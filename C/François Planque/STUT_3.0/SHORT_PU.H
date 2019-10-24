/*
 * Shortcuts_Public.h
 */

	extern	void	Create_KeyMap(
							OBJECT	*	pObj_Menu );	/* In: Arbre Menu … analyser */


	extern	int	Lookup_Shortkey(			/* Out: no de l'entr‚e menu ‚quivalente; NIL si pas trouv‚ */
							int	n_kbd_state, 	/* In:  Etat du clavier lors de l'appui de touche */
							int	n_ScanCode, 	/* In:  Scancode de la touche press‚e */
							char	c_car,			/* In:  Code ascii de la touche */
							int *	pn_Title );		/* Out: Idx du titre de menu concern‚ */
