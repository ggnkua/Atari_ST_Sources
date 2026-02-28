/* **[]************************* */
/* *                           * */
/* * 20/04/2015 MaJ 20/04/2015 * */
/* ***************************** */



#define	FCM_INDEX_FENETRE	W_LAUNCH
#define	FCM_TITRE_FENETRE	TITRE_LAUNCH



void Fcm_ouvre_fenetre_launch( void );



/* Fonction */
void Fcm_ouvre_fenetre_launch( void )
{


	OBJECT	*adr_formulaire;
	int16	x,y,largeur,hauteur;
	int16	winx,winy,winw,winh;
	uint16	win_flag;




	#ifdef LOG_FILE
	sprintf( buf_log, " ~ ouvre_fenetre_launch(), hwin(%d)=", FCM_INDEX_FENETRE );
	log_print(FALSE);
	#endif



	if( h_win[FCM_INDEX_FENETRE]>0 )
	{
		buffer_aes[0]=WM_TOPPED;
		buffer_aes[1]=ap_id;
		buffer_aes[2]=0;
		buffer_aes[3]=h_win[FCM_INDEX_FENETRE];
		appl_write( ap_id, 16, &buffer_aes );
	}
	else
	{
		win_flag=NAME|MOVER|BACKDROP;

		/* on recherche l'adresse du Formulaire */
		rsrc_gaddr( R_TREE, win_rsc[ FCM_INDEX_FENETRE], &adr_formulaire );

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
		Fcm_set_win_position( FCM_INDEX_FENETRE, &winx, &winy );


		/* On demande … l'AES de cr‚er notre fenˆtre */
		h_win[FCM_INDEX_FENETRE]=wind_create(	win_flag,
										winx,winy,winw,winh); 

		if( h_win[FCM_INDEX_FENETRE]>0 )
		{
			/* on m‚morise la position de la fenˆtre */
			win_posxywh[FCM_INDEX_FENETRE][0]=winx;
			win_posxywh[FCM_INDEX_FENETRE][1]=winy;
			win_posxywh[FCM_INDEX_FENETRE][2]=winw;
			win_posxywh[FCM_INDEX_FENETRE][3]=winh;

			#ifdef LOG_FILE
			sprintf( buf_log, "%2d ; w=%3d, h=%3d"CRLF, h_win[FCM_INDEX_FENETRE], winw, winh );
			log_print(FALSE);
			#endif


			/* adresse du dialogue des titres de fenetre */
			rsrc_gaddr( R_TREE, DL_TITRE_FENETRE, &adr_formulaire );

			/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un nom ... */
			wind_set_str(h_win[FCM_INDEX_FENETRE],WF_NAME,(adr_formulaire+FCM_TITRE_FENETRE)->ob_spec.free_string);
			/* ... et on demande … l'AES de l'ouvrir */
			wind_open(h_win[FCM_INDEX_FENETRE],winx,winy,winw,winh);


		}
		else
		{
			int16 dummy;

			#ifdef LOG_FILE
			sprintf( buf_log, "‚chec (ERREUR)"CRLF);
			log_print(FALSE);
			#endif

			h_win[FCM_INDEX_FENETRE]=FCM_NO_OPEN_WINDOW;
/*			Fcm_form_alerte( 0, ALT_NO_WINDOWS );*/
			Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NO_WINDOWS, &dummy );

		}
	}


	return;


}


#undef	FCM_INDEX_FENETRE
#undef	FCM_TITRE_FENETRE

