/*
 *	WinDom - Dominique B‚r‚ziat
 *	Tous droits r‚serv‚s … l'auteur 1994/1995/1996/1997/1998
 *	module: stdcode.c
 *	description : les routines standards des fenˆtres
 */

#include <stddef.h>
#include <stdlib.h>
#include "globals.h"


/*	Fonctions utilitaires scrolls
 */

void move_screen( int vhandle, GRECT *screen, int dx, int dy) {
	INT16 xy[ 8];
	long dum = 0L;
	GRECT g;
	
	/* on intersecte avec l'‚cran */
	wind_get( 0, WF_CURRXYWH, &g.g_x, &g.g_y, &g.g_w, &g.g_h);
	rc_intersect( &g, screen);
	xy[ 0] = screen -> g_x;
	xy[ 1] = screen -> g_y;
	xy[ 2] = xy[ 0] + screen -> g_w - 1;
	xy[ 3] = xy[ 1] + screen -> g_h - 1;
	xy[ 4] = xy[ 0] + dx;
	xy[ 5] = xy[ 1] + dy;
	xy[ 6] = xy[ 2] + dx;
	xy[ 7] = xy[ 3] + dy;
	vro_cpyfm( vhandle, S_ONLY, xy, (MFDB *)&dum, (MFDB *)&dum);
}

void move_work(WINDOW *win, int dx, int dy) {
	INT16 x,y,w,h;
	GRECT rect, r1, r2;

	if (dx || dy) 
	{
		WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
		while( !wind_update(BEG_UPDATE));
		graf_mouse( M_OFF, 0L);		
		rc_set( &rect, x, y, w, h);
		wind_get( win -> handle, WF_FIRSTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
		while (r1.g_w && r1.g_h) {
			if( rc_intersect( &rect, &r1)) {
				if ( (abs(dx) < r1.g_w) && (abs(dy) < r1.g_h) )
				{
					r2 = r1; /* save */
					if (dy > 0) {
						r1.g_y += dy;
						r1.g_h -= dy;
					} else {
						r1.g_h += dy;
					}
					if (dx > 0) {
						r1.g_x += dx;
						r1.g_w -= dx;
					} else {
						r1.g_w += dx;
					}
					move_screen( win->graf.handle, &r1, - dx, - dy);
					if (dx)
					{
						r1 = r2 ;  /* restore */
						if (dx > 0) {
							r1.g_x += r1.g_w - dx;
							r1.g_w = dx;
						} else {
							r1.g_w = - dx;
						}
						if (dy > 0) {
							r1.g_h -= dy;
						} else {
							r1.g_y -= dy;
							r1.g_h += dy;
						}
						rc_clip_on( win->graf.handle, &r1);
						EvntExec( win, WM_REDRAW);
						rc_clip_off( win->graf.handle);
					}
					if (dy)
					{
						r1 = r2 ;  /* restore */
						if (dy > 0) {
							r1.g_y += r1.g_h - dy;
							r1.g_h = dy;
						} else {
							r1.g_h = - dy;
						}
						rc_clip_on( win->graf.handle, &r1);
						EvntExec( win, WM_REDRAW);
						rc_clip_off( win->graf.handle);
					}
				}
				else
				{
					rc_clip_on( win->graf.handle, &r1);
					EvntExec( win, WM_REDRAW);
					rc_clip_off( win->graf.handle);
				}
			}
			wind_get( win -> handle, WF_NEXTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
		}
		graf_mouse( M_ON, 0L);
		wind_update(END_UPDATE);
		if (dx) WindSlider( win, HSLIDER);
		if (dy) WindSlider( win, VSLIDER);
	}
}

void draw_page( WINDOW *win, int x, int y, int w, int h) {
	GRECT r1, rect;
	
	while( !wind_update(BEG_UPDATE));
	graf_mouse( M_OFF, 0L);		
	rc_set( &rect, x, y, w, h);
	wind_get( win -> handle, WF_FIRSTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	while (r1.g_w && r1.g_h) {
		if( rc_intersect( &rect, &r1)) {
			rc_clip_on( win->graf.handle, &r1);
			EvntExec( win, WM_REDRAW);
			rc_clip_off( win->graf.handle);
		}
		wind_get( win -> handle, WF_NEXTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	}
	graf_mouse( M_ON, 0L);
	wind_update(END_UPDATE);
}


/*************************************************************/
/*	======  Fonctions d'‚venements fenetre standard  ======= */
/*************************************************************/

void std_cls( WINDOW *win) {	
	snd_msg( win, WM_DESTROY,0,0,0,0);
}

void std_mvd( WINDOW *win) {	
	wind_set( evnt.buff[3], WF_CURRXYWH, evnt.buff[4], evnt.buff[5], evnt.buff[6], evnt.buff[7]);
	win->status &= ~WS_FULLSIZE;
}

void std_tpd( WINDOW *win) {
	WindSet( win, WF_TOP, win->handle, 0, 0, 0);
	wglb.appfront = wglb.front = win;
}

void std_szd( WINDOW *win) {
	INT16 x, y, w, h;
	int rdw = 0;
	unsigned long oldx, oldy;
	
	w = MAX( evnt.buff[6], win -> w_min);
	h = MAX( evnt.buff[7], win -> h_min);
	w = MIN( evnt.buff[6], win -> w_max);
	h = MIN( evnt.buff[7], win -> h_max);

	wind_set( evnt.buff[3], WF_CURRXYWH, evnt.buff[4], evnt.buff[5], w, h);

	/* Cas une fenetre de contenu proportionnel ie qui ne 
	   depend pas des win->x etc .. */
	
	if( win->xpos == 0 && win->xpos_max == 1 &&
		win->ypos == 0 && win->ypos_max == 1)
		rdw = 1;
		
	/* Nouvelle version : Gere les cas ou la fenetre est + grande
		que les 'tailles' des donn‚es */
		
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	oldx = win -> xpos;
	oldy = win -> ypos;
	if( (unsigned int)w > win -> xpos_max * win -> w_u)
		win -> xpos = 0;
	else
		win -> xpos = MIN( win -> xpos, win -> xpos_max - w / win -> w_u);

	if( (unsigned int)h > win -> ypos_max * win -> h_u)
		win -> ypos = 0;
	else
		win -> ypos = MIN( win -> ypos, win -> ypos_max - h / win -> h_u);

	/*    fin    */

	if( oldx != win -> xpos || oldy != win -> ypos)
		rdw = 1;
	WindSlider( win, HSLIDER|VSLIDER);
	win->status &= ~WS_FULLSIZE;
	if( rdw) snd_rdw( win);
}

void std_fld( WINDOW *win) {
	INT16 x, y, w, h;

	if( win->status & WS_FULLSIZE) {
		wind_get( evnt.buff[3], WF_PREVXYWH, &x, &y, &w, &h);
		wind_set( evnt.buff[3], WF_CURRXYWH, x, y,  w, h);
	} else
		wind_set(evnt.buff[3], WF_CURRXYWH, app.x, app.y, win->w_max, win->h_max);
	
	win->status ^= WS_FULLSIZE;

	/* Cas une fenetre de contenu proportionnel ie qui ne 
	   depend pas des win->x etc .. */
	
	if( win->xpos == 0 && win->xpos_max == 1 &&
		win->ypos == 0 && win->ypos_max == 1)
		snd_rdw( win);
		
	/* Nouvelle version : Gere les cas ou la fenetre est + grande
		que les 'tailles' des donn‚es */
		
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	if( (unsigned int)w > win -> xpos_max * win -> w_u)
		win -> xpos = 0;
	else
		win -> xpos = MIN( win -> xpos, win -> xpos_max - w / win -> w_u);

	if( (unsigned int)h > win -> ypos_max * win -> h_u)
		win -> ypos = 0;
	else
		win -> ypos = MIN( win -> ypos, win -> ypos_max - h / win -> h_u);

	/*    fin    */

	WindSlider( win, HSLIDER|VSLIDER);
}

void std_icn( WINDOW *win) {
	WindSet( win, WF_ICONIFY, evnt.buff[4], evnt.buff[5], evnt.buff[6], evnt.buff[7]);
	WindSet( win, WF_BOTTOM, win->handle, 0, 0, 0);
	if( win->icon.name)
#ifdef __GEMLIB__
		wind_set_str( win->handle, WF_NAME, win->icon.name);
#else
		wind_set( win->handle, WF_NAME, ADR(win->icon.name), 0, 0);
#endif
}

void std_unicn( WINDOW *win) {
	if( win->status & WS_ALLICNF) {
		WINDOW *scan;
		
		MenuEnable();
		for( scan=wglb.first; scan; scan=scan->next) {
			if( scan != win && scan->status & WS_ALLICNF) {
				WindOpen( scan, scan->icon.x, scan->icon.y, scan->icon.w, scan->icon.h);
				scan->status &= ~WS_ALLICNF;
			/*	EvntWindom( MU_MESAG); */
			}
		}
		win->status &= ~WS_ALLICNF;
		WindSet( win, WF_TOP, win->handle, 0, 0, 0);
	}
	WindSet( win, WF_UNICONIFY, evnt.buff[4], evnt.buff[5], evnt.buff[6], evnt.buff[7]);
	WindSet( win, WF_TOP, win->handle, 0, 0, 0);
	if( win->name)
#ifdef __GEMLIB__
		wind_set_str( win->handle, WF_NAME, win->name);
#else
		wind_set( win->handle, WF_NAME, ADR(win->name), 0, 0);
#endif
}

void std_allicn( WINDOW *win)
{
	WINDOW *scan;
	
	MenuDisable();

	/* On ferme toutes les fenˆtres, sauf celle ci */
	for( scan = wglb.first; scan; scan=scan->next) {
		if( scan->status & WS_OPEN && scan != win) {
			scan->status |= WS_ALLICNF;
			WindGet( scan, WF_CURRXYWH, &scan->icon.x, &scan->icon.y, &scan->icon.w, &scan->icon.h);
			WindClose( scan);
		/*	EvntWindom( MU_MESAG); */
		}
	}
	win->status |= WS_ALLICNF;
	/* On iconifie notre fenˆtre */
	std_icn( win);
}



/*
	void std_dnpgd( WINDOW *):
		fonction standart pour le champs win->dnpaged.
*/

void std_dnpgd( WINDOW *win) {
	int page;
	INT16 x,y,w,h;
	long old_pos = win -> ypos;
	int dy;
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	page = h / win -> h_u;
	if ( win -> ypos < win -> ypos_max - page) {
		win -> ypos = MIN( win->ypos_max, win->ypos) + page;
		win -> ypos = MIN( win -> ypos, win -> ypos_max - page);
		dy = (int) ((win->ypos - old_pos) * win->h_u);
		move_work(win,0,dy);
	}
}

/*
	void std_uppgd( WINDOW *):
		fonction standart pour le champs win->uppaged.
*/

void std_uppgd( WINDOW *win) {
	long pos;
	INT16 dum, h;
	int dy;

	if ( win -> ypos > 0L)
	{
		WindGet( win, WF_WORKXYWH, &dum, &dum, &dum, &h);
		pos = MAX( 0L, win->ypos - h / win->h_u);
		dy = (int) ((pos - win->ypos) * win->h_u);
		win->ypos = pos;
		move_work(win,0,dy);
	}
}

/*
	void std_uplnd( WINDOW*):
		fonction standart pour le champs win->uplined.
*/

void std_uplnd( WINDOW *win) {
	if ( win -> ypos > 0L) {
		win->ypos --;
		move_work(win,0, - win->h_u);
	}
}

/*
	void std_dnlnd( WINDOW *):
		fonction standart pour le champs win->dnlined.
*/

void std_dnlnd( WINDOW *win) {
	INT16 x, y, w, h;

	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	if (( win -> ypos < win -> ypos_max - h / win -> h_u) &&
	    ( win -> ypos_max > h / win -> h_u )) {
		win -> ypos ++;
		move_work(win,0,win->h_u);
	}
}

void std_vsld( WINDOW *win) {
	long pos;
	INT16 h, dum;
	int dy;

	WindGet( win, WF_WORKXYWH, &dum, &dum, &dum, &h);
	pos = (long)(win->ypos_max - h/win->h_u)*(long)evnt.buff[4]/1000L;
	if (pos < 0) pos = 0;
	dy = (int)((pos - win->ypos) * win->h_u);
	win->ypos =  (int) pos;
	if( dy) move_work( win, 0, dy);
}

void std_hsld( WINDOW *win) {
	INT16 w, dum;
	long pos;
	int dx;

	WindGet( win, WF_WORKXYWH, &dum, &dum, &w, &dum);
	pos = (long)(win->xpos_max - w/win->w_u)*(long)evnt.buff[4]/1000L;	
	if (pos < 0) pos = 0;
	dx = (int)((pos - win->xpos) * win->w_u );
	win->xpos =  (int) pos;
	if (dx) move_work(win,dx,0);
}

void std_lflnd( WINDOW *win) {
	if ( win -> xpos > 0) {
		win -> xpos --;
		move_work(win,-win->w_u,0);
	}
}

void std_rtlnd( WINDOW *win) {
	INT16 dum, w;

	WindGet( win, WF_WORKXYWH, &dum, &dum, &w, &dum);
	if( ( win -> xpos < win -> xpos_max - w / win -> w_u) &&
	    ( win -> xpos_max > w / win -> w_u )) {
		win -> xpos ++;
		move_work(win,win->w_u,0);
	}
}

void std_lfpgd( WINDOW *win) {
	long pos;
	INT16 dum, w;
	int dx;

	if ( win -> xpos > 0L) {
		WindGet( win, WF_WORKXYWH, &dum, &dum, &w, &dum);
		pos = MAX( 0L, win->xpos - w / win->w_u);
		dx = (int)((pos - win->xpos) * win->w_u);
		win->xpos = pos;
		move_work(win,dx,0);
	}
}

void std_rtpgd( WINDOW *win) {
	int page;
	INT16 x,y,w,h;
	long old_pos = win -> xpos;
	int dx;
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	page = w / win -> w_u;
	if ( win -> xpos < win -> xpos_max - page) {
		win -> xpos = MIN( win -> xpos_max, win -> xpos) + page;
		win -> xpos = MIN( win -> xpos, win -> xpos_max - page);
		dx = (int)((win->xpos - old_pos) * win->w_u);
		move_work(win,dx,0);
	}
}

void std_arw( WINDOW *win) {
	switch( evnt.buff[4]) {
	case WA_UPPAGE:
		std_uppgd( win);
		break;
	case WA_DNPAGE:
		std_dnpgd( win);
		break;
	case WA_RTPAGE:
		std_rtpgd( win);
		break;
	case WA_LFPAGE:
		std_lfpgd( win);
		break;
	case WA_UPLINE:
		std_uplnd( win);
		break;
	case WA_DNLINE:
		std_dnlnd( win);
		break;
	case WA_RTLINE:
		std_rtlnd( win);
		break;
	case WA_LFLINE:
		std_lflnd( win);
		break;
	}
}

/*
 * fonction "standard" pour d‚placer les sliders
 * en temps r‚el en fonction du d‚placement de la souris
 * tant que un des boutons de la souris est appuy‚
 */

void std_mwk( WINDOW *win) {
	INT16 k, dum;
	INT16 x0,y0,x,y;
	INT16 w,h;
	int dx, dy;
	long xpos_bornesup;
	long ypos_bornesup;
	MFORM mform;

	WindGet( win, WF_WORKXYWH, &dum, &dum, &w, &h);
	xpos_bornesup = win -> xpos_max - (long)w / (long)win -> w_u;
	if (xpos_bornesup < 0) xpos_bornesup = 0;
	ypos_bornesup = win -> ypos_max - (long)h / (long)win -> h_u;
	if (ypos_bornesup < 0) ypos_bornesup = 0;
	
	if( app.aes4 & AES4_XGMOUSE)
		graf_mouse( M_SAVE, &mform);
	graf_mouse( FLAT_HAND,NULL);
	wind_update( BEG_MCTRL);
	
	graf_mkstate(&x0,&y0,&k,&dum);
	x = x0;
	y = y0;
	
	while (k) {
		/* calcul du d‚placement dx */
		dx = (x0 - x) / win->w_u; /* unit = like "pos" */
		if (dx < 0) {  /* direction = right ==> slider to left */
			if ( - dx > win->xpos) dx = - (int) win->xpos;
		} else {       /* direction = left ==> slider to right */
			if ( win->xpos + dx > xpos_bornesup) dx = (int)(xpos_bornesup - win->xpos);
		}
		win->xpos += dx;
		dx *= win->w_u; /* unit = pixel */
		x0 -= dx;

		/* calcul deplacement dy */
		dy = (y0 - y) / win->h_u; /* unit = like "pos" */
		if (dy < 0) {  /* direction = down ==> slider to up */
			if ( - dy > win->ypos) dy = - (int) win->ypos;
		} else {       /* direction = up ==> slider to down */
			if ( win->ypos + dy > ypos_bornesup) dy = (int)(ypos_bornesup - win->ypos);
		}
		win->ypos += dy;
		dy *= win->h_u; /* unit = pixel */
		y0 -= dy;
		
		/* perform the move */
		if (dx || dy) move_work(win,dx,dy);
	
		graf_mkstate(&x,&y,&k,&dum);
	}

	wind_update(END_MCTRL);
	if( app.aes4 & AES4_XGMOUSE && graf_mouse( M_RESTORE, &mform)) {
		/* cannot restore the mouse ? set mouse to default value (arrow) */
		graf_mouse(ARROW,NULL);
	}
}
/*
 *	Fonction standard de mise en arriŠre plan
 *  d'une fenˆtre.
 */

void std_btm( WINDOW *win) {
	WindSet( win, WF_BOTTOM, 0, 0, 0, 0);
}

/*
 *	Fonction standard de destruction
 *  elle doit normalement lib‚rer
 *  la m‚moire (champ data)
 */

void std_dstry( WINDOW *win) {
	WindClose( win);
	WindDelete( win);
	if( !wglb.first && !app.menu)
		snd_msg( NULL, AP_TERM,0,0,0,0);
}

/*
 *	Non window standard functions (binded by ApplInit)
 */

void std_fntchg( WINDOW *win) {
	UNUSED( win);
	if( vq_gdos()) {
		vst_unload_fonts( app.handle, 0);
		app.gdos = vst_load_fonts( app.handle, 0) + app.work_out[10];
	}
}


/* EOF */