/* **[Offscreen]**************** */
/* *                           * */
/* * 01/01/2016 MaJ 02/01/2016 * */
/* ***************************** */



#include "replace_fenetre_vram.c"



/* prototype */
void bench_ecran_ecran( void );



/* Fonction */
void bench_ecran_ecran( void )
{


	replace_fenetre_vram();


	{
		OBJECT	*adr_formulaire;
		char buffer[16];

		strcpy( buffer, "Test...");
		Fcm_set_rsc_string( DL_BENCH, BC_ECR_ECR_R, buffer );

		rsrc_gaddr( R_TREE, DL_BENCH, &adr_formulaire );
		Fcm_objet_draw( adr_formulaire, h_win[W_BENCH], BC_ECR_ECR_R, FCM_WU_BLOCK );
	}


	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF, NULL);


	{
		int16	winx,winy,dummy;

		wind_get(h_win[W_SPRITE_OFFSCREEN],WF_WORKXYWH,&winx,&winy,&dummy,&dummy);

		pxy[0]=winx;
		pxy[1]=winy+SCREEN_HEIGHT;
		pxy[2]=pxy[0]+SCREEN_WIDTH-1;
		pxy[3]=pxy[1]+SCREEN_HEIGHT-1;

		pxy[4]=winx;
		pxy[5]=winy;
		pxy[6]=pxy[0]+SCREEN_WIDTH-1;
		pxy[7]=pxy[1]+SCREEN_HEIGHT-1;

		vro_cpyfm(vdihandle, 3, pxy,  &Fcm_mfdb_ecran, &Fcm_mfdb_ecran);


		pxy[0]=winx;
		pxy[1]=winy;
		pxy[2]=winx+SCREEN_WIDTH-1;
		pxy[3]=winy+SCREEN_HEIGHT-1;


		wind_get(h_win[W_OFFSCREEN],WF_WORKXYWH,&winx,&winy,&dummy,&dummy);

		pxy[4]=winx;
		pxy[5]=winy;
		pxy[6]=winx+SCREEN_WIDTH-1;
		pxy[7]=winy+SCREEN_HEIGHT-1;
	}


	{
		uint32 timer_start;
		uint32 timer=0;
		uint32 nb_boucle = BENCH_NB_BOUCLE_START;

		do
		{
			uint32 bcl;

			timer_start=Fcm_get_timer();

			for( bcl=nb_boucle; bcl>0; bcl-- )
			{
				vro_cpyfm(vdihandle, 3, pxy,  &Fcm_mfdb_ecran, &Fcm_mfdb_ecran);
			}

			timer=Fcm_get_timer()-timer_start;

/*{
	char texte[256];

	sprintf(texte,"nb_boucle=%ld timer=%ld (%ld) offscreenhandle=%d  ", nb_boucle, timer, timer_start, offscreenhandle );
	v_gtext(vdihandle,61*8,3*16,texte);
}*/

			if( timer<DELAI_VALID_BENCH )
			{
				if( timer==0 )
				{
					nb_boucle = nb_boucle + BENCH_NB_BOUCLE_START;
				}
				else
				{
					nb_boucle = nb_boucle + (nb_boucle * (DELAI_VALID_BENCH/timer) );
				}
			}


		} while( timer<DELAI_VALID_BENCH );


		gb_stats_ecran_ecran=(((BENCH_TAILLE_ECRAN*nb_boucle)/timer)*200)/1048576;

	}


	graf_mouse(M_ON, NULL);
	wind_update(END_UPDATE);


	{
		OBJECT	*adr_formulaire;
		char buffer[16];

		sprintf( buffer, "%5ld Mo/s", gb_stats_ecran_ecran );
		Fcm_set_rsc_string( DL_BENCH, BC_ECR_ECR_R, buffer );

		rsrc_gaddr( R_TREE, DL_BENCH, &adr_formulaire );
		Fcm_objet_draw( adr_formulaire, h_win[W_BENCH], BC_ECR_ECR_R, FCM_WU_BLOCK );
	}


	if( offscreen_mode!=RB_STAT_OFF_VRAM )
	{
		wind_close ( h_win[W_SPRITE_OFFSCREEN] );
		wind_delete( h_win[W_SPRITE_OFFSCREEN] );
		h_win[W_SPRITE_OFFSCREEN]=FCM_NO_OPEN_WINDOW;

		Fcm_gestion_aes_message();
	}


	return;


}

