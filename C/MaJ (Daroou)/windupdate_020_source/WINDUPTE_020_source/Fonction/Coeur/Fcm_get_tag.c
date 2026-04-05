/* **[Fonction Commune]************* */
/* * Recherche TAG dans une chaine * */
/* * 26/03/2003 # 11/01/2015       * */
/* ********************************* */


/* Prototype */
int16 Fcm_get_tag( const char *chaine, char *buffer, const int16 taille_buffer, const char *buffer_config );


/* Fonction */
int16 Fcm_get_tag( const char *chaine, char *buffer, const int16 taille_buffer, const char *buffer_config )
{
	/*
	 * chaine : chaine a rechercher
	 * buffer : buffer pour la reponse
	 * taille_buffer: euh... taille du buffer max
	 * buffer_config: buffer contenant le fichier de configuration
	 * taille : taille du fichier de configuration (obsolete: buffer config est NULL terminated
	 */

	char  *pt_position;





	#ifdef LOG_FILE
	sprintf( buf_log, TAB12"* Fcm_get_tag({%s},{%s},%d,%p)"CRLF, chaine,buffer,taille_buffer, buffer_config );
	log_print(FALSE);
	#endif


	if( strlen(chaine)==0 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, TAB12" - TAG vide - strlen chaine %ld"CRLF, strlen(chaine) );
		log_print(FALSE);
		#endif

		return(FALSE);
	}



	/* on recherche la chaine dans le buffer de config */
	pt_position = strstr( buffer_config, chaine );


/*	#ifdef LOG_FILE
	sprintf( buf_log, "position=%p"CRLF, pt_position );
	log_print(FALSE);
	#endif*/

	if( pt_position == NULL )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, TAB12" - TAG non trouv‚"CRLF );
		log_print(FALSE);
		#endif

		/* Le TAG n'a pas ‚t‚ trouv‚ */
		return (FALSE);
	}


	/* on se positionne aprŠs le TAG */
	pt_position = pt_position + strlen(chaine);


/*	#ifdef LOG_FILE
	sprintf( buf_log, "position=%p %s (%ld)"CRLF, pt_position, chaine, strlen(chaine) );
	log_print(FALSE);
	#endif*/


	{
		uint16 nb_car=0;


		while( pt_position[nb_car]!=13 && pt_position[nb_car]!=0 && nb_car<taille_buffer )
		{
			buffer[nb_car] = pt_position[nb_car];
			nb_car++;
		}
		buffer[nb_car] = 0;

		#ifdef LOG_FILE
		sprintf( buf_log, TAB12" - Trouv‚={%s}"CRLF, buffer );
		log_print(FALSE);
		#endif

	}


	return( TRUE );


}

