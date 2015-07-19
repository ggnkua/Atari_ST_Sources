/*  ARC - Archive utility - ARC Header

    Version 2.14, created on 02/03/86 at 22:48:29

(C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:  Thom Henderson

    Description: 
         This is the header file for the ARC archive utility.  It defines
         global parameters and the references to the external data.


    Language:
         Computer Innovations Optimizing C86
*/

#ifdef SYS5
#define index strchr
#define rindex strrchr
#endif SYS5

#if unix
#define alloc xalloc
#define realloc xrealloc
#if m68000
typedef long int int32_t;
typedef short int int16_t;
typedef unsigned short int uint16_t;
#else	/* not m68000 */
put apropriate typedefs here
#endif m68000
#else	/* not unix, assume C86 */
typedef long int int32_t;
typedef int int16_t;
typedef unsigned int uint16_t;
#endif unix

#define ARCMARK 26                     /* special archive marker */
#define ARCVER 8                       /* archive header version code */
#define STRLEN 100                     /* system standard string length */
#define FNLEN 13                       /* file name length */
#define MAXARG 25                      /* maximum number of arguments */

#include "arcs.h"

#ifndef MAIN
#define EXTERN extern
EXTERN char VERSION[];
#else
#define EXTERN /**/
EXTERN char VERSION[] = "Version 5.12 created on 02/05/86 at 22:22:01";
#endif MAIN
EXTERN int keepbak;             /* true if saving the old archive */
EXTERN int warn;                /* true to print warnings */
EXTERN int note;                /* true to print comments */
EXTERN int bose;                /* true to be verbose */
EXTERN int nocomp;              /* true to suppress compression */
EXTERN int kludge;              /* kludge flag */
EXTERN char *arctemp;        /* arc temp file prefix */
EXTERN char *password;       /* encryption password pointer */
EXTERN int nerrs;               /* number of errors encountered */

EXTERN char hdrver;                      /* header version */
EXTERN FILE *arc;                        /* the old archive */
EXTERN FILE *new;                        /* the new archive */
EXTERN char arcname[100];           /* storage for archive name */
EXTERN char bakname[100];           /* storage for backup copy name */
EXTERN char newname[100];           /* storage for new archive name */
EXTERN unsigned int arcdate;    /* archive date stamp */
EXTERN unsigned int arctime;    /* archive time stamp */

 