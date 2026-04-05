/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 22/11/2015 * */
/* ***************************** */

#include	"../fonction/graphique/fcm_free_surface.c"

void libere_surface( void );





void libere_surface( void )
{

#ifdef LOG_FILE
sprintf( buf_log, CRLF"*-> START libere_surface()"CRLF );
log_print(FALSE);
#endif



	Fcm_free_surface( &surface_framebuffer );

	Fcm_free_surface( &surface_prairie );


#ifdef LOG_FILE
sprintf( buf_log, CRLF"*-> badgers"CRLF );
log_print(FALSE);
#endif
	{
		int16 idx_badgers;
		int16 idx_forme_badgers;

		for(idx_badgers=0; idx_badgers<NB_BADGERS; idx_badgers++)
		{
			if( idx_badgers!=8 && idx_badgers!=10)
			{
				for(idx_forme_badgers=0; idx_forme_badgers<NB_FORME_BAGERS; idx_forme_badgers++)
				{
					Fcm_free_surface( &surface_badgers     [idx_badgers][idx_forme_badgers] );
					Fcm_free_surface( &surface_badgers_mask[idx_badgers][idx_forme_badgers] );
				}
			}
		}
	}


	Fcm_free_surface( &surface_mushroom[0] );
	Fcm_free_surface( &surface_mushroom[1] );


#ifdef LOG_FILE
sprintf( buf_log, CRLF"*-> Arghhh"CRLF );
log_print(FALSE);
#endif
	{
		int16 idx_argh;

		for(idx_argh=0; idx_argh<NB_ARGH; idx_argh++)
		{
			Fcm_free_surface( &surface_argh[idx_argh] );
		}
	}


	Fcm_free_surface( &surface_desert );

	Fcm_free_surface( &surface_soleil );

	Fcm_free_surface( &surface_nuage );

	Fcm_free_surface( &surface_horizon1 );

	Fcm_free_surface( &surface_horizon2 );
	Fcm_free_surface( &surface_horizon2_mask );

	Fcm_free_surface( &surface_cactus );
	Fcm_free_surface( &surface_cactus_mask );

	Fcm_free_surface( &surface_herbe1 );
	Fcm_free_surface( &surface_herbe1_mask );

	Fcm_free_surface( &surface_herbe2 );
	Fcm_free_surface( &surface_herbe2_mask );



#ifdef LOG_FILE
sprintf( buf_log, CRLF"*-> Snake"CRLF );
log_print(FALSE);
#endif
	{
		int16 idx_snake;

		for(idx_snake=0; idx_snake<NB_SNAKE; idx_snake++)
		{
			Fcm_free_surface( &surface_snake[idx_snake] );
			Fcm_free_surface( &surface_snake_mask[idx_snake] );
		}
	}



#ifdef LOG_FILE
sprintf( buf_log, "*-> END libere_surface()"CRLF""CRLF );
log_print(FALSE);
#endif


	return;


}

