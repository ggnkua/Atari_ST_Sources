/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 22/11/2023 * */
/* ***************************** */


#include	"../fonction/coeur/type_gcc.h"


void    affiche_error               ( int32 error_code );

int 	main						( void );


void 	init_prog					( void );
void	init_barre_menu				( void );


void    get_tag_config              ( const char *pt_fichier_config );
void	set_config					( void );
void	save_config					( const int16 handle_fichier);


void	fermeture_programme			( void );

void	gestion_barre_menu			( void );
void 	gestion_clavier				( int16 a, int16 b );
void 	gestion_timer				( void );
void	gestion_va_start			( void );



