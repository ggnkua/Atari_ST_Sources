/*
 * July 5, 1991
 * Copyright 1991 Lance Norskog And Sundry Contributors
 * This source code is freely redistributable and may be used for
 * any purpose.  This copyright notice must be maintained. 
 * Lance Norskog And Sundry Contributors are not responsible for 
 * the consequences of using this software.
 */

/*
 * Sound Tools Sound Blaster VOC handler sources.
 *
 * Outstanding problem: the Sound Blaster DMA clock is 8 bits wide,
 * giving spotty resolution above 10khz.  voctartwrite() should check
 * the given output rate and make sure it's +-1% what the SB can
 * actually do.  Other format drivers should do similar checks.
 */

#include "st.h"

/* Private data for VOC file */
typedef struct vocstuff {
	long	rest;			/* bytes remaining in current block */
	long	rate;			/* rate code (byte) of this chunk */
	int	silent;			/* sound or silence? */
	long	srate;			/* rate code (byte) of silence */
	int	blockseek;		/* start of current output block */
	long	samples;		/* number of samples output */
} *vs_t;

#define	VOC_TERM	0
#define	VOC_DATA	1
#define	VOC_CONT	2
#define	VOC_SILENCE	3
#define	VOC_MARKER	4
#define	VOC_TEXT	5
#define	VOC_LOOP	6
#define	VOC_LOOPEND	7

#define	min(a, b)	(((a) < (b)) ? (a) : (b))

IMPORT int summary, verbose;
void getblock();

vocstartread(ft) 
ft_t ft;
{
	char header[20];
	vs_t v = (vs_t) ft->priv;
	int sbseek;

	if (! ft->seekable)
		fail("VOC input file must be a file, not a pipe");
	if (fread(header, 1, 20, ft->fp) != 20)
		fail("unexpected EOF in VOC header");
	if (strncmp(header, "Creative Voice File\032", 19))
		fail("VOC file header incorrect");

	sbseek = rlshort(ft);
	fseek(ft->fp, sbseek, 0);

	v->rate = -1;
	v->rest = 0;
	getblock(ft);
	if (v->rate == -1)
		fail("Input .voc file had no sound!");

	ft->info.rate = 1000000.0/(256 - v->rate);
	ft->info.size = BYTE;
	ft->info.style = UNSIGNED;
	if (ft->info.channels == -1)
		ft->info.channels = 1;
}

vocread(ft, buf, len) 
ft_t ft;
long *buf, len;
{
	vs_t v = (vs_t) ft->priv;
	int done = 0;
	
	if (v->rest == 0)
		getblock(ft);
	if (v->rest == 0)
		return 0;

	if (v->silent) {
		/* Fill in silence */
		for(;v->rest && (done < len); v->rest--, done++)
			*buf++ = 0x80000000;
	} else {
		for(;v->rest && (done < len); v->rest--, done++) {
			long l;
			if ((l = getc(ft->fp)) == EOF) {
				fail("VOC input: short file"); /* */
				v->rest = 0;
				return 0;
			}
			l ^= 0x80;	/* convert to signed */
			*buf++ = LEFT(l, 24);
		}
	}
	return done;
}

/* nothing to do */
vocstopread(ft) 
ft_t ft;
{
}

vocstartwrite(ft) 
ft_t ft;
{
	vs_t v = (vs_t) ft->priv;

	if (! ft->seekable)
		fail("Output .voc file must be a file, not a pipe");

	v->samples = 0;

	/* File format name and a ^Z (aborts printing under DOS) */
	(void) fwrite("Creative Voice File\032\032", 1, 20, ft->fp);
	wlshort(ft, 26);			/* size of header */
	wlshort(ft, 0x10a);                     /* major/minor version number */
	wlshort(ft, 0x1129);			/* checksum of version number */

	ft->info.size = BYTE;
	ft->info.style = UNSIGNED;
	if (ft->info.channels == -1)
		ft->info.channels = 1;
}

vocwrite(ft, buf, len) 
ft_t ft;
long *buf, len;
{
	vs_t v = (vs_t) ft->priv;
	unsigned char uc;

	v->rate = 256 - (1000000.0/(float)ft->info.rate);	/* Rate code */
	if (v->samples == 0) {
		/* No silence packing yet. */
		v->silent = 0;
		blockstart(&outformat);
	}
	v->samples += len;
	while(len--) {
		uc = RIGHT(*buf++, 24);
		uc ^= 0x80;
		putc(uc, ft->fp);
	}
}

vocstopwrite(ft) 
ft_t ft;
{
	blockstop(ft);
}

/* Voc-file handlers */

/* Read next block header, save info, leave position at start of data */
void
getblock(ft)
ft_t ft;
{
	vs_t v = (vs_t) ft->priv;
	unsigned char uc, block;
	unsigned long sblen;
	int i;

	v->silent = 0;
	while (v->rest == 0) {
		if (feof(ft->fp))
			return;
		block = getc(ft->fp);
		if (block == VOC_TERM)
			return;
		if (feof(ft->fp))
			return;
		uc = getc(ft->fp);
		sblen = uc;
		uc = getc(ft->fp);
		sblen |= ((long) uc) << 8;
		uc = getc(ft->fp);
		sblen |= ((long) uc) << 16;
		switch(block) {
		case VOC_DATA: 
			uc = getc(ft->fp);
			if (uc == 0)
			   fail("File %s: Sample rate is zero?");
			if ((v->rate != -1) && (uc != v->rate))
			   fail("File %s: sample rate codes differ: %d != %d",
					v->rate, uc);
			v->rate = uc;
			uc = getc(ft->fp);
			if (uc != 0)
				fail("File %s: only interpret 8-bit data!");
			v->rest = sblen - 2;
			return;
		case VOC_CONT: 
			v->rest = sblen;
			return;
		case VOC_SILENCE: 
			{
			unsigned short period;

			period = rlshort(ft);
			uc = getc(ft->fp);
			if (uc == 0)
				fail("File %s: Silence sample rate is zero");
			/* 
			 * Some silence-packed files have gratuitously
			 * different sample rate codes in silence.
			 * Adjust period.
			 */
			if ((v->rate != -1) && (uc != v->rate))
				period = (period * (256 - uc))/(256 - v->rate);
			else
				v->rate = uc;
			v->rest = period;
			v->silent = 1;
			return;
			}
		case VOC_MARKER:
			uc = getc(ft->fp);
			uc = getc(ft->fp);
			/* Falling! Falling! */
		case VOC_TEXT:
			{
			int i;
			/* Could add to comment in SF? */
			for(i = 0; i < sblen; i++)
				getc(ft->fp);
			}
			continue;	/* get next block */
		case VOC_LOOP:
		case VOC_LOOPEND:
			report("File %s: skipping repeat loop");
			for(i = 0; i < sblen; i++)
				getc(ft->fp);
			break;
		default:
			report("File %s: skipping unknown block code %d",
				ft->filename, block);
			for(i = 0; i < sblen; i++)
				getc(ft->fp);
		}
	}
}

/* Start an output block. */
blockstart(ft)
ft_t ft;
{
	vs_t v = (vs_t) ft->priv;

	v->blockseek = ftell(ft->fp);
	if (v->silent) {
		putc(VOC_SILENCE, ft->fp);	/* Silence block code */
		putc(0, ft->fp);		/* Period length */
		putc(0, ft->fp);		/* Period length */
		putc((int) v->rate, ft->fp);		/* Rate code */
	} else {
		putc(VOC_DATA, ft->fp);		/* Voice Data block code */
		putc(0, ft->fp);		/* block length (for now) */
		putc(0, ft->fp);		/* block length (for now) */
		putc(0, ft->fp);		/* block length (for now) */
		putc((int) v->rate, ft->fp);		/* Rate code */
		putc(0, ft->fp);		/* 8-bit raw data */
	}
}

/* End the current data or silence block. */
blockstop(ft) 
ft_t ft;
{
	vs_t v = (vs_t) ft->priv;
	long datum;

	putc(0, ft->fp);			/* End of file block code */
	fseek(ft->fp, v->blockseek, 0);		/* seek back to block length */
	fseek(ft->fp, 1, 1);			/* seek forward one */
	if (v->silent) {
		datum = (v->samples) & 0xff;
		putc((int)datum, ft->fp);       /* low byte of length */
		datum = (v->samples >> 8) & 0xff;
		putc((int)datum, ft->fp);  /* high byte of length */
	} else {
		v->samples += 2;		/* adjustment: SBDK pp. 3-5 */
		datum = (v->samples) & 0xff;
		putc((int)datum, ft->fp);       /* low byte of length */
		datum = (v->samples >> 8) & 0xff;
		putc((int)datum, ft->fp);  /* middle byte of length */
		datum = (v->samples >> 16) & 0xff;
		putc((int)datum, ft->fp); /* high byte of length */
	}
}

