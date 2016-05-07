
#include "flicker.h"

/****
These rgb to hls routines work with rgbhls all in [0,255]
****/


static long
value(n1, n2, hue)
long n1, n2;
WORD hue;
{
	long val;

	while (hue >= 256)
		hue -= 256;

	while (hue < 0)
		hue += 256;

	if (hue < (256/6))
		val = n1 + (n2 - n1) * (long)hue / (256/6);
	else if (hue < 256/2)
		val = n2;
	else if (hue < 2*256/3)
		val = n1 + (long)(n2 - n1) * (2*256/3 - hue) / (256/6);
	else
		val = n1;

	val>>=8;
	if (val > 255) val = 255;
	if (val<0) val = 0;
	return(val);
}

/*routine copped from p618 of Foley and Van Dam Fundamentals of Interactive
  computer graphics.  Converted to integer math by Jim Kent.*/

rgb_to_hls(r,g,b,h,l,s)
WORD r,g,b,*h,*l,*s;
{
WORD max,min;
WORD rc,gc,bc;
WORD hv, lv, sv;

#ifdef DEBUG
lprintf("rgb_to_hls(%lx %lx %lx %lx %lx)\n",
	r,g,b,*h,*l,*s);
#endif DEBUG

/* shift the components from ST 0-7 to 0-255 */

r <<= 5;
g <<= 5;
b <<= 5;
max = r;
if (g>max) max = g;
if (b>max) max = b;
min = r;
if (g<min) min = g;
if (b<min) min = b;
lv = (max+min)>>1;

if (max == min)
	{
	hv = sv = 0;
	}
else
	{
	if (lv < 128)
		sv = ((long)(max-min)<<8)/(max+min);
	else
		sv = ((long)(max-min)<<8)/(512-max-min);
	
	if (sv >= 256)
		sv = 255;
	rc = uscale_by(256, max-r, max-min);
	gc = uscale_by(256, max-g, max-min);
	bc = uscale_by(256, max-b, max-min);

	if (r == max)
		hv = bc - gc;
	else if (g == max)
		hv = 2*256 + rc - bc;
	else
		hv = 4*256 + gc - rc;
	
	hv /= 6;
	while (hv < 0) hv += 256;
	while (hv >= 256) hv -= 256;
	}
*h = hv;
*l = lv;
*s = sv;
}

hls_to_rgb(r, g, b, h, l, s)
WORD *r, *g, *b;
WORD	h, l, s;
{
long	m1, m2;
WORD rv, gv, bv;

#ifdef DEBUG
lprintf("rgb_to_hls(%lx %lx %lx %lx %lx)\n",
	*r,*g,*b,h,l,s);
#endif DEBUG

if (l <= 128)
	m2 = (long)l * (256 + s);
else
	m2 = ((long)(l + s)<<8) - (long)l * s;

m1 = 512 *(long)l - m2;

if (s == 0)
	{
	rv = l;
	gv = l;
	bv = l;
	}
else
	{
	s = value(m1, m2, h - 256/3);
	l = value(m1, m2, h);
	h = value(m1, m2, h + 256/3);
	bv = s;
	gv = l;
	rv = h;
	}
/* scale down to ST values */
rv += 16;
bv += 16;
gv += 16;
if (rv > 255)
	rv = 255;
if (gv > 255)
	gv = 255;
if (bv > 255)
	bv = 255;
*r = rv>>5;
*g = gv>>5;
*b = bv>>5;
}


