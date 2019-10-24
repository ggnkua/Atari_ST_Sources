/*
 * Objects_public.h
 */
 
	extern	int find_ObjByXY(						/* Out: Index ic“ne */
							OBJECT 	* 	pObj_Tree,
							int			n_x,
							int			n_y );
	extern	int find_ObjBySpec(				/* Out: Index objet trouv‚ ou NIL_1 */
							OBJECT 	* 	pObj_Tree,
							void		*	ob_spec );



	extern	void	open_panel( OBJECT *dialog, const GRECT *little_box, GRECT *big_box, int center );
	extern	void	close_pannel( OBJECT *dialog, int exit_obj, const GRECT *big_box );
	extern	void	abort_pannel( OBJECT *dialog, int exit_obj, const GRECT *little_box, const GRECT *big_box );

	extern	void	fix_ftext( 
				OBJECT *tree, 
				int obj, 
				const char *ftext );

	extern	char	*extract_ftext( OBJECT *tree, int obj );

	extern	OBJECT*	formdup( 
				OBJECT *srce_tree );

	extern	void	rlink_teptext( 
				OBJECT *objc_adr, 
				const char *texte );
			
	extern	void dlink_teptext( 
		OBJECT *objc_adr, 
		const char *texte );

	extern	void	objc_sel( OBJECT *tree, int obj );
	extern	void	objc_dsel( OBJECT *tree, int obj );
	extern	void	objc_toggle( OBJECT *tree, int obj );
	extern	void	objc_clrsel(  OBJECT *tree, int obj );
	extern	void	objc_setsel(  OBJECT *tree, int obj );
	extern	void	objc_fixsel( 
			OBJECT*	pObj_tree, 	/* In: Arbre dans lequel on agit */
			int 		n_obj,		/* In: Objet sur lequel on agit */
			int		n_state );   /* In: 0=d‚selection, autre selectionne */

	extern	BOOL	objc_testsel( 				/* Out: !=0 si s‚lectionn‚ */
				OBJECT *	pObj_tree, 	/* In: Arbre dans lequel on teste */
				int 		n_obj );		/* In: Objet sur lequel on teste */
		
	extern	void	objc_enable( OBJECT *tree, int obj );
	extern	void	objc_disable( OBJECT *tree, int obj );
	extern	void	objc_setenable( OBJECT *tree, int obj );
	extern	void	objc_setdisable( OBJECT *tree, int obj );
	extern	void	objc_fixable( OBJECT *tree, int obj, int enable );

	extern void free_text( 
		OBJECT *objc_adr );
	extern	void	free_form( OBJECT *tree );

				

	extern	BOOL	objc_TestEnable( 			/* Out: !=0 si s‚lectionn‚ */
							OBJECT *	pObj_tree, 	/* In: Arbre dans lequel on teste */
							int 		n_obj );		/* In: Objet sur lequel on teste */

	extern	void init_objects( void );
	extern	void rsrc_color( OBJECT *tree );

	extern 	int	ctrl_icon( OBJECT *tree, int	object, int	check_x, int check_y );

	extern	void	sensitive_desk( 
					int new_x, 
					int new_y, 
					int start_obj, 
					int *actual_spot );

	extern	void	open_dialog( OBJECT *dialog, const GRECT *little_box, GRECT *big_box );
	extern	void	close_dialog(
							OBJECT *dialog, 
							int exit_obj, 
							const GRECT *little_box, 
							const GRECT *big_box );



	extern	char	*	dir_infoline_selection( 
								WIPARAMS *wi_params_adr );

	extern	int	objc_color( OBJECT *tree, int objc );

	extern	void	objc_setenable( OBJECT *tree, int obj );
	extern	void	maptree( OBJECT *tree, int this, int last, int (*routine)( OBJECT *tree, int tmp1 ) );

	extern	void	enable_menu( OBJECT *menu_adr, int enable );
	extern	int	enable_menuitem( OBJECT *tree, int objc );

	extern	void	objc_toggle( OBJECT *tree, int obj );
	extern	GRECT	* objc_xywh ( OBJECT *tree, int gc, GRECT *frame );

	extern	void	rearrange_dir( WIPARAMS *wi_params_adr, int new_w );
	extern	void	efface_dir( WIPARAMS *wi_params_adr );
	extern	char	*dir_infoline( WIPARAMS *wi_params_adr );

	extern	void	update_iconChar( 
							OBJECT *	pObject,		/* In: Ic“ne … modofier */
							SSTATE	sstate	);	/* In: Etat de l'objet auquel l'icone se rapporte */		
	extern	void	modif_icon( WIPARAMS * params_adr, int start_ob, int icon, int selected, int take_control );
	extern	void	redraw_icon( WIPARAMS * params_adr, int start_ob, int icon, int take_control );
	extern	int 	find_iconByNamePtr(				/* Out: Index ic“ne */
								OBJECT 	* 	pObj_Tree,
								char		*	psz_nom );

	extern	int	objc_parent( OBJECT *tree, int obj );
	extern	int	dup_tedinfo( OBJECT *tree, int tmp1 );
	extern	int	supress_tedinfo( OBJECT *tree, int objc );


	extern	void	remplace_dir( DATADIR * pDataDir );

	extern	void	deselect_current( void );

	extern	void	fix_fmtFtext( 					/* Out: */
							OBJECT *tree, 				/* In: Arbre contenant l'objet targett‚ */
							int obj, 					/* In: Index de l'objet target */
							const char	*ftext );	/* In: Ptr sur texte a ins‚rer ds objet */
	extern	char	*extract_fmtFtext( 			/* Out: nlle chaine contenant texte extrait */
							OBJECT *tree, 				
							int obj );





