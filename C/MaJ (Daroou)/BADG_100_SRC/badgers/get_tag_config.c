/* **[Badgers]****************** */
/* *                           * */
/* * 20/09/2015 MaJ 14/11/2023 * */
/* ***************************** */

extern int16 Fcm_image_cache_actif;
extern char  Fcm_chemin_image_cache[FCM_TAILLE_CHEMIN];



void get_tag_config( const char *pt_fichier_config )
{
	
	FCM_LOG_PRINT1( CRLF"* get_tag_config(%p) - Local Application ", pt_fichier_config );


	/* Activation cache */
	Fcm_image_cache_actif = Fcm_get_tag_booleen( "CHECK_CACHEIMG=", pt_fichier_config, FALSE );
	FCM_LOG_PRINT1( "  Fcm_image_cache_actif=%d", Fcm_image_cache_actif );

	/* Chemin cache */
	Fcm_get_tag_string( "CHECK_PATHCACHE=", pt_fichier_config, Fcm_chemin_image_cache, FCM_TAILLE_CHEMIN );
	FCM_LOG_PRINT1( "  Fcm_chemin_image_cache={%s}", Fcm_chemin_image_cache );

	/* Force mode mono */
	global_force_mode_mono = Fcm_get_tag_booleen( "CHECK_FORCEMONO=", pt_fichier_config, FALSE );
	FCM_LOG_PRINT1( "  global_force_mode_mono=%d", global_force_mode_mono );

	/* Vitesse maximale animation   */
	global_max_fps = Fcm_get_tag_booleen( "CHECK_MAXFPS=", pt_fichier_config, FALSE );
	FCM_LOG_PRINT1( "  global_max_fps=%d", global_max_fps );

	/* Couper le son */
	global_mute_sound = Fcm_get_tag_booleen( "CHECK_MUTESOUND=", pt_fichier_config, FALSE );
	FCM_LOG_PRINT1( "  global_mute_sound=%d", global_mute_sound );

	/* palette pour ecran 16 (ou 256) couleurs */
	global_utilise_palette = Fcm_get_tag_booleen( "CHECK_PALETTE=", pt_fichier_config, FALSE );
	FCM_LOG_PRINT1( "  global_utilise_palette=%d", global_utilise_palette );

	/* offscreen pour le framebuffer */
	global_use_VDI_offscreen_for_framebuffer = Fcm_get_tag_booleen( "CHECK_OFFSCREEN_FRAMEBUFFER=", pt_fichier_config, FALSE );
	FCM_LOG_PRINT1( "  global_use_VDI_offscreen_for_framebuffer=%d", global_use_VDI_offscreen_for_framebuffer );

	/* Type de RAM pour les sprites  */
	Fcmgfx_CreateSurface_ram_type_select = Fcm_get_tag_int32( "POPUP_TYPE_RAM=", pt_fichier_config );
	if( Fcmgfx_CreateSurface_ram_type_select < POPUP_RAM_AUTO   ||   Fcmgfx_CreateSurface_ram_type_select > POPUP_RAM_MILAN )
	{
		Fcmgfx_CreateSurface_ram_type_select = POPUP_RAM_AUTO;  /* POPUP_RAM_xxxxx -> RSC definition dans POPUP_RAM */
	}
	FCM_LOG_PRINT1( "  Fcmgfx_CreateSurface_ram_type_select=%d", Fcmgfx_CreateSurface_ram_type_select );





	/* format pixel pour le mode 8bits   */
	global_pixel_8bits = Fcm_get_tag_int32( "PIXEL_8BITS=", pt_fichier_config );
	if( global_pixel_8bits < POP_PIXEL_AUTO   ||   global_pixel_8bits > POP_PIX_8B_PACK )
	{
		global_pixel_8bits = POP_PIXEL_AUTO;  /* POPUP_PIX_xxxxx -> RSC definition dans POPUP_PIXEL */
	}
	FCM_LOG_PRINT1( "  global_pixel_8bits=%d", global_pixel_8bits );

	/* format pixel pour le mode 16bits   */
	global_pixel_16bits = Fcm_get_tag_int32( "PIXEL_16BITS=", pt_fichier_config );
	if( global_pixel_16bits < POP_PIXEL_AUTO   ||   global_pixel_16bits > POP_PIX_16B_MOT )
	{
		global_pixel_16bits = POP_PIXEL_AUTO;  /* POPUP_PIX_xxxxx -> RSC definition dans POPUP_PIXEL */
	}
	FCM_LOG_PRINT1( "  global_pixel_16bits=%d", global_pixel_16bits );

	/* format pixel pour le mode 24bits  */
	global_pixel_24bits = Fcm_get_tag_int32( "PIXEL_24BITS=", pt_fichier_config );
	if( global_pixel_24bits < POP_PIXEL_AUTO   ||   global_pixel_24bits > POP_PIX_24B_MOT )
	{
		global_pixel_24bits = POP_PIXEL_AUTO;  /* POPUP_PIX_xxxxx -> RSC definition dans POPUP_PIXEL */
	}
	FCM_LOG_PRINT1( "  global_pixel_24bits=%d", global_pixel_24bits );

	/* format pixel pour le mode 32bits  */
	global_pixel_32bits = Fcm_get_tag_int32( "PIXEL_32BITS=", pt_fichier_config );
	if( global_pixel_32bits < POP_PIXEL_AUTO   ||   global_pixel_32bits > POP_PIX_32B_MOT )
	{
		global_pixel_32bits = POP_PIXEL_AUTO;  /* POPUP_PIX_xxxxx -> RSC definition dans POPUP_PIXEL */
	}
	FCM_LOG_PRINT1( "  global_pixel_32bits=%d", global_pixel_32bits );




	/* Pour chaque type de format d'écran, le format du pixel    */
	/* selectionné par le PopUP Pixel Format (Options) est sauvé */
	switch( Fcm_screen.nb_plan )
	{
		case 1:
			global_pixel_label_actif=POP_PIX_1B;
			break;
		case 2:
			global_pixel_label_actif=POP_PIX_2B;
			break;
		case 4:
			global_pixel_label_actif=POP_PIX_4B;
			break;
		case 8:
			global_pixel_label_actif=global_pixel_8bits;
			break;
		case 16:
			global_pixel_label_actif=global_pixel_16bits;
			break;
		case 24:
			global_pixel_label_actif=global_pixel_24bits;
			break;
		case 32:
			global_pixel_label_actif=global_pixel_32bits;
			break;
	}


	return;


}

