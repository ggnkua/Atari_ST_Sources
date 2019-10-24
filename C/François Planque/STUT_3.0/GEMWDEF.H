/* 
 * Gem_Windows_Defs.h
 *
 * Definitions proprietaires pour la gestion des fenetres GEM
 * Structures gerant les fenetres AES ainsi que leur contenu.
 *
 * Notes:
 * ------
 * Diagramme de dépendances:
 *				
 * dfstruct.h  dfstruct.h  dfstruct.h
 *     |          |           |
 *     |      DATAGROUP       |
 *     |       DATADIR        |
 *  TEXTLINE   DATAPAGE   TEXT_DRAWPAR
 *     |        |   |         |
 *   {WORK_CONTENT}  \    {WORK_DRAW}   MENU_OPTIONS   WINFLAGS         
 *               \    \___    |    ___/__________________/
 *                 \_____ \   |   /
 *			  					   WIPARAMS     
 *
 *
 * History:
 * --------
 * Created by fplanque
 */

/*
 * V‚rifie si les pr‚sentes d‚finitions ont d‚ja ‚t‚ faites:
 */
#ifndef _GEMWDEF_H_ 
#define _GEMWDEF_H_

/*
 * Headers:
 */   
 
 #include <vdi.h>
                            
 #include "DFSTRUCT.H"			/* Structures de données affichées */
														/* dans les fenetres */                              
	
/*
 * Window definitions: 
 */
#define	COMPLETE			NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE
                                 /* Fenêtre avec tous les elements */
#define	OUTLINE_INWIN	2;			/* Taille d'un cadre OUTLINE lorsque */
											/* le formulaire en question est dans */
											/* une fenêtre (Range: 0-3) */

/*
 * Internal window-class definitions:
 */
enum
	{
		CLASS_EMPTY,		/* Vide */
		CLASS_DESK,			/* Le bureau */
		CLASS_DIR,			/* Un directory tout simple */
		CLASS_TEXT,			/* Un texte */
		CLASS_DATAPAGE,	/* Une page de donn‚es, plus de pr‚cisions dans le TYPE */
		CLASS_TREE			/* Arbre d'objets */
	};		


/* 
 * Internal window-type definitions:
 */
enum
	{
		TYP_DESK,		/* Le bureau! */
		TYP_EMPTY,		/* Rien (Fenˆtre vide) */
		TYP_ARBO,		/* Configuration d'une page arbo */
		TYP_DIR,			/* Directory */
		TYP_TEXT,		/* Texte */
		TYP_DEBUG,		/* Texte de debugging */
		TYP_TRACK,		/* Tracking du serveur */
		TYP_ERRORS,		/* Erreurs du compilateur */
		TYP_PI3,			/* Image Degas PI3 */
		TYP_TREE			/* Arbre d'objets */
	};           
             
             
/*
 * WORK_CONTENT: Ptr sur les données affichées dans une fenetre   
 *
 * Suggest:
 * --------
 * N'y-a-t'il pas double emploi avec les pointeurs directs dans
 * la structure WIPARAMS
 */
typedef
	union
	{
		TEXTINFO		*textInfo;			/* Texte */
		DATAGROUP	*datagroup;			/* Bloc de donn‚es */
		DATADIR		*datadir;			/* Repr‚sentation d'un bloc de donn‚es */
		DATAPAGE		*datapage;			/* Page de donn‚es */
		void			*x;					/* Chose inconnue... */
	}
	WORK_CONTENT;

                                                             
         

/*
 * WORK_DRAW: Ptr vers infos permettant d'afficher le contenu de la fenetre
 *
 * Purpose:
 * --------  
 * Cette union donne un pointeur vers une structure contenant les
 * informations nécessaires à l'affichage des données contenues dans
 * la fenetre.
 */
typedef
	union
	{
		MFDB				*	psrcMFDB;		/* block source */
		OBJECT			*	tree;				/* Arbre d'objets */
		TEXT_DRAWPAR	*	pTextDrawPar;	/* Infos sur un texte */
		void				*	x;					/* Chose inconnue... */
	}
	WORK_DRAW;
 
 
/*
 * MENU_OPTIONS: Options du menu a valider selon le contenu de la fenetre
 */
typedef
	struct
	{
		BOOL		save			:1;			/* Peut on sauver le contenu? */
		BOOL		saveas		:1;			/* Peut on sauver le contenu? */
		BOOL		savedisk		:1;			/* Peut on sauver le contenu? */
		BOOL		newlink		:1;			/* Nouveau lien */
		BOOL		newpage		:1;			/* Nouvelle page */
		BOOL		newrub		:1;			/* Nouvelle rubrique */
		BOOL		newtext		:1;			/* Nouveau texte */
		BOOL		compile		:1;			/* On peut compiler */
		UINT		affichage	:2;			/* Params d'affichage */
	}
	MENU_OPTIONS;


/*
 * Flags s'appliquant … une fenˆtre:
 */
typedef
	struct
	{
		int	b_modified	:	1;		/* Le contenu de la fenˆtre a ‚t‚ modifi‚ */	
	} 
	WINFLAGS;


enum { PARAFF_NONE, PARAFF_TEXT };

         
/*
 * WIPARAMS: ParamŠtres concernant une fenˆtre (ouverte ou fermee)
 * 
 * Purpose:
 * --------
 * Chaque element de la liste chain‚e fournit des infos sur
 * une fenetre:                
 *		- Handles, Titre, etc...
 *		- Contenu
 *		- M‚thode d'affichage du contenu
 *		- Dimension totale & partie visible
 *		- Objet s‚lectionn‚
 *		- Options de menu valides pour ce contenu.
 */                                                          
typedef
	struct	wi_params
	{
		/*
		 * Fenˆtre suivante: 
		 */
		struct wi_params	*	next;		/* Prochaine fenˆtre */

		/*
		 * Contenu de la fenˆtre: 
		 */
		int				class;				/* Classe des donn‚es contenues ds la fenˆtre */
		DATAGROUP	*	datagroup;			/* Datagroup concern‚ */
		DATADIR		*	datadir;				/* Dossier concern‚ */
		DATAPAGE		*	datapage;			/* Page concern‚e */
		WORK_CONTENT	content_ptr;		/* Pointeur sur le contenu! */

		/*
		 * Informations sur l'affichage: 
		 * En g‚n‚ral, c'est difficile … mettre en place! 
		 */
		int				type;					/* Type des donn‚es contenues ds la fenŠtre*/
		WORK_DRAW		draw_ptr;			/* Pointeur sur les infos pour le dessin */
			
		/*
		 * Informations sur la fen en g‚n‚ral:
		 */
		int				handle;				/* Handle de la fenˆtre concern‚e */
		char			*	name_adr;			/* Titre de la fenˆtre */
		char			*	info_adr;			/* Lignes d'infos */
		int				wi_ckind;			/* El‚m‚nts actifs de la fenˆtre */
		int				fulled;				/* 1: Plein ‚cran  0: normal */	
		int				curr_x, curr_y;	/* Coord avant fermeture */
		int				curr_w, curr_h;	/* Taille avant fermeture */
		int				maxsize_w, maxsize_h;	/* Taille maximale, bordure comprise */
		int				h_step, v_step;	/* Taille des sauts lorsqu'on clique sur les flˆches */
		int				more;					/* Info suppl‚mentaire */
		
		/*
		 * Infos sur la taille du contenu et la portion visible: 
		 */
		unsigned int	work_x;				/* Position X de la zone de travail */
		unsigned int	work_y;				/* Position Y de la zone de travail */
		unsigned	long	seen_x;				/* Coordonn‚es (offset) de la fen */
		unsigned	long	seen_y;				/* ouverte sur le document */
		unsigned int	seen_w;				/* Largeur visible */
		unsigned int	seen_h;				/* Hauteur visible */
		unsigned	long	total_w;				/* largeur totale */
		unsigned long	total_h;				/* hauteur totale */
	
		/*
		 * S‚lection dans la fenˆtre= 
		 */
		int				selected_icon;		/* No Objet selectionne */

		/*
		 * Validation des options du menu 
		 */
		MENU_OPTIONS	menu_options;

		/*
		 * Divers
		 * ex: le contenu a t'il ‚t‚ modifi‚:
		 */	
		WINFLAGS			WinFlags;
	} 
	WIPARAMS;
              
              
/*
 * Fin du test anti red‚finition:
 */
#endif
                                               