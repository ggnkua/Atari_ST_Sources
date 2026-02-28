/* **[Offscreen]**************** */
/* *                           * */
/* * 30/12/2015 MaJ 06/02/2016 * */
/* ***************************** */




#ifndef ___refresh_rsc_adresse___
#define ___refresh_rsc_adresse___




/* prototype */
void refresh_rsc_adresse( void );




/* Fonction */
void refresh_rsc_adresse( void )
{

	char buffer[32];

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# refresh_rsc_adresse()"CRLF );
	log_print( FALSE );
	#endif

	{
		OBJECT *adr_popup;

		rsrc_gaddr( R_TREE, POPUP_ADRESSE, &adr_popup );

		Fcm_set_rsc_string( DL_ADRESSE, AD_POPUP, adr_popup[rsc_adresse_view_mode].ob_spec.tedinfo->te_ptext );
		Fcm_set_rsc_string( DL_ADRESSE, AD_TITRE, adr_popup[rsc_adresse_view_mode].ob_spec.tedinfo->te_ptext );
	}


	if( rsc_adresse_view_mode==RSC_VIEW_MODE_ST_RAM )
	{
		int16 idx;

/*		strcpy( buffer,"Offscreen ST RAM" );
		Fcm_set_rsc_string( DL_ADRESSE, AD_TITRE, buffer );*/


		sprintf( buffer,"$%08lx ST RAM", surface_offscreen_stram.adresse_buffer );
		Fcm_set_rsc_string( DL_ADRESSE, AD_OFFSCREEN, buffer );

		sprintf( buffer,"$%08lx ST RAM", surface_fond_stram.adresse_buffer );
		Fcm_set_rsc_string( DL_ADRESSE, AD_FOND, buffer );

		for( idx=0; idx<7; idx++)
		{
			sprintf( buffer,"$%08lx ST RAM", surface_bar_stram[idx].adresse_buffer );
			Fcm_set_rsc_string( DL_ADRESSE, (AD_BAR1+(idx*2)), buffer );
		}

		sprintf( buffer,"$%08lx ST RAM", surface_bee_stram.adresse_buffer );
		Fcm_set_rsc_string( DL_ADRESSE, AD_BEE, buffer );

		sprintf( buffer,"$%08lx ST RAM", surface_bee_mask_stram.adresse_buffer );
		Fcm_set_rsc_string( DL_ADRESSE, AD_BEE_MASK, buffer );
	}






	if( rsc_adresse_view_mode==RSC_VIEW_MODE_TT_RAM )
	{
		int16 idx;

/*		strcpy( buffer,"Offscreen TT RAM" );
		Fcm_set_rsc_string( DL_ADRESSE, AD_TITRE, buffer );*/


		sprintf( buffer,"$%08lx TT RAM", surface_offscreen_ttram.adresse_buffer );
		Fcm_set_rsc_string( DL_ADRESSE, AD_OFFSCREEN, buffer );

		sprintf( buffer,"$%08lx TT RAM", surface_fond_ttram.adresse_buffer );
		Fcm_set_rsc_string( DL_ADRESSE, AD_FOND, buffer );

		for( idx=0; idx<7; idx++)
		{
			sprintf( buffer,"$%08lx TT RAM", surface_bar_ttram[idx].adresse_buffer );
			Fcm_set_rsc_string( DL_ADRESSE, (AD_BAR1+(idx*2)), buffer );
		}

		sprintf( buffer,"$%08lx TT RAM", surface_bee_ttram.adresse_buffer );
		Fcm_set_rsc_string( DL_ADRESSE, AD_BEE, buffer );

		sprintf( buffer,"$%08lx TT RAM", surface_bee_mask_ttram.adresse_buffer );
		Fcm_set_rsc_string( DL_ADRESSE, AD_BEE_MASK, buffer );
	}





	if( rsc_adresse_view_mode==RSC_VIEW_MODE_VDI )
	{
		int16 idx;

/*		strcpy( buffer,"Offscreen VDI" );
		Fcm_set_rsc_string( DL_ADRESSE, AD_TITRE, buffer );*/


		if( gb_mode_vdi_actif==FALSE )
		{
			Fcm_set_rsc_string( DL_ADRESSE, AD_OFFSCREEN, "----" );
			Fcm_set_rsc_string( DL_ADRESSE, AD_FOND, "----" );
			for( idx=0; idx<7; idx++)
			{
				Fcm_set_rsc_string( DL_ADRESSE, (AD_BAR1+(idx*2)), "----" );
			}
			Fcm_set_rsc_string( DL_ADRESSE, AD_BEE, "----" );
			Fcm_set_rsc_string( DL_ADRESSE, AD_BEE_MASK, "----" );
		}
		else
		{

			if( surface_offscreen_vdi.adresse_buffer & 0xff000000 )
			{
				sprintf( buffer,"$%08lx TT RAM %3d", surface_offscreen_vdi.adresse_buffer, surface_offscreen_vdi.handle_offscreen );
			}
			else
			{
				sprintf( buffer,"$%08lx ST RAM %3d", surface_offscreen_vdi.adresse_buffer, surface_offscreen_vdi.handle_offscreen );
			}
			Fcm_set_rsc_string( DL_ADRESSE, AD_OFFSCREEN, buffer );


			if( surface_offscreen_vdi.adresse_buffer & 0xff000000 )
			{
				sprintf( buffer,"$%08lx TT RAM %3d", surface_fond.adresse_buffer, surface_fond.handle_offscreen );
			}
			else
			{
				sprintf( buffer,"$%08lx ST RAM %3d", surface_fond.adresse_buffer, surface_fond.handle_offscreen );
			}
			Fcm_set_rsc_string( DL_ADRESSE, AD_FOND, buffer );


			for( idx=0; idx<7; idx++)
			{
				if( surface_offscreen_vdi.adresse_buffer & 0xff000000 )
				{
					sprintf( buffer,"$%08lx TT RAM %3d", surface_bar[idx].adresse_buffer, surface_bar[idx].handle_offscreen );
				}
				else
				{
					sprintf( buffer,"$%08lx ST RAM %3d", surface_bar[idx].adresse_buffer, surface_bar[idx].handle_offscreen );
				}
				Fcm_set_rsc_string( DL_ADRESSE, (AD_BAR1+(idx*2)), buffer );
		}
	

			if( surface_offscreen_vdi.adresse_buffer & 0xff000000 )
			{
				sprintf( buffer,"$%08lx TT RAM %3d", surface_bee.adresse_buffer, surface_bee.handle_offscreen );
			}
			else
			{
				sprintf( buffer,"$%08lx ST RAM %3d", surface_bee.adresse_buffer, surface_bee.handle_offscreen );
			}
			Fcm_set_rsc_string( DL_ADRESSE, AD_BEE, buffer );


			if( surface_offscreen_vdi.adresse_buffer & 0xff000000 )
			{
				sprintf( buffer,"$%08lx TT RAM %3d", surface_bee_mask.adresse_buffer, surface_bee_mask.handle_offscreen );
			}
			else
			{
				sprintf( buffer,"$%08lx ST RAM %3d", surface_bee_mask.adresse_buffer, surface_bee_mask.handle_offscreen );
			}
			Fcm_set_rsc_string( DL_ADRESSE, AD_BEE_MASK, buffer );
		}
	}





	if( rsc_adresse_view_mode==RSC_VIEW_MODE_CT60_VRAM )
	{
		int16 idx;

/*		strcpy( buffer,"CT060 VRAM" );
		Fcm_set_rsc_string( DL_ADRESSE, AD_TITRE, buffer );*/


		if( gb_mode_ct60_vram_actif==FALSE )
		{
			Fcm_set_rsc_string( DL_ADRESSE, AD_OFFSCREEN, "----" );
			Fcm_set_rsc_string( DL_ADRESSE, AD_FOND, "----" );
			for( idx=0; idx<7; idx++)
			{
				Fcm_set_rsc_string( DL_ADRESSE, (AD_BAR1+(idx*2)), "----" );
			}
			Fcm_set_rsc_string( DL_ADRESSE, AD_BEE, "----" );
			Fcm_set_rsc_string( DL_ADRESSE, AD_BEE_MASK, "----" );
		}
		else
		{
			sprintf( buffer,"$%08lx VRAM", (uint32)mfdb_offscreen_ct60_vram.fd_addr );
			Fcm_set_rsc_string( DL_ADRESSE, AD_OFFSCREEN, buffer );

			sprintf( buffer,"$%08lx VRAM", (uint32)mfdb_fond_ct60_vram.fd_addr );
			Fcm_set_rsc_string( DL_ADRESSE, AD_FOND, buffer );

			for( idx=0; idx<7; idx++)
			{
				sprintf( buffer,"$%08lx VRAM", (uint32)mfdb_bar_ct60_vram[idx].fd_addr );
				Fcm_set_rsc_string( DL_ADRESSE, (AD_BAR1+(idx*2)), buffer );
			}

			sprintf( buffer,"$%08lx VRAM", (uint32)mfdb_bee_ct60_vram.fd_addr );
			Fcm_set_rsc_string( DL_ADRESSE, AD_BEE, buffer );

			sprintf( buffer,"$%08lx VRAM", (uint32)mfdb_bee_mask_ct60_vram.fd_addr );
			Fcm_set_rsc_string( DL_ADRESSE, AD_BEE_MASK, buffer );
		}
	}



	return;


}


#endif   /* ___refresh_rsc_adresse___ */

