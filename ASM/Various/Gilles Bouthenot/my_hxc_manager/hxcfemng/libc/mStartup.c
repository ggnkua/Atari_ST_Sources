
//CPP startup
#include <mint/osbind.h>
#include <mint/falcon.h>

#include <string.h>
#include <stdio.h>

#include <limits.h>
#include <ctype.h>
#include <stdlib.h>



void __main(){}




// ----------------------------------------------------------------------------------------

int puts( const char* pText ){
	Cconws ( pText );
	Cconws ( "\r\n" );
	return 0;
}

// ----------------------------------------------------------------------------------------

void* memset ( void * ptr, int value, size_t num )
{
	unsigned char* pTemp = (unsigned char*) ptr;

	while ( num-- )
	{
		*pTemp++=value;
	}

	return ptr;
}

// ----------------------------------------------------------------------------------------

inline char *strcpy(char *dest, const char* src)
{
	char *ret = dest;
	while ((*dest++ = *src++)) {
	};

	return ret;
}

// ----------------------------------------------------------------------------------------

void * malloc ( size_t size )
{
	return (void*)Malloc( size);
}

// ----------------------------------------------------------------------------------------

void * calloc ( size_t num, size_t size )
{
	char *ptr = (char*) Malloc( size*num);
	memset( ptr, 0, size*num );
	return ptr;
}

// ----------------------------------------------------------------------------------------
void * mallocFAST ( size_t size )
{
	return (void*)Mxalloc( size, MX_PREFTTRAM);
}

// ----------------------------------------------------------------------------------------

void * callocFAST ( size_t num, size_t size )
{
	char *ptr = (char*) Mxalloc( size*num , MX_PREFTTRAM);
	memset( ptr, 0, size*num );
	return ptr;
}

// ----------------------------------------------------------------------------------------

void free ( void * ptr )
{
	if ( ptr )
	{
		Mfree ( ptr );
	}
}

// ----------------------------------------------------------------------------------------

void * realloc ( void * ptr, size_t size )
{
	char *newptr = (char*) Malloc( size);
	memcpy ( newptr, ptr, size );
	Mfree ( ptr );
	return newptr;
}

// ----------------------------------------------------------------------------------------
void * reallocFAST ( void * ptr, size_t size )
{
	char *newptr = (char*) Mxalloc( size , MX_PREFTTRAM);
	memcpy ( newptr, ptr, size );
	Mfree ( ptr );
	return newptr;
}

// ----------------------------------------------------------------------------------------

/*
size_t strlen ( const char * str )
{
	size_t len = 0;
	while ( *(char*)str ++ != 0 ) len++;
	return len;
}
*/

// ----------------------------------------------------------------------------------------

/*
int strcmp(const char *s1, const char *s2)
{
	while((*s1 && *s2) && (*s1++ == *s2++));
	return *(--s1) - *(--s2);
}
*/

// ----------------------------------------------------------------------------------------

void* memmove(void *destination, const void *source, size_t n)
{
	char* dest = (char*)destination;
	char* src = (char*)source;

	/* No need to do that thing. */
	if (dest == src)
		return destination;

	/* Check for destructive overlap.  */
	if (src < dest && dest < src + n) {
		/* Destructive overlap ... have to copy backwards.  */
		src += n;
		dest += n;
		while (n-- > 0)
			*--dest = *--src;
	} else {
		/* Do an ascending copy.  */
		while (n-- > 0)
			*dest++ = *src++;
	}

	return destination;
}

// ----------------------------------------------------------------------------------------

int atoi( const char* pStr )
{
  int iRetVal = 0;
  int iTens = 1;

  if ( pStr )
  {
	const char* pCur = pStr;
	while (*pCur)
	  pCur++;

	pCur--;

	while ( pCur >= pStr && *pCur <= '9' && *pCur >= '0' )
	{
	  iRetVal += ((*pCur - '0') * iTens);
	  pCur--;
	  iTens *= 10;
	}
  }
  return iRetVal;
}

// ----------------------------------------------------------------------------------------

/* from http://clc-wiki.net/wiki/strncpy */
char *strncpy(char *dest, const char *src, size_t n)
{
	char *ret = dest;
	do {
		if (!n--)
			return ret;
	} while ((*dest++ = *src++));
	while (n--)
		*dest++ = 0;
	return ret;
}

/* from http://clc-wiki.net/wiki/strncmp */
int strncmp(const char* s1, const char* s2, size_t n)
{
	while(n--)
		if(*s1++!=*s2++)
			return *(unsigned char*)(s1 - 1) - *(unsigned char*)(s2 - 1);
	return 0;
}

/* from http://clc-wiki.net/wiki/strcat */
char *strcat(char *dest, const char *src)
{
	char *ret = dest;
	while (*dest)
		dest++;
	while ((*dest++ = *src++))
		;
	return ret;
}

#if(0)
/* from http://clc-wiki.net/wiki/strstr */
/* uses memcmp, strlen */
/* For 52 more bytes, an assembly optimized version is available in the .s file */
char *strstr(const char *s1, const char *s2)
{
	size_t n = strlen(s2);
	while(*s1)
		if(!memcmp(s1++,s2,n))
			return (char *) (s1-1);
	return (char *)0;
}
#endif

/* from http://clc-wiki.net/wiki/C_standard_library:string.h:strchr */
char *strchr(const char *s, int c)
{
	while (*s != (char)c)
		if (!*s++)
			return 0;
	return (char *)s;
}

/* from http://clc-wiki.net/wiki/memcmp */
int memcmp(const void* s1, const void* s2,size_t n)
{
	const unsigned char *p1 = s1, *p2 = s2;
	while(n--)
		if( *p1 != *p2 )
			return *p1 - *p2;
		else
			p1++,p2++;
	return 0;
}

/* from http://clc-wiki.net/wiki/C_standard_library:string.h:memchr */
void *memchr(const void *s, int c, size_t n)
{
	unsigned char *p = (unsigned char*)s;
	while( n-- )
		if( *p != (unsigned char)c )
			p++;
		else
			return p;
	return 0;
}

/* from http://code.google.com/p/embox/source/browse/trunk/embox/src/lib/string/strlwr.c?spec=svn3211&r=3211 */
char *strlwr (char * string ) {
	char * cp;

	for (cp=string; *cp; ++cp) {
		if ('A' <= *cp && *cp <= 'Z') {
			*cp += 'a' - 'A';
		}
	}

	return(string);
}

int toupper (int c) {
	if ('a' <= c && c <= 'z') {
		c -= 'a' - 'A';
	}
	return c;
}
int tolower (int c) {
	if ('A' <= c && c <= 'Z') {
		c += 'a' - 'A';
	}
	return c;
}


/* Possible sources:
http://code.google.com/p/plan9front/source/browse/sys/src/libc/68000/?r=d992998a50139655fdb4cb7995e996219c6735d5
https://bitbucket.org/npe/nix/src/15af5ea53bed/src/9kron/libc/68000/
http://clc-wiki.net/wiki/C_standard_library
http://code.google.com/p/embox/source/browse/trunk/embox/src/lib/string/?r=3211
http://www.koders.com/noncode/fid355C9167E5496B5F863EAEB5758B4236711466D2.aspx
http://svn.opentom.org/opentom/trunk/linux-2.6/arch/m68knommu/lib/
*/
