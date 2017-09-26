/*      STDARG.H

        Parameter List Definition Includes

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if !defined(__STDARG)
#define __STDARG


typedef void    *va_list;

#define va_start(ap, parmN) ((ap) = ...)
#define va_arg(ap, type)    (*((type *)(ap))++)
#define va_end(ap)


#endif

/************************************************************************/
