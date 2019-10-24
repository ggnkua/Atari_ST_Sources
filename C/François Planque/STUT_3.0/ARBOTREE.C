/*
 * treeedit.c
 *
 * Purpose:
 * --------
 * Fonctions permettant l'edition de l'arbre "arborescence":
 *
 * History:
 * --------
 * 18.05.94: Created by flanque, extracted from arboedit.c
 */

	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"ARBOTREE.C v1.02 - 03.95"
          
/*
 * System headers:
 */
	#include	<stdio.h>
	#include <stdlib.h>					/* Malloc etc... */
	#include	<string.h>					/* Memcpy etc... */
	#include	<aes.h>						/* header AES */  
	
/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"
	#include "S_MALLOC.H"
	#include "STUT_ONE.RSC\STUT_3.H"					/* noms des objets ds le ressource */
	#include "AESDEF.H"
	#include "EXFRM_PU.H"
	#include "ATREE_PU.H"
	#include "ARBPG_PU.H"
	#include "ARPAR_PU.H"
	#include "ARBKEYPU.H"
	#include "DTDIR_PU.H"
	#include "DATPG_PU.H"
	#include	"DEBUG_PU.H"	
	#include	"DESK_PU.H"	
	#include	"MAIN_PU.H"	
	#include "OBJCT_PU.H"
	#include "RTERR_PU.H"
	#include "VDI_PU.H"
	#include "WIN_PU.H"					/* Gestion des fenˆtres */
	#include "WINDR_PU.H"	

/* 
 * Headers ressource: 
 */
	#include	"ARBO.RCH"				/* Ressources d'‚dition arbo */
	#include	"ARBO_MED.RCH"			/* Ressources d'‚dition arbo */


/*
 * ------------------------ PROTOTYPES -------------------------
 */

/*
 * PRIVate internal prototypes:
 */
	static	void	build_arbodir( DATADIR * *curr_datadir, OBJECT * *tree );
	static	void	build_arbotree( DATADIR *curr_datadir, OBJECT * *tree );
	static	OBJECT	*add_arbo_elt( OBJECT	*tree, OBJECT *srce_object, unsigned *nb_objs );

	static	int	drag_arboicon( unsigned object_id, int ob_x, int ob_y, 
										int start_x, int start_y, 
										int			n_GridSrceX,	/* In: Coordonn‚es de d‚part ds la grille */
										int			n_GridSrceY,
										int *drop_x, int *drop_y,
										int 			take_control );	/* In: faut il prendre le controle de l'‚cran ou pas? */
	static	void	control_links( unsigned object_id,
											int 		pos_x, 		/* In: Position propos‚e */
											int 		pos_y, 
											int		n_StartX,	/* In: Position initiale */
											int		n_StartY,
											int *line_style );
	static	int	iblk_owner( OBJECT *tree, int obj );
	
	static	DATAPAGE	*find_arbo_by_xy( DATADIR *datadir, int pos_x, int pos_y );
	static	int	find_inlinkXY( 				/* Out: !=0 si non trouv‚ (erreur) */		
							DATADIR	* pDataDir,		/* In:  Datadir dans lequel on cherche */
							int		* pn_posX,		/* Out: Position X en cases */
							int		* pn_posY );	/* Out: Position Y en cases */

	static	void	link_arbo_to_parent( DATADIR *datadir, int pos_x, int pos_y );
	static	unsigned	find_ascent( 					/* Out: Contenu de la cellule parent */
					DATADIR *	datadir, 	/* In:  Dossier dans lequel on cherche */
					int 			pos_x, 		/* In:  Position de l'enfant */
					int 			pos_y, 
					int *			ascent_x, 	/* Out: Position du parent (meme si case vide) */
					int *			ascent_y );
	static	void	find_children( DATADIR *datadir, int pos_x, int pos_y );
	static	void	walk_arbotree( int pos_x, int pos_y );

	static	int arboTree_DeleteElt( 
							DATADIR	*	datadir,
							int			stcl_x,				/* In: Coordonn‚es dans le tableau */
							int			stcl_y,
							WIPARAMS *	wi_params_adr );

/*
 * ------------------------ VARIABLES -------------------------
 */

/*
 * External variables: 
 */
	/* 
	 * Bureau: 
	 */
	extern	OBJECT	*	G_desktop_adr;		/* Ptr sur arbre bureau */
	extern	WIPARAMS	*	G_desk_params_adr;	/* ParamŠtres de la "fenˆtre bureau" */
	/* 
	 * G‚n‚ral: 
	 */
	extern	WIPARAMS	*	G_wi_list_adr;		/* Adresse de l'arbre de paramŠtres */
	extern	int			G_x_mini, G_y_mini;	/* Coord sup gauche de l'‚cran */
	extern	int			G_w_maxi, G_h_maxi;	/* Taille de l'‚cran de travail */
	extern	int			G_top_wi_handle;		/* Fenˆtre g‚r‚e par le programme
															la plus en haut, mais pouvant ˆtre
															surpass‚e par un accessoire */
	extern	char		*	G_empty_string;		/* Chaine vide */
	extern	char		*	G_tmp_buffer;			/* Tampon */
	/* 
	 * VDI: 
	 */
	extern	int			G_ws_handle;			/* handle virtual workstation VDI */
	extern	int   		G_pxyarray[18];		/* Liste de coord X,Y pour le VDI */
	extern	int			G_pxyarray2[10];	
	extern	int			G_cliparray[ 4 ];
	extern	USERBLK		G_bcroix_ublk;			/* Pour bouton-croix */
	/* 
	 * Groupes de donn‚es: 
	 */
	extern	DATAGROUP	*G_datagroups;		/* Pointeur sur tableau de G_datagroups */


/*
 * Public variables: 
 */
	/* 
	 * Dimensions des ic“nes: 
	 */
 	int		G_arbocell_w;					/* Larg d'une ic“ne arbo */
	int		G_arbocell_h;					/* Hauteur... */


/*
 * Internal variables: 
 */
	/* 
	 * Arbres: 
	 */
	static	OBJECT	*M_newlink_adr;			/* Nouveaux liens */
	static	OBJECT	*M_newpagearbo_adr;		/* Nouvelles pages arbo */
	/* 
	 * Objets pour arborescence: 
	 */
	static	OBJECT	*M_arbotree;				/* Arbre arborescence */
	static	USERBLK	M_grid_ublk = {	draw_grid, 	/* Adr routine */
													0L };			/* Ob SPEC */	
	static 	int		M_arboelt_w;					/* Larg d'une ic“ne arbo */
	static	int		M_arboelt_h;					/* Hauteur... */
	static	int		M_fantome_lien[10];			/* Infos pour dessin du fant“me */
	/* 
	 * Tableau des IDS associ‚s aux liens: 
	 */
	static	int		M_link_id[]=
	{
		IDLINK_FETS,		/* Lien */
		IDLINK_FETWS,		/* Lien */
		IDLINK_FNTWSE,		/* Lien */
		IDLINK_FWTSE,		/* Lien */
		IDLINK_FWTS,		/* Lien */
		IDLINK_FNTWS,		/* Lien */
		IDLINK_FNTS,		/* Lien */
		IDLINK_FNTSE,		/* Lien */
		IDLINK_FNTW,		/* Lien */
		IDLINK_FETW,		/* Lien */
		IDLINK_FNTWE,		/* Lien */
		IDLINK_FWTE,		/* Lien */
		IDLINK_FNTE 		/* Lien */
	};
	/* 
	 * Fonctions arbo: 
	 */
	static	AFNCTSPEC		M_fnctarbo[]=
	{
		FA_MENU,				ARBOMENU,	"Menu, Ecran simple",
		FA_ECRI_MSG,		AECRIMSG,	"Ecriture d'un message",
		FA_LECT_MSG,		ALECTMSG,	"Lecture de message(s)",
		FA_DISP_TEXT,		DISPTEXT,	"Affichage d'un texte",
		FA_ID,				ARBOID,		"Identification User",
		FA_NEW_ACCOUNT,	ARBONACC,	"Nouveau Compte User",
		FA_LIST,				ARBOLIST,	"Liste de messages",
		FA_DIRECTORY,		ARBODIR, 	"Annuaire des comptes",
		FA_FILESEL,			ARBOFSEL,	"S‚lection fichier",
		FA_DOWNLOAD,		ARBODWLD,	"Download"
	};
	/*
	 * Liens IN par d‚faut:
	 */
#include "FN_INLNK.C"
	/* 
	 * Walking trees: 
	 */
	static DATADIR	 *	M_walker_datadir;
	static unsigned	M_walker_mapwidth;
	static unsigned *	M_walker_map;

/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * init_tree(-)
 *
 * Purpose:
 * --------
 * Init de la gestion d'arborescence
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 18.05.94: divis‚
 * 02.02.95: gŠre moyenne r‚solution
 * 13.02.95: d‚termine taille des ic“nes selon taille BITBLK d'un lien NORTH to SOUTH
 */
void	init_tree( void )
{
	TRACE0( "Initializing " THIS_FILE );

	/*
	 * Trouve adresses des arbres d'objets 
	 * (diff‚rentes selon qu'on est en moyenne ou haute r‚solution)
	 */
	#if ACCEPT_SMALLFONTS
		if( G_cell_size_prop == 1 )
		{	/*
			 * Moyenne r‚solution
			 */
			if( rsrc_gaddr( R_TREE, NEWLMED,  &M_newlink_adr ) == 0)
				erreur_rsrc();
			if( rsrc_gaddr( R_TREE, NEWPAMED, &M_newpagearbo_adr ) == 0)
				erreur_rsrc();
			M_arbotree = &rs_object_med[ 0 ];
		}
		else
		{	/*
			 * haute
			 */
			if( rsrc_gaddr( R_TREE, NEWLINK,  &M_newlink_adr ) == 0)
				erreur_rsrc();
			if( rsrc_gaddr( R_TREE, NEWPAGEA, &M_newpagearbo_adr ) == 0)
				erreur_rsrc();
			M_arbotree = &rs_object_hi[ 0 ];
		}
	#else
		/*
		 * On peut consid‚rer qu'on est en haute:
		 */
		if( rsrc_gaddr( R_TREE, NEWLINK,  &M_newlink_adr ) == 0)
			erreur_rsrc();
		if( rsrc_gaddr( R_TREE, NEWPAGEA, &M_newpagearbo_adr ) == 0)
			erreur_rsrc();
		M_arbotree = &rs_object_hi[ 0 ];
	#endif		

	rsrc_color( M_newlink_adr );			/* Fixe couleurs */
	rsrc_color( M_newpagearbo_adr );		/* Fixe couleurs */


	/*
	 * Dimensions des ic“nes/liens arbo: 
	 */
	M_arboelt_w = M_newlink_adr[ LKFNTS ] .ob_spec.bitblk -> bi_wb *8 -1;
	M_arboelt_h = M_newlink_adr[ LKFNTS ] .ob_spec.bitblk -> bi_hl;
	TRACE2( "  Size of arboelt= %d %d", M_arboelt_w, M_arboelt_h );
	
	/*
	 * Dimension de l'emplacement: 
	 */
	G_arbocell_w = M_arboelt_w +1;		/* 47 -> 48 */
	G_arbocell_h = M_arboelt_h +1;		/* 47 -> 48 */
	TRACE2( "  Size of arbocell= %d %d", G_arbocell_w, G_arbocell_h );

	/* 
	 * Fant“me d'une ic“ne-LIEN: 
	 */
	M_fantome_lien[ 0 ] = 0;
	M_fantome_lien[ 1 ] = 0;
	
	M_fantome_lien[ 2 ] = M_arboelt_w-1;
	M_fantome_lien[ 3 ] = 0;
	
	M_fantome_lien[ 4 ] = M_arboelt_w-1;
	M_fantome_lien[ 5 ] = M_arboelt_h-1;
	
	M_fantome_lien[ 6 ] = 0;
	M_fantome_lien[ 7 ] = M_arboelt_h-1;
	
	M_fantome_lien[ 8 ] = 0;
	M_fantome_lien[ 9 ] = 1;				/* Pour ne pas se mordre la queue! */ 
	
	/*
	 * Param USERDEF: 
	 */
	M_grid_ublk .ub_parm = M_arbotree -> ob_spec.index;	/* Copie OB_SPEC */
	M_arbotree -> ob_spec.userblk = &M_grid_ublk;			/* Fixe adr USERBLK */

	/*
	 * Cr‚e modŠles de liens-IN:
	 */
	M_in_arbolinks = CmdList_Create( M_inlinks );

}



/*
 * open_arbotree(-)
 *
 * Purpose:
 * --------
 * Ouverture d'une fenˆtre sur un dossier de l'arborescence
 *
 * Algorythm:
 * ----------  
 *
 * Notes:
 * ------
 * ATTENTION: la gestion des dossiers ARBO et des normaux ne se fait
 * Pas de la mˆme maniŠre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 17.05.94: Centrage du lien in au milieu de la fenˆtre lors de son ouverture
 * 08.08.94: fplanque: modif de la signalisation de MODIF sur le directory
 * 21.09.94: modif gestion du nbre de dirs simultan‚s ouverts
 */
void open_arbotree( 
			WIPARAMS *wi_params_adr )
{
	OBJECT		*tree;			/* Arbre d'objets */
	DATAGROUP	*curr_datagr  = wi_params_adr -> datagroup;	/* Datagroup concern‚ */
	DATADIR		*curr_datadir = wi_params_adr -> datadir;
	int			n_posX, n_posY;

	/*
	 * Teste si le directory est vierge ou non: 
	 */
	if( curr_datadir != NULL )
	{	/********************************************/
		/* Si on re-ouvre un dossier existant d‚j…: */
		/********************************************/

		/*
		 * Contr“le si une fenˆtre est d‚j… ouverte sur le MEME dossier: 
		 */
		if ( curr_datadir -> nb_dirs > 0 )
		{	/*
		 	 * ----------------------------------------------------------
			 * Si il y a d‚j… une/des fenˆtres ouvertes sur ce dossier: 
			 * ----------------------------------------------------------
			 *
			 * On va r‚cup‚rer le contenu d'une fenˆtre: (avant on dupliquait!) 
			 *
			 * Etant donn‚ que les wi_params de la nlle fenˆtre ne sont pas   
			 *	encore pr‚sentes dans la liste, on peut demander une recherche
			 *	d'une AUTRE fenˆtre pointant sur le mˆme dataDIR:
			 */
			WIPARAMS *modele_adr = find_datawindow2( (unsigned long) curr_datadir, G_wi_list_adr );
			
			/*
			 * R‚cupŠre Adresse de l'arbre d'objets de la premiŠre fenetre: 
			 */
			tree = modele_adr -> draw_ptr.tree;
		}
		else
		{	/*--------------------------------------------------*/
			/* Si pas encore de fenˆtre ouverte sur ce dossier: */
			/*--------------------------------------------------*/
			/*
			 * On cr‚e juste un arbre d'objets selon les indications du DATDIR: 
			 */
			build_arbotree( curr_datadir, &tree );
		}
	}
	else
	{	/**********************************/
		/* Si on ouvre un dossier vierge: */
		/**********************************/	
		/*
		 * On cr‚e un dossier de contenu vierge: 
		 */

		/*
		 * Cr‚e les infos datadir 
		 * ainsi que l'arbre d'objets (simpliste) associ‚: 
		 */
		build_arbodir( &curr_datadir, &tree );

		/*
		 * Le dossier n'est plus vierge (il y a un elt "IN") 
		 */
		/* OLD: set_datastate( curr_datagr, 1 );	/* Plein, Non modifi‚ */
		/*
		 * On a fait une modif dans le dossier (auparavant vierge)
		 */
		dataDir_setSavState( curr_datadir, SSTATE_MODIFIED, TRUE );

		/*
		 * Lie ce dossier au datagroup: 
		 */
		curr_datagr -> root_dir			= curr_datadir;	/* Dir ppal */
		
	}


	/* 
	 * Param‚trage de la fenˆtre: 
	 */
	wi_params_adr -> content_ptr.datadir= curr_datadir;/* Contenu */
										/* Ce setting est trŠs important
										 *	pour la recherche de la fenˆtre
										 *	par find_datawindow lorsque l'on
										 *	veut par ex dupliquer son contenu 
										 */	
	wi_params_adr -> datadir = curr_datadir;	/* Ptr sur datadir */
	wi_params_adr -> draw_ptr.tree 	= tree;				/* Pointeur sur arbre d'objets */
	wi_params_adr -> total_w			= tree[0].ob_width + WA_OUTLINE;
	wi_params_adr -> total_h			= tree[0].ob_height + WA_OUTLINE;
	wi_params_adr -> h_step				= G_arbocell_w;	/* Saut par emplacement */
	wi_params_adr -> v_step 			= G_arbocell_h;	/* Saut par emplacement */

	/*
	 * Centrage de la fenˆtre ouverte sur le lien "IN":
	 */
	if( find_inlinkXY( curr_datadir, &n_posX, &n_posY ) == SUCCESS0 )
	{	/*
		 * Si on a trouv‚ le Lien IN:
		 *
		 * Centrage en X et haut (mais place pour bordure) de fenˆtre en Y:
		 */
		int	n_Xoffset = n_posX * G_arbocell_w + G_arbocell_w/2 - (wi_params_adr -> seen_w)/2 + AICON_OFFX;
		int	n_Yoffset = n_posY * G_arbocell_h;
		
		if( n_Xoffset < 0 )
		{	/* 
			 * Si on d‚passe le bord gauche 
			 */
			n_Xoffset = 0;
		}
		else if( n_Xoffset + wi_params_adr -> seen_w > wi_params_adr -> total_w )
		{	/* 
			 * Si on d‚passe le bord droit 
			 */
			n_Xoffset = (int) (wi_params_adr -> total_w - wi_params_adr -> seen_w);
		}

		if( n_Yoffset < 0 )
		{	/* 
			 * Si on d‚passe le bord sup‚rieur
			 */
			n_Yoffset = 0;
		}
		else if( n_Yoffset + wi_params_adr -> seen_h > wi_params_adr -> total_h )
		{	/* 
			 * Si on d‚passe le bord inf‚rieur:
			 */
			n_Yoffset = (int) (wi_params_adr -> total_h - wi_params_adr -> seen_h);
		}

		wi_params_adr -> seen_x	= n_Xoffset;		/* Offset X */
		wi_params_adr -> seen_y	= n_Yoffset;		/* Offset Y */
	}

	/* 
	 * Options menu: 
	 */
	wi_params_adr -> menu_options.newlink = TRUE_1;	/* On peut cr‚er des nouveaux liens */
	wi_params_adr -> menu_options.newpage = TRUE_1;	/* On peut cr‚er des nouvelles pages */

	/* 
	 * 1 fenˆtre semblable de plus: 
	 */
	curr_datadir -> nb_dirs ++;
	/* printf( "Ouverture: nb_dirs=%d\n", curr_datadir -> nb_dirs ); */

}


/*
 * build_arbodir(-)
 *
 * Purpose:
 * --------
 * Cr‚ation du contenu d'un dossier dans l'arborescence
 *
 * Suggest:
 * ------
 * passer les trucs trŠs sp‚cifiques ds DIRSPEC
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 15.07.94: fplanque: appelle maintenant create_EmptyDataDir()
 * 21.09.94: ne considŠre plus qu'il y a un dossier ouvert par d‚faut!
 * 14.05.95: Corrig‚ bug de cr‚ation des Liens-In
 */
void	build_arbodir( 
			DATADIR * * curr_datadir, 
			OBJECT  * * tree )
{
	/*
	 * Variables: 
	 */
	ICONBLK		*iblk_array;	/* Tableau d'iconblocks */
	size_t		map_size = ( ARBOPAGES_W * ARBOPAGES_H + 2 )* sizeof( unsigned );
											/* +2 pour [largeur] et [hauteur] */
	unsigned		*arbo_map;		/* Tableau repr‚sentatif */

	DIRSPEC		*dir_spec;		/* Sp‚cifications compl‚mentaires */


	/* 
	 * Cr‚e une zone pour et avec le nouvel arbre d'objets: 
	 */
	*tree = (OBJECT *) MALLOC( sizeof( OBJECT ) * (DEF_NBOBJ_TREE+1) ); /* +1 pour la boŒte pŠre */
	memcpy( *tree, M_arbotree, 2*sizeof( OBJECT ) );	/* Copie pŠre + "IN" */

	/* 
	 * Cr‚e une zone pour les ICONBLKs: 
	 */
	iblk_array = (ICONBLK *) MALLOC( sizeof( ICONBLK ) * DEF_NBIBL_TREE );

	/* 
	 * Cr‚e un tableau repr‚sentant l'arbre: 
	 */
	arbo_map = ( unsigned * ) MALLOC( map_size );
	memset( arbo_map, 0, map_size );		/* Initialise tout … z‚ro : cases vides */
	arbo_map[ 0 ]= ARBOPAGES_W;				/* Largeur */
	arbo_map[ 1 ]= ARBOPAGES_H;				/* Hauteur */		
	arbo_map[ 2 + ARBOIN_POSY*ARBOPAGES_W + ARBOIN_POSX ]= IDELT_IN;	 				/* Signale l'‚l‚ment "IN" avec une sortie South */

	/* 
	 * Cr‚e une zone d'infos DATADIR: 
	 */
	*curr_datadir = create_EmptyDataDir( find_datagroup_byType( DTYP_ARBO), NULL );

	(*curr_datadir) -> iconblks 	= iblk_array;

	/* 
	 * Fixe paramŠtres sp‚ciaux aux DATADIRs ARBO
	 */
	dir_spec = (DIRSPEC *) MALLOC ( sizeof( DIRSPEC ) );
	/*
	 * BUG: different types:
	 */
	dir_spec -> liens_in 	= dup_KeyWordList( M_in_arbolinks );
	dir_spec -> max_objs		= DEF_NBOBJ_TREE;
	dir_spec -> nb_objs		= 1;	/* Pour l'instant: 1 elt: "IN" */
	dir_spec -> max_iblks	= DEF_NBIBL_TREE;
	dir_spec -> nb_iblks		= 0;
	dir_spec -> dir_map 		= arbo_map;
	(*curr_datadir) -> dir_spec = dir_spec;	/* Sp‚cifications compl‚mentaires */

}


/*
 * efface_arbodir(-)
 *
 * Purpose:
 * --------
 * Efface un dossier de l'arborescence
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	efface_arbodir( DATADIR *datadir )
{
	/*
	 * Adresse dir_spec? 
	 */
	DIRSPEC	*	dir_spec = datadir -> dir_spec;

	/*
	 * Petit contr“le: il ne doit plus y avoir de pages ds le datadir: 
	 */
	if( datadir -> data_start != NULL )
	{
		signale("On a effac‚ un DIR non vide!!!");
	}
	
	/*
	 * Effacement des SPECS 
	 * Efface liens-in du dossier: 
	 */
	free_KeyWordList( dir_spec -> liens_in );
	/*
	 * Effacement du dir-map: 
	 */
	FREE( dir_spec -> dir_map );
	/*
	 * Efface specs: 
	 */
	FREE( dir_spec );	
	datadir -> dir_spec = NULL;

	/*
	 * Effacement du dossier lui-mˆme: 
	 */
	DataDir_Destruct( datadir );
}
    
    
/*
 * build_arbotree(-)
 *
 * Purpose:
 * --------
 * Cr‚ation de l'arbre d'objets repr‚sentant un dossier dans l'arbo
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 21.09.94: ne touche pas au nb de dirs ouverts simultan‚ment
 */
void	build_arbotree( 
			DATADIR	*	curr_datadir, 
			OBJECT 	**	tree )
{
	DIRSPEC	*	pDirSpec = curr_datadir -> dir_spec;
	ICONBLK	*	iblk_array;	/* Tableau d'iconblocks */
	unsigned	*	arbo_map	= pDirSpec -> dir_map;	/* Tableau repr‚sentatif */
	unsigned		map_width	= arbo_map[ 0 ];			/* Largeur tableau */
	unsigned		map_height	= arbo_map[ 1 ];			/* Hauteur tableau */
	unsigned		map_x, map_y;
	unsigned		object_id;			/* ID de l'objet en cours de cr‚ation */
	unsigned	*	map_ptr;			/* Pointeur sur une case */
	/*
	 * Cr‚ation des objets: 
	 */
	unsigned		nb_objs = 1;		/* Nombre d'objets, par d‚faut: 1: "IN" */
	unsigned		nb_iblks = 0;		/* Nombre d'IBLKS */
	int			offset_x, offset_y;	/* Position des objets quel'on place dans le formulaire */
	int			srce_obj_no;		/* No de l'objet modŠme */
	OBJECT	*	srce_object;		/* ModŠle … recopier */
	OBJECT	*	new_object;		/* Nouvel objet cr‚‚ */
	ICONBLK	*	new_iblk;			/* Nouveau IBLK */

	/*
	 * Calcule le nombre d'objets qu'on va r‚server: 
	 */ 
	pDirSpec -> max_objs = pDirSpec -> nb_objs + DEF_NBOBJ_TREE; /* Nbre d‚j… existant + MARGE */
	/* printf("maxobjs=%d \n", curr_datadir -> max_objs ); */
	/*
	 * Cr‚e une zone pour et avec le nouvel arbre d'objets: 
	 */
	*tree = (OBJECT *) MALLOC( sizeof( OBJECT ) * (pDirSpec -> max_objs +1) ); /* +1 pour la boŒte pŠre */
	memcpy( *tree, M_arbotree, 2*sizeof( OBJECT ) );	/* Copie pŠre + "IN" */
	/*
	 * Adapte la taille du formulaire: 
	 */
	tree[ ROOT ] -> ob_width = map_width * G_arbocell_w +WA_BORDER;
	tree[ ROOT ] -> ob_height = map_height * G_arbocell_h +WA_BORDER;

	/*
	 * Calcule le nombre d'ICONBLOCKS qu'on va r‚server: 
	 */ 
	pDirSpec -> max_iblks = pDirSpec -> nb_iblks + DEF_NBIBL_TREE; /* Nbre d‚j… existant + MARGE */
	/* printf("maxiblk=%d \n", pDirSpec -> max_iblks ); */

	/*
	 * Cr‚e une zone pour les ICONBLKs: 
	 */
	iblk_array = (ICONBLK *) MALLOC( sizeof( ICONBLK ) * pDirSpec -> max_iblks );
	/* printf("IBLKARRAY=%lu\n",iblk_array); */
	/*
	 * Sauve l'adr de cette nlle zone 
	 */	
	curr_datadir -> iconblks 	= iblk_array;
	

	/*
	 * Parcourt le tableau: 
	 */
	map_ptr = &(arbo_map[2]);		/* Pointe sur 1Šre case */
	offset_y = AICON_OFFY;			/* Offset Y des objets dans l'arbre */
	for(	map_y = 0;
			map_y < map_height;
			map_y++, offset_y += G_arbocell_h )
	{
		offset_x = AICON_OFFX;		/* Offset X des objets dans l'arbre */
		for(	map_x = 0;
				map_x < map_width;
				map_x++, offset_x += G_arbocell_w )
		{
			object_id = *(map_ptr++);	/* ID de l'objet se trouvant … cette position */					
			if ( object_id != 0 )
			{	/* Si la case n'est pas vide: */

				if ( object_id & CT_ARBO )
				{	/* S'il s'agit d'une page ARBO: */

					/*
					 * On recherche la page qui se trouve 
					 *	aux coordonn‚es en cours d'investigation: 
					 */
					DATAPAGE	*datapage = find_arbo_by_xy ( curr_datadir, map_x, map_y );

					if( datapage != NULL )	/* Normalement NULL ne devrait jamais arriver */
					{	/*
						 * Si on a trouv‚ la page qui se trouve aux coordonn‚es courantes 
						 */
						PAGEARBO	*pagearbo = datapage -> data.pagearbo;

						/* printf("Trouv‚ page: %lu\n", datapage ); */

						/*
						 * D‚duit adr de l'objet source: 
						 */
						srce_object = &M_newpagearbo_adr[ (pagearbo -> fnct_spec) -> icon_no ];

						/*
						 * Ajoute l'ic“ne PAGE-ARBO dans l'arbre: 
						 */
						new_object = add_arbo_elt( *tree, srce_object, &nb_objs );

						/*
						 * Duplique IBLK 
						 */
						new_iblk = &( iblk_array[ nb_iblks++ ] );	/* Adresse copie (Un IBLK de plus) */
						memcpy( new_iblk, srce_object -> ob_spec.iconblk, sizeof( ICONBLK ) ); /* Copie */
						/*
						 * Lie IBLK … l'objet: 
						 */
						new_object -> ob_spec.iconblk = new_iblk;
						/*
						 * Modifie le nom de la page dans l'ICONBLK: 
						 */
						new_iblk -> ib_ptext = datapage -> nom; /* Fixe ptr sur nom */

					}
					else
					{
						signale("Page pos‚e dans le MAP mais introuvable dans LISTE");
					}
				}
				else
				{	/* S'il s'agit d'un LIEN */
					if ( object_id == IDELT_IN )
					{	/* S'il s'agit du point d'entr‚e: */
						/* Cet elt fait d‚j… partie de l'arbre */
						new_object = &(*tree)[ 1 ];		/* D‚termine son adresse */
					}
					else
					{	/* S'il s'agit d'un lien standard: */
					/* Recherche no de l'image du lien demand‚ */
						srce_obj_no = 0;
						while( M_link_id[ srce_obj_no ] != object_id && srce_obj_no < NB_LINKTYPES )
						{
							srce_obj_no ++;		/* Objet suivant */
						}
					/* Transforme en no d'objet dans l'arbre M_newlink_adr: */
						srce_obj_no += LKFETS;		/* Add no du 1er lien du formulaire */
					/* D‚duit adr de l'objet source: */
						srce_object = &M_newlink_adr[ srce_obj_no ];

					/* Ajoute l'ic“ne LIEN dans l'arbre: */
						new_object = add_arbo_elt( *tree, srce_object, &nb_objs );
					}
				}

				/*
				 * Fixe les coordonn‚es du nouvel objet: 
				 */
				new_object -> ob_x = offset_x;
				new_object -> ob_y = offset_y;

			}
		}
	}
}



/*
 * afnct_spec(-)
 *
 * Purpose:
 * --------
 * Trouve adr des sp‚cification associ‚es … une fonction arbo
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 10.11.94: more debug info
 */
AFNCTSPEC	*afnct_spec( int fnct )
{
	AFNCTSPEC *afnctspec = M_fnctarbo;		/* Adresse du tableau des fonctions arbo */
	int	i;

	for( i=0; i<NB_FNCTARBO; i++ )
	{
		if ( afnctspec[ i ] .fnct_no == fnct )
			break;
	}
	
	if( i == NB_FNCTARBO )
	{	/*
		 * Si pas trouv‚ 
		 */
		ping();
		TRACE1( "Fonction ARBO %d inconnue", fnct );
		return	afnctspec;		/* Renvoie adr 1ere fonction */
	}
	else
	{
		return	&afnctspec[ i ];
	}
}


/*
 * find_arbo_by_xy(-)
 *
 * Purpose:
 * --------
 * Trouve la page arbo se trouvant aux coordonn‚es X,Y
 *
 * Algorythm:
 * ----------  
 * Parcourt toutes les pages du DIR et v‚rifie leurs coordonn‚es
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
DATAPAGE	*	find_arbo_by_xy( 
					DATADIR *	datadir, 
					int 			pos_x, 
					int 			pos_y )
{
	DATAPAGE	*datapage = datadir -> data_start;	/* 1Šre page */
	PAGEARBO	*pagearbo;

	while( datapage != NULL )
	{	/*
		 * On se place sur les infos pagearbo: 
		 */
		pagearbo = datapage -> data.pagearbo;

		/*
		 *	Teste si on est sur la page cherch‚e 
		 */
		if( 	pagearbo -> map_pos_y == pos_y
			&&	pagearbo -> map_pos_x == pos_x )
		{
			break;		/* Sort si on a trouv‚ */
		}
	
		/*
		 * Passe … la page suivante: 
		 */
		datapage = datapage -> next;
	}

	if( datapage == NULL )
	{	/*
		 * Si la page n'a pas ‚t‚ trouv‚e! 
		 */
		signale("Page arbo recherch‚e n'est pas d‚finie");
	}

	return	datapage;
}



/*
 * find_inlinkXY(-)
 *
 * Purpose:
 * --------
 * Trouve les coordonn‚es X,Y de l'‚l‚ment Lien IN
 *
 * Algorythm:
 * ----------  
 * Cherche l'‚l‚ment dans le MAP
 *
 * History:
 * --------
 * 17.05.94: fplanque: Created
 */
int	find_inlinkXY( 					/* Out: !=0 si non trouv‚ (erreur) */		
				DATADIR	* pDataDir,		/* In:  Datadir dans lequel on cherche */
				int		* pn_posX,		/* Out: Position X en cases */
				int		* pn_posY )		/* Out: Position Y en cases */
{
	/*
	 * Plan du directory:
	 */
	DIRSPEC	*	pDirSpec = pDataDir -> dir_spec;
	unsigned	*	Tu_ArboMap = pDirSpec -> dir_map;
	unsigned		u_mapW = Tu_ArboMap[ 0 ];
	unsigned		u_mapH = Tu_ArboMap[ 1 ];
	int			n_i;

	/*
	 * Parcourt le map:
	 */
	for( n_i = 2; n_i < (u_mapW * u_mapH) + 2; n_i ++ )
	{
		if( Tu_ArboMap[ n_i ] == IDELT_IN )
		{ /*
			* Si on a trouv‚ l'‚lement LIEN IN:
			*/
			*pn_posY = (n_i-2) / u_mapW;
			*pn_posX = (n_i-2) % u_mapW;
			
			return	SUCCESS0;
		}
	}
	
	return	CORRUPT_1;
}



/*
 * add_arbo_elt(-)
 *
 * Purpose:
 * --------
 * Ajoute un nouvel objet dans l'arbo
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 21.09.94: gestion des flags LASTOB
 */
OBJECT	*add_arbo_elt( 
				OBJECT	*	tree, 
				OBJECT 	*	srce_object, 
				unsigned *	nb_objs )
{
	/*
	 * Adresse de l'objet nouveau lien: 
	 */
	OBJECT	*new_object;
	
	/*
	 * Comme on ajoute un objet le dernier objet actuel
	 * ne sera bientot plus le dernier:
	 */
	tree[ *nb_objs ] .ob_flags &= ~LASTOB;
	
	/*
	 * 1 objet de plus: 
	 */
	(*nb_objs) ++;

	/*
	 * Adresse nouvel objet: 
	 */
	new_object = &( tree[ *nb_objs ] );	

	/*
	 * Copie l'objet-lien: 
	 */
	memcpy( new_object, srce_object, sizeof( OBJECT ) );

	/*
	 * Fixe flags: 
	 * Nvel objet peut ˆtre s‚lectionn‚
	 * Ce le nouveau DERNIER objet de l'arbre!
	 */
	(new_object -> ob_flags) |= SELECTABLE | LASTOB;	
	
	/* printf("Flags=%X \n",new_object -> ob_flags); */

	/*
	 * Lie l'objet: 
	 */
	objc_add( tree, 0, *nb_objs );

	return	new_object;
}



/*
 * efface_arbotree(-)
 *
 * Purpose:
 * --------
 * Efface un arbre d'objet arbo dans 1 fenˆtre et la zone 
 * d'ICONBLKS s'il s'agissait de la derniŠre fenˆtre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 21.09.94: Correction bug sur d‚cr‚mentation nb_dirs
 */
void	efface_arbotree( WIPARAMS *wi_params_adr )
{
	/*
	 * R‚pertoire affich‚ dans la fenˆtre: 
	 */
	DATADIR	*datadir = wi_params_adr -> datadir;

	/*
	 * Une fenˆtre de moins dans DATDIR ET DATAGROUP... 
	 */
	(datadir -> nb_dirs)--;
	/*
	 * Teste s'il reste des fenˆtres semblables 
	 */
	if ( datadir -> nb_dirs == 0)
	{	/*
		 * Si on vient de fermer la derniŠre fenˆtre: 
		 */
		if ( datadir -> iconblks != NULL )
		{	/*
			 * S'il y avait des ic“nes et donc une zone d'ICONBLKs
			 *	ds la derniŠre fenˆtre: 
			 */
			FREE( datadir -> iconblks );	/* Efface tableau d'ICONBLK: */
			datadir -> iconblks = NULL;	/* Signale qu'on a ‚ffac‚ les ICONBLK
													 *	Ceci est important afin de d‚terminer,
													 *	lors de la r‚-ouverture du dossier,
													 *	s'il faut les re-cr‚er ou pas, en l'occurence: OUI !
													 */
		}
	}

	/*
	 * Efface arbre d'ic“nes de la m‚moire 
	 */
	FREE( wi_params_adr -> draw_ptr.tree );
}

                
                
/*
 * arbo_infoline(-)
 *
 * Purpose:
 * --------
 * Modifie la ligne d'informations sur l'arbo
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
char	*	arbo_infoline( 
				WIPARAMS *wi_params_adr )
{
	DATADIR	*	datadir = wi_params_adr -> datadir;
	DIRSPEC	*	pDirSpec = datadir -> dir_spec;
	int			nb_elts	= datadir -> nb_elts;
	int			nb_links = pDirSpec -> nb_objs - nb_elts;

	/* Cr‚ation de la ligne d'infos: */
	G_tmp_buffer[ 0 ] = ' ';

	itoa( nb_elts, &G_tmp_buffer[ 1 ], 10 );	/* Nombre d'‚l‚ments */
	if ( nb_elts <= 1 )
		strcat( G_tmp_buffer, " page, " );
	else
		strcat( G_tmp_buffer, " pages, " );

	itoa( nb_links, &G_tmp_buffer[ strlen( G_tmp_buffer ) ], 10 );	/* Nombre de liens */
	if ( nb_links <= 1 )
		strcat( G_tmp_buffer, " lien." );
	else
		strcat( G_tmp_buffer, " liens." );

	return	STRDUP( G_tmp_buffer );
}



/*
 * arbo_infoline_selection(-)
 *
 * Purpose:
 * --------
 * Modifie la ligne d'informations sur l'arbo 
 * lorsqu'on a s‚lectionn‚ une icone
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
char	* arbo_infoline_selection( 
				WIPARAMS * wi_params_adr )
{
	DATADIR		*datadir			= wi_params_adr -> datadir;
	int			selected_icon	= wi_params_adr -> selected_icon;
	OBJECT		*selected_obj	= &(wi_params_adr -> draw_ptr.tree)[selected_icon];

	/*
	 * Controle type: 
	 */
	if ( selected_obj -> ob_type == G_IMAGE )
	{	/*
		 * S'il s'agit d'un lien (G_IMAGE): 
		 */
		strcpy( G_tmp_buffer, " 1 lien s‚lectionn‚." );
	}
	else
	{	/*
		 * S'il s'agit d'un page (G_ICON): 
		 */
		char			*dataname		= (selected_obj -> ob_spec.iconblk) -> ib_ptext;
		DATAPAGE		*datapage	 	= page_adr_byname( datadir, dataname ); 
		char			*comment			= datapage -> comment;

		/*
		 * Cr‚ation de la ligne d'infos: 
		 */
		strcpy( G_tmp_buffer, " S‚lection: " );
		strcat( G_tmp_buffer, dataname );		/* Ajoute nom de la page */
		if ( comment != NULL )
		{
			strcat( G_tmp_buffer, " = " );
			strcat( G_tmp_buffer, comment );		/* Ajoute commentaire */
		}
	}
	
	return	STRDUP( G_tmp_buffer );
}



/*
 * arbotree_optimal(-)
 *
 * Purpose:
 * --------
 * Calcul des coordonn‚es optimales pour le full-screen window
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 16.03.95: corrig‚ petit bug d'accŠs … DirSpec
 */
void	arbotree_optimal( 
			int			wi_ckind, 
			DATADIR	*	datadir, 
			int 		*	border_x, 
			int		*	border_y, 
			int		*	border_w, 
			int		*	border_h)
{
	int			map_width, map_height;
	int			form_w, form_h;

	/*
	 * Trouve taille du map:
	 */
	if( datadir == NULL )
	{	/*
		 * Taille par d‚faut: 
		 */
		map_width = ARBOPAGES_W;
		map_height = ARBOPAGES_H;
	}
	else
	{	/*
		 * Taille actuelle: 
		 */
		DIRSPEC	*	pDirSpec = datadir -> dir_spec;
		map_width = pDirSpec -> dir_map[ 0 ];
		map_height = pDirSpec -> dir_map[ 1 ];
	}

	/*
	 * Taille du formulaire aes 
	 */
	form_w = map_width * G_arbocell_w +WA_BORDER +WA_OUTLINE;
	form_h = map_height * G_arbocell_h +WA_BORDER +WA_OUTLINE;

	/*
	 * Calcule les coordonn‚es totales de la fenˆtre: 
	 */
	wind_calc( WC_BORDER, wi_ckind, 50, 50, form_w, form_h,
					border_x, border_y, border_w, border_h );

	/*
	 * Contr“le taille + centrage: 
	 */
	if ( *border_w > G_w_maxi )
		*border_w = G_w_maxi;
	*border_x = G_x_mini + (G_w_maxi - *border_w) /2;

	if ( *border_h > G_h_maxi )
		*border_h = G_h_maxi;
	*border_y = G_y_mini + (G_h_maxi - *border_h) /2;
}



               
               
/*
 * select_newarbo(-)
 *
 * Purpose:
 * --------
 * S‚lection d'un nouvel element … placer dans une arbo
 *
 * History:
 * --------
 * 22.01.95: fplanque: extracted from new_arbo()
 * 23.01.95: empeche double click
 */
OBJECT *	select_newarbo(
			int 				type, 
			const GRECT *	start_box,
			int			* ob_x,		/* Out: Coordonn‚es de l'objet s‚lectionn‚ */
			int			* ob_y,
			int			* ob_w,
			int			* ob_h,
			UINT			* object_id )	/* Out: 'forme' de l'objet */
{
	GRECT		form_box;					/* Dimensions du formulaire */
	OBJECT	*form_adr;					/* Adresse du formulaire */
	int		annuler;						/* No du bouton "Annuler" */
	int		exit_obj;
	int		edit_obj = 0;				/* Bidon */

	OBJECT	*	newlink_obj;
	
	/*
	 * Teste si on va ajouter un lien ou une page: 
	 */
	switch( type )
	{
		case	0:
			form_adr = M_newlink_adr;
			annuler	= NEWLKANN;
			break;
			
		case	1:
			form_adr = M_newpagearbo_adr;
			annuler	= NEWPAGAN;
			break;
			
		default:
			ping();
	}

	/*
	 * Affiche/gŠre formulaire: 
	 */
	open_panel( form_adr, start_box, &form_box, TRUE_1 );

	do
	{
		exit_obj = ext_form_do( form_adr, &edit_obj );	/* Gestion de la boŒte */

	} while( exit_obj & 0x8000 );		/* ne sort pas Si on a double cliqu‚ */

	if( exit_obj == annuler )
	{	/*
		 * Si on a annul‚: 
		 */
		abort_pannel( form_adr, exit_obj, start_box, &form_box );

		return NULL;
	}


	/*
	 * Adresse de l'objet - nouveau lien: 
	 */
	newlink_obj = &(form_adr[ exit_obj ]);

	/*
	 * Ferme formulaire 
	 */			
	close_pannel( form_adr, exit_obj, &form_box );

	/*
	 * Coord de d‚part du drag: 
	 */
	objc_offset( form_adr, exit_obj, ob_x, ob_y );
	*ob_w = newlink_obj -> ob_width;
	*ob_h = newlink_obj -> ob_height;


	/*
	 * Trouve la forme de l'ic“ne: 
	 */
	switch( type )
	{
		case	0:				/* Lien */
			*object_id = M_link_id[ exit_obj - LKFETS ];
			break;
			
		case	1:				/* Page arbo */
			*object_id = IDPAGE_STD;
			break;
			
		default:
			signale( "Lien ou ic“ne??" );
	}
	/* printf("ID:%X\n",object_id); */


	return	newlink_obj;

}




	
/*
 * add_newarbo(-)
 *
 * Purpose:
 * --------
 * S‚lection d'un nouvel element … placer dans une arbo
 *
 * History:
 * --------
 * 22.01.95: fplanque: extracted from new_arbo()
 */
BOOL	add_newarbo(							/* Out: TRUE_1 si ok */
			unsigned			object_id,		/* In: forme de l'objet */
			OBJECT		*	newlink_obj,	/* In: ModŠle d'objet … ajouter */
			const GRECT *	start_box,
			int				drop_x,			/* In: Coordonn‚es de placement */
			int				drop_y )
{
	DATADIR	*	curr_datadir = G_wi_list_adr -> datadir;   /* Dossier concern‚ */
	DIRSPEC	*	pDirSpec = curr_datadir -> dir_spec;
	unsigned	*	nb_objs = &(pDirSpec -> nb_objs);
	unsigned	*	nb_iblks = &(pDirSpec -> nb_iblks);
	int			pos_x = (G_wi_list_adr -> draw_ptr.tree) -> ob_x + drop_x * G_arbocell_w +AICON_OFFX;
	int			pos_y = (G_wi_list_adr -> draw_ptr.tree) -> ob_y + drop_y * G_arbocell_h +AICON_OFFY;
	OBJECT	*	tree = G_wi_list_adr -> draw_ptr.tree;
	OBJECT	*	newelt_cpy;	/* Adresse de la copie du lien/page int‚gr‚e … l'arbre d'objets */
	ICONBLK	*	iblk_array = curr_datadir -> iconblks;
	ICONBLK	*	newiblk_cpy;	/* Adresse de la copie de l'iconblk int‚gr‚e … l'arbre d'objets */
	int			link_x, link_y;
	int			work_x = G_wi_list_adr -> work_x,
					work_y = G_wi_list_adr -> work_y;
	GRECT			dest_box;		/* Coord nlle ic“ne ds denˆtre */
	/*
	 * Adresse du map: 
	 */
	unsigned	*	arbo_map = pDirSpec -> dir_map;	/* Avant, on prenait le datadir, ds le content */

	/*
	 * Effet graphique d'ouverture sur cet emplacement: 
	 */
	graf_growbox( start_box -> g_x, start_box -> g_y,
						start_box -> g_w -8, start_box -> g_h,
						pos_x, pos_y, G_arbocell_w, G_arbocell_h );
	/*
	 * Ce -8 pourrait paraitre bizarre, en effet! 
	 * Il evite la d‚g‚n‚rescence de l'effet graphique si la 
	 * source est bcp plus large que la destination! 
	 */

	/*
	 * Contr“le si on a la place de l'ajouter: 
	 */
	if( *nb_objs >= pDirSpec -> max_objs )
	{	/*
	 	 * Pas la place de l'ajouter 
	 	 */
		signale("Object room overflow");	/* PROVISOIRE */
		return	FALSE0;
	}

	if( (object_id & CT_ARBO)  &&  (*nb_iblks) >= pDirSpec -> max_iblks )
	{	/*
		 * Pas la place d'ajouter ICONBLK pour icone page arbo
		 */
		signale("ICONBLK room overflow");	/* PROVISOIRE */
		return	FALSE0;
	}
	
	/*
	 * Ajoute/Copie l'objet-lien/page-arbo … l'arbre
	 * (Un objet de plus): 
	 */
	newelt_cpy = add_arbo_elt( tree, newlink_obj, nb_objs );
				
	/*
	 * Si page, duplication de l'iconblk 
	 */
	if( object_id & CT_ARBO )
	{	/*
	 	 * Si page: 
		 * -------- 
		 * Duplique IBLK 
		 */
		newiblk_cpy = &( iblk_array[ *nb_iblks ] );	/* Adresse copie */
		memcpy( newiblk_cpy,
			 newlink_obj -> ob_spec.iconblk,
			 sizeof( ICONBLK ) ); /* Copie */
		(*nb_iblks)++;		/* Un IBLK de plus */
		
		/*
		 * Lie IBLK … l'objet: 
		 */
		newelt_cpy -> ob_spec.iconblk = newiblk_cpy;
	}
				
	/*
	 * Fixe coordonn‚es: 
	 */
	newelt_cpy -> ob_x = drop_x * G_arbocell_w + AICON_OFFX;
	newelt_cpy -> ob_y = drop_y * G_arbocell_h + AICON_OFFY;
	objc_offset( tree, *nb_objs, &link_x, &link_y );

	/* ---------------------------- */
	/* Redraw de la zone concern‚e: */
	/* ---------------------------- */
	dest_box .g_x = max( work_x, link_x );
	dest_box .g_y = max( work_y, link_y );
	dest_box .g_w = min( work_x + G_wi_list_adr -> seen_w, link_x + G_arbocell_w) - dest_box .g_x;
	dest_box .g_h = min( work_y + G_wi_list_adr -> seen_h, link_y + G_arbocell_h) - dest_box .g_y;
	/* printf("Dessin zone:%d %d %d %d\n",dest_box .g_x,dest_box .g_y,dest_box .g_w,dest_box .g_h); */

	if( object_id & CT_ARBO )
	{	/*
		 * S'il s'agit d'une ic“ne page: 
		 */
		(newelt_cpy -> ob_state) |= SELECTED;	/* S‚lectionne */
	}
	objc_draw( tree, 0, 2, dest_box .g_x, dest_box .g_y, dest_box .g_w, dest_box .g_h);

	/* 
	 * Solution alternative:
	 *	… utiliser le jour ou on pourra placer l'ic“ne dans une fenˆtre
	 * qui n'est pas au TOP ! :
	 *	modif_icon( G_wi_list_adr, 0,*nb_objs, <<<selected>>>, CTRL_OK );
	 */

	/*
	 * Signale l'objet dans le tableau arbo_map 
	 */
	arbo_map[ drop_y * arbo_map[0] + drop_x +2 ]		/* +2 pour Larg et Haut en 0 et 1 */
			= object_id;

	if( object_id & CT_ARBO )
	{	/*
		 * Si on vient de placer une page arbo: 
		 */

		char 		*	pMsz_NewName;
		char 		*	pMsz_NewComment;
		DATAPAGE	*	datapage;
		
		/*
		 * ***************
		 * Demande le nom: 
		 * ***************
		 */
		pMsz_NewName = query_newname( &dest_box, "NOUVELLE PAGE ARBORESCENCE", NULL, NULL, &pMsz_NewComment, CTRL_OK );

		if( pMsz_NewName == NULL )
		{	/*
			 * On a annul‚:
			 */
			arbo_map[ drop_y * arbo_map[0] + drop_x +2 ] = 0;
			if( object_id & CT_ARBO )
			{
				(*nb_iblks)--;		/* Un IBLK de moins  */
			}
			objc_delete( tree, *nb_objs );
			(*nb_objs)--;
			tree[ *nb_objs ] .ob_flags |= LASTOB;
			/*
			 * Redraw de la zone concern‚e: 
			 */
			objc_draw( tree, 0, 2, dest_box .g_x, dest_box .g_y, dest_box .g_w, dest_box .g_h);
		}
		else
		{	/*
			 * On a confirm‚
			 * Cr‚e la nouvelle page en m‚moire: 
			 */
			/* printf("Type de la page: %X\n",(newlink_obj -> ob_type)>>8); */

			datapage = cree_pagearbo( curr_datadir, (newlink_obj -> ob_type)>>8, pMsz_NewName, drop_x, drop_y );
			FREE( pMsz_NewName );

			/*
			 * Fixe commentaire:
			 */
			datapage -> comment = pMsz_NewComment;

			/*
			 * Modifie ICONBLK: 
			 */
			newiblk_cpy -> ib_ptext = datapage -> nom; /* Fixe ptr sur nom */
			/*
			 * Redraw de la zone concern‚e: 
			 */
			newelt_cpy -> ob_state &= (!SELECTED);	/* D‚s‚lectionne */
			objc_draw( tree, 0, 2, dest_box .g_x, dest_box .g_y, dest_box .g_w, dest_box .g_h);
	
			/*
			 * Signale que le dossier courant a ‚t‚ modifi‚
			 */
			dataPage_chgSavState( datapage, SSTATE_MODIFIED, TRUE_1, TRUE_1 );
	
			/*
			 * AUTOLINK:
			 * Liaison automatique avec le pŠre de la nouvelle page:
			 */
			link_arbo_to_parent( curr_datadir, drop_x, drop_y );
		}
	}

	return	TRUE_1;
}



/*
 * new_arbo(-)
 *
 * Purpose:
 * --------
 * Cr‚ation d'un nouveau lien/page arbo
 *
 * Algorythm:
 * ----------  
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 22.11.94: teste fen ouverte avant d'agir
 * 22.11.94: efface newname obtenu par query_newname()
 * 17.12.94: fixe flag modified
 */
void	new_arbo( 
			int 				type, 
			const GRECT *	start_box )
{
	OBJECT	*	newlink_obj;
	unsigned		object_id;

	/*
	 * Coord objet en position de d‚part: 
	 */
	int		ob_x, ob_y, ob_w, ob_h;
	/*
	 * Coordonn‚es de relachement: 
	 */
	int		drop_x, drop_y;
	int		valid;				/* Validit‚ du relachement */


	if( G_wi_list_adr == NULL 
		|| G_wi_list_adr -> type != TYP_TREE )
	{
		ping();
		return;
	}
	
	/*
	 * Simule "construction ‚cran" pour empˆcher 
	 * l'AES de d‚rouler ses menus: 
	 */
	start_WINDRAW( NULL );

	/*
	 * S‚lection d'un noyvel objet:
	 */
	newlink_obj = select_newarbo( type, start_box, &ob_x, &ob_y, &ob_w, &ob_h, &object_id );

	if( newlink_obj == NULL )
	{	/*
	 	 * On a annul‚:
		 * Fin construction ‚cran:
		 */
		end_WINDRAW();
	
		return;
	}
	

	/*
	 * Positionne l'arbre d'objets de la fenetre au top: 
	 */
	fixform_window( G_wi_list_adr );		/* Fixe nlle position formulaire */

	/*
	 * Mouvement du fant“me: 
	 */
	valid = drag_arboicon(	object_id, 
									ob_x, ob_y,
			 						ob_x + ob_w /2, ob_y + ob_h /2, 
									-1, -1,
									&drop_x, &drop_y,
									CTRL_OK );

	if( valid == POS_REPLACE_2 || valid == POS_WRONGREP_4 )
	{	/*
		 * Impossible de remplacer objet
		 * Fin construction ‚cran:
		 */
		end_WINDRAW();

		form_alert( 1,  "[3][|Vous devez effacer le contenu|"
									"de cette case avant de pouvoir|"
									"y cr‚er un nouvel ‚l‚ment.]"
									"[Abandon]" );
									
		return;
	}

	if( valid == FALSE0 )
	{	/*
		 * On a relach‚ l'ic“ne en dehors de la fenˆtre:
		 * Fin construction ‚cran:
		 */
		end_WINDRAW();

		return;
	}

	/*
	 * ------------------------------------
	 * Si on a relach‚ … un endroit valide: 
	 * ------------------------------------
	 */
	add_newarbo( object_id, newlink_obj, start_box, drop_x, drop_y );
	
	/*
	 * Fin construction ‚cran:
	 */
	end_WINDRAW();
}


/*
 * arboTree_MoveElt(-)
 *
 * Purpose:
 * --------
 * D‚placement d'un ‚l‚ment dans un dossier arborescence
 *
 * Suggest:
 * ------
 * On peut faire sans WI_PARAMS
 * ADAPTER AU MDI
 *
 * History:
 * --------
 * 10.10.94: fplanque: Created
 */
void arboTree_MoveElt(
			DATADIR	*	pDataDir,		/* In: Datadir ds lequel s'effectue le d‚placement */
			int			n_StartX,		/* In: grid pos de d‚part */
			int			n_StartY,
			int			n_DestX,			/* In: grid pos d'arriv‚e */
			int			n_DestY,
			WIPARAMS *	wi_params_adr )
{
	DIRSPEC * pDirSpec = pDataDir -> dir_spec;
	/*
	 * Quel arbre d'objets: 
	 * Quel objet: 
	 */
	OBJECT *	pObj_Tree = wi_params_adr -> draw_ptr.tree;
	int		n_StartObjX = n_StartX * G_arbocell_w + AICON_OFFX;
	int		n_StartObjY = n_StartY * G_arbocell_h + AICON_OFFY;
	int		n_ObjIndex = find_ObjByXY( pObj_Tree, n_StartObjX, n_StartObjY );
	OBJECT *	pObject = &pObj_Tree[ n_ObjIndex ];

	/*
 	 * MAP:
	 */
	unsigned	*	arbo_map 	= &(pDirSpec -> dir_map)[ 2 ];	/* Tableau repr‚sentatif */
	unsigned		map_width	= (pDirSpec -> dir_map)[ 0 ];	/* Largeur tableau */
	/*
	 * Nos des cases concern‚es dans le map:
	 */
	int		map_SrcePos = n_StartY * map_width + n_StartX;	
	int		map_DestPos = n_DestY * map_width + n_DestX;	


	/* TRACE3( "Moving obj (%d,%d): %d", n_StartObjX, n_StartObjY, n_ObjIndex ); */


	/*
	 * D‚placement dans arbre GEM:
	 */
	pObject -> ob_x = n_DestX * G_arbocell_w + AICON_OFFX;
	pObject -> ob_y = n_DestY * G_arbocell_h + AICON_OFFY;


	/*
 	 * D‚placement dans map:
	 */
	arbo_map[ map_DestPos ] = arbo_map[ map_SrcePos ];
	arbo_map[ map_SrcePos ] = 0;


	/*
	 * Fixe nlles coords dans page ARBO:
	 */
	if( arbo_map[ map_DestPos ] & CT_ARBO )
	{	/*
		 * On a boug‚ une page arbo:
		 * On recherche la page qui se trouvait 
		 *	aux coordonn‚es de l'ic“ne qu'on vient d'effacer: 
		 */
		DATAPAGE	*	pDataPage = find_arbo_by_xy( pDataDir, n_StartX, n_StartY );
		PAGEARBO	*	pPageArbo = pDataPage -> data.pagearbo;

		/* TRACE1( "Moving datapage: %lX", pDataPage ); */

		pPageArbo -> map_pos_x = n_DestX;			
		pPageArbo -> map_pos_y = n_DestY;
	}
	
	/* TRACE0( "  Move OK" ); */
}



/*
 * move_arbo(-)
 *
 * Purpose:
 * --------
 * D‚placement/Copie d'une page/lien arbo … la souris
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 06.10.94: fplanque: d‚but impl‚mentation du move:
 * 10.10.94: gestion des redraw
 */
void	move_arbo( 
			WIPARAMS *	wi_params_adr, 
			int clic_x, 
			int clic_y )
{
	/*
	 * Dans quel dossier se trouve t'on ? 
	 */
	DATADIR	*	datadir		= wi_params_adr -> datadir;	/* Dossier concern‚ */
	DIRSPEC	*	pDirSpec		= datadir -> dir_spec;
	unsigned		map_width	= (pDirSpec -> dir_map)[ 0 ];	/* Largeur tableau */
	unsigned	*	arbo_map 	= &(pDirSpec -> dir_map)[ 2 ];	/* Tableau repr‚sentatif */

	/*
	 * Quel arbre d'objets: 
	 */
	OBJECT	*start_tree = wi_params_adr -> draw_ptr.tree;
	/*
	 * Quel objet: 
	 */
	int		stobj_no = wi_params_adr -> selected_icon;
	OBJECT	*stobj_adr = &start_tree[ stobj_no ];
	int		stobj_x, stobj_y;

	/*
	 * Offset zone de travail fenˆtre: 
	 */
	int	work_x = start_tree -> ob_x + AICON_OFFX;
	int	work_y = start_tree -> ob_y + AICON_OFFY;

	/*
	 * Conversion des coordonn‚es ‚cran de la souris en coordonn‚es tableau de la case survol‚e: 
	 */
	int	stcl_x	= (clic_x - work_x) /G_arbocell_w;	/* Coord X en emplacements */
	int	stcl_y	= (clic_y - work_y) /G_arbocell_h;	/* Coord Y en emplacements */

	/*
	 * Quel est le type d'objet … d‚placer/copier: 
	 */
	int		map_elt = stcl_y * map_width + stcl_x;	/* No de case dans le map */
	unsigned	object_id = arbo_map[ map_elt ];			/* Contenu de la case */

	/*
	 * Coordonn‚es de relachement: 
	 */
	int	drop_x, drop_y;
	int	destination;		/* Information sur la destination de l'icone */

	/* printf("%d %d -> %d Type d'objet: %X\n", stcl_x, stcl_y, map_elt, object_id ); */

	/*
	 * Coordonn‚es de l'ic“ne de d‚part: 
	 */
	objc_offset( start_tree, stobj_no, &stobj_x, &stobj_y );

	/*
	 * Mouvement du fant“me: 
	 */
	destination = drag_arboicon(	object_id, 
											stobj_x,	stobj_y,
											clic_x,	clic_y, 
											stcl_x,	stcl_y,
											&drop_x,	&drop_y,
											TAKE_CTRL );

	graf_mouse(BUSYBEE, 0);		/* Change curseur souris */

	/*
	 * Selon destination choisie: 
	 */
	if( destination < 0 )
	{	/*
		 * On a d‚plac‚ l'ic“ne d'un endroit … un autre de la fenˆtre:
		 */

		if( destination == POS_REPLACE_2 || destination == POS_WRONGREP_4 )
		{	/*
			 * Si on veut remplacer un autre objet:
			 * il faut effacer celui-ci au pr‚alable:
			 */

			if( arboTree_DeleteElt( datadir, drop_x, drop_y, wi_params_adr ) == FALSE0 )
			{	/*
				 * Si on a pas effac‚:
				 */
				return;			 
			}			
		}		

		/*
		 * On va maintenant effectuer le d‚placement r‚el:
		 */
		arboTree_MoveElt( datadir, stcl_x, stcl_y, drop_x, drop_y, wi_params_adr );

		/*
		 * R‚affichage: 
		 */
		send_fullredraw( wi_params_adr );

	}
	else	if( destination > 0 )
	{	/*
		 * Destination: une ICONE du BUREAU: 
		 */
		int	resultat = IMPOSS0;		/* A priori, l'op‚ration est impossible! */
		
		/*
		 * Selon destination: 
		 */
		switch( destination )
		{
			case	DSTTRASH:		
				/*
				 * Destination: CORBEILLE 
				 */
				if ( object_id == IDELT_IN )
				{	/*
					 * Si on essaie d'effacer le point d'entr‚e: 
					 */
					form_alert(1,"[1][|Vous ne pouvez pas supprimer|le point d'entr‚e du dossier!][ Abandon ]");
					resultat = ERROR_1;
				}
				else
				{	/*
					 * Si on veut effacer un lien ou une page: 
					 */
					OBJECT	*dest_adr	= &G_desktop_adr[ destination ];

					/*
					 * Effet graphique: 
					 */
					graf_beginmove( start_tree, stobj_adr, destination, dest_adr );

					/*
					 * Effacement en mem et … l'‚cran:
					 */
					if( arboTree_DeleteElt( datadir, stcl_x, stcl_y, wi_params_adr ) == TRUE_1 )
					{	/*
						 * Si on a effac‚:
						 * Plus d'ic“ne s‚lectionn‚e: 
						 */
						no_selection();
						/*
						 * Modifie ligne d'informations: (Plus de s‚lection) 
						 */
						set_infoline( wi_params_adr, arbo_infoline );
					
						/*
						 * R‚affichage: 
						 */
						/* redraw( wi_params_adr, 'x' + n_ObjX, 'y' + n_ObjY, G_arbocell_w, G_arbocell_h, TAKE_CTRL ); */
						send_fullredraw( wi_params_adr );
					}
				
					resultat = OK1;	/* OK c fait (il faut d‚selectionner la destination) */
				}
									
				break;
		}	
	
		/*
		 * Selon r‚sultat op‚ration: 
		 */
		switch ( resultat )
		{
			case	IMPOSS0:
				alert( PERR_IMPOSSIBLE_OP );		/* Op‚ration impossible */
				break;
			
			case	OK1:
				/*
				 * D‚s‚lectionne destination: 
				 */
				modif_icon( G_desk_params_adr, destination, destination, NORMAL, TAKE_CTRL );
				break;
					
			case	ERROR_1:
				/*
				 * on ne fait rien 
				 */
				break;
				
			default:
				ping();
		}
	}
}




/*
 * arboTree_DeleteElt(-)
 *
 * Purpose:
 * --------
 * Efface une page d'une arborescence
 *
 * Suggest:
 * --------
 * Adapter au MDI
 *
 * History:
 * --------
 * 03.10.94: fplanque: created by moving from move_arbo()
 * 06.10.94: cherche index objet en fonction de la position, full redraw
 * 09.10.94: slight changes aiming at debugging this stuff
 * 09.10.94: remplac‚ appel de maptree() par find_ObjbySpec() : Bug corrig‚, mais pk maptree plante??
 * 10.10.94: ne provoque plus de redraw de soi-mˆme
 * 11.10.94: dplacement de la s‚lection courante si n‚cessaire
 */
int arboTree_DeleteElt( 				/* Out: TRUE si on a confim‚ effacement */
			DATADIR	*	datadir,
			int			mapPos_x,		/* In: Coordonn‚es de l'elt … effacer dans le tableau */
			int			mapPos_y,
			WIPARAMS *	wi_params_adr )
{
	int		effacement	= NO0;						/* A propri, on efface pas sans confirmation */

	DIRSPEC * pDirSpec = datadir -> dir_spec;
	
	/*
 	 * MAP:
	 */
	unsigned	*	arbo_map 	= &(pDirSpec -> dir_map)[ 2 ];	/* Tableau repr‚sentatif */
	unsigned		map_width	= (pDirSpec -> dir_map)[ 0 ];	/* Largeur tableau */
	/*
	 * No de case '… vider' dans le map:
	 */
	int		map_elt = mapPos_y * map_width + mapPos_x;	
	/*
	 * Type d'objet se trouvant … cet endroit:
	 */
	unsigned	object_id = arbo_map[ map_elt ];			/* Contenu de la case */

	/*
	 * Quel arbre d'objets: 
	 * Quel objet: 
	 */
	OBJECT *	pObj_Tree = wi_params_adr -> draw_ptr.tree;
	int		n_ObjX 	= mapPos_x * G_arbocell_w + AICON_OFFX;
	int		n_ObjY 	= mapPos_y * G_arbocell_h + AICON_OFFY;
	int		n_ObjIndex = find_ObjByXY( pObj_Tree, n_ObjX, n_ObjY );
	OBJECT *	pObject	= &pObj_Tree[ n_ObjIndex ];
	/*
 	 * Nbre d'objets:
	 * (Non compris le ROOT ni le lien 'IN')
	 */
	int		nb_objs = pDirSpec -> nb_objs;

	/* TRACE0( "-------------delete--------------" ); */
	/* TRACE1( "Nb objs before erase: %d", nb_objs ); */

	/*
	 * Anti Stuck:
	 */
	if( n_ObjIndex == -1 )
	{
		signale( "arboTree_DeleteElt() n'a pas trouv‚ l'elt … effacer!" );
		return	FALSE0;
	}


	/*
	 * Teste si on efface une page: 
	 */
	if( object_id & CT_ARBO )
	{	/*
		 * On efface une page: 
		 * On va donc supprimer les donn‚es de la page: 
		 *
		 * On recherche la page qui se trouvait 
		 *	aux coordonn‚es de l'ic“ne qu'on vient d'effacer: 
		 */
		DATAPAGE	*datapage = find_arbo_by_xy( datadir, mapPos_x, mapPos_y );
		
		/*
		 * Demande conf & Supprime la page: 
		 */
		if( efface_1data( datadir, datapage ) )
		{	/*
			 * Si on a effac‚: 
			 */
			effacement = YES1;
		}
	}
	else
	{	/*
		 * Si on efface un lien: 
	 	 * On ne demande pas de confirmation
		 */
		effacement = YES1;	/* OK on peut effacer */
	}


	if( effacement == FALSE0 )
	{	/*
 		 * On n'a pas confirm‚!!:
		 */
		return	FALSE0;
	}

	/*
	 * -------------------------
 	 * On enlŠve l'objet du MAP:
	 * Effacement logique du map: 
	 */
	arbo_map[ map_elt ] = 0;	/* Case VIDE */

	/*
	 * Teste s'il s'agit d'une ic“ne: 
	 */
	if( (pObj_Tree[ n_ObjIndex ] .ob_type & 0x00FF) == G_ICON )
	{	/*
		 * S'il s'agit d'une ic“ne: 
		 * Il va falloir supprimer l'ICONBLK: 
		 */
		ICONBLK	*	rm_iblk;
		ICONBLK	*	iconblks;
		int			nb_iblks;
		ICONBLK	*	last_iblk;
										
		/* IBLK … supprimer */
		rm_iblk = pObj_Tree[ n_ObjIndex ] .ob_spec.iconblk;	

		/* Tableau d'IBLKs du dossier */
		iconblks = datadir -> iconblks;
	
		/* Nbre d'IBLKS dans le dossier */
		nb_iblks = pDirSpec -> nb_iblks;		
	
		/* Ptr sur dernier IBLK */
		last_iblk = &iconblks[ nb_iblks-1 ];	

		/*
		 * Teste si on invalide le dernier ICONBLK ou pas: 
		 */
		if( rm_iblk < last_iblk )
		{	/*
			 * On n'a pas invalid‚ le dernier ICONBLK... 
			 * Il y a donc un trou qu'il faut combler! 
			 * Recopie le dernier IBLK vers le trou: 
			 */
			int 			idx;
			OBJECT	*	pObj_Owner;

			/* TRACE2( "  Moving ICONBLK: %lX -> %lX", last_iblk, rm_iblk ); */

			memcpy( rm_iblk, last_iblk, sizeof( ICONBLK ) );
			
			/*
			 * Recherche l'objet … qui appartenait le dernier IBLK 
			 */
			/* M_searched_iblk = last_iblk;			/* IBLK dont on recherche le propri‚taire */
			/* M_iblk_owner = NULL; */
			/* maptree( pObj_Tree, 2, nb_objs + 1, iblk_owner ); */

			idx = find_ObjBySpec( pObj_Tree,	last_iblk );
			pObj_Owner = &(pObj_Tree[idx] );

			if( pObj_Owner < pObj_Tree )
			{
				signale( "Could not find IBLK owner!" );
			}
			
			/* TRACE2( "  OBJECT=%lX has last IBLK:%lX", pObj_Owner, pObj_Owner -> ob_spec.iconblk ); */

			/*
			 * Change pointeur vers le nouvel iblk, 
			 * celui qui bouche le trou; afin de lib‚rer le dernier: 
			 */
			pObj_Owner -> ob_spec.iconblk = rm_iblk;
			
		}

		/*
		 * 1 ICONBLK de moins: 
		 */
		(pDirSpec -> nb_iblks) --;
	}

	/*
	 * EnlŠve les liens sur l'objet: 
	 */
	objc_delete( pObj_Tree, n_ObjIndex );


	/*
	 * Teste si on a supprim‚ le dernier objet ou pas: 
	 */
	if( n_ObjIndex < nb_objs )
	{	/*
		 * Si on a pas supprim‚ le dernier objet: 
		 */

		/*
		 * ATTENTION au trou cr‚‚ dans l'arbre!!... 
		 * On va ramener le dernier objet … la place 
		 * de celui qu'on vient d'enlever! 
		 * EnlŠve les liens sur le dernier objet: 
		 */

		objc_delete( pObj_Tree, nb_objs );
		/*
		 * L'objet enlev‚ n'est plus le dernier elt de l'arbre:
		 */
		pObj_Tree[ nb_objs ] .ob_flags &= ~LASTOB;
		/*
		 * Recopie cet objet dans le trou cr‚‚ plus haut: 
		 */
		memcpy( pObject, &pObj_Tree[ nb_objs ], sizeof( OBJECT ) );
		/*
		 * Recr‚e les liens entre l'objet d‚plac‚ et l'arbre: 
		 */
		objc_add( pObj_Tree, ROOT, n_ObjIndex );
		/*
		 * Fixe nouveau LASTOB:
		 */
		pObj_Tree[ nb_objs -1 ] .ob_flags |= LASTOB;
		
		
		/*
		 * Mise … jour de la s‚lection courante si elle a ‚t‚ d‚plac‚e:
		 * ATTENTION: pas compatible MDI: la s‚lection pourrait ˆtre ds une autre fenˆtre
		 */
		if( wi_params_adr -> selected_icon == nb_objs )
		{
			/* TRACE2( "CHANGING s‚lection from %d to %d", nb_objs, n_ObjIndex ); */
			wi_params_adr -> selected_icon = n_ObjIndex;
		}
	}

	/*
	 *	Un objet de moins dans l'arbre: 
	 */
	(pDirSpec -> nb_objs) --;

	return	TRUE_1;
	
}


#ifdef	NOTDEFINED
/*
 * iblk_owner(-)
 *
 * Purpose:
 * --------
 * Subroutine from MAPTREE: 
 * Recherche le propri‚taire d'un ICONBLK donn‚
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
int	iblk_owner( OBJECT *tree, int obj )
{
	OBJECT	*	pObject = &tree[ obj ];
	
	if ( (pObject -> ob_type & 0x00FF) == G_ICON )
	{	/*
		 * S'il s'agit d'une ic“ne: 
		 */	
		/* TRACE2( "MapTree: examine obj %lX IBLK=%lX", pObject, pObject -> ob_spec.iconblk ); */
		if( pObject -> ob_spec.iconblk == M_searched_iblk )
		{	/*
	 		 * Si on a trouv‚ le propri‚taire: 
			 */
			/* TRACE0( "Found sought IBLK!" ); */

			M_iblk_owner = pObject;

			return	FALSE0;	/* On arrˆte la recherche */
		}
	}
	
	return	TRUE_1;	/* On continue … chercher */
}
#endif 
 
 
/*
 * drag_arboicon(-)
 *
 * Purpose:
 * --------
 * D‚placement d'un fant“me d'ic“ne	
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 10.10.94: contr“le si coord drop = init
 */
int	drag_arboicon(						/* Out: Code indiquant le type de destination */
			unsigned		object_id, 
			int			ob_x, 			/* In: Pos de l'objet au d‚part */
			int			ob_y, 
			int			start_x, 		/* In: position de la souris au d‚part */
			int			start_y, 
			int			n_GridSrceX,	/* In: Coordonn‚es de d‚part ds la grille */
			int			n_GridSrceY,
			int		*	drop_x, 			/* In: Grid coord de relƒchement */
			int		*	drop_y,
			int 			take_control )	/* In: faut il prendre le controle de l'‚cran ou pas? */
{
	int		drag_evt;			/* EvŠnement qui s'est d‚clench‚: */
	int		new_bstate, kbd_state, kbd_return, mouse_nbc;	/* Non utilis‚s */

	int		offset_x , offset_y;
	int		fantome_x, fantome_y;
	int		area_x1, area_y1, area_x2, area_y2;	/* Zone de d‚placement du fant“me */
	int		new_x, new_y;		/* Nlle position souris */

	int		new_handle;			/* Handle de la fen point‚e par la souris */
	int		i,j;
	
	/*
	 * Offset zone de travail fenˆtre: 
	 */
	int	work_x = (G_wi_list_adr -> draw_ptr.tree) -> ob_x + AICON_OFFX;
	int	work_y = (G_wi_list_adr -> draw_ptr.tree) -> ob_y + AICON_OFFY;

	/*
	 * Proposition: 
	 */
		/*
		 * Dans la fenˆtre arbo: 
		 */
		int	prop_x, prop_y;		/* Coordonn‚es ‚cran */
		int	old_x=-1, old_y=-1;	/* Coord ‚cran ancien placement */
		int	line_style=0;			/* Style de trait pour la proposition */
		/*
		 * Sur le bureau: 
		 */
		int	last_spot=-1;			/* Dernier objet que l'on avait "allum‚" */
	
	/*
	 * Clipping des possibilit‚s de proposition: 
	 * On prend le rectangle le plus restreint entre la zone de travail
	 *		de la fenˆtre et la taille de la boŒte pŠre: 
	 */
		G_cliparray[ 0 ]	=	max( G_wi_list_adr -> work_x, work_x );
		G_cliparray[ 1 ]	=	max( G_wi_list_adr -> work_y, work_y );
		G_cliparray[ 2 ]	=	min( G_wi_list_adr -> work_x + G_wi_list_adr -> seen_w -1,
										work_x + (G_wi_list_adr -> draw_ptr.tree) -> ob_width -1 -WA_BORDER);
		G_cliparray[ 3 ]	=	min( G_wi_list_adr -> work_y + G_wi_list_adr -> seen_h -1,
										work_y + (G_wi_list_adr -> draw_ptr.tree) -> ob_height -1 -WA_BORDER);
		/*	printf("%d %d %d %d\n", G_cliparray[ 0 ], G_cliparray[ 1 ], G_cliparray[ 2 ], G_cliparray[ 3 ]); */
		
	/* 
	 * Simule "construction ‚cran" pour empˆcher l'AES de d‚rouler ses menus: 
	 */
	/* vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv */
	if( take_control == TAKE_CTRL )
	{
		start_WINDRAW( NULL );
	}

	/*
	 * Forme souris: 
	 */
	graf_mouse( FLAT_HAND, NULL );	/* Main ouverte */

	/*
	 * Calcule la zone ds laquelle peut se d‚placer le fant“me: 
	 */	
	area_x1 = G_x_mini;
	area_y1 = G_y_mini;
	area_x2 = G_x_mini + G_w_maxi - M_arboelt_w;	/* Taille de ce type */
	area_y2 = G_y_mini + G_h_maxi - M_arboelt_h;	/* d'ic“nes */
	
	/*
	 * Calcule offset entre ic“ne-start et pointeur de la souris: 
	 */
	offset_x = ob_x - start_x;
	offset_y = ob_y - start_y;

	/*
	 * Nouvelle position par d‚faut: 
	 */
	new_x = start_x;
	new_y = start_y;

	/*
	 * Fixe les paramŠtres de dessin VDI: 
	 */
	vsl_color( G_ws_handle, RED );					/* Couleur */		
	vswr_mode( G_ws_handle, MD_XOR );				/* Mode XOR */
	vsl_type( G_ws_handle, 7 );						/* Motif utilisateur */
			
	/*
	 * --------------------
	 * Boucle de mouvement: 
	 * --------------------
	 */
	do
	{	/*
		 * Cherche sur quoi se trouve le pointeur de la souris: 
		 */			
		new_handle = wind_find( new_x, new_y );

		/*
		 * Selon la fenˆtre "survol‚ee": 
		 */
		if ( new_handle == G_top_wi_handle )
		{	/*
			 * Si on est dans la fenˆtre concern‚e: 
			 */
			if ( new_x >= G_cliparray[ 0 ]
					&& new_y	>= G_cliparray[ 1 ]
					&& new_x	<= G_cliparray[ 2 ]
					&& new_y	<= G_cliparray[ 3 ] )
			{	/*
				 * Conversion des coordonn‚es ‚cran de la souris
				 * en coordonn‚es tableau de la case survol‚e: 
				 */
				*drop_x	= (new_x - work_x) /G_arbocell_w;	/* Coord X en emplacements */
				prop_x	= work_x + *drop_x * G_arbocell_w;	/* Coord X ‚cran */

				*drop_y	= (new_y - work_y) /G_arbocell_h;	/* Coord Y en emplacements */
				prop_y	= work_y + *drop_y * G_arbocell_h;	/* Coord Y ‚cran */

				/*
				 * Teste si la proposition … chang‚: 
				 */
				if ( old_x != prop_x || old_y != prop_y )
				{	/*
					 * Si la proposition … chang‚: 
					 * ParamŠtres VDI: 
					 */
					vs_clip( G_ws_handle, 1, G_cliparray );	/* Clipping sur work */
	
					/*
					 * Teste s'il faut effacer l'ancienne: 
					 */
					if ( old_x != -1 && line_style !=0 )
					{	/*
						 * S'il y avait d‚j… une proposition affich‚e: 
						 * Efface la proposition de placement: 
						 */
						vsl_type( G_ws_handle, line_style );	/* Type de trait */
						draw_proposition(); 
					}
	
					/*
					 * ------------------------------------------
					 * Teste si le nouveau placement est correct: 
					 * ------------------------------------------
					 */
					control_links( object_id, 
										*drop_x, *drop_y, 
										n_GridSrceX, n_GridSrceY,
										&line_style );
	
					if( line_style )
					{	/*
						 * S'il faut afficher 
						 * Fixe coordonn‚es du nouveau dessin: 
						 */
						for( i=1, j=0; i<=5; i++ )
						{
							G_pxyarray2[ j ]= prop_x + M_fantome_lien[ j++ ];
							G_pxyarray2[ j ]= prop_y + M_fantome_lien[ j++ ];
						}
		
						/*
						 * Dessin de la proposition de placement: 
						 */
						vsl_type( G_ws_handle, line_style );	/* Type de trait */
						draw_proposition(); 
		
					}							
	
					/*
					 * ParamŠtres VDI: 
					 */
					vsl_type( G_ws_handle, 7 );		/* Motif utilisateur */
					vs_clip( G_ws_handle, 0, G_cliparray );	/* Clipping OFF! */
	
					/*
					 * Nouvelle "ancienne" proposition: 
					 */
					old_x = prop_x;
					old_y	= prop_y;

				}
			}
		}
		else
		{	/*
			 * Si pas ds fen concern‚e: 
			 * Teste s'il faut effacer la proposition courante: 
			 */
			if ( old_x != -1 )
			{	/*
				 * S'il y avait une proposition: 
				 */

				if( line_style != 0 )
				{	/*
					 * Si elle ‚tait affich‚e: 
					 * ParamŠtres VDI: 
					 */
					vsl_type( G_ws_handle, line_style );	/* Type de trait */
					vs_clip( G_ws_handle, 1, G_cliparray );	/* Clipping sur work */
					/*
					 * Efface la proposition de placement: 
					 */
					draw_proposition(); 
					/*
					 * ParamŠtres VDI: 
					 */
					vsl_type( G_ws_handle, 7 );		/* Motif utilisateur */
					vs_clip( G_ws_handle, 0, G_cliparray );	/* Clipping OFF! */
				}
				
				/*
				 * Plus de proposition: 
				 */
				old_x = -1;
				old_y = -1;
			}											
		
			/*
			 * Teste ‚ventuellement les ic“nes du bureau: 
			 */
			sensitive_desk( new_x, new_y, NIL, &last_spot );
		}
	
		/*
		 * Coordonn‚es auxquelles il faut dessiner le fant“me: 
		 */
		fantome_x = new_x + offset_x;
		if ( fantome_x < area_x1 )
			fantome_x = area_x1;
		else if ( fantome_x > area_x2 )
			fantome_x = area_x2;
		
		fantome_y = new_y + offset_y;
		if ( fantome_y < area_y1 )
			fantome_y = area_y1;
		else if ( fantome_y > area_y2 )
			fantome_y = area_y2;
		
		/*
		 * Fixe coordonn‚es du dessin: 
		 */
		for( i=1, j=0; i<=5; i++ )
		{
			G_pxyarray[ j ]= fantome_x + M_fantome_lien[ j++ ];
			G_pxyarray[ j ]= fantome_y + M_fantome_lien[ j++ ];
		}
		
		/*
		 * --------------------
		 * Dessin du fant“me de l'ic“ne: 
		 * --------------------
		 */
		rig_draw_fantom(); 
			
		/*
		 * Attend qu'il se passe qque chose: 
		 */
		drag_evt=evnt_multi( MU_BUTTON | MU_M1,
								1, 1, 0,							/* Observe le relachement du bouton gauche */
                        1, new_x, new_y, 1, 1,		/* Observe tout d‚placement de la souris */ 
                        0, 0, 0, 0, 0,
                        0L, 
                        0, 0,
                        &new_x, &new_y, &new_bstate,
                        &kbd_state, &kbd_return,
                        &mouse_nbc);
		/*	printf("%d \r",new_bstate ); */

		/*
		 * Efface le fant“me de l'ic“ne: 
		 */
		rig_draw_fantom(); 
		
	} while( drag_evt != MU_BUTTON );

	
	/*
	 * Il faut remettre en place certains attributs de dessin: 
	 */
	vswr_mode( G_ws_handle, MD_REPLACE );			/* FIN Mode XOR */

	/*
	 * Si on … relach‚ sur une icone: 
	 */
	if ( last_spot != NIL )
	{	/*
		 * D‚s‚lectionne l'ic“ne destination: 
		 */
		modif_icon( G_desk_params_adr, last_spot, last_spot, NORMAL, CTRL_OK );	/* D‚S‚lectionne */
	}

	/*
	 * Fin du drag 
	 */
	graf_mouse(BUSYBEE, 0);			/* Change curseur souris */

	if( take_control == TAKE_CTRL )
	{
		end_WINDRAW();
	}
	/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ */

	/*
	 * Teste si on a relach‚ le fant“me … un emplacement valide: 
	 */
	/* printf( "Old_x=%d Last_spot=%d ", old_x, last_spot ); */
	if ( old_x != -1 )
	{ 	/*
		 * Si on a une proposition dans la fenetre: 
		 */
		switch ( line_style )
		{
			case	LSTYL_OK:
				return	POS_FREE_1;		
				
			case	LSTYL_REPLACE:
				return	POS_REPLACE_2;
		
			case	LSTYL_WRONG:
				return	POS_ISOLATED_3;

			case	LSTYL_WRONGREP:
				return	POS_WRONGREP_4;
	
			/* case LSTYL_NOWAY: */
			default:
				return	FALSE0;		/* Aucune dest valide */
		}
	}
	else if ( last_spot != NIL )
	{	/*
		 * Si on a d‚plac‚ vers une icone: 
		 */
		return	last_spot;			/* Retourne no de cette icone */
	}

	/*
	 * Par d‚faut: 
	 */
	return	FALSE0;			/* Aucune destination valide */

}




/*
 * control_links(-)
 *
 * Purpose:
 * --------
 * Contr“le si le placement propos‚ est correct
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 10.10.94: fplanque: V‚rifie position initiale
 * 11.10.94: ajout style LSTYL_WRONGREP
 */
void	control_links( 
			unsigned object_id, 
			int 		pos_x, 		/* In: Position propos‚e */
			int 		pos_y, 
			int		n_StartX,	/* In: Position initiale */
			int		n_StartY,
			int *		line_style )
{
	int			pos_error	=	0;		/* A priori, pas d'erreur de positionnement */
	/*
    * Adresse du map: 
	 */
	DIRSPEC	*	pDirSpec = G_wi_list_adr -> datadir -> dir_spec;
	unsigned	*	arbo_map = pDirSpec -> dir_map; /* Avant, on prenait le datadir, ds le content */
	unsigned		map_width = arbo_map[ 0 ];		/* Largeur du tableau */
	unsigned		map_height = arbo_map[ 1 ];	/* Hauteur du tableau */
	unsigned		concerned;				/* No/case concern‚e */

	/* printf("Pos: %d %d \n", pos_x, pos_y ); */

	/*
	 * Teste si les coordonn‚es de relƒchement sont ‚gales
	 * aux coordon‚es de d‚part:
	 */
	if( pos_x == n_StartX && pos_y == n_StartY )
	{	/*
		 * On n'autorise pas cette position:
		 */
		*line_style = LSTYL_NOWAY;
		return;
	}


	/*
	 * Contr“le lien North: 
	 */
	if (	object_id & IN_NORTH		/* Si nl objet … un lien IN au nord: */
		&& (	pos_y == 0					/* et si on est en ligne 0 */
			||	( (arbo_map[ (pos_y-1) * map_width + pos_x +2 ] & OUT_SOUTH) == 0 )
			)									/* ou objet au dessus n'a pas de lien OUT au sud */
		)
	{
		pos_error  = 1;			/* Il y a une erreur de lien */
	}

	/*
	 * Contr“le lien West: 
	 */
	concerned = pos_y * map_width + pos_x-1 +2;
	if (	object_id & IN_WEST	)	/* Si nl objet … un lien IN … l'ouest: */
	{
		if	(	pos_x == 0					/* et si on est en col 0 */
			||	( (arbo_map[ concerned ] & OUT_EAST) == 0 )
			)									/* ou objet … gauche n'a pas de lien OUT … l'est */
		{
			pos_error  = 1;			/* Il y a une erreur de lien */
		}
	}
	else if (	object_id & OUT_WEST	)	/* Si nl objet … un lien OUT … l'ouest: */
	{
		if (	pos_x == 0					/* et si on est en col 0 */
			|| (	arbo_map[ concerned ] != 0	/* ou case … gauche pas vide */
				&&	(arbo_map[ concerned ] & IN_EAST) == 0 /* et case a gauche ss entr‚e EST */
				)
			)
		{
			pos_error  = 1;			/* Il y a une erreur de lien */
		}
	}

	/*
	 * Contr“le lien East: 
	 */
	concerned = pos_y * map_width + pos_x+1 +2;
	if (	object_id & IN_EAST )	/* Si nl objet … un lien IN … l'est: */
	{
		if (	pos_x == map_width -1	/* et si on est en col maxi */
			||	( (arbo_map[ concerned ] & OUT_WEST) == 0 )
			)									/* ou objet … droite n'a pas de lien OUT … l'ouest */
		{
			pos_error  = 1;			/* Il y a une erreur de lien */
		}
	}
	else if ( object_id & OUT_EAST )	/* Si nl objet … un lien OUT … l'est: */
	{
		if (	pos_x == map_width -1	/* et si on est en col maxi */
			|| (	arbo_map[ concerned ] != 0	/* ou case … doite pas vide */
				&&	(arbo_map[ concerned ] & IN_WEST) == 0 /* ou case … droite ss entr‚e … l'OUEST */
				)
			)
		{
			pos_error  = 1;			/* Il y a une erreur de lien */
		}
	}

	/*
	 * Contr“le lien South: 
	 */
	concerned = (pos_y+1) * map_width + pos_x +2;
	if ( object_id & OUT_SOUTH 	/* Si nl objet … un lien OUT au sud: */
		&&	(	pos_y == map_height -1	/* et si on est en ligne maxi */
			|| (	arbo_map[ concerned ] != 0	/* ou case en dessous pas vide */
				&&	(arbo_map[ concerned ] & IN_NORTH) == 0 /* ou case au dessous ss entr‚e au nord */
				)
			)
		)
	{
		pos_error  = 1;			/* Il y a une erreur de lien */
	}

	/*
 	 * Case concern‚e 
	 */
	concerned = arbo_map[ pos_y * map_width + pos_x +2 ];
		
	/*
	 * Contr“le ‚ventualit‚ de remplacement: 
	 * (case d‚j… occup‚e)
	 */
	if( concerned != 0 )
	{	/*
		 * emplacement d‚j… utilis‚: 
		 */
		if( pos_error == 0 )
		{	/*
			 * Si pas d'erreur de liens:
			 */
			pos_error = 2;
		}
		else
		{	/*
			 * Non seulement, on va remplacer, mais en plus
			 * les liens sont incorrect pour la case targett‚e
			 */
			pos_error = 3;
		}
	}
	
	/*
	 * R‚agit en fonction de l'erreur 
	 */
	switch ( pos_error )
	{
		case 0:					/* pas d'erreur */
			*line_style = LSTYL_OK;			/* Tait continu */
			break;
			
		case 1:					/* Erreur de liens */
			*line_style = LSTYL_WRONG;		/* petits points */
			break;
			
		case 2:					/* Erreur de superposition */
			*line_style = LSTYL_REPLACE;	/* Longs Pointill‚s */
			break;
			
		case 3:					/* Erreur de superposition + de liens */
			*line_style = LSTYL_WRONGREP;	/* Pointill‚s */
			break;
			
		default:
			signale( "Ne peut d‚terminer autorisation de pos" );
	}

}


/*
 * link_arbo_to_parent(-)
 *
 * Purpose:
 * --------
 * Liaison d'une nouvelle page arbo … son pŠre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 17.12.94: impl‚ment‚ retour par sommaire, retour, envoi
 * 17.12.94: quelques liens descendants
 * 12.04.95: enhanced
 */
void	link_arbo_to_parent( 
			DATADIR *	datadir, 
			int 			pos_x, 
			int 			pos_y )
{
	DATAPAGE	*	pDataPage_curr = find_arbo_by_xy( datadir, pos_x, pos_y );
	PAGEARBO	*	pPageArbo_curr = pDataPage_curr -> data.pagearbo;
	int			ascent_x, ascent_y;		/* Coordonn‚es de l'ancˆtre */
	unsigned		u_ParentCell;
	int			n_FnctCurr = pPageArbo_curr -> fnct_no;
	int			n_FnctParent;

	/* printf("\033Y! "); */
	/* printf("Nouvelle page: %s\n", pDataPage_curr -> nom ); */

	/*
	 * Parcourt les liens en remontant … la recherche de l'ancˆtre 
	 *	de la page courante: 
	 */
	u_ParentCell = find_ascent( datadir, pos_x, pos_y, &ascent_x, &ascent_y );

	if( u_ParentCell & CT_ARBO )
	{	/*
		 * Si le parent est une page arbo (cas classique): 
		 */
		DATAPAGE	*	pDataPage_parent = find_arbo_by_xy( datadir, ascent_x, ascent_y );	/* Trouve le parent */
		PAGEARBO	*	pPageArbo_parent = pDataPage_parent -> data.pagearbo;
		n_FnctParent = pPageArbo_parent -> fnct_no;
		
		/*
		 * ------------------------------------
		 * Retour du descendant vers son parent
		 * ------------------------------------
		 * Certains parents ne sont pas vraiment pr‚vus pour un retour
		 * on s‚lectionne ici:
		 */
		switch( n_FnctParent )
		{
			case	FA_MENU:
			case	FA_LECT_MSG:
			case	FA_DISP_TEXT:
			case	FA_LIST:
			case	FA_DIRECTORY:
			case	FA_FILESEL:
				/*
				 * Ces types la acceptent le retour de bon coeur:
				 * Les possibilit‚s de retour sont diff‚rentes selon 
				 * le type de descendant...
				 *
				 * Retour par [SOMMAIRE]:
				 */
				CmdList_Replace1Content( pPageArbo_curr -> p_Events, 
							FL_SOMM, ACTION_NONE, ACTION_FULLCLS, NULL, pDataPage_parent -> nom );
		
				/*
				 * Retour par [RETOUR]:
				 */
				switch( n_FnctCurr )
				{
					case	FA_MENU:
					case	FA_DOWNLOAD:
						CmdList_Replace1Content( pPageArbo_curr -> p_Events, 
								FL_RETOUR, ACTION_NONE, ACTION_FULLCLS, NULL, pDataPage_parent -> nom );
				}
		
				/*
				 * Retour par [ENVOI]:
				 */
				switch( n_FnctCurr )
				{
					case	FA_ECRI_MSG:
					case	FA_NEW_ACCOUNT:
						CmdList_Replace1Content( pPageArbo_curr -> p_Events, 
								FL_ENVOI, ACTION_NONE, ACTION_FULLCLS, NULL, pDataPage_parent -> nom );
				}

				/*
				 * Retour par [ANNULATION]:
				 */
				switch( n_FnctCurr )
				{
					case	FA_DOWNLOAD:
						CmdList_Replace1Content( pPageArbo_curr -> p_Events, 
								FL_ANNUL, ACTION_NONE, ACTION_FULLCLS, NULL, pDataPage_parent -> nom );
				}
		}

		/*
		 * -----------------------------------
		 * Lien du parent vers son d‚scendant:
		 * -----------------------------------
		 * D‚pend du parent:
		 */
		switch( n_FnctParent )
		{
			case	FA_LECT_MSG:
			case	FA_ECRI_MSG:
			case	FA_ID:
			case	FA_NEW_ACCOUNT:
				/*
				 * Lien par ENVOI:
				 */
				CmdList_Replace1Content( pPageArbo_parent -> p_Events, 
						FL_ENVOI, ACTION_NONE, ACTION_FULLCLS, NULL, pDataPage_curr -> nom );
				break;

			case	FA_LIST:
				/*
				 * Lien par "Visu S‚lection":
				 */
				if( n_FnctCurr == FA_LECT_MSG )
				{
					CmdList_Replace1Content( pPageArbo_parent -> p_Events, 
						FL_WATCH, ACTION_NONE, ACTION_FULLCLS, NULL, pDataPage_curr -> nom );
				}
				break;

			case	FA_FILESEL:
				/*
				 * Lien par "Download S‚lection":
				 */
				if( n_FnctCurr == FA_DOWNLOAD )
				{
					CmdList_Replace1Content( pPageArbo_parent -> p_Events, 
						FL_DOWNLOAD, ACTION_NONE, ACTION_FULLCLS, NULL, pDataPage_curr -> nom );
				}
				break;

			case	FA_MENU:
			case	FA_DOWNLOAD:
				/*
				 * Ajoute un mot clef:
				 */
				break;
		}
		
	}
	else if( u_ParentCell & CT_INOUT )
	{	/*
	 	 * Si le parent est "IN": 
		 * 
		 * Lien 1stpage -> curr
	 	 */
		CmdList_Replace1Content( datadir -> dir_spec -> liens_in, 
						FL_FIRST, ACTION_NONE, ACTION_NONE, NULL, pDataPage_curr -> nom );
	}


	/*
	 * --------------------
	 * Parcourt les liens en descendant … la recherche
	 * de tous les descendants de l'ancˆtre: 
	 */
	/* find_children( datadir, ascent_x, ascent_y ); */

}



/*
 * find_ascent(-)
 *
 * Purpose:
 * --------
 * Trouve l'ancˆtre d'une page arbo
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 10.10.94: fplanque: prise en compte cases vides
 * 17.12.94: retourne cellule parent, traitement sur le parent pris en charge par l'appellant
 */
unsigned	find_ascent( 					/* Out: Contenu de la cellule parent */
				DATADIR *	datadir, 	/* In:  Dossier dans lequel on cherche */
				int 			pos_x, 		/* In:  Position de l'enfant */
				int 			pos_y, 
				int *			ascent_x, 	/* Out: Position du parent (meme si case vide) */
				int *			ascent_y )
{
	/*
	 * Variables: 
	 */
	DIRSPEC	*	pDirSpec = datadir -> dir_spec;
	unsigned		map_width = (pDirSpec -> dir_map)[ 0 ];
	unsigned	*	dir_map	= &(pDirSpec -> dir_map)[ 2 ];
	unsigned		curr_link;

	/*
	 * Positionne sur lien pr‚c‚dent la page courante: 
	 */
	pos_y --;
	
	/*
	 * Parcourt les liens … l'envers jusqu'au parent: 
	 */
	while
	(
		curr_link = dir_map[ pos_y * map_width + pos_x ],
		((curr_link & (CT_ARBO|CT_INOUT)) == 0) 
		&&	curr_link != 0
		&& (pos_x >= 0) && (pos_y >= 0)  /* Anti bug */
	)
	{	/*
		 * Tant qu'on est sur un lien: 
		 */
		/* printf("Lien pr‚c‚dent: %d %d  %X\n", pos_x, pos_y, curr_link); */
		
		/*
		 * Analyse d'o— vient le lien:
		 * ON CONSIDERE QU'IL N'Y A QU'UN SEUL "IN": 
		 */
		if ( curr_link & IN_NORTH )
			pos_y --;		/* Remonte */
		else if ( curr_link & IN_WEST )
			pos_x --;		/* Retourne … gauche */
		else if ( curr_link & IN_EAST )
			pos_x ++;		/* Retourne … droite */
		else
			signale("Lien inconnu!");
	}

	/*
	 * Fixe les coordonn‚es de l'ancˆtre: 
	 */
	*ascent_x = pos_x;
	*ascent_y = pos_y;

	/* printf("PARENT: %d %d  %X\n", pos_x, pos_y, curr_link); */

	return	curr_link;
}



/*
 * find_children(-)
 *
 * Purpose:
 * --------
 * Trouve les descendants d'une page arbo
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	find_children( 
			DATADIR *datadir, 
			int pos_x, 
			int pos_y )
{
	DIRSPEC	*	pDirSpec = datadir -> dir_spec;

	M_walker_datadir	= datadir;	/* Fixe variable globale */
	M_walker_mapwidth	= pDirSpec -> dir_map[0];
	M_walker_map		= &(pDirSpec -> dir_map[2]);

	walk_arbotree( pos_x, pos_y+1 );
}




/*
 * walk_arbotree(-)
 *
 * Purpose:
 * --------
 * Descend toutes les branches d'une arbo a partir d'une
 * position donnée
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	walk_arbotree( int pos_x, int pos_y )
{
	unsigned	curr_link;
	int		nb_branches;		/* Nombre de branches */
	int		last_x, last_y;
	
	
	/*
	 * Compte nombre de branches: 
	 */
	do
	{
		curr_link = M_walker_map[ pos_y * M_walker_mapwidth + pos_x ];
		/*	printf("Lien: %X \n", curr_link ); */
		last_x = pos_x;
		last_y = pos_y;
		nb_branches = 0;

		/*
		 * Teste si on est arriv‚ sur une page ou OUT: 
		 */
		if( curr_link & (CT_ARBO|CT_INOUT) )
		{
			/* printf("Terminaison: "); */

			if ( curr_link & CT_ARBO )
			{	/* Si on a trouv‚ un enfant: */
				DATAPAGE *child_page = find_arbo_by_xy( M_walker_datadir, pos_x, pos_y );	/* Trouve l'enfant */
				/* printf("Enfant: %s \n", child_page -> nom ); */
				FAKE_USE( child_page );
			}
			else if ( curr_link & CT_INOUT )
			{	/* Si on a trouv‚ un "OUT": */
				/* printf("'OU'\n"); */
			}
			break;		/* On arrˆte la recherche */
		}
		
		/*
		 * Teste lien vers la gauche: 
		 */
		if ( curr_link & OUT_WEST )
		{
			nb_branches ++;
			pos_x --;			/* Si une seule branche, ce sera … gauche */
		}
		
		/*
		 * Teste lien vers le bas: 
		 */
		if ( curr_link & OUT_SOUTH )
		{
			nb_branches ++;
			pos_y ++;			/* Si une seule branche, ce sera en bas */
		}
		
		/*
		 * Teste lien vers la droite: 
		 */
		if ( curr_link & OUT_EAST )
		{
			nb_branches ++;
			pos_x ++;			/* Si une seule branche, ce sera … doite */
		}
	}
	while( nb_branches == 1 );		/* Jusqu'… 1 Fourche ou case vide */

	/*
	 * Teste si on est sur une fourche: 
	 */
	if ( nb_branches > 1 )
	{	/* Si on est sur une fourche: */
		/*	printf("Fourche! "); */
		/* On va parcourir les branches une … une: */
		if ( curr_link & OUT_WEST )
			walk_arbotree( last_x -1 , last_y );	/* R‚cursion */

		if ( curr_link & OUT_SOUTH )
			walk_arbotree( last_x , last_y +1 );	/* R‚cursion */

		if ( curr_link & OUT_EAST )
			walk_arbotree( last_x +1 , last_y );	/* R‚cursion */
		
	}
}



/*
 * free_specialpar(-)
 *
 * Purpose:
 * --------
 * Efface les paramŠtres sp‚ciaux d'une pge arbo
 *
 * History:
 * --------
 * 10.05.94: fplanque: Created
 * 27.03.95: libŠre params FILESEL
 * 09.04.95: passage union par adresse pour ‚viter warning
 */
void	free_specialpar( 
			int					n_fnct,				/* Type de page */
			ARBO_SPECIALPAR *	special_par )
{
	if( special_par -> data != NULL )
	{
		switch( n_fnct )
		{
			case	FA_FILESEL:
				free_String( special_par -> filesel -> pMsz_RootPath );
				break;
		}

		FREE( special_par -> data );
	}
}

