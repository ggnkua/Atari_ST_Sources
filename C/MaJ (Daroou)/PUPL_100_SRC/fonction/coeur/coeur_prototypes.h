/*-------------------------------------------------------------------*/
/* Prototypes des Fonctions du Coeur des applications                */
/* MaJ : 29/11/2025                                                  */
/*-------------------------------------------------------------------*/

void    log_print( const int16 mode );


int16   Fcm_affiche_alerte( const int16 data_mode, const uint16 idx_alert, int16 *bouton );
int16   Fcm_analyse_raccourci_GEM( const int16 touche );

int32   Fcm_bload(const char *nom_fichier, const char * adresse, int32 saut, int32 nombre);

int16   Fcm_check_rsc_alerte( void );
int16   Fcm_charge_RSC( void );
int16   Fcm_charger_config( void );
/*int32   Fcm_conversion_ascii_to_long( const char *chaine ); ne plus utiliser, -> atol() */
int16   Fcm_cookies_exist( const uint32 id_cookie );

int16   Fcm_dir_exist( const char *repertoire);

int16   Fcm_eddi_version( void );

void    Fcm_fermer_fenetre( int16 win_index );
int16   Fcm_file_exist( const char *nom_fichier);
int32   Fcm_file_size(const char *nom_fichier);
int16   Fcm_form_alerte( const int16 arbre_idx, const int16 texte_idx );
int16   Fcm_fprint ( const int16 handle, const char *buffer );



/* -----  Fcm_gestion_aes  ----- */
void    Fcm_gestion_aes(void);
void    Fcm_gestion_app_arg( const int argc, char **argv );
void    Fcm_gestion_barre_menu( void );
uint16  Fcm_gestion_bit_objet( OBJECT *adr_formulaire,  const int16 handle_win, const uint16 objet, const uint16 id_bit );
void    Fcm_gestion_bottom(void);
void    Fcm_gestion_clavier( const int16 controlkey, const int16 touche);
void    Fcm_gestion_fenetre_info( const int16 controlkey, const int16 touche, const int16 bouton );
void    Fcm_gestion_fenetre_preference( const int16 controlkey, const int16 touche, const int16 bouton );
void    Fcm_gestion_fermeture_fenetre(void);
void    Fcm_gestion_fermeture_programme( void );
void    Fcm_gestion_iconify( void );
void    Fcm_gestion_message(void);
void    Fcm_gestion_moved(void);
int16   Fcm_gestion_objet_bouton( OBJECT *adr_formulaire, const int16 handle, const uint16 objet_bouton );
void    Fcm_gestion_ontop(void);
void    Fcm_gestion_perte_ldg(void);
int16   Fcm_gestion_pop_up( int16 index_formulaire, int16 index_popup, int16 dial_popup );
void    Fcm_gestion_preference_langue( void );
void    Fcm_gestion_redraw_fenetre( void );
void    Fcm_gestion_shaded(void);
void    Fcm_gestion_sized(void);
void    Fcm_gestion_sliders(void);
void    Fcm_gestion_souris( const int16 controlkey, int16 bouton );
void    Fcm_gestion_topped(void);
void    Fcm_gestion_uniconify(void);
void    Fcm_gestion_untopped(void);
void    Fcm_gestion_va_start(void);
void    Fcm_gestion_widgets( void );



void    Fcm_get_chemin_home( char *mon_chemin, const uint16 size_max );
int32   Fcm_get_cookies( const uint32 id_cookie, uint32 *valeur_cookie );
//uint32 *Fcm_get_cookies_table(void);
int16   Fcm_get_indexwindow( const int16 handle_win );
void    Fcm_get_machine_info(void);
int16   Fcm_get_objet_parent( OBJECT *adr_formulaire, int16 objet );
void    Fcm_get_screen_info(void);
int32   Fcm_get_shel_envrn( char *string, const char *name, const uint16 size_max );


void    Fcm_get_tag_config_generale( const char *pt_fichier_config );
//int16   Fcm_get_tag( const char *chaine, char *buffer, const uint16 taille_buffer, const char *buffer_config );
int16   Fcm_get_tag_booleen(const char *tag, const char *pt_fichier_config, int16 valeur_par_defaut);
int32   Fcm_get_tag_int32  (const char *tag, const char *pt_fichier_config );
void    Fcm_get_tag_string (const char *tag, const char *pt_fichier_config, char *string_dest, uint16 string_dest_size );


uint32  Fcm_get_timer(void);
uint16  Fcm_get_tos_version(void);
int16   Fcm_get_win_parametre( const char *pt_config );

void    Fcm_get_rsrc_gaddr_rtree( void );


int32   Fcm_init_coeur_application( void );
int16   Fcm_init_AES_VDI( void );
void    Fcm_init_environnement( void );
void    Fcm_init_prog( void );
void    Fcm_init_rsc_info( void );
void    Fcm_init_win_parametre( void );
int16   Fcm_is_my_win_ontop( void );

void    Fcm_libere_aes_vdi( void );
int32   Fcm_libere_ram( uint32 adresse );
void    Fcm_libere_RSC( void );


void    Fcm_menu_tnormal( int16 tree_index, int16 menu_index, int16 mode );
void    Fcm_mouse_no_bouton( void );
void    Fcm_my_menu_bar( const int16 tree_index, const int16 mode );

void    Fcm_objet_change( OBJECT *adr_formulaire, const int16 handle, const uint16 objet, const uint16 etat );
void    Fcm_objet_draw( OBJECT *adr_formulaire, int16 handle_win, uint16 objet, int16 windupdate_mode );
void	Fcm_ouvre_fenetre( uint16 index_tab_win, GRECT *win_xywh );
void    Fcm_ouvre_fenetre_start(void);

/*int16   Fcm_point_in_area ( const GRECT *r1, const GRECT *r2);*/
void    Fcm_purge_clavier(void);
void    Fcm_purge_aes_message(void);
//void    Fcm_purge_redraw(void);

void    Fcm_redraw_fenetre( const GRECT *rd , const int16 index_tab_win);
uint32  Fcm_reserve_ram( int32 nombre, uint16 mode );
void    Fcm_rescale_bar_menu(void);
void    Fcm_rescale_fenetre_info(void);
void    Fcm_rescale_fenetre_preference(void);

void    Fcm_sauver_config( const int16 force_save );
void    Fcm_save_config_generale(const int16 handle_fichier);
void    Fcm_set_config_generale( void );
void    Fcm_set_rsc_string( const int16 idx_dialogue, const int16 objet, const char *chaine );
void    Fcm_set_rsc_string_int32( const int16 idx_dialogue, const int16 objet, const int32 valeur );
void    Fcm_set_win_position( const uint16 index_win, int16 *winx, int16 *winy, int16 *winw, int16 *winh );

int16   Fcm_win_form_alert( const int16 defaut_bouton, const char *pop_up );

