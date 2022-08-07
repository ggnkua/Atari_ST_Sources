
overlay "player"

#include "..\\include\\lists.h"
#include "..\\include\\machine.h"
#include "..\\include\\format.h"
#include "..\\include\\poly.h"
#include "..\\include\\cursor.h"

#define UPDIR 1
#define DOWNDIR 0

WORD on_off_buf[ (XMAX+15)/16 * YMAX ];
#ifdef PORTABLE
struct cursor fill_stencil_cursor = 
	{
	0,
	on_off_buf,
	0, 0, 0, 0
	};
#endif PORTABLE

#ifdef ATARI
extern (*jblit_table[])();
extern WORD *cscreen;
#endif ATARI

fill_concave(poly)
register Poly *poly;
{
register LLpoint *pointpt;
register WORD x,y;
register WORD ox,oy;
register WORD xmin,ymin;
WORD lastdir;
WORD i;
WORD xmax,ymax;
WORD wordwidth;
WORD width, height;

pointpt = poly->clipped_list;
xmin = xmax = pointpt->x;
ymin = ymax = pointpt->y;
pointpt = pointpt->next;

i = poly->pt_count;
while (--i > 0)
   {
   if (xmin > pointpt->x) xmin = pointpt->x;
   if (xmax < pointpt->x) xmax = pointpt->x;
   if (ymin > pointpt->y) ymin = pointpt->y;
   if (ymax < pointpt->y) ymax = pointpt->y;
   pointpt = pointpt->next;
   }

if (ymin==ymax)  /*can't cope with trivial case*/
	{
	hline(ymin, xmin, xmax, poly->color);
	return;
	}

#ifdef ATARI
/*make it word alligned, the stencil that is...*/
xmin &= 0xfff0;
#endif ATARI

width = xmax - xmin + 1;
height = ymax - ymin + 1;
wordwidth = ( (width + 15)>>4);
block_stuff(on_off_buf, 0, wordwidth * 2 * height);

x = pointpt->x;
y = pointpt->y;

do
	{
	pointpt = pointpt->next;
	ox = pointpt->x;
	oy = pointpt->y;
	}
while (oy == y);

if (oy>y)
	lastdir = UPDIR;
else
	lastdir = DOWNDIR;

i = poly->pt_count;
while (--i >= 0)
   {
   pointpt = pointpt->next;
   x = pointpt->x;
   y = pointpt->y;
   if (y!=oy)
	  {
	  y_xor_line(wordwidth,ox-xmin,oy-ymin,x-xmin,y-ymin);
	  if (y>oy)
		 if (lastdir == UPDIR)
			xor_pt(wordwidth,ox-xmin,oy-ymin);
		 else
			lastdir = UPDIR;
	  else
		 if (lastdir == DOWNDIR)
			xor_pt(wordwidth,ox-xmin,oy-ymin);
		 else
			lastdir = DOWNDIR;
	  }
   ox = x;
   oy = y;
   }



/*run on off on it*/

on_off(wordwidth, width, height);

#ifdef ATARI
(*jblit_table[poly->fill_color])(wordwidth, height, on_off_buf,
	cscreen + 80*ymin + ((xmin>>4)<<2) );
#endif ATARI

#ifdef PORTABLE
fill_stencil_cursor.width = width;
fill_stencil_cursor.height = height;
show_c_nohot(&fill_stencil_cursor, xmin, ymin, poly->color);
#endif PORTABLE

outline_poly(poly);
/*show final version*/
}

#ifdef C_CODE
on_off(wordwidth, width, height)
WORD wordwidth;
WORD width;
WORD height;
{
register WORD *imagept = on_off_buf;
register WORD *linept;
register unsigned WORD rot;
register WORD j;

while (--height >= 0)
	{
	linept = imagept;
	j = width;
start_off:
	while ( !*linept)
   {
   linept++;
   if ( (j-=16) <= 0)
	   goto next_line;
   }
	rot = 0x8000;
	while (!(rot & *linept))
   {
   if ( --j <= 0)
	   goto next_line;
   rot >>=1;
   } /*scan til first on*/
skip_first_on:
	if ( --j <= 0)
   goto next_line;
	rot >>=1;
start_on:
	for (;;)
   {
   if (rot == 0)
	   {
	   linept++;
	   break;
	   }
   if (! (rot & *linept) )  /*advance over blank bits*/
	   *linept |= rot;
   else		 /*if found end segment in word*/
	   goto end_in_word;
   if ( --j <= 0)
	   goto next_line;
   rot >>=1;
   }
	while ( !*linept)
   {
   *linept = 0xffff;
   linept++;
   if ( (j-=16) <= 0)
	   goto next_line;
   }
	rot = 0x8000;
end_in_word:
	for (;;) /*look for new segment in word */
   {
   if ( (rot & *linept) )
	   {
	   for (;;)
	  {
	  if ( --j <= 0)
		  goto next_line;
	  rot >>= 1;
	  if (rot == 0)
		  {
		  linept++;
		  goto start_off;
		  }
	  if (rot & *linept)
		  goto skip_first_on;
	  }
	   }
   *linept |= rot;
   if ( --j <= 0)
	   goto next_line;
   rot >>= 1;
   }
next_line:
	imagept += wordwidth;
	}
}
#endif C_CODE


xor_pt(wordwidth,x,y)
WORD wordwidth;
register WORD x;
WORD y;
{
register unsigned WORD rot;

rot = ((unsigned)0x8000) >> (x&15);
on_off_buf[ wordwidth*y + (x>>4) ] ^= rot;
}


#ifdef C_CODE
y_xor_line(wordwidth, x1, y1, x2, y2)
WORD wordwidth;
int x1,y1,x2,y2;
{
register WORD *imagept = on_off_buf;
WORD height;
register unsigned WORD rot;
register WORD   duty_cycle;
WORD incx;
register WORD   delta_x, delta_y;
register WORD dots;

rot = ((unsigned)0x8000) >> (x1&15);
imagept += wordwidth*y1 + (x1>>4);

delta_y = y2-y1;
delta_x = x2-x1;
incx =  1;

if (delta_y < 0) 
   {
   delta_y = -delta_y;
   wordwidth = -wordwidth;
   }

if (delta_x < 0) 
   {
   delta_x = -delta_x;
   incx = -1;
   }


duty_cycle = delta_x - delta_y/2;
dots = delta_y;

*(imagept) ^= rot;

if (incx < 0)
	goto leftwards;
while (--dots >= 0)
	{
	 while (duty_cycle > 0)
   {
   duty_cycle -= delta_y;
   rot >>= 1;
   if (rot == 0)
	  {
	  imagept++;
	  rot = 0x8000;
	  }
   }
   
	duty_cycle += delta_x;	  /* update duty cycle */
	imagept += wordwidth;
	*(imagept) ^= rot;
	}
return;

leftwards:
while (--dots >= 0)
	{
	 while (duty_cycle > 0)
   {
   duty_cycle -= delta_y;
   rot <<= 1;
   if (rot == 0)
	  {
	  --imagept;
	  rot = 0x0001;
	  }
   }
   
	duty_cycle += delta_x;	  /* update duty cycle */
	imagept += wordwidth;
	*(imagept) ^= rot;
	}
}
#endif C_CODE



 
