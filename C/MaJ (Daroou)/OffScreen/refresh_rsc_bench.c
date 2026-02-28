/* **[Offscreen]**************** */
/* *                           * */
/* * 31/12/2015 MaJ 31/01/2016 * */
/* ***************************** */




#ifndef ___refresh_rsc_bench___
#define ___refresh_rsc_bench___




/* prototype */
void refresh_rsc_bench( void );




/* Fonction */
void refresh_rsc_bench( void )
{



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# refresh_rsc_bench()"CRLF );
	log_print( FALSE );
	#endif




/*{
	char texte[256];

	sprintf(texte,"refresh_rsc_bench  " );
	v_gtext(vdihandle,41*8,4*16,texte);
}*/

	{
		OBJECT *adr_formulaire;

		rsrc_gaddr( R_TREE, DL_BENCH, &adr_formulaire );

		if( gb_mode_vdi_actif == FALSE )
		{
			SET_BIT_W( adr_formulaire[BC_OFF_ECR].ob_state, OS_DISABLED, 1);
			SET_BIT_W( adr_formulaire[BC_OFF_OFF].ob_state, OS_DISABLED, 1);
			SET_BIT_W( adr_formulaire[BC_OFF_OFF2].ob_state, OS_DISABLED, 1);
		}
		if( gb_mode_vram_actif == FALSE )
		{
			SET_BIT_W( adr_formulaire[BC_ECR_ECR].ob_state, OS_DISABLED, 1);
		}

		if( gb_mode_stram_actif == FALSE )
		{
			SET_BIT_W( adr_formulaire[BC_STRAM_ECR].ob_state, OS_DISABLED, 1);
			SET_BIT_W( adr_formulaire[BC_STRAM_STRAM].ob_state, OS_DISABLED, 1);
		}

		if( gb_mode_ttram_actif == FALSE )
		{
			SET_BIT_W( adr_formulaire[BC_TTRAM_ECR].ob_state, OS_DISABLED, 1);
			SET_BIT_W( adr_formulaire[BC_TTRAM_TTRAM].ob_state, OS_DISABLED, 1);
		}

		if( gb_mode_ct60_vram_actif == FALSE )
		{
			SET_BIT_W( adr_formulaire[BC_CT060_ECR].ob_state, OS_DISABLED, 1);
			SET_BIT_W( adr_formulaire[BC_CT060_CT060].ob_state, OS_DISABLED, 1);
		}


	}



	{
		char buffer[16];


		sprintf( buffer,"%5ld Mo/s", gb_stats_stram_ecran );
		Fcm_set_rsc_string( DL_BENCH, BC_STRAM_ECR_R, buffer );

		sprintf( buffer,"%5ld Mo/s", gb_stats_ttram_ecran );
		Fcm_set_rsc_string( DL_BENCH, BC_TTRAM_ECR_R, buffer );

		sprintf( buffer,"%5ld Mo/s", gb_stats_vdi_ecran );
		Fcm_set_rsc_string( DL_BENCH, BC_OFF_ECR_R, buffer );

		sprintf( buffer,"%5ld Mo/s", gb_stats_ct60_vram_ecran );
		Fcm_set_rsc_string( DL_BENCH, BC_CT60_ECR_R, buffer );



		sprintf( buffer,"%5ld Mo/s", gb_stats_stram_stram );
		Fcm_set_rsc_string( DL_BENCH, BC_STRAM_STRAM_R, buffer );

		sprintf( buffer,"%5ld Mo/s", gb_stats_ttram_ttram );
		Fcm_set_rsc_string( DL_BENCH, BC_TTRAM_TTRAM_R, buffer );

		sprintf( buffer,"%5ld Mo/s", gb_stats_vdi_vdi );
		Fcm_set_rsc_string( DL_BENCH, BC_OFF_OFF_R, buffer );

		sprintf( buffer,"%5ld Mo/s", gb_stats_vdi_vdi2 );
		Fcm_set_rsc_string( DL_BENCH, BC_OFF_OFF2_R, buffer );

		sprintf( buffer,"%5ld Mo/s", gb_stats_ecran_ecran );
		Fcm_set_rsc_string( DL_BENCH, BC_ECR_ECR_R, buffer );

		sprintf( buffer,"%5ld Mo/s", gb_stats_ct60_ct60_vram );
		Fcm_set_rsc_string( DL_BENCH, BC_CT60_CT60_R, buffer );
	}


	return;


}


#endif   /* ___refresh_rsc_bench___ */

