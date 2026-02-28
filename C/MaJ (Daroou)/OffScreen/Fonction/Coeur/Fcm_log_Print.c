/* **[Fonction Commune]********** */
/* * Fonction Log_Print         * */
/* * 16/06/2003 :: 06/04/2013   * */
/* ****************************** */



#ifndef __log_print__
#define __log_print__



/* Fonction */
VOID log_print ( const WORD mode )
{
/*
 * extern CHAR Fcm_chemin_courant[TAILLE_CHEMIN];
 * extern CHAR buf_log[TAILLE_BUFFER];
 *
 */

	CHAR	chemin[TAILLE_CHEMIN];
	LONG	handle_fichier;



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
			(VOID)Fseek ( 0, handle_fichier, SEEK_END );
			(VOID)Fwrite( handle_fichier, strlen(buf_log) , buf_log );
			(VOID)Fclose( handle_fichier );
		}
	}


	return;


}


#endif

