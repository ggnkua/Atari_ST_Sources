/* **[Badgers]****************** */
/* *                           * */
/* * 04/01/2024 MaJ 04/01/2024 * */
/* ***************************** */

#include "../fonction/include/falcon.h"

void sound_start( void );






void sound_start( void )
{

#ifdef LOG_FILE
sprintf( buf_log, CRLF"# sound_start()"CRLF);
log_print(FALSE);
#endif


	if(global_audio_ok==TRUE && global_mute_sound==FALSE && global_animation_pause==FALSE)
	{
		/* On verouille le DMA audio pour notre appli */
		if( Locksnd() != 1 )
		{
			affiche_error(APPLI_ERROR_DMA_LOCKED);

			global_mute_sound = TRUE;

			{
				OBJECT	*adr_dialogue_option;

				rsrc_gaddr( R_TREE, DL_OPTIONS, &adr_dialogue_option );
				SET_BIT_W( (adr_dialogue_option+CHECK_MUTESOUND )->ob_state, OS_SELECTED, 1 );
				Fcm_objet_draw( adr_dialogue_option, h_win[W_OPTIONS], CHECK_MUTESOUND, FCM_WU_BLOCK );
			}

			return;
		}

		/* Le DMA nous est reservé, on joue la musique */
		{
			Buffoper ( 0 );
			Sndstatus( SND_RESET );

			if( Fcm_systeme.xbios_sound_mode==XBIOS_SOUND_MODE_STE_TT )
			{
				Devconnect( DMAPLAY, DAC, CLK25M, CLKOLD, 1);
				Soundcmd( SETPRESCALE, 2);
			}
			else
			{
				Devconnect( DMAPLAY, DAC, CLK25M, CLK25K, 1);
			}

			Soundcmd( LTATTEN, 0);
			Soundcmd( RTATTEN, 0);

			Setmode( MONO8 );

			Setbuffer ( SR_PLAY, position_sequence_dma[0], position_sequence_dma[1] );
			Buffoper ( (SB_PLA_ENA + SB_PLA_RPT) );
			Setbuffer ( SR_PLAY, position_sequence_dma[1], position_sequence_dma[2] );

			index_sequence_dma = 1; /* on attend que le dma arrive dans cette position */
		}
	}


	return;


}


