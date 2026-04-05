/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 15/08/2003 MaJ 05/03/2024 * */
/* ***************************** */



void Fcm_get_chemin_home( char *mon_chemin, const uint16 size_max )
{

	/* recherche du chemin HOME             */
	/* 1- variable d'environnement de l'AES */
	/* 2- recherche C:\home\                */
	/* 3- recherche C:\                     */
	/* 4- chemin de l'application           */
	/* 5- crash bomber                      */


	FCM_LOG_PRINT2(CRLF"* Fcm_get_chemin_home( %p, %d )", mon_chemin, size_max );


	if( Fcm_get_shel_envrn( mon_chemin, "HOME=", (size_max-1) ) == TRUE )
	{
		/* HOME est defini */
		FCM_LOG_PRINT1("- HOME = {%s}", mon_chemin );

		/* si la variable a ‚t‚ trouv‚ */
		if( strlen(mon_chemin) !=0 )
		{
			/* on v‚rifie qu'il y a un backslash en fin de chemin */
			if( mon_chemin[ strlen(mon_chemin)-1 ] != '\\' )
			{
				/* sinon on l'ajoute */
				strcat( mon_chemin, "\\" );

				FCM_LOG_PRINT1("- HOME = {%s} correction", mon_chemin);
			}


			FCM_LOG_PRINT( "- verification chemin" );

			/* si le chemin est valide */
			if( Fcm_dir_exist(mon_chemin) )
			{
				return;
			}
		}
	}


	FCM_LOG_PRINT("- Variable d'environnement non d‚fini, recherche manuelle");

	snprintf( mon_chemin, size_max, "C:\\HOME\\" );

	FCM_LOG_PRINT1("- Recherche de %s", mon_chemin);

	if( Fcm_dir_exist(mon_chemin) )
	{
		FCM_LOG_PRINT1("- chemin {%s} valide", mon_chemin);

		return;
	}


	/* C:\HOME\ n'existe pas, on tente C:\ */

	snprintf( mon_chemin, size_max, "C:\\" );

	FCM_LOG_PRINT1("- Recherche de %s", mon_chemin);

	if( Fcm_dir_exist( mon_chemin ) )
	{
		FCM_LOG_PRINT1("- chemin {%s} valide", mon_chemin);

		return;
	}


	/* Pas de disque dur ? on prend le chemin de l'application    */

	if( size_max > strlen(Fcm_chemin_courant) )
	{
		strcpy( mon_chemin, Fcm_chemin_courant );

		FCM_LOG_PRINT1("- HOME introuvrable, r‚pertoire de l'application utilis‚:"CRLF" -> {%s}", mon_chemin);

		return;
	}

	FCM_LOG_PRINT("- HOME non defini, buffer trop faible pour le chemin courant");


	FCM_CONSOLE_DEBUG("Fcm_get_chemin_home() taille buffer insuffisante");

	/* reste plus que le lecteur de disquette */
	snprintf( mon_chemin, size_max, "A:\\" );


	return;


}

