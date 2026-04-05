/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 06/05/2018 MaJ 25/02/2024 * */
/* ***************************** */



#define ICONE_FOND  (0)
#define ICONE_OBJET (1)




void Fcm_redraw_fenetre( const GRECT *rd , const int16 index_tab_win )
{
	OBJECT	*adr_formulaire;
	int16	winx,winy,winw,winh;


	wind_get(h_win[index_tab_win],WF_WORKXYWH,&winx,&winy,&winw,&winh);

	FCM_LOG_PRINT5("* Fcm_redraw_fenetre idx=%d  x=%d y=%d w=%d h=%d", index_tab_win, winx, winy, rd->g_w, rd->g_h);

	if( win_iconified[index_tab_win] != TRUE )
	{
		adr_formulaire = Fcm_adr_RTREE[ win_rsc[index_tab_win] ];
	}
	else
	{
		adr_formulaire = Fcm_adr_RTREE[ win_rsc_iconify[index_tab_win] ];

		/* la taille de la fenetre en mode iconfie peut varier */
		/* donc on s'adapte a la taille de la fenetre          */
		adr_formulaire[ICONE_FOND].ob_width  = winw;
		adr_formulaire[ICONE_FOND].ob_height = winh;

		/* on centre l'icone */
		adr_formulaire[ICONE_OBJET].ob_x = (winw-adr_formulaire[ICONE_OBJET].ob_width) / 2;
		adr_formulaire[ICONE_OBJET].ob_y = (winh-adr_formulaire[ICONE_OBJET].ob_height) / 2;
	}


	/* La position de l'objet ne tient pas compte du cadre ou */
	/* des effets comme shadow On doit la corriger nous meme  */
	/* A voir ce que ca donne en mode iconifié ... */
	if( adr_formulaire->ob_spec.obspec.framesize < 0 )
	{
		winx = winx + ABS( adr_formulaire->ob_spec.obspec.framesize );
		winy = winy + ABS( adr_formulaire->ob_spec.obspec.framesize );
	}


	/* on cale le formulaire sur ces coordonn‚es */
	adr_formulaire->ob_x = winx;
	adr_formulaire->ob_y = winy;

	/* on demande … l'AES de tracer le formulaire */
	objc_draw( adr_formulaire, 0, 4, rd->g_x, rd->g_y, rd->g_w, rd->g_h );


	return;


}


#undef ICONE_FOND
#undef ICONE_OBJET

