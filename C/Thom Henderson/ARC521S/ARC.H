/*
 * $Header: arc.h,v 1.10 88/08/01 14:28:29 hyc Exp $
 */

#undef	DOS	/* Just in case... */
#undef	UNIX

/*
 * Assumptions:
 * char = 8 bits
 * short = 16 bits
 * long = 32 bits
 * int >= 16 bits
 */

#if	MSDOS || GEMDOS
#define	DOS	1
#define	CUTOFF	'\\'
#define	OPEN_R	"rb"
#define	OPEN_W	"wb"
#endif

#if	!MSDOS
#define	envfind	getenv
#define	setmem(a, b, c)	memset(a, c, b)
#endif

#if	BSD || SYSV
#define	UNIX	1
#define	CUTOFF	'/'
#define	OPEN_R	"r"
#define	OPEN_W	"w"
#include <ctype.h>
#endif

#if	MTS
#define	CUTOFF	sepchr[0]
#endif

#if	MTS || SYSV
#define	rindex	strrchr
#define	index	strchr
#endif

#ifdef __STDC__
#define abort __myabort
#define sizeof	(int)sizeof
#endif

/*  ARC - Archive utility - ARC Header
  
    Version 2.17, created on 04/22/87 at 13:09:43
  
(C) COPYRIGHT 1985,86 by System Enhancement Associates; ALL RIGHTS RESERVED
  
    By:	 Thom Henderson
  
    Description: 
	 This is the header file for the ARC archive utility.  It defines
	 global parameters and the references to the external data.
  
  
    Language:
	 Computer Innovations Optimizing C86
*/

#define ARCMARK 26		/* special archive marker        */
#define ARCVER 9		/* archive header version code   */
#define STRLEN 100		/* system standard string length */
#define FNLEN 13		/* file name length              */
#define MAXARG 400		/* maximum number of arguments   */

#ifndef DONT_DEFINE		/* Defined by arcdata.c */
#include "arcs.h"

extern int      keepbak;	/* true if saving the old archive */
#if	!DOS
extern int      image;		/* true to suppress CRLF/LF x-late */
#endif
#if	MTS
extern char     sepchr[2];	/* Shared file separator, default = ':' */
extern char     tmpchr[2];	/* Temporary file prefix, default = '-' */
#endif
#if	GEMDOS
extern int      hold;		/* hold screen before exiting */
#endif
extern int      warn;		/* true to print warnings */
extern int      note;		/* true to print comments */
extern int      bose;		/* true to be verbose */
extern int      nocomp;		/* true to suppress compression */
extern int      overlay;	/* true to overlay on extract */
extern int      kludge;		/* kludge flag */
extern char    *arctemp;	/* arc temp file prefix */
extern char    *password;	/* encryption password pointer */
extern int      nerrs;		/* number of errors encountered */
extern int      changing;	/* true if archive being modified */

extern char     hdrver;		/* header version */

extern FILE    *arc;		/* the old archive */
extern FILE    *new;		/* the new archive */
extern char     arcname[STRLEN];/* storage for archive name */
extern char     bakname[STRLEN];/* storage for backup copy name */
extern char     newname[STRLEN];/* storage for new archive name */
extern unsigned short arcdate;	/* archive date stamp */
extern unsigned short arctime;	/* archive time stamp */
extern unsigned short olddate;	/* old archive date stamp */
extern unsigned short oldtime;	/* old archive time stamp */
extern int      dosquash;	/* squash instead of crunch */
#endif				/* DONT_DEFINE */
