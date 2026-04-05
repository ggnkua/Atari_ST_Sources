/* ***************************** */
/* * 08/08/2017 MaJ 08/08/2017 * */
/* ***************************** */




#ifndef ___Fcm_open_offscreen_bitmap___
#define ___Fcm_open_offscreen_bitmap___


#include	"Fcm_create_surface.h"



void Fcm_open_offscreen_bitmap( SURFACE *surface, MFDB *mfdb );




/* Fonction */
void Fcm_open_offscreen_bitmap( SURFACE *surface, MFDB *mfdb )
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# Fcm_open_offscreen_bitmap(surface:$%p, MFDB:$%p)"CRLF, (void*)surface, (void*)mfdb );
	log_print(FALSE);
	#endif


	/* ----------------------------------------- */
	/* on tente l'ouverture d'un ecran offscreen */
	/* ----------------------------------------- */
	if( Fcm_screen.eddi_version > 0x99 )  /* 1.00 minimum */
	{
		int16 work_in[20];
		int16 work_out[280]; /* normalement 56 elements: http://wikipendium.free.fr/nvdi/nvdi4_en/html/0205.htm#OPEN%20BITMAP%20%28VDI%20100%2C%201%29 */
		int16 handle_bitmap;
		int16 dummy;

		handle_bitmap=graf_handle( &dummy, &dummy, &dummy, &dummy );

		work_in[ 0]=1;
		work_in[ 1]=1;
		work_in[ 2]=1;
		work_in[ 3]=1;
		work_in[ 4]=1;
		work_in[ 5]=1;
		work_in[ 6]=1;
		work_in[ 7]=1;
		work_in[ 8]=1;
		work_in[ 9]=1;
		work_in[10]=2;
		work_in[11]=surface->width-1;
		work_in[12]=surface->height-1;
		work_in[13]=0;
		work_in[14]=0;
		work_in[15]=0;
		work_in[16]=0;
		work_in[17]=0;
		work_in[18]=0;
		work_in[19]=0;

		v_opnbm(work_in, mfdb, &handle_bitmap, work_out);


		if( handle_bitmap != 0 )
		{
/*			#ifdef LOG_FILE
			sprintf( buf_log, " ouverture ecran offscreen reussi"CRLF );
			log_print(FALSE);
			sprintf( buf_log, " -> handle_bitmap=%d"CRLF, handle_bitmap );
			log_print( FALSE );
			sprintf( buf_log, " -> mfdb.fd_addr=$%08lx"CRLF,(int32)mfdb->fd_addr );
			log_print( FALSE );
			sprintf( buf_log, " -> mfdb.fd_w=%d"CRLF,mfdb->fd_w );
			log_print( FALSE );
			sprintf( buf_log, " -> mfdb.fd_h=%d"CRLF,mfdb->fd_h );
			log_print( FALSE );
			sprintf( buf_log, " -> mfdb.fd_wdwidth=%d"CRLF,mfdb->fd_wdwidth );
			log_print( FALSE );
			sprintf( buf_log, " -> mfdb.fd_stand=%d"CRLF,mfdb->fd_stand );
			log_print( FALSE );
			sprintf( buf_log, " -> mfdb.fd_nplanes=%d"CRLF,mfdb->fd_nplanes );
			log_print( FALSE );
			sprintf( buf_log, " -> mfdb.fd_r1=%d"CRLF,mfdb->fd_r1 );
			log_print( FALSE );
			#endif*/

			surface->handle_VDIoffscreen = handle_bitmap;

		}
		else
		{
			#ifdef LOG_FILE
			sprintf( buf_log, " echec ouverture surface offscreen (handle_bitmap=%d)"CRLF, handle_bitmap );
			log_print(FALSE);
			#endif
		}
	}
	else
	{
		#ifdef LOG_FILE
		sprintf( buf_log, " offscreen bitmap non disponible"CRLF );
		log_print(FALSE);
		#endif
	}


	#ifdef LOG_FILE
	sprintf( buf_log, " -> Fcm_screen.eddi_version=0x%x "CRLF, Fcm_screen.eddi_version );
	log_print( FALSE );
	sprintf( buf_log, " -> handle_bitmap=%d (surface->handle_VDIoffscreen)"CRLF, surface->handle_VDIoffscreen );
	log_print( FALSE );
	sprintf( buf_log, " -> mfdb.fd_addr=$%08lx"CRLF,(int32)mfdb->fd_addr );
	log_print( FALSE );
	sprintf( buf_log, " -> mfdb.fd_w=%d"CRLF,mfdb->fd_w );
	log_print( FALSE );
	sprintf( buf_log, " -> mfdb.fd_h=%d"CRLF,mfdb->fd_h );
	log_print( FALSE );
	sprintf( buf_log, " -> mfdb.fd_wdwidth=%d"CRLF,mfdb->fd_wdwidth );
	log_print( FALSE );
	sprintf( buf_log, " -> mfdb.fd_stand=%d"CRLF,mfdb->fd_stand );
	log_print( FALSE );
	sprintf( buf_log, " -> mfdb.fd_nplanes=%d"CRLF,mfdb->fd_nplanes );
	log_print( FALSE );
	sprintf( buf_log, " -> mfdb.fd_r1=%d"CRLF,mfdb->fd_r1 );
	log_print( FALSE );
	#endif

	return;


}


#endif /* ___Fcm_open_offscreen_bitmap___ */

