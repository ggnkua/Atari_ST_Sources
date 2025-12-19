/*****************************************************************

GLUETGA.C  -  Glues together several partial .TGA files
              (using the header Y offset for line #) and
	      concatenates them into one full screen .TGA
	      file of whatever resolution used.  Nearly any
	      resolution should work, but all partial files
	      MUST be of the same overall frame X-Y size.

	      By Aaron A. Collins, written on 6/2/90

	      This file is released to the Public Domain.

	      PICLAB is a trademark of The Stone Soup Group.
	      TARGA is a trademark of AT&T/Truevision.

Revised 05/09/91 V1.1 AAC - reordered args so output file is last. 
Revised 05/15/91 V1.2 AAC - removed IBM-ness of filenames/exts.

*****************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define HDRLEN 18L

char outname[80];
char inname[20][80];

void main(argc,argv)
int argc;
char *argv[];
{
	int xres, yres, xhi, yhi, yorigin, yorghi, outxres, outyres, numfiles;
	int x, y, index;
	unsigned char *buffer;
	long posn;
	FILE *in, *out;

	printf("\n\nTARGA-24 Image File Concatenation Utility\n");
	printf("Version 1.2 By Aaron A. Collins.  Written 3/30/90 Revised 05/15/91\n\n");

	if (argc < 3)
	{
		printf("Usage: %s InputFile1 [InputFile2]... OutputFile\n\n",argv[0]);
		exit(1);
	}

	numfiles = argc - 2;		  /* number of input files to do */

	for (x = 0; x < numfiles; x++)
		strcpy(&inname[x][0], argv[1 + x]); /* get in filename(s) */

	strcpy(outname, argv[numfiles + 1]);  /* get final output filename */

	if ((in = fopen(&inname[0][0], "rb")) == NULL) /* try 1st file ext */
	{
		printf("ERROR - Couldn't open file %s\n", argv[1]);
		exit(1);
	}

	if ((out = fopen(outname, "wb")) == NULL)
	{
		printf("ERROR - Couldn't create file %s\n", outname);
		fclose(in);
		exit(1);
	}

	printf("Creating Output file = %s\n\n", outname); /* show stats */

	/** Copy 1st part of standard Targa header **/

	for (x = 0; x < 10; x++)	/* 00, 00, 02, then 7 00's... */
		fputc(fgetc(in), out);

	/** discard y orgin, and rewrite 0 as new in rest of Targa hdr **/

	fgetc(in);
	fgetc(in);
	fputc(0, out);
	fputc(0, out);
	
	/** load x and y resolution, and rewrite as rest of Targa hdr **/

	outxres = fgetc(in);			/* lo order */
	xhi = fgetc(in);			/* hi order */
	outxres += ((unsigned int) xhi) << 8;

	fputc(outxres & 0x00ff, out);		/* write lo order */
	fputc((outxres & 0xff00) >> 8, out);	/* write hi order */

	outyres = fgetc(in);			/* now do yres the same... */
	yhi = fgetc(in);
	outyres += ((unsigned int) yhi) << 8;

	fputc(outyres & 0x00ff, out);
	fputc((outyres & 0xff00) >> 8, out);

	fputc(fgetc(in), out);	/* 24 bits/pixel (16 million colors!) (24) */
	fputc(fgetc(in), out);	/* Set bit to indicate top-down display (32)*/
	
	fclose(in);		/* Close the input file, read body later. */
	
	printf("Image  X  resolution = %d\n", outxres);	 /* show more stats */
	printf("Image  Y  resolution = %d\n\n", outyres);

	if ((buffer = malloc(outxres * 3)) == NULL)
	{
		printf("ERROR - couldn't allocate memory for buffer!\n");
		fclose (out);
		unlink (outname);
	}

	/* write out zeroes to the entire output file's body */

	for (x = 0; x < outxres; x++)		/* clear line buffer */
	{
		index = x * 3;
		buffer[index++] = '\0';		/* write null BGR triples */
		buffer[index++] = '\0';
		buffer[index] = '\0';
	}
	
	for (y = 0; y < outyres; y++)		 /* for the number of lines */
		if (fwrite(buffer, 3, outxres, out) != (unsigned int)outxres) /*wrt a line*/
		{
			printf("ERROR - Couldn't create file %s - out of disk space?\n", outname);
			fclose(in);
			fclose(out);
			unlink(outname);
			exit(1);
		}

	for (index = 0; index < numfiles; index++) /* for # of input files */
	{
		if ((in = fopen(&inname[index][0], "rb")) == NULL)
		{
			printf("ERROR - Couldn't open file %s\n", &inname[index][0]);
			fclose(out);
			unlink(outname);
			exit(1);
		}
		printf("Glueing File:  %s\t", &inname[index][0]);

		/** Read and discard 1st part of standard Targa header **/

		for (x = 0; x < 10; x++)   /* 00, 00, 02, then 7 00's... */
			fgetc(in);

		/** load y origin for this segment... **/

		yorigin = fgetc(in);
		yorghi = fgetc(in);
		yorigin += ((unsigned int) yorghi) << 8;
		
		/** load x and y resolution, check if okay... **/

		xres = fgetc(in);			/* lo order */
		xhi = fgetc(in);			/* hi order */
		xres += ((unsigned int) xhi) << 8;
		if (xres > outxres)			/* too big? */
		{
			printf("ERROR - X res. of %s (%d) exceeds maximum (%d)!\n", &inname[index][0], xres, outxres);
			fclose(in);			/* close files */
			fclose(out);
			unlink(outname);		/* delete bad file */
			exit(1);
		}

		yres = fgetc(in);		/* now do yres the same... */
		yhi = fgetc(in);
		yres += ((unsigned int) yhi) << 8;
		if (yres > outyres)			/* too big? */
		{
			printf("ERROR - Y res. of %s (%d) exceeds maximum (%d)!\n", &inname[index][0], yres, outyres);
			fclose(in);			/* close files */
			fclose(out);
			unlink(outname);		/* delete bad file */
			exit(1);
		}

		fgetc(in); /* absorb 24 bits/pixel (16 million colors!) (24)*/
		fgetc(in); /* also bit to indicate top-down display (32)*/

		printf("to line:   %d", yorigin);

		posn = (long) yorigin * ((long) outxres * 3) + HDRLEN;
		fseek(out, posn, 0);	/* position output file for copy */

		for (y = yorigin; y < yres; y++) /* for every line in file */
		{
			printf("\b\b\b%3d", y);	   /* disp. current line # */

			/* read in a whole line */
			if (fread(buffer, 3, xres, in) != (unsigned int)xres)
				break;		/* stop if less bytes read */

			fwrite(buffer, 3, xres, out); /* copy BGR triplets */
		}
		printf("\n");
		fclose(in);		/* close this input file */
	}
	fflush(out);			/* close output file when done */
	fclose(out);
	exit(0);
}
