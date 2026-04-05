/* ***************************** */
/* *                           * */
/* * 20/11/2016 MaJ 15/07/2017 * */
/* ***************************** */




#ifndef ___FCM_MAKE_SPRITE_TRANSPARENT_MONO_C___
#define ___FCM_MAKE_SPRITE_TRANSPARENT_MONO_C___





#include "fcm_create_surface.c"
#include "fcm_set_transparence.c"
#include "fcm_create_mask_mono.c"
#include "fcm_create_sprite_mono.c"
#include "fcm_charge_tga.c"
#include "fcm_libere_tga.c"




/* prototype */
int32 Fcm_make_sprite_transparent_mono( s_tga_ldg *tga_image, SURFACE *surface, SURFACE *surface_mask, MFDB *mfdb, MFDB *mfdb_mask, char *fichier, int16 x, int16 y );



/* Fonction */
int32 Fcm_make_sprite_transparent_mono( s_tga_ldg *tga_image, SURFACE *surface, SURFACE *surface_mask, MFDB *mfdb, MFDB *mfdb_mask, char *fichier, int16 x, int16 y )
{
	uint16 pixel_xformat;


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"* Fcm_make_sprite_transparent_mono( %p, %p, %p, %p, %p, {%s}, %d, %d )"CRLF, (void*)tga_image, (void*)surface, (void*)surface_mask, (void*)mfdb, (void*)mfdb_mask, fichier, x, y );
	log_print(FALSE);
	#endif


	surface->handle_VDIoffscreen      = SURFACE_NO_OPEN_VDI_OFFSCREEN_BITMAP;
	surface_mask->handle_VDIoffscreen = SURFACE_NO_OPEN_VDI_OFFSCREEN_BITMAP;


	/* La routine de transparence ne gŠre pas le      */
	/* mode 1 bits, donc on travaille en 8 bits  */
	/* Packed et on convertit en 1 bits … la fin */
	pixel_xformat = PIXEL_8_PACKED;



	tga_image->format_need = pixel_xformat;
	tga_image->vdi_align16 = TGA_VDI_ALIGN16;



/*	if( TGA_load(fichier, tga_image) !=0 )
	{
		return( MAKE_SPRITE_ERROR_TGA_LOAD );
	}*/

	{
		int32 reponse;
		reponse = Fcm_charge_TGA(fichier, tga_image, FCM_CHARGE_TGA_MODE_MONO);
		if( reponse != 0 )
		{
			return( reponse );
		}
	}


/*	if( Fcm_charge_TGA(fichier, tga_image, FCM_CHARGE_TGA_MODE_MONO) !=0 )
	{
		return( MAKE_SPRITE_ERROR_TGA_LOAD );
	}*/


	
	
	/* création du mask */
	surface_mask->nb_plan = 1;
	surface_mask->width   = tga_image->frame_width;
	surface_mask->height  = tga_image->frame_height;

	#ifdef LOG_FILE
	sprintf( buf_log, "Fcm_create_surface() mask"CRLF );
	log_print(FALSE);
	#endif

	if( Fcm_create_surface(surface_mask, mfdb_mask) != TRUE )
	{
		return( MAKE_SPRITE_ERROR_CREATE_SURFACE );
	}

	Fcm_create_mask_mono( tga_image, mfdb_mask, x, y );


/*	pxy[0]=0;
	pxy[1]=0;
	pxy[2]=surface_mask->width-1;
	pxy[3]=surface_mask->height-1;
	pxy[4]=10;
	pxy[5]=10;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];

	vrt_cpyfm(vdihandle,2,pxy, mfdb_mask, &Fcm_mfdb_ecran, mask_couleur);*/

	
	/* création du sprite */
	surface->nb_plan = 1;
	surface->width   = tga_image->frame_width;
	surface->height  = tga_image->frame_height;

	#ifdef LOG_FILE
	sprintf( buf_log, "Fcm_create_surface() sprite"CRLF );
	log_print(FALSE);
	#endif

	if( Fcm_create_surface(surface, mfdb) != TRUE )
	{
		return( MAKE_SPRITE_ERROR_CREATE_SURFACE );
	}

	Fcm_create_sprite_mono( tga_image, mfdb, x, y );

/*	pxy[0]=0;
	pxy[1]=0;
	pxy[2]=surface->width-1;
	pxy[3]=surface->height-1;
	pxy[4]=10;
	pxy[5]=200;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];
	vrt_cpyfm(vdihandle,2,pxy, mfdb, &Fcm_mfdb_ecran, mask_couleur);*/



/*	TGA_free( tga_image );*/
	Fcm_libere_TGA( tga_image );

	return 0L;

}



#endif  /*   ___FCM_MAKE_SPRITE_TRANSPARENT_MONO_C___   */


