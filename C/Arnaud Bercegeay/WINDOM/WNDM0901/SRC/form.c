/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997
 *
 *	module: form.c
 *	description: Interface routines formulaires.
 */
 
#include <stdlib.h>
#include <stddef.h>
#include <stdarg.h>
#include <stdio.h>
#include "scancode.h"
#include "globals.h"
#include "userdef.h"


/******************************************
 *		Dialogues classiques
 ******************************************/

void FormBegin( OBJECT *tree, MFDB *bckgrnd) {
	INT16 x, y, w, h;
	
	/* form_center( tree, &x, &y, &w, &h); */
	GrectCenter( tree->ob_width, tree->ob_height, &x, &y);
	tree->ob_x = x;
	tree->ob_y = y;
	w = tree->ob_width;
	h = tree->ob_height;
	
	if( bckgrnd)	/* On sauvegarde le fond */
		w_get_bkgr( x-6, y-6, w+11, h+11, bckgrnd);
	else
		form_dial( FMD_START, 0, 0, 0, 0, x-6, y-6, w+11, h+11);
	if( CONF(app)->weffect == TRUE || CONF(app)->weffect == DEFVAL)
		form_dial( FMD_GROW, 0, 0, 0, 0, x, y, w, h);
	while( !wind_update( BEG_MCTRL));
	objc_draw( tree, 0, MAX_DEPTH, x-6, y-6, w+11, h+11);
}

void FormEnd( OBJECT *tree, MFDB *bckgrnd) {
	INT16 x, y, w, h;
	
/*	form_center( tree, &x, &y, &w, &h);*/
	GrectCenter( tree->ob_width, tree->ob_height, &x, &y);
	w = tree->ob_width;
	h = tree->ob_height;
	
	if( bckgrnd)
		w_put_bkgr( x-6, y-6, w+11, h+11, bckgrnd);
	else
		form_dial( FMD_FINISH, 0, 0, 0, 0, x-6, y-6, w+11, h+11);
	if( CONF(app)->weffect == TRUE || CONF(app)->weffect == DEFVAL)
		form_dial( FMD_SHRINK, 0, 0, 0, 0, x, y, w, h);
	wind_update( END_MCTRL);
}

/**************************************************
 * Dialogue en fenˆtres
 **************************************************/

/* 
 * Routine de dessin
 */

void frm_drw( WINDOW *win) {
	INT16 x, y, w, h;
	int outlined = 0;
	W_FORM	*dial = DataSearch( win, WD_WFRM);

	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	if( dial->root->ob_state & OUTLINED)
		outlined = OUTLINED_WIDTH;
	dial->root[ROOT].ob_x = x - (int)win->xpos * win->w_u + outlined;
	dial->root[ROOT].ob_y = y - (int)win->ypos * win->h_u + outlined;
	objc_draw( dial->root, ROOT, MAX_DEPTH, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
	/* Cas des champs ‚ditables */
	if ( dial->edit != -1) {
		wind_get( win -> handle, WF_TOP, &x, &y, &w, &h);
		if ( x == win -> handle)
			ObjcEdit( OC_FORM, win, dial->edit, 0, &dial->cursor, ED_INIT);
	}
}

/*
 * Routine de fermeture
 */

void frm_cls( WINDOW *win) {
	W_FORM *dial = DataSearch( win, WD_WFRM);

	/* eteindre le curseur */
	if( dial->edit != -1 ) 
		ObjcEdit( OC_FORM, win, dial->edit, 0, &dial->cursor, ED_END);
	snd_msg( win, WM_DESTROY,0,0,0,0);
}

/*
 * Routine de destruction
 */

void frm_dstry( WINDOW *win) {
	FormAttach( win, NULL, NULL);
	graf_mouse( ARROW, 0L);
}

/*
 *	Message WM_TOPPED
 */

void frm_tpd( WINDOW *win) {
	W_FORM *dial = DataSearch( win, WD_WFRM);

	WindSet( win, WF_TOP, win->handle, 0, 0, 0);
	wglb.front = win;
	ObjcEdit( OC_FORM, win, dial->edit, 0, &dial->cursor, ED_INIT);
}

/*
 * Message WM_MOVED
 */
 
void frm_mvd( WINDOW *win) {
	INT16 x, y, w, h;
	int outlined = 0;
	W_FORM *dial = DataSearch( win, WD_WFRM);
	 	
 	x = evnt.buff[4];
	y = evnt.buff[5];
	w = evnt.buff[6];
	h = evnt.buff[7];
	wind_set( evnt.buff[3], WF_CURRXYWH, x, y, w, h);
	win->status &= ~WS_FULLSIZE;
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	if( dial->root->ob_state & OUTLINED )
		outlined = OUTLINED_WIDTH;
	dial->root[ROOT].ob_x = x + outlined - (int)win->xpos*win->w_u;
	dial->root[ROOT].ob_y = y + outlined - (int)win->ypos*win->h_u;
}

void frm_fld( WINDOW *win) {
	INT16 x,y,w,h;
	int outlined = 0;
	W_FORM *dial = DataSearch( win, WD_WFRM);
	void std_fld( WINDOW *);

	std_fld( win);
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	if( dial->root->ob_state & OUTLINED )
		outlined = OUTLINED_WIDTH;
	dial->root[ROOT].ob_x = x + outlined - (int)win->xpos*win->w_u;
	dial->root[ROOT].ob_y = y + outlined - (int)win->ypos*win->h_u;
}

/*
 *	Routine de gestion du clavier
 */

void frm_keyhd( WINDOW *win) {
	W_FORM *form = DataSearch( win, WD_WFRM);
	OBJECT *dial;
	char scancode;
	int res, x2, y2;
	INT16 x, y;

	scancode = evnt.keybd >> 8;
	dial = form->root;
	
	/* Raccour‡i claviers */
	
	if( (res = frm_keybd_ev( dial)) != -1)
		;
	else if ( scancode == SC_RETURN || scancode == SC_ENTER) 
		res = obj_fd_flag( dial, ROOTS, DEFAULT);
	else if( scancode == SC_UNDO) {
		res = obj_fd_xtype( dial, res, UNDOBUT);
		if( res == -1)
			res = obj_fd_flag( dial, res, FLAGS11);
	}
	else if( scancode == SC_HELP)
		res = obj_fd_xtype( dial, res, HELPBUT);
	else if (form->edit != -1) { 
		
		/* Gestion des Editables */
		
		/* passage au champ suivant */
		if ( scancode == SC_DWARW && evnt.mkstate == 0) {
			for( res=(form->edit+1)%form->nb_ob; (res % form->nb_ob) != form->edit; res++)
				if( (dial[res%form->nb_ob].ob_flags & EDITABLE) &&
					!(dial[res%form->nb_ob].ob_flags & HIDETREE))
					break;

			if ( res%form->nb_ob != form->edit) {
				ObjcEdit( OC_FORM, win, form->edit, 0, &form->cursor, ED_END);
				form->edit = res%form->nb_ob;
				form->cursor = 0;
				ObjcEdit( OC_FORM, win, form->edit, 0, &form->cursor, ED_INIT);
			}
		}
		/* passage au champ pr‚c‚dent */
		else if ( scancode == SC_UPARW && evnt.mkstate == 0) {
			res = form->edit-1;			
			while( res != form->edit) {
				if( res<0)
					res = form->nb_ob-1;
				if( (dial[res].ob_flags & EDITABLE) && !(dial[res].ob_flags & HIDETREE))
					break;
				res --;
			}
			if ( res != form->edit) {
				ObjcEdit( OC_FORM, win, form->edit, 0, &form->cursor, ED_END);
				form->edit = res;
				form->cursor = 0;
				ObjcEdit( OC_FORM, win, form->edit, 0, &form->cursor, ED_INIT);
			}
		}
		/* Sinon, insertion caractere */
		else 
			ObjcEdit( OC_FORM, win, form->edit, evnt.keybd, &form->cursor, ED_CHAR);
		res = -1;
	}

	if( res != -1) {
		objc_offset( dial, res, &x, &y);
		x2 = evnt.mx; y2 = evnt.my;
		evnt.mx = x + dial[res].ob_width/2-1;
		evnt.my = y + dial[res].ob_height/2-1;
		res = frm_buttn_ev( win, OC_FORM);
		if( res == -1)
			return ;
		evnt.mx = x2; evnt.my = y2;
		snd_msg( win, WM_FORM, res, evnt.mkstate, 0, 0);
	}
}

/*
 * Routine de gestion des clics souris
 */
 
void frm_click( WINDOW *win) {
	int res;
	W_FORM *form = DataSearch( win, WD_WFRM);

	if( !(evnt.mbut & 0x01))
		return;
#if GFORM
	res = frm_buttn_ev( win, OC_FORM);
#else
	res = objc_find( form->root, ROOT, MAX_DEPTH, evnt.mx, evnt.my);			
#endif
	if( res != -1)  /* On g‚nŠre un ‚v‚nement WM_FORM au lieu du MU_BUTTON) */
		snd_msg( win, WM_FORM, res, evnt.nb_click, evnt.keybd, 0);
}

/*
 *	On attache un formulaire … une fenˆtre
 */

int FormAttach( WINDOW *win, OBJECT *tree, void *proc) {
	W_FORM *form;

	/* Attach a form */
	if( tree != NULL) {
		int outlined=0;
		INT16 dum, x, y;

		form = (W_FORM *)malloc( sizeof(W_FORM));
		if( !form) return -69;
		
		/* A form was already attached */
		if( win->status & WS_FORM)	
			FormAttach( win, NULL, NULL);
	
		if( tree -> ob_state & OUTLINED)
			outlined = OUTLINED_WIDTH;

		EvntAttach( win, WM_REDRAW, frm_drw);
		EvntAttach( win, WM_FORM, proc);
		EvntAttach( win, WM_MOVED, frm_mvd);
		EvntAttach( win, WM_TOPPED, frm_tpd);
		EvntAttach( win, WM_FULLED, frm_fld);
		EvntAttach( win, WM_XBUTTON, frm_click);
		EvntAttach( win, WM_XKEYBD, frm_keyhd);
		EvntAdd	  ( win, WM_DESTROY, frm_dstry, EV_TOP);
		
		DataAttach( win, WD_WFRM, form);
		win->status |= WS_FORM;

		form->root = tree;
		form->real = tree;
		form->save = NULL;
		form->bind = NULL;
		form->edit = obj_fd_flag( tree, 0, EDITABLE);
		
		/* Num‚ro du premier TEDINFO, -1 s'il n'y en a pas */
		form->cursor = 0;		  
		
		/* Position curseur */
		/* if( form->edit != -1) */
		/* Nombre d'objets dans le dialogue */
		form->nb_ob = obj_nb( tree);
		
		/* Index de l'objet racine */
		WindGet( win, WF_WORKXYWH, &x, &y, &dum, &dum);
		form->root->ob_x = x - (int)win->xpos * win->w_u + outlined;
		form->root->ob_y = y - (int)win->ypos * win->h_u + outlined;
		
		/* Gestion des ascenseurs */
		graf_handle( &win -> w_u, &win -> h_u, &dum, &dum);
		win -> xpos = win -> ypos = 0;
		win -> xpos_max = (tree[0].ob_width+2*outlined)/win -> w_u;
		win -> ypos_max = (tree[0].ob_height+2*outlined)/win -> h_u;

		/* taille maxi */
		WindCalc( WC_BORDER, win, 0, 0, tree[0].ob_width+2*outlined, 
				  tree[0].ob_height+2*outlined, &x, &x, &win->w_max, &win->h_max);
	} else {
		/* On libŠre le formulaire de la fenˆtre */	
			
		form = DataSearch( win, WD_WFRM);

		RsrcUserFree( form->root);
		if( form->bind) free( form->bind);
		if( form->save) free( form->save);
		if( win->status & WS_FORMDUP) ObjcFree( form->root);
		DataDelete( win, WD_WFRM);
		free( form);

		win -> status &= ~WS_FORM;

		EvntAttach( win, WM_REDRAW, WindClear);
		EvntRemove( win, WM_DESTROY, frm_dstry);
		EvntDelete( win, WM_FORM);
		EvntAttach( win, WM_MOVED, std_mvd);
		EvntAttach( win, WM_TOPPED, std_tpd);
		EvntDelete( win, WM_XKEYBD);

		win -> xpos = win -> ypos = 0;
		win -> xpos_max = win -> ypos_max = 1;
	}
	return 0;
}

/*
 *  This function creates and open easily at screen a 
 *	window form.
 */

WINDOW *FormCreate( OBJECT *tree, int GemAttrib, void *proc, char *nom, GRECT *taille, int grow, int dup) {
	register WINDOW *win = wglb.first;
	GRECT coord;
	INT16 x, y, w, h, dum;
	int outlined = 0;
	W_FORM *form;
	
	/* Case the window is already created */
	if( !dup)
	while( win) {
		if( win -> status & WS_FORM) {
			form = DataSearch( win, WD_WFRM);
			if( form->root == tree) {
				if( win -> status & WS_ICONIFY) {
					WindGet( win, WF_UNICONIFY, &x, &y, &w, &h);
					snd_msg( win, WM_UNICONIFY, x, y, w, h);
				} else if( win -> status & WS_OPEN) 
					/* window opened */
					wind_set( win -> handle, WF_TOP, 0, 0, 0, 0);
				else {
					wind_get( win->handle, WF_PREVXYWH, &x, &y, &w, &h);
					WindOpen( win, x, y, w, h);
				}
				return win;
			}
		}
		win = win -> next;
	}
	
	for( dum = 0; dum < 10; app.work_in[dum++] = 1);
	app.work_in[10] = 2;
	win = WindCreate( GemAttrib, app.x, app.y, app.w, app.h);
	if( win == NULL) return NULL;

	if( tree -> ob_state & OUTLINED)
		outlined = OUTLINED_WIDTH;

	if( !taille) {
		coord.g_w = tree->ob_width + 2*outlined;
		coord.g_h = tree->ob_height + 2*outlined;
		WindCalc( WC_BORDER, win, 0, 0, coord.g_w, coord.g_h, &x, &y, &coord.g_w, &coord.g_h);
		GrectCenter( coord.g_w, coord.g_h, &coord.g_x, &coord.g_y);

		/* Si le formulaire est trop grand, on force les
		 * assenceurs 
		 */

		if( coord.g_w >= app.w || coord.g_h >= app.h) {
			WindDelete( win);
			if( coord.g_w >= app.w)
				GemAttrib |= HSLIDE|LFARROW|RTARROW|SIZER;
			if( coord.g_h >= app.h)
				GemAttrib |= VSLIDE|DNARROW|UPARROW|SIZER;
			win = WindCreate( GemAttrib, app.x, app.y, app.w, app.h);
		}
	} else
		coord = *taille;
	
	win -> name = nom;
	if( grow) win -> status |= WS_GROW;
	WindOpen( win, coord.g_x, coord.g_y, coord.g_w, coord.g_h);
	FormAttach( win, tree, proc);
	form = DataSearch( win, WD_WFRM);

	/* Form have to be duplicated */
	if( dup) {
		win -> status |= WS_FORMDUP;
		form->root = ObjcDup( tree, win);
		if( form->root == NULL) {
			WindDelete( win);
			return 0;
		}	
	}

	WindSetStr( win, WF_NAME, nom);
	WindSet( win, WF_BEVENT, B_UNTOPPABLE, 0, 0, 0);
	WindSlider(win, HSLIDER|VSLIDER);
	return( win);
}


/*****************************************
 * Dialogue en fenˆtre modale
 *****************************************/

WINDOW *FormWindBegin( OBJECT *dial, char *nom) {
	WINDOW *win;

	win = FormCreate( dial, CONF(app)->mwidget, NULL, nom, NULL, 1, 0);
	if( win == NULL) return NULL;
	EvntDelete( win, WM_DESTROY);
	MenuDisable();
	WindSet( win, WF_BEVENT, B_MODAL, 0, 0, 0);
	return win;
}

/*
 *	A voir: FormWinDo( int Evnt);
 */

int FormWindDo( int Evnt) {
	int evnt_res;

	while( 1) {
		evnt_res = EvntWindom( Evnt);
		
		if( (evnt_res & MU_MESAG)) {
			switch( evnt.buff[ 0]) {

			case WM_FORM:
				return( evnt.buff[ 4]);
			case WM_DESTROY:
				return( -1);
			}
		}
		/* else  */
		if( Evnt & FORM_EVNT)
			return (evnt_res|FORM_EVNT);
	}
}

void FormWindEnd( void) {
	WINDOW *win = wglb.appfront;

	FormAttach( win, NULL, NULL);
	WindClose( win);
	WindDelete( win);
	MenuEnable();
}

/**********************************************************
 *	Autres fonctions
 **********************************************************/

int FormSave( WINDOW *win, int mode) {
	W_FORM *wform;
	int co;
	
	if( mode == OC_FORM)
		wform = DataSearch( win, WD_WFRM);
	else
		wform = &win->tool;
	
	if( wform->save == NULL)
		wform->save = (int *)malloc( sizeof(int)*wform->nb_ob);
	if( wform->save == NULL)
		return -39;
	for( co=0; co<wform->nb_ob; co++)
		wform->save[ co] = wform->root[co].ob_state;
	return 0;
}

int FormRestore( WINDOW *win, int mode)	{
	W_FORM *wform;
	int co;
	
	if( mode == OC_FORM )
		wform =  DataSearch( win, WD_WFRM);
	else
		wform = &win->tool;

	if( !wform->save)
		return -1;
	for( co=0; co<wform->nb_ob; co++)
		wform->root[co].ob_state = wform->save[ co];
	return 0;
}

int FormAlert( int but, char fmt[], ...) {
	va_list list;
	char alrt[255];
	
	va_start( list, fmt);
	vsprintf( alrt, fmt, list);
	va_end( list);
	return form_alert( but, alrt);
}

/*******************************************************
 * Gestion automatique des onglets 
 *******************************************************/

typedef struct _thumb {
	/* liens boutons <-> onglets */
	int *idxthb;
	int *idxbut;
	/* nombre d'onglets */
	int nbbut;
	/* onglet actif (index dans idxthb et idxbut) */
	int selbut;
} THUMB;

/* magic number r‚serv‚ */
#define WD_WTHB	0x57544842L	/* 'WTHB', a mettre dans global.h */

/* Fonction qui sera li‚e aux boutons des onglets (priv‚e) */

static void thumb_do( WINDOW *win, int obj) {
	W_FORM *form = DataSearch( win, WD_WFRM);
	THUMB *thumb = DataSearch( win, WD_WTHB);
	int i, idx;

	/* index du bouton s‚lectionn‚ dans thumb->button */
	idx = -1;
	for( i=0; i<thumb->nbbut; i++) {
		if( thumb->idxbut[i] == obj) {
			idx = i;
			break;
		}
	}

	/* bouton trouv‚ et nouveau bouton */
	if( idx != -1 && idx != thumb -> selbut) {
		/* montrer le nouvel onglet */
		form->root[thumb->idxthb[idx]].ob_flags &= ~HIDETREE;
		/* cacher l'ancien onglet */
		form->root[thumb->idxthb[thumb->selbut]].ob_flags |= HIDETREE;
		/* button actif */
		thumb->selbut = idx;
		form->edit = -1; 	/* WinDom bug */
		/* dessin de l'onglet */
		ObjcDraw( OC_FORM, win, thumb->idxthb[idx], MAX_DEPTH);
		/* dessin du bouton */
		ObjcDraw( OC_FORM, win, thumb->idxbut[idx], 0);
	}
}

/* Cr‚ation de l'onglet */

int FormThumb( WINDOW *win, int *idxthb, int *idxbut, int nb) {
	W_FORM *form = DataSearch( win, WD_WFRM);
	THUMB *thumb;
	int i;
	
	thumb = (THUMB*)malloc( sizeof( THUMB));
	if( !thumb)	return -69;
	thumb -> idxthb = malloc( sizeof(int)*nb);
	if( !thumb -> idxthb) {
		free( thumb);
		return -69;
	}
	thumb -> idxbut = malloc( sizeof(int)*nb);
	if( !thumb -> idxbut) {
		free( thumb->idxthb);
		free( thumb);
		return -69;
	}
	for( i=0; i<nb; i++) {
		thumb -> idxthb[i] = idxthb[i];
		thumb -> idxbut[i] = idxbut[i];
		ObjcAttach( OC_FORM, win, idxbut[i], BIND_FUNC, thumb_do);
	}
	thumb -> nbbut = nb;
	thumb -> selbut = 0;
	DataAttach( win, WD_WTHB, thumb);
	
	if( form) {
		for(i=0; i<nb; i++) {
			form->root[idxthb[i]].ob_flags |= HIDETREE;
			form->root[idxbut[i]].ob_state &= ~SELECTED;
			form->root[idxbut[i]].ob_flags |= RBUTTON;
		}
		form->root[idxthb[0]].ob_flags &= ~HIDETREE;
		form->root[idxbut[0]].ob_state |= SELECTED;
	}
	
	return 0;
}

/* Lib‚ration de l'onglet */

void FormThbFree( WINDOW *win) {
	THUMB *thumb = DataSearch( win, WD_WTHB);
	free( thumb->idxthb);
	free( thumb->idxbut);
	free( thumb);
	DataDelete( win, WD_WTHB);
}

/* S‚lectionne un onglet */

void FormThbSet( WINDOW *win, int but) {
	/* S‚lectionner le bouton */
	evnt.buff[3] = win->handle;
	evnt.buff[4] = but;
	evnt.buff[5] = 0;
	/* EvntExec( win, WM_FORM); */
	/* */
	thumb_do( win, but);
}

/*
 * Retourne l'onglet actif 
 * type = 0 : le bouton actif
 * type = 1 : l'onglet actif
 */

int FormThbGet( WINDOW *win, int type) {
	THUMB *thumb = DataSearch( win, WD_WTHB);
	if( thumb) {
		if( type == 0)
			return thumb->idxbut[thumb->selbut];
		else 
			return thumb->idxthb[thumb->selbut];
	} else
		return -1;
}

/* EOF */