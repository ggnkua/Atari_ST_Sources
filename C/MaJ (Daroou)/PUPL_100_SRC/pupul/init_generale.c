/* **[Pupul]******************** */
/* *                           * */
/* * 04/07/2014 MaJ 24/02/2015 * */
/* ***************************** */


#include "fonction/coeur/coeur_define.c"
#include "affiche_error.c"



/* prototype */
int32 init_generale( void );



/* Fonction */
int32 init_generale( void )
{

	char  mon_chemin[ (TAILLE_CHEMIN_DATA+16) ];



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# init_generale()"CRLF);
	log_print(FALSE);
	#endif



	/***********************************/
	/* m‚morisation du chemin des data */
	/***********************************/



	/* On v‚rifie que la taille du chemin est inf‚rieur */
	/* … la capacit‚ du buffer                          */
	if( (strlen(Fcm_chemin_courant) + strlen("DATA\\")) > TAILLE_CHEMIN_DATA )
	{
		return(PUPUL_ERROR_DATA_PATH_OVER);
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
		strcat( mon_chemin, "main.TGA" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "demon_01.TGA" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "demon_02.TGA" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "demon_03.TGA" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "trans_01.TGA" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "trans_02.TGA" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "ball_01.TGA" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "equinox.TGA" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "renaissa.TGA" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "bar_red.tga" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "pupulfnt.tga" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "fondtext.tga" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "pupul.ANI" );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;



		{
			int16 idx;

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

			return(PUPUL_ERROR_DATAFILE_NOT_FOUND);
		}




		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "CYBERNO2.MOD" );

		if( Fcm_file_exist( mon_chemin ) != TRUE )
		{
			flag_audio_ok=FALSE;
			affiche_error(PUPUL_ERROR_CYBERNOID_NOT_FOUND);
		}




		if( systeme.xbios_sound != TRUE )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, " -> NO XBIOS Falcon sound routine"CRLF );
			log_print(FALSE);
			#endif

			flag_audio_ok=FALSE;
			affiche_error(PUPUL_ERROR_XBIOS_FALCON_NOT_FOUND);
		}



	}




	return 0L;


}

