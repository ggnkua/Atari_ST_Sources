#ifndef _STDDEF_H
#define _STDDEF_H

/* Signed type of difference of two pointers.  */

typedef long ptrdiff_t;

/* Unsigned type of `sizeof' something.  */

/* typedef unsigned long size_t;  -- not on atari, we've got one */
#include <types.h>

/* A null pointer constant.  */

#ifndef NULL
#define NULL ((void *)0)
#endif

/* Offset of member MEMBER in a struct of type TYPE.  */

#define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER)

#endif /* _STDDEF_H */
