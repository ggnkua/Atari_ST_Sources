#include "zdef.h"

/*------------------------------*/
/*	zfilter			*/
/*------------------------------*/
#ifndef __STDC__
ZFILE *zfilter (f)
FILE   *f;
#else
ZFILE *zfilter (FILE *f)
#endif
{
	register ZFILE *z;

	z = (ZFILE *) malloc (sizeof (ZFILE));
	z->flags          = 0;
	z->maxbits        = Z_BITS;	/* user settable max # bits/code */
	z->free_ent       = 0;		/* first unused entry */
	z->block_compress = BLOCK_MASK;
	z->clear_flg      = 0;
	z->init           = 0;

	z->zeof           = (0 != 0);
	z->c1             = EOF;
	z->c2             = EOF;
	z->bufput         = 0;
	z->bufget         = 0;
	z->bufend         = Z_MAXBUF - 1;

	z->maxbits        = Z_BITS;	/* user settable max # bits/code */

	/*
	 *   Open input file
	 */
	z->file = f;
	if (z->file == (FILE *) NULL)
	{
		free (z);
		z = (ZFILE *) NULL;
	}

	/*
	 *   Check the magic number
	 */
	if (z != (ZFILE *) NULL)
	{
		z->c1 = fgetc (z->file);
		z->c2 = fgetc (z->file);
		if ((z->c1 != 0x1F) || (z->c2 != 0x9D))
		{
			z->flags |= NOT_COMPRESSED;
		}
	}
	if ((z == (ZFILE *) NULL) || ((z->flags & NOT_COMPRESSED) != 0))
		return ((ZFILE *) z);

	z->maxbits        = fgetc (z->file);	/* set -b from file */
	z->block_compress = z->maxbits & BLOCK_MASK;
	z->maxbits       &= BIT_MASK;

	if (z->maxbits > Z_BITS)
	{
		fprintf (stderr,
			"stdin compressed with %d bits; decompress can only handle %d bits\n",
			z->maxbits, Z_BITS);
		exit (0);
	}
	return ((ZFILE *) z);
}



