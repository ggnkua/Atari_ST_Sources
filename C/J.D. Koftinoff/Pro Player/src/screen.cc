/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include "screen.hh"
#include <joystick.hh>



static unsigned short Screen::new_colors[4] = 
		{ 0x0000, 0x0777, 0x0730, 0x047 };


Screen::Screen( MIDIPort *midi_port, Configuration *cfg ) : creekvt52( 2 )
{
	register unsigned short i;

	MIDI=midi_port;	
	orig_rez=Getrez();
	
	for( i=0; i<16; i++ )
	{
		saved_colors[i]=Setcolor( i, -1 );
	}
	
	if( orig_rez==0 )
		Setscreen( -1L, -1L, 1 );
	
	for( i=0; i<4; i++ )
		Setcolor( i, new_colors[i] );
	
	char_col( 1 );
	back_col( 0 );
	clear_screen();
	cursor_off();
	
	theMIDIScrn = new MIDIScrn( MIDI );
	theMIDIScrn->Init( cfg );

	use_joystick=cfg->Get( CFG_USE_JOYSTICK );
	if( use_joystick==1 )
		JoyInit();

	ctrl_channel=cfg->Get( CFG_CTRL_CHANNEL );
	ctrl_type=cfg->Get( CFG_CTRL_TYPE );
}


Screen::~Screen()
{
	if( use_joystick==0 )
		JoyKill();
	
	delete theMIDIScrn;
	
	Setscreen( -1L, -1L, orig_rez );
	
	for( register short i=0; i<16; i++ )
	{
		Setcolor( i, saved_colors[i] );
	}
	cursor_on();
}





Screen::Center( char *text, unsigned short line )
{
	unsigned short len=strlen( text );
	
	goto_xy( 40-len/2, line );
	put( text );
}


Screen::Status( char *long_text, char *short_text )
{
	goto_xy( 0, 23 );
	clear_line();
	
	char_col(2);
	Center( long_text, 23 );
	char_col(1);
	
	theMIDIScrn->Send( long_text, short_text );

}


Screen::Inverse()
{
	reverse_on();
}


Screen::Normal()
{
	reverse_off();
}


Screen::Output( char *text, unsigned short x, unsigned short y )
{
	goto_xy( x, y );
	put( text );
}


Command Screen::KeyCommand( *param )
{
	if( istat() )
	{
		long key=get();
		
		switch( key&0x7f )
		{
		case 'A'-0x40:
			return ComStop;
		case 'G'-0x40:
			return ComExit;
		case 'U'-0x40:
			return ComUnhang;
		case ' ':
			return ComPlay;
		default:
			return ComNone;
		}
	}
	return ComNone;
}

Command Screen::MIDICommand( *param )
{
	MIDIMessage m=MIDI->PollInput();
	
	if( ctrl_type == CTRL_TYPE_NONE )
		return ComNone;
	
	if( m.length>1 )
	{
		// MIDI ctrl should be in a different class
	}
	return ComNone;
}

Command Screen::JoyCommand( int *param )
{
	if( !use_joystick )
	{
		return ComNone;
	}
	return ComNone;
}


Command Screen::GetCommand( int *param )
{
	Command c;
	
	c=MIDICommand( param );
	
	if( c==ComNone )
		c=KeyCommand( param );
	if( c==ComNone )
		c=JoyCommand( param );
		
	return c;
}

