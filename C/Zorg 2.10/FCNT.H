/* boot.c */
void	lire_boot( void );
void	info_boot( void );
void	ecrire_boot( void );
void	charger_boot( void );
void	sauver_boot( void );

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

/* curseur.c */
void	curseur_on( windowptr thewin );
void	edit( windowptr thewin, int key, int shift );
void	update_curseur( windowptr thewin, int xon, int yon, int xoff, int yoff, int affiche );
void	curseur_up( windowptr thewin, boolean full );
void	curseur_down( windowptr thewin, boolean full );
void	curseur_left( windowptr thewin, int ascii, boolean full );
void	curseur_right( windowptr thewin, int ascii, boolean full );
void	curseur_home( windowptr thewin, boolean full );

/* config.c */
void	couleur( windowptr thewin );
boolean	couleur_proc( t_dialog *dialog, int exit );
void	raccourcis_clavier( void );
boolean	raccourcis_proc( t_dialog *dialog, int exit );
void	config_generale( void );
boolean	config_generale_proc( t_dialog *dialog, int exit );
void	config_disques( void );
boolean	config_disques_proc( t_dialog *dialog, int exit );
void	raccourcis_clavier( void );
boolean	read_config( void );
boolean	save_config( void );

/* deplace.c */
boolean	update_goto_marque( windowptr thewin, int pos, int fast );
boolean	update_goto_dialog( windowptr thewin, int pos, int fast );
boolean	update_goto( windowptr thewin, int pos, int fast );
void	goto_marque( windowptr thewin );
boolean	goto_marque_proc( t_dialog *dialog, int exit );
void	next_secteur( windowptr thewin );
void	previous_secteur( windowptr thewin );
void	next_bloc( windowptr thewin );
void	previous_bloc( windowptr thewin );
void	goto_secteur( windowptr thewin );
boolean	goto_secteur_proc( t_dialog *dialog, int exit );
boolean	goto_offset_proc( t_dialog *dialog, int exit );
boolean	goto_raw_secteur_proc( t_dialog *dialog, int exit );
void	marquer_position( windowptr thewin );

/* desk.c */
void	read_desktop( void );
void	do_desk( int mousex, int mousey , int double_clic, int key );
void	init_desk( boolean mode );
void	redraw_desk( void );

/* dialog.c */
t_dialog	*find_dialog( windowptr thewin );
void	my_close_dialog( t_dialog *dialog );
int		my_open_dialog( t_dialog *dialog, int dial_mode, int edit);
void	paraminfo( char *string1, char *string2 );
void	error_msg( int err );
int		selecteur( char *nom, char *filtre, char *info );
int		choix_unit( void );
int		real_time_slide( windowptr thewin, OBJECT *arbre, int pere, int fils, int timer, boolean (*redraw)( windowptr thewin, int pos, int fast ), int sens );
int		rt_init( XEVENT *evt, int events_available );
int		rt_message( XEVENT *event );
int		my_alert( int b_default, int undo, int icon, char *texts, char *buttons );

/* liste des erreurs ZORG */
#define Z_READ_WRITE 1
#define Z_NOT_ENOUGH_MEMORY -39
#define Z_NO_BPB 2
#define Z_NO_MORE_WINDOW 3
#define Z_DMA_RW 4
#define Z_CANT_CREATE_SCRAP 5
#define Z_CLIPBOARD_NOT_INSTALLED 6
#define Z_CLIPBOARD_NOT_INSTALLABLE 7
#define Z_NO_CORRESPONDING_HANDLE 8
#define Z_VIEWER_NOT_LOADED 9
#define Z_HELP_VIEWER_NOT_LOADED 10
#define Z_ERROR_WITH_VIEWER 11

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

/* fat.c */
unsigned int	find_place( int drive, unsigned int size, unsigned int max );
boolean		save_arbo_short( int drive );
boolean		save_arbo_vfat( int drive );
boolean		save_dir_short( dir_elt_short arbo[], long table[], long max, int drive );
boolean		save_dir_vfat( dir_elt_vfat arbo[], long table[], long max, int drive );
void		from_zorg_inf( boolean zorg );
void		update_systeme( int drive );
boolean		change_disque( int drive, boolean verbose );
boolean		load_FAT( int drive );
boolean		save_FAT( int drive );
long		create_file_table( char nom[], long *(table[]), long *size);
dir_elt_short	*find_file_short( char name[] );
dir_elt_vfat	*find_file_vfat( char name[] );
long		create_table( unsigned int first_cluster, long *(table[]), int drive);
boolean		load_arbo_file( int drive, char *filename );
boolean		load_dir_file_short( dir_elt_short *(arbo[]), long table[], long max, int drive, unsigned int first_cluster, char *filename );
boolean		load_dir_file_vfat( dir_elt_vfat *(arbo[]), long table[], long max, int drive, unsigned int first_cluster, char *filename );
boolean		load_arbo( int drive );
boolean		load_dir_short( dir_elt_short *(arbo[]), long table[], long max, int drive, unsigned int first_cluster );
boolean		load_dir_vfat( dir_elt_vfat *(arbo[]), long table[], long max, int drive, unsigned int first_cluster );
void		free_arbo_short( dir_elt_short *dir );
void		free_arbo_vfat( dir_elt_vfat *dir );
BPB			my_getbpb( int drive );
void		create_map_short( dir_elt_short *dir, dir_elt_short *cluster[], unsigned int fat[] );
void		create_map_vfat( dir_elt_vfat *dir, dir_elt_vfat *cluster[], unsigned int fat[] );

/* fenetre.c */
void	get_menu_entry( windowptr thewin, char *nom );
void	ascenseurs( windowptr thewin );
void	ajoute( windowptr thewin, char *text );
void	secteur_file( windowptr thewin );
void	print_secteur_file( windowptr thewin );
void	secteur_window_update( windowptr thewin, int fast );
void	update_slide( windowptr thewin );
void	taille_ideale( windowptr thewin );
void	choix_fonte( windowptr thewin );
boolean	do_mouse( windowptr thewin, int mousex, int mousey, int double_clic );
void	do_mouse_occupation( windowptr thewin, int mousex, int mousey );

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

/* init.c */
boolean	init_resources( void );
boolean	init_menu( void );
void	shutdown( int reset );
void	reset( void );
void	cleanup( void );
OBJECT	*make_slide( GRECT *work, long max );
void	init_drive( void );

/* lance.c */
void	lance_prg( void );
boolean	lance_prg_proc( t_dialog *dialog, int exit );

/* menu.c */
boolean	MenuSelect( int object, int scan, int state, int button );
void	set_shortcuts( void );
void	shortcut_key( int key, int state, char *key_text, boolean fill );
void	aide( void );
void	presentation( void );
boolean	presentation_proc( t_dialog *dialog, int exit );

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

/* search.c */
void	search_secteur(  windowptr thewin, boolean diff_majmin, boolean start_to_end );
void	search_found(  windowptr thewin, long secteur, long offset );
int		load_buffer( windowptr thewin, char *buffer, long secteur, int size, boolean start_to_end );
long	search_pattern( char *buffer, long size, char *pattern, boolean diff_majmin, boolean start_to_end );
void	search_first( windowptr thewin );
boolean	search_proc( t_dialog *dialog, int exit );
void	search_next( windowptr thewin );
void	search_tampon( windowptr thewin, boolean diff_majmin );

/* secteur.c */
void	affichage_decimal( windowptr thewin );
void	secteur_ascii( windowptr thewin );
void	secteur_hexa( windowptr thewin );
void	load_secteur( windowptr thewin, int menu );
void	save_secteur( windowptr thewin, int menu );
int		read_secteur( windowptr thewin, int menu );
int		write_secteur( windowptr thewin, int menu );

/* tampon.c */
void	effacer_tampon( void );
void	creer_fichier( void );
void	sauver_tampon( void );
void	copier_tampon( windowptr thewin );
void	coller_tampon( windowptr thewin );
void	echanger_tampon( windowptr thewin );
void	ouvrir_tampon( void );
void	fermer_tampon( void );
char	m_ascii_box( char car, int modal );
boolean	m_ascii_box_proc( t_dialog *dialog, int exit );
void	ascii_tampon( void );
void	creer_tampon( void );
void	copier_clipboard( windowptr thewin, char *scrap_path );
void	coller_clipboard( char *scrap_path );
boolean	test_scrap_path( char *scrap_path );
void	clipboard_gem( windowptr thewin );

/* update.c */
void	occupationproc( int first, WIN *thewin, GRECT *clip );
void	secteurproc( int first, WIN *thewin, GRECT *clip );
void	textproc( int first, WIN *thewin, GRECT *clip );
void	redraw_slide( windowptr thewin, GRECT *clip );
void	aff_text( windowptr thewin, GRECT *clip );

/* wind.c */
void	do_window( int message[] );
void	untopped( int message[] );
void	cycle_window( void );
void	H_slide_window( int message[] );
void	V_slide_window( int message[] );
void	slide_window( int message[] );
void	scroll_left( windowptr thewin, int delta );
void	scroll_right( windowptr thewin, int delta );
void	scroll_up( windowptr thewin, int delta );
void	scroll_down( windowptr thewin, int delta );
void	do_resize( int message[] );
void	do_fullsize( int handle );
windowptr	findwindowptr( int handle );
t_win_coord	*get_info( int no, windowptr thewin, GRECT *rect );
windowptr	new_window( int thekind, char *title, char *info , void (*redraw_proc)(int ,WIN *, GRECT *), int type, int no );
void	dispose_window( windowptr thewin );
void	make_frontwin( windowptr thewin );

