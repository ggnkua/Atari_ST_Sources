/*
 * desktopi.c
 *
 * Purpose:
 * --------
 *	Installation du nouveau bureau
 *	Init des ic“nes
 *
 * History:
 * --------
 * 1992: fplanque: Created
 * 09.05.94: fplanque: les fichiers .h pour ressources avaient disparu
 *					lors de l'ajout de commentaires - remis en place.
 * 15.07.94: sorti fonction create_EmptyDataDir();
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"DESKTOPI.C v1.00 - 02.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>				/* header standard */
	#include <string.h>				/* strcopy */
	#include	<aes.h>					/* Pour routines AES */

/*
 * Custom headers:
 */
	#include "SPEC_PU.H"
	#include "S_MALLOC.H"
	#include "DEBUG_PU.H"
	#include "WIN_PU.H"
	#include "DESK_PU.H"
	#include "COLORDEF.H"			/* Couleurs … utiliser */
	#include "AESDEF.H"				/* Gestion AES etendue */
	#include "VDI_PU.H"

	#include "DESKICON.RCH"					/* Bureau + Icones haute r‚solution */
#if ACCEPT_SMALLFONTS == YES1
	#include "DESK_MED.RCH"					/* Ic“nes moyenne r‚solution */
#endif

	#include "RSH_MAP.H"	
	#include	"RSHCRMAP.H"			/* Cr‚ation du map pour CE RSH */


/*
 * ------------------------ PROTOTYPES -------------------------
 */

/*
 * EXTernal prototypes:
 */
	/* 
	 * G‚n‚ral: 
	 */
	extern	void	erreur( const char *texte_erreur );
	extern	void	erreur_rsrc( void );		/* PROVISOIRE */
	extern	void	ping( void );
	/* 
	 * Relocation du RSH: 
	 */
	extern	void	remap_rsh( RSH_MAP *rsh_map );
	/* 
	 * Fenetres: 
	 */
	extern	void	redraw( WIPARAMS *wi_params_adr, int area_x, int area_y, int area_w, int area_h, int take_control );
	/*
	 * datadirs
	 */
	extern	DATADIR	*create_EmptyDataDir(					/* Out: Ptr sur directory cr‚‚ */
								DATAGROUP	*	pDataGroup,			/* In:  Groupe dans lequel on cr‚e ce dossier */
								DATADIR		*	pDataDir_parent );/* In:  Directory parent de celui-ci */
	/*
	 * datas:
	 */
	extern	void	init_vars_datagroup( 
							DATAGROUP *datagroup );	/* In: DATAGROUP à initialiser */


/*
 * PUBlic INTernal prototypes:
 */
	static	DATAGROUP	*	find_datagroup_byType( 		/* Out: Ptr sur datagroup */
										DATATYPE		DataType );	/* In:  Type DTYP_* */

/*
 * PRIVate INTernal prototypes:
 */
	static	void		place_fnct_icon( OBJECT *icone );
	static	void		place_data_icon( OBJECT *icone );
	static	void		register_datagroup( int	icon_no, DATAGROUP *datagroup_ptr );

   
/*
 * ------------------------ VARIABLES -------------------------
 */

/*
 * External variables: 
 */
	extern	unsigned	G_version_aes;				/* Version AES */
	extern	int		G_x_mini, G_y_mini;		/* Coord sup gauche de l'‚cran */
	extern	int		G_w_maxi, G_h_maxi;		/* Taille de l'‚cran de travail */
	extern	int		G_wx_mini, G_wy_mini;	/* Dimensions maximales d'une */
	extern	int		G_ww_maxi, G_wh_maxi;	/* fenˆtre complŠte */
	extern	int		G_nb_colors;				/* Nbre de couleurs simultan‚es */


/*
 * Public variables: 
 */
	OBJECT	*	G_desktop_adr;				/* Ptr sur arbre bureau */
	WIPARAMS	*	G_desk_params_adr;		/* ParamŠtres de la "fenˆtre bureau" */
	ICONIMGS		G_icon_images;				/* Pointeurs sur les images des ic“nes */
	int			G_icon_w, G_icon_h;		/* Dimensions des ic“nes */
	int			G_iconw_max_w;				/* Dimension maximale d'une fenˆtre contenant des ic“nes */
	int			G_fantome_icone[18];		/* Tableau contenant les coord pour le dessin d'un fant“me d'ic“ne */
	DATAGROUP *	G_datagroups;				/* Pointeur sur tableau de G_datagroups */
	
/*
 * Private variables: 
 */
	static	int	M_fnct_icons_height=1;		/* Hauteur de l'empilement des ic“nes de fonction */
	static	int	M_fnct_icons_max;				/* Hauteur maxi: */
	static	int	M_fnct_icons_border;			/* Ligne d'alignement */
	static	int	M_data_icons_width;			/* Largeur de l'empilement des ic“nes de donn‚es */
	static	int	M_data_icons_max;				/* Largeur maxi: */
	static	int	M_data_icons_border;			/* Ligne d'alignement */
	static	int	M_icon_fcolor = ICON_PAPER_2 << 8;	/* Couleur de fond pour les icones, par d‚faut: blanc */
	static	int	M_nb_datagroups=0;			/* Nombre de groupes de donn‚es enregistr‚s */
	 
 
/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * init_desktop(-)
 *
 * Purpose:
 * --------
 * Ajuste l'arbre d'objets du bureau à la zone de travail de l'écran
 * courament utilisé
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 02.02.95: gŠre moyenne r‚solution
 */
void	init_desktop( void )
{
	int	foo;

	TRACE0( "Initializing " THIS_FILE );

	/*
	 * Si moyenne r‚solution, utilise le jeu d'ic“ne appropri‚:
	 */
	#if ACCEPT_SMALLFONTS
		if( G_cell_size_prop == 1 )
		{
			rsh_map .rs_iconblk = rs_iconblk_med;
		}
	#endif

	/*
	 * Relocation du RSH: 
	 */
	remap_rsh( &rsh_map );		/* Reloge le RSH */

	/*
	 * Adresse des arbres: 
	 */
	G_desktop_adr = &rs_object[ rs_trindex[ DESKTOP ] ];

	/*
	 * Modifie taille LOGO si n‚cessaire:
	 */
#if ACCEPT_SMALLFONTS
	if( G_cell_size_prop == 1 )
	{	/*
		 * Moyenne r‚solution
		 */
		int		nb_lines = rs_bitblk[ 0 ] .bi_hl;
		int		n_linesize = rs_bitblk[ 0 ] .bi_wb;	/* Taille en bytes */
		int		n_SrceLine = 2;
		char	*	pBitmap_Srce = &((char*) (rs_bitblk[ 0 ] .bi_pdata))[ 2 * n_linesize ];
		char	*	pBitmap_Dest = &((char*) (rs_bitblk[ 0 ] .bi_pdata))[ n_linesize ];
		int		nb_CreatedLines = 1;	/* La premiŠre ligne reste intacte et existe d‚j… */
		
		while( n_SrceLine <= nb_lines )
		{
			memcpy( pBitmap_Dest, pBitmap_Srce, n_linesize );
			
			/*
			 * On a cr‚‚ une ligne de plus:
			 */
			nb_CreatedLines++;

			n_SrceLine++;
			n_SrceLine++;
			pBitmap_Srce += n_linesize;
			pBitmap_Srce += n_linesize;
			pBitmap_Dest += n_linesize;

		}

		/*
		 * Nouvelle taille (/2):
		 * Aussi bien pour l'ombre que pour le logo:
		 */
		rs_bitblk[ 0 ] .bi_hl = nb_CreatedLines;
		rs_bitblk[ 1 ] .bi_hl = nb_CreatedLines;
		/*
		 *  Remonte l'ombre plus prŠs du logo:
		 */
		G_desktop_adr[ LOGSHAPE ] .ob_y = 11;
		G_desktop_adr[ LOGSHADE ] .ob_y = 12;
	}
#endif
	
	/*
	 * Regarde taille des ic“nes Desktop: 
	 */
	G_icon_w =	G_desktop_adr[ DSTDISK ] .ob_width;
	G_icon_h =	G_desktop_adr[ DSTDISK ] .ob_height;
	/* TRACE2( "Icon w=%d h=%d", G_icon_w, G_icon_h ); */
	
	/*
	 * Position X maximale que peuvent occuper les ic“nes ds une fenˆtre 
	 */
	G_iconw_max_w= G_ww_maxi - G_ww_maxi % G_icon_w;		/* Largeur max de la zone d'ic“nes */
	wind_calc( WC_BORDER, COMPLETE, 100, 100, G_iconw_max_w, 100,
						&foo, &foo, &G_iconw_max_w, &foo ); /* Larg max de la fenˆtre */

	
	/*
	 * Cr‚ation des infos sur la "fenˆtre bureau" 
	 */
	G_desk_params_adr= (WIPARAMS *)MALLOC( sizeof(WIPARAMS) ) ;
	G_desk_params_adr -> handle				= 0;
	G_desk_params_adr -> class					= CLASS_DESK;
	G_desk_params_adr -> type					= TYP_DESK;
	G_desk_params_adr -> draw_ptr .tree	= G_desktop_adr;
	G_desk_params_adr -> seen_x				= G_x_mini;
	G_desk_params_adr -> seen_y				= G_y_mini;
	G_desk_params_adr -> seen_w				= G_w_maxi;
	G_desk_params_adr -> seen_h				= G_h_maxi;
	G_desk_params_adr -> total_w				= G_w_maxi;
	G_desk_params_adr -> total_h				= G_h_maxi;
	G_desk_params_adr -> selected_icon		= 0;	/* Pas d'ic“ne s‚lectionn‚e */

	/*
	 * Ordonnancement du bureau 
	 * Fixe dimensions du bureau: 
	 */
	G_desktop_adr[0] .ob_x			= G_x_mini;
	G_desktop_adr[0] .ob_y			= G_y_mini;
	G_desktop_adr[0] .ob_width		= G_w_maxi;
	G_desktop_adr[0] .ob_height	= G_h_maxi;

	/*
	 * Place image centrale 
	 */
	G_desktop_adr[ LOGOBOX ] .ob_x =
		( G_w_maxi - G_desktop_adr[ LOGOBOX ] .ob_width ) / 2;
	G_desktop_adr[ LOGOBOX ] .ob_y =
		( G_h_maxi - G_icon_h - G_desktop_adr[ LOGOBOX ] .ob_height ) / 2;

	/*
	 * Fixe les couleurs (logiques): 
	 */
	if( G_nb_colors >= 4 )
	{	/*
		 * A partir de 4 couleurs: 
		 * Fond du bureau: 
		 */
		G_desktop_adr[ ROOT ] .ob_spec.obspec.fillpattern = DESK_PATTERN_4;
		G_desktop_adr[ ROOT ] .ob_spec.obspec.interiorcol = DESK_COLOR_4;
		/*
		 * Logo Stut One: 
		 */
		G_desktop_adr[ LOGSHAPE ] .ob_spec.bitblk -> bi_color = LOGO_COLOR_4;		/* Rouge */

		if ( G_nb_colors >= 16 )
		{	/*
			 * A partir de 16 couleurs: 
			 */
			TE_COLOR	te_color;
			te_color.value = 0;
			/*
			 * No de version 
			 */
			te_color.bf .textcol = VERSION_COLOR_16;
			G_desktop_adr[ VERTEXT ]  .ob_spec.tedinfo -> te_color = te_color.value;		/* Bleu */
			/*
			 * Couleur de fond des icones: 
			 */
			M_icon_fcolor = ICON_PAPER_16 << 8;
		}
	}

	/*
	 * PLace corbeille: (et en d‚duit les pos max pour les autres ic“nes) 
	 */
	G_desktop_adr[ DSTTRASH ] .ob_x= G_w_maxi - G_icon_w;
	M_data_icons_max = G_w_maxi - G_icon_w;	/* Les ic“nes de donn‚es ne pourront aller plus … droite que la corbeille! */
	M_data_icons_border = G_h_maxi - G_icon_h;
	
	G_desktop_adr[ DSTTRASH ] .ob_y= G_h_maxi - G_icon_h;
	M_fnct_icons_max = G_h_maxi - G_icon_h;
		/* Les ic“nes de fonction ne pourront aller plus bas
			que la corbeille! */
	M_fnct_icons_border = G_w_maxi - G_icon_w;

	/*
	 * Couleur corbeille: 
	 */
	if ( G_nb_colors >= 16 )
	{	/* A partir de 16 couleurs: */
		G_desktop_adr[ DSTTRASH ] .ob_spec.iconblk -> ib_char |= M_icon_fcolor ;
	}
		
	/*
	 * Place ic“nes de fonction: 
	 */
	place_fnct_icon( &G_desktop_adr[ DSTDISK ] );
	place_fnct_icon( &G_desktop_adr[ DSTTERM ] );

	/*
	 * Place ic“nes de donn‚es: 
	 */
	place_data_icon( &G_desktop_adr[ DSTARBO ] );
	place_data_icon( &G_desktop_adr[ DSTPAGES ] );
	place_data_icon( &G_desktop_adr[ DSTDATAS ] );
	place_data_icon( &G_desktop_adr[ DSTTEXTS ] );
	place_data_icon( &G_desktop_adr[ DSTPICS ] );

	/*
	 * Installation du fond de bureau 
	 */
	wind_set( 0, WF_NEWDESK, G_desktop_adr, ROOT );
	/*
	 * Affichage du nouveau bureau: 
	 */
	redraw( G_desk_params_adr, G_x_mini, G_y_mini, G_w_maxi, G_h_maxi, TAKE_CTRL );

}


/*
 * clear_desktop(-)
 *
 * Purpose:
 * --------
 * EnlŠve le bureau de l'application
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	clear_desktop( void )
{
	/* App prend en charge souris */
	WIND_UPDATE_BEG_MCTRL
	
	form_dial( FMD_START, 0, 0, 0, 0, G_x_mini, G_y_mini, G_w_maxi, G_h_maxi );
	/*	printf("\033Y  F"); */

	/* D‚sinstalle le bureau: */
	wind_set( 0, WF_NEWDESK, NULL, 0 );

	/* R‚affiche bureau: */
	form_dial( FMD_FINISH, 0, 0, 0, 0, G_x_mini, G_y_mini, G_w_maxi, G_h_maxi );
	/* printf("\033Y  -"); */

	/* Effet graphique de fermeture: */
	form_dial( FMD_SHRINK, 0, 0, 0, 0, G_x_mini, G_y_mini, G_w_maxi, G_h_maxi );

	/* AES peut reprendre la souris */
	WIND_UPDATE_END_MCTRL
}
 
 
/*
 * place_fnct_icon(-)
 *
 * Purpose:
 * --------
 * Placement des ic“nes de fonction sur le bureau:
 *
 * History:
 * --------
 * fplanque: Created
 */
void	place_fnct_icon( OBJECT *icone )
{
	if ( M_fnct_icons_height + G_icon_h > M_fnct_icons_max )
	{
		M_fnct_icons_border -= G_icon_w;
		M_fnct_icons_height	=	1;
		M_fnct_icons_max		-= G_icon_h;
	}
	icone -> ob_x = M_fnct_icons_border;
	icone -> ob_y = M_fnct_icons_height;
	icone -> ob_spec.iconblk -> ib_char |= M_icon_fcolor;		/* Couleur fond */
	M_fnct_icons_height += G_icon_h;
}


/*
 * place_data_icon(-)
 *
 * Purpose:
 * --------
 * Placement des ic“nes de données sur le bureau:
 *
 * History:
 * --------
 * fplanque: Created
 */
void	place_data_icon( OBJECT *icone )
{
	if ( M_data_icons_width + G_icon_w > M_data_icons_max )
	{
		M_data_icons_border	-= G_icon_h;
		M_data_icons_width	=	0;
		M_data_icons_max		-= G_icon_w;
	}
	icone -> ob_x = M_data_icons_width;
	icone -> ob_y = M_data_icons_border;
	icone -> ob_spec.iconblk -> ib_char |= M_icon_fcolor;		/* Couleur fond */
	M_data_icons_width += G_icon_w;
}


/*
 * init_icons(-)
 *
 * Purpose:
 * --------
 * Initialisation des ic“nes:
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	init_icons( void )
{
	ICONBLK	 *	exemple = G_desktop_adr[ DSTTRASH ] .ob_spec.iconblk;
	DATAGROUP *	datagroup_ptr;		/* Pointeur sur datagr en cours de registrement */

	/* Dessin d'un fant“me d'ic“ne: */
	/* 		0----2
				|    |
				|    |
				|    |
		  12--14	  4---6
		  |				|
		  10-----------8				*/

		G_fantome_icone[ 0 ]= exemple -> ib_xicon & 0xFFFE;
		G_fantome_icone[ 1 ]= exemple -> ib_yicon & 0xFFFE;

		G_fantome_icone[ 2 ]= exemple -> ib_xicon + exemple -> ib_wicon & 0xFFFE;
		G_fantome_icone[ 3 ]= G_fantome_icone[ 1 ];

		G_fantome_icone[ 4 ]= G_fantome_icone[ 2 ];
		G_fantome_icone[ 5 ]= exemple -> ib_ytext & 0xFFFE;

		G_fantome_icone[ 6 ]= exemple -> ib_xtext + exemple -> ib_wtext & 0xFFFE;
		G_fantome_icone[ 7 ]= G_fantome_icone[ 5 ];
		
		G_fantome_icone[ 8 ]= G_fantome_icone[ 6 ];
		G_fantome_icone[ 9 ]= exemple -> ib_ytext + exemple -> ib_htext & 0xFFFE;

		G_fantome_icone[ 10 ]= exemple -> ib_xtext & 0xFFFE;
		G_fantome_icone[ 11 ]= G_fantome_icone[ 9 ];

		G_fantome_icone[ 12 ]= G_fantome_icone[ 10 ];
		G_fantome_icone[ 13 ]= exemple -> ib_ytext & 0xFFFE;
		
		G_fantome_icone[ 14 ]= G_fantome_icone[ 0 ];		
		G_fantome_icone[ 15 ]= G_fantome_icone[ 13 ];

		G_fantome_icone[ 16 ]= G_fantome_icone[ 14 ];
		G_fantome_icone[ 17 ]= G_fantome_icone[ 1 ];
		
	/*	for( i=0; i<=5 */

	/*
	 * Minitel: 
	 */
	Icon_CopyIBLKtoICONIMG(	G_desktop_adr[ DSTTERM ] .ob_spec.iconblk, &(G_icon_images .minitel) );
	/*
	 * Donn‚es: 
	 */
	Icon_CopyIBLKtoICONIMG(	G_desktop_adr[ DSTDATAS ] .ob_spec.iconblk, &(G_icon_images .datas) );
	/*
	 * Textes: 
	 */
	Icon_CopyIBLKtoICONIMG(	G_desktop_adr[ DSTTEXTS ] .ob_spec.iconblk, &(G_icon_images .texte) );
	/*
	 * Images: 
	 */
	Icon_CopyIBLKtoICONIMG(	G_desktop_adr[ DSTPICS ] .ob_spec.iconblk, &(G_icon_images .image) );
	/*
	 * Ic“nes suppl‚mentaires:
	 */	
	#if ACCEPT_SMALLFONTS
		if( G_cell_size_prop == 1 )
		{	/*
			 * Moyenne:
			 */
			Icon_CopyIBLKtoICONIMG(	&rs_iconblk_med[8],  &(G_icon_images .affichages) );
			Icon_CopyIBLKtoICONIMG(	&rs_iconblk_med[9],  &(G_icon_images .saisies) );
			Icon_CopyIBLKtoICONIMG(	&rs_iconblk_med[10], &(G_icon_images .params) );
			Icon_CopyIBLKtoICONIMG(	&rs_iconblk_med[11], &(G_icon_images .liens) );
			Icon_CopyIBLKtoICONIMG(	&rs_iconblk_med[12], &(G_icon_images .erreurs) );
			Icon_CopyIBLKtoICONIMG(	&rs_iconblk_med[13], &(G_icon_images .motsclef) );
		}
		else
		{	/*
			 * Haute:
			 */
			Icon_CopyIBLKtoICONIMG(	&rs_iconblk[8],  &(G_icon_images .affichages) );
			Icon_CopyIBLKtoICONIMG(	&rs_iconblk[9],  &(G_icon_images .saisies) );
			Icon_CopyIBLKtoICONIMG(	&rs_iconblk[10], &(G_icon_images .params) );
			Icon_CopyIBLKtoICONIMG(	&rs_iconblk[11], &(G_icon_images .liens) );
			Icon_CopyIBLKtoICONIMG(	&rs_iconblk[12], &(G_icon_images .erreurs) );
			Icon_CopyIBLKtoICONIMG(	&rs_iconblk[13], &(G_icon_images .motsclef) );
		}
	#else
		/*
		 * On considŠre qu'opn est en haute:
		 */
		Icon_CopyIBLKtoICONIMG(	&rs_iconblk[8],  &(G_icon_images .affichages) );
		Icon_CopyIBLKtoICONIMG(	&rs_iconblk[9],  &(G_icon_images .saisies) );
		Icon_CopyIBLKtoICONIMG(	&rs_iconblk[10], &(G_icon_images .params) );
		Icon_CopyIBLKtoICONIMG(	&rs_iconblk[11], &(G_icon_images .liens) );
		Icon_CopyIBLKtoICONIMG(	&rs_iconblk[12], &(G_icon_images .erreurs) );
		Icon_CopyIBLKtoICONIMG(	&rs_iconblk[13], &(G_icon_images .motsclef) );
	#endif

	/******************************************/
	/* Initialisation des groupes de donn‚es: */
	/******************************************/
	/* 
	 * Alloue zone m‚moire pour les infos: 
	 */
		G_datagroups = MALLOC( sizeof( DATAGROUP ) * NB_DATAGROUPS );
		datagroup_ptr = G_datagroups;		/* Ptr sur 1er datagroup */
		register_datagroup( DSTARBO,  datagroup_ptr++ );	
		register_datagroup( DSTPAGES, datagroup_ptr++ );	
		register_datagroup( DSTDATAS, datagroup_ptr++ );	
		register_datagroup( DSTTEXTS, datagroup_ptr++ );	
		register_datagroup( DSTPICS,  datagroup_ptr++ );	
		/* printf("Nbre de G_datagroups enregistr‚s: %d\n",M_nb_datagroups); */
}


/*
 * 02.02.95:
 */
void	Icon_CopyIBLKtoICONIMG(
			ICONBLK * pIconBlk,
			ICONIMG * pIconImg )
{			
	pIconImg -> mask 		=	pIconBlk -> ib_pmask;
	pIconImg -> data 		=	pIconBlk -> ib_pdata;
	pIconImg -> icon_y	=	pIconBlk -> ib_yicon;
	pIconImg -> icon_h	=	pIconBlk -> ib_hicon;
	pIconImg -> char_x	=	pIconBlk -> ib_xchar;
	pIconImg -> char_y	=	pIconBlk -> ib_ychar;
}

/*
 * 02.02.95:
 */
void	Icon_CopyICONIMGtoIBLK(
			ICONIMG * pIconImg,
			ICONBLK * pIconBlk )
{			
	pIconBlk -> ib_pmask = pIconImg -> mask;
	pIconBlk -> ib_pdata = pIconImg -> data;
	pIconBlk -> ib_yicon = pIconImg -> icon_y;
	pIconBlk -> ib_hicon = pIconImg -> icon_h;
	pIconBlk -> ib_xchar = pIconImg -> char_x;
	pIconBlk -> ib_ychar = pIconImg -> char_y;
}


/*
 * register_datagroup(-)
 *
 * Purpose:
 * --------
 * Enregistre un groupe de donn‚es dans la liste
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	register_datagroup( int	icon_no, DATAGROUP *datagroup_ptr )
{
	/*
	 * state de l'ic“ne: 
	 */
	unsigned int	*icon_state = &(G_desktop_adr[ icon_no ] .ob_state);
	/*
	 * state ‚tendus: 
	 */
	DATATYPE			ext_state	= (*icon_state) >> 9;
	/*
	 * Nom de l'unit‚ de stockage virtuelle: 
	 */
	char				*data_device;		
	/* printf("state ‚tendus=%u\n",ext_state); */

	/*
	 * Fixe certains ParamŠtres Datagroup (Pas tous!): 
	 */		
	datagroup_ptr -> icon_no		= icon_no;		/* No datagr [0...] */
	datagroup_ptr -> DataType		= ext_state;	/* Type de donn‚es */

	init_vars_datagroup( datagroup_ptr );

	/*
	 * Fixe le nom de l'unit‚ de stockage virtuelle: 
	 */
	switch( ext_state )
	{
		case	DTYP_ARBO:
			datagroup_ptr -> root_dir = NULL;	/* Pas encore de dossier reli‚ */
			data_device = "ARB:";
			break;
			
		case	DTYP_PAGES:
			datagroup_ptr -> root_dir = create_EmptyDataDir( datagroup_ptr, NULL );	/* Cr‚e dossier vide */
			data_device = "ECR:";
			break;
			
		case	DTYP_DATAS:
			datagroup_ptr -> root_dir = create_EmptyDataDir( datagroup_ptr, NULL );	/* Cr‚e dossier vide */
			data_device = "DAT:";
			break;
			
		case	DTYP_TEXTS:
			datagroup_ptr -> root_dir = create_EmptyDataDir( datagroup_ptr, NULL );	/* Cr‚e dossier vide */
			data_device = "TXT:";
			break;
			
		case	DTYP_PICS:
			datagroup_ptr -> root_dir = create_EmptyDataDir( datagroup_ptr, NULL );	/* Cr‚e dossier vide */
			data_device = "IMG:";
			break;

		default:
			datagroup_ptr -> root_dir = create_EmptyDataDir( datagroup_ptr, NULL );	/* Cr‚e dossier vide */
			data_device = "xxx:";

	}
	strcpy( datagroup_ptr -> data_device, data_device );

	/* Nouveaux state ‚tendus = No du datagroup concern‚ [1...]: */
	/* Une ic“ne sans datagroup aura donc pour ext_state: 0 */
	ext_state	= (++M_nb_datagroups) << 9;
	/* Fixe nouveaux state: */
	(*icon_state) &= 0x01FF;		/* Efface ancien ext_state */
	(*icon_state) |= ext_state;	/* Fixe nouveaux.. */
}
 
 

/*
 * dgroup_adr_byiconno(-)
 *
 * Purpose:
 * --------
 * Fournit l'adresse d'un groupe de donn‚es
 * en fonction du no de l'ic“ne
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
DATAGROUP	*dgroup_adr_byiconno( int icon_no )
{
	int	data_no = ( (G_desktop_adr[ icon_no ] .ob_state) >>9) -1;	/* Ext flags de l'ic“ne */

	return	&G_datagroups[ data_no ];
}

 

/*
 * find_datagroup_byType(-)
 *
 * Purpose:
 * --------
 * Fournit l'adresse d'un groupe de donn‚es
 * en fonction du type de donn‚es qu'il contient
 *
 * Algorythm:
 * ----------  
 * V‚rifie tous les DATAGROUPS pour voir si le type existe
 *
 * History:
 * --------
 * 06.07.94: fplanque: Created
 * 11.07.94: Recherche plus fiable du DATAGROUP concern‚
 */
DATAGROUP	*	find_datagroup_byType( 		/* Out: Ptr sur datagroup */
						DATATYPE		DataType )	/* In:  Type DTYP_* */
{
	int	i;

	for( i=0; i<NB_DATAGROUPS; i++ )
	{
		if( G_datagroups[ i ] .DataType == DataType )
		{
			return	& G_datagroups[ i ];
		}
	}

	return	NULL;
}
