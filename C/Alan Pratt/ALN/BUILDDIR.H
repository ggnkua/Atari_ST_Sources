/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:40 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	builddir.h,v $
* Revision 1.1  88/08/23  14:20:40  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/builddir.h,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * BUILDDIR.H: structures & forward declarations for BUILDDIR
 */

/* 
 * note that directories became index files, and this program "doindex", on
 * 10/22/86.
 */

#ifdef VAX
#include <stdio.h>
#endif VAX

#include "port.h"
#include "slongio.h"

#ifdef DEBUG
#include "debug.h"
#else
#define DEBUG0(s) 0
#define DEBUG1(s,a) 0
#define DEBUG2(s,a,b) 0
#define DEBUG3(s,a,b,c) 0
#endif DEBUG

#ifdef DBMALLOC
extern char *mymalloc(), *mycalloc(), *myrealloc();

#define free(x) myfree(x)
#define malloc(x) mymalloc(x)
#define calloc(x,y) mycalloc(x,y)
#define realloc(x,y) myrealloc(x,y)
#else
#ifdef ATARIST
extern char *lmalloc(), *lcalloc(), *lrealloc();

#define free(x) lfree(x)
#define malloc(x) lmalloc(x)
#define calloc(x,y) lcalloc(x,y)
#define realloc(x,y) lrealloc(x,y)
#else
extern char *malloc(), *calloc(), *realloc();
#endif ATARIST
#endif DBMALLOC

#ifndef NULL
#define NULL 0L
#endif NULL

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif TRUE

#ifndef min
#define min(a,b) ((a) < (b) ? (a) : (b))
#define max(a,b) ((a) > (b) ? (a) : (b))
#endif min

struct ARHEADER {
	char a_fname[14];
	long a_modti;
	char a_userid;
	char a_gid;
	int a_fimode;
	long a_fsize;
	int reserved;		/* two bytes of zeroes btw header & file */
};
#define Newarheader() (struct ARHEADER *)malloc((long)sizeof(struct ARHEADER))

/*
 * Bit definitions for the type field of a symbol.
 */

#define T_DEFINED	0x8000
#define T_EQUATED	0x4000
#define T_GLOBAL	0x2000
#define T_REGISTER	0x1000
#define T_EXTERN	0x0800
#define T_DATA		0x0400	/* data-based relocatable */
#define T_TEXT		0x0200	/* text-based relocatable */
#define T_BSS		0x0100	/* bss-based relocatable  */
#define T_FILE		0x0080	/* file symbol */
#define T_OST		0x0001	/* private: "symbol is in ost": see above */
#define T_COMMON	(T_GLOBAL | T_EXTERN)
#define T_SEG		(T_DATA | T_TEXT | T_BSS) /* segment bits */

/*
 * SYMREC: used by builddir for the lists of exports and imports.
 */

#define SYMLEN 10			  /* symbol name size (incl null) */

struct SYMREC {
	char s_name[SYMLEN];	/* including null terminator */
	struct SYMREC *s_next;
};
#define Newsymrec() (struct SYMREC *)malloc((long)sizeof(struct SYMREC))

#define FNLEN 16		/* size of a file name (15 chars + NULL) */
struct FILEREC {
	char f_name[FNLEN];		/* the file name */
	struct FILEREC *f_next;		/* next file in the list */
	long f_offset;			/* offset of this file in archive */
	struct SYMREC *f_imports;	/* list of imported symbols */
	struct SYMREC *f_exports;	/* list of exported symbols */
};
#define Newfilerec() (struct FILEREC *)malloc((long)sizeof (struct FILEREC))

#define DIRSUFFIX ".ndx"	/* suffix for the directory file */
#define HEADSIZE 6
#define FNSIZE (FNLEN + 4)
#define SYMSIZE (SYMLEN + 2)

/*
 * These macros are for use with dependency vectors.
 */

#define Setbit(ptr,bit) ((ptr)[(bit)>>3] |= (0x80 >> ((bit)&7)))
#define Testbit(ptr,bit) ((ptr)[(bit)>>3] & (0x80 >> ((bit)&7)))

/*
 * These macros are used with the TYPE field of a SYMBOL.
 */

#define iscommon(type) (((type) & T_COMMON) == T_COMMON)
#define isglobal(type) (((type) & T_COMMON) == T_GLOBAL)
#define isextern(type) (((type) & T_COMMON) == T_EXTERN)
#define islocal(type)  (((type) & T_COMMON) == 0)

/*
 * forward declarations for builddir
 */

#ifdef malloc
char *mymalloc(), *mycalloc(), *myrealloc();
#else
char *malloc(), *calloc(), *realloc();
#endif

char *index(), *rindex();
char *build_directory();
