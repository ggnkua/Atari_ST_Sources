/*
 *
 *
 */



#include <conio.h>
#include <dos.h>
#include <string.h>

#define AC_INDEX        0x3c0   /* Attribute controller index register */
#define MISC_OUTPUT     0x3c2   /* Miscellaneous Output register */
#define SC_INDEX        0x3c4   /* Sequence Controller Index */
#define GC_INDEX        0x3ce   /*  Graphics controller Index */
#define CRTC_INDEX      0x3d4   /* CRT Controller Index */
#define DAC_READ_INDEX  0x3c7   /* */
#define DAC_WRITE_INDEX 0x3c8   /* */
#define DAC_DATA        0x3c9   /* */
#define INPUT_STATUS_0  0x3da   /* Input status 0 register */

#define CLOCK       0xe3    /* dot clock */
#define REGCOUNT    10      /* Number of CRTC Registers to update */

unsigned int DrawPage;
unsigned int PageOffsets[]={ 0*19200, 1*19200};

/*
 *      Set video mode.
 */

void SetMode(int mode)
{
  union REGS r;

  r.w.ax = mode;
  int386(0x10, &r, &r);
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
    SetDrawPage(0);
    ClearScreen();
    SetDrawPage(1);
    ClearScreen();
}

void SetDrawPage(int Page)
{       DrawPage = (0xA0000 + PageOffsets[Page & 1]);
}

void SetViewPage(int Page)
{       int Offset = PageOffsets[Page & 1];
        outp(CRTC_INDEX, 0xC);
        outp(CRTC_INDEX+1, Offset >> 8);
        outp(CRTC_INDEX, 0xD);
        outp(CRTC_INDEX+1, Offset & 0xFF);
}


void ClearScreen()
{      ClearScr(DrawPage);
}

/* Plot a pixel in mode x 
 */


void PlotPixelX(short x, short y, short Color)
{
    char *Pixel;

    outpw(SC_INDEX, ((1 << (x & 3)) << 8) + 2);
    Pixel = (char *)DrawPage;
    Pixel += y*80;
    Pixel += (x >> 2);
    *Pixel = Color;
}

void PlotPixel13(short x, short y, short Color)
{
    char *Pixel;
    Pixel = (char *) DrawPage + (y*320) +x ;
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
