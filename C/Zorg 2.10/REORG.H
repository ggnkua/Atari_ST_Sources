/* reorg.c */
void	nettoie_repertoire( int drive );
boolean	nettoie_dir_short( dir_elt_short arbo[], int max );
boolean	nettoie_dir_vfat( dir_elt_vfat arbo[], int max );
void	nettoie_clusters_libres( int drive );
void	reconnect( int drive );
boolean	reconnect2( int drive );
boolean	reconnect_dir_short( dir_elt_short arbo[], int max, int drive, BPB *bpb, char *buffer, long buffer_size );
boolean	reconnect_dir_vfat( dir_elt_vfat arbo[], int max, int drive, BPB *bpb, char *buffer, long buffer_size );
void	nettoie_repertoire( int drive );
void	compresse( int drive );
boolean	compresse2( int drive );
void	compresse_dir_short( dir_elt_short arbo[], int max, unsigned int redirect[] );
void	compresse_dir_vfat( dir_elt_vfat arbo[], int max, unsigned int redirect[] );
void	restauration_complete( int drive );
