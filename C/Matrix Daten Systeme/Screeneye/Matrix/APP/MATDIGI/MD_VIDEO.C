/********************************************************************/
/* 				Read/Write Y-C Video (for MATdigi)					*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 20.08.93												*/
/*																	*/
/*  WA/HG - Matrix Daten Systeme, Talstr. 16, W-71570 Oppenweiler	*/
/*																	*/
/********************************************************************/
# define TEST 0

# include <portab.h>
# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <linea.h>
# include <ext.h>
# include <tos.h>

# include <global.h>
# include <error.h>
# include <vdi.h>

# include "md_picfa.h"
# include "md_picfi.h"
# include "tiff.h"
# include "matdigi.h"
# include "md_vmer.h"
# include "md_video.h"
# include "ycrgbtab.h"
# include "fastrom.h"

YCpic	yc_buffer ;
ESMpic	esm_buffer ;
byte	*std_buffer ;
byte	*ras_buffer ;

/* For MFDBs ... */
# define ATARI_FORMAT 0
# define STANDARD_FORMAT !ATARI_FORMAT
MFDB	scrn_fdb 	= { NULL, 0, 0, 0, 0, 0, 0, 0, 0 } ; /* screen device */
MFDB	ras_std_fdb = { NULL, 0, 0, 0, 0, 0, 0, 0, 0 } ; /* standard buffer */
MFDB	ras_fdb  	= { NULL, 0, 0, 0, 0, 0, 0, 0, 0 } ; /* raster buffer */

/* Mouse form */
# define mouse_on()		graf_mouse ( M_ON, (MFORM *)0 )
# define mouse_off()	graf_mouse ( M_OFF, (MFORM *)0 )

/*--------------------------------------------------- copy_YC -----*/
uword *copy_YC ( uword *d, uword *s, int pixel )
{
	while ( pixel-- > 0 )
		*d++ = *s++ ;	/*	8 bit Y, 8 bit U/V	*/
	return ( d ) ;
}

/*-------------------------------------------------- copy_RGB -----*/
byte *copy_RGB ( byte *d, byte *s, int pixel )
{
	while ( pixel-- > 0 )
	{
		s++ ;
		*d++ = *s++ ;
		*d++ = *s++ ;
		*d++ = *s++ ;
	}
	return ( d ) ;
}

# if 0
/*---------------------------------------------- save_video_file ---*/
int save_video_file ( char *name, YCpic *yc, ESMpic *esm )
{
	int  result ;

	switch ( pic_file_type ( name ) )
	{
case ESMfile :	result = write_esm_picture ( name, esm ) ;
				break ;
case YCfile :	result = write_yc_picture ( name, yc ) ;
				break ;
default :		result = UNDEFfile ;
				break ;
	}
	return ( result ) ;
}
# endif

/*---------------------------------------------- load_video_file ---*/
int load_video_file ( char *name, YCpic *yc, ESMpic *esm )
{
	int  result ;

	switch ( pic_file_type ( name ) )
	{
case ESMfile :	free_esm_pic ( &esm_buffer ) ;
				result = read_esm_picture ( name, esm ) ;
				break ;
case YCfile :	free_yc_pic ( &yc_buffer ) ;
				result = read_yc_picture ( name, yc ) ;
				break ;
default :		result = UNDEFfile ;
				break ;
	}
	return ( result ) ;
}


/*-------------------------------------------- double_yc ----*/
int double_yc ( YCpic *yc )
{
	int yi, result ;
	byte *sp, *dp ;
	YCpic newyc ;
	long inclen ;
	
	sp = yc->data ;
	result = malloc_yc_pic ( &newyc, yc->head->breite,
							 min ( Vdiesc->v_rez_vt,
							 	   ( yc->head->hoehe * 2 ) ) ) ;
	dp = newyc.data ;
	inclen = (long)yc->head->breite *
			 (long)yc->head->tiefe / 8 /* bpp */ ;
	if ( result == OK )
	{
		for ( yi = 0; yi < newyc.head->hoehe ; yi += 2 )
		{
			memcpy ( dp, sp, inclen ) ;
			dp += inclen ;
			memcpy ( dp, sp, inclen ) ;
			dp += inclen ;
			sp += inclen ;
		}
		free_yc_pic ( yc ) ;
		yc->head = newyc.head ;
		yc->data = newyc.data ;
	}
	return ( result ) ;
}


/*---------------------------------------------- video_info ----*/
void video_info ( void )
{
	int x, y ;
	byte *screen ;

	while ( ! kbhit() ) ;
		getch() ;
	
	screen = Logbase() ;
	printf ( "yc : $%p, %i x %i ; esm : $%p, %i x %i\n",
				yc_buffer.data,
				yc_buffer.head->breite, yc_buffer.head->hoehe,
				esm_buffer.data,
				esm_buffer.head->breite, esm_buffer.head->hoehe ) ;
	do
	{
		x = Vdiesc->cur_x ;
		y = Vdiesc->cur_y ;
		
		delay ( 100 ) ;
		printf ( "\r" ) ;

		printf ( "pos=%3d:%3d", x, y ) ;
		if ( yc_buffer.data != NULL )
		{
			printf ( ", y0/cb/y1/cr : ", x, y ) ;
			yc_print_pixel  ( &yc_buffer,  x, y ) ;
		}
		if ( esm_buffer.data != NULL )
		{
			printf ( ", r,g,b : " ) ;
			esm_print_pixel ( &esm_buffer, x, y ) ;
		}

		if ( Linea->v_planes == 8 )
		{
			printf ( ", pixel : " ) ;
			byte_print_pixel ( screen, x, y, Linea->v_lin_wr ) ;
		}
	}
	while ( ! kbhit() ) ;
	printf ( "\n" ) ;
	getch() ;
}


/*---------------------------------------------- display_rgb ----*/
int display_rgb ( ESMpic *rgb,
				  byte *dp,
				  int x, int y, int w, int h,
				  unsigned bpl )
{
	if ( w <=0 || h <= 0 )
		return ( NOwindow ) ;

	switch ( Linea->v_planes )
	{
  case 8 :	esm_to_6window ( rgb, dp, x, y, w, h, bpl ) ;
			break ;
  case 32 :	esm_to_tcwindow ( rgb, dp, x, y, w, h, bpl ) ;
  			break ;
  default :	return ( ILLbpp ) ;
	}
	return ( OK ) ;
}


# if TEST
/*------------------------------------------- show_test_info ----*/
void show_test_info ( char *name, RECTangle *win, POINT *vid,
					  int pixwidth, int pixheight,
					  int planes )
{
	if ( verbose )
		printf ( "%s, bpp used=%d, x=%d, y=%d, w=%d, h=%d, px=%d, py=%d, vx=%d, vy=%d\n",
					name, planes, win->x, win->y, win->w, win->h,
					pixwidth, pixheight, vid->x, vid->y ) ;
}
# endif TEST


/*---------------------------------------------- show_mono ----*/
void show_mono ( int vdi_handle, MFDB *ras_std_fdb, MFDB *scrn_fdb,
				 RECTangle *win, POINT *vid )
{  
	int			pxyarray[8] ;
	int			col[2] = { 1, 0 };

/*	ras_std_fdb->fd_w set by caller	*/
/*	ras_std_fdb->fd_h set by caller	*/
	ras_std_fdb->fd_wdwidth	= ras_std_fdb->fd_w >> 4 ;
	ras_std_fdb->fd_nplanes	= MONO ;	

	pxyarray[0] = vid->x;
	pxyarray[1] = vid->y;
	pxyarray[2] = vid->x + win->w - 1;
	pxyarray[3] = vid->y + win->h - 1;
	pxyarray[4] = win->x;
	pxyarray[5] = win->y;
	pxyarray[6] = win->x + win->w - 1;
	pxyarray[7] = win->y + win->h - 1;
	mouse_off();
	vrt_cpyfm ( vdi_handle, MD_REPLACE, pxyarray, ras_std_fdb, scrn_fdb, col ) ;
	mouse_on();
}


/*---------------------------------------------- show_grey ----*/
void show_grey ( int vdi_handle,
				 MFDB *ras_std_fdb, MFDB *ras_fdb, MFDB *scrn_fdb,
				 RECTangle *win, POINT *vid, int planes )
{
	int			pxyarray[8] ;

/*	ras_fdb->fd_w and ras_std_fdb->fd_w	set by caller	*/
/*	ras_fdb->fd_h and ras_std_fdb->fd_h	set by caller	*/
	ras_fdb->fd_wdwidth	= ras_fdb->fd_w >> 4 ;
	ras_fdb->fd_nplanes	= planes ;	

	if ( ras_std_fdb != NULL)
	{
		ras_std_fdb->fd_wdwidth = ras_fdb->fd_wdwidth ;
		ras_std_fdb->fd_nplanes = ras_fdb->fd_nplanes ;
		vr_trnfm ( vdi_handle, ras_std_fdb, ras_fdb ) ;
	}

	pxyarray[0] = vid->x;
	pxyarray[1] = vid->y;
	pxyarray[2] = vid->x + win->w - 1;
	pxyarray[3] = vid->y + win->h - 1;
	pxyarray[4] = win->x;
	pxyarray[5] = win->y;
	pxyarray[6] = win->x + win->w - 1;
	pxyarray[7] = win->y + win->h - 1;
	mouse_off();
	vro_cpyfm ( vdi_handle, S_ONLY, pxyarray,  ras_fdb, scrn_fdb ) ;
	mouse_on();
}


/*---------------------------------------------- show_colour ----*/
void show_colour ( int vdi_handle,
				   MFDB *ras_fdb, MFDB *scrn_fdb,
				   RECTangle *win, POINT *vid, int planes )
{
	int			pxyarray[8] ;

/*	ras_fdb->fd_w set by caller	*/
/*	ras_fdb->fd_h set by caller	*/
	ras_fdb->fd_wdwidth	= ras_fdb->fd_w >> 4 ;
	ras_fdb->fd_nplanes	= planes ;	

	pxyarray[0] = vid->x;
	pxyarray[1] = vid->y;
	pxyarray[2] = vid->x + win->w - 1;
	pxyarray[3] = vid->y + win->h - 1;
	pxyarray[4] = win->x;
	pxyarray[5] = win->y;
	pxyarray[6] = win->x + win->w - 1;
	pxyarray[7] = win->y + win->h - 1;
	mouse_off();
	vro_cpyfm ( vdi_handle, S_ONLY, pxyarray,  ras_fdb, scrn_fdb ) ;
	mouse_on();
}


/*---------------------------------------- display_full_grey_ntc ----*/
int display_full_grey_ntc ( int vdi_handle,
							RECTangle *win,
							POINT *vid )
{
	if ( ras_buffer != NULL ) 
	{
# if TEST
		show_test_info ( "display_full_grey_ntc", win, vid, PIXWIDTH, PIXHEIGHT, NTC ) ;
# endif TEST
		Y_to_grey_ntc ( (void *)ras_buffer, PIXHEIGHT ) ;
		ras_fdb.fd_w = PIXWIDTH ;
		ras_fdb.fd_h = PIXHEIGHT ;
		show_colour ( vdi_handle, &ras_fdb, &scrn_fdb,
					  win, vid, NTC ) ;
	}
	else
		return ( NOmemory ) ;
	return ( OK ) ;
}

typedef void Y_TO_STANDARD ( void *, void *, int, int ) ;
/*---------------------------------------------- display_full_grey ----*/
int display_full_grey ( int vdi_handle,
						RECTangle *win,
						POINT *vid,
						int planes )
{
	int		matgraph = FALSE ;
	Y_TO_STANDARD *y_to_standard ;
	
	if ( win->w <=0 || win->h <= 0 )
		return ( NOwindow ) ;

# if TEST
	show_test_info ( "display_full_grey", win, vid, PIXWIDTH, PIXHEIGHT, planes ) ;
# endif TEST

	if ( matgraph )	switch ( planes )
	{
# if 0
  case 8 :	y_to_standard = Y_to_cx8 ;	/* assuming	CXX 256 grey levels	*/
  			break ;
# endif
  default :	matgraph = FALSE ;
	}
		
	if ( ! matgraph ) switch ( planes )
	{
  case MONO :	return ( display_full_mono ( vdi_handle,
  										 win, vid )) ;
  case 2 :  			
  case 4  : y_to_standard = Alt_Y_to_grey ;
  			break ;	
  case 8  : y_to_standard = Y_to_grey ;	
			fetch_rom_pic ( (void *)yc_buffer.data, PIXWIDTH, PIXHEIGHT ) ;
			break ;
  case NTC:
			if ( ( ras_buffer != NULL )  &&
		 		( std_buffer != NULL )    )
			{
  				rgb_init ( NTC ) ;
				return ( display_full_grey_ntc ( vdi_handle,
  											 	 win, vid ) ) ;
  			}
  			break ;
  default :	return ( ILLbpp ) ;
	}

	if ( ( ras_buffer != NULL )  &&
 		( std_buffer != NULL )    )
	{
		(*y_to_standard) ( (void *)std_buffer, (void *)yc_buffer.data, PIXHEIGHT, planes ) ;
		ras_fdb.fd_w = ras_std_fdb.fd_w = PIXWIDTH ;
		ras_fdb.fd_h = ras_std_fdb.fd_h = PIXHEIGHT ;
		show_grey ( vdi_handle, &ras_std_fdb, &ras_fdb, &scrn_fdb,
					win, vid, planes ) ;
		return OK ;
	}
	return NOmemory ;
}


/*------------------------------------ fetch_and_save --------------*/
int fetch_and_save ( char * fname, RECTangle *win, POINT *vid,
								   YCpic *yc, ESMpic *esm )
{
	RECTangle cutwindow ;

	fetch_rom_pic ( (void *)yc->data, PIXWIDTH, PIXHEIGHT ) ;

	switch ( pic_file_type ( fname ) )
	{
case YCfile :	break ;
case ESMfile :
case TIFfile :
default :		yc_to_esm ( yc, esm ) ;
	}

	if ( ( win == NULL ) || ( vid == NULL ) )
		return ( cut_and_save ( fname, NULL, yc, esm ) ) ;
	else
	{
		cutwindow.x = vid->x;
		cutwindow.y = vid->y;
		cutwindow.w = win->w;
		cutwindow.h = win->h;
		return ( cut_and_save ( fname, &cutwindow, yc, esm ) ) ;
	}
}


typedef void Y_TO_RASTER ( void *, int ) ;
/*---------------------------------------------- display_full_colour ----*/
int display_full_colour ( int vdi_handle,
						  RECTangle *win,
						  POINT *vid,
						  int planes )
{
	Y_TO_RASTER	*y_to_raster ;
	
	if ( win->w <=0 || win->h <= 0 )
		return ( NOwindow ) ;

	switch ( planes )
	{
  case MONO :
  			return ( display_full_mono ( vdi_handle, win, vid ) ) ;
  case 2  :
  case 4  : return ( display_full_grey ( vdi_handle, win, vid, planes ) ) ;
  case 8  :	rgb_init ( 8 ) ;
			fetch_rom_pic ( (void *)yc_buffer.data, PIXWIDTH, PIXHEIGHT ) ;
			Y_to_332 ( (void *)std_buffer, (void *)yc_buffer.data, PIXHEIGHT ) ;
			ras_fdb.fd_w = ras_std_fdb.fd_w = PIXWIDTH ;
			ras_fdb.fd_h = ras_std_fdb.fd_h = PIXHEIGHT ;
			show_grey ( vdi_handle, &ras_std_fdb, &ras_fdb, &scrn_fdb,
						win, vid, planes ) ;
			return ( OK ) ;
  case NTC:	rgb_init ( NTC ) ;
			y_to_raster = Y_to_ntc ;	/* FALCON */
 			break ;
  default :	return ( ILLbpp ) ;
	}

	if ( ( ras_buffer != NULL )  &&
		 ( std_buffer != NULL )    )
	{
# if TEST
		show_test_info ( "display_full_colour", win, vid, PIXWIDTH, PIXHEIGHT, planes ) ;
# endif TEST
		(*y_to_raster) ( (void *)ras_buffer, PIXHEIGHT ) ;
		ras_fdb.fd_w = PIXWIDTH ;
		ras_fdb.fd_h = PIXHEIGHT ;
		show_colour ( vdi_handle, &ras_fdb, &scrn_fdb,
					  win, vid, planes ) ;
	}
	else
		return ( NOmemory ) ;
	return ( OK ) ;
}


/*---------------------------------------- display_grey_ntc ----*/
int display_grey_ntc ( int vdi_handle,
					   RECTangle *win,
					   POINT *vid )
{
	if ( ras_buffer != NULL ) 
	{
# if TEST
		show_test_info ( "display_grey_ntc", win, vid, GPIXWIDTH, GPIXHEIGHT, NTC ) ;
# endif TEST
		Y_to_2grey_ntc ( (void *)ras_buffer, PIXHEIGHT ) ;
		ras_fdb.fd_w = GPIXWIDTH ;
		ras_fdb.fd_h = GPIXHEIGHT ;
		show_colour ( vdi_handle, &ras_fdb, &scrn_fdb,
					  win, vid, NTC ) ;
	}
	else
		return ( NOmemory ) ;
	return ( OK ) ;
}


/*---------------------------------------------- display_grey ----*/
int display_grey ( int vdi_handle, RECTangle *win, POINT *vid, int planes )
{
	if ( win->w <=0 || win->h <= 0 )
		return ( NOwindow ) ;

	if ( planes == NTC )
	{
		rgb_init ( NTC ) ;
		return ( display_grey_ntc ( vdi_handle, win, vid ) ) ;
	}
	
	if ( ( ras_buffer != NULL )  &&
		 ( std_buffer != NULL )    )
	{
# if TEST
		show_test_info ( "display_grey", win, vid, GPIXWIDTH, GPIXHEIGHT, planes ) ;
# endif TEST
		fetch_2rom_pic ( (void *)yc_buffer.data, GPIXWIDTH, GPIXHEIGHT ) ;
		Y_to_2grey ( (void *)std_buffer, (void *)yc_buffer.data, GPIXHEIGHT, planes ) ;
		ras_fdb.fd_w = ras_std_fdb.fd_w = GPIXWIDTH ;
		ras_fdb.fd_h = ras_std_fdb.fd_h = GPIXHEIGHT ;
		show_grey ( vdi_handle, &ras_std_fdb, &ras_fdb, &scrn_fdb,
					win, vid, planes ) ;
	}
	else
		return ( NOmemory ) ;
	return ( OK ) ;
}

/*---------------------------------------------- repeat_colour ----*/
int repeat_colour ( int vdi_handle, RECTangle *win, POINT *vid,
				    int dx, int dy, int planes )
{
	if ( win->w <=0 || win->h <= 0 )
		return ( NOwindow ) ;

	if ( ras_buffer != NULL )
	{
# if TEST
		show_test_info ( "repeat_colour", win, vid, dx, dy, planes ) ;
# endif TEST
		ras_fdb.fd_w = dx ;
		ras_fdb.fd_h = dy ;
		show_colour ( vdi_handle, &ras_fdb, &scrn_fdb,
					  win, vid, planes ) ;
	}
	else
		return ( NOmemory ) ;
	return ( OK ) ;
}


/*---------------------------------------------- repeat_grey ----*/
int repeat_grey ( int vdi_handle, RECTangle *win, POINT *vid,
				  int dx, int dy, int planes )
{
	if ( win->w <=0 || win->h <= 0 )
		return ( NOwindow ) ;

	if ( ras_buffer != NULL )
	{
# if TEST
		show_test_info ( "repeat_grey", win, vid, dx, dy, planes ) ;
# endif TEST
		ras_fdb.fd_w = dx ;
		ras_fdb.fd_h = dy ;
		show_grey ( vdi_handle, NULL, &ras_fdb, &scrn_fdb,
					win, vid, planes ) ;
	}
	else
		return ( NOmemory ) ;
	return ( OK ) ;
}


/*---------------------------------------------- display_mono ----*/
int display_mono ( int vdi_handle, RECTangle *win, POINT *vid )
{
	if ( win->w <=0 || win->h <= 0 )
		return ( NOwindow ) ;

	if ( std_buffer != NULL )
	{
# if TEST
		show_test_info ( "display_mono", win, vid, GPIXWIDTH, GPIXHEIGHT, MONO ) ;
# endif TEST
		Y_to_2mono ( (void *)std_buffer, GPIXHEIGHT ) ;
		ras_std_fdb.fd_w = GPIXWIDTH ;
		ras_std_fdb.fd_h = GPIXHEIGHT ;
		show_mono ( vdi_handle, &ras_std_fdb, &scrn_fdb, win, vid ) ;
	}
	else
		return ( NOmemory ) ;
	return ( OK ) ;
}


/*---------------------------------------------- display_full_mono ----*/
int display_full_mono ( int vdi_handle, RECTangle *win, POINT *vid )
{
	if ( win->w <=0 || win->h <= 0 )
		return ( NOwindow ) ;

	if ( std_buffer != NULL )
	{
# if TEST
		show_test_info ( "display_full_mono", win, vid, PIXWIDTH, PIXHEIGHT, MONO ) ;
# endif TEST
		Y_to_mono ( (void *)std_buffer, PIXHEIGHT ) ;
		ras_std_fdb.fd_w = PIXWIDTH ;
		ras_std_fdb.fd_h = PIXHEIGHT ;
		show_mono ( vdi_handle, &ras_std_fdb, &scrn_fdb, win, vid ) ;
	}
	else
		return ( NOmemory ) ;
	return ( OK ) ;
}


/*---------------------------------------------- repeat_mono ----*/
int repeat_mono ( int vdi_handle, RECTangle *win, POINT *vid,
				  int dx, int dy )
{
	if ( win->w <=0 || win->h <= 0 )
		return ( NOwindow ) ;

	if ( std_buffer != NULL )
	{
# if TEST
		show_test_info ( "repeat_mono", win, vid, dx, dy, MONO ) ;
# endif TEST
		ras_std_fdb.fd_w = dx ; 
		ras_std_fdb.fd_h = dy ;
		show_mono ( vdi_handle, &ras_std_fdb, &scrn_fdb, win, vid ) ;
	}
	else
		return ( NOmemory ) ;
	return ( OK ) ;
}


/*---------------------------------------------- display_dither ----*/
int display_dither ( int vdi_handle, RECTangle *win, POINT *vid )
{
	if ( win->w <=0 || win->h <= 0 )
		return ( NOwindow ) ;

	if ( std_buffer != NULL )
	{
# if TEST
		show_test_info ( "display_dither", win, vid, GPIXWIDTH, GPIXHEIGHT, MONO ) ;
# endif TEST
		Y_to_2dith	( (void *)std_buffer, GPIXHEIGHT ) ;
		ras_std_fdb.fd_w = GPIXWIDTH ;
		ras_std_fdb.fd_h = GPIXHEIGHT ;
		show_mono ( vdi_handle, &ras_std_fdb, &scrn_fdb, win, vid ) ;
	}
	else
		return ( NOmemory ) ;
	return ( OK ) ;
}

/*---------------------------------------------- display_full_dither ----*/
int display_full_dither ( int vdi_handle, RECTangle *win, POINT *vid )
{
	if ( win->w <=0 || win->h <= 0 )
		return ( NOwindow ) ;

	if ( std_buffer != NULL )
	{
# if TEST
		show_test_info ( "display_full_dither", win, vid, PIXWIDTH, PIXHEIGHT, MONO ) ;
# endif TEST
		Y_to_dith ( (void *)std_buffer, PIXHEIGHT ) ;
		ras_std_fdb.fd_w = PIXWIDTH ;
		ras_std_fdb.fd_h = PIXHEIGHT ;
		show_mono ( vdi_handle, &ras_std_fdb, &scrn_fdb, win, vid ) ;
	}
	else
		return ( NOmemory ) ;
	return ( OK ) ;
}


/*---------------------------------------------- clear_yc -------*/
void clear_yc ( YCpic *yc, long pattern )
{
	long *dp ;
	long count ;

	count = pic_data_size ( yc->head ) / 4L ;
	
	dp = (long*)yc->data ;
	
	while ( count-- > 0 )
		*dp++ = pattern ;
}


/*---------------------------------------------- clear_esm -------*/
void clear_esm ( ESMpic *esm, int w, int h, long pattern )
{
	resize_esm ( esm, w, h ) ;
	clear_yc ( (YCpic *) esm, pattern ) ;
}


/*----------------------------------------- cut_and_save_esm -----*/
int cut_and_save_esm ( char *esmfile, RECTangle *win, ESMpic *esm )
{
	ESMpic 	newesm ;
	int		result ;
	
	clear_esm_pic ( &newesm ) ;
	if ( ( result = cut_esm ( esm,
							  win->x, win->y, win->w, win->h,
							  &newesm ) ) == OK )
	{
		result = write_esm_picture ( esmfile, &newesm ) ;
		free_esm_pic ( &newesm ) ;
	}
	return ( result ) ;
}


/*----------------------------------------- cut_and_save_tif -----*/
int cut_and_save_tif ( char *esmfile,
					   RECTangle *win, ESMpic *esm )
{
	ESMpic 	newesm ;
	TIFFpic *tiff ;
	int		result ;
	
	clear_esm_pic ( &newesm ) ;
	if ( ( result = cut_esm ( esm,
							  win->x, win->y, win->w, win->h,
							  &newesm ) ) == OK )
	{
		tiff = init_tiff ( (void *)newesm.data, 
							newesm.head->breite,
							newesm.head->hoehe,
							&result ) ;
		if ( result == OK )
		{
			result = write_tiff_picture ( esmfile,
									  	  tiff,
										  newesm.head->breite,
										  newesm.head->hoehe ) ;
			free_tiff_pic ( tiff ) ;
		}
		free_esm_pic ( &newesm ) ;
	}
	return ( result ) ;
}


/*----------------------------------------- cut_and_save_yc -----*/
int cut_and_save_yc ( char *ycfile, RECTangle *win, YCpic *yc)
{
	YCpic 	newyc ;
	int		result ;
	
	clear_yc_pic ( &newyc ) ;
	if ( ( result = cut_yc ( yc,
							 win->x, win->y, win->w, win->h,
							 &newyc ) ) == OK )
	{
		result = write_yc_picture ( ycfile, &newyc ) ;
		free_yc_pic ( &newyc ) ;
	}
	return ( result ) ;
}


/*----------------------------------------- cut_and_save -----*/
int cut_and_save ( char *file, RECTangle *win, YCpic *yc, ESMpic *esm )
{
	int		result ;
	TIFFpic *tiff ;
	
	switch ( pic_file_type ( file ) )
	{
case YCfile		: if ( win == NULL )
					result = write_yc_picture ( file, yc ) ;
				  else
					result = cut_and_save_yc ( file, win, yc ) ;
				  break ;

case ESMfile	: if ( win == NULL )
					result = write_esm_picture ( file, esm ) ;
				  else
					result = cut_and_save_esm ( file, win, esm ) ;
				  break ;

case TIFfile	:
default :		  if ( win == NULL )
				  {
					tiff = init_tiff ( (void *)esm->data, 
										esm->head->breite,
										esm->head->hoehe,
										&result ) ;
					if ( result == OK )
					{
						result = write_tiff_picture ( file,
													  tiff,
													  esm->head->breite,
													  esm->head->hoehe ) ;
						free_tiff_pic ( tiff ) ;
					}
				  }
				  else
					result = cut_and_save_tif ( file, win, esm ) ;
				  break ;
	}
	return ( result ) ;
}

	
/*------------------------------------------------ init_vidig -----*/
int init_vidig ( int w, int h )
{
	int result ;
	
	init_rgb6(); 
	init_yc_to_rgb();

	clear_yc_pic ( &yc_buffer ) ;
	clear_esm_pic ( &esm_buffer ) ;
	result = malloc_yc_pic ( &yc_buffer, w, h ) ;
	if ( result == OK )
	{
		yc_buffer.head->bildart = YC_422 ;
		result = malloc_esm_pic ( &esm_buffer, w, h ) ;
		if ( result == OK )
		{	/* reserve space for blit buffers & partly-initialise MFDBs */
			std_buffer = Mdalloc ( (long)h * (long)w * (long)Linea->v_planes / 8L ) ;
			ras_buffer = Mdalloc ( (long)h * (long)w * (long)Linea->v_planes / 8L ) ;
			ras_fdb.fd_addr		= ras_buffer ;
			ras_std_fdb.fd_addr	= std_buffer ;
			ras_fdb.fd_stand	= ATARI_FORMAT ;
			ras_std_fdb.fd_stand= STANDARD_FORMAT ;
		}
		if ( ( std_buffer != NULL ) && ( ras_buffer != NULL ) )
			return OK;
		else
			return ( NOmemory ) ;
	}
	else
		return ( result ) ;
}


/*------------------------------------------------ term_vidig -----*/
void term_vidig ( void )
{
	free_yc_pic ( &yc_buffer ) ;
	free_esm_pic ( &esm_buffer ) ;
	if ( std_buffer != NULL )
		Mfree ( std_buffer ) ;
	if ( ras_buffer != NULL )
		Mfree ( ras_buffer ) ;
}


