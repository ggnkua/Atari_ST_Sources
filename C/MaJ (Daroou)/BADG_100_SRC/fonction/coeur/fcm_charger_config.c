/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 20/01/2013 MaJ 01/03/2024 * */
/* ***************************** */



int16 Fcm_charger_config( void )
{
	char  *pt_fichier_config = NULL;
	int32  taille_fichier_config = 0L;


	FCM_LOG_PRINT( CRLF"# Fcm_charger_config()" );


	/*----------------------------------------------------------*/
	/* On r‚cupŠre le chemin d‚fini par HOME                    */
	/*----------------------------------------------------------*/
	Fcm_chemin_config[0] = 0;
	Fcm_get_chemin_home( Fcm_chemin_config, (FCM_TAILLE_CHEMIN_CONFIG - strlen(INF_NOM)) );
	strcat( Fcm_chemin_config, INF_NOM );

	FCM_LOG_PRINT(CRLF"END Fcm_get_chemin_home()");

	FCM_LOG_PRINT1(CRLF"- Fichier Config: {%s}",Fcm_chemin_config );


	/*----------------------------------------------------------*/
	/* Chargement du fichier de config                          */
	/*----------------------------------------------------------*/
	taille_fichier_config = Fcm_file_size(Fcm_chemin_config);


	FCM_LOG_PRINT1(CRLF"- Taille Fichier Config: {%ld} (negatif=erreur)",taille_fichier_config);


	if( taille_fichier_config <= 0 )
	{
		FCM_LOG_PRINT("Info : fichier de config absent (ou defectueux)");
		FCM_CONSOLE_ADD("Info : fichier de config absent (ou defectueux)", G_WHITE);

		/* on ouvre la fenetre info par d‚faut */
		h_win[W_INFO_PRG] = FCM_GO_OPEN_WINDOW;
	}
	else
	{
		/* on reserve la quantit‚ de RAM n‚cessaire + 1 octet pour le Null byte de fin */
		pt_fichier_config = (char *)Fcm_reserve_ram( (taille_fichier_config + 1), MX_PREFTTRAM );

		if( pt_fichier_config == (char *)0L )
		{
			FCM_LOG_PRINT1( CRLF"ERREUR reserve RAM -> pt_fichier_config=%p", pt_fichier_config);
			FCM_CONSOLE_DEBUG("Fcm_charger_config(): Pas de RAM disponible pour le fichier de configuration");

			return(FALSE);
		}



		/* Chargement du fichier de configuration */
		{
			int32 octet_charger;


			/* Chargement du fichier en mode binaire */
			octet_charger = Fcm_bload( Fcm_chemin_config, pt_fichier_config, 0L, taille_fichier_config );

			if( octet_charger != taille_fichier_config )
			{
				FCM_CONSOLE_DEBUG("Fcm_charger_config(): Chargement fichier de configuration incomplet");
			}

			/* L'entete fait dans les 150 octets, pas besoin de continuer */
			if( octet_charger < 150 ) return(FALSE);


			taille_fichier_config = octet_charger;
			pt_fichier_config[ (octet_charger-1) ] = 0; /* NULL byte de fin de buffer */
		}


		/* --------------------------------------------------------- */
		/* On r‚cupere tous les TAG commun … toutes les applications */
		/* --------------------------------------------------------- */
		Fcm_get_tag_config_generale( pt_fichier_config );


		/* --------------------------------------------------------- */
		/* Ici , tous les TAG propre … l'application                 */
		/* --------------------------------------------------------- */
		get_tag_config( pt_fichier_config );


		Fcm_libere_ram( (uint32)pt_fichier_config );
	}


	FCM_LOG_PRINT(CRLF"# FIN Fcm_charger_config()");


	return(TRUE);


}

