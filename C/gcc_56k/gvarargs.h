/* $Id: gvarargs.h,v 1.4 91/11/22 19:43:58 pete Exp $ */
#if defined ( __WATCOMC__ ) || defined( __DGUX__ )
#include <stdarg.h>
#else
#ifdef GNUDOS
#include <varargs.h>
#else
#ifndef __GNUC__
/* Use the system's macros with the system's compiler.  */
#include <varargs.h>
#else
#ifdef __spur__
#include "va-spur.h"
#else
#ifdef __mips__
#include "va-mips.h"
#else
#ifdef __i860__
#include "va-i860.h"
#else
#ifdef __pyr__
#include "va-pyr.h"
#else

#ifdef __NeXT__

/* On Next, erase any vestiges of stdarg.h.  */

#undef va_alist
#undef va_dcl
#undef va_list
#undef va_start
#undef va_end
#undef __va_rounded_size
#undef va_arg

/* Record that varargs.h is defined; this turns off stdarg.h.  */

#ifndef _VARARGS_H
#define _VARARGS_H
#endif
#endif  /* __NeXT__ */

/* These macros implement traditional (non-ANSI) varargs
   for GNU C.  */

#define va_alist  __builtin_va_alist
#define va_dcl    int __builtin_va_alist;
#define va_list   char *

#ifdef __sparc__
#define va_start(AP) 						\
 (__builtin_saveregs (),					\
  AP = ((void *) &__builtin_va_alist))
#else
#define va_start(AP)  AP=(char *) &__builtin_va_alist
#endif
#define va_end(AP)

#define __va_rounded_size(TYPE)  \
  (((sizeof (TYPE) + sizeof (int) - 1) / sizeof (int)) * sizeof (int))

#define va_arg(AP, TYPE)						\
 (AP += __va_rounded_size (TYPE),					\
  *((TYPE *) (AP - __va_rounded_size (TYPE))))

#endif /* not pyr */
#endif /* not i860 */
#endif /* not mips */
#endif /* not spur */
#endif /* __GNUC__ */
#endif /* GNUDOS */
#endif /* __WATCOMC__ */
