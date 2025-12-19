/***************************************************************

TGA2DUMP.C  - Converts a Targa-16/24/32 file to a Targa-16/24/32
						  file by swapping the red and blue Components.
						  Its useful for Calamus SL for the ST/TT in one of
						  the first Versions.

	      Version 1.0 By Norbert Marschalleck, written on 23/11/91

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

int read_line(int, FILE *);
int write_line(int, FILE *);

unsigned char linbuf[3][MAXXRES];

void main(int argc, char **argv)
{
	register int xres, yres, xhi, yhi;
	register int y, pixelsize, filetype;
	FILE *in, *out;

	printf("\n\nTarga-16/24/32 Image File to Targa-16/24/32 Image File Converter\n");
	printf("by swapping the red and blue Components\n");
	printf("Version 1.0  By Norbert Marschalleck.  Written 23/11/91 \n\n");
	if(argc != 3)
	 {
		printf("Usage: %s InputFile OutputFile\n\n",argv[0]);
		exit(1);
	 }
	if((in = fopen(argv[1], "rb")) == NULL)  /* try opening input file */
	 {
		printf("ERROR - Couldn't open file %s\n", argv[1]);
		exit(1);
	 }
	if((out = fopen(argv[2], "wb")) == NULL)
	 {
		printf("ERROR - Couldn't create file %s\n", argv[2]);
		fclose(in);
		exit(1);
	 }
	/** absorb 1st part of Targa header **/
	fputc(fgetc(in),out);		/* absorb 2 0's */
	fputc(fgetc(in),out);
	if((filetype = fgetc(in)) != 2) /* Uncompressed, Unmapped TGA only */
	 {
		printf("\nInvalid Targa File Type %d (Must be 2) - Aborting!\n\n", filetype);
		fclose(in);             /* close all files */
		fclose(out);
		unlink(argv[2]);
		exit(1);
	 }
	fputc(2,out);
	for(y = 0; y < 9; y++)	/* discard 7 0's and file X/Y origin */
   fputc(fgetc(in),out);
	/** load x and y resolution from input Targa file while copying **/
	xres = fputc(fgetc(in), out);	/* lo order */
	xhi = fputc(fgetc(in), out);	/* hi order */
	xres += ((unsigned int) xhi) << 8;
	if(xres > MAXXRES)			/* too big? */
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
	fputc(pixelsize,out);
	fputc(fgetc(in), out);		/* assume top-down display order */
	if(pixelsize != 16 && pixelsize != 24 && pixelsize != 32)
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
	for(y = 0; y < yres; y++)	/* for every line in the in file */
	 {
		printf("\b\b\b%3d", y);		/* disp. current line # */
		if(feof(in))			/* stop if file truncated */
		 break;
    read_line(xres,in);
    write_line(xres,out);
/*	 if(read_line(xres,in) == 0)
		{
	   printf("File input error on %s.  Disk Error ?\n", argv[1]);
	   fclose(in);
	   fflush(out);
	   fclose(out);
	   exit(1);
		}
	 if(write_line(xres,out) == 0)
		{
	   printf("File output error on %s.  Disk Full ?\n", argv[2]);
	   fclose(in);
	   fflush(out);
	   fclose(out);
	   exit(1);
		} */
	 }
	printf("\n");
	fclose(in);                                 /* close all files */
	fflush(out);
	fclose(out);
	exit(0);
}

int read_line(int xres, FILE *in_file)
{
 register int x;

 for(x = 0; x < xres; x++)
  {
   linbuf[0][x] = fgetc(in_file);  /* read Red */
   linbuf[1][x] = fgetc(in_file);  /* read Green */
   linbuf[2][x] = fgetc(in_file);  /* read Blue */
  }
 return(ferror(in_file));
}

int write_line(int xres, FILE *out_file)
{
 register int x;

 for(x = 0; x < xres; x++)
  {
   fputc(linbuf[2][x], out_file);  /* write Blue */
   fputc(linbuf[1][x], out_file);  /* write Green */
   fputc(linbuf[0][x], out_file);  /* write Red */
  }
 return(ferror(out_file));
}
