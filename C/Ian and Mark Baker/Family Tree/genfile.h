/************************************************************************/
/*																		*/
/*		Genfile.h	22 Jan 95											*/
/*																		*/
/************************************************************************/

/* Header file for GENFILE containing #DEFINES and						*/
/* prototype definitions												*/

											/* Routines in GENFILE.C	*/
void	store_data( void ) ;
short	get_tree_name( char *data_directory ) ;
short	save_pblock( short block ) ;
void	save_std_pdata( Person *p_ptr, FILE *fp ) ;
short	save_cblock( short block ) ;
void	save_std_cdata( Couple *c_ptr, FILE *fp ) ;
short	load_pblock( short block, int reference ) ;
void	load_pparam( int parameter, Person *pptr, char *buf_ptr,
									short block, char *buffer, FILE *fp ) ;
short	load_cblock( short block, int reference ) ;
void	load_cparam( int parameter, Couple *cptr, char *buf_ptr,
															short block ) ;
void	copy_str( char **str_ptr, char *buf_ptr, char **blk_ptr,
													char *block_end ) ;
void	copy_notes( char **notes, char *buffer, char **blk_ptr ,
										FILE **fp_ptr, char *block_end ) ;
void	copy_refs( char **dest_ptr, char *buf_ptr, char **next_ptr,
													char *block_end ) ;
FILE	*f_exopen( char *filename, char *mode, short exists ) ;
short	save_indexes( void ) ;
short	load_indexes( void ) ;
void	load_preferences( void ) ;
