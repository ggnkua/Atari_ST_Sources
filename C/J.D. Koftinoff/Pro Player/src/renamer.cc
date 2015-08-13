/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include <sglib.h>
#include <dirlist.hh>
#include <jkpath.h>

void renamer( int mode )
{
	static char *tmplate[] = { "\\SONGS\\*.SNG", "\\SONGS\\*.MID" };
	static char *new_suffix[]  = { ".MID", ".SNG" };
	DirList d;
	char old_path[64], new_path[64];
	
	d.Search( tmplate[mode] );

	for( int i=0; i<d.GetNumberFiles(); i++ )
	{
		strcpy( old_path, "\\SONGS\\" );
		strcat( old_path, d.GetFileName(i) );
		JKPathAppendExtension( new_path, old_path, new_suffix[mode] );
		Frename( 0, old_path, new_path );
	}
}

void main()
{
	int sel;
	
	appl_init();
	
	
	while( TRUE )
	{
		sel=form_alert( 1, 
	"[1][*.MID & *.SNG RENAMER]"
	"[ QUIT | SNG->MID | MID->SNG ]" );
		
		if( sel==1 )
			break;
		if( sel==2 )
			renamer( 0 );
		if( sel==3 )
			renamer( 1 );
	}
	
	
	appl_exit();	
	exit(0);
}


