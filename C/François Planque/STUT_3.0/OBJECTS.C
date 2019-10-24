/*
 * objects.c
 *
 * Purpose:
 * --------
 * Routines de traitement des objets/arbres AES
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"OBJECTS.C v1.05 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>
	#include	<string.h>					/* strlen() etc.. */
	#include	<stdlib.h>					
	#include	<aes.h>						/* header AES */
   

/*
 * Custom headers:
 */
	#include "SPEC_PU.H"
	#include "S_MALLOC.H"
	#include "STUT_ONE.RSC\STUT_3.H"		/* noms des objets ds le ressource */
	#include	"TEXT_PU.H"				/* Params texte VDI */
	#include	"DTDIR_PU.H"	
	#include	"DATPG_PU.H"	
	#include	"DESK_PU.H"			/* Stockage des ic“nes manipul‚es */
	#include "COLORDEF.H"				/* Couleurs … utiliser */
	#include "AESDEF.H"
	#include	"DEBUG_PU.H"	
	#include	"OBJCT_PU.H"	
	#include	"MAIN_PU.H"	
	#include "VDI_PU.H"
	#include	"WIN_PU.H"	
	#include	"WINDR_PU.H"	

/*
 * ------------------------ VARIABLES -------------------------
 */
	
/*
 * External variables: 
 */
	/* 
	 * VDI: 
	 */
	extern	int		G_ws_handle;			/* handle virtual workstation VDI */
	extern	int 		G_pxyarray[18];		/* Liste de coord X,Y pour le VDI */
	extern	MFDB		G_plogMFDB;				/* block ‚cran logique */
	extern	int		G_nb_bitplanes;		/* Nbre de plans graphiques */
	extern	int		G_nb_colors;			/* Nbre de couleurs simultan‚es */
	extern	VDI_TEXT_PARAMS	G_std_text;	/* ParamŠtres du texte standard */	
	/* 
	 * Tampon AES: 
	 */
	extern	char		*G_tampon_aes;			/* Adr tampon */
	extern	size_t	G_long_tampon;			/* Longueur de ce tampn */
	extern	MFDB		G_tamponMFDB;				/* MFDB pour le tampon AES */
	/* 
	 * Config: 
	 */
	extern	int		G_cnf_cope_with_ltf;	/* Contourner les bugs de Let'em Fly */


/*
 * Public variables: 
 */
	/* 
	 * Buffer AES: 
	 */
	int		G_stock_tampon;					/* Nre de lignes stock‚es dans le tamp AES */
	char	*	G_tampon_supp;					/* Tampon suppl‚mentaire */

	
/*
 * Private variables: 
 */
	/* 
	 * Objets: 
	 */
	static	OBJECT	M_single_box=						/* Boite pŠre d'un directory */
				{-1, -1, -1, G_BOX, NONE, NORMAL, 0xFF1112L, 0,0, 10000, 10000};
	static	OBJECT	M_icone=							/* Ic“ne */
				{-1, -1, -1, G_ICON, SELECTABLE | OUVRABLE, NORMAL, 0L, 0,0, 10, 3};
	static	ICONBLK	M_iconblk =
				{(int*)2L, (int*)3L, NULL, 4096,0,0, 24,34-28,32,28, 4,36,72,8}; 
	/* 
	 * Gestion des formulaires: 
	 */
	/* Niveau de r‚cursion dans l'ouverture de formulaires: */
	static	M_form_recurse_depth = 0;		/* Au d‚but: aucun formulaire ouvert */
	/* 
	 * Maptree: 
	 */
	static	int	M_enable_menu;				/* Faut il faire un enbale ou disable du menu */
	 
 
/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * init_objects(-)
 *
 * Purpose:
 * --------
 * Init des objets en RAM
 *
 * History:
 * --------
 * fplanque: Created
 */
void init_objects( void )
{
	TRACE0( "Initializing " THIS_FILE );

	/*
	 * Fixe taille de l'ic“ne g‚n‚rique: 
	 */
	M_icone .ob_width  = G_icon_w;
	M_icone .ob_height = G_icon_h;

	/*
	 * Donne des valeurs par d‚faut … l'iconblk:
	 * Ces valeurs sont reprises sur le desktop et tiennent compte de la r‚solution:
	 */
	M_iconblk = *(G_desktop_adr[ DSTTERM ] .ob_spec.iconblk);

	/*
	 * Couleur pŠre de directory: 
	 */
	if( G_nb_colors >= 16 )
	{
		M_single_box .ob_spec.obspec .fillpattern = DIR_PATTERN_16;
		M_single_box .ob_spec.obspec .interiorcol = DIR_COLOR_16;
	}
	else if( G_nb_colors >= 4 )
	{
		M_single_box .ob_spec.obspec .fillpattern = DIR_PATTERN_4;
	}
}



/*
 * rsrc_color(-)
 *
 * Purpose:
 * --------
 * Corrige la taille de certains objets
 * Peint les boites de dialogue en couleur quand c'est esth‚tiquement possible (!)
 *
 * History:
 * --------
 * fplanque: Created
 * 29.08.94: parxourt l'arbe mˆme en mono, en effet on ne s'occupe plus seulement de la couleur
 */
void rsrc_color( OBJECT *tree )
{
	maptree( tree, ROOT, NIL, objc_color );
}



/*
 * objc_color(-)
 *
 * Purpose:
 * --------
 * Fixe la couleur et autres attributs 
 * d'un objet
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 29.08.94: fplanque: Gestion des GROUPTITLEs
 * 02.10.94: gestion des RESIZE_OBJECT
 * 02.02.95: gestion ic“nes moyenne r‚solution
 * 28.03.95: ajout traitement des userdefs bouton croix
 */
int	objc_color( 
			OBJECT *	tree, 
			int		objc )
{
	ICONBLK * pIconBlk;
	int	ob_height;
	int	ob_type 	= tree[ objc ] .ob_type;	/* Type de l'objet */
	int	real_type = ob_type & 0x00FF;
	int	ob_flags = tree[ objc ] .ob_flags;	/* Flags de l'objet */
	int	ob_state = tree[ objc ] .ob_state;	/* State de l'objet */

	if( ob_state & RESIZE_OBJECT /* = BOUTON_CROIX */ )
	{	/*
		 * D‚termine le type d'objet pour savoir quel traitement
		 * il faut effectuer:
		 */
		switch( real_type )
		{
			case	G_BOX:
				/*
				 * Il faut mettre en userdef BOUTON_CROIX:
				 */
				tree[ objc ].ob_spec.userblk = &G_bcroix_ublk;
				tree[ objc ].ob_type = G_USERDEF ;
				break;

			case	G_TEXT:
			case	G_BOXTEXT:
				/*
				 * S'il s'agit d'un titre de groupe:
				 * on va diminuer la hauteur de l'objet:
		 	 	 */
		 	 	tree[ objc ] .ob_y += 4;
				tree[ objc ] .ob_height -= 8;
				break;

			case	G_IMAGE:
				/*
				 * S'il s'agit d'un objet image a qui on veut donner
				 * exactement la largeur du bitmap:
				 */
				tree[ objc ] .ob_height = tree[ objc ] .ob_spec.bitblk -> bi_hl;
				break;
				 
			case	G_ICON:
				/*
				 * S'il s'agit d'une ic“ne:
				 * On augmente la taille verticale … l'equiv de 3 caractŠres
				 */ 
				ob_height = G_std_text .cell_h * 3;
				tree[ objc ] .ob_height = ob_height;
				
				/*
				 * Modifie positions du texte et de l'icone dans l'objet
				 */
				pIconBlk = tree[ objc ] .ob_spec.iconblk;
	
				#if ACCEPT_SMALLFONTS
					if( G_cell_size_prop == 1 )
					{	/*
						 * Moyenne r‚solution
						 */
						pIconBlk -> ib_ytext = ob_height - 8;
						pIconBlk -> ib_yicon = ob_height - 8 - pIconBlk -> ib_hicon;
					}
					else
					{	/*
						 * haute
						 */
						pIconBlk -> ib_ytext = ob_height - 10;
						pIconBlk -> ib_yicon = ob_height - 14 - pIconBlk -> ib_hicon;
					}
				#else
					/*
					 * On peut consid‚rer qu'on est en haute:
					 */
					pIconBlk -> ib_ytext = ob_height - 10;
					pIconBlk -> ib_yicon = ob_height - 14 - pIconBlk -> ib_hicon;
				#endif		

				break;
			
		}
	}

	if( !(ob_flags & RELIEF1) && ob_flags & RELIEF2 )
	{	
	
		if( G_nb_colors >= 16 )
		{	/*
			 * S'il faut peindre le fond en gris: 
			 */
			switch ( ob_type )
			{
				case	G_BOX:
				case	G_BOXCHAR:
					tree[ objc ] .ob_spec.obspec .fillpattern = FORM_PATTERN_16;
					tree[ objc ] .ob_spec.obspec .interiorcol = FORM_COLOR_16;
					break;
	
				case	G_BOXTEXT:
				case	G_FBOXTEXT:
				{
					TE_COLOR		te_color;
					te_color.value = tree[ objc ] .ob_spec.tedinfo -> te_color;
					te_color.bf .fillpattern = FORM_PATTERN_16;
					te_color.bf .interiorcol = FORM_COLOR_16;
					tree[ objc ] .ob_spec.tedinfo -> te_color = te_color.value;
					break;
				}
			}
		}

#if COLOR_TEST
		else if( G_nb_colors >= 4 )
		{	/*
			 * S'il faut peindre le fond en gris: 
			 */
			switch ( ob_type )
			{
				case	G_BOX:
				case	G_BOXCHAR:
					tree[ objc ] .ob_spec.obspec .fillpattern = FORM_PATTERN_4;
					tree[ objc ] .ob_spec.obspec .interiorcol = FORM_COLOR_4;
					break;
	
				case	G_BOXTEXT:
				case	G_FBOXTEXT:
				{
					TE_COLOR		te_color;
					te_color.value = tree[ objc ] .ob_spec.tedinfo -> te_color;
					te_color.bf .fillpattern = FORM_PATTERN_4;
					te_color.bf .interiorcol = FORM_COLOR_4;
					tree[ objc ] .ob_spec.tedinfo -> te_color = te_color.value;
					break;
				}
			}
		}
#endif

	}

	return	TRUE_1;
}



/*
 * ctrl_icon(-)
 *
 * Purpose:
 * --------
 * Contr“le si un point de l'‚cran appartient … une ic“ne(1) ou non(0)
 *
 * History:
 * --------
 * fplanque: Created
 */
int	ctrl_icon( OBJECT *tree, int	object, int	check_x, int check_y )
{
	int	icon_x, icon_y;

	/* Adresse de l'objet-ic“ne: */
	OBJECT	*obj_adr = &( tree[object] );

	/* Adresse des infos sur l'ic“ne: */
	ICONBLK *iconblk_adr = obj_adr -> ob_spec. iconblk;

	/* Coordonn‚es de l'objet-ic“ne: */
	objc_offset( tree, object, &icon_x, &icon_y );

	/*
	 * Contr“le:
	 * Ce contr“le considŠre que le texte se situe imm‚diatement
	 *	AU DESSOUS de l'image de l'ic“ne! 
	 */
	if ( check_y >= icon_y + (iconblk_adr -> ib_yicon) )
	{	/* Au dessous du haut de l'image: */
		if (	check_y >= icon_y + (iconblk_adr -> ib_ytext) )	
		{ /* Au dessous du haut du texte: */
			if ( check_y < icon_y + (iconblk_adr -> ib_ytext) + (iconblk_adr -> ib_htext) )
			{	/* Dans le texte: */
				if (	check_x >= icon_x + (iconblk_adr -> ib_xtext)
					&&	check_x <  icon_x + (iconblk_adr -> ib_xtext) + (iconblk_adr -> ib_wtext) )
					return	1;
			}
		}
		else
		{	/* Dans l'image: */
			if (	check_x >= icon_x + (iconblk_adr -> ib_xicon)
				&&	check_x <  icon_x + (iconblk_adr -> ib_xicon) + (iconblk_adr -> ib_wicon) )
				return	1;
		}
	}
	return	0;
}



/*
 * deselect_current(-)
 *
 * Purpose:
 * --------
 * D‚selectionne l'ic“ne du bureau 
 * ou d'une fenˆtre actuellement s‚lectionn‚e
 *
 * History:
 * --------
 * fplanque: Created
 */
void	deselect_current( void )
{
	if ( G_selection_adr != NULL )
	{	/*
		 * S'il y a une ic“ne s‚lectionn‚e: 
		 */
		OBJECT	*tree = G_selection_adr -> draw_ptr.tree;
		int		selected_object = G_selection_adr -> selected_icon;
		int		start_obj;
		/*
		 * Teste … partir de o— il faut r‚afficher: 
		 */
		if (	G_cnf_cope_with_ltf == TRUE_1 		/* Si on veut contourner les bugs de let'm fly */
			|| tree[selected_object] .ob_type == G_IMAGE )  /* S'il s'agit d'une IMAGE */
		{	/*
			 * S'il faut r‚afficher l'objet en dessous 
			 * de celui qui nous int‚resse: 
			 */
			start_obj = objc_parent( tree, selected_object );	/* On va aussi redessiner le parent sous l'icone */
		}
		else
		{
			start_obj = selected_object;	/* On ne red‚ssine que l'ic“ne elle mˆme */
		}
		/*
		 * R‚affiche: 
		 */
		modif_icon( G_selection_adr, start_obj, selected_object, NORMAL, TAKE_CTRL );

		/*
		 * Signale qu'il n'y a plus rien de s‚lectionn‚: 
		 */
		no_selection();
	}
}



/*
 * modif_icon(-)
 *
 * Purpose:
 * --------
 * Modifie l'‚tat s‚lectionn‚/d‚selectionn‚ d'une ic“ne du bureau ou d'une fenˆtre
 *
 * History:
 * --------
 * fplanque: Created
 */
void modif_icon( 
		WIPARAMS * params_adr, 
		int start_ob, 
		int icon, 
		int selected, 
		int take_control )
{
	OBJECT	* tree_adr = params_adr -> draw_ptr .tree;  /* Pointeur sur arbe d'objets */

	/*
	 * Modifie l'‚tat de l'objet: 
	 */
	if ( selected )
	{
		tree_adr[icon].ob_state |= SELECTED;	/* S‚lectionne l'ic“ne */
	}
	else
	{
		tree_adr[icon].ob_state &= ~SELECTED ;	/* D‚s‚lectionne l'ic“ne */
	}

	/*
	 * Teste si on a affaire … un formulaire partag‚: 
	 */
	if ( params_adr -> type == TYP_TREE )
	{	/* Si positionnement n‚cessaire: */
		fixform_window( params_adr );		/* Fixe nlle position formulaire */
	}


	/*
	 * R‚affiche l'ic“ne: 
	 */
	redraw_icon( params_adr, start_ob, icon, take_control );
		
}



/*
 * redraw_icon(-)
 *
 * Purpose:
 * --------
 * R‚affiche une ic“ne du bureau ou d'une fenˆtre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	redraw_icon( 
			WIPARAMS *	params_adr, 
			int 			start_ob, 
			int 			icon, 
			int 			take_control )
{
	GRECT		obj_box;					/* Coordonn‚es de l'objet */
	int		xr, yr, wr, hr;
	OBJECT	* tree_adr = params_adr -> draw_ptr .tree;  /* Pointeur sur arbe d'objets */
	int		handle =	params_adr -> handle;		/* Handle de la "fenˆtre" au sens global */

	/*
	 * D‚termine les coordonn‚es de l'objet: 
	 */
	objc_xywh( tree_adr, icon, &obj_box );

	/*
	 * On va r‚afficher l'ic“ne, cependant, comme elle peut ˆtre
	 * recouverte par une (autre) fenˆtre, on doit proc‚der par un redraw
	 * de la fenˆtre … modifier, on cherche donc les intersections de cette
	 * fenˆtre visible avec l'ic“ne … modifier... 
	 */

	/*
	 * Auparavant, on s'assure que la liste des rectangles ne va pas bouger 
	 */
	if( take_control == TAKE_CTRL )
	{	/*
	 	 * Si l'application n'a pas encore pris le contr“le de l'‚cran 
		 * ... on le fait maintenant: 
		 */
		start_WINDRAW( NULL );
	}

	/* printf("Arbre=%lu start=%d\n", tree_adr, start_ob ); */

	/*
	 * Parcourt les rectangles de la fenˆtre concern‚e: 
	 */
	wind_get( handle, WF_FIRSTXYWH, &xr, &yr, &wr, &hr ); /* Premier rectangle */
	while ( wr && hr )					/* Tant que dimensions non nulles */
	{
		if ( rcintersect ( G_x_mini, G_y_mini, G_w_maxi, G_h_maxi, &xr, &yr, &wr, &hr ) )
		{	/* Si rectangle est dans l'‚cran */
			if ( rcintersect( obj_box .g_x, obj_box .g_y, obj_box .g_w, obj_box .g_h, &xr, &yr, &wr, &hr ) )
			{	/* Si rect est dans la zone de redraw */
				objc_draw( tree_adr, start_ob, 4, xr, yr, wr, hr ); /* Affiche ic“ne */
			}
		}
		wind_get( handle, WF_NEXTXYWH, &xr, &yr, &wr, &hr ); /* Rectangle suivant */
	}

	/*
	 * Peut-ˆtre faut il signaler la fin de la construction de l'‚cran: 
	 */
	if( take_control == TAKE_CTRL )
	{	/* Si l'application a pris le contr“le de l'‚cran juste pour redessiner l'ic“ne */
		/* ... on le rends maintenant: */
		end_WINDRAW();
	}

}




/*
 * sensitive_desk(-)
 *
 * Purpose:
 * --------
 * Hot-Spot des ic“nes du bureau lors d'un drag_[arbo]icon
 *
 * History:
 * --------
 * fplanque: Created
 */
void	sensitive_desk( 
			int new_x, 
			int new_y, 
			int start_obj, 
			int *actual_spot )
{
	/*
	 * Variables locales: 
	 */
	OBJECT	*tree_adr = G_desktop_adr;	/* Arbre sur lequel on opŠre */
													/* Ds cette version: tjs le bureau */
	int	last_spot = *actual_spot;		/* Dernier objet hot-spot */
	int	new_object;		/* Objet sur lequel se trouve actuelmnt la souris */

	/* Determine quel est l'objet sous le csr souris: */
	new_object= objc_find( tree_adr, 0, 1, new_x, new_y );
	/* Au cas on on serait hors du bureau: i.e. dans la barre de menu! */
	if( new_object == NIL )
	{	/* Si on est hors arbre d'objets: */
		new_object = ROOT;	/* On fait comme si on ‚tait sur le fond du bureau... */		
	}

	/* Cas d'une ic“ne: v‚rifie qu'on est sur l'image ou le texte... */
	if ( tree_adr[ new_object ] .ob_type == G_ICON )
	{
		if ( !ctrl_icon( tree_adr, new_object, new_x, new_y ) )
		{	/* Si on a seulement cliqu‚ PRES d'une ic“ne: */
			new_object = 0;	/* ATTENTION: Valable uniquement pour desktop */
 		}
	}

	/* Teste si on a fait un d‚placement significatif */
	if ( new_object != last_spot )
	{	/* Si on a chang‚ d'objet: */
		if ( last_spot != -1 )
		{	/* S'il y avait un objet s‚lectionn‚: */
				modif_icon( G_desk_params_adr, last_spot, last_spot, NORMAL, CTRL_OK );	/* D‚S‚lectionne l'ancienne ic“ne */
				*actual_spot = -1;						/* Plus d'ic“ne s‚lectionn‚e */
		}
		if ( new_object != start_obj )
		{	/* Si on est pas sur l'ic“ne de d‚part */
			if ( tree_adr[ new_object ] .ob_flags & SELECTED )
			{	/* Si on arrive sur un objet pouvant ˆtre s‚lectionn‚ */
				modif_icon( G_desk_params_adr, new_object, new_object, SELECTED, CTRL_OK );	/* S‚lectionne la nouvelle ic“ne */
				*actual_spot = new_object;		/* Nlle ic“ne s‚lectionn‚e */
			}
		}
	}
}

/*
 * ------------------------ MAPTREE -------------------------
 */


/*
 * maptree(-)
 *
 * Purpose:
 * --------
 * MapTree
 *
 * Algorythm:
 * ----------  
 * Cette routine va traverser l'arbre
 * depuis l'objet THIS jusqu'au LAST
 *
 * History:
 * --------
 * 1993: fplanque: Created based on Pro-GEM
 */
void	maptree( 
			OBJECT *	tree, 												/* In: arbre … parcourir */
			int 		this,											 		/* In: Premier obj … visiter */
			int 		last, 												/* In: dernier obj a visiter */
			int 		(*routine)( OBJECT *tree, int tmp1 ) )		/* In: Fnct … appeller pour chaque objet */
{

	int	tmp1 = this;		/* Dernier parent visit‚ */
	
	while( this != last && this != -1 )
	{
		if ( tree[ this ] .ob_tail != tmp1 )
		{
			tmp1 = this;
			this = -1;
			if( (*routine)( tree, tmp1 ) )
			{	/*
			 	 * Si routine … r‚pondu TRUE
			 	 */
				this = tree[ tmp1 ] .ob_head;
			}
			if ( this == -1 )
			{
				this = tree[ tmp1 ] .ob_next;
			}
		}
		else
		{
			tmp1 = this;
			this = tree[ tmp1 ] .ob_next;
		}
	}
}
 
 
 
/*
 * objc_sel(-)
 * objc_dsel(-)
 * objc_toggle(-)
 * objc_clrsel(-)
 * objc_setsel(-)
 * objc_fixsel(-)
 *
 * Purpose:
 * --------
 * S‚lection d‚selection d'un objet
 *
 * History:
 * --------
 * fplanque: Created
 * 10.05.94: fplanque: Added objc_fixsel()
 */
void	objc_sel( OBJECT *tree, int obj )
{
	if	( !(tree[ obj ] .ob_state & SELECTED) )
		objc_toggle( tree, obj );
}
void	objc_dsel( OBJECT *tree, int obj )
{
	if	( tree[ obj ] .ob_state & SELECTED )
		objc_toggle( tree, obj );
}
void	objc_toggle( OBJECT *tree, int obj )
{
	int	state, newstate;
	GRECT	root;
	
	objc_xywh( tree, 0, &root );
	state		= tree[ obj ] .ob_state;
	newstate	= state ^ SELECTED;
	objc_change( tree, obj, 0, root .g_x, root .g_y, root .g_w, root .g_h, newstate, 1 );
}
void	objc_clrsel(  OBJECT *tree, int obj )
{
	tree[ obj ] .ob_state &= ~SELECTED;
}
void	objc_setsel(  OBJECT *tree, int obj )
{
	tree[ obj ] .ob_state |= SELECTED;
}
void	objc_fixsel( 
			OBJECT*	pObj_tree, 	/* In: Arbre dans lequel on agit */
			int 		n_obj,		/* In: Objet sur lequel on agit */
			int		n_state )   /* In: 0=d‚selection, autre selectionne */
{
	if( n_state )
	{	/* S‚lection: */
		pObj_tree[ n_obj ] .ob_state |= SELECTED;
	}
	else
	{	/* D‚s‚lection: */
		pObj_tree[ n_obj ] .ob_state &= ~SELECTED;
	}
}



/*
 * objc_testsel(-)
 *
 * Purpose:
 * --------
 * Teste si un objet est s‚lectionn‚
 *
 * History:
 * --------
 * 10.05.94: fplanque: Created
 * 24.09.94: retourne BOOL
 */
BOOL	objc_testsel( 				/* Out: !=0 si s‚lectionn‚ */
			OBJECT *	pObj_tree, 	/* In: Arbre dans lequel on teste */
			int 		n_obj )		/* In: Objet sur lequel on teste */
{
	return ( (pObj_tree[ n_obj ] .ob_state & SELECTED) ? TRUE_1 : FALSE0 );
}


         

/*
 * objc_enable(-)
 * objc_disable(-)
 * objc_setenable(-) 
 * objc_setdisable(-)
 * objc_fixable(-)
 *
 * Purpose:
 * --------
 * Enable-Disable d'un objet
 *
 * History:
 * --------
 * fplanque: Created
 */
void	objc_enable( OBJECT *tree, int obj )
{
	int	state = tree[ obj ] .ob_state;

	if ( state & DISABLED )
	{	/* Slt si l'objet est DISABLED: */
		GRECT	root;

		objc_xywh( tree, ROOT, &root );
		objc_change( tree, obj, 0,
						 root .g_x, root .g_y, root .g_w, root .g_h,
						 (state ^ DISABLED), 1 );
	}

};
void	objc_disable( OBJECT *tree, int obj )
{
	int	state = tree[ obj ] .ob_state;

	if ( !(state & DISABLED) )
	{	/* Slt si l'objet n'est *PAS* DISABLED: */
		GRECT	root;

		objc_xywh( tree, ROOT, &root );
		objc_change( tree, obj, 0,
						 root .g_x, root .g_y, root .g_w, root .g_h,
						 (state | DISABLED), 1 );
	}
}
void	objc_setenable( OBJECT *tree, int obj )
{
	tree[ obj ] .ob_state &= ~DISABLED;
}
void	objc_setdisable( OBJECT *tree, int obj )
{
	tree[ obj ] .ob_state |= DISABLED;
}
void	objc_fixable( OBJECT *tree, int obj, int enable )
{
	if ( enable )
		tree[ obj ] .ob_state &= ~DISABLED;
	else
		tree[ obj ] .ob_state |= DISABLED;	

}


/*
 * objc_TestEnable(-)
 *
 * Purpose:
 * --------
 * Teste si un objet est s‚lectionn‚
 *
 * History:
 * --------
 * 22.11.94: fplanque: Created
 */
BOOL	objc_TestEnable( 			/* Out: !=0 si s‚lectionn‚ */
			OBJECT *	pObj_tree, 	/* In: Arbre dans lequel on teste */
			int 		n_obj )		/* In: Objet sur lequel on teste */
{
	return ( (pObj_tree[ n_obj ] .ob_state & DISABLED) ? FALSE0 : TRUE_1 );
}



/*
 * ------------------- ENABLE/DISABLE MENU -------------------
 */


/*
 * enable_menu(-)
 * enable_menuitem(-)
 *
 * Purpose:
 * --------
 * Enable_disable d'un ‚l‚ment menu
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	enable_menu( OBJECT *menu_adr, int enable )
{
	M_enable_menu = enable;

	maptree( menu_adr, ROOT, NIL, enable_menuitem );

}
int	enable_menuitem( OBJECT *tree, int objc )
{
	if( tree[ objc ] .ob_flags & MENU_DIS )
	{	/* Si l'objet est concern‚: */
		/*	printf("%s\n", tree[ objc ] .ob_spec.free_string ); */

		if ( tree[ objc ] .ob_type == G_TITLE )
		{	/* Si c'est un titre: */
			if ( M_enable_menu )
				objc_enable( tree, objc );
			else
				objc_disable( tree, objc );
		}
		else
		{	/* Si c'est un ‚l‚ment: */
			menu_ienable( tree, objc, M_enable_menu? 1:0 );
		}
	}
	
	return	TRUE_1;
}



/*
 * ------------------------ - -------------------------
 */



/*
 * open_dialog(-)
 *
 * Purpose:
 * --------
 * Ouvre une boite de dialogue
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	open_dialog( OBJECT *dialog, const GRECT *little_box, GRECT *big_box )
{
	form_center( dialog, &big_box -> g_x, &big_box -> g_y, &big_box -> g_w, &big_box -> g_h );

	if ( M_form_recurse_depth == 0 )
	{	/*
		 * S'il n'y a pas encore de formulaire ouvert: 
		 * On d‚clare cette ouverture … l'AES: 
		 */
		form_dial( FMD_START, 0, 0, 0, 0,
			big_box -> g_x, big_box -> g_y, big_box -> g_w, big_box -> g_h );
		/*printf("\033Y  F"); */
	}
	
	form_dial( FMD_GROW, little_box -> g_x, little_box -> g_y, little_box -> g_w, little_box -> g_h,
		big_box -> g_x, big_box -> g_y, big_box -> g_w, big_box -> g_h );
	objc_draw( dialog, 0, 5, big_box -> g_x, big_box -> g_y, big_box -> g_w, big_box -> g_h );
	graf_mouse( ARROW, 0);	/* souris: FlŠche */

	/*
	 * On a ouvert un formulaire de plus par dessus le pr‚c‚dent 
	 */
	M_form_recurse_depth ++;	
}


/*
 * open_panel(-)
 *
 * Purpose:
 * --------
 * Ouvre une boite de "contr“le" 
 * dont on pourra restorer le fond par raster
 *
 * History:
 * --------
 * fplanque: Created
 */
void	open_panel( 
			OBJECT *dialog, 
			const GRECT *little_box, 
			GRECT *big_box, 
			int center )
{

#define	open_panel_debug	0

	unsigned	int	nb_lignes;				/* Nbre de lignes … sauver */
	unsigned int	buf_line_nbpixels;	/* Nbre de pixels/ligne ds buffer de sauvegarde (multiple de 16) */
	unsigned	int	buf_line_size;			/* Taille en octets d'une ligne du buffer de sauvegarde */
	unsigned	int	buf_capacity;			/* Capacit‚ de stockage du buffer en lignes de la taille sp‚cif ci-dessus */

	#if ( open_panel_debug )
	printf("\x1BY\x20\x20 Debug actif:\n");
	#endif

	/* Coordonn‚es formulaire: */
	if ( center == TRUE_1 )
	{	/* Centrage formulaire: */	
		form_center( dialog, &big_box -> g_x, &big_box -> g_y, &big_box -> g_w, &big_box -> g_h );
		/* Correction pour ombrage: */
		if ( dialog[ 0 ] .ob_state & SHADOWED )
		{	/* S'il y a de l'ombre: Compensation: */
			big_box -> g_x --;
			big_box -> g_y --;
			big_box -> g_w += 2;
			big_box -> g_h += 2;
		}
	}
	else
	{	/* Pas de centrage: */
		/* Calcule coordonn‚es du formulaire: */
		objc_xywh( dialog, 0, big_box );
		/* Correction pour ombrage: */
		if ( dialog[ 0 ] .ob_state & SHADOWED )
		{	/* S'il y a de l'ombre: Compensation: */
			big_box -> g_x --;
			big_box -> g_y --;
			big_box -> g_w += 4;
			big_box -> g_h += 4;
		}
	}

	#if ( open_panel_debug )
	printf("Zone ‚cran occup‚e: x=%d y=%d w=%d h=%d\n", big_box -> g_x, big_box -> g_y, big_box -> g_w, big_box -> g_h );
	#endif

	/* R‚servation d'une zone … l'‚cran? */
	if ( M_form_recurse_depth == 0 )
	{	/* S'il n'y a pas encore de formulaire ouvert: */
		/* On d‚clare cette ouverture … l'AES: */
		form_dial( FMD_START, 0, 0, 0, 0,
			big_box -> g_x, big_box -> g_y, big_box -> g_w, big_box -> g_h );
		/* printf("\033Y  F"); */
	}

	/* Effet graphique d'ouverture: */
	if( little_box != NULL )
	{	/* Si on a sp‚cifi‚ des coordon‚es pour little bbox: */
		/* Dessine rectangle en expansion: */
		form_dial( FMD_GROW, little_box -> g_x, little_box -> g_y, little_box -> g_w, little_box -> g_h,
			big_box -> g_x, big_box -> g_y, big_box -> g_w, big_box -> g_h );
	}

	/* Nombre de lignes … stocker: */
	nb_lignes = big_box -> g_h;

	/* Taille n‚cessaire au stockage d'une ligne: */
	buf_line_nbpixels = ( ( (big_box -> g_w) + 15) & 0xFFF0 );	/* En pixels */
	buf_line_size = buf_line_nbpixels * G_nb_bitplanes /8;		/* En octets */
	#if ( open_panel_debug )
		printf( "Long d'une ligne= %d   ", buf_line_nbpixels );
		printf( "taille en octets=%d\n", buf_line_size );
	#endif

	/* Capacit‚ du buffer AES en lignes: */
	buf_capacity = (unsigned) (G_long_tampon / buf_line_size);
	G_stock_tampon = min( buf_capacity, nb_lignes );
	#if ( open_panel_debug )
		printf( "Capacit‚ buffer: %d lignes  ", buf_capacity );
		printf( "=> On stocke %d lignes\n", G_stock_tampon );
	#endif
	
	/* Fixe les coordonn‚es de la copie dans buff AES */
	G_pxyarray[0]=big_box -> g_x;			/* Coord source */
	G_pxyarray[1]=big_box -> g_y;
	G_pxyarray[2]=G_pxyarray[0]+big_box -> g_w-1;
	G_pxyarray[3]=G_pxyarray[1]+G_stock_tampon-1;
	G_pxyarray[4]=0;							/* Coord destination */
	G_pxyarray[5]=0;
	G_pxyarray[6]=big_box -> g_w -1;
	G_pxyarray[7]=G_stock_tampon -1;

	/* Fixe les paramŠtres (virtuels) de l'‚cran-tampon AES: */
	G_tamponMFDB.fd_w = buf_line_nbpixels;		/* Largeur ligne */
	G_tamponMFDB.fd_h = big_box -> g_h;			/* Hauteur (nb_lignes)  */
	G_tamponMFDB.fd_wdwidth = buf_line_nbpixels /16;	/* Taille en mots d'un seul plan d'une seule ligne */
	#if ( open_panel_debug )
	printf("destMFDB w=%d h=%d wInt=%d Plans=%d\n", G_tamponMFDB.fd_w, G_tamponMFDB.fd_h, G_tamponMFDB.fd_wdwidth, G_tamponMFDB.fd_nplanes );
	#endif

	/* Op‚ration de copie: */
	graf_mouse( M_OFF, NULL );
	vro_cpyfm( G_ws_handle, S_ONLY, G_pxyarray, &G_plogMFDB, &G_tamponMFDB);
	graf_mouse( M_ON, NULL );

	/* Si tout n'est pas encore stock‚: */
	if ( G_stock_tampon < nb_lignes )
	{
		nb_lignes -= G_stock_tampon;		/* Nbre de lignes restantes */
		#if ( open_panel_debug )
			printf("Il reste … sauver %d lignes ds buffer supp\n", nb_lignes );
		#endif
		G_tampon_supp = MALLOC( nb_lignes * buf_line_size );
		if (G_tampon_supp == NULL)
		{	/* Pas assez de m‚moire: */
			signale("Pas assez de m‚moire interne");
		}
		else
		{	/* On va copier ce qui reste */
			G_pxyarray[1] += G_stock_tampon;					/* Y de la suite */
			G_pxyarray[3]	= G_pxyarray[1]+nb_lignes-1;	/* Y + H */
			G_pxyarray[7]	= nb_lignes -1;					/* H */
			G_tamponMFDB.fd_addr = G_tampon_supp;			/* Adr tampon */

			/* Op‚ration de copie: */
			graf_mouse( M_OFF, NULL );
			vro_cpyfm( G_ws_handle, S_ONLY, G_pxyarray, &G_plogMFDB, &G_tamponMFDB);
			graf_mouse( M_ON, NULL );
			
			G_tamponMFDB.fd_addr = G_tampon_aes;		/* Adr tampon */
		}
	}

	/* Dessine formulaire: */
	objc_draw( dialog, 0, 5, big_box -> g_x, big_box -> g_y, big_box -> g_w, big_box -> g_h );
	graf_mouse( ARROW, 0);					/* souris: FlŠche */

	/* On a ouvert un formulaire de plus par dessus le pr‚c‚dent */
	M_form_recurse_depth ++;	

	#undef	open_panel_debug
}



/*
 * close_dialog(-)
 *
 * Purpose:
 * --------
 * Ferme une boite de dialogue
 *
 * History:
 * --------
 * fplanque: Created
 */
void	close_dialog(
			OBJECT *dialog, 
			int exit_obj, 
			const GRECT *little_box, 
			const GRECT *big_box )
{
	graf_mouse( BUSYBEE, 0);				/* souris: Abeille */
	objc_clrsel( dialog, exit_obj );		/* Annule s‚lection du bouton de sortie */
	form_dial( FMD_SHRINK, little_box -> g_x, little_box -> g_y, little_box -> g_w, little_box -> g_h,
		big_box -> g_x, big_box -> g_y, big_box -> g_w, big_box -> g_h );

	if ( M_form_recurse_depth <= 1 )
	{	/* Si on vient de refermer le dernier formulaire ouvert: */
		/* On le d‚clare … l'AES: */
		form_dial( FMD_FINISH, 0, 0, 0, 0,
			big_box -> g_x, big_box -> g_y, big_box -> g_w, big_box -> g_h );
		/* printf("\033Y  -"); */
	}
	
	/* On a referm‚ le formulaire du haut... */
		M_form_recurse_depth --;	
}




/*
 * close_pannel(-)
 *
 * Purpose:
 * --------
 * Ferme une boite de "contr“le" en restorant le fond par raster
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	close_pannel( OBJECT *dialog, int exit_obj, const GRECT *big_box )
{
	graf_mouse( BUSYBEE, 0);				/* souris: Abeille */
	objc_clrsel( dialog, exit_obj );		/* Annule s‚lection du bouton de sortie */

	/*
	 * Restaure le fond: 
	 */
	G_pxyarray[0]=0;							/* Coord source */
	G_pxyarray[1]=0;
	G_pxyarray[2]=big_box -> g_w -1;
	G_pxyarray[3]=G_stock_tampon -1;
	G_pxyarray[4]=big_box -> g_x;		/* Coord destination */
	G_pxyarray[5]=big_box -> g_y;
	G_pxyarray[6]=G_pxyarray[4]+G_pxyarray[2];
	G_pxyarray[7]=G_pxyarray[5]+G_pxyarray[3];

	/*
	 * Op‚ration de copie: 
	 */
	graf_mouse( M_OFF, NULL );
	vro_cpyfm( G_ws_handle, S_ONLY, G_pxyarray, &G_tamponMFDB, &G_plogMFDB );
	graf_mouse( M_ON, NULL );

	if ( G_stock_tampon < big_box -> g_h )
	{	/*
		 * S'il reste qque chose … copier 
		 */
		G_pxyarray[3] = 	big_box -> g_h - G_stock_tampon -1;
		G_pxyarray[5] += G_stock_tampon;
		G_pxyarray[7] =	G_pxyarray[5]+G_pxyarray[3];
		G_tamponMFDB.fd_addr = G_tampon_supp;		/* Adr tampon suppl‚mentaire */

		/*
		 * Op‚ration de copie: 
		 */
		graf_mouse( M_OFF, NULL );
		vro_cpyfm( G_ws_handle, S_ONLY, G_pxyarray, &G_tamponMFDB, &G_plogMFDB );
		graf_mouse( M_ON, NULL );
		
		G_tamponMFDB.fd_addr = G_tampon_aes;		/* Adr tampon AES std */
		FREE( G_tampon_supp );						/* LibŠre le tampon supp */
		G_tampon_supp = NULL;
	}

	if( M_form_recurse_depth <= 1 )
	{	/* Si on vient de refermer le dernier formulaire ouvert: */
		/* On le d‚clare … l'AES: */
		form_dial( FMD_FINISH, 0, 0, 0, 0,
			big_box -> g_x, big_box -> g_y, big_box -> g_w, big_box -> g_h );
		/* printf("\033Y  -"); */
	}
	
	/*
	 * On a referm‚ le formulaire du haut... 
	 */
	M_form_recurse_depth --;	
}



/*
 * abort_pannel(-)
 *
 * Purpose:
 * --------
 * Ferme une boite de "contr“le" en restorant le fond par raster
 * avec en PLUS l'effet graphique de fermeture
 *
 * Suggest:
 * --------
 * Regrouppement avec close enisag‚ -> test si little_box != NULL
 *
 * History:
 * --------
 * fplanque: Created
 */
void	abort_pannel( OBJECT *dialog, int exit_obj, const GRECT *little_box, const GRECT *big_box )
{
	form_dial( FMD_SHRINK, little_box -> g_x, little_box -> g_y, little_box -> g_w, little_box -> g_h,
		big_box -> g_x, big_box -> g_y, big_box -> g_w, big_box -> g_h );
	close_pannel( dialog, exit_obj, big_box );
}
               
               
               
/*
 * objc_xywh(-)
 *
 * Purpose:
 * --------
 * Calcule la position et la taille d'un objet
 *
 * Suggest:
 * --------
 * Ne pas retourner la frame deja en param!
 *
 * History:
 * --------
 * fplanque: Created
 */
GRECT* objc_xywh ( 
				OBJECT *tree, 
				int objc, 
				GRECT *frame )
{
	objc_offset( tree, objc, &(frame->g_x), &(frame->g_y) );
	frame -> g_w = tree[objc].ob_width;
	frame -> g_h = tree[objc].ob_height;
	return	frame;
}
            
            

/*
 * objc_parent(-)
 *
 * Purpose:
 * --------
 * Trouve le pŠre d'un objet
 *
 * History:
 * --------
 * fplanque: Created
 */
int	objc_parent( OBJECT *tree, int obj )
{
	int	parent;
	
	/* Teste si on a bien indiqu‚ un n d'objet: */
	if (obj == -1 )
		return -1;
	
	parent = tree[ obj ] .ob_next;	/* 1er parent possible */
	
	if ( parent != -1 )
	{	/* Si on ne pointait pas sur le ROOT! */
		while ( tree[ parent ] .ob_tail != obj )
		{	/* Tant que l'objet courant n'est pas le dernier Fils du Parent */
			/*	pr‚sum‚, c'est qu'on a pas attrap‚ le parent! */
			obj = parent;							/* Nouvel objet courant */
			parent = tree[ obj ] .ob_next;	/* Nouveau parent pr‚sum‚ */
		}
	}
	
	return	parent;
}


/*
 * dlink_teptext(-)
 *
 * Purpose:
 * --------
 * Modifie le texte d'un objet xTEXT en changeant le pointeur
 * Sans contr“le de longueur (direct)
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void dlink_teptext( 
		OBJECT *objc_adr, 
		const char *texte )
{
	TEDINFO	*tedinfo_adr = ( objc_adr -> ob_spec.tedinfo ); /* Pointeur sur structure TEDINFO */
	tedinfo_adr -> te_ptext = (char *)texte;			/* Pointe sur le nouveau texte */
	tedinfo_adr -> te_txtlen = (int) strlen( texte );	/* Fixe longueur de ce texte */
}



/*
 * rlink_teptext(-)
 *
 * Purpose:
 * --------
 * Modifie le texte d'un objet xTEXT en changeant le pointeur
 * Avec contr“le, donnant la priorit‚ … la fin du texte
 *
 * Algorythm:
 * ----------  
 * Si texte … linker est NULL, on linke G_empty_string
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 28.03.95: linke chaines NULLes
 */
void	rlink_teptext( 
			OBJECT 		*	objc_adr, 
			const char	*	texte )	/* In: texte … linker */
{
	TEDINFO	*	tedinfo_adr;		/* Pointeur sur structure TEDINFO */
	int			long_dem,			/* Longueur demand‚e */
					long_max;			/* Longueur maximum autoris‚e */

	if( texte == NULL )
	{
		texte = G_empty_string;
	}
	
	long_dem = (int) strlen ( texte );		/* Longueur demand‚e avec /0 */
	long_max = ( objc_adr -> ob_width  ) / G_std_text.cell_w +1 ; /* Long max avec /0 */
	if (long_dem > (long_max) )				/* Si texte trop long! */
	{
		texte += (long_dem - long_max +1);		/* D‚place ptr sur la fin affichable */
		long_dem = long_max;
	}
	tedinfo_adr = ( objc_adr -> ob_spec.tedinfo ); /* Pointe sur TEDINFO */
	tedinfo_adr -> te_ptext = (char *)texte;	/* Pointe sur le nouveau texte */
	tedinfo_adr -> te_txtlen = long_dem;	/* Fixe longueur de ce texte */
}




/*
 * fix_ftext(-)
 *
 * Purpose:
 * --------
 * Copie texte dans un objet editable 
 * Contr“le de longueur
 * No Redraw
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	fix_ftext( 
			OBJECT 	  *	tree, 	/* In: Tree */
			int 				obj, 		/* In: dest object */
			const char *	ftext )	/* In: Source, can be NULL */
{
	int		i = 0;
	int		long_max	 = tree[ obj ] .ob_spec.tedinfo -> te_txtlen -1;
	char		cur_car;
	char		*te_ptext = tree[ obj ] .ob_spec.tedinfo -> te_ptext;

	if ( ftext != NULL )
	{	/*
		 * S'il y a un texte	d'origine: 
		 * Recopie la chaine ‚ditable: 
		 */
		while (	cur_car = ftext[ i ],
					cur_car != '\0'  &&  i < long_max )
		{
			te_ptext[ i ] = cur_car;	/* Fixe un caractŠre */
			i++;
		}
	}
	
	/* 
	 * Termine la chaine: 
	 */
	te_ptext[ i ] = '\0';

}     



/*
 * fix_fmtFtext(-)
 *
 * Purpose:
 * --------
 * Fixe texte dans un objet editable 
 * Formatt‚
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 17.12.94: gŠre les ftext NULL
 */
void	fix_fmtFtext( 					/* Out: */
			OBJECT 		*	tree,		/* In: Arbre contenant l'objet targett‚ */
			int 				obj, 		/* In: Index de l'objet target */
			const char	*	ftext )	/* In: Ptr sur texte a ins‚rer ds objet */
{
	TEDINFO	*tedinfo = tree[ obj ] .ob_spec.tedinfo;
	char	*te_ptext	= tedinfo -> te_ptext;
	char	*te_ptmplt 	= tedinfo -> te_ptmplt;
	char	templ, fcar;

	while( *te_ptmplt != '_' && *te_ptmplt != '\0' )
	{
		te_ptmplt ++;		/* Saute le blabla inutile */
	}
	
	if( *te_ptmplt != '\0' && ftext != NULL )		/* Anti-bug */
	{	/*
	 	 * Si on a trouv‚ un d‚but de template: 
	 	 */
		while(	fcar	= *ftext,
					templ	= *(te_ptmplt++),
					fcar != '\0' && templ != '\0' )
		{
			if( templ == '_' )
			{	/*
				 * Si position ‚ditable: 
				 */
				if ( fcar != '.' && fcar != ':' )
				{	/*
					 * Si le car est int‚grable: 
					 */
					*(te_ptext++) = *(ftext++);	/* Copie car */
				}
				else
				{	/*
					 * Si le car n'est pas int‚grable: 
					 */
					*(te_ptext++) = ' ';		/* Espace */
				}
			}
			else if ( templ == fcar )
			{	/*
				 * S'il s'agit du caractŠre qu'on attendait: 
				 */
				ftext++;		/* Passe sur position suivante dans chaine source */
			}
		}
	}

	/*
	 * Rajoute \0 final: 
	 */
	*te_ptext = '\0';

}



/*
 * extract_fmtFtext(-)
 *
 * Purpose:
 * --------
 * Extrait le texte d'un objet ‚ditable
 * formatt‚
 *
 * Notes:
 * ------
 * contient un malloc()
 *
 * History:
 * --------
 *     1993: fplanque: Created
 * 11.07.95: fplanque: realloc oubliat la place pour le \0 final
 */
char * extract_fmtFtext( 	/* Out: nlle chaine contenant texte extrait */
			OBJECT *	tree, 	/* In:  Arbre contenant l'objet */
			int		obj )		/* In:  No de l'objet contenant le texte */
{
	TEDINFO*	tedinfo = tree[ obj ] .ob_spec.tedinfo;
	char	*	te_ptext	= tedinfo -> te_ptext;
	char	*	te_ptmplt 	= tedinfo -> te_ptmplt;
	char	*	ftext		= MALLOC( strlen( te_ptmplt ) +1 );		/* Cr‚e zone de longueur maximale + \0 final */
	char	*	ftext_ptr	= ftext;
	char		car;

	while( *te_ptmplt != '_' && *te_ptmplt != '\0' )
	{
		te_ptmplt ++;		/* Saute le blabla inutile */
	}

	if ( *te_ptmplt != '\0' )		/* Anti-bug */
	{	/*
		 * Si on a trouv‚ un d‚but de template: 
		 */
		while( *te_ptext != '\0' )
		{
			car = *(te_ptmplt++);
			if( car == '_' )
			{	/*
				 * Si position ‚ditable: 
				 */
				car = *(te_ptext++);
				if ( car != ' ' )
				{	/*
					 * Si le car n'est pas un espace de bourrage: 
					 */
					*(ftext_ptr++) = car;
				}
			}
			else
			{	/*
				 * Si caractŠre de formattage: 
				 */
				*(ftext_ptr++) = car;
			}
		}
	}

	/*
	 * Rajoute \0 final: 
	 */
	*ftext_ptr = '\0';

	/*
	 * Restreint … la longueur n‚cessaire: 
	 * (sans oublier le \0 final)
	 */
	ftext = REALLOC( ftext, strlen( ftext )+1 );

	/*
	 * Retourne adr chaine FTEXT: 
	 */
	return	ftext;
}


/*
 * extract_ftext(-)
 *
 * Purpose:
 * --------
 * Extrait le texte d'un objet ‚ditable
 * non-formatt‚
 *
 * History:
 * --------
 * 24.05.94: fplanque: Created
 */
char	*extract_ftext( OBJECT *tree, int obj )
{
	return	STRDUP( tree[ obj ] .ob_spec.tedinfo -> te_ptext );
}


/*
 * free_text(-)
 *
 * Purpose:
 * --------
 * Efface le texte associ‚e … une TEDINFO de la m‚moire
 *
 * History:
 * --------
 * fplanque: Created
 */
void free_text( 
		OBJECT *objc_adr )
{
	FREE( ( objc_adr -> ob_spec.tedinfo ) -> te_ptext );
}


/*
 * formdup(-)
 *
 * Purpose:
 * --------
 * Duplique un arbre d'objets et ses TEDINFOS
 *
 * Notes:
 * ------
 * Cette routine se base sur le flag LASTOB
 *
 * History:
 * --------
 * fplanque: Created
 */
OBJECT*	formdup( 
				OBJECT *srce_tree )
{
	OBJECT	*srce_ptr = srce_tree;	/* Pointeur ds l'arbre source */
	OBJECT	*dest_tree;					/* Adr arbre de destination */
	size_t	tree_size;					/* Taille de l'arbre en octets */
	int		nb_objects=1;				/* Nombre d'objets */
	
	/* Compte le nombre d'objets: */
	while( ((srce_ptr++) -> ob_flags & LASTOB) == 0 	/* Tant que pas dernier objet */
			&& nb_objects < 100 )		/* (Protection anti-boucle sans fin) */
	{
		nb_objects++;						/* Un objet de plus! */
	}
	
	/* Taille de l'arbre: */
	/* printf("%d * %lu\n",nb_objects,sizeof( OBJECT )); */
	tree_size = nb_objects * sizeof( OBJECT );

	/* Copie les objets: */
	dest_tree = (OBJECT *) MALLOC( tree_size );
	memcpy( dest_tree, srce_tree, tree_size );
		
	/* Parcourt l'arbre pour duplication des TEDINFOS */
	maptree( dest_tree, ROOT, NIL, dup_tedinfo );
	
	return	dest_tree;
}



/*
 * dup_tedinfo(-)
 *
 * Purpose:
 * --------
 * Duplication des tedinfos
 *
 * History:
 * --------
 * fplanque: Created
 */
int	dup_tedinfo( 
			OBJECT *tree, 
			int objc )
{
	/* Teste si il faut dupliquer l'OB_SPEC: */
	if( tree[ objc ] .ob_state & USES_SPEC )
	{
	/* Analyse type: */
		switch( tree[ objc ] .ob_type )
		{
			case	G_TEXT:
			case	G_BOXTEXT:
			case	G_FTEXT:
			case	G_FBOXTEXT:	
			{
				TEDINFO	*new_tedinfo = (TEDINFO *) MALLOC ( sizeof( TEDINFO ) );	/* Cr‚e zone */
				memcpy( new_tedinfo, tree[ objc ] .ob_spec.tedinfo, sizeof( TEDINFO ) );	/* Recpie TEDINFO */
				tree[ objc ] .ob_spec.tedinfo = new_tedinfo;					/* Fixe nlle adresse */
				break;
			}
		}
	}
	
	return TRUE_1;
}



/*
 * free_form(-)
 *
 * Purpose:
 * --------
 * Efface un arbre d'objets dupliqu‚ et ses TEDINFOS dupliqu‚es
 *
 * History:
 * --------
 * fplanque: Created
 */
void	free_form( OBJECT *tree )
{
	/* Parcourt l'arbre pour suppression des TEDINFOS */
	maptree( tree, ROOT, NIL, supress_tedinfo );

	/* Supprime le formulaire de la m‚moire: */
	FREE( tree );
}




/*
 * supress_tedinfo(-)
 *
 * Purpose:
 * --------
 * Supression des tedinfos
 *
 * History:
 * --------
 * fplanque: Created
 */
int	supress_tedinfo( OBJECT *tree, int objc )
{
	/* Teste si on a dupliqu‚ l'OB_SPEC: */
	if( tree[ objc ] .ob_state & USES_SPEC )
	{
		/* Analyse type: */
		switch( tree[ objc ] .ob_type )
		{
			case	G_TEXT:
			case	G_BOXTEXT:
			case	G_FTEXT:
			case	G_FBOXTEXT:	
				FREE( tree[ objc ] .ob_spec.tedinfo );	/* LibŠre m‚moire */
				break;
		}
	}

	return TRUE_1;
}



/*
 * ------------------------ DIRECTORIES -------------------------
 */



/*
 * dir_optimal(-)
 *
 * Purpose:
 * --------
 * Calcule taille optimale d'une fenêtre directory
 *
 * History:
 * --------
 * fplanque: Created
 */
void	dir_optimal( 
			int *x_full, 
			int *y_full, 
			int *w_full, 
			int *h_full)
{
	*x_full = G_x_mini;
	*y_full = G_y_mini;
	*w_full = G_iconw_max_w;
	*h_full = G_h_maxi;
}


/*
 * open_dir(-)
 *
 * Purpose:
 * --------
 * Ouvre une fenˆtre directory
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 18.06.94: modif menu_options en fonction de la fenˆtre
 * 06.08.94: param DATAGROUP remplac‚ par DATADIR
 */
void	open_dir( 
			WIPARAMS *	wi_params_adr, 
			DATADIR *	pDataDir, 
			int x_work, 
			int y_work, 
			int w_work )
{
	int		wi_ckind = wi_params_adr -> wi_ckind;

	OBJECT	*dir_tree,					/* Nouvel arbre pour directory */
				*dir_tree_ptr;				/* Pointeur dans cet arbre */
	ICONBLK	*iblk_array,				/* Zone d'iconblks */
				*iblk_array_ptr;			/* Pointeur dans cette zone */
	int		i;								/* Divers usages */
	int		curr_x=0, curr_y=0;		/* Position des ic“nes qu'on ajoute */
	int		max_x;						/* Largeur de la fenˆtre */

	int			nb_items		= pDataDir -> nb_elts;	/* Nombres d'‚l‚ments */
	DATAPAGE		*curr_page	= pDataDir -> data_start; /* Ptr sur premiŠre page */ 

	/*
	 * Cr‚e un arbre d'objets: 
	 */
	dir_tree = MALLOC( sizeof( OBJECT ) * (nb_items+1) );	/* Cr‚e zone pour arbre d'objets */
	
	/* 
	 * Indique imm‚diatement l'adresse ds params fenˆtre 
	 * car on va en avoir besoin trŠs vite.... 
	 */
	wi_params_adr -> draw_ptr.tree 	= dir_tree;		/* Pointeur sur arbre d'objets */

	/*
	 * Teste si une fenˆtre semblable est d‚j… ouverte: 
	 */
	if ( pDataDir -> nb_dirs )
	{	/* 
	    * On va reprendre le contenu d'une fenˆtre similaire:
		 * Etant donn‚ que les wi_params de la nlle fenˆtre ne sont pas
		 *	encore pr‚sentes dans la liste, on peut demander une recherche
		 *	d'une AUTRE fenˆtre pointant sur le mˆme datagroup:
		 */
		WIPARAMS *modele_adr = find_datawindow2( (unsigned long) pDataDir, G_wi_list_adr );
			
		/*
		 * Copie l'arbre directory du modŠle vers la nlle fenˆtre: 
		 */
		/*	printf("Dupliq.arbre: modele= %lu -> %lu\n", (modele_adr -> draw_ptr).tree, dir_tree ); */
		memcpy( dir_tree, (modele_adr -> draw_ptr).tree,
					 sizeof( OBJECT ) * (nb_items+1) );

		/*
		 * R‚arrange les ic“nes en fnct de la nlle taille:
		 */
		rearrange_dir( wi_params_adr, wi_params_adr -> curr_w );

		/* Remarque: on a gard‚ les iconblks de la 1Šre des fenˆtres semblables! */
	}
	else
	{	/*
	 	 * On va cr‚er le contenu de la fenˆtre: 
		 * Installe la Boite de fond: 
		 */
		dir_tree_ptr = dir_tree;
		memcpy( dir_tree_ptr, &M_single_box, sizeof( OBJECT ) );	/* Copie le pŠre (boŒte blanche) */
				
		/*
		 * Icones: 
		 */
		/* Position X maxi des ic“nes: */
			max_x = w_work -(w_work % G_icon_w);
			if ( max_x < G_icon_w )
				max_x = G_icon_w;
	
		if ( nb_items )		/* S'il y a des ic“nes: */
		{
			ICONIMG	* pIconImg;	/* Donn‚e sur l'ic“ne … utiliser */

			/*
			 * ParamŠtre M_iconblk: 
			 */
			switch( pDataDir -> pDataGroup -> DataType )
			{
				case	DTYP_PAGES:		/* Pages ‚cran: */
					pIconImg = &(G_icon_images .minitel);
					break;

				case	DTYP_DATAS:		/* Donn‚es: */
					pIconImg = &(G_icon_images .datas);
					break;
				
				case	DTYP_TEXTS:		/* Pages ‚cran: */
					pIconImg = &(G_icon_images .texte);
					break;
					
				case	DTYP_PICS:		/* Images: */
					pIconImg = &(G_icon_images .image);
					break;
					
				default:
					ping();
			}
			M_iconblk .ib_pmask = pIconImg -> mask;
			M_iconblk .ib_pdata = pIconImg -> data;
			M_iconblk .ib_yicon = pIconImg -> icon_y;
			M_iconblk .ib_hicon = pIconImg -> icon_h;
			M_iconblk .ib_xchar = pIconImg -> char_x;
			M_iconblk .ib_ychar = pIconImg -> char_y;
				
			/*
			 * Cr‚e une zone d'ICONBLK: 
			 */
			iblk_array = MALLOC( sizeof( ICONBLK ) * nb_items );	/* Cr‚e zone pour ICONBLKs */
			iblk_array_ptr = iblk_array;
			/*
			 * Sauvegarde cette adresse: 
			 */
			pDataDir -> iconblks = iblk_array;
	
			for( i = 1; i <= nb_items; i++ )
			{	/*
				 * Param‚trage ICONBLK: 
				 * Modifie NOM de l'ic“ne ds M_iconblk 
				 */
				M_iconblk .ib_ptext = curr_page -> nom;	/* Adresse du nom ds struct DATAPAGE */
	
				/* 
				 * Copie ICONBLK: 
				 */
				memcpy( iblk_array_ptr, &M_iconblk, sizeof( ICONBLK ) );
					
				/* 
				 * Param‚trage OBJECT: 
				 */
				/* Lie M_iconblk … l'objet-ic“ne: */
					M_icone .ob_spec.iconblk = iblk_array_ptr++;	/* OB_SPEC Pointe sur M_iconblk */
	
				/*
				 * Modifie coordonn‚es (relatives au pŠre): 
				 */
					if ( curr_x >= max_x )			/* Si on d‚passe la fin de la fenˆtre: */
					{										
						curr_x = 0;							/* D‚but de la ligne...	*/
						curr_y += G_icon_h;					/* ...ligne suivante */
					}
					M_icone .ob_x = curr_x;				/* Position X */
					M_icone .ob_y = curr_y;				/* Position Y */
					curr_x += G_icon_w;						/* X Prochaine ic“ne */
		
				/*
				 * Ajoute la nouvelle ic“ne dans l'arbre: 
				 */
				memcpy( ++dir_tree_ptr, &M_icone, sizeof( OBJECT ) );

				/*
				 * Change le caractŠre de l'ic“ne en fonction du statut de sauvegarde:
				 */
				update_iconChar( &M_icone, dataPage_getSavState( curr_page ) );
	
				/* 
				 * Param‚trage TREE: 
				 */
				/* Lie la nouvelle ic“ne … l'arbre: */
					objc_add( dir_tree, 0, i );
			
				/*
				 * Passe … l'‚l‚ment suivant: 
				 */
				curr_page = curr_page -> next;
			}
		}
		else 
		{	/*
			 * Si pas d'ic“nes: 
			 */
			pDataDir -> iconblks = NULL;		/* Pas de zone d'ICONBLKs */
		}
			
		/*
		 * Signale le dernier objet de la fenˆtre: 
		 */
		dir_tree_ptr -> ob_flags |= LASTOB;

		/*
		 * Fixe taille de la boŒte de fond: 
		 */
		dir_tree -> ob_width = G_w_maxi;
		dir_tree -> ob_height = curr_y + G_h_maxi;
					
		/*
		 * Param‚trage de la fenˆtre: 
		 */
		wi_params_adr -> total_w	= max_x-1;		/* Taille utile occup‚e par les ic“nes */
		/* printf("Open: %d\n",wi_params_adr -> total_w); */
		wi_params_adr -> total_h	= curr_y + G_icon_h - 1;	/* Idem */
		/* Calc taille ext‚rieure limite en dessous de laquelle il faut
			r‚arranger les ic“nes dans la fenˆtre: */
			wind_calc( WC_BORDER, wi_ckind, 100, 100, max_x, 100,
								 &i, &i, &(wi_params_adr -> more), &i );
	}

	/*
	 * Contr“le position de la fen/doc: 
	 */
	/* printf("seen y=%d, h=%d, total=%d\n",(int)wi_params_adr -> seen_y, (int)wi_params_adr -> seen_h, (int)wi_params_adr -> total_h ); */
	if ( get_workYBas( wi_params_adr ) > wi_params_adr -> total_h )
	{	/* Si la fenˆtre d‚passe le bas du nouveau doc */
		wi_params_adr -> seen_y = 
			l_max ( 0, wi_params_adr -> total_h - wi_params_adr -> seen_h );
	}

	/*
	 * Positionne l'arbre d'objets: 
	 */
	dir_tree[0].ob_x = x_work;
	dir_tree[0].ob_y = y_work - (int) wi_params_adr -> seen_y;


	/*
	 * Param‚trage de la fenˆtre: 
	 */
	wi_params_adr -> content_ptr.datadir = pDataDir;	/* contenu */
	wi_params_adr -> h_step = G_icon_w;					/* Saut par ic“ne */
	wi_params_adr -> v_step = G_icon_h;					/* Saut par ic“ne */
	/*
	 * Options menu: 
	 */
	switch( pDataDir -> pDataGroup -> DataType )
	{
		case	DTYP_DATAS:		/* Donn‚es: */
			wi_params_adr -> menu_options.newrub = TRUE_1;	/* On peut cr‚er des nouvelles rubriques */
			break;
		
		case	DTYP_TEXTS:		/* textes: */
			wi_params_adr -> menu_options.newtext = TRUE_1;	/* On peut cr‚er des nouveaux textes */
			break;
	}						

	/*
	 * 1 fenˆtre semblable de plus: 
	 */
	pDataDir -> nb_dirs ++;
}




/*
 * rearrange_dir(-)
 *
 * Purpose:
 * --------
 * R‚-arrange une fenˆtre directory en fnct de sa nlle taille
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void rearrange_dir( WIPARAMS *wi_params_adr, int new_w )
{
	OBJECT	*dir_tree = (wi_params_adr -> draw_ptr.tree); /* Pointeur sur l'arbre */
	int		wi_ckind = wi_params_adr -> wi_ckind;
	int		i;								/* Divers usages */
	int		curr_x=0, curr_y=0;		/* Position des ic“nes qu'on place */
	int		max_x;						/* Largeur de la fenˆtre */

	/*
	 * Position X maxi des ic“nes 
	 */
	wind_calc( WC_WORK, wi_ckind, 100, 100, new_w, 100,
					 &i, &i, &max_x, &i );
	max_x = max_x -(max_x % G_icon_w);
	if ( max_x < G_icon_w )
		max_x = G_icon_w;
	
	/*
	 * Re-positionne chaque ic“ne: 
	 */
	i = 0;
	while( (dir_tree[i] .ob_flags & LASTOB) == 0 )
	{	/*
		 * Tant qu'on est pas arriv‚ … la fin de l'arbre: 
		 */
		i++;			/* Passe … l'ic“ne suivante */
	
		/*
		 * Modifie coordonn‚es (relatives au pŠre): 
		 */
		if ( curr_x >= max_x )			/* Si on d‚passe la fin de la fenˆtre: */
		{										
			curr_x = 0;							/* D‚but de la ligne...	*/
			curr_y += G_icon_h;					/* ...ligne suivante */
		}
		dir_tree[i] .ob_x = curr_x;		/* Position X */
		dir_tree[i] .ob_y = curr_y;		/* Position Y */
		curr_x += G_icon_w;						/* X Prochaine ic“ne */
	}

	/*
	 * Fixe nlle hauteur de la boŒte de fond: 
	 */
	dir_tree -> ob_height = curr_y + G_h_maxi;

	/*
	 * Param‚trage de la fenˆtre: 
	 */
	wi_params_adr -> total_w			= max_x-1;		/* Taille utile occup‚e par les ic“nes */
	/*	printf("Resize: %d\n",wi_params_adr -> total_w);*/
	wi_params_adr -> total_h			= curr_y + G_icon_h - 1;	/* Idem */

	/* 
	 * Calc taille ext‚rieure limite en dessous de laquelle il faut
	 * r‚arranger les ic“nes dans la fenˆtre: 
	 */
	wind_calc( WC_BORDER, wi_ckind, 100, 100, max_x, 100,
						 &i, &i, &(wi_params_adr -> more), &i );

}




/*
 * remplace_dir(-)
 *
 * Purpose:
 * --------
 * Remplace un arbre d'objet directory dans les fenˆtres concern‚es
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 09.08.94: le param est maintenant un DATADIR comme il se doit!
 * 28.08.94: peut remplacer datadir mˆme si aucune fen ouverte dessus
 */
void remplace_dir( DATADIR	* datadir )
{
	WIPARAMS	*curr_wi_adr;								/* Adresse des params de la
																/* fen en cours de traitement */
	int		x_work, y_work, w_work, foo; 			/* Coord zone de travail */
	int		wi_ckind;					/* El‚ments des fen^etres concern‚es */

	/* 
	 * PremiŠre ‚tape: 
	 * Effacer les anciens arbres d'objets et l'ICONBLK
	 * On recherche la premiŠre fenˆtre concern‚e
	 * d'aprŠs leur datagroup: 
	 */
	curr_wi_adr = find_datawindow2( (unsigned long) datadir, G_wi_list_adr );

	while ( curr_wi_adr != NULL )
	{
		/*	printf("Adr Fen concern‚e: %lX\n",curr_wi_adr);*/

		/* Efface le directory de la fenˆtre: */
		efface_dir( curr_wi_adr );

		/* Trouve prochaine fenˆtre */
		curr_wi_adr = find_datawindow2( (unsigned long) datadir, curr_wi_adr -> next ); 

	}

	/* 
	 * DeuxiŠme ‚tape: Cr‚er un nouvel arbre d'objets & ICONBLK 
	 *	et le fixer dans les fenˆtres concern‚es: 
	 * PremiŠre fenˆtre … traiter: 
	 */
	curr_wi_adr = find_datawindow2( (unsigned long) datadir, G_wi_list_adr );

	while ( curr_wi_adr != NULL )
	{
		wi_ckind		= curr_wi_adr -> wi_ckind;		/* El‚ments des fenetres … traiter */
	
		/* printf("Adr Fen concern‚e: %lX\n",curr_wi_adr); */
 		/*	printf("Fen no= %d: ",curr_wi_adr -> handle ); */

		/* Coord zone de travail: */
		wind_calc( WC_WORK, wi_ckind, curr_wi_adr -> curr_x,
			 curr_wi_adr -> curr_y, curr_wi_adr -> curr_w, 100,
			 &x_work, &y_work, &w_work, &foo );

		/* Ouvre nouveau directory */
		open_dir( curr_wi_adr, datadir, x_work, y_work, w_work );

		/* Modifie ligne d'informations: */
		set_infoline( curr_wi_adr, dir_infoline );

		/* Demande redraw total de la fenˆtre: */
		send_fullredraw( curr_wi_adr );

		/* Fixe Nouvel ascenseur */
		set_slider_h( curr_wi_adr );		/* Fixe taille */
		set_slider_y( curr_wi_adr );		/* Fixe position asc */

		/* Trouve prochaine fenˆtre */
		curr_wi_adr = find_datawindow2( (unsigned long) datadir, curr_wi_adr -> next ); 

	}
}



/*
 * efface_dir(-)
 *
 * Purpose:
 * --------
 * Efface un arbre d'objet directory dans 1 fenˆtre
 * et la zone d'ICONBLKS s'il s'agissait de la derniŠre fenˆtre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	efface_dir( WIPARAMS *wi_params_adr )
{
	/* 
	 * Groupe de donn‚e dont on vient de fermer (une)/(la derniŠre) fenˆtre: 
	 * Ou dont on veut remplacer le directory: 
	 */
	DATAGROUP	*curr_datagr = wi_params_adr -> datagroup;	/* Datagroup concern‚ */
	DATADIR		*datadir		 = curr_datagr -> root_dir;		/* Dossier ppal du Datagroup */

	/* Une fenˆtre de moins... */
	/* Teste s'il reste des fenˆtres semblables */
	if ( --(datadir -> nb_dirs) == 0)
	{	/* Si on vient de fermer la derniŠre fenˆtre: */
		if ( datadir -> iconblks != NULL )
		{	/* S'il y avait des ic“nes et donc une zone d'ICONBLKs
			/*	ds la derniŠre fenˆtre: */
			FREE( datadir -> iconblks );	 /* Efface tableau d'ICONBLK: */
		}
	}
			
	/*
	 * Efface arbre d'ic“nes de la m‚moire 
	 */
	FREE( wi_params_adr -> draw_ptr.tree );
}



/*
 * dir_infoline(-)
 *
 * Purpose:
 * --------
 * Cr‚e ligne d'informations sur un directory
 *
 * History:
 * --------
 * fplanque: Created
 */
char	*dir_infoline( WIPARAMS *wi_params_adr )
{

	int	nb_elts = (wi_params_adr -> datadir) -> nb_elts;

	/* Cr‚ation de la ligne d'infos: */
	if( nb_elts )
	{
		G_tmp_buffer[ 0 ] = ' ';
		itoa( nb_elts, &G_tmp_buffer[ 1 ], 10 );	/* Nombre d'‚l‚ments */
		if ( nb_elts == 1 )
			strcat( G_tmp_buffer, " ‚l‚ment." );
		else
			strcat( G_tmp_buffer, " ‚l‚ments." );
	}
	else
	{	/* Dossier vide */
		strcpy( G_tmp_buffer, " Aucun ‚l‚ment." );		/* Bug corrig‚ le 6/8/93 */
	}

	return	STRDUP( G_tmp_buffer );
}



/*
 * dir_infoline_selection(-)
 *
 * Purpose:
 * --------
 * Modifie la ligne d'informations sur le dir 
 * lorsqu'on a s‚lectionn‚ une icone
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
char	*	dir_infoline_selection( 
				WIPARAMS *wi_params_adr )
{
	DATADIR	*	datadir			= wi_params_adr -> datadir;
	int			selected_icon	= wi_params_adr -> selected_icon;
	char		*	dataname			= ((wi_params_adr -> draw_ptr.tree)[selected_icon] .ob_spec.iconblk) -> ib_ptext;
	DATAPAGE	*	datapage	 		= page_adr_byname( datadir, dataname ); 
	char		*	comment			= datapage -> comment;

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

	return	STRDUP( G_tmp_buffer );
}




/*
 * update_iconChar(-)
 *
 * Purpose:
 * --------
 * Modifie le caractŠre d'une ic“ne de maniŠre … ce qu'elle reflŠte
 * le statut de sauvegarde de l'objet auquel elle se rapporte
 *
 * History:
 * --------
 * 06.08.94: fplanque: Created
 */
void	update_iconChar( 
			OBJECT *	pObject,		/* In: Ic“ne … modofier */
			SSTATE	sstate	)	/* In: Etat de l'objet auquel l'icone se rapporte */		
{
	char	newChar;
	int * pIconChar = &(pObject -> ob_spec.iconblk -> ib_char);	

	switch( sstate )
	{
		case	SSTATE_EMPTY:
			newChar = CEMPTY;
			break;
	
		case	SSTATE_MODIFIED:
			newChar = '*';
			break;

		case	SSTATE_SAVED:
			newChar = ' ';
			break;
			
		default:
			newChar = '?';
			signale( "Unknown SSTATE" );
	}

	*pIconChar = ((*pIconChar) & 0xFF00) | newChar;
}



/*
 * find_iconByNamePtr(-)
 *
 * Purpose:
 * --------
 * Trouve une ic“ne dans une fenˆtre directory en fonction
 * du pointeur sur son nom (texte)
 *
 * History:
 * --------
 * 06.08.94: fplanque: Created
 * 21.09.94: adapt‚ aux arbres arbo
 */
int find_iconByNamePtr(				/* Out: Index ic“ne */
			OBJECT 	* 	pObj_Tree,
			char		*	psz_nom )
{
	int i;

	for( i=0; (pObj_Tree[i] .ob_flags & LASTOB) == 0; )
	{	/*
		 * Tant qu'on est pas arriv‚ … la fin de l'arbre: 
		 */
		i++;			/* Passe … l'ic“ne suivante */

		/*
		 * Compare textes/noms: 
		 */
		if( ((pObj_Tree[i] .ob_type ) & 0x00FF ) == G_ICON
			&& ((pObj_Tree[i] .ob_spec.iconblk) -> ib_ptext ) == psz_nom )
		{
			return	i;
		}
	}

	return	NIL_1;
}



/*
 * find_ObjBySpec(-)
 *
 * Purpose:
 * --------
 * Trouve un objet dans un arbre en fonction de son ptr sur ob_spec
 *
 * History:
 * --------
 * 09.10.94: fplanque: Created
 */
int find_ObjBySpec(				/* Out: Index objet trouv‚ ou NIL_1 */
			OBJECT 	* 	pObj_Tree,
			void		*	ob_spec )
{
	int i;

	for( i=0; (pObj_Tree[i] .ob_flags & LASTOB) == 0; )
	{	/*
		 * Tant qu'on est pas arriv‚ … la fin de l'arbre: 
		 */
		i++;			/* Passe … l'ic“ne suivante */

		/*
		 * Compare textes/noms: 
		 */
		if( pObj_Tree[i] .ob_spec.free_string == ob_spec )
		{
			return	i;
		}
	}

	return	NIL_1;
}



/*
 * find_ObjByXY(-)
 *
 * Purpose:
 * --------
 * Trouve un objet dans un arbre
 * en fonction de ses coordonn‚es
 *
 * History:
 * --------
 * 06.10.94: fplanque: Created
 */
int find_ObjByXY(						/* Out: Index ic“ne */
			OBJECT 	* 	pObj_Tree,
			int			n_x,
			int			n_y )
{
	int i;

	for( i=0; (pObj_Tree[i] .ob_flags & LASTOB) == 0; )
	{	/*
		 * Tant qu'on est pas arriv‚ … la fin de l'arbre: 
		 */
		i++;			/* Passe … l'obj suivant */

		/*
		 * Compare coords: 
		 */
		if( pObj_Tree[i] .ob_x == n_x && pObj_Tree[i] .ob_y == n_y )
		{
			return	i;
		}
	}

	return	NIL_1;
}
