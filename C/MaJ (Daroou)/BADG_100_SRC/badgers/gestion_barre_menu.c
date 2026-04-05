/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 13/11/2023 * */
/* ***************************** */




void gestion_barre_menu( void )
{

	/* ----------------------------------------- */
	/* Ici on gŠre les clic sur la barre de Menu */
	/* sp‚cifique … l'application                */
	/* ----------------------------------------- */


	switch( buffer_aes[4] )
	{
		case MN_BADGERS:
			ouvre_fenetre_badgers();
			break;

		case MN_OPTIONS:
			Fcm_ouvre_fenetre(W_OPTIONS, NULL);
			break;
	}


	return;


}

