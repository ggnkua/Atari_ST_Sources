

#pragma once

#include <creek.hh>
#include "cfg_type.h"
#include "midiscrn.hh"


enum Command
{
	ComNone,
	ComHelp,
	ComAutoPlay,
	ComPlay,
	ComStop,
	ComPause,
	ComSkip,
	ComBackup,
	ComSelect,
	ComUnhang,
	ComReload,
	ComNewSet,
	ComExit
};


class Screen : public creekvt52 
{
private:
	unsigned short	saved_colors[16];
	static unsigned short new_colors[4];
	unsigned short	orig_rez;
	unsigned short	use_joystick;
	
	unsigned short	ctrl_channel;
	unsigned short	ctrl_type;

	MIDIPort *MIDI;
	MIDIScrn *theMIDIScrn;
	
protected:
	Command KeyCommand( int *param );
	Command MIDICommand( int *param );
	Command JoyCommand( int *param );
public:
	Screen( MIDIPort *, Configuration *cfg );
	~Screen();

	Center( char *text, unsigned short line );
	Status( char *long_text, char *short_text );
	Inverse();
	Normal();
	Output( char *text, unsigned short x, unsigned short y );
	
	Command GetCommand( int *param );
};


