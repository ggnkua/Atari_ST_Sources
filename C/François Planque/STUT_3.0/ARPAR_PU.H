/*
 * ArboParams_Public.h
 */


	ARBO_TEXTPAR *	Duplicate_TextParList( 
				const ARBO_TEXTPAR *	pTextPar_FirstSrce );	/* In: Ptr sur 1er elt liste source */

	void	Delete_TextParList( 
			ARBO_TEXTPAR *	arbo_textpar );

	ARBO_TEXTPAR	*	Get_ithTextParInList( 
							ARBO_TEXTPAR *	pTextPar, 
							int 				n_Index );

	void	InputField_Save( 
			INPUT_FPAR	*	pInputFPar, 	/* In: Champ Ö sauver */
			FILE 			*	fstream );		/* In: Fichier vers lequel sauver */
	void	InputField_Load( 
			INPUT_FPAR	*	pInputFPar, /* In: Champ ds lequel on charge */
			FILE 			*	fstream,		/* In: Fichier duquel on charge */
			int				n_Version );
	void	AListPars_Save(
			ARBO_LISTPARS	*	pAListPars, /* In: Paramätres Ö sauver */
			FILE 				*	fstream );	/* In: Fichier vers lequel sauver */
	ARBO_LISTPARS	*	AListPars_Load(		/* Out: paramätres chargÇs */
			FILE 				*	fstream );	/* In:  Fichier depuis lequel on charge */
	void	OutputField_Save( 
			OUTPUT_FPAR	*	pOutputFPar, 	/* In: Champ Ö sauver */
			FILE 			*	fstream );		/* In: Fichier vers lequel sauver */
	void	OutputField_Load( 
			OUTPUT_FPAR	*	pOutputFPar, /* In: Champ ds lequel on charge */
			FILE 			*	fstream,		/* In: Fichier duquel on charge */
			int				n_Version );

	BOOL	TextParList_Replace1Content(					/* Out: TRUE_1 si ok */
				ARBO_TEXTPAR *	pTextPar_List,			/* In: Liste des textpars Ö remplacer */
				int				n_Fnct,					/* In: Fonction du textpar Ö remplacer */
				const char	 * cpsz_NewContent );	/* In: Modäle du nouveau contenu */
