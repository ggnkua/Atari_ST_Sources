/*
 * arbo_page_public.h
 *
 * Purpose:
 * --------
 * Interface publique pour ARBOPAGES
 *
 * History:
 * --------
 * 16.11.94: fplanque: Created
 */

#include "DEF_ARBO.H"
#include "GEMWDEF.H"

/*
 * ------------------------- MEMBRES PUBLICS ----------------------------
 */


/*
 * ----------------------- OPERATIONS PUBLIQUES -------------------------
 */

	/*
	 * Constructeur/Initialisation:
	 */
	extern	void	init_arbo( void );


	extern	void	ouverture_page_arbo( WIPARAMS	*selection_adr );
	extern	void	ouverture_menu_arbo( WIPARAMS	*selection_adr );



	extern	char	*arbo_infoline_selection( WIPARAMS *wi_params_adr );

	extern	DATAPAGE	*cree_pagearbo( DATADIR *curr_datadir, int fnct, char *form_name, int pos_x, int pos_y );

	ARBO_TEXTPAR *	cree_textpars2( 
						ARBO_TEXTPAR * TTextPar_Origin );	/* In: Tableau de valeurs par d‚faut */
	int	access_arbo( 
				DATAPAGE *datapage, 
				WORK_CONTENT *content_ptr );
	void	arboedit_optimal( int wi_ckind, int *border_x, int *border_y, int *border_w, int *border_h);

	void open_arbosomm( 
			WIPARAMS *pWiParams, 
			DATAPAGE *datapage );
	void free_arbosomm( OBJECT *form_adr );
			
