/*
assert.h
*/
#ifndef ASSERT_H
#define ASSERT_H

#if DEBUG

#define INIT_ASSERT	static char *assert_file= __FILE__;

void bad_assertion(char *file, int line, char *what);
void bad_compare(char *file, int line, int lhs, char *what, int rhs);

#define assert(x)	(!(x) ? bad_assertion(assert_file, __LINE__, #x) \
								: (void) 0)
#define compare(a,t,b)	(!((a) t (b)) ? bad_compare(assert_file, __LINE__, \
				(a), #a " " #t " " #b, (b)) : (void) 0)
#else /* !DEBUG */

#define INIT_ASSERT	/* nothing */

#define assert(x)	(void)0
#define compare(a,t,b)	(void)0

#endif /* !DEBUG */

#endif /* ASSERT_H */
