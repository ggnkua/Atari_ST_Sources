/***************************************************************

DUMP2TGA.C  - Converts a DKB/QRT "Dump"
	      format raw file to a Targa-16/24/32 file.

	      Version 1.0 By Norbert Marschalleck, written on 13/10/91

	      This file is released to the Public Domain.
	      It based on TGA2DUMP from A. Collins

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

void main(argc,argv)
int argc;
char *argv[];
{
 register int xres, yres, xhi, yhi, y_tmp_line,y_tmp_hi;
 register int y;
 FILE *in, *out;

 printf("\n\nDKB/QRT Dump Format to Targa-16/24/32 Image File Converter\n");
 printf("Version 1.0  By Norbert Marschalleck.  Written 13/10/91\n\n");
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
 /** 1st part of Targa header **/
 fputc(0,out);  /* Lenght of Header */
 fputc(0,out);  /* ColorMapType = 1*/
 fputc(2,out);  /* uncompressed Targa-Format */
 for(y = 0; y < 9; y++)	/* put 7 0's and file X/Y origin at pos 0000*/
  fputc('\0',out);
 xres = fputc(fgetc(in), out); /* get xres */
 xhi = fputc(fgetc(in), out);
 xres += ((unsigned int) xhi) << 8;
 yres = fputc(fgetc(in), out); /* now do yres the same... */
 yhi = fputc(fgetc(in), out);
 yres += ((unsigned int) yhi) << 8;
 if(xres > MAXXRES)			/* too big? */
  {
	 printf("ERROR - X res. of %s (%d) exceeds maximum (%d)!\n", argv[1], xres, MAXXRES);
	 fclose(in);			/* close all files */
	 fclose(out);
	 unlink(argv[2]);		/* delete empty out files */
	 exit(1);
  }
 fputc(24,out); /* 24 Bits per Pixel */
 fputc(32,out); /* Top-Down raster */

 printf("Input file         = %s\n", argv[1]);	/* show stats */
 printf("Output file        = %s\n", argv[2]);
 printf("Image X resolution = %d\n", xres);
 printf("Image Y resolution = %d\n", yres);
 printf("\nProcessing Line:   0");
 for(y = 0; y < yres; y++)	  /* for every line in the in file */
	{
	 printf("\b\b\b%3d", y);		/* disp. current line # */
	 if(feof(in))			          /* stop if file truncated */
		break;
   y_tmp_line = fgetc(in); /* get Line Number */
   y_tmp_hi = fgetc(in);
   y_tmp_line += ((unsigned int) y_tmp_hi) << 8;
   if(y_tmp_line != y)
    {
     printf("\nError: Line Number in File != processing Line !\n");
		 fclose(in); /* close all files */
		 fclose(out);
		 unlink(argv[2]);		/* delete empty out files */
		 exit(1);
    }
   read_line(xres,in);
   write_line(xres,out);
/*	 if(read_line(xres,in))
		{
	   printf("File input error on %s.  Disk Error ?\n", argv[1]);
	   fclose(in);
	   fflush(out);
	   fclose(out);
	   exit(1);
		}
	 if(write_line(xres,in))
		{
	   printf("File output error on %s.  Disk Full ?\n", argv[2]);
	   fclose(in);
	   fflush(out);
	   fclose(out);
	   exit(1);
		} */
  }
 printf("\n");
 fclose(in); /* close all files */
 fflush(out);
 fclose(out);
 exit(0);
}

int read_line(int xres, FILE *in_file)
{
 register int x;

 for(x = 0; x < xres; x++)
  linbuf[0][x] = fgetc(in_file);  /* read line of Red */
 for(x = 0; x < xres; x++)
	linbuf[1][x] = fgetc(in_file);  /* read line of Green */
 for (x = 0; x < xres; x++)
	linbuf[2][x] = fgetc(in_file);  /* read line of Blue */
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
