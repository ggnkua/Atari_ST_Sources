/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 
/*	playmidi.c
**
**	Plays a song of type 'Midi'
**	( MIDI Song File Format 0)
**
*/

#define SEND_CLOCK	0
#define SEND_INT_CLOCK	1

/* do the following define so the program will show you when
** a tempo change happens, and tells you info
*/

/*
 #define SHOW_TEMPOS
 #define SHOW_EVENTS
*/

#define SHOW_TEMPO1 0
#define DEBUG_2 0
#define DEBUG_3 0
#define DEBUG_4 1
#define INCLUDE_HEX_DUMP 0


char s[200];

#include "ply_defs.h"
#include "personal.h"
#include "midstat.h"

extern long clock_ticks;


extern	Command cur_command;
extern	CFG cfg;
extern	SET set;

extern	int	rez;
extern	int cur_thru;

unsigned char *seq_ptr, *sng_location;

int  ts_numerator, ts_denom;
long cur_tempo;			// in microseconds per beat 
long tempo_offset;		// in microseconds per beat

long last_sent_time;		// time that the last event was sent
unsigned char seq_run_stat;	// running status for sequence

typedef struct {
	long time;		// time that event will be sent at
	int	 length;	// message length
	unsigned char data[384];// MIDI Data	
} EVENT;

EVENT s_event;

short division;	// division from midi file
		// copy of division from current song

#if SEND_CLOCK || SEND_INT_CLOCK
short ticks_per_midi_clock;
long last_sent_midi_clock_time;
#endif

#if SEND_INT_CLOCK
extern short clock_ticks_per_midi_clock;
extern short cur_midi_clock_tick_count;
#endif
		
static void read_event();
static long read_var_length();
static long calc_freq(void);
static void start_clock(void);
static void set_tempo(void);

#ifdef SHOW_EVENTS
static void display_event(void);
#endif

static void send_event(void);
static Boolean wait_midi(void);



static long read_var_length()
{
#ifdef __GNUG__
	register long retvalue __asm__("d0");
	asm ( "
		clrl	D0
		movel	%2,a0

Lrdlp:
		lslw	#7,D0
		moveb	a0@+,D2
		moveb	d2,d1
		andb	#0x7f,d1
		orb	d1,%1
		tstb	d2
		jmi	Lrdlp
		movel	a0,%0
	"
	:	"=g"(seq_ptr), "=r"(retvalue)		/* output 	*/
	:	"g"(seq_ptr)				/* input	*/
	:	"a0", "d0", "d1", "d2"
	 );
	return retvalue;
#else 

	asm {
		clr.l	D0
		move.l	seq_ptr,A0
loop:
		lsl		#7,D0
		move.b	(A0)+,D2
		move.b	D2,D1
		and.b	#0x7f,D1		;strip off high bit
		or.b	D1,D0			;put it in result
		tst.b	D2			;was it set?
		bmi		loop		;yes, do it again

		move.l	A0,seq_ptr		;save the updated pointer
	}
#endif
}



#if DEBUG_2
#define INCLUDE_HEX_DUMP 1
#endif

#if INCLUDE_HEX_DUMP

char hex_digit[17]="0123456789abcdef";

void put_hex_byte( unsigned char b )
{
	putch( hex_digit[ b >> 4 ] );
	putch( hex_digit[ b & 0x0f ] );
}

void put_hex_word( unsigned short b )
{
	put_hex_byte( b>>8 );
	put_hex_byte( b&0xff );
}

void put_hex_long( unsigned long b )
{
	put_hex_word( b>>16 );
	put_hex_word( b&0xffff );
}

#endif

static void read_event()
{
register unsigned char *s_ptr;
static unsigned char run_stat;
register unsigned int first, second;
long length;
long dtime;

try_again:
	dtime=read_var_length();

	s_event.time=(dtime<<1) + last_sent_time;
	
#if DEBUG_2
	if( dtime>0x1000 )
	{
		cputs( "\r\nPossible Error: DTIME=" );
		put_hex_long( dtime );
		cputs( "\r\nOffset =" );
		put_hex_long( (long)(seq_ptr-sng_location) );
		cputs( "\r\n" );
	}
#endif

	/* dtime is * by 2 because clock is too, for accurate clock */
	
	last_sent_time=s_event.time;

	s_ptr=seq_ptr;
	
	first=*s_ptr++;
	if( first<0x80 ) {
		second=first;
		first=run_stat;
#if DEBUG_2
		if( run_stat==0 )
		{
			cputs( "\r\nBad Status! second =" );
			put_hex_byte( second );
			cputs( "\r\nOffset =" );
			put_hex_long( (long)(seq_ptr-sng_location) );
			cputs( "\r\n" );
		}
#endif
	}
	else {
		if( first<0xf0 )
			run_stat=first;
		if( first!=0xf0 && first!=0xf7 )
			second=*s_ptr++;
	}

	s_event.data[0]=first;
	s_event.data[1]=second;


#if 0	
		sprintf( s, "\r\n0x%02x 0x%02x\r\n",
			s_event.data[0],
			s_event.data[1] );
		cputs( s );
#endif
/* handle Meta-Events	*/
	if( first==0xff || first==0xf0 || first==0xf7 ) {

#if DEBUG_2
		cputs( "\r\nMeta Event " );
		put_hex_byte( first );
		cputs( "\r\nOffset =" );
		put_hex_long( (long)(seq_ptr-sng_location) );
		cputs( "\r\n" );
#endif
		/* run_stat=0; */

		seq_ptr=s_ptr;
		length=read_var_length();

#if DEBUG_2
		cputs( "\r\nMeta Length=" );
		put_hex_long( length );
		cputs( "\r\n" );
#endif
		if( length>370 ) {
			seq_ptr+=length;
#if DEBUG_2
			cputs( "\r\nEvent too long to send\r\n" );
#endif
			goto try_again;
		}

		s_ptr=seq_ptr;

		if( first==0xf0 || first==0xf7 )
		{
			s_event.data[1] = *s_ptr++;
			--length;
		}

		for( second=0; second<length; second++ ) {
			s_event.data[2+second]=*s_ptr++;
		}
		seq_ptr=s_ptr;

		s_event.length=length;
		if( first!=0xff )
			s_event.length++;

		return;
	}

#if DEMO_VERSION
	if( s_event.time/50 > (92*4) )
	{
		s_event.data[0]=0xff;
		s_event.data[1]=0x2f;
		return;
	}
#endif

	first&=0xf0;
	if( (first==0xc0) || (first==0xd0) )
	{
		s_event.length=2;
		seq_ptr=s_ptr;
		return;
	}
	else
	if( (first==0x80) || (first==0x90) ||
		(first==0xb0) || (first==0xe0)) {
		s_event.length=3;
		s_event.data[2]=*s_ptr++;
		seq_ptr=s_ptr;
		return;
	}
#ifdef SHOW_EVENTS
	cputs( "\r\nEvent Not recognized\r\n" );
#endif	
	s_event.length=0;
}


static long calc_freq()
{
register long clock_per_beat, micro_sec_per_beat;
long freq;

	/* calculate frequency of clock.
	** division is internal clocks per beat (?).
	** cur_tempo is in microseconds per beat
	*/
	
	clock_per_beat= ((long)division) *1000;
	micro_sec_per_beat=(cur_tempo+tempo_offset+500)/1000;

	freq=clock_per_beat/micro_sec_per_beat;

#if SHOW_TEMPO1
	put_hex_long( cur_tempo );
#endif

#ifdef SHOW_TEMPOS
	sprintf( s, "\r\ndivision=%d\r\nts_numerator=%d\r\n\
cur_tempo=%ld\r\nclock_per_beat=%ld\r\nmicro_sec_per_beat=%ld\r\n",
	division, ts_numerator, cur_tempo,
	clock_per_beat, micro_sec_per_beat );
	
	cputs( s );
	sprintf( s, "\r\nFrequency=%ld\r\n",
		freq );
	cputs( s );
	
	sprintf( s, "\r\ntempo: %lf\r\n", (double)1/((double)cur_tempo/1e6)*60 );
	cputs( s);
	sprintf( s, "\r\nOffset:%ld\r\n", (long)(seq_ptr-sng_location) );
	cputs( s );
#endif

	return( freq<<1 );		/* multiply freq by 2, for accurate clock */
}

static void start_clock()
{
	ts_numerator=4;	/* default */
	ts_denom=4;
	cur_tempo=500000;
#if SEND_CLOCK 
	ticks_per_midi_clock = (division*2)/24;
#endif

#if SEND_INT_CLOCK
	clock_ticks_per_midi_clock = (division*2)/24;
#endif

	set_timer( calc_freq() );
}



static void set_tempo()
{
#ifdef __GNUG__

	asm ( "
		clrl	D0
		clrl	D1
		
		moveb	%1,D0
		swap	D0
		moveb	%2,D1
		
		aslw	#8,d1
		moveb	%3,D1
		movew	D1,D0
		movel	D0,%0	
	"
	:	"=g"(cur_tempo)			/* outputs 	*/
	:	"g"(s_event.data[2]),		/* inputs	*/
		"g"(s_event.data[3]),
		"g"(s_event.data[4])
	:	"d0", "d1"			/* clobbered	*/
	 );
	
#else 

	asm {
		clr.l	D0
		clr.l	D1
		
		move.b	s_event.data+2,D0	/* read first byte */
		swap	D0			/* take it to upper word */
		move.b	s_event.data+3,D1	/* read second byte 	*/
		
		asl.w	#8,D1			/* shift it	*/
		move.b	s_event.data+4,D1	/* read last byte*/
		move.w	D1,D0
		move.l	D0,cur_tempo
	}

#endif
	set_timer( calc_freq() );
}

void do_tempo_up()
{
	tempo_offset-=2000;
	set_timer( calc_freq() );
}


void do_tempo_down()
{
	tempo_offset+=2000;
	set_timer( calc_freq() );
}


unsigned char *start_auto_loop;
Boolean auto_loop_valid;
unsigned char auto_loop_count;


Boolean handle_auto_loop_command()
{
	if( s_event.data[2]==0 && !auto_loop_valid )
	{
		start_auto_loop=seq_ptr;
#if DEBUG_4
		cputs( "\r\nauto loop start found" );
#endif
		return TRUE;
	}

	if( s_event.data[2]!=0 && start_auto_loop!=0 )
	{
#if DEBUG_4
		cputs( "\r\nend auto loop found" );
#endif
		if( !auto_loop_valid )
		{
			// the first time through
			auto_loop_valid=TRUE;
			auto_loop_count=s_event.data[2]-1;
	
			if( auto_loop_count )
			{
#if DEBUG_4
				cputs( "\r\npreparing to do first auto loop" );
#endif
				seq_ptr = start_auto_loop;
			}
			return TRUE;		
		}
		else
		{
			if( !auto_loop_count )
			{
#if DEBUG_4
				cputs( "\r\nfinished last auto loop" );
#endif
				return TRUE;
			}
			if( auto_loop_count-- )
			{
#if DEBUG_4
				cputs( "\r\npreparing to do next auto loop" );

#endif
				seq_ptr = start_auto_loop;
			}
			return TRUE;
		}
	}
	return FALSE;
}


unsigned char *start_loop;
Boolean	loop_trigger;




Boolean	handle_loop_command()
{
	if( s_event.data[2]==0 )
	{
		start_loop = seq_ptr;

		put_stat( "LOOP?", "LOOP?" );

#if DEBUG_3
		cputs( "\r\nstart loop found\r\n" );
#endif

		return TRUE;
	}
	if( s_event.data[2]==1 )
	{
#if DEBUG_3
			cputs( "\r\nLoop end found\r\n" );
#endif
		if( loop_trigger )
		{
#if DEBUG_3
			cputs( "\r\nEnd and Trigger\r\n" );
#endif
			if( start_loop!=0 )
			{
#if DEBUG_3
				cputs( "\r\nDoing loop\r\n" );
#endif
				seq_ptr=start_loop;

				put_stat( "LOOP?", "LOOP?" );
			}
			else
			{
#if DEBUG_3
				cputs( "\r\nLoop end but no beginning\r\n" );
#endif
			}

			loop_trigger=FALSE;
			return TRUE;
		}
		else
		{
#if DEBUG_3
			cputs("\r\nLoop end hit, no trigger\r\n" );
#endif			
	
			put_stat( "PLAYING", "PLAYING" );
			start_loop=0;
			return TRUE;
		}
	}
	return FALSE;
}

Boolean handle_pause_command()
{
	if( s_event.data[2]==0 )
	{
		put_stat( "*** PAUSE ***", "PAUSE" );
		clr_con();

		wait_for_play();
		put_stat( "PLAYING", "PLAYING" );
				
		clock_ticks=s_event.time;
		return TRUE;		
	}
	return FALSE;
}

Boolean	handle_page_command()
{
	select_new_page( s_event.data[2] );
	return TRUE;
}


Boolean	handle_internal_command( void )
{
	if( s_event.data[1]==60 )
		return handle_auto_loop_command();
	if( s_event.data[1]==61 )
		return handle_loop_command();
	if( s_event.data[1]==62 )
		return handle_pause_command();
	if( s_event.data[1]==63 )
		return handle_page_command();
	return FALSE;
}

Boolean play_midi( SONG *sng )
{
int light_status;
char light_note=-1;


	start_loop=0;
	loop_trigger=0;
	tempo_offset=0;
	start_auto_loop=0;
	auto_loop_valid=0;

#if SEND_CLOCK || SEND_INT_CLOCK
	last_sent_midi_clock_time = -1;
	midi_out( M_START );
#endif

#if SEND_INT_CLOCK
	clock_ticks_per_midi_clock = (sng->division * 2) /24;
#endif

	if( cfg.light_ch<0 || cfg.light_ch>15 )
		light_status=FALSE;
	else {
		light_status=TRUE;
		light_note=0x90+cfg.light_ch;
	}
	
	division=sng->division;
	seq_ptr=(unsigned char *)sng->location;
	sng_location=(unsigned char *)sng->location;
	clock_ticks=0;
	last_sent_time=0;
	cur_tempo=500000;	/* 120 beats per min */
	start_clock();
	
	do {
		read_event();
#ifdef SHOW_EVENTS
		display_event();
#else
		if( s_event.time>clock_ticks ) 
#endif
			if( !wait_midi() ) {
#if SEND_CLOCK || SEND_INT_CLOCK
				midi_out( M_STOP );
#endif
				unset_timer();
				unhang();
				return( FAILED );
			}
		/* at this point, the event that is in our buffer is
		** ready to be handled.
		*/
		
	/* check for meta-events */
		if( s_event.data[0]==0xff ) {
			if( s_event.data[1]==0x2f ) break;	/* end of track */
			if( s_event.data[1]==0x51 ) {
				set_tempo();
				continue;
			}
			/* 0x58 is time signature (not used) */
			continue;		/* not recognized */
		}
		
		/* check for lighting channel data */
		if( light_status )
			if( s_event.data[0]==light_note ) {
				light_midi( (int)s_event.data[1], (int)s_event.data[2] );
				continue;
			}

		/* check for internal commands */
		if( cfg.int_chan!=-1 )
		{
			if( s_event.data[0] == 0xb0 + cfg.int_chan )
				if( handle_internal_command() )
					continue;
		}


		send_event();
	} while( TRUE );
	
#if SEND_CLOCK || SEND_INT_CLOCK
	midi_out( M_STOP );
#endif
	unset_timer();
	unhang();
	return( OK );
}

#ifdef SHOW_EVENTS
static void display_event()
{

	sprintf( s, "\r\nCurrent Time=%ld\r\n",
		clock_ticks );
	cputs( s );
	sprintf( s, "\r\nEvent Read:\r\n\tTime: %ld\r\n\
\tlength: %d\r\n\tdata:%02x %02x %02x\r\n",
	s_event.time, (int)s_event.length,
	s_event.data[0], s_event.data[1], s_event.data[2] );
		
	cputs( s );

}
#endif

static void send_event()
{
register int i;
register unsigned char *data;

char buf[128];

#if 0
	sprintf( buf, "\r\nTime=%08ld %02x,%02x,%02x", 
			s_event.time,
			s_event.data[0],
			s_event.data[1],
			s_event.data[2] );
	cputs( buf );
#endif
	data=s_event.data;
	i=0;
	if( *data==0xf7 ) {
		data++; /* skip 0xf7.  this means escape code, send anything */
		i=1;
	}
	for( ; i<s_event.length; i++ ) {
		midi_out( *data++ );
	}
}


extern Boolean is_auto_playing;


static Boolean wait_midi() 
{

	do {

#if SEND_CLOCK
		long tick_temp = clock_ticks;

		if( tick_temp % ticks_per_midi_clock == 0 )
		{
			if( tick_temp != last_sent_midi_clock_time )
			{
				last_sent_midi_clock_time=tick_temp;
				midi_out( M_CLOCK );
			}
		}
#endif
		
		if( s_event.time > clock_ticks+15 )
		{
			draw_next_char();
		}

		get_action();
		if( cur_command.type!=ComNone ) switch( cur_command.type ) {

			case ComTempoUp:
				do_tempo_up();
				break;
			case ComTempoDown:
				do_tempo_down();
				break;

			case ComSkip:
				select_next_page();
				break;
			case ComBackup:
				select_prev_page();
				break;
			case ComPlay:

				if( start_loop )
				{
					loop_trigger=TRUE;
					put_stat( "LOOP ON","LOOP ON" );
					break;
				}
				else

				{
					unhang();
					return FAILED;
				}
				break;
			case ComStop:
				unhang();
				return( FAILED );

			case ComAutoPlay:
				is_auto_playing=FALSE;
				break;

			case ComUnhang:
				unhang();
				break;				

			case ComPause:
#if SEND_CLOCK || SEND_INT_CLOCK
				midi_out( M_STOP );
#endif
				put_stat( "*** PAUSE ***", "PAUSE" );
				clr_con();
				jk_clr_m_buf();
				unhang();

				wait_for_play();

				put_stat( "PLAYING", "PLAYING" );
#if SEND_CLOCK || SEND_INT_CLOCK
				midi_out( M_CONTINUE );
#endif
				clock_ticks=s_event.time;
				/* re-set our counter in case time was wasted */
				break;
			default:
				break;
           };           
    } while( s_event.time > clock_ticks );


    return( OK );              
}


