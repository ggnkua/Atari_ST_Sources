#undef FULL_SCREEN		/* def to write entire screen, not just wxh */


/*
 *	file.c - stuff for file operations (flicker file write, etc)
 */

/* Last changed by Bill 91/6/15 */
static char *sccsid  = "@(#) file.c 1.1 rosenkra(1.0)  92/11/09 Klockars\0\0";

/* #include <stdio.h>	Included via proto.h */
#include <osbind.h>
/* #include <fcntl.h> */
#include <string.h>
/* #include "mgif.h"	Included via "proto.h" */

#ifndef __LATTICE__
#include "proto.h"	/* Lattice C should have this precompiled */
#endif

#define reg_t		register
#define DBG(x)		/*printf x*/


#define NCHUNK		400
#define FLMAGSZ		10
#define FLHDRSZ		256
#define MAGIC		"FLICKER91a"


/*------------------------------*/
/*	write_fl		*/
/*------------------------------*/
int write_fl (fname, pscrn, w, h)
char   *fname;
int    *pscrn;
int	w;
int	h;
{
	char	       *pbuf;
	register long	i;
	register long	j;
/*	int		fd; */
	int		ival;
	FILE	       *stream;
	char		magic[FLMAGSZ+10];
	char		header[FLHDRSZ+10];
	char	       *pheader;
	char	       *pchar;
	int	       *pint;
	long	       *plong;
	int		nbytes;


	/*
	 *   open the .fl file...
	 */		/* NEW, was fopenb */
	if ((stream = fopen (fname, "wb")) == (FILE *) NULL)
	{
		printf ("Error openning %s.\n",
			fname);
		return (0);
	}

#ifdef __GNUC__
	stream->_flag |= _IOBIN;	/* The GNU libraries don't like "wb" */
#endif

/*	fd = fileno (stream); */


	/*
	 *   set up header. start with magic. there is no real header (yet).
	 *   just write nulls in unused portions
	 *
	 *	offset	size	item
	 *	------	----	-----------------------------------------
	 *	0	2	width (pixels)
	 *	2	2	height (pixels)
	 */
	strcpy (magic, MAGIC);
	/* align to word boundary */
	if ((long) (&header[0]) & 1L)	pheader = (char *) (&header[1]);
	else				pheader = (char *) (&header[0]);
	for (i = 0; i < FLHDRSZ; i++)
		pheader[i] = 0;
	if (w > 640)
		w = 640;
	if (h > 400)
		h = 400;
	pint = (int *) (&pheader[0]);	*pint = w;
	pint = (int *) (&pheader[2]);	*pint = h;


	/*
	 *   write .fl header...
	 */
	fwrite (magic,  1, FLMAGSZ, stream);
	fwrite (header, 1, FLHDRSZ, stream);


#ifdef FULL_SCREEN
	/*
	 *   write the screens, sequentially. each screen is 32000 and there
	 *   are 3 screens for a total of 96000 bytes. work with NCHUNK bytes
	 *   at a time.
	 */
	pbuf = (char *) pscrn;
	for (i = 0L; i < 96000L/NCHUNK; i++)	/* number of writes */
	{
		fwrite (pbuf, 1, NCHUNK, stream);

		pbuf += (long) NCHUNK;
	}
#else
	/*
	 *   only write what we need to the file for images smaller than
	 *   the screen...
	 */
	if ((int) w % 8)
		w += 8;
	nbytes = (w >> 3);
	pbuf = (char *) pscrn;
	for (i = 0L; i < h; i++)
	{
		fwrite (pbuf, 1, nbytes, stream);
		pbuf += 80L;
	}

	pbuf = (char *) ((long) pscrn + 32000L);
	for (i = 0L; i < h; i++)
	{
		fwrite (pbuf, 1, nbytes, stream);
		pbuf += 80L;
	}

	pbuf = (char *) ((long) pscrn + 64000L);
	for (i = 0L; i < h; i++)
	{
		fwrite (pbuf, 1, nbytes, stream);
		pbuf += 80L;
	}
#endif

	fclose (stream);

	return (1);
}





/*------------------------------*/
/*	read_fl			*/
/*------------------------------*/
int read_fl (fname, pscrn, w, h)
char   *fname;				/* file name (in) */
int    *pscrn;				/* where to put screen data (out) */
int    *w;				/* size of image, pixels (out) */
int    *h;
{

/*
 *	read the flicker file. return 0 if error else 1.
 */

	reg_t char     *pbuf;
	reg_t int      *pint;
	reg_t int	nbytes;
	reg_t int	nlines;
	reg_t long	ii;
/*	int		fd; */
	FILE	       *stream;
	char		magic[FLMAGSZ+10];
	char		header[FLHDRSZ+10];
	char	       *pheader;


	DBG (("enter read_fl...\n"));

	/*
	 *   open the .fl file, binary...
	 */		/* NEW, was fopenb */
	if ((stream = fopen (fname, "rb")) == (FILE *) NULL)
	{
		printf ("Error openning %s.\n", fname);
		return (0);
	}

#ifdef __GNUC__
	stream->_flag |= _IOBIN;	/* The GNU libraries don't like "rb" */
#endif

/*	fd = fileno (stream); */



	/*
	 *   read .fl magic
	 */
	fread (magic, 1, FLMAGSZ, stream);
	if (strncmp (magic, MAGIC, 10))
	{
		printf ("Bad magic here...\n");
		fclose (stream);
		return (0);
	}



	/*
	 *   read .fl header:
	 *
	 *	offset	size	item
	 *	------	----	-----------------------------------------
	 *	0	2	width (pixels)
	 *	2	2	height (pixels)
	 */		/* NEW, added (long) below) */
	if ((long)header & 1)		pheader = (char *) (&header[1]);
	else			pheader = (char *) (&header[0]);

	fread (pheader, 1, FLHDRSZ, stream);

	pint = &pheader[0];	*w = *pint;
	pint = &pheader[2];	*h = *pint;



#ifdef FULL_SCREEN
	/*
	 *   read the screens, sequentially. each screen is 32000 and there
	 *   are 3 screens for a total of 96000 bytes. work with NCHUNK bytes
	 *   at a time.
	 */
	pbuf = (char *) pscrn;
	for (ii = 0L; ii < 96000L/NCHUNK; ii++)	/* number of reads */
	{
		fread (pbuf, 1, NCHUNK, stream);

		pbuf += (long) NCHUNK;
	}
#else
	/*
	 *   this is space-saver version. we only need the actual pixels,
	 *   not the whole screen saved. find actual byte count for files
	 *   with w not evenly divisible by 8.
	 */
	if ((int) *w % 8)
		nbytes = ((*w + 8) >> 3);
	else
		nbytes = (*w >> 3);
	nlines = *h;

	/* screen 1 */
	for (pbuf = (char *) pscrn, ii = 0L; ii < nlines; ii++)
	{
		fread (pbuf, 1, nbytes, stream);
		pbuf += 80L;		/* 640x400 screen has 80 bytes/line */
	}

	/* screen 2 */
	for (pbuf = (char *) ((long) pscrn + 32000L), ii = 0L; ii < nlines; ii++)
	{
		fread (pbuf, 1, nbytes, stream);
		pbuf += 80L;
	}

	/* screen 3 */
	for (pbuf = (char *) ((long) pscrn + 64000L), ii = 0L; ii < nlines; ii++)
	{
		fread (pbuf, 1, nbytes, stream);
		pbuf += 80L;
	}
#endif


	/*
	 *   done. return success...
	 */
	fclose (stream);
	DBG (("read_fl returning...\n"));

	return (1);
}



