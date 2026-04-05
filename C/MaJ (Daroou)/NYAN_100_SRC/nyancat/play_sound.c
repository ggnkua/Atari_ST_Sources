/* **[NyanCat]****************** */
/* *                           * */
/* * 26/11/2023 MaJ 26/11/2023 * */
/* ***************************** */



#include "../fonction/audio/fcm_musique.c"



/* prototype */
void play_sound( void );



/* Fonction */
void play_sound( void )
{

	int32 reponse = global_flag_audio_error;


#ifdef LOG_FILE
sprintf( buf_log, CRLF"# play_sound()"CRLF);
log_print(FALSE);
#endif

	
	if(global_flag_audio_error==0 && global_mute_sound==FALSE && global_animation_pause==FALSE)
	{
		/* on joue la musique */
		reponse = Fcm_musique_play( &global_musique );
	}

	if( reponse != 0  )
	{
		if( global_flag_audio_error != 0 )
		{
			affiche_error(global_flag_audio_error);
		}

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

