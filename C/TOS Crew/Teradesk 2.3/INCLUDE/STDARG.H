/*      STDARG.H

        Parameter List Definition Includes

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if !defined(__STDARG)
#define __STDARG


typedef char    *va_list;

#define va_start(ap, parmN) ((ap) = (char *)...)
#define va_arg(ap, type)    \
    ((sizeof(type) == 1) ? \
    (*(type *)((ap += 2) - 1)) : \
    (*((type *)(ap))++))
#define va_end(ap)	(void)0


#endif

/************************************************************************/
