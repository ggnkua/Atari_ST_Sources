/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 06/02/2016 * */
/* ***************************** */



/* prototype */
void libere_surface( void );



/* Fonction */
void libere_surface( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"*-> START libere_surface()"CRLF );
	log_print(FALSE);
	#endif



	Fcm_free_surface( &surface_offscreen_vdi );
	Fcm_free_surface( &surface_offscreen_stram );
	Fcm_free_surface( &surface_offscreen_ttram );



	Fcm_free_surface( &surface_fond );
	Fcm_free_surface( &surface_fond_stram );
	Fcm_free_surface( &surface_fond_ttram );

	{
		int16 index;
		for(index=0; index<NB_BAR; index++)
		{
			Fcm_free_surface( &surface_bar[index] );
			Fcm_free_surface( &surface_bar_stram[index] );
			Fcm_free_surface( &surface_bar_ttram[index] );
		}
	}

	Fcm_free_surface( &surface_bee );
	Fcm_free_surface( &surface_bee_stram );
	Fcm_free_surface( &surface_bee_ttram );

	Fcm_free_surface( &surface_bee_mask );
	Fcm_free_surface( &surface_bee_mask_stram );
	Fcm_free_surface( &surface_bee_mask_ttram );



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"Lib‚ration Buffer ct60_vmalloc"CRLF );
	log_print(FALSE);
	#endif
	if( gb_adresse_buffer_ct60_vram != 0 )
	{
		#ifdef LOG_FILE
		int32 reponse;
		#endif

		#ifndef CT60_VRAM_IN_TTRAM

			#ifndef LOG_FILE
			ct60_vmalloc(1, gb_adresse_buffer_ct60_vram);
			#else
			reponse=ct60_vmalloc(1, gb_adresse_buffer_ct60_vram);
			sprintf( buf_log, "reponse ct60_vmalloc(1,x)=%ld"CRLF, reponse  );
			log_print(FALSE);
			#endif

		#else

			#ifndef LOG_FILE
			Fcm_libere_ram(gb_adresse_buffer_ct60_vram);
			#else
			reponse=Fcm_libere_ram(gb_adresse_buffer_ct60_vram);
			sprintf( buf_log, "reponse Fcm_libere_ram=%ld"CRLF, reponse  );
			log_print(FALSE);
			#endif

		#endif
	}
	else
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "pas de buffer ct60_vmalloc"CRLF );
		log_print(FALSE);
		#endif
	}


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"*-> END libere_surface()"CRLF""CRLF );
	log_print(FALSE);
	#endif


	return;


}

