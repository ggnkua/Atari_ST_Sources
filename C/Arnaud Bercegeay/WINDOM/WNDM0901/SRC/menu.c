/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2000
 *
 *	module: menu.c
 *	description: librairie menu
 */
#include <ctype.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "scancode.h"
#include "globals.h"
#include "userdef.h"
#include "mnscroll.h"
#include "mnscroll.rh"
#include "mnscroll.rsh"

/* Variables globales 
 */

static int _menu_disabled = 0;


void init_scroll_menu( void) {
	int dum;
	for( dum=0; dum<NUM_OBS; rsrc_obfix( rs_object, dum++));
}

void menu_bind( WINDOW *win, int item, int title) {
	BIND *bind = win?win->menu.bind:app.mnbind;
	
	if( item != -1 && bind) {
		if( bind[item].var) {
			*(bind[item].var) ^= bind[item].bit;
			MenuIcheck( win, item, (*(bind[item].var) & bind[item].bit)?1:0);
		}
		if( bind[item].fnc) {
			void (*f)( WINDOW *,int, int, int );
		
			f = bind[item].fnc;
			(*f)( win, item, OC_MENU, title);
		}
	}
}

/*******************************************************************/

/*
		Gestion automatique des raccour‡is clavier menu ( fonctions internes)
*/


/*
 * Utiliser NKCC serait pas mal
 */

void GemCode2Ascii( int key, int kstate, char *txt) {
	char code = key >> 8;

	switch( code){
	case SC_ESC:
		strcpy( txt, "ESC");
		break;
	case SC_HELP:
		strcpy( txt, "HELP");
		break;
	case SC_UNDO:
		strcpy( txt, "UNDO");
		break;
	case SC_INSERT:
		strcpy( txt, "INSERT");
		break;
	case SC_HOME:
		strcpy( txt, "HOME");
		break;
	case SC_TAB:
		strcpy( txt, "TAB");
		break;
	case SC_DEL:
		strcpy( txt, "DEL");
		break;
	case SC_BACK:
		strcpy( txt, "BACK");
		break;
	case SC_F1:
		strcpy( txt, "F1");
		break;
	case SC_F2:
		strcpy( txt, "F2");
		break;
	case SC_F3:
		strcpy( txt, "F3");
		break;
	case SC_F4:
		strcpy( txt, "F4");
		break;
	case SC_F5:
		strcpy( txt, "F5");
		break;
	case SC_F6:
		strcpy( txt, "F6");
		break;
	case SC_F7:
		strcpy( txt, "F7");
		break;
	case SC_F8:
		strcpy( txt, "F8");
		break;
	case SC_F9:
		strcpy( txt, "F9");
		break;
	case SC_F10:
		strcpy( txt, "F10");
		break;
	default:
		txt[1] = '\0';
		txt[0] = toupper( keybd2ascii( key, kstate & (K_LSHIFT|K_RSHIFT)));
		break;
	}
}

/* retourne 1 si la commmande a ‚t‚ ex‚cut‚, 0 sinon
   si win == NULL on travaille sur le menu du bureau
   Condition d'utilisation: l'entre du menu
   		doit contenir la s‚quence espace-racourci clavier-espace
   		Les raccourcis claviers sont:
   			^=control
   			=alternate
   			=shift
   			A-Z,F1-F10
   			ESC,UNDO,HELP,TAB,BACK,DEL,HOME,INSERT
   		ex:
   			" I "
   			" ^C "
   			" UNDO "
   			" F3 "
   			" DEL "  etc ...
   		Les combinaison entre Shift, alternate, control ne sont
   		pas permis pour l'instant. 
   */

int menu_exec_cmd( WINDOW *win) {
	int titre, entre;
	char cmd[10], rac[10], *str, *p;
	OBJECT *menu;

	menu = win?win -> menu.root:app.menu;
	if( !menu) /* Y'a pas de menu */
		return 0;
	
	/* On transforme le scancode en chaŒne */
	GemCode2Ascii( evnt.keybd, evnt.mkstate, rac);

	if( *rac == '\0' || *rac == ' ')
		return 0;
		
	/* analyse du raccourci clavier */
	strcpy( cmd, " ");
	if( evnt.mkstate & K_ALT)
		strcat( cmd, "");
	else if( evnt.mkstate & K_CTRL)
		strcat( cmd, "^");
	else if( evnt.mkstate & K_RSHIFT || evnt.mkstate & K_LSHIFT)
		strcat( cmd, "");
	strcat( cmd, rac);
	strcat( cmd, " ");
	titre = entre = 3;
	
	while( menu[entre].ob_type != G_BOX)
		entre ++;
	
	while( 1) {
		do {
			entre ++;
			if( menu[entre].ob_type == G_BOX)
				break;
			if( menu[titre].ob_state & DISABLED ||
				menu[entre].ob_state & DISABLED )
				continue;
			
			str = ObjcString( menu, entre, NULL);
			p = strstr( str, cmd);
			if( p != NULL && str+1 != p) {
				if( win) {
					menu_bind( win, entre, titre);
					ApplWrite( app.id, WM_MNSELECTED, win -> handle, titre, entre, 0, 0);
				} else
					ApplWrite( app.id, MN_SELECTED, titre, entre, 0, 0, 0);
				return 1;
			}
		} while( !(menu[ entre].ob_flags & LASTOB));
		if( menu[ entre].ob_flags & LASTOB)
			return 0; /* Commande pas trouv‚ */
		titre ++;
	}
}

/*  Menu en fenetres */

/* Cette fonction dessine la barre de menu - Elle sera appell‚
	automatiquement par evnt_windows lors d'un ‚v‚nement REDRAW */

void menu_draw(WINDOW *win, int xc, int yc, int wc, int hc) {
	OBJECT *menu;
	INT16 xy[4], x, y, w, h, i;

	wind_get( win->handle, WF_WORKXYWH, &x, &y, &w, &h);
	menu = win -> menu.root;
	menu->ob_x = x;
	menu->ob_y = y;
	menu[1].ob_width  = w;
	if( CONF(app)->flag & MENUSCROLL) {
		/*	D‚caler le menu */
		for( i = 0; i < win->menu.scroll; i++)
			menu->ob_x -= menu[3+i].ob_width;
	
		/* Devrait aller dans WindSet */
		menu[0].ob_width = 10000;
		menu[1].ob_width = 10000;
		menu[2].ob_width = 10000;
		/* --------------------- */
		objc_draw( menu, 1, 2, xc, yc, wc, hc);
		
		rs_trindex[MNSCROLL][MENULF].ob_flags =  menu[1].ob_flags;
		rs_trindex[MNSCROLL][MENURT].ob_flags =  menu[1].ob_flags;
		rs_trindex[MNSCROLL]->ob_height =  menu[1].ob_height;

		/* Afficher les scrolls */
		if( win->menu.scroll > 0)
			rs_trindex[MNSCROLL][MENULF].ob_state &= ~DISABLED;
		else
			rs_trindex[MNSCROLL][MENULF].ob_state |= DISABLED;
		
		if( menu[3+win->menu.scroll].ob_next != 2 )
			rs_trindex[MNSCROLL][MENURT].ob_state &= ~DISABLED;
		else
			rs_trindex[MNSCROLL][MENURT].ob_state |= DISABLED;

		rs_trindex[MNSCROLL]->ob_y = y;
		rs_trindex[MNSCROLL]->ob_x = x;
		objc_draw( rs_trindex[MNSCROLL], 0, 1, xc, yc, wc, hc);
	} else
		objc_draw( menu, 1, 2, xc, yc, wc, hc);

	vsl_color( app.handle, BLACK);
	vsl_width( app.handle, 1);
	vsl_type( app.handle, 1);
	xy[0] = xc; xy[1] = yc;
	xy[2] = xc + wc - 1;
	xy[3] = yc + hc - 1;
	vs_clip( app.handle, 1, xy);
	objc_offset( menu, 1, &xy[0], &xy[1]);
	xy[ 1] += menu[1].ob_height;		/* +1 pour la ligne */
	xy[ 2] = xy[0] + menu[1].ob_width - 1;
	xy[ 3] = xy[ 1];
	v_pline( app.handle, 2, xy);
	vs_clip( app.handle, 0, xy);
}

int is_title( OBJECT *tree, int index) {	
	if( tree[index].ob_type == G_TITLE)
		return 1;
	if( tree[index].ob_type == ((MENUTITLE << 8) | G_USERDEF)) {
		USERBLK *user = tree[index].ob_spec.userblk;
		if( ((W_PARM*)user->ub_parm)->wp_type == ((MENUTITLE << 8) | G_TITLE))
			return 1;
	}
	return 0;
}

/* Retourner l'index du menu correspondant - sous fonction
 *	de frm_menu().
 */

int GetIndexMenu( OBJECT *menu, int title) {
	register int count=0;
	int check=1, link=0;

	while( !(menu[count++].ob_flags & LASTOB) ) {
		if( count != title && is_title(menu,count) )
			check ++;
		if( count == title)
			break;
	}
	while( !(menu[count++].ob_flags & LASTOB) ) {
		if( menu[count].ob_type == G_BOX)
			link ++;
		if( link == check)
			return count;
	}
	return -1;
}


void MenuScroll( WINDOW *win, int dir) {
	INT16 x, y, w, h;
	OBJECT *menu = win->menu.root;

	wind_get( win->handle, WF_WORKXYWH, &x, &y, &w, &h);
	if( dir == 0) { /* RIGTH */
		if( menu[3+win->menu.scroll].ob_next != 2 ) {
			menu[3+win->menu.scroll].ob_flags |= HIDETREE;
			menu[3+win->menu.scroll].ob_state |= DISABLED;
			win -> menu.scroll ++;
			snd_msg( win, WM_REDRAW, x, y, w, menu[1].ob_height);
		}
	} else {
		if( win->menu.scroll > 0) {
			win -> menu.scroll --;
			menu[3+win->menu.scroll].ob_flags &= ~HIDETREE;
			menu[3+win->menu.scroll].ob_state &= ~DISABLED;
			snd_msg( win, WM_REDRAW, x, y, w, menu[1].ob_height);
		}	
	}
}

/*
 *  Cette fonction gŠre le menu d'une fenetre - elle sera appell‚
 *	automatiquement par evnt_windows lors d'un click souris dans
 *	une fenetre menu. Retourne -1 si on a selectionn‚ aucun
 *	titre.
 */

int frm_menu( WINDOW *win) {
	int title;
	int item;
	int index, box;
	OBJECT *menu;
	INT16 x, y, w, h, xob, yob;
	INT16 mx, my, mbut, mkey;
	INT16 msg[8], ev;
	INT16 dum;
	int GetIndexMenu( OBJECT *, int);
	MFDB fond;

	menu = win -> menu.root;
	wind_get( win->handle, WF_WORKXYWH, &x, &y, &w, &h);

	if( CONF(app)->flag & MENUSCROLL) {
		rs_trindex[MNSCROLL] -> ob_x = x;
		rs_trindex[MNSCROLL] -> ob_y = y;

		title = objc_find( rs_trindex[MNSCROLL], 0, MAX_DEPTH, evnt.mx, evnt.my);
		switch( title) {
		case MENURT:
			MenuScroll( win, 0);
			return -1;
		case MENULF:
			MenuScroll( win, 1);
			return -1;
		}
	}

	while( !wind_update( BEG_MCTRL));

	/* on attend qu'on relache le bouton */
	
	do
		graf_mkstate( &evnt.mx, &evnt.my, &evnt.mbut, &evnt.mkstate);
	while( evnt.mbut);


	title = objc_find( menu, 0, MAX_DEPTH, evnt.mx, evnt.my);
	if( title == -1 || !is_title(menu,title)) {
		wind_update( END_MCTRL);
		return -1;
	}

	item = -1;
	title = -1;
	box = 0;
	do {
		ev = 
#ifdef __GEMLIB__
		evnt_multi( MU_TIMER|MU_BUTTON, 1, 1, 1,
					0,0,0,0,0,
					0,0,0,0,0,
					msg,
					0L,
					&mx, &my, &mbut, &mkey,
					&dum, &dum);
# else  /* __GEMLIB__ */
		evnt_multi( MU_TIMER|MU_BUTTON, 1, 1, 1,
					0,0,0,0,0,
					0,0,0,0,0,
					msg,
					0, 0,
					&mx, &my, &mbut, &mkey,
					&dum, &dum);
#endif /* __GEMLIB__ */
		
		/***********************************************/
				
		index = objc_find( menu, 0, MAX_DEPTH, mx, my);
		if( index == -1 || menu[index].ob_type == G_BOX)
			continue;

		if( is_title(menu, index)
			&& !(menu[ index].ob_state & DISABLED)
			&& index != title) 	/* on change de menu d‚roulant */
		{
			if( mx<x || mx>x+w-1 || my <y || my>y+h-1)
				continue;
			if( wind_find( mx, my) != win->handle)
				continue;
			if( title !=-1)	/* Un menu est-il deja s‚lectionn‚ ? */
			{				/* on ferme le menu pr‚cedent */
				if( item != -1)
					objc_change( menu, item, 0, x, y, w, h, NORMAL, 0);
				box = GetIndexMenu( menu, title);
				objc_offset( menu, box, &xob, &yob);
				w_put_bkgr( xob-10, yob-10, menu[box].ob_width+20, menu[box].ob_height+20, &fond);
				ObjcWindChange( win, menu, title, x, y, w, h, NORMAL);
			}
			ObjcWindChange( win, menu, index, x, y, w, h, SELECTED);
			title = index;
			box = GetIndexMenu( menu, title);
			objc_offset( menu, box, &xob, &yob);
			w_get_bkgr( xob-10, yob-10, menu[box].ob_width+20, menu[box].ob_height+20, &fond);
			objc_draw( menu, box, MAX_DEPTH, xob-10, yob-10, 
					   menu[box].ob_width+20, menu[box].ob_height+20);
			if( win->menu.hilight) 
				(*win->menu.hilight)( win, title, -1);
		} else { 
			
			/* on change d'entr‚e de menu */
			
			index = objc_find( menu, box, MAX_DEPTH, mx, my);
			if( item != -1 && item != index 
				&& !(menu[item].ob_state & DISABLED))
				objc_change( menu, item, 0, xob, yob, menu[box].ob_width, 
							 menu[box].ob_height, NORMAL, 1);
			if( index != -1 && index != item
				&& !(menu[index].ob_state & DISABLED)) {
				objc_change( menu, index, 0, xob, yob,menu[box].ob_width, 
							 menu[box].ob_height, SELECTED, 1);
				if( win->menu.hilight)
					(*win->menu.hilight)( win, title, index);
			}
			item = index;

		}
	} while( ! (ev & MU_BUTTON));

	if( item != -1 && !(menu[item].ob_state & DISABLED))
		for( dum=0; dum < CONF(app)->menu_effect; dum++)
		{
#ifdef __GEMLIB__
			evnt_timer( 50L);
#else
			evnt_timer( 50,0);
#endif
			objc_change( menu, item, 0, xob, yob,menu[box].ob_width, 
					 	 menu[box].ob_height, NORMAL, 1);
#ifdef __GEMLIB__
			evnt_timer( 50L);
#else
			evnt_timer( 50,0);
#endif
			objc_change( menu, item, 0, xob, yob,menu[box].ob_width, 
					 	 menu[box].ob_height, SELECTED, 1);
		}
	
	if(box)
		w_put_bkgr( xob-10, yob-10, menu[box].ob_width+20, menu[box].ob_height+20, &fond);

	do
		graf_mkstate( &mx, &my, &mbut, &mkey);
	while( mbut);

	wind_update( END_MCTRL);
	
	if( item != -1 && !(menu[item].ob_state & DISABLED) ) {
		objc_change( menu, item, 0, x, y, w, h, NORMAL, 0);
	} else 
		item = -1;

	/* Binding variable & fonction */
	menu_bind( win, item, title);
	
	/* R‚sultat du traitement envoy‚ … l'AES */
	snd_msg( win, WM_MNSELECTED, title, item, 0, 0);
	return 0;
}

static WINDOW *open_menu( OBJECT *tree, int index) {
	WINDOW *win;
	GRECT coord;

	coord.g_x = tree[index].ob_x;
	coord.g_y = tree[index].ob_y;
	coord.g_w = tree[index].ob_width;
	coord.g_h = tree[index].ob_height;
	win = FormCreate( &tree[index], 0, NULL, "", &coord, 0, 0);
	return win;
}

static void close_menu( WINDOW *win) {
	if( win) EvntExec( win, WM_DESTROY);
}

int frm_menu_beta( WINDOW *win) {
	int title, item;
	int index, box, ev;
	OBJECT *menu;
	INT16 x, y, w, h;
	EVNTvar old;
	WINDOW *wbox = NULL;
	int GetIndexMenu( OBJECT *, int);
	int EvntWindom( int);
	int ObjcChange( int, void*, int, int, int);
		
	menu = win -> menu.root;
	wind_get( win->handle, WF_WORKXYWH, &x, &y, &w, &h);

	if( CONF(app)->flag & MENUSCROLL) {
		rs_trindex[MNSCROLL] -> ob_x = x;
		rs_trindex[MNSCROLL] -> ob_y = y;

		title = objc_find( rs_trindex[MNSCROLL], 0, MAX_DEPTH, evnt.mx, evnt.my);
		switch( title) {
		case MENURT:
			MenuScroll( win, 0);
			return -1;
		case MENULF:
			MenuScroll( win, 1);
			return -1;
		}
	}

	while( !wind_update( BEG_MCTRL));

	/* on attend qu'on relache le bouton */
	
	do
		graf_mkstate( &evnt.mx, &evnt.my, &evnt.mbut, &evnt.mkstate);
	while( evnt.mbut);


	title = objc_find( menu, 0, MAX_DEPTH, evnt.mx, evnt.my);
	if( title == -1 || !is_title(menu,title)) {
		wind_update( END_MCTRL);
		return -1;
	}

	item = -1;
	title = -1;
	box = 0;
	old = evnt;

	do {

		ev = EvntWindom( MU_MESAG | MU_BUTTON);
		
		if( ev & MU_BUTTON) {
		
			index = objc_find( menu, 0, MAX_DEPTH, evnt.mx, evnt.my);
			if( index == -1)	continue;
		
			/* on change de menu d‚roulant */
			if( is_title(menu, index)
				&& !(menu[ index].ob_state & DISABLED)
				&& index != title) {
				if( evnt.mx<x || evnt.mx>x+w-1 || evnt.my<y || evnt.my>y+h-1)
					continue;
				if( wind_find( evnt.mx, evnt.my) != win->handle)
					continue;
			
				/* Un menu est-il deja selectionne? */
				if( title != -1)	{
					/* on ferme le menu pr‚cedent */
					if( item != -1)
						objc_change( menu, item, 0, x, y, w, h, NORMAL, 0);
					box = GetIndexMenu( menu, title);
					close_menu( wbox);
					ObjcWindChange( win, menu, title, x, y, w, h, NORMAL);
				}
				ObjcWindChange( win, menu, index, x, y, w, h, SELECTED);
				title = index;
				box = GetIndexMenu( menu, title);
				wbox = open_menu( menu, box);
			} else { 
			
				/* on change d'entr‚e de menu */
			
				index = objc_find( menu, box, MAX_DEPTH, evnt.mx, evnt.my);
				if( item != -1 && item != index 
					&& !(menu[item].ob_state & DISABLED))
					ObjcChange( OC_FORM, wbox, item, NORMAL, 1);
				if( index != -1 && index != item
					&& !(menu[index].ob_state & DISABLED))
					ObjcChange( OC_FORM, wbox, index, SELECTED, 1);
				item = index;
			}
		}
		graf_mkstate( &evnt.mx, &evnt.my, &evnt.mbut, &evnt.mkstate);
	} while( !evnt.mbut);

	/* Effet de clignotement */
	if( item != -1 && !(menu[item].ob_state & DISABLED)) {
		int dum;

		for( dum=0; dum < CONF(app)->menu_effect; dum++) {
#ifdef __GEMLIB__
			evnt_timer( 50L);
#else
			evnt_timer( 50,0);
#endif
			ObjcChange( OC_FORM, wbox, item, NORMAL, 1);
#ifdef __GEMLIB__
			evnt_timer( 50L);
#else
			evnt_timer( 50,0);
#endif
			ObjcChange( OC_FORM, wbox, item, SELECTED, 1);
		}
	}
	if(box)
		close_menu( wbox);
	do
		graf_mkstate( &evnt.mx, &evnt.my, &evnt.mbut, &evnt.mkstate);
	while( evnt.mbut);

	wind_update( END_MCTRL);
	evnt = old;
	
	if( item != -1 && !(menu[item].ob_state & DISABLED) )
		objc_change( menu, item, 0, x, y, w, h, NORMAL, 0);
	else 
		item = -1;

	/* R‚sultat du traitement envoy‚ … l'AES */
	snd_msg( win, WM_MNSELECTED, title, item, 0, 0);
	return 0;
}

/* Cette fonction teste si la souris est sur le menu
 * d'une fenetre. Interne
 */

int is_menu( WINDOW *win) {
	INT16 x, y;

	objc_offset( win -> menu.root, 1, &x, &y);
	if( (evnt.mx > x) && (evnt.mx < x + (win->menu.root)[1].ob_width - 1)
		&& (evnt.my > y) && (evnt.my < y + (win->menu.root)[1].ob_height - 1))
		return 1;
	return 0;
}


/******  Pseudo fonction AES ********/

int MenuBar( OBJECT *menu, int mode) {
	int res;
	
	res = menu_bar( menu, mode);
	if( mode)
		app.menu = menu;
	else
		app.menu = NULL;
	return res;
}

int MenuTnormal( WINDOW *win, int title, int mode) {
	INT16 x, y, w, h;
	int res, dum;

	if( win == NULL)
		res = menu_tnormal( app.menu, title, mode);
	else {
		wind_get( win->handle, WF_WORKXYWH, &x, &y, &w, &h);

		dum = win->menu.root[title].ob_state;
		if( mode)
			dum &= ~SELECTED;
		else
			dum |= SELECTED;
		
		res = ObjcWindChange( win, win->menu.root, title, x, y, w, h, mode?NORMAL:SELECTED);
	
		win->menu.root[title].ob_state = dum;
	}
	return res;
}

int MenuDisable( void) {
	if( !app.menu) return 1;
	if( _menu_disabled == 0) {
	int index = 3;
	
		while( is_title( app.menu, index++))
			app.menu[index].ob_state = DISABLED;
		while( app.menu[ index].ob_type != G_STRING)
			index++;
		app.menu[index].ob_state = DISABLED;
		menu_bar( app.menu, 1);
	}
	_menu_disabled ++;
	return 0;
}

int MenuEnable( void) {
	if( !app.menu) return 1;
	if( _menu_disabled == 1)
	{
	int index = 3;
	
		while( is_title( app.menu, index++))
			app.menu[index].ob_state = NORMAL;
		while( app.menu[ index].ob_type != G_STRING)
			index++;
		app.menu[index].ob_state = NORMAL;
		menu_bar( app.menu, 1);
	}
	if( _menu_disabled>0)
		_menu_disabled --;
	return 0;
}

int MenuIcheck( WINDOW *win, int item, int check) {
	OBJECT *menu;
	char *str;
	
	menu = ( win == NULL)? app.menu: win->menu.root;
	
	str = ObjcString( menu, item, NULL);
	if( *str) {
		str[0] = check?'':' ';
		return 0;
	}
	return 1;
}

int MenuText( WINDOW *win, int item, char *txt) {
	OBJECT *menu;
	char *str;
	
	menu = ( win == NULL)? app.menu: win->menu.root;
	str= ObjcString( menu, item, txt);
	return (*str?1:0);
}


/*
 *	Menus hi‚rarchiques
 */

typedef struct {
		char *string;
		OBJECT *mn_tree;
		int mn_menu, mn_item, mn_scroll;
	} SMENU;

/*
 *	type = G_STRING  -> type G_USERDEF | 0x0100
 */

void w_get_bkgr(int of_x, int of_y, int of_w, int of_h, MFDB *img);
void w_put_bkgr(int of_x, int of_y, int of_w, int of_h, MFDB *img);

WORD __CDECL draw_submenu( PARMBLK *pblk) {
	/* 1er: dessiner l'item
	 * 2nd: afficher le sub menu
	 */
	INT16 tab[10], hcar;
	INT16 mx,my,but,dum;
	OBJECT *tree;
	MFDB scr;
	
	 	/* Clippage */
	tab[0]=pblk->pb_xc;
	tab[1]=pblk->pb_yc;
	tab[2]=pblk->pb_wc+tab[0]-1;
	tab[3]=pblk->pb_hc+tab[1]-1;
	vs_clip( app.handle, 1, tab);

	vqt_attributes( app.handle, tab);
	hcar = tab[7];
	
	tab[0]=pblk->pb_x;
	tab[1]=pblk->pb_y;
	tab[2]=pblk->pb_w+tab[0]-1;
	tab[3]=pblk->pb_h+tab[1]-1;

	vswr_mode( app.handle, MD_REPLACE);
	vsf_color( app.handle, WHITE);
	v_bar( app.handle, tab);

	v_gtext( app.handle, pblk->pb_x, pblk->pb_y + pblk->pb_h/2+hcar/2-1, 
			((SMENU *)pblk->pb_parm)->string);
	
	if( pblk->pb_currstate & SELECTED) {
		vswr_mode( app.handle, MD_XOR);
		vsf_color( app.handle, BLACK);
		vsf_interior( app.handle, 1 /*FIS_SOLID*/ );
		tab[0] --;tab[1] --;
		tab[2] ++;tab[3] ++;
		v_bar( app.handle, tab);
	}
	vs_clip( app.handle, 0, tab);

	if( /*((SMENU *)pblk->pb_parm)->mn_scroll &&*/ pblk->pb_currstate & SELECTED) {
		tree = ((SMENU *)pblk->pb_parm)->mn_tree;
		tree->ob_x = pblk->pb_x+pblk->pb_w;
		tree->ob_y = pblk->pb_y;
		w_get_bkgr( tree->ob_x-3, tree->ob_y-3, tree->ob_width-5, tree->ob_height-5, &scr);
/*		objc_draw( tree, 0, MAX_DEPTH, app.x, app.y, app.w, app.h); */
		v_show_c( app.handle, 1);
		while( !wind_update (BEG_MCTRL));
		do{
			graf_mkstate( &mx, &my, &but, &dum);
			dum = objc_find(tree, 0, 7, mx, my);
		}while( dum != -1 && tree[dum].ob_type != G_TITLE);
		
		v_hide_c( app.handle);
		wind_update (END_MCTRL);
		w_put_bkgr( tree->ob_x-3, tree->ob_y-3, tree->ob_width+5, tree->ob_height+5, &scr);
		((SMENU *)pblk->pb_parm)->mn_scroll = 0;
	}

	if( pblk->pb_currstate & SELECTED)
		((SMENU *)pblk->pb_parm)->mn_scroll = 1;
	else
		((SMENU *)pblk->pb_parm)->mn_scroll = 0;

	return 0;
}

#define ME_INQUIRE	0
#define ME_ATTACH	1
#define ME_REMOVE	2

int MenuAttach( int flag, OBJECT *tree, WORD item, MENU *mdata) {
	char *txt;
	
	if( tree[item].ob_type == G_STRING && flag == ME_ATTACH) {
		SMENU *sub;
		USERBLK *user;
		
		/* on attache, l'entr‚e du menu est remplac‚ par
		   un objet userdef */
		tree[item].ob_type = G_USERDEF | (XSMENU<<8);

		sub = (SMENU *)malloc( sizeof(SMENU));
		txt = tree[item].ob_spec.free_string;
		txt[ strlen(txt)-2] = '';
		sub->string = txt;
		sub->mn_tree = mdata->mn_tree;
		sub->mn_menu = mdata->mn_menu;
		sub->mn_item = mdata->mn_item;
		sub->mn_scroll = 0 /*mdata->mn_scroll*/;

		user = (USERBLK *)malloc( sizeof(USERBLK));
		user->ub_code = draw_submenu;
		user->ub_parm =(long)sub;
		
		tree[item].ob_spec.userblk = user;
		
	} else if( tree[item].ob_type == (G_USERDEF|(XSMENU<<8)) && flag == ME_REMOVE) {		
		txt = ((SMENU *)tree[item].ob_spec.userblk->ub_parm)->string;
		tree[item].ob_type = G_STRING;
		free( (void*)tree[item].ob_spec.userblk->ub_parm);
		free( tree[item].ob_spec.userblk);
		txt[ strlen(txt)-2] = ' ';
		tree[item].ob_spec.free_string = txt;
	} else if( tree[item].ob_type == (G_USERDEF|(XSMENU<<8)) && flag == ME_INQUIRE) {
	
	}
	return 0;
}

