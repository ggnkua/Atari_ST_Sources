/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>
#include <PORTAB.H>
#include	<TOS.H>
#include <VDI.H>
#include	<VDICOL.H>														/* neue Farbdefinitionen des VDI */
#include	<MT_AES.H>

#include <stdio.h>
#include	<string.h>

/*----------------------------------------------------------------------------------------*/
/* Ordered Dither																									*/
/*----------------------------------------------------------------------------------------*/
extern void		*open_dither( int32 config, CTAB_REF ctab, ITAB_REF inverse_ctab );
extern int16	close_dither( void *dither_blk );

extern void		do_dither( void *dither_blk, int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
								  int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2 );

/*----------------------------------------------------------------------------------------*/
/* Floyd-Steinberg																								*/
/*----------------------------------------------------------------------------------------*/
extern void		*open_floyd( int16 xmax, int32 config, CTAB_REF ctab, ITAB_REF inverse_ctab );
extern void		init_floyd( void *dither_blk );
extern int16	close_floyd( void *dither_blk );

extern void		do_floyd( void *dither_blk, int32 *src, uint8 *buf, int32 src_width, int32 buf_width,
								 int16 dst_x1, int16 dst_y1, int16 dst_x2, int16 dst_y2 );

/*----------------------------------------------------------------------------------------*/
/* Funktionen fÅr Formatumwandlung																			*/
/*----------------------------------------------------------------------------------------*/
extern void	init_transform8( void );
extern int16	transform8( int32 dx, int32 dy, int32 dst_format, void *src, void *dst, int32 src_width, int32 dst_width );
extern int16	transform32( int32 dx, int32 dy, int32 dst_format, void *src, void *dst, int32 src_width, int32 dst_width );

extern int32	plane2packed32( int32 no_words, int32 plane_length, int16 no_planes, void *src, void *dst, CTAB_REF src_ctab ); 
extern int32	packed2packed32( int32 word_cnt, int32 dummy, int16 no_planes, void *src, void *dst, CTAB_REF src_ctab ); 

/*----------------------------------------------------------------------------------------*/
/* Funktionen fÅr die Verwaltung der Farbpalette														*/
/*----------------------------------------------------------------------------------------*/
extern int16		default_colors( int16 vdi_handle, COLOR_RGB *gslct );
extern int32		_get_device_format( int16 vdi_handle );
extern CTAB_REF	_create_ctab( int16 vdi_handle );
extern int16		_delete_ctab( CTAB_REF ctab );
extern ITAB_REF	_create_inverse_ctab( CTAB_REF ctab, int16 no_bits, int16 levels );
extern int16		_delete_inverse_ctab( ITAB_REF inverse_ctab );

/*----------------------------------------------------------------------------------------*/
extern void	*Malloc_sys( int32 length );
extern int16	Mfree_sys( void *addr );


/*----------------------------------------------------------------------------------------*/
#define	USE_FLOYD	1													/* 0: Ordered Dither 1: Floyd Steinberg */
#define	USE_DEFAULT_COLORS	0										/* 0: Palette Åbernehemen 1: Palette setzen */
#define	DITHER_SINGLE_LINES	1										/* 0: komplettes Bild dithern und danach ausgeben;
																						das Quellbild wird zerstîrt
																					1: jede Zeile dithern und sofort ausgeben;
																						das Quellbild wird nicht verÑndert */

/*----------------------------------------------------------------------------------------*/
/* Vektoren fÅr VDI-Emulation																					*/
/*----------------------------------------------------------------------------------------*/

/* Farbtabellen */
int16		(*FP_vq_ctab)( int16 handle, int32 ctab_length, COLOR_TAB *ctab );
int32		(*FP_v_get_ctab_id)( int16 handle );

/* inverse Farbtabellen */
ITAB_REF	(*FP_v_create_itab)( int16 handle, COLOR_TAB *ctab, int16 bits );
int16		(*FP_v_delete_itab)( int16 handle, ITAB_REF itab );


/* Bitmapausgabe */
void	(*FP_vr_transfer_bits)( int16 handle, GCBITMAP *_src_bm, GCBITMAP *_dst_bm,
								int16 *src_rect, int16 *dst_rect,
								int16 mode );


/*----------------------------------------------------------------------------------------*/
/* Funktionen fÅr VDI-Emulation																				*/
/*----------------------------------------------------------------------------------------*/

int16	RK_init( int16 vdi_handle );
int16	RK_reset( int16 vdi_handle );

int16	RK_vq_ctab( int16 handle, int32 ctab_length, COLOR_TAB *ctab );
int32	RK_v_get_ctab_id( int16 handle );

ITAB_REF	RK_v_create_itab( int16 handle, COLOR_TAB *ctab, int16 bits );
int16	RK_v_delete_itab( int16 handle, ITAB_REF itab );

void	RK_vr_transfer_bits( int16 handle, GCBITMAP *_src_bm, GCBITMAP *_dst_bm,
								int16 *src_rect, int16 *dst_rect,
								int16 mode );




static int16	mode2logic( int16 mode );
static int16	mode2wr( int16 mode, int16 *fg, int16 *bg );
static void	dither_bits( int16 handle, GCBITMAP *src_bm, GCBITMAP *dst_bm,
						 int16 *src_rect, int16 *dst_rect,
						 int16 mode );


static int16		extnd_out[57];
static GCBITMAP	screen;												/* Bitmapbeschreibung des Bildschirms */
static int32		map_id = 1024;

static int16	mode2logic( int16 mode )
{	
	static uint8	convert_logic_mode[8] =
	{
		3,																		/* T_LOGIC_COPY */
		7,																		/* T_LOGIC_OR */
		6,																		/* T_LOGIC_XOR */
		1,																		/* T_LOGIC_AND */
		12,																	/* T_LOGIC_NOT_COPY */
		13,																	/* T_LOGIC_NOT_OR */
		9,																		/* T_LOGIC_NOT_XOR */
		4																		/* T_LOGIC_NOT_AND */
	};
	
	static uint8	convert_draw_mode[4] =
	{
		3,																		/* T_REPLACE */
		7,																		/* T_TRANSPARENT */
		6,																		/* T_HILITE */
		4																		/* T_REVERS_TRANSPARENT */
	};

	mode &= T_ARITH_MODE | T_DRAW_MODE | 15;
	
	if ( mode <= 7 )
		mode = convert_logic_mode[mode];
	else if (( mode >= T_REPLACE ) && ( mode <= T_REVERS_TRANSPARENT ))
		mode = convert_draw_mode[mode & 3];
	else
		mode = 3;															/* alle anderen Modi kînnen wir nicht nachbilden */

	return( mode );
}

static int16	mode2wr( int16 mode, int16 *fg, int16 *bg )
{	
	typedef struct
	{
		int8	mode;
		int8	fg;
		int8	bg;
	} WMODE_CONV;

	static WMODE_CONV	convert_logic_mode[8] =
	{
		{ 1, 1, 0 },														/* T_LOGIC_COPY */
		{ 2, 1, 0 },														/* T_LOGIC_OR */
		{ 3, 1, 0 },														/* T_LOGIC_XOR */
		{ 4, 1, 0 },														/* T_LOGIC_AND */
		{ 1, 0, 1 },														/* T_LOGIC_NOT_COPY */
		{ 4, 0, 1 },														/* T_LOGIC_NOT_OR */
		{ 3, 0, 1 },														/* T_LOGIC_NOT_XOR */
		{ 2, 0, 1 }															/* T_LOGIC_NOT_AND */
	};
	
	static WMODE_CONV	convert_draw_mode[4] =
	{
		{ 1, 1, 0 },														/* T_REPLACE */
		{ 2, 1, 0 },														/* T_TRANSPARENT */
		{ 3, 1, 0 },														/* T_HILITE */
		{ 4, 0, 1 }															/* T_REVERS_TRANSPARENT */
	};

	mode &= T_ARITH_MODE | T_DRAW_MODE | 15;
	
	if ( mode <= 7 )
	{
		mode = convert_logic_mode[mode].mode;
		*fg = convert_logic_mode[mode].fg;
		*bg = convert_logic_mode[mode].bg;
	}	
	else if (( mode >= T_REPLACE ) && ( mode <= T_REVERS_TRANSPARENT ))
	{
		mode &= 3;
		mode = convert_draw_mode[mode].mode;
		*fg = convert_draw_mode[mode].fg;
		*bg = convert_draw_mode[mode].bg;
	}
	else
	{
		mode = 1;															/* alle anderen Modi kînnen wir nicht nachbilden */
		*fg = 1;
		*bg = 0;
	}
	
	return( mode );
}

/*----------------------------------------------------------------------------------------*/ 
/*	Emulation von TRANSFER BITMAP; es wird entweder gedithert oder gehofft, daû die			*/
/* Systemfarben eingestellt sind																				*/
/* Funktionsresultat:	-																						*/
/*	handle:					VDI-Handle																			*/
/*	src_bm:					Quellbitmap oder 0L fÅr die GerÑtebitmap									*/
/*	dstbm:					Zielbitmap oder 0L fÅr die GerÑtebitmap									*/
/*	src_rect:				Quellrechteck																		*/
/*	dst_rect:				Zielrechteck																		*/
/*	mode:						VerknÅpfung																			*/
/*----------------------------------------------------------------------------------------*/ 
void	RK_vr_transfer_bits( int16 handle, GCBITMAP *_src_bm, GCBITMAP *_dst_bm,
								int16 *src_rect, int16 *dst_rect,
								int16 mode )
{
	if ((( mode & T_DITHER_MODE ) == 0 ) || ( _src_bm->bits == 1 ))	/* ohne Dithern? */
	{
		GCBITMAP	*src_bm;
		GCBITMAP	*dst_bm;
		MFDB	src_mfdb;
		MFDB	dst_mfdb;
		int16	xy[8];

		src_bm = _src_bm;
		dst_bm = _dst_bm;

		if ( src_bm == 0L )
			src_bm = &screen;

		if ( dst_bm == 0L )
			dst_bm = &screen;

		src_mfdb.fd_addr = src_bm->addr;								/* MFDB fÅr den Quellblock besetzen */
		src_mfdb.fd_w = src_bm->xmax - src_bm->xmin;
		src_mfdb.fd_h = 1;
		src_mfdb.fd_wdwidth = ( src_bm->width / src_bm->bits ) >> 1;
		src_mfdb.fd_stand = 0;
		src_mfdb.fd_nplanes = src_bm->bits;
	
		dst_mfdb.fd_addr = dst_bm->addr;								/* MFDB fÅr den Zielblock besetzen */
		dst_mfdb.fd_w = dst_bm->xmax - dst_bm->xmin;
		dst_mfdb.fd_h = 1;
		dst_mfdb.fd_wdwidth = ( dst_bm->width / dst_bm->bits ) >> 1;
		dst_mfdb.fd_stand = 0;
		dst_mfdb.fd_nplanes = dst_bm->bits;
	
		xy[0] = src_rect[0];												/* Quellrechteck */
		xy[1] = src_rect[1];
		xy[2] = src_rect[2];
		xy[3] = src_rect[3];
	
		xy[4] = dst_rect[0];												/* Zielrechteck */
		xy[5] = dst_rect[1];
		xy[6] = dst_rect[2];
		xy[7] = dst_rect[3];

		if ( src_bm->px_format == dst_bm->px_format )			/* identisches Pixelformat? */
		{
			mode = mode2logic( mode );
			vro_cpyfm( handle, mode, xy, &src_mfdb, &dst_mfdb );	/* hoffentlich stimmt die Farbtabelle ... */
			return;
		}
		else if ( src_bm->bits == 1 )									/* monochrom? */
		{
			int16	color_idx[2];

			mode = mode2wr( mode, &color_idx[0], &color_idx[1] );
			vrt_cpyfm( handle, mode, xy, &src_mfdb, &dst_mfdb, color_idx );	/* Farbtabelle ignorieren */
			return;
		}
	}
	
	dither_bits( handle, _src_bm, _dst_bm, src_rect, dst_rect, mode );	/* dithern */
}

/*----------------------------------------------------------------------------------------*/ 
/*	Dither-Emulation fÅr TRANSFER BITMAP (diverse EinschrÑnkungen ...)							*/
/* Funktionsresultat:	-																						*/
/*	handle:					VDI-Handle																			*/
/*	src_bm:					Quellbitmap oder 0L fÅr die GerÑtebitmap									*/
/*	dstbm:					Zielbitmap oder 0L fÅr die GerÑtebitmap									*/
/*	src_rect:				Quellrechteck																		*/
/*	dst_rect:				Zielrechteck																		*/
/*	mode:						VerknÅpfung																			*/
/*----------------------------------------------------------------------------------------*/ 
static void	dither_bits( int16 handle, GCBITMAP *src_bm, GCBITMAP *dst_bm,
								 int16 *src_rect, int16 *dst_rect,
								 int16 mode )
{
	void	*dither_blk;
	MFDB	src_mfdb;
	MFDB	dst_mfdb;
	int32	dither_buf_width;
	uint8	*dither_buf;
	int32	transform_buf_width;
	uint8	*transform_buf;
	int16	xy[8];

	uint8	*src_addr;
	int32	src_width;
	int32	src_height;

	int32	height;
	int32	y;
	int32	src_y1;
	
	if ( src_bm == 0L )
		return;																/* der Bildschirm ist in der Emulation nicht als Quelle erlaubt */

	if ( dst_bm == 0L )													/* ist der Bildschirm das Ziel? */
		dst_bm = &screen;

	mode = mode2logic( mode );											/* Modus in logischen Modus fÅr vro_cpyfm() wandeln */

	src_y1 = src_rect[1] - src_bm->ymin;							/* Startzeile relativ zur ersten Zeile der Quellbitmap */
	src_width = src_bm->xmax - src_bm->xmin;						/* Breite der Quellbitmap */
	src_height = src_bm->ymax - src_bm->ymin;						/* Hîhe der Quellbitmap */
	src_addr = (uint8 *) src_bm->addr + ( src_y1 * src_bm->width );	/* Startadresse fÅr den Zugriff auf die Quellbitmap */

	height = dst_rect[3] - dst_rect[1] + 1;						/* Anzahl der auszugebenden Zeilen */

	dither_buf_width = ( src_width + 15 ) & ~15L;
	dither_buf_width <<= 2;												/* 4 Bytes pro Pixel  */
	dither_buf = Malloc_sys( dither_buf_width );					/* Buffer fÅr das Dithern */

	if ( dither_buf == 0L )
		return;

	transform_buf_width = ((( src_width + 15 ) & ~15L ) * dst_bm->bits ) >> 3;
	transform_buf = Malloc_sys( transform_buf_width );			/* Buffer fÅr das Transformieren */

	if ( transform_buf == 0L )
	{
		Mfree_sys( dither_buf );
		return;
	}

	src_mfdb.fd_addr = (void *) transform_buf;					/* MFDB fÅr die Quelle aufbauen */
	src_mfdb.fd_w = ( src_width + 15 ) & ~15L;
	src_mfdb.fd_h = 1;
	src_mfdb.fd_wdwidth = src_mfdb.fd_w >> 4;
	src_mfdb.fd_stand = 0;
	src_mfdb.fd_nplanes = dst_bm->bits;

	dst_mfdb.fd_addr = dst_bm->addr;									/* MFDB fÅr das Ziel aufbauen */
	dst_mfdb.fd_w = ( dst_bm->xmax - dst_bm->xmin + 15 ) & ~15L;
	dst_mfdb.fd_h = 1;
	dst_mfdb.fd_wdwidth = dst_mfdb.fd_w >> 4;
	dst_mfdb.fd_stand = 0;
	dst_mfdb.fd_nplanes = dst_bm->bits;

	xy[0] = 0;
	xy[1] = src_rect[0];
	xy[2] = src_rect[2];
	xy[3] = 0;

	xy[4] = dst_rect[0];
	xy[5] = dst_rect[1];
	xy[6] = dst_rect[2];
	xy[7] = dst_rect[1];

	if ( dst_bm->bits <= 8 )											/* muû gedithert werden? */
	{
		dither_blk = open_floyd( src_width - 1, 0, dst_bm->ctab, dst_bm->itab );	/* Speicher anfordern */

		if ( dither_blk == 0L )
		{
			Mfree_sys( transform_buf );								/* Buffer fÅr Transformation freigeben */
			Mfree_sys( dither_buf );									/* Buffer fÅrs Dithern freigeben */
			return;
		}
	}

	if (( src_bm->px_format & PX_PACKING ) == PX_PLANES )		/* einzelne Planes? */
	{
		int32	src_words;
		int32	src_mono_width;
		int32	src_plane_length;
		
		src_mono_width = src_bm->width / src_bm->bits;			/* LÑnge einer monochromen Zeile */
		src_words = src_mono_width >> 1;								/* Worte pro Zeile */
		src_plane_length = ( src_bm->width * ( src_bm->ymax - src_bm->ymin )) / src_bm->bits;

		for ( y = 0; y < height; y++, src_y1++ )
		{
			if (( src_y1 >= 0 ) && ( src_y1 < src_height ))		/* y-Quellkoordinate innerhalb des Quellbuffers? */
			{
				plane2packed32( src_words, src_plane_length, src_bm->bits, src_addr, dither_buf, src_bm->ctab );

				if ( dst_bm->bits <= 8 )
				{
					do_floyd( dither_blk, (int32 *) dither_buf, dither_buf, dither_buf_width, dither_buf_width, 0, 0, src_width - 1, 0 );
					transform8( src_width - 1, 0, dst_bm->px_format, dither_buf, transform_buf, dither_buf_width, transform_buf_width );	/* Pixelformat wandeln */
				}
				else
					transform32( src_width - 1, 0, dst_bm->px_format, dither_buf, transform_buf, dither_buf_width, transform_buf_width );

				vro_cpyfm( handle, mode, xy, &src_mfdb, &dst_mfdb );	/* Zeile auf den Schirm kopieren */
			}

			src_addr += src_mono_width;								/* nÑchste Quellzeile */
			xy[5]++;															/* nÑchste Zielzeile */
			xy[7]++;
		}
	}
	else																		/* hoffentlich Packed */
	{
		if ( src_bm->bits <= 8 )
		{
			for ( y = 0; y < height; y++, src_y1++ )
			{
				if (( src_y1 >= 0 ) && ( src_y1 < src_height ))	/* y-Quellkoordinate innerhalb des Quellbuffers? */
				{
					packed2packed32( src_bm->width >> 2, 0, src_bm->bits, src_addr, dither_buf, src_bm->ctab ); 

					if ( dst_bm->bits <= 8 )
					{
						do_floyd( dither_blk, (int32 *) dither_buf, dither_buf, dither_buf_width, dither_buf_width, 0, 0, src_width - 1, 0 );
						transform8( src_width - 1, 0, dst_bm->px_format, dither_buf, transform_buf, dither_buf_width, transform_buf_width );	/* Pixelformat wandeln */
					}
					else
						transform32( src_width - 1, 0, dst_bm->px_format, dither_buf, transform_buf, dither_buf_width, transform_buf_width );

					vro_cpyfm( handle, mode, xy, &src_mfdb, &dst_mfdb );	/* Zeile auf den Schirm kopieren */
				}
				src_addr += src_bm->width;								/* nÑchste Quellzeile */
				xy[5]++;														/* nÑchste Zielzeile */
				xy[7]++;
			}
		}
		else																	/* hoffentlich 32 Bit */
		{
			for ( y = 0; y < height; y++, src_y1++ )
			{
				if (( src_y1 >= 0 ) && ( src_y1 < src_height ))	/* y-Quellkoordinate innerhalb des Quellbuffers? */
				{
					if ( dst_bm->bits <= 8 )
					{
						do_floyd( dither_blk, (int32 *) src_addr, dither_buf, src_bm->width, dither_buf_width, 0, 0, src_width - 1, 0 );
						transform8( src_width - 1, 0, dst_bm->px_format, dither_buf, transform_buf, dither_buf_width, transform_buf_width );	/* Pixelformat wandeln */
					}
					else
						transform32( src_width - 1, 0, dst_bm->px_format, src_addr, transform_buf, src_bm->width, transform_buf_width );

					vro_cpyfm( handle, mode, xy, &src_mfdb, &dst_mfdb );	/* Zeile auf den Schirm kopieren */
				}

				src_addr += src_bm->width;								/* nÑchste Quellzeile */
				xy[5]++;														/* nÑchste Zielzeile */
				xy[7]++;
			}
		}
	}
		
	if ( dst_bm->bits <= 8 )
		close_floyd( dither_blk );

	Mfree_sys( transform_buf );										/* Buffer fÅr Transformation freigeben */
	Mfree_sys( dither_buf );											/* Buffer fÅrs Dithern freigeben */
}


/*----------------------------------------------------------------------------------------*/ 
/*	INQUIRE CURRENT COLOR TABLE																				*/
/* Eingestellte Farbtabelle erfragen																		*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	handle:					VDI-Handle																			*/
/* ctab_length:			LÑnge des Buffers fÅr die Farbtabelle										*/
/*	ctab:						Buffer fÅr die Farbtabelle														*/
/*----------------------------------------------------------------------------------------*/ 
int16	RK_vq_ctab( int16 handle, int32 ctab_length, COLOR_TAB *ctab )
{
	if ( ctab_length >= screen.ctab->length )
	{
		memcpy( ctab, screen.ctab, screen.ctab->length );		/* Farbtabelle des Bildschirms kopieren */
		return( 1 );
	}
	else
		return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* GET UNIQUE COLOR TABLE ID																					*/
/* Eindeutige Kennung fÅr eine eigene oder verÑnderte Farbtabelle zurÅckliefern				*/
/* Funktionsresultat:	Farbtabellenkennung																*/
/*	handle:					VDI-Handle																			*/
/*----------------------------------------------------------------------------------------*/ 
int32	RK_v_get_ctab_id( int16 handle )
{
	map_id++;
	return( map_id ); 
}

/*----------------------------------------------------------------------------------------*/ 
/*	CREATE INVERSE COLOR TABLE REFERENCE (VDI 208, 0)													*/
/*	Inverse Farbtabelle einer Åbergebenen Farbtabelle erstellen										*/
/* Funktionsresultat:	Referenz auf inverse Farbtabelle oder 0L (Fehler)						*/
/*	handle:					VDI-Handle																			*/
/*	ctab:						Zeiger auf Farbtabelle															*/
/*	bits:						bevorzugte Auflîsung der inversen Farbtabelle							*/
/*								(sinnvollerweise 4 oder 5 Bits [pro Komponente])						*/
/*----------------------------------------------------------------------------------------*/ 
ITAB_REF	RK_v_create_itab( int16 handle, COLOR_TAB *ctab, int16 bits )
{
	ITAB_REF	itab;
	int16	levels;
		
#if	USE_FLOYD
	bits = 3;																/* nur 3 Bit, damit die inverse Farbtabelle schnell aufgebaut wird */
	levels = 8;
#else
	if ( ctab->no_colors == 256 )
	{
		bits = 3;
		levels = 6;															/* 6 * 6 * 6 EintrÑge */
	}	
	else																		/* 8 oder weniger Farben */
	{
		bits = 1;
		levels = 2;
	}	
#endif
	itab = _create_inverse_ctab( ctab, bits, levels );

	return( itab );
}

/*----------------------------------------------------------------------------------------*/ 
/*	DELETE INVERSE COLOR TABLE REFERENCE (VDI 208, 1)													*/
/*	Inverse Farbtabelle einer Åbergebenen Farbtabelle erstellen										*/
/* Funktionsresultat:	0: Fehler 1: alles in Ordnung													*/
/*	handle:					VDI-Handle																			*/
/*	itab:						Referenz auf inverse Farbtabelle												*/
/*----------------------------------------------------------------------------------------*/ 
int16	RK_v_delete_itab( int16 handle, ITAB_REF itab )
{
	return( _delete_inverse_ctab( itab ));							/* Speicher freigeben */
}



/*----------------------------------------------------------------------------------------*/
/* Workstation îffnen, Farbpalette und inverse Farbpalette erzeugen								*/
/* Funktionsresultat:	VDI-Handle oder 0 als Fehlernummer											*/
/*	aes_handle:				VDI-Handle des AES																*/
/*	ctab:						Farbpalette																			*/
/*	inverse_ctab:			inverse Farbpalette																*/
/*----------------------------------------------------------------------------------------*/
int16	RK_init( int16 vdi_handle )
{
	int16	result;
	
	result = 0;

	vq_extnd( vdi_handle, 1, extnd_out );

	if ( extnd_out[30] & 2 )											/* Treiber hat TRANSFER BITMAP? */
	{
		/* Farbtabellen */
		FP_vq_ctab = vq_ctab;
		FP_v_get_ctab_id = v_get_ctab_id;
		
		/* inverse Farbtabellen */
		FP_v_create_itab = v_create_itab;
		FP_v_delete_itab = v_delete_itab;
		
		/* Bitmapausgabe */
		FP_vr_transfer_bits = vr_transfer_bits;
	
		screen.ctab = 0;
		screen.itab = 0;

		result = 1;
	}
	else																		/* vr_transfer_bits() nachbilden */
	{
		/* Farbtabellen */
		FP_vq_ctab = RK_vq_ctab;
		FP_v_get_ctab_id = RK_v_get_ctab_id;
		
		/* inverse Farbtabellen */
		FP_v_create_itab = RK_v_create_itab;
		FP_v_delete_itab = RK_v_delete_itab;
		
		/* Bitmapausgabe */
		FP_vr_transfer_bits = RK_vr_transfer_bits;
	
		if ( vdi_handle > 0 )
		{
	#if USE_DEFAULT_COLORS
			default_colors( vdi_handle, 0L );
	#endif
			init_transform8();
	
			screen.addr = 0L;												/* in den MFDB soll als Adresse 0 eingetragen werden ... */
			screen.px_format = _get_device_format( vdi_handle );	/* Pixelformat */
			screen.bits = screen.px_format & PX_BITS;				/* Bits pro Pixel */
			screen.ctab = _create_ctab( vdi_handle );
			screen.itab = 0L;
	
			if ( screen.ctab )											/* konnte die Farbtabelle angelegt werden? */
			{
				if ( screen.bits <= 8 )
				{
					int16	bits;
					int16	levels;
	
#if USE_FLOYD
					bits = 3;												/* damit es schnell geht */
					levels = 1 << bits;
#else
					if ( screen.ctab->no_colors == 16 )				/* 16 Farben? */
					{
						int16	i;
						
						for ( i = 7; i <= 14; i++ )					/* die hinteren 8 Systemfarben sollen beim Dithern nicht beachtet werden */
						{
							(*ctab)->colors[i].rgb.red = 65535L;
							(*ctab)->colors[i].rgb.green = 65535L;
							(*ctab)->colors[i].rgb.blue = 65535L;
							(*ctab)->colors[i].rgb.reserved = 0;
						}
					}
	
					if ( screen.bits == 8 )								/* 256 Farben? */
					{
						bits = 3;
						levels = 6;											/* mit 216 Farben dithern */
					}
					else
					{
						bits = 1;
						levels = 2;											/* mit 8 Farben dithern */
					}
#endif
					screen.itab = _create_inverse_ctab( screen.ctab, bits, levels );
				}
				else
					screen.itab = _create_inverse_ctab( screen.ctab, 0, 0 );	/* Dummy-Tabelle */
				
				if ( screen.itab )
					result = 1;	
				else
					_delete_ctab( screen.ctab );
			}
		}
	}								
	return( result );
}

/*----------------------------------------------------------------------------------------*/
/* Farbpalette und inverse Farbpalette freigeben, Workstation schlieûen							*/
/* Funktionsresultat:	1																						*/
/*	vdi_handle:				VDI-Handle																			*/
/*	ctab:						Farbpalette																			*/
/*	inverse_ctab:			inverse Farbpalette																*/
/*----------------------------------------------------------------------------------------*/
int16	RK_reset( int16 vdi_handle )
{
	if ( screen.ctab )
		_delete_ctab( screen.ctab );
	if ( screen.itab )	
		_delete_inverse_ctab( screen.itab );

	return( 1 );
}


