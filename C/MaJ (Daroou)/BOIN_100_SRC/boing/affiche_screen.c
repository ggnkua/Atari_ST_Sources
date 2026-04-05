/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 24/09/2023 * */
/* ***************************** */




/* prototype */
void affiche_screen( void );




/* Fonction */
void affiche_screen( void )
{

	/* si la fenetre n'est pas ouverte, bah on affiche rien */
	if( h_win[W_BOING] == FCM_NO_OPEN_WINDOW )
	{
		return;
	}






    /* ---------------------------- */
	/* fenetre iconifi‚e            */
	/* ---------------------------- */
	if( win_iconified[W_BOING] == TRUE )
	{
		GRECT	r1,r2;
		int16	winx,winy,winw,winh;


		/* on cherche les coordonn‚es de travail de la fenˆtre */
		wind_get(h_win[W_BOING],WF_WORKXYWH,&winx,&winy,&winw,&winh);

		r1.g_x = winx;
		r1.g_y = winy;
		r1.g_w = winw;
		r1.g_h = winh;


		if( wind_update(BEG_UPDATE) )
		{
			/* C'est bon, on peut redessiner notre fenetre */
			/* ------------------------------------------- */


			wind_get(h_win[W_BOING],WF_FIRSTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

			while ( r2.g_w && r2.g_h )
			{
				if( rc_intersect(&r1,&r2) )
				{
					pxy[0] = r2.g_x;
					pxy[1] = r2.g_y;
					pxy[2] = r2.g_x + r2.g_w - 1;
					pxy[3] = r2.g_y + r2.g_h - 1;

					graf_mouse(M_OFF, NULL);
					
					vs_clip( global_vdihandle_ecran, CLIP_ON, pxy );


					pxy[4] = pxy[0];
					pxy[5] = pxy[1];
					pxy[6] = pxy[2];
					pxy[7] = pxy[3];

					pxy[0] = r2.g_x - winx + view_iconified_x;
					pxy[1] = r2.g_y - winy + view_iconified_y;
					pxy[2] = pxy[0] + r2.g_w - 1;
					pxy[3] = pxy[1] + r2.g_h - 1;

					vro_cpyfm(global_vdihandle_ecran, 3, pxy, &mfdb_framebuffer, &Fcm_mfdb_ecran);


				 	vs_clip( global_vdihandle_ecran, CLIP_OFF, 0);

					graf_mouse(M_ON, NULL);

				}

				wind_get(h_win[W_BOING],WF_NEXTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

			}

			/* On libŠre l'‚cran */
			wind_update(END_UPDATE);

		}

		return;

	}












    /* ---------------------------- */
	/* fenetre taille normal        */
	/* affichage des zones modifi‚s */
	/* ---------------------------- */
	{
		GRECT	zone_win;
		int16	winx,winy,dummy;


		/* on cherche les coordonn‚es de travail de la fenˆtre */
		wind_get(h_win[W_BOING],WF_WORKXYWH,&winx,&winy,&dummy,&dummy);



		if( wind_update(BEG_UPDATE) )
		{

			/* C'est bon, on peut redessiner notre fenetre */
			/* ------------------------------------------- */

			wind_get(h_win[W_BOING],WF_FIRSTXYWH,&zone_win.g_x,&zone_win.g_y,&zone_win.g_w,&zone_win.g_h);

			while ( zone_win.g_w && zone_win.g_h )
			{

/*				for( index_redraw=0; index_redraw<Fcm_nb_liste_refresh_ecran; index_redraw++)*/
				{
					GRECT zone_redraw;


/*					*(&zone_redraw) = 	*(&Fcm_liste_refresh_ecran[index_redraw]);*/


					/* optimisation du redraw de la Ball et de l'ombre      */
					/* les deux sont cote … cote et ont une partie communes */
					/* On affiche la zone occup‚ par les deux               */
					zone_redraw.g_x = MIN( Fcm_liste_refresh_ecran[0].g_x, Fcm_liste_refresh_ecran[1].g_x );
					zone_redraw.g_y = MIN( Fcm_liste_refresh_ecran[0].g_y, Fcm_liste_refresh_ecran[1].g_y );

					zone_redraw.g_w = MAX( Fcm_liste_refresh_ecran[0].g_x+Fcm_liste_refresh_ecran[0].g_w, Fcm_liste_refresh_ecran[1].g_x+Fcm_liste_refresh_ecran[1].g_w ) - zone_redraw.g_x;
					zone_redraw.g_h = MAX( Fcm_liste_refresh_ecran[0].g_y+Fcm_liste_refresh_ecran[0].g_h, Fcm_liste_refresh_ecran[1].g_y+Fcm_liste_refresh_ecran[1].g_h ) - zone_redraw.g_y;


					zone_redraw.g_x = zone_redraw.g_x + winx;
					zone_redraw.g_y = zone_redraw.g_y + winy;


					if ( rc_intersect(&zone_win,&zone_redraw) )
					{

						pxy[0] = zone_redraw.g_x;
						pxy[1] = zone_redraw.g_y;
						pxy[2] = zone_redraw.g_x + zone_redraw.g_w - 1;
						pxy[3] = zone_redraw.g_y + zone_redraw.g_h - 1;

						graf_mouse(M_OFF, NULL);

						vs_clip( global_vdihandle_ecran, CLIP_ON, pxy );



						pxy[4] = pxy[0];
						pxy[5] = pxy[1];
						pxy[6] = pxy[2];
						pxy[7] = pxy[3];

						pxy[0] = zone_redraw.g_x - winx;
						pxy[1] = zone_redraw.g_y - winy;
						pxy[2] = pxy[0] + zone_redraw.g_w - 1;
						pxy[3] = pxy[1] + zone_redraw.g_h - 1;

						/* On ne copie pas tout l'écran, seul les parties changeante */
						/* ceci permet de montrer la zone qui est redessiné à l'écran */
/*						{
						evnt_timer(50);
						vro_cpyfm(global_vdihandle_ecran,0,pxy,  &mfdb_framebuffer, &Fcm_mfdb_ecran);
						evnt_timer(50);
						}*/


						vro_cpyfm(global_vdihandle_ecran,3,pxy,  &mfdb_framebuffer, &Fcm_mfdb_ecran);

						vs_clip( global_vdihandle_ecran, CLIP_OFF, 0);

						/* affichage complet du frame buffer sur l'écran pour debug */
/*						{
							pxy[0] = 0;
							pxy[1] = 0;
							pxy[2] = SCREEN_WIDTH-1;
							pxy[3] = SCREEN_HEIGHT-1;

							pxy[4] = 0;
							pxy[5] = 20;
							pxy[6] = SCREEN_WIDTH-1;
							pxy[7] = 20+SCREEN_HEIGHT-1;
							vro_cpyfm(global_vdihandle_ecran,3,pxy,  &mfdb_framebuffer, &Fcm_mfdb_ecran);
						}*/


						graf_mouse(M_ON, NULL);

					}

				}

				wind_get(h_win[W_BOING],WF_NEXTXYWH,&zone_win.g_x,&zone_win.g_y,&zone_win.g_w,&zone_win.g_h);

			}

			/* On libŠre l'‚cran */
			wind_update(END_UPDATE);
		}
	}



	return;


}

