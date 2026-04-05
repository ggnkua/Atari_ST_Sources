/* ***************************** */
/* * 01/07/2017 MaJ 29/11/2025 * */
/* ***************************** */



#ifndef ___Fcm_sauve_image_to_cache___
#define ___Fcm_sauve_image_to_cache___

#include "../Fcm_remove_extension.c"
#include "../Fcm_remove_chemin.c"
#include "../coeur/Fcm_file_exist.c"


// coeur_variables.h
// char Fcm_chemin_courant[FCM_TAILLE_CHEMIN]="";


/* disponible mais pas actif par defaut, l'utilisateur doit l'activer */
int16 Fcm_image_cache_actif=FALSE;

char  Fcm_chemin_image_cache[FCM_TAILLE_CHEMIN];




void Fcm_sauve_image_to_cache( char *fichier, s_tga_ldg *tga_image, int16 mode_mono );


/* Fonction */
void Fcm_sauve_image_to_cache( char *fichier, s_tga_ldg *tga_image, int16 mode_mono )
{
	char file_chemin[FCM_TAILLE_CHEMIN*2];
	char file_cache[FCM_TAILLE_CHEMIN*2];    /* a revoir tout ca ... */


	/* plus de place sur le disk, on ne fait rien */
	if( Fcm_disk_full == TRUE )
	{
		FCM_CONSOLE_DEBUG1( "sauve image to cache, disque plein %p"CRLF, tga_image );
//		printf( "sauve image to cache, disque plein %p    "CRLF, tga_image );
		return;
	}


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"Fcm_sauve_image_to_cache(%s, %p)"CRLF""CRLF, fichier, tga_image );
	log_print(FALSE);
	#endif


	/* emplacement du cache */
	if( strlen(Fcm_chemin_image_cache)==0 )
	{
//		sprintf( Fcm_chemin_image_cache, "%sDATA\\CACHE\\", Fcm_chemin_courant);
		sprintf( file_chemin, "%sDATA\\CACHE\\", Fcm_chemin_courant);
//		snprintf( Fcm_chemin_image_cache, sizeof(Fcm_chemin_image_cache) ,"%s", file_chemin);
		if( strlen(file_chemin) < FCM_TAILLE_CHEMIN )
		{
			strcpy( Fcm_chemin_image_cache, file_chemin);
		}
		else
		{
			FCM_CONSOLE_DEBUG2( "sauve image to cache, chemin trop long %ld/%d"CRLF, strlen(file_chemin), FCM_TAILLE_CHEMIN );
//			printf( "sauve image to cache, chemin trop long %ld/%d"CRLF, strlen(file_chemin), FCM_TAILLE_CHEMIN );
			return;
		}
	}


	/* on construit le nom de l'image */
	/* nom_image.cxx                  */
	strcpy( file_cache, fichier);
	Fcm_remove_chemin( file_cache );
	Fcm_remove_extension( file_cache );

	if( mode_mono == FCM_CHARGE_TGA_MODE_MONO )
	{
		sprintf( file_chemin, "%s%s.c0", Fcm_chemin_image_cache, file_cache );
	}
	else
	{
		sprintf( file_chemin, "%s%s.c%d", Fcm_chemin_image_cache, file_cache, tga_image->format_need );
	}


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"file_chemin(%s)"CRLF""CRLF, file_chemin );
	log_print(FALSE);
	#endif

	
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


	/* Le fichier est deja present ? */
	if( Fcm_file_exist(file_chemin)==TRUE )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "# le fichier existe deja"CRLF );
		log_print( FALSE );
		sprintf( buf_log, "# filesize=%ld    taille attendu=%ld"CRLF, Fcm_file_size(file_chemin), (tga_image->decode_size+sizeof(s_tga_ldg)) );
		log_print( FALSE );
		#endif
		if( Fcm_file_size(file_chemin) == (int32)(tga_image->decode_size+sizeof(s_tga_ldg)) )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "# le fichier est conforme"CRLF );
			log_print( FALSE );
			#endif
			return;
		}
		#ifdef LOG_FILE
		sprintf( buf_log, "# le fichier est different"CRLF );
		log_print( FALSE );
		#endif

	}



	/* sauvegarde de l'image dans le cache */
	{
		int32	handle_fichier;
		int32	nombre_sauver;


		/* Ouverture du fichier */
		handle_fichier = Fcreate(file_chemin, 0);


		/* Si erreur on retourne l'erreur */
		if(handle_fichier<0)
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "# ERREUR creation fichier => handle=%ld"CRLF, handle_fichier );
			log_print( FALSE );
			#endif

			return;
		}


		nombre_sauver = Fwrite(handle_fichier, sizeof(*tga_image), tga_image );

		#ifdef LOG_FILE
		sprintf( buf_log, "> Nombre_sauver=%ld"CRLF, nombre_sauver );
		log_print( FALSE );
		#endif

		nombre_sauver = nombre_sauver + Fwrite(handle_fichier, tga_image->decode_size, tga_image->adr_decode );

		#ifdef LOG_FILE
		sprintf( buf_log, "> Nombre_sauver=%ld"CRLF, nombre_sauver );
		log_print( FALSE );
		#endif



		Fclose(handle_fichier);


	}



	return;

}

#endif /* ___Fcm_sauve_image_to_cache___ */

