/* **[WindUpdate]*************** */
/* *                           * */
/* * Prototypes                * */
/* * 20/12/2012 MaJ 29/01/2015 * */
/* ***************************** */


int 	main						( void );


void 	init_prog					( void );
void	init_barre_menu				( void );


void 	get_tag_config				( const char *a, int16 *b, int16 *c);
void	save_config					( const int16 h);
void	set_config					( void );

void	gestion_va_start			( void );


void	fermeture_programme			( void );


void	gestion_barre_menu			( void );
void 	gestion_clavier				( int16 a, int16 b );
void 	gestion_timer				( void );


void 	init_rsc_windupdate			( void );
void	ouvre_fenetre_windupdate	( void );
void	redraw_fenetre_windupdate	( const GRECT *r1 );
void	refresh_fenetre_windupdate	( void );
void	gestion_fenetre_windupdate	( int16 a, int16 b, int16 c);

