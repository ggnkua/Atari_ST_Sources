#pragma warn -use
static char	*sccsid = "@(#)PBMplus/pnm2tiff 1.21, Copyright (c) Jef Poskanzer, Dieter Linde, "__DATE__;
#pragma warn .use
/*
 * pnm2tiff.c - converts a portable anymap to a Tagged Image File
 *
 * Derived by Jef Poskanzer from ras2tif.c, which is:
 *
 * Copyright ½1990 by Sun Microsystems, Inc.
 *
 * Author: Patrick J. Naughton
 * naughton@wind.sun.com
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted,
 * provided that the above copyright notice appear in all copies and that
 * both that copyright notice and this permission notice appear in
 * supporting documentation.
 *
 * This file is provided AS IS with no warranties of any kind.  The author
 * shall have no liability with respect to the infringement of copyrights,
 * trade secrets or any patents by this file or any part thereof.  In no
 * event will the author be liable for any lost revenue or profits or
 * other special, indirect and consequential damages.
 */
#include "pnm.h"
#include "tiffio.h"

#ifdef	PPM
#include "..\ppm\ppmcmap.h"
#define MAXCOLORS	256
#endif 	/* PPM */

#define	COMPRESSION_UNDEF	0

/****************************************************************************
 *
 */
void
main(
	int  argc, 
     	char *argv[]
     	)
{
    	register int 		col;
    	register xel		*xP;
    	char			*scomp, *ids;
    	unsigned char		*buf, *tP;
    	int 			i, cols, rows, format, row, argn, grayscale, bytesperrow;
    	short 			photometric, samplesperpixel, bitspersample;
    	u_short			comp;
    	long 			rowsperstrip, colors;
    	xelval 			maxval;
    	FILE			*ifp;
    	xel			**xels;
    	TIFF			*tif;
#ifdef 	PPM
    	unsigned short 		red[MAXCOLORS], grn[MAXCOLORS], blu[MAXCOLORS];
    	colorhist_vector	chv;
    	colorhash_table 	cht;
#endif 	/* PPM */
    	char			*inf = NULL;
    	char			*usage = "[-none|-dump|-ccittrle|-rle|-ccittfax3|-fax3|-ccittfax4|-fax4|-ccittrlew|-rlew|-packbits|-lzw|-picio|-sgirle] [<pnmfile>]";

	pnm_init("pnm2tiff", &argc, argv);
	ids = getenv("TIFF_IMAGEDESCRIPTION");

    	argn = 1;
    	comp = COMPRESSION_UNDEF;

    	while (argn < argc && argv[argn][0] == '-' && argv[argn][1] != '\0') {
		if (pm_keymatch(argv[argn], "-none", 2) || pm_keymatch(argv[argn], "-dump", 2)) {
	    		if (comp != COMPRESSION_UNDEF)
				pm_error("only one compression method may be specified");
	    		comp = COMPRESSION_NONE;
	    		scomp = "none";
	    	}
		else if (pm_keymatch(argv[argn], "-ccittrle", 9) || pm_keymatch(argv[argn], "-rle", 4)) {
	    		if (comp != COMPRESSION_UNDEF)
				pm_error("only one compression method may be specified");
	    		comp = COMPRESSION_CCITTRLE;
	                scomp = "CCITT modified Huffman";
	    	}
		else if (pm_keymatch(argv[argn], "-ccittrlew", 10) || pm_keymatch(argv[argn], "-rlew", 5)) {
	    		if (comp != COMPRESSION_UNDEF)
				pm_error("only one compression method may be specified");
	    		comp = COMPRESSION_CCITTRLEW;
                	scomp = "CCITT modified Huffman w/ word alignment";
	    	}
		else if (pm_keymatch(argv[argn], "-ccittfax3", 10) || pm_keymatch(argv[argn], "-fax3", 5)) {
	    		if (comp != COMPRESSION_UNDEF)
				pm_error("only one compression method may be specified");
	    		comp = COMPRESSION_CCITTFAX3;
        	        scomp = "CCITT Group 3 facsimile";
	    	}
		else if (pm_keymatch(argv[argn], "-ccittfax4", 10) || pm_keymatch(argv[argn], "-fax4", 5)) {
	    		if (comp != COMPRESSION_UNDEF)
				pm_error("only one compression method may be specified");
	    		comp = COMPRESSION_CCITTFAX4;
                        scomp = "CCITT Group 4 facsimile";
	    	}
		else if (pm_keymatch(argv[argn], "-packbits", 3)) {
	    		if (comp != COMPRESSION_UNDEF)
				pm_error("only one compression method may be specified");
	    		comp = COMPRESSION_PACKBITS;
        	        scomp = "Macintosh PackBits";
	    	}
		else if (pm_keymatch(argv[argn], "-lzw", 2)) {
	    		if (comp != COMPRESSION_UNDEF)
				pm_error("only one compression method may be specified");
	    		comp = COMPRESSION_LZW;
	                scomp = "Lempel-Ziv & Welch";
	    	}
		else if (pm_keymatch(argv[argn], "-picio", 3)) {
	    		if (comp != COMPRESSION_UNDEF)
				pm_error("only one compression method may be specified");
	    		comp = COMPRESSION_PICIO;
	                scomp = "Pixar picio";
	    	}
		else if (pm_keymatch(argv[argn], "-sgirle", 2)) {
	    		if (comp != COMPRESSION_UNDEF)
				pm_error("only one compression method may be specified");
	    		comp = COMPRESSION_SGIRLE;
			scomp = "Silicon Graphics run-length";
	    	}
		else
	    		pm_usage(usage);
		argn++;
	}
    	if (comp == COMPRESSION_UNDEF) {
    		comp = COMPRESSION_NONE;
    		scomp = "none";
    	}

    	if (argn != argc) {
        	inf = argv[argn];
        	ifp = pm_openr(inf);
		argn++;
	}
	else {
        	inf = "stdin";
        	ifp = stdin;
		if (setvbuf(ifp, NULL, _IOFBF, stdbufsize))
                	pm_error("out of memory allocating a filebuffer");
		fsetmode(ifp, IO_BINARY);
		fclrmode(ifp, IO_NBF);
	}
    	if (argn != argc)
		pm_usage(usage);

    	xels = pnm_readpnm(ifp, &cols, &rows, &maxval, &format);
    	pm_close(ifp);

	/* 
	 * Check for grayscale. 
	 */
    	switch (PNM_FORMAT_TYPE(format)) {

#ifdef 	PPM
        	case PPM_TYPE:
        		pm_message("computing colormap...");
        		if ((chv = ppm_computecolorhist(xels, cols, rows, MAXCOLORS, &colors)) == NULL) {
            			pm_message("too many colors -- proceeding to write a 24-bit RGB file.");
            			pm_message("If you want an 8-bit palette file, try doing a \"ppmquant %d\".", MAXCOLORS);
            			grayscale = 0;
            		}
        		else {
            			pm_message("%ld colors found", colors);
            			grayscale = 1;
            			for (i = 0; i < colors; i++) {
                			register xelval	r, g, b;

                			r = PPM_GETR(chv[i].color);
                			g = PPM_GETG(chv[i].color);
                			b = PPM_GETB(chv[i].color);
                			if (r != g || g != b) {
                    				grayscale = 0;
                    				break;
                    			}
                		}
            		}
        		break;
#endif 	/* PPM */

        	default:
        		grayscale = 1;
        		break;
        }

 	/* 
	 * Open output file. 
	 */

	pm_message("using encoding method \'%s\'", scomp);

    	if ((tif = TIFFFdOpen(1, "stdout", "wb")) == NULL)
        	pm_error("error opening stdout as TIFF file");

	/* 
	 * Figure out TIFF parameters. 
	 */
    	switch (PNM_FORMAT_TYPE(format)) {

#ifdef 	PPM
        	case PPM_TYPE:
        		if (chv == NULL) {
            			samplesperpixel = 3;
            			bitspersample = 8;
            			photometric = PHOTOMETRIC_RGB;
            			bytesperrow = cols * 3;
            		}
        		else if (grayscale) {
            			samplesperpixel = 1;
            			bitspersample = pm_maxvaltobits(maxval);
            			photometric = PHOTOMETRIC_MINISBLACK;
            			bytesperrow = (cols + i - 1) / i;
            		}
        		else {
            			samplesperpixel = 1;
            			bitspersample = 8;
            			photometric = PHOTOMETRIC_PALETTE;
            			bytesperrow = cols;
            		}
        		break;
#endif 	/* PPM */

#ifdef 	PGM
        	case PGM_TYPE:
        		samplesperpixel = 1;
        		bitspersample = pm_maxvaltobits(maxval);
        		photometric = PHOTOMETRIC_MINISBLACK;
        		i = 8 / bitspersample;
        		bytesperrow = (cols + i - 1) / i;
        		break;
#endif 	/* PGM */

        	default:
        		samplesperpixel = 1;
        		bitspersample = 1;
        		photometric = PHOTOMETRIC_MINISBLACK;
        		bytesperrow = (cols + 7) / 8;
        		break;
        }
    	rowsperstrip = (8 * 1024) / bytesperrow;
    	if ((buf = (unsigned char *)malloc(bytesperrow)) == NULL)
        	pm_error("out of memory allocating row buffer");

	/* 
	 * Set TIFF parameters. 
	 */
    	TIFFSetField(tif, TIFFTAG_IMAGEWIDTH, cols);
    	TIFFSetField(tif, TIFFTAG_IMAGELENGTH, rows);
    	TIFFSetField(tif, TIFFTAG_BITSPERSAMPLE, bitspersample);
    	TIFFSetField(tif, TIFFTAG_ORIENTATION, ORIENTATION_TOPLEFT);
    	TIFFSetField(tif, TIFFTAG_COMPRESSION, comp);
    	TIFFSetField(tif, TIFFTAG_PHOTOMETRIC, photometric);
    	TIFFSetField(tif, TIFFTAG_DOCUMENTNAME, inf);
	if (ids != NULL)
	    	TIFFSetField(tif, TIFFTAG_IMAGEDESCRIPTION, ids);
    	TIFFSetField(tif, TIFFTAG_SAMPLESPERPIXEL, samplesperpixel);
    	TIFFSetField(tif, TIFFTAG_ROWSPERSTRIP, rowsperstrip);
    	TIFFSetField(tif, TIFFTAG_STRIPBYTECOUNTS, rows / rowsperstrip);
    	TIFFSetField(tif, TIFFTAG_PLANARCONFIG, PLANARCONFIG_CONTIG);

#ifdef 	PPM
    	if (chv == NULL)
        	cht = NULL;
    	else {

	/* 
	 * Make TIFF colormap. 
	 */
        	for (i = 0; i < colors; i++) {
            		red[i] = (long)PPM_GETR(chv[i].color) * 65535L / maxval;
            		grn[i] = (long)PPM_GETG(chv[i].color) * 65535L / maxval;
            		blu[i] = (long)PPM_GETB(chv[i].color) * 65535L / maxval;
            	}
        	TIFFSetField(tif, TIFFTAG_COLORMAP, red, grn, blu);

	/* 
	 * Convert color vector to color hash table, for fast lookup. 
	 */
        	cht = ppm_colorhisttocolorhash(chv, colors);
        	ppm_freecolorhist(chv);
      	}
#endif 	/* PPM */

	/* 
	 * Now write the TIFF data. 
	 */
    	for (row = 0; row < rows; row++) {

#ifdef 	PPM
        	if (PNM_FORMAT_TYPE(format) == PPM_TYPE && !grayscale) {
            		if (cht == NULL) {
                		for (col = 0, xP = xels[row], tP = buf; col < cols; col++, xP++) {
                    			register unsigned char	s;

                    			s = PPM_GETR(*xP);
                    			if (maxval != 255)
                        			s = (long)s * 255 / maxval;
                    			*tP++ = s;
                    			s = PPM_GETG(*xP);
                    			if (maxval != 255)
                        			s = (long)s * 255 / maxval;
                    			*tP++ = s;
                    			s = PPM_GETB(*xP);
                    			if (maxval != 255)
                        			s = (long)s * 255 / maxval;
                    			*tP++ = s;
                    		}
                	}
            		else {
                		for (col = 0, xP = xels[row], tP = buf; col < cols; col++, xP++) {
                    			register long	s;

                    			s = ppm_lookupcolor(cht, xP);
                    			if (s == -1)
                        			pm_error("color not found?!? (row=%d, col=%d, r=%d, g=%d, b=%d)", row, col, PPM_GETR(*xP), PPM_GETG(*xP), PPM_GETB(*xP));
                    			*tP++ = (unsigned char)s;
                    		}
                	}
            	}
        	else
#endif	/* PPM */
            	{
            		register xelval		bigger_maxval;
            		register int 		bitshift;
            		register unsigned char	byte;
            		register xelval 	s;

            		bigger_maxval = pm_bitstomaxval(bitspersample);
            		bitshift = 8 - bitspersample;
            		byte = 0;
            		for (col = 0, xP = xels[row], tP = buf; col < cols; col++, xP++) {
                		s = PNM_GET1(*xP);
                		if (maxval != bigger_maxval)
                    			s = (long)s * bigger_maxval / maxval;
                		byte |= (s << bitshift);
                		bitshift -= bitspersample;
                		if (bitshift < 0) {
                    			*tP++ = byte;
                    			bitshift = 8 - bitspersample;
                    			byte = 0;
                    		}
                	}
            		if (bitshift != 8 - bitspersample)
                		*tP++ = byte;
            	}

        	if (TIFFWriteScanline(tif, buf, row, 0) < 0)
            		pm_error("failed a scanline write on row %d", row);
       	}
    	TIFFFlushData(tif);
    	TIFFClose(tif);

	fflush(stdout);
    	exit(0);
}
