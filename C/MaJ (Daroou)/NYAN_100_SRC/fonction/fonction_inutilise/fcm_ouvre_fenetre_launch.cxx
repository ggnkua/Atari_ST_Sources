/* **[]************************* */
/* *                           * */
/* * 20/04/2015 MaJ 20/04/2015 * */
/* ***************************** */




#include "coeur/Fcm_rescale_def.h"


void Fcm_ouvre_fenetre_launch( void );
void Fcm_rescale_fenetre_launch( void );


/* Fonction */
void Fcm_ouvre_fenetre_launch( void )
{
	OBJECT	*adr_formulaire;
	int16	x,y,largeur,hauteur;
	int16	winx,winy,winw,winh;
	int16	flag_win;


#define	FCM_INDEX_FENETRE	W_LAUNCH
#define	FCM_TITRE_FENETRE	TITRE_LAUNCH


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
		Fcm_rescale_fenetre_launch();
		
		flag_win=NAME|MOVER|BACKDROP;

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
		wind_calc(	0,flag_win,
					x, y, largeur, hauteur, &winx, &winy, &winw, &winh );


		/* Replace la fenetre … sa derniŠre position enregistr‚ */
		Fcm_set_win_position( FCM_INDEX_FENETRE, &winx, &winy );


		/* On demande … l'AES de cr‚er notre fenˆtre */
		h_win[FCM_INDEX_FENETRE]=wind_create(	flag_win,
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



#undef	FCM_INDEX_FENETRE
#undef	FCM_TITRE_FENETRE


	return;

}








/* Fonction */
void Fcm_rescale_fenetre_launch( void )
{

	OBJECT	*dial;
	/*int16    form_w;*/
	/*int16    gr_hwbox, gr_hhbox;*/
	int16	 gr_hwcar,gr_hhcar;


	

	#define IMG_LAUNCH_WIDTH  (48)
	#define IMG_LAUNCH_HEIGHT (32)

	
	/* Marre que le formulaire s'affiche mal d'une resolution a l'autre */
	/* tous les objets et le fond sont repositionner                    */

	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_rescale_fenetre_launch()"CRLF );
	log_print(FALSE);
	#endif


	/* espace occuper par les caracteres de la fonte systeme */
	{
		int16 dummy;

		/*graf_handle( &gr_hwcar, &gr_hhcar, &gr_hwbox, &gr_hhbox );*/
		graf_handle( &gr_hwcar, &gr_hhcar, &dummy, &dummy );
/*		{
			char texte_surface[80];
			sprintf( texte_surface, "gr_hwcar=%d, gr_hhcar=%d, gr_hwbox=%d, gr_hhbox=%d", gr_hwcar, gr_hhcar, gr_hwbox, gr_hhbox );
			v_gtext( vdihandle, 1*16, 2*16, texte_surface);
		}*/
	}


	/* on cherche l'adresse du formulaire et l'objet sous la souris */
	rsrc_gaddr( R_TREE, DL_LAUNCH, &dial );

	dial[LAUNCH_IMAGE].ob_y     = FCM_RESCALE_MARGE_HAUT/2;
	dial[LAUNCH_BOX].ob_x       = FCM_RESCALE_MARGE_GAUCHE;
	dial[LAUNCH_BOX].ob_y       = dial[LAUNCH_IMAGE].ob_y + IMG_LAUNCH_HEIGHT + FCM_RESCALE_INTERLIGNE;
	dial[LAUNCH_FOND].ob_width  = dial[LAUNCH_BOX].ob_x + dial[LAUNCH_BOX].ob_width + FCM_RESCALE_MARGE_DROITE;
	dial[LAUNCH_IMAGE].ob_x     = (dial[LAUNCH_FOND].ob_width - IMG_LAUNCH_WIDTH) / 2;
	dial[LAUNCH_FOND].ob_height = dial[LAUNCH_BOX].ob_y + dial[LAUNCH_BOX].ob_height + FCM_RESCALE_MARGE_BAS;


	#undef IMG_LAUNCH_WIDTH
	#undef IMG_LAUNCH_HEIGHT


	return;

}

