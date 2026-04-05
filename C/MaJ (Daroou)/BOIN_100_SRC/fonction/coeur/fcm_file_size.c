/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 11/05/2002 MaJ 05/03/2024 * */
/* ***************************** */



int32 Fcm_file_size( const char *nom_fichier )
{
	int32	handle_fichier;
	int32	reponse;


	FCM_LOG_PRINT1(CRLF"* Fcm_file_size( {%s} )",nom_fichier);

	handle_fichier = Fopen( nom_fichier, 0 );

	if( handle_fichier < 0 )
	{
		FCM_LOG_PRINT1("  ERREUR -> handle_fichier=(%ld)", handle_fichier );

		return( handle_fichier );
	}

	/* on se position … la fin du fichier */
	reponse = Fseek( 0, handle_fichier, SEEK_END );

	FCM_LOG_PRINT1("  taille fichier = %ld", reponse );

	/* On ferme le fichier */
	Fclose( handle_fichier );

	return(reponse);

}

