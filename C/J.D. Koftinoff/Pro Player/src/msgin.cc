/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include "perform.h"

#include "midstat.h"

struct PERFMIDIMessage 
{
	uchar length,status,byte1,byte2;
};

#if 0
MIDIParser the_mparser;

void jk_clr_m_buf()
{
	while( midi_stat() )
		(void)the_mparser.Parse( midi_in() );
	the_mparser.ResetParser();
}


short jk_msg_in( unsigned char *buffer, short max_len )
{
	PERFMIDIMessage m;
	
	while( midi_stat() )
	{
		m=the_mparser.Parse( midi_in() );
		if( m.length>1 )
		{
			buffer[0]=m.status;
			buffer[1]=m.byte1;
			buffer[2]=m.byte2;
			return m.length;
		}
	}
	return 0;
}

#else

static void midi_rx_parser( short data );

static PERFMIDIMessage m;
static int flag=0;


static int msgin( PERFMIDIMessage a )
{
	m=a;
	flag=TRUE;
	return TRUE;
}

short jk_msg_in( unsigned char *buffer, short max_len )
{
	short byte;
	
	
	while( midi_stat() )
	{
		byte=midi_in()&0xff;
		flag=0;
		midi_rx_parser( byte );
		if( flag )
		{
			buffer[0]=m.status;
			buffer[1]=m.byte1;
			buffer[2]=m.byte2;
			return m.length;
		}
	}
	return 0;
}


void jk_clr_m_buf()
{
	while( midi_stat() )
		midi_rx_parser(	midi_in() );
	
}


static void midi_rx_parser( short data )
{
	static PERFMIDIMessage m = { 0, 0, 0, 0 };
	static short state=0;
	PERFMIDIMessage sys;
	register short stat;


	// here is the state machine which parses the MIDI bytes.
	// first here are the bytes that cause the state machine to
	// jump into state 0 (initial state), which causes the
	// machine to ignore all data until next status byte.
		
			
	if( data&0x80 )				// any type of status message?
	{
		stat=data&0xf0;
		
		if( stat==0xf0 )		// any type of system message?
		{
			if(  data==M_RESET 	// system reset
			  || data==M_SENSE	// not sense but overflow 
			//  || data==M_EXCL	// start of sys-ex
			//  || data==M_EOX	// end of sys-ex
				)
			{
				state=0;
				m.length=0;
				m.status=0;	// reset running status

				sys.length=1;
				sys.status=data;
					
				msgin(sys);

				return;
			}
			if(  data==M_START	// any clock messages?
			  || data==M_STOP
			  || data==M_CONTINUE
			  || data==M_CLOCK
			  || data==M_TUNE	// or tune requests?
				)
			{
				// we use sys because these msgs may
				// interrupt long message

				sys.length=1;
				sys.status=data;
				
				msgin(sys);
				
				return;
			}
		if( data==M_SPP			// song position pointer?
			)
		{
			state=3;		// means we expect two more 
			m.length=1;
			m.status=data;
			return;
		}
		if(	data==M_SONG		// song number select?
			)
		{
			state=2;		// means we expect one more 
			m.length=1;
			m.status=data;
			return;
		}
			
			// if there is anything else, cause a reset.
			// this means communications is really fucked
			
			state=0;
			m.length=0;
			m.status=0;		// reset running status
			return;
		}
		
		// ok, so it wasn't a system message. it was a simple
		// real time channel message. how long is it going to be?
		
		
		// here are all the 3 byte messages.
		
		if(	stat==M_NOTE_OFF	
		    ||	stat==M_NOTE_ON
		    ||	stat==M_P_AFTER
		    ||	stat==M_CONTROL
		    || 	stat==M_BENDER
		  )
		{
			state=3;
			m.status=data;
			return;
		}
		
		// here are the two byte messages:
		
		if(	stat==M_PG
		    ||	stat==M_C_AFTER
			)
		{
			state=2;
			m.status=data;
			return;
		}
		
		// if there is anything else, cause a reset.
		// this means communications is really fucked
		
		state=0;
		m.length=0;
		m.status=0;	// reset running status
		return;
	}
	else	// here comes data bytes.
	{
		if( state==0 )	// we don't do anything at all.
		{
			return;
		}
		if( state==3 )	// we must read first data byte of 3 byte msg
		{
			m.byte1=data;
			state=4; 	// go into state 4 to read second byte
			return;
		}
		if( state==2 )	// we gotta read single data byte of 2 byte msg
		{
			m.length=2;
			m.byte1=data;
			
			state=2;	// keep running status active
			msgin(m);
	
			return;
		}
		if( state==4 )
		{
			m.length=3;
			m.byte2=data;

			state=3;	// keep running status active	
			msgin(m);
	
			return;
		}
	}

}

#endif

