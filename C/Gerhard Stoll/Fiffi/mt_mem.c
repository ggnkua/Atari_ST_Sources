#include <STDLIB.H>
#include <STDIO.H>
#include	<STRING.H>
#include	<TOS.H>

#ifdef	xMEMDEBUG
#define	MEMDEBUG
#include	<MEMDEBUG.H>
static volatile int	debug = 0;
#define	strdup(a)	strcpy( malloc( strlen( a ) + 1 ), a )
#endif

static volatile int	mt_flag = 0;

static void	mt_set( void );
static void	mt_clr( void );

static void	mt_set( void )
{
	while( mt_flag )
		Syield();
	mt_flag = 1;
}
static void	mt_clr( void )
{
	mt_flag = 0;
}

void	*mt_malloc( size_t size )
{
	void	*ret;
#ifdef	xMEMDEBUG
	if( !debug )
	{
#ifdef	IRC_CLIENT
		set_MemdebugOptions( c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, 0L, 0L, "C:\\var\\log\\Chatter-Debug\\statistics", "C:\\var\\log\\Chatter-Debug\\error" );
#endif
#ifdef	TELNET_CLIENT
		set_MemdebugOptions( c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, 0L, 0L, "C:\\var\\log\\Teli-Debug\\statistics", "C:\\var\\log\\Teli-Debug\\error" );
#endif
		debug = 1;
	}
#endif
	mt_set();
	ret = malloc( size );
	mt_clr();
	return( ret );
}
void  *mt_calloc( size_t nitems, size_t size )
{
	void	*ret;
	mt_set();
	ret = calloc( nitems, size );
	mt_clr();
	return( ret );
}
void	*mt_realloc( void *block, size_t newsize )
{
	void	*ret;
	mt_set();
	ret = realloc( block, newsize );
	mt_clr();
	return( ret );
}
char  *mt_strdup( const char *s )
{
	char	*ret;
	mt_set();
	ret = strdup( s );
	mt_clr();
	return( ret );
}
void	mt_free( void *ptr )
{
	mt_set();
	free( ptr );
	mt_clr();
}

int	mt_fclose( FILE *stream )
{
	int	ret;
	mt_set();
	ret = fclose( stream );
	mt_clr();
	return( ret );
}
char	*mt_fgets( char *str, int n, FILE *stream )
{
	char	*ret;
	mt_set();
	ret = fgets( str, n, stream );
	mt_clr();
	return( ret );
}
FILE	*mt_fopen( const char *filename, const char *mode )
{
	FILE	*ret;
	mt_set();
	ret = fopen( filename, mode );
	mt_clr();
	return( ret );
}
int	mt_fprintf( FILE *stream, const char *format, ... )
{
	int	ret;
	mt_set();
	{
		va_list	ap;
		va_start( ap, format );
		ret = vfprintf( stream, format, ap );
		va_end( ap );
	}
	mt_clr();
	return( ret );
}
int	mt_fscanf( FILE *stream, const char *format, ... )
{
	int	ret;
	mt_set();
	{
		va_list	ap;
		va_start( ap, format );
		ret = vfscanf( stream, format, ap );
		va_end( ap );
	}
	mt_clr();
	return( ret );
}

size_t  mt_fread( void *buf, size_t elem_Siz, size_t count, FILE *stream )
{
	size_t	ret;
	mt_set();
	ret = fread( buf, elem_Siz, count, stream );
	mt_clr();
	return( ret );
}

void    *mt_memcpy( void *dest, const void *src, size_t len )
{
	void	*ret;
	mt_set();
	ret = memcpy( dest, src, len );
	mt_clr();
	return( ret );
}

char    *mt_strcat( char *s1, const char *s2 )
{
	char	*ret;
	mt_set();
	ret = strcat( s1, s2 );
	mt_clr();
	return( ret );
}
char    *mt_strncat( char *s1, const char *s2, size_t n )
{
	char	*ret;
	mt_set();
	ret = strncat( s1, s2, n );
	mt_clr();
	return( ret );
}
char    *mt_strcpy( char *s1, const char *s2 )
{
	char	*ret;
	mt_set();
	ret = strcpy( s1, s2 );
	mt_clr();
	return( ret );
}
char    *mt_strncpy( char *s1, const char *s2, size_t n )
{
	char	*ret;
	mt_set();
	ret = strncpy( s1, s2, n );
	mt_clr();
	return( ret );
}
