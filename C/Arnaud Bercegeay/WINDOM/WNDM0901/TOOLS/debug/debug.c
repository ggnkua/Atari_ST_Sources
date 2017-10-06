/*
 *	Programme affichant les messages
 *	de debuggage dans sa ligne d'info
 */

#include <string.h>
#include <stdio.h>
#include <windom.h>

int status = 0;	/* Normal,  1 wait*/
char normal[] = "Mode: normal";
char wait[] = "Mode: wait";
char title[] = "Debug 1.01 by D.B‚r‚ziat";
char title2[]= "Press any key ...";
char info[] = "Status: normal";

void timer( WINDOW *win) {
	WindSet( win, WF_INFO, info);
}

void key( WINDOW *win) {
	switch( evnt.keybd & 0x00FF) {
	case 'n':
	case 'N':
		status = 0;
		WindSet( win, WF_INFO, normal);
		break;
	case 'w':
	case 'W':
		status = 1;
		WindSet( win, WF_INFO, wait);
		break;
	}
}

WINDOW *Create( void) {
	WINDOW *win;
	
	win = WindCreate( NAME|MOVER|SMALLER|CLOSER|INFO,
					  app.x, app.y, app.w, app.h);
	WindSet( win, WF_NAME, title);
	WindSet( win, WF_INFO, normal);
	EvntAttach( win, WM_XTIMER, timer);
	EvntAttach( win, WM_XKEYBD, key);
	return win;
}

void Open( WINDOW *win) {
	int x, y, w, h;

	if( win -> status & WS_ICONIFY) {
		WindGet( win, WF_UNICONIFY, &x, &y, &w, &h);
		WindSet( win, WF_UNICONIFY, x, y, w, h);
	} else if( win -> status & WS_OPEN) /* D‚ja ouverte */
		WindSet( win, WF_TOP);
	else {
		WindGet( win, WF_PREVXYWH, &x, &y, &w, &h);
		WindOpen( win, x, y, w, h);
	}
}

int main( void) {
	int end = 0, first = 1;
	WINDOW *win = NULL;
	char debug[255];
	
	ApplInit();
	win = Create();
	if(_app) {
		WindOpen( win, app.x, app.y, app.w, 0);
		first = 0;
	}
	evnt.lo_timer = 30000;
	do {
		if( EvntWindom( MU_MESAG|MU_TIMER|MU_KEYBD) & MU_MESAG) {
			switch( evnt.buff[0]) {
			case AP_TERM:
				end = 1;
				break;
			case AC_OPEN:
				if( first)
					Open( win);
				else  {
					WindOpen( win, app.x, app.y, app.w, 24);
					first = 0;
				}
				break;
			case AC_CLOSE:
				WindClose( win);
				break;
			/* message de d‚bug */
			case AP_DEBUG:
				if(app.aes4 & AES4_APPSEARCH) {
					char name[9];
					
					ApplName(name, evnt.buff[1]);
					sprintf( debug, "From %s: ", name);
				}
				else
 					sprintf( debug, "From %d: ", evnt.buff[1]);
				strcat( debug, *(char**)&evnt.buff[4]);
				if( first)
					Open( win);
				else  {
					WindOpen( win, app.x, app.y, app.w, 0);
					first = 0;
				}
				WindSet( win, WF_INFO, debug);
				if( status == 1) {
					WindSet( win, WF_TOP, win->handle);
					WindSet( win, WF_NAME, title2);
					evnt_keybd();
					WindSet( win, WF_NAME, title);
				}
				ApplWrite( evnt.buff[1], AP_DEBUG, 0);
				if( status == 1) 
					ApplWrite( evnt.buff[1], WM_TOPPED, evnt.buff[3]);
				break;
			}
		}
	} while( !end);
	ApplExit();
	return 0;
}
