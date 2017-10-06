/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2000
 *
 *	module: evnt.c
 *	description: librairie ‚v‚nements AES
 */

#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "av.h"
#include "globals.h"
#include "cookie.h"


/************************************************/
/* snd_aes: envoie … l'AES un message de REDRAW */
/************************************************/

void snd_rdw( WINDOW *win) {
	INT16 x, y, w, h;
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	ApplWrite( app.id, WM_REDRAW, win->handle, x, y, w, h);
}

/*
 *	snd_arrw: envoi un message WA_? a l'AES
 */

void snd_arrw( WINDOW *win, int type) {
	ApplWrite( app.id, WM_ARROWED, win->handle, type, 0, 0, 0);	
}

/*
 * snd_msg : envoi un message simple … l'AES
 * par exemple WM_CLOSED, WM_TOPPED, ...
 */

void snd_msg( WINDOW *win, int msg, int par1, int par2, int par3, int par4) {
	ApplWrite( app.id, msg, win?win->handle:0, par1, par2, par3, par4);
}

/*
 *	Nouveaux messages AES 4 ( fonction interne)
 */

/*
 *	Fonction interne calculant les positions des fenetres
 *  pour les messages WF_ICONIFY ...
 */

static int __CDECL (*icfs)( int f, ...);

void give_iconifyxywh( INT16 *x, INT16 *y, INT16 *w, INT16 *h) {
	int pos=0, pmax;
	
	if( app.aes4 & AES4_ICONIFY) {
		*x = *y = *w = *h = -1;
	} else if( get_cookie( ICFS_COOKIE, (long*)&icfs)) {
		pos = (*icfs)( ICF_GETPOS, x, y, w, h);
		(*icfs)( ICF_FREEPOS, pos);
	} else {
		pmax = app.w/CONF(app)->wicon;
		for(; __iconlist[ pos]; pos ++);
		*x = app.x + (pos % pmax)*CONF(app)->wicon;
		*y = app.y + app.h -(pos / pmax + 1)*CONF(app)->hicon;
		*w = CONF(app)->wicon;
		*h = CONF(app)->hicon;
	}
}

/*
 *	Retourne 1 s'il y a une fenˆtre modale
 */
 
int is_modal( void) {
	return( wglb.appfront && (wglb.appfront->status & WS_MODAL));
}

/*
 *	Mise … jour des fenetres ( fonction interne)
 */

void _do_update( WINDOW *win) {
	GRECT win_rect, r1, rw;
#ifndef __MINIWINDOM__
	int dy=0;
	INT16 x, y, w, h;
#endif

	while( !wind_update(BEG_UPDATE));
	graf_mouse( M_OFF, 0L);
	
	rc_set( &win_rect, evnt.buff[4], evnt.buff[5], evnt.buff[6], evnt.buff[7]);
	wind_get( win->handle, WF_FIRSTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
#ifndef __MINIWINDOM__
	wind_get( win->handle, WF_WORKXYWH, &x, &y, &w, &h);
#endif
	WindGet( win, WF_WORKXYWH, &rw.g_x, &rw.g_y, &rw.g_w, &rw.g_h);
	while (r1.g_w && r1.g_h) {
		if ( rc_intersect( &win_rect, &r1)) {
			rc_clip_on( win->graf.handle, &r1);
#ifndef __MINIWINDOM__
			if( win -> status & WS_MENU && !(win->status & WS_ICONIFY)) {
				menu_draw( win, r1.g_x, r1.g_y, r1.g_w, r1.g_h);
				dy = win->menu.root[1].ob_height+1;
			}
			if( win -> status & WS_TOOLBAR && !(win->status & WS_ICONIFY)) {				
				win->tool.root->ob_x = x;
				win->tool.root->ob_y = y + dy;
				objc_draw( win->tool.root, 0, MAX_DEPTH, r1.g_x, r1.g_y, r1.g_w, r1.g_h);
			}
#endif
			if( win->status & WS_ICONIFY && win->icon.draw != NULL)
				(*win->icon.draw)( win);
			else if( rc_intersect( &rw, &r1)) {
				rc_clip_on( win->graf.handle, &r1);
				EvntExec( win, WM_REDRAW);				
			}
			rc_clip_off( win->graf.handle);
		}

		wind_get( evnt.buff[3], WF_NEXTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	}
	graf_mouse( M_ON, 0L);
	wind_update(END_UPDATE);
}

/*
 *	Traitement des ‚v‚nements messages - interne
 *	Valeur retourn‚e: 0 - continuer le traitement dans EvntWindom()
 *					  1 - non
 */

static 
int _do_evnt_msg( int *evnt_res) {
	INT16 top, dum;
	INT16 x, y, w, h;
	EV_MSG *msg;
	WINDOW *win;
	
	/* 1/ Gestion de la palette */
	/* WM_UNTOPPED = on passe en arriŠre plan
	 * WM_ONTOP	   = une fenetre d'une autre application passe
	 *	   			 en premier plan (cas multi application) 
	 */
	if( !(CONF(app)->flag & NOPALETTE) && (
		   evnt.buff[ 0] == WM_UNTOPPED 
		|| evnt.buff[ 0] == WM_ONTOP 
		|| evnt.buff[ 0] == WM_TOPPED)) {
		
		wind_get( 0, WF_TOP, &top, &dum, &dum, &dum);
		if ( (win = WindHandle( top)) == NULL) 	/* C'est pas … nous */
			w_setpal( app.palette);	
		else
			w_setpal( win -> graf . palette);
	}
	
	/* On v‚rifie si l'‚v‚nement concerne une fenˆtre */
	dum = evnt.buff[0];
	msg = EvntFind( NULL, evnt.buff[0]);
	if( msg && (msg -> flags & EVM_ISWIN)) {
		win = WindHandle( evnt.buff[3]);
		msg = EvntFind( win, evnt.buff[0]);
	} else
		win = NULL;

	/* Ev‚nements fenˆtres */
	if( win && msg) {
		
		/* 2/ Cas sp‚ciaux : ‚v‚nements sensibles ou
			  				 ‚mulation de certains messages */
		switch ( evnt.buff[0]) {
		case WM_REDRAW:
			_do_update( win);
			break;
		case WM_TOPPED:
			/* ‚mulation WF_BEVENT/B_UNTOPPABLE
			 * lorsque le systŠme ne le supporte pas */
			if( win->status & WS_UNTOPPABLE
				&& !(app.aes4 & AES4_BEVENT)) {
				wind_get( win->handle, WF_WORKXYWH, &x, &y, &w, &h);
				if( evnt.mx >= x && evnt.my >= y) {
					*evnt_res |= MU_BUTTON;
					evnt.mbut |= 0x01;
				}
				break;
			}
			/* Cas des fenˆtres modales */
			if( is_modal()) {
				EvntExec( wglb.appfront, WM_TOPPED);
				break;
			}
#ifndef __MINIWINDOM__
			/* s‚lection en arriŠre plan des menus et des toolbars */
			if( win->status & WS_MENU) {
				dum = objc_find( win->menu.root, 0, MAX_DEPTH, evnt.mx, evnt.my);
				if( dum != -1 && win->menu.root[dum].ob_type == G_TITLE ) {
					*evnt_res |= MU_BUTTON;
					evnt.mbut |= 0x01;
					break;
				}
			}
			if( win->status & WS_TOOLBAR) {
				dum = objc_find( win->tool.root, 0, MAX_DEPTH, evnt.mx, evnt.my);
				if( dum != -1 && win->tool.root[dum].ob_flags & (SELECTABLE|TOUCHEXIT) )
				{
					*evnt_res |= MU_BUTTON;
					evnt.mbut |= 0x01;
					break;
				}
			}

#endif
			if( win->status & WS_ICONIFY)
				std_tpd( win);
			else {				
				WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
				if( CONF(app)->flag & BUTTON_ON_MOUSE && IS_IN( evnt.mx, evnt.my, x, y, w, h)) {
					*evnt_res |= MU_BUTTON;
					evnt.mbut |= 0x01;
				} else 
					EvntExec( win, evnt.buff[0]);
			}
			break;

		case WM_BOTTOMED:
			if( !(win -> status & WS_MODAL))
				WindSet( win, WF_BOTTOM, evnt.buff[3], 0, 0, 0);
			break;
		
		case WM_ICONIFY:
			if( win -> status & WS_MODAL && win == wglb.appfront)
				/* on transforme le message */
				snd_msg( win, WM_ALLICONIFY, evnt.buff[4], evnt.buff[5], evnt.buff[6], evnt.buff[7]);
			else
				EvntExec( win, WM_ICONIFY);
			break;
		case WM_MOVED:
#ifndef __MINIWINDOM__
			/* Mettre … jour le menu */
			if( win -> status & WS_MENU ) {
				wind_get( win->handle, WF_CURRXYWH, &x, &y, &dum, &dum);
				win->menu.root->ob_x += evnt.buff[4]-x;
				win->menu.root->ob_y += evnt.buff[5]-y;
			}
			/* Mettre … jour le toolbar */
			if( win -> status & WS_TOOLBAR ) {
				wind_get( win->handle, WF_CURRXYWH, &x, &y, &dum, &dum);
				win->tool.root->ob_x += evnt.buff[4]-x;
				win->tool.root->ob_y += evnt.buff[5]-y;
			}
#endif
			if( win -> status & WS_ICONIFY)
				std_mvd( win);
			else  {
				if( !(app.aes4 & AES4_BOTTOM) && (evnt.mkstate & 0x02 || evnt.mkstate & 0x01)) {
					snd_msg( win, WM_BOTTOMED,0,0,0,0);
					return 1;
				}
				EvntExec( win, evnt.buff[0]);
			}
			break;
		case WM_FULLED:
#ifndef __MINIWINDOM__
			if( win -> status & WS_MENU ) {
				wind_get( win->handle, WF_CURRXYWH, &x, &y, &dum, &dum);
				win->menu.root->ob_x += evnt.buff[4]-x;
				win->menu.root->ob_y += evnt.buff[5]-y;
			}
			if( win -> status & WS_TOOLBAR ) {
				wind_get( win->handle, WF_CURRXYWH, &x, &y, &dum, &dum);
				win->tool.root->ob_x += evnt.buff[4]-x;
				win->tool.root->ob_y += evnt.buff[5]-y;
			}
#endif
			EvntExec( win, evnt.buff[0]);
			break;
		case WM_CLOSED:
			/* -> ‚mulation l'ic“nification <- */
			if( evnt.mkstate & (K_LSHIFT|K_RSHIFT|K_CTRL) 
				&& (app.aes4 & AES4_SMALLER) == 0 ) {
				give_iconifyxywh( &x, &y, &w, &h);
				if( evnt.mkstate & 0x03)
					snd_msg( win, WM_ICONIFY, x, y, w, h);
				else
					snd_msg( win, WM_ALLICONIFY, x, y, w, h);
			} else if( app.aes4 & AES4_APPLCONTROL 
					   && evnt.mkstate & (K_LSHIFT|K_RSHIFT)) {
				/* -> masquer application <- */
				ApplControl( app.id, APC_HIDE);
			} else {
				if( is_modal() && win != wglb.appfront)
					return 0;
				EvntExec( win, evnt.buff[0]);
			}
			break;
			
		/* ici pas de break, car on fait un EvntExec() apres  */
		case WM_FORM:
		case WM_TOOLBAR:
			if( *evnt_res & MU_BUTTON)
				*evnt_res &= ~MU_BUTTON;
		default:
			EvntExec( win, evnt.buff[0]);
			break;
		}
	} 

	/* Cas binding de menu du bureau : viens avant
	   un ‚ventuel attachement au message MN_SELECTED :
	   comme pour les menus en fenetre */
	if( evnt.buff[0] == MN_SELECTED && app.mnbind)
		menu_bind( NULL, evnt.buff[4], evnt.buff[3]);	
	
	/* Ev‚nements autres */
	if( !win && msg)
		EvntExec( NULL, evnt.buff[0]);

	/* Ev‚nements sp‚ciaux */
	if( !msg) {
	 	switch( evnt.buff[0]) {
		case AP_BUTTON:
			/* WM_BUTTON devient un MU_BUTTON */
			*evnt_res 	 &= ~MU_MESAG;
			*evnt_res 	 |= MU_BUTTON;
			evnt.mx   	  = evnt.buff[3];
			evnt.my   	  = evnt.buff[4];
			evnt.mbut 	  = evnt.buff[5];
			evnt.mkstate  = evnt.buff[6];
			evnt.nb_click = evnt.buff[7];
			break;
		case AP_KEYBD:
			/* WM_KEYBD devient un MU_KEYBD */
			*evnt_res 	&= ~MU_MESAG;
			*evnt_res 	|= MU_KEYBD;
			evnt.mkstate = evnt.buff[3];
			evnt.keybd 	 = evnt.buff[4];
			break;
		}
	} 
	return 0;
}

/***********************************************************************/

int EvntWindom( int evntflag) {
	int evnt_res;
	INT16 top, dum;
	int mu_button=0;
	int mu_keybd=0;
	WINDOW *win, *mwin;
	INT16 x, y, w, h;
	EV_MSG *evmsg;
	
	/*
	 * Sont consider‚ comme messages:
	 *	- le menu systeme
	 *	- les menus en fenetres
	 *	- les toolbars
	 *  - les formulaires
	 *  - les raccourcis claviers
	 *	MU_BUTTON et MU_KEYBD sont impos‚s pour ces ‚venements
	 *		aussi il n'y a pas de message MU_BUTTON ou MU_KEYBD
	 *		retourn‚.
	 *  le mˆme travail est	 … faire pour EvntMesag 
	 */
	
	if( (evntflag & MU_BUTTON) == 0) {
		mu_button = 1;
		evntflag |= MU_BUTTON;
	}
	if( (evntflag & MU_KEYBD) == 0) {
		mu_keybd = 1;
		evntflag |= MU_KEYBD;
	}


EVNT:
#ifdef __GEMLIB__
	evnt_res = evnt_multi( evntflag,
			evnt.bclick, evnt.bmask, evnt.bstate,
			evnt.m1_flag, evnt.m1_x, evnt.m1_y, evnt.m1_w, evnt.m1_h,
			evnt.m2_flag, evnt.m2_x, evnt.m2_y, evnt.m2_w, evnt.m2_h, 
			evnt.buff,
			evnt.timer,
			&evnt.mx, &evnt.my, &evnt.mbut, &evnt.mkstate,
			&evnt.keybd, &evnt.nb_click);
#else  /* !defined __GEMLIB__ */
	evnt_res = evnt_multi( evntflag,
			evnt.bclick, evnt.bmask, evnt.bstate,
			evnt.m1_flag, evnt.m1_x, evnt.m1_y, evnt.m1_w, evnt.m1_h,
			evnt.m2_flag, evnt.m2_x, evnt.m2_y, evnt.m2_w, evnt.m2_h, 
			evnt.buff,
			(int) evnt.timer, (int)(evnt.timer >> 16),
			&evnt.mx, &evnt.my, &evnt.mbut, &evnt.mkstate,
			&evnt.keybd, &evnt.nb_click);
#endif /* __GEMLIB__ */

	if(	(evnt_res & MU_MESAG) && (_do_evnt_msg( &evnt_res) == 1))
		goto EVNT;
	
	/* fenˆtre frontale */
	wind_get( 0, WF_TOP, &top, &dum, &dum, &dum);
	wglb.front = WindHandle( top);


	/* fenˆtre sous la souris */
	mwin = WindHandle( wind_find( evnt.mx, evnt.my));

	/* Gestion des ‚venements boutons */

	if( evnt_res & MU_BUTTON) {

		/* Cas d'une fenˆtre modale */
		if( is_modal() && mwin != wglb.appfront) {
			/* On toppe la fenˆtre modale */
			snd_msg( wglb.appfront, WM_TOPPED, 0, 0, 0, 0);
			goto ICI;
		}

		evmsg = EvntFind( mwin, WM_XBUTTON);
				
		if( mwin && evnt.mbut & 0x01) {	
			/* Cas d'une fenˆtre iconifi‚e */
			if( mwin ->status & WS_ICONIFY) {
				if( evnt.nb_click == 2) {
					WindGet( mwin, WF_UNICONIFY, &x, &y, &w, &h);
					snd_msg( mwin, WM_UNICONIFY, x, y, w, h);
				}
				goto ICI;
			}
#ifndef __MINIWINDOM__
			/* On clique sur un menu */
			if( mwin -> status & WS_MENU && is_menu( mwin)) {
				if( frm_menu( mwin) != -1)
					goto ICI; /* on passe a la suite du traitement */
				else
					EvntExec( mwin, WM_TOPPED); /* on top si on ne selectionne rien */
			}
			/* On clique sur un toolbar */
			if( mwin -> status & WS_TOOLBAR) {
				int res;

#if GFORM
				res = frm_buttn_ev( mwin, OC_TOOLBAR);
#else
				res = objc_find( mwin->tool.root, ROOT, MAX_DEPTH, 
								 evnt.mx, evnt.my);
#endif
				 
				if( res != -1) {
					snd_msg( mwin, WM_TOOLBAR, res, evnt.keybd, 0, 0);
					goto ICI;
				}
			}
#endif /*__MINIWINDOM__*/
			/* formulaire */
			if( mwin -> status & WS_FORM) {
				WindGet( mwin, WF_WORKXYWH, &x, &y, &w, &h);
				if( IS_IN(evnt.mx, evnt.my, x, y, w, h)) {
					EvntExec( mwin, WM_XBUTTON);
				/*	(*evmsg->proc)(mwin);	*/
					goto ICI;
				}
			}
		}

		/* Les autres cas */
		if( !mu_button && mwin && evmsg) {
			WindGet( mwin, WF_WORKXYWH, &x, &y, &w, &h);
			if( IS_IN(evnt.mx, evnt.my, x, y, w, h))
				EvntExec( mwin, WM_XBUTTON);
			/*	(*evmsg->proc)(mwin);	*/
		}
		
		/* Pour que EvntAttach( NULL) fonctionne  */
		EvntExec( NULL, WM_XBUTTON);
	}

ICI:
	/* Gestion des ‚v‚nements clavier */
	if( evnt_res & MU_KEYBD) {

		/* Gestion du mode KEYBD_ON_MOUSE */
		if( CONF(app)->flag & KEYBD_ON_MOUSE)
			win = WindHandle( wind_find( evnt.mx, evnt.my));
		else
			win = wglb.front;

		evmsg = EvntFind( win, WM_XKEYBD);

		/* Cas d'une fenˆtre modale */
		if( is_modal() && win != wglb.appfront)
			win = NULL;

		/* Gestion des raccourcis clavier */
#ifndef __MINIWINDOM__
		if( !(CONF(app)->flag & KEYMENUOFF) 
			&& (menu_exec_cmd( win) || menu_exec_cmd( NULL)))
			;
		else if( win && win->status & WS_TOOLBAR
			     && (dum = frm_keybd_ev( win->tool.root)) != -1) {
			objc_offset( win->tool.root, dum, &w, &h);
			x = evnt.mx; y = evnt.my;
			evnt.mx = w + win->tool.root[dum].ob_width/2-1;
			evnt.my = h + win->tool.root[dum].ob_height/2-1;
			dum = frm_buttn_ev( win, OC_TOOLBAR);
			evnt.mx = x; evnt.my = y;
			if( dum != -1) {
				snd_msg( win, WM_TOOLBAR, dum, evnt.keybd, 0, 0);
			}
		}
		else
#endif
			if ( win && (!mu_keybd || win->status & WS_FORM)
					 && evmsg)
			/*	(*evmsg->proc)(win);	*/
				EvntExec( win, WM_XKEYBD);

		/* Pour que EvntAttach( NULL) fonctionne  */
		EvntExec( NULL, WM_XKEYBD);
	}

	
	if( evnt_res & MU_TIMER) {
		win = wglb.first;
		while (1) {
			EvntExec( win, WM_XTIMER);
			if( !win) break;
			win = win -> next;
		}
	}
	
	if( evnt_res & MU_M1) {
		win = wglb.first;
		while (1) {
			EvntExec( win, MU_M1);
			if( !win) break;
			win = win -> next;
		}
	}

	if( evnt_res & MU_M2) {
		win = wglb.first;
		while (1) {
			EvntExec( win, MU_M2);
			if( !win) break;
			win = win -> next;
		}
	}
	
	if( mu_button) 	evnt_res &= ~MU_BUTTON;
	if( mu_keybd) 	evnt_res &= ~MU_KEYBD;
	return evnt_res;
}
