/* **[Pupul]******************** */
/* *                           * */
/* * 16/08/2014 MaJ 07/11/2023 * */
/* ***************************** */



/* Fonction */
void gestion_barre_menu( void )
{

	/* ----------------------------------------- */
	/* Ici on gŠre les clic sur la barre de Menu */
	/* sp‚cifique … l'application                */
	/* ----------------------------------------- */


	switch( buffer_aes[4] )
	{
		case MN_PUPUL:
			ouvre_fenetre_pupul();
			break;

		case MN_OPTIONS:
			Fcm_ouvre_fenetre(W_OPTIONS, NULL);
			break;

		case MN_MOD_OPTIONS:
			Fcm_ouvre_fenetre(W_MODLDG, NULL);
			break;

	}


	return;


}

