/* XACCTEST.PRG/ACC - ein XACC-Beispiel und Testprogramm
	(c) 1993 Harald Sommerfeldt @ KI im Maus-Netz
	E-Mail:  Harald_Sommerfeldt@ki.maus.de */

/* Geschichte:
	22.03.93: erste Version
	05.09.93: erste verîffentlichte Version
*/

/* Hinweise:
	- dieses Programm lÑuft sowohl als ACC als auch als PRG
	- dieses Programm wurde mit Tabweite 3 entwickelt
*/

/* bekannte Bugs:
	- dieses Programm funktioniert NICHT mit Speicherschutz (MiNT)
*/

#include <aes.h>
#include <tos.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include "xacc.h"
#include "xacctest.h"

typedef enum { FALSE, TRUE } bool;

int	ap_id, menu_id;
OBJECT *menu;
char	path[80], name[14], buffer[1000];

bool	handle_mesag( const int *msgbuf );


/* form_alert() mit Format-String */
int	form_falert( int defbut, const char *fastring, ... )
{
	va_list	argpoint;
	static char buffer[256];
	int	button;

	wind_update( BEG_UPDATE );
	va_start( argpoint, fastring );
	vsprintf( buffer, fastring, argpoint );
	va_end( argpoint );
	button = form_alert( defbut, buffer );
	wind_update( END_UPDATE );
	return button;
}

/* vereinfachtes rsrc_gaddr() */
OBJECT	*rsrc_gtaddr( int index )
{
	OBJECT	*tree;

	rsrc_gaddr( 0, index, &tree );
	return tree;
}


/* dem Benutzer eine Liste der aktiven XACC-Applikationen andrehen,
   diese Routine kann nur max. 8 EintrÑge verwalten (in einem richtigen
   Programm sollte man natÅrlich alle anbieten), damit sie kurz und
   knapp (und verstÑndlich) bleibt
	info   : Infozeile, worum es Åberhaupt geht
	groups : Bitmaske, welche Groups wir brauchen
	zurÅckgegeben wird der Index des XACC-Eintrages oder NIL (-1) */
#define NXACC 8	/* soviele EintrÑge passen in unsere Liste */
int	do_list( const char *info, int groups )
{
	OBJECT	*dialog = rsrc_gtaddr( XACCLIST );
	int		obj, i, x, y, w, h;

	/* Titel setzen und Unterstreichung anpassen */
	dialog[XL_TITLE].ob_spec.free_string = (char *)info;
	dialog[XL_TITUN].ob_width = dialog[XL_TITLE].ob_width / (int)strlen( "STRING" ) * (int)strlen( info );

	/* EintrÑge in die Liste schmeissen */
	for ( i = 0; i < NXACC; i++ ) {
		if ( xaccs[i].id >= 0 ) {
			sprintf( dialog[XL_ENTRY+i].ob_spec.tedinfo->te_ptext, "%-30s %2d %#06x",
				xaccs[i].name, xaccs[i].id, xaccs[i].groups );
			if ( xaccs[i].groups & groups )
				dialog[XL_ENTRY+i].ob_state &= ~DISABLED;
			else
				dialog[XL_ENTRY+i].ob_state |= DISABLED;
		}
		else {
			sprintf( dialog[XL_ENTRY+i].ob_spec.tedinfo->te_ptext, "%-40s", "" );
			dialog[XL_ENTRY+i].ob_state |= DISABLED;
			dialog[XL_ENTRY+i].ob_state &= ~SELECTED;
		}
	}
	form_center( dialog, &x, &y, &w, &h );
	wind_update( BEG_UPDATE );
	form_dial( FMD_START, 0, 0, 0, 0, x, y, w, h );
	objc_draw( dialog, 0, MAX_DEPTH, x, y, w, h );
	obj = form_do( dialog, 0 );
	dialog[obj].ob_state &= ~SELECTED;
	if ( obj == XL_OK ) {
		for ( i = 0; i < NXACC; i++ ) {
			if ( dialog[XL_ENTRY+i].ob_state & SELECTED ) break;
		}
		if ( i == NXACC ) i = -1;
	}
	else i = -1;
	form_dial( FMD_FINISH, 0, 0, 0, 0, x, y, w, h );
	wind_update( END_UPDATE );
	return i;
}

/* eine Taste mittels ACC_KEY versenden */
void	do_key( int i )
{
	OBJECT	*dialog = rsrc_gtaddr( SENDKEY );
	int		msgbuf[8], x, y, w, h;

	wind_update( BEG_UPDATE );
	form_center( dialog, &x, &y, &w, &h );
	form_dial( FMD_START, 0, 0, 0, 0, x, y, w, h );
	objc_draw( dialog, 0, MAX_DEPTH, x, y, w, h );
	wind_update( BEG_MCTRL );
	msgbuf[0] = ACC_KEY;
	msgbuf[1] = ap_id;
	msgbuf[2] = 0;
	msgbuf[3] = evnt_keybd();
	appl_write( xaccs[i].id, 16, msgbuf );
	wind_update( END_MCTRL );
	form_dial( FMD_FINISH, 0, 0, 0, 0, x, y, w, h );
	wind_update( END_UPDATE );
}

/* einen Text mittels ACC_TEXT versenden */
void	do_text( int i )
{
	OBJECT	*dialog = rsrc_gtaddr( SENDTEXT );
	int		msgbuf[8], x, y, w, h, obj;

	wind_update( BEG_UPDATE );
	form_center( dialog, &x, &y, &w, &h );
	form_dial( FMD_START, 0, 0, 0, 0, x, y, w, h );
	objc_draw( dialog, 0, MAX_DEPTH, x, y, w, h );
	obj = form_do( dialog, 0 );
	dialog[obj].ob_state &= ~SELECTED;
	if ( obj == STXT_OK ) {
		msgbuf[0] = ACC_TEXT;
		msgbuf[1] = ap_id;
		msgbuf[2] = 0;
		*(char **)(msgbuf+4) = dialog[STXT_TXT].ob_spec.tedinfo->te_ptext;
		appl_write( xaccs[i].id, 16, msgbuf );
	}
	form_dial( FMD_FINISH, 0, 0, 0, 0, x, y, w, h );
	wind_update( END_UPDATE );
}

/* ein StÅck Datei versenden */
int	do_sendpiece( int dest_id, int type, int das_ende, const char *addr, long length )
{
	int	msgbuf[8], dummy, event, keycode;

	if ( xacc_send( dest_id, type, addr, length, das_ende ) ) {
		/* auf BestÑtigung warten, Timeout: 30 Sekunden */
		for (;;) {
			event = evnt_multi( MU_MESAG|MU_KEYBD|MU_TIMER, 2, 1, 1,
				0, 0, 0, 0, 0, 0, 0, 0, 0, 0, msgbuf, 30*1000, 0,
				&dummy, &dummy, &dummy, &dummy, &keycode, &dummy );
			/* UNDO gedrÅckt: keine Lust mehr! */
			if ( (event & MU_KEYBD) && keycode == 0x6100 ) {	/* UNDO */
				if ( form_falert( 1, "[2][ |Senden abbrechen?][Ja|Nein]" ) == 1 )
					break;
			}
			/* eine Nachricht fÅr uns! */
			if ( event & MU_MESAG ) {
				if ( msgbuf[0] == ACC_ACK ) {
					/* alles paletti: weiter im Text */
					if ( msgbuf[3] ) return TRUE;
					/* ansonsten: das Leben ist hart und ungerecht */
					form_falert( 1, "[3][ |Keiner mag mich!][SchnÅff]" );
					break;
				}
				if ( msgbuf[0] != MN_SELECTED && msgbuf[0] != AC_OPEN )
					handle_mesag( msgbuf );
			}
			/* 30 Sekunden vorbei: Timeout ! */
			if ( event & MU_TIMER ) {
				form_falert( 1, "[3][ |Timeout beim Senden][Abbruch]" );
				break;
			}
		}
	}
	return FALSE;
}

/* eine Datei mittels 'message' versenden */
void	do_sendfile( int i, const char *fileext, int message )
{
	char	oh_du_froehliche[128];
	int	knopf_der_weisheit, du_begnadete_datei;
	long	gott_hab_ihn_seelich, erbarme_meiner_seele;

	/* ein wenig VorgeplÑnkel ... */
	if ( *path == '\0' ) {
		path[0] = Dgetdrv() + 'A';
		path[1] = ':';
		Dgetpath( path+2, 0 );
		strcat( path+2, "\\" );
	}
	strcat( strcpy( strrchr( path, '\\' ) + 1, "*." ), fileext );
	if ( strchr( name, '.' ) != NULL ) strcpy( strchr( name, '.' ) + 1, fileext );
	if ( fsel_input( path, name, &knopf_der_weisheit ) && knopf_der_weisheit ) {
		/* Bastelstunde: wir basteln und einen Dateinamen ! */
		strcpy( strrchr( strcpy( oh_du_froehliche, path ), '\\' ) + 1, name );
		/* Handwerkerstunde: wir îffnen eine Datei ! */
		if ( (gott_hab_ihn_seelich = Fopen( oh_du_froehliche, FO_READ )) >= 0L ) {
			du_begnadete_datei = (int)gott_hab_ihn_seelich;
			/* Programmiererstunde: wir versenden eine Datei mittels XACC ! */
			for (;;) {
				/* ein bischen Frieden, ein bischen Datei, ... */
				erbarme_meiner_seele = Fread( du_begnadete_datei, sizeof(buffer), buffer );
				/* ... ein bischen Ende */
				if ( erbarme_meiner_seele <= 0L ) {
					do_sendpiece( xaccs[i].id, message, TRUE, buffer, 0L );
					break;
				}
				/* ein StÅck Datei versenden ... */
				if ( !do_sendpiece( xaccs[i].id, message, erbarme_meiner_seele < sizeof(buffer), buffer, erbarme_meiner_seele ) )
					break;
				if ( erbarme_meiner_seele < sizeof(buffer) ) break;
			}
			Fclose( du_begnadete_datei );
		}
	}
}

/* eine GEM-Metadatei mittels ACC_META versenden */
void	do_meta( int i )
{
	do_sendfile( i, "GEM", ACC_META );
}

/* eine GEM-Imagedatei mittels ACC_IMG versenden */
void	do_img( int i )
{
	do_sendfile( i, "IMG", ACC_IMG );
}


/* das Copyright des genialen & begnadeten Programmieres ausgeben :-) */
void	do_info( void )
{
	form_falert( 1, "[1][ |xAcc - Testprogramm|(c) 1993 Harald Sommerfeldt][  OK  ]" );
}

/* der Hauptdialog, der in der ACC-Version die MenÅzeile ersetzt */
void	do_dialog( void )
{
	OBJECT	*dialog = rsrc_gtaddr( DIALOG );
	int	x, y, w, h, obj;
	int	i;

	wind_update( BEG_UPDATE );
	form_center( dialog, &x, &y, &w, &h );
	form_dial( FMD_START, 0, 0, 0, 0, x, y, w, h );
	objc_draw( dialog, 0, MAX_DEPTH, x, y, w, h );
	obj = form_do( dialog, 0 );
	dialog[obj].ob_state &= ~SELECTED;
	form_dial( FMD_FINISH, 0, 0, 0, 0, x, y, w, h );
	wind_update( END_UPDATE );
	switch ( obj ) {
		case DO_INFO:
			do_info();
			break;
		case DO_KEY:
			if ( (i = do_list( "sende Taste ...", 1 )) >= 0 ) do_key( i );
			break;
		case DO_TEXT:
			if ( (i = do_list( "sende Text ...", 1 )) >= 0 ) do_text( i );
			break;
		case DO_META:
			if ( (i = do_list( "sende GEM-Metadatei ...", 2 )) >= 0 ) do_meta( i );
			break;
		case DO_IMG:
			if ( (i = do_list( "sende GEM-Imagedatei ...", 2 )) >= 0 ) do_img( i );
			break;
	}
}

/* GEM-Nachrichten Dispatcher */
bool	handle_mesag( const int *msgbuf )
{
	int	i;

	if ( !xacc_message( msgbuf ) ) switch ( msgbuf[0] ) {
		case AC_OPEN:				/* ACC-Eintrag angewÑhlt */
			if ( menu != NULL ) do_dialog();
			else form_falert( 1, "[3][ |XACCTEST.RSC nicht geladen][Abbruch]" );
			break;
		case MN_SELECTED:			/* MenÅeintrag angeklickt */
			switch( msgbuf[4] ) {
				case MINFO:
					do_info();
					break;
				case MS_KEY:
					if ( (i = do_list( "sende Taste...", 1 )) >= 0 ) do_key( i );
					break;
				case MS_TEXT:
					if ( (i = do_list( "sende Text...", 1 )) >= 0 ) do_text( i );
					break;
				case MS_META:
					if ( (i = do_list( "sende GEM-Metadatei...", 2 )) >= 0 ) do_meta( i );
					break;
				case MS_IMG:
					if ( (i = do_list( "sende GEM-Imagedatei...", 2 )) >= 0 ) do_img( i );
					break;
				case MQUIT:
					return FALSE;		/* Programmende */
			}
			menu_tnormal( menu, msgbuf[3], TRUE );
			break;
		case ACC_ACK:
			/* ein EmpfÑnger will uns Kunde tun von seiner Begeisterung auf
				die ACC_TEXT, ACC_KEY, ACC_META oder ACC_IMG-Nachricht, die
				wir ihm geschickt hatten, msgbuf[3] enthÑlt den
				Begeisterungsgrad: 0 (durchgefallen) oder 1 (bestanden) */
			form_falert( 1, ( msgbuf[3] ) ? "[1][ |ACC_ACK TRUE|empfangen][  OK  ]"
			                              : "[1][ |ACC_ACK FALSE|empfangen][  OK  ]" );
			break;
		case ACC_TEXT:
			/* es wird versucht, uns einen Text anzudrehen */
			strncpy( buffer, *(char **)(msgbuf+4), 20 )[20] = '\0';
			if ( form_falert( 1, "[1][ |ACC_TEXT \"%s\"|empfangen][OK|nicht OK]", buffer ) == 1 )
				xacc_ack( msgbuf[1], TRUE );
			else
				xacc_ack( msgbuf[1], FALSE );
			break;
		case ACC_KEY:
			/* es wird versucht, uns eine Taste anzudrehen */
			if ( form_falert( 1, "[1][ |ACC_KEY %#06x|empfangen][OK|nicht OK]", msgbuf[3] ) == 1 )
				xacc_ack( msgbuf[1], TRUE );
			else
				xacc_ack( msgbuf[1], FALSE );
			break;
		case ACC_META:
			/* es wird versucht, uns eine GEM-Metadatei anzudrehen */
			if ( form_falert( 1, "[1][ |ACC_META %d %p %ld|empfangen][OK|nicht OK]",
			                     msgbuf[3], *(char **)(msgbuf+4), *(long *)(msgbuf+6) ) == 1 )
				xacc_ack( msgbuf[1], TRUE );
			else
				xacc_ack( msgbuf[1], FALSE );
			break;
		case ACC_IMG:
			/* es wird versucht, uns eine GEM-Imagedatei anzudrehen */
			if ( form_falert( 1, "[1][ |ACC_IMG %d %p %ld|empfangen][OK|nicht OK]",
			                     msgbuf[3], *(char **)(msgbuf+4), *(long *)(msgbuf+6) ) == 1 )
				xacc_ack( msgbuf[1], TRUE );
			else
				xacc_ack( msgbuf[1], FALSE );
			break;
	}
	return TRUE;
}

/* und hier die Krînung: das Hauptprogramm */
int	main( void )
{
	const char xaccname[] = "XACC-Testprogramm";
	int	msgbuf[8];

	ap_id = appl_init();
	if ( !_app ) menu_id = menu_register( ap_id, "  XACC-Testprogramm" );
	else menu_id = -1;
	wind_update( BEG_UPDATE );
	if ( rsrc_load( "XACCTEST.RSC" ) ) {
		menu = rsrc_gtaddr( MENU );
		rsrc_gtaddr( SENDTEXT )[STXT_TXT].ob_spec.tedinfo->te_ptext[0] = '\0';
	}
	else menu = NULL;
	if ( _app ) {	/* Ich Programm? Du MenÅzeile darstellen! */
		if ( menu != NULL ) {
			menu_bar( menu, TRUE );
			graf_mouse( ARROW, NULL );
		}
		else form_falert( 1, "[3][ |XACCTEST.RSC nicht geladen][Abbruch]" );
	}
	wind_update( END_UPDATE );
	xacc_init( menu_id, xaccname, (int)sizeof(xaccname), 0x0003 );
	for (;;) {
		evnt_mesag( msgbuf );						/* auf Nachricht warten */
		if ( !handle_mesag( msgbuf ) ) break;	/* und auswerten */
	}
	xacc_exit();
	appl_exit();
	return 0;
}
