/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 20/01/2013 MaJ 26/08/2025 * */
/* ***************************** */



#ifndef __FCM_SAUVER_CONFIG_C__
#define __FCM_SAUVER_CONFIG_C__



void Fcm_sauver_config( const int16 force_save )
{
	int16	handle_fichier;


	FCM_LOG_PRINT1("# Fcm_sauver_config(%d)", force_save);
	FCM_LOG_PRINT1("  Fcm_save_option_auto=%d", Fcm_save_option_auto);


	if( force_save == FALSE   &&   Fcm_save_option_auto == FALSE )
	{
FCM_LOG_PRINT("  - Sauvegarde dÇsactivÇ");
//FCM_CONSOLE_DEBUG("Fcm_sauver_config() : sauver desactive");

		return;
	}


	FCM_LOG_PRINT1("  Sauvegarde sur: %s", Fcm_chemin_config);

	handle_fichier = Fcreate( Fcm_chemin_config, 0 );

	if( handle_fichier > 0 )
	{
		Fcm_fprint( handle_fichier, PRG_FULL_NOM" "PRG_VERSION""CRLF"(P) Renaissance"CRLF );
		Fcm_fprint( handle_fichier, "");

		/* ----------------------------------- */
		/* Tout ce qui est commum a toute les  */
		/* applications est Sauver ici         */
		/* ----------------------------------- */
		Fcm_save_config_generale(handle_fichier);


		/* ---------------------------------------------- */
		/* paramätre de config propre Ö cette application */
		/* ---------------------------------------------- */
		save_config(handle_fichier);


		/* ---------------------------------------------- */
		/* Bas de page du fichier de Configuration        */
		/* ---------------------------------------------- */
		Fcm_fprint( handle_fichier, "");

		{
			int16 reponse;


			reponse = Fclose( handle_fichier );

			if( reponse < 0 )
			{
				FCM_LOG_PRINT1("Erreur Fclose() err=%d", reponse);
				FCM_CONSOLE_DEBUG1("Fcm_sauver_config() : erreur Fclose() (%d)", reponse);

				Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_ERR_SAVE_INF, 0 );
			}
		}
	}
	else
	{
		FCM_LOG_PRINT1("Erreur Fcreate() (%d)", handle_fichier);
		FCM_CONSOLE_DEBUG1("Fcm_sauver_config() : erreur Fcreate() (%d)", handle_fichier);

		Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_ERR_SAVE_INF, 0 );
	}


	return;


}


#endif  /*  __FCM_SAUVER_CONFIG_C__  */

