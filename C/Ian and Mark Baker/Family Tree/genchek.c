/************************************************************************/
/*																		*/
/*		Genchek.c	 22 Jan 01											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "genchek.h"
#include "genutil.h"
#include "gendata.h"

extern Index_person *people ;
extern Index_couple *couples ;

extern char save_directory[FNSIZE+FMSIZE] ;
extern int next_person, next_couple ;

OBJECT *errors_ptr ;

int person ;


void  check_data( void )
{
	int /*person, */couple ;
	FILE *error_fp ;
	char error_file[FNSIZE+FMSIZE] ;
	short errors_found = FALSE ;
	
	sprintf( error_file, "%s\\errors.gen", save_directory ) ;
	error_fp = fopen( error_file, "w" ) ;
	fclose( error_fp ) ;

	for( person = 1; person < next_person; person++ )
		if( !check_person( person, error_file ) )  errors_found = TRUE ;
	for( couple = 1; couple < next_couple; couple++ )
		if( !check_couple( couple, error_file ) )  errors_found = TRUE ;
	
	if( errors_found )  rsrc_form_alert( 1, CHECK_ERRORS ) ;
	else  rsrc_form_alert( 1, CHECK_OK ) ;
}


short  check_person( int person, char *error_file )
{
	Person *pptr ;
	Couple *cptr ;
	short block ;
	int couple, child ;
	char *chptr, *coupptr ;
	short index_error = FALSE ;
	short invalid_parents = FALSE ;
	short parents_checked = FALSE ;
	short coupling_error = FALSE ;
	short deletion_error = FALSE ;
	FILE *error_fp ;

	pptr = get_pdata_ptr( person, &block ) ;
	if( -1 != people[person].birth_date )	/* Check if person not deleted	*/
	{
									/* check index data matches person data	*/
		if( pptr->family_name )
		{
			if( strcmp( people[person].family_name, pptr->family_name ) )
			index_error = TRUE ;
		}
		else if( people[person].family_name[0] != '\0' )
			index_error = TRUE ;

		if( pptr->forenames )
		{
			if( strncmp( people[person].forename, pptr->forenames,
					(size_t) min( IDX_NAM_MAX+2,strlen( people[person].forename ) ) ) )
			index_error = TRUE ;
		}
		else if( people[person].forename[0] != '\0' )
			index_error = TRUE ;

		if( people[person].birth_date != pptr->birth_date )
			index_error = TRUE ;
		if( people[person].flags != pptr->flags )
			index_error = TRUE ;

									/* check parents						*/
		if( couple = pptr->parents, couple )
		{
			if( couple < 0 || couple > next_couple )
				invalid_parents = TRUE ;
			else
			{
				cptr = get_cdata_ptr( couple, &block ) ;
				if( chptr = cptr->children, chptr )
				{
					while( child = form_ref( &chptr ) )
					{
						if( child == person )  parents_checked = TRUE ;
					}
				}
			}
		}
		else  parents_checked = TRUE ;	/* by default, nothing to check	*/

									/* check couplings						*/
		if( coupptr = pptr->couplings, coupptr )
		{
			while( couple = form_ref( &coupptr ) )
			{
				if( couples[couple].male_reference != person
						&& couples[couple].female_reference != person )
					coupling_error = TRUE ;
			}
		}

	}
	else
	{
		if( pptr->parents || pptr->couplings )  deletion_error = TRUE ;
		parents_checked = TRUE ;		/* by default, nothing to check	*/
	}
	
	if( index_error || !parents_checked || coupling_error || deletion_error )
	{
		error_fp = fopen( error_file, "a" ) ;

		fprintf( error_fp, "\n%s %d\n",
					 (char *)errors_ptr[PERSON_ERRORS].ob_spec, person ) ;
		if( index_error )
			fprintf( error_fp, "%s\n",
			 					(char *)errors_ptr[P_IDX_ERROR].ob_spec ) ;
		if( invalid_parents )
			fprintf( error_fp, "%\n",
			 					(char *)errors_ptr[P_P_INVALID].ob_spec ) ;
		if( !parents_checked )
			fprintf( error_fp, "%s\n",
			 					(char *)errors_ptr[P_PAR_ERROR].ob_spec ) ;
		if( coupling_error )
			fprintf( error_fp, "%s\n",
			 					(char *)errors_ptr[P_COUP_ERROR].ob_spec ) ;
		if( deletion_error )
			fprintf( error_fp, "%s\n",
			 					(char *)errors_ptr[P_DEL_ERROR].ob_spec ) ;
		fclose( error_fp ) ;
		
		return FALSE ;
	}

	else
		return TRUE ;
}


short  check_couple( int couple, char *error_file )
{
	Couple *cptr ;
	Person *pptr ;
	short block ;
	int child ;
	int male, female ;
	int male_birth, female_birth, wedding_date ;
	char *chptr ;
	short deleted = FALSE ;
	short index_error = FALSE ;
	short invalid_child = FALSE ;
	short child_error = FALSE ;
	FILE *error_fp ;

	cptr = get_cdata_ptr( couple, &block ) ;
	
									/* check index data matches couple data	*/
	if( couples[couple].male_reference != cptr->male_reference
			|| couples[couple].female_reference != cptr->female_reference )
	{
		if( coupling_confirmed( couples[couple].male_reference, couple )
			|| coupling_confirmed( cptr->male_reference, couple )
			|| coupling_confirmed( couples[couple].female_reference, couple )
			|| coupling_confirmed( cptr->female_reference, couple )
			|| cptr->children )
		{
			index_error = TRUE ;
		}
		else			/* assume deleted couple and tidy up		*/
		{
			deleted = TRUE ;
			couples[couple].male_reference = 0 ;
			cptr->male_reference = 0 ;
			couples[couple].female_reference = 0 ;
			cptr->female_reference = 0 ;
		}
	}
	
	wedding_date = couples[couple].wedding_date ;
	
	if( !deleted && wedding_date != cptr->wedding_date )
	{
									/* early software may have produced		*/
									/* silly dates in index, simply set		*/
									/* these to blank, i.e. 0.				*/
									/* These occur when no date set for		*/
									/* wedding and can be huge, small or	*/
									/* negative. If they happen to be in	*/
									/* the range of possible dates they are	*/
									/* not assumed silly, and an error will	*/
									/* be reported.							*/
		if( male = couples[couple].male_reference, male )
			male_birth = people[male].birth_date ;
		else  male_birth = 0 ;
		if( female = couples[couple].female_reference, female )
			female_birth = people[female].birth_date ;
		else  female_birth = 0 ;
		
		if( 0 == cptr->wedding_date
			&&( wedding_date < male_birth || wedding_date < female_birth
				|| male_birth && wedding_date > male_birth + MAX_AGE
				|| female_birth && wedding_date > female_birth + MAX_AGE
				|| !male_birth && !female_birth && wedding_date > FAR_FUTURE ) )
		{
			couples[couple].wedding_date = 0 ;
		}
		else  index_error = TRUE ;
	}

									/* check children						*/
	if( chptr = cptr->children, !deleted && chptr )
	{
		while( child = form_ref( &chptr ), child )
		{
			if( child < 0 || child >= next_person )
				invalid_child = TRUE ;
			else
			{
				pptr = get_pdata_ptr( child, &block ) ;
				if( pptr->parents != couple )  child_error = TRUE ;
			}
		}
	}

	if( index_error || invalid_child || child_error )
	{
		error_fp = fopen( error_file, "a" ) ;

		fprintf( error_fp, "\n%s %d\n",
					 (char *)errors_ptr[COUPLE_ERRORS].ob_spec, couple ) ;
		if( index_error )
			fprintf( error_fp, "%s\n",
			 					(char *)errors_ptr[C_IDX_ERROR].ob_spec ) ;
		if( invalid_child )
			fprintf( error_fp, "%s\n",
			 					(char *)errors_ptr[C_C_INVALID].ob_spec ) ;
		if( child_error )
			fprintf( error_fp, "%s\n",
			 					(char *)errors_ptr[C_CHILD_ERROR].ob_spec ) ;
		fclose( error_fp ) ;
		
		return FALSE ;
	}
	else  return TRUE ;
}


short coupling_confirmed( int person, int couple )
{
	Person *pptr ;
	char *coupptr ;
	int check_couple ;
	short block ;
	short coupling_confirmed = FALSE ;
	
	pptr = get_pdata_ptr( couples[couple].male_reference, &block ) ;
	if( coupptr = pptr->couplings, coupptr )
	{
		while( check_couple = form_ref( &coupptr ) )
		{
			if( check_couple == couple )  coupling_confirmed = TRUE ;
		}
	}
	return coupling_confirmed ;
}
					
