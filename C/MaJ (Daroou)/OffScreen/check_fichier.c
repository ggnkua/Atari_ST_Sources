/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 09/01/2016 * */
/* ***************************** */




#include "fonction/coeur/coeur_define.c"
#include "affiche_error.c"



/* prototype */
int32 check_fichier( void );



/* Fonction */
int32 check_fichier( void )
{
	char  mon_chemin[ (TAILLE_CHEMIN_DATA+16) ];




	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# check_fichier()"CRLF);
	log_print(FALSE);
	#endif



	/***********************************/
	/* m‚morisation du chemin des data */
	/***********************************/

	/* On v‚rifie que la taille du chemin est inf‚rieur */
	/* … la capacit‚ du buffer                          */
	if( (strlen(Fcm_chemin_courant) + strlen("DATA\\")) > TAILLE_CHEMIN_DATA )
	{
		return(OFFSCREEN_ERROR_DATA_PATH_OVER);
	}

	strcpy( chemin_data, Fcm_chemin_courant );
	strcat( chemin_data, "DATA\\" );


	#ifdef LOG_FILE
	sprintf( buf_log, "  chemin data {%s}"CRLF, chemin_data );
	log_print(FALSE);
	#endif






	/****************************************************/
	/* V‚rification de la presence de tous les fichiers */
	/****************************************************/
	{
		int16 erreur=0;


		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "BEE.ANI" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "FOND.TGA" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "BEE.TGA" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;


		{
			int16 idx;

			for(idx=1; idx<8; idx++)
			{
				sprintf( mon_chemin, "%sBAR%1d.TGA", chemin_data, idx );

				if( Fcm_file_exist(mon_chemin) != TRUE ) erreur++;
			}
		}



		if( erreur != 0 )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, CRLF"# %d fichier(s) absent(s)"CRLF, erreur);
			log_print(FALSE);
			#endif

			return(OFFSCREEN_ERROR_DATAFILE_NOT_FOUND);
		}

	}



	return 0L;


}


