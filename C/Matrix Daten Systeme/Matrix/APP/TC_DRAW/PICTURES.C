#include <vdi.h>
#include <aes.h>
#include <string.h>
#include <portab.h>

#include <global.h>
#include <vdi_ext.h>

# include "\pc\cxxsetup\aesutils.h"
# include "\pc\cxxsetup\main.h"
# include "\pc\cxxsetup\cxxfast.h"
# include "\pc\cxxsetup\files.h"
# include "\pc\cxxsetup\screen.h"
# include "\pc\cxxsetup\poti.h"
# include "\pc\cxxsetup\dialog.h"


# undef TRUE
# include <picfiles.h>
# define TRUE 1

# include "\pc\app\jpeg\src\jpeg_dec.h"
# include "\pc\app\jpeg\src\jpeg_com.h"
# include "\pc\app\tif\src\tiffwind.h"
	
# include "tc_dra.h"
# include "colors.h"
# include "drawwind.h"
# include "popup.h"
# include "text.h"
# include "draw_cli.h"

# include "pictures.h"

/*... display pictures ...*/

char pic_path[STPATHLEN] = "C:\*.ESM" ;
char fullname[STPATHLEN+STFILELEN] ;

char *txttab_pic_format[] =
{
	"ESM",
	"ÝTIF",
/*	"RGB",
	"IMG",	*/
	"MCC",
	"MOG",
	"MOC",
	"PPM",
	"JPG",
	"YC" ,
	"INF" ,
	"*",
	NULL
} ;

/*---------------------------------------- display_full_pic -----*/
void display_full_pic ( int *dpts,
						int w, int h, void *data, int planes,
						int wr_mode, int transcol )
{
	MFDB srcMFDB ;
	int *pts, *pxya, pxyarray[8] ;
	int color_index[2] ;
	POINT dim ;

	pts = dpts ;
	dim.x = pts[X1] - pts[X0] + 1 ;
	dim.y = pts[Y1] - pts[Y0] + 1 ;

	pxya = pxyarray ;
	*pxya++ = 0 ;			/*	offset picture window */
	*pxya++ = 0 ;
	*pxya++ = min ( dim.x, w ) - 1 ;	/*	end x-point	*/
	*pxya++ = min ( dim.y, h  ) - 1 ;	/*	end y-point	*/

	pts[X1] = pts[X0] + pxyarray[X1] ;
	pts[Y1] = pts[Y0] + pxyarray[Y1] ;

	*pxya++ = *pts++ ;
	*pxya++ = *pts++ ;
	*pxya++ = *pts++ ;
	*pxya++ = *pts++ ;


	srcMFDB.fd_addr 	= data ;
	srcMFDB.fd_w 		= w ;
	srcMFDB.fd_h		= h ;
	srcMFDB.fd_wdwidth	= 0 ;	/* calc'd by vdi\v_raster.c-vrt_cpyfm	*/
	srcMFDB.fd_stand	= PCK_FORM ;
	srcMFDB.fd_nplanes  = planes ;

	color_index[0] = transcol ;
	vrt_cpyfm ( vdi_handle, wr_mode, pxyarray,
						&srcMFDB, &vdi_screen, color_index ) ;
}

/*.... MOC palette handling	...*/

typedef int VDI_RGB[3] ;
typedef VDI_RGB VDI_PALETTE[256] ;

/*--------------------------------------- get_vdi_palette -------------*/
void get_vdi_palette ( VDI_PALETTE *pal )
{
	int color;

	for(color=0;color<256;color++)
		vq_color(vdi_handle,color,VQcolMode,(*pal)[color]);
}

/*--------------------------------------- set_vdi_palette -------------*/
void set_vdi_palette ( VDI_PALETTE *pal )
{
	int color;

	for(color=0;color<256;color++)
		vs_color(vdi_handle,color,(*pal)[color]);
}


VDI_PALETTE saved_palette ;

/*---------------------------------------- load_palette -----*/
void load_palette ( PALETTE *pal )
{
	RGB *pp ;
	int rgb[3], color ;

										/* load moc-palette	*/
	pp = *pal ;
	for ( color = 0 ; color < 256 ; color++, pp++ )
	{
		rgb[R] = scale ( pp->r, 1000, 255 ) ;
		rgb[G] = scale ( pp->g, 1000, 255 ) ;
		rgb[B] = scale ( pp->b, 1000, 255 ) ;
		vs_color ( vdi_handle, color, rgb ) ;
	}
}

/*--------------------------------------- set_gray_palette -------------*/
void set_gray_palette ( void )
{
	int color;
	int rgb[3] ;
	
	for(color=0;color<256;color++)
	{
		rgb[R] = rgb[G] = rgb[B] = scale ( color, 1000, 255 ) ;
		vs_color(vdi_handle,color,rgb);
	}
}


/*---------------------------------------- display_esm_pic -----*/
void display_esm_pic ( int *pts, ESMpic *pic)
{
	if ( pic->head->tiefe == 8 )
	{
		get_vdi_palette ( &saved_palette ) ;
		set_gray_palette() ;
	}
	display_full_pic ( pts,
						pic->head->breite, pic->head->hoehe,
						pic->data, pic->head->tiefe,
						MD_REPLACE, 0 ) ;
	if ( pic->head->tiefe == 8 )
		set_vdi_palette ( &saved_palette ) ;
}


/*---------------------------------------- display_moc_pic -----*/
void display_moc_pic ( int *pts, MOCpic *pic )
{
	get_vdi_palette ( &saved_palette ) ;
	load_palette ( pic->palette ) ;

	display_full_pic ( pts,
						pic->head->breite, pic->head->hoehe,
						pic->data, 8,
						transp_color < 256 ? MD_TRANS : MD_REPLACE, transp_color ) ;

	set_vdi_palette ( &saved_palette ) ;
}

/*-------------------------------------------------------- get_pic_name --*/	
bool get_pic_name ( char *prompt )
{
	change_extension ( pic_path, find_file_ext() ) ;
	return ( file_selector ( pic_path, fullname, prompt ) ) ;
}
	 	
/*-------------------------------------------------------- read_pic_start --*/	
void read_pic_start ( char *name )
{
	info_printf ( MSGreadFile, name ) ;
	MouseBusy();
}

/*-------------------------------------------------------- read_pic_end --*/	
bool read_pic_end ( int result )
{
	MouseBase();

	if ( result == OK )
		return(TRUE) ;
	else
	{
		info_printf ( MSGreadError ) ;
		return(FALSE) ;
	}
}

/*-------------------------------------------------------- read_esmpic --*/	
bool read_esmpic ( char *name, ESMpic *pic )
{
	read_pic_start ( name ) ;
	return read_pic_end ( read_esm_picture ( name, pic ) ) ;
}


/*-------------------------------------------------------- read_mocpic --*/	
bool read_mocpic ( char *name, MOCpic *pic )
{
	read_pic_start ( name );
	return read_pic_end ( read_moc_picture ( name, pic ) ) ;
}

/*-------------------------------------------------------- read_ppmpic --*/	
bool read_ppmpic ( char *name, PPMpic *pic )
{
	read_pic_start ( name );
	return read_pic_end ( read_ppm_picture ( name, pic ) ) ;
}

/*-------------------------------------------------------- read_ycpic --*/	
bool read_ycpic ( char *name, YCpic *pic )
{
	read_pic_start ( name );
	return read_pic_end ( read_yc_picture ( name, pic ) ) ;
}

/*-------------------------------------------------------- read_mccpic --*/	
bool read_mccpic ( char *name, MCCpic *pic )
{
	read_pic_start ( name );
	return read_pic_end ( read_mcc_picture ( name, pic ) ) ;
}


/*--------------------------------------------- LoadNamedPicFile ------------*/
bool LoadNamedPicFile ( char *name, int *pts )
{
	bool ok ;
	ESMpic esmpic ;
	MOCpic mocpic ;
	MCCpic mccpic ;
	YCpic  ycpic ;
	PPMpic ppmpic ;

	ok = FALSE ;
	switch ( pic_file_type ( name ) )
	{
case INFfile :	MouseOff();
				ok = cli_file ( name ) == 0 ;
				MouseOn();
				break ;
case PPMfile :	clear_ppm_pic ( &ppmpic ) ;
				if ( read_ppmpic ( name, &ppmpic ) )
				{
					if ( ppm_to_esm ( &ppmpic, &esmpic ) == OK )
					{
						MouseOff();
						display_esm_pic ( pts, &esmpic ) ;
						MouseOn();
						free_esm_pic ( &esmpic ) ;
						ok = TRUE ;
					}
					else
						free_ppm_pic ( &ppmpic ) ;
				}
				break ;

case JPGfile :	MouseOff();
				start_time = get_ticks() ;
				ok = jpeg_to_window ( name, screen_address,
							pts[X0], pts[Y0],
							pts[X1]-pts[X0]+1, pts[Y1]-pts[Y0]+1,
							bytes_per_line ) == 0 ;
				end_time = get_ticks() ; 
				MouseOn();
				break ;

case TIFfile :	MouseOff();
				ok = tiff_to_argb_window ( name, screen_address,
							pts[X0], pts[Y0],
							pts[X1]-pts[X0]+1, pts[Y1]-pts[Y0]+1,
							bytes_per_line ) == 0 ;
				MouseOn();
				break ;

case ESMfile :	clear_esm_pic ( &esmpic ) ;
				if ( read_esmpic ( name, &esmpic ) )
				{
					MouseOff();
					display_esm_pic ( pts, &esmpic ) ;
					MouseOn();
					free_esm_pic ( &esmpic ) ;
					ok = TRUE ;
				}
				break ;


case MOCfile :	clear_moc_pic ( &mocpic ) ;
				if ( read_mocpic ( name, &mocpic ) )
				{
					MouseOff();
					display_moc_pic ( pts, &mocpic ) ;
					MouseOn();
					free_moc_pic ( &mocpic ) ;
					ok = TRUE ;
				}
				break ;

case MCCfile :	clear_moc_pic ( &mocpic ) ;
				clear_mcc_pic ( &mccpic ) ;
				if ( read_mccpic ( name, &mccpic ) )
				{
					if ( mcc_to_moc ( &mccpic, &mocpic ) == OK )
					{
						free_mcc_pic ( &mccpic ) ;
						MouseOff();
						display_moc_pic ( pts, &mocpic ) ;
						MouseOn();
						free_moc_pic ( &mocpic ) ;
						ok = TRUE ;
					}
					else
					{
						info_printf ( " Fehler beim Entpacken der MCC-Datei" ) ;
						free_mcc_pic ( &mccpic ) ;
					}
				}
				break ;

case YCfile :	clear_esm_pic ( &esmpic ) ;
				clear_yc_pic ( &ycpic ) ;
				if ( read_ycpic ( name, &ycpic ) )
				{
					if ( yc_to_esm ( &ycpic, &esmpic ) == OK )
					{
						free_yc_pic ( &ycpic ) ;
						MouseOff();
						display_esm_pic ( pts, &esmpic ) ;
						MouseOn();
						free_esm_pic ( &esmpic ) ;
						ok = TRUE ;
					}
				}
				break ;

default :		info_printf ( " Unzul„ssiger Dateityp : %s",
									name ) ;
				break ;
	}

	return ok ;
}



/*--------------------------------------------- LoadPicture ------------*/
bool LoadPicture ( int *pts )
{
	MouseArrow();
	start_time = 0 ;
	if ( get_pic_name ( MSGreadPicName ) )
	{
# if 0
		WindUpdateEnd();			/* hopefully, the AES restores the	*/
		evnt_timer ( 1000, 0 ) ;	/*	 file selector background		*/
		WindUpdateBegin();
# endif
		MouseBusyBee();
		return LoadNamedPicFile ( fullname, pts ) ;
	}
	else
		return FALSE ;
}



/*---------------------------------------------------- save_draw_window --*/	
bool save_draw_window ( int *pts )

{
# if 0
	char alert_mesgbuf[128] ;
# endif
	int	 result, w, h ;
	ESMpic esmpic ;
	PPMpic ppmpic ;

	w = pts[X1] - pts[X0] + 1 ;
	h = pts[Y1] - pts[Y0] + 1 ;
	result = malloc_esm_pic ( &esmpic, w, h ) ;

	start_time = 0 ;
	if ( result == OK )
	{
		window_to_esm ( screen_address, bytes_per_line,
						 pts[X0], pts[Y0], w, h,
						 &esmpic ) ;
	
		MouseOn();
		MouseArrow();
		if ( get_pic_name ( MSGwritePicName ) )
		{
			info_printf ( MSGwriteFile, fullname ) ;
			MouseBusy();
			switch ( pic_file_type ( fullname ) )
			{
case PPMfile :	if ( esm_to_ppm ( &esmpic, &ppmpic ) == OK )
				{
					result = write_ppm_picture ( fullname, &ppmpic ) ;
					free_ppm_pic ( &ppmpic ) ;
				}
				else
					free_esm_pic ( &esmpic ) ;
				break ;

case JPGfile :	start_time = get_ticks() ;
				result = rgb_to_jpeg ( fullname, esmpic.data, w, h ) ;
				end_time = get_ticks() ; 
				free_esm_pic ( &esmpic ) ;
				break ;
	
case ESMfile :	result = write_esm_picture ( fullname, &esmpic ) ;
				free_esm_pic ( &esmpic ) ;
				break ;

case TIFfile :	result = rgb_to_tiff ( fullname, esmpic.data, w, h ) ;
				free_esm_pic ( &esmpic ) ;
				break ;
				
default :		info_printf ( " Unzul„ssiger Dateityp : %s",
									fullname ) ;
				result = 1 ;
				break ;
			}
			MouseBase();
		}
		MouseOff();
	}

	if ( result == OK )
	{
		return(TRUE) ;
	}
	else
	{
		simple_message ( MSGwriteError, result ) ;
# if 0
		sprintf ( alert_mesgbuf, "[2][|%s][ Abort ]",
										 err_mesgs[result] ) ;
		form_alert ( 1, alert_mesgbuf ) ;
# endif
		return(FALSE) ;
	}
}

