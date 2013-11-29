/************************************************************************/
/*																		*/
/*		Genmerg.h	21 Jun 1996											*/
/*																		*/
/************************************************************************/

/* Header file for GENMERG.C containing #DEFINES and					*/
/* prototype definitions												*/

#define FAMTREE_TYPE 0
#define GEDCOM_TYPE 1
#define CSV_TYPE 2

											/* Routines in GENMERG.C	*/
void	export_tree( void )  ;
short	select_exports( short *transfer_type ) ;
void	list_exportees( int oset ) ;
void 	set_esel_form_addrs( void ) ;
void	set_efil_form_addrs( void ) ;
void	clear_efil_form( void ) ;
void 	set_cross_refs( void ) ;
int		write_transfer_file( short transfer_type ) ;
void	write_std_transfer_header( FILE *fp ) ;
void	write_gedcom_transfer_header( FILE *fp ) ;
short	get_transfer_file_name( short transfer_type ) ;
void	write_std_transfer_person( int pers, FILE *fp ) ;
void	write_std_transfer_couple( int coup, FILE *fp ) ;
void	ancestor_select( int reference ) ;
void	descendant_select( int reference, int excluded_child,
													int excluded_couple ) ;
void	import_tree( void ) ;
short	read_trans_hdr_type( FILE *fp ) ;
void	load_std_trans_hdr( FILE *fp ) ;
void	import_flag_string( short flag_number, char *buf_ptr ) ;
short	check_hdr( void ) ;
void	load_trans_people( FILE *fp ) ;
void	load_trans_couples( FILE *fp ) ;

