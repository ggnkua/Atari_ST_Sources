/* **[NyanCat]****************** */
/* *                           * */
/* * 04/01/2024 MaJ 04/01/2024 * */
/* ***************************** */


#include "../fonction/include/falcon.h"
//#include "../fonction/audio/avr.h"

void sound_play( void );




void sound_play( void )
{
	int32 reponse;


#ifdef LOG_FILE
sprintf( buf_log, CRLF"# sound_play()"CRLF);
log_print(FALSE);
#endif


	reponse=Fcm_musique_play( &global_musique );


	if( reponse==ALT_ERR_DMA_LOCK )
	{
		global_mute_sound = TRUE;

		{
			OBJECT	*adr_dialogue_option;

			rsrc_gaddr( R_TREE, DL_OPTIONS, &adr_dialogue_option );
			SET_BIT_W( (adr_dialogue_option+CHECK_MUTESOUND )->ob_state, OS_SELECTED, 1 );
			Fcm_objet_draw( adr_dialogue_option, h_win[W_OPTIONS], CHECK_MUTESOUND, FCM_WU_BLOCK );
		}
	}


	return;


}


