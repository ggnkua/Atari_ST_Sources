#ifndef	_SYS_CDEFS_H
# define _SYS_CDEFS_H 1

#ifdef __GNUC__

#if defined __GNUC__ && defined __GNUC_MINOR__
# define __GNUC_PREREQ(maj, min) \
	((__GNUC__ << 16) + __GNUC_MINOR__ >= ((maj) << 16) + (min))
#else
# define __GNUC_PREREQ(maj, min) 0
#endif

/* All functions, except those with callbacks or those that
   synchronize memory, are leaf functions.  */
# if __GNUC_PREREQ (4, 6) && !defined _LIBC
#  define __LEAF , __leaf__
#  define __LEAF_ATTR __attribute__ ((__leaf__))
# else
#  define __LEAF
#  define __LEAF_ATTR
# endif

# if !defined __cplusplus && __GNUC_PREREQ (3, 3)
#  define __THROW	__attribute__ ((__nothrow__))
#  define __THROWNL	__attribute__ ((__nothrow__))
#  define __NTH(fct)	__attribute__ ((__nothrow__)) fct
# else
#  if defined __cplusplus && __GNUC_PREREQ (2,8)
#   define __THROW	throw ()
#   define __THROWNL	throw ()
#   define __NTH(fct)	fct throw ()
#  else
#   define __THROW
#   define __THROWNL
#   define __NTH(fct)	fct
#  endif
# endif

#if __GNUC_PREREQ(3, 3)
# define __CLOBBER_RETURN(a) 
#else
# define __CLOBBER_RETURN(a) a,
#endif

#if __GNUC_PREREQ(2, 6)
#define AND_MEMORY , "memory"
#else
#define AND_MEMORY
#endif

#if __GNUC_PREREQ(2, 5)
#define __NORETURN __attribute__ ((noreturn))
#define __EXITING void
#else
#define __EXITING volatile void
#endif

#ifndef __CDECL
#ifdef __FASTCALL__
#define __CDECL __attribute__((__cdecl__))
#else
#define __CDECL
#endif
#endif

#else	/* Not GCC.  */

# define __GNUC_PREREQ(maj, min) 0

# define __inline		/* No inline functions.  */

# define __THROW
# define __THROWNL
# define __NTH(fct)	fct

# define __const	const
# define __signed	signed
# define __volatile	volatile

#ifndef __CDECL
#if defined(__PUREC__) || defined(__AHCC__)
#define __CDECL cdecl
#endif
#endif

#endif	/* GCC.  */

#ifndef __attribute__
#  ifndef __GNUC__
#    define __attribute__(x)
#  endif
#endif

#ifndef __NORETURN
#define __NORETURN
#endif

#ifndef __EXITING
#define __EXITING
#endif

#define __CONCAT(x,y)	x ## y
#define __STRING(x)	#x
#define __STRINGIFY(x)	__STRING(x)

#ifdef	__cplusplus
# define __BEGIN_DECLS	extern "C" {
# define __END_DECLS	}
#else
# define __BEGIN_DECLS
# define __END_DECLS
#endif

/* The standard library needs the functions from the ISO C90 standard
   in the std namespace.  At the same time we want to be safe for
   future changes and we include the ISO C99 code in the non-standard
   namespace __c99.  The C++ wrapper header take case of adding the
   definitions to the global namespace.  */
#if defined __cplusplus && defined _GLIBCPP_USE_NAMESPACES
# define __BEGIN_NAMESPACE_STD	namespace std {
# define __END_NAMESPACE_STD	}
# define __USING_NAMESPACE_STD(name) using std::name;
# define __BEGIN_NAMESPACE_C99	namespace __c99 {
# define __END_NAMESPACE_C99	}
# define __USING_NAMESPACE_C99(name) using __c99::name;
#else
/* For compatibility we do not add the declarations into any
   namespace.  They will end up in the global namespace which is what
   old code expects.  */
# define __BEGIN_NAMESPACE_STD
# define __END_NAMESPACE_STD
# define __USING_NAMESPACE_STD(name)
# define __BEGIN_NAMESPACE_C99
# define __END_NAMESPACE_C99
# define __USING_NAMESPACE_C99(name)
#endif


#if __GNUC_PREREQ (2,96)
# define __attribute_malloc__ __attribute__ ((__malloc__))
#else
# define __attribute_malloc__ /* Ignore */
#endif

#if __GNUC_PREREQ (2,96)
# define __attribute_pure__ __attribute__ ((__pure__))
#else
# define __attribute_pure__ /* Ignore */
#endif

#if __GNUC_PREREQ (3,1)
# define __attribute_used__ __attribute__ ((__used__))
# define __attribute_noinline__ __attribute__ ((__noinline__))
#else
# define __attribute_used__ __attribute__ ((__unused__))
# define __attribute_noinline__ /* Ignore */
#endif

#if __GNUC_PREREQ (2,8)
# define __attribute_format_arg__(x) __attribute__ ((__format_arg__ (x)))
#else
# define __attribute_format_arg__(x) /* Ignore */
#endif

#if __GNUC_PREREQ (2,97)
# define __attribute_format_strfmon__(a,b) \
  __attribute__ ((__format__ (__strfmon__, a, b)))
#else
# define __attribute_format_strfmon__(a,b) /* Ignore */
#endif

#if __GNUC_PREREQ (3,3)
# define __nonnull(params) __attribute__ ((__nonnull__ params))
#else
# define __nonnull(params)
#endif

#if !__GNUC_PREREQ (2,8)
# define __extension__		/* Ignore */
#endif

#if !__GNUC_PREREQ (2,92)
# define __restrict	/* Ignore */
#endif

#endif	 /* sys/cdefs.h */
