/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 20/04/2015 MaJ 22/02/2024 * */
/* ***************************** */



#ifndef ___FCM_FENETRE_LAUNCH_C___
#define ___FCM_FENETRE_LAUNCH_C___


#include "coeur/Fcm_rescale_def.h"

void Fcm_fenetre_launch( int16 idx_message, int16 launch_mode, uint32 launch_wait );
void Fcm_ouvre_fenetre_launch( void );
void Fcm_rescale_fenetre_launch( void );


/* paramètre launch_mode */
#define LAUNCH_INIT   (1)
#define LAUNCH_OPEN   (2)
#define LAUNCH_CLOSE  (3)
#define LAUNCH_UPDATE (4)

/* paramètre launch_wait */
#define LAUNCH_WAIT_SLOW   (200)
#define LAUNCH_WAIT_NORMAL ( 60)
#define LAUNCH_WAIT_FAST   ( 20)
#define LAUNCH_WAIT_FTL    (  0)

/* sp‚cial idx_message, pour message de progression  */
#define LH_INIT_SURFACE    (999)
#define LH_INIT            (0)
/*      LH_xxxxxxxxxxxx    voir DL_LAUNCH_TEXTE pour les idx_message specifique à l'appli */



/*
 *
 * Init bar progression : xx est le nombre total d'appel a Fcm_fenetre_launch
 * affichable en console dans la fonction pour en déterminer la valeur.
 * Fcm_fenetre_launch( LH_INIT, LAUNCH_INIT, xx );   nombre total d'appel a Fcm_fenetre_launch => bar progression 
 *
 * Ouverture fenetre launch avec le message LH_INIT_BOING et attente de LAUNCH_WAIT_FAST
 * Fcm_fenetre_launch( LH_INIT_BOING, LAUNCH_OPEN, LAUNCH_WAIT_FAST);
 *
 * Mise a jour avec le nouveau message LH_VERIF_FICHIER et attente de LAUNCH_WAIT_FAST
 * Fcm_fenetre_launch( LH_VERIF_FICHIER, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
 *
 *
 * Message special Auto-incrémenté pour indiquer la progression du chargement des surfaces
 * Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
 *
 *
 * Fermeture fenetre launch, avec l'id du dernier message (ou autre, mais different des id de
 * commande, pas de message affiché avec LAUNCH_CLOSE
 * Fcm_fenetre_launch( LH_INIT_TERMINE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
 * Fcm_fenetre_launch( LH_INIT_TERMINE, LAUNCH_CLOSE, LAUNCH_WAIT_FAST);
 *
 *
 */



void Fcm_fenetre_launch( int16 idx_message, int16 launch_mode, uint32 launch_wait )
{
	static	uint16  init_start       = 0;    /* pout memoriser l'init de la fonction */
	static	uint16  idx_init_surface = 0;    /* pour LH_INIT_SURFACE idx_message */
	static  uint16  total_call_launch= 99;   /* pour bar de progression */
	static  uint16  nb_call_launch   = 0;


	FCM_LOG_PRINT(CRLF"# Fcm_fenetre_launch()");


	if( launch_mode == LAUNCH_INIT )
	{
		total_call_launch = launch_wait;
		nb_call_launch=0;
		return;
	}

	/* comptabilise le nombre d'appel a la fonction, sert pour la barre de progression */
	nb_call_launch++;

//FCM_CONSOLE_ADD2("nb_call_launch=%d", nb_call_launch, G_YELLOW );
	FCM_LOG_PRINT1("nb_call_launch=%d", nb_call_launch);


	if( init_start == 0 )
	{
		init_start = 1;
		win_widgets           [ W_LAUNCH ] = NAME|MOVER|BACKDROP;
		win_rsc               [ W_LAUNCH ] = DL_LAUNCH;
		win_rsc_iconify       [ W_LAUNCH ] = FCM_NO_RSC_DEFINED;
		table_ft_ouvre_fenetre[ W_LAUNCH ] = Fcm_ouvre_fenetre_launch;
		table_ft_redraw_win   [ W_LAUNCH ] = FCM_FONCTION_NON_DEFINI;    /* c'est le coeur qui s'en charge */
	}


	if( idx_message == LH_INIT_SURFACE )
	{
		idx_init_surface++;

		if( idx_init_surface > 4 )
		{
			idx_init_surface = 0;
		}

		/* LH_INIT_SURFACE1 a LH_INIT_SURFACE5 doivent etre consecutif dans le dialogue */
		idx_message = LH_INIT_SURFACE1 + idx_init_surface;
	}


	if( launch_mode == LAUNCH_OPEN  ||  launch_mode == LAUNCH_UPDATE )
	{
		OBJECT *dial;


		dial = Fcm_adr_RTREE[DL_LAUNCH_TEXTE];
		FCM_LOG_PRINT1("=> OUT {%s}", dial[idx_message].ob_spec.free_string );
		Fcm_set_rsc_string( DL_LAUNCH, LAUNCH_TEXTE, dial[idx_message].ob_spec.free_string );


		dial = Fcm_adr_RTREE[DL_LAUNCH];
		/* BAR progression */
		dial[LAUNCH_BAR].ob_width = MIN( ((nb_call_launch * dial[LAUNCH_BOX].ob_width) / total_call_launch) , dial[LAUNCH_BOX].ob_width );


		if( launch_mode == LAUNCH_OPEN )
		{
			Fcm_ouvre_fenetre_launch();
		}

		if( launch_mode == LAUNCH_UPDATE )
		{
			Fcm_objet_draw( dial, h_win[W_LAUNCH], LAUNCH_BOX , FCM_WU_BLOCK );
		}
	}


	if( launch_mode == LAUNCH_CLOSE )
	{
		init_start = 0; /* en cas de redemmarage */
		Fcm_fermer_fenetre(W_LAUNCH);
	}


	Fcm_purge_aes_message();


	if( launch_wait != LAUNCH_WAIT_FTL )
	{
		evnt_timer(launch_wait);
	}


	return;


}










void Fcm_ouvre_fenetre_launch( void )
{
	int16	winx, winy, winw, winh;


	FCM_LOG_PRINT1(" ~ ouvre_fenetre_launch(), hwin(%d)", W_LAUNCH );


	Fcm_rescale_fenetre_launch();

	/* on demande … l'AES de centrer le dialogue sur le DeskTop */
	form_center( Fcm_adr_RTREE[ win_rsc[W_LAUNCH] ], &winx, &winy, &winw, &winh );

	{
		int16  x, y, largeur, hauteur;

		{
			int16  dummy;
			graf_mkstate( &souris.g_x, &souris.g_y, &dummy, &dummy);
		}

		/* Calcul des dimensions de la fenetre en fonction */
		/* de la taille du formulaire                      */
		x       = winx;
		y       = winy;
		largeur = winw;
		hauteur = winh;

		/* on place le dialoque pres du curseur de la souris */
		x = souris.g_x - (largeur/2);
		y = souris.g_y - (hauteur/2);

		/* on verifie que le dialogue n'est pas hors ecran */
		x = MAX( x, (Fcm_screen.x_desktop + 2) );
		x = MIN( x, (Fcm_screen.w_desktop - largeur - 2) );
		y = MAX( y, (Fcm_screen.y_desktop + 2) );
		y = MIN( y, (Fcm_screen.h_desktop - hauteur - 2) );
		y = MAX( y, (Fcm_screen.y_desktop + Fcm_screen.gr_hhbox + 4) ); /* espace pour la barre de titre de la fenetre */

		/* on demande … l'AES de nous calculer la taille de la fenˆtre */
		/* en fonction de la zone de travail (taille formulaire)       */
		wind_calc( WC_BORDER, win_widgets[W_LAUNCH], x, y, largeur, hauteur, &winx, &winy, &winw, &winh );
	}

	/* On demande … l'AES de cr‚er notre fenˆtre */
	h_win[W_LAUNCH] = wind_create( win_widgets[W_LAUNCH], winx, winy, winw, winh );

	if( h_win[W_LAUNCH]>0 )
	{
		//OBJECT	*adr_formulaire;

		FCM_LOG_PRINT3(" -> handle=%2d w=%3d h=%3d", h_win[W_LAUNCH], winw, winh );

		/* adresse du dialogue des titres de fenetre */
		//adr_formulaire = Fcm_adr_RTREE[DL_TITRE_FENETRE];

		snprintf( fcm_win_titre_texte[W_LAUNCH], FCM_WIN_TITRE_MAXSIZE, PRG_FULL_NOM );

		/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un nom ... */
		wind_set_str( h_win[W_LAUNCH], WF_NAME, fcm_win_titre_texte[W_LAUNCH] );
		/* ... et on demande … l'AES de l'ouvrir */
		wind_open( h_win[W_LAUNCH], winx, winy, winw, winh );
	}
	else
	{
		int16 dummy;

		FCM_LOG_PRINT("‚chec (ERREUR)");

		h_win[W_LAUNCH] = FCM_NO_OPEN_WINDOW;

		Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NO_WINDOWS, &dummy );
	}


	return;

}





void Fcm_rescale_fenetre_launch( void )
{
	OBJECT	*dial;

	
	/* Marre que le formulaire s'affiche mal d'une resolution a l'autre */
	/* tous les objets et le fond sont repositionne                     */

	FCM_LOG_PRINT("# Fcm_rescale_fenetre_launch()" );


	/* on cherche l'adresse du formulaire */
	//rsrc_gaddr( R_TREE, DL_LAUNCH, &dial );
	dial = Fcm_adr_RTREE[DL_LAUNCH];


	dial[LAUNCH_IMAGE].ob_y = FCM_RESCALE_MARGE_HAUT/2;

	FCM_LOG_PRINT1("dial[LAUNCH_IMAGE].ob_height=%d", dial[LAUNCH_IMAGE].ob_height );
	//FCM_CONSOLE_ADD2("dial[LAUNCH_IMAGE].ob_height=%d", dial[LAUNCH_IMAGE].ob_height, G_YELLOW );


	dial[LAUNCH_TEXTE].ob_x = FCM_RESCALE_MARGE_GAUCHE/2;
	dial[LAUNCH_TEXTE].ob_y = FCM_RESCALE_MARGE_HAUT/2;


	if( Fcm_screen.nb_plan==1 )
	{
		dial[LAUNCH_BAR].ob_spec.obspec.fillpattern = IP_2PATT;
		dial[LAUNCH_BAR].ob_spec.obspec.interiorcol = G_BLACK;
	}
	else
	{
		dial[LAUNCH_BAR].ob_spec.obspec.fillpattern = IP_SOLID;
		dial[LAUNCH_BAR].ob_spec.obspec.interiorcol = G_GREEN;
	}


	dial[LAUNCH_BOX].ob_x       = FCM_RESCALE_MARGE_GAUCHE;
	dial[LAUNCH_BOX].ob_y       = dial[LAUNCH_IMAGE].ob_y + dial[LAUNCH_IMAGE].ob_height + FCM_RESCALE_INTERLIGNE;
	dial[LAUNCH_BOX].ob_width   = dial[LAUNCH_TEXTE].ob_width + FCM_RESCALE_MARGE_GAUCHE/2;
	dial[LAUNCH_BOX].ob_height  = dial[LAUNCH_TEXTE].ob_height + FCM_RESCALE_MARGE_HAUT/2;


	dial[LAUNCH_BAR].ob_x       = 0;
	dial[LAUNCH_BAR].ob_y       = 0;
	dial[LAUNCH_BAR].ob_width   = 0;
	dial[LAUNCH_BAR].ob_height  = dial[LAUNCH_BOX].ob_height;


	dial[LAUNCH_FOND].ob_width  = dial[LAUNCH_BOX].ob_x + dial[LAUNCH_BOX].ob_width + FCM_RESCALE_MARGE_DROITE;
	dial[LAUNCH_FOND].ob_height = dial[LAUNCH_BOX].ob_y + dial[LAUNCH_BOX].ob_height + FCM_RESCALE_MARGE_BAS;

	dial[LAUNCH_IMAGE].ob_x     = (dial[LAUNCH_FOND].ob_width - dial[LAUNCH_IMAGE].ob_width) / 2;


	return;


}


#endif   /*  ___FCM_FENETRE_LAUNCH_C___  */

