/**[Fonction commune]***************/
/* Fonction GFA adapt‚ et am‚lior‚ */
/* 02/06/2013 # 02/06/2013         */
/***********************************/


/* Prototype */
LONG Fcm_bsave(CHAR *nom_fichier,CHAR *adresse, LONG nombre);


/* Fonction */
LONG Fcm_bsave(CHAR *nom_fichier,CHAR *adresse, LONG nombre)
{
	LONG	handle_fichier;
	LONG	nombre_sauver;
	LONG	reponse=0;
/*	LONG	dummy;*/


	#ifdef LOG_FILE
	sprintf( buf_log, "# bsave( {%s}, 0x%p, %ld )"CRLF, nom_fichier, adresse, nombre );
	log_print( FALSE );
	#endif
	printf( "# bsave( {%s}, 0x%p, %ld )"CRLF, nom_fichier, adresse, nombre );

	/* Ouverture du fichier */
	handle_fichier=Fcreate(nom_fichier, 0);


	/* Si erreur on retourne l'erreur */
	if(handle_fichier<0)
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "# ERREUR Bsave, handle=%ld"CRLF, handle_fichier );
		log_print( FALSE );
		#endif
		printf( "# ERREUR Bsave, handle=%ld"CRLF, handle_fichier );

		return(handle_fichier);
	}








		do
		{
			nombre_sauver=Fwrite(handle_fichier, nombre, adresse);

			printf( "Nombre_sauver=%ld"CRLF, nombre_sauver );


			adresse=adresse+nombre_sauver;
			nombre=nombre-nombre_sauver;
			reponse=reponse+nombre_sauver;

		} while(nombre);


	Fclose(handle_fichier);


	if( reponse>0 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "# bsave: %ld octets sauv‚s"CRLF, reponse );
		log_print( FALSE );
		#endif
		printf( "# bsave: %ld octets sauv‚s"CRLF, reponse );
	}


	return(reponse);


}

