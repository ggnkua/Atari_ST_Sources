/**
*	SREC Definitions
**/

#define TRUE	1
#define FALSE	0
#define YES	1
#define NO	0
#define EOS	'\0'			/* end-of-string constant */
#define MAXSTR	256			/* maximum string size + 1 */

/*
* The following definitions are for Macintosh Lightspeed C since that
* environment does not support command line DEFINEs.  Remove comments
* as necessary.
*/
/*
#define MAC		1
#define LSC		1
*/

/**
*	Environment Definitions (zero here; may be redefined at compile time)
**/

#ifndef MSDOS
#define MSDOS		0		/* MS-DOS operating system */
#endif
#ifndef VMS
#define VMS		0		/* VMS operating system */
#endif
#ifndef ATT
#define ATT		0		/* AT&T Unix */
#endif
#ifndef BSD
#define BSD		0		/* Berkeley Unix */
#endif
#ifndef MACH
#define MACH		0		/* NeXT Mach */
#endif
#ifdef UNIX
#undef UNIX
#endif
#define UNIX		(ATT || BSD || MACH)	/* generic Unix OS */
#ifndef MAC
#define MAC		0		/* Macintosh operating system */
#endif

#ifndef MSC
#define MSC		0		/* Microsoft C compiler */
#endif
#ifndef VAXC
#define VAXC		0		/* VAX C compiler */
#endif
#ifndef LSC
#define LSC		0		/* Lightspeed C compiler */
#endif
#ifndef MPW
#define MPW		0		/* MPW C (Macintosh) */
#endif
#ifndef AZTEC
#define AZTEC		0		/* Aztec C (Macintosh) */
#endif

#if BSD
#define strchr	index
#define strrchr	rindex
#else
#define index	strchr
#define rindex	strrchr
#endif

#if AZTEC		/* text file routine redefintion for Aztec */
#ifdef fgetc
#undef fgetc
#endif
#define	fgetc	agetc
#ifdef fputc
#undef fputc
#endif
#define	fputc	aputc
#endif

#if VMS				/* exit status values */
#define OK	0x18000001L
#define	ERR	0x1800FFFBL
#define CLI_ABSENT	CLI$_ABSENT
#else
#define OK	0
#define ERR	1
#define CLI_ABSENT	0
#endif

/*	Base filename lengths	*/
#if MSDOS
#define BASENAMLEN	12
#endif
#if ATT
#define BASENAMLEN	14
#endif
#if BSD || MACH
#define BASENAMLEN	255
#endif
#if VMS
#define	BASENAMLEN	78
#endif
#if MAC
#define BASENAMLEN	31
#endif
#define MAXEXTLEN	4		/* longest filename extension */

#define DSP56000	1
#define WSIZE5		3		/* bytes per 56000 word */
#define OVRHD5		3		/* 56000 S-record byte overhead */
#define WRDFMT5		"%06lx"		/* 56000 word format string */

#define DSP96000	2
#define WSIZE9		4		/* bytes per 96000 word */
#define OVRHD9		5		/* 96000 S-record byte overhead */
#define WRDFMT9		"%08lx"		/* 96000 word format string */

#define DSP5616		3
#define WSIZE6		2		/* bytes per 5616 word */
#define OVRHD6		3		/* 5616 S-record byte overhead */
#define WRDFMT6		"%04lx"		/* 5616 word format string */

#define S0OVRHD		3		/* S0 record overhead */
#define MAXBYTE		30		/* max data bytes per S-record */
#define MAXOVRHD	8		/* maximum S-record overhead */
#define MAXBUF	(MAXBYTE + MAXOVRHD) * 2/* maximum byte buffer size */

#define MSPACES	4			/* number of memory spaces */
#define XMEM	0			/* memory space array offsets */
#define YMEM	1
#define LMEM	2
#define PMEM	3

#define NONE	0			/* OMF record codes */
#define START	1
#define END	2
#define DATA	3
#define BDATA	4
#define SYMBOL	5
#define COMMENT	6

#define RECORD	1			/* OMF field types */
#define HEXVAL	2

#define NEWREC	'_'			/* new record indicator */

struct srec {				/* S-record structure */
		FILE *fp;
		unsigned checksum;
		char *p;
		char buf[MAXBUF + 1];
		};

char *strcpy (), *strncpy ();
char *strcat (), *strncat ();
#if BSD
char *sprintf ();
char *index (), *rindex ();
#else
char *strchr (), *strrchr ();
#endif

#if MSDOS		/* reference DOS version number */
#if MSC
extern unsigned char _osmajor;
#endif
#endif
