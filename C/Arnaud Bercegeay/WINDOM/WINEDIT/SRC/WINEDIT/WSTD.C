/*
 *	Edition de texte
 *  D.B‚r‚ziat 1998
 *	Interfacage avec WinDom de la librairie TextEdit
 *	
 *	Routines standards, suceptible d'ˆtre modifi‚es
 *	par le d‚veloppeur, parce que elles ne pr‚voient
 *	pas tous les cas.
 *	Le d‚veloppeur s'en inspirera pour ‚crire les
 *	siennes.
 */
#include <string.h>
#include <scancode.h>
#include <windom.h>
#include <winedit.h>

/*
 *	Routine bouton souris standard
 */

void wedit_stdbut( WINDOW *win) {
	int flags;
	
	WeditGet( win, WES_FLAGS, &flags);
	graf_mkstate( &evnt.mx, &evnt.my, &evnt.mbut, &evnt.mkstate);
	if( evnt.mbut)
		wedit_selectbloc( win);
	else {
		if( flags & BLOC) {
			wedit_draw_bloc( win, NULL, NULL);
			WeditSet( win, WES_FLAGS, BLOC, FLG_INV);
		}
		wedit_set_cursor( win, evnt.mx, evnt.my);
	}
}

/*
 * Routine clavier standard.
 */

char stdkey[] = "abcdefghijklmnopqrstuvwxyz"
				"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
				"‚Šˆ‰‡€¡‹Œ—–£… ƒ„‘"
				"0123456789"
				" &\"'(İ!)-_`œ^[]*{},?;.:/=+%\#|@~<>";


void wedit_stdkey( WINDOW *win) {
	int c = evnt.keybd & 0x00FF;
	int scan = evnt.keybd >> 8;
	int oldflags, flags;

	WeditGet( win, WES_FLAGS, &oldflags);
	
	switch( scan) {
	case SC_RETURN:
	case SC_ENTER:
		if( !(oldflags  & READONLY)) 
			wedit_newline( win);
		break;
	case SC_LFARW:
		wedit_curs_left( win);
		break;
	case SC_RTARW:
		wedit_curs_right( win);
		break;
	case SC_UPARW:
		if( evnt.mkstate & (K_LSHIFT|K_RSHIFT))
			wedit_curs_page_up( win);
		else
			wedit_curs_up( win);
		break;
	case SC_DWARW:
		if( evnt.mkstate & (K_LSHIFT|K_RSHIFT))
			wedit_curs_page_down( win);
		else
			wedit_curs_down( win);
		break;
	case SC_DEL:
		if( oldflags  & READONLY) return;
		curs_right( wedit_get(win));
	case SC_BACK:
		if( !(oldflags  & READONLY)) wedit_delete_char(win);
		break;
	case SC_HOME:
		if( evnt.mkstate & (K_LSHIFT|K_RSHIFT))
			wedit_curs_bottom( win);
		else
			wedit_curs_top( win);
		break;
	default:
		/* Saisie et affichage d'un caractŠre tap‚ au clavier */
		if( !(oldflags  & READONLY) && wedit_allowed_char( win, c))
			wedit_insert_char( win, c);
		break;
	}

	WeditGet( win, WES_FLAGS, &flags);	

	if( !(oldflags & CHANGED) && (flags & CHANGED)) {
		strcpy( win->info, "* ");
		wind_set( win->handle, WF_INFO, win->info);
	}
}

/*
 *	Dessin color‚
 */

