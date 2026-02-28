/* ***************************** */
/* *                           * */
/* * 10/08/2015 MaJ 10/08/2015 * */
/* ***************************** */




#ifndef ___Fcm_make_sprite_opaque___
#define ___Fcm_make_sprite_opaque___



#include "../coeur/coeur_define.c"

#include "Fcm_make_sprite.h"

#include "Fcm_create_surface.c"
#include "Fcm_free_surface.c"
#include "Fcm_transfert_surface_to_mfdb.c"
#include "Fcm_set_transparence.c"
#include "Fcm_create_mask.c"






/* prototype */
int32 Fcm_make_sprite_opaque( s_tga_ldg *image_tga, /*int16 pixel_xformat,*/ SURFACE *surface, MFDB *mfdb, char *fichier );



/* Fonction */
int32 Fcm_make_sprite_opaque( s_tga_ldg *image_tga, /*int16 pixel_xformat,*/ SURFACE *surface, MFDB *mfdb, char *fichier )
{
	int16 pixel_xformat;

	#ifdef LOG_FILE
	int32 timer;
	timer=Fcm_get_timer();
	#endif



	pixel_xformat = Fcm_screen.pixel_xformat;

	/* gestion du mode 8 bit planar */
	if( pixel_xformat == PIXEL_8_PLAN )
	{
		pixel_xformat = PIXEL_8_PACKED;
	}

	/* La routine de transparence ne gŠre pas le      */
	/* mode 8 bits Plan, donc on travaille en 8 bits  */
	/* Packed et on convertit en 8 bits Plan … la fin */



	image_tga->format_need = pixel_xformat;
	image_tga->vdi_align16 = TGA_VDI_ALIGN16;



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"Fcm_make_sprite_opaque()"CRLF );
	log_print(FALSE);
	#endif



	if( TGA_load(fichier, image_tga) !=0 )
	{
		return( MAKE_SPRITE_ERROR_TGA_LOAD );
	}


	surface->nb_plan = SCREEN_PLAN;
	surface->width   = image_tga->frame_width;
	surface->height  = image_tga->frame_height;


	#ifdef LOG_FILE
	sprintf( buf_log, "Fcm_create_surface mfdb()"CRLF );
	log_print(FALSE);
	#endif


	if( Fcm_create_surface(surface, mfdb) != TRUE )
	{
		return( MAKE_SPRITE_ERROR_CREATE_SURFACE );
	}


	#ifdef LOG_FILE
	sprintf( buf_log, "Fcm_transfert_surface_to_mfdb()"CRLF );
	log_print(FALSE);
	#endif



	Fcm_transfert_surface_to_mfdb( image_tga, mfdb );


/*	pxy[0]=0;
	pxy[1]=0;
	pxy[2]=surface->width-1;
	pxy[3]=surface->height-1;
	pxy[4]=10;
	pxy[5]=400;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];
	vro_cpyfm(vdihandle,3,pxy, mfdb, &Fcm_mfdb_ecran);
*/


/*	surface_mask->nb_plan = 1;
	surface_mask->width   = image_tga->frame_width;
	surface_mask->height  = image_tga->frame_height;


	#ifdef LOG_FILE
	sprintf( buf_log, "Fcm_create_surface mask"CRLF );
	log_print(FALSE);
	#endif

*/
/*
	if( Fcm_create_surface(surface_mask, mfdb_mask) != TRUE )
	{
		return( MAKE_SPRITE_ERROR_CREATE_SURFACE );
	}

	Fcm_create_mask( mfdb, mfdb_mask, x, y );
*/

/*	pxy[4]=10;
	pxy[5]=440;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];

	vrt_cpyfm(vdihandle,2,pxy, mfdb_mask, &Fcm_mfdb_ecran, mask_couleur);
*/

/*
	Fcm_set_transparence( mfdb, x, y );

*/
	TGA_free( image_tga );



	if( Fcm_screen.pixel_xformat == PIXEL_8_PLAN )
	{
		image_tga->adr_decode   = (uint32)mfdb->fd_addr;
		image_tga->frame_width  = mfdb->fd_w;
		image_tga->frame_height = mfdb->fd_h;

		Conversion_packed_to_plan( image_tga );
	}




/*	pxy[4]=10;
	pxy[5]=470;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];
	vro_cpyfm(vdihandle,3,pxy, mfdb, &Fcm_mfdb_ecran);
*/


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"Sprite charg‚ en %ld/200"CRLF""CRLF, Fcm_get_timer()-timer );
	log_print(FALSE);
	#endif


	return 0L;


}



#endif


