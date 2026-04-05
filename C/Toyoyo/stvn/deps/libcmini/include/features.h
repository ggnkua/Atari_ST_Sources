#ifndef	_FEATURES_H
#define	_FEATURES_H	1

#undef	__USE_ISOC11
#undef	__USE_ISOC99
#undef	__USE_ISOC95
#undef	__USE_ISOCXX11
#undef	__USE_POSIX
#undef	__USE_POSIX2
#undef	__USE_POSIX199309
#undef	__USE_POSIX199506
#undef	__USE_XOPEN
#undef	__USE_XOPEN_EXTENDED
#undef	__USE_UNIX98
#undef	__USE_XOPEN2K
#undef	__USE_XOPEN2KXSI
#undef	__USE_XOPEN2K8
#undef	__USE_XOPEN2K8XSI
#undef	__USE_LARGEFILE
#undef	__USE_LARGEFILE64
#undef	__USE_FILE_OFFSET64
#undef	__USE_BSD
#undef	__USE_SVID
#undef	__USE_MISC
#undef	__USE_ATFILE
#undef	__USE_GNU
#undef	__USE_REENTRANT
#undef	__USE_FORTIFY_LEVEL
#undef	__FAVOR_BSD
#undef	__KERNEL_STRICT_NAMES
#undef  __USE_MINTLIB
#undef	__GLIBC_USE_DEPRECATED_GETS

#define	__USE_ANSI	1

/* turn on all the other features.  */
#undef  _ISOC95_SOURCE
#define _ISOC95_SOURCE	1
#undef  _ISOC99_SOURCE
#define _ISOC99_SOURCE	1
#undef  _ISOC11_SOURCE
#define _ISOC11_SOURCE	1
#undef  _POSIX_SOURCE
#define _POSIX_SOURCE	1
#undef  _POSIX_C_SOURCE
#define _POSIX_C_SOURCE	200809L
#undef  _XOPEN_SOURCE
#define _XOPEN_SOURCE	700
#undef  _XOPEN_SOURCE_EXTENDED
#define _XOPEN_SOURCE_EXTENDED	1
#undef  _BSD_SOURCE
#define _BSD_SOURCE	1
#undef  _SVID_SOURCE
#define _SVID_SOURCE	1
#undef  _DEFAULT_SOURCE
#define _DEFAULT_SOURCE	1

#define __USE_ISOC11	1
#define __USE_ISOC99	1
#define __USE_ISOC95	1
#define __USE_ISOC11	1
#if defined(__cplusplus) && __cplusplus >= 201103L
#  define __USE_ISOCXX11	1
#endif
#define __USE_POSIX	1
#define __USE_POSIX2	1
#define __USE_POSIX199309	1
#define __USE_POSIX199506	1
#define __USE_XOPEN2K		1
#define __USE_XOPEN	1
#define __USE_XOPEN_EXTENDED	1
#define __USE_MISC	1
#define __USE_BSD	1
#define __USE_SVID	1
#define __USE_GNU	1

#include <sys/cdefs.h>

/* Decide whether we can define 'extern inline' functions in headers.  */
#if __GNUC_PREREQ (2, 7) && defined __OPTIMIZE__ \
    && !defined __OPTIMIZE_SIZE__ && !defined __NO_INLINE__
# define __USE_EXTERN_INLINES	1
# if (defined __GNUC_STDC_INLINE__ && __GNUC_STDC_INLINE__) || \
     defined __cplusplus || \
     (defined __clang__ && (defined __GNUC_STDC_INLINE__ || defined __GNUC_GNU_INLINE__))
#   define _EXTERN_INLINE extern __inline __attribute__((__gnu_inline__))
# else
#   define _EXTERN_INLINE extern __inline
# endif
#else
# define _EXTERN_INLINE extern
#endif

#endif	/* features.h  */
