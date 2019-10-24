/*
 * Windows_Public.h
 */

#ifndef WIN_PU_H
#define WIN_PU_H

#include "GEMWDEF.H"	


/*
 * -------- public members -----
 */
	extern	WIPARAMS	*ouvre_fenetre( int class, int type,
										DATAGROUP *datagroup, DATADIR *datadir, DATAPAGE *datapage,
										const char *titre );
	BOOL ferme_fenetre( 				/* Out: TRUE_1 si la fenˆtre a ‚t‚ ferm‚e */
		WIPARAMS *	pWiParams,	/* In:  fenˆtre … fermer */
		BOOL			b_Query );	/* In:  TRUE_1 si on doit demander confirmation avant perte de donn‚es */
	extern	WIPARAMS	*take_off_wi_par( WIPARAMS * *list_adr, int wi_handle );
	extern	void	add_wipar_ontop( WIPARAMS * *list_adr, WIPARAMS *wi_params_adr );
	extern	void	cycle_window( void );
	extern	void	put_wi_on_top( WIPARAMS *wi_params_adr );
	extern	void	fixform_window( WIPARAMS *wi_params_adr );
	extern	void	set_infoline( WIPARAMS *wi_params_adr, char *(*infoline_text) (WIPARAMS *wi_params_adr) );

	extern	void	wi_resize( WIPARAMS * wi_params_adr );
	extern	void	fixform_window( WIPARAMS *wi_params_adr );


	extern	int	get_workYBas(						/* Out: Coord Y Basse */
							WIPARAMS	*	pWiParams );	/* In:  Fenˆtre concern‚e */
	extern	int	get_workXDroit(					/* Out: Coord X droite */
							WIPARAMS	*	pWiParams );	/* In:  Fenˆtre concern‚e */

	extern	WIPARAMS *find_datawindow2( unsigned long adr_contenu, WIPARAMS *start );
	extern	WIPARAMS *	findWin_byDataPage(					/* Out: Ptr sur fenˆtre trouv‚e ou NULL */
									DATAPAGE  *	pDataPage, 			/* In:  Ptr sur datapage dont on recherche la fenˆtre ouverte */
									WIPARAMS	 *	pWiParams_list );	/* In:  Ptr sur la liste des fenˆtres */

	extern	void	vscroll_window( WIPARAMS *wi_params_adr, unsigned long old_pos, unsigned long new_pos );
	extern	void	hscroll_window(
							WIPARAMS *wi_params_adr, 
							unsigned long old_pos, 
							unsigned long new_pos );

	extern	void	set_slider_x( WIPARAMS	*wi_params_adr );
	extern	void	set_slider_y( WIPARAMS	*wi_params_adr );
	extern	void	set_slider_h( WIPARAMS	*wi_params_adr );
	extern	void	set_slider_x( 
							WIPARAMS	*wi_params_adr );

	void	Wnd_SetModified(
			WIPARAMS	* pWiParams );	/* In: Fenˆtre concern‚e */
	void	Wnd_ClearModified(
			WIPARAMS	* pWiParams );	/* In: Fenˆtre concern‚e */
	void	Wnd_ChangeTitle(
			WIPARAMS	* 	pWiParams,			/* In: Fenˆtre concern‚e */
			char		*	pMsz_NewTitle );	/* In: Ptr sur nouveau titre */



#endif /* #ifndef WIN_PU_H */
