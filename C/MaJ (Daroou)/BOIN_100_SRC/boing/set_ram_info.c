/* **[Boing]******************** */
/* *                           * */
/* * 20/02/2024 MaJ 20/02/2024 * */
/* ***************************** */


void set_ram_info( void );




/* Fonction */
void set_ram_info( void )
{
	char bufdata[16];


	FCM_LOG_PRINT("* set_ram_info()");

	/* liste des buffers, adr ram, type ram */


	/* Framebuffer */
	sprintf( bufdata, "$%08lx", surface_framebuffer.adresse_malloc );
	Fcm_set_rsc_string( DL_RAM, RAM_LIGNE1+1, bufdata );

	sprintf( bufdata, "%3d", surface_framebuffer.ram_type );
	Fcm_set_rsc_string( DL_RAM, RAM_LIGNE1+2, bufdata );


	/* Fond */
	sprintf( bufdata, "$%08lx", surface_fond_ecran.adresse_malloc );
	Fcm_set_rsc_string( DL_RAM, RAM_LIGNE1+3+1, bufdata );

	sprintf( bufdata, "%3d", surface_fond_ecran.ram_type );
	Fcm_set_rsc_string( DL_RAM, RAM_LIGNE1+3+2, bufdata );


	/* Boing 1-7 */
	{
		int cpt=0;
		int16 idx;
		
		for( idx=RAM_LIGNE1+3+3; cpt<7; idx=idx+6)
		{
			/* boing x adresse */
			sprintf( bufdata, "$%08lx", surface_boing_ball[cpt].adresse_malloc );
			Fcm_set_rsc_string( DL_RAM, idx+1, bufdata );
			/* boing x type RAM */
			sprintf( bufdata, "%3d", surface_boing_ball[cpt].ram_type );
			Fcm_set_rsc_string( DL_RAM, idx+2, bufdata );

			/* boing mask x adresse */
			sprintf( bufdata, "$%08lx", surface_boing_ball_mask[cpt].adresse_malloc );
			Fcm_set_rsc_string( DL_RAM, idx+4, bufdata );
			/* boing mask x type RAM */
			sprintf( bufdata, "%3d", surface_boing_ball_mask[cpt].ram_type );
			Fcm_set_rsc_string( DL_RAM, idx+5, bufdata );

			cpt++;
		}
	}


	/* ombre */
	sprintf( bufdata, "$%08lx", surface_boing_ombre_mask.adresse_malloc );
	Fcm_set_rsc_string( DL_RAM, RAM_LIGNE_OMBRE+1, bufdata );

	sprintf( bufdata, "%3d", surface_boing_ombre_mask.ram_type );
	Fcm_set_rsc_string( DL_RAM, RAM_LIGNE_OMBRE+2, bufdata );


	return;


}

