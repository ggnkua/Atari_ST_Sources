/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 12/11/2023 * */
/* ***************************** */

#include	"../fonction/coeur/fcm_affiche_alerte.c"

void ouvre_fenetre_badgers( void );






void ouvre_fenetre_badgers( void )
{
	//OBJECT	*adr_formulaire;
	int16   x,y;
	int16	winx,winy,winw,winh;



#ifdef LOG_FILE
sprintf( buf_log, " ~ ouvre_fenetre_badgers(), hwin(%d)=", W_BADGERS );
log_print(FALSE);
#endif



	if( h_win[W_BADGERS]>0 )
	{
#ifdef LOG_FILE
sprintf( buf_log, " fenetre d‚j… ouverte"CRLF );
log_print(FALSE);
#endif

		buffer_aes[0]=WM_TOPPED;
		buffer_aes[1]=ap_id;
		buffer_aes[2]=0;
		buffer_aes[3]=h_win[W_BADGERS];
		appl_write( ap_id, 16, &buffer_aes );
	}
	else
	{
		int16 dummy_pos;

		/* Calcul des dimensions de la fenetre en fonction */
		/* de la taille du formulaire                      */
		x = (Fcm_screen.width -  SCREEN_WIDTH ) / 2;
		y = (Fcm_screen.height - SCREEN_HEIGHT) / 2;

		/* on demande … l'AES de nous calculer la taille de la fenˆtre */
		/* en fonction de la zone de travail (taille formulaire)       */
		wind_calc( 0, win_widgets[W_BADGERS], x, y, SCREEN_WIDTH, SCREEN_HEIGHT, &winx, &winy, &winw, &winh );

		/* Replace la fenetre … sa derniŠre position enregistr‚ */
		Fcm_set_win_position( W_BADGERS, &winx, &winy, &dummy_pos, &dummy_pos  );

		/* On demande … l'AES de cr‚er notre fenˆtre */
		h_win[W_BADGERS] = wind_create( win_widgets[W_BADGERS],winx,winy,winw,winh ); 

		if( h_win[W_BADGERS]>0 )
		{
			/* on m‚morise la position de la fenˆtre */
			win_posxywh[W_BADGERS][0]=winx;
			win_posxywh[W_BADGERS][1]=winy;
			win_posxywh[W_BADGERS][2]=winw;
			win_posxywh[W_BADGERS][3]=winh;

#ifdef LOG_FILE
sprintf( buf_log, "%2d ; w=%3d, h=%3d"CRLF, h_win[W_BADGERS], winw, winh );
log_print(FALSE);
#endif


			/* adresse du dialogue des titres de fenetre */
			//rsrc_gaddr( R_TREE, DL_TITRE_FENETRE, &adr_formulaire );

			/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un nom ... */
#ifdef LOG_FILE
			//snprintf( fcm_win_titre_texte[W_BADGERS], FCM_WIN_TITRE_MAXSIZE, "%s *Debug*", adr_formulaire[win_titre[W_BADGERS]].ob_spec.free_string);
			snprintf( fcm_win_titre_texte[W_BADGERS], FCM_WIN_TITRE_MAXSIZE, "%s *Debug*", PRG_FULL_NOM );
#else
			//snprintf( fcm_win_titre_texte[W_BADGERS], FCM_WIN_TITRE_MAXSIZE, "%s", adr_formulaire[win_titre[W_BADGERS]].ob_spec.free_string);
			snprintf( fcm_win_titre_texte[W_BADGERS], FCM_WIN_TITRE_MAXSIZE, "%s", PRG_FULL_NOM );
#endif
			wind_set_str(h_win[W_BADGERS],WF_NAME, fcm_win_titre_texte[W_BADGERS]);
			wind_set_str(h_win[W_BADGERS],WF_INFO, win_info_texte);
			/* ... et on demande … l'AES de l'ouvrir */
			wind_open(h_win[W_BADGERS],winx,winy,winw,winh);
		}
		else
		{
			int16 dummy;

#ifdef LOG_FILE
sprintf( buf_log, "‚chec (ERREUR)"CRLF);
log_print(FALSE);
#endif

			h_win[W_BADGERS]=FCM_NO_OPEN_WINDOW;
			Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NO_WINDOWS, &dummy );

		}
	}


	return;


}

