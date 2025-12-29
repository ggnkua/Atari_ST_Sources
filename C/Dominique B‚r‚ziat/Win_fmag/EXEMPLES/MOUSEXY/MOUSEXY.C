/*
 *	Exemple d'utilisation du timer:
 *	petit programme affichant dans une fenˆtre la
 *	position de la souris.
 *	Dominique B‚r‚ziat 1997.
 */

#include <windom.h>
#include <stdio.h>

char info[100];

void timer(WINDOW *win)
{
	static int x=0;
	static int y=0;
	
	if( evnt.my != y || evnt.mx != x) {
		sprintf( info, "   x = %-3d | y = %-3d", evnt.mx, evnt.my);
		WindSet( win, WF_INFO, info);
		x = evnt.mx;
		y = evnt.my;
	}
}

int main(void)
{
	WINDOW *win;
	
	ApplInit();
	
	
	win = WindCreate( MOVER|NAME|INFO|CLOSER|SMALLER, app.x, app.y, app.w, app.h);
	win->timed = timer;
	WindOpen(win, 100, 100, 180, 0);
	WindSet( win, WF_NAME, "Mouse position");
	evnt.lo_timer = 100;
	evnt.hi_timer = 0;

	do {
		EvntWindom( MU_MESAG|MU_TIMER);
	} while( !(wglb.first == NULL || evnt.buff[0] == AP_TERM));

	ApplExit();
	return 0;
}