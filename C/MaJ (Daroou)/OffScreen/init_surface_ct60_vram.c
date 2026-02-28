/* **[Offscreen]**************** */
/* *                           * */
/* * 31/01/2016 MaJ 31/01/2016 * */
/* ***************************** */




#include "fonction/coeur/coeur_define.c"
#include "fonction/graphique/Fcm_check_ct60_vram.c"

#include "offscreen_error_code.h"




/* prototype */
int32 init_surface_ct60_vram( void );




/* Fonction */
int32 init_surface_ct60_vram( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# init_surface_ct60_vram()"CRLF );
	log_print(FALSE);
	#endif



	/* Ct60_vram disponible ? */
	#ifndef CT60_VRAM_IN_TTRAM
	if( Fcm_check_ct60_vram( &gb_vram_free ) != 0 )
	{
		return(-1);
	}
	#endif



	/* ******************** */
	/* Ct60_vram disponible */
	/* ******************** */
	{
		int32 size_vram;
		uint32 adresse_buffer;


		/* Nombre d'octet n‚cessaire */
		size_vram = (PIXEL_ECRAN + PIXEL_ECRAN + PIXEL_ALL_BAR + PIXEL_BEE) * (Fcm_screen.nb_plan/8);
		size_vram = size_vram + OCTET_MASK_BEE;

		/* Multiple de 256 */
		size_vram = (size_vram + 255) & 0xffffff00;


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"# Ram n‚cessaire: %ld octets"CRLF, size_vram );
		log_print(FALSE);
		#endif


		#ifndef CT60_VRAM_IN_TTRAM
		gb_adresse_buffer_ct60_vram = (uint32)ct60_vmalloc(0, size_vram);
		#else
		gb_adresse_buffer_ct60_vram = (uint32)Fcm_reserve_ram(size_vram, MX_TTRAM);
		#endif


		if( gb_adresse_buffer_ct60_vram==0 )
		{
			return(-1);
		}


		/* ecran de travail */
		adresse_buffer = gb_adresse_buffer_ct60_vram;

		mfdb_offscreen_ct60_vram.fd_addr    = (void *)adresse_buffer;
		mfdb_offscreen_ct60_vram.fd_w       = SCREEN_WIDTH;
		mfdb_offscreen_ct60_vram.fd_h       = SCREEN_HEIGHT;
		mfdb_offscreen_ct60_vram.fd_wdwidth = (SCREEN_WIDTH+15)/16;
		mfdb_offscreen_ct60_vram.fd_stand   = 0;
		mfdb_offscreen_ct60_vram.fd_nplanes = Fcm_screen.nb_plan;
		mfdb_offscreen_ct60_vram.fd_r1      = 0;
		mfdb_offscreen_ct60_vram.fd_r2      = 0;
		mfdb_offscreen_ct60_vram.fd_r3      = 0;


		/* fond */
		adresse_buffer = adresse_buffer + (PIXEL_ECRAN*OCTET_PAR_PIXEL);

		mfdb_fond_ct60_vram.fd_addr    = (void *)adresse_buffer;
		mfdb_fond_ct60_vram.fd_w       = SCREEN_WIDTH;
		mfdb_fond_ct60_vram.fd_h       = SCREEN_HEIGHT;
		mfdb_fond_ct60_vram.fd_wdwidth = (SCREEN_WIDTH+15)/16;
		mfdb_fond_ct60_vram.fd_stand   = 0;
		mfdb_fond_ct60_vram.fd_nplanes = Fcm_screen.nb_plan;
		mfdb_fond_ct60_vram.fd_r1      = 0;
		mfdb_fond_ct60_vram.fd_r2      = 0;
		mfdb_fond_ct60_vram.fd_r3      = 0;


		/* bar */
		adresse_buffer = adresse_buffer + (PIXEL_ECRAN*OCTET_PAR_PIXEL);

		{
			int16 idx_bar;

			for( idx_bar=0; idx_bar<NB_BAR; idx_bar++ )
			{
				mfdb_bar_ct60_vram[idx_bar].fd_addr    = (void *)adresse_buffer;
				mfdb_bar_ct60_vram[idx_bar].fd_w       = BAR_WIDTH;
				mfdb_bar_ct60_vram[idx_bar].fd_h       = BAR_HEIGHT;
				mfdb_bar_ct60_vram[idx_bar].fd_wdwidth = (BAR_WIDTH+15)/16;
				mfdb_bar_ct60_vram[idx_bar].fd_stand   = 0;
				mfdb_bar_ct60_vram[idx_bar].fd_nplanes = Fcm_screen.nb_plan;
				mfdb_bar_ct60_vram[idx_bar].fd_r1      = 0;
				mfdb_bar_ct60_vram[idx_bar].fd_r2      = 0;
				mfdb_bar_ct60_vram[idx_bar].fd_r3      = 0;

				adresse_buffer = adresse_buffer + (PIXEL_ONE_BAR*OCTET_PAR_PIXEL);
			}
		}


		/* Bee */
		mfdb_bee_ct60_vram.fd_addr    = (void *)adresse_buffer;
		mfdb_bee_ct60_vram.fd_w       = BEE_WIDTH;
		mfdb_bee_ct60_vram.fd_h       = BEE_HEIGHT;
		mfdb_bee_ct60_vram.fd_wdwidth = (BEE_WIDTH+15)/16;
		mfdb_bee_ct60_vram.fd_stand   = 0;
		mfdb_bee_ct60_vram.fd_nplanes = Fcm_screen.nb_plan;
		mfdb_bee_ct60_vram.fd_r1      = 0;
		mfdb_bee_ct60_vram.fd_r2      = 0;
		mfdb_bee_ct60_vram.fd_r3      = 0;


		/* Bee mask */
		adresse_buffer = adresse_buffer + (PIXEL_BEE*OCTET_PAR_PIXEL);

		mfdb_bee_mask_ct60_vram.fd_addr    = (void *)adresse_buffer;
		mfdb_bee_mask_ct60_vram.fd_w       = BEE_WIDTH;
		mfdb_bee_mask_ct60_vram.fd_h       = BEE_HEIGHT;
		mfdb_bee_mask_ct60_vram.fd_wdwidth = (BEE_WIDTH+15)/16;
		mfdb_bee_mask_ct60_vram.fd_stand   = 0;
		mfdb_bee_mask_ct60_vram.fd_nplanes = 1;
		mfdb_bee_mask_ct60_vram.fd_r1      = 0;
		mfdb_bee_mask_ct60_vram.fd_r2      = 0;
		mfdb_bee_mask_ct60_vram.fd_r3      = 0;

	}


	/* ***************** */
	/* Copie des sprites */
	/* ***************** */
	{
		int16 pxy[8];
		int16 idx;


		/* fond */
		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=SCREEN_WIDTH-1;
		pxy[3]=SCREEN_HEIGHT-1;

		pxy[4]=0;
		pxy[5]=0;
		pxy[6]=SCREEN_WIDTH-1;
		pxy[7]=SCREEN_HEIGHT-1;

		vro_cpyfm(vdihandle,3,pxy, &mfdb_fond, &mfdb_fond_ct60_vram );



		/* bar */
		for(idx=0; idx<NB_BAR; idx++)
		{
			pxy[0]=0;
			pxy[1]=0;
			pxy[2]=BAR_WIDTH-1;
			pxy[3]=BAR_HEIGHT-1;

			pxy[4]=0;
			pxy[5]=0;
			pxy[6]=BAR_WIDTH-1;
			pxy[7]=BAR_HEIGHT-1;

			vro_cpyfm(vdihandle,3,pxy, &mfdb_bar[idx], &mfdb_bar_ct60_vram[idx] );
		}


		/* bee */
		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=BEE_WIDTH-1;
		pxy[3]=BEE_HEIGHT-1;

		pxy[4]=0;
		pxy[5]=0;
		pxy[6]=BEE_WIDTH-1;
		pxy[7]=BEE_HEIGHT-1;

		vro_cpyfm(vdihandle,3,pxy, &mfdb_bee, &mfdb_bee_ct60_vram );
/*		vro_cpyfm(vdihandle,3,pxy, &mfdb_bee_ct60_vram, &Fcm_mfdb_ecran );*/


		/* bee mask */
		memcpy( mfdb_bee_mask_ct60_vram.fd_addr, mfdb_bee_mask.fd_addr, OCTET_MASK_BEE );

/*		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=BEE_WIDTH-1;
		pxy[3]=BEE_HEIGHT-1;

		pxy[4]=0;
		pxy[5]=100;
		pxy[6]=BEE_WIDTH-1;
		pxy[7]=100+BEE_HEIGHT-1;

		vrt_cpyfm(vdihandle,2,pxy, &mfdb_bee_mask_ct60_vram, &Fcm_mfdb_ecran, mask_couleur );
*/
	}




	return 0L;


}

