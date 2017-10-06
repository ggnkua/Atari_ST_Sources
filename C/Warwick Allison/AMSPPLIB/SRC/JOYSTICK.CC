//////////////////////////////////////////////////////////////////////////////
//
//  This file is part of the Atari Machine Specific Library,
//  and is Copyright 1992 by Warwick W. Allison.
//
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.
//
//////////////////////////////////////////////////////////////////////////////

#include "Joystick.h"
#include "MousePosition.h"
#include "JoyISR.h"
#include <osbind.h>

// TERMINATION code:

// used to ensure MyJoystickRestorer is linked in if possibly necessary
#define EnsureRestoration { volatile JoystickRestorer* x=&MyJoystickRestorer; }

const char JoyJoyString[]="\024";
const char MouseJoyString[]="\010";

class JoystickRestorer
{
public:
	JoystickRestorer() {
		_KBDVECS * KV=Kbdvbase();
		OrigJoy=KV->joyvec;
	}
	~JoystickRestorer() {
		_KBDVECS * KV=Kbdvbase();
		KV->joyvec=OrigJoy;
		Ikbdws(0,MouseJoyString);
	}
private:
	void (*OrigJoy)(void*);
};

static JoystickRestorer MyJoystickRestorer;



/* GLOBAL */ volatile int JoyFlags[2]={0,0};

int XDif[16] = { 0,0,0,0,-1,-1,-1,-1,1,1,1,1,0,0,0,0 };
int YDif[16] = { 0,-1,1,0,0,-1,1,0,0,-1,1,0,0,-1,1,0 };

static int Enabled[2];
static void (*OldJoy)(void*);
static bool joyusemouse=TRUE;

Joystick::Joystick(int Port=1) : port(Port)
{
	EnsureRestoration;

	if (port==0 || port==1) {
		if (!Enabled[port]) {
			if (!Enabled[1-port]) {
				// Very first!
				_KBDVECS * KV=Kbdvbase();
				OldJoy=KV->joyvec;
				KV->joyvec=JoyISR;
			}
			if (port==0) {
				Ikbdws(0,JoyJoyString);
				joyusemouse=FALSE;
			}
		}

		Enabled[port]++;
		Flags=&JoyFlags[port];
	} else {
		// What shall we do with the drunken sailor?
	}
}

Joystick::~Joystick()
{
	Enabled[port]--;

	if (!Enabled[port]) {
		if (!Enabled[1-port]) {
			// Very last!
			_KBDVECS * KV=Kbdvbase();
			KV->joyvec=OldJoy;
		}
		if (port==0) {
			Ikbdws(0,MouseJoyString);
			joyusemouse=TRUE;
		}
	}
}

bool Joystick::Trigger()
{
 	return (port && joyusemouse) ? Mouse.RightButton() : bool(!!(*Flags&128));
}
