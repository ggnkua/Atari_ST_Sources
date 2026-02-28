/* **[Offscreen]**************** */
/* *                           * */
/* * 28/12/2015 MaJ 27/01/2016 * */
/* ***************************** */




#ifndef ___make_ram_surface___
#define ___make_ram_surface___


#include "fonction/graphique/fcm_create_surface.h"




int32 make_ram_surface( SURFACE *surface, MFDB *mfdb, int16 nbplan, int16 width, int16 height, int16 ram_mode );




/* Fonction */
int32 make_ram_surface( SURFACE *surface, MFDB *mfdb, int16 nbplan, int16 width, int16 height, int16 ram_mode  )
{

	int32 ram_adresse;
	int32 ram_size;


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"make_ram_surface(%p,%p,%d,%d,%d,%d)"CRLF, surface, mfdb, nbplan, width, height, ram_mode );
	log_print(FALSE);
	#endif



	surface->handle_offscreen = 0;
	surface->adresse_buffer   = 0;
	surface->adresse_malloc   = 0;


	mfdb->fd_addr    = (uint32 *)0;



	/* width doit etre un multiple de 16 pour la vdi */
	if( nbplan != 1)
	{
		if( nbplan == 15)
		{
			ram_size = ((width+15) & 0xfff0) * height * (16/8);
		}
		else
		{
			ram_size = ((width+15) & 0xfff0) * height * (nbplan/8);
		}
	}
	else
	{
		ram_size = (  ((width+15) & 0xfff0) * height  ) / 8;
	}


	/* Pour avoir une adresse multiple de 256 */
	ram_size=ram_size+256;

	ram_adresse = Fcm_reserve_ram( ram_size, ram_mode );


	if( ram_adresse == 0 )
	{
		return( OFFSCREEN_ERROR_INIT_STRAM );
	}

	surface->adresse_malloc = ram_adresse;
	surface->adresse_buffer = (ram_adresse+255)&0xFFFFFF00;

	mfdb->fd_addr    = (uint32 *)surface->adresse_buffer;
	mfdb->fd_w       = width;
	mfdb->fd_h       = height;
	mfdb->fd_wdwidth = (width+15)/16;
	mfdb->fd_stand   = 0;
	mfdb->fd_nplanes = nbplan;
	mfdb->fd_r1      = 0;
	mfdb->fd_r2      = 0;
	mfdb->fd_r3      = 0;


	return 0L;


}


#endif /* ___make_ram_surface___ */

