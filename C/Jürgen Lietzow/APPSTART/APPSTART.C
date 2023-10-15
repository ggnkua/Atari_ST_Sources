/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 5/93  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	Batch-Programme								*/
/*							hier: einfacher Packer-Batch				*/
/*																		*/
/*		M O D U L E		:	APPSTART.C									*/
/*																		*/
/*																		*/
/*		Author			:	JÅrgen Lietzow fÅr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 4.01, Pure C				*/
/*																		*/
/*		Last Update		:	22.03.93 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

# include <string.h>
# include <stdio.h>
# include <stdlib.h>
# include <ctype.h>
# include <tos.h>
# include <aes.h>

#define F_SEP	'\\'
#define F_SPEC	"*.*"

#ifndef FA_ATTRIB
 #define		FA_ATTRIB		(FA_DIREC|FA_SYSTEM|FA_RDONLY|FA_HIDDEN)
#endif

#ifndef EOS
 #define EOS		'\0'
#endif

#ifdef __TOS__

	#include <ext.h>
	#include <tos.h>

	#define		mkdir(p)		(Dcreate(p) < 0)
	#define		rmdir(p)		(Ddelete(p))
	#define		getdta()		(Fgetdta())
	#define		setdta(d)		(Fsetdta(d))
	#define		_chmode(p,f,a)	(Fattrib(p,f,a))
	#define		setftime(h,t)	(Fdatime((DOSTIME *)t,h,1))
	#define		getftime(h,t)	(Fdatime((DOSTIME *)t,h,0))

#endif

static	char	my_name[128];
static	char	top_path[128];

static	char	mag[8] = "_ Com__";
static	char	cmd[128] = "D:\\COMMANDS\\LZH.TTP";
static	char	arg[256] = "a -rm";

/*
*	NormPath()
*
*	erzeugt aus einem relativen Pfad (z.B.: "bin\prg") einen kompletten
*	Pfad, abgeschlossen mit '\' (z.B.: "C:\WRKS\BIN\PRG\")
*/

void	NormPath( const char *path, char *norm )
{
	if ( path[0] && path[1] == ':' )
	{
		*norm++ = toupper (path[0]);
		path += 2;
	}
	else
		*norm++ = getdisk() + 'A';

	*norm++ = ':';
	*norm++ = F_SEP;
	
	if ( *path != F_SEP )
	{
		getcurdir( norm[-3] - ( 'A' - 1 ), norm );
		while ( *norm )
			norm++;
		*norm++ = F_SEP;
	}
	strcpy( norm, path );
	while ( *norm )
		norm++;
	if ( norm[-1] != F_SEP )
	{
		*norm++ = F_SEP;
		*norm++ = '\0';
	}
}

/*
*	LastDir()
*
*	Liefert einen Zeiger auf den letzten Datei-Separator ('\') oder ':',
*	auf den noch ein Pfad- oder Dateiname folgt.
*
*/

char	*LastDir( char *path )
{
	char	*ptr = path;
	char	c;
	
	while ( ( c = *ptr++ ) != 0 )
	{
		if ( c == F_SEP && *ptr )
			path = ptr;
		if ( c == ':' && *ptr != F_SEP && *ptr )
			path = ptr;
	}
	return ( path );
}

/*
*	FixPath()
*
*	fÅgt an einen Pfad gegebenenfalls ein Datei-Separtor ('\') an,
*	um dann nur noch einen Dateinamen anhÑngen zu mÅssen.
*	'a:'      -> 'a:'
*	''        -> ''
*	'xxx'     -> 'xxx\'
*	'AUX:'    -> 'AUX:'
*	liefert 0, im Falle von Pfad == 'AUX:' or 'CON:', ...
*/

int	FixPath( char *path )
{
	char	*p;
	
	p = strrchr( path, F_SEP );
	if ( !p )
	{
		if ( path[0] == EOS )
			return ( -1 );
		p = path + strlen( path );
		if ( p[-1] == ':' )
		{
			if ( path[1] == ':' )
				return ( -1 );
			else
				return ( 0 );
		}
		*p++ = F_SEP;
		*p++ = EOS;
	}
	else
	{
		if ( p[1] != EOS )
		{
			while ( *p++ );
			p[-1] = F_SEP;
			p[0] = EOS;
		}
	}
	return ( -1 );
}


/*
*	AppendPath()
*
*	hÑngt an einen Pfad, einen Dateinamen (type != 0) oder einen weiteren
*	Pfad (type == 0) an.
*/

void	AppendPath( char *path, char *dir, int type )
{
	if ( *dir == F_SEP )
		dir++;
	
	if ( !FixPath( path ) )
		return;
	strcat( path, dir );	
	
	if ( !type )
		FixPath( path );
}

/*
*	PathExists()
*
*	liefert 0 wenn <path> nicht existiert
*/

int		PathExists( const char *path )
{
	struct ffblk	fb;
	char			p[128];
	
	strcpy( p, path );
	AppendPath( p, F_SPEC, 1 );
	
	if ( !findfirst( p, &fb, FA_ATTRIB ) )
		return ( -1 );
	else
		return ( 0 );
}

/*
*	FileExists()
*
*	liefert 0 wenn <fname> nicht existiert
*	'CON:', 'AUX:', ... existiert immer
*/

int		FileExists( const char *fname )
{
	struct ffblk	fb;
	char			*p;
	
	p = strrchr( fname, F_SEP );
	if ( p )
	{
		if ( p[1] == EOS )
			return ( 0 );
	}
	else
	{
		p = strrchr( fname, ':' );
		if ( p && p[1] == EOS )
		{
			if ( p == fname + 1 )
				return ( 0 );
			else
				return ( 1 );
		}
	}
	return ( !findfirst( fname, &fb, FA_ATTRIB ^ FA_DIREC ) );
}

/*
*	IsFName()
*
*	liefert 0, wenn <fname> kein Dateiname ist
*/

int		IsFName( char *fname )
{
	char	*p;

	p = fname + strlen( fname );
	
	if ( p[-1] == F_SEP || ( p[-1] == ':' && p == fname + 2 ) )
		return ( 0 );
	return ( 1 );
}

/*
*	IsPName()
*
*	liefert 0, wenn <pname> kein Pfadname ist
*/

int		IsPName( char *pname )
{
	char	*p;

	p = pname + strlen( pname );
	
	if ( p[-1] == F_SEP || ( p[-1] == ':' && p == pname + 2 ) )
		return ( 1 );
	return ( 0 );
}
	
/*
*	DirType()
*
*	liefert 1 wenn <dir> ein existierender Pfad ist, und 2 wenn <dir> eine
*	existerende Datei ist.
*	3 bedeutet, daû <dir> als Datei und Pfad existiert.
*/

int		DirType( char *dir )
{
	struct	ffblk	fb;
	char			*p;
	int				mode = 0;
	
	p = dir + strlen( dir );
	if ( p[-1] == F_SEP || p[-1] == ':' )
		return ( 1 );
	if ( !findfirst( dir, &fb, FA_ATTRIB ) )
	{
		do
		{
			if ( fb.ff_attrib & FA_DIREC )
				mode |= 1;
			else
				mode |= 2;
		} while ( !findnext( &fb ) );
	}
	return ( mode );
}
char	*GetDesktopWin( void )
{
	static	char	path[128];
	
	char	*p;
	char	*buf;
	char	*ptr;
	
	path[0] = '\0';
	
	if ( ( buf = malloc( 8196L + 2L ) ) == NULL )
		return ( path );

	shel_get( buf, 8196 );
	buf[8196] = 10;
	buf[8196+1] = ~'#';
	ptr = buf;
	p = NULL;
	
	while ( *ptr++ == '#' )
	{
		if ( *ptr == 'W' )
		{
			while ( *ptr++ != '@' );
			if ( ptr[-2] != ' ' )
			{
				while ( *--ptr != ' ' );
				p = ptr + 1;
			}
		}
		while ( *ptr++ != 10 );
	}
	
	if ( p )
	{
		ptr = path;
		while ( ( *ptr++ = *p++ ) != '@' );
		ptr[-1] = '\0';
		strrchr( path, '\\' )[1] = '\0';
	}
	free( buf );
	return ( path );
}

/*
*	MyName()
*
*	liefert Pfad und Dateiname des Programmes, wenn ermittelbar
*/

char	*MyName( void )
{
	static	char	fname[128];
			char	tmp[128];
	
	shel_read( fname, tmp );
	
	return ( fname );
}

/*
*	AppendCommand()
*
*	FÅgt ein weiteres Argument an eine Kommandozeile.
*	Erstes Zeichen enthÑlt die LÑnge. Trennzeichen (' ') werden automatisch
*	eingefÅgt.
*/

int		AppendCommand( char *cmd, char *arg )
{
	char	*p = cmd + 1;
	int		len = cmd[0];
	
	p += len;
	
	if ( len >= 127 )
		return ( 1 );
		
	if ( len != 0 )
	{
		if ( p[-1] != ' ' )
		{
			*p++ = ' ';
			len++;
		}
	}
	while ( *arg == ' ' )
		arg++;

	if ( ( len += (int) strlen( arg ) ) >= 127 )
		return ( 1 );
	strcpy( p, arg );
	cmd[0] = (char) len;
	
	return ( 0 );
}

/*
*	execute()
*
*	fÅhrt <command> mit <argument> aus.
*/

int	execute( char *command, void *argument )
{
	return (int) Pexec( 0, command, argument, NULL );
}


static	void	doInstall( void )
{
	char	temp[256];
	FILE	*fp;
	int		c;
	
	
	printf( "\nPack directory                         by J. Lietzow\n\n" );
	printf( "Current settings:\n"
			"    Packer:  '%s'\n"
			"    Command: '%s [packer_file path\\*.*]'\n\n", cmd, arg);
	
	while ( 1 )
	{
		if ( !my_name[0] )
		{
			printf( "Full file name of this Programm ?" );
			scanf( "%[^ \n\r]", temp );
			if ( temp[0] == 0 )
				return;
		}
		else
			strcpy( temp, my_name );
		if ( ( fp = fopen( temp, "r+b" ) ) == 0 )
		{
			printf ( "File not found: '%s'\n"
					 "(N)ew, (Q)uit ?\n", temp );
			my_name[0] = '\0';
			if ( toupper( getch() ) == 'Q' )
				return;
			else
				continue;
		}
		while ( ( c = fgetc( fp ) ) != EOF )
			if (	  c == '_' &&
					( c = fgetc( fp ) ) == ' ' && 
					( c = fgetc( fp ) ) == 'C' && 
					( c = fgetc( fp ) ) == 'o' && 
					( c = fgetc( fp ) ) == 'm' && 
					( c = fgetc( fp ) ) == '_' && 
					( c = fgetc( fp ) ) == '_' &&
					( c = fgetc( fp ) ) == 0 )
				break;
		if ( c == EOF )
		{
			fclose ( fp );
			printf ( "This is not our programm: '%s'\n"
					 "(N)ew, (Q)uit ?\n", temp );
			my_name[0] = '\0';
			if ( toupper( getch() ) == 'Q' )
				return;
			else
				continue;
		}
		fflush( fp );
		printf( "\nNew packer name ?" );
		fflush( stdin );
		scanf( "%[^ \n\r]", cmd );
		fwrite( cmd, 1L, sizeof( cmd ), fp );
		printf( "\nCommand ?" );
		fflush( stdin );
		scanf( "%[^\n\r]", arg );
		fwrite( arg, 1L, sizeof( arg ), fp );
		fclose ( fp );
		break;
	}
	printf( "New settings:\n"
			"    Packer:  '%s'\n"
			"    Command: '%s [packer_file path\\*.*]'\n", cmd, arg);
	printf( "Installed!\n"
			"Press <Return>\n" );
	getch();
}	

void	Init( void )
{
	strcpy( my_name, MyName() );
	strcpy( top_path, GetDesktopWin() );
	if ( top_path[0] == '\0' )
		NormPath( "", top_path );
}

int		main( int argc, char *argv[] )
{
	char	temp[128];
	char	argument[128];
	char	*ptr, *p;
	int		ret;

	Init();

	ret = mag[7];		/* wichtig, um <mag> ins DATA-Segment aufzunehmen */

	if ( argc < 2 )
	{
		doInstall();
		return ( 0 );
	}
	if ( argc != 2 )
	{
		printf( "\nIllegal argument number!\nPress <Return>" );
		getch();
		return ( -1 );
	}
	strcpy( temp, argv[1] );
	if ( !PathExists( temp ) )
	{
		printf( "\nPath: '%s' does not exist!\nPress <Return>", temp );
		getch();
		return ( -1 );
	}
	argument[0] = '\0';
	AppendCommand( argument, arg );
	ptr = strrchr( temp, '\\' );
	if ( ptr && !ptr[1] )
		ptr[0] = '\0';
	ptr = strrchr( temp, '\\' );
	if ( !ptr )
		ptr = temp;
	else
		ptr++;
	if ( ( p = strrchr( ptr, '.' ) ) != NULL )
		*p = '\0';
	AppendCommand( argument, ptr );
	if ( p )
		*p = '.';
	strcat( temp, "\\*.*" );
	AppendCommand( argument, temp );
	
	ret = execute( cmd, argument );
	return ( ret );
}	
	