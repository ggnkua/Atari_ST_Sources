/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 24/05/2018 * */
/* ***************************** */

#include	"../fonction/coeur/type_gcc.h"


int 	main						( void );

void    affiche_error               ( int32 error_code );

void 	init_prog					( void );
void	init_barre_menu				( void );

void    get_tag_config              ( const char *pt_fichier_config );
void	set_config					( void );
void	save_config					( const int16 handle_fichier);

void	gestion_barre_menu			( void );
void 	gestion_clavier				( int16 a, int16 b );
void	gestion_va_start			( void );

void	fermeture_programme			( void );

void 	gestion_timer				( void );


void    ouvre_fenetre_nyancat( void );
void    redraw_fenetre_nyancat( const GRECT *rd, const int16 index_tab_win );
void    gestion_fenetre_nyancat( const int16 controlkey, const int16 touche, const int16 bouton );
void    fermer_fenetre_nyancat( void );

void    rescale_rsc_options( void );
void    gestion_fenetre_options( const int16 controlkey, const int16 touche, const int16 bouton );


int32   init_nyancat( void );

