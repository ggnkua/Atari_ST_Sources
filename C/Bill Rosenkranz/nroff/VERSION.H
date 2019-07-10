#ifndef VERSION_H
#define VERSION_H

/*
 *	version.h - included in nroff.h only in main.c (NRO_MAIN defined)
 */

#include "patchlev.h"

/*
 *	to get around no valid argv[0] with some compilers...
 */
char	       *myname  = "nroff";

#ifdef GEMDOS
char	       *version = "nroff (TOS) v1.1p4 01/15/91 rosenkra@convex.com";
#endif
#ifdef MINIX_ST
char	       *version = "nroff (Minix-ST) v1.1p4 01/15/91 rosenkra@convex.com";
#endif
#ifdef MINIX_PC
char	       *version = "nroff (Minix-PC) v1.1p4 01/15/91 rosenkra@convex.com";
#endif
#ifdef UNIX
char	       *version = "nroff (Unix) v1.1p4 01/15/91 rosenkra@convex.com";
#endif

#endif /*VERSION_H*/
