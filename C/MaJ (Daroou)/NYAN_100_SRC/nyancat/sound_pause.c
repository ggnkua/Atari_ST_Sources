/* **[NyanCat]****************** */
/* *                           * */
/* * 04/01/2024 MaJ 04/01/2024 * */
/* ***************************** */



void sound_pause( void );






void sound_pause( void )
{

#ifdef LOG_FILE
sprintf( buf_log, CRLF"# sound_pause()"CRLF);
log_print(FALSE);
#endif


	Fcm_musique_pause( &global_musique );


	return;


}

