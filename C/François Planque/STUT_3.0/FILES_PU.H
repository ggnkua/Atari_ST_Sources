/*
 * Files_Public.h
 *
 * Internal/File document-type definitions: (chargement) 
 */

typedef
	enum
	{
		F_UNKNOWN,

		FS_ARBO,				/* Arborescence (Smart format *.STU) */
		FS_ARB,				/* Une seule page arbo (Smart Format *.ARB) */
	
		GF_PAGES_ECRAN,	/* Pages ‚cran: format g‚n‚rique: correspond … un ensemble de formats diff‚rents */
		FS_PAGES_ECRAN,	/* Dossier de pages ‚cran (Smart Format *.STU) */
		/* FS_PAGE_ECRAN,		/* Une seule page ‚cran (Smart Format *.ECR) */
		F_VDT,				/* Une seule page ‚cran (bloc *.VDT) */

		FS_DATAS,			/* Bases de donn‚es (Smart Format *.STU) */
		FS_DXF,				/* Data eXchange Format (Smart Format *.DXF) */

		GF_TEXTES,			/* Textes: format g‚n‚rique: correspond … un ensemble de formats diff‚rents */
		FS_TEXTES,			/* Textes (Smart Format *.STU) */
		F_TEXTE,				/* Texte (bloc m‚moire *.TXT) */
		F_TEXTE_ASCII,		/* Texte ascii (en m‚moire sous forme de lignes *.TXT) */

		FS_IMAGES,			/* Images (Smart Format *.STU) */
		F_IMAGE,				/* Image (Degas *.PI3) */

		FS_INF,				/* ParamŠtres serveur (Smart format *.INF) */
		FS_INI				/* Configuration logiciel (Smart format *.INI) */
	}
	FILEFORMAT;



	extern	char	G_stutpath[];	/* Path dans lequel se trouve Stut One */
	extern	char	G_filename[];	/* Nom du fichier … charger ex:TEST.TXT */
	extern	char	G_filepath[];	/* Chemin du fichier … charger ex:D\EXEMPLE */



	/* 
	 * Fichiers: 
	 */
	void	erase_extension(
				char	*	psz_Filename );		/* In: Nom de fichier dont on veut effacer l'extension */
	void	replace_extensionInBuf(
				char			*	pBsz_Filename,		/* In: Nom de fichier dont on veut changer l'extension */
				const char	*	cpsz_extension );	/* In: Extension a utiliser */

	BOOL	set_DtPgFilePathToFS(			/* Out: TRUE si success */
			DATAPAGE	*	pDataPage );		/* In: Page … sauver */ 
	BOOL	set_DtPgFilePath(			/* Out: TRUE si success */
			DATAPAGE	*	pDataPage );		/* In: Page … sauver */ 

	extern	void	init_fsel( void );	/* Init les directorys etc... */
	extern	int	directsave_file( int file_type, FTA *fta );
	extern	int	directload_file2( int file_type, FTA *fta, int obligatoire );
	extern	int	head_control( FILE *fstream, int ftype, char *content );
	extern	char	*get_config_line( FILE *fstream, int separat, char * *object, char * *data );

	extern	int	load_file( char *titre, int doc_type, FTA *fta );
	extern	int	save_file( 					/* Out: */
							char	*	titre,		/* In:  Tritre du s‚lecteur de fichiers */
							int 		file_type,	/* In:  Type de fichier … sauver */ 
							FTA	*	fta );		/* In:  File Transfer Area: fournit ptr sur donn‚es … sauver */

	extern	char * 	load_String(				/* Out: chaine de caractŠres charg‚e */
								FILE *	fstream );	/* In:  fichier depuis lequel on va charger */
	extern	void	save_String(
								char *	pString,		/* In: Pointeur sur la chaŒne … sauver */
								FILE *	fstream );	/* In: fichier dans lequel on va sauver */
	BOOL	recall_filepath( 					/* Out: TRUE if success */
			DATAGROUP *	datagroup );
	int	file_access_extract( 
			char *file_access );
	BOOL	Append_CompRecToDXFFile(			/* In: True si success */
			COMPACT_RECORD *	pCompactRec );	/* In: Ptr sur le Record … ajouter */

	void	path_add_backslash( char *path );

