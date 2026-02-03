#ifndef _PORTAB_H
#define _PORTAB_H

/* PORTAB.H - Einige Standarddefinitionen */
/* $Id: portab.h,v 1.5 1994/02/27 23:27:52 mwk Exp $ */

typedef signed char BYTE;
typedef unsigned char UBYTE;
typedef signed short WORD;
typedef unsigned short UWORD;
typedef signed long LONG;
typedef unsigned long ULONG;

#ifndef TRUE
#define TRUE    (!0)
#define FALSE   (0)
#endif	/* !TRUE */

#ifndef VOID
#define VOID void
#endif

#ifndef NULL
#define NULL    ((void *)0)
#endif

#endif	/* _PORTAB_H */
