/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 09/08/2003 MaJ 25/02/2024 * */
/* ***************************** */



#ifndef ____FCM_CHARGE_RSC_C___
#define ____FCM_CHARGE_RSC_C___


/*
 * present dans le dialogue POPUP_PREF_LANG du RSC
 *
 * PLANG_ANGLAIS    1 UK (folder name)
 * PLANG_ALLEMAND   2 DE
 * PLANG_FRANCAIS   3 FR
 * PLANG_ESPAGNOL   4 ES
 * PLANG_ITALIEN    5 IT
 * PLANG_SUEDOIS    6 SW
 * PLANG_UKRAINIEN  7 UR
 * PLANG_RUSSE      8 RU
 * PLANG_xxxxx      9 ..
 * etc...
 *
 * Attention: ne pas changer l'ordre des langues
 * ou changer la chaine de code des langues aussi
 *
 * Modifier aussi la fonction Fcm_gestion_preference_langue()
 * qui utilse aussi string_plang[]
 *
 */


#define TAILLE_CHEMIN_RSC  (256 + 16)


int16 Fcm_charge_RSC( void )
{
	char buf_rsc_chemin[ TAILLE_CHEMIN_RSC ];


	FCM_LOG_PRINT1( CRLF"# Fcm_charge_RSC() -> {%s}", RSC_NOM );
	FCM_LOG_PRINT1( "  Fcm_rsc_langage_code : %d", Fcm_rsc_langage_code );

	{
		char rsc_language[4];
		int16 pos_string;
		char string_plang[]="UKDEFRESITSWURRU";


		/* dossier par defaut FR */
		rsc_language[0] = 'F';
		rsc_language[1] = 'R';

		if( Fcm_rsc_langage_code >= PLANG_ANGLAIS  &&  Fcm_rsc_langage_code <= PLANG_RUSSE )
		{
			/* 1->0  2->2  3->4  4->6  etc... */
 			pos_string = (Fcm_rsc_langage_code - 1) * 2;

			rsc_language[0] = string_plang[pos_string];
			rsc_language[1] = string_plang[pos_string+1];
			//FCM_CONSOLE_ADD("RSC language defini", G_YELLOW );
		}

		rsc_language[2] = 0;    /* null */

		//FCM_CONSOLE_ADD2("RSC language %s", rsc_language, G_CYAN );

		/* On construit le chemin + fichier du RSC */
		snprintf( buf_rsc_chemin, TAILLE_CHEMIN_RSC, "%sRSC\\%s\\%s", Fcm_chemin_courant, rsc_language, RSC_NOM );

		//FCM_CONSOLE_ADD2("chemin RSC {%s}", buf_rsc_chemin, G_CYAN );
	}


	FCM_LOG_PRINT1( "  chemin complet {%s}", buf_rsc_chemin );


	if( Fcm_file_exist(buf_rsc_chemin) != TRUE )
	{
		FCM_LOG_PRINT( "  Fichier ressource absent");
		FCM_LOG_PRINT( "  Utilisation du RSC par d‚faut (FR)" );

		/* On construit le chemin + fichier du RSC FR */
		snprintf( buf_rsc_chemin, TAILLE_CHEMIN_RSC, "%sRSC\\FR\\%s", Fcm_chemin_courant, RSC_NOM );
		Fcm_rsc_langage_code = PLANG_FRANCAIS;
	}

	FCM_LOG_PRINT1( "  Nom du ressource … charger: {%s}", buf_rsc_chemin );

	if( rsrc_load(buf_rsc_chemin) )
	{
		FCM_LOG_PRINT( "  RSC charg‚" );
		FCM_LOG_PRINT( "  chargement HEADER RSC" );

		/* on charge l'entete du RSC pour recuperer les adresses */
		/* des Objets Tree, voir Fcm_get_rsrc_gaddr_rtree()      */
		Fcm_bload( buf_rsc_chemin, (char *)Fcm_header_rsc, 0, sizeof(RSHDR) );

		Fcm_get_rsrc_gaddr_rtree();

		if( Fcm_check_rsc_alerte() == 0 )
		{
			return(TRUE);
		}
	}
	else
	{
		FCM_LOG_PRINT( "ERREUR - Fichier ressource introuvable" );

		/* RSC introuvable, on doit quitter */
		form_alert(1, "[3]["PRG_NOM"| |RSC introuvable|RSC not found][  Quitter  ]");
	}


	/* Erreur... */
	return(FALSE);


}


#endif  /* ____FCM_CHARGE_RSC_C___ */

