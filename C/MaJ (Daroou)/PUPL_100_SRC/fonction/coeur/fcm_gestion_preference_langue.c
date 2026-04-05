/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 25/05/2015 MaJ 25/02/2024 * */
/* ***************************** */



#define CHEMIN_RSC_LANGUE (FCM_TAILLE_CHEMIN + (20) )  /* "RSC\FR\12345678.RSC" */


void Fcm_gestion_preference_langue( void )
{
	char    my_buffer[ CHEMIN_RSC_LANGUE ];


	FCM_LOG_PRINT(CRLF"# Fcm_gestion_preference_langue()");
	FCM_LOG_PRINT1(" - Fcm_rsc_langage_code=%d", Fcm_rsc_langage_code);


	/* on v‚rifie que le buffer est assez grand */
	if(  (strlen(Fcm_chemin_courant) + strlen("RSC\\FR\\") + strlen(RSC_NOM))  >=  CHEMIN_RSC_LANGUE )
	{
		FCM_LOG_PRINT1("ERREUR Chemin RSC plus long que le buffer (%d)"CRLF, CHEMIN_RSC_LANGUE );
		FCM_CONSOLE_DEBUG("Fcm_gestion_preference_langue() : buffer trop petit pour le chemin du RSC");

		form_alert(1, "[3]["PRG_NOM"|Chemin RSC trop long|pour le buffer][  Quitter  ]" );
		return;
	}


	/* On cache toutes les STRING des langues */
	{
		int16 idx_champ;

		for( idx_champ=PLANG_ANGLAIS; idx_champ <= PLANG_RUSSE; idx_champ++ )
		{
			SET_BIT_W( Fcm_adr_RTREE[POPUP_PREF_LANG][idx_champ].ob_flags, OF_HIDETREE, 1);
		}
	}


	FCM_LOG_PRINT("Recherche langue disponible");

	/* On recherche toutes les langues disponibles avec l'application */
	{
		char rsc_language[4];
		char string_plang[]="UKDEFRESITSWURRU";
		int16 pos_string;
		int16 index_langue = PLANG_ANGLAIS;


		rsc_language[2] = 0;    /* null */

		/* 8 langues a rechercher, 2 lettres par code langue */
		for( pos_string=0; pos_string < (8*2);  )
		{
			rsc_language[0] = string_plang[pos_string];
			rsc_language[1] = string_plang[pos_string + 1];

//FCM_CONSOLE_ADD2("Recherche RSC language %s", rsc_language, G_CYAN );

			sprintf( my_buffer, "%sRSC\\%s\\"RSC_NOM, Fcm_chemin_courant, rsc_language );

			if( Fcm_file_exist(my_buffer) == TRUE )
			{
				SET_BIT_W( Fcm_adr_RTREE[POPUP_PREF_LANG][index_langue].ob_flags, OF_HIDETREE, 0);

//FCM_CONSOLE_ADD2("Fcm_gestion_preference_langue() : langue %s presente", rsc_language, G_GREEN);
				FCM_LOG_PRINT1("  Fichier ressource %s present", rsc_language);
			}

			index_langue++;
			pos_string = pos_string + 2;
		}
	}



	{
		int16  objet;


		objet = Fcm_gestion_pop_up( DL_OPT_PREF, PREF_POPUP_LANG, POPUP_PREF_LANG );

		/* ---------------------------------------------- */
		/* Mise … jour Langue dans le dialogue preference */
		/* ---------------------------------------------- */
		if( objet != -1   &&   objet != Fcm_rsc_langage_code )
		{
			int16 old_Fcm_rsc_langage_code;


			old_Fcm_rsc_langage_code = Fcm_rsc_langage_code;
			Fcm_rsc_langage_code = objet;

			Fcm_my_menu_bar( BARRE_MENU, MENU_REMOVE );
			Fcm_libere_RSC();

			if( Fcm_charge_RSC() != TRUE )
			{
				/* erreur, on recharge l'ancien RSC */
				form_alert(1, "[2]["PRG_NOM"|Erreur chargement RSC|Error loading RSC][    Ok    ]" );

				Fcm_rsc_langage_code = old_Fcm_rsc_langage_code;

				if( Fcm_charge_RSC() != TRUE )
				{
					/* on arrive pas recharger le rsc original */
					form_alert(1, "[3]["PRG_NOM"|Impossible de recharger|le RSC original.|Unable loading original RSC.][  Quitter  ]" );

					Fcm_gestion_fermeture_programme(); /* AP_TERM */
					return;
				}
			}

			Fcm_set_config_generale();
			set_config();

			Fcm_init_rsc_info();
			Fcm_rescale_fenetre_info();
			Fcm_rescale_fenetre_preference();
			Fcm_rescale_bar_menu();

			Fcm_my_menu_bar( BARRE_MENU, MENU_INSTALL );


			if( Fcm_ft_rsc_init != FCM_FONCTION_NON_DEFINI )
			{
				/* R‚-initialisation des champs des dialogues de l'appli */
				/* qui ne sont pas initialisé avec set_config()          */
				Fcm_ft_rsc_init();
			}

			/* on ferme et ré-ouvre les fenetres avec le nouveau RSC */
			Fcm_fermer_fenetre( FCM_CLOSE_ALL_WIN );
			Fcm_ouvre_fenetre_start();
		}
	}


	return;


}


#undef CHEMIN_RSC_LANGUE

