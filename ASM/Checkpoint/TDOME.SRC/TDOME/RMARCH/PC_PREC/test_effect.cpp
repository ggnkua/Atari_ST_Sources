//
// ray-marching
// totally unoptimized
// (w)2014 lsl/checkpoint
//


#define PI 3.1415926f


#include <math.h>
#include "filestuff.h"
#include "test_effect.h"

#define VS   64
#define VSA (VS-1)

double voxel[VS][VS][VS];

//-----------------------------------
u8 voxel_INT[VS][VS][VS];
u8 voxel_colors[VS][VS][VS];
//-----------------------------------

u8 frame_output[50][80];
u8 frame_output_4bpp[50][80/2];


int colorlut[16*256];


double frame = 0;

int frame_num = 0;


int frames_to_save = 128;


FILE *so_file = 0;
int so_done = 0;


int get_color_so(int col)
{
	col = col>>4;
	col = col&15;

//	col = 8+15-col;
	
	col = col&15;

	return col;
}

int save_output()
{
	int xp,yp,c0,c1,c;

	//if(frame)		return 0;


	if(so_done)	return -1;	// all done?


	if(so_file==0)
	{
		so_file = fopen("OUTPUT.DAT","wb");
	}


	if(frame_num==frames_to_save)
	{
		printf("\n\nclosing output file..\n");
		fclose( so_file);
		so_done=1;
	}
	

	for(yp=0;yp<50;yp++)
	{
		for(xp=0;xp<(80/2);xp++)
		{
			c0 = frame_output[yp][0+xp*2];
			c1 = frame_output[yp][1+xp*2];

			c0 = get_color_so(c0);
			c1 = get_color_so(c1);

			c  = (c0<<4)|c1;

			frame_output_4bpp[yp][xp] = c;
		}
	}

	fwrite( frame_output_4bpp, sizeof(frame_output_4bpp), 1, so_file);

	return 0;
}




void init_voxel_colors()
{
	int xp,yp,zp;
	int xv,yv,zv;

	double nx,ny,nz;
	double r,dens;
	double color;

	for(zp=0;zp<VS;zp++)
	{
		for(yp=0;yp<VS;yp++)
		{
			for(xp=0;xp<VS;xp++)
			{
				xv = xp;
				yv = yp;
				zv = zp;

				dens = voxel[zv][yv][xv];

				nx = voxel[zv][yv][(xv-1)&VSA] - voxel[zv][yv][(xv+1)&VSA];
				ny = voxel[zv][(yv-1)&VSA][xv] - voxel[zv][(yv+1)&VSA][xv];
				nz = voxel[(zv-1)&VSA][yv][xv] - voxel[(zv+1)&VSA][yv][xv];

				r  = sqrt(nx*nx + ny*ny + nz*nz);
				r  = 128.f/(r+0.0001f);
				nx = nx*r;
				ny = ny*r;
				nz = nz*r;

				color=255-(nz+256+128);

				//color = 128 + 8*256+(0.005*ny*nz);

				voxel_colors[zp][yp][xp] = color;
			}
		}
	}
}




double dens_func(double r)
{
	double dens;
	r+=0.0000001f;
	dens = (16+128)/(r);	//16

	return dens;
}

void init_voxel()
{
	int xp,yp,zp;
	double x,y,z;
	double r,dens,dsin;

	double x0=24-32;
	double y0=-32;
	double z0=-32;

	double x1=-24-32;
	double y1=-32;
	double z1=-32;

	double x2=-32;
	double y2=-32;
	double z2=-20-32;


	for(zp=0;zp<VS;zp++)
	{
		for(yp=0;yp<VS;yp++)
		{
			for(xp=0;xp<VS;xp++)
			{
				r = 0;
				dens = 0;

				x = xp+x0;
				y = yp+y0;
				z = zp+z0;
				r = sqrt(x*x + y*y + z*z);
				dens+=dens_func(r);

				x = xp+x1;
				y = yp+y1;
				z = zp+z1;
				r = sqrt(x*x + y*y + z*z);				
				dens+=dens_func(r);

				x = xp+x2;
				y = yp+y2;
				z = zp+z2;
				r = sqrt(x*x + y*y + z*z);
				dens+=dens_func(r);

				//-----------------------------------------

				x = (xp*2*PI)/VS + PI/2;
				y = (yp*2*PI)/VS + PI/2;
				z = (zp*2*PI)/VS + PI/2;

				dsin =  3*sin(x);
				dsin+=  3*sin(y);
				dsin+=  3*sin(z);
				dsin+=(3+3+3 +1);

				dens = dsin;
				dens = dens_func(dens);


				dens=dens*0.75f;

				voxel[zp][yp][xp] = dens;

				voxel_INT[zp][yp][xp] = dens;
			
			}
		}
	}

	init_voxel_colors();

}



double proj_z = 500;
double z_zoom = 0;

double xr = 0;
double yr = 0;
double zr = 0;

double x_scroll = 0;
double y_scroll = 0;
double z_scroll = 0;


void setup_movement()
{
	double t;
	double a;
	int frint = frame;
	frint=frint&127;

	t = frint;

	xr =  2*PI*t/128;
	yr = -2*PI*t/128;
/*
	x_scroll=64*cos(2*PI*t/128);
	y_scroll=64*sin(2*PI*t/128);
	z_scroll=t;

	return;
*/

/*
	x_scroll=t;
	y_scroll=t/2;
	z_scroll=2*t;
*/
	x_scroll=2*t;
	y_scroll=t;
	z_scroll=4*t;

}



void render_voxel()
{
	int xp,yp,zp;
	int xv,yv,zv;
	int col;

	double x,y,z;
	double xx,yy,zz;

	double nx,ny,nz;
	double r,denom;

	double zs;

	double zf;

	double color;
	double dens;

	double depths;


	int dens_INT;



	setup_movement();


	double xsin=sin(xr);
	double xcos=cos(xr);

	double ysin=sin(yr);
	double ycos=cos(yr);	

	double zsin=sin(zr);
	double zcos=cos(zr);


	double z_trans = 0;

	double ft = 1;

	for(yp=0;yp<50;yp++)		// 64
	{
		for(xp=0;xp<80;xp++)	// 80
		{
			color = 0;

			for(zp=0;zp<64;zp++)
			{
				x = xp-ft*80/2;
				y = yp-ft*50/2;
				z = zp-ft*32;

				x = 16*32.f*x;
				y = 16*32.f*y;
				z = 16*32.f*z;

				zs=0.3*z - 32*200;


				yy=y;
				y = y*xcos +  z*xsin;
				z = z*xcos - yy*xsin;

				xx=x;
				x = x*ycos +  z*ysin;
				z = z*ycos - xx*ysin;				
				
				xx=x;
				x = x*zcos +  y*zsin;
				y = y*zcos - xx*zsin;

				zf = 1.f - ((z_zoom-zs)/(proj_z-zs));	// CONST!
				
				zf*=0.05; //25;

				x*=zf;
				y*=zf;
				z*=zf; // BESSER SO??!

				// movement x,y,z axxis
				/*
				xv = x + 100*sin(0.03723f*z_scroll);
				yv = y + 50*sin(0.02132f*z_scroll);
				zv = z + 0*sin(0.012615f*z_scroll) + 3.f*z_scroll;
				*/

				x+=x_scroll;
				y+=y_scroll;
				z+=z_scroll;

				xv=x;
				yv=y;
				zv=z;

				xv=xv&VSA;
				yv=yv&VSA;
				zv=zv&VSA;

				dens_INT = voxel_INT[zv][yv][xv];
				
				if(dens_INT>(10))
				{
					color = voxel_colors[zv][yv][xv];
					break;
				}
				
			}

			depths = 2*(12000-zs);
			depths-=10000;

			color = (color*depths)/30000;
			if(color<0) color=0;


			col = color;
			col = col&(4*256-1);
			col = colorlut[col];

			frame_output[yp][xp] = col;

			chunkyBuffer[0+yp*4][0+xp*4] = col;
			chunkyBuffer[0+yp*4][1+xp*4] = col;
			chunkyBuffer[0+yp*4][2+xp*4] = col;			
			chunkyBuffer[0+yp*4][3+xp*4] = col;
			chunkyBuffer[1+yp*4][0+xp*4] = col;
			chunkyBuffer[1+yp*4][1+xp*4] = col;
			chunkyBuffer[1+yp*4][2+xp*4] = col;			
			chunkyBuffer[1+yp*4][3+xp*4] = col;
			chunkyBuffer[2+yp*4][0+xp*4] = col;
			chunkyBuffer[2+yp*4][1+xp*4] = col;
			chunkyBuffer[2+yp*4][2+xp*4] = col;			
			chunkyBuffer[2+yp*4][3+xp*4] = col;
			chunkyBuffer[3+yp*4][0+xp*4] = col;
			chunkyBuffer[3+yp*4][1+xp*4] = col;
			chunkyBuffer[3+yp*4][2+xp*4] = col;			
			chunkyBuffer[3+yp*4][3+xp*4] = col;
		}
	}

/*
	double ff;

	ff = 2.5;

	xr+=ff*0.2*0.02f;
	yr-=ff*0.2*0.015f;
	zr+=ff*0.011f;

	ff = 0.3;

	z_scroll+=ff*0.7*1;
*/
}



int colclip(int c)
{
	if(c<0) c=0;
	if(c>255) c=255;
	return c;
}


int init_test_effect()
{
	int i,j,r,g,b,idc;

	init_voxel();

	for(i=0;i<256;i++)
	{
		r = i-47;
		g = i;
		b = 1.25*i+27;

		r=colclip(r);
		g=colclip(g);
		b=colclip(b);
		colortable[i] = (r<<16) | (g<<8) | b;
	}



	idc = 0;
	for(j=0;j<256;j++)
	{
		colorlut[idc++] = j;
	}

	for(i=0;i<7;i++)
	{
		for(j=0;j<256;j++)
		{
			colorlut[idc++] = 255;
		}
		for(j=255;j>0;j--)
		{
			colorlut[idc++] = 255;
		}
	}

/*
	idc = 0;
	for(i=0;i<8;i++)
	{
		for(j=0;j<256;j++)
		{
			colorlut[idc++] = j;
		}
		for(j=255;j>0;j--)
		{
			colorlut[idc++] = j;
		}
	}
*/
	
//	save_file( "VOXEL.DNS", (u8*)&voxel_INT, sizeof(voxel_INT) );
//	save_file( "VOXEL.COL", (u8*)&voxel_colors, sizeof(voxel_colors) );
	
	return 0;
}



int do_test_effect()
{
	int xp,yp;
	int col;


	render_voxel();

	save_output();


	frame+=1.0f;	// advance framecounter
	frame_num++;

	return 0;
}

