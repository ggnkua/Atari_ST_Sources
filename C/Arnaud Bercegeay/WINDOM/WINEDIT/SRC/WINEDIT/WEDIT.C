/*
 *	Edition de texte
 *  D.B‚r‚ziat 1998
 *	Interfacage avec WinDom de la librairie TextEdit
 *	
 *	Routines Publiques haut niveau d'insertion de texte (que l'on
 *	peut appeler depuis le client) &
 *	un exemple de routine ‚v‚nement clavier
 */

#include <string.h>
#include <windom.h>
#include <libtedit.h>
#include "wglobal.h"

void wedit_curs_pos	( WINDOW *win, CURSOR *cur, int *x, int *y, int *w, int *h);
void wedit_center	( WINDOW *win, int xc, int yc, int wc, int hc);
void wedit_scroll	( WINDOW *win, int x, int y, int w, int h, int dx, int dy);
void wedit_draw_char( WINDOW *win, char c, int x, int y);
int  wedit_curs_vis	( WINDOW *win);
int  wedit_curs_vis2( WINDOW *win, int *x, int *y, int *w, int *h);
void wedit_curs_on	( WINDOW *win);
void wedit_curs_off	( WINDOW *win);
void wedit_xy2curs	( WINDOW *win, int x, int y, CURSOR *cur);
void wedit_draw_bloc( WINDOW *win, CURSOR *b, CURSOR *e, int clip);

void draw_page		( WINDOW *, int, int, int, int);	/* non d‚clar‚ dans windom.h */
void w_v_gtext		( WINDOW *win, int x, int y, char *txt);
void w_vqt_extent	( WINDOW *win, char *txt, int *pxy);

/*
 *	Les fonctions qui suivent r‚alisent des op‚rations complexes
 *	d'insertion et suppression de caractŠre dans une fenˆtre.
 *	Elles peuvent ˆtre appel‚ n'importe quand et par n'importe
 *	qui.
 */

/*
 *	Insertion d'un caractŠre
 */

void wedit_insert_char( WINDOW *win, char c) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int xc, yc, wc, hc;
	int x, y, w, h;
	int box[10];
	
	wedit_curs_off( win);

	/* Infos */
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	wedit_curs_pos( win, NULL, &xc, &yc, &wc, &hc);

	/* Recalage ‚cran si besoin */
	if(  xc < x || yc < y || xc+wc > x+w || yc+hc > y+h) {
		wedit_center( win, xc, yc, wc, hc);
		wedit_curs_pos( win, NULL, &xc, &yc,&wc,&hc);
	}
	
	/* Affichage */	

	/* cas tabulation */
	if( c == '\t' && !(wedit->flags & SHOWTAB) ) {
		w_vqt_extent( win, " ", box);
		wc = box[2] - box[0];
		wedit_scroll( win, xc, yc, w, hc, wc*wedit->siztab, 0);
		for( x=0; x<wedit->siztab; x++)
			wedit_draw_char( win, ' ', xc+x*wc, yc);
		
	} else {
		/* le cas ou on insŠre derriŠre une tabulation
		 * est … traiter */
/*		if( wedit->edit->cur.line && strchr ( wedit->edit->cur.line->buf+wedit->edit->cur.row ,
			'\t') ) {
			FormAlert( 1, "[1][Insertion derriere |une tabulation][OK]");
		}
*/
		wedit_scroll( win, xc, yc, w, hc, wc,  0);
		wedit_draw_char( win, c, xc, yc);
	}

	/* Saisie */
	char_put( wedit->edit, c);
	wedit->flags |= CHANGED;
	wedit_curs_on( win);
}

/*
 *	Insertion d'une nouvelle ligne
 */

void wedit_newline( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int xc, yc, wc, hc;
	int x, y, w, h;

	wedit_curs_off( win);
	char_put( wedit->edit, NEWLINE);
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	wedit_curs_pos( win, NULL, &xc, &yc, &wc, &hc);
	if(  xc < x || yc < y || xc+wc > x+w || yc+hc > y+h) {
		wedit_center( win, xc, yc, wc, hc);
		wedit_curs_pos( win, NULL, &xc, &yc,&wc,&hc);
	}

	/* dessin */
	draw_page( win, xc, yc-hc, w, hc);
	wedit_scroll( win, x, yc, w, h, 0, hc);
	draw_page( win, x, yc, w, hc);

	/* mise … jour paramŠtres essentiels */
	wedit->flags |= CHANGED;
	win->ypos ++;
	win->ypos_max ++;
	WindSlider( win, VSLIDER);
	wedit_curs_on( win);
}

/*
 *	Positionne le curseur en (x,y)
 */

void wedit_set_cursor( WINDOW *win, int x, int y) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);

	wedit_curs_off( win);
	/* Annuler le bloc pr‚c‚dent */
	if( wedit->flags & BLOC) {
		wedit_draw_bloc( win, &wedit->begblc, &wedit->endblc, 0x01);
		wedit->flags &= ~BLOC;
	}
	/* Positionnenement de la souris */
	wedit_xy2curs( win, x, y, &(wedit->edit->cur));
	/* Cette valeur ne tient pas compte des tabulations */
	wedit->edit->maxcur = wedit->edit->cur.row;
	wedit_curs_on( win);
}

/*
 *	A faire : insertion d'une chaŒne
 */

void wedit_insert_string( WINDOW *win, char *string) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int xc, yc, wc, hc;
	int x, y, w, h, xn, yn;

	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	wedit_curs_pos( win, NULL, &xc, &yc, &wc, &hc);
	if(  xc < x || yc < y || xc+wc > x+w || yc+hc > y+h) {
		wedit_center( win, xc, yc, wc, hc);
		wedit_curs_pos( win, NULL, &xc, &yc,&wc,&hc);
	}
	string_put(  wedit->edit, string);
	wedit->flags |= CHANGED;
	wedit_curs_pos( win, NULL, &xn, &yn, &wc, &hc);
	/* Mise-…-jour fenˆtre */
	if( yc == yn) {
		/* Cas une seule ligne */
		draw_page( win, xc, yc, w, hc);
	} else {
		/* Cas deux ligne ou + */
		draw_page( win, xc, yc, w, hc);
		draw_page( win, x, yc+hc, w, yn-yc+hc);
	}
}

/*
 *	Effacement caractŠre
 *		0 : top of buffer
 *		1 : OKAY
 */

int wedit_delete_char( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int xc, yc, wc, hc, xn, yn;
	int x, y, w, h;
	int delchar;
	
	if( !(wedit->edit->cur.line)) return 0;
	if( !IS_TOP(wedit->edit)) {
		wedit_curs_off( win);
		WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);

		/* Centrer si besoin */
		if( !wedit_curs_vis2( win, &xc, &yc, &wc, &hc)) {
			wedit_center( win, xc, yc, wc, hc);
			wedit_curs_pos( win, NULL, &xc, &yc, &wc, &hc);
		}
		
		delchar = char_del( wedit->edit);
		wedit->flags |= CHANGED;
		wedit_curs_pos( win, NULL, &xn, &yn, &wc, &hc);
		
		/* On remonte d'une ligne ? */
		if( delchar == 0) {
			win->ypos --;
			win->ypos_max --;
			/* dessin de la ligne … remonter */
			draw_page( win, xn, yn, w, hc);
			/* scroll des lignes inf‚rieurs */
			wedit_scroll( win, x, yc, w, h, 0, -hc);
			/* dessin de la nouvelle ligne du bas */
			draw_page( win, x, y+h-1-hc, w, hc);
			/* mise-…-jour sliders */
			WindSlider( win, VSLIDER);
		} else {
			if( delchar == '\t') {
				int box[10];
				w_vqt_extent( win, " ", box);
				wc = wedit->siztab * (box[2]-box[0]);
			}
			/* scroll ligne */
			wedit_scroll( win, xc, yc, w, hc, -wc, 0);
			/* dessin de la derniŠre colonne */
			draw_page( win, x+w-1-wc, yc, wc, hc);			
		}
		wedit_curs_on( win);
		return 1;
	}
	return 0;
}

/*
 * Effacement de la ligne
 */

int wedit_delete_line( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int xc, yc, wc, hc;
	int x, y, w, h;
	int update_pos = FALSE;
	
	if( !wedit->edit->cur.line) return 0;
	/* if( wedit->edit->maxline == 0) return 0; */
	
	wedit_curs_off( win);
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);

	/* Centrer si besoin */
	if( !wedit_curs_vis2( win, &xc, &yc, &wc, &hc)) {
		wedit_center( win, xc, yc, wc, hc);
		wedit_curs_pos( win, NULL, &xc, &yc, &wc, &hc);
	}

	if( wedit->pos == wedit->edit->cur.line)
		update_pos = TRUE;

	line_rem( wedit->edit);
	wedit->flags |= CHANGED;
	if( update_pos)
		wedit->pos = wedit->edit->cur.line;


	win->ypos_max = wedit->edit->maxline ? wedit->edit->maxline : 1;
	WindSlider( win, VSLIDER);
	draw_page( win, x, yc, w, h);

	wedit_curs_on( win);
	return 1;
}

int wedit_delete_end_line( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int xc, yc, wc, hc;
	int x, y, w, h;
	int lastline;

	if( !wedit->edit->cur.line) return 0;
	if( wedit->edit->maxline == 0) return 0;
	
	wedit_curs_off( win);
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);

	/* Centrer si besoin */
	if( !wedit_curs_vis2( win, &xc, &yc, &wc, &hc)) {
		wedit_center( win, xc, yc, wc, hc);
		wedit_curs_pos( win, NULL, &xc, &yc, &wc, &hc);
	}

	lastline = wedit->edit->cur.line -> next?0:1;
	char_put( wedit->edit, NEWLINE);
	line_rem( wedit->edit);
	if( lastline)
		while( !IS_BOT( wedit->edit))
			curs_right( wedit->edit);
	else
		curs_left( wedit->edit);
	wedit->flags |= CHANGED;
	
	draw_page( win, x, yc, w, hc);

	wedit_curs_on( win);
	return 1;
}

/*
 *	D‚placement du curseur
 */

void wedit_curs_left( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int x, y, w, h;

	if( !wedit->edit->cur.line) return;
	if( !IS_TOP( wedit->edit)) {
		wedit_curs_off( win);
		curs_left( wedit->edit);
		if( !wedit_curs_vis2( win, &x, &y, &w, &h))
			wedit_center( win, x, y, w, h);
		wedit_curs_on( win);
	}
}

void wedit_curs_right( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int x,y,w,h;
	
	if( !wedit->edit->cur.line) return;
	if( !IS_BOT( wedit->edit)) {
		wedit_curs_off( win);
		curs_right( wedit->edit);
		if( !wedit_curs_vis2( win, &x, &y, &w, &h))
			wedit_center( win, x, y, w, h);
		wedit_curs_on( win);
	}
}

void wedit_curs_up( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int x,y,w,h;

	if( !wedit->edit->cur.line) return;
	if( !IS_UP( wedit->edit) ) {
		wedit_curs_off( win);
		curs_up( wedit->edit);
		if( !wedit_curs_vis2( win, &x, &y, &w, &h))
			wedit_center( win, x, y, w, h);
		wedit_curs_on( win);
	}
}

void wedit_curs_down( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int x,y,w,h;

	if( !wedit->edit->cur.line) return;
	if( !IS_DN( wedit->edit) ) {
		wedit_curs_off(win);
		curs_down( wedit->edit);
		if( !wedit_curs_vis2( win, &x, &y, &w, &h))
			wedit_center( win, x, y, w, h);
		wedit_curs_on(win);
	}
}

/* d‚placement par page */

void wedit_curs_page_up( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int x, y, w, h;
	int attr[10];
	int sizepage;
		
	if( !wedit->edit->cur.line) return;
	if( !IS_UP( wedit->edit) ) {
		WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
		vqt_attributes( win->graf.handle, attr);
		sizepage = h / HCELL;
		wedit_curs_off( win);
		while( sizepage--)
			curs_up( wedit->edit);
		wedit_curs_pos( win, NULL, &x, &y, &w, &h);
		wedit_center( win, x, y, w, h);
		wedit_curs_on( win);
	}
}

void wedit_curs_page_down( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int x, y, w, h;
	int attr[10];
	int sizepage;
	
	if( !wedit->edit->cur.line) return;
	if( !IS_DN( wedit->edit) ) {
		WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
		vqt_attributes( win->graf.handle, attr);
		sizepage = h / HCELL;
		wedit_curs_off(win);
		while( sizepage-- )
			curs_down( wedit->edit);
		wedit_curs_pos( win, NULL, &x, &y, &w, &h);
		wedit_center( win, x, y, w, h);
		wedit_curs_on(win);
	}
}

void wedit_curs_top( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	
	if( !wedit->edit->cur.line) return;
	if( !IS_TOP( wedit->edit) ) {

		wedit_curs_off(win);
		wedit -> pos = wedit -> edit -> cur.line = wedit -> edit -> top;
		wedit->edit -> cur.index = 0;
		if( wedit->edit -> top)
			wedit->edit -> cur.row = 0;

		if( win->ypos > 0 || win->xpos > 0)
			snd_rdw( win);
		win->ypos = win->xpos = 0;
		WindSlider( win, VSLIDER+HSLIDER);
		wedit_curs_on(win);
	}
}

void wedit_curs_bottom( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int x,y,w,h;

	if( !wedit->edit->cur.line) return;
	if( !IS_BOT( wedit->edit) ) {

		wedit_curs_off(win);
		wedit->edit -> cur.line = wedit -> edit -> bot;
		wedit->edit -> cur.index = (int)win->ypos_max - 1;
		if( wedit->edit -> bot)
			wedit->edit -> cur.row = wedit -> edit -> bot -> len;
		
		wedit_curs_pos( win , NULL, &x, &y, &w, &h);
		wedit_center( win, x, y, w, h);
		wedit_curs_on(win);
	}
}

/*
 *	Divers
 */

int wedit_allowed_char( WINDOW *win, char c) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	
	if( wedit->keys) {
		if(  c && strchr( wedit->keys, c)) 
			return TRUE;
		else
			return FALSE;
	} else
		return TRUE;	/* si pas de maps -> toujours OK */	
}

/* EOF */
