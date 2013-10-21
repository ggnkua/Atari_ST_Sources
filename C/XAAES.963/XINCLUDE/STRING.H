/*
 * String functions.
 */
#ifndef _STRING_H
#define _STRING_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

begin_decls

#ifndef _SIZE_T
#define _SIZE_T __SIZE_TYPEDEF__
typedef _SIZE_T size_t;
#endif

#ifndef NULL
#define NULL __NULL
#endif

void *memcpy (void *dst, const void *src, size_t size);
void *memmove (void *dst, const void *src, size_t size);
int memcmp (const void *s1, const void *s2, size_t size);
void *memchr (const void *s, int ucharwanted, size_t size);
void *memset (void *s, int ucharfill, size_t size);

#if  1   /*  def __USE_GNU  */			/* 7'99 HR */
/* Copy N bytes of SRC to DEST, return pointer to bytes afterthe last
   written byte.  */
void* __mempcpy (void* __dest, const void* src, size_t n);
void* mempcpy (void* __dest, const void* src, size_t n);
#endif

char *strcpy (char *dst, const char *src);
char *strncpy (char *dst, const char *src, size_t n);
char *strcat (char *dst, const char *src);
char *strncat (char *dst, const char *src, size_t n);
int strcmp (const char *scan1, const char *scan2);
int strncmp (const char *scan1, const char *scan2, size_t n);
int strcoll (const char *scan1, const char *scan2);
size_t	strxfrm (char *to, const char *from, size_t maxsize);
char *strchr (const char *s, int charwanted);
size_t strcspn (const char *s, const char *reject);
char *strpbrk (const char *s, const char *breakat);
char *strrchr (const char *s, int charwanted);
size_t strspn (const char *s, const char *accept);
char *strstr (const char *s, const char *wanted);
char *strtok (char *s, const char *delim);
char *strtok_r (char* s, const char* delim, char** saveptr);
size_t strlen (const char *scan);
char *strerror (int errnum);
/* Provided for compatibility with the GNU libc.  Not really needed
   unless you want to write portable code (the normal strerror function
   is also threadsafe).  */
char *strerror_r (int errnum, char* buf, size_t buflen);

#if defined(__USE_SVID) || defined(__USE_BSD)
/* 
 * from henry spencers string lib
 *  these dont appear in ansi draft sec 4.11
 */
void *memccpy (void *dst, const void *src, int ucharstop, size_t size);

# ifndef __STRICT_ANSI__
char *strlwr (char *string);
char *strupr (char *string);
/* CAUTION: there are assumptions elsewhere in the code that strrev()
   reverses in-place
 */
char *strrev (char *string);
# endif
#endif

#if defined(__USE_SVID) || defined (__USE_BSD)
char *strdup (const char *s);
#endif

/* Return a malloc'd copy of at most N bytes of STRING.  The
   resultant string is terminated even if no null terminator
   appears before STRING[N].  */
#if defined __USE_GNU
char* strndup (const char* __string, size_t __n);
#endif

/*
 * V7 and BSD compatibility.
 */
#ifdef __USE_BSD
char *index (const char *s, int charwanted);
char *rindex (const char *s, int charwanted);
void bcopy (const void *src, void *dst, size_t length);
int bcmp (const void *src, const void *dst, size_t n);
void bzero (void *b, size_t n);
#endif

void _bcopy (const void *src, void *dst, unsigned long length);
int  _bcmp (const void *s1, const void *s2, unsigned long length);
void _bzero (void *dst, unsigned long length);

#ifdef __USE_MISC
/* FIXME: Do these four lads belong to wany standard?  */
int stricmp ( const char *, const char * );
int strnicmp ( const char *, const char *, size_t );
int strcmpi ( const char *, const char * );
int strncmpi ( const char *, const char *, size_t );
#endif

int strcasecmp ( const char *, const char * );

#ifdef __USE_GNU
int strncasecmp ( const char *, const char *, size_t );

/* Copy SRC to DEST, returning the address of the terminating '\0' in DEST.  */
char* __stpcpy (char* __dest, const char* __src);
char* stpcpy (char* __dest, const char* __src);

/* Copy no more than N characters of SRC to DEST, returning the address of 
   the last character written into DEST.  */
char* __stpncpy (char* __dest, const char* __src, size_t __n);
char* stpncpy (char* __dest, const char* __src, size_t __n);
#endif

/* some macro versions of functions. these are faster, but less
   forgiving of NULLs and similar nasties. to use the library functions,
   just #undef the appropriate things.
*/

#ifdef __GNUC_INLINE__
# ifndef __cplusplus

static __inline__
char *
__strcat(char *dst, const char *src)
{
	register char *_dscan;

	for (_dscan = dst; *_dscan; _dscan++) ;
	while ((*_dscan++ = *src++)) ;
	return dst;
}

static __inline__ 
char *
__strcpy(char *dst, const char *src)
{
	register char *_dscan = dst;
	while ((*_dscan++ = *src++)) ;
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

# endif /* !__cplusplus */
#endif /* __GNUC_INLINE__ */

#if defined(__LATTICE__) && !defined(_NO_INLINE)

int __builtin_strcmp (const char *, const char *);
char * __builtin_strcpy (char *, const char *);
size_t __builtin_strlen (const char *);

#define strcmp __builtin_strcmp
#define strcpy __builtin_strcpy
#define strlen __builtin_strlen

#endif

#ifdef	__USE_MISC
/* Return the file name within directory of FILENAME.  An equal prototype
   is in <libgen.h>, FIXME!  */
char* basename (const char *__filename);
#endif

end_decls

#endif /* _STRING_H */
