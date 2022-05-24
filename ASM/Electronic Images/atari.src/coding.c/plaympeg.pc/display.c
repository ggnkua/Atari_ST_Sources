/*
 *	PLAYMPEG, dither routines etc.
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include "plaympeg.h"

static int screen_type;
static unsigned char *dithered_image;
static unsigned char ytab[(long) 16*(256+16)];
unsigned char uvtab[(long) 256*269+270];
static unsigned char pixel[256];
             
void init_resource(void)
{	
}

static int saved_pal[256][3];
static int current_pal[256][3];

void save_palette(void)
{	
}

void restore_palette(void)
{	
}

void set_current_pal(void)
{	
}

#define COLOURS_256_PACKED (0)
#define COLOURS_15BIT_PACKED (1)
#define COLOURS_16_PACKED_GREYSCALE (2)
#define COLOURS_MONO (3)
#define COLOURS_4_PACKED (4)
#define COLOURS_24BIT_PACKED (5)
#define COLOURS_32BIT_PACKED (6)
#define COLOURS_256_PACKED_GREYSCALE (7)


unsigned char table_4bit[256][256];
UINT16 table_15bit[16][16][256];
static UINT32 *table_24bit;
static UINT32 *table_32bit;
static INT32 *currt,*nextt;

void init_mode(int mode)
{       union REGS r;
	r.w.ax = mode;
	int386(0x10,&r,&r); 
}

static void display_image(dithered_image)
unsigned char *dithered_image;
{ register int * screen_ptr= 0xa0000+16;
  register int * image_ptr = dithered_image; 
  register int j;
  int height = vertical_size;
  int width = coded_picture_width >> 2;
  for (j=0;j<height;j++)
  { 	switch (width)
	{
		case 50:screen_ptr[49] = image_ptr[49];
		case 49:screen_ptr[48] = image_ptr[48];
		case 48:screen_ptr[47] = image_ptr[47];
		case 47:screen_ptr[46] = image_ptr[46];
		case 46:screen_ptr[45] = image_ptr[45];
		case 45:screen_ptr[44] = image_ptr[44];
		case 44:screen_ptr[43] = image_ptr[43];
		case 43:screen_ptr[42] = image_ptr[42];
		case 42:screen_ptr[41] = image_ptr[41];
		case 41:screen_ptr[40] = image_ptr[40];
		case 40:screen_ptr[39] = image_ptr[39];
		case 39:screen_ptr[38] = image_ptr[38];
		case 38:screen_ptr[37] = image_ptr[37];
		case 37:screen_ptr[36] = image_ptr[36];
		case 36:screen_ptr[35] = image_ptr[35];
		case 35:screen_ptr[34] = image_ptr[34];
		case 34:screen_ptr[33] = image_ptr[33];
		case 33:screen_ptr[32] = image_ptr[32];
		case 32:screen_ptr[31] = image_ptr[31];
		case 31:screen_ptr[30] = image_ptr[30];
		case 30:screen_ptr[29] = image_ptr[29];
		case 29:screen_ptr[28] = image_ptr[28];
		case 28:screen_ptr[27] = image_ptr[27];
		case 27:screen_ptr[26] = image_ptr[26];
		case 26:screen_ptr[25] = image_ptr[25];
		case 25:screen_ptr[24] = image_ptr[24];
		case 24:screen_ptr[23] = image_ptr[23];
		case 23:screen_ptr[22] = image_ptr[22];
		case 22:screen_ptr[21] = image_ptr[21];
		case 21:screen_ptr[20] = image_ptr[20];
		case 20:screen_ptr[19] = image_ptr[19];
		case 19:screen_ptr[18] = image_ptr[18];
		case 18:screen_ptr[17] = image_ptr[17];
		case 17:screen_ptr[16] = image_ptr[16];
		case 16:screen_ptr[15] = image_ptr[15];
		case 15:screen_ptr[14] = image_ptr[14];
		case 14:screen_ptr[13] = image_ptr[13];
		case 13:screen_ptr[12] = image_ptr[12];
		case 12:screen_ptr[11] = image_ptr[11];
		case 11:screen_ptr[10] = image_ptr[10];
		case 10:screen_ptr[9] = image_ptr[9];
		case 9:	screen_ptr[8] = image_ptr[8];
		case 8:	screen_ptr[7] = image_ptr[7];
		case 7:	screen_ptr[6] = image_ptr[6];
		case 6:	screen_ptr[5] = image_ptr[5];
		case 5:	screen_ptr[4] = image_ptr[4];
		case 4:	screen_ptr[3] = image_ptr[3];
		case 3:	screen_ptr[2] = image_ptr[2];
		case 2:	screen_ptr[1] = image_ptr[1];
		case 1:	screen_ptr[0] = image_ptr[0];
	}
 		   screen_ptr += (320>>2);
 		   image_ptr += width;
  }
}
extern void cdecl dither_16bit(unsigned char *,unsigned char *,unsigned char *,unsigned char *);

void init_display(void)
{	INT32 crv, cbu, cgu, cgv;
	INT32 x,y;
	crv = convmat[5][0];
	cbu = convmat[5][1];
	cgu = convmat[5][2];
	cgv = convmat[5][3];

        screen_type = COLOURS_256_PACKED;
/*
	switch (work_out[4])
	{	case 32:
			screen_type = COLOURS_32BIT_PACKED;
			break;
		case 24:
			screen_type = COLOURS_24BIT_PACKED;
			break;
		case 16:
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

*/
	switch (screen_type)
	{	

		case COLOURS_16_PACKED_GREYSCALE:
		{	INT32 i,j;
			save_palette();
  			init_mode(0x13); 
			  outp(0x3c8,32);
			for (i=0 ; i < 16; i++)
			{	current_pal[i][0] = (i * 1000) >> 4;
				current_pal[i][1] = (i * 1000) >> 4;
			    current_pal[i][2] = (i * 1000) >> 4;
				/*vs_color(gr_handle,(int) i,&current_pal[i][0]);*/
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
		case COLOURS_256_PACKED_GREYSCALE:
		{	int i;
  			init_mode(0x13); 
			outp(0x3c8,32);
			for (i=16; i<256; i++)
			{	INT32 y;
    				y = 76309 * (i - 16); /* (255/219)*65536 */
				y = clp[(y + 32768)>>16] >> 2;
    				outp(0x3c9,(unsigned char) y);
 			   	outp(0x3c9,(unsigned char) y);
			    	outp(0x3c9,(unsigned char) y);
    			}
		}
		case COLOURS_256_PACKED:
		{	INT32 i,j,v;
			 unsigned char ctab[256+32];
  			 init_mode(0x13); 
			 outp(0x3c8,32);
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
   				outp(0x3c9,(unsigned char) (r >> 2));
			    	outp(0x3c9,(unsigned char) (g >> 2));
   				outp(0x3c9,(unsigned char) (b >> 2));
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
		case COLOURS_MONO:
		case COLOURS_4_PACKED:
		{	
			save_palette();
			current_pal[0][0] = 0;
			current_pal[0][1] = 0;
			current_pal[0][2] = 0;
			current_pal[1][0] = 1000;
			current_pal[1][1] = 1000;
			current_pal[1][2] = 1000;
			/*vs_color(gr_handle,(int) 0,&current_pal[0][0]);
			vs_color(gr_handle,(int) 1,&current_pal[1][0]); */
			if (!(dithered_image = (unsigned char *)malloc((long) (coded_picture_width/8)*
                                                  coded_picture_height*2l)))
	   	  		error("\nNot enough memory!\n");
   			currt = (INT32 *)calloc(1,(long) sizeof(INT32) * (coded_picture_width + 2));
  			nextt = (INT32 *)calloc(1,(long) sizeof(INT32) * (coded_picture_width + 2));
			break;
		}
		case COLOURS_32BIT_PACKED:
		{	
			INT32 yc,uc,vc;
			UINT32 *t;
			t = table_32bit = malloc((long) 256*16*16 * sizeof(UINT32));
			
			for (uc = 0 ; uc < 256 ; uc +=16)
			{	for (vc = 0 ; vc < 256 ; vc +=16)
				{	for (yc = 0 ; yc < 256 ; yc ++)
					{	INT32 y, u, v,r, g, b;
		    			y = (yc-16) * 76309 ; /* (255/219)*65536 */
		    			u = uc-128;
		    			v = vc-128; 
					    r = clp[(y + crv*v + 32768)>>16];
    					g = clp[(y - cgu*u -cgv*v + 32768)>>16];
		    			b = clp[(y + cbu*u + 32786)>>16];
			    		*t++ = ( (r<<16) | ( g << 8) | b);
					}
				}
			}
			if (!(dithered_image = (unsigned char *)malloc((long) coded_picture_width*
                                                   coded_picture_height*4l)))
	   	  		error("\nNot enough memory!\n");

			break;
		}
		
		default:
		{	screen_type =-1;
		       /*
			form_alert(1,"[0][|  Unsupported Resolution!  |][ Quit! ]");*/

			exit_display();
			exit(1);
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
		{	free(dithered_image);
			restore_palette();	
			break;
		}
		case COLOURS_MONO:
		case COLOURS_4_PACKED:
		{	
			restore_palette();	
			free(dithered_image);
			free(nextt);
			free(currt);	
			break;
		}
		case COLOURS_15BIT_PACKED:
		{	free(dithered_image);
			break;
		}
		case COLOURS_24BIT_PACKED:
		{	
			free(dithered_image);
			free(table_24bit);
			break;
		}
		case COLOURS_32BIT_PACKED:
		{	free(dithered_image);
			free(table_32bit);
			break;
		}
	}
	init_mode(0x3);
}


void dither(src)
unsigned char *src[];
{	unsigned char *py = src[0],*pu = src[1],*pv = src[2];
	switch (screen_type)
	{	
		case COLOURS_16_PACKED_GREYSCALE:
		{	int i,j;
  			unsigned char *dst = dithered_image;
  			for (j=0; j<coded_picture_height; j+=1)
		  	{	
				for (i=0; i<coded_picture_width; i+=2)
			    {	unsigned char a = *py++;
			    	unsigned char b = *py++;
			    	unsigned char c = a & 0xf;
			    	unsigned char d = b & 0xf;
			    	unsigned char e = a >> 4;
			    	unsigned char f = b >> 4;
			    	/*if (c > 8)
			    	{	e++;
			    		if (e>15)
			    			e = 15;
			    	}
			    	if (d > 8)
			    	{	f++;
			    		if (f>15)
			    			f = 15;
			    	}*/
					*dst++ = (e<<4) | f;
			    }

	 		}
			break;
		
		}

		/* 4x4 ordered dither
		 *
		 * threshold pattern:
		 *   0  8  2 10
		 *  12  4 14  6
		 *   3 11  1  9
		 *  15  7 13  5
		 */
		
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

			    pu -= (coded_picture_width>>1); 
			    pv -= (coded_picture_width>>1); 

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

			    pu -= (coded_picture_width>>1); 
			    pv -= (coded_picture_width>>1); 

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
  
 			display_image(dithered_image);
			break;
		}
		case COLOURS_15BIT_PACKED:
		{	
			/*dither_16bit(pu,pv,py,dithered_image); 
		
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
			break;
		}
		case COLOURS_32BIT_PACKED:
		{/*	
			int i,j,uv;
  			UINT32 *dst = (UINT32 *) dithered_image;
  			for (j=0; j<coded_picture_height; j+=2)
		  	{
				for (i=0; i<coded_picture_width; i+=2)
			    {	UINT32 *t = table_32bit+ ((UINT32) ((*pu++ & 0xf0)|(*pv++ >> 4))<<8);
					*dst++ = t[(UINT32) *py++];
					*dst++ = t[(UINT32) *py++];
			    }

		      	pu -= chrom_width;
      			pv -= chrom_width;
				for (i=0; i<coded_picture_width; i+=2)
			    {	UINT32 *t = table_32bit+ ((UINT32) ((*pu++ & 0xf0)|(*pv++ >> 4))<<8);
					*dst++ = t[(UINT32) *py++];
					*dst++ = t[(UINT32) *py++];
			    }
	 		} 
			INT32 crv, cbu, cgu, cgv;
			crv = convmat[5][0];
			cbu = convmat[5][1];
			cgu = convmat[5][2];
			cgv = convmat[5][3];	 		
	 		for (j=0; j<coded_picture_height; j+=2)
		  	{
				for (i=0; i<coded_picture_width; i+=2)
			    {	INT32 y, u, v,r, g, b;	
			    	u = (*pu++)-128;
		    		v = (*pv++)-128;
		    		y = ((INT32) (*py++)-16) * 76309 ; 
					r = clp[(y + crv*v + 32768)>>16];
    				g = clp[(y - cgu*u -cgv*v + 32768)>>16];
		    		b = clp[(y + cbu*u + 32786)>>16];
			    	*dst++ = ( (r<<16) | ( g << 8) | b);
			    	y = ((INT32) (*py++)-16) * 76309 ; 
					r = clp[(y + crv*v + 32768)>>16];
    				g = clp[(y - cgu*u -cgv*v + 32768)>>16];
		    		b = clp[(y + cbu*u + 32786)>>16];
			    	*dst++ = ( (r<<16) | ( g << 8) | b);
			    	 
			    	 
			    }

		      	pu -= chrom_width;
      			pv -= chrom_width;
				for (i=0; i<coded_picture_width; i+=2)
			    {	INT32 y, u, v,r, g, b;	
			    	u = (*pu++)-128;
		    		v = (*pv++)-128;
		    		y = ((INT32)(*py++)-16) * 76309 ; 
					r = clp[(y + crv*v + 32768)>>16];
    				g = clp[(y - cgu*u -cgv*v + 32768)>>16];
		    		b = clp[(y + cbu*u + 32786)>>16];
			    	*dst++ = ( (r<<16) | ( g << 8) | b);
			    	y = ((INT32)(*py++)-16) * 76309 ; 
					r = clp[(y + crv*v + 32768)>>16];
    				g = clp[(y - cgu*u -cgv*v + 32768)>>16];
		    		b = clp[(y + cbu*u + 32786)>>16];
			    	*dst++ = ( (r<<16) | ( g << 8) | b);
			    }
	 		}
			*/
				 	
			break;
		}		
		case COLOURS_MONO:
		case COLOURS_4_PACKED:
		{	
#define MaxGrey         65280
#define Threshold       (MaxGrey/2)
#define MinGrey         0
#define SEED_BIT 0x80
#define OPP_SEED_BIT 0x01
#define SHIFT_SEED_BIT(b) (b >>= 1)
#define OPP_SHIFT_SEED_BIT(b) (b <<= 1)
			INT32     *curr = currt+1;
			INT32     *next = nextt+1;
  			unsigned char *dst = dithered_image;
  			UINT32 bit,data;
  			INT16 i,j;
  			INT32 *swap;
  			INT32 out_err,next1,next2;
 	
 			for(i = 0; i < coded_picture_height; i+=2)
 			{	bit = SEED_BIT;
			    data = 0;
      			out_err = curr[0];
      			next1 = 0;
      			next2 = 0;
      			for (j=0; j<coded_picture_width; j++)
      			{
					out_err = (out_err >> 4) + ((INT32) py[j] << 8);
					if(out_err > Threshold) {
	 					data |= bit;
					  	out_err -= MaxGrey;
					}/* else
	 					out_err -= MinGrey;*/
					next[j-1] = next1 +     (out_err+out_err+out_err);
					next1     = next2 +     ((out_err<<2)+out_err);
					next2     =             (out_err);
					out_err   = curr[j+1] + ((out_err<<3)-out_err);
					SHIFT_SEED_BIT(bit);
					if (!bit) {
						dst[j>>3] = data;
				  		bit = SEED_BIT;
						data = 0;
					}
      			}
     			next[coded_picture_width-1] = next1;
		   		py += coded_picture_width;
		   		dst += (coded_picture_width >> 3);
		   		swap = curr; curr = next;	next = swap;
		   	
      			bit = OPP_SEED_BIT;
      			data = 0;
      			out_err = curr[coded_picture_width-1];
      			next1 = 0;
				next2 = 0;
      			for (j=(coded_picture_width-1); j>=0; j--)
      			{
					out_err = (out_err >> 4) + ((INT32)py[j] << 8);
					if(out_err > Threshold) {
						data |= bit;
	  					out_err -= MaxGrey;
					}/* else
					  out_err -= MinGrey;*/
					  
					next[j+1] = next1 +     (out_err+out_err+out_err);
					next1     = next2 +     ((out_err<<2)+out_err);
					next2     =             (out_err);
					out_err   = curr[j-1] + ((out_err<<3)-out_err);

					OPP_SHIFT_SEED_BIT(bit);
					if(bit > 0x80) {
			 			dst[j >> 3] = data;
	  					bit = OPP_SEED_BIT;
	 					data = 0;
					}
     			}
  			    next[0] = next1;
		   		py += coded_picture_width;
		   		dst += (coded_picture_width >> 3);
		   		swap = curr; curr = next;	next = swap;
		   	
 			}	
 			
			break;
		}		
	}
}
