/*
 * progress.c
 *
 * Purpose:
 * --------
 * Routines de gestion des progress-indicators
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"PROGRESS.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>
	#include	<string.h>					/* strlen() etc.. */
	#include	<stdlib.h>					/* malloc etc... */
	#include	<aes.h>						/* header AES */
   

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"	
	#include	"STKEYMAP.H"	
	#include "STUT_ONE.RSC\STUT_3.H"					/* noms des objets ds le ressource */


/*
 * ------------------------ PROTOTYPES -------------------------
 */


/*
 * EXTernal prototypes:
 */
	/* 
	 * G‚n‚ral: 
	 */
	extern	void	signale( char * inf );
	extern	void	erreur_rsrc( void );
	/* 
	 * Objects: 
	 */
	extern	void	rsrc_color( OBJECT *tree );
	extern	void	dlink_teptext ( OBJECT *objc_adr , const char *texte );
	extern	void	rlink_teptext ( OBJECT *objc_adr , const char *texte );
	extern	GRECT	* objc_xywh ( OBJECT *tree, int objc, GRECT *frame );
	extern	void	objc_sel( OBJECT *tree, int obj );
	extern	void	objc_dsel( OBJECT *tree, int obj );
	extern	void	objc_clrsel(  OBJECT *tree, int obj );
	/* 
	 * Sp‚cial: 
	 */
	extern	void	grecttoarray( GRECT *rect, int *array );
	extern	long	l_min( long a, long b);		/* Minimum de 2 long int */
	extern	long	l_max( long a, long b);		/* Minimum de 2 long int */
	extern	void	ping( void );


/*
 * ------------------------ VARIABLES -------------------------
 */
    
/*
 * External variables: 
 */
	/* 
	 * G‚n‚ral: 
	 */
	extern	int		G_ev_mgpbuff[8];				/* Buffer d'‚venements GEM */


/*
 * Private variables: 
 */
	/* 
	 * Objets: 
	 */
	static	OBJECT	*M_std_progress;
	static	GRECT		M_progress_form_box;	/* Coord boite complŠte */
	static	GRECT		M_prog_indicator_box;	/* Coord de la boite de l'indicateur */
	static	GRECT		M_prog_cancel_box;		/* Coord du bouton Annuler */
	static	int		M_prog_cancel_xy[4];	/* Coord en X1 y1 x2 y2 */
	/* 
	 * Variables du progress en cours: 
	 */
	static	BOOL		M_b_DontManageEnv = FALSE0;
	static	BOOL		M_b_visible = FALSE0;		/* Le progress est-il visible? */	 
	static	int		M_curr_prog_width;		/* Largeur de progress courament affich‚ee */	
	static	int		M_max_prog_width;		/* Largeur maximale */
	static	long		M_curr_prog_length;		/* Longueur totale du progress en cours */
	static	long		M_curr_slice_size;		/* Longueur d'une tranche avant mise … jour */
	static	int		M_m1_state;				/* Etat du contr“le position souris par rapport au bouton annuler */
 
/*
 * ------------------------ FUNCTIONS -------------------------
 */



/*
 * init_progress(-)
 *
 * Purpose:
 * --------
 * Initialisations
 *
 * History:
 * --------
 * fplanque: Created
 */
void	init_progress( void )
{
	/*
	 * Trouve adresses des arbres d'objets: 
	 */
	if (rsrc_gaddr( R_TREE, PROGRESS, &M_std_progress) == 0)
		erreur_rsrc();
	rsrc_color( M_std_progress );		/* Fixe couleurs */

	/*
	 * Largeur de la boŒte de progress: 
	 */
	M_max_prog_width = M_std_progress[ PROGBOX ] .ob_width;
	
}



/*
 * start_progress(-)
 *
 * Purpose:
 * --------
 * Affichage de la boite de progression
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 08.01.95: param b_DontManageEnv
 * 30.01.95: prend taille de bloc minimale qu'on accepte
 */
long	start_progress( 							/* Out: Taille de bloc pour obtenir la fluidit‚ maximale */
			const char *	title, 
			const char *	info, 
			long 				prog_length,
			long				l_MinBlockSize,	/* In: Taille de bloc minimale qu'on accepte */
			BOOL				b_DontManageEnv )	/* In: True si il ne faut pas g‚rer l'environnent, par ex si on a d‚j… un dialogue ouvert … l'‚cran */
			
{
	/*
	 * Initialise la progression: 
	 */
	M_b_DontManageEnv	 = b_DontManageEnv;
	M_curr_prog_length = prog_length;	/* Longueur de la progression */
	M_m1_state = 0;	/* Par d‚faut, la souris n'est pas sur le bouton "Annuler" */

	/*
	 * Fixe textes: 
	 */
	dlink_teptext ( &(M_std_progress[ PROGTITL ]) , title );	/* Titre */
	rlink_teptext ( &(M_std_progress[ PROGINFO ]) , info );	/* Info */

	/*
	 * Reset progress bar: 
	 */
	M_curr_prog_width = 0;		/* Largeur affich‚e: 0 */

	/*
	 * Centre formulaire: 
	 */
	form_center( M_std_progress, 
		&(M_progress_form_box .g_x), &(M_progress_form_box .g_y), &(M_progress_form_box .g_w), &(M_progress_form_box .g_h) );
	
	/*
	 * Sauve coordonn‚es de l'indicateur: 
	 */
	objc_xywh( M_std_progress, PROGBOX, &M_prog_indicator_box );
	objc_xywh( M_std_progress, PROGANNU, &M_prog_cancel_box );
	grecttoarray( &M_prog_cancel_box, M_prog_cancel_xy );

	/*
	 * Souris: 
	 */
	graf_mouse( BUSYBEE, 0);	/* souris: Abeille */

	/*
	 * On d‚clare cette ouverture … l'AES: 
	 */
	if( b_DontManageEnv == FALSE0 )
	{
		/* App prend en charge souris */
		WIND_UPDATE_BEG_MCTRL

		form_dial( FMD_START, 0, 0, 0, 0,
			M_progress_form_box .g_x, M_progress_form_box .g_y, M_progress_form_box .g_w, M_progress_form_box .g_h );
		/* printf("\033Y  F"); */
	}
	
	/*
	 * Dessine objet: 
	 */
	objc_draw( M_std_progress, 0, 2, 	/* La profondeur choisie fait que l'on n'affiche pas la barre elle mˆme, juste son cadre! */
		M_progress_form_box .g_x, M_progress_form_box .g_y, M_progress_form_box .g_w, M_progress_form_box .g_h );

	/*
	 * Progress est maintenant visible:
	 */
	M_b_visible = TRUE_1;

	/*
	 * Calcule la longueur d'une tranche: 
	 * (Longueur aprŠs laquelle on recommande au processus appellant de faire un update,
	 * afin d'obtenir une fluidit‚ maximale 
	 */
	M_curr_slice_size = l_max( M_curr_prog_length / M_max_prog_width, l_MinBlockSize );	/* Minimum l_MinBlockSize */
	return 	l_min( M_curr_slice_size, M_curr_prog_length );	/* Maximum calcul‚ pour ne pas d‚passer la fin */
}




/*
 * update_progress(-)
 *
 * Purpose:
 * --------
 * Mise … jour de la progression
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 28.09.94: gŠre la visibilit‚ de la boŒte
 * 31.01.95: retourne taille block et non pas longueur totale
 */
long	update_progress( 
			long prog_done )
{
	int	event;
	int	mx, my, mstate, mnb_clicks;
	int	key_state, key_ret;

	/*
	 * Calcule nlle longueur de la barre de progression: 
	 */
	int	new_prog_width;
	
	if( M_curr_prog_length != 0 )
	{
		new_prog_width = (int) (M_max_prog_width * prog_done / M_curr_prog_length );
	}
	else
	{
		new_prog_width = M_max_prog_width;
	}

	/*
	 * Contr“le si ‡a a boug‚: 
	 */
	if ( new_prog_width > M_curr_prog_width )
	{	/*
		 * Si le progress … avanc‚ 
		 * Fixe nlle longueur: 
		 */
		M_std_progress[ PROGBAR ] .ob_width = new_prog_width;

		/*
		 * Affiche le bout en plus: 
		 */			
		if( M_b_visible )
		{
			objc_draw( M_std_progress, PROGBAR, 1, 	
				M_prog_indicator_box .g_x + M_curr_prog_width, M_prog_indicator_box .g_y, 
				new_prog_width -M_curr_prog_width +1, M_prog_indicator_box .g_h );
		}
		
		/* 
		 * Nlle longueur courante: 
		 */
		M_curr_prog_width = new_prog_width;
	}

	/*
	 * Appel rapide de l'AES pour voir si l'utilisateur d‚sire annuler: 
	 */
	event = evnt_multi( MU_TIMER|MU_M1|MU_BUTTON|MU_KEYBD,
								1, 1, 1,
		                  M_m1_state, M_prog_cancel_box .g_x, M_prog_cancel_box .g_y, M_prog_cancel_box .g_w, M_prog_cancel_box .g_h,
		                  0, 0, 0, 0, 0,
		                  G_ev_mgpbuff,
		                  0, 0,
		                  &mx, &my, &mstate,
		                  &key_state, &key_ret,
		                  &mnb_clicks );

	/*
	 * Analyse r‚ponse AES: 
	 */
	if ( (event & MU_M1) && M_b_visible )
	{	/*
	 	 * Si la souris est entr‚e/sortie du rectangle: 
	 	 * et si la boite est affich‚e
	 	 */
		if ( M_m1_state == 0 )
		{	/*
			 * Si la souris est entr‚e: 
			 */
			graf_mouse( ARROW, 0);	/* souris: FlŠche */
			objc_sel( M_std_progress, PROGANNU );	/* S‚lectionne bouton */
			M_m1_state = 1;	/* On va attendre que la souris ressorte */
		}
		else
		{	/*
		 	 * Si la souris est sortie: 
		 	 */
			graf_mouse( BUSYBEE, 0);	/* souris: Abeille */
			objc_dsel( M_std_progress, PROGANNU );	/* D‚s‚lectionne bouton */
			M_m1_state = 0;	/* On va attendre que la souris entre … nouveau */
		}
	}
	
	if ( (event & MU_BUTTON) &&  M_b_visible )
	{	/*
		 * Si on a cliqu‚ et si form affich‚
		 * Contr“le si on a cliqu‚ … l'int‚rieur du bouton "Annuler": 
		 */
		if (	mx >= M_prog_cancel_xy[ 0 ] && mx <= M_prog_cancel_xy[ 2 ]
			&&	my >= M_prog_cancel_xy[ 1 ] && my <= M_prog_cancel_xy[ 3 ] )
		{	/*
			 * Si on a annul‚: 
			 */
			objc_sel( M_std_progress, PROGANNU );	/* S‚lectionne bouton */
			return	TRUE_1;			/* On a interrompu l'action en cours... */
		}
	}
		
	if ( event & MU_KEYBD )
	{
		if ( key_ret == STSCAN_UNDO )
		{	/*
			 * Si on a appuy‚ sur UNDO 
			 */
			if( M_b_visible )
			{
				objc_sel( M_std_progress, PROGANNU );	/* S‚lectionne bouton */
			}
			return	TRUE_1;			/* On a interrompu l'action en cours... */
		}

	}

	/*
	 * On peut continuer l'affichage... 
	 * Calcule la taille de la prochaine tranche: 
	 * (Longueur aprŠs laquelle on recommande au processus appellant de faire un update, afin d'obtenir une fluidit‚ maximale)
	 */
	return 	l_min( M_curr_slice_size, M_curr_prog_length - prog_done );	/* Maximum calcul‚ pour ne pas d‚passer la fin */
}




/*
 * end_progress(-)
 *
 * Purpose:
 * --------
 * Effa‡age de la boite de progression
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 08.01.95: param pObj_BackgrdForm
 */
void	end_progress(
			OBJECT	*	pObj_BackgrdForm )	/* In: Arbe … afficher en fond */
{
	/*
	 * Affiche le progress jusqu'au bout:
	 */
	update_progress( M_curr_prog_length );

	if( pObj_BackgrdForm != NULL )
	{	/* 
	 	 *	Red‚ssinne le fond: 
	 	 */
		objc_draw( pObj_BackgrdForm, 0, 5, M_progress_form_box .g_x, M_progress_form_box .g_y, M_progress_form_box .g_w, M_progress_form_box .g_h );
	}

	if( M_b_DontManageEnv == FALSE0 )
	{	/*
	  	 * On efface le formulaire par l'AES: 
	  	 */
		form_dial( FMD_FINISH, 0, 0, 0, 0,
			M_progress_form_box .g_x, M_progress_form_box .g_y, M_progress_form_box .g_w, M_progress_form_box .g_h );
		/* printf("\033Y  -"); */
	
		/* AES peut reprendre la souris */
		WIND_UPDATE_END_MCTRL
	}
	
	/*
	 * Progress est maintenant invisible:
	 */
	M_b_visible = FALSE0;

	/*
	 * D‚s‚lectionne bouton Annuler 
	 */
	objc_clrsel( M_std_progress, PROGANNU );

}
