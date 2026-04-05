/* *[Console]******************* */
/* *                           * */
/* * 01/01/2024 MaJ 12/02/2024 * */
/* ***************************** */

void Fcm_console_gestion_sized( void )
{
	int16 winx,winy,winw,winh;
	int16 oldwinx,oldwiny,oldwinw,oldwinh;
	int16 oldwinx2;
	int16 oldwiny2;
	int16 winx2;
	int16 winy2;


	/* dans buffer_aes[4-7] il y a les nouvelles dimensions de la fenetre */
	/* on doit les verifier avant de les valider                          */


	/* Support des widget Size de MyAES, dans chaque coin     */
	/* Si c'est le widget standard AES, x et y ne change pas, */
	/* seul la largeur et hauteur de la fenetre change        */
	/* Si x ou y change, c'est les widget de MyAES            */
	

	wind_get(h_win[W_CONSOLE],WF_WORKXYWH,&oldwinx,&oldwiny,&oldwinw,&oldwinh);


	/* on demande … l'AES de nous donner la zone de travail equivalente de la nouvelle position */
	wind_calc( WC_WORK, win_widgets[W_CONSOLE], buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7], &winx, &winy, &winw, &winh );


	oldwinx2 = oldwinx + oldwinw;
	oldwiny2 = oldwiny + oldwinh;
	winx2 = winx + winw;
	winy2 = winy + winh;

/*
	*** Fenetre position actuelle ***

			oldwinx,oldwiny
						  +---------------------+
						  |                     |
						  |                     |
						  |                     |
						  |                     |
						  +---------------------+
												oldwinx2,oldwiny2

	*** Fenetre nouvelle position ***

				winx,winy
						  +---------------------+
						  |                     |
						  |                     |
						  |                     |
						  |                     |
						  +---------------------+
												winx2,winy2
*/




/*
{
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, "----"CRLF );
	Fcm_console_add( Fcm_console_texte, G_LBLACK );
}

{
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, "oldwinx=%d oldwiny=%d oldwinw=%d oldwinh=%d oldwinx2=%d oldwiny2=%d"CRLF, oldwinx,oldwiny,oldwinw,oldwinh, oldwinx+oldwinw, oldwiny+oldwinh );
	Fcm_console_add( Fcm_console_texte, G_WHITE );
}
{
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, "winx=%d winy=%d winw=%d winh=%d winx2=%d winy2=%d"CRLF, winx,winy,winw,winh, winx+winw, winy+winh );
	Fcm_console_add( Fcm_console_texte, G_GREEN );
}
*/




	/* on verifie les dimensions */
	winw = MIN( winw, Fcm_struct_console_global.zone_w_max );
	winw = MAX( winw, FCM_CONSOLE_LARGEUR_MINI );

	/* pour que la largeur soit un multiple de la largeur d'une lettre */
	winw = winw / Fcm_struct_console_global.char_cellw;
	winw = winw * Fcm_struct_console_global.char_cellw;


	winh = MIN( winh, Fcm_struct_console_global.zone_h_max );
	winh = MAX( winh, FCM_CONSOLE_HAUTEUR_MINI );

	/* pour que la hauteur soit un multiple de la hauteur d'une lettre */
	winh = winh / Fcm_struct_console_global.char_cellh;
	winh = winh * Fcm_struct_console_global.char_cellh;


	/* Sized AES standard, x et y sont constant */
	if( winx != oldwinx  ||  winy != oldwiny )
	{
		/* --- Widget sized MyAES --- */

/*{
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, "oldwinx2=%d winx2=%d oldwiny2=%d winy2=%d"CRLF, oldwinx2,winx2,oldwiny2,winy2 );
	Fcm_console_add( Fcm_console_texte, G_CYAN );
}*/

		/* coin bas-gauche */
		if( oldwiny==winy && oldwinx2==winx2 )
		{
			winx = oldwinx2 - winw;
/*{
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, "coin bas-gauche new winx=%d"CRLF, winx );
	Fcm_console_add( Fcm_console_texte, G_GREEN );
}*/
		}


		/* coin haut-droit */
		if( oldwinx==winx && oldwiny2==winy2 )
		{
			winy = oldwiny2 - winh;

/*{
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, "coin haut-droit new winy=%d"CRLF, winy );
	Fcm_console_add( Fcm_console_texte, G_GREEN );
}*/
		}


		/* coin haut-gauche */
		if( oldwinx2==winx2 && oldwiny2==winy2 )
		{
			winx = oldwinx2 - winw;
			winy = oldwiny2 - winh;
/*{
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, "coin haut-gauche new winx=%d  new winy=%d"CRLF, winx, winy );
	Fcm_console_add( Fcm_console_texte, G_GREEN );
}*/
		}



		winx = MAX(0, winx);
		winx = (winx / 16) * 16;  /* x multiple de 16 */

		winw = oldwinx2 - winx;

	}

/*{
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, "winx=%d winy=%d winw=%d winh=%d winx2=%d winy2=%d"CRLF, winx,winy,winw,winh, winx+winw, winy+winh );
	Fcm_console_add( Fcm_console_texte, G_YELLOW );
}*/


/*
{
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, "----"CRLF );
	Fcm_console_add( Fcm_console_texte, G_LBLACK );
}
{
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, "oldwinx=%d oldwiny=%d oldwinw=%d oldwinh=%d"CRLF, oldwinx,oldwiny,oldwinw,oldwinh );
	Fcm_console_add( Fcm_console_texte, G_WHITE );
}
{
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, "aes[4]=%d aes[5]=%d aes[6]=%d aes[7]=%d"CRLF, oldaes4,oldaes5,oldaes6,oldaes7 );
	Fcm_console_add( Fcm_console_texte, G_LMAGENTA );
}
{
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, "winw=%d  Fcm_struct_console_global.zone_w_max=%d"CRLF, winw, Fcm_struct_console_global.zone_w_max );
	Fcm_console_add( Fcm_console_texte, G_CYAN );
}
{
	snprintf( Fcm_console_texte, FCM_CONSOLE_TEXTE_BUFLEN, "winw=%d  Fcm_struct_console_global.zone_w_max=%d"CRLF, winw, Fcm_struct_console_global.zone_w_max );
	Fcm_console_add( Fcm_console_texte, G_GREEN );
}
*/

	/* on reconvertit en zone de fenetre externe */
	wind_calc( WC_BORDER, win_widgets[W_CONSOLE], winx, winy, winw, winh, &buffer_aes[4], &buffer_aes[5], &buffer_aes[6], &buffer_aes[7] );

	/* et on applique les changements */
	wind_set(buffer_aes[3],WF_CURRXYWH,buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);

	win_posxywh[W_CONSOLE][0]=buffer_aes[4];
	win_posxywh[W_CONSOLE][1]=buffer_aes[5];
	win_posxywh[W_CONSOLE][2]=buffer_aes[6];
	win_posxywh[W_CONSOLE][3]=buffer_aes[7];

	Fcm_struct_console_global.nbligne_visible  = winh / Fcm_struct_console_global.char_cellh;
	Fcm_struct_console_global.nblettre_visible = winw / Fcm_struct_console_global.char_cellw;


	Fcm_struct_console_global.ligne_start = MIN( (FCM_CONSOLE_MAXLIGNE-Fcm_struct_console_global.nbligne_visible) , Fcm_struct_console_global.ligne_start );



	/* mise a jour des slider H et V */
	Fcm_console_set_slider();


	return;


}

