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

#include "PIC.H"
#include	"ESM_FN.H"
#include	"IMG_FN.H"

#define	ABS( a )	(( a ) < 0 ? -( a ) : ( a ))
#define	MAX( a, b ) (( a ) > ( b ) ? ( a ) : ( b ))
#define	MIN( a, b ) (( a ) < ( b ) ? ( a ) : ( b ))

#define	MAX_BUF_SIZE	( 16L * 1024L * 1024L )					/* maximal 16 MB anfordern */
#define	RESERVE_FOR_DRIVER	( 512L * 1024L )					/* minimal 512 KB freilassen */

int32	pref_px_format[32] =												/* bevorzugte Pixelformate */
{
	PX_PREF1,
	PX_PREF2,
	0,
	PX_PREF4,
	0, 0, 0,
	PX_PREF8,
	0, 0, 0,  0, 0, 0, 0,
	PX_PREF15,
	0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0,
	PX_PREF32
};

/*----------------------------------------------------------------------------------------*/ 
/* interen Funktionsprototypen																				*/
/*----------------------------------------------------------------------------------------*/ 
static int16	open_buffer( IMG_REF *pic, PIC_BUFFER *buf );	/* Buffer anfordern */
static int16	close_buffer( PIC_BUFFER *buf );					/* Buffer freigeben */

static int16	get_base_handle( void );
static int16	img_identify( int8 *name, IMG_REF *pic );

/*----------------------------------------------------------------------------------------*/ 
/* Bild îffnen																										*/
/* Funktionsresultat:	Zeiger auf Bildbeschreibung oder 0L											*/
/* name:						absoluter Pfad mit Dateinamen													*/
/*----------------------------------------------------------------------------------------*/ 
IMG_REF	*img_open( int8 *name )
{
	IMG_REF	*pic;
	int16		aes_handle;

	aes_handle = get_base_handle();

	pic = Malloc( sizeof( IMG_REF ));
	
	if ( pic )
	{
		pic->max_buffer_size = MAX_BUF_SIZE;
		pic->min_reserve_size = RESERVE_FOR_DRIVER;
		pic->buffer.addr = 0L;											/* kein Buffer angefordert */

		if ( img_identify( name, pic ))								/* kann der Bildtyp geladen werden? */
		{
			if ( pic->img_open( name, pic, aes_handle ))			/* lÑût sich die Datei îffnen? */
				return( pic );
		}
		Mfree( pic );
	}
	
	return( 0L );
}

/*----------------------------------------------------------------------------------------*/ 
/* Bild schlieûen																									*/
/* Funktionsresultat:	1																						*/
/*	pic:						Zeiger auf Bildbeschreibung													*/
/*----------------------------------------------------------------------------------------*/ 
int16	img_close( IMG_REF *pic )
{
	if (	pic->buffer.addr )											/*  Buffer angefordert? */
		close_buffer( &pic->buffer );

	pic->img_close( pic );												/* Datei schlieûen, Buffer freigeben */
	Mfree( pic );
	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Bildausmaûe zurÅckliefern																					*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	pic:						Bildbeschreibung																	*/
/*	width:					Breite in Pixeln																	*/
/*	height:					Hîhe in Pixeln																		*/
/*	bits:						Bits pro Pixel																		*/
/*----------------------------------------------------------------------------------------*/ 
int16	img_get_info( IMG_REF *pic, int32 *width, int32 *height, int32 *bits )
{
	*width = pic->width;													/* Breite des Bilds in Pixeln */
	*height = pic->height;												/* Hîhe des Bilds in Zeilen */
	*bits = pic->planes;													/* Bits pro Pixel */
	return( 1 );
}

int16	img_needs_dither( IMG_REF *pic, int16 vdi_handle )
{
	COLOR_TAB	*ctab;
	COLOR_ENTRY	*color;
	int32	max_difference;
	int32	min_colors;
	int32	no_similar_colors;
	int32	no_colors;

	if ( pic->planes > 8 )												/* Bild mit mehr als 256 Farben? */
		return( 1 );														/* dann muû gedithert werden */

	ctab = (COLOR_TAB *) &pic->ctab;
	color = ctab->colors;
	no_similar_colors = 0;

	if ( ctab->no_colors <= 16 )
	{
		max_difference = 65535L * 15 / 100;							/* maximal 15 Prozent Schwankung */
		min_colors = ctab->no_colors;									/* fÅr jede Farbe muû ein Ñhnlicher Eintrag vorhanden sein */
	}
	else
	{
		max_difference = 65535L * 1 / 100;							/* maximal 1 Prozent Schwankung */
		min_colors = 216;													/* 6 * 6 * 6 Farben */
	}
	
	no_colors = ctab->no_colors;

	while ( no_colors > 0 )
	{
		COLOR_ENTRY	nearest_color;
		int32	difference;
		int32	tmp;

		v_color2nearest( vdi_handle, ctab->color_space, color, &nearest_color );	/* nÑchsten Farbwert suchen */
	
		difference = ABS((int32) color->rgb.red - (int32) nearest_color.rgb.red );
		tmp = ABS((int32) color->rgb.green - (int32) nearest_color.rgb.green );
		difference = MAX( tmp, difference ); 
		tmp = ABS((int32) color->rgb.blue - (int32) nearest_color.rgb.blue );
		difference = MAX( tmp, difference ); 

		if ( difference < max_difference )							/* tolerierbarer Unterschied? */
			no_similar_colors++;

		color++;
		no_colors--;
	}

	if ( no_similar_colors >= min_colors )							/* ist die Mindestanzahl von Ñhnlichen Farben vorhanden? */
		return( 0 );

	return( 1 );
}

/*----------------------------------------------------------------------------------------*/
/* AES-Handle herausfinden																						*/
/* Funktionsresultat:	AES-Handle																			*/
/*----------------------------------------------------------------------------------------*/
static int16	get_base_handle( void )
{
extern void _mt_aes( PARMDATA *d, WORD *ctrldata,	WORD *global );

	PARMDATA d;
	static WORD c[] = {77,0,5,0};

	d.intout[0] = 1;
	_mt_aes( &d, c, 0L );
	return(d.intout[0]);
}

/*----------------------------------------------------------------------------------------*/ 
/* Bildtyp identifizieren																						*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	name:						Dateiname																			*/
/*	pic:						Bildbeschreibung																	*/
/*----------------------------------------------------------------------------------------*/ 
static int16	img_identify( int8 *name, IMG_REF *pic )
{
	int32		file_handle;
	uint32	file_type;
	int16		identified;

	identified = 0;
	strcpy((int8 *) &file_type, name + strlen( name ) - 3 );
	strupr((int8 *) &file_type );
	file_type = ( file_type >> 8 ) | 0x20000000UL;

	file_handle = Fopen( name, FO_READ );							/* Datei îffnen */

	if ( file_handle > 0 )												/* lÑût die Datei sich îffnen? */
	{
		if ( file_type == ' ESM' )										/* ESM-Datei? */
		{
			uint32	magic;
	
			if ( Fread((int16) file_handle, sizeof( uint32 ), &magic ) == sizeof( uint32 ))
			{
				if ( magic == 'TMS\0' )									/* richtige Kennung? */
				{
					pic->img_open = ESM_open;
					pic->img_close = ESM_close;
					pic->img_read_slice = ESM_read_slice;
					identified = 1;
				}	
			}
		}
		else if ( file_type == ' IMG' )								/* IMG- oder XIMG-Datei? */
		{
			pic->img_open = IMG_open;
			pic->img_close = IMG_close;
			pic->img_read_slice = IMG_read_slice;
			identified = 1;
		}
		Fclose((int16) file_handle );									/* Datei schlieûen */
	}

	return( identified );
}


/*----------------------------------------------------------------------------------------*/ 
/* Buffer anfordern																								*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*	buf:						Bufferbeschreibung																*/
/*----------------------------------------------------------------------------------------*/ 
static int16	open_buffer( IMG_REF *pic, PIC_BUFFER *buf )
{
	int32	available;
	
	buf->planes = pic->planes;

	buf->y1 = -32767;
	buf->y2 = -32767;

	switch ( buf->planes )
	{
		case	1:
		case	2:
		case	4:
		case	8:
		case	16:
		case	32:	break;
		
		/* ungewîhnliche Formate umdefinieren */
		case	3:		buf->planes = 4;	break;						/* als 4 Bit pp verwalten */
		case	5:
		case	6:
		case	7:		buf->planes = 8;	break;						/* als 8 Bit pp verwalten */
		case	15:	buf->planes = 16;	break;						/* als 16 Bit xRGB verwalten */
		case	24:	buf->planes = 32;	break;						/* als 32 Bit xRGB verwalten */

		default:		return( 0 );										/* andere Format werden nicht unterstÅtzt */
	}

	buf->width = ( pic->width + 15 ) & 0xfff0;					/* Breite einer Bufferzeile in Pixeln (Vielfaches von 16) */
	buf->line_width = buf->width * buf->planes / 8;				/* Breite einer Bufferzeile in Bytes */

	available = (int32) Malloc( -1L );								/* Grîûe des verfÅgbaren Speichers */
	
	if ( available > pic->min_reserve_size )						/* genÅgend Speicher vorhanden? */
	{
		int32	size;
		
		available -= pic->min_reserve_size;

		size = buf->line_width * pic->height;						/* entpackte Bildgrîûe */
		if ( size < available )
			available = size;
		
		if ( available > pic->max_buffer_size )					/* grîûer als nîtig? */
			buf->len = pic->max_buffer_size;
		else
			buf->len = available;
	}
	else																		/* wenig Speicher */
		buf->len = (int32) buf->width * 16;							/* nur 16 Zeilen fÅr den Buffer anfordern */

	if (( buf->len > 0 ) && ( buf->len <= available ))
	{
		buf->height = buf->len / buf->line_width;					/* Hîhe des Buffers */
		if ( buf->height > pic->height )
			buf->height = pic->height;

		buf->len = (int32) buf->line_width * buf->height;		/* LÑnge korrigieren */
		buf->addr = Malloc( buf->len );

		if ( buf->addr )													/* Speicher vorhanden? */
			return( 1 );
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Speicher fÅr Buffer freigeben																				*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	buf:						Bufferbeschreibung																*/
/*----------------------------------------------------------------------------------------*/ 
static int16	close_buffer( PIC_BUFFER *buf )
{
	if ( Mfree( buf->addr ) == 0 )									/* lÑût sich der Block freigeben? */
		return( 1 );
	else
		return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Bild einlesen und (mit Vergrîûerung) ausgeben														*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*	dst_rect:				Ausgaberechteck																	*/
/*	mode:						Transfermodus																		*/
/*	clip_rect:				Clipping-Rechteck (fÅr Ausgabe in einem Fenster)						*/
/*	vdi_handle:				VDI-Handle des Treibers															*/
/*----------------------------------------------------------------------------------------*/ 
int16	img_show( IMG_REF *pic, 
					 GCBITMAP *dst, RECT16 *dst_rect, int16 mode, 
					 RECT16 *clip_rect, int16 vdi_handle )
{
	PIC_BUFFER	*buf;
	GCBITMAP	src;
	RECT16	src_rect;
	RECT16	local_clip_rect;
	int16	slice_height;
	int16	height;
	int16	y1;
	int16	src_dy;
	int16	dst_dy;

	if ( pic->buffer.addr == 0L )										/* kein Buffer vorhanden? */
	{
		if ( open_buffer( pic, &pic->buffer ) == 0 )
			return( 0 );													/* Fehler */
	}
	buf = &pic->buffer;

/* Bitmapbeschreibung initialisieren */
	src.magic = 'cbtm';													/* Kennung */
	src.length = sizeof( GCBITMAP );									/* StrukturlÑnge */
	src.format = 0;														/* Format 0 */
	src.reserved = 0;

	src.addr = (uint8 *) buf->addr;									/* Bitmapadresse */
	src.width = buf->line_width;										/* Bytes pro Zeile */
	src.bits = buf->planes;												/* Bits pro Pixel */
	src.px_format = pref_px_format[src.bits - 1];				/* Pixelformat der Quelle angeben */

	src.xmin = 0;
	src.ymin = 0;
	src.xmax = buf->width;
	src.ymax = buf->height;

	if ( pic->ctab.magic )
		src.ctab = (CTAB_REF) &pic->ctab;							/* Zeiger auf die Farbtabelle */
	else
		src.ctab = 0L;														/* keine Farbtabelle */
	src.itab = 0L;															/* keine inverse Farbtabelle bei Quellbitmaps */
	src.reserved0 = 0L;
	src.reserved1 = 0L;

	src_rect.x1 = 0;														/* linke Ecke des Quellblocks */
	src_rect.y1 = 0;														/* Startzeile des Quellblocks */
	src_rect.x2 = pic->width - 1;										/* rechte Ecke des Quellblocks */
	src_rect.y2 = pic->height - 1;									/* untere Ecke des Quellblocks */

	local_clip_rect = *clip_rect;										/* Clipping-Rechteck setzen */

	height = pic->height;												/* Hîhe des Quellbilds */
	slice_height = buf->height;										/* Hîhe des Buffers */

	src_dy = pic->height - 1;
	dst_dy = dst_rect->y2 - dst_rect->y1;

	y1 = 0;

	while ( height > 0 )
	{
		int16 next_clip_y1;
		int16	y2;
				
		if ( height < slice_height )
			slice_height = height;
	
		y2 = y1 + slice_height - 1;									/* letzte einzulesende Scheibe */

		if ( pic->img_read_slice( pic, buf, y1, y2 ))			/* lÑût sich die Scheibe einlesen? */
		{
			int32	dy;
			
			dy = y1 + slice_height - 1;								/* letzte einzulesende Zeile */

			dy *= ( dst_dy + 1 );
			if ( src_dy < dst_dy )										/* Quelle kleiner als das Ziel? */
				dy += dst_dy;
			dy /= ( src_dy + 1 );										/* Abstand der letzten auszugebenden Zeile zu dst_y1 */
		
			local_clip_rect.y2 = dst_rect->y1 + (int16) dy;		/* letzte auszugebende Zeile */

			if ( src_dy > dst_dy )										/* verkleinern? */
			{
				int16	src_prev_y;
				int16	src_last_y;
			
				dy *= ( src_dy + 1 );
				src_prev_y = (int16) (( dy - 1 ) / ( dst_dy + 1 ));
				src_last_y = (int16) (( dy + src_dy ) / ( dst_dy + 1 ));
				
				src_prev_y -= y1;											/* Hîhe der Scheibe - 1, wenn local_clip_rect.y2 - 1 die letzte Ausgabezeile ist */
				src_last_y -= y1;											/* Hîhe der Scheibe - 1, wenn local_clip_rect.y2 die letzte Ausgabezeile ist */

				if (( src_last_y >= slice_height ) && ( src_prev_y >= 0 ))	/* ist die Scheibe zu klein? */
				{
					slice_height = src_prev_y + 1;
					local_clip_rect.y2--;								/* eine Zeile weniger ausgeben */
				}
			}

			src.ymax = slice_height;									/* tatsÑchliche Grîûe der Quelle */

			next_clip_y1 = local_clip_rect.y2 + 1;					/* erste auszugebende Zeile fÅr den nÑchsten Durchgang */
			
			if ( local_clip_rect.y1 <  clip_rect->y1 )
				local_clip_rect.y1 = clip_rect->y1;
			
			if ( local_clip_rect.y2 > clip_rect->y2 )
				local_clip_rect.y2 = clip_rect->y2;

			if ( local_clip_rect.y1 <= local_clip_rect.y2 )		/* sichbarer Bereich? */
			{
				vs_clip( vdi_handle, 1, (int16 *) &local_clip_rect );	/* Clipping-Rechteck setzen */

				vr_transfer_bits( vdi_handle, &src, dst,
										(int16 *) &src_rect, (int16 *) dst_rect,
										mode );
			}
			src_rect.y1 -= slice_height;
			src_rect.y2 -= slice_height;

			local_clip_rect.y1 = next_clip_y1;						/* erste auszugebende Zeile fÅr den nÑchsten Durchgang */
		}
	
		y1 += slice_height;
		y2 += slice_height;
		
		height -= slice_height;
	}
	
	return( 1 );
}	

/*----------------------------------------------------------------------------------------*/ 
/* Bild einlesen und in Zielbitmap kopieren																*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*	buf:						Bufferbeschreibung																*/
/*	dst:						Zielbitmap																			*/
/*	vdi_handle:				VDI-Handle des Treibers															*/
/*----------------------------------------------------------------------------------------*/ 
int16	img_copy( IMG_REF *pic, GCBITMAP *dst, int16 vdi_handle )
{
	PIC_BUFFER	*buf;
	GCBITMAP	src;
	RECT16	src_rect;
	RECT16	dst_rect;
	int16	slice_height;
	int16	height;
		
	if ( pic->buffer.addr == 0L )										/* kein Buffer vorhanden? */
	{
		if ( open_buffer( pic, &pic->buffer ) == 0 )
			return( 0 );													/* Fehler */
	}
	buf = &pic->buffer;

/* Bitmapbeschreibung initialisieren */
	src.magic = 'cbtm';													/* Kennung */
	src.length = sizeof( GCBITMAP );									/* StrukturlÑnge */
	src.format = 0;														/* Format 0 */
	src.reserved = 0;

	src.addr = (uint8 *) buf->addr;									/* Bitmapadresse */
	src.width = buf->line_width;										/* Bytes pro Zeile */
	src.bits = buf->planes;												/* Bits pro Pixel */
	src.px_format = pref_px_format[src.bits - 1];				/* Pixelformat der Quelle angeben */

	src.xmin = 0;
	src.ymin = 0;
	src.xmax = buf->width;
	src.ymax = buf->height;

	if ( pic->ctab.magic )
		src.ctab = (CTAB_REF) &pic->ctab;							/* Zeiger auf die Farbtabelle */
	else
		src.ctab = 0L;														/* keine Farbtabelle */
	src.itab = 0L;															/* keine inverse Farbtabelle bei Quellbitmaps */
	src.reserved0 = 0L;
	src.reserved1 = 0L;

	src_rect.x1 = 0;														/* linke Ecke des Quellblocks */
	src_rect.y1 = 0;														/* Startzeile des Quellblocks */
	src_rect.x2 = pic->width - 1;										/* rechte Ecke des Quellblocks */
	src_rect.y2 = pic->height - 1;									/* untere Ecke des Quellblocks */

	dst_rect = src_rect;

	height = pic->height;												/* Hîhe des Quellbilds */
	slice_height = buf->height;										/* Hîhe des Buffers */

	while ( height > 0 )
	{
		if ( height < slice_height )
			slice_height = height;
	
		src_rect.y2 = slice_height - 1;
		dst_rect.y2 = dst_rect.y1 + slice_height - 1;

		if ( pic->img_read_slice( pic, buf, dst_rect.y1, dst_rect.y2 ))	/* lÑût sich die Scheibe einlesen? */
		{
			src.ymax = slice_height;									/* tatsÑchliche Grîûe der Quelle */

			vr_transfer_bits( vdi_handle, &src, dst,
									(int16 *) &src_rect, (int16 *) &dst_rect,
									T_LOGIC_COPY | T_DITHER_MODE );
		}
		
		dst_rect.y1 += slice_height;
		height -= slice_height;
	}
	
	return( 1 );
}	

