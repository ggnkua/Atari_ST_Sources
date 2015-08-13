/* Joystick.hh
** By Jeff Koftinoff
** March 1, 1990
**
** definitions for use with my joystick library.
*/

#ifndef _H_JOYSTICK
#define _H_JOYSTICK

typedef struct
{
	unsigned int 	up 	: 1,
			down 	: 1,
			left 	: 1,
			right 	: 1,
			fire 	: 1;
} JoyStickState;

void JoyInit( void );
void JoyKill( void );

JoyStickState JoyGet( int joystick_num  );

#endif


