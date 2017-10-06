/*
 *	Routines d'‚dition de texte
 *  D.B‚r‚ziat 1998
 *	Interfacage avec WinDom de la librairie WinEdit
 *	Module : windom.c
 *	Description : Fonctions d'‚v‚nements, WeditCreate, 
 *				  WeditGet() & WeditSet().
 */

#include <windom.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <libtedit.h>
#include "wglobal.h"

/* Non d‚clar‚ dans WinDom */
void set_clip( int, GRECT *);
void clip_off(int);
void draw_page( WINDOW *win, int x, int y, int w, int h);

void wedit_curs_pos	( WINDOW *win, CURSOR *curs, int *x, int *y, int *w, int *h);
void wedit_curs_on	( WINDOW *win);
void wedit_draw_curs( WINDOW *win, int x, int y, int w, int h, int light, int listaes);
void wedit_key		( WINDOW *win);
void wedit_sld		( WINDOW *win);
void wedit_curs_off	( WINDOW *win);

void w_v_gtext		( WINDOW *win, int x, int y, char *txt);

void wedit_stdkey	( WINDOW *win);
void wedit_stdbut	( WINDOW *win);

/*
 * Routine de dessin 
 */

void wedit_text( WINDOW *win) {
	int x, y, w, h;
	int xs, ys, ws, hs;
	int xe, ye, we, he;
	int i, offset;
	int attr[10];
	EDLINE *scan;
	char *p, buf[MAXBUF+1];
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	
	/* Les infos */
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	vqt_attributes( win->graf.handle, attr);
	offset = HCELL - HCAR ;

	/* On affiche le fond de la fenˆtre */
	vswr_mode( win->graf.handle, MD_REPLACE);
	WindClear( win);

	/* Le texte maintenant */
	if( !wedit->pos) wedit->pos = wedit->edit->top;
	vswr_mode( win->graf.handle, MD_TRANS);
	vst_color( win->graf.handle, wedit->coltxt);

	if( wedit->flags & BLOC) {
		wedit_curs_pos( win, &wedit->begblc, &xs, &ys, &ws, &hs);
		wedit_curs_pos( win, &wedit->endblc, &xe, &ye, &we, &he);
	}

	for( scan = wedit->pos, i = (int)win->ypos; scan; scan = scan->next, i++) {
		y += HCELL;
		if( y < clip.g_y) continue;

		/* Affichage de la ligne de texte */
		p = (wedit->flags & SHOWTAB)?scan->buf:tab2spc( wedit->siztab, buf, scan->buf, MAXBUF);
		if( strlen( p) > win->xpos)
			w_v_gtext( win, x, y - offset, p + win->xpos);
		
		/* Cas des blocs */
		if( wedit->flags & BLOC && wedit->begblc.index <= i &&
			wedit->endblc.index >= i) {
			int xy[4], start, end;
			char c;
			int xtext = x;
			
			xy[0] = x;
			xy[1] = y - HCELL;
			xy[2] = x + w - 1;
			xy[3] = y - 1;

			if( i == wedit->begblc.index ) {
				xy[0] = xs;
				xy[1] = ys;
				start = wedit->begblc.row;
				xtext = xs;
			} else
				start = 0;
			if( i ==  wedit->endblc.index) {
				xy[2] = xe+we-1;
				xy[3] = ye+he-1;
				end = wedit->begblc.row;
			} else
				end = -1;
				
			vswr_mode( win->graf.handle, MD_REPLACE);
			vsf_color( win->graf.handle, wedit->colblc);
			vsf_interior( win->graf.handle, FIS_SOLID);
			v_bar	 ( win->graf.handle, xy);
			vswr_mode( win->graf.handle, MD_TRANS);
			vst_color( win->graf.handle, wedit->coltxtblc);
			if( end != -1) {
				c = scan->buf[end+1];
				scan->buf[end+1] = '\0';
			}
			p = (wedit->flags & SHOWTAB)?(scan->buf+start):tab2spc( wedit->siztab, buf, scan->buf+start, MAXBUF);
			if( strlen( p) > win->xpos)
				w_v_gtext( win, xtext, y - offset, p + win->xpos);
			if( end != -1) 
				scan->buf[end+1] = c;
			vst_color( win->graf.handle, wedit->coltxt);
		}

		/* sort-on de la zone clipp‚e ? */
		if( y > clip.g_y + clip.g_h)
			break;
	}
	/* Dessin du curseur, s'il ne clignote pas */
	if( !(wedit->flags & CURFLASH)) {
		wedit_curs_pos ( win, NULL, &x, &y, &w, &h);
		wedit_draw_curs( win, x, y, w, h, 1, FALSE);
	}
}

/*
 * Routine Timer (clignotement du curseur)
 */

void wedit_timer( WINDOW *win) {
 	int x, y, w, h;
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	
	if( wedit->flags & BLOC || win->status & WS_ICONIFY
		|| !(wedit->flags & CURFLASH))
		return;
	wedit_curs_pos ( win, NULL, &x, &y, &w, &h);
	wedit->flags ^= CURSON;
	wedit_draw_curs( win, x, y, w, h, wedit->flags & CURSON, TRUE);
}


void wedit_kill( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);

	if( vq_gdos())
		vst_unload_fonts( win->graf.handle, 0);
	edit_free ( wedit->edit);
	free( wedit);
	DataDelete( win, WD_EDIT);
	WindClose( win);
	WindDelete( win);
}

/*
 *	Routine de d‚placement de bloc ‚cran qui tient compte
 *	de la liste des rectangles de l'AES.
 */

void wedit_scroll( WINDOW *win, int x, int y, int w, int h, int dx, int dy) {
	void move_screen( int vhandle, GRECT *screen, int dx, int dy);
	void set_clip( int, GRECT *);
	void clip_off( int);
	GRECT r1, r2;
	
	wind_update(BEG_UPDATE);
	graf_mouse( M_OFF, 0L);		
	rect_set( &r2, x, y, w, h);
	WindGet( win, WF_WORKXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	rc_intersect( &r1, &r2);
	wind_get( win->handle, WF_FIRSTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	while (r1.g_w && r1.g_h) {
		if( rc_intersect( &r2, &r1)) {
			set_clip( win->graf.handle, &r1);
			move_screen( win->graf.handle, &r1, dx, dy);
			clip_off( win->graf.handle);
		}
		wind_get( win -> handle, WF_NEXTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	}
	graf_mouse( M_ON, 0L);
	wind_update(END_UPDATE);
}	

/*
 * Ajuste la position des donn‚es dans la fenˆtre selon
 * la position du curseur (le curseur sera au milieu de
 * de la fenˆtre selon la taille des donn‚es).
 */

void wedit_center( WINDOW *win, int xc, int yc, int wc, int hc) {
	EDLINE *pos;
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int x, y, w, h, hpos;
	int draw = 0, attr[10];
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	vqt_attributes( win->graf.handle, attr);
	/* ajustement vertical ? */
	if( yc < y || yc + hc > y + h) {
		hpos = h;
		hpos /= 2; /* au miyeu */ 
		pos = pos = wedit->edit->cur.line;
		win -> ypos = wedit->edit->cur.index - 1;
		while( hpos > 0) {
			hpos -= HCELL;
			if( pos -> prev) {
				pos = pos -> prev;
				win -> ypos --;
			} else {
				pos = wedit->edit -> top;
				win -> ypos = 0;
				break;
			}
		}
		wedit -> pos = pos;
		draw |= VSLIDER;
	}
	/* ajustement horizontal */
	if( xc < x || xc + wc > x + w) {
		win -> xpos = max( 0, wedit->edit->cur.row - w/WCELL/2);
		draw |= HSLIDER;
	}
	
	if( draw) {
		draw_page( win, x, y, w, h);
		WindSlider( win, draw);
	}
}

EDIT *wedit_get( WINDOW *win) {
	return ((WEDIT *)DataSearch( win, WD_EDIT))->edit;
}

void wedit_setup_read( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	char font[80];
	
	if( ConfInquire( "winedit.text.font", "%s", font)) {
		wedit->fnttxt = FontName2Id( font);
		vst_font( win->graf.handle, wedit -> fnttxt);
	}
	if( ConfInquire( "winedit.text.size", "%d", &wedit->siztxt)) {
		int d;
		vst_point( win->graf.handle, wedit -> siztxt, &d, &d, &d, &d);
	}

	/* Les couleurs  */
	ConfInquire( "winedit.text.color", "%d", &wedit->coltxt);
	ConfInquire( "winedit.cursor.bgcolor", "%d", &wedit->colcur);
	ConfInquire( "winedit.cursor.txtcolor", "%d", &wedit->coltxtcur);
	ConfInquire( "winedit.bloc.bgcolor", "%d", &wedit->colblc);
	ConfInquire( "winedit.bloc.txtcolor", "%d", &wedit->coltxtblc);
	ConfInquire( "winedit.tabulation.size", "%d", &wedit->siztab);
}

/*
 *	Cr‚er une fenˆtre EDIT
 */

void wedit_uppage( WINDOW *);
void wedit_dnpage( WINDOW *);
void wedit_upline( WINDOW *);
void wedit_dnline( WINDOW *);
		
WINDOW *WeditCreate( int attrib, EDIT *edit) {
	WINDOW *win;
	WEDIT *wedit;
	int attr[10];

	win = WindCreate( attrib, app.x, app.y, app.w, app.h);
	
	EvntAttach( win, WM_REDRAW , wedit_text);

	EvntAttach( win, WM_UPPAGE, wedit_uppage);
	EvntAttach( win, WM_DNPAGE, wedit_dnpage);
	EvntAdd	  ( win, WM_UPLINE, wedit_upline, EV_TOP);
	EvntAdd   ( win, WM_DNLINE, wedit_dnline, EV_TOP);
		
	EvntAttach( win, WM_VSLID  , wedit_sld);
	EvntAttach( win, WM_DESTROY, wedit_kill);
	EvntAttach( win, WM_XKEYBD,  wedit_stdkey);
	EvntAttach( win, WM_XBUTTON, wedit_stdbut);
	EvntAttach( win, WM_XTIMER,  wedit_timer);

	/* Data */
	wedit = (WEDIT*) malloc(sizeof(WEDIT));
 	DataAttach( win, WD_EDIT, wedit);
	wedit -> keys  = NULL;
	wedit -> edit  = edit;
	wedit -> flags = 0;
	wedit -> pos   = edit -> top;
	wedit -> curs  = NULL;
	wedit -> siztxt = 10;
	wedit -> fnttxt = 1;
	wedit -> siztab = 4;
	wedit -> coltxt = BLACK;
	wedit -> colcur = BLACK;
	wedit -> coltxtcur = WHITE;
	wedit -> colblc = BLACK;
	wedit -> coltxtblc = WHITE;
	if( vq_gdos())
		vst_load_fonts( win->graf.handle, 0);
	vsf_perimeter( win->graf.handle, 0);
	wedit_setup_read( win);
	
	/* Scrolls */	
	vqt_attributes( win->graf.handle, attr);
	win -> ypos_max = edit -> maxline;
	win -> xpos_max = 255;
	win -> w_u = WCELL;
	win -> h_u = HCELL;
	WindSlider( win, VSLIDER|HSLIDER);
	wedit_curs_on( win);
	return win;
}

void WeditSet( WINDOW *win, int mode, ...) {
	va_list list;
	WEDIT *wedit = DataSearch( win, WD_EDIT);

	if( mode == WES_EDIT) {
		EDIT *e;
		va_start( list, mode);
		e = va_arg( list, EDIT *);
		wedit -> edit = e;
	} else if( mode == WES_CURDRAW) {
		void *e;
		va_start( list, mode);
		e = va_arg( list, void *);
		wedit -> curs = e;
	} else if( mode == WES_BLCMARK) {
		CURSOR *s, *e;
		va_start( list, mode);
		s = va_arg( list, CURSOR *);
		e = va_arg( list, CURSOR *);
		wedit -> begblc = *s;
		wedit -> endblc = *e;
		va_end( list);
	} else if( mode == WES_EDITKEY) {
		char *keys;
		va_start( list, mode);
		keys = va_arg( list, char *);
		wedit -> keys = keys;
		va_end( list);
	} else {
		int v1, v2, v3;

		va_start( list, mode);
		v1 = va_arg( list, int );
		switch(mode) {
		case WES_FLAGS:
			v2 = va_arg( list, int );
			if( v2 == FLG_ON)
				wedit -> flags |= v1;
			else if( v2 == FLG_OFF)
				wedit -> flags &= ~v1;
			else if( v2 == FLG_INV)
				wedit -> flags ^= v1;
			break;
		case WES_TXTATTR:
			v2 = va_arg( list, int);
			v3 = va_arg( list, int);
			if( v1 != -1)
				wedit -> coltxt = v1;
			if( v2 != -1)
				wedit -> siztxt = v2;
			if( v3 != -1)
				wedit -> fnttxt = v3;
			break;
		case WES_BLCATTR:
			v2 = va_arg( list, int);
			if( v1 != -1)
				wedit -> colblc = v1;
			if( v2 != -1)
				wedit -> coltxtblc = v2;
			break;
		case WES_CURATTR:
			v2 = va_arg( list, int);
			if( v1 != -1)
				wedit -> colcur = v1;
			if( v2 != -1)
				wedit -> coltxtcur = v2;
			break;
		case WES_TABSIZE:
			wedit -> siztab = v1;
			break;
		}
		va_end( list);
	}
}

void WeditGet( WINDOW *win, int mode, ...) {
	va_list list;
	WEDIT *wedit = DataSearch( win, WD_EDIT);

	if( mode == WES_EDIT) {
		EDIT **e;
		va_start( list, mode);
		e = va_arg( list, EDIT **);
		*e = wedit -> edit;
	} else if( mode == WES_CURDRAW) {
		long *e;
		va_start( list, mode);
		e = va_arg( list, long *);
		*e = (long)wedit -> curs;
	} else if( mode == WES_BLCMARK) {
		CURSOR *s, *e;
		va_start( list, mode);
		s = va_arg( list, CURSOR *);
		e = va_arg( list, CURSOR *);
		if( s) *s = wedit -> begblc;
		if( e) *e = wedit -> endblc;
		va_end( list);
	} else if( mode == WES_EDITKEY) {
		char **keys;
		va_start( list, mode);
		keys = va_arg( list, char **);
		*keys = wedit -> keys;
		va_end( list);
	} else {
		int *v1, *v2, *v3;

		va_start( list, mode);
		v1 = va_arg( list, int*);
		switch(mode) {
		case WES_FLAGS:
			*v1 = wedit -> flags;
			break;
		case WES_TXTATTR:
			v2 = va_arg( list, int*);
			v3 = va_arg( list, int*);
			if( v1) *v1 = wedit -> coltxt ;
			if( v2) *v2 = wedit -> siztxt ;
			if( v3) *v3 = wedit -> fnttxt ;
			break;
		case WES_BLCATTR:
			v2 = va_arg( list, int*);
			if( v1) *v1 = wedit -> colblc;
			if( v2) *v2 = wedit -> coltxtblc;
			break;
		case WES_CURATTR:
			v2 = va_arg( list, int*);
			if( v1)	*v1 = wedit -> colcur;
			if( v2) *v2 = wedit -> coltxtcur ;
			break;
		case WES_TABSIZE:
			*v1 = wedit -> siztab;
			break;
		}
		va_end( list);
	}
}

