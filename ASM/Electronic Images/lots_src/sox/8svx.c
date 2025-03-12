/*
 * Amiga 8SVX format handler: W V Neisius, February 1992
 */

#ifdef	unix
#include <sys/types.h>
#endif
#include <math.h>
#include <errno.h>
#ifdef	VMS
#include <perror.h>
#endif
#include "st.h"

/* Private data used by writer */
struct svxpriv {
        unsigned long nsamples;
	FILE *ch[4];
};

#ifndef SEEK_CUR
#define SEEK_CUR        1
#endif
#ifndef SEEK_SET
#define SEEK_SET        0
#endif

/*======================================================================*/
/*                         8SVXSTARTREAD                                */
/*======================================================================*/

svxstartread(ft)
ft_t ft;
{
	struct svxpriv *p = (struct svxpriv *) ft->priv;

	char buf[12];
	char *endptr;
	char *chunk_buf;

	unsigned long totalsize;
	unsigned long chunksize;

	int channels;
	long rate;
	int littlendian = 0;
	int i;

	unsigned long chan1_pos;

	rate = 0;
	channels = 1;

	/* read FORM chunk */
	if (fread(buf, 1, 4, ft->fp) != 4 || strncmp(buf, "FORM", 4) != 0)
		fail("8SVX: header does not begin with magic word 'FORM'");
	totalsize = rblong(ft);
	if (fread(buf, 1, 4, ft->fp) != 4 || strncmp(buf, "8SVX", 4) != 0)
		fail("8SVX: 'FORM' chunk does not specify '8SVX' as type");

	/* read chunks until 'BODY' (or end) */
	while (fread(buf,1,4,ft->fp) == 4 && strncmp(buf,"BODY",4) != 0) {
		if (strncmp(buf,"VHDR",4) == 0) {
			chunksize = rblong(ft);
			if (chunksize != 20)
				fail ("8SVX: VHDR chunk has bad size");
			fseek(ft->fp,12,SEEK_CUR);
			rate = rbshort(ft);
			fseek(ft->fp,1,SEEK_CUR);
			fread(buf,1,1,ft->fp);
			if (buf[0] != 0)
				fail ("8SVX: unsupported data compression");
			fseek(ft->fp,4,SEEK_CUR);
			continue;
		}

		if (strncmp(buf,"ANNO",4) == 0) {
			chunksize = rblong(ft);
			if (chunksize & 1)
				chunksize++;
			chunk_buf = (char *) malloc(chunksize + 1);
			if (fread(chunk_buf,1,(size_t)chunksize,ft->fp) 
					!= chunksize)
				fail("8SVX: Unexpected EOF in ANNO header");
			chunk_buf[chunksize] = '\0';
			report ("%s",chunk_buf);
			free(chunk_buf);

			continue;
		}

		if (strncmp(buf,"NAME",4) == 0) {
			chunksize = rblong(ft);
			if (chunksize & 1)
				chunksize++;
			chunk_buf = (char *) malloc(chunksize + 1);
			if (fread (chunk_buf,1,(size_t)chunksize,ft->fp) 
					!= chunksize)
				fail("8SVX: Unexpected EOF in NAME header");
			chunk_buf[chunksize] = '\0';
			report ("%s",chunk_buf);
			free(chunk_buf);

			continue;
		}

		if (strncmp(buf,"CHAN",4) == 0) {
			chunksize = rblong(ft);
			if (chunksize != 4) 
				fail("8SVX: Short channel chunk");
			channels = rblong(ft);
			channels = (channels & 0x01) + 
					((channels & 0x02) >> 1) +
				   	((channels & 0x04) >> 2) + 
					((channels & 0x08) >> 3);

			continue;
		}

		/* some other kind of chunk */
		chunksize = rblong(ft);
		if (chunksize & 1)
			chunksize++;
		fseek(ft->fp,chunksize,SEEK_CUR);
		continue;

	}

	if (rate == 0)
		fail ("8SVX: invalid rate");
	if (strncmp(buf,"BODY",4) != 0)
		fail ("8SVX: BODY chunk not found");
	p->nsamples = rblong(ft);

	ft->info.channels = channels;
	ft->info.rate = rate;
	ft->info.style = SIGN2;
	ft->info.size = BYTE;

	/* open files to channels */
	p->ch[0] = ft->fp;
	chan1_pos = ftell(p->ch[0]);

	for (i = 1; i < channels; i++) {
		if ((p->ch[i] = fopen(ft->filename, READBINARY)) == NULL)
			fail("Can't open channel file '%s': %s",
				ft->filename, strerror(errno));

		/* position channel files */
		if (fseek(p->ch[i],chan1_pos,SEEK_SET))
		    fail ("Can't position channel %d: %s",i,strerror(errno));
		if (fseek(p->ch[i],p->nsamples/channels*i,SEEK_CUR))
		    fail ("Can't seek channel %d: %s",i,strerror(errno));
	}


	endptr = (char *) &littlendian;
	*endptr = 1;
	if (littlendian == 1)
		ft->swap = 1;

}

/*======================================================================*/
/*                         8SVXREAD                                     */
/*======================================================================*/
svxread(ft, buf, nsamp) 
ft_t ft;
long *buf, nsamp;
{
	register unsigned long datum;
	int done = 0;
	int i;

	struct svxpriv *p = (struct svxpriv *) ft->priv;

	while (done < nsamp) {
		for (i = 0; i < ft->info.channels; i++) {
			datum = getc(p->ch[i]);
			if (feof(p->ch[i]))
				return done;
			/* scale signed up to long's range */
			*buf++ = LEFT(datum, 24);
		}
		done += ft->info.channels;
	}
	return done;
}

/*======================================================================*/
/*                         8SVXSTOPREAD                                 */
/*======================================================================*/
svxstopread(ft)
ft_t ft;
{
	int i;

	struct svxpriv *p = (struct svxpriv *) ft->priv;

	/* close channel files */
	for (i = 1; i < ft->info.channels; i++) {
		fclose (p->ch[i]);
	}
}

/*======================================================================*/
/*                         8SVXSTARTWRITE                               */
/*======================================================================*/
svxstartwrite(ft)
ft_t ft;
{
	struct svxpriv *p = (struct svxpriv *) ft->priv;
	int littlendian = 0;
	int i;
	char *endptr;

	/* open channel output files */
	p->ch[0] = ft->fp;
	for (i = 1; i < ft->info.channels; i++) {
		if ((p->ch[i] = tmpfile()) == NULL)
			fail("Can't open channel output file: %s",
				strerror(errno));
	}

	/* write header (channel 0) */
	ft->info.style = SIGN2;
	ft->info.size = BYTE;

	p->nsamples = 0;
	svxwriteheader(ft, p->nsamples);

	endptr = (char *) &littlendian;
	*endptr = 1;
	if (littlendian == 1)
		ft->swap = 1;
}

/*======================================================================*/
/*                         8SVXWRITE                                    */
/*======================================================================*/

svxwrite(ft, buf, len)
ft_t ft;
long *buf, len;
{
	struct svxpriv *p = (struct svxpriv *) ft->priv;

	register long datum;
	int done = 0;
	int i;

	p->nsamples += len;

	while(done < len) {
		for (i = 0; i < ft->info.channels; i++) {
			datum = RIGHT(*buf++, 24);
			putc((int)datum, p->ch[i]);
		}
		done += ft->info.channels;
	}
}

/*======================================================================*/
/*                         8SVXSTOPWRITE                                */
/*======================================================================*/

svxstopwrite(ft)
ft_t ft;
{
	struct svxpriv *p = (struct svxpriv *) ft->priv;

	int i;
	int len;
	char svxbuf[512];

	/* append all channel pieces to channel 0 */
	/* close temp files */
	for (i = 1; i < ft->info.channels; i++) {
		if (fseek (p->ch[i], 0L, 0))
			fail ("Can't rewind channel output file %d",i);
		while (!feof(p->ch[i])) {
			len = fread (svxbuf, 1, 512, p->ch[i]);
			fwrite (svxbuf, 1, len, p->ch[0]);
		}
		fclose (p->ch[i]);
	}

	/* fixup file sizes in header */
	if (fseek(ft->fp, 0L, 0) != 0)
		fail("can't rewind output file to rewrite 8SVX header");
	svxwriteheader(ft, p->nsamples);
}

/*======================================================================*/
/*                         8SVXWRITEHEADER                              */
/*======================================================================*/
#define SVXHEADERSIZE 100
svxwriteheader(ft,nsamples)
ft_t ft;
long nsamples;
{
	fputs ("FORM", ft->fp);
	wblong(ft, nsamples + SVXHEADERSIZE - 8);  /* size of file */
	fputs("8SVX", ft->fp); /* File type */

	fputs ("VHDR", ft->fp);
	wblong(ft, (long) 20); /* number of bytes to follow */
	wblong(ft, nsamples);  /* samples, 1-shot */
	wblong(ft, (long) 0);  /* samples, repeat */
	wblong(ft, (long) 0);  /* samples per repeat cycle */
	wbshort(ft, (int) ft->info.rate); /* samples per second */
	fputc(1,ft->fp); /* number of octaves */
	fputc(0,ft->fp); /* data compression (none) */
	wbshort(ft,1); wbshort(ft,0); /* volume */

	fputs ("ANNO", ft->fp);
	wblong(ft, (long) 32); /* length of block */
	fputs ("File created by Sound Exchange  ", ft->fp);

	fputs ("CHAN", ft->fp);
	wblong(ft, (long) 4);
	wblong(ft, (ft->info.channels == 2) ? (long) 6 :
		   (ft->info.channels == 4) ? (long) 15 : (long) 2);

	fputs ("BODY", ft->fp);
	wblong(ft, nsamples); /* samples in file */
}
