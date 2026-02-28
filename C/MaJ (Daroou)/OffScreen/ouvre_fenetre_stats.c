/* **[Offscreen]**************** */
/* *                           * */
/* * 13/12/2015 MaJ 18/12/2015 * */
/* ***************************** */




#include "fonction/coeur/Fcm_Set_Win_Position.c"
#include "fonction/coeur/Fcm_Form_Alerte.c"



/* Prototype */
VOID ouvre_fenetre_stats( VOID );


/* Fonction */
VOID ouvre_fenetre_stats( VOID )
{
	/* Variables Globales Externes:
	 *
	 * extern	WORD	h_win[NB_FENETRE];
	 * extern	WORD	winpos[NB_FENETRE][5];
	 *
	 */

	OBJECT	*adr_formulaire;
	WORD	x,y,largeur,hauteur;
	WORD	winx,winy,winw,winh;
	UWORD	win_flag;



	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"* ouvre_fenetre_stats() : hwin(%d)=", W_STATS );
	log_print(FALSE);
	#endif



	if( h_win[W_STATS] > 0 )
	{
		buffer_aes[0]=WM_TOPPED;
		buffer_aes[1]=ap_id;
		buffer_aes[2]=0;
		buffer_aes[3]=h_win[W_STATS];
		appl_write( ap_id, 16, &buffer_aes );
	}
	else
	{
		win_flag=NAME|CLOSER|MOVER|BACKDROP|SMALLER;

		/* on recherche l'adresse du Formulaire */
		rsrc_gaddr( R_TREE, DL_STATS, &adr_formulaire );

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
		wind_calc( 0, win_flag, x, y, largeur, hauteur, &winx, &winy, &winw, &winh );


		/* On applique les coordonn‚es sauvegard‚es dans la fichier de config si */
		/* pr‚sente, sinon on laisse les coordonn‚es centr‚es                    */
		Fcm_set_win_position( W_STATS, &winx, &winy );


		/* On demande … l'AES de cr‚er notre fenˆtre */
		h_win[W_STATS]=wind_create(	win_flag, winx, winy, winw, winh); 


		if( h_win[W_STATS]>0 )
		{
			/* on m‚morise la position de la fenˆtre */
			win_posxywh[W_STATS][0]=winx;
			win_posxywh[W_STATS][1]=winy;
			win_posxywh[W_STATS][2]=winw;
			win_posxywh[W_STATS][3]=winh;

			#ifdef LOG_FILE
			sprintf( buf_log, "%2d ; x=%4d, y=%4d, w=%3d, h=%3d"CRLF, h_win[W_STATS], winx, winy, winw, winh );
			log_print(FALSE);
			#endif


			/* adresse du dialogue des titres de fenetre */
			rsrc_gaddr( R_TREE, DL_TITRE_FENETRE, &adr_formulaire );

			/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un nom ... */
			wind_set_str(h_win[W_STATS],WF_NAME,(adr_formulaire+TITRE_STATS)->ob_spec.free_string);
			/* ... et on demande … l'AES de l'ouvrir */
			wind_open(h_win[W_STATS],winx,winy,winw,winh);

		}
		else
		{
			int16 dummy;

			#ifdef LOG_FILE
			sprintf( buf_log, "‚chec"CRLF);
			log_print(FALSE);
			#endif

			h_win[W_STATS]=FCM_NO_OPEN_WINDOW;
/*			Fcm_form_alerte( 0, ALT_NO_WINDOWS );*/
			Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NO_WINDOWS, &dummy );

		}
	}


	return;


}

