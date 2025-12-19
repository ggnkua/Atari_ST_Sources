/*****************************************************************************
*
*                                 amigaconf.h
*
*   from DKBTrace (c) 1990  David Buck
*
*  This module contains Amiga-specific defines, types, and other declarations.
*
* This software is freely distributable. The source and/or object code may be
* copied or uploaded to communications services so long as this notice remains
* at the top of each file.  If any changes are made to the program, you must
* clearly indicate in the documentation and in the programs startup message
* who it was who made the changes. The documentation should also describe what
* those changes were. This software may not be included in whole or in
* part into any commercial package without the express written consent of the
* author.  It may, however, be included in other public domain or freely
* distributed software so long as the proper credit for the software is given.
*
* This software is provided as is without any guarantees or warranty. Although
* the author has attempted to find and correct any bugs in the software, he
* is not responsible for any damage caused by the use of the software.  The
* author is under no obligation to provide service, corrections, or upgrades
* to this package.
*
* Despite all the legal stuff above, if you do find bugs, I would like to hear
* about them.  Also, if you have any comments or questions, you may contact me
* at the following address:
*
*     David Buck
*     22C Sonnet Cres.
*     Nepean Ontario
*     Canada, K2H 8W7
*
*  I can also be reached on the following bulleton boards:
*
*     OMX              (613) 731-3419
*     Mystic           (613) 596-4249  or  (613) 596-4772
*
*  Fidonet:   1:163/109.9
*  Internet:  dbuck@ccs.carleton.ca
*  You Can Call Me Ray: (708) 358-5611
*
*  IBM Port by Aaron A. Collins. Aaron may be reached on the following BBS'es:
*
*     Lattice BBS                      (708) 916-1200
*     The Information Exchange BBS     (708) 945-5575
*     Stillwaters BBS                  (708) 403-2826
*
*****************************************************************************/


/* For the Amiga, we can use ANSI prototype definitions. */
#include <dos.h>

#define ACOS acos
#define SQRT sqrt
#define POW pow
#define COS cos
#define SIN sin
#define EPSILON 1.0e-5

#define PARAMS(x) x
void main (int, char**);
void exit(int);
void *malloc(int);
void free(void *);

extern int _bufsiz;

int amiga_close_all(void);

extern char *getenv PARAMS((char *str));
void amiga_init_dkb_trace PARAMS((void));
#define STARTUP_DKB_TRACE amiga_init_dkb_trace();
#define TEST_ABORT chkabort();
