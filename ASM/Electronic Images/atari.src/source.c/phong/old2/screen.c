#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <conio.h>
#include <dos.h>
#include <string.h>
#include "types.h"

unsigned int PageOffsets[]={ 0*19200, 1*19200};
unsigned char *screen_ptr=0xa0000;

/*
 *      Set video mode.
 */

void SetMode(int mode)
{
  union REGS r;

  r.w.ax = mode;
  int386(0x10, &r, &r);
}

char *SetDrawPage(int Page)
{      return (char *) (0xA0000 + PageOffsets[Page & 1]);
}

void ModeX_320x240()
{
    int i,j;

    static int X320Y240[] = {
        0x0d06, /* vertical total */
        0x3e07, /* overflow (bit 8 of vertical counts) */
        0x4109, /* cell height (2 to double-scan) */
        0xea10, /* v sync start */
        0xac11, /* v sync end and protect cr0-cr7 */
        0xdf12, /* vertical displayed */
        0x0014, /* turn off dword mode */
        0xe715, /* v blank start */
        0x0616, /* v blank end */
        0xe317  /* turn on byte mode */
    };

    SetMode(0x13);
    outpw(SC_INDEX, 0x604);
    outpw(SC_INDEX, 0x100);
    outp(MISC_OUTPUT, CLOCK);
    outpw(SC_INDEX, 0x300);
    outp(CRTC_INDEX, 0x11);
    j = inp(CRTC_INDEX+1);
    j &= 0x7f;
    outp(CRTC_INDEX+1, j);
    for(i=0;i<REGCOUNT; i++) {
        outpw(CRTC_INDEX, X320Y240[i]);
    }
}


void SetViewPage(int Page)
{       int Offset = PageOffsets[Page & 1];
        outp(CRTC_INDEX, 0xC);
        outp(CRTC_INDEX+1, Offset >> 8);
        outp(CRTC_INDEX, 0xD);
        outp(CRTC_INDEX+1, Offset & 0xFF);
}

/* Plot a pixel in mode x 
 */


void PlotPixelX(short x, short y, short Color)
{
    char *Pixel;
    outpw(SC_INDEX, ((1 << (x & 3)) << 8) + 2);
    Pixel = (char *) screen_ptr;
    Pixel += y*(MAX_X>>2);
    Pixel += (x >> 2);
    *Pixel = Color;
}

void WaitVBL()
{
    int i;
    do {
        i = inp(0x3da);
    }while ((i&8) == 0);
}


void SetColour(int N,int R, int B, int G)
{
    outp(0x3C8, N);
    outp(0x3C9, R);
    outp(0x3C9, B);
    outp(0x3C9, G);
}

void SetPal(char *pal)
{	int i;
    	outp(0x3C8, 0);
    	for (i=0 ; i < 255 ; i++)
 	{	unsigned char R = *pal++;
	    	unsigned char G = *pal++;
		unsigned char B = *pal++;
	    	outp(0x3C9, R >> 2);
    		outp(0x3C9, B >> 2);
    		outp(0x3C9, G >> 2);
	}
}

void PlotPixel(int x,int y,int c)
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
{ 	short *scr = (short *) screen_ptr,y,c=0;
	extern short z_buffer[MAX_X*MAX_Y];
	int *z= (int *) z_buffer,d=0x7fff7fff;
    	outpw(SC_INDEX, ((15 << 8) + 2));
	for (y = 0; y < (MAX_Y*MAX_X)/64;y++)
	{ 	scr[0] = c; 	z[0] = d; z[1] = d; z[2] = d; z[3] = d;
	    	scr[1] = c;	z[4] = d; z[5] = d; z[6] = d; z[7] = d;
	    	scr[2] = c; 	z[8] = d; z[9] = d; z[10]= d; z[11]= d;
 		scr[3] = c;	z[12]= d; z[13]= d; z[14]= d; z[15]= d;
	    	scr[4] = c; 	z[16]= d; z[17]= d; z[18]= d; z[19]= d;
		scr[5] = c;	z[20]= d; z[21]= d; z[22]= d; z[23]= d;
	    	scr[6] = c; 	z[24]= d; z[25]= d; z[26]= d; z[27]= d;
		scr[7] = c;	z[28]= d; z[29]= d; z[30]= d; z[31]= d;
	    	z+=32; scr+=8;
	}
}

void InitDisplay(char *x)
{ 	int i;
    	int ncolors = 128;
	ModeX_320x240();
    	outpw(SC_INDEX, ((15 << 8) + 2));
	memset(0xa0000,0,64000);
  	for (i=0; i<ncolors; i++) 
   	{ 	 SetColour(i,i >> 1,i >> 1,i >> 1);
	}
}

void UpdateDisplay(void)
{	static int mypage = 0;
    	extern int timingflag;
    	SetViewPage(mypage++);
	if (timingflag)
		SetColour(0,20,20,20);
	WaitVBL();
	SetColour(0,0,0,0);
	screen_ptr = (char *) SetDrawPage(mypage);
}

void CloseDisplay(void)
{	SetMode(0x03);
}
