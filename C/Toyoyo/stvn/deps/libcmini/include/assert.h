#ifndef _ASSERT_H_
#define _ASSERT_H_

#ifndef NDEBUG

#ifndef __STDLIB
#include <stdlib.h>
#endif

#ifndef __STDIO
#include <stdio.h>
#endif

/* This prints an "Assertion failed" message and aborts.  */
void __assert_fail (const char *__assertion,
			   const char *__file,
			   unsigned int __line,
			   const char *__function)
     __attribute__ ((__noreturn__));

# define assert(expr)							      \
  ((void) ((expr) ? 0 :							      \
	   (__assert_fail (#expr,				      \
			   __FILE__, __LINE__, NULL), 0)))
#else
#define assert(expr)
#endif /* NDEBUG */
#endif /* _ASSERT_H_ */

