/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include <PORTAB.H>
#include	<TOS.H>
#include <VDI.H>
#include	<AES.H>

#include	<STDIO.H>

#include	"ESM.H"

#define	MAX_BUF_SIZE	( 512L * 1024L )
#define	RESERVE_FOR_DRIVER	( 384L * 1024L )

typedef struct
{
	WORD	red;																/* Rot-IntensitÑt in Promille (0-1000) */
	WORD	green;															/* GrÅn-IntensitÑt in Promille (0-1000) */
	WORD	blue;																/* Blau-IntensitÑt in Promille (0-1000) */
} RGB1000;

typedef struct
{
	WORD	file_handle;
	
	WORD	width;															/* Breite des Bilds in Pixeln */
	WORD	height;															/* Hîhe des Bilds in Zeilen */
	WORD	planes;															/* Tiefe des Bilds */

	RGB1000	bg;															/* Hintergrundfarbe, falls das Bild nur eine Ebene hat */
	RGB1000	fg;															/* Vordergrundfarbe, falls das Bild nur eine Ebene hat */

	union
	{
		ESM_HEAD	*esm;
	} head;
} PICTURE;

typedef struct
{
	void	*addr;															/* Bufferadresse */
	WORD	line_width;														/* Breite einer Bufferzeile in Bytes */
	WORD	width;															/* Breite einer Bufferzeile in Pixeln (Vielfaches von 16) */
	WORD	height;															/* Hîhe des Buffers in Zeilen */
	WORD	planes;
	LONG	len;																/* LÑnge des Buffers in Bytes */
} PIC_BUFFER;

WORD	ESM_open( BYTE *name, PICTURE *pic );
WORD	ESM_close( PICTURE *pic );
WORD	ESM_read( PICTURE *pic, PIC_BUFFER *buf, WORD y1, WORD y2 );
WORD	ESM_read_1( PICTURE *pic, PIC_BUFFER *buf, WORD y1, WORD y2 );
WORD	ESM_read_8( PICTURE *pic, PIC_BUFFER *buf, WORD y1, WORD y2 );
WORD	ESM_read_24( PICTURE *pic, PIC_BUFFER *buf, WORD y1, WORD y2 );
WORD	ESM_output( PICTURE *pic, PIC_BUFFER *buf, WORD zx, WORD zy, WORD zwidth, WORD zheight, WORD vdi_handle );

WORD	open_buffer( PICTURE *pic, PIC_BUFFER *buf );
WORD	close_buffer( PIC_BUFFER *buf );

/*----------------------------------------------------------------------------------------*/ 
/* ESM-Bild îffnen																								*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/* name:						absoluter Pfad mit Dateinamen													*/
/*	pic:						Bildbeschreibung																	*/
/*----------------------------------------------------------------------------------------*/ 
WORD	ESM_open( BYTE *name, PICTURE *pic )
{
	LONG	handle;

	handle = Fopen( name, FO_READ );									/* Datei îffnen */

	if ( handle > 0 )														/* lÑût die Datei sich îffnen? */
	{
		ESM_HEAD	*head;
		
		pic->file_handle = (WORD) handle;
		head = Malloc( sizeof( ESM_HEAD ));							/* Speicher fÅr Header anfordern */

		if ( head )
		{
			pic->head.esm = head;

			if ( Fread((WORD) handle, sizeof( ESM_HEAD ), head ) == sizeof( ESM_HEAD ))
			{
				if ( head->magic == 'TMS\0' )							/* richtige Kennung? */
				{
					pic->width = head->width;
					pic->height = head->height;
					pic->planes = head->planes;
	
					if ( head->format == 2 )							/* Graustufenbild? */
					{
						WORD	i;
						
						for ( i = 0; i < 256; i++ )
						{
							head->green[i] = head->red[i];
							head->blue[i] = head->red[i];
						}
					}

					if ( pic->planes == 1 )								/* monochrom? */
					{
						WORD	max_level;
	
						if ( head->size >= sizeof( ESM_HEAD ))		/* Farbpalette vorhanden? */
						{
							max_level = ( 1 << head->r_bits ) - 1;
							pic->bg.red = (WORD) ((LONG) head->red[0] * 1000L / max_level );
							pic->fg.red = (WORD) ((LONG) head->red[1] * 1000L / max_level );
		
							max_level = ( 1 << head->g_bits ) - 1;
							pic->bg.green = (WORD) ((LONG) head->green[0] * 1000L / max_level );
							pic->fg.green = (WORD) ((LONG) head->green[1] * 1000L / max_level );
		
							max_level = ( 1 << head->b_bits ) - 1;
							pic->bg.blue = (WORD) ((LONG) head->blue[0] * 1000L / max_level );
							pic->fg.blue = (WORD) ((LONG) head->blue[1] * 1000L / max_level );
						}
						else													/* Standard-Vorbesetzung */
						{
							pic->bg.red = 0;
							pic->bg.green = 0;
							pic->bg.blue = 0;
							
							pic->fg.red = 1000;
							pic->fg.green = 1000;
							pic->fg.blue = 1000;
						}
					}
					return( 1 );
				}
			}
						
			Mfree( pic->head.esm );										/* Speicher freigeben */
		}
		Fclose((WORD) handle );											/* Datei schlieûen */
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* ESM-Bild schlieûen																							*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*----------------------------------------------------------------------------------------*/ 
WORD	ESM_close( PICTURE *pic )
{
	if ( Fclose( pic->file_handle ) == 0 )
		return( 1 );
	else
		return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* ESM-Bild ausgeben																								*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*	buf:						Bufferbeschreibung																*/
/*	zx:						x-Koordinate																		*/
/*	zy:						y-Koordinate																		*/
/*	zwidth:					Breite in Pixeln																	*/
/*	zheight:					Hîhe in Zeilen																		*/
/*	vdi_handle:				VDI-Handle des Treibers															*/
/*----------------------------------------------------------------------------------------*/ 
WORD	ESM_output( PICTURE *pic, PIC_BUFFER *buf, WORD zx, WORD zy, WORD zwidth, WORD zheight, WORD vdi_handle )
{
	#define	qdy	( pic->height - 1 )
	#define	zdy	( zheight - 1 )
	
	WORD	color_index[2] = { 1, 0 };
	MFDB	src;
	MFDB	dst;
	WORD	raster[8];
	WORD	clip[4];
	WORD	slice_height;
	WORD	height;
	WORD	y1;
	
	height = pic->height;												/* Hîhe des Quellbilds */
	slice_height = buf->height;										/* Hîhe des Buffers */

	src.fd_addr = buf->addr;
	src.fd_w = buf->width;
	src.fd_h = buf->height;
	src.fd_wdwidth = buf->line_width / 2 / buf->planes;
	src.fd_stand = 0;
	src.fd_nplanes = buf->planes;
			
	dst.fd_addr = 0L;

	raster[0] = 0;															/* linke Ecke des Quellblocks */
	raster[1] = 0;															/* Startzeile des Quellblocks */
	raster[2] = pic->width - 1;										/* rechte Ecke des Quellblocks */
	raster[3] = pic->height - 1;										/* untere Ecke des Quellblocks */
	raster[4] = zx;														/* linke Ecke des Zielblocks */
	raster[5] = zy;														/* Startzeile des Zielblocks */
	raster[6] = zx + zwidth - 1;										/* rechte Ecke des Zielblocks */
	raster[7] = zy + zheight - 1;										/* untere Ecke des Zielblocks */
	
	clip[0] = raster[4];
	clip[1] = raster[5];
	clip[2] = raster[6];
	
	y1 = 0;

	while ( height > 0 )
	{
		WORD	y2;
		
		if ( height < slice_height )
			slice_height = height;
	
		y2 = y1 + slice_height - 1;									/* letzte einzulesende Scheibe */

		if ( ESM_read( pic, buf, y1, y2 ))							/* lÑût sich die Scheibe einlesen? */
		{
			LONG	dy;
			
			dy = y1 + slice_height - 1;								/* letzte einzulesende Zeile */

			dy *= ( zdy + 1 );
			if ( qdy < zdy )												/* Quelle kleiner als das Ziel? */
				dy += zdy;
			dy /= ( qdy + 1 );											/* Abstand der letzten auszugebenden Zeile zu zy1 */
		
			clip[3] = zy + (WORD) dy;									/* letzte auszugebende Zeile */

			if ( qdy > zdy )												/* verkleinern? */
			{
				WORD	qy_prev;
				WORD	qy_last;
			
				dy *= ( qdy + 1 );
				qy_prev = (WORD) (( dy - 1 ) / ( zdy + 1 ));
				qy_last = (WORD) (( dy + qdy ) / ( zdy + 1 ));
				
				qy_prev -= y1;												/* Hîhe der Scheibe - 1, wenn clip_ymax - 1 die letzte Ausgabezeile ist */
				qy_last -= y1;												/* Hîhe der Scheibe - 1, wenn clip_ymax die letzte Ausgabezeile ist */

				if (( qy_last >= slice_height ) && ( qy_prev >= 0 ))	/* ist die Scheibe zu klein? */
				{
					slice_height = qy_prev + 1;
					clip[3]--;												/* eine Zeile weniger ausgeben */
				}
			}

			vs_clip( vdi_handle, 1, clip );							/* Clipping-Rechteck setzen */

			src.fd_h = slice_height;

			if ( buf->planes == 1 )										/* nur ein Bit? */
				vrt_cpyfm( vdi_handle, 0x8001, raster, &src, &dst, color_index );	/* Scheibe ausgeben */
			else																/* Truecolor */
				vro_cpyfm( vdi_handle, 0x8003, raster, &src, &dst );	/* Scheibe ausgeben */
	
			raster[1] -= slice_height;
			raster[3] -= slice_height;

			clip[1] = clip[3] + 1;										/* erste auszugebende Zeile fÅr den nÑchsten Durchgang */
		}
	
		y1 += slice_height;
		y2 += slice_height;
		
		height -= slice_height;
	}
	
	return( 1 );
	
	#undef	qdy
	#undef	zdy
}	

/*----------------------------------------------------------------------------------------*/ 
/* Teil eines ESM-Bilds laden																					*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*	buf:						Bufferbeschreibung																*/
/*	y1:						erste einzulesende Zeile														*/
/*	y2:						letzte einzulesende Zeile														*/
/*----------------------------------------------------------------------------------------*/ 
WORD	ESM_read( PICTURE *pic, PIC_BUFFER *buf, WORD y1, WORD y2 )
{
	switch ( pic->head.esm->planes )
	{
		case	1:		return( ESM_read_1( pic, buf, y1, y2 ));
		case	8:		return( ESM_read_8( pic, buf, y1, y2 ));
		case	24:	return( ESM_read_24( pic, buf, y1, y2 ));
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Teil eines ESM-Bilds laden und von 1 in 32 Bit wandeln											*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*	buf:						Bufferbeschreibung																*/
/*	y1:						erste einzulesende Zeile														*/
/*	y2:						letzte einzulesende Zeile														*/
/*----------------------------------------------------------------------------------------*/ 
WORD	ESM_read_1( PICTURE *pic, PIC_BUFFER *buf, WORD y1, WORD y2 )
{
	ESM_HEAD	*head;
	WORD	width;
	LONG	offset;
	WORD	handle;
	
	head = pic->head.esm;
	handle = pic->file_handle;
	width = ( head->width + 7 ) / 8;									/* Bytes pro Zeile */
	
	offset = head->size + ((LONG) y1 * width );					/* Abstand zum Dateianfang */

	if ( Fseek( offset, (WORD) handle, 0 ) == offset )			/* erste auszulesende Zeile */
	{
		LONG	len;
		
		len = (LONG) ( y2 - y1 + 1 ) * width;						/* LÑnge des zu ladenden Bereichs */
		
		if ( Fread( handle, len, buf->addr ) == len )			/* Daten einlesen	*/
		{
			if ( width & 1 )												/* ungerade Breite? */
			{
				UBYTE	*bufb;
				UBYTE	*bufw;
				
				bufb = (UBYTE *) buf->addr + len;						/* Zeiger hinter die 24-Bit-Daten */
				
				bufw = (UBYTE *) buf->addr;
				bufw += (LONG) ( y2 - y1 + 1 ) * buf->width / 8;	/* Zeiger hinter die 32-Bit-Daten */
				
				while ( y1 <= y2 )
				{
					WORD	x;
					
					*( --bufw ) = 0;											/* Leerpixel */
					
					for ( x = 0; x < width; x++ )							/* je 8 Pixel kopieren */
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
WORD	ESM_read_8( PICTURE *pic, PIC_BUFFER *buf, WORD y1, WORD y2 )
{
	ESM_HEAD	*head;
	UBYTE	*red;
	UBYTE	*green;
	UBYTE	*blue;
	LONG	offset;
	WORD	handle;
	
	head = pic->head.esm;
	handle = pic->file_handle;
	red = head->red;
	green = head->green;
	blue = head->blue;
	
	offset = head->size + ((LONG) y1 * head->width );			/* Abstand zum Dateianfang */

	if ( Fseek( offset, (WORD) handle, 0 ) == offset )			/* erste auszulesende Zeile */
	{
		LONG	len;
		
		len = (LONG) ( y2 - y1 + 1 ) * head->width;				/* LÑnge des zu ladenden Bereichs */
		
		if ( Fread( handle, len, buf->addr ) == len )			/* Daten einlesen	*/
		{
			UBYTE	*buf8;
			UBYTE	*buf32;
			
			buf8 = (UBYTE *) buf->addr + len;						/* Zeiger hinter die 24-Bit-Daten */
			
			buf32 = (UBYTE *) buf->addr;
			buf32 += (LONG) ( y2 - y1 + 1 ) * buf->line_width;	/* Zeiger hinter die 32-Bit-Daten */
			
			while ( y1 <= y2 )
			{
				WORD	x;
				
				for ( x = head->width; x < buf->width; x++ )		/* unbenutzte Pixel weiû setzen */
					*(--(ULONG *) buf32 ) = 0x00ffffffL;
				
				for ( x = 0; x < head->width; x++ )					/* Pixel kopieren und von 24 auf 32 Bit erweitern */
				{
					UBYTE	index;
					
					index = *( --buf8 );
					*( --buf32 ) = blue[index];						/* blau */
					*( --buf32 ) = green[index];						/* grÅn */
					*( --buf32 ) = red[index];							/* rot */
					*( --buf32 ) = 0;										/* unbenutzt */
				}
				y1++;
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
WORD	ESM_read_24( PICTURE *pic, PIC_BUFFER *buf, WORD y1, WORD y2 )
{
	ESM_HEAD	*head;
	LONG	offset;
	WORD	handle;
	
	head = pic->head.esm;
	handle = pic->file_handle;

	offset = head->size + ((LONG) y1 * head->width * 3 );		/* Abstand zum Dateianfang */

	if ( Fseek( offset, (WORD) handle, 0 ) == offset )			/* erste auszulesende Zeile */
	{
		LONG	len;
		
		len = (LONG) ( y2 - y1 + 1 ) * head->width * 3;			/* LÑnge des zu ladenden Bereichs */
		
		if ( Fread( handle, len, buf->addr ) == len )			/* Daten einlesen	*/
		{
			UBYTE	*buf24;
			UBYTE	*buf32;
			
			buf24 = (UBYTE *) buf->addr + len;						/* Zeiger hinter die 24-Bit-Daten */
			
			buf32 = (UBYTE *) buf->addr;
			buf32 += (LONG) ( y2 - y1 + 1 ) * buf->width * 4;	/* Zeiger hinter die 32-Bit-Daten */
			
			while ( y1 <= y2 )
			{
				WORD	x;
				
				for ( x = head->width; x < buf->width; x++ )		/* unbenutzte Pixel weiû setzen */
					*(--(ULONG *) buf32 ) = 0x00ffffffL;
				
				for ( x = 0; x < head->width; x++ )					/* Pixel kopieren und von 24 auf 32 Bit erweitern */
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

/*----------------------------------------------------------------------------------------*/ 
/* Buffer anfordern																								*/
/* Funktionsresultat:	1: alles in Ordnung 0: Fehler													*/
/*	pic:						Bildbeschreibung																	*/
/*	buf:						Bufferbeschreibung																*/
/*----------------------------------------------------------------------------------------*/ 
WORD	open_buffer( PICTURE *pic, PIC_BUFFER *buf )
{
	LONG	available;
	
	buf->width = ( pic->width + 15 ) & 0xfff0;					/* Breite einer Bufferzeile in Pixeln (Vielfaches von 16) */

	if ( pic->planes == 1 )												/* monochrom? */
	{
		buf->line_width = buf->width / 8;
		buf->planes = 1;
	}
	else																		/* Bitmap wird als Truecolor-Bild verwaltet */
	{
		buf->line_width = buf->width * 4;							/* Breite einer Bufferzeile in Bytes */
		buf->planes = 32;
	}
		
	available = (LONG) Malloc( -1L );								/* Grîûe des verfÅgbaren Speichers */
	
	if ( available > RESERVE_FOR_DRIVER )							/* genÅgend Speicher vorhanden? */
	{
		available -= RESERVE_FOR_DRIVER;
		if ( available > MAX_BUF_SIZE )								/* grîûer als nîtig? */
			buf->len = MAX_BUF_SIZE;
		else
			buf->len = available;
	}
	else																		/* wenig Speicher */
		buf->len = (LONG) buf->width * 16;							/* nur 16 Zeilen fÅr den Buffer anfordern */

	if (( buf->len > 0 ) && ( buf->len <= available ))
	{
		buf->height = (WORD) ( buf->len / buf->line_width );	/* Hîhe des Buffers */
		buf->len = (LONG) buf->line_width * buf->height;		/* LÑnge korrigieren */
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
WORD	close_buffer( PIC_BUFFER *buf )
{
	if ( Mfree( buf->addr ) == 0 )									/* lÑût sich der Block freigeben? */
		return( 1 );
	else
		return( 0 );
}

void	print_main( BYTE *name )
{
	PICTURE	pic;
	
	if ( ESM_open( name, &pic ))										/* lÑût sich die Datei îffnen? */
	{
		PIC_BUFFER	buf;
		
		if ( open_buffer( &pic, &buf ))								/* genÅgend Speicher fÅr Buffer vorhanden? */
		{
			WORD	work_in[11];
			WORD	work_out[57];
			WORD	vdi_handle;
			WORD	tmp;
			WORD	i;
		
			for( i = 0; i < 10; i++ )
				work_in[i] = 1;

			work_in[0] = 21;
			work_in[10] = 2;
		
			vdi_handle = graf_handle( &tmp, &tmp, &tmp, &tmp );
			v_opnwk( work_in, &vdi_handle, work_out );

			if ( vdi_handle )												/* lÑût sich der Druckertreiber îffnen? */
			{
				WORD	extnd_out[57];
				
				vq_extnd( vdi_handle, 1, extnd_out );
	
				if ( extnd_out[4] == 32 )								/* Truecolor-Modus? */
				{
					if ( extnd_out[30] & 1 )							/* kann der Treiber skalieren? */
					{
						Cconws( "Starte Aufbereitung\r\n" );
						
						if ( ESM_output( &pic, &buf, 0, 0, pic.width * 2, pic.height * 2, vdi_handle ))
						{
							Cconws( "Starte Ausdruck von " );
							Cconws( name );
							Cconws( "\r\n" );
							
							v_updwk( vdi_handle );						/* Seite ausgeben */
							v_clrwk( vdi_handle );						/* Vorschub senden */
						}
					}
					else
						Cconws( "Ausdruck nicht mîglich: Treiber kann nicht skalieren.\r\n" );
				}		
				else
					Cconws( "Bitte den Treiber in den Halbton- oder Truecolor-Modus umschalten.\r\n" );

				v_clswk( vdi_handle );									/* Druckertreiber schlieûen */
			}
			else
				Cconws( "Druckertreiber konnte nicht geîffnet werden.\r\n" );
			
			close_buffer( &buf );										/* Buffer freigeben */
		}
		else
			Cconws( "Nicht genÅgend Speicher fÅr TemporÑrbuffer vorhanden.\r\n" );
		
		ESM_close( &pic );												/* Datei schlieûen */
	}
	else
		Cconws( "Konnte Bilddatei nicht îffnen.\r\n" );
}

main( WORD argc, BYTE *argv[] )
{
	Cconws( "Beispielprogramm fÅr Truecolor-Ausdruck mit NVDI\r\n" );
	
	if ( argc == 1 )
	{
		Cconws( "PRINT_TC druckt die Åbergebene ESM-Datei in\r\n" );
		Cconws( "doppelter Grîûe auf VDI-Treiber 21 aus.\r\n" );
		return( 0 );
	}		
				
	while ( argc > 1 )
	{
		argc--;
		
		print_main( argv[argc] );										/* Datei ausgeben */

	}

   return( 0 );
}
