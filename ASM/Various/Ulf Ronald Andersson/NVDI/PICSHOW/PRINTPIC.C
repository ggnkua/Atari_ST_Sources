/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>														/* ProzessorunabhÑngige Datentypen */
#include	<PORTAB.H>														/* KompatibilitÑt */
#include	<TOS.H>															/* GEMDOS-, Bios- und XBios-Funktionen */
#include	<RKIT.H>															/* Funktionsdefinitionen und Umlenkungen fÅr den Rasterkit */
#include <VDICOL.H>														/* Erweiterungen und Farbfunktionen */
#include	<MT_AES.H>														/* AES-Funktionen */

#include	<string.h>
#include	<stdlib.h>

#include "PIC_FN.H"														/* Funktionsdefinitionen der Bildschnittstelle */

#define	MAX( a, b ) (( a ) > ( b ) ? ( a ) : ( b ))
#define	MIN( a, b ) (( a ) < ( b ) ? ( a ) : ( b ))

/*----------------------------------------------------------------------------------------*/
/* globale Variablen																								*/
/*----------------------------------------------------------------------------------------*/
int16	app_id;
int16	aes_handle;
int8	home[128];

/*----------------------------------------------------------------------------------------*/
/* Funktionen																										*/
/*----------------------------------------------------------------------------------------*/
int16	main( int16 argc, int8 *argv[] );

/*----------------------------------------------------------------------------------------*/ 
/* interen Funktionsprototypen																				*/
/*----------------------------------------------------------------------------------------*/ 
/* Schnittfunktionen */
static int16	sect_rect16( RECT16 *src_a, RECT16 *src_b, RECT16 *dst );

/* Beispielfunktionen */
static int16	print_pic( IMG_REF *img_handle, PRN_SETTINGS *settings, int8 *file_name );

/*----------------------------------------------------------------------------------------*/ 
/* Zwei Rechtecke (mit diskreten Koordinaten) schneiden												*/
/* Funktionsresultat:	0: Rechtecke schneiden sich nicht 1: Rechtecke schneiden sich		*/
/*	src_a:					Rechteck a																			*/
/*	src_b:					Rechteck b																			*/
/*	dst:						Schnittrechteck																	*/
/*----------------------------------------------------------------------------------------*/ 
static int16	sect_rect16( RECT16 *src_a, RECT16 *src_b, RECT16 *dst )
{
	dst->x1 = MAX( src_a->x1, src_b->x1 );
	dst->y1 = MAX( src_a->y1, src_b->y1 );
	dst->x2 = MIN( src_a->x2, src_b->x2 );
	dst->y2 = MIN( src_a->y2, src_b->y2 );

	if (( dst->x1 <= dst->x2 ) && ( dst->y1 <= dst->y2 ))
		return( 1 );														/* Rechtecke schneiden sich */
	else
		return( 0 );														/* Rechtecke schneiden sich nicht */
}

extern PRN_SETTINGS	*read_psettings( PRN_DIALOG *prn_dialog );
extern int16	save_psettings( PRN_SETTINGS *settings );
extern int16	do_print_dialog( PRN_SETTINGS *settings, int8 *document_name, int16 kind );

/*----------------------------------------------------------------------------------------*/ 
/* Bild auf einem Drucker (in doppelter Grîûe) ausgeben												*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	img_handle:				Bildbeschreibung																	*/
/*	buf:						Bufferbeschreibung																*/
/*	settings:				Druckereinstellung																*/
/*----------------------------------------------------------------------------------------*/ 
static int16	print_pic( IMG_REF *img_handle, PRN_SETTINGS *settings, int8 *file_name )
{
	int16		work_out[57];
	int16		extnd_out[57];
	int16		prn_handle;
	
	prn_handle = v_opnprn( aes_handle, settings, work_out );	/* Drucker îffnen */
	
	if ( prn_handle )														/* lÑût sich der Druckertreiber îffnen? */
	{
		RECT16	device_rect;
		RECT16	dst_rect;
		RECT16	clip_rect;
		int32		width;
		int32		height;
		int32		bits;
		int8		*name;
		
		if ( RK_init( prn_handle ) == 0 )							/* Rasterkit fÅr den Drucker initialisieren */
		{
			v_clswk( prn_handle );
			return( 0 );													/* Fehler */
		}

		vs_document_info( prn_handle, 0, "PRINTME", 0 );		/* Applikationsname */
		
		name = strrchr( file_name, '\\' );
		if ( name )
			name++;
		else
			name = file_name;
		vs_document_info( prn_handle, 1, name, 0 );				/* Dokumentenname */

		device_rect.x1 = 0;
		device_rect.y1 = 0;
		device_rect.x2 = work_out[0];
		device_rect.y2 = work_out[1];

		vq_extnd( prn_handle, 1, extnd_out );
		/* extnd_out[30] & 2: Treiber hat TRANSFER BITMAP */
		/* extnd_out[30] & 1: Treiber kann skalieren (betrifft alte Treiber die kein vr_transfer_bits(), sondern nur vrt_cpyfm/vro_cpyfm() hatten) */
		/* extnd_out[32] & 1: Farbeinstellfunktionen vsX_fg_color()/vsX_bg_color() vorhanden */

		img_get_info( img_handle, &width, &height, &bits );	/* Bildausmaûe erfragen */
		dst_rect.x1 = 0;
		dst_rect.y1 = 0;
		dst_rect.x2 = ( width * 2 ) - 1;								/* doppelte Breite */
		dst_rect.y2 = ( height * 2 ) - 1;							/* doppelte Hîhe */

		clip_rect = dst_rect;											/* kein Clipping */
	
		if ( sect_rect16( &device_rect, &clip_rect, &clip_rect ))	/* ist das Clipping-Rechteck innerhalb der GerÑtebitmap? */
		{
			if ( img_show( img_handle,
			 					0L, &dst_rect, T_LOGIC_COPY | T_DITHER_MODE,
								&clip_rect, prn_handle ) == 0 )
				Cconws( "Nicht genÅgend Speicher fÅr TemporÑrbuffer vorhanden.\r\n" );
	
			v_updwk( prn_handle );										/* Seite ausgeben */
			v_clrwk( prn_handle );										/* Vorschub senden */
		}

		RK_reset( prn_handle );											/* Speicher fÅr Rasterkit freigeben */
		v_clswk( prn_handle );											/* Druckertreiber schlieûen */
	}
	else
	{
		Cconws( "Druckertreiber konnte nicht geîffnet werden.\r\n" );
		return( 0 );
	}

	return( 1 );
}

/*----------------------------------------------------------------------------------------*/
/* Voreinstellungen setzen, Header der COPS.inf einlesen												*/
/* Funktionsresultat:	-																						*/
/*----------------------------------------------------------------------------------------*/
void	std_settings( void )
{
	int8	*env;
	
	Pdomain( 1 );															/* verstehe lange Dateinamen */

	env = getenv( "HOME" );												/* Environment suchen */
	if ( env )
	{
		strcpy( home, env );
		if ( strlen( home ) > 0 )
		{
			if ( home[strlen( home ) - 1] != '\\' )
				strcat( home, "\\" );									/* Backslash anhÑngen */
		}
	}
	else																		/* aktuellen Pfad benutzen */
	{
		home[0] = Dgetdrv() + 'A';
		home[1] = ':';
		Dgetpath( home + 2, 0 );
		if ( home[strlen( home ) - 1] != '\\' )					/* kein Backslash am Ende? */
			strcat( home, "\\" );
	}
}

/*----------------------------------------------------------------------------------------*/
/* Speicherbereich anfordern (wird von FILEDIV.C aufgerufen)										*/
/* Funktionsresultat:	Zeiger auf den Speicherblock oder 0L										*/
/* length:					LÑnge des Blocks																	*/
/*----------------------------------------------------------------------------------------*/
void	*Malloc_sys( int32 length )
{
	if ( length )
		return( Malloc( length ));
	else
		return( 0L );
}

/*----------------------------------------------------------------------------------------*/
/* Speicherbereich freigeben (wird von FILEDIV.C aufgerufen)										*/
/* Funktionsresultat:	Zeiger auf den Speicherblock oder 0L										*/
/* length:					LÑnge des Blocks																	*/
/*----------------------------------------------------------------------------------------*/
int16	Mfree_sys( void *addr )
{
	return( Mfree( addr ));
}

int16 main( int16 argc, int8 *argv[] )
{
	PRN_SETTINGS	*psettings;

	app_id = appl_init();

	if( app_id != -1 )													/* Anmeldung erfolgreich? */
	{
		int16	dummy;

		aes_handle = graf_handle( &dummy, &dummy, &dummy, &dummy );
	
		std_settings();
		psettings = read_psettings( 0L );							/* Druckereinstellung laden  */
	
		if ( psettings )
		{
			int16	button;

			button = do_print_dialog( psettings, "", PDLG_PRINT );	/* Druckdialog aufrufen */
		
			if ( button == PDLG_OK )									/* Ausdruck starten? */
			{
				while ( argc > 1 )
				{
					void	*img_handle;

					argc--;

					img_handle = img_open( argv[argc] );
					
					if ( img_handle )										/* kann das Bild geladen werden? */
					{
						print_pic( img_handle, psettings, argv[argc] );	/* Bild ausdrucken */
							
						img_close( img_handle );						/* Bild schlieûen */
					}
					else
						Cconws( "Konnte Bilddatei nicht îffnen.\r\n" );
				}
			}		
			save_psettings( psettings );
		}
		else
			Cconws( "Druckereinstellung konnte nicht erstellt werden.\r\n" );

		appl_exit();
	}

   return( 0 );
}
