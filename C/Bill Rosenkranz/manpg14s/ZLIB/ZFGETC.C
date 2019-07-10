#include "zdef.h"

#include <proto.h>			/* for _PROTO macro... */

static void     decompress_more _PROTO((register ZFILE *z));
static long     getcode _PROTO((register ZFILE *z));

#define CR		0x0D
#define LF		0x0A

/*------------------------------*/
/*	zfgetc			*/
/*------------------------------*/
#ifndef __STDC__
int zfgetc (z)
ZFILE *z;
#else
int zfgetc (ZFILE *z)
#endif
{
	int     c;

	/* 
	 *   If buffer empty, and not end-of-file, call decompress_more();
	 *   return next in buffer.  
	 */
again:
	if ((z->flags & NOT_COMPRESSED) != 0)
	{
		if ((c = z->c1) >= 0)
		{
			z->c1 = z->c2;
			z->c2 = EOF;

			return ((int) c);
		}
again2:
		c = fgetc (z->file);
#ifdef ALCYON
		/*
		 *   see note below...
		 */
		if (c == CR)
			goto again2;
#endif
		return ((int) c);
	}
	if ((z->bufget == z->bufput) && (!z->zeof))
	{
		decompress_more (z);
	}
	z->zeof = (z->bufput == z->bufget);
	if (z->zeof)
	{
		if ((z->flags & ALLOCATED) != 0)
		{
#ifdef MSDOS
			hfree (z->tab_suffixof);
			hfree (z->tab_prefixof);
#else
			free (z->tab_suffixof);
			free (z->tab_prefixof);
#endif
			z->flags &= (~ALLOCATED);
		}
		return ((int) EOF);
	}
	c = z->buff[z->bufget];
	z->bufget++;

#ifdef MONITOR_CRLF
	if (c == CR)
		fprintf (stderr, "\n*** CR IN INPUT ***\n");
	if (c == LF)
		fprintf (stderr, "\n*** LF IN INPUT ***\n");
#endif

#ifdef ALCYON
	/*
	 *   at least with alcyon, fputc will write a cr-nl if c is nl so
	 *   skip past the cr we read. other libraries may or may not have
	 *   this problem...
	 */
	if (c == CR)
		goto again;
#endif

	return ((int) c);
}



/*------------------------------*/
/*	decompress_more		*/
/*------------------------------*/
#ifndef __STDC__
static void decompress_more (z)
register ZFILE *z;
#else
static void decompress_more (register ZFILE *z)
#endif
{
	z->bufput = 0;
	z->bufget = 0;

	if (z->init != 0)
		goto resume;

	z->init   = 1;
	z->offset = 0;
	z->size   = 0;

#ifdef MSDOS
	z->tab_suffixof =
		(unsigned char PC_HUGE *) halloc (HSIZE, sizeof (unsigned char));
	z->tab_prefixof =
		(long PC_HUGE *) halloc (HSIZE, sizeof (long));
#else
	z->tab_suffixof =
		(unsigned char *) malloc ((size_t) HSIZE * sizeof (unsigned char));
	z->tab_prefixof = (long *) malloc ((size_t) HSIZE * sizeof (long));
#endif
	z->flags |= ALLOCATED;

	z->n_bits  = INIT_BITS;
	z->maxcode = ((1L << (z->n_bits)) - 1L);
	for (z->code = 255L; z->code >= 0L; z->code--)
	{
		z->tab_prefixof[z->code] = 0L;
		z->tab_suffixof[z->code] = (unsigned char) z->code;
	}
	z->free_ent = ((z->block_compress) ? FIRST : 256L);

	z->finchar = z->oldcode = getcode (z);
	if (z->oldcode == -1L)
		return;			/* EOF already? */
	if (z->finchar < 0L || z->finchar >= 256L)
		fprintf (stderr, "****\n");
	z->buff[z->bufput] = (char) (z->finchar & 0xff);
	z->bufput++;

	z->stackp = 1L << Z_BITS;	/* The 1L is for DOS huge arrays */

	while ((z->code = getcode (z)) != EOF)
	{
		if ((z->code == CLEAR) && z->block_compress)
		{
			for (z->code = 255; z->code >= 0; z->code--)
				z->tab_prefixof[z->code] = 0;
			z->clear_flg = 1;
			z->free_ent  = FIRST - 1;
			if ((z->code = getcode (z)) == EOF)
				break;	/* O, untimely death! */
		}			/* if */
		z->incode = z->code;
		if (z->code >= z->free_ent)
		{
			z->tab_suffixof[z->stackp] = (unsigned char) z->finchar;
			z->stackp                 += 1L;
			z->code                    = z->oldcode;
		}
		while (z->code >= 256L)
		{
			z->tab_suffixof[z->stackp] = z->tab_suffixof[z->code];
			z->stackp                 += 1L;
			z->code                    = z->tab_prefixof[z->code];
		}
		z->finchar                 = z->tab_suffixof[z->code];
		z->tab_suffixof[z->stackp] = (unsigned char) z->finchar;
		z->stackp                 += 1L;
		do
		{
			long    tmp;

			z->stackp           -= 1L;
			tmp                  = z->tab_suffixof[z->stackp];
			z->buff[z->bufput++] = (unsigned char) (tmp & 255L);
			if (z->bufput == z->bufend)
			{
				/*
				 *   Logically a setjmp/longjump, but this
				 *   is more portable
				 */
				return;

				/*
				 *   jumped to here -- is jumping into a
				 *   loop safe?
				 *   - or should I use jumps for the loop too?
				 */
resume:				;
			}		/* if */

		} while (z->stackp > (1L << Z_BITS));
		/* ^ This is why I changed stackp from a pointer. */
		/* Pointer comparisons can be dubious...          */

		if ((z->code = z->free_ent) < (1L << z->maxbits))
		{
			z->tab_prefixof[z->code] = z->oldcode;
			z->tab_suffixof[z->code] = (unsigned char) z->finchar;
			z->free_ent              = z->code + 1;
		}
		z->oldcode = z->incode;
	}				/* while */
}

static unsigned char    rmask[9] =
{
	0x00, 0x01, 0x03, 0x07, 0x0f, 0x1f, 0x3f, 0x7f, 0xff
};


/*------------------------------*/
/*	getcode			*/
/*------------------------------*/
#ifndef __STDC__
static long getcode (z)
register ZFILE *z;
#else
static long getcode (register ZFILE *z)
#endif
{					/* Should be int!!! */
	register long   code;
	register long   r_off,
	                bits;
	register int    bp;

	bp = 0;
	if (z->clear_flg != 0 || z->offset >= z->size
	|| z->free_ent > z->maxcode)
	{
		if (z->free_ent > z->maxcode)
		{
			z->n_bits++;
			if (z->n_bits == z->maxbits)
			{
				z->maxcode = (1L << z->maxbits);
				/* won't get any bigger now */
			}
			else
			{
				z->maxcode = ((1L << (z->n_bits)) - 1L);
			}
		}
		if (z->clear_flg != 0)
		{
			z->n_bits    = INIT_BITS;
			z->maxcode   = ((1L << (z->n_bits)) - 1L);
			z->clear_flg = 0;
		}
		z->size = fread (z->buf, 1, (size_t) z->n_bits, z->file);
		if (z->size <= 0)
		{
			fclose (z->file);
			return ((long) EOF);	/* end of file */
		}
		z->offset = 0;
		z->size   = (z->size << 3) - (z->n_bits - 1);
	}
	r_off = z->offset;
	bits  = z->n_bits;
	bp    = bp + ((int) r_off >> 3);
	r_off = r_off & 7;
	code  = ((long) z->buf[bp++] >> r_off);
	bits  = bits - 8 + r_off;
	r_off = 8 - r_off;		/* now, offset into code word */
	if (bits >= 8)
	{
		code  = code | ((long) z->buf[bp++] << r_off);
		r_off = r_off + 8;
		bits  = bits - 8;
	}
	code = code
		| ((long) ((long) (z->buf[bp]) & (long) rmask[bits]) << (long) r_off);
	z->offset = z->offset + z->n_bits;

	return ((long) code);
}



