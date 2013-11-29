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

#include <types2b.h>
#include	<string.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<mgx_dos.h>

/*----------------------------------------------------------------------------------------*/
/* local includes																									*/
/*----------------------------------------------------------------------------------------*/

#include "file.h"
#include	"path.h"

/*----------------------------------------------------------------------------------------*/
/* search for environment path																				*/
/* Return: TRUE if found, else FALSE														 				*/
/*----------------------------------------------------------------------------------------*/
boolean	get_envpath( uint8 *envpath, uint8 *envname )
{
	uint8 *p, *env;

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
				p[0] = EOS;
			p = strchr( envpath, ',' );
			if( p != NULL )
				p[0] = EOS;
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
/* search for configuration file (filename) -> cnf_path												*/
/* return: -																						 				*/
/*----------------------------------------------------------------------------------------*/
boolean	home_search( uint8 *filename, uint8 *configpath )
{
	uint8	homepath[256];
	extern  uint8	gl_appdir[];

	sprintf( configpath, "%s%s", gl_appdir, filename );

	if( get_envpath( homepath, "HOME" ) )
	{
		sprintf( configpath, "%sdefaults\\%s", homepath, filename );

		if( !file_exist( configpath ) )
			sprintf( configpath, "%s%s", homepath, filename );

		if( !file_exist( configpath ) )
			sprintf( configpath, "%s%s", gl_appdir, filename );
	}

	if( !file_exist( configpath ) )
		return FALSE;
	else
		return TRUE;
}