#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include <STDDEF.H>
#include <STDLIB.H>
#include	<STDIO.H>
#include	<STRING.H>

#include <atarierr.h>

#include	"Recursiv.h"

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static void	GetnEntry( BYTE *Entry, WORD *nDir, WORD *nFile );
static void	GetEntry( BYTE *Entry, BYTE ***Filename, BYTE ***Path, BYTE ***Dir, WORD *nBasename );
static BYTE *ConvertPath( BYTE *Entry, WORD Basename );

#ifdef	RECURSIV
void	GetRecursiv( BYTE *Arg, WORD nArg, BYTE ***Filename, BYTE ***Path, BYTE ***Dir )
{
	WORD	n = nArg, nFile = 0, nDir = 0, nBasename;
	BYTE	*c = Arg, Entry[512];
	BYTE	**tFilename, **tPath, **tDir;
	while( n )
	{
		strcpy( Entry, c );
		if( Entry[ strlen( Entry ) - 1 ] == '\\' )
			Entry[ strlen( Entry ) - 1 ] = 0;

		GetnEntry( Entry, &nDir, &nFile );
	
		c += strlen( c ) + 1;
		n--;
	}
	if( nDir == 0 && nFile == 0 )
	{
		*Filename = NULL;
		*Path = NULL;
		*Dir = NULL;
		return;
	}
	*Filename = malloc(( nFile + 1 ) * sizeof( BYTE * ));
	if( *Filename == NULL )
	{
		*Filename = NULL;
		*Path = NULL;
		*Dir = NULL;
		return;
	}
	*Path = malloc(( nFile + 1 ) * sizeof( BYTE * ));
	if( *Path == NULL )
	{
		free( *Filename );
		*Filename = NULL;
		*Path = NULL;
		*Dir = NULL;
		return;
	}
	*Dir = malloc(( nDir + 1 ) * sizeof( BYTE * ));
	if( *Dir == NULL )
	{
		free( *Filename );
		*Filename = NULL;
		free( *Path );
		*Path = NULL;
		*Dir = NULL;
	}
	tFilename = *Filename;
	tPath = *Path;
	tDir = *Dir;

	c = Arg;
	n = nArg;
	while( n )
	{
		strcpy( Entry, c );
		if( Entry[ strlen( Entry ) - 1 ] == '\\' )
			Entry[ strlen( Entry ) - 1 ] = 0;
		nBasename = 0;
		GetEntry( Entry, &tFilename, &tPath, &tDir, &nBasename );
		c += strlen( c ) + 1;
		n--;
	}
	*tFilename = NULL;
	*tPath = NULL;
	*tDir = NULL;
}

static void	GetnEntry( BYTE *Entry, WORD *nDir, WORD *nFile )
{
	XATTR	Xattr;

	Fxattr( 0, Entry, &Xattr );
	if( Xattr.attr & FA_SUBDIR )
	{
		BYTE	*NewEntry, *NewPath;
		LONG	DirHandle;

		if(( NewEntry = malloc( 512 )) == NULL )
			return;
		if(( NewPath = malloc( 512 )) == NULL )
		{
			free( NewEntry );
			return;
		}
		DirHandle = Dopendir( Entry, 0 );
		while( Dreaddir( 512, DirHandle, NewEntry ) == E_OK )
		{
/* [GS] 1.50a Start */
			if ( strcmp ( &( NewEntry[4] ), "." ) != 0 && strcmp ( &( NewEntry[4] ), ".." ) != 0 )
			{
/* Ende */
				strcpy( NewPath, Entry );
				strcat( NewPath, "\\" );
				strcat( NewPath, &( NewEntry[4] ));
				GetnEntry( NewPath, nDir, nFile );
			}
		}
		Dclosedir( DirHandle );
		free( NewEntry );
		free( NewPath );

		( *nDir )++;
	}
	else
		( *nFile )++;
}

static void	GetEntry( BYTE *Entry, BYTE ***Filename, BYTE ***Path, BYTE ***Dir, WORD *nBasename )
{
	XATTR	Xattr;
	if( *nBasename == 0 )
		*nBasename = strrchr( Entry, '\\' ) - Entry + 1;
	Fxattr( 0, Entry, &Xattr );
	if( Xattr.attr & FA_SUBDIR )
	{
		BYTE	*NewEntry, *NewPath;
		LONG	DirHandle;
		if(( NewEntry = malloc( 512 )) == NULL )
			return;
		if(( NewPath = malloc( 512 )) == NULL )
		{
			free( NewEntry );
			return;
		}
		**Dir = ConvertPath( Entry, *nBasename );
		( *Dir )++;
		DirHandle = Dopendir( Entry, 0 );
		while( Dreaddir( 512, DirHandle, NewEntry ) == E_OK )
		{
/* [GS] 1.50a Start */
			if ( strcmp ( &( NewEntry[4] ), "." ) != 0 && strcmp ( &( NewEntry[4] ), ".." ) != 0 )
			{
/* Ende */
				strcpy( NewPath, Entry );
				strcat( NewPath, "\\" );
				strcat( NewPath, &( NewEntry[4] ));
				GetEntry( NewPath, &( *Filename ),  &( *Path ),  &( *Dir ), nBasename );
			}
		}
		Dclosedir( DirHandle );
		free( NewEntry );
		free( NewPath );
	}
	else
	{
		**Filename = ConvertPath( Entry, *nBasename );
		( *Filename )++;
		**Path = strdup( Entry );
		( *Path )++;
	}
}

static BYTE *ConvertPath( BYTE *Entry, WORD Basename )
{
	BYTE	*Ret = strdup( &( Entry[Basename] ));
	if( Ret )
	{
		BYTE	*Tmp = Ret;
		while( *Tmp )
		{
			if( *Tmp == '\\' )
				*Tmp = '/';
			Tmp++;
		}
	}
	return( Ret );
}
#endif