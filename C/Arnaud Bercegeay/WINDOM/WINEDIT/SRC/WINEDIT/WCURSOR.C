/*
 *	Edition de texte
 *  D.B‚r‚ziat 1998
 *	Interfacage avec WinDom de la librairie TextEdit
 *	
 *	Routines _priv‚es_ li‚es au curseur
 */

#include <windom.h>
#include <libtedit.h>
#include "wglobal.h"

/* Non d‚clar‚ dans WinDom */
void set_clip	( int, GRECT *);
void clip_off	(int);
void draw_page	( WINDOW *win, int x, int y, int w, int h);

void WeditGet		( WINDOW *win, int mode, ...);
void w_v_gtext		( WINDOW *win, int x, int y, char *txt);
void w_vqt_extent	( WINDOW *win, char *txt, int *pxy);

/* 
 * Position du caractŠre devant le curseur 
 *	x,y +-+
 *		|A| w (cellule)
 *		+-+ 
 *		 h (cellule)
 *	Fonctionnne avec tout type de fontes
 */

void wedit_curs_pos( WINDOW *win, CURSOR *cur, int *x, int *y, int *w, int *h) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int attr[10], box[8];
	int line;
	
	if( cur == NULL) cur = &wedit->edit->cur;
	line = diff_line( wedit -> pos, cur -> line);
	 
	WindGet( win, WF_WORKXYWH, x, y, w, h);
	vqt_attributes( win->graf.handle, attr);
	*x -= (int)win->xpos * WCELL;
	*y += line * HCELL;
	*h = HCELL;	
	
	if( cur->line) {
		char dup[255], txt[] = " ", *p;

		*txt = cur -> line -> buf [ cur -> row];
		cur -> line -> buf [ cur -> row] = '\0';

		/* expansion en espace si besoin */
		if( !(wedit->flags & SHOWTAB)) {
			p = tab2spc( wedit->siztab, dup, 
					 	 cur -> line -> buf, 255);
		} else
			p = cur -> line -> buf;

		w_vqt_extent( win, p, box);
		cur -> line -> buf [ cur -> row] = *txt;
		*x += box[2] - box[0];
		w_vqt_extent( win, txt, box);
		*w = (box[2] - box[0])?(box[2] - box[0]):WCELL;
	} else {
		*w = WCELL;
		*x += cur -> row * WCELL;	/* devrait etre 0 ? */
	}
}

/*
 * Le curseur est-il visible dans la fenˆtre ? 
 */

int wedit_curs_vis( WINDOW *win) {
	int x,y,w,h;
	int xc,yc,wc,hc;

	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	wedit_curs_pos( win, NULL, &xc, &yc, &wc, &hc);
	return ( xc>=x && yc>=y && xc+wc < x+w && yc+hc < y+h)?1:0;
}

int wedit_curs_vis2( WINDOW *win, int *xc, int *yc, int *wc, int *hc) {
	int x,y,w,h;

	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	wedit_curs_pos( win, NULL, xc, yc, wc, hc);
	return ( *xc>=x && *yc>=y && *xc+*wc < x+w && *yc+*hc < y+h)?1:0;
}

/*
 * Dessin d'un caractŠre 
 *	Tiens compte de la liste des rectangles de l'AES.
 */

void wedit_draw_char( WINDOW *win, char c, int x, int y) {
	int xy[4], mx, my, mouse;
	char txt[] = " ";
	int attr[10], box[8];
	GRECT list, work;
	int wcol, wpat, wsty;

	vqt_attributes( win->graf.handle, attr);
	txt[0]=c;
	w_vqt_extent( win, txt, box);
	WindGet( win, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);

	graf_mkstate( &mx, &my, &mouse, &mouse);
	mouse = ( mx >= x-16 && my >= y-6 && mx <= x+WCELL+16 && my <= y+HCELL+16)?1:0;
	wind_update( BEG_UPDATE);
	if( mouse) graf_mouse( M_OFF, 0L);

	xy[0] = x; 
	xy[1] = y;
	xy[2] = x + ((box[2] - box[0])?(box[2] - box[0]):WCELL) - 1;
	xy[3] = y + HCELL - 1;

	ApplGet		( APS_WINBG, &wcol, &wpat, &wsty);
	vsf_interior( win -> graf . handle, wpat);
	vsf_style	( win -> graf . handle, wsty);
	vsf_color	( win -> graf . handle, wcol);

	WindGet( win, WF_FIRSTXYWH, &list.g_x, &list.g_y, &list.g_w, &list.g_h);
	while( list.g_w && list.g_h) {
		if( rc_intersect( &work, &list)) {
			set_clip( win->graf.handle, &list);
			vswr_mode( win->graf.handle, MD_REPLACE);			
			v_bar( win->graf.handle, xy);
			if( c != 0) {
				vswr_mode( win->graf.handle, MD_TRANS);
				w_v_gtext( win, xy[ 0], xy[ 1] + HCAR, txt);
			}
		}
		WindGet( win, WF_NEXTXYWH, &list.g_x, &list.g_y, &list.g_w, &list.g_h);	
	}
	clip_off( win->graf.handle);
	wind_update( END_UPDATE);
	if(mouse) graf_mouse( M_ON, 0L);
}

/* post: Curseur dans un bloc ? 
 * pre : le bloc est d‚fini */

int curs_in_bloc( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	CURSOR *cur, *beg, *end;
	
	cur = &wedit->edit->cur;
	beg = &wedit->begblc;
	end = &wedit->endblc;

	if( (beg->index == cur->index && beg->row <= cur->row) ||
		(end->index == cur->index && end->row >= cur->row) ||
		beg->index < cur->index && end->index > cur->index)
		return 1;
	else
		return 0;
}

/*
 *	Routine d'affichage du curseur par d‚faut
 *	(n'utilise pas la vid‚o inverse)
 */
 
static
void wedit_default_cursor( WINDOW *win, int *xy, int light) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int attr[10], color, flags, txtcolor;
	char c[] = " ";
	
	vqt_attributes( win->graf.handle, attr);
	WeditGet	  ( win, WES_FLAGS, &flags);

	/* Saisie du caractere */
	
	if( wedit->edit->cur.line) 
		*c = GET_CHAR( wedit->edit);
	else
		*c = ' ';
	if( !(flags & SHOWTAB) && *c == '\t') 
		*c=' ';

	/* Dessin du fond */
	vswr_mode	( win -> graf . handle, MD_REPLACE);
	if( light) {
		/* R‚glage du curseur */
		WeditGet	( win, WES_CURATTR, &color, &txtcolor);
		vsf_interior( win -> graf . handle, FIS_SOLID);
		vsf_color	( win -> graf . handle, color);
		
	} else {
		/* Si bloc : prendre la couleur du bloc */
		if( flags & BLOC && curs_in_bloc( win)) {
			WeditGet	( win, WES_BLCATTR, &color, &txtcolor);
			vsf_interior( win -> graf . handle, FIS_SOLID);
			vsf_color	( win -> graf . handle, color);
		} else {
			int wpat, wcol, wsty;
			/* Prendre les r‚glages du fond */
			ApplGet		( APS_WINBG, &wcol, &wpat, &wsty);
			vsf_interior( win -> graf . handle, wpat);
			vsf_style	( win -> graf . handle, wsty);
			vsf_color	( win -> graf . handle, wcol);
			WeditGet( win, WES_TXTATTR, &txtcolor, NULL, NULL);
		}
	}
	v_bar		( win -> graf . handle, xy);

	/* Dessin du caractŠre */
	vswr_mode	( win -> graf . handle, MD_TRANS);
/*	if( light || (flags & BLOC && curs_in_bloc( win)))
		WeditGet( win, WES_CURATTR, NULL, &color);
	else
		WeditGet( win, WES_TXTATTR, &color, NULL, NULL);
*/
	vst_color	( win -> graf . handle, txtcolor);

	w_v_gtext	( win, xy[0], xy[1] + HCAR, c);
}

/*
 * Dessin du curseur 
 * x,y,w,h: position et taille du curseur
 */

void wedit_draw_curs( WINDOW *win, int x, int y, int w, int h, int light, int listaes) {
	int xy[4];
	int mx, my, mouse;
	GRECT work, list;
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	
	xy[0] = x, xy[1] = y, xy[2] = x+w-1, xy[3] = y+h-1;

	WindGet( win, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);
	
	if( listaes) {
		graf_mkstate( &mx, &my, &mouse, &mouse);
		mouse = ( mx+16 >= x && my+16 >= y && mx-16 <= x+w && my-16 <= y+h)?1:0;
		wind_update( BEG_UPDATE);
		if( mouse) graf_mouse( M_OFF, 0L);
		WindGet( win, WF_FIRSTXYWH, &list.g_x, &list.g_y, &list.g_w, &list.g_h);
	} else
		list.g_w = list.g_h = 1;

	while( list.g_w && list.g_h) {
		if ( rc_intersect( &work, &list) || !listaes) {
			if( listaes) set_clip( win->graf.handle, &list);
			if( wedit->curs)
				(*wedit->curs)( win, xy, light);
			else
				wedit_default_cursor( win, xy, light);		
		}
		if( listaes)
			WindGet( win, WF_NEXTXYWH, &list.g_x, &list.g_y, &list.g_w, &list.g_h);
		else
			break;
	}

	if( listaes) {
		clip_off( win -> graf . handle);
		if( mouse) graf_mouse( M_ON, 0L);
		wind_update( END_UPDATE);
	}
}

/* Eteind le curseur */

void wedit_curs_off( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
 	int x, y, w, h;

	if( wedit->flags & CURSON) {
		wedit_curs_pos ( win, NULL, &x, &y, &w, &h);
		wedit_draw_curs( win, x, y, w, h, 0, TRUE);
		wedit->flags &= ~CURSON;
	}
}

/* Allume le curseur */

void wedit_curs_on( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
 	int x, y, w, h;

	if( !(wedit->flags & CURSON)) {
		wedit_curs_pos ( win, NULL, &x, &y, &w, &h);
		wedit_draw_curs( win, x, y, w, h, 1, TRUE);
		wedit->flags |= CURSON;
	}
}

/* Conversion cordonn‚e ‚cran en coordonn‚e
 * curseur */

void wedit_xy2curs( WINDOW *win, int x, int y, CURSOR *cur) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int attr[10];
	int xw, yw, ww, hw;
	int line;
	
	WindGet( win, WF_WORKXYWH, &xw, &yw, &ww, &hw);
	vqt_attributes( win->graf.handle, attr);
	x -= xw; y -= yw;

	/* Curseur en haut … gauche */
	
	cur -> line = wedit -> pos;
	cur -> index = (int) win -> ypos;
	cur -> row = 0;

	/* Calcul et positionnement sur la ligne */
	line = y / HCELL;
	while( line-- && cur -> line -> next) {
		cur -> index ++;
		cur -> line = cur -> line -> next;	
	}

	/* Calcul et positionnement sur la colonne */
	if( cur -> line) {
		int box[8];
		char c, *p;
		int i, tab, tabsize,
					tabwidth,
					spacewidth;
		
		p = cur -> line -> buf;
		cur -> row = 0;
		tab = wedit -> siztab;
		tabsize = 0;
		w_vqt_extent( win, " ", box);
		spacewidth = box[2] - box[0];
		w_vqt_extent( win, "\t", box);		
		tabwidth = box[2] - box[0];

		for( i=0; i < cur -> line -> len; i++,  cur -> row ++) {

			/* taille de la ligne tronqu‚e */
			if( !(wedit->flags & SHOWTAB) && p[i] == '\t')
				tabsize += (tab - ( i % tab))*spacewidth - tabwidth;
			
			c = p[i];
			p[i] = '\0';
			w_vqt_extent( win, p, box);
			p[i] = c;
			
			if( x - WCAR < box[2] - box[0] + tabsize)
			break;
		}
	}
}

void wedit_curs_set( WINDOW *win, CURSOR *curs) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);

	curs->line = wedit -> edit -> cur.line;
	curs->row  = wedit -> edit -> cur.row;
	curs->index  = wedit -> edit -> cur.index;
}

void wedit_curs_get( WINDOW *win, CURSOR *curs) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);

	wedit -> edit -> cur.line = curs->line;
	wedit -> edit -> cur.row = curs->row;
	wedit -> edit -> cur.index = curs->index;
}

