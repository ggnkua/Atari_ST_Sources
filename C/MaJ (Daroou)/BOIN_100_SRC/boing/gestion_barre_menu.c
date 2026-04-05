/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 27/05/2018 * */
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
		case MN_BOING:
			ouvre_fenetre_boing();
			break;
		case MN_OPTIONS:
			Fcm_ouvre_fenetre(W_OPTIONS, NULL);
			break;
		case MN_RAM:
			Fcm_ouvre_fenetre(W_RAM, NULL);
			break;
	}


	return;


}

