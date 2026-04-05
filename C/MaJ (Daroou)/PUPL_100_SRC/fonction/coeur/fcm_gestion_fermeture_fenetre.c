/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 02/01/2013 MaJ 06/03/2024 * */
/* ***************************** */



#ifndef ___FCM_GESTION_FERMETURE_FENETRE_C___
#define ___FCM_GESTION_FERMETURE_FENETRE_C___


void Fcm_gestion_fermeture_fenetre( void )
{
	int16  win_index;


	FCM_LOG_PRINT1("* Fcm_gestion_Fermeture_Fenetre() : handle=%d", buffer_aes[3] );

	/* on cherche l'index de la fenetre dans la liste des handles */
	win_index = Fcm_get_indexwindow( buffer_aes[3] );


	FCM_LOG_PRINT1("  win_index=%d", win_index );

	if( win_index == FCM_NO_MY_WINDOW )
	{
		/* Bug AES ? ou du programme ;p */
		FCM_LOG_PRINT("  ERREUR - Ce n'est pas une fenetre … nous ;p");
		FCM_CONSOLE_DEBUG("Fcm_gestion_fermeture_fenetre() : fenetre inconnu");

		return;
	}


	FCM_LOG_PRINT2("  @ table_ft_ferme_fenetre[%d]=%p", win_index, table_ft_ferme_fenetre[win_index] );

	if( table_ft_ferme_fenetre[win_index] != FCM_FONCTION_NON_DEFINI )
	{
		table_ft_ferme_fenetre[win_index]();
	}
	else
	{
		Fcm_fermer_fenetre( win_index );
	}


	return;


}


#endif  /* ___FCM_GESTION_FERMETURE_FENETRE_C___ */

