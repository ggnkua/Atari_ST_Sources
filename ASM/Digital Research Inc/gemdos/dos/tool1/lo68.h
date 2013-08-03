/*
	Copyright 1983
	Alcyon Corporation
	8716 Production Ave.
	San Diego, Ca.  92121

	@(#)lo68.h	2.1	7/10/84
*/

/* include the flags for lo68. RHR */
#include "bannerlo.h"
#ifdef vax11c
#	define VMS   1
#	define VAX11 1
#	define DECC  1
#	include "ICOUT"
#	include "IAR68"
#	include "ISTAT"
#	define unlink delete
#	define BAD_EXIT  -1
#	define GOOD_EXIT 1
#else
#	define BAD_EXIT  1
#	define GOOD_EXIT 0
#endif

#ifdef WHITE
#	include <stdio.h>
#	define VMS   1
#	define VAX11 1
#endif

#ifdef CPM
#	define DRI
#	include "cout.h"
#	include "ar68.h"
#	define LIMITED
#	define NOSYFN
#endif

#ifdef DOS4
#	define DRI
#	include "cout.h"
#	include "ar68.h"
#	define NOSYFN
#endif

#ifdef REGULUS
#	include <cout.h>
#	include <ar68.h>
#	include <stat.h>
#endif

#ifdef MC68000
    struct BYTESTR {
        char hibyte;
        char lobyte;
    };
    struct WORDSTR {
        int hiword;
        int loword;
    };
#endif

#ifdef VAX11
#	ifndef DECC
#		include <c68/cout.h>
#		include <c68/ar68.h>
#		include <c68/stat.h>
#	endif
/* as a result of adding the sysinfo call, and removing defined MMU */

    struct WORDSTR {
        short loword;
        short hiword;
    };
    struct BYTESTR {
        char lobyte;
        char hibyte;
    };
#endif

#ifdef PDP11
#	include <c68/cout.h>
#	include <c68/ar68.h>
#	include <c68/stat.h>
/* as a result of adding the sysinfo call, and removing defined MMU */

    struct BYTESTR {
        char lobyte;
        char hibyte;
    };
    struct WORDSTR {
        int hiword;
        int loword;
    };
#endif

/* format of a symbol entry in the main table*/

#define SEEKREL	1	/*relative seek flag*/
#define SYNAMLEN	8

struct symtab {
	char name[SYNAMLEN]; /*symbol name*/
	short  flags;	     /*bit flags*/
	long vl1;			 /*symbol value*/
	char *tlnk;			 /*table link*/
};

char *lmte;		/*last entry in main table*/
char *bmte;		/*beginning of main table*/
char *emte;		/*end of main table*/

	/*symbol table entry size -- must be sizeof for sbrk*/
#define SYTESIZE	(sizeof *symptr)
struct symtab *symptr;
	/*symbol table entry length on object file without tlnk*/
#define OSTSIZE	14

/* flags for symbols*/
#define SYDF	0100000		/*defined*/
#define SYEQ	0040000		/*equated*/
#define SYGL	0020000		/*global - entry or external*/
#define SYER	0010000		/*equated register*/
#define SYXR	0004000		/*external reference*/
#define SYDA	0002000		/*DATA based relocatable*/
#define SYTX	0001000		/*TEXT based relocatable*/
#define SYBS	0000400		/*BSS based relocatable*/
#define SYFN	0000200		/* ?.o file name */


struct irts {
	char *irle;		/*ptr to last entry in chain*/
	char *irfe;		/*ptr to first entry in chain*/
};

/* parameters that define the main table*/
#ifndef DECC
#	define SZMT 300     /*initial size of the main table */
                       	/*must be large enough to initialize*/
#	define ICRSZMT 10   /*add to main table when run out*/
#else
	/**
	 *	use sizes on vax that result in memory allocation of multiples of
	 *	512 bytes.  Calls to sbrk round up to the next multiple of 512 so
	 *	for contiguous memory allocation these numbers should be used:
	 *		size of symtab = 18
	 *		455 * 18 + 2 = 8192	(=16*512)
	 *		256 * 18 = 4608		(=9*512)
	**/
#	define SZMT		455
#	define ICRSZMT	256
#endif
int cszmt;				/*current size of main table*/

/*initial reference table for externals*/
#define SZIRT	64
char *eirt[SZIRT];
char *saveirt[SZIRT];

/*initial reference table for globals*/
char *girt[SZIRT];
char *savgirt[SZIRT];

char **pirt;
char *savlmte;

#define AREGLO		8
#define AREGHI		15

/* relocation bit definitions:*/
#define RBMASK		07		/*tells type of relocation*/
#define INSABS		7		/*first word of instr -- absolute*/
#define DABS		0		/*data word absolute*/
#define TRELOC		2		/* TEXT relocatable*/
#define DRELOC		1		/* DATA relocatable*/
#define BRELOC		3		/* BSS relocatable*/
#define EXTVAR		4		/* ref to external variable*/
#define LUPPER		5		/* upper word of long*/
#define EXTREL		6		/* relative mode on external variable*/

#define BSIZE	512

struct iob{
	int fd;
	int cc;
	char *cp;
	char cbuf[BSIZE];
}ibuf, tbuf, obuf, rbuf, rtbuf, rdbuf;

int sflag;		/*remove symbol table*/

long textbase;
long database;
long bssbase;
long textsize;
long datasize;
long bsssize;
long stacksize;

long textstart;
long datastart;
long bssstart;

char *ifilname;			/*points to name of current input file*/

#define NFILE	256		/*max # files we can process*/
char *fsymp[NFILE];		/*points to first symbol for each .o file*/
char **firstsym;		/*points to entry in fsymp*/

int extmatch;			/*matched an external in a library entry*/
int noload;				/*dont load this lib file flag*/

#define NLIB	16		/*max # libraries to process*/
int lbfictr[NLIB];		/*counts files loaded from one library*/
int *libfctr;			/*points to lbfictr*/
long lbfioff[NFILE];	/*each file offset in library*/
long *libptr;			/*points to lbfioff*/
struct libhdr libhd;	/* 15 apr 83, used to be int[13] */
struct hdr couthd;		/* [vlh] 4.1 declared */

int undflg;
char dafnc;
int pass2;
long stlen;
int Xflag, Dflag, Bflag, Zflag;

struct symtab *etextptr;
struct symtab *edataptr;
struct symtab *endptr;
char *lastdup;

char rtfnc;
char rdfnc;
int saverbits;
int shortlflg;

#define TWOKSHT		-1		/* 2k shared text */
#define FOURKSHT	1	/* 4k shared text */

#define DEFSHTEXT	FOURKSHT

#define SH2BOUND 2048	/*shared text memory boundary*/
#define SHBOUND  4096
int shtext;		/*shared text if set*/
int isplit;		/*i&d split if set*/


	/*** Predeclared Functions ***/
char *lemt();
char *nextsy();
int endit();
long lgetnum();
char *sbrk();
long extval();
char *mktemp();
long lseek();
