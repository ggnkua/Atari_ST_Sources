/**[Fonction commune]***************/
/*                                 */
/* 17/05/2018 # 26/05/2020         */
/***********************************/



#ifndef ___FCM_MUSIQUE_C___
#define ___FCM_MUSIQUE_C___




#include "../include/falcon.h"
#include "../audio/fcm_musique.h"
#include "../audio/fcm_init_dma_sound.c"


/* Fonctions:
 * ---------------------------------------------------
 * int32 Fcm_musique_play  ( s_MUSIQUE_PLAY *musique )
 * void  Fcm_musique_pause ( s_MUSIQUE_PLAY *musique )
 * void  Fcm_musique_stop  ( s_MUSIQUE_PLAY *musique )
 * ---------------------------------------------------
 *
 * Utilisé par Nyancat GEM pour jouer la musique de fond
 *
 *
 */


/*
#define FCM_SOUND_PLAY_XBIOS_FALCON_FAIL (-7001)
#define FCM_SOUND_PLAY_DMA_LOCKED        (-7002)
*/



int32 Fcm_musique_play( s_MUSIQUE_PLAY *musique )
{
	int32 reponse;
/*	s_AVR_HEADER *musique_header;
	
	CHAR	my_buffer[256];



	musique_header = (s_AVR_HEADER *)adr_buffer_AVR;


{
	


		
		sprintf( my_buffer, "Mono/Stereo : %d ", musique_header->mono  );
		v_gtext( vdihandle, 8, 16*2, my_buffer);
		sprintf( my_buffer, "nb bit : %d ",  musique_header->rez );
		v_gtext( vdihandle, 8, 16*3, my_buffer);
		sprintf( my_buffer, "Sign‚/non sign‚ : %d ", musique_header->sign );
		v_gtext( vdihandle, 8, 16*4, my_buffer);
		sprintf( my_buffer, "boucle oui/non : %d ",  musique_header->loop );
		v_gtext( vdihandle, 8, 16*5, my_buffer);
		sprintf( my_buffer, "Midi  : %d ",  musique_header->midi );
		v_gtext( vdihandle, 8, 16*6, my_buffer);
		sprintf( my_buffer, "frequence : %ld ", musique_header->rate & 0x00ffffff);
		v_gtext( vdihandle, 8, 16*7, my_buffer);
		sprintf( my_buffer, "size : %ld ", musique_header->size );
		v_gtext( vdihandle, 8, 16*8, my_buffer);
		sprintf( my_buffer, "loop beg : %ld ", musique_header->lbeg );
		v_gtext( vdihandle, 8, 16*9, my_buffer);
		sprintf( my_buffer, "loop end : %ld ", musique_header->lend );
		v_gtext( vdihandle, 8, 16*10, my_buffer);


		sprintf( my_buffer, "Mono/Stereo : %d ", musique->stereo  );
		v_gtext( vdihandle, 8, 16*12, my_buffer);
		sprintf( my_buffer, "nb bit : %d ",  musique->rez_bit );
		v_gtext( vdihandle, 8, 16*13, my_buffer);
		sprintf( my_buffer, "Sign‚/non sign‚ : %d ", musique->signe );
		v_gtext( vdihandle, 8, 16*14, my_buffer);
		sprintf( my_buffer, "frequence : %d ", musique->frequence );
		v_gtext( vdihandle, 8, 16*15, my_buffer);
		sprintf( my_buffer, "adresse_start beg : %ld ", musique->adresse_start );
		v_gtext( vdihandle, 8, 16*16, my_buffer);
		sprintf( my_buffer, "adresse_end end : %ld ", musique->adresse_end );
		v_gtext( vdihandle, 8, 16*17, my_buffer);
		sprintf( my_buffer, "loop beg : %ld ", musique->adresse_loop_start );
		v_gtext( vdihandle, 8, 16*18, my_buffer);
		sprintf( my_buffer, "loop end : %ld ", musique->adresse_loop_end );
		v_gtext( vdihandle, 8, 16*19, my_buffer);
		sprintf( my_buffer, "adresse_pause : %ld ", musique->adresse_pause );
		v_gtext( vdihandle, 8, 16*20, my_buffer);
		sprintf( my_buffer, "status : %d ", musique->status );
		v_gtext( vdihandle, 8, 16*21, my_buffer);

}
*/

	/* cette erreur ne devrait jamais arriver, erreur de code, a revoir */
	if( musique->status == FCM_MUSIQUE_STATUS_PLAY )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"ERREUR ***** musique->status == FCM_MUSIQUE_STATUS_PLAY "CRLF );
		log_print(FALSE);
		#endif
		return -9999;
	}


	/* on verouille le son pour notre appli, s'il n'et pas d‚j… utilis‚ */
	/* ---------------------------------------------------------------- */
	if( Locksnd() != 1 )
	{
		Fcm_affiche_alerte( DATA_MODE_APPLI, ALT_ERR_DMA_LOCK, 0 );
		return ALT_ERR_DMA_LOCK;
	}

/*	sprintf( my_buffer, "Fcm_init_DMA_sound" );
	v_gtext( vdihandle, 8, 16*22, my_buffer);*/



	/* on initialise le son DMA */
	Fcm_init_DMA_sound( musique );



	if( musique->status == FCM_MUSIQUE_STATUS_STOP )
	{
		reponse = Setbuffer ( SR_PLAY, musique->adresse_start, musique->adresse_end );

/*		sprintf( my_buffer, "reponse : %ld ", reponse );
		v_gtext( vdihandle, 8, 16*24, my_buffer);*/

		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"  reponse = Setbuffer=%ld"CRLF, reponse );
		log_print(FALSE);
		#endif


		if( reponse == 0 )
		{
			Buffoper ( musique->play_mode );
			musique->status = FCM_MUSIQUE_STATUS_PLAY;

			reponse = Setbuffer ( SR_PLAY, musique->adresse_loop_start, musique->adresse_loop_end );

/*			sprintf( my_buffer, "reponse boucle: %ld ", reponse );
			v_gtext( vdihandle, 8, 16*25, my_buffer);*/

			#ifdef LOG_FILE
			sprintf( buf_log, CRLF"  reponse boucle = Setbuffer=%ld"CRLF, reponse );
			log_print(FALSE);
			#endif
		}
		else
		{
			Unlocksnd();
		}
	}



	if( musique->status == FCM_MUSIQUE_STATUS_PAUSE )
	{
		reponse = Setbuffer ( SR_PLAY, musique->adresse_pause, musique->adresse_loop_end );

/*		sprintf( my_buffer, "reponse : %ld ", reponse );
		v_gtext( vdihandle, 8, 16*24, my_buffer);*/

		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"  reponse = Setbuffer=%ld"CRLF, reponse );
		log_print(FALSE);
		#endif

		if( reponse == 0 )
		{
			Buffoper ( musique->play_mode );
			musique->status = FCM_MUSIQUE_STATUS_PLAY;

			reponse = Setbuffer ( SR_PLAY, musique->adresse_loop_start, musique->adresse_loop_end );

/*			sprintf( my_buffer, "reponse boucle: %ld ", reponse );
			v_gtext( vdihandle, 8, 16*25, my_buffer);*/

			#ifdef LOG_FILE
			sprintf( buf_log, CRLF"  reponse boucle = Setbuffer=%ld"CRLF, reponse );
			log_print(FALSE);
			#endif
		}
		else
		{
			Unlocksnd();
		}
	}



	return 0;

}














void Fcm_musique_pause( s_MUSIQUE_PLAY *musique )
{
	/*CHAR	my_buffer[256];*/


	if( musique->status != FCM_MUSIQUE_STATUS_PLAY )
	{
/*		sprintf( my_buffer, "**** Fcm_musique_pause => FCM_MUSIQUE_STATUS_PLAY" );
		v_gtext( vdihandle, 8, 16*2, my_buffer);*/

		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"ERREUR **** Fcm_musique_pause => FCM_MUSIQUE_STATUS_PLAY"CRLF );
		log_print(FALSE);
		#endif

		return;
	}


	{
		int32  ptr[4];
		int32  reponse;

		reponse = Buffptr( &ptr );

		if( reponse==0 )
		{
			musique->adresse_pause = (uint32)ptr[0];
		}
		else
		{
			musique->adresse_pause = musique->adresse_loop_start;
		}
	}

	Buffoper(0);
	Unlocksnd();

	musique->status = FCM_MUSIQUE_STATUS_PAUSE;

/*	sprintf( my_buffer, " Fcm_musique_stop => FCM_MUSIQUE_STATUS_STOP " );
	v_gtext( vdihandle, 8, 16*26, my_buffer);*/

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"  Fcm_musique_stop => FCM_MUSIQUE_STATUS_STOP"CRLF );
	log_print(FALSE);
	#endif


	return;

}



void Fcm_musique_stop( s_MUSIQUE_PLAY *musique )
{
	/*CHAR	my_buffer[256];*/


	if( musique->status != FCM_MUSIQUE_STATUS_PLAY )
	{
/*		sprintf( my_buffer, "**** Fcm_musique_stop => FCM_MUSIQUE_STATUS_PLAY" );
		v_gtext( vdihandle, 8, 16*2, my_buffer);*/

		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"ERREUR **** Fcm_musique_stop => FCM_MUSIQUE_STATUS_PLAY"CRLF );
		log_print(FALSE);
		#endif

/*		return;*/
	}


	Buffoper(0);
	Unlocksnd();

	musique->status = FCM_MUSIQUE_STATUS_STOP;

/*	sprintf( my_buffer, " Fcm_musique_stop => FCM_MUSIQUE_STATUS_STOP " );
	v_gtext( vdihandle, 8, 16*26, my_buffer);*/

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"  Fcm_musique_stop => FCM_MUSIQUE_STATUS_STOP"CRLF );
	log_print(FALSE);
	#endif


	return;

}



#endif  /* ___FCM_MUSIQUE_C___ */

