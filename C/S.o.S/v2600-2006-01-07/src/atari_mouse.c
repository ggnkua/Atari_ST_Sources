/*****************************************************************************
Author     : Peter Persson (IKBD routines by Patrice Mandin)
Description: Atari Falcon-specific mouse stuff
Version    : 0.0.1 (2006-01-07)
******************************************************************************/


#include "config.h"
#include "options.h"
#include "ikbd.h"

extern int moudrv_x, moudrv_y, moudrv_but;

void moudrv_init(void)
{
	moudrv_x=160;
	moudrv_y=100;
}

void moudrv_close(void) {}

void moudrv_read(void)
{
	moudrv_x=+Ikbd_mousex;
	moudrv_y=+Ikbd_mousey;
	moudrv_but=Ikbd_mouseb & 0x03;

	if(moudrv_x<0) moudrv_x=0;
	if(moudrv_y<0) moudrv_y=0;
	if(moudrv_x>319) moudrv_x=319;
	if(moudrv_y>199) moudrv_y=199;

}

void moudrv_update(void) {}

