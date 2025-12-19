/***************************************************************

TGA2DUMP.C  - Converts a Targa-16/24/32 file to a DKB/QRT "Dump"
	      format raw file.

	      Version 1.1 By Aaron A. Collins, written on 1/1/91
	      Version 1.2 By Aaron A. Collins, revised on 5/1/91
	      Version 1.3 By Aaron A. Collins, revised on 5/15/91

	      This file is released to the Public Domain.

 **************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

#define MAXXRES 2048   /* huge max x resolution allowable, infinite y res. */

write_line(int, FILE *, int);

unsigned char linbuf[MAXXRES * 3];

void main(argc,argv)
int argc;
char *argv[];
{
	register int xres, yres, xhi, yhi;
	register int y, pixelsize, filetype;
	FILE *in, *out;

	printf("\n\nTarga-16/24/32 Image File to DKB/QRT Dump Format Converter\n");
	printf("Version 1.3  By Aaron A. Collins.  Written 1/1/91 Revised 5/15/91\n\n");

	if (argc != 3)
	{
		printf("Usage: %s InputFile OutputFile\n\n",argv[0]);
		exit(1);
	}

	if ((in = fopen(argv[1], "rb")) == NULL)  /* try opening input file */
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

	/** absorb 1st part of Targa header **/

	fgetc(in);		/* absorb 2 0's */
	fgetc(in);

	if ((filetype = fgetc(in)) != 2) /* Uncompressed, Unmapped TGA only */
	{
		printf("\nInvalid Targa File Type %d (Must be 2) - Aborting!\n\n", filetype);
		fclose(in);             /* close all files */
		fclose(out);
		unlink(argv[2]);
		exit(1);
	}

	for (y = 0; y < 9; y++)	/* discard 7 0's and file X/Y origin */
		fgetc(in);

	/** load x and y resolution from input Targa file while copying **/

	xres = fputc(fgetc(in), out);	/* lo order */
	xhi = fputc(fgetc(in), out);	/* hi order */
	xres += ((unsigned int) xhi) << 8;

	if (xres > MAXXRES)			/* too big? */
	{
		printf("ERROR - X res. of %s (%d) exceeds maximum (%d)!\n", argv[1], xres, MAXXRES);
		fclose(in);			/* close all files */
		fclose(out);
		unlink(argv[2]);		/* delete empty out files */
		exit(1);
	}

	yres = fputc(fgetc(in), out);		/* now do yres the same... */
	yhi = fputc(fgetc(in), out);
	yres += ((unsigned int) yhi) << 8;

	pixelsize = fgetc(in);	/* discard bits/pixel and display order */
	fgetc(in);		/* assume top-down display order */

	if (pixelsize != 16 && pixelsize != 24 && pixelsize != 32)
	{
		printf("\nInvalid Targa File Pixel Size %d (must be 16,24,32) - Aborting!\n\n", pixelsize);
		fclose(in);             /* close all files */
		fclose(out);
		unlink(argv[2]);
		exit(1);
	}

	printf("Input file         = %s\n", argv[1]);	/* show stats */
	printf("Bits per pixel     = %d\n", pixelsize);
	printf("Output file        = %s\n", argv[2]);
	printf("Image X resolution = %d\n", xres);
	printf("Image Y resolution = %d\n", yres);

	printf("\nProcessing Line:   0");

	for (y = 0; y < yres; y++)	/* for every line in the in file */
	{
		printf("\b\b\b%3d", y);		/* disp. current line # */

		if (feof(in))			/* stop if file truncated */
		    break;

		fread(linbuf, 1, xres * (pixelsize/8), in); /* read a line */

		fputc(y & 0x00ff, out);		/* write line # out */
		fputc((y & 0xff00) >> 8, out);

		if (write_line(xres, out, pixelsize))
		{
		    printf("File output error on %s.  Disk Full?\n", argv[2]);
		    fclose(in);
		    fflush(out);
		    fclose(out);
		    exit(1);
		}
	}
	printf("\n");
	fclose(in);                                 /* close all files */
	fflush(out);
	fclose(out);
	exit(0);
}

write_line(xres, out, pixelsize)
int xres, pixelsize;
FILE *out;
{
	register int idx, x;
	register unsigned int tmp_byte;

	switch (pixelsize)	/* Pixel ordering for Targa-16/24/32 files */
	{
	    case 16:
		for (x = 0, idx = 1; x < xres; x++, idx += 2)
		    fputc((linbuf[idx] & 0x7C) << 1, out);  /* write Red */
		for (x = 0, idx = 0; x < xres; x++, idx += 2)
		{
		    tmp_byte = (linbuf[idx] & 0xE0) >> 2;
		    tmp_byte |= (linbuf[idx + 1] & 0x03) << 6;
		    fputc(tmp_byte, out);  /* write line of Green */
		}
		for (x = 0, idx = 0; x < xres; x++, idx += 2)
		    fputc((linbuf[idx] & 0x1F) << 3, out);  /* write Blue */
		break;
	    case 24:
		for (x = 0, idx = 2; x < xres; x++, idx += 3)
		    fputc(linbuf[idx], out);  /* write line of Red */
		for (x = 0, idx = 1; x < xres; x++, idx += 3)
		    fputc(linbuf[idx], out);  /* write line of Green */
		for (x = 0, idx = 0; x < xres; x++, idx += 3)
		    fputc(linbuf[idx], out);  /* write line of Blue */
		break;
	    case 32:
		for (x = 0, idx = 2; x < xres; x++, idx += 4)
		    fputc(linbuf[idx], out);  /* write line of Red */
		for (x = 0, idx = 1; x < xres; x++, idx += 4)
		    fputc(linbuf[idx], out);  /* write line of Green */
		for (x = 0, idx = 0; x < xres; x++, idx += 4)
		    fputc(linbuf[idx], out);  /* write line of Blue */
		break;
	}
	return(ferror(out));
}
