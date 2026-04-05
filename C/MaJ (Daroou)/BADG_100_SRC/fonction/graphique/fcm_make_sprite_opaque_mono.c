/* ***************************** */
/* *                           * */
/* * 20/11/2016 MaJ 15/07/2017 * */
/* ***************************** */




#ifndef ___FCM_MAKE_SPRITE_OPAQUE_MONO_C___
#define ___FCM_MAKE_SPRITE_OPAQUE_MONO_C___





#include "fcm_create_surface.c"
#include "fcm_create_sprite_opaque_mono.c"
#include "fcm_charge_tga.c"
#include "fcm_libere_tga.c"






/* prototype */
int32 Fcm_make_sprite_opaque_mono( s_tga_ldg *tga_image, SURFACE *surface, MFDB *mfdb, char *fichier );



/* Fonction */
int32 Fcm_make_sprite_opaque_mono( s_tga_ldg *tga_image, SURFACE *surface, MFDB *mfdb, char *fichier )
{
	uint16 pixel_xformat;


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"* Fcm_make_sprite_opaque_mono( %p, %p, %p, {%s} )"CRLF, (void*)tga_image, (void*)surface, (void*)mfdb, fichier );
	log_print(FALSE);
	#endif


	surface->handle_VDIoffscreen = SURFACE_NO_OPEN_VDI_OFFSCREEN_BITMAP;

	/* La routine ne gŠre pas le      */
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


	Fcm_create_sprite_opaque_mono( tga_image, mfdb );

	/*{
		int16 mask[2];
		
	mask[0]=1;
	mask[1]=0;

	pxy[0]=0;
	pxy[1]=0;
	pxy[2]=surface->width-1;
	pxy[3]=surface->height-1;
	pxy[4]=20;
	pxy[5]=20;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];
	vrt_cpyfm(vdihandle,MD_REPLACE,pxy, mfdb, &Fcm_mfdb_ecran, mask);
	}*/


/*	TGA_free( tga_image );*/
	Fcm_libere_TGA( tga_image );

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" End Fcm_make_sprite_opaque_mono()"CRLF );
	log_print(FALSE);
	#endif

	return 0L;

}


#endif  /*   ___FCM_MAKE_SPRITE_OPAQUE_MONO_C___   */

