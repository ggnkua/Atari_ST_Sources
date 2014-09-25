/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 
/*	ply_main.c					By Jeff Koftinoff
**	v1.0						started: Apr 17/88
**
*/



#include "ply_defs.h"
#include "olddisk.h"
#include "personal.h"
#include "clocks.h"

#define SEND_INT_CLOCK	1

extern void ReadConfiguration();
extern void do_hello_screen();
extern void force_media_change();


char *full= "MEMORY FULL"; 
Command cur_command;
int current_set;

CFG cfg = {
	TCFG0,			// cfg_type
	-1,			// master_ch
	-1,			// master_local
	-1,			// light_ch
	2,			// disp_type
	16,			// disp_chan
	16,			// thru
	1,			// ctrl_type
	0,			// ctrl_chan
	0,			// auto_play
	0,			// wait_after_excl
	0,			// use_joy
	0,			// load_single
	0			// pause_after_load
};

SET set;
SONG song[NUM_SONGS];
char *lyrics[NUM_SONGS];
SONG excl[NUM_SONGS];

int	top_song=0;
int	cur_song, rez, cur_thru=16, playing=FALSE;
int	error_flag=TRUE;

char wait_msg[]= "WAITING",
	 dongle[]= "The Pro MIDI player requires"
	 	   " A hardware key. Please use it.";

int _stksize=-1L;
int has_text_on=FALSE;
long _orig_heapbase=0;
extern void * _heapbase;
int text_set=FALSE;

extern void build_text_set();

void toggle_background()
{
	if( rez==2 )
	{
		int prev=Setcolor( 0, -1 )&1;
		(void)Setcolor( 0, !prev ); 
	}
}

void do_dongle()
{

	do_hello_screen();
	put_text( -1, 13, HIGH_COLOR,0, dongle );
	long time=jk_get_200()+(200*20);
	while( time>jk_get_200() );
	t_clr_scrn();
}

#if SEND_INT_CLOCK

extern short clock_ticks_per_midi_clock;

void StartDefaultClock()
{
	clock_ticks_per_midi_clock=4;
	set_timer( 192 );
}

void	StopDefaultClock()
{
	unset_timer();
}

#else
void StartDefaultClock()
{
}

#endif

void DispatchCommand()
{
	switch( cur_command.type ) {
		case ComAutoPlay:
			init_watch();
			auto_play();
			//put_stat( wait_msg, wait_msg );
			break;
		case ComPlay:
			init_watch();
			play_song();
			if( ++cur_song==set.num_songs )
				cur_song=0;
			show_set(FALSE);
			//put_stat( wait_msg, wait_msg );
			break;
		case ComSkip:
			if( ++cur_song==set.num_songs )
				cur_song=0;
			show_set(FALSE);
			break;
		case ComBackup:
			if( cur_song--==0 )
				cur_song=set.num_songs-1;
			show_set(FALSE);
			break;
		case ComSelect:
			cur_song=cur_command.value;
			show_set(FALSE);
			break;
		case ComUnhang:
			unhang();
			break;
		case ComHelp:
			show_help();
			//put_stat( wait_msg, wait_msg );
			break;
		case ComTextSet:
			kill_songs();
			t_clr_scrn();
			show_titles();
			build_text_set();
			text_set=TRUE;
			load_songs();
			cur_song=0;
			put_stat( wait_msg, wait_msg );
			pwrite1(0,8);
			pwrite1(1,12);
  			pwrite1(2,32);
			pwrite1(3,0x30);
			show_set(TRUE);
			stop_watch();
			break;
		case ComNewSet:
			//if( cur_command.value==current_set ) 
			//	break;
			if( 
			  set_exists(cur_command.value) ) {
				kill_songs();
				t_clr_scrn();
				show_titles();
				text_set=FALSE;
				get_set(cur_command.value);
				load_songs();
				cur_song=0;
				put_stat( wait_msg, wait_msg );
				pwrite1(0,8);
				pwrite1(1,12);
  			 	pwrite1(2,32);
				pwrite1(3,0x30);
				show_set(TRUE);
				stop_watch();
			}
			break;
		case ComReload:
			kill_songs();
			t_clr_scrn();
			show_titles();
			text_set=FALSE;
			build_set();
			load_songs();
			cur_song=0;
			put_stat( wait_msg, wait_msg );
			pwrite1(0,8);
			pwrite1(1,12);
  			pwrite1(2,32);
			pwrite1(3,0x30);
			show_set(TRUE);
			stop_watch();
			break;
		default:
			break;
	}
}

main()
{

   if( kbhit() )               /* pressing ESC while starting exits    */
       if( (getch()&0x7f)==27 )
           exit(1);

   _orig_heapbase= (long)_heapbase;
   pwrite1(0,1);
   pwrite1(1,2);
   pwrite1(2,0);
   pwrite1(3,2);

   if( pread(0)!=1 || pread(1)!=2 || pread(2)!=0 || pread(3)!=2 ) {
   		init();
		do_dongle();
		(void)getch();
		init();
		exit(1);
	}
	pwrite(0,2);
	pwrite(1,3);
	pwrite(2,0);
	pwrite(3,1);

 	if( pread1(0)!=2 || pread1(1)!=3 || pread1(2)!=0 || pread1(3)!=1 ) {
		init();
		do_dongle();
		(void)getch();
		init();
		exit(1);
	}

	init();	
	
	do_hello_screen();
	long timed=jk_get_200()+(200*5);
	while( timed>jk_get_200() );
	
	do {
		StartDefaultClock();

		show_titles();
		get_cfg();
		get_set(0);
		load_songs();

		while( set.num_songs==0 ) {
			(void)getch();
			load_songs();
		}

		show_set(TRUE);

		cur_thru=cfg.thru;

		master( cfg.master_local );

		if( cfg.auto_play ) {
			init_watch();
			auto_play();
		}
		//put_stat( wait_msg, wait_msg );
		do {
		pwrite(0,3);
		pwrite(1,1);
		pwrite(2,2);
		pwrite(3,3);

	 	if( pread(0)!=3 || pread(1)!=1 || pread(2)!=2 || pread(3)!=3 ) 
		{
			do_dongle();
			(void)getch();
			init();
			exit(1);
		}

	
			do {
				update_watch();
				get_action();
			} while( cur_command.type==ComNone );

			DispatchCommand();
			

		} while( cur_command.type != ComExit );
		kill_songs();
		stop_watch();
		if( cur_command.type==ComExit ) break;
		
	} while( TRUE );

	StopDefaultClock();
	init();	
	exit(0);
}


Boolean is_auto_playing=FALSE;

void auto_play()
{
int state, cur;
	
	if( text_set )
		return;

	is_auto_playing=TRUE;

	do 
	{
		show_set(FALSE);
		state=play_song();
		cur=cur_song;
		if( ++cur==set.num_songs )
			cur=0;
		cur_song=cur;

	
	} while( state && is_auto_playing );
	show_set( FALSE );
	is_auto_playing=FALSE;
}

void kill_songs()
{
#if DEBUG
	put_stat( "Ready to kill", "" );
	show_free_mem();
	getch();
#endif
	top_song=0;
	for( short i=set.num_songs-1; i>=0 ; i-- ) {
		KillSong( i );
	}
}


void init()
{
unsigned short i;
static int 	orig_rez, flag=0, orig_colors[16],
	   colors[4]= {
           0x0000, 0x0777, 0x0730, 0x047 };

	ReadConfiguration();

	if( flag==0 ) {
		JoyInit(); 
		//rs_init( 4096 );
		
		orig_rez=Getrez();
    
		if( orig_rez == 2 ) {
			orig_colors[0]=Setcolor( 0, -1 );
			(void)Setcolor( 0, colors[0] ); 
		}  
		if( orig_rez == 1 )
		{
			for( i=0; i<4; i++ )
				orig_colors[i]=Setcolor( i, -1 );
       		}
		
		if( orig_rez == 0 ) {               /* if in low rez,               */
			for( i=0; i<16; i++ )
				orig_colors[i]=Setcolor( i, -1 );
			(void)Setscreen( -1L, -1L, 1 );
				/* set screen to med rez     */      
    		}          
    
		if( (rez=Getrez())==1 ) {
			for( i=0; i<4; i++ )   /* set needed colors                    */
				(void)Setcolor( i, colors[ i ] );
			t_back_col( BACK_COLOR );
		}
		t_curs_off();      
		t_over_off();
		flag=1;
		return;
	}
	else {
		JoyKill();	
		//rs_exit();
			
		if( orig_rez==0 ) {
			Setscreen( (long)-1, (long)-1, 0 );     /* reset normal rez     */
    
			for( i=0; i<16; i++ )  /* reset normal colours         */
				(void)Setcolor( i, orig_colors[i] );
		
			t_char_col(15);
		}
    
		if( orig_rez==1 ) {
			for( i=0; i<4; i++ )
				(void)Setcolor( i, orig_colors[i] );
	    		t_char_col( 3 );
		}

		if( orig_rez==2 ) {
			(void)Setcolor( 0, orig_colors[0] );
			t_char_col( 1 );
		}
    
		//t_curs_on();
		light(0);							/* shut off lighting	*/

	}

}

Boolean set_exists( int set_num )	/* check if the set file exists */
{
char file[16], s[16];
	
	strcpy( file, "performX.set" );
	
	file[7]=set_num+'0';

	force_media_change();

	if( exist( file ) ) return( TRUE );

	strcpy( s, "\\" );
	strcat( s, file );
	if( exist( s ) )
		return( TRUE );

	return( FALSE );
}

void get_set( int set_num )
{
long time;
char file[16], s[16];

	top_song=0;
	cur_song=0;
	strcpy( file, "performX.set" );
	
	file[7]=set_num+'0';

	error_flag=FALSE;
	put_stat( "LOADING SET", "L:SET" );
	if( !load_set( &set, file )) {
		strcpy( s, "\\" );
		strcat( s, file );
		if( !load_set( &set, s )) {
			error_flag=TRUE;
			build_set();
			return;
		}
	}
	error_flag=TRUE;

	if( set.num_songs>NUM_SONGS || set.num_songs<1 ) 
	{
		put_stat( "SET IS BAD", "BAD SET" );
		time=jk_get_200()+400;
		while( jk_get_200()<time );
		build_set();
	}
	current_set=set_num;
}

void get_cfg()
{
	ReadConfiguration();

	light(0);

}







Boolean load_exclusive( SONG *song, SONG *excl, char *s )
{
	error_flag=FALSE;
	if( !load_s_param( excl, s) )
		if( !load_s_param( excl, s) ) {
			excl->type=0;
			error_flag=TRUE;
			return TRUE;
		}
	error_flag=TRUE;
	put_stat( "Loading Exclusive", "L:EXCL" );
	
	excl->location=(char *)malloc( excl->length );
	if( excl->location==0 ) {
		put_stat( full, full );
		wait_for_play();
		free( song->location );
		song->type=TBAD ;
		return FALSE;
	}
	if( !load_s_data( excl, s ) )
		if( !load_s_data( excl, s ) ) {
			put_stat( "BAD EXCL, SONG MARKED BAD", "BAD EXCL" );
			wait_for_play();
			song->type=TBAD ;
			return TRUE;
		}
	return TRUE;
}		



void show_help()
{
	extern unsigned short l_stat;
	int l=2;	
	int x=17;

	show_titles();
	
	put_text( -1, l++, HIGH_COLOR, 1,
"HELP SCREEN" );
	put_text( x, l++, STAT_COLOR, 0,
"KEY                            FUNCTION         " );
	l++;
	put_text( x, l++, TEXT_COLOR, 0,
"Space Bar                      Play Song/Stop Song/Do Loop" );
	put_text( x, l++, TEXT_COLOR, 0,
"'\\'                            Start/Stop Auto play" );
	get_action();
	put_text( x, l++, TEXT_COLOR, 0,
"Song #, Return                 Select Song     " );
	get_action();
	put_text( x, l++, TEXT_COLOR, 0,
"Up Arrow/Down Arrow            Select Song/Select Text Page" );
	get_action();
	put_text( x, l++, TEXT_COLOR, 0,
"Left Arrow/Right Arrow         Select Song     " );


	if( cfg.light_ch>=0 && cfg.light_ch<16 ) {
		put_text( x, l++, TEXT_COLOR, 0,
"Shift F1-F8                    Toggle Light    " );
		put_text( x, l++, TEXT_COLOR, 0,
"Shift F9                       All Lights On   " );
		put_text( x, l++, TEXT_COLOR, 0,
"Shift F10                      All Lights Off  " );
	}

	get_action();

	put_text( x, l++, TEXT_COLOR, 0,
"Ctrl-U or 'U'                  Unhang notes    " );
	put_text( x, l++, TEXT_COLOR, 0,
"Ctrl-P or 'P'                  Pause Song      " );
	put_text( x, l++, TEXT_COLOR, 0,
"Ctrl-A or 'A'                  Abort Song      " );
	put_text( x, l++, TEXT_COLOR, 0,
"',' and '.'                    Tempo Down/Up   " );
	put_text( x, l++, TEXT_COLOR, 0,
"Ctrl-L or 'L'                  Load all songs  " );
	put_text( x, l++, TEXT_COLOR, 0,
"F1-F9 or F10                   Load Set 1-9 or 0 " );
	put_text( x, l++, TEXT_COLOR, 0,
"Ctrl-T or 'T'                  Create text set " );
	put_text( x, l++, TEXT_COLOR, 0,
"Ctrl-G                         Goodbye (exit)  " );

	l+=3;
	put_text( -1, l, TEXT_COLOR, 0,
"Press Play to Continue" );
	
	wait_for_play();		

	show_titles();
	show_set(TRUE);

	light( l_stat );
}


static	int lyrics_pos;
static	char *lyrics_ptr;
static 	int current_page;
static 	Boolean	lyrics_valid;
static	int new_page;
static	int current_line;
static	int start_new_page;
static	Boolean still_drawing_lyrics;

void	select_prev_page()
{
	if( current_page>0 )
		select_new_page( current_page-1 );
}

void	select_next_page()
{
	select_new_page( current_page+1 );	
}


Boolean select_new_page( int p )
{
	if( lyrics_valid )
	{
		new_page=p;
		if( new_page!=current_page )
		{
			still_drawing_lyrics=find_page();

			if( still_drawing_lyrics )
				start_new_page=1;	
			else
				new_page=current_page;

			return still_drawing_lyrics;
		}
	}
	return FALSE;
}

static 	Boolean find_page()
{
	if( lyrics_valid )
	{
		int l=1;
		char last_c=0;
		char c=0;
		int pg=0;

		lyrics_pos=0;
		if( new_page==0 )
		{
			current_page=new_page;
			return TRUE;
		}

		for( ; lyrics_pos<24000; ++lyrics_pos )
		{
			last_c=c;
			c=lyrics_ptr[lyrics_pos];

			if( c==0 )
			{
				return FALSE;
			}

			if( c=='\r' )
			{
				++l;
			}
			else if( c=='\n' && last_c!='\r' )
			{
				++l;
			}

			if( pg<new_page-1 && l>=24 )
			{
				++pg;
				l=0;
			}

			if( pg==new_page-1 && l>=25 )
			{
				current_page=new_page;
				return TRUE;
			}
			
		}
	}
	return FALSE;
}

Boolean draw_next_char()
{
	static char last_c=0;
	char c;

	if( lyrics_valid && still_drawing_lyrics )
	{
		if( start_new_page )
		{
			last_c=0;
			t_clr_scrn();
			if( new_page==0 )
			{
				t_goto_xy(0,1);
				current_line=1;
			} 
			else
			{
				t_goto_xy(0,0);
				current_line=0;
			}
			start_new_page=0;
			return TRUE;
		}
		c=lyrics_ptr[lyrics_pos];
		
		if( !c )
		{
			still_drawing_lyrics=FALSE;
			last_c=0;
			return FALSE;
		}
		
		if( (c=='\n' && last_c=='\r') )
		{
			last_c=c;
			++lyrics_pos;
			return TRUE;
		}

		if( (c=='\n' && last_c!='\r') || c=='\r' )
		{
			++current_line;
			if( current_line>=25 )
			{
				still_drawing_lyrics=FALSE;
				return FALSE;
			}
			putch( '\r' );
			putch( '\n' );
		}
		else
			putch( c );

		++lyrics_pos;
		last_c=c;
		return TRUE;	
	}
	else
	{
		return FALSE;
	}
}


Boolean	show_lyrics()
{
	if( !lyrics[cur_song] )
	{
		lyrics_valid=FALSE;
		return FALSE;
	}
	lyrics_valid=TRUE;
	lyrics_pos=0;
	lyrics_ptr=lyrics[cur_song];

	has_text_on=TRUE;
		
	t_clr_scrn();
	t_char_col(3);
	t_back_col(0);
	t_rev_off();
	t_goto_xy(0,1);

	current_line=1;
	current_page=-1;
	new_page=0;
	still_drawing_lyrics=TRUE;
	start_new_page=1;
	while( draw_next_char() );
	current_page=0;
	return TRUE;
}




#if 0
Boolean show_lyrics()
{
unsigned int i;
register char *l;
int line;

	i=cur_song;

	if( !lyrics[i] )
		return(FALSE);

	has_text_on=TRUE;		
	t_clr_scrn();

	//	put_text(-1,0,1,1, song[i].full_name );
	t_char_col(3);
	t_back_col(0);
	t_rev_off();
	t_goto_xy( 0, 1 );
	line=1;

	l=lyrics[i];
		
	while( *l ) 
	{
		if( *l=='\n' ) {
			if( *(l-1)!='\r' )
				putch( '\r' );
			line++;
			if( line==24 ) break;
		}
		putch( *l );
			
		l++;
	};
	
	return(TRUE);
}
#endif

Boolean play_text_song()
{
	if( cfg.load_single == 1 )
		if( !LoadSong( cur_song ) )
			return FALSE;

	playing=TRUE;
	show_lyrics();

	put_stat( "TEXT VIEW ONLY", "TEXT VIEW" );
	wait_for_play();
	playing=FALSE;

	has_text_on=FALSE;
	if( lyrics[cur_song] ) 
	{
		show_titles();
		show_set(TRUE);
	}

	if( cfg.load_single == 1 )
		KillSong( cur_song );
	return TRUE;
}

Boolean play_song()
{
char s[80], t[80];
register Boolean stat;
int a;


	if( text_set )
	{
		return play_text_song();
	}

	if( cfg.load_single == 1 )
		if( !LoadSong( cur_song ) )
			return FALSE;


	playing=TRUE;

	a=cur_song;

	show_lyrics();	

	if( cfg.load_single == 1 && cfg.pause_after_load == 1 )
	{
		put_stat( "PAUSED", "PAUSE" );
		wait_for_play();
	}	

	if( excl[a].type!=0 ) 
	{
		strcpy( s, "Exclusives:" );
		strcat( s, excl[a].full_name );
		strcpy( t, "EX:" );
		strcat( t, set.list[a] );
		//master( excl[a].master_local );
		if( excl[a].thru!=-2 )
			cur_thru=excl[a].thru;
		
		put_stat(s,t);
		if( (stat=dispatch( &excl[a] ))==FALSE ) goto end;
		
		if( cfg.wait_after_excl )
		{
			put_stat( "PAUSED", "PAUSE" );
			StartDefaultClock();
			wait_for_play();
		}
		
	}


	if( song[a].thru!=-2 )
		cur_thru=song[a].thru;
	strcpy( s, "Playing:" );
	strcat( s, song[a].full_name );
	strcpy( t, "P:" );
	strcat( t, set.list[a] );

	master( song[a].master_local );

	put_stat( s,t );
	
	stat=dispatch( &song[a] );
	StartDefaultClock();

end:
	cur_thru=cfg.thru;
	playing=FALSE;

	master( cfg.master_local );
	has_text_on=FALSE;
	if( lyrics[a] ) 
	{
		show_titles();
		show_set(TRUE);
	}

	if( cfg.load_single == 1 )
		KillSong( cur_song );

	StartDefaultClock();

	return( stat );
}

Boolean dispatch( SONG *song )
{
long type;
Boolean stat=FALSE;


	if( text_set )
	{
		return play_text_song();
	}

	type=song->type;

	if( type==TSNG1 ||
		type==TTNG1 )
		stat=play_s1( song );
	else if( type==TMThd || type==TNThd )
		stat=play_midi( song );

	else if( type!=TBAD  ) {
		put_stat( "SONG NOT RECOGNIZED!", "BAD SONG!" );
		type=jk_get_200()+200;
		while( jk_get_200()<type ) {
			get_action();
		}
	}
	lyrics_valid=FALSE;
	return stat;
}



Boolean master( int mode )
{
register char chan;

	if( mode==-1 ) return( OK );            

	if( cfg.master_ch==(char)-1 ) return( FAILED );
	chan=cfg.master_ch;
	chan &= 0xf;

	midi_out( 0xb0 | (chan) );
	midi_out( 122 );

	if( mode==TRUE )
		midi_out( 0x7f );
	else
		midi_out( 0 );
	return OK;
}




Boolean disk_error( DiskErr type, char *file )
{
char s[80], t[80];

	if( !error_flag ) {
		if( type==NoError ) return( OK );
		return( FAILED );
	}

	switch( type ) {
		case NoError:
			return( OK );

		case OpenError:
			strcpy( s, "ERROR OPENING:" );
			strcpy( t, "EO:" );
			break;			
		case CreateError:
			strcpy( s, "ERROR CREATING:" );
			strcpy( t, "EC:" );
			break;
		case ReadError:
			strcpy( s, "ERROR READING:" );
			strcpy( t, "ER:" );
			break;
		case WriteError:
			strcpy( s, "ERROR WRITING:" );
			strcpy( t, "EW:" );
			break;
		case TypeError:
			strcpy( s, "WRONG TYPE:" );
			strcpy( t, "ET:" );
			break;
	}
	strcat( s, file );
	strcat( t, file );
	put_stat( s, t );
	
	cur_command.type=ComNone;
	
	wait_for_play();

	return( FAILED );
}


void wait_for_play()
{
	do {
		get_action();
		if( playing==TRUE )
		{
			draw_next_char();
			if( cur_command.type==ComSkip )
				select_next_page();
			else if( cur_command.type==ComBackup )
				select_prev_page();
		}
		if( cur_command.type==ComPlay || cur_command.type==ComAutoPlay )
			break;
	} while( 1 );

}


void show_free_mem()
{
#if DEBUG
	char s[32];
	
	sprintf( s,"Heapbase diff=%08x",(long) _heapbase - _orig_heapbase );
	put_text( 0,20,1,0,s );
#endif
}

/* int clock_is_running=FALSE;
long current_time=0, last_update_time=0;
static int hours=0, minutes=0, sec=0;
*/

void update_watch()
{

}

void init_watch()
{

}

void stop_watch()
{

}
