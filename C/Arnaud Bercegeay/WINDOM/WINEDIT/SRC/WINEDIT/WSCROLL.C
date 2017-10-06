/*
 *	Edition de texte
 *  D.B‚r‚ziat 1998
 *	Interfacage avec WinDom de la librairie TextEdit
 *	
 *	Routines de gestion des ‚v‚nements de scrolls
 */

#include <windom.h>
#include <libtedit.h>
#include "wglobal.h"

#include <stdio.h>
#define TRACE()	sprintf(win->info, "%d", win->ypos);WindSet(win,WF_INFO,win->info);

/* Non d‚clar‚e dans windom.h mais n‚anmmois utile */
void draw_page( WINDOW *win, int x, int y, int w, int h);

void wedit_upline( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);

	if( win -> ypos > 0) wedit->pos = wedit->pos->prev;
}

void wedit_dnline( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int x, y, w, h;
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);	
	if( win -> ypos < win -> ypos_max - h / win -> h_u)
		wedit->pos = wedit->pos->next;
}

void wedit_uppage( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int x, y, w, h;
	pos_t new, diff;
	EDLINE *scan;
	
	if ( win -> ypos > 0L) {
		WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
		new = max( 0L, win->ypos - h / win->h_u);
		diff = win->ypos - new;
		win->ypos = new;
		for( scan = wedit->pos; diff; diff--, scan = scan -> prev);
		wedit->pos = scan;
		draw_page( win, x, y, w, h);
		WindSlider( win, VSLIDER);
	}
}

void wedit_dnpage( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	int page, x,y,w,h;
	pos_t new, diff;
	EDLINE *scan;

	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	page = h / win -> h_u;
	if ( win -> ypos < win -> ypos_max - page) {
		new = min( win->ypos_max, win->ypos) + page;
		new = min( new, win -> ypos_max - page);
		diff = new - win->ypos;
		win->ypos = new;
		for( scan = wedit->pos; diff; diff--, scan = scan -> next);
		wedit->pos = scan;
		draw_page( win, x, y, w, h);
		WindSlider( win, VSLIDER);
	}
}

/* Ne sert plus a rien */

#if 0
void wedit_lfline( WINDOW *win) {
	void std_lflnd( WINDOW *win);
	
	std_lflnd( win);
}

void wedit_rtline( WINDOW *win) {
	void std_rtlnd( WINDOW *win);
	
	std_rtlnd( win);
}

void wedit_lfpage( WINDOW *win) {
	void std_lfpgd( WINDOW *win);
	
	std_lfpgd( win);
}

void wedit_rtpage( WINDOW *win) {
	void std_rtpgd( WINDOW *win);
	
	std_rtpgd( win);
}
#endif

void wedit_sld( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	void std_vsld( WINDOW *);
	void EvntRedraw( WINDOW *win);

	pos_t old = win->ypos;
	std_vsld( win);	
	printf( "%ld\n", old-win->ypos);
	if( old > win->ypos) {
		old -= win->ypos;
		while( old--) 
			wedit->pos = wedit->pos->prev;
	} else {
		old = win->ypos-old;
		while( old--) 
			wedit->pos = wedit->pos->next;
	}	
	EvntRedraw( win);
}

void wedit_upd( WINDOW *win) {
	WEDIT *wedit = DataSearch( win, WD_EDIT);
	win -> ypos_max = wedit->edit -> maxline;
	WindSlider( win, HSLIDER);
}

/* EOF */
