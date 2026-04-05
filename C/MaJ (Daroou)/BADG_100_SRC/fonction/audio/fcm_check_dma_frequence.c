/**[Fonction Audio]*****************/
/* 30/06/2020 # 30/06/2020         */
/***********************************/


/*
 * Cette fonction controle et corrige la frequence d'un son 
 *
 *
 *
 *
*/


#ifndef ___Fcm_check_dma_frequence___
#define ___Fcm_check_dma_frequence___


/*
#include "../include/FALCON.H"
#include "../audio/Fcm_sound_play.h"
#include "../audio/Fcm_init_DMA_sound.c"
*/




uint16  Fcm_check_dma_frequence( int32 frequence );




uint16  Fcm_check_dma_frequence( int32 frequence )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# Fcm_check_dma_frequence(%ld)"CRLF, frequence);
	log_print(FALSE);
	#endif


	if( frequence < 0 )
	{
		frequence = ABS( frequence );
	}



	/* valeur sur 16bits, max 65535 */

	if( frequence < 9400 )
	{
		frequence=6250;
	}

	if( frequence >= 9400 && frequence < 18700 )
	{
		frequence=12500;
	}

	if( frequence >= 18700 && frequence < 37500 )
	{
		frequence=25000;
	}

	if( frequence >= 37500 )
	{
		frequence=50000;
	}

	/* a faire, verifier si la frequence a une valeur correct DMA Audio (???) */



	return (uint16)frequence;

}


#endif   /* ___Fcm_check_dma_frequence___ */

