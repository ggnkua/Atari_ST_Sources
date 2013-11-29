/************************************************************************/
/*																		*/
/*		Gendata.c	23 Jan 98											*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "genhd.h"
#include "gendata.h"
#include "genutil.h"
#include "gencoup.h"
#include "gendesc.h"
#include "gendraw.h"
#include "genfile.h"
#include "genmain.h"
#include "genpers.h"
#include "genpref.h"
#include "genpsel.h"
#include "gentree.h"

extern char data_directory[FNSIZE+FMSIZE] ;
extern char save_directory[FNSIZE+FMSIZE] ;
extern char custom_file[] ;
extern short edit_pers_block, edit_coup_block ;
extern int edit_pers_ref, edit_coup_ref ;
extern Person *edit_pers_pptr ;
extern Couple *edit_coup_cptr ;

extern Wind_edit_params pers_form, coup_form ;
extern Wind_edit_params tree_form, desc_form ;

extern Preferences prefs ;

int p_index_size = 0 ;
int c_index_size = 0 ;
Index_person *people ;
Index_couple *couples ;
int *matches ;
short pfile_exists[MAX_PEOPLE_BLOCKS] ;
short cfile_exists[MAX_COUPLES_BLOCKS] ;
short pidx_changed, cidx_changed ;
short idx_files_exist = FALSE ;
short tree_loaded = FALSE ;

short number_of_p_blocks = 0 ;
short number_of_c_blocks = 0 ;

People_block *p_block_ptrs[MAX_PEOPLE_BLOCKS] ;
					/* Block space initially reserved with start ptrs	*/
People_block *start_pblock1_ptr, *start_pblock2_ptr ;
Couples_block *c_block_ptrs[MAX_COUPLES_BLOCKS] ;
					/* Block space initially reserved with start ptrs	*/
Couples_block *start_cblock1_ptr, *start_cblock2_ptr ;

int people_in_block[MAX_PEOPLE_BLOCKS] ;	/* references of first		*/
int couples_in_block[MAX_COUPLES_BLOCKS] ;	/* person, couple in block	*/

short pblock_usage[MAX_PEOPLE_BLOCKS] ;
short cblock_usage[MAX_COUPLES_BLOCKS] ;
short pblock_changed[MAX_PEOPLE_BLOCKS] ;
short cblock_changed[MAX_COUPLES_BLOCKS] ;
char *next_pstring_ptr[MAX_PEOPLE_BLOCKS] ;
char *next_cstring_ptr[MAX_COUPLES_BLOCKS] ;
char *pblock_end[MAX_PEOPLE_BLOCKS] ;
char *cblock_end[MAX_COUPLES_BLOCKS] ;

short saving_as = FALSE ;					/* flag set during save as	*/

char overflow[OVERFLOW_SIZE] ;
short overflowed = FALSE ;					/* flag for using overflow	*/

extern OBJECT *menu_ptr ;		/* pointer used to point to				*/
								/* menu bar tree						*/

int next_person, next_couple ;


void  start_new_tree( void )
{
	busy( BUSY_MORE ) ;
	
	if( get_tree_name( data_directory ) )
	{
		if( Dcreate( data_directory ) )		/* if unable to create dir	*/
			rsrc_form_alert( 1, NO_DIR ) ;
		else
		{
			strcpy( save_directory, data_directory ) ;
			close_custom() ;		/* close custom tree if loaded		*/
			custom_file[0] = '\0' ;
			clear_windows() ;		/* close any open windows before	*/
									/* clearing blocks they use			*/
			clear_blocks() ;
			free_blocks() ;
			clear_indexes() ;
			idx_files_exist = FALSE ;
			pidx_changed = TRUE ;	/* force save to happen				*/
			cidx_changed = TRUE ;
			if( people && couples && get_initial_blocks() )
			{
				save_indexes() ;	/* create empty index files			*/
				menu_enables( 1 ) ;	/* allow menu options				*/
			}
			else
			{
				menu_enables( 0 ) ;
				rsrc_form_alert( 1, NO_MEMORY ) ;
			}
		}
	}
	busy( BUSY_LESS ) ;
}


void  load_tree( void )
{
	char *idx_ptr, index_path[2*FNSIZE+FMSIZE] ;
	
	busy( BUSY_MORE ) ;
	if( get_tree_name( data_directory ) )
	{			/* Check whether index can be found in directory.	*/
				/* If not, it may be because a file has been		*/
				/* selected. This can happen with Little Green File	*/
				/* selector for example even when you do not click	*/
				/* on a file. If the file name is removed and an	*/
				/* index file can be found, assume this has			*/
				/* happened and remove name from directory name.	*/
	
		sprintf( index_path, "%s\\p_index.gen", data_directory ) ;
		if( access( index_path, 0 ) == -1 )
		{
			idx_ptr = index_path + strlen( data_directory ) - 1 ;
			while( *(--idx_ptr) != '\\' ) ;
			*idx_ptr = '\0' ;
			strcat( index_path, "\\p_index.gen" ) ;
			if( access( index_path, 0 ) != -1 )
			{
				*idx_ptr = '\0' ;
				strcpy( data_directory, index_path ) ;
				save_defaults() ;
			}
		}
		
		load_chosen_tree() ;
	}
	busy( BUSY_LESS ) ;
}


void  load_chosen_tree( void )
{
	short flag ;
	
	strcpy( save_directory, data_directory ) ;

	flag = 0 ;
	load_preferences() ;
	load_custom() ;				/* load customisation file			*/
	close_custom() ;			/* close custom tree if loaded		*/
	custom_file[0] = '\0' ;
	clear_windows() ;			/* close any open windows before	*/
								/* clearing blocks they use			*/
	clear_blocks() ;
	free_blocks() ;
	clear_indexes() ;
	if( people && couples && get_initial_blocks() )
	{
		idx_files_exist = TRUE ;
		tree_loaded = load_indexes() ;
		if( tree_loaded )
		{
			flag = 1 ;
			pidx_changed = FALSE ;
			cidx_changed = FALSE ;
		}
	}
	else  rsrc_form_alert( 1, NO_MEMORY ) ;

	menu_enables( flag ) ;
							/* If tree name OK allow save of config	*/
							/* whether fail or not as config may be	*/
							/* cause of failure.					*/
	menu_ienable( menu_ptr, SAVE_PREF, 1 ) ;
}

void  save_tree_as( void )
{
	short block ;
	int pref, cref ;

	get_tree_name( save_directory ) ;
	
	if( strcmp( save_directory, data_directory ) )
	{
		saving_as = TRUE ;
		Dcreate( save_directory ) ;
		
		for( pref = 0 ; pref < next_person ; pref += PEOPLE_PER_BLOCK )
		{
			if( !pref )  pref = 1 ;				/* No person 0		*/
			get_pdata_ptr( pref, &block ) ;		/* load every block	*/
		}
		for( cref = 0 ; cref < next_couple ; cref += COUPLES_PER_BLOCK )
		{
			if( !cref )  cref = 1 ;				/* No couple 0		*/
			get_cdata_ptr( cref, &block ) ;		/* load every block	*/
		}
		pidx_changed = TRUE ;		/* force save of indexes		*/
		cidx_changed = TRUE ;
		store_data() ;				/* save what is left in blocks	*/
	
		save_custom() ;				/* save user settings			*/
		save_preferences() ;

		saving_as = FALSE ;
		strcpy( data_directory, save_directory ) ;
	}
	else  store_data() ;
}


void  clear_windows( void )
{
	if( pers_form.fm_handle > 0 )  close_person() ;
	if( coup_form.fm_handle > 0 )  close_couple() ;
	if( tree_form.fm_handle > 0 )  close_tree() ;
	if( desc_form.fm_handle > 0 )  close_desc() ;
}


void  menu_enables( short flag )
{
		menu_ienable( menu_ptr, NEW_PERSON, flag ) ;
		menu_ienable( menu_ptr, EDIT_PERSON, flag ) ;
		menu_ienable( menu_ptr, SAVE_TREE, flag ) ;
		menu_ienable( menu_ptr, SAVE_TREE_AS, flag ) ;
		menu_ienable( menu_ptr, EXPORT, flag ) ;
		menu_ienable( menu_ptr, IMPORT, flag ) ;
		menu_ienable( menu_ptr, CHECK_TREE, flag ) ;
		menu_ienable( menu_ptr, DISP_TREE, flag ) ;
		menu_ienable( menu_ptr, DISP_DESCEND, flag ) ;
		menu_ienable( menu_ptr, DISP_CUSTOM, flag ) ;
		menu_ienable( menu_ptr, NEW_CUSTOM, flag ) ;
		menu_ienable( menu_ptr, OPEN_CUSTOM, flag ) ;
		menu_ienable( menu_ptr, SAVE_PREF, flag ) ;
		menu_ienable( menu_ptr, NAME_FLAGS, flag ) ;
		menu_ienable( menu_ptr, PRINT_TREE, flag ) ;
		menu_ienable( menu_ptr, PRINT_PERSON, flag ) ;
		menu_ienable( menu_ptr, PRINT_INDEX, flag ) ;
		menu_ienable( menu_ptr, PRINT_DESCEND, flag ) ;
}


short  get_initial_blocks( void )
{
	start_pblock1_ptr = (People_block *) pmalloc( sizeof (People_block)
														+ prefs.pblock_size ) ;
	start_pblock2_ptr = (People_block *) pmalloc( sizeof (People_block)
														+ prefs.pblock_size ) ;
	start_cblock1_ptr = (Couples_block *) pmalloc( sizeof (Couples_block)
														+ prefs.cblock_size ) ;
	start_cblock2_ptr = (Couples_block *) pmalloc( sizeof (Couples_block)
														+ prefs.cblock_size ) ;

	if( start_pblock1_ptr && start_pblock2_ptr && start_cblock1_ptr
												&& start_cblock2_ptr )
		return TRUE ;
	else  return FALSE ;

}


void  clear_blocks( void )
{
	short block ;

	for( block=0; block<number_of_p_blocks; block++ )
	{
		clear_pblock( block ) ;
		people_in_block[block] = -1 ;
		pblock_changed[block] = FALSE ;
	}
	for( block=0; block<number_of_c_blocks; block++ )
	{
		clear_cblock( block ) ;
		couples_in_block[block] = -1 ;
		cblock_changed[block] = FALSE ;
	}
	overflowed = FALSE ;
}


void  clear_pblock( short block )	/* Initialise all people data in	*/
									/* block and set text pointer to	*/
									/* start of text space				*/
{
	short block_index ;

	for( block_index=0; block_index<PEOPLE_PER_BLOCK; block_index++ )
		clear_person( block, block_index ) ;
	next_pstring_ptr[block] = &p_block_ptrs[block]->people_text ;
	pfile_exists[block] = FALSE ;
}


void  clear_cblock( short block )	/* Initialise all couples data in	*/
					/* block and set text pointer	*/
					/* to start of text space	*/
{
	short block_index ;

	for( block_index=0; block_index<COUPLES_PER_BLOCK; block_index++ )
		clear_couple( block, block_index ) ;
	next_cstring_ptr[block] = &c_block_ptrs[block]->couples_text ;
	cfile_exists[block] = FALSE ;
}


void  delete_person( int ref )
{
	short blk, blk_index ;

	get_pdata_ptr( ref, &blk ) ;
	blk_index = ref % PEOPLE_PER_BLOCK ;
	clear_person( blk, blk_index ) ;
	pblock_changed[blk] = TRUE ;
	
	people[ref].birth_date = DELETED_DATE ;
	people[ref].family_name[0] = '\0' ;
	people[ref].forename[0] = '\0' ;
	pidx_changed = TRUE ;
}


void  clear_person( short block, short block_index )
			/* Initilise all people data in block	*/
{
	Person *this_person ;

	this_person = &(p_block_ptrs[block]->people[block_index]) ;
	
	this_person->reference = 0  ;
	this_person->family_name = NULL ;
	this_person->forenames = NULL ;
	this_person->sex = '?' ;
	this_person->birth_date = 0 ;
	this_person->birth_place = NULL ;
	this_person->birth_source = NULL ;
	this_person->occupation = NULL ;
	this_person->baptism_place = NULL ;
	this_person->baptism_source = NULL ;
	this_person->baptism_date = 0 ;
	this_person->death_date = 0 ;
	this_person->death_place = NULL ;
	this_person->burial_place = NULL ;
	this_person->burial_date = 0 ;
	this_person->death_source = NULL ;
	this_person->will_date =0L ;
	this_person->will_wit1 = NULL ;
	this_person->will_wit2 = NULL ;
	this_person->will_exe1 = NULL ;
	this_person->will_exe2 = NULL ;
	this_person->will_sol = NULL ;
	this_person->will_bens = NULL ;
	this_person->will_bens2 = NULL ;
	this_person->will_bens3 = NULL ;
	this_person->parents = 0 ;
	this_person->couplings = NULL ;
	this_person->notes = NULL ;
	this_person->flags = 0 ;
}


void  clear_couple( short block, short block_index )
			/* Initilise all couples data in block	*/
{
	Couple *this_couple ;

	this_couple = &(c_block_ptrs[block]->couples[block_index]) ;
	
	this_couple->reference = 0 ;
	this_couple->male_reference = 0 ;
	this_couple->female_reference = 0 ;
	this_couple->wedding_date = 0 ;
	this_couple->wedding_place = NULL ;
	this_couple->wedding_source = NULL ;
	this_couple->wedd_wit1 = NULL ;
	this_couple->wedd_wit2 = NULL ;
	this_couple->children = NULL ;
	this_couple->divorce_date = 0 ;
	this_couple->divorce_source = NULL ;
}


void  clear_indexes( void )
{
	int person, couple ;

	if( prefs.max_people != p_index_size )
	{
		if( people )  free( people ) ;
		if( matches )  free( matches ) ;

		people = (Index_person *) pmalloc( prefs.max_people * sizeof (Index_person) ) ;
		if( people )  p_index_size = prefs.max_people ;
		else  p_index_size = 0 ;
		matches = (int *) pmalloc( (prefs.max_people + 1) * sizeof (int) ) ;
	}
	if( people )
	{
		for( person=0; person<prefs.max_people; person++ )
		{
			people[person].family_name[0] = '\0' ;
			people[person].forename[0] = '\0' ;
			people[person].birth_date = 0 ;
			people[person].flags = 0 ;
		}
	}
	next_person = 1 ;

	if( prefs.max_couples != c_index_size )
	{
		if( couples )  free( couples ) ;

		couples = (Index_couple *) pmalloc( prefs.max_couples * sizeof (Index_couple) ) ;
		if( couples )  c_index_size = prefs.max_couples ;
		else  c_index_size = 0 ;
	}
	if( couples )
	{
		for( couple=0; couple<prefs.max_couples; couple++ )
		{
			couples[couple].male_reference = 0 ;
			couples[couple].female_reference = 0 ;
			couples[couple].wedding_date = 0 ;
		}
	}
	next_couple = 1 ;

	if( people == NULL || couples == NULL || matches == NULL )
		rsrc_form_alert( 0, NO_INDEX_MEM ) ;
}
	
	
Person *get_pdata_ptr( int reference, short *block )
			/* This routine first checks whether person is	*/
			/* already loaded and if not loads				*/
			/* them from disc. It returns a pointer to them	*/
			/* in the block.								*/
{
	short i ;
	int file_number ;		/* File number is reference divided by the	*/
	short block_index ;		/* number of people per block. Block index	*/
							/* is reference relative to first entry.	*/
	short blk = -1 ;		/* block containing person's data			*/
														
	block_index = reference % PEOPLE_PER_BLOCK ;	
	file_number = reference - block_index ;
					/* Search blocks to see if loaded	*/
	i = 0 ;
	while( i < number_of_p_blocks )
	{
		if( people_in_block[i] == file_number )  blk = i ;
		i++ ;
	}
					/* If not, load them.			*/
	if( blk == -1 )
	{	busy( BUSY_MORE ) ;
		blk = get_new_pblock( reference ) ;
		busy( BUSY_LESS ) ;
	}
								/* Find block in block usage array		*/
								/* and move it up one position unless	*/
								/* it is already first.					*/
	if( blk != -1 )
	{	promote_block( blk, pblock_usage ) ;
		*block = blk ;			/* set up block value					*/
		return &(p_block_ptrs[blk]->people[block_index]) ;
	}
	else  return NULL ;
}


Couple   *get_cdata_ptr( int reference, short *block )
			/* This routine first checks whether couple is	*/
			/* already loaded in a block, and if not loads	*/
			/* them from disc. It returns a pointer to them	*/
			/* in the block.								*/
{
	short i ;
	int file_number ;		/* File number is reference divided by the	*/
	short block_index ;		/* number of couples per block. Block index	*/
							/* is reference relative to first entry.	*/
	short blk = -1 ;		/* block containing person's data			*/

	block_index = reference % COUPLES_PER_BLOCK ;	
	file_number = reference - block_index ;

	i = 0 ;
	while( i < number_of_c_blocks )
	{
		if( couples_in_block[i] == file_number )  blk = i ;
		i++ ;
	}
	
	if( blk == -1 )
	{
		busy( BUSY_MORE ) ;
		blk = get_new_cblock( reference ) ;
		busy( BUSY_LESS ) ;
	}

	if( blk != -1 )
	{
		promote_block( blk, cblock_usage ) ;
		*block = blk ;				/* set up block value					*/
		return &(c_block_ptrs[blk]->couples[block_index]) ;
	}
	else  return NULL ;
}


void  promote_block( short blk, short *block_usage_array )
{
	short i = 0 ;

	while( block_usage_array[i] != blk ) i++ ;
	if( i )
	{
		block_usage_array[i] = block_usage_array[i-1] ;
		block_usage_array[i-1] = blk ;
	}
}



short  get_new_pblock( int ref )
			/* Attempt to get a new block of memory. If there	*/
			/* is insufficient memory available save least used	*/
			/* block and load new data into it.			*/
{
	People_block *block_ptr = NULL ;
	short block ;
	short fail = FALSE ;

	while( !fail && block_ptr == NULL )
	{
		if( number_of_p_blocks == 0 )
			block_ptr = start_pblock1_ptr ;
		else if( number_of_p_blocks == 1 )
			block_ptr = start_pblock2_ptr ;
		else if( number_of_p_blocks < MAX_PEOPLE_BLOCKS )
		{
			block_ptr = (People_block *) pmalloc( sizeof (People_block)
														+ prefs.pblock_size ) ;
			if( block_ptr )				/* Releasable memory now used		*/
				menu_ienable( menu_ptr, RELEASE_MEMORY, 1 ) ;
		}
				/* If successful record entry in block usage.	*/
		if( block_ptr )
		{
			block = number_of_p_blocks++ ;
			pblock_usage[block] = block ;
			p_block_ptrs[block] = block_ptr ;
			pblock_end[block] = &(block_ptr->people_text) + prefs.pblock_size ;
		}
				/* Else save least used block and put new one in	*/
				/* its position. First ensure least used block is	*/
				/* not current edit block.							*/
		else if( !saving_as )
		{
			while( block = pblock_usage[number_of_p_blocks - 1],
												block == edit_pers_block )
				promote_block( block, pblock_usage ) ;
			if( pblock_changed[block] )
			{	
				if( !save_pblock( block ) )  fail = TRUE ;
				else  store_data() ;	/* Save rest of data to ensure	*/
										/* consistency of data on disc.	*/
			}
			block_ptr = p_block_ptrs[block] ;
		}
		else  release_memory() ;

	}
	if( !fail )
	{
		clear_pblock( block ) ;
						/* Unless this is a new person and first in a	*/
						/* block, load block. New person if reference	*/
						/* equals next reference. Reference = 1 is a	*/
						/* special case of first in a block as 0 is not	*/
						/* used.										*/
		if( ( ref != next_person )
					|| ( ( ref % PEOPLE_PER_BLOCK ) && ( ref != 1 ) ) )
		{	
			if( !load_pblock( block, ref ) )  fail = TRUE ;
		}
		else
		{
			pfile_exists[block] = FALSE ;
			if( ref != 1 )  people_in_block[block] = ref ;
			else  people_in_block[block] = 0 ;
		}
		pblock_changed[block] = FALSE ;
	}
	if( !fail )  return block ;
	else  return -1 ;
}


short  get_new_cblock( int ref )
{
	Couples_block *block_ptr = NULL ;
	short block ;
	short fail = FALSE ;

	while( !fail && block_ptr == NULL )
	{
		if( number_of_c_blocks == 0 )
			block_ptr = start_cblock1_ptr ;
		else if( number_of_c_blocks == 1 )
			block_ptr = start_cblock2_ptr ;
		else if( number_of_c_blocks < MAX_COUPLES_BLOCKS )
		{	
			block_ptr = (Couples_block *) pmalloc( sizeof (Couples_block)
														+ prefs.cblock_size ) ;
			if( block_ptr )				/* Releasable memory now used		*/
				menu_ienable( menu_ptr, RELEASE_MEMORY, 1 ) ;
		}
		
		if( block_ptr )
		{	
			block = number_of_c_blocks++ ;
			cblock_usage[block] = block ;
			c_block_ptrs[block] = block_ptr ;
			cblock_end[block] = &(block_ptr->couples_text) + prefs.cblock_size ;
		}
				/* Else save least used block and put new one in	*/
				/* its position. First ensure least used block is	*/
				/* not current edit block.							*/
		else if( !saving_as )
		{	
			while( block = cblock_usage[number_of_c_blocks - 1],
												block == edit_coup_block )
				promote_block( block, cblock_usage ) ;
			if( cblock_changed[block] )
			{	
				if( !save_cblock( block ) )  fail = TRUE ;
				else  store_data() ;	/* Save rest of data to ensure	*/
										/* consistency of data on disc.	*/
			}
			block_ptr = c_block_ptrs[block] ;
		}
		else		/* when saving_as save data and go round loop again	*/
		{	
			release_memory() ;
		}
	}
	if( !fail )
	{	
		clear_cblock( block ) ;
						/* Unless this is a new person and first in a	*/
						/* block, load block. New person if reference	*/
						/* equals next reference. Reference = 1 is a	*/
						/* special case of first in a block as 0 is not	*/
						/* used.										*/
		if( ( ref != next_couple )
						|| ( ( ref % COUPLES_PER_BLOCK ) && ( ref != 1 ) ) )
		{	
			if( !load_cblock( block, ref ) )  fail = TRUE ;
		}
		else
		{	
			cfile_exists[block] = FALSE ;
			if( ref != 1 )  couples_in_block[block] = ref ;
			else  couples_in_block[block] = 0 ;
		}
		cblock_changed[block] = FALSE ;
	}

	if( !fail )  return block ;
	else  return -1 ;
}



Person *new_pref( int *ref_ptr , char *buf_ptr, short block )
{
	Person *pptr ;
	short block_index ;

	*ref_ptr = atoi( buf_ptr ) ;
	block_index = *ref_ptr % PEOPLE_PER_BLOCK ;
	pptr = &( p_block_ptrs[block]->people[block_index] ) ;

	return pptr ;
}


Couple  *new_cref( int *ref_ptr , char *buf_ptr, short block )
{
	Couple *cptr ;
	short block_index ;

	*ref_ptr = atoi( buf_ptr ) ;
	block_index = *ref_ptr % COUPLES_PER_BLOCK ;
	cptr = &( c_block_ptrs[block]->couples[block_index] ) ;

	return cptr ;
}


int  form_ref( char **str_ptr )		/* This takes a pointer to a pointer	*/
									/* to a char. It increments the char	*/
									/* pointer through 4 chars which it	*/
									/* builds into a long.				*/
{
	int ref = 0 ;
	short i ;

	for( i=0; i<4; i++ )
	{
		ref = ref << 8 ;
		ref += ( (int) *(*str_ptr)++ ) & 0xFF ;
	}
	return ref ;
}


void  add_coupling( int pref, int cref )
								/* This routine adds a couple reference	*/
								/* to a persons list of couplings. It	*/
								/* checks that it is not already there	*/
								/* first. It also sorts the couplings.	*/
{
	Person *pptr ;
	int *coup, couplings[MAX_COUPLINGS] ;
	short already = FALSE ;
	short entries = 0 ;
	short block ;				/* Needed for get_pdata_ptr.			*/

	if( pptr = get_pdata_ptr( pref, &block ) )
	{
		get_couplings( pptr, couplings ) ;
								/* Check if couple already included		*/
		coup = couplings ;
		while( *coup )
		{
			if( cref == *coup )  already = TRUE ;
			coup++ ;
			entries++ ;
		}
		if( !already )
		{
			*coup++ = cref ;
			*coup = 0 ;
			entries++ ;
			qsort( (void *) couplings, (size_t) entries, (size_t) 4,
														coup_compare ) ;
			put_couplings( pptr, block, couplings ) ;
			pblock_changed[block] = TRUE ;
		}
	}
}


void  remove_coupling( int pref, int cref )
{
	Person *pptr ;
	int *coup, couplings[MAX_COUPLINGS] ;
	short entries = 0 ;
	short block ;				/* Needed for get_pdata_ptr.			*/

	if( pptr = get_pdata_ptr( pref, &block ) )
	{
		get_couplings( pptr, couplings ) ;

		coup = couplings ;
		while( *coup )
		{
			if( *coup == cref )  *coup = 0 ;
			coup++ ;
			entries++ ;
		}

		qsort( (void *) couplings, (size_t) entries, (size_t) 4,
														coup_compare ) ;
		if( couplings[0] )  put_couplings( pptr, block, couplings ) ;
		else  pptr->couplings = NULL ;
		pblock_changed[block] = TRUE ;
	}
}


	

void  get_couplings( Person *pptr, int *couplings )
{
	int *coup_ptr ;
	char *coup_str ;
	int cref ;
	
	coup_ptr = couplings ;
	if( coup_str = pptr->couplings )
	{
		while( cref = form_ref( &coup_str ) )  *coup_ptr++ = cref ;
	}
	*coup_ptr = 0 ;
}
			

void  put_couplings( Person *pptr, short block, int *couplings )
{
	int *coup ;
	char *next_str ;
	short count = 0 ;
	char *next_end ;
	
	coup = couplings ;
	while( *coup++ )  count++ ;
	next_str = next_pstring_ptr[block] ;
	if( !overflowed )
	{
		next_end = next_str + ( ++count * sizeof (int) ) ;
		if( next_end > pblock_end[block] )
		{
			next_str = overflow ;
			overflowed = TRUE ;
		}
	} 

	coup = couplings ;
	
	pptr->couplings = next_str ;
	while( *coup )
	{
		put_ref( *coup, &next_str ) ;
		coup++ ;
	}
	
	put_ref( 0, &next_str ) ;			/* terminate couplings			*/
	
	next_pstring_ptr[block] = next_str ;
}


void  put_ref( int ref, char **str_ptr )
{
	*(*str_ptr)++ = (char) ( ref >> 24 ) ;
	*(*str_ptr)++ = (char) ( ( ref >> 16 ) & 0xFF ) ;
	*(*str_ptr)++ = (char) ( ( ref >> 8 ) & 0xFF ) ;
	*(*str_ptr)++ = (char) ( ref & 0xFF ) ;
}


void  cput_references( char **ptr_ptr, short block, int *references )
{
	int *refs ;
	char *next_str ;
	short count = 0 ;
	char *next_end ;

	refs = references ;
	while( *refs++ )  count++ ;
	next_str = next_cstring_ptr[block] ;
	if( !overflowed )
	{
		next_end = next_str + ( ++count * sizeof (int) ) ;
		if( next_end > cblock_end[block] )
		{
			next_str = overflow ;
			overflowed = TRUE ;
		}
	} 

	refs = references ;
	
	*ptr_ptr = next_str ;
	while( *refs )
	{
		put_ref( *refs, &next_str ) ;
		refs++ ;
	}
	
	put_ref( 0, &next_str ) ;			/* terminate couplings			*/
	
	next_cstring_ptr[block] = next_str ;
}


int  coup_compare( void *coup1_ref, void *coup2_ref )
{
	int greater ;

	if( *(int *)coup1_ref && *(int *)coup2_ref )
		greater = compare_dates( couples[*(int *)coup1_ref].wedding_date,
								couples[*(int *)coup2_ref].wedding_date ) ;
	else if( *(int *)coup1_ref )  greater = -1 ;
	else if( *(int *)coup2_ref )  greater = 1 ;
	else  greater = 0 ;

	return greater ;
}


void  clear_mem_ptrs( void )
{
	short block ;

	for( block = 0; block < MAX_PEOPLE_BLOCKS; block++ )
	{
		p_block_ptrs[block] = NULL ;
		next_pstring_ptr[block] = NULL ;
		pblock_end[block] = NULL ;
	}
	for( block = 0; block < MAX_COUPLES_BLOCKS; block++ )
	{
		c_block_ptrs[block] = NULL ;
		next_cstring_ptr[block] = NULL ;
		cblock_end[block] = NULL ;
	}
}


void  free_memory( void )
{
	free_blocks() ;

	if( people )  free( people ) ;
	if( matches )  free( matches ) ;
	if( couples )  free( couples ) ;
}


void  free_blocks( void )
{
	short block ;
	char *blk_ptr ;

	clear_blocks() ;	/* I am not sure whether this is needed	*/
						/* but it is here in case any block		*/
						/* data could be re-used when releasing	*/
						/* memory.								*/
	for( block = 0; block < number_of_p_blocks; block++ )
		if( blk_ptr = (char *) p_block_ptrs[block], blk_ptr )
			free( blk_ptr ) ;
	number_of_p_blocks = 0 ;
	for( block = 0; block < number_of_c_blocks; block++ )
		if( blk_ptr = (char *) c_block_ptrs[block], blk_ptr )
			free( blk_ptr ) ;
	number_of_c_blocks = 0 ;

				/* There is now no memory which can be released.	*/
	menu_ienable( menu_ptr, RELEASE_MEMORY, 0 ) ;
}


void  release_memory( void )
{
	save_current_edits() ;
	store_data() ;
	free_blocks() ;
	get_initial_blocks() ;
	if( edit_pers_ref )
		edit_pers_pptr = get_pdata_ptr( edit_pers_ref, &edit_pers_block ) ;
	if( edit_coup_ref )
		edit_coup_cptr = get_cdata_ptr( edit_coup_ref, &edit_coup_block ) ;
}


int  get_next_couple( int current_ref, int pers_ref )
{
	Person *pptr ;
	short block ;
	char *coupls_ptr ;

	pptr = get_pdata_ptr( pers_ref, &block ) ;
	coupls_ptr = pptr->couplings ;
	while( current_ref != form_ref( &coupls_ptr ) ) ;

	return form_ref( &coupls_ptr ) ;
}


int  get_next_child( int current_ref, int coup_ref )
{
	Couple *cptr ;
	short block ;
	char *children_ptr ;

	cptr = get_cdata_ptr( coup_ref, &block ) ;
	children_ptr = cptr->children ;
	while( current_ref != form_ref( &children_ptr ) ) ;

	return form_ref( &children_ptr ) ;
}

