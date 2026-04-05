/* ***************************** */
/* *                           * */
/* * 10/08/2015 MaJ 10/11/2023 * */
/* ***************************** */




#ifndef ___FCM_MAKE_SPRITE_OPAQUE_C___
#define ___FCM_MAKE_SPRITE_OPAQUE_C___





#include "fcm_make_sprite.h"

#include "fcm_create_surface.c"
#include "fcm_transfert_image_to_mfdb.c"
#include "fcm_charge_tga.c"
#include "fcm_libere_tga.c"





/* prototype */
int32 Fcm_make_sprite_opaque( s_tga_ldg *tga_image, /*int16 pixel_xformat,*/ SURFACE *surface, MFDB *mfdb, char *fichier );



/* Fonction */
int32 Fcm_make_sprite_opaque( s_tga_ldg *tga_image, /*int16 pixel_xformat,*/ SURFACE *surface, MFDB *mfdb, char *fichier )
{
	uint16 pixel_xformat;

	#ifdef LOG_FILE
	uint32 timer;
	timer=Fcm_get_timer();
	#endif



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"Fcm_make_sprite_opaque()"CRLF );
	log_print(FALSE);
	#endif


	#ifdef LOG_FILE
	if( Fcm_screen.pixel_xformat<0 )
	{
		sprintf( buf_log, CRLF"ERREUR !!! Fcm_screen.pixel_xformat non defini (%d)"CRLF, Fcm_screen.pixel_xformat );
		log_print(FALSE);
	}
	#endif


	surface->handle_VDIoffscreen = SURFACE_NO_OPEN_VDI_OFFSCREEN_BITMAP;

	pixel_xformat = (uint16)Fcm_screen.pixel_xformat;

	/* gestion du mode 8 et 4 bit planar */
	if( pixel_xformat==PIXEL_8_PLAN || pixel_xformat==PIXEL_4_PLAN )
	{
		pixel_xformat = PIXEL_8_PACKED;
	}


	/* La routine de transparence ne gŠre pas le          */
	/* mode 8/4 bits Plan, donc on travaille en 8 bits    */
	/* Packed et on convertit en 8/4 bits Plan … la fin   */


	tga_image->format_need = pixel_xformat;
	tga_image->vdi_align16 = TGA_VDI_ALIGN16;



	/*if( TGA_load(fichier, tga_image) !=0 )
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


	/* l'image a été décodé a tga_image->adr_decode,       */
	/* on convertit l'image en 8/4 bits plan si necessaire */
/*	if( Fcm_screen.pixel_xformat==PIXEL_8_PLAN || Fcm_screen.pixel_xformat==PIXEL_4_PLAN)*/   /*  ------------------ */
	{
		switch( Fcm_screen.pixel_xformat )
		{
			case PIXEL_4_PLAN:
				TGA_SA_8packed_to_4plan( tga_image );
				break;
			case PIXEL_8_PLAN:
				Conversion_packed_to_plan( tga_image );
				break;
		}
	}


	/* On cree la surface pour le sprite */
	surface->nb_plan = FCMGFX_SCREEN_NBPLAN;
	surface->width   = tga_image->frame_width;
	surface->height  = tga_image->frame_height;

	if( Fcm_create_surface(surface, mfdb) != TRUE )
	{
		return( MAKE_SPRITE_ERROR_CREATE_SURFACE );
	}


	/*#ifdef LOG_FILE
	sprintf( buf_log, "Fcm_transfert_image_to_mfdb()"CRLF );
	log_print(FALSE);
	#endif*/


	/* on transfert le sprite dans sa surface definitive */
	Fcm_transfert_image_to_mfdb( tga_image, mfdb );


	/* affichage sprite a l'ecran (debug) */
	/*pxy[0]=0;
	pxy[1]=0;
	pxy[2]=mfdb->fd_w-1;
	pxy[3]=mfdb->fd_h-1;
	pxy[4]=0;
	pxy[5]=0;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];
	vro_cpyfm(vdihandle,3,pxy, mfdb, &Fcm_mfdb_ecran);
	evnt_timer(1000);*/



	/* on libere l'image TGA */
/*	TGA_free( tga_image );*/
	Fcm_libere_TGA( tga_image );




	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"Sprite charg‚ en %ld/200"CRLF""CRLF, Fcm_get_timer()-timer );
	log_print(FALSE);
	#endif


	return 0L;

}

#endif  /* ___FCM_MAKE_SPRITE_OPAQUE_C___ */

