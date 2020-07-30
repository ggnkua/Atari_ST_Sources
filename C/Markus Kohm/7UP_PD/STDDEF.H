/*      STDDEF.H

        Standard Type Definition Includes

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if !defined( __STDDEF )
#define __STDDEF


typedef unsigned long   size_t;
typedef long            ptrdiff_t;


#define NULL        ((void *)0)

#define offsetof(type,ident)   ((size_t)&(((type *)0)->ident))


#endif

/************************************************************************/
