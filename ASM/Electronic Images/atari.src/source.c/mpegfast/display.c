#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include "config.h"
#include "global.h"

/* private prototypes */
static void display_image _ANSI_ARGS_((unsigned char *dithered_image));
static void ditherframe _ANSI_ARGS_((unsigned char *src[]));
static void dithertop _ANSI_ARGS_((unsigned char *src[], unsigned char *dst));
static void ditherbot _ANSI_ARGS_((unsigned char *src[], unsigned char *dst));
static void ditherframe444 _ANSI_ARGS_((unsigned char *src[]));
static void dithertop444 _ANSI_ARGS_((unsigned char *src[], unsigned char *dst));
static void ditherbot444 _ANSI_ARGS_((unsigned char *src[], unsigned char *dst));

/* local data */
static unsigned char *dithered_image, *dithered_image2;

static unsigned char ytab[16*(256+16)];
static unsigned char uvtab[256*269+270];

static unsigned char pixel[256];

void init_mode(int mode)
{       union REGS r;
	r.w.ax = mode;
	int386(0x10,&r,&r); 
}

void init_display()
{
  int crv, cbu, cgu, cgv;
  int y, u, v, r, g, b;
  int i;
  /* matrix coefficients */
  crv = convmat[matrix_coefficients][0];
  cbu = convmat[matrix_coefficients][1];
  cgu = convmat[matrix_coefficients][2];
  cgv = convmat[matrix_coefficients][3];
    
  /* color allocation:
   * i is the (internal) 8 bit color number, it consists of separate
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
  
  /*init_mode(0x13); */

  outp(0x3c8,0);
  for (i=32; i<240; i++)
  {
    /* color space conversion */
    y = 16*((i>>4)&15) + 8;
    u = 32*((i>>2)&3)  - 48;
    v = 32*(i&3)       - 48;

    y = 76309 * (y - 16); /* (255/219)*65536 */

    r = clp[(y + crv*v + 32768)>>16];
    g = clp[(y - cgu*u -cgv*v + 32768)>>16];
    b = clp[(y + cbu*u + 32786)>>16];
    outp(0x3c9,(unsigned char) (r >> 2));
    outp(0x3c9,(unsigned char) (b >> 2));
    outp(0x3c9,(unsigned char) (g >> 2));
    pixel[i] = i;
  }

    if (!(dithered_image = (unsigned char *)malloc(coded_picture_width*
						   coded_picture_height)))
      error("malloc failed");

    if (!prog_seq)
    {
      if (!(dithered_image2 = (unsigned char *)malloc(coded_picture_width*
						      coded_picture_height)))
	error("malloc failed");
    }
}

void exit_display()
{   init_mode(0x03);
}

static void display_image(dithered_image)
unsigned char *dithered_image;
{ register int * screen_ptr= 0xa0000;
  register int * image_ptr = dithered_image; 
  register int i,j;
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
  puts("frame");
}

void display_second_field()
{
  display_image(dithered_image2);
}

/* 4x4 ordered dither
 *
 * threshold pattern:
 *   0  8  2 10
 *  12  4 14  6
 *   3 11  1  9
 *  15  7 13  5
 */

void init_dither()
{
  int i, j, v;
  unsigned char ctab[256+32];

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
}

void dither(src)
unsigned char *src[];
{ return;
  if (prog_seq)
  {
    if (chroma_format!=CHROMA444)
      ditherframe(src);
    else
      ditherframe444(src);
  }
  else
  {
    if ((pict_struct==FRAME_PICTURE && topfirst) || pict_struct==BOTTOM_FIELD)
    {
      /* top field first */
      if (chroma_format!=CHROMA444)
      {
	dithertop(src,dithered_image);
	ditherbot(src,dithered_image2);
      }
      else
      {
	dithertop444(src,dithered_image);
	ditherbot444(src,dithered_image2);
      }
    }
    else
    {
      /* bottom field first */
      if (chroma_format!=CHROMA444)
      {
	ditherbot(src,dithered_image);
	dithertop(src,dithered_image2);
      }
      else
      {
	ditherbot444(src,dithered_image);
	dithertop444(src,dithered_image2);
      }
    }
  }

  display_image(dithered_image);
}

/* only for 4:2:0 and 4:2:2! */

static void ditherframe(src)
unsigned char *src[];
{
  int i,j;
  unsigned int uv;
  unsigned char *py,*pu,*pv,*dst;

  py = src[0];
  pu = src[1];
  pv = src[2];
  dst = dithered_image;

  for (j=0; j<coded_picture_height; j+=4)
  {
    /* line j + 0 */
    for (i=0; i<coded_picture_width; i+=8)
    {
      uv = uvtab[(*pu++<<8)|*pv++];
      *dst++ = ytab[((*py++)<<4)|(uv&15)];
      *dst++ = ytab[((*py++ +8)<<4)|(uv>>4)];
      uv = uvtab[((*pu++<<8)|*pv++)+1028];
      *dst++ = ytab[((*py++ +2)<<4)|(uv&15)];
      *dst++ = ytab[((*py++ +10)<<4)|(uv>>4)];
      uv = uvtab[(*pu++<<8)|*pv++];
      *dst++ = ytab[((*py++)<<4)|(uv&15)];
      *dst++ = ytab[((*py++ +8)<<4)|(uv>>4)];
      uv = uvtab[((*pu++<<8)|*pv++)+1028];
      *dst++ = ytab[((*py++ +2)<<4)|(uv&15)];
      *dst++ = ytab[((*py++ +10)<<4)|(uv>>4)];
    }

    if (chroma_format==CHROMA420)
    {
      pu -= chrom_width;
      pv -= chrom_width;
    }

    /* line j + 1 */
    for (i=0; i<coded_picture_width; i+=8)
    {
      uv = uvtab[((*pu++<<8)|*pv++)+2056];
      *dst++ = ytab[((*py++ +12)<<4)|(uv>>4)];
      *dst++ = ytab[((*py++ +4)<<4)|(uv&15)];
      uv = uvtab[((*pu++<<8)|*pv++)+3084];
      *dst++ = ytab[((*py++ +14)<<4)|(uv>>4)];
      *dst++ = ytab[((*py++ +6)<<4)|(uv&15)];
      uv = uvtab[((*pu++<<8)|*pv++)+2056];
      *dst++ = ytab[((*py++ +12)<<4)|(uv>>4)];
      *dst++ = ytab[((*py++ +4)<<4)|(uv&15)];
      uv = uvtab[((*pu++<<8)|*pv++)+3084];
      *dst++ = ytab[((*py++ +14)<<4)|(uv>>4)];
      *dst++ = ytab[((*py++ +6)<<4)|(uv&15)];
    }

    /* line j + 2 */
    for (i=0; i<coded_picture_width; i+=8)
    {
      uv = uvtab[((*pu++<<8)|*pv++)+1542];
      *dst++ = ytab[((*py++ +3)<<4)|(uv&15)];
      *dst++ = ytab[((*py++ +11)<<4)|(uv>>4)];
      uv = uvtab[((*pu++<<8)|*pv++)+514];
      *dst++ = ytab[((*py++ +1)<<4)|(uv&15)];
      *dst++ = ytab[((*py++ +9)<<4)|(uv>>4)];
      uv = uvtab[((*pu++<<8)|*pv++)+1542];
      *dst++ = ytab[((*py++ +3)<<4)|(uv&15)];
      *dst++ = ytab[((*py++ +11)<<4)|(uv>>4)];
      uv = uvtab[((*pu++<<8)|*pv++)+514];
      *dst++ = ytab[((*py++ +1)<<4)|(uv&15)];
      *dst++ = ytab[((*py++ +9)<<4)|(uv>>4)];
    }

    if (chroma_format==CHROMA420)
    {
      pu -= chrom_width;
      pv -= chrom_width;
    }

    /* line j + 3 */
    for (i=0; i<coded_picture_width; i+=8)
    {
      uv = uvtab[((*pu++<<8)|*pv++)+3598];
      *dst++ = ytab[((*py++ +15)<<4)|(uv>>4)];
      *dst++ = ytab[((*py++ +7)<<4)|(uv&15)];
      uv = uvtab[((*pu++<<8)|*pv++)+2570];
      *dst++ = ytab[((*py++ +13)<<4)|(uv>>4)];
      *dst++ = ytab[((*py++ +5)<<4)|(uv&15)];
      uv = uvtab[((*pu++<<8)|*pv++)+3598];
      *dst++ = ytab[((*py++ +15)<<4)|(uv>>4)];
      *dst++ = ytab[((*py++ +7)<<4)|(uv&15)];
      uv = uvtab[((*pu++<<8)|*pv++)+2570];
      *dst++ = ytab[((*py++ +13)<<4)|(uv>>4)];
      *dst++ = ytab[((*py++ +5)<<4)|(uv&15)];
    }
  }
}

static void dithertop(src,dst)
unsigned char *src[];
unsigned char *dst;
{
  int i,j;
  unsigned int y,uv1,uv2;
  unsigned char *py,*py2,*pu,*pv,*dst2;

  py = src[0];
  py2 = src[0] + (coded_picture_width<<1);
  pu = src[1];
  pv = src[2];
  dst2 = dst + coded_picture_width;

  for (j=0; j<coded_picture_height; j+=4)
  {
    /* line j + 0, j + 1 */
    for (i=0; i<coded_picture_width; i+=4)
    {
      y = *py++;
      uv2 = (*pu++<<8)|*pv++;
      uv1 = uvtab[uv2];
      uv2 = uvtab[uv2+2056];
      *dst++  = ytab[((y)<<4)|(uv1&15)];
      *dst2++ = ytab[((((y + *py2++)>>1)+12)<<4)|(uv2>>4)];

      y = *py++;
      *dst++  = ytab[((y+8)<<4)|(uv1>>4)];
      *dst2++ = ytab[((((y + *py2++)>>1)+4)<<4)|(uv2&15)];

      y = *py++;
      uv2 = (*pu++<<8)|*pv++;
      uv1 = uvtab[uv2+1028];
      uv2 = uvtab[uv2+3072];
      *dst++  = ytab[((y+2)<<4)|(uv1&15)];
      *dst2++ = ytab[((((y + *py2++)>>1)+14)<<4)|(uv2>>4)];

      y = *py++;
      *dst++  = ytab[((y+10)<<4)|(uv1>>4)];
      *dst2++ = ytab[((((y + *py2++)>>1)+6)<<4)|(uv2&15)];
    }

    py += coded_picture_width;

    if (j!=(coded_picture_height-4))
      py2 += coded_picture_width;
    else
      py2 -= coded_picture_width;

    dst += coded_picture_width;
    dst2 += coded_picture_width;

    if (chroma_format==CHROMA420)
    {
      pu -= chrom_width;
      pv -= chrom_width;
    }
    else
    {
      pu += chrom_width;
      pv += chrom_width;
    }

    /* line j + 2, j + 3 */
    for (i=0; i<coded_picture_width; i+=4)
    {
      y = *py++;
      uv2 = (*pu++<<8)|*pv++;
      uv1 = uvtab[uv2+1542];
      uv2 = uvtab[uv2+3598];
      *dst++  = ytab[((y+3)<<4)|(uv1&15)];
      *dst2++ = ytab[((((y + *py2++)>>1)+15)<<4)|(uv2>>4)];

      y = *py++;
      *dst++  = ytab[((y+11)<<4)|(uv1>>4)];
      *dst2++ = ytab[((((y + *py2++)>>1)+7)<<4)|(uv2&15)];

      y = *py++;
      uv2 = (*pu++<<8)|*pv++;
      uv1 = uvtab[uv2+514];
      uv2 = uvtab[uv2+2570];
      *dst++  = ytab[((y+1)<<4)|(uv1&15)];
      *dst2++ = ytab[((((y + *py2++)>>1)+13)<<4)|(uv2>>4)];

      y = *py++;
      *dst++  = ytab[((y+9)<<4)|(uv1>>4)];
      *dst2++ = ytab[((((y + *py2++)>>1)+5)<<4)|(uv2&15)];
    }

    py += coded_picture_width;
    py2 += coded_picture_width;
    dst += coded_picture_width;
    dst2 += coded_picture_width;
    pu += chrom_width;
    pv += chrom_width;
  }
}

static void ditherbot(src,dst)
unsigned char *src[];
unsigned char *dst;
{
  int i,j;
  unsigned int y2,uv1,uv2;
  unsigned char *py,*py2,*pu,*pv,*dst2;

  py = src[0] + coded_picture_width;
  py2 = py;
  pu = src[1] + chrom_width;
  pv = src[2] + chrom_width;
  dst2 = dst + coded_picture_width;

  for (j=0; j<coded_picture_height; j+=4)
  {
    /* line j + 0, j + 1 */
    for (i=0; i<coded_picture_width; i+=4)
    {
      y2 = *py2++;
      uv2 = (*pu++<<8)|*pv++;
      uv1 = uvtab[uv2];
      uv2 = uvtab[uv2+2056];
      *dst++  = ytab[((((*py++ + y2)>>1))<<4)|(uv1&15)];
      *dst2++ = ytab[((y2+12)<<4)|(uv2>>4)];

      y2 = *py2++;
      *dst++  = ytab[((((*py++ + y2)>>1)+8)<<4)|(uv1>>4)];
      *dst2++ = ytab[((y2+4)<<4)|(uv2&15)];

      y2 = *py2++;
      uv2 = (*pu++<<8)|*pv++;
      uv1 = uvtab[uv2+1028];
      uv2 = uvtab[uv2+3072];
      *dst++  = ytab[((((*py++ + y2)>>1)+2)<<4)|(uv1&15)];
      *dst2++ = ytab[((y2+14)<<4)|(uv2>>4)];

      y2 = *py2++;
      *dst++  = ytab[((((*py++ + y2)>>1)+10)<<4)|(uv1>>4)];
      *dst2++ = ytab[((y2+6)<<4)|(uv2&15)];
    }

    if (j==0)
      py -= coded_picture_width;
    else
      py += coded_picture_width;

    py2 += coded_picture_width;
    dst += coded_picture_width;
    dst2 += coded_picture_width;

    if (chroma_format==CHROMA420)
    {
      pu -= chrom_width;
      pv -= chrom_width;
    }
    else
    {
      pu += chrom_width;
      pv += chrom_width;
    }

    /* line j + 2, j + 3 */
    for (i=0; i<coded_picture_width; i+=4)
    {
      y2 = *py2++;
      uv2 = (*pu++<<8)|*pv++;
      uv1 = uvtab[uv2+1542];
      uv2 = uvtab[uv2+3598];
      *dst++  = ytab[((((*py++ + y2)>>1)+3)<<4)|(uv1&15)];
      *dst2++ = ytab[((y2+15)<<4)|(uv2>>4)];

      y2 = *py2++;
      *dst++  = ytab[((((*py++ + y2)>>1)+11)<<4)|(uv1>>4)];
      *dst2++ = ytab[((y2+7)<<4)|(uv2&15)];

      y2 = *py2++;
      uv2 = (*pu++<<8)|*pv++;
      uv1 = uvtab[uv2+514];
      uv2 = uvtab[uv2+2570];
      *dst++  = ytab[((((*py++ + y2)>>1)+1)<<4)|(uv1&15)];
      *dst2++ = ytab[((y2+13)<<4)|(uv2>>4)];

      y2 = *py2++;
      *dst++  = ytab[((((*py++ + y2)>>1)+9)<<4)|(uv1>>4)];
      *dst2++ = ytab[((y2+5)<<4)|(uv2&15)];
    }

    py += coded_picture_width;
    py2 += coded_picture_width;
    dst += coded_picture_width;
    dst2 += coded_picture_width;
    pu += chrom_width;
    pv += chrom_width;
  }
}

/* only for 4:4:4 */

static void ditherframe444(src)
unsigned char *src[];
{
  int i,j;
  unsigned char *py,*pu,*pv,*dst;

  py = src[0];
  pu = src[1];
  pv = src[2];
  dst = dithered_image;

  for (j=0; j<coded_picture_height; j+=4)
  {
    /* line j + 0 */
    for (i=0; i<coded_picture_width; i+=8)
    {
      *dst++ = ytab[((*py++)<<4)|(uvtab[(*pu++<<8)|*pv++]&15)];
      *dst++ = ytab[((*py++ +8)<<4)|(uvtab[(*pu++<<8)|*pv++]>>4)];
      *dst++ = ytab[((*py++ +2)<<4)|(uvtab[((*pu++<<8)|*pv++)+1028]&15)];
      *dst++ = ytab[((*py++ +10)<<4)|(uvtab[((*pu++<<8)|*pv++)+1028]>>4)];
      *dst++ = ytab[((*py++)<<4)|(uvtab[(*pu++<<8)|*pv++]&15)];
      *dst++ = ytab[((*py++ +8)<<4)|(uvtab[(*pu++<<8)|*pv++]>>4)];
      *dst++ = ytab[((*py++ +2)<<4)|(uvtab[((*pu++<<8)|*pv++)+1028]&15)];
      *dst++ = ytab[((*py++ +10)<<4)|(uvtab[((*pu++<<8)|*pv++)+1028]>>4)];
    }

    /* line j + 1 */
    for (i=0; i<coded_picture_width; i+=8)
    {
      *dst++ = ytab[((*py++ +12)<<4)|(uvtab[((*pu++<<8)|*pv++)+2056]>>4)];
      *dst++ = ytab[((*py++ +4)<<4)|(uvtab[((*pu++<<8)|*pv++)+2056]&15)];
      *dst++ = ytab[((*py++ +14)<<4)|(uvtab[((*pu++<<8)|*pv++)+3084]>>4)];
      *dst++ = ytab[((*py++ +6)<<4)|(uvtab[((*pu++<<8)|*pv++)+3084]&15)];
      *dst++ = ytab[((*py++ +12)<<4)|(uvtab[((*pu++<<8)|*pv++)+2056]>>4)];
      *dst++ = ytab[((*py++ +4)<<4)|(uvtab[((*pu++<<8)|*pv++)+2056]&15)];
      *dst++ = ytab[((*py++ +14)<<4)|(uvtab[((*pu++<<8)|*pv++)+3084]>>4)];
      *dst++ = ytab[((*py++ +6)<<4)|(uvtab[((*pu++<<8)|*pv++)+3084]&15)];
    }

    /* line j + 2 */
    for (i=0; i<coded_picture_width; i+=8)
    {
      *dst++ = ytab[((*py++ +3)<<4)|(uvtab[((*pu++<<8)|*pv++)+1542]&15)];
      *dst++ = ytab[((*py++ +11)<<4)|(uvtab[((*pu++<<8)|*pv++)+1542]>>4)];
      *dst++ = ytab[((*py++ +1)<<4)|(uvtab[((*pu++<<8)|*pv++)+514]&15)];
      *dst++ = ytab[((*py++ +9)<<4)|(uvtab[((*pu++<<8)|*pv++)+514]>>4)];
      *dst++ = ytab[((*py++ +3)<<4)|(uvtab[((*pu++<<8)|*pv++)+1542]&15)];
      *dst++ = ytab[((*py++ +11)<<4)|(uvtab[((*pu++<<8)|*pv++)+1542]>>4)];
      *dst++ = ytab[((*py++ +1)<<4)|(uvtab[((*pu++<<8)|*pv++)+514]&15)];
      *dst++ = ytab[((*py++ +9)<<4)|(uvtab[((*pu++<<8)|*pv++)+514]>>4)];
    }

    /* line j + 3 */
    for (i=0; i<coded_picture_width; i+=8)
    {
      *dst++ = ytab[((*py++ +15)<<4)|(uvtab[((*pu++<<8)|*pv++)+3598]>>4)];
      *dst++ = ytab[((*py++ +7)<<4)|(uvtab[((*pu++<<8)|*pv++)+3598]&15)];
      *dst++ = ytab[((*py++ +13)<<4)|(uvtab[((*pu++<<8)|*pv++)+2570]>>4)];
      *dst++ = ytab[((*py++ +5)<<4)|(uvtab[((*pu++<<8)|*pv++)+2570]&15)];
      *dst++ = ytab[((*py++ +15)<<4)|(uvtab[((*pu++<<8)|*pv++)+3598]>>4)];
      *dst++ = ytab[((*py++ +7)<<4)|(uvtab[((*pu++<<8)|*pv++)+3598]&15)];
      *dst++ = ytab[((*py++ +13)<<4)|(uvtab[((*pu++<<8)|*pv++)+2570]>>4)];
      *dst++ = ytab[((*py++ +5)<<4)|(uvtab[((*pu++<<8)|*pv++)+2570]&15)];
    }
  }
}

static void dithertop444(src,dst)
unsigned char *src[];
unsigned char *dst;
{
  int i,j;
  unsigned int y,uv;
  unsigned char *py,*py2,*pu,*pv,*dst2;

  py = src[0];
  py2 = src[0] + (coded_picture_width<<1);
  pu = src[1];
  pv = src[2];
  dst2 = dst + coded_picture_width;

  for (j=0; j<coded_picture_height; j+=4)
  {
    /* line j + 0, j + 1 */
    for (i=0; i<coded_picture_width; i+=4)
    {
      y = *py++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((y)<<4)|(uvtab[uv]&15)];
      *dst2++ = ytab[((((y + *py2++)>>1)+12)<<4)|(uvtab[uv+2056]>>4)];

      y = *py++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((y+8)<<4)|(uvtab[uv]>>4)];
      *dst2++ = ytab[((((y + *py2++)>>1)+4)<<4)|(uvtab[uv+2056]&15)];

      y = *py++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((y+2)<<4)|(uvtab[uv+1028]&15)];
      *dst2++ = ytab[((((y + *py2++)>>1)+14)<<4)|(uvtab[uv+3072]>>4)];

      y = *py++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((y+10)<<4)|(uvtab[uv+1028]>>4)];
      *dst2++ = ytab[((((y + *py2++)>>1)+6)<<4)|(uvtab[uv+3072]&15)];
    }

    py += coded_picture_width;

    if (j!=(coded_picture_height-4))
      py2 += coded_picture_width;
    else
      py2 -= coded_picture_width;

    dst += coded_picture_width;
    dst2 += coded_picture_width;

    pu += chrom_width;
    pv += chrom_width;

    /* line j + 2, j + 3 */
    for (i=0; i<coded_picture_width; i+=4)
    {
      y = *py++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((y+3)<<4)|(uvtab[uv+1542]&15)];
      *dst2++ = ytab[((((y + *py2++)>>1)+15)<<4)|(uvtab[uv+3598]>>4)];

      y = *py++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((y+11)<<4)|(uvtab[uv+1542]>>4)];
      *dst2++ = ytab[((((y + *py2++)>>1)+7)<<4)|(uvtab[uv+3598]&15)];

      y = *py++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((y+1)<<4)|(uvtab[uv+514]&15)];
      *dst2++ = ytab[((((y + *py2++)>>1)+13)<<4)|(uvtab[uv+2570]>>4)];

      y = *py++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((y+9)<<4)|(uvtab[uv+514]>>4)];
      *dst2++ = ytab[((((y + *py2++)>>1)+5)<<4)|(uvtab[uv+2570]&15)];
    }

    py += coded_picture_width;
    py2 += coded_picture_width;
    dst += coded_picture_width;
    dst2 += coded_picture_width;
    pu += chrom_width;
    pv += chrom_width;
  }
}

static void ditherbot444(src,dst)
unsigned char *src[];
unsigned char *dst;
{
  int i,j;
  unsigned int y2,uv;
  unsigned char *py,*py2,*pu,*pv,*dst2;

  py = src[0] + coded_picture_width;
  py2 = py;
  pu = src[1] + chrom_width;
  pv = src[2] + chrom_width;
  dst2 = dst + coded_picture_width;

  for (j=0; j<coded_picture_height; j+=4)
  {
    /* line j + 0, j + 1 */
    for (i=0; i<coded_picture_width; i+=4)
    {
      y2 = *py2++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((((*py++ + y2)>>1))<<4)|(uvtab[uv]&15)];
      *dst2++ = ytab[((y2+12)<<4)|(uvtab[uv+2056]>>4)];

      y2 = *py2++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((((*py++ + y2)>>1)+8)<<4)|(uvtab[uv]>>4)];
      *dst2++ = ytab[((y2+4)<<4)|(uvtab[uv+2056]&15)];

      y2 = *py2++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((((*py++ + y2)>>1)+2)<<4)|(uvtab[uv+1028]&15)];
      *dst2++ = ytab[((y2+14)<<4)|(uvtab[uv+3072]>>4)];

      y2 = *py2++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((((*py++ + y2)>>1)+10)<<4)|(uvtab[uv+1028]>>4)];
      *dst2++ = ytab[((y2+6)<<4)|(uvtab[uv+3072]&15)];
    }

    if (j==0)
      py -= coded_picture_width;
    else
      py += coded_picture_width;

    py2 += coded_picture_width;
    dst += coded_picture_width;
    dst2 += coded_picture_width;

    pu += chrom_width;
    pv += chrom_width;

    /* line j + 2, j + 3 */
    for (i=0; i<coded_picture_width; i+=4)
    {
      y2 = *py2++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((((*py++ + y2)>>1)+3)<<4)|(uvtab[uv+1542]&15)];
      *dst2++ = ytab[((y2+15)<<4)|(uvtab[uv+3598]>>4)];

      y2 = *py2++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((((*py++ + y2)>>1)+11)<<4)|(uvtab[uv+1542]>>4)];
      *dst2++ = ytab[((y2+7)<<4)|(uvtab[uv+3598]&15)];

      y2 = *py2++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((((*py++ + y2)>>1)+1)<<4)|(uvtab[uv+514]&15)];
      *dst2++ = ytab[((y2+13)<<4)|(uvtab[uv+2570]>>4)];

      y2 = *py2++;
      uv = (*pu++<<8)|*pv++;
      *dst++  = ytab[((((*py++ + y2)>>1)+9)<<4)|(uvtab[uv+514]>>4)];
      *dst2++ = ytab[((y2+5)<<4)|(uvtab[uv+2570]&15)];
    }

    py += coded_picture_width;
    py2 += coded_picture_width;
    dst += coded_picture_width;
    dst2 += coded_picture_width;
    pu += chrom_width;
    pv += chrom_width;
  }
}

