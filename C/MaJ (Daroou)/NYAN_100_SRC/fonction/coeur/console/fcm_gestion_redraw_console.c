/* *[Console]******************* */
/* *                           * */
/* * 26/02/2024 MaJ 27/02/2024 * */
/* ***************************** */



#ifndef __FCM_GESTION_REDRAW_CONSOLE_C__
#define __FCM_GESTION_REDRAW_CONSOLE_C__



/* ATTENTION : pas de message Console :) */


void Fcm_gestion_redraw_console(void)
{
	GRECT	r1,r2;


//FCM_LOG_PRINT(CRLF"* Fcm_gestion_redraw_console");

	/* coordonnee de la zone a redessinner */
	r1.g_x = console_aes[4];
	r1.g_y = console_aes[5];
	r1.g_w = console_aes[6];
	r1.g_h = console_aes[7];

	if( wind_update(BEG_UPDATE) )  
	{
		//FCM_LOG_PRINT4(" zone de redraw demande par l'AES : r1.g_x=%d r1.g_y=%d r1.g_w=%d r1.g_h=%d", r1.g_x,r1.g_y,r1.g_w,r1.g_h );

		/* C'est bon, on peut redessiner notre fenetre... */
		wind_get( h_win[W_CONSOLE],WF_FIRSTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

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

					Fcm_console_redraw( &r2, W_CONSOLE );

					vs_clip( vdihandle, CLIP_OFF, 0);
				}
			}
			wind_get(h_win[W_CONSOLE],WF_NEXTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);
		}

		graf_mouse(M_ON, NULL);

		/* On libäre l'Çcran */
		wind_update(END_UPDATE);
	}


//FCM_LOG_PRINT( " fin Fcm_gestion_redraw_console"CRLF);

	return;


}


#endif   /*    __FCM_GESTION_REDRAW_CONSOLE_C__   */

