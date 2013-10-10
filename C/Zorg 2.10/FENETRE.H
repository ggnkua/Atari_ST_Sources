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
