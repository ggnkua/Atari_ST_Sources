/* ***************************** */
/* *                           * */
/* * 24/12/2015 MaJ 24/12/2015 * */
/* ***************************** */




#ifndef ___Fcm_make_mask___
#define ___Fcm_make_mask___



#include "../coeur/coeur_define.c"

#include "Fcm_create_surface.c"
#include "Fcm_free_surface.c"
#include "Fcm_create_mask.c"


#define MAKE_SPRITE_ERROR_TGA_LOAD       (-1001)
#define MAKE_SPRITE_ERROR_CREATE_SURFACE (-1002)




/* prototype */
int32 Fcm_make_mask( s_tga_ldg *image_tga, SURFACE *surface_mask, MFDB *mfdb_mask, char *fichier, int16 x, int16 y );



/* Fonction */
int32 Fcm_make_mask( s_tga_ldg *image_tga, SURFACE *surface_mask, MFDB *mfdb_mask, char *fichier, int16 x, int16 y )
{
	int16 pixel_xformat;
	MFDB  mfdb_temp;

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
	sprintf( buf_log, CRLF"Fcm_make_mask()"CRLF );
	log_print(FALSE);
	#endif




	if( TGA_load(fichier, image_tga) !=0 )
	{
		return( MAKE_SPRITE_ERROR_TGA_LOAD );
	}


	mfdb_temp.fd_addr=(uint32 *)image_tga->adr_decode;
	mfdb_temp.fd_w=image_tga->frame_width;
	mfdb_temp.fd_h=image_tga->frame_height;
	mfdb_temp.fd_wdwidth=image_tga->frame_width/16;
	mfdb_temp.fd_nplanes=Fcm_screen.nb_plan;
	mfdb_temp.fd_stand=0;
	mfdb_temp.fd_r1=0;
	mfdb_temp.fd_r2=0;
	mfdb_temp.fd_r3=0;


	surface_mask->nb_plan = 1;
	surface_mask->width   = image_tga->frame_width;
	surface_mask->height  = image_tga->frame_height;


	#ifdef LOG_FILE
	sprintf( buf_log, "Fcm_create_surface mask"CRLF );
	log_print(FALSE);
	#endif



	if( Fcm_create_surface(surface_mask, mfdb_mask) != TRUE )
	{
		return( MAKE_SPRITE_ERROR_CREATE_SURFACE );
	}

	Fcm_create_mask( &mfdb_temp, mfdb_mask, x, y );


	TGA_free( image_tga );


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"Sprite charg‚ en %ld/200"CRLF""CRLF, Fcm_get_timer()-timer );
	log_print(FALSE);
	#endif


	return 0L;


}


#endif

