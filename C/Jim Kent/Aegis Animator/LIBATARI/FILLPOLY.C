
#include <stdio.h>
#include <osbind.h>
#include <aline.h>
#include "..\\include\\lists.h"
#include "..\\include\\poly.h"
#include "..\\include\\format.h"

#define YES 1
#define NO 0

extern WORD *cscreen;

static WORD thread1[YMAX], thread2[YMAX];


WORD *
xdda_ebuf(ebuf, x1, y1, x2, y2)
register WORD *ebuf;
int x1,y1,x2,y2;
{
WORD incx;
register WORD x;
register WORD   duty_cycle;
register WORD   delta_x, delta_y;
register WORD dots;


delta_y = y2-y1;
delta_x = x2-x1;
incx =  1;
x = x1;
if (delta_y < 0) 
   {
   delta_y = -delta_y;
   }

if (delta_x < 0) 
   {
   delta_x = -delta_x;
   incx = -1;
   }

duty_cycle = delta_x - delta_y/2;
dots = delta_y;

if (incx < 0)
	goto leftwards;
while (--dots >= 0)
	{
	 while (duty_cycle > 0)
	   {
	   duty_cycle -= delta_y;
	   x++;
	   }
	duty_cycle += delta_x;	  /* update duty cycle */
	*ebuf++ = x;
	}
return(ebuf);

leftwards:
while (--dots >= 0)
	{
	 while (duty_cycle > 0)
	   {
	   duty_cycle -= delta_y;
	   --x;
	   }
	 duty_cycle += delta_x;	  /* update duty cycle */
	 *ebuf++ = x;
	 }
return(ebuf);
}


/***********
**
**	fill_ebuf	-   fill in edge buffer
**
************/
WORD *
fill_ebuf(thread, count, ebuf)
register LLpoint *thread;
WORD count;
register WORD *ebuf;
{
register WORD x, y, ox, oy;

ox = *ebuf++ = thread->x;
oy = thread->y;

while (--count >= 0)
   {
   thread = thread->next;
   x = thread->x;
   y = thread->y;
   if (y!=oy)
	  {
	  ebuf = xdda_ebuf(ebuf,ox,oy,x,y);
	  }
   ox = x;
   oy = y;
   }
return(ebuf);
}

fill_poly(pl)
Poly *pl;
{
register LLpoint *p;
register LLpoint *np;
LLpoint *peak;
LLpoint *valley;
register WORD highy;
register WORD i;
register WORD pcount;
WORD lasty;

peak = p = pl->clipped_list;
i = pl->pt_count;
highy = p->y;
pcount = 0;
while (--i > 0)
	{
	p = p->next;
	if (p->y <= highy)
		{
		peak = p;
		highy = p->y;
		}
	}
p = peak;
np = p->next;
i = pl->pt_count;
while (--i >= 0)
	{
	if (np->y < p->y)
		{
		valley = p;
		p = np;
		np = np->next;
		while (--i >= 0)
			{
			if (np->y > p->y)
				{
				fill_concave(pl);
				return;	/*sorry its concave*/
				}
			p = np;
			np = np->next;		
			}
		fill_ebuf(peak, pcount, thread1);
		pcount = fill_ebuf(valley, pl->pt_count - pcount, thread2)
			- thread2;
		blast_hlines(thread1, thread2, highy, pcount, pl->fill_color);
		outline_poly(pl);	/*clean up edges*/
		return;
		}
	pcount++;
	p = np;
	np = np->next;
	}	
outline_poly(pl);
return;	/*all points of poly have same y value */
}

#ifdef C_CODE
unsigned WORD lmasks[16] = 
	{
	0xffff, 0x7fff, 0x3fff, 0x1fff,
	0xfff, 0x7ff, 0x3ff, 0x1ff,
	0xff, 0x7f, 0x3f, 0x1f,
	0xf, 0x7, 0x3, 0x1,
	};

unsigned WORD rmasks[16] =
	{
	0x8000, 0xc000, 0xe000, 0xf000,
	0xf800, 0xfc00, 0xfe00, 0xff00,
	0xff80, 0xffc0, 0xffe0, 0xfff0,
	0xfff8, 0xfffc, 0xfffe, 0xffff,
	};


hline1(line_addr, x1, x2)
register unsigned WORD *line_addr;
register WORD x1, x2;
{
register WORD count;
register WORD data;

line_addr += ((x1>>4)<<2);
count = (x2>>4) - (x1>>4);
x1 &= 0xf;
x2 &= 0xf;
if (count == 0)
	{
	data = ~(lmasks[x1] & rmasks[x2]);
	*line_addr++ &= data;
	*line_addr++ &= data;
	*line_addr++ &= data;
	*line_addr++ |= ~data;
	}
else
	{
	data = ~lmasks[x1];
	*line_addr++ &= data;
	*line_addr++ &= data;
	*line_addr++ &= data;
	*line_addr++ |= ~data;
	data = 0xffff;
	while (--count > 0)
		{
		*line_addr++ = 0;	
		*line_addr++ = 0;	
		*line_addr++ = 0;	
		*line_addr++ = data;	
		}
	data = ~rmasks[x2];
	*line_addr++ &= data;
	*line_addr++ &= data;
	*line_addr++ &= data;
	*line_addr++ |= ~data;
	}
}


#endif C_CODE
