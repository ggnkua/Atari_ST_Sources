/* amiga.h
 *
 * Globular definitions that affect all of AmigaDom.
 *
 * Originally included in unzip.h, extracted for simplicity and eeze of
 * maintenance by John Bush.
 *
 * THIS FILE IS #INCLUDE'd by unzip.h 
 *
 */

#include <time.h>


#ifdef AZTEC_C                   /* Manx Aztec C, 5.0 or newer only */
#  include <clib/dos_protos.h>
#  include <pragmas/dos_lib.h>
#  define MODERN
#  define O_BINARY 0
#  include "amiga/z-stat.h"
#  define dirent direct
#  ifdef ASM_CRC
#    pragma regcall(CalcCRC(a0,d0,a1,d1))
#  endif
#endif /* AZTEC_C */


#if defined(LATTICE) || defined(__SASC) || defined(__SASC_60)
#  include <sys/types.h>         
#  include <sys/stat.h>
#  include <sys/dir.h>
#  include <dos.h>
#  include <proto/dos.h>  /* needed? */
#  if ( (!defined(O_BINARY)) && defined(O_RAW))
#    define O_BINARY O_RAW
#  endif
#  ifdef ASM_CRC
     /* PUT SOMETHING HERE TO PASS ARGS IN REGISTERS TO CalcCRC() */
#  endif
#endif /* LATTICE */

/* Funkshine Prough Toe Taipes */

int cmptime (struct tm *, struct tm *);
time_t invlocal (struct tm *);
LONG FileDate (char *, time_t[]);

#define dup  /* needed? */
