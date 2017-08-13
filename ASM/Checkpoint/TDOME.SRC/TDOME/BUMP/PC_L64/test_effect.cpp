//
//
//
//


#include <math.h>
#include "filestuff.h"
#include "test_effect.h"


u8 light[64][64];

u8 bump_out[100][160][2];


void init_light()
{
	int xp,yp;
	int c;
	double x,y;
	double r;

	for(yp=0;yp<64;yp++)
	{
		for(xp=0;xp<64;xp++)
		{
			x = xp-64/2;
			y = yp-64/2;
			r = x*x + y*y;

			r = 0.2*r + 150; //150;

			r = 1.5*255-r;

			c = r;
			if(c<0)		c=0;
			if(c>255)	c=255;

			chunkyBuffer[yp][xp] = c;

			light[yp][xp] = c;
		}
	}

	save_file("LIGHT.8B", (u8*)light, sizeof(light) );
}


u8 red[256];
u8 green[256];
u8 blue[256];

u8 st_pal[16*2];

int colclip(int c)
{
	if(c<0)		c = 0;
	if(c>255)	c=255;
	return c;
}

int col2st(int c)
{
	c = c*0.65f;

	c = c*15;
	c = c/255;
	if(c<0)	c = 0;
	if(c>7)	c = 7;
	return c;
}

void init_palette()
{
	int r,g,b, col;
	int i,j;
	u8 *stp;

	for(i=0;i<256;i++)
	{
		r = i-23;
		g = i-42;
		b = i;

		r = 1.3*r;
		g = 1.2*g;
		b = 1.7*b;

		r = colclip(r);
		g = colclip(g);
		b = colclip(b);

		red[i]	 = r;
		green[i] = g;
		blue[i]	 = b;

		colortable[i] = (r<<16) | (g<<8) | b;
	}

	// ST-palette
	stp = (u8*)&st_pal;
	for(j=0;j<16;j++)
	{
		i = j*16;

		r = red[i];
		g = green[i];
		b = blue[i];

		r = col2st(r);
		g = col2st(g);
		b = col2st(b);

		col = (r<<8)|(g<<4)|(b);

		*stp++=(col>>8)&255;
		*stp++=col&255;
	}
	save_file("COLORS.ST", (u8*)st_pal, sizeof(st_pal) );
}



int init_test_effect()
{
	init_light();
	
	init_palette();

	return 0;
}



int do_test_effect()
{
	int xp,yp;
	int xv,yv;
	int u,v;

	int c;
	int c0,c1,c2,c3;

	double x,y;
	double nx,ny;
	double l;
	
	static double frame=0.f;
	static int first_frame=1;

	double x_move,y_move;

	x_move = 20*sin(0.0325*frame);	// 32
	y_move = 20*sin(0.0492*frame);	// 32

	u8 *bump_outPtr = (u8*)&bump_out;

	for(yp=0;yp<100;yp++)
	{
		for(xp=0;xp<160;xp++)
		{
			x = xp-160/2;
			y = yp-100/2;

			xv = xp+3;
			yv = yp+1;
			c0 = 0*255-texture0[yv][xv-1];
			c1 = 0*255-texture0[yv][xv+1];
			c2 = 0*255-texture0[yv-1][xv];
			c3 = 0*255-texture0[yv+1][xv];

/*
			xv = xp;
			yv = yp;
			c0 = 0*255-texture0[yv][xv];
			c1 = 0*255-texture0[yv][xv+1];
			c2 = 0*255-texture0[yv][xv];
			c3 = 0*255-texture0[yv+1][xv];
*/

			nx = (c1-c0);
			ny = (c3-c2);

// l = 0.15 + 8/(20 + sqrt(nx*nx + ny*ny));

l = 0.1 + 4/(20 + sqrt(nx*nx + ny*ny));

//			l = 0.15;	// 0.1

			nx = nx*l + 0*0.0015*x;	// 0.0015
			ny = ny*l + 0*0.0015*y;

			u = 32+nx + x_move; 
			v = 32+ny + y_move;

			u&=63;
			v&=63;

			if(first_frame)
			{
				*bump_outPtr++=u;
				*bump_outPtr++=v;
			}

			c = light[v][u];
			chunkyBuffer[0+yp*2][0+xp*2] = c;
			chunkyBuffer[0+yp*2][1+xp*2] = c;
			chunkyBuffer[1+yp*2][0+xp*2] = c;
			chunkyBuffer[1+yp*2][1+xp*2] = c;

		}
	}

	if(first_frame)
	{
		save_file("BUMP.UV", (u8*)&bump_out, sizeof(bump_out) );
	}


	frame+=1.0f;	// advance framecounter
	first_frame = 0;

	return 0;
}

