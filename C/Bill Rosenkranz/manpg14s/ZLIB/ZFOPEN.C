#include "zdef.h"

/*------------------------------*/
/*	zfopen			*/
/*------------------------------*/
#ifndef __STDC__
ZFILE *zfopen (fileptr, how)
char   *fileptr;
char   *how;
#else
ZFILE *zfopen (char *fileptr, char *how)
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
	if (*how == 'r')
	{
#ifdef ALCYON
		z->file = fopenb (fileptr, "r");
#else
		z->file = fopen (fileptr, "rb");
#endif
		if (z->file == (FILE *) NULL)
		{
			char    tempfname[256];

			strcpy (tempfname, fileptr);
			strcat (tempfname, ZEXT);
#ifdef ALCYON
			z->file = fopenb (tempfname, "r");
#else
			z->file = fopen (tempfname, "rb");
#endif
		}
	}
	else
	{
		/*
		 *   No compressed output yet, if ever...
		 *   Compress the file explicitly once it has been written
		 */
#ifdef ALCYON
		z->file = fopenb (fileptr, how);
#else
		z->file = fopen (fileptr, how);
#endif
		z->flags |= NOT_COMPRESSED;
	}
	if (z->file == (FILE *) NULL)
	{
		free (z);
		z = (ZFILE *) NULL;
	}

	/*
	 *   Check the magic number
	 */
	if ((z != (ZFILE *) NULL)
	&& ((fgetc (z->file) != 0x1F) || (fgetc (z->file) != 0x9D)))
	{
		z->flags |= NOT_COMPRESSED;
		fclose (z->file);
#ifdef ALCYON
		z->file = fopenb (fileptr, how);
#else
		z->file = fopen (fileptr, how);
#endif
		if (z->file == (FILE *) NULL)
		{
			free (z);
			z = (ZFILE *) NULL;
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
			"%s: compressed with %d bits; decompress can only handle %d bits\n",
			fileptr, z->maxbits, Z_BITS);
		exit (0);
	}

	return ((ZFILE *) z);
}



