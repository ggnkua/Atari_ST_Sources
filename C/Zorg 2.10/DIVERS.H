/* divers.s */
int		mediach( int device );
long	search_pattern_ste( char *buffer, long size, char *pattern, int pattern_size );
long	search_pattern_ets( char *buffer, long size, char *pattern, int pattern_size );
void	and_buffer( char *buffer, long size );
int		hard_read( long debut, int nombre, char *buffer, int control );
int		hard_write( long debut, int nombre, char *buffer, int control );
void	reset000( void );
void	reset030( void );
void	swap_flopy_FAT( unsigned int *FAT, unsigned int *local_FAT, int numcl );
void	swap_FAT( unsigned int *FAT, unsigned int *local_FAT, int size );
void	re_swap_flopy_FAT( unsigned int *FAT, unsigned int *local_FAT, int numcl );
void	trans_dir_elt_short( dir_elt_short *destination, real_dir_elt *source );
void	re_trans_dir_elt_short( real_dir_elt *destination, dir_elt_short *source );
void	trans_dir_elt_vfat( dir_elt_vfat *destination, real_dir_elt *source );
void	re_trans_dir_elt_vfat( real_dir_elt *destination, dir_elt_vfat *source );
void	convert_sect( char *secteurBin, char *secteurLigne[], int ascii );
