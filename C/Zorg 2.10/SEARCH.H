/* search.c */
void	search_secteur(  windowptr thewin, boolean diff_majmin, boolean start_to_end );
void	search_found(  windowptr thewin, long secteur, long offset );
int		load_buffer( windowptr thewin, char *buffer, long secteur, int size, boolean start_to_end );
long	search_pattern( char *buffer, long size, char *pattern, boolean diff_majmin, boolean start_to_end );
void	search_first( windowptr thewin );
boolean	search_proc( t_dialog *dialog, int exit );
void	search_next( windowptr thewin );
void	search_tampon( windowptr thewin, boolean diff_majmin );
