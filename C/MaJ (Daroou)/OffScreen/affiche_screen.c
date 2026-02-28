/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 18/12/2015 * */
/* ***************************** */






/* prototype */
void affiche_screen( void );




/* Fonction */
void affiche_screen( void )
{




	/* si la fenetre n'est pas ouverte, bah on affiche rien */
	if( h_win[W_OFFSCREEN] == FCM_NO_OPEN_WINDOW )
	{
		return;
	}






    /* ---------------------------- */
	/* fenetre iconifi‚e            */
	/* ---------------------------- */
	if( win_iconified[W_OFFSCREEN]==TRUE )
	{
		GRECT	r1,r2;
		int16	winx,winy,winw,winh;


		/* on cherche les coordonn‚es de travail de la fenˆtre */
		wind_get(h_win[W_OFFSCREEN],WF_WORKXYWH,&winx,&winy,&winw,&winh);

		r1.g_x=winx;
		r1.g_y=winy;
		r1.g_w=winw;
		r1.g_h=winh;


		if( wind_update(BEG_UPDATE) )
		{
			/* C'est bon, on peut redessiner notre fenetre */
			/* ------------------------------------------- */

			wind_get(h_win[W_OFFSCREEN],WF_FIRSTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

			while ( r2.g_w && r2.g_h )
			{
				if( rc_intersect(&r1,&r2) )
				{
					/* clipping */
					pxy[0] = r2.g_x;
					pxy[1] = r2.g_y;
					pxy[2] = r2.g_x + r2.g_w;
					pxy[3] = r2.g_y + r2.g_h;

					graf_mouse(M_OFF, NULL);
					vs_clip( vdihandle, CLIP_ON, pxy );


					if(offscreen_mode!=RB_STAT_OFF_VRAM)
					{

						pxy[0]=r2.g_x-winx+view_iconified_x;
						pxy[1]=r2.g_y-winy+view_iconified_y;
						pxy[2]=pxy[0]+r2.g_w-1;
						pxy[3]=pxy[1]+r2.g_h-1;

						pxy[4]=r2.g_x;
						pxy[5]=r2.g_y;
						pxy[6]=r2.g_x+r2.g_w-1;
						pxy[7]=r2.g_y+r2.g_h-1;

/*						{
							int16 pxyarray[4];

							pxyarray[0]=r2.g_x;
							pxyarray[1]=r2.g_y;
							pxyarray[2]=pxyarray[0]+r2.g_w;
							pxyarray[3]=pxyarray[1]+r2.g_h;

							vsf_color(vdihandle, 6);
							vr_recfl(vdihandle, pxyarray);
							evnt_timer(20);
						}*/
					}
					else
					{
						int16 winx_sprite,winy_sprite,dummy;

						/* on cherche les coordonn‚es de travail de la fenˆtre */
						wind_get(h_win[W_SPRITE_OFFSCREEN],WF_WORKXYWH,&winx_sprite,&winy_sprite,&dummy,&dummy);

						pxy[0]=winx_sprite + (r2.g_x-winx) + view_iconified_x;
						pxy[1]=winy_sprite + (r2.g_y-winy) + view_iconified_y;
						pxy[2]=pxy[0]+r2.g_w-1;
						pxy[3]=pxy[1]+r2.g_h-1;

						pxy[4]=r2.g_x;
						pxy[5]=r2.g_y;
						pxy[6]=r2.g_x+r2.g_w-1;
						pxy[7]=r2.g_y+r2.g_h-1;
					}


					octet_total = octet_total  + (r2.g_w*r2.g_h * (Fcm_screen.nb_plan/8) );
					octet_redraw= octet_redraw + (r2.g_w*r2.g_h * (Fcm_screen.nb_plan/8) );


					vro_cpyfm(vdihandle,3,pxy,  &mfdb_offscreen, &Fcm_mfdb_ecran);

				 	vs_clip( vdihandle, CLIP_OFF, 0);
					graf_mouse(M_ON, NULL);

				}

				wind_get(h_win[W_OFFSCREEN],WF_NEXTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

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
		wind_get(h_win[W_OFFSCREEN],WF_WORKXYWH,&winx,&winy,&dummy,&dummy);


		if( wind_update(BEG_UPDATE) )
		{

			/* C'est bon, on peut redessiner notre fenetre */
			/* ------------------------------------------- */

			wind_get(h_win[W_OFFSCREEN],WF_FIRSTXYWH,&zone_win.g_x,&zone_win.g_y,&zone_win.g_w,&zone_win.g_h);

			while ( zone_win.g_w && zone_win.g_h )
			{
				{
					GRECT zone_redraw;

					zone_redraw.g_x = winx;
					zone_redraw.g_y = winy;
					zone_redraw.g_w = SCREEN_WIDTH;
					zone_redraw.g_h = SCREEN_HEIGHT;


					if ( rc_intersect(&zone_win,&zone_redraw) )
					{
						/* clipping */
						pxy[0] = zone_redraw.g_x;
						pxy[1] = zone_redraw.g_y;
						pxy[2] = zone_redraw.g_x + zone_redraw.g_w-1;
						pxy[3] = zone_redraw.g_y + zone_redraw.g_h-1;

						graf_mouse(M_OFF, NULL);
						vs_clip( vdihandle, CLIP_ON, pxy );


						if( offscreen_mode!=RB_STAT_OFF_VRAM )
						{
							pxy[0]=zone_redraw.g_x-winx;
							pxy[1]=zone_redraw.g_y-winy;
							pxy[2]=pxy[0]+zone_redraw.g_w-1;
							pxy[3]=pxy[1]+zone_redraw.g_h-1;

							pxy[4]=zone_redraw.g_x;
							pxy[5]=zone_redraw.g_y;
							pxy[6]=zone_redraw.g_x+zone_redraw.g_w-1;
							pxy[7]=zone_redraw.g_y+zone_redraw.g_h-1;
						}
						else
						{
							int16 winx_sprite,winy_sprite;

							/* on cherche les coordonn‚es de travail de la fenˆtre */
							wind_get(h_win[W_SPRITE_OFFSCREEN],WF_WORKXYWH,&winx_sprite,&winy_sprite,&dummy,&dummy);

							pxy[0]=winx_sprite + zone_redraw.g_x-winx;
							pxy[1]=winy_sprite + zone_redraw.g_y-winy;
							pxy[2]=pxy[0]+zone_redraw.g_w-1;
							pxy[3]=pxy[1]+zone_redraw.g_h-1;

							pxy[4]=zone_redraw.g_x;
							pxy[5]=zone_redraw.g_y;
							pxy[6]=zone_redraw.g_x+zone_redraw.g_w-1;
							pxy[7]=zone_redraw.g_y+zone_redraw.g_h-1;
						}

/*						{
							int16 pxyarray[4];

							pxyarray[0]=zone_redraw.g_x;
							pxyarray[1]=zone_redraw.g_y;
							pxyarray[2]=pxyarray[0]+zone_redraw.g_w-1;
							pxyarray[3]=pxyarray[1]+zone_redraw.g_h-1;

							vsf_color(vdihandle, 6);
							vr_recfl(vdihandle, pxyarray);
evnt_timer(20);
						}*/


						octet_total = octet_total  + (zone_redraw.g_w*zone_redraw.g_h * (Fcm_screen.nb_plan/8) );
						octet_redraw= octet_redraw + (zone_redraw.g_w*zone_redraw.g_h * (Fcm_screen.nb_plan/8) );


						vro_cpyfm(vdihandle,3,pxy,  &mfdb_offscreen, &Fcm_mfdb_ecran);

					 	vs_clip( vdihandle, CLIP_OFF, 0);
						graf_mouse(M_ON, NULL);

					}
				}

				wind_get(h_win[W_OFFSCREEN],WF_NEXTXYWH,&zone_win.g_x,&zone_win.g_y,&zone_win.g_w,&zone_win.g_h);

			}


			/* On libŠre l'‚cran */
			wind_update(END_UPDATE);
		}

	}


	return;


}

