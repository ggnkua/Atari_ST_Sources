/* menu.c */
boolean	MenuSelect( int object, int scan, int state, int button );
void	set_shortcuts( void );
void	shortcut_key( int key, int state, char *key_text, boolean fill );
void	aide( void );
void	presentation( void );
boolean	presentation_proc( t_dialog *dialog, int exit );
