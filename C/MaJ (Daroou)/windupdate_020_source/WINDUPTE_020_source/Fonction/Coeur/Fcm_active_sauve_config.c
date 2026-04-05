/* **[Fonction Commune]********* */
/* *                           * */
/* * 05/01/2013  =  04/03/2013 * */
/* ***************************** */



#ifndef __Fcm_active_sauve_config__
#define __Fcm_active_sauve_config__




/* Prototype */
VOID Fcm_active_sauve_config( VOID );


/* Fonction */
VOID Fcm_active_sauve_config( VOID )
{
	/* Variables Globales Externes:
	 *
	 *
	 */

	OBJECT	*mon_formulaire;


	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_active_sauve_config()"CRLF );
	log_print(FALSE);
	#endif




	/* on cherche l'adresse du formulaire PCI INFO */
	rsrc_gaddr( R_TREE, DL_OPT_PREF, &mon_formulaire );


	if( ((mon_formulaire+PREF_SAVE_CONFIG)->ob_state & OS_DISABLED) )
	{
		SET_BIT_W( (mon_formulaire+PREF_SAVE_CONFIG)->ob_state, OS_DISABLED, 0);
		Fcm_objet_draw( mon_formulaire, h_win[W_OPTION_PREFERENCE], PREF_SAVE_CONFIG, FCM_WU_BLOCK );
	}


	return;


}


#endif

