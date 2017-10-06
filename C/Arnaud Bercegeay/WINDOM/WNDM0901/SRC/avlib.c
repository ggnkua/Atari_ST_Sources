/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/1998
 *
 *	module: appl.c
 *	description: librairie du protocol AV
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "av.h"

#include "globals.h"

#define TIME_IDLE	
#define V_EXIT			0x0400

static char *__av_name;					/* nom du client (notre appli) */
static char __av_server[9];				/* nom du serveur AV */
static INT16 __av_status[3]={0,0,0};	/* action support‚s par le serveur */

/*
 *	On cherche l'id du server AV :
 *		-> variable AVSERVER
 *		-> apps AVSERVER, GEMINI, THING
 *		-1: pas de server AV
 */

static
int av_server_id( void) {
	char *p, name[89];
	INT16 id=-1;
	
	shel_envrn(&p, "AVSERVER=");
	if( p) {
		sprintf(name, "%8.8s", p);
		id = appl_find( name);
	}	
	if( id != -1) return id;
	id = appl_find( "AVSERVER");
	if( id != -1) return id;
	id = appl_find( "GEMINI  ");
	if( id != -1) return id;
	id = appl_find( "THING   ");
	if( id != -1) return id;
	if( app.aes4 & AES4_APPSEARCH) {
		char name[9];
		INT16 type;
		appl_search( 0, name, &type, &id);
		
		if( appl_search( 0, name, &type, &id) == 0)
			if( type & 0x8) return 1;
		while( appl_search( 1, name, &type, &id))
			if( type & 0x8) return 1;
		id = -1;
	}
	return id;
}

/* sous fonction: attente d'un message
 * avec time_idle (a faire) */
 
int AvWaitfor( int msg, INT16 *buf, long idle) {
	int res;
	INT16 dum;
	long count = 0;
	
	while(1) {
#ifdef __GEMLIB__
		res = evnt_multi( MU_TIMER|MU_MESAG,
					0,0,0,
					0,0,0,0,0,
					0,0,0,0,0,
					buf,
					100L,
					&dum,&dum,&dum,
					&dum,&dum,&dum);
#else  /* __GEMLIB__ */
		res = evnt_multi( MU_TIMER|MU_MESAG,
					0,0,0,
					0,0,0,0,0,
					0,0,0,0,0,
					buf,
					100,0,
					&dum,&dum,&dum,
					&dum,&dum,&dum);
#endif /* __GEMLIB__ */
		if( res & MU_MESAG) {
			if( buf[0] != msg) {
				appl_write( app.id, 16, buf);
				count += 100;
#ifdef __GEMLIB__
				evnt_timer(100);
#else
				evnt_timer( 100,0);
#endif
				if( count > idle)
					return 0;
			} else return 1;
		}
		if( res & MU_TIMER) {
			count += 100;
			if( count > idle)
				return 0;
		}
	} 
}


/* sous fonction: interrogation du serveur */

static int av_ping( int status, long idle) {
	INT16 msg[8];
	
	ApplWrite( app.avid, AV_PROTOKOLL, status, 0, 0, ADR(__av_name));
	if( AvWaitfor( VA_PROTOSTATUS, msg, idle)) {
		__av_status[0] = msg[3];
		__av_status[1] = msg[4];
		__av_status[2] = msg[5];
		strcpy( __av_server, *(char **)&msg[6]);
		return 1;
	} else
		return 0;
}

/*
 *	Initialisation du protocol AV
 *	id : id du client
 *	name: nom du client (format GEM)
 *	status: les actions support‚es par le client, peut ˆtre
 *	appel‚ plusieurs fois (avec un nouvel ‚tat)
 *			0x1: VA_SETSTATUS
 *			0x2: VA_START
 *			0x4: AV_STARTED
 *			0x8: VA_FONTCHANGED
 *			0x10: truc de quoting
 *			0x20: VA_PATH_UPDATE
 *	idle: temps max de r‚ponse du serveur en ms
 *			( 1000 semble pas mal)
 */

int AvInit( char *name, int status, long idle) {
	if( app.avid == -1) {
		app.avid = av_server_id();
		__av_name = strdup( name);
	}

	/* erreur, pas de server, bye */
	if( app.avid == -1) return -1 ;

	/* erreur, un client ne peut pas ˆtre son
	 * propre serveur, bye */
	if( app.avid == app.id) return -3 ;

	/* d‚claration du client au serveur AV */
	if( av_ping( status, idle))
		return app.avid;
	else
		return -2;	/* Ne supporte pas le protocol, bye */
}

/*
 *	Fin du protocole
 */
 
void AvExit( void) {
	if( __av_status[0] & V_EXIT)
		ApplWrite( app.avid, AV_EXIT, app.id, 0, 0, 0, 0);
	free( __av_name);
	app.avid = -1;
}

/*
 *	Divers
 */

/* retourne les actions du serveur AV */

INT16 *AvStatus( void) {
	return __av_status;
}

char *AvServer( void) {
	return __av_server;
}

/* Formatte un nom de fichier au format AV:
 * src: chaŒne … formatter,
 * retour: chaŒne formatt‚ (au format chaine d'environnement),
 *		   -> a lib‚rer avec free()
 * mode: 1:
 *		on enlŠve les quotes s'ils existe
 * 		 0:
 *		on ajoute des quotes si besoin est
 *	(fonctionne aussi avec le D&D de chez Thing et MagXdesk)
 */

char *AvStrfmt( int mode, char *src) {
	char *dst, *r;
	
	r = dst = (char*)malloc(sizeof(char)*strlen(src)+3);
	if( mode) {
		char *p, *q;

		p = src;
		do {
			q = NULL;
			while( *p == ' ') p++;
			if( *p == '\'')
				q = strchr( ++p, '\'');
			else  
				q = strchr( p, ' ');
			if( q) *q++ = '\0';
			strcpy( dst, p);
			dst += strlen( dst)+1;
			p = q;
		} while (q);
		*dst = '\0';
	} else if( strchr( src, ' ')) {
		*dst = '\'';
		strcpy( dst+1, src);
		strcat( dst, "\'");
	}
	return r;
}
