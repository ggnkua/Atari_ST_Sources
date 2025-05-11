#ifndef __GNUC__
/* Use the system's macros with the system's compiler.  */
#include <varargs.h>
#else

/* These macros implement traditional (non-ANSI) varargs
   for GNU C.  */

#define va_alist  _varargs
#define va_dcl    int _varargs;
#define va_list   char *

#define va_start(AP)  AP=(char *) &_varargs
#define va_end(AP)

#define _va_rounded_size(TYPE)  \
  (((sizeof (TYPE) + sizeof (int) - 1) / sizeof (int)) * sizeof (int))

#define va_arg(AP, TYPE)						\
 (AP += _va_rounded_size (TYPE),					\
  *((TYPE *) (AP - _va_rounded_size (TYPE))))

#endif
