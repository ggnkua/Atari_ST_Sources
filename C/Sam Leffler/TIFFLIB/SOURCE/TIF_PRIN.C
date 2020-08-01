#pragma warn -use
static char 	*sccsid = "@(#)TIFF/tif_print.c 1.23, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
#pragma warn .use
/*
 * Copyright (c) 1988, 1990 by Sam Leffler, Oct 8 1990
 * All rights reserved.
 *
 * This file is provided for unrestricted use provided that this legend is included on all tape media and as a part of the
 * software program in whole or part.  Users may copy, modify or distribute this file at will.
 *
 * TIFF Library.
 *
 * Directory Printing Support
 */
#include <stdio.h>
#include <stdlib.h>
#include "tiffio.h"

#define FIELD(tif, f)	TIFFFieldSet(tif, f)

static char	*ResponseUnitNames[] = {
        		"#0",
		        "10ths",
		        "100ths",
		        "1,000ths",
		        "10,000ths",
		        "100,000ths",
		};
static float	ResponseUnit[] = { 1.0, 0.1, 0.01, 0.001, 0.0001, 0.00001 };

#define	MAXRESPONSEUNIT	(sizeof(ResponseUnitNames) / sizeof(ResponseUnitNames[0]))

/****************************************************************************
 * Print the contents of the current directory to the specified stdio file stream.
 */
void
TIFFPrintDirectory(
       	TIFF 	*tif,
        FILE 	*fd,
        int 	showstrips, 
        int	showresponsecurve, 
        int	showcolormap
        )
{
        register TIFFDirectory	*td;
        char 			sep;
        int 			i;
        long 			n;
        float 			unit;

        fprintf(fd, "TIFF Directory at offset 0x%08x\n", tif->tif_diroff);
        td = &tif->tif_dir;
        if (FIELD(tif, FIELD_SUBFILETYPE)) {
                fputs("  Subfile Type..............:", fd);
                sep = ' ';
                if (td->td_subfiletype & FILETYPE_REDUCEDIMAGE) {
                	fputc(sep, fd);
                        fputs("reduced-resolution image", fd);
                        sep = '/';
                }
                if (td->td_subfiletype & FILETYPE_PAGE) {
                	fputc(sep, fd);
                        fputs("multi-page document", fd);
                        sep = '/';
                }
                if (td->td_subfiletype & FILETYPE_MASK) {
                	fputc(sep, fd);
                        fputs("transparency mask", fd);
                }
                fprintf(fd, " (%u = 0x%04x)\n", td->td_subfiletype, td->td_subfiletype);
        }
        if (FIELD(tif, FIELD_IMAGEDIMENSIONS)) {
                fprintf(fd, "  Image Width...............: %u\n", td->td_imagewidth);
                fprintf(fd, "  Image Length..............: %u\n", td->td_imagelength);
        }
        if (FIELD(tif, FIELD_RESOLUTION)) {
                fprintf(fd, "  Resolution................: %f, %f", td->td_xresolution, td->td_yresolution);
                if (FIELD(tif, FIELD_RESOLUTIONUNIT)) {
                        switch (td->td_resolutionunit) {
	                        case RESUNIT_NONE:
        	                        fputs(" (unitless)", fd);
                	                break;
                        	case RESUNIT_INCH:
                                	fputs(" pixels/inch", fd);
	                                break;
        	                case RESUNIT_CENTIMETER:
                	                fputs(" pixels/cm", fd);
                        	        break;
	                        default:
        	                        fprintf(fd, " (unit %u = 0x%04x)", td->td_resolutionunit, td->td_resolutionunit);
	                                break;
                        }
                }
                fputc('\n', fd);
        }
        if (FIELD(tif, FIELD_POSITION))
               	fprintf(fd, "  Position..................: %f, %f\n", td->td_xposition, td->td_yposition);
        if (FIELD(tif, FIELD_BITSPERSAMPLE))
                fprintf(fd, "  Bits/Sample...............: %u\n", td->td_bitspersample);
        if (FIELD(tif, FIELD_COMPRESSION)) {
                fputs("  Compression Scheme........: ", fd);
                switch (td->td_compression) {
	                case COMPRESSION_NONE:
        	                fputs("none\n", fd);
                	        break;
	                case COMPRESSION_CCITTRLE:
        	                fputs("CCITT modified Huffman encoding\n", fd);
	                        break;
        	        case COMPRESSION_CCITTFAX3:
                	        fputs("CCITT Group 3 facsimile encoding\n", fd);
	                        break;
        	        case COMPRESSION_CCITTFAX4:
	                        fputs("CCITT Group 4 facsimile encoding\n", fd);
        	                break;
                	case COMPRESSION_CCITTRLEW:
                        	fputs("CCITT modified Huffman encoding w/ word alignment\n", fd);
	                        break;
        	        case COMPRESSION_PACKBITS:
                	        fputs("Macintosh PackBits encoding\n", fd);
                        	break;
	                case COMPRESSION_THUNDERSCAN:
        	                fputs("ThunderScan 4-bit encoding\n", fd);
                	        break;
	                case COMPRESSION_LZW:
        	                fputs("Lempel-Ziv & Welch encoding\n", fd);
                	        break;
	                case COMPRESSION_PICIO:
        	                fputs("Pixar picio encoding\n", fd);
                	        break;
	                case COMPRESSION_NEXT:
        	                fputs("NeXT 2-bit encoding\n", fd);
                	        break;
			case COMPRESSION_SGIRLE:
				fputs("Silicon Graphics run-length encoding\n", fd);
				break;
	                default:
        	                fprintf(fd, "%u (0x%04x)\n", td->td_compression, td->td_compression);
	                        break;
                }
        }
        if (FIELD(tif, FIELD_PHOTOMETRIC)) {
                fputs("  Photometric Interpretation: ", fd);
                switch (td->td_photometric) {
	                case PHOTOMETRIC_MINISWHITE:
        	                fputs("min-is-white\n", fd);
                	        break;
	                case PHOTOMETRIC_MINISBLACK:
        	                fputs("min-is-black\n", fd);
                	        break;
	                case PHOTOMETRIC_RGB:
        	                fputs("RGB color\n", fd);
                	        break;
	                case PHOTOMETRIC_PALETTE:
        	                fputs("palette color (RGB from colormap)\n", fd);
                	        break;
	                case PHOTOMETRIC_MASK:
        	                fputs("transparency mask\n", fd);
                	        break;
	                default:
        	                fprintf(fd, "%u (0x%04x)\n", td->td_photometric, td->td_photometric);
	                        break;
                }
        }
        if (FIELD(tif, FIELD_MATTEING))
                fprintf(fd, "  Matteing..................: %s\n", td->td_matteing ? "pre-multiplied with alpha channel" : "none");
        if (FIELD(tif, FIELD_THRESHHOLDING)) {
                fputs("  Thresholding..............: ", fd);
                switch (td->td_threshholding) {
	                case THRESHHOLD_BILEVEL:
        	                fputs("bilevel art scan\n", fd);
                	        break;
	                case THRESHHOLD_HALFTONE:
        	                fputs("halftone or dithered scan\n", fd);
                	        break;
	                case THRESHHOLD_ERRORDIFFUSE:
        	                fputs("error diffused\n", fd);
                	        break;
	                default:
        	                fprintf(fd, "%u (0x%04x)\n", td->td_threshholding, td->td_threshholding);
	                        break;
                }
        }
        if (FIELD(tif, FIELD_FILLORDER)) {
                fputs("  Fillorder.................: ", fd);
                switch (td->td_fillorder) {
	                case FILLORDER_MSB2LSB:
        	                fputs("msb-to-lsb\n", fd);
                	        break;
	                case FILLORDER_LSB2MSB:
        	                fputs("lsb-to-msb\n", fd);
                	        break;
	                default:
        	                fprintf(fd, "%u (0x%04x)\n", td->td_fillorder, td->td_fillorder);
	                        break;
                }
        }
        if (FIELD(tif, FIELD_PREDICTOR)) {
                fputs("  Predictor.................: ", fd);
                switch (td->td_predictor) {
	                case 1:
        	                fputs("none\n", fd);
                	        break;
	                case 2:
        	                fputs("horizontal differencing\n", fd);
                	        break;
	                default:
        	                fprintf(fd, "%u (0x%04x)\n", td->td_predictor, td->td_predictor);
	                        break;
                }
        }
        if (FIELD(tif, FIELD_ARTIST))
                fprintf(fd, "  Artist....................: %s\n", td->td_artist);
        if (FIELD(tif, FIELD_DATETIME))
                fprintf(fd, "  Date & Time...............: %s\n", td->td_datetime);
        if (FIELD(tif, FIELD_HOSTCOMPUTER))
                fprintf(fd, "  Host Computer.............: %s\n", td->td_hostcomputer);
        if (FIELD(tif, FIELD_SOFTWARE))
                fprintf(fd, "  Software..................: %s\n", td->td_software);
        if (FIELD(tif, FIELD_DOCUMENTNAME))
                fprintf(fd, "  Document Name.............: %s\n", td->td_documentname);
        if (FIELD(tif, FIELD_IMAGEDESCRIPTION))
                fprintf(fd, "  Image Description.........: %s\n", td->td_imagedescription);
        if (FIELD(tif, FIELD_MAKE))
                fprintf(fd, "  Make......................: %s\n", td->td_make);
        if (FIELD(tif, FIELD_MODEL))
                fprintf(fd, "  Model.....................: %s\n", td->td_model);
        if (FIELD(tif, FIELD_ORIENTATION)) {
                fputs("  Orientation...............: ", fd);
                switch (td->td_orientation) {
	                case ORIENTATION_TOPLEFT:
        	                fputs("row 0 top, col 0 lhs\n", fd);
                	        break;
	                case ORIENTATION_TOPRIGHT:
        	                fputs("row 0 top, col 0 rhs\n", fd);
                	        break;
	                case ORIENTATION_BOTRIGHT:
        	                fputs("row 0 bottom, col 0 rhs\n", fd);
                	        break;
	                case ORIENTATION_BOTLEFT:
        	                fputs("row 0 bottom, col 0 lhs\n", fd);
                	        break;
	                case ORIENTATION_LEFTTOP:
        	                fputs("row 0 lhs, col 0 top\n", fd);
                	        break;
	                case ORIENTATION_RIGHTTOP:
        	                fputs("row 0 rhs, col 0 top\n", fd);
                	        break;
	                case ORIENTATION_RIGHTBOT:
        	                fputs("row 0 rhs, col 0 bottom\n", fd);
                	        break;
	                case ORIENTATION_LEFTBOT:
        	                fputs("row 0 lhs, col 0 bottom\n", fd);
                	        break;
	                default:
        	                fprintf(fd, "%u (0x%04x)\n", td->td_orientation, td->td_orientation);
	                        break;
                }
        }
        if (FIELD(tif, FIELD_SAMPLESPERPIXEL))
                fprintf(fd, "  Samples/Pixel.............: %u\n", td->td_samplesperpixel);
        if (FIELD(tif, FIELD_ROWSPERSTRIP)) {
                fputs("  Rows/Strip................: ", fd);
                if (td->td_rowsperstrip == 0xffffffffL)
                        fputs("(infinite)\n", fd);
                else
                        fprintf(fd, "%u\n", td->td_rowsperstrip);
        }
        if (FIELD(tif, FIELD_MINSAMPLEVALUE))
                fprintf(fd, "  Minimum Sample Value......: %u\n", td->td_minsamplevalue);
        if (FIELD(tif, FIELD_MAXSAMPLEVALUE))
                fprintf(fd, "  Maximum Sample Value......: %u\n", td->td_maxsamplevalue);
        if (FIELD(tif, FIELD_PLANARCONFIG)) {
                fputs("  Planar Configuration......: ", fd);
                switch (td->td_planarconfig) {
	                case PLANARCONFIG_CONTIG:
        	                fputs("single image plane\n", fd);
                	        break;
	                case PLANARCONFIG_SEPARATE:
        	                fputs("separate image planes\n", fd);
                	        break;
	                default:
        	                fprintf(fd, "%u (0x%04x)\n", td->td_planarconfig, td->td_planarconfig);
	                        break;
                }
        }
        if (FIELD(tif, FIELD_PAGENAME))
                fprintf(fd, "  Page Name.................: %s\n", td->td_pagename);
        if (FIELD(tif, FIELD_GRAYRESPONSEUNIT)) {
                fputs("  Gray Response Unit........: ", fd);
                if (td->td_grayresponseunit < MAXRESPONSEUNIT)
                        fprintf(fd, "%s\n", ResponseUnitNames[td->td_grayresponseunit]);
                else
                        fprintf(fd, "%u (0x%04x)\n", td->td_grayresponseunit, td->td_grayresponseunit);
        }
        if (FIELD(tif, FIELD_GRAYRESPONSECURVE)) {
                fputs("  Gray Response Curve.......: ", fd);
                if (showresponsecurve) {
                        fputc('\n', fd);
                        unit = ResponseUnit[td->td_grayresponseunit];
                        n = 1L << td->td_bitspersample;
                        for (i = 0; i < n; i++)
                                fprintf(fd, "    %2d: %f (%u)\n", i, td->td_grayresponsecurve[i] * unit, td->td_grayresponsecurve[i]);
                } 
                else
                        fputs("(present)\n", fd);
        }
        if (FIELD(tif, FIELD_GROUP3OPTIONS)) {
                fputs("  Group 3 Options...........:", fd);
                sep = ' ';
                if (td->td_group3options & GROUP3OPT_2DENCODING) {
                	fputc(sep, fd);
                       	fputs("2-d encoding", fd);
                       	sep = '+';
               	}
                if (td->td_group3options & GROUP3OPT_FILLBITS) {
                	fputc(sep, fd);
                        fputs("EOL padding", fd);
                        sep = '+';
              	}
                if (td->td_group3options & GROUP3OPT_UNCOMPRESSED) {
                	fputc(sep, fd);
                        fputs("no compression", fd);
                }
                fprintf(fd, " (%lu = 0x%08lx)\n", td->td_group3options, td->td_group3options);
        }
        if (FIELD(tif, FIELD_CLEANFAXDATA)) {
                fputs("  Fax Data..................: ", fd);
                switch (td->td_cleanfaxdata) {
	                case CLEANFAXDATA_CLEAN:
        	                fputs("clean\n", fd);
                	        break;
	                case CLEANFAXDATA_REGENERATED:
        	                fputs("receiver regenerated\n", fd);
                	        break;
	                case CLEANFAXDATA_UNCLEAN:
        	                fputs("uncorrected errors\n", fd);
                	        break;
	                default:
        	                fprintf(fd, "(%u = 0x%04x)\n", td->td_cleanfaxdata, td->td_cleanfaxdata);
	                        break;
                }
        }
        if (FIELD(tif, FIELD_BADFAXLINES))
                fprintf(fd, "  Bad Fax Lines.............: %lu\n", td->td_badfaxlines);
        if (FIELD(tif, FIELD_BADFAXRUN))
                fprintf(fd, "  Consecutive Bad Fax Lines.: %u\n", td->td_badfaxrun);
        if (FIELD(tif, FIELD_GROUP4OPTIONS))
                fprintf(fd, "  Group 4 Options...........: %lu (0x%08lx)\n", td->td_group4options, td->td_group4options);
        if (FIELD(tif, FIELD_PAGENUMBER))
                fprintf(fd, "  Page Number...............: %u-%u\n", td->td_pagenumber[0], td->td_pagenumber[1]);
        if (FIELD(tif, FIELD_COLORRESPONSEUNIT)) {
                fputs("  Color Response Unit.......: ", fd);
                if (td->td_colorresponseunit < MAXRESPONSEUNIT)
                        fprintf(fd, "%s\n", ResponseUnitNames[td->td_colorresponseunit]);
                else
                        fprintf(fd, "%u (0x%04x)\n", td->td_colorresponseunit, td->td_colorresponseunit);
        }
        if (FIELD(tif, FIELD_COLORMAP)) {
                fputs("  Color Map.................: ", fd);
                if (showcolormap) {
                        fputc('\n', fd);
                        n = 1L << td->td_bitspersample;
                        for (i = 0; i < n; i++)
                                fprintf(fd, "   %5d: %5u %5u %5u\n", i, td->td_redcolormap[i], td->td_greencolormap[i], td->td_bluecolormap[i]);
                } 
                else
                        fputs("(present)\n", fd);
        }
        if (FIELD(tif, FIELD_COLORRESPONSECURVE)) {
                fputs("  Color Response Curve......: ", fd);
                if (showresponsecurve) {
                        fputc('\n', fd);
                        unit = ResponseUnit[td->td_colorresponseunit];
                        n = 1L << td->td_bitspersample;
                        for (i = 0; i < n; i++)
                                fprintf(fd, "    %2d: %6.4f %6.4f %6.4f\n", i, td->td_redresponsecurve[i] * unit, td->td_greenresponsecurve[i] * unit, td->td_blueresponsecurve[i] * unit);
                } 
                else
                        fputs("(present)\n", fd);
        }
        if (showstrips && FIELD(tif, FIELD_STRIPOFFSETS)) {
        	char	s[20];

                fprintf(fd, "  %lu Strips", td->td_nstrips);
                for (i = 0; i < 19 - (int)strlen(ltoa(td->td_nstrips, s, 10)); i++)
                	fputc('.', fd);
                fputs(":\n", fd);
                for (i = 0; i < td->td_nstrips; i++)
                        fprintf(fd, "    %3d: [%8lu, %8lu]\n", i, td->td_stripoffset[i], td->td_stripbytecount[i]);
        }
}
