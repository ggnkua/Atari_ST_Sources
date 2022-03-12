/*
   Doom Editor Utility, by Brendon Wyber and Rapha‰l Quinet.
   Atari port by Anthony Jacques.

   You are allowed to use any parts of this code in another program, as
   long as you give credits to the authors in the documentation and in
   the program itself.  Read the file README.1ST for more information.

   This program comes with absolutely no warranty.

   ATARIGFX.C - Graphics routines.
*/

/* the includes */
#include "deu.h"
#include <math.h>
#include <dos.h>
#include <osbind.h>


/* the global variables */
short GfxMode = 0;	/* graphics mode number, or 0 for text */
			/* 1 = 320x200, 2 = 640x480, 3 = 800x600, 4 = 1024x768 */
			/* positive = 16 colors, negative = 256 colors */
short OrigX;		/* the X origin */
short OrigY;		/* the Y origin */
float Scale;		/* the scale value */
short PointerX;		/* X position of pointer */
short PointerY;		/* Y position of pointer */
short ScrMaxX;		/* maximum X screen coord */
short ScrMaxY;		/* maximum Y screen coord */
short ScrCenterX;		/* X coord of screen center */
short ScrCenterY;		/* Y coord of screen center */


short OldMode;

/*
   initialise the graphics display
*/

void InitGfx()
{
   OldMode=Vsetmode(-1);     
   
   /*if (Montype()==2) VsetScreen(0x1b); */ /* 640x480x256xVGA */
/*       else VsetScreen(0x10b);          *//* 640x400x256xRGB */
 
   GfxMode = -2; /* 640x480x256 */
   SetDoomPalette( 0);
  
/*   setlinestyle( 0, 0, 1);
   setbkcolor( TranslateToDoomColor( BLACK));
   settextstyle( 0, 0, 1);
*/   ScrMaxX = 640;
   if (Montype()==2) ScrMaxY = 480;
      else ScrMaxY=400;
   ScrCenterX = ScrMaxX / 2;
   ScrCenterY = ScrMaxY / 2;
}



/*
   terminate the graphics display
*/

void TermGfx()
{

if (Vsetmode(-1)!=OldMode) Vsetmode(OldMode);

}



/*
   switch from VGA 16 colours to VGA 256 colours
*/

Bool SwitchToVGA256()
{

/* Switch to 256 colour mode, with VsetScreen. */

   if (Montype()==2) VsetScreen(-1L,-1L,3,0x1b);  /* 640x480x256xVGA */
       else VsetScreen(-1L,-1L,3,0x10b);          /* 640x400x256xRGB */
 
   GfxMode = -2; /* 640x480x256 */
   SetDoomPalette( 0);
  
/*   setlinestyle( 0, 0, 1);
   setbkcolor( TranslateToDoomColor( BLACK));
   settextstyle( 0, 0, 1);
*/   ScrMaxX = 640;
   if (Montype()==2) ScrMaxY = 480;
      else ScrMaxY=400;
   ScrCenterX = ScrMaxX / 2;
   ScrCenterY = ScrMaxY / 2;

   return TRUE;
}



/*
   switch from VGA 256 colours to VGA 16 colours
*/

Bool SwitchToVGA16()
{

/*
   Why would we want to switch down from 256 to 16 colours????
   I see no point in doing this...
*/

/*   if (Montype()==2) VsetScreen(0x1a);  *//* 640x480x16xVGA */
/*       else VsetScreen(0x10a);          *//* 640x400x16xRGB */
 
   GfxMode = 2; /* 640x480x16 */
   SetDoomPalette( 0);

   ScrMaxX = 640;
   if (Montype()==2) ScrMaxY = 480;
      else ScrMaxY=400;
   ScrCenterX = ScrMaxX / 2;
   ScrCenterY = ScrMaxY / 2;
   
   return TRUE;
}



/*
   clear the window
*/

void ClearScreen()
{
 vsm_color(workstation,0);
 vr_recfl(workstation, vdi_rect);
}



/*
   set the current drawing color
*/

void SetColor( short color)
{
/*   if (GfxMode < 0)
 *     setcolor( TranslateToDoomColor(color));  256 colour choice 
 *  else
 *     setcolor( color);  */  /* 16 colour choice */

 vsm_color(workstation,color);
 vsf_color(workstation,color);
 vsl_color(workstation,color);
}



/*
   draw a line on the screen from map coords
*/

void DrawMapLine( short mapXstart, short mapYstart, short mapXend, short mapYend)
{
 int pxyarray[4];

 pxyarray[0]=SCREENX(mapXstart);
 pxyarray[1]=SCREENY(mapYstart);
 pxyarray[2]=SCREENX(mapXend);
 pxyarray[3]=SCREENY(mapYend);

 v_pline(workstation,2,pxyarray);
}



/*
** draw a circle on the screen from map coords
*/

void DrawMapCircle( short mapXcenter, short mapYcenter, short mapRadius)
{
 v_circle(workstation, SCREENX(mapXcenter), SCREENY(mapYcenter), mapRadius * Scale);
}



/*
** draw an arrow on the screen from map coords
*/
void DrawMapVector( short mapXstart, short mapYstart, short mapXend, short mapYend)
{
   short  scrXstart = SCREENX( mapXstart);
   short  scrYstart = SCREENY( mapYstart);
   short  scrXend   = SCREENX( mapXend);
   short  scrYend   = SCREENY( mapYend);
   double r         = (double) sqrt((double)((scrXstart-scrXend)*(scrXstart-scrXend) + (scrYstart-scrYend)*(scrYstart-scrYend)));
   short  scrXoff   = (r >= 1.0) ? (short) ((scrXstart - scrXend) * 8.0 / r * Scale) : 0;
   short  scrYoff   = (r >= 1.0) ? (short) ((scrYstart - scrYend) * 8.0 / r * Scale) : 0;
 int pxyarray[4];

 pxyarray[0]=scrXstart;
 pxyarray[1]=scrYstart;
 pxyarray[2]=scrXend;
 pxyarray[3]=scrYend;
 v_pline(workstation,2,pxyarray);

 scrXstart = scrXend + 2 * scrXoff;
 scrYstart = scrYend + 2 * scrYoff;

 pxyarray[0]=scrXstart - scrYoff;
 pxyarray[1]=scrYstart + scrXoff;
 pxyarray[2]=scrXend;
 pxyarray[3]=scrYend;
 v_pline(workstation,2,pxyarray);

 pxyarray[0]=scrXstart + scrYoff;
 pxyarray[1]=scrYstart - scrXoff;
 pxyarray[2]=scrXend;
 pxyarray[3]=scrYend;
 v_pline(workstation,2,pxyarray);
}



/*
** draw an arrow on the screen from map coords and angle (0 - 65535)
*/
void DrawMapArrow( short mapXstart, short mapYstart, unsigned angle)
{
 short mapXend   = mapXstart + (short) (50 * cos(angle / 10430.37835));
 short mapYend   = mapYstart + (short) (50 * sin(angle / 10430.37835));
 short scrXstart = SCREENX( mapXstart);
 short scrYstart = SCREENY( mapYstart);
 short scrXend   = SCREENX( mapXend);
 short scrYend   = SCREENY( mapYend);
 double r      = (double)sqrt((double) ((scrXstart - scrXend)*(scrXstart - scrXend) + (scrYstart - scrYend)*(scrYstart - scrYend)));
 short scrXoff   = (r >= 1.0) ? (short) ((scrXstart - scrXend) * 8.0 / r * Scale) : 0;
 short scrYoff   = (r >= 1.0) ? (short) ((scrYstart - scrYend) * 8.0 / r * Scale) : 0;
 int pxyarray[4];

 pxyarray[0]=scrXstart;
 pxyarray[1]=scrYstart;
 pxyarray[2]=scrXend;
 pxyarray[3]=scrYend;
 v_pline(workstation,2,pxyarray);

 scrXstart = scrXend + 2 * scrXoff;
 scrYstart = scrYend + 2 * scrYoff;

 pxyarray[0]=scrXstart - scrYoff;
 pxyarray[1]=scrYstart + scrXoff;
 pxyarray[2]=scrXend;
 pxyarray[3]=scrYend;
 v_pline(workstation,2,pxyarray);

 pxyarray[0]=scrXstart + scrYoff;
 pxyarray[1]=scrYstart - scrXoff;
 pxyarray[2]=scrXend;
 pxyarray[3]=scrYend;
 v_pline(workstation,2,pxyarray);
}



/*
** draw a line on the screen from screen coords
*/
void DrawScreenLine( short Xstart, short Ystart, short Xend, short Yend)
{
 int pxyarray[4];

 pxyarray[0]=Xstart;
 pxyarray[1]=Ystart;
 pxyarray[2]=Xend;
 pxyarray[3]=Yend;
 v_pline(workstation,2,pxyarray);
}



/*
** draw a filled in box on the screen from screen coords
*/
void DrawScreenBox( short Xstart, short Ystart, short Xend, short Yend)
{
 int pxyarray[4];

 pxyarray[2]=Xstart;
 pxyarray[3]=Ystart;
 pxyarray[0]=Xend;
 pxyarray[1]=Yend;
 v_bar(workstation,pxyarray);
}



/*
** draw a filled-in 3D-box on the screen from screen coords
*/
void DrawScreenBox3D( short Xstart, short Ystart, short Xend, short Yend)
{
 DrawScreenBox( Xstart + 1, Ystart + 1, Xend - 1, Yend - 1);
 SetColor( 8);

 DrawScreenLine( Xstart, Yend, Xend, Yend);
 DrawScreenLine( Xend, Ystart, Xend, Yend);
 if (Xend - Xstart > 20 && Yend - Ystart > 20)
    {
     DrawScreenLine( Xstart + 1, Yend - 1, Xend - 1, Yend - 1);
     DrawScreenLine( Xend - 1, Ystart + 1, Xend - 1, Yend - 1);
     SetColor( WHITE);
     DrawScreenLine( Xstart + 1, Ystart + 1, Xstart + 1, Yend - 1);
     DrawScreenLine( Xstart + 1, Ystart + 1, Xend - 1, Ystart + 1);
    }
 SetColor( WHITE);
 DrawScreenLine( Xstart, Ystart, Xend, Ystart);
 DrawScreenLine( Xstart, Ystart, Xstart, Yend);
 SetColor( BLACK);
}



/*
** draw a hollow 3D-box on the screen from screen coords
*/
void DrawScreenBoxHollow( short Xstart, short Ystart, short Xend, short Yend)
{
 DrawScreenBox( Xstart + 1, Ystart + 1, Xend - 1, Yend - 1);
 SetColor( WHITE);
 DrawScreenLine( Xstart, Yend, Xend, Yend);
 DrawScreenLine( Xend, Ystart, Xend, Yend);
 if (Xend - Xstart > 20 && Yend - Ystart > 20)
    {
     DrawScreenLine( Xstart + 1, Yend - 1, Xend - 1, Yend - 1);
     DrawScreenLine( Xend - 1, Ystart + 1, Xend - 1, Yend - 1);
     SetColor( 8);
     DrawScreenLine( Xstart + 1, Ystart + 1, Xstart + 1, Yend - 1);
     DrawScreenLine( Xstart + 1, Ystart + 1, Xend - 1, Ystart + 1);
    }
 SetColor( 8);
 DrawScreenLine( Xstart, Ystart, Xend, Ystart);
 DrawScreenLine( Xstart, Ystart, Xstart, Yend);
 SetColor( WHITE);
}



/*
** draw a meter bar on the screen from screen coords (in a hollow box); max. value = 1.0
*/

void DrawScreenMeter( short Xstart, short Ystart, short Xend, short Yend, float value)
{
 if (value < 0.0) value = 0.0;
 if (value > 1.0) value = 1.0;

 SetColor(BLACK);
 DrawScreenBox( Xstart + 1 + (short) ((Xend - Xstart - 2) * value), Ystart + 1, Xend - 1, Yend - 1);

 SetColor(10);
 DrawScreenBox( Xstart + 1, Ystart + 1, Xstart + 1 + (short) ((Xend - Xstart - 2) * value), Yend - 1);
}



/*
** write text to the screen
*/

void DrawScreenText( short Xstart, short Ystart, char *msg, ...)
{

/*
* Wow! The PC version was big!!! Just call v_gtext() 
*
* Sadly, this doesn't accept the ... stuff. 
* Perhaps a 'sprintf()' call could be made to do this? [C Question...]
*/

 v_gtext(workstation, Xstart, Ystart, msg);
}



/*
** Old PC function - not needed, as we always have an OS handled
** mouse pointer...
*/
void DrawPointer( Bool rulers)
{
}



/*
** load one "playpal" palette and change all palette colours
*/
void SetDoomPalette( short playpalnum)
{
 MDirPtr dir;
 unsigned char *dpal;
 short n;
 short rgb[3];

 if (playpalnum < 0 && playpalnum > 13)
     return;
 dir = FindMasterDir( MasterDir, "PLAYPAL");
 if (dir)
    {
     dpal = GetMemory( 768 * sizeof( char));
     BasicWadSeek( dir->wadfile, dir->dir.start);
     for (n = 0; n <= playpalnum; n++)
	     BasicWadRead( dir->wadfile, dpal, 768L);
     for (n = 0; n < 768; n+=3)
         {
          rgb[0]=dpal[n]*4;
          rgb[1]=dpal[n+1]*4;
          rgb[2]=dpal[n+2]*4;
          vs_color(workstation,n/3,rgb);
         }
     FreeMemory( dpal);
    }
}



/*
** translate a standard color to Doom palette 0 (approx.)
*/

short TranslateToDoomColor( short color)
{
 if (GfxMode < 0)
    switch (color)
       {
        case BLACK:
             return 0;
        case BLUE:
             return 202;
        case GREEN:
             return 118;
        case CYAN:
             return 194;
        case RED:
             return 183;
        case MAGENTA:
             return 253;
        case 6:
             return 144;
        case 7:
             return 88;
        case 8:
             return 96;
        case 9:
             return 197;
        case 10:
             return 112;
        case 11:
             return 193;
        case 12:
             return 176;
        case 13:
             return 250;
        case YELLOW:
             return 231;
        case WHITE:
             return 4;
       }
 return color;
}



/* Yes, I know all the functions below should be in another file, */
/* but this is the only source file that includes <math.h>...     */

/*
** translate (dx, dy) into an integer angle value (0-65535)
*/
unsigned ComputeAngle( short dx, short dy)
{
 return (unsigned) (atan2( (double) dy, (double) dx) * 10430.37835 + 0.5);
}



/*
** compute the distance from (0, 0) to (dx, dy)
*/
unsigned ComputeDist( short dx, short dy)
{
 return (unsigned) (atan2( (double) dy, (double) dx) * 10430.37835 + 0.5);
}



/*
** insert the vertices of a new polygon
*/
void InsertPolygonVertices( short centerx, short centery, short sides, short radius)
{
 short n;

 for (n = 0; n < sides; n++)
    InsertObject( OBJ_VERTEXES, -1, centerx + (short) ((double) radius * cos( 6.28 * (double) n / (double) sides)), centery + (short) ((double) radius * sin( 6.2832 * (double) n / (double) sides)));
}



/*
** move (x, y) to a new position: rotate and scale around (0, 0)
*/
void RotateAndScaleCoords( short *x, short *y, double angle, double scale)
{
 double r, theta;

 r = (double)sqrt((double)((*x)*(*x) + (*y)*(*y)));
 theta = atan2( (double) *y, (double) *x);
 *x = (short) (r * scale * cos( theta + angle) + 0.5);
 *y = (short) (r * scale * sin( theta + angle) + 0.5);
}



/* end of file */
