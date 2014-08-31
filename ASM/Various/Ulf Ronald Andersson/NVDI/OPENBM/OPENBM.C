/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>														/* ProzessorunabhÑngige Datentypen */
#include	<PORTAB.H>														/* KompatibilitÑt */
#include	<TOS.H>															/* GEMDOS-, Bios- und XBios-Funktionen */
#include <VDICOL.H>														/* Erweiterungen und Farbfunktionen */
#include	<MT_AES.H>														/* AES-Funktionen */

/*----------------------------------------------------------------------------------------*/
/* globale Variablen																								*/
/*----------------------------------------------------------------------------------------*/
int16	app_id;
int16	aes_handle;

/*----------------------------------------------------------------------------------------*/
/* Funktionen																										*/
/*----------------------------------------------------------------------------------------*/
int16	main( void );
int16	open_screen_wk( int16 aes_handle, int16 *work_out );

void	init_gcbitmap( GCBITMAP *bm, uint8 *addr, uint32 px_format, int32 width, int32 height );
void	dont_share_colors( void );
void	share_colors( void );

/*----------------------------------------------------------------------------------------*/
/* Virtuelle Bildschirm-Workstation îffnen																*/
/* Funktionsresultat:	VDI-Handle oder 0 als Fehlernummer											*/
/* work_out:				GerÑteinformationen																*/
/*----------------------------------------------------------------------------------------*/
int16	open_screen_wk( int16 aes_handle, int16 *work_out )
{
	int16	work_in[11];
	int16	handle;
	int16	i;

	for( i = 1; i < 10; i++ )
		work_in[i] = 1;

	work_in[0] = Getrez() + 2;											/* KompatibilitÑt */
	work_in[10] = 2;														/* Rasterkoordinaten benutzen */
	handle = aes_handle;

	v_opnvwk( work_in, &handle, work_out );
	return( handle );
}

/*----------------------------------------------------------------------------------------*/
/* GCBITMAP-Struktur ohne Farbtabelle initialisieren													*/
/* Funktionsresultat:	-																						*/
/*	bm:						Zeiger auf die Struktur															*/
/*	addr:						Zeiger auf Speicherbereich oder 0L											*/
/*	px_format:				Pixelformat																			*/
/*	width:					Breite in Pixeln																	*/
/*	height:					Hîhe in Pixeln																		*/
/*----------------------------------------------------------------------------------------*/
void	init_gcbitmap( GCBITMAP *bm, uint8 *addr, uint32 px_format, int32 width, int32 height )
{
	bm->magic = CBITMAP_MAGIC;											/* Kennung */
	bm->length = sizeof( GCBITMAP );									/* StrukturlÑnge */
	bm->format = 0;														/* Format 0 */
	bm->reserved = 0;

	if ( addr )																/* Speicherbereich Åbergeben? */
	{
		bm->addr = addr;
		bm->width = ( width * ( px_format & PX_BITS )) >> 3;	/* Zeilenbreite in Bytes */
	}
	else
	{	
		bm->addr = 0;
		bm->width = 0;
	}

	bm->bits = px_format & PX_BITS;
	bm->px_format = px_format;

	bm->xmin = 0;
	bm->ymin = 0;
	bm->xmax = width;
	bm->ymax = height;

	bm->ctab = 0L;
	bm->itab = 0L;
	bm->reserved0 = 0L;
	bm->reserved1 = 0L;
}

/*----------------------------------------------------------------------------------------*/
/* Offscreen-Bitmap mit eigener Farbtabelle erzeugen.													*/
/* Dadurch beeinflussen FarbverÑnderungen auf dem Bildschirm nicht die Ausgabe der Bitmap,*/
/* da vr_transfer_bits() bei unterschiedlichen Farbtabellen ggf. umrechnet.					*/
/* Funktionsresultat:	-																						*/
/*----------------------------------------------------------------------------------------*/
void	dont_share_colors( void )
{
	int16	screen_out[57];
	int16	screen_handle;

	wind_update( BEG_UPDATE );											/* Bildschirm sperren */
	wind_update( BEG_MCTRL );											/* Maus- und Tastaturkontrolle holen */

	screen_handle = open_screen_wk( aes_handle, screen_out );	/* VDI-Handle anfordern */

	if ( screen_handle )
	{
		GRECT		size;
		GCBITMAP	bm;
		int16		bm_handle;

		size.g_x = 0;
		size.g_x = 0;
		size.g_w = screen_out[0] + 1;
		size.g_h = screen_out[1] + 1;
		form_dial( FMD_START, &size, &size );						/* das ist nicht die feine Art ... */

/* GCBITMAP initialisieren; Ausmaûe auf 0, damit beim v_open_bm() die */
/* Werte von <screen_handle> Åbernommen werden */
		init_gcbitmap( &bm, 0, 0, 0, 0 );						

/* Bitmap mit Bildschirmausmaûen und gleicher Pixelgrîûe anlegen */
/* Die Bitmap hat eine eigene Farbtabelle! */
		bm_handle = v_open_bm( screen_handle, &bm, 0, 0, 0, 0 );

		if ( bm_handle )													/* wurde die Bitmap angelegt? */
		{
			COLOR_ENTRY	blue_color = { 0, 0x0000, 0x0000, 0xffff };
			COLOR_ENTRY	save_color;
			int32	save_color_space;
			int16	ctab_idx;
			RECT16	rect;
			
/* Rotes Rechteck auf dem Schirm zeichnen */
			rect.x1 = 50;			
			rect.y1 = 50;			
			rect.x2 = 100;			
			rect.y2 = 100;			
			vsf_color( screen_handle, 2 );							/* VDI-Farbe 2: Rot */
			vsf_interior( screen_handle, 1 );						/* vollflÑchig */
			vr_recfl( screen_handle, (int16 *) &rect );			/* gefÅlltes Rechteck auf dem Schirm zeichnen */

			v_gtext( screen_handle, 0, 32, "Rotes Rechteck ausgegeben. Bitte Taste drÅcken." );
			evnt_keybd();
			
/* Roten Kreis in der Bitmap zeichnen */
			vsf_color( bm_handle, 2 );									/* VDI-Farbe 2: Rot */
			vsf_interior( bm_handle, 1 );								/* vollflÑchig */
			v_circle( bm_handle, 200, 200, 100 );					/* gefÅllten Kreis in der Bitmap zeichnen */

/* gesamte Bitmap Transparent auf den Bildschirm kopieren */
			rect.x1 = 0;
			rect.y1 = 0;
			rect.x2 = screen_out[0];
			rect.y2 = screen_out[1];

			vr_transfer_bits( screen_handle,
									&bm, 0,
									(int16 *) &rect, (int16 *) &rect,
									T_TRANSPARENT );

/* Meldung ausgeben und auf Tastendruck warten */
			v_gtext( screen_handle, 0, 32, "Die Bitmap wurde transparent ausgegeben. Bitte Taste drÅcken." );
			evnt_keybd();													/* Auf Tastendruck warten */

/* Farbe auf dem Bildschirm verstellen */
			ctab_idx = v_ctab_vdi2idx( screen_handle, 2 );		/* Farbtabellenindex von Rot erfragen (entspricht bis 256 Farben dem Pixelwert) */
			save_color_space = vq_ctab_entry( screen_handle, ctab_idx, &save_color );	/* Farbwert erfragen */
			vs_ctab_entry( screen_handle, ctab_idx, CSPACE_RGB, &blue_color );	/* Eintrag auf Blau setzen; bei bis zu 256 Farben wird die Farbe in der CLUT geÑndert */

/* Meldung ausgeben und auf Tastendruck warten */
			v_gtext( screen_handle, 0, 32, "Der Farbeintrag von Rot wurde auf Blau umgestellt. Bitte Taste drÅcken." );
			evnt_keybd();

/* Bitmap nochmals ausgeben; die Farben werden konvertiert und der Kreis bleibt Rot */
			vr_transfer_bits( screen_handle,
									&bm, 0,
									(int16 *) &rect, (int16 *) &rect,
									T_TRANSPARENT );

/* Meldung ausgeben und auf Tastendruck warten */
			v_gtext( screen_handle, 0, 32, "Die Bitmap wurde nochmals ausgegeben; die Farbe ist wieder Rot. Bitte Taste drÅcken." );
			evnt_keybd();

/* Farbeintrag wieder zurÅcksetzen */
			vs_ctab_entry( screen_handle, ctab_idx, save_color_space, &save_color );

/* Meldung ausgeben und auf Tastendruck warten */
			v_gtext( screen_handle, 0, 32, "Der Farbeintrag wurde wieder auf Rot zurÅckgestellt. Bitte Taste drÅcken." );
			evnt_keybd();

			v_close_bm( bm_handle );									/* Bitmap freigeben */
		}

		form_dial( FMD_FINISH, &size, &size );						/* freigeben */
		v_clsvwk( screen_handle );
	}
	wind_update( END_MCTRL );
	wind_update( END_UPDATE );
}

/*----------------------------------------------------------------------------------------*/
/* Offscreen-Bitmap erzeugen, die ihre Farbtabelle mit dem Bildschirm teilt.					*/
/* Dadurch haben Zeichenoperationen in Bildschirm und Bitmap immer das gleiche Ergebnis,	*/
/*	weil identische Farbwerte immer durch identische Pixelwerte reprÑsentiert werden.		*/
/* Funktionsresultat:	-																						*/
/*----------------------------------------------------------------------------------------*/
void	share_colors( void )
{
	int16	screen_out[57];
	int16	screen_handle;

	wind_update( BEG_UPDATE );											/* Bildschirm sperren */
	wind_update( BEG_MCTRL );											/* Maus- und Tastaturkontrolle holen */

	screen_handle = open_screen_wk( aes_handle, screen_out );	/* VDI-Handle anfordern */

	if ( screen_handle )
	{
		GRECT		size;
		GCBITMAP	bm;
		int16		bm_handle;

		size.g_x = 0;
		size.g_x = 0;
		size.g_w = screen_out[0] + 1;
		size.g_h = screen_out[1] + 1;
		form_dial( FMD_START, &size, &size );						/* das ist nicht die feine Art ... */

/* GCBITMAP initialisieren; Ausmaûe auf 0, damit beim v_open_bm() die */
/* Werte von <screen_handle> Åbernommen werden */
		init_gcbitmap( &bm, 0, 0, 0, 0 );						

/* Bitmap mit Bildschirmausmaûen und gleicher Pixelgrîûe anlegen */
/* Die Farbtabelle wird mit <screen_handle> geteilt! */
		bm_handle = v_open_bm( screen_handle, &bm, 1, 0, 0, 0 );

		if ( bm_handle )													/* wurde die Bitmap angelegt? */
		{
			COLOR_ENTRY	blue_color = { 0, 0x0000, 0x0000, 0xffff };
			COLOR_ENTRY	save_color;
			int32	save_color_space;
			int16	ctab_idx;
			RECT16	rect;

/* Rotes Rechteck auf dem Schirm zeichnen */
			rect.x1 = 50;			
			rect.y1 = 50;			
			rect.x2 = 100;			
			rect.y2 = 100;			
			vsf_color( screen_handle, 2 );							/* VDI-Farbe 2: Rot */
			vsf_interior( screen_handle, 1 );						/* vollflÑchig */
			vr_recfl( screen_handle, (int16 *) &rect );			/* gefÅlltes Rechteck auf dem Schirm zeichnen */

			v_gtext( screen_handle, 0, 32, "Rotes Rechteck ausgegeben. Bitte Taste drÅcken." );
			evnt_keybd();

/* Roten Kreis in der Bitmap zeichnen */
			vsf_color( bm_handle, 2 );									/* VDI-Farbe 2: Rot */
			vsf_interior( bm_handle, 1 );								/* vollflÑchig */
			v_circle( bm_handle, 200, 200, 100 );					/* gefÅllten Kreis in der Bitmap zeichnen */

/* gesamte Bitmap Transparent auf den Bildschirm kopieren */
			rect.x1 = 0;
			rect.y1 = 0;
			rect.x2 = screen_out[0];
			rect.y2 = screen_out[1];

			vr_transfer_bits( screen_handle,
									&bm, 0,
									(int16 *) &rect, (int16 *) &rect,
									T_TRANSPARENT );

/* Meldung ausgeben und auf Tastendruck warten */
			v_gtext( screen_handle, 0, 32, "Die Bitmap wurde transparent ausgegeben. Bitte Taste drÅcken." );
			evnt_keybd();

/* Farbe auf dem Bildschirm verstellen */
			ctab_idx = v_ctab_vdi2idx( screen_handle, 2 );		/* Farbtabellenindex von Rot erfragen (entspricht bis 256 Farben dem Pixelwert) */
			save_color_space = vq_ctab_entry( screen_handle, ctab_idx, &save_color );	/* Farbwert erfragen */
			vs_ctab_entry( screen_handle, ctab_idx, CSPACE_RGB, &blue_color );	/* Eintrag auf Blau setzen; bei bis zu 256 Farben wird die Farbe in der CLUT geÑndert */

			v_gtext( screen_handle, 0, 32, "Der Farbeintrag von Rot wurde auf Blau umgestellt. Bitte Taste drÅcken." );
			evnt_keybd();

/* Bitmap nochmals ausgeben; da eine gemeinsame Farbtabelle benutzt wird, bleibt der Kreis blau */
			vr_transfer_bits( screen_handle,
									&bm, 0,
									(int16 *) &rect, (int16 *) &rect,
									T_TRANSPARENT );

/* Meldung ausgeben und auf Tastendruck warten */
			v_gtext( screen_handle, 0, 32, "Die Bitmap wurde nochmals ausgegeben; die Farbe ist Blau. Bitte Taste drÅcken." );
			evnt_keybd();

/* Farbeintrag wieder zurÅcksetzen */
			vs_ctab_entry( screen_handle, ctab_idx, save_color_space, &save_color );

/* Meldung ausgeben und auf Tastendruck warten */
			v_gtext( screen_handle, 0, 32, "Der Farbeintrag wurde wieder auf Rot zurÅckgestellt. Bitte Taste drÅcken." );
			evnt_keybd();

			v_close_bm( bm_handle );									/* Bitmap freigeben */
		}
	
		form_dial( FMD_FINISH, &size, &size );						/* freigeben */
		v_clsvwk( screen_handle );
	}
	wind_update( END_MCTRL );
	wind_update( END_UPDATE );
}

/*----------------------------------------------------------------------------------------*/
/* Beispielprogramm fÅr Offscreen-Bitmaps																	*/
/*----------------------------------------------------------------------------------------*/
int16	main( void )
{
	app_id = appl_init();												/* AES initialisieren */

	if ( app_id >= 0 )
	{
		int16	dummy;
		
		aes_handle = graf_handle( &dummy, &dummy, &dummy, &dummy );
		graf_mouse( M_OFF, 0L );										/* Maus ausschalten */

		share_colors();													/* in Bitmap zeichnen, gemeinsame Farbtabelle mit dem Bildschirm nutzen */
		evnt_timer( 500 );												/* kurz warten, damit das AES hoffentlich genÅgend Zeit fÅr einen Redraw hat */
		dont_share_colors();												/* in Bitmap zeichnen, eigene Farbtabelle benutzen */

		graf_mouse( M_ON, 0L );											/* Maus einschalten */
		appl_exit();
	}
	return( 0 );
}