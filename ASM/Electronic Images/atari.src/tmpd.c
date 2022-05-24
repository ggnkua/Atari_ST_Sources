/*
 *	PLAYMPEG, dither routines etc.
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include "plaympeg.h"
#include "proto.h"

static unsigned char *dithered_image;
static unsigned char ytab[(long) 16*(256+16)];
static unsigned char uvtab[(long) 256*269+270];
static unsigned char pixel[256];
static int ap_id;
static int fo_cx,fo_cy,fo_cw,fo_ch,rt,mx,my,du;
static int gr_handle;
static int work_in[11],
             work_out[57];
             
void init_resource(void)
{	
	/*rsrc_load(RESOURCENAME);
	rsrc_gaddr(0,FORM1,&form1);
	rsrc_gaddr(0,FORM2,&form2);
	rsrc_gaddr(0,FORM3,&form3); */
}

static int saved_pal[256][3];
static int current_pal[256][3];

void save_palette(void)
{	INT32 i;
 	for (i=0; i<256; i++)
        vq_color(gr_handle,i,1,&saved_pal[i][0]);
}

void restore_palette(void)
{	INT32 i;	
	for (i=0; i<256; i++)
        vs_color(gr_handle,i,&saved_pal[i][0]);
}

void set_current_pal(void)
{	INT32 i;	
	for (i=32; i<240; i++)
        vs_color(gr_handle,i,&current_pal[i][0]);
}

#define COLOURS_256_PACKED (0)
#define COLOURS_15BIT_PACKED (1)
#define COLOURS_16_PACKED_GREYSCALE (2)
#define COLOURS_MONO (3)

static int win_x = 200;
static int win_y = 350;
static int screen_type;
unsigned char table_4bit[256][256];
UINT16 table_15bit[16][16][256];

extern void cdecl dither_16bit(unsigned char *,unsigned char *,unsigned char *,unsigned char *);

void init_display(void)
{	INT32 crv, cbu, cgu, cgv;
	crv = convmat[5][0];
	cbu = convmat[5][1];
	cgu = convmat[5][2];
	cgv = convmat[5][3];

  	ap_id = appl_init();
	{	int j;
		for (j = 0 ; j < 10 ; j++)
		{	work_in[j] = 1;
		}
		work_in[10] = Getrez()+2;
	}
		
	gr_handle = graf_handle(&du,&du,&du,&du);
	v_opnvwk(work_in,&gr_handle,work_out);
	vq_extnd(gr_handle,1,work_out);

  	init_resource();

	switch (work_out[4])
	{	case 16:
			screen_type = COLOURS_15BIT_PACKED;
			break;
		case 8:
			screen_type = COLOURS_256_PACKED;
			break;
		case 4:
			screen_type = COLOURS_16_PACKED_GREYSCALE;
			break;
		case 1:
			screen_type = COLOURS_MONO;
			break;
	}		

	switch (screen_type)
	{	

		case COLOURS_16_PACKED_GREYSCALE:
		{	INT32 i,j;
			save_palette();
			for (i=0 ; i < 16; i++)
			{	current_pal[i][0] = (i * 1000) >> 4;
				current_pal[i][1] = (i * 1000) >> 4;
			    current_pal[i][2] = (i * 1000) >> 4;
				vs_color(gr_handle,(int) i,&current_pal[i][0]);
			}
			
			for (i=0 ; i < 256; i++)
			{	for (j=0 ; j < 256; j++)
				{	INT32 a = i & 0x0f;
					INT32 b = j & 0x0f;
					INT32 c = i >> 4;
					INT32 d = j >> 4;
					table_4bit[i][j] = (c << 4) | d ;
					
				}
			}	
			if (!(dithered_image = (unsigned char *)malloc((long) coded_picture_width*
                                                   coded_picture_height)))
    	  		error("\nNot enough memory!\n");

			break;
		}
		case COLOURS_256_PACKED:
		{	INT32 i,j,v;
			 unsigned char ctab[256+32];
			/* color allocation:
			 * i is the  8 bit color number, it consists of separate
			 * bit fields for Y, U and V: i = (yyyyuuvv), we don't use yyyy=0000
			 * yyyy=0001 and yyyy=1111, this leaves 48 colors for other applications
			 *	
			 * the allocated colors correspond to the following Y, U and V values:
			 * Y:   40, 56, 72, 88, 104, 120, 136, 152, 168, 184, 200, 216, 232
			 * U,V: -48, -16, 16, 48
			 *
			 * U and V values span only about half the color space; this gives
			 * usually much better quality, although highly saturated colors can
			 * not be displayed properly
			 *
			 * translation to R,G,B is implicitly done by the color look-up table
			 */
			save_palette();
			for (i=32; i<240; i++)
			{	INT32 y, u, v, r, g, b;

			    y = 16*((i>>4)&15) + 8;
		    	u = 32*((i>>2)&3)  - 48;
			    v = 32*(i&3)       - 48;
    			y = 76309 * (y - 16); /* (255/219)*65536 */
			    r = clp[(y + crv*v + 32768)>>16];
    			g = clp[(y - cgu*u -cgv*v + 32768)>>16];
		    	b = clp[(y + cbu*u + 32786)>>16];
				current_pal[i][0] = (r * 1000) >> 8;
			    current_pal[i][1] = (g * 1000) >> 8;
		    	current_pal[i][2] = (b * 1000) >> 8;
    			pixel[i] = i;
		  	}

			for (i=0; i<256+16; i++)
			{
				v = (i-8)>>4;
			    if (v<2)
					v = 2;
				else if (v>14)
					v = 14;
				for (j=0; j<16; j++)
			      ytab[16*i+j] = pixel[(v<<4)+j];
  			}

			for (i=0; i<256+32; i++)
			{
				v = (i+48-128)>>5;
			    if (v<0)
				    v = 0;
				else if (v>3)
				    v = 3;
				ctab[i] = v;
			  }

			for (i=0; i<255+15; i++)
				for (j=0; j<255+15; j++)
					uvtab[256*i+j]=(ctab[i+16]<<6)|(ctab[j+16]<<4)|(ctab[i]<<2)|ctab[j];

	    	if (!(dithered_image = (unsigned char *)malloc((long) coded_picture_width*
                                                   coded_picture_height)))
    	  		error("\nNot enough memory!\n");

			set_current_pal();
			break;
		}
		case COLOURS_15BIT_PACKED:
		{	INT32 yc,uc,vc;
			UINT16 *t = table_15bit;	
			for (uc = 0 ; uc < 256 ; uc +=16)
			{	for (vc = 0 ; vc < 256 ; vc +=16)
				{	for (yc = 0 ; yc < 256 ; yc ++)
					{	INT32 y, u, v, r, g, b;
		    			y = (yc-16) * 76309 ; /* (255/219)*65536 */
		    			u = uc-128;
		    			v = vc-128; 
					    r = clp[(y + crv*v + 32768)>>16] >> 3;
    					g = clp[(y - cgu*u -cgv*v + 32768)>>16] >> 3;
		    			b = clp[(y + cbu*u + 32786)>>16] >> 3;
			    		*t++ = ( (r<<10) | ( g << 5) | b);
					}
				}
			}
			if (!(dithered_image = (unsigned char *)malloc((long) coded_picture_width*
                                                   coded_picture_height*2l)))
	   	  		error("\nNot enough memory!\n");

			break;
		}
		
	}
	
}

void exit_display()
{	
	switch (screen_type)
	{	
		case COLOURS_16_PACKED_GREYSCALE:
		case COLOURS_256_PACKED:
		{
			restore_palette();	
			break;
		}
		case COLOURS_15BIT_PACKED:
		{	 
			break;
		}
	}
	v_clsvwk(gr_handle);	
	rsrc_free();
	appl_exit();
}


/* 4x4 ordered dither
 *
 * threshold pattern:
 *   0  8  2 10
 *  12  4 14  6
 *   3 11  1  9
 *  15  7 13  5
 */

void dither(src)
unsigned char *src[];
{	unsigned char *py = src[0],*pu = src[1] ,*pv = src[2];
	MFDB src_mfdb,dst_mfdb;
	INT16 pxy[8];
	
	pxy[0] = 0;
	pxy[1] = 0;
	pxy[2] = horizontal_size-1;
	pxy[3] = vertical_size-1;
	pxy[4] = win_x;
	pxy[5] = win_x;
	pxy[6] = win_x+horizontal_size-1;
	pxy[7] = win_y+vertical_size-1;

	switch (screen_type)
	{	
		case COLOURS_16_PACKED_GREYSCALE:
		{	int i,j;
  			unsigned char *dst = dithered_image;
  			for (j=0; j<coded_picture_height; j+=1)
		  	{	unsigned char error = 8;
				for (i=0; i<coded_picture_width; i+=2)
			    {	unsigned char a = *py++;
			    	unsigned char b = *py++;
			    	unsigned char c = a & 0xf;
			    	unsigned char d = b & 0xf;
			    	unsigned char e = a >> 4;
			    	unsigned char f = b >> 4;
			    	if (c > 8)
			    	{	e++;
			    		if (e>15)
			    			e = 15;
			    	}
			    	if (d > 8)
			    	{	f++;
			    		if (f>15)
			    			f = 15;
			    	}
					*dst++ = (e<<4) | f;
			    }

	 		}
			src_mfdb.fd_addr = dithered_image;
			src_mfdb.fd_w = coded_picture_width;
			src_mfdb.fd_h = coded_picture_height;
			src_mfdb.fd_r1 = 0;
			src_mfdb.fd_r2 = 0;
			src_mfdb.fd_r3 = 0;
			dst_mfdb.fd_addr = NULL; /* current screen */
			src_mfdb.fd_wdwidth = (coded_picture_width + 15) / 16;
			src_mfdb.fd_stand = 0;
			src_mfdb.fd_nplanes = 4;
			vro_cpyfm(gr_handle,S_ONLY,&pxy,&src_mfdb,&dst_mfdb);
			break;
		
		}
		
		case COLOURS_256_PACKED:
  		{	int i,j,uv;
  			unsigned char *dst = dithered_image;
  			for (j=0; j<coded_picture_height; j+=4)
		  	{
		   		/* line j + 0 */
				for (i=0; i<coded_picture_width; i+=4)
			    {
				    uv = uvtab[((UINT32) *pu++<<8)|(UINT32) *pv++];
					*dst++ = ytab[(((UINT32) *py++)<<4)|(uv&15)];
				    *dst++ = ytab[(((UINT32) *py++ +8)<<4)|(uv>>4)];
				    uv = uvtab[(((UINT32) *pu++<<8)|(UINT32) *pv++)+1028];
				    *dst++ = ytab[(((UINT32) *py++ +2)<<4)|(uv&15)];
				    *dst++ = ytab[(((UINT32) *py++ +10)<<4)|(uv>>4)];
			    }

		      	pu -= chrom_width;
      			pv -= chrom_width;

				/* line j + 1 */
			    for (i=0; i<coded_picture_width; i+=4)
			    {
				    uv = uvtab[(((UINT32) *pu++<<8)|(UINT32) *pv++)+2056];
				    *dst++ = ytab[(((UINT32) *py++ +12)<<4)|(uv>>4)];
					*dst++ = ytab[(((UINT32) *py++ +4)<<4)|(uv&15)];
				    uv = uvtab[(((UINT32) *pu++<<8)|(UINT32) *pv++)+3084];
				    *dst++ = ytab[(((UINT32) *py++ +14)<<4)|(uv>>4)];
				    *dst++ = ytab[(((UINT32) *py++ +6)<<4)|(uv&15)];
			    }

			    /* line j + 2 */
			    for (i=0; i<coded_picture_width; i+=4)
			    {
				    uv = uvtab[(((UINT32) *pu++<<8)|(UINT32) *pv++)+1542];
				    *dst++ = ytab[(((UINT32) *py++ +3)<<4)|(uv&15)];
				    *dst++ = ytab[(((UINT32) *py++ +11)<<4)|(uv>>4)];
					 uv = uvtab[(((UINT32) *pu++<<8)|(UINT32) *pv++)+514];
					*dst++ = ytab[(((UINT32) *py++ +1)<<4)|(uv&15)];
				    *dst++ = ytab[(((UINT32) *py++ +9)<<4)|(uv>>4)];
			    }
		
			    pu -= chrom_width;
			    pv -= chrom_width;

				/* line j + 3 */
			    for (i=0; i<coded_picture_width; i+=4)
			    {
				    uv = uvtab[(((UINT32) *pu++<<8)|(UINT32) *pv++)+3598];
					*dst++ = ytab[(((UINT32) *py++ +15)<<4)|(uv>>4)];
					*dst++ = ytab[(((UINT32) *py++ +7)<<4)|(uv&15)];
				    uv = uvtab[(((UINT32) *pu++<<8)|(UINT32) *pv++)+2570];
				    *dst++ = ytab[(((UINT32) *py++ +13)<<4)|(uv>>4)];
				    *dst++ = ytab[(((UINT32) *py++ +5)<<4)|(uv&15)];
			    }
	 		}
  
			src_mfdb.fd_addr = dithered_image;
			src_mfdb.fd_w = coded_picture_width;
			src_mfdb.fd_h = coded_picture_height;
			src_mfdb.fd_r1 = 0;
			src_mfdb.fd_r2 = 0;
			src_mfdb.fd_r3 = 0;
			dst_mfdb.fd_addr = NULL; /* current screen */
			src_mfdb.fd_wdwidth = (coded_picture_width + 15) / 16;
			src_mfdb.fd_stand = 0;
			src_mfdb.fd_nplanes = 8;
			vro_cpyfm(gr_handle,S_ONLY,&pxy,&src_mfdb,&dst_mfdb);
			break;
		}
		case COLOURS_15BIT_PACKED:
		{	dither_16bit(pu,pv,py,dithered_image);
			/*
			int i,j,uv;
  			UINT16 *dst = (UINT16 *) dithered_image;
  			UINT16 *t;
  			for (j=0; j<coded_picture_height; j+=2)
		  	{
				for (i=0; i<coded_picture_width; i+=2)
			    {	t = &table_15bit[*pu++ >> 4][*pv ++ >> 4][0];
					*dst++ = t[(UINT32) *py++];
					*dst++ = t[(UINT32) *py++];
			    }

		      	pu -= chrom_width;
      			pv -= chrom_width;
				for (i=0; i<coded_picture_width; i+=2)
			    {	t = &table_15bit[*pu++ >> 4][*pv++ >> 4][0];
					*dst++ = t[(UINT32) *py++];
					*dst++ = t[(UINT32) *py++];
			    }
	 		}
	 		
	 		*/
			src_mfdb.fd_addr = dithered_image;
			src_mfdb.fd_w = coded_picture_width;
			src_mfdb.fd_h = coded_picture_height;
			src_mfdb.fd_r1 = 0;
			src_mfdb.fd_r2 = 0;
			src_mfdb.fd_r3 = 0;
			dst_mfdb.fd_addr = NULL; /* current screen */
			src_mfdb.fd_wdwidth = (coded_picture_width + 15) / 16;
			src_mfdb.fd_stand = 0;
			src_mfdb.fd_nplanes = 16;
			vro_cpyfm(gr_handle,S_ONLY,&pxy,&src_mfdb,&dst_mfdb);

			break;

		}		
	}
}
