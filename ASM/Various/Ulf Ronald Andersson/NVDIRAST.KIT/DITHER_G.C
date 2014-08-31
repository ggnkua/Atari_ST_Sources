/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.H>
#include	<ColorMap.h>

/*----------------------------------------------------------------------------------------*/
/* externe Funktionen																							*/
/*----------------------------------------------------------------------------------------*/
extern void	*Malloc_sys( int32 length );
extern int16	Mfree_sys( void *addr );	

/*----------------------------------------------------------------------------------------*/
/* 16 * 16 Ausgangsmatrix fÅr Ordered Dither 															*/
/*----------------------------------------------------------------------------------------*/
static uint8	base_matrix[16][16] =
{
	  0,192, 48,240, 12,204, 60,252,  3,195, 51,243, 15,207, 63,255,
	128, 64,176,112,140, 76,188,124,131, 67,179,115,143, 79,191,127,
	 32,224, 16,208, 44,236, 28,220, 35,227, 19,211, 47,239, 31,223,
	160, 96,144, 80,172,108,156, 92,163, 99,147, 83,175,111,159, 95,
	  8,200, 56,248,  4,196, 52,244, 11,203, 59,251,  7,199, 55,247,
	136, 72,184,120,132, 68,180,116,139, 75,187,123,135, 71,183,119,
	 40,232, 24,216, 36,228, 20,212, 43,235, 27,219, 39,231, 23,215,
	168,104,152, 88,164,100,148, 84,171,107,155, 91,167,103,151, 87,
	  2,194, 50,242, 14,206, 62,254,  1,193, 49,241, 13,205, 61,253,
	130, 66,178,114,142, 78,190,126,129, 65,177,113,141, 77,189,125,
	 34,226, 18,210, 46,238, 30,222, 33,225, 17,209, 45,237, 29,221,
	162, 98,146, 82,174,110,158, 94,161, 97,145, 81,173,109,157, 93,
	 10,202, 58,250,  6,198, 54,246,  9,201, 57,249,  5,197, 53,245,
	138, 74,186,122,134, 70,182,118,137, 73,185,121,133, 69,181,117,
	 42,234, 26,218, 38,230, 22,214, 41,233, 25,217, 37,229, 21,213,
	170,106,154, 90,166,102,150, 86,169,105,153, 89,165,101,149, 85
};

typedef struct
{
	int32	config;
	COLOR_MAP	*color_map;
	INVERSE_CMAP	*inverse_cmap;
	
	int16	matrix[16][16];
	int16	divN[256];
	int16	modN[256];
} DITHER_BLK;

DITHER_BLK	*open_dither( int32 config, COLOR_MAP *color_map, INVERSE_CMAP *inverse_cmap );
int16	close_dither( DITHER_BLK *dither_blk );
void	do_dither( DITHER_BLK *dither_blk, int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
					  int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2 );

void	do_color_dither_xrgb( int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
									 int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2,
									 int16 (*matrix)[16], int16 *divN, int16 *modN, uint8 *values, int16 levels );

void	do_mono_dither_xrgb( int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
									int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2,
									int16 (*matrix)[16], int16 *divN, int16 *modN, uint8 *values, int16 levels );

/*----------------------------------------------------------------------------------------*/
/* Ordered Dither initialisieren																				*/
/* Funktionsresultat:	Zeiger auf die Dithermatrix													*/
/*	levels:					Anzahl der Abstufungen (2 oder 6)											*/
/*----------------------------------------------------------------------------------------*/
DITHER_BLK	*open_dither( int32 config, COLOR_MAP *color_map, INVERSE_CMAP *inverse_cmap )
{
	DITHER_BLK	*dither_blk;

	dither_blk = Malloc_sys( sizeof( DITHER_BLK ));

	if ( dither_blk )
	{
		int16	(*matrix)[16];
		int16	*divN;
		int16	*modN;
		int16	levels;
		int16	i;
		int16	j;

		dither_blk->config = config;
		dither_blk->color_map = color_map;
		dither_blk->inverse_cmap = inverse_cmap;

		divN = dither_blk->divN;
		modN = dither_blk->modN;
		levels = inverse_cmap->levels;

		if ( color_map->no_colors >= 8 )
		{
			for ( i = 0, j = 0; i < 256; i++, j++ )					/* Tabellen fÅr div() und mod() aufbauen (wenn divN[i] = levels - 1  muû modN[i] = 0 sein) */		   {
				divN[i] = ( i * ( levels - 1 )) / 255;					/* Quotient */		
				if ( j && ( divN[i - 1] < divN[i] ))					/* Ñndert sich der Quotient? */
					j = 0;
		
				modN[i] = j;													/* Rest */
			}		
			matrix = dither_blk->matrix;
		
			for ( i = 0; i < 16; i++ )										/* Dithermaxtrix an die Anzahl der Abstufungen anpassen */
				for ( j = 0; j < 16; j++ )
					matrix[i][j] = base_matrix[i][j] / ( levels - 1 );
		}
		else
		{
			for ( i = 0, j = 0; i < 256; i++, j++ )					/* Tabellen fÅr div() und mod() aufbauen (wenn divN[i] = levels - 1  muû modN[i] = 0 sein) */			{
				divN[i] = 0;
				modN[i] = j;													/* Rest */
			}		
			matrix = dither_blk->matrix;
		
			for ( i = 0; i < 16; i++ )										/* Dithermaxtrix an die Anzahl der Abstufungen anpassen */
				for ( j = 0; j < 16; j++ )
					matrix[i][j] = base_matrix[i][j];
		}
	}

	return( dither_blk );
}

/*----------------------------------------------------------------------------------------*/
/* Dummy-Funktion																									*/
/* Funktionsresultat:	1																						*/
/*----------------------------------------------------------------------------------------*/
int16	close_dither( DITHER_BLK *dither_blk )
{
	if ( dither_blk )
	{
		Mfree_sys( dither_blk );
		return( 1 );
	}
	else
		return( 0 );
}

void	do_dither( DITHER_BLK *dither_blk, int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
					  int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2 )
{
	if ( dither_blk->color_map->no_colors >= 8 )
	{
		do_color_dither_xrgb( src, buf, src_width, buf_width,
									 dst_x1, dst_y1, dst_x2, dst_y2,
									 dither_blk->matrix, dither_blk->divN, dither_blk->modN,
									 dither_blk->inverse_cmap->values, dither_blk->inverse_cmap->levels );
	}
	else
	{
		do_mono_dither_xrgb( src, buf, src_width, buf_width,
									dst_x1, dst_y1, dst_x2, dst_y2,
									dither_blk->matrix, dither_blk->divN, dither_blk->modN,
									dither_blk->inverse_cmap->values, dither_blk->inverse_cmap->levels );
	}
}

/*----------------------------------------------------------------------------------------*/
/* Dither-Makro fÅr Farbausgabe																				*/
/*----------------------------------------------------------------------------------------*/
#define	DITHER( v ) ( modN[v] > matrix_value ? ( divN[v] + 1 ) : divN[v] )

/*----------------------------------------------------------------------------------------*/
/* Ordered Dither fÅr xRGB-Daten																				*/
/* Funktionsresultat:	-																						*/
/*	src:						Quelladresse																		*/
/*	buf:						Zielbuffer																			*/
/*	src_width:				Breite einer Quellzeile in Bytes												*/
/*	buf_width:				Breite einer Bufferzeile in Bytes											*/
/*	dst_x1, dst_y1,																								*/
/*	dst_x2, dst_x2:		Zielkoordinaten von vro_cpyfm()												*/
/*	matrix:					Dithermatrix (Zuordnung: matrix[y][x])										*/
/*	levels:					Anzahl der Abstufungen															*/
/*	values:					Wertefeld der inversen Farbpalette											*/
/*																														*/
/*																														*/
/*																														*/
/*	Bemerkungen:																									*/
/*	-	Das Zielrechteck (dst_??) wird benutzt, um die richtige Startposition in der			*/
/*		Dithermatrix zu bestimmen.																				*/
/*	-	Wenn mit einer festen Palette (6*6*6) und ohne inverse Farbpalette gearbeitet wird,	*/
/*		reicht es aus, values auf ein Feld uint8 level_to_pix[6][6][6] zeigen zu lassen,		*/
/*		das einen zum RGB-Index korrespondierenden Pixelwert liefert.								*/
/*	-	Substitution der Multiplikation mit levels und des Makros DITHER() durch Tabellen 	*/
/*		kînnte die Funktion erheblich beschleunigen.														*/
/*																														*/
/*----------------------------------------------------------------------------------------*/
void	do_color_dither_xrgb( int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
									 int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2,
									 int16 (*matrix)[16], int16 *divN, int16 *modN, uint8 *values, int16 levels )
{
 	int16	x;
 	int16	y;

	src_width -= ( dst_x2 - dst_x1 + 1 ) * 4;						/* Abstand zur nÑchsten Quellzeile */
	buf_width -= ( dst_x2 - dst_x1 + 1 );							/* Abstand zur nÑchsten Zielzeile */

	for ( y = dst_y1; y <= dst_y2; y++ )
	{
		int16	*row;

		row = matrix[y & 15];											/* Zeilenanfang der Dithermatrix */

		for ( x = dst_x1; x <= dst_x2; x++ )
		{
			int16	matrix_value;
			int16	index;
		 	int16	r;
		 	int16	g;
		 	int16	b;

			matrix_value = row[x & 15];								/* Wert der Dithermatrix an dieser Position */

			(uint8 *) src += 1;											/* erstes Byte Åberspringen */
			r = *((uint8 *) src )++;
			g = *((uint8 *) src )++;
			b = *((uint8 *) src )++;

			index = DITHER( r );											/* Index fÅr die inverse Farbpalette bilden ... */
			index *= levels;
			index += DITHER( g );
			index *= levels;
			index += DITHER( b );

			*buf++ = values[index];										/* Pixelwert auslesen und schreiben */
		}
	
		(uint8 *) src += src_width;									/* nÑchste Quellzeile */
		buf += buf_width;													/* nÑchste Bufferzeile */
	}
}

/*----------------------------------------------------------------------------------------*/
/* Dither-Makro fÅr Schwarzweiûausgabe																		*/
/*----------------------------------------------------------------------------------------*/
#define	MONO_DITHER( v ) ( v > matrix_value ? 0 : 255 )

/*----------------------------------------------------------------------------------------*/
/* Ordered Dither fÅr xRGB-Daten																				*/
/* Funktionsresultat:	-																						*/
/*	src:						Quelladresse																		*/
/*	buf:						Zielbuffer																			*/
/*	src_width:				Breite einer Quellzeile in Bytes												*/
/*	buf_width:				Breite einer Bufferzeile in Bytes											*/
/*	dst_x1, dst_y1,																								*/
/*	dst_x2, dst_x2:		Zielkoordinaten von vro_cpyfm()												*/
/*	matrix:					Dithermatrix (Zuordnung: matrix[y][x])										*/
/*	levels:					Anzahl der Abstufungen															*/
/*	values:					Wertefeld der inversen Farbpalette											*/
/*																														*/
/*																														*/
/*																														*/
/*	Bemerkungen:																									*/
/*	-	Das Zielrechteck (dst_??) wird benutzt, um die richtige Startposition in der			*/
/*		Dithermatrix zu bestimmen.																				*/
/*	-	Wenn mit einer festen Palette (6*6*6) und ohne inverse Farbpalette gearbeitet wird,	*/
/*		reicht es aus, values auf ein Feld uint8 level_to_pix[6][6][6] zeigen zu lassen,		*/
/*		das einen zum RGB-Index korrespondierenden Pixelwert liefert.								*/
/*	-	Substitution der Multiplikation mit levels und des Makros DITHER() durch Tabellen 	*/
/*		kînnte die Funktion erheblich beschleunigen.														*/
/*																														*/
/*----------------------------------------------------------------------------------------*/
void	do_mono_dither_xrgb( int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
									int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2,
									int16 (*matrix)[16], int16 *divN, int16 *modN, uint8 *values, int16 levels )
{
 	int16	x;
 	int16	y;

	src_width -= ( dst_x2 - dst_x1 + 1 ) * 4;						/* Abstand zur nÑchsten Quellzeile */
	buf_width -= ( dst_x2 - dst_x1 + 1 );							/* Abstand zur nÑchsten Zielzeile */

	for ( y = dst_y1; y <= dst_y2; y++ )
	{
		int16	*row;

		row = matrix[y & 15];											/* Zeilenanfang der Dithermatrix */

		for ( x = dst_x1; x <= dst_x2; x++ )
		{
			int16		matrix_value;
			int16		index;
		 	int16		r;
		 	int16		g;
		 	int16		b;
			uint16	grey;

			matrix_value = row[x & 15];								/* Wert der Dithermatrix an dieser Position */

			(uint8 *) src += 1;											/* erstes Byte Åberspringen */
			r = *((uint8 *) src )++;
			g = *((uint8 *) src )++;
			b = *((uint8 *) src )++;

			grey = r * 84;													/* Umwandlung in Grauwert nach CCIR 709 */
			grey += g * 154;
			grey += b * 18;
			grey >>= 8;

			*buf++ = MONO_DITHER( grey );
		}
	
		(uint8 *) src += src_width;									/* nÑchste Quellzeile */
		buf += buf_width;													/* nÑchste Bufferzeile */
	}
}
