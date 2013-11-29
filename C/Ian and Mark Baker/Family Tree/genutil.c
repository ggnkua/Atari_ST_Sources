/************************************************************************/
/*																		*/
/*		Genutil.c	30 Jun 02											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "genutil.h"
#include "gencoup.h"
#include "gendata.h"
#include "gendesc.h"
#include "gendraw.h"
#include "genmain.h"
#include "gennote.h"
#include "genpers.h"
#include "gentree.h"


#define AC_HELP 1025

#define RBUTTON_INNER_RADIUS 4
#define RBUTTON_OUTER_RADIUS 7

extern Index_person *people ;
extern Index_couple *couples ;
extern char *edit_buffer ;


extern short scr_handle, check_vdih ;
extern short device_type ;			/* device type set in v_opnwk		*/
extern FONTINFO fontinfo ;
extern short scr_pixel_width ;
extern short scr_pixel_height ;
extern short prn_pixel_width ;

extern short wchar ;

extern Wind_edit_params *wind_edit_params_ptrs[] ;
extern OBJECT *icons_ptr ;
extern OBJECT *strings_ptr ;
extern OBJECT *menu_ptr ;
extern int group_icon_handle ;
extern int ap_id ;

extern const char* const index_help ;

extern struct {
	char *ref ;
	char *fam ;
	char *fore ;
	char *bid ;
	char *bid_qual ;
	char *bip ;
	char *occ ;
	char *mother ;
	char *father ;
	char *child[4] ;
	char *spouse ;
	char *wed ;
	char *wed_qual ;
	char *wep ;
	char *ded ;
	char *ded_qual ;
	char *sib[4] ;
	char *sex ;
	char *dep ;
	char *bcp ;
	char *bcd ;
	char *bcd_qual ;
	char *desrc ;
	char *dwd ;
	char *wid_qual ;
	char *dw1 ;
	char *dw2 ;
	char *ex1 ;
	char *ex2 ;
	char *sol ;
	char *ben ;
	char *be2 ;
	char *be3 ;
	char *bad ;
	char *bad_qual ;
	char *bap ;
	char *basrc ;
	char *bisrc ;
} form_addrs ;

extern struct {
	char *ref ;
	char *male ;
	char *female ;
	char *wed ;
	char *wed_qual ;
	char *wep ;
	char *ww1 ;
	char *ww2 ;
	char *m_ref ;
	char *f_ref ;
	char *child[10] ;
	char *did ;
	char *did_qual ;
	char *disrc ;
	char *cosrc ;
} c_form_addrs ;


extern Wind_edit_params pers_form, birth_form, baptism_form, death_form ;
extern Wind_edit_params coup_form, co_src_form, divorce_form ;
extern Wind_edit_params notes_form, desc_form, tree_form, custom_form ;
extern Custom_device custom_display ;
extern short custom_fulled ;		/* flag									*/

extern char months[15][4] ;			/* loaded with month strings			*/
extern char circa[4] ;				/* string for approx data				*/

extern short top ;					/* current top window					*/
extern GRECT deskbox ;

extern Preferences prefs ;

char circa_char = 'c' ;
char before_char = 'b' ;
char after_char = 'a' ;

int wind_form_kind = NAME | CLOSE | MOVE | SMALLER ;
int group_icon_kind = NAME | MOVE ;
int app_modal_kind = NAME | MOVE ;
int untitled_app_modal_kind = 0 ;
Wind_edit_params dialogue_form ;

extern short printer_chars ;


void  send_redraw_message( const GRECT *rect, int window_handle )
{
	short msg[8] ;

	if( window_handle )
	{
		msg[0] = WM_REDRAW ;
		msg[1] = ap_id ;
		msg[2] = 0 ;
		msg[3] = window_handle ;
		msg[4] = rect->g_x ;
		msg[5] = rect->g_y ;
		msg[6] = rect->g_w ;
		msg[7] = rect->g_h ;

		appl_write( ap_id, sizeof( msg ), msg ) ;
	}
}


void  redraw_all_windows( void )
{
	if( pers_form.fm_handle )  send_redraw_message( &deskbox, pers_form.fm_handle  ) ; 
	if( notes_form.fm_handle )  send_redraw_message( &deskbox, notes_form.fm_handle  ) ; 
	if( coup_form.fm_handle )  send_redraw_message( &deskbox, coup_form.fm_handle  ) ; 
	if( tree_form.fm_handle )  send_redraw_message( &deskbox, tree_form.fm_handle  ) ; 
	if( desc_form.fm_handle )  send_redraw_message( &deskbox, desc_form.fm_handle  ) ; 
	if( custom_form.fm_handle )  send_redraw_message( &deskbox, custom_form.fm_handle  ) ; 
	if( birth_form.fm_handle )  send_redraw_message( &deskbox, birth_form.fm_handle  ) ; 
	if( baptism_form.fm_handle )  send_redraw_message( &deskbox, baptism_form.fm_handle  ) ; 
	if( death_form.fm_handle )  send_redraw_message( &deskbox, death_form.fm_handle  ) ; 
	if( co_src_form.fm_handle )  send_redraw_message( &deskbox, co_src_form.fm_handle  ) ; 
	if( divorce_form.fm_handle )  send_redraw_message( &deskbox, divorce_form.fm_handle  ) ; 
	if( dialogue_form.fm_handle )  send_redraw_message( &deskbox, dialogue_form.fm_handle  ) ; 
}


short  top_window( void )
{
	short top_handle_ptr ;
	short dummy ;
	short top = 0 ;

	wind_get( DESK, WF_TOP, &top_handle_ptr, &dummy, &dummy, &dummy ) ;

	if( top_handle_ptr )
	{
		if( top_handle_ptr == pers_form.fm_handle )  top = PERSON_WINDOW ;
		else if( top_handle_ptr == notes_form.fm_handle )  top = NOTES_WINDOW ;
		else if( top_handle_ptr == coup_form.fm_handle )  top = COUPLE_WINDOW ;
		else if( top_handle_ptr == tree_form.fm_handle )  top = TREE_WINDOW ;
		else if( top_handle_ptr == desc_form.fm_handle )  top = DESC_WINDOW ;
		else if( top_handle_ptr == custom_form.fm_handle )  top = CUSTOM_WINDOW ;
		else if( top_handle_ptr == birth_form.fm_handle )  top = BIRTH_WINDOW ;
		else if( top_handle_ptr == baptism_form.fm_handle )  top = BAPTISM_WINDOW ;
		else if( top_handle_ptr == death_form.fm_handle )  top = DEATH_WINDOW ;
		else if( top_handle_ptr == co_src_form.fm_handle )  top = CO_SOURCE_WINDOW ;
		else if( top_handle_ptr == divorce_form.fm_handle )  top = DIVORCE_WINDOW ;
		else if( top_handle_ptr == dialogue_form.fm_handle )  top = DIALOGUE_WINDOW ;
	}

	return top ;
}


short  find_window( int x, int y )
{
	short top_handle ;
	short top = 0 ;

	top_handle = wind_find( x, y ) ;

	if( top_handle )
	{
		if( top_handle == pers_form.fm_handle )  top = PERSON_WINDOW ;
		else if( top_handle == notes_form.fm_handle )  top = NOTES_WINDOW ;
		else if( top_handle == coup_form.fm_handle )  top = COUPLE_WINDOW ;
		else if( top_handle == tree_form.fm_handle )  top = TREE_WINDOW ;
		else if( top_handle == desc_form.fm_handle )  top = DESC_WINDOW ;
		else if( top_handle == custom_form.fm_handle )  top = CUSTOM_WINDOW ;
		else if( top_handle == birth_form.fm_handle )  top = BIRTH_WINDOW ;
		else if( top_handle == baptism_form.fm_handle )  top = BAPTISM_WINDOW ;
		else if( top_handle == death_form.fm_handle )  top = DEATH_WINDOW ;
		else if( top_handle == co_src_form.fm_handle )  top = CO_SOURCE_WINDOW ;
		else if( top_handle == divorce_form.fm_handle )  top = DIVORCE_WINDOW ;
	}

	return top ;
}


void  rubber_band( int vdi_handle,  short* new_m_x, short* new_m_y, short m_x, short m_y, short line_type )
{
	short pxy_array[4] ;
	short button ;
	short kstate ;

	pxy_array[0] = m_x ;
	pxy_array[1] = m_y ;
	pxy_array[2] = m_x ;
	pxy_array[3] = m_y ;
	
	wind_update( BEG_UPDATE ) ;
	wind_update( BEG_MCTRL ) ;
	vswr_mode( vdi_handle, MD_XOR ) ;
	vsl_type( vdi_handle, line_type ) ;

	graf_mouse( M_OFF, 0 ) ;		/* turn off mouse while drawing		*/
	v_box( vdi_handle, pxy_array ) ;
	graf_mouse( M_ON, 0 ) ;			/* turn on mouse after drawing		*/

	while( graf_mkstate( new_m_x, new_m_y, &button, &kstate ), button != 0 )
	{
		if( *new_m_x != pxy_array[2] || *new_m_y != pxy_array[3] )
		{
			graf_mouse( M_OFF, 0 ) ;		/* turn off mouse while drawing		*/
			v_box( vdi_handle, pxy_array ) ;
			pxy_array[2] = *new_m_x ;
			pxy_array[3] = *new_m_y ;
			v_box( vdi_handle, pxy_array ) ;
			graf_mouse( M_ON, 0 ) ;			/* turn on mouse after drawing		*/
		}
	}
	graf_mouse( M_OFF, 0 ) ;		/* turn off mouse while drawing		*/
	v_box( vdi_handle, pxy_array ) ;
	graf_mouse( M_ON, 0 ) ;			/* turn on mouse after drawing		*/

	vsl_type( vdi_handle, SOLID ) ;
	vswr_mode( vdi_handle, MD_TRANS ) ;
	wind_update( END_MCTRL ) ;
	wind_update( END_UPDATE ) ;
}


void  grect2pxy( const GRECT *gr_ptr, short *pxy_ptr )
{
	*pxy_ptr = (*gr_ptr).g_x ;
	*(pxy_ptr+1) = (*gr_ptr).g_y ;
	*(pxy_ptr+2) = *pxy_ptr + (*gr_ptr).g_w - 1 ;
	*(pxy_ptr+3) = *(pxy_ptr+1) + (*gr_ptr).g_h - 1 ;
}


short rect_end( GRECT* rect_ptr )
{
	return ( rect_ptr->g_x + rect_ptr->g_w - 1 ) ;
} 


short rect_bottom( GRECT* rect_ptr )
{
	return ( rect_ptr->g_y + rect_ptr->g_h - 1 ) ;
} 


void  scroll_line( GRECT scroll_text_box, short text_lines,
								short direction, short scroll_text_size )
{
	short *upper_ptr ;
	short *lower_ptr ;
	short pxy_array[8] ;
	short char_ht, cell_ht ;
	MFDB mfdb = { NULL, 0, 0, 0, 0, 0, 0, 0, 0, } ;
	short dummy ;

	if( direction == DOWN )
	{
		upper_ptr = &(pxy_array[0]) ;
		lower_ptr = &(pxy_array[4]) ;
	}
	else
	{
		upper_ptr = &(pxy_array[4]) ;
		lower_ptr = &(pxy_array[0]) ;
	}

	wind_update( BEG_UPDATE ) ;
	v_attrs( scr_handle, SAVE ) ;

	vst_point( scr_handle, scroll_text_size, &dummy, &char_ht,
													&dummy, &cell_ht ) ;
	*lower_ptr = scroll_text_box.g_x ;
	*(lower_ptr+1) = scroll_text_box.g_y + 2 * cell_ht - char_ht ;
	*(lower_ptr+2) = *lower_ptr + scroll_text_box.g_w - 1 ;
	*(lower_ptr+3) = *(lower_ptr+1) + cell_ht * ( text_lines - 1 ) - 1 ;
	*upper_ptr = *lower_ptr ;
	*(upper_ptr+1) = *(lower_ptr+1) - cell_ht ;
	*(upper_ptr+2) = *(lower_ptr+2) ;
	*(upper_ptr+3) = *(lower_ptr+3) - cell_ht ;

	graf_mouse( M_OFF, NULL ) ;
	vro_cpyfm( scr_handle, S_ONLY, pxy_array, &mfdb, &mfdb ) ;
	graf_mouse( M_ON, NULL ) ;

	v_attrs( scr_handle, RESTORE ) ;
	wind_update( END_UPDATE ) ;
}


void  extract_string( OBJECT *form_ptr, short field, char *buffer )
{
	short fault = FALSE ;
	char *template_ptr, *buf_ptr ;

	buf_ptr = buffer ;
	if( form_ptr )
	{
		switch( form_ptr[field].ob_type )
		{
			case G_FBOXTEXT :
			case G_FTEXT :
				template_ptr = ((TEDINFO *)form_ptr[field].ob_spec)->te_ptmplt ;
				break ;
			case G_BOXTEXT :
			case G_TEXT :
				template_ptr = ((TEDINFO *)form_ptr[field].ob_spec)->te_ptext ;
				break ;
			case G_BUTTON :
			case G_STRING :
			case G_TITLE :
				template_ptr = form_ptr[field].ob_spec ;
				break ;
			default :
#ifndef NDEBUG
				str_report( "Wrong type of field" ) ;
#endif
				fault = TRUE ;
				break ;
		}
		if( !fault )
		{
					/* remove leading blanks	*/
			while( *template_ptr == ' ' )  template_ptr++ ;
			strcpy( buffer, template_ptr ) ;
			while( *buf_ptr != '_' && *buf_ptr != '\0' )  buf_ptr++ ;
		}
	}
	*buf_ptr = '\0' ;
}


void  names_only( int ref, char *names, short chmax, short use_full_forename )
						/* This routine takes a persons fore and family	*/
						/* names and puts them into a formatted string,	*/
						/* padded with spaces to chmax characters. If	*/
						/* chmax is less than length of names, there	*/
						/* will be no padding, e.g. if chmax = 0. The	*/
						/* string will always terminate by chmax		*/
						/* characters if chmax non zero.				*/
						/* If chmax is negative, string will be limited	*/
						/* to -chmax, but not padded.					*/
						/* If ref == 0 this just writes blanks.			*/
{
	char *str_ptr ;
	short spaces ;
	char buffer[100] ;

	if( ref )  form_names( ref, buffer, chmax, use_full_forename ) ;
	else  buffer[0] = '\0' ;

	str_ptr = buffer + strlen( buffer ) ;
	spaces = chmax - strlen( buffer ) ;
	while( spaces-- > 0 )  *str_ptr++ = ' ' ;
	*str_ptr = '\0' ;

	strcpy( names, buffer ) ;
}




void  form_names( int ref, char *buffer, short chmax, short use_full_forename )
						/* Form_names concatenates persons forenames	*/
						/* and family name. If chmax is non zero the	*/
						/* string is limited to chmax characters, by	*/
						/* eliminating whole forenames if possible.		*/
						/* If chmax is negative, string will be limited	*/
						/* to -chmax, but not padded.					*/
						/* If ref is zero the string will be blanked.	*/
						/* If use_full_forename is true the forename	*/
						/* string will be fetched from the person's		*/
						/* data, not the short form in the index.		*/
{
	Person *pptr ;
	short dummy ;
	char *str_ptr ;
	short done = FALSE ;

	if( use_full_forename )
	{
		pptr = get_pdata_ptr( ref, &dummy ) ;
		if( pptr->forenames )  strcpy( buffer, pptr->forenames ) ;
		else  buffer[0] = '\0' ;
	}
	else  strcpy( buffer, people[ref].forename ) ;

	if( chmax < 0 )  chmax = -chmax ;

	if( chmax &&
			strlen( buffer ) + strlen( people[ref].family_name ) + 1 > chmax )
	{
		str_ptr = buffer + chmax - strlen( people[ref].family_name ) - 1 ;
					/* attempt to limit string at last space		*/
		while( str_ptr-- > buffer  && !done )
		{
			if( *str_ptr == ' ' )
			{
				*str_ptr = '\0' ;
				done = TRUE ;
			}
		}
						/* dumb limit of string in case no space found	*/
		buffer[chmax-strlen( people[ref].family_name )] = '\0' ;
	}

	strcat( buffer, " " ) ;
	strcat( buffer, people[ref].family_name ) ;
}


void  shorten_names( char *buffer, short length )
{
	char *buf_ptr ;
	char *last_space, *space_before ;
	short failed = FALSE ;

	while( strlen( buffer ) > length && !failed )
	{
		buf_ptr = buffer + strlen( buffer ) ;
		while( buf_ptr > buffer && *buf_ptr != ' ' )  buf_ptr-- ;
		last_space = buf_ptr-- ;
		while( buf_ptr > buffer && *buf_ptr != ' ' )  buf_ptr-- ;
		space_before = buf_ptr ;
		if( space_before > buffer )  strcpy( space_before, last_space ) ;
		else
		{
			failed = TRUE ;
			buffer[length] = '\0' ;
		}
	}
}


void  names_ref( int ref, char *names, short chmax, short use_full_forename )
						/* This routine takes a persons fore and family	*/
						/* names and puts them into a formatted string,	*/
						/* followed by their reference number.			*/
						/* The string will be limited to a maximum		*/
						/* length of chmax characters.					*/
{
	char buffer[100] ;

	if( ref )
	{
		form_names( ref, buffer, chmax, use_full_forename ) ;
		if( prefs.include_reference )  sprintf( buffer + strlen(buffer), " %d", ref ) ;
	}
	else  buffer[0] = '\0' ;

	strcpy( names, buffer ) ;
}


void  form_date( char *date_str, char* qualifier, int date, short padflag )
								/* This takes date in modified Gemdos	*/
								/* form. The day and month are in		*/
								/* bits 0 to 8.							*/
								/* Year is relative to 0AD, so date is	*/
								/* int, not short, in bits 9 to 31.		*/
								/* A blank string is the 13th month.	*/
								/* Qtr is the 14th month!				*/
								/* The circa flag is in bit 21. 		*/
								/* If padflag is non zero or TRUE		*/
								/* always make up to 9 characters.		*/
								/* If the date is zero it sets the		*/
								/* string to "", or "         " if		*/
								/* padflag, and qualifier to ' '.		*/ 
{
	short day, mon, year ;

	day = date & 0x1F ;
	mon = ( date & 0x1E0 ) >> 5 ;
	year = ( date & 0x1FFE00 ) >> 9 ;

	switch( date & DATE_QUALIFY_BITS )
	{
		case CIRCA_CODE :
			*qualifier = circa_char ;
			break ;
		case BEFORE_CODE :
			*qualifier = before_char ;
			break ;
		case AFTER_CODE :
			*qualifier = after_char ;
			break ;
		default :
			*qualifier = ' ' ;
			break ;
	}
	if( ( padflag && ( date != 0 ) ) || day )
	{
		if( day == 0 && mon == 0 )  mon = 13 ;
		sprintf( date_str, "%2hd%s%4hd", day, months[mon], year ) ;
		if( day == 0 )  date_str[1] = ' ' ;
	}
	else if( mon )  sprintf( date_str, "%s%4hd", months[mon], year ) ;
	else if( year )  sprintf( date_str, "%4hd", year ) ;
	else  *date_str = '\0' ;
}


BOOLEAN  form_todays_date( char* buffer )
						/* This routine fetches date from the system	*/
						/* and uses either the month strings or the		*/
						/* GEDCOM month strings to form the date in		*/
						/* buffer.										*/
						/* If the date is earlier than 1995 it returns	*/
						/* False to indicate that date not correctly	*/
						/* set.											*/
{
	struct
	{
		short da_year;
		char da_day;
		char da_mon;
	} date ;

	getdate( &date ) ;
	sprintf( buffer, "%hd %s %hd", (short) date.da_day,
							months[date.da_mon], date.da_year ) ;
	
	return (date.da_year >= 1995) ;
}


void  names_date( int ref, char *names, short padto, short use_full_forename )
						/* This routine takes a persons fore and family	*/
						/* names and puts them into a formatted string	*/
						/* with their date of birth. If padto is non	*/
						/* zero the name is padded to padto chars.		*/
						/* If padto is negative, string will be limited	*/
						/* to -padto, but not padded.					*/
						/* Two spaces are left before the date. If a	*/
						/* non zero flag is passed to the form_date		*/
						/* function it will not pad out the date.		*/
{
	short spaces ;
	char *str_ptr ;
	char buffer[100] ;
	char qualifier ;

	if( ref )  form_names( ref, buffer, padto, use_full_forename ) ;
	else  buffer[0] = '\0' ;
	if( padto )  spaces = padto - strlen( buffer ) ;
	else  spaces = 2 ;
	str_ptr = buffer + strlen( buffer ) ;
	while( spaces-- > 0 )  *str_ptr++ = ' ' ;
	if( padto )  buffer[padto] = '\0' ;

	form_date( str_ptr, &qualifier, people[ref].birth_date, padto ) ;
					/* put qualifying character in last (second) space	*/
	*(str_ptr-1) = qualifier ;

	strcpy( names, buffer ) ;
}


void  names_dates( int ref, char *names, short padto, short use_full_forename )
						/* As names_date() but includes death date		*/
{
	Person *pptr ;
	char *str_ptr ;
	char qualifier ;
	int date ;			/* temporary holding variable					*/
	short dummy ;

	names_date( ref, names, padto, use_full_forename ) ;

	pptr = get_pdata_ptr( ref, &dummy ) ;
	if( date = pptr->death_date )
	{
		strcat( names, " - " ) ;
		str_ptr = names + strlen( names ) ;
		form_date( str_ptr, &qualifier, date, padto ) ;
		if( qualifier != ' ' )
		{
			*str_ptr = qualifier ;
			form_date( str_ptr+1, &qualifier, date, padto ) ;
		}
	}
}


short  fsel_geninput( char *pathfile, const char *dflt_file, short *button,
															short field )
		/* This is equivalent to fsel_exinput but takes the file path	*/
		/* and name combined. It also includes wind_update calls to		*/
		/* protect it from Harlekin under TOS 2.06, which hangs the		*/
		/* ST when selecting B: otherwise.								*/
{
	char filename[FNSIZE] ;
	char *str_ptr, pathspec[FMSIZE] ;
	char extension[4] ;
	short res ;

	if( stcgfp( pathspec, pathfile ) && stcgfn( filename, pathfile ) )
	{
		strcat( pathspec, "\\*." ) ;
		if( stcgfe( extension, pathfile ) )  strcat( pathspec, extension ) ;
		else  strcat( pathspec, "*" ) ;
	}
	else
	{
		stcgfp( pathspec, dflt_file ) ;
		stcgfn( filename, dflt_file ) ;
		strcat( pathspec, "\\*." ) ;
		if( stcgfe( extension, dflt_file ) )  strcat( pathspec, extension ) ;
		else  strcat( pathspec, "*" ) ;
	}

	wind_update( BEG_UPDATE ) ;		/* At HiSoft's suggestion I have	*/
									/* included wind_update() pair to	*/
									/* prevent Harlekin II and TOS 2.06	*/
									/* together causing a hang up when	*/
									/* selecting virtual drive B with	*/
									/* the file selector.				*/
	res = fsel_exinput( pathspec, filename, button,
									(char *)strings_ptr[field].ob_spec ) ;
	wind_update( END_UPDATE ) ;

	if( res && *button && strlen( pathspec ) )
	{
		short name_length ;
		strcpy( pathfile, pathspec ) ;
		str_ptr = pathfile + strlen( pathfile ) ;
		while( *(--str_ptr) != '\\' ) ;
		if( name_length = strlen( filename ), name_length )
		{
									/* Freedom file selector sometimes	*/
									/* appends \ to end of filename.	*/
			if( filename[name_length-1] == '\\' )  filename[name_length-1] = '\0' ;
			str_ptr++ ;
			strcpy( str_ptr, filename ) ;
		}
		else  *str_ptr = '\0' ;
	}
	else  *button = 0 ;

	busy( RESTORE ) ;

	menu_bar( menu_ptr, MENU_INSTALL ) ;

	return res ;
}


void  init_form( Wind_edit_params *ed_params, short index, short string_field, const char *help_string )
{
	int i ;
	
	rsrc_gaddr( R_TREE, index, &ed_params->fm_ptr ) ;
	ed_params->fm_handle = -1 ;
	ed_params->fm_box.g_w = 0 ;
	
	ed_params->help_ref = help_string ;

	ed_params->icon_object = FORM_ICON ;	/* this may be overwritten for	*/
											/* person and couple forms		*/

	i=0 ;
	do
	{
		if( ed_params->fm_ptr[i].ob_type >> 8 == 18 )
		{
			ed_params->fm_ptr[i].ob_type = ( 18 << 8 ) + G_PROGDEF ;
			ed_params->fm_ptr[i].ob_spec = pmalloc( sizeof(APPLBLK) ) ;
			((APPLBLK *)(ed_params->fm_ptr[i].ob_spec))->ab_code = draw_check ;
		}
		if( ed_params->fm_ptr[i].ob_type >> 8 == 19 )
		{
			ed_params->fm_ptr[i].ob_type = ( 19 << 8 ) + G_PROGDEF ;
			ed_params->fm_ptr[i].ob_spec = pmalloc( sizeof(APPLBLK) ) ;
			((APPLBLK *)(ed_params->fm_ptr[i].ob_spec))->ab_code = draw_radio ;
		}
		i++ ;
	}
	while( !( ed_params->fm_ptr[i-1].ob_flags & LASTOB ) ) ;
	if( string_field != NO_STRING )
	{
		strcpy( ed_params->title_str, (char *)strings_ptr[string_field].ob_spec ) ;
		strcpy( ed_params->icon_title, (char *)strings_ptr[string_field].ob_spec ) ;
		strupr( ed_params->icon_title ) ;
	}
}


void  wind_form_do( Wind_edit_params *ed_params, short start_obj )
					/* Wind_form_do opens a 'dialogue box' window for	*/
					/* a form. If necessary it creates the window first.*/
					/* If creating it, it is centred on the desktop.	*/
					/* Otherwise it uses its previous position.			*/
					/* The keyboard is handled by form_keys, buttons by	*/
					/* form_button_do.									*/
{
	short dummy ;

	ed_params->edit_object = 0;
	ed_params->next_object = 0;
	ed_params->start_object = start_obj ;
	ed_params->drawn = FALSE ;		/* wait for form to be drawn before	*/
									/* trying to draw cursor			*/
	if( ed_params->fm_handle <= 0 )
	{									/* Find dialog box size and 	*/
										/* centre it relative to the	*/
										/* desk top.					*/
		if( ed_params->fm_box.g_w == 0 )
		{
			ed_params->fm_box.g_w = ed_params->fm_ptr[ROOT].ob_width ;
			ed_params->fm_box.g_h = ed_params->fm_ptr[ROOT].ob_height ;
			wind_calc( WC_BORDER, wind_form_kind, ELTS( ed_params->fm_box ),
												REFS( ed_params->fm_box ) ) ;
			rc_center( &deskbox, &ed_params->fm_box ) ;
			wind_calc( WC_WORK, wind_form_kind, ELTS( ed_params->fm_box ),
						&ed_params->fm_ptr[ROOT].ob_x, &ed_params->fm_ptr[ROOT].ob_y,
						&dummy, &dummy ) ;
		}

		ed_params->fm_handle = wind_create( wind_form_kind, ELTS( ed_params->fm_box ) ) ;
		if( ed_params->fm_handle < 0 )
		{
			ed_params->fm_handle = -1 ;
			rsrc_form_alert( 1, NO_WINDOW ) ;
		}
		else  wind_open( ed_params->fm_handle, ELTS( ed_params->fm_box ) ) ;
		ed_params->iconified = FALSE ;
		ed_params->cursor_position
			= strlen( ( (TEDINFO *) ed_params->fm_ptr[start_obj].ob_spec)->te_ptext ) ;
	}
	else
	{
		wind_set( ed_params->fm_handle, WF_TOP, 0, 0, 0, 0 ) ;
		send_redraw_message( &ed_params->fm_box, ed_params->fm_handle ) ;
	}

	if( ed_params->fm_handle > 0 && !ed_params->iconified )
		wind_title( ed_params->fm_handle, ed_params->title_str ) ;
}


void  form_mu_mesag( const short *message, Wind_edit_params *ed_params )
{
	GRECT *rect ;			/* Grect pointer for wind_redraw			*/
	short dummy ;

	assert( ed_params->fm_handle > 0 ) ;

	switch( message[0] )
	{
		case WM_REDRAW :
			form_redraw( message, ed_params ) ;
			break ;
		case WM_MOVED :
			rect = (GRECT *) &(message[4]) ;
			wind_set( ed_params->fm_handle, WF_CURRXYWH, PTRS( rect ) ) ;
			ed_params->fm_box = *rect ;
			wind_calc( WC_WORK, wind_form_kind, ELTS( ed_params->fm_box ),
					&ed_params->fm_ptr[ROOT].ob_x, &ed_params->fm_ptr[ROOT].ob_y,
					&dummy, &dummy ) ;
			break ;
		case WM_TOPPED :
			wind_set( ed_params->fm_handle, WF_TOP ) ;
			break ;
		case WM_BOTTOM :
			wind_set( ed_params->fm_handle, WF_BOTTOM ) ;
			break ;
		case WM_CLOSED :
			wind_close( ed_params->fm_handle ) ;
			wind_delete( ed_params->fm_handle ) ;
			ed_params->fm_handle = -1 ;
			break ;
		case WM_ALLICONIFY :
			iconify_all( ed_params->fm_box.g_x ) ;
			break ;
		case WM_ICONIFY :
			wind_set( ed_params->fm_handle, WF_UNICONIFYXYWH, ELTS( ed_params->fm_box ) ) ;
			ed_params->fm_box = *(GRECT *)&message[4] ;
			ed_params->iconified = TRUE ;
			wind_set( ed_params->fm_handle, WF_ICONIFY, ELTS( ed_params->fm_box ) ) ;
			wind_title( ed_params->fm_handle, ed_params->icon_title ) ;
			send_redraw_message( &ed_params->fm_box, ed_params->fm_handle ) ;
			break ;
		case WM_UNICONIFY :
			wind_get( ed_params->fm_handle, WF_UNICONIFY, REFS( ed_params->fm_box ) ) ;
			wind_calc( WC_WORK, wind_form_kind, ELTS( ed_params->fm_box ),
					&ed_params->fm_ptr[ROOT].ob_x, &ed_params->fm_ptr[ROOT].ob_y,
					&dummy, &dummy ) ;
			wind_set( ed_params->fm_handle, WF_UNICONIFY, ELTS( ed_params->fm_box ) ) ;
			wind_title( ed_params->fm_handle, ed_params->title_str ) ;
			ed_params->iconified = FALSE ;
			break ;
		default :
			break ;
	}
}


void  form_mu_button( short m_x, short m_y, Wind_edit_params *ed_params )
{
	if( !ed_params->iconified )
	{
		ed_params->next_object = objc_find( ed_params->fm_ptr, ROOT, MAX_DEPTH, m_x, m_y ) ;
		if( ed_params->next_object == NIL )
		{
			Bconout( 2, '\a' ) ;
			objc_edit( ed_params->fm_ptr, ed_params->edit_object, 0,
										&(ed_params->cursor_position), ED_END ) ;
			ed_params->edit_object = 0 ;
		}
		change_edit_object( ed_params, MU_BUTTON ) ;
							/* change to new object if it is editable	*/

							/* now deal with special cases				*/

							/* handle pop up date qualifier menus		*/
		if( top == DEATH_WINDOW && ed_params->next_object == BCD_QUALIFIER )
			popup_date_qualifier( form_addrs.bcd_qual, death_form.fm_ptr, BCD_QUALIFIER ) ;
		else if( top == DEATH_WINDOW && ed_params->next_object == WID_QUALIFIER )
			popup_date_qualifier( form_addrs.wid_qual, death_form.fm_ptr, WID_QUALIFIER ) ;
		else if( top == DIVORCE_WINDOW && ed_params->next_object == DID_QUALIFIER )
			popup_date_qualifier( c_form_addrs.did_qual, divorce_form.fm_ptr, DID_QUALIFIER ) ;
	}
}


void  change_edit_object( Wind_edit_params *form_ed_params, short event )
{
	short cursor_posn ;
	char* edit_string ;
	char hold_char ;

	if( form_ed_params->next_object > 0
			&& ( form_ed_params->fm_ptr[form_ed_params->next_object].ob_flags
															& EDITABLE ) )
	{
		if( form_ed_params->edit_object )
			objc_edit( form_ed_params->fm_ptr, form_ed_params->edit_object, 0,
							&(form_ed_params->cursor_position), ED_END ) ;
		form_ed_params->edit_object = form_ed_params->next_object ;

		cursor_posn = find_cursor_posn( form_ed_params ) ;
		edit_string = ( (TEDINFO *) form_ed_params->fm_ptr[form_ed_params->next_object].ob_spec)->te_ptext ;
		hold_char = edit_string[cursor_posn] ;
				/* if changing in response to mouse click position cursor	*/
				/* using mouse position, otherwise let it go to end of text	*/

		if( event == MU_BUTTON )  edit_string[cursor_posn] = '\0' ;

		objc_edit( form_ed_params->fm_ptr, form_ed_params->edit_object, 0,
							&(form_ed_params->cursor_position), ED_INIT ) ;

		edit_string[cursor_posn] = hold_char ;
	}
}


short  find_cursor_posn( Wind_edit_params *form_ed_params )
{
	short mouse_x ;
	short dummy ;
	GRECT rect ;
	char* template ;
	char* tmpl_ptr ;
	char* edit_string ;
	short start_of_template ;
	short template_char ;
	short cursor_posn = 0 ;
	short i ;

	template = ( (TEDINFO *) form_ed_params->fm_ptr[form_ed_params->next_object].ob_spec)->te_ptmplt ;
	edit_string = ( (TEDINFO *) form_ed_params->fm_ptr[form_ed_params->next_object].ob_spec)->te_ptext ;
	graf_mkstate( &mouse_x, &dummy, &dummy, &dummy ) ;
	objc_xywh( form_ed_params->fm_ptr, form_ed_params->next_object, &rect ) ;

	switch( ( (TEDINFO *) form_ed_params->fm_ptr[form_ed_params->next_object].ob_spec)->te_just )
	{
		case TE_LEFT :
			start_of_template = rect.g_x ;
			break ;
		case TE_RIGHT :
			start_of_template = rect_end( &rect ) - wchar * strlen( template ) ;
			break ;
		case TE_CNTR :
			start_of_template = rect.g_x + rect.g_w / 2 - wchar * strlen( template ) / 2 ;
			break ;
		default :
			start_of_template = rect.g_x ;
			break ;
	}
	
	template_char = ( mouse_x - start_of_template + wchar / 2 ) / wchar ;
	tmpl_ptr = template ;
	for( i = 0; i < template_char; i++ )
	{
		if( template[i] == '_' )  cursor_posn++ ;
	}
	cursor_posn = min( cursor_posn, strlen( edit_string ) ) ;
	
	return( cursor_posn ) ;
}
	

void  form_redraw( const short *message, Wind_edit_params *form_ed_params )
{
	GRECT *rect ;

	if( form_ed_params->edit_object && !form_ed_params->iconified )
	{
		objc_edit( form_ed_params->fm_ptr, form_ed_params->edit_object, 0,
							&(form_ed_params->cursor_position), ED_END ) ;
									/* Set start_object to edit_object	*/
									/* and edit object to zero to get	*/
									/* cursor redrawn by main loop.		*/
	}

	rect = (GRECT *) &(message[4]) ;
	wind_redraw( (int) message[3], rect, f_redraw ) ;

	if( !form_ed_params->drawn )  form_ed_params->edit_object
											= form_ed_params->start_object ;

	if( form_ed_params->edit_object && !form_ed_params->iconified )
	{
		short hold_char ;
		char* edit_string ;
		
		edit_string = ( (TEDINFO*) form_ed_params->fm_ptr[form_ed_params->edit_object].ob_spec)->te_ptext ;
hold_char = '\0' ;
/*
		if( form_ed_params->cursor_position < strlen( edit_string ) )
			hold_char = edit_string[form_ed_params->cursor_position] ;
		else  hold_char = '\0' ;
*/
		if( hold_char != '\0' )
			edit_string[form_ed_params->cursor_position] = '\0' ;
		objc_edit( form_ed_params->fm_ptr, form_ed_params->edit_object, 0,
							&(form_ed_params->cursor_position), ED_INIT ) ;
		if( hold_char != '\0' )
			edit_string[form_ed_params->cursor_position] = hold_char ;
	}
	form_ed_params->drawn = TRUE ;
}


int f_redraw( int handle, const GRECT *rect )
{
	Wind_edit_params *form = NULL ;

	if( handle == pers_form.fm_handle )  form = &pers_form ;
	else if( handle == coup_form.fm_handle )  form = &coup_form ;
	else if( handle == death_form.fm_handle )  form = &death_form ;
	else if( handle == baptism_form.fm_handle )  form = &baptism_form ;
	else if( handle == birth_form.fm_handle )  form = &birth_form ;
	else if( handle == co_src_form.fm_handle )  form = &co_src_form ;
	else if( handle == divorce_form.fm_handle )  form = &divorce_form ;
	else if( handle == dialogue_form.fm_handle )  form = &dialogue_form ;
	if( form && form->iconified )
	{
		icons_ptr[0].ob_x = form->fm_box.g_x ;
		icons_ptr[0].ob_y = form->fm_box.g_y ;
		icons_ptr[ICON].ob_spec = icons_ptr[form->icon_object].ob_spec ;
		((TEDINFO *)icons_ptr[ICON_LABEL1].ob_spec)->te_ptext = form->icon_label1 ;
		((TEDINFO *)icons_ptr[ICON_LABEL2].ob_spec)->te_ptext = form->icon_label2 ;
		objc_draw( icons_ptr, ROOT, MAX_DEPTH, PTRS( rect ) ) ;
	}
	else if( form )
		objc_draw( form->fm_ptr, ROOT, MAX_DEPTH, PTRS( rect ) ) ;

	return 1 ;
}


void  close_form_window( Wind_edit_params *p )
{
	short dummy ;
	int i ;

	if( p->iconified )
	{
		wind_get( p->fm_handle, WF_UNICONIFY, REFS( p->fm_box ) ) ;
		if( p->fm_ptr )
			wind_calc( WC_WORK, wind_form_kind, ELTS( p->fm_box ),
					&p->fm_ptr[ROOT].ob_x, &p->fm_ptr[ROOT].ob_y,
					&dummy, &dummy ) ;
		p->iconified = FALSE ;
	}

	if( p->fm_ptr != NULL )	/* excludes notes window which has no resource	*/
	{
		for( i=0; !( p->fm_ptr[i].ob_flags & LASTOB ); i++ )
		{
			if( p->fm_ptr[i].ob_type == G_PROGDEF + (18 << 8)
			|| p->fm_ptr[i].ob_type == G_PROGDEF + (19 << 8) )
			{
				free( p->fm_ptr[i].ob_spec ) ;
			}
		}
	}

	assert( p->fm_handle > 0 ) ;

	wind_close( p->fm_handle ) ;
	wind_delete( p->fm_handle ) ;
	p->fm_handle = -1 ;
}


int  move_slide( OBJECT *tree, int slider, int slide_range, const GRECT *box )
							/* This routine moves the slider and does	*/
							/* the redraw. It returns a number in the	*/
							/* standard GEM range of 0 to 1000.			*/
{
	int res ;
	int range ;

	res = graf_slidebox( tree, slide_range, slider, 1 ) ;

	range = tree[slide_range].ob_height - tree[slider].ob_height ;
	tree[slider].ob_y = res * range / 1000 ;

	objc_draw( tree, slide_range, MAX_DEPTH, PTRS( box ) ) ;

	return res ;
}


void  set_slide( int value, int range, OBJECT *tree,
								int slider, int slide_range, GRECT *box )
							/* This routine moves the slider a distance	*/
							/* equal to jump/range times the maximum	*/
							/* slider movement.							*/
{
	short max_slide ;

	max_slide = tree[slide_range].ob_height - tree[slider].ob_height ;

	if( range > 0 )  tree[slider].ob_y = value * max_slide / range ;
	else  tree[slider].ob_y = 0 ;

	if( box->g_w )  objc_draw( tree, slide_range, MAX_DEPTH, PTRS( box ) ) ;
}


					/* Get_next_slice loads buffer with a string that	*/
					/* fits within slice_length character widths. If	*/
					/* the alignment mode is Left_wrap it will cut the 	*/
					/* string back to the previous space where there is	*/
					/* one. It will set the string pointer str_ptr to	*/
					/* point to the Null at the end of the string so a	*/
					/* subsequent call will get a NULL return value,	*/
					/* unless the alignment mode is Left_wrap when the	*/
					/* pointer will be left pointing at the remainder	*/
					/* of the string. This is to allow a string to be	*/
					/* processed as a number of slices.					*/
					/* If the string is empty or the slice length is	*/
					/* not positive the function returns NULL.			*/
					/* If the string contains carriage returns it will	*/
					/* be broken at these even if more words would fit.	*/
char *get_next_slice( char *buffer, char **str_ptr, Str_prt_params *ps_ptr,
									short slice_length )
{
	char *slice_ptr ;
	short save_max_len ;
	char ch ;
	char *cr_ptr ;

	if( !**str_ptr || slice_length <= 0 )  return NULL ;

	save_max_len = ps_ptr->max_len ;
	ps_ptr->max_len = slice_length ;

								/* ensure slice ends by cr if any		*/
	cr_ptr = strchr( *str_ptr, '\r' ) ;
	if( cr_ptr )  *cr_ptr = '\0' ;
	if( !line_fits( *str_ptr, ps_ptr ) )
	{
						/* Find last space within slice_length, if any.	*/
		slice_ptr = *str_ptr + slice_length ;
		if( ps_ptr->use_gdos )	/* Find string that just fits.			*/
								/* Proportional fonts mean that this	*/
								/* cannot be done by counting chars as	*/
								/* works for standard printer or file.	*/
		{
			ch = *slice_ptr ;
			*slice_ptr = '\0' ;
			while( line_fits( *str_ptr, ps_ptr ) )
			{
				*slice_ptr = ch ;
				ch = *++slice_ptr ;
				*slice_ptr = '\0' ;
			}
			while( !line_fits( *str_ptr, ps_ptr ) )
			{
				*slice_ptr = ch ;
				ch = *--slice_ptr ;
				*slice_ptr = '\0' ;
			}
			*slice_ptr = ch ;
		}
		if( ps_ptr->align == LEFT_WRAP )
			while( slice_ptr > *str_ptr && *slice_ptr != ' ' )  slice_ptr-- ;

		if( slice_ptr <= *str_ptr )
		{
			strncpy( buffer, *str_ptr, slice_length ) ;
			buffer[slice_length] = '\0' ;
			*str_ptr += slice_length ;
		}
		else
		{
			strncpy( buffer, *str_ptr, slice_ptr - *str_ptr ) ;
			buffer[slice_ptr - *str_ptr] = '\0' ;
			*str_ptr = ++slice_ptr ;
		}
				/* If not wrapping, i.e. truncating, then ensure that	*/
				/* next get_next_slice returns NULL.					*/
		if( ps_ptr->align != LEFT_WRAP )  *str_ptr += strlen( *str_ptr ) ;
	}
	else
	{
		strcpy( buffer, *str_ptr ) ;
		*str_ptr += strlen( *str_ptr ) ;
		if( cr_ptr )  *str_ptr = cr_ptr + 1 ; 
	}

								/* If a carriage return has been		*/
								/* replaced restore it.					*/
	if( cr_ptr )  *cr_ptr = '\r' ;

	ps_ptr->max_len = save_max_len ;

	return buffer ;
}


char get_previous_char( char **str_ptr, char *tail_ptr, char *insert_ptr )
{
	char ch ;
	
	if( *str_ptr < edit_buffer )  return '\0' ;
	
	ch = **str_ptr ;
	
	if( *str_ptr == tail_ptr )  *str_ptr = insert_ptr ;
	(*str_ptr)-- ;
	
	return ch ;
}


char get_next_char( char **str_ptr, char *tail_ptr )
{
	char ch ;
	
	ch = *(*str_ptr)++ ;
	
	if( ch == '\0' && *str_ptr < tail_ptr )
	{
		*str_ptr = tail_ptr ;
		ch = *(*str_ptr)++ ;
	}

	return ch ;
}


char  get_next_char_with_properties( char **str_ptr, char *tail_ptr, char *property )
{
	char ch ;
	short done = FALSE ;
	
	ch = get_next_char( str_ptr, tail_ptr ) ;
	
	while( ch == '<' && !done )
	{
		ch = get_next_char( str_ptr, tail_ptr ) ;
	
		if( ch == '<' )
			done = TRUE ;
		else
		{
			if( ch == '\\' )
			{
				ch = get_next_char( str_ptr, tail_ptr ) ;
				switch( ch )
				{
					case 'a' :
						*property &= ~HREF ;
						break ;
					default :
						break ;
				}
			}
			else
			{
				switch( ch )
				{
					case 'a' :
						*property |= HREF ;
						break ;
					default :
						break ;
				}
			}
			while( ch && ch != '>' )  ch = get_next_char( str_ptr, tail_ptr ) ;
			if( ch )  ch = get_next_char( str_ptr, tail_ptr ) ;
		}
	}
	return ch ;
}


					/* Get_next_slice_with_properties loads buffer with	*/
					/* a string that fits within slice_length character	*/
					/* widths.											*/
					/* If the alignment mode is Left_wrap it will cut	*/
					/* the string back to the previous space where		*/
					/* there is	one.									*/
					/* It will set the string pointer str_ptr to point	*/
					/* to the Null at the end of the string so a		*/
					/* subsequent call will get a NULL return value,	*/
					/* unless the alignment mode is Left_wrap when the	*/
					/* pointer will be left pointing at the remainder	*/
					/* of the string. This is to allow a string to be	*/
					/* processed as a number of slices.					*/
					/* If the string is empty or the slice length is	*/
					/* not positive the function returns NULL.			*/
					/* If the string contains carriage returns it will	*/
					/* be broken at these even if more words would fit.	*/
					/* If the tail pointer is greater than the str_ptr,	*/
					/* then a string terminator, '\0', will cause this	*/
					/* routine to jump to the tail and fetch chars from	*/
					/* there.											*/
char *get_next_slice_with_properties( char *buffer, char **str_ptr, char *tail_ptr,
						Str_prt_params *ps_ptr, short *curs_x,
						char *property, char *properties, short slice_length )
{
	short save_max_len ;
	int done = FALSE ;
	char ch ;
	char *buf_ptr ;
	char *last_char ;
	char *last_space = NULL ;
	char *last_buf_space ;
	char *prop_ptr ;

	if( ( !**str_ptr && *str_ptr > tail_ptr ) || slice_length <= 0 )  return NULL ;

	save_max_len = ps_ptr->max_len ;
	ps_ptr->max_len = slice_length ;

	buf_ptr = buffer ;
	*buf_ptr = '\0' ;
	*curs_x = 0 ;
	prop_ptr = properties ;
	
	while( !done )	/* keep getting chars until cr, end of string or does not fit	*/
	{
		ch = get_next_char_with_properties( str_ptr, tail_ptr, property ) ;
		
		if( ch != '\r' )
		{
			*buf_ptr++ = ch ;
			if( prop_ptr )  *prop_ptr++ = *property ;
		}
		*buf_ptr = '\0' ;
		if( *str_ptr < tail_ptr )  *curs_x = strlen( buffer ) ;

		last_char = *str_ptr - 1 ;
		if( ch == '\r' )
		{
			done = TRUE ;
		}
		else if( ch == ' ' )
		{
			last_space = last_char ;
			last_buf_space = buf_ptr - 1 ;
		}
		else if( ch == '\0' )
		{
			done = TRUE ;
			*str_ptr = NULL ;
		}
		else
		{
			if( !line_fits( buffer, ps_ptr ) )
			{
				if( last_space && ps_ptr->align == LEFT_WRAP )
				{
					*last_buf_space = '\0' ;
					*str_ptr = last_space + 1 ;
				}
				else
				{
					*--buf_ptr = '\0' ;
					if( ps_ptr->align == LEFT_WRAP )  *str_ptr = last_char ;
				}
				done = TRUE ;
			}
		}
	}
	
	ps_ptr->max_len = save_max_len ;

	return buffer ;
}


void v_gtext_with_properties( int handle, int x, int y, const char *str, const char *properties )
{
	char buffer[256] ;
	char *buf_ptr = buffer ;
	const char *str_ptr = str ;
	const char *prop_ptr = properties ;
	char property ;
	short w_cell ;
	short dummy ;
	
	v_attrs( scr_handle, SAVE ) ;

	vst_point( handle, prefs.notes_text_size, &dummy, &dummy,
													&w_cell, &dummy ) ;
	while( *str_ptr )
	{
		*buf_ptr++ = *str_ptr++ ;
		property = *prop_ptr++ ;
		if( property != *prop_ptr || *str_ptr == '\0' )
		{
			*buf_ptr = '\0' ;
			
			if( property & HREF )
			{
				int all_spaces = TRUE ;
				int i = 0 ;
				
				vst_color( scr_handle, BLUE ) ;
				vst_effects( scr_handle, THICKENED ) ;

				for( i = 0 ; i < strlen( buffer ) ; i++ )  if( buffer[i] != ' ' )  all_spaces = FALSE ;
				if( all_spaces )  for( i = 0 ; i < strlen( buffer ) ; i++ )  buffer[i] = '_' ;
			}
			else
			{
				vst_color( scr_handle, BLACK ) ;
				vst_effects( scr_handle, 0 ) ;
			}
			
			v_gtext( handle, x, y, buffer ) ;
			x += strlen( buffer ) * w_cell ;
			buf_ptr = buffer ;
		}
	}
	vst_effects( scr_handle, 0 ) ;
	v_attrs( scr_handle, RESTORE ) ;
}



short  line_fits( char *line, Str_prt_params *ps_ptr )	
	
{	short pts[8] ;				/* for return values of vqt_extent		*/
	short fits = TRUE ;
	short half_length, length ;
	char ch ;
	
	short dummy ;
	int handle ;

	if( ps_ptr->use_gdos )
	{	
		/* For metafiles the calculations are done for the screen as	*/
		/* I do not know how to get proper sizes from metafiles.		*/
		if( METAFILE == device_type )
		{
			handle = scr_handle ;
			vst_font( scr_handle, fontinfo.font_index ) ;
			if( vq_vgdos() == GDOS_FSM )
				vst_arbpt( scr_handle, fontinfo.font_size, &dummy,
									&dummy, &dummy, &dummy ) ;
			else
				vst_point( scr_handle, fontinfo.font_size, &dummy,
									&dummy, &dummy, &dummy ) ;
		}
		else  handle = ps_ptr->prn_handle ;

		half_length = strlen( line ) / 2 ;	
					/* length is calculated in two halves as vqt_extent	*/
					/* seems to bomb out when the string is wider than	*/
					/* the workstation.									*/
		ch = line[half_length] ;
		line[half_length] = '\0' ;
		vqt_extent( handle, line, pts ) ;	
		line[half_length] = ch ;
		length = pts[2] - pts[0] + 1 ;
		vqt_extent( handle, line + half_length, pts ) ;	
		length += pts[2] - pts[0] + 1 ;
		if( METAFILE == device_type )
		{
			length = (short) ( (long) length * scr_pixel_width
													/ prn_pixel_width ) ;
			vst_font( scr_handle, SYSTEM_FONT ) ;	/* restore system font	*/
		}

		if( length > ps_ptr->max_len * ps_ptr->cell_width )  fits = FALSE ;
	}
	else
	{
		if( strlen( line ) > ps_ptr->max_len )  fits = FALSE ;
	}

	return fits ;
}


void iconify_all( int x )
{
	GRECT icon_position ;
	int i ;

	if( group_icon_handle == -1 )
	{
		icon_position.g_x = x ;
		icon_position.g_y = deskbox.g_y + deskbox.g_h - 72 ;
		icon_position.g_w = 72 ;
		icon_position.g_h = 72 ;
		group_icon_handle = wind_create( group_icon_kind, ELTS( icon_position ) ) ;
		wind_title( group_icon_handle, (char *)strings_ptr[GROUP_ITITLE].ob_spec ) ;
		wind_set( group_icon_handle, WF_ICONIFY, ELTS( icon_position ) ) ;
		wind_open( group_icon_handle, ELTS( icon_position ) ) ;
	}

	for( i=1; i<NUM_WINDOWS+1; i++ )
	{
		if( wind_edit_params_ptrs[i]->fm_handle > 0 && wind_edit_params_ptrs[i]->iconified < PROG_ICON )
		{
			wind_close( wind_edit_params_ptrs[i]->fm_handle ) ;
			wind_edit_params_ptrs[i]->iconified += PROG_ICON ;
		}
	}
}


void uniconify_all( void )
{
	int i ;

	for( i=1; i<NUM_WINDOWS+1; i++ )
	{
		if( wind_edit_params_ptrs[i]->fm_handle > 0 && wind_edit_params_ptrs[i]->iconified >= PROG_ICON )
		{
			wind_open( wind_edit_params_ptrs[i]->fm_handle, ELTS( wind_edit_params_ptrs[i]->fm_box ) ) ;
			wind_edit_params_ptrs[i]->iconified -= PROG_ICON ;
		}
	}

	assert( group_icon_handle > 0 ) ;

	wind_close( group_icon_handle ) ;
	wind_delete( group_icon_handle ) ;
	group_icon_handle = -1 ;
}


void  group_icon_mesag( const short *message )
{
	GRECT *rect ;			/* Grect pointer for wind_redraw			*/

	switch( message[0] )
	{
		case WM_REDRAW :
			wind_redraw( group_icon_handle, (GRECT *)&(message[4]), group_icon_redraw ) ;
			break ;
		case WM_MOVED :
			rect = (GRECT *) &(message[4]) ;
			wind_set( group_icon_handle, WF_CURRXYWH, PTRS( rect ) ) ;
			break ;
		case WM_TOPPED :
			wind_set( group_icon_handle, WF_TOP ) ;
			break ;
		case WM_BOTTOM :
			wind_set( group_icon_handle, WF_BOTTOM ) ;
			break ;
		case WM_UNICONIFY :
			uniconify_all() ;
			break ;
		default :
			break ;
	}
}


int group_icon_redraw( int wh, const GRECT *area )
{
	GRECT box ;

	wind_get( wh, WF_CURRXYWH, REFS( box ) ) ;
	icons_ptr[0].ob_x = box.g_x ;
	icons_ptr[0].ob_y = box.g_y ;
	icons_ptr[ICON].ob_spec = icons_ptr[GROUP_ICON].ob_spec ;
	((TEDINFO *)icons_ptr[ICON_LABEL1].ob_spec)->te_ptext = "" ;
	((TEDINFO *)icons_ptr[ICON_LABEL2].ob_spec)->te_ptext = "" ;
	objc_draw( icons_ptr, ROOT, MAX_DEPTH, PTRS( area ) ) ;

	return 1 ;
}


BOOLEAN  app_modal_init( OBJECT *tree, const char *help_ref, BOOLEAN titled )
{
	short dummy ;
	int i ;
	int kind ;

	if( titled )  kind = app_modal_kind ;
	else  kind = untitled_app_modal_kind ;
	
	dialogue_form.titled = titled ;
	
	dialogue_form.help_ref = help_ref ;

	dialogue_form.fm_ptr = tree ;
	dialogue_form.fm_box.g_w = dialogue_form.fm_ptr[ROOT].ob_width ;
	dialogue_form.fm_box.g_h = dialogue_form.fm_ptr[ROOT].ob_height ;
	wind_calc( WC_BORDER, kind, ELTS( dialogue_form.fm_box ),
										REFS( dialogue_form.fm_box ) ) ;
										
	if( ( dialogue_form.fm_ptr[ROOT].ob_state & DISABLED ) == 0 )
	{
		rc_center( &deskbox, &dialogue_form.fm_box ) ;
		wind_calc( WC_WORK, kind, ELTS( dialogue_form.fm_box ),
				&dialogue_form.fm_ptr[ROOT].ob_x, &dialogue_form.fm_ptr[ROOT].ob_y,
				&dummy, &dummy ) ;
		dialogue_form.fm_ptr[ROOT].ob_state |= DISABLED ;
	}
	else  wind_calc( WC_BORDER, kind, dialogue_form.fm_ptr[ROOT].ob_x, dialogue_form.fm_ptr[ROOT].ob_y, 
				dialogue_form.fm_ptr[ROOT].ob_width, dialogue_form.fm_ptr[ROOT].ob_height, REFS( dialogue_form.fm_box ) ) ;

	i=0;
	do
	{
		if( dialogue_form.fm_ptr[i].ob_type >> 8 == 18 )
		{
			dialogue_form.fm_ptr[i].ob_type = G_PROGDEF + ( 18 << 8 ) ;
			dialogue_form.fm_ptr[i].ob_spec = pmalloc( sizeof(APPLBLK) ) ;
			((APPLBLK *)(dialogue_form.fm_ptr[i].ob_spec))->ab_code = draw_check ;
		}
		if( dialogue_form.fm_ptr[i].ob_type >> 8 == 19 )
		{
			dialogue_form.fm_ptr[i].ob_type = G_PROGDEF + ( 19 << 8 ) ;
			dialogue_form.fm_ptr[i].ob_spec = pmalloc( sizeof(APPLBLK) ) ;
			((APPLBLK *)(dialogue_form.fm_ptr[i].ob_spec))->ab_code = draw_radio ;
		}
		i++ ;
	}
	while( !( dialogue_form.fm_ptr[i-1].ob_flags & LASTOB ) ) ;

	dialogue_form.fm_handle = wind_create( kind, ELTS( dialogue_form.fm_box ) ) ;
	if( dialogue_form.fm_handle < 0 )
	{
		dialogue_form.fm_handle = -1 ;
		rsrc_form_alert( 1, NO_WINDOW ) ;
		return FALSE ;
	}
	wind_open( dialogue_form.fm_handle, ELTS( dialogue_form.fm_box ) ) ;
	if( titled )  wind_title( dialogue_form.fm_handle, (char *)strings_ptr[DIALOGUE_TITLE].ob_spec ) ;
	dialogue_form.iconified = FALSE ;
	dialogue_form.edit_object = 0 ;

	menu_bar( menu_ptr, MENU_REMOVE ) ;
	menu_ienable( menu_ptr, ABOUT, 0 ) ;
	menu_ienable( menu_ptr, FILE_T, 0 ) ;
	menu_ienable( menu_ptr, EDIT_T, 0 ) ;
	menu_ienable( menu_ptr, DISPLAY_T, 0 ) ;
	menu_ienable( menu_ptr, CUSTOM_T, 0 ) ;
	menu_ienable( menu_ptr, PRINT_T, 0 ) ;
	menu_ienable( menu_ptr, PREFS_T, 0 ) ;
	menu_ienable( menu_ptr, HELP_T, 0 ) ;
	menu_bar( menu_ptr, MENU_INSTALL ) ;

	return TRUE ;
}


int  app_modal_do( void )
{
	int event ;
	short msg[8] ;
	BOOLEAN quit = FALSE ;
	short x, y, kstate, kreturn, breturn ;
	short asc_char ;
	short button ;
	short right_click ;

	while( !quit )
	{
		event = evnt_multi( MODAL_EVENTS,
							0x102, 3, 0,
							/* 2 clicks, either button, pressed			*/
							0,0,0,0,0,
							0,0,0,0,0,
							msg, 0,0,  &x,&y,&button,
							&kstate,&kreturn,  &breturn ) ;
		top = top_window() ;

		if( event & MU_KEYBD )
		{
			asc_char = alt2ascii( kreturn ) ;

			if( kstate & K_CTRL && ( asc_char == 'c' || asc_char == 'v' || asc_char == 'x' ) )
				ctrl_keys( kstate, kreturn, &quit ) ;
			else  if( kreturn == 0x6200 )
			{
				if( kstate & ( K_LSHIFT | K_RSHIFT ) )
					help( index_help ) ;
				else
					help( dialogue_form.help_ref ) ;
			}
			else
			{
				quit = !form_keybd( dialogue_form.fm_ptr, (int) dialogue_form.edit_object, 0,
							(int) kreturn, &(dialogue_form.next_object), &kreturn ) ;
				if( kreturn )
					objc_edit( dialogue_form.fm_ptr, (int) dialogue_form.edit_object,
								kreturn, &(dialogue_form.cursor_position), ED_CHAR ) ;
				change_edit_object( &dialogue_form, MU_KEYBD ) ;
			}
		}
		if( event & MU_BUTTON )
		{
			right_click = ( button & 0x2 ) ;
			
			dialogue_form.next_object = objc_find( dialogue_form.fm_ptr, ROOT, MAX_DEPTH, x, y ) ;
			if( dialogue_form.fm_ptr[dialogue_form.next_object].ob_flags & EDITABLE )
			{
				if( dialogue_form.next_object == NIL )
				{
					Bconout( 2, '\a' ) ;
					objc_edit( dialogue_form.fm_ptr, dialogue_form.edit_object, 0,
												&(dialogue_form.cursor_position), ED_END ) ;
					dialogue_form.edit_object = 0 ;
				}
				change_edit_object( &dialogue_form, MU_BUTTON ) ;
			}
			else
				quit = !form_button( dialogue_form.fm_ptr, dialogue_form.next_object,
												breturn, &dialogue_form.next_object ) ;
		}

		if( event & MU_MESAG && msg[0] == WM_TOPPED )
			msg[3] = dialogue_form.fm_handle ;	/* Force tops to top dialogue */
		if( event & MU_MESAG && msg[0] == AP_TERM )
		{
			/* force exit of app_modal_do and resend terminate message	*/
			quit = TRUE ;
			appl_write( ap_id, sizeof( msg ), msg ) ;
			dialogue_form.next_object = APP_MODAL_TERM ;
		}
		if( event & MU_MESAG )
		{
			if( msg[3] == dialogue_form.fm_handle )
				form_mu_mesag( msg, &dialogue_form ) ;
			else  pass_message( msg ) ;
		}
	}
	if( right_click )  dialogue_form.next_object |= DOUBLE_CLICK ; ;

	return dialogue_form.next_object ;
}


void  app_modal_first_draw( void )
{
	int event ;
	short msg[8] ;
	BOOLEAN quit = FALSE ;
	short dummy ;

	while( !quit )
	{
		event = evnt_multi( MODAL_EVENTS,
							2,0x01,0x01,
							0,0,0,0,0,
							0,0,0,0,0,
							msg, 0,0,  &dummy,&dummy,&dummy,
							&dummy,&dummy,  &dummy ) ;

		if( event & MU_MESAG )
		{
			if( msg[3] == dialogue_form.fm_handle )
			{
				form_mu_mesag( msg, &dialogue_form ) ;
				if( msg[0] == WM_REDRAW )  quit = TRUE ;
			}
			else  pass_message( msg ) ;
		}
	}
}


int  app_modal_button_check( int object )
{
	GRECT rect ;
	BOOLEAN inside = FALSE ;
	short x, y, button, kstate ;

	evnt_timer( 0, 0 ) ;

	objc_xywh( dialogue_form.fm_ptr, object, &rect ) ;
	
	graf_mkstate( &x, &y, &button, &kstate ) ;

	inside = rc_inside( x, y, &rect ) ;
	if( inside )  graf_mouse( ARROW, NULL ) ;
	else  graf_mouse( BUSY_BEE, NULL ) ;
	
	if( inside && (button & 1) )  return object ;
	else  return 0 ;
}


void app_modal_end( void )
{
	int i ;
	
	for( i=0; !( dialogue_form.fm_ptr[i].ob_flags & LASTOB ); i++ )
	{
		if( dialogue_form.fm_ptr[i].ob_type == G_PROGDEF + 18 << 8 
			|| dialogue_form.fm_ptr[i].ob_type == G_PROGDEF + 19 << 8 )
		{
			free( dialogue_form.fm_ptr[i].ob_spec ) ;
		}
	}

	assert( dialogue_form.fm_handle > 0 ) ;
	
	wind_close( dialogue_form.fm_handle ) ;
	wind_delete( dialogue_form.fm_handle ) ;
	dialogue_form.fm_handle = -1 ;

	menu_bar( menu_ptr, MENU_REMOVE ) ;
	menu_ienable( menu_ptr, ABOUT, 1 ) ;
	menu_ienable( menu_ptr, FILE_T, 1 ) ;
	menu_ienable( menu_ptr, EDIT_T, 1 ) ;
	menu_ienable( menu_ptr, DISPLAY_T, 1 ) ;
	menu_ienable( menu_ptr, CUSTOM_T, 1 ) ;
	menu_ienable( menu_ptr, PRINT_T, 1 ) ;
	menu_ienable( menu_ptr, PREFS_T, 1 ) ;
	menu_ienable( menu_ptr, HELP_T, 1 ) ;
	menu_bar( menu_ptr, MENU_INSTALL ) ;
}


GRECT *app_modal_box( void )
{
	return &dialogue_form.fm_box ;
}


short  app_modal_edit_obj( short new_edit_obj )
				/* Sets edit object according to field new_edit_obj.		*/
				/* If new_edit_obj is 0, deselect edit without selecting	*/
				/* another.													*/
				/* If new_edit_obj is -1, do nothing.						*/
				/* Returns old edit object.									*/
{
	short old_edit_object ;

	old_edit_object = dialogue_form.edit_object ;

	if( new_edit_obj != -1 )
	{
		if( new_edit_obj )
		{
			dialogue_form.next_object = new_edit_obj ;
			change_edit_object( &dialogue_form, 0 ) ;
		}
		else
		{
			objc_edit( dialogue_form.fm_ptr, dialogue_form.edit_object, 0,
								&(dialogue_form.cursor_position), ED_END ) ;
			dialogue_form.edit_object = 0 ;
		}
	}
	return old_edit_object ;
}


/*
 * popup_menu() function. Handles pop-up menus. Designed to be
 *		a drop in replacement for the AES menu_popup() call, but
 *		works on all AES versions.
 */

void popup_menu( MENU *in, int x, int y, MENU *out )
{
	int yd ;
	int last = -1, this ;
	int event ;
	short xm, ym ;
	short xo, yo ;
	short dummy, msg[8] ;
	short start_button ;
	short wait_state ;

							/* Calculate position of top of popup menu.	*/
							/* Limit its position below top of deskbox.	*/
	yd = y - in->mn_tree[in->mn_item].ob_y ;
	yd = max( yd, deskbox.g_y ) ;
	
	in->mn_tree[in->mn_menu].ob_x = x - in->mn_tree[ROOT].ob_x ;
	in->mn_tree[in->mn_menu].ob_y = yd - in->mn_tree[ROOT].ob_y ;

	wind_update( BEG_UPDATE ) ;
	wind_update( BEG_MCTRL ) ;
	form_dial( FMD_START, 0,0,0,0, x - 1, yd - 1, in->mn_tree[in->mn_menu].ob_width + 4,
										in->mn_tree[in->mn_menu].ob_height + 4 ) ;
	objc_draw( in->mn_tree, in->mn_menu, MAX_DEPTH, ELTS( deskbox ) ) ;
	graf_mkstate( &dummy, &dummy, &start_button, &dummy ) ;
	if( start_button & 1 )  wait_state = 0 ;
	else  wait_state = 1 ;

	do
	{
		event = evnt_multi( MU_TIMER | MU_BUTTON, 1, 1, wait_state, 0,0,0,0,0,
					0,0,0,0,0, msg, 50,0 /* 50ms */, &xm, &ym,
					&dummy,	&dummy, &dummy, &dummy ) ;

		this = objc_find( in->mn_tree, in->mn_menu, MAX_DEPTH, xm, ym ) ;
		if( last != this  )
		{
			if( last != -1 )
			{
				in->mn_tree[last].ob_state &= ~SELECTED ;
				objc_offset( in->mn_tree, last, &xo, &yo ) ;
				objc_draw( in->mn_tree, last, MAX_DEPTH, ELTS( deskbox ) ) ;
			}
			if( this != -1 )
			{
				in->mn_tree[this].ob_state |= SELECTED ;
				objc_offset( in->mn_tree, this, &xo, &yo ) ;
				objc_draw( in->mn_tree, this, MAX_DEPTH, ELTS( deskbox ) ) ;
			}
			last = this ;
		}
	}
	while( !( event & MU_BUTTON ) ) ;	/* Do while not mouse button pressed or released */
	
	if( last != -1 )
		in->mn_tree[last].ob_state &= ~SELECTED ;
	
	form_dial( FMD_FINISH, 0,0,0,0, x - 1, yd - 1, in->mn_tree[in->mn_menu].ob_width + 4,
										in->mn_tree[in->mn_menu].ob_height + 4 ) ;
	wind_update( END_MCTRL ) ;
	wind_update( END_UPDATE ) ;

	out->mn_item = last ;
	out->mn_tree = in->mn_tree ;
	out->mn_menu = in->mn_menu ;
}


void  set_wind_title( int pers_ref, int spouse_ref, Wind_edit_params *p,
						short rsrc_title, short rsrc_ititle )
{
	form_wind_title( pers_ref, spouse_ref, p, rsrc_title, rsrc_ititle ) ;
	if( p->iconified )
		send_redraw_message( &p->fm_box, p->fm_handle ) ;
	else
		wind_title( p->fm_handle, p->title_str ) ;

}


void  v_attrs( int handle, short flag )
{
	static short scr_t_attr[10] ;
	static short scr_f_attr[5] ;
	static short scr_l_attr[6] ;
	static short prn_t_attr[10] ;
	static short prn_f_attr[5] ;
	static short prn_l_attr[6] ;
	short dummy ;

	switch( flag )
	{
		case SAVE :
			vqf_attributes( handle, scr_f_attr ) ;
			vqt_attributes( handle, scr_t_attr ) ;
			vql_attributes( handle, scr_l_attr ) ;
			break ;
		case RESTORE :
			vsf_color( handle, scr_f_attr[1] ) ;
			vsf_interior( handle, scr_f_attr[0] ) ;
			vswr_mode( handle, scr_f_attr[3] ) ;
			vst_color( handle, scr_t_attr[1] ) ;
			vst_height( handle, scr_t_attr[7], &dummy, &dummy, &dummy, &dummy) ;
			vst_alignment( handle, scr_t_attr[3], scr_t_attr[4], &dummy, &dummy) ;
			break ;
		case PRN_SAVE :
			vqf_attributes( handle, prn_f_attr ) ;
			vqt_attributes( handle, prn_t_attr ) ;
			vql_attributes( handle, prn_l_attr ) ;
			break ;
		case PRN_RESTORE :
			vsf_color( handle, prn_f_attr[1] ) ;
			vsf_interior( handle, prn_f_attr[0] ) ;
			vswr_mode( handle, prn_f_attr[3] ) ;
			vst_font( handle, prn_t_attr[0] ) ;
			vst_height( handle, prn_t_attr[7], &dummy, &dummy, &dummy, &dummy) ;
			vst_alignment( handle, prn_t_attr[3], prn_t_attr[4], &dummy, &dummy) ;
			break ;
		default :
			break ;
	}
}


void help( const char *subject )
{
	int help_id ;
	static char filename[200] ;
	unsigned short msg[8] ;

	help_id = appl_find( "ST-GUIDE" ) ;
	if( help_id != -1 )
	{
		getcwd( filename, 200 ) ;
		strcat( filename, "\\fam_tree.ref" ) ;

		msg[0] = AC_HELP ;
		msg[1] = ap_id ;
		msg[2] = 0 ;
		msg[3] = (long)subject >> 16 ;
		msg[4] = (long)subject ;
		msg[5] = 0x1993 ;
		msg[6] = (long)filename >> 16 ;
		msg[7] = (long)filename ;

		appl_write( help_id, 16, msg ) ;
	}
}


int  isalpha_accented( int c )
{
	c &= 0xFF ;

	return	( c >= 0x80 && c <= 0x9B )
			|| ( c >= 0xA0 && c <= 0xA7 )
			|| ( c >= 0xB0 && c <= 0xB8 )
			|| ( c >= 0xC0 && c <= 0xC1 ) ;
}


			/*****	 tidy_spaces										*****/
			/*	takes a string, removes leading spaces and converts			*/
			/* multiple spaces to single spaces								*/
			/*																*/
			/* Passed	string	string to be tidied							*/
			/* Return	void												*/
			/* Global	.......												*/
			
void  tidy_spaces( char *string )
{
	BOOLEAN Balready_spaced = TRUE ;	/*Assumes no space wanted at start	*/
	char *pc ;
	char *pcmover ;
	
	assert( string != NULL ) ;
	pc = string ;

	while( *pc )
	{
		if( *pc == ' ' )
		{
			if( Balready_spaced )
			{
						/* copy string back over itself, overwriting space	*/
				pcmover = pc ;
				while( *pcmover)
				{
					*pcmover = *(pcmover+1) ;
					pcmover++ ;
				}
			}
			Balready_spaced = TRUE ;
		}
		else  Balready_spaced = FALSE ;
		
		pc++ ;
	}
					/* remove any trailing space							*/
	if( Balready_spaced )  *(pc-1) = '\0' ;
}


			/*	takes a string, removes leading and trailing spaces			*/
			/* Passed	string	string to be tidied							*/
			/* Return	void												*/
			/* Global	.......												*/
			
void  remove_surrounding_spaces( char *string, short position )
{
	char* str_ptr ;
	short space_count = 0 ;
	
	if( position == TRAILING || position == SURROUNDING )
	{
		str_ptr = string + strlen(string) - 1 ;
		while( *str_ptr == ' ' && str_ptr >= string )  *str_ptr-- = '\0' ;
	}
	if( position == LEADING || position == SURROUNDING )
	{
		while( string[space_count] == ' ' )  space_count++ ;
	
		if( space_count > 0 )
			memmove( string, string + space_count,
								(size_t) strlen(string) + 1 - space_count ) ;
	}
}


void  v_box( int handle, const short pxy[4] )
{
	short newpxy[10] ;
	
	newpxy[0] = pxy[0] ;
	newpxy[1] = pxy[1] ;
	newpxy[2] = pxy[2] ;
	newpxy[3] = pxy[1] ;
	newpxy[4] = pxy[2] ;
	newpxy[5] = pxy[3] ;
	newpxy[6] = pxy[0] ;
	newpxy[7] = pxy[3] ;
	newpxy[8] = pxy[0] ;
	newpxy[9] = pxy[1] ;

	v_pline( handle, 5, newpxy ) ;
}


void  save_default_char( char* param_str, char param, FILE* fp )
{
	fputs( param_str, fp ) ;
	if( param != '\0' )  fputc( param, fp ) ;
	fputc( '\n', fp ) ;
}


void  save_yes_no_param( char* param_str, BOOLEAN yes, FILE* fp )
{
	if( yes )  fprintf( fp, "%sy\n", param_str ) ;
	else  fprintf( fp, "%sn\n", param_str ) ;
}


void  busy( short get_busier )
{
	static business = 0 ;

	switch( get_busier )
	{
		case BUSY_MORE :
			business++ ;
			if( business == 1 )  graf_mouse( BUSYBEE, NULL ) ;
			break ;
		case BUSY_LESS :
			if( business > 0 )  business-- ;
			if( business == 0 )  graf_mouse( ARROW, NULL ) ;
			break ;
		case BUSY_DEFEAT :
			graf_mouse( ARROW, NULL ) ;
			break ;
		case BUSY_RESTORE :
			if( business > 0 )  graf_mouse( BUSYBEE, NULL ) ;
			else  graf_mouse( ARROW, NULL ) ;
			break ;
		case BUSY_BLANK :
			graf_mouse( M_OFF, NULL ) ;
			break ;
		default :
			break ;
	}
}


/*
 * draw_check() function. Draws checkbox PROGDEFS
 */
 
int __stdargs __saveds draw_check( PARMBLK *parms )
{
	short pxyarray[4] ;
	short swap ;
	BOOLEAN check_needed = TRUE ;
	
	pxyarray[0] = parms->pb_x ;
	pxyarray[1] = parms->pb_y ;
	pxyarray[2] = parms->pb_x + parms->pb_w - 1 ;
	pxyarray[3] = parms->pb_y + parms->pb_h - 1 ;

	if( parms->pb_currstate == parms->pb_prevstate )
	{
		vsf_interior( check_vdih, FIS_HOLLOW ) ;
		vsf_color( check_vdih, BLACK ) ;
		vswr_mode( check_vdih, MD_REPLACE ) ;
		v_bar( check_vdih, pxyarray ) ;
		if( !(parms->pb_currstate & SELECTED) )  check_needed = FALSE ;
	}
	else  vswr_mode( check_vdih, MD_XOR ) ;

	if( check_needed )
	{
		pxyarray[0]++ ; pxyarray[1]++ ;
		pxyarray[2]-- ; pxyarray[3]-- ;
		v_pline( check_vdih, 2, pxyarray ) ;
		swap = pxyarray[0] ;
		pxyarray[0] = pxyarray[2] ;
		pxyarray[2] = swap ;
		v_pline( check_vdih, 2, pxyarray ) ;
	}
	
	return 0 ;
}

/*
 * draw_radio() function. Draws radio button (circle) PROGDEFS
 */
 
int __stdargs __saveds draw_radio( PARMBLK *parms )
{
	short centrex, centrey ;
	short invert = FALSE ;
	
	centrex = parms->pb_x + parms->pb_w / 2 ;
	centrey = parms->pb_y + parms->pb_h / 2 ;

	if( parms->pb_currstate != parms->pb_prevstate )  invert = TRUE ;
	else
	{
		vsf_interior( check_vdih, FIS_HOLLOW ) ;
		vsf_color( check_vdih, BLACK ) ;
		vswr_mode( check_vdih, MD_REPLACE ) ;
		v_circle( check_vdih, centrex, centrey, RBUTTON_OUTER_RADIUS ) ;
		if( parms->pb_currstate & SELECTED )  invert = TRUE ;
	}
	if( invert )
	{
		vswr_mode( check_vdih, MD_XOR ) ;
		vsf_interior( check_vdih, FIS_SOLID ) ;
		v_circle( check_vdih, centrex, centrey, RBUTTON_INNER_RADIUS ) ;
	}
	
	return 0 ;
}


void* pmalloc( size_t n )
{
	long available ;
	
	available = (long) Malloc( (size_t) -1 ) ;
	
	if( available > n + MEMORY_MARGIN )  return malloc( n ) ;
	else  return NULL ;
}


void  *checked_malloc( size_t amount )
{
	void* ptr = NULL ;
	
	ptr = pmalloc( amount ) ;
	if( ptr == NULL )
		rsrc_form_alert( 1, NO_MEMORY ) ;

	return ptr ;
}


int  rsrc_form_alert( int deflt, int index )
{
	char* alert_ptr ;
	int button ;
	
	rsrc_gaddr( R_STRING, index, &alert_ptr ) ;
	button = form_alert( deflt, alert_ptr ) ;

	return button ;
}


int  rsrc_form_alert_with_text( int deflt, int index, char* text )
{
	char alert_str[200] ;
	char* alert_ptr ;
	int button ;
	
	rsrc_gaddr( R_STRING, index, &alert_ptr ) ;
	sprintf( alert_str, alert_ptr, text ) ;
	button = form_alert( deflt, alert_str ) ;

	return button ;
}


#ifndef NDEBUG

void  report( const long event )
{
	char rep_string[40] ;

	sprintf( rep_string, "[1][value returned is %#.4X][OK]", event ) ;

	form_alert( 1, rep_string ) ;
}



void  str_report( const char *str )
{
	char alert_str[200] ;

	sprintf( alert_str, "[1][string is|%.30s][OK]", str ) ;

	form_alert( 1, alert_str ) ;
}


void  box_report( const GRECT *box_ptr )
{
	char alert_str[200] ;

	sprintf( alert_str, "[1][GRECT|%#.4X %#.4X|%#.4X %#.4X][OK]",
				box_ptr->g_x, box_ptr->g_y, box_ptr->g_w, box_ptr->g_h ) ;
	form_alert( 1, alert_str ) ;
}


void  freport( const int value )
{
	FILE *rp ;

	rp = fopen( "b:\\report", "a" ) ;
	fprintf( rp, "%d\n", value ) ;
	fclose( rp ) ;
}


void  fstr_report( const char *string )
{
	FILE *rp ;

	rp = fopen( "b:\\report", "a" ) ;
	fprintf( rp, "%s\n", string ) ;
	fclose( rp ) ;
}



/* Kept in case I use stk_report() again.	*/
extern unsigned long _STKDELTA ;
extern void *_base ;
void stk_report( void ) ;

void stk_report( void )
{
	char alert_str[70] ;

	sprintf( alert_str, "[1][Base is %X|Stk_delta is %X|Stack reaches %X][OK]",
			(int) _base, _STKDELTA, (int) alert_str ) ;
	form_alert( 1, alert_str ) ;
}
/*	*/

#endif

