#undef DEBUG	/*1*/
#undef MONITOR_CRLF

/*
 *	zdef.h
 */

/*
 *	These wondrous debugging macros helped me find the nasty bug which
 *	only manifested itself on msdos -- stackp has to be a long on msdos
 *	because the array it is indexing is 'huge' ...
 */
#ifdef DEBUG
int	debug = 1;
# define TRACT(lev, stmnt)	if (lev <= debug) fprintf(stderr, "%d: %s\n", __LINE__, #stmnt);
# define TRACE(lev, stmnt)	if (lev <= debug) fprintf(stderr, "%d: %s\n", __LINE__, #stmnt); stmnt
# define TRACA(lev, stmnt)	stmnt; if (lev <= debug) fprintf(stderr, "%d: %s\n", __LINE__, #stmnt);
# define TRACL(lev, var)	if (lev <= debug) fprintf(stderr, "%d: %s <- %ld\n", __LINE__, #var, var);
#else
# define TRACT(lev, stmnt)
# define TRACE(lev, stmnt) stmnt
# define TRACA(lev, stmnt) stmnt
# define TRACL(lev, var)
#endif


/* 
 *
 * Originally:
 *
 * compress.c - File compression ala IEEE Computer, June 1984.
 *
 * Authors:    Spencer W. Thomas       (decvax!harpo!utah-cs!utah-gr!thomas)
 *             Jim McKie               (decvax!mcvax!jim)
 *             Steve Davies            (decvax!vax135!petsd!peora!srd)
 *             Ken Turkowski           (decvax!decwrl!turtlevax!ken)
 *             James A. Woods          (decvax!ihnp4!ames!jaw)
 *             Joe Orost               (decvax!vax135!petsd!joe)
 *
 * $Header: zlib.c,v 4.1 90/11/12 14:52:24 gtoal Release $
 *
 * Graham Toal, 3rd September 1988.  My changes released to public domain.
 *                                   Updated Nov 90.
 *
 * The original decompress has been restructured so that data can be
 * fetched on demand a byte at a time.  This lets it be used as a filter
 * for programs which read large data files - you do not need the disk
 * space to decompress the input files first.
 *
 * (Incidentally, programs reading data off floppies will be speeded up
 *  because decompression is always faster than the equivalent amount
 *  of disk I/O).
 *
 * This implementation supplies 'z' versions of fopen, fputc, feof and fclose
 * to be used as direct substitutes for the originals; it would be cleaner
 * and more transparent if the decompress filter were hidden under the
 * real stdio procedures.  An extra call zfilter() is supplied to convert
 * an already-opened stream into a z-stream: see the example at the end
 * of this file.
 *
 * If a file opened by zfopen() was not compressed, the files contents are
 * still recovered correctly at the low expense of an extra procedure call
 * per byte.  This makes the routines more generally usable - they can be
 * left in production programs which can be speeded up in the field by
 * compressing selected input files(*); also, files can be compressed or
 * not selectively depending on whether the compression makes them
 * smaller or not - code accessing the files does not need to know.
 *
 * [(*) reading from a compressed file off floppy disk is faster than
 * reading from an uncompressed file. This probably isn't true of
 * hard disks though.]
 *
 * BUGS: Opening a file "r" will not do CR/LF processing on computers with
 *       this file structure.
 */


#include <stdio.h>
#include <string.h>
#ifdef __STDC__
# include <stdlib.h>
#else
# define size_t		int
#endif
#include <ctype.h>

#ifdef MSDOS
# include <malloc.h>
#else
extern char    *malloc ();
#endif

#ifndef min
# define min(a,b)	((a>b) ? b : a)
# endif
#define HSIZE		69001L		/* 95% occupancy */

/*
 *	the next two codes should not be changed lightly, as they must not
 *	lie within the contiguous general code space.
 */
#define FIRST		257L		/* first free entry */
#define CLEAR		256L		/* table clear output code */

#define BIT_MASK        0x1f
#define BLOCK_MASK      0x80
#define INIT_BITS       9		/* initial number of bits/code */

#define CHECK_GAP	10000L		/* ratio check interval */

#include "zlib.h"

#define NOT_COMPRESSED	1
#define ALLOCATED	2


/* end of zdef.h */
