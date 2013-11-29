/************************************************************************/
/*																		*/
/*		Gendata.h	31 Dec 95											*/
/*																		*/
/************************************************************************/

/* Header file for GEN containing #DEFINES and							*/
/* prototype definitions												*/

typedef struct people_block
{	Person	people[PEOPLE_PER_BLOCK] ;
	char	*next_string ;
	char	people_text ;
} People_block ;

typedef struct couples_block
{	Couple	couples[COUPLES_PER_BLOCK] ;
	char	*next_string ;
	char	couples_text ;
} Couples_block ;

											/* Routines in GENDATA.C	*/
void	start_new_tree( void ) ;
void	load_tree( void ) ;
void	load_chosen_tree( void ) ;
void	save_tree_as( void ) ;
void	clear_windows( void ) ;
void	menu_enables( short flag ) ;
short	get_initial_blocks( void ) ;
void	clear_blocks( void ) ;
void	clear_pblock( short block ) ;
void	clear_cblock( short block ) ;
void	delete_person( int ref ) ;
void	clear_person( short block_number, short block_index ) ;
void	clear_couple( short block_number, short block_index ) ;
void	clear_indexes( void ) ;
short	get_new_pblock( int reference ) ;
short	get_new_cblock( int reference ) ;
Person	*get_pdata_ptr( int reference, short *block ) ;
Couple	*get_cdata_ptr( int reference, short *block ) ;
void	promote_block( short blk, short *block_usage_array ) ;
Person	*new_pref( int *ref_ptr , char *buf_ptr, short block ) ;
Couple	*new_cref( int *ref_ptr , char *buf_ptr, short block ) ;
int		form_ref( char **str_ptr ) ;
void	add_coupling( int pref, int cref ) ;
void	remove_coupling( int pref, int cref ) ;
void	get_couplings( Person *pptr, int *couplings ) ;
void	put_couplings( Person *pptr, short block, int *couplings ) ;
void	cput_references( char **ptr_ptr, short block, int *references ) ;
void	put_ref( int ref, char **str_ptr ) ;
int		coup_compare( void *coup1_ref, void *coup2_ref ) ;
void	clear_mem_ptrs( void ) ;
void	free_memory( void ) ;
void	free_blocks( void ) ;
void	release_memory( void ) ;
int		get_next_couple( int current_ref, int pers_ref ) ;
int		get_next_child( int current_ref, int coup_ref ) ;
