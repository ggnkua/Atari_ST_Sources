/* **[Offscreen]**************** */
/* *                           * */
/* * 25/12/2015 MaJ 05/01/2016 * */
/* ***************************** */




#include "fonction/coeur/coeur_define.c"
#include "offscreen_error_code.h"
#include "fonction/graphique/fcm_create_surface.h"
#include  "make_ram_surface.c"




/* prototype */
int32 init_surface_stram( void );



/* Fonction */
int32 init_surface_stram( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# init_surface_stram()"CRLF );
	log_print(FALSE);
	#endif



	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);



	/* **************************************************************** */
	/* Ouverture de l'‚cran                                           * */
	/* **************************************************************** */

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" ST RAM - Cr‚ation ‚cran offscreen"CRLF );
	log_print(FALSE);
	#endif

	/* --------------------------------------------------------------- */
	/* Offscreen                                                       */
	/* --------------------------------------------------------------- */
	{
		int32 reponse;

		reponse = make_ram_surface	(
										&surface_offscreen_stram,
										&mfdb_offscreen_stram,
										Fcm_screen.nb_plan,
										SCREEN_WIDTH,
										SCREEN_HEIGHT,
										MX_STRAM
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
										&surface_fond_stram,
										&mfdb_fond_stram,
										Fcm_screen.nb_plan,
										SCREEN_WIDTH,
										SCREEN_HEIGHT,
										MX_STRAM
									);

		if( reponse != 0 )
		{
			return( reponse );
		}

		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=mfdb_fond_stram.fd_w-1;
		pxy[3]=mfdb_fond_stram.fd_h-1;
		pxy[4]=0;
		pxy[5]=0;
		pxy[6]=pxy[2];
		pxy[7]=pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  &mfdb_fond, &mfdb_fond_stram);

/*		pxy[4]=10;
		pxy[5]=10;
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  &mfdb_fond_stram, &Fcm_mfdb_ecran);
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
											&surface_bar_stram[bar],
											&mfdb_bar_stram[bar],
											Fcm_screen.nb_plan,
											BAR_WIDTH,
											BAR_HEIGHT,
											MX_STRAM
										);

			if( reponse != 0 )
			{
				return( reponse );
			}


		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=mfdb_bar_stram[bar].fd_w-1;
		pxy[3]=mfdb_bar_stram[bar].fd_h-1;
		pxy[4]=0;
		pxy[5]=0;
		pxy[6]=pxy[2];
		pxy[7]=pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  &mfdb_bar[bar], &mfdb_bar_stram[bar]);

/*		pxy[4]=10;
		pxy[5]=220+(pxy[3]*bar);
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  &mfdb_bar_stram[bar], &Fcm_mfdb_ecran);
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
										&surface_bee_stram,
										&mfdb_bee_stram,
										Fcm_screen.nb_plan,
										BEE_WIDTH,
										BEE_HEIGHT,
										MX_STRAM
									);

		if( reponse != 0 )
		{
			return( reponse );
		}


		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=mfdb_bee_stram.fd_w-1;
		pxy[3]=mfdb_bee_stram.fd_h-1;
		pxy[4]=0;
		pxy[5]=0;
		pxy[6]=pxy[2];
		pxy[7]=pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  &mfdb_bee, &mfdb_bee_stram);

/*		pxy[4]=10;
		pxy[5]=40;
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  &mfdb_bee_stram, &Fcm_mfdb_ecran);
*/

	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);




	{
		int32 reponse;


		reponse = make_ram_surface	(
										&surface_bee_mask_stram,
										&mfdb_bee_mask_stram,
										1,
										BEE_WIDTH,
										BEE_HEIGHT,
										MX_STRAM
									);

		if( reponse != 0 )
		{
			return( reponse );
		}

		memcpy( mfdb_bee_mask_stram.fd_addr, mfdb_bee_mask.fd_addr, OCTET_MASK_BEE );

/*		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=mfdb_bee_mask_stram.fd_w-1;
		pxy[3]=mfdb_bee_mask_stram.fd_h-1;

		pxy[4]=30;
		pxy[5]=100;
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];

		vrt_cpyfm(vdihandle,2,pxy, &mfdb_bee_mask_stram, &Fcm_mfdb_ecran, mask_couleur);

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

