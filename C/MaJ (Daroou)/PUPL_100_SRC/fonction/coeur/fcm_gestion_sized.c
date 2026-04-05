/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 03/01/2024 MaJ 06/03/2024 * */
/* ***************************** */



/*
 * fonction en version beta , premiere version...
 * seul la console est sized pour le moment...
 * A voir quand moult fenetre seront sized comment
 * gérer le schmilblick...
 *
 */


#ifndef ___FCM_GESTION_SIZED_C___
#define ___FCM_GESTION_SIZED_C___


void Fcm_gestion_sized(void)
{
	int16 index_win;


	FCM_LOG_PRINT4(CRLF"Fcm_gestion_sized buffer_aes[4]=%d buffer_aes[5]=%d buffer_aes[6]=%d buffer_aes[7]=%d : "CRLF, buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7] );

	/* buffer_aes[3] est l'handle AES de la fenetre    */
	/* on cherche son index dans notre liste (tableau) */
	index_win = Fcm_get_indexwindow( buffer_aes[3] );

	/* on verifie si c'est une de nos fenetres par s‚curit‚ */
	if( index_win != FCM_NO_MY_WINDOW )
	{
		FCM_LOG_PRINT("# Appel fonction dynamique gestion sized");
		FCM_LOG_PRINT2("  -> index_win=%d, adresse fonction=%08lx"CRLF, index_win, (int32)table_ft_gestion_sized[index_win] );

		if( table_ft_gestion_sized[index_win] != FCM_FONCTION_NON_DEFINI )
		{
			FCM_LOG_PRINT(CRLF" -> Appel fonction dynamique gestion sized");

			table_ft_gestion_sized[index_win]();
		}
		else
		{
			FCM_LOG_PRINT("# ERREUR !!! pas de fonction defini");
			FCM_CONSOLE_DEBUG("Fcm_gestion_sized() : pas de fonction defini");
		}
	}
	else
	{
		FCM_LOG_PRINT(" ERREUR !!! index win");
		FCM_CONSOLE_DEBUG("Fcm_gestion_sized() : erreur index win");
	}


	return;


}


#endif  /* ___FCM_GESTION_SIZED_C___ */

