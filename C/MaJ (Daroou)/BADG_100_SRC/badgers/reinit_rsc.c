/* **[Badgers]****************** */
/* *                           * */
/* * 22/07/2017 MaJ 12/11/2023 * */
/* ***************************** */

void reinit_rsc( void );






void reinit_rsc( void )
{

	/* le redemmarage pour le mode mono/couleur ne recharge pas le RSC, ni set_config */
	/* uniquement le changement de langue du RSC recharge le RSC et doit etre reinit  */

	#ifdef LOG_FILE
	sprintf( buf_log, " * reinit_rsc()"CRLF );
	log_print( FALSE );
	#endif


	rescale_rsc_options();



	return;


}

