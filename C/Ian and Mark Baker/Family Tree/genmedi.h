/************************************************************************/
/*																		*/
/*		Genmedi.h	 3 Nov 99											*/
/*																		*/
/************************************************************************/

/* Header file for GENMEDI containing #DEFINES and						*/
/* prototype definitions												*/

typedef struct list_item *List_item_ptr ;
typedef struct list_item
{
	void *data_ptr ;
	List_item_ptr next_ptr, previous_ptr ;
} List_item ;

typedef struct association
{
	char ext[5] ;
	char *program ;
	char va ;
	char status ;
} Association ;

											/* Routines in GENMEDI.C	*/
void	add_to_list( List_item *addition, List_item **first, List_item **last, short (*compare)( const void*, const void* ) ) ;
void	remove_from_list( List_item* entry, List_item **first, List_item **last ) ;
List_item	*get_next_entry( List_item* entry ) ;
List_item	*get_matching_entry( List_item *first, void *entry, short (*compare)( const void*, const void* ) ) ; 
int	count_entries( List_item* first ) ;

void	shorten_file_name( char* dest, char* src, short len ) ;

short	compare_association( const void *assoc1, const void *assoc2 ) ;
List_item	*add_association( Association *assoc ) ;
Association	*new_association( char *ext, char *prog, char va ) ;
void	free_association( Association *assoc_ptr ) ;

void	set_file_association_addrs( void ) ;
void	update_file_associations_list( Association *assocs[], short ok ) ;
short	display_associations( Association **assocs, short offset, short *return_entries, char *ext ) ;
void	add_to_file_associations( char *filetype ) ; 
void	set_file_associations( char *ext ) ;
void	save_associations( FILE *fp ) ;
void	load_association( char* str ) ;
short	get_associated_program( char *prog, const char *filename, char *va ) ;
