/* XACC.C - Routinen zur Behandlung des XACC-Protokolls
            nach der Spezifikation vom 28. November 1992,
            erweitert um Mag!X 2.0
	(c) 1993 Harald Sommerfeldt @ KI im Maus-Netz
	E-Mail:  Harald_Sommerfeldt@ki.maus.de */

/* Geschichte:
	22.03.93: erste Version
	03.08.93: lÑuft auch unter Speicherschutz (MiNT)
	05.09.93: Åberarbeitet und als seperater Quelltext XACC.C
	06.09.93: fÑngt den fatalen Fehler von Watchdog 1.4 ab, welches im
	          Singletasking-Fall als Antwort von ACC_ID fÑlschlicherweise
	          fleiûig ACC_ACC's verschickt, die auch noch eine falsche ID (16)
	          enthalten, so daû das AES sich die Kugel gibt, falls man versucht,
	          darauf zu antworten :-(((
*/

/* Hinweise:
	- dieser Quelltext ist Freeware und darf daher 1. nur umsonst und 2. nur
	  komplett (XACC.C, XACC.H, XACCTEST.C, XACCTEST.PRJ, XACCTEST.PRG,
	  XACC2.TXT) weitergegeben werden!
	- dieser Quelltext kann ohne Hinweis auf mein Copyright in eigene Programme
	  nach belieben eingebunden werden, die Entfernung meines Copyrightes in
	  diesem Quelltext ist jedoch nicht erlaubt!
	- dieser Quelltext wurde mit Tabweite 3 entwickelt
*/

/* bekannte Bugs:
	- diese Routinen laufen NICHT mit Mag!X 1.x, sondern erst ab Mag!X 2.00!
	- die Variable 'xacc' wird zwar gesetzt, aber ansonsten ignoriert
*/


#define XACC_ACC
/* Dieses Routinen funktionieren auch, wenn das Programm als ACC lÑuft.
	Ist dies bei eigenen Programmen nicht der Fall, so kînnen die dafÅr
	zustÑndigen Routinen durch Lîschung dieser Zeile ausmaskiert werden,
	um redundanten Quellcode zu vermeiden. */

#define XACC_PRG
/* Dieses Routinen funktionieren auch, wenn das Programm als PRG lÑuft. */

/* #define XACC_RECONLY */
/* Diese Routinen kînnen nur per XACC empfangen, nicht selber senden.
	Dies ist z.B. sinnvoll, wenn man als ACC das XACC nicht aktiv benutzt,
	d.h. selbst keine Applikationen anmorsen will, man kann aber korrekt
	durch XACC angesprochen werden.
   Das XACC-Protokoll ist hierbei vollstÑndig implementiert!!! */


#if !defined( XACC_ACC ) && !defined( XACC_PRG )
#error Warum binden Sie diesen Quelltext Åberhaupt ein?
#endif
#if defined( XACC_SMALL ) && defined( XACC_PRG )
#error XACC_SMALL ist nur bei ACCs mîglich
#endif


#include <aes.h>
#include <tos.h>
#include <string.h>
#include <stddef.h>
#include "xacc.h"

/* benîtigte AES-Definitionen */
#ifdef __PUREC__
#define ap_version	_GemParBlk.global[0]	/* AES-Versionsnummer (z.B. 0x140 = 1.40) */
#define ap_count		_GemParBlk.global[1]	/* Anzahl der max. laufenden Applikationen */
#define ap_id			_GemParBlk.global[2]	/* eigene ID */
#endif

/* benîtigte allgemeine Definitionen */
#define NIL		-1
typedef enum { FALSE, TRUE } bool;


/* globale Variablen */
static bool xacc;						/* XACC-Protokoll aktiviert */
static bool xacc_singletask;		/* alte Spezifikation vom 12.3.89 verwenden? */
static char *xacc_name;				/* Platz fÅr den eigenen XACC-Namen */
static unsigned xacc_groups;		/* eigenes XACC-Group-Wort */
static int xacc_menuid;				/* die ID des MenÅeintrages bzw. -1 */

#ifndef XACC_SMALL
struct xaccs xaccs[MAX_XACC];		/* Strukturen, um sich die XACC-Partner zu merken */
#endif


/* XACC-Protokoll initialisieren,
	diese Routine MUSS beim Programmstart irgendwann nach appl_init() aufgerufen werden */

int	xacc_init( int menu_id, const char *name, int sizeofname, unsigned groups )
{
	int	i;

	xacc = TRUE;

	/* den XACC-Namen in einem global zugÑnglichen
	   (Speicherschutz!) unterbringen */
	if ( ap_version >= 0x0400 && xacc_cookie( 'MiNT', NULL ) )
		xacc_name = Mxalloc( sizeofname, 0x0022 );
	else
		xacc_name = Malloc( sizeofname );
	if ( xacc_name == NULL ) return xacc = FALSE;
	memcpy( xacc_name, name, sizeofname );

	/* die MenÅ-ID und das Group-Wort merken */
	xacc_menuid = menu_id;
	xacc_groups = groups;

#ifndef XACC_SMALL
	/* erstmal alle EintrÑge lîschen */
	for ( i = 0; i < MAX_XACC; i++ ) xaccs[i].id = -1;
#endif

	/* unter einem Multi-AES-TOS gilt die neue Spezifikation... */
	if ( ap_count != 1 ) {
		xacc_singletask = FALSE;
		/* AES 4.0 (z.B. MTOS) oder MagX? */
		if ( ap_version >= 0x400 || xacc_cookie( 'MagX', NULL ) ) {
			int	type, id;
			char	name[10];

			/* ...wir senden also an alle Applikationen unseren Willkommensgruû */
			for ( i = appl_search( 0, name, &type, &id ); i; i = appl_search( 1, name, &type, &id ) ) {
				if ( (type & 6) != 0 ) xacc_id( id, ACC_ID );
			}
		}
		else xacc = FALSE;		/* sorry, wird wohl nichts draus... */
	}
	/* ansonsten handelt es sich um ein altes, trostloses Singletasking-AES,
	   wo wir das angestaubte XACC-Protokoll vom 12.3.89 verwenden */
	else xacc_singletask = TRUE;

	return xacc;
}


/*	XACC-Protokoll deinitialisieren,
	diese Routine MUSS irgendwann beim Programmende vor appl_exit() aufgerufen werden */

#ifndef XACC_SMALL
void	xacc_exit( void )
{
	int	i;

	/* Im Multitasking-Fall ... */
	if ( !xacc_singletask ) {
		/* ... verabschieden wir und brav und hîflich (mittels ACC_EXIT) */
		for ( i = 0; i < MAX_XACC; i++ ) {
			if ( xaccs[i].id >= 0 ) xacc_id( xaccs[i].id, ACC_EXIT );
		}
	}
	if ( xacc_name != NULL ) Mfree( xacc_name );
}
#endif


/*	die Nachricht in msgbuf verarbeiten, falls es sich um eine
	Nachricht des Types AC_CLOSE, ACC_ID, ACC_ACC oder ACC_EXIT handelt;
	es wird TRUE zurÅckgegeben, falls die Nachricht komplett verarbeitet wurde */

int	xacc_message( const int *msgbuf )
{
	int	i;

#ifdef XACC_ACC
	if ( msgbuf[0] == AC_CLOSE ) {
		/*	wenn wir dem Singletasking-Protokoll hîrig sind,
			ist dies der Moment, wo der Elefant das Wasser lÑût:
			das XACC-Protokoll wird angekurbelt */
		if ( xacc_singletask ) {
#ifndef XACC_SMALL
			/* erstmal alle EintrÑge lîschen... */
			for ( i = 0; i < MAX_XACC; i++ ) xaccs[i].id = -1;
#endif
			/*	...dann die Lawine in Gang setzen: ACC_ID ans Haupt-
				programm verschicken; die Bedingung ap_id != 0 sollte
				hierbei eigentlich immer erfÅllt sein, aber man weiû
				ja nie, wer einem so alles eine AC_CLOSE-Nachricht
				andrehen will (z.B. Schlemi!) */
			if ( ap_id != 0 ) xacc_id( 0, ACC_ID );
		}
		return FALSE;
	}
#endif
	if ( msgbuf[0] == ACC_ID ) {
		/* wenn wir dem Single-Tasking-Protokoll hîrig sind,
			ist dies der Moment, wo der Elefant das Wasser gelassen hat:
			das XACC-Protokoll wurde angekurbelt */
		if ( xacc_singletask ) {
#ifdef XACC_PRG
			if ( ap_id == 0 ) {	/* nur wenn wir ein PRG sind... */
				int	mymsgbuf[8];

				/* ...verschicken wir fleiûig Gruûkarten (ACC_ACC) */
				mymsgbuf[0] = ACC_ACC;
				mymsgbuf[1] = ap_id;
				mymsgbuf[2] = 0;
				mymsgbuf[3] = msgbuf[3];
				mymsgbuf[4] = msgbuf[4];
				mymsgbuf[5] = msgbuf[5];
				mymsgbuf[6] = msgbuf[6];
				mymsgbuf[7] = msgbuf[1];
				for ( i = 0; i < MAX_XACC; i++ ) {
					if ( xaccs[i].id >= 0 ) appl_write( xaccs[i].id, 16, mymsgbuf );
				}
				/* dem Auslîser dieser Lawine einen Heiratsantrag schicken */
				xacc_id( msgbuf[1], ACC_ID );
			}
#else
			;
#endif
		}
		/* im Falle des Multitasking-Protokolls tut sich hier nicht
			ganz so viel: Wir erwiedern das Moin (ACC_ID) mit Moin-Moin (ACC_ACC) */
		else xacc_id( msgbuf[1], ACC_ACC );
#ifndef XACC_SMALL
		/* auf jeden Fall lassen wir ein ACC_ID nicht ungestraft
			durchgehen, der Absender wird in der Fahndungsliste vermerkt! */
		xacc_remid( msgbuf[1], msgbuf );
#endif
		return TRUE;
	}
	else if ( msgbuf[0] == ACC_ACC ) {
		/* ACC_ACC ist vergleichsweise harmlos: Im Singletasking-Fall
			erhalten wir so als ACC von anderen ACCs Kenntnis (und
			vermitteln diesen die Kenntnis Åber uns), im Multitasking-Fall
			ist dies einfach das Moin-Moin auf das Moin (ACC_ID)
			ACHTUNG: Im ersten Fall steht die interessante Id bei
			         msgbuf[7], im zweiteren bei msgbuf[1]! */
		if ( xacc_singletask ) {
#ifdef XACC_ACC
			if ( ap_id != 0 ) {	/* sollte eigentlich immer der Fall sein,
			                        im Falle Watchdog 1.4 leider nicht :-((( */
				xacc_id( msgbuf[7], ACC_ID );
#ifndef XACC_SMALL
				xacc_remid( msgbuf[7], msgbuf );
#endif
			}
#else
			;
#endif
		}
#ifndef XACC_SMALL
		else xacc_remid( msgbuf[1], msgbuf );
#endif
		return TRUE;
	}
	else if ( msgbuf[0] == ACC_EXIT ) {
		/* Der Untergang der Titanic, hier allerdings nicht ohne
			VorankÅndigung: Die Id wird mangels grÅnen Punkt nicht
			wiederverwertet, sondern wandert auf den MÅll */
		xacc_killid( msgbuf[1] );		/* wech mit den Altlasten */
		return TRUE;
	}
	return FALSE;
}


/* ein Teil des Ganzen als XACC-Nachricht versenden
	dest_id : die ap_id des glÅcklichen EmpfÑngers
	message : Nachrichtentyp (ACC_IMG oder ACC_META)
	addr    : Adresse des Speicherblockes
	length  : LÑnge des Speicherblockes
	last    : Letzter Speicherblock? (FALSE/TRUE) */

int	xacc_send( int dest_id, int message, void *addr, long length, int last )
{
	int	msgbuf[8];

	msgbuf[0] = message;
	msgbuf[1] = ap_id;
	msgbuf[2] = 0;
	msgbuf[3] = last;
	*(const char **)(msgbuf+4) = addr;
	*(long *)(msgbuf+6) = length;
	return appl_write( dest_id, 16, msgbuf );
}


/* ACC_ACK als Antwort auf ACC_TEXT, ACC_KEY, ACC_META oder ACC_IMG versenden
	dest_id : die ap_id des (un-)glÅcklichen EmpfÑngers
	ok      : TRUE oder FALSE */

int	xacc_ack( int dest_id, int ok )
{
	int	msgbuf[8];

	msgbuf[0] = ACC_ACK;
	msgbuf[1] = ap_id;
	msgbuf[2] = 0;
	msgbuf[3] = ok;
	msgbuf[4] = msgbuf[5] = msgbuf[6] = msgbuf[7] = 0;
	return appl_write( dest_id, 16, msgbuf );
}


/* die eigene XACC-ID versenden
	dest_id : die ap_id des glÅcklichen EmpfÑngers
	message : ACC_ID oder ACC_ACC, je nach Lust & Laune */

int	xacc_id( int dest_id, int message )
{
	int	msgbuf[8];

	/* da in xacc_init() die eigene ap_id nicht herausgefiltert wird,
	   wird hier verhindert, daû wir uns selber eine Nachricht schicken */
	if ( dest_id != ap_id ) {
		msgbuf[0] = message;			/* Nachrichtentyp */
		msgbuf[1] = ap_id;			/* unsere ap_id */
		msgbuf[2] = 0;					/* LÑnge der Nachricht - 16 */
		msgbuf[3] = xacc_groups;	/* die von uns unterstÅtzten XACC-Gruppen */
		*(const char **)(msgbuf+4) = xacc_name;	/* unser XACC-Name */
		msgbuf[6] = xacc_menuid;	/* unsere MenÅkennung (falls ACC), sonst -1 */
		msgbuf[7] = NIL;				/* reserviert */
		return appl_write( dest_id, 16, msgbuf );
	}
	return 0;
}


/* XACC-Eintrag vermerken (bei ACC_ID & ACC_ACC)
	id     : die ap_id des Absenders,
	msgbuf : der empfangene Nachrichtenpuffer */

#ifndef XACC_SMALL
int	xacc_remid( int id, const int *msgbuf )
{
	int	i;

	/* eventuell alten Eintrag mit der gleichen Id vorher lîschen.
	   es gibt verschiedene FÑlle, wo dies notwendig ist:
	   - ein Eintrag ist veraltet, da das Programm abgestÅrzt ist
	     und daher kein ACC_EXIT versandt hat
	   - beim Singletasking-Protokoll kann ein ACC mehrere ACC_ACC
	     vom gleichen ACC erhalten
	   - beim Multitasking-Protokolls erhÑlt ein ACC _IMMER_ von einem
	     anderen ACC beim Neustart des Rechners sowohl ein ACC_ID als
	     auch ein ACC_ACC
	*/
	xacc_killid( id );

	/* nun gehts aber los! */
	for ( i = 0; i < MAX_XACC; i++ ) {	/* XACC-Liste abklappern */
		if ( xaccs[i].id < 0 ) {				/* freier Eintrag gefunden */
			xaccs[i].id = id;					/* Eintrag vermerken */
			xaccs[i].groups = msgbuf[3];
			xaccs[i].name = *(const char **)(msgbuf+4);
			return TRUE;
		}
	}
	return FALSE;
}
#endif


/* XACC-Eintrag lîschen (z.B. bei ACC_EXIT)
	id : die nicht mehr gÅltige ap_id */

#ifndef XACC_SMALL
int	xacc_killid( int id )
{
	int	i;

	for ( i = 0; i < MAX_XACC; i++ ) {	/* XACC-Liste abklappern */
		if ( xaccs[i].id == id ) {			/* Id gefunden ! */
			xaccs[i].id = NIL;				/* Eintrag in der Liste freigeben */
			return TRUE;
		}
	}
	return FALSE;
}
#endif


/* Wert eines Cookies holen, zurÅckgegeben wird TRUE bei Erfolg */

typedef struct {
	long	cookie, value;
} cookiejar;

int	xacc_cookie( long cookie, long *value )
{
	cookiejar *_p_cookies;
	void	*sp;

	sp = (void *)Super( NULL );
	_p_cookies = *(void **)0x5A0;		/* Zeiger auf Cookiejar holen */
	Super( sp );
	if ( _p_cookies != NULL ) {		/* wenn Cookiejar installiert ... */
												/* ... dann Cookies abklappern ... */
		for (; _p_cookies->cookie != 0L; _p_cookies++ ) {
			if ( _p_cookies->cookie == cookie ) {
												/* ... bis der gewÅnschte Eintrag ist */
				if ( value != NULL ) *value = _p_cookies->value;
				return TRUE;
			}
		}
	}
	return FALSE;
}
