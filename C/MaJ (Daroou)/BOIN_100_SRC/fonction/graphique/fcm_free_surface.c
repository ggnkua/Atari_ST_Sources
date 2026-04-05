/* ***************************** */
/* * 30/01/2013 MaJ 08/08/2017 * */
/* ***************************** */




#ifndef ___FCM_FREE_SURFACE_C___
#define ___FCM_FREE_SURFACE_C___

#include	"fcm_libere_vram_ct60.c"


void Fcm_free_surface( SURFACE *surface );



/* Fonction */
void Fcm_free_surface( SURFACE *surface )
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# Fcm_free_surface(%p)  (adresse_malloc=0x%lx, ram type=%d"CRLF, (void*)surface, surface->adresse_malloc, surface->ram_type );
	log_print(FALSE);
	#endif


	if( surface->adresse_malloc != FALSE )
	{
		switch(surface->ram_type)
		{
			case SURFACE_RAM_TYPE_ST_RAM:
			case SURFACE_RAM_TYPE_TT_RAM:
				Fcm_libere_ram( surface->adresse_malloc );
				break;

			case SURFACE_RAM_TYPE_CT60_VRAM:
				Fcm_libere_vram_ct60( surface->adresse_malloc );
				break;

			case SURFACE_RAM_TYPE_MILAN_VRAM:
				/*Fcm_libere_vram_milan( surface->adresse_malloc );*/
				break;

			default:
				break;
		}

		surface->adresse_malloc = 0;
		surface->adresse_buffer = 0;
	}
	else
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "  - Adresse_buffer null "CRLF );
		log_print(FALSE);
		#endif
	}




	/* Si un ecran offscreen bitmap a ete ouvert sur cette surface */
	if( surface->handle_VDIoffscreen > 0 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" -> fermeture station Offscreen bitmap"CRLF );
		log_print(FALSE);
		#endif

		v_clsbm( (int16)surface->handle_VDIoffscreen );
		surface->handle_VDIoffscreen=0;
	}


	return;

}

#endif /*___FCM_FREE_SURFACE_C___*/

