/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>														/* ProzessorunabhÑngige Datentypen */
#include	<PORTAB.H>														/* KompatibilitÑt */
#include	<TOS.H>															/* GEMDOS-, Bios- und XBios-Funktionen */
#include	<RKIT.H>															/* Funktionsdefinitionen und Umlenkungen fÅr den Rasterkit */
#include <VDICOL.H>														/* Erweiterungen und Farbfunktionen */

#include "PIC.H"
#include	"ESM_FN.H"														/* globale Funktionen des ESM-Laders */

/*----------------------------------------------------------------------------------------*/ 
/*	interne Funktionen																							*/
/*----------------------------------------------------------------------------------------*/ 
static int16	ESM_read_1( IMG_REF *pic, PIC_BUFFER *buf, int16 y1, int16 y2 );
static int16	ESM_read_8( IMG_REF *pic, PIC_BUFFER *buf, int16 y1, int16 y2 );
static int16	ESM_read_24( IMG_REF *pic, PIC_BUFFER *buf, int16 y1, int16 y2 );


/*----------------------------------------------------------------------------------------*/ 
/* ESM-Bild îffnen																								*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/* name:						absoluter Pfad mit Dateinamen													*/
/*	pic:						Bildbeschreibung																	*/
/*----------------------------------------------------------------------------------------*/ 
int16	ESM_open( int8 *name, IMG_REF *pic, int16 vdi_handle )
{
	int32	handle;

	handle = Fopen( name, FO_READ );									/* Datei îffnen */

	if ( handle > 0 )														/* lÑût die Datei sich îffnen? */
	{
		ESM_HEAD	*head;
		
		pic->file_handle = (int16) handle;
		head = Malloc( sizeof( ESM_HEAD ));							/* Speicher fÅr Header anfordern */

		if ( head )
		{
			pic->head.esm = head;

			if ( Fread((int16) handle, sizeof( ESM_HEAD ), head ) == sizeof( ESM_HEAD ))
			{
				if ( head->magic == 'TMS\0' )							/* richtige Kennung? */
				{
					pic->width = head->width;
					pic->height = head->height;
					pic->planes = head->planes;
	
					if ( head->format == 2 )							/* Graustufenbild? */
					{
						int16	i;
						
						for ( i = 0; i < 256; i++ )
						{
							head->green[i] = head->red[i];
							head->blue[i] = head->red[i];
						}
					}

					if ( pic->planes <= 8 )								/* Bild mit Farbpalette? */
					{
						int16	no_entries;
						int16	max_r_level;
						int16	max_g_level;
						int16	max_b_level;
						
						no_entries = 1 << pic->planes;				/* Anzahl der FarbeintrÑge */
						max_r_level = ( 1 << head->r_bits ) - 1;	/* Anzahl der Rot-Abstufungen - 1 */
						max_g_level = ( 1 << head->g_bits ) - 1;	/* Anzahl der GrÅn-Abstufungen - 1 */
						max_b_level = ( 1 << head->b_bits ) - 1;	/* Anzahl der Blau-Abstufungen - 1 */
						
						if ( head->size >= sizeof( ESM_HEAD ))		/* Farbpalette vorhanden? */
						{
							COLOR_TAB	*ctab;
							COLOR_ENTRY	*color;
							int16	i;
							
							ctab = (COLOR_TAB *) &pic->ctab;			/* Zeiger auf die Farbtabelle */
							
							ctab->magic = 'ctab';						/* Kennung */
							ctab->length = sizeof ( COLOR_TAB ) + ( no_entries * sizeof( COLOR_ENTRY ));	/* LÑnge */
							ctab->format = 0;								/* Format 0 */
							ctab->reserved = 0;
							ctab->map_id = v_get_ctab_id( vdi_handle );	/* Kennung der Farbtabelle */
							ctab->color_space = CSPACE_RGB;			/* Farbraum */
							ctab->flags = CSPACE_3COMPONENTS;		/* Anzahl der Komponenten angeben */
							ctab->no_colors = no_entries;				/* Anzahl der FarbeintrÑge */

							ctab->reserved1 = 0;
							ctab->reserved2 = 0;
							ctab->reserved3 = 0;
							ctab->reserved4 = 0;

							color = ctab->colors;						/* Zeiger auf die FarbeintrÑge */

							for ( i = 0; i < no_entries; i++ )		/* FarbeintrÑge besetzen */
							{
								uint16	intensity;

								color[i].rgb.reserved = i;				/* Farbindex */

								intensity = ( head->red[i] * 255 ) / max_r_level;
								color[i].rgb.red = ( intensity << 8 ) | intensity;

								intensity = ( head->green[i] * 255 ) / max_g_level;
								color[i].rgb.green = ( intensity << 8 ) | intensity;

								intensity = ( head->blue[i] * 255 ) / max_b_level;
								color[i].rgb.blue = ( intensity << 8 ) | intensity;
							}
						}
						else
							pic->ctab.magic = 0;							/* ctab nicht gÅltig */
					}
					else
						pic->ctab.magic = 0;								/* ctab nicht gÅltig */

					return( 1 );
				}
			}
						
			Mfree( pic->head.esm );										/* Speicher freigeben */
		}
		Fclose((int16) handle );										/* Datei schlieûen */
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* ESM-Bild schlieûen																							*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*----------------------------------------------------------------------------------------*/ 
int16	ESM_close( IMG_REF *pic )
{
	Mfree( pic->head.esm );												/* Speicher freigeben */

	if ( Fclose( pic->file_handle ) == 0 )
		return( 1 );
	else
		return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Teil eines ESM-Bilds laden																					*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*	buf:						Bufferbeschreibung																*/
/*	y1:						erste einzulesende Zeile														*/
/*	y2:						letzte einzulesende Zeile														*/
/*----------------------------------------------------------------------------------------*/ 
int16	ESM_read_slice( IMG_REF *pic, PIC_BUFFER *buf, int16 y1, int16 y2 )
{
	int16	result;

	result = 0;

	switch ( pic->head.esm->planes )
	{
		case	1:		result = ESM_read_1( pic, buf, y1, y2 );	break;
		case	8:		result = ESM_read_8( pic, buf, y1, y2 );	break;
		case	24:	result = ESM_read_24( pic, buf, y1, y2 );	break;
	}

	if ( result )
	{
		buf->y1 = y1;
		buf->y2 = y2;
	}
	else
	{
		buf->y1 = -1;
		buf->y2 = -1;
	}

	return( result );
}

/*----------------------------------------------------------------------------------------*/ 
/* Teil eines ESM-Bilds laden und von 1 in 32 Bit wandeln											*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*	buf:						Bufferbeschreibung																*/
/*	y1:						erste einzulesende Zeile														*/
/*	y2:						letzte einzulesende Zeile														*/
/*----------------------------------------------------------------------------------------*/ 
static int16	ESM_read_1( IMG_REF *pic, PIC_BUFFER *buf, int16 y1, int16 y2 )
{
	ESM_HEAD	*head;
	int16	width;
	int32	offset;
	int16	handle;
	
	head = pic->head.esm;
	handle = pic->file_handle;
	width = ( head->width + 7 ) / 8;									/* Bytes pro Zeile */
	
	offset = head->size + ((int32) y1 * width );					/* Abstand zum Dateianfang */

	if ( Fseek( offset, (int16) handle, 0 ) == offset )		/* erste auszulesende Zeile */
	{
		int32	len;
		
		len = (int32) ( y2 - y1 + 1 ) * width;						/* LÑnge des zu ladenden Bereichs */
		
		if ( Fread( handle, len, buf->addr ) == len )			/* Daten einlesen	*/
		{
			if ( width & 1 )												/* ungerade Breite? */
			{
				uint8	*bufb;
				uint8	*bufw;
				
				bufb = (uint8 *) buf->addr + len;					/* Zeiger hinter die Daten mit ungerader Breite */
				
				bufw = (uint8 *) buf->addr;
				bufw += (int32) ( y2 - y1 + 1 ) * buf->line_width;	/* Zeiger hinter die Daten mit gerader Breite */
				
				while ( y1 <= y2 )
				{
					int16	x;
					
					*( --bufw ) = 0;										/* Leerpixel */
					
					for ( x = 0; x < width; x++ )						/* je 8 Pixel kopieren */
						*( --bufw ) = *( --bufb );

					y1++;
				}
			}
			return( 1 );													/* alles in Ordnung */
		}
	}
	return( 0 );															/* Fehler */
}

/*----------------------------------------------------------------------------------------*/ 
/* Teil eines ESM-Bilds laden und von 8 in 32 Bit wandeln											*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*	buf:						Bufferbeschreibung																*/
/*	y1:						erste einzulesende Zeile														*/
/*	y2:						letzte einzulesende Zeile														*/
/*----------------------------------------------------------------------------------------*/ 
static int16	ESM_read_8( IMG_REF *pic, PIC_BUFFER *buf, int16 y1, int16 y2 )
{
	ESM_HEAD	*head;
	int32	offset;
	int16	handle;
	int16	esm_width;

	handle = pic->file_handle;
	head = pic->head.esm;
	esm_width = head->width;
	
	offset = head->size + ((int32) y1 * esm_width );			/* Abstand zum Dateianfang */

	if ( Fseek( offset, (int16) handle, 0 ) == offset )		/* erste auszulesende Zeile */
	{
		int32	len;
		
		len = (int32) ( y2 - y1 + 1 ) * esm_width;				/* LÑnge des zu ladenden Bereichs */
		
		if ( Fread( handle, len, buf->addr ) == len )			/* Daten einlesen	*/
		{
			if ( buf->planes == 8 )
			{
				if ( esm_width & 15 )									/* ungerade Breite? */
				{
					uint8	*bufb;
					uint8	*bufw;
					
					bufb = (uint8 *) buf->addr + len;				/* Zeiger hinter die Daten mit ungerader Breite */
					
					bufw = (uint8 *) buf->addr;
					bufw += (int32) ( y2 - y1 + 1 ) * buf->line_width;	/* Zeiger hinter die Daten mit gerader Breite */
					
					while ( y1 <= y2 )
					{
						int16	x;
						
						for ( x = esm_width; x < buf->width; x++ )	/* unbenutzte Pixel sind weiû */
							*( --bufw ) = 0;									/* Leerpixel */
						
						for ( x = 0; x < esm_width; x++ )				/* je 8 Pixel kopieren */
							*( --bufw ) = *( --bufb );
	
						y1++;
					}
				}
			
			}
			else																/* Bitmap mit 32 Bit pro Pixel bilden */
			{
				uint8		*buf8;
				uint32	*buf32;
				
				buf8 = (uint8 *) buf->addr + len;					/* Zeiger hinter die 24-Bit-Daten */
				buf32 = (uint32 *) ((uint8 *) buf->addr +
						  ((int32) ( y2 - y1 + 1 ) * buf->line_width ));	/* Zeiger hinter die 32-Bit-Daten */
				
				while ( y1 <= y2 )
				{
					int16	x;
					
					for ( x = esm_width; x < buf->width; x++ )	/* unbenutzte Pixel sind weiû */
						*( --buf32 ) = 0x00ffffffL;
					
					for ( x = 0; x < esm_width; x++ )				/* Pixel kopieren und von 8 auf 32 Bit erweitern */
					{
						COLOR_ENTRY	*color;
						uint32	value;
						
						color = &pic->ctab.colors[*( --buf8 )];	/* Zeiger auf COLOR_ENTRY */
						value =  (((uint32) color->rgb.red ) << 8 ) & 0x00ff0000L;
						value |= color->rgb.green & 0x0000ffL;
						value |= color->rgb.blue >> 8;
						
						*( --buf32 ) = value;							/* xRGB-Pixelwert */
					}
					y1++;
				}
			}
			return( 1 );													/* alles in Ordnung */
		}
	}
	return( 0 );															/* Fehler */
}

/*----------------------------------------------------------------------------------------*/ 
/* Teil eines ESM-Bilds laden und von 24 in 32 Bit wandeln											*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*	buf:						Bufferbeschreibung																*/
/*	y1:						erste einzulesende Zeile														*/
/*	y2:						letzte einzulesende Zeile														*/
/*----------------------------------------------------------------------------------------*/ 
static int16	ESM_read_24( IMG_REF *pic, PIC_BUFFER *buf, int16 y1, int16 y2 )
{
	ESM_HEAD	*head;
	int32	offset;
	int16	handle;
	int16	esm_width;

	handle = pic->file_handle;
	head = pic->head.esm;
	esm_width = head->width;

	offset = head->size + ((int32) y1 * esm_width * 3 );		/* Abstand zum Dateianfang */

	if ( Fseek( offset, (int16) handle, 0 ) == offset )		/* erste auszulesende Zeile */
	{
		int32	len;
		
		len = (int32) ( y2 - y1 + 1 ) * esm_width * 3;			/* LÑnge des zu ladenden Bereichs */
		
		if ( Fread( handle, len, buf->addr ) == len )			/* Daten einlesen	*/
		{
			uint8	*buf24;
			uint8	*buf32;
			
			buf24 = (uint8 *) buf->addr + len;						/* Zeiger hinter die 24-Bit-Daten */
			buf32 = ((uint8 *) buf->addr +
					  ((int32) ( y2 - y1 + 1 ) * buf->line_width ));	/* Zeiger hinter die 32-Bit-Daten */
			
			while ( y1 <= y2 )
			{
				int16	x;
				
				for ( x = esm_width; x < buf->width; x++ )		/* unbenutzte Pixel sind weiû */
					*(--(uint32 *) buf32 ) = 0x00ffffffL;
				
				for ( x = 0; x < esm_width; x++ )					/* Pixel kopieren und von 24 auf 32 Bit erweitern */
				{
					*( --buf32 ) = *( --buf24 );						/* blau */
					*( --buf32 ) = *( --buf24 );						/* grÅn */
					*( --buf32 ) = *( --buf24 );						/* rot */
					*( --buf32 ) = 0;										/* unbenutzt */
				}
				y1++;
			}
			return( 1 );													/* alles in Ordnung */
		}
	}
	return( 0 );															/* Fehler */
}
