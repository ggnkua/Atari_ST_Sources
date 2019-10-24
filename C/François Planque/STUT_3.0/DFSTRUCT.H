/*
 * dfstruct.h
 *                                                                 
 * Purpose:
 * --------
 *	Ce fichier contient toutes les structures de donn‚es inter-
 * d‚pendantes utilis‚es par STUT ONE (fenˆtres+contenu etc.. )
 *
 * Notes:
 * ------
 * Diagramme de d‚pendances:  
 *
 *       				       dxf.h           arbotree.h
 * 							      | 	   	      /      \				      
 * DATABLOCK	DEGASPIX  DATA_RECORDS  PAGEARBO   ARBO_TEXTPAR
 *    		\_________\____   |   ____/             / 
 *									\  |  /                 /
 *     						 {DATAUNION}              /
 *          				      |           DIRSPEC
 *								  DATAPAGE       /           TEXTLINE
 *			   	      	          \     /               /
 *											DATADIR           TEXTINFO          FNCTSPEC
 *											/	    \___   ___/       \
 *  		   	      	    DATAGROUP       \ /       TEXT_DRAWPAR
 *  		      	      	                 FTA
 *
 *          
 *
 * History:
 * --------
 * 25.11.93: Sortie des structures de gestion des fenêtres AES vers
 *					le fichier gemwdef.h   
 * 25.11.93: Sortie des structures de gestion des voies vers le
 *					fichier serveur.h
 */

/*
 * V‚rifie si les pr‚sentes d‚finitions ont d‚ja ‚t‚ faites:
 */
#if  !defined( _DFSTRUCT_H_ )
#define _DFSTRUCT_H_

/* 
 * Headers indispensables:
 */
	#include	<aes.h>						/* header AES */


/*
 * Custom Types:
 */
	#include "DXF.H"     
	#include "ARBOTREE.H"


/*
 * Icon-extended-(datagroup)type (stocked in flags) definitions: 
 * Les DG_xxx sont les types utilis‚s dans le champ type des DATAGROUPS
 * et DATAPAGES.
 * ils sont repris sous forme de DTYP_xxx
 */
typedef
	enum
	{
		STYP_NONE =0,			/* pas de type */
		DTYP_ARBO,
		DTYP_PAGES,
		DTYP_DATAS,
		DTYP_TEXTS,
		DTYP_PICS,
		DTYP_UNKNOWN
	}
	DATATYPE;

	#define	NB_DATAGROUPS		5		/* On va cr‚er un emplacement pour 5 datagroups */
	#define	RAMPATH_MAXLEN		107	/* Suffit pour 10 dossiers + 1 nom de fichier */



/*
 * DEGASPIX: Image DEGAS Elite
 */
typedef
	struct
	{
		unsigned	int	rez;					/* R‚solution */
		unsigned	int	color[16];			/* Palette des 16 Couleurs */
		unsigned	int	bitmap[ 32000 / sizeof(unsigned int) ]; /* Bitmap */
		unsigned int	rsvd[16];			/* Ce qu'il reste derriŠre */
	}
	DEGASPIX;
                    

/*
 * TEXTLINE: Ligne intégrée à un texte avec ptrs next/prev & info
 */                  
typedef
	struct		textline
	{
		struct textline	*prev;		/* Ptr sur Ligne pr‚c‚dente */
		struct textline	*next;		/* Ptr sur Ligne suivante */
		struct
		{
			int	bufsize	 : 15;		/* Taille du buffer d'‚dition contenant cette ligne (\0 non compris) */
			int	continued : 1;
		}						info1;
		int					length;		/* Longueur de cette ligne (\0 non compris) */
		char					*text;		/* Pointeur sur le texte */
	}
	TEXTLINE;
   

/*
 * TEXTINFO: Infos sur un texte
 *
 * Purpose:
 * --------
 * Fournit point d'accŠs vers la 1ere et derniŠre ligne au format
 * TEXTLINE d'un texte
 *
 * Notes:
 * ------
 *
 * Notes:
 * -----
 * En COURS:
 * Virer topline et le mettre dans une structure contenant aussi un
 * ptr sur le reste de TEXTINFO. Cette structure pourra alors etre
 * liee a WIPARAMS par l'intermediaire de WORK_DRAW (25.11.93)
 * Mˆme chose pour le curseur...
 * 
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.05.94: fplanque: Ajout de variables de gestion du curseur
 * 25.05.94: fplanque: Sorti toutes variables concernant l'affichage ds fenetre GEM vers TEXT_DRAWPAR
 */
typedef
	struct
	{
		TEXTLINE		*	firstline;			/* Ptr sur 1Šre ligne du texte affiché */
		TEXTLINE		*	lastline;			/* Ptr sur derniŠre ligne du texte */
		long				nb_lignes;			/* Nombre total de lignes */
	}
	TEXTINFO;


/*
 * TEXT_DRAWPAR: paramŠtres n‚cessaires … l'affichage d'un texte
 * dans une fenˆtre.
 *
 * Purpose:
 * --------
 * Fournit toutes les informations pour l'affichage d'un texte
 * lorsque le texte est affich‚ dans une fenˆtre:
 * la ligne du haut de la fenetre, la fonte, couleur etc...
 * Position du curseur, etc...
 *
 * Notes:
 * ------
 * Du au pointeur *topline, le texte ne doit etre affiche que dans
 * une seule fenetre a la fois
 *
 * Suggest:
 * --------
 * Virer topline et le mettre dans une structure contenant aussi un
 * ptr sur le reste de TEXTINFO. Cette structure pourra alors etre
 * liee a WIPARAMS par l'intermediaire de WORK_DRAW (25.11.93)
 * Mˆme chose pour le curseur...
 * 
 * History:
 * --------
 * 25.05.94: fplanque: Created
 */
typedef
	struct
	{
		TEXTINFO		*	pTextInfo;		/* ptr sur les infos sur le texte en RAM */
		TEXTLINE		*	pTextLine_top;	/* Ptr sur 1Šre ligne affich‚e en haut de la fenˆtre */
		long				l_topline;		/* No de la ligne en haut de la fenetre [0...] */

		int				n_points;		/* Taille en "points" */
		int				n_char_h;		/* Hauteur d'un caractŠre: */
		int				n_cell_w;		/* Largeur d'un emplacement caractŠre */
		int				n_cell_h;		/* Hauteur d'un emplacement caractŠre */

		/*
		 * Pour textes non ‚ditables seulement:
		 */
		long				l_nbLinesMax;	/* Nbre de lignes … conserver en m‚moire, les plus vieilles sont d‚truites */

		/*
		 * Edition:
		 * Si le texte est Read Only, pTextLine_edit === NULL
		 */
		TEXTLINE		*	pTextLine_edit;	/* Ligne en cours d'‚dition; porte le curseur */
		long				l_LigneCsr;			/* No Ligne en cours d'‚dition */
		int				n_ColCsr;			/* Colonne ou se trouve le curseur [0...nb_cars] si nb_cars:apres dernier caractŠre  */
	}
	TEXT_DRAWPAR;


/*
 * DATABLOCK: Bloc de donn‚es
 *
 * History:
 * --------
 * 19.06.94: Created
 */
typedef
	struct
	{
		char				*	p_block;			/* Donn‚es */
		unsigned	long		ul_length;		/* Longueur de ce bloc */
	}
	DATABLOCK;
   
/*
 * DATAUNION: Ptr sur une entit‚ de donn‚es
 *
 * History:
 * --------
 * 19.06.94: Vir‚ le ptr texte direct
 */
typedef
	union
	{
		PAGEARBO			*	pagearbo;	/* Page arborescence (DTYP_ARBO) */
		DATABLOCK		*	dataBlock;	/* Block de donn‚es brutes (DTYP_PAGES, DTYP_TEXTS ) */
		DATA_RECORDS	*	records;		/* Enregistrements (DTYP_DATAS) */
		DEGASPIX			*	degaspix;	/* Image Degas (DTYP_PICS) */
		void				*	x;				/* G‚n‚rique */
	}
	DATAUNION;


/*
 * DATASTATE: Etat des donn‚es:
 *
 * 06.08.94: fplanque: Created
 */                                    
typedef
	struct
	{
		BOOL				b_open	:	1;			/* != 0 si  fenˆtre ouverte dessus */
		unsigned int	sstate	:	2;			/* indication de sauvegarde des donn‚es */
	}
	DATASTATE;
           
                                    
/*
 * DATAPAGE: Page de donn‚es
 *
 * Purpose:
 * --------
 * Ajoute … une Entit‚ de donn‚es, un nom, un commentaire etc...
 * et l'insŠre ds une liste chain‚e
 *
 * Suggest:
 * --------
 * Peut ˆtre un sous type pour pr‚ciser le DATATYPE ?
 *
 * History:
 * --------
 * 11.07.94: fplanque: ajout du membre DATATYPE
 * 06.08.94: fplanque: remplace le int state par un DATASTATE
 * 15.12.94: ajout‚ backptr vers le DATADIR auqeulest reli‚e la DATAPAGE
 */
typedef
	struct		datapage
	{
		struct datapage *	prev;			/* Ptr sur Page pr‚c‚dente */
		struct datapage *	next;			/* Ptr sur Page suivante */
		struct datadir	 *	pDataDir;	/* Ptr sur le Dir auquel appartient la page */
		DATATYPE				DataType;	/* Type de donn‚es */
		char					nom[13];		/* Nom de cette page */
		DATAUNION			data;			/* Pointeur sur les donn‚es de la page */
		char					*comment;	/* Commentaire sur cette page (… titre informatif) */
		DATASTATE			DataState;	/* Status */
	}
	DATAPAGE;


/*
 * DIRSPEC: Sp‚cifications d'un directory d'arborescence
 *
 * Purpose:
 * --------
 * Fournit des informations compl‚mentaires et sp‚cifiques au type 
 * de donn‚es g‚r‚es sur un directory
 * pour l'arbo:
 * 	- nom du lien arbo servant de point d'entree dans le directory
 * 	- Autres rajout‚s le 14.02.95, pris dans DATADIR
 */
typedef
	struct
	{
		KEYWORD_LIST *	liens_in;		/* Liste des nomd des liens-arbo */
												/* d'entr‚e dans ce dir */
		unsigned			max_objs;		/* Nombre d'objets maximum avant modification taille zone objects */
		unsigned			nb_objs;			/* Nombre d'objets */
		unsigned			max_iblks;		/* Nombres d'ICONBLOCKs maxi */
		unsigned			nb_iblks;		/* Nombres d'ICONBLOCKs */

		unsigned		*	dir_map;			/* Tableau repr‚sentatif */
												/* Format:
												 *	- Largeur
												 *	- Hauteur
												 *	- Elements...
												 */	
	}
	DIRSPEC;


/*
 * DATADIR: Dossier de Pages de données
 *
 * Purpose:
 * --------
 * Regroupe plusieurs pages de données dans une sorte de dossier
 * en mémoire.
 *
 * Suggest:
 * --------
 * Pour ‚viter la redondance de ptrs sur le DATAGROUP, on pourait faire
 * en sorte que le ROOT pointe sur le DATAGROUP (son "pŠre") et on
 * ferait la diff‚rence datadir/datagroup grâce au fait que le pŠre
 * du DATAGROUp serait NULL (cr‚er une UNION datadir/datagroup/generic 
 *
 * 15.07.94: Ajout de ptrs sur DATADIR parent et DATAGROUP
 * 07.08.94: fplanque: remplace le int state par un DATASTATE
 */
typedef
	struct	datadir
	{	
		/*
		 * Le ptr sur datagroup fut enlev‚
		 * puis remis le 15.07.94
		 */ 
		struct datadir 	*	pDataDir_parent;	/* Directory parent */
		struct datagroup 	*	pDataGroup;			/* Groupe de donn‚es */

		ICONBLK	*	iconblks;			/* Pointe sur le tableau d'iconblk */

		unsigned		nb_elts;				/* Nombre d'‚l‚ments DATAPAGE */
		DATAPAGE	*	data_start;			/* Pointe sur premiŠre page */
		DATAPAGE	*	data_end;			/* Pointe sur derniŠre page */

		DIRSPEC	*	dir_spec;			/* Sp‚cifications compl‚mentaires */

		/* Ces variables ont ‚t‚ transf‚r‚es depuis le datagroup dans le datadir: */
		/* en plusieurs ‚tapes jusqu'au 4 Mai 93 */
		DATASTATE	DataState;			/* Status. Note: Le bit OPEN n'est pas utilis‚ puisk'on a carr‚ment un compteur de fens ouvertes */
		int			nb_dirs;				/* Nb de fenetres DIRs ouvertes sur ces donn‚es */
		int			nb_edits;			/* Nb de donn‚es ouvertes en ‚dition */
	}
	DATADIR;


/*
 * DATAGROUP: Unit‚ de donn‚es contenant tous les dossiers de ce type
 *                                                                   
 * Purpose:
 * --------
 * Tous les dossiers contenant un certains types de données sont
 * reli‚es … un ROOT.
 * La structure DATAGROUP donne un point d'accŠs … ce ROOT.  
 * Le datagroup correspond g‚n‚ralement … un fichier sur disque.
 */
typedef
	struct	datagroup
	{
		int			icon_no;				/* Num‚ro de l'ic“ne associ‚e */
		DATATYPE		DataType;			/* Type, ex: DTYP_ARBO */
		char			data_device[5];	/* Nom de l'unit‚ de stockage virtuelle */
		DATADIR		*root_dir;			/* Ptr sur Directory ppal */
		char			filename[13];		/* Nom du fichier charg‚ */
		char			*filepath;			/* Ptr sur R‚pertoire de ce fichier */
	}
	DATAGROUP;
                           
                           
/*
 * FTA: File Transfer Area (Woaw Genial!) 
 *
 */                           
typedef
	union			
	{
		DATADIR	*	datadir;			/* Ptr sur un dossier */
		DATADIR	**	datadir_ptr;	/* Adr d'un Ptr sur un dossier */
		DATAPAGE	*	pDataPage;		/* Ptr sur DataPage */	
		TEXTINFO	*	textinfo;		/* Ptr sur infos texte */
		int			param;			/* ParamŠtre */
	}
	FTA;
                           
                           
/*
 * Fin du test anti red‚finition:
 */
#endif
