/* This module performs two functions allows the user to setup a custom
   keyboard upon entry into the program. And, reset back to the BIOS 
   default keyboard when exiting the program.
*/
#include <osbind.h>
#include <xbios.h>
#include "keyboard.h"

	struct keytbl *kp;

set_user_keyboard() {
	
	kp = Keytbl(normal,shifted,capslock);
	return;
}

reset_keyboard() {
	
	Bioskeys();
	return;
}
