/*
 *	Rechager la config
 *	-> tirez l'appli sur l'icone (en multitƒche)
 */
#include <aes.h>
#include <string.h>
#include <stdio.h>

int main( int argc, char *argv[]) {
	int apid = appl_init();
	if( argc>1) {
		char appli[9], *p;
		int id, msg[8];
		
		p = strrchr( argv[1], '.');
		if( p ) *p = '\0';
		p = strrchr( argv[1], '\\');
		if( p ) p ++;
		else	p = argv[1];
		sprintf( appli, "%-8s", strupr( p));
		id = appl_find( appli);
		msg[0] = /*WM_LOADCONF*/ 0x4403;
		msg[1] = apid;
		msg[2] = 0;
		appl_write( id, 16, msg);
		evnt_timer( 500, 0);
	}
	appl_exit();
	return 0;
}