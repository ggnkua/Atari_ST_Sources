
/* **[Offscreen]**************** */
/* *                           * */
/* * 28/12/2015 MaJ 28/12/2015 * */
/* ***************************** */




#include "fonction/coeur/coeur_define.c"
#include "offscreen_error_code.h"
#include "fonction/graphique/fcm_create_surface.h"
#include  "make_ram_surface.c"




/* prototype */
int32 init_surface_ttram( void );



/* Fonction */
int32 init_surface_ttram( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# init_surface_ttram()"CRLF );
	log_print(FALSE);
	#endif



	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);



	/* **************************************************************** */
	/* Ouverture de l'‚cran                                           * */
	/* **************************************************************** */

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" TT RAM - Cr‚ation ‚cran offscreen"CRLF );
	log_print(FALSE);
	#endif

	/* --------------------------------------------------------------- */
	/* Offscreen                                                       */
	/* --------------------------------------------------------------- */
	{
		int32 reponse;

		reponse = make_ram_surface	(
										&surface_offscreen_ttram,
										&mfdb_offscreen_ttram,
										Fcm_screen.nb_plan,
										SCREEN_WIDTH,
										SCREEN_HEIGHT,
										MX_TTRAM
									);

		if( reponse != 0 )
		{
			return( reponse );
		}

	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);





	/* --------------------------------------------------------------- */
	/* Image de fond                                                   */
	/* --------------------------------------------------------------- */
	{
		int32 reponse;

		reponse = make_ram_surface	(
										&surface_fond_ttram,
										&mfdb_fond_ttram,
										Fcm_screen.nb_plan,
										SCREEN_WIDTH,
										SCREEN_HEIGHT,
										MX_TTRAM
									);

		if( reponse != 0 )
		{
			return( reponse );
		}

		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=mfdb_fond_ttram.fd_w-1;
		pxy[3]=mfdb_fond_ttram.fd_h-1;
		pxy[4]=0;
		pxy[5]=0;
		pxy[6]=pxy[2];
		pxy[7]=pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  &mfdb_fond, &mfdb_fond_ttram);

/*		pxy[4]=10;
		pxy[5]=10;
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  &mfdb_fond_ttram, &Fcm_mfdb_ecran);
*/



	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);










	/* ------------------------------- */
	/* -             BAR             - */
	/* ------------------------------- */
	{
		int32 reponse;
		int16 bar;


		for( bar=0; bar<NB_BAR; bar++)
		{

			reponse = make_ram_surface	(
											&surface_bar_ttram[bar],
											&mfdb_bar_ttram[bar],
											Fcm_screen.nb_plan,
											BAR_WIDTH,
											BAR_HEIGHT,
											MX_TTRAM
										);

			if( reponse != 0 )
			{
				return( reponse );
			}


		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=mfdb_bar_ttram[bar].fd_w-1;
		pxy[3]=mfdb_bar_ttram[bar].fd_h-1;
		pxy[4]=0;
		pxy[5]=0;
		pxy[6]=pxy[2];
		pxy[7]=pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  &mfdb_bar[bar], &mfdb_bar_ttram[bar]);

/*		pxy[4]=10;
		pxy[5]=220+(pxy[3]*bar);
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  &mfdb_bar_ttram[bar], &Fcm_mfdb_ecran);
*/

		}

	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);












	/* ------------------------------- */
	/* -             BEE             - */
	/* ------------------------------- */
	{
		int32 reponse;



		reponse = make_ram_surface	(
										&surface_bee_ttram,
										&mfdb_bee_ttram,
										Fcm_screen.nb_plan,
										BEE_WIDTH,
										BEE_HEIGHT,
										MX_TTRAM
									);

		if( reponse != 0 )
		{
			return( reponse );
		}


		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=mfdb_bee_ttram.fd_w-1;
		pxy[3]=mfdb_bee_ttram.fd_h-1;
		pxy[4]=0;
		pxy[5]=0;
		pxy[6]=pxy[2];
		pxy[7]=pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  &mfdb_bee, &mfdb_bee_ttram);

/*		pxy[4]=10;
		pxy[5]=40;
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  &mfdb_bee_ttram, &Fcm_mfdb_ecran);
*/

	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);




	{
		int32 reponse;


		reponse = make_ram_surface	(
										&surface_bee_mask_ttram,
										&mfdb_bee_mask_ttram,
										1,
										BEE_WIDTH,
										BEE_HEIGHT,
										MX_TTRAM
									);

		if( reponse != 0 )
		{
			return( reponse );
		}

		memcpy( mfdb_bee_mask_ttram.fd_addr, mfdb_bee_mask.fd_addr, OCTET_MASK_BEE );

		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=mfdb_bee_mask_ttram.fd_w-1;
		pxy[3]=mfdb_bee_mask_ttram.fd_h-1;
/*		pxy[4]=0;
		pxy[5]=0;
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];

		vrt_cpyfm(vdihandle,2,pxy, &mfdb_bee_mask, &mfdb_bee_mask_stram, mask_couleur);*/
/*
		pxy[4]=30;
		pxy[5]=100;
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];

		vrt_cpyfm(vdihandle,2,pxy, &mfdb_bee_mask_ttram, &Fcm_mfdb_ecran, mask_couleur);

		pxy[4]=100;
		pxy[5]=100;
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];

		vrt_cpyfm(vdihandle,2,pxy, &mfdb_bee_mask, &Fcm_mfdb_ecran, mask_couleur);
*/

	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);







	return 0L;


}

