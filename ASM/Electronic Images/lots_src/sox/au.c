/*
 * September 25, 1991
 * Copyright 1991 Guido van Rossum And Sundry Contributors
 * This source code is freely redistributable and may be used for
 * any purpose.  This copyright notice must be maintained. 
 * Guido van Rossum And Sundry Contributors are not responsible for 
 * the consequences of using this software.
 */

/*
 * Sound Tools Sun format with header (SunOS 4.1; see /usr/demo/SOUND).
 * NeXT uses this format also, but has more format codes defined.
 * DEC uses a slight variation and swaps bytes.
 * We only support the common formats.
 * Output is always in big-endian (Sun/NeXT) order.
 */

#include "st.h"

/* Magic numbers used in Sun and NeXT audio files */
#define SUN_MAGIC 	0x2e736e64		/* Really '.snd' */
#define SUN_INV_MAGIC	0x646e732e		/* '.snd' upside-down */
#define DEC_MAGIC	0x2e736400		/* Really '\0ds.' (for DEC) */
#define DEC_INV_MAGIC	0x0064732e		/* '\0ds.' upside-down */
#define SUN_HDRSIZE	24			/* Size of minimal header */
#define SUN_UNSPEC	((unsigned)(~0))	/* Unspecified data size */
#define SUN_ULAW	1			/* u-law encoding */
#define SUN_LIN_8	2			/* Linear 8 bits */
#define SUN_LIN_16	3			/* Linear 16 bits */
#define SUN_LIN_24	4			/* Linear 24 bits */
#define SUN_LIN_32	5			/* Linear 32 bits */
#define SUN_FLOAT	6			/* IEEE FP 32 bits */
#define SUN_DOUBLE	7			/* IEEE FP 64 bits */
/* The other formats are not supported by sox at the moment */

/* Private data used by writer */
struct aupriv {
	unsigned long data_size;
};

IMPORT auwriteheader(P2(ft_t ft, unsigned long data_size));

austartread(ft) 
ft_t ft;
{
	/* The following 6 variables represent a Sun sound header on disk.
	   The numbers are written as big-endians.
	   Any extra bytes (totalling hdr_size - 24) are an
	   "info" field of unspecified nature, usually a string.
	   By convention the header size is a multiple of 4. */
	unsigned long magic;
	unsigned long hdr_size;
	unsigned long data_size;
	unsigned long encoding;
	unsigned long sample_rate;
	unsigned long channels;

	register int i;
	char *buf;


	/* Check the magic word */
	magic = rlong(ft);
	if (magic == DEC_INV_MAGIC) {
		ft->swap = 1;
		report("Found inverted DEC magic word");
	}
	else if (magic == SUN_INV_MAGIC) {
		ft->swap = 1;
		report("Found inverted Sun/NeXT magic word");
	}
	else if (magic == SUN_MAGIC) {
		ft->swap = 0;
		report("Found Sun/NeXT magic word");
	}
	else if (magic == DEC_MAGIC) {
		ft->swap = 0;
		report("Found DEC magic word");
	}
	else
		fail("Sun/NeXT/DEC header doesn't start with magic word\nTry the '.ul' file type with '-t ul -r 8000 filename'");

	/* Read the header size */
	hdr_size = rlong(ft);
	if (hdr_size < SUN_HDRSIZE)
		fail("Sun/NeXT header size too small.");

	/* Read the data size; may be ~0 meaning unspecified */
	data_size = rlong(ft);

	/* Read the encoding; there are some more possibilities */
	encoding = rlong(ft);

	/* Translate the encoding into style and size parameters */
	switch (encoding) {
	case SUN_ULAW:
		ft->info.style = ULAW;
		ft->info.size = BYTE;
		break;
	case SUN_LIN_8:
		ft->info.style = SIGN2;
		ft->info.size = BYTE;
		break;
	case SUN_LIN_16:
		ft->info.style = SIGN2;
		ft->info.size = WORD;
		break;
	default:
		report("encoding: 0x%lx", encoding);
		fail("Unsupported encoding in Sun/NeXT header.\nOnly U-law, signed bytes, and signed words are supported.");
		/*NOTREACHED*/
	}

	/* Read the sampling rate */
	sample_rate = rlong(ft);
	ft->info.rate = sample_rate;

	/* Read the number of channels */
	channels = rlong(ft);
	ft->info.channels = channels;

	/* Skip the info string in header; print it if verbose */
	hdr_size -= SUN_HDRSIZE; /* #bytes already read */
	if (hdr_size > 0) {
		buf = (char *) malloc(hdr_size + 1);
		for(i = 0; i < hdr_size; i++) {
			buf[i] = (char) getc(ft->fp);
			if (feof(ft->fp))
				fail("Unexpected EOF in Sun/NeXT header info.");
		}
		buf[i] = '\0';
		ft->comment = buf;
		report("Input file %s: Sun header info: %s", ft->filename, buf);
	}
}

/* When writing, the header is supposed to contain the number of
   data bytes written, unless it is written to a pipe.
   Since we don't know how many bytes will follow until we're done,
   we first write the header with an unspecified number of bytes,
   and at the end we rewind the file and write the header again
   with the right size.  This only works if the file is seekable;
   if it is not, the unspecified size remains in the header
   (this is legal). */

austartwrite(ft) 
ft_t ft;
{
	struct aupriv *p = (struct aupriv *) ft->priv;
	int littlendian = 0;
	char *endptr;

	p->data_size = 0;
	auwriteheader(ft, SUN_UNSPEC);
	endptr = (char *) &littlendian;
	*endptr = 1;
	if (littlendian == 1)
		ft->swap = 1;
}

auwrite(ft, buf, samp)
ft_t ft;
long *buf, samp;
{
	struct aupriv *p = (struct aupriv *) ft->priv;
	p->data_size += samp * ft->info.size;
	rawwrite(ft, buf, samp);
}

void
austopwrite(ft)
ft_t ft;
{
	struct aupriv *p = (struct aupriv *) ft->priv;
	if (!ft->seekable)
		return;
	if (fseek(ft->fp, 0L, 0) != 0)
		fail("Can't rewind output file to rewrite Sun header.");
	auwriteheader(ft, p->data_size);
}

auwriteheader(ft, data_size)
ft_t ft;
unsigned long data_size;
{
	unsigned long magic;
	unsigned long hdr_size;
	unsigned long encoding;
	unsigned long sample_rate;
	unsigned long channels;

	if (ft->info.style == ULAW && ft->info.size == BYTE)
		encoding = SUN_ULAW;
	else if (ft->info.style == SIGN2 && ft->info.size == BYTE)
		encoding = SUN_LIN_8;
	else if (ft->info.style == SIGN2 && ft->info.size == WORD)
		encoding = SUN_LIN_16;
	else {
/*		fail("Unsupported output style/size for Sun/NeXT header.  \nOnly U-law, signed bytes, and signed words are supported."); /* */
		report("SUN .AU format not specified.  Defaulting to 8khz u-law");
		encoding = SUN_ULAW;
		ft->info.style = ULAW;
		ft->info.size = BYTE;
		ft->info.rate = 8012;  /* strange but true */
	}

	magic = SUN_MAGIC;
	wblong(ft, magic);

	/* hdr_size = SUN_HDRSIZE;		/* + strlen(ft->comment); */
	hdr_size = SUN_HDRSIZE + strlen(ft->comment);
	wblong(ft, hdr_size);

	wblong(ft, data_size);

	wblong(ft, encoding);

	sample_rate = ft->info.rate;
	wblong(ft, sample_rate);

	channels = ft->info.channels;
	wblong(ft, channels);

	fputs(ft->comment, ft->fp);
}

