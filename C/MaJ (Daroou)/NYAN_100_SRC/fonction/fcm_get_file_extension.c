/* **************************** */
/* * Fonction File Extension  * */
/* * 10/05/2002 # 03/03/2013  * */
/* **************************** */

#define FCM_EXTENSION_SIZE_MAX 5

/* Prototype */
VOID Fcm_get_file_extension( CHAR *fichier, CHAR *buffer );


/* Fonction */
VOID Fcm_get_file_extension( CHAR *fichier, CHAR *buffer )
{
	WORD	index;


	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_get_file_extension(%s,%s)"CRLF, fichier, buffer );
	log_print(FALSE);
	#endif


	buffer[0]='.';	/* ?????? */

	for( index=(strlen(fichier)-1); index>=0; index-- )
	{
		if( fichier[index]=='.' )
		{
			if( strlen( (fichier+index) ) <= FCM_EXTENSION_SIZE_MAX )
			{
				strcpy( buffer, (fichier+index) );
			}
			else
			{
#ifdef LOG_FILE
sprintf( buf_log, "ERREUR -> Extension trop longue {%s}"CRLF, (fichier+index) );
log_print(FALSE);
#endif
			}
			break;
		}
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "  -> Extension => buffer={%s}"CRLF, buffer );
	log_print(FALSE);
	#endif

}

