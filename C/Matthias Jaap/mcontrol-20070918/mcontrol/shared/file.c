/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* global includes																								*/
/*----------------------------------------------------------------------------------------*/

#include	<mgx_dos.h>
#include <types2b.h>
#include	<string.h>
#include <stdio.h>
#include	<ctype.h>
#include	<cflib.h>

#include	"strcmd.h"

/*----------------------------------------------------------------------------------------*/
/* local includes																									*/
/*----------------------------------------------------------------------------------------*/

#include	"core.h"
#include	"file.h"

#define	FA_ATTRIB	(FA_READONLY|FA_HIDDEN|FA_SYSTEM)


/*----------------------------------------------------------------------------------------*/
/* Berechnet die Grîsse einer Datei																			*/
/*----------------------------------------------------------------------------------------*/
uint32	file_size(const uint8 *filename)
{
	XATTR		xattr;
	int32		err;

	if( filename[0] == EOS )
		return 0;

	err = Fxattr( 0, (char*)filename, &xattr );

	if(err == EINVFN)
	{
		DTA	dta;
	
		Fsetdta( &dta );
		err = Fsfirst( filename, FA_ATTRIB );
		if( err == 0 )
		{
			Fgetdta();
			return dta.d_length;
		}
	}
	else if( err == 0 )
	{
		if((xattr.mode & S_IFMT) == S_IFREG)
			return (uint32)xattr.size;
	}

	return 0;
}


/*----------------------------------------------------------------------------------------*/
/* Gibt das Erstelldatum einer Datei zurÅck																*/
/* Funktionsergebnis: Erstelldatum als uint32															*/
/*----------------------------------------------------------------------------------------*/
uint32	file_date( const uint8 *path )
{
	XATTR		xattr;
	uint32	fdate;
	int32		ret;

	ret = Fxattr( FXATTR_RESOLVE, (char*)path, &xattr );

	if( ret == 0 )
	{
		fdate = ((uint32)xattr.cdate << 16) + (UWORD)xattr.ctime;
		return fdate;
	}
	else if( ret == EINVFN )
	{
		DTA	dta;
		
		Fsetdta( &dta );
		if( Fsfirst( path, FA_ARCHIVE|FA_HIDDEN|FA_READONLY ) == 0)
		{
			fdate = ((uint32)dta.d_date << 16) + (UWORD)dta.d_time;
			return fdate;
		}
	}
	return 0;
}


/*----------------------------------------------------------------------------------------*/
/* PrÅft, ob eine Datei existiert											 								*/
/* Funktionsresultat: TRUE wenn ja, FALSE sonst							 								*/
/*----------------------------------------------------------------------------------------*/
boolean	file_exist( const uint8 *filename )
{
	XATTR		xattr;
	int32		err;

	if( filename[0] == EOS || filename == NULL )
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
/* Testet, ob eine Dateiname ausfÅhrbar ist (PRG/APP)													*/
/* Funktionsergebnis: TRUE wenn ja, FALSE sonst															*/
/*----------------------------------------------------------------------------------------*/
boolean	file_isprog( const uint8 *fname )
{
	uint8	*p;

	if( !fname )
		return FALSE;

	p = strrchr( fname, '.' );

	if( p == NULL )
		return FALSE;

	if( strlen( p ) != 4 )
		return FALSE;

	if( strnicmp( p, ".app", 4 ) == 0 )	return TRUE;
	if( strnicmp( p, ".prg", 4 ) == 0 )	return TRUE;
	if( strnicmp( p, ".acc", 4 ) == 0 )	return TRUE;
	if( strnicmp( p, ".gtp", 4 ) == 0 )	return TRUE;
	if( strnicmp( p, ".tos", 4 ) == 0 )	return TRUE;
	if( strnicmp( p, ".ttp", 4 ) == 0 )	return TRUE;
	if( strnicmp( p, ".cpx", 4 ) == 0 )	return TRUE;
	if( strnicmp( p, ".ovl", 4 ) == 0 )	return TRUE;
	if( strnicmp( p, ".slb", 4 ) == 0 )	return TRUE;

	return FALSE;
}


/*----------------------------------------------------------------------------------------*/
/*	Testet, ob ein Pfad auf eine Floppydisk zeigt														*/
/* Funktionsergebnis: TRUE wenn ja, FALSE sonst															*/
/*----------------------------------------------------------------------------------------*/
boolean	file_onfloppy( const uint8 *path )
{
	int16 drv;
	
	drv = toupper( (int16)path[0] );

	if( drv < 'C' )
		return TRUE;
	else
		return FALSE;
}


/*----------------------------------------------------------------------------------------*/
/* Gibt den Dateinamen (Pointer) eines absoluten Pfads zurÅck										*/
/* Funktionsergebnis: Pointer auf den Dateinamen														*/
/*----------------------------------------------------------------------------------------*/
uint8	*file_name_ptr( const uint8 *string )
{
	uint8	*p;

	p = strrchr( string, '\\');

	if( (p != NULL) && (p[1] != EOS) )
	{
		p++;
	}
	else
		p = (StringPtr)string;

	return p;
}

boolean	file_name( const uint8 *string, uint8 **fname )
{
	uint8	*p;

	p = strrchr( string, '\\');

	if( (p != NULL) && (p[1] != EOS) )
	{
		*fname = p+1;
		return TRUE;
	}
	else if( (string != NULL) && (string[0] != EOS) )
	{
		*fname = (uint8 *)string;
		return TRUE;
	}
	else
		return FALSE;
}


/*----------------------------------------------------------------------------------------*/
/*	Loads an ASCII file into a new CFData structure														*/
/* Result: CFDataRef																								*/
/*----------------------------------------------------------------------------------------*/
CFDataRef	FileASCIILoad( StringPtr path )
{
	CFDataRef	dref = NULL;
	uint32 		fsize = file_size( path );
		
	if( fsize > 0 )
	{
		dref = CFDataCreate( (int32) fsize + 1, kCFTypeASCII );
		
		if( dref != NULL )
		{
			int32	fh, fs, rd;
			
			fh = Fopen( path, FO_READ );
			fs = (int32)fsize;
			
			if( fh > 0 )
			{
				int16	handle = (int16) fh;
				
				Fseek( 0l, handle, SEEK_SET );
				rd = Fread( handle, fs, dref->data );
				Fclose( handle );
				
				if( rd == fs )
				{
					dref->data[fs] = EOS;
					tab2space( dref->data );
				}
			}
		}
	}
	return dref;
}


/*----------------------------------------------------------------------------------------*/
/*	Adds a backslash to a path, if the last caracter isn't a backslash							*/
/* Funktionsergebnis: -																							*/
/*----------------------------------------------------------------------------------------*/
void	catbslash( uint8 *string )
{
	if( string[strlen(string)-1] != '\\' )
		strcat( string, "\\" );
}


/*----------------------------------------------------------------------------------------*/
/*	Deletes a backslash from a path, if the last caracter is a backslash							*/
/* Funktionsergebnis: -																							*/
/*----------------------------------------------------------------------------------------*/
void	delbslash( uint8 *string )
{
	if( string[strlen(string)-1] == '\\' )
		string[strlen(string)-1] = EOS;
}


/*----------------------------------------------------------------------------------------*/
/* test, if 'pathname' exists																					*/
/* Funktionsresultat: TRUE if yes, else FALSE							 								*/
/*----------------------------------------------------------------------------------------*/
boolean	path_exist( const uint8 *pathvar )
{
	uint8		pathname[256];
	uint8		link[256];
	XATTR		xattr;
	int32		err;

	strncpy( pathname, pathvar, 256 );

	if( pathname[0] == EOS )
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
/* Schneidet den allfÑlligen Dateinamen eines absoluten Pfades ab									*/
/* Funktionsergebnis: TRUE, falls es sich um einen vollstÑndigen Pfad handelt					*/
/*----------------------------------------------------------------------------------------*/
boolean	path_name( const uint8 *string )
{
	uint8	*p;

	p = strrchr( string, '\\');

	if( p != NULL )
	{
		p[1] = EOS;
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}


/*----------------------------------------------------------------------------------------*/
/*	Converts a filename to a suitable path for the actual filesystem								*/
/*----------------------------------------------------------------------------------------*/
int16 path_browse( const uint8 *filepath, void (*cb)(uint8* path) )
{
	boolean	trunc = FALSE;
	uint8		tpath[MAXLEN_PATH];
	uint8		tfile[MAXLEN_FILE];
	uint8		*p, *q;

	if( !is_filled(filepath) )
		return 0;

	strcpy( tpath, filepath );
	
	if( (tpath[1] == ':') && (tpath[2] == '\\') )
	{
		tpath[3] = '\0';
		p = (StringPtr)filepath + 3;
	}
	
	q = strchr( p, '\\' );

	while( q != NULL )
	{
		strncpy( tfile, p, q-p );
		tfile[q-p] = '\0';
		
 		if( path_exist(tpath) )
 			trunc = !fs_long_name(tpath);
		
		if( trunc )
			cb( tfile );
		
		catbslash( tpath );
		strcat( tpath, tfile );
		
		p = q+1;
		q = strchr( p, '\\' );
	}
	
	if( p != '\0' )
	{
		strcpy( tfile, p );
		if( trunc )	cb( tfile );
		catbslash( tpath );
		strcat( tpath, tfile );
	}
	strcpy( (StringPtr)filepath, tpath );
	return (int16) trunc;
}


/*----------------------------------------------------------------------------------------*/
/* KÅrzt einen Pfad auf die LÑnge [max_lenght] im Stil "C:\...\TEST\FILE.TXT"					*/
/* Funktionsergebnis: 0																							*/
/*----------------------------------------------------------------------------------------*/
int16	path_resize( uint8 *longstring, int16 max_lenght)
{
	uint8	temp[256];
	boolean	fits = FALSE;
	int16	longlen = (int16)strlen(longstring);

	if( longlen > max_lenght )
	{
		if( strncmp(longstring+1, ":\\", 2) )			/* Kein Pfad */
		{
			uint8	*p = longstring + min( longlen-max_lenght+3, longlen );
			strcpy( temp, "..." );
			strcat( temp, p );
		}
		else
		{
			uint8 *p = longstring;							/* Pfad */
			while( p != NULL )
			{
				p++;
				p = strchr( p, '\\' );
				
				if( p != NULL && (longlen + longstring - p) <= (max_lenght-6) )
				{
					fits = TRUE;
					break;
				}
			}
			if( !fits )
				p = longstring + min( longlen-max_lenght+6, longlen );
			strcpy( temp, "X:\\..." );
			strcat( temp, p );
			temp[0] = longstring[0];
		}
		strcpy( longstring, temp );
	}
	return 0;
}
