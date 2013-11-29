/************************************************************************/
/*																		*/
/*		Genmerg.c	 5 Dec 99											*
/*																		*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "genutil.h"
#include "genmerg.h"
#include "gencoup.h"
#include "gencsvd.h"
#include "gendata.h"
#include "genfile.h"
#include "gengedc.h"
#include "genmain.h"
#include "genpers.h"
#include "genpref.h"
#include "genpsel.h"

extern char Version[] ;
extern char months[15][4] ;		/* loaded with month strings			*/

extern char transfer_file[] ;
extern char gedcom_transfer_file[] ;
extern char csv_transfer_file[] ;

extern Index_person *people ;
extern Index_couple *couples ;
extern int next_person, next_couple ;
extern int *matches ;
extern char *edit_buffer ;

extern short pidx_changed, cidx_changed ;
extern short pblock_changed[MAX_PEOPLE_BLOCKS] ;
extern short cblock_changed[MAX_COUPLES_BLOCKS] ;
extern char *next_pstring_ptr[MAX_PEOPLE_BLOCKS] ;
extern char *next_cstring_ptr[MAX_COUPLES_BLOCKS] ;
extern char *pblock_end[MAX_PEOPLE_BLOCKS] ;
extern char *cblock_end[MAX_COUPLES_BLOCKS] ;

extern OBJECT *flags_ptr ;
extern struct
{
	char *fl[8] ;
} flags_addrs ;

extern Preferences prefs ;

struct
{
	char *fl[8] ;
} use_flag_addrs ;

const char* const export_help = "Export" ;
const char* const std_header = "Transfer file for Gen.prg" ;

int total_people ;
int total_couples ;
char *exp_selected ;

int *match_refs ;					/* to find match posn from ref	*/
int *pcross_refs, *ccross_refs ;

int trans_pers_oset ;
int trans_coup_oset ;

short flag_cross_ref[8] ;

struct
{
	char *selects[16] ;
} esel_form_addrs ;

struct
{
	char *efam_name ;
	char *eforename ;
	char *ebefore ;
	char *eafter ;
	char *eplace ;
} efil_form_addrs ;


OBJECT *esel_ptr ;
OBJECT *efil_ptr ;			/* pointer to select filter form	*/
OBJECT *use_flag_ptr ;


void  export_tree( void )

{
	short transfer_type ;

	if( select_exports( &transfer_type ) )
	{
		set_cross_refs() ;
		write_transfer_file( transfer_type ) ;
	}
}


short  select_exports( short *type_ptr )
{
	int oset = 0 ;				/* slider offset in numbers of people	*/
	short done = FALSE ;
	short fdone ;
	short export = FALSE ;
	short button ;
	short m_x, m_y ;
	short dummy ;
	short obj_x, obj_y ;
	Filter filter ;
	short i, flag ;

	match_refs = (int *) pmalloc( sizeof (int) * next_person ) ;
	pcross_refs = (int *) pmalloc( sizeof (int) * next_person ) ;
	ccross_refs = (int *) pmalloc( sizeof (int) * next_couple ) ;

	total_people = 0 ;
	for( i=1; i<next_person; i++ )
	{
		if( people[i].birth_date != DELETED_DATE )
			matches[total_people++] = i ;
	}

	exp_selected = (char *) pmalloc( total_people ) ;

	if( !exp_selected || !match_refs || !pcross_refs || !ccross_refs )
	{	
		rsrc_form_alert( 1, NO_MEMORY ) ;
		if( exp_selected )  free( exp_selected ) ;
		if( match_refs )  free( match_refs ) ;
		if( pcross_refs )  free( pcross_refs ) ;
		if( ccross_refs ) free( ccross_refs ) ;
		return FALSE ;
	}

	qsort( matches, (size_t) total_people, (size_t) 4, pidx_compare ) ;

				/* initialise match_refs as not all of array is used	*/
	for( i=0; i<next_person; i++ )  match_refs[i] = -1 ;
				/* load array to get from reference to match position	*/
	for( i=0; i<total_people; i++ )  match_refs[matches[i]] = i ;

	for( i=0; i<total_people; i++ )  exp_selected[i] = FALSE ;

	if( total_people > 16 )
	{
		if( total_people < 256 )
			esel_ptr[ES_SLIDER].ob_height
					= esel_ptr[ES_SLIDE_RANGE].ob_height * 16 / total_people ;
		else
			esel_ptr[ES_SLIDER].ob_height
					= esel_ptr[ES_SLIDE_RANGE].ob_height / 16 ;
		set_slide( 0, total_people-16, esel_ptr,
										ES_SLIDER, ES_SLIDE_RANGE, app_modal_box() ) ;
	}
	else
	{
		esel_ptr[ES_SLIDER].ob_height = esel_ptr[ES_SLIDE_RANGE].ob_height ;
		set_slide( 0, 1, esel_ptr, ES_SLIDER, ES_SLIDE_RANGE, app_modal_box() ) ;
	}

	list_exportees( oset ) ;

	app_modal_init( esel_ptr, "Export", TITLED ) ;

	while( !done )
	{
		button = app_modal_do() ;
		button &= ~DOUBLE_CLICK ;

		if( button  && button != APP_MODAL_TERM )  esel_ptr[button].ob_state &= ~SELECTED ;

		switch( button )
		{
			case ES_SLIDER :
				if( total_people > 16 )
				{
					oset = move_slide( esel_ptr,
										ES_SLIDER, ES_SLIDE_RANGE, app_modal_box() ) ;
					oset = ( total_people - 16 ) * oset / 1000 ;
				}
				list_exportees( oset ) ;
				objc_draw( esel_ptr, ES_LIST, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				break ;
			case ES_UP :
				if( total_people > 16 && oset > 0 )
				{
					oset-- ;
					set_slide( oset, total_people-16, esel_ptr,
										ES_SLIDER, ES_SLIDE_RANGE, app_modal_box() ) ;
				}
				list_exportees( oset ) ;
				objc_draw( esel_ptr, ES_LIST, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				break ;
			case ES_DOWN :
				if( total_people > 16 && oset < total_people - 16 )
				{
					oset++ ;
					set_slide( oset, total_people - 16, esel_ptr,
										ES_SLIDER, ES_SLIDE_RANGE, app_modal_box() ) ;
				}
				list_exportees( oset ) ;
				objc_draw( esel_ptr, ES_LIST, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				break ;
			case ES_SLIDE_RANGE :
				if( total_people > 16 )
				{
					graf_mkstate( &m_x, &m_y, &dummy, &dummy ) ;
					objc_offset( esel_ptr, ES_SLIDER, &obj_x, &obj_y ) ;
					if( m_y > obj_y )
					{
						oset += 15 ;
						if( oset > total_people - 16 )  oset = total_people - 16 ;
					}
					else
					{
						oset -= 15 ;
						if( oset < 0 )  oset = 0 ;
					}
					set_slide( oset, total_people-16, esel_ptr,
									ES_SLIDER, ES_SLIDE_RANGE, app_modal_box() ) ;
				}
				list_exportees( oset ) ;
				objc_draw( esel_ptr, ES_LIST, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				break ;
			case ESEL0 :
			case ESEL1 :
			case ESEL2 :
			case ESEL3 :
			case ESEL4 :
			case ESEL5 :
			case ESEL6 :
			case ESEL7 :
			case ESEL8 :
			case ESEL9 :
			case ESEL10 :
			case ESEL11 :
			case ESEL12 :
			case ESEL13 :
			case ESEL14 :
			case ESEL15 :
				if( esel_ptr[ANCESTORS].ob_state & SELECTED )
				{
					ancestor_select( matches[button-ESEL0 + oset] ) ;
					esel_ptr[ANCESTORS].ob_state &= ~SELECTED ;
					esel_ptr[DESCENDANTS].ob_state &= ~SELECTED ;
					list_exportees( oset ) ;
					objc_draw( esel_ptr, ROOT, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				}
				else if( esel_ptr[DESCENDANTS].ob_state & SELECTED )
				{
					descendant_select( matches[button-ESEL0 + oset], 0, 0 ) ;
					esel_ptr[DESCENDANTS].ob_state &= ~SELECTED ;
					list_exportees( oset ) ;
					objc_draw( esel_ptr, ROOT, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				}
				else
				{
					if( !exp_selected[button-ESEL0 + oset] )
					{
						exp_selected[button-ESEL0 + oset] = TRUE ;
						esel_ptr[button].ob_state |= CHECKED ;
					}
					else
					{
						exp_selected[button-ESEL0 + oset] = FALSE ;
						esel_ptr[button].ob_state &= ~CHECKED ;
					}
					objc_draw( esel_ptr, button, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				}
				break ;
			case ES_SEL_ALL :
				for( i=0; i<total_people; i++ )  exp_selected[i] = TRUE ;
				list_exportees( oset ) ;
				objc_draw( esel_ptr, ES_LIST, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				objc_draw( esel_ptr, ES_SEL_ALL, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				break ;
			case ES_DSEL_ALL :
				for( i=0; i<total_people; i++ )  exp_selected[i] = FALSE ;
				list_exportees( oset ) ;
				objc_draw( esel_ptr, ES_LIST, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				objc_draw( esel_ptr, ES_DSEL_ALL, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				break ;
			case ES_FILTER :
				clear_efil_form() ;
				clear_form_flags() ;
				for( i = 0 ; i <= FL_NOT8 - FL_NOT1 ; i+= FL_NOT2 - FL_NOT1 )
				{
					set_to_ignore(FL_NOT1+i) ;
					flags_ptr[FL_NOT1+i].ob_state |= SELECTED ;
				}
				fdone = FALSE ;				/* loop until filter done	*/
				while( !fdone )
				{
					button = do_sub_form( efil_ptr, "Export Filter", EXP_HELP, TITLED ) ;
					switch( button )
					{
						case EXP_SEL :
						case EXP_DESEL :
							busy( BUSY_MORE ) ;
							update_filter( &filter, efil_form_addrs.efam_name,
								efil_form_addrs.eforename, efil_form_addrs.ebefore,
								efil_form_addrs.eafter, efil_form_addrs.eplace ) ;
							if( button == EXP_DESEL )  flag = FALSE ;
							else  flag = TRUE ;
							for( i=0; i<total_people; i++ )
							{
								if( test_match( &filter, matches[i] ) )
									exp_selected[i] = flag ;
							}
							busy( BUSY_LESS ) ;
						case EXP_CANCEL :
							fdone = TRUE ;
							break ;
						case EXP_FLAGS :
							do_sub_form( flags_ptr, "Filter Flags", FL_HELP, TITLED ) ;
							break ;
					}
				}
				list_exportees( oset ) ;
				break ;
			case ES_CANCEL :
			case APP_MODAL_TERM :
				done = TRUE ;
				break ;
			case ES_OK :
				export = TRUE ;
				done = TRUE ;
				break ;
			case ES_HELP :
				help( export_help ) ;
				objc_draw( esel_ptr, ES_HELP, 0, PTRS( app_modal_box() ) ) ;
				break ;
			default :
				break ;
		}
	}
	esel_ptr[ANCESTORS].ob_state &= ~SELECTED ;
	esel_ptr[DESCENDANTS].ob_state &= ~SELECTED ;

	if( esel_ptr[GEDCOM].ob_state & SELECTED )
		*type_ptr = GEDCOM_TYPE ;
	else if( esel_ptr[CSV].ob_state & SELECTED )
		*type_ptr = CSV_TYPE ;
	else  *type_ptr = FAMTREE_TYPE ;
	
	app_modal_end() ;

	return export ;
}


void  ancestor_select( int reference )
{
	Person *pptr ;
	short block ;
	int ref ;
	int parents, excluded_couple = 0 ;

	exp_selected[match_refs[reference]] = TRUE ;

	pptr = get_pdata_ptr( reference, &block ) ;

	if( parents = pptr->parents )
	{
		if( ref = couples[parents].male_reference )
		{
			ancestor_select( ref ) ;
			if( esel_ptr[DESCENDANTS].ob_state & SELECTED )
				descendant_select( ref, reference, 0 ) ;
			excluded_couple = parents ;
		}
		if( ref = couples[parents].female_reference )
		{
			ancestor_select( ref ) ;
			if( esel_ptr[DESCENDANTS].ob_state & SELECTED )
				descendant_select( ref, reference, excluded_couple ) ;
		}
	}
}


void  descendant_select( int reference, int excluded_child,
													int excluded_couple )
{
	Person *pptr ;
	Couple *cptr ;
	char *ch_ptr ;						/* ptrs to array of child refs	*/
	char *coupls_ptr ;					/* ptr to array of couplings	*/
	short block ;
	int coup ;
	int ch ;
	int next_child ;
	int next_coup ;

	exp_selected[match_refs[reference]] = TRUE ;

	pptr = get_pdata_ptr( reference, &block ) ;

	if( coupls_ptr = pptr->couplings, coupls_ptr )
	{
		next_coup = form_ref( &coupls_ptr ) ;
		while( coup = next_coup )
		{
			next_coup = get_next_couple( coup, reference ) ;
			if( coup != excluded_couple )
			{
				cptr = get_cdata_ptr( coup, &block ) ;
				if( cptr->male_reference == reference )
				{
					if( cptr->female_reference )
						exp_selected[match_refs[cptr->female_reference]] = TRUE ;
				}
				else
				{
					if( cptr->male_reference )
							exp_selected[match_refs[cptr->male_reference]] = TRUE ;
				}
				if( ch_ptr = cptr->children )
				{
					next_child = form_ref( &ch_ptr ) ;
					while( ch = next_child )
					{
						next_child = get_next_child( ch, coup ) ;
						if( ch != excluded_child )  descendant_select( ch, 0, 0 ) ;
					}
				}
			}
		}
	}
}


void  list_exportees( int oset )
{
	int entry ;
	int ref ;
	char names[2*IDX_NAM_MAX+2+DATE_LENGTH] ;

	for( entry=0; entry < total_people && entry < 16; entry++ )
	{
		ref = matches[entry+oset] ;
		names_date( ref, names, 40, FALSE ) ;
									/* format names & date into string	*/
		str_load( esel_form_addrs.selects[entry], names ) ;
		if( exp_selected[entry+oset] == TRUE )
			esel_ptr[entry+ESEL0].ob_state |= CHECKED ;
		else  esel_ptr[entry+ESEL0].ob_state &= ~CHECKED ;
	}
	while( entry < 16 )
	{
		*(esel_form_addrs.selects[entry++]) = '\0' ;
		esel_ptr[entry+ESEL0].ob_state &= ~CHECKED ;
	}
}


void  set_esel_form_addrs( void )
							/* This routine fetches all the resource	*/
							/* tree addresses for the variable strings	*/
							/* on the select export form and stores		*/
							/* them in a single array.					*/
{
							/* get select export form addresses			*/
	esel_form_addrs.selects[0] = FORM_TEXT(esel_ptr, ESEL0) ;
	esel_form_addrs.selects[1] = FORM_TEXT(esel_ptr, ESEL1) ;
	esel_form_addrs.selects[2] = FORM_TEXT(esel_ptr, ESEL2) ;
	esel_form_addrs.selects[3] = FORM_TEXT(esel_ptr, ESEL3) ;
	esel_form_addrs.selects[4] = FORM_TEXT(esel_ptr, ESEL4) ;
	esel_form_addrs.selects[5] = FORM_TEXT(esel_ptr, ESEL5) ;
	esel_form_addrs.selects[6] = FORM_TEXT(esel_ptr, ESEL6) ;
	esel_form_addrs.selects[7] = FORM_TEXT(esel_ptr, ESEL7) ;
	esel_form_addrs.selects[8] = FORM_TEXT(esel_ptr, ESEL8) ;
	esel_form_addrs.selects[9] = FORM_TEXT(esel_ptr, ESEL9) ;
	esel_form_addrs.selects[10] = FORM_TEXT(esel_ptr, ESEL10) ;
	esel_form_addrs.selects[11] = FORM_TEXT(esel_ptr, ESEL11) ;
	esel_form_addrs.selects[12] = FORM_TEXT(esel_ptr, ESEL12) ;
	esel_form_addrs.selects[13] = FORM_TEXT(esel_ptr, ESEL13) ;
	esel_form_addrs.selects[14] = FORM_TEXT(esel_ptr, ESEL14) ;
	esel_form_addrs.selects[15] = FORM_TEXT(esel_ptr, ESEL15) ;
}


void  set_efil_form_addrs( void )
							/* This routine fetches all the resource	*/
							/* tree addresses for the variable strings	*/
							/* on the select filter form and stores		*/
							/* them in a single array.					*/

{							/* get filter export form addresses			*/
	efil_form_addrs.efam_name = FORM_TEXT(efil_ptr, EXP_FAMILY_NAME) ;
	efil_form_addrs.eforename = FORM_TEXT(efil_ptr, EXP_FORENAME) ;
	efil_form_addrs.ebefore = FORM_TEXT(efil_ptr, EXP_BEFORE) ;
	efil_form_addrs.eafter = FORM_TEXT(efil_ptr, EXP_AFTER) ;
	efil_form_addrs.eplace = FORM_TEXT(efil_ptr, EXP_POB) ;
}


void  clear_efil_form( void )	/* clear all selection strings	*/

{	efil_form_addrs.efam_name[0] = '\0' ;
	efil_form_addrs.eforename[0] = '\0' ;
	efil_form_addrs.ebefore[0] = '\0' ;
	efil_form_addrs.eafter[0] = '\0' ;
	efil_form_addrs.eplace[0] = '\0' ;
}


void  set_cross_refs( void )
{
	int pers_no = 0, coup_no = 0 ;
	int male, female ;
	int child ;
	short include_couple ;
	Couple *cptr ;
	short block ;
	char *ch_ptr ;
	int i ;

	for( i=1; i<next_person; i++ )
	{
		if( match_refs[i] != -1 && exp_selected[match_refs[i]] )
			pcross_refs[i] = ++pers_no ;
		else  pcross_refs[i] = 0 ;
	}
	total_people = pers_no ;

	ccross_refs[0] = 0 ;
	for( i=1; i<next_couple; i++ )
	{
		include_couple = FALSE ;
		if( male = couples[i].male_reference )
			if( !pcross_refs[male] )  male = 0 ;
		if( female = couples[i].female_reference )
			if( !pcross_refs[female] )  female = 0 ;
		if( male && female )  include_couple = TRUE ;
		else if( male || female )
		{
			cptr = get_cdata_ptr( i, &block ) ;
			if( ch_ptr = cptr->children )
			{
				while( child = form_ref( &ch_ptr ) )
				{
					if( pcross_refs[child] )
						include_couple = TRUE ;
				}
			}
		}
		if( include_couple )  ccross_refs[i] = ++coup_no ;
		else  ccross_refs[i] = 0 ;
	}
	total_couples = coup_no ;
}


int  write_transfer_file( short transfer_type )
{
	FILE *fp ;
	int i ;

	assert( transfer_type == FAMTREE_TYPE || transfer_type == GEDCOM_TYPE || transfer_type == CSV_TYPE ) ;

	if( !get_transfer_file_name( transfer_type ) )  return FALSE ;
	
	switch( transfer_type )
	{
		case FAMTREE_TYPE :
			fp = fopen( transfer_file, "w" ) ;
			break ;
		case GEDCOM_TYPE :
			fp = fopen( gedcom_transfer_file, "w" ) ;
			break ;
		case CSV_TYPE :
			fp = fopen( csv_transfer_file, "w" ) ;
			break ;
	}
	
	if( fp == NULL )  return FALSE ;

	busy( BUSY_MORE ) ;

	switch( transfer_type )
	{
		case FAMTREE_TYPE :
			write_std_transfer_header( fp ) ;
			break ;
		case GEDCOM_TYPE :
			write_gedcom_transfer_header( fp ) ;
			break ;
		case CSV_TYPE :
			break ;
	}

	for( i=1; i<next_person; i++ )
	{
		if( pcross_refs[i] )
		{
			switch( transfer_type )
			{
				case FAMTREE_TYPE :
					write_std_transfer_person( i, fp ) ;
					break ;
				case GEDCOM_TYPE :
					write_gedcom_transfer_person( i, fp ) ;
					break ;
				case CSV_TYPE :
					write_csv_transfer_person( i, fp ) ;
					break ;
			}
		}
	}
		
	if( transfer_type == FAMTREE_TYPE )
	{
		fprintf( fp, "pee\nCouples transfer data\n" ) ;
	}

	for( i=1; i<next_couple; i++ )
	{
		if( ccross_refs[i] )
		{
			switch( transfer_type )
			{
				case FAMTREE_TYPE :
					write_std_transfer_couple( i, fp ) ;
					break ;
				case GEDCOM_TYPE :
					write_gedcom_transfer_couple( i, fp ) ;
					break ;
				case CSV_TYPE :
					break ;
			}
		}
	}
	switch( transfer_type )
	{
		case FAMTREE_TYPE :
			fprintf( fp, "coe\n" ) ;
			break ;
		case GEDCOM_TYPE :
			fputs( "0 TRLR\n", fp ) ;
			break ;
		case CSV_TYPE :
			break ;
	}

	fclose( fp ) ;
		
	busy( BUSY_LESS ) ; 

	return TRUE ;
}



void  write_std_transfer_header( FILE *fp )
{
	short flag ;

	fprintf( fp, "%s, Version %s\n", std_header, Version ) ;
	fprintf( fp, "ttp%d\n", total_people ) ;
	fprintf( fp, "ttc%d\n", total_couples ) ;

	for( flag=0; flag<=7; flag++ )
	{
		if( flags_addrs.fl[flag][0] )
			fprintf( fp, "fl%d%s\n", flag+1, flags_addrs.fl[flag] ) ;
	}

	fprintf( fp, "hde\n" ) ;
	fprintf( fp, "People transfer data\n" ) ;
}
		

short  get_transfer_file_name( short transfer_type )

{
	short button ;

	switch( transfer_type )
	{
		case FAMTREE_TYPE :
			fsel_geninput( transfer_file, NULL, &button, SELECT_TRANSFER ) ;
			break ;
		case GEDCOM_TYPE :
			fsel_geninput( gedcom_transfer_file, NULL, &button, SELECT_TRANSFER ) ;
			break ;
		case CSV_TYPE :
			fsel_geninput( csv_transfer_file, NULL, &button, SELECT_TRANSFER ) ;
			break ;
	}
	if( button )  save_defaults() ;

	return button ;
}


void  write_std_transfer_person( int pers, FILE *fp )
{
	Person *p_ptr ;
	short block ;
	int pars, cref ;
	char *coups ;
	short first ;

	p_ptr = get_pdata_ptr( pers, &block ) ;

	fprintf( fp, "ref%d\n", pcross_refs[pers] ) ;
	save_std_pdata( p_ptr, fp ) ;
	if( pars = ccross_refs[p_ptr->parents] )
		fprintf( fp, "par%d\n", pars ) ;

	if( coups = p_ptr->couplings)
	{
		first = TRUE ;
		while( cref = form_ref( &coups ) )
		{	if( cref = ccross_refs[cref], cref )
			{	if( first )  fprintf( fp, "cou" ) ;
				else  fputc( ',', fp ) ;
				fprintf( fp, "%d", cref ) ;
				first = FALSE ;
			}
		}
		if( !first )  fputc( '\n', fp ) ;
	}

	fprintf( fp, "end\n" ) ;
}


void  write_std_transfer_couple( int coup, FILE *fp )
{
	Couple *c_ptr ;
	short block ;
	char *child_ptr ;
	short first ;
	int ref ;

	c_ptr = get_cdata_ptr( coup, &block ) ;

	fprintf( fp, "ref%d\n", ccross_refs[coup] ) ;
	if( c_ptr->male_reference )
		fprintf( fp, "mal%d\n", pcross_refs[c_ptr->male_reference] ) ;
	if( c_ptr->female_reference )
		fprintf( fp, "fem%d\n", pcross_refs[c_ptr->female_reference] ) ;
	save_std_cdata( c_ptr, fp ) ;
	if( child_ptr = c_ptr->children )
	{
		first = TRUE ;
		while( ref = form_ref( &child_ptr ) )
		{
			if( ref = pcross_refs[ref] )
			{
				if( first )  fprintf( fp, "chi" ) ;
				else  fputc( ',', fp ) ;
				fprintf( fp, "%d", ref ) ;
				first = FALSE ;
			}
		}
		if( !first )  fputc( '\n', fp ) ;
	}
	fprintf( fp, "end\n" ) ;
}


void  import_tree( void )
{
	FILE *fp ;
	short transfer_type = FAMTREE_TYPE ;
	short succeed ;		/* primarily used to check if gedcom header loaded	*/

	if( get_transfer_file_name( transfer_type ) && ( fp = fopen( transfer_file, "r" ) ) )
	{
		busy( BUSY_MORE ) ;

		transfer_type = read_trans_hdr_type( fp ) ;

		switch( transfer_type )
		{
			case FAMTREE_TYPE :
				load_std_trans_hdr( fp ) ;
				if( check_hdr() )
				{
					trans_pers_oset = next_person - 1 ;
					trans_coup_oset = next_couple - 1 ;

					load_trans_people( fp ) ;
					load_trans_couples( fp ) ;
				}
				break ;
			case GEDCOM_TYPE :
				succeed = prescan_gedcom_file( fp ) ;
				if( succeed )  load_gedcom_file( fp ) ;
				break ;
			case CSV_TYPE :
								/* Only load csv data if new tree or user chooses to continue	*/
				if( next_person == 1 || rsrc_form_alert( 1, CSV_WARNING ) == 2 )
				{
					fseek( fp, 0, SEEK_SET ) ;	/* no header, so return to start of file	*/
					load_csv_file( fp ) ;
				}
				break ;
		}
		
		fclose( fp ) ;
		
		busy( BUSY_LESS ) ;
	}
}


short  read_trans_hdr_type( FILE *fp )
{
	char buffer[BUFFER_SIZE] ;
	short transfer_type = FAMTREE_TYPE ;

	fgets( buffer, BUFFER_SIZE - 1, fp ) ;
	if( strstr( buffer, std_header ) )  transfer_type = FAMTREE_TYPE ;
	else if( strstr( buffer, "HEAD" ) )  transfer_type = GEDCOM_TYPE ;
	else  transfer_type = CSV_TYPE ;
	
	return transfer_type ;
}


void  load_std_trans_hdr( FILE *fp )
{
	char *buf_ptr, buffer[BUFFER_SIZE] ;
	int parameter ;
	short done = FALSE ;

	short i ;
	for( i=0; i<8; i++ )  flag_cross_ref[i] = -1 ;
												/* initialise to none	*/
	buffer[BUFFER_SIZE - 1] = '\0' ;
	while( fgets( buffer, BUFFER_SIZE - 1, fp ), !feof( fp ) && !done )
	{
		buf_ptr = buffer ;
		buffer[strlen( buffer ) - 1] = '\0' ;
		parameter = (*buf_ptr++<<16) + (*buf_ptr++<<8) + *buf_ptr++ ;
		switch( parameter )
		{
			case 'fl1' :
			case 'fl2' :
			case 'fl3' :
			case 'fl4' :
			case 'fl5' :
			case 'fl6' :
			case 'fl7' :
			case 'fl8' :
				import_flag_string( parameter - 'fl1', buf_ptr ) ;
				break ;
			case 'ttp' :
				total_people = atoi( buf_ptr ) ;
				break ;
			case 'ttc' :
				total_couples = atoi( buf_ptr ) ;
				break ;
			case 'hde' :
				done = TRUE ;
				break ;
			default :
				break ;
		}
	}
}


void  import_flag_string( short flag_number, char *buf_ptr )
{
	char import_flag_string[FLAG_LENGTH+1] ;
	short cross_ref = -1 ;
	short button ;
	short i ;

	strncpy( import_flag_string, buf_ptr, FLAG_LENGTH ) ;
	import_flag_string[FLAG_LENGTH] = '\0' ;	/* ensure termination */

	for( i=0; i<8; i++ )
	{
		if( !stricmp( import_flag_string, flags_addrs.fl[i] ) )
			cross_ref = i ;
	}

	if( cross_ref == -1 )
	{	
		strcpy( FORM_TEXT(use_flag_ptr, INCLUDE_FLAG), import_flag_string ) ;
		for( i=0; i<8; i++ )
			strcpy( use_flag_addrs.fl[i], flags_addrs.fl[i] ) ;
		button = do_sub_form( use_flag_ptr, "Import", UF_HELP, TITLED ) ;

		if( button != DO_NOT_USE_FL )
			cross_ref = button - USE_FL1 ;
		if( cross_ref != -1 && flags_addrs.fl[cross_ref][0] == '\0' )
			strcpy( flags_addrs.fl[cross_ref], import_flag_string ) ;
	}
	if( cross_ref != -1 )  flag_cross_ref[flag_number] = cross_ref ;
}


short  check_hdr( void )	/* Check whether there is index space for	*/
							/* the imported people and couples.			*/
{
	short check = TRUE ;

	if( next_person + total_people > prefs.max_people )
	{
		check = FALSE ;
		rsrc_form_alert( 1, P_INDEX_FULL ) ;
	}
	if( next_couple + total_couples > prefs.max_couples )
	{
		check = FALSE ;
		rsrc_form_alert( 1, C_INDEX_FULL ) ;
	}
	return check ;
}


void  load_trans_people( FILE *fp )
{
	char *buf_ptr, buffer[BUFFER_SIZE] ;
	int parameter ;
	short done = FALSE ;
	Person *p_ptr ;
	int pref ;
	short block ;
	char *chr_ptr ;		/* used for pointing to references		*/
	int couplings[MAX_COUPLINGS+1] ;
	short import_flags ;
	short cross_ref ;
	short i, mask ;

	buffer[BUFFER_SIZE - 1] = '\0' ;
	while( fgets( buffer, BUFFER_SIZE - 1, fp ), !feof( fp ) && !done )
	{
		buf_ptr = buffer ;
		buffer[strlen( buffer ) - 1] = '\0' ;
		parameter = (*buf_ptr++<<16) + (*buf_ptr++<<8) + *buf_ptr++ ;
		switch( parameter )
		{
			case 'ref' :
				pref = atoi( buf_ptr ) ;
				pref += trans_pers_oset ;
				p_ptr = get_pdata_ptr( pref, &block ) ;
				break ;
			case 'flg' :
				import_flags = (short) atoi( buf_ptr ) ;
				mask = 1 ;
				for( i=0; i<8; i++ )
				{
					cross_ref = flag_cross_ref[i] ;
					if( cross_ref != -1 && import_flags & mask )
						p_ptr->flags |= 1 << ( 2 * cross_ref ) ;
					mask <<= 1 ;
					if( cross_ref != -1 && import_flags & mask )
						p_ptr->flags |= 2 << ( 2 * cross_ref ) ;
					mask <<= 1 ;
				}
				break ;
			case 'end' :
				p_ptr->reference = pref ;
				if( p_ptr->parents )  p_ptr->parents += trans_coup_oset ;
				if( chr_ptr = p_ptr->couplings )
				{
					get_couplings( p_ptr, couplings ) ;
					i = 0 ;
					while( couplings[i] )
						put_ref( couplings[i++] + trans_coup_oset, &chr_ptr ) ;
				}
				add_to_pidx( pref, p_ptr ) ;
				pblock_changed[block] = TRUE ;
				next_person++ ;
				break ;
			case 'pee' :
				done = TRUE ;
				break ;
			default :
				load_pparam( parameter, p_ptr, buf_ptr, block, buffer, fp ) ;
				break ;
		}
	}
	pidx_changed = TRUE ;
}


void  load_trans_couples( FILE *fp )
{
	char *buf_ptr, buffer[BUFFER_SIZE] ;
	int parameter ;
	short done = FALSE ;
	Couple *cptr ;
	int cref ;
	short block ;
	char *chr_ptr ;		/* used for pointing to references		*/
	int children[MAX_CHILDREN+1] ;
	short i ;

	buffer[BUFFER_SIZE - 1] = '\0' ;
	while( fgets( buffer, BUFFER_SIZE - 1, fp ), !feof( fp ) && !done )
	{
		buf_ptr = buffer ;
		buffer[strlen( buffer ) - 1] = '\0' ;
		parameter = (*buf_ptr++<<16) + (*buf_ptr++<<8) + *buf_ptr++ ;
		switch( parameter )
		{
			case 'ref' :
				cref = atoi( buf_ptr ) ;
				cref += trans_coup_oset ;
				cptr = get_cdata_ptr( cref, &block ) ;
				break ;
			case 'end' :
				cptr->reference = cref ;
				if( cptr->male_reference )
					cptr->male_reference += trans_pers_oset ;
				if( cptr->female_reference )
					cptr->female_reference += trans_pers_oset ;
				if( chr_ptr = cptr->children )
				{
					get_children( cptr, children ) ;
					i = 0 ;
					while( children[i] )
						put_ref( children[i++] + trans_pers_oset, &chr_ptr ) ;
				}
				add_to_cidx( cref, cptr ) ;
				cblock_changed[block] = TRUE ;
				next_couple++ ;
				break ;
			case 'coe' :
				done = TRUE ;
				break ;
			default :
				load_cparam( parameter, cptr, buf_ptr, block ) ;
				break ;
		}
	}
	cidx_changed = TRUE ;
}



