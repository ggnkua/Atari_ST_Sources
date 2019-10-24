/*
 * StuFiles.c
 *
 * Purpose:
 * --------
 * Op‚rations DIRECTEMENT en relation avec les fichiers:
 *	init des chemins du file selector
 *	controle d'extension .???
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"STUFILES.C v1.20 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>					/* header standard */
	#include	<stdlib.h>					/* header librairie de fnct std */
	#include <string.h>					/* header tt de chaines */
	#include	<ext.h>						/* header fonctions ‚tendues */
	#include	<tos.h>						/* Header fonctions TOS */
	#include	<aes.h>						/* header AES */
	#include <vdi.h>						/* header VDI */
   

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"					/* Listes */
	#include "S_MALLOC.H"
	#include	"DEBUG_PU.H"	
	#include	"DBSYS_PU.H"	
	#include	"ARBPG_PU.H"	
	#include	"ARPAR_PU.H"	
	#include	"ATREE_PU.H"	
	#include	"LISTS_PU.H"	
	#include	"FILES_PU.H"	
	#include	"RTERR_PU.H"	
	#include	"DTDIR_PU.H"	
	#include	"DATPG_PU.H"	
	#include	"TEXT_PU.H"	
	#include "ARBKEYPU.H"
	#include	"GEMDIRPU.H"

/*
 * Mode d'enregistrement:
 */
typedef
	enum
	{
		FEMODE_SINGLE,			/* Objet sauv‚ ds fichier … part */
		FEMODE_INTEGRATED		/* Objet int‚gr‚ ds fichier avec d'autres */
	}
	FEMODE;

typedef
	enum
	{
		SERIALIZE_INPUTFPAR,
		SERIALIZE_OUTPUTFPAR	
	}
	SERIALIZE_TYPE;

/*
 * ------------------------ PROTOTYPES -------------------------
 */


/*
 * EXTernal prototypes:
 */
	/* 
	 * Datas: 
	 */
	extern	void	init_serv( void );
	/*
	 * desktop
	 */
	extern	DATAGROUP	*	find_datagroup_byType( 		/* Out: Ptr sur datagroup */
									DATATYPE		DataType );		/* In:  Type DTYP_* */
	/* 
	 * Config: 
	 */
	extern	void	save_infdata( FILE *fstream );
	extern	void	save_inf( FILE *fstream );
	extern	void	load_inf( FILE *fstream );
	extern	void	save_inidata( FILE *fstream );
	extern	void	save_ini( FILE *fstream );
	extern	void	load_ini( FILE *fstream );
	/*
	 * S.G.B.D.
	 */
	extern	void	clear_AllLocks( 						
							COMPACT_RECORD *pCompRec ); 	/* In:  Ptr sur record … initialiser */


/*
 * PUBlic INTernal prototypes:
 */
	static	int	save_file( 					/* Out: */
							char	*	titre,		/* In:  Tritre du s‚lecteur de fichiers */
							int 		file_type,	/* In:  Type de fichier … sauver */ 
							FTA	*	fta );		/* In:  File Transfer Area: fournit ptr sur donn‚es … sauver */

	static	unsigned long	get_file_ext( const char *filename );
	static	int	ctrl_extension( const char *nom, int doc_type );
	static	int	directload_file2( int file_type, FTA *fta, int obligatoire );
	static	int	directsave_file( int file_type, FTA *fta );

	static	char	*ffind( FILE *fstream, char *string );
	static	void	load_str_tobuffer( FILE *fstream, int maxlen );

	static	int	merge_text( FILE *fstream, TEXTLINE * start_line, TEXTINFO * info_ptr );

	static	int	load_1text( FILE *fstream, DATADIR *datadir, char * filename );

	static	int	load_pi3( FILE *fstream, DATADIR *datadir, char * filename );
	static	int	write_PIx( 							/* In: !=0 si erreur */
							FILE 		*	fstream, 		/* In: Fichier dans lequel on veut sauver */
							DEGASPIX *	pDegasPix );	/* In: Ptr sur image en m‚moire */

	static	int	DataPge_LoadStdText( 
							DATAPAGE *	curr_page,
							FILE 		*	fstream ); 

	static	DATADIR *load_arbo( FILE *fstream );
	static	int	load_dirmap( FILE *fstream, unsigned * *dir_map );
	static	KEYWORD_LIST *	load_inlinks( 
						FILE 	*	fstream,
						int		n_Version );
	static	ARBO_TEXTPAR	*load_atextpar( FILE *fstream );
	static	ARBO_FIELDPARS *	load_fieldpar( 
			FILE 			*	fstream,
			SERIALIZE_TYPE	SerializeType,	/* In: Type de donn‚es … charger */
			int				n_Version );	/* In: version de fichier */
	static	BOOL	load_pagesarbo( 				/* Out: FALSE0 si chargement a ‚chou‚ */
					FILE 		*	fstream, 
					DATADIR 	*	pDataDi,		/* In: DataDir ds lequel on charge */
					int			n_Version);	/* In: Version du fichier */

	static	int	save_arbo( FILE *fstream, DATADIR *datadir );



/*
 * PRIVate INTernal prototypes:
 */

	static	int	save_datas( 
							FILE 			*	fstream, 
							const char	*	cpsz_FileName,	/* IN: Nom du fichier catalogue -> dossier de sauvegarde des fichiers ind‚pendants */
							DATADIR		*	datadir );
	static	int	load_datas(
							FILE			*	fstream, 
							const char	*	cpsz_FileName,	/* IN: Nom du fichier catalogue -> dossier de sauvegarde des fichiers ind‚pendants */
							DATADIR		*	datadir );
	static	BOOL	save_CompRecToDXF(					/* Out: TRUE si success */
							FILE				*	fstream, 	/* In:  Fichier ds lequel on doit sauver */
							COMPACT_RECORD	*	pCompRec );	/* In:  Record … sauver */
	static	int	save_DBtoDXF( 						/* Out: !=0 si erreur */
								FILE 		*	fstream, 
								char 		*	generic_name, 
								DATAPAGE *	datapage );
	static	DATA_RECORDS *	load_datafile(
										FILE *fstream );

	static	void	save_specialpar( 
							FILE 		*	fstream, 
							PAGEARBO	*	pArboPg );
	static	ARBO_SPECIALPAR load_specialpar(		/* Out: Params charg‚, NULL si pas de params */
						FILE *	fstream,		/* In:  Fichier depuis lequel on charge */
						int		n_fnct );	/* In:  Fonction de la page */

	static	void	save_atextpar( FILE *fstream, ARBO_TEXTPAR *atextpar );
	static	void	save_fields( 
			FILE 				*	fstream, 
			ARBO_FIELDPARS *	field_params, 
			SERIALIZE_TYPE		SerializeType );	/* In: Type de donn‚es … charger */


	static	int	load_PagesEcran( 				/* Out: YES1 ou NO0 */
							FILE 		*	fstream,		/* In: Fichier depuis lequel on charge */
							DATADIR	*	pDataDir );	/* In: Dossier dans lequel on doit charger */
	static	int	load_pages( FILE *fstream, DATADIR *datadir );
	static	int	load_1page( FILE *fstream, DATADIR *datadir, char* filename );
	static	int	save_PagesEcran( 				/* Out: YES1 si sauvegarde OK */
							FILE 		*	fstream, 	/* In:  Fichier ds lequel on doit sauver */
							DATADIR	*	pDataDir );	/* In:  Dossier de pages ‚cran … sauver */

	static	int	load_textes( 
							FILE *fstream, 		/* In: Fichier depuis lequel on charge */
							const char	*	cpsz_FileName,	/* IN: Nom du fichier catalogue -> dossier de sauvegarde des fichiers ind‚pendants */
							DATADIR *datadir );	/* In: dossier dans lequel on charge */
	static	int	save_textes(
							FILE *fstream, 
							const char	*	cpsz_FileName,	/* IN: Nom du fichier catalogue -> dossier de sauvegarde des fichiers ind‚pendants */
							DATADIR *datadir );
	static	void	save_text( 
							FILE 		*	fstream, 	/* In: Fichier ds lequel on veut sauver */
							TEXTINFO *	info_ptr );	/* In: Ptr sur le texte … sauver */

	static	DATABLOCK *	load_DataBlock( 			/* Out: Infos sur texte charg‚ */
									FILE	*	fstream,		/* In:  Fichier duquel on charge */
									FEMODE	FEMode);		/* In:  Mode d'enregistrement ds fichier */
	static	int	save_DataBlock( 
							FILE			*	fstream, 		/* In: Fichier ds lequel on veut sauver */
							DATABLOCK	*	pDataBlock,		/* In: Ptr sur le texte … sauver */
							FEMODE			FEMode);			/* In:  Mode d'enregistrement ds fichier */




/*
 * ------------------------ VARIABLES -------------------------
 */
    
/*
 * External variables: 
 */
	extern	char	*	G_crlf;						/* Retour … la ligne */
	extern	char	*	G_tmp_buffer;				/* Peut contenir un texte long de 255 signes + '\0' */
	extern	char	*	G_2nd_buffer;				/* DeuxiŠme buffer */
	/* 
	 * Vdi: 
	 */
	extern	int		G_def_text_width;			/* Largeur d'un texte par d‚faut */

/*
 * Public variables: 
 */
	char	G_stutpath[ MAXPATH ];	/* Path dans lequel se trouve Stut One */
	char	G_filename[ 13 ];			/* Nom du fichier … charger ex:TEST.TXT */
	char	G_filepath[ MAXPATH + 13 ];	/* Chemin du fichier … charger ex:D\EXEMPLE */

	
/*
 * Private variables: 
 */
	/* 
	 * Chemin s‚lect courant ex:D:\EXEMPLE\*.* 
	 */
	static	char	M_fs_iinsel[ 13 ];
	/* 
	 * Fichier s‚lectionn‚ ex:TEST.TXT 
	 */
	static	char	M_fs_iinpath[ MAXPATH + 13 ];	/*  +13 pour \12345678.ABC  */
	static	char	*M_path_end_adr;	/* Pointe sur le dernier Backslash du PATH dans G_filepath */
	/* 
	 * Header d'un fichier (partie commune … tous les fichiers: 
	 */
	static 	char	*M_header = "Applicat: Stut One\r\nCompatib: 0.00\r\nData... :\r\n";
	 
 
/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * init_fsel(-)
 *
 * Purpose:
 * --------
 * Init variables pour sélecteur de fichier
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	init_fsel( void )
{
	TRACE0( "Initializing " THIS_FILE );

	/*
	 * Sauvegarde du chemin d'accŠs au d‚marrage: 
	 */
	getcwd( G_stutpath, MAXPATH );

	/*
	 * Init du chemin d'accŠs courant: 
	 */
	getcwd( M_fs_iinpath, MAXPATH );		/* Path courant */
	path_add_backslash( M_fs_iinpath );	/* Rajoute backslash si n‚cessaire */
	strcat ( M_fs_iinpath, "*.*");		/* Rajoute "*.*" */

	/*
	 * Init du fichier courament s‚lectionn‚: 
	 */
	M_fs_iinsel[0]='\0';					/* Aucun fichier s‚lectionn‚ */

}


/*
 * get_fs_iinsel(-)
 */
char * get_fs_iinsel( void )
{
	return M_fs_iinsel;	
}

/*
 * get_fs_iinpath(-)
 */
char * get_fs_iinpath( void )
{
	return M_fs_iinpath;	
}


/*
 * erase_extension(-)
 *
 * Purpose:
 * --------
 * Efface l'extension d'un nom de fichier (ou path complet)
 *
 * History:
 * --------
 * 15.12.94: fplanque: Created
 */
void	erase_extension(
			char	*	psz_Filename )		/* In: Nom de fichier dont on veut effacer l'extension */
{
	char			*	piBsz_dot;

	piBsz_dot = strBchr( psz_Filename, '.' );
	if( piBsz_dot != NULL )
	{
		piBsz_dot[0] = '\0';
	}
}

/*
 * replace_extensionInBuf(-)
 *
 * Purpose:
 * --------
 * Remplace l'extension d'un nom de fichier (ou path complet)
 *
 * Note:
 * -----
 * Il doit y avoir suffisament de place ds le buffer pour contenir la nouvelle extension
 *
 * History:
 * --------
 * 17.12.94: fplanque: Created
 */
void	replace_extensionInBuf(
			char			*	pBsz_Filename,		/* In: Nom de fichier dont on veut changer l'extension */
			const char	*	cpsz_extension )	/* In: Extension a utiliser */
{
	char			*	piBsz_dot;

	piBsz_dot = strBchr( pBsz_Filename, '.' );
	if( piBsz_dot != NULL )
	{
		strcpy( piBsz_dot, cpsz_extension );	
	}
	else
	{
		strcat( pBsz_Filename, cpsz_extension );	
	}
}


 
 

/*
 * path_add_backslash(-)
 *
 * Purpose:
 * --------
 * Ajoute backslash final au path si n‚cessaire
 *
 * Algorythm:
 * ----------  
 * Si le nom ne se fini pas par un \ on le rajoute
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 28.03.95: optimized
 */
void	path_add_backslash( char *path )
{
	size_t len = strlen( path );

	if( path[ len -1 ] != '\\' )
	{	/*
		 * Si on est dans un dossier: 
		 */
		path[ len ] = '\\';
		path[ len+1 ] = '\0';
	}

}

            
            

/*
 * directload_file2(-)
 *
 * Purpose:
 * --------
 * Charge un fichier dont on connait d‚j… le chemin d'accŠs
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 19.06.94: charge groupes de textes
 * 19.06.94: expansion des groupes g‚n‚riques
 */
int	directload_file2( 
			int	file_type, 		/* In: type de fichier */
			FTA *	fta, 				/* In: */
			int 	obligatoire )	/* In: */
{
	/*
	 * Variables: 
	 */
	int		ouverture_ok = NO0;	/* =YES si on a pu ouvrir le contenu */
	int		new_defname	 = NO0;	/* =YES si le nom fichier actuel doit ˆtre utilis‚ pour sauvegarde & *.INF */
	unsigned long	ftype;			/* Extension du fichier choisi convertie en long */
	FILE		*fstream;

	/*
	 * Fixe le chemin courant: 
	 */
	Dsetdrv ( G_filepath[0] - 'A' );	/* Ch drive */
	chdir( G_filepath );					/* Ch dir */

	/*
	 * Ouvre fichier: 
	 */
	fstream = fopen( G_filename, "rb" );
	if ( fstream == NULL )   
	{	/*
		 * Si on a pas pu ouvrir 
		 */
		if ( errno != 2  ||  obligatoire == YES1 )
		{	/*
			 * Slt si ce n'est PAS un fichier non obligatoire
			 * qui n'a pas ‚t‚ trouv‚ 
			 */
			alert( errno );
		}
	}
	else							
	{
		ftype = get_file_ext( G_filename );		/* Extension */

		/*
		 * Expansion des types de fichiers g‚n‚riques:
		 */
		switch( file_type )
		{
			case	GF_PAGES_ECRAN:
				if( ftype == '.STU' )
					file_type = FS_PAGES_ECRAN;
				else
					file_type = F_VDT;
				break;							

			case	GF_TEXTES:
				if( ftype == '.STU' )
					file_type = FS_TEXTES;
				else
					file_type = F_TEXTE;
				break;							
		}

		/*
		 * Charge en fonction du type de fichier:
		 */
		switch( file_type )
		{
			case	FS_ARBO:
				/*
				 * Chargement d'un dossier arborescence: 
				 */
				*(fta -> datadir_ptr) = load_arbo( fstream );

				if ( *(fta -> datadir_ptr) != NULL )
				{	/* 
				 	 * Si on a charg‚ un DATADIR: 
				 	 */
					ouverture_ok 	= YES1;	/* Chargement OK */
					new_defname		= YES1;	/* Nouveau nom par d‚faut */
				}
				break;

			case	FS_PAGES_ECRAN:
				/*
				 * Chargement d'une s‚rie de pages: 
				 */
				ouverture_ok = load_PagesEcran( fstream, *(fta -> datadir_ptr) );
				new_defname  = YES1;		/* Nouveau nom par d‚faut */
				break;

			case	F_VDT:
				/*
				 * Ajout d'un fichier isol‚: 
				 */
				ouverture_ok = load_1page( fstream, *(fta -> datadir_ptr), M_fs_iinsel );
				break;

			case	FS_DATAS:
				ouverture_ok = load_datas( fstream, G_filename, *(fta -> datadir_ptr) );
				new_defname  = YES1;			/* Nouveau nom par d‚faut */
				break;

			case	FS_TEXTES:
				ouverture_ok = load_textes( fstream, G_filename, *(fta -> datadir_ptr) );
				new_defname  = YES1;			/* Nouveau nom par d‚faut */
				break;

			case	F_TEXTE:
				ouverture_ok = load_1text( fstream, *(fta -> datadir_ptr), M_fs_iinsel );
				break;
				
			case	F_TEXTE_ASCII:
				ouverture_ok = merge_text( fstream, (fta -> textinfo) -> lastline, fta -> textinfo );
				break;							
		
			case	F_IMAGE:
				ouverture_ok = load_pi3( fstream, *(fta -> datadir_ptr), M_fs_iinsel );
				break;
				
			case	FS_INF:
				if ( fta -> param == 1 )
				{	/*
					 * S'il faut initialiser avant de charger: 
					 */
					init_serv();
				}
				load_inf( fstream );		/* Charge params-serveur + serveur */
				break;

			case	FS_INI:
				load_ini( fstream );		/* Charge configuration */
				break;

			default:
				signale("Type de fichier inconnu");
		}
		/*
		 * Ferme le fichier: 
		 */
		fclose( fstream );
	}

	/*
	 * Teste s'il faut sauver le nom du fichier 
	 */
	if ( ouverture_ok )
	{
		if ( new_defname )
		{	/* S'il faut m‚moriser le nom & le chemin du fichier charg‚: */
			return	2;		/* Nom et Path … m‚moriser dispo ds G_filename et G_filepath */
		}
		
		return	1;
	}

	/*
	 * Si le chargement ne s'est pas effectu‚: 
	 */	
	return	FALSE0;
}



/*
 * get_file_ext(-)
 *
 * Purpose:
 * --------
 * Fournit l'extension du nom de fichier
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
unsigned long	get_file_ext( const char *filename )
{
	/* 
	 * Variables: 
	 */
	unsigned long	f_ext;		/* Extension du fichier choisi convertie en long */
	char				*extension;

	/*
	 * Recherche le point avant l'extension = d‚but de l'extension 
	 */
	extension = strchr( filename, '.' );	/* Pointeur sur le texte d'extension */

	/*
	 * Cr‚e un long int contenant l'extension (Top-moumoute!): 
	 */
	if ( extension != NULL )
	{
		f_ext = 	/* Extension ds un mot long */
			  ( ((unsigned long)extension[0]) <<24) 
			| ( ((unsigned long)extension[1]) <<16)
			| ( ((unsigned long)extension[2]) <<8)
			| ( (unsigned long)extension[3]);
	}
	else
	{
		f_ext = 0UL;		/* Pas d'extension */
	}

	return	f_ext;
}



/*
 * ctrl_extension(-)
 *
 * Purpose:
 * --------
 * Contr“le l'extension
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
int	ctrl_extension( const char *nom, int doc_type )
{
	static char		*err_text="[3][|  Vous devez choisir|  un fichier portant|  l'extension .ABC ! ][R‚essayer|Abandonner]";
	char				*extension;
	char				*valid;
	int				resultat=0;

	/*
	 * Recherche le point avant l'extension = d‚but de l'extension 
	 */
	extension = strchr( nom, '.' );	/* Pointeur sur le texte d'extension */

	switch( doc_type )
	{
		case F_IMAGE:
		{
			valid = ".PI3";		/* Extension demand‚e */
			
			if	( extension == NULL || strcmp( extension, valid ) != 0 )
			{	/*
				 * Si le nom ne comporte pas la bonne extension: 
				 */
				memcpy( err_text+61, valid, 4);
				resultat = form_alert( 1, err_text );
			}
			
			break;
		}

		case FS_ARBO:
		{
			valid = ".STU";		/* Extension demand‚e */
			
			if	( extension == NULL || strcmp( extension, valid) != 0 )
			{	/*
				 * Si le nom ne comporte pas la bonne extension: 
				 */
				memcpy( err_text+61, valid, 4);
				resultat = form_alert( 1, err_text );
			}
			
			break;
		}

	}

	return resultat;		/* 0 si ext correspond */

}
 
 
 
/*
 * recall_filepath(-)
 *
 * Purpose:
 * --------
 * Retourne dans le dernier chemin d'accŠs associ‚ au DATAGROUP
 * en vue de la prochaine sauvegarde
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 15.12.94: le NOM est TOUJOURS fix‚
 * 13.02.95: renvoie valeur de retour
 */
BOOL	recall_filepath( 					/* Out: TRUE if success */
			DATAGROUP *	datagroup )
{
	/*
	 *	Nom du fichier: 
	 */
	strcpy( M_fs_iinsel, datagroup -> filename );

	if( datagroup -> filepath != NULL )
	{	/*
		 * Si un chemin a ‚t‚ m‚moris‚: 
		 * Nouveau chemin d'accŠs courant: 
		 */
		strcpy( M_fs_iinpath, datagroup -> filepath );
		path_add_backslash( M_fs_iinpath );	/* Rajoute backslash si n‚cessaire */
		strcat ( M_fs_iinpath, "*.*");		/* Rajoute "*.*" */
	
		return	TRUE_1;
	}

	return FALSE0;
}


 
/*
 * set_DtPgFilePathToFS(-)
 *
 * Purpose:
 * --------
 * Retourne dans le chemin d'accŠs par d‚faut associ‚ … la DTAPAGE
 * en fonction de son emplacement ds dtagaroup et de l'emplacement
 * sur le disque de ce datagroup:
 * en vue de la prochaine sauvegarde
 *
 * Notes:
 * ------
 * Similaire … set_DtPgFilePath()
 *
 * History:
 * --------
 * 15.12.94: fplanque: Created based on recall_filepath()
 */
BOOL	set_DtPgFilePathToFS(			/* Out: TRUE si success */
			DATAPAGE	*	pDataPage )		/* In: Page … sauver */ 
{
	DATADIR		*	pDataDir	  = pDataPage -> pDataDir;		/* Directory dans lequel se trouve la page */
	DATAGROUP	*	pDataGroup = pDataDir -> pDataGroup;

	/*
	 *	Nom du fichier: 
	 */
	strcpy( M_fs_iinsel, pDataPage -> nom );

	if( pDataGroup -> filepath != NULL )
	{	/*
		 * Si un chemin a ‚t‚ m‚moris‚: 
		 * Chemin d'acces au group.STU:
		 */
		strcpy( M_fs_iinpath, pDataGroup -> filepath );
		path_add_backslash( M_fs_iinpath );	/* Rajoute backslash si n‚cessaire */

		/*
		 * On va se placer dans un sous dossier de nom du group:
		 */
		strcat( M_fs_iinpath, pDataGroup -> filename );
		erase_extension( M_fs_iinpath );

		strcat( M_fs_iinpath, "\\*.*");		/* Rajoute "*.*" */

		return	TRUE_1;
	}

	return	FALSE0;
}
            


 
/*
 * set_DtPgFilePath(-)
 *
 * Purpose:
 * --------
 * Retourne dans le chemin d'accŠs par d‚faut associ‚ … la DTAPAGE
 * en fonction de son emplacement ds dtagaroup et de l'emplacement
 * sur le disque de ce datagroup:
 * en vue de la prochaine sauvegarde
 *
 * Notes:
 * ------
 * Similaire … set_DtPgFilePathToFS()
 * 
 * History:
 * --------
 * 13.02.95: fplanque: Created based on set_DtPgFilePathToFS()
 */
BOOL	set_DtPgFilePath(			/* Out: TRUE si success */
			DATAPAGE	*	pDataPage )		/* In: Page … sauver */ 
{
	DATADIR		*	pDataDir	  = pDataPage -> pDataDir;		/* Directory dans lequel se trouve la page */
	DATAGROUP	*	pDataGroup = pDataDir -> pDataGroup;

	/*
	 *	Nom du fichier: 
	 */
	strcpy( G_filename, pDataPage -> nom );

	if( pDataGroup -> filepath != NULL )
	{	/*
		 * Si un chemin a ‚t‚ m‚moris‚: 
		 * Chemin d'acces au group.STU:
		 */
		strcpy( G_filepath, pDataGroup -> filepath );
		path_add_backslash( G_filepath );	/* Rajoute backslash si n‚cessaire */

		/*
		 * On va se placer dans un sous dossier de nom du group:
		 */
		strcat( G_filepath, pDataGroup -> filename );
		erase_extension( G_filepath );

		return	TRUE_1;
	}

	return	FALSE0;
}

            
/*
 * directsave_file(-)
 *
 * Purpose:
 * --------
 * Sauve un fichier dont on connait d‚j… le chemin d'accŠs
 *
 * Suggest:
 * --------
 * v‚rifier que certains fichiers ont bien une extension
 * ex DATAS.STU paske DATAS tout court, c le nom du dossier associ‚!
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 19.06.94: support des textes serveur
 * 29.06.94: support textes compact‚s, pages vdt, degas
 * 02.09.94: support des fichiers de pages vid‚otex
 */
int	directsave_file(
			int	file_type, 		/* In: Type de fichier … sauver */
			FTA *	fta )
{
	int		sauve_ok		 = NO0;	/* =YES si on a pu sauver le contenu */
	int		new_defname	 = NO0;	/* =YES si le nom fichier actuel doit ˆtre utilis‚ pour sauvegarde suivante & *.INF */
	FILE	*	fstream;

	/*
	 * On se place dans le dossier concern‚: 
	 */
	Dsetdrv ( G_filepath[0] - 'A' );	/* Ch drive */
	chdir( G_filepath );					/* Ch dir */
	
	/*
	 * Ouvre fichier 
	 */
	fstream = fopen( G_filename, "wb" );
	if ( fstream == NULL )   /* Si on a pas pu ouvrir */
	{
		if ( errno != 5 )
		{	/* 
			 * Si ce n'est pas une erreur de protection
			 * (qui b‚n‚ficie d'une alerte TOS automatique ) 
			 */
			alert( errno );
		}
	}
	else							
	{
		switch( file_type )
		{
			case	FS_ARBO:
				/*
				 * Dossier arbo:
				 */
				sauve_ok = save_arbo( fstream, fta -> datadir );
				new_defname = YES1;		/* Il faut m‚moriser le nom du fichier */
				break;

			case	FS_PAGES_ECRAN:
				/*
				 * Dossier de pages ‚cran:
				 */
				sauve_ok = save_PagesEcran( fstream, fta -> datadir );
				new_defname = YES1;		/* Il faut m‚moriser le nom du fichier */
				break;

			case	F_VDT:
				/*
				 * Page vid‚otex:
				 */
				if( save_DataBlock( fstream, fta -> pDataPage -> data.dataBlock, FEMODE_SINGLE ) == SUCCESS0 )
				{
					sauve_ok = YES1;
				}
				break;

			case	FS_DATAS:
				/*
				 * Dossier de bases de donn‚es:
				 */
				sauve_ok = save_datas( fstream, G_filename, fta -> datadir );
				new_defname = YES1;		/* Il faut m‚moriser le nom du fichier */
				break;

			case	FS_DXF:
				/*
				 * Base de donn‚es:
				 */
				if( save_DBtoDXF( fstream, G_filename , fta -> pDataPage ) == SUCCESS0 )
				{
					sauve_ok = YES1;
				}
				break;

			case	FS_TEXTES:
			 	/*
			 	 * Dossier de textes:
			 	 */
				sauve_ok = save_textes( fstream, G_filename, fta -> datadir );
				new_defname = YES1;		/* Il faut m‚moriser le nom du fichier */
				break;

			case	F_TEXTE_ASCII:
				/*
				 * texte sous forme formatt‚e en m‚moire:
				 */
				save_text( fstream, fta -> textinfo );
				break;

			case	F_TEXTE:
				/*
				 * texte sous forme compact‚e en m‚moire:
				 */
				if( save_DataBlock( fstream, fta -> pDataPage -> data.dataBlock, FEMODE_SINGLE ) == SUCCESS0 );
				{
					sauve_ok = YES1;
				}
				break;

			case	FS_IMAGES:
				/* sauve_ok = save_images( fstream, fta -> datadir ); */
				new_defname = YES1;		/* Il faut m‚moriser le nom du fichier */
				break;

			case	F_IMAGE:
				/*
				 * Sauve une image seule:
				 */
				if( write_PIx( fstream, fta -> pDataPage -> data.degaspix ) == SUCCESS0 );
				{
					sauve_ok = YES1;
				}
				break;
											
			case	FS_INF:
				save_inf( fstream );
				break;
											
			case	FS_INI:
				save_ini( fstream );
				break;

			default:
				signale( "Format de fichier inconnu" );
		}
		if( fclose( fstream ) != 0 )
			alert( errno );
	}

	/*
	 * Teste s'il faut sauver le nom du fichier 
	 */
	if ( sauve_ok )
	{
		if ( new_defname )
		{	/*
			 * S'il faut m‚moriser le nom & le chemin du fichier sauv‚: 
			 */
			return	2;		/* Nom et Path … m‚moriser dispo ds G_filename et G_filepath */
		}
		
		return	1;
	}

	/*
	 * Si la sauvegarde ne s'est pas effectu‚: 
	 */	
	return	0;
}



/*
 * file_access_extract(-)
 *
 * Purpose:
 * --------
 * Fixe le chemin d'accŠs … un fichier dont on connait le path complet
 *
 * Suggest:
 * --------
 * PROVISOIRE: d‚tection d'erreurs … rajouter
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
int	file_access_extract( 
			char *file_access )
{
	/*	printf("File acces: %s\n",file_access); */

	M_path_end_adr=(char *)strrchr( file_access, '\\');

	if ( M_path_end_adr != NULL )
	{	/* Si on a trouv‚ le \ en question: */
		/* S‚pare le path du nom: */
		*M_path_end_adr = '\0';
		/* Recopie path: */
		strcpy( G_filepath, file_access );
		/* Recopie nom de fichier: */
		strcpy( G_filename, &M_path_end_adr[1] );

		/*	printf("Path=%s File=%s\n",G_filepath, G_filename ); */

		return	OK1;
	}

	return WRONG0;

}




/*
 * head_control(-)
 *
 * Purpose:
 * --------
 * Contr“le du header d'un fichier
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 15.09.94: Propose des alternatives si fmt fichier vid‚otex .STU non reconnu
 * 23.11.94: controle no de version
 * 21.01.95: renvoie no de version du fichier
 */
int	head_control( 					/* Out: no de version, ou ERROR_1 si pb ou CHANGE_2 */
			FILE *			fstream, 
			int 				ftype, 
			char *			content )
{
	/*
	 * Variables: 
	 */
	char	*	line_end;
	int		n_Version = ERROR_1;
	size_t	size_LineEnd;

	/************************/
	/* Contr“le du contenu: */
	/************************/
	line_end = ffind( fstream, "Content : " );
	if ( line_end == NULL )
	{	
		if( ftype == FS_PAGES_ECRAN )
		{	/*
		 	 * Fichier de pages ‚cran n'‚tant pas en Smart Format
		 	 * On demande si on veut tenter autre chose...
		 	 */
			if( alert( QUERY_FILEFORMAT ) == 1 )
			{	/*
				 * On veut tenter autre chose:
				 */
				return	CHANGE_2;
			}
		}

		alert( BAD_FILEFMT );	/* Format de fichier non reconnu! */
		return	ERROR_1;	
	}

	/*
	 * Si on trouve le champ content dans le header: 
	 */
	if ( stricmp( content, line_end ) != 0 )
	{	/*
		 * Fichier ne contient pas ce qu"on cherche: 
		 */
		alert( BAD_CONTENT, ftype );
		return	ERROR_1;	
	}
	
	
	/*
	 * Si le contenu est correct: 
	 */

	/**********************************/
	/* Contr“le de l'appli cr‚atrice: */
	/**********************************/
	line_end = ffind( fstream, "Applicat: " );
	if ( line_end == NULL )
	{	/* Format de header inconnu: */
		alert( BAD_FILEFMT );	/* Format de fichier non reconnu! */
		return	ERROR_1;	
	}

	/*
	 * Si on trouve le champ Application dans le header: 
	 */
	if ( ftype != FS_DXF && stricmp( "Stut One", line_end ) != 0 )
	{	/* Fichier n'est pas au format STUT ONE: */
		alert( BAD_FILEOWN );
		return	ERROR_1;	
	}
	
	/*
	 * Si l'application cr‚atrice est correcte: 
	 */
	
	/**************************/
	/* Cherche No de version: */
	/**************************/
	if( ffind( fstream, "Compatib:" ) == NULL )
	{	/*
	 	 * Format de header inconnu: 
	 	 */
		alert( BAD_HEADFMT );	/* Format de header non reconnu! */
		return	ERROR_1;	
	}

	/*
	 * G‚nŠre no de version en BCD:
	 */
	size_LineEnd = strlen( line_end );
	if( size_LineEnd >=4 )
	{
		n_Version =	(line_end[ size_LineEnd-1 ]  & 0xCF)
						| 	((line_end[ size_LineEnd-2 ]  & 0xCF) << 8)
						| 	((line_end[ size_LineEnd-4 ]  & 0xCF) << 16);
	}


	/************************************/
	/* On se positionne sur le Donn‚es: */
	/************************************/
	if( ffind( fstream, "Data... :" ) == NULL )
	{	/* Format de header inconnu: */
		alert( BAD_HEADFMT );	/* Format de header non reconnu! */
		return	ERROR_1;	
	}

	/* Si on trouve le champ Data dans le header: */

	/* HEADER OK: */
	return	n_Version;
	
}


/*
 * ffind(-)
 *
 * Purpose:
 * --------
 * description
 *
 * Algorythm:
 * ----------  
 * Trouve une ligne de caractŠres dans un fichier texte
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
char	*ffind( FILE *fstream, char *string )
{
	size_t	maxlen = strlen( string );

	while( fscanf( fstream, "%256[^\r]\r\n", G_tmp_buffer ) == 1 )
	{	/* Tant qu'on a pu lire une chaine: */

		if( strnicmp( string, G_tmp_buffer, maxlen ) == 0 )
		{	/* Si le d‚but de ligne correspond: */
			/* Retoune la suite: */
			return	&G_tmp_buffer[ maxlen ];
		}
		
	}

	return	NULL;
}





/*
 * get_config_line(-)
 *
 * Purpose:
 * --------
 * Charge une ligne dans un fichier de config du type OBJECT=DATA
 *
 * History:
 * --------
 * fplanque: Created
 */
char	*get_config_line( 
			FILE *fstream, 
			int separat, 
			char * *object, 
			char * *data )
{
	char	*egal;		/* Pointeur sur signe = */
	char	car;

	/* Charge une ligne: */
		fscanf( fstream, "%32s %256[^\r]\r\n", G_2nd_buffer, G_tmp_buffer );
		/* printf("Ligne: >%s< >%s<\n", G_2nd_buffer, G_tmp_buffer); */

	/* Contr“le s'il s'agit d'un commentaire: */
		car = *G_2nd_buffer;
		if ( car == '!' || car == '[' )
		{	/* S'il s'agit d'un commentaire: */
			/*	printf("Commentaire: >%c< >%s< >%s<\n", car, G_2nd_buffer, G_tmp_buffer); */
			
			*object = NULL;	/* Ligne non valide */
			*data	  = NULL;
			return 	NULL;		/* Pas d'action */		
		}

	/* Cherche caractŠres s‚parateur (= ou :) */
		egal = strchr( G_tmp_buffer, separat );
		if ( egal == NULL )
		{	/* Signe non trouv‚: */

		/* Selon le type de s‚parateur: */
			if ( separat == ' ' )
			{	/* Si on cherchait un espace: */
			/* On fait comme s'il y en avait un … la fin de la ligne: */
				*object = G_tmp_buffer;		/* Pointeur sur l'objet */
				*data	  = NULL;				/* Pas de sp‚cifications */
			}
			else
			{
			/* printf("Error\n"); */
			signale("Ligne invalide");
			*object = NULL;	/* Ligne non valide */
			*data	  = NULL;
			}
		}
		else
		{	/* On a trouv‚ le s‚parateur */
			/* printf("\n"); */
			*egal = '\0';	/* On le remplace par un octet NUL pour scinder la chaine en 2 */
			*object = G_tmp_buffer;		/* Pointeur sur l'objet */
			*data	  = &egal[1];		/* Pointeur sur la chaine de donn‚es */
		}

	/* Retourne commande: */
		return	G_2nd_buffer;
}

                    
                    
/*
 * load_str_tobuffer(-)
 *
 * Purpose:
 * --------
 * Charge une chaine termin‚e par un code <32 
 * depuis un fichier vers G_tmp_buffer
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 14.02.95: verified mallocs
 */
void	load_str_tobuffer( 
			FILE *	fstream,		/* In: Fichier depuis lequel on charge */
			int 		maxlen )		/* In: Nbre de cractŠres maximum, \0 non compris */
{

	char *	ptr = G_tmp_buffer;	/* Pointeur sur le buffer */
	int		i	 = 0;					/* Nombre d'octets lus */
	int		car;						/* CaractŠre courant */

	while
	(
		car = getc( fstream ),		/* Charge un caractŠre */
		car >= ' '  &&  i < maxlen
	)
	{
		*(ptr++) = (char)car;	/* Sauve car */
		i ++;								/* 1 car charg‚ de plus */
	}

	*ptr = '\0';		/* Termine buffer avec un octet nul */

	/* TRACE1( "Buffer=%s<>", G_tmp_buffer );  */
}
 
 
/*
 * -------------------------- FILESELECT --------------------------------
 */
 
/*
 * load_file(-)
 *
 * Purpose:
 * --------
 * Effectue la s‚lection d'un fichier et demande son chargement
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 19.06.94: centralis‚ triatement des erreurs de s‚lection
 */
int	load_file( 
			char *titre, 		/* In: titre pour FILESELECT */
			int file_type, 	/* In: Type de fichier … charger */
			FTA *fta )			/*  */
{
	/*
	 *  Variables: 
	 */
	int		fs_iexbutton;			/* Bouton de sortie */
 	int		fsel_retry;				/* =YES si on veut retenter de donner un nom! */
	int		ouverture_ok = NO0;	/* =YES si on a pu ouvrir le contenu */

	/*
	 * Boucle d'essais de s‚lection d'un fichier valide: 
	 */
	do
	{
	 	fsel_retry=NO0;	/* on ne veut pas encore retenter de donner un nom! */

 		if (fsel_exinput( M_fs_iinpath, M_fs_iinsel, &fs_iexbutton, titre ) != 0)
	 	{	/*
	 		 * S'il n'y a pas eu d'erreur pdt la s‚lection 
	 		 */
			graf_mouse(BUSYBEE, 0);		/* Change curseur souris */
			
			if (fs_iexbutton == 1)		/* Si on a cliqu‚ sur OK */
			{
				if ( strlen( M_fs_iinsel ) == 0 )
				{	/* 
					 * On a pas donn‚ de nom de fichier: 
					 */
					fsel_retry = alert( PERR_NO_FILENAME );
				}
				else
				{	/* 
					 * On a donn‚ un nom de fichier: 
					 * Contr“le l'extension: 
					 */
					fsel_retry=ctrl_extension( M_fs_iinsel, file_type );
	
					if ( fsel_retry == 0 )   /* si extension OK */
					{
						strcpy ( G_filepath, M_fs_iinpath );
	
						/*
						 * Il faut enlever le masque de s‚lection: 
						 */
						M_path_end_adr=(char *)strrchr( G_filepath, '\\');
						if ( M_path_end_adr == NULL )
						{
							fsel_retry = alert( PERR_INCORRECT_PATH );
						}
						else
						{	/*
							 * Si le path SEMBLE correct 
							 *
							 * EnlŠve extension: 
							 */
							M_path_end_adr[0]='\0';		/* Path sans \ final */	

							/*
							 * Recopie le nom du fichier ds var globale: 
							 */
							strcpy( G_filename, M_fs_iinsel );

							/* 
							 * Chargement: 
							 */
							ouverture_ok = directload_file2( file_type, fta, YES1 );

						}
					}
				}
			}
		}
	} while (fsel_retry == 1 );

	return	ouverture_ok;
}


/*
 * save_file(-)
 *
 * Purpose:
 * --------
 * Effectue s‚lection de fichier puis
 * Sauve un document/une DATAPAGE/un DATAGROUP sur disque
 *
 * Algorythm:
 * ----------  
 * appelle directsave_file
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 19.06.94: centralis‚ triatement des erreurs de s‚lection
 */
int	save_file( 					/* Out: */
			char	*	titre,		/* In:  Tritre du s‚lecteur de fichiers */
			int 		file_type,	/* In:  Type de fichier … sauver */ 
			FTA	*	fta )			/* In:  File Transfer Area: fournit ptr sur donn‚es … sauver */
{
	/*
	 * Variables: 
	 */
	int		fs_iexbutton;		/* Bouton de sortie */
 	int		fsel_retry;			/* =YES si on veut retenter de donner un nom! */
	int		sauve_ok = NO0;	/* =YES si on a pu sauver le contenu */

	do
	{
	 	fsel_retry = NO0;	/* on ne veut pas encore retenter de donner un nom! */

		/*
		 * Demande un nom de fichier: 
		 */
 		if( fsel_exinput( M_fs_iinpath, M_fs_iinsel, &fs_iexbutton, titre ) != 0)
   	{	/*
   		 * S'il n'y a pas eu d'erreur pdt la s‚lection: 
   		 */
		
			graf_mouse(BUSYBEE, 0);		/* Change curseur souris */
			
			if (fs_iexbutton == 1)		/* Si on a cliqu‚ sur OK */
			{
				if ( strlen( M_fs_iinsel ) == 0 )
				{
					fsel_retry = alert( PERR_NO_FILENAME );
				}
				else
				{	/*
					 * Si on a donn‚ un nom de fichier: 
					 * Contr“le de l'extension:
					 */
		
					if ( fsel_retry == 0 )   /* si extension OK */
					{	/*
						 * Fixe chemin d'accŠs dans la var globale: 
						 */
		
						strcpy ( G_filepath, M_fs_iinpath );
		
						/*
						 * Il faut enlever le masque de s‚lection: 
						 */
						M_path_end_adr=(char *)strrchr( G_filepath, '\\');
						if ( M_path_end_adr == NULL )
						{
							fsel_retry = alert( PERR_INCORRECT_PATH );
						}
						else
						{	/*
							 * Si le path SEMBLE correct
							 * Si on a trouv‚ l'extension: 
							 * On l'enlŠve: 
							 */
							M_path_end_adr[0]='\0';		/* Path sans \ final */	

							/*
							 * Fixe nom du fichier dans variable globale: 
							 */
							strcpy( G_filename, M_fs_iinsel );

							/*
							 * Sauvegarde proprement dite: 
							 */
							sauve_ok = directsave_file( file_type, fta );	/* Sauvegarde */
						}
					}
				}
			}
		}
	} while (fsel_retry == 1 );

	return	sauve_ok;
}
            


/*
 * -------------------------- CONFIGS  .INF  ----------------------------
 */
 


/*
 * save_inf(-)
 *
 * Purpose:
 * --------
 * Sauvegarde des paramŠtres-serveur dans fichier .INF
 *
 * History:
 * --------
 * fplanque: Created
 */
void	save_inf( FILE *fstream )
{
	/*
	 * Sauve header: 
	 */
	fputs( "Filename: STUT_ONE.INF\r\nContent : ParamŠtres-Serveur\r\n", fstream );
	fputs( M_header, fstream );
		
	/*
	 * Sauve donn‚es: 
	 */
	save_infdata( fstream );
}
 
 

/*
 *	------------------------- CONFIGS  .INI  ----------------------------
 */
 
  
 
/*
 * save_ini(-)
 *
 * Purpose:
 * --------
 * Sauvegarde de la configuration dans fichier .INI
 *
 * History:
 * --------
 * fplanque: Created
 */
void	save_ini( FILE *fstream )
{

	/*
	 * Sauve header: 
	 */
	fputs( "Filename: STUT_ONE.INI\r\nContent : Configuration\r\n", fstream );
	fputs( M_header, fstream );
		
	/*
	 * Sauve donn‚es: 
	 */
	save_inidata( fstream );
}
 
 
 

/*
 *	------------------------- ARBO ----------------------------
 */
 
  

/*
 * load_dirmap(-)
 *
 * Purpose:
 * --------
 * Chargement du dir_map
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 14.02.95: verified mallocs
 */
int	load_dirmap( 
			FILE 		*		fstream, 
			unsigned * *	dir_map )
{
	unsigned		map_w, map_h;	/* Dimensions du MAP */
	size_t		map_elts;		/* Taille du MAP */
	unsigned	*	l_dir_map;		/* MAP */
	int			nb_objs;
	size_t		i;				/* Pointeur dans MAP */

	/*
	 * Par d‚faut:
	 */
	*dir_map = NULL;

	/*
	 * Teste pr‚sence du MAP: 
	 */
	if( ffind( fstream, "MAP:" ) == NULL )
	{	/*
		 * On a pas trouv‚ le map:
		 */
		return	NIL;		/* Chargement … ‚chou‚ */
	}
	
	/*
	 * CHARGEMENT DU MAP: 
	 * Charge dimensions: 
	 */
	fread( &map_w, sizeof( unsigned ), 1, fstream );	/* Largeur */
	fread( &map_h, sizeof( unsigned ), 1, fstream );	/* Hauteur */
	map_elts = map_w * map_h;		/* Calcule taille n‚cessaire */
	/* TRACE3(" Map: %u*%u=%lu", map_w, map_h, map_elts ); */

	/*
	 * Alloue le MAP: 
	 */
	l_dir_map = (unsigned *) MALLOC( (2+map_elts) * sizeof( unsigned ) ); 
	if( l_dir_map == NULL )
	{	/*
		 * Si pas assez de m‚moire: 
		 */
		alert( NOMEM_OPENFILE );	/* Pas assez de mem pour ouvrir */

		return	NIL;		/* Chargement … ‚chou‚ */
	}

	/*
	 * Allocation OK:
	 * Fixe dimensions: 
	 */
	/* TRACE1(" Dir Map: %lX", l_dir_map ); */
	l_dir_map[ 0 ] = map_w;		/* Largeur */
	l_dir_map[ 1 ] = map_h;		/* Hauteur */
	/*
	 * Chargement du map: 
	 */
	if( fread( &(l_dir_map[2]), sizeof( unsigned ), map_elts, fstream ) != map_elts )
	{	/*
		 * Si on a pas pu tout charger: 
		 */
		alert( BAD_FILEFMT );	/* Format de fichier non reconnu! */

		/*
		 * En cas d'echec de chagement:
		 * On libŠre le MAP: 
		 */
		FREE( l_dir_map );

		return	NIL;		/* Chargement … ‚chou‚ */
	}

	/*
	 * SI on a charg‚:
	 * Calcule le nombre d'objets dans le MAP: 
	 */

	nb_objs = 0;
	for( i=0 ; i<map_elts ; i++ )
	{	/*
		 * Parcourt les cases: 
		 */
		if( l_dir_map[ 2 + i ] != 0 )
		{	/*
			 * Si la case contient un objet: 
			 */
			nb_objs ++;		/* 1 objet de plus */
		}
	}
	
	/* TRACE1( " Nb objs in MAP=%d", nb_objs ); */

	/*
	 * OK, c'est charg‚: 
	 */
	*dir_map = l_dir_map;	/* Retourne Adresse du MAP */				
	return	nb_objs;			/* Nbre d'objets dans le map */
}



/*
 * load_inlinks(-)
 *
 * Purpose:
 * --------
 * Chargement des liens-IN
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 14.02.95: verified mallocs
 * 29.03.95m use of KEYWORD_LIST
 */
KEYWORD_LIST *	load_inlinks( 
						FILE 	*	fstream,
						int		n_Version )
{
	/* 
	 * Teste pr‚sence des liens IN: 
	 */
	if( ffind( fstream, "IN:" ) != NULL )
	{	/*
		 * Si on a trouv‚ l'IN: 
		 * CHARGEMENT IN: 
		 */
		KEYWORD_LIST *	liens_in = load_motsclefs( fstream, CMD_EVENT, n_Version );
		return			liens_in;
	}

	/*
	 * On a pas pu charger: 
	 */
	return	NULL;
}



/*
 * load_pagesarbo(-)
 *
 * Purpose:
 * --------
 * Chargement des pages arbo
 *
 * Suggest:
 * --------
 * Cette proc‚dure manque de tests pour d‚celler les erreurs
 * v‚rifier les mallocs
 *
 * History:
 * --------
 * fplanque: Created
 * 10.05.94: fplanque: ajout‚ paramŠtres sp‚ciaux
 * 16.12.94: charge direct ds datagroup; optimisations
 * 26.01.95: v0.03: params de liste d'affichage
 */
BOOL	load_pagesarbo( 				/* Out: FALSE0 si chargement a ‚chou‚ */
			FILE 		*	fstream, 
			DATADIR 	*	pDataDir,	/* In: DataDir ds lequel on charge */
			int			n_Version )	/* In: Version du fichier */
{
	/*
	 * Compteur du nombre de pages charg‚es: 
	 */
	int	nb_pages = 0;	/* Pas encore de page charg‚e */

	int	ctrl_car;		/* CaractŠre de contr“le */

	/*
	 * Teste pr‚sence des pages: 
	 */
	if( ffind( fstream, "PAGES:" ) == NULL )
	{	/*
	 	 * On a pas trouv‚ les pages: 
	 	 */
		alert( BAD_FILEFMT );	/* Format de fichier non reconnu! */
	}
	else
	{	/*
	 	 * Si on a trouv‚ les pages: 
		 * CHARGEMENT PAGES: 
		 */
		DATAPAGE	*	pDataPage;
		PAGEARBO	*	pagearbo;				/* Donn‚es de la page en cours */

		while(	ctrl_car = getc( fstream ),
				 	ctrl_car	== '>' )
		{	/*
			 * Tant qu'il reste une page … charger:
			 * Charge nom: 
			 */
			load_str_tobuffer( fstream, 12 );		/* 12 car max */

			/* 
			 * Cr‚e page: 
			 */
			pDataPage = create_std_datapage( DTYP_ARBO, G_tmp_buffer ); 

			/*
			 * Charge commentaire: 
			 */
			pDataPage -> comment = load_String( fstream );
			
			/*
			 * Chargement des donn‚es: 
			 * -----------------------
			 * Cr‚‚ la zone de stockage: 
			 */
			pagearbo = (PAGEARBO *) MALLOC( sizeof( PAGEARBO ) ); 
			/*
			 * Lie … la page: 
			 */
			pDataPage -> data.pagearbo = pagearbo; 

			/* TRACE2(" Page ARBO: DtPg:%lX   PgArb:%lX", pDataPage, pDataPage -> data.pagearbo ); */

			/*
			 * Donn‚e non sauvegard‚e: Chemin d'accŠs complet 
			 */
			pagearbo -> chemin = page_fullpath_old( find_datagroup_byType( DTYP_ARBO ), pDataPage -> nom ); 

			/*
			 * Charge no de fonction: 
			 */
			fread( &( pagearbo -> fnct_no ), sizeof( pagearbo -> fnct_no ), 1, fstream );
			/*
			 * Donn‚e non sauvegard‚e: sp‚cifs fonction 
			 */
			pagearbo	-> fnct_spec = afnct_spec( pagearbo -> fnct_no );	/* Sp‚cifs associ‚es */
			/*
			 * Charge position dans le MAP: 
			 */
			fread( &( pagearbo -> map_pos_x ), sizeof( pagearbo -> map_pos_x ), 1, fstream );
			fread( &( pagearbo -> map_pos_y ), sizeof( pagearbo -> map_pos_y ), 1, fstream );
	
			/*
			 * Pages-‚cran: 
			 */
			pagearbo -> pages_ecran = load_atextpar( fstream );

			/*
			 * Champs de sortie/output: 
			 */
			pagearbo -> output_fields = load_fieldpar( fstream, SERIALIZE_OUTPUTFPAR, n_Version );
			/*
			 * ParamŠtres de liste:
			 */
			if( n_Version >= 0003 )
			{
				pagearbo -> pArboListPars = AListPars_Load( fstream );
			}
			else
			{
				pagearbo -> pArboListPars = NULL;
			}

			/*
			 * Champs de saisie/input: 
			 */
			pagearbo -> input_fields = load_fieldpar( fstream, SERIALIZE_INPUTFPAR, n_Version );

			/*
			 * Bases de donn‚es associ‚es: 
			 */
			pagearbo -> databases = load_atextpar( fstream );

			/*
			 * -----------
			 * Liens-arbo: 
			 * -----------
			 */
			pagearbo -> p_Events = load_motsclefs( fstream, CMD_EVENT, n_Version );
	
			/*
			 * ---------------------------------------
			 * ParamŠtres sp‚cifiques au type de page: 
			 * ---------------------------------------
			 */
			pagearbo -> special_par = load_specialpar( fstream, pagearbo -> fnct_no );

			/*
			 * -----------
			 * Mots clefs: 
			 * -----------
			 */
			pagearbo -> p_MotsClefs = load_motsclefs( fstream, CMD_KEYWORD, n_Version );
		
			/*
			 * Init statut sauvegarde: sauv‚e
			 * Pas de redraw, car page pas encore ajout‚e ds DATAGROUP
			 */
			dataPage_setSavState( pDataPage, SSTATE_SAVED ); 


			/*
			 * Ajoute page ds DataDir: 
			 */
			attach_new_data( pDataDir, pDataPage ); 
			 
			/*
			 * On a charg‚ une page de plus: 
			 */
			nb_pages ++;

		}

		/* TRACE1(" Charg‚: %d pages", nb_pages ); */

		/*
		 * Contr“le si le chargement s'est bien effectu‚ jusqu'au bout: 
		 */
		if ( ctrl_car == 0xFF )
		{	/*
			 * Chargement OK: 
			 */
			return	TRUE_1;
		}

		/*
		 * Sinon, le chargement a foir‚: 
		 */
		alert( UNEXPECTED_FFMT );		/* Fichier endommag‚ */
		
		/*
		 * Effacement des pages charg‚es: 
		 */
		clearout_datadir( pDataDir );
	
	}

	/*
	 * On a pas pu charger:  
	 */
	return	FALSE0;	
}




/*
 * load_atextpar(-)
 *
 * Purpose:
 * --------
 * Charge paramŠtres textuels
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 14.02.95: verified mallocs
 */
ARBO_TEXTPAR *	load_atextpar( 
						FILE *	fstream )
{
	size_t				load_res;			/* R‚sultat de l'op‚ration de chargement */
	unsigned				fnct_no = 0;		/* Num‚ro de fonction */
	ARBO_TEXTPAR	*	first;				/* 1er paramŠtre */
	ARBO_TEXTPAR	**	pred = &first;		/* Adr Ptr sur prochain ds le pr‚c‚dent */
	ARBO_TEXTPAR	*	pATextPar_Curr;	/* Param courant */

	/*
	 * Charge paramŠtres: 
	 */
	while
	( 
		load_res = fread( &fnct_no, sizeof( unsigned ), 1, fstream ),
		load_res == 1 /*PasFinFichier*/  &&  fnct_no != 0xFFFF /*PasFinListe*/
	)
	{	/*
		 * Tant qu'il y a des paramŠtres … charger: 
		 * Cr‚e le paramŠtre: 
		 */
		pATextPar_Curr = (ARBO_TEXTPAR *) MALLOC( sizeof(ARBO_TEXTPAR) );
		
		/*
		 * Liaison avec le pr‚c‚dent: 
		 */
		*pred = pATextPar_Curr;	/* Indique adresse du param courant */

		/*
		 * Fixe no de fonction: 
		 */
		pATextPar_Curr -> fnct_no = fnct_no;
	
		/*
		 * Charge paramŠtre textuel: 
		 */
		pATextPar_Curr -> nom = load_String( fstream );
		
		/*
		 * Sauve adresse du ptr dans lequel 
		 * il va falloir placer l'adr du param suivant: 
		 */
		pred = &( pATextPar_Curr -> next );			
	}

	/*
	 * Signale fin de la liste: 
	 */
	*pred = NULL;		/* Plus de param aprŠs */

	/*
	 * Contr“le si le chargement est ok: 
	 */
	if( fnct_no != 0xFFFF )
	{	/*
	 	 * S'il y a eu un problŠme: 
		 * Efface le d‚but de liste: 
		 */
		Delete_TextParList( first );
		first = NULL;	/* Plus de liste */
	}

	/*
	 * Renvoie l'adresse du 1er param: 
	 */
	return	first;
}





/*
 * load_specialpar(-)
 *
 * Purpose:
 * --------
 * Charge paramŠtres sp‚cifiques au type de page:
 *
 * History:
 * --------
 * fplanque: Created
 * 27.03.95: param fnct; impl‚mentation FILSEL
 */
ARBO_SPECIALPAR load_specialpar(		/* Out: Params charg‚, NULL si pas de params */
						FILE *	fstream,	/* In:  Fichier depuis lequel on charge */
						int		n_fnct )	/* In:  Fonction de la page */
{
	size_t				st_result;
	size_t				st_ParLength;
	ARBO_SPECIALPAR 	SpecPars;
	
	SpecPars.data = NULL;
	
	/* 
	 * Charge Longueur des parametres: 
	 */
	st_result = fread( &st_ParLength, sizeof( size_t ), 1, fstream );
	
	if( st_result > 0  && st_ParLength > 0 )
	{	/*
	    * S'il y a des paramŠtres … charger
		 */
		switch( n_fnct )
		{
			case	FA_LECT_MSG:
				SpecPars.lecture = MALLOC( sizeof( LECTURE_PAR ) );
				fread( SpecPars.lecture, 1, st_ParLength, fstream );
				break;
	
			case	FA_FILESEL:
				SpecPars.filesel = MALLOC( sizeof( FILESEL_PAR ) );
				fread( SpecPars.filesel, 1, st_ParLength, fstream );
				SpecPars.filesel -> pMsz_RootPath = load_String( fstream );
				break;
		}
	}
	
	return	SpecPars;
}




/*
 * load_arbo(-)
 *
 * Purpose:
 * --------
 * Chargement d'un fichier arborescence
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 15.07.94: fplanque: appelle maintenant create_EmptyDataDir()
 * 22.01.95: gŠre no de version
 * 14.02.95: verified mallocs
 */
DATADIR	*	load_arbo( 
					FILE *	fstream )
{
	int			n_Version;
	unsigned *	dir_map;
	int			nb_objs;

	/* 
	 * Contr“le le header:
	 */
	n_Version = head_control( fstream, FS_ARBO, "Arbo" );
	/* TRACE1(" Version arbo: %X", n_Version ); */
	
	/*
	 * Contr“le le no de version:
	 */
	switch( n_Version )
	{
		case	0x0002:
		case	0x0003:
		case	0x0004:
		case	0x0005:	/* 31.03.95 */
			break;
			
		case	ERROR_1:
			return	NULL;		/* Le chargement ne s'est pas effectu‚ */

		default:
			alert( BAD_VERSION );
			return	NULL;		/* Le chargement ne s'est pas effectu‚ */
	}
	
	/* 
	 * Si le header est correct:
	 * Charge dir-map: 
	 */
	nb_objs = load_dirmap( fstream, &dir_map );

	if( nb_objs >= 0 && dir_map != NULL )
	{	/*
		 * Si chargement dir-map ok: 
		 * Chargement des liens-IN: 
		 */
		KEYWORD_LIST *	liens_in = load_inlinks( fstream, n_Version );
		
		if( liens_in != NULL )
		{	/* 
			 * Si chargement liens-in ok: 
			 * ---------------------
			 * Chargement des pages: 
			 * ---------------------
			 */
			DATADIR 	*	pDataDir = create_EmptyDataDir( find_datagroup_byType( DTYP_ARBO ), NULL );

			if( load_pagesarbo( fstream, pDataDir, n_Version ) )
			{	/* 
				 * Si chargement des pages ok: 
				 * Cr‚ation du ROOT-DIR: 
				 */
				DIRSPEC * dir_spec;

				/*
				 * Cr‚ation des dir_spec: 
				 */
				dir_spec = (DIRSPEC *) MALLOC( sizeof( DIRSPEC ) );
				dir_spec -> liens_in  = liens_in;	/* Liens IN */
				dir_spec -> max_objs	 = 0;				/* Trait‚ plus tard... */
				dir_spec -> nb_objs	 = nb_objs;		/* Nombre d'objets ds MAP */
				dir_spec -> max_iblks = 0;				/* Trait‚ plus tard... */
				dir_spec -> nb_iblks	 = pDataDir -> nb_elts;	/* Nbre d'objets n‚cessitant un ICONBLK */
																/* nb_iblks = nbre depages arbo = nbre d'ic“nes (pas des IMAGEs) */
				dir_spec -> dir_map = dir_map;		/* MAP */

				/* TRACE2(" pages: nb_objs=%d  nb_iblks=%d ", dir_spec -> nb_objs, dir_spec -> nb_iblks ); */

				/*
				 * Relie Dir_spec au DATADIR
				 */						
				pDataDir -> dir_spec = dir_spec;	/* Sp‚cifications sp‚ciales!!! */

				/*
				 * Chargement termin‚ ok 
				 */
				return	pDataDir;		/* Chargement effectu‚ */		

			}
			
			/*
			 * En cas d'‚ch‚c:
			 * -Kill DataDir
			 * -Liberation des liens_in 
			 */
			DataDir_Destruct( pDataDir ); 
			free_KeyWordList( liens_in );

		}
		
		/*
		 * En cas d'‚chec, efface le dir_map: 
		 */
		FREE( dir_map );
	}

	/* 
	 * Si le chargement … ‚chou‚: 
	 */
	return	NULL;		/* Le chargement ne s'est pas effectu‚ */
}



/*
 * save_arbo(-)
 *
 * Purpose:
 * --------
 * Sauvegarde d'un dossier arbo
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 10.05.94: fplanque: ajout‚ paramŠtres sp‚ciaux
 * 24.11.94: version 0.01
 * 26.01.95: v0.03: sauve params liste
 * 15.03.95: v0.04: mots clefs ‚tendus aux commandes
 * 31.03.95: v0.05: liens-arbo>>>events traites comme mots clef
 */
int	save_arbo( 
			FILE 		*	fstream, 
			DATADIR	*	datadir )
{
	DIRSPEC	*	dir_spec = datadir -> dir_spec;	/* Sp‚cifications compl‚mentaires */
	unsigned	*	dir_map = dir_spec -> dir_map;	/* Map */
	unsigned		map_w = dir_map[ 0 ];
	unsigned		map_h = dir_map[ 1 ];
	DATAPAGE	*	datapage = datadir -> data_start;	/* 1Šre page */
	PAGEARBO	*	pagearbo;		/* Donn‚es arbo */
	int			n_NoFnct;		/* No de fonction d'une page */

	/*
	 * Sauve header: 
	 */
	fputs( "Filename: ARBO.STU\r\nContent : Arbo\r\n", fstream );
	fputs( "Applicat: Stut One\r\nCompatib: 0.05\r\nData... :\r\n", fstream );

	/*
	 * Sauve MAP: 
	 */
	fputs( "MAP:\r\n", fstream );
	fwrite( dir_map, sizeof( unsigned ), 2 + map_w * map_h, fstream );

	/*
	 * Sauve paramŠtres IN: 
	 */
	fputs( "\r\nIN:\r\n", fstream );
	save_motsclef( fstream, dir_spec -> liens_in );		/* Sauve liens arbo */

	/* 
	 * Sauve pages: 
	 */
	fputs( "\r\nPAGES:\r\n", fstream );
	while( datapage != NULL )
	{
		/* 
		 * Sauve octet de contr“le indiquant le d‚but d'une page: 
		 */
		putc( '>', fstream );

		/* 
		 * Sauve nom de la page: 
		 */
		save_String( datapage -> nom, fstream );	/* Nom */
	
		/* 
		 * Sauve commentaire: 
		 */
		save_String( datapage -> comment, fstream );	/* Commentaire */

		/* 
		 * Donn‚es: 
		 */
		pagearbo = datapage -> data.pagearbo;	/* Ptr sur donn‚es arbo */
	
		/* 
		 * No de fonction: 
		 */
		n_NoFnct = pagearbo -> fnct_no;
		fwrite( &n_NoFnct, sizeof( int ), 1, fstream );
		fwrite( &(pagearbo -> map_pos_x), sizeof( int ), 1, fstream );
		fwrite( &(pagearbo -> map_pos_y), sizeof( int ), 1, fstream );
	
		/*
		 * Pages ‚cran: 
		 */
		save_atextpar( fstream, pagearbo -> pages_ecran );

		/*
		 * Champs de sortie: 
		 */
		save_fields( fstream, pagearbo -> output_fields, SERIALIZE_OUTPUTFPAR );
		/* 
		 * ParamŠtres de liste:
		 */
		AListPars_Save( pagearbo -> pArboListPars, fstream );

		/*
		 * Champs de saisie: 
		 */
		save_fields( fstream, pagearbo -> input_fields, SERIALIZE_INPUTFPAR );

		/*
		 * Bases de donn‚es utilis‚es: 
		 */
		save_atextpar( fstream, pagearbo -> databases );

		/*
		 * Liens arbo: 
		 */
		save_motsclef( fstream, pagearbo -> p_Events );

		/*
		 * ParamŠtres sp‚ciaux de la page: 
		 */
		save_specialpar( fstream, pagearbo );

		/*
		 * Mots clef: 
		 */
		save_motsclef( fstream, pagearbo -> p_MotsClefs );
		
		/*
		 * Passe … la page suivante: 
		 */
		datapage = datapage -> next;	
	}

	/*
	 * Sauve octet de contr“le indiquant qu'il n'y a plus de page: 
	 */
	putc( 0xFF, fstream );

	return	YES1;		/* La sauvegarde s'est bien effectu‚e */
}




/*
 * save_atextpar(-)
 *
 * Purpose:
 * --------
 * Sauve paramŠtres textuels
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	save_atextpar( 
			FILE *fstream, 
			ARBO_TEXTPAR *atextpar )
{
	/*
	 * Sauve paramŠtres: 
	 */
	while( atextpar != NULL )
	{	/* Tant qu'il y a des paramŠtres … sauver */
		/* Sauve no de fonction: */
		fwrite( &(atextpar -> fnct_no), sizeof(int), 1, fstream );
		/* Sauve texte: */
		save_String( atextpar -> nom, fstream );
		/* Passe au paramŠtre suivant: */
		atextpar = atextpar -> next;
	}

	/*
	 * Fin de la liste: 
	 */
	fputc( 0xFF, fstream );		/* Ajoute 0xFFFF pour signaler */
	fputc( 0xFF, fstream );		/* La fin de la liste */
}



/*
 * save_fields(-)
 *
 * Purpose:
 * --------
 * Sauve paramŠtres des champs de sortie
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 17.12.94: new arg SerializeType
 */
void	save_fields( 
			FILE 				*	fstream, 
			ARBO_FIELDPARS *	field_params, 
			SERIALIZE_TYPE		SerializeType )	/* In: Type de donn‚es … charger */
{
	/*
	 * Sauve paramŠtres: 
	 */
	while( field_params != NULL )
	{	/*
		 * Tant qu'il y a des paramŠtres … sauver 
		 */
		switch( SerializeType )
		{
			case	SERIALIZE_INPUTFPAR:
				InputField_Save( &(field_params -> data.input), fstream );
				break;
				
			case	SERIALIZE_OUTPUTFPAR:
				OutputField_Save( &(field_params -> data.output), fstream );
				break;
				
			default:
				ping();
		}

		/*
		 * Passe au paramŠtre suivant: 
		 */
		field_params = field_params -> next;
	}

	/* 
	 * Fin de la liste 
	 */
	fputc( 0xFF, fstream );		/* Ajoute 0xFFFF pour signaler */
	fputc( 0xFF, fstream );		/* La fin de la liste */
}



/*
 * load_fieldpar(-)
 *
 * Purpose:
 * --------
 * Charge paramŠtres des champs de saisie
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 24.11.94: nouveau code de chargement aprŠs fnct_no (meilleure immunit‚ aux modifs et meilleure portabilit‚)
 * 17.12.94: new arg  SerializeType
 */
ARBO_FIELDPARS *	load_fieldpar( 
			FILE 			*	fstream,
			SERIALIZE_TYPE	SerializeType,	/* In: Type de donn‚es … charger */
			int				n_Version)		/* In: version de fichier */
{
	/*
	 * Variables: 
	 */
	size_t			load_res;		/* R‚sultat de l'op‚ration de chargement */
	unsigned			fnct_no = 0;	/* Num‚ro de fonction */
	ARBO_FIELDPARS	* first;			/* 1er paramŠtre */
	ARBO_FIELDPARS	** pred = &first;	/* Adr Ptr sur prochain ds le pr‚c‚dent */
	ARBO_FIELDPARS	* current;		/* Param courant */

	/*
	 * Charge paramŠtres: 
	 */
	while
	( 
		load_res = fread( &fnct_no, sizeof( int ), 1, fstream ),
		load_res == 1 /*PasFinFichier*/  &&  fnct_no != 0xFFFF /* PasFinListe */
	)
	{	/*
		 * Tant qu'il y a des paramŠtres … charger: 
		 */
		fseek( fstream, - sizeof( int ), SEEK_CUR );

		switch( SerializeType )
		{
			case	SERIALIZE_INPUTFPAR:
				current = MALLOC( sizeof( void * ) + sizeof( INPUT_FPAR ) );
				InputField_Load( &(current -> data.input), fstream, n_Version );
				break;
				
			case	SERIALIZE_OUTPUTFPAR:
				current = MALLOC( sizeof( void * ) + sizeof( OUTPUT_FPAR ) );
				OutputField_Load( &(current -> data.output), fstream, n_Version );
				break;
				
			default:
				ping();
		}

		/*
		 * Liaison avec le pr‚c‚dent: 
		 */
		*pred = current;	/* Indique adresse du param courant */

		/*
		 * Sauve adresse du ptr dans lequel il va falloir placer l'adr du param suivant: 
		 */
		pred = &( current -> next );			
	}

	/*
	 * Signale fin de la liste: 
	 */
	*pred = NULL;		/* Plus de param aprŠs */

	/*
	 * Contr“le si le chargement est ok: 
	 */
	if( fnct_no != 0xFFFF )
	{	/*
		 * S'il y a eu un problŠme: 
		 * Efface le d‚but de liste: 
		 */
		Delete_SingleLinkList( first );
		first = NULL;	/* Plus de liste */
	}

	/*
	 * Renvoie l'adresse du 1er param: 
	 */
	return	first;
}




/*
 * save_specialpar(-)
 *
 * Purpose:
 * --------
 * Sauve paramŠtres sp‚ciaux d'une page
 *
 * Algorythm:
 * ----------  
 * Sauve longueur puis paramŠtres: 
 *
 * Notes:
 * ------
 * La longueur … sauver peut ˆtre nulle.
 *
 * History:
 * --------
 * 10.05.94: fplanque: Created
 * 27.03.95: changed everything
 */
void	save_specialpar( 
			FILE 		*	fstream, 
			PAGEARBO	*	pArboPg )
{
	size_t	size_ParSize;	

	switch( pArboPg -> fnct_no )
	{	
		case FA_LECT_MSG:
			size_ParSize = sizeof( LECTURE_PAR );
			fwrite( &size_ParSize, sizeof( size_t ), 1, fstream );
			fwrite( pArboPg -> special_par.lecture, 1, size_ParSize, fstream );
			break;
			
		case FA_FILESEL:
			size_ParSize = sizeof( FILESEL_PAR ) - sizeof( char* );
			fwrite( &size_ParSize, sizeof( size_t ), 1, fstream );
			fwrite( pArboPg -> special_par.filesel, 1, size_ParSize, fstream );
			save_String( pArboPg -> special_par.filesel -> pMsz_RootPath, fstream );
			break;

		default:
			size_ParSize = 0;
			fwrite( &size_ParSize, sizeof( size_t ), 1, fstream );
	}
}



/*
 * ------------------------ DATAGROUPS ----------------------------
 */

 

/*
 * save_datagroup(-)
 *
 * Purpose:
 * --------
 * Sauvegarde d'un dossier de textes
 *
 * History:
 * --------
 * 19.06.94: fplanque: Created based on save_datas()
 * 14.12.94: Ne sauve que les textes ayant ‚t‚ modifi‚es
 * 14.12.94: sauve commentaires, ne rajoute plus d'extension par d‚faut
 * 15.12.94: changed to general function load_datagroup(); ne sauve pas le header
 * 25.03.95: sauve les fichires qui n'existent pas encore meme s'il ne portent pas de modifs
 */
int	save_datagroup(
			FILE 			*	fstream,			/* In: Fichier ds lequel on sauve */
			const char	*	cpsz_FileName,	/* In: Nom du fichier, pour cr‚er dossier */
			const char	*	cpsz_Instruct,	/* In: Instruction indiquant un nom de fichier datapage */
			int				n_fileType,		/* In: Type du fichier qu'on sauve */
			DATADIR		*	pDataDir )		/* In: Dossier racine de l'arborescence … sauver */
{
	FILE			*	fileStream;
	char			*	cpsz_PageName;
	DATAPAGE		*	pDataPage = pDataDir -> data_start;	/* 1Šre page */
	
	strcpy( G_tmp_buffer, cpsz_FileName );
	erase_extension( G_tmp_buffer );

	if( chdir( G_tmp_buffer ) != 0 )
	{	/*
		 * On a pas pu aller dans le directory:
		 * On va le cr‚er:
		 */
		if( Dcreate( G_tmp_buffer ) < 0 )
		{
			alert( DISK_CANTCREATEDIR );
			return	NO0;
		}

		if( chdir( G_tmp_buffer ) != 0 )
		{
			alert( DISK_CANTENTERDIR );
			return	NO0;
		}

	}

	/*
	 * Sauve objets (datapages): 
	 */
	while( pDataPage != NULL )
	{
		/*
		 * Sauve nom de la page:
		 */
		cpsz_PageName = pDataPage -> nom;		
		fprintf( fstream, "%s %s", cpsz_Instruct, cpsz_PageName );	/* Sauve Nom */
	
		/*
		 * Sauve commentaire en tant que commentaire: filename    ! comment : 
		 */
		if( pDataPage -> comment != NULL ) 
		{ 
			fputs( "  ! ", fstream );				 	/* Entete commentaire */
			fputs( pDataPage -> comment, fstream );	/* Commentaire */
		}

		fputc( '\r', fstream );					/* CR */
		fputc( '\n', fstream );					/* LF */

		/*
		 * V‚rifie si cette page a ‚t‚ modifi‚e
		 * ou si la page existe en RAM mais pas sur Disque (suite … une importation)
		 */
		if( pDataPage -> DataState.sstate == SSTATE_MODIFIED
			|| ! File_Exists( cpsz_PageName ) )
		{	/*
			 * Cette datapage a ‚t‚ modifi‚e: 
			 * Sauve la datapage dans un fichier ind‚pendant: 
			 * Ouvre un fichier: 
			 */
			fileStream = fopen( cpsz_PageName, "wb" );
			if ( fileStream == NULL )
			{  /* 
				 * Si on a pas pu ouvrir 
				 */
				if( errno != 5 )
				{	/*
					 * Si ce n'est pas une erreur de protection  (qui b‚n‚ficie d'une alerte TOS automatique ) 
					 */
					alert( errno );
				}
				/*
				 * La sauvegarde … ‚chou‚: 
				 */
				return	NO0;
			}

			/*
			 * Si on a pu ouvrir le fichier: 
			 */
			switch( n_fileType )
			{
				case	FS_DATAS:
					save_DBtoDXF( fileStream, cpsz_PageName, pDataPage );
					break;
	
				case	FS_TEXTES:
					save_DataBlock( fileStream, pDataPage -> data.dataBlock, FEMODE_SINGLE );
					break;
					
				default:
					ping();
			}

			/*
			 * Referme le fichier: 
			 */
			if( fclose( fileStream ) != 0 )
			{
				alert( errno );
			}
		}
		
		/*
		 * Passe … la page suivante: 
		 */
		pDataPage = pDataPage -> next;	
	}

	return	YES1;		/* La sauvegarde s'est bien effectu‚e */
}



/*
 * load_datagroup(-)
 *
 * Purpose:
 * --------
 * Chargement d'un DATAGROUP standard
 *
 * History:
 * --------
 * 19.06.94: fplanque: Created based on load_datas()
 * 11.08.94: fplanque: SSTATE_SAVED
 * 14.12.94: charge commentaires
 * 16.12.94: utilise attach_new_data()
 */
int	load_datagroup( 
			FILE			*	fstream, 		/* In: Fichier depuis lequel on charge */
			const char	*	cpsz_FileName,	/* In: Nom du fichier catalogue -> dossier de sauvegarde des fichiers ind‚pendants */
			char			*	pS_section,		/* In: Nom de la section dans laquelle on charge */
			char			*	pS_instruct,	/* In: Instruction indiquant un nom de fichier datapage */
			int				n_fileType,		/* In: Type du fichier qu'on charge */
			DATADIR		*	datadir )		/* In: dossier dans lequel on charge */
{
	DATAPAGE		*	curr_page;				/* Page en cours de chargement */
	FILE			*	datastream;				/* Stream du fichier contenant les donn‚es de la base courante */
	int				nb_dataPages = 0;		/* Nombre de bases charg‚es */
	char			*	instr;					/* Action lue ds fichier */
	char			*	pS_nomDataPage = NULL;
	char			*	piBsz_Comment;										
	DATAUNION		data_ptr;
	/* PROVISOIRE: Type de donn‚es stock‚es dans datapage: */
	DATATYPE			DataType = (n_fileType == FS_DATAS) ? DTYP_DATAS : DTYP_TEXTS;

	/*
	 * Teste pr‚sence des noms de fichiers: 
	 */
	if( ffind( fstream, pS_section ) != NULL )
	{	/*
		 * On se place dans le dossier ou sont sauv‚s les fichiers:
		 */

		strcpy( G_tmp_buffer, cpsz_FileName );
		erase_extension( G_tmp_buffer );
		if( chdir( G_tmp_buffer ) != 0 )
		{	/*
			 * Impossible d'ouvrir le dossier:
			 */
			alert( DISK_CANTENTERDIR );
			return	FALSE0;		/* Chargement … ‚chou‚ */
		}

		while( !( feof( fstream ) ) )
		{	/*
			 * Tant qu'il y a qque chose … charger: 
			 * Essaie de charger une instr (nom de fichier): 
			 */
			instr = get_config_line( fstream, ' ', &pS_nomDataPage, &piBsz_Comment );

			/*
			 * Teste instr: 
			 */
			if( instr != NULL )
			{	/*
				 * S'il y a une instruction:
				 */

				if( strcmp( instr, pS_instruct ) == 0 )
				{	/* 
					 * S'il faut charger une datapage: 
					 * Nom de la datapage: 
					 */
					pS_nomDataPage = STRDUP( pS_nomDataPage );		/* Duplique nom */
				
					/*
					 * Regarde s'il y a un commentaire:
					 */
					if( piBsz_Comment != NULL )
					{
						char * piBc_Exclamation = strchr( piBsz_Comment, '!' );
						
						if( piBc_Exclamation == NULL )
						{
							piBsz_Comment = NULL;
						}
						else
						{	/*
							 * Duplique le commentaire depuis son buffer
							 */
							piBsz_Comment = STRDUP( &piBc_Exclamation[2] );
						}
					}
	
					/*
					 * Cr‚e le nom du fichier dans le buffer temporaire: 
					 */
					strcpy( G_tmp_buffer, pS_nomDataPage );	/* Copie partie principale */
					
					/*
					 * Ouvre fichier: 
					 */
					datastream = fopen( G_tmp_buffer, "rb" );
					if ( datastream == NULL )
					{	/*
						 * Si on a pas pu ouvrir: 
						 */
						alert( errno );
					}
					else							
					{	/*
						 * Si on a pu ouvrir le fichier: 
						 * Charge les donn‚es du fichier: 
						 */
						switch( n_fileType )
						{
							case	FS_DATAS:
								data_ptr.records = load_datafile( datastream ); 
								break;
								
							case	FS_TEXTES:
								data_ptr.dataBlock = load_DataBlock( datastream, FEMODE_SINGLE );
								break;

							default:
								data_ptr.x = NULL;
								signale( "Ne sait pas charger!" );
						}

						/*
						 * Stockage des donn‚es charg‚es dans une DATAPAGE:
						 */
						if( data_ptr.x == NULL )
						{
							free_String( piBsz_Comment );
						}
						else
						{	/*
							 * Cr‚e zone d'info DATAPAGE standard: 
							 */
							curr_page = create_std_datapage( DataType, pS_nomDataPage );

							/*
							 * M‚morise commentaire:
							 */
							curr_page -> comment = piBsz_Comment;

							/*
							 * Fixe ptr sur les infos des enregistrements: 
							 * -------------------------------------------
							 */
							curr_page -> data = data_ptr;

							/*
							 * fixe la page comme charg‚e (mais non modifi‚e)
							 */
							dataPage_setSavState( curr_page, SSTATE_SAVED );
								
			
							/* 
							 * Lien avec le DataDir: 
							 */
							attach_new_data( datadir, curr_page );
				
							/* 
							 * OK, la page est charg‚e, on peut passer … la suivante 
							 */
							nb_dataPages ++;					/* 1 page de + */

						}

						/* 
						 * Ferme le fichier: 
						 */
						fclose( datastream );
					}

					/* 
					 * LibŠre m‚moire occup‚e par nom: 
					 */
					free_String( pS_nomDataPage );
				
				}
				else 
				{	/*
				 	 * Si ce n'est pas un commentaire: 
				 	 */
					signale( "Instruction inconnue " );
				}
			}
		}

		/* 
		 * Chargement OK: 
		 */
		return	OK1;
	}

	return	FALSE0;	/* Chargement … ‚chou‚ */
}
 

/*
 * ------------------------- DATAS ----------------------------
 */
 

/*
 * save_datas(-)
 *
 * Purpose:
 * --------
 * Sauvegarde d'un dossier de bases de donn‚es
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 14.12.94: Ne sauve que les bases ayant ‚t‚ modifi‚es
 * 14.12.94: sauve commentaires, ne rajoute plus d'extension par d‚faut
 */
int	save_datas( 
			FILE 			*	fstream, 
			const char	*	cpsz_FileName,
			DATADIR		*	pDataDir )
{
	/* 
	 * Sauve header: 
	 */
	fputs( "Filename: DATAS.STU\r\nContent : Bases de donn‚es\r\n", fstream );
	fputs( M_header, fstream );

	/*
	 * Sauve bases: 
	 */
	fputs( "\r\n[ Noms des bases de donn‚es utilis‚es par le serveur: ]\r\n\r\nBASES:\r\n", fstream );

	return	save_datagroup( fstream, cpsz_FileName, "BASE", FS_DATAS, pDataDir );	
}


/*
 * save_CompRecToDXF(-)
 *
 * Sauve un comp rec dans un fichier DXF
 *
 * 13.02.95: fplanque: created
 */
BOOL	save_CompRecToDXF(					/* Out: TRUE si success */
			FILE				*	fstream, 	/* In:  Fichier ds lequel on doit sauver */
			COMPACT_RECORD	*	pCompRec )	/* In:  Record … sauver */
{
	/* 
	 * D‚termine longueur de l'enregistrement en cours de traitement: 
	 */
	size_t	rec_length = pCompRec -> data.header .header .rec_length;

	/*
	 * Sauve l'enregistrement dans le fichier: 
	 */
	if( fwrite( pCompRec -> data.compact_rec, 1, rec_length, fstream ) != rec_length )
	{	/*
		 * Erreur lors de la sauvegarde:
		 */
		return	FALSE0;
	}

	return	TRUE_1;
}


/*
 * Append_CompRecToDXFFile(-)
 *
 * Purpose:
 * --------
 * Ajoute un compact record a un fichier DXF:
 *
 * Purpose:
 * --------
 * 13.02.95: fplanque: Created
 */
BOOL	Append_CompRecToDXFFile(			/* In: True si success */
			COMPACT_RECORD *	pCompactRec )	/* In: Ptr sur le Record … ajouter */
{
	FILE * fstream;
	BOOL	result;

	/*
	 * On se place dans le dossier concern‚: 
	 */
	Dsetdrv( G_filepath[0] - 'A' );	/* Ch drive */
	chdir( G_filepath );					/* Ch dir */

	/*
	 * Ouvre le fichier en mode APPEND:
	 */
	fstream = fopen( G_filename, "ab" );
	if( fstream == NULL )
	{	/*
		 * Si on a pas pu ouvrir:
		 */
		TRACE0("fopen() failed");
		return	FALSE0;
	}

	/*
	 * Ajoute le compact record:
	 */
	result = save_CompRecToDXF( fstream, pCompactRec );
	if( result == FALSE0 )
	{
		TRACE0("save_CompRecToDXF() failed");
	}

	/*
	 * Ferme le fichier:
	 */
	if( fclose( fstream ) != 0 )
	{
		TRACE0("fclose() failed");
		return	FALSE0;
	}

	return	result;
}

			

/*
 * save_DBtoDXF(-)
 *
 * Purpose:
 * --------
 * Sauvegarde d'une bases de donn‚es dans un fichier
 *
 * Notes:
 * ------
 * Ne v‚rifie pas les LOCKS sur les records sauv‚s.
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 29.07.94: error code return
 * 20.10.94: ne sauve plus commentaire
 */
int	save_DBtoDXF( 						/* Out: !=0 si erreur */
			FILE		*	fstream, 		/* In:  Fichier ds lequel on doit sauver */
			char 		*	generic_name, 	/* In:  Nom sous lequel on sauve: juste pour le header */
			DATAPAGE *	datapage )		/* In:  DATAPAGE encapsulant la base de donn‚es … sauver */
{
	/*
	 * Pointeurs: 
	 */
	DATA_RECORDS	*	records = datapage -> data.records;		/* Infos sur les enregistrements */
	COMPACT_RECORD	*	curr_record = records -> first_record;	/* Ptr sur enregistrement en cours de traitement */

	/*
	 * Sauve header: 
	 */
	fputs( "Filename: ", fstream );
	fputs( generic_name, fstream );		/* Nom du fichier */
	fputs( "\r\nContent : Donn‚es DXF\r\n", fstream );
	fputs( M_header, fstream );

	/*
	 * Sauve enregistrements: 
	 */
	while( curr_record != NULL )
	{	/* 
		 * Tant qu'il y a un enregistrement … sauver:
		 */
		if( save_CompRecToDXF( fstream, curr_record ) == FALSE0 )
		{
			return	ERROR_1;
		}

		/*
		 * Passe … l'enregistrement suivant: 
		 */
		curr_record = curr_record -> next;

	}
	
	return	SUCCESS0;
}



/*
 * load_datas(-)
 *
 * Purpose:
 * --------
 * Chargement d'un fichier de bases de donn‚es 
 * dansun DATADIR
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 19.06.94: sorti code de chargement commun … tous les datagroups g‚n‚raux
 * 22.01.95: gŠre no de version
 */
int	load_datas( 
			FILE 			*	fstream, 		/* In: Fichier depuis lequel on charge */
			const char	*	cpsz_FileName,	/* In: Nom du fichier catalogue -> dossier de sauvegarde des fichiers ind‚pendants */
			DATADIR		*	datadir )		/* In: dossier dans lequel on charge */
{
	/* 
	 * Contr“le le header:
	 */
	int n_Version = head_control( fstream, FS_DATAS, "Bases de donn‚es" );
	
	/*
	 * Contr“le le no de version:
	 */
	switch( n_Version )
	{
		case	0x0000:
			break;
			
		case	ERROR_1:
			return	FALSE0;	/* Chargement … ‚chou‚ */

		default:
			alert( BAD_VERSION );
			return	FALSE0;	/* Chargement … ‚chou‚ */
	}
		
	return	load_datagroup( fstream, cpsz_FileName, "BASES:", "BASE",
		 									FS_DATAS ,datadir );
}



/*
 * load_datafile(-)
 *
 * Purpose:
 * --------
 * Chargement d'un fichier de bases de donn‚es
 *
 * Algorythm:
 * ----------  
 * Pour chaque record charg‚, met le nbre de locks … 0.
 *
 * Suggest:
 * --------
 * PROVISOIRE: En cas d'‚chec en cours de chargement 
 * on perdra de la m‚moire (celle oqp par les enregistrement 
 * ayant r‚ussi)
 *
 * History:
 * --------
 * fplanque: Created
 * 17.05.94: fplanque: clear_AllLocks() pour chaque record charg‚
 * 19.06.94: fplanque: retourne maintenant un ptr sur DATA_RECORDS
 * 20.10.94: ne charge plus commentaire
 * 03.02.95: chang‚ format d'appel … fread()
 * 02.03.95: appel de CompRec_Create(), correction bug malloc
 */
DATA_RECORDS *	load_datafile(
						FILE *fstream )
{
	/*
	 * Pointeurs: 
	 */
	COMPACT_HEADER	*		header = (COMPACT_HEADER *) G_tmp_buffer;		/* Zone de chargement du header compact */
	COMPACT_RECORD	*		curr_record;			/* Enreg en cours de chargement */
	COMPACT_RECORD	*		prev_record = NULL;	/* Pr‚c‚dent enregitsrement */
	COMPACT_RECORD	* *	prev_ptrto_next;	/* Pointeur sur suivant ds enreg pr‚c‚dent */
	/*
	 * Variables: 
	 */
	DATA_RECORDS	*	p_DataRecords;		
	size_t				record_length;		/* Longueur de l'enregistrement courant */
	size_t				resultat;
	unsigned long		nb_records = 0;	/* Nombre d'enregistrements charg‚s */

	/* 
	 * Contr“le le header:
	 */
	int n_Version = head_control( fstream, FS_DXF, "Donn‚es DXF" );
	
	/*
	 * Contr“le le no de version:
	 */
	switch( n_Version )
	{
		case	0x0000:
			break;
			
		case	ERROR_1:
			/*
			 * Chargement … ‚chou‚ dans le header:
			 */
			return	NULL;

		default:
			/*
			 * Chargement a ‚chou‚ 
			 */
			alert( BAD_VERSION );
			return	NULL;	
	}


	/*
	 * Si le header est correct: 
	 * Cr‚e une zone d'info sur les enregistrements de la base: 
	 */
	p_DataRecords = (DATA_RECORDS *) MALLOC( sizeof( DATA_RECORDS ) );
	/*
	 * Adresse du 1er pointeur sur record: 
	 */
	prev_ptrto_next = &( p_DataRecords -> first_record);

	/*
	 * Chargement des enregistrements: 
	 */
	while
	(	/*
		 * Tente de charger un header: 
		 */
		resultat = fread( header, 1, sizeof(COMPACT_HEADER), fstream ),
		resultat != 0
	)
	{	/* 
		 * Tant qu'on est pas arriv‚ … la fin du fichier: 
		 * V‚rifie qu'on a affaire … un header: 
		 */
		if( resultat == sizeof(COMPACT_HEADER)
				&& header -> head_id == 'HEAD' )
		{
			/*
			 * Longueur de l'enregistrement: 
			 */
			record_length = header -> header .rec_length;
			/* printf( "\nReclen= %d ", record_length ); */

			/*
			 * Contr“le la validit‚ de la longueur: 
			 */
			if ( 	(record_length > sizeof(COMPACT_HEADER) )
				&&	(record_length & (~PARITY)) == 0 )	/* longueur doit etre paire */
			{ /*
				* Si la longueur semble correcte: 
				* Alloue une zone m‚moire pour l'enregistrement: 
				*/
				curr_record = CompRec_Create( record_length );
				/*	printf( "M adr=%lX ", curr_record ); */

				/*
				 * Recopie les infos/header d‚j… charg‚es: 
				 */
				curr_record -> data.header = *header;

				/*
				 * Charge la partie restante: 
				 */
				fread (	curr_record -> data.compact_rec + sizeof(COMPACT_HEADER) ,
							sizeof(int),
							( record_length - sizeof(COMPACT_HEADER) )/sizeof(int),
							fstream );


				/* 
				 * Fixe les pointeurs de liaison: 
				 */
				curr_record -> prev = prev_record;	/* Lien courant -> pr‚c‚dent */
				*prev_ptrto_next = curr_record;		/* Lien pr‚c‚dent -> courant */

				/*
				 * L'enregistrement qui vient d'ˆtre charg‚ n'est pas encore de LOCK‚
				 */
				clear_AllLocks( curr_record );


				/* 
				 * On va charger l'enreg suivant: 
				 */
				nb_records ++;						/* On a charg‚ un enregistrement de + */
				prev_record = curr_record;
				prev_ptrto_next = &(curr_record -> next);
			}
			else
			{	/* 
				 * Format de fichier incorrect: 
				 */
				alert( UNEXPECTED_FFMT );	/* Signale problŠme */
			
				return	NULL;	/* Chargement … ‚chou‚ */
			}
								
		}
		else
		{	/* Format de fichier incorrect: */
			alert( UNEXPECTED_FFMT );	/* Signale problŠme */
		
			return	NULL;	/* Chargement … ‚chou‚ */
		}
	}

	/*
	 * Fixe pointeurs: 
	 */
	p_DataRecords -> last_record = prev_record;	/* Ptr sur dernier enregistrement */
	*prev_ptrto_next = NULL;			/* Il n'y a plus d'enregistrement aprŠs */
	
	/*
	 * Fixe variables: 
	 */
	p_DataRecords -> nb_records = nb_records;	/* Nombre d'enregistrements charg‚s */

	/*
	 * Chargement OK: 
	 */
	return	p_DataRecords;
}


 
/*
 *	------------------------- TEXTES ----------------------------
 */


/*
 * load_textes(-)
 *
 * Purpose:
 * --------
 * Chargement d'un fichier de textes:
 *
 * History:
 * --------
 * 19.06.94: fplanque: Created based on load_datas()
 */
int	load_textes( 
			FILE 			*	fstream, 		/* In: Fichier depuis lequel on charge */
			const char	*	cpsz_FileName,	/* IN: Nom du fichier catalogue -> dossier de sauvegarde des fichiers ind‚pendants */
			DATADIR 		*	datadir )		/* In: dossier dans lequel on charge */
{
	/* 
	 * Contr“le le header:
	 */
	int n_Version = head_control( fstream, FS_TEXTES, "Textes" );
	
	/*
	 * Contr“le le no de version:
	 */
	switch( n_Version )
	{
		case	0x0000:
			break;
			
		case	ERROR_1:
			/*
			 * Chargement … ‚chou‚ dans le header:
			 */
			return	FALSE0;

		default:
			/*
			 * Chargement a ‚chou‚ 
			 */
			alert( BAD_VERSION );
			return	FALSE0;	/* Chargement … ‚chou‚ */
	}

	return	load_datagroup( fstream, cpsz_FileName, "TEXTES:", "TEXTE",
		 									FS_TEXTES ,datadir );

}


         
/*
 * load_1text(-)
 *
 * Purpose:
 * --------
 * Chargement d'un texte (ASCII)
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 02.09.94: modifi‚ chargement
 */
int	load_1text( 
			FILE *fstream, 
			DATADIR *datadir, 
			char * filename )
{
	DATAPAGE		*curr_page;			/* Page en cours de chargement */

	/*
	 * Cr‚e zone d'info DATAPAGE standard: 
	 */
	curr_page = create_std_datapage( DTYP_TEXTS, filename );
	
	/*
	 * Chargement du texte: 
	 */
	if( DataPge_LoadStdText( curr_page, fstream ) == SUCCESS0 )
	{
		attach_new_data( datadir, curr_page );
		
		return	YES1;
	}

	/*
	 * Chargement a ‚chou‚:
	 * On efface la page:
	 */	
	efface_page( curr_page );

	return	NO0;
}



/*
 * DataPge_LoadStdText(-)
 *
 * Purpose:
 * --------
 * Charge un fichier de caractŠres standard
 * dans une DATAPAGE
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 19.06.94: mise en service DATABLOCK
 * 19.06.94: appelle maintenant load_DataBlock()
 * 02.09.94: nom: load_std_text() -> DataPge_LoadStdText(), n'insŠre plus ds DATADIR tout seul, ne d‚truit pas non plus la page
 * 02.09.94: fixe la page comme SSTATE_SAVED
 */
int	DataPge_LoadStdText( 		/* Out: SUCCESS0 ou ERROR_1 */
			DATAPAGE	*	pDataPage,	/* In: Datapage ds laquelle il faut charger le texte */
			FILE 		*	fstream )	/* In: Fichier depuis lequel on charge */
{
	/*
	 * Charge texte:
	 */
	DATABLOCK * pDataBlock = load_DataBlock( fstream, FEMODE_SINGLE );

	if( pDataBlock != NULL )
	{	/*
		 * Si chargement OK:
		 */
		pDataPage -> data.dataBlock = pDataBlock;

		dataPage_setSavState( pDataPage, SSTATE_SAVED );

		return	SUCCESS0;
	}

	return	ERROR_1;
}

 
/*
 * save_textes(-)
 *
 * Purpose:
 * --------
 * Sauvegarde d'un dossier de textes
 *
 * History:
 * --------
 * 19.06.94: fplanque: Created based on save_datas()
 * 14.12.94: Ne sauve que les textes ayant ‚t‚ modifi‚es
 * 14.12.94: sauve commentaires, ne rajoute plus d'extension par d‚faut
 */
int	save_textes(
			FILE 			*	fstream, 
			const char	*	cpsz_FileName,
			DATADIR		*	pDataDir )
{
	/* 
	 * Sauve header: 
	 */
	fputs( "Filename: TEXTES.STU\r\nContent : Textes\r\n", fstream );
	fputs( M_header, fstream );

	/*
	 * Sauve textes: 
	 */
	fputs( "\r\n[ Noms des fichiers texte utilis‚es par le serveur: ]\r\n\r\nTEXTES:\r\n", fstream );

	return	save_datagroup( fstream, cpsz_FileName, "TEXTE", FS_TEXTES, pDataDir );	
}


 



/*
 * merge_text(-)
 *
 * Purpose:
 * --------
 * Chargement d'un texte ascii avec formattage direct en m‚moire
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
int	merge_text( 
			FILE *fstream, 
			TEXTLINE * start_line, 
			TEXTINFO * info_ptr )
{
	int	ouverture_ok = 0;

	#define	BUFF_SIZE	1024*8	/* 8 Ko de buffer chargement */

	char		*buffer, 				/* Buffer de chargement*/
				*buff_ptr,				/* Pointeur dans buffer */
				*extline,				/* Chaine extraite */
				*ext_ptr,				/* Pointeur ds chaine extraite */
				*new_line;				/* Ligne g‚n‚r‚e */
	int 		ext_length;				/* Longueur de la chaine extraite */
	char		current_car;			/* CaractŠre en cours de traitement */
	size_t	read_length;			/* Longueur lue */
	int		i;							/* Parcourt buffer */
	int		line_end=0;				/* Indique une fin de ligne */
	TEXTLINE	*text_ptr=start_line;	/* Fin du texte dans lequel on charge */

	buffer 	= (char *) MALLOC( BUFF_SIZE );		/* Alloue 4 Ko de buffer */ 
	extline	= (char *) MALLOC( G_def_text_width + 1 );	/* Alloue une ligne pour extraire */
	ext_ptr	= extline;
	ext_length = 0;			/* Chaine de longueur nulle */

	while
	(	/*
		 * Remplissage du buffer lecture: 
		 */
		read_length = fread ( buffer, 1, BUFF_SIZE, fstream ),
		read_length != 0
	)	
	{	/*
		 * Tant que la fin du fichier n'est pas atteinte: 
		 */
		if ( read_length == -1 )	/* Si erreur */
		{
			alert( errno );				/* Signale erreur */
			break;
		}

		buff_ptr	 = buffer;		/* On commence au d‚but du buffer */

		for ( i = 1;	i <= read_length;	i++, buff_ptr++ )
		{
			current_car = *buff_ptr;		/* CaractŠre en cours */

			/*
			 * D‚tection de la fin d'une ligne 
			 */
			if (	current_car==10				/* Si FF */
					&&	ext_length					/* et si il y a d‚j… qque chose ds buff d'extraction */
					&& *( ext_ptr -1 ) == 13)	/* et si le FF vient aprŠs un CR */
			{
				line_end = 1;			/* On arrive sur une fin de ligne */
				ext_ptr--;				/* on va Ecraser le CR */
			}

			/* 
			 * Extraction des caractŠres:
			 */					
			if (	!line_end			 		/* Si pas fin de ligne */
				&&	current_car != 0 )		/* Si pas un code NUL */
			{
				*ext_ptr++ = current_car;		/* Stocke caractŠre */
				ext_length++ ;
			}

			/*
			 * Fin d'une ligne extraite: 
			 */
			if ( line_end							/* Si fin de ligne */
				||	ext_length == G_def_text_width) 	/* ou long max atteinte */
			{
				/*
				 * Termine la chaine courante: 
				 */
				*ext_ptr = '\0';					/* Ajoute un NUL */
				ext_length++ ;						/* Longueur augmente */

				/*
				 * Cr‚e une nouvelle ligne: 
				 */
				new_line = (char *) MALLOC( ext_length ); 	/* R‚serve RAM */
				strcpy( new_line, extline );						/* Copie texte */
				text_ptr = insert_line( text_ptr, new_line, NIL, info_ptr );	/* Ajoute la ligne au texte */

				/*
				 * Reset ligne en cours d'extraction: 
				 */
				line_end = 0;				/* On est plus en fin de ligne */
				ext_ptr	= extline;		/* Ptr sur d‚but du buffer */
				ext_length = 0;			/* Chaine de longueur nulle pour l'instant */
			}
		}
		if ( read_length < BUFF_SIZE )	/* Si on a lu la fin du fichier */
			break;
	}

	if	( ext_length )				/* S'il reste une ligne non sauv‚e */
	{
		/*
		 * Termine la chaine courante: 
		 */
		*ext_ptr = '\0';					/* Ajoute un NUL */
		ext_length++ ;						/* Longueur augmente */

		/*
		 * Cr‚e une nouvelle ligne: 
		 */
		new_line = (char *) MALLOC( ext_length ); 	/* R‚serve RAM */
		strcpy( new_line, extline );						/* Copie texte */
		text_ptr = insert_line( text_ptr, new_line, NIL, info_ptr );	/* Ajoute la ligne au texte */
	}
	FREE( buffer );				/* Efface buffer */
	FREE( extline );				/* Efface buffer d'extraction */

	ouverture_ok = 1;
	
	return	ouverture_ok;
}




/*
 * save_text(-)
 *
 * Purpose:
 * --------
 * Sauvegarde d'un texte ascii r‚sident en m‚moire sous forme formatt‚e
 *
 * Suggest:
 * --------
 * Pas de crlf sur derniŠre ligne!
 *
 * History:
 * --------
 * 31.05.94: fplanque: Created
 */
void	save_text( 
			FILE 		*	fstream, 	/* In: Fichier ds lequel on veut sauver */
			TEXTINFO *	info_ptr )	/* In: Ptr sur le texte … sauver */
{
	/*
	 * On commence sur la ligne no 1 (et pas la 0):
	 */
	TEXTLINE *	pTextLine = (info_ptr -> firstline) -> next;

	while( pTextLine != NULL )
	{
		if( pTextLine -> text != NULL )
		{
			fputs( pTextLine -> text, fstream );	/* Ligne de texte */
		}
		fputs( G_crlf, fstream );						/* CR LF */

		pTextLine = pTextLine -> next;
	}
}



/*
 * --------------------------- PAGES ECRAN -------------------------------
 *
 * Les pages ecran sont parfois trait‚es comme des 'blocs'
 */


/*
 * load_PagesEcran(-)
 *
 * Purpose:
 * --------
 * Chargement d'un fichier de pages ‚cran 
 * en Smart Format
 * dans un DATADIR
 *
 * Suggest:
 * ------
 * appeller plutot un truc genre: dataDir_InsertStdDataPg() mais pas Std au lieu de attach_new_data()
 *
 * History:
 * --------
 * 02.09.94: fplanque: Created based on load_arbo()
 * 15.09.94: corrig‚ type de fichier ds head_control, extension chgt anciens fichiers
 * 20.09.94: corrig‚ bug type de page
 * 21.01.95: gŠre no de version
 */
int	load_PagesEcran( 						/* Out: */
					FILE 		*	fstream,		/* In: Fichier depuis lequel on charge */
					DATADIR	*	pDataDir )	/* In: Dossier dans lequel on doit charger */
{
	/* 
	 * Contr“le le header:
	 */
	int n_Version = head_control( fstream, FS_PAGES_ECRAN, "Pages-Ecran" );
	
	/*
	 * Contr“le le no de version:
	 */
	switch( n_Version )
	{
		case	0x0000:
			break;
			
		case	ERROR_1:
			/*
			 * Chargement … ‚chou‚ dans le header:
			 */
			return	NO0;

		case	CHANGE_2:
			/* 
			 * Si le header est incorrect:
			 * On revient au d‚but du fichier et
			 * Essaie de charger le fichier comme s'il avait ‚t‚ cr‚‚ avec STUT 2.3
			 */
			if( alert( QUERY_VDTFORMAT ) == 2 )
			{	/*
				 * Ce n'est pas un stut 2.3 … 2.6
				 */
				return	NO0;
			}

			graf_mouse( BUSYBEE, NULL );

			/*
			 * Revient au d‚but du fichier:
			 */			
			fseek( fstream, 0, SEEK_SET );
	
			return	load_pages( fstream, pDataDir );		 

		default:
			/*
			 * Chargement a ‚chou‚ 
			 */
			alert( BAD_VERSION );
			return	NO0;	/* Chargement … ‚chou‚ */
	}

	/*
	 * Si header est correct (OK1):
	 */

	if( ffind( fstream, "PAGES:" ) != NULL )
	{	/*
		 * Si on a trouv‚ les pages:
		 * Chargement des pages: 
		 */
		char				ctrl_car;
		DATAPAGE		*	pDataPage;
		DATABLOCK	*	pDataBlock;

		while(	ctrl_car = getc( fstream ),
				 	ctrl_car	== '>' )
		{	/*
			 * Tant qu'il reste une page … charger:
			 * Charge nom: 
			 */
			load_str_tobuffer( fstream, 12 );		/* 12 car max */

			/* 
			 * Cr‚e page: 
			 */
			pDataPage = create_std_datapage( DTYP_PAGES, G_tmp_buffer );

			/*
			 * Charge commentaire: 
			 */
			pDataPage -> comment = load_String( fstream );
			
			/*
			 * Chargement des donn‚es: 
			 */
			pDataBlock = load_DataBlock( fstream, FEMODE_INTEGRATED );

			if( pDataBlock == NULL )
			{	/*
				 * Arrˆte le Chargement:
				 * Par contre on dit OK, pour les autres pages d‚j… charg‚es:!
				 */
				efface_page( pDataPage );					

				return	YES1;
			}

			pDataPage -> data.dataBlock = pDataBlock;

			/*
			 * Init statut sauvegarde: sauv‚e
			 * Pas de redraw, car page pas encore ajout‚e ds DATAGROUP
			 */
			dataPage_setSavState( pDataPage, SSTATE_SAVED );

			/*
			 * InsŠre page dans datadir:
			 */
			attach_new_data( pDataDir, pDataPage );

		}
	}

	/*
	 * Chargement OK:
	 */
	return YES1;			
}



/*
 * load_pages(-)
 *
 * Purpose:
 * --------
 * Chargement d'un fichier de pages ‚cran
 * au format STUT ONE 2.3
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 19.06.94: mise en service DATABLOCK
 * 11.08.94: met les pages charg‚es en SSTATE_SAVED
 * 02.09.94: ajoute ".VDT" aux noms des pages
 * 31.01.95: fixe ptr sur datadir
 */
int	load_pages( 
			FILE 		*	fstream, 
			DATADIR	*	datadir )
{
	int			ouverture_ok = 1;
	int			nb_pages;				/* Nombre de pages ds le fichier */
	int			i;
	DATAPAGE	*	curr_page;				/* Page en cours de chargement */
	DATAPAGE	*	last_page;				/* Adr de la Page qui vient d'ˆtre charg‚e */
	DATAPAGE	**	last_nextptr;			/* Pointeur de la page pr‚c‚dente vers la page courante */
	DATABLOCK * pDataBlock;				/* Ptr sur infos sur block de donn‚es */
	char		*	ptr;						/* Pointeur dans la zone de chargement courante */
	unsigned		length;					/* Long de la page courante */
	char			ctrl;						/* Octet de contr“le */

	/*
	 * Nombre de pages: 
	 */
	fread ( &nb_pages, sizeof( nb_pages ), 1, fstream ); /* Charge nombre de pages */

	/*
	 * Adr du ptr sur la premiŠre page qui va ˆtre charg‚e: 
	 */
	if( datadir -> nb_elts == 0)
	{	/*
		 * S'il n'y a pas encore de page en m‚moire: 
		 */
		last_page = NULL;			/* Il n'y a encore aucune page de charg‚e */
		if ( datadir -> data_start == NULL)
		{	/*
			 * On va rattacher la 1ERE page: 
			 */
			last_nextptr = &(datadir -> data_start);
		}
		else
		{
			ping();				/* ANORMAL! */
		}
	}
	else
	{	/*
	 	 * S'il y a d‚j… des pages en m‚moire: 
	 	 */
		last_page = datadir -> data_end;	/* Adr de la derniŠre page en m‚moire */
		if ( datadir -> data_start != NULL  &&  last_page !=NULL )
		{	/*
			 * On va ajouter les nlles pages … la suite de la derniŠre: 
			 */
			last_nextptr = &((datadir -> data_end) -> next);
		}
		else
		{
			ping();				/* ANORMAL! */
		}
	}


	/*
	 * Charge les pages 1 par 1 
	 */
	for( i=0; i<nb_pages; i++) 
	{
		/*
		 * Contr“le:
		 */
		fread ( &ctrl, sizeof( char ), 1, fstream );	 /* Charge octet de contr“le */
		if ( ctrl != 255 )
		{
			ping();
		}
		
		
		/*
		 * Charge nom: 
		 */
		load_str_tobuffer( fstream, 8 );
		/*
		 * Ajoute .VDT:
		 */
		strcat( G_tmp_buffer, ".VDT" );

		/*
		 * Cr‚e zone d'info DATAPAGE standard: 
		 */
		curr_page = create_std_datapage( DTYP_PAGES, G_tmp_buffer );
		/*
		 * Lien vers la page pr‚c‚dente:
		 */
		curr_page -> prev = last_page;
		/*
		 * Lien de la page pr‚c vers la courante: 
		 */
		*last_nextptr = curr_page;			
		/*
		 * Dossier auquel appartient la page:
		 */
		curr_page -> pDataDir = datadir;

		/*
		 * Cr‚e infos sur block en m‚moire:
		 */
		pDataBlock = create_stdDataBlock();
		/*
		 * Le lie … la page:
		 */
		curr_page -> data.dataBlock = pDataBlock;

		/*
		 * Charge longueur page: 
		 */
		fread ( &length, sizeof( int ), 1, fstream ); /* Charge longueur */
		pDataBlock -> ul_length = length;

		/*
		 * Charge DATAs de la page: 
		 */
		if ( length != 0 )
		{
			/*
			 * Cr‚e une zone de stockage: 
			 */
			ptr = (char*) MALLOC( length );
			pDataBlock -> p_block = ptr;			/* Stocke l'adresse */
			/*
			 * Charge page: 
			 */
			fread ( ptr, 1, length, fstream );
		}
		
		/*
		 * La page es maintenant pleine mais sauv‚e:
		 */
		dataPage_setSavState( curr_page, SSTATE_SAVED );
		
		/*
		 * OK, la page est charg‚e, on peut passer … la suivante 
		 */
		last_page = curr_page;
		last_nextptr = &(last_page -> next);
	}

	/*
	 * Lien de la page pr‚c vers la courante: YENAPLUS! : 
	 */
	*last_nextptr = NULL;			
	/*
	 * Pointeur sur la derniŠre page: 
	 */
	datadir -> data_end = last_page;

	/*
	 * Stocke nombre de pages effectivement charg‚es: 
	 */
	(datadir -> nb_elts) += i;	/* Nb de pages charg‚es en PLUS de celles qui existaient d‚j… */

	return	ouverture_ok;
}




/*
 * save_PagesEcran(-)
 *
 * Purpose:
 * --------
 * Sauvegarde d'un dossier de pages ‚cran
 *
 * History:
 * --------
 * 02.09.94: fplanque: Created
 */
int	save_PagesEcran( 				/* Out: YES1 si sauvegarde OK */
			FILE 		*	fstream, 	/* In:  Fichier ds lequel on doit sauver */
			DATADIR	*	pDataDir )	/* In:  Dossier de pages ‚cran … sauver */
{
	/*
	 * Variables: 
	 */
	DATAPAGE	*	datapage = pDataDir -> data_start;	/* 1Šre page */

	/*
	 * Sauve header: 
	 */
	fputs( "Filename: VIDEOTEX.STU\r\nContent : Pages-Ecran\r\n", fstream );
	fputs( M_header, fstream );

	/* 
	 * Sauve pages: 
	 */
	fputs( "PAGES:\r\n", fstream );
	while( datapage != NULL )
	{
		/* 
		 * Sauve octet de contr“le indiquant le d‚but d'une page: 
		 */
		putc( '>', fstream );

		/* 
		 * Sauve nom de la page: 
		 */
		save_String( datapage -> nom, fstream );	/* Nom */
	
		/* 
		 * Sauve commentaire: 
		 */
		save_String( datapage -> comment, fstream );	/* Commentaire */

		/* 
		 * Donn‚es de la page vid‚otex: 
		 */
		if( save_DataBlock( fstream, datapage -> data.dataBlock, FEMODE_INTEGRATED ) == ERROR_1 )
		{
			return	NO0;
		}
		
		/*
		 * Passe … la page suivante: 
		 */
		datapage = datapage -> next;	
	}

	/*
	 * Sauve octet de contr“le indiquant qu'il n'y a plus de page: 
	 */
	putc( 0xFF, fstream );

	return	YES1;		/* La sauvegarde s'est bien effectu‚e */
}

             
             
             
/*
 * load_1page(-)
 *
 * Purpose:
 * --------
 * Chargement d'une page ‚cran
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
int	load_1page( 
			FILE 		*	fstream, 
			DATADIR 	*	datadir, 
			char 		*	filename )
{
	DATAPAGE	*curr_page;				/* Page en cours de chargement */

	/*
	 * Cr‚e zone d'info DATAPAGE standard: 
	 */
	curr_page = create_std_datapage( DTYP_PAGES, filename );

	/*
	 * Chargement de la page: 
	 */
	if( DataPge_LoadStdText( curr_page, fstream ) == SUCCESS0 )
	{
		attach_new_data( datadir, curr_page );
		
		return	YES1;
	}

	/*
	 * Chargement a ‚chou‚:
	 * On efface la page:
	 */	
	efface_page( curr_page );

	return	NO0;

}


/*
 * -------------------------- IMAGES -----------------------------
 */


/*
 * load_pi3(-)
 *
 * Purpose:
 * --------
 * Chargement d'une image Degas Elite
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 19.06.94: fplanque: ne charge plus longueur du fichier! cause: mise en service DATABLOCK
 * 29.07.94: fplanque: correction bug dans MEMSET: 132 -> 32 octets seulement sont mis … 0
 */
int	load_pi3( FILE *fstream, DATADIR *datadir, char * filename )
{
	int		ouverture_ok = 1;		/* A priori, on peut charger le fichier */
	DATAPAGE	*curr_page;				/* Page en cours de chargement */
	char		*ptr;						/* Pointeur sur la zone de chargement */
	unsigned	length;					/* Longueur charg‚e */

	/*
	 * Cr‚e zone d'info DATAPAGE standard: 
	 */
	curr_page = create_std_datapage( DTYP_PICS, filename );

	/*
	 * Cr‚e une zone de stockage pour DATAs: 
	 */
	ptr = (char *) MALLOC( sizeof(DEGASPIX) );
	curr_page -> data.degaspix = (DEGASPIX *) ptr;		/* Stocke l'adresse */
	if ( ptr == NULL)
	{
		alert( NOMEM_OPENDOC );		/* Pas assez de mem pour ouvrir ce doc */
		ouverture_ok = 0;
	}
	else
	{
		/*
		 * Charge DATAs de la page: 
		 */
		length = (unsigned) fread ( ptr, 1, sizeof(DEGASPIX)+1, fstream ); /* Charge 32066+1 octets */
		if ( length == 32034 )
		{	/*
			 * Si fichier au format degas PAS ‚lite! 
			 */
			ptr += 32034;
			memset( ptr, 0, 32 );	/* Finit de remplir avec des /0 */
		}

		if( length != 32034 && length != sizeof(DEGASPIX) ) 
		{	/*
			 * Si longueur du fichier incorrecte: 
			 */
			alert( BAD_FILEFMT );	/* Format de fichier non reconnu! */
			ouverture_ok = 0;			/* Signale erreur */
		}
		else
		{	/*
			 * Relie la nlle image aux autres: 
			 */
			attach_new_data( datadir, curr_page );
		}
	}

	/*
	 * Si le chargement n'a pas pu s'effectuer: 
	 */
	if ( ouverture_ok == 0 )
	{	/*
	 	 * Si on a pas pu charger:
	 	 */
		if ( curr_page -> data.degaspix != NULL )
		{
			FREE( curr_page -> data.degaspix );		/* LibŠre zone page */
		}
		FREE( curr_page );					/* LibŠre ref de la page */
	}

	return	ouverture_ok;
}
         
         
/*
 * write_PIx(-)
 *
 * Purpose:
 * --------
 * Sauvegarde d'une image Degas Elite
 *
 * History:
 * --------
 * 29.07.94: fplanque: Created
 */
int	write_PIx( 							/* In: !=0 si erreur */
			FILE 		*	fstream, 		/* In: Fichier dans lequel on veut sauver */
			DEGASPIX *	pDegasPix )		/* In: Ptr sur image en m‚moire */
{
	size_t	elem_count = sizeof( DEGASPIX );

	if( fwrite( pDegasPix, 1, elem_count, fstream ) != elem_count )
	{
		return	ERROR_1;
	}

	return	SUCCESS0;
}


/*
 * ------------------------ ROUTINES GENERALES ---------------------------
 */
 
 
/*
 * load_String(-)
 *
 * Purpose:
 * --------
 * Charge une chaine de caractŠres termin‚e par \0 et la renvoie
 *
 * Algorythm:
 * ----------  
 * Renvoie NULL si la chaine ‚tait vide
 *
 * History:
 * --------
 * 24.05.94: fplanque: Created
 * 14.02.95: verified mallocs
 */
char *	load_String(					/* Out: chaine de caractŠres charg‚e */
					FILE *	fstream )	/* In:  fichier depuis lequel on va charger */
{
	/*
	 * Charge une chaine dans G_tmp_buffer:
	 */
	load_str_tobuffer( fstream, 256 );	
	
	/*
	 * Teste si cette chaŒne est vide ou non: 
	 */
	if( *G_tmp_buffer == '\0' )
	{	/*
		 * ChaŒne vide: 
		 */
		return NULL;
	}

	/*
	 * Duplique juste la longueur n‚cessaire: 
	 */
	return	STRDUP( G_tmp_buffer );			

}



/*
 * save_String(-)
 *
 * Purpose:
 * --------
 * Sauve une chaine de caractŠres termin‚e par \0
 *
 * History:
 * --------
 * 24.05.94: fplanque: Created
 */
void	save_String(
				char *	pString,		/* In: Pointeur sur la chaŒne … sauver */
				FILE *	fstream )	/* In: fichier dans lequel on va sauver */
{
	if( pString != NULL )
	{	/*
	 	 * S'il y a des caractŠres:
	 	 */
		fputs( pString, fstream );		/* ChaŒne de caractŠres */
	}
	fputc( 0, fstream );					/* \0 final */
}



/*
 * load_DataBlock(-)
 *
 * Purpose:
 * --------
 * Chargement d'un DATABLOCK
 * exemple: - texte ascii … stocker sous forme COMPACTE
 *          - page vdt...
 *
 * History:
 * --------
 * 19.06.94: fplanque: Created
 * 07.09.94: ajout du paramŠtre FEMODE
 */
DATABLOCK *	load_DataBlock( 			/* Out: Infos sur block charg‚ */
					FILE	*	fstream,		/* In:  Fichier duquel on charge */
					FEMODE	FEMode)		/* In:  Mode d'enregistrement ds fichier */
{
	/*
	 * Cr‚e zone d'infos sur bloc m‚moire:
	 */
	DATABLOCK	* pDataBlock = create_stdDataBlock();

	/*
	 * D‚termine longueur du datablock:
	 */
	long	l_length = -1;
	
	if( FEMode == FEMODE_SINGLE )
	{	/*
		 * Demande longueur du fichier :
		 */
		l_length = filelength( fileno( fstream ) );
	}
	else
	{	/*
		 * FEMode == FEMODE_INTEGRATED
		 * Charge longueur ds le fichier mˆme:
		 */ 
		fread( &l_length, sizeof( long ), 1, fstream );
	}

	if( l_length < 0 )
	{	/*
	 	 * Impossible de connaitre longueur:
	 	 */
		FREE( pDataBlock );
		return NULL;				/* Chargement a ‚chou‚ */
	}

	pDataBlock -> ul_length = l_length;

	/*
	 * Charge Bloc: 
	 */
	if( l_length == 0 )
	{	/*
		 * Chargement OK:
		 */
		return	pDataBlock;
	}
	else
	{	/*
		 * Cr‚e une zone de stockage: 
		 */
		char	* p_block = (char*) MALLOC( l_length );
		pDataBlock -> p_block = p_block;			/* Stocke l'adresse */
		/*
		 * Charge datas: 
		 */
		if( fread( p_block, 1, l_length, fstream ) > 0 )
		{	/*
			 * Chargement OK:
			 */
			return	pDataBlock;
		}
		FREE( p_block );
	}
	FREE( pDataBlock );

	/*
	 * Chargement a ‚chou‚:
	 */
	return	NULL;
}



/*
 * save_DataBlock(-)
 *
 * Purpose:
 * --------
 * Sauvegarde d'un DataBlock:
 * exemples: - texte ascii r‚sident en m‚moire sous forme COMPACTE
 *           - page vdt...
 *
 * History:
 * --------
 * 19.06.94: fplanque: Created
 * 29.07.94: error code return
 * 07.09.94: gestion de FEMODE_INTEGRATED
 */
int	save_DataBlock( 
			FILE			*	fstream, 		/* In: Fichier ds lequel on veut sauver */
			DATABLOCK	*	pDataBlock,		/* In: Ptr sur le DATABLOCK … sauver */
			FEMODE			FEMode)			/* In:  Mode d'enregistrement ds fichier */
{
	size_t	size_bloc = pDataBlock -> ul_length;

	if( FEMode == FEMODE_INTEGRATED )
	{	/*
		 * Si plusieurs datablocks sont sauv‚s dans un mˆme fichier,
		 * il faut sauver la taille du bloc avant:
		 */
		fwrite( &size_bloc, sizeof( long ), 1, fstream );
	}


	if( fwrite( pDataBlock -> p_block, 1, size_bloc, fstream ) != size_bloc )
	{
		return	ERROR_1;
	}

	return	SUCCESS0;
}


