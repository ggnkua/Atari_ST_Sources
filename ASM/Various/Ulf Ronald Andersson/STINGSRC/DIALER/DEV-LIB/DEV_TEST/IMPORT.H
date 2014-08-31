/************************************************************************/
/* module:          import.h                                            */
/* author:          Jan Kriesten        date:        27.11.1992         */
/*                                                                      */
/* description:     header-file to import header-files;                 */
/*                                                                      */
/* last change: 	27.11.1992                                          */
/************************************************************************/

/* -------------------------------------------------------------------- */
/*       environment.                                                   */
/* -------------------------------------------------------------------- */

#ifndef __IMPORT_H__
#define __IMPORT_H__

/* -------------------------------------------------------------------- */
/*       includes.                                                      */
/* -------------------------------------------------------------------- */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "portab.h"

/* -------------------------------------------------------------------- */
/*       constants.                                                     */
/* -------------------------------------------------------------------- */

#ifdef GLOBAL
#undef GLOBAL
#endif

#define GLOBAL EXTERN

#define Mavail( ) (LONG)Malloc( -1L )

#ifndef max
#define max( a, b ) ( ( (a) > (b) ) ? (a) : (b) ) /* Maximum-Funktion */
#define min( a, b ) ( ( (a) < (b) ) ? (a) : (b) ) /* Minimum Funktion */
#endif

#define odd( i )    ( (i) & 1 )                   /* ungerade */

#define AND         &&
#define OR          ||
#define XOR         ^^
#define NOT         !
#define DIV         /
#define MOD         %

#define BITAND      &
#define BITOR       |
#define BITXOR      ^
#define BITNOT      ~

/* -------------------------------------------------------------------- */
/*       types.                                                         */
/* -------------------------------------------------------------------- */

/* -------------------------------------------------------------------- */
/*       end of header module.                                          */
/* -------------------------------------------------------------------- */

#endif /* __IMPORT_H__ */

