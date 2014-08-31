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

int16	work_out[57];
int16	extnd_out[57];

/*----------------------------------------------------------------------------------------*/
/* Funktionen																										*/
/*----------------------------------------------------------------------------------------*/
int16	main( void );
int16	open_screen_wk( int16 aes_handle, int16 *work_out );

void	show_rgb_colors( int16 vdi_handle, int16 base_x, int16 base_y );
void	set_similar_color( int16 vdi_handle, int16 levels, COLOR_ENTRY *color );
void	rect_bg_demo( int16 vdi_handle, int16 base_x, int16 base_y );
void	text_rot_demo( int16 vdi_handle, int16 base_x, int16 base_y );

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

	work_in[0] = Getrez() + 2;											/* Auflîsung */
	work_in[10] = 2;														/* Rasterkoordinaten benutzen */
	handle = aes_handle;

	v_opnvwk( work_in, &handle, work_out );
	return( handle );
}


/*----------------------------------------------------------------------------------------*/
/* FarbwÅrfel aufspalten und anzeigen																		*/
/* Funktionsresultat:	-																						*/
/* vdi_handle:				VDI-Handle																			*/
/*	base_x:					x-Koordinate																		*/
/*	base_y:					y-Koordinate																		*/
/*----------------------------------------------------------------------------------------*/
void	show_rgb_colors( int16 vdi_handle, int16 base_x, int16 base_y )
{
																				/* 256 * 256 Pixel */
#define	RSTEP				(65535L/15)									/* 16 Schnitte entlang der Rot-Achse */
#define	GSTEP				(65535L/63)									/* 64 Schnitte entlang der Rot-Achse */
#define	BSTEP				(65535L/63)									/* 64 Schnitte entlang der Rot-Achse */
#define	RCUT				(16-4)										/* 12 bedeutungslose Rot-Bits */
#define	RROW				4												/* 4 VerlÑufe pro Reihe */
#define	RROWSHIFT		2
#define	RWIDTHSHIFT		6												/* Verlauf ist 2^6 Pixel breit */
#define	RHEIGHTSHIFT	6												/* Verlauf ist 2^6 Pixel hoch */

	uint32	r;
	uint32	g;
	uint32	b;
	
	vswr_mode( vdi_handle, 1 );										/* REPLACE */

	for ( r = 0; r <= 65535L;  r+= RSTEP )
	{
		COLOR_ENTRY	color;
		int16	xy[4];
		int16	 x;
		int16	 y;
		
		color.rgb.reserved = 0;
		color.rgb.red = r;

		x = base_x + ((( r >> RCUT ) & ( RROW - 1 )) << RWIDTHSHIFT );
		y = base_y + (( r >> ( RCUT+RROWSHIFT )) << RHEIGHTSHIFT );

		xy[0] = x;
		xy[2] = x;

		for ( g = 0; g <= 65535L; g += GSTEP )
		{
			color.rgb.green = g;

			xy[0]++;
			xy[2]++;

			xy[1] = y;
			xy[3] = y;

			for ( b = 0; b <= 65535L; b += BSTEP )
			{
				color.rgb.blue = b;
				vsl_fg_color( vdi_handle, CSPACE_RGB, &color );	/* Linienfarbe setzen */

				xy[1]++;
				xy[3]++;
		
				v_pline( vdi_handle, 2, xy );
			}
		}
	}
}


/*----------------------------------------------------------------------------------------*/
/* RGB-Farbe durch eingefÑrbtes monochromes Muster annÑhren											*/
/*	Hinweis:																											*/
/*	Diese Funktion ist nur ein Beispiel; sie erzeugt nur eine grobe AnnÑhrung der Farbe,	*/
/*	da sie nur mit einem monochromen Muster arbeitet. FÅr korrekte Darstellung mÅûte ein	*/
/*	farbiges Muster mit vr_transfer_bits() oder selber gedithert werden und anschlieûend 	*/
/*	mit vsf_udpat() eingestellt werden.																		*/
/* Funktionsresultat:	-																						*/
/* vdi_handle:				VDI-Handle																			*/
/*	levels:					Anzahl der Abstufungen pro Farbkanal										*/
/*	color:					gewÅnschte Farbe																	*/
/*----------------------------------------------------------------------------------------*/
void	set_similar_color( int16 vdi_handle, int16 levels, COLOR_ENTRY *color )
{
	if ( levels >= 16 )													/* mindestens 16 verfÅgbare Abstufungen pro Komponente? */
	{
		vsf_fg_color( vdi_handle, CSPACE_RGB, color );
		vsf_interior( vdi_handle, 1 );
	}
	else																		/* weniger als 16 verfÅgbare Abstufungen pro Komponente */
	{
		uint32	r;
		uint32	g;
		uint32	b;
		uint16	rpat_idx;
		uint16	gpat_idx;
		uint16	bpat_idx;
		uint16	pat_idx;
		uint16	step;

		step = 65535L / ( levels - 1 );								/* Schrittweite */
	
		r = color->rgb.red / ( step >> 3 );
		g = color->rgb.green / ( step >> 3 );
		b = color->rgb.blue / ( step >> 3 );
		
		rpat_idx = r & 7;													/* Musterindex */
		gpat_idx = g & 7;
		bpat_idx = b & 7;
		
		pat_idx = ( rpat_idx + gpat_idx + bpat_idx + 1 ) / 3;	/* kombinierten Index schÑtzen (eigentlich mÅûte man ein mehrfarbiges Muster mit 4 Farben erzeugen) */

		if ( pat_idx == 0 )												/* Vollfarbe? */
		{
			vsf_fg_color( vdi_handle, CSPACE_RGB, color );
			vsf_interior( vdi_handle, 1 );							/* vollflÑchiges Muster */
		}
		else
		{
			COLOR_ENTRY	fg_color;
			COLOR_ENTRY	bg_color;
	
			r = ( r >> 3 ) * step;
			g = ( g >> 3 ) * step;
			b = ( b >> 3 ) * step;
	
			fg_color.rgb.reserved = 0;
			fg_color.rgb.red = r;										/* fÅr den Vordergrund die dunklere Farbe auswÑhlen */
			fg_color.rgb.green = g;
			fg_color.rgb.blue = b;
	
			r += step;
			g += step;
			b += step;
	
			if ( r > 0xffffL )
				r = 0xffffL;
	
			if ( g > 0xffffL )
				g = 0xffffL;
	
			if ( b > 0xffffL )
				b = 0xffffL;
	
			bg_color.rgb.reserved = 0;
			bg_color.rgb.red = r;										/* fÅr den Hintergrund die nÑchsthellere Farbe auswÑhlen */
			bg_color.rgb.green = g;
			bg_color.rgb.blue = b;
		
			vsf_fg_color( vdi_handle, CSPACE_RGB, &fg_color );
			vsf_bg_color( vdi_handle, CSPACE_RGB, &bg_color );
			vsf_interior( vdi_handle, 2 );
			vsf_style( vdi_handle, 8 - pat_idx );					/* FÅllmuster zwischen 12,5 und 100 % auswÑhlen */
		}
	}
}

/*----------------------------------------------------------------------------------------*/
/* Mehrere VerlÑufe zeichnen																					*/
/* Funktionsresultat:	-																						*/
/* vdi_handle:				VDI-Handle																			*/
/*	base_x:					x-Koordinate																		*/
/*	base_y:					y-Koordinate																		*/
/*----------------------------------------------------------------------------------------*/
void	rect_bg_demo( int16 vdi_handle, int16 base_x, int16 base_y )
{
	COLOR_ENTRY	color;
	RECT16	rect;
	int16	levels;
	int16	i;

	if ( extnd_out[4] <= 4 )
		levels = 2;															/* maximal 2 Abstufungen */
	else if ( extnd_out[4] == 8 )
		levels = 6;															/* wahrscheinlich 6 Abstufunfen (FarbwÅrfel mit 6*6*6= 216 Farben) */
	else if ( extnd_out[4] <= 16 )
		levels = 32;														/* 5 oder 6 Bit pro Komponente */
	else
		levels = 256;														/* 8 Bit pro Komponente */
	
	vswr_mode( vdi_handle, 1 );										/* REPLACE */

	for ( i = 0; i <= 255; i++ )										/* Verlauf von Cyan nach Weiû */
	{
		color.rgb.reserved = 0;
		color.rgb.red = ( i << 8 ) + i;
		color.rgb.green = 0xffff;		
		color.rgb.blue = 0xffff;
		
		rect.x1 = base_x + 0;
		rect.x2 = base_x + 19;
		rect.y1 = base_y + i;
		rect.y2 = base_y + i;

		set_similar_color( vdi_handle, levels, &color );		/* Pseudo-Dither-Muster setzen */
		vr_recfl( vdi_handle, (int16 *) &rect );					/* Rechteck ausgeben */
	}

	for ( i = 0; i <= 255; i++ )										/* Verlauf von Magenta nach Weiû */
	{
		color.rgb.reserved = 0;
		color.rgb.red = 0xffff;
		color.rgb.green = ( i << 8 ) + i;		
		color.rgb.blue = 0xffff;
		
		rect.x1 = base_x + 20;
		rect.x2 = base_x + 39;
		rect.y1 = base_y + i;
		rect.y2 = base_y + i;

		set_similar_color( vdi_handle, levels, &color );		/* Pseudo-Dither-Muster setzen */
		vr_recfl( vdi_handle, (int16 *) &rect );					/* Rechteck ausgeben */
	}

	for ( i = 0; i <= 255; i++ )										/* Verlauf von Gelb nach Weiû */
	{
		color.rgb.reserved = 0;
		color.rgb.red = 0xffff;
		color.rgb.green = 0xffff;		
		color.rgb.blue = ( i << 8 ) + i;
		
		rect.x1 = base_x + 40;
		rect.x2 = base_x + 59;
		rect.y1 = base_y + i;
		rect.y2 = base_y + i;

		set_similar_color( vdi_handle, levels, &color );		/* Pseudo-Dither-Muster setzen */
		vr_recfl( vdi_handle, (int16 *) &rect );					/* Rechteck ausgeben */
	}

	for ( i = 0; i <= 255; i++ )										/* Verlauf von Rot nach Weiû */
	{
		color.rgb.reserved = 0;
		color.rgb.red = 0xffff;
		color.rgb.green = (i<<8) + i;		
		color.rgb.blue = (i<<8) + i;
		
		rect.x1 = base_x + 60;
		rect.x2 = base_x + 79;
		rect.y1 = base_y + i;
		rect.y2 = base_y + i;

		set_similar_color( vdi_handle, levels, &color );		/* Pseudo-Dither-Muster setzen */
		vr_recfl( vdi_handle, (int16 *) &rect );					/* Rechteck ausgeben */
	}

	for ( i = 0; i <= 255; i++ )										/* Verlauf von GrÅn nach Weiû */
	{
		color.rgb.reserved = 0;
		color.rgb.red = ( i << 8 ) + i;
		color.rgb.green = 0xffff;		
		color.rgb.blue = ( i << 8 ) + i;
		
		rect.x1 = base_x + 80;
		rect.x2 = base_x + 99;
		rect.y1 = base_y + i;
		rect.y2 = base_y + i;

		set_similar_color( vdi_handle, levels, &color );		/* Pseudo-Dither-Muster setzen */
		vr_recfl( vdi_handle, (int16 *) &rect );					/* Rechteck ausgeben */
	}
	
	for ( i = 0; i <= 255; i++ )										/* Verlauf von Blau nach Weiû */
	{
		color.rgb.reserved = 0;
		color.rgb.red = ( i << 8 ) + i;
		color.rgb.green = ( i << 8 ) + i;		
		color.rgb.blue = 0xffff;
		
		rect.x1 = base_x + 100;
		rect.x2 = base_x + 119;
		rect.y1 = base_y + i;
		rect.y2 = base_y + i;

		set_similar_color( vdi_handle, levels, &color );		/* Pseudo-Dither-Muster setzen */
		vr_recfl( vdi_handle, (int16 *) &rect );					/* Rechteck ausgeben */
	}
}

/*----------------------------------------------------------------------------------------*/
/* Textrotation mit verschiedenen Grautînen fÅr die Vordergrundfarbe								*/
/* Funktionsresultat:	-																						*/
/* vdi_handle:				VDI-Handle																			*/
/*	base_x:					x-Koordinate																		*/
/*	base_y:					y-Koordinate																		*/
/*----------------------------------------------------------------------------------------*/
void	text_rot_demo( int16 vdi_handle, int16 base_x, int16 base_y )
{
	int32	i;
	int16	d;

	vswr_mode( vdi_handle, 2 );										/* TRANSPARENT */
	vst_font( vdi_handle, 5031 );										/* Baskerville einstellen */
	vst_height( vdi_handle, 50, &d, &d, &d, &d );				/* 50 Pixel Hîhe */

	for ( i = 0; i < 3600; i += 100 )								/* in Schritten von 10 Grad rotieren */
	{
		COLOR_ENTRY	color;
		uint16	grey;
		
		vst_rotation( vdi_handle, 3600 - i );						/* Rotation setzen */

		grey = (uint16) ( i * 65535L / 3600 );
		color.rgb.reserved = 0;
		color.rgb.red = grey;
		color.rgb.green = grey;
		color.rgb.blue = grey;
		
		vst_fg_color( vdi_handle, CSPACE_RGB, &color );			/* RGB-Wert fÅr die Textfarbe setzen */
		v_ftext( vdi_handle, base_x, base_y, "SchînfÑrberei in Grau" );
	}
}

int16	main( void )
{
	app_id = appl_init();												/* AES initialisieren */

	if ( app_id >= 0 )
	{
		int16	aes_handle;
		int16	vdi_handle;
		int16	dummy;
		
		aes_handle = graf_handle( &dummy, &dummy, &dummy, &dummy );
		wind_update( BEG_UPDATE );										/* Bildschirm sperren */
		wind_update( BEG_MCTRL );										/* Maus- und Tastaturkontrolle holen */
		graf_mouse( M_OFF, 0L );										/* Maus ausschalten */

		vdi_handle = open_screen_wk( aes_handle, work_out );	/* VDI-Handle anfordern */

		if ( vdi_handle )
		{
			vq_extnd( vdi_handle, 1, extnd_out );					/* Informationen erfragen */
			
			if ( extnd_out[32] & 1 )									/* neue Farbfunktionen vorhanden? */
			{
				show_rgb_colors( vdi_handle, 100, 100 );			/* RGB-Diagramm */
				rect_bg_demo( vdi_handle, work_out[0] - 119, work_out[1] - 255 );
				text_rot_demo( vdi_handle, work_out[0] / 2, work_out[1] / 2 );	/* Textrotation mit Grautînen */
			}
			else
				Cconws( "Keine erweiterten Farbfunktionen vorhanden.\r\nTESTFGBG wird beendet.\r\n" );

			v_clsvwk( vdi_handle );
		}

		graf_mouse( M_ON, 0L );											/* Maus einschalten */
		wind_update( END_MCTRL );
		wind_update( END_UPDATE );

		appl_exit();
	}
	return( 0 );
}