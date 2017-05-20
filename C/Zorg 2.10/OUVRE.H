/* ouvre.c */
void	get_max_name( char *nom, char *dest, int size, boolean menu );
void	voir_fichier( void );
void	really_voir_fichier( char *filename );
void	open_file_other_fs( void );
void	really_open_file_other_fs( char *nom );
void	open_disk( void );
void	open_file( void );
void	open_directory_short( void );
void	open_directory_vfat( void );
boolean	open_directory_proc_short( t_dialog *dialog, int exit );
boolean	open_directory_proc_vfat( t_dialog *dialog, int exit );
boolean	directory_entry( dir_elt_vfat *file );
void	fermer( int handle );
