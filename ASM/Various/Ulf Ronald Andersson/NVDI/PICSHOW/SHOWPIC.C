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

#include "PIC_FN.H"														/* Funktionsdefinitionen der Bildschnittstelle */

#define	MAX( a, b ) (( a ) > ( b ) ? ( a ) : ( b ))
#define	MIN( a, b ) (( a ) < ( b ) ? ( a ) : ( b ))

/*----------------------------------------------------------------------------------------*/
/* globale Variablen																								*/
/*----------------------------------------------------------------------------------------*/
int16	app_id;
int16	aes_handle;

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
static int16	blt_pic( IMG_REF *img_handle );
static void		show_pic( int8 *name );

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

/*----------------------------------------------------------------------------------------*/ 
/* Bild auf dem Bildschirm ausgeben																			*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	img_handle:				Bildbeschreibung																	*/
/*	buf:						Bufferbeschreibung																*/
/*----------------------------------------------------------------------------------------*/ 
static int16	blt_pic( IMG_REF *img_handle )
{
	int16		work_in[11];
	int16		work_out[57];
	int16		extnd_out[57];
	RECT16	device_rect;
	int16		vdi_handle;
	int16		i;
	
	for( i = 0; i < 10; i++ )
		work_in[i] = 1;

	work_in[10] = 2;
	
	vdi_handle = aes_handle;
	v_opnvwk( work_in, &vdi_handle, work_out );					/* virtuelle Workstation îffnen */
	
	device_rect.x1 = 0;
	device_rect.y1 = 0;
	device_rect.x2 = work_out[0];
	device_rect.y2 = work_out[1];
	
	if ( vdi_handle )														/* alles in Ordnung? */
	{
		RECT16	dst_rect;
		RECT16	clip_rect;
		int32		width;
		int32		height;
		int32		bits;

		vq_extnd( vdi_handle, 1, extnd_out );
		/* extnd_out[30] & 2: Treiber hat TRANSFER BITMAP */
		/* extnd_out[30] & 1: Treiber kann skalieren (betrifft alte Treiber die kein vr_transfer_bits(), sondern nur vrt_cpyfm/vro_cpyfm() hatten) */
		/* extnd_out[32] & 1: Farbeinstellfunktionen vsX_fg_color()/vsX_bg_color() vorhanden */

		img_get_info( img_handle, &width, &height, &bits );	/* Bildausmaûe erfragen */
		dst_rect.x1 = 0;
		dst_rect.y1 = 0;
		dst_rect.x2 = 0 + (( width  )  - 1 );
		dst_rect.y2 = (( height  ) - 1 );
	
		clip_rect = dst_rect;											/* kein Clipping */

		if ( sect_rect16( &device_rect, &clip_rect, &clip_rect ))	/* ist das Clipping-Rechteck innerhalb der GerÑtebitmap? */
		{
			int16	mode;

#if USE_BLENDING
			COLOR_ENTRY	weight_color = { 0x0000, 0x8000, 0x8000, 0x8000 };	/* Quelle 50 %, Ziel 50 % */
/*			COLOR_ENTRY	weight_color = { 0x0000, 0x0000, 0x0000, 0x0000 };	 Quelle 0 %, Ziel 100 % */
/*			COLOR_ENTRY	weight_color = { 0x0000, 0xffff, 0xffff, 0xffff };	 Quelle 100 %, Ziel 0 % */

			vs_weight_color( vdi_handle, CSPACE_RGB, &weight_color );	/* Vordergrundfarbe fÅr Bitmaps */
			mode = T_BLEND | T_DITHER_MODE;							/* Mischung von Quelle und Ziel */
#elif USE_ADD
			mode = T_ADD | T_DITHER_MODE;								/* Addition der Farbwerte */
#elif USE_SUB 
			mode = T_SUB | T_DITHER_MODE;								/* Subtraktion der Farbwerte */
#else
			mode = T_REPLACE | T_DITHER_MODE;						/* ersetzende Ausgabe */
#endif

			if ( img_show( img_handle, 0L, &dst_rect, mode,  &clip_rect, vdi_handle ) == 0 )	/* Bild ausgeben */
				Cconws( "Nicht genÅgend Speicher fÅr TemporÑrbuffer vorhanden.\r\n" );
		}
		v_clsvwk( vdi_handle );											/* WK schlieûen */
	}
	else
	{
		Cconws( "Virtuelle WK kann nicht geîffnet werden.\r\n" );
		return( 0 );
	}

	return( 1 );
}


/*----------------------------------------------------------------------------------------*/ 
/* Bild ausgeben																									*/
/* Funktionsresultat:	-																						*/
/*	name:						Dateiname																			*/
/*----------------------------------------------------------------------------------------*/ 
static void	display_pic( int8 *name )
{
	void	*img_handle;

	RK_init( get_base_handle());

	img_handle = img_open( name );
	
	if ( img_handle )														/* kann das Bild geladen werden? */
	{
		if ( blt_pic( img_handle ) == 0 )							/* auf dem Bildschirm anzeigen */
			Cconws( "Fehler bei der Anzeige\r\n" );
			
		img_close( img_handle );										/* Bild schlieûen */
	}
	else
		Cconws( "Konnte Bilddatei nicht îffnen.\r\n" );

	RK_reset( get_base_handle());
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

int16	main( int16 argc, int8 *argv[] )
{
	app_id = appl_init();												/* AES initialisieren */

	if ( app_id >= 0 )
	{
		int16	dummy;

		aes_handle = graf_handle( &dummy, &dummy, &dummy, &dummy );

		wind_update( BEG_UPDATE );										/* Bildschirm sperren */
		wind_update( BEG_MCTRL );										/* Maus- und Tastaturkontrolle holen */
		graf_mouse( M_OFF, 0L );										/* Maus ausschalten */

		while ( argc > 1 )
		{
			argc--;
			
			display_pic( argv[argc] );									/* Datei ausgeben */
	
		}

		graf_mouse( M_ON, 0L );											/* Maus einschalten */
		wind_update( END_MCTRL );
		wind_update( END_UPDATE );

		appl_exit();
	}
	return( 0 );
}
