/*
 * stdlib.h
 *
 *  Created on: 31.05.2013
 *      Author: mfro
 */

#ifndef _STDLIB_H_
#define _STDLIB_H_

#ifndef	_FEATURES_H
# include <features.h>
#endif

#include <stddef.h>

int atoi(const char *c);
long atol(const char *c);
double atof(const char *c);
void *malloc(size_t size);
void *calloc(size_t nmemb, size_t size);
void *realloc(void *ptr, size_t size);
void free(void *ptr);

char *ltoa(long value, char *buffer, int radix);
char *ultoa(unsigned long value, char *buffer, int radix);
char *itoa(int value, char *buffer, int radix);
#define _ltoa(a, b, c) ltoa((a), (b), (c))
#define _ultoa(a, b, c) ultoa((a), (b), (c))
#define _itoa(a, b, c) itoa((a), (b), (c))

char *getenv(const char *name);
int setenv(const char *name, const char *value, int replace);
int unsetenv(const char *name);

int atexit(void (*func)(void));
void exit(int status);
void abort(void);

/* Terminate the program with STATUS without calling any of the
   functions registered with `atexit' or `on_exit'.  */
void _Exit (int __status) __THROW __attribute__ ((__noreturn__));

#if defined(__MSHORT__) || defined(__PUREC__) || defined(__AHCC__)
#define	RAND_MAX (0x7FFF)
#else
#define	RAND_MAX (0x7FFFFFFFL)
#endif

#define	EXIT_FAILURE	1	/* Failing exit status.  */
#define	EXIT_SUCCESS	0	/* Successful exit status.  */

int rand(void);
void srand(unsigned int __seed);
long lrand(void);
void srand48(long int __seed);

long strtol(const char*, char**, int);
unsigned long strtoul(const char*, char**, int);
long long strtoll(const char*, char**, int);
unsigned long long strtoull(const char*, char**, int);
double strtod(const char* s, char** endp);
long double strtold(const char* s, char** endp);
float strtof(const char* s, char** endp);

#ifndef __COMPAR_FN_T
# define __COMPAR_FN_T
typedef int (*__compar_fn_t) (__const void*, __const void*);

# ifdef	__USE_GNU
typedef __compar_fn_t comparison_fn_t;
# endif
#endif

void *bsearch(const void *key, const void *base, size_t num, size_t size, int (*cmp)(const void *, const void *));
void qsort(void *__base, size_t __nel, size_t __size, __compar_fn_t __compar);

int abs(int n);
long labs(long n);

#define abs(j)  ((j) > 0 ? (j) : -(j))

/* Returned by `div'.  */
typedef struct {
	int quot;			/* Quotient.  */
    int rem;			/* Remainder.  */
} div_t;

/* Returned by `ldiv'.  */
#ifndef __ldiv_t_defined
typedef struct {
	long int quot;		/* Quotient.  */
	long int rem;		/* Remainder.  */
} ldiv_t;
# define __ldiv_t_defined	1
#endif

div_t div(int __numer, int __denom) __attribute__ ((__const__));
ldiv_t ldiv(long int __numer, long int __denom) __attribute__ ((__const__));

#ifndef NULL
# define NULL	((void *) 0)
#endif

#endif /* _STDLIB_H_ */
