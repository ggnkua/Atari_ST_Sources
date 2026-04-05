/* **[Pupul]******************** */
/* *                           * */
/* * 04/07/2014 MaJ 26/02/2015 * */
/* ***************************** */


//#include "../fonction/coeur/coeur_define.c"




/* prototype */
int32 load_animation( void );




/* Fonction */
int32 load_animation( void )
{

	char	mon_chemin[(TAILLE_CHEMIN_DATA+16)];
	uint32  adr_buffer;
	uint32  nb_coord;
	int32   file_animation_size;



	strcpy( mon_chemin, chemin_data );
	strcat( mon_chemin, "pupul.ani" );


	#ifdef LOG_FILE
	sprintf( buf_log, " load_animation {%s}"CRLF, mon_chemin );
	log_print(FALSE);
	#endif


	file_animation_size = Fcm_file_size(mon_chemin);

	if( file_animation_size != 32432 )
	{
		return( APPLI_ERROR_ANIMATION_SIZE );
	}


	adr_buffer = Fcm_reserve_ram( file_animation_size, MX_PREFTTRAM );

	if( adr_buffer==FALSE )
	{
		/* echec reservation ram */
		return( APPLI_ERROR_ANIMATION_RAM );
	}



	nb_coord = (uint32)file_animation_size / 4;



	{
		int32 reponse;

		reponse = Fcm_bload( mon_chemin, (char *)adr_buffer, 0, file_animation_size);

		if( reponse != file_animation_size )
		{
			/* echec chargement des coordonnees */
			return( APPLI_ERROR_ANIMATION_LOAD );
		}
	}





	nb_coord = MIN(DEMON_MAX_POINT, nb_coord);



	{
		uint16  i;
		uint16 *pt_scrapxy;


		pt_scrapxy = (uint16 *)adr_buffer;

		for( i=0; i<nb_coord; i++ )
		{

			demon_xy[i].x = (*pt_scrapxy++)-55;
			demon_xy[i].y = (*pt_scrapxy++)-40;


			if( demon_xy[i].x>384 || demon_xy[i].y>264 )
			{
				demon_xy[i].x = MAX( demon_xy[i].x, 384);
				demon_xy[i].y = MAX( demon_xy[i].y, 264);

				printf( "# coord error index=%d, x=%d, y=%d #"CRLF, i, demon_xy[i].x, demon_xy[i].y);
			}
		}

	}

	demon_xy_nbpoint = nb_coord;



	Fcm_libere_ram( adr_buffer );



	return 0L;



}

