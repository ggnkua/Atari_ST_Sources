/* **[Offscreen]**************** */
/* *                           * */
/* * 01/01/2016 MaJ 01/01/2016 * */
/* ***************************** */


#ifndef ___replace_fenetre_test___
#define ___replace_fenetre_test___



#include	"fonction/coeur/Fcm_gestion_aes_message.c"




/* prototype */
void replace_fenetre_test( void );



/* Fonction */
void replace_fenetre_test( void )
{
	int16	winx,winy,winw,winh;



	if( h_win[W_OFFSCREEN] != FCM_NO_OPEN_WINDOW )
	{
		if( win_iconified[W_OFFSCREEN]==TRUE )
		{
			buffer_aes[0]=WM_UNICONIFY;
			buffer_aes[1]=ap_id;
			buffer_aes[2]=0;
			buffer_aes[3]=h_win[W_OFFSCREEN];
			buffer_aes[4]=win_posxywh[W_OFFSCREEN][0];
			buffer_aes[5]=win_posxywh[W_OFFSCREEN][1];
			buffer_aes[6]=win_posxywh[W_OFFSCREEN][2];
			buffer_aes[7]=win_posxywh[W_OFFSCREEN][3];
			appl_write( ap_id, 16, &buffer_aes );

			Fcm_gestion_aes_message();
		}

		wind_get(h_win[W_OFFSCREEN],WF_CURRXYWH,&winx,&winy,&winw,&winh);
	}
	else
	{
		winx=win_posxywh[W_OFFSCREEN][0];
		winy=win_posxywh[W_OFFSCREEN][1];
		winw=win_posxywh[W_OFFSCREEN][2];
		winh=win_posxywh[W_OFFSCREEN][3];
		win_posxywh[W_OFFSCREEN][1]=-1;
	}






	winx = MAX( 0, winx );
	winx = MIN( (Fcm_screen.width-winw-2), winx );

	winy = MAX( 0, winy );
	winy = MIN( (Fcm_screen.height-winh-2), winy );

	if( win_posxywh[W_OFFSCREEN][0]!=winx || win_posxywh[W_OFFSCREEN][1]!=winy )
	{
		win_posxywh[W_OFFSCREEN][0]=winx;
		win_posxywh[W_OFFSCREEN][1]=winy;
		win_posxywh[W_OFFSCREEN][2]=winw;
		win_posxywh[W_OFFSCREEN][3]=winh;

		if( h_win[W_OFFSCREEN] != FCM_NO_OPEN_WINDOW )
		{
			wind_close ( h_win[W_OFFSCREEN] );
			wind_delete( h_win[W_OFFSCREEN] );
			h_win[W_OFFSCREEN]=FCM_NO_OPEN_WINDOW;

			Fcm_gestion_aes_message();
		}

		ouvre_fenetre_offscreen();

	}
	else
	{
		buffer_aes[0]=WM_TOPPED;
		buffer_aes[1]=ap_id;
		buffer_aes[2]=0;
		buffer_aes[3]=h_win[W_OFFSCREEN];
		appl_write( ap_id, 16, &buffer_aes );
	}


	Fcm_gestion_aes_message();


	return;


}


#endif   /*  ___replace_fenetre_test___  */

