/* **[PUPUL]******************** */
/* *                           * */
/* * 20/08/2014 MaJ 26/02/2015 * */
/* ***************************** */



/* prototype */
void libere_surface( void );



/* Fonction */
void libere_surface( void )
{


	Fcm_free_surface( &surface_framebuffer );
	Fcm_free_surface( &surface_fond_ecran );
	

	Fcm_free_surface( &surface_demons_sprite[SPRITE_DEMON1] );
	Fcm_free_surface( &surface_demons_sprite[SPRITE_DEMON2] );
	Fcm_free_surface( &surface_demons_sprite[SPRITE_DEMON3] );
	Fcm_free_surface( &surface_demons_sprite[SPRITE_MORPH1] );
	Fcm_free_surface( &surface_demons_sprite[SPRITE_MORPH2] );
	Fcm_free_surface( &surface_demons_sprite[SPRITE_BALL1] );


	Fcm_free_surface( &surface_demons_mask[SPRITE_DEMON1] );
	Fcm_free_surface( &surface_demons_mask[SPRITE_DEMON2] );
	Fcm_free_surface( &surface_demons_mask[SPRITE_DEMON3] );
	Fcm_free_surface( &surface_demons_mask[SPRITE_MORPH1] );
	Fcm_free_surface( &surface_demons_mask[SPRITE_MORPH2] );
	Fcm_free_surface( &surface_demons_mask[SPRITE_BALL1] );


	Fcm_free_surface( &surface_logo_equinox_mask );
	Fcm_free_surface( &surface_logo_renaissance_mask );


	Fcm_free_surface( &surface_barre_scrolltext );

	Fcm_free_surface( &surface_fond_scrolltext );

	Fcm_free_surface( &surface_fonte_texte );
	Fcm_free_surface( &surface_fonte_texte_mask );


	{
		int16 damier;
		for(damier=0; damier<NB_DAMIER; damier++)
		{
			Fcm_free_surface( &surface_damier[damier] );
		}
	}



	return;


}

