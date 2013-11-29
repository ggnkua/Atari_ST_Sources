/************************************************************************/
/*																		*/
/*		Genprnt.c	 5 May 99											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"
#endif

#include "genhd.h"
#include "genprnt.h"
#include "genutil.h"
#include "genfoot.h"
#include "genfsel.h"

extern short printer_lines ;		/* maximum lines for printout		*/
extern short printer_chars ;		/* maximum characters for printout	*/
extern short printer_x_offset ;		/* std printer left margin			*/
extern short printer_y_offset ;		/* std printer top margin			*/
extern short printer_type  ;		/* std printer, GDOS or to file		*/
extern short page_pause ;			/* pause between pages flag			*/
extern short gdos_page_pause ;		/* pause between pages flag			*/
extern short file_chars ;			/* maximum chars for file printout	*/
extern short file_x_offset ;		/* file print left margin			*/
extern short printer_device_number ;	/* GDOS device number			*/
extern short device_type ;			/* device type set in v_opnwk		*/
BOOLEAN gdos_params_valid ;

extern short device_width, device_height ;
										/* gdos page width & height		*/
extern short gdos_x_offset, gdos_y_offset ;
										/* gdos left and top margins	*/
extern FONTINFO fontinfo ;

extern short printer_type  ;			/* std printer, GDOS or to file	*/
extern char formfeed[] ;				/* ........... to form feed		*/
extern short prn_pixel_width, prn_pixel_height ;

extern short scr_handle ;				/* GEM vdi handle used by AES	*/
extern short scr_pixel_width, scr_pixel_height ;

extern short device_type ;						/* device type set in v_opnwk	*/
extern short print_width, print_height ;		/* printer page width & height	*/
		 										/* in pixels					*/
extern short page_width_mm, page_height_mm ;	/* printer page width & height	*/
												/* in mm						*/


char init_printer[32] ;				/* sent to printer to initialise it	*/
char formfeed[32] ;					/* ............... to form feed		*/
char separator[32] ;				/* sent to file between sections	*/

OBJECT *check_print_ptr ;

BOOLEAN  start_print_checking( Str_prt_params *ps_ptr )
{
	BOOLEAN started ;
	
	started = app_modal_init( check_print_ptr, NULL, TRUE ) ;
	if( started )
	{
		ps_ptr->check_printer = CHECK_PRINTER_OK ;
		app_modal_first_draw() ;			/* To get dialogue drawn	*/
	}
	else  ps_ptr->check_printer = CHECK_PRINTER_OFF ;
	
	return  started ;
}


BOOLEAN  check_printing( Str_prt_params *ps_ptr )
{
	short button ;
	BOOLEAN stop ;

	if( !ps_ptr || ps_ptr->check_printer == CHECK_PRINTER_OFF )  return TRUE ;
	
	if( printing_ok( ps_ptr ) )
	{
		button = app_modal_button_check( CANCEL_PRINTING ) ;
		check_print_ptr[CANCEL_PRINTING].ob_state &= ~SELECTED ;
	
		stop = ( button == CANCEL_PRINTING ) ;
		if( stop )
		{
			app_modal_end() ;
			ps_ptr->check_printer = CHECK_PRINTER_STOPPED ;
		}
	}
	else  stop = TRUE ;

	return  !stop ;
}


BOOLEAN  printing_ok( Str_prt_params *ps_ptr )
{
	return  ( ps_ptr->check_printer != CHECK_PRINTER_STOPPED ) ;
}


BOOLEAN  print_testing( Str_prt_params *ps_ptr )
{
	return  ( ps_ptr->check_printer == CHECK_PRINTER_STOPPED ) ;
}


void  stop_print_checking( Str_prt_params *ps_ptr )
{
	if( ps_ptr->check_printer == CHECK_PRINTER_OK )
	{
		app_modal_end() ;
		ps_ptr->check_printer = CHECK_PRINTER_STOPPED ;
	}
}


void  close_printer( Str_prt_params *ps_ptr )
{
	short end_gdp[] = { 81 } ;
	short dummy[] = { 0, 0 } ;

	stop_print_checking( ps_ptr ) ;
	if( ps_ptr->prn_handle )
	{
		if( device_type == METAFILE )
			v_write_meta( ps_ptr->prn_handle, 1, end_gdp, 0, dummy ) ;
		v_clswk( ps_ptr->prn_handle ) ;
	}
	else if( ps_ptr->fp )
	{
		if( printer_type != STD_PRNT )  fclose( ps_ptr->fp ) ;
		else  fflush( ps_ptr->fp ) ;
	}
}
			

void  end_page( Str_prt_params *ps_ptr, BOOLEAN more )
{
	short button ;

	if( printing_ok( ps_ptr ) && ps_ptr->use_gdos )
	{
		v_attrs( ps_ptr->prn_handle, PRN_SAVE ) ;

		if( printing_ok( ps_ptr ) && footer_lines() )  print_footer_lines( ps_ptr ) ;

		v_updwk( ps_ptr->prn_handle ) ;
		v_clrwk( ps_ptr->prn_handle ) ;
		v_attrs( ps_ptr->prn_handle, PRN_RESTORE ) ;
		if( printing_ok( ps_ptr ) && more && gdos_page_pause )
		{
			stop_print_checking( ps_ptr ) ;
			button = rsrc_form_alert( 1, P_PAUSE ) ;
			if( button == 1 )  start_print_checking( ps_ptr ) ;
		}
	}
	else if( printer_type == STD_PRNT && ps_ptr->y_pos != 0 )
	{
		if( printing_ok( ps_ptr ) && footer_lines() )
		{
			while( ps_ptr->y_pos < ps_ptr->chs_up )
			{
				ps_ptr->y_pos++ ;
				fputc( '\n', ps_ptr->fp ) ;
			}
			print_footer_lines( ps_ptr ) ;
		}
		page_feed( ps_ptr, more ) ;
	}
	else if( printer_type == FILE_PRNT )
		fputs( separator, ps_ptr->fp ) ;
	
	ps_ptr->y_pos = 0 ;
}


void  next_page( Str_prt_params *ps_ptr ) 
{
	short i ;

	end_page( ps_ptr, TRUE ) ;

	if( !ps_ptr->use_gdos )
	{
		i = ps_ptr->y_offset ;
		while( 0 < i-- )  fputc( '\n', ps_ptr->fp ) ;
	}
	ps_ptr->page++ ;
}


void  page_feed( Str_prt_params *ps_ptr, BOOLEAN more )
{
	short button ;
	
	fputs( formfeed, ps_ptr->fp ) ;
	if( more && page_pause )
	{
		fflush( ps_ptr->fp ) ;

		stop_print_checking( ps_ptr ) ;
		button = rsrc_form_alert( 1, P_PAUSE ) ;
		if( button == 1 )  start_print_checking( ps_ptr ) ;
	}
}


short  print_str( OBJECT *form_ptr, short field, char *str_ptr,
					short ignore_blank, Str_prt_params *ps_ptr )
{
	char buffer[256] ;
	short blank = FALSE ;

	if( ignore_blank && ( str_ptr == NULL || *str_ptr == '\0' ) )
		blank = TRUE ;

	if( !blank )
	{
		extract_string( form_ptr, field, buffer ) ;
	
		printout_strings( buffer, str_ptr, ps_ptr ) ;
	} 	

	return blank ;
}


short  print_char( OBJECT *form_ptr, short field, char chr,
					short ignore_blank, Str_prt_params *ps_ptr )
{
	char buffer[256] ;
	char chr_str[2] ;
	short blank = FALSE ;

	if( ignore_blank && chr == 0 )
		blank = TRUE ;

	if( !blank )
	{
		extract_string( form_ptr, field, buffer ) ;
	
		if( chr )
		{
			sprintf( chr_str, "%c", (int) chr ) ;
			printout_strings( buffer, chr_str, ps_ptr ) ;
		}
		else  printout_strings( buffer, 0, ps_ptr ) ;
	} 	

	return blank ;
}


short  print_date( OBJECT *form_ptr, short field, int date,
					short ignore_blank, Str_prt_params *ps_ptr )
{
	char buffer[256] ;
	char *date_ptr, date_str[11] ;
	char qualifier ;
	short blank = FALSE ;

	if( ignore_blank && date == 0 )
		blank = TRUE ;

	if( !blank )
	{
		extract_string( form_ptr, field, buffer ) ;
	
		if( date )
		{
			form_date( date_str, &qualifier, date, FALSE ) ;
			if( qualifier != ' ' )
			{
				date_str[0] = qualifier ;
				form_date( date_str+1, &qualifier, date, FALSE ) ;
			}
			date_ptr = date_str ;
			if( *date_ptr == '\ ' )  date_ptr++ ;
		}
		else  date_ptr = NULL ;

		printout_strings( buffer, date_ptr, ps_ptr ) ;
	} 	

	return blank ;
}


short  print_int( OBJECT *form_ptr, short field, int number,
					short ignore_blank, Str_prt_params *ps_ptr )
{
	char buffer[256] ;
	char int_str[21] ;
	short blank = FALSE ;

	if( ignore_blank && number == 0 )
		blank = TRUE ;

	if( !blank )
	{
		extract_string( form_ptr, field, buffer ) ;
	
		sprintf( int_str, "%d", number ) ;

		printout_strings( buffer, int_str, ps_ptr ) ;
	} 	

	return blank ;
}


				/* Routine to print out two strings with various tabs	*/
				/* and justifications.									*/
				/* If strings are left justified for GDOS, or non GDOS,	*/
				/* the routine ensures that they fit into the available	*/
				/* width by slicing the string into lengths which will	*/
				/* fit.													*/
void  printout_strings( char *str1, char *str2, Str_prt_params *ps_ptr )
 {
 	short i, spaces ;					/* loop counters				*/
	short x_pos1, x_pos2 ;				/* positions of 1st & 2nd strs	*/
	char buffer[256] ;
	char *print_str ;
	short last_x ;
	short dummy ;
	

	if( !check_printing( ps_ptr ) )  return ;
	
	if( ps_ptr->y_pos >= ps_ptr->chs_up )  next_page( ps_ptr ) ;

	if( ps_ptr->use_gdos )
	{
		switch( ps_ptr->align )
		{
			case RIGHT :
				vst_alignment( ps_ptr->prn_handle, RIGHT,
					0, &dummy, &dummy ) ;
				x_pos2 = ps_ptr->x_pos ;
				x_pos1 = x_pos2 - ps_ptr->tabpos ;
				break ;
			case LEFT :
			case LEFT_WRAP :
				vst_alignment( ps_ptr->prn_handle, LEFT,
					0, &dummy, &dummy ) ;
				x_pos1 = ps_ptr->x_pos ;
				x_pos2 = x_pos1 + ps_ptr->tabpos ;
				break ;
			case CENTRE :
				vst_alignment( ps_ptr->prn_handle, CENTRE,
					0, &dummy, &dummy ) ;
				if( str2 )  x_pos1 = ps_ptr->x_pos
					- ( strlen( str2 ) + ps_ptr->tabpos ) /2 ;
				else  x_pos1 = ps_ptr->x_pos ;
				x_pos2 = x_pos1 + ps_ptr->tabpos ;
				break ;
			default :
#ifndef NDEBUG
				str_report( "Invalid justification" ) ;
				str_report( "First string" ) ;
				report( ps_ptr->align ) ;
				str_report( str1 ) ;
				str_report( str2 ) ;
#endif
				break ;
		}
		if( str1 && str1[0] != '\0' )
		{
			if( !ps_ptr->max_len
					&& ps_ptr->align == LEFT || ps_ptr->align == LEFT_WRAP )
								/* i.e. not justified and left aligned	*/
			{
				print_str = str1 ;
				while( get_next_slice( buffer, &print_str,
									ps_ptr, ps_ptr->chs_across - x_pos1 ) )
				{	
					v_gtext( ps_ptr->prn_handle,
						x_pos1 * ps_ptr->cell_width + ps_ptr->x_offset,
						( ps_ptr->y_pos + 1 ) * ps_ptr->cell_height
										+ ps_ptr->y_offset, buffer ) ;
							/* if line did not all fit go to next line	*/
					if( *print_str )
					{
						ps_ptr->y_pos++ ;
						if( ps_ptr->y_pos >= ps_ptr->chs_up )
							next_page( ps_ptr ) ;
					}
				}
			}
			else if( !ps_ptr->max_len )		/* i.e. not justified	*/
			{	
				v_gtext( ps_ptr->prn_handle,
						x_pos1 * ps_ptr->cell_width + ps_ptr->x_offset,
						( ps_ptr->y_pos + 1 ) * ps_ptr->cell_height
										+ ps_ptr->y_offset, str1 ) ;
			}
			else
			{
				v_justified( ps_ptr->prn_handle, 
					x_pos1 * ps_ptr->cell_width + ps_ptr->x_offset,
					( ps_ptr->y_pos + 1 ) * ps_ptr->cell_height + ps_ptr->y_offset, str1,
					ps_ptr->max_len * ps_ptr->cell_width, 1, 0 ) ;
			}
		}
		if( str2 )
		{	
			if( ps_ptr->align == LEFT || ps_ptr->align == LEFT_WRAP )
			{
				print_str = str2 ;
				while( get_next_slice( buffer, &print_str,
									ps_ptr, ps_ptr->chs_across - x_pos2 ) )
				{	
					v_gtext( ps_ptr->prn_handle,
						x_pos2 * ps_ptr->cell_width + ps_ptr->x_offset,
						( ps_ptr->y_pos + 1 ) * ps_ptr->cell_height
											+ ps_ptr->y_offset, buffer ) ;
							/* if line did not all fit go to next line	*/
					if( *print_str )
					{
						ps_ptr->y_pos++ ;
						if( ps_ptr->y_pos >= ps_ptr->chs_up )
							next_page( ps_ptr ) ;
					}
				}
			}
			else
			{	
				v_gtext( ps_ptr->prn_handle,
						x_pos1 * ps_ptr->cell_width + ps_ptr->x_offset,
						( ps_ptr->y_pos + 1 ) * ps_ptr->cell_height
										+ ps_ptr->y_offset, str2 ) ;
			}
		}
		ps_ptr->y_pos += ps_ptr->downlines ;
	}	
	else
	{
		switch( ps_ptr->align )
		{	case RIGHT :
				if( str2 )
					x_pos1 = ps_ptr->x_pos
										- strlen( str2 ) - ps_ptr->tabpos ;
				else  x_pos1 = ps_ptr->x_pos - strlen( str1 ) ;
				break ;
			case CENTRE :
				if( str2 )
					x_pos1 = ps_ptr->x_pos
						- ( ps_ptr->tabpos + strlen( str2 ) ) / 2 ;
				else  x_pos1 = ps_ptr->x_pos - strlen( str1 ) / 2 ;
				break ;
			case LEFT :
			case LEFT_WRAP :
				x_pos1 = ps_ptr->x_pos ;
				break ;
			default :
#ifndef NDEBUG
				str_report( "Invalid justification" ) ;
				str_report( "Second string" ) ;
				report( ps_ptr->align ) ;
				str_report( str1 ) ;
				str_report( str2 ) ;
#endif
				break ;
		}
		
		x_pos1 += ps_ptr->x_offset ;

		x_pos2 = x_pos1 + ps_ptr->tabpos ;

		spaces = x_pos1 - ps_ptr->last_x_end ;
		i = 0 ;
		while( i++ < spaces )  fputc( ' ', ps_ptr->fp ) ;

		buffer[0] = '\0' ;
		print_str = str1 ;
		while( get_next_slice( buffer, &print_str, ps_ptr,
						ps_ptr->chs_across - ( x_pos1 - ps_ptr->x_offset ) ) )
		{
			fputs( buffer, ps_ptr->fp ) ;
			last_x = x_pos1 + strlen( buffer ) ;
							/* if line did not all fit go to next line	*/
			if( *print_str )
			{
				fputc( '\n', ps_ptr->fp ) ;
				ps_ptr->y_pos++ ;
				if( ps_ptr->y_pos >= ps_ptr->chs_up )
					next_page( ps_ptr ) ;
				i = x_pos1 ;
				while( 0 < i-- )  fputc( ' ', ps_ptr->fp ) ;
			}
		}

		if( str2 )
		{
			spaces = ps_ptr->tabpos - strlen( buffer ) ;
			i = 0 ;
			while( i++ < spaces )  fputc( ' ', ps_ptr->fp ) ;

			print_str = str2 ;
			while( get_next_slice( buffer, &print_str, ps_ptr,
				ps_ptr->chs_across - ( x_pos1 - ps_ptr->x_offset ) - ps_ptr->tabpos ) )
			{
				fputs( buffer, ps_ptr->fp ) ;
				last_x = x_pos1 + ps_ptr->tabpos + strlen( buffer ) ;
				if( *print_str )
				{
					fputc( '\n', ps_ptr->fp ) ;
					ps_ptr->y_pos++ ;
					if( ps_ptr->y_pos >= ps_ptr->chs_up )
						next_page( ps_ptr ) ;
					i = x_pos2 ;
					while( 0 < i-- )  fputc( ' ', ps_ptr->fp ) ;
				}
			}
		}
		for( i=0; i<ps_ptr->downlines; i++ )
		{
			if( ps_ptr->y_pos < ps_ptr->chs_up )
			{
				fputs( "\n", ps_ptr->fp ) ;
				ps_ptr->y_pos++ ;
			}
			else
			{
				next_page( ps_ptr ) ;
				i = ps_ptr->downlines ;	/* force exit	*/
			}
		}
	}
		
	if( ps_ptr->downlines )  ps_ptr->last_x_end = 0 ;
	else  ps_ptr->last_x_end = last_x ;
}


void  down_n_lines( short n, Str_prt_params *ps_ptr )
{
	short i ;
	
	if( ps_ptr->use_gdos )  ps_ptr->y_pos += n ;
	else
	{
		for( i=0; i<n; i++ )
		{
			if( ps_ptr->y_pos < ps_ptr->chs_up )
			{
				fputs( "\n", ps_ptr->fp ) ;
				ps_ptr->y_pos++ ;
			}
			else
			{
				next_page( ps_ptr ) ;
				i = n ;	/* force exit	*/
			}
		}
	}
}
	


short  open_printer( Str_prt_params *ps_ptr )
{
	static char print_file[FMSIZE+FNSIZE] = "" ;

	short button ;					/* button pressed for file selector	*/
	int res ;						/* return value for file selector	*/
	short opened_flag = FALSE ;
	short i ;

	busy( BUSY_MORE ) ;
	
	if( printer_type == GDOS_PRNT )  ps_ptr->use_gdos = TRUE ;
	else  ps_ptr->use_gdos = FALSE ;
	
	if( ps_ptr->use_gdos )
	{
		open_gdos_prn( ps_ptr, NULL, printer_device_number ) ;
		ps_ptr->fp = NULL ;
	}
	else
	{	
		ps_ptr->cell_width = 1 ;
		ps_ptr->cell_height = 1 ;
		ps_ptr->prn_handle = 0 ;
		if( printer_type == STD_PRNT )
		{	
			ps_ptr->chs_across = printer_chars ;
			ps_ptr->chs_up = printer_lines ;
			if( footer_lines() )  ps_ptr->chs_up -=  footer_lines() + 1 ;
			ps_ptr->x_offset = printer_x_offset ;
			ps_ptr->y_offset = printer_y_offset ;

			ps_ptr->fp = stdprt ;
			fputs( init_printer, ps_ptr->fp ) ;
		}
		else if( printer_type == FILE_PRNT )
		{	
			ps_ptr->chs_across = file_chars ;
			ps_ptr->chs_up = 0x7FFF ;	/* assumed virtually infinite		*/
			ps_ptr->x_offset = file_x_offset ;
			ps_ptr->y_offset = 0 ;

			res = fsel_geninput( print_file, "A:\\PRINT.GEN", &button, PRNT_FILE ) ;

			if( res && button )
				ps_ptr->fp = fopen( print_file, "w" ) ;
			else ps_ptr->fp = NULL ;
		}
		if( ps_ptr->fp )
		{
			if( i = ps_ptr->y_offset, i > 0 )
				while( 0 < i-- )  fputc( '\n', ps_ptr->fp ) ;

								/* set to start of line when no y offset	*/
			fputc( '\r', ps_ptr->fp ) ;
		}

	}
	
	ps_ptr->page = 1 ;
	ps_ptr->ref1 = 0 ;
	ps_ptr->ref2 = 0 ;
	
	if( ps_ptr->prn_handle || ps_ptr->fp )
	{
		opened_flag = TRUE ;
		if( printer_type == FILE_PRNT )  ps_ptr->check_printer = CHECK_PRINTER_OFF ;
		else  ps_ptr->check_printer = CHECK_PRINTER_OK ;
	}

	busy( BUSY_LESS ) ;
	
	return opened_flag ;
}


void  open_gdos_prn( Str_prt_params *ps_ptr, char *metafile_name, short pdev )
{
	short work_in[11] = { 21, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2 } ;
	short work_out[57] ;
	static char filename[FMSIZE + FNSIZE] = "" ;
	char default_filename[FMSIZE + FNSIZE] = "A:\\" ;
	short drive ;
	short res, button ;
	short start_gdp[] = { 80 } ;
	short dummy[] = { 0, 0 } ;
	short print_x_offset, print_y_offset ;	/* printer page offsets in		*/
											/* pixels						*/

#ifdef BARBER
fstr_report( "open gdos printer" ) ;
#endif
	if( vq_vgdos() == GDOS_NONE )  rsrc_form_alert( 1, NO_GDOS ) ;
	else
	{
		work_in[0] = pdev ;
		v_opnwk( work_in, &(ps_ptr->prn_handle), work_out ) ;
#ifdef BARBER
fstr_report( "ps_ptr->prn_handle" ) ;
#endif
#ifdef BARBER
freport( (int) ps_ptr->prn_handle ) ;
#endif

		if( ps_ptr->prn_handle )
		{
			device_type = work_out[DEVICE_TYPE] ;

						/*************** Input device ***********************/
			if( device_type == INPUT_DEVICE )
			{
				rsrc_form_alert( 1, INPUT_ONLY ) ;
				v_clswk( ps_ptr->prn_handle ) ;
				ps_ptr->prn_handle = 0 ;
			}
						/*************** Metafile ***************************/
			else if( device_type == METAFILE )
			{
				if( !metafile_name )
				{
					drive = Dgetdrv() ;
					default_filename[0] = 'A' + drive ;
					strcat( default_filename, "METAFILE.GEM" ) ;
					res = fsel_geninput( filename, default_filename, &button,
																SELECT_METAFILE ) ;
				}
				else
					strcpy( filename, metafile_name ) ;

				if( metafile_name || ( res && button ) )
				{	
					vm_filename( ps_ptr->prn_handle, filename ) ;
 					remove( "GEMFILE.GEM" ) ;
							/* A4 width and height in multiples of 100um	*/
					vm_pagesize( ps_ptr->prn_handle, A4_WIDTH, A4_HEIGHT ) ;
					vm_coords( ps_ptr->prn_handle, 0, A4_HEIGHT, A4_WIDTH, 0 ) ;
					v_meta_extents( ps_ptr->prn_handle, 0, A4_HEIGHT, A4_WIDTH, 0 ) ;
					v_write_meta( ps_ptr->prn_handle, 1, start_gdp, 0, dummy ) ;
					prn_pixel_width = 100 ;
					prn_pixel_height = 100 ;
					
					if( device_width )  print_width = device_width * 10 ;
					else  print_width = A4_WIDTH ;
					
					if( device_height )  print_height = device_height * 10 ;
					else  print_height = A4_HEIGHT ;

					print_x_offset = gdos_x_offset * 10 ;
					print_y_offset = gdos_y_offset * 10 ;
					vq_extnd( ps_ptr->prn_handle, 0, work_out ) ;
				}
				else
				{
					v_clswk( ps_ptr->prn_handle ) ;
					ps_ptr->prn_handle = 0 ;
				}
			}
						/*************** Printer ****************************/
			else
			{	
				prn_pixel_width = work_out[PIXEL_WIDTH] ;
				prn_pixel_height = work_out[PIXEL_HEIGHT] ;
#ifdef BARBER
fstr_report( "prn_pixel_width" ) ;
#endif
#ifdef BARBER
freport( prn_pixel_width ) ;
#endif
#ifdef BARBER
fstr_report( "prn_pixel_height" ) ;
#endif
#ifdef BARBER
freport( prn_pixel_height ) ;
#endif
#ifdef BARBER
fstr_report( "device_width" ) ;
#endif
#ifdef BARBER
freport( device_width ) ;
#endif

				if( prn_pixel_width )
					print_x_offset = gdos_x_offset * 1000l / prn_pixel_width ;
				else  print_x_offset = 0 ;
				if( prn_pixel_height )
					print_y_offset = gdos_y_offset * 1000l / prn_pixel_height ;
				else  print_y_offset = 0 ;
				if( prn_pixel_width && device_width )
					print_width = (short) ( device_width * 1000l
												/ prn_pixel_width ) ;
				else  print_width = work_out[DEVICE_WIDTH] ;
#ifdef BARBER
fstr_report( "print_width" ) ;
#endif
#ifdef BARBER
freport( print_width ) ;
#endif
				if( work_out[DEVICE_WIDTH] < print_width + print_x_offset )
				{
					if( device_width )		/* ie if user has specified width	*/
					{
						if( work_out[DEVICE_WIDTH] < print_width )
							print_width = work_out[DEVICE_WIDTH] ;
						print_x_offset = work_out[DEVICE_WIDTH] - print_width ;
					}
					else
					{
						if( work_out[DEVICE_WIDTH] < print_x_offset )
						{
							print_x_offset = 0 ;
							if( work_out[DEVICE_WIDTH] < print_width )
								print_width = work_out[DEVICE_WIDTH] ;
						}
						else
							print_width = work_out[DEVICE_WIDTH] - print_x_offset ;
					}
				}
#ifdef BARBER
fstr_report( "page_width_mm" ) ;
#endif
#ifdef BARBER
freport( page_width_mm ) ;
#endif
#ifdef BARBER
fstr_report( "device_height" ) ;
#endif
#ifdef BARBER
freport( device_height ) ;
#endif

				if( prn_pixel_height && device_height )
					print_height = (short) ( device_height * 1000l
												/ prn_pixel_height ) ;
				else  print_height = work_out[DEVICE_HEIGHT] ;
				
				if( work_out[DEVICE_HEIGHT] < print_height + print_y_offset )
				{
					if( device_height )		/* ie if user has specified height	*/
					{
						if( work_out[DEVICE_HEIGHT] < print_height )
							print_height = work_out[DEVICE_HEIGHT] ;
						print_y_offset = work_out[DEVICE_HEIGHT] - print_height ;
					}
					else
					{
						if( work_out[DEVICE_HEIGHT] < print_y_offset )
						{
							print_y_offset = 0 ;
							if( work_out[DEVICE_HEIGHT] < print_height )
								print_height = work_out[DEVICE_HEIGHT] ;
						}
						else
							print_height = work_out[DEVICE_HEIGHT] - print_y_offset ;
					}
				}
				if( work_out[DEVICE_HEIGHT] < print_height )
					print_height = work_out[DEVICE_HEIGHT] ;
			}
		}

		if( ps_ptr->prn_handle )
		{
			vst_color( ps_ptr->prn_handle, BLACK ) ;
			vswr_mode( ps_ptr->prn_handle, MD_TRANS ) ;

			vst_load_fonts( ps_ptr->prn_handle, 0 ) ;
			setup_font( ps_ptr, fontinfo ) ;
			
			page_width_mm = ((long) print_width) * prn_pixel_width / 1000 ;
			if( footer_lines() )
			{
				ps_ptr->chs_up -= footer_lines() + 1 ;
				print_height -= ( footer_lines() + 1 ) * ps_ptr->cell_height ;
			}
			page_height_mm = ((long) print_height) * prn_pixel_height / 1000 ;
			
			ps_ptr->x_offset = print_x_offset ;
			ps_ptr->y_offset = print_y_offset ;
			
			gdos_params_valid = TRUE ;
		}
	}
#ifdef BARBER
fstr_report( "page_height_mm" ) ;
#endif

#ifdef BARBER
freport( page_height_mm ) ;
#endif

#ifdef BARBER
fstr_report( "gdos printer opened" ) ;
#endif
}



void  setup_font( Str_prt_params *ps_ptr, FONTINFO fontinfo )
{
	short dummy ;
	short char_height, cell_width, cell_height ;
	short pts[8] ;

	use_fontinfo( ps_ptr->prn_handle, fontinfo ) ;

	if( device_type != METAFILE )
	{
		if( vq_vgdos() == GDOS_FSM )
			vst_arbpt( ps_ptr->prn_handle, fontinfo.font_size, &dummy,
									&char_height, &dummy, &cell_height ) ;
		else
			vst_point( ps_ptr->prn_handle, fontinfo.font_size, &dummy,
									&char_height, &dummy, &cell_height ) ;

								/* measure 8 n's to find typical width	*/
		vqt_extent( ps_ptr->prn_handle, "nnnnnnnn", pts ) ;
		cell_width = ( pts[2] - pts[0] ) / 8 ;
	}
	else
	{
		/* for metafiles it is not possible to obtain character size	*/
		/* information. Hence this routine determines the sizes if the	*/
		/* font were used on screen and then scales them according to	*/
		/* the relative pixel sizes.									*/
		vst_font( scr_handle, fontinfo.font_index ) ;
		if( vq_vgdos() == GDOS_FSM )
			vst_arbpt( scr_handle, fontinfo.font_size, &dummy,
									&char_height, &dummy, &cell_height ) ;
		else
			vst_point( scr_handle, fontinfo.font_size, &dummy,
									&char_height, &dummy, &cell_height ) ;
								/* measure 8 n's to find typical width	*/
		vqt_extent( scr_handle, "nnnnnnnn", pts ) ;
		cell_width = ( pts[2] - pts[0] ) / 8 ;

		char_height = (short) ( (long) char_height * scr_pixel_height
													/ prn_pixel_height ) ;
		cell_height = (short) ( (long) cell_height * scr_pixel_height
													/ prn_pixel_height ) ;
		cell_width = (short) ( (long) cell_width * scr_pixel_width
													/ prn_pixel_width ) ;
		vst_font( scr_handle, SYSTEM_FONT ) ;	/* restore screen to system font	*/
	}

	ps_ptr->chs_across = print_width / cell_width ;
	ps_ptr->cell_width = cell_width ;
	ps_ptr->chs_up = print_height / cell_height ;
	ps_ptr->cell_height = cell_height ;
	ps_ptr->char_height = char_height ;
}
