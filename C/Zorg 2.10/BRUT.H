/* brute.c */
void	raw_floppy( int config );
boolean	raw_floppy_proc( t_dialog *dialog, int exit );
void	raw_hard( int config );
boolean	raw_hard_proc( t_dialog *dialog, int exit );
void	open_raw_floppy( char secteur, char piste, char face, char lecteur );
void	open_raw_hard( int unit, long secteur );
int		my_floppy_read( char *buffer, int taille, int offset, int secteurs, int faces, char lecteur );
int		my_rwabs( int rwflag, char *buffer, int cnt, long recnr, int dev );
int		my_DMAread( long sector, int count, char *buffer, int devno );
int		my_DMAwrite( long sector, int count, char *buffer, int devno );
void	*sector_alloc( unsigned int size );
void	sector_free( void *ptr );
