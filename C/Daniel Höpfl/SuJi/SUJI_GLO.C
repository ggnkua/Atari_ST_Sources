#include "SuJi_glo.h"

int ap_id;
GlobalArray global;

struct CONFIG config;

int show_row[6]={1,1,1,1,1,1};
int max_breite[6]={0};

struct SUCHINFORMATIONEN suji;

char *bubble_string=NULL;

char *prog_name;

/* Standardvariablen */
char *alert;
int i,dummy;

int searching=FALSE;

char help_str_liste[]="*:\\SuJi.hyp Die Liste";
char help_str_dialog[]="*:\\SuJi.hyp Der Maskendialog";

int there_is_check_and_set;

/* Variablen fÅr die USERDEFs in der Listbox */
USERBLK ud_ENTRY1;
USERBLK ud_ENTRY2;
USERBLK ud_ENTRY3;
USERBLK ud_ENTRY4;

/*----------------------------------------------------------------------------------------*/
void catbslash( char *string )
{
	if( string[strlen(string)-1] != '\\' )
		strcat( string, "\\" );
}

/*----------------------------------------------------------------------------------------*/
void delbslash( char *string )
{
	if( string[strlen(string)-1] == '\\' )
		string[strlen(string)-1] = '\0';
}

/*----------------------------------------------------------------------------------------*/

int	path_exist( const char *pathvar )
{
	char		pathname[256];
	char		link[256];
	XATTR		xattr;
	long		err;

	strncpy( pathname, pathvar, 256 );

	if( pathname[0] == '\0' )
		return FALSE;

	delbslash( pathname );
	
	if( strlen(pathname) == 2 )						/* Wurzelverzeichnis */
	{
		if( Dgetpath(pathname, pathvar[0]-64) == 0)
		{
			return TRUE;
		}
		else
			return FALSE;
	}

	err = Fxattr( 0, pathname, &xattr );

	if(err == EINVFN)
	{
		DTA	dta;

		Fsetdta( &dta );
		err = Fsfirst( pathname, FA_SUBDIR );
		if( err == 0 )
		{
			return TRUE;
		}
	}
	else if( err == 0 )
	{
		if( Freadlink ( 255, link, pathname ) == 0 )
			strcpy( pathname, link );

		if((xattr.mode & S_IFMT) == S_IFDIR)
		{
			return TRUE;
		}
	}

	return FALSE;
}

/*----------------------------------------------------------------------------------------*/

int file_exist( const char *filename )
{
	XATTR		xattr;
	long		err;

	if( filename[0] == '\0' || filename == NULL )
		return FALSE;

	err = Fxattr( 0, (char*)filename, &xattr );

	if(err == EINVFN)
	{
		DTA	dta;
		
		Fsetdta( &dta );
		err = Fsfirst( filename, FA_ATTRIB );
		if( err == 0 )
			return TRUE;
	}
	else if( err == 0 )
	{
		if((xattr.mode & S_IFMT) == S_IFREG)
			return TRUE;
	}

	return FALSE;
}

/*----------------------------------------------------------------------------------------*/

int	get_envpath( char *envpath, char *envname )
{
	char *p, *env;

	env = getenv( envname );

	if( env )
	{	
		p = strstr( env, ":\\" );

		if( p != NULL )
		{
			p--;
			strcpy( envpath, p );
			p = strchr( envpath, ';' );
			if( p != NULL )
				p[0] = '\0';
			p = strchr( envpath, ',' );
			if( p != NULL )
				p[0] = '\0';
		}
	}

	delbslash( envpath);

	if( path_exist( envpath ) )
	{
		catbslash( envpath);
		return TRUE;
	}
	else
		return FALSE;
}

/*----------------------------------------------------------------------------------------*/

int	home_search( char *filename, char *configpath )
{
	char	homepath[256];
	char	appdir[256];

	sprintf( configpath, "%s%s", appdir, filename );

	if( get_envpath( homepath, "HOME" ) )
	{
		sprintf( configpath, "%sdefaults\\%s", homepath, filename );

		if( !file_exist( configpath ) )
			sprintf( configpath, "%s%s", homepath, filename );
/*
		if( !file_exist( configpath ) )
			sprintf( configpath, "%s%s", appdir, filename );
*/
	}

	if( !file_exist( configpath ) )
		return 0;
	else
		return 1;
}