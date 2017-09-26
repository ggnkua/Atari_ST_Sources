#ifdef	MEMDEBUG
#include	<STRING.H>
#define	strdup(a)	strcpy( malloc( strlen( a ) + 1 ), a )
#include	<memdebug.h>
#else
#include	<STDDEF.H>
#define	malloc(a)	mt_malloc(a)
#define	calloc(a,b)	mt_calloc(a,b)
#define	realloc(a,b)	mt_realloc(a,b)
#define	strdup(a)	mt_strdup(a)
#define	free(a)	mt_free(a)
void	*mt_malloc( size_t size );
void  *mt_calloc( size_t nitems, size_t size );
void	*mt_realloc( void *block, size_t newsize );
char  *mt_strdup( const char *s );
void	mt_free( void *ptr );

#endif

#include	<STDIO.H>
#define	flcose(a)	mt_fclose(a)
#define	fgets(a,b,c)	mt_fgets(a,b,c)
#define	fopen(a,b)	mt_fopen(a,b)
#define	fprintf		mt_fprintf
#define	fread(a,b,c,d)	mt_fread(a,b,c,d)

#define	memcpy(a,b,c)	mt_memcpy(a,b,c)

#define	strcat(a,b)	mt_strcat(a,b)
#define	strncat(a,b,c)	mt_strncat(a,b,c)
#define	strcpy(a,b)	mt_strcpy(a,b)
#define	strncpy(a,b,c)	mt_strncpy(a,b,c)

int	mt_fclose( FILE *stream );
char	*mt_fgets( char *str, int n, FILE *stream );
FILE	*mt_fopen( const char *filename, const char *mode );
int	mt_fprintf( FILE *stream, const char *format, ... );
int	mt_fscanf( FILE *stream, const char *format, ... );
size_t  mt_fread( void *buf, size_t elem_Siz, size_t count, FILE *stream );

void    *mt_memcpy( void *dest, const void *src, size_t len );

char    *mt_strcat( char *s1, const char *s2 );
char    *mt_strncat( char *s1, const char *s2, size_t n );
char    *mt_strcpy( char *s1, const char *s2 );
char    *mt_strncpy( char *s1, const char *s2, size_t n );

void	mt_set();
void	mt_clr();