/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 02/05/2003 MaJ 03/03/2024 * */
/* ***************************** */



#ifndef __FCM_GET_WIN_PARAMETRE_C__
#define __FCM_GET_WIN_PARAMETRE_C__


int16 Fcm_get_win_parametre( const char *pt_config )
{
	char	winpos_buffer[16];
	uint16  idx;


	FCM_LOG_PRINT1( CRLF"* Fcm_get_win_parametre(%p)", pt_config );



	for( idx=0; idx < NB_FENETRE; idx++)
	{
		/*FCM_LOG_PRINT1( CRLF"  - Win idx [%d]", idx );*/

		sprintf( winpos_buffer, "WINPOS_%02dX=", idx );
		win_posxywh[idx][0] = Fcm_get_tag_int32( winpos_buffer, pt_config );
		/*FCM_LOG_PRINT2( "  win_posxywh[%d][0]=%d", idx, win_posxywh[idx][0] );*/

		sprintf( winpos_buffer, "WINPOS_%02dY=", idx );
		win_posxywh[idx][1] = Fcm_get_tag_int32( winpos_buffer, pt_config );
		/*FCM_LOG_PRINT2( "  win_posxywh[%d][1]=%d", idx, win_posxywh[idx][1] );*/

		sprintf( winpos_buffer, "WINPOS_%02dW=", idx );
		win_posxywh[idx][2] = Fcm_get_tag_int32( winpos_buffer, pt_config );
		/*FCM_LOG_PRINT2( "  win_posxywh[%d][2]=%d", idx, win_posxywh[idx][2] );*/

		sprintf( winpos_buffer, "WINPOS_%02dH=", idx );
		win_posxywh[idx][3] = Fcm_get_tag_int32( winpos_buffer, pt_config );
		/*FCM_LOG_PRINT2( "  win_posxywh[%d][3]=%d", idx, win_posxywh[idx][3] );*/



		if( idx != W_CONSOLE )
		{
			/* La console peut etre ouverte automatiquement en cas de message console    */
			/* et avant de charger la config, donc on ne tient pas compte de la valeur   */
			/* sauver en config, sinon on peut ecraser l'handle de la console si ouverte */

			sprintf( winpos_buffer, "WINPOS_%02dOpen=", idx );
			h_win[idx] = Fcm_get_tag_int32( winpos_buffer, pt_config );
			FCM_LOG_PRINT2( "  h_win[%idx]=%d", idx, h_win[idx] );

			/* verification de la valeur */
			if( h_win[idx] != FCM_GO_OPEN_WINDOW )
			{
				h_win[idx] = FCM_NO_OPEN_WINDOW;
			}
		}
	}


	return 0;


}


#endif   /*   __FCM_GET_WIN_PARAMETRE_C__   */

