/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 07/03/2024 MaJ 07/03/2024 * */
/* ***************************** */



/*

  Cette fonction modifie un OBJET texte du RSC avec une valeur int32

*/


#ifndef __FCM_SET_RSC_STRING_INT32_C__
#define __FCM_SET_RSC_STRING_INT32_C__


void Fcm_set_rsc_string_int32( const int16 idx_dialogue, const int16 objet, const int32 valeur )
{
	char buffer_int32[16];


	FCM_LOG_PRINT3("* Fcm_set_rsc_string_int32(dial:%d, obj:%d, val:(%ld))", idx_dialogue, objet, valeur );

	snprintf( buffer_int32, 16, "%ld", valeur );
	Fcm_set_rsc_string( idx_dialogue, objet, buffer_int32 );

	return;

}


#endif  /*  __FCM_SET_RSC_STRING_INT32_C__  */

