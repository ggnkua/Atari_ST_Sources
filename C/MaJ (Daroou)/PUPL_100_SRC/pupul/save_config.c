/* **[Pupul]******************** */
/* *                           * */
/* * 20/08/2014 MaJ 07/11/2023 * */
/* ***************************** */




/* Fonction */
void save_config(const int16 handle_fichier)
{
	
	#ifdef LOG_FILE
	sprintf( buf_log, "# save_config()"CRLF );
	log_print(FALSE);
	#endif


	Fcm_fprint( handle_fichier, "");
	Fcm_fprint( handle_fichier, "-=- Configuration local application -=-");
	Fcm_fprint( handle_fichier, "");
	Fcm_fprint( handle_fichier, "");




	{
		char	my_buffer[128];


		Fcm_fprint( handle_fichier, "# configuration du dialogue <<Options>>");

		sprintf( my_buffer, "CHECK_CACHEIMG=%d", Fcm_image_cache_actif );
		Fcm_fprint( handle_fichier, my_buffer );

		sprintf( my_buffer, "CHECK_PATHCACHE=%s", Fcm_chemin_image_cache );
		Fcm_fprint( handle_fichier, my_buffer );

		sprintf( my_buffer, "CHECK_FORCEMONO=%d", global_force_mode_mono );
		Fcm_fprint( handle_fichier, my_buffer );

		sprintf( my_buffer, "CHECK_MAXFPS=%d", global_max_fps );
		Fcm_fprint( handle_fichier, my_buffer );

		sprintf( my_buffer, "CHECK_MUTESOUND=%d", global_mute_sound );
		Fcm_fprint( handle_fichier, my_buffer );

		sprintf( my_buffer, "CHECK_PALETTE=%d", global_utilise_palette );
		Fcm_fprint( handle_fichier, my_buffer );

		sprintf( my_buffer, "CHECK_OFFSCREEN_FRAMEBUFFER=%d", global_use_VDI_offscreen_for_framebuffer );
		Fcm_fprint( handle_fichier, my_buffer );

		sprintf( my_buffer, "POPUP_TYPE_RAM=%d", Fcmgfx_CreateSurface_ram_type_select );
		Fcm_fprint( handle_fichier, my_buffer );

		sprintf( my_buffer, "PIXEL_8BITS=%d", global_pixel_8bits );
		Fcm_fprint( handle_fichier, my_buffer );
		sprintf( my_buffer, "PIXEL_16BITS=%d", global_pixel_16bits );
		Fcm_fprint( handle_fichier, my_buffer );
		sprintf( my_buffer, "PIXEL_24BITS=%d", global_pixel_24bits );
		Fcm_fprint( handle_fichier, my_buffer );
		sprintf( my_buffer, "PIXEL_32BITS=%d", global_pixel_32bits );
		Fcm_fprint( handle_fichier, my_buffer );




		Fcm_fprint( handle_fichier, "");
		Fcm_fprint( handle_fichier, "# configuration du dialogue <<MOD LDG>>");

		sprintf( my_buffer, "MOD_UPDATE_POPUP=%d", global_mod_ldg_update );
		Fcm_fprint( handle_fichier, my_buffer );

		sprintf( my_buffer, "MOD_FREQ_POPUP=%d", global_mod_ldg_frequence );
		Fcm_fprint( handle_fichier, my_buffer );

	}


	Fcm_fprint( handle_fichier, "");
	Fcm_fprint( handle_fichier, "");
	Fcm_fprint( handle_fichier, "-=- Fin du fichier de configuration -=-");


	return;


}

