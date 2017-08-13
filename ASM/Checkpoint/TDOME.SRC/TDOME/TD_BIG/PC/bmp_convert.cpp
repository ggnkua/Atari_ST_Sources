//---------------------------------------------------------------------------------
#include <stdio.h>
#include <conio.h>
#include <math.h>
#include <windows.h>
//---------------------------------------------------------------------------------
#include "datatypes.h"
#include "main.h"
#include "filestuff.h"
#include "display.h"
//---------------------------------------------------------------------------------


// in
char bmpC_fname[512]	= "TD_BIG.BMP";

// out
char st_gfx_fname[512]	= "TD_BIG.GFX";


u8 bmpC_buffer[1512000];


u32 bmpC_colors[256];


u8 *outBC;
u8 outBC_buffer[256000];


int pc_color_to_st(int c)
{
	c = (c*8)/256;
	if(c<0) c=0;
	if(c>7) c=7;
	return c;
}

void write_bc16(int v)
{
	*outBC++=(v>>8)&255;
	*outBC++=v&255; 
}

void convert_bmp()
{
	int i;
	int x,y;

	int texC_x = 752;
	int texC_y = 132;

	outBC = outBC_buffer;
	
	load_file(bmpC_fname, bmpC_buffer);

	// palette
	u32 r,g,b,colst;
	u8  *p=bmpC_buffer;
	p+=54;		// skip header
	for(i=0;i<16;i++)
	{
		b=*p++;
		g=*p++;
		r=*p++;
		p++;
		bmpC_colors[i] = (r<<16) | (g<<8) | b;

		r = pc_color_to_st(r);
		g = pc_color_to_st(g);
		b = pc_color_to_st(b);
		colst = (r<<8)|(g<<4)|(b);
		write_bc16(colst);	
	}

	// gfx
	u8  c;
	p=bmpC_buffer;
	p+=1078;	// skip header & colortable

	int xx;
	u16 p3,p2,p1,p0;

	for(y=0;y<texC_y;y++)
	{
		for(x=0;x<texC_x/16;x++)
		{
			p3=p2=p1=p0=0;
			for(xx=0;xx<16;xx++)
			{
 				p3<<=1;
				p2<<=1;
				p1<<=1;
				p0<<=1;
				c = *(p+(texC_y-1-y)*texC_x + x*16 + xx);
				if(c&8) p3|=1; 
				if(c&4) p2|=1; 
				if(c&2) p1|=1; 	
				if(c&1) p0|=1; 
			}
			write_bc16(p0);
			write_bc16(p1);
			write_bc16(p2);
			write_bc16(p3);
		}
	}

	i = outBC-outBC_buffer;
	save_file( st_gfx_fname, outBC_buffer, i );

}