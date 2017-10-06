/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>
#include	<ColorMap.h>

#include	<stdlib.h>

/*----------------------------------------------------------------------------------------*/
/* externe Funktionen																							*/
/*----------------------------------------------------------------------------------------*/
extern void	*Malloc_sys( int32 length );
extern int16	Mfree_sys( void *addr );	

#define	MAX_COMPONENTS		4											/* maximale Anzahl von Farbkomponenten */

typedef struct
{
	int32	config;
	int16	xmax;
	COLOR_MAP	*color_map;
	INVERSE_CMAP	*inverse_cmap;
	int16	err_table[];
} DITHER_BLK;


int32	get_floyd_size( int16 xmax );
DITHER_BLK	*open_floyd( int16 xmax, int32 config, COLOR_MAP *color_map, INVERSE_CMAP *inverse_cmap );
void	init_floyd( DITHER_BLK *dither_blk );
int16	close_floyd( DITHER_BLK *dither_blk );

void	do_floyd( DITHER_BLK *dither_blk, int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
					 int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2 );
void	do_color_floyd_xrgb( int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
									int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2,
									int16 *err,	COLOR_ENTRY	*color_map, uint8	*inverse_map, int16 no_bits );
void	do_mono_floyd_xrgb( int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
								  int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2,
								  int16 *err,	COLOR_ENTRY	*color_map, uint8	*inverse_map, int16 no_bits );

/*----------------------------------------------------------------------------------------*/
/* Fehlerwerte beschrÑnken 																					*/
/*----------------------------------------------------------------------------------------*/
#define	limit_xrgb( red, green, blue ) \
{																														\
	if ( red < -255 )																								\
		red = -255;																									\
	if ( green < -255 )																							\
		green = -255;																								\
	if ( blue < -255 )																							\
		blue = -255;																								\
																														\
	if ( red > 255 )																								\
		red = 255;																									\
	if ( green > 255 )																							\
		green = 255;																								\
	if ( blue > 255 )																								\
		blue = 255;																									\
}	

/*----------------------------------------------------------------------------------------*/
/* Mapping fÅr inverse RGB-Farbpalette																		*/
/*----------------------------------------------------------------------------------------*/
#define	 remap_xrgb3( red, green, blue, index, color_map, inverse_map ) \
{																														\
	uint16	*color;																								\
																														\
	index = 0;																										\
																														\
	if ( red > 255 )																								\
		index += 0x00e0;																							\
	else if ( red >= 0 )																							\
		index += red & 0x00e0;																					\
																														\
	index <<= 1;																									\
																														\
	if ( green > 255 )																							\
		index += 0x0038;																							\
	else if ( green >= 0 )																						\
		index += ( green & 0x00e0 ) >> 2;																	\
																														\
	if ( blue > 255 )																								\
		index += 0x0007;																							\
	else if ( blue >= 0 )																						\
		index += blue >> 5;																						\
																														\
	index = inverse_map[index];										/* Pixelwert */					\
																														\
	color = &color_map[index].rgb.red;								/* Zeiger auf COLOR_ENTRY */	\
	red -= *color++ >> 8;												/* Fehlerwert fÅr Rot */		\
	green -= *color++ >> 8;												/* Fehlerwert fÅr GrÅn */		\
	blue -= *color++ >> 8;												/* Fehlerwert fÅr Blau */		\
}	

#define	remap_xrgb4( red, green, blue, index, color_map, inverse_map ) \
{																														\
	uint16	*color;																								\
																														\
	index = 0;																										\
																														\
	if ( red > 255 )																								\
		index += 0x00f0;																							\
	else if ( red >= 0 )																							\
		index += red & 0x00f0;																					\
																														\
	index <<= 4;																									\
																														\
	if ( green > 255 )																							\
		index += 0x00f0;																							\
	else if ( green >= 0 )																						\
		index += green & 0x00f0;																				\
																														\
	if ( blue > 255 )																								\
		index += 0x000f;																							\
	else if ( blue >= 0 )																						\
		index += blue >> 4;																						\
																														\
	index = inverse_map[index];										/* Pixelwert */					\
																														\
	color = &color_map[index].rgb.red;								/* Zeiger auf COLOR_ENTRY */	\
	red -= *color++ >> 8;												/* Fehlerwert fÅr Rot */		\
	green -= *color++ >> 8;												/* Fehlerwert fÅr GrÅn */		\
	blue -= *color++ >> 8;												/* Fehlerwert fÅr Blau */		\
}	

#define	remap_xrgb5( red, green, blue, index, color_map, inverse_map ) \
{																														\
	uint16	*color;																								\
																														\
	index = 0;																										\
																														\
	if ( red > 255 )																								\
		index += 0x00f8;																							\
	else if ( red >= 0 )																							\
		index += red & 0x00f8;																					\
																														\
	index <<= 5;																									\
																														\
	if ( green > 255 )																							\
		index += 0x00f8;																							\
	else if ( green >= 0 )																						\
		index += green & 0x00f8;																				\
																														\
	index <<= 2;																									\
																														\
	if ( blue > 255 )																								\
		index += 0x001f;																							\
	else if ( blue >= 0 )																						\
		index += blue >> 3;																						\
																														\
	index = inverse_map[index];										/* Pixelwert */					\
																														\
	color = &color_map[index].rgb.red;								/* Zeiger auf COLOR_ENTRY */	\
	red -= *color++ >> 8;												/* Fehlerwert fÅr Rot */		\
	green -= *color++ >> 8;												/* Fehlerwert fÅr GrÅn */		\
	blue -= *color++ >> 8;												/* Fehlerwert fÅr Blau */		\
}	

/*----------------------------------------------------------------------------------------*/
/* Grîûe des fÅr Floyd-Steinberg benîtigten Speichers berechnen									*/
/* Funktionsresultat:	Grîûe des fÅr Floyd-Steinberg benîtigten Speichers						*/
/*	xmax:						Breite - 1																			*/
/*----------------------------------------------------------------------------------------*/
int32	get_floyd_size( int16 xmax )
{
	int32	len;
	
	len = sizeof( DITHER_BLK );
	len += sizeof( int16 ) * MAX_COMPONENTS * ( xmax + 3 ) ;

	return( len );
}

/*----------------------------------------------------------------------------------------*/
/* Speicher fÅr Floyd-Steinberg anfordern																	*/
/* Funktionsresultat:	Zeiger auf Speicher oder 0L bei einem Fehler								*/
/*	xmax:						maximale Breite - 1																*/
/*----------------------------------------------------------------------------------------*/
DITHER_BLK	*open_floyd( int16 xmax, int32 config, COLOR_MAP *color_map, INVERSE_CMAP *inverse_cmap )
{
	DITHER_BLK	*dither_blk;

	dither_blk = Malloc_sys( get_floyd_size( xmax ));

	if ( dither_blk )
	{
		dither_blk->config = config;
		dither_blk->xmax = xmax;

		dither_blk->color_map = color_map;
		dither_blk->inverse_cmap = inverse_cmap;

		init_floyd( dither_blk );
	}	
	
	return( dither_blk );
}
	

/*----------------------------------------------------------------------------------------*/
/* Floyd-Steinberg initialisieren																			*/
/* Funktionsresultat:	0																						*/
/*	err:						Zeiger auf den Speicher fÅr die Fehlerberechnung						*/
/*	xmax:						Breite - 1																			*/
/*----------------------------------------------------------------------------------------*/
void	init_floyd( DITHER_BLK *dither_blk )
{
	if ( dither_blk )
	{
		int16	no_words;
		int16	*err;
		
		no_words = ( dither_blk->xmax + 3 ) * MAX_COMPONENTS;
		err = dither_blk->err_table;
		
		while ( no_words >= 0 )
		{
			*err++ = 0;
			no_words--;
		}
	}
}

/*----------------------------------------------------------------------------------------*/
/* Speicher fÅr Floyd-Steinberg freigeben																	*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	err:						Zeiger auf den Speicher fÅr die Fehlerberechnung						*/
/*----------------------------------------------------------------------------------------*/
int16	close_floyd( DITHER_BLK *dither_blk )
{
	if ( dither_blk )
	{
		Mfree_sys( dither_blk );
		return( 1 );
	}
	else
		return( 0 );
}

void	do_floyd( DITHER_BLK *dither_blk, int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
					 int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2 )
{
	if (( dst_x2 - dst_x1 ) > dither_blk->xmax )
		dst_x2 = dst_x1 + dither_blk->xmax;

	if ( dither_blk->color_map->no_colors >= 8 )
	{
		do_color_floyd_xrgb( src, buf, src_width, buf_width,
									dst_x1, dst_y1, dst_x2, dst_y2,
									dither_blk->err_table, dither_blk->color_map->colors,
									dither_blk->inverse_cmap->values, dither_blk->inverse_cmap->no_bits );
	}
	else
	{
		do_mono_floyd_xrgb( src, buf, src_width, buf_width,
								  dst_x1, dst_y1, dst_x2, dst_y2,
								  dither_blk->err_table, dither_blk->color_map->colors,
								  dither_blk->inverse_cmap->values, dither_blk->inverse_cmap->no_bits );
	}
}

/*----------------------------------------------------------------------------------------*/
/* Floyd-Steinberg, wandelt 32-Bit xRGB in 8 Bit pro Pixel											*/
/* Funktionsresultat:	-																						*/
/*	src:						Zeiger auf die Quellbitmap														*/
/*	buf:						Zielbuffer																			*/
/*	src_width:				Breite einer Quellzeile in Bytes												*/
/*	buf_width:				Breite einer Bufferzeile in Bytes											*/
/*	dst_x1, dst_y1,																								*/
/*	dst_x2, dst_x2:		Zielkoordinaten von vro_cpyfm()												*/
/*	err:						Zeiger auf den Speicher fÅr die Fehlerberechnung						*/
/*	color_map:				Zeiger auf die EintrÑge der Farbpalette									*/
/*	inverse_map:			Zeiger auf die EintrÑge der inversen Farbtabelle						*/
/*	no_bits:					Auflîsung von inverse_map														*/
/*																														*/
/*	Bemerkungen:																									*/
/*	-	fehlende DÑmpfungsfunktion kann zum Ausbluten fÅhren											*/
/*	-	keine Serpentine																							*/
/*	-	eine Zufallsfunktion kînnte die Bildung von unerwÅnschten Rastern und die deutliche	*/
/*		Stufenbildung bei VerlÑufen vermindern																*/
/*	-	es werden nur inverse Farbpaletten mit 3, 4 und 5 Bit unterstÅtzt, Tabellen mit		*/
/*		anderer Auflîsung als 2^no_bits kînnen nicht benutzt werden									*/
/*																														*/
/*----------------------------------------------------------------------------------------*/
void	do_color_floyd_xrgb( int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
									int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2,
									int16 *err,	COLOR_ENTRY	*color_map, uint8	*inverse_map, int16 no_bits )
{
	int16	xmax;
	int16	ymax;
	int16	x;
	
	int16	*err_red;
	int16	*err_green;
	int16	*err_blue;
	int16	index;

	int16	diff;

	int16	red;
	int16	green;
	int16	blue;
	
	xmax = dst_x2 - dst_x1;												/* Breite - 1 */
	ymax = dst_y2 - dst_y1;												/* Hîhe - 1 */
	src_width -= ( xmax + 1 ) * 4;									/* Abstand zur nÑchsten Quellzeile */
	buf_width -= ( xmax + 1 );											/* Abstand zur nÑchsten Zielzeile */

	err_red = err + 1;
	err_green = err_red + ( xmax + 3 );
	err_blue = err_green + ( xmax + 3 );

	while ( ymax >= 0 )
	{
		red = *err_red;													/* Fehlerwert aus der vorigen Zeile fÅr x = 0 */
		green = *err_green;
		blue = *err_green;

		*err_red = 0;														/* auf 0 setzen (wg. FehlerÅbertrag) */
		*err_green = 0;
		*err_blue = 0;

		for ( x = 0; x <= xmax; x++ )
		{
			red = ( red + 8 ) >> 4;
			green = ( green + 8 ) >> 4;
			blue = ( blue + 8 ) >> 4;
			
			limit_xrgb( red, green, blue );							/* Fehlerwert begrenzen */

			((uint8 *) src ) += 1;
			red += *((uint8 *) src )++;								/* Farbwert im Bereich -255 bis +510 */
			green += *((uint8 *) src )++;
			blue += *((uint8 *) src )++;

			switch ( no_bits )
			{
				case	3:	remap_xrgb3( red, green, blue, index, color_map, inverse_map ); break;
				case	4:	remap_xrgb4( red, green, blue, index, color_map, inverse_map ); break;
				case	5:	remap_xrgb5( red, green, blue, index, color_map, inverse_map ); break;
				default:	abort();
			}

			*buf++ = (uint8) index;

			diff = red;														/* Fehler bei Rot */
			*( err_red - 1 ) += diff * 3;								/* 3/16 auf das vorhergehende Pixel der nÑchsten Zeile Åbertragen */
			*err_red++ += diff * 5 ;									/* 5/16 auf das darunterliegende Pixel der nÑchsten Zeile Åbertragen */
			red = ( diff * 7 ) + *err_red;							/* 7/16 auf das folgende Pixel Åbertragen und Fehler aus der letzen Zeile addieren */
			*err_red = diff;												/* 1/16 auf das darauffolgende Pixel der nÑchsten Zeile Åbertragen */

			diff = green;													/* Fehler bei GrÅn */
			*( err_green - 1 ) += diff * 3;
			*err_green++ += diff * 5;
			green = ( diff * 7 ) + *err_green;
			*err_green = diff;

			diff = blue;													/* Fehler bei Blau */
			*( err_blue - 1 ) += diff * 3;
			*err_blue++ += diff * 5;
			blue = ( diff * 7 ) + *err_blue;
			*err_blue = diff;
		}
		
		err_red -= xmax + 1;
		err_green -= xmax + 1;
		err_blue -= xmax + 1;
		
		(uint8 *) src += src_width;									/* nÑchste Quellzeile */
		buf += buf_width;													/* nÑchste Bufferzeile */
		ymax--;		
	}
}

/*----------------------------------------------------------------------------------------*/
/* Floyd-Steinberg, wandelt 32-Bit xRGB in 8 Bit pro Pixel											*/
/* Funktionsresultat:	-																						*/
/*	src:						Zeiger auf die Quellbitmap														*/
/*	buf:						Zielbuffer																			*/
/*	src_width:				Breite einer Quellzeile in Bytes												*/
/*	buf_width:				Breite einer Bufferzeile in Bytes											*/
/*	dst_x1, dst_y1,																								*/
/*	dst_x2, dst_x2:		Zielkoordinaten von vro_cpyfm()												*/
/*	err:						Zeiger auf den Speicher fÅr die Fehlerberechnung						*/
/*	color_map:				Zeiger auf die EintrÑge der Farbpalette									*/
/*	inverse_map:			Zeiger auf die EintrÑge der inversen Farbtabelle						*/
/*	no_bits:					Auflîsung von inverse_map														*/
/*																														*/
/*	Bemerkungen:																									*/
/*	-	fehlende DÑmpfungsfunktion kann zum Ausbluten fÅhren											*/
/*	-	keine Serpentine																							*/
/*	-	eine Zufallsfunktion kînnte die Bildung von unerwÅnschten Rastern und die deutliche	*/
/*		Stufenbildung bei VerlÑufen vermindern																*/
/*	-	es werden nur inverse Farbpaletten mit 3, 4 und 5 Bit unterstÅtzt, Tabellen mit		*/
/*		anderer Auflîsung als 2^no_bits kînnen nicht benutzt werden									*/
/*																														*/
/*----------------------------------------------------------------------------------------*/
void	do_mono_floyd_xrgb( int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
								  int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2,
								  int16 *err,	COLOR_ENTRY	*color_map, uint8	*inverse_map, int16 no_bits )
{
	int16	xmax;
	int16	ymax;
	int16	x;
	
	int16	index;
	int16	diff;
	int16	grey;
	
	xmax = dst_x2 - dst_x1;												/* Breite - 1 */
	ymax = dst_y2 - dst_y1;												/* Hîhe - 1 */
	src_width -= ( xmax + 1 ) * 4;									/* Abstand zur nÑchsten Quellzeile */
	buf_width -= ( xmax + 1 );											/* Abstand zur nÑchsten Zielzeile */

	err++;																	/* links von x = 0 ein Wort Platz lassen */

	while ( ymax >= 0 )
	{
		grey = *err;														/* Fehlerwert aus der vorigen Zeile fÅr x = 0 */
		*err = 0;															/* auf 0 setzen (wg. FehlerÅbertrag) */

		for ( x = 0; x <= xmax; x++ )
		{
			uint16	tmp;
			int16		red;
			int16		green;
			int16		blue;

			grey = ( grey + 8 ) >> 4;

			if ( grey < -255 )											/* Fehlerbegrenzung */
				grey = -255;
			if ( grey > 255 )
				grey = 255;

			((uint8 *) src ) += 1;
			red = *((uint8 *) src )++;
			green = *((uint8 *) src )++;
			blue = *((uint8 *) src )++;

			tmp = red * 84;												/* Umwandlung in Grauwert nach CCIR 709 */
			tmp += green * 154;
			tmp += blue * 18;
			grey += tmp >> 8;

			if ( grey >= 128 )
			{
				*buf++ = 0;													/* weiûes Pixel setzen */
				grey -= 255;
			}
			else
			{
				*buf++ = 0xff;												/* schwarzes Pixel setzen */
			}


			diff = grey;
			*( err - 1 ) += diff * 3;									/* 3/16 auf das vorhergehende Pixel der nÑchsten Zeile Åbertragen */
			*err++ += diff * 5 ;											/* 5/16 auf das darunterliegende Pixel der nÑchsten Zeile Åbertragen */
			grey = ( diff * 7 ) + *err;								/* 7/16 auf das folgende Pixel Åbertragen und Fehler aus der letzen Zeile addieren */
			*err = diff;													/* 1/16 auf das darauffolgende Pixel der nÑchsten Zeile Åbertragen */
		}
		
		err -= xmax + 1;
		
		(uint8 *) src += src_width;									/* nÑchste Quellzeile */
		buf += buf_width;													/* nÑchste Bufferzeile */
		ymax--;		
	}
}

