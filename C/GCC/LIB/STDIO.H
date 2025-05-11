/*
 * stdio.h
 *
 * this version kludged up by jrd
 */

/* files are really pointers to something, but that isn't visible to standard
   code */
#define	FILE	long
#define	EOF	-1

#ifndef NULL
#define NULL	(void *)0
#endif

/* standard files */
extern FILE * stdin, * stdout, * stderr;

/* and code to hack them */
extern FILE * fopen(), * freopen(), * fdopen();

extern int fgetc();
extern char * fgets();
extern char * gets();

/* more eunuchs compatibility brain damage... */
#define putc	fputc
#define	getc	fgetc
#define putchar(c)	fputc(c, stdout)
#define getchar()	fgetc(stdin)

/* this is so unbelievably brain-dead I can't think of an epithet
   that accurately describes it.  No, it has no use at all, other
   than to support eunuchs code that doesn't believe in modularity
   or functional boundaries.  That is, most of it.... */
#define BUFSIZ	512
