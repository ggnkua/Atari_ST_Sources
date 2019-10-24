/*
 * ArboTree_pu.h
 *
 * Purpose:
 * --------
 * Interface publique pour ARBOTREE
 *
 * History:
 * --------
 * 16.11.94: fplanque: Created
 */

#include "GEMWDEF.H"

/*
 * ------------------------- MEMBRES PUBLICS ----------------------------
 */

	/* 
	 * Dimensions des ic“nes: 
	 */
 	extern	int	G_arbocell_w;			/* Larg d'une ic“ne arbo */
	extern	int	G_arbocell_h;			/* Hauteur... */

/*
 * ----------------------- OPERATIONS PUBLIQUES -------------------------
 */

	/*
	 * Constructeur/Initialisation:
	 */
	extern	void	init_tree( void );

	extern	void	move_arbo( WIPARAMS *wi_params_adr, int clic_x, int clic_y );

 
	AFNCTSPEC	*afnct_spec( int fnct );

	void	arbo_optimal( OBJECT *tree, int *border_x, int *border_y, int *border_w, int *border_h);
	
	void open_arbotree( 
			WIPARAMS *wi_params_adr );
			
	void	efface_arbotree( WIPARAMS *wi_params_adr );
			


	extern	char	*arbo_infoline( WIPARAMS *wi_params_adr );
	extern	char	*arbo_infoline_selection( WIPARAMS *wi_params_adr );
	
	void	arbotree_optimal( 
				int wi_ckind, 
				DATADIR *datadir, 
				int *border_x, 
				int *border_y, 
				int *border_w, 
				int *border_h);

	void	free_specialpar( 
			int					n_fnct,				/* Type de page */
			ARBO_SPECIALPAR *	special_par );
