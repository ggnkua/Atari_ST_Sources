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
