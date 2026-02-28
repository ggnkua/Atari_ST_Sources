/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 07/02/2016 * */
/* ***************************** */




#include "build_screen_vdi.c"
#include "build_screen_vram.c"
#include "build_screen_stram.c"
#include "build_screen_ttram.c"
#include "build_screen_ct60_vram.c"

#include "replace_fenetre_vram.c"
#include "replace_fenetre_test.c"




/* prototype */
void change_offscreen_mode( void );




/* Fonction */
void change_offscreen_mode( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# change_offscreen_mode()"CRLF );
	log_print( FALSE );
	#endif




	switch( offscreen_mode )
	{

		case RB_STAT_OFF_VDI:
			*(&mfdb_offscreen) = *(&mfdb_offscreen_vdi);
			pf_build_screen = build_screen_vdi;
			break;

		case RB_STAT_OFF_VRAM:
			mfdb_offscreen.fd_addr=0L;
			pf_build_screen = build_screen_vram;
			break;

		case RB_STAT_OFF_STRM:
			*(&mfdb_offscreen) = *(&mfdb_offscreen_stram);
			pf_build_screen = build_screen_stram;
			break;

		case RB_STAT_OFF_TTRM:
			*(&mfdb_offscreen) = *(&mfdb_offscreen_ttram);
			pf_build_screen = build_screen_ttram;
			break;

		case RB_STAT_CT60_VRM:
			*(&mfdb_offscreen) = *(&mfdb_offscreen_ct60_vram);
			pf_build_screen = build_screen_ct60_vram;
			break;
	}


	gb_frame_fps  = 0;
	octet_total   = 0;
	octet_redraw  = 0;



	if( offscreen_mode != RB_STAT_OFF_VRAM )
	{
		if( h_win[W_SPRITE_OFFSCREEN] != FCM_NO_OPEN_WINDOW )
		{
			buffer_aes[0]=WM_CLOSED;
			buffer_aes[1]=ap_id;
			buffer_aes[2]=0;
			buffer_aes[3]=h_win[W_SPRITE_OFFSCREEN];
			appl_write( ap_id, 16, &buffer_aes );
		}

		replace_fenetre_test();
	}
	else
	{
		replace_fenetre_vram();
	}



	return;


}

