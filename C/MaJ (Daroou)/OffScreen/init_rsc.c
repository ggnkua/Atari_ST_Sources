/* **[Offscreen]**************** */
/* *                           * */
/* * 19/12/2015 MaJ 05/01/2016 * */
/* ***************************** */



#include	"refresh_rsc_adresse.c"
#include	"refresh_rsc_bench.c"
#include	"refresh_rsc_stats.c"
#include	"refresh_rsc_info_sys.c"



/* prototype */
void init_rsc( void );




/* Fonction */
void init_rsc( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# init_rsc()"CRLF );
	log_print( FALSE );
	#endif

	refresh_rsc_stats();
	refresh_rsc_adresse();
	refresh_rsc_bench();
	refresh_rsc_info_sys();


	return;


}

