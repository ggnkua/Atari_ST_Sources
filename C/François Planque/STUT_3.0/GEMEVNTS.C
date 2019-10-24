/*
 * gemevnts.c
 *
 * Purpose:
 * --------
 * Traitement de divers ‚vˆnements GEM
 *
 * History:
 * --------
 * fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"GEMEVNTS.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<aes.h>						/* header AES */
	#include <stdio.h>

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"					/* Macros */
	#include "WIN_PU.H"
	#include "WINDR_PU.H"
	#include	"DEBUG_PU.H"
	#include	"TEXT_PU.H"

/*
 * ------------------------ PROTOTYPES -------------------------
 */

/*
 * EXTernal prototypes:
 */
	/* 
	 * Objets: 
	 */
	extern	void	rearrange_dir( WIPARAMS *wi_params_adr, int new_w );

/*
 * ------------------------ VARIABLES -------------------------
 */
    
/*
 * External variables: 
 */
	/* 
	 * G‚n‚ral: 
	 */
	extern	int		G_x_mini, G_y_mini;		/* Coord sup gauche de l'‚cran */
	extern	int		G_w_maxi, G_h_maxi;		/* Taille de l'‚cran de travail */
	extern	int		G_ev_mgpbuff[8];			/* Buffer d'‚venements GEM */
	/*
	 * Ic“nes: 
	 */
	extern	int		G_icon_w, G_icon_h;	/* Dimensions des ic“nes */


	
/*
 * Private variables: 
 */
	/* 
	 * Buffers: 
	 */
	static	int	MB_new_x, MB_new_y, MB_new_w, MB_new_h; 
	static	long	MB_old_pos, MB_new_pos;
	 
 
/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * msg_fulled(-)
 *
 * Purpose:
 * --------
 * WM_FULLED : Full_screen ou r‚duction de fenêtre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	msg_fulled( 
			WIPARAMS	*wi_params_adr )
{
	/* 
	 * Variables: 
	 */
	int	wi_handle = wi_params_adr ->  handle;	

	/*
	 * Teste si c'est un agrandissement ou une r‚duction: 
	 */
	if (wi_params_adr -> fulled == 0)  	/* si taille norm */
	{					
		wind_get( wi_handle, WF_FULLXYWH, &MB_new_x, &MB_new_y, &MB_new_w, &MB_new_h);
		wi_params_adr -> fulled = 1;		/* Taille max */
	}
	else
	{
		wind_get( wi_handle, WF_PREVXYWH, &MB_new_x, &MB_new_y, &MB_new_w, &MB_new_h);
		wi_params_adr -> fulled = 0;		/* Taille norm */					
	}

	switch( wi_params_adr -> type )	
	{
		case	TYP_DIR:
			/*
			 * Contr“le s'il faut r‚-arranger les ic“nes: 
			 */
			if (	MB_new_w >= (wi_params_adr -> more + G_icon_w)
				||	MB_new_w < (wi_params_adr -> more ) )
			{
				/*
				 * R‚arrange ic“nes: 
				 */
				rearrange_dir( wi_params_adr, MB_new_w );

				/*
				 * Demande redraw total de la fenˆtre: 
				 */
				send_fullredraw( wi_params_adr );
			};

			/*
			 * Change les coordonn‚es de l'arbe d'objets … l'‚cran: 
			 */
			(wi_params_adr -> draw_ptr.tree) -> ob_x +=
				MB_new_x - wi_params_adr -> curr_x;
			(wi_params_adr -> draw_ptr.tree) -> ob_y +=
				MB_new_y - wi_params_adr -> curr_y;
			break;
	}

	wind_set( wi_handle, WF_CURRXYWH, MB_new_x, MB_new_y, MB_new_w, MB_new_h);
	wi_params_adr -> curr_x = MB_new_x;
	wi_params_adr -> curr_y = MB_new_y;
	wi_params_adr -> curr_w = MB_new_w;
	wi_params_adr -> curr_h = MB_new_h;

	/*
	 * Taille asc et repositionnement contenu si n‚cessaire:
	 */
	wi_resize( wi_params_adr ); 

	/*
	 * On s'occupe de positionner le formulaire pour le prochain redraw: 
	 */
	if ( wi_params_adr -> type == TYP_ARBO )
	{	/*
		 * Si positionnement n‚cessaire: 
		 */
		fixform_window( wi_params_adr );		/* Fixe nlle position formulaire */
	}

}



/*
 * msg_arrowed(-)
 *
 * Purpose:
 * --------
 * WM_ARROWED : Flˆches de d‚placement
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 26.09.94: support type TYP_ERRORS
 */
void	msg_arrowed( WIPARAMS	*wi_params_adr )
{
	/* printf("Seen_h=%d\n", wi_params_adr -> seen_h ); */

	/* Selon le type d'ARROW: */
	switch ( G_ev_mgpbuff[4] )
	{
		/* D‚placement vertical */
		case 0:
		case 1:
		case 2:
		case 3:
			switch ( G_ev_mgpbuff[4] )
			{
				case 0:						/* Page vers le haut */
					MB_new_pos = l_max ( 0, wi_params_adr -> seen_y
						- wi_params_adr -> seen_h );
					break;

				case 1:						/* Page vers le bas */
					MB_new_pos = l_min ( wi_params_adr -> total_h - wi_params_adr -> seen_h, 
						wi_params_adr -> seen_y + wi_params_adr -> seen_h );
					MB_new_pos = MAX( MB_new_pos, 0 );
					break;
					
				case 2:						/* Ligne vers le haut */
					MB_new_pos = l_max ( 0, wi_params_adr -> seen_y - wi_params_adr -> v_step );
					break;

				case 3:						/* Ligne vers le bas */
					MB_new_pos = l_min ( wi_params_adr -> total_h - wi_params_adr -> seen_h, 
						wi_params_adr -> seen_y + wi_params_adr -> v_step );
					MB_new_pos = MAX( MB_new_pos, 0 );
					break;
			}

			if ( MB_new_pos != wi_params_adr -> seen_y )
			{	/*
				 * Si la position verticale a chang‚:
				 */
				switch( wi_params_adr -> type )
				{
					case	TYP_TEXT:
					case	TYP_DEBUG:
					case	TYP_ERRORS:
						/*
						 * Fixe nouvelle ligne se trouvant en haut de l'‚cran: 
						 */
						vmove_text( wi_params_adr, MB_new_pos );
						break;

					case	TYP_DIR:
					case	TYP_ARBO:
						/*
						 * Change les coordonn‚es de l'arbe d'objets … l'‚cran: 
						 */
						(wi_params_adr -> draw_ptr.tree) -> ob_y +=
							(int) (wi_params_adr -> seen_y - MB_new_pos);
						break;
						
				/*	default:
						TRACE1( "Type de donn‚es %X non support‚ par msg_arrowed", wi_params_adr -> type ); */
				}
				MB_old_pos = wi_params_adr -> seen_y;	/* Sauve ancienne position */
				wi_params_adr -> seen_y = MB_new_pos;	/* valide new pos */
				set_slider_y( wi_params_adr );			/* R‚aff slider */
				/*
				 * Fait scroller le contenu de la fenˆtre: 
				 */
				vscroll_window( wi_params_adr, MB_old_pos, MB_new_pos );
			}
			break;
			
		/* 
		 * D‚placement horizontal 
		 */
		case 4:
		case 5:
		case 6:
		case 7:
			switch ( G_ev_mgpbuff[4] )
			{
				case 4:						/* Page vers la gauche */
					MB_new_pos = l_max ( 0, wi_params_adr -> seen_x - wi_params_adr -> seen_w );
					break;

				case 5:						/* Page vers la droite */
					MB_new_pos = l_min ( wi_params_adr -> total_w - wi_params_adr -> seen_w, 
						wi_params_adr -> seen_x + wi_params_adr -> seen_w );
					MB_new_pos = MAX( MB_new_pos, 0 );
					break;
					
				case 6:						/* Ligne vers la gauche */
					MB_new_pos = l_max ( 0, wi_params_adr -> seen_x - wi_params_adr -> h_step );
					break;

				case 7:						/* Ligne vers la droite */
					MB_new_pos = l_min ( wi_params_adr -> total_w - wi_params_adr -> seen_w, 
						wi_params_adr -> seen_x + wi_params_adr -> h_step );
					MB_new_pos = MAX( MB_new_pos, 0 );
					break;
			}
			if ( MB_new_pos != wi_params_adr -> seen_x )
			{
				switch( wi_params_adr -> type )
				{
					case	TYP_DIR:
					case	TYP_ARBO:
					/* case	TYPTREE: */
					/* Change les coordonn‚es de l'arbe d'objets … l'‚cran: */
						(wi_params_adr -> draw_ptr.tree) -> ob_x +=
							(int) (wi_params_adr -> seen_x - MB_new_pos);
						break;
				};
				MB_old_pos = wi_params_adr -> seen_x;	/* Sauve ancienne position */
				wi_params_adr -> seen_x = MB_new_pos;	/* valide new pos */
				set_slider_x( wi_params_adr );		/* R‚aff slider */							
			/* Fait scroller le contenu de la fenˆtre: */
				hscroll_window( wi_params_adr, MB_old_pos, MB_new_pos );
			}
			break;
	}
}



/*
 * msg_vslid(-)
 *
 * Purpose:
 * --------
 * WM_VSLID : Ascenseur vertical
 *
 * History:
 * --------
 * fplanque: Created
 * 26.09.94: support type TYP_ERRORS
 */
void	msg_vslid( WIPARAMS	*wi_params_adr )
{
	/* Variables: */
	int	wi_handle = wi_params_adr ->  handle;	
	int	slider_pos=	G_ev_mgpbuff[4];

	/* Nouvelle position demand‚e: */
	MB_new_pos = ( slider_pos * 
		(wi_params_adr -> total_h - wi_params_adr -> seen_h) / 1000);
	if ( MB_new_pos != wi_params_adr -> seen_y )
	{
		switch( wi_params_adr -> type )
		{
			case	TYP_TEXT:
			case	TYP_DEBUG:
			case	TYP_ERRORS:
				/*
				 * Fixe nouvelle ligne se trouvant en haut de l'‚cran: 
				 */
				vmove_text( wi_params_adr, MB_new_pos );
				break;

			case	TYP_DIR:
			case	TYP_ARBO:
				/*
				 * Change les coordonn‚es de l'arbe d'objets … l'‚cran: 
				 */
				(wi_params_adr -> draw_ptr.tree) -> ob_y +=
					(int) (wi_params_adr -> seen_y - MB_new_pos);
				break;
						
			/*	default:
					TRACE1( "Type de donn‚es %X non support‚ par msg_vslid", wi_params_adr -> type ); */
		}
		MB_old_pos = wi_params_adr -> seen_y;	/* Sauve ancienne position */
		wi_params_adr -> seen_y = MB_new_pos;
		wind_set( wi_handle, WF_VSLIDE, slider_pos);
		/*
		 * Fait scroller le contenu de la fenˆtre: 
		 * (ou redessine entiŠrement si pas de scroll possible)
		 * (Redraw imm‚diat) 
		 */
		vscroll_window( wi_params_adr, MB_old_pos, MB_new_pos );
	}
}



/*
 * msg_hslid(-)
 *
 * Purpose:
 * --------
 * WM_HSLID : Ascenseur horizontal
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	msg_hslid( WIPARAMS	*wi_params_adr )
{
	/*
	 * Variables: 
	 */
	int	wi_handle = wi_params_adr ->  handle;	
	int	slider_pos=	G_ev_mgpbuff[4];

	MB_new_pos = (int) ( slider_pos * 
		(wi_params_adr -> total_w - wi_params_adr -> seen_w) / 1000);

	switch( wi_params_adr -> type )
	{
		case	TYP_DIR:
		case	TYP_ARBO:
		/* case	TYPTREE: */
		/* Change les coordonn‚es de l'arbe d'objets … l'‚cran: */
			(wi_params_adr -> draw_ptr.tree) -> ob_x +=
				(int) (wi_params_adr -> seen_x - MB_new_pos);
			break;
	}
	MB_old_pos = wi_params_adr -> seen_x;	/* Sauve ancienne position */
	wi_params_adr -> seen_x = MB_new_pos;
	wind_set( wi_handle, WF_HSLIDE, slider_pos);

	/*
	 * Fait scroller le contenu de la fenˆtre: 
	 * (ou redessine entiŠrement si pas de scroll possible) 
	 * (Redraw imm‚diat):
	 */
	hscroll_window( wi_params_adr, MB_old_pos, MB_new_pos );
}



/*
 * msg_sized(-)
 *
 * Purpose:
 * --------
 * WM_SIZED : Changement de taille
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	msg_sized( WIPARAMS	*wi_params_adr )
{
	/*
	 * Variables: 
	 */
	int	wi_handle = wi_params_adr ->  handle;	

	MB_new_x = G_ev_mgpbuff[4];
	MB_new_y = G_ev_mgpbuff[5];
	MB_new_w = G_ev_mgpbuff[6];
	MB_new_h = G_ev_mgpbuff[7];
	
	/*
	 * Contr“le qu'on ne d‚passe pas la taille maxi autoris‚e: 
	 */
	if ( MB_new_w > (wi_params_adr -> maxsize_w) )
	{
		MB_new_w = wi_params_adr -> maxsize_w;
	}
	if ( MB_new_h > (wi_params_adr -> maxsize_h) )
	{
		MB_new_h = wi_params_adr -> maxsize_h;
	}
	
	/*
	 * Contr“le s'il faut modifier le contenu de la fenˆtre: 
	 */
	switch( wi_params_adr -> type )	
	{
		case	TYP_DIR:
			/*
			 * Contr“le s'il faut r‚-arranger les ic“nes: 
			 */
			if (	MB_new_w >= (wi_params_adr -> more + G_icon_w)
				||	MB_new_w < (wi_params_adr -> more ) )
			{
				rearrange_dir( wi_params_adr, MB_new_w );
				/* Demande redraw total de la fenˆtre: */
				send_fullredraw( wi_params_adr );
			}
			break;
	}
	
	/*
	 * Change la taille de la fenˆtre: 
	 */
	wind_set( wi_handle, WF_CURRXYWH, MB_new_x, MB_new_y, MB_new_w, MB_new_h );
	wi_params_adr -> curr_x = MB_new_x;
	wi_params_adr -> curr_y = MB_new_y;
	wi_params_adr -> curr_w = MB_new_w;
	wi_params_adr -> curr_h = MB_new_h;

	/*
	 * Taille asc et repositionnement contenu si n‚cessaire:
	 */
	wi_resize( wi_params_adr ); 		

	wi_params_adr -> fulled = 0;		/* Taille norm */					

	/*
	 * On s'occupe de positionner le formulaire pour le prochain redraw: 
	 */
	if ( wi_params_adr -> type == TYP_ARBO )
	{	/*
		 * Si positionnement n‚cessaire: 
		 */
		fixform_window(wi_params_adr );	/* Fixe nlle position formulaire */
	}
}



/*
 * msg_moved(-)
 *
 * Purpose:
 * --------
 * WM_MOVED : D‚placement d'une fenˆtre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 17.12.94: chge coord arbre OBJC pour les TYP_TREE (n‚cessaire lorsque les ic“nes sont actualis‚es )
 */
void	msg_moved( WIPARAMS	*wi_params_adr )
{
	int	wi_handle = wi_params_adr ->  handle;	
	int	x_move, y_move;	/* D‚placement relatif */

	MB_new_x = G_ev_mgpbuff[4];
	MB_new_y = G_ev_mgpbuff[5];
	MB_new_w = G_ev_mgpbuff[6];
	MB_new_h = G_ev_mgpbuff[7];
	
	x_move = MB_new_x - wi_params_adr -> curr_x;
	y_move = MB_new_y - wi_params_adr -> curr_y;
	
	switch( wi_params_adr -> type )	
	{
		case	TYP_DIR:
		case	TYP_ARBO:
		case	TYP_TREE:
			/*
			 * Change les coordonn‚es de l'arbe d'objets … l'‚cran: 
			 */
			(wi_params_adr -> draw_ptr.tree) -> ob_x += x_move;
			(wi_params_adr -> draw_ptr.tree) -> ob_y += y_move;
	}
	
	wind_set( wi_handle, WF_CURRXYWH, MB_new_x, MB_new_y, MB_new_w, MB_new_h );
	wi_params_adr -> curr_x = MB_new_x;
	wi_params_adr -> curr_y = MB_new_y;
	wi_params_adr -> curr_w = MB_new_w;
	wi_params_adr -> curr_h = MB_new_h;
	wi_params_adr -> work_x += x_move;
	wi_params_adr -> work_y += y_move;
	wi_params_adr -> fulled = 0;		/* Taille norm */					
}
