/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2001
 *
 *	module: special.c
 *	description: fonctions GEM haut niveau
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>	
#include "av.h"
#include "globals.h"

/*
 *	Appel de ST-Guide
 */

int CallStGuide( char *pattern) {
	int id;
	
	if( (id=appl_find( "ST-GUIDE")) >= 0 && app.pipe) {
        strcpy( app.pipe, pattern);
        ApplWrite( id, VA_START, ADR(app.pipe), 0, 0, 0);
        return 0;
	} else
		return -1;
}

/*
 *	Centrage des fenetres et formulaires
 */
 
void GrectCenter( int w, int h, INT16 *x, INT16 *y) {
	INT16 dum;
	
	switch( CONF(app)->wcenter) {
	case CENTER:
		if( app.w > w)
			*x = (app.w - w)/2;
		else
			*x = 0;
		if( app.h > h)
			*y = (app.h - h)/2;
		else
			*y = 0;
		break;
	case WMOUSE:
		/* centr‚e sur la souris */
		graf_mkstate( x, y, &dum, &dum);
		*x -= w/2;
		*y -= h/2;
		break;
	case UP_LEFT:
		*x = app.x;
		*y = app.y;
		break;
	case UP_RIGHT:
		*x = app.w - w;
		*y = app.y;
		break;
	case DN_LEFT:
		*x = app.x;
		*y = app.h - h;
		break;
	case DN_RIGHT:
		*x = app.w - w;
		*y = app.h - h;
		break;
	/* Utiliser form_center */
	case FCENTER:
		{
			OBJECT form;
			form.ob_next = -1;
			form.ob_head = -1;
			form.ob_tail = -1;
			form.ob_type = G_BOX;
			form.ob_flags = LASTOB;
			form.ob_state = NORMAL;
			form.ob_spec.index =  0x00FF1100L;
			form.ob_x = 0;
			form.ob_y = 0;
			form.ob_width = w;
			form.ob_height = h;
			form_center( &form, x, y, &dum, &dum);
		}
		break;
	}
	/* rester dans les limites de l'‚cran */
	if( *x + w > app.x + app.w)
		*x =  app.x + app.w - w;
	if( *y + h > app.y + app.h)
		*y =  app.y + app.h - h;
	*x = MAX( *x, app.x);
	*y = MAX( *y, app.y);

}


#define VA_START 0x4711
#define WS_PEXEC 0xF000

struct _shelw {
	char *newcmd;
	long psetlimit;
	long prenice;
	char *defdir;
	char *env;
};

/*
 *  Ex‚cuter une application GEM ou TOS en parallŠle 
 *  gere le protocol AV
 *  Sous MonoTos, on utilise Pexec() en
 *	g‚rant le repertoire courant.
 */

int ShelWrite( char *prg, char *cmd, void *env, int av, int single) {
	static char file[FILE_SIZE];
	char *p;
	int res, mode;
	char path[FILE_SIZE], path2[FILE_SIZE];
	int drv;

	strcpy( file, cmd);
	if( av) {
		int id_app, msg[8];
		char aesname[9], name[64];

		/* extraire le nom du programme */
		p = strrchr( prg, '\\');
		strcpy( name, (p?(p+1):prg));
		p = strrchr( name, '.');
		if( p) *p = '\0';
		strupr( name);
		sprintf( aesname, "%-8s", name);
		id_app = appl_find( aesname);
		if( id_app >= 0) {
			msg[0] = VA_START;
			msg[1] = app.id;
			msg[2] = 0;
			*(char **)&msg[3] = file;
		    msg[5] = 0;
    	    msg[6] = 0;
    	    msg[7] = 0;
    	   	appl_write(id_app, 16, msg);
    	    return id_app;
		}
	}
	
	strcpy( file+1, cmd);
	*file = strlen(cmd);


		/* Sauver chemin courant */
		drv = Dgetdrv();
		Dgetpath( path, 0);
		
		/* Mettre le chemin courant a celui du programme */		
		if( prg[1] == ':')
			Dsetdrv( toupper(prg[0])-'A');
		p = strchr( prg, '\\');
		strcpy( path2, p?p:prg);
		p = strrchr( path2, '\\');
		if(p) *p = '\0';
		Dsetpath( path2);
	
	if( _AESnumapps != 1 && single == 0) {
		p = strchr( prg, '.');
		if( p) {
			if( !stricmp(p+1, "ttp") ||
				!stricmp(p+1, "tos"))
				mode = 0;
			else
				mode = 1;
		} else
			mode = 0; /* Cas Minix ?? */
		
		if( env) {
			struct _shelw shelenv;

			shelenv.newcmd=prg;
			shelenv.env=env;
			
			res = shel_write(0x801,mode,100, (char *)&shelenv, file);
		} else
			res = shel_write(1,mode,100, prg, file);
		
	} else {
		WINDOW *scan;
		INT16 x, y, w, h;
		
		/* Fermer toutes les fenˆtres et changer le chemin
		 * courant pour celui de l'application  */
		for( scan=wglb.first; scan; scan = scan->next) {
			if( scan->status & WS_OPEN) {
				WindClose( scan);
				scan->status |= WS_PEXEC;
			}
		}
		/* Enlever le menu  */
		if( app.menu) menu_bar( app.menu, 0);
		

		res=(int)Pexec( 0, prg, (void *) file, env);
		
		
		/* Le menu */
		if( app.menu) menu_bar( app.menu, 1);

		/* Les fenˆtres	*/
		for( scan=wglb.first; scan; scan = scan->next) {
			if( scan->status & WS_PEXEC) {
				WindGet( scan, WF_PREVXYWH, &x, &y, &w, &h);
				WindOpen( scan, x, y, w, h);
				scan->status &= ~WS_PEXEC;
			}
		}
	}

		/* Restaurer le chemin courant */
		Dsetdrv( drv);
		Dsetpath( path);

	return res;
}

void DebugWindom(  const char *format, ...) {
	char path[255];
	static char debug[255];
	char type[120], p;
	va_list arglist;
	
	p = ConfInquire( "windom.debug", "%s,%s", type, path);
	if( p>0) {
		/* format */
		va_start( arglist, format);
		vsprintf( debug, format, arglist);
		va_end( arglist);

		if( !stricmp( type, "alert")) {
			char alert[255];
			sprintf( alert, "[1][%s][Okay]", debug);
			form_alert( 1, alert);	
		} else
		if( !stricmp( type, "debug") && p == 2) {
			int id, ans = 0;
			
			if( _AESnumapps != 1)
				ShelWrite( path, "", NULL, 1, 0);
			id = appl_find( "DEBUG   ");
			if( id > 0) {
				evnt.buff[0] = AP_DEBUG;
				evnt.buff[1] = app.id;
				evnt.buff[2] = 0;
				evnt.buff[3] = wglb.front?wglb.front->handle:0;
				*(char **)&evnt.buff[4] = debug;
				appl_write( id, 16, evnt.buff);
				/* On attend la r‚ponse */
				do {
					evnt_mesag( evnt.buff);
					if( evnt.buff[0] == AP_TERM) {
						ans = 1;
						ApplWrite( app.id, AP_TERM, 0, 0, 0, 0, 0);
					}
					if( evnt.buff[0] == AP_DEBUG)
						ans = 1;
				} while( !ans);
			}
		} else
		if( !stricmp( type, "log") && p == 2) {
			FILE *fp;
			static int first = 1;
			
			fp = fopen( path, first?"w":"a");
			first = 0;
			fputs( debug, fp);
			fputs( "\n", fp);
			fclose( fp);
		}
	}
}

/* EOF */
