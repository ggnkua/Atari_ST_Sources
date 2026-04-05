/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 26/08/2025 * */
/* ***************************** */

#include "affiche_error.c"


int32 check_fichier( void );




int32 check_fichier( void )
{

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
sprintf( buf_log, "  chemin data {%s} [%ld/%d]"CRLF, chemin_data, strlen(chemin_data), TAILLE_CHEMIN_DATA );
log_print(FALSE);
#endif






	/****************************************************/
	/* V‚rification de la presence de tous les fichiers */
	/****************************************************/
	{
		char  mon_chemin[ (TAILLE_CHEMIN_DATA+16) ];
		int16 erreur=0;

		sprintf( mon_chemin, "%sARGH1.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sARGH2.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sARGH3.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sARGH4.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sARGH5.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sARGH6.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sARGH7.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;


		sprintf( mon_chemin, "%sCACTUS.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sDESERT.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sHERBE1.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sHERBE2.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sHORIZON1.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sHORIZON2.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sMUSHROM1.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sMUSHROM2.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sNUAGE.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sPRAIRIE.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sSOLEIL.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;

		sprintf( mon_chemin, "%sSNAKE1.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sSNAKE2.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sSNAKE3.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;
		sprintf( mon_chemin, "%sSNAKE4.TGA", chemin_data );
		if( Fcm_file_exist( mon_chemin ) != TRUE ) erreur++;



		{
			int16 idx_badgers;
			int16 idx_form;

			for(idx_badgers=1; idx_badgers<NB_BADGERS; idx_badgers++)
			{
				if( idx_badgers!=8 && idx_badgers!=10)
				{
					for( idx_form=1; idx_form<5; idx_form++)
					{
						sprintf( mon_chemin, "%sBADGR%d%d.TGA", chemin_data, idx_badgers,idx_form );
						if( Fcm_file_exist(mon_chemin) != TRUE ) erreur++;
					}
				}
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



//		sprintf( mon_chemin, "%sBADGERS.AVR", chemin_data );
		sprintf( mon_chemin, "%s%s", chemin_data, FILE_BADGERS_AVR );

		if( Fcm_file_exist( mon_chemin ) != TRUE )
		{
			global_audio_ok = FALSE;
			affiche_error(APPLI_ERROR_AVR_NOT_FOUND);
		}
	}


	return 0L;


}

