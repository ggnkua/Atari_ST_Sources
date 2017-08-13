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


char bmpC_fname[512] = "player.bmp";

char st_texsave_fname[512]		= "PLAYER.DAT";
char st_texsave606_fname[512]	= "PLAYER.606";


u8 bmpC_buffer[1512000];


u8 st_texture[32+256*256];
u8 st_texture606[32+256*256];


u32 bmpC_colors[256];

u8 *outBC;


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
	int texC_x = 256;
	int texC_y = 256;

	outBC = st_texture;
	
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
	for(y=0;y<texC_y;y++)
	{
		for(x=0;x<texC_x;x++)
		{
			c = *(p+(texC_y-1-y)*texC_x + x);
			rgbBuffer_display[y][x] = bmpC_colors[c];
			*outBC++ = c;
			//texture0[y][x]=c;
		}
	}

	save_file(st_texsave_fname, st_texture, sizeof(st_texture) );


	// make 606 optimized texture 
	u8 *p606 = st_texture606;
	p = st_texture;

	// palette
	memcpy(p606, p, 32);
	p606+=32;
	p+=32;

	// gfx
	for(y=0;y<texC_y;y++)
	{
		for(x=0;x<texC_x;x++)
		{
			c = *p++;
			c = (c*8)+0x06;	// chunkysize=8, base=0x06
			*p606++=c;
		}
	}

	save_file(st_texsave606_fname, st_texture606, sizeof(st_texture606) );

}