/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 
/*	rec_song.c											By Jeff Koftinoff
**	v1.0												started: Apr 17/88
**
*/

#include "rec_defs.h"

#define MEMORY_ALERT	"[1][Sorry, not enough memory to |continue.][ 'Sniff ]"


static JK_OBJ o;
static char *status, *info;

song_record()
{

	if( len_song_mem<10000 || song_data==NULL ) {
		form_alert( 1, MEMORY_ALERT );
		return( FAILED );
	}

	if( song_is_good ) {
		if( form_alert( 1, "[1][Erase current song/excl|in memory?][ OK | CANCEL ]" )==2 )
			return( FAILED );
		song.length=0;
	}
	else {
		if( form_alert( 1, "[1][Ready to record song.][  OK  | CANCEL ]" )==2 )
			return( FAILED );
		song.length=0;
		song.offset=0;
		song.thru=16;
		song.master_local=-1;
		song.full_name[0]='\0';
	}
	
	song_is_good=FALSE;
	
	song.location=song_data;

	rsrc_gaddr( 0, TR_RECS, (void **)&o.d );
	status= ((TEDINFO *)o.d[RS_STAT].ob_spec)->te_ptext;
	info= ((TEDINFO *)o.d[RS_INFO].ob_spec)->te_ptext;	
	
	strcpy( status, " Waiting for MIDI data " );
	sprintf( info, "Memory : %ld Bytes", len_song_mem );
	
	draw_tree( &o, TRUE );
	
	if( !rec_sng() ) 
		form_alert( 1, "[1][Recording CANCELED!][  OK  ]" );

	draw_tree( &o, FALSE );

	if( song_is_good ) {
	    song.type=TYPE_SNG1;
	    if( song_param() )
	    	file_save( Song_type );
	}	
	return( song_is_good ); 
}

rec_sng()
{
long   time1, time2;
int    msg_len, i;
register long	song_length=0;
register char *ptr;
char   buffer[300];
 
 	ptr=song.location;
 	
    while( midi_stat() ) midi_in();
    
    clr_con();
    
    do {
       if( kbhit() )
           if( (char)getch()==27 )
           		return( FAILED );
    } while((msg_len=jk_msg_in(ptr,300))<2);
    
    g_hide_m();
    strcpy( status, " -- RECORDING SONG --  " );
    objc_draw( o.d, RS_STAT, 10, EXPANDRECT( o.clip)  );
    
    song_length=msg_len;
    ptr+=msg_len;
    
    time1=(long)jk_get_200();
    
    do {
       if( song_length+512>len_song_mem ) {
           g_show_m();
           form_alert(1, MEMORY_ALERT );
           return( FAILED );
       }
       
       time2=(long)jk_get_200();
       
       if( time2-time1 > 199 ) {
           *ptr++ =0xff;
           *ptr++ =time2-time1;
           time1=time2;
           song_length+=2;
           continue;
       }
       
        if( (msg_len=jk_msg_in( buffer,300)) >1 ) {
       
      /*     if( buffer[0] > (char)0xcf 
               && buffer[0] < (char)0xe0 ) continue;
      */   
           if( time2-time1>3 ) {
               *ptr++=0xff;
               *ptr++=time2-time1;
               time1=time2;
               song_length+=2;
           }
           
           for( i=0; i<msg_len; i++ )
               *ptr++=buffer[i];
           song_length+=msg_len;
       }
    } while( !kbhit() );
       
    if( (char)getch()==27 )
    	song_is_good=FALSE;
    else {
    	song_is_good=TRUE;
		song.length=song_length;	
	}
	
    g_show_m();

    return( song_is_good );
}


song_param()
{
JK_OBJ o;
int thru, i,sel;
char *name, *thru_txt;

static char local[] = {
	S_LOCNO, S_LOCOFF, S_LOCON, -1
};

	if( !song_is_good ) {
		form_alert( 1,"[1][Sorry, no song in memory yet.][ CANCEL ]" );
		return( FAILED );
	}

	rsrc_gaddr(0, TR_SONGP,(void **) &o.d );

	name=((TEDINFO *)o.d[S_NAME].ob_spec)->te_ptext;
	thru_txt=((TEDINFO *)o.d[S_THRU].ob_spec)->te_ptext;
	
	
	for( i=0; i<3; i++ ) {
		if( song.master_local==i-1 )
			o.d[local[i]].ob_state |= SELECTED;
		else
			o.d[local[i]].ob_state &= ~SELECTED;
	}

	strncpy( name, song.full_name, 24 );

	thru=song.thru;
	parse_thru( thru_txt, thru );	
	
	draw_tree( &o, TRUE );
	
	do {
		sel=form_do( o.d, S_NAME );
		if( sel==S_THRUU ) 
			if( thru<16 ) {
				parse_thru( thru_txt, ++thru );
				objc_draw( o.d, S_THRU, 2, EXPANDRECT(o.clip) );
			}
		if( sel==S_THRUD )
			if( thru>=0 ) {
				parse_thru( thru_txt, --thru );
				objc_draw( o.d, S_THRU, 2, EXPANDRECT(o.clip) );
			}
			
	} while( sel != S_OK && sel != S_CANC );
	
	o.d[sel].ob_state &= ~SELECTED;
	draw_tree( &o, FALSE );
	
	if( sel== S_OK ) {
		strncpy( song.full_name, name, 24 );
		song.full_name[25]='\0';
		song.master_local=g_radio( local, o.d )-1;
		song.thru=thru;
		return( OK );
	}
	return( FAILED );
}


static
parse_thru( char *txt, char chan )
{

	switch( chan ) {
		case -1:
			strcpy( txt, "OFF" );
			break;
		case 16:
			strcpy( txt, "ALL" );
			break;
		default:
			sprintf( txt, "%3d", chan+1 );
			break;
	};
}


