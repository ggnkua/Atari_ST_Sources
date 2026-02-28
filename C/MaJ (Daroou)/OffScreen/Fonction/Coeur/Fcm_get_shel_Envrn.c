/* **************************** */
/* * Get Shel_Environnement   * */
/* * 28/12/2001 - 15/11/2015  * */
/* **************************** */

/* -----------------------------------------------------------------
   Cette fonction sert … r‚cup‚rer le contenu d'une variable
   d'environnement via la fonction AES SHEL_ENVRN().
  ------------------------------------------------------------------ */


/* Prototype */
int32 Fcm_get_shel_envrn( CHAR *string, const char *name, const uint16 size_max );


/* Fonction */
int32 Fcm_get_shel_envrn( char *string, const char *name, const uint16 size_max )
{

	char	*chaine;



	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"* Fcm_get_shel_envrn({%s},{%s},%d)"CRLF, string, name, size_max );
	log_print(FALSE);
	#endif



	if( shel_envrn(&chaine, name)==1 )
	{

		#ifdef LOG_FILE
		sprintf( buf_log, TAB8"-> chaine=0x%p -> chaine={%s}"CRLF, chaine, chaine );
		log_print(FALSE);
		#endif



		if( chaine != NULL )
		{

			if( strlen(chaine) < size_max )
			{
				#ifdef LOG_FILE
				uint16 i;

				sprintf( buf_log, CRLF"detail chaine:"CRLF );
				log_print(FALSE);

				for( i=0; i<strlen(chaine); i++)
				{
					sprintf( buf_log, "%d {%c}"CRLF, chaine[i], chaine[i] );
					log_print(FALSE);
				}

				sprintf( buf_log, CRLF"Fin detail chaine"CRLF );
				log_print(FALSE);
				#endif

				strcpy( string, chaine );


				#ifdef LOG_FILE
				sprintf( buf_log, TAB8"-> reponse={%s}"CRLF, string );
				log_print(FALSE);
				#endif


				return(TRUE);	/* ChaŒne trouv‚ */

			}
			else
			{
				#ifdef LOG_FILE
				sprintf( buf_log, TAB8"-> reponse trop longue (%ld) => {%s}"CRLF,  strlen(chaine), chaine );
				log_print(FALSE);
				#endif
			}
		}
		else
		{
			#ifdef LOG_FILE
			sprintf( buf_log, TAB8"-> ChaŒne non d‚fini"CRLF );
			log_print(FALSE);
			#endif
		}

	}
	else
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR -> reponse shel_envrn() != 1 !!!"CRLF );
		log_print(FALSE);
		#endif

	}


	return(FALSE);	/* ChaŒne non trouv‚ */


}

