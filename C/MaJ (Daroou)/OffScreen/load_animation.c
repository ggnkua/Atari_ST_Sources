/* **[Offscreen]**************** */
/* *                           * */
/* * 08/01/2016 MaJ 08/01/2016 * */
/* ***************************** */



#include "fonction/coeur/coeur_define.c"




/* prototype */
int32 load_animation( void );




/* Fonction */
int32 load_animation( void )
{

	char	mon_chemin[(TAILLE_CHEMIN_DATA+16)];
	uint32  adr_buffer;




	strcpy( mon_chemin, chemin_data );
	strcat( mon_chemin, "BEE.ANI" );




	{
		int32 file_animation_size;


		file_animation_size=Fcm_file_size(mon_chemin);

		if( file_animation_size != ANIM_FILE_SIZE )
		{
			return( OFFSCREEN_ERROR_ANIMATION_SIZE );
		}


		adr_buffer=Fcm_reserve_ram( file_animation_size, MX_PREFTTRAM );

		if( adr_buffer==FALSE )
		{
			/* echec reservation ram */
			return( OFFSCREEN_ERROR_ANIMATION_RAM );
		}


		{
			int32 reponse;

			reponse=Fcm_bload( mon_chemin, (char *)adr_buffer, 0, file_animation_size);

			if( reponse!=file_animation_size )
			{
				/* echec chargement des coordonnees */
				return( OFFSCREEN_ERROR_ANIMATION_LOAD );
			}
		}
	}







/*	uint32  nb_coord;*/
/*	nb_coord = (32432/4);*/



	{
		uint16  i;
		uint16 *pt_scrapxy;

		uint16 maxx,minx;
		uint16 maxy,miny;

		minx=320;
		miny=320;
		maxx=0;
		maxy=0;

		pt_scrapxy = (uint16 *)adr_buffer;

		for( i=0; i<ANIM_NB_COORD; i++ )
		{

			bee_xy[i].x = (*pt_scrapxy++)-55-20+15;
			bee_xy[i].y = (*pt_scrapxy++)-40-20;

			bee_xy[i].x = (bee_xy[i].x * 90)/100;
			bee_xy[i].y = (bee_xy[i].y * 90)/100;

			minx=MIN( minx, bee_xy[i].x);
			miny=MIN( miny, bee_xy[i].y);

			maxx=MAX( maxx, bee_xy[i].x);
			maxy=MAX( maxy, bee_xy[i].y);


/*{
	char texte[256];

	sprintf(texte,"minx=%3d miny=%3d maxx=%3d maxy=%3d     ", minx,miny, maxx, maxy  );
	v_gtext(vdihandle,2*8,3*16,texte);
}*/


			if( bee_xy[i].x>384 || bee_xy[i].y>264 )
			{
				bee_xy[i].x = MAX( bee_xy[i].x, 384);
				bee_xy[i].y = MAX( bee_xy[i].y, 264);

				printf( "# coord error index=%d, x=%d, y=%d #"CRLF, i, bee_xy[i].x, bee_xy[i].y);
			}
		}

	}

/*	demon_xy_nbpoint = nb_coord;*/



	Fcm_libere_ram( adr_buffer );


	return 0L;



}

