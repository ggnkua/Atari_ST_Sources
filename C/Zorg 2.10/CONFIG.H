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
