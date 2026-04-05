/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 24/05/2018 * */
/* ***************************** */




#ifndef ___EXIT_SOUND___
#define ___EXIT_SOUND___



#include "../fonction/include/falcon.h"



/* prototype */
void exit_sound( void );



/* Fonction */
void exit_sound( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# exit_sound()"CRLF);
	log_print(FALSE);
	#endif


	/* Doit-on couper le son ? */
	if( global_musique.status == FCM_MUSIQUE_STATUS_PLAY )
	{
		Buffoper(0);
		Unlocksnd();
		/*Sndstatus( SND_RESET );*/   /* utile ??? */
	}


	/* on libere le buffer de la musique */
	if( global_adr_buffer_AVR != 0 )
	{
		Fcm_libere_ram( global_adr_buffer_AVR );
	}


	return;


}


#endif  /*  ___EXIT_SOUND___  */

