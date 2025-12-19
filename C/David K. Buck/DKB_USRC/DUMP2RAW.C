/**********************************************************

DUMP2RAW.C  - Converts a DKB/QRT "Dump" format raw file to
	      PICLAB's "raw" format, which is 3 files of
	      8-Bit pixel data named .R8, .B8, and .G8.
	      On the Amiga, names are .red, .grn, and .blu.
	      By Aaron A. Collins, written on 6/30/90

	      This file is released to the Public Domain.

	      PICLAB is a trademark of The Stone Soup Group.
			  
 ***********************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

#define MAXXRES 2048   /* huge max x resolution allowable, infinite y res. */

unsigned char linbuf[MAXXRES * 3];

void main(argc,argv)
int argc;
char *argv[];
{
	int xres, yres, xhi, yhi, noext = FALSE;
	register int x, y;
	char inname[80], rname[80], bname[80], gname[80], tmpname[80];
	FILE *in, *rout, *bout, *gout;

	printf("\n\nDKB/QRT Image File to Raw R-G-B Files Converter\n");
	printf("By Aaron A. Collins.  Written 6/30/90\n\n");

	if (argc < 2)
	{
		printf("Usage: %s InFile[.DIS]\n\n",argv[0]);
		exit(1);
	}

	strcpy(inname, argv[1]);	  /* get input filename */

	strcpy(tmpname, inname);
	strupr(tmpname);		/* Cvt to uppercase */
	if (!strstr(tmpname, ".DIS"))	/* if user didn't supply .DIS ext, */
		if (!strchr(tmpname, '.'))  /* AND didn't supply ANY ext */
		{
			noext = TRUE;
			strcat(inname, ".DIS");
		}

	if ((in = fopen(inname, "rb")) == NULL)  /* try w/supplied ext. */
	{
		printf("ERROR - Couldn't open file %s\n", inname);
		exit(1);
	}

	if (noext)
	{
		strcpy(rname, argv[1]);		/* copy name w/no extension */
		strcpy(gname, argv[1]);
		strcpy(bname, argv[1]);
	}
	else
	{
		strcpy(tmpname, argv[1]);	/* Get Input Filename */
		strupr(tmpname);		/* Cvt to uppercase */
		*strchr(tmpname, '.') = '\0';	/* Find the Dot + Truncate */
		strcpy(rname, tmpname);		/* copy name w/no extension */
		strcpy(gname, tmpname);
		strcpy(bname, tmpname);
	}

#ifdef IBM
	strcat(rname, ".r8");
	strcat(gname, ".g8");
	strcat(bname, ".b8");
#else
	strcat(rname, ".red");
	strcat(gname, ".grn");
	strcat(bname, ".blu");
#endif
	
	if ((rout = fopen(rname, "wb")) == NULL)
	{
		printf("ERROR - Couldn't create file %s\n", rname);
		fclose(in);
		exit(1);
	}

	if ((gout = fopen(gname, "wb")) == NULL)
	{
		printf("ERROR - Couldn't create file %s\n", gname);
		fclose(in);
		fclose(rout);
		exit(1);
	}

	if ((bout = fopen(bname, "wb")) == NULL)
	{
		printf("ERROR - Couldn't create file %s\n", bname);
		fclose(in);
		fclose(rout);
		fclose(gout);
		exit(1);
	}

	/** load x and y resolution from input DUMP file **/

	xres = fgetc(in);			/* lo order */
	xhi = fgetc(in);			/* hi order */
	xres += ((unsigned int) xhi) << 8;
	
	if (xres > MAXXRES)			/* too big? */
	{
		printf("ERROR - X res. of %s (%d) exceeds maximum (%d)!\n", inname, xres, MAXXRES);
		fclose(in);			/* close all files */
		fclose(rout);
		fclose(gout);
		fclose(bout);
		unlink(rname);		/* delete empty out files */
		unlink(gname);
		unlink(bname);
		exit(1);
	}

	yres = fgetc(in);			/* now do yres the same... */
	yhi = fgetc(in);
	yres += ((unsigned int) yhi) << 8;

	printf("Input file         = %s\n", inname);	/* show stats */
	printf("Output files       = %s\n", rname);
	printf("                     %s\n", gname);
	printf("                     %s\n\n", bname);
	printf("Image X resolution = %d\n", xres);
	printf("Image Y resolution = %d\n", yres);

	printf("\nProcessing Line:   0");

	for (y = 0; y < yres; y++)	/* for every line in the old file */
	{

		printf("\b\b\b%3d", y);		/* disp. current line # */

		fread(linbuf, 1, 2, in);	/* read in line number */

		if (feof(in))			/* stop if file truncated */
			break;

		for (x = 0; x < 3; x++)
		{
			fread(linbuf, 1, xres, in); /* read a line's data */

			if (feof(in))		/* stop if file truncated */
				break;

			switch (x)
			{
				case 0:
					fwrite(linbuf, 1, xres, rout);
					break;
				case 1:
					fwrite(linbuf, 1, xres, gout);
					break;
				case 2:
					fwrite(linbuf, 1, xres, bout);
					break;
			}
		}
	}
	printf("\n");
	fclose(in);                                 /* close all files */
	fflush(rout);
	fflush(gout);
	fflush(bout);
	fclose(rout);
	fclose(gout);
	fclose(bout);
	exit(0);
}
