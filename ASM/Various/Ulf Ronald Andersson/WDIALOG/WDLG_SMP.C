/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/


#define	DEBUG	0

/*----------------------------------------------------------------------------------------*/ 
/* Globale Includes																								*/
/*----------------------------------------------------------------------------------------*/ 
#include <PORTAB.H>
#include	<TOS.H>
#include	<VDI.H>
#include	<MT_AES.H>

#include	<STRING.H>
#include	<STDLIB.H>
#include	<STDIO.H>

/*----------------------------------------------------------------------------------------*/ 
/* Lokale Includes																								*/
/*----------------------------------------------------------------------------------------*/ 
#include	"ADAPTRSC.H"
#include "WDLG_SMP.H"

/*----------------------------------------------------------------------------------------*/ 
/* Strukturdefinitionen																							*/
/*----------------------------------------------------------------------------------------*/ 

/* Statt der LBOX_ITEM-Struktur werden in diesem Beispiel die beiden */
/* Strukturen STR_ITEM und PAT_ITEM benutzt. */

typedef struct _str_item
{
	struct _str_item	*next;											/* Zeiger auf den Nachfolger */
	WORD	selected;														/* Status */
	
	BYTE	*str;
} STR_ITEM;

typedef struct _pat_item
{
	struct _pat_item	*next;											/* Zeiger auf den Nachfolger */
	WORD	selected;														/* Status */
	
	WORD	color;
	WORD	index;
} PAT_ITEM;

/*----------------------------------------------------------------------------------------*/ 
/* globale Variablen																								*/
/*----------------------------------------------------------------------------------------*/ 
WORD		app_id,
			aes_handle,
			pwchar, phchar,
			pwbox, phbox;

WORD	aes_flags;
WORD	aes_font;
WORD	aes_height;

RSHDR		*rsh;
OBJECT	**tree_addr;
BYTE		**fstring_addr;
WORD		tree_count;

USERBLK	udef_window_bar;

WORD		work_out[57];
WORD		vdi_handle;

WORD		sample_width;
WORD		sample_height;

/* Zeiger auf Listbox-Strukturen */
LIST_BOX	*style_box;
LIST_BOX	*pat_box;
LIST_BOX	*spice_box;

/* Objekte der Listboxen */
#define	NO_STYLES	4
WORD	style_ctrl[5] = { FSTL_BOX, FSTL_UP, FSTL_DOWN, FSTL_BACK, FSTL_WHITE };
WORD	style_objs[4] = { FSTL_0, FSTL_1, FSTL_2, FSTL_3 };

#define	NO_PATS	13
WORD	pat_ctrl[5] = { PAT_BOX, PAT_LEFT, PAT_RIGHT, -1, -1 };
WORD	pat_objs[13] = { PAT_0, PAT_1, PAT_2, PAT_3, PAT_4, PAT_5, PAT_6, PAT_7, PAT_8, PAT_9, PAT_10, PAT_11, PAT_12 };

#define	NO_SPICES	4
WORD	spice_ctrl[9] = { SPICE_BOX, SPICE_UP, SPICE_DOWN, SPICE_BACK, SPICE_SL, SL_LEFT, SL_RIGHT, SLBK_H, SL_H };
WORD	spice_objs[4] = { SPICE_0, SPICE_1, SPICE_2, SPICE_3 };

/* Strings fÅr die Stil-Box */
BYTE	*style_smp[8] = {	"light",
								"light italic",
								"demi",
								"demi italic",
								"book",
								"italic",
								"bold",
								"bold italic" };

/* Strings fÅr die GewÅrz-Box */
BYTE	*spice_smp[9] = {	"Pfeffer",
								"Salz",
								"Petersilie",
								"Lauch",
								"Brennesselspitzen",
								"Basilikum",
								"Paprika",
								"Knoblauch",
								"Zwiebeln" };

/*----------------------------------------------------------------------------------------*/ 
/* Funktionsprototypen																							*/
/*----------------------------------------------------------------------------------------*/ 
WORD			open_screen_wk( WORD aes_handle, WORD *work_out );
void			deselect_button( DIALOG *dialog, WORD obj );
void			init_rsrc( void );
WORD	cdecl window_bar( PARMBLK *parmblock );
void			do_sample( void );
WORD	cdecl	handle_sample( DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data );
void	set_slider_borders( void );

WORD	cdecl	set_str_item( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, WORD index, void *user_data, GRECT *rect, WORD offset );
WORD	cdecl	set_pat_item( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, WORD index, void *user_data, GRECT *rect, WORD offset );
void	cdecl	slct_style( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, WORD obj_index, WORD last_state );
void 	cdecl	slct_pat( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, WORD obj_index, WORD last_state  );
void	cdecl	slct_spice( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, WORD obj_index, WORD last_state  );

WORD			create_style_box( DIALOG *dialog );
WORD			create_pat_box( DIALOG *dialog );
WORD			create_spice_box( DIALOG *dialog );
STR_ITEM		*build_str_list( BYTE **tab, WORD n );
PAT_ITEM		*build_pat_list( void );

DIALOG		*open_sample( void );
void			close_dlg( DIALOG *dialog );

void			delete_style_box( void );
void			delete_pat_box( void );
void			delete_spice_box( void );
void			free_items( LIST_BOX *box );

void			do_redraw( DIALOG *dialog, GRECT *rect, WORD obj );

/*----------------------------------------------------------------------------------------*/ 
/* Fensterdialog îffnen																							*/
/* Funktionsergebnis:	Zeiger auf DIALOG																	*/
/*----------------------------------------------------------------------------------------*/ 
DIALOG	*open_sample( void )
{
	OBJECT	*tree;
	DIALOG	*dialog;
	
	tree = tree_addr[TESTME];											/* Zeiger auf den Objektbaum */

	dialog = wdlg_create( handle_sample, tree, 0L, 0, 0L, WDLG_BKGD );	/* Dialog-Struktur initialisieren */
	
	if ( dialog )
	{
		if ( create_style_box( dialog ) &&
			  create_pat_box( dialog ) &&
			  create_spice_box( dialog ))								/* lassen sich alle Listboxen anlegen? */
		{	

			if ( wdlg_open( dialog, fstring_addr[TEST_TITEL], NAME + CLOSER + MOVER, -1, -1, 0, 0L ))	/* Dialog zeichnen */
			{
				sample_width = tree->ob_width;
				sample_height = tree->ob_height;
				return( dialog );
			}
			else																/* Fehler beim ôffnen */
			{
				delete_spice_box();										/* Listbox lîschen */
				delete_pat_box();											/* Listbox lîschen */
				delete_style_box();										/* Listbox lîschen */
				wdlg_delete( dialog );									/* Dialogstruktur lîschen */
			}
		}
	}
	return( 0L );
}

/*----------------------------------------------------------------------------------------*/ 
/* Fensterdialog schlieûen																						*/
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
	EVNT	events;
	DIALOG	*d_sample;
	
	d_sample = open_sample();
	
	if ( d_sample )
		wdlg_set_edit( d_sample, 0 );									/* kein aktives Edit-Feld */

	while( d_sample )									/* solange ein Dialog offen ist */
	{
		EVNT_multi( MU_KEYBD + MU_BUTTON + MU_MESAG, 2, 1, 1,	0L, 0L, 0L, &events );

		if ( d_sample )													/* ist die Beispielbox offen? */
		{
			if	( wdlg_evnt( d_sample, &events ) == 0 )			/* wurde Dialog geschlossen? */
			{
				/* irgendwelche Aktionen weil der Dialog geschlossen wurde... */

				delete_spice_box();										/* Listbox lîschen */
				delete_pat_box();											/* Listbox lîschen */
				delete_style_box();										/* Listbox lîschen */

				close_dlg( d_sample );									/* Dialog schlieûen */
				d_sample = 0;
			}
		}	

		/* hier kînnte die Applikation die sie betreffenden Ereignisse auswerten, z.B.:
		
		if( events.mwhich & MU_KEYBD )						/* Tastendruck? */
			hdle_keybd( keycode, mkstate );
		
		if( events.which & MU_BUTTON )						/* Mausclicks? */
			hdle_button( mousex, mousey, mbutton, mkstate, mclicks );

		if( events.which & MU_MESAG )							/* Mitteilungen des SCRENMGR? */
			hdle_mesag( buf );
			
		*/
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Service-Routine fÅr Fensterdialog 																		*/
/* Funktionsergebnis:	0: Dialog schlieûen 1: weitermachen											*/
/*	dialog:					Zeiger auf die Dialog-Struktur												*/
/*	events:					Zeiger auf EVNT-Struktur oder 0L												*/
/*	obj:						Nummer des Objekts oder Ereignisnummer										*/
/*	clicks:					Anzahl der Mausklicks															*/
/*	data:						Zeiger auf zusÑtzliche Daten													*/
/*----------------------------------------------------------------------------------------*/ 
WORD	cdecl	handle_sample( DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data )
{
	OBJECT	*tree;
	GRECT		rect;
	
	wdlg_get_tree( dialog, &tree, &rect );							/* Adresse des Baums erfragen */

	if ( obj < 0 )															/* Ereignis oder Objektnummer? */
	{
																				/* alle Ereignisse auûer HNDL_CLSD */
																				/* werden bei diesem Beispiel ignoriert */
			
		if ( obj == HNDL_CLSD )											/* Closer betÑtigt? */
			return( 0 );													/* beenden */ 
	}
	else																		/* ein Objekt ist angewÑhlt worden */
	{
		extern LIST_BOX	*style_box;
		extern LIST_BOX	*pat_box;
		extern LIST_BOX	*spice_box;

		if ( clicks == 2 )												/* Doppelklick? */
			obj |= 0x8000;

		if ( lbox_do( style_box, obj ) == -1 )						/* Doppelklick? */
#if DEBUG
			return( 1 );
#else		
			return( 0 );
#endif

		if ( lbox_do( pat_box, obj ) == -1 )						/* Doppelklick? */
#if DEBUG
			return( 1 );
#else		
			return( 0 );
#endif

		if ( lbox_do( spice_box, obj ) == -1 )						/* Doppelklick? */
#if DEBUG
			return( 1 );
#else		
			return( 0 );
#endif

		obj &= 0x7fff;

		switch ( obj )														/* Aktionen einleiten (falls nîtig) */
		{
			case	TOK:		return( 0 );								/* wir kennen nur OK */
			case	TEST_BT:	return( 0 );								/* und Abbruch */
			case	TSIZE:													/* Grîûe verÑndern */
			{
				GRECT	win;
				GRECT	work;
				WORD	handle;
				WORD	w;
				WORD	h;
	
				wind_update( BEG_MCTRL );
	
				handle = wdlg_get_handle( dialog );
				wind_get( handle, WF_CURRXYWH, &win.g_x, &win.g_y, &win.g_w, &win.g_h );
				wind_get( handle, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h );
				
				if ( graf_rubbox( win.g_x, win.g_y, win.g_w - work.g_w + sample_width, win.g_h - work.g_h + sample_height, &w, &h ))
				{
					GRECT	last;
					
					objc_offset( tree, TBUTTONS, &last.g_x, &last.g_y );	/* Position des Sizers */
					last.g_w = tree[TBUTTONS].ob_width;
					last.g_h = tree[TBUTTONS].ob_height;
					
					 w -= win.g_w - work.g_w;							/* Breite der ArbeitsflÑche */
					 h -= win.g_h - work.g_h;							/* Hîhe der ArbeitsflÑche */
					 
					tree[TBUTTONS].ob_x += w - tree->ob_width;		/* Sizer verschieben */
					tree[TBUTTONS].ob_y += h - tree->ob_height;
					tree->ob_width = w;									/* Wurzelobjekt verkleinern */
					tree->ob_height = h;
					
					wdlg_set_size( dialog, (GRECT *) &tree->ob_x );	/* Grîûe verÑndern und Redraw auslîsen */
					
					do_redraw( dialog, &last, ROOT );				/* alten Sizer entfernen */
				}

				do_redraw( dialog, (GRECT *) &tree->ob_x, TBUTTONS );	/* Sizer zeichnen */
				wind_update( END_MCTRL );
				break;
			}
		}
	}
	
	return( 1 );															/* alles in Ordnung - weiter so */
}

/*----------------------------------------------------------------------------------------*/ 
/* Listbox fÅr die Fontstile anlegen																		*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	dialog:					Zeiger auf die Dialog-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	create_style_box( DIALOG *dialog )
{	
	STR_ITEM	*style_list;

	style_list = build_str_list( style_smp, 8 );					/* verkettete Liste mit Fontstilen aufbauen */

	if ( style_list )
	{
		extern LIST_BOX	*style_box;
		OBJECT	*tree;
	
		tree = tree_addr[TESTME];										/* Zeiger auf den Objektbaum */
		strcpy( tree[FSTL_SAMPLE].ob_spec.tedinfo->te_ptext, style_list->str );	/* Sample-String setzen */

		/* vertikale Listbox mit Auto-Scrolling und Real-Time-Slider anlegen */
		style_box = lbox_create( tree, slct_style, set_str_item, (LBOX_ITEM *) style_list,
										 NO_STYLES, 0, style_ctrl, style_objs, 
										 LBOX_VERT + LBOX_AUTO + LBOX_AUTOSLCT + LBOX_REAL + LBOX_SNGL, 
										 40, dialog, dialog, 0, 0, 0, 0 );
		
		if ( style_box )													/* alles in Ordnung? */
			return( 1 );
	}					
	return( 0 );															/* Fehler */
}

/*----------------------------------------------------------------------------------------*/ 
/* Listbox fÅr die Muster anlegen																			*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	dialog:					Zeiger auf die Dialog-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	create_pat_box( DIALOG *dialog )
{	
	PAT_ITEM	*pat_list;

	pat_list = build_pat_list();										/* verkettete Liste mit Farbe und Muster aufbauen */

	if ( pat_list )
	{
		extern LIST_BOX	*pat_box;
		OBJECT	*tree;
	
		tree = tree_addr[TESTME];										/* Zeiger auf den Objektbaum */
		tree[PAT_SAMPLE].ob_spec.obspec.interiorcol = pat_list->color;
		tree[PAT_SAMPLE].ob_spec.obspec.fillpattern = pat_list->index;

		/* horizontale Listbox mit Auto-Scrolling und Real-Time-Slider anlegen */
		pat_box = lbox_create( tree, slct_pat, set_pat_item, (LBOX_ITEM *) pat_list,
									  NO_PATS, 0, pat_ctrl, pat_objs, 
									  LBOX_AUTO + LBOX_AUTOSLCT + LBOX_REAL + LBOX_SNGL, 
									  20, dialog, dialog, 0, 0, 0, 0 );

		if ( pat_box )														/* alles in Ordnung? */
			return( 1 );
	}					
	return( 0 );															/* Fehler */
}
							
/*----------------------------------------------------------------------------------------*/ 
/* Listbox fÅr die GewÅrze anlegen																			*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	dialog:					Zeiger auf die Dialog-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
WORD	create_spice_box( DIALOG *dialog )
{	
	STR_ITEM	*spice_list;

	spice_list = build_str_list( spice_smp, 9 );					/* verkettete Liste aufbauen */

	if ( spice_list )
	{
		extern LIST_BOX	*spice_box;
		OBJECT	*tree;
	
		tree = tree_addr[TESTME];										/* Zeiger auf den Objektbaum */

		/* vertikale Listbox mit Auto-Scrolling, Real-Time-Slider und Mehrfachselektion anlegen */
		spice_box = lbox_create( tree, slct_spice, set_str_item, (LBOX_ITEM *) spice_list,
										 NO_SPICES, 0, spice_ctrl, spice_objs, 
										 LBOX_VERT + LBOX_AUTO + LBOX_AUTOSLCT + LBOX_REAL + LBOX_SHFT + LBOX_2SLDRS, 
										 40, dialog, dialog, 12, 0, 40, 5 );

		if ( spice_box )													/* alles in Ordnung? */
			return( 1 );
	}					
	return( 0 );															/* Fehler */
}

/*----------------------------------------------------------------------------------------*/ 
/* Verkettete Liste mit Strings aufbauen																	*/
/* Funktionsresultat:	Zeiger auf die Liste																*/
/*	tab:						Zeiger auf ein Feld mit Zeigern auf Strings								*/
/*	n:							Anzahl der Strings																*/
/*----------------------------------------------------------------------------------------*/ 
STR_ITEM	*build_str_list( BYTE **tab, WORD n )
{
	STR_ITEM	*str_items;

	str_items = 0L;
	
	while ( n > 0 )
	{
		STR_ITEM	*tmp;

		tmp = malloc( sizeof( STR_ITEM ));							/* Speicher fÅr Eintrag anfordern */

		n--;
		
		if ( tmp )
		{
			tmp->next = str_items;										/* Zeiger auf den Nachfolger */
			tmp->selected = 0;											/* nicht selektiert */
			tmp->str = (void *) tab[n];								/* Zeiger auf String */

			str_items = tmp;
		}
	}
	str_items->selected = 1;											/* ersten Eintrag selektieren */

	return( str_items );
}

/*----------------------------------------------------------------------------------------*/ 
/* Verkettete Liste mit Attributen fÅr Farbe und Muster aufbauen									*/
/* Funktionsresultat:	Zeiger auf die Liste																*/
/*----------------------------------------------------------------------------------------*/ 
PAT_ITEM	*build_pat_list( void )
{
	PAT_ITEM	*patterns;
	WORD	color;

	patterns = 0L;
	
	for ( color = 15; color >= 1; color-- )
	{
		WORD	index;
		
		for ( index = 7; index >= 0; index-- )
		{
			PAT_ITEM	*tmp;
			
			tmp = malloc( sizeof( PAT_ITEM ));
			
			if ( tmp )
			{
				tmp->next = patterns;									/* Zeiger auf den Nachfolger */
				tmp->selected = 0;										/* nicht selektiert */
				tmp->color = color;										/* Farbe des FÅllmusters */
				tmp->index = index;										/* Index des FÅllmusters */

				patterns = tmp;
			}
		}
	}
	patterns->selected = 1;												/* ersten Eintrag selektieren */

	return( patterns );
}

/*----------------------------------------------------------------------------------------*/ 
/* Listbox fÅr Fontstile lîschen																				*/
/* Funktionsresultat:	-																						*/
/*----------------------------------------------------------------------------------------*/ 
void	delete_style_box( void )
{
	extern LIST_BOX	*style_box;
	
	free_items( style_box );											/* Speicher fÅr verkettete Liste freigeben */
	lbox_delete( style_box );
}

/*----------------------------------------------------------------------------------------*/ 
/* Listbox fÅr die Muster lîschen																			*/
/* Funktionsresultat:	-																						*/
/*----------------------------------------------------------------------------------------*/ 
void	delete_pat_box( void )
{
	extern LIST_BOX	*pat_box;
	
	free_items( pat_box );												/* Speicher fÅr verkettete Liste freigeben */
	lbox_delete( pat_box );
}

/*----------------------------------------------------------------------------------------*/ 
/* Listbox fÅr die GewÅrze lîschen																			*/
/* Funktionsresultat:	-																						*/
/*----------------------------------------------------------------------------------------*/ 
void	delete_spice_box( void )
{
	extern LIST_BOX	*spice_box;
	
	free_items( spice_box );											/* Speicher fÅr verkettete Liste freigeben */
	lbox_delete( spice_box );
}

/*----------------------------------------------------------------------------------------*/ 
/* Speicher fÅr alle EintrÑge in der Listbox freigeben												*/
/* Funktionsresultat:	-																						*/
/*	box:						Zeiger auf die Listbox-Struktur												*/
/*----------------------------------------------------------------------------------------*/ 
void	free_items( LIST_BOX *box )
{
	LBOX_ITEM	*item;
	
	item = lbox_get_items( box );
	
	while ( item )
	{
		LBOX_ITEM *next;
		
		next = item->next;
		free( item );														/* Speicher freigeben */
		item = next;														/* nÑchstes Element */
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* String und Objektstatus eines GTEXT-Objekts in der Listbox setzen								*/
/* Funktionsresultat:	Nummer des zu zeichnenden Startobjekts										*/
/*	box:						Zeiger auf die Listbox-Struktur												*/
/*	tree:						Zeiger auf den Objektbaum														*/
/* item:						Zeiger auf den Eintrag															*/
/* index:					Objektnummer																		*/
/* user_data:				...																					*/
/*	rect:						GRECT fÅr Selektion/Deselektion oder 0L (nicht verÑnderbar)			*/					
/*----------------------------------------------------------------------------------------*/ 
WORD	cdecl	set_str_item( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, WORD index, void *user_data, GRECT *rect, WORD offset )
{
	BYTE	*ptext;
	BYTE	*str;

	ptext = tree[index].ob_spec.tedinfo->te_ptext;				/* Zeiger auf String des GTEXT-Objekts */

	if ( item )																/* LBOX_ITEM vorhanden? */
	{
		if ( item->selected )											/* selektiert? */
			tree[index].ob_state |= SELECTED;
		else
			tree[index].ob_state &= ~SELECTED;

		str = ((STR_ITEM *)item)->str;								/* Zeiger auf den String */			

		if ( offset == 0 )
		{
			if ( *ptext )
				*ptext++ = ' ';											/* vorangestelltes Leerzeichen */
		}
		else
			offset -= 1;
		
		if ( offset <= strlen( str ))
		{
			str += offset;

			while ( *ptext && *str )
				*ptext++ = *str++;
		}
	}
	else																		/* nicht benutzter Eintrag */
		tree[index].ob_state &= ~SELECTED;

	while ( *ptext )
		*ptext++ = ' ';													/* Stringende mit Leerzeichen auffÅllen */	

	return( index );														/* Objektnummer des Startobjekts */
}

/*----------------------------------------------------------------------------------------*/ 
/* Farbe, Muster und Rahmen eines Objekts in der Listbox setzen									*/
/* Funktionsresultat:	Nummer des zu zeichnenden Startobjekts										*/
/*	box:						Zeiger auf die Listbox-Struktur												*/
/*	tree:						Zeiger auf den Objektbaum														*/
/* item:						Zeiger auf den Eintrag															*/
/* index:					Objektnummer																		*/
/* user_data:				...																					*/
/*	rect:						GRECT fÅr Selektion/Deselektion oder 0L (nicht verÑnderbar)			*/					
/*----------------------------------------------------------------------------------------*/ 
WORD	cdecl	set_pat_item( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, WORD index, void *user_data, GRECT *rect, WORD offset )
{
	if ( item )
	{
		if ( item->selected )											/* selektiert? */
			tree[index].ob_spec.obspec.framesize = 2;				/* dann innerer Rahmen mit 2 Pixeln */
		else
			tree[index].ob_spec.obspec.framesize = 0;				/* sonst kein Rahmen */
	
		tree[index].ob_spec.obspec.interiorcol = ((PAT_ITEM *)item)->color;	/* Farbe */
		tree[index].ob_spec.obspec.fillpattern = ((PAT_ITEM *)item)->index;	/* Muster-Index */
	}
	
	return( index );														/* Objektnummer des Startobjekts */
}

/*----------------------------------------------------------------------------------------*/ 
/* Ein Eintrag in der Stil-Listbox ist angewÑhlt worden...											*/
/* Funktionsergebnis:	-																						*/
/*	box:						Zeiger auf die Listbox-Struktur												*/
/*	tree:						Zeiger auf den Objektbaum des Dialogs										*/
/*	item:						Zeiger auf den angewÑhlten Eintrag											*/
/*	user_data:				...																					*/
/*	obj_index:				Index des Objekt, evtl. | 0x8000, evtl. 0 (nicht sichtbar)			*/
/*	last_state:				der vorheriger Status															*/
/*----------------------------------------------------------------------------------------*/ 
void	cdecl	slct_style( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, WORD obj_index, WORD last_state )
{
#if DEBUG
	if ( obj_index & 0x8000 )
		printf( "Doppelklick\r\n" );

	printf( "Slct: obj %d status %d letzer %d\r\n", obj_index & 0x7fff, item->selected, last_state );
#endif
		
	if ( item->selected && ( item->selected != last_state ))
	{
		strcpy( tree[FSTL_SAMPLE].ob_spec.tedinfo->te_ptext, ((STR_ITEM *) item)->str );	/* neuen String setzen */
		do_redraw( user_data, (GRECT *) &tree->ob_x, FSTL_SAMPLE );	/* Text zeichnen */
	}
}


/*----------------------------------------------------------------------------------------*/ 
/* Ein Eintrag in der Muster-Listbox ist angewÑhlt worden...										*/
/* Funktionsergebnis:	-																						*/
/*	box:						Zeiger auf die Listbox-Struktur												*/
/*	tree:						Zeiger auf den Objektbaum des Dialogs										*/
/*	item:						Zeiger auf den angewÑhlten Eintrag											*/
/*	user_data:				...																					*/
/*	obj_index:				Index des Objekt, evtl. | 0x8000, evtl. 0 (nicht sichtbar)			*/
/*	last_state:				der vorheriger Status															*/
/*----------------------------------------------------------------------------------------*/ 
void	cdecl	slct_pat( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, WORD obj_index, WORD last_state  )
{
#if DEBUG
	if ( obj_index & 0x8000 )
		printf( "Doppelklick\r\n" );

	printf( "Slct: obj %d status %d letzer %d\r\n", obj_index & 0x7fff, item->selected, last_state );
#endif

	if ( item->selected && ( item->selected != last_state ))
	{
		tree[PAT_SAMPLE].ob_spec.obspec.interiorcol = ((PAT_ITEM *)item)->color;	/* Farbe */
		tree[PAT_SAMPLE].ob_spec.obspec.fillpattern = ((PAT_ITEM *)item)->index;	/* Muster-Index */
		do_redraw( user_data, (GRECT *) &tree->ob_x, PAT_SAMPLE );	/* Rechteck zeichnen */
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Ein Eintrag in der GewÅrz-Listbox ist angewÑhlt worden...										*/
/* Funktionsergebnis:	-																						*/
/*	box:						Zeiger auf die Listbox-Struktur												*/
/*	tree:						Zeiger auf den Objektbaum des Dialogs										*/
/*	item:						Zeiger auf den angewÑhlten Eintrag											*/
/*	user_data:				...																					*/
/*	obj_index:				Index des Objekt, evtl. | 0x8000, evtl. 0 (nicht sichtbar)			*/
/*	last_state:				der vorheriger Status															*/
/*----------------------------------------------------------------------------------------*/ 
void	cdecl	slct_spice( LIST_BOX *box, OBJECT *tree, LBOX_ITEM *item, void *user_data, WORD obj_index, WORD last_state )
{
#if DEBUG
	if ( obj_index & 0x8000 )
		printf( "Doppelklick\r\n" );

	printf( "Slct: obj %d status %d letzer %d\r\n", obj_index & 0x7fff, item->selected, last_state );
#endif

	/* in diesem Fall gibt es nichts zu tun... */
}

/*----------------------------------------------------------------------------------------*/ 
/* Objekt zeichnen																								*/
/* Funktionsresultat:	-																						*/
/*	tree:						Zeiger auf den Objektbaum														*/
/*	rect:						begrenzendes Rechteck															*/
/*	obj:						Objektnummer																		*/
/*	depth:					Anzahl der Objektebenen															*/
/*----------------------------------------------------------------------------------------*/ 
void	do_redraw( DIALOG *dialog, GRECT *rect, WORD obj )
{
	wind_update( BEG_UPDATE );
	wdlg_redraw( dialog, rect, obj, MAX_DEPTH );
	wind_update( END_UPDATE );
}

/*----------------------------------------------------------------------------------------*/ 
/* Selektion eines Buttons lîschen und Button zeichnen												*/
/* Funktionsergebnis:	-																						*/
/*	fnt_dialog:				Zeiger auf die Fontdialog-Struktur											*/
/*	obj:						Objektnummer																		*/
/*----------------------------------------------------------------------------------------*/ 
void	deselect_button( DIALOG *dialog, WORD obj )
{
	OBJECT	*tree;
	GRECT		rect;

	wdlg_get_tree( dialog, &tree, &rect );
	
	if	( tree[obj].ob_state & SELECTED )							/* ist der Button selektiert? */
	{
		tree[obj].ob_state &= ~SELECTED;
		do_redraw( dialog, &rect, obj );
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Resource und dazugehîrige Strukturen initialisieren												*/
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/ 
void	init_rsrc( void )
{
	OBJECT	*objs;
	UWORD		no_objs;
	OBJECT	*tree;
	WORD	hor_3d;
	WORD	ver_3d;

	aes_flags = get_aes_info( &aes_font, &aes_height, &hor_3d, &ver_3d );

	rsh = *((RSHDR **)(&_GemParBlk.global[7]));					/* Adresse des Resource-Headers Åber global[7/8] holen */

	tree_addr = (OBJECT **)(((UBYTE *)rsh) + rsh->rsh_trindex);	/* Zeiger auf die Objektbaumtabelle holen */
	tree_count = rsh->rsh_ntree;										/* und Anzahl der ObjektbÑume (von 1 ab gezÑhlt) bestimmen */
	fstring_addr = (BYTE **)((UBYTE *)rsh + rsh->rsh_frstr);	/* Zeiger auf die Free-Strings */
	objs = (OBJECT *) (((BYTE *) rsh ) + rsh->rsh_object );	/* Zeiger auf die Objekte */
	no_objs = rsh->rsh_nobs;											/* Anzahl der Objekte */

	tree_addr[TESTME][TSIZE].ob_x -= 1;								/* Position und Grîûe des Sizers korrigieren */
	tree_addr[TESTME][TSIZE].ob_y -= 1;
	tree_addr[TESTME][TSIZE].ob_width += 2;
	tree_addr[TESTME][TSIZE].ob_height += 2;
	
	if ( aes_flags & GAI_3D )											/* 3D-Look? */
		adapt3d_rsrc( objs, no_objs, hor_3d, ver_3d );
	else																		/* 3D-Flags lîschen */
	{
		no3d_rsrc( objs, no_objs, 1 );

		tree = tree_addr[TESTME];
		tree[FSTL_BACK].ob_spec.obspec.interiorcol = 1;			/* Farbe schwarz */
		tree[FSTL_BACK].ob_spec.obspec.fillpattern = 1;			/* Muster */
	
		tree[SPICE_BACK].ob_spec.obspec.interiorcol = 1;			/* Farbe schwarz */
		tree[SPICE_BACK].ob_spec.obspec.fillpattern = 1;			/* Muster */

		tree[SLBK_H].ob_spec.obspec.interiorcol = 1;			/* Farbe schwarz */
		tree[SLBK_H].ob_spec.obspec.fillpattern = 1;			/* Muster */
		set_slider_borders();											/* Slider-Objekte auf 1 Pixel Rand setzen */
	}
	
	if (( aes_flags & GAI_MAGIC ) == 0 )							/* kein MagiC-AES? */
	{
		OBJECT	*slct;
		OBJECT	*deslct;
		
		if ( phchar < 15 )
		{
			slct = tree_addr[IMAGE_DIALOG] + RADIO_M_SLCT;
			deslct = tree_addr[IMAGE_DIALOG] + RADIO_M_DESLCT;
		}
		else
		{
			slct = tree_addr[IMAGE_DIALOG] + RADIO_SLCT;
			deslct = tree_addr[IMAGE_DIALOG] + RADIO_DESLCT;
		}

		substitute_objects( objs, no_objs, aes_flags, slct, deslct );
		set_slider_borders();											/* Slider-Objekte auf 1 Pixel Rand setzen */
	}
	else
		substitute_objects( objs, no_objs, aes_flags, 0L, 0L );
}

/*----------------------------------------------------------------------------------------*/ 
/* RÑnder der Slider-Objekte auf 1 Pixel setzen															*/
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/ 
void	set_slider_borders( void )
{
	extern OBJECT	**tree_addr;
	OBJECT	*tree;
	
	tree = tree_addr[TESTME];

	tree[FSTL_WHITE].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */
	tree[FSTL_DOWN].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */
	tree[FSTL_UP].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */

	tree[PAT_RIGHT].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */
	tree[PAT_LEFT].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */

	tree[SPICE_BACK].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */
	tree[SPICE_SL].ob_spec.obspec.framesize = 1;						/* innen 1 Pixel Rahmen */
	tree[SPICE_DOWN].ob_spec.obspec.framesize = 1;						/* innen 1 Pixel Rahmen */
	tree[SPICE_UP].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */

	tree[SLBK_H].ob_spec.obspec.framesize = 1;						/* innen 1 Pixel Rahmen */
	tree[SL_H].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */
	tree[SL_LEFT].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */
	tree[SL_RIGHT].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */
	
	tree[TSIZE].ob_spec.obspec.framesize = 1;					/* innen 1 Pixel Rahmen */

}

/*----------------------------------------------------------------------------------------*/ 
/* Box mit innerem grauen Rand fÅr sample_text() bzw.check_box() zeichnen						*/
/* Funktionsresultat:																							*/
/* parmblock:				Zeiger auf die Parameter-Block-Struktur									*/
/*----------------------------------------------------------------------------------------*/ 
WORD	cdecl window_bar( PARMBLK *parmblock )
{
	extern WORD vdi_handle;
	WORD	clip_rect[4];
	WORD	rect[4];
	WORD	xy[10];

	clip_rect[0] = parmblock->pb_xc;									/* Clipping-Rechteck... */
	clip_rect[1] = parmblock->pb_yc;
	clip_rect[2] = clip_rect[0] - 1 + parmblock->pb_wc;
	clip_rect[3] = clip_rect[1] - 1 + parmblock->pb_hc;

	vs_clip( vdi_handle, 1, clip_rect );							/* Zeichenoperationen auf gegebenen Bereich beschrÑnken */
	
	rect[0] = parmblock->pb_x;											/* Objekt-Rechteck... */
	rect[1] = parmblock->pb_y;
	rect[2] = rect[0] - 1 + parmblock->pb_w;
	rect[3] = rect[1] - 1 + parmblock->pb_h;
	
	vswr_mode( vdi_handle, 1 );										/* Ersetzend */

	vsf_interior( vdi_handle, FIS_SOLID );
	vsf_color( vdi_handle, 8 );										/* hellgrau */
	xy[0] = rect[0] + 1;
	xy[1] = rect[1] + 1;
	xy[2] = rect[2] - 1;
	xy[3] = rect[3] - 1;
	vr_recfl( vdi_handle, xy );										/* hellgraue Box zeichnen */

	vsl_type( vdi_handle, 1 );
	vsl_color( vdi_handle, 0 );										/* weiû */
	xy[0] = rect[0];
	xy[1] = rect[3];
	xy[2] = rect[0];
	xy[3] = rect[1];
	xy[4] = rect[2];
	xy[5] = rect[1];
	v_pline( vdi_handle, 3, xy );										/* weiûen Rahmen zeichnen */

	vsl_color( vdi_handle, 9 );										/* grau */
	xy[0] = rect[0];
	xy[1] = rect[3];
	xy[2] = rect[2];
	xy[3] = rect[3];
	xy[4] = rect[2];
	xy[5] = rect[1];
	v_pline( vdi_handle, 3, xy );										/* grauen Rahmen zeichnen */

	xy[0] = rect[0] + 2;
	xy[1] = rect[1] + 3;
	xy[2] = rect[2] - 2;
	xy[3] = rect[1] + 3;

	while (( xy[1] + 1 ) < rect[3] )
	{
		vsl_color( vdi_handle, 9 );									/* grau */
		v_pline( vdi_handle, 2, xy );					

		xy[1]++;
		xy[3]++;
		vsl_color( vdi_handle, 0 );									/* weiû */
		v_pline( vdi_handle, 2, xy );					

		xy[1] += 3;
		xy[3] += 3;
	}
	return( parmblock->pb_currstate );
}

/*----------------------------------------------------------------------------------------*/ 
/* Virtuelle Bildschirm-Workstation îffnen																*/
/* Funktionsresultat:	VDI-Handle oder 0 als Fehlernummer											*/
/* work_out:				GerÑteinformationen																*/
/*----------------------------------------------------------------------------------------*/ 
WORD	open_screen_wk( WORD aes_handle, WORD *work_out )
{
	WORD	work_in[11];
	WORD	handle;
	WORD	i;

	for( i = 1; i < 10; i++ )
		work_in[i] = 1;

	work_in[0] = Getrez() + 2;											/* Auflîsung */
	work_in[10] = 2;														/* Rasterkoordinaten benutzen */
	handle = aes_handle;

	v_opnvwk( work_in, &handle, work_out );
	return( handle );
}

/*----------------------------------------------------------------------------------------*/ 
/* Hauptprogramm																									*/
/*----------------------------------------------------------------------------------------*/ 
main( void )
{
	WORD	ret_code = -1;

	app_id = appl_init();												/* anmelden */
	
	if( app_id != -1 )
	{
		aes_handle = graf_handle( &pwchar, &phchar, &pwbox, &phbox );		

		vdi_handle = open_screen_wk( aes_handle, work_out );

		if ( vdi_handle > 0 )
		{
			graf_mouse( ARROW, 0L );
	
			if( rsrc_load( "WDLG_SMP.RSC" ))							/* Resource laden */
			{
				init_rsrc();												/* initialisieren */
				if (( aes_flags & ( GAI_WDLG + GAI_LBOX )) == ( GAI_WDLG + GAI_LBOX ))
				{
					do_sample();											/* Fensterdialog anzeigen */
					ret_code = 0;
				}
				else
					form_alert( 1, fstring_addr[WDLG_MISSING] );

				substitute_free();										/* Speicher fÅr Userdefs freigeben */
				rsrc_free();
			}
			v_clsvwk( vdi_handle );
		}
		appl_exit();														/* abmelden */
	}
	return( ret_code );
}
