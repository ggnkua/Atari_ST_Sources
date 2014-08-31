/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

/*----------------------------------------------------------------------------------------*/ 
/* Globale Includes																								*/
/*----------------------------------------------------------------------------------------*/ 
#include	<Types2B.h>														/* Prozessorunabh„ngige Datentypen */
#include	<PORTAB.H>														/* Kompatibilit„t */
#include	<TOS.H>															/* GEMDOS-, Bios- und XBios-Funktionen */
#include <VDICOL.H>														/* Erweiterungen und Farbfunktionen */
#include	<MT_AES.H>														/* AES-Funktionen */

#include	<string.h>

/*----------------------------------------------------------------------------------------*/ 
/* Lokale Includes																								*/
/*----------------------------------------------------------------------------------------*/ 
#include "WATCHCOL.H"

/*----------------------------------------------------------------------------------------*/ 
/* globale Variablen																								*/
/*----------------------------------------------------------------------------------------*/ 
int16		app_id,
			aes_handle,
			pwchar, phchar,
			pwbox, phbox;

RSHDR		*rsh;
OBJECT	**tree_addr;
int8		**fstring_addr;
int16		tree_count;

int32		col_state;
int32		set_syscol;

#ifndef	COLORS_CHANGED													/* Nachricht nicht definiert? */
#define	COLORS_CHANGED	84
#endif

#define	obj_DESELECTED( tree, obj )		tree[obj].ob_state &= ~SELECTED

/*----------------------------------------------------------------------------------------*/ 
/* Funktionsprototypen																							*/
/*----------------------------------------------------------------------------------------*/ 
void			init_rsrc( void );
void			do_sample( void );
int16	cdecl	handle_sample( DIALOG *dialog, EVNT *events, int16 obj, int16 clicks, void *data );

DIALOG		*open_sample( void );
void			close_dlg( DIALOG *dialog );

void			do_redraw( DIALOG *dialog, GRECT *rect, int16 obj );

/*----------------------------------------------------------------------------------------*/ 
/* Fensterdialog ”ffnen																							*/
/* Funktionsergebnis:	Zeiger auf DIALOG																	*/
/*----------------------------------------------------------------------------------------*/ 
DIALOG	*open_sample( void )
{
	int16	work_out[57];
	OBJECT	*tree;
	DIALOG	*dialog;
	
	vq_extnd( aes_handle, 0, work_out );							/* Bildschirmausmaže erfragen */
	tree = tree_addr[TESTME];											/* Zeiger auf den Objektbaum */

	dialog = wdlg_create( handle_sample, tree, 0L, 0, 0L, WDLG_BKGD );	/* Dialog-Struktur initialisieren */
	
	if ( dialog )
	{
		if ( wdlg_open( dialog, fstring_addr[TEST_TITEL], NAME + CLOSER + MOVER, 16, work_out[1] - tree->ob_height - 16, 0, 0L ))	/* Dialog zeichnen */
			return( dialog );
		else																	/* Fehler beim ™ffnen */
			wdlg_delete( dialog );										/* Dialogstruktur l”schen */
	}
	return( 0L );
}

/*----------------------------------------------------------------------------------------*/ 
/* Fensterdialog schliežen																						*/
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/ 
void	close_dlg( DIALOG *dialog )
{
	if ( dialog )
	{
		wdlg_close( dialog, 0, 0 );
		wdlg_delete( dialog );
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Fensterdialog anzeigen																						*/
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/ 
void	do_sample( void )
{
	extern int32	col_state;
	extern int32	set_syscol;
	EVNT		events;
	DIALOG	*d_sample;
	
	col_state = -1;														/* noch nicht initialisiert */
	set_syscol = 0;

	d_sample = open_sample();

	while( d_sample )														/* solange ein Dialog offen ist */
	{
		int32	old_state;
		
		EVNT_multi( MU_KEYBD + MU_BUTTON + MU_MESAG + MU_TIMER, 2, 1, 1,	0L, 0L, 2000L, &events );

		old_state = col_state;
		if ((uint32) vq_ctab_id( aes_handle ) < 1024 )
			col_state = 1;													/* Systemfarben sind eingestellt */
		else
			col_state = 0;													/* Systemfarben sind verstellt */
		
		if ( col_state != old_state )									/* Farbtabelle ver„ndert? */
		{
			if ( col_state )
				strcpy( tree_addr[TESTME][COLSTR].ob_spec.free_string, fstring_addr[STR_SYSPAL] );
			else
				strcpy( tree_addr[TESTME][COLSTR].ob_spec.free_string, fstring_addr[STR_BADCOL] );

			do_redraw( d_sample, (GRECT *) &tree_addr[TESTME][ROOT].ob_x, ROOT );
		}


		if ( d_sample )													/* ist der Dialog offen? */
		{
			if	( wdlg_evnt( d_sample, &events ) == 0 )			/* wurde Dialog geschlossen? */
			{
				close_dlg( d_sample );									/* Dialog schliežen */
				d_sample = 0;
			}
		}	

		if ( set_syscol )													/* Systemfarben einstellen */
		{
			int16	msg[8];

			vs_dflt_ctab( aes_handle );								/* Systemfarben einstellen */
			set_syscol = 0;

			msg[0] = COLORS_CHANGED;
			msg[1] = app_id;
			msg[2] = 0;
			msg[3] = 0;
			msg[4] = 0;
			msg[5] = 0;
			msg[6] = 0;
			msg[7] = 0;
		
			shel_write( SHW_BROADCAST, 0, 0, (int8 *) msg, 0L );	/* andere Prozesse benachrichtigen */
		}
		
		if( events.mwhich & MU_MESAG )								/* Mitteilungen des SCRENMGR? */
		{
			if ( events.msg[0] == AP_TERM )
			{
				close_dlg( d_sample );									/* Dialog schliežen */
				d_sample = 0;
			}
		}
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Service-Routine fr Fensterdialog 																		*/
/* Funktionsergebnis:	0: Dialog schliežen 1: weitermachen											*/
/*	dialog:					Zeiger auf die Dialog-Struktur												*/
/*	events:					Zeiger auf EVNT-Struktur oder 0L												*/
/*	obj:						Nummer des Objekts oder Ereignisnummer										*/
/*	clicks:					Anzahl der Mausklicks															*/
/*	data:						Zeiger auf zus„tzliche Daten													*/
/*----------------------------------------------------------------------------------------*/ 
int16	cdecl	handle_sample( DIALOG *dialog, EVNT *events, int16 obj, int16 clicks, void *data )
{
	extern int32	set_syscol;
	OBJECT	*tree;
	GRECT		rect;
	
	wdlg_get_tree( dialog, &tree, &rect );							/* Adresse des Baums erfragen */

	if ( obj < 0 )															/* Ereignis oder Objektnummer? */
	{
																				/* alle Ereignisse aužer HNDL_CLSD */
																				/* werden bei diesem Beispiel ignoriert */
			
		if ( obj == HNDL_CLSD )											/* Closer bet„tigt? */
			return( 0 );													/* beenden */ 
	}
	else
	{
		obj &= 0x7fff;

		if ( obj == SET_SYSCOL )										/* Systemfarben einstellen? */
		{
			set_syscol = 1;

			evnt_timer( 40 );												/* kurz warten, bevor der Button deselektiert wird */
			obj_DESELECTED( tree, SET_SYSCOL );
			do_redraw( dialog, &rect, SET_SYSCOL );
		}
	}
	return( 1 );															/* alles in Ordnung - weiter so */
}

/*----------------------------------------------------------------------------------------*/ 
/* Objekt zeichnen																								*/
/* Funktionsresultat:	-																						*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*	rect:						begrenzendes Rechteck															*/
/*	obj:						Objektnummer																		*/
/*	depth:					Anzahl der Objektebenen															*/
/*----------------------------------------------------------------------------------------*/ 
void	do_redraw( DIALOG *dialog, GRECT *rect, int16 obj )
{
	wind_update( BEG_UPDATE );
	wdlg_redraw( dialog, rect, obj, MAX_DEPTH );
	wind_update( END_UPDATE );
}

/*----------------------------------------------------------------------------------------*/ 
/* Resource und dazugeh”rige Strukturen initialisieren												*/
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/ 
void	init_rsrc( void )
{
	rsh = *((RSHDR **)(&_GemParBlk.global[7]));					/* Adresse des Resource-Headers ber global[7/8] holen */

	tree_addr = (OBJECT **)(((uint8 *)rsh) + rsh->rsh_trindex);	/* Zeiger auf die Objektbaumtabelle holen */
	tree_count = rsh->rsh_ntree;										/* und Anzahl der Objektb„ume (von 1 ab gez„hlt) bestimmen */
	fstring_addr = (int8 **)((uint8 *)rsh + rsh->rsh_frstr);	/* Zeiger auf die Free-Strings */
}

/*----------------------------------------------------------------------------------------*/ 
/* Hauptprogramm																									*/
/*----------------------------------------------------------------------------------------*/ 
main( void )
{
	int16	ret_code = -1;

	app_id = appl_init();												/* anmelden */
	
	if( app_id != -1 )
	{
		aes_handle = graf_handle( &pwchar, &phchar, &pwbox, &phbox );		
		graf_mouse( ARROW, 0L );
	
		if( rsrc_load( "WATCHCOL.RSC" ))								/* Resource laden */
		{
			init_rsrc();													/* initialisieren */
			do_sample();													/* Fensterdialog anzeigen */
			ret_code = 0;

			rsrc_free();
		}
		appl_exit();														/* abmelden */
	}
	return( ret_code );
}
