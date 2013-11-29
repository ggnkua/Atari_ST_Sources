/************************************************************************/
/*																		*/
/*		Genpers2.c	 7 Jul 95											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"
#endif

#include "genhd.h"
#include "genpers.h"
#include "genutil.h"
#include "gencoup.h"
#include "gendata.h"
#include "genfile.h"
#include "gennote.h"

extern People_block *p_block_ptrs[MAX_PEOPLE_BLOCKS] ;
extern Couples_block *c_block_ptrs[MAX_COUPLES_BLOCKS] ;

extern int ap_id ;					/* global application identifier	*/

extern Index_person far *people ;
extern Index_couple far *couples ;
extern short pblock_changed[MAX_PEOPLE_BLOCKS] ;
extern short cblock_changed[MAX_COUPLES_BLOCKS] ;
extern short pidx_changed ;
extern char *next_pstring_ptr[MAX_PEOPLE_BLOCKS] ;
extern char *next_cstring_ptr[MAX_COUPLES_BLOCKS] ;
extern char *pblock_end[MAX_PEOPLE_BLOCKS] ;
extern int p_index_size ;
extern int edit_pers_ref ;
extern int next_person, next_couple ;

extern char far overflow[OVERFLOW_SIZE] ;
extern short overflowed ;

extern Wind_edit_params pers_form, birth_form, baptism_form, death_form ;

extern OBJECT *flags_ptr ;

extern int notes_handle ;		/* window handle for notes				*/
extern short notes_open ;
extern GRECT note_box ;
extern short notes_created ;
extern short notes_loaded ;

extern char months[15][4] ;		/* loaded with month strings			*/
extern char circa[4] ;
extern char circa_char ;
extern char before_char ;
extern char after_char ;

extern int *job_ptr ;

extern short notes_used ;

extern int mother, father, spouse ;
extern int couplings[MAX_COUPLINGS] ;
extern int pprog_array[MAX_CHILDREN] ;
extern int sib_array[MAX_CHILDREN] ;
extern short number_spouses, spouse_oset ;
extern short number_children, number_siblings ;
extern short child_oset, sib_oset ;	/* offset through children and		*/
									/* siblings for display				*/
extern short latest_flags ;

extern struct
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



void  set_person_form_addrs( void )
							/* This routine fetches all the resource	*/
							/* tree addresses for the variable strings	*/
							/* on the edit person form and stores them	*/
							/* in a single array.						*/
{									/* get person form addresses		*/									
	form_addrs.ref = FORM_TEXT( pers_form.fm_ptr, P_REFERENCE ) ;
	form_addrs.fam = FORM_TEXT( pers_form.fm_ptr, FAMILY_NAME ) ;
	form_addrs.fore = FORM_TEXT( pers_form.fm_ptr, FORENAMES ) ;
	form_addrs.bid = FORM_TEXT( pers_form.fm_ptr, BIRTH_DATE ) ;
	form_addrs.bid_qual = ( (char *) &(pers_form.fm_ptr[BID_QUALIFIER].ob_spec) ) ;
	form_addrs.bip = FORM_TEXT( pers_form.fm_ptr, BIRTH_PLACE ) ;
	form_addrs.bad = FORM_TEXT( pers_form.fm_ptr, BDATE ) ;
	form_addrs.bad_qual = ( (char *) &(pers_form.fm_ptr[BAD_QUALIFIER].ob_spec) ) ;
	form_addrs.occ = FORM_TEXT( pers_form.fm_ptr, OCCUPATION ) ;
	form_addrs.mother = FORM_TEXT( pers_form.fm_ptr, MOTHER ) ;
	form_addrs.father = FORM_TEXT( pers_form.fm_ptr, FATHER ) ;
	form_addrs.child[0] = FORM_TEXT( pers_form.fm_ptr, CHILD1 ) ;
	form_addrs.child[1] = FORM_TEXT( pers_form.fm_ptr, CHILD2 ) ;
	form_addrs.child[2] = FORM_TEXT( pers_form.fm_ptr, CHILD3 ) ;
	form_addrs.child[3] = FORM_TEXT( pers_form.fm_ptr, CHILD4 ) ;
	form_addrs.spouse = FORM_TEXT( pers_form.fm_ptr, SPOUSE ) ;
	form_addrs.wed = FORM_TEXT( pers_form.fm_ptr, WEDDING_DATE ) ;
	form_addrs.wed_qual = ( (char *) &(pers_form.fm_ptr[WDD_QUALIFIER].ob_spec) ) ;
	form_addrs.wep = FORM_TEXT( pers_form.fm_ptr, WEDDING_PLACE ) ;
	form_addrs.ded = FORM_TEXT( pers_form.fm_ptr, DEATH_DATE ) ;
	form_addrs.ded_qual = ( (char *) &(pers_form.fm_ptr[DED_QUALIFIER].ob_spec) ) ;
	form_addrs.sib[0] = FORM_TEXT( pers_form.fm_ptr, SIBLING1 ) ;
	form_addrs.sib[1] = FORM_TEXT( pers_form.fm_ptr, SIBLING2 ) ;
	form_addrs.sib[2] = FORM_TEXT( pers_form.fm_ptr, SIBLING3 ) ;
	form_addrs.sib[3] = FORM_TEXT( pers_form.fm_ptr, SIBLING4 ) ;
				/* sex is ms byte of int ob_spec		*/
	form_addrs.sex = ( (char *) &(pers_form.fm_ptr[SEXCHAR].ob_spec) ) ;

	form_addrs.dep = FORM_TEXT( death_form.fm_ptr, DPLACE ) ;
	form_addrs.bcp = FORM_TEXT( death_form.fm_ptr, BCPLACE ) ;
	form_addrs.bcd = FORM_TEXT( death_form.fm_ptr, BCDATE ) ;
	form_addrs.bcd_qual = ( (char *) &(death_form.fm_ptr[BCD_QUALIFIER].ob_spec) ) ;
	form_addrs.desrc = FORM_TEXT( death_form.fm_ptr, DSOURCE ) ;
	form_addrs.dwd = FORM_TEXT( death_form.fm_ptr, DW_DATE ) ;
	form_addrs.wid_qual = ( (char *) &(death_form.fm_ptr[WID_QUALIFIER].ob_spec) ) ;
	form_addrs.dw1 = FORM_TEXT( death_form.fm_ptr, DWIT1 ) ;
	form_addrs.dw2 = FORM_TEXT( death_form.fm_ptr, DWIT2 ) ;
	form_addrs.ex1 = FORM_TEXT( death_form.fm_ptr, EXEC1 ) ;
	form_addrs.ex2 = FORM_TEXT( death_form.fm_ptr, EXEC2 ) ;
	form_addrs.sol = FORM_TEXT( death_form.fm_ptr, SOLIC ) ;
	form_addrs.ben = FORM_TEXT( death_form.fm_ptr, BENEF ) ;
	form_addrs.be2 = FORM_TEXT( death_form.fm_ptr, BENEF2 ) ;
	form_addrs.be3 = FORM_TEXT( death_form.fm_ptr, BENEF3 ) ;

	form_addrs.bap = FORM_TEXT( baptism_form.fm_ptr, BPLACE ) ;
	form_addrs.basrc = FORM_TEXT( baptism_form.fm_ptr, BSOURCE ) ;
	form_addrs.bisrc = FORM_TEXT( birth_form.fm_ptr, BF_SOURCE ) ;
}


Person  *load_person( int reference, short *block )	
								/* This routine copies person data into	*/
								/* the strings used for the edit person	*/
								/* It can only be used after addresses	*/
								/* set by set_person_form_addrs().		*/
{
	Person *pptr ;
	Couple *cptr ;
	int coup, ref ;					/* temporary holding variables		*/
	char names[2*IDX_NAM_MAX+2] ;	/* temporary holding string			*/
	short sib ;
	short cblk ;					/* for unwanted return				*/
	char *sib_ptr ;
	short self_found ;
			
	busy( BUSY_MORE ) ;

	pptr = get_pdata_ptr( reference, block ) ;

	sprintf( form_addrs.ref, "%10d", reference ) ;

	str_load( form_addrs.fam, pptr->family_name ) ;
	str_load( form_addrs.fore, pptr->forenames ) ;

	str_load( form_addrs.bip, pptr->birth_place ) ;
	form_date( form_addrs.bid, form_addrs.bid_qual, pptr->birth_date, TRUE ) ;
	if( *form_addrs.bid_qual == ' ' )  *form_addrs.bid_qual = '-' ;
	str_load( form_addrs.bisrc, pptr->birth_source ) ;
	if( form_addrs.bisrc[0] )
		pers_form.fm_ptr[BIRTH_SOURCE].ob_state |= CHECKED ;
	else  pers_form.fm_ptr[BIRTH_SOURCE].ob_state &= ~CHECKED ;

	str_load( form_addrs.occ, pptr->occupation ) ;

	str_load( form_addrs.bap, pptr->baptism_place ) ;	
	form_date( form_addrs.bad, form_addrs.bad_qual, pptr->baptism_date, TRUE ) ;
	if( *form_addrs.bad_qual == ' ' )  *form_addrs.bad_qual = '-' ;
	str_load( form_addrs.basrc, pptr->baptism_source ) ;	
	if( form_addrs.basrc[0] )
		pers_form.fm_ptr[BAPTISM].ob_state |= CHECKED ;
	else  pers_form.fm_ptr[BAPTISM].ob_state &= ~CHECKED ;

	str_load( form_addrs.dep, pptr->death_place ) ;	
	str_load( form_addrs.bcp, pptr->burial_place ) ;	
	form_date( form_addrs.bcd, form_addrs.bcd_qual, pptr->burial_date, TRUE ) ;
	if( *form_addrs.bcd_qual == ' ' )  *form_addrs.bcd_qual = '-' ;
	form_date( form_addrs.ded, form_addrs.ded_qual, pptr->death_date, TRUE ) ;
	if( *form_addrs.ded_qual == ' ' )  *form_addrs.ded_qual = '-' ;
	str_load( form_addrs.desrc, pptr->death_source ) ;
	form_date( form_addrs.dwd, form_addrs.wid_qual, pptr->will_date, TRUE ) ;
	str_load( form_addrs.dw1, pptr->will_wit1 ) ;
	str_load( form_addrs.dw2, pptr->will_wit2 ) ;
	str_load( form_addrs.ex1, pptr->will_exe1 ) ;
	str_load( form_addrs.ex2, pptr->will_exe2 ) ;
	str_load( form_addrs.sol, pptr->will_sol ) ;
	str_load( form_addrs.ben, pptr->will_bens ) ;
	str_load( form_addrs.be2, pptr->will_bens2 ) ;
	str_load( form_addrs.be3, pptr->will_bens3 ) ;
	
	if( form_addrs.dep[0] || form_addrs.bcp[0] || form_addrs.bcd[0]
			|| form_addrs.desrc[0] || form_addrs.dwd[0]
			|| form_addrs.dw1[0] || form_addrs.dw2[0] || form_addrs.ex1[0]
			|| form_addrs.ex2[0] || form_addrs.sol[0] || form_addrs.ben[0]
			|| form_addrs.be2[0] || form_addrs.be3[0] )
		pers_form.fm_ptr[DEATH].ob_state |= CHECKED ;
	else  pers_form.fm_ptr[DEATH].ob_state &= ~CHECKED ;
		
	if( coup = pptr->parents )
	{
		mother = couples[coup].female_reference ;
		names_only( mother, names, 40, FALSE ) ;
											/* format names into string	*/
		strcpy( form_addrs.mother, names ) ;
		father = couples[coup].male_reference ;
		names_only( father, names, 40, FALSE ) ;
											/* format names into string	*/
		strcpy( form_addrs.father, names ) ;

		cptr = get_cdata_ptr( coup, &cblk ) ;	/* fill sibling array	*/

		self_found = FALSE ;
		sib = 0 ;
		if( sib_ptr = cptr->children )
		{
			while( ( ref = form_ref( &sib_ptr ) ) )
			{
				if( ref != reference )  sib_array[sib++] = ref ;
				else  self_found = TRUE ;
			}
		}
		number_siblings = sib ;
		while( sib < MAX_CHILDREN )  sib_array[sib++] = 0 ;
		qsort( sib_array, (size_t) number_siblings, (size_t) 4,
														child_compare ) ;

		if( !self_found )	/* Added to handle particular error which	*/
							/* occurred when earlier versions of		*/
							/* program failed to save couple data.		*/
		{
			sib_array[number_siblings] = reference ;
			cput_references( &cptr->children, cblk, sib_array ) ;
			sib_array[number_siblings] = 0 ;
			rsrc_form_alert( 1, COUP_DATA_ERROR ) ;
		}
	}
	else
	{
		blank_field( pers_form.fm_ptr, FATHER, TOTAL ) ;
		blank_field( pers_form.fm_ptr, MOTHER, TOTAL ) ;
		mother = 0 ;
		father = 0 ;
		for( sib=0; sib<MAX_CHILDREN; sib++ )  sib_array[sib] = 0 ;
	}

	sib_oset = 0 ;
	pers_form.fm_ptr[SIB_SLIDER].ob_y = 0 ;
	if( number_siblings > 4 )
		pers_form.fm_ptr[SIB_SLIDER].ob_height
			= 4 * pers_form.fm_ptr[SIB_SLIDERANGE].ob_height / number_siblings ;
	else  pers_form.fm_ptr[SIB_SLIDER].ob_height
			= pers_form.fm_ptr[SIB_SLIDERANGE].ob_height ;
	display_siblings() ;

	spouse_oset = 0 ;

	if( pptr->couplings )		/* If any couplings display 1st spouse.	*/
	{
		sort_couplings( reference ) ;
		get_couplings( pptr, couplings ) ;
								/* count couplings						*/
		while( couplings[spouse_oset++] ) ;
		number_spouses = spouse_oset - 1 ;
		spouse_oset = 0 ;

		/* if more than one coupling set right arrow	*/
		/* if one coupling set greater than arrow		*/
		if( number_spouses > 1 )  *( (char*) &pers_form.fm_ptr[NEXT_SPOUSE].ob_spec ) = 0x03 ;
		else  *( (char*) &pers_form.fm_ptr[NEXT_SPOUSE].ob_spec ) = '>' ;
		pers_form.fm_ptr[NEXT_SPOUSE].ob_flags |= TOUCHEXIT ;
	}
	else
	{
		number_spouses = 0 ;
		*( (char*) &pers_form.fm_ptr[NEXT_SPOUSE].ob_spec ) = ' ' ;
		pers_form.fm_ptr[NEXT_SPOUSE].ob_flags &= ~TOUCHEXIT ;
	}
	*( (char*) &pers_form.fm_ptr[PREV_SPOUSE].ob_spec ) = ' ' ;
	pers_form.fm_ptr[PREV_SPOUSE].ob_flags &= ~TOUCHEXIT ;

	for( coup = number_spouses ; coup < MAX_COUPLINGS; coup++ )
		couplings[coup] = 0 ;

	spouse_display( reference ) ;

	*form_addrs.sex = pptr->sex ;

						/* to force further_notes() to load edit buffer	*/
	notes_loaded = FALSE ;	
	if( pptr->notes && *(pptr->notes) )
		pers_form.fm_ptr[NOTES].ob_state |= CHECKED ;
	else  pers_form.fm_ptr[NOTES].ob_state &= ~CHECKED ;

	busy( BUSY_LESS ) ;
	return pptr ;
}


void  display_siblings( void )
{
	short sib = 0 ;
	int chref ;
	char names[2*IDX_NAM_MAX+2] ;	/* temporary holding string			*/

	while( ( chref = sib_array[sib_oset+sib] ) && ( sib < 4 ) )
	{
		names_only( chref, names, 32, FALSE ) ;
		str_load( form_addrs.sib[sib], names ) ;
		sib++ ;
	}

	names_only( 0, names, 32, FALSE ) ;
	while( sib < 4 )
	{
		str_load( form_addrs.sib[sib], names ) ;
		sib++ ;
	}
}



void  spouse_display( int reference )

{
	Couple *cptr ;
	short cblock ;						/* couple block number			*/
	int ref ;							/* temporary holding variable	*/
	char names[2*IDX_NAM_MAX+2] ;		/* temporary holding string		*/
	char *child_ptr ;
	short child ;

	if( couplings[spouse_oset] )
	{
		if( spouse = couples[couplings[spouse_oset]].male_reference,
													spouse == reference )
			spouse = couples[couplings[spouse_oset]].female_reference ;
		names_only( spouse, names, 40, FALSE ) ;
		strcpy( form_addrs.spouse, names ) ;
		cptr = get_cdata_ptr( couplings[spouse_oset], &cblock ) ;
		str_load( form_addrs.wep, cptr->wedding_place ) ;
		blank_field( pers_form.fm_ptr, WEDDING_PLACE, PARTIAL ) ; 
		form_date( form_addrs.wed, form_addrs.wed_qual, cptr->wedding_date, TRUE ) ;

		child = 0 ;
		if( child_ptr = cptr->children )
		{
			while( ( ref = form_ref( &child_ptr ) ) )
			{
				pprog_array[child] = ref ;
				child++ ;
			}
		}
	
		number_children = child ;
		while( child < MAX_CHILDREN )  pprog_array[child++] = 0 ;

		qsort( pprog_array, (size_t) number_children, (size_t) 4,
														child_compare ) ;
	
		pers_form.fm_ptr[CH_SLIDER].ob_y = 0 ;
		if( number_children > 4 )
			pers_form.fm_ptr[CH_SLIDER].ob_height
				= 4 * pers_form.fm_ptr[CH_SLIDERANGE].ob_height / number_children ;
		else  pers_form.fm_ptr[CH_SLIDER].ob_height
				= pers_form.fm_ptr[CH_SLIDERANGE].ob_height ;
		child_oset = 0 ;
		display_children() ;
	}
	else
	{
		names_only( 0, names, 40, FALSE ) ;
		strcpy( form_addrs.spouse, names ) ;
		blank_field( pers_form.fm_ptr, WEDDING_DATE, TOTAL ) ;
		blank_field( pers_form.fm_ptr, WEDDING_PLACE, TOTAL ) ;
		names_only( 0, names, 32, FALSE ) ;
		for( child=0; child<4; child++ )
		{
			strcpy( form_addrs.child[child], names ) ;
			pprog_array[child] = 0 ;
		}
		spouse = 0 ;
		number_children = 0 ;
	}
}


void  display_children( void )
{
	short child = 0 ;
	int chref ;
	char names[2*IDX_NAM_MAX+2] ;	/* temporary holding string			*/

	while( ( chref = pprog_array[child_oset+child] ) && ( child < 4 ) )
	{
		names_only( chref, names, 32, FALSE ) ;
		str_load( form_addrs.child[child], names ) ;
		child++ ;
	}
	names_only( 0, names, 32, FALSE ) ;
	while( child < 4 )
	{
		strcpy( form_addrs.child[child], names ) ;
		child++ ;
	}
}
	
	
	
void  str_load( char *dest, char *source )
{
	if( source )  strcpy( dest, source ) ;
	else  *dest = '\0' ;
}


void  save_person( int reference, short block, Person *pptr )
{
	char *note_ptr ;
	short changed = FALSE ;
	
	save_int( &pptr->reference, reference, &changed ) ;
	str_save( &(pptr->family_name), form_addrs.fam,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	str_save( &(pptr->forenames), form_addrs.fore,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	pptr->sex = *form_addrs.sex ;
	save_date( &(pptr->birth_date), form_addrs.bid, form_addrs.bid_qual, &changed ) ;
	str_save( &(pptr->birth_place), form_addrs.bip,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	str_save( &(pptr->birth_source), form_addrs.bisrc,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;

	str_save( &(pptr->occupation), form_addrs.occ,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;

	save_date( &(pptr->baptism_date), form_addrs.bad, form_addrs.bad_qual, &changed ) ;
	str_save( &(pptr->baptism_place), form_addrs.bap,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	str_save( &(pptr->baptism_source), form_addrs.basrc,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;

	save_date( &(pptr->death_date), form_addrs.ded, form_addrs.ded_qual, &changed ) ;
	str_save( &(pptr->death_place), form_addrs.dep,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	str_save( &(pptr->burial_place), form_addrs.bcp,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	save_date( &(pptr->burial_date), form_addrs.bcd, form_addrs.bcd_qual, &changed ) ;
	str_save( &(pptr->death_source), form_addrs.desrc,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	save_date( &(pptr->will_date), form_addrs.dwd, form_addrs.wid_qual, &changed ) ;
	str_save( &(pptr->will_wit1), form_addrs.dw1,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	str_save( &(pptr->will_wit2), form_addrs.dw2,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	str_save( &(pptr->will_exe1), form_addrs.ex1,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	str_save( &(pptr->will_exe2), form_addrs.ex2,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	str_save( &(pptr->will_sol), form_addrs.sol,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	str_save( &(pptr->will_bens), form_addrs.ben,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	str_save( &(pptr->will_bens2), form_addrs.be2,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	str_save( &(pptr->will_bens3), form_addrs.be3,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;

	if( note_ptr = check_notes() )
		str_save( &(pptr->notes), note_ptr,
		&next_pstring_ptr[block], pblock_end[block], &changed ) ;

	if( latest_flags != pptr->flags )
	{
		pptr->flags = latest_flags ;
		changed = TRUE ;
	}
	
	if( changed )  pblock_changed[block] = TRUE ;

	add_to_pidx( reference, pptr ) ;

	if( reference == next_person )  next_person++ ;
	if( next_person >= p_index_size )
		rsrc_form_alert( 1, P_INDEX_FULL ) ;
		
	if( overflowed )  rsrc_form_alert( 1, BK_FULL ) ;
}	


void  str_save( char **dest_ptr, char *source, char **next_ptr,
									char *block_end, short *changed_ptr )
							/* If dest_ptr already points to a string	*/
							/* and the source string is not too long	*/
							/* overwrite old string. If not set dest	*/
							/* to point to next available space, write	*/
							/* string there and update next space ptr.	*/
{
	char *next_end ;
	short changed = FALSE ;

	if( *dest_ptr == NULL && source[0] != '\0' )  changed = TRUE ;
	else if( *dest_ptr && source[0] == '\0' )
	{
		*dest_ptr = NULL ;
		changed = TRUE ;
	}
	else if( *dest_ptr && source[0] )
		if( strcmp( *dest_ptr, source ) )  changed = TRUE ;

	if( changed )
	{
		if( ( *dest_ptr == NULL ) || ( strlen( *dest_ptr ) < strlen( source ) ) )
		{
			if( !overflowed )
			
			{	next_end = *next_ptr + strlen( source )+1 ; 
				if( next_end > block_end )
				{
					*next_ptr = overflow ;
					overflowed = TRUE ;
				}
			}
			*dest_ptr = *next_ptr ;
			*next_ptr += strlen( source )+1 ;
		}
		strcpy( *dest_ptr, source ) ;
	}

	if( changed )  *changed_ptr = TRUE ;
}


void  save_date( int *dest, char *source, char *qualifier, short *changed_ptr )
{
	int day, month, year ;
	char month_string[4] ;
	int new_date ;
	short i ;					/* loop counter							*/	
	char *ch_ptr ;
	char saved_date_str[DATE_LENGTH] ;	

								/* If date has been displayed with		*/
								/* blanks in unknown day & month		*/
								/* restore to 00xxx0000 format.			*/
	strcpy( saved_date_str, source ) ;
	ch_ptr = source ;
	if( *ch_ptr == ' ' )  *ch_ptr = '0' ;
	if( *(++ch_ptr) == ' ' )
	{
		*ch_ptr = *(ch_ptr-1) ;
		*(ch_ptr-1) = '0' ;
	}

	ch_ptr++ ;
	if( *(ch_ptr) == ' ' && *(ch_ptr+1) == ' ' && *(ch_ptr+2) == ' ' )
	{
		*ch_ptr = 'x' ;
		*(ch_ptr+1) = 'x' ;
		*(ch_ptr+2) = 'x' ;
	}

	if( sscanf( source, "%d%3s%d", &day, month_string, &year ) == 3 )	
	{
		month = 0 ;
		for( i=1; i<=12 && !month; i++ )
		{
			if( stricmp( month_string, months[i]) == 0 )  month = i ;
		}
												/* check for Qtr		*/
		if( stricmp( month_string, months[14]) == 0 )  month = 14 ;	
		new_date = ( year << 9 ) + ( month << 5 ) + day ;
		if( *qualifier == circa_char )  new_date += CIRCA_CODE ;
		else if( *qualifier == before_char )  new_date += BEFORE_CODE ;
		else if( *qualifier == after_char )  new_date += AFTER_CODE ;
	}
	else  new_date = 0 ;
	if( *dest != new_date )
	{
		*dest = new_date ;
		*changed_ptr = TRUE ;
	}
	strcpy( source, saved_date_str ) ;
}


short  form_flags( void )
{
	short flags_val = 0 ;
	short i, flag_bit = 1 ;

	for( i = 0 ; i <= FL_YES8 - FL_YES1 ; i += FL_YES2 - FL_YES1 )
	{
		if( flags_ptr[FL_NO1 + i].ob_state & SELECTED )
			flags_val |= flag_bit ;
		flag_bit <<= 1 ;
		if( flags_ptr[FL_YES1 + i].ob_state & SELECTED )
			flags_val |= flag_bit ;
		flag_bit <<= 1 ;
	}
	
	return flags_val ;
}


void  set_form_flags( short flags_val )
{
	short i, flag_bit = 1 ;
	
	clear_form_flags() ;
	
	for( i = 0 ; i <= FL_YES8 - FL_YES1 ; i += FL_YES2 - FL_YES1 )
	{
		if( flags_val & (flag_bit << 1) )
			flags_ptr[FL_YES1 + i].ob_state |= SELECTED ;
		else if( flags_val & flag_bit )
			flags_ptr[FL_NO1 + i].ob_state |= SELECTED ;
		else  flags_ptr[FL_NOT1 + i].ob_state |= SELECTED ;
		flag_bit <<= 2 ;
	}
}


void  clear_form_flags( void )
{
	short i ;

	for( i = 0; i <= ( FL_YES8 - FL_YES1 ) ; i += ( FL_YES2 - FL_YES1 ) )
	{
		flags_ptr[FL_YES1 + i].ob_state &= ~SELECTED ;
		flags_ptr[FL_NO1 + i].ob_state &= ~SELECTED ;
		flags_ptr[FL_NOT1 + i].ob_state &= ~SELECTED ;
	}
}

	
void  add_to_pidx( int ref, Person *pptr )
{
	short i ;				/* loop counter								*/
	short shortened = FALSE ;	/* flag for end of first name shortened	*/
	char fname[IDX_NAM_MAX+1] ;
	char buffer[100] ;
			
	if( pptr->family_name )
	{
		if( strcmp( people[ref].family_name, pptr->family_name ) )
		{
			strncpy( buffer, pptr->family_name, IDX_NAM_MAX ) ;
							/* Ensure name is terminated and not more	*/
							/* than IDX_NAM_MAX characters long.		*/
			buffer[IDX_NAM_MAX] = '\0' ;
							/* Remove trailing spaces					*/
			if( buffer[0] )  remove_surrounding_spaces( buffer, TRAILING ) ;

			strcpy( people[ref].family_name, buffer ) ;

			pidx_changed = TRUE ;
		}
	}
	else if( people[ref].family_name[0] != '\0' )
	{
		people[ref].family_name[0] = '\0' ;
		pidx_changed = TRUE ;
	} 

	if( pptr->forenames )
	{
		strncpy( fname, pptr->forenames, IDX_NAM_MAX ) ;
							/* Ensure name is terminated and not more	*/
							/* than IDX_NAM_MAX characters long.		*/
		if( strlen( pptr->forenames ) > IDX_NAM_MAX )
		{
			i = IDX_NAM_MAX ;
			while( i>0 && ( !shortened || fname[i] == ' ' ) )
			{
				if( fname[i] == ' ' )
				{
					fname[i] = '\0' ;
					shortened = TRUE ;
				}
				i-- ;
			}
		}
		fname[IDX_NAM_MAX] = '\0' ;
	}
	else  fname[0] = '\0' ;

	if( strcmp( people[ref].forename, fname ) )
	{
		strcpy( people[ref].forename, fname ) ;
		pidx_changed = TRUE ;
	}

	if( people[ref].birth_date != pptr->birth_date )
	{
		people[ref].birth_date = pptr->birth_date ;
		pidx_changed = TRUE ;
	}

	if( people[ref].flags != pptr->flags )
	{
		people[ref].flags = pptr->flags ;
		pidx_changed = TRUE ;
	}
}


void	blank_field( OBJECT *obj_ptr, int object, short extent )
							/* This routine blanks the remainder of a	*/
							/* field. If the field is empty it blanks	*/
							/* it all. If extent is TOTAL blank from	*/
							/* start of field.							*/
{
	short length ;
	char *text_ptr ;

	length = ( (TEDINFO *)obj_ptr[object].ob_spec)->te_txtlen ;
	text_ptr = ( (TEDINFO *)obj_ptr[object].ob_spec)->te_ptext ;
	
	if( extent == PARTIAL )		/* find end of string, put spaces after	*/
	{
		while( *text_ptr++ )  length-- ;
		text_ptr-- ;
	}
	
	while( --length )  *text_ptr++ = ' ' ;	
	*text_ptr = '\0' ;
}


short  q_delete_person( int ref )
{
	Person *pptr ;
	short blk ;
	short deleted = FALSE ;
	
	pptr = get_pdata_ptr( ref, &blk ) ;
	if( pptr->couplings )
		rsrc_form_alert( 1, M_RELATED ) ;
	else if( pptr->parents )
		rsrc_form_alert( 1, C_RELATED ) ;
	else
	{
		if( rsrc_form_alert( 2, SURE_DELETE ) == 1 )
		{
			if( ref != next_person )  delete_person( ref ) ;
			deleted = TRUE ;
		}
	}
	return deleted ;
}
