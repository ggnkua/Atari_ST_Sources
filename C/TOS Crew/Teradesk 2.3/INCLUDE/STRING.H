/*      STRING.H

        String Definitions

        Copyright (C) Borland International 1990
        All Rights Reserved.
*/


#if !defined( __STRING )
#define __STRING


typedef unsigned long    size_t;


char    *strcat( char *s1, const char *s2 );
char    *strncat( char *s1, const char *s2, size_t n );
int     strcmp( const char *s1, const char *s2 );
int     stricmp( const char *s1, const char *s2 );
int     strcmpi( const char *s1, const char *s2 );
int     strncmp( const char *s1, const char *s2, size_t n );
int     strnicmp( const char *s1, const char *s2, size_t n );
int     strncmpi( const char *s1, const char *s2, size_t n );
char    *strcpy( char *s1, const char *s2 );
char    *strncpy( char *s1, const char *s2, size_t n );
char    *strdup( const char *s );

size_t  strlen( const char *s );

char    *strchr( const char *s, int c );
char    *strrchr( const char *s, int c );

size_t  strspn( const char *s, const char *set );
size_t  strcspn( const char *s, const char *set );
char    *strpbrk( const char *s, const char *set );

char    *strstr( const char *src, const char *sub );
char    *strtok( char *str, const char *set );

char    *strupr( char *s );
char    *strlwr( char *s );
char    *strrev( char *s );
char    *strset( char *s, int c );
char    *strnset( char *s, int c, size_t n );

double  strtod( const char *s, char **endptr );
long    strtol( const char *str, char **ptr, int base );
unsigned long   strtoul( const char *str, char **ptr, int base );

char    *strerror( int errnum );

void    *memchr( const void *ptr, int val, size_t len );
int     memcmp( const void *ptr1, const void *ptr2, size_t len );
void    *memcpy( void *dest, const void *src, size_t len );
void    *memmove( void *dest, const void *src, size_t len );
void    *memset( void *ptr, int val, size_t len );


#endif

/************************************************************************/
