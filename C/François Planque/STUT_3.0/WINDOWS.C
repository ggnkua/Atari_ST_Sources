/*
 * windows.c
 *
 * Purpose:
 * --------
 *	GESTION DES FENETERES sous GEM
 *	
 *	- resize
 *	- ouverture
 *	- fermeture
 *	
 *	- ajout dans une liste de fenetres
 *	- retrait d'une liste de fenetres
 *	- amener une fenˆtre au premier plan
 *	- trouver une fenˆtres ds une liste selon critŠres	
 *
 *	- taille des ascenseurs
 *	- position des ascenseurs
 *
 *	- options menu concernant les fenˆtres
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 17.06.94: fplanque: routines de redraw extraites vers REDRAW.C
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"WINDOWS.C v1.00 - 03.95"
          

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
	#include "S_MALLOC.H"
	#include "STUT_ONE.RSC\STUT_3.H"					/* noms des objets ds le ressource */
	#include "WIN_PU.H"
	#include "WINDR_PU.H"
	#include	"TEXT_PU.H"						/* Infos sur texte VDI */
	#include	"AESDEF.H"
	#include "VDI_PU.H"
	#include "DEBUG_PU.H"
	#include "RTERR_PU.H"
	#include "ARBPG_PU.H"
	#include "ATREE_PU.H"
	#include "MAIN_PU.H"
	#include "MMENU_PU.H"
	#include "DTDIR_PU.H"
	

/*
 * ------------------------ PROTOTYPES -------------------------
 */


/*
 * EXTernal prototypes:
 */
	/* 
	 * Images: 
	 */
	extern	void	pi3_optimal( int wi_ckind, int *border_x, int *border_y, int *border_w, int *border_h);
	extern	int	access_image( DATAPAGE *datapage, WORK_CONTENT *content_ptr, WORK_DRAW *draw_ptr );
	extern	void	open_pi3( WIPARAMS *pWiParams, DATAPAGE *content_ptr, MFDB *draw_ptr );
	/* 
	 * Objets: 
	 */
	extern	void	dir_optimal( int *x_full, int *y_full, int *w_full, int *h_full);
	extern	void	open_dir( 
							WIPARAMS *pWiParams, 
							DATADIR *	pDataDir, 
							int x_work, int y_work, int w_work );
	extern	void	efface_dir( WIPARAMS *pWiParams );
	extern	char	*dir_infoline( WIPARAMS *pWiParams );
	extern	char	*arbo_infoline( WIPARAMS *pWiParams );
	/*
	 * Datas:
	 */
	extern	BOOL dataPage_IsOpen( 				/* Out: !=0 si fen ouverte */
							DATAPAGE	*	pDataPage);	/* In: Datapage concern‚e */
	extern	void dataPage_setOpenBit( 
							DATAPAGE	*	pDataPage,	/* In: Datapage concern‚e */
							BOOL 			b_open );	/* In: !=0 si fen ouverte */


/*
 * PUBlic INTernal prototypes:
 */
	static	int	get_workYBas(						/* Out: Coord Y Basse */
							WIPARAMS	*	pWiParams );	/* In:  Fenˆtre concern‚e */
	static	int	get_workXDroit(					/* Out: Coord X droite */
							WIPARAMS	*	pWiParams );	/* In:  Fenˆtre concern‚e */

	static	void		add_wipar_ontop( WIPARAMS * *list_adr, WIPARAMS *pWiParams );
	static	WIPARAMS	*take_off_wi_par( WIPARAMS * *list_adr, int wi_handle);
	static	void	put_wi_on_top( WIPARAMS *pWiParams );
	
	static	void	set_infoline( WIPARAMS *pWiParams, char *(*infoline_text) (WIPARAMS *pWiParams) );
	
	static	void	update_VertSizePos( 
							WIPARAMS * pWiParams );
	static	void	update_HorSizePos( 
							WIPARAMS * pWiParams );
							
	static	void	set_slider_x( WIPARAMS	*pWiParams );
	static	void	set_slider_y( WIPARAMS	*pWiParams );
	static	void	set_slider_w( WIPARAMS	*pWiParams );
	static	void	set_slider_h( WIPARAMS	*pWiParams );
   
	static	WIPARAMS *	findWin_byDataPage(					/* Out: Ptr sur fenˆtre trouv‚e ou NULL */
									DATAPAGE  *	pDataPage, 			/* In:  Ptr sur datapage dont on recherche la fenˆtre ouverte */
									WIPARAMS	 *	pWiParams_list );	/* In:  Ptr sur la liste des fenˆtres */

/*
 * PRIVate INTernal prototypes:
 */
	static	void	menu_wi_options( void );



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
	extern	WIPARAMS	*G_wi_list_adr;		/* Adresse de l'arbre de paramŠtres */
				WIPARAMS	*G_closed_list_adr;	/* Adresse de la liste de fen referm‚es */
	extern	int	G_top_wi_handle;			/* Fenˆtre g‚r‚e par le programme */
	extern	WIPARAMS	*G_selection_adr;		/* ParamŠtres de la "Fenˆtre" dans laquelle
															se trouve la s‚lection actuelle */
	extern	char		*G_empty_string;		/* Chaine vide! */
	/*
	 * VDI: 
	 */
	extern	int	G_ws_handle;				/* handle virtual workstation VDI */
	extern	int 	G_pxyarray[18];			/* Liste de coord X,Y pour le VDI */
	extern	int	G_pxyarray2[10];			/* 2Šme liste */
	extern	MFDB	G_plogMFDB;					/* block ‚cran logique */
	extern	VDI_TEXT_PARAMS	G_std_text;	/* ParamŠtres du texte standard */
	extern	int	G_cell_size_prop;			/* Rapport Hauteur/Largeur d'un emplacement caractŠre standard */
	/* 
	 * Ressources: 
	 */
	extern	OBJECT	*G_menu_adr;			/* Pointeur sur le MENU ! */
	/* 
	 * Debug: 
	 */
	extern	WIPARAMS	*G_debug_window;		/* Fenˆtre de d‚bugging */


/*
 * -------------------- METHODES POUR WIPARAMS --------------------------
 */


/*
 * get_workYBas(-)
 *
 * Purpose:
 * --------
 * Retourne la coordonn‚e Y du bord inf‚rieur de la zone
 * de travail d'une fenˆtre
 *
 * Algorythm:
 * ----------  
 * .. = coord bord sup + hauteur - 1
 *
 * History:
 * --------
 * 17.06.94: fplanque: Created
 */
int	get_workYBas(						/* Out: Coord Y basse */
			WIPARAMS	*	pWiParams )		/* In:  Fenˆtre concern‚e */
{
	return	( pWiParams -> work_y + pWiParams -> seen_h -1 );
}


/*
 * get_workXDroit(-)
 *
 * Purpose:
 * --------
 * Retourne la coordonn‚e X du bord droit de la zone
 * de travail d'une fenˆtre
 *
 * Algorythm:
 * ----------  
 * .. = coord bord gauche + largeur - 1
 *
 * History:
 * --------
 * 17.06.94: fplanque: Created
 */
int	get_workXDroit(					/* Out: Coord X droite */
			WIPARAMS	*	pWiParams )		/* In:  Fenˆtre concern‚e */
{
	return	( pWiParams -> work_x + pWiParams -> seen_w -1 );
}




/*
 * vscroll_window(-)
 *
 * Purpose:
 * --------
 * Scrolling vertical du contenu d'une fenˆtre
 *
 * Algorythm:
 * ----------  
 * Pour certains types de fenˆtres, un scroll n'est pas rentable!
 * Par exemple, lorsque l'on … d‚j… une image BITMAP du contenu
 * en m‚moire, dans cas on va faire un redraw standard:
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 17.06.94: teste 'OVERLAPPED' plut“t que WF_TOP
 */
void	vscroll_window( 
			WIPARAMS *pWiParams, 
			unsigned long old_pos, 
			unsigned long new_pos )
{
	
	switch( pWiParams -> type )
	{
		case	TYP_EMPTY:		/* Fenˆtre vide: */
		case	TYP_PI3:			/* Image: */
			redraw( pWiParams, G_x_mini, G_y_mini, G_w_maxi, G_h_maxi, TAKE_CTRL );	/* Redraw complet */
			break;
			
		default:					/* Autres types: */
		{	/* 
			 * Un scroll a ttes les chances de se rentabiliser: 
			 *
			 * Bloque ‚cran: 
			 */
			if( start_WINDRAW( pWiParams ) == FALSE0 )
			{	/*
				 * La fenˆtre est overlapp‚e: 
				 * impossible de scroller: 
				 *
				 * Effectue un redraw bourrin de la partie "on-screen"
				 * de la fenˆtre, l'envoi de messages provoquant un
				 *	d‚bordement tampon AES (=>plantage!) lorsqu'on se sert 
				 *	d'un ARROWED en continu: 
				 *
				 * Par ailleurs, certaines proc‚dures peuvent vouloir
				 * un redraw imm‚diat: 
				 */
	
				redraw( pWiParams, G_x_mini, G_y_mini, G_w_maxi, G_h_maxi, CTRL_OK );	/* Redraw complet */
	
			}
			else
			{	/*
				 * Si la fenˆtre est au top: on va la faire scroller: 
				 */
				/* Variables: */
				unsigned long	deplacement = labs( new_pos - old_pos );
				int				bloc_size;

				/* Coordonn‚es de la zone de travail: */
				int	szone_x	= pWiParams -> work_x;
				int	szone_y	= pWiParams -> work_y;
				int	szone_w	= pWiParams -> seen_w;
				int	szone_h	= pWiParams -> seen_h;
	
				/* R‚duit … la partie qui se trouve vraiment sur l'‚cran: */
				rcintersect(	G_x_mini, G_y_mini, G_w_maxi, G_h_maxi,
							  		&szone_x, &szone_y, &szone_w, &szone_h );
		
				/*
				 * Teste s'il y a une partie de l'‚cran … scroller ou non: 
				 */
				if( deplacement < szone_h )
				{	/*
					 * S'il y a qque chose … scroller: 
					 */
					/* Taille du bloc … d‚placer: */
					bloc_size = (int) (szone_h - deplacement);
			
					graf_mouse( M_OFF, NULL);			/* Efface le ptr souris */

					/* 
					 * Teste sens du d‚placement 
					 */
					if ( new_pos > old_pos )
					{	/* On est descendu: */
					/* Coordonn‚es source, destination: */
						G_pxyarray[0]=szone_x; 			/* Coord source */
						G_pxyarray[1]=szone_y + (int)deplacement;
						G_pxyarray[2]=szone_x + szone_w -1;
						G_pxyarray[3]=G_pxyarray[1] + bloc_size -1;
						G_pxyarray[4]=szone_x;			/* Coord destination */
						G_pxyarray[5]=szone_y;
						G_pxyarray[6]=G_pxyarray[2];
						G_pxyarray[7]=szone_y + bloc_size -1;
						/* D‚placement d'un bloc vers le haut sur l'‚cran logique: */
						vro_cpyfm( G_ws_handle, S_ONLY, G_pxyarray,
									  &G_plogMFDB, &G_plogMFDB);
						/* Fixe coord de ce qu'il reste … dessiner: */
						szone_y += bloc_size;
						szone_h = (int)deplacement;
					}
					else if ( new_pos < old_pos )
					{	/* On a mont‚: */
						/* Coordonn‚es source, destination: */
						G_pxyarray[0]=szone_x; 			/* Coord source */
						G_pxyarray[1]=szone_y;
						G_pxyarray[2]=szone_x + szone_w -1;
						G_pxyarray[3]=szone_y + bloc_size -1;
						G_pxyarray[4]=szone_x;			/* Coord destination */
						G_pxyarray[5]=szone_y + (int)deplacement;
						G_pxyarray[6]=G_pxyarray[2];
						G_pxyarray[7]=G_pxyarray[5] + bloc_size -1;
						/* D‚placement d'un bloc vers le bas sur l'‚cran logique: */
						vro_cpyfm( G_ws_handle, S_ONLY, G_pxyarray,
									  &G_plogMFDB, &G_plogMFDB);
						/* Fixe coord de ce qu'il reste … dessiner: */
						szone_h = (int)deplacement;
					}
					else
					{	/* Pas de d‚placement: (ne devrait jamais se produire) */
						/* Fixe coord de ce qu'il reste … dessiner: */
						szone_h = 0;
					}

					graf_mouse( M_ON, 0);				/* Affiche le ptr souris */
				}
	
				/*
				 * Effectue un redraw de la partie d'‚cran qui n'a pas pu ˆtre
				 * trait‚e par scrolling: 
				 */
				redraw( pWiParams, szone_x, szone_y, szone_w, szone_h, CTRL_OK );
	
			}
			
			/*
			 * rend le contr“le de l'‚cran: 
			 */
			end_WINDRAW();
		}
	}
}



/*
 * hscroll_window(-)
 *
 * Purpose:
 * --------
 * Scrolling horizontal du contenu d'une fenˆtre
 *
 * Algorythm:
 * ----------  
 * Pour certains types de fenˆtres, un scroll n'est pas rentable!
 * Par exemple, lorsque l'on … d‚j… une image BITMAP du contenu
 * en m‚moire, dans cas on va faire un redraw standard:
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 17.06.94: teste 'OVERLAPPED' plut“t que WF_TOP
 */
void	hscroll_window(
			WIPARAMS *pWiParams, 
			unsigned long old_pos, 
			unsigned long new_pos )
{
	switch( pWiParams -> type )
	{
		case	TYP_EMPTY:		/* Fenˆtre vide: */
		case	TYP_PI3:			/* Image: */
			redraw( pWiParams, G_x_mini, G_y_mini, G_w_maxi, G_h_maxi, TAKE_CTRL );	/* Redraw complet */
			break;
			
		default:					/* Autres types: */
		{	/* 
			 * Un scroll a ttes les chances de se rentabiliser: 
			 *
			 * Bloque ‚cran: 
			 */
			if( start_WINDRAW( pWiParams) == FALSE0 )
			{	/* 
				 * La fenˆtre est overlapp‚e: 
				 * impossible de scroller: 
				 */
	
				/* Effectue un redraw bourrin de la partie "on-screen"
				de la fenˆtre, l'envoi de messages provoquant un
				d‚bordement tampon AES (=>plantage!) lorsqu'on se sert 
				d'un ARROWED en continu: */
				/* Par ailleurs, certaines proc‚dures peuvent vouloir un redraw imm‚diat: */
	
				redraw( pWiParams, G_x_mini, G_y_mini, G_w_maxi, G_h_maxi, CTRL_OK );	/* Redraw complet */
	
			}
			else
			{	/* Si la fenˆtre est au top: on va la faire scroller: */
			/* Variables: */
				unsigned long	deplacement = labs( new_pos - old_pos );
				int				bloc_size;

			/* Coordonn‚es de la zone de travail: */
				int	szone_x	= pWiParams -> work_x;
				int	szone_y	= pWiParams -> work_y;
				int	szone_w	= pWiParams -> seen_w;
				int	szone_h	= pWiParams -> seen_h;
	
			/* R‚duit … la partie qui se trouve vraiment sur l'‚cran: */
				rcintersect(	G_x_mini, G_y_mini, G_w_maxi, G_h_maxi,
							  		&szone_x, &szone_y, &szone_w, &szone_h );
		
			/* Teste s'il y a une partie de l'‚cran … scroller ou non: */
				if( deplacement < szone_w )
				{	/* S'il y a qque chose … scroller: */
				/* Taille du bloc … d‚placer: */
					bloc_size = (int) (szone_w - deplacement);
			
					graf_mouse( M_OFF, NULL);			/* Efface le ptr souris */

				/* Teste sens du d‚placement */
					if ( new_pos > old_pos )
					{	/* On vavers la droite: */
					/* Coordonn‚es source, destination: */
						G_pxyarray[0]=szone_x + (int)deplacement;	/* Coord source */
						G_pxyarray[1]=szone_y;
						G_pxyarray[2]=G_pxyarray[0] + bloc_size -1;
						G_pxyarray[3]=szone_y + szone_h -1;
						G_pxyarray[4]=szone_x;			/* Coord destination */
						G_pxyarray[5]=szone_y;
						G_pxyarray[6]=szone_x + bloc_size -1;
						G_pxyarray[7]=G_pxyarray[3];
					/* D‚placement d'un bloc vers la gauche sur l'‚cran logique: */
						vro_cpyfm( G_ws_handle, S_ONLY, G_pxyarray,
									  &G_plogMFDB, &G_plogMFDB);
					/* Fixe coord de ce qu'il reste … dessiner: */
						szone_x += bloc_size;
						szone_w = (int)deplacement;
					}
					else if ( new_pos < old_pos )
					{	/* On va vers la gauche: */
					/* Coordonn‚es source, destination: */
						G_pxyarray[0]=szone_x; 			/* Coord source */
						G_pxyarray[1]=szone_y;
						G_pxyarray[2]=szone_x + bloc_size -1;
						G_pxyarray[3]=szone_y + szone_h -1;
						G_pxyarray[4]=szone_x + (int)deplacement;	/* Coord destination */
						G_pxyarray[5]=szone_y;
						G_pxyarray[6]=G_pxyarray[4] + bloc_size -1;
						G_pxyarray[7]=G_pxyarray[3];
					/* D‚placement d'un bloc vers la droite sur l'‚cran logique: */
						vro_cpyfm( G_ws_handle, S_ONLY, G_pxyarray,
									  &G_plogMFDB, &G_plogMFDB);
					/* Fixe coord de ce qu'il reste … dessiner: */
						szone_w = (int)deplacement;
					}
					else
					{	/* Pas de d‚placement: (ne devrait jamais se produire) */
					/* Fixe coord de ce qu'il reste … dessiner: */
						szone_w = 0;
					}

					graf_mouse( M_ON, 0);				/* Affiche le ptr souris */

				}
	
			/* Effectue un redraw de la partie d'‚cran qui n'a pas pu ˆtre
				trait‚e par scrolling: */
				redraw( pWiParams, szone_x, szone_y, szone_w, szone_h, CTRL_OK );
	
			}
			
			/*
			 * rend le contr“le de l'‚cran: 
			 */
			end_WINDRAW();
		}
	}

}



/*
 * wi_resize(-)
 *
 * Purpose:
 * --------
 * Changement de taille d'une fenˆtre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 13.06.94: le repositionnement et le redimensionnement des ascenseurs a ‚t‚ extrait
 */
void	wi_resize( WIPARAMS * pWiParams )
{
	/*
	 * Nouvelle taille de la zone de travail:
	 */
	wind_get( pWiParams -> handle, WF_WORKXYWH,
				 &(pWiParams -> work_x), &(pWiParams -> work_y), 
				 &(pWiParams -> seen_w), &(pWiParams -> seen_h) );

	/*
	 * Repositionnement et Redimensionnement Vertical:
	 */
	update_VertSizePos( pWiParams );

	/*
	 * Repositionnement et Redimensionnement Horizontal:
	 */
	update_HorSizePos( pWiParams );

}


/*
 * update_VertSizePos(-)
 *
 * Purpose:
 * --------
 * Mise … jour taille et position ascenseur vertical
 * avec contr“le de d‚bordement.
 * repositionne le contenu de la fenˆtre si traitement sp‚cial est n‚cessaire
 * appell‚ par wi_resize()
 *
 * History:
 * --------
 * 13.06.94: fplanque: Extracted from wi_resize()
 * 29.07.94: fplanque: Correction bug ds repositionnement: enlev‚ get_workYBas( pWiParams )
 * 25.09.94: prise en compte des TYP_ERRORS
 */
void	update_VertSizePos( 
			WIPARAMS * pWiParams )
{
	unsigned long	new_pos;

	set_slider_h( pWiParams );			/* Fix taille slider vertical */
	
	if ( ( pWiParams -> seen_y + pWiParams -> seen_h /*-1*/ ) > pWiParams -> total_h )
	{	/*
		 * Si on d‚passe la fin du document:
		 */

		if( (pWiParams -> total_h) > (pWiParams -> seen_h) )
		{	/*
			 * Si la fenˆtre ne montre pas pour autant 
			 * l'ENSEMBLE du document
			 */
			new_pos = pWiParams->total_h - pWiParams -> seen_h;
		}
		else	
		{	/*
			 * Si fenˆtre est devenue plus grande que document,
			 * peut arriver avec TYP_DIR par ex... 
			 */
			new_pos = 0; 
		}
		
		/*
		 * Repositionne les donn‚es pour qu'elles tiennent compte du
		 * r‚ajustement.
		 */
		switch( pWiParams -> type )
		{
			case	TYP_TEXT:
			case	TYP_DEBUG:
			case	TYP_TRACK:
			case	TYP_ERRORS:
				vmove_text( pWiParams, new_pos );
				break;

			case	TYP_DIR:
				(pWiParams -> draw_ptr.tree) -> ob_y +=
					(int) (pWiParams -> seen_y - new_pos );
				break;
		}

		pWiParams->seen_y = new_pos;			/* Fixe nouvelle position */
	}

	set_slider_y( pWiParams );		/* Fixe position asc */
}


/*
 * update_HorSizePos(-)
 *
 * Purpose:
 * --------
 * Mise … jour taille et position ascenseur horizontal
 * avec contr“le de d‚bordement.
 * appell‚ par wi_resize()
 *
 * History:
 * --------
 * 13.06.94: fplanque: Extracted from wi_resize()
 * 29.07.94: fplanque: Correction bug ds repositionnement
 */
void	update_HorSizePos( 
			WIPARAMS * pWiParams )
{
	unsigned long	new_pos;

	set_slider_w( pWiParams );				/* Fix taille slider horizontal */
	if ( ( pWiParams -> seen_x + pWiParams -> seen_w /*-1*/ ) > pWiParams -> total_w )
	{	/*
		 * Si on d‚passe la fin du document:
		 */
		if( pWiParams->total_w > pWiParams -> seen_w )
		{
			new_pos= pWiParams->total_w - pWiParams -> seen_w;
		}
		else	
		{	/*
			 * Si fenˆtre plus grande que document, peut arriver avec TYP_DIR par ex... 
			 */
			new_pos = 0; 
		}
		
		pWiParams ->seen_x = new_pos;	/* Fixe nouvelle position */
	}

	set_slider_x( pWiParams );			/* Fixe position asc */
}



/*
 * ouvre_fenetre(-)
 *
 * Purpose:
 * --------
 * Ouverture d'une fenˆtre
 *
 * Algorythm:
 * ----------  
 * - V‚rifie si fen d‚j… ouverte ou contenu lock‚  (ACCESS)
 * - Fixe elements de la fenetre ainsi que taille plein ‚cran etc...
 * - ...et demande … l'AES de cr‚er la fenˆtre avec ces infos
 * - chargement/cr‚ation du contenu
 * - Allocation d'une zone WIPARAMS
 * - Fixe paramŠtres dans cette zone, y compris taille … l'ouverture
 * - appelle ouvre_xxx() pour les dispositions d'affichages (remplissage formulaires etc...)
 * - Cr‚e titre, infos
 * - Ouverture effective: affichage a l'‚cran (AES)
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 17.05.94: Ajout de commentaires
 * 06.08.94: Contr“le qu'une seule fenetre max puisse etre ouverte sur une DATAPAGE donn‚e
 * 25.09.94: ouverture des TYP_ERRORS
 * 11.10.94: empˆche temporairement l'ouverture de plusieurs fenˆtres arbo
 * 14.12.94: cr‚ation Titre/path des datapages ouvertes en fenetres
 * 26.12.94: fixe positions des ascenseurs … l'ouverture
 */
WIPARAMS	*	ouvre_fenetre( 
		int 				class, 
		int 				type,
		DATAGROUP	*	datagroup, 
		DATADIR 		*	datadir, 
		DATAPAGE 	*	datapage,
		const char	*	titre )
{
	static int		default_x=0,
						default_y=0;			/* Coordonn‚es d'ouverture par defaut */

	WIPARAMS		*	pWiParams;			/* Adresse des params */
	int				wi_handle;				/* handle de la fen qu'on va cr‚er */
	int				wi_ckind=COMPLETE;	/* El‚ments de la fenˆtre */
	int				x_full, y_full, w_full, h_full;
	int				x_work, y_work, w_work, h_work;
	int				access_ok = 1;			/* A priori l'accŠs aux donn‚es de la fenˆtre … ouvrir n'est pas bloqu‚ */
	WORK_CONTENT	pointeur;				/* Pointeur sur le contenu de la fenˆtre */
	WORK_DRAW		draw_ptr;				/* Pointeur sur infos de dessin associ‚es! */
	int				ouverture_ok;			/* =0 si ouverture … foir‚ */
	char	*			pMsz_CreatedTitle = NULL;
				
	/* 
	 * On commence par v‚rifier que la fenˆtre qui nous int‚resse n'est
	 *	pas d‚j… ouverte ou encore que son contenu n'est pas bloqu‚: 
	 */
	if( type == TYP_TREE )
	{
		if( datagroup -> root_dir != NULL && datagroup -> root_dir -> nb_dirs > 0 )
		{
			form_alert( 1,  "[3][|Vous ne pouvez pas ouvrir|"
										"plusieurs fenˆtres sur|"
										"l'arborescence]"
										"[Abandon]" );
			return	NULL;
		}
	}
	else if( class == CLASS_DATAPAGE )
	{
		if ( dataPage_IsOpen( datapage ) )
		{	/* 
			 * S'il y a d‚j… une fenˆtre ouverte sur cette DATAPAGE: 
			 * Trouve cette fenˆtre:
			 */
			WIPARAMS	* wi_adr = findWin_byDataPage( datapage, G_wi_list_adr );
	
			/*
			 * on va la monter au 1er Plan: 
			 */
			if ( wi_adr != NULL )
			{
				put_wi_on_top( wi_adr );
			}
			else
			{	/* ANORMAL */
				signale( "Impossible de trouver la fenˆtre ouverte sur cet objet" );
			}	

			return	NULL;		/* Pas de fenˆtre ouverte */
		}
		
		switch( type )
		{
			case TYP_TEXT:					
				/* Si texte */
				access_ok= access_text( datapage, &pointeur, &( draw_ptr.pTextDrawPar ) );
				break;

			case TYP_PI3:
				/* Si image degas */
				access_ok= access_image( datapage, &pointeur, &draw_ptr );
				break;

			case TYP_ARBO:
				/* Si sommaire d'‚dition ARBO */
				access_ok= access_arbo( datapage, &pointeur );
				break;
		
			default:
				access_ok= 0;				/* AccŠs impossible! */
				signale("Type DATAPAGE inconnu => autorisation d'accŠs non d‚termin‚e");
		}

		if( access_ok == 0 )
		{	/*
			 * Si ouverture impossible:
			 */
			return	NULL;
		}


		/*
		 * Signale l'ouverture d'une fenˆtre sur la DATAPAGE:
		 * On ne peut en ouvrir qu'une page DATAPAGE:
		 */
		dataPage_setOpenBit( datapage, TRUE_1 );
		datadir -> nb_edits ++;			/* Une fen d'‚dition d'ouverte de plus dans ce groupe */
	}


	/* 
	 * Si on a pu acc‚der: 
	 * 
	 * Calcul des coordonn‚es "plein ‚cran" de la fenˆtre
	 * Et fixe elts de la fenˆtre (Par d‚faut elle est d‚j… COMPLETE):
	 * Et teste si le document a le droit d'ˆtre ouvert: 
	 */
	switch ( type )
	{
		case	TYP_PI3:
			pi3_optimal( wi_ckind, &x_full, &y_full, &w_full, &h_full);
			break;

		case	TYP_TREE:
			arbotree_optimal( wi_ckind, datadir, &x_full, &y_full, &w_full, &h_full);
			break;
			
		case	TYP_ARBO:
			wi_ckind &= ~INFO;	/* Cette fenetre n'aura pas de ligne d'infos */
			arboedit_optimal( wi_ckind, &x_full, &y_full, &w_full, &h_full);
			y_full = G_y_mini + ( G_h_maxi - h_full )/2;
			break;
			
		case	TYP_DIR:
			dir_optimal( &x_full, &y_full, &w_full, &h_full);
			break;
			
		case	TYP_TEXT:
		case	TYP_DEBUG:
		case	TYP_ERRORS:
			text_optimal( wi_ckind, &x_full, &y_full, &w_full, &h_full);
			break;

		case	TYP_TRACK:
			wi_ckind = NAME|CLOSER|FULLER|MOVER|INFO|SIZER;
			text_optimal( wi_ckind, &x_full, &y_full, &w_full, &h_full);
			break;

		default:
			x_full = G_x_mini;
			y_full = G_y_mini;
			w_full = G_w_maxi;
			h_full = G_h_maxi;
			break;
	}


	/* 
	 * Demande … l'AES de Cr‚er la fenˆtre: 
	 */
	wi_handle=wind_create(wi_ckind, x_full, y_full, w_full, h_full);
			
	if ( wi_handle <= 0)
	{
		alert( NOMORE_WIN );		/* Plus de fenˆtre dispo */
	}
	else
	{
		/* 
		 * Chargement/Cr‚ation du contenu: 
		 */
		switch( class )
		{
			case 	CLASS_DATAPAGE:
				/*
				 * R‚cupŠre chemin d'accŠs … l'objet en RAM
				 * pour en faire le titre de la fenˆtre:
				 */
				pMsz_CreatedTitle = page_fullpath( datadir, datapage -> nom ); 
				ouverture_ok=1;
				break;

			default:				
				switch( type )
				{
					case TYP_EMPTY:
					case TYP_TREE:					/* Si Arborescence */
					case TYP_DIR:					/* Si liste des pages ‚cran */
						ouverture_ok=1;
						break;
			
					case TYP_TEXT:
						ouverture_ok= charge_texte( &( draw_ptr.pTextDrawPar ) );
						break;
			
					case TYP_DEBUG:
						ouverture_ok= debug_CreateWinText( &( draw_ptr.pTextDrawPar ) );
						break;

					case TYP_ERRORS:
						ouverture_ok= errors_CreateWinText( &( draw_ptr.pTextDrawPar ) );
						break;
			
					case TYP_TRACK:
					{	/*
						 * Tracking d'une voie:
						 */
						TEXTINFO 	 *	pTextInfo = create_TextInfo();
						ouverture_ok = 0;
						if( pTextInfo != NULL )
						{
							TEXT_DRAWPAR *	pTextDrawPar = create_TextDrawPar( pTextInfo, 100 );
							if( pTextDrawPar != NULL )
							{
								draw_ptr.pTextDrawPar = pTextDrawPar;
								ouverture_ok= 1;
							}
							else
							{
								free_formatext( pTextInfo );
							}
						}
					}
					break;
			
					default:
						signale("Type de donn‚es inconnu, impossible d'y acc‚der");
				}
		}


		if ( ouverture_ok == 1)
		{	/* 
			 * Si on a pu ouvrir le contenu: 
			 *
			 * R‚serve/R‚cupŠre une zone de params 
			 */

			if	( G_closed_list_adr == NULL)		
			{	/* 
				 * Si pas de fenˆtres ferm‚es prˆtes a ˆtre r‚ouvertes 
				 */
				pWiParams= (WIPARAMS *)MALLOC( sizeof(WIPARAMS) ) ;
						/* Cr‚ation d'un zone de paramŠtres */

				if (pWiParams == NULL)
				{
					alert( NOMEM_OPENWIN );		/* Pas assez de mem pour ouvrir fen */
					free_String( pMsz_CreatedTitle );
					wind_delete( wi_handle );			/* LibŠre m‚moire fenˆtre */
					wi_handle = 0;							/* Echec d'ouverture */
				}
				else
				{
					if 
					(
						default_x == 0								/* Non initialis‚ */
						|| default_x > (G_x_mini+G_w_maxi)/2		/* Trop loin dans l'‚cran */
						|| default_y > (G_y_mini+G_h_maxi)/2
					)
					{	/* (R‚)-Initialisation des coordonn‚es par defaut */
						default_x = G_x_mini + G_std_text. cell_w;
						default_y = G_y_mini + G_std_text. cell_h * 0.3;
					}
					pWiParams -> curr_x = default_x;
					pWiParams -> curr_y = default_y;
					pWiParams -> curr_w = G_w_maxi/1.5;
					pWiParams -> curr_h = G_h_maxi/1.5;

					/* Pour la prochaine fenˆtre: */
						default_x += G_std_text. cell_w * G_cell_size_prop;
						default_y += G_std_text. cell_h * 1.3;
				}
			}
			else
			{	/*
				 * Si on peut r‚cup‚rer les parms d'une ancienne fenˆtre 
				 */
			
				pWiParams= take_off_wi_par( &G_closed_list_adr, 0);		
			}

			/* 
			 * Calcule la taille UTILE (de la zone de TRAVAIL) de la fenˆtre: 
			 */
			wind_calc( WC_WORK, wi_ckind, pWiParams -> curr_x, pWiParams -> curr_y,
				pWiParams -> curr_w, pWiParams -> curr_h,
				&x_work, &y_work, &w_work, &h_work );


			/* 
			 * Ouverture... 
			 */							
			if ( wi_handle !=0 )			/* Si on a pu ouvrir une fenˆtre*/
			{
				/*
				 * Fixe paramŠtres compl‚mentaires:
				 */
				pWiParams -> handle		= wi_handle;
				pWiParams -> class		= class;			/* Classe de contenu */
				pWiParams -> datagroup	= datagroup;	/* Datagroup concern‚ */
				pWiParams -> datadir		= datadir;		/* Dossier concern‚ */
				pWiParams -> datapage	= datapage;		/* Page concern‚e */
				pWiParams -> type			= type;			/* Type de contenu */

				/* 
				 * Coords de la zone de travail actuelle: 
				 */
				pWiParams -> work_x		=	x_work;
				pWiParams -> work_y		=	y_work;

				/* 
				 * Coordonn‚es (par d‚faut) de la fenˆtre ouverte sur le document: 
				 */
				pWiParams -> seen_x	= 0;		/* Offset X */
				pWiParams -> seen_y	= 0;		/* Offset Y */

				/* 
				 * Taille actuellement affich‚e: 
				 */
				pWiParams -> seen_w	= w_work;	/* Largeur */
				pWiParams -> seen_h	= h_work;	/* Hauteur */
				
				/* 
				 * Initialisations: 
				 */
				pWiParams -> wi_ckind 		= wi_ckind;	/* Elts actifs */
				pWiParams -> fulled 			= 0;			/* Taille normale */
				pWiParams -> selected_icon = 0;			/* Ic“ne s‚lectionn‚e */
				/*
				 * Par d‚faut: Pas d'Options menu 
				 */
				pWiParams -> menu_options.save 			= FALSE0;
				pWiParams -> menu_options.saveas 		= FALSE0;
				pWiParams -> menu_options.savedisk		= FALSE0;
				pWiParams -> menu_options.newlink 		= FALSE0;
				pWiParams -> menu_options.newpage 		= FALSE0;
				pWiParams -> menu_options.newrub			= FALSE0;
				pWiParams -> menu_options.newtext		= FALSE0;
				pWiParams -> menu_options.compile		= FALSE0;
				pWiParams -> menu_options.affichage		= PARAFF_NONE;
				/*
				 * Etats par d‚faut:
				 */
				pWiParams -> WinFlags .b_modified		= FALSE0;	/* Contenu de la fenˆtre pas modifi‚ */
			
				switch ( type )
				{
					case TYP_PI3:					/* Degas haute r‚solution */
						open_pi3( pWiParams, pointeur.datapage, draw_ptr.psrcMFDB );
						break;
						
					case TYP_ARBO:					/* Si sommaire d'‚dition ARBO */
						open_arbosomm( pWiParams, pointeur.datapage );
						break;

					case TYP_TREE:					/* Si ARBOrescence */
						open_arbotree( pWiParams );
						break;

					case TYP_DIR:
						open_dir( pWiParams, datadir, x_work, y_work, w_work );
						break;
						
					case TYP_TEXT:
					case TYP_DEBUG:
					case TYP_TRACK:
						open_text( pWiParams, draw_ptr.pTextDrawPar );

						if( class == CLASS_DATAPAGE )
						{	/*
							 * S'il s'agit d'un texte en ram:
							 * on peut le sauver en ram...
							 */
							pWiParams -> menu_options.save = TRUE_1;
						}
						break;
	
					case TYP_ERRORS:
						errors_OpenLogWin( pWiParams, draw_ptr.pTextDrawPar );
						break;
												
					default:
						pWiParams -> content_ptr.x= NULL;	/* Pas de contenu */
						pWiParams -> draw_ptr.x	= NULL;	/* Pas de contenu */
						pWiParams -> total_w		= 1;		/* Taille totale (minimum) */
						pWiParams -> total_h		= 1;
						pWiParams -> h_step = G_std_text .cell_w * G_cell_size_prop;	/* Saut par 8 car */
						pWiParams -> v_step = G_std_text .cell_h;		/* Saut par ligne */
				}

				/* 
				 * Calcule taille maximale que l'user pourra donner … la fenˆtre:
				 */
				switch( type )
				{						
					case	TYP_EMPTY:
					case	TYP_DIR:
						pWiParams -> maxsize_w = G_w_maxi;
						pWiParams -> maxsize_h = G_h_maxi;
						break;

					case	TYP_TEXT:
					case	TYP_DEBUG:
					case	TYP_TRACK:
					case	TYP_ERRORS:
					{
						int foo;
						wind_calc( WC_BORDER, wi_ckind, 100, 100,
						(int) pWiParams -> total_w, G_h_maxi, &foo, &foo,
						&(pWiParams -> maxsize_w), &(pWiParams -> maxsize_h) );
						break;					
					}
						
					default:
					{
						int foo;
						/* 
						 * Calcule les coordonn‚es totales de la fenˆtre,
						 * en fonction de la taille du documenent 
						 * Peut ˆtre plus grand que l'‚cran physique,
						 *	c'est la diff‚rence avec w_full et h_full
						 *	qui sont <= … G_w_maxi et G_h_maxi... 
						 */
						wind_calc( WC_BORDER, wi_ckind, 100, 100,
						(int) pWiParams -> total_w, (int) pWiParams -> total_h, &foo, &foo,
						&(pWiParams -> maxsize_w), &(pWiParams -> maxsize_h) );
					}
				}

				/* 
				 * Cr‚e le titre 
				 */
				if( pMsz_CreatedTitle == NULL )
				{
					pWiParams -> name_adr = STRDUP( titre );	/* Duplique titre fourni */
				}
				else
				{
					pWiParams -> name_adr = pMsz_CreatedTitle;
				}
	      	wind_set( wi_handle, WF_NAME, pWiParams -> name_adr );

				/* 
				 * Cr‚e les infos 
				 */
				pWiParams -> info_adr = G_empty_string;	/* Par d‚faut: */
				switch( class )
				{
					case	CLASS_EMPTY:
						pWiParams -> info_adr = STRDUP(" Fenetre vide");
						wind_set( wi_handle, WF_INFO, pWiParams -> info_adr );
						break;
						
					case	CLASS_DIR:			/* Directory */
						set_infoline( pWiParams, dir_infoline );		/* Modifie ligne d'infos */
						break;

					case	CLASS_TREE:			/* Arborescence */
						set_infoline( pWiParams, arbo_infoline );	/* Modifie ligne d'infos */
						break;

					case	CLASS_DATAPAGE:
					default:
						wind_set( wi_handle, WF_INFO, pWiParams -> info_adr );
				}

				/* 
				 * Fixe tailles des ascenseurs:
				 */
				set_slider_w( pWiParams );	/* Fix taille slider horizontal */
				set_slider_h( pWiParams );	/* Fix taille slider vertical */
				
				/* 
				 * Fixe positions des ascenseurs:
				 */
				set_slider_x( pWiParams );
				set_slider_y( pWiParams );

				/* 
				 * Contr“le de la taille d'ouverture: 
				 */
				if ( pWiParams -> curr_w > w_full )
				{
					pWiParams -> curr_w = w_full;
				}
				if ( pWiParams -> curr_h > h_full )
				{
					pWiParams -> curr_h = h_full;
				}

				/* 
				 * Affiche fenˆtre 
				 */
				add_wipar_ontop( &G_wi_list_adr, pWiParams);
										/* Ajoute nlle fen en tˆte de liste */
				G_top_wi_handle=G_wi_list_adr -> handle;	/* Fenˆtre la plus en haut */

				wind_open(	wi_handle,
							 	pWiParams -> curr_x, pWiParams -> curr_y,
								pWiParams -> curr_w, pWiParams -> curr_h);	

				/* 
				 * Options menu: 
				 */	
				menu_ienable( G_menu_adr, FERMER, 1);		/* Enable Fermer */

				if ( pWiParams -> next != NULL )
				{	/*
					 * S'il y a maintenant au moins 2 fenˆtres ouvertes 
					 */
					menu_ienable( G_menu_adr, PREMPLAN, 1);		/* Enable Premier Plan */
				}

				/*
				 * Autres options:
				 */
				menu_wi_options();	

				/* 
				 * Retourne adresse params fenetre: 
				 */
				return	pWiParams;
			}
		}
		else						/* Si on a pas pu ouvrir le contenu */
		{
			wind_delete( wi_handle );			/* LibŠre m‚moire fenˆtre */
		}
	}

	/* 
	 * On a pas pu ouvrir de fenˆtre: 
	 */
	return	NULL;
}



/*
 * ferme_fenetre(-)
 *
 * Purpose:
 * --------
 * Fermeture d'une fenetre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.09.94: lorsqu'on ferme le debug, on garde le log text pour plus tard
 * 25.09.94: gestion des fen type ERRORS
 * 14.12.94: demande s'il faut sauver avant de fermer si le doc a ‚t‚ modifi‚
 * 07.01.95: renvoie r‚sultat, prend param b_Query
 */
BOOL ferme_fenetre( 				/* Out: TRUE_1 si la fenˆtre a ‚t‚ ferm‚e */
		WIPARAMS *	pWiParams,	/* In:  fenˆtre … fermer */
		BOOL			b_Query )	/* In:  TRUE_1 si on doit demander confirmation avant perte de donn‚es */
{
	int	closed_wi_handle;
	
	if( pWiParams == NULL || G_top_wi_handle == 0 )
	{	/* 
		 * Si aucune fenˆtre ouverte!
		 * Cela arrive lorsque le menu n'a pas eu le temps de s'effacer aprŠs
		 * fermeture de la derniŠre fen et que l'user … ‚t‚ assez rapide pour
		 * y recliquer 
		 */
		ping();
		return	FALSE0;
	}

	if( pWiParams -> WinFlags .b_modified && b_Query )
	{	/*
		 * Si le contenu de la fenˆtre a ‚t‚ modifi‚,
		 * Et si on est autoris‚ … demander:
		 * On va proposer de sauvegarder avant de fermer
		 */
		switch( alert( DLG_SAVEBEFORECLOSE ) )
		{
			case	1:
				/*
				 * Il faut sauver:
				 */
				sauver_ram( pWiParams );
				break;
				
			case	3:
				/*
				 * Il ne faut pas fermer:
				 */
				return	FALSE0;
		}
	}

	/*
	 * Si au moins une fenˆtre ouverte:
	 * Handle de la fen … fermer:
	 */
	closed_wi_handle = pWiParams -> handle;

	/*
	 * Suppression dans la liste des paramŠtres: 
	 */
	pWiParams = take_off_wi_par( &G_wi_list_adr, closed_wi_handle );

	/*
	 * Mise … jour des paramŠtres de la fenˆtre: 
	 */
	pWiParams -> handle =0;	/* Cette fen n'aura plus de handle */ 			

	/*
	 * Ajout des paramŠtres sur la tˆte de liste des fen ferm‚es 
	 */
	add_wipar_ontop( &G_closed_list_adr, pWiParams);
	
	/*
	 * Suppression de la fenˆtre par le systŠme: 
	 */
	wind_close( closed_wi_handle );
	wind_delete( closed_wi_handle );

	/*
	 * Supression des donn‚es en m‚moire/signalisation fermeture: 
	 */
	switch( pWiParams -> class )
	{
		case	CLASS_DIR:
		{	/*
			 * Efface arbre d'objets directory (& evtlmnt ICONBLKs ) 
			 */
			efface_dir( pWiParams );
			break;
		}

		case	CLASS_TREE:
		{	/*
			 * Efface arbre d'objets arbo: 
			 */
			efface_arbotree( pWiParams );
			break;
		}

		case	CLASS_TEXT:
			switch( pWiParams -> type )
			{
				case TYP_DEBUG:
					/*
					 * Si on a affaire … la fenˆtre d'infos debug 
					 */
					G_debug_window = NULL; 	/* Plus de fenˆtre de debug */
					menu_ienable( G_menu_adr, SYSTEMST, 0);	/* Disable System status */
					/*
					 * On n'efface pas le log debug:
					 * On le garde pour la prochaine fois
					 */
					break;

				case TYP_ERRORS:
					/*
					 * Run-Time errors:
					 */
					errors_CloseLogWin( pWiParams );
					break;

				default:
					/*
					 * LibŠre le texte formatt‚:
					 */
					free_formatext( pWiParams -> draw_ptr.pTextDrawPar -> pTextInfo );
			}

			/*
			 * LibŠre les infos d'affichage: 
			 */
			FREE( pWiParams -> draw_ptr.pTextDrawPar );

			break;

		case	CLASS_DATAPAGE:
		{	/*
			 * La fenˆtre contient l'‚dition d'une PAGE de donn‚es: 
			 */
			switch( pWiParams -> type )
			{
				case	TYP_TEXT:
					/* LibŠre le texte formatt‚: */
					free_formatext( pWiParams -> draw_ptr.pTextDrawPar -> pTextInfo );
					/* LibŠre les infos d'affichage: */
					FREE( pWiParams -> draw_ptr.pTextDrawPar );
					break;
					
				case	TYP_PI3:
				/* LibŠre zone MFDB: */
					FREE( pWiParams -> draw_ptr.psrcMFDB );
					break;

				case	TYP_ARBO:
				/* LibŠre arbre d'objets: */
					free_arbosomm( pWiParams -> draw_ptr.tree );
					break;
	
				default:
					signale("Le contenu de la fenˆtre n'a pas ‚t‚ lib‚r‚");
			}
			/*
			 * Signale qu'il n'y a plus de fen ouverte sur ce doc 
			 */
			dataPage_setOpenBit( pWiParams -> datapage, FALSE0 );
			/*
			 * Signale une fen d'‚dition de - dans ce DATADIR: 
			 */
			((pWiParams -> datadir) -> nb_edits) --;
			/*
			 * Signale une fen d'‚dition de - dans ce DATAGROUP:
			 */
			/* utile uniqmt si dossiers imbriqu‚s */
			/*	((pWiParams -> datagroup) -> nb_edits) --; */
			break;
		}
			
		default:
		{
			switch( pWiParams -> type )
			{
				case	TYP_EMPTY:
					break;
	
				default:
					signale("Le contenu de la fenˆtre n'a pas ‚t‚ lib‚r‚");
			}
		}
	}

	FREE( pWiParams -> name_adr );	/* LibŠre chaine Titre */

	if ( pWiParams -> info_adr != G_empty_string )
	{	/*
		 * S'il y a une ligne d'infos: 
		 */
		FREE( pWiParams -> info_adr );	/* LibŠre chaine infos */
	}
	
	/*
	 * Traitement des cons‚quences … la fermeture
	 * au niveau gestion des fenˆtres: 
	 */
	if ( G_wi_list_adr == NULL )		/* Si plus aucune fenˆtre ouvert */
	{
		G_top_wi_handle = 0;			/* Plus de fenˆtre sup‚rieure! */
		menu_ienable( G_menu_adr, FERMER, 0);	/* Disable */
	}
	else
	{
		G_top_wi_handle = G_wi_list_adr -> handle;	
											/* Nlle fenˆtre sup‚rieure */
		if ( G_wi_list_adr -> next == NULL )
		{	/*
			 * S'il y a maintenant plus qu'une seule fen ouverte 
			 */
			menu_ienable( G_menu_adr, PREMPLAN, 0);	/* Disable Premier Plan */
		}
	}

	if( G_selection_adr == pWiParams )
	{	/*
		 * Si la s‚lection actuelle se trouvait dans la fen ferm‚e 
		 */
		no_selection();		/* Efface les flags */
	}

	/*
	 * Options menu: 
	 */
	menu_wi_options();	/* Chg options menu en fnct de la nlle fen au 1er plan */
		
	return	TRUE_1;
}





/*
 * add_wipar_ontop(-)
 *
 * Purpose:
 * --------
 * Ajout d'une fenêtre dans une liste de fenêtres
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void add_wipar_ontop( WIPARAMS * *list_adr, WIPARAMS *pWiParams )
{
	pWiParams -> next = *list_adr;		/* Pointe sur la suite */
	*list_adr=pWiParams;					/* Nlle tˆte de liste */
}




/*
 * take_off_wi_par(-)
 *
 * Purpose:
 * --------
 * Retrait d'une fenetre d'une liste de fenetres
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
WIPARAMS	*take_off_wi_par(
				WIPARAMS * *list_adr, 
				int wi_handle)
{
		WIPARAMS		*pWiParams;	/* Adresse des params de la fen … fermer*/
		WIPARAMS		*prec_params_adr=NULL;
										/* Adresse des params de la fen pr‚c‚dente*/

		pWiParams=*list_adr;	/* On commence par le haut de la liste */

		while ( (pWiParams -> handle) != wi_handle )		
						/* Tant qu'on pointe pas sur la fen qu'on veut fermer */
		{
			prec_params_adr = pWiParams;		/* Nlle fen pr‚c‚dente */
			pWiParams = pWiParams -> next;   /* Nlle fenˆtre … tester */
		}

		if ( prec_params_adr == NULL )			/* Si c'‚tait la tˆte de liste */
			*list_adr = pWiParams -> next;	/* Nlle tˆte de liste*/
		else
			prec_params_adr -> next = pWiParams -> next;
											/* Court circuite la fenˆtre … effacer! */

		return pWiParams;
						/* Adresse de la zone de params qui a ‚t‚ retir‚e */
}



/*
 * set_infoline(-)
 *
 * Purpose:
 * --------
 * Modifie la ligne d'informations d'une fenetre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 10.09.94: use of free_String()
 */
void	set_infoline( 
			WIPARAMS *pWiParams, 
			char *(*infoline_text) (WIPARAMS *pWiParams) )
{

	char	*old_info = pWiParams -> info_adr;

	/*
	 * Fixe nouvelle chaine d'infos: 
	 */
	pWiParams -> info_adr = infoline_text( pWiParams );	/* Cr‚e une copie du tampon */
	wind_set( pWiParams -> handle, WF_INFO, pWiParams -> info_adr );

	/*
	 * Efface ancienne chaine: 
	 */
	free_String( old_info );
}


/*
 * fixform_window(-)
 *
 * Purpose:
 * --------
 * Fixe la position d'un formulaire contenu dans une fenetre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	fixform_window( WIPARAMS *pWiParams )
{

	(pWiParams -> draw_ptr.tree) -> ob_x =
		pWiParams -> work_x - (int) (pWiParams -> seen_x) + OUTLINE_INWIN;
	(pWiParams -> draw_ptr.tree) -> ob_y =
		pWiParams -> work_y - (int) (pWiParams -> seen_y) + OUTLINE_INWIN;

}



/*
 * cycle_window(-)
 *
 * Purpose:
 * --------
 * RamŠne la fenˆtre du fond au 1er plan
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 22.11.94: fplanque: teste si fen ouverte avant d'agir
 */
void	cycle_window( void )
{
	WIPARAMS	*pWiParams = G_wi_list_adr;		/* Adresse des params */

	if ( pWiParams == NULL )
	{	
		ping();
	}
	else
	{	/*
		 * S'il y a des fenˆtres ouvertes: 
	 	 * Trouve fenˆtre du fond 
	 	 */
		while( pWiParams -> next != NULL )
		{	/*
			 * Tant qu'on a pas trouv‚ la derniŠre fenˆtre:
			 */
			pWiParams = pWiParams -> next;	/* Passe … la suivante */
		}

		/* RamŠne la derniŠre fenˆtre au 1er plan: */
		put_wi_on_top( pWiParams );

	}
}

                                        
                                        
/*
 * put_wi_on_top(-)
 *
 * Purpose:
 * --------
 * Place une fenˆtre au premier plan
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	put_wi_on_top( WIPARAMS *pWiParams )
{
	int	wi_handle = pWiParams -> handle;

	wind_set( wi_handle, WF_TOP);
	G_top_wi_handle=wi_handle;		/* Nlle fenˆtre au TOP */
	take_off_wi_par( &G_wi_list_adr, wi_handle );
	add_wipar_ontop( &G_wi_list_adr, pWiParams );					
	menu_wi_options();	/* Chg options menu en fnct de la nlle fen au 1er plan */

}



/*
 * find_datawindow2(-)
 *
 * Purpose:
 * --------
 * Trouve une fenˆtre appartenant … un certain datagroup
 *
 * Algorythm:
 * ----------  
 * La fenˆtre qu'on recherche sera rep‚r‚e d'aprŠs l'adresse de
 *	son contenu, seul point de repŠre qui ne change pas lorsque
 *	l'on efface ou que l'on ajoute des ‚l‚ments dans un directory
 *	(ce qui n'est pas le cas du no d'objet, par exemple).
 *	On repŠre donc en g‚n‚ral avec les adresses suivantes:
 *			OLD	: adr_contenu= &(DATAGROUP)
 *	Directory	: adr_contenu= &(DATADIR)
 *	Document		: adr_contenu= &(DATAPAGE)
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
WIPARAMS *find_datawindow2(
				unsigned long adr_contenu, 
				WIPARAMS *start )
{
	/* printf("Seeking for %lu\n", adr_contenu ); */

	while ( start != NULL )
	{
		/*	printf("Found:%lu\n",start -> content_ptr.x); */

		if (	(unsigned long) (start -> content_ptr.x) == adr_contenu )
		{	/*
			 * Sort si on a trouv‚ une fen correspondant au critŠre 
			 */
			return	start;	/* Adr des params de la fen correspondante ou NULL */
		}
		start = start -> next;
	}

	/*
	 * On a pas trouv‚:
	 */
	return NULL;
}




/*
 * findWin_byDataPage(-)
 *
 * Purpose:
 * --------
 * Trouve une fenˆtre ouverte sur une certaine DATAPAGE
 *
 * Algorythm:
 * ----------  
 * La fenˆtre qu'on recherche sera rep‚r‚e d'aprŠs l'adresse de
 *	sa datapage
 *
 * History:
 * --------
 * 31.05.94: fplanque: Created base on fin_datawindow()
 */
WIPARAMS *	findWin_byDataPage(					/* Out: Ptr sur fenˆtre trouv‚e ou NULL */
					DATAPAGE  *	pDataPage, 			/* In:  Ptr sur datapage dont on recherche la fenˆtre ouverte */
					WIPARAMS	 *	pWiParams_list )	/* In:  Ptr sur la liste des fenˆtres */
{
	while ( pWiParams_list != NULL )
	{
		if ( pWiParams_list -> datapage == pDataPage )
		{	/*
			 * Sort si on a trouv‚ une fen correspondant au critŠre 
			 */
			return	pWiParams_list;	/* Adr des params de la fen correspondante ou NULL */
		}
		pWiParams_list = pWiParams_list -> next;
	}

	/*
	 * On a pas trouv‚:
	 */
	return NULL;
}




/*
 * ------------------- Taille/pos des Ascenseurs ------------------
 */


/*
 * set_slider_w(-)
 *
 * Purpose:
 * --------
 * Fixe taille ascenseur horizontal
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	set_slider_w( WIPARAMS	*pWiParams )
{
	if ( pWiParams -> wi_ckind & HSLIDE )
	{	/* S'il y a un ascenseur horizontal: */
		long	taille;		/* taille du slider */
		
		taille= ( (pWiParams -> seen_w) * (long)1000 / (pWiParams -> total_w) );	
															/* Calcul fait en LONG */
		if (taille>1000)
			taille=1000;
		wind_set( pWiParams -> handle, WF_HSLSIZE, (int)taille, 0, 0, 0);
																				/* Fixe taille */
	}
}


/*
 * set_slider_h(-)
 *
 * Purpose:
 * --------
 * Fixe taille ascenseur vertical
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	set_slider_h( WIPARAMS	*pWiParams )
{
	if ( pWiParams -> wi_ckind & VSLIDE )
	{	/* S'il y a un ascenseur vertical: */
		long	taille;		/* taille du slider */
		
		taille= ( (pWiParams -> seen_h) * (long)1000 / (pWiParams -> total_h) );	
															/* Calcul fait en LONG */
		if (taille>1000)
			taille=1000;
		wind_set( pWiParams -> handle, WF_VSLSIZE, (int)taille, 0, 0, 0);
																			/* Fixe taille */
	}
}



/*
 * set_slider_y(-)
 *
 * Purpose:
 * --------
 * Fixe position ascenseur vertical
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void set_slider_y( 
			WIPARAMS * pWiParams )
{
	if ( pWiParams -> wi_ckind & VSLIDE )
	{	/*
		 * S'il y a un ascenseur vertical: 
		 */
		long	position;								/* position du slider */
		if ( pWiParams -> seen_h >= pWiParams -> total_h )
		{
			position = 0;
		}
		else
		{
			position= 1000 * (pWiParams -> seen_y) / 
				(pWiParams -> total_h - pWiParams -> seen_h );	
				/* Calcul fait en LONG */
		}
		wind_set( pWiParams -> handle, WF_VSLIDE, (int)position );
			/* Fixe position */
	}
}


/*
 * set_slider_x(-)
 *
 * Purpose:
 * --------
 * Fixe position ascenseur horizontal
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void set_slider_x( 
			WIPARAMS	*pWiParams )
{
	if ( pWiParams -> wi_ckind & HSLIDE )
	{	/*
		 * S'il y a un ascenseur horizontal: 
		 */
		long	position;								/* position du slider */
		if ( pWiParams -> seen_w >= pWiParams -> total_w )
		{
			position = 0;
		}
		else
		{
			position= 1000 * (pWiParams -> seen_x) / 
			(pWiParams -> total_w - pWiParams -> seen_w );	
			/* Calcul fait en LONG */
		}
		wind_set( pWiParams -> handle, WF_HSLIDE, (int)position );
			/* Fixe position */
	}
}


/*
 * -------------------------------------------------------
 */
 
 
/*
 * menu_wi_options(-)
 *
 * Purpose:
 * --------
 * Validation des options du menu concernant la fenˆtre au top
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 31.05.94: Ajout option 'Sauver'
 * 18.06.94: options "new text" et "compile"
 */
void	menu_wi_options( void )
{
	if	( G_wi_list_adr != NULL )	/* S'il y a au - 1 fen ouverte: */
	{
		MENU_OPTIONS	menu_options = G_wi_list_adr -> menu_options;

		menu_ienable( G_menu_adr, SAUVER,	menu_options.save? 1:0 );
		menu_ienable( G_menu_adr, SAVEAS,	menu_options.saveas? 1:0 );
		menu_ienable( G_menu_adr, SAVEDISK, menu_options.savedisk? 1:0 );
		menu_ienable( G_menu_adr, MENNEWLK, menu_options.newlink? 1:0 );
		menu_ienable( G_menu_adr, MENNEWPG, menu_options.newpage? 1:0 );
		menu_ienable( G_menu_adr, MENEWRUB, menu_options.newrub? 1:0 );
		menu_ienable( G_menu_adr, MENEWTXT, menu_options.newtext? 1:0 );
		menu_ienable( G_menu_adr, MENCOMPI, menu_options.compile? 1:0 );
		menu_ienable( G_menu_adr, AFFICHAG, (menu_options.affichage != PARAFF_NONE) ? 1:0 );
	}
	else	/* Si plus aucune fenˆtre ouverte: */
	{
		menu_ienable( G_menu_adr, SAUVER,	0);	/* Disable Sauver */
		menu_ienable( G_menu_adr, SAVEAS,	0);	/* Disable Sauver */
		menu_ienable( G_menu_adr, SAVEDISK, 0);	/* Disable Sauver */
		menu_ienable( G_menu_adr, MENNEWLK, 0);	/* Disable Nouveau Lien */
		menu_ienable( G_menu_adr, MENEWRUB, 0);	/* Disable Nouvelle rubrique */
		menu_ienable( G_menu_adr, MENEWTXT, 0);	/* Disable  */
		menu_ienable( G_menu_adr, MENCOMPI, 0);	/* Disable  */
		menu_ienable( G_menu_adr, MENNEWPG, 0);	/* Disable Nouvelle page */
		menu_ienable( G_menu_adr, AFFICHAG, 0);	/* Disable Affichage */
	}
}




/*
 * Wnd_SetModified(-)
 *
 * Purpose:
 * --------
 * Positionne le flag modified
 * et traduit cet ‚tat dans le titre de la fenˆtre
 *
 * History:
 * --------
 * 14.12.94: fplanque: Created
 */
void	Wnd_SetModified(
			WIPARAMS	* pWiParams )	/* In: Fenˆtre concern‚e */
{
	char	*	pMsz_NewTitle;
	
	if( pWiParams -> WinFlags .b_modified == TRUE_1 )
	{	/*
		 * On a d‚j… modifi‚ auparavent:
		 */
		return;
	}
	
	/*
	 * Contenu de la fenˆtre a ‚t‚ modifi‚ maintenant:
	 */
	pWiParams -> WinFlags .b_modified = TRUE_1;	
	
	/*
	 * Nouveau titre:
	 * On augmente la longueur de 2 "* " et on oublie pas la place pour le 0 final
	 */
	pMsz_NewTitle = MALLOC( strlen( pWiParams -> name_adr ) + 3 );
	pMsz_NewTitle[0] = '*';
	pMsz_NewTitle[1] = ' ';
	strcpy( &pMsz_NewTitle[2], pWiParams -> name_adr );
	
	Wnd_ChangeTitle( pWiParams, pMsz_NewTitle );
}


/*
 * Wnd_ClearModified(-)
 *
 * Purpose:
 * --------
 * EnlŠve le flag modified
 * et traduit cet ‚tat dans le titre de la fenˆtre
 *
 * History:
 * --------
 * 14.12.94: fplanque: Created
 */
void	Wnd_ClearModified(
			WIPARAMS	* pWiParams )	/* In: Fenˆtre concern‚e */
{
	char	*	pMsz_NewTitle;
	
	if( pWiParams -> WinFlags .b_modified == FALSE0 )
	{	/*
		 * La fenˆtre n'‚tait pas modifi‚e:
		 */
		return;
	}
	
	/*
	 * Contenu de la fenˆtre a ‚t‚ sauv‚ maintenant:
	 */
	pWiParams -> WinFlags .b_modified = FALSE0;	
	
	/*
	 * Nouveau titre (le mˆme sans "* " au d‚but)
	 */
	pMsz_NewTitle = STRDUP( &(pWiParams -> name_adr)[2] );
	
	Wnd_ChangeTitle( pWiParams, pMsz_NewTitle );
}


/*
 * Wnd_ChangeTitle(-)
 *
 * Purpose:
 * --------
 * Remplace le titre d'une fenˆtre
 *
 * History:
 * --------
 * 14.12.94: fplanque: Created
 */
void	Wnd_ChangeTitle(
			WIPARAMS	* 	pWiParams,			/* In: Fenˆtre concern‚e */
			char		*	pMsz_NewTitle )	/* In: Ptr sur nouveau titre */
{
	/*
	 * Affiche nouveau titre:
	 */
  	wind_set( pWiParams -> handle, WF_NAME, pMsz_NewTitle );
	
	/*
	 * Efface l'ancien titre de la m‚moire:
	 */
	free_String( pWiParams -> name_adr );

	/*
	 * la fenˆtre M‚morise le nouveau titre:
	 */
	pWiParams -> name_adr = pMsz_NewTitle;
}