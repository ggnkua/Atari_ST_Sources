/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include "jkform.hh"
#include "ply_defs.h"
#include "olddisk.h"
#include "personal.h"

extern int	top_song;
extern int	cur_song, rez, cur_thru, playing;
extern int	error_flag;
extern int 	current_set;
extern SET set;
extern SONG song[NUM_SONGS];
extern char *lyrics[NUM_SONGS];
extern SONG excl[NUM_SONGS];
extern int has_text_on;
extern char *full;
extern CFG cfg;
extern int text_set;

#ifdef USER_ID
char *user_id = USER_ID;
#else
char *user_id = "";
#endif

void force_media_change();


static unsigned short i,j;
static char ss[80],tt[80];
static char s[80], t[80];
static char old_path[64], key;

#ifdef SHORT_USER_NAME
static char *short_user_name=SHORT_USER_NAME;
#else
static char *short_user_name="";
#endif

static uchar last_name_pos=0;

static void AbortLoad()
{

	key=getch();
	if( key==0x1B ) 
	{
		set.num_songs=i;
		strcpy( s, "Abort loading" );
		put_stat( s, s );
		wait_for_play();
	}
}


static Boolean IsCopy( ushort num )
{			
	if( cfg.load_single )
		return FALSE;

	for( j=0; j<num; j++ )
		if( !strcmp( set.list[num], set.list[j]) ) 
		{
			song[num]=song[j];
			excl[num]=excl[j];
			if( song[num].type==TSNG1 )
				song[num].type=TTNG1;	/* mark as a copy	*/
			if( song[num].type==TMThd )
				song[num].type=TNThd;	/* mark as a copy	*/
			lyrics[num]=lyrics[j];
			return TRUE;
		}
	return FALSE;
}


static Boolean LoadSongPart( ushort i)
{
	if( text_set )
		return TRUE;

	strcpy( ss, "loading: " );
	strcat( ss, set.list[i] );
	strcpy( tt, "L:" );
	strcat( tt, set.list[i] );
	put_stat(ss, tt );	
		
	if( load_s_param( &song[i], s ) )
		return TRUE;
	force_media_change();
	if( load_s_param( &song[i], s ) )
		return TRUE;
	else
	{
		put_stat( 
		  JKForm32( "SWAP DISK: %s", set.list[i] ),
		  "SWAP DISK" );
		wait_for_play();
		force_media_change();
		return FALSE;
	}
	return FALSE;
}


Boolean LoadSong( ushort i )
{
#if PERSONALIZED
#if 0
	if( short_user_name[0]!=user_id[1] || toupper(short_user_name[1])!=user_id[11]
		|| toupper( short_user_name[2] ) != user_id[13] )
	{
		set.num_songs=short_user_name[0]/64;
	}
#endif
#endif

	(void)Dgetpath( old_path, 0 );
	(void)Dsetpath( "\\SONGS" );

	strcpy( s, "\\SONGS\\" );	
	strcat( s,set.list[i] );
	strcat( s,".MID" );
	if( IsCopy( i ) )
	{
		(void)Dsetpath( old_path );
		return TRUE;
	}
	
	unsigned short lp;
	for( lp=0; lp<3; lp++ )
	{
		error_flag=FALSE;
		if( LoadSongPart(i) )
			break;
	}
	error_flag=TRUE;
				
	if( lp==3 )
	{
		put_stat( "SONG MARKED AS BAD", "BAD SONG" );
		wait_for_play();
		song[i].type=TBAD ;
		strcpy( song[i].full_name, set.list[i] );
		(void)Dsetpath( old_path );
		return FALSE;		
	}
		
	if( !text_set )
	{
		song[i].location=(char *)malloc( song[i].length );
		if( song[i].location==NULL ) 
		{
			put_stat( full, full );
			wait_for_play();
			set.num_songs=i;
			(void)Dsetpath( old_path );
			return FALSE;
		}
	if( !load_s_data( &song[i], s ) )
		if( !load_s_data( &song[i], s ) ) 
		{
			put_stat( "SONG MARKED AS BAD", "BAD SONG" );
			wait_for_play();
			song[i].type=TBAD ;
			strcpy( song[i].full_name, set.list[i] );
			(void)Dsetpath( old_path );
			return FALSE;
		}
	}

	strcpy( song[i].full_name, set.list[i] );

	strcpy( s, "\\SONGS\\" );
	strcat( s,set.list[i] );
	strcat( s,".TXT" );
	lyrics[i]=0;

	if( exist(s) )
		load_lyrics( &lyrics[i], s );

	if( !text_set )
	{
		strcpy( s, "\\SONGS\\" );
		strcat( s,set.list[i] );	
		strcat( s,".EXC" );
		excl[i].location=0;
		excl[i].type=0;
		if( exist(s) )
			load_exclusive( &song[i], &excl[i], s );
	}

	(void)Dsetpath( old_path );
	return TRUE;
}


void KillSong( ushort i )
{
	if( text_set )
	{
		if( lyrics[i] )
		{
			free( lyrics[i] );
			lyrics[i]=0;
		}	
	}
	else
	if( song[i].type==TSNG1 || song[i].type==TMThd ) {
		
		if( excl[i].type==TSNG1 || song[i].type==TMThd ) {
			free( excl[i].location );
			excl[i].location=0;
			excl[i].type=0;
#if DEBUG
			put_stat( "Killed exclusive","" );
			show_free_mem();
			getch();
#endif								
		if( lyrics[i] ) {
			free( lyrics[i] );
			lyrics[i]=0;
#if DEBUG
			put_stat( "Killed lyrics", "" );
			show_free_mem();
			getch();
#endif
		}
		free( song[i].location );
		song[i].location=0;
#if DEBUG
			put_stat( "Killed song","" );
			show_free_mem();
			getch();
#endif			

		}
		song[i].type=0;
		excl[i].type=0;
	}
	else {
		lyrics[i]=0;
		song[i].type=0;
		excl[i].type=0;
#if DEBUG
		put_stat( "Killed duplicate","" );
		getch();
#endif
		}
#if DEBUG
	show_free_mem();
	put_stat( "Done Killing 1", "Killed 1" );
	getch();
#endif

}



void load_songs()
{

#if DEMO_VERSION
	set.num_songs=5;
#endif

#if PERSONALIZED
#if 0
	if( short_user_name[0]!=user_id[1] || toupper(short_user_name[1])!=user_id[11]
	/*	|| toupper( short_user_name[2] ) != user_id[13] */ )
	{
		set.num_songs=short_user_name[0]/64;
	}
#endif
#endif

	if( cfg.load_single )
		return;

	while( kbhit() ) getch();
	
	jk_clr_m_buf();


	for( i=0; i<set.num_songs; i++ ) {
	
		if( kbhit() ) 
		{
			AbortLoad();
			break;
		}

		LoadSong( i );
#if DEBUG
		show_free_mem();
#endif
	}

}



void force_media_change()
{
	register unsigned int d=Dgetdrv();

#if PERSONALIZED
#if 0
	if( 	short_user_name[last_name_pos]!=user_id[3] 
		|| toupper(short_user_name[last_name_pos+2])!=user_id[14]
		|| toupper( short_user_name[last_name_pos+1] ) != user_id[12] )
	{
		set.num_songs=short_user_name[last_name_pos]/64;
		return;
	}
#endif
#endif	

	if( d==0 || d==1 )
		Rwabs( 0, NULL,1,1,d );
}

void do_hello_screen()
{
	t_clr_scrn();
	
#if PERSONALIZED
	for( short xx=0; xx<20; ++xx )
	{
		if( short_user_name[xx]==' ' )
		{
			last_name_pos=xx+1;
			break;
		}
	}
#endif
	for( unsigned short i=0; i<1; i++ )
		put_text( -1, i, HIGH_COLOR, 0, TITLE1 );

#if PERSONALIZED
	put_text( -1, 4, HIGH_COLOR, 0, "Version For:" );
	put_text( -1, 5, HIGH_COLOR, 0, USER_NAME );
#endif

	for( i=10; i<11; i+=2 )
	{
		put_text( -1, i, HIGH_COLOR, 0, 
		"Copyright (c) 1986-1993 By J.D. Koftinoff Software, Ltd" );
//#if HAL_TIPPER
		put_text( -1, i+1, HIGH_COLOR, 0,
		"and Pro MIDI Systems, Ltd." );
//#endif

	}
	put_text( -1, 15, HIGH_COLOR, 0,
	"Distributed By:" );
#if HAL_TIPPER
	put_text( -1, 17, HIGH_COLOR, 0, 
	"PRO MIDI SYSTEMS" );
	put_text( -1, 18, HIGH_COLOR, 0, 
	"176 Christie Park Manor, Calgary, Alberta, T3H-2P6" );
	put_text( -1, 19, HIGH_COLOR, 0,
	"or" );
	put_text( -1, 20, HIGH_COLOR, 0,
	"Box 13  Laurier, WA, USA 99146" );
	put_text( -1, 21, HIGH_COLOR, 0,
	"Phone: (403) 243-0358  FAX: (604) 442-3300" );
#else
	put_text( -1, 17, HIGH_COLOR, 0,
	"J.D. Koftinoff Software, Ltd." );
	put_text( -1, 18, HIGH_COLOR, 0,
	"Box 4103, Vancouver, BC" );
	put_text( -1, 19, HIGH_COLOR, 0,
	"CANADA, V6B-3Z6" );

	put_text( -1, 21, HIGH_COLOR, 0, 
	"Phone: (604) 430-6827  Fax: (604) 442-3233" );
#endif

}

Boolean exist( char *file )		/* check if a file exists	*/
{
int h;

	if( (h=jk_open( file, JK_O_RO ))<0 )
		return( FALSE );
	(void)jk_close( h );
	return( TRUE );
}

void show_set( int stat )		/* stat=1 to redraw entire set	*/
{					/* 0 just to update current song*/
unsigned short    i;
char s[80], t[80];
static int last_cur=-1;

	has_text_on=FALSE;
	if( (last_cur/110)!=(cur_song/110) )
	{
		top_song=(cur_song/110)*110;
		stat=TRUE;
	}
	
	if( stat==TRUE ) 
	{
		show_titles();
		
		if( text_set )
		{
			put_text( 74, 0, HIGH_COLOR, 0, "TEXT  " );
		}
		else
		{
			strcpy( s, "Set #0" );
			s[5]+=current_set;
			put_text( 74, 0, HIGH_COLOR, 0, s );
		}
		

#if PERSONALIZED
#if 0
	if( 	short_user_name[last_name_pos]!=user_id[3] 
		|| toupper(short_user_name[last_name_pos+2])!=user_id[14]
		|| toupper( short_user_name[last_name_pos+1] ) != user_id[12] )
	{
		set.num_songs=short_user_name[last_name_pos]/64;
		return;
	}
#endif
#endif	
	
		while( cur_song<top_song )
			top_song-=110;
		while( cur_song>top_song+110 )
			top_song+=110;
			
    		for( i=top_song; i<set.num_songs && i<top_song+110; i++ ) 
		{
			put_song( i );
		}
	}
	

	if( stat==FALSE ) {
		if( last_cur!=-1 )
			put_song( last_cur );
		put_song( cur_song );
	}   

    if( rez==1 )
       t_char_col( STAT_COLOR );
    else
    	t_rev_off();
    
//	strcpy( s, song[cur_song].full_name );
	strcpy( s, set.list[cur_song] );

	put_stat( s, s );
//	put_text( -1, 1, HIGH_COLOR, 1, s ); 
	
	strcpy( t, "S:" );
	strcat( t, set.list[cur_song] );

	ext_display( s, t );
	last_cur=cur_song;
}

void goto_mode0( unsigned int i)
{
unsigned int x,y;

	y=2+i;
	x=31;
	t_goto_xy( x,y);
}

void goto_mode1( unsigned int i)
{
unsigned int x,y;

	x=18;
	y=2+i;
	if( y>23 ) {
		y-=24-2;
		x=49;
	}
	
	t_goto_xy(x,y);
}

void goto_mode2( unsigned int i)
{
unsigned int x,y;

	x=1;
	y=2+i;
	
	while( y>23 ) 
	{
		y-=24-2;
		x+=16;
	}
	t_goto_xy(x,y);

}

void put_song( unsigned int i )
{
#if PERSONALIZED
#if 0
	if( strncmp( short_user_name, USER_NAME, 8 ) )
		i=(unsigned int) ((((double)set.num_songs)+.5)*3.1);
#endif
#endif
	
	if( set.num_songs<23 )
		goto_mode0(i);
	else if( set.num_songs<46 )
		goto_mode1(i);
	else
		goto_mode2(i%110);
       
	if( i == cur_song ) {
		if( rez==1 )
			t_char_col( HIGH_COLOR );
           	  
		else
			t_rev_on(); 
	}
	else {
		if( rez==1 ) 
			t_char_col( TEXT_COLOR );
		else
			t_rev_off();  
	}
       
        i++;
	putch( (i/100)%10+'0' );
	putch( (i/10)%10+'0' );
	putch( i%10+'0' );
	i--;
	
	if( song[i].type==TBAD  )
		putch( '*' );

	putch(' ' );
       	
	//cputs( song[i].full_name );
       	cputs( set.list[i] );
}

void show_titles()
{
	t_clr_scrn();
	put_text( 0, 0, HIGH_COLOR, 0, TITLE3 );

#if PERSONALIZED
	put_text( 29, 0, TEXT_COLOR, 0, "For" );
	put_text( 33, 0, HIGH_COLOR, 0, short_user_name );
#endif

}

