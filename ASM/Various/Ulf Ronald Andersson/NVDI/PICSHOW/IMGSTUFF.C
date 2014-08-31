/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>														/* Prozessorunabh„ngige Datentypen */
#include	<PORTAB.H>														/* Kompatibilit„t */
#include	<TOS.H>															/* GEMDOS-, Bios- und XBios-Funktionen */
#include	<RKIT.H>															/* Funktionsdefinitionen und Umlenkungen fr den Rasterkit */
#include <VDICOL.H>														/* Erweiterungen und Farbfunktionen */

#include	<string.h>

#include "PIC.H"
#include	"IMG_FN.H"														/* globale Funktionen des IMG-Laders */

/*----------------------------------------------------------------------------------------*/ 
/*	externe Funktionen																							*/
/*----------------------------------------------------------------------------------------*/ 
extern int32	plane2packed( int32 no_words, int32 plane_length, int16 no_planes, void *src, void *dst ); 

/*----------------------------------------------------------------------------------------*/ 
/*	interne Funktionen																							*/
/*----------------------------------------------------------------------------------------*/ 
static void unpack_line( IMG_REF *pic, uint8 *des );
static void fill_img_buf( IMG_REF *pic );
static void	refill_img_buf( IMG_REF *pic, int32 read );
static uint8 *unpack_line1( uint8 *img, uint8 *des, int16 pat_len, int16 len );
static uint8 *unpack_line2( uint8 *img, uint8 *des, int16 pat_len, int16 len );

/*----------------------------------------------------------------------------------------*/ 
/*	interne Strukturen																							*/
/*----------------------------------------------------------------------------------------*/ 
typedef struct
{
	int16	img_buf_valid;
	int16	img_y;															/* aktuelle y-Koordinate im IMG-Buffer */
	uint8 *img_buf;														/* Zeiger auf gepackte IMG-Daten */
	int32	img_buf_len;													/* L„nge des IMG-Buffers */
	int32	img_buf_offset;												/* Abstand zum Anfang des IMG-Buffers */
	int32	img_buf_used;													/* Anzahl der benutzten Bytes des IMG-Buffers */

	uint8	*line_buffer;													/* Buffer fr entpackte IMG-Zeile im Standardformat */

	int16	pat_len;															/* L„nge eines Musters in Bytes */
	int16	line_len;														/* L„nge einer Zeile in Bytes */

	int32	rest_length;													/* noch einzulesende Dateil„nge */
	int32	file_length;													/* Dateil„nge */
} XIMG_DATA;

static COLOR_RGB	white = { 0, 0xffffU, 0xffffU, 0xffffU };
static COLOR_RGB	black = { 0, 0x0000U, 0x0000U, 0x0000U };

/*----------------------------------------------------------------------------------------*/ 
/* IMG-Bild ”ffnen																								*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/* name:						absoluter Pfad mit Dateinamen													*/
/*	pic:						Bildbeschreibung																	*/
/*----------------------------------------------------------------------------------------*/ 
int16	IMG_open( int8 *name, IMG_REF *pic, int16 vdi_handle )
{
	int32	handle;
	int16	line_width;

	handle = Fopen( name, FO_READ );									/* Datei ”ffnen */

	if ( handle > 0 )														/* l„t die Datei sich ”ffnen? */
	{
		IMGHDR	*head;
		
		pic->file_handle = (int16) handle;
		head = Malloc( sizeof( IMGHDR ));							/* Speicher fr Header anfordern */

		if ( head )
		{
			pic->head.img = head;

			if (( Fread((int16) handle, sizeof( IMGHDR ), head ) == sizeof( IMGHDR )) &&	/* konnte der Header geladen werden? */
				 (( head->planes >= 1 ) && ( head->planes <= 8 )))	/* Format untersttzt? */
			{
				XIMG_DATA	*info;

				info = Malloc( sizeof( XIMG_DATA ));				/* Speicher fr Verwaltung anfordern */

				if ( info )
				{
					pic->format_specific_data = (void *) info;

					info->pat_len = head->pattern_length;			/* Bytes pro Muster */
					info->line_len = ( head->w + 7 ) / 8;			/* L„nge einer monochromen IMG-Zeile in Bytes */
					line_width = (( head->w + 15 ) & 0xfff0 ) / 8;	/* Breite in Bytes (Vielfaches von 2) */
					line_width *= head->planes;						/* Breite einer farbigen Zeile in Bytes */

					info->line_buffer = Malloc((int32) line_width );	/* Buffer frs Entpacken einer Zeile */
		
					if ( info->line_buffer )
					{
						info->file_length = Fseek( 0, handle, 2 );	/* Dateil„nge */
	
						info->img_buf_len = 8192;
						if ( info->img_buf_len < ( 2 * line_width ))
							info->img_buf_len = 2 * line_width;
	
						info->img_buf_valid = 0;						/* Buffer ist noch nicht aufgefllt */
						info->img_buf = Malloc( info->img_buf_len );	/* Buffer ber Malloc anfordern */
	
						if ( info->img_buf )
						{
							COLOR_TAB	*ctab;
							COLOR_ENTRY	*color;
							int16	no_entries;
							int16	i;
			
							pic->width = head->w;						/* Breite in Pixeln */
							pic->height = head->h;						/* H”he in Zeilen */
							pic->planes = head->planes;				/* Anzahl der Ebenen */
			
							no_entries = 1 << pic->planes;			/* Anzahl der Farbeintr„ge */
										
							ctab = (COLOR_TAB *) &pic->ctab;			/* Zeiger auf die Farbtabelle */
										
							ctab->magic = 'ctab';						/* Kennung */
							ctab->length = sizeof ( COLOR_TAB ) + ( no_entries * sizeof( COLOR_ENTRY ));	/* L„nge */
							ctab->format = 0;								/* Format 0 */
							ctab->reserved = 0;
							ctab->map_id = v_get_ctab_id( vdi_handle );	/* Kennung der Farbtabelle */
							ctab->color_space = CSPACE_RGB;			/* Farbraum */
							ctab->flags = CSPACE_3COMPONENTS;		/* Anzahl der Komponenten angeben */
							ctab->no_colors = no_entries;				/* Anzahl der Farbeintr„ge */
			
							ctab->reserved1 = 0;
							ctab->reserved2 = 0;
							ctab->reserved3 = 0;
							ctab->reserved4 = 0;
			
							ctab->colors[0].rgb = white;				/* Wei und Schwarz fr den Fall zuweisen, da es kein XIMG ist */
							ctab->colors[1].rgb = black;
			
							if ( head->length > ( sizeof( IMGHDR ) / 2 ))	/* m”glicherweise XIMG? */
							{
								int8	identify[6];
					
								Fseek( sizeof( IMGHDR ), handle, 0 );	/* Dateiheader berspringen */
								Fread( handle, 6, identify );
								if ( *(int32 *) identify == 'XIMG' )	/* XIMG-Kennung vorhanden? */
								{
									RGB1000	*palette;
									int32		pal_len;
									
									palette = (RGB1000 *) ctab->colors;
									
									pal_len = ( head->length * 2 ) - 6 - sizeof( IMGHDR );	/* L„nge der Palette in Bytes */
									
									if ( pal_len > ( 256 * sizeof( RGB1000 )))
										pal_len = 256 * sizeof( RGB1000 );
									
									Fread( handle, pal_len, palette );	/* Palettendaten einlesen */
			
									color = ctab->colors;
	
									for ( i =  no_entries - 1; i >= 0; i-- )
									{
										int32		intensity;
										
										intensity = palette[i].blue;
										color[i].rgb.blue = (( intensity << 16 ) - intensity ) / 1000L;
										
										intensity = palette[i].green;
										color[i].rgb.green = (( intensity << 16 ) - intensity ) / 1000L;

										intensity = palette[i].red;
										color[i].rgb.red = (( intensity << 16 ) - intensity ) / 1000L;
			
										color[i].rgb.reserved = i;		/* Farbindex */
									}
								}
							}
							return( 1 );
						}
						Mfree( info->line_buffer );					/* Buffer fr entpackte Zeile freigeben */
					}
					Mfree( info );											/* Speicher fr Verwaltung freigeben */
				}
			}
			Mfree( pic->head.img );										/* Speicher freigeben */
		}
		Fclose((int16) handle );										/* Datei schlieen */
	}
	return( 0 );
}


/*----------------------------------------------------------------------------------------*/ 
/* IMG-Datei schlieen																							*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*----------------------------------------------------------------------------------------*/ 
int16	IMG_close( IMG_REF *pic )
{
	XIMG_DATA	*info;

	info = (XIMG_DATA *) pic->format_specific_data;

	Mfree( info->img_buf );												/* Buffer fr gepackte Daten freigeben */
	Mfree( info->line_buffer );										/* Buffer fr entpackte Zeile freigeben */
	Mfree( info );															/* Speicher fr Verwaltung freigeben */
	Mfree( pic->head.img );												/* Speicher freigeben */

	if ( Fclose( pic->file_handle ) == 0 )
		return( 1 );
	else
		return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Teil eines IMG-Bilds laden																					*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*	buf:						Bufferbeschreibung																*/
/*	y1:						erste einzulesende Zeile														*/
/*	y2:						letzte einzulesende Zeile														*/
/*----------------------------------------------------------------------------------------*/ 
int16	IMG_read_slice( IMG_REF *pic, PIC_BUFFER *buf, int16 y1, int16 y2 )
{
	XIMG_DATA	*info;
	IMGHDR		*head;
	uint8			*dst;
	int16			even_len;
	int16			y;

	info = (XIMG_DATA *) pic->format_specific_data;
	head = pic->head.img;
	dst = buf->addr;

	if (( info->img_buf_valid == 0 ) || ( info->img_y != y1 ))	/* ist der aktuelle Status nicht gltig? */
	{
		Fseek( head->length * 2, pic->file_handle, 0 );			/* Dateiheader berspringen */
		info->rest_length = info->file_length - head->length * 2;	/* verbleibende Dateil„nge korrigieren */
		fill_img_buf( pic );												/* Buffer auffllen */
		info->img_buf_valid = 1;
		info->img_y = 0;
	}

	even_len = ( info->line_len + 1 ) & ~1L;

	for ( y = info->img_y; y <= y2; y++ )							/* von der aktuelle Datenzeile aus bis y2 entpacken */
	{
		unpack_line( pic, info->line_buffer );						/* komplette Zeile in den Buffer entpacken */

		if ( y >= y1 )
		{
			if ( info->line_len & 1 )									/* ungerade Zeilenl„nge? */
			{
				uint8	*odd;
				uint8	*even;
				int16	i;
				
				odd = info->line_buffer + ( info->line_len * head->planes );	/* Zeiger hinter die Daten mit ungerader Zeilenl„nge */
				even = odd + head->planes;								/* Zeiger hinter die Daten mit gerader Zeilenl„nge */

				for ( i = 0; i < head->planes; i++ )
				{
					*( --even ) = 0;										/* Fllbyte */

					odd -= info->line_len;
					even -= info->line_len;
					memcpy( even, odd, info->line_len );
				}
			}
			plane2packed( even_len >> 1, even_len, head->planes, info->line_buffer, dst );	/* wandeln */
			dst += buf->line_width;										/* n„chste Zeile */
		}	
	}

	info->img_y = y;														/* Position innerhalb der IMG-Daten */
	buf->y1 = y1;
	buf->y2 = y2;
	
	return( 1 );
}

/*----------------------------------------------------------------------------------------*/ 
/* IMG-Zeile auspacken																							*/
/* Funktionsresultat:	-																						*/
/*----------------------------------------------------------------------------------------*/ 
static void unpack_line( IMG_REF *pic, uint8 *des )
{
	XIMG_DATA	*info;
	uint8	*img_line;
	int32	read;
	
	info = (XIMG_DATA *) pic->format_specific_data;
	img_line = info->img_buf + info->img_buf_offset;

	read = (int32) ( unpack_line1( img_line, des, info->pat_len, info->line_len * pic->head.img->planes ) - img_line );

	refill_img_buf( pic, read );										/* Buffer weiter auffllen */
}

/*----------------------------------------------------------------------------------------*/ 
/* Buffer zum ersten Mal fllen																				*/
/* Funktionsresultat:	-																						*/
/*----------------------------------------------------------------------------------------*/ 
static void fill_img_buf( IMG_REF *pic )
{
	XIMG_DATA	*info;
	int32	read;
	
	info = (XIMG_DATA *) pic->format_specific_data;

	read = info->img_buf_len;											/* Buffer komplett fllen */
	if ( read > info->rest_length )									/* mehr Bytes als die Datei lang ist? */
		read = info->rest_length;	

	info->img_buf_offset = 0;											/* Bufferstart */	
	info->img_buf_used = Fread( pic->file_handle, read, info->img_buf );	/* einlesen */
	info->rest_length -= info->img_buf_used;						/* noch vorhandene Dateil„nge verkleinern */
}

/*----------------------------------------------------------------------------------------*/ 
/* Buffer auffllen																								*/
/* Funktionsresultat:	-																						*/
/*	read:						Anzahl der gelesenen Bytes														*/
/*----------------------------------------------------------------------------------------*/ 
static void	refill_img_buf( IMG_REF *pic, int32 read )
{	
	XIMG_DATA	*info;
	info = (XIMG_DATA *) pic->format_specific_data;

	info->img_buf_used -= read;										/* Anzahl der gltigen Bytes im Buffer */
	info->img_buf_offset += read;										/* Abstand zum Bufferstart */
	
	if ( info->img_buf_offset >= ( info->img_buf_len / 2 ))	/* Buffer halbleer? */
	{
		if ( info->img_buf_used > 0 )		
			memcpy( info->img_buf, info->img_buf + info->img_buf_offset, info->img_buf_used );	/* an Bufferstart verschieben */
		
		read = info->img_buf_offset;									/* Anzahl der zus„tzlich zu lesenden Bytes */

		if ( read > info->rest_length )								/* mehr Bytes als die Datei lang ist? */
			read = info->rest_length;

		read = Fread( pic->file_handle, read, info->img_buf + info->img_buf_used );	/* einlesen */
	
		info->img_buf_used += read;									/* Buffergr”e korrigieren */
		info->img_buf_offset = 0;										/* Bufferstart */	
		info->rest_length -= read;										/* noch vorhandene Dateil„nge verkleinern */
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Zeile eines IMGs entpacken																					*/
/* Funktionsresultat:	Zeiger auf die n„chste Zeile im IMG-Format								*/
/*	img:						Zeiger auf die IMG-Zeile														*/
/*	des:						Zeiger auf die Zielbitmap														*/
/*	pat_len:					L„nge eines IMG-Muster in Bytes												*/
/*	len:						L„nge einer entpackten Zeile in Bytes										*/
/*----------------------------------------------------------------------------------------*/ 
static uint8 *unpack_line1( uint8 *img, uint8 *des, int16 pat_len, int16 len )
{
	if (( img[0] == 0 ) && ( img[1] == 0 ) && ( img[2] == 0xff ))	/* vertikale Wiederholung? */
	{
		if ( img[3] > 1 )													/* mehr als eine Zeile? */
		{
			unpack_line2( img + 4, des, pat_len, len );
			img[3] -= 1;													/* eine Wiederholung weniger */
			return( img );
		}
		else
			return( unpack_line2( img + 4, des, pat_len, len ));
	}
	else
		return( unpack_line2( img, des, pat_len, len ));
}

/*----------------------------------------------------------------------------------------*/ 
/* Zeile eines IMGs entpacken, vertikale Wiederholfaktoren drfen nicht vorkommen			*/
/* Funktionsresultat:	Zeiger auf die n„chste Zeile im IMG-Format								*/
/*	img:						Zeiger auf die IMG-Zeile														*/
/*	des:						Zeiger auf die Zielbitmap														*/
/*	pat_len:					L„nge eines IMG-Muster in Bytes												*/
/*	len:						L„nge einer entpackten Zeile in Bytes										*/
/*----------------------------------------------------------------------------------------*/ 
static uint8 *unpack_line2( uint8 *img, uint8 *des, int16 pat_len, int16 len )
{
	int16	i;
	uint16	cnt;

	while ( len > 0 )														/* komplette Zeile abgearbeitet? */
	{
		uint8	tag;
		
		tag = *img++;
		
		if ( tag == 0 )													/* Pattern Run? */
		{
			cnt = *img++;													/* Anzahl der Wiederholungen */
			
			for ( i = 0; i < cnt; i++ )
			{
				int16	j;
				for ( j = 0; j < pat_len; j++ )
					*des++ = img[j];
			}
																							
			img += pat_len;												/* Musterdaten berspringen */
			cnt *= pat_len;												/* L„nge des Musters */
		}
		else if ( tag == 0x80 )											/* Bit String? */
		{
			cnt = *img++;													/* Anzahl der unkomprimierten Bytes */
		
			for ( i = 0; i < cnt; i++ )
				*des++ = *img++;
		}
		else if (( tag & 0x80 ) == 0 )								/* weier Solid Run? */
		{
			cnt = tag & 0x7f;												/* Anzahl der Wiederholungen */
			
			for ( i = 0; i < cnt; i++ )
				*des++ = 0;
		}
		else																	/* schwarzer Solid Run */
		{
			cnt = tag & 0x7f;												/* Anzahl der Wiederholungen */
			
			for ( i = 0; i < cnt; i++ )
				*des++ = 0xff;
		}	

		len -= cnt;															/* Anzahl der noch vorhandenen Bytes */
	}
	return( img );
}
