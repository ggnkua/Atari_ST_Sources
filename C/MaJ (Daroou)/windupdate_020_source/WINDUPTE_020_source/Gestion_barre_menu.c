/* **[WindUpdate]*************** */
/* *                           * */
/* * 02/01/2013 MaJ 29/01/2015 * */
/* ***************************** */



void gestion_barre_menu( void )
{

	/* ---------------------------------------------- */
	/* Ici on gŠre les clic sur la barre de Menu      */
	/* sp‚cifique … l'application                     */
	/* ---------------------------------------------- */


	switch( buffer_aes[4] )
	{
		case MN_WINDUPDATE:
			ouvre_fenetre_windupdate();
			break;
	}


	return;


}

