/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 10/12/2001 MaJ 26/02/2024 * */
/* ***************************** */



#ifndef __FCM_GESTION_REDRAW_FENETRE_C__
#define __FCM_GESTION_REDRAW_FENETRE_C__



/*
 * 27/06/2020 : Ajout d'un test supplementaire: rc_intersect(&Fcm_zone_bureau,&r2)
 *   Il arrive qu'une zone à redessiner soit hors ecran, donc on verifie que la zone
 *   est bien contenu dans l'ecran.
 *   Je n'ai vu ce cas que sous TOS 4.xx en 320x200, avec chevauchement de fenetre,
 *   avec une demande de redessin qui commence en x=320, qui provoque un bus error
 *
 */



void Fcm_gestion_redraw_fenetre(void)
{
	GRECT	r1,r2;
	int16	win_index;


	FCM_LOG_PRINT1(CRLF"* Fcm_gestion_redraw_fenetre hdl=%d", buffer_aes[3]);
//FCM_CONSOLE_DEBUG1(CRLF"Fcm_gestion_redraw_fenetre handle=buffer_aes[3]=%d", buffer_aes[3]);

	/* Cette fonction gŠre les redraws de toutes les fenetres  */
	/* de l'application. Elle calcul les zones … redessiner,   */
	/* installe le clipping et execute la fonction qui gŠre    */
	/* le contenu de la fenetre afin de la (re)dessinner       */

	/* coordonnee de la zone a redessinner */
	r1.g_x = buffer_aes[4];
	r1.g_y = buffer_aes[5];
	r1.g_w = buffer_aes[6];
	r1.g_h = buffer_aes[7];

	/* Index de la fenetre concern‚e */
	win_index = Fcm_get_indexwindow( buffer_aes[3] );

//FCM_LOG_PRINT1(" - win_index=%d", win_index );
//FCM_CONSOLE_DEBUG1(" - win_index=%d", win_index );

	/* On r‚serve l'‚cran pour ne pas entrer en conflict avec des     */
	/* affichages venant d'autres applications.                       */
	/* Si une appli a d‚j… r‚serv‚ l'‚cran, la fonction Wind_Update() */
	/* va attendre jusqu'… ce que l'‚cran soit lib‚r‚...              */
	if( win_index < NB_FENETRE )
	{
		if( wind_update(BEG_UPDATE) )  
		{
//FCM_LOG_PRINT4(" zone de redraw demande par l'AES : r1.g_x=%d r1.g_y=%d r1.g_w=%d r1.g_h=%d", r1.g_x,r1.g_y,r1.g_w,r1.g_h );

			/* C'est bon, on peut redessiner notre fenetre... */
			wind_get(buffer_aes[3],WF_FIRSTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

//FCM_LOG_PRINT4(" WF_FIRSTXYWH : r2.g_x=%d r2.g_y=%d r2.g_w=%d r2.g_h=%d", r2.g_x,r2.g_y,r2.g_w,r2.g_h );

			graf_mouse(M_OFF, NULL);

			while ( r2.g_w && r2.g_h )
			{
				if ( rc_intersect(&r1,&r2) )
				{
//FCM_LOG_PRINT4(" Dimension desktop: %d,%d,%d,%d", Fcm_screen.x_desktop,Fcm_screen.y_desktop,Fcm_screen.w_desktop,Fcm_screen.h_desktop);
//FCM_LOG_PRINT4(" rc_intersect : r2.g_x=%d r2.g_y=%d r2.g_w=%d r2.g_h=%d", r2.g_x,r2.g_y,r2.g_w,r2.g_h );

					if( rc_intersect(&Fcm_zone_bureau,&r2) )
					{
//FCM_LOG_PRINT4("Zrc_intersect : r2.g_x=%d r2.g_y=%d r2.g_w=%d r2.g_h=%d", r2.g_x,r2.g_y,r2.g_w,r2.g_h );

						pxy[0] = r2.g_x;
						pxy[1] = r2.g_y;
						pxy[2] = r2.g_x + r2.g_w - 1;
						pxy[3] = r2.g_y + r2.g_h - 1;

						vs_clip( vdihandle, CLIP_ON, pxy );

						if( table_ft_redraw_win[win_index] != FCM_FONCTION_NON_DEFINI )
						{
//FCM_CONSOLE_DEBUG("Appel fonction redraw defini");
							table_ft_redraw_win[win_index] ( &r2, win_index );
						}
						else
						{
//FCM_CONSOLE_DEBUG("Appel fonction redraw du Coeur");
							Fcm_redraw_fenetre( &r2, win_index );
						}

						vs_clip( vdihandle, CLIP_OFF, 0);
					}
				}
				wind_get(buffer_aes[3],WF_NEXTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);
			}

			graf_mouse(M_ON, NULL);

			/* On libŠre l'‚cran */
			wind_update(END_UPDATE);
		}

		/* Si la fenetre a besoin de rafraichir son contenu */
		/* suite … un redraw (partiel)                      */
		if( table_ft_refresh_win[win_index] != FCM_FONCTION_NON_DEFINI )
		{
			table_ft_refresh_win[win_index]();
		}
	}
	else
	{
		FCM_LOG_PRINT1("Fcm_gestion_redraw_fenetre() ERREUR  win_index > NB_FENETRE buffer_aes[3]=%d", buffer_aes[3]);

		//FCM_CONSOLE_DEBUG1("Fcm_gestion_redraw_fenetre() ERREUR  win_index > NB_FENETRE buffer_aes[3]=%d", buffer_aes[3]);
		//FCM_CONSOLE_DEBUG6("(0)=%d (1)=%d (2)=%d (3)=%d (4)=%d (5)=%d ", h_win[0],h_win[1],h_win[2],h_win[3],h_win[4],h_win[5] );
		//FCM_CONSOLE_DEBUG6("(6)=%d (7)=%d (10)=%d (10)=%d (10)=%d (10)=%d ", h_win[6],h_win[7],h_win[10],h_win[10],h_win[10],h_win[10] );

		//evnt_timer(2000);
	}

	FCM_LOG_PRINT( " fin Fcm_gestion_redraw_fenetre"CRLF);

	return;


}


#endif   /*    __FCM_GESTION_REDRAW_FENETRE_C__   */

