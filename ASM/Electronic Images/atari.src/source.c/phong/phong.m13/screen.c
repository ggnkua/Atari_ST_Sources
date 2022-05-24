#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include "types.h"

static unsigned char my_screen[64000];

//unsigned char *screen_ptr = 0xa0000;
unsigned char *screen_ptr = &(my_screen[0]);

void Put_pixel(int x,int y,int c)
{	* (unsigned char *) (screen_ptr + (y * MAX_X) + x) = c;
}

void DrawLine(int x1,int y1,int x2,int y2,int c)
{	int dx,dy,ydir;
	register int e,i;
	register unsigned char *scr;
	if (x1 > x2)
	{	int t;
		t = x1; x1 = x2; x2 = t;
		t = y1; y1 = y2; y2 = t; 
	}
	dx = x2 - x1;
	dy = y2 - y1;
	if (dy >= 0)
		ydir = MAX_X;
	else
	{	ydir = -MAX_X;
		dy =- dy;
	}	
	scr = screen_ptr + (y1 * MAX_X) + x1;
	if (dx > dy)
	{	e = dx;
		for (i=0 ; i < dx ; i++)
		{	*scr++ = c;		
			e -= (2*dy);
			if (e < 0)
			{	scr+=ydir;
				e += (2*dx);
			}
		}
	} else
	{	e = dy;
		for (i=0 ; i < dy ; i++)
		{	*scr = c;	
			e -= (2*dx);
			if (e < 0)
			{	scr++;
				e += (2*dy);
			}
			scr+=ydir;
		}
	}
	*scr = c;
}

void ClearDisplay(void)
{ 	unsigned char *scr = screen_ptr;
	memset((char *) screen_ptr,0,MAX_X*MAX_Y);
}

void InitDisplay(char *x)
{ 	int i;
    	int ncolors = 128;
	SetMode(0x13);
  	for (i=0; i<ncolors; i++) 
   	{ 	 SetColour(i,i >> 1,i >> 1,i >> 1);
	}
}
void UpdateDisplay(void)
{	memcpy (0xa0000,my_screen,64000);
}

void CloseDisplay(void)
{	SetMode(0x03);
}
