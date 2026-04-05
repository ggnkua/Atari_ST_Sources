/*===========================*/
/* Gestion de l'execution de */
/* la tache TIMER            */
/*                           */
/* 29/12/2012 # 10/01/2014   */
/*___________________________*/



#ifndef __Fcm_task_timer__
#define __Fcm_task_timer__




#include "Fcm_Get_Timer.c"




/* prototype */
void  Fcm_task_timer( void );


/* Fonction */
void Fcm_task_timer( void )
{
/*
 * 	externe uint32 fcm_task_timer_old;
 */


	uint32 timer;


	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_task_timer ");
	log_print( FALSE );
	#endif


	timer=Fcm_get_timer();

	#ifdef LOG_FILE
	sprintf( buf_log, "timer=%ld - FCM_TASK_TIMER=%d"CRLF,timer, FCM_TASK_TIMER);
	log_print( FALSE );
	#endif

	/* Si le d‚lai est bon... */
	if( timer > (fcm_task_timer_old+FCM_TASK_TIMER) )
	{
		/* On lance la tache de fond */
		fcm_task_timer_old=timer;


		#ifdef LOG_FILE
		sprintf( buf_log, "=> (local) gestion_timer()"CRLF);
		log_print( FALSE );
		#endif

		gestion_timer();
	}


	return;


}


#endif

