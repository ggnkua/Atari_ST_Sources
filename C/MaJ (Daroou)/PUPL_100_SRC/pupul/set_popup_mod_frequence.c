/* **[pupul]******************** */
/* *                           * */
/* * 09/11/2023 MaJ 09/11/2023 * */
/* ***************************** */


void set_popup_mod_frequence( void );




/* Fonction */
void set_popup_mod_frequence( void )
{



	#ifdef LOG_FILE
	sprintf( buf_log, " * set_popup_mod_frequence()"CRLF );
	log_print( FALSE );
	#endif




	/* ******************************************************* */
	/* * POPUP_MOD_FREQ                                      * */
	/* ******************************************************* */
	/* on desactive les menu du popup qui sont indisponible */
	{
		/* rien a desactiver ici */
	}


	/* -------------------------- */
	/* Pop Up frequence MOD LDG   */
	/* -------------------------- */
	{
		OBJECT	*adr_popup;

		/* Adresse du pop up */
		rsrc_gaddr( R_TREE, POPUP_MOD_FREQ, &adr_popup );
		Fcm_set_rsc_string( DL_MODLDG, MOD_FREQ_POPUP, adr_popup[global_mod_ldg_frequence].ob_spec.free_string );
	}




	return;


}

