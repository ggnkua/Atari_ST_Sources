/*
 * InputOuput_Fields_Public.h
 */

typedef
	enum
	{
		 BASIC,
		 BUFFERING,
		 FIELDEDIT
	}
	EDIT_MODE;


	EDIT_MODE	GetEditMode(				/* Out: Mode d'‚dition courant de la voie concern‚e */
					VOIE *pVoie_curr );	/* In:  Ptr sur voie courante */

	FLD_STATUS get_InFieldPars( 				/* Out: FLD_NOT_FOUND, FLD_DISABLED ou FLD_READY */
								VOIE 		*	pVoie_curr,		/* In:  Voie concern‚e */
								int			n_fnct,			/* In:  Fonction recherch‚e */
								IOFIELD **	ppInField );	/* Out: ptr sur params ou NULL si pas trouv‚ */

	void	Create_ArboPageInFieldList( VOIE *pVoie_curr );

	void	display_field(
							int			device,	
							IOFIELD	*	pInField,	/* In: ptr sur champ … afficher */
							int			n_ClipTop,	/* In: Limite sup‚rieure pour l'affichage */
							int			n_ClipBot );/* In: Limite inf‚ieure pour l'affichage */

	int	start_fieldedit( 								/* Out:	FALSE si OK */
				VOIE	 	*	pVoie_curr,				/* In:	Voie concern‚e */
				int			n_fnct,					/* In:	Fonction de champ recherch‚e si pas de ptr direct sur champ */
				IOFIELD	*	pIOField_CurrIn );	/* In:	Ptr sur champ voulu si connu, NULL sinon: ds ce cas on cherche avec le no de fnct */

	void	Move_FocusToFirstInField(
								VOIE 	*	pVoie_curr );	/* In: Voie concern‚e */
	void	Move_FocusToNextInField(
								VOIE 	*	pVoie_curr );	/* In: Voie concern‚e */
	void	Move_FocusToPrevInField(
								VOIE 	*	pVoie_curr );	/* In: Voie concern‚e */
	void	Move_FocusToInField(
				VOIE 		*	pVoie_curr,	/* In: Voie concern‚e */
				IOFIELD	*	pInField );	/* In: Champ de saisie d‚sir‚ */
	void	Move_FocusToInField_byFnct(
				VOIE 		*	pVoie_curr,		/* In: Voie concern‚e */
				int			n_Fnct,			/* In: Fonction du champ de saisie d‚sir‚ */
				int			n_FnctEcran );	/* In: Fonction ‚cran d‚sir‚e avant edition du champ */


	const char * aim_CurrField(				/* Out: Ptr sur texte Champ courante */
									VOIE *pVoie_curr );		/* In:  Ptr sur voie courante */
	const char * aim_InField(					/* Out: Ptr sur texte du Champ demand‚ */
									VOIE *	pVoie_curr,		/* In:  Ptr sur voie courante */
									int		n_Fnct );		/* In:  Fonction du champ qui nous int‚resse */


	BOOL	validate_InFields( 		/* Out: TRUE si les champ sont correctement remplis */
			VOIE * pVoie_curr );	/* In:  Voie concern‚e */

	void	IOFieldList_Destruct(
			IOFIELD	*	pIOField );	/* In: 1er elt de la Liste … effacer */

	void	OutField_Display(
			VOIE 		*	pVoie_curr,		/* In: Voie concern‚e */
			IOFIELD	*	pIOField,		/* In: Champ … afficher */
			int			n_XOffset,		/* In: Offsets … appliquer aux coordonn‚es des champs */			
			int			n_YOffset );

	void	OutField_Clear(
			VOIE 			*	pVoie_curr,			/* In: Voie concern‚e */
			OUTPUT_FPAR	*	pOutput_FPar,		/* In: Param Champ … effacer */
			int				X_Offset,			/* In: Offsets … appliquer aux coordonn‚es des champs */			
			int				Y_Offset );
	void InField_Clear(
			VOIE	 	*	pVoie_curr,				/* In:	Voie concern‚e */
			IOFIELD	*	pIOField_CurrIn );	/* In:	Ptr sur champ … effacer */

	long	IOField_MoveTopLine(				/* Out: Nbre de lignes dont on s'est effectivement d‚plac‚ */
			IOFIELD	*	pIOField,		/* In:  Champ ds lequel on se d‚place */
			long			l_LineOffset );/* In:  Nbre de lignes duquel on se d‚place */

	void	IOField_DisplayText(
			VOIE 			*	pVoie_curr,		/* In: Voie concern‚e */
			OUTPUT_FPAR	*	pOutputFPar,	/* In: ParamŠtres du champ de sortie concern‚ */
			int				n_XOffset,		/* In: Offsets … appliquer aux coordonn‚es des champs */			
			int				n_YOffset,
			char			*	pText,			/* In: Texte (compact) … afficher */
			size_t			size_Text );	/* In: Longueur de ce texte */

	IOFIELD *	IOField_PrepareText(
					OUTPUT_FPAR	*	pOutputFPar,	/* In: ParamŠtres du champ de sortie concern‚ */
					char			*	pText,			/* In: Texte (compact) … afficher */
					size_t			size_Text );	/* In: Longueur de ce texte */

	void	IOField_DisplayString(
			VOIE 			*	pVoie_curr,		/* In: Voie concern‚e */
			OUTPUT_FPAR	*	pOutputFPar,	/* In: ParamŠtres du champ de sortie concern‚ */
			int				n_XOffset,		/* In: Offsets … appliquer aux coordonn‚es des champs */			
			int				n_YOffset,
			const char	*	cpsz_String );	/* In: Chaine … afficher */

	OUTPUT_FPAR	*	Find_OutField( 			/* Out: Champ de sortie trouv‚ */
						VOIE	*	pVoie_curr,	/* In:  Voie concern‚e */
						int		n_fnct );	/* In:  No de fonction demand‚e */
