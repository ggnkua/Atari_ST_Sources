/* ***************************** */
/* *                           * */
/* * 24/12/2015 MaJ 10/11/2023 * */
/* ***************************** */


/* pour les sprites monochromes qui n'ont pas de partie 'opaque',       */
/* pas besoin de sprite+mask, uniquement un mask affiché en transparent */



#ifndef ___FCM_MAKE_MASK_C___
#define ___FCM_MAKE_MASK_C___




#include "fcm_create_surface.c"





/* prototype */
int32 Fcm_make_mask( s_tga_ldg *tga_image, SURFACE *surface_mask, MFDB *mfdb_mask, char *fichier, int16 x, int16 y );



/* Fonction */
int32 Fcm_make_mask( s_tga_ldg *tga_image, SURFACE *surface_mask, MFDB *mfdb_mask, char *fichier, int16 x, int16 y )
{

	#ifdef LOG_FILE
	int32 timer;
	timer=(int32)Fcm_get_timer();
	#endif


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"Fcm_make_mask(%p, %p, %p, %s, %d, %d)"CRLF, tga_image, surface_mask, mfdb_mask, fichier, x, y );
	log_print(FALSE);
	#endif


	surface_mask->handle_VDIoffscreen = SURFACE_NO_OPEN_VDI_OFFSCREEN_BITMAP;


	/* on travaille en 8bits packed */
	tga_image->format_need = PIXEL_8_PACKED;
	tga_image->vdi_align16 = TGA_VDI_ALIGN16;


	/* Free RAM */
/*	#ifdef LOG_FILE
	{
		if( systeme.gemdos_version >= 0x19 )
		{
			sprintf( buf_log, "  - ST RAM free : %ld ( Mxalloc(-1, MX_STRAM) )"CRLF, Mxalloc(-1, MX_STRAM) );
			log_print(FALSE);
			sprintf( buf_log, "  - TT RAM free : %ld ( Mxalloc(-1, MX_TTRAM) )"CRLF, Mxalloc(-1, MX_TTRAM) );
			log_print(FALSE);
		}
		sprintf( buf_log, "  -    RAM free : %ld ( Malloc(-1) , depend du flag PRG)"CRLF, Malloc(-1) );
		log_print(FALSE);
	}
	#endif
*/

	{
		int32 reponse;
		reponse = Fcm_charge_TGA(fichier, tga_image, FCM_CHARGE_TGA_MODE_MONO);
		if( reponse != 0 )
		{
			return( reponse );
		}
	}

	surface_mask->nb_plan = 1;
	surface_mask->width   = tga_image->frame_width;
	surface_mask->height  = tga_image->frame_height;


	if( Fcm_create_surface(surface_mask, mfdb_mask) != TRUE )
	{
		return( MAKE_SPRITE_ERROR_CREATE_SURFACE );
	}


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"Creation du mask"CRLF );
	log_print(FALSE);
	#endif


	{
		uint32  i;
		uint8   bit;
		uint8   bitmask;
		uint8  *ptmask8;
		uint8  *ptimage8;
		uint32  nb_pixel;
		uint8   alphacolor;

		ptimage8 = (uint8 *)tga_image->adr_decode;
		ptmask8  = (uint8 *)mfdb_mask->fd_addr;
		nb_pixel = (uint32 )tga_image->frame_width * (uint32)tga_image->frame_height;

		alphacolor = ptimage8[ (y * tga_image->frame_width) + x ];

		for( i=0; i<nb_pixel; )
		{
			bitmask=0;

			for( bit=0; bit<8; bit++)
			{
				if( *ptimage8++ != alphacolor )
				{
					bitmask++;
				}
				if( bit<7 )
				{
					bitmask=bitmask<<1;
				}
				i++;
			}
			*ptmask8++ = bitmask;
		}
	}

/*
{
int16 pxyt[8];
int16 couleur[2];

couleur[0]=0;
couleur[1]=15;

pxyt[0]=0;
pxyt[1]=0;
pxyt[2]=STAR_WIDTH-1;
pxyt[3]=STAR_HEIGHT-1;

pxyt[4]=32;
pxyt[5]=32;
pxyt[6]=pxyt[4]+pxyt[2];
pxyt[7]=pxyt[5]+pxyt[3];
vrt_cpyfm(vdihandle, MD_REPLACE, pxyt, mfdb_mask, &Fcm_mfdb_ecran, couleur);
}*/



	Fcm_libere_TGA( tga_image );

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"Sprite charg‚ en %ld/200"CRLF""CRLF, Fcm_get_timer()-(uint32)timer );
	log_print(FALSE);
	#endif


	return 0L;


}


#endif  /*   ___FCM_MAKE_MASK_C___   */

