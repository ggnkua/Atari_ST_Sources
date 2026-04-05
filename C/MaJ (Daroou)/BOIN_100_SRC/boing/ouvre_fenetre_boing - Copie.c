/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 17/10/2015 * */
/* ***************************** */


#include	"../fonction/coeur/Fcm_affiche_alerte.c"


void ouvre_fenetre_boing( void );



/* Fonction */
void ouvre_fenetre_boing( void )
{

	OBJECT	*adr_formulaire;
	int16	winx,winy,winw,winh;
	int16	flag_win;





	#ifdef LOG_FILE
	sprintf( buf_log, " ~ ouvre_fenetre_boing() hwin(%d)=", W_BOING );
	log_print(FALSE);
	#endif



	if( h_win[W_BOING]>0 )
	{
		/* la fenetre est ouverte */
		buffer_aes[0]=WM_TOPPED;
		buffer_aes[1]=ap_id;
		buffer_aes[2]=0;
		buffer_aes[3]=h_win[W_BOING];
		appl_write( ap_id, 16, &buffer_aes );
	}
	else
	{
		flag_win=NAME|INFO|CLOSER|MOVER|BACKDROP|SMALLER;

		/* on centre la fenetre */
		winx = (Fcm_screen.w_desktop-SCREEN_WIDTH) / 2;
		winy = ((Fcm_screen.h_desktop-SCREEN_HEIGHT) / 2) + Fcm_screen.y_desktop;


		/* on demande … l'AES de nous calculer la taille de la fenˆtre */
		/* en fonction de la zone de travail                           */
		wind_calc(	0, flag_win,
					winx, winy, SCREEN_WIDTH, SCREEN_HEIGHT, &winx, &winy, &winw, &winh );


		/* Replace la fenetre … sa derniŠre position enregistr‚ */
		Fcm_set_win_position( W_BOING, &winx, &winy );


		/* On demande … l'AES de cr‚er notre fenˆtre */
		h_win[W_BOING]=wind_create(	flag_win,winx,winy,winw,winh); 

		if( h_win[W_BOING]>0 )
		{
			/* on m‚morise la position de la fenˆtre */
			win_posxywh[W_BOING][0]=winx;
			win_posxywh[W_BOING][1]=winy;
			win_posxywh[W_BOING][2]=winw;
			win_posxywh[W_BOING][3]=winh;

			#ifdef LOG_FILE
			sprintf( buf_log, "%2d ; w=%3d, h=%3d"CRLF, h_win[W_BOING], winw, winh );
			log_print(FALSE);
			#endif


			/* adresse du dialogue des titres de fenetre */
			rsrc_gaddr( R_TREE, DL_TITRE_FENETRE, &adr_formulaire );

			/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un nom ... */
			wind_set_str(h_win[W_BOING],WF_NAME,(adr_formulaire+TITRE_BOING)->ob_spec.free_string);
			wind_set_str(h_win[W_BOING],WF_INFO, win_info_texte);
			/* ... et on demande … l'AES de l'ouvrir */
			wind_open(h_win[W_BOING],winx,winy,winw,winh);


		}
		else
		{
			int16 dummy;

			#ifdef LOG_FILE
			sprintf( buf_log, "‚chec (ERREUR)"CRLF);
			log_print(FALSE);
			#endif

			h_win[W_BOING]=FCM_NO_OPEN_WINDOW;
			Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NO_WINDOWS, &dummy );

		}
	}


	return;


}

