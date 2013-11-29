/************************************************************************/
/*																		*/
/*		Genfoot.c	 5 Dec 99											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"
#endif

#include "genhd.h"
#include "genfoot.h"
#include "genutil.h"
#include "genmain.h"
#include "genpprn.h"
#include "genprnt.h"

extern char data_directory[] ;
extern FONTINFO fontinfo ;
extern BOOLEAN gdos_params_valid ;

const char* const footer_help = "Setting Footers" ;

Footers footers, saved_footers ;


Footer_line_addrs footer_addrs[FOOTER_LINES] ;

OBJECT* footers_ptr ;



void  set_footer_addrs( void )
{
	short i ;

	assert( FOOTER2 == FOOTER1 + FOOTER_OFFSET ) ;
	assert( LEFT2 == LEFT1 + FOOTER_OFFSET ) ;
	assert( CENTRE2 == CENTRE1 + FOOTER_OFFSET ) ;
	assert( RIGHT2 == RIGHT1 + FOOTER_OFFSET ) ;
	assert( FOOTER3 == FOOTER2 + FOOTER_OFFSET ) ;
	assert( LEFT3 == LEFT2 + FOOTER_OFFSET ) ;
	assert( CENTRE3 == CENTRE2 + FOOTER_OFFSET ) ;
	assert( RIGHT3 == RIGHT2 + FOOTER_OFFSET ) ;
	assert( FOOTER4 == FOOTER3 + FOOTER_OFFSET ) ;
	assert( LEFT4 == LEFT3 + FOOTER_OFFSET ) ;
	assert( CENTRE4 == CENTRE3 + FOOTER_OFFSET ) ;
	assert( RIGHT4 == RIGHT3 + FOOTER_OFFSET ) ;

	for( i=0; i<FOOTER_LINES; i++ )
	{
		footer_addrs[i].l = FORM_TEXT( footers_ptr, LEFT1 + FOOTER_OFFSET * i ) ;
		footer_addrs[i].c = FORM_TEXT( footers_ptr, CENTRE1 + FOOTER_OFFSET * i ) ;
		footer_addrs[i].r = FORM_TEXT( footers_ptr, RIGHT1 + FOOTER_OFFSET * i ) ;
	}
}


void  set_footers( void )
{
	BOOLEAN done = FALSE ;
	short button ;
	short old_footer_lines = footer_lines() ;
	
	copy_footers_to_form() ;
	app_modal_init( footers_ptr, footer_help, TITLED ) ;

	while( !done )
	{
		button = app_modal_do() ;
		button &= ~DOUBLE_CLICK ;

		if( button && button != APP_MODAL_TERM )
		{
			footers_ptr[button].ob_state &= ~SELECTED ;
			objc_draw( footers_ptr, button, 0, PTRS( app_modal_box() ) ) ;
		}

		switch( button )
		{
			case FOOTER_OK :
				copy_form_to_footers() ;
				done = TRUE ;
				break ;
			case FOOTER_CANCEL :
			case APP_MODAL_TERM :
				done = TRUE ;
				break ;
			case FOOTER_SAVE :
				copy_form_to_footers() ;
				saved_footers = footers ;
				save_defaults() ;
				done = TRUE ;
				break ;
			case FOOTER_HELP :
				help( footer_help ) ;
				break ;
			default :
				break ; 
		}
	}

	if( footer_lines() != old_footer_lines )  gdos_params_valid = FALSE ;
							/* This will force draw_custom_pages	*/
							/* to get a correct value				*/

	app_modal_end() ;
}


void  clear_footers( void )
{
	short i ;
	
	for( i=0 ; i<FOOTER_LINES ; i++ )
	{
		footers.line[i].enable = FALSE ;
		strcpy( footers.line[i].left, "" ) ;
		strcpy( footers.line[i].centre, "" ) ;
		strcpy( footers.line[i].right, "" ) ;
	}
}


void  copy_footers_to_form( void )
{
	short i ;
	
	for( i=0 ; i<FOOTER_LINES ; i++ )
	{
		if( footers.line[i].enable )  footers_ptr[FOOTER1 + i * FOOTER_OFFSET].ob_state |= SELECTED ;
		else  footers_ptr[FOOTER1 + i * FOOTER_OFFSET].ob_state &= ~SELECTED ;
		strcpy( footer_addrs[i].l, footers.line[i].left ) ;
		strcpy( footer_addrs[i].c, footers.line[i].centre ) ;
		strcpy( footer_addrs[i].r, footers.line[i].right ) ;
	}
}


void  copy_form_to_footers( void )
{
	short i ;
	
	for( i=0 ; i<FOOTER_LINES ; i++ )
	{
		if( footers_ptr[FOOTER1 + i * FOOTER_OFFSET].ob_state & SELECTED )  footers.line[i].enable = TRUE ;
		else  footers.line[i].enable = FALSE ;
		strcpy( footers.line[i].left, footer_addrs[i].l ) ;
		strcpy( footers.line[i].centre, footer_addrs[i].c ) ;
		strcpy( footers.line[i].right, footer_addrs[i].r ) ;
	}
}


void  use_saved_footers()
{
	footers = saved_footers ;
}


void  load_saved_footer_param( int param, char *buf_ptr )
{
	switch( param )
	{
		case 'fe1' :
		case 'fe2' :
		case 'fe3' :
		case 'fe4' :
			saved_footers.line[param - 'fe1'].enable = ( *buf_ptr == 'y' ) ;
			break ;
		case 'fl1' :
		case 'fl2' :
		case 'fl3' :
		case 'fl4' :
			strcpy( saved_footers.line[param - 'fl1'].left, buf_ptr ) ;
			break ;
		case 'fc1' :
		case 'fc2' :
		case 'fc3' :
		case 'fc4' :
			strcpy( saved_footers.line[param - 'fc1'].centre, buf_ptr ) ;
			break ;
		case 'fr1' :
		case 'fr2' :
		case 'fr3' :
		case 'fr4' :
			strcpy( saved_footers.line[param - 'fr1'].right, buf_ptr ) ;
			break ;
		default :
			break ;
	}
}


void  store_saved_footer_params( FILE *fp )
{
	short i ;
	char param_string[] = "fe0";
	
	for( i=0 ; i<FOOTER_LINES ; i++ )
	{
		param_string[2]++ ;
		save_yes_no_param( param_string, saved_footers.line[i].enable, fp ) ;
		fprintf( fp, "fl%hd%s\n", i+1, saved_footers.line[i].left ) ;
		fprintf( fp, "fc%hd%s\n", i+1, saved_footers.line[i].centre ) ;
		fprintf( fp, "fr%hd%s\n", i+1, saved_footers.line[i].right ) ;
	}
}


short  footer_lines( void )
{
	short lines = 0 ;
	short i ;
	
	for( i=0 ; i<FOOTER_LINES ; i++ )  if( footers.line[i].enable )  lines++ ;
	
	return lines ;
}


void  print_footer_lines( Str_prt_params *ps_ptr )
{
	char buffer[FOOTER_CHARS+1] ;
	short line = 0 ;
	Str_prt_params params ;
	
	params = *ps_ptr ;
	
	if( params.use_gdos )  setup_font( &params, fontinfo ) ;
	
	params.y_pos = params.chs_up ;	/* for GDOS ensures footer in right place			*/
	params.align = LEFT ;
	params.max_len = 0 ;			/* turn off justification							*/
	params.chs_up = 32767 ;			/* to avoid infinite nested calls to print footers	*/
	if( footer_lines() )  printout_strings( " ", NULL, &params ) ;
	for( line = 0; line < FOOTER_LINES ; line++ )
	{
		if( footers.line[line].enable )
		{
			params.x_pos = 0 ;
			params.align = LEFT ;
			params.downlines = 0 ;
			form_footer_part( buffer, footers.line[line].left, params.ref1, params.ref2, params.page ) ;
			printout_strings( buffer, NULL, &params ) ;
			params.x_pos = params.chs_across / 2 ;
			params.align = CENTRE ;
			form_footer_part( buffer, footers.line[line].centre, params.ref1, params.ref2, params.page ) ;
			printout_strings( buffer, NULL, &params ) ;
			params.x_pos = params.chs_across ;
			params.align = RIGHT ;
			params.downlines = 1 ;
			form_footer_part( buffer, footers.line[line].right, params.ref1, params.ref2, params.page ) ;
			printout_strings( buffer, NULL, &params ) ;
		}
	}
}


void  form_footer_part( char *buffer, const char *template, int ref1, int ref2, short page )
{
	const char *src = template ;
	char *dest = buffer ;
	char ch ;
	char local_buffer[FOOTER_CHARS+1] ;
	short length = 0 ;
	
	while( ch = *src++, ch && length < FOOTER_CHARS )
	{
		if( ch == '%' )
		{
			ch = *src++ ;
			switch( ch )
			{
				case 'd' :			/* date			*/
					form_todays_date( local_buffer ) ;
					break ;
				case 'f' :			/* filename		*/
					sprintf( local_buffer, "%s", data_directory ) ;
					break ;
				case 'n' :			/* name(s)		*/
					if( ref1 )  names_only( ref1, local_buffer, 0, TRUE ) ;
					else  local_buffer[0] = '\0' ;
					if( ref2 )
					{
						strcat( local_buffer, " & " ) ;
						names_only( ref2, local_buffer + strlen( local_buffer ), 0, TRUE ) ;
					}
					break ;
				case 'p' :			/* page number	*/
					sprintf( local_buffer, "%hd", page ) ;
					break ;
				default :
					sprintf( local_buffer, "%c", ch ) ;
					break ;
			}
			*dest = '\0' ;
			strncpy( dest, local_buffer, FOOTER_CHARS - strlen( buffer ) ) ;
			buffer[FOOTER_CHARS] = '\0' ;
			length = strlen( buffer ) ;
			dest = buffer + length ;
		}
		else
		{
			*dest++ = ch ;
			length++ ;
		}
	}
	buffer[length] = '\0' ;
}
