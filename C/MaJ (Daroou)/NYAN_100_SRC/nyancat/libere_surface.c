/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 24/05/2018 * */
/* ***************************** */



/* Fonction */
void libere_surface( void )
{

	Fcm_free_surface( &surface_fond_ecran );

	Fcm_free_surface( &surface_framebuffer );


	{
		int16 index_surface;

		for( index_surface=0; index_surface<6; index_surface++ )
		{
			Fcm_free_surface( &surface_nyancat_sprite[index_surface] );
			Fcm_free_surface( &surface_nyancat_mask[index_surface] );
			Fcm_free_surface( &surface_star_mask[index_surface] );
		}
	}


	Fcm_free_surface( &surface_arcenciel[ARCENCIEL_UP] );
	Fcm_free_surface( &surface_arcenciel_mask[ARCENCIEL_UP] );

	Fcm_free_surface( &surface_arcenciel[ARCENCIEL_DOWN] );
	Fcm_free_surface( &surface_arcenciel_mask[ARCENCIEL_DOWN] );



	Fcm_free_surface( &surface_mask_font );
	Fcm_free_surface( &surface_font );



	return;


}

