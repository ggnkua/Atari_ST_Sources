/* **[Pupul]******************** */
/* *                           * */
/* * 16/08/2014 MaJ 07/11/2023 * */
/* ***************************** */




//#include "../fonction/coeur/coeur_define.c"
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
		return(APPLI_ERROR_DATA_PATH_OVER);
	}

	sprintf( chemin_data, "%sDATA\\", Fcm_chemin_courant );


	#ifdef LOG_FILE
	sprintf( buf_log, "  chemin data {%s}"CRLF, chemin_data );
	log_print(FALSE);
	#endif



	/****************************************************/
	/* V‚rification de la presence de tous les fichiers */
	/****************************************************/
	{
		int16 erreur=0;

		sprintf( mon_chemin, "%spupul.ani", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		sprintf( mon_chemin, "%sbar_red.tga", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		sprintf( mon_chemin, "%sequinox.tga", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		sprintf( mon_chemin, "%sfond.tga", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		sprintf( mon_chemin, "%sfond.tga", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		sprintf( mon_chemin, "%sfondtext.tga", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		sprintf( mon_chemin, "%spupulfnt.tga", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		sprintf( mon_chemin, "%srenaissa.tga", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		{
			int16 idx;

			for(idx=1; idx<7; idx++)
			{
				sprintf( mon_chemin, "%sdemon_0%d.TGA", chemin_data, idx );
				if( Fcm_file_exist(mon_chemin) != TRUE ) erreur++;
			}

			for(idx=1; idx<19; idx++)
			{
				sprintf( mon_chemin, "%sdamier%02d.TGA", chemin_data, idx );
				if( Fcm_file_exist(mon_chemin) != TRUE ) erreur++;
			}

		}



		if( erreur != 0 )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, CRLF"# %d fichier(s) absent(s)"CRLF, erreur);
			log_print(FALSE);
			#endif

			return(APPLI_ERROR_DATAFILE_NOT_FOUND);
		}





		/* les sons sont dans le dossier DATA, en mode graphique mono ou non */

		sprintf( mon_chemin, "%s%s", chemin_data, "CYBERNO2.MOD");
		if( Fcm_file_exist( mon_chemin ) != TRUE )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "  ERREUR: %s absent"CRLF, mon_chemin );
			log_print(FALSE);
			#endif

			global_flag_audio_ok=FALSE;
			affiche_error(APPLI_ERROR_CYBERNOID_NOT_FOUND);
		}

	}


	return 0L;


}

