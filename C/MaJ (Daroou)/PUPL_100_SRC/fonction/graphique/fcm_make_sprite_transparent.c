/* ***************************** */
/* *                           * */
/* * 10/08/2015 MaJ 24/09/2023 * */
/* ***************************** */



/* **** !!! Vider le cache Image en cas de modification du code !!! **** */


#ifndef ___FCM_MAKE_SPRITE_TRANSPARENT_C___
#define ___FCM_MAKE_SPRITE_TRANSPARENT_C___


#include "fcm_make_sprite.h"

#include "fcm_create_surface.c"
#include "fcm_transfert_image_to_mfdb.c"
#include "fcm_set_transparence.c"
#include "fcm_create_mask.c"
#include "fcm_charge_tga.c"
#include "fcm_libere_tga.c"



/* prototype */
int32 Fcm_make_sprite_transparent( s_tga_ldg *tga_image, SURFACE *surface, SURFACE *surface_mask, MFDB *mfdb, MFDB *mfdb_mask, char *fichier, uint16 x, uint16 y );



/* Fonction */
int32 Fcm_make_sprite_transparent( s_tga_ldg *tga_image, SURFACE *surface, SURFACE *surface_mask, MFDB *mfdb, MFDB *mfdb_mask, char *fichier, uint16 x, uint16 y )
{
	uint16 pixel_xformat;
	MFDB   mfdb_TGA;

	#ifdef LOG_FILE
	uint32 timer;
	timer=Fcm_get_timer();
	#endif

	
	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"Fcm_make_sprite_transparent()    Fcm_screen.pixel_xformat=%d"CRLF, Fcm_screen.pixel_xformat );
	log_print(FALSE);
	#endif

	#ifdef LOG_FILE
	if( Fcm_screen.pixel_xformat<0 )
	{
		sprintf( buf_log, CRLF"ERREUR !!! Fcm_screen.pixel_xformat non defini (%d)"CRLF, Fcm_screen.pixel_xformat );
		log_print(FALSE);
	}
	#endif


	surface->handle_VDIoffscreen      = SURFACE_NO_OPEN_VDI_OFFSCREEN_BITMAP;
	surface_mask->handle_VDIoffscreen = SURFACE_NO_OPEN_VDI_OFFSCREEN_BITMAP;


	pixel_xformat = (uint16)Fcm_screen.pixel_xformat;

	/* gestion du mode 8 et 4 bit planar */
	if( pixel_xformat==PIXEL_8_PLAN || pixel_xformat==PIXEL_4_PLAN )
	{
		pixel_xformat = PIXEL_8_PACKED;
	}

	/* La routine de transparence ne gŠre pas les     */
	/* mode bits Plan, donc on travaille en 8 bits    */
	/* Packed et on convertit en   bits Plan … la fin */


	tga_image->format_need = pixel_xformat;
	tga_image->vdi_align16 = TGA_VDI_ALIGN16;




/*	if( TGA_load(fichier, tga_image) !=0 )
	{
		return( MAKE_SPRITE_ERROR_TGA_LOAD );
	}*/

	{
		int32 reponse;
		reponse = Fcm_charge_TGA(fichier, tga_image, FCM_CHARGE_TGA_MODE_NORMAL);
		if( reponse != 0 )
		{
			return( reponse );
		}
	}


/*	if( Fcm_charge_TGA(fichier, tga_image, FCM_CHARGE_TGA_MODE_NORMAL) !=0 )
	{
		return( MAKE_SPRITE_ERROR_TGA_LOAD );
	}*/

		
	mfdb_TGA.fd_addr=(uint32 *)tga_image->adr_decode;
	mfdb_TGA.fd_w=(int16)tga_image->frame_width;
	mfdb_TGA.fd_h=(int16)tga_image->frame_height;
	mfdb_TGA.fd_wdwidth=0;
	mfdb_TGA.fd_stand=0;
	mfdb_TGA.fd_r1=0;
	mfdb_TGA.fd_r2=0;
	mfdb_TGA.fd_r3=0;

	switch( pixel_xformat )
	{
		case PIXEL_8_PLAN:
		case PIXEL_8_PACKED:
		case PIXEL_4_PLAN:
			mfdb_TGA.fd_nplanes=8;
			break;
		case PIXEL_15_FALCON:
		case PIXEL_15_MOTOROLA:
		case PIXEL_15_INTEL:
		case PIXEL_16_MOTOROLA:
		case PIXEL_16_INTEL:
			mfdb_TGA.fd_nplanes=16;
			break;
		case PIXEL_24_MOTOROLA:
		case PIXEL_24_INTEL:
			mfdb_TGA.fd_nplanes=24;
			break;
		case PIXEL_32_MOTOROLA:
		case PIXEL_32_INTEL:
			mfdb_TGA.fd_nplanes=32;
			break;
	}


	surface->nb_plan = FCMGFX_SCREEN_NBPLAN;
	surface->width   = tga_image->frame_width;
	surface->height  = tga_image->frame_height;


	if( Fcm_create_surface(surface, mfdb) != TRUE )
	{
		return( MAKE_SPRITE_ERROR_CREATE_SURFACE );
	}


	surface_mask->nb_plan = 1;
	surface_mask->width   = tga_image->frame_width;
	surface_mask->height  = tga_image->frame_height;

	if( Fcm_create_surface(surface_mask, mfdb_mask) != TRUE )
	{
		return( MAKE_SPRITE_ERROR_CREATE_SURFACE );
	}

	/*Fcm_create_mask( mfdb, mfdb_mask, x, y );*/
	Fcm_create_mask( &mfdb_TGA, mfdb_mask, x, y );


/*	pxy[0]=0;
	pxy[1]=0;
	pxy[2]=mfdb_mask->fd_w-1;
	pxy[3]=mfdb_mask->fd_h-1;
	pxy[4]=10;
	pxy[5]=10;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];

	vrt_cpyfm(vdihandle,2,pxy, mfdb_mask, &Fcm_mfdb_ecran, mask_couleur);*/
	/*evnt_timer(1000);*/



	/*Fcm_set_transparence( mfdb, x, y );*/
	Fcm_set_transparence( &mfdb_TGA, x, y );


	
	if( Fcm_screen.pixel_xformat==PIXEL_8_PLAN || Fcm_screen.pixel_xformat==PIXEL_4_PLAN)
	{
		switch( Fcm_screen.pixel_xformat )
		{
			case PIXEL_4_PLAN:
				TGA_SA_8packed_to_4plan( tga_image );
				break;
			case PIXEL_8_PLAN:
				Conversion_packed_to_plan( tga_image ); /* fonction à renommer TGA_SA_8packed_to_8plan */
				break;
		}
	}


	Fcm_transfert_image_to_mfdb( tga_image, mfdb );


/*	TGA_free( tga_image );*/
	Fcm_libere_TGA( tga_image );


	/*pxy[0]=0;
	pxy[1]=0;
	pxy[2]=mfdb->fd_w-1;
	pxy[3]=mfdb->fd_h-1;
	pxy[4]=10;
	pxy[5]=200;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];
	vro_cpyfm(vdihandle,3,pxy, mfdb, &Fcm_mfdb_ecran);*/


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"Sprite charg‚ en %ld/200"CRLF""CRLF, Fcm_get_timer()-timer );
	log_print(FALSE);
	#endif


	return 0L;

}

#endif  /*   ___FCM_MAKE_SPRITE_TRANSPARENT_C___   */

