/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 17/12/2015 * */
/* ***************************** */



#include	"fonction/coeur/type_gcc.h"



int 	main						( void );


void 	init_prog					( void );
void	init_barre_menu				( void );


void	get_tag_config				( const char *pt_fichier_config, int16 *erreur_config, int16 *tag_absent);
void	set_config					( void );
void	save_config					( const int16 handle_fichier);


void	fermeture_programme			( void );

void	gestion_barre_menu			( void );
void 	gestion_clavier				( int16 a, int16 b );
void 	gestion_timer				( void );
void	gestion_va_start			( void );



