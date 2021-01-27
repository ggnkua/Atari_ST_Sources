/* This file is part of the AHCC C Library.

   The AHCC C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The AHCC C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.
*/

/* string.c */
/* from Dale Schumacher's dLibs library */
/* Adapted to ANSI and AHCC by H. Robbers */

#include <prelude.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

char *strcat ( char *dest, const char *source )
{
	char *p = dest;

	while (*p) ++p;
	while ((*p++ = *source++) ne 0);

	return dest;
}

char *strncat(char *dest, const char *source, size_t limit)
{
	char *p = dest;

	while (*p) ++p;
	while (limit-- ne 0 and (*p++ = *source++) ne 0);

	*p = '\0';

	return dest;
}

short strcmp(const char *str1, const char *str2)
{
	for (; *str1 eq *str2; ++str1, ++str2)
		if (*str1 eq '\0')
			return 0;

	return *str1 - *str2;
}

short stricmp(const char *str1, const char *str2)
{
	char c1, c2;

	for (;   (c1 = tolower(*str1))
	      eq (c2 = tolower(*str2));
	      ++str1, ++str2
	    )
		if (c1 eq '\0')
			return 0;

	return c1 - c2;
}

short strcmpi( const char *str1, const char *str2 )
{ return stricmp(str1, str2); }

short strncmp( const char *str1, const char *str2, size_t limit )
{
	for(; --limit ne 0 and *str1 eq *str2; ++str1, ++str2)
		if (*str1 eq '\0')
			return 0;

	return *str1 - *str2;
}

short strnicmp( const char *str1, const char *str2, size_t limit )
{
	char c1, c2;

	for(;    --limit ne 0
	     and (   (c1 = tolower(*str1))
	          eq (c2 = tolower(*str2))
	         );
	     ++str1, ++str2
	    )
		if (c1 eq '\0')
			return 0;

	return c1 - c2;
}

short   strncmpi	( const char *s1, const char *s2, size_t n );

/* copy string upto and including /0 character */
char *strcpy(char *d, const char *s)
{
	char *td = d;
	while ((*td++ = *s++) ne 0);
	return d;
}

/* copy string upto and including /0 character or until l expires */
char *strncpy(char *d, const char *s, size_t l)
{
	char *p = d;

	while(l-- ne 0 and (*p++ = *s++) ne 0);
	return d;
}

char *strdup( const char *string )
{
	char *p;

	if ((p = malloc(strlen(string) + 1)) ne nil)
		strcpy(p, string);
	return p;
}

size_t strlen( const char *string )
{
	size_t n = 0;

	while (*string++) ++n;
	return n;
}

char *strchr ( const char *s, short c )
{
	while (*s and (uchar)*s ne (uchar)c) s++;
	return *s ? s : (c eq 0 ? s : nil);
}

char *strrchr ( const char *s, short c )
{
	const char *p = s;

	while (*s++);

	do
		if (*(uchar *)--s eq (uchar)c)
			return s;
	while (s != p);

	return nil;
}

size_t strspn ( const char *s, const char *set )
{
	size_t n = 0;

	while (*s and strchr(set, *s++)) ++n;

	return n;
}

size_t strcspn( const char *s, const char *set )
{
	size_t n = 0;

	while (*s and !strchr(set, *s++)) ++n;

	return n;
}

char *strpbrk( const char *s, const char *set )
{
	while(*s)
	{
		if (strchr(set, *s))
			return(s);
		++s;
	}

	return nil;
}

char *strstr ( const char *s, const char *pattern )
{
	size_t plen = strlen(pattern);

	while((s = strchr(s, *pattern)) ne 0)
	{
		if (strncmp(s, pattern, plen) eq 0)
			break;

		++s;
	}

	return s;
}

char *strtok( char *s, const char *delim )
{
	char *p;
	static char *_strtok = NULL;	/* local token pointer */

	if (s eq NULL)
		s = _strtok;

	while (*s and strchr(delim, *s))
		++s;

	if (*s eq '\0')		/* no more tokens */
		return(NULL);

	p = s;

	while (*s and !strchr(delim, *s))
		++s;

	if (*s != '\0')
		*s++ = '\0';

	_strtok = s;
	return p;
}

static
char *__uplw(char *s, _CTYPE_c *uplw)
{
	char *p = s;

	while(*s)
	{
		if (uplw(*s))
			*s ^= 0x20;

		++s;
	}

	return p;
}

char *strupr( char *s ) { return __uplw(s, islower); }
char *strlwr( char *s ) { return __uplw(s, isupper); }

char *strrev( char *s )
{
	char *p = s, *q, c;

	if (*(q = p) ne 0)		/* non-empty string ? */
	{
		while (*++q) ;

		while (--q > p)
		{
			c    = *q;
			*q   = *p;
			*p++ = c;
		}
	}
	return s;
}

char *strset( char *s, short c )
{
	char *p = s;

	while (*p)
		*p++ = c;

	return s;
}

char *strnset( char *s, short c, size_t n )
{
	char *p = s;

	while (n-- and *p)
		*p++ = c;

	return s;
}

/*
 *	Adjust <string> by adding space if <dir> is positive, or removing
 *	space if <dir> is negative.  The magnitude of <dir> is the number
 *	of character positions to add or remove.  Characters are added or
 *	removed at the beginning of <string>.  A pointer to the modified
 *	<string> is returned.
 */
char *stradj(char *s, short dir)
{
	 char *p = s, *q;

	if (dir eq 0)
		return(s);

	if (dir > 0)						/* add space */
	{
		while (*p) ++p;					/* find end */
		q = p + dir;					/* set gap */

		while(p >= s)				/* copy data */
			*q-- = *p--;

		while (q >= s)				/* replace <nul>s */
		{
			if (*q eq '\0')
				*q = ' ';
			--q;
		}
	othw								/* remove space */
		dir = -dir;
		q = p + dir;					/* set gap */

		while ((*p++ = *q++) ne 0);		/* copy data */
	}

	return s;
}

void *memchr( const void *ptr, short val, size_t len )
{
	char *p = ptr;

	while (len--)
		if (*p++ eq val)
			return --p;

	return nil;
}

short memcmp( const void *mem1, const void *mem2, size_t len )
{
	const char *m1 = mem1, *m2 = mem2;

	while (--len and *m1 eq *m2)
		++m1, ++m2;

	return *m1 - *m2;
}

void *memmove( void *dest, const void *src, size_t len )
{
	char *p = dest, *source = src;

	if (source < p)
	{
		p += len;
		source += len;
		while (len--) *--p = *--source;
	}
	else
		while (len--) *p++ = *source++;

	return dest;
}
void *	memcpy( void *dest, const void *src, size_t len )
{
	return memmove(dest, src, len);
}

void *memset( void *dest, short data, size_t len )
{
	char *p = dest;

	while (len--) *p++ = data;

	return dest;
}

/* in dlibs, not in PC lib */

short memicmp( const char *mem1, const char *mem2, size_t len )
{
	char c1, c2;

	while((   (c1 = tolower(*mem1++)) == (c2 = tolower(*mem2++)))
	       && (--len))
		;
	return c1 - c2;
}

void *memccpy( char *dst, const char *src, const char c, short cnt )
{
	while (cnt--)
		if ((*dst++ = *src++) == c)
			return dst;

 	return nil;
}

char *stristr(const char *string, const char *pattern)
{
	size_t plen;

	plen = strlen(pattern);

	while(*string)
	{
		if (strnicmp(string, pattern, plen) == 0)
			return string;
		++string;
	}

	return nil;
}

/*
 *	Replace at most <n> occurances of <ptrn> in <string> with <rpl>.
 *	If <n> is -1, replace all.  Return the number of replacments.
 */
short strrpl(char *string, const char *ptrn, const char *rpl, short n)
{
	char *p, *q = string;
	size_t d, rlen;
	short nn = 0;

	rlen = strlen(rpl);
	d = rlen - strlen(ptrn);

	while (n && (p = strstr(q, ptrn)) ne 0)
	{
		++nn;
		stradj(p, d);
		strncpy(p, rpl, rlen);
		q = p + rlen;

		if(n > 0) --n;
	}

	return nn;
}

short strirpl(char *string, const char *ptrn, const char *rpl, short n)
{
	char *p, *q = string;
	size_t d, rlen;
	short nn = 0;

	rlen = strlen(rpl);
	d = rlen - strlen(ptrn);

	while (n and (p = stristr(q, ptrn)) ne 0)
	{
		++nn;
		stradj(p, d);
		strncpy(p, rpl, rlen);
		q = p + rlen;

		if (n > 0) --n;
	}

	return nn;
}

char *strpcpy(char *dest, char *start, char *stop)
{
	char *p = dest;

	while(start <= stop and (*dest++ = *start++) ne 0);

	return(p);
}

ptrdiff_t strpos(char *string, char symbol)
{
	char *p;

	if ((p = strchr(string, symbol)) ne 0)
		return p - string;

	return -1;
}

ptrdiff_t strrpos(char *string, char symbol)
{
	char *p;

	if ((p = strrchr(string, symbol)) ne 0)
		return p - string;

	return -1;
}

char *strrpbrk(const char *string, const char *set)
{
	char *p = strrchr(string, '\0');		/* start at EOS */

	while (string != p)
	{
		if (strchr(set, *--p))
			return p;
	}
	return nil;
}

char *strtrim(char *string, char *junk)
{
	char *p = string;

	while(*p and (strchr(junk, *p)) ne 0) ++p;

	if (*p)
	{
		string = strrchr(p, '\0');

		while (strchr(junk, *--string) ne 0);

		*++string = '\0';
	}

	return p;
}

char *substr(char *dest, char *source, size_t start, size_t end)
{
	char *p = dest;
	size_t n;

	n = strlen(source);

	if (start > n)
		start = n - 1;

	if( end > n)
		end = n - 1;

	source += start;

	while (start++ <= end)
		*p++ = *source++;

	*p = '\0';

	return dest;
}

char *subnstr(char *dest, char *source, size_t start, size_t length)
{
	char *p = dest;
	size_t n;

	n = strlen(source);

	if (start > n)
		start = n - 1;

	source += start;

	while (*source and (length--))
		*p++ = *source++;

	*p = '\0';

	return dest;
}

/*
 *	Note the backward order of the <src> and <dst> parameters.  Don't
 *	blame me... this is how Microsoft specifies it.
 */
void swab(char *src, char *dst, size_t n)
{
	char c;

	n >>= 1;		/* convert to a word count */

	while(n--)
	{
		c = *dst++;
		*dst++ = *src++;
		*src++ = c;
	}
}
