/* **[Offscreen]**************** */
/* *                           * */
/* * 01/01/2016 MaJ 04/01/2016 * */
/* ***************************** */


#ifndef ___replace_fenetre_vram___
#define ___replace_fenetre_vram___



#include	"fonction/coeur/Fcm_gestion_aes_message.c"




/* prototype */
void replace_fenetre_vram( void );



/* Fonction */
void replace_fenetre_vram( void )
{
	int16	winx,winy,winw,winh;
	int16	winox,winoy,winow,winoh;


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


	if( h_win[W_SPRITE_OFFSCREEN] != FCM_NO_OPEN_WINDOW )
	{
		wind_get(h_win[W_SPRITE_OFFSCREEN],WF_CURRXYWH,&winox,&winoy,&winow,&winoh);
	}
	else
	{
		winox=win_posxywh[W_SPRITE_OFFSCREEN][0];
		winoy=win_posxywh[W_SPRITE_OFFSCREEN][1];
		winow=win_posxywh[W_SPRITE_OFFSCREEN][2];
		winoh=win_posxywh[W_SPRITE_OFFSCREEN][3];
		win_posxywh[W_SPRITE_OFFSCREEN][1]=-1;
	}

/*	{
		char texte[256];


		sprintf(texte,"winx=%d  winy=%d  winw=%d  winh=%d ", winx, winy, winw, winh );
		v_gtext(vdihandle,50*8,2*16, texte);
		sprintf(texte,"winox=%d winoy=%d winow=%d winoh=%d ", winox, winoy, winow, winoh );
		v_gtext(vdihandle,50*8,3*16, texte);
	}*/

	if( winx > winox )
	{

		winx = MAX( (winow), winx );
		winx = MIN( (Fcm_screen.width-winw), winx );

		winy = MAX( 0, winy );
		winy = MIN( (Fcm_screen.height-winh), winy );


		winox = MAX( 0, winox );
		winox = MIN( (winx-winow), winox );

		winoy = MAX( 0, winoy );
		winoy = MIN( (Fcm_screen.height-winoh), winoy );
	}


	if( winx < winox )
	{
		winx = MAX( 0, winx );
		winx = MIN( (Fcm_screen.width-winw-winow), winx );

		winy = MAX( 0, winy );
		winy = MIN( (Fcm_screen.height-winh), winy );


		winox = MAX( (winx+winw), winox );
		winox = MIN( (Fcm_screen.width-winow), winox );

		winoy = MAX( 0, winoy );
		winoy = MIN( (Fcm_screen.height-winoh), winoy );
	}



/*	{
		char texte[256];


		sprintf(texte,"winx=%d  winy=%d  winw=%d  winh=%d ", winx, winy, winw, winh );
		v_gtext(vdihandle,50*8,4*16, texte);
		sprintf(texte,"winox=%d winoy=%d winow=%d winoh=%d ", winox, winoy, winow, winoh );
		v_gtext(vdihandle,50*8,5*16, texte);
	}*/




	if( win_posxywh[W_SPRITE_OFFSCREEN][0]!=winox || win_posxywh[W_SPRITE_OFFSCREEN][1]!=winoy )
	{
		win_posxywh[W_SPRITE_OFFSCREEN][0]=winox;
		win_posxywh[W_SPRITE_OFFSCREEN][1]=winoy;
		win_posxywh[W_SPRITE_OFFSCREEN][2]=winow;
		win_posxywh[W_SPRITE_OFFSCREEN][3]=winoh;

		if( h_win[W_SPRITE_OFFSCREEN] != FCM_NO_OPEN_WINDOW )
		{
			wind_close ( h_win[W_SPRITE_OFFSCREEN] );
			wind_delete( h_win[W_SPRITE_OFFSCREEN] );
			h_win[W_SPRITE_OFFSCREEN]=FCM_NO_OPEN_WINDOW;

			Fcm_gestion_aes_message();
		}

		ouvre_fenetre_sprite_offscreen();

	}
	else
	{
		buffer_aes[0]=WM_TOPPED;
		buffer_aes[1]=ap_id;
		buffer_aes[2]=0;
		buffer_aes[3]=h_win[W_SPRITE_OFFSCREEN];
		appl_write( ap_id, 16, &buffer_aes );
	}

	Fcm_gestion_aes_message();




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


#endif   /*  ___replace_fenetre_vram___  */

