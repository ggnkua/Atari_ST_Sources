/**[Fonction commune]***************/
/* 07/10/2015 # 28/05/2020         */
/***********************************/


/*
 * Cette fonction joue un son si le DMA audio n'est pas vérouillé
 * et libère le DMA audio juste après le son démarré.
 *
 *
 * ----------------------------------------------------------------
 *
 * Utilisé par Boing, DMA info
 *
 *
*/


#ifndef ___Fcm_sound_play___
#define ___Fcm_sound_play___



#include "../include/falcon.h"
#include "../audio/fcm_sound_play.h"
#include "../audio/fcm_init_dma_sound.c"




#define FCM_SOUND_PLAY_XBIOS_FALCON_FAIL (-7001) /* ??? */
#define FCM_SOUND_PLAY_DMA_LOCKED        (-7002) /* ??? */









int32  Fcm_sound_play( s_MUSIQUE_PLAY *son )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF""CRLF""CRLF"# Fcm_sound_play(%ld,%ld)"CRLF, son->adresse_start, son->adresse_end );
	log_print(FALSE);
	#endif



#ifdef LOG_FILE
	{
		int32 ptr[4];
		Buffptr( &ptr );

		sprintf( buf_log, CRLF"# DMA playback pointeur =%ld  Buffoper(-1)=%ld;"CRLF, ptr[0], Buffoper(-1) );
		log_print(FALSE);
	}
#endif


	/* Sur (mon) Milan, l'ordi se fige si un son est joué plus d'une fois par seconde         */
	/* bug hardware ? driver ? lorsque les caches du 040 sont désactivé, ça plante moins vite */
	/* donc si c'est un Milan, on limite la fréquence des sons joués */
	if( Fcm_systeme.machine_modele == FCM_MACHINE_MILAN )
	{
		static uint32 timer_precedent=0;

		if( ((Fcm_get_timer()-timer_precedent) < 200) ||  (Buffoper(-1)!=0) )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, CRLF"- Milan040, delai trop court %ld"CRLF, (Fcm_get_timer()-timer_precedent) );
			log_print(FALSE);
			#endif

			return 0;
		}
		timer_precedent=Fcm_get_timer();
	}



	/* on verouille le son pour notre appli, s'il n'et pas d‚j… utilis‚ */
	/* ---------------------------------------------------------------- */
	if( Locksnd() != 1 )
	{
		/* le DMA est vérouillé, on ne fait rien */
/*		return APPLI_ERROR_DMA_LOCKED;*/  /*  FCM_SOUND_PLAY_DMA_LOCKED ???  */
		return FCM_SOUND_PLAY_DMA_LOCKED;  /* maj 22/11/2023 */
	}


#ifdef LOG_FILE
sprintf( buf_log, CRLF"- Fcm_init_DMA_sound"CRLF);
log_print(FALSE);
#endif

	/* on initialise le son DMA */
	Fcm_init_DMA_sound( son );



#ifdef LOG_FILE
	{
		int32 ptr[4];
		Buffptr( &ptr );
		sprintf( buf_log, CRLF"# DMA playback pointeur =%ld  Buffoper(-1)=%ld;"CRLF, ptr[0], Buffoper(-1) );
		log_print(FALSE);
	}
#endif



	{
		int32 reponse;

		reponse = Setbuffer ( SR_PLAY, son->adresse_start, (son->adresse_end+1) );

		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"  reponse = Setbuffer=%ld"CRLF, reponse );
		log_print(FALSE);
		#endif

		if( reponse==0 )
		{
			Buffoper ( son->play_mode );
		}
	}




#ifdef LOG_FILE
	{
		int32 ptr[4];
		Buffptr( &ptr );
		sprintf( buf_log, CRLF"# DMA playback pointeur =%ld  Buffoper(-1)=%ld;"CRLF, ptr[0], Buffoper(-1) );
		log_print(FALSE);
		sprintf( buf_log, CRLF"# END Fcm_sound_play()"CRLF );
		log_print(FALSE);
	}
#endif



	/* on dévérouille de suite */
	Unlocksnd();
	return 0;

}


#endif   /* ___Fcm_sound_play___ */

