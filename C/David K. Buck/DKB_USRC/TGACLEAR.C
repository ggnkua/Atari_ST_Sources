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
	register int y, pixelsize;
	FILE *out;

	printf("\n\nTarga-16/24/32 Image File Creater\n");
	printf("Version 1.0  By Norbert Marschalleck.  Written 23/11/91 \n\n");
	if(argc != 4)
	 {
		printf("Usage: %s OutputFile width height \n\n",argv[0]);
		exit(1);
	 }
	if((out = fopen(argv[1], "wb")) == NULL)
	 {
		printf("ERROR - Couldn't create file %s\n", argv[1]);
		fclose(out);
		exit(1);
	 }
	if((xres = atoi(argv[2])) > MAXXRES) 
	 {
	  printf("ERROR - X res. (%d) exceeds maximum (%d)!\n", xres, MAXXRES);
	  fclose(out);
	  unlink(argv[1]);		/* delete empty out files */
	  exit(1);
	 }
	yres = atoi(argv[3]);
	/** 1st part of Targa header **/
	fputc(0,out);		/* write 2 0's */
	fputc(0,out);
	fputc(2,out);
	for(y = 0; y < 9; y++)	/* discard 7 0's and file X/Y origin */
   fputc(0,out);
	/** load x and y resolution from input Targa file while copying **/
	xhi = ((unsigned int) xres) >> 8;
	fputc(xres, out);	/* lo order */
	fputc(xhi, out);	/* hi order */
	yhi = ((unsigned int) yres) >> 8;
	fputc(yres, out);	/* lo order */
	fputc(yhi, out);	/* hi order */
	pixelsize = fputc(24,out); /* Assume 24 Bits per Pixel */
  fputc(32,out); /* Top-Down raster */
	printf("Bits per pixel     = %d\n", pixelsize);
	printf("Output file        = %s\n", argv[1]);
	printf("Image X resolution = %d\n", xres);
	printf("Image Y resolution = %d\n", yres);
	printf("\nProcessing Line:   0");
	for(y = 0; y < xres; y++)
	 {
	  linbuf[0][y] = 0xFF;
	  linbuf[1][y] = 0xFF;
	  linbuf[2][y] = 0xFF;
	 }
	for(y = 0; y < yres; y++)	/* for every line in the in file */
	 {
		printf("\b\b\b%3d", y);		/* disp. current line # */
    write_line(xres,out);
/*	 if(write_line(xres,out) == 0)
		{
	   printf("File output error on %s.  Disk Full ?\n", argv[2]);
	   fclose(in);
	   fflush(out);
	   fclose(out);
	   exit(1);
		} */
	 }
	printf("\n");
	fflush(out);
	fclose(out);
	exit(0);
}

int write_line(int xres, FILE *out_file)
{
 register int x;

 for(x = 0; x < xres; x++)
  {
   fputc(linbuf[0][x], out_file);  /* write Red */
   fputc(linbuf[1][x], out_file);  /* write Green */
   fputc(linbuf[2][x], out_file);  /* write Blue */
  }
 return(ferror(out_file));
}
