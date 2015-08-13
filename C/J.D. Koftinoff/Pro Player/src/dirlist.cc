/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include "perform.h"
#pragma hdrstop

#include <dirlist.hh>

#ifdef _IBM_PC
#include <dir.h>
#endif


void JKPathSeparate1(
		char *fullpath,
		char *drive,
		char *dir,
		char *file
		)
{
	register char *p=fullpath;
	
	if( drive )
	{
		if( fullpath[1]==':' )
		{
			*drive++=*p++;
			*drive++=*p++;

		}
		*drive++='\0';          
	}
	else
	{
		if( fullpath[1]==':' )
		{
			p+=2;
		}
	}
	
	if( dir )
	{
		register unsigned short last_dir=0;
		
		strcpy( dir, p );
		for( register unsigned short i=0; i<96; i++ )
		{
			if( dir[i]=='\0' )
				break;
			if( dir[i]=='\\' )
				last_dir=i;
		}
		if( last_dir )
		{
			dir[last_dir]=0;
			p+=last_dir+1;
		}

	}
	
	if( file )
	{
		strcpy( file, p );
	}
}



DirList::DirList( int s ) : List( 96, s )
{


}

int	DirList::MultiSearch(
		char **tmplate_table, 
		int file_type=0 
		) 
{
	int number=0;

	do
	{
		number+=Search( *tmplate_table, file_type );
	} while( ++*tmplate_table );
	return number;
}


#ifdef atarist

int DirList::Search( char *tmplate, int file_type )
{
	tos_dta info, *old;
	char full_name[128];
	char prefix[128];

#if 0
	{
		char _drive[8];
		char _dir[128];
		char _file[16];

		JKPathSeparate1( tmplate, _drive, _dir, _file );
		strcpy( prefix, _drive );
		strcat( prefix, _dir );

		if( *prefix && prefix[strlen(prefix)-1]!='\\' )
			strcat( prefix, "\\" ); 
	}
#endif

	//printf( "\nDirList::Search( %s ) prefix=%s\n", tmplate, prefix );
	//getch();

	old=(tos_dta *)Fgetdta();
	Fsetdta( &info );

	// force a mediachange

	char drv=-1;
	if( tmplate[1]==':' )
		drv=toupper( tmplate[0] )-'A';
	else
		drv=Dgetdrv();
	if( drv==0 || drv==1 )
		Rwabs( 0, NULL,1,1,drv );

	

	if( Fsfirst( tmplate, file_type )>=0 )
		do
		{
			strcpy( full_name, (char *)info.dta_name );
			//strcat( full_name, (char *)info.dta_name );
			AddElement( (void *)full_name );	
 		} while( Fsnext()>=0 );

	Fsetdta( old );
	return number;
}


#else


int DirList::Search( char *tmplate, int file_type )
{
	struct ffblk f;
	int done;


	done= findfirst( tmplate, &f, file_type );

	if( !done )
		do
		{
			AddElement( (void *)f.ff_name );
		} while( findnext( &f) );


	return number;
}


#endif



void DirList::Sort()
{
	qsort( (void *)data, number, sizeofeach, (void *)strcmp );
}


