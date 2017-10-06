/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997
 *
 *	module: wind.c
 *	description: librairie des fonctions fenˆtres
 */

#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "av.h"
#include "globals.h"
#include "cookie.h"

/*
 * Ajoute une fenˆtre dans la liste
 */
 
void AddWindow( WINDOW* win) {
	WINDOW* winptr = wglb.first;
	
	if (winptr == NULL)
		wglb.first = win;
	else {
		while(winptr->next)
			winptr = winptr->next;
		winptr->next = win;
	}
}

/*
 * Retire une fenˆtre de la liste
 */

void RemoveWindow( WINDOW* win) {
	WINDOW* winptr = wglb.first;
	
	if (winptr == win)  	/* cas ou win = wglb.first */
		wglb.first = winptr->next;
	else {
		while (winptr->next) /* recherche de win */
			if (winptr->next == win)
				break;
			else
				winptr = winptr->next;
				
		if (winptr->next == win)
			winptr->next = winptr->next->next;
	}
}

/*********************************************************/
/* Gestion des position des sliders		 				 */
/*********************************************************/

/*
 *	Fixe les position et taille des sliders en fonction des
 *	valeurs des variables interne de gestion des ascensceurs
 */

void WindSlider( WINDOW *win, int mode) {
	INT16 x,y,w,h;
	unsigned long size, pos;
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	if( mode & VSLIDER) {
		if ( win->ypos_max < (unsigned long)h/win->h_u)
			size = 1000L;
		else
			size = MAX( 50L, (unsigned long)h*1000L/(unsigned long)(win->h_u*win->ypos_max));
		WindSet( win, WF_VSLSIZE,(int)size , 0, 0, 0);

		if( win->ypos_max > (unsigned long)h/win->h_u) {
			pos = (unsigned long)win->ypos *1000L/(unsigned long)(win->ypos_max-h/win->h_u);
			WindSet( win, WF_VSLIDE, (int)pos, 0, 0, 0);
		} else if (win->ypos) {
			win->ypos = 0;
			WindSet( win, WF_VSLIDE, 0, 0, 0, 0); 
		}
	}
	if( mode & HSLIDER) {
		if ( win->xpos_max < (unsigned long)w/win->w_u)
			size = 1000L;
		else
			size = MAX( 50L, (unsigned long)w*1000L/(unsigned long)( win->w_u*win->xpos_max));
		WindSet( win, WF_HSLSIZE, (int)size, 0, 0, 0);

		if( win->xpos_max > (unsigned long)w/win->w_u) {
			pos = (unsigned long)win->xpos*1000L/(unsigned long)(win->xpos_max-w/win->w_u);
			WindSet( win, WF_HSLIDE, (int)pos, 0, 0, 0);
		} else if (win->xpos) {
			win->xpos = 0;
			WindSet( win, WF_HSLIDE, 0, 0, 0, 0);
		}
	}
}

/***********************************************************/
/* WindClear: Efface la zone de travail d'une fenˆtre.    */
/***********************************************************/

void WindClear( WINDOW *win) {
	INT16 x, y, w, h;
	INT16 xy[4];

	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	xy[0] = x;xy[1] = y;xy[2] = x+w-1;xy[3] = y+h-1;
	vsf_interior( win->graf.handle, CONF(app)->bgpatt);
	vsf_style( win->graf.handle, CONF(app)->bgstyle);
	if( CONF(app)->bgcolor < app.color)
		vsf_color( win->graf.handle, CONF(app)->bgcolor);
	else
		vsf_color( win->graf.handle, WHITE);
		
	v_bar( win->graf.handle, xy);
}

/*************************************************************/
/*	======  Pseudo Fonctions librairie Windows	     ======= */
/*************************************************************/

WINDOW* WindCreate( int GemAttrib, int x, int y, int w, int h) {
	WINDOW* win;
	INT16 handle, dum;

	handle = wind_create( GemAttrib, x, y, w, h);
	if( handle < 0) {
#ifdef WINDOMDEBUG
		form_alert( 1, "[1][WINDOM warning:|Impossible to create a window.][Ok]");
#endif
		return NULL;
	}
	win = (WINDOW *) malloc( sizeof( WINDOW));
	if( win == NULL) {
		wind_delete( handle);
		return NULL;
	}
	rc_set( &win->createsize, x, y, w, h);
	win->attrib = GemAttrib;
	win->w_min 	= win->h_min = 40;
	win->status = WS_GROW;
	win->w_max 	= w;
	win->h_max 	= h;
	win->graf.handle = graf_handle( &dum, &dum, &dum, &dum);
	v_opnvwk( app.work_in, &win->graf.handle, app.work_out);
	win -> graf.palette = NULL;

	win->next    = NULL;
	win->handle  = handle;
	win->binding = NULL;

	EvntAttach( win, WM_REDRAW, WindClear);
	EvntAttach( win, WM_CLOSED, std_cls);
	EvntAttach( win, WM_TOPPED, std_tpd);
	EvntAttach( win, WM_BOTTOMED, std_btm);
	EvntAttach( win, WM_MOVED , std_mvd);
	EvntAttach( win, WM_SIZED , std_szd);
	EvntAttach( win, WM_FULLED, std_fld);
	EvntAttach( win, WM_ICONIFY, std_icn);
	EvntAttach( win, WM_UNICONIFY, std_unicn);
	EvntAttach( win, WM_ALLICONIFY, std_allicn);
	EvntAttach( win, WM_ARROWED, std_arw);
	EvntAttach( win, WM_UPPAGE, std_uppgd);
	EvntAttach( win, WM_DNPAGE, std_dnpgd);
	EvntAttach( win, WM_LFPAGE, std_lfpgd);
	EvntAttach( win, WM_RTPAGE, std_rtpgd);	
	EvntAttach( win, WM_UPLINE, std_uplnd);
	EvntAttach( win, WM_DNLINE, std_dnlnd);
	EvntAttach( win, WM_LFLINE, std_lflnd);
	EvntAttach( win, WM_RTLINE, std_rtlnd);
	EvntAttach( win, WM_VSLID , std_vsld);
	EvntAttach( win, WM_HSLID , std_hsld);
	EvntAttach( win, WM_DESTROY, std_dstry);

	win -> xpos 	= win -> ypos = 0;
	win -> xpos_max = win -> ypos_max = 1;
	win -> w_u = win -> h_u = 1;
	win -> menu . root = NULL;
	win -> menu . bind = NULL;
	win -> menu . hilight = NULL;
	win -> tool . root = NULL;
	win -> tool . save = NULL;
	win -> tool . bind = NULL;
	win -> icon . draw = NULL;
	win -> icon . name = NULL;
	AddWindow( win);
	win->data = NULL;
	win->type = 0;
	win->name = win->info = NULL;
	return win;	
}

void add_windowlist( int handle) {
	int top = 0;
	
	while( __windowlist[top] != -1)
		top = __windowlist[top];
	__windowlist[ top] = handle;
	__windowlist[ handle] = -1;
}

void remove_windowlist( int handle) {
	int top;
	
	for( top = 0; __windowlist[top] != handle; top = __windowlist[top]);
	__windowlist[ top] = __windowlist[ handle];
	__windowlist[ handle] = 0;
}

int WindOpen( WINDOW *win, int x, int y , int w, int h) {
	int res = 0;
	INT16 dum;
	INT16 _x;
	INT16 _y;

	add_windowlist( win->handle);
	if( app.avid != -1) ApplWrite( app.avid, AV_ACCWINDOPEN, win->handle,0,0,0,0);
	if( x == -1) {
		GrectCenter( w, h, &_x, &dum); x = _x;
	}
	if( y == -1) {
		GrectCenter( w, h, &dum, &_y); y = _y;
	}
	w = MAX( w, win->w_min);
	w = MIN( w, win->w_max);
	h = MAX( h, win->h_min);
	h = MIN( h, win->h_max);
	/* Effet de graphique toujours optionnel */
	if( win -> status & WS_GROW && CONF(app)->weffect == TRUE)
		graf_growbox( 0, 0, 0, 0, x, y, w, h);
	res = wind_open( win->handle, x, y, w, h);
#ifdef WINDOMDEBUG
	if( res == 0) form_alert( 1, "[1][WINDOM warning:|Impossible to open a window.][Ok]");
#endif
	win->status |= WS_OPEN;
	wglb.appfront = win;
	WindSlider( win, HSLIDER|VSLIDER);
	return res;
}

WINDOW* WindHandle( int handle)
{
	register WINDOW *win;

	for(win = wglb.first; win; win = win->next)
		if (win->handle == handle)
			break;
	return win;
}

int WindClose( WINDOW *win) {
	INT16 x,y,w,h;
	int res=0;

/*
	if( !(win->status & WS_OPEN))
		return -1;	*/ /* warning : fenetre d‚j… ferm‚ */
			
	/* Ajout Frame */
	if( win -> status & WS_FRAME) {
		win -> status &= ~WS_OPEN;
		return 0;
	}
	/* fin ajout frame */
	
	wind_get( win->handle, WF_CURRXYWH, &x, &y, &w, &h);
	if( win -> status & WS_OPEN) {
		res = wind_close( win -> handle);
		/* Effet de graphique toujours optionnel */
		if( win -> status & WS_GROW && CONF(app)->weffect == TRUE)
			graf_shrinkbox( 0, 0, 0, 0, x, y, w, h);
	}
	win -> status &= ~WS_OPEN;

	wind_get( 0, WF_TOP, &x, &y, &w, &h);
	wglb.front = WindHandle( x);

	
	/* la liste d'ordonnance nous permet de choisir trouver la
	   fenˆtre sous celle ci */

	for( w=0; __windowlist[w] != win->handle; w = __windowlist[w]);

	wglb.appfront = WindHandle( w);

	remove_windowlist( win->handle);
	if( app.avid != -1) ApplWrite( app.avid, AV_ACCWINDCLOSED, win->handle,0,0,0,0);

	return res;
}

int WindDelete( WINDOW *win) {
	int res=0;
	
	if( win->status & WS_OPEN)
		res = WindClose( win);

	DataClear( win);
	/* Modif frame */
	if( win->status & WS_FRAME)
		(*__rfrm)( WindHandle( win->handle), win);
	else {
		/* Pour ne pas d‚truire la fenˆtre */
		if( win->handle != -1)
			res = wind_delete( win -> handle);
		RemoveWindow( win);
	} 
	/* Fin modif frame */

	v_clsvwk( win -> graf.handle);
#ifndef __MINIWINDOM__
	if( win -> status & WS_TOOLBAR) {
		RsrcUserFree( win -> tool.root);
		ObjcFree( win -> tool.root);
		if( win -> tool.save) free( win -> tool.save);
		if( win -> tool.bind) free( win -> tool.bind);
	}
	if( win -> status & WS_MENU)
		ObjcFree( win -> menu.root);
#endif
	EvntClear( win);
	free( win);
	return res;
}

int WindCalc( int type, WINDOW *wind, int xin, int yin,
			  int win, int hin, INT16 *xout, INT16 *yout, 
			  INT16 *wout, INT16 *hout) {
	int res=0;
	
	if( wind->status & WS_ICONIFY) {
		res = wind_calc( type, MOVER|NAME, xin, yin, win, hin, xout, yout, wout, hout);
		return res;
	}
	else
		res = wind_calc( type, wind->attrib, xin, yin, win, hin, xout, yout, wout, hout);

	if( type == WC_BORDER) { /* WORK --> CURR */
		if( wind->status & WS_TOOLBAR) {
			if( wind -> tool.root -> ob_width == app.w) {
				*yout -= wind->tool.root->ob_height;
				*hout += wind->tool.root->ob_height;
			} else {
				*xout -= wind -> tool.root -> ob_width;
				*wout += wind -> tool.root -> ob_width;
			}
		}
		if( wind->status & WS_MENU) {
			*yout -= (wind->menu.root[1].ob_height+1); /* le +1 est du a la */
			*hout += (wind->menu.root[1].ob_height+1); /* ligne sous le menu */
		}
	} else {
		if( wind -> status & WS_MENU ) {
			*yout += (wind->menu.root[1].ob_height+1);
			*hout -= (wind->menu.root[1].ob_height+1);
		}
		if( wind -> status & WS_TOOLBAR ) {
			if( wind -> tool.root -> ob_width == app.w) {
				*yout += wind -> tool.root -> ob_height;
				*hout -= wind -> tool.root -> ob_height;
			} else {
				*xout += wind -> tool.root -> ob_width;
				*wout -= wind -> tool.root -> ob_width;
			}	
		}	
	}
	return res;
}


/*
 *	WindSet()  -  Set window parameters
 */

static int __CDECL (*icfs)( int f, ...);

#ifndef __MSHORT__  /* version for 32 bits compiler */

int WindSet( WINDOW *win, int mode, int _x, int _y, int _w, int _h) {
	int res=0;
	INT16 x,y,w,h;			/* arguments type entiers */
	INT16 top, pos, dum;	/* Variables temporaires */
	INT16 xi, yi, wi, hi;
	void *v1, *v2;			/* arguments type pointeur */
	
	x = _x; y = _y; w = _w; h = _h;

	v1 = (void*) (long) ( ((long)_x << 16 ) | ((long)_y & 0xFFFFL) ) ;
	v2 = (void*) (long) ( ((long)_w << 16 ) | ((long)_h & 0xFFFFL) ) ;

#else	/* version for 16 bits compiler */

int WindSet( WINDOW *win, int mode, ...) {
	va_list args;
	int res=0;
	INT16 x,y,w,h;			/* arguments type entiers */
	INT16 top, pos, dum;	/* Variables temporaires */
	INT16 xi, yi, wi, hi;
	void *v1, *v2;			/* arguments type pointeur */
			
	/* Saisie des arguments, il y en a deux type */

	va_start( args, mode);
	switch( mode) {
	case WF_NAME:
	case WF_ICONTITLE:
	case WF_ICONDRAW :
	case WF_INFO:
	case WF_MENU:
	case WF_TOOLBAR:
	case WF_HILIGHT:
		/* 1) les pointeurs */
		v1 = va_arg( args, void*);    
		v2 = va_arg( args, void*);
	default:
		/* 2) les entiers */
		x = va_arg( args, int);
		y = va_arg( args, int);
		w = va_arg( args, int);
		h = va_arg( args, int);	
	}
	va_end( args);

#endif

	/* Et maintenant l'analyse du mode */		

	/* Nouveaut‚ : si la fenˆtre est ouverte,
	 * la taille de la fenetre est ajust‚ */

	switch( mode){
	case WF_MENU:
#ifndef __MINIWINDOM__
		/* Bureau ? */
		if( win == NULL) {
			if( v1 == NULL) {
				MenuBar( app.menu, 0);
				EvntDelete( NULL, MN_SELECTED);
			} else {
				MenuBar( v1, 1);
				EvntAttach( NULL, MN_SELECTED, v2);
			}
			break;
		}
		
		if( win -> status & WS_MENU) {
			hi = win -> menu.root[1].ob_height;
			ObjcFree( win -> menu.root);
		} else 
			hi = 0;
		
		if( v1 == NULL) { /* on enlŠve le menu */
			win -> status &= ~WS_MENU;
			win -> menu.root = NULL;
			win -> menu.real = NULL;
			EvntDelete( win, WM_MNSELECTED);
			if( win->status & WS_OPEN && hi) {
				wind_get( win->handle, WF_CURRXYWH, &x, &y, &w, &h);
				h -= hi;
				wind_set( win->handle, WF_CURRXYWH, x, y, w, h);
				ApplWrite( app.id, WM_REDRAW, win->handle, x, y, w, h);
			}
		} else {
			win -> menu.root = ObjcDup( v1, win);
			win -> menu.real = (OBJECT *)v1;			
			win -> menu.scroll = 0;
			win -> status |= WS_MENU;
			EvntAttach( win, WM_MNSELECTED, v2);
			if( win->status & WS_OPEN) {
				wind_get( win->handle, WF_CURRXYWH, &x, &y, &w, &h);
				h += (win -> menu.root[1].ob_height-hi);
				wind_set( win->handle, WF_CURRXYWH, x, y, w, h);
				ApplWrite( app.id, WM_REDRAW, win->handle, x, y, w, h);
			}
		}
#endif
		break;
	case WF_NAME:
		win -> name = (char*)v1;
		if( !(win -> status & WS_ICONIFY))
#if defined(__MGEMLIB__) || defined(_PCGEMX_H_)
			res =
#endif
			wind_set_str( win->handle, WF_NAME, (char*)v1);
		break;
	case WF_ICONTITLE:
		win -> icon.name = (char*)v1;
		if( win -> status & WS_ICONIFY)
#if defined(__MGEMLIB__) || defined(_PCGEMX_H_)
			res =
#endif
			wind_set_str( win->handle, WF_NAME, (char*)v1);
		break;
	case WF_ICONDRAW:
		win -> icon.draw = (void*)v1;
		break;
	case WF_INFO:
		win->info = v1;
		if( win->status & WS_FRAME) {
			GRECT r;
			(*__calc)( win, 1, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
			(*__swgt)( win, &r, 0x20);
		}
#if defined(__MGEMLIB__) || defined(_PCGEMX_H_)
			res =
#endif
			wind_set_str( win->handle, WF_INFO, (char*)v1);
		break;

	case WF_TOOLBAR:
#ifndef __MINIWINDOM__
		if( win -> status & WS_TOOLBAR) {
			wi = ( win -> tool.root -> ob_width > win -> tool.root -> ob_height)?1:0;
			hi = wi ? win -> tool.root -> ob_height : win -> tool.root -> ob_width;
			RsrcUserFree( win -> tool.root);
			ObjcFree( win -> tool.root);
			if( win -> tool.save) free( win->tool.save);
		} else
			hi = 0;
		wind_get( win->handle, WF_CURRXYWH, &x, &y, &w, &h);
		if( win -> tool.root) ObjcFree( win -> tool.root);
		if( win -> tool.bind) free(  win -> tool.bind);
		win -> tool.bind = NULL;
		if( v1 == NULL) {
			win -> tool.root = NULL;
			win -> tool.real = NULL;
			EvntDelete( win, WM_TOOLBAR);
			win -> status &= ~WS_TOOLBAR;
			if( wi) h -= hi;
			else	w -= hi;
		} else {
			win -> tool.root = ObjcDup( v1, win);
			win -> tool.real = (OBJECT *)v1;			
			EvntAttach( win, WM_TOOLBAR, v2);
			win -> tool.save = NULL;
			win -> status |= WS_TOOLBAR;
			if( win -> tool.root -> ob_width > win -> tool.root -> ob_height) {
				win -> tool.root -> ob_width = app.w;
				h += win -> tool.root -> ob_height;
			} else {
				win -> tool.root -> ob_height = app.h;
				w += win -> tool.root -> ob_width;
			}
		}
		if( win->status & WS_OPEN) {
			wind_set( win->handle, WF_CURRXYWH, x, y, w, h);
			ApplWrite( app.id, WM_REDRAW, win->handle, x, y, w, h);
		}
#else
		if(app.aes4 & AES4_TOOLBAR)
			wind_set( win->handle, WF_TOOLBAR, x, y, w, h);
#endif
		break;
	case WF_BEVENT:
		if( x & B_UNTOPPABLE)
			win -> status |= WS_UNTOPPABLE;
		if( (app.aes4 & AES4_BEVENT) && (x & B_UNTOPPABLE)) {
			x &= ~B_MODAL;
			wind_set( win -> handle, WF_BEVENT, x, y, w, h);
		}
		if( x & B_MODAL)
			win -> status |= WS_MODAL;
		else
			win -> status &= ~WS_MODAL;
		break;
	case WF_ICONIFY:
		if( win -> status & WS_ICONIFY)
			break;
		win -> status |= WS_ICONIFY;
		wind_get( win->handle, WF_CURRXYWH, &win->icon.x, &win->icon.y, 
				  &win->icon.w, &win->icon.h);
		if( app.aes4 & AES4_ICONIFY) {
			if( win -> status & WS_GROW)
				graf_shrinkbox( x,y,w,h,win->icon.x,win->icon.y,win->icon.w,win->icon.h);
			wind_set( win->handle, WF_ICONIFY, x, y, w, h);
			if( win->icon.name)
#if defined(__MGEMLIB__) || defined(_PCGEMX_H_)
				res =
#endif
				wind_set_str( win->handle, WF_NAME, win->icon.name);
			break;
		}

		/* La fenetre est en top? */
		wind_get( 0, WF_TOP, &top, &dum, &dum, &dum);
		dum=(top==win->handle)?0:1;

		if( win -> status & WS_GROW) {
			res = 1;
			win -> status &= ~ WS_GROW;
		}
		else res = 0;
		WindClose( win);
		
		wind_delete( win->handle);
		win->handle = wind_create( NAME|MOVER, app.x, app.y, app.w, app.h);
		
			/* position des ic“nes */
		if( get_cookie( ICFS_COOKIE, (long*)&icfs)) {
			pos = (*icfs)( ICF_GETPOS, &xi, &yi, &wi, &hi);
			if( xi == x && yi == y && wi == w && hi == h)
				__iconlist[ pos] = win->handle;
			else
				(*icfs)( ICF_FREEPOS, pos);
		} else {
			for( pos = 0; __iconlist[ pos]; pos ++);
			xi = app.x + (pos%(app.w/CONF(app)->wicon))*CONF(app)->wicon;
			yi = app.y + app.h -(pos/(app.w/CONF(app)->wicon)+1)*CONF(app)->hicon;
			wi = CONF(app)->wicon;
			hi = CONF(app)->hicon;
			if( xi == x && yi == y && wi == w && hi == h)
				__iconlist[ pos] = win->handle;
		}
		
		if( res == 1)
			graf_shrinkbox( x,y,w,h,win->icon.x,win->icon.y,win->icon.w,win->icon.h);

		WindOpen( win, x, y, w, h);
		if( res == 1)
			win -> status |= WS_GROW;
		
		if( dum)
			wind_set( top, WF_TOP, 0, 0, 0, 0);

		if( win->icon.name)
			wind_set_str( win->handle, WF_NAME, win->icon.name);
		break;

	case WF_UNICONIFY:
		if( (win -> status & WS_ICONIFY) == 0)
			break;
		win -> status &= ~WS_ICONIFY;
		wind_get( win->handle, WF_CURRXYWH, &xi, &yi, &wi, &hi);
		if( app.aes4 & AES4_ICONIFY)
		{
			if( win -> status & WS_GROW)
				graf_growbox( xi,yi,wi,hi,x,y,w,h);
			wind_set( win->handle, WF_UNICONIFY, x, y, w, h);
			if( win->name)
				wind_set_str( win->handle, WF_NAME, win->name);
			break;
		}

		/* lib‚rer les positions d'ic“nes */
		for( pos = 0; __iconlist[ pos] != win->handle; pos ++); 
		__iconlist[ pos] = 0;
		if( get_cookie( ICFS_COOKIE, (long*)&icfs))
			(*icfs)( ICF_FREEPOS, pos);

		if( win -> status & WS_GROW) {
			res = 1;
			win -> status &= ~ WS_GROW;
		}
		else res = 0;

		WindClose( win);
		wind_delete( win->handle);
		win->handle = wind_create( win->attrib, win->createsize.g_x, 
								   win->createsize.g_y, win->createsize.g_w, 
								   win->createsize.g_h);

		if( res == 1)
			graf_growbox( xi, yi, wi, hi,x,y,w,h);
		
		WindOpen( win, x, y, w, h);
		if( res == 1)
			win -> status |= WS_GROW;
		
		if( win -> name)
			wind_set_str( win->handle, WF_NAME, win->name);
		if( win -> info)
			wind_set_str( win->handle, WF_INFO, win->info);
		break;
	case WF_UNICONIFYXYWH:
		if( app.aes4 & AES4_ICONIFY)
			wind_set( win->handle, WF_UNICONIFYXYWH, x, y, w, h);
		else {
			win->icon.x = x;
			win->icon.y = y;
			win->icon.w = w;
			win->icon.h = h;
		}
		break;
	case WF_WORKXYWH:
		{
			INT16 xc,yc,wc,hc;
			
			WindCalc( 0, win, x, y, w, h, &xc, &yc, &wc, &hc);
			wind_set( win->handle, WF_CURRXYWH, xc, yc, wc, hc);
		}
		break;
	case WF_BOTTOM:
		/* Si la fenˆtre est modal 
		 * on ne fait rien */
		if( is_modal() && x == wglb.appfront->handle)
			break;
		if( !(app.aes4 & AES4_BOTTOM))
		{
			if( x == __windowlist[0])
				break;
			for( w=0; __windowlist[w] != x; w = __windowlist[w]);
			__windowlist[ w] = __windowlist[ x];
			__windowlist[ x] = __windowlist[ 0];
			__windowlist[ 0] = x;
			y = __windowlist[ x];
			while( y != -1)
			{
				wind_set( y, WF_TOP, 0, 0, 0, 0);
				y = __windowlist[ y];
			}
		}
		else
			wind_set( x, WF_BOTTOM, x, 0, 0, 0);
		break;
	case WF_TOP:
		if( !(app.aes4 & AES4_BOTTOM))
		{
			y = 0;
			while( __windowlist[y] != -1)
				y = __windowlist[y];
			if( x != y ) /* une fenetre hors appl ‚tait au top ? */
			{	
				/* w = prec(x) */
				for( w=0; __windowlist[w] != x; w = __windowlist[w]);
				__windowlist[w] = __windowlist[x];
				__windowlist[y] = x;
				__windowlist[x] = -1;
			}
		}
		if( is_modal()) {
			win = wglb.appfront;
			x = win->handle;
		}
		res = wind_set( win?win->handle:x, WF_TOP, x, 0, 0, 0);
		if( (win = WindHandle(x)) != NULL)	/* fenetre a nous */
			wglb.appfront = wglb.front = win;
		break;

	/* Sliders et frame */
	case WF_HSLIDE:
		if( win->status & WS_FRAME) {
			GRECT r;
			win->frame.hsldpos= x;
			(*__calc)( win, 1, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
			(*__swgt)( win, &r, 0x8|0x40);
		}
		else
			wind_set( win->handle, mode, x, 0, 0, 0);
		break;
	case WF_VSLIDE:
		if( win->status & WS_FRAME) {
			GRECT r;
			win->frame.vsldpos = x;
			(*__calc)( win, 1, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
			(*__swgt)( win, &r, 0x10|0x40);
		}
		else
			wind_set( win->handle, mode, x, 0, 0, 0);
		break;
	case WF_HSLSIZE:
		if( win->status & WS_FRAME) {
			GRECT r;
			win->frame.hsldsize = x;
			(*__calc)( win, 1, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
			(*__swgt)( win, &r, 0x8|0x40);
		}
		else
			wind_set( win->handle, mode, x, 0, 0, 0);
		break;
	case WF_VSLSIZE:
		if( win->status & WS_FRAME) {
			GRECT r;
			win->frame.vsldsize = x;
			(*__calc)( win, 1, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
			(*__swgt)( win, &r, 0x10|0x40);
		}
		else
			wind_set( win->handle, mode, x, 0, 0, 0);
		break;

	case WF_HILIGHT:
		if( win)
			win->menu.hilight = v1;
		else
			app.hilight = v1;
	/* Les autres modes de wind_set() */
	default:
		res = wind_set( win?win->handle:0, mode, x,y,w,h);
		break;
	}
	return res;
}

/*
 *	WindGet()  -  Get window parameters
 */

#ifndef __MSHORT__

/* Version for 32 bits compilers */

int WindGet( WINDOW *win, int mode, INT16 *x, INT16 *y, INT16* w, INT16 *h ) {
	INT16 xc, yc, wc, hc;
	int res=0;
#ifndef __MINIWINDOM__
	GRECT gin, gout;
	void* proc;
#endif

#else 

/* Version for 16 bits compilers */

int WindGet( WINDOW *win, int mode, ...) {
	va_list args;
	INT16 *x, *y, *w, *h;
	INT16 xc, yc, wc, hc;
	int res=0;
#ifndef __MINIWINDOM__
	GRECT gin, gout;
	void* proc;
#endif

	va_start( args, mode);
	x = va_arg( args, INT16*);
	y = va_arg( args, INT16*);
	w = va_arg( args, INT16*);
	h = va_arg( args, INT16*);
	va_end( args);

#endif

	switch( mode) {
#ifndef __MINIWINDOM__
	case WF_MENU:
		*x = (WORD)( ((LONG)(win->menu.root)>>16) & 0x0000FFFF);
		*y = (WORD)( (LONG)(win->menu.root) & 0x0000FFFF);
		proc = EvntFind( win, WM_MNSELECTED);
		*w = (WORD)( ((LONG)(proc)>>16) & 0x0000FFFF);
		*h = (WORD)( (LONG)(proc) & 0x0000FFFF);		
		break;
	case WF_TOOLBAR:
		*x = (WORD)( ((LONG)(win->tool.root)>>16) & 0x0000FFFF);
		*y = (WORD)( (LONG)(win->tool.root) & 0x0000FFFF);
		proc = EvntFind( win, WM_TOOLBAR);
		*w = (WORD)( ((LONG)(proc)>>16) & 0x0000FFFF);
		*h = (WORD)( (LONG)(proc) & 0x0000FFFF);		
		break;
	case WF_HILIGHT:
		*x = (WORD)( ((LONG)(win->menu.hilight)>>16) & 0x0000FFFF);
		*y = (WORD)( (LONG)(win->menu.hilight) & 0x0000FFFF);		
		break;
	case WF_FTOOLBAR:
	case WF_NTOOLBAR:
		wind_get( win->handle, mode == WF_FTOOLBAR?WF_FIRSTXYWH:WF_NEXTXYWH,
				  &gin.g_x, &gin.g_y, &gin.g_w, &gin.g_h);
		rc_set( &gout, win->tool.root->ob_x, win->tool.root->ob_y,
			 		win->tool.root->ob_width, win->tool.root->ob_height);
		rc_intersect( &gin, &gout);
		*x = gout.g_x;
		*y = gout.g_y;
		*w = gout.g_w;
		*h = gout.g_h;
		break;
#endif
	case WF_WORKXYWH:
		/* Ajout frame */
		if( win -> status & WS_FRAME) {
			res = (*__calc)( win, 0, x, y, w, h);
			break;
		}
		/* fin ajout frame */
		if( win -> status & WS_ICONIFY) {
			res = wind_get( win -> handle, mode, x, y, w, h);
			break;
		}
		res = wind_get( win -> handle, WF_CURRXYWH, &xc, &yc, &wc, &hc);
		if( wc == 0 && hc == 0) {
			WindCalc( 1, win, win->createsize.g_x, win->createsize.g_y, 
						win->createsize.g_w, win->createsize.g_h, x, y, w, h);
		} else
			WindCalc( 1, win, xc, yc, wc, hc, x, y, w, h);
		break;
	case WF_CURRXYWH:
		/* Ajout frame */
		if( win -> status & WS_FRAME)
			res = (*__calc)( win, 1, x, y, w, h);
		else
			res = wind_get( win->handle, WF_CURRXYWH, x, y, w, h);
			if( *w == 0 && *h == 0) {
				*x = win->createsize.g_x;
				*y = win->createsize.g_y;
				*w = win->createsize.g_w;
				*h = win->createsize.g_h;
			}
		break;
	case WF_BEVENT:
		if( win->status & WS_UNTOPPABLE)
			*x |= B_UNTOPPABLE;
		else
			*x &= ~B_UNTOPPABLE;
		if( win->status & WS_MODAL)
			*x |= B_MODAL;
		else
			*x &= ~B_MODAL;
		break;
	case WF_ICONIFY:
		wind_get( win->handle, WF_CURRXYWH, x, h, y, w);
		*x=(win->status&WS_ICONIFY)?1:0;
		if( *x == 0 ) {
			if( get_cookie( ICFS_COOKIE, (long *)&icfs))
				(*icfs)( ICF_GETSIZE, y, w);
			else {
				*y = CONF(app)->wicon;
				*w = CONF(app)->hicon;
			}
		}
		break;
	case WF_UNICONIFY:
		*x=win->icon.x;
		*y=win->icon.y;
		*w=win->icon.w;
		*h=win->icon.h;
		break;
	case WF_BOTTOM:
		if( !(app.aes4 & AES4_BOTTOM))
			*x = __windowlist[0];
		else
			wind_get( 0, WF_BOTTOM, x, 0, 0, 0);
			
		break;
	case WF_TOP:
		/* ‚mulation WM_UNTOPPED 
		 * la fenˆtre qui ‚tait en premier plan re‡oit 
		 * le message WM_UNTOPPED */
		
		if( !(app.aes4 & AES4_UNTOPPED)){
			WINDOW *wtop;
			INT16 dum, dum2;
						
			wind_get( win->handle, WF_TOP, &dum, &dum2, &dum2, &dum2);
			wtop= WindHandle( dum);
			if( wtop)
				snd_msg( wtop, WM_UNTOPPED, 0, 0, 0, 0);
		}
		wind_get( 0, WF_TOP, x, 0, 0, 0);
		break;

	/* Sliders et frame */

	case WF_HSLIDE:
		if( win->status & WS_FRAME)
			*x=win->frame.hsldpos;
		else
			wind_get( win->handle, mode, x, y, w, h);
		break;
	case WF_VSLIDE:
		if( win->status & WS_FRAME)
			*x=win->frame.vsldpos;
		else
			wind_get( win->handle, mode, x, y, w, h);
		break;
	case WF_HSLSIZE:
		if( win->status & WS_FRAME)
			*x=win->frame.hsldsize;
		else
			wind_get( win->handle, mode, x, y, w, h);
		break;
	case WF_VSLSIZE:
		if( win->status & WS_FRAME)
			*x=win->frame.vsldsize;
		else
			wind_get( win->handle, mode, x, y, w, h);
		break;
	case WF_NAME:
		*x = (WORD)( ((LONG)(win->name)>>16) & 0x0000FFFF);
		*y = (WORD)( (LONG)(win->name) & 0x0000FFFF);
		break;
	case WF_ICONTITLE:
		*x = (WORD)( ((LONG)(win->icon.name)>>16) & 0x0000FFFF);
		*y = (WORD)( (LONG)(win->icon.name) & 0x0000FFFF);
		break;
	case WF_ICONDRAW:
		*x = (WORD)( ((LONG)(win->icon.draw)>>16) & 0x0000FFFF);
		*y = (WORD)( (LONG) (win->icon.draw) 	  & 0x0000FFFF);
		break;		
	default:
		res = wind_get( win?win->handle:0, mode, x, y, w, h);
		break;
	}
	return res;
}

/*
 *	remplacement de wind_new() pour toute version de l'AES
 *  a voir 
 */

void WindNew( void) {
	int EvntWindom( int);
	
	while( wglb.first) {
		snd_msg( wglb.first, WM_DESTROY, 0, 0, 0, 0);
		EvntWindom( MU_MESAG);
	}
	if( _AESversion >= 0x0140)
		wind_new();
	else {
		/* reset souris */
		v_show_c( app.handle, 0);
		
		wind_update( END_MCTRL);
		wind_update( END_UPDATE);
	}
}

/*
 * Nouvelle fonction pour attacher une fenˆtre externe
 * a un pointeur de fenˆtre WinDom
 */

WINDOW *WindAttach( int handle) {
	WINDOW *win;
	INT16 dum, _h;

	win = (WINDOW *)calloc( 1, sizeof(WINDOW));
	if( win == NULL) return NULL;
	win -> handle = handle;
	win -> status |= WS_OPEN;
	AddWindow( win);
	add_windowlist( handle);
	win->graf.handle = graf_handle( &dum, &dum, &dum, &dum);
	v_opnvwk( app.work_in, &win->graf.handle, app.work_out);
	win -> graf.palette = NULL;
	wind_get( handle, WF_TOP, &_h, &dum, &dum, &dum);
	if( _h == win->handle)
		wglb.front = wglb.appfront = win;
	return win;
}

/* recherche une fenetre selon diff‚rentes facons */

WINDOW *WindFind( int mode, ...) {
	int id;
	void *adr;
	long magic;
	va_list args;
	WINDOW *win;
	
	va_start( args, mode);
	if( mode == WDF_ID)
		id = va_arg( args, int);
	else if( mode == WDF_DATA)
		magic = va_arg( args, long);
	else
		adr = va_arg( args, void*);
		
	va_end( args);
	for( win = wglb.first; win; win = win->next) {
		switch ( mode) {
		case WDF_NAME:
			if( win->name && !strcmp(win->name, (char *)adr) )
				return win;
			break;
		case WDF_INFO:
			if( win->info && !strcmp(win->info, (char *)adr) )
				return win;
			break;
		case WDF_ID:
			if( win->handle == id)
				return win;
			break;
		case WDF_MENU:
			if( win->menu.real == adr)
				return win;
			break;
		case WDF_FORM:
			
			break;
		case WDF_TOOL:
			if( win->tool.real == adr)
				return win;
			break;
			
		case WDF_DATA:
			if( DataSearch( win, magic))
				return win;
			break;
		}
		
	}
	return NULL;
}

/* met en premier plan une fenetre */

void WindTop( WINDOW *win) {
	INT16 x, y, w, h;
	
	if( win -> status & WS_ICONIFY) {
		WindGet( win, WF_UNICONIFY, &x, &y, &w, &h);
		ApplWrite( app.id, WM_UNICONIFY, win->handle, x, y, w, h);
	} else if( win -> status & WS_OPEN) 
		/* window opened */
		wind_set( win -> handle, WF_TOP, 0, 0, 0, 0);
	else {
		wind_get( win->handle, WF_PREVXYWH, &x, &y, &w, &h);
		WindOpen( win, x, y, w, h);
	}
}

