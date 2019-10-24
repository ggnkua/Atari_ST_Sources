/*
 * ArboTree.h
 *
 * Structures repr‚sentant une arborescence complŠte:
 *                                                                 
 * Purpose:
 * --------
 *	Ce fichier contient toutes les structures de donn‚es inter-
 * d‚pendantes utilis‚es pour representer et utiliser une arborescence
 * de serveur complete.
 *
 * Notes:
 * ------
 * Diagramme de d‚pendances:
 * FNCTSPEC          
 *
 * 			OUTPUT_FPAR		INPUT_FPAR   ARBO_LISTPARS  LECTURE_PAR
 * 			        \		  /                   |          |
 * AFNCTSPEC	  {ARBO_FIELDPARS}  ARBO_TEXTPAR  |  {ARBO_SPECIALPAR}
 *          \________    |    ________/_________/__________/
 *       			   \   |   /              
 *                   PAGEARBO             
 *
 *
 */

/*
 * V‚rifie si les pr‚sentes d‚finitions ont d‚ja ‚t‚ faites:
 */
#ifndef _ARBOTREE_H_ 
#define _ARBOTREE_H_


#include "ARBKEYWD.H"


#define	REVERSEVIDEO	0x4000	/* bit 14 */
 
/*
 * FNCTSPEC: No + Nom d'une fonction
 */
typedef
	struct
	{
		int	fnct_no;				/* Fonction */
		char	*fnct_name;			/* Intitul‚ de cette fonction */
	}
	FNCTSPEC;
	
	
/*
 * AFNCTSPEC: No + icone + Nom d'une fonction ARBO
 */
typedef
	struct
	{
		int	fnct_no;				/* Fonction arbo */
		int	icon_no;				/* No de l'icone associ‚e dans le formulaire de choix du type d'une nlle page */
		char	*fnct_name;			/* Intitul‚ de cette fonction */
	}
	AFNCTSPEC;

	
/*
 * ARBO_TEXTPAR: Parametre textuel d'une page arbo
 * 04.12.94: next est maintenant en premier pour compatibilit‚ avec SGLE_LINK_LIST_ELT mais on ne peut utiliser dy`uplicate..ssl qd meme a cause de char*
 */
typedef
	struct		arbo_textpar
	{
		struct arbo_textpar	*	next;		/* Pointeur sur param suivant */
		int							fnct_no;	/* No de la fonction du parm */
		char						*	nom;		/* Pointeur sur le nom du param */
	}
	ARBO_TEXTPAR;

typedef
	struct
	{
		BOOL	b_enabled			:	1;		/* TRUE si valid‚ */
		BOOL	b_MultiParagraph	:	1;		/* TRUE si champ peut contenir plusieurs paragraphe (d‚limot‚s par des CR) */
		BOOL	b_Mandatory			:	1;		/* TRUE si champ obligatoire (NULL value not allowed) */
		BOOL	b_DisplayImm		:	1;		/* Affichage imm‚diat lorsqu'on arrive sur la page */
		BOOL	b_DisplayEnt		:	1;		/* Affichage lorsqu'on entre ds le champ pour la premiŠre fois */
		BOOL	b_DisplayTjs		:	1;		/* Affiche toujours: … chauqe fois qu'on arrive sur le champ */
		BOOL	b_ReverseSupp		:	1;		/* Vid‚o inverse Support */
		BOOL	b_ReverseText		:	1;		/* Vid‚o inverse Texte */
		int	n_Junk				:  8;		/* A remplir avec des 0 */		
	}
	INFIELD_FLAGS;
typedef
	struct
	{
		BOOL	b_enabled			:	1;		/* TRUE si valid‚ */
		BOOL	b_ReverseText		:	1;		/* Vid‚o inverse Texte */
		BOOL	b_ReverseInfo		:	1;		/* Vid‚o inverse Info */
		BOOL	b_Clear				:	1;		/* Il faut effacer le champ de l'‚cran avant d'en changer le contenu */
		UINT	u_GroupId			:	4;		/* 1:Fond  2:Header/Nopage  4:pagecontent */
		int	n_Junk				:  8;		/* A remplir avec des 0 */		
	}
	OUTFIELD_FLAGS;

/*
 * OUTPUT_FPAR: ParamŠtres d'un champ OUTPUT d'une page arbo
 * 24.11.94: fplanque: added FieldFlags
 */
typedef
	struct
	{
		int				fnct_no;			/* No de fonction du champ de sortie */
		ULONG				ul_CodeChamp;	/* Code d'identification du champ */
		OUTFIELD_FLAGS	OutFieldFlags;	/* Diff‚rents flags */	
		int				x;					/* Position du champ */
		int				y;	
		int				w;					/* Largeur du champ */
		int				h;					/* Nbre de lignes du champ */
		int				col_text;		/* Couleur du texte */
		int				col_info;		/* Couleur des infos */
		int				n_Format;		/* Format de pr‚sentation des donn‚es */
		int				reserved;		/* R‚serv‚ pour usage futur */
	}
	OUTPUT_FPAR;


/*
 * INPUT_FPAR: ParamŠtres d'un champ INPUT d'une page arbo
 * 24.11.94: fplanque: added FieldFlags
 */
typedef
	struct
	{
		int				fnct_no;			/* No de fonction du champ de saisie */
		ULONG				ul_CodeChamp;	/* Code d'identification du champ */
		INFIELD_FLAGS	InFieldFlags;	/* Diff‚rents flags */	
		int				x;					/* Position du champ */
		int				y;	
		int				w;					/* Largeur du champ */
		int				h;					/* Nbre de lignes du champ */
		int				asc_fill;		/* Code ASCII CaractŠre de remplissage */
		int				asc_cach;		/* Code ASCII CaractŠre Cache (Pour mot de passe...) */
		int				col_fill;		/* Couleur du "fill" */
		int				col_text;		/* Couleur du texte tap‚ */
		int				n_Filter;		/* Filtre de saisie */
		ULONG				l_MaxNbLines;	/* Nombre de lignes maximum */
		int				reserved;		/* R‚serv‚ pour usage futur */
		char			*	psz_DefText;	/* Texte par d‚faut */
	}
	INPUT_FPAR;

/*
 * ARBO_FIELDPARS: ParamŠtres d'un champ quelconque d'une page arbo
 */
typedef
	struct		field_params
	{
		struct field_params	*next;		/* Ptr sur paramŠtres du champ suivant */
		union
		{
			OUTPUT_FPAR				output;		/* Champ de sortie */
			INPUT_FPAR				input;		/* Champ de saisie */
			int						fnct_no;		/* No de fonction */
			char						params[];	/* G‚n‚rique */
		}							data;
	}
	ARBO_FIELDPARS;      


/*
 * ARBO_LISTPARS: ParamŠtres d'affichage de la liste
 */
typedef
	struct
	{
		int	Reserved1;
		int	nb_Lines;		/* Nbre de lignes dans la liste */
		int	nb_Cols;			/* Nbre de colonnes dans la liste */
		int	n_InterLine;	/* Espace entre 2 lignes cons‚cutives */
		int	n_InterCol;		/* Espace entre 2 colonnes cons‚cutives */
		int	Reserved2;
		int	Reserved3;
	}ARBO_LISTPARS;


/*
 * LECTURE_PAR: ParamŠtres sp‚ciaux d'une page arbo LECTURE
 */
typedef
	struct
	{
		int	n_Annule_Efface;		/* !=0 si un appui sur annulation provoque un effacement de message */	
	}
	LECTURE_PAR;      


/*
 * FILESEL_PAR: ParamŠtres sp‚ciaux d'une page arbo FILESEL
 */
typedef
	struct
	{
		int		n_flags;					/* flags d'inclusion de diff‚rents types de fichiers */
		char	*	pMsz_RootPath;			/* Racine de s‚lection */	
	}
	FILESEL_PAR;      

	
/*
 * ARBO_SPECIALPAR: ParamŠtres speciaux d'une page arbo
 */
typedef
	union
	{
		char			*	data;			/* Contenu G‚n‚rique, pour sauvegarde */
		LECTURE_PAR	*	lecture;		/* ParamŠtres pour page lecture */
		FILESEL_PAR	*	filesel;		/* ParamŠtres pour page filesel */
	}
	ARBO_SPECIALPAR;      


	
/*
 * PAGEARBO: Tous les paramètres d'UNE PAGE ARBO
 *
 * Notes:
 * ------
 * Les variables en retrait sont celles qui ne sont pas sauvées
 * sur disque. Elles sont l… pour augmenter la vitesse de traitement
 * par le programme.
 *
 * 29.03.95: les liens arbo, deviennent evenements
 */
typedef
	struct
	{
		int					fnct_no;				/* Fonction de la page */
			char					*chemin;			/* ??? Chemin complet */
			AFNCTSPEC			*fnct_spec;		/* Sp‚cification sur la fonction arbo */
			
		int					map_pos_x;			/* Coordonn‚es dans le tableau repr‚sentatif */
		int					map_pos_y;

		ARBO_TEXTPAR	*	pages_ecran;		/* Pointeur sur la 1Šre page ‚cran */

		ARBO_TEXTPAR	*	databases;			/* Bases de donn‚es concern‚es */

		ARBO_SPECIALPAR	special_par;		/* Ptr sur parametres speciaux */

		ARBO_FIELDPARS	*	output_fields;		/* Ptr sur 1er champ de sortie */	
		ARBO_LISTPARS	*	pArboListPars;		/* Ptr sur paramŠtres de liste */

		ARBO_FIELDPARS	*	input_fields;		/* Ptr sur 1er champ de saisie */

		KEYWORD_LIST	*	p_MotsClefs;		/* Ptr sur liste de Mots clefs */

		KEYWORD_LIST	*	p_Events;			/* Ptr sur liste d'Evenments */
	}
	PAGEARBO;  
	

/*
 * Fin du test anti red‚finition:
 */
#endif
