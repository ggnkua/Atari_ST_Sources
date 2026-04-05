/* ***************************** */
/* *                           * */
/* * 01/07/2017 MaJ 29/11/2025 * */
/* ***************************** */



#ifndef ___Fcm_charge_image_from_cache___
#define ___Fcm_charge_image_from_cache___



int32 Fcm_charge_image_from_cache( char *fichier, s_tga_ldg *tga_image, int16 mode_mono );



/* Fonction */
int32 Fcm_charge_image_from_cache( char *fichier, s_tga_ldg *tga_image, int16 mode_mono )
{


	char file_chemin[FCM_TAILLE_CHEMIN*2];
	char file_cache[FCM_TAILLE_CHEMIN*2];   /* a revoir tout ca ... */
	int32 taille_fichier;
	s_tga_ldg tga_image_temp;


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"Fcm_charge_image_from_cache(%s, %p)"CRLF""CRLF, fichier, tga_image );
	log_print(FALSE);
	sprintf( buf_log, CRLF"Fcm_chemin_image_cache={%s}  strlen(Fcm_chemin_image_cache)=%ld"CRLF, Fcm_chemin_image_cache, strlen(Fcm_chemin_image_cache) );
	log_print(FALSE);
	#endif



	/* on construit le nom de l'image */
	/* nom_image.cxx                  */
	/* fichier contient chemin + nom_image + TGA */

	strcpy( file_cache, fichier);
	/* on recupere le nom du fichier */
	Fcm_remove_chemin( file_cache );
	/* on vire l'extension */
	Fcm_remove_extension( file_cache );


	/* on genere le chemin + fichier + extension */
	if( mode_mono == FCM_CHARGE_TGA_MODE_MONO )
	{
		sprintf( file_chemin, "%s%s.c0", Fcm_chemin_image_cache, file_cache );
	}
	else
	{
		sprintf( file_chemin, "%s%s.c%d", Fcm_chemin_image_cache, file_cache, tga_image->format_need );
	}


	/* Le fichier est present dans le cache ? */
	taille_fichier = Fcm_file_size(file_chemin);

	/* la taille du fichier ne peut pas etre inferieur a la taille de l'entete du fichier */
	if( taille_fichier <= (int32)sizeof(s_tga_ldg) )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "# le fichier n'existe pas ou a une taille incorrect"CRLF );
		log_print( FALSE );
		sprintf( buf_log, "# taille_fichier=%ld (-33 => inexistant)"CRLF, taille_fichier );
		log_print( FALSE );
		#endif
		return FALSE;
	}


	#ifdef LOG_FILE
	sprintf( buf_log, "> le fichier existe, taille_fichier=%ld"CRLF, taille_fichier );
	log_print( FALSE );
	#endif


	/* taille de l'image */
	taille_fichier = taille_fichier - (int32)sizeof(s_tga_ldg);
	tga_image->decode_size = (uint32)taille_fichier;


	#ifdef LOG_FILE
	sprintf( buf_log, "> taille image=%ld"CRLF, taille_fichier );
	log_print( FALSE );
	#endif


	{
		uint32 adr_buffer;
		
		adr_buffer = Fcm_reserve_ram( taille_fichier, MX_PREFTTRAM );
		if( adr_buffer == FALSE )
		{
			return FALSE;
		}

		tga_image->adr_decode = (uint32)adr_buffer;
		tga_image->tga_free_flag = FALSE; /* ne doit pas etre liberé par TGA_free() car elle n'est pas chargé par TGA_load() (->ldg_malloc) */
	}


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"> tga_image->adr_decode = %08lx"CRLF, tga_image->adr_decode );
	log_print(FALSE);
	#endif


	/* chargement de l'image dans le cache */
	{
		int32	handle_fichier;
		int32	nombre_charger;


		/* Ouverture du fichier */
		handle_fichier = Fopen(file_chemin, 0);

		/* Si erreur on retourne l'erreur */
		if(handle_fichier<0)
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "# ERREUR ouverture fichier => handle=%ld"CRLF, handle_fichier );
			log_print( FALSE );
			#endif

			return FALSE;
		}

		nombre_charger = Fread(handle_fichier, sizeof(s_tga_ldg), &tga_image_temp );

		#ifdef LOG_FILE
		sprintf( buf_log, "Load entete : nombre_charger=%ld   sizeof(s_tga_ldg)=%ld"CRLF, nombre_charger, sizeof(s_tga_ldg) );
		log_print( FALSE );
		#endif

		nombre_charger = nombre_charger + Fread(handle_fichier, taille_fichier, tga_image->adr_decode );

		#ifdef LOG_FILE
		sprintf( buf_log, "Load image : total nombre_charger=%ld "CRLF, nombre_charger );
		log_print( FALSE );
		#endif

		Fclose(handle_fichier);

		if( nombre_charger != (taille_fichier + (int32)sizeof(s_tga_ldg)) )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "erreur de chargement, les taille ne corespondent pas !"CRLF );
			log_print( FALSE );
			#endif

			return FALSE;
		}
	}

	tga_image->width        = tga_image_temp.width;
	tga_image->height       = tga_image_temp.height;
	tga_image->frame_width  = tga_image_temp.frame_width;
	tga_image->frame_height = tga_image_temp.frame_height;


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"sizeof tga_image =%ld"CRLF, sizeof(s_tga_ldg) );
	log_print(FALSE);
	sprintf( buf_log, "adr_decode =%08lx"CRLF, tga_image->adr_decode );
	log_print(FALSE);
	sprintf( buf_log, "decode_size =%ld"CRLF, tga_image->decode_size );
	log_print(FALSE);
	sprintf( buf_log, "width =%d"CRLF, tga_image->width );
	log_print(FALSE);
	sprintf( buf_log, "height =%d"CRLF, tga_image->height );
	log_print(FALSE);
	sprintf( buf_log, "frame_width =%d"CRLF, tga_image->frame_width );
	log_print(FALSE);
	sprintf( buf_log, "frame_height =%d"CRLF, tga_image->frame_height );
	log_print(FALSE);
	sprintf( buf_log, "format_need =%d"CRLF, tga_image->format_need );
	log_print(FALSE);
	#endif

	return TRUE;

}



#endif /* ___Fcm_charge_image_from_cache___ */


