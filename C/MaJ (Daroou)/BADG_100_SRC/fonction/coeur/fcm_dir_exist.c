/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 30/12/2012 MaJ 05/03/2024 * */
/* ***************************** */



int16 Fcm_dir_exist( const char *repertoire )
{
	int32  handle_fichier;
	char   chemin[FCM_TAILLE_CHEMIN];


	FCM_LOG_PRINT1(CRLF"* Fcm_dir_exist(%s)", repertoire);


	/* On controle un ‚ventuel d‚bordement */
	if( ( strlen(repertoire) + 12 )   >   FCM_TAILLE_CHEMIN )
	{
		FCM_CONSOLE_DEBUG("Fcm_dir_exist() taille buffer insuffisante");

		return FALSE;
	}

	/* on construit le chemin + fichier */
	strcpy( chemin, repertoire );
	strcat( chemin, "ERASEME.TMP" );

	/* On tente de cr‚er le fichier... */
	handle_fichier = Fcreate( chemin, 0 );

	if( handle_fichier < 0 )
	{
		/* erreur lors de la cr‚ation du fichier */
		/* r‚pertoire invalide */
		return(FALSE);
	}

	/* Le fichier a ‚t‚ cr‚e donc le repertoire est valide */
	/* On ferme le fichier et on l'efface */
	Fclose(handle_fichier);
	Fdelete(chemin);

	return(TRUE);


}

