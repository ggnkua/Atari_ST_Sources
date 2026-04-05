/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 02/01/2013 MaJ 06/03/2024 * */
/* ***************************** */



#ifndef ___FCM_GESTION_BARRE_MENU_C___
#define ___FCM_GESTION_BARRE_MENU_C___


void Fcm_gestion_barre_menu( void )
{
	/* ---------------------------------------------- */
	/* Ici on gäre les clic sur la barre de Menu,     */
	/* on intercepte les clics sur les menus          */
	/* communs, sinon on lance la fonction de gestion */
	/* de l'application                               */
	/* ---------------------------------------------- */

	FCM_LOG_PRINT1("# Fcm_gestion_barre_menu: buffer_aes[4]=%d", buffer_aes[4] );

	/* On remet le MENU dans son Çtat d'origine */
	Fcm_menu_tnormal( BARRE_MENU, buffer_aes[3], 1 );


	switch( buffer_aes[4] )
	{
		/* Interception des options du MENU qui sont communes */
		/* Ö toutes les applications                          */
		case MN_QUITTER:
			Fcm_gestion_fermeture_programme();
			break;

		case MN_INFO_PRG:
			Fcm_ouvre_fenetre(W_INFO_PRG, NULL);
			break;

		case MN_PREFERENCE:
			Fcm_ouvre_fenetre(W_OPTION_PREFERENCE, NULL);
			break;

		case MN_CONSOLE:
			Fcm_console_ouvre_fenetre();
			break;

		case MN_SAUVER_CONFIG:
			Fcm_sauver_config(TRUE);
			break;


		default:
			/* On redirige vers la fonction qui gäre les options du */
			/* MENU spÇcifique Ö l'application                      */

			gestion_barre_menu();
			break;
	}


	return;

}


#endif /* ___FCM_GESTION_BARRE_MENU_C___ */

