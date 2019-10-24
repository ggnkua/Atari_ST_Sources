/*
 * MainMenu_Public.h
 */
 
	extern	OBJECT *	G_menu_adr;					/* Ptr sur le MENU ! */

	extern	void	init_MainMenu( void );

	extern	void selection_menu(
					int	menu_title,		/* In: Titre de menu s‚lectionn‚ */
					int	menu_entry );	/* In: Entr‚e de menu s‚lectionn‚e */

	extern	BOOL	handle_keypress(		/* Out: TRUE_1 si reconnu */
					int	n_kbd_state, 	/* In: Etat du clavier lors de l'appui de touche */
					int	n_ScanCode, 	/* In: Scancode de la touche press‚e */
					char	c_car	);			/* In: Code ascii de la touche */

	void sauver_ram(
			WIPARAMS	*	pWiParams );	/* In: fenˆtre dont il faut sauver le contenu */
