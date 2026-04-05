/* **[WindUpdate]*************** */
/* *                           * */
/* * 20/12/2012 MaJ 29/01/2015 * */
/* ***************************** */



void ouvre_fenetre_windupdate( void )
{

	OBJECT	*adr_formulaire;
	int16	x,y,largeur,hauteur;
	int16	winx,winy,winw,winh;
	uint16	win_flag;

	int16	index_win=W_WINDUPDATE;



	#ifdef LOG_FILE
	sprintf( buf_log, " ~ Ouverture fenˆtre WindUpdate  : hwin(%d)=", index_win );
	log_print(FALSE);
	#endif



	if( h_win[index_win]>0 )
	{
		buffer_aes[0]=WM_TOPPED;
		buffer_aes[1]=ap_id;
		buffer_aes[2]=0;
		buffer_aes[3]=h_win[index_win];
		appl_write( ap_id, 16, &buffer_aes );
	}
	else
	{
		win_flag=NAME|CLOSER|MOVER|BACKDROP|SMALLER;

		/* on recherche l'adresse du Formulaire */
		rsrc_gaddr( R_TREE, DL_WINDUPDATE, &adr_formulaire );

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
		wind_calc(	0,win_flag,
					x, y, largeur, hauteur, &winx, &winy, &winw, &winh );


		/* Replace la fenetre … sa derniŠre position enregistr‚ */
		Fcm_set_win_position( index_win, &winx, &winy );


		/* On demande … l'AES de cr‚er notre fenˆtre */
		h_win[index_win]=wind_create(	win_flag,
										winx,winy,winw,winh); 

		if( h_win[index_win]>0 )
		{
			/* on m‚morise la position de la fenˆtre */
			win_posxywh[index_win][0]=winx;
			win_posxywh[index_win][1]=winy;
			win_posxywh[index_win][2]=winw;
			win_posxywh[index_win][3]=winh;

			#ifdef LOG_FILE
			sprintf( buf_log, "%2d ; w=%3d, h=%3d"CRLF, h_win[index_win], winw, winh );
			log_print(FALSE);
			#endif


			/* adresse du dialogue des titres de fenetre */
			rsrc_gaddr( R_TREE, DL_TITRE_FENETRE, &adr_formulaire );

			/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un nom ... */
			wind_set_str(h_win[index_win],WF_NAME,(adr_formulaire+TITRE_WINDUPDATE)->ob_spec.free_string);
			/* ... et on demande … l'AES de l'ouvrir */
			wind_open(h_win[index_win],winx,winy,winw,winh);

		}
		else
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "‚chec"CRLF);
			log_print(FALSE);
			#endif

			h_win[index_win]=FCM_NO_OPEN_WINDOW;
			Fcm_form_alerte( 0, ALT_NO_WINDOWS );
		}
	}


	return;


}

