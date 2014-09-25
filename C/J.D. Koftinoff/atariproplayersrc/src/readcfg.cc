/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 


#include "ply_defs.h"
#include "cfg_type.h"
#include "jk_term.h"

extern CFG cfg;


void ReadConfiguration()
{
	long val;
	Configuration *c = new Configuration( CFG_TYPE );
	
	if( !c->Load( CFG_FILE_NAME ) )
		c->Load( "\\"CFG_FILE_NAME );
	
	cfg.cfg_type=TCFG1;
	
	if( c->Get( CFG_CTRL_TYPE, &val ) )
		cfg.ctrl_type=val;

	if( c->Get( CFG_CTRL_CHANNEL, &val ) )
		cfg.ctrl_chan=val;
	
	if( c->Get( CFG_DISPLAY_TYPE, &val ) )
		cfg.disp_type=val;
	
	if( c->Get( CFG_DISPLAY_CHANNEL, &val ) )
		cfg.disp_chan=val;
	
	if( c->Get( CFG_LIGHT_CHANNEL, &val ) )
		cfg.light_ch=val;

	if( c->Get( CFG_MIDI_THRU, &val ) )
		cfg.thru=val;
	
	if( c->Get( CFG_INTERNAL_CHANNEL, &val ) )
		cfg.int_chan=val;

	if( c->Get( CFG_WAIT_AFTER_EXCL, &val ) )
		cfg.wait_after_excl=val;

	if( c->Get( CFG_USE_JOYSTICK, &val ) )
		cfg.use_joy=val;

	if( c->Get( CFG_LOAD_SINGLE_SONGS, &val ) )
		cfg.load_single=val;

	if( c->Get( CFG_PAUSE_AFTER_LOAD, &val ) )
		cfg.pause_after_load=val;

		
	delete c;

}


