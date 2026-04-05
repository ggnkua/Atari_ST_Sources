/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 04/01/2024 * */
/* ***************************** */

#include "load_sound.c"

void init_sound( void );





void init_sound( void )
{


#ifdef LOG_FILE
sprintf( buf_log, CRLF"# init_sound()"CRLF);
log_print(FALSE);
#endif



	/* ----------------------------- */
	/*  XBIOS sound compatible ?     */
	/* ----------------------------- */
	if( Fcm_systeme.xbios_sound != TRUE )
	{
#ifdef LOG_FILE
sprintf( buf_log, CRLF"Xbios Falcon Sound routine non d‚tect‚, pas de music"CRLF);
log_print(FALSE);
#endif

		affiche_error(APPLI_ERROR_XBIOS_FALCON);

		global_audio_ok = FALSE;
	}





	/* ----------------------------------------------------------------- */
	/* Buffer Son DMA                                                    */
	/* ----------------------------------------------------------------- */
	if( global_audio_ok == TRUE )
	{
		if( Fcm_systeme.mint_os )
		{
			global_adr_buffer_avr = Fcm_reserve_ram( BADGERS_SOUND_SIZE, (MX_STRAM|MX_MPROT|MX_GLOBAL) );
		}
		else
		{
			global_adr_buffer_avr = Fcm_reserve_ram( BADGERS_SOUND_SIZE, (MX_STRAM) );
		}
			

#ifdef LOG_FILE
sprintf( buf_log, CRLF"  global_adr_buffer_avr : %ld"CRLF, global_adr_buffer_avr );
log_print(FALSE);
#endif

		if( global_adr_buffer_avr == 0L )
		{
			/* echec reservation ram */
			global_audio_ok = FALSE;

			affiche_error( APPLI_ERROR_RESERVE_RAM_AVR );
		}
		else
		{
			memset( (void *)global_adr_buffer_avr, 0, BADGERS_SOUND_SIZE );
		}
	}



	/* ----------------------------------------------------------------- */
	/* Chargement Sample                                                 */
	/* ----------------------------------------------------------------- */
	if( global_audio_ok == TRUE )
	{
		int32 reponse=0;

		reponse = load_sound();

		if( reponse != 0L )
		{
			/* echec chargement  sample */
			global_audio_ok = FALSE;

			affiche_error( reponse );

			memset( (void *)global_adr_buffer_avr, 0, BADGERS_SOUND_SIZE );
		}
	}



	/* ------------------------------------------------------ */
	/* calcul des offsets absolu des sequences de l'animation */
	/* ------------------------------------------------------ */
	{
		int16 idx;

		for( idx=0; idx<NB_SEQUENCE_ANIMATION; idx++)
		{
			position_sequence_dma[idx] = position_sequence_dma_offset[idx] + (int32)(global_adr_buffer_avr+128);
		}
	}


	return;


}

