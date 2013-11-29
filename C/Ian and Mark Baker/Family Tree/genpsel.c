/************************************************************************/
/*																		*/
/*		Genpsel.c	 5 Dec 99											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"
#endif

#include "genhd.h"
#include "genpsel.h"
#include "genutil.h"
#include "gencoup.h"
#include "gendata.h"
#include "genpers.h"
#include "genpref.h"

extern Index_person *people ;
extern Index_couple *couples ;
extern int *matches ;
extern int p_index_size ;
extern int edit_pers_ref ;
extern int next_person, next_couple ;
extern short pblock_changed[MAX_PEOPLE_BLOCKS] ;
extern char *pblock_end[MAX_PEOPLE_BLOCKS] ;
extern char *next_pstring_ptr[MAX_PEOPLE_BLOCKS] ;

extern OBJECT *flags_ptr ;
extern OBJECT *extra_info_ptr ;				/* extra info form pointer	*/

extern Preferences prefs ;

const char* const person_selector_help = "Person Selector" ;
OBJECT* psel_ptr ;

int psel = -1 ;						/* rsc index of selection			*/
int oset ;							/* shortlist scrolling offset		*/
int entries ;						/* number of matching people found.	*/

struct
{
	char *ref ;
	char *fam ;
	char *fore ;
	char *after ;
	char *before ;
	char *pob ;							/* place of birth				*/
	char *selects[10] ;
} psel_form_addrs ;

OBJECT *psel_ptr ;						/* selection form pointer		*/

void *raddr_ptr ;

int  get_person_reference( char *f_nam, short list )
{
	int ref = 0 ;
	short person_chosen = 0 ;
	short done = FALSE ;
	short button ;
	short dbl ;							/* button double clicked		*/
	short m_x, m_y ;
	short dummy ;
	short obj_x, obj_y ;
	Person* pptr ;		/* person pointer used when adding new person	*/
	short block ;		/* block containing new person					*/
	short i ;

	assert( PSEL1 == PSEL0 + 1 ) ;
	assert( PSEL2 == PSEL0 + 2 ) ;
	assert( PSEL3 == PSEL0 + 3 ) ;
	assert( PSEL4 == PSEL0 + 4 ) ;
	assert( PSEL5 == PSEL0 + 5 ) ;
	assert( PSEL6 == PSEL0 + 6 ) ;
	assert( PSEL7 == PSEL0 + 7 ) ;
	assert( PSEL8 == PSEL0 + 8 ) ;
	assert( PSEL9 == PSEL0 + 9 ) ;
	assert( FL_NOT3 - FL_NOT2 == FL_NOT2 - FL_NOT1 ) ;
	assert( FL_NOT4 - FL_NOT3 == FL_NOT2 - FL_NOT1 ) ;
	assert( FL_NOT5 - FL_NOT4 == FL_NOT2 - FL_NOT1 ) ;
	assert( FL_NOT6 - FL_NOT5 == FL_NOT2 - FL_NOT1 ) ;
	assert( FL_NOT7 - FL_NOT6 == FL_NOT2 - FL_NOT1 ) ;
	assert( FL_NOT8 - FL_NOT7 == FL_NOT2 - FL_NOT1 ) ;

	entries = 0 ;

	clear_psel_form( f_nam ) ;
	
	psel_ptr[PS_OK].ob_flags &= ~DEFAULT ;
	psel_ptr[PS_LIST].ob_flags |= DEFAULT ;

	psel_ptr[DETAILS].ob_state |= DISABLED ;

	for( i = 0 ; i < 8 ; i++ )  set_to_ignore( FL_NOT1 + i * ( FL_NOT2 - FL_NOT1 ) ) ;

	clear_form_flags() ;
	flags_ptr[FL_NOT1].ob_state |= SELECTED ;
	flags_ptr[FL_NOT2].ob_state |= SELECTED ;
	flags_ptr[FL_NOT3].ob_state |= SELECTED ;
	flags_ptr[FL_NOT4].ob_state |= SELECTED ;
	flags_ptr[FL_NOT5].ob_state |= SELECTED ;
	flags_ptr[FL_NOT6].ob_state |= SELECTED ;
	flags_ptr[FL_NOT7].ob_state |= SELECTED ;
	flags_ptr[FL_NOT8].ob_state |= SELECTED ;

	if( f_nam || prefs.autolist )
	{
		app_modal_box()->g_w = 0 ;		 /* set zero box size to prevent drawing	*/
		update_listed_people( *app_modal_box() ) ;
	}

	app_modal_init( psel_ptr, person_selector_help, TITLED ) ;

	if( psel_form_addrs.fam[0] == '\0' )
		app_modal_edit_obj( S_FAMILY_NAME ) ;
	else  app_modal_edit_obj( S_FORENAME ) ;

	while( !done )
	{
		button = app_modal_do() ;

		dbl = button & DOUBLE_CLICK ;
		button &= ~DOUBLE_CLICK ;

		if( *(psel_form_addrs.ref) )
		{
			ref = atoi( psel_form_addrs.ref ) ;
			if( ref < 0 || ref > next_person )  ref = 0 ;
		}
		else  ref = 0 ;

		switch( button )
		{
			case PSFLAGS :
				psel_ptr[PSFLAGS].ob_state &= ~SELECTED ;
				{
					short saved_flags ;
					
					saved_flags = form_flags() ;
					if( do_sub_form( flags_ptr, "Filter Flags", FL_HELP, TITLED ) == FL_OK )
						update_listed_people( *app_modal_box() ) ;
					else  set_form_flags( saved_flags ) ;
				}
				break ;
			case DETAILS :				/* Only selectable if person chosen	*/
				psel_ptr[DETAILS].ob_state &= ~SELECTED ;
										/* If extra info form OK'd then		*/
										/* assume choice done and exit.		*/
				update_extra_info( ref ) ;
				if( PEI_OK == do_sub_form( extra_info_ptr, "Details", PEI_HELP, TITLED ) )  done = TRUE ;
				break ;
			case PS_LIST :
				update_listed_people( *app_modal_box() ) ;
				psel_ptr[PS_LIST].ob_state &= ~SELECTED ;
				objc_draw( psel_ptr, PS_LIST, 0, PTRS( app_modal_box() ) ) ;
				break ;
			case PS_NEW_PERSON :
				psel_ptr[PS_NEW_PERSON].ob_state &= ~SELECTED ;
				if( edit_pers_ref >= next_person )  next_person++ ;
				if( next_person >= p_index_size )	/* do not add if index full		*/
					rsrc_form_alert( 1, P_INDEX_FULL ) ;
				else if( psel_form_addrs.fam[0] == '\0' && psel_form_addrs.fore[0] == '\0' )
					rsrc_form_alert( 1, NO_NAMES ) ;
				else
				{
					ref = next_person ;
					done = TRUE ;
					pptr = get_pdata_ptr( next_person, &block ) ;
					save_int( &pptr->reference, next_person, &pblock_changed[block] ) ;
					str_save( &(pptr->family_name), psel_form_addrs.fam,
						&next_pstring_ptr[block], pblock_end[block], &pblock_changed[block] ) ;
					str_save( &(pptr->forenames), psel_form_addrs.fore,
						&next_pstring_ptr[block], pblock_end[block], &pblock_changed[block] ) ;
					add_to_pidx( next_person, pptr ) ;
					next_person++ ;
				}
				if( !done )  objc_draw( psel_ptr, PS_NEW_PERSON, 0, PTRS( app_modal_box() ) ) ;
				break ;
			case PS_CANCEL :
			case APP_MODAL_TERM :
				psel_ptr[PS_CANCEL].ob_state &= ~SELECTED ;
				ref = 0 ;
				done = TRUE ;
				break ;
							/* If a person has been selected, return	*/
							/* that person. If not, and only one person	*/
							/* matches the names etc., return that		*/
							/* person. Otherwise, do not exit loop.		*/
			case PS_OK :
				psel_ptr[PS_OK].ob_state &= ~SELECTED ;

				if( ref )  person_chosen = ref ;
				else
				{
					update_listed_people( *app_modal_box() ) ;
					if( entries == 1 )  ref = matches[0] ;
					else if( entries > 1 && list )  ref = -1 ;
				}

				if( ref )  done = TRUE ;
				else
				{
					rsrc_form_alert( 1, NO_SELECTION ) ;
					objc_draw( psel_ptr, PS_OK, 0, PTRS( app_modal_box() ) ) ;
				}
				break ;
			case PS_HELP :
				psel_ptr[PS_HELP].ob_state &= ~SELECTED ;
				objc_draw( psel_ptr, PS_HELP, 0, PTRS( app_modal_box() ) ) ;
				help( person_selector_help ) ;
				break ;
			case PS_SLIDER :
				if( entries > 10 )
				{
					oset = move_slide( psel_ptr,
										PS_SLIDER, PS_SLIDE_RANGE, app_modal_box() ) ;
					oset = ( entries - 10 ) * oset / 1000 ;

					display_short_list( *app_modal_box() ) ;
				}
				break ;
			case PS_UP :
				if( entries > 10 && oset > 0 )
				{
					oset-- ;
					set_slide( oset, entries-10, psel_ptr,
										PS_SLIDER, PS_SLIDE_RANGE, app_modal_box() ) ;
					display_short_list( *app_modal_box() ) ;
				}
				break ;
			case PS_DOWN :
				if( entries > 10 && oset < entries - 10 )
				{
					oset++ ;
					set_slide( oset, entries-10, psel_ptr,
										PS_SLIDER, PS_SLIDE_RANGE, app_modal_box() ) ;
					display_short_list( *app_modal_box() ) ;
				}
				break ;
			case PS_SLIDE_RANGE :
				if( entries > 10 )
				{
					graf_mkstate( &m_x, &m_y, &dummy, &dummy ) ;
					objc_offset( psel_ptr, PS_SLIDER, &obj_x, &obj_y ) ;
					if( m_y > obj_y )
					{
						oset += 9 ;
						if( oset > entries - 10 )  oset = entries - 10 ;
					}
					else
					{
						oset -= 9 ;
						if( oset < 0 )  oset = 0 ;
					}
					set_slide( oset, entries-10, psel_ptr,
									PS_SLIDER, PS_SLIDE_RANGE, app_modal_box() ) ;
					display_short_list( *app_modal_box() ) ;
				}
				break ;
			case PSEL0 :
			case PSEL1 :
			case PSEL2 :
			case PSEL3 :
			case PSEL4 :
			case PSEL5 :
			case PSEL6 :
			case PSEL7 :
			case PSEL8 :
			case PSEL9 :
				pselect( button - PSEL0, &ref, *app_modal_box() ) ;
				psel = button ;
				if( dbl && ref )  person_chosen = ref ;
				break ;
			default :
				break ;
		}
		if( person_chosen )
		{
			entries = 1 ;
			matches[0] = ref ;
			matches[1] = 0 ;		/* terminator				*/
			done = TRUE ;
		}
		else if( ref > 0 && ref < next_person && psel_ptr[PS_LIST].ob_flags & DEFAULT )
		{
			psel_ptr[PS_LIST].ob_flags &= ~DEFAULT ;
			objc_draw( psel_ptr, PS_LIST_IBOX, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				/* note use of IBOX around button because new size smaller than	*/
				/* old size, and hence outer edge of button would not be removed*/
			psel_ptr[PS_OK].ob_flags |= DEFAULT ;
			objc_draw( psel_ptr, PS_OK, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
		}
	}

	psel_ptr[psel].ob_state &= ~SELECTED ;

	app_modal_end() ;

	if( ref == -1 )			/* no selection but list acceptable			*/
		ref = matches[0] ;

	set_all_notset() ;

	return ref ;
}


void  set_to_ignore( short field )
{
	strcpy( (char *) flags_ptr[field].ob_spec,
								(char *) flags_ptr[IGNORE].ob_spec ) ;
	flags_ptr[field].ob_flags |= SELECTABLE ;
}


void  set_psel_form_addrs( void )
							/* This routine fetches all the resource	*/
							/* tree addresses for the variable strings	*/
							/* on the select person form and stores them	*/
							/* in a single array.						*/
{
							/* get select person form addresses	*/
	psel_form_addrs.ref = FORM_TEXT( psel_ptr, PS_REFERENCE ) ;
	psel_form_addrs.fam = FORM_TEXT( psel_ptr, S_FAMILY_NAME ) ;
	*(psel_form_addrs.fam) = '\0' ;		/* Initially clear family name.	*/
	psel_form_addrs.fore = FORM_TEXT( psel_ptr, S_FORENAME ) ;
	psel_form_addrs.after = FORM_TEXT( psel_ptr, AFTER ) ;
	psel_form_addrs.before = FORM_TEXT( psel_ptr, BEFORE ) ;
	psel_form_addrs.pob = FORM_TEXT( psel_ptr, POB ) ;
	psel_form_addrs.selects[0] = FORM_TEXT( psel_ptr, PSEL0 ) ;
	psel_form_addrs.selects[1] = FORM_TEXT( psel_ptr, PSEL1 ) ;
	psel_form_addrs.selects[2] = FORM_TEXT( psel_ptr, PSEL2 ) ;
	psel_form_addrs.selects[3] = FORM_TEXT( psel_ptr, PSEL3 ) ;
	psel_form_addrs.selects[4] = FORM_TEXT( psel_ptr, PSEL4 ) ;
	psel_form_addrs.selects[5] = FORM_TEXT( psel_ptr, PSEL5 ) ;
	psel_form_addrs.selects[6] = FORM_TEXT( psel_ptr, PSEL6 ) ;
	psel_form_addrs.selects[7] = FORM_TEXT( psel_ptr, PSEL7 ) ;
	psel_form_addrs.selects[8] = FORM_TEXT( psel_ptr, PSEL8 ) ;
	psel_form_addrs.selects[9] = FORM_TEXT( psel_ptr, PSEL9 ) ;
}


void  clear_psel_form( char *f_nam )
{
	short i ;							/* loop counter					*/
	*(psel_form_addrs.ref) = '\0' ;
	if( f_nam )  strcpy( psel_form_addrs.fam, f_nam ) ;
	else
		if( !prefs.reuse_fname )  *(psel_form_addrs.fam) = '\0' ;
	*(psel_form_addrs.fore) = '\0' ;
	*(psel_form_addrs.after) = '\0' ;
	*(psel_form_addrs.before) = '\0' ;
	*(psel_form_addrs.pob) = '\0' ;
	for( i=0; i<10; i++ )  *(psel_form_addrs.selects[i]) = '\0' ;
}


void  update_listed_people( GRECT box )
{
	int ref ;
	int entry ;					/* matching person found.				*/
	int *mp_ptr ;				/* pointer to matched people array		*/
	Filter filter ;

	busy( BUSY_MORE ) ;

	update_filter( &filter, psel_form_addrs.fam, psel_form_addrs.fore,
							psel_form_addrs.before, psel_form_addrs.after,
							psel_form_addrs.pob ) ;

	mp_ptr = matches ;
	entries = 0 ;

	for( ref=1; ref<next_person ; ref++ )
	{
		if( test_match( &filter, ref ) )
		{
			*mp_ptr++ = ref ;
			entries++ ;
		}
	}

	if( !entries )  rsrc_form_alert( 1, NO_MATCHES ) ;

	if( entries > 1 )  qsort( matches, (size_t) entries, (size_t) 4,
														pidx_compare ) ;

	for( entry = entries; entry < prefs.max_people; entry++ )  matches[entry] = 0 ;

	oset = 0 ;

	if( entries > 10 )
	{
		if( entries < 100 )
			psel_ptr[PS_SLIDER].ob_height
					= psel_ptr[PS_SLIDE_RANGE].ob_height * 10 / entries ;
		else
			psel_ptr[PS_SLIDER].ob_height
					= psel_ptr[PS_SLIDE_RANGE].ob_height / 10 ;
		set_slide( 0, entries-10, psel_ptr,
										PS_SLIDER, PS_SLIDE_RANGE, &box ) ;
	}
	else
	{
		psel_ptr[PS_SLIDER].ob_height = psel_ptr[PS_SLIDE_RANGE].ob_height ;
		set_slide( 0, 1, psel_ptr, PS_SLIDER, PS_SLIDE_RANGE, &box ) ;
	}

	display_short_list( box ) ;

	busy( BUSY_LESS ) ;
}


void  update_filter( Filter *filter, char *fam_name, char *forename,
							char *before_date_str, char *after_date_str,
							char *birth_place )
{
	char *str_ptr ;
	char ch ;
	short dummy ;
	char dummy_blank = ' ' ;
	short i, strnum ;

	save_date( &(filter->after_date), after_date_str, &dummy_blank, &dummy ) ;
	save_date( &(filter->before_date), before_date_str, &dummy_blank, &dummy ) ;

	str_ptr = fam_name ;
	i = 0 ;
	while( ch = *str_ptr++ )
	{
		if( ch == '*' )  filter->family_name[i++] = '?' ;
							/* '*' padded to '?*' for stcpma function	*/
		filter->family_name[i++] = tolower( ch ) ;
	}
	filter->family_name[i++] = '\0' ;

					/* Load up to 4 forenames into strings				*/
	for( strnum=0; strnum<4; strnum++ )  filter->non_alpha_forename[strnum] = FALSE ;
	strnum = 0 ;
	str_ptr = forename ;
	i = 0 ;
	while( strnum < 4 && ( ch = *str_ptr++ ) )
	{
		if( ch != ' ' )
		{
			if( ch == '*' )  filter->forename[strnum][i++] = '?' ;
							/* '*' padded to '?*' for stcpma function	*/
			filter->forename[strnum][i++] = tolower( ch ) ;
			if( !isalpha( ch ) && !isalpha_accented( ch )
								&& ch != '-' && ch != '\'' && ch != '.' )
				filter->non_alpha_forename[strnum] = TRUE ;
		}
		else
		{
			filter->forename[strnum++][i] = '\0' ;
			i = 0 ;
		}
	}
	if( !ch && i )  filter->forename[strnum++][i] = '\0' ;
	filter->forenames_to_match = strnum ;

	filter->sel_flags = form_flags() ;

					/* Load up to 4 places into strings				*/
	strnum = 0 ;
	str_ptr = birth_place ;
	i = 0 ;
	while( strnum < 4 && ( ch = *str_ptr++ ) )
	{
		if( ch != ' ' )
		{
			if( ch == '*' )  filter->birth_place[strnum][i++] = '?' ;
							/* '*' padded to '?*' for stcpma function	*/
			filter->birth_place[strnum][i++] = tolower( ch ) ;
		}
		else
		{
			filter->birth_place[strnum++][i] = '\0' ;
			i = 0 ;
		}
	}
	if( !ch && i )  filter->birth_place[strnum++][i] = '\0' ;
	filter->places_to_match = strnum ;
}


short  test_match( Filter *filter, int reference )

{	Person *p_ptr ;
	short match = TRUE ;
	char family_name[IDX_NAM_MAX+1], forename[IDX_NAM_MAX+1] ;
	short strnum ;
	char *str_ptr, *name_ptr ;
	char ch ;
	short name_ended ;
	char birth_place[40] ;			/* to hold lower case birth place	*/
	short i, dummy ;
	char *junk ;

	if( people[reference].birth_date == DELETED_DATE )  match = FALSE ;
	else if( ( filter->sel_flags & people[reference].flags )
													!= filter->sel_flags )
		match = FALSE ;
	else
	{
		if( filter->family_name[0] )
		{
			if( strlen( people[reference].family_name ) == 0 )
				match = FALSE ;
			else
			{
				i = 0 ;
				while( family_name[i] = tolower( people[reference].family_name[i] ) )
					i++ ;
				if( strlen( family_name )
						!= stcpma( family_name, filter->family_name ) )
				match = FALSE ;
			}
		}
	}

	strnum = 0 ;
	str_ptr = people[reference].forename ;
	while( match && strnum < filter->forenames_to_match )
	{
		name_ended = FALSE ;
		name_ptr = forename ;
		while( !name_ended )
		{
			ch = *str_ptr++ ;
			if( ch && ch != ' ' )
			{
				if( isalpha(ch) || isalpha_accented( ch )
								|| ch == '-' || ch == '\'' || ch == '.'
								|| filter->non_alpha_forename[strnum] )
				*name_ptr++ = tolower( ch ) ;
			}
			else
			{
				*name_ptr = '\0' ;
				name_ended = TRUE ;
			}
		}

		if( strlen( forename ) == 0 )  match = FALSE ;
		else if( strlen( forename )
						!= stcpma( forename, filter->forename[strnum] ) )
			match = FALSE ;

		strnum++ ;
		if( !ch )  str_ptr-- ;	/* This ensures that if the forename	*/
								/* string is used up the next name will	*/
								/* be empty, it will not go beyond the	*/
								/* end of the string.					*/
	}

	if( match )
	{
		if( ( filter->after_date || filter->before_date )
											&& !people[reference].birth_date )
			match = FALSE ;
		else if( filter->before_date
				&& ( compare_dates( filter->before_date, people[reference].birth_date ) < 0 ) )
			match = FALSE ;
		else if( filter->after_date
				&& ( compare_dates( filter->after_date, people[reference].birth_date ) > 0 ) )
			match = FALSE ;
	}

	if( match )
	{
		strnum = 0 ;
		if( filter->places_to_match )
		{
			p_ptr = get_pdata_ptr( reference, &dummy ) ;
			if( p_ptr->birth_place )
			{
				i = 0 ;
				while( birth_place[i] = tolower( p_ptr->birth_place[i] ) )
					i++ ;
			}
			else  match = FALSE ;

			while( match && strnum < filter->places_to_match )
			{
				if( !stcpm( birth_place, filter->birth_place[strnum++],
																&junk ) )
					match = FALSE ;
			}
		}
	}

	return match ;
}


short  compare_dates( int date1, int date2 )
{
	short circ1, day1, mon1, year1 ;
	short circ2, day2, mon2, year2 ;
	short difference ;

	day1 = date1 & 0x1F ;
	mon1 = ( date1 & 0x1E0 ) >> 5 ;
	year1 = ( date1 & 0x1FFE00 ) >> 9 ;
	if( date1 & 0x200000 )  circ1 = TRUE ;
	else  circ1 = FALSE ;

	day2 = date2 & 0x1F ;
	mon2 = ( date2 & 0x1E0 ) >> 5 ;
	year2 = ( date2 & 0x1FFE00 ) >> 9 ;
	if( date2 & 0x200000 )  circ2 = TRUE ;
	else  circ2 = FALSE ;

	if( year1 != year2 )
		difference = year1 - year2 ;

	else if( mon1 && mon2 && ( mon1 != mon2 ) )
	{
							/* If month is specified as a quarter,	*/
								/* which quarter is given by day.		*/
								/* The days are multiplied by 6 making	*/
								/* the quarters come out as 0,6,12,18.	*/
								/* The months are doubled, minus 1, ie	*/
								/* 1,3,5, 7,9,11, 13,15,17, 19,21,23.	*/
		if( mon1 == 14 )				/* i.e. month1 == Qtr		*/
		{
			mon1 = 6 * ( day1 - 1 ) ;	/* set Qtr from day value	*/
				mon2 = 2 * mon2 - 1 ;		/* set month as quarter		*/
		}
		if( mon2 == 14 )				/* i.e. month2 == Qtr		*/
		{
			mon2 = 6 * ( day2 - 1 ) ;	/* set Qtr from day value	*/
			mon1 = 2 * mon1 - 1 ;		/* set month as quarter		*/
		}
		difference = mon1 - mon2 ;
	}

										/* next line sometimes got mis-read by LC	*/
	else if( circ1 != circ2 )  difference = circ1 ? 1 : -1 ;

	else  difference = day1 - day2 ;

	return difference ;
}


void  display_short_list( GRECT box )
{
	int entry, ref ;
	char names[2*IDX_NAM_MAX+2+DATE_LENGTH] ;

	if( psel != -1 )
	{
		psel_ptr[psel].ob_state &= ~SELECTED ;
		psel = -1 ;
	}

	for( entry=0; entry<entries-oset && entry < 10; entry++ )
	{
		ref = matches[entry+oset] ;
		names_date( ref, names, 40, FALSE ) ;
									/* format names & date into string	*/
		str_load( psel_form_addrs.selects[entry], names ) ;
		psel_ptr[PSEL0 + entry].ob_flags |= SELECTABLE ;
	}
	while( entry < 10 )
	{
		psel_ptr[PSEL0 + entry].ob_flags &= ~SELECTABLE ;
		*(psel_form_addrs.selects[entry++]) = '\0' ;
	}
								/* update screen unless box width == 0	*/
	if( box.g_w )  objc_draw( psel_ptr, P_LIST, MAX_DEPTH, ELTS( box ) ) ;
}


int  pidx_compare( void *ref1_ptr, void *ref2_ptr )
{
	int greater ;			/* ref1 > ref2 flag		*/

	greater = strcmpi( people[*(int *)ref1_ptr].family_name,
								people[*(int *)ref2_ptr].family_name ) ;
	if( !greater )
		greater = strcmpi( people[*(int *)ref1_ptr].forename,
									people[*(int *)ref2_ptr].forename ) ;
	if( !greater )
		greater = (int) compare_dates( people[*(int *)ref1_ptr].birth_date,
									people[*(int *)ref2_ptr].birth_date ) ;
	return greater ;
}


void  pselect( int entry, int *ref_ptr, GRECT box )
{
	if( PS_REFERENCE == app_modal_edit_obj( -1 ) )
		app_modal_edit_obj( 0 ) ;

	*ref_ptr = matches[entry+oset] ;
	sprintf( psel_form_addrs.ref, "%10d", *ref_ptr ) ;
	objc_draw( psel_ptr, PS_REFERENCE, 0, ELTS( box ) ) ;
	psel_ptr[DETAILS].ob_state &= ~DISABLED ;
	objc_draw( psel_ptr, DETAILS, 0, ELTS( box ) ) ;
}


void  update_extra_info( int ref )
{
	Person *pptr ;
	int coup, mother, father ;
	int date ;
	char names[41] ;	/* temporary holding string			*/
	short block ;

	pptr = get_pdata_ptr( ref, &block ) ;

	str_load( (char *)extra_info_ptr[PEI_FAMILY_NAME].ob_spec, pptr->family_name ) ;
	str_load( (char *)extra_info_ptr[PEI_FORENAMES].ob_spec, pptr->forenames ) ;

	str_load( (char *)extra_info_ptr[PEI_BIRTHPLACE].ob_spec, pptr->birth_place ) ;
	str_load( (char *)extra_info_ptr[PEI_OCCUPATION].ob_spec, pptr->occupation ) ;

	if( date = pptr->birth_date )
		form_date( FORM_TEXT( extra_info_ptr, PEI_BIRTH_DATE ), (char *)&(extra_info_ptr[PEI_BID_QUAL].ob_spec), date, TRUE ) ;
	else
	{
		blank_field( extra_info_ptr, PEI_BIRTH_DATE, TOTAL ) ;
		*( (char *) &(extra_info_ptr[PEI_BID_QUAL].ob_spec) ) = ' ' ;
	}

	if( date = pptr->baptism_date )
		form_date( FORM_TEXT( extra_info_ptr, PEI_BDATE ), (char *)&(extra_info_ptr[PEI_BAD_QUAL].ob_spec), date, TRUE ) ;
	else
	{
		blank_field( extra_info_ptr, PEI_BDATE, TOTAL ) ;
		*( (char *) &(extra_info_ptr[PEI_BAD_QUAL].ob_spec) ) = ' ' ;
	}

	if( date = pptr->death_date )
		form_date( FORM_TEXT( extra_info_ptr, PEI_DEATH_DATE ), (char *)&(extra_info_ptr[PEI_DED_QUAL].ob_spec), date, TRUE ) ;
	else
	{
		blank_field( extra_info_ptr, PEI_DEATH_DATE, TOTAL ) ;
		*( (char *) &(extra_info_ptr[PEI_DED_QUAL].ob_spec) ) = ' ' ;
	}

	if( coup = pptr->parents )
	{
		mother = couples[coup].female_reference ;
		names_only( mother, names, 40, FALSE ) ;
											/* format names into string	*/
		strcpy( (char *)extra_info_ptr[PEI_MOTHER].ob_spec, names ) ;
		father = couples[coup].male_reference ;
		names_only( father, names, 40, FALSE ) ;
											/* format names into string	*/
		strcpy( (char *)extra_info_ptr[PEI_FATHER].ob_spec, names ) ;
	}
	else
	{
		*(char *)extra_info_ptr[PEI_MOTHER].ob_spec = '\0' ;
		*(char *)extra_info_ptr[PEI_FATHER].ob_spec = '\0' ;
	}
}

