/* **[Fonction Commune]********** */
/* * Fonction Log_Print         * */
/* * 16/06/2003 :: 06/04/2013   * */
/* ****************************** */



#ifndef __FCM_LOG_PRINT_C__
#define __FCM_LOG_PRINT_C__






void log_print ( const int16 mode )
{

	char	chemin[FCM_TAILLE_CHEMIN];
	int32	handle_fichier;


	/* plus de place sur le disk, on ne fait rien */
	if( Fcm_disk_full == TRUE )
	{
		printf( "disque plein (%d)     "CR, buf_log[0] );
		return;
	}



	strcpy( chemin, Fcm_chemin_courant );
	strcat( chemin, "LOG_FILE.TXT" );

	if( !Fcm_file_exist(chemin) )
	{
		printf("LOG PRINT: ERREUR Fcm_chemin_courant non defini "CRLF );
	}
	else
	{
		if( mode==TRUE )
		{
			handle_fichier=Fcreate(chemin,0);
		}
		else
		{
			handle_fichier=Fopen(chemin,S_WRITE);
		}



		if(handle_fichier>0)
		{
			int32 reponse;

			(void)Fseek ( 0, handle_fichier, SEEK_END );
			reponse=Fwrite( handle_fichier, strlen(buf_log) , buf_log );
			(void)Fclose( handle_fichier );

			if( reponse < 0 )
			{
				Fcm_disk_full = TRUE;
			}
		}
	}


	return;


}


#endif   /*   __FCM_LOG_PRINT_C__    */

