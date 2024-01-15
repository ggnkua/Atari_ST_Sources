/*****************************************************************************
Author     : Peter Persson (IKBD routines by Patrice Mandin)
Description: Atari Falcon-specific joystick stuff
Version    : 0.0.1 (2006-01-07)
******************************************************************************/

#include "ikbd.h"
#include "types.h"
#include "mint/falcon.h"

#define LJOYMASK 0x01
#define RJOYMASK 0x02
#define UJOYMASK 0x04
#define DJOYMASK 0x08
#define B1JOYMASK 0x10
#define B2JOYMASK 0x20

int
get_realjoy (int stick)
{
	int retval = 0;

	if (Ikbd_joystick & 0x01) retval |= UJOYMASK;
	if (Ikbd_joystick & 0x02) retval |= DJOYMASK;
	if (Ikbd_joystick & 0x04) retval |= LJOYMASK;
	if (Ikbd_joystick & 0x08) retval |= RJOYMASK;
	if (Ikbd_joystick & 0x80) retval |= B1JOYMASK;

	return (retval);
}

void update_realjoy (void) {}
void calibrate_realjoy (int stick) {}
void init_realjoy (void) {}
void close_realjoy (void) {}
