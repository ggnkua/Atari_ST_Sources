/*
 * stdlib.h
 *	ansi draft sec 4.10
 */
#ifndef _STDLIB_H
#define _STDLIB_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

begin_decls

#ifndef _SIZE_T
#define _SIZE_T __SIZE_TYPEDEF__
typedef _SIZE_T size_t;
#endif

#ifndef _WCHAR_T
#define _WCHAR_T __WCHAR_TYPEDEF__
typedef _WCHAR_T wchar_t;
#endif

#ifndef NULL
#define NULL		__NULL
#endif

#ifdef __MSHORT__
#define	RAND_MAX	(0x7FFF)	/* maximum value from rand() */
#else
#define	RAND_MAX	(0x7FFFFFFFL)	/* maximum value from rand() */
#endif

#define MB_CUR_MAX	1		/* max. length of multibyte character
					   in current locale */

#ifndef EXIT_FAILURE
#define EXIT_FAILURE	(1)
#define EXIT_SUCCESS	(0)
#endif

typedef struct {
    int		quot;	/* quotient	*/
    int		rem;	/* remainder 	*/
} div_t;

typedef struct {
    long	quot;	/* quotient	*/
    long	rem;	/* remainder 	*/
} ldiv_t;

double atof __PROTO((const char* __s));
int atoi __PROTO((const char* __str));
long atol __PROTO((const char* __str));
long int strtol __PROTO((const char* __nptr, char** __endptr, 
                                  int __base));
unsigned long int strtoul __PROTO((const char* __nptr, 
                                            char** __endptr, int __base));
double strtod __PROTO((const char* __s, char** __endptr)); /* sigh! */

void srand __PROTO((unsigned int __seed));
int rand __PROTO((void));


#if defined(__USE_SVID) || defined(__USE_XOPEN)
/* System V style 48-bit random number generator functions.  */

/* Return non-negative, double-precision floating-point value in [0.0,1.0).  */
double drand48 __PROTO ((void));
double erand48 __PROTO ((unsigned short int __xsubi[3]));

/* Return non-negative, long integer in [0,2^31).  */
long lrand48 __PROTO ((void));
long nrand48 __PROTO ((unsigned short int __xsubi[3]));

/* Return signed, long integers in [-2^31,2^31).  */
long mrand48 __PROTO ((void));
long jrand48 __PROTO ((unsigned short int __xsubi[3]));

/* Seed random number generator.  */
void srand48 __PROTO ((long __seedval));
unsigned short int *seed48 __PROTO ((unsigned short int __seed16v[3]));
void lcong48 __PROTO ((unsigned short int __param[7]));

/* Data structure for communication with thread safe versions.  */
struct drand48_data
  {
    unsigned short int x[3];	/* Current state.  */
    unsigned short int a[3];	/* Factor in congruential formula.  */
    unsigned short int c;	/* Additive const. in congruential formula.  */
    unsigned short int old_x[3]; /* Old state.  */
    int init;			/* Flag for initializing.  */
  };

#ifdef __USE_MISC
/* Return non-negative, double-precision floating-point value in [0.0,1.0).  */
int drand48_r __PROTO ((struct drand48_data *__buffer, 
                                 double *__result));
int erand48_r __PROTO ((unsigned short int __xsubi[3],
			         struct drand48_data *__buffer, 
			         double *__result));

/* Return non-negative, long integer in [0,2^31).  */
int lrand48_r __PROTO ((struct drand48_data *__buffer, 
                                 long *__result));
int nrand48_r __PROTO ((unsigned short int __xsubi[3],
			         struct drand48_data *__buffer, 
			         long *__result));

/* Return signed, long integers in [-2^31,2^31).  */
int mrand48_r __PROTO ((struct drand48_data *__buffer, 
                                 long *__result));
int jrand48_r __PROTO ((unsigned short int __xsubi[3],
			         struct drand48_data *__buffer, 
			         long *__result));

/* Seed random number generator.  */
int srand48_r __PROTO ((long __seedval, 
                                 struct drand48_data *__buffer));
int seed48_r __PROTO ((unsigned short int __seed16v[3],
			        struct drand48_data *__buffer));
int lcong48_r __PROTO ((unsigned short int __param[7],
			         struct drand48_data *__buffer));
#endif	/* Use misc.  */

/* Internal function to compute next state of the generator.  */
int __drand48_iterate __PROTO ((unsigned short int __xsubi[3],
				         struct drand48_data *__buffer));
#endif	/* Use SVID or X/Open.  */


void *malloc __PROTO((size_t n));
void free __PROTO((void *param));
void *realloc __PROTO((void *_r, size_t n));
void *calloc __PROTO((size_t n, size_t sz));
#ifndef __STRICT_ANSI__

#  ifndef alloca
#    ifndef __GNUC__
#      ifndef __cplusplus
          void *alloca __PROTO((size_t));
#      else
          void *alloca __PROTO((long unsigned int));
#      endif /* __cplusplus */
#    else
#      define alloca(X) __builtin_alloca(X)
#    endif /* __GNUC__ */
#  endif /* alloca */

#  ifdef atarist
     void _malloczero __PROTO((int __yes));
     void _mallocChunkSize __PROTO((size_t __siz));
#  endif

#endif /* __STRICT_ANSI__ */

__EXITING abort __PROTO((void)) __NORETURN;
#if !(defined (__GNUG__) && __GNUG__ == 1)
  /* bug in g++ 1.39.0 -- cant digest proto */
int atexit __PROTO((void (*)(void)));
#endif
__EXITING exit __PROTO((int)) __NORETURN;

char *getenv __PROTO((const char* __tag));
int system __PROTO((const char* __s));

void *bsearch __PROTO((const void* __key, const void* __base, 
                                size_t __num, size_t __size, 
                                int (*__cmp )(const void *, const void *)));
void qsort __PROTO((void* __base, size_t __total_elems, 
                             size_t __size, 
                             int (*__cmp )(const void *, const void *)));

int abs __PROTO((int __x));
long labs __PROTO((long __x));

div_t div __PROTO((int __num, int __denom));
ldiv_t ldiv __PROTO((long __num, long __denom));

int mblen __PROTO((const char *, size_t));
size_t mbstowcs __PROTO((wchar_t *, const char *, size_t));
int mbtowc __PROTO((wchar_t *, const char *, size_t));
size_t wcstombs __PROTO((char *, const wchar_t *, size_t));
int wctomb __PROTO((char *, wchar_t));

wchar_t *wcscat __PROTO((wchar_t *, const wchar_t *));
int wcscmp __PROTO((const wchar_t *, const wchar_t *));
wchar_t *wcscpy __PROTO((wchar_t *, const wchar_t *));
size_t wcslen __PROTO((const wchar_t *));
wchar_t *wcsncat __PROTO((wchar_t *, const wchar_t *, size_t));
int wcsncmp __PROTO((const wchar_t *, const wchar_t *, size_t));
wchar_t *wcsncpy __PROTO((wchar_t *, const wchar_t *, size_t));

/* This function is similar to the above but returns NULL if the
   programs is running with SUID or SGID enabled.  */
char *__secure_getenv __PROTO ((const char *__name));

#if defined(__USE_SVID) || defined(__USE_XOPEN)
/* The SVID says this is in <stdio.h>, but this seems a better place.	*/
/* Put STRING, which is of the form "NAME=VALUE", in the environment.
   If there is no `=', remove NAME from the environment.  */
int putenv __PROTO ((const char *__string));
#endif

#ifdef	__USE_BSD
/* Set NAME to VALUE in the environment.
   If REPLACE is nonzero, overwrite an existing value.  */
int setenv __PROTO ((const char *__name, const char *__value,
			int __replace));

/* Remove the variable NAME from the environment.  */
void unsetenv __PROTO ((const char *__name));
#endif

#ifdef __USE_MISC
/* The `clearenv` was planned to be added to POSIX.1 but probably
   never made it.  Nevertheless the POSIX.9 standard (POSIX bindings
   for Fortran 77) requires this function.  */
int clearenv __PROTO ((void));
#endif

#if defined(__USE_MISC) || defined(__USE_XOPEN_EXTENDED)
/* Generate a unique temporary file name from TEMPLATE.
   The last six characters of TEMPLATE must be "XXXXXX";
   they are replaced with a string that makes the file name unique.
   Returns TEMPLATE, or a null pointer if it cannot get a unique file name.  */
char *mktemp __PROTO ((char* __template));

/* Generate a unique temporary file name from TEMPLATE.
   The last six characters of TEMPLATE must be "XXXXXX";
   they are replaced with a string that makes the filename unique.
   Returns a file descriptor open on the file for reading and writing,
   or -1 if it cannot create a uniquely-named file.  */
int mkstemp __PROTO ((char* __template));
#endif

#ifdef __USE_GNU
/* Return a malloc'd string containing the canonical absolute name of the
   named file.  The last file name component need not exist, and may be a
   symlink to a nonexistent file.  */
char* canonicalize_file_name __PROTO((const char* __name));
#endif

#if defined __USE_BSD || defined __USE_XOPEN_EXTENDED
/* Return the canonical absolute name of file NAME.  The last file name
   component need not exist, and may be a symlink to a nonexistent file.
   If RESOLVED is null, the result is malloc'd; otherwise, if the canonical
   name is PATH_MAX chars or more, returns null with `errno' set to
   ENAMETOOLONG; if the name fits in fewer then PATH_MAX chars, returns
   the name in RESOLVED.  */
char* realpath __PROTO((const char* __name, char* __resolved));
#endif

#if defined(__LATTICE__) && !defined(_NO_INLINE)

int	__builtin_abs(int);
long	__builtin_labs(long);

#define abs(i)	__builtin_abs(i);
#define labs(l)	__builtin_labs(l);

#endif

end_decls

#endif /* _STDLIB_H */
