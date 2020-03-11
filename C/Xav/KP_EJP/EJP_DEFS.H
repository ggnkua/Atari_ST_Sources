/*
**	ejp_defs.h
**	==========
**
**	By Xav
**	======
**
**
**	Contains structure definitions for the following:-
**
**		Joypads	(JOYPAD)
**
*/



/*
**	This structure makes it easier to deal with the joypads, as
**	you simply call a function to fill it, then test the variables
**	you're interested in. There's also space for a copy of the old
**	values, as this can often be useful to see if buttons have
**	actually changed state.
*/

struct JOYPAD
{
	short UP;
	short DOWN;
	short LEFT;
	short RIGHT;
	short FIRE_A;
	short FIRE_B;
	short FIRE_C;
	short PAUSE;
	short OPTION;
	short NUMPAD_0;
	short NUMPAD_1;
	short NUMPAD_2;
	short NUMPAD_3;
	short NUMPAD_4;
	short NUMPAD_5;
	short NUMPAD_6;
	short NUMPAD_7;
	short NUMPAD_8;
	short NUMPAD_9;
	short NUMPAD_STAR;
	short NUMPAD_HASH;
	
	short OLD_UP;
	short OLD_DOWN;
	short OLD_LEFT;
	short OLD_RIGHT;
	short OLD_FIRE_A;
	short OLD_FIRE_B;
	short OLD_FIRE_C;
	short OLD_PAUSE;
	short OLD_OPTION;
	short OLD_NUMPAD_0;
	short OLD_NUMPAD_1;
	short OLD_NUMPAD_2;
	short OLD_NUMPAD_3;
	short OLD_NUMPAD_4;
	short OLD_NUMPAD_5;
	short OLD_NUMPAD_6;
	short OLD_NUMPAD_7;
	short OLD_NUMPAD_8;
	short OLD_NUMPAD_9;
	short OLD_NUMPAD_STAR;
	short OLD_NUMPAD_HASH;
};

