/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 18/12/2015 * */
/* ***************************** */




void ouvre_fenetre_sprite_offscreen( void );



/* Fonction */
void ouvre_fenetre_sprite_offscreen( void )
{

	OBJECT	*adr_formulaire;
	int16	winx,winy,winw,winh;
	uint16	win_flag;





	#ifdef LOG_FILE
	sprintf( buf_log, " ~ ouvre_fenetre_sprite_offscreen(), hwin(%d)=", W_SPRITE_OFFSCREEN );
	log_print(FALSE);
	#endif



	if( h_win[W_SPRITE_OFFSCREEN]>0 )
	{
		/* la fenetre est ouverte */
		buffer_aes[0]=WM_TOPPED;
		buffer_aes[1]=ap_id;
		buffer_aes[2]=0;
		buffer_aes[3]=h_win[W_SPRITE_OFFSCREEN];
		appl_write( ap_id, 16, &buffer_aes );
	}
	else
	{
		win_flag=NAME|CLOSER|MOVER|BACKDROP;

		/* on demande … l'AES de nous calculer la taille de la fenˆtre */
		/* en fonction de la zone de travail                           */
		wind_calc(	0, win_flag,
					0, 0, SPRITE_OFFSCREEN_WIDTH, SPRITE_OFFSCREEN_HEIGHT, &winx, &winy, &winw, &winh );


		/* Replace la fenetre … sa derniŠre position enregistr‚ */
		Fcm_set_win_position( W_SPRITE_OFFSCREEN, &winx, &winy );

		/* On demande … l'AES de cr‚er notre fenˆtre */
		h_win[W_SPRITE_OFFSCREEN]=wind_create(	win_flag,winx,winy,winw,winh); 


		winy = MIN( winy, (Fcm_screen.y_desktop + Fcm_screen.h_desktop - 1 - winh) );
		winy = MAX( winy, Fcm_screen.y_desktop );

		winx = MIN( winx, (Fcm_screen.x_desktop + Fcm_screen.w_desktop - 1 - winw) );
		winx = MAX( winx, Fcm_screen.x_desktop );


		if( h_win[W_SPRITE_OFFSCREEN]>0 )
		{
			/* on m‚morise la position de la fenˆtre */
			win_posxywh[W_SPRITE_OFFSCREEN][0]=winx;
			win_posxywh[W_SPRITE_OFFSCREEN][1]=winy;
			win_posxywh[W_SPRITE_OFFSCREEN][2]=winw;
			win_posxywh[W_SPRITE_OFFSCREEN][3]=winh;

			#ifdef LOG_FILE
			sprintf( buf_log, "%2d ; w=%3d, h=%3d"CRLF, h_win[W_SPRITE_OFFSCREEN], winw, winh );
			log_print(FALSE);
			#endif


			/* adresse du dialogue des titres de fenetre */
			rsrc_gaddr( R_TREE, DL_TITRE_FENETRE, &adr_formulaire );

			/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un nom ... */
			wind_set_str(h_win[W_SPRITE_OFFSCREEN],WF_NAME,(adr_formulaire+TITRE_SPRITE_OFF)->ob_spec.free_string);
/*			wind_set_str(h_win[W_SPRITE_OFFSCREEN],WF_INFO, win_info_texte);*/
			/* ... et on demande … l'AES de l'ouvrir */
			wind_open(h_win[W_SPRITE_OFFSCREEN],winx,winy,winw,winh);


		}
		else
		{
			int16 dummy;

			#ifdef LOG_FILE
			sprintf( buf_log, "‚chec (ERREUR)"CRLF);
			log_print(FALSE);
			#endif

			h_win[W_SPRITE_OFFSCREEN]=FCM_NO_OPEN_WINDOW;
			Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NO_WINDOWS, &dummy );

		}
	}


	return;


}

