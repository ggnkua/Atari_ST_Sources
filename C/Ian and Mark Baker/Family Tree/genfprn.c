/************************************************************************/
/*																		*/
/*		Genfprn.c	22 Jul 97											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"
#endif

#include "genhd.h"
#include "genfprn.h"
#include "genutil.h"
#include "gendata.h"
#include "genpprn.h"
#include "genprnt.h"
#include "gentprn.h"


#define indent 2
#define date_posn 12
#define text_posn 24
#define minimum_person_lines 5

extern Index_couple *couples ;

extern int edit_pers_ref ;
extern Person *edit_pers_pptr ;
extern short number_spouses, spouse_oset ;
extern int couplings[MAX_COUPLINGS] ;
extern int print_couple ;
extern int mother, father, spouse ;

extern FONTINFO fontinfo, largefont ;

extern Wind_edit_params pers_form, birth_form, baptism_form, death_form ;
extern Wind_edit_params coup_form, co_src_form, divorce_form ;
extern OBJECT *strings_ptr ;

void  print_family( void )
{
	Person *s_pptr ;
	Couple *cptr ;
	short block ;
	short dummy ;
	Str_prt_params params ;
	char *ch_ptr ;
	int ch ;			/* child's reference	*/
	Person *child_pptr ;
	BOOLEAN print_parents_notes = TRUE ;
	BOOLEAN print_childrens_notes = FALSE ;
	short selection ;
	char divider_string[256] ;
	short i ;

	assert( edit_pers_ref > 0 ) ;
	assert( edit_pers_pptr != NULL ) ;
	
	selection = rsrc_form_alert( 0, FAMILY_NOTES ) ;

	if( selection == 1 )  print_parents_notes = FALSE ;
	else if( selection == 3 )  print_childrens_notes = TRUE ;

	if( !open_printer( &params ) )  return ;

	busy( BUSY_MORE ) ;

	start_print_checking( &params ) ;

	params.ref1 = edit_pers_ref ;
	if( number_spouses > 0 )  params.ref2 = spouse ;
	else  params.ref2 = 0 ;

	if( params.use_gdos )  setup_font( &params, fontinfo ) ;

	params.max_len = 0 ;
	params.last_x_end = 0 ;
	params.y_pos = 0 ;
	params.align = LEFT_WRAP ;

	print_basic_person_data( edit_pers_pptr, &params ) ;
	print_parents( edit_pers_pptr, &params ) ;
	
	if( print_parents_notes && edit_pers_pptr->notes != NULL )
		print_notes_indented( edit_pers_pptr, &params ) ;

	down_n_lines( 1, &params ) ;

	if( number_spouses > 0 && spouse != 0 )
	{
		cptr = get_cdata_ptr( couplings[spouse_oset], &dummy ) ;
		assert( cptr != NULL ) ;
		print_date_text( coup_form.fm_ptr, C_SOURCE, cptr->wedding_date,
									cptr->wedding_place, &params ) ;
		down_n_lines( 1, &params ) ;

		s_pptr = get_pdata_ptr( spouse, &block ) ;
		assert( s_pptr != NULL ) ;
			
		print_basic_person_data( s_pptr, &params ) ;
		print_parents( s_pptr, &params ) ;
		if( print_parents_notes && s_pptr->notes != NULL )
			print_notes_indented( s_pptr, &params ) ;

		if( printing_ok( &params ) && ( ch_ptr = cptr->children ) )
		{
			down_n_lines( 1, &params ) ;

			params.x_pos = 0 ;
			params.tabpos = 0 ;
			params.downlines = 1 ;
			print_str( pers_form.fm_ptr, CH_STRING, NULL, 0, &params ) ;
			for( i=0; i<255 && i < params.chs_across; i++ )  divider_string[i] = '-' ;
			divider_string[i] = '\0' ;
			print_str( NULL, 0, divider_string, 0, &params ) ;

			while(  printing_ok( &params ) && ( ch = form_ref( &ch_ptr ) ) )
			{
				down_n_lines( 1, &params ) ;
			
				child_pptr = get_pdata_ptr( ch, &dummy ) ;
				print_basic_person_data( child_pptr, &params ) ;
				print_spouses( child_pptr, &params ) ;
				if( print_childrens_notes && child_pptr->notes != NULL )
					print_notes_indented( child_pptr, &params ) ;
			}
		}
	}

	end_page( &params, FALSE ) ;
	close_printer( &params ) ;
	busy( BUSY_LESS ) ;
}


void  print_basic_person_data( Person* pptr, Str_prt_params *ps_ptr )
{
	char names[FULL_NAME_PLUS_REF_MAX + 1] ;
	short normal_cell_height ;
	short minimum_person_space ;
	short normal_chs_up ;
	
	ps_ptr->x_pos = 0 ;
	ps_ptr->tabpos = 0 ;
	ps_ptr->downlines = 1 ;

	if( ps_ptr->use_gdos )
	{
		normal_cell_height = ps_ptr->cell_height ;
		normal_chs_up = ps_ptr->chs_up ;
		setup_font( ps_ptr, largefont ) ;

		minimum_person_space = ( ps_ptr->char_height / normal_cell_height )
												+ minimum_person_lines - 1 ;
		if( minimum_person_space > normal_chs_up - ps_ptr->y_pos
								&& minimum_person_space < normal_chs_up )
			next_page( ps_ptr ) ;
		else if( ps_ptr->char_height > normal_cell_height )
			down_n_lines( ps_ptr->char_height / normal_cell_height, ps_ptr ) ;

		ps_ptr->cell_height = normal_cell_height ;
	}
	else
	{
		if( ps_ptr->chs_up - ps_ptr->y_pos < minimum_person_lines )  next_page( ps_ptr ) ;
	}
	names_ref( pptr->reference, names, 0, TRUE ) ;
	print_str( NULL, 0, names, 0, ps_ptr ) ;
	if( ps_ptr->use_gdos )
		setup_font( ps_ptr, fontinfo ) ;

	print_date_text( pers_form.fm_ptr, BIRTH_SOURCE, pptr->birth_date,
												pptr->birth_place, ps_ptr ) ;
	print_date_text( pers_form.fm_ptr, BAPTISM, pptr->baptism_date,
												pptr->baptism_place, ps_ptr ) ;
	print_date_text( pers_form.fm_ptr, DEATH, pptr->death_date,
												pptr->death_place, ps_ptr ) ;
	print_date_text( strings_ptr, BURIED, pptr->burial_date,
												pptr->burial_place, ps_ptr ) ;
	print_date_text( pers_form.fm_ptr, OCCUPATION, 0,
												pptr->occupation, ps_ptr ) ;
}


void  print_date_text(  OBJECT *form_ptr, short field, int date, char *text,
					Str_prt_params *ps_ptr )
{
	ps_ptr->downlines = 0 ;
	ps_ptr->x_pos = indent ;
	ps_ptr->tabpos = date_posn ;	
	print_date( form_ptr, field, date, 0, ps_ptr ) ;

	ps_ptr->downlines = 1 ;
	ps_ptr->x_pos = text_posn ;
	ps_ptr->tabpos = 0 ;
	print_str( NULL, 0, text, 0, ps_ptr ) ;
}


void  print_parents( Person *pptr, Str_prt_params *ps_ptr )
{
	char names[FULL_NAME_PLUS_REF_MAX + 1] ;
	int parent ;

	parent = couples[pptr->parents].male_reference ;
	if( parent )  names_ref( parent, names, 0, TRUE ) ;
	else names[0] = '\0' ;
	print_date_text( pers_form.fm_ptr, FATHER, 0, names, ps_ptr ) ;

	parent = couples[pptr->parents].female_reference ;
	if( parent )  names_ref( parent, names, 0, TRUE ) ;
	else names[0] = '\0' ;
	print_date_text( pers_form.fm_ptr, MOTHER, 0, names, ps_ptr ) ;
}


void  print_spouses( Person* pptr, Str_prt_params *ps_ptr )
{
	char names[FULL_NAME_PLUS_REF_MAX + 1] ;
	char *coupls_ptr ;
	int coup ;

	coupls_ptr = pptr->couplings ;

	if( coupls_ptr == NULL )  return ;

	while( coup = form_ref( &coupls_ptr ) )
	{
		if( pptr->reference == couples[coup].male_reference )  spouse = couples[coup].female_reference ;
		else  spouse = couples[coup].male_reference ;
		
		if( spouse )
		{
			names_ref( spouse, names, 0, TRUE ) ;
			print_date_text( pers_form.fm_ptr, SPOUSE, 0, names, ps_ptr ) ;
		}
	}
}
