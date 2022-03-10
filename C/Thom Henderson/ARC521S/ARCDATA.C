/*
 * $Header: arcdata.c,v 1.7 88/07/31 18:47:22 hyc Exp $
 */

/*  ARC - Archive utility - ARCDATA

    Version 2.17, created on 04/22/87 at 13:09:43

(C) COPYRIGHT 1985,86 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:	 Thom Henderson

    Description: 
	 This file defines the external data storage used by the ARC
	 archive utility.


    Language:
	 Computer Innovations Optimizing C86
*/
#include <stdio.h>

#define DONT_DEFINE
#include "arc.h"

int             keepbak = 0;	/* true if saving the old archive */
#if	UNIX
int		image = 1;	/* true to suppress CRLF/LF x-late */
#endif
#if	MTS
int             image = 0;	/* true to suppress EBCDIC/ASCII x-late */
char            sepchr[2] = ":";/* Shared file separator */
char            tmpchr[2] = "-";/* Temporary file prefix */
#endif
#if	GEMDOS
int		hold = 0;	/* true to pause before exit */
#endif
int             warn = 1;	/* true to print warnings */
int             note = 1;	/* true to print comments */
int             bose = 0;	/* true to be verbose */
int             nocomp = 0;	/* true to suppress compression */
int             overlay = 0;	/* true to overlay on extract */
int             kludge = 0;	/* kludge flag */
char           *arctemp = NULL;	/* arc temp file prefix */
char           *password = NULL;/* encryption password pointer */
int             nerrs = 0;	/* number of errors encountered */
int		changing = 0;	/* true if archive being modified */

char            hdrver;		/* header version */

FILE           *arc;		/* the old archive */
FILE           *new;		/* the new archive */
char            arcname[STRLEN];	/* storage for archive name */
char            bakname[STRLEN];	/* storage for backup copy name */
char            newname[STRLEN];	/* storage for new archive name */
unsigned short  arcdate = 0;	/* archive date stamp */
unsigned short  arctime = 0;	/* archive time stamp */
unsigned short  olddate = 0;	/* old archive date stamp */
unsigned short  oldtime = 0;	/* old archive time stamp */
int		dosquash = 0;	/* true to squash instead of crunch */
