#ifndef __TIF_FAX3_H__
#define __TIF_FAX3_H__
/*
 * @(#)TIFF/tif_fax3.h 1.03, Copyright (c) Sam Leffler, Dieter Linde, Oct 8 1990
 * 
 * CCITT Group 3 compression/decompression definitions.
 */
#define FAX3_CLASSF    	TIFF_OPT0      	/* use Class F protocol */

/* 
 * The following are for use by Compression=2, 32771, and 4 (T.6) algorithms .
 */
#define FAX3_NOEOL      TIFF_OPT1       /* no EOL code at end of row */
#define FAX3_BYTEALIGN  TIFF_OPT2       /* force byte alignment at end of row */
#define FAX3_WORDALIGN  TIFF_OPT3       /* force word alignment at end of row */

/*
 * Compression + decompression state blocks are derived from this ``base state'' block.
 */
typedef struct {
       	short  	data;                   /* current i/o byte */
        short   bit;                    /* current i/o bit in byte */
        short   white;                  /* value of the color ``white'' */
        enum {                          /* decoding/encoding mode */
            	G3_1D,                 	/* basic 1-d mode */
            	G3_2D                  	/* optional 2-d mode */
        } tag;
        u_char  *bitmap;                /* bit reversal table */
        u_char  *refline;               /* reference line for 2d decoding */
} Fax3BaseState;

/* 
 * These routines are used for Group 4 (T.6).
 */
int 	Fax3Decode2DRow(TIFF *, u_char *, int);
int 	Fax3Encode2DRow(TIFF *, u_char *, u_char *, int);
void	Fax3PutEOL(TIFF *);

#endif 	/* __TIF_FAX3_H__ */
