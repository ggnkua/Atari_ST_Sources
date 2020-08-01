#pragma warn -use
static char 	*sccsid = "@(#)TIFF/tiffinfo.c 1.30, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
#pragma warn .use
/*
 * Copyright (c) 1988 by Sam Leffler, Apr 25 1989
 * All rights reserved.
 *
 * This file is provided for unrestricted use provided that this legend is included on all tape media and as a part of the
 * software program in whole or part.  Users may copy, modify or distribute this file at will.
 */
#include <stdio.h>
#include <stdlib.h>
#include <lin.h>
#include "tiffio.h"

static char	*progname;
static int	showcolormap = 0;		/* show colormap entries if present */
static int	showresponsecurves = 0;		/* show response curve[s] if present */
static int	showstrips = 0;			/* show strip offsets and sizes */
static int	showdata = 0;			/* show data */
static int	readdata = 0;			/* read data in file */

/****************************************************************************
 *
 */
static void
usage(
	int 	code
	)
{
	fprintf(stderr, "usage: %s [-Ddcs] [-<n>] <tifffiles>\n", progname);
	fputs("\t-D   read data\n", stderr);
	fputs("\t-d   show data\n", stderr);
	fputs("\t-c   show color/gray response curves and colormap\n", stderr);
	fputs("\t-s   show data strip offsets and byte counts\n", stderr);
	fputs("\t-<n> show directory number <n>\n", stderr);
	exit(code);
}

/****************************************************************************
 *
 */
static void
Show(
	int    	row,
     	int    	sample,
     	u_char	*pp,
     	int    	scanline
     	)
{
	register int	cc;

	printf("[%3d", row);
	if (sample > 0)
		printf(",%d", sample);
	printf("]");
	for (cc = 0; cc < scanline; cc++) {
		printf(" %02x", *pp++);
		if (((cc + 1) % 24) == 0)
			putchar('\n');
	}
	putchar('\n');
}

/****************************************************************************
 *
 */
static void
TIFFInfo(
	TIFF 	*tif
	)
{
	u_char 	*scanbuf;
	u_short	config, h;
	int 	s, row, scanline;

	TIFFPrintDirectory(tif, stdout, showstrips, showcolormap, showresponsecurves);
	if (!readdata)
		return;
	TIFFGetField(tif, TIFFTAG_PLANARCONFIG, &config);
	if ((scanbuf = (u_char *)malloc(scanline = TIFFScanlineSize(tif))) == NULL) {
		fprintf(stderr, "%s: out of memory allocating scanline buffer\n", progname);
		return;
	}
	TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &h);
	if (config == PLANARCONFIG_CONTIG) {
		for (row = 0; row < h; row++) {
			if (TIFFReadScanline(tif, scanbuf, row, 0) < 0)
				break;
			if (showdata)
				Show(row, -1, scanbuf, scanline);
		}
	}
	else {
		u_short	samplesperpixel;

		TIFFGetField(tif, TIFFTAG_SAMPLESPERPIXEL, &samplesperpixel);
		for (s = 0; s < samplesperpixel; s++)
			for (row = 0; row < h; row++) {
				if (TIFFReadScanline(tif, scanbuf, row, s) < 0)
					goto done;
				if (showdata)
					Show(row, s, scanbuf, scanline);
			}
done:
		;
	}
	free(scanbuf);
}

/****************************************************************************
 *
 */
void
main(
	int  	argc,
     	char 	*argv[]
     	)
{
	int 	dirnum = -1;
	int	multiplefiles;
	char 	*cp;
	TIFF 	*tif;

        progname = ((int)strlen(argv[0]) == 0) ? "tiffinfo" : argv[0];

	argc--;
	argv++;
	while (argc > 0 && argv[0][0] == '-') {
		for (cp = &argv[0][1]; *cp; cp++)
			switch (*cp) {
				case '0':
				case '1':
				case '2':
				case '3':
				case '4':
				case '5':
				case '6':
				case '7':
				case '8':
				case '9':
					dirnum = atoi(cp);
					goto next;
				case 'd':
					showdata++;
				case 'D':
					readdata++;
					break;
				case 'c':
					showcolormap++;
					showresponsecurves++;
					break;
				case 's':
					showstrips++;
					break;
				default:
					usage(-1);
				/* NOTREACHED */
			}
next:
		argc--;
		argv++;
	}
	if (argc <= 0)
		usage(-2);
	for (multiplefiles = argc > 1; argc > 0; argc--, argv++) {
		if (multiplefiles)
			printf("%s:\n", argv[0]);
		tif = TIFFOpen(argv[0], "r");
		if (tif != NULL) {
			if (dirnum == -1) {
				do
					TIFFInfo(tif);
				while (TIFFReadDirectory(tif));
			}
			else {
				if (TIFFSetDirectory(tif, dirnum))
					TIFFInfo(tif);
			}
			TIFFClose(tif);
		}
	}
	exit(0);
}
