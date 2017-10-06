#include <stdio.h>
#include <windom.h>
#include <wintimer.h>

char txt[80];

void Timer1000( long time, WINDOW *win) {	
	if( win) {
		sprintf( txt, "timer=%ld", time);
		WindSet( win, WF_INFO, txt);
	}
}

void Timer2000( long time, WINDOW *win) {	
	if( win) {
		sprintf( txt, "timer=%ld", time);
		WindSet( win, WF_INFO, txt);
	}
}

void TimerDesktop( long time) {	
	sprintf( txt, "timer=%ld", time);
	v_gtext( app.handle, app.x, app.y+40, txt);
}

int main( void) {
	WINDOW *win;
	ApplInit();

	/* TimerInit() sets the evnt.timer value */
	TimerInit( 100);

	/* first window */
	win = WindCreate( NAME+INFO+CLOSER+MOVER, app.x, app.y, app.w, app.h);
	WindOpen( win, -1, app.y, 400, 50);
	TimerAttach( win, 1000, Timer1000);
	
	/* second window */
	win = WindCreate( NAME+INFO+CLOSER+MOVER, app.x, app.y, app.w, app.h);
	WindOpen( win, -1, app.y+50, 400, 50);
	TimerAttach( win, 1000, Timer1000);

	/* global */
	TimerAttach( win, 2000, Timer2000);
	TimerAttach( NULL, 100, TimerDesktop);
		
	while( wglb.first)
		EvntWindom( MU_MESAG + MU_TIMER);
	
	TimerExit();
	ApplExit();
	return 0;
}

