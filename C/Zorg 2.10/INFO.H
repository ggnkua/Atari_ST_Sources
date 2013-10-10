/* info.c */
void	get_name_from_cluster_short( int drive, unsigned int cluster, char *name, int size );
void	get_name_from_cluster_vfat( int drive, unsigned int cluster, char *name, int size );
void	structure_test_short( int drive );
void	structure_test_vfat( int drive );
boolean	create_file_short( char *name, unsigned int first_cluster, long size, dir_elt_short arbo[], int drive );
boolean	create_file_vfat( char *name, unsigned int first_cluster, long size, dir_elt_vfat arbo[], int drive );
boolean	info_load_dir_short( dir_elt_short *(arbo[]), long table[], int max, int drive, unsigned int first_cluster, unsigned int *fat, long s_min, long s_max, int *minor, char *name, dir_elt_short ** cluster );
boolean	info_load_dir_vfat( dir_elt_vfat *(arbo[]), long table[], int max, int drive, unsigned int first_cluster, unsigned int *fat, long s_min, long s_max, int *minor, char *name, dir_elt_vfat ** cluster );
int		info_create_table( unsigned int first_cluster, long *(table[]), int drive, unsigned int *fat, char *name );
void	statistiques( int drive );
void	compte_fichiers_short( int drive, dir_elt_short dir[], unsigned int fat[], int *file, int *directory, int *file_frac );
void	compte_fichiers_vfat( int drive, dir_elt_vfat dir[], unsigned int fat[], int *file, int *directory, int *file_frac );
void	occupation( int drive );
void	informations( int drive );
void	trace_file( void );
