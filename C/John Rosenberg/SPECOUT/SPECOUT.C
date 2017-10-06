/*
 *	specout.c  --  Spectrum 512 output routines (version 1)
 *
 *	Written by John Rosenberg
 *	CIS [73607,3464]; Genie J.ROSENBERG5
 */

#include <stdio.h>

FILE	*SpecFile;			/* output file descriptor	    */
int	SpecScreenMem[200][80];		/* 200(Y) x 80 words screen memory  */
int	SpecPallettes[200][48];		/* 200(Y) x 48 pallette words	    */
int	SpecBitIndex[] = { 0x8000, 0x4000, 0x2000, 0x1000,
			   0x0800, 0x0400, 0x0200, 0x0100,
			   0x0080, 0x0040, 0x0020, 0x0010,
			   0x0008, 0x0004, 0x0002, 0x0001 };


/* ------------------------------------------------------------------------
 *	Open Spectrum 512 output file.  Returns 0=success, -1=failure.
 * ------------------------------------------------------------------------ */

int SpecOpen(filename)
   char *filename;
{
   if ((SpecFile = fopen(filename,"wb")) == NULL)
      return (-1);
   return (0);
}


/* ------------------------------------------------------------------------
 *	Write out Spectrum file data and close file.
 * ------------------------------------------------------------------------ */

 SpecWriteOut()
 {
    SpecCleanupPallettes();
    SpecWriteMap();
    SpecWritePallettes();
    fclose(SpecFile);
 }


/* ------------------------------------------------------------------------
 *	Clear screen memory & pallettes.
 * ------------------------------------------------------------------------ */
 
SpecClearAll()
{
   int i, j;

   for (i=0; i<200; ++i)			/* clear screen memory	    */
      for (j=0; j<80; ++j)
         SpecScreenMem[i][j] = 0;
   for (i=0; i<200; ++i) {			/* clear all pallettes	    */
      SpecPallettes[i][0] = 0;
      for (j=1; j<48; ++j)
         SpecPallettes[i][j] = -1;
   }
}


/* ------------------------------------------------------------------------
 *	Convert integer color [0:511] to Atari color word [0x0RGB].
 * ------------------------------------------------------------------------ */

int SpecInt2Color(color_num)
   int color_num;
{
   int cw;

   cw = ((color_num << 2) & 0x0700) |
        ((color_num << 1) & 0x0070) |
         (color_num       & 0x0007);
   return (cw);
}


/* ------------------------------------------------------------------------
 *	Set pixel (x,y) to some color index [0:15].
 * ------------------------------------------------------------------------ */
 
SpecSetPixel(x, y, color)
   int x, y, color;
{
   int w, b, bit, i;

   w = (x >> 2) & 0x3ffc;		/* w --> 1st of 4 SpecScreenMem wds */
   b = SpecBitIndex[x % 16];		/* b = desired bit within words	    */
   for (i=0; i<4; ++i) {		/* set color (low-order bit first)  */
      bit = ((color & 1) ? b : 0);
      SpecScreenMem[y][w+i] |= bit;
      color >>= 1;
   }
}


/* ------------------------------------------------------------------------
 *	Add a color word [0x0RGB] to a pallette, specified by 'y'.  The
 *	color must be accessable from the 'x' column.  The color is added
 *	if needed.  Returns a color index [0:15], or -1 if insufficient
 *	room remains in the pallette to add the color.
 * ------------------------------------------------------------------------ */

int SpecAddColor(x, y, color_word)
   int x, y, color_word;
{
   int i;

   for (i=0; i<48; ++i)				  /* see if already there   */
      if ((SpecPallettes[y][i] == color_word) &&  /* and accessable at 'x'  */
          (SpecColorAccessableP(x, i)))
         return (i % 16);			/* if so, return index % 16 */
   for (i=1; i<48; ++i)				/* no, try to insert	    */
      if ((SpecPallettes[y][i] == -1) &&
          (SpecColorAccessableP(x, i))) {	/* (note: color 0 reserved) */
	 SpecPallettes[y][i] = color_word;
         return (i % 16);
      }
   return (-1);					/* failed, too bad	    */
}


/* ------------------------------------------------------------------------
 *	Determine if column 'x' can access pallette index 'index' [0:47].
 * ------------------------------------------------------------------------ */

int SpecColorAccessableP(x, index)
   int x, index;
{
   int a, base;

   if (x == 0)					/* set base of 16 indices   */
      base = 0;					/*  available at 'x'	    */
   else {
      a = x % 20;
      if ((a >= 1) && (a <= 4))			/* determine test to use    */
	 base = (x / 10) + 1;
      else
         base = ((x - 1) / 10) + 2;
   }
   return ((index >= base) && (index <= (base+15)));
}

/* ------------------------------------------------------------------------
 *	Clean up pallettes before writing out.
 * ------------------------------------------------------------------------ */

SpecCleanupPallettes()
{
   int i, j;

   for (i=0; i<200; ++i)
      for (j=0; j<48; ++j)
	 if (SpecPallettes[i][j] == -1)
	    SpecPallettes[i][j] = 0;
}


/* ------------------------------------------------------------------------
 *	Write out screen map.
 * ------------------------------------------------------------------------ */
 
SpecWriteMap()
{
   fwrite(&SpecScreenMem[0][0], 80*2, 200, SpecFile);
}


/* ------------------------------------------------------------------------
 *	Write out pallettes.
 * ------------------------------------------------------------------------ */

SpecWritePallettes()
{
   fwrite(&SpecPallettes[1][0], 48*2, 199, SpecFile);
}
