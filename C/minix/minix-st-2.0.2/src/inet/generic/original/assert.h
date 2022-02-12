/*
assert.h

Copyright 1995 Philip Homburg
*/
#ifndef INET_ASSERT_H
#define INET_ASSERT_H

#if !NDEBUG

void bad_assertion(char *file, int line, char *what);
void bad_compare(char *file, int line, unsigned long lhs,
					char *what, unsigned long rhs);

#define assert(x)	(!(x) ? bad_assertion(this_file, __LINE__, #x) \
								: (void) 0)
#define compare(a,t,b)	(!((unsigned long)(a) t (unsigned long)(b)) ? \
		bad_compare(this_file, __LINE__, \
		(unsigned long)(a), #a " " #t " " #b, (unsigned long)(b)) \
			: (void) 0)

#else /* NDEBUG */

#define assert(x)		0
#define compare(a,t,b)		0

#endif /* NDEBUG */

#endif /* INET_ASSERT_H */


/*
 * $PchId: assert.h,v 1.4 1995/11/21 06:45:27 philip Exp $
 */
