/*
 *	
 *
 * Gestion des blocs
 */
	
#include <stdio.h> /* pour debug */
#include <string.h>
#include <windom.h>
#include <libtedit.h>
#include "wglobal.h"

#define abs(a) ((a)>0?(a):(-a))

EDIT *bloc = NULL;

void 	wedit_curs_off	( WINDOW *win);
void 	wedit_curs_on	( WINDOW *win);
void 	wedit_curs_pos	( WINDOW *win, CURSOR *cur, int *x, int *y, int *w, int *h);
void	wedit_curs_up	( WINDOW *);
void	wedit_curs_down	( WINDOW *);
void 	wedit_curs_get	( WINDOW *, CURSOR *);
void 	wedit_curs_set	( WINDOW *, CURSOR *);
void 	wedit_xy2curs	( WINDOW *, int, int, CURSOR *);

void 	set_clip		( int, GRECT *);
void 	clip_off		( int);
int 	bloc2scrap		( WINDOW *);
void 	w_v_gtext		( WINDOW *, int, int, char *);

void draw_bar_text( WINDOW *win, EDLINE *line, int row, int end, int x, int y, int w, int h, int select) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int xy[4], attr[10];
	char *p, c, buf[MAXBUF+1];

	/* Bloc */
	vswr_mode	( win->graf.handle, MD_REPLACE);
	if( select) {
		vsf_color	( win->graf.handle, wedit->colblc);
		vsf_interior( win->graf.handle, FIS_SOLID);
		vsf_style	( win->graf.handle, 8);	
	} else {
		int wcol, wpat, wsty;
		ApplGet		( APS_WINBG, &wcol, &wpat, &wsty);
		vsf_interior( win -> graf . handle, wpat);
		vsf_style	( win -> graf . handle, wsty);
		vsf_color	( win -> graf . handle, wcol);
	} 

	xy[0] = x;
	xy[1] = y;
	xy[2] = x+w-1;
	xy[3] = y+h-1;
	v_bar( win->graf.handle, xy);

	/* Texte */
	vswr_mode( win->graf.handle, MD_TRANS);
	vst_color( win->graf.handle, select ? wedit->coltxtblc:wedit->coltxt);
	vqt_attributes( win->graf.handle, attr);
	if( end ) {
		c = line->buf[end];
		line->buf[end] = '\0';
	}
	p = (wedit->flags & SHOWTAB)?(line->buf+row):tab2spc( wedit->siztab, buf, line->buf+row, MAXBUF);
	if( strlen( p) > win->xpos)
		w_v_gtext( win, x, y + HCAR, p);
	if( end ) line->buf[end] = c;
}


/* post: Dessine un bloc
 * pre: start < end  
 */

/* a mettre dans struct.h */
/* #define DOCLIP	 0x01 */
#define SELECT		0x01
#define DNSCROLL 	0x10
#define UPSCROLL 	0x20

static
void wedit_set_bloc( WINDOW *win, CURSOR *start, CURSOR *end, int mode) {
	int xs, ys, ws, hs;
	int xe, ye, we, he;
	int pos, ysinter;
	GRECT work, list;
	int attr[10], select;
	EDLINE *line;
	
	graf_mouse	( M_OFF, 0L);
	
	vqt_attributes	( win->graf.handle, attr);
	WindGet			( win, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h);	
	WindGet			( win, WF_FIRSTXYWH, &list.g_x, &list.g_y, &list.g_w, &list.g_h);
	wedit_curs_pos	( win, start, &xs, &ys, &ws, &hs);
	wedit_curs_pos	( win, end,   &xe, &ye, &we, &he);

	select = (mode & SELECT)?1:0;

	while( list.g_w && list.g_h) {

		if( rc_intersect( &work, &list)) {
			set_clip( win->graf.handle, &list);

			if( start->line == end->line)

				draw_bar_text( win, start->line, start->row, end->row+1,
								xs, ys, xe + we - xs, hs, select);

			else {

				if( end->index > start->index) 
					line = start->line;
				else
					line = end->line;

				draw_bar_text( win, line, start->row, 0, xs, ys, work.g_w, hs, select);
				ysinter = ys;

				for( pos = abs(end->index - start->index); pos>1; pos --, line = line->next) {
					
					ysinter += HCELL;

					if( ysinter + hs > work.g_y + work.g_h && mode & (DNSCROLL|UPSCROLL)) {
						if( mode & DNSCROLL)
							wedit_curs_down( win);
						else
							wedit_curs_up( win);
						/* On a chang‚ de position ... */
						wedit_curs_pos( win, end, &xe, &ye, &we, &he);
						break;
					} else
						draw_bar_text( win, line, 0, 0, work.g_x, ysinter, work.g_w, HCELL, select);
				}

				draw_bar_text( win, end->line, 0, end->row+1, work.g_x, ye, xe + we - work.g_x, he, select);
			} 
		}
		
		WindGet( win, WF_NEXTXYWH, &list.g_x, &list.g_y, &list.g_w, &list.g_h);
	}

	clip_off( win->graf.handle);
	graf_mouse	( M_ON, 0L);
}

/* Fonction publique */

void wedit_draw_bloc( WINDOW *win, CURSOR *start, CURSOR *end) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);

	wedit_set_bloc( win, start?start:&wedit->begblc, 
						 end?end:&wedit->endblc, 0);
}

/* Selection du bloc par l'utilisateur */

void wedit_selectbloc( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	CURSOR temp;
	int forward, h, dum, attr[10];
	
	graf_mkstate( &evnt.mx, &evnt.my, &evnt.mbut, &evnt.mkstate);
	
	/* SELECTION DE BLOC : NE FONCTIONNNE QUE DANS UNE SEULE
	 * DIRECTION,
	 * LE SCROLL AUTOMATIQUE FONCTIONNE MAL */

	wedit_curs_off( win);
	wind_update( BEG_MCTRL);
	graf_mouse( TEXT_CRSR, 0L);
	WindGet( win, WF_WORKXYWH, &dum, &dum, &dum, &h);
	vqt_attributes( win->graf.handle, attr);
	
	/* Annuler le bloc pr‚c‚dent */
	if( wedit->flags & BLOC)
		wedit_set_bloc( win, &wedit->begblc, &wedit->endblc, 0);
		
	/* D‚but du bloc */
	wedit_xy2curs( win, evnt.mx, evnt.my, &wedit->begblc);
	wedit->endblc = wedit->begblc;

	while( evnt.mbut) {
		
		/* Bloc interm‚daire */
		graf_mkstate( &evnt.mx, &evnt.my, &evnt.mbut, &evnt.mkstate); 
		wedit_xy2curs( win, evnt.mx, evnt.my, &temp);
				
		/* Dessin entre endblc et temp */
		if( temp.index != wedit->endblc.index
			|| temp.row != wedit->endblc.row ) {

			/* Scroll ? */
			if( win->ypos > temp.index)
				WindSet( win, WF_INFO, "Scroll up");
			else if( win->ypos + h / HCELL > temp.index) {
				WindSet( win, WF_INFO, "Scroll down");
			}
			
			/* Direction ? */

			if( temp.index > wedit->begblc.index)
				forward = 1;
			else if( temp.index < wedit->begblc.index)
				forward = 0;
			else
				forward = ( temp.row > wedit->begblc.row)? 1 : 0;
	
			/* dessin du bloc interm‚diaire */

			if( temp.index > wedit->endblc.index)
				wedit_set_bloc( win, &wedit->endblc, &temp, forward?SELECT:0);
			else if( temp.index == wedit->endblc.index) {
				if( temp.row > wedit->endblc.row)
					wedit_set_bloc( win, &wedit->endblc, &temp, forward?SELECT:0);
				else
					wedit_set_bloc( win, &temp, &wedit->endblc, forward?0:SELECT);
			} else
				wedit_set_bloc( win, &temp, &wedit->endblc, forward?0:SELECT);
		
		}		
		/* Fin du bloc */
		wedit->endblc = temp;
				
	}
	
	/* Si endblc == begblc, pas de bloc */
	if( wedit->endblc.index == wedit->begblc.index &&
		wedit->endblc.row == wedit->begblc.row ) {
		wedit->flags &= ~BLOC;
	} else {
		wedit->flags |= BLOC;
		/* Il faut inverser ? */
		if( wedit->endblc.index < wedit->begblc.index ||
			(wedit->endblc.index == wedit->begblc.index &&
			 wedit->endblc.row < wedit->begblc.row )) {
			temp = wedit->endblc;
			wedit->endblc = wedit->begblc;
			wedit->begblc = temp;
			wedit->edit->cur = wedit->begblc;
		} else 
			wedit->edit->cur = wedit->endblc;
		
		/* Copie dans le bloc */
/*		if( bloc)
			edit_free( bloc);
		bloc = edit_new();
		edit_insert_buffer( &wedit->begblc, &wedit->begblc, bloc);
 */
	}	
	graf_mouse( ARROW, 0L);
	wind_update( END_MCTRL); 
	wedit_curs_on( win);
}

