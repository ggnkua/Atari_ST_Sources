/* **[Pupul]******************** */
/* *                           * */
/* * 22/07/2017 MaJ 24/05/2018 * */
/* ***************************** */



void reinit_rsc( void );




/* Fonction */
void reinit_rsc( void )
{

	/* le redemmarage pour le mode mono/couleur ne recharge pas le RSC, ni set_config */
	/* uniquement le changement de langue du RSC recharge le RSC et doit etre reinit  */

	#ifdef LOG_FILE
	sprintf( buf_log, " * reinit_rsc()"CRLF );
	log_print( FALSE );
	#endif


	rescale_rsc_options();
	rescale_rsc_mod();


	if( global_flag_audio_error != 0 )
	{
		/* Une erreur niveau audio, on désactive la partie son */
		OBJECT	*adr_dialogue_option;
		rsrc_gaddr( R_TREE, DL_OPTIONS, &adr_dialogue_option );

		SET_BIT_W( (adr_dialogue_option+CHECK_MUTESOUND )->ob_state, OS_SELECTED, 1 );
		SET_BIT_W( (adr_dialogue_option+CHECK_MUTESOUND )->ob_state, OS_DISABLED, 1 );
		SET_BIT_W( (adr_dialogue_option+OPTION_MUTESOUND )->ob_state, OS_DISABLED, 1 );

		//global_mute_sound=TRUE;
	}

	return;


}

