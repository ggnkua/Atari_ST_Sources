/* curseur.c */
void	curseur_on( windowptr thewin );
void	edit( windowptr thewin, int key, int shift );
void	update_curseur( windowptr thewin, int xon, int yon, int xoff, int yoff, int affiche );
void	curseur_up( windowptr thewin, boolean full );
void	curseur_down( windowptr thewin, boolean full );
void	curseur_left( windowptr thewin, int ascii, boolean full );
void	curseur_right( windowptr thewin, int ascii, boolean full );
void	curseur_home( windowptr thewin, boolean full );
