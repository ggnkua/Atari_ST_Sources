/************************************************************************/
/*																		*/
/*		Gengedc.h	1 Nov 1995											*/
/*																		*/
/************************************************************************/

/* Header file for GENGEDC containing #DEFINES and							*/
/* prototype definitions												*/

typedef enum
{
	G_NONE,
	G_ADDR, G_BAP, G_BAPM, G_BIRT, G_BURI, G_CHAR, G_CHIL, G_CHR, G_CONT, G_CORP, G_DATE, G_DEAT, G_DEFN, G_DEST, G_DIV, G_EVEN,
	G_FAM, G_FAMC, G_FAMS, G_FILE, G_FORM, G_GEDC, G_HEAD, G_HUSB, G_INDI, G_ISA, G_LABL, G_LGTE, G_MARR, G_NAME,
	G_NCHI, G_NMR, G_NOTE, G_OCCU, G_PLAC, G_RFN, G_SCHEMA, G_SEX, G_SOUR, G_SUBM, G_TRLR, G_VERS, G_WILL, G_WIFE, G_WITN,
	G__EXCUTR, G__SOLI, 
	G_LAST
} gedcom_tag ;

void	write_gedcom_transfer_header( FILE *fp ) ;
void	set_subm_form_addrs( void ) ;
void	write_gedcom_transfer_person( int pers, FILE *fp ) ;
void	count_couples_and_children( Person* p_ptr, short* number_of_couplings, short* number_of_children ) ;
void	write_gedcom_transfer_couple( int coup, FILE *fp ) ;
void	print_ged_details( FILE *fp, char *event, int date, char *place, char *source ) ;
short	prescan_gedcom_file( FILE *fp ) ;
void	load_gedcom_file( FILE *fp ) ;
BOOLEAN	save_ged_name( Person *pptr, char *data_string, short block ) ;
void	save_last_person( int person, Person *pptr, short block, int *couple_array, short *psNumber_of_couplings ) ;
void	save_last_couple( int couple, Couple *cptr, short block, int *child_array, short *psNumber_of_chldren ) ;
void	mishandled_line( int line_number,
			int person, Person *pptr, int couple, Couple *cptr, char *buffer ) ;
short	load_gedcom_data(	char **dest_ptr, short field_size, char *data_string,
										char **next_ptr, char *block_end ) ;
short	parse_gedcom_line( char *buffer, int *level,
			char *reference_string, gedcom_tag *tag_index, char *data_string ) ;
short	extract_reference( char *token, char *reference_string, char **end_ptr ) ;
short	get_tag_index( char *tag_string ) ;
int		get_entry_index( char *reference_string, char *index, int total_entries, int next ) ;
short	form_gedcom_names( Person *p_ptr, char *names ) ;
int		evaluate_gedcom_date( char *data_string ) ;
void	form_gedcom_date( char *date_str, int date ) ;
void	gedcom_output_notes( FILE *fp, char *notes ) ;
short	add_note( char *preamble, char *data_string ) ;

