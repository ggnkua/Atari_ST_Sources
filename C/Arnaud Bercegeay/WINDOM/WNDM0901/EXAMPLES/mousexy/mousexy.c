/*
 *  Example of Timer event
 *	Dominique B‚r‚ziat 1997/2000.
 *	version 2.00
 */

#include <windom.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <tos.h>

#define MOUSEPOS 0x1
#define CLOCK	 0x2

typedef struct {
	unsigned year:	7;
	unsigned month:	4;
	unsigned day:	5;
	unsigned hour:	5;
	unsigned minute:6;
	unsigned second:5;
} BIOS_TIME;

char info[200];
unsigned int conf = MOUSEPOS;

void timer(WINDOW *win) {
	static int x=0;
	static int y=0;
	
	if( evnt.my != y || evnt.mx != x) {
		strcpy( info, "   ");
		if( conf & MOUSEPOS)
			sprintf( info,   "%s(%.3d,%.3d)    ", info, evnt.mx, evnt.my);
		if( conf & CLOCK) {
			long dum;
			BIOS_TIME time;
			
			dum = Gettime();
			*(long*)&time = dum;
			sprintf( info, "%s%.2d:%.2d", info, time.hour, time.minute);
		}
		WindSetStr( win, WF_INFO, info);
		x = evnt.mx;
		y = evnt.my;
	}
}

void ApTerm( void) {
	ApplExit();
	exit( 0);
}

void main(void) {
	WINDOW *win;
	int refresh=100,dum;
	int x=100,y=100;
	int xd, yd;
	int attrib = MOVER|NAME|INFO|CLOSER|SMALLER;
	
	ApplInit();
	
	/* La config */
	ConfInquire( "mousexy.timer", "%d", &refresh);
	if( ConfInquire( "mousexy.display.clock", "%b", &dum) == 1)
		set_bit( &conf, CLOCK, dum);
	if( ConfInquire( "mousexy.display.mouse", "%b", &dum) == 1)
		set_bit( &conf, MOUSEPOS, dum);
	ConfInquire( "mousexy.window", "%d,%d", &x, &y);
	wind_get( 0, WF_WORKXYWH, &xd, &yd, &dum, &dum);
	x = max(x,xd);
	y = max(y,yd);

	/* La fenetre */
	win = WindCreate( attrib, app.x, app.y, app.w, app.h);
	EvntAttach( win, WM_XTIMER, timer);
	EvntAttach( NULL, AP_TERM, ApTerm);
	WindOpen(win, x, y, 120*((conf & MOUSEPOS)?1:0)+90*((conf & CLOCK)?1:0), 0);
	WindSetStr( win, WF_NAME, "MouseXY 2.00 by D.B‚r‚ziat");
	evnt.timer = refresh;

	/* les evenements */
	while( 1)
		EvntWindom( MU_MESAG|MU_TIMER);
}
