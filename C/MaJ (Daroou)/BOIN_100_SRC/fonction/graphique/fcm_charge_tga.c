/* ***************************** */
/* *                           * */
/* * 01/07/2017 MaJ 23/09/2023 * */
/* ***************************** */



#ifndef ___FCM_CHARGE_TGA_C___
#define ___FCM_CHARGE_TGA_C___


#ifdef FCM_USE_IMAGE_CACHE
#warning "ne plus utilser FCM_USE_IMAGE_CACHE"
#endif


/* Define pour le parametre mode_mono */
#define FCM_CHARGE_TGA_MODE_NORMAL (0)
#define FCM_CHARGE_TGA_MODE_MONO   (1)



//#ifdef FCM_USE_IMAGE_CACHE
#include "fcm_sauve_image_to_cache.c"
#include "fcm_charge_image_from_cache.c"
//#endif




/* prototype */
int32 Fcm_charge_TGA( char *fichier, s_tga_ldg *tga_image, int16 mode_mono );



/* Fonction */
int32 Fcm_charge_TGA( char *fichier, s_tga_ldg *tga_image, int16 mode_mono )
{

	#ifdef LOG_FILE
	uint32 timer;
	timer=Fcm_get_timer();
	#endif

//	#ifndef FCM_USE_IMAGE_CACHE
//	UNUSED(mode_mono);
//	#endif




	#ifdef LOG_FILE
	sprintf( buf_log, CRLF">>> ------------ Fcm_charge_TGA (%s, %p, %d)"CRLF, fichier, tga_image, mode_mono );
	log_print(FALSE);
	#endif


//	#ifdef FCM_USE_IMAGE_CACHE
	if( Fcm_image_cache_actif == TRUE )
	{
		if( Fcm_charge_image_from_cache( fichier, tga_image, mode_mono) == TRUE )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, CRLF"image charg‚ a partir du cache en %ld/200"CRLF""CRLF, Fcm_get_timer()-timer );
			log_print(FALSE);
			#endif

			return 0L;
		}
	}
//	#endif



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF">>> ------------ chargement avec TGA_SA.LDG"CRLF);
	log_print(FALSE);
	#endif

	{
		int32 reponse;
		
		reponse = TGA_load(fichier, tga_image);
		
		if( reponse != 0 )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, CRLF"reponse TGA_LOAD = %ld"CRLF, reponse );
			log_print(FALSE);
			#endif

			return( MAKE_SPRITE_ERROR_TGA_LOAD );
		}
	}


//	#ifdef FCM_USE_IMAGE_CACHE
	if( Fcm_image_cache_actif == TRUE )
	{
		Fcm_sauve_image_to_cache( fichier, tga_image, mode_mono);
	}
//	#endif


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"image charg‚ en %ld/200"CRLF""CRLF, Fcm_get_timer()-timer );
	log_print(FALSE);
	#endif

	return 0L;

}



#endif  /* ___FCM_CHARGE_TGA_C___ */


