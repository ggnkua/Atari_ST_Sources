/* ***************************** */
/* *                           * */
/* * 20/08/2015 MaJ 24/10/2015 * */
/* ***************************** */




#ifndef ___Fcm_make_sprite_texte_transparent___
#define ___Fcm_make_sprite_texte_transparent___


#define CODAGE "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890:.()"


#include "../coeur/coeur_define.c"

#include "Fcm_make_sprite.h"

#include "Fcm_create_surface.c"
#include "Fcm_free_surface.c"
#include "Fcm_transfert_surface_to_mfdb.c"
#include "Fcm_set_transparence.c"
#include "Fcm_create_mask.c"






/* prototype */
int32 Fcm_make_sprite_texte_transparent( SURFACE *surface, SURFACE *surface_mask, MFDB *mfdb, MFDB *mfdb_mask, MFDB *mfdb_fonte, char *texte, int16 largeur, int16 hauteur );



/* Fonction */
int32 Fcm_make_sprite_texte_transparent( SURFACE *surface, SURFACE *surface_mask, MFDB *mfdb, MFDB *mfdb_mask, MFDB *mfdb_fonte, char *texte, int16 largeur, int16 hauteur )
{
	int16 pixel_xformat;
	int16 longueur_texte;




	longueur_texte = strlen(texte);


	pixel_xformat = Fcm_screen.pixel_xformat;

	/* gestion du mode 8 bit planar */
	if( pixel_xformat == PIXEL_8_PLAN )
	{
		pixel_xformat = PIXEL_8_PACKED;
	}

	/* La routine de transparence ne gŠre pas le      */
	/* mode 8 bits Plan, donc on travaille en 8 bits  */
	/* Packed et on convertit en 8 bits Plan … la fin */



	image_tga.format_need = pixel_xformat;
	image_tga.vdi_align16 = TGA_VDI_ALIGN16;



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"Fcm_make_sprite_texte_transparent()"CRLF );
	log_print(FALSE);
	#endif


	surface->nb_plan = SCREEN_PLAN;
	surface->width   = largeur * longueur_texte;
	surface->height  = hauteur;


	#ifdef LOG_FILE
	sprintf( buf_log, "Fcm_create_surface mfdb()"CRLF );
	log_print(FALSE);
	#endif


	if( Fcm_create_surface(surface, mfdb) != TRUE )
	{
		return( MAKE_SPRITE_ERROR_CREATE_SURFACE );
	}



	#ifdef LOG_FILE
	sprintf( buf_log, "Ecriture texte {%s} %d lettre"CRLF,texte, longueur_texte );
	log_print(FALSE);
	#endif



/*		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=mfdb_fonte->fd_w-1;
		pxy[3]=mfdb_fonte->fd_h-1;
		pxy[4]=32;
		pxy[5]=160;
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  mfdb_fonte, &Fcm_mfdb_ecran);


		pxy[0]=16;
		pxy[1]=0;
		pxy[2]=pxy[0]+15;
		pxy[3]=15;
		pxy[4]=32;
		pxy[5]=180;
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  mfdb_fonte, &Fcm_mfdb_ecran);



		pxy[0]=160;
		pxy[1]=0;
		pxy[2]=pxy[0]+15;
		pxy[3]=15;
		pxy[4]=32;
		pxy[5]=200;
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  mfdb_fonte, &Fcm_mfdb_ecran);
*/



	{
		int16  lettre;
		char  *pt_position;
		char   lettre_code_x;


		for( lettre=0; lettre<(longueur_texte-0); lettre++ )
		{

			pt_position = strchr( CODAGE, texte[lettre] );


	#ifdef LOG_FILE
	sprintf( buf_log, "lettre=%d pt_position=%c"CRLF, lettre, *pt_position );
	log_print(FALSE);
	#endif

/*	evnt_timer(2000);*/

			if( pt_position != NULL )
			{
				lettre_code_x = (char)(pt_position-CODAGE);


	#ifdef LOG_FILE
	sprintf( buf_log, "lettre_code_x=%d"CRLF, lettre_code_x );
	log_print(FALSE);
	#endif

				pxy[0]=lettre_code_x * largeur;
				pxy[1]=0;
				pxy[2]=pxy[0]+largeur-1;
				pxy[3]=hauteur-1;

				pxy[4]=lettre * largeur;
				pxy[5]=0;
				pxy[6]=pxy[4]+largeur-1;
				pxy[7]=hauteur-1;
				vro_cpyfm(vdihandle, 3, pxy, mfdb_fonte,  &Fcm_mfdb_ecran);
				vro_cpyfm(vdihandle, 3, pxy, mfdb_fonte,  mfdb);

			}
			else
			{
				int16 idx;

				pxy[0]=largeur-1;
				pxy[1]=0;
				pxy[2]=pxy[0];
				pxy[3]=hauteur-1;

				for( idx=0; idx<largeur; idx++ )
				{
					pxy[4]=(lettre * largeur)+idx;
					pxy[5]=0;
					pxy[6]=pxy[4];
					pxy[7]=hauteur-1;
					vro_cpyfm(vdihandle, 3, pxy, mfdb_fonte,  &Fcm_mfdb_ecran);
					vro_cpyfm(vdihandle, 3, pxy, mfdb_fonte,  mfdb);
				}
			}



		}

	}


	surface_mask->nb_plan = 1;
	surface_mask->width   = surface->width;
	surface_mask->height  = surface->height;


	#ifdef LOG_FILE
	sprintf( buf_log, "Fcm_create_surface mask"CRLF );
	log_print(FALSE);
	#endif


	if( Fcm_create_surface(surface_mask, mfdb_mask) != TRUE )
	{
		return( MAKE_SPRITE_ERROR_CREATE_SURFACE );
	}


	Fcm_create_mask( mfdb, mfdb_mask, largeur-1, 0 );


/*	pxy[4]=10;
	pxy[5]=440;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];

	vrt_cpyfm(vdihandle,2,pxy, mfdb_mask, &Fcm_mfdb_ecran, mask_couleur);
*/


	Fcm_set_transparence( mfdb, largeur-1, 0 );


/*	TGA_free( image_tga );*/



	if( Fcm_screen.pixel_xformat == PIXEL_8_PLAN )
	{
		image_tga.adr_decode   = (uint32)mfdb->fd_addr;
		image_tga.frame_width  = mfdb->fd_w;
		image_tga.frame_height = mfdb->fd_h;

		Conversion_packed_to_plan( &image_tga );
	}




/*	pxy[4]=10;
	pxy[5]=470;
	pxy[6]=pxy[4]+pxy[2];
	pxy[7]=pxy[5]+pxy[3];
	vro_cpyfm(vdihandle,3,pxy, mfdb, &Fcm_mfdb_ecran);
*/


	return 0L;


}



#endif


