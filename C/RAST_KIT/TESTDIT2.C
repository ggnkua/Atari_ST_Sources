/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>
#include <PORTAB.H>
#include	<TOS.H>
#include <VDI.H>
#include	<MT_AES.H>

#include <stdio.h>

#include	<ColorMap.h>
#include	<CBitmap.h>

/*----------------------------------------------------------------------------------------*/
/* Ordered Dither																									*/
/*----------------------------------------------------------------------------------------*/
#define	USE_FLOYD	1													/* 0: Ordered Dither 1: Floyd Steinberg */
#define	USE_DEFAULT_COLORS	0										/* 0: Palette Åbernehemen 1: Palette setzen */
#define	DITHER_SINGLE_LINES	0										/* 0: komplettes Bild dithern und danach ausgeben;
																						das Quellbild wird zerstîrt
																					1: jede Zeile dithern und sofort ausgeben;
																						das Quellbild wird nicht verÑndert */

/*----------------------------------------------------------------------------------------*/
/* globale Variablen																								*/
/*----------------------------------------------------------------------------------------*/
int16	app_id;

int16	work_out[57];
int16	extnd_out[57];
int32	dst_format;															/* Pixelformat der Zielbitmap */

/*----------------------------------------------------------------------------------------*/
/* Ordered Dither																									*/
/*----------------------------------------------------------------------------------------*/
extern void	*open_dither( int32 config, COLOR_MAP *color_map, INVERSE_CMAP *inverse_cmap );
extern int16	close_dither( void *dither_blk );

extern void	do_dither( void *dither_blk, int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
							  int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2 );

/*----------------------------------------------------------------------------------------*/
/* Floyd-Steinberg																								*/
/*----------------------------------------------------------------------------------------*/
extern void	*open_floyd( int16 xmax, int32 config, COLOR_MAP *color_map, INVERSE_CMAP *inverse_cmap );
extern void	init_floyd( void *dither_blk );
extern int16	close_floyd( void *dither_blk );

extern void	do_floyd( void *dither_blk, int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
							 int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2 );

/*----------------------------------------------------------------------------------------*/
/* Funktionen fÅr Formatumwandlung																			*/
/*----------------------------------------------------------------------------------------*/
extern void	init_transform8( void );
extern int16	transform8( int32 dx, int32 dy, int32 dst_format, void *src, void *dst, int32 src_width, int32 dst_width );
extern int16	transform32( int32 dx, int32 dy, int32 dst_format, void *src, void *dst, int32 src_width, int32 dst_width );

/*----------------------------------------------------------------------------------------*/
/* Funktionen fÅr die Verwaltung der Farbpalette														*/
/*----------------------------------------------------------------------------------------*/
extern int16	default_colors( int16 vdi_handle, COLOR_RGB *gslct );
extern int32	_get_device_format( int16 vdi_handle );
extern COLOR_MAP	*_create_cmap( int16 vdi_handle );
extern int16	_delete_cmap( COLOR_MAP *cmap );
extern INVERSE_CMAP	*_create_inverse_cmap( COLOR_MAP *cmap, int16 no_bits, int16 levels );
extern int16	_delete_inverse_cmap( INVERSE_CMAP *inverse_cmap );

/*----------------------------------------------------------------------------------------*/
/* Bild laden																										*/
/*----------------------------------------------------------------------------------------*/
int32	read_file( int8 *name, uint8 *dest, int32 offset, int32 len );
int32	*load_esm( int8 *name, int16 *xmax, int16 *ymax );

/*----------------------------------------------------------------------------------------*/
/* Speicher																											*/
/*----------------------------------------------------------------------------------------*/
void	*Malloc_sys( int32 length );
int16	Mfree_sys( void *addr );

/*----------------------------------------------------------------------------------------*/
/* Datei laden																										*/
/* Der Speicher fÅr die Datei wird mit Malloc angefordert											*/
/* Funktionsresultat:	Zeiger auf die Datei oder 0L (Fehler)										*/
/* name:						absoluter Pfad mit Dateinamen													*/
/* length:					Zeiger auf Langwort fÅr die DateilÑnge										*/
/*----------------------------------------------------------------------------------------*/
int32	*load_esm( int8 *name, int16 *xmax, int16 *ymax )
{
	#define	LF_FLAGS	FA_READONLY + FA_HIDDEN + FA_SYSTEM + FA_ARCHIVE	/* Flags fÅr Fsfirst() */

	DTA	*old_dta;
	DTA	dta;
	void	*addr;

	old_dta = Fgetdta();								/* Adresse der bisherigen DTA */
	Fsetdta( &dta );									/* neue DTA setzen */

	addr = 0L;
	
	if ( Fsfirst( name, LF_FLAGS ) == 0 )		/* Datei vorhanden ?					*/
	{
		int32	read;
		int32	len;
		int16	header_size;
		int16	width;
		int16	width16;
		int16	height;
		
		read_file( name, (uint8 *) &header_size, 4, sizeof( int16 ));
		read_file( name, (uint8 *) &width, 6, sizeof( int16 ));
		read_file( name, (uint8 *) &height, 8, sizeof( int16 ));
		
		width16 = ( width + 15 ) & 0xfff0;
		len = (int32) width16 * (int32) height * sizeof( int32 );
		read = dta.d_length - header_size;
				
		if (( addr = Malloc_sys( len )) != 0 )		/* Speicher anfordern	*/	
		{
			if  ( read != read_file( name, addr, header_size, read ))	/* Datei unvollstÑndig?	*/
			{
				Mfree_sys( addr );
				addr = 0L;
			}
			else
			{
				uint8 *src;
				int32	*dst;
				int16	x;
				int16	y;
				
				src = (uint8 *) addr + ((int32) width * (int32) height * 3 );
				dst = (int32 *) addr + ((int32) width16 * (int32) height );
				
				for ( y = 0; y < height; y++ )
				{
					for ( x = width; x < width16; x++ )
						*( --dst ) = 0x00ffffffL;

					for ( x = 0; x < width; x++ )
					{	
						int32	pixel;
						
						pixel = *( --src );
						pixel += ((int32) *( --src )) << 8;
						pixel += ((int32) *( --src )) << 16;

						*( --dst ) = pixel;
					}
				}
			}
			
			*xmax = width16 - 1;
			*ymax = height - 1;
		}
	}
	Fsetdta( old_dta );								/* alte DTA setzen */

	return( addr );									/* Adresse zurÅckgeben				*/
}

/*----------------------------------------------------------------------------------------*/
/* Dateiabschnitt Datei laden																					*/
/* Funktionsresultat:	LÑnge der eingelesenen Daten													*/
/* name:						Name der Datei																		*/
/*	dest:						Zieladresse der Daten															*/
/*	offset:					Abstand vom Anfang der Datei													*/
/*	len:						LÑnge der einzulesenden Daten													*/
/*----------------------------------------------------------------------------------------*/
int32	read_file( int8 *name, uint8 *dest, int32 offset, int32 len )
{
	int32	handle;
	int32	read;
	
	read = 0;
	handle = Fopen( name, FO_READ );				/* Datei îffnen				*/
	if (	handle > 0 )								/* alles ok?	*/
	{
		Fseek( offset, (int16) handle, 0 );		/* Position relativ zum Dateianfang	*/
		read = Fread((int16) handle, len, dest );	/* Daten einlesen	*/
		Fclose((int16) handle );						/* Datei schlieûen	*/
	}

	return( read );									/* Anzahl der eingelesenen Bytes	*/
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
/* Workstation îffnen, Farbpalette und inverse Farbpalette erzeugen								*/
/* Funktionsresultat:	VDI-Handle oder 0 als Fehlernummer											*/
/*	aes_handle:				VDI-Handle des AES																*/
/*	cmap:						Farbpalette																			*/
/*	inverse_cmap:			inverse Farbpalette																*/
/*----------------------------------------------------------------------------------------*/
int16	init( int16 aes_handle, COLOR_MAP **cmap, INVERSE_CMAP **inverse_cmap )
{
	int16	vdi_handle;

	*cmap = 0L;
	*inverse_cmap = 0L;
	vdi_handle = open_screen_wk( aes_handle, work_out );

	if ( vdi_handle > 0 )
	{
#if USE_DEFAULT_COLORS
		default_colors( vdi_handle, 0L );
#endif

		vq_extnd( vdi_handle, 1, extnd_out );
		init_transform8();
		dst_format = _get_device_format( vdi_handle );			/* Pixelformat des Bildschirms */

		if (( dst_format & PX_BITS ) <= 8 )
		{
			*cmap = _create_cmap( vdi_handle );
	
			if ( *cmap )
			{
				int16	bits;
				int16	levels;

	#if USE_FLOYD
				if (( dst_format & PX_BITS ) == 8 )					/* 256 Farben? */
					bits = 4;
				else															/* 8 oder 16 Farben */
					bits = 3;												/* mehr Bits wÑren Verschwendung */

				levels = 1 << bits;
	#else
				if ( (*cmap)->no_colors == 16 )						/* 16 Farben? */
				{
					int16	i;
					
					for ( i = 7; i <= 14; i++ )						/* die hinteren 8 Systemfarben sollen beim Dithern nicht beachtet werden */
					{
						(*cmap)->colors[i].rgb.red = 65535L;
						(*cmap)->colors[i].rgb.green = 65535L;
						(*cmap)->colors[i].rgb.blue = 65535L;
						(*cmap)->colors[i].rgb.reserved = 0;
					}
				}

				if (( dst_format & PX_BITS ) == 8 )					/* 256 Farben? */
				{
					bits = 3;
					levels = 6;												/* mit 216 Farben dithern */
				}
				else
				{
					bits = 1;
					levels = 2;												/* mit 8 Farben dithern */
				}
	#endif
				*inverse_cmap = _create_inverse_cmap( *cmap, bits, levels );
				
				if ( *inverse_cmap == 0L )
				{
					_delete_cmap( *cmap );
					*cmap = 0L;

					v_clsvwk( vdi_handle );
					vdi_handle = 0;
				}
			}
		}
	}
	
	return( vdi_handle );
}

/*----------------------------------------------------------------------------------------*/
/* Farbpalette und inverse Farbpalette freigeben, Workstation schlieûen							*/
/* Funktionsresultat:	1																						*/
/*	vdi_handle:				VDI-Handle																			*/
/*	cmap:						Farbpalette																			*/
/*	inverse_cmap:			inverse Farbpalette																*/
/*----------------------------------------------------------------------------------------*/
int16	reset( int16 vdi_handle, COLOR_MAP *cmap, INVERSE_CMAP *inverse_cmap )
{
	if ( cmap )
		_delete_cmap( cmap );
	if ( inverse_cmap )	
		_delete_inverse_cmap( inverse_cmap );

	v_clsvwk( vdi_handle );

	return( 1 );
}

#if DITHER_SINGLE_LINES == 0

/*----------------------------------------------------------------------------------------*/
/* 32 Bit xRGB-Bild anzeigen, komplettes Bild dithern und danach ausgeben						*/
/* Das Bild im Quellbuffer wird zerstîrt (der Buffer wird u.a. fÅrs Dithern benutzt).		*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	xrgb_image:				Zeiger auf xRGB-Bild																*/
/*	xmax:						Breite in Pixeln (Vielfaches von 16) -1									*/
/*	ymax:						Hîhe in Zeilen - 1																*/
/*	vdi_handle:				VDI-Handle																			*/
/*	cmap:						Farbpalette																			*/
/*	inverse_cmap:			inverse Farbpalette																*/
/*----------------------------------------------------------------------------------------*/
int16	show_image( int32 *xrgb_image, int16 xmax, int16 ymax, int16 vdi_handle, COLOR_MAP *cmap, INVERSE_CMAP *inverse_cmap  )
{
	void	*dither_blk;
	MFDB	src;
	MFDB	screen;
	int32	src_width;
	int32	dst_width;
	int16	xy[8];

	src.fd_addr = (void *) xrgb_image;
	src.fd_w = ( xmax + 16 ) & 0xfff0;
	src.fd_h = ymax + 1;
	src.fd_wdwidth = src.fd_w / 16;
	src.fd_stand = 0;
	src.fd_nplanes = dst_format & PX_BITS;

	screen.fd_addr = 0L;

	xy[0] = 0;																/* Quellkoordinaten des Buffers */
	xy[1] = 0;
	xy[2] = xmax;
	xy[3] = ymax;
	xy[4] = 0;																/* Zielkoordinaten */
	xy[5] = 0;
	xy[6] = xmax;
	xy[7] = ymax;

	src_width =  ( xmax + 1 ) * 4;									/* Breite einer Quellzeile in Bytes */
	dst_width =  (( xmax + 1 ) * ( dst_format & PX_BITS )) / 8;	/* Breite einer Zielzeile in Bytes */

	if (( dst_format & PX_BITS ) <= 8 )								/* Dithern nîtig? */
	{
		uint8	*buf;
		int32	buf_width;
						
		buf = (uint8 *) xrgb_image;									/* Die Quellbitmap als Zielbuffer benutzen */
		buf_width = xmax + 1;											/* Breite einer Bufferzeile in Bytes */

#if USE_FLOYD
		dither_blk = open_floyd( xmax, 0, cmap, inverse_cmap );	/* Speicher anfordern */

		if ( dither_blk )
		{
			do_floyd( dither_blk, xrgb_image, buf, src_width, buf_width, xy[4], xy[5], xy[6], xy[7] );
			close_floyd( dither_blk );
		}
		else
			return( 0 );
#else
		dither_blk = open_dither( 0, cmap, inverse_cmap );		/* Speicher anfordern */

		if ( dither_blk )
		{
			do_dither( dither_blk, xrgb_image, buf, src_width, buf_width, xy[4], xy[5], xy[6], xy[7] );
			close_dither( dither_blk );
		}		
		else
			return( 0 );
#endif

		transform8( xmax, ymax, dst_format, buf, buf, buf_width, dst_width );	/* Pixelformat wandeln */
	}
	else																		/* Direct Color, ggf. Bits kappen */
		transform32( xmax, ymax, dst_format, xrgb_image, xrgb_image, src_width, dst_width );
	
	
	vs_clip( vdi_handle, 1, xy );										/* Clipping-Rechteck setzen */
	vro_cpyfm( vdi_handle, 3, xy, &src, &screen );				/* Buffer auf den Schirm kopieren */

	return( 1 );
}

#else

/*----------------------------------------------------------------------------------------*/
/* 32 Bit xRGB-Bild anzeigen, zeilenweise dithern, transformieren und ausgeben				*/
/* Das Bild im Quellbuffer wird nicht zerstîrt.															*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	xrgb_image:				Zeiger auf xRGB-Bild																*/
/*	xmax:						Breite in Pixeln (Vielfaches von 16) -1									*/
/*	ymax:						Hîhe in Zeilen - 1																*/
/*	vdi_handle:				VDI-Handle																			*/
/*	cmap:						Farbpalette																			*/
/*	inverse_cmap:			inverse Farbpalette																*/
/*----------------------------------------------------------------------------------------*/
int16	show_image( int32 *xrgb_image, int16 xmax, int16 ymax, int16 vdi_handle, COLOR_MAP *cmap, INVERSE_CMAP *inverse_cmap  )
{
	void	*dither_blk;
	MFDB	src;
	MFDB	screen;
	int32	image_width;
	int32	dither_buf_width;
	uint8	*dither_buf;
	int32	transform_buf_width;
	uint8	*transform_buf;
	int16	xy[8];

	xy[0] = 0;																/* Clipping-Rechteck */
	xy[1] = 0;
	xy[2] = xmax;
	xy[3] = ymax;
	vs_clip( vdi_handle, 1, xy );										/* Clipping-Rechteck setzen */

	dither_buf_width = ( xmax + 16 ) & 0xfff0;
	dither_buf = Malloc_sys( dither_buf_width );					/* Buffer fÅr das Dithern */

	if ( dither_buf == 0L )
		return( 0 );

	transform_buf_width = (( xmax + 16 ) & 0xfff0 ) * ( dst_format & PX_BITS ) / 8;
	transform_buf = Malloc_sys( transform_buf_width );			/* Buffer fÅr das Transformieren */
		
	if ( transform_buf == 0L )
	{
		Mfree_sys( dither_buf );
		return( 0 );
	}

	src.fd_addr = (void *) transform_buf;
	src.fd_w = ( xmax + 16 ) & 0xfff0;
	src.fd_h = 1;
	src.fd_wdwidth = src.fd_w / 16;
	src.fd_stand = 0;
	src.fd_nplanes = dst_format & PX_BITS;

	screen.fd_addr = 0L;

	image_width =  ( xmax + 1 ) * 4;									/* Breite einer Quellzeile in Bytes */

	if (( dst_format & PX_BITS ) <= 8 )								/* Dithern nîtig? */
	{
#if USE_FLOYD
		dither_blk = open_floyd( xmax, 0, cmap, inverse_cmap );	/* Speicher anfordern */

		if ( dither_blk )
		{
			int16	y;

			xy[0] = 0;
			xy[1] = 0;
			xy[2] = xmax;
			xy[3] = 0;

			xy[4] = 0;
			xy[5] = 0;
			xy[6] = xmax;
			xy[7] = 0;

			for ( y = 0; y <= ymax; y++ )
			{
				do_floyd( dither_blk, xrgb_image, dither_buf, image_width, dither_buf_width, xy[4], xy[5], xy[6], xy[7] );
				transform8( xmax, 0, dst_format, dither_buf, transform_buf, dither_buf_width, transform_buf_width );	/* Pixelformat wandeln */
				vro_cpyfm( vdi_handle, 3, xy, &src, &screen );	/* Zeile auf den Schirm kopieren */

				(uint8 *) xrgb_image += image_width;				/* nÑchste Quellzeile */

				xy[5]++;
				xy[7]++;
			}
			
			close_floyd( dither_blk );
		}
		else
			return( 0 );
#else
		dither_blk = open_dither( 0, cmap, inverse_cmap );		/* Speicher anfordern */

		if ( dither_blk )
		{
			int16	y;

			xy[0] = 0;
			xy[1] = 0;
			xy[2] = xmax;
			xy[3] = 0;

			xy[4] = 0;
			xy[5] = 0;
			xy[6] = xmax;
			xy[7] = 0;

			for ( y = 0; y <= ymax; y++ )
			{
				do_dither( dither_blk, xrgb_image, dither_buf, image_width, dither_buf_width, xy[4], xy[5], xy[6], xy[7] );
				transform8( xmax, 0, dst_format, dither_buf, transform_buf, dither_buf_width, transform_buf_width );	/* Pixelformat wandeln */
				vro_cpyfm( vdi_handle, 3, xy, &src, &screen );	/* Zeile auf den Schirm kopieren */

				(uint8 *) xrgb_image += image_width;				/* nÑchste Quellzeile */

				xy[5]++;
				xy[7]++;
			}
			close_dither( dither_blk );
		}		
		else
			return( 0 );
#endif
	}
	else																		/* Direct Color, ggf. Bits kappen */
	{
		int16	y;

		xy[0] = 0;
		xy[1] = 0;
		xy[2] = xmax;
		xy[3] = 0;

		xy[4] = 0;
		xy[5] = 0;
		xy[6] = xmax;
		xy[7] = 0;

		for ( y = 0; y <= ymax; y++ )
		{
			transform32( xmax, 0, dst_format, xrgb_image, transform_buf, image_width, transform_buf_width );
			vro_cpyfm( vdi_handle, 3, xy, &src, &screen );		/* Zeile auf den Schirm kopieren */

			(uint8 *) xrgb_image += image_width;					/* nÑchste Quellzeile */

			xy[5]++;
			xy[7]++;
		}
	}		

	Mfree_sys( transform_buf );										/* Buffer fÅr Transformation freigeben */
	Mfree_sys( dither_buf );											/* Buffer fÅrs Dithern freigeben */

	return( 1 );
}

#endif


int16	main( int16 argc, int8 *argv[] )
{
	app_id = appl_init();

	if ( app_id >= 0 )
	{
		COLOR_MAP	*cmap;
		INVERSE_CMAP	*inverse_cmap;
		int16	vdi_handle;

		int16	aes_handle;
		int16	pwchar;
		int16	phchar;
		int16	pwbox;
		int16	phbox;
		
		aes_handle = graf_handle( &pwchar, &phchar, &pwbox, &phbox );
		vdi_handle = init( aes_handle, &cmap, &inverse_cmap );

		if ( vdi_handle )
		{
			while ( argc > 1 )
			{
				int32	*esm;
				int16	xmax;
				int16	ymax;
				argc--;
		
				esm = load_esm( argv[argc], &xmax, &ymax );
	
				if ( esm )
				{
					if ( show_image( esm, xmax, ymax, vdi_handle, cmap, inverse_cmap ) == 0 )
						Cconws( "Fehler beim Anzeigen\r\n" );
				
					Mfree_sys( esm );
				}
				else
					Cconws( "Fehler beim Laden des ESM-Bilds\r\n" );
			}
			reset( vdi_handle, cmap, inverse_cmap );
		}
		else
			Cconws( "Fehler bei der Initialisierung\r\n" );
	
		appl_exit();
	}
	
	return( 0 );
}