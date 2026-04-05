/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 03/01/2013 MaJ 05/03/2024 * */
/* ***************************** */



#ifndef ___FCM_GESTION_SHADED_C___
#define ___FCM_GESTION_SHADED_C___


void Fcm_gestion_shaded( void )
{
	int16 win_index;


	/* Cette fonction gŠre les actions qui doivent etre */
	/* ex‚cut‚ lorsque le contenu d'une de nos fenetres */
	/* est cach‚ ou r‚-affich‚                          */

	/* Ex: changement de palette, activation du contenu, */
	/* pause du jeu, etc...                              */


	/* Pour l'instant, aucune utilit‚, … impl‚menter le */
	/* jour o— la n‚cessit‚ se fera sentir              */



	/* on prend juste note de l'‚tat pour les redraws & Cie */

	win_index = Fcm_get_indexwindow( buffer_aes[3] );


	if( win_index != FCM_NO_MY_WINDOW )
	{
		switch( buffer_aes[0] )
		{
			case WM_SHADED:
				win_shaded[win_index] = TRUE;
				break;

			case WM_UNSHADED:
				win_shaded[win_index] = FALSE;
				break;
		}
	}


	return;


}


#endif /* ___FCM_GESTION_SHADED_C___ */

