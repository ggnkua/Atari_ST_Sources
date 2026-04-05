/* ***************************** */
/* *                           * */
/* * 06/07/2017 MaJ 15/07/2017 * */
/* ***************************** */


#ifndef ___FCM_LIBERE_TGA_C___
#define ___FCM_LIBERE_TGA_C___


/* prototype */
void Fcm_libere_TGA( s_tga_ldg *tga_image );



/* Fonction */
void Fcm_libere_TGA( s_tga_ldg *tga_image )
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF">>> Fcm_libere_TGA (%p)"CRLF, tga_image );
	log_print(FALSE);
	#endif

	if( tga_image->tga_free_flag == TRUE )
	{
		TGA_free( tga_image );
	}
	else
	{
		Fcm_libere_ram( tga_image->adr_decode );
	}

	return;

}

#endif  /* ___FCM_LIBERE_TGA_C___ */

