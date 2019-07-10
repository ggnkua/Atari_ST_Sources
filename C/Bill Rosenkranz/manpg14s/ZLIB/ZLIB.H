#ifndef _ZLIB_H
#define _ZLIB_H 1

#include <proto.h>			/* for _PROTO macro... */

#ifdef ALCYON
# ifndef void
#  define void		int
# endif
#endif

#ifdef MSDOS
# define PC_HUGE	huge		/* Microsoft C and contemptibles */
#else
# define PC_HUGE
#endif

#define ZEXT		".Z"		/* "normal" compressed file ext */

#ifdef __arm
# undef ZEXT
# define ZEXT		"-z"
#endif

#define Z_BITS		16
#define Z_MAXBUF	256

/*
 *	the major data structure, ZFILE
 */
typedef struct zfiletype
{
	FILE	       *file;
	int		flags;
	int     	n_bits;		/* number of bits/code */
	int     	maxbits;	/* user settable max # bits/code */
	long    	maxcode;	/* maximum code, given n_bits */
	long    	free_ent;	/* first unused entry */
	int     	block_compress;
	int     	clear_flg;

	long    	stackp;
	long    	finchar;
	long    	code,
	        	oldcode,
	        	incode;
	int     	offset,
	        	size;
	unsigned char   buf[Z_BITS];	/* Passed to getcode */
	unsigned char PC_HUGE *tab_suffixof;
					/* There is a flag bit to say whether */
	long PC_HUGE   *tab_prefixof;	/* these have been allocated.         */
	int     	init;

	int     	bufput,
	        	bufget,
	        	bufend;
	unsigned char   buff[Z_MAXBUF];
	int     	c1,
	        	c2;
	int     	zeof;

} ZFILE;


/*
 *	fcn prototypes...
 */
ZFILE  *zfopen _PROTO((char *fileptr, char *how));
void    zfclose _PROTO((ZFILE *z));
ZFILE  *zfilter _PROTO((FILE *f));
int     zfgetc _PROTO((ZFILE *z));
int     zfeof _PROTO((ZFILE *z));
char   *zfgets _PROTO((char *line, int len, ZFILE *zfp));

#endif /*_ZLIB_H*/
