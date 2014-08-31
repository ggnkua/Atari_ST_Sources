/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

/*----------------------------------------------------------------------------------------*/ 
/* Globale Includes																								*/
/*----------------------------------------------------------------------------------------*/ 
#include <PORTAB.H>
#include	<TOS.H>
#include	<VDI.H>
#include	<VDICOL.H>														/* neue VDI-Funktionen */
#include	<MT_AES.H>

#include	<string.h>
#include	<stdlib.h>
#include	<stdio.h>

#include	"PDSMPRSC.H"

/*----------------------------------------------------------------------------------------*/ 
/* Prototypen																										*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	is_macprn( WORD handle, WORD id );
void	print_sample( PRN_SETTINGS *settings );

PRN_SETTINGS	*read_psettings( PRN_DIALOG *prn_dialog );
WORD	save_psettings( PRN_SETTINGS *settings );

WORD	open_print_dialog( PRN_SETTINGS *settings, BYTE *document_name, WORD kind );
WORD	close_print_dialog( void );

void	menu_selected( WORD title, WORD entry );
void	handle_keybd( WORD keycode, WORD kstate );
void	handle_message( WORD msg[8] );
void	event_loop( void );

void	init_rsrc( void );
WORD	wlfp_available( void );

/*----------------------------------------------------------------------------------------*/ 
/* Globale Variablen																								*/
/*----------------------------------------------------------------------------------------*/ 

WORD	app_id;
WORD	aes_handle;
WORD	pwchar;
WORD	phchar;
WORD	pwbox;
WORD	phbox;

RSHDR		*rsh;
BYTE		**fstring_addr;
OBJECT	**tree_addr;
WORD		tree_count;
OBJECT	*menu_tree;

WORD	quit;

/*----------------------------------------------------------------------------------------*/ 
/* Informationen Åber den Druckdialog																		*/
/* In einer ausgewachsenen Applikation sollten diese Variablen in einer Struktur 			*/
/*	gekapselt werden, damit es nicht zu unÅbersichtlich wird											*/
/*----------------------------------------------------------------------------------------*/ 
PRN_SETTINGS	*gprn_settings;
PRN_DIALOG		*gprn_dialog;
WORD				gprn_whdl;
WORD				gprn_x;
WORD				gprn_y;
WORD				gprn_is_print_dialog;
PDLG_SUB			*gsub_dialogs;

#define	obj_SELECTED( tree, obj )			tree[obj].ob_state |= SELECTED
#define	obj_DESELECTED( tree, obj )		tree[obj].ob_state &= ~SELECTED

/*----------------------------------------------------------------------------------------*/ 
/* Informationen fÅr eigene Unterdialoge des Druckdialogs											*/
/*----------------------------------------------------------------------------------------*/ 

int32 cdecl	pinit_my_special1( PRN_SETTINGS *settings, PDLG_SUB *sub_dialog );
int32 cdecl	psub_my_special1( PRN_SETTINGS *settings, PDLG_SUB *sub_dialog, int16 exit_obj );
int32 cdecl	preset_my_special1( PRN_SETTINGS *settings, PDLG_SUB *sub_dialog );

int32 cdecl	pinit_my_special2( PRN_SETTINGS *settings, PDLG_SUB *sub_dialog );
int32 cdecl	preset_my_special2( PRN_SETTINGS *settings, PDLG_SUB *sub_dialog );

typedef struct																/* Dialogbeschreibung fÅr create_sub_dialogs() */
{
	PDLG_INIT	init_dlg;
	PDLG_HNDL	do_dlg;
	PDLG_RESET	reset_dlg;
	int16			icon_index;
	int16			tree_index;
} SIMPLE_SUB;

PDLG_SUB	*create_sub_dialogs( OBJECT **tree_addr, SIMPLE_SUB *create, int16 no_subs );
void	free_sub_dialogs( PDLG_SUB	*sub_dialogs );

void	redraw_obj( PDLG_SUB *sub_dialog, int16 obj );

SIMPLE_SUB	my_subs_for_pdlg[2] =									/* Feld mit Dialogbeschreibungen fÅr create_sub_dialogs() */
{
	{ pinit_my_special1, psub_my_special1, preset_my_special1, PI_MY_SPECIAL1, MY_SPECIAL_DLG1 },
	{ pinit_my_special2, 0L, preset_my_special2, PI_MY_SPECIAL2, MY_SPECIAL_DLG2 }
};

/*----------------------------------------------------------------------------------------*/ 
/* Liste fÅr die Unterdialoge aufbauen																		*/
/* Funktionsresultat:	Zeiger auf Liste																	*/
/*	tree_addr:				Feld mit Objektbaumadressen													*/
/*	create:																											*/
/*	no_subs:					Anzahl der Unterdialoge															*/
/*----------------------------------------------------------------------------------------*/ 
PDLG_SUB	*create_sub_dialogs( OBJECT **tree_addr, SIMPLE_SUB *create, int16 no_subs )
{
	PDLG_SUB	*sub_dialogs;
	int16	i;

	sub_dialogs = 0L;

	for ( i = 0; i < no_subs; i++ )
	{
		PDLG_SUB	*sub;

		sub = malloc( sizeof( PDLG_SUB ));
		
		if ( sub )
		{
			sub->next = 0L;												/* Zeiger auf den Nachfolger */

			sub->option_flags = 0;
			sub->sub_id = -1;												/* Kennung des Unterdialogs (wird von pdlg_add_sub_dialogs() gesetzt) */
			sub->sub_icon = tree_addr[ICON_DIALOG] + create->icon_index;
			sub->sub_tree = tree_addr[create->tree_index];		/* Zeiger auf den Objektbaum des Unterdialogs */

			sub->dialog = 0L;												/* Zeiger auf die Struktur des Fensterdialogs oder 0L */
			sub->tree = 0L;												/* Zeiger auf den zusammengesetzen Objektbaum */
			sub->index_offset = 0;										/* Indexverschiebung des Unterdialogs */
			sub->reserved1 = 0;
			sub->reserved2 = 0;

			sub->init_dlg = create->init_dlg;						/* Initialisierungsfunktion */
			sub->do_dlg = create->do_dlg;								/* Behandlungsfunktion */
			sub->reset_dlg = create->reset_dlg;						/* ZurÅcksetzfunktion */
			sub->reserved3 = 0;
			
			sub->next = sub_dialogs;
			sub_dialogs = sub;
		}
		create++;															/* Zeiger auf die nÑchste Beschreibung */
	}
	return( sub_dialogs );	
}

/*----------------------------------------------------------------------------------------*/ 
/* Verkettete Liste fÅr die Unterdialoge freigeben														*/
/* Funktionsresultat:	-																						*/
/*	sub_dialogs:			Liste der Unterdialoge															*/
/*----------------------------------------------------------------------------------------*/ 
void	free_sub_dialogs( PDLG_SUB	*sub_dialogs )
{
	while ( sub_dialogs )
	{	
		PDLG_SUB	*next;

		next = sub_dialogs->next;
		free( sub_dialogs );
		sub_dialogs = next;
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Objekt im Druckdialog zeichnen																			*/
/* Funktionsresultat:	-																						*/
/*	sub_dialog:				Struktur des Unterdialogs														*/
/*	obj:						Nummer des Objekts																*/
/*----------------------------------------------------------------------------------------*/ 
void	redraw_obj( PDLG_SUB *sub_dialog, int16 obj )
{
	OBJECT	*tree;
	GRECT		rect;

	tree = sub_dialog->tree;
	rect = *(GRECT *) &tree->ob_x;									/* Dialog-Rechteck */
	
	wind_update( BEG_UPDATE );											/* Bildschirm sperren */

	if ( sub_dialog->dialog )											/* Fensterdialog? */
		wdlg_redraw( sub_dialog->dialog, &rect, obj, MAX_DEPTH );
	else																		/* normaler Dialog */
		objc_draw( tree, obj, MAX_DEPTH, &rect );

	wind_update( END_UPDATE );											/* Bildschirm freigeben */
}

/*----------------------------------------------------------------------------------------*/ 
/* Unterdialog initialisieren																					*/
/* Funktionsergebnis:	0: Fehler 1: alles in Ordnung													*/
/*	settings:				Druckereinstellung																*/
/*	sub_dialog:				Zeiger auf die Unterdialog-Struktur											*/
/*----------------------------------------------------------------------------------------*/ 
int32 cdecl	pinit_my_special1( PRN_SETTINGS *settings, PDLG_SUB *sub_dialog )
{
	OBJECT	*tree;
	int16		offset;

	tree = sub_dialog->tree;											/* Zeiger auf den Objektbaum */
	offset = sub_dialog->index_offset;								/* Offset fÅr die Objektindizes */

	obj_SELECTED( tree, MYSP_FARBKEIL1 + offset );				/* Objekt anfÑnglich selektieren */

	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Buttons im Unterdialog behandeln																			*/
/* Funktionsergebnis:	0: Fehler 1: alles in Ordnung	PDLG_BUT_DEV: GerÑt wechseln			*/
/*	settings:				Druckereinstellung																*/
/*	sub_dialog:				Zeiger auf die Unterdialog-Struktur											*/
/* exit_obj:				Objektnummer																		*/
/*----------------------------------------------------------------------------------------*/ 
int32 cdecl psub_my_special1( PRN_SETTINGS *settings, PDLG_SUB *sub_dialog, int16 exit_obj )
{
	OBJECT	*tree;
	int16		offset;

	tree = sub_dialog->tree;											/* Zeiger auf den Objektbaum */
	offset = sub_dialog->index_offset;								/* Offset fÅr die Objektindizes */

	switch ( exit_obj - sub_dialog->index_offset )
	{
		case	MYSP_PUSH_ME1:												/* Beispielbutton */
		{
			/* der einzige "aktive" Button in diesem Unterdialog */
			/* invertiert den Status eines Icons */
		
			tree[PUSH_ME_ICON1 + offset].ob_state ^= SELECTED;	/* Selektion eines Icons Ñndern */
			redraw_obj( sub_dialog, PUSH_ME_ICON1 + offset );
			
			obj_DESELECTED( tree, exit_obj );						/* Button wieder normal */
			redraw_obj( sub_dialog, exit_obj );
			break;
		}
	}
	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Felder im Unterdialog auslesen bevor der Unterdialog gewechselt wird							*/
/* Funktionsergebnis:	0: Fehler 1: alles in Ordnung													*/
/*	settings:				Druckereinstellung																*/
/*	sub_dialog:				Zeiger auf die Unterdialog-Struktur											*/
/*----------------------------------------------------------------------------------------*/ 
int32 cdecl	preset_my_special1( PRN_SETTINGS *settings, PDLG_SUB *sub_dialog )
{
	OBJECT	*tree;
	int16		offset;
	
	tree = sub_dialog->tree;
	offset = sub_dialog->index_offset;
	
	/* Objektstati auswerten */

	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Unterdialog initialisieren																					*/
/* Funktionsergebnis:	0: Fehler 1: alles in Ordnung													*/
/*	settings:				Druckereinstellung																*/
/*	sub_dialog:				Zeiger auf die Unterdialog-Struktur											*/
/*----------------------------------------------------------------------------------------*/ 
int32 cdecl	pinit_my_special2( PRN_SETTINGS *settings, PDLG_SUB *sub_dialog )
{
	OBJECT	*tree;
	int16		offset;

	tree = sub_dialog->tree;											/* Zeiger auf den Objektbaum */
	offset = sub_dialog->index_offset;								/* Offset fÅr die Objektindizes */

	/* Objektstati setzen */

	return( 1 );
}

/* ... der zweite Unterdialog enthÑlt keine "aktiven" Buttons und benîtigt */
/* daher auch keine PDLG_HNDL-Funktion */

/*----------------------------------------------------------------------------------------*/ 
/* Felder im Unterdialog "Anschluû" auslesen bevor der Unterdialog gewechselt wird			*/
/* Funktionsergebnis:	0: Fehler 1: alles in Ordnung													*/
/*	settings:				Druckereinstellung																*/
/*	sub_dialog:				Zeiger auf die Unterdialog-Struktur											*/
/*----------------------------------------------------------------------------------------*/ 
int32 cdecl	preset_my_special2( PRN_SETTINGS *settings, PDLG_SUB *sub_dialog )
{
	OBJECT	*tree;
	int16		offset;
	
	tree = sub_dialog->tree;
	offset = sub_dialog->index_offset;
	
	/* Objektstati auswerten */

	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Abtesten, ob der Treiber MACPRN.SYS ist																*/
/* Funktionsresultat:	1: ist MACPRN.SYS																	*/
/*	handle:					Handle des Druckers																*/
/*	id:						Treibernummer																		*/
/*																														*/
/*	Bemerkung:																										*/
/*	Der alte MACPRN liefert die Orientierung nicht korrekt zurÅck, obwohl der Treiber die	*/
/*	Seite drehen kann.																							*/
/*----------------------------------------------------------------------------------------*/ 
static WORD	is_macprn( WORD handle, WORD id )
{
	VDIPB	pb;
	WORD	contrl[16];
	WORD	intin[1];
	WORD	ptsin[1];
	WORD	intout[64];
	WORD	ptsout[64];

	contrl[0] = 248;														/* Funktionsnummer */
	contrl[1] = 0;
	contrl[3] = 1;															/* ID wird Åbergeben */
	contrl[5] = 0;
	contrl[6] = handle;

	intin[0] = id;

	pb.contrl = contrl;
	pb.intin = intin;
	pb.ptsin = ptsin;
   pb.intout = intout;
	pb.ptsout = ptsout;

   vdi( &pb );

	if ( contrl[4] && intout[0] )										/* Treiber vorhanden? */
	{
		BYTE	macprn[6] = { 'M','A','C','P','R','N' };
		WORD	i;
		WORD	len;

		len = contrl[4];
		if ( len > 6 )
			len = 6;															/* nur die ersten 6 Buchstaben abtesten */
		
		for ( i = 0; i < len; i++ )
		{
        if ( intout[i] != macprn[i] )
        {
 	       if ( intout[i] != ( macprn[i] + ( 'a' - 'A' )))
					return( 0 );											/* ist nicht MACPRN */
			}
		}
		return( 1 );
   }
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Rumpffunktion fÅr Druckausgabe																			*/
/* Funktionsresultat:	-																						*/
/*	settings:				Druckereinstellung																*/
/*----------------------------------------------------------------------------------------*/ 
void	print_sample( PRN_SETTINGS *settings )
{
#if 0
	WORD	prn_work_out[57];
	WORD	prn_handle;

	prn_handle = v_opnprn( aes_handle, settings, prn_work_out );

	if ( prn_handle )														/* konnte der Druckertreiber geîffnet werden? */
	{
		WORD	page_inc;
		WORD	no_copies;
		WORD	do_landscape;
		WORD	page;

#if 0
		/* 
			Der Metafile-Treiber benîtigt die folgenden drei
			Aufrufe, damit Programme den Metafile korrekt skalieren
			und anzeigen kînnen. Der Metafile-Treiber unterscheidet
			sich auch insofern von allen anderen Treibern, als daû
			er keine vrt/vro_cpyfm()-Aufrufe erlaubt.
		*/

		if ( settings->driver_id == 31 )								/* Metafile? */
		{
			v_meta_extents( prn_handle, x_min, y_min, x_max, y_max );	/* umgebendes Rechteck */
			vm_pagesize( prn_handle, pgwidth, pgheight );		/* Seitenausmaûe */
			vm_coords( prn_handle, llx, lly, urx, ury );			/* Koordinatensystem */
		}
#endif

		if ( settings->first_page > settings->last_page )		/* rÅckwÑrts drucken? */
			page_inc = -1;
		else																	/* aufsteigende Seitenreihenfolge */
			page_inc = 1;

		if ( v_copies( prn_handle, -1 ) <= 1 )						/* kann der Treiber keine Kopien erzeugen? */
			no_copies = settings->no_copies;
		else																	/* Treiber fertigt selber Kopien an */
			no_copies = 1;

		do_landscape = 0;													/* Treiber sorgt fÅr Drehung */
		if ( settings->orientation == PG_LANDSCAPE )				/* Querformat eingestellt? */
		{
			if ( v_orient( prn_handle, -1 ) != 1 )					/* kein Querformat eingestellt? */
			{
				if ( is_macprn( prn_handle, settings->driver_id ) == 0 )
					do_landscape = 1;										/* selber drehen */
			}
		}

		for ( page = settings->first_page; page <= settings->last_page; page += page_inc )
		{
			if (((( page & 1 ) == 0 ) && ( settings->page_flags & PG_EVEN_PAGES )) ||	/* gerade Seitennummern erlaubt? */
				 (( page & 1 ) && ( settings->page_flags & PG_ODD_PAGES )))					/* ungerade Seitennummern erlaubt? */
			{
				WORD	copy;
				
				for ( copy = 0; copy < no_copies; copy++ )		/* Schleife fÅr Treiber, die keine Kopien erstellen kînnen */
				{
					if ( do_landscape )									/* kann der Treiber kein Querformat ausgeben? */
					{
						/* hier wÑre Ausgabe mit gedrehtem Koordinatensystem angesagt */
					}
					else														/* Treiber sorgt fÅr die Querausgabe */
					{
						/* normal ausgeben */
					}
					
					v_updwk( prn_handle );								/* Seite aufbauen */
					v_clrwk( prn_handle );								/* Seitenvorschub */
				}
			}
		}
	
		v_clswk( prn_handle );											/* Treiber wieder schlieûen */
	}		
#else
	form_alert( 1, fstring_addr[PRINT_ALERT] );
#endif
}

/*----------------------------------------------------------------------------------------*/ 
/* Gespeicherte Druckereinstellung zurÅckliefern														*/
/* Funktionsresultat:	Zeiger auf Druckereinstellung oder 0L										*/
/*	prn_dialog:				Zeiger auf Verwaltungsstruktur (wenn dauerhaft geîffnet) oder 0L	*/
/*----------------------------------------------------------------------------------------*/ 
PRN_SETTINGS	*read_psettings( PRN_DIALOG *prn_dialog )
{
	PRN_DIALOG		*p;
	PRN_SETTINGS	*settings;

	settings = 0L;

	if ( prn_dialog == 0L )												/* noch nicht offen? */
	{
		p = pdlg_create( 0 );											/* kurzzeitig îffnen */
		if ( p == 0L ) 
			return( 0L );
	
		prn_dialog = p;
	}
	else
		p = 0L;

#if 0	
	
	Wenn das Programm die Einstellungen in einer Datei gespeichert hÑtte,
	sollte der folgende Code benutzt werden:
	
	settings = read_settings_from_file();							/* Einstellungen aus programmeigener Datei holen */
	
	if ( settings )
	{
		if ( pdlg_validate_settings( prn_dialog, settings ) == 0 )	/* schwerwiegender Fehler? */
		{
			Mfree( settings );
			settings = 0L;
		}		
	}
#endif

	if ( settings == 0L )
	{
		settings = 	Malloc( pdlg_get_setsize());					/* Speicherbereich anfordern */
		
		if ( settings )
			pdlg_dflt_settings( prn_dialog, settings );			/* und initialisieren */
	}
	
	if ( p )																	/* nur kurzzeitig geîffnet? */
		pdlg_delete( p );

	return( settings );
}

/*----------------------------------------------------------------------------------------*/ 
/* Druckereinstellung speichern																				*/
/* Funktionsresultat:	1: alles in Ordnung																*/
/*	settings:				Druckereinstellung																*/
/*----------------------------------------------------------------------------------------*/ 
WORD	save_psettings( PRN_SETTINGS *settings )
{
	if ( settings )
	{
		#if 0
	
		Wenn das Programm die Einstellungen in einer Datei speichern wÅrde,
		sollte der folgende Code benutzt werden:
		
		write_settings_to_file( settings );							/* Druckereinstellung speichern */
		
		#endif
	
		Mfree( settings );												/* Speicher freigeben */
		return( 1 );
	}
	
	return( 0 );
}

/* Hoch/Querformat, Kopien und gerade/ungerade Seiten anbieten */
#define	PRINT_FLAGS	PDLG_ALWAYS_ORIENT + PDLG_ALWAYS_COPIES + PDLG_EVENODD

/*----------------------------------------------------------------------------------------*/ 
/* Druckdialog îffnen																							*/
/* Funktionsresultat:	Fensterhandle																		*/
/*	settings:				Druckereinstellung																*/
/*	document_name:			Dokumentenname																		*/
/*	kind:						PDLG_PREFS: Einstelldialog PDLG_PRINT: Druckdialog						*/
/*----------------------------------------------------------------------------------------*/ 
WORD	open_print_dialog( PRN_SETTINGS *settings, BYTE *document_name, WORD kind )
{
	extern PRN_DIALOG	*gprn_dialog;
	extern WORD gprn_whdl;
	extern WORD gprn_x;
	extern WORD gprn_y;
	extern PDLG_SUB	*gsub_dialogs;
	
	if ( gprn_dialog )													/* Dialog bereits geîffnet? */
	{
		wind_set( gprn_whdl, WF_TOP, 0, 0, 0, 0 );				/* Fenster nach vorne bringen */
		return( gprn_whdl );
	}
	else
	{
		gprn_dialog = pdlg_create( PDLG_3D );						/* Speicher anfordern, Treiber scannen */
		if ( gprn_dialog )
		{
			gsub_dialogs = create_sub_dialogs( tree_addr, my_subs_for_pdlg, 2 );	/* Liste fÅr zwei Unterdialoge aufbauen */
		
			if ( gsub_dialogs )
				pdlg_add_sub_dialogs( gprn_dialog, gsub_dialogs );	/* Unterdialoge hinzufÅgen */

			gprn_whdl = pdlg_open( gprn_dialog, settings, document_name, PRINT_FLAGS + kind, gprn_x, gprn_y );
	
			if ( gprn_whdl )
				return( gprn_whdl );
			else																/* Fehler beim ôffnen des Fensters */
			{
				pdlg_delete( gprn_dialog );							/* Speicher freigeben */
				gprn_dialog = 0L;
			}
		}
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Druckdialog schlieûen																						*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*----------------------------------------------------------------------------------------*/ 
WORD	close_print_dialog( void )
{
	extern PRN_DIALOG	*gprn_dialog;
	extern WORD gprn_x;
	extern WORD gprn_y;
	extern PDLG_SUB	*gsub_dialogs;
	
	if ( gprn_dialog )													/* Dialog geîffnet? */
	{
		if ( gsub_dialogs )
		{
			pdlg_remove_sub_dialogs( gprn_dialog );			/* Unterdialoge entfernen */
			free_sub_dialogs( gsub_dialogs );						/* Speicher fÅr Liste freigeben */
		}

		pdlg_close( gprn_dialog, &gprn_x, &gprn_y );				/* Fenster schlieûen, Position merken */
		pdlg_delete( gprn_dialog );									/* Speicher freigeben */
		gprn_dialog = 0L;
		return( 1 );
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Auf angeklickten MenÅeintrag reagieren																	*/
/* Funktionsresultat:	-																						*/
/*	title:					Objektnummer des MenÅtitels													*/
/*	entry:					Objektnummer des MenÅpunktes													*/
/*----------------------------------------------------------------------------------------*/ 
void	menu_selected( WORD title, WORD entry )
{
	menu_tnormal( menu_tree, title, 0 );							/* MenÅtitel selektieren */
	
	switch( entry )
	{
		case	DLAYOUT:
		{
			form_alert( 1, fstring_addr[LAYOUT_ALERT] );
			break;
		}
		case	DPAPIER:
		{
	
			menu_ienable( menu_tree, DDRUCKEN, 0 );				/* "Drucken" ist nicht anwÑhlbar */
			open_print_dialog( gprn_settings, "ohne Namen", PDLG_PREFS );	/* Einstelldialog îffnen */
			gprn_is_print_dialog = 0;									/* Einstelldialog wird angezeigt */
			break;
		}
		case	DDRUCKEN:
		{
			menu_ienable( menu_tree, DPAPIER, 0 );					/* "Papierformat" ist nicht anwÑhlbar */
			open_print_dialog( gprn_settings, "ohne Namen", PDLG_PRINT );	/* Druckdialog îffnen */
			gprn_is_print_dialog = 1;									/* Druckdialog wird angezeigt */
			break;
		}
		case	DQUIT:
		{
			if ( gprn_dialog )											/* Dialog noch offen? */
				close_print_dialog();

	 		quit = 1;
	 		break;
		}
	}
	menu_tnormal( menu_tree, title, 1 );							/* MenÅtitel deselektieren */
}

/*----------------------------------------------------------------------------------------*/ 
/* Auf Tastendruck reagieren																					*/
/* Funktionsresultat:	-																						*/
/*	keycode:					ist events->key																	*/
/*	kstate:					ist events->kstate																*/
/*----------------------------------------------------------------------------------------*/ 
void	handle_keybd( WORD keycode, WORD kstate )
{
	if ( kstate == K_CTRL )
	{
		switch ( keycode & 0xff )
		{
			case 'P'-64:	menu_selected( MDATEI, DDRUCKEN );	break;
			case 'Q'-64:	menu_selected( MDATEI, DQUIT );	break;
		}
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* AES-Nachrichten bearbeiten																					*/
/* Funktionsresultat:	-																						*/
/*	msg:						Zeiger auf den Nachrichtenpuffer												*/
/*----------------------------------------------------------------------------------------*/ 
void	handle_message( WORD msg[8] )
{
	switch ( msg[0] )
	{
		case	MN_SELECTED:	menu_selected( msg[3], msg[4] ); break;
	}
}

void	event_loop( void )
{
	EVNT	events;
	
	quit = 0;
	
	while ( quit == 0 )
	{
		EVNT_multi( MU_KEYBD + MU_BUTTON + MU_MESAG, 2, 1, 1,	0L, 0L, 0L, &events );

		if ( events.mwhich & MU_KEYBD )
			handle_keybd( events.key, events.kstate );

		if ( events.mwhich & MU_MESAG )
			handle_message( events.msg );

		if ( gprn_dialog )
		{
			WORD	button;

			if ( pdlg_evnt( gprn_dialog, gprn_settings, &events, &button ) == 0 )	/* Dialog schlieûen? */
			{
				close_print_dialog();									/* Dialog schlieûen */

				if ( gprn_is_print_dialog )							/* Druckdialog? */
				{
					menu_ienable( menu_tree, DPAPIER, 1 );			/* "Papierformat" ist wieder anwÑhlbar */

					if ( button == PDLG_OK )							/* "Drucken" angewÑhlt? */
						print_sample( gprn_settings );
				}
				else															/* Einstelldialog */
					menu_ienable( menu_tree, DDRUCKEN, 1 );		/* "Drucken" ist wieder anwÑhlbar */
			}
		}
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Resource und dazugehîrige Strukturen initialisieren												*/
/*----------------------------------------------------------------------------------------*/ 
void	init_rsrc( void )
{
	rsh = *((RSHDR **)(&_GemParBlk.global[7]));					/* Adresse des Resource-Headers Åber global[7/8] holen */

	tree_addr = (OBJECT **)(((UBYTE *)rsh) + rsh->rsh_trindex);	/* Zeiger auf die Objektbaumtabelle holen */
	tree_count = rsh->rsh_ntree;										/* und Anzahl der ObjektbÑume (von 1 ab gezÑhlt) bestimmen */
	fstring_addr = (BYTE **)((UBYTE *)rsh + rsh->rsh_frstr);

	menu_tree = tree_addr[MENU];

	/* hier kînne ggf. adaptrsc aufgrufen werden */
}

/*----------------------------------------------------------------------------------------*/ 
/* Testen, ob wdlg_xx()/lbox_xx()/fnts_xx()/pdlg_xx()-Funktionen vorhanden sind				*/
/* Funktionsresultat:	1: vorhanden, 0: nicht vorhanden												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	wlfp_available( void )
{
	if ( appl_find( "?AGI" ) == 0 )									/* appl_getinfo() vorhanden? */
	{
		WORD	ag1;
		WORD	ag2;
		WORD	ag3;
		WORD	ag4;

		if ( appl_getinfo( 7, &ag1, &ag2, &ag3, &ag4 ))			/* Unterfunktion 7 aufrufen */
		{
			if (( ag1 & 0x17 ) == 0x17 )								/* wdlg_xx()/lbox_xx()/fnts_xx()/pdlg_xx() vorhanden? */
				return( 1 );
		}	
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Hauptprogramm																									*/
/*----------------------------------------------------------------------------------------*/ 
WORD	main( void )
{
	extern WORD	app_id;
	extern WORD	aes_handle;
	extern WORD	pwchar;
	extern WORD	phchar;
	extern WORD	pwbox;
	extern WORD	phbox;
	
	app_id = appl_init();

	if( app_id != -1 )													/* Anmeldung erfolgreich? */
	{
		if ( wlfp_available())											/* Dialogroutinen vorhanden? */
		{
			aes_handle = graf_handle( &pwchar, &phchar, &pwbox, &phbox );
			graf_mouse( ARROW, 0L );									/* Mauszeiger anschalten */
	
			if( rsrc_load( "PDSMPRSC.RSC" ) )
			{
				init_rsrc();												/* Resource anpassen */

				gprn_settings = read_psettings( 0L );				/* Druckereinstellung einlesen/erzeugen */
				gprn_dialog = 0L;
				gprn_x = -1;												/* Fenster anfÑnglich zentrieren */
				gprn_y = -1;
				gsub_dialogs = 0L;

				menu_bar( menu_tree, 1 );								/* MenÅleiste anzeigen */
				event_loop();
				menu_bar( menu_tree, 0 );								/* MenÅleiste nicht mehr anzeigen */

				save_psettings( gprn_settings );						/* Druckereinstellung speichern */
				rsrc_free();
			}
		}
		else
			form_alert( 1, "[1][Bitte starten Sie die System-|erweiterung WDIALOG.][Ende]" );

		appl_exit();
	}
	return( 0 );
}
