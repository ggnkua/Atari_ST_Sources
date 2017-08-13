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
	dens = (128)/(r);	//16
//	dens+=8.f*r;

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

/*
				x = xp-32;
				y = yp-32;
				z = zp-32;
				x*=0.1251f;
				y*=0.1251f;
				z*=0.1251f;
*/

				x = (xp*2*PI)/63;
				y = (yp*2*PI)/63;
				z = (zp*2*PI)/63;

				dsin = 3*sin(x);
				dsin+= 3*sin(y);
				dsin+= 3*sin(z);
				dsin+=(3+3+3 +1);



//				dsin = 10+4*sin(x)*sin(y)*sin(z);

				
				dens = dsin;
				dens = dens_func(dens);



//				r+=0.0000001f;
//				dens = (128*100)/(r);

				dens=dens*0.75f;

				voxel[zp][yp][xp] = dens;
			}
		}
	}
}



double proj_z = -300;
double z_zoom = 70;


void render_voxel()
{
	int xp,yp,zp;
	int xv,yv,zv;
	int col;

	double x,y,z;
	double xx,yy,zz;

	double zf;

	double color;
	double dens;

	static double xr = 0;
	static double yr = 0;
	static double zr = 0;


	double xsin=sin(xr);
	double xcos=cos(xr);

	double ysin=sin(yr);
	double ycos=cos(yr);	

	double zsin=sin(zr);
	double zcos=cos(zr);


	double z_trans = 0;

	int ft = 1;

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

				x = 1.2f*x;
				y = 1.2f*y;
				z = 1.2f*z;

				yy=y;
				y = y*xcos +  z*xsin;
				z = z*xcos - yy*xsin;

				xx=x;
				x = x*ycos +  z*ysin;
				z = z*ycos - xx*ysin;				
/*				
				xx=x;
				x = x*zcos +  y*zsin;
				y = y*zcos - xx*zsin;
*/

				zf=z+z_trans;
				zf = 1.f - ((z_zoom-zf)/(proj_z-zf));
				x*=zf;
				y*=zf;

				xv = x+32.5f;
				yv = y+32.5f;
				zv = z+32.5f;

				if( (xv<0) || (xv>63) || (yv<0) || (yv>63) || (zv<0) || (zv>63) )
				{

				}
				else
				{
					dens = voxel[zv][yv][xv];
					if(dens>10.f)	// <120
					{
						//color=48*voxel[zv][yv][xv];
						color=voxel[zv][yv][xv];
					//	color=color-180;
					//	color=color*48;

					//	color-=650;

						color = color*64*1024; //32;

						//color+=64*(voxel[zv][yv][xv]);
						break;
					}
				}

				//color+=voxel[zv][yv][xv];
				
			}

			color = color/64;
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

//	xr+=0.04f;
	yr+=0.04f;

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

