/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 15/01/2013 MaJ 02/03/2024 * */
/* ***************************** */




int32 Fcm_init_coeur_application( void )
{

	graf_mouse( ARROW, NULL );

	/*
	 * ATTENTION :
	 * Aucune sortie de LOG ne peut etre effectue
	 * avant l'init de l'environnement
	 *
	 */
	Fcm_init_environnement();




	FCM_LOG_PRINT("****************************************" );
	FCM_LOG_PRINT("***** Fcm_init_coeur_application() *****" );
	FCM_LOG_PRINT("****************************************" );


	FCM_LOG_PRINT1(CRLF">> Coeur application version: %s <<"CRLF, FCM_COEUR_VERSION );

	FCM_LOG_PRINT3("GEMLIB : %d.%d.%d", __GEMLIB_MAJOR__, __GEMLIB_MINOR__, __GEMLIB_REVISION__ );
	FCM_LOG_PRINT3("GCC    : %d.%d.%d", __GNUC__, __GNUC_MINOR__, __GNUC_PATCHLEVEL__ );

#ifdef BUILDLIBCMINI
	FCM_LOG_PRINT("LibC   : LibCmini");
#else
	FCM_LOG_PRINT("LibC   : MintLib");
#endif


/* Actuellement, la version debug est compilé que pour 68000 ou Coldfire */
#ifdef CPU_020_060
	FCM_LOG_PRINT("CPU    : 20-60");
#elif  CPU_CFV4E
	FCM_LOG_PRINT("CPU    : ColdFire V4");
#elif  CPU_68K
	FCM_LOG_PRINT("CPU    : 68000");
#else
	FCM_LOG_PRINT("CPU    : Erreur");
#endif


	#ifndef FCM_W_INDEX_APP_START_APPLI_UPDATED
		#error "modifier les index de fenetre en mode dynamique !"
	#endif

/*
	typedef struct
	{
		int16 magic_os;
		int32 tsize;
		int32 dsize;
		int32 bsize;
		int32 ssize;
		int32 res1;
		int32 flags;
		int32 dummy;
	} PH;

	{
		PH header;


		Fcm_bload( "BOIN_68K.PRG", (char *)&header, 0, 28 );

	FCM_LOG_PRINT("LibCmini");
	FCM_LOG_PRINT1("magic_os:%x", header.magic_os);
	FCM_LOG_PRINT1("tsize:%lx", header.tsize);
	FCM_LOG_PRINT1("dsize:%lx", header.dsize);
	FCM_LOG_PRINT1("bsize:%lx", header.bsize);
	FCM_LOG_PRINT1("ssize:%lx", header.ssize);
	FCM_LOG_PRINT1("res1:%lx", header.res1);
	FCM_LOG_PRINT1("flags:%lx", header.flags);


		Fcm_bload( "BOIN_MNT.PRG", (char *)&header, 0, 28 );

	FCM_LOG_PRINT("MINT");
	FCM_LOG_PRINT1("magic_os:%x", header.magic_os);
	FCM_LOG_PRINT1("tsize:%lx", header.tsize);
	FCM_LOG_PRINT1("dsize:%lx", header.dsize);
	FCM_LOG_PRINT1("bsize:%lx", header.bsize);
	FCM_LOG_PRINT1("ssize:%lx", header.ssize);
	FCM_LOG_PRINT1("res1:%lx", header.res1);
	FCM_LOG_PRINT1("flags:%lx", header.flags);

	}
*/


	if( Fcm_init_AES_VDI() == FALSE )
	{
		return(EXIT_SUCCESS); /* ??? prevoir un message d'erreur un jour peut-etre ... a moins que ce soit géré dans l'init */
	}


	Fcm_get_screen_info();

	Fcm_get_machine_info();


	if( Fcm_systeme.magic_os  ||  Fcm_systeme.mint_os  ||  Fcm_systeme.aes_version >= 0x399 )
	{
		FCM_LOG_PRINT1("- menu_register() AES multitache {%s}"CRLF, "  "PRG_FULL_NOM" ");
		/* cette fonction est dispo sur toute les version de MagiC ? */ 
		menu_register( ap_id, "  "PRG_FULL_NOM" " );

		/*Pdomain( 1 );*/   /* necessite <mintbind.h>, je sais pas si c'est compatible */
		/* avec la LibCmini donc pour le moment j'utilise pas */
		/* de plus, sous mint/aranym, mes applis peuvent lire les noms de fichier long */
		/* sans pdomain(1) (minuscule, '[' ']' etc...  */
		/* enfin, <mintbind.h> rend dispo Ssystem(), mais elle trouve aucun cookie lol */
		/* pour plus tard si cela est necessaire... */
	}


	Fcm_init_win_parametre();

	Fcm_console_init();

	Fcm_charger_config();


	if( Fcm_charge_RSC() == TRUE )
	{
		Fcm_init_prog();

		Fcm_init_rsc_info();
		Fcm_rescale_fenetre_info();
		Fcm_rescale_fenetre_preference();
		Fcm_rescale_bar_menu();

		/* Si version Debug, on previent l'utilisateur de n'utiliser */
		/* cette version que pour générer le log_file.txt            */
		#ifdef LOG_FILE
			Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_DEBUGVERSION, 0L );
		#endif

		FCM_LOG_PRINT(CRLF"************************************" );
		FCM_LOG_PRINT(    "* END Fcm_init_coeur_application() *" );
		FCM_LOG_PRINT(    "************************************"CRLF""CRLF""CRLF );

		return( TRUE );
	}
	

	/* on arrive ici qu'en cas d'erreur !!! */
	FCM_LOG_PRINT( CRLF"***** END Fcm_init_coeur_application()"CRLF"Erreur chargement RSC"CRLF""CRLF""CRLF" " );


	return( FALSE );


}

