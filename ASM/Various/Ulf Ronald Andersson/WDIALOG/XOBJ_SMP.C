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
#include	<STDIO.h>

/*----------------------------------------------------------------------------------------*/ 
/* Lokale Includes																								*/
/*----------------------------------------------------------------------------------------*/ 
#include	"ADAPTRSC.H"
#include "XOBJ_SMP.H"

/*----------------------------------------------------------------------------------------*/ 
/* Strukturdefinitionen																							*/
/*----------------------------------------------------------------------------------------*/ 

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

WORD		work_out[57];
WORD		vdi_handle;


/*----------------------------------------------------------------------------------------*/ 
/* Funktionsprototypen																							*/
/*----------------------------------------------------------------------------------------*/ 
WORD			open_screen_wk( WORD aes_handle, WORD *work_out );
void			deselect_button( DIALOG *dialog, WORD obj );
void			init_rsrc( void );
WORD	cdecl window_bar( PARMBLK *parmblock );
void			do_sample( void );
WORD	cdecl	handle_sample( DIALOG *dialog, EVNT *events, WORD obj, WORD clicks, void *data );

DIALOG		*open_sample( void );
void			close_dlg( DIALOG *dialog );

void			do_redraw( DIALOG *dialog, GRECT *rect, WORD obj );

/*----------------------------------------------------------------------------------------*/ 

DIALOG	*open_sample( void )
{
	OBJECT	*tree;
	DIALOG	*dialog;
	
	tree = tree_addr[OBJDEMO];											/* Zeiger auf den Objektbaum */

	dialog = wdlg_create( handle_sample, tree, 0L, 0, 0L, WDLG_BKGD );	/* Dialog-Struktur initialisieren */
	
	if ( dialog )
	{
		if ( wdlg_open( dialog, fstring_addr[TEST_TITEL], NAME + CLOSER + MOVER, -1, -1, 0, 0L ))	/* Dialog zeichnen */
			return( dialog );
	}
	return( 0L );
}

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
				close_dlg( d_sample );
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
		obj &= 0x7fff;

		switch ( obj )														/* Aktionen einleiten (falls nîtig) */
		{
			case	TOK:		return( 0 );								/* wir kennen nur OK */
			case	CANCEL:	return( 0 );								/* und Abbruch */
			default:			return( 1 );
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
	WORD		hor_3d, ver_3d;
	
	aes_flags = get_aes_info( &aes_font, &aes_height, &hor_3d, &ver_3d );

	rsh = *((RSHDR **)(&_GemParBlk.global[7]));					/* Adresse des Resource-Headers Åber global[7/8] holen */

	tree_addr = (OBJECT **)(((UBYTE *)rsh) + rsh->rsh_trindex);	/* Zeiger auf die Objektbaumtabelle holen */
	tree_count = rsh->rsh_ntree;										/* und Anzahl der ObjektbÑume (von 1 ab gezÑhlt) bestimmen */
	fstring_addr = (BYTE **)((UBYTE *)rsh + rsh->rsh_frstr);	/* Zeiger auf die Free-Strings */
	objs = (OBJECT *) (((BYTE *) rsh ) + rsh->rsh_object );	/* Zeiger auf die Objekte */
	no_objs = rsh->rsh_nobs;											/* Anzahl der Objekte */

	if ( aes_flags & GAI_3D )											/* 3D-Look? */
		adapt3d_rsrc( objs, no_objs, hor_3d, ver_3d );
	else																		/* 3D-Flags lîschen */
	{
		no3d_rsrc( objs, no_objs, 1 );
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
	}
	else
		substitute_objects( objs, no_objs, aes_flags, 0L, 0L );
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
	
			if( rsrc_load( "XOBJ_SMP.RSC" ))							/* Resource laden */
			{
				init_rsrc();												/* initialisieren */

				if (( aes_flags & GAI_WDLG) == GAI_WDLG )
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
