/*
 * STDARG.H
 */

#ifndef _STDARG_H
#ifndef va_start	/* in case of varargs being included */
#define	_STDARG_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#ifdef __GNUC__

/* Define __gnuc_va_list.  */

#ifndef __GNUC_VA_LIST
#define __GNUC_VA_LIST
typedef void *__gnuc_va_list;
#endif

/* Amount of space required in an argument list for an arg of type TYPE.
   TYPE may alternatively be an expression whose type is used.  */

#define __va_rounded_size(TYPE)  \
  (((sizeof (TYPE) + sizeof (int) - 1) / sizeof (int)) * sizeof (int))

#if (__GNUC__==2) && (__GNUC_MINOR__>=7)
#define va_start(AP, LASTARG) (AP = ((__gnuc_va_list)\
				     __builtin_next_arg (LASTARG)))
#else
#define va_start(AP, LASTARG) (AP = ((__gnuc_va_list)\
				     __builtin_next_arg ()))
#endif

#define va_end(AP)

/* We cast to void * and then to TYPE * because this avoids
   a warning about increasing the alignment requirement.  */
#define va_arg(AP, TYPE)                                                \
 (AP = (__gnuc_va_list) ((char *) (AP) + __va_rounded_size (TYPE)),	\
  *((TYPE *) (void *) ((char *) (AP) - ((sizeof (TYPE) < sizeof (int)	\
					 ? sizeof (TYPE)		\
					 : __va_rounded_size (TYPE))))))

#ifndef _VA_LIST_
#define _VA_LIST_
typedef __gnuc_va_list va_list;
#endif /* _VA_LIST_ */

#else

typedef	__VA_LIST__ va_list,__gnuc_va_list;		/* 7'99 HR */


# ifdef __TURBOC__
#  define va_start(list, param)   ((list) = ...)
#  define va_arg(list, type)      (*((type *) (list))++)
#  define va_end(list)
# else
#  define va_start(list,param)  list = ((va_list) &(param)) \
				   + ((sizeof(param) + 1) & ~1)
#  define va_arg(list,type)     ((type *)(list += ((sizeof(type) + 1) & ~1)))[-1]
#  define va_end(list)
# endif /* __TURBOC__ */

#endif /* __GNUC__ */

#endif /* va_start */

#endif /* _STDARG_H */
