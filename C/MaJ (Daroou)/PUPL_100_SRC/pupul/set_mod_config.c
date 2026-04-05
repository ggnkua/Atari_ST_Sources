/* **[Pupul]******************** */
/* *                           * */
/* * 08/11/2023 MaJ 08/11/2023 * */
/* ***************************** */



#ifndef  __SET_MOD_CONFIG__
 #define __SET_MOD_CONFIG__

#include  "../fonction/ldg/mod.h"


void set_mod_config( void );




/* Fonction */
void set_mod_config( void )
{
	
	#ifdef LOG_FILE
	sprintf( buf_log, "# set_mod_config()"CRLF );
	log_print(FALSE);
	#endif

	#ifdef LOG_FILE
	sprintf( buf_log, "global_mod_ldg_update=%d global_mod_ldg_frequence=%d"CRLF,global_mod_ldg_update, global_mod_ldg_frequence );
	log_print(FALSE);
	#endif


	/* Configuration de la fr‚quence et du mode d'alimentation de MOD.LDG */
	switch( global_mod_ldg_update )
	{
		case MODLDG_UPDATE_POLLING:
			mod_setup( SET_MCBUFMODE, MCINT_POLL_NORMAL );
			break;

		case MODLDG_UPDATE_TIMERA:
			mod_setup( SET_MCBUFMODE, MCINT_TIMERA );
			break;

		case MODLDG_UPDATE_MFPI7:
			mod_setup( SET_MCBUFMODE, MCINT_MFP7 );
			break;

		case MODLDG_UPDATE_GSXB:
			mod_setup( SET_MCBUFMODE, MCINT_GSXB );
			break;
	}




	switch( global_mod_ldg_frequence )
	{
		case MODLDG_FREQ_12KHZ:
			mod_setup( SET_MCFREQ, MCFREQ_12KHZ );
			break;

		case MODLDG_FREQ_25KHZ:
			mod_setup( SET_MCFREQ, MCFREQ_25KHZ );
			break;

		case MODLDG_FREQ_50KHZ:
			mod_setup( SET_MCFREQ, MCFREQ_50KHZ );
			break;
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "END set_mod_config()"CRLF );
	log_print(FALSE);
	#endif



	return;

}


#endif	/* #ifndef __SET_MOD_CONFIG__ */


