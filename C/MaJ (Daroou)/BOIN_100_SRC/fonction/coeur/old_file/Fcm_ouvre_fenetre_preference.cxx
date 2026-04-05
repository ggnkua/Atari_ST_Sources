/* **[Fonction Commune]******* */
/* *                         * */
/* * 17/11/2003 = 08/04/2013 * */
/* *************************** */


#include "Fcm_Set_Win_Position.c"
#include "Fcm_Form_Alerte.c"
#include "Fcm_rescale_def.h"


/* Prototype */
/*void Fcm_ouvre_fenetre_preference( void );*/
void Fcm_rescale_fenetre_preference(void);


/* Fonction */
void Fcm_ouvre_fenetre_preference( void )
{
	/* Variables Globales Externes:
	 *
	 * extern	int16	h_win[NB_FENETRE];
	 * extern	int16	winpos[NB_FENETRE][5];
	 *
	 */

	OBJECT	*adr_formulaire;
	int16	x,y,largeur,hauteur;
	int16	winx,winy,winw,winh;
	int16	flag_win;



	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"* Fcm_ouvre_fenetre_preference() : hwin(%d)=", W_OPTION_PREFERENCE );
	log_print(FALSE);
	#endif



	if( h_win[W_OPTION_PREFERENCE] > 0 )
	{
		buffer_aes[0]=WM_TOPPED;
		buffer_aes[1]=ap_id;
		buffer_aes[2]=0;
		buffer_aes[3]=h_win[W_OPTION_PREFERENCE];
		appl_write( ap_id, 16, &buffer_aes );
	}
	else
	{
		Fcm_rescale_fenetre_preference();

		flag_win=NAME|CLOSER|MOVER|BACKDROP|SMALLER;

		/* on recherche l'adresse du Formulaire */
		rsrc_gaddr( R_TREE, DL_OPT_PREF, &adr_formulaire );

		/* on demande … l'AES de le centrer sur le DeskTop */
		form_center( adr_formulaire, &winx, &winy, &winw, &winh );

		/* Calcul des dimensions de la fenetre en fonction */
		/* de la taille du formulaire                      */
		x       = winx;
		y       = winy;
		largeur = winw;
		hauteur = winh;

		/* on demande … l'AES de nous calculer la taille de la fenˆtre */
		/* en fonction de la zone de travail (taille formulaire)       */
		wind_calc( 0, flag_win, x, y, largeur, hauteur, &winx, &winy, &winw, &winh );


		/* On applique les coordonn‚es sauvegard‚es dans la fichier de config si */
		/* pr‚sente, sinon on laisse les coordonn‚es centr‚es                    */
		Fcm_set_win_position( W_OPTION_PREFERENCE, &winx, &winy );


		/* On demande … l'AES de cr‚er notre fenˆtre */
		h_win[W_OPTION_PREFERENCE]=wind_create(	flag_win, winx, winy, winw, winh); 


		if( h_win[W_OPTION_PREFERENCE]>0 )
		{
			/* on m‚morise la position de la fenˆtre */
			win_posxywh[W_OPTION_PREFERENCE][0]=winx;
			win_posxywh[W_OPTION_PREFERENCE][1]=winy;
			win_posxywh[W_OPTION_PREFERENCE][2]=winw;
			win_posxywh[W_OPTION_PREFERENCE][3]=winh;

			#ifdef LOG_FILE
			sprintf( buf_log, "%2d ; x=%4d, y=%4d, w=%3d, h=%3d"CRLF, h_win[W_OPTION_PREFERENCE], winx, winy, winw, winh );
			log_print(FALSE);
			#endif


			/* adresse du dialogue des titres de fenetre */
			rsrc_gaddr( R_TREE, DL_TITRE_FENETRE, &adr_formulaire );

			/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un nom ... */
			wind_set_str(h_win[W_OPTION_PREFERENCE],WF_NAME,(adr_formulaire+TITRE_PREFERENCE)->ob_spec.free_string);
			/* ... et on demande … l'AES de l'ouvrir */
			wind_open(h_win[W_OPTION_PREFERENCE],winx,winy,winw,winh);

		}
		else
		{
			int16 dummy;

			#ifdef LOG_FILE
			sprintf( buf_log, "‚chec"CRLF);
			log_print(FALSE);
			#endif

			h_win[W_OPTION_PREFERENCE]=FCM_NO_OPEN_WINDOW;
/*			Fcm_form_alerte( 0, ALT_NO_WINDOWS );*/
			Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NO_WINDOWS, &dummy );

		}
	}

	return;

}






/* Fonction */
void Fcm_rescale_fenetre_preference( void )
{
	OBJECT	*dial;
	int16    form_w;
	/*int16    gr_hwbox, gr_hhbox;*/
	int16	 gr_hwcar,gr_hhcar;

	/* Marre que le formulaire s'affiche mal d'une resolution a l'autre */
	/* tous les objets et le fond sont repositionner                    */

	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_rescale_fenetre_preference()"CRLF );
	log_print(FALSE);
	#endif

	/* espace occuper par les caracteres de la fonte systeme */
	{
		int16 dummy;
		graf_handle( &gr_hwcar, &gr_hhcar, &dummy, &dummy );
		/*graf_handle( &gr_hwcar, &gr_hhcar, &gr_hwbox, &gr_hhbox );*/
	}

	/* on cherche l'adresse du formulaire et l'objet sous la souris */
	rsrc_gaddr( R_TREE, DL_OPT_PREF, &dial );



	/* sauve position des fenetre */
	{
		dial[CHK_SAVE_WINPOS].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[CHK_SAVE_WINPOS].ob_y = FCM_RESCALE_MARGE_HAUT;

		dial[PREF_SAVE_WINPOS].ob_x = dial[CHK_SAVE_WINPOS].ob_x + dial[CHK_SAVE_WINPOS].ob_width + FCM_RESCALE_ESPACE;
		dial[PREF_SAVE_WINPOS].ob_y = dial[CHK_SAVE_WINPOS].ob_y;

		form_w = dial[PREF_SAVE_WINPOS].ob_x + dial[PREF_SAVE_WINPOS].ob_width;
	}

	/* quitter sur fermeture fenetre principale */
	{
		dial[CHK_CLOSE_QUIT].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[CHK_CLOSE_QUIT].ob_y = dial[CHK_SAVE_WINPOS].ob_y + dial[CHK_SAVE_WINPOS].ob_height + FCM_RESCALE_INTERLIGNE;

		dial[PREF_CLOSE_QUIT].ob_x = dial[CHK_CLOSE_QUIT].ob_x + dial[CHK_CLOSE_QUIT].ob_width + FCM_RESCALE_ESPACE;
		dial[PREF_CLOSE_QUIT].ob_y = dial[CHK_CLOSE_QUIT].ob_y;

		form_w = MAX( form_w, (dial[PREF_CLOSE_QUIT].ob_x + dial[PREF_CLOSE_QUIT].ob_width) );
	}

	/* sauver les options en quittant */
	{
		dial[CHK_SAVE_AUTO].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[CHK_SAVE_AUTO].ob_y = dial[CHK_CLOSE_QUIT].ob_y + dial[CHK_CLOSE_QUIT].ob_height + FCM_RESCALE_INTERLIGNE;

		dial[PREF_SAVE_AUTO].ob_x = dial[CHK_SAVE_AUTO].ob_x + dial[CHK_SAVE_AUTO].ob_width + FCM_RESCALE_ESPACE;
		dial[PREF_SAVE_AUTO].ob_y = dial[CHK_SAVE_AUTO].ob_y;

		form_w = MAX( form_w, (dial[PREF_SAVE_AUTO].ob_x + dial[PREF_SAVE_AUTO].ob_width) );
	}

	/* bouton sauver */
	{
		dial[PREF_SAVE_CONFIG].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[PREF_SAVE_CONFIG].ob_y = dial[CHK_SAVE_AUTO].ob_y + dial[CHK_SAVE_AUTO].ob_height + FCM_RESCALE_INTERLIGNE;
	}

	/* popup langue */
	{
		/* popup */
		dial[PREF_POPUP_LANG].ob_x = form_w - dial[PREF_POPUP_LANG].ob_width;
		dial[PREF_POPUP_LANG].ob_y = dial[PREF_SAVE_CONFIG].ob_y;

		/* label */
		dial[PREF_POPUP_LABEL].ob_x = dial[PREF_POPUP_LANG].ob_x - dial[PREF_POPUP_LABEL].ob_width - FCM_RESCALE_ESPACE;
		dial[PREF_POPUP_LABEL].ob_y = dial[PREF_SAVE_CONFIG].ob_y;

/*	{
			char texte_surface[80];
			sprintf( texte_surface, "dial[PREF_POPUP_LABEL].ob_x=%d  cut=%d  FCM_RESCALE_ESPACE=%d", dial[PREF_POPUP_LABEL].ob_x, (dial[PREF_SAVE_CONFIG].ob_x+dial[PREF_SAVE_CONFIG].ob_width+FCM_RESCALE_ESPACE), FCM_RESCALE_ESPACE );
			v_gtext( vdihandle, 1*16, 2*16, texte_surface);
	}*/

		if( dial[PREF_POPUP_LABEL].ob_x < (dial[PREF_SAVE_CONFIG].ob_x+dial[PREF_SAVE_CONFIG].ob_width+(FCM_RESCALE_ESPACE*2)) )
		{
			dial[PREF_POPUP_LABEL].ob_x = dial[PREF_SAVE_CONFIG].ob_x + dial[PREF_SAVE_CONFIG].ob_width + (FCM_RESCALE_ESPACE*2);
			dial[PREF_POPUP_LANG].ob_x = dial[PREF_POPUP_LABEL].ob_x + dial[PREF_POPUP_LABEL].ob_width + FCM_RESCALE_ESPACE;
			form_w = MAX( form_w, (dial[PREF_POPUP_LANG].ob_x + dial[PREF_POPUP_LANG].ob_width) );
		}

/*	{
			char texte_surface[80];
			sprintf( texte_surface, "dial[PREF_POPUP_LABEL].ob_x=%d  cut=%d  FCM_RESCALE_ESPACE=%d", dial[PREF_POPUP_LABEL].ob_x, (dial[PREF_SAVE_CONFIG].ob_x+dial[PREF_SAVE_CONFIG].ob_width+FCM_RESCALE_ESPACE), FCM_RESCALE_ESPACE );
			v_gtext( vdihandle, 1*16, 3*16, texte_surface);
	}*/

	}
	
	/* dimension du fond */
	dial[0].ob_width  = form_w + FCM_RESCALE_MARGE_DROITE;
	dial[0].ob_height = dial[PREF_SAVE_CONFIG].ob_y + dial[PREF_SAVE_CONFIG].ob_height + FCM_RESCALE_MARGE_BAS;

/*
	#undef RESCALE_MARGE_H
	#undef RESCALE_MARGE_V
	#undef RESCALE_INTERLIGNE
	#undef RESCALE_ESPACE
*/

	return;

}

