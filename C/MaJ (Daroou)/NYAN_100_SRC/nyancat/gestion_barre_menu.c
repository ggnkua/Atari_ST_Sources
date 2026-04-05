/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 24/05/2018 * */
/* ***************************** */




/* Fonction */
void gestion_barre_menu( void )
{

	/* ---------------------------------------------- */
	/* Ici on gŠre les clic sur la barre de Menu      */
	/* sp‚cifique … l'application                     */
	/* ---------------------------------------------- */


	switch( buffer_aes[4] )
	{
		case MN_NYANCAT:
			ouvre_fenetre_nyancat();
			break;

		case MN_OPTIONS:
			Fcm_ouvre_fenetre(W_OPTIONS, NULL);
			break;
	}


	return;


}

