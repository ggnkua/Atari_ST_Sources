/*
 * PagesEcran_Public.h
 *
 * PUBlic INTernal prototypes:
 */

	extern	void	init_PagesEcran( void );
	extern	void	compile_page( GRECT *pGRect_start );
	void	watch_PageEcran(
				OBJECT	*	pObj_CallForm,	/* In: Formulaire appellant */
				int 			call_obj );		/* In: objet appellant */
	extern	void	visu_page(
					DATAPAGE	*	pDataPage,			/* In: Page ‚cran … afficher */ 
					OBJECT	*	pObj_CallForm );	/* In: Arbre appellant, peut ˆtre NULL */
