/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDI.H>

#include	<ColorMap.h>
#include	<CBitmap.h>

#include	"EDDILIB.H"														/* fÅr fehlende VDI-Funktionen */

/*----------------------------------------------------------------------------------------*/
/* externe Funktionen																							*/
/*----------------------------------------------------------------------------------------*/
extern void	*Malloc_sys( int32 length );
extern int16	Mfree_sys( void *addr );	

/*----------------------------------------------------------------------------------------*/
/* Deklaration																										*/
/*----------------------------------------------------------------------------------------*/
int16	default_colors( int16 vdi_handle, COLOR_RGB *gslct );

int32	_get_device_format( int16 vdi_handle );

COLOR_MAP	*_create_cmap( int16 vdi_handle );
int16	_delete_cmap( COLOR_MAP *cmap );

INVERSE_CMAP	*_create_inverse_cmap( COLOR_MAP *cmap, int16 no_bits, int16 levels );
int16	_delete_inverse_cmap( INVERSE_CMAP *inverse_cmap );

static int16	system_colors[16][3] = 
{
	{ 1000, 1000, 1000 },
	{ 0, 0, 0 },
	{ 949, 0, 0 },
	{ 0, 902, 0 },
	{ 200, 0, 1000 },
	{ 98, 796, 733 },
	{ 1000, 1000, 0 },
	{ 902, 200, 600 },
	{ 843, 843, 843 },
	{ 502, 502, 502 },
	{ 502, 0, 0 },
	{ 0, 502, 0 },
	{ 0, 0, 502, },
	{ 0, 502, 502 },
	{ 714, 635, 224 },
	{ 502, 0, 502 }
};

int16	scale[7] = 
{
	953,
	902,
	753,
	702,
	502,
	302,
	102
};

int16	default_colors( int16 vdi_handle, COLOR_RGB *gslct )
{
	int32	no_colors;
	int16	work_out[272];
	int16	rgb_in[3];
	int16	index;
	
	vq_scrninfo( vdi_handle, work_out );							/* Pixelwerte erfragen */
	no_colors = *(int32 *) ( work_out + 3 );						/* Farbanzahl */

	for ( index = 0; index < 16; index++ )							/* neue Systemfarben, die fÅr besseres Dithern sorgen */
	{
		rgb_in[0] = system_colors[index][0];
		rgb_in[1] = system_colors[index][1];
		rgb_in[2] = system_colors[index][2];
		vs_color( vdi_handle, index, rgb_in );
	}

	if ( no_colors >= 256 )												/* 256 Farben oder Direct Color? */
	{
		int16	gslct_red;
		int16	gslct_green;
		int16	gslct_blue;
		int16	red;
		int16	green;
		int16	blue;
		int16	gray;
		
		if ( gslct )
		{
			gslct_red = (int16) (((int32) gslct->red + 6553 ) / 13107 ) * 200;	/* Farbe innerhalb des 6*6*6-WÅrfels auswÑhlen */
			gslct_green = (int16) (((int32) gslct->green + 6553 ) / 13107 ) * 200;
			gslct_blue = (int16) (((int32) gslct->blue + 6553 ) / 13107 ) * 200;
		}
		else																	/* Selektionsfarbe von Hellgrau: Voreinstellung */
		{
			gslct_red = 200;
			gslct_green = 200;
			gslct_blue = 600;
		}
		
		index = 16;

		for ( red = 0; red < 6; red++ )								/* VDI-Index 16 - 229: 6*6*6 FarbwÅrfel (ohne Schwarz und Weiû => 214 Farbtîne) */
		{
			for ( green = 0; green < 6; green++ )
			{
				for ( blue = 0; blue < 6; blue++ )
				{
					if ((( red != green ) || ( red != blue )) || (( red != 0 ) && ( red != 5 )))	/* nicht Schwarz und und nicht Weiû? */
					{
						rgb_in[0] = ( red * 1000 ) / 5;
						rgb_in[1] = ( green * 1000 ) / 5;
						rgb_in[2] = ( blue * 1000 ) / 5;
						if (( rgb_in[0] == gslct_red ) && ( rgb_in[1] == gslct_green ) && ( rgb_in[2] == gslct_blue )) /* Selektionsfarbe fÅr Hellgrau? */
						{
							rgb_in[0] = 0;
							rgb_in[1] = 0;
							rgb_in[2] = scale[2];
						}
						
						vs_color( vdi_handle, index, rgb_in );
						index++;
					}
				}
			}
		}

		for ( red = 0; red < 7; red++ )								/* VDI-Index 230 - 236: 7 Rottîne */
		{
			rgb_in[0] = scale[red];
			rgb_in[1] = 0;
			rgb_in[2] = 0;
			vs_color( vdi_handle, index, rgb_in );
			index++;
		}

		for ( green = 0; green < 7; green++ )						/* VDI-Index 237 - 243: 7 GrÅntîne */
		{
			rgb_in[0] = 0;
			rgb_in[1] = scale[green];
			rgb_in[2] = 0;
			vs_color( vdi_handle, index, rgb_in );
			index++;
		}

		for ( blue = 6; blue >= 0; blue-- )							/* VDI-Index 244 - 250: 6 Blautîne und die Selektionsfarbe */
		{
			if ( index == 248 )											/* Selektionsfarbe von Hellgrau? */
			{
				rgb_in[0] = gslct_red;
				rgb_in[1] = gslct_green;
				rgb_in[2] = gslct_blue;
			}
			else																/* Blauverlauf setzen */
			{
				rgb_in[0] = 0;
				rgb_in[1] = 0;
				rgb_in[2] = scale[blue];
			}
			vs_color( vdi_handle, index, rgb_in );
			index++;
		}

		for ( gray = 0; gray < 7; gray++ )							/* VDI-Index 251 - 255: 5 Grautîne (die 16 Systemfarben enhalten zwei weitere Grautîne) */
		{
			if (( scale[gray] != 502 ) && ( scale[gray] != 902 ))	/* Hellgrau und 50%grau werden aus den Systemfarben genommen */
			{
				rgb_in[0] = scale[gray];
				rgb_in[1] = scale[gray];
				rgb_in[2] = scale[gray];
				vs_color( vdi_handle, index, rgb_in );
				index++;
			}
		}
	}
	return( 1 );
}


int32	_get_device_format( int16 vdi_handle )
{
	int32	format;
	int16	work_out[272];
	
	vq_scrninfo( vdi_handle, work_out );							/* Pixelwerte erfragen */

	if (( work_out[0] == -1 ) && ( work_out[2] == 4 ))			/* VGA-Karte mit 4 separaten Ebenen? */
		format = PX_PLANES + PX_4BIT;
	else																		/* kein Sonderfall */
	{
		format = 0;
		format |= ((int32) work_out[0] ) << 16;					/* Pixelformat */
		format |= work_out[2];											/* Bits pro Pixel */
	}
	
	if ( work_out[2] <= 8 )
	{
		format |= PX_1COMP;												/* 1 Komponente pro Pixel */
		format |= work_out[2] << 8;									/* benutzte Bits pro Pixel */
	}
	else																		/* Direct Color */
	{
		int16	used_bits;
		int16	red_bits;
		int16	green_bits;
		int16	blue_bits;
		
		red_bits = work_out[8];
		green_bits = work_out[9];
		blue_bits = work_out[10];
		
		used_bits = red_bits + green_bits + blue_bits;			/* benutzte Bits pro Pixel */

		if ( work_out[16 + red_bits - 1] < work_out[48 + blue_bits - 1] )	/* umdrehte Bytereihenfolge? */
		{
			format |= PX_REVERSED;
		
			if ( used_bits < work_out[2] )
				format |= PX_xFIRST;										/* unbenutze Bits stehen vor den Farbwerten */
		}
		else																	/* normale Bytereihenfolge */
		{
			if ( work_out[16 + red_bits - 1] < ( work_out[2] - 1 ))
				format |= PX_xFIRST;										/* unbenutze Bits stehen vor den Farbwerten */
			else if ( used_bits == 15 )								/* Geier? */
				used_bits = 16;											/* wie rrrr rggg gggb bbbb behandeln */
		}

		format |= PX_3COMP;												/* 3 Farbkomponenten pro Pixel */
		format |= used_bits << 8;										/* benutzte Bits pro Pixel */
	}

	return( format );
}

/*----------------------------------------------------------------------------------------*/
/* Farbpalette erzeugen																							*/
/* Funktionsresultat:	Zeiger auf Farbpalette oder 0L 												*/
/*	vdi_handle:				...																					*/
/*----------------------------------------------------------------------------------------*/
COLOR_MAP	*_create_cmap( int16 vdi_handle )
{
	COLOR_MAP	*cmap;
	int32	length;
	int32	no_colors;
	int16	work_out[272];
	
	vq_scrninfo( vdi_handle, work_out );							/* Pixelwerte erfragen */
	no_colors = *(int32 *) ( work_out + 3 );						/* Farbanzahl */
	
	if (( no_colors == 0 ) || ( no_colors > 256 ))				/* Direct Color, Dummy-Palette erzeugen? */
	{
		int16	i;

		for ( i = 0; i < 256; i++ )
			work_out[16 + i] = i;
			
		no_colors = 256;
	}

	length = sizeof( COLOR_MAP ) + ( no_colors * sizeof( COLOR_ENTRY ));
	cmap = Malloc_sys( length );
	
	if ( cmap )
	{
		cmap->magic = 'cmap';
		cmap->length = length;											/* LÑnge der Farbtabelle */
		cmap->format = 0;
		cmap->reserved = 0;
		
		cmap->map_id = 0;
		cmap->color_space = CSPACE_RGB;
		cmap->flags = CSPACE_3COMPONENTS;
		cmap->no_colors = no_colors;									/* Anzahl der Farben */

		cmap->reserved1 = 0;
		cmap->reserved2 = 0;
		cmap->reserved3 = 0;
		cmap->reserved4 = 0;
		
		while ( no_colors > 0 )
		{
			int16	rgb_out[3];
			COLOR_ENTRY	*entry;
			int16	value;

			no_colors--;
			vq_color( vdi_handle, (int16) no_colors, 1, rgb_out ); 
			value = work_out[16 + no_colors];						/* Pixelwert */

			entry = cmap->colors + value;								/* Eintrag in der Farbtabelle */
			entry->rgb.red = (((int32) rgb_out[0] << 8 ) - rgb_out[0] ) / 1000L;
			entry->rgb.red += entry->rgb.red << 8;
			entry->rgb.green = (((int32) rgb_out[1] << 8 ) - rgb_out[1] ) / 1000L;
			entry->rgb.green += entry->rgb.green << 8;
			entry->rgb.blue = (((int32) rgb_out[2] << 8 ) - rgb_out[2] ) / 1000L;
			entry->rgb.blue += entry->rgb.blue << 8;
			entry->rgb.reserved = value;
		}
	}

	return( cmap );
}

/*----------------------------------------------------------------------------------------*/
/* Speicher fÅr Farbpalette freigeben																		*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	cmap:						Zeiger auf Farbpalette															*/
/*----------------------------------------------------------------------------------------*/
int16	_delete_cmap( COLOR_MAP *cmap )
{
	if ( cmap && ( cmap->magic == 'cmap' ))
	{
		cmap->magic = 0L;
		Mfree_sys( cmap );
		return( 1 );
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/
/* Inverse Farbpalette zur Åbergeben Farbpalette aufbauen											*/
/* Funktionsresultat:	Zeiger auf INVERSE_CMAP oder 0L im Fehlerfall							*/
/*	cmap:						Farbpalette																			*/
/*	no_bits:					Bits pro Farbkomponente	(1 <= no_bits <= 5)								*/
/*	levels:					Anzahl der Abstufungen pro Farbkomponente (levels <= 2^no_bits)	*/
/*																														*/
/*																														*/
/*	Der Algorithmus basiert auf inkrementeller Distanzbestimmung (Spencer W. Thomas, 		*/
/*	Graphic GEMS II, Kapitel iii.1).																			*/
/*																														*/
/*	Bekannte Probleme:																							*/
/*	-	das Laufzeitverhalten entspricht O * ( no_colors * 2^(3*no_bits))							*/
/*	-	die inverse Farbpalette enthÑlt ÅbermÑûig viele Grautîne, weil Farben im Inneren 	*/
/*		des FarbwÅrfels (insbesondere Grautîne) gegenÅber denen in den Randbereichen			*/
/*		bevorzugt werden (u.a. weil der Mittelpunkt einer Zelle fÅr die Distanzberechnung	*/
/*		benutzt wird)																								*/
/*	-	keine Farbpriorisierung mîglich																		*/
/*	-	Graustufenpaletten werden nicht unterstÅtzt														*/
/*	-	Das Verfahren liefert keine Liste der "versteckten" Farben									*/
/*																														*/
/*	Tips:																												*/
/*	-	diese Funktion sollte bei hÑufiger Benutzung nur mit no_bits <= 4 aufgerufen werden	*/
/*																														*/
/*	Hinweis:																											*/
/* Die nÑchste NVDI-Version wird eine Funktion mit Ñhnlichen Parametern enthalten, die		*/
/*	um ein Vielfaches schneller ist, Vergrauung vermeidet und alle Abstufungen auflîsen		*/
/*	kann. _create_inverse_cmap() sollte nur aufgrufen werden, wenn das VDI keine Funktion	*/
/*	anbietet.																										*/
/*																														*/
/*----------------------------------------------------------------------------------------*/
INVERSE_CMAP	*_create_inverse_cmap( COLOR_MAP *cmap, int16 no_bits, int16 levels )
{
	INVERSE_CMAP	*inverse_cmap;
	int32	no_entries;
	
	no_entries = (int32) levels * levels * levels;

	inverse_cmap = Malloc_sys( sizeof( INVERSE_CMAP ) + no_entries );

	if ( inverse_cmap )
	{
		uint32	*dist_buf;

		inverse_cmap->magic = 'imap';
		inverse_cmap->length = sizeof( INVERSE_CMAP ) + no_entries;
		inverse_cmap->format = 0;
		inverse_cmap->reserved = 0;

		inverse_cmap->map_id = 0;
		inverse_cmap->no_bits = no_bits;								/* Bits pro Komponente */
		inverse_cmap->levels = levels;								/* Abstufungen pro Komponente */
		inverse_cmap->flags = CSPACE_3COMPONENTS;					/* Farbmodell mit 3 Komponenten */
		inverse_cmap->no_colors = cmap->no_colors;				/* Anzahl der in <values> verwendeten Farben (kann bei diesem Verfahren nicht bestimmt werden, daher cmap->no_colors) */

		inverse_cmap->reserved1 = 0;
		inverse_cmap->reserved2 = 0;
		inverse_cmap->reserved3 = 0;
		inverse_cmap->no_hidden_values = 0;							/* keine Ñhnlichen Farben */

		dist_buf = Malloc_sys( sizeof( uint32 ) * no_entries );	/* Abstandsbuffer */
	
		if ( dist_buf )
		{
			uint32	*distances;
			uint8		*values;
			int32		txsqr;
			int32		x;
			int16		value;

			x = 256 / levels;												/* SeitenlÑnge einer Farbzelle */
			txsqr = ( 2 * 65536L ) / ( levels * levels );		/* 2 * (( x / levels )^2 ) */
		
			distances = dist_buf;
			while ( no_entries > 0 )									/* Abstandbuffer vorbesetzten */
			{
				*distances++ = 0x7fffffffL;
				no_entries--;
			}

			for ( value = 0; value < cmap->no_colors; value++ )	/* fÅr jede Farbe den gesamten WÅrfel untersuchen */
			{
				int32	rdist;
				int32	gdist;
				int32	bdist;
				int32	rinc;
				int32	ginc;
				int32	binc;
				int32	rxx;
				int32	gxx;
				int32	bxx;
				int32	r;
				int32	g;
				int32	b;
		
				r = cmap->colors[value].rgb.red >> 8;
				g = cmap->colors[value].rgb.green >> 8;
				b = cmap->colors[value].rgb.blue >> 8;
				
				rdist = r - x / 2;										/* von der Mitte der Farbzelle ausgehen */
				gdist = g - x / 2;
				bdist = b - x / 2;
				rdist = rdist * rdist + gdist * gdist + bdist * bdist;
		
				rinc = txsqr - (( r << 9 ) / levels );
				ginc = txsqr - (( g << 9 ) / levels );
				binc = txsqr - (( b << 9 ) / levels );
				distances = dist_buf;
				values = inverse_cmap->values;
		
				for ( r = 0, rxx = rinc; r < levels; rdist += rxx, r++, rxx += txsqr )
				{
					for ( g = 0, gdist = rdist, gxx = ginc; g < levels; gdist += gxx, g++, gxx += txsqr )
					{
						for ( b = 0, bdist = gdist, bxx = binc; b < levels; bdist += bxx, b++, distances++, values++, bxx += txsqr )
						{
							if ( *distances > bdist )
					  		{
								*distances = bdist;						/* Quadrat des Abstands */
								*values = value;							/* den Pixelwert fÅr diesen Index eintragen */
							}
						}
					}
				}
			}

			Mfree_sys( dist_buf );
		}
		else
		{
			Mfree_sys( inverse_cmap );
			inverse_cmap = 0L;
		}
	}
	return( inverse_cmap );
}

/*----------------------------------------------------------------------------------------*/
/* Speicher fÅr inverse Farbpalette freigeben															*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	inverse_cmap:			Zeiger auf inverse Farbpalette												*/
/*----------------------------------------------------------------------------------------*/
int16	_delete_inverse_cmap( INVERSE_CMAP *inverse_cmap )
{
	if ( inverse_cmap && ( inverse_cmap->magic == 'imap' ))
	{
		inverse_cmap->magic = 0L;
		Mfree_sys( inverse_cmap );
		return( 1 );
	}
	return( 0 );
}