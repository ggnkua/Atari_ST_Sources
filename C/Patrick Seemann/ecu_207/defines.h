/*      DEFINES.H

        Portability Includes for Turbo-C

        Copyright (c) Heinz Ozwirk 1989
        All Rights Reserved.
*/

#ifndef __PORTAB
#define __PORTAB

#pragma warn -ucp
#pragma warn -cln
#pragma warn -dup

#define  size_of(type, obj) sizeof(((type *) 0)->obj)

#define  LOBYTE(x)   ((BYTE) (x))
#define  HIBYTE(x)   (((WORD) (x)) >> 8)
#define  LOWORD(x)   ((WORD) (x))
#define  HIWORD(x)   (((LONG) (x)) >> 16)

typedef  unsigned char  BYTE;
typedef  unsigned short WORD;
typedef  unsigned long  LONG;

typedef  enum { FALSE, TRUE } BOOL;

#define  FNSIZE   13
#define  FMSIZE   64

#ifndef  O_BINARY
#define  O_BINARY 0
#endif

#ifndef  NULL
#define  NULL     ( ( void * ) 0L )
#endif

#ifndef  NIL
#define  NIL      ( ( void * ) -1l)
#endif   NIL

#define  PRT   0
#define  AUX   1
#define  CON   2
#define  MIDI  3
#define  IKBD  4

#endif
