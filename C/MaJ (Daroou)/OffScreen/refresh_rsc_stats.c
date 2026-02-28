/* **[Offscreen]**************** */
/* *                           * */
/* * 05/01/2016 MaJ 31/01/2016 * */
/* ***************************** */



#ifndef ___refresh_rsc_stats___
#define ___refresh_rsc_stats___


/* prototype */
void refresh_rsc_stats( void );




/* Fonction */
void refresh_rsc_stats( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# refresh_rsc_stats()"CRLF );
	log_print( FALSE );
	#endif


	{
		OBJECT *adr_formulaire;

		rsrc_gaddr( R_TREE, DL_STATS, &adr_formulaire );

		if( gb_mode_vdi_actif == FALSE )
		{
			SET_BIT_W( adr_formulaire[RB_STAT_OFF_VDI].ob_state, OS_DISABLED, 1);
		}

		if( gb_mode_vram_actif == FALSE )
		{
			SET_BIT_W( adr_formulaire[RB_STAT_OFF_VRAM].ob_state, OS_DISABLED, 1);
		}

		if( gb_mode_stram_actif == FALSE )
		{
			SET_BIT_W( adr_formulaire[RB_STAT_OFF_STRM].ob_state, OS_DISABLED, 1);
		}

		if( gb_mode_ttram_actif == FALSE )
		{
			SET_BIT_W( adr_formulaire[RB_STAT_OFF_TTRM].ob_state, OS_DISABLED, 1);
		}

		if( gb_mode_ct60_vram_actif == FALSE )
		{
			SET_BIT_W( adr_formulaire[RB_STAT_CT60_VRM].ob_state, OS_DISABLED, 1);
		}



		/* on d‚select tous les objets du radio bouton */
		SET_BIT_W( (adr_formulaire+RB_STAT_OFF_VDI)->ob_state, OS_SELECTED, 0);
		SET_BIT_W( (adr_formulaire+RB_STAT_OFF_VRAM)->ob_state, OS_SELECTED, 0);
		SET_BIT_W( (adr_formulaire+RB_STAT_OFF_STRM)->ob_state, OS_SELECTED, 0);
		SET_BIT_W( (adr_formulaire+RB_STAT_OFF_TTRM)->ob_state, OS_SELECTED, 0);
		SET_BIT_W( (adr_formulaire+RB_STAT_CT60_VRM)->ob_state, OS_SELECTED, 0);

		/* on select le nouveau bouton */
		SET_BIT_W( (adr_formulaire+offscreen_mode)->ob_state, OS_SELECTED, 1);


	}




	octet_par_frame = PIXEL_ECRAN + PIXEL_ALL_BAR + (PIXEL_BEE*gb_nb_bee);
	octet_par_frame = octet_par_frame * (Fcm_screen.nb_plan/8);
	octet_par_frame = octet_par_frame + (OCTET_MASK_BEE*gb_nb_bee);



	{
		char buffer[16];

		sprintf( buffer,"%ld", octet_par_frame );
		Fcm_set_rsc_string( DL_STATS, TXT_STAT_FRAME, buffer );

		sprintf( buffer,"%d Bee", gb_nb_bee );
		Fcm_set_rsc_string( DL_STATS, TXT_STATS_NB_BEE, buffer );

		sprintf( buffer,"Distance %d", gb_decalage_bee );
		Fcm_set_rsc_string( DL_STATS, TXT_STATS_DECAL, buffer );

	}



	return;


}


#endif   /* ___refresh_rsc_stats___ */


