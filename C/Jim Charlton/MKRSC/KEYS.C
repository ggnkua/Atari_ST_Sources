#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"


int do_update(keycode,keymod)
    int keycode,keymod;
{  
	int cx,cy,cw,ch;
	char *dadr2;
	int order[MAXONUM], i, num;
	int message[8];
	
	switch(keycode) {
			case 0x1000	:	message[3] = FILE;
							message[4] = QUIT;
							do_menu(message);
							break;
			case 0x2E00	:	message[3] = EDIT;
							message[4] = COPY;
							do_menu(message);
							break;
			case 0x2D00	:	message[3] = EDIT;
							message[4] = CUT;
							do_menu(message);
							break;
			case 0x2F00	:	message[3] = EDIT;
							message[4] = PASTE;
							do_menu(message);
							break;
			case 0x1200	:	message[3] = EDIT;
							message[4] = ERASE;
							do_menu(message);
							break;
			case 0x3100	:	message[3] = CHOOSE;
							message[4] = NAM;
							do_menu(message);
							break;
			case 0x1F00	:	message[3] = CHOOSE;
							message[4] = SORT;
							do_menu(message);
							break;
			case 0x1300	:	message[3] = WINDOWS;
							message[4] = 1;
							do_menu(message);
							break;
			 		}
}   
