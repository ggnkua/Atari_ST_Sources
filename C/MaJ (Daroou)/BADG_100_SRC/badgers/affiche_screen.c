/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 06/12/2015 * */
/* ***************************** */


#include "../fonction/graphique/fcm_make_liste_redraw.h"

void affiche_screen( void );





void affiche_screen( void )
{

	/* si la fenetre n'est pas ouverte, on affiche rien */
	if( h_win[W_BADGERS] == FCM_NO_OPEN_WINDOW )
	{
		Fcm_nb_liste_refresh_ecran=0;
		return;
	}




    /* ---------------------------- */
	/* fenetre iconifi‚e            */
	/* ---------------------------- */
	if( win_iconified[W_BADGERS]==TRUE )
	{
		GRECT	r1,r2;
		int16	winx,winy,winw,winh;


		/* on cherche les coordonn‚es de travail de la fenˆtre */
		wind_get(h_win[W_BADGERS],WF_WORKXYWH,&winx,&winy,&winw,&winh);

		r1.g_x=winx;
		r1.g_y=winy;
		r1.g_w=winw;
		r1.g_h=winh;


		if( wind_update(BEG_UPDATE) )
		{
			/* C'est bon, on peut redessiner notre fenetre */
			/* ------------------------------------------- */


			wind_get(h_win[W_BADGERS],WF_FIRSTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

			while ( r2.g_w && r2.g_h )
			{
				if( rc_intersect(&r1,&r2) )
				{
					pxy[0] = r2.g_x;
					pxy[1] = r2.g_y;
					pxy[2] = r2.g_x + r2.g_w - 1;
					pxy[3] = r2.g_y + r2.g_h - 1;

					graf_mouse(M_OFF, NULL);
					vs_clip( vdihandle, CLIP_ON, pxy );

					pxy[0]=r2.g_x - winx + view_iconified_x;
					pxy[1]=r2.g_y - winy + view_iconified_y;
					pxy[2]=pxy[0] + r2.g_w - 1;
					pxy[3]=pxy[1] + r2.g_h - 1;

					pxy[4]=r2.g_x;
					pxy[5]=r2.g_y;
					pxy[6]=r2.g_x + r2.g_w - 1;
					pxy[7]=r2.g_y + r2.g_h - 1;

/*					{
						int16 pxyarray[4];

						pxyarray[0]=r2.g_x;
						pxyarray[1]=r2.g_y;
						pxyarray[2]=pxyarray[0]+r2.g_w;
						pxyarray[3]=pxyarray[1]+r2.g_h;

						vsf_color(vdihandle, 6);
						vr_recfl(vdihandle, pxyarray);
						evnt_timer(20);
					}*/

					vro_cpyfm(vdihandle,3,pxy,  &mfdb_framebuffer, &Fcm_mfdb_ecran);

				 	vs_clip( vdihandle, CLIP_OFF, 0);
					graf_mouse(M_ON, NULL);
				}

				wind_get(h_win[W_BADGERS],WF_NEXTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);
			}

			/* On libŠre l'‚cran */
			wind_update(END_UPDATE);
		}

	}
	else
	{

	    /* ---------------------------- */
		/* fenetre taille normal        */
		/* affichage des zones modifi‚s */
		/* ---------------------------- */

		GRECT	zone_win;
		int16	winx,winy,dummy;


		/* on cherche les coordonn‚es de travail de la fenˆtre */
		wind_get(h_win[W_BADGERS],WF_WORKXYWH,&winx,&winy,&dummy,&dummy);



		if( wind_update(BEG_UPDATE) )
		{

			/* C'est bon, on peut redessiner notre fenetre */
			/* ------------------------------------------- */

			wind_get(h_win[W_BADGERS],WF_FIRSTXYWH,&zone_win.g_x,&zone_win.g_y,&zone_win.g_w,&zone_win.g_h);

			while ( zone_win.g_w && zone_win.g_h )
			{
				int16 index_redraw;


				for( index_redraw=0; index_redraw<Fcm_nb_liste_refresh_ecran; index_redraw++)
				{
					GRECT zone_redraw;


					*(&zone_redraw) = 	*(&Fcm_liste_refresh_ecran[index_redraw]);

					zone_redraw.g_x += winx;
					zone_redraw.g_y += winy;


					if ( rc_intersect(&zone_win,&zone_redraw) )
					{
						pxy[0] = zone_redraw.g_x;
						pxy[1] = zone_redraw.g_y;
						pxy[2] = zone_redraw.g_x + zone_redraw.g_w - 1;
						pxy[3] = zone_redraw.g_y + zone_redraw.g_h - 1;

						graf_mouse(M_OFF, NULL);
						vs_clip( vdihandle, CLIP_ON, pxy );

						pxy[0]=zone_redraw.g_x - winx;
						pxy[1]=zone_redraw.g_y - winy;
						pxy[2]=pxy[0] + zone_redraw.g_w - 1;
						pxy[3]=pxy[1] + zone_redraw.g_h - 1;

						pxy[4]=zone_redraw.g_x;
						pxy[5]=zone_redraw.g_y;
						pxy[6]=zone_redraw.g_x + zone_redraw.g_w - 1;
						pxy[7]=zone_redraw.g_y + zone_redraw.g_h - 1;


						vro_cpyfm(vdihandle,3,pxy,  &mfdb_framebuffer, &Fcm_mfdb_ecran);

					 	vs_clip( vdihandle, CLIP_OFF, 0);
						graf_mouse(M_ON, NULL);
					}
				}

				wind_get(h_win[W_BADGERS],WF_NEXTXYWH,&zone_win.g_x,&zone_win.g_y,&zone_win.g_w,&zone_win.g_h);
			}

			/* On libŠre l'‚cran */
			wind_update(END_UPDATE);
		}
	}



	/* remise … z‚ro liste des redraw */
	Fcm_nb_liste_refresh_ecran=0;


	return;


}

