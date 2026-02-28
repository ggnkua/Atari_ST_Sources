/*=================================*/
/* File Size                       */
/* Fonction d‚terminant la taille  */
/* du fichier source               */
/* 11/05/2002 # 10/01/2015         */
/*_________________________________*/



/* Prototypes */
int32 Fcm_file_size(const char *nom_fichier);



/* Fonction */
int32 Fcm_file_size(const char *nom_fichier)
{

	int32	handle_fichier;
	int32	reponse;



	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"* Fcm_file_size( {%s} )"CRLF,nom_fichier);
	log_print(FALSE);
	#endif


	handle_fichier = Fopen(nom_fichier, 0);


	if(handle_fichier<0)
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR = %ld"CRLF, handle_fichier );
		log_print(FALSE);
		#endif
		return(handle_fichier);
	}



	/* on se position … la fin du fichier */
	reponse = Fseek( 0, handle_fichier, SEEK_END );


	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"=> position = %ld"CRLF, reponse );
	log_print(FALSE);
	#endif


	/* On ferme le fichier */
	Fclose(handle_fichier);


	return(reponse);


}

