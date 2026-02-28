/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 17/12/2015 * */
/* ***************************** */




/* prototype */
void init_animation_global( void );



/* Fonction */
void init_animation_global( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# init_animation_global()"CRLF );
	log_print( FALSE );
	#endif



	pf_build_screen = build_screen_vdi;
	*(&mfdb_offscreen) = *(&mfdb_offscreen_vdi);


	if( gb_mode_vdi_actif==FALSE )
	{
		offscreen_mode=RB_STAT_OFF_STRM;

		if( gb_mode_stram_actif==FALSE )
		{
			offscreen_mode=RB_STAT_OFF_TTRM;
		}
	}



/*
	octet_par_frame = PIXEL_ECRAN + PIXEL_BAR + (PIXEL_BEE*gb_nb_bee);
	octet_par_frame = octet_par_frame * (Fcm_screen.nb_plan/8);
	octet_par_frame = octet_par_frame + (OCTET_MASK_BEE*gb_nb_bee);
*/
/*	{
		char buffer[16];

		sprintf( buffer,"%ld", octet_par_frame );
		Fcm_set_rsc_string( DL_STATS, TXT_STAT_FRAME, buffer );
	}*/




	pxy_bee[0]=0;
	pxy_bee[1]=0;
	pxy_bee[2]=BEE_WIDTH-1;
	pxy_bee[3]=BEE_HEIGHT-1;


	pxy_bar[0]=0;
	pxy_bar[1]=0;
	pxy_bar[2]=BAR_WIDTH-1;
	pxy_bar[3]=BAR_HEIGHT-1;

	pxy_bar[4]=0;
	pxy_bar[6]=BAR_WIDTH-1;



	{
		int16 pxy[8];
		int16 idx;


		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=SCREEN_WIDTH-1;
		pxy[3]=SCREEN_HEIGHT-1;

		pxy[4]=0;
		pxy[5]=SCREEN_HEIGHT;
		pxy[6]=SCREEN_WIDTH-1;
		pxy[7]=pxy[5]+SCREEN_HEIGHT-1;

		vro_cpyfm(vdihandle,3,pxy, &mfdb_fond, &mfdb_sprite_offscreen );


		for(idx=0; idx<NB_BAR; idx++)
		{
			pxy[0]=0;
			pxy[1]=0;
			pxy[2]=BAR_WIDTH-1;
			pxy[3]=BAR_HEIGHT-1;

			pxy[4]=0;
			pxy[5]=SCREEN_HEIGHT+SCREEN_HEIGHT+(idx*BAR_HEIGHT);
			pxy[6]=BAR_WIDTH-1;
			pxy[7]=pxy[5]+BAR_HEIGHT-1;

			vro_cpyfm(vdihandle,3,pxy, &mfdb_bar[idx], &mfdb_sprite_offscreen );

		}


			pxy[0]=0;
			pxy[1]=0;
			pxy[2]=BEE_WIDTH-1;
			pxy[3]=BEE_HEIGHT-1;

			pxy[4]=0;
			pxy[5]=SCREEN_HEIGHT+SCREEN_HEIGHT+(7*BAR_HEIGHT);
			pxy[6]=BEE_WIDTH-1;
			pxy[7]=pxy[5]+BEE_HEIGHT-1;

			vro_cpyfm(vdihandle,3,pxy, &mfdb_bee, &mfdb_sprite_offscreen );

/*			pxy[0]=0;
			pxy[1]=0;
			pxy[2]=BEE_WIDTH-1;
			pxy[3]=BEE_HEIGHT-1;

			pxy[4]=BEE_WIDTH-1;
			pxy[5]=SCREEN_HEIGHT+SCREEN_HEIGHT+(7*BAR_HEIGHT);
			pxy[6]=BEE_WIDTH+BEE_WIDTH-1;
			pxy[7]=pxy[5]+BEE_HEIGHT-1;

			vrt_cpyfm(vdihandle,1,pxy, &mfdb_bee_mask, &mfdb_sprite_offscreen, mask_couleur );
*/


	}









	return;


}

