/*
 *	spectest.c  --  test specout.c routines
 *
 *	Compile (with MWC) as "cc spectest.c specout.c".
 *
 *	Written by John Rosenberg
 *	CIS [73607,3464]; Genie J.ROSENBERG5
 */

#include <stdio.h>
#include <specout.h>


main()
{
   int  x, y, i, j, k, l, c;

   if (SpecOpen("spectest.spu")) {
      puts("Cannot open spectest.spu");
      exit(1);
   }

   puts("Clearing screen memory and pallettes...");
   SpecClearAll();

   puts("Setting up screen map...");
   y = 195;
   for (i=0; i<64; ++i) {			/* for RG = [0:63]	    */
      for (j=0; j<3; ++j) {			/* (3 scan lines each)	    */
         printf("Line %d\n",y);
         x = 0;
         for (k=0; k<8; ++k) {			/* -for B = [0:7]	    */
	    for (l=0; l<40; ++l) {		/* -(40 pixels each)	    */
	       if ((c = SpecAddColor(x, y, SpecInt2Color(8*i + k))) == -1) {
	          printf("Cannot add color %d at (%d,%d)\n",
		         (8*i + k), x, y);
		  exit(1);
	       }
	       SpecSetPixel(x++, y, c);
	    }
	 }
	 --y;
      }
   }

   puts("Writing screen map and pallettes...");
   SpecWriteOut();
}
