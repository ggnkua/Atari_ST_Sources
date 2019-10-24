/*
 * WinDraw_Public.h
 */

#include "GEMWDEF.H"

	/*
	 * windraw:
	 */
	extern	int	start_WINDRAW( 					/* In: =TRUE si fenˆtre non overlapp‚e */
							WIPARAMS *	pWiParams );	/* In: fenˆtre que l'on s'apprˆte … redessiner (can be NULL) */
	extern	void	end_WINDRAW( void );
	extern	void	redraw( WIPARAMS *wi_params_adr, int area_x, int area_y, int area_w, int area_h, int take_control );

	extern	void	send_fullredraw( WIPARAMS *pWiParams );
	extern	void	redraw_textline( 
							WIPARAMS	*	pWiParams,	/* In: ParamŠtres de la fenˆtre */
							TEXTLINE	*	pTextLine,	/* In: Ptr sur ligne … redessiner */
							long			l_NoLine,	/* In: No de la ligne … redessiner */
							int			n_col,		/* In: Colonne … partir de laquelle on commence le redraw */
							int			n_length );	/* In: Longueur … afficher, NIL_1 si on veut la longueur du texte */
