/*
    Copyright (c) 2005 Peter Persson
    IKBD stuff by Patrice Mandin

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/*
    Changelog
    2005-11-20	Created (Peter Persson)
    2005-11-29	Corrected joypad bug (Peter Persson)
    2005-12-03	Rewrote joypad handling (Peter Persson)
    2006-01-21	Added keys for frameskip +/- (Peter Persson)
               Added keyboard debounce for UI (stolen from DOS-port)
    2006-02-06 Added keys for state load/save (Peter Persson)
*/

#include "osd.h"

uint16 *jp_mask = (uint16 *)0xFF9202;
uint16 *jp_buttons = (uint16 *)0xFF9200;
uint16 *jp_keys = (uint16 *)0xFF9202;
uint16 jp_dir;
uint16 jp_but;

void input_open()
{
	/* Setup IKBD handling */

	memset(Ikbd_keyboard, 0, 128);
	Ikbd_mousex = Ikbd_mousey = Ikbd_mouseb = Ikbd_joystick = 0;

	Supexec(IkbdInstall);
}


void input_close()
{
	/* Restore IKBD stuff */

	Supexec(IkbdUninstall);
}

/* Debounce keyboard buttons */
int check_key(int code)
{
    static int lastpressed = 0;

    if((!Ikbd_keyboard[code]) && (lastpressed == code))
        lastpressed = 0;

    if((Ikbd_keyboard[code]) && (lastpressed != code))
    {
        lastpressed = code;
        return 1;
    }

    return 0;
}


/* Poll player controls and user interface */

int input_poll()
{
	input.system    = 0;
	input.pad[1]    = 0;
	
	/* poll IKBD-joystick (player 1) */	
	input.pad[0] = Ikbd_joystick & 0x0F;
	if (Ikbd_mouseb & 0x01) input.pad[0] |= INPUT_BUTTON1;

	/* poll joypads (both players) */
	*jp_mask = 0xFFEE;
	jp_but = *jp_buttons;
	if (!(jp_but & 0x0001))					/* Pause PL1 */
		input.system |= (IS_GG) ? INPUT_START : INPUT_PAUSE;
	if (!(jp_but & 0x0004))					/* Pause PL2 */
		input.system |= (IS_GG) ? INPUT_START : INPUT_PAUSE;

	if (!(jp_but & 0x0002))	input.pad[0] |= INPUT_BUTTON1;	/* button A PL1 */
	if (!(jp_but & 0x0008))	input.pad[1] |= INPUT_BUTTON1;	/* button A PL2 */

	jp_dir = *jp_keys;
	if (!(jp_dir & 0x0100))	input.pad[0] |= INPUT_UP;	/* Up     PL1   */
	if (!(jp_dir & 0x0200))	input.pad[0] |= INPUT_DOWN;	/* Down   PL1   */
	if (!(jp_dir & 0x0400))	input.pad[0] |= INPUT_LEFT;	/* Left   PL1   */
	if (!(jp_dir & 0x0800))	input.pad[0] |= INPUT_RIGHT;	/* Right  PL1   */
	if (!(jp_dir & 0x1000))	input.pad[1] |= INPUT_UP;	/* Up     PL2   */
	if (!(jp_dir & 0x2000))	input.pad[1] |= INPUT_DOWN;	/* Down   PL2   */
	if (!(jp_dir & 0x4000))	input.pad[1] |= INPUT_LEFT;	/* Left   PL3   */
	if (!(jp_dir & 0x8000))	input.pad[1] |= INPUT_RIGHT;	/* Right  PL4   */

	*jp_mask = 0xFFDD;
	if (!(*jp_buttons & 0x0002))	input.pad[0] |= INPUT_BUTTON2;	/* button B PL1 */
	if (!(*jp_buttons & 0x0008))	input.pad[1] |= INPUT_BUTTON2;	/* button B PL2 */

	/* poll keyboard (player 1) */
	if(Ikbd_keyboard[0x48]) /* Arrow UP */
		input.pad[0] |= INPUT_UP;
	if(Ikbd_keyboard[0x50]) /* Arrow DOWN */
		input.pad[0] |= INPUT_DOWN;
	if(Ikbd_keyboard[0x4b]) /* Arrow LEFT */
		input.pad[0] |= INPUT_LEFT;
	if(Ikbd_keyboard[0x4d]) /* Arrow RIGHT */
		input.pad[0] |= INPUT_RIGHT;
	if(Ikbd_keyboard[0x1f]) /* S */
		input.pad[0] |= INPUT_BUTTON1;
	if(Ikbd_keyboard[0x1e]) /* A */
		input.pad[0] |= INPUT_BUTTON2;

	/* poll keyboard (player 2) */
	if(Ikbd_keyboard[0x68]) /* Keypad 8 */
		input.pad[1] |= INPUT_UP;
	if(Ikbd_keyboard[0x6E]) /* Keypad 2 */
		input.pad[1] |= INPUT_DOWN;
	if(Ikbd_keyboard[0x6a]) /* Keypad 4 */
		input.pad[1] |= INPUT_LEFT;
	if(Ikbd_keyboard[0x6c]) /* Keypad 6 */
		input.pad[1] |= INPUT_RIGHT;
	if(Ikbd_keyboard[0x6d]) /* Keypad 1 */
		input.pad[1] |= INPUT_BUTTON1;
	if(Ikbd_keyboard[0x6f]) /* Keypad 3 */
		input.pad[1] |= INPUT_BUTTON2;
		
		
	/* poll keyboard (system) */
	if(Ikbd_keyboard[0x1C] || Ikbd_keyboard[0x39]) /* Return or Space */
		input.system |= (IS_GG) ? INPUT_START : INPUT_PAUSE;
	if(Ikbd_keyboard[0x0F]) /* TAB */
		input.system |= INPUT_RESET;
	if(Ikbd_keyboard[0x53]) /* Delete */
		system_reset();


	/* poll user interface */

	if(check_key(0x3B)) frameskip++;								/* F1 - increase fskip */
	if(check_key(0x3C))	{ frameskip--; if(frameskip==0) frameskip = 1; }	/* F2 - decrease fskip */
	if(check_key(0x01))	return(1); /* ESCAPE */

	/* State save/load keys */
	if(check_key(0x3F)) save_state();	/* F5 = save state */
	
	if(check_key(0x02)) state_slot = 1;
	if(check_key(0x03)) state_slot = 2;
	if(check_key(0x04)) state_slot = 3;
	if(check_key(0x05)) state_slot = 4;
	if(check_key(0x06)) state_slot = 5;
	if(check_key(0x07)) state_slot = 6;
	if(check_key(0x08)) state_slot = 7;
	if(check_key(0x09)) state_slot = 8;
	if(check_key(0x0A)) state_slot = 9;
	if(check_key(0x0B)) state_slot = 0;

	if(check_key(0x40)) load_state(); /* F6 = load state */

	return(0);
}