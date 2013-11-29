/************************************************************************/
/*																		*/
/*		Genpers1.c	28 Dec 97											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "genpers.h"
#include "genutil.h"
#include "gencoup.h"
#include "gendata.h"
#include "genmain.h"
#include "gennote.h"
#include "genpsel.h"

extern int ap_id ;					/* global application identifier	*/
extern char **keytable ;			/* ascii lookup from scancodes		*/

extern Index_person far *people ;
extern Index_couple far *couples ;
extern short pblock_changed[MAX_PEOPLE_BLOCKS] ;
extern short cblock_changed[MAX_COUPLES_BLOCKS] ;
extern char *next_pstring_ptr[MAX_PEOPLE_BLOCKS] ;
extern char *next_cstring_ptr[MAX_COUPLES_BLOCKS] ;
extern char *pblock_end[MAX_PEOPLE_BLOCKS] ;
extern int p_index_size ;
extern int next_person, next_couple ;

extern char overflow[OVERFLOW_SIZE] ;
extern short overflowed ;

extern OBJECT *strings_ptr ;	/* pointer to resource strings			*/
extern short notes_open ;
extern short notes_loaded ;
extern short notes_changed ;

extern Wind_edit_params notes_form ;
extern Wind_edit_params coup_form ;
extern Wind_edit_params dialogue_form ;
extern int wind_form_kind ;

extern OBJECT *menu_ptr ;				/* pointer to menu bar tree				*/
extern OBJECT *flags_ptr ;

extern char months[15][4] ;		/* loaded with month strings			*/
extern int *job_ptr ;

int edit_pers_ref = 0 ;
short edit_pers_block = -1 ;
Person *edit_pers_pptr ;

int mother, father, spouse ;
int couplings[MAX_COUPLINGS] ;
int pprog_array[MAX_CHILDREN] ;
int sib_array[MAX_CHILDREN] ;
short number_spouses, spouse_oset ;
short number_children, number_siblings ;
short child_oset, sib_oset ;	/* offset through children and siblings	*/
								/* for display							*/
short latest_flags ;
char male_char, female_char ;

struct
{
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

Wind_edit_params pers_form ;

Wind_edit_params birth_form, baptism_form, death_form ;


short curs_enbl = FALSE ;


void  edit_person( int reference )
{
	short next_flag = FALSE ;		/* This is a "next" person, use		*/
									/* previous family name.			*/
	if( reference > next_person )
	{
		reference = next_person ;
		next_flag = TRUE ;
	}

	if( !reference )  reference = get_person_reference( NULL, FALSE ) ;
	if( !reference )  return ;		/* exit if nobody selected			*/
	if( reference >= p_index_size )	/* exit if index full				*/
	{
		rsrc_form_alert( 1, P_INDEX_FULL ) ;
		return ;
	}

			/* If this is a different person, and last person has not	*/
			/* been cleared to indicate cancellation or deletion then	*/
			/* save last person.										*/
	if( edit_pers_ref && edit_pers_ref != reference )
		save_current_edits() ;

	if( reference != edit_pers_ref )
	{
		edit_pers_ref = reference ;
		edit_pers_pptr = load_person( edit_pers_ref, &edit_pers_block ) ;
		notes_changed = FALSE ;
		latest_flags = edit_pers_pptr->flags ;
	}

	if( next_flag )
		str_load( form_addrs.fam, people[edit_pers_ref-1].family_name ) ;

	if( edit_pers_ref >= next_person - 1 )
	{
		pers_form.fm_ptr[P_NEXT].ob_flags &= ~HIDETREE ;
	}
	else  pers_form.fm_ptr[P_NEXT].ob_flags |= HIDETREE ;

	form_wind_title( edit_pers_ref, 0, &pers_form, EDIT_TITLE, EDIT_ITITLE ) ;
	pers_form.icon_object = PERS_ICON ;

	wind_form_do( &pers_form, FAMILY_NAME ) ;

	if( pers_form.fm_handle > 0 )
	{
		menu_ienable( menu_ptr, PRINT_FAMILY, 1 ) ;
		if( notes_form.fm_handle > 0 )
		{
			load_notes( edit_pers_pptr ) ;
			set_notes_sizes( &notes_form.fm_box ) ;
			set_wind_title( edit_pers_ref, 0, &notes_form, NOTES_TITLE, NOTES_ITITLE ) ;
			send_redraw_message( &notes_form.fm_box, notes_form.fm_handle ) ;
		}
		if( birth_form.fm_handle > 0 )
			send_redraw_message( &birth_form.fm_box, birth_form.fm_handle ) ;
		if( baptism_form.fm_handle > 0 )
			send_redraw_message( &baptism_form.fm_box, baptism_form.fm_handle ) ;
		if( death_form.fm_handle > 0 )
			send_redraw_message( &death_form.fm_box, death_form.fm_handle ) ;
		wind_set( pers_form.fm_handle, WF_TOP ) ;
		send_redraw_message( &pers_form.fm_box, pers_form.fm_handle ) ;

		if( notes_form.fm_box.g_w == 0 )  notes_form.fm_box = pers_form.fm_box ;
	}
}


void  form_wind_title( int pers_ref, int spouse_ref,
				Wind_edit_params *p, short rsrc_title, short rsrc_ititle )
{
	char name_str[2*IDX_NAM_MAX + 4] ;
	int i, j ;

	names_only( pers_ref, name_str, 0, FALSE ) ;
	sprintf( p->title_str, " %s %s ",
					(char *)strings_ptr[rsrc_title].ob_spec, name_str ) ;

	for( i=0; name_str[i] != '\0' && name_str[i] != ' ' ; i++ ) ;
	if( name_str[i] == ' ' )
	{
		for( j=strlen(name_str)-1; name_str[j] != ' ' && j>=0 ; j-- ) ;
		strcpy( p->icon_label2, name_str + j + 1 ) ;
		strupr( p->icon_label2 ) ;
	}
	name_str[i] = '\0' ;
	strcpy( p->icon_label1, name_str ) ;
	strupr( p->icon_label1 ) ;

	strcpy( p->icon_title, (char *)strings_ptr[rsrc_ititle].ob_spec ) ;

	if( spouse_ref )
	{
		names_only( spouse_ref, name_str, 0, FALSE ) ;
		strcat( p->title_str, "& " ) ;
		strcat( p->title_str, name_str ) ;
		strcat( p->title_str, " " ) ;
	}
}


void  cancel_person( void )
{
	if( *job_ptr )
	{
		edit_pers_ref = 0 ;		/* avoids second save	*/
		edit_person( *job_ptr-- ) ;
	}
	else  close_person() ;
}


void  close_person( void )
{
	edit_pers_ref = 0 ;
	edit_pers_block = -1 ;

	if( coup_form.fm_handle > 0 )  close_couple() ;

	if( notes_form.fm_handle > 0 )  close_form_window( &notes_form ) ;
	notes_loaded = FALSE ;

	if( birth_form.fm_handle > 0 )  close_form_window( &birth_form ) ;
	if( baptism_form.fm_handle > 0 )  close_form_window( &baptism_form ) ;
	if( death_form.fm_handle > 0 )  close_form_window( &death_form ) ;

	menu_ienable( menu_ptr, PRINT_FAMILY, 0 ) ;

	close_form_window( &pers_form ) ;
}


void  pers_mu_mesag( const short *message )
{
	GRECT *rect ;			/* Grect pointer for wind_redraw			*/
	short dummy ;

	switch( message[0] )
	{
		case WM_REDRAW :
			form_redraw( message, &pers_form ) ;
			break ;
		case WM_MOVED :
			rect = (GRECT *) &(message[4]) ;
			wind_set( pers_form.fm_handle, WF_CURRXYWH, PTRS( rect ) ) ;
			pers_form.fm_box = *rect ;
			wind_calc( WC_WORK, wind_form_kind, ELTS( pers_form.fm_box ),
					&pers_form.fm_ptr[ROOT].ob_x, &pers_form.fm_ptr[ROOT].ob_y,
					&dummy, &dummy ) ;
			break ;
		case WM_TOPPED :
			wind_set( pers_form.fm_handle, WF_TOP ) ;
			break ;
		case WM_BOTTOM :
			wind_set( pers_form.fm_handle, WF_BOTTOM ) ;
			break ;
		case WM_CLOSED :
			save_current_edits() ;
			close_person() ;
			break ;
		case WM_ALLICONIFY :
			iconify_all( pers_form.fm_box.g_x ) ;
			break ;
		case WM_ICONIFY :
			wind_set( pers_form.fm_handle, WF_UNICONIFYXYWH, ELTS( pers_form.fm_box ) ) ;
			pers_form.fm_box = *(GRECT *)&message[4] ;
			pers_form.iconified = TRUE ;
			wind_set( pers_form.fm_handle, WF_ICONIFY, ELTS( pers_form.fm_box ) ) ;
			wind_title( pers_form.fm_handle, pers_form.icon_title ) ;
			send_redraw_message( &pers_form.fm_box, pers_form.fm_handle ) ;
			break ;
		case WM_UNICONIFY :
			wind_get( pers_form.fm_handle, WF_UNICONIFY, REFS( pers_form.fm_box ) ) ;
			wind_calc( WC_WORK, wind_form_kind, ELTS( pers_form.fm_box ),
					&pers_form.fm_ptr[ROOT].ob_x, &pers_form.fm_ptr[ROOT].ob_y,
					&dummy, &dummy ) ;
			wind_set( pers_form.fm_handle, WF_UNICONIFY, ELTS( pers_form.fm_box ) ) ;
			wind_title( pers_form.fm_handle, pers_form.title_str ) ;
			pers_form.iconified = FALSE ;
			break ;
		default :
			break ;
	}
}


void  pers_mu_button(  short m_x, short m_y, short breturn )
{
	int mref, fref ;
	short no_exit ;
	short dbl ;						/* double click flag				*/

	if( !pers_form.iconified )
	{
		pers_form.next_object = objc_find( pers_form.fm_ptr, ROOT, MAX_DEPTH,
																m_x, m_y ) ;
		if( pers_form.next_object == NIL )
		{
			Bconout( 2, '\a' ) ;
			objc_edit( pers_form.fm_ptr, pers_form.edit_object, 0,
									&(pers_form.cursor_position), ED_END ) ;
			pers_form.edit_object = 0 ;
		}
		else
		{
			no_exit = form_button( pers_form.fm_ptr, pers_form.next_object,
										breturn, &(pers_form.next_object) ) ;
			if( !no_exit )
			{
				dbl = pers_form.next_object & DOUBLE_CLICK ;
				pers_form.next_object &= ~DOUBLE_CLICK ;
									/* deselect object if it an exit button	*/
				if( pers_form.fm_ptr[pers_form.next_object].ob_flags & EXIT )
					pers_form.fm_ptr[pers_form.next_object].ob_state &= ~SELECTED ;
				switch( pers_form.next_object )
				{
					case SEXCHAR :
						popup_sex_selector() ;
						objc_draw( pers_form.fm_ptr, SEXCHAR, MAX_DEPTH,
													ELTS( pers_form.fm_box ) ) ;
						break ;
					case BIRTH_SOURCE :
						wind_form_do( &birth_form, BF_SOURCE ) ;
						break ;
					case BID_QUALIFIER :
						popup_date_qualifier( form_addrs.bid_qual, pers_form.fm_ptr, BID_QUALIFIER ) ;
						break ;
					case BAPTISM :
						wind_form_do( &baptism_form, BPLACE ) ;
						break ;
					case BAD_QUALIFIER :
						popup_date_qualifier( form_addrs.bad_qual, pers_form.fm_ptr, BAD_QUALIFIER ) ;
						break ;
					case DEATH :
						wind_form_do( &death_form, DPLACE ) ;
						break ;
					case DED_QUALIFIER :
						popup_date_qualifier( form_addrs.ded_qual, pers_form.fm_ptr, DED_QUALIFIER ) ;
						break ;
					case NEXT_SPOUSE :
						step_spouse( 1, edit_pers_ref, pers_form.fm_box ) ;
						break ;
					case PREV_SPOUSE :
						step_spouse( -1, edit_pers_ref, pers_form.fm_box ) ;
						break ;
					case CH_SLIDER :
						slide_children( &pers_form.fm_box ) ;
						break ;
					case CH_UP :
						step_children( -1, &pers_form.fm_box ) ;
							break ;
					case CH_DOWN :
						step_children( 1, &pers_form.fm_box ) ;
						break ;
					case CH_SLIDERANGE :
						step_children( page_children( m_y ), &pers_form.fm_box ) ;
						break ;
					case SIB_SLIDER :
						slide_siblings( &pers_form.fm_box ) ;
						break ;
					case SIB_UP :
						step_siblings( -1, &pers_form.fm_box ) ;
						break ;
					case SIB_DOWN :
						step_siblings( 1, &pers_form.fm_box ) ;
						break ;
					case SIB_SLIDERANGE :
						step_siblings( page_siblings( m_y ), &pers_form.fm_box ) ;
						break ;
					case MOTHER :
						if( dbl )
							sub_edit_person( edit_pers_ref, mother ) ;
						break ;
					case FATHER :
						if( dbl )
							sub_edit_person( edit_pers_ref, father ) ;
						break ;
					case SPOUSE :
						if( dbl && spouse )  sub_edit_person( edit_pers_ref, spouse ) ;
						if( !dbl && spouse_oset < number_spouses )
							edit_couple( couplings[spouse_oset], 0, 0 ) ;
						if( spouse_oset == number_spouses )
						{
							mref = 0 ;
							fref = 0 ;
							if( *form_addrs.sex == male_char )  mref = edit_pers_ref ;
							if( *form_addrs.sex == female_char )  fref = edit_pers_ref ;
							if( mref || fref )
								edit_couple( next_couple, mref, fref ) ;
							else  rsrc_form_alert( 1, NO_SEX_SET ) ;
						}
						break ;
					case WEDDING_PLACE :
						if( !dbl && spouse_oset < number_spouses )
							edit_couple( couplings[spouse_oset], 0, 0 ) ;
						break ;
					case CHILD1 :
					case CHILD2 :
					case CHILD3 :
					case CHILD4 :
						if( dbl )
							sub_edit_person( edit_pers_ref, pprog_array[child_oset + pers_form.next_object - CHILD1] ) ;
						break ;
					case SIBLING1 :
					case SIBLING2 :
					case SIBLING3 :
					case SIBLING4 :
						if( dbl )
							sub_edit_person( edit_pers_ref, sib_array[sib_oset + pers_form.next_object - SIBLING1] ) ;
						break ;
					case NOTES :
						curs_enbl = FALSE ;
						further_notes( edit_pers_ref, edit_pers_pptr ) ;
						break ;
					case PFLAGS :
						set_form_flags( latest_flags ) ;
						if( do_sub_form( flags_ptr, "Set Flags", FL_HELP, TITLED ) == FL_OK )
							latest_flags = form_flags() ;
						break ;
					case P_DELETE :
						if( q_delete_person( edit_pers_ref ) )
						{
							cancel_person() ;
						}
						else  objc_draw( pers_form.fm_ptr, P_DELETE, MAX_DEPTH,
													ELTS( pers_form.fm_box ) ) ;
						break ;
					case CANCEL :
						cancel_person() ;
						break ;
					case P_NEXT :
						save_current_edits() ;
						edit_person( next_person+1 ) ;
						break ;
					case P_OK :
						save_current_edits() ;
						cancel_person() ;
						break ;
					default :
#ifndef NDEBUG
						report( 0x300 + pers_form.next_object ) ;
#endif
						break ;
				}
			}
		}
		change_edit_object( &pers_form, MU_BUTTON ) ;
	}
}


char  alt2ascii( short kstate )
{
	return ( *(*keytable + ( kstate >> 8 ) ) ) ;
}


short  do_sub_form( OBJECT *fm_ptr, char *help_ref, int help_obj, BOOLEAN titled )
{
	short button ;
	OBJECT *old = NULL ;
	const char *ohr = NULL ;
	BOOLEAN ottl = TITLED ;

	assert( fm_ptr != NULL ) ;
	assert( help_ref != NULL ) ;
	
	if( dialogue_form.fm_handle > 0 )			/* Save old dialogue 	*/
	{
		old = dialogue_form.fm_ptr ;
		ohr = dialogue_form.help_ref ;
	assert( old != NULL ) ;
	assert( ohr != NULL ) ;
		ottl = dialogue_form.titled ;
		app_modal_end() ;
	}
	app_modal_init( fm_ptr, help_ref, titled ) ;
	do
	{
		button = app_modal_do() & ~DOUBLE_CLICK ;
		if( button != APP_MODAL_TERM )  fm_ptr[button].ob_state &= ~SELECTED ;
		if( button == help_obj )
		{
			help( help_ref ) ;
			objc_draw( fm_ptr, help_obj, 0, PTRS( app_modal_box() ) ) ;
		}
	}
	while( button == help_obj ) ;

	app_modal_end() ;

	if( old )								/* Restore old dialogue */
		app_modal_init( old, ohr, ottl ) ;

	return button ;
}


void  popup_sex_selector( void )
{
	OBJECT *menus ;
	MENU popup ;
	short x, y ;

	rsrc_gaddr( R_TREE, POPUPS, &menus ) ;
	popup.mn_tree = menus ;
	popup.mn_menu = SEX_SELECTOR ;
	
	if( *form_addrs.sex == female_char )  popup.mn_item = SEX_FEMALE ;
	else  popup.mn_item = SEX_MALE ;

	objc_offset( pers_form.fm_ptr, SEXCHAR, &x, &y ) ;
	popup_menu( &popup, x, y, &popup ) ;
	
	if( popup.mn_item == SEX_FEMALE )  *form_addrs.sex = female_char ;
	else  *form_addrs.sex = male_char ;
}


void  popup_date_qualifier( char* qual_ptr, OBJECT* form_ptr, int field )
{
	OBJECT *menus ;
	MENU popup ;
	short x, y ;

	rsrc_gaddr( R_TREE, POPUPS, &menus ) ;
	popup.mn_tree = menus ;
	popup.mn_menu = DATE_QUALIFIERS ;
	switch( *qual_ptr )
	{
		case 'a' :
			popup.mn_item = QUAL_AFTER ;
			break ;
		case 'b' :
			popup.mn_item = QUAL_BEFORE ;
			break ;
		case 'c' :
			popup.mn_item = QUAL_CIRCA ;
			break ;
		case ' ' :
		default :
			popup.mn_item = QUAL_NONE ;
			break ;
	}
	objc_offset( form_ptr, field, &x, &y ) ;
	popup_menu( &popup, x, y, &popup ) ;
	switch( popup.mn_item )
	{
		case QUAL_AFTER :
			*qual_ptr = 'a' ;
			break ;
		case QUAL_BEFORE :
			*qual_ptr = 'b' ;
			break ;
		case QUAL_CIRCA :
			*qual_ptr = 'c' ;
			break ;
		case QUAL_NONE :
			*qual_ptr = '-' ;
			break ;
	}
}


void  step_spouse( short step, int reference, GRECT box )
{
	if( step == 1 && spouse_oset < number_spouses )
	{
		spouse_oset++ ;
					/* allow left arrow	*/
		*( (char*) &pers_form.fm_ptr[PREV_SPOUSE].ob_spec ) = 0x04 ;
		pers_form.fm_ptr[PREV_SPOUSE].ob_flags |= TOUCHEXIT ;
		if( spouse_oset == number_spouses - 1 )  *( (char*) &pers_form.fm_ptr[NEXT_SPOUSE].ob_spec ) = '>' ;
		else if( spouse_oset >= number_spouses )
		{
			*( (char*) &pers_form.fm_ptr[NEXT_SPOUSE].ob_spec ) = ' ' ;
			pers_form.fm_ptr[NEXT_SPOUSE].ob_flags &= ~TOUCHEXIT ;
		}
	}
	else if( step == -1 && spouse_oset > 0 )
	{
		spouse_oset-- ;
		if( spouse_oset < number_spouses - 1 )
		{
			*( (char*) &pers_form.fm_ptr[NEXT_SPOUSE].ob_spec ) = 0x03 ;
		}
		else  *( (char*) &pers_form.fm_ptr[NEXT_SPOUSE].ob_spec ) = '>' ;
		pers_form.fm_ptr[NEXT_SPOUSE].ob_flags |= TOUCHEXIT ;
		
		if( spouse_oset == 0 )
		{
			*( (char*) &pers_form.fm_ptr[PREV_SPOUSE].ob_spec ) = ' ' ;
			pers_form.fm_ptr[PREV_SPOUSE].ob_flags &= ~TOUCHEXIT ;
		}

	}
	spouse_display( reference ) ;

	objc_draw( pers_form.fm_ptr, SPOUSE_DATA, MAX_DEPTH, ELTS( box ) ) ;
	objc_draw( pers_form.fm_ptr, CHILDREN, MAX_DEPTH, ELTS( box ) ) ;
}


void  slide_children( GRECT *box_ptr)
{
	if( number_children > 4 )
	{
		child_oset = move_slide( pers_form.fm_ptr,
				CH_SLIDER, CH_SLIDERANGE, box_ptr ) ;
		child_oset = ( number_children - 4 ) * child_oset / 1000 ;
		display_children() ;
		objc_draw( pers_form.fm_ptr, CHILDREN, MAX_DEPTH, PTRS( box_ptr ) ) ;
	}
}


short  page_children( short m_y )
{
	short step = 0 ;
	short obj_x, obj_y ;

	if( number_children > 4 )
	{
		objc_offset( pers_form.fm_ptr, CH_SLIDER, &obj_x, &obj_y ) ;
		if( m_y > obj_y )  step = 4 ;
		else  step = -4 ;
	}

	return step ;
}


void  step_children( short step, GRECT *box_ptr )
{
	if( number_children > 4 )
	{
		child_oset += step ;
		if( child_oset < 0 )  child_oset = 0 ;
		else if( child_oset > number_children - 4 )
			child_oset = number_children - 4 ;

		set_slide( child_oset, number_children - 4,
			pers_form.fm_ptr, CH_SLIDER, CH_SLIDERANGE, box_ptr ) ;
		display_children() ;
		objc_draw( pers_form.fm_ptr, CHILDREN, MAX_DEPTH, PTRS( box_ptr ) ) ;
	}
}


void  slide_siblings( GRECT *box_ptr )
{
	if( number_siblings > 4 )
	{
		sib_oset = move_slide( pers_form.fm_ptr,
				SIB_SLIDER, SIB_SLIDERANGE, box_ptr ) ;
		sib_oset = ( number_siblings - 4 ) * sib_oset / 1000 ;
		display_siblings() ;
		objc_draw( pers_form.fm_ptr, SIBLINGS, MAX_DEPTH, PTRS( box_ptr ) ) ;
	}
}


short  page_siblings( short m_y )
{
	short step = 0 ;
	short obj_x, obj_y ;

	if( number_siblings > 4 )
	{
		objc_offset( pers_form.fm_ptr, SIB_SLIDER, &obj_x, &obj_y ) ;
		if( m_y > obj_y )  step = 4 ;
		else  step = -4 ;
	}

	return step ;
}


void  step_siblings( short step, GRECT *box_ptr )
{
	if( number_siblings > 4 )
	{
		sib_oset += step ;
		if( sib_oset < 0 )  sib_oset = 0 ;
		else if( sib_oset > number_siblings - 4 )
			sib_oset = number_siblings - 4 ;

		set_slide( sib_oset, number_siblings - 4,
			pers_form.fm_ptr, SIB_SLIDER, SIB_SLIDERANGE, box_ptr ) ;
		display_siblings() ;
		objc_draw( pers_form.fm_ptr, SIBLINGS, MAX_DEPTH, PTRS( box_ptr ) ) ;
	}
}
