//
// basic test-effect (z-rot-zoomer)
// totally unoptimized
// (w)2013 defjam/checkpoint
//


#define PI 3.1415926f


#include <math.h>
#include "filestuff.h"
#include "test_effect.h"


double voxel[64][64][64];


int colorlut[16*256];


double frame = 0;





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


	for(zp=0;zp<64;zp++)
	{
		for(yp=0;yp<64;yp++)
		{
			for(xp=0;xp<64;xp++)
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

				x = (xp*2*PI)/64 + PI/2;
				y = (yp*2*PI)/64 + PI/2;
				z = (zp*2*PI)/64 + PI/2;

				dsin =  3*sin(x);
				dsin+=  3*sin(y);
				dsin+=  3*sin(z);
				dsin+=(3+3+3 +1);

				dens = dsin;
				dens = dens_func(dens);


				dens=dens*0.75f;

				voxel[zp][yp][xp] = dens;
			}
		}
	}
}



double proj_z = 100;
double z_zoom = 0;


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

	static double xr = 0;
	static double yr = 0;
	static double zr = 0;

	static double z_scroll = 0;


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

				x = 2.0f*x;
				y = 2.0f*y;
				z = 2.0f*z;

				zs=z;


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

	z*=zf; // BESSER SO??!

				x*=zf;
				y*=zf;

				xv = x + 100*sin(0.03723f*z_scroll);
				yv = y + 50*sin(0.02132f*z_scroll);
				zv = z + 0*sin(0.012615f*z_scroll) + 3.f*z_scroll;

				xv=xv&63;
				yv=yv&63;
				zv=zv&63;

				dens = voxel[zv][yv][xv];

				if(dens>13.f)
				{
					// Gradient - am Besten!!
					// --> eigentlich stehen die Farbwerte fest --> 2. Tabelle!!
					nx = voxel[zv][yv][(xv+1)&63] - dens;
					ny = voxel[zv][(yv+1)&63][xv] - dens;
					nz = voxel[(zv+1)&63][yv][xv] - dens;
					r  = sqrt(nx*nx + ny*ny + nz*nz);
					r  = 128.f/(r+0.0001f);
					nz = nz*r;
					color=(nz+128);

					// color=color*(64-zp+20)/84; // depth-shading

					break;
				}
			}

			col = color;
			col = col&(4*256-1);
			col = colorlut[col];

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

	double ff;

	ff = 0.4;

	xr+=ff*0.2*0.02f;
	yr-=ff*0.2*0.015f;
	zr+=ff*0.011f;

	ff = 0.4;

	z_scroll+=ff*0.7*1;

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
	return 0;
}



int do_test_effect()
{
	int xp,yp;
	int col;


	render_voxel();

	return 0;
	//----------------------------------------------

	for(yp=0;yp<YW;yp++)
	{
		for(xp=0;xp<XW;xp++)
		{
			col=xp+yp;

			col = col&(4*256-1); //255;

			chunkyBuffer[yp][xp] = colorlut[col];
		}
	}


	frame+=1.0f;	// advance framecounter

	return 0;
}

