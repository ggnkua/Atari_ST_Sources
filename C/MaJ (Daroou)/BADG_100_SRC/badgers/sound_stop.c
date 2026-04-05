/* **[Badgers]****************** */
/* *                           * */
/* * 04/01/2024 MaJ 04/01/2024 * */
/* ***************************** */

#include "../fonction/include/falcon.h"

void sound_stop( void );






void sound_stop( void )
{

#ifdef LOG_FILE
sprintf( buf_log, CRLF"# sound_stop()"CRLF);
log_print(FALSE);
#endif


	if( global_audio_ok==TRUE )
	{
		Buffoper(0);
		Unlocksnd();
	}


	return;


}

