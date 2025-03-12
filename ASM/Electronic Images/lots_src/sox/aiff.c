/*
 * September 25, 1991
 * Copyright 1991 Guido van Rossum And Sundry Contributors
 * This source code is freely redistributable and may be used for
 * any purpose.  This copyright notice must be maintained. 
 * Guido van Rossum And Sundry Contributors are not responsible for 
 * the consequences of using this software.
 */

/*
 * Sound Tools SGI/Amiga AIFF format.
 * Used by SGI on 4D/35 and Indigo.
 * This is a subformat of the EA-IFF-85 format.
 * This is related to the IFF format used by the Amiga.
 * But, apparently, not the same.
 *
 * Jan 93: new version from Guido Van Rossum that 
 * correctly skips unwanted sections.
 */

#include <math.h>
#include "st.h"

/* Private data used by writer */
struct aiffpriv {
	unsigned long nsamples;
};

double read_ieee_extended();

aiffstartread(ft) 
ft_t ft;
{
	char buf[4];
	unsigned long totalsize;
	unsigned long chunksize;
	int channels;
	unsigned long frames;
	int bits;
	double rate;
	unsigned long offset;
	unsigned long blocksize;
	int littlendian = 0;
	char *endptr;

	/* FORM chunk */
	if (fread(buf, 1, 4, ft->fp) != 4 || strncmp(buf, "FORM", 4) != 0)
		fail("AIFF header does not begin with magic word 'FORM'");
	totalsize = rblong(ft);
	if (fread(buf, 1, 4, ft->fp) != 4 || strncmp(buf, "AIFF", 4) != 0)
		fail("AIFF 'FORM' chunk does not specify 'AIFF' as type");

	/* Skip everything but the COMM chunk and the SSND chunk */
	/* The SSND chunk must be the last in the file */
	while (1) {
		if (fread(buf, 1, 4, ft->fp) != 4)
			fail("Missing SSND chunk in AIFF file");

		if (strncmp(buf, "COMM", 4) == 0) {
			/* COMM chunk */
			chunksize = rblong(ft);
			if (chunksize != 18)
				fail("AIFF COMM chunk has bad size");
			channels = rbshort(ft);
			frames = rblong(ft);
			bits = rbshort(ft);
			rate = read_ieee_extended(ft);
		}
		else if (strncmp(buf, "SSND", 4) == 0) {
			/* SSND chunk */
			chunksize = rblong(ft);
			offset = rblong(ft);
			blocksize = rblong(ft);
			break;
		}
		else {
			chunksize = rblong(ft);
			/* Skip the chunk using getc() so we may read
			   from a pipe */
			while ((long) (--chunksize) >= 0) {
				if (getc(ft->fp) == EOF)
					fail("unexpected EOF in AIFF chunk");
			}
		}
	}

	/* SSND chunk just read */
	if (blocksize != 0)
		fail("AIFF header specifies nonzero blocksize?!?!");
	while ((long) (--offset) >= 0) {
		if (getc(ft->fp) == EOF)
			fail("unexpected EOF while skipping AIFF offset");
	}

	ft->info.channels = channels;
	ft->info.rate = rate;
	ft->info.style = SIGN2;
	switch (bits) {
	case 8:
		ft->info.size = BYTE;
		break;
	case 16:
		ft->info.size = WORD;
		break;
	default:
		fail("unsupported sample size in AIFF header");
		/*NOTREACHED*/
	}
	endptr = (char *) &littlendian;
	*endptr = 1;
	if (littlendian == 1)
		ft->swap = 1;
}

/* When writing, the header is supposed to contain the number of
   samples and data bytes written.
   Since we don't know how many samples there are until we're done,
   we first write the header with an very large number,
   and at the end we rewind the file and write the header again
   with the right number.  This only works if the file is seekable;
   if it is not, the very large size remains in the header.
   Strictly spoken this is not legal, but the playaiff utility
   will still be able to play the resulting file. */

aiffstartwrite(ft)
ft_t ft;
{
	struct aiffpriv *p = (struct aiffpriv *) ft->priv;
	int littlendian = 0;
	char *endptr;

	p->nsamples = 0;
	if (ft->info.style == ULAW && ft->info.size == BYTE) {
		report("expanding 8-bit u-law to 16 bits");
		ft->info.size = WORD;
	}
	ft->info.style = SIGN2; /* We have a fixed style */
	/* Compute the "very large number" so that a maximum number
	   of samples can be transmitted through a pipe without the
	   risk of causing overflow when calculating the number of bytes.
	   At 48 kHz, 16 bits stereo, this gives ~3 hours of music.
	   Sorry, the AIFF format does not provide for an "infinite"
	   number of samples. */
	aiffwriteheader(ft, 0x7f000000 / (ft->info.size*ft->info.channels));

	endptr = (char *) &littlendian;
	*endptr = 1;
	if (littlendian == 1)
		ft->swap = 1;
}

aiffwrite(ft, buf, len)
ft_t ft;
long *buf, len;
{
	struct aiffpriv *p = (struct aiffpriv *) ft->priv;
	p->nsamples += len;
	rawwrite(ft, buf, len);
}

void
aiffstopwrite(ft)
ft_t ft;
{
	struct aiffpriv *p = (struct aiffpriv *) ft->priv;
	if (!ft->seekable)
		return;
	if (fseek(ft->fp, 0L, 0) != 0)
		fail("can't rewind output file to rewrite AIFF header");
	aiffwriteheader(ft, p->nsamples / ft->info.channels);
}

aiffwriteheader(ft, nframes)
ft_t ft;
long nframes;
{
	int hsize =
		8 /*COMM hdr*/ + 18 /*COMM chunk*/ +
		8 /*SSND hdr*/ + 12 /*SSND chunk*/;
	int bits;

	if (ft->info.style == SIGN2 && ft->info.size == BYTE)
		bits = 8;
	else if (ft->info.style == SIGN2 && ft->info.size == WORD)
		bits = 16;
	else
		fail("unsupported output style/size for AIFF header");

	fputs("FORM", ft->fp); /* IFF header */
	wblong(ft, hsize + nframes * ft->info.size * ft->info.channels); /* file size */
	fputs("AIFF", ft->fp); /* File type */

	/* COMM chunk -- describes encoding (and #frames) */
	fputs("COMM", ft->fp);
	wblong(ft, (long) 18); /* COMM chunk size */
	wbshort(ft, ft->info.channels); /* nchannels */
	wblong(ft, nframes); /* number of frames */
	wbshort(ft, bits); /* sample width, in bits */
	write_ieee_extended(ft, (double)ft->info.rate);

	/* SSND chunk -- describes data */
	fputs("SSND", ft->fp);
	wblong(ft, 8 + nframes * ft->info.channels * ft->info.size); /* chunk size */
	wblong(ft, (long) 0); /* offset */
	wblong(ft, (long) 0); /* block size */
}

double ConvertFromIeeeExtended();

double read_ieee_extended(ft)
ft_t ft;
{
	char buf[10];
	if (fread(buf, 1, 10, ft->fp) != 10)
		fail("EOF while reading IEEE extended number");
	return ConvertFromIeeeExtended(buf);
}

write_ieee_extended(ft, x)
ft_t ft;
double x;
{
	char buf[10];
	ConvertToIeeeExtended(x, buf);
	/*
	report("converted %g to %o %o %o %o %o %o %o %o %o %o",
		x,
		buf[0], buf[1], buf[2], buf[3], buf[4],
		buf[5], buf[6], buf[7], buf[8], buf[9]);
	*/
	(void) fwrite(buf, 1, 10, ft->fp);
}


/*
 * C O N V E R T   T O   I E E E   E X T E N D E D
 */

/* Copyright (C) 1988-1991 Apple Computer, Inc.
 * All rights reserved.
 *
 * Machine-independent I/O routines for IEEE floating-point numbers.
 *
 * NaN's and infinities are converted to HUGE_VAL or HUGE, which
 * happens to be infinity on IEEE machines.  Unfortunately, it is
 * impossible to preserve NaN's in a machine-independent way.
 * Infinities are, however, preserved on IEEE machines.
 *
 * These routines have been tested on the following machines:
 *    Apple Macintosh, MPW 3.1 C compiler
 *    Apple Macintosh, THINK C compiler
 *    Silicon Graphics IRIS, MIPS compiler
 *    Cray X/MP and Y/MP
 *    Digital Equipment VAX
 *
 *
 * Implemented by Malcolm Slaney and Ken Turkowski.
 *
 * Malcolm Slaney contributions during 1988-1990 include big- and little-
 * endian file I/O, conversion to and from Motorola's extended 80-bit
 * floating-point format, and conversions to and from IEEE single-
 * precision floating-point format.
 *
 * In 1991, Ken Turkowski implemented the conversions to and from
 * IEEE double-precision format, added more precision to the extended
 * conversions, and accommodated conversions involving +/- infinity,
 * NaN's, and denormalized numbers.
 */

#ifndef HUGE_VAL
# define HUGE_VAL HUGE
#endif /*HUGE_VAL*/

# define FloatToUnsigned(f)      ((unsigned long)(((long)(f - 2147483648.0)) + 2147483647L) + 1)

ConvertToIeeeExtended(num, bytes)
double num;
char *bytes;
{
    int    sign;
    int expon;
    double fMant, fsMant;
    unsigned long hiMant, loMant;

    if (num < 0) {
        sign = 0x8000;
        num *= -1;
    } else {
        sign = 0;
    }

    if (num == 0) {
        expon = 0; hiMant = 0; loMant = 0;
    }
    else {
        fMant = frexp(num, &expon);
        if ((expon > 16384) || !(fMant < 1)) {    /* Infinity or NaN */
            expon = sign|0x7FFF; hiMant = 0; loMant = 0; /* infinity */
        }
        else {    /* Finite */
            expon += 16382;
            if (expon < 0) {    /* denormalized */
                fMant = ldexp(fMant, expon);
                expon = 0;
            }
            expon |= sign;
            fMant = ldexp(fMant, 32);          
            fsMant = floor(fMant); 
            hiMant = FloatToUnsigned(fsMant);
            fMant = ldexp(fMant - fsMant, 32); 
            fsMant = floor(fMant); 
            loMant = FloatToUnsigned(fsMant);
        }
    }
    
    bytes[0] = expon >> 8;
    bytes[1] = expon;
    bytes[2] = hiMant >> 24;
    bytes[3] = hiMant >> 16;
    bytes[4] = hiMant >> 8;
    bytes[5] = hiMant;
    bytes[6] = loMant >> 24;
    bytes[7] = loMant >> 16;
    bytes[8] = loMant >> 8;
    bytes[9] = loMant;
}


/*
 * C O N V E R T   F R O M   I E E E   E X T E N D E D  
 */

/* 
 * Copyright (C) 1988-1991 Apple Computer, Inc.
 * All rights reserved.
 *
 * Machine-independent I/O routines for IEEE floating-point numbers.
 *
 * NaN's and infinities are converted to HUGE_VAL or HUGE, which
 * happens to be infinity on IEEE machines.  Unfortunately, it is
 * impossible to preserve NaN's in a machine-independent way.
 * Infinities are, however, preserved on IEEE machines.
 *
 * These routines have been tested on the following machines:
 *    Apple Macintosh, MPW 3.1 C compiler
 *    Apple Macintosh, THINK C compiler
 *    Silicon Graphics IRIS, MIPS compiler
 *    Cray X/MP and Y/MP
 *    Digital Equipment VAX
 *
 *
 * Implemented by Malcolm Slaney and Ken Turkowski.
 *
 * Malcolm Slaney contributions during 1988-1990 include big- and little-
 * endian file I/O, conversion to and from Motorola's extended 80-bit
 * floating-point format, and conversions to and from IEEE single-
 * precision floating-point format.
 *
 * In 1991, Ken Turkowski implemented the conversions to and from
 * IEEE double-precision format, added more precision to the extended
 * conversions, and accommodated conversions involving +/- infinity,
 * NaN's, and denormalized numbers.
 */

#ifndef HUGE_VAL
# define HUGE_VAL HUGE
#endif /*HUGE_VAL*/

# define UnsignedToFloat(u)         (((double)((long)(u - 2147483647L - 1))) + 2147483648.0)

/****************************************************************
 * Extended precision IEEE floating-point conversion routine.
 ****************************************************************/

double ConvertFromIeeeExtended(bytes)
unsigned char *bytes;	/* LCN */
{
    double    f;
    int    expon;
    unsigned long hiMant, loMant;
    
    expon = ((bytes[0] & 0x7F) << 8) | (bytes[1] & 0xFF);
    hiMant    =    ((unsigned long)(bytes[2] & 0xFF) << 24)
            |    ((unsigned long)(bytes[3] & 0xFF) << 16)
            |    ((unsigned long)(bytes[4] & 0xFF) << 8)
            |    ((unsigned long)(bytes[5] & 0xFF));
    loMant    =    ((unsigned long)(bytes[6] & 0xFF) << 24)
            |    ((unsigned long)(bytes[7] & 0xFF) << 16)
            |    ((unsigned long)(bytes[8] & 0xFF) << 8)
            |    ((unsigned long)(bytes[9] & 0xFF));

    if (expon == 0 && hiMant == 0 && loMant == 0) {
        f = 0;
    }
    else {
        if (expon == 0x7FFF) {    /* Infinity or NaN */
            f = HUGE_VAL;
        }
        else {
            expon -= 16383;
            f  = ldexp(UnsignedToFloat(hiMant), expon-=31);
            f += ldexp(UnsignedToFloat(loMant), expon-=32);
        }
    }

    if (bytes[0] & 0x80)
        return -f;
    else
        return f;
}

