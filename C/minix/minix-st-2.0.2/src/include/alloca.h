/*	alloca.h - The dreaded alloca() function.
 */

#ifndef _ALLOCA_H
#define _ALLOCA_H

#if __GNUC__

/* The compiler recognizes this special keyword, and inlines the code. */
#define alloca(size)	__builtin_alloca(size)

#endif /* __GCC__ */

#if __ACK__ || __CCC__ || __SOZOBONX__

#ifndef _ANSI_H
#include <ansi.h>
#endif

_PROTOTYPE(void *alloca, (size_t _size)					);

#endif /* __ACK__ || __CCC__ */

#endif /* _ALLOCA_H */
