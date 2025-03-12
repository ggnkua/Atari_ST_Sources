#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include "global.h"

/*#define DEBUG*/

#define	VERTFLAG	0x100	/* double-line on VGA, interlace on ST/TV */
#define	STMODES		0x080	/* ST compatible */
#define	OVERSCAN	0x040	/* Multiply X&Y rez by 1.2, ignored on VGA */
#define	PAL		0x020	/* PAL if set, else NTSC */
#define	VGA		0x010	/* VGA if set, else TV mode */
#define	COL80		0x008	/* 80 column if set, else 40 column */
#define	NUMCOLS		7	/* Mask for number of bits per pixel */
#define	BPS16		4
#define	BPS8		3
#define	BPS4		2
#define	BPS2		1
#define	BPS1		0
enum montypes {STmono=0, STcolor, VGAcolor, TVcolor};


short ScreenWidth;
short ScreenHeight;
short vid_mode;
short old_vid_mode;
static void *old_phy_base;
static void *old_log_base;
static void *Phy_base;
unsigned char *SCREEN;
extern void SETVGA(void *);
static unsigned char *dithered_image;
#define SCREENSIZE ( (256 + ( (long) 320*240*2)))

static unsigned short ytab[16][16][256];

unsigned char *clp;

/* 4x4 ordered dither
 *
 * threshold pattern:
 *   0  8  2 10
 *  12  4 14  6
 *   3 11  1  9
 *  15  7 13  5
 */

void init_dither()
{	long y,u,v,i;
	long crv = 104597l;
	long cbu = 132201l;
	long cgu = 25675l;
	long cgv = 53279l;
	clp=malloc(1024);
	clp+=384;
	for (i=-384; i<640; i++)
		clp[i] = (i<0) ? 0 : ((i>255) ? 255 : i);

	for (u = 0 ; u < 16  ; u++)
	{	for (v = 0 ; v < 16  ; v++)
		{	for (y = 0 ; y < 256 ; y++)
			{	unsigned int r,g,b;
				long y1 = 76309 * (y - 16); 
	    			long u1 = (u*16)-128;
	    			long v1 = (v*16)-128;
				r = clp[(y1 + crv*v1 + 32768)>>16];
				g = clp[(y1 - cgu*u1 -cgv*v1 + 32768)>>16];
				b = clp[(y1 + cbu*u1 + 32768)>>16];
				ytab[u][v][y] = ((r & 0xf8) << 8) | ((g & 0xf8) << 3) | ((b & 0xf8) >> 3);
			}
		}
	}


}

void init_display(void)
{	old_phy_base = ( void *) Physbase();
	old_log_base = ( void *) Logbase();
	old_vid_mode = Vsetmode(-1) & 0x1ff;
	init_dither();
	dithered_image = calloc(1,SCREENSIZE);
	SCREEN = calloc(1,SCREENSIZE);
	Phy_base = (void *) ( (long) (SCREEN+256)  & 0xffffff00);
	switch (Montype())
	{	case STmono:
			exit (2);
		case VGAcolor:
			ScreenWidth  = 320;
			ScreenHeight = 240;
#ifndef DEBUG
			SETVGA(Phy_base);
#endif
			break;
		
		case TVcolor:
		case STcolor:
			ScreenWidth  = 320;
			ScreenHeight = 200;
			Vsync();
			Setscreen(Phy_base,Phy_base,-1);
			Vsetmode(PAL|BPS16);
			break;
		
	}
}

void exit_display()
{
	Vsync();
	Setscreen(old_log_base,old_phy_base,-1);
#ifndef DEBUG
	Vsetmode(old_vid_mode);
#endif
}
void display_image(unsigned char *image)
{ 	short height = vertical_size;
 	short width  = coded_picture_width;
	short add_width = ScreenWidth - width;
	long screen  =  (long) ((short *) Phy_base + (add_width >> 1) 
	          	       		+ (((ScreenHeight - height) >> 1) * 320));

	while ( ((* (unsigned char *) 0xffff8a3cl) & 0x80) !=0);
	*((short *)0xffff8a20l) = (short) 2;		/* source inc X */
	*((short *)0xffff8a22l) = (short) 2;		/* source inc y */
	*((long  *)0xffff8a24l) = image;	/* source address */
	*((short *)0xffff8a2el) = (short) 2;		/* dest inc X */
	*((short *)0xffff8a30l) = (short) (add_width+1)*2;	/* dest inc y */
	*((long  *)0xffff8a32l) = screen;			/* dest address */
	*((short *)0xffff8a36l) = (short) width;	/* X count */
	*((short *)0xffff8a38l) = (short) height;	/* Y count */
	*((short *)0xffff8a3al) = (short) 0x0203;	/* HOP/OP  */
	*((char  *)0xffff8a3dl) = (unsigned char) 0;	/* skew */
	*((char  *)0xffff8a3cl) = (unsigned char) 0x80;	/* line_num */
}

extern cdecl ASMDITH(unsigned char *, unsigned char *, unsigned char *, int, int); 

void ditherframe()
{
  int i,j;
  unsigned char *py1,*py2,*pu;
  unsigned short *dst1,*dst2;
  pu = chromframe;
  py1 = lumframe;
  py2 = lumframe+coded_picture_width;
  dst1 = (unsigned short *) dithered_image;
  dst2 = (unsigned short *) dithered_image+coded_picture_width;

  for (j=0; j<coded_picture_height; j+=2)
  {
    for (i=0; i<coded_picture_width; i+=2)
    { unsigned short *t = &(ytab[(*pu++) >> 4][(*pu++) >> 4][0]);
      *dst1++ = t[*py1++];
      *dst1++ = t[*py1++];
      *dst2++ = t[*py2++];
      *dst2++ = t[*py2++];
    }
    py1 += (coded_picture_width);
    py2 += (coded_picture_width);
    dst1+= (coded_picture_width);
    dst2+= (coded_picture_width);
  }
}

void dither(void)
{
  /*ASMDITH(lumframe,chromframe,dithered_image, coded_picture_width, coded_picture_height);*/
  ditherframe();
  display_image(dithered_image);
}
