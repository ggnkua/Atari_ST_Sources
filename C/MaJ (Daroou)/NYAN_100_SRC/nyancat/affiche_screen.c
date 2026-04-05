/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 24/05/2018 * */
/* ***************************** */




/* prototype */
void affiche_screen( void );




/* Fonction */
void affiche_screen( void )
{




	/* si la fenetre n'est pas ouverte, on affiche rien */
	if( h_win[W_NYANCAT] == FCM_NO_OPEN_WINDOW )
	{
		return;
	}




    /* ---------------------------- */
	/* fenetre iconifi‚e            */
	/* ---------------------------- */
	if( win_iconified[W_NYANCAT] == TRUE )
	{
		GRECT	r1,r2;
		int16	winx,winy,winw,winh;


		/* on cherche les coordonn‚es de travail de la fenˆtre */
		wind_get(h_win[W_NYANCAT],WF_WORKXYWH,&winx,&winy,&winw,&winh);

		r1.g_x=winx;
		r1.g_y=winy;
		r1.g_w=winw;
		r1.g_h=winh;


		if( wind_update(BEG_UPDATE) )
		{
			/* C'est bon, on peut redessiner notre fenetre */
			/* ------------------------------------------- */


			wind_get(h_win[W_NYANCAT],WF_FIRSTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

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

						vsf_color(global_vdihandle_ecran, 6);
						vr_recfl(global_vdihandle_ecran, pxyarray);
						evnt_timer(20);
					}*/

					vro_cpyfm(global_vdihandle_ecran,VRO_COPY_MODE,pxy, &mfdb_framebuffer, &Fcm_mfdb_ecran);

				 	vs_clip( global_vdihandle_ecran, CLIP_OFF, 0);
					graf_mouse(M_ON, NULL);

				}

				wind_get(h_win[W_NYANCAT],WF_NEXTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

			}

			/* On libŠre l'‚cran */
			wind_update(END_UPDATE);

		}

		return;

	}


    /* ---------------------------- */
	/* fenetre non iconifi‚e        */
	/* ---------------------------- */
	{
		GRECT	r1,r2;
		int16	winx,winy,winw,winh;


		/* on cherche les coordonn‚es de travail de la fenˆtre */
		wind_get(h_win[W_NYANCAT],WF_WORKXYWH,&winx,&winy,&winw,&winh);

		r1.g_x = winx;
		r1.g_y = winy;
		r1.g_w = winw;
		r1.g_h = winh;
/*
		wind_get(h_win[W_NYANCAT],WF_WORKXYWH,&winx,&winy,&dummy,&dummy);
		r1.g_x=winx;
		r1.g_y=winy;
		r1.g_w=SCREEN_WIDTH;
		r1.g_h=SCREEN_HEIGHT;
*/

		if( wind_update(BEG_UPDATE) )
		{

			/* C'est bon, on peut redessiner notre fenetre... */
			wind_get(h_win[W_NYANCAT],WF_FIRSTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

			while ( r2.g_w && r2.g_h )
			{
				if ( rc_intersect(&r1,&r2) )
				{
					pxy[0] = r2.g_x;
					pxy[1] = r2.g_y;
					pxy[2] = r2.g_x + r2.g_w - 1;
					pxy[3] = r2.g_y + r2.g_h - 1;

					graf_mouse(M_OFF, NULL);
					vs_clip( global_vdihandle_ecran, CLIP_ON, pxy );

					pxy[0] = r2.g_x - winx;
					pxy[1] = r2.g_y - winy;
					pxy[2] = pxy[0] + r2.g_w - 1;
					pxy[3] = pxy[1] + r2.g_h - 1;

					pxy[4] = r2.g_x;
					pxy[5] = r2.g_y;
					pxy[6] = r2.g_x + r2.g_w - 1;
					pxy[7] = r2.g_y + r2.g_h - 1;

/*					{
						int16 pxyarray[4];

						pxyarray[0]=r2.g_x;
						pxyarray[1]=r2.g_y;
						pxyarray[2]=pxyarray[0]+r2.g_w;
						pxyarray[3]=pxyarray[1]+r2.g_h;

						vsf_color(global_vdihandle_ecran, 6);
						vr_recfl(global_vdihandle_ecran, pxyarray);
					}*/
/*					evnt_timer(50);*/

					vro_cpyfm(global_vdihandle_ecran,VRO_COPY_MODE,pxy, &mfdb_framebuffer, &Fcm_mfdb_ecran);

				 	vs_clip( global_vdihandle_ecran, CLIP_OFF, 0);
					graf_mouse(M_ON, NULL);

				}
				wind_get(h_win[W_NYANCAT],WF_NEXTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);
			}

			/* On libŠre l'‚cran */
			wind_update(END_UPDATE);
		}
	}


	return;


}

