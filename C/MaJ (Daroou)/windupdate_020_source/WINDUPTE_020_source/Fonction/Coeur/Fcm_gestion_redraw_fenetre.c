/* **[Fonction commune]******** */
/* * Gere Redraw des fenetres * */
/* * 10/12/2001 = 06/04/2013  * */
/* **************************** */


#ifndef __Fcm_gestion_redraw_fenetre__
#define __Fcm_gestion_redraw_fenetre__


/* Prototypes */
VOID Fcm_gestion_redraw_fenetre(VOID);


/* Fonction */
VOID Fcm_gestion_redraw_fenetre(VOID)
{
/*
 * extern	FT_REDRAW	table_ft_redraw_win[NB_FENETRE];
 * extern	WORD		buffer_aes[16];
 * extern	WORD		h_win[NB_FENETRE];
 * extern	WORD		pxy[16];
 * extern	WORD		vdihandle;
 *
 */

	GRECT	r1,r2;
	UWORD	win_index;



	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"* Fcm_gestion_redraw_fenetre()"CRLF );
	log_print(FALSE);
	#endif


	/* Cette fonction gŠre les redraws de toutes les fenetres  */
	/* de l'application. Elle calcul les zones … redessiner,   */
	/* installe le clipping et execute la fonction qui gŠre    */
	/* le contenu de la fenetre afin de la (re)dessinner       */


	/* coordonnee de la zone a redessinner */
	r1.g_x = buffer_aes[4];
	r1.g_y = buffer_aes[5];
	r1.g_w = buffer_aes[6];
	r1.g_h = buffer_aes[7];

	/* Conversion absolu VDI */
	pxy[0] = r1.g_x;
	pxy[1] = r1.g_y;
	pxy[2] = r1.g_x + r1.g_w - 1;
	pxy[3] = r1.g_y + r1.g_h - 1;


	/* Index de la fenetre concern‚e */
	win_index= Fcm_get_indexwindow( buffer_aes[3] );


	/* On r‚serve l'‚cran pour ne pas entrer en conflict avec des     */
	/* affichages venant d'autres applications.                       */
	/* Si une appli a d‚j… r‚serv‚ l'‚cran, la fonction Wind_Update() */
	/* va attendre jusqu'… ce que l'‚cran soit lib‚r‚...              */
	if( wind_update(BEG_UPDATE) )  
	{

		/* C'est bon, on peut redessiner notre fenetre... */
		wind_get(buffer_aes[3],WF_FIRSTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

		while ( r2.g_w && r2.g_h )
		{
			if ( rc_intersect(&r1,&r2) )
			{
				pxy[0] = r2.g_x;
				pxy[1] = r2.g_y;
				pxy[2] = r2.g_x + r2.g_w - 1;
				pxy[3] = r2.g_y + r2.g_h - 1;

				graf_mouse(M_OFF, NULL);
				vs_clip( vdihandle, CLIP_ON, pxy );


				if( table_ft_redraw_win[win_index] != FCM_FONCTION_NON_DEFINI )
				{
					table_ft_redraw_win[win_index] ( &r2 );
				}
				else
				{
					Fcm_form_alerte( 0, ALT_ERR_NOFUNC );
					#ifdef LOG_FILE
					sprintf( buf_log, "ERREUR !!! Fcm_gestion_redraw_fenetre(%d) pas de fonction defini !!!;"CRLF, win_index );
					log_print(FALSE);
					#endif
				}


			 	vs_clip( vdihandle, CLIP_OFF, 0);
				graf_mouse(M_ON, NULL);
			}


			wind_get(buffer_aes[3],WF_NEXTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);
		}


		/* On libŠre l'‚cran */
		wind_update(END_UPDATE);
	}


	/* Si la fenetre a besoin de rafraichir son contenu */
	/* suite … un redraw (partiel)                      */
	if( table_ft_refresh_win[win_index] != FCM_FONCTION_NON_DEFINI )
	{
		table_ft_refresh_win[win_index] ();
	}


	return;


}


#endif

