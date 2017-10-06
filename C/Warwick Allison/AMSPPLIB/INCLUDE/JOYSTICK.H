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

#ifndef _Joystick_h
#define _Joystick_h
//
//  Support for direct Joystick access.
//
#include <bool.h>

enum JoystickDirection {	J_0, J_U, J_D, J_UD, J_L, J_UL, J_DL, J_UDL,
							J_R, J_UR, J_DR, J_UDR, J_LR, J_ULR, J_DLR, J_UDLR };

class Joystick
{
public:
	Joystick(int port=1);
	~Joystick();

	JoystickDirection Way();

	bool Passive();
	bool Up();
	bool Down();
	bool Left();
	bool Right();

	// NOTE: Trigger 1 only works if joystick 0 is being used,
	//       otherwise it is diverted as RightButton of the mouse.
	//      (Blame Atari)
	//
	bool Trigger();

	// -1, 0, or +1 interpretation of joystick
	int X();
	int Y();

private:
	volatile int (*Flags);
    short port;
};


// Below is private


inline JoystickDirection Joystick::Way() { return *Flags&J_UDLR; }

inline bool Joystick::Passive() { return !*Flags; }
inline bool Joystick::Up() { return !!(*Flags&J_U); }
inline bool Joystick::Down() { return !!(*Flags&J_D); }
inline bool Joystick::Left() { return !!(*Flags&J_L); }
inline bool Joystick::Right() { return !!(*Flags&J_R); }

extern int XDif[16];
extern int YDif[16];

inline int Joystick::X() { return XDif[Way()]; }
inline int Joystick::Y() { return YDif[Way()]; }


#endif
