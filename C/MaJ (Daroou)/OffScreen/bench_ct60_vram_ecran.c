/* **[Offscreen]**************** */
/* *                           * */
/* * 31/01/2016 MaJ 07/02/2016 * */
/* ***************************** */



#include	"replace_fenetre_test.c"



/* prototype */
void bench_ct60_vram_ecran( void );



/* Fonction */
void bench_ct60_vram_ecran( void )
{


	replace_fenetre_test();




	{
		OBJECT	*adr_formulaire;
		char buffer[16];

		strcpy( buffer, "Test...");
		Fcm_set_rsc_string( DL_BENCH, BC_CT60_ECR_R, buffer );

		rsrc_gaddr( R_TREE, DL_BENCH, &adr_formulaire );
		Fcm_objet_draw( adr_formulaire, h_win[W_BENCH], BC_CT60_ECR_R, FCM_WU_BLOCK );
	}



	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF, NULL);




	{
		int16	winx,winy,dummy;

		wind_get(h_win[W_OFFSCREEN],WF_WORKXYWH,&winx,&winy,&dummy,&dummy);

		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=SCREEN_WIDTH-1;
		pxy[3]=SCREEN_HEIGHT-1;

		pxy[4]=winx;
		pxy[5]=winy;
		pxy[6]=winx+SCREEN_WIDTH-1;
		pxy[7]=winy+SCREEN_HEIGHT-1;
	}




	{
		uint32 timer_start;
		uint32 timer=0;
		uint32 nb_boucle=BENCH_NB_BOUCLE_START;


		do
		{
			uint32 bcl;

			timer_start=Fcm_get_timer();

			for( bcl=nb_boucle; bcl>0; bcl-- )
			{
				vro_cpyfm(vdihandle, 3, pxy,  &mfdb_fond_ct60_vram, &Fcm_mfdb_ecran);
			}

			timer=Fcm_get_timer()-timer_start;

/*{
	char texte[256];

	sprintf(texte,"nb_boucle=%d timer=%ld (%ld)", nb_boucle, timer, timer_start );
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


		gb_stats_ct60_vram_ecran=(((BENCH_TAILLE_ECRAN*nb_boucle)/timer)*200)/1048576;

	}



	graf_mouse(M_ON, NULL);
	wind_update(END_UPDATE);



	{
		OBJECT	*adr_formulaire;
		char buffer[16];

		sprintf( buffer, "%5ld Mo/s", gb_stats_ct60_vram_ecran);
		Fcm_set_rsc_string( DL_BENCH, BC_CT60_ECR_R, buffer );

		rsrc_gaddr( R_TREE, DL_BENCH, &adr_formulaire );
		Fcm_objet_draw( adr_formulaire, h_win[W_BENCH], BC_CT60_ECR_R, FCM_WU_BLOCK );
	}


	return;


}

