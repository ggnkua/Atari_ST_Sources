/* **[Badgers]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 04/01/2024 * */
/* ***************************** */

#include "../fonction/include/falcon.h"

void exit_sound( void );





void exit_sound( void )
{

#ifdef LOG_FILE
sprintf( buf_log, CRLF"# exit_sound()"CRLF);
log_print(FALSE);
#endif


	/* Doit-on couper le son ? */
	if( global_audio_ok==TRUE && global_mute_sound==FALSE )
	{
		Buffoper(0);
		Unlocksnd();
	}


	/* on libere le buffer de la musique */
	if( global_adr_buffer_avr != 0 )
	{
		Fcm_libere_ram( global_adr_buffer_avr );
	}


	return;


}

