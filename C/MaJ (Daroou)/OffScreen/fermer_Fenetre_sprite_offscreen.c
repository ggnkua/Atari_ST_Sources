/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 16/12/2015 * */
/* ***************************** */




/* Prototype */
void fermer_fenetre_sprite_offscreen( void );



/* Fonction */
void fermer_fenetre_sprite_offscreen( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, "# fermer_fenetre_sprite_offscreen"CRLF );
	log_print(FALSE);
	#endif


	if( offscreen_mode==RB_STAT_OFF_VRAM )
	{
		OBJECT	*adr_formulaire;

		offscreen_mode=RB_STAT_OFF_VDI;

		if( gb_mode_vdi_actif==FALSE )
		{
			offscreen_mode=RB_STAT_OFF_STRM;

			if( gb_mode_stram_actif==FALSE )
			{
				offscreen_mode=RB_STAT_OFF_TTRM;
			}
		}

		change_offscreen_mode();


		/* on cherche l'adresse du formulaire */
		rsrc_gaddr( R_TREE, DL_STATS, &adr_formulaire );

		/* on d‚select tous les objets du radio bouton */
		SET_BIT_W( (adr_formulaire+offscreen_mode)->ob_state, OS_SELECTED, 1);
		SET_BIT_W( (adr_formulaire+RB_STAT_OFF_VRAM)->ob_state, OS_SELECTED, 0);

		Fcm_objet_draw( adr_formulaire, h_win[W_STATS], RB_STAT_OFF_VRAM, FCM_WU_BLOCK );
		Fcm_objet_draw( adr_formulaire, h_win[W_STATS], offscreen_mode, FCM_WU_BLOCK );
	}




	{
		wind_close ( h_win[W_SPRITE_OFFSCREEN] );	/* on ferme la fenetre */
		wind_delete( h_win[W_SPRITE_OFFSCREEN] );	/* et on l'efface      */

		h_win[W_SPRITE_OFFSCREEN]=FCM_NO_OPEN_WINDOW;	/* on m‚morise sa fermeture */

		#ifdef LOG_FILE
		sprintf( buf_log, " ~ fenˆtre W_SPRITE_OFFSCREEN ferm‚"CRLF );
		log_print(FALSE);
		#endif

	}


	return;


}

