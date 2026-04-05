/* *[Console]******************* */
/* *                           * */
/* * 01/01/2024 MaJ 03/01/2024 * */
/* ***************************** */


//#include "fcm_set_win_position.c"
//#include "fcm_form_alerte.c"
#include "../fcm_affiche_alerte.h"


void Fcm_console_ouvre_fenetre( void )
{
	int16	x,y,largeur,hauteur;
	int16	winx,winy,winw,winh;


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"* Fcm_console_ouvre_fenetre()"CRLF );
	log_print(FALSE);
	#endif


	if( h_win[W_CONSOLE] > 0 )
	{
		/* La console reste dans le plan actuel, pas de premier plan */
		return;
	}
	else
	{
		/* Calcul des dimensions de la fenetre par defaut */
		x       = 4;
		largeur = Fcm_struct_console_global.nblettre_visible * Fcm_struct_console_global.char_cellw;
		//largeur = 160;
		hauteur = Fcm_struct_console_global.nbligne_visible  * Fcm_struct_console_global.char_cellh;
		//hauteur = 80;
		y       = Fcm_screen.h_desktop - hauteur - 32;

		/* on demande … l'AES de nous calculer les dimensions de la fenˆtre */
		wind_calc( WC_BORDER, win_widgets[W_CONSOLE],	x, y, largeur, hauteur, &winx, &winy, &winw, &winh );

		/* On applique les coordonn‚es sauvegard‚es dans le fichier de config si */
		/* pr‚sente, sinon on laisse les coordonn‚es centr‚es                    */
		Fcm_set_win_position( W_CONSOLE, &winx, &winy, &winw, &winh );

		winw = MIN( winw, (Fcm_screen.w_desktop-16) );  /* 16 -> VSLIDE */
		winh = MIN( winh, (Fcm_screen.h_desktop-32) );  /* 32 -> NAME + HSLIDE */

		winx = MIN( winx, (Fcm_screen.w_desktop-winw) );
		winx = MAX( 0, winx );

		winy = MIN( winy, (Fcm_screen.h_desktop-winh) );
		winy = MAX( 0, winy );

		/* on doit verifier les dimensions interne de la fenˆtre */
		/* Les dimensions sont alignées sur la taille d'un caractère en W et H */
		wind_calc( WC_WORK, win_widgets[W_CONSOLE],	winx, winy, winw, winh, &x, &y, &largeur, &hauteur  );

		largeur = MIN( largeur, ((largeur*largeur)/Fcm_struct_console_global.char_cellw) );
		hauteur = MIN( hauteur, ((hauteur*hauteur)/Fcm_struct_console_global.char_cellh) );

		/* on demande … l'AES de nous calculer les dimensions de la fenˆtre */
		wind_calc( WC_BORDER, win_widgets[W_CONSOLE],	x, y, largeur, hauteur, &winx, &winy, &winw, &winh );


		/* On demande … l'AES de cr‚er notre fenˆtre */
		h_win[W_CONSOLE]=wind_create( win_widgets[W_CONSOLE], winx, winy, winw, winh);
		//h_win[W_CONSOLE]=wind_create( win_widgets[W_CONSOLE], 16, 32, 160, 80);


		if( h_win[W_CONSOLE] > 0 )
		{
			//OBJECT	*adr_formulaire;

			/* on m‚morise la position de la fenˆtre */
			win_posxywh[W_CONSOLE][0]=winx;
			win_posxywh[W_CONSOLE][1]=winy;
			win_posxywh[W_CONSOLE][2]=winw;
			win_posxywh[W_CONSOLE][3]=winh;

			#ifdef LOG_FILE
			sprintf( buf_log, "hwin(%d)=%2d ; x=%4d, y=%4d, w=%3d, h=%3d"CRLF, W_CONSOLE, h_win[W_CONSOLE], winx, winy, winw, winh );
			log_print(FALSE);
			#endif


			/* adresse du dialogue des titres de fenetre */
			//rsrc_gaddr( R_TREE, DL_TITRE_FENETRE, &adr_formulaire );
			//adr_formulaire = Fcm_adr_RTREE[DL_TITRE_FENETRE];

			/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un titre... */
			snprintf( fcm_win_titre_texte[W_CONSOLE], FCM_WIN_TITRE_MAXSIZE, APP_WIN_PREFIX_TITRE" Console");
			wind_set_str(h_win[W_CONSOLE],WF_NAME, fcm_win_titre_texte[W_CONSOLE]);

			/* ... et on demande … l'AES de l'ouvrir */
			wind_open(h_win[W_CONSOLE],winx,winy,winw,winh);


/* en doublon dans gestion_sized... a factoriser et controler les dimensions de la zone work ? */
wind_get(h_win[W_CONSOLE],WF_WORKXYWH,&winx,&winy,&winw,&winh);

Fcm_struct_console_global.nbligne_visible  = winh / Fcm_struct_console_global.char_cellh;
Fcm_struct_console_global.nblettre_visible = winw / Fcm_struct_console_global.char_cellw;

Fcm_struct_console_global.ligne_start  = FCM_CONSOLE_MAXLIGNE - Fcm_struct_console_global.nbligne_visible;



			Fcm_console_set_slider();
		}
		else
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "‚chec"CRLF);
			log_print(FALSE);
			#endif

			h_win[W_CONSOLE]=FCM_NO_OPEN_WINDOW;
			Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NO_WINDOWS, 0 );
		}
	}


	return;

}

