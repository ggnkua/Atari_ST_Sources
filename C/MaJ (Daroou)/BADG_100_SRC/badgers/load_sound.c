/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 26/08/2025 * */
/* ***************************** */

#define TAILLE_CHEMIN_AVR   ( (TAILLE_CHEMIN_DATA)+(16) )


int32 load_sound( void );





int32 load_sound( void )
{
	char    mon_chemin[TAILLE_CHEMIN_AVR];
	int32   taille_fichier;



#ifdef LOG_FILE
sprintf( buf_log, CRLF"# load_sound(%s)"CRLF, FILE_BADGERS_AVR);
log_print(FALSE);
#endif



	if( (strlen(chemin_data)+strlen(FILE_BADGERS_AVR)) > TAILLE_CHEMIN_AVR )
	{
		return(APPLI_ERROR_DATA_PATH_OVER);
	}


	sprintf( mon_chemin, "%s%s", chemin_data, FILE_BADGERS_AVR );


#ifdef LOG_FILE
sprintf( buf_log, CRLF" chemin: {%s}"CRLF, mon_chemin);
log_print(FALSE);
#endif


	taille_fichier = Fcm_file_size(mon_chemin);


#ifdef LOG_FILE
sprintf( buf_log, CRLF"  Taille fichier : %ld"CRLF, taille_fichier );
log_print(FALSE);
#endif


	/* Probläme d'accäs au fichier ? */
	if( taille_fichier < 0  ||  taille_fichier != BADGERS_SOUND_SIZE )
	{
		return( APPLI_ERROR_AVR_FILE );
	}





	{
		int32 number_octet_load;


		number_octet_load = Fcm_bload( mon_chemin,(char *)global_adr_buffer_avr, 0, taille_fichier);

		if( number_octet_load!=taille_fichier || number_octet_load!=BADGERS_SOUND_SIZE )
		{
			return( APPLI_ERROR_AVR_SIZE );
		}
	}





	return 0L;


}

