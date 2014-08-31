/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>														/* Prozessorunabh„ngige Datentypen */
#include	<PORTAB.H>														/* Kompatibilit„t */
#include	<TOS.H>															/* GEMDOS-, Bios- und XBios-Funktionen */
#include <VDICOL.H>														/* Erweiterungen und Farbfunktionen */
#include	<MT_AES.H>														/* AES-Funktionen */

#include <string.h>

/*----------------------------------------------------------------------------------------*/
/* globale Variablen																								*/
/*----------------------------------------------------------------------------------------*/
int16	app_id;

/*----------------------------------------------------------------------------------------*/
/* Funktionen																										*/
/*----------------------------------------------------------------------------------------*/
int16	create_gcbitmap( int16 vdi_handle, GCBITMAP *bm, int32 flags,
							  int32 color_space, uint32 px_format, int32 width, int32 height );
int16	delete_gcbitmap( int16 vdi_handle, GCBITMAP *bm );
void	draw_background( int16 vdi_handle );
void	draw_strings( int16 vdi_handle );
void	how_to_transfer_bits( int16 vdi_handle );
int16 main( void );

/*----------------------------------------------------------------------------------------*/
/* Definitionen																									*/
/*----------------------------------------------------------------------------------------*/
#define SIZE 128															/* Gr”že der Rechtecke */

/* Flags fr create_gcbitmap */
#define	GCBITMAP_NOCLR	0x01											/* Bitmap nicht l”schen */
#define	GCBITMAP_CTAB	0x02											/* Farbtabelle anlegen */
#define	GCBITMAP_ITAB	0x04											/* inverse Farbtabelle anlegen */
#define	GCBITMAP_ILOW	0x08											/* niedrige Qualit„t reicht bei der inversen Farbtabelle aus */
#define	GCBITMAP_IHIGH	0x10											/* hohe Qualit„t reicht bei der inversen Farbtabelle aus */

/*----------------------------------------------------------------------------------------*/
/* Speicher fr Bitmap anfordern und GCBITMAP-Struktur ausfllen									*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	vdi_handle:				VDI-Handle																			*/
/*	bm:						Zeiger auf GCBITMAP-Strukur													*/
/*	flags:					siehe oben																			*/
/*	color_space:			Farbraum (CSPACE_RGB)															*/
/*	px_format:				Pixelformat oder 0 (von vdi_handle holen)									*/
/*	width:					Breite oder 0 (von vdi_handle holen)										*/
/*	height:					H”he oder 0 (von vdi_handle holen)											*/
/*----------------------------------------------------------------------------------------*/
int16	create_gcbitmap( int16 vdi_handle, GCBITMAP *bm, int32 flags,
							  int32 color_space, uint32 px_format, int32 width, int32 height )
{
	uint8	*addr;
	int32	byte_width;
	int32	bits;
	int32	length;

	if (( width == 0 ) || ( height == 0 ))							/* wurden keine Ausmaže bergeben? */
	{
		int16	extnd_out[57];
		
		vq_extnd( vdi_handle, 0, extnd_out );						/* Breite und H”he von handle bernehmen */
		width = extnd_out[0] + 1;
		height = extnd_out[0] + 1;
	}	

	if ( px_format == 0 )												/* wurde kein Pixelformat bergeben? */
		color_space = vq_px_format( vdi_handle, &px_format );

	width = ( width + 15 ) & ~15L;									/* Breite ist Vielfaches von 16 */

	bits = px_format & PX_BITS;										/* Bits pro Pixel */
	byte_width = ( bits * width ) >> 3;								/* Breite einer Zeile in Bytes */
	length = ( byte_width * height ) + 16 + 16;					/* L„nge des Speicherbereichs (+ 16 Bytes davor und dahinter) */
	addr = Malloc( length );											/* Speicher fr die Bitmap anfordern */

	if ( addr )
	{
		if (( flags & GCBITMAP_NOCLR ) == 0 )						/* Bitmap l”schen? */
		{
			if ( bits >= 16 )												/* direkte Farbwerte? */
				memset( addr, 255, length );
			else																/* Indizes */
				memset( addr, 0, length );
		}

		bm->magic = CBITMAP_MAGIC;										/* Kennung */
		bm->length = sizeof( GCBITMAP );								/* Strukturl„nge */
		bm->format = 0;													/* Format 0 */
		bm->reserved = 0;
	
		bm->addr = addr + 16;											/* Startadresse der Bitmap */
		bm->width = byte_width;											/* Breite einer Zeile in Bytes */
		bm->bits = bits;													/* Bits pro Pixel */
		bm->px_format = px_format;										/* Pixelformat */
	
		bm->xmin = 0;														/* Ursprung ist bei (0,0) */
		bm->ymin = 0;
		bm->xmax = width;
		bm->ymax = height;
	
		bm->ctab = 0L;
		bm->itab = 0L;
		bm->reserved0 = 0L;
		bm->reserved1 = 0L;
	
		if ( flags & GCBITMAP_CTAB )									/* Farbtabelle anlegen? */
		{
			bm->ctab = v_create_ctab( vdi_handle, color_space, px_format );
			if ( bm->ctab == 0 )											/* konnte die Farbtabelle nicht angelegt werden? */
			{
				delete_gcbitmap( vdi_handle, bm );
				return( 0 );
			}
		}

		if (( flags & GCBITMAP_ITAB ) && bm->ctab )	 			/* inverse Farbtabelle anlegen? */
		{
			int16	bits;
			
			bits = 4;
			if ( flags & GCBITMAP_ILOW )								/* reicht geringe Qualit„t aus? */
				bits = 3;
			if ( flags & GCBITMAP_IHIGH )								/* hohe Qualit„t? */
				bits = 5;

			bm->itab = v_create_itab( vdi_handle, bm->ctab, bits );
			if ( bm->itab == 0 )											/* konnte die inverse Farbtabelle nicht angelegt werden? */
			{
				delete_gcbitmap( vdi_handle, bm );
				return( 0 );
			}
		}
	}
	return( 1 );
}

/*----------------------------------------------------------------------------------------*/
/* Speicher fr Bitmap freigeben 																			*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	vdi_handle:				VDI-Handle																			*/
/*	bm:						Zeiger auf GCBITMAP-Strukur													*/
/*----------------------------------------------------------------------------------------*/
int16	delete_gcbitmap( int16 vdi_handle, GCBITMAP *bm )
{
	if ( bm )
	{
		if ( bm->itab )
		{
			v_delete_itab( vdi_handle, bm->itab );					/* Referenz auf inverse Farbtabelle freigeben */
			bm->itab = 0L;
		}

		if ( bm->ctab )
		{
			v_delete_ctab( vdi_handle, bm->ctab );					/* Speicher fr Farbtabelle freigeben */
			bm->ctab = 0L;
		}

		if ( bm->addr )
		{
			Mfree( bm->addr - 16 );										/* Speicher fr die Bitmap freigeben */
			bm->addr = 0L;
		}
		return( 1 );
	}
	
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/
/* Hintergrund fr die Ausgabe zeichnen																	*/
/* Funktionsresultat:	-																						*/
/*	vdi_handle:				VDI-Handle																			*/
/*----------------------------------------------------------------------------------------*/
void	draw_background( int16 vdi_handle )
{
	COLOR_ENTRY	white_color = { 0, 0xffff, 0xffff, 0xffff };
	COLOR_ENTRY	black_color = { 0, 0x0000, 0x0000, 0x0000 };
	RECT16	rect;

	vswr_mode( vdi_handle, 1 );										/* REPLACE */

	vsf_fg_color( vdi_handle, CSPACE_RGB, &white_color );		/* Weiž als Fllfarbe setzen */
	v_circle( vdi_handle, SIZE / 2, SIZE / 2, SIZE / 3 );		/* gefllten Kreis ausgeben */

	vsl_fg_color( vdi_handle, CSPACE_RGB, &black_color );		/* Schwarz als Linienfarbe setzen */
	v_arc( vdi_handle, SIZE / 2, SIZE / 2, SIZE / 4, 0, 3600 );	/* Kreisbogen ausgeben */

	rect.x1 = 0;
	rect.y1 = SIZE;
	rect.x2 = ( 5 * SIZE ) - 1;
	rect.y2 = ( 2 * SIZE ) + SIZE - 1;
	vsf_interior( vdi_handle, 2 );
	vsf_style( vdi_handle, 4 );										/* monochromes 50 % Graumuster */
	vsf_fg_color( vdi_handle, CSPACE_RGB, &black_color );		/* Schwarz als Fllfarbe setzen */
	vr_recfl( vdi_handle, (int16 *) &rect );
}

/*----------------------------------------------------------------------------------------*/
/* Beschriftung ausgeben																						*/
/* Funktionsresultat:	-																						*/
/*	vdi_handle:				VDI-Handle																			*/
/*----------------------------------------------------------------------------------------*/
void	draw_strings( int16 vdi_handle )
{
	COLOR_ENTRY	blue_color = { 0, 0x0000, 0x0000, 0xffff };
	COLOR_ENTRY	red_color = { 0, 0xffff, 0x0000, 0x0000 };
	COLOR_ENTRY	yellow_color = { 0, 0xffff, 0xffff, 0x0000 };
	int16	tmp;

	vswr_mode( vdi_handle, 1 );										/* REPLACE */
	vst_font( vdi_handle, 1 );											/* Systemfont einstellen */
	vst_height( vdi_handle, 13, &tmp, &tmp, &tmp, &tmp );		/* 13 Pixel H”he */
	vst_alignment( vdi_handle, 0, 5, &tmp, &tmp );				/* vertikale Ausrichtung an der Oberkante */
	vst_fg_color( vdi_handle, CSPACE_RGB, &blue_color );		/* Textvordergrundfarbe ist Blau */
	v_gtext( vdi_handle, 4 * SIZE, SIZE, 		"Bitmap mit 4 Bit" );
	v_gtext( vdi_handle, 4 * SIZE, SIZE + 16, "ber einem Grau-" );
	v_gtext( vdi_handle, 4 * SIZE, SIZE + 32, "muster verknpft" );

	v_gtext( vdi_handle, 4 * SIZE, 2 * SIZE, 		 "Bitmap mit 32Bit" );
	v_gtext( vdi_handle, 4 * SIZE, 2 * SIZE + 16, "mit Dithern ber" );
	v_gtext( vdi_handle, 4 * SIZE, 2 * SIZE + 32, "einem Graumuster" );
	v_gtext( vdi_handle, 4 * SIZE, 2 * SIZE + 48, "arithmetisch" );
	v_gtext( vdi_handle, 4 * SIZE, 2 * SIZE + 64, "verknpft" );

	vst_fg_color( vdi_handle, CSPACE_RGB, &red_color );		/* Textvordergrundfarbe ist Rot */
	vst_bg_color( vdi_handle, CSPACE_RGB, &yellow_color );	/* Texthintergrundfarbe ist Gelb */

	v_gtext( vdi_handle, 0 * SIZE, 1 * SIZE, "T_REPLACE" );
	v_gtext( vdi_handle, 1 * SIZE, 1 * SIZE, "T_TRANSPARENT" );
	v_gtext( vdi_handle, 2 * SIZE, 1 * SIZE, "T_HILITE" );
	v_gtext( vdi_handle, 3 * SIZE, 1 * SIZE, "T_REVTRANS" );

	v_gtext( vdi_handle, 0 * SIZE, 2 * SIZE, "T_BLEND" );
	v_gtext( vdi_handle, 1 * SIZE, 2 * SIZE, "T_ADD" );
	v_gtext( vdi_handle, 2 * SIZE, 2 * SIZE, "T_SUB" );
	v_gtext( vdi_handle, 3 * SIZE, 2 * SIZE, "T_MAX" );
}

/*----------------------------------------------------------------------------------------*/
/* Ausgaben mit vr_transfer_bits() in unterschiedlichen Bittiefen und Modi						*/
/* Funktionsresultat:	-																						*/
/*	vdi_handle:				VDI-Handle																			*/
/*----------------------------------------------------------------------------------------*/
void	how_to_transfer_bits( int16 vdi_handle )
{
	RECT16	src_rect;
	RECT16	bm_rect;
	RECT16	dst_rect;
	GCBITMAP bm;

/* Quellrechteck */
	src_rect.x1 = 0;
	src_rect.y1 = 0;
	src_rect.x2 = SIZE - 1;
	src_rect.y2 = SIZE - 1;

/* Bufferrechteck */
	bm_rect.x1 = 0;
	bm_rect.y1 = 0;
	bm_rect.x2 = SIZE - 1;
	bm_rect.y2 = SIZE - 1;

/* Zielrechteck */
	dst_rect.x1 = 0;
	dst_rect.y1 = SIZE;
	dst_rect.x2 = SIZE - 1;
	dst_rect.y2 = ( 2 * SIZE ) - 1;

/* Bitmap mit 4 Bit Farbtiefe anlegen */
	if ( create_gcbitmap( vdi_handle, &bm, GCBITMAP_CTAB | GCBITMAP_ITAB, CSPACE_RGB, PX_PREF4, SIZE, SIZE ))
	{
/* Auschnitt mit Dithern in die Bitmap kopieren */
		vr_transfer_bits( vdi_handle, 0L, &bm, (int16 *) &src_rect, (int16 *) &bm_rect, T_REPLACE | T_DITHER_MODE );

/* Bitmap nacheinander in den Modi T_REPLACE, T_TRANSPARENT, T_HILITE und T_REVERS_TRANSPARENT ausgeben */
		vr_transfer_bits( vdi_handle, &bm, 0L, (int16 *) &bm_rect, (int16 *) &dst_rect, T_REPLACE );

		dst_rect.x1 += SIZE;	dst_rect.x2 += SIZE;
		vr_transfer_bits( vdi_handle, &bm, 0L, (int16 *) &bm_rect, (int16 *) &dst_rect, T_TRANSPARENT );

		dst_rect.x1 += SIZE;	dst_rect.x2 += SIZE;
		vr_transfer_bits( vdi_handle, &bm, 0L, (int16 *) &bm_rect, (int16 *) &dst_rect, T_HILITE );

		dst_rect.x1 += SIZE;	dst_rect.x2 += SIZE;
		vr_transfer_bits( vdi_handle, &bm, 0L, (int16 *) &bm_rect, (int16 *) &dst_rect, T_REVERS_TRANSPARENT );

		delete_gcbitmap( vdi_handle, &bm );							/* Speicher fr die Bitmap freigeben */
	}

	dst_rect.x1 = 0;
	dst_rect.y1 = 2 * SIZE;
	dst_rect.x2 = SIZE - 1;
	dst_rect.y2 = ( 3 * SIZE ) - 1;

/* Bitmap mit 32 Bit Farbtiefe anlegen */
	if ( create_gcbitmap( vdi_handle, &bm, GCBITMAP_CTAB | GCBITMAP_ITAB, CSPACE_RGB, PX_PREF32, SIZE, SIZE ))
	{
/* Auschnitt in die Bitmap kopieren */
		vr_transfer_bits( vdi_handle, 0L, &bm, (int16 *) &src_rect, (int16 *) &bm_rect, T_REPLACE );

/* Bitmap nacheinander mit Dithern in den Modi T_BLEND, T_ADD, T_SUB und T_MAX ausgeben */
		vr_transfer_bits( vdi_handle, &bm, 0L, (int16 *) &bm_rect, (int16 *) &dst_rect, T_BLEND | T_DITHER_MODE );

		dst_rect.x1 += SIZE;	dst_rect.x2 += SIZE;
		vr_transfer_bits( vdi_handle, &bm, 0L, (int16 *) &bm_rect, (int16 *) &dst_rect, T_ADD | T_DITHER_MODE );

		dst_rect.x1 += SIZE;	dst_rect.x2 += SIZE;
		vr_transfer_bits( vdi_handle, &bm, 0L, (int16 *) &bm_rect, (int16 *) &dst_rect, T_SUB | T_DITHER_MODE );

		dst_rect.x1 += SIZE;	dst_rect.x2 += SIZE;
		vr_transfer_bits( vdi_handle, &bm, 0L, (int16 *) &bm_rect, (int16 *) &dst_rect, T_MAX | T_DITHER_MODE );

		delete_gcbitmap( vdi_handle, &bm );							/* Speicher fr die Bitmap freigeben */
	}
}

int16 main( void )
{
	int16	result;	

	result = -1;
	app_id = appl_init();												/* beim AES anmelden */

	if ( app_id >= 0 )
	{
		int16	work_in[11];
		int16	work_out[57];
		int16	vdi_handle;
		int16	tmp;
		int16 i;

		wind_update( BEG_UPDATE );										/* Bildschirm sperren */
		wind_update( BEG_MCTRL );										/* Maus- und Tastaturkontrolle holen */
		graf_mouse( M_OFF, 0L );										/* Maus ausschalten */

		vdi_handle = graf_handle( &tmp, &tmp, &tmp, &tmp );

		for(i = 0; i < 10; work_in[i++] = 1);
		work_in[10] = 2;

		v_opnvwk( work_in, &vdi_handle, work_out );				/* virtuelle Workstation ”ffnen */
	
		if ( vdi_handle )
		{
			result = 0;
			draw_background( vdi_handle );							/* Hintergrund zeichnen */
			how_to_transfer_bits( vdi_handle );						/* mit vr_transfer_bits() kopieren */
			draw_strings( vdi_handle );								/* Beschriftung der Ausgaben */
			v_clsvwk( vdi_handle );
		}

		graf_mouse( M_ON, 0L );											/* Maus einschalten */
		wind_update( END_MCTRL );
		wind_update( END_UPDATE );

		appl_exit();
	}
	return( result );
}
