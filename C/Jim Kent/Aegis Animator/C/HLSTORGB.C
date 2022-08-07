
overlay "find"

#include "..\\include\\lists.h"

/****
These rgb to hls routines work with rgbhls all in [0,255]
****/


static long
value(n1, n2, hue)
long n1, n2;
int hue;
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
int r,g,b,*h,*l,*s;
{
int max,min;
int rc,gc,bc;

#ifdef DEBUG
lprintf("rgb_to_hls(%lx %lx %lx %lx %lx)\n",
	r,g,b,*h,*l,*s);
#endif DEBUG

max = r;
if (g>max) max = g;
if (b>max) max = b;
min = r;
if (g<min) min = g;
if (b<min) min = b;
*l = (max+min)>>1;

if (max == min)
	{
	*h = *s = 0;
	}
else
	{
	if (*l < 128)
		*s = ((long)(max-min)<<8)/(max+min);
	else
		*s = ((long)(max-min)<<8)/(512-max-min);
	
	rc = uscale_by(256, max-r, max-min);
	gc = uscale_by(256, max-g, max-min);
	bc = uscale_by(256, max-b, max-min);

	if (r == max)
		*h = bc - gc;
	else if (g == max)
		*h = 2*256 + rc - bc;
	else
		*h = 4*256 + gc - rc;
	
	*h /= 6;
	while (*h < 0) *h += 256;
	while (*h >= 256) *h -= 256;
	}
}

hls_to_rgb(r, g, b, h, l, s)
int *r, *g, *b;
int	h, l, s;
{
	long	m1, m2;

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
		*r = l;
		*g = l;
		*b = l;
		}
	else
		{
		*r = value(m1, m2, h + 256/3);
		*g = value(m1, m2, h);
		*b = value(m1, m2, h - 256/3);
		}
}


