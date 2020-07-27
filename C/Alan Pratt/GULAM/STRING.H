/*
 * String functions.
 */
#ifndef _STRING_H
#define _STRING_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#if defined(__cplusplus)
extern "C" {
#endif


#ifndef _SIZE_T
#define _SIZE_T __SIZE_TYPEDEF__
typedef _SIZE_T size_t;
#endif

#ifndef NULL
#define NULL __NULL
#endif

__EXTERN void *memcpy __PROTO((void *dst, const void *src, size_t size));
__EXTERN void *memmove __PROTO((void *dst, const void *src, size_t size));
__EXTERN int memcmp __PROTO((const void *s1, const void *s2, size_t size));
__EXTERN void *memchr __PROTO((const void *s, int ucharwanted, size_t size));
__EXTERN void *memset __PROTO((void *s, int ucharfill, size_t size));

__EXTERN uchar *strcpy __PROTO((uchar *dst, uchar *src));
__EXTERN uchar *strncpy __PROTO((uchar *dst, uchar *src, size_t n));
__EXTERN uchar *strcat __PROTO((uchar *dst, uchar *src));
__EXTERN uchar *strncat __PROTO((uchar *dst, uchar *src, size_t n));
__EXTERN int strcmp __PROTO((uchar *scan1, uchar *scan2));
__EXTERN int strncmp __PROTO((uchar *scan1, uchar *scan2, size_t n));
 	/* strcoll not implemented for now */
__EXTERN size_t	strcoll __PROTO((uchar *to, size_t maxsize, uchar *from));
__EXTERN uchar *strchr __PROTO((uchar *s, int ucharwanted));
__EXTERN size_t strcspn __PROTO((uchar *s, uchar *reject));
__EXTERN uchar *strpbrk __PROTO((uchar *s, uchar *breakat));
__EXTERN uchar *strrchr __PROTO((uchar *s, int ucharwanted));
__EXTERN size_t strspn __PROTO((uchar *s, uchar *accept));
__EXTERN uchar *strstr __PROTO((uchar *s, uchar *wanted));
__EXTERN uchar *strtok __PROTO((uchar *s, uchar *delim));
__EXTERN size_t strlen __PROTO((uchar *scan));
__EXTERN char *strerror __PROTO((int errnum));

#ifndef __STRICT_ANSI__
/* 
 * from henry spencers string lib
 *  these dont appear in ansi draft sec 4.11
 */
__EXTERN void *memccpy __PROTO((void *dst, const void *src, int ucharstop, size_t size));
__EXTERN uchar *strlwr __PROTO((uchar *string));
/* CAUTION: there are assumptions elsewhere in the code that strrev()
   reverses in-place
 */
__EXTERN uchar *strrev __PROTO((uchar *string));
__EXTERN uchar *strdup __PROTO((uchar *s));

/*
 * V7 and BSD compatibility.
 */
__EXTERN uchar *index __PROTO((uchar *s, int charwanted));
__EXTERN uchar *rindex __PROTO((uchar *s, int charwanted));
__EXTERN void bcopy __PROTO((const void *src, void *dst, size_t length));
__EXTERN int bcmp __PROTO((const void *src, const void *dst, size_t n));
__EXTERN void bzero __PROTO((void *b, size_t n));
#ifdef __MSHORT__
__EXTERN void lbcopy __PROTO((const void *src, void *dst, long length));
__EXTERN int  lbcmp __PROTO((const void *s1, const void *s2, long length));
__EXTERN void lbzero __PROTO((void *dst, long length));
#endif /* __MSHORT__ */
#endif /* __STRICT_ANSI__ */

#ifndef __STRICT_ANSI__
#ifndef __MSHORT__
#define lbcopy	bcopy
#define lbcmp 	bcmp
#define lbzero	bzero
#endif /* __MSHORT__ */
#endif /* __STRICT_ANSI__ */

/* some macro versions of functions. these are faster, but less
   forgiving of NULLs and similar nasties. to use the library functions,
   just #undef the appropriate things.
*/

#if defined(__GNUC__) && !defined(__NO_INLINE__) && !defined(__cplusplus)

static __inline__
char *
__strcat(char *dst, const char *src)
{
	register char *_dscan;

	for (_dscan = dst; *_dscan; _dscan++) ;
	while (*_dscan++ = *src++) ;
	return dst;
}

static __inline__ 
char *
__strcpy(char *dst, const char *src)
{
	register char *_dscan = dst;
	while (*_dscan++ = *src++) ;
	return dst;
}

static __inline__
size_t
__strlen(const char *scan)
{
	register const char *_start = scan+1;
	while (*scan++) ;
	return (size_t)((long)scan - (long)_start);
}

#define strcat 	__strcat
#define strcpy 	__strcpy
#define strlen 	__strlen

#endif /* __GNU__ && !__NO_INLINE__ &&!__cplusplus */

#if defined(__cplusplus)
}
#endif

#endif /* _STRING_H */
