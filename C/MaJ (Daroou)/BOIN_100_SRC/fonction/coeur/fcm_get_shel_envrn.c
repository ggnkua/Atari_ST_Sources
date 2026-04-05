/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 28/12/2001 MaJ 03/03/2024 * */
/* ***************************** */



int32 Fcm_get_shel_envrn( char *string, const char *name, const uint16 size_max )
{
	char  *chaine;


	FCM_LOG_PRINT3(CRLF"* Fcm_get_shel_envrn({%s},{%s},%d)", string, name, size_max);


	shel_envrn( &chaine, name );


	/* Comme shel_envrn() renvoie toujours 1, on teste la chaine directement */
	if( chaine != NULL )
	{
		if( strlen(chaine) < size_max )
		{


#ifdef LOG_FILE
{
	uint16 i;

	sprintf( buf_log, "  detail chaine:"CRLF );
	log_print(FALSE);

	for( i=0; i < strlen(chaine); i++)
	{
		sprintf( buf_log, "  %d {%c}"CRLF, chaine[i], chaine[i] );
		log_print(FALSE);
	}

	sprintf( buf_log, "  :Fin detail chaine"CRLF);
	log_print(FALSE);
}
#endif

			strcpy( string, chaine );

			FCM_LOG_PRINT1("  -> reponse={%s}"CRLF" END -> Fcm_get_shel_envrn()"CRLF""CRLF, string);

			return(TRUE);
		}
		else
		{
			FCM_CONSOLE_DEBUG("Buffer pour Fcm_get_shel_envrn() trop petit");
		}
	}
	else
	{
		FCM_LOG_PRINT("  -> ChaŒne non d‚fini");
	}

	FCM_LOG_PRINT("   END Fcm_get_shel_envrn()"CRLF);


	return(FALSE);


}

