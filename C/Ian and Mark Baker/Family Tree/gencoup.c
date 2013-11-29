/************************************************************************/ 
/*																		*/
/*		Gencoup.c	24 Dec 98											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "gencoup.h"
#include "genutil.h"
#include "gendata.h"
#include "genmain.h"
#include "genpers.h"
#include "genpsel.h"


extern Index_person far *people ;
extern Index_couple far *couples ;
extern short pblock_changed[MAX_PEOPLE_BLOCKS] ;
extern short cblock_changed[MAX_COUPLES_BLOCKS] ;
extern short cidx_changed ;
extern char *next_pstring_ptr[MAX_PEOPLE_BLOCKS] ;
extern char *next_cstring_ptr[MAX_COUPLES_BLOCKS] ;
extern char *pblock_end[MAX_PEOPLE_BLOCKS] ;
extern char *cblock_end[MAX_COUPLES_BLOCKS] ;
extern int c_index_size ;
extern int next_person, next_couple ;
extern short number_spouses, spouse_oset ;

extern Wind_edit_params pers_form ;
extern int wind_form_kind ;
extern int edit_pers_ref ;
extern short edit_pers_block ;

extern short overflowed ;

extern OBJECT *strings_ptr ;		/* pointer to resource strings			*/
extern char months[15][4] ;			/* loaded with month strings		*/

const char* const marriage_help = "Editing marriages" ;

char blankref[] = "        " ;

int edit_coup_ref = 0 ;
short edit_coup_block = -1 ;

Couple *edit_coup_cptr ;

Wind_edit_params coup_form ;
Wind_edit_params co_src_form ;
Wind_edit_params divorce_form ;

struct
{
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


int male, female ;				/* references of two people				*/
int prog_array[MAX_CHILDREN], old_prog_array[MAX_CHILDREN] ;
short prog_oset ;				/* Offset through progeny for display	*/

Wind_edit_params coup_form ;

void  edit_couple( int reference, int male_ref, int female_ref )
{
	int partner ;					/* member of couple who is not edit	*/
									/* person							*/

	if( reference >= c_index_size )	/* if index full abort after giving	*/
									/* a warning						*/
	{
		rsrc_form_alert( 1, C_INDEX_FULL ) ;
		return ;
	}

	busy( BUSY_MORE ) ;

	save_current_edits() ;

	coup_form.fm_ptr[C_SLIDER].ob_y = 0 ;		/* set slider height & offset.	*/
	coup_form.fm_ptr[C_SLIDER].ob_height
			= coup_form.fm_ptr[C_SLIDERANGE].ob_height / 4 ;

	edit_coup_ref = reference ;
	male = couples[reference].male_reference ;
	female = couples[reference].female_reference ;

	edit_coup_cptr = load_couple( edit_coup_ref,
								male_ref, female_ref, &edit_coup_block ) ;

	if( edit_pers_ref == male )  partner = female ;
	else  partner = male ;
	form_wind_title( edit_pers_ref, partner, &coup_form, COUPLE_TITLE, COUPLE_ITITLE ) ;
	coup_form.icon_object = COUP_ICON ;

				/* If people set up do not allow them to be changed.	*/
	if( male )  coup_form.fm_ptr[MALE].ob_flags &= ~TOUCHEXIT ;
	else  coup_form.fm_ptr[MALE].ob_flags |= TOUCHEXIT ;
	if( female )  coup_form.fm_ptr[FEMALE].ob_flags &= ~TOUCHEXIT ;
	else  coup_form.fm_ptr[FEMALE].ob_flags |= TOUCHEXIT ;

	wind_form_do( &coup_form, W_DATE ) ;

	busy( BUSY_LESS ) ;
}


void  close_couple( void )

{
	edit_coup_ref = 0 ;
	edit_coup_block = -1 ;

	if( co_src_form.fm_handle > 0 )  close_form_window( &co_src_form ) ;
	if( divorce_form.fm_handle > 0 )  close_form_window( &divorce_form ) ;

	close_form_window( &coup_form ) ;
}


void  coup_mu_mesag( const short *message )
{
	GRECT *rect ;
	short dummy ;

	switch( message[0] )
	{
		case WM_REDRAW :
			form_redraw( message, &coup_form ) ;
			break ;
		case WM_MOVED :
			rect = (GRECT *) &(message[4]) ;
			wind_set( coup_form.fm_handle, WF_CURRXYWH, PTRS( rect ) ) ;
			coup_form.fm_box = *rect ;
			wind_calc( WC_WORK, wind_form_kind, ELTS( coup_form.fm_box ),
					&coup_form.fm_ptr[ROOT].ob_x, &coup_form.fm_ptr[ROOT].ob_y,
					&dummy, &dummy ) ;
			break ;
		case WM_TOPPED :
			if( message[3] == coup_form.fm_handle )
				wind_set( coup_form.fm_handle, WF_TOP ) ;
			break ;
		case WM_BOTTOM :
			wind_set( coup_form.fm_handle, WF_BOTTOM ) ;
			break ;
		case WM_CLOSED :
			save_couple( edit_coup_ref, edit_coup_block, edit_coup_cptr ) ;
			close_couple() ;
			break ;
		case WM_ALLICONIFY :
			iconify_all( coup_form.fm_box.g_x ) ;
			break ;
		case WM_ICONIFY :
			wind_set( coup_form.fm_handle, WF_UNICONIFYXYWH, ELTS( coup_form.fm_box ) ) ;
			coup_form.fm_box = *(GRECT *)&message[4] ;
			coup_form.iconified = TRUE ;
			wind_set( coup_form.fm_handle, WF_ICONIFY, ELTS( coup_form.fm_box ) ) ;
			wind_title( coup_form.fm_handle, coup_form.icon_title ) ;
			send_redraw_message( &coup_form.fm_box, coup_form.fm_handle ) ;
			break ;
		case WM_UNICONIFY :
			wind_get( coup_form.fm_handle, WF_UNICONIFY, REFS( coup_form.fm_box ) ) ;
			wind_calc( WC_WORK, wind_form_kind, ELTS( coup_form.fm_box ),
					&coup_form.fm_ptr[ROOT].ob_x, &coup_form.fm_ptr[ROOT].ob_y,
					&dummy, &dummy ) ;
			wind_set( coup_form.fm_handle, WF_UNICONIFY, ELTS( coup_form.fm_box ) ) ;
			wind_title( coup_form.fm_handle, coup_form.title_str ) ;
			coup_form.iconified = FALSE ;
			break ;
		default :
			break ;
	}
}


void  coup_mu_button( short m_x, short m_y, short breturn )
{
	short obj_x, obj_y ;			/* object x and y return values		*/
	short no_exit ;
	char names[60] ;				/* string in which to format names	*/

	coup_form.next_object = objc_find( coup_form.fm_ptr, ROOT, MAX_DEPTH, m_x, m_y ) ;
	if( coup_form.next_object == NIL )
	{
		Bconout( 2, '\a' ) ;
		objc_edit( coup_form.fm_ptr, coup_form.edit_object, 0,
							&(coup_form.cursor_position), ED_END ) ;
		coup_form.edit_object = 0 ;
	}
	else
	{
		no_exit = form_button( coup_form.fm_ptr, coup_form.next_object,
								breturn, &(coup_form.next_object) ) ;
		if( !no_exit )
		{
			coup_form.next_object &= ~DOUBLE_CLICK ;
									/* deselect object if it an exit button	*/
			if( coup_form.fm_ptr[coup_form.next_object].ob_flags & EXIT )
				coup_form.fm_ptr[coup_form.next_object].ob_state &= ~SELECTED ;
			switch( coup_form.next_object )
			{
				case C_CANCEL :
					close_couple() ;
					break ;
				case C_OK :
					save_couple( edit_coup_ref, edit_coup_block, edit_coup_cptr ) ;
					close_couple() ;
					break ;
				case C_DELETE :
					if( q_del_coup( edit_coup_ref, edit_coup_block,
														edit_coup_cptr ) )
						close_couple() ;
						else  objc_draw( coup_form.fm_ptr, C_DELETE, MAX_DEPTH,
													ELTS( coup_form.fm_box ) ) ;
					break ;
				case C_HELP :
					help( marriage_help ) ;
					objc_draw( coup_form.fm_ptr, C_HELP, 0, ELTS( coup_form.fm_box ) ) ;
					break ;
				case MALE :
					if( male = get_person_reference( NULL, FALSE ) )
					{
						names_only( male, names, 40, FALSE ) ;
						strcpy( c_form_addrs.male, names ) ;
						objc_draw( coup_form.fm_ptr, MALE, 0,
							(int) coup_form.fm_box.g_x,(int) coup_form.fm_box.g_y,
 							(int) coup_form.fm_box.g_w, (int) coup_form.fm_box.g_h ) ;
						sprintf( c_form_addrs.m_ref, "%10d", male ) ;
						objc_draw( coup_form.fm_ptr, M_REF, 0,
							(int) coup_form.fm_box.g_x,(int) coup_form.fm_box.g_y,
 							(int) coup_form.fm_box.g_w, (int) coup_form.fm_box.g_h ) ;
					}
					break ;
				case FEMALE :
					if( female = get_person_reference( NULL, FALSE ) )
					{
						names_only( female, names, 40, FALSE ) ;
						strcpy( c_form_addrs.female, names ) ;
						objc_draw( coup_form.fm_ptr, FEMALE, 0,
							(int) coup_form.fm_box.g_x,(int) coup_form.fm_box.g_y,
 							(int) coup_form.fm_box.g_w, (int) coup_form.fm_box.g_h ) ;
						sprintf( c_form_addrs.f_ref, "%10d", female ) ;
						objc_draw( coup_form.fm_ptr, F_REF, 0,
							(int) coup_form.fm_box.g_x,(int) coup_form.fm_box.g_y,
 							(int) coup_form.fm_box.g_w, (int) coup_form.fm_box.g_h ) ;
 					}
					break ;
				case WED_QUALIFIER :
					popup_date_qualifier( c_form_addrs.wed_qual, coup_form.fm_ptr, WED_QUALIFIER ) ;
					break ;
				case C_SOURCE :
					wind_form_do( &co_src_form, WF_SOURCE ) ;
					break ;
				case C_DIVORCE :
					wind_form_do( &divorce_form, DI_DATE ) ;
					break ;
				case PROG0 :
				case PROG1 :
				case PROG2 :
				case PROG3 :
				case PROG4 :
				case PROG5 :
				case PROG6 :
				case PROG7 :
				case PROG8 :
				case PROG9 :
					select_progeny( coup_form.next_object - PROG0,
														coup_form.fm_box ) ;
					break ;
				case C_SLIDER :
					prog_oset = move_slide( coup_form.fm_ptr,
								C_SLIDER, C_SLIDERANGE, &coup_form.fm_box ) ;
					prog_oset = 30 * prog_oset / 1000 ;
					update_progeny() ;
					objc_draw( coup_form.fm_ptr, PROGENY, MAX_DEPTH,
								(int) coup_form.fm_box.g_x, (int) coup_form.fm_box.g_y,
								(int) coup_form.fm_box.g_w, (int) coup_form.fm_box.g_h ) ;
					break ;
				case C_UP :
					if( prog_oset > 0 )
					{
						prog_oset-- ;
						set_slide( prog_oset, 30,
							coup_form.fm_ptr, C_SLIDER, C_SLIDERANGE, &coup_form.fm_box ) ;
						update_progeny() ;
						objc_draw( coup_form.fm_ptr, PROGENY, MAX_DEPTH,
									(int) coup_form.fm_box.g_x, (int) coup_form.fm_box.g_y,
									(int) coup_form.fm_box.g_w, (int) coup_form.fm_box.g_h ) ;
					}
					break ;
				case C_DOWN :
					if( prog_oset < 30 )
					{	prog_oset++ ;
						set_slide( prog_oset, 30,
							coup_form.fm_ptr, C_SLIDER, C_SLIDERANGE, &coup_form.fm_box ) ;
						update_progeny() ;
						objc_draw( coup_form.fm_ptr, PROGENY, MAX_DEPTH,
									(int) coup_form.fm_box.g_x, (int) coup_form.fm_box.g_y,
									(int) coup_form.fm_box.g_w, (int) coup_form.fm_box.g_h ) ;
					}
					break ;
				case C_SLIDERANGE :
					objc_offset( coup_form.fm_ptr, C_SLIDER, &obj_x, &obj_y ) ;
					if( m_y > obj_y )
					{
						prog_oset += 9 ;
						if( prog_oset > 30 )  prog_oset = 30 ;
					}
					else
					{
						prog_oset -= 9 ;
						if( prog_oset < 0 )  prog_oset = 0 ;
					}
					set_slide( prog_oset, 30, coup_form.fm_ptr,
								C_SLIDER, C_SLIDERANGE, &coup_form.fm_box ) ;
					update_progeny() ;
					objc_draw( coup_form.fm_ptr, PROGENY, MAX_DEPTH,
									(int) coup_form.fm_box.g_x, (int) coup_form.fm_box.g_y,
									(int) coup_form.fm_box.g_w, (int) coup_form.fm_box.g_h ) ;
					break ;
				default :
#ifndef NDEBUG
					report( 0x300 + coup_form.next_object ) ;
#endif
					break ;
			}
		}
	}
	change_edit_object( &coup_form, MU_BUTTON ) ;
}


void  select_progeny( short prog_num, GRECT box )
{
	int prog ;					/* progeny reference					*/
	char names[IDX_NAM_MAX*2 + DATE_LENGTH + 2] ;
	char alert_str[200], *alert_ptr ;

	prog = -1 ;

	if( prog_array[prog_num + prog_oset] )	/* If child there already,	*/
											/* does it want deleting.	*/
	{
		rsrc_gaddr( R_STRING, PROG_DEL, &alert_ptr ) ;
		names_only( prog_array[prog_num + prog_oset] , names, 30, FALSE ) ;
		sprintf( alert_str, alert_ptr, names  ) ;
		if( form_alert( 1, alert_str ) == 2 )  prog = 0 ;
	}
	else  prog = get_person_reference( people[male].family_name, FALSE ) ;

	if( prog != -1 )
	{
		prog_array[prog_num + prog_oset] = prog ;
		names_date( prog, names, 40, FALSE ) ;
		strcpy( c_form_addrs.child[prog_num], names ) ;
		objc_draw( coup_form.fm_ptr, PROGENY, MAX_DEPTH,
										(int) box.g_x,(int) box.g_y,
										(int) box.g_w, (int) box.g_h ) ;
	}
}


void  set_couple_form_addrs( void )
							/* This routine fetches all the resource	*/
							/* tree addresses for the variable strings	*/
							/* on the edit person form and stores them	*/
							/* in a single array.						*/
{									/* get couple c_form addresses		*/
	c_form_addrs.ref = FORM_TEXT( coup_form.fm_ptr, C_REFERENCE ) ;
	c_form_addrs.male = FORM_TEXT( coup_form.fm_ptr, MALE ) ;
	c_form_addrs.female = FORM_TEXT( coup_form.fm_ptr, FEMALE ) ;
	c_form_addrs.wed = FORM_TEXT( coup_form.fm_ptr, W_DATE ) ;
	c_form_addrs.wed_qual = ( (char *) &(coup_form.fm_ptr[WED_QUALIFIER].ob_spec) ) ;
	c_form_addrs.wep = FORM_TEXT( coup_form.fm_ptr, W_PLACE ) ;
	c_form_addrs.m_ref = FORM_TEXT( coup_form.fm_ptr, M_REF ) ;
	c_form_addrs.f_ref = FORM_TEXT( coup_form.fm_ptr, F_REF ) ;
	c_form_addrs.child[0] = FORM_TEXT( coup_form.fm_ptr, PROG0 ) ;
	c_form_addrs.child[1] = FORM_TEXT( coup_form.fm_ptr, PROG1 ) ;
	c_form_addrs.child[2] = FORM_TEXT( coup_form.fm_ptr, PROG2 ) ;
	c_form_addrs.child[3] = FORM_TEXT( coup_form.fm_ptr, PROG3 ) ;
	c_form_addrs.child[4] = FORM_TEXT( coup_form.fm_ptr, PROG4 ) ;
	c_form_addrs.child[5] = FORM_TEXT( coup_form.fm_ptr, PROG5 ) ;
	c_form_addrs.child[6] = FORM_TEXT( coup_form.fm_ptr, PROG6 ) ;
	c_form_addrs.child[7] = FORM_TEXT( coup_form.fm_ptr, PROG7 ) ;
	c_form_addrs.child[8] = FORM_TEXT( coup_form.fm_ptr, PROG8 ) ;
	c_form_addrs.child[9] = FORM_TEXT( coup_form.fm_ptr, PROG9 ) ;

	c_form_addrs.did = FORM_TEXT( divorce_form.fm_ptr, DI_DATE ) ;
	c_form_addrs.did_qual = ( (char *) &(divorce_form.fm_ptr[DID_QUALIFIER].ob_spec) ) ;
	c_form_addrs.disrc = FORM_TEXT( divorce_form.fm_ptr, DI_SOURCE ) ;
	c_form_addrs.cosrc = FORM_TEXT( co_src_form.fm_ptr, WF_SOURCE ) ;
	c_form_addrs.ww1 = FORM_TEXT( co_src_form.fm_ptr, WWIT1 ) ;
	c_form_addrs.ww2 = FORM_TEXT( co_src_form.fm_ptr, WWIT2 ) ;
}


Couple  *load_couple( int reference, int male_ref, int female_ref, short *blk_ptr )
								/* This routine copies couple data into	*/
								/* the strings used for the edit couple	*/
								/* It can only be used after addresses	*/
								/* set by set_couple_form_addrs().		*/
{
	Couple *cptr ;
	int ref ;						/* temporary holding variable		*/
	char names[2*IDX_NAM_MAX+2+DATE_LENGTH] ;
									/* string into which names formed	*/
	short child ;					/* loop counter						*/
	char  *child_ptr ;				/* pointer to child references		*/

	cptr = get_cdata_ptr( reference, blk_ptr ) ;

	sprintf( c_form_addrs.ref, "%10d", reference ) ;

	if( reference == next_couple )	/* A new couple can start with one	*/
									/* or both partners predefined.		*/
	{
		cptr->male_reference = male_ref ;
		male = male_ref ;
		cptr->female_reference = female_ref ;
		female = female_ref ;
	}

	ref = cptr->male_reference ;
	names_only( ref, names, 40, FALSE ) ;	/* format names into string	*/
	str_load( c_form_addrs.male, names ) ;
	if( male )  sprintf( c_form_addrs.m_ref, "%10d", male ) ;
	else  strcpy( c_form_addrs.m_ref, blankref ) ;
	ref = cptr->female_reference ;
	names_only( ref, names, 40, FALSE ) ;	/* format names into string	*/
	str_load( c_form_addrs.female, names ) ;
	if( female )  sprintf( c_form_addrs.f_ref, "%10d", female ) ;
	else  strcpy( c_form_addrs.f_ref, blankref ) ;

	form_date( c_form_addrs.wed, c_form_addrs.wed_qual, cptr->wedding_date, TRUE ) ;
	if( *c_form_addrs.wed_qual == ' ' )  *c_form_addrs.wed_qual = '-' ;
	str_load( c_form_addrs.wep, cptr->wedding_place ) ;
	str_load( c_form_addrs.ww1, cptr->wedd_wit1 ) ;
	str_load( c_form_addrs.ww2, cptr->wedd_wit2 ) ;
	str_load( c_form_addrs.cosrc, cptr->wedding_source ) ;
	if( c_form_addrs.ww1[0] || c_form_addrs.ww2[0] || c_form_addrs.cosrc[0] )
		coup_form.fm_ptr[C_SOURCE].ob_state |= CHECKED ;
	else  coup_form.fm_ptr[C_SOURCE].ob_state &= ~CHECKED ;

	form_date( c_form_addrs.did, c_form_addrs.did_qual, cptr->divorce_date, TRUE ) ;
	if( *c_form_addrs.did_qual == ' ' )  *c_form_addrs.did_qual = '-' ;
	str_load( c_form_addrs.disrc, cptr->divorce_source ) ;
	if( c_form_addrs.did[0] || c_form_addrs.disrc[0] )
		coup_form.fm_ptr[C_DIVORCE].ob_state |= CHECKED ;
	else  coup_form.fm_ptr[C_DIVORCE].ob_state &= ~CHECKED ;

	prog_oset = 0 ;
	child_ptr = cptr->children ;	/* Display listed children, blank	*/
	child = 0 ;						/* remaining strings.				*/
	if( child_ptr )
	{
		while( ( ref = form_ref( &child_ptr ) ) && ( child < MAX_CHILDREN ) )
		{
			prog_array[child] = ref ;
			old_prog_array[child] = ref ;
			child++ ;
		}
	}
	while( child < MAX_CHILDREN )
	{
		prog_array[child] = 0 ;
		old_prog_array[child] = 0 ;
		child++ ;
	}

	update_progeny() ;

	return cptr ;
}


void  update_progeny()
{
	int ref ;								/* temporary reference		*/
	short child = 0 ;						/* loop counter				*/
	char names[2*IDX_NAM_MAX+2+DATE_LENGTH] ;
									/* string into which names formed	*/

	while( ref = prog_array[child + prog_oset], ref && child < 10 )
	{
		names_date( ref, names, 40, FALSE ) ;
		str_load( c_form_addrs.child[child], names ) ;
		child++ ;
	}
	while( child < 10 )  *(c_form_addrs.child[child++]) = '\0' ;
}


void  save_couple( int reference, short block, Couple *cptr )
{
	int chref ;					/* child reference						*/
	short child ;				/* loop counter							*/
	short new_child, deleted_child ;
	Person *pptr ;
	short pblock ;
	char *alert_ptr, alert_str[200] ;
	short i ;				/* loop counter							*/
	short changed = FALSE ;

	busy( BUSY_MORE ) ;

	save_int( &(cptr->reference), reference, &changed ) ;
	save_int( &(cptr->male_reference), male, &changed ) ;
	save_int( &(cptr->female_reference), female, &changed ) ;
	save_date( &(cptr->wedding_date), c_form_addrs.wed, c_form_addrs.wed_qual, &changed ) ;
	str_save( &(cptr->wedding_place), c_form_addrs.wep,
		&next_cstring_ptr[block], cblock_end[block], &changed ) ;
	str_save( &(cptr->wedd_wit1), c_form_addrs.ww1,
		&next_cstring_ptr[block], cblock_end[block], &changed ) ;
	str_save( &(cptr->wedd_wit2), c_form_addrs.ww2,
		&next_cstring_ptr[block], cblock_end[block], &changed ) ;
	str_save( &(cptr->wedding_source), c_form_addrs.cosrc,
		&next_cstring_ptr[block], cblock_end[block], &changed ) ;
	save_date( &(cptr->divorce_date), c_form_addrs.did, c_form_addrs.did_qual, &changed ) ;
	str_save( &(cptr->divorce_source), c_form_addrs.disrc,
		&next_cstring_ptr[block], cblock_end[block], &changed ) ;

	add_to_cidx( reference, cptr ) ;

	if( male )
	{
		pptr = get_pdata_ptr( male, &pblock ) ;
		if( pptr->sex == '?' )
		{
			pptr->sex = 'm' ;
			pblock_changed[pblock] = TRUE ;
		}
		add_coupling( male, reference ) ;
		sort_couplings( male ) ;
	}
	if( female )
	{
		pptr = get_pdata_ptr( female, &pblock ) ;
		if( pptr->sex == '?' )
		{
			pptr->sex = 'f' ;
			pblock_changed[pblock] = TRUE ;
		}
		add_coupling( female, reference ) ;
		sort_couplings( female ) ;
	}

	qsort( prog_array, (size_t) MAX_CHILDREN, (size_t) 4, child_compare ) ;

	if( prog_array[0] || old_prog_array[0] )
	{
		child = 0 ;
		while( chref = prog_array[child] )
		{
			new_child = TRUE ;
			for( i=0; i<MAX_CHILDREN; i++ )
				if( chref == old_prog_array[i] )  new_child = FALSE ;
			if( new_child )
			{
				pptr = get_pdata_ptr( chref, &pblock ) ;
				if( pptr->parents && pptr->parents != reference )
				{
					rsrc_gaddr( R_STRING, TWO_PARENTS, &alert_ptr ) ;
					sprintf( alert_str, alert_ptr, chref ) ;
					form_alert( 1, alert_str ) ;
					prog_array[child] = 0 ;
				}
				else
				{
					pptr->parents = reference ;
					pblock_changed[pblock] = TRUE ;
					changed = TRUE ;
				}
			}
			child++ ;
		}
		child = 0 ;
		while( chref = old_prog_array[child] )
		{
			deleted_child = TRUE ;
			for( i=0; i<MAX_CHILDREN; i++ )
				if( chref == prog_array[i] )  deleted_child = FALSE ;
			if( deleted_child )
			{
				pptr = get_pdata_ptr( chref, &pblock ) ;
				pptr->parents = 0 ;
				pblock_changed[pblock] = TRUE ;
				changed = TRUE ;
			}
			child++ ;
		}
	}
							/* resort array in case of deletions		*/
	qsort( prog_array, (size_t) MAX_CHILDREN, (size_t) 4, child_compare ) ;

	if( prog_array[0] )
		cput_references( &cptr->children, block, prog_array ) ;
	else  cptr->children = 0 ;

	if( changed )
	{
		cblock_changed[block] = TRUE ;
		load_person( edit_pers_ref, &edit_pers_block ) ;
		send_redraw_message( &pers_form.fm_box, pers_form.fm_handle ) ;
	}

	if( spouse_oset == number_spouses )		/* i.e. adding a new coupling	*/
	{
		number_spouses++ ;
		*( (char*) &pers_form.fm_ptr[NEXT_SPOUSE].ob_spec ) = '>' ;
		pers_form.fm_ptr[NEXT_SPOUSE].ob_flags |= TOUCHEXIT ;
	}

	if( reference == next_couple )  next_couple++ ;

	busy( BUSY_LESS ) ;

	if( next_couple >= c_index_size )  rsrc_form_alert( 1, C_INDEX_FULL ) ;

	if( overflowed )  rsrc_form_alert( 1, BK_FULL ) ;
}


void  save_int( int *dest, int source, short *changed_ptr )
{
	if( *dest != source )
	{
		*dest = source ;
		*changed_ptr = TRUE ;
	}
}


int  child_compare( void *child1_ptr, void *child2_ptr )
{
	int greater ;

	if( *(int *)child1_ptr && *(int *)child2_ptr )
		greater = (int) compare_dates( people[*(int *)child1_ptr].birth_date,
								people[*(int *)child2_ptr].birth_date ) ;

	else  if( *(int *)child1_ptr )  greater = -1 ;
	else  if( *(int *)child2_ptr )  greater = 1 ;
	else greater = 0 ;

	return greater ;
}


void  add_to_cidx( int ref, Couple *cptr )
{
	if( couples[ref].male_reference != cptr->male_reference )
	{
		couples[ref].male_reference = cptr->male_reference ;
		cidx_changed = TRUE ;
	}
	if( couples[ref].female_reference != cptr->female_reference )
	{
		couples[ref].female_reference = cptr->female_reference ;
		cidx_changed = TRUE ;
	}
	if( couples[ref].wedding_date != cptr->wedding_date )
	{
		couples[ref].wedding_date = cptr->wedding_date ;
		cidx_changed = TRUE ;
	}
}


short  q_del_coup( int reference, short block, Couple *cptr )
					/* This routine deletes a couple by removing its	*/
					/* reference from both spouses lists of couplings.	*/
					/* The couple will still exist and its number can	*/
					/* not be re-used. From 2.10 onwards, couple data	*/
					/* is cleared.										*/
					/* If there are any progeny they must be removed	*/
					/* first.											*/
{
	short pblock ;
	Person *pptr ;
	int chref ;						/* temporary child reference		*/
	short prog_exist = FALSE, succeed = FALSE ;
	short i ;						/* loop counter						*/

	busy( BUSY_MORE ) ;

	for( i=0; i<MAX_CHILDREN; i++ )
		if( prog_array[i] )  prog_exist = TRUE ;

	if( prog_exist )  rsrc_form_alert( 1, PROG_EXIST ) ;
	else
	{
		if( rsrc_form_alert( 2, SURE_DELETE ) == 1 )
		{
			for( i=0; i<MAX_CHILDREN; i++ )	/* delete old children refs	*/
			{
				if( chref = old_prog_array[i] )
				{
					pptr = get_pdata_ptr( chref, &pblock ) ;
					pptr->parents = 0 ;
					pblock_changed[pblock] = TRUE ;
				}
			}
			if( male )  remove_coupling( male, reference ) ;
			if( female )  remove_coupling( female, reference ) ;
			
			couples[reference].male_reference = 0 ;
			couples[reference].female_reference = 0 ;
			couples[reference].wedding_date = 0 ;
			clear_couple( block, reference % COUPLES_PER_BLOCK ) ;
			cblock_changed[block] = TRUE ;

			load_person( edit_pers_ref, &edit_pers_block ) ;
			send_redraw_message( &pers_form.fm_box, pers_form.fm_handle ) ;

			succeed = TRUE ;
		}
	}
	busy( BUSY_LESS ) ;

	return succeed ;
}


void  sort_couplings( int ref )
{
	Person *pptr ;
	short block ;
	int coups[MAX_COUPLINGS], old_coups[MAX_COUPLINGS] ;
	short changed = FALSE ;
	short i ;
	char *chr_ptr ;			/* pointer to couples in character area	*/

	pptr = get_pdata_ptr( ref, &block ) ;
	if( pptr->couplings )	/* if any couplings load and sort them	*/
	{
		get_couplings( pptr, coups ) ;
								/* copy and count couplings			*/
		i = 0 ;
		while( old_coups[i] = coups[i] )  i++ ;

		qsort( coups, (size_t) i, (size_t) 4, coup_compare ) ;

		while( i > 0 )
		{
			i-- ;
			if( coups[i] != old_coups[i] )  changed = TRUE ;
		}
				/* As the number of couplings does not change it is	*/
				/* all right to simply overwrite the old values.	*/
		if( changed )
		{
			pblock_changed[block] = TRUE ;
			chr_ptr = pptr->couplings ;
			i = 0 ;
			while( coups[i] )  put_ref( coups[i++], &chr_ptr ) ;
		}
	}
}


void  get_children( Couple *cptr, int *children )
{
	short child = 0 ;
	char *child_ptr ;
	int ref ;

	if( child_ptr = cptr->children )
	{
		while( ( ref = form_ref( &child_ptr ) ) && ( child < MAX_CHILDREN ) )
			children[child++] = ref ;
		children[child] = 0 ;					/* terminate entries	*/
	}
}
