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
