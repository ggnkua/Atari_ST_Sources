/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 
 /*	play_s1.c
**
**	Plays a song of type 'SNG1'
**
*/


#include "ply_defs.h"

extern	Command cur_command;
extern	CFG cfg;

extern	int	rez;
extern	int cur_thru;



Boolean play_s1( SONG *sng )
{
int    lflag, note, vel, light_status;
long   st_time, waste, length;
unsigned delay;
register char *s;
register long i;
char	light_note=-1;

	if( cfg.light_ch<0 || cfg.light_ch>15 )
		light_status=FALSE;
	else
		light_status=TRUE;

	if( light_status ) {
		light_note=0x90+cfg.light_ch;
		lflag=0;
	}

	s=sng->location;
	length=sng->length;

	i=0;
	st_time=(long)jk_get_200();

	do {
		if( light_status ) {
			if( s[i]>=(char)0x80 ) lflag=0;   /* this message NOT lighting */
	
			if( s[i]==light_note ) {
				i++;
				lflag=2; /* current lighting msg has running stat (0x9y) */
			}

			if( (s[i]>=0 && s[i]<(char)0x80 && lflag==1) || lflag==2 ) {

				lflag=1; /* next msg might be lighting   */
				note=s[i];   /* note #   */
				i++;
				vel=s[i];     /* velocity */
				i++;

				light_midi( note, vel );
			}
		}

		if( s[i]==(char)0xff ) {
			i++;
			if( i>=length ) break;
           
			waste=(long)jk_get_200()-st_time;
           
			delay=s[i++];
           
			if( waste>=delay ) {
				st_time+=delay;
				continue;
			}
           
			delay-=waste;
           
			if( wait_s1( delay ) == FAILED )
				return( FAILED );
           /* fails if ABORT is pressed        */
           
			if( i>=length ) break;
           
			st_time=(long)jk_get_200();
   
			continue;
		}
       
		midi_out( s[i++] );

		if( i>=length ) break;
	} while( TRUE );
	return( OK );
}

Boolean wait_s1( unsigned long delay )   /* waits delay/200 seconds      */
{
register long end_time;

	end_time = ((long)jk_get_200() + delay);
    
	while( (long)jk_get_200() < end_time) {
		get_action();
		if( cur_command.type!=ComNone ) switch( cur_command.type ) {
			case ComPlay:
			case ComStop:
				unhang();
				return( FAILED );

			case ComUnhang:
				unhang();
				break;				

			case ComPause:
				put_stat( "*** PAUSE ***", "PAUSE" );
				clr_con();
				jk_clr_m_buf();
				unhang();

				wait_for_play();
			
				put_stat( "PLAYING", "PLAYING" );
				break;
			default:
				break;
           };           
    }
       
    return( OK );              
}
