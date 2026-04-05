/*==============================================*/
/* Fonction qui regarde si le r‚p‚rtoire existe */
/* 30/12/2012 # 10/01/2015                      */
/*______________________________________________*/


/* Prototype */
int16 Fcm_dir_exist( const char *repertoire);



/* Fonction */
int16 Fcm_dir_exist( const char *repertoire)
{

	int32	handle_fichier;
	char	chemin[TAILLE_CHEMIN];



	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_dir_exist( %s )"CRLF, repertoire );
	log_print(FALSE);
	#endif



	/* On controle un ‚ventuel d‚bordement */
	if( (strlen(repertoire)+12) > TAILLE_CHEMIN )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR chemin trop long pour le buffer"CRLF );
		log_print(FALSE);
		#endif

		return FALSE;
	}



	/* on construit le chemin+fichier */
	strcpy( chemin, repertoire );
	strcat( chemin, "ERASEME.TMP" );



	/* On tente de cr‚er le fichier... */
	handle_fichier=Fcreate( chemin, 0 );


	/* erreur lors de la cr‚ation du fichier */
	if( handle_fichier < 0 )
	{
		return(FALSE); /* r‚pertoire invalide */
	}


	/* Le fichier a ‚t‚ cr‚e donc le repertoire est valide */
	/* On ferme le fichier et on l'efface                  */
	Fclose(handle_fichier);
	Fdelete(chemin);


	return(TRUE);	/* le r‚pertoire exist */


}

