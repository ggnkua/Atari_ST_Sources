/* compiler specific defines */
/* this file is guaranteed to be included exactly once if you include
   anything at all. all site-dependent or compiler-dependent stuff
   should go here!!!
 */

#ifndef _COMPILER_H
# define _COMPILER_H 1

#include <features.h>

/* symbol to identify the library itself */
#ifndef __MINT__
# define __MINT__
#endif

/* symbols to identify the type of compiler */

#ifdef LATTICE
#define __LATTICE__
#endif

/* general library stuff */
/* __SIZE_TYPEDEF__: 	the type returned by sizeof() */
/* __PTRDIFF_TYPEDEF__: the type of the difference of two pointers */
/* __WCHAR_TYPEDEF__: 	wide character type (i.e. type of L'x') */
/* __EXITING:           the type of a function that exits */
/* __NORETURN:          attribute of a function that exits (gcc >= 2.5) */
/* __CDECL:             function must get parameters on stack */
		/* if !__CDECL, passing in registers is OK */

/* symbols to report about compiler features */
/* #define __NEED_VOID__	compiler doesn't have a void type */
/* #define __MSHORT__		compiler uses 16 bit integers */
/* (note that gcc and C68 define this automatically when appropriate) */

#ifdef __GNUC__
#if __GNUC__ > 1
#define __SIZE_TYPEDEF__ __SIZE_TYPE__
#define __PTRDIFF_TYPEDEF__ __PTRDIFF_TYPE__
#ifdef __GNUG__
/* In C++, wchar_t is a distinct basic type,
   and we can expect __wchar_t to be defined by cc1plus.  */
#define __WCHAR_TYPEDEF__ __wchar_t
#else
/* In C, cpp tells us which type to make an alias for.  */
#define __WCHAR_TYPEDEF__ __WCHAR_TYPE__
#endif
#else
#ifndef sun
#  define __SIZE_TYPEDEF__ unsigned long
#  define __PTRDIFF_TYPEDEF__ long
#  define __WCHAR_TYPEDEF__ int
#else
   /* sun always seems to have an agenda of their own */
#  include <sys/stdtypes.h>
#  define __SIZE_TYPEDEF__ int          /* can you believe this!! */
#  define __PTRDIFF_TYPEDEF__ int       /* or this!! */
#  define __WCHAR_TYPEDEF__ unsigned short /* this seems reasonable */
#  define _SIZE_T __SIZE_TYPEDEF__
#  define _WCHAR_T __WCHAR_TYPEDEF__
#endif
#endif
#if (__GNUC__ == 2) && (__GNUC_MINOR__ >= 5) /* false for gcc < 2.5 */
#define __NORETURN __attribute__ ((noreturn))
#define __EXITING void
#else
#define __EXITING volatile void
#endif
#define __VA_LIST__ void *
#ifndef __NO_INLINE__
# define __GNUC_INLINE__
#endif
#endif

#ifdef __LATTICE__
#define __SIZE_TYPEDEF__ unsigned long
#define __PTRDIFF_TYPEDEF__ long
#define __WCHAR_TYPEDEF__ char
#define __EXITING void
#define __CDECL __stdargs
#ifdef _SHORTINT
# define __MSHORT__
#endif
#ifdef _UNSIGNEDCHAR
# define __CHAR_UNSIGNED__
#endif
#endif

#ifdef __C68__
#define __SIZE_TYPEDEF__ unsigned long
#define __PTRDIFF_TYPEDEF__ long
#define __WCHAR_TYPEDEF__ char
#define __EXITING void
#endif

#ifdef __TURBOC__
#ifndef __STDC__			/* we deal with 'cdecl' below */
#  define __STDC__ 1		/* We must include cdecl in the standard there is no choice */
#endif	
#define __SIZE_TYPEDEF__ unsigned long
#define __PTRDIFF_TYPEDEF__ long
#define __WCHAR_TYPEDEF__ char
#define __EXITING void
#define __MSHORT__
#define __VA_LIST__ void *
#define __CDECL cdecl
#define __cdecl cdecl					/* 7'99 HR  */
#define __NULL 0						/*   "     Good enough for ANSI */

/* As long as we haven't ported gemlib to Pure C and hence have to use
 * Turbo's/Pure's GEM library, define the next:
 */
#define __TCC_GEMLIB__
#endif /* __TURBOC__ */

#ifndef __STDC__
#error pre ANSI compilers are out!! (H.Robbers)
#else

	#if defined(__hpux) && (!defined(__GNUC__))
	#define __SIZE_TYPEDEF__ unsigned int
	#define __PTRDIFF_TYPEDEF__ int
	#define __WCHAR_TYPEDEF__ unsigned int
	#define __EXITING void
	#endif

	/* some default declarations */
	/* if your compiler needs something
	 * different, define it above
	 */
	#ifndef __VA_LIST__
	#define __VA_LIST__ char *
	#endif

	#ifndef __CDECL
	#define __CDECL
	#endif

	#ifndef __NORETURN
	#define __NORETURN
	#endif

	#ifndef __NULL
	#  ifdef __MSHORT__
	#    define __NULL ((void *)0)
	#  else
	     /* avoid complaints about misuse of NULL :-) */
	#    define __NULL (0)
	#  endif
	#  define nil __NULL
	#endif

	#define __EXTERN
	#define __PROTO(x) x

	/* macros for POSIX support */
	#ifndef __hpux
	#define _UID_T unsigned short
	#define _GID_T unsigned short
	#define _PID_T int
	#define _POSIX_VERSION 1
	#endif

	/* used in limits.h, stdio.h */
	#define	_NFILE		(32)		/* maximum number of open streams */

	#ifdef __TURBOC__
	#define atarist
	#endif

	/* These macros are provided for GNU compatibility.  */
	#ifndef __P
	# define __P(x) __PROTO(x)
	#endif

	#ifdef __cplusplus
	# ifndef __BEGIN_DECLS
	#  define __BEGIN_DECLS extern "C" {
	#  define __END_DECLS }
	# endif
	#else
	# ifndef __BEGIN_DECLS
	#  define __BEGIN_DECLS
	#  define __END_DECLS
	# endif
	#endif

	#ifdef _LIBC
	# include <libc-symbols.h>
	#endif

	#define begin_decls __BEGIN_DECLS
	#define end_decls __END_DECLS
#endif /* __STDC__ */
#endif /* _COMPILER_H */
