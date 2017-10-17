/*
 * portab.h - Definitions for writing portable C
 *
 * Copyright (c) 2001 Lineo, Inc. and the EmuTOS devel team
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */

/*
 * I guess now this file is just badly named. it just contains 
 * common macros that were so often in the code that we just have
 * to keep them here.
 */

#ifndef PORTAB_H
#define PORTAB_H



/*
 *  Compiler Definitions
 */

#ifdef __GNUC__
#define NORETURN __attribute__ ((noreturn))
#else
#define NORETURN
#endif

/*
 *  Constants 
 */

#ifndef NULL
#define NULL    0                       /*      Null character value        */
#endif
#ifndef TRUE
#define TRUE    (1)                     /*      Function TRUE  value        */
#endif
#ifndef FALSE
#define FALSE   (0)                     /*      Function FALSE value        */
#endif
#define NULLPTR ((void*)0)              /*      Null pointer value          */

/*
 *  Miscellaneous
 */

#define REG             register                /* register variable       */
#define GLOBAL                                  /* Global variable         */

/*
 *  Types
 */

typedef char            BYTE ;                  /*  Signed byte         */

typedef unsigned char   UBYTE ;                 /*  Unsigned byte       */
typedef unsigned long   ULONG ;                 /*  unsigned 32 bit word*/

typedef long            PTR ;                   /*  32 bit pointer */

typedef int             BOOLEAN ;               /*  boolean             */
typedef int             BOOL ;                  /*  same as boolean     */
typedef short int       WORD ;                  /*  signed 16 bit word  */
typedef unsigned short int UWORD ;              /*  unsigned 16 bit word*/
typedef long            LONG ;                  /*  signed 32 bit word  */

#endif /* PORTAB_H */

