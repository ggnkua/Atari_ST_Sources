/* **[Offscreen]**************** */
/* *                           * */
/* * 02/02/2016 MaJ 07/02/2016 * */
/* ***************************** */




#ifndef ___refresh_rsc_info_sys___
#define ___refresh_rsc_info_sys___




/* prototype */
void refresh_rsc_info_sys( void );




/* Fonction */
void refresh_rsc_info_sys( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# refresh_rsc_info_sys()"CRLF );
	log_print( FALSE );
	#endif


	Fcm_set_rsc_string( DL_INFO_SYSTEM, INFO_COOKIE_EDDI, info_eddi );
	Fcm_set_rsc_string( DL_INFO_SYSTEM, INFO_COOKIE_NVDI, info_nvdi );
	Fcm_set_rsc_string( DL_INFO_SYSTEM, INFO_COOKIE_CT60, info_ct60 );
	Fcm_set_rsc_string( DL_INFO_SYSTEM, INFO_COOKIE_PCI,  info_pci );
	Fcm_set_rsc_string( DL_INFO_SYSTEM, INFO_COOKIE_SUPV, info_supv );

	Fcm_set_rsc_string( DL_INFO_SYSTEM, INFO_SYS_REZ, info_rez );

	Fcm_set_rsc_string( DL_INFO_SYSTEM, INFO_VRAM_FREE, info_vram_free );

	Fcm_set_rsc_string( DL_INFO_SYSTEM, INFO_SYS_ATI, info_ati_device );




	return;


}


#endif   /* ___refresh_rsc_adresse___ */

