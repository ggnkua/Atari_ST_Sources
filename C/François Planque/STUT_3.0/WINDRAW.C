/*
 * windraw.c
 *
 * Purpose:
 * --------
 *	DESSIN DU CONTENU DES FENETRES sous GEM
 *	
 * History:
 * --------
 * 17.06.94: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"WINDRAW.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>					/* header standard */
	#include	<stdlib.h>					/* header librairie de fnct std */
	#include <string.h>					/* header tt de chaines */		
	#include	<tos.h>
	#include	<aes.h>						/* header AES */
	#include <vdi.h>						/* header VDI */
   

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"
	#include "WINDR_PU.H"	
	#include	"TEXT_PU.H"						/* Infos sur texte VDI */
	#include	"AESDEF.H"
	#include "VDI_PU.H"
	

/*
 * ------------------------ PROTOTYPES -------------------------
 */


/*
 * EXTernal prototypes:
 */
	/*
	 * Sp‚cial: 
	 */
	extern	void	ping( void );				/* Ping! */
	extern	int	max(			/* Out: Maximum des deux INT */
							int a,	/* In:  INT #1 */
							int b);	/* In:  INT #2 */
	extern 	int	rcintersect( int area_x, int area_y, int area_w, int area_h,
							  int *box_x, int *box_y, int *box_w, int *box_h );

/*
 * PUBlic INTernal prototypes:
 */
	static	int	start_WINDRAW( 					/* In: =TRUE si fenˆtre non overlapp‚e */
							WIPARAMS *	pWiParams );	/* In: fenˆtre que l'on s'apprˆte … redessiner (can be NULL) */
	static	void	end_WINDRAW( void );
	static	void	redraw( 
							WIPARAMS *pWiParams,		/* In: fenˆtre … redessiner */ 
							int area_x, 				/* In: zone de l'‚cran en dehors de laquelle */
							int area_y, 				/*     il ne faut pas dessiner */
							int area_w, 
							int area_h, 
							int take_control );		/* In: =CTRL_OK si on a d‚j… r‚serv‚ l'‚cran, sinon: TAKE_CTRL */
	static	void	redraw_textline( 
							WIPARAMS	*	pWiParams,	/* In: ParamŠtres de la fenˆtre */
							TEXTLINE	*	pTextLine,	/* In: Ptr sur ligne … redessiner */
							long			l_NoLine,	/* In: No de la ligne … redessiner */
							int			n_col,		/* In: Colonne … partir de laquelle on commence le redraw */
							int			n_length );	/* In: Longueur … afficher, NIL_1 si on veut la longueur du texte */

/*
 * PRIVate INTernal prototypes:
 */
	static	void	redraw_empty( 
							WIPARAMS *	pWiParams,	
							int area_x, 
							int area_y, 
							int area_w, 
							int area_h );
	static	void	redraw_form( 
							WIPARAMS *	pWiParams,	
							int area_x, 
							int area_y, 
							int area_w, 
							int area_h );
	static	void	redraw_picture( 
							WIPARAMS *	pWiParams,	
							int area_x, 
							int area_y, 
							int area_w, 
							int area_h );
	static	void	redraw_text( 
							WIPARAMS *wi_params_adr, 
							int area_x, 
							int area_y, 
							int area_w, 
							int area_h );


/*
 * ------------------------ VARIABLES -------------------------
 */
    

/*
 * External variables: 
 */

	/* 
	 * G‚n‚ral: 
	 */
	extern	int	G_ap_id;						/* Identification par l'AES */
	extern	int	G_x_mini, G_y_mini;		/* Coord sup gauche de l'‚cran */
	extern	int	G_w_maxi, G_h_maxi;		/* Taille de l'‚cran de travail */
	extern	char	*G_tmp_buffer;				/* Tampon */
	/*
	 * VDI: 
	 */
	extern	int	G_ws_handle;				/* handle virtual workstation VDI */
	extern	int 	G_pxyarray[18];			/* Liste de coord X,Y pour le VDI */
	extern	int	G_pxyarray2[10];			/* 2Šme liste */
	extern	MFDB	G_plogMFDB;					/* block ‚cran logique */


/*
 * ------------------------ FUNCTIONS -------------------------
 */



/*
 * start_WINDRAW(-)
 *
 * Purpose:
 * --------
 * Signale le d‚but d'un affichage dans une fenˆtre
 * cette fonction va donc r‚server l'‚cran
 * En option: renvoie TRUE si la fenˆtre est affich‚e dans un unique
 * rectangle: no overlap
 *
 * Notes:
 * ------
 * Ne cache pas la souris.
 * Le r‚sultat n'est pas vraiment la r‚ponse … overlap?
 * Ca dirt plutot si on est en un seul bloc ou en plusizur, mais on peut aussi voir 1 seul bloc d'une fenˆtre a moiti‚ cach‚e
 *
 * History:
 * --------
 * 17.06.94: fplanque: Created
 * 04.12.94: correction bug: v‚rifie si TOUTE la feneˆtre est non overlapp‚e, pas seulement 1 rectangle
 */
int	start_WINDRAW( 					/* In: =TRUE si fenˆtre non overlapp‚e */
			WIPARAMS *	pWiParams )		/* In: fenˆtre que l'on s'apprˆte … redessiner (can be NULL) */
{
	/* App prend en charge souris */
	WIND_UPDATE_BEG_MCTRL
	wind_update( BEG_UPDATE );			/* D‚but de construction ‚cran */

	/*
	 * Teste si la fenˆtre est overlapp‚e ou non:
	 */
	if( pWiParams != NULL )
	{	/*
		 * Si on veut connaitre cette information:
		 */
		int	n_wiHandle = pWiParams -> handle;
		int	n_top_handle;
		int	xr, yr, wr, hr;
		
		/*
		 * V‚rifie d‚j… si la fenˆtre est au top:
		 */
		wind_get( 0, WF_TOP, &n_top_handle );
		if( n_top_handle == n_wiHandle )
		{
			return	TRUE_1;		/* OK, fenˆtre non overlapp‚e */
		}
		
		wind_get( n_wiHandle, WF_FIRSTXYWH, &xr, &yr, &wr, &hr );
	
		if( wr == pWiParams -> seen_w && hr == pWiParams -> seen_h )
		{	/*
			 * Toute la fenˆtre visible tient en un seul rectangle:
			 */
			return	TRUE_1;		/* fenˆtre non OVERLAPPEE */
		}
	}
	
	return FALSE0;		/* Fenˆtre est OVERLAPPEE */
}


/*
 * end_WINDRAW(-)
 *
 * Purpose:
 * --------
 * Signale la fin d'un affichage dans une fenˆtre
 * cette fonction va donc lib‚rer l'‚cran r‚serv‚ par start_WINDRAW()
 *
 * Notes:
 * ------
 * Ne montre pas la souris.
 *
 * History:
 * --------
 * 17.06.94: fplanque: Created
 */
void	end_WINDRAW( void )
{
	wind_update( END_UPDATE );			/* Fin de construction ‚cran */
	/* AES peut reprendre la souris */
	WIND_UPDATE_END_MCTRL
}


/*
 * send_fullredraw(-)
 *
 * Purpose:
 * --------
 * Envoie un msg auto-adress‚ 
 * demandant un redraw complet d'une fenˆtre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	send_fullredraw( WIPARAMS *wi_params_adr )
{	
	int	msg[8];								/* Buffer contenant le message */
	
	msg[0] = WM_REDRAW;						/* Type du message */
	msg[1] = G_ap_id;							/* No AES de l'application */
	msg[2] = 0;									/* Longueur standard */
	msg[3] = wi_params_adr -> handle;	/* Handle de la fenˆtre */
	wind_get( wi_params_adr -> handle, WF_WORKXYWH, &msg[4], &msg[5],
		 &msg[6], &msg[7] );	/* Coordonn‚es de la zone … red‚ssiner... */
	appl_write( G_ap_id, 16, &msg );		/* Envoie le message de redraw */
}


/*
 * ------------------------ REDRAW -------------------------
 */


/*
 * redraw(-)
 *
 * Purpose:
 * --------
 * Redraw du contenu d'une fenˆtre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.05.94: Sorti gestion des textes et r‚organisation
 * 25.05.94: Sorti chaque type de redraw ds fnct ind‚pendante
 * 25.09.94: redraw des fen TYP_ERRORS
 */
void	redraw( 
			WIPARAMS *pWiParams,		/* In: fenˆtre … redessiner */ 
			int area_x, 				/* In: zone de l'‚cran en dehors de laquelle */
			int area_y, 				/*     il ne faut pas dessiner */
			int area_w, 
			int area_h, 
			int take_control )		/* In: =CTRL_OK si on a d‚j… r‚serv‚ l'‚cran, sinon: TAKE_CTRL */
{
	/*
	 * Auparavant, on s'assure que la liste des rectangles ne va pas bouger 
	 */
	if( take_control == TAKE_CTRL )
	{	/*
	 	 * Si l'application n'a pas encore pris le contr“le de l'‚cran 
		 * ... on le fait maintenant: 
		 */
		/* App prend en charge souris */
		WIND_UPDATE_BEG_MCTRL
		wind_update( BEG_UPDATE );			/* D‚but de construction ‚cran */
	}

	/*
	 * Efface le ptr souris:
	 */
	graf_mouse( M_OFF, NULL);	

	/*
	 * Appelle la routine de redraw appropri‚e:
	 */
	switch ( pWiParams -> type )
	{
		case TYP_EMPTY: 						/* Fenˆtre vide */
			redraw_empty( pWiParams, area_x, area_y, area_w, area_h );
			break;

		case TYP_PI3:								/* Image PI3 */
			redraw_picture( pWiParams, area_x, area_y, area_w, area_h );
			break;

		case	TYP_DESK:
		case	TYP_TREE:
		case	TYP_ARBO:
		case	TYP_DIR:
			redraw_form( pWiParams, area_x, area_y, area_w, area_h );
			break;
			
		case	TYP_TEXT:
		case	TYP_DEBUG:
		case	TYP_TRACK:
		case	TYP_ERRORS:
			redraw_text( pWiParams, area_x, area_y, area_w, area_h );
			break;
			
		default:				/* Un truc qu'on ne sait pas d‚ssiner! */
			ping();
	}
		
	/*
	 * Affiche le ptr souris:
	 */
	graf_mouse( M_ON, 0);				

	/*
	 * Peut-ˆtre faut il signaler la fin de la construction de l'‚cran: 
	 */
	if( take_control == TAKE_CTRL )
	{	/* Si l'application a pris le contr“le de l'‚cran juste pour le redraw */
		/* ... on le rends maintenant: */
		wind_update( END_UPDATE );			/* Fin de construction ‚cran */
		/* AES peut reprendre la souris */
		WIND_UPDATE_END_MCTRL
	}
}



/*
 * redraw_empty(-)
 *
 * Purpose:
 * --------
 * Redraw d'une fenˆtre vide(!)
 *
 * Notes:
 * ------
 * Cette fonction est pr‚vue pour ˆtre appell‚e par redraw()
 *
 * History:
 * --------
 * 25.05.94: fplanque: Created by extracting from redraw()
 */
void	redraw_empty( 
			WIPARAMS *	pWiParams,	
			int area_x, 
			int area_y, 
			int area_w, 
			int area_h )
{
	int	wi_handle = pWiParams -> handle;	/* Handle fenˆtre */
	int	xr,yr,wr,hr;					/* Coords rectangles fournis par AES */
	int	xr2, yr2;						/* Coords inf droites pour VDI */

	/*
	 * Redraw de chacun des rectangles composant la fenˆtre visible:
	 */
	wind_get( wi_handle, WF_FIRSTXYWH, &xr, &yr, &wr, &hr );
	while( wr && hr )					
	{	/*
		 * Tant que dimensions non nulles 
		 */
		if ( rcintersect ( G_x_mini, G_y_mini, G_w_maxi, G_h_maxi, &xr, &yr, &wr, &hr ) )
		{	/*
			 * Si rectangle est dans l'‚cran 
			 */
			if ( rcintersect( area_x, area_y, area_w, area_h, &xr, &yr, &wr, &hr ) )
			{	/* 
				 * Si rect est dans la zone de redraw:
				 */
				xr2 = xr +wr -1;		/* Coords inf droites du rectangle */
				yr2 = yr +hr -1;

				G_pxyarray[0]=xr;
				G_pxyarray[1]=yr;
				G_pxyarray[2]=xr2;
				G_pxyarray[3]=yr2;
				vr_recfl( G_ws_handle, G_pxyarray );		/* Carr‚ blanc! */
			}
		}
		wind_get( wi_handle, WF_NEXTXYWH, &xr, &yr, &wr, &hr );
	}
}



/*
 * redraw_form(-)
 *
 * Purpose:
 * --------
 * Redraw d'une fenˆtre contenant un formulaire
 *
 * Notes:
 * ------
 * Cette fonction est pr‚vue pour ˆtre appell‚e par redraw()
 *
 * History:
 * --------
 * 25.05.94: fplanque: Created by extracting from redraw()
 */
void	redraw_form( 
			WIPARAMS *	pWiParams,	
			int area_x, 
			int area_y, 
			int area_w, 
			int area_h )
{
	int	wi_handle = pWiParams -> handle;	/* Handle fenˆtre */
	int	xr,yr,wr,hr;					/* Coords rectangles fournis par AES */

	/*
	 * Adresse formulaire: 
	 */
	OBJECT * tree = pWiParams -> draw_ptr.tree;		/* Adr form */

	/*
	 * Pour l'arborescence, il faut positionner le formulaire d'obord: 
	 */
	if ( pWiParams -> type == TYP_TREE )
	{	/* Si on va faire un redraw de l'arbo: */
		tree[ ROOT ] .ob_x = pWiParams -> work_x - (int) (pWiParams -> seen_x) +OUTLINE_INWIN;
		tree[ ROOT ] .ob_y = pWiParams -> work_y - (int) (pWiParams -> seen_y) +OUTLINE_INWIN;
	}

	/*
	 * Redraw de chacun des rectangles composant la fenˆtre visible:
	 */
	wind_get( wi_handle, WF_FIRSTXYWH, &xr, &yr, &wr, &hr );
	while( wr && hr )					
	{	/*
		 * Tant que dimensions non nulles 
		 */
		if ( rcintersect ( G_x_mini, G_y_mini, G_w_maxi, G_h_maxi, &xr, &yr, &wr, &hr ) )
		{	/*
			 * Si rectangle est dans l'‚cran 
			 */
			if ( rcintersect( area_x, area_y, area_w, area_h, &xr, &yr, &wr, &hr ) )
			{	/* 
				 * Si rect est dans la zone de redraw:
				 */
				objc_draw( tree, 0, 5, xr, yr, wr, hr );
			}
		}
		wind_get( wi_handle, WF_NEXTXYWH, &xr, &yr, &wr, &hr );
	}
}




/*
 * redraw_picture(-)
 *
 * Purpose:
 * --------
 * Redraw d'une image bitmap dans une fenˆtre
 *
 * Notes:
 * ------
 * Cette fonction est pr‚vue pour ˆtre appell‚e par redraw()
 *
 * History:
 * --------
 * 25.05.94: fplanque: Created by extracting from redraw()
 */
void	redraw_picture( 
			WIPARAMS *	pWiParams,	
			int area_x, 
			int area_y, 
			int area_w, 
			int area_h )
{
	int	wi_handle = pWiParams -> handle;	/* Handle fenˆtre */
	int	xr,yr,wr,hr;					/* Coords rectangles fournis par AES */
	int	xr2, yr2;						/* Coords inf droites pour VDI */

	/*
	 * Coord zone de travail de la fenˆtre:
	 */
	int	wkspace_x = pWiParams -> work_x;
	int	wkspace_y = pWiParams -> work_y;

	/*
	 * Offset de la fenˆtre sur le document: 
	 */
	int	offset_x= (int) (pWiParams -> seen_x);
	int	offset_y= (int) (pWiParams -> seen_y);
				/* printf( "\rseen_x=%d seen_y=%d  ", offset_x, offset_y ); */
		
	/*
	 * Redraw de chacun des rectangles composant la fenˆtre visible:
	 */
	wind_get( wi_handle, WF_FIRSTXYWH, &xr, &yr, &wr, &hr );
	while( wr && hr )					
	{	/*
		 * Tant que dimensions non nulles 
		 */
		if ( rcintersect ( G_x_mini, G_y_mini, G_w_maxi, G_h_maxi, &xr, &yr, &wr, &hr ) )
		{	/*
			 * Si rectangle est dans l'‚cran 
			 */
			if ( rcintersect( area_x, area_y, area_w, area_h, &xr, &yr, &wr, &hr ) )
			{	/* 
				 * Si rect est dans la zone de redraw:
				 */
				xr2 = xr +wr -1;		/* Coords inf droites du rectangle */
				yr2 = yr +hr -1;

				G_pxyarray[0]=offset_x+xr-wkspace_x; /* Coord source */
				G_pxyarray[1]=offset_y+yr-wkspace_y;
				G_pxyarray[2]=G_pxyarray[0]+wr-1;
				G_pxyarray[3]=G_pxyarray[1]+hr-1;
				G_pxyarray[4]=xr;							/* Coord destination */
				G_pxyarray[5]=yr;
				G_pxyarray[6]=xr2;
				G_pxyarray[7]=yr2;
				vro_cpyfm( G_ws_handle, S_ONLY, G_pxyarray,
							  pWiParams -> draw_ptr.psrcMFDB, &G_plogMFDB);
			}
		}
		wind_get( wi_handle, WF_NEXTXYWH, &xr, &yr, &wr, &hr );
	}
}



/*
 * redraw_text(-)
 *
 * Purpose:
 * --------
 * Redraw d'un texte dans une fenˆtre
 *
 * Notes:
 * ------
 * Cette fonction est pr‚vue pour ˆtre appell‚e par redraw()
 *
 * History:
 * --------
 * 25.05.94: fplanque: Gestion curseur ds textes
 * 25.05.94: fplanque: Created by extracting from redraw()
 * 25.05.94: fplanque: Simplification, retrait des variables inutiles
 */
void	redraw_text( 
			WIPARAMS *	pWiParams,	
			int area_x, 
			int area_y, 
			int area_w, 
			int area_h )
{
	int	wi_handle = pWiParams -> handle;	/* Handle fenˆtre */
	int	xr,yr,wr,hr;					/* Coords rectangles fournis par AES */
	int	xr2, yr2;						/* Coords inf droites pour VDI */
	int	hout, vout;						/* R‚ponse VDI */
	int	foo;								/* Bidon */
	int	line_y;							/* Coordonn‚e pix Y de la ligne en cours d'affichage */

	/* 
	 * Infos sur le texte: 
	 */
	TEXT_DRAWPAR	* pTextDrawPar = pWiParams -> draw_ptr.pTextDrawPar;
	/*
	 * Ligne portant le Curseur:
	 */
	TEXTLINE	* pTextLine_Csr = pTextDrawPar -> pTextLine_edit;
	/*
	 * Ligne en cours d'affichage:
	 */
	TEXTLINE	*line_ptr;					


	/*
	 * Calcule coord pix Y sup‚rieure 
	 * de la premiŠre ligne affich‚e (topline): 
	 */
	int	line_h = pTextDrawPar -> n_cell_h;									/* Hauteur d'une ligne en pixels */
	int	text_y = (pWiParams -> work_y) 										/* Pos Y sup de la topline) */
						- line_h + (line_h / TEXT_VMARGINS_LINERATIO) 		/* Laisse un peu d'espace blanc */
						- (int)((pWiParams -> seen_y) % line_h);		/* Tient compte du fait que la ligne peut ˆtre d‚cal‚e par rapport … son alignement vertical initial */

	/*
	 * Calcule le 1er car … afficher … partir de la gauche
	 * et sa coord pix X:
	 */
	int	cell_w 	 = pTextDrawPar -> n_cell_w;								/* Largeur d'un emplacement caractŠre en pixels */
	int	first_col = ((int)(pWiParams -> seen_x) - TEXT_HMARGINS_WIDTH) / cell_w;
	int	text_x	 = (pWiParams -> work_x)						/* Position en pixels pour l'affichage des lignes de texte */
							- ((int)(pWiParams -> seen_x) - TEXT_HMARGINS_WIDTH) % cell_w;	/* Laisse une marge de 4 pixels sur la gauche */


	/*
	 * Fixe coordonn‚es de la r‚f d'un caractŠre 
	 */
	vst_alignment ( G_ws_handle, HALIGN_LEFT, VALIGN_TOP, &hout, &vout );
								/*	printf("Hor: %d, Vert: %d\n", hout, vout); */
	/*
	 * Fixe couleur: 
	 */
	vst_color( G_ws_handle, 1 );

	/*
	 * Fixe taille: 
	 */
	vst_point( G_ws_handle, pTextDrawPar -> n_points, &foo, &foo, &foo, &foo );

	/*
	 * Redraw de chacun des rectangles composant la fenˆtre visible:
	 */
	wind_get( wi_handle, WF_FIRSTXYWH, &xr, &yr, &wr, &hr );
	while( wr && hr )					
	{	/*
		 * Tant que dimensions non nulles 
		 */
		if ( rcintersect ( G_x_mini, G_y_mini, G_w_maxi, G_h_maxi, &xr, &yr, &wr, &hr ) )
		{	/*
			 * Si rectangle est dans l'‚cran 
			 */
			if ( rcintersect( area_x, area_y, area_w, area_h, &xr, &yr, &wr, &hr ) )
			{	/* 
				 * Si rect est dans la zone de redraw:
				 */
				xr2 = xr +wr -1;		/* Coords inf droites du rectangle */
				yr2 = yr +hr -1;

				/*
				 * Pointeur sur la ligne texte en cours d'affichage: 
				 */
				line_ptr = pTextDrawPar -> pTextLine_top;	/* On commence tjs au d‚but de la fenˆtre: */

				/*
				 * Zone a red‚ssiner: 
				 */
				G_pxyarray[0]=xr;
				G_pxyarray[1]=yr;
				G_pxyarray[2]=xr2;
				G_pxyarray[3]=yr2;
				vs_clip( G_ws_handle, YES1, G_pxyarray );	/* Clipping pour text */

				for ( line_y = text_y; 
						(line_y <= yr2) && ( line_ptr != NULL );
						line_y += line_h, line_ptr = line_ptr -> next )
				{
					/*
					 * Efface portion d'‚cran correspondant … la ligne:
					 */
					G_pxyarray[1]=line_y;						/* Position Y de la ligne */
					G_pxyarray[3]=line_y + line_h -1;		/* Bas de la ligne */
					vr_recfl( G_ws_handle, G_pxyarray );	/* Fond blanc! */

					/*
					 * Affiche texte de la ligne:
					 */
					if (	line_ptr -> text  !=  NULL
						&&	line_ptr -> length >= first_col )
					{
						v_gtext(	G_ws_handle,
									text_x, line_y, 
									&(line_ptr -> text[ first_col ]) );	/* Long max = INT_IN_SIZE = 128 caractŠres (1 car par int) */
					}
					
					/*
					 * Affiche le curseur:
					 */
					if( line_ptr == pTextLine_Csr )
					{	/*
						 * Si on est sur la Ligne portant le cusreur:
						 */
						G_pxyarray2[0] = text_x + (pTextDrawPar -> n_ColCsr - first_col) * cell_w;	/* Position X du curseur */
						G_pxyarray2[1] = line_y;						/* Position Y de la ligne */
						G_pxyarray2[2] = G_pxyarray2[0]+CURSOR_WIDTH-1;	/* Position X droite du curseur */
						G_pxyarray2[3] = G_pxyarray[3];				/* Bas de la ligne */
						vsf_interior( G_ws_handle, FIS_SOLID );	/* remplissage: PLEIN(couleur courante) */
						vswr_mode( G_ws_handle, MD_XOR );
						vr_recfl( G_ws_handle, G_pxyarray2 );	 
						vswr_mode( G_ws_handle, MD_REPLACE );
						vsf_interior( G_ws_handle, FIS_HOLLOW );	/* remplissage: VIDE(blanc) */
					}
				}
				
				if (line_y <= yr2)
				{	/*
					 * S'il reste du blanc en dessous: 
					 */
					G_pxyarray[1]=line_y;						/* Position Y de la ligne */
					G_pxyarray[3]=yr+hr-1;						/* Bas de la zone … redessiner */
					vr_recfl( G_ws_handle, G_pxyarray );	/* Fond blanc! */
				}
			}
		}
		wind_get( wi_handle, WF_NEXTXYWH, &xr, &yr, &wr, &hr );
	}
	vs_clip( G_ws_handle, NO0, G_pxyarray );	/* Clipping OFF! */
}



/*
 * redraw_textline(-)
 *
 * Purpose:
 * --------
 * Redraw d'une ligne de texte dans une fenˆtre
 *
 * Algorythm:
 * ----------  
 * - ConsidŠre que l'application d‚tient le CONTROLE de l'‚cran
 * - Efface/restore pointeur souris
 *
 * Suggest:
 * --------
 * Faire une version optimis‚e … utiliser lorsque la fenˆtre est
 * au premier plan.
 *
 * History:
 * --------
 * 30.05.94: fplanque: created
 * 18.06.94: Permet maintenant de sp‚cifier la longueur de ligne … afficher
 * 20.08.94: n_minLength est maintenant en pixels
 */
void	redraw_textline( 
			WIPARAMS	*	pWiParams,		/* In: ParamŠtres de la fenˆtre */
			TEXTLINE	*	pTextLine,		/* In: Ptr sur ligne … redessiner */
			long			l_NoLine,		/* In: No de la ligne … redessiner */
			int			n_col,			/* In: Colonne … partir de laquelle on commence le redraw */
			int			n_minLength )	/* In: Longueur minimale … afficher en pixels */
{
	int	wi_handle = pWiParams -> handle;	/* Handle fenˆtre */
	int	xr,yr,wr,hr;					/* Coords rectangles fournis par AES */
	int	hout, vout;						/* R‚ponse VDI */
	int	foo;								/* Bidon */

	/* 
	 * Infos sur le texte: 
	 */
	TEXT_DRAWPAR * pTextDrawPar = pWiParams -> draw_ptr.pTextDrawPar;

	/*
	 * Calcule coord pix Y sup‚rieure 
	 * de la ligne … afficher: 
	 */
	int	line_h = pTextDrawPar -> n_cell_h;								/* Hauteur d'une ligne en pixels */
	int	text_y = (pWiParams -> work_y) 									/* Pos Y sup de la topline */
						- line_h + (line_h / TEXT_VMARGINS_LINERATIO) 	/* Laisse un peu d'espace blanc */
						- (int)((pWiParams -> seen_y) % line_h);			/* Tient compte du fait que la ligne peut ˆtre d‚cal‚e par rapport … son alignement vertical initial */
	int	line_y = text_y + (int)( l_NoLine - pTextDrawPar -> l_topline ) * line_h;

	/*
	 * Calcule le 1er car … afficher … partir de la gauche
	 * et sa coord pix X:
	 */
	int	cell_w 	 = pTextDrawPar -> n_cell_w;								/* Largeur d'un emplacement caractŠre en pixels */
	int	first_col = ((int)(pWiParams -> seen_x) - TEXT_HMARGINS_WIDTH) / cell_w;
	int	text_x	 = (pWiParams -> work_x)						/* Position en pixels pour l'affichage des lignes de texte */
							- ((int)(pWiParams -> seen_x) - TEXT_HMARGINS_WIDTH) % cell_w;	/* Laisse une marge de 4 pixels sur la gauche */
	int	line_x	 = text_x + ( n_col - first_col ) * cell_w;	/* Position de la premiŠre colonne … afficher */

	int	n_areaW;

	/*
	 * Calcule coordonn‚es du rectangle … redessiner:
	 */
	n_areaW = max( n_minLength,
						(pTextLine -> length - n_col) * cell_w + CURSOR_WIDTH );

	/*
	 * Fixe coordonn‚es de la r‚f d'un caractŠre 
	 */
	vst_alignment ( G_ws_handle, HALIGN_LEFT, VALIGN_TOP, &hout, &vout );
								/*	printf("Hor: %d, Vert: %d\n", hout, vout); */
	/*
	 * Fixe couleur: 
	 */
	vst_color( G_ws_handle, 1 );

	/*
	 * Fixe taille: 
	 */
	vst_point( G_ws_handle, pTextDrawPar -> n_points, &foo, &foo, &foo, &foo );

	/*
	 * Efface le ptr souris:
	 */
	graf_mouse( M_OFF, NULL);	

	/*
	 * Redraw de chacun des rectangles composant la fenˆtre visible:
	 */
	wind_get( wi_handle, WF_FIRSTXYWH, &xr, &yr, &wr, &hr );
	while( wr && hr )					
	{	/*
		 * Tant que dimensions non nulles 
		 */
		if ( rcintersect ( G_x_mini, G_y_mini, G_w_maxi, G_h_maxi, &xr, &yr, &wr, &hr ) )
		{	/*
			 * Si rectangle est dans l'‚cran 
			 */
			if ( rcintersect( line_x, line_y, n_areaW, line_h, &xr, &yr, &wr, &hr ) )
			{	/* 
				 * Si rect est dans la zone de redraw:
				 *
				 * Zone a red‚ssiner: 
				 */
				G_pxyarray[0]=xr;
				G_pxyarray[1]=yr;
				G_pxyarray[2]=xr +wr -1;
				G_pxyarray[3]=yr +hr -1;

				/*
				 * Fond blanc:
				 */
				vr_recfl( G_ws_handle, G_pxyarray );

				/*
				 * Clipping pour text
				 */
				vs_clip( G_ws_handle, YES1, G_pxyarray );	

				/*
				 * Affiche texte de la ligne:
				 */
				if (	pTextLine -> text  !=  NULL
					&&	pTextLine -> length >= n_col )
				{
					v_gtext(	G_ws_handle,
								line_x, line_y, 
								&(pTextLine -> text[ n_col ]) );	/* Long max = INT_IN_SIZE = 128 caractŠres (1 car par int) */
				}
					
				/*
				 * Affiche le curseur:
				 */
				if( pTextLine == pTextDrawPar -> pTextLine_edit )
				{	/*
					 * Si on est sur la Ligne portant le cusreur:
					 */
					G_pxyarray[0] = text_x + (pTextDrawPar -> n_ColCsr - first_col) * cell_w;	/* Position X du curseur */
					G_pxyarray[2] = G_pxyarray[0]+CURSOR_WIDTH-1; /* Position X droite du curseur */
					vsf_interior( G_ws_handle, FIS_SOLID );		/* remplissage: PLEIN(couleur courante) */
					vswr_mode( G_ws_handle, MD_XOR );
					vr_recfl( G_ws_handle, G_pxyarray );	 
					vswr_mode( G_ws_handle, MD_REPLACE );
					vsf_interior( G_ws_handle, FIS_HOLLOW );	/* remplissage: VIDE(blanc) */
				}
			}
		}
		wind_get( wi_handle, WF_NEXTXYWH, &xr, &yr, &wr, &hr );
	}

	/*
	 * Affiche le ptr souris:
	 */
	graf_mouse( M_ON, 0);				

	/*
	 * Clipping OFF! 
	 */
	vs_clip( G_ws_handle, NO0, G_pxyarray );	
}

