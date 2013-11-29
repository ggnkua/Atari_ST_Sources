/************************************************************************/
/*																		*/
/*		Gencsvd.c	 5 Dec 99											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#define LONG_MAX (2147483647)

#include "genhd.h"
#include "genutil.h"
#include "gencsvd.h"
#include "gendata.h"
#include "gengedc.h"
#include "genmain.h"
#include "genpers.h"
#include "genpprn.h"

extern short scr_handle ;		/* GEM vdi handle used by AES			*/
								/* initialised work array for open		*/
								/* virtual workstation					*/
extern short pblock_changed[MAX_PEOPLE_BLOCKS] ;
extern char *next_pstring_ptr[MAX_PEOPLE_BLOCKS] ;
extern char *pblock_end[MAX_PEOPLE_BLOCKS] ;
extern int next_person ;

extern Index_couple *couples ;
extern char male_char, female_char ;
extern char* edit_buffer ;

extern Wind_edit_params pers_form, birth_form, baptism_form, death_form ;
extern OBJECT *strings_ptr ;			/* pointer to resource strings			*/
extern OBJECT *flags_ptr ;
extern struct
{
	char *fl[8] ;
} flags_addrs ;

OBJECT* csv_sel_ptr ;
const char* const csv_selector_help = "Export Data Selector" ;
OBJECT* csv_fmt_ptr ;
const char* const csv_format_help = "CSV Data Format" ;

int parameter_list[] = { 'ref', 'fam', 'for', 'sex', 'occ', 'bid', 'bip', 'bis',	/* 8	*/
						 'bad',	'bap', 'bas', 'ded', 'dep', 'des', 'bcp', 'bcd',	/* 16	*/
						 'dwd',	'dws', 'exs', 'sol', 'bes',							/* 21	*/
						 'cou', 'not', 'nch', 'mot', 'fat',							/* 26	*/
						 'fl1','fl2','fl3','fl4','fl5','fl6','fl7','fl8', 0 } ;		/* 34	*/
BOOLEAN param_selected[NO_OF_PARAMS+1] ;

short max_length[] = { 0, FAM_NAME_LENGTH, FORENAME_LENGTH, 0, OCCUPATION_LENGTH, 0, BIRTH_PLACE_LENGTH, BIRTH_SOURCE_LENGTH,
					 0, BAPTISM_PLACE_LENGTH, BAPTISM_SOURCE_LENGTH, 0, DEATH_PLACE_LENGTH, DEATH_SOURCE_LENGTH, BURIAL_PLACE_LENGTH, 0,
					 0, WILL_WITNESS_LENGTH, WILL_EXECUTOR_LENGTH, WILL_SOLICITOR_LENGTH, WILL_BENEFICIARY_LENGTH,
					 0, BUFFER_SIZE, 0, 0, 0,
					 0, 0, 0, 0, 0, 0, 0, 0 } ;

int csv_list[NO_OF_PARAMS+1] ;
int saved_csv_list[NO_OF_PARAMS+1] ;
BOOLEAN csv_selected[NO_OF_PARAMS+1] ;
short csv_entries ;

char csv_new_line = '\\' ;
char csv_separator = ',' ;
char csv_quote = '"' ;
char csv_quote_replacement = '\'' ;
BOOLEAN csv_date_as_text = FALSE ;
int csv_default_date = 0 ;
short csv_max_line_length = 0 ;

char saved_csv_new_line = '\\' ;
char saved_csv_separator = ',' ;
char saved_csv_quote = '"' ;
char saved_csv_quote_replacement = '\'' ;
BOOLEAN saved_csv_date_as_text = FALSE ;
int saved_csv_default_date = 0 ;
short saved_csv_max_line_length = 0 ;

struct
{
	char* new_line ;
	char* separator ;
	char* quote ;
	char* quote_replacement ;
	char* default_year ;
	char* default_mon ;
	char* default_day ;
	char* max_line_length ;
} csv_fmt_addrs ;

void  select_csv_params( void )
{
	BOOLEAN done = FALSE ;
	short button ;
	short dbl ;							/* button double clicked		*/
	short param_oset = 0 ;
	short csv_oset = 0 ;
	short m_x, m_y ;
	short kstate ;
	short dummy ;
	short obj_x, obj_y ;
	short selection ;
	short i ;
	int old_list[NO_OF_PARAMS+1] ;
	short old_csv_entries ;

	assert( PARAM2 == PARAM1 + 1 ) ;
	assert( PARAM3 == PARAM1 + 2 ) ;
	assert( PARAM4 == PARAM1 + 3 ) ;
	assert( PARAM5 == PARAM1 + 4 ) ;
	assert( PARAM6 == PARAM1 + 5 ) ;
	assert( PARAM7 == PARAM1 + 6 ) ;
	assert( PARAM8 == PARAM1 + 7 ) ;
	assert( PARAM9 == PARAM1 + 8 ) ;
	assert( PARAM10 == PARAM1 + 9 ) ;
	assert( PARAM11 == PARAM1 + 10 ) ;
	assert( PARAM12 == PARAM1 + 11 ) ;
	assert( CSV2 == CSV1 + 1 ) ;
	assert( CSV3 == CSV1 + 2 ) ;
	assert( CSV4 == CSV1 + 3 ) ;
	assert( CSV5 == CSV1 + 4 ) ;
	assert( CSV6 == CSV1 + 5 ) ;
	assert( CSV7 == CSV1 + 6 ) ;
	assert( CSV8 == CSV1 + 7 ) ;
	assert( CSV9 == CSV1 + 8 ) ;
	assert( CSV10 == CSV1 + 9 ) ;
	assert( CSV11 == CSV1 + 10 ) ;
	assert( CSV12 == CSV1 + 11 ) ;

	old_csv_entries = csv_entries ;
	for( i=0; i<NO_OF_PARAMS+1; i++ )
	{
		param_selected[i] = FALSE ;
		csv_selected[i] = FALSE ;
		old_list[i] = csv_list[i] ;
	}

	csv_sel_ptr[PARAM_SLIDER].ob_height
					= csv_sel_ptr[PARAM_SLIDE_BOX].ob_height * NO_DISPLAYED / NO_OF_PARAMS ;
	set_slide( 0, NO_OF_PARAMS-NO_DISPLAYED, csv_sel_ptr,
										PARAM_SLIDER, PARAM_SLIDE_BOX, app_modal_box() ) ;
	update_param_list( 0 ) ;

	set_csv_slider_height( csv_entries ) ;
	set_slide( 0, csv_entries-NO_DISPLAYED, csv_sel_ptr,
										CSV_SLIDER, CSV_SLIDE_BOX, app_modal_box() ) ;
	update_csv_list( 0 ) ;
		

	app_modal_init( csv_sel_ptr, csv_selector_help, TITLED ) ;

	while( !done )
	{
		button = app_modal_do() ;
		graf_mkstate( &m_x, &m_y, &dummy, &kstate ) ;

		dbl = button & DOUBLE_CLICK ;
		button &= ~DOUBLE_CLICK ;

		update_selections( param_oset, csv_oset ) ;
		
		switch( button )
		{
			case PARAM_IBOX :
				rubber_band_params( m_x, m_y, param_oset, kstate, PARAM_IBOX ) ;
				if( clear_selections( csv_selected, csv_entries ) )  update_csv_box( csv_oset ) ;
				break ;
			case CSV_IBOX :
				rubber_band_params( m_x, m_y, csv_oset, kstate, CSV_IBOX ) ;
				if( clear_selections( param_selected, NO_OF_PARAMS ) )  update_param_box( param_oset ) ;
				break ;
			case CSV_SAVE :
				for( i=0; i < NO_OF_PARAMS+1; i++ )  saved_csv_list[i] = csv_list[i] ;
				save_defaults() ;
								/* deliberately no break	*/
			case CSV_OK :
				done = TRUE ;
				break ;
			case CSV_CANCEL :
			case APP_MODAL_TERM :
				for( i=0; i < NO_OF_PARAMS+1; i++ )  csv_list[i] = old_list[i] ;
				csv_entries = old_csv_entries ;
				done = TRUE ;
				break ;
			case CSV_HELP :
				help( csv_selector_help ) ;
				break ;
			case PARAM_SLIDER :
				param_oset = move_slide( csv_sel_ptr,
										PARAM_SLIDER, PARAM_SLIDE_BOX, app_modal_box() ) ;
				param_oset = ( NO_OF_PARAMS - NO_DISPLAYED ) * param_oset / 1000 ;

				update_param_list( param_oset ) ;
				objc_draw( csv_sel_ptr, PARAM_BOX, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				break ;
			case PARAM_UP :
				if( param_oset > 0 )
				{
					param_oset-- ;
					update_param_box( param_oset ) ;
				}
				break ;
			case PARAM_DOWN :
				if( param_oset < NO_OF_PARAMS - NO_DISPLAYED )
				{
					param_oset++ ;
					update_param_box( param_oset ) ;
				}
				break ;
			case PARAM_SLIDE_BOX :
				objc_offset( csv_sel_ptr, PARAM_SLIDER, &obj_x, &obj_y ) ;
				if( m_y > obj_y )
				{
					param_oset += NO_DISPLAYED - 1 ;
					if( param_oset > NO_OF_PARAMS - NO_DISPLAYED )  param_oset = NO_OF_PARAMS - NO_DISPLAYED ;
				}
				else
				{
					param_oset -= NO_DISPLAYED - 1 ;
					if( param_oset < 0 )  param_oset = 0 ;
				}
				update_param_box( param_oset ) ;
				break ;
			case PARAM1 :
			case PARAM2 :
			case PARAM3 :
			case PARAM4 :
			case PARAM5 :
			case PARAM6 :
			case PARAM7 :
			case PARAM8 :
			case PARAM9 :
			case PARAM10 :
			case PARAM11 :
			case PARAM12 :
				{
					BOOLEAN update_param = FALSE ;
					BOOLEAN update_csv = FALSE ;

					selection = button - PARAM1 + param_oset ;

					update_csv = clear_selections( csv_selected, csv_entries ) ;

					if( !( kstate & (K_LSHIFT | K_RSHIFT) ) )
					{
						update_param = clear_selections_set_one( param_selected, NO_OF_PARAMS, selection ) ;
					
						if( dbl )
						{
							add_csv_entry( selection, WARN_SELECTED ) ;
							update_boxes( csv_entries, csv_oset, param_oset ) ;
							update_param = FALSE ;
							update_csv = FALSE ;
						}
					}
					if( update_param )  update_param_box( param_oset ) ;
					if( update_csv )  update_csv_box( csv_oset ) ;
				}
				break ;
			case CSV1 :
			case CSV2 :
			case CSV3 :
			case CSV4 :
			case CSV5 :
			case CSV6 :
			case CSV7 :
			case CSV8 :
			case CSV9 :
			case CSV10 :
			case CSV11 :
			case CSV12 :
				{
					BOOLEAN update_csv = FALSE ;
					BOOLEAN update_param = FALSE ;

					if( !( kstate & (K_LSHIFT | K_RSHIFT) ) )
					{
						update_param = clear_selections( param_selected, NO_OF_PARAMS ) ;

						selection = button - CSV1 + csv_oset ;
						update_csv = clear_selections_set_one( csv_selected, csv_entries, selection ) ;
					
						if( dbl )
						{
							remove_csv_entry( selection ) ;
							update_csv = TRUE ;
						}
					}

					if( update_param )  update_param_box( param_oset ) ;
					if( update_csv )  update_csv_box( csv_oset ) ;
				}
				break ;
			case CSV_SLIDER :
				if( csv_entries > NO_DISPLAYED )
				{
					csv_oset = move_slide( csv_sel_ptr,
										CSV_SLIDER, CSV_SLIDE_BOX, app_modal_box() ) ;
					csv_oset = ( csv_entries - NO_DISPLAYED ) * csv_oset / 1000 ;

					update_csv_list( csv_oset ) ;
					objc_draw( csv_sel_ptr, CSV_BOX, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				}
				break ;
			case CSV_UP :
				if( csv_oset > 0 )
				{
					csv_oset-- ;
					update_csv_box( csv_oset ) ;
				}
				break ;
			case CSV_DOWN :
				if( csv_oset < csv_entries - NO_DISPLAYED )
				{
					csv_oset++ ;
					update_csv_box( csv_oset ) ;
				}
				break ;
			case CSV_SLIDE_BOX :
				graf_mkstate( &m_x, &m_y, &dummy, &dummy ) ;
				objc_offset( csv_sel_ptr, CSV_SLIDER, &obj_x, &obj_y ) ;
				if( m_y > obj_y )
				{
					csv_oset += NO_DISPLAYED - 1 ;
					if( csv_oset > csv_entries - NO_DISPLAYED )  csv_oset = csv_entries - NO_DISPLAYED ;
				}
				else
				{
					csv_oset -= NO_DISPLAYED - 1 ;
					if( csv_oset < 0 )  csv_oset = 0 ;
				}
				update_csv_box( csv_oset ) ;
				break ;
			case CSV_ADD :
				{
					short index ;
					
					for( index = 0; index<NO_OF_PARAMS; index++ )
						if( param_selected[index] )  add_csv_entry( index, WARN_SELECTED ) ;
				}
				
				update_boxes( csv_entries, csv_oset, param_oset ) ;
				break ;
			case ADD_ALL :
				{
					short index ;
					
					for( index = 0; index<NO_OF_PARAMS; index++ )  add_csv_entry( index, !WARN_SELECTED ) ;
				}
				update_boxes( csv_entries, csv_oset, param_oset ) ;
				break ;
			case CSV_REMOVE :
				{
					short index ;
					
					for( index = 0; index < csv_entries; )
					{
						if( csv_selected[index] )  remove_csv_entry( index ) ;
						else  index++ ;
					}
				}
				while( csv_oset > 0 && NO_DISPLAYED + csv_oset > csv_entries )  csv_oset-- ;
				set_csv_slider_height( csv_entries ) ;
				update_csv_box( csv_oset ) ;
				break ;
			case REMOVE_ALL :
				while( csv_entries > 0 )  remove_csv_entry( 0 ) ;
				csv_oset = 0 ;
				set_csv_slider_height( csv_entries ) ;
				update_csv_box( csv_oset ) ;
				break ;
			case CSV_SOONER :
				csv_sooner() ;
				update_csv_box( csv_oset ) ;
				break ;
			case CSV_LATER :
				csv_later() ;
				update_csv_box( csv_oset ) ;
				break ;
			default :
				break ;
		}
		
		if( !( button >= PARAM1 && button <= PARAM12)
			&& !( button >= CSV1 && button <= CSV12)
			&& !( button == APP_MODAL_TERM )
			&& csv_sel_ptr[button].ob_state & SELECTED )
		{
			csv_sel_ptr[button].ob_state &= ~SELECTED ;
			if( !done )  objc_draw( csv_sel_ptr, button, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
		}
	}

	app_modal_end() ;
}


BOOLEAN  clear_selections( BOOLEAN* selected, short entries )
{
	return clear_selections_set_one( selected, entries, -1 ) ;
}


BOOLEAN  clear_selections_set_one( BOOLEAN* selected, short entries, short selection )
{
	short index ;
	BOOLEAN update = FALSE ;
	
	for( index = 0; index < entries; index++ )
	{
		if( index != selection )
		{
			if( selected[index] )  update = TRUE ;
			selected[index] = FALSE ;
		}
		else  selected[index] = TRUE ;
	}
	
	return update ;
}


void  add_csv_entry( short index, BOOLEAN warn_already_selected )
{
	if( not_already_listed( index ) )
	{
		csv_list[csv_entries] = parameter_list[index] ;
		csv_selected[csv_entries] = TRUE ;
		csv_entries++ ;
	}
	else if( warn_already_selected )
	{
		char temp_str[100] ;
		write_param_name( temp_str, parameter_list[index] ) ;
		rsrc_form_alert_with_text( 1, ALREADY_SELECTED, temp_str ) ;
	}
	param_selected[index] = FALSE ;
}


void  remove_csv_entry( short index )
{
	short i ;

	for( i=index; i < csv_entries; i++ )
	{
		csv_list[i] = csv_list[i+1] ;
		csv_selected[i] = csv_selected[i+1] ;
	}
	csv_entries-- ;
}


void  csv_sooner( void )
{
	short i = 0 ;

	while( i < csv_entries && csv_selected[i] == TRUE )  i++ ;
	while( i < csv_entries )
	{
		if( csv_selected[i] )
		{
			int temp = csv_list[i-1] ;
			csv_list[i-1] = csv_list[i] ;
			csv_list[i] = temp ;
			csv_selected[i-1] = TRUE ;
			csv_selected[i] = FALSE ;
		}
		i++ ;
	}
}


void  csv_later( void )
{
	short i = csv_entries - 1 ;

	while( i > 0 && csv_selected[i] == TRUE )  i-- ;
	while( i >= 0 )
	{
		if( csv_selected[i] )
		{
			int temp = csv_list[i+1] ;
			csv_list[i+1] = csv_list[i] ;
			csv_list[i] = temp ;
			csv_selected[i+1] = TRUE ;
			csv_selected[i] = FALSE ;
		}
		i-- ;
	}
}


void  update_boxes( short csv_entries, short csv_oset, short param_oset )
{
	set_csv_slider_height( csv_entries ) ;
	update_csv_box( csv_oset ) ;
	update_param_box( param_oset ) ;
}



void  rubber_band_params( short m_x, short m_y, short oset, short kstate, BOOLEAN field )
{
	short new_x, new_y ;
	short p_x, p_y ;
	short p_r, p_b ;
	BOOLEAN update = FALSE ;
	short i ;
	BOOLEAN* selected ;
	short first_field ;
	
	rubber_band( scr_handle, &new_x, &new_y, m_x, m_y, SOLID ) ;
	
	selected = ( field == PARAM_IBOX ) ? param_selected : csv_selected ;
	first_field = ( field == PARAM_IBOX ) ? PARAM1 : CSV1 ;
	
	if( !( kstate & (K_LSHIFT | K_RSHIFT) ) )
	{
		for( i= 0; i<NO_OF_PARAMS; i++ )
		{
			if( selected[i] )
			{
				selected[i] = FALSE ;
				update = TRUE ;
			}
		}
	}
	
	objc_offset( csv_sel_ptr, first_field, &p_x, &p_y ) ;
	p_r = p_x + csv_sel_ptr[first_field].ob_width ;
	
	if( ( m_x < p_x && new_x > p_x ) || ( m_x > p_r && new_x < p_r ) )
	{
		/* i.e. rubber band overlaps parameters	*/
		for( i= 0; i< NO_DISPLAYED; i++ )
		{
			objc_offset( csv_sel_ptr, first_field+i, &p_x, &p_y ) ;
			p_b = p_y + csv_sel_ptr[first_field].ob_height ;
			
			if( ( m_y < p_y && new_y > p_y ) || ( m_y > p_y && new_y < p_y )
				|| ( m_y > p_b && new_y < p_b ) || ( m_y < p_b && new_y > p_b ) )
			{
				if( !selected[oset+i] )
				{
					selected[oset+i] = TRUE ;
					update = TRUE ;
				}
			}
		}
	}
	if( update )  ( field == PARAM_IBOX ) ? update_param_box( oset ) : update_csv_box( oset ) ;
}


void  update_param_list( short param_oset )
{
	short index ;
	
	for( index=0; index<NO_DISPLAYED; index++ )
	{
		if( param_selected[param_oset+index] )  csv_sel_ptr[PARAM1+index].ob_state |= SELECTED ;
		else  csv_sel_ptr[PARAM1+index].ob_state &= ~SELECTED ;
		
		write_param_name( FORM_TEXT(csv_sel_ptr, PARAM1+index), parameter_list[param_oset+index] ) ;
	}
}


void  update_param_box( short param_oset )
{
	set_slide( param_oset, NO_OF_PARAMS-NO_DISPLAYED, csv_sel_ptr,
										PARAM_SLIDER, PARAM_SLIDE_BOX, app_modal_box() ) ;
	update_param_list( param_oset ) ;
	objc_draw( csv_sel_ptr, PARAM_BOX, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
}


BOOLEAN  not_already_listed( short index )
{
	BOOLEAN listed = FALSE ;
	short i = 0 ;
	
	while( csv_list[i] != 0 )
		if( csv_list[i++] == parameter_list[index] )  listed = TRUE ;

	return !listed ;
}


void  update_csv_list( short csv_oset )
{
	short index ;
	
	for( index=0; index<NO_DISPLAYED && csv_list[index+csv_oset] != 0; index++ )
	{
		if( csv_selected[csv_oset+index] )  csv_sel_ptr[CSV1+index].ob_state |= SELECTED ;
		else  csv_sel_ptr[CSV1+index].ob_state &= ~SELECTED ;

		csv_sel_ptr[CSV1+index].ob_flags |= SELECTABLE ;

		write_param_name( FORM_TEXT(csv_sel_ptr, CSV1+index), csv_list[index+csv_oset] ) ;
	}
	while( index<NO_DISPLAYED )
	{
		FORM_TEXT(csv_sel_ptr, CSV1+index)[0] = '\0' ;
		csv_sel_ptr[CSV1+index].ob_state &= ~SELECTED ;
		csv_sel_ptr[CSV1+index].ob_flags &= ~SELECTABLE ;
		index++ ;
	}
}


void  set_csv_slider_height( short csv_entries )
{
	if( csv_entries > NO_DISPLAYED )
	{
		csv_sel_ptr[CSV_SLIDER].ob_height
				= csv_sel_ptr[CSV_SLIDE_BOX].ob_height * NO_DISPLAYED / csv_entries ;
	}
	else  csv_sel_ptr[CSV_SLIDER].ob_height	= csv_sel_ptr[CSV_SLIDE_BOX].ob_height ;
}


void  update_csv_box( short csv_oset )
{
	set_slide( csv_oset, csv_entries-NO_DISPLAYED, csv_sel_ptr,
										CSV_SLIDER, CSV_SLIDE_BOX, app_modal_box() ) ;
	update_csv_list( csv_oset ) ;
	objc_draw( csv_sel_ptr, CSV_BOX, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
}


void  update_selections( short param_oset, short csv_oset )
{
	short index ;
	
	for( index = 0; index < NO_DISPLAYED; index++ )
	{
		param_selected[index+param_oset] = (csv_sel_ptr[PARAM1+index].ob_state & SELECTED) ? TRUE : FALSE ;
		csv_selected[index+csv_oset] = (csv_sel_ptr[CSV1+index].ob_state & SELECTED) ? TRUE : FALSE ;
	}
}

void  write_param_name( char* dest, int param_tag )
{

	assert( FLAG2 == FLAG1 + (FLAG2 - FLAG1) * ('fl2' - 'fl1' ) ) ;
	assert( FLAG3 == FLAG1 + (FLAG2 - FLAG1) * ('fl3' - 'fl1' ) ) ;
	assert( FLAG4 == FLAG1 + (FLAG2 - FLAG1) * ('fl4' - 'fl1' ) ) ;
	assert( FLAG5 == FLAG1 + (FLAG2 - FLAG1) * ('fl5' - 'fl1' ) ) ;
	assert( FLAG6 == FLAG1 + (FLAG2 - FLAG1) * ('fl6' - 'fl1' ) ) ;
	assert( FLAG7 == FLAG1 + (FLAG2 - FLAG1) * ('fl7' - 'fl1' ) ) ;
	assert( FLAG8 == FLAG1 + (FLAG2 - FLAG1) * ('fl8' - 'fl1' ) ) ;

	switch( param_tag )
	{
		case 'ref' :
			extract_string( pers_form.fm_ptr, P_REFERENCE, dest ) ;
			break ;
		case 'fam' :
			extract_string( pers_form.fm_ptr, FAMILY_NAME, dest ) ;
			break ;
		case 'for' :
			extract_string( pers_form.fm_ptr, FORENAMES, dest ) ;
			break ;
		case 'sex' :
			extract_string( strings_ptr, SEX_STR, dest ) ;
			break ;
		case 'occ' :
			extract_string( pers_form.fm_ptr, OCCUPATION, dest ) ;
			break ;
		case 'bid' :
			extract_string( strings_ptr, BI_DATE_STR, dest ) ;
			break ;
		case 'bip' :
			extract_string( pers_form.fm_ptr, BIRTH_PLACE, dest ) ;
			break ;
		case 'bis' :
			extract_string( strings_ptr, BI_SRC_STR, dest ) ;
			break ;
		case 'bad' :
			extract_string( strings_ptr, BA_DATE_STR, dest ) ;
			break ;
		case 'bap' :
			extract_string( baptism_form.fm_ptr, BA_PLACE, dest ) ;
			break ;
		case 'bas' :
			extract_string( strings_ptr, BA_SRC_STR, dest ) ;
			break ;
		case 'ded' :
			extract_string( strings_ptr, DTH_DATE_STR, dest ) ;
			break ;
		case 'dep' :
			extract_string( death_form.fm_ptr, D_PLACE, dest ) ;
			break ;
		case 'des' :
			extract_string( strings_ptr, DW_SRC_STR, dest ) ;
			break ;
		case 'bcp' :
			extract_string( death_form.fm_ptr, BC_PLACE, dest ) ;
			break ;
		case 'bcd' :
			extract_string( death_form.fm_ptr, BCDATE, dest ) ;
			break ;
		case 'dwd' :
			extract_string( strings_ptr, DW_DATE_STR, dest ) ;
			break ;
		case 'dws' :
			extract_string( death_form.fm_ptr, DWIT1, dest ) ;
			break ;
		case 'exs' :
			extract_string( death_form.fm_ptr, EXEC1, dest ) ;
			break ;
		case 'sol' :
			extract_string( death_form.fm_ptr, SOLIC, dest ) ;
			break ;
		case 'bes' :
			extract_string( death_form.fm_ptr, BENEF, dest ) ;
			break ;
		case 'cou' :
			extract_string( strings_ptr, COUPLES_STR, dest ) ;
			break ;
		case 'not' :
			extract_string( strings_ptr, NOTES_STR, dest ) ;
			break ;
		case 'nch' :
			extract_string( strings_ptr, NO_CHILDREN_STR, dest ) ;
			break ;
		case 'mot' :
			extract_string( pers_form.fm_ptr, MOTHER, dest ) ;
			break ;
		case 'fat' :
			extract_string( pers_form.fm_ptr, FATHER, dest ) ;
			break ;
		case 'fl1' :
		case 'fl2' :
		case 'fl3' :
		case 'fl4' :
		case 'fl5' :
		case 'fl6' :
		case 'fl7' :
		case 'fl8' :
			strcpy( dest, FORM_TEXT( flags_ptr, FLAG1 + (FLAG2 - FLAG1) * (param_tag - 'fl1') ) ) ;
			if( dest[0] == '\0' )
			{
				char number[3] ;
				
				number[0] = ' ' ;
				number[1] = '1' + param_tag - 'fl1' ;
				number[2] = '\0' ;
				extract_string( pers_form.fm_ptr, PFLAGS, dest ) ;
				strcat( dest, number ) ;
			}
			break ;
		default :
			strcpy( dest, "other strings" ) ;
			break ;
	}
}


void  extract_flag( char* dest, short flag_number )
{
	short field ;
	char number_str[] = "0" ;
	
	field = FLAG1 + flag_number - 1 ;
	
	strcpy( dest, FORM_TEXT( flags_ptr, field ) ) ;
	
	if( dest[0] == '\0' )
	{
		extract_string( strings_ptr, FLAGS_STR, dest ) ;
		number_str[0] = '0' + flag_number ;
		strcat( dest, number_str ) ;
	}
}


void  set_csv_format( void )
{
	short button ;
	BOOLEAN done = FALSE ;
	
	set_csv_fmt_addrs() ;
	write_csv_format() ;

	app_modal_init( csv_fmt_ptr, csv_format_help, TITLED ) ;

	while( !done )
	{
		button = app_modal_do() ;
		button &= ~DOUBLE_CLICK ;
		
		switch( button )
		{
			case CSV_FMT_OK :
				read_csv_format() ;
				done = TRUE ;
				break ;
			case CSV_FMT_CANCEL :
				done = TRUE ;
				break ;
			case CSV_FMT_SAVE :
				save_csv_format() ;
				done = TRUE ;
				break ;
			case CSV_FMT_HELP :
				help( csv_format_help ) ;
				break ;
			case APP_MODAL_TERM :
				done = TRUE ;
				break ;
			default :
				break ;
		}
		
		if( button != APP_MODAL_TERM )  csv_fmt_ptr[button].ob_state &= ~SELECTED ;
		if( !done )  objc_draw( csv_fmt_ptr, button, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
	}
	app_modal_end() ;
}


void  set_csv_fmt_addrs( void )
{
	csv_fmt_addrs.separator = FORM_TEXT( csv_fmt_ptr, CSV_SEPARATOR ) ;
	csv_fmt_addrs.new_line = FORM_TEXT( csv_fmt_ptr, CSV_NEWLINE ) ;
	csv_fmt_addrs.quote = FORM_TEXT( csv_fmt_ptr, CSV_QUOTE ) ;
	csv_fmt_addrs.quote_replacement = FORM_TEXT( csv_fmt_ptr, CSV_REPLACEMENT ) ;
	csv_fmt_addrs.max_line_length = FORM_TEXT( csv_fmt_ptr, CSV_MAX_LENGTH ) ;
	csv_fmt_addrs.default_year = FORM_TEXT( csv_fmt_ptr, CSV_DEFAULT_YR ) ;
	csv_fmt_addrs.default_mon = FORM_TEXT( csv_fmt_ptr, CSV_DEFAULT_MON ) ;
	csv_fmt_addrs.default_day = FORM_TEXT( csv_fmt_ptr, CSV_DEFAULT_DAY ) ;
}


void  write_csv_format( void )
{
	*(csv_fmt_addrs.separator) = csv_separator ;
	*(csv_fmt_addrs.new_line) = csv_new_line ;
	*(csv_fmt_addrs.quote) = csv_quote ;
	*(csv_fmt_addrs.quote_replacement) = csv_quote_replacement ;
	sprintf( csv_fmt_addrs.max_line_length, "%04hd", csv_max_line_length ) ;
	
	if( csv_date_as_text )  csv_fmt_ptr[CSV_DATE_AS_TEXT].ob_state |= SELECTED ;
	else  csv_fmt_ptr[CSV_DATE_AS_TEXT].ob_state &= ~SELECTED ;
	sprintf( csv_fmt_addrs.default_year, "%04hd", csv_default_date / 10000 ) ;
	sprintf( csv_fmt_addrs.default_mon, "%02hd", ( csv_default_date / 100 ) % 100 ) ;
	sprintf( csv_fmt_addrs.default_day, "%02hd", csv_default_date % 100 ) ;
}


void  save_csv_format( void )
{
	read_csv_format() ;
	
	saved_csv_separator = csv_separator ;
	saved_csv_new_line = csv_new_line ;
	saved_csv_quote = csv_quote ;
	saved_csv_quote_replacement = csv_quote_replacement ;
	saved_csv_date_as_text = csv_date_as_text ;
	saved_csv_default_date = csv_default_date ;
	saved_csv_max_line_length = csv_max_line_length ;

	save_defaults() ;
}

void  read_csv_format( void )
{
	int day, mon, year ;

	csv_separator = *(csv_fmt_addrs.separator) ;
	csv_new_line = *(csv_fmt_addrs.new_line) ;
	csv_quote = *(csv_fmt_addrs.quote) ;
	csv_quote_replacement = *(csv_fmt_addrs.quote_replacement) ;
	csv_max_line_length = atoi( csv_fmt_addrs.max_line_length ) ;
	
	if( csv_fmt_ptr[CSV_DATE_AS_TEXT].ob_state & SELECTED )  csv_date_as_text = TRUE ;
	else  csv_date_as_text = FALSE ;
	year = atoi( csv_fmt_addrs.default_year ) ;
	mon = atoi( csv_fmt_addrs.default_mon ) ;
	mon = min( mon, 12 ) ;
	day = atoi( csv_fmt_addrs.default_day ) ;
	day = min( day, 31 ) ;
	
	csv_default_date = 10000 * year + 100 * mon + day ;
}


void  load_csv_file( FILE* fp )
{
	char buffer[BUFFER_SIZE] ;
	char* error_string ;
	short i ;
	int param_tag ;
	BOOLEAN succeed = TRUE ;
	int ref = 0 ;
	Person* pptr = NULL ;
	short block ;
	char ch ;
	
	int line = 0 ;

	while( fgets( buffer, BUFFER_SIZE - 1, fp ), succeed && !feof( fp ) )
	{
		BOOLEAN done = FALSE ;
		char* buf_ptr = buffer ;
		
		line++ ;

		if( ref != 0 )
		{
			assert( pptr != NULL ) ;
			add_to_pidx( ref, pptr ) ;
		}
		ref = next_person ;
		pptr = get_pdata_ptr( ref, &block ) ;
		next_person++ ; 
		pblock_changed[block] = TRUE ;
		
		for( i=0 ; i<csv_entries && !done && succeed ; i++ )
		{
			param_tag = csv_list[i] ;
			
			error_string = buf_ptr ;

			switch( param_tag )
			{
				case 'fam' :
				case 'for' :
				case 'bip' :
				case 'bis' :
				case 'occ' :
				case 'bap' :
				case 'bas' :
				case 'dep' :
				case 'des' :
				case 'bcp' :
				case 'sol' :
				case 'not' :
					succeed = load_csv_string( pptr, &buf_ptr, param_tag, block ) ;
					break ;
				case 'sex' :
					succeed = load_csv_sex( pptr, &buf_ptr ) ;
					break ;
				case 'bid' :
				case 'bad' :
				case 'ded' :
				case 'bcd' :
				case 'dwd' :
					succeed = load_csv_date( pptr, &buf_ptr, param_tag ) ;
					break ;
				case 'dws' :
				case 'exs' :
				case 'bes' :
					succeed = load_csv_strings( pptr, &buf_ptr, param_tag, block ) ;
					break ;
				case 'fl1' :
				case 'fl2' :
				case 'fl3' :
				case 'fl4' :
				case 'fl5' :
				case 'fl6' :
				case 'fl7' :
				case 'fl8' :
					succeed = load_csv_flags( pptr, &buf_ptr, param_tag ) ;
					break ;
				case 'ref' :	/* unused inputs	*/
				case 'cou' :
				case 'nch' :
				case 'mot' :
				case 'fat' :
					while( ch = *buf_ptr++, ch != '\0' && ch != csv_separator ) ; 
					break ;
				default :
					succeed = FALSE ;
#ifndef NDEBUG
					str_report( "Not handled, param number" ) ;
					report( param_tag ) ;
#endif
					break ;
			}
		}
	}

	if( ref != 0 )
	{
		assert( pptr != NULL ) ;
		add_to_pidx( ref, pptr ) ;
	}
	if( !succeed )
	{
		char alert_str[200] ;
		char* alert_ptr ;
		char parameter_name[100] ;
		
		write_param_name( parameter_name, param_tag ) ;
		error_string[30] = '\0' ;
		rsrc_gaddr( R_STRING, CSV_ERROR, &alert_ptr ) ;
		sprintf( alert_str, alert_ptr, i, line, parameter_name, error_string ) ;
		form_alert( 1, alert_str ) ;
	}
}		


BOOLEAN  load_csv_string( Person* pptr, char** buf_ptr, int param_tag, short block )
{
	char** dest_ptr = NULL ;
	BOOLEAN succeed ;
	short limit_length ;
	char temp_buf[BUFFER_SIZE+1] ;
	short dummy ;
	
	limit_length = csv_string_length( param_tag ) ;
	succeed = copy_csv_string( temp_buf, buf_ptr, limit_length ) ;
	switch( param_tag )
	{
		case 'fam' :
			dest_ptr = &(pptr->family_name) ;
			break ;
		case 'for' :
			dest_ptr = &(pptr->forenames) ;
			break ;
		case 'bip' :
			dest_ptr = &(pptr->birth_place) ;
			break ;
		case 'bis' :
			dest_ptr = &(pptr->birth_source) ;
			break ;
		case 'occ' :
			dest_ptr = &(pptr->occupation) ;
			break ;
		case 'bap' :
			dest_ptr = &(pptr->baptism_place) ;
			break ;
		case 'bas' :
			dest_ptr = &(pptr->baptism_source) ;
			break ;
		case 'dep' :
			dest_ptr = &(pptr->death_place) ;
			break ;
		case 'des' :
			dest_ptr = &(pptr->death_source) ;
			break ;
		case 'bcp' :
			dest_ptr = &(pptr->burial_place) ;
			break ;
		case 'sol' :
			dest_ptr = &(pptr->will_sol) ;
			break ;
		case 'not' :
			dest_ptr = &(pptr->notes) ;
			break ;
		default :
			break ;
	}
		
	str_save( dest_ptr, temp_buf,
			&next_pstring_ptr[block], pblock_end[block], &dummy ) ;

	return succeed ;
}


BOOLEAN  load_csv_strings( Person* pptr, char** buf_ptr, int param_tag, short block )
{
	BOOLEAN succeed ;
	short limit_length ;
	char temp_buf[100] ;
	short dummy ;

	limit_length = csv_string_length( param_tag ) ;

	switch( param_tag )
	{
		case 'dws' :
			succeed = copy_csv_string( temp_buf, buf_ptr, limit_length ) ;
			if( succeed )  str_save( &(pptr->will_wit1), temp_buf,
				&next_pstring_ptr[block], pblock_end[block], &dummy ) ;
			if( succeed )  succeed = copy_csv_string( temp_buf, buf_ptr, limit_length ) ;
			if( succeed )  str_save( &(pptr->will_wit2), temp_buf,
				&next_pstring_ptr[block], pblock_end[block], &dummy ) ;
			break ;
		case 'exs' :
			succeed = copy_csv_string( temp_buf, buf_ptr, limit_length ) ;
			if( succeed )  str_save( &(pptr->will_exe1), temp_buf,
				&next_pstring_ptr[block], pblock_end[block], &dummy ) ;
			if( succeed )  succeed = copy_csv_string( temp_buf, buf_ptr, limit_length ) ;
			if( succeed )  str_save( &(pptr->will_exe2), temp_buf,
				&next_pstring_ptr[block], pblock_end[block], &dummy ) ;
			break ;
		case 'bes' :
			succeed = copy_csv_string( temp_buf, buf_ptr, limit_length ) ;
			if( succeed )  str_save( &(pptr->will_bens), temp_buf,
				&next_pstring_ptr[block], pblock_end[block], &dummy ) ;
			if( succeed )  succeed = copy_csv_string( temp_buf, buf_ptr, limit_length ) ;
			if( succeed )  str_save( &(pptr->will_bens2), temp_buf,
				&next_pstring_ptr[block], pblock_end[block], &dummy ) ;
			if( succeed )  succeed = copy_csv_string( temp_buf, buf_ptr, limit_length ) ;
			if( succeed )  str_save( &(pptr->will_bens3), temp_buf,
				&next_pstring_ptr[block], pblock_end[block], &dummy ) ;
			break ;
		default :
			break ;
	}
	
	return succeed ;
}


short  csv_string_length( int param_tag )
{
		short index = 0 ;
		
		while( param_tag != parameter_list[index] )  index++ ;

		return max_length[index] ;
}


BOOLEAN  copy_csv_string( char* dest_ptr, char** buf_ptr, short limit_length )
{
	char ch ;
	short char_count = 0 ;
	BOOLEAN quotes_mode = FALSE ;
	BOOLEAN done = FALSE ;
	BOOLEAN succeed = TRUE ;

	if( csv_quote != '\0' )
	{
		while( **buf_ptr == csv_quote && !done )
		{
			if( *(*buf_ptr+1) == csv_quote )
			{
				ch = *(*buf_ptr+2) ;
				if( ch == csv_separator || ch == '\0' || ch == '\n' )
				{
					*buf_ptr += 3 ;
					done = TRUE ;
				}
				else
				{
					char_count++ ;
					*dest_ptr++ = csv_quote ;
					*buf_ptr += 2 ;
				}
			}
			else
			{
				quotes_mode = TRUE ;
				(*buf_ptr)++ ;
			}
		}
	}
	while( succeed && !done )
	{
		ch = *(*buf_ptr)++ ;
		if( quotes_mode && ch == csv_quote )
		{
			ch = *(*buf_ptr)++ ;
			if( csv_quote_replacement == '\0' && ch == csv_quote )
			{
				char_count++ ;
				*dest_ptr++ = ch ;
			}
			else
			{
				if( ch == csv_separator || ch == '\0' || ch == '\n' )  done = TRUE ;
				else  succeed = FALSE ;
			}
		}
		else
		{
			if( ( !quotes_mode && ( ch == csv_separator || ch == '\n' ) ) || ch == '\0' )  done = TRUE ;
			else
			{
				if( ch == csv_new_line )  ch = '\r' ;
				
								/* discard every second quotes character	*/
				if( csv_quote != '\0' && ch == csv_quote && *(*buf_ptr) == csv_quote )  (*buf_ptr)++ ;
				
				char_count++ ;
				*dest_ptr++ = ch ;
			}
		}
		if( char_count > limit_length )  succeed = FALSE ;
	}
	if( succeed )  *dest_ptr++ = '\0' ;

	return succeed ;
}


BOOLEAN  load_csv_sex( Person* pptr, char** buf_ptr )
{
	BOOLEAN succeed = TRUE ;
	char ch ;
	char temp_buf[BUFFER_SIZE+1] ;
	
	succeed = copy_csv_string( temp_buf, buf_ptr, BUFFER_SIZE ) ;

	if( succeed )
	{
		ch = temp_buf[0] ;
		if( ch == male_char || ch == female_char || ch == '?' )  pptr->sex = ch ;
		else if( ch != '\0' )  succeed = FALSE ;
	}
	
	return succeed ;
}


BOOLEAN	 load_csv_date( Person* pptr, char** buf_ptr, int param_tag )
{
	BOOLEAN succeed = TRUE ;
	char ch ;
	short year = 0, month = 0, day = 0 ;
	int date ;
	short i ;
	char first, second ;
	
	if( !csv_date_as_text )
	{
		first = **buf_ptr ;
		second = *(*buf_ptr+1) ;
		if( first == csv_separator || first == '\0' || first == '\n' )
		{
			(*buf_ptr)++ ;
			return succeed ;
		}
		if( first == '0' && ( second == csv_separator || second == '\0' || second == '\n' ) )
		{
			*buf_ptr += 2 ;
			return succeed ;
		}
		
		for( i=0; i<4 && succeed; i++ )
		{
			ch = *(*buf_ptr)++ ;
			if( isdigit( ch ) )
			{
				year *= 10 ;
				year += ch - '0' ;
			}
			else  succeed = FALSE ;
		}
		for( i=0; i<2 && succeed; i++ )
		{
			ch = *(*buf_ptr)++ ;
			if( isdigit( ch ) )
			{
				month *= 10 ;
				month += ch - '0' ;
			}
			else  succeed = FALSE ;
		}
		for( i=0; i<2 && succeed; i++ )
		{
			ch = *(*buf_ptr)++ ;
			if( isdigit( ch ) )
			{
				day *= 10 ;
				day += ch - '0' ;
			}
			else  succeed = FALSE ;
		}
		if( succeed )
		{
			ch = *(*buf_ptr)++ ;
			if( ch && ch != csv_separator && ch != '\n' )  succeed = FALSE ;
		}
		if( month > 12 )  succeed = FALSE ;
	
		if( succeed )
		{
			date = (year << 9) + (month << 5) + day ;
		
			switch( param_tag )
			{
				case 'bid' :
					pptr->birth_date = date ;
					break ;
				case 'bad' :
					pptr->baptism_date = date ;
					break ;
				case 'ded' :
					pptr->death_date = date ;
					break ;
				case 'bcd' :
					pptr->burial_date = date ;
					break ;
				case 'dwd' :
					pptr->will_date = date ;
					break ;
				default :
					break ;
			}
		}
	}
	
	return succeed ;
}


BOOLEAN  load_csv_flags( Person* pptr, char** buf_ptr, int param_tag )
{
	BOOLEAN succeed = TRUE ;
	char temp_buf[BUFFER_SIZE+1] ;
	char last_ch = '\0' ;
	short flag = 0 ;
	short length ;
	
	succeed = copy_csv_string( temp_buf, buf_ptr, BUFFER_SIZE ) ;

	if( succeed )
	{
		if( length = strlen( temp_buf ), length > 0 )
		{
			last_ch = temp_buf[length - 1] ;

			if( last_ch == 'y' )  flag = 1 ;
			else if( last_ch == 'n' )  flag = 2 ;
			else  succeed = FALSE ;

			if( succeed )  pptr->flags |= flag << ( 2 * ( ( param_tag & 0xFF ) - '1' ) ) ;
		}
	}
	
	return succeed ;
}



void  write_csv_transfer_person( int pers, FILE* fp )
{
	Person *p_ptr ;
	short block ;
	short index = 0 ;
	long param_tag ;
	char* coupls_ptr ;
	int coup ;
	short dummy, number_of_children ;
	char names[FAM_NAME_LENGTH + FORENAME_LENGTH + 12] ;
	short flag ;
	char buffer[256] ;
	
	p_ptr = get_pdata_ptr( pers, &block ) ;

	while( param_tag = csv_list[index], param_tag != 0 )
	{
		if( index != 0 )  fputc( csv_separator, fp ) ;
		
		switch( param_tag )
		{
			case 'ref' :
				write_csv_reference( fp, p_ptr->reference ) ;
				break ;
			case 'fam' :
				check_fputs( p_ptr->family_name, fp ) ;
				break ;
			case 'for' :
				check_fputs( p_ptr->forenames, fp ) ;
				break ;
			case 'sex' :
				write_csv_char( fp, p_ptr->sex ) ;
				break ;
			case 'bid' :
				write_csv_date( p_ptr->birth_date, fp ) ;
				break ;
			case 'bip' :
				check_fputs( p_ptr->birth_place, fp ) ;
				break ;
			case 'bis' :
				check_fputs( p_ptr->birth_source, fp ) ;
				break ;
			case 'occ' :
				check_fputs( p_ptr->occupation, fp ) ;
				break ;
			case 'bad' :
				write_csv_date( p_ptr->baptism_date, fp ) ;
				break ;
			case 'bap' :
				check_fputs( p_ptr->baptism_place, fp ) ;
				break ;
			case 'bas' :
				check_fputs( p_ptr->baptism_source, fp ) ;
				break ;
			case 'ded' :
				write_csv_date( p_ptr->death_date, fp ) ;
				break ;
			case 'dep' :
				check_fputs( p_ptr->death_place, fp ) ;
				break ;
			case 'bcp' :
				check_fputs( p_ptr->burial_place, fp ) ;
				break ;
			case 'bcd' :
				write_csv_date( p_ptr->burial_date, fp ) ;
				break ;
			case 'dwd' :
				write_csv_date( p_ptr->will_date, fp ) ;
				break ;
			case 'des' :
				check_fputs( p_ptr->death_source, fp ) ;
				break ;
			case 'dws' :
				check_fputs( p_ptr->will_wit1, fp ) ;
				fputc( csv_separator, fp ) ;
				check_fputs( p_ptr->will_wit2, fp ) ;
				break ;
			case 'exs' :
				check_fputs( p_ptr->will_exe1, fp ) ;
				fputc( csv_separator, fp ) ;
				check_fputs( p_ptr->will_exe2, fp ) ;
				break ;
			case 'sol' :
				check_fputs( p_ptr->will_sol, fp ) ;
				break ;
			case 'bes' :
				check_fputs( p_ptr->will_bens, fp ) ;
				fputc( csv_separator, fp ) ;
				check_fputs( p_ptr->will_bens2, fp ) ;
				fputc( csv_separator, fp ) ;
				check_fputs( p_ptr->will_bens3, fp ) ;
				break ;
			case 'cou' :
				{
					char temp_buffer[MAX_COUPLINGS*(FULL_NAME_MAX+11+2)] ;	/* allows for 10digit reference	*/
					char* tb_ptr ;

					tb_ptr = temp_buffer ;
					
					if( coupls_ptr = p_ptr->couplings )
					{
						int spouse ;
						BOOLEAN first = TRUE ;
						Couple* cptr ;
						short cblk ;
						while( coup = form_ref( &coupls_ptr ) )
						{
							if( first )  first = FALSE ;
							else
							{
								*tb_ptr++ = ',' ;
								*tb_ptr++ = ' ' ;
							}
						
							cptr = get_cdata_ptr( coup, &cblk ) ;
							if( cptr->male_reference == pers )
								spouse = cptr->female_reference ;
							else  spouse = cptr->male_reference ;

							names_ref( spouse, names, 0, TRUE ) ;
						
							strcpy( tb_ptr, names ) ;
							tb_ptr += strlen( names ) ;
						}
					}
					*tb_ptr = '\0' ;
					check_fputs( temp_buffer, fp ) ;
				}
				break ;
			case 'not' :
				check_fputs( p_ptr->notes, fp ) ;
				break ;
			case 'nch' :
				count_couples_and_children( p_ptr, &dummy, &number_of_children ) ;
				sprintf( buffer, "%hd", number_of_children ) ;
				check_fputs( buffer, fp ) ;
				break ;
			case 'mot' :
				{
					int mother ;
					
					if( p_ptr->parents )
					{
						mother = couples[p_ptr->parents].female_reference ;
						names_ref( mother, names, 0, TRUE ) ;
						check_fputs( names, fp ) ;
					}
				}
				break ;
			case 'fat' :
				{
					int father ;
					
					if( p_ptr->parents )
					{
						father = couples[p_ptr->parents].male_reference ;
						names_ref( father, names, 0, TRUE ) ;
						check_fputs( names, fp ) ;
					}
				}
				break ;
			case 'fl1' :
			case 'fl2' :
			case 'fl3' :
			case 'fl4' :
			case 'fl5' :
			case 'fl6' :
			case 'fl7' :
			case 'fl8' :
				flag = ( p_ptr->flags >> ( 2 * ( (param_tag & 0xFF) - '1' ) ) ) & 0x3 ;
				if( flag )
				{
					sprintf( buffer, "%s %c", flags_addrs.fl[param_tag-'fl1'],
								(flag==1) ? 'y' : 'n' ) ;
					check_fputs( buffer, fp ) ;
				}
				else  check_fputs( "", fp ) ;
				break ;
			default :
				fprintf( fp, "no case for %d", param_tag ) ;
				break ;
		}
				index++ ;
	}
	fputc( '\n', fp ) ;
}


void  write_csv_reference( FILE* fp, int reference )
{
	if( csv_quote != '\0' )  fputc( csv_quote, fp ) ;
	fprintf( fp, "%d", reference ) ;
	if( csv_quote != '\0' )  fputc( csv_quote, fp ) ;
}


void  write_csv_char( FILE* fp, char character )
{
	if( csv_quote != '\0' )  fputc( csv_quote, fp ) ;
	fputc( character, fp ) ;
	if( csv_quote != '\0' )  fputc( csv_quote, fp ) ;
}


void  write_csv_date( int date, FILE* fp )
{
	short day, month, year ;
	char buffer[128] ;
	
	if( csv_date_as_text )
	{
		form_date( buffer+1, buffer, date, FALSE ) ;
		tidy_spaces( buffer ) ;
		check_fputs( buffer, fp ) ;
	}
	else
	{
		day = date & 0x1F ;
		month = ( date & 0x1E0 ) >> 5 ;
		year = ( date & 0x1FFE00 ) >> 9 ;

		if( month > 12 )	/* 13 = blank month, 14 = quarters	*/
		{
			month = 0 ;
			day = 0 ;
		}

		if( day == 0 )  day = csv_default_date % 100 ;
		if( month == 0 )  month = ( csv_default_date / 100 ) % 100 ;
		if( year == 0 )  year = csv_default_date / 10000 ;

		if( day || month || year )  fprintf( fp, "%04hd%02hd%02hd", year, month, day ) ;
		else  fputc( '0', fp ) ;
	}
}


void  check_fputs( char* str, FILE* fp )
{
	if( csv_quote != '\0' )  fputc( csv_quote, fp ) ;

	if( str != NULL )
	{
		char buffer[BUFFER_SIZE+1] ;
		char second_buffer[2*BUFFER_SIZE+1] ;
		Str_prt_params print_params ;		/* Only used to set not gdos and left wrap for get_next_slice	*/
		short slice_length ;
		BOOLEAN first_slice = TRUE ;
		char* str_ptr ;
		
		if( csv_max_line_length > 0 && csv_max_line_length < BUFFER_SIZE )
			slice_length = csv_max_line_length ;
		else  slice_length = BUFFER_SIZE ;
		
		print_params.use_gdos = FALSE ;
		print_params.align = LEFT_WRAP ;
		
		str_ptr = str ;
		
		while( get_next_slice( buffer, &str_ptr, &print_params, slice_length ) )
		{
			char* buf_ptr ;
			char* second_buf_ptr ;
			
			if( !first_slice )  fputc( csv_new_line, fp ) ;
			first_slice = FALSE ;
			
			buf_ptr = buffer ;
			second_buf_ptr = second_buffer ;
			while( *buf_ptr != '\0' )
			{
													/* typically " becomes ' or ""		*/
				if( *buf_ptr == csv_quote )
				{
					if( csv_quote_replacement != '\0' )  *buf_ptr = csv_quote_replacement ;
					else  *second_buf_ptr++ = csv_quote ;
				}
				*second_buf_ptr++ = *buf_ptr++ ;
			}
			
			*second_buf_ptr = '\0' ;
			fputs( second_buffer, fp ) ;
		}
	}

	if( csv_quote != '\0' )  fputc( csv_quote, fp ) ;
}