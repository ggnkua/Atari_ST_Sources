/************************************************************************/
/*																		*/
/*		Genpprn.c	 5 Dec 99											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"
#endif

#include "genhd.h"
#include "genpprn.h"
#include "genutil.h"
#include "gendata.h"
#include "genfoot.h"
#include "genprnt.h"
#include "genpsel.h"
#include "gentprn.h"

extern int ap_id ;					/* global application identifier	*/

extern int *matches ;				/* array of matching people			*/
extern int entries ;				/* number of matching people found	*/

extern Index_person *people ;
extern Index_couple *couples ;
extern int next_person ;
extern Wind_edit_params pers_form, birth_form, baptism_form, death_form ;
extern Wind_edit_params coup_form, co_src_form, divorce_form ;
extern OBJECT *flags_ptr ;

extern int *job_ptr ;

extern short scr_handle ;			/* GEM vdi handle used by AES		*/

extern short printer_lines ;		/* maximum lines for printout		*/
// extern short printer_chars ;		/* maximum characters for printout	*/
// extern short printer_x_offset ;		/* std printer left margin			*/
// extern short printer_y_offset ;		/* std printer top margin			*/
// extern short printer_type  ;		/* std printer, GDOS or to file		*/
// extern short page_pause ;			/* pause between pages flag			*/
// extern short gdos_page_pause ;		/* pause between pages flag			*/
// extern short file_chars ;			/* maximum chars for file printout	*/
// extern short file_x_offset ;		/* file print left margin			*/
// extern short printer_device_number ;	/* GDOS device number			*/
extern short device_type ;			/* device type set in v_opnwk		*/

extern struct
{
	char *fl[8] ;
} flags_addrs ;
extern short print_flags ;			/* bits 7-0 enable printing of		*/
									/* custom flags						*/

extern FONTINFO fontinfo, largefont ;

OBJECT *range_ptr ;


void  print_people( int ref )
{
	int reference ;					/* person selected for printing		*/
	char *alert_ptr, alert_str[200] ;
	short i, count = 0 ;
	Str_prt_params params ;
	
	while( !count )
	{
		if( !ref )
		{
			reference =  get_person_reference( NULL, TRUE ) ;
			if( !reference )  return ;		/* exit if nobody selected	*/

			count = entries ;	/* entries is number of people selected	*/
			if( count > 1 )
			{
				rsrc_gaddr( R_STRING, PRINT_MANY, &alert_ptr ) ;
				sprintf( alert_str, alert_ptr, count ) ;
				if( form_alert( 0, alert_str ) == 2 )  count = 0 ;
			}
		}
		else
		{
			matches[0] = ref ;	/* force selector list					*/
			count = 1 ;
		}	

		if( count )
		{
			if( open_printer( &params ) )
			{
				params.ref2 = 0 ;		/* Do not print second reference.	*/
				
				if( params.use_gdos )
					setup_font( &params, fontinfo ) ;

				if( params.chs_across < 40 )
				{
					rsrc_gaddr( R_STRING, GROSS_FONT, &alert_ptr ) ;
					rsrc_form_alert( 1, GROSS_FONT ) ;
				}
				else
				{
					busy( BUSY_MORE ) ;
			
					start_print_checking( &params ) ;

					i = 0 ;
					while(  printing_ok( &params ) && ( reference = matches[i++] ) )
						print_person( reference, &params ) ;

					close_printer( &params ) ;
					busy( BUSY_LESS ) ;
				}
			}
		}
	}
}


void  print_person( int reference, Str_prt_params *ps_ptr )
{
	Person *pptr ;
	Couple *cptr ;
	short cblk ;						/* block number					*/
	int coup, father, mother, ch, spouse ;
										/* references					*/
	char *ch_ptr ;						/* ptr to array of child refs	*/
	char *coupls_ptr ;					/* ptr to array of couplings	*/
	short first_ch ;					/* flag to print "sibling" or	*/
										/* "children" before first one	*/
	char temp_str[100] ;
	short dist_down ;
	short dummy ;
	short omit_baptism_details = TRUE ;
	short omit_will_details = TRUE ;
	short omit_death_details = TRUE ;
	short omit_wed_details ;
	short omit_divorce_details ;
	short i ;

	busy( BUSY_MORE ) ;
	pptr = get_pdata_ptr( reference, &dummy ) ;
	ps_ptr->ref1 = reference ;
	
	if( ps_ptr->use_gdos )
		setup_font( ps_ptr, largefont ) ;

	ps_ptr->last_x_end = 0 ;
	ps_ptr->y_pos = 0 ;
	ps_ptr->downlines = 1 ;
	ps_ptr->tabpos = 0 ;
	sprintf( temp_str, "%s    %s", pptr->forenames, pptr->family_name ) ;
	ps_ptr->align = RIGHT ;
	ps_ptr->x_pos = ps_ptr->chs_across ;
	print_str( NULL, 0, temp_str, 0, ps_ptr ) ;
	ps_ptr->align = RIGHT ;
	ps_ptr->x_pos = ps_ptr->chs_across ;
	ps_ptr->tabpos = 0 ;
	print_int( NULL, 0, pptr->reference, 0, ps_ptr ) ;

	dist_down = ps_ptr->y_pos * ps_ptr->cell_height ;
	if( ps_ptr->use_gdos )  setup_font( ps_ptr, fontinfo ) ;
	ps_ptr->y_pos = ( dist_down + ps_ptr->cell_height - 1 ) 
													/ ps_ptr->cell_height ;
	ps_ptr->align = LEFT_WRAP ;
	ps_ptr->x_pos = 0 ;
	ps_ptr->max_len = 0 ;
	ps_ptr->last_x_end = 0 ;
	ps_ptr->tabpos = 28 ;	
	print_date( pers_form.fm_ptr, BIRTH_SOURCE, pptr->birth_date, 0, ps_ptr ) ;

//	ps_ptr->align = LEFT_WRAP ;
	ps_ptr->x_pos = 4 ;
	ps_ptr->tabpos = 24 ;
	print_str( pers_form.fm_ptr, BIRTH_PLACE, pptr->birth_place, 1, ps_ptr ) ;

//	ps_ptr->align = LEFT_WRAP ;
	ps_ptr->x_pos = 4 ;
	ps_ptr->tabpos = 24 ;
//	ps_ptr->downlines = 1 ;
	print_str( birth_form.fm_ptr, BI_SOURCE_TITLE, pptr->birth_source, 1, ps_ptr ) ;

	if( pptr->occupation )  down_n_lines( 1, ps_ptr ) ;

	ps_ptr->x_pos = 0 ;
	ps_ptr->tabpos = 28 ;
	print_str( pers_form.fm_ptr, OCCUPATION, pptr->occupation, 1, ps_ptr ) ;

	down_n_lines( 1, ps_ptr ) ;

	if( coup = pptr->parents )
	{
		father = couples[coup].male_reference ;
		names_ref( father, temp_str, 40, FALSE ) ;
											/* format names into string	*/
		ps_ptr->x_pos = 0 ;
		ps_ptr->tabpos = 28 ;
		print_str( pers_form.fm_ptr, FATHER, temp_str, 0, ps_ptr ) ;
		mother = couples[coup].female_reference ;
		names_ref( mother, temp_str, 40, FALSE ) ;
											/* format names into string	*/
		print_str( pers_form.fm_ptr, MOTHER, temp_str, 0, ps_ptr ) ;

		cptr = get_cdata_ptr( coup, &cblk ) ;
		if( ch_ptr = cptr->children )
		{
			first_ch = TRUE ;
			while( ch = form_ref( &ch_ptr ) )
			{
				if( ch != reference )
				{
					if( first_ch )
					{
						first_ch = FALSE ;
						ps_ptr->x_pos = 4 ;
						ps_ptr->tabpos = 0 ;
						print_str( pers_form.fm_ptr, SIB_STRING, NULL, 0, ps_ptr ) ;
						ps_ptr->x_pos = 28 ;
					}
					names_ref( ch, temp_str, 40, FALSE ) ;
					print_str( NULL, 0, temp_str, 0, ps_ptr ) ;
				}
			}
		}
		if( ps_ptr->y_pos < printer_lines )  down_n_lines( 1, ps_ptr ) ;
	}

	if( pptr->baptism_date || pptr->baptism_place || pptr->baptism_source )
		omit_baptism_details = FALSE ;
	ps_ptr->x_pos = 0 ;
	ps_ptr->tabpos = 28 ;
	print_date( pers_form.fm_ptr, BAPTISM, pptr->baptism_date,
										omit_baptism_details, ps_ptr ) ;
	ps_ptr->x_pos = 4 ;
	ps_ptr->tabpos = 24 ;
	print_str( baptism_form.fm_ptr, BA_PLACE, pptr->baptism_place, 1, ps_ptr ) ;
	print_str( baptism_form.fm_ptr, BA_SOURCE, pptr->baptism_source, 1, ps_ptr ) ;
	if( !omit_baptism_details )
		if( ps_ptr->y_pos < printer_lines )  down_n_lines( 1, ps_ptr ) ;
	
	if( coupls_ptr = pptr->couplings )
	{
		while( coup = form_ref( &coupls_ptr ) )
		{
			omit_wed_details = TRUE ;
			omit_divorce_details = TRUE ;

			cptr = get_cdata_ptr( coup, &cblk ) ;
			if( cptr->male_reference == reference )
				spouse = cptr->female_reference ;
			else  spouse = cptr->male_reference ;
			names_ref( spouse, temp_str, 40, FALSE ) ;
			ps_ptr->x_pos = 0 ;
			ps_ptr->tabpos = 28 ;
			print_str( pers_form.fm_ptr, SPOUSE, temp_str, 0, ps_ptr ) ;
			
			if( cptr->wedding_date || cptr->wedding_place || cptr->wedding_place
									|| cptr->wedd_wit1 || cptr->wedd_wit2 )
				omit_wed_details = FALSE ;
			ps_ptr->x_pos = 4 ;
			ps_ptr->tabpos = 24 ;
			print_date( coup_form.fm_ptr, C_SOURCE, cptr->wedding_date,
				omit_wed_details, ps_ptr ) ;
			print_str( coup_form.fm_ptr, W_PLACE, cptr->wedding_place, 1, ps_ptr ) ;			
			print_str( co_src_form.fm_ptr, W_SOURCE, cptr->wedding_source, 1, ps_ptr ) ;	
			ps_ptr->x_pos = 8 ;
			ps_ptr->tabpos = 20 ;
			print_str( co_src_form.fm_ptr, WWIT1, cptr->wedd_wit1, 1, ps_ptr ) ;
			print_str( co_src_form.fm_ptr, WWIT2, cptr->wedd_wit2, 1, ps_ptr ) ;
			
			if( cptr->divorce_date || cptr->divorce_source )
				omit_divorce_details = FALSE ;
				
			ps_ptr->x_pos = 4 ;
			ps_ptr->tabpos = 24 ;
			print_date( coup_form.fm_ptr, C_DIVORCE, cptr->divorce_date,
				omit_divorce_details, ps_ptr ) ;
			ps_ptr->x_pos = 8 ;
			ps_ptr->tabpos = 20 ;
			print_str( divorce_form.fm_ptr, DI_SOURCE_TITLE, cptr->divorce_source, 1, ps_ptr ) ;					
			
			if( ch_ptr = cptr->children )
			{
				first_ch = TRUE ;
				while( ch = form_ref( &ch_ptr ) )
				{
					if( first_ch )
					{
						first_ch = FALSE ;
						ps_ptr->x_pos = 4 ;
						ps_ptr->tabpos = 0 ;
						print_str( pers_form.fm_ptr, CH_STRING, NULL, 0, ps_ptr ) ;
						ps_ptr->x_pos = 28 ;
					}
					names_ref( ch, temp_str, 40, FALSE ) ;
					print_str( NULL, 0, temp_str, 0, ps_ptr ) ;
				}
			}
			if( ps_ptr->y_pos < printer_lines )  down_n_lines( 1, ps_ptr ) ;
		}
	}

	if( pptr->will_date || pptr->will_wit1 || pptr->will_wit2
			|| pptr->will_exe1 || pptr->will_exe2
			|| pptr->will_sol || pptr->will_bens
			|| pptr->will_bens2 || pptr->will_bens3 )
			omit_will_details = FALSE ;
	if( pptr->death_date || pptr->death_place || pptr->death_source
			|| pptr->burial_date || pptr->burial_place || !omit_will_details )
		omit_death_details = FALSE ;
	ps_ptr->x_pos = 0 ;
	ps_ptr->tabpos = 28 ;
	print_date( pers_form.fm_ptr, DEATH, pptr->death_date,
										omit_death_details, ps_ptr ) ;
	ps_ptr->x_pos = 4 ;
	ps_ptr->tabpos = 24 ;
	print_str( death_form.fm_ptr, D_PLACE, pptr->death_place, 1, ps_ptr ) ;
	print_str( death_form.fm_ptr, BC_PLACE, pptr->burial_place, 1, ps_ptr ) ;
	print_date( death_form.fm_ptr, BCDATE, pptr->burial_date, 1, ps_ptr ) ;
	print_str( death_form.fm_ptr, D_SOURCE, pptr->death_source, 1, ps_ptr ) ;

	print_date( death_form.fm_ptr, D_WILL, pptr->will_date, omit_will_details,
																ps_ptr ) ;
	ps_ptr->x_pos = 8 ;
	ps_ptr->tabpos = 20 ;
	print_str( death_form.fm_ptr, DWIT1, pptr->will_wit1, 1, ps_ptr ) ;
	print_str( death_form.fm_ptr, DWIT2, pptr->will_wit2, 1, ps_ptr ) ;
	print_str( death_form.fm_ptr, EXEC1, pptr->will_exe1, 1, ps_ptr ) ;
	print_str( death_form.fm_ptr, EXEC2, pptr->will_exe2, 1, ps_ptr ) ;
	print_str( death_form.fm_ptr, SOLIC, pptr->will_sol, 1, ps_ptr ) ;
	print_str( death_form.fm_ptr, BENEF, pptr->will_bens, 1, ps_ptr ) ;
	print_str( death_form.fm_ptr, BENEF2, pptr->will_bens2, 1, ps_ptr ) ;
	print_str( death_form.fm_ptr, BENEF3, pptr->will_bens3, 1, ps_ptr ) ;

	ps_ptr->x_pos = 4 ;
	ps_ptr->tabpos = 24 ;
	for( i=7; i>=0; i-- )  print_flag( i, pptr->flags, ps_ptr ) ;
	
	if( pptr->notes )
	{
		ps_ptr->tabpos = 0 ;
		ps_ptr->x_pos = 0 ;
//		ps_ptr->downlines = 1 ;
		ps_ptr->align = LEFT ;
		
		print_str( NULL, 0, NULL, 0, ps_ptr ) ;
		
		ps_ptr->downlines = 2 ;
		
		print_str( pers_form.fm_ptr, NOTES, NULL, 0, ps_ptr ) ;
	
		print_notes_indented( pptr, ps_ptr ) ;
	}

	end_page( ps_ptr, FALSE ) ;
	busy( BUSY_LESS ) ;
}


void  print_flag( short flag_num, short flags, Str_prt_params *ps_ptr )
{
	short shift ;
	char *str_ptr ;

	shift = 2 * flag_num ;
	if( print_flags & ( 1 << shift ) )
	{
		if( flags & ( 3 << shift ) )
		{
			if( flags & ( 2 << shift ) )
				str_ptr = flags_ptr[FL_YES1].ob_spec ;
			else  str_ptr = flags_ptr[FL_NO1].ob_spec ;
			printout_strings( flags_addrs.fl[flag_num], str_ptr, ps_ptr ) ;
		}
	}
}



void  print_notes( char *notes, Str_prt_params *ps_ptr )
{
	char *next_line, *not_ptr, *space_ptr ;
	char ch ;							/* temporary character			*/
	short done = FALSE ;
	short print_so_far = FALSE ;
	short max_len, just_len ;
	
			/* ps_ptr->max_len non-zero allows fully justified text.	*/
			/* This routine sets it to just_len when it should be fully	*/
			/* justified, i.e. in "print_so_far". Just_len is set to	*/
			/* max_len normally, but if printing to a Metafile it is	*/
			/* set to zero. This is because neither Papyrus nor			*/
			/* Kandinsky will print fully justified lines although they	*/
			/* display them.											*/
			
	max_len = ps_ptr->max_len ;

	if( METAFILE == device_type )  just_len = 0 ;
	else  just_len = max_len ;

	ps_ptr->downlines = 1 ;
	
	next_line = notes ;
	
	not_ptr = next_line ;
	space_ptr = NULL ;		/* Initialise to no space found.	*/
	
	while( !done )
	{	
		while( ch = *not_ptr, ch && ch != ' ' && ch != 0x0D )
			not_ptr++ ;
		if( ch == ' ' )
		{	
			*not_ptr = '\0' ;
			if( line_fits( next_line, ps_ptr ) )
			{
				space_ptr = not_ptr ;
				*not_ptr++ = ch ;
			}
			else  print_so_far = TRUE ;
		}
		if( ch == '\0' )
		{
			if( '\0' == next_line[0] )  done = TRUE ;
			else if( line_fits( next_line, ps_ptr ) )
			{	
				ps_ptr->max_len = 0 ;
				printout_strings( next_line, NULL, ps_ptr ) ;
				ps_ptr->max_len = max_len ;

				done = TRUE ;
			}
			else
			{
				print_so_far = TRUE ;
			}
		}
	
		if( ch == 0x0D )
		{
			*not_ptr = '\0' ;
			if( line_fits( next_line, ps_ptr ) )
			{	
				ps_ptr->max_len = 0 ;
				printout_strings( next_line, NULL, ps_ptr ) ;
				ps_ptr->max_len = max_len ;

				*not_ptr++ = ch ;
				next_line = not_ptr ;
			}
			else  print_so_far = TRUE ;
		}

		if( print_so_far )
		{	
			print_so_far = FALSE ;
			if( space_ptr )  *space_ptr = '\0' ;
			else
			{
				while( !line_fits( next_line, ps_ptr ) )
				{
					*not_ptr = ch ;
					ch = *--not_ptr ;
					*not_ptr = '\0' ;
				}
			}
			ps_ptr->max_len = just_len ;
			printout_strings( next_line, NULL, ps_ptr ) ;
			ps_ptr->max_len = max_len ;

			*not_ptr = ch ;
			if( space_ptr )
			{
				*space_ptr = ' ' ;
				not_ptr = space_ptr + 1 ;
			}
			next_line = not_ptr ;
			space_ptr = NULL ;
		}
	}
	ps_ptr->max_len = 0 ;
}


void  print_notes_indented( Person *pptr, Str_prt_params *ps_ptr )
{
	short old_max_len ;
	
	old_max_len = ps_ptr->max_len ;
	
	ps_ptr->x_pos = ps_ptr->chs_across / 10 ;
	ps_ptr->max_len = 4 * ps_ptr->chs_across / 5 ;

	print_notes( pptr->notes, ps_ptr ) ;
	
	ps_ptr->max_len = old_max_len ;
}


void  print_index( void )
{
	int ref ;
	short print_all = FALSE ;
	short print_list = FALSE ;
	Str_prt_params params ;
	short i ;
	char *start_str, *end_str ;
	int start_index, end_index ;
	short button ;

	if( rsrc_form_alert( 0, PRINT_ALL ) == 1 )
		print_all = TRUE ;
	else if( ref = get_person_reference( NULL, TRUE ) )
		print_list = TRUE ;
	if( !print_all && !print_list )  return ;
	
	if( open_printer( &params ) )
	{	
		params.ref1 = 0 ;			/* Do not print references.	*/
		params.ref2 = 0 ;


		params.align = LEFT ;		/* printout alignment				*/
		params.max_len = 0 ;		/* maximum length in character widths	*/
		params.last_x_end = 0 ;
		params.y_pos = 0 ;
		params.tabpos = 0 ;		/* relative position of second string	*/
		
		if( print_all )
		{	
			start_str = FORM_TEXT( range_ptr, START_INDEX ) ;
			end_str = FORM_TEXT( range_ptr, END_INDEX ) ;
			sprintf( start_str, "%d", 1 ) ;
			sprintf( end_str, "%d", next_person - 1 ) ;

			app_modal_init( range_ptr, "", TITLED ) ;
			button = app_modal_do() ;
			if( button != APP_MODAL_TERM )
			{
				range_ptr[INDEX_RANGE_OK].ob_state &= ~SELECTED ;

				start_index = atoi( start_str ) ;
				end_index = atoi( end_str ) ;
			}
			app_modal_end() ;
			
			if( button != APP_MODAL_TERM )
			{
				if( start_index < 1 || end_index > next_person - 1
											|| end_index < start_index )
					rsrc_form_alert( 1, INVALID_RANGE ) ;
				else
				{
					busy( BUSY_MORE ) ;

					start_print_checking( &params ) ;
	
					for( i=start_index;  printing_ok( &params ) && i<=end_index; i++ )
						if( people[i].birth_date != DELETED_DATE )
						print_idx_person( i, &params ) ;
					busy( BUSY_LESS ) ;
				}
			}
		}
		else if( print_list )
		{	
			busy( BUSY_MORE ) ;

			start_print_checking( &params ) ;
	
			i = 0 ;
			while(  printing_ok( &params ) && ( ref = matches[i++] ) )
				print_idx_person( ref, &params ) ;
			busy( BUSY_LESS ) ;
		}
	
		end_page( &params, FALSE ) ;
		close_printer( &params ) ;
	}
}
		

void  print_idx_person( int ref, Str_prt_params *ps_ptr )
{
	char ref_str[9] ;
	char names[2*IDX_NAM_MAX+2] ;
	char qualifier ;

	sprintf( ref_str, "%d", ref ) ;
	ps_ptr->x_pos = 7 ;
	ps_ptr->align = RIGHT ;
	ps_ptr->downlines = 0 ;		/* lines down to next print				*/
	printout_strings( ref_str, NULL, ps_ptr ) ;

	names_only( ref, names, 40, FALSE ) ;
	ps_ptr->x_pos = 10 ;
	ps_ptr->align = LEFT ;
	printout_strings( names, NULL, ps_ptr ) ;

	form_date( names, &qualifier, people[ref].birth_date, FALSE ) ;
	if( qualifier != ' ' )
	{
		names[0] = qualifier ;
		form_date( names+1, &qualifier, people[ref].birth_date, FALSE ) ;
	}
	ps_ptr->x_pos = 60 ;
	ps_ptr->align = RIGHT ;
	ps_ptr->downlines = 1 ;
	printout_strings( names, NULL, ps_ptr ) ;
}

