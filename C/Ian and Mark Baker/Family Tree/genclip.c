/************************************************************************/
/*																		*/
/*		Genclip.c	23 Jan 98											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "genclip.h"
#include "genutil.h"
#include "gendesc.h"
#include "gendraw.h"
#include "gennote.h"
#include "genpprn.h"
#include "genprnt.h"
#include "gentprn.h"
#include "gentree.h"

extern Wind_edit_params notes_form ;
extern Wind_edit_params desc_form ;
extern Wind_edit_params tree_form ;
extern Wind_edit_params custom_form ;

extern char *edit_buffer ;
extern char *tail_ptr ;		/* pointer to start of tail in edit buffer	*/
extern char *edit_ptr ;		/* pointer to end of head in edit buffer	*/
extern char *block_start_ptr ;
extern char *block_end_ptr ;
extern int notes_size ;		/* number of characters in edit buffer		*/
extern short notes_changed ;
extern short first_line ;				/* first line in window			*/
extern char *line_start[MAX_LINES] ;	/* ptr into edit buffer of		*/
										/* character at start of line	*/
extern int desc_root ;
extern short desc_first_line ;
extern short desc_chars_up ;

extern int tree_trunk ;
extern char far tree_names[MAX_TREE_SIZE][SHORT_NAME_MAX + 1] ;
extern char far tree_dates[MAX_TREE_SIZE][2*DATE_LENGTH + 2] ;

extern Custom_device custom_display ;
extern Custom_tree custom_tree ;
extern Custom_device custom_printout ;
extern short prn_pixel_width ;			/* gdos pixel width & height	*/
extern short prn_pixel_height ;

extern short scr_handle ;

extern Preferences prefs ;

char *clip_setup( void )
{
	static char scrap_path[200] ;
	char temp[200] ;
	struct FILEINFO dta ;
	int length ;
	int drive_map ;

	if( getcookie( 'MiNT', NULL ) )
		Psemaphore( 2 /* SEM_LOCK */ , '_CLP', -1 ) ;

	Fsetdta( &dta ) ;
	
	if( scrp_read( scrap_path ) && isalpha( scrap_path[0] ) )
	{	
		length = strlen( scrap_path ) ;
		if( scrap_path[length-1] != '\\' )
		{
			Fsfirst( scrap_path, 0x17 ) ;
			if( dta.attr & 0x10 )
				strcat( scrap_path, "\\" ) ;
			else
			{
				strcpy( temp, scrap_path ) ;
				stcgfp( scrap_path, temp ) ;
			}
		}
	}
	else
	{
		drive_map = Drvmap() ;
		if( drive_map & 0x04 )
			strcpy( scrap_path, "c:\clipbrd" ) ;
		else
			strcpy( scrap_path, "a:\clipbrd" ) ;
		Dcreate( scrap_path ) ;
		strcat( scrap_path, "\\" ) ;
	}

	scrp_write( scrap_path ) ;
	return( scrap_path ) ;
}


void clip_finish( void )
{
	if( getcookie( 'MiNT', NULL ) )
		Psemaphore( 3 /* SEM_LOCK */, '_CLP', -1 ) ;
}


void clip_clear( char *path )
{
	short err ;
	char scrapfile[200] ;
	char delfile[200] ;
	struct FILEINFO dta ;
	
	Fsetdta( &dta ) ;
	
	strcpy( scrapfile, path ) ;
	strcat( scrapfile, "scrap.*" ) ;
	
	err = Fsfirst( scrapfile, 2 ) ;
	while( !err )
	{	strcpy( delfile, path ) ;
		strcat( delfile, dta.name ) ;
		Fdelete( delfile ) ;
		err = Fsnext() ;
	}
}


void write_further_notes_to_clipboard( void )
{
	char *clippath ;
	char filename[FMSIZE] ;
	FILE *fp ;
	char *i ;
	int restore = FALSE ;	/* restore block to NULL afterwards */

	clippath = clip_setup() ;
	clip_clear( clippath ) ;
	
	if( !block_start_ptr || !block_end_ptr )
	{
		block_start_ptr = edit_buffer ;
		block_end_ptr = edit_buffer+prefs.edit_buffer_size ;
		restore = TRUE ;
	}

	strcpy( filename, clippath ) ;
	strcat( filename, "scrap.asc" ) ;
	
	if( fp = fopen( filename, "wb" ) )
	{
		for( i = block_start_ptr ; i < block_end_ptr; i++ )
		{
			if( i == edit_ptr )  i = tail_ptr ;
			fputc( *i, fp ) ;
			if( *i == '\r' )  fputc( 0x0a, fp ) ;
		}
		fclose( fp ) ;
	}

	strcpy( filename, clippath ) ;
	strcat( filename, "scrap.txt" ) ;
	
	if( fp = fopen( filename, "w" ) )
	{
		write_notes_as_text( fp ) ;
		fclose( fp ) ;
	}

	if( restore )
		block_start_ptr = block_end_ptr = NULL ;

	clip_finish() ;
}


void read_further_notes_from_clipboard( void )
{
	char *clippath ;
	char filename[FMSIZE] ;
	FILE *fp ;
	char c ;
	char *old_edit_ptr ;	
	int opened = FALSE ;

	clippath = clip_setup() ;
	
	strcpy( filename, clippath ) ;
	strcat( filename, "scrap.asc" ) ;
	
	if( fp = fopen( filename, "rb" ) )
		opened = TRUE ;
	else
	{
		strcpy( filename, clippath ) ;
		strcat( filename, "scrap.txt" ) ;
		
		if( fp = fopen( filename, "rb" ) )
			opened = TRUE ;
	}
	
	if( opened )
	{
		if( filelength( fileno(fp) ) > prefs.edit_buffer_size - notes_size )
			rsrc_form_alert( 1, ED_FULL ) ;
		else
		{
			notes_changed = TRUE ;	/* This will cause the notes to be	*/
									/* checked to see if really changed	*/

			old_edit_ptr = edit_ptr ;

			while( ( c = fgetc( fp ) ), !feof( fp ) )
				if( c != 0x0a )  *edit_ptr++ = c ;
			*edit_ptr = '\0' ;

			notes_size += edit_ptr - old_edit_ptr ;
			if( old_edit_ptr < line_start[0] )  first_line = 0 ;
			set_notes_sizes( &notes_form.fm_box ) ;	
			send_redraw_message( &notes_form.fm_box, notes_form.fm_handle ) ;
		}
		fclose( fp ) ;
	}

	clip_finish() ;
}


void  write_notes_as_text( FILE *fp )
{
	Str_prt_params params ;
	char *notes ;
	char *pos ;
	char *i ;
	
	if(	notes = (char *) pmalloc( prefs.edit_buffer_size ) )
	{
		pos = notes ;
		for( i = block_start_ptr ; i < block_end_ptr; i++ )
		{
			if( i == edit_ptr )	i = tail_ptr ;
			*pos++ = *i ;
		}
		*pos = '\0' ;
		
		params.check_printer = CHECK_PRINTER_OFF ;
		params.last_x_end = 0 ;
		params.x_pos = 0 ;
		params.y_pos = 0 ;
		params.x_offset = 0 ;
		params.y_offset = 0 ;
		params.downlines = 1 ;
		params.align = LEFT ;
		params.chs_across = 75 ;
		params.max_len = 75 ;
		params.cell_width = 1 ;
		params.cell_height = 1 ;
		params.chs_up = 0x7FFF ;	/* assumed virtually infinite		*/
		params.use_gdos = FALSE ;
		params.fp = fp ;

		print_notes( notes, &params ) ;

		free( notes ) ;
	}
}


void write_tree_to_clipboard( void )
{
	char *clippath ;
	char filename[FMSIZE] ;
	Str_prt_params params ;
	Tree_params tree_params ;
	short max_gens ;
	short x_offset ;
	short x ;
	
	clippath = clip_setup() ;
	clip_clear( clippath ) ;

	strcpy( filename, clippath ) ;
	strcat( filename, "scrap.img" ) ;
	write_window_to_img_file( tree_form.fm_handle, filename ) ;

	strcpy( filename, clippath ) ;
	strcat( filename, "scrap.gem" ) ;
	busy( BUSY_MORE ) ;
	params.use_gdos = TRUE ;
	open_gdos_prn( &params, filename, 31 ) ;

	if( params.prn_handle )
	{
		x = (int) params.chs_up + 2 ;	/* calculate max generations vertically	*/
		max_gens = 0 ;
		while( x > 3 && max_gens < MAX_GENS )
		{
			x >>= 1 ;
			max_gens++ ;
		}
		x_offset = params.cell_width
			* ( params.chs_across - 1 - SHORT_NAME_MAX ) / ( max_gens - 1 ) ;

		tree_params.ref = tree_trunk ;
		tree_params.generation = 1 ;
		tree_params.max_generations = max_gens ;		/* temporary values	*/
		tree_params.position = 1 ;
		tree_params.x_offsets = x_offset ;
	
		for( x=0; x<MAX_TREE_SIZE; x++ )
		{
			tree_names[x][0] = '\0' ;
			tree_dates[x][0] = '\0' ;
		}

		load_tree_strings( tree_params ) ;

		tree_params.ch_width = params.cell_width ;
		tree_params.x_position = params.cell_width ;
		tree_params.ch_height = params.cell_height ;
		tree_params.y_min = 2 ;
		tree_params.y_max = params.chs_up * params.cell_height - 2 ;
		tree_params.line_start_x = 0 ;
		tree_params.line_start_y = 0 ;
	
		draw_person( params.prn_handle, tree_params ) ;

		end_page( &params, FALSE ) ;
		close_printer( &params ) ;
	}
	busy( BUSY_LESS ) ;

	clip_finish() ;
}


void write_desc_to_clipboard( void )
{
	Str_prt_params params ;

	char *clippath ;
	char filename[FMSIZE] ;

	clippath = clip_setup() ;
	clip_clear( clippath ) ;

	strcpy( filename, clippath ) ;
	strcat( filename, "scrap.img" ) ;
	write_window_to_img_file( desc_form.fm_handle, filename ) ;
	
	strcpy( filename, clippath ) ;
	strcat( filename, "scrap.gem" ) ;

	busy( BUSY_MORE ) ;

	params.use_gdos = TRUE ;
	open_gdos_prn( &params, filename, 31 ) ;
	if( params.prn_handle )
	{
		params.fp = NULL ;			/* file pointer not used			*/
		params.align = LEFT ;
		params.x_pos = 0 ;
		params.x_offset = 0 ;
		params.max_len = 0 ;
		params.last_x_end = 0 ;
		params.y_pos = 0 ;
		params.y_offset = 0 ;
		params.tabpos = 3 ;	
		params.downlines = 1 ;
		params.line_number = 0 ;
		params.first_line = desc_first_line ;
		params.last_line = params.first_line + params.chs_up - 1 ;

		print_desc( desc_root, 0, &params ) ;
		
		end_page( &params, FALSE ) ;
		close_printer( &params ) ;
	}
	busy( BUSY_LESS ) ;

	clip_finish() ;
}


void write_window_to_img_file( int wh, char *filename )
{
	FILE *fp ;
	GRECT rect ;
	short work_out[57] ;
	MFDB screen, buffera, bufferb ;
	char *bufa, *bufb, *ptr ;
	short pxy_array[8] ;
	short x, y ;
	short nplanes ;

	busy( BUSY_MORE ) ;

	if( fp = fopen( filename, "wb" ) )
	{
		vq_extnd( scr_handle, 1, work_out ) ;
		nplanes = work_out[4] ;
		vq_extnd( scr_handle, 0, work_out ) ;
		wind_get( wh, WF_WORKXYWH, REFS(rect) ) ;
		rect.g_w -= ( rect.g_w % 16 ) ;

		bufa = pmalloc( rect.g_h * rect.g_w / 8 * nplanes ) ;
		buffera.fd_addr = (void *) bufa ;
		ptr = bufb = pmalloc( rect.g_h * rect.g_w / 8 * nplanes ) ;
		bufferb.fd_addr = (void *) bufb ;
		buffera.fd_w = bufferb.fd_w = rect.g_w ;
		buffera.fd_h = bufferb.fd_h = rect.g_h ;
		buffera.fd_wdwidth = bufferb.fd_wdwidth =rect.g_w / 16 ;
		buffera.fd_stand = 0 ;
		bufferb.fd_stand = 1 ;
		buffera.fd_nplanes = bufferb.fd_nplanes = nplanes ;
		screen.fd_addr = NULL ;
		pxy_array[0] = rect.g_x ;
		pxy_array[1] = rect.g_y ;
		pxy_array[2] = rect_end( &rect ) ;
		pxy_array[3] = rect_bottom( &rect ) ;
		pxy_array[4] = pxy_array[5] = 0 ;
		pxy_array[6] = rect.g_w - 1 ;
		pxy_array[7] = rect.g_h - 1 ;
		graf_mouse( M_OFF, NULL ) ;
		vro_cpyfm( scr_handle, S_ONLY, pxy_array, &screen, &buffera ) ;
		graf_mouse( M_ON, NULL ) ;
		vr_trnfm( scr_handle, &buffera, &bufferb ) ;		

		fputw( 0x0001, fp ) ;			/* .img format version 1.00		*/
		fputw( 0x0008, fp ) ;			/* Standard 8 word header		*/
		fputw( 0x0001, fp ) ;			/* One bitplanes - monochrome	*/
		fputw( 0x0002, fp ) ;			/* Two byte patterns			*/
		fputw( work_out[3], fp ) ;		/* Pixel width in æm			*/
		fputw( work_out[4], fp ) ;		/* Pixel height in æm			*/
		fputw( rect.g_w, fp ) ;			/* Image width in pixels		*/
		fputw( rect.g_h, fp ) ;			/* Image height in pixels		*/

		for( y=0; y<(rect.g_h); y++ )
		{
			fputc( 0x80, fp ) ;
			fputc( rect.g_w / 8, fp ) ;
			for( x=0; x<(rect.g_w/8); x++ )
				fputc( *ptr++, fp ) ;
		}
		free( bufa ) ;
		free( bufb ) ;
		fclose( fp ) ;
	}
	busy( BUSY_LESS ) ;
}


void  write_custom_to_clipboard( void )
{
	char *clippath ;
	char filename[FMSIZE] ;
	Str_prt_params params ;
	short right_edge_mm ;
	short bottom_edge_mm ;
	short hout ;	/* return values from vst_alignment	*/
	short vout ;
	short clip_array[4] ;
	
	clippath = clip_setup() ;
	clip_clear( clippath ) ;

	strcpy( filename, clippath ) ;
	strcat( filename, "scrap.img" ) ;
	write_window_to_img_file( custom_form.fm_handle, filename ) ;

	strcpy( filename, clippath ) ;
	strcat( filename, "scrap.gem" ) ;

	busy( BUSY_MORE ) ;
	params.use_gdos = TRUE ;
	open_gdos_prn( &params, filename, 31 ) ;

	if( params.prn_handle )
	{
		adjust_tree_position() ;

		right_edge_mm = pix2mm( custom_display.custom_box.g_w, 0, XDIST, &custom_display ) ;
		bottom_edge_mm = pix2mm( custom_display.custom_box.g_h, 0, YDIST, &custom_display ) ;

		custom_printout.handle = params.prn_handle ;
		custom_printout.pixel_width = prn_pixel_width ;
		custom_printout.pixel_height = prn_pixel_height ;
		custom_printout.cell_height = params.cell_height ;
		custom_printout.custom_box.g_x = 0 ;
		custom_printout.custom_box.g_y = 0 ;
		custom_printout.custom_box.g_w = mm2pix( right_edge_mm, 0, XDIST, &custom_printout ) ;
		custom_printout.custom_box.g_h = mm2pix( bottom_edge_mm, 0, YDIST, &custom_printout ) ;

		vst_alignment( custom_printout.handle, CENTRE, BASE, &hout, &vout ) ;
		assert( hout == CENTRE ) ;
		assert( vout == BASE) ;
		
		grect2pxy( &(custom_printout.custom_box), clip_array ) ;
		vs_clip( custom_printout.handle, 1, clip_array ) ;

		draw_custom_tree( &custom_printout, custom_printout.custom_box,
							custom_display.x_start, custom_display.y_start, NULL ) ;
		end_page( &params, FALSE ) ;
		close_printer( &params ) ;
	}
	busy( BUSY_LESS ) ;

	clip_finish() ;
}

