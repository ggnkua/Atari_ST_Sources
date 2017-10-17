/*****************************************************************************/
/*                                                                           */
/* IMPORT.H                                                                  */
/* Datum: 09/07/90                                                           */
/*                                                                           */
/*****************************************************************************/

#ifndef __IMPORT_H__
#define __IMPORT_H__

/*
#include <stdio.h>
*/
#include <string.h>
#include <scsidrv/portab.h>
#include <aes.h>
#include <vdi.h>

#if GEMDOS
#include <tos.h>
#define Mavail() (LONG)Malloc (-1L)
#endif

#if MSDOS | OS2 | FLEXOS
#include <gemdos.h>
#include <dosbind.h>
#endif

#if UNIX
#include <sys/types.h>
#define Mavail() (64 * 1024L)                 /* In UNIX ist immer Speicher frei */
#endif

#if ANSI
#include <stdlib.h>
#else
#define abs(x)      ((x) <  0  ? -(x) : (x))  /* Absolut-Wert */
#define labs(x)     abs (x)                   /* Langer Absolut-Wert */
#define fabs(x)     abs (x)                   /* Double Absolut-Wert */
#endif

/****** DEFINES **************************************************************/

#ifdef GLOBAL
#undef GLOBAL
#endif

#define GLOBAL EXTERN

#if LASER_C
#define strchr  index
#define strrchr rindex
#endif

#if HIGH_C
#ifdef NULL
#undef NULL
#define NULL 0L
#endif
#endif

#ifndef max
#define max(a,b)    (((a) > (b)) ? (a) : (b)) /* Maximum-Funktion */
#define min(a,b)    (((a) < (b)) ? (a) : (b)) /* Minimum Funktion */
#endif

#define odd(i)      ((i) & 1)                 /* ungerade */

/*****************************************************************************/

#ifdef PASCAL_DEF
#define and         &&                        /* Für Pascal-Programmierer */
#define or          ||
#define xor         ^^
#define not         !
#define div         /
#define mod         %

#define bitand      &
#define bitor       |
#define bitxor      ^
#define bitnot      ~

#define loop        for (;;)
#define exitloop(e) if (e) break
#define nextloop(e) if (e) continue

#define repeat      do {
#define until(e)    } while (! (e))

#define begin       {
#define end         }

#define then

#define boolean     BOOLEAN
#define integer     WORD
#define longint     LONG
#define real        FLOAT
#define longreal    DOUBLE

#define type        typedef
#endif /* PASCAL_DEF */

/*****************************************************************************/

#ifdef MODULA_DEF
#define AND         &&                        /* Für Modula-Programmierer */
#define OR          ||
#define XOR         ^^
#define NOT         !
#define DIV         /
#define MOD         %

#define BITAND      &
#define BITOR       |
#define BITXOR      ^
#define BITNOT      ~

#define LOOP        for (;;)
#define EXITLOOP(e) if (e) break
#define NEXTLOOP(e) if (e) continue

#define REPEAT      do {
#define UNTIL(e)    } while (! (e))

#define BEGIN       {
#define END         }

#define WHILE(e)    while (e) {
#define IF(e)       if (e) {
#define THEN
#define ELSE        } else {
#define ELSIF(e)    } else if (e) {

#define CASE(e)     switch (e) {
#define OF

#define RETURN      return

#define INTEGER     WORD
#define LONGINT     LONG
#define CARDINAL    UWORD
#define LONGCARD    ULONG
#define REAL        FLOAT
#define LONGREAL    DOUBLE
#define BITSET      UWORD
#define LONGBITSET  ULONG

#define TYPE        typedef
#endif /* MODULA_DEF */

/*****************************************************************************/

#endif /* __IMPORT__ */

