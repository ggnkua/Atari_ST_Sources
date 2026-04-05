/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 16/08/2003 MaJ 03/03/2024 * */
/* ***************************** */



void Fcm_libere_aes_vdi( void )
{

	FCM_LOG_PRINT("# Fcm_libere_aes_vdi()");


	/* fermeture de la station graphique VDI */
	v_clsvwk( vdihandle );


	/* On indique … l'AES que l'on a plus besoin de ses services */
	appl_exit();


#ifdef LOG_FILE
{
	int16 dummy;

	strcpy ( buf_log, CRLF"Fermeture session de "PRG_NOM);
	log_print( FALSE );
	dummy = Tgettime();
	sprintf( buf_log, " … %02d:%02d:%02d"CRLF""CRLF,((dummy>>11) & 31), ((dummy>>5) & 63), ((dummy & 31)<<1) );
	log_print( FALSE );
}
#endif


	return;


}

