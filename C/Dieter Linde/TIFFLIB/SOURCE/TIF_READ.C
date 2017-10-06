#pragma warn -use
static char 	*sccsid = "@(#)TIFF/tif_read.c 1.23, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
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
 * Scanline-oriented Read Support
 */
#include <stdlib.h>
#include "tiffio.h"

#define roundup(x, y)	((((x) + ((y) - 1)) / (y)) * (y))

/****************************************************************************
 *
 */
static long
TIFFReadRawStrip1(
        TIFF 	*tif,
        u_int 	strip,
        void 	*buf,
        u_long	size,
        char 	*module
        )
{
        if (!SeekOK(tif->tif_fd, tif->tif_dir.td_stripoffset[strip])) {
               	TIFFError(module, "seek error at scanline %ld, strip %u", tif->tif_row, strip);
                return(-1);
        }
        if (!ReadOK(tif->tif_fd, buf, size)) {
               	TIFFError(module, "read error at scanline %ld", tif->tif_row);
                return(-1);
        }
        return(size);
}


/****************************************************************************
 * Read a strip of data from the file.
 */
long
TIFFReadRawStrip(
        TIFF 	*tif,
        u_int 	strip,
        void 	*buf,
        u_long 	size
        )
{
        static char	*module = "TIFFReadRawStrip";
        TIFFDirectory 	*td = &tif->tif_dir;
        u_long 		bytecount;

        if (tif->tif_mode == O_WRONLY) {
               	TIFFError(module, "file \"%s\" not opened for reading", tif->tif_name);
                return(-1);
        }
        if (strip >= td->td_nstrips) {
                TIFFError(module, "strip %u out of range, max %ul", strip, td->td_nstrips);
                return(-1);
        }
        bytecount = td->td_stripbytecount[strip];
        if (size == (u_int)-1)
                size = bytecount;
        else if (bytecount > size)
                bytecount = size;
        return(TIFFReadRawStrip1(tif, strip, buf, bytecount, module));
}

/****************************************************************************
 * Set state to appear as if a strip has just been read in.
 */
static int
TIFFStartStrip(
        register TIFF	*tif,
        u_int 		strip
        )
{
        TIFFDirectory	*td = &tif->tif_dir;

        tif->tif_curstrip = strip;
        tif->tif_row = (strip % td->td_stripsperimage) * td->td_rowsperstrip;
        tif->tif_rawcp = tif->tif_rawdata;
        tif->tif_rawcc = td->td_stripbytecount[strip];
        return(tif->tif_stripdecode == NULL || (*tif->tif_stripdecode)(tif));
}
/****************************************************************************
 * Read the specified strip and setup for decoding.  The data buffer is expanded, as necessary, to
 * hold the strip's data.
 */
static int
TIFFFillStrip(
        TIFF 	*tif,
        u_int 	strip
        )
{
        static char	*module = "TIFFFillStrip";
        TIFFDirectory 	*td = &tif->tif_dir;
        u_long 		bytecount;

        /*
         * Expand raw data buffer, if needed, to hold data strip coming from file
         * (perhaps should set upper bound on the size of a buffer we'll use?).
         */
        bytecount = td->td_stripbytecount[strip];
        if (bytecount > tif->tif_rawdatasize) {
                tif->tif_curstrip = -1;        	/* unknown state */
                if (tif->tif_rawdata) {
                        free(tif->tif_rawdata);
                        tif->tif_rawdata = NULL;
                }
                tif->tif_rawdatasize = roundup(bytecount, 1024);
                tif->tif_rawdata = malloc(tif->tif_rawdatasize);
                if (tif->tif_rawdata == NULL) {
                       	TIFFError(module, "out of memory allocating data buffer at scanline %ld", tif->tif_row);
                        tif->tif_rawdatasize = 0;
                        return(0);
                }
        }
        if (TIFFReadRawStrip1(tif, strip, tif->tif_rawdata, bytecount, module) != bytecount)
                return(0);
        if (td->td_fillorder != tif->tif_fillorder && (tif->tif_flags & TIFF_NOBITREV) == 0)
                TIFFReverseBits((u_char *)tif->tif_rawdata, bytecount);
        return(TIFFStartStrip(tif, strip));
}

/****************************************************************************
 * Seek to a random row + sample in a file.
 */
static int
TIFFSeek(
        register TIFF	*tif,
        u_int 		row, 
        u_int		sample
        )
{
	static char		*module = "TIFFSeek";
        register TIFFDirectory	*td = &tif->tif_dir;
        long 			strip;

        if (row >= td->td_imagelength) {       	/* out of range */
               	TIFFError(module, "row %u out of range, max %u", row, td->td_imagelength);
                return(0);
        }
        if (td->td_planarconfig == PLANARCONFIG_SEPARATE) {
               	if (sample >= td->td_samplesperpixel) {
                       	TIFFError(module, "sample %u out of range, max %u", sample, td->td_samplesperpixel);
                        return(0);
                }
                strip = sample * td->td_stripsperimage + row / td->td_rowsperstrip;
        } 
        else
                strip = row / td->td_rowsperstrip;
        if (strip != tif->tif_curstrip) {      	/* different strip, refill */
                if (!TIFFFillStrip(tif, (u_int)strip))
                       	return(0);
        } 
        else if (row < tif->tif_row) {

	/*
         * Moving backwards within the same strip: backup to the start and then decode forward (below).
         *
         * NB: If you're planning on lots of random access within a strip, it's better to just read and decode the entire
         * strip, and then access the decoded data in a random fashion.
         */
               	if (!TIFFStartStrip(tif, (u_int)strip))
                        return(0);
        }
        if (row != tif->tif_row) {
               	if (tif->tif_seek) {

	/*
         * Seek forward to the desired row.
         */
                       	if (!(*tif->tif_seek)(tif, row - tif->tif_row))
                               	return(0);
                        tif->tif_row = row;
                } 
                else {
                       	TIFFError(module, "compression algorithm does not support random access");
                        return(0);
                }
        }
        return(1);
}

/****************************************************************************
 *
 */
int
TIFFReadScanline(
        register TIFF	*tif,
        void 		*buf,
        u_int 		row, 
        u_int		sample
        )
{
	static char	*module = "TIFFReadScanline";
        int 		e;

        if (tif->tif_mode == O_WRONLY) {
                TIFFError(module, "file \"%s\" not opened for reading", tif->tif_name);
                return(-1);
        }
        if ((e = TIFFSeek(tif, row, sample)) != 0) {

	/*
         * Decompress desired row into user buffer
         */
                e = (*tif->tif_decoderow)(tif, buf, tif->tif_scanlinesize);
                tif->tif_row++;
        }
        return(e ? 1 : -1);
}

/****************************************************************************
 * Read a strip of data and decompress the specified amount into the user-supplied buffer.
 */
int
TIFFReadEncodedStrip(
        TIFF 	*tif,
        u_int 	strip,
        void 	*buf,
        u_int 	size
        )
{
	static char	*module = "TIFFReadEncodedStrip";
        TIFFDirectory	*td = &tif->tif_dir;

        if (tif->tif_mode == O_WRONLY) {
               	TIFFError(module, "file \"%s\" not opened for reading", tif->tif_name);
                return(-1);
        }
        if (strip >= td->td_nstrips) {
               	TIFFError(module, "strip %u out of range, max %ul", strip, td->td_nstrips);
                return(-1);
        }
        if (size == (u_int)-1)
               	size = (u_int)(td->td_rowsperstrip * tif->tif_scanlinesize);
        else if (size > td->td_rowsperstrip * tif->tif_scanlinesize)
               	size = (u_int)(td->td_rowsperstrip * tif->tif_scanlinesize);
        return(TIFFFillStrip(tif, strip) && (*tif->tif_decoderow)(tif, buf, size) ? size : -1);
}
