#pragma warn -use
static char 	*sccsid = "@(#)TIFF/tif_picio.c 1.21, Copyright (c) Sam Leffler, Dieter Linde, "__DATE__;
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
 * Pixar Picio RLE Algorithm Support
 *
 * NB: This algorithm is not (currently) very effective because the state is reset at each scanline.  This
 *   was done to avoid having dangling pointers into the raw data buffer that are invalidated by the flushing
 *   that occurs in TIFFWriteScanline().  To fix this problem we need to add an encodestrip routine (to reset
 *   state) and maintain state during decoding so that runs and such can be restarted when they cross scanline
 *   boundaries.  However, since LZW already works on a strip basis and seems to be more effective, there's
 *   not much reason to go to the trouble.
 */
#include <stdlib.h>
#include "tiffio.h"

/*
 * Each image is composed of a sequence of dumps, runs, partial dumps, and partial runs.  The first two
 * bytes of a sequence contain a flag indicator and a count.  Flags are encoded in the upper 4 bits
 * of the first byte while the lower 12 bits contain the count.
 */

/*
 * Tile flag indicators.
 */
#define PT_FILL        	0              	/* fill input buffer */
#define PT_FULLDUMP     1               /* full dump, use count */
#define PT_FULLRUN      2               /* full run, length precedes pixel */
#define PT_PARTDUMP     3               /* part dump, alpha constant */
#define PT_PARTRUN      4               /* part run, alpha constant */

#define MAXPACKETSIZE  	8		/* picio encoding state */

/* 
 * Macros for unrolling loops.
 */
#define REPEAT4(n, op)	switch (n) { \
				case 4: \
					op; \
				case 3: \
					op; \
				case 2: \
					op; \
				case 1: \
					op; \
			}
#define	REPEAT8(n, op)	switch (n) { \
				case 8: \
					op; \
				case 7: \
					op; \
				case 6: \
					op; \
				case 5: \
					op; \
                		case 4: \
                			op; \
                		case 3: \
                			op; \
                		case 2: \
                			op; \
                		case 1: \
                			op; \
                	}
#define SPRAY4(nc, op)	switch (nc) { \
		        	case 4: \
		        		op[3]; \
			        case 3: \
			        	op[2]; \
			        case 2: \
			        	op[1]; \
			        case 1: \
			        	op[0]; \
        		}

struct  piciostate {
        u_char 	*startptr;
        u_char 	*lptr;          		/* pointer to length byte in run */
        u_short len;            		/* length of run when in 16-bit mode */
        short   count;          		/* repeat count of data in packet */
        short   amark;          		/* index to alpha channel */
        int     type;           		/* 4-bit packet type */
        int     fulldisklength; 		/* size of data + alpha unit */
        int     infodisklength; 		/* size of data unit */
        u_char  *fulleobuffer;  		/* output buffer fencepost for full packet */
        u_char  *infoeobuffer;  		/* output buffer fencepost for info packet */
/*** temp buffers of data going to disk ***/
        u_char  disk0buffer[MAXPACKETSIZE];
        u_char  disk1buffer[MAXPACKETSIZE];
/*** temp buffers of data in memory ***/
        u_short core0buffer[MAXPACKETSIZE / 2];
        u_short core1buffer[MAXPACKETSIZE / 2];
};

static u_char 	*newdisk, *olddisk;
static u_short	*newcore, *oldcore;

#pragma warn -par
/****************************************************************************
 *
 */
static int
pic8DecodeScanline(
        TIFF		*tif,
        register u_char	*op,
        int 		cc
        )
{
        register u_char	*bp, *sp, *ep;
        register int 	npixels;
        u_char 		spare[4];
        short 		nc, flag, word, count, length;
        static char	module[] = "PicioDecode";

        bp = tif->tif_rawcp;
        ep = bp + tif->tif_rawcc;
        npixels = tif->tif_dir.td_imagewidth;
        nc = (tif->tif_dir.td_planarconfig == PLANARCONFIG_CONTIG ? tif->tif_dir.td_samplesperpixel : 1);
        while (bp < ep && npixels > 0) {
                word = (bp[1] << 8) | bp[0];
                bp += 2;
                count = (word & 0xfff) + 1;
                switch (flag = (word >> 12)) {
	                case PT_FULLRUN:
        	                while (count-- > 0) {

	/*
         * The first byte holds a count.  The next bytes hold data to be repeated.
         */
                                	length = (*bp++) + 1;
                                	sp = spare + nc;
                                	REPEAT4(nc, *--sp = *bp++);
                                	npixels -= length;
                                	for (sp = spare; length-- > 0;)
                                        	SPRAY4(nc, *op++ = sp);
                        	}
                        	break;
	                case PT_FULLDUMP:
        	                npixels -= count;
                	        for (count *= nc; count-- > 0; *op++ = *bp++)
                        	        ;
	                        break;
        	        case PT_PARTRUN:
                	        spare[0] = *bp++;
                        	while (count-- > 0) {

	/*
         * The first byte is a count.  The next bytes are data to be repeated.
         */
                                	length = (*bp++) + 1;
	                                sp = spare + nc;
	                                REPEAT4(nc - 1, *--sp = *bp++);
	                                npixels -= length;
        	                        for (sp = spare; length-- > 0;)
                	                        SPRAY4(nc, *op++ = sp);
                        	}
	                        break;
        	        case PT_PARTDUMP:

	/*
         * The fixed value (normally alpha) is stored in the first byte.
         */
                        	(sp = spare)[0] = *bp++;
                        	npixels -= count;
                        	while (count-- > 0) {
                                	REPEAT4(nc - 1, *op++ = *bp++);
                                	*op++ = sp[0];
                        	}
                        	break;
	                default:
        	                TIFFError(module, "%s: Unknown flag 0x%x at scanline %d", tif->tif_name, flag, tif->tif_row);
                        	return(0);
                }
        }
        tif->tif_rawcc -= (bp - tif->tif_rawcp);
        tif->tif_rawcp = bp;
        if (npixels > 0) {
               	TIFFError(module, "%s: Not enough data for scanline %d", tif->tif_name, tif->tif_row);
                return(0);
        }
        return(1);
}
#pragma warn .par

#pragma warn -par
/****************************************************************************
 *
 */
static int
pic16DecodeScanline(
        TIFF 		*tif,
        register u_char	*op,
        int 		cc
        )
{
        register u_char 	*bp, *ep;
        register int 		npixels;
        register u_short 	*sp;
        short 			nc, flag, word, count, length;
        u_short 		spare[4];
        static char 		module[] = "PicioDecode";

        bp = tif->tif_rawcp;
        ep = bp + tif->tif_rawcc;
        npixels = tif->tif_dir.td_imagewidth;
        nc = (tif->tif_dir.td_planarconfig == PLANARCONFIG_CONTIG ? tif->tif_dir.td_samplesperpixel : 1);
        while (bp < ep && npixels > 0) {
                word = (bp[1] << 8) | bp[0];
                bp += 2;
                count = (word & 0xfff) + 1;
                switch (flag = (word >> 12)) {
                	case PT_FULLRUN:
	                        while (count-- > 0) {

	/*
         * The first byte holds a count.  The next bytes hold data to be repeated.
         */
                                	length = ((bp[1] << 8) | bp[0]) + 1; 
                                	bp += 2;
                                	sp = spare + nc;
                                	REPEAT4(nc, *--sp = bp[0]|(bp[1] << 8); bp += 2);
	                                npixels -= length;
        	                        for (sp = spare; length-- > 0;)
                	                        SPRAY4(nc, *((u_short *)op)++ = sp);
                        	}
                        	break;
	                case PT_FULLDUMP:
        	                npixels -= count;
                	        while (count-- > 0)
                        	        REPEAT4(nc, *((u_short *)op)++ = bp[0]|(bp[1] << 8); bp += 2);
	                        break;
        	        case PT_PARTRUN:
                	        spare[0] = bp[0]|(bp[1] << 8); 
                	        bp += 2;
	                        while (count-- > 0) {

	/*
         * The first byte is a count.  The next bytes are data to be repeated.
         */
                                	length = ((bp[1] << 8) | bp[0]) + 1; 
                                	bp += 2;
	                                sp = spare + nc;
                                	REPEAT4(nc - 1, *--sp = bp[0]|(bp[1] << 8); bp +=2);
	                                npixels -= length;
        	                        for (sp = spare; length-- > 0;)
                	                        SPRAY4(nc, *((u_short *)op)++ = sp);
                        	}
	                        break;
        	        case PT_PARTDUMP:

	/*
         * The fixed value (normally alpha) is stored in the first byte.
         */
                        	(sp = spare)[0] = bp[0]|(bp[1] << 8); 
                        	bp += 2;
                        	npixels -= count;
                        	while (count-- > 0) {
                                	REPEAT4(nc - 1, *((u_short *)op)++ = bp[0]|(bp[1] << 8); bp +=2);
	                                *((u_short *)op)++ = sp[0];
        	                }
                	        break;
                	default:
                        	TIFFError(module, "%s: Unknown flag 0x%x at scanline %d", tif->tif_name, flag, tif->tif_row);
                        	return(0);
                }
        }
        tif->tif_rawcc -= (bp - tif->tif_rawcp);
        tif->tif_rawcp = bp;
        if (npixels > 0) {
               	TIFFError(module, "%s: Not enough data for scanline %d", tif->tif_name, tif->tif_row);
                return(0);
        }
        return(1);
}
#pragma warn .par

/****************************************************************************
 *
 */
static int
PicioDecodeStrip(
        TIFF 	*tif
        )
{
        switch (tif->tif_dir.td_bitspersample) {
        	case 8:
                	tif->tif_decoderow = pic8DecodeScanline;
	                break;
        	case 16:
                	tif->tif_decoderow = pic16DecodeScanline;
	                break;
        	default:
                	TIFFError("PicioDecode", "Can't handle %d-bit pictures", tif->tif_dir.td_bitspersample);
                	return(0);
        }
        return(1);
}

/****************************************************************************
 * Startpacket takes the old and new pixels and starts the requested packet using them.
 */
static u_char *
startpacket(
	TIFF	*tif,
	u_char	*ptr, 
	short	type
	)
{
        register struct piciostate	*ps;
        register u_char 		*dp;

        /*
         * Set up packet type and count.  The packet count is incremented as the data is repeated.  These
         * two values are merged and written when ending the packet.
         */
        ps = (struct piciostate *)tif->tif_data;
        if (ptr > ps->fulleobuffer) {
               	tif->tif_rawcc += ptr - (u_char *)tif->tif_rawcp;
                if (!TIFFFlushData(tif))
                       	return(NULL);
                ptr = (u_char *)tif->tif_rawcp;
        }
        ps->type = type;
        ps->count = 0;
        ps->startptr = ptr;
        ptr += 2;	/* skip packet header */
        switch (type) {
        	case 0:
                	ps->type = PT_FULLDUMP;
                	dp = newdisk;
                	REPEAT8(ps->fulldisklength, *ptr++ = *dp++);
                	break;

        	case PT_FULLDUMP:
        	case PT_FULLRUN:
                	if (type == PT_FULLRUN) {
                        	ps->lptr = ptr;
                        	*ptr++ = 1;
                        	if (tif->tif_dir.td_bitspersample == 16) {
                                	ps->len = 1;
                                	*ptr++ = 0;
                        	}
                	}
                	dp = olddisk;
                	REPEAT8(ps->fulldisklength, *ptr++ = *dp++);
                	break;

        	case PT_PARTRUN:
        	case PT_PARTDUMP:
                	dp = olddisk + ps->infodisklength;
                	REPEAT8(ps->fulldisklength - ps->infodisklength, *ptr++ = *dp++);
                	if (type == PT_PARTRUN) {
                        	ps->lptr = ptr;
                        	*ptr++ = 1;
                        	if (tif->tif_dir.td_bitspersample == 16) {
                                	ps->len = 1;
                                	*ptr++ = 0;
                        	}
                	}
                	dp = olddisk;
                	REPEAT8(ps->infodisklength, *ptr++ = *dp++);
                	break;
       	}
        return(ptr);
}

/****************************************************************************
 * Set the packet header from the accumulated state information.
 */
static void
endpacket(
      	register struct piciostate	*ps
      	)
{
       	ps->count |= ps->type << 12;
        ps->startptr[1] = ps->count >> 8;
        ps->startptr[0] = ps->count;
}

/*
 * Yech -- this knows about bp & runstatus.
 */
#define startnewbuffer(tif, pt)	{ \
        				endpacket((struct piciostate *)tif->tif_data); \
        				tif->tif_rawcc += bp - (u_char *)tif->tif_rawcp; \
        				if (!TIFFFlushData(tif)) \
                				return(-1); \
        				bp = startpacket(tif, tif->tif_rawcp, runstatus = pt); \
        				if (bp == NULL) \
                				return(-1); \
				}

/* 
 * State indicators used in encoding.
 */
#define PT_UNKNOWN  	-1
#define PT_CFULLRUN     -2
#define PT_STARTUP      -3
#define PT_CPARTRUN     -4

/*
 * To encode tile type + same-pixel + same-alpha into a single value, we use the following magic constants.
 */
#define SP_FALSE       	(0 * (PT_PARTRUN - PT_CPARTRUN + 1))
#define SP_TRUE         (1 * (PT_PARTRUN - PT_CPARTRUN + 1))
#define SA_FALSE        (2 * SP_FALSE)
#define SA_TRUE         (4 * SP_TRUE)

/****************************************************************************
 * Setup encoding state.
 */
static int
PicioStripEncode(
      	register TIFF	*tif
      	)
{
        register struct piciostate	*ps;
        int 				bytespersample;

        if (tif->tif_data != NULL)
               	return(1);
        if (tif->tif_dir.td_bitspersample != 8 && tif->tif_dir.td_bitspersample != 16) {
               	TIFFError("PicioEncode", "Can't handle %d-bit pictures", tif->tif_dir.td_bitspersample);
                return(0);
        }
        if ((tif->tif_data = malloc(sizeof(struct piciostate))) == NULL) {
               	TIFFError("PicioEncode", "No space for picio state block");
                return(0);
        }
        bzero(tif->tif_data, sizeof(struct piciostate));
        ps = (struct piciostate *)tif->tif_data;
        if (tif->tif_dir.td_planarconfig == PLANARCONFIG_CONTIG) {
               	ps->fulldisklength = tif->tif_dir.td_samplesperpixel;
                if ((ps->infodisklength = tif->tif_dir.td_samplesperpixel) > 3)
                       	ps->infodisklength = 3;
                ps->amark = tif->tif_dir.td_matteing ? tif->tif_dir.td_samplesperpixel - 1 : 3;
        } 
        else {
                ps->fulldisklength = ps->infodisklength = 1;
                ps->amark = 0;
        }
        bytespersample = tif->tif_dir.td_bitspersample <= 8 ? 1 : tif->tif_dir.td_bitspersample <= 16 ? 2 : 4;
        ps->fulldisklength *= bytespersample;
        ps->infodisklength *= bytespersample;

        /*
         * fulleobuffer & infoeobuffer mark the last spot in the buffer at which a packet can be placed
         * (either a fulldisklength or infodisklength packet).  The 2+ is for the 2 byte packet type and length.
         */
        ps->fulleobuffer = (u_char *)tif->tif_rawdata + tif->tif_rawdatasize - (2 + ps->fulldisklength) - 1;
        ps->infoeobuffer = (u_char *)tif->tif_rawdata + tif->tif_rawdatasize - (2 + ps->infodisklength) - 1;
        return(1);
}

/****************************************************************************
 * Encode a scanline of pixels.
 */
static int
PicioEncode(
       	TIFF 		*tif,
        register u_char	*ip,
        int		cc
        )
{
        register u_char			*bp;
        register struct piciostate 	*ps;
        u_char 				*dp, *ep;
        int 				cmpstatus, runstatus, nc, hasalphachannel;
        u_short 			*cp1, *cp2, *wp;

        ps = (struct piciostate *)tif->tif_data;
        ep = ip + cc;
        bp = (u_char *)tif->tif_rawcp;
        if (tif->tif_dir.td_planarconfig == PLANARCONFIG_CONTIG) {
                nc = tif->tif_dir.td_samplesperpixel;
                hasalphachannel = tif->tif_dir.td_matteing;
        } 
        else {
                nc = 1;
                hasalphachannel = 0;
        }
        oldcore = ps->core0buffer;
        newcore = ps->core1buffer;
        olddisk = ps->disk0buffer;
        newdisk = ps->disk1buffer;

        /* 
         * Setup initial alpha to be different.
         */
        oldcore[ps->amark] = 0;
        newcore[ps->amark] = -1;

        /*
         * Process each pixel with a finite state machine with one-pixel look-ahead.  The look-ahead is used to compress
         * identical pixels into "pixel runs".  The states of encoding process include all the packet types, filled
         * out with a startup state (used only at startup) and an unknown state (used when we have no packet open and
         * do not know yet what kind of packet this last pixel will start.  Also needed are temporary runlength states
         * which are needed, for example, when we have just finished one run in a runlength packet and do not know whether this
         * last pixel is the start of a new run or the start of a whole new (dump) packet.
         */
        runstatus = PT_STARTUP;
        while (ip < ep) {

     	/*
         * Swap pointers to new and old data buffers.
         */
#define	SWAP(t, a, b)	{ \
				t	tmp; \
				tmp = a; \
				a = b; \
				b = tmp; \
			}
              	SWAP(u_short *, oldcore, newcore);
                SWAP(u_char *, olddisk, newdisk);

    	/*
         * Next move the new pixel from the user buffer into the local array and set up the cmpstatus flag to
         * indicate if the new and old pixels agree fully, or just in the flat field (alpha) component.
         */
                cmpstatus = SP_TRUE;
                cp1 = newcore; 
                cp2 = oldcore; 
                dp = newdisk;
                if (tif->tif_dir.td_bitspersample == 8) {
                       	REPEAT4(nc, *cp1 = *ip++;
                            	if (*cp2++ != *cp1)
                                	cmpstatus = SP_FALSE;
                            	*dp++ = *cp1++);
                } 
                else {
                       	wp = (u_short *)ip;	/* XXX for non-pcc compilers */
                        REPEAT4(nc, *cp1 = *wp++;
                            	if (*cp2++ != *cp1)
                                	cmpstatus = SP_FALSE;
                            	*dp++ = *cp1;
                            	*dp++ = *cp1++ >> 8);
                        ip = (u_char *)wp;
                }
                cmpstatus += oldcore[ps->amark] == newcore[ps->amark] ? SA_TRUE : SA_FALSE;

   	/*
         * Here is the main loop that decides how to handle the new pixel based on the current state.
         */
                switch (runstatus + cmpstatus) {

      	/*
         * Continue the full run because the new pixel matches the old.
         */
                	case PT_FULLRUN + SP_TRUE + SA_FALSE:
                	case PT_FULLRUN + SP_TRUE + SA_TRUE:

     	/*
         * The run count just overflowed.  Go to the CFULLRUN state, because this run is done, and we do not
         * know whether to start a new packet or just a new run.
         */
                        	if (tif->tif_dir.td_bitspersample == 16) {
                                	ps->lptr[0] = ++(ps->len);
                                	ps->lptr[1] = ps->len >> 8;
                                	if (ps->len != 0)
                                        	break;
                                	ps->lptr[0] = --(ps->len);
                                	ps->lptr[1] = ps->len >> 8;
                        	} 
                        	else {
                                	if (++(*ps->lptr) != 0)
                                        	break;
                                	(*ps->lptr)--;
                        	}
                        	/*** fall thru... ***/

                	case PT_FULLRUN + SP_FALSE + SA_FALSE:
                	case PT_FULLRUN + SP_FALSE + SA_TRUE:

      	/*
         * Terminate the current run and go to CFULLRUN to decide whether to start a new run with this
         * pixel or to start a whole new packet.
         */
                        	runstatus = PT_CFULLRUN;
                        	break;

       	/*
         * In the middle of a fullrun packet; wait to see whether to start a new run, or whether to end this 
         * packet and start a new packet.
         */
                	case PT_CFULLRUN + SP_TRUE + SA_FALSE:
                	case PT_CFULLRUN + SP_TRUE + SA_TRUE:

       	/*
         * Start a new run.  Increment the packet count which holds the number of runs in this packet.  
         * Put out the run length (1, meaning 1 repetition or 2 instances) and the full component information.
         */
                        	if (bp > ps->fulleobuffer) {
                                	startnewbuffer(tif, PT_FULLRUN);
                        	} 
                        	else {
                                	ps->count++;
                                	ps->lptr = bp;
                                	*bp++ = 1;
                                	if (tif->tif_dir.td_bitspersample == 16) {
                                        	ps->len = 1;
                                        	*bp++ = 0;
                                	}
                                	dp = newdisk;
                                	REPEAT8(ps->fulldisklength, *bp++ = *dp++);
                        	}
                        	runstatus = PT_FULLRUN;
                        	break;

                	case PT_CFULLRUN + SP_FALSE + SA_TRUE:

     	/*
         * End this packet and start a partial dump packet, because at least the alpha stayed constant.
         */
                        	endpacket(ps);
                        	bp = startpacket(tif, bp, runstatus = PT_PARTDUMP);
                        	if (bp == 0)
                                	return(-1);
                        	break;

                	case PT_CFULLRUN + SP_FALSE + SA_FALSE:
                        	endpacket(ps);
                        	bp = startpacket(tif, bp, runstatus = PT_FULLDUMP);
                        	if (bp == 0)
                                	return(-1);
                        	break;

                	case PT_FULLDUMP + SP_TRUE + SA_TRUE:
                	case PT_FULLDUMP + SP_TRUE + SA_FALSE:

    	/*
         * End this full dump packet and start a full run because of the match.
         */
                        	endpacket(ps);
                        	bp = startpacket(tif, bp, runstatus = PT_FULLRUN);
                        	if (bp == 0)
                                	return(-1);
                        	break;

                	case PT_FULLDUMP + SP_FALSE + SA_TRUE:
                        	endpacket(ps);
                        	bp = startpacket(tif, bp, runstatus = PT_PARTDUMP);
                        	if (bp == 0)
                                	return(-1);
                        	break;

                	case PT_FULLDUMP + SP_FALSE + SA_FALSE:

     	/*
         * Continue the dump packet.  Write the full component information into the buffer.
         */
                        	if (bp > ps->fulleobuffer) {
                                	startnewbuffer(tif, PT_FULLDUMP);
                        	} 
                        	else {
                                	ps->count++;
                                	dp = olddisk;
                                	REPEAT8(ps->fulldisklength, *bp++ = *dp++);
                        	}
                        	break;

                	case PT_PARTRUN + SP_TRUE + SA_FALSE:
                	case PT_PARTRUN + SP_TRUE + SA_TRUE:

    	/*
         * Continue the part run packet.
         */
                        	if (tif->tif_dir.td_bitspersample == 16) {
                                	ps->lptr[0] = ++(ps->len);
                                	ps->lptr[1] = ps->len >> 8;
                                	if (ps->len != 0)
                                        	break;
                                	ps->lptr[0] = --(ps->len);
                                	ps->lptr[1] = ps->len >> 8;
                        	} 
                        	else {
                                	if (++(*ps->lptr) != 0)
                                        	break;
                                	(*ps->lptr)--;
                        	}
                        	/*** fall thru... ***/

                	case PT_PARTRUN + SP_FALSE + SA_TRUE:

     	/*
         * Go to CPARTRUN because this may just be the start of a new run for this packet.
         */
                        	runstatus = PT_CPARTRUN;
                        	break;

                	case PT_PARTRUN + SP_FALSE + SA_FALSE:

    	/*
         * With no match at all, we have to end this part run packet.  With only this last pixel to start with, we do not
         * know what packet to start next.  Thus we go to the UNKNOWN state.
         */
                        	endpacket(ps);
                        	runstatus = PT_UNKNOWN;
                        	break;

                	case PT_CPARTRUN + SP_TRUE + SA_FALSE:
                	case PT_CPARTRUN + SP_TRUE + SA_TRUE:
                        	if (bp > ps->infoeobuffer) {
                                	startnewbuffer(tif, PT_PARTRUN);
                        	} 
                        	else {
                                	ps->count++;
                                	ps->lptr = bp;
                                	*bp++ = 1;
                                	if (tif->tif_dir.td_bitspersample == 16) {
                                        	ps->len = 1;
                                        	*bp++ = 0;
                                	}
                                	dp = newdisk;
                                	REPEAT8(ps->infodisklength, *bp++ = *dp++);
                        	}
                        	runstatus = PT_PARTRUN;
                        	break;

                	case PT_CPARTRUN + SP_FALSE + SA_TRUE:
                        	endpacket(ps);
                        	bp = startpacket(tif, bp, runstatus = PT_PARTDUMP);
                        	if (bp == 0)
                                	return(-1);
                        	break;

                	case PT_CPARTRUN + SP_FALSE + SA_FALSE:
                        	endpacket(ps);
                        	bp = startpacket(tif, bp, runstatus = PT_FULLDUMP);
                        	if (bp == 0)
                                	return(-1);
                        	break;

                	case PT_PARTDUMP + SP_TRUE + SA_FALSE:
                	case PT_PARTDUMP + SP_TRUE + SA_TRUE:

     	/*
         * This dump packet ends and a partial run packet begins with these last two pixels.
         */
                        	endpacket(ps);
                        	bp = startpacket(tif, bp, runstatus = PT_PARTRUN);
                        	if (bp == 0)
                                	return(-1);
                        	break;

                	case PT_PARTDUMP + SP_FALSE + SA_TRUE:

     	/*
         * The partial dump packet continues.
         */
                        	if (bp > ps->infoeobuffer) {
                                	startnewbuffer(tif, PT_PARTDUMP);
                        	} 
                        	else {
                                	ps->count++;
                                	dp = olddisk;
                                	REPEAT8(ps->infodisklength, *bp++ = *dp++);
                        	}
                        	break;

                	case PT_PARTDUMP + SP_FALSE + SA_FALSE:

    	/*
         * The partial dump ends because alpha is no longer constant.  Finish off this packet and go to the unknown
         * state with this new pixel.
         */
                        	if (bp > ps->infoeobuffer) {
                                	startnewbuffer(tif, PT_PARTDUMP);
                        	} 
                        	else {
                                	ps->count++;
                                	dp = olddisk;
                                	REPEAT8(ps->infodisklength, *bp++ = *dp++);
                        	}
                        	endpacket(ps);
                        	runstatus = PT_UNKNOWN;
                        	break;

                	case PT_STARTUP + SP_FALSE + SA_FALSE:
	                case PT_STARTUP + SP_FALSE + SA_TRUE:
        	        case PT_STARTUP + SP_TRUE + SA_FALSE:
                	case PT_STARTUP + SP_TRUE + SA_TRUE:

       	/*
         * The only thing to do when starting is to start a packet.  However, we do not know which to start until 
         * we have two pixels, so we go to the unknown state.
         */
                        	runstatus = PT_UNKNOWN;
                        	break;

                	case PT_UNKNOWN + SP_TRUE + SA_FALSE:
                	case PT_UNKNOWN + SP_TRUE + SA_TRUE:
                        	runstatus = hasalphachannel ? PT_PARTRUN : PT_FULLRUN;
                        	bp = startpacket(tif, bp, runstatus);
                        	if (bp == 0)
                                	return(-1);
                        	break;

                	case PT_UNKNOWN + SP_FALSE + SA_TRUE:
                        	bp = startpacket(tif, bp, runstatus = PT_PARTDUMP);
                        	if (bp == 0)
                                	return(-1);
                        	break;

                	case PT_UNKNOWN + SP_FALSE + SA_FALSE:
                        	bp = startpacket(tif, bp, runstatus = PT_FULLDUMP);
                        	if (bp == 0)
                                	return(-1);
                        	break;
               	}
       	}

        /*
         * The following code handles the cleanup at the end of the scanline -- we must flush the current packet.
         */
        switch (runstatus) {
	        case PT_FULLRUN:	/* everything is up to date */
                	break;

        	case PT_CFULLRUN:	/* add the last new pixel as a run with repeat count 0 */
                	if (bp > ps->fulleobuffer) {
                        	startnewbuffer(tif, 0);
                	} 
                	else {
                        	ps->count++;
                        	*bp++ = 0;
                        	if (tif->tif_dir.td_bitspersample == 16)
                                	*bp++ = 0;
                        	dp = newdisk;
                        	REPEAT8(ps->fulldisklength, *bp++ = *dp++);
                	}
                	break;

        	case PT_FULLDUMP:	/* add this new pixel as the last pixel in a dump */
                	if (bp > ps->fulleobuffer) {
                        	startnewbuffer(tif, 0);
                	} 
                	else {
                        	ps->count++;
                        	dp = newdisk;
                        	REPEAT8(ps->fulldisklength, *bp++ = *dp++);
                	}
                	break;

        	case PT_PARTRUN:	/* we are up to date */
                	break;

        	case PT_CPARTRUN:	/* see CFULLRUN above */
                	if (bp > ps->infoeobuffer) {
                        	startnewbuffer(tif, 0);
                	} 
                	else {
                        	ps->count++;
                        	*bp++ = 0;
                        	if (tif->tif_dir.td_bitspersample == 16)
                                	*bp++ = 0;
                        	dp = newdisk;
                        	REPEAT8(ps->infodisklength, *bp++ = *dp++);
                	}
                	break;

        	case PT_PARTDUMP:	/* see FULLDUMP above */
                	if (bp > ps->infoeobuffer) {
                        	startnewbuffer(tif, 0);
                	} 
                	else {
                        	ps->count++;
                        	dp = newdisk;
                        	REPEAT8(ps->infodisklength, *bp++ = *dp++);
                	}
                	break;

        	case PT_STARTUP:
                	break;

        	case PT_UNKNOWN:	/* we are caught with one pixel in the hand and no packet to add it to; we start a simple fulldump packet */
                	bp = startpacket(tif, bp, 0);
                	if (bp == 0)
                        	return(-1);
                	break;
       	}
        endpacket(ps);
        tif->tif_rawcc += bp - (u_char *)tif->tif_rawcp;
        tif->tif_rawcp = (u_char *)bp;
        return(1);
}

/****************************************************************************
 *
 */
static void
PicioCleanup(
       	TIFF 	*tif
       	)
{
        if (tif->tif_data != NULL) {
               	free(tif->tif_data);
               	tif->tif_data = NULL;
        }
}

/****************************************************************************
 *
 */
int
TIFFInitPicio(
        TIFF	*tif
        )
{
        tif->tif_stripdecode = PicioDecodeStrip;
        tif->tif_stripencode = PicioStripEncode;
        tif->tif_encoderow = PicioEncode;
        tif->tif_cleanup = PicioCleanup;
        return(1);
}
