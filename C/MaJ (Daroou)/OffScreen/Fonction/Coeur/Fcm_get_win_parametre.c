/* **[Fonction commune]************** */
/* * R‚cup‚ration paramŠtre fenˆtre * */
/* * 02/05/2003 - 11/01/2015        * */
/* ********************************** */


#ifndef __Fcm_get_win_parametre__
#define __Fcm_get_win_parametre__



#include "Fcm_Conversion_ASCII_to_long.c"


#define BUFFER_WPARAM  (16)



/* Prototype */
int16 Fcm_get_win_parametre( const char *pt_config );


/* Fonction */
int16 Fcm_get_win_parametre( const char *pt_config )
{
	char	my_buffer[BUFFER_WPARAM];
	int16	reponse;
	uint16  index;




	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"* Fcm_get_win_parametre"CRLF );
	log_print(FALSE);
	#endif

	for( index=0; index<NB_FENETRE; index++)
	{
		#ifdef LOG_FILE
		sprintf( buf_log, CRLF""TAB8"- Win index [%d]"CRLF, index );
		log_print(FALSE);
		#endif

		sprintf( my_buffer, "WINPOS_%02dX=", index );
		reponse=Fcm_get_tag( my_buffer, my_buffer, BUFFER_WPARAM, pt_config );
		if(reponse==TRUE) win_posxywh[index][0]=Fcm_conversion_ascii_to_long( my_buffer );


		sprintf( my_buffer, "WINPOS_%02dY=", index );
		reponse=Fcm_get_tag( my_buffer, my_buffer, BUFFER_WPARAM, pt_config );
		if(reponse==TRUE) win_posxywh[index][1]=Fcm_conversion_ascii_to_long( my_buffer );


		sprintf( my_buffer, "WINPOS_%02dW=", index );
		reponse=Fcm_get_tag( my_buffer, my_buffer, BUFFER_WPARAM, pt_config );
		if(reponse==TRUE) win_posxywh[index][2]=Fcm_conversion_ascii_to_long( my_buffer );


		sprintf( my_buffer, "WINPOS_%02dH=", index );
		reponse=Fcm_get_tag( my_buffer, my_buffer, BUFFER_WPARAM, pt_config );
		if(reponse==TRUE) win_posxywh[index][3]=Fcm_conversion_ascii_to_long( my_buffer );


		sprintf( my_buffer, "WINPOS_%02dOpen=", index );
		reponse=Fcm_get_tag( my_buffer, my_buffer, BUFFER_WPARAM, pt_config );
		if(reponse==TRUE)
		{
			h_win[index]=Fcm_conversion_ascii_to_long( my_buffer );
			if( h_win[index] >0 ) h_win[index]=FCM_GO_OPEN_WINDOW;
		}

	}


	return 0;


}

#undef BUFFER_WPARAM


#endif

