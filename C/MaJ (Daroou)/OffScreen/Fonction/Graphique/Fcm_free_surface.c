/* ***************************** */
/* * 30/01/2013 MaJ 05/02/2015 * */
/* ***************************** */




#ifndef ___FCM_FREE_SURFACE___
#define ___FCM_FREE_SURFACE___



void Fcm_free_surface( SURFACE *surface );



/* Fonction */
void Fcm_free_surface( SURFACE *surface )
{
/*
 *
 */


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# Fcm_free_surface(%p)"CRLF, surface );
	log_print(FALSE);
	#endif



/*	printf( CRLF">>> FREE SURFACE  >>>>>>>>>>>>>>>>>>>>>"CRLF );
	printf( "free_surface( %p )"CRLF, surface );


	printf( "surface->handle_offscreen = %d"CRLF, surface->handle_offscreen );
*/

	/* Surface allou‚ par la VDI ? */
	if( surface->handle_offscreen > 0 )
	{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" -> fermeture Offscreen"CRLF );
	log_print(FALSE);
	#endif

/*		printf( "fermeture OFFSCREEN"CRLF);*/
		v_clsbm( surface->handle_offscreen );
		surface->handle_offscreen=0;
		surface->adresse_buffer=0;

	}
	else
	{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" -> fermeture malloc"CRLF );
	log_print(FALSE);
	#endif

/*		printf( "fermeture OFFSCREEN malloc()"CRLF);*/

		if( surface->adresse_malloc != 0 )
		{
			Fcm_libere_ram( surface->adresse_malloc );

			surface->adresse_malloc=0;
			surface->adresse_buffer=0;
		}
		else
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "  - Adresse_buffer null "CRLF );
			log_print(FALSE);
			#endif
		}
	}




	return;


}


#endif /*___FCM_FREE_SURFACE___*/


