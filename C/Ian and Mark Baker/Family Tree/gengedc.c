/************************************************************************/
/*																		*/
/*		Gengedc.c	 5 May 99											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "genutil.h"
#include "gengedc.h"
#include "gencoup.h"
#include "gendata.h"
#include "genfile.h"
#include "genmain.h"
#include "genmerg.h"
#include "genpers.h"
#include "genpref.h"

extern char Version[] ;
extern char transfer_file[FNSIZE+FMSIZE] ;

extern Index_person* people ;
extern Index_couple* couples ;
extern int next_person, next_couple ;
extern char* edit_buffer ;

extern short pblock_changed[MAX_PEOPLE_BLOCKS] ;
extern short cblock_changed[MAX_COUPLES_BLOCKS] ;
extern char* next_pstring_ptr[MAX_PEOPLE_BLOCKS] ;
extern char* next_cstring_ptr[MAX_COUPLES_BLOCKS] ;
extern char* pblock_end[MAX_PEOPLE_BLOCKS] ;
extern char* cblock_end[MAX_COUPLES_BLOCKS] ;

extern int* pcross_refs ;
extern int* ccross_refs ;
extern int total_people ;		/* total people to be loaded from file	*/
extern int total_couples ;		/* total couples to be loaded from file	*/

extern Preferences prefs ;

const char* const doterr = ".ERR" ;
								/* GEDCOM specific file data	*/
const char ibm_char_set[6] = "IBMPC" ;
const char this_program[18] = "ATARI_FAMILY_TREE" ;	/* must be same as SOUR below	*/
const char* const header_part1 = "0 HEAD\n"
						 		"1 SOUR ATARI_FAMILY_TREE\n"
								"2 VERS %s\n"
								"2 CORP Ian & Mark Baker\n"
								"3 ADDR 256 Lower Road\n"
								"4 CONT Great Bookham\n"
								"4 CONT Surrey  KT23 4DL\n"
								"4 CONT England\n"
								"1 DEST %s\n" ;
const char* const header_part2 = "1 FILE %s\n"
								"1 GEDC\n"
								"2 VERS 5.3\n"
								"2 FORM LINEAGE-LINKED\n" ;
const char gedcom_months[15][4] = { "XXX", "JAN", "FEB", "MAR", "APR", "MAY",
				"JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC", "XXX", "QTR" } ;
const char* const Date_str = "2 DATE %s\n" ;
const char* const Place_str = "2 PLAC %s\n" ;
const char* const Source_str = "2 SOUR %s\n" ;
char gedcom_dest[21] = "ATARI_FAMILY_TREE" ;
const char* const schema_solicitor = "1 SCHEMA\n"
									"2 INDI\n"
									"3 WILL\n"
									"4 _SOLI\n"
									"5 LABL Solicitor\n"
									"5 DEFN The solicitor who handled the will.\n"
									"5 ISA ROLE\n" ;
const char* const schema_executor =  "1 SCHEMA\n"
									"2 INDI\n"
									"3 WILL\n"
									"4 _EXCUTR\n"
									"5 LABL Executor\n"
									"5 DEFN An executor of a will.\n"
									"5 ISA ROLE\n" ;

						/* These tags must be in the same order as	*/
						/* the gedcom_tag enum in GENGEDC.H			*/
const char* const gedcom_tags[] = { "",
								"ADDR",
								"BAP",
								"BAPM",
								"BIRT",
								"BURI",
								"CHAR",
								"CHIL",
								"CHR",
								"CONT",
								"CORP",
								"DATE",
								"DEAT",
								"DEFN",
								"DEST",
								"DIV",
								"EVEN",
								"FAM",
								"FAMC",
								"FAMS",
								"FILE",
								"FORM",
								"GEDC",
								"HEAD",
								"HUSB",
								"INDI",
								"ISA",
								"LABL",
								"LGTE",
								"MARR",
								"NAME",
								"NCHI",
								"NMR",
								"NOTE",
								"OCCU",
								"PLAC",
								"RFN",
								"SCHEMA",
								"SEX",
								"SOUR",
								"SUBM",
								"TRLR",
								"VERS",
								"WILL",
								"WIFE",
								"WITN",
								"_EXCUTR",
								"_SOLI",
								"LAST"
								} ;
short max_index_length ;
char* people_indices ;		/* tables of gedcom index strings	*/
char* couple_indices ;

char* notes_ptr ;
char* notes_end ;
BOOLEAN previous_gedcom_failure ;

struct
{
	char* fam_name ;
	char* forename ;
	char* adr[5] ;
} subm_form_addrs ;


OBJECT* subm_ptr ;			/* pointer to submitter form		*/


void  write_gedcom_transfer_header( FILE* fp )
{
	char today[] = "XX MMM YYYY" ;
	struct
	{
		short da_year;
		char da_day;
		char da_mon;
	} date ;

	char names[FULL_NAME_MAX+1] ;
	short adrline ;		/* loop counter round address lines		*/
	BOOLEAN first_adr_line ;	/* true until first line sent	*/

	fprintf( fp, header_part1, Version, gedcom_dest ) ;

	getdate( &date ) ;
	if( date.da_year >= 1995 )
	{
		sprintf( today, "%hd %s %hd", (short) date.da_day,
							gedcom_months[date.da_mon], date.da_year ) ;
		fprintf( fp, "1 DATE %s\n", today ) ;
	}

	busy( BUSY_DEFEAT ) ;
	do_sub_form( subm_ptr, "submitter", SUBMITTER_HELP, TITLED ) ;
	subm_ptr[SUBMITTER_OK].ob_state &= ~SELECTED ;
	busy( BUSY_RESTORE ) ;
	save_defaults() ;
	
	strcpy( names, subm_form_addrs.forename ) ;
	if( strlen( names ) != 0 )  strcat( names, " " ) ;
	strcat( names, "/" ) ;
	strcat( names, subm_form_addrs.fam_name ) ;
	strcat( names, "/" ) ;
	fprintf( fp, "1 SUBM\n2 NAME %s\n", names ) ;
	
	first_adr_line = TRUE ;
	for( adrline = 0; adrline < 5; adrline++ )
	{
		if( *subm_form_addrs.adr[adrline] )
		{
			if( first_adr_line )
			{
				first_adr_line = FALSE ;
				fprintf( fp, "2 ADDR %s\n", subm_form_addrs.adr[adrline] ) ;
			}
			else  fprintf( fp, "3 CONT %s\n", subm_form_addrs.adr[adrline] ) ;
		}
	}
		
	fprintf( fp, header_part2, transfer_file ) ;

	fputs( schema_solicitor, fp ) ;
	fputs( schema_executor, fp ) ;
}


void  set_subm_form_addrs( void )
							/* This routine fetches all the resource	*/
							/* tree addresses for the variable strings	*/
							/* on the submitter form and stores them in	*/
							/* a single array.							*/

{
							/* get filter export form addresses			*/
	subm_form_addrs.fam_name = FORM_TEXT(subm_ptr, SUBMITTER_FAM) ;
	subm_form_addrs.forename = FORM_TEXT(subm_ptr, SUBMITTER_FORE) ;
	subm_form_addrs.adr[0] = FORM_TEXT(subm_ptr, ADDRESS1) ;
	subm_form_addrs.adr[1] = FORM_TEXT(subm_ptr, ADDRESS2) ;
	subm_form_addrs.adr[2] = FORM_TEXT(subm_ptr, ADDRESS3) ;
	subm_form_addrs.adr[3] = FORM_TEXT(subm_ptr, ADDRESS4) ;
	subm_form_addrs.adr[4] = FORM_TEXT(subm_ptr, ADDRESS5) ;
}




void  write_gedcom_transfer_person( int pers, FILE* fp )
{
	Person* p_ptr ;
	short block ;
	int pars, cref ;
	char* coups ;
	char names[FULL_NAME_MAX+1] ;
	char date_string[] = "ABT DD MMM YYYY" ;
	short number_of_couplings, number_of_children ;

	p_ptr = get_pdata_ptr( pers, &block ) ;

	fprintf( fp, "0 @I%d@ INDI\n", pcross_refs[pers] ) ; 

		/* form names using unlimited, full length forenames	*/
	form_gedcom_names( p_ptr, names ) ;
	fprintf( fp, "1 NAME %s\n", names ) ;
	if( 'f' == p_ptr->sex || 'm' == p_ptr->sex )
		fprintf( fp, "1 SEX %c\n", (int) toupper( p_ptr->sex ) ) ; 

	print_ged_details( fp, "BIRT", p_ptr->birth_date, p_ptr->birth_place, p_ptr->birth_source ) ;
	print_ged_details( fp, "BAPM", p_ptr->baptism_date, p_ptr->baptism_place, p_ptr->baptism_source ) ;

	if( p_ptr->occupation )
		fprintf( fp, "1 OCCU %s\n", p_ptr->occupation ) ;

	print_ged_details( fp, "DEAT", p_ptr->death_date, p_ptr->death_place, p_ptr->death_source ) ;
	print_ged_details( fp, "BURI", p_ptr->burial_date, p_ptr->burial_place, NULL ) ;

	if( p_ptr->will_date || p_ptr->will_wit1 || p_ptr->will_wit2
				|| p_ptr->will_exe1 || p_ptr->will_exe2 || p_ptr->will_sol
				|| p_ptr->will_bens || p_ptr->will_bens2 || p_ptr->will_bens3 )
	{
		fprintf( fp, "1 WILL\n" ) ;
		if( p_ptr->will_date )
		{
			form_gedcom_date( date_string, p_ptr->will_date ) ;
			fprintf( fp, Date_str, date_string ) ;
		}
		if( p_ptr->will_wit1 )
			fprintf( fp, "2 WITN %s\n", p_ptr->will_wit1 ) ;
		if( p_ptr->will_wit2 )
			fprintf( fp, "2 WITN %s\n", p_ptr->will_wit2 ) ;
		if( p_ptr->will_exe1 )
			fprintf( fp, "2 _EXCUTR %s\n", p_ptr->will_exe1 ) ;
		if( p_ptr->will_exe2 )
			fprintf( fp, "2 _EXCUTR %s\n", p_ptr->will_exe2 ) ;
		if( p_ptr->will_wit1 )
			fprintf( fp, "2 _SOLI %s\n", p_ptr->will_sol ) ;
		if( p_ptr->will_bens )
			fprintf( fp, "2 LGTE %s\n", p_ptr->will_bens ) ;
		if( p_ptr->will_bens2 )
			fprintf( fp, "2 LGTE %s\n", p_ptr->will_bens2 ) ;
		if( p_ptr->will_bens3 )
			fprintf( fp, "2 LGTE %s\n", p_ptr->will_bens3 ) ;
	}
				 
				/* count number of couplings and total children	*/
	count_couples_and_children( p_ptr, &number_of_couplings, &number_of_children ) ;
	
	fprintf( fp, "1 NMR %hd\n"
			 "1 NCHI %hd\n", number_of_couplings, number_of_children ) ;
		
	if( coups = p_ptr->couplings, coups )
	{
		while( cref = form_ref( &coups ), cref )
		{
			if( cref = ccross_refs[cref], cref )
				fprintf( fp, "1 FAMS @F%d@\n", cref ) ;
		}
	}

	if( p_ptr->parents )
	{
		if( pars = ccross_refs[p_ptr->parents], pars )
			fprintf( fp, "1 FAMC @F%d@\n", pars ) ;
	}

	fprintf( fp, "1 RFN %d\n", pers ) ;
		
	if( p_ptr->notes )
		gedcom_output_notes( fp, p_ptr->notes ) ;
}


void  count_couples_and_children( Person* p_ptr, short* number_of_couplings, short* number_of_children )
{
	char* coups ;
	char* ch_ptr ;
	int coup, next_coup ;
	int child, next_child ;
	Couple* c_ptr ;
	short block ;

	*number_of_couplings = 0 ;
	*number_of_children = 0 ;
	
	if( coups = p_ptr->couplings, coups )
	{
		next_coup = form_ref( &coups ) ;
		while( coup = next_coup, coup )
		{
			next_coup = get_next_couple( coup, p_ptr->reference ) ;
			(*number_of_couplings)++ ;
			c_ptr = get_cdata_ptr( coup, &block ) ;
			if( ch_ptr = c_ptr->children, ch_ptr )
			{
				next_child = form_ref( &ch_ptr ) ;
				while( child = next_child, child )
				{
					next_child = get_next_child( child, coup ) ;
					(*number_of_children)++ ;
				}
			}
		}
	}
}


void  write_gedcom_transfer_couple( int coup, FILE* fp )
{
	Couple* c_ptr ;
	short block ;
	char* child_ptr ;
	int ref ;
	short number_of_children ;
	int child, next_child ;
	char* ch_ptr ;

	c_ptr = get_cdata_ptr( coup, &block ) ;

	fprintf( fp, "0 @F%d@ FAM\n", ccross_refs[coup] ) ;

	if( c_ptr->male_reference )
		if( ref = pcross_refs[c_ptr->male_reference], ref )
			fprintf( fp, "1 HUSB @I%d@\n", ref ) ;
	if( c_ptr->female_reference )
		if( ref = pcross_refs[c_ptr->female_reference], ref )
			fprintf( fp, "1 WIFE @I%d@\n", ref ) ;
	if( child_ptr = c_ptr->children )
	{
		while( ref = form_ref( &child_ptr ) )
			if( ref = pcross_refs[ref], ref )
				fprintf( fp, "1 CHIL @I%d@\n", ref ) ;
	}
	fprintf( fp, "1 RFN %d\n", coup ) ;

	print_ged_details( fp, "MARR", c_ptr->wedding_date, c_ptr->wedding_place,
														c_ptr->wedding_source ) ;
	if( c_ptr->wedd_wit1 )
		fprintf( fp, "2 WITN %s\n", c_ptr->wedd_wit1 ) ;
	if( c_ptr->wedd_wit2 )
		fprintf( fp, "2 WITN %s\n", c_ptr->wedd_wit2 ) ;

	print_ged_details( fp, "DIV", c_ptr->divorce_date, NULL,
														c_ptr->divorce_source ) ;
	number_of_children = 0 ;
	if( ch_ptr = c_ptr->children, ch_ptr )
	{
		next_child = form_ref( &ch_ptr ) ;
		while( child = next_child, child )
		{
			next_child = get_next_child( child, coup ) ;
			number_of_children++ ;
		}
	}
	fprintf( fp, "1 NCHI %d\n", number_of_children ) ;
}



void  print_ged_details( FILE* fp, char* event, int date, char* place, char* source )
{
	char date_string[] = "ABT DD MMM YYYY" ;

	if( date || place || source )
	{
		fprintf( fp, "1 %s\n", event ) ;
		if( date )
		{
			form_gedcom_date( date_string, date ) ;
			fprintf( fp, Date_str, date_string ) ;
		}
		if( place )  fprintf( fp, Place_str, place ) ;
		if( source )  fprintf( fp, Source_str, source ) ;
	}
}


short  prescan_gedcom_file( FILE* fp )
{
	char buffer[BUFFER_SIZE], buffer2[BUFFER_SIZE] ;
	short done = FALSE ;
	int level ;		/* hierarchical level reached						*/
	gedcom_tag tag_index ;	/* tag in current line						*/
	char reference_string[16] ;
	char data_string[248] ;	/* data following tag (not used here)		*/
	BOOLEAN parsed ;		/* flag for line successfully parsed		*/
	BOOLEAN succeed = TRUE ;	/* gedcom file successfully parsed, and	*/
								/* sufficient memory					*/
	int max_notes_size = 0 ;
	int current_notes_size = 0 ;
	short record_type = G_NONE ;

	total_people = 0 ;
	total_couples = 0 ;
	max_index_length = 0 ;

	while( fgets( buffer, BUFFER_SIZE - 1, fp ), !feof( fp ) && !done )
	{
		if( *buffer )						/* ignore blank lines		*/
		{
			strcpy( buffer2, buffer ) ;
			parsed = parse_gedcom_line( buffer,
						&level, reference_string, &tag_index, data_string ) ;
			if( !parsed )
				succeed = FALSE ;
			else
			{
				if( level == 0 )
				{
					max_notes_size = max( max_notes_size, current_notes_size ) ;
					current_notes_size = 0 ;
	
					record_type = tag_index ;
	
					switch( tag_index )
					{
						case G_INDI :
							total_people++ ;
							max_index_length = max( max_index_length,
												strlen( reference_string ) ) ;
							break ;
						case G_FAM :
							total_couples++ ;
							max_index_length = max( max_index_length,
												strlen( reference_string ) ) ;
							break ;
						case G_TRLR :
							done = TRUE ;
							break ;
						default :
							break ;
					}
				}
				if( record_type == G_INDI )
				{
					switch( tag_index )
					{
						case G_NOTE :
						case G_CONT :
							current_notes_size += strlen( data_string ) ;
							break ;
						case G_NONE :
							current_notes_size += strlen( buffer2 ) ;
							break ;
						default :
							break ;
					}
				} 
			}
		}
	}

	if( !succeed )
	{
		if( 1 == rsrc_form_alert( 0, PARSE_FAILURE ) )
						/* i.e. ignore failure to parse line(s)	*/
			succeed = TRUE ;
	}

	if( succeed && max_notes_size > prefs.edit_buffer_size )
	{
		void* alert_ptr ;
		char alert_str[200] ;
			
		rsrc_gaddr( R_STRING, ED_BUF_TOO_SMALL, &alert_ptr ) ;
		sprintf( alert_str, alert_ptr, prefs.edit_buffer_size, max_notes_size ) ;
		form_alert( 1, alert_str ) ;
		succeed = FALSE ;
	}
				/* If file read successfully and not too many people	*/
				/* attempt to allocate enough memory for loading data.	*/
	if( succeed && check_hdr() )
	{
							/* ++ on max_i_l to allow for terminator	*/
		if( total_people != 0 )
			people_indices = (char*) pmalloc( (size_t) ( total_people
												* ++max_index_length ) ) ;
		if( total_couples != 0 )
			couple_indices = (char*) pmalloc( (size_t) ( total_couples
												* max_index_length ) ) ;
		if( total_people && people_indices == NULL ||
							total_couples && couple_indices == NULL )
		{
			rsrc_form_alert( 1, NO_MEMORY ) ;
				
			if( people_indices )  free( people_indices ) ;
			if( couple_indices )  free( couple_indices ) ;
				
			succeed = FALSE ;
		}
	}
	return succeed ;
}



void  load_gedcom_file( FILE* fp )
{
	int original_next_person ;
	int original_next_couple ;
	gedcom_tag tags[10] ;	/* array of tag indexes at each level of		*/
							/* hierarchical data							*/
	gedcom_tag tag_index ;	/* tag in current line							*/
	int level ;		/* hierarchical level reached							*/
	int line_number ;	/* line number in GEDCOM file					*/
	char buffer[257] ;		/* allows for 255 chars plus termination \n\0	*/
	char reference_string[16] ;
	char data_string[248] ;	/* data following tag							*/
	char** dest_ptr ;		/* data pointer within person or couple			*/
	short length ;			/* field length for person data					*/
	short done = FALSE ;
	short succeed ;
	int person = 0 ;
	Person* pptr = NULL ;
	int couple_array[MAX_COUPLINGS+1] ;
	short sNumber_of_couplings = 0 ;
	int couple = 0 ;
	Couple* cptr = NULL ;
	int child_array[MAX_CHILDREN+1] ;
	short sNumber_of_children = 0 ;
	short block = 0 ;		/* initialised to allow compilation without		*/
							/* warning										*/
	int date ;
	BOOLEAN Bmishandled = FALSE ;
	BOOLEAN Bfam_tree_sourced = FALSE ;

 			/* initialise mishandled line by calling with zero line number	*/
	mishandled_line( 0, 0, NULL, 0, NULL, NULL ) ;

	previous_gedcom_failure = FALSE ;
	
	release_memory() ;
	if( !edit_buffer )  edit_buffer = pmalloc( (size_t) prefs.edit_buffer_size ) ;
	notes_ptr = edit_buffer ;
	notes_end = edit_buffer + prefs.edit_buffer_size ;

							/* set up references on this pass				*/
	fseek( fp, 0, SEEK_SET ) ;
	while( fgets( buffer, 256, fp ), !feof( fp ) && !done )
	{
		if( *buffer )							/* ignore blank lines		*/
		{
			succeed = parse_gedcom_line( buffer, &level, reference_string, &tag_index, data_string ) ;
		
			if( succeed )
			{
				switch( tag_index )
				{
					case G_INDI :
						if( level == 0 )
						{
							strcpy( people_indices + person * max_index_length,
														reference_string ) ;
							person++ ;
						}
						break ;
					case G_FAM :
						if( level == 0 )
						{
							strcpy( couple_indices + couple * max_index_length,
														reference_string ) ;
							couple++ ;
						}
						break ;
					case G_TRLR :
						done = TRUE ;
						break ;
					default :
						break ;
				}
			}
		}
	}
						/* Hierarchy initialised on assumption that first	*/
						/* line has been read and was start of header.		*/
	tags[0] = G_HEAD ;
	tags[1] = G_NONE ;
	level = 1 ;

	done = FALSE ;
	fseek( fp, 0, SEEK_SET ) ;
	line_number = 0 ;
	person = 0 ;
	couple = 0 ;
	original_next_person = next_person ;
	original_next_couple = next_couple ;
	
	while( fgets( buffer, BUFFER_SIZE - 1, fp ), !feof( fp ) && !done )
	{
		line_number++ ;

		if( *buffer )							/* ignore blank lines		*/
		{
			succeed = parse_gedcom_line( buffer, &level, reference_string, &tag_index, data_string ) ;
		
			if( succeed )
			{
				tags[level] = tag_index ;
			
				switch( tag_index )
				{
					case G_BAP :
					case G_BAPM :
					case G_CHR :
					case G_BIRT :
					case G_BURI :
					case G_DEAT :
						if( level != 1 || tags[0] != G_INDI )  Bmishandled = TRUE ;
						break ;
					case G_CHAR :
						if( strcmp( data_string, ibm_char_set ) )  Bmishandled = TRUE ;
						break ;
					case G_CHIL :
						if( level == 1 && tags[0] == G_FAM )
							child_array[sNumber_of_children++] = get_entry_index( reference_string,
											people_indices, total_people, original_next_person ) ;
						else  Bmishandled = TRUE ;
						break ;
					case G_DATE :
						date = evaluate_gedcom_date( data_string ) ;
						if( date > 0 )
						{
							switch( tags[0] )
							{
								case G_INDI :
									if( level == 2 )
									{
										switch( tags[1] )
										{
											case G_BAP :
											case G_BAPM :
											case G_CHR :
												pptr->baptism_date = date ;
												break ;
											case G_BIRT :
												pptr->birth_date = date ;
												break ;
											case G_BURI :
												pptr->burial_date = date ;
												break ;
											case G_DEAT :
												pptr->death_date = date ;
												break ;
											default :
												Bmishandled = TRUE ;
												break ;
										}
									}
									else  Bmishandled = TRUE ;
									break ;
								case G_FAM :
									if( level == 2 )
									{
										switch( tags[1] )
										{
											case G_MARR :
												cptr->wedding_date = date ;
												break ;
											case G_DIV :
												cptr->divorce_date = date ;
												break ;
											default :
												Bmishandled = TRUE ;
												break ;
										}
									}
									else  Bmishandled = TRUE ;
									break ;
								case G_HEAD :
									break ;
								default :
									Bmishandled = TRUE ;
									break ;
							}
						}
						else if( date == -1 )  Bmishandled = TRUE ;
						break ;
					case G_DIV :
						if( level != 1 || tags[0] != G_FAM )  Bmishandled = TRUE ;
						break ;
					case G_EVEN :
						if( level == 0 )
						{
							save_last_person( person, pptr, block, couple_array, &sNumber_of_couplings ) ;
							save_last_couple( couple, cptr, block, child_array, &sNumber_of_children ) ;
							person = 0 ;
							couple = 0 ;
						}
						Bmishandled = TRUE ;
						break ;
					case G_FAM :
						if( level == 0 )
						{
							save_last_person( person, pptr, block, couple_array, &sNumber_of_couplings ) ;
							save_last_couple( couple, cptr, block, child_array, &sNumber_of_children ) ;
							person = 0 ;
					
							couple = get_entry_index( reference_string, couple_indices, total_couples, original_next_couple ) ;
						
							assert( couple == next_couple ) ;
						
							cptr = get_cdata_ptr( couple, &block ) ;
							cptr->reference = couple ;
							next_couple++ ;
						}
						else  Bmishandled = TRUE ;
						break ;
					case G_FAMC :
						if( level == 1 && tags[0] == G_INDI )
							pptr->parents = get_entry_index( reference_string,
											couple_indices, total_couples, original_next_couple ) ;
						else  Bmishandled = TRUE ;
						break ;
					case G_FAMS :
						if( level == 1 && tags[0] == G_INDI )
							couple_array[sNumber_of_couplings++] = get_entry_index( reference_string,
											couple_indices, total_couples, original_next_couple ) ;
						else  Bmishandled = TRUE ;
						break ;
					case G_HUSB :
						if( level == 1 && tags[0] == G_FAM )
							cptr->male_reference = get_entry_index( reference_string, people_indices, total_people, original_next_person ) ;
						else  Bmishandled = TRUE ;
						break ;
					case G_INDI :
						if( level == 0 )
						{
							save_last_person( person, pptr, block, couple_array, &sNumber_of_couplings ) ;
							save_last_couple( couple, cptr, block, child_array, &sNumber_of_children ) ;
							couple = 0 ;
						
							person = get_entry_index( reference_string, people_indices, total_people, original_next_person ) ;

							assert( person == next_person ) ;
	
							pptr = get_pdata_ptr( person, &block ) ;
							pptr->reference = person ;
							next_person++ ;
						}
						else if( tags[0] != G_HEAD )  Bmishandled = TRUE ;
						break ;
					case G_LGTE :
						if( *data_string && level == 2 && tags[0] == G_INDI && tags[1] == G_WILL )
						{
							if( pptr->will_bens == NULL )
								dest_ptr = &(pptr->will_bens) ;
							else if( pptr->will_bens2 == NULL )
								dest_ptr = &(pptr->will_bens2) ;
							else if( pptr->will_bens3 == NULL )
								dest_ptr = &(pptr->will_bens3) ;
							else  Bmishandled = TRUE ;

							if( ! Bmishandled )
								Bmishandled = load_gedcom_data( dest_ptr,
									WILL_BENEFICIARY_LENGTH, data_string,
									&next_pstring_ptr[block], pblock_end[block] ) ;
						}
						else  Bmishandled = TRUE ;
						break ;
					case G_MARR :
						if( level != 1 || tags[0] != G_FAM )  Bmishandled = TRUE ;
						break ;
					case G_NAME :
						if( level == 1 && tags[0] == G_INDI )
							Bmishandled = save_ged_name( pptr, data_string, block ) ;
						else if( tags[0] != G_HEAD )  Bmishandled = TRUE ;
						break ;
					case G_NOTE :
						if( tags[0] == G_INDI && *data_string )
						{
							if( notes_ptr > edit_buffer )
								Bmishandled = add_note( "\r", data_string ) ;
							else  Bmishandled = add_note( NULL, data_string ) ;
						}
						else  Bmishandled = TRUE ;
						break ;
					case G_CONT :
						if( level > 1 && tags[0] == G_INDI && tags[level-1] == G_NOTE && *data_string )
							Bmishandled = add_note( " ", data_string ) ;
						break ;
					case G_OCCU :
						if( level == 1 && tags[0] == G_INDI )
						{
							Bmishandled = load_gedcom_data( &(pptr->occupation),
										OCCUPATION_LENGTH, data_string,
										&next_pstring_ptr[block], pblock_end[block] ) ;
						}
						else  Bmishandled = TRUE ;
						break ;
					case G_PLAC :
						if( *data_string )
						{
							switch( tags[0] )
							{
								case G_INDI :
									if( level == 2 )
									{
										switch( tags[1] )
										{
											case G_BAP :
											case G_BAPM :
											case G_CHR :
												dest_ptr = &(pptr->baptism_place) ;
												length = BAPTISM_PLACE_LENGTH ;
												break ;
											case G_BIRT :
												dest_ptr = &(pptr->birth_place) ;
												length = BIRTH_PLACE_LENGTH ;
												break ;
											case G_BURI :
												dest_ptr = &(pptr->burial_place) ;
												length = BURIAL_PLACE_LENGTH ;
												break ;
											case G_DEAT :
												dest_ptr = &(pptr->death_place) ;
												length = DEATH_PLACE_LENGTH ;
												break ;
											default :
												Bmishandled = TRUE ;
												break ;
										}
									}
									else  Bmishandled = TRUE ;
									break ;
								case G_FAM :
									if( level == 2 )
									{
										switch( tags[1] )
										{
											case G_MARR :
												dest_ptr = &(cptr->wedding_place) ;
												length = WEDDING_PLACE_LENGTH ;
												break ;
											default :
												Bmishandled = TRUE ;
												break ;
										}
									}
									else  Bmishandled = TRUE ;
									break ;
								default :
									Bmishandled = TRUE ;
									break ;
							}
							if( !Bmishandled )
								Bmishandled = load_gedcom_data( dest_ptr, length,
									data_string,
									&next_pstring_ptr[block], pblock_end[block] ) ;

						}
						else  Bmishandled = TRUE ;
						break ;
					case G_SEX :
						if( level == 1 && tags[0] == G_INDI )
						{
							if( strcmp( data_string, "M" ) == 0 )
								pptr->sex = 'm' ;
							else if( strcmp( data_string, "F" ) == 0 )
								pptr->sex = 'f' ;
									/* mishandled if other data, not if space	*/
							else if( *data_string && strcmp( data_string, " " ) != 0 )  Bmishandled = TRUE ;
						}
						else  Bmishandled = TRUE ;
						break ;
					case G_SOUR :
						if( *data_string )
						{
							switch( tags[0] )
							{
								case G_HEAD :
									if( level == 1
											&& strcmp( data_string, this_program ) == 0 )
										Bfam_tree_sourced = TRUE ;
									dest_ptr = NULL ;
									break ;
								case G_INDI :
									if( level == 2 )
									{
										switch( tags[1] )
										{
											case G_BAP :
											case G_BAPM :
											case G_CHR :
												dest_ptr = &(pptr->baptism_source) ;
												length = BAPTISM_SOURCE_LENGTH ;
												break ;
											case G_BIRT :
												dest_ptr = &(pptr->birth_source) ;
												length = BIRTH_SOURCE_LENGTH ;
												break ;
											case G_DEAT :
												dest_ptr = &(pptr->death_source) ;
												length = DEATH_SOURCE_LENGTH ;
												break ;
											default :
												Bmishandled = TRUE ;
												break ;
										}
									}
									else  Bmishandled = TRUE ;
									break ;
								case G_FAM :
									if( level == 2 )
									{
										switch( tags[1] )
										{
											case G_MARR :
												dest_ptr = &(cptr->wedding_source) ;
												length = WEDDING_SOURCE_LENGTH ;
												break ;
											case G_DIV :
												dest_ptr = &(cptr->divorce_source) ;
												length = DIVORCE_SOURCE_LENGTH ;
												break ;
											default :
												Bmishandled = TRUE ;
												break ;
										}
									}
									else  Bmishandled = TRUE ;
									break ;
								default :
									Bmishandled = TRUE ;
									break ;
							}
							if( !Bmishandled && dest_ptr )
								Bmishandled = load_gedcom_data( dest_ptr, length,
									data_string,
									&next_pstring_ptr[block], pblock_end[block] ) ;
						}
						else  Bmishandled = TRUE ;
						break ;
					case G_WILL :
						break ;
					case G_WIFE :
						if( level == 1 && tags[0] == G_FAM )
							cptr->female_reference = get_entry_index( reference_string, people_indices, total_people, original_next_person ) ;
						else  Bmishandled = TRUE ;
						break ;
					case G_WITN :
						if( *data_string && level == 2 && tags[0] == G_INDI && tags[1] == G_WILL )
						{
							if( pptr->will_wit1 == NULL )
								dest_ptr = &(pptr->will_wit1) ;
							else if( pptr->will_wit2 == NULL )
								dest_ptr = &(pptr->will_wit2) ;
							else  Bmishandled = TRUE ;

							if( ! Bmishandled )
								Bmishandled = load_gedcom_data( dest_ptr,
									WILL_WITNESS_LENGTH, data_string,
									&next_pstring_ptr[block], pblock_end[block] ) ;
						}
					
						else if( *data_string && level == 2 && tags[0] == G_FAM && tags[1] == G_MARR )
						{
							if( cptr->wedd_wit1 == NULL )
								dest_ptr = &(cptr->wedd_wit1) ;
							else if( cptr->wedd_wit2 == NULL )
								dest_ptr = &(cptr->wedd_wit2) ;
							else  Bmishandled = TRUE ;

							if( ! Bmishandled )
								Bmishandled = load_gedcom_data( dest_ptr,
									WEDDING_WITNESS_LENGTH, data_string,
									&next_cstring_ptr[block], cblock_end[block] ) ;
						}
					
						else  Bmishandled = TRUE ;
						break ;
					case G__EXCUTR :
						if( *data_string && level == 2 && tags[0] == G_INDI && tags[1] == G_WILL )
						{
							if( pptr->will_exe1 == NULL )
								dest_ptr = &(pptr->will_exe1) ;
							else if( pptr->will_exe2 == NULL )
								dest_ptr = &(pptr->will_exe2) ;
							else  Bmishandled = TRUE ;

							if( ! Bmishandled )
								Bmishandled = load_gedcom_data( dest_ptr,
									WILL_EXECUTOR_LENGTH, data_string,
									&next_pstring_ptr[block], pblock_end[block] ) ;
						}
						else  Bmishandled = TRUE ;
						break ;
					case G__SOLI :
						if( *data_string && level == 2 && tags[0] == G_INDI && tags[1] == G_WILL )
						{
							if( pptr->will_sol == NULL )
								dest_ptr = &(pptr->will_sol) ;
							else  Bmishandled = TRUE ;

							if( !Bmishandled )
								Bmishandled = load_gedcom_data( dest_ptr,
									WILL_EXECUTOR_LENGTH, data_string,
									&next_pstring_ptr[block], pblock_end[block] ) ;
						}
						else if( tags[0] != G_HEAD )  Bmishandled = TRUE ;
						break ; 
							/* entries which would be mishandled, but not	*/
							/* a problem if they were generated by this		*/
							/* program anyway								*/
					case G_ISA :
					case G_LABL :
					case G_SCHEMA :
					case G_NMR :
					case G_NCHI :
					case G_RFN :
						if( !Bfam_tree_sourced )  Bmishandled = TRUE ;	/* otherwise ignore	*/
						break ;
							/* Entries which are happily ignored in Header,	*/
							/* but probably an error anywhere else			*/
					case G_ADDR :
					case G_CORP :
					case G_DEST :
					case G_FILE :
					case G_FORM :
					case G_GEDC :
					case G_HEAD :	/* should only occur at start!	*/
					case G_SUBM :
					case G_VERS :
						if( tags[0] != G_HEAD )  Bmishandled = TRUE ;
						break ;
								/* specific tags which I will not interpret		*/
					case G_DEFN :
						Bmishandled = TRUE ;
						break ;
								/* any other tags which I will not interpret	*/
					case G_TRLR :
						done = TRUE ;
						break ;
					default :
						Bmishandled = TRUE ;
						break ;
				}

								/* assume I can handle my own schema			*/
				if( tags[0] == G_HEAD && tags[1] == G_SCHEMA && Bfam_tree_sourced )  Bmishandled = FALSE ;
								/* assume I cannot handle other schema			*/
				if( tags[0] == G_HEAD && tags[1] ==  G_SCHEMA && !Bfam_tree_sourced )  Bmishandled = TRUE ;
								/* ignore submitter, some old files may have	*/
								/* SUBM as level 0, not level 1 in header		*/
				if( tags[0] == G_SUBM )  Bmishandled = FALSE ;
				
				if( Bmishandled )
				{
					mishandled_line( line_number, person, pptr, couple, cptr, buffer ) ;
					Bmishandled = FALSE ;
				}
			}
		}
	}
	save_last_person( person, pptr, block, couple_array, &sNumber_of_couplings ) ;
	save_last_couple( couple, cptr, block, child_array, &sNumber_of_children ) ;

	assert( next_person == original_next_person + total_people ) ;
	assert( next_couple == original_next_couple + total_couples ) ;

 		/* report number of mishandled lines by calling with line number -1	*/
	mishandled_line( -1, 0, NULL, 0, NULL, NULL ) ;

	fclose( fp ) ;
}


BOOLEAN  save_ged_name( Person* pptr, char* data_string, short block )
{
	char fore_buffer[256] ;
	char fam_buffer[256] ;
	char* pcdata ;
	char* pcfore ;
	char* pcfam ;
	char ch ;
	BOOLEAN Bfam_flag ;	/* set whilst processing family name				*/
	BOOLEAN Bmishandled = FALSE ;
	short changed ;		/* dummy used for str_save as change assumed anyway	*/

	assert( pptr ) ;
	assert( data_string ) ;

	pcdata = data_string ;
	pcfore = fore_buffer ;
	pcfam = fam_buffer ;
	Bfam_flag = FALSE ;
	
	while( ch = *pcdata++, ch )
	{
		if( ch == '/' )
		{
			Bfam_flag = !Bfam_flag ;
		}
		else
		{
			if( Bfam_flag )  *pcfam++ = ch ;
			else  *pcfore++ = ch ;
		}
	}
	*pcfam = '\0' ;
	*pcfore = '\0' ;
											/* remove unwanted spaces		*/
	tidy_spaces( fore_buffer ) ;
	tidy_spaces( fam_buffer ) ;

	if( strlen( fore_buffer ) > FORENAME_LENGTH || strlen( fam_buffer ) > FAM_NAME_LENGTH )
	{
		shorten_names( fore_buffer, FORENAME_LENGTH ) ;
		shorten_names( fam_buffer, FAM_NAME_LENGTH ) ;
		
		Bmishandled = TRUE ;
	}
		
	str_save( &(pptr->family_name), fam_buffer,
						&next_pstring_ptr[block], pblock_end[block], &changed ) ;
	str_save( &(pptr->forenames), fore_buffer,
						&next_pstring_ptr[block], pblock_end[block], &changed ) ;

	return Bmishandled ;
}



			/*****	 	save_last_person								*****/
			/* checks whether person is non-zero. It then sets appropriate	*/
			/* block as changed and adds the person to the index.			*/
			/*																*/
			/* Passed	person	reference of person being entered or zero	*/
			/*			pptr	data pointer for person being entered		*/
			/*			block	block number for person or couple - assume	*/
			/*						that calling program will have passed	*/
			/*						person or couple block as required.		*/
			/*			couple_array	list of couplings					*/
			/*			psNumber_of_couplings	passed by pointer so that	*/
			/*										it can be zeroed.		*/
			/* Return	void												*/
			/* Global	writes to pblock_changed array						*/
			/*			adds couples to block								*/
			/*			adds to people index								*/
			
void  save_last_person( int person, Person* pptr, short block, int* couple_array, short* psNumber_of_couplings )
{
	short dummy ;

	if( person )
	{
		assert( (int) pptr ) ;
		assert( (int) couple_array ) ;
		assert( (int) psNumber_of_couplings ) ;

		pblock_changed[block] = TRUE ;
		add_to_pidx( person, pptr ) ;
		if( *psNumber_of_couplings )
		{
			couple_array[*psNumber_of_couplings] = 0 ;	/* terminate list	*/
			put_couplings( pptr, block, couple_array ) ;
			*psNumber_of_couplings = 0 ;
		}
		if( notes_ptr > edit_buffer )
		{
			str_save( &(pptr->notes), edit_buffer,
					&next_pstring_ptr[block], pblock_end[block], &dummy ) ;
			notes_ptr = edit_buffer ;
		}
	}
}


			/*****	 	save_last_couple								*****/
			/* checks whether couple is non-zero. It then sets appropriate	*/
			/* block as changed and adds the couple to the index.			*/
			/*																*/
			/* Passed	couple	reference of couple being entered or zero	*/
			/*			cptr	data pointer for couple being entered		*/
			/*			block	block number for person or couple - assume	*/
			/*						that calling program will have passed	*/
			/*						couple block as required.				*/
			/*			couple_array	list of couplings					*/
			/*			psNumber_of_children	passed by pointer so that	*/
			/*										it can be zeroed.		*/
			/* Return	void												*/
			/* Global	writes to cblock_changed array						*/
			/*			adds children to block								*/
			/*			adds to couples index								*/

void  save_last_couple( int couple, Couple* cptr, short block, int* child_array, short* psNumber_of_children )
{
	if( couple )
	{
		assert( (int) cptr ) ;
		assert( (int) child_array ) ;
		assert( (int) psNumber_of_children ) ;

		cblock_changed[block] = TRUE ;
		add_to_cidx( couple, cptr ) ;
		if( *psNumber_of_children )
		{
			child_array[*psNumber_of_children] = 0 ;	/* terminate list	*/
			cput_references( &cptr->children, block, child_array ) ;
			*psNumber_of_children = 0 ;
		}

	}
}


void  mishandled_line( int line_number, int person, Person* pptr, int couple, Couple* cptr, char* buffer )
{
	static FILE* pFgedfail ;
	static char gedfail_file[FNSIZE+FMSIZE] ;
	static int failures ;

	char buffer2[258] ;
	
	if( line_number == 0 )
	{
		failures = 0 ;
		*gedfail_file = '\0' ;
	}
	else if( line_number == -1 )
	{
		if( failures )
		{
			void* alert_ptr ;
			char alert_str[200] ;
			char* fail_file ;
			
			assert( (int) gedfail_file ) ;

			if( strlen( gedfail_file ) > 30 )  fail_file = gedfail_file + strlen( gedfail_file ) - 30 ;
			else  fail_file = gedfail_file ;
			rsrc_gaddr( R_STRING, GED_LINES_FAILED, &alert_ptr ) ;
			sprintf( alert_str, alert_ptr, failures, fail_file ) ;
			form_alert( 1, alert_str ) ;
		}
	}
	else
	{
		failures++ ;
		
		if( *gedfail_file == '\0' )
		{
			char* pch ;
			
			strcpy( gedfail_file, transfer_file ) ;
			pch = gedfail_file + strlen( gedfail_file ) ;
			while( *pch != '.' && *pch != '\\' && pch >= gedfail_file )  pch-- ;
			if( *pch == '.' )  *pch = '\0' ;			/* remove file suffix	*/
			strcat( gedfail_file, doterr ) ;			/* make suffix ".ERR"	*/
			
			pFgedfail = fopen( gedfail_file, "w" ) ;
			
			if( pFgedfail == NULL )  rsrc_form_alert( 1, NO_GED_FAIL_FILE ) ;
		}
		else  fopen( gedfail_file, "a" ) ; 
			
		strcpy( buffer2, buffer ) ;
		buffer2[strlen(buffer)] = '\n' ;
		buffer2[strlen(buffer)+1] = '\0' ;
	
		if( person )
		{
			assert( pptr ) ;
			add_note( "mishandled line\r   ", buffer ) ;
			add_note( NULL, "\r" ) ;
		}

		if( pFgedfail )
		{
			fprintf( pFgedfail, "%8d  **%s**\n", line_number, buffer ) ;
			fclose( pFgedfail ) ;
		}
	}
}


			/*****	 	load_gedcom_data								*****/
			/* checks data length against space available and if ok copies	*/
			/* string into memory block using str_save().					*/
			/*																*/
			/* Passed	char** dest_pt		pointer to pointer to string in	*/
			/*					 				person structure			*/
			/*			short field_size	max data program can handle		*/
			/*			char* data_string	data string to be loaded		*/
			/*			char** next_ptr		position where data must be put	*/
			/*									and left pointing to next	*/
			/*									space for data				*/
			/*			char* block_end		points to end of available		*/
			/*									space before overflow used	*/
			/* Return	short success		TRUE if load successful			*/
			/* Global	str_save uses overflow position						*/

short  load_gedcom_data( char** dest_ptr, short field_size, char* data_string,
										char** next_ptr, char* block_end )
{
	short dummy ;	/* for 'changed' information returned by str_save	*/
	short fail = FALSE ;
	
	assert( (int) dest_ptr ) ;
	assert( (int) data_string ) ;
	assert( (int) next_ptr ) ;
	assert( (int) block_end ) ;

	if( field_size == 0 || strlen( data_string ) <= field_size )
		str_save( dest_ptr, data_string, next_ptr, block_end, &dummy ) ;
	else  fail = TRUE ;
	
	return fail ;
}


short  parse_gedcom_line( char* buffer, int* level,
			char* reference_string, gedcom_tag* tag_index, char* data_string )
{
	short succeed = TRUE ;
	short ref_found ;
	char* token ;
	char* end_ptr ;
	char* buffer_end ;
	char buffer_copy[256] ;
	
	assert( (int) buffer ) ;
	assert( (int) level ) ;
	assert( (int) reference_string ) ;
	assert( (int) tag_index ) ;
	assert( (int) data_string ) ;

	*reference_string = '\0' ;
	*data_string = '\0' ;
	

	if( buffer[strlen( buffer )-1] == '\n' )  buffer[strlen( buffer )-1] = '\0' ;
	strcpy( buffer_copy, buffer ) ;
	buffer_end = buffer_copy + strlen( buffer_copy ) ;
	
	if( token = strtok( buffer_copy, " " ), token == NULL )  succeed = FALSE ;
			/* convert first token to level number, and check conversion	*/
	if( succeed )
		if( stcd_i( token, level ) == 0 )  succeed = FALSE ;
	
			/* get next token and check it is valid							*/
	if( succeed )
		if( token = strtok( NULL, " " ), token == NULL )  succeed = FALSE ;

			/* if token is a reference, check and save it, get next token	*/
	if( succeed )
	{
		ref_found = extract_reference( token, reference_string, &end_ptr ) ;
		if( ref_found )
		{
			/* handle case where no space after reference by setting token to	*/
			/* look at next character, otherwise get next token					*/
			if( *(end_ptr+1) != '\0' )  token = end_ptr+1 ;
			else  token = strtok( NULL, " " ) ;
		}
	}
									/* load tag string							*/
	if( succeed )
	{
		*tag_index = get_tag_index( token ) ;
	
									/* look at remainder of buffer for data		*/
		token = token + strlen( token ) + 1 ;
		if( token >= buffer_end )  token = buffer_end ;
		strcpy( data_string, token ) ;
		remove_surrounding_spaces( data_string, SURROUNDING ) ;
	}
	
									/* if data string is a reference put it in	*/
									/* reference_string							*/
	extract_reference( token, reference_string, &end_ptr ) ;
	
	return succeed ;
}


short  extract_reference( char* token, char* reference_string, char** end_ptr )
{
	short ref_found = FALSE ;

	assert( token ) ;
	assert( reference_string ) ;
	assert( *end_ptr ) ;
	
	if( *token == '@' && *(token + 1 ) != '@' )
	{
		if( *end_ptr = strchr( token+1, '@' ), *end_ptr != NULL )
		{
			while( *(*end_ptr+1) == '@' )
				*end_ptr = strchr( *end_ptr+2, '@' ) ;
			if( *end_ptr != NULL )  ref_found = TRUE ;
		}

		if( ref_found )
		{
			**end_ptr = '\0' ;
			strcpy( reference_string, token+1 ) ;
		}
	}
	return ref_found ;
}
	


short  get_tag_index( char* tag_string )

{
	short tag_index = G_NONE ;
	short tag_loop_index = 0 ;

	while( tag_index == G_NONE && tag_loop_index < G_LAST )
	{
		if( 0 == strcmp( tag_string, gedcom_tags[++tag_loop_index] ) )
			tag_index = tag_loop_index ;
	}
	return tag_index ;
}



			/***** 		get_entry_index									*****/
			/*	takes a string and searches people or couple_indices for	*/
			/* matching string. Entry number in people or couple_indices is	*/
			/* added to next to give a reference number, which is returned.	*/
			/* If no matching string then 0 is returned.					*/
			/*																*/
			/* Passed	reference_string	string to be searched for		*/
			/*			index				to be searched					*/
			/*			total_entries		size of index					*/
			/*			next				offset to add to reference to	*/
			/*									allow for existing people	*/
			/*									or couples					*/
			/* Return	int					reference_number or 0			*/
			/* Global	max_index_length	size of index entries			*/
			
int  get_entry_index( char* reference_string, char* index, int total_entries, int next )
{
	char* index_ptr = index ;
	short found = FALSE ;
	int reference ;
	
	reference = 0 ;

			/* search until found, no more strings or end of array			*/
	if( total_entries > 0 )
	{
		while( !found && *index_ptr && reference < total_entries )
		{
			if( strcmp( index_ptr, reference_string ) == 0 )
				found = TRUE ;
			else
			{
				reference++ ;
				index_ptr += max_index_length ;
			}
		}
	}
	if( found )  reference += next ;
	else  reference = 0 ;
	
	return reference ;
}
		

short  form_gedcom_names( Person* p_ptr, char* names )
{
	short name_exists = FALSE ;
	
	if( p_ptr->forenames )
	{
		name_exists = TRUE ;
		strcpy( names, p_ptr->forenames ) ;
	}
	else names[0] = '\0' ;
	
	if( p_ptr->family_name )
	{
		if( name_exists )  strcat( names, " " ) ;
		name_exists = TRUE ;
		strcat( names, "/" ) ;
		strcat( names, p_ptr->family_name ) ;
		strcat( names, "/" ) ;
	}
	return name_exists ;
}


			/***** 		evaluate_gedcom_date							*****/
			/*  Takes a data_string and converts it to an integer date		*/
			/* this copes with dates of form			dd MON yyyy			*/
			/* It can handle either dd or dd & MON missing					*/
			/* It will treat '??' as day missing, '???' as month missing	*/
			/* It can handle prefixes ABT or EST, about or estimated, if	*/
			/* the day is not specified										*/
			/* If the date is successfully evaluated it is returned, if not	*/
			/* -1 is returned. Note that 0 may be returned without a		*/
			/* a failure if for example only ' ' and '?' in string.			*/
			/*																*/
			/* Passed	reference_string	string to be searched for		*/
			/*			index				to be searched					*/
			/*			total_entries		size of index					*/
			/*			next				offset to add to reference to	*/
			/*									allow for existing people	*/
			/*									or couples					*/
			/* Return	int					reference_number or 0			*/
			/* Global	max_index_length	size of index entries			*/

int  evaluate_gedcom_date( char* data_string )
{
	char* ds_ptr ;
	char* ch_ptr ;
	int date = 0 ;
	BOOLEAN about = FALSE ;
	BOOLEAN before = FALSE ;
	BOOLEAN after = FALSE ; 
	BOOLEAN fail = FALSE ;
	int day = 0 ;
	int month = 0 ;
	short month_index ;
	int year = 0 ;
	
	assert( data_string ) ;

	strupr( data_string ) ;

			/* First check for date qualifiers, BEF, AFT, ABT or EST or the	*/
			/* non standard c or C for circa. These are assumed to be at	*/
			/* start of string.												*/

	ds_ptr = data_string ;
	while( !isalnum( *ds_ptr ) && *ds_ptr != '\0' )  ds_ptr++ ;
	
	if( ch_ptr = strstr( ds_ptr, "AFT" ), ch_ptr )
	{
		after = TRUE ;
		ds_ptr = ch_ptr + 3 ;
	}
	else if( ch_ptr = strstr( ds_ptr, "BEF" ), ch_ptr )
	{
		before = TRUE ;
		ds_ptr = ch_ptr + 3 ;
	}
	else if( ch_ptr = strstr( ds_ptr, "ABT" ), ch_ptr )
	{
		about = TRUE ;
		ds_ptr = ch_ptr + 3 ;
	}
	else if( ch_ptr = strstr( ds_ptr, "EST" ), ch_ptr )
	{
		about = TRUE ;
		ds_ptr = ch_ptr + 3 ;
	}
	else if( ch_ptr = strstr( ds_ptr, "C" ), ch_ptr == ds_ptr )
	{
		about = TRUE ;
		ds_ptr++ ;
	}
	
	while( !isalnum( *ds_ptr ) && *ds_ptr != '\0' )  ds_ptr++ ;
	
			/* Now check whether number, and if so whether it is the day or	*/
			/* year. A year consists of exactly four digits, a day of one	*/
			/* or two.														*/
			
	if( isdigit( *ds_ptr ) )
	{
			/* omit leading zeros if more than 4 digit number				*/
		while( *ds_ptr == '0' && isdigit( *(ds_ptr+1) ) && isdigit( *(ds_ptr+2) )
							&& isdigit( *(ds_ptr+3 ) ) && isdigit( *(ds_ptr+4) ) )
			ds_ptr++ ;

		if( isdigit( *(ds_ptr+1) ) && isdigit( *(ds_ptr+2) )
							&& isdigit( *(ds_ptr+3 ) ) && !isdigit( *(ds_ptr+4) ) )
			year = atoi( ds_ptr ) ;
		else if( !isdigit( *(ds_ptr+1) ) || !isdigit( *(ds_ptr+2) ) )
			day = atoi( ds_ptr ) ;
		else  fail = TRUE ;
	}
	
				/* If not already done year check for month.					*/

	if( !fail && year == 0 )
	{
		while( !isalpha( *ds_ptr ) && *ds_ptr != '\0' )  ds_ptr++ ;
		
				/* discard any 'st', 'nd', 'rd' or 'th' and trailing non alphas	*/
		if( ( *ds_ptr == 'S' && *(ds_ptr+1) == 'T' )
			|| ( *ds_ptr == 'N' && *(ds_ptr+1) == 'D' )
			|| ( *ds_ptr == 'R' && *(ds_ptr+1) == 'D' )
			|| ( *ds_ptr == 'T' && *(ds_ptr+1) == 'H' ) )
		{
			ds_ptr += 2 ;
			while( !isalpha( *ds_ptr ) && *ds_ptr != '\0' )  ds_ptr++ ;
		}
			
		month_index = 1 ;
		while( month == 0 && month_index < 15 )
		{
			if( strstr( ds_ptr, gedcom_months[month_index] ) == ds_ptr )
			{
				month = month_index ;
			}
			else  month_index++ ;
		}
		if( month == 0 )  fail = TRUE ;
	}

			/* if not already done year, check for year.						*/

	if( !fail && year == 0 )
	{
		while( !isdigit( *ds_ptr ) && *ds_ptr != '\0' )  ds_ptr++ ;
		if( isdigit( *ds_ptr ) && isdigit( *(ds_ptr+1) )
				&& isdigit( *(ds_ptr+2) ) && isdigit( *(ds_ptr+3) )
				&& !isdigit( *(ds_ptr+4) ) )
			year = atoi( ds_ptr ) ;
		else if( isdigit( *ds_ptr ) )  fail = TRUE ;
	}
	
	if( !fail )
	{
								/* This forms date into modified Gemdos	*/
								/* form. The day and month are in		*/
								/* bits 0 to 8.							*/
								/* Year is relative to 0AD, so date is	*/
								/* int, not short, in bits 9 to 31.		*/
								/* A blank string is the 0th month.		*/
								/* Qtr is the 14th month!,				*/
								/* The circa flag is in bit 21. 		*/
		date = day + ( month << 5 ) + ( year << 9 ) ;

		if( about )  date += CIRCA_CODE ;
		else if( before )  date += BEFORE_CODE ;
		else if( after )  date += AFTER_CODE ;
	}

	return fail ? -1 : date ;
}

						
void  form_gedcom_date( char* date_str, int date )
								/* This takes date in modified Gemdos	*/
								/* form. The day and month are in		*/
								/* bits 0 to 8.							*/
								/* Year is relative to 0AD, so date is	*/
								/* int, not short, in bits 9 to 31.		*/
								/* A blank string is the 13th month.	*/
								/* Qtr is the 14th month!				*/
								/* The circa flag is in bit 21. 		*/
{
	short day, mon, year ;
	char temp_str[5] ;

	day = date & 0x1F ;
	mon = ( date & 0x1E0 ) >> 5 ;
	year = ( date & 0x1FFE00 ) >> 9 ;
	
	date_str[0] = '\0' ;

	switch( date & DATE_QUALIFY_BITS )
	{
		case CIRCA_CODE :
			strcat( date_str, "ABT " ) ;
			break ;
		case BEFORE_CODE :
			strcat( date_str, "BEF " ) ;
			break ;
		case AFTER_CODE :
			strcat( date_str, "AFT " ) ;
			break ;
		default :
			break ;
	}

	if( day )
	{
		sprintf( temp_str, "%hd", day ) ;
		strcat( date_str, temp_str ) ;
	}
	if( mon > 0 && mon <= 12 )
	{
		if( day )  strcat( date_str, " " ) ;
		strcat( date_str, gedcom_months[mon] ) ;
	}
	if( year )
	{
		if( day || ( mon > 0 && mon <= 12 ) )  strcat( date_str, " " ) ;
		sprintf( temp_str, "%hd", year ) ; 
		strcat( date_str, temp_str ) ;
	}
}


			/*****	 	gedcom_output_notes								*****/
			/*  outputs notes in lines of maximum 255 characters,			*/
			/* including terminators. As lines start "1 NOTE " and may have	*/
			/* cr/lf at end of line limit to 246 data characters. This may	*/
			/* be over cautious as \n may only take one character, but risk	*/
			/* is not worth taking for one character.						*/
			/*																*/
			/* Passed	fp		destination file pointer					*/
			/*			notes	pointer to string to be sent				*/
			/*																*/
			/* Return	void												*/
			/* Global	writes to pblock_changed array						*/
			/*			adds couples to block								*/
			/*			adds to people index								*/
			
void  gedcom_output_notes( FILE* fp, char* notes )
{
	char* buf_ptr ;
	char buffer[256] ;					/* to hold maximal GEDCOM line plus		*/
										/* leading tag.							*/
	char* slice_ptr ;
	Str_prt_params print_params ;
	
	print_params.use_gdos = FALSE ;		/* ensure functions work on character	*/
										/* count, not on font widths.			*/
	print_params.align = LEFT_WRAP ;
	print_params.max_len = 246 ;		/* not used really!						*/
	
	strcpy( buffer, "1 NOTE " ) ;
	buf_ptr = buffer + strlen( buffer) ;
	slice_ptr = notes ;
	
	while( get_next_slice( buf_ptr, &slice_ptr, &print_params, 246 ) )
	{
		strcat( buffer, "\n" ) ;
		assert( strlen( buffer) < 256 ) ;

		fputs( buffer, fp ) ;
		if( *(slice_ptr-1) == '\r' )	/* if split at a 'cr', start new note	*/
			strcpy( buffer, "1 NOTE " ) ;
		else  strcpy( buffer, "2 CONT " ) ;
		buf_ptr = buffer + strlen( buffer ) ;
	}
}


short  add_note( char* preamble, char* data_string )
{
	short fail = FALSE ;
	short length ;
	
	assert( data_string ) ;
	assert( edit_buffer ) ;
	assert( notes_ptr >= edit_buffer ) ;

	length = strlen( data_string ) ;
	if( preamble )  length += strlen( preamble ) + 1 ;

	if( notes_ptr + length < notes_end )
	{
		if( preamble )
		{
			strcpy( notes_ptr, preamble ) ;
			notes_ptr += strlen( preamble ) ;
			if( strcmp( preamble, "\r" ) && strcmp( preamble, " " ) )
				*notes_ptr++ = ' ' ;
		}
		strcpy( notes_ptr, data_string ) ;
		notes_ptr += strlen( data_string ) ;
	}
	else
	{
		fail = TRUE ;
		if( !previous_gedcom_failure )
		{
			rsrc_form_alert( 1, GEDCOM_FAILURE ) ;
			previous_gedcom_failure = TRUE ;
		}
	}
	
	return fail ;
}
