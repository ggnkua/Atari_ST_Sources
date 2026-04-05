/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 27/05/2018 * */
/* ***************************** */



#ifndef ___LIBERE_SURFACE_C___
#define ___LIBERE_SURFACE_C___



/* prototype */
void libere_surface( void );



/* Fonction */
void libere_surface( void )
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"*-> START libere_surface()"CRLF );
	log_print(FALSE);
	#endif


	Fcm_free_surface( &surface_fond_ecran );
	Fcm_free_surface( &surface_framebuffer );



	{
		int16 index_ball;
		for(index_ball=0; index_ball<NB_BOING_BALL; index_ball++)
		{
			Fcm_free_surface( &surface_boing_ball[index_ball] );
			Fcm_free_surface( &surface_boing_ball_mask[index_ball] );
		}
	}


	/*Fcm_free_surface( &surface_boing_ombre );*/
	Fcm_free_surface( &surface_boing_ombre_mask );



	#ifdef LOG_FILE
	sprintf( buf_log, "*-> END libere_surface()"CRLF""CRLF );
	log_print(FALSE);
	#endif


	return;


}

#endif    /* ___LIBERE_SURFACE_C___ */

