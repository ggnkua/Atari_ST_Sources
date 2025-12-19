/*********************************************************

HALFTGA.C  -  Shrinks a TARGA file to exactly 1/2 its size
	      and modifies the header appropriately.
	      By Aaron A. Collins, written on 3/30/90

	      Note - Does NOT interpolate color values!!
		     This is to complement PICLAB's inter-
		     polating "RESIZE" command...

	      This file is released to the Public Domain.

	      PICLAB is a trademark of The Stone Soup Group.
	      TARGA is a trademark of AT&T/Truevision.

Revised 5/15/91 - AAC - Version 1.1 - Removed IBM-ness of
	      filenames/exts.
**********************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXXRES 2048   /* huge max x resolution allowable, infinite y res. */

unsigned char linbuf[MAXXRES * 3];

void main(argc,argv)
int argc;
char *argv[];
{
	int xres, yres, xhi, yhi;
	register int x, y;
	FILE *in, *out;

	printf("\n\nTARGA-24 Image File 1/2 Size Resolution Reducer\n");
	printf("Version 1.1 By Aaron A. Collins.  Written 3/30/90 Revised 5/15/91\n\n");

	if (argc != 3)
	{
		printf("Usage: %s InputFile OutputFile\n\n",argv[0]);
		exit(1);
	}

	if ((in = fopen(argv[1], "rb")) == NULL)  /* try w/supplied ext. */
	{
		printf("ERROR - Couldn't open file %s\n", argv[1]);
		exit(1);
	}

	if ((out = fopen(argv[2], "wb")) == NULL)
	{
		printf("ERROR - Couldn't create file %s\n", argv[2]);
		fclose(in);
		exit(1);
	}

	/** Copy 1st part of standard Targa header **/

	for (x = 0; x < 12; x++)	/* 00, 00, 02, then 9 00's... */
		fputc(fgetc(in), out);

	/** load x and y resolution, and rewrite as rest of Targa hdr **/

	xres = fgetc(in);			/* lo order */
	xhi = fgetc(in);			/* hi order */
	xres += ((unsigned int) xhi) << 8;
	
	if (xres > MAXXRES)			/* too big? */
	{
		printf("ERROR - X res. of %s (%d) exceeds maximum (%d)!\n", argv[1], xres, MAXXRES);
		fclose(in);			/* close files */
		fclose(out);
		unlink(argv[2]);		/* delete empty out file */
		exit(1);
	}

	xhi = xres;				/* save old resolution */
	xres >>= 1;				/* cheapie divide by two! */

	fputc(xres & 0x00ff, out);		/* write lo order */
	fputc((xres & 0xff00) >> 8, out);	/* write lo order */

	yres = fgetc(in);			/* now do yres the same... */
	yhi = fgetc(in);
	yres += ((unsigned int) yhi) << 8;

	yhi = yres;
	yres >>= 1;

	fputc(yres & 0x00ff, out);
	fputc((yres & 0xff00) >> 8, out);

	fputc(fgetc(in), out);	/* 24 bits/pixel (16 million colors!) (24) */
	fputc(fgetc(in), out);	/* Set bit to indicate top-down display (32)*/

	printf("\nInput file        = %s\n", argv[1]);	/* show stats */
	printf("Output file       = %s\n\n", argv[2]);
	printf("Old X  resolution = %d\n", xhi);
	printf("Old Y  resolution = %d\n\n", yhi);
	printf("New X  resolution = %d\n", xres);
	printf("New Y  resolution = %d\n\n", yres);

	printf("Processing Line:   0");

	for (y = 0; y < yhi; y++)	/* for every line in the old file */
	{

		printf("\b\b\b%3d", y);		/* disp. current line # */

		fread(linbuf, 3, xhi, in);	/* read in a whole line */

		if (feof(in))			/* stop if file truncated */
			break;

		if (y & 0x0001)			/* throw away odd # lines */
			continue;

		for (x = 0; x < xhi; x++)	/* for every BGR triplet */
		{
			if (x & 0x0001)		/* throw away odd # BGR's */
				continue;

			fwrite(&linbuf[x * 3], 3, 1, out); /*write BGR trip*/
		}
	}
	printf("\n");
	fclose(in);                                 /* close files */
	fflush(out);
	fclose(out);
	exit(0);
}
