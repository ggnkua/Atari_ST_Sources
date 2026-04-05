/* **[Fonction Commune]**************** */
/* *                                  * */
/* * 15/01/2013 - 19/08/2014          * */
/* ************************************ */



#ifndef __GNUC_PATCHLEVEL__
#define __GNUC_PATCHLEVEL__ 1
#endif


#include "Fcm_init_environnement.c"
#include "Fcm_init_AES_VDI.c"

#ifdef LOG_FILE
#include "Fcm_log_pointeur_fonction.c"
#endif

#include "Fcm_get_screen_info.c"
#include "Fcm_get_machine_info.c"
#include "Fcm_charge_RSC.c"
#include "Fcm_init_win_parametre.c"
#include "Fcm_init_rsc_info.c"
#include "Fcm_init_prog.c"



/* Prototype */
WORD Fcm_init_coeur_application( VOID );


/* Fonction */
WORD Fcm_init_coeur_application( VOID )
{
/*
 *
 */

	graf_mouse( ARROW, 0 );

	/* ATTENTION :                                */
	/* Aucune sortie de LOG ne peut etre effectue */
	/* avant l'init de l'environnement            */

	Fcm_init_environnement();

	#ifdef LOG_FILE
	sprintf( buf_log, "***** Fcm_init_coeur_application()"CRLF );
	log_print(FALSE);
	#endif




	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"  GEMLIB version:  __GEMLIB_MAJOR__ =%d, __GEMLIB_MINOR__ =%d, __GEMLIB_REVISION__ =%d"CRLF, __GEMLIB_MAJOR__, __GEMLIB_MINOR__, __GEMLIB_REVISION__ );
	log_print(FALSE);
	sprintf( buf_log, CRLF"  GCC version:  __GNUC__ =%d, __GNUC_MINOR__ =%d, __GNUC_PATCHLEVEL__ =%d"CRLF""CRLF, __GNUC__, __GNUC_MINOR__, __GNUC_PATCHLEVEL__ );
	log_print(FALSE);
	#endif



	if( Fcm_init_AES_VDI()==FALSE )
	{
		return(EXIT_SUCCESS);
	}


	#ifdef LOG_FILE
	Fcm_log_pointeur_fonction();
	#endif


	Fcm_get_screen_info();
	Fcm_get_machine_info();


	if( Fcm_charge_RSC()==TRUE )
	{
		Fcm_init_win_parametre();
		Fcm_init_rsc_info();
		Fcm_init_prog();

		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"***** END Fcm_init_coeur_application()"CRLF""CRLF""CRLF""CRLF );
		log_print(FALSE);
		#endif

		return( TRUE );
	}

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"***** END Fcm_init_coeur_application()"CRLF""CRLF""CRLF""CRLF );
	log_print(FALSE);
	#endif

	return( FALSE );


}

