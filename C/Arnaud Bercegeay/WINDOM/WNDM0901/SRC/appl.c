/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2000
 *
 *	module: appl.c
 *	description: librairie application
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "globals.h"
#include "cookie.h"
#include "fsel.h"
#include "wsystem.h"


/*
 * Configuration de Windom  (et masquage des informations)
 */

int ApplGet( int mode, ...) {
	int *v1, *v2, *v3, *v4;
	va_list list;

	if( !app.conf) return 2;
	
	va_start( list, mode);
	v1 = va_arg( list, int*);
	v2 = va_arg( list, int*);
	v3 = va_arg( list, int*);
	v4 = va_arg( list, int*);
	va_end( list);
	switch( mode) {
	case APS_ICONSIZE:
		if( v1) *v1 = CONF(app)->hicon;
		if( v2) *v2 = CONF(app)->wicon;
		break;
	case APS_FLAG:
		*v1 = CONF(app)->flag;
		break;
	case APS_WINBG:
		if( v1) *v1 = CONF(app)->bgcolor;
		if( v2) *v2 = CONF(app)->bgpatt;
		if( v3) *v3 = CONF(app)->bgstyle;
		break;
	case APS_KEYCOLOR:
		*v1 = CONF(app)->key_color;
		break;
	case APS_STRSTYLE:
		if( v1) *v1 = CONF(app)->string.font;
		if( v2) *v2 = CONF(app)->string.size;
		if( v3) *v3 = CONF(app)->string.color;
		break;
	case APS_BUTSTYLE:
		if( v1) *v1 = CONF(app)->button.font;
		if( v2) *v2 = CONF(app)->button.size;
		if( v3) *v3 = CONF(app)->button.color;
		break;
	case APS_EXITSTYLE:
		if( v1) *v1 = CONF(app)->exit.font;
		if( v2) *v2 = CONF(app)->exit.size;
		if( v3) *v3 = CONF(app)->exit.color;
		break;
	case APS_TITLESTYLE:
		if( v1) *v1 = CONF(app)->title.font;
		if( v2) *v2 = CONF(app)->title.size;
		if( v3) *v3 = CONF(app)->title.color;
		break;
	case APS_3DEFFECT:
		if( v1) *v1 = CONF(app)->actmono;
		if( v2) *v2 = CONF(app)->actcol;
		break;
	case APS_MENUEFFECT:
		*v1 = CONF(app)->menu_effect;
		break;
	case APS_BUBBLESTYLE:
		if( v1) *v1 = CONF(app)->bubble.font;
		if( v2) *v2 = CONF(app)->bubble.size;
		break;
	case APS_POPUPSTYLE:
		if( v1) *v1 = CONF(app)->popcolor;
		if( v2) *v2 = CONF(app)->popborder;
		if( v3) *v3 = CONF(app)->popfcolor;
		if( v4) *v4 = CONF(app)->poppatt;
		break;
	case APS_POPUPWIND:
		*v1 = CONF(app)->popwind;
		break;
	case APS_WINDOWS:
		if( v1) *v1 = CONF(app)->wcenter;
		if( v2) *v2 = CONF(app)->weffect;
		if( v3) *v3 = CONF(app)->mwidget;
		break;
	case APS_XEDITTEXTSTYLE:
		if( v1) *v1 = CONF(app)->xedit_text.font;
		if( v2) *v2 = CONF(app)->xedit_text.size;
		if( v3) *v3 = CONF(app)->xedit_text.color;
		break;
	case APS_XEDITLABELSTYLE:
		if( v1) *v1 = CONF(app)->xedit_label.font;
		if( v2) *v2 = CONF(app)->xedit_label.size;
		if( v3) *v3 = CONF(app)->xedit_label.color;
		break;
	case APS_XTEDINFOSTYLE:
		if( v1) *v1 = CONF(app)->xtedinfo.font;
		if( v2) *v2 = CONF(app)->xtedinfo.size;
		if( v3) *v3 = CONF(app)->xtedinfo.color;
		if( v4) *v4 = CONF(app)->xtdinf_smlfnt;
		break;
	case APS_XLONGEDITSTYLE:
		if( v1) *v1 = CONF(app)->xlongedit.font;
		if( v2) *v2 = CONF(app)->xlongedit.size;
		if( v3) *v3 = CONF(app)->xlongedit.color;
		if( v4) *v4 = CONF(app)->xlgedt_smlfnt;
		break;
	default:
		return 1;	/* Error */
	}	
	return 0;	/* No Error */
}

static void set_value( int *var, int val) {
	if( val != -1)
		*var = (short)val;
}

int ApplSet( int mode, ...) {
	short v1, v2, v3, v4;
	va_list list;
	
	if( !CONF(app)) return 2;
	
	va_start( list, mode);
	v1 = va_arg( list, short);
	v2 = va_arg( list, short);
	v3 = va_arg( list, short);
	v4 = va_arg( list, short);
	va_end( list);

	switch( mode) {
	case APS_ICONSIZE:
		set_value( &CONF(app)->hicon, v1);
		set_value( &CONF(app)->wicon, v2);
		break;
	case APS_FLAG:
		set_value( (int *)&CONF(app)->flag , v1);
		break;
	case APS_WINBG:
		set_value( &CONF(app)->bgcolor, v1);
		set_value( &CONF(app)->bgpatt,  v2);
		set_value( &CONF(app)->bgstyle, v3);
		break;
	case APS_KEYCOLOR:
		set_value( &CONF(app)->key_color, v1);
		break;
	case APS_STRSTYLE:
		set_value( &CONF(app)->string.font, v1);
		set_value( &CONF(app)->string.size, v2);
		set_value( &CONF(app)->string.color, v3);
		break;
	case APS_BUTSTYLE:
		set_value( &CONF(app)->button.font, v1);
		set_value( &CONF(app)->button.size, v2);
		set_value( &CONF(app)->button.color, v3);
		break;
	case APS_EXITSTYLE:
		set_value( &CONF(app)->exit.font, v1);
		set_value( &CONF(app)->exit.size, v2);
		set_value( &CONF(app)->exit.color, v3);
		break;
	case APS_TITLESTYLE:
		set_value( &CONF(app)->title.font, v1);
		set_value( &CONF(app)->title.size, v2);
		set_value( &CONF(app)->title.color, v3);
		break;
	case APS_3DEFFECT:
		set_value( &CONF(app)->actmono, v1);
		set_value( &CONF(app)->actcol, v2);
		break;
	case APS_MENUEFFECT:
		set_value( &CONF(app)->menu_effect, v1);
		break;
	case APS_BUBBLESTYLE:
		set_value( &CONF(app)->bubble.font, v1);
		set_value( &CONF(app)->bubble.size, v2);
		break;
	case APS_POPUPSTYLE:
		set_value( &CONF(app)->popcolor, v1);
		set_value( &CONF(app)->popborder, v2);
		set_value( &CONF(app)->popfcolor, v3);
		set_value( &CONF(app)->poppatt, v4);
		break;
	case APS_POPUPWIND:
		set_value( &CONF(app)->popwind, v1);
		break;
	case APS_WINDOWS:
		set_value( &CONF(app)->wcenter, v1);
		set_value( &CONF(app)->weffect, v2);
		set_value( &CONF(app)->mwidget, v3);
		break;
	case APS_XEDITTEXTSTYLE:
		set_value( &CONF(app)->xedit_text.font, v1);
		set_value( &CONF(app)->xedit_text.size, v2);
		set_value( &CONF(app)->xedit_text.color, v3);
		break;
	case APS_XEDITLABELSTYLE:
		set_value( &CONF(app)->xedit_label.font, v1);
		set_value( &CONF(app)->xedit_label.size, v2);
		set_value( &CONF(app)->xedit_label.color, v3);
		break;
	case APS_XTEDINFOSTYLE:
		set_value( &CONF(app)->xtedinfo.font, v1);
		set_value( &CONF(app)->xtedinfo.size, v2);
		set_value( &CONF(app)->xtedinfo.color, v3);
		set_value( &CONF(app)->xtdinf_smlfnt, v4);
		break;
	case APS_XLONGEDITSTYLE:
		set_value( &CONF(app)->xlongedit.font, v1);
		set_value( &CONF(app)->xlongedit.size, v2);
		set_value( &CONF(app)->xlongedit.color, v3);
		set_value( &CONF(app)->xlgedt_smlfnt, v4);
		break;
	default:
		return 1;
	}
	return 0;
}

int ApplInit( void) {
	INT16 dum;
	
	if ( (app.id = appl_init()) == -1)
		return -1;

	app.aeshdl = graf_handle( &dum, &dum, &dum, &dum);
	vq_extnd( app.aeshdl, 0, app.work_out);
	app.color  = app.work_out[ 13];
	vq_extnd( app.aeshdl, 1, app.work_out);
	app.nplanes = app.work_out[ 4];
	app.palette = (W_COLOR *) malloc( app.color * sizeof( W_COLOR));
	w_getpal( app.palette);

	wind_get( 0, WF_WORKXYWH, &app.x, &app.y, &app.w, &app.h);
	graf_mouse( ARROW, 0L);
	app.work_in[0] = Getrez() + 2;
	for( dum = 1; dum < 10; app.work_in[ dum ++] = 1);
	app.work_in[10] = 2;
	app.handle = app.aeshdl;
	v_opnvwk( app.work_in, &app.handle, app.work_out);
	if( app.y+app.h-1 >=240)
		_res = 1;
	else
		_res = 0;
	CONF(app)->hicon = _res?72:36;
	
	for( dum = 1; dum<MAX_WINDOW; __windowlist[dum++]=0);
	__windowlist[0]=-1;
	for( dum = 0; dum<MAX_ICON; __iconlist[dum++]=0);
	app.aes4 = 0;

	/* Interrogation extensions systŠmes 
	 * la fonction appl_getinfo() retourne 1 
	 * quand l'information est disponible, 0 sinon */

	if( has_appl_getinfo() ) {
		INT16 parm1, parm3;

		if( appl_getinfo( 12 /* AES_MESSAGE */, &parm1, &dum, &parm3, &dum) == 1) {
			if( parm1 & 0x0002 )
				app.aes4 |= AES4_UNTOPPED;
			if( parm1 & 0x0040 )
				app.aes4 |= AES4_BOTTOM;
			if( (parm1 & 0x0080) && (parm1 & 0x0100) && (parm1 & 0x0200)) {
				app.aes4 |= AES4_ICONIFY;
				app.aes4 |= AES4_TOOLBAR;
			}
			if( parm3 & 0x0001 )	/* support des coordonn‚es */
				app.aes4 |= AES4_ICONIFYXYWH;
		}
		
		if( appl_getinfo( AES_WINDOW, &parm1, &dum, &parm3, &dum) == 1) {
			if( parm3 & 0x0001 )
				app.aes4 |= AES4_SMALLER;
			if( parm3 & 0x0002 )
				app.aes4 |= AES4_BOTTOMER;
			if( parm1 & 0x0020)
				app.aes4 |= AES4_BEVENT;
		}
		if( appl_getinfo( AES_PROCESS, &dum, &dum, &parm3, &dum) == 1) {
			if( parm3 == 1) app.aes4 |= AES4_APPSEARCH;
		}
		/* Les fonctions fslx_() sont-elles dispos ? */
		if( appl_getinfo( 7 /* AES_EXTENSION */, &parm1, &dum, &dum, &dum) == 1) {
			if( parm1 & 0x0008) app.aes4 |= AES4_FSLX;
		}
		/* Mode extendues de graf_mouse dispo ? */
		if( appl_getinfo( AES_MOUSE, &parm1, &dum, &dum, &dum) == 1) {
			if( parm1 == 1) app.aes4 |= AES4_XGMOUSE;
		}
	} else {
		BXKT_STR *value;

		if( _AESversion >= 0x0340) { /* AES Falcon */
			app.aes4 |= AES4_UNTOPPED;
			app.aes4 |= AES4_BEVENT;
		}

		/* Les fonctions fslx_() sont dispos avec BoxKite 2 */
		if( get_cookie( HBFS_COOKIE, (long*)&value) && value->magic == HBFS_MAGIC && value->version >= 0x200 )
			app.aes4 |= AES4_FSLX;
	}
	if( vq_naes() > 0 || vq_magx() >= 0x0310) 
		app.aes4 |= AES4_APPLCONTROL;
	app.gdos = vq_gdos() ? vst_load_fonts( app.handle, 0)+app.work_out[10] : 0;
	app.avid = -1;
	app.ntree = -1;
	app.hilight = NULL;
	app.menu = NULL;
	app.mnbind = NULL;
#ifdef WINDOMDEBUG
	{
		FILE *fp;
		fp = fopen( LOGFILE, "w");
		if( fp) fclose( fp);
	}
#endif
#ifndef __MINIWINDOM__
	init_scroll_menu();
#endif
	ConfRead();
#ifdef __GEMLIB__
	_AESglobal = aes_global;
#else
	_AESglobal = (short *)_GemParBlk.global;
#endif

	/* Default binding */
	EvntAttach( NULL, AP_LOADCONF, ConfRead);
	EvntAttach( NULL, FNT_CHANGED, std_fntchg);

	app.pipe = Galloc( PIPE_SIZE);
	return app.id;
}

static int __CDECL (*icfs)( int f, ...);

int ApplExit( void) {
	int dum;
	extern char * __confdef_buffer, * __confapp_buffer;

	/* lib conf */
	if( __confapp_buffer)
		free( __confapp_buffer);
	if( __confdef_buffer)
		free( __confdef_buffer);
	
	if( get_cookie( ICFS_COOKIE, (long*)&icfs))
		for( dum = 0; dum<MAX_ICON; dum++)
			if( __iconlist[dum]) (*icfs)( ICF_FREEPOS, dum);

	if( !(CONF(app)->flag & NOPALETTE))
		w_setpal( app.palette);
	free( app.palette);
	if( app.gdos)
		vst_unload_fonts( app.handle, 0);
	if( __bubble_quit != -1 ) {
		evnt.buff[0] = AP_TERM;
        evnt.buff[1] = (WORD)app.id;
        evnt.buff[2] = 0;
        appl_write( __bubble_quit, 16, evnt.buff);
	}
	v_clsvwk( app.handle);
	EvntClear( NULL);
	if( app.pipe) Mfree( app.pipe);
	if( app.mnbind) free( app.mnbind);
	return( appl_exit());
}

/* A faire: ApplGetinfo() et ApplName() */

int ApplName( char *name, int id) {
	INT16 i,m=0x0F;

	if( app.aes4 & AES4_APPSEARCH) {
		if( appl_search(APP_FIRST, name, &m, &i) == 0) {
			*name = '\0';
			return 0;
		}
		if( i == id)
			return 1;
		while( appl_search(APP_NEXT, name, &m, &i)) {
			if( i == id )
				return 1;
		}
	}
	*name = '\0';
	return 0;
}

/* La fonction appl_write en plus pratique */

#ifndef __MSHORT__

/* en 32bits, on attend des 'int' plutot que '...' (va_args) en parametre */
/* car c'est le seul moyen d'‚viter l'utilisation du code genre           */
/* ApplWrite( to, msg, "tralala");                                        */
/* qui fonctionne uniquement en 16 bits si on utilise va_args             */

int ApplWrite( int to, int msg, int b3, int b4, int b5, int b6, int b7) {
	INT16 buf[8];

	buf[0] = msg;
	buf[1] = app.id;
	buf[2] = 0;
	buf[3] = b3;
	buf[4] = b4;
	buf[5] = b5;
	buf[6] = b6;
	buf[7] = b7;
	return appl_write( to, 16, buf);
}

#else 

int ApplWrite( int to, int msg, ...) {
	va_list args;	
	short buf[8];

	buf[0] = msg;
	buf[1] = app.id;
	buf[2] = 0;
	va_start( args, msg);
	buf[3] = va_arg( args, short);
	buf[4] = va_arg( args, short);
	buf[5] = va_arg( args, short);
	buf[6] = va_arg( args, short);
	buf[7] = va_arg( args, short);
	va_end( args);
	return appl_write( to, 16, buf);
}
#endif

/*
 * ApplControl() est une fonction de Naes. MagiC offre les
 * mˆmes actions mais sous une forme diff‚rente. Cette fonction
 * unifie le tout.
 */

#define MA	0x4D41	/* 'MA' */
#define GX	0x4758	/* 'GX' */

int ApplControl( int ap_cid, int ap_cwhat) {
	void *dummy = 0;  /* initialized to avoid GCC warning */
	if( vq_naes() > 0) {
		/* parametre mystere dans appl_control */
		return appl_control( ap_cid, ap_cwhat, dummy);
	} else if( vq_magx() >= 0x0310) {
		switch( ap_cwhat) {
		case APC_HIDE:
			ApplWrite( SCREENMGR, SM_M_SPECIAL, 0, MA, GX, SMC_HIDEACT, 0);
			break;
		case APC_SHOW:
			ApplWrite( SCREENMGR, SM_M_SPECIAL, 0, MA, GX, SMC_UNHIDEALL, 0);
			break;
		case APC_TOP:
			/* on peut le faire diff‚rement */
			break;
		case APC_HIDENOT:
			ApplWrite( SCREENMGR, SM_M_SPECIAL, 0, MA, GX, SMC_HIDEOTHERS, 0);
			break;
		}
	}
	return 1;	/* pas d'erreur ? */
}
