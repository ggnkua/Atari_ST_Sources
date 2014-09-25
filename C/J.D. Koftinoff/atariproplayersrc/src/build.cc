/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 




#include "ply_defs.h"

#include <dirlist.hh>

extern SET set;
extern int top_song;
extern Command cur_command;
#if 0
char *song_tmplates[] =
{
	"SONGS\\*.MID",
	"SONGS1\\*.MID",
	"SONGS2\\*.MID",
	"SONGS3\\*.MID",
	"SONGS4\\*.MID",
	"SONGS5\\*.MID",
	"SONGS6\\*.MID",
	"SONGS7\\*.MID",
	"SONGS8\\*.MID",
	"SONGS9\\*.MID",
	"\\SONGS\\*.MID",
	"\\SONGS1\\*.MID",
	"\\SONGS2\\*.MID",
	"\\SONGS3\\*.MID",
	"\\SONGS4\\*.MID",
	"\\SONGS5\\*.MID",
	"\\SONGS6\\*.MID",
	"\\SONGS7\\*.MID",
	"\\SONGS8\\*.MID",
	"\\SONGS9\\*.MID",
	0
};
#endif


char *text_tmplates[] =
{
	"SONGS\\*.TXT",
	"SONGS1\\*.TXT",
	"SONGS2\\*.TXT",
	"SONGS3\\*.TXT",
	"SONGS4\\*.TXT",
	"SONGS5\\*.TXT",
	"SONGS6\\*.TXT",
	"SONGS7\\*.TXT",
	"SONGS8\\*.TXT",
	"SONGS9\\*.TXT",
	"\\SONGS\\*.TXT",
	"\\SONGS1\\*.TXT",
	"\\SONGS2\\*.TXT",
	"\\SONGS3\\*.TXT",
	"\\SONGS4\\*.TXT",
	"\\SONGS5\\*.TXT",
	"\\SONGS6\\*.TXT",
	"\\SONGS7\\*.TXT",
	"\\SONGS8\\*.TXT",
	"\\SONGS9\\*.TXT",
	0
};


void build_set()
{
unsigned int i;
DirList dir(1000);

	top_song=0;
	put_stat( "CREATING SET", "CREATING" );

	dir.Clear();

	//if( dir.MultiSearch( song_tmplates )==0 )
	if( dir.Search( "SONGS\\*.MID" )==0 )
		if( dir.Search( "\\SONGS\\*.MID")==0 )
			dir.Search( "*.MID" );
	
	set.num_songs=dir.GetNumberFiles();

	if( set.num_songs==0 ) 
	{
		put_stat( "NO SONGS", "NO SONGS" );
#if 0
		do 
		{
			get_action();
		} while( cur_command.type==ComNone );
#endif
		return;
	}

	dir.Sort();

	if( set.num_songs>NUM_SONGS )
		set.num_songs=NUM_SONGS;

	for( i=0; i<set.num_songs; i++ ) 
	{ 
		strncpy( set.list[i], dir.GetFileName(i), 95 );
		*rindex( set.list[i], '.' )='\0';
	}	
}


void build_text_set()
{
unsigned int i;
DirList dir(1000);

	top_song=0;
	put_stat( "CREATING TEXT SET", "CREATING" );


	//if( dir.MultiSearch( text_tmplates )==0 )
	if( dir.Search( "SONGS\\*.TXT" )==0 )
		if( dir.Search( "\\SONGS\\.TXT")==0 )
			dir.Search( "*.TXT" );
	
	set.num_songs=dir.GetNumberFiles();

	if( set.num_songs==0 ) 
	{
		put_stat( "NO SONGS", "NO SONGS" );
		do 
		{
			get_action();
		} while( cur_command.type==ComNone );
		return;
	}

	dir.Sort();

	if( set.num_songs>NUM_SONGS )
		set.num_songs=NUM_SONGS;

	for( i=0; i<set.num_songs; i++ ) 
	{
		strncpy( set.list[i], dir.GetFileName(i), 95 );
		*rindex( set.list[i], '.' )='\0';
	}	
}

