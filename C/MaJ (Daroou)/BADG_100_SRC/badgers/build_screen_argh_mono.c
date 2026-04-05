/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 13/11/2023 * */
/* ***************************** */





/* prototype */
void build_screen_argh_mono( void );





/* Fonction */
void build_screen_argh_mono( void )
{

	static int16 argh_index=0;





	/* R‚-initialisation de l'animation */
	if( build_screen_restart==TRUE )
	{
		argh_index=0;
		build_screen_restart=FALSE;
	}



	/* ------------------------------------- */
	/* Affichage ARGH dans l'‚cran offscreen */
	/* ------------------------------------- */
//	vro_cpyfm(global_vdihandle_framebuffer,3,pxy_screen, &mfdb_argh[argh_index], &mfdb_framebuffer );
	vrt_cpyfm(global_vdihandle_framebuffer, VRT_COPY_MODE, pxy_screen, &mfdb_argh[argh_index], &mfdb_framebuffer, couleur_vrt_copy );



	/* ------------------------------------- */
	/* Animation des ‚crans                  */
	/* ------------------------------------- */
	argh_index++;

	if( argh_index==NB_ARGH )
	{
		build_screen_restart=TRUE;
		pf_build_screen = build_screen_snake;
	}



	/* ------------------------------------- */
	/* affichage … l'‚cran                   */
	/* ------------------------------------- */
	Fcm_liste_refresh_ecran[0].g_x=0;
	Fcm_liste_refresh_ecran[0].g_y=0;
	Fcm_liste_refresh_ecran[0].g_w=SCREEN_WIDTH;
	Fcm_liste_refresh_ecran[0].g_h=SCREEN_HEIGHT;
	Fcm_nb_liste_refresh_ecran=1;


	return;


}


