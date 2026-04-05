/* **[pupul]******************** */
/* *                           * */
/* * 09/11/2023 MaJ 09/11/2023 * */
/* ***************************** */


void set_popup_mod_update( void );




/* Fonction */
void set_popup_mod_update( void )
{



	#ifdef LOG_FILE
	sprintf( buf_log, " * set_popup_mod_update()"CRLF );
	log_print( FALSE );
	#endif




	/* ******************************************************* */
	/* * POPUP_MODPOLLING                                    * */
	/* ******************************************************* */
	/* on desactive les menu du popup qui sont indisponible */
	{
		OBJECT	*dial_popup;

		/* Adresse du pop up */
		rsrc_gaddr( R_TREE, POPUP_MODPOLLING, &dial_popup );

		/* on desactive par defaut */
		SET_BIT_W( dial_popup[POPUP_MAJ_TIMERA].ob_state, OS_DISABLED, 1);
		SET_BIT_W( dial_popup[POPUP_MAJ_MFPI7].ob_state, OS_DISABLED, 1);
		SET_BIT_W( dial_popup[POPUP_MAJ_GSXB].ob_state, OS_DISABLED, 1);


		switch( Fcm_systeme.machine_modele )
		{
			case  FCM_MACHINE_STE:
			case  FCM_MACHINE_MEGA_STE:
			case  FCM_MACHINE_TT:
			case  FCM_MACHINE_FALCON: /* ???? a tester */
			case  FCM_MACHINE_STEMULATOR:  /* ??? peu pas tester */
			case  FCM_MACHINE_MEDUSA:  /* ??? peu pas tester */
			case  FCM_MACHINE_HADES:  /* ??? peu pas tester */
			case  FCM_MACHINE_MILAN:  /* ??? peu pas tester pour le moment le milan est en sommeil :( */
			case  FCM_MACHINE_FIREBEE:  /* ??? peu pas tester */
			/*case  FCM_MACHINE_ARANYM:*/  /* le systeme ne veut pas -> crash , pas besoin de toute facon... assez de brutpower */
				SET_BIT_W( dial_popup[POPUP_MAJ_TIMERA].ob_state, OS_DISABLED, 0);
				SET_BIT_W( dial_popup[POPUP_MAJ_MFPI7].ob_state, OS_DISABLED, 0);
		}


		if( Fcm_cookies_exist(COOKIE_GSXB) )
		{
			SET_BIT_W( dial_popup[POPUP_MAJ_GSXB].ob_state, OS_DISABLED, 0);
		}
	}


	/* petite verification */
	/* Normalement, ca sert a rien, au premier lancement, c'est la mise a jour logiciel qui est par defaut */
	/* apres si un malin modifie le fichier de config a la main, il pourra forcer un mode */
	/* et pleurer si ca crash ... */
/*	if( (dial_popup[POPUP_MAJ_GSXB].ob_state & OS_DISABLED) && global_mod_ldg_update==MODLDG_UPDATE_GSXB )
	{
		global_mod_ldg_update = MODLDG_UPDATE_POLLING;
	}
	if( (dial_popup[POPUP_MAJ_TIMERA].ob_state & OS_DISABLED) && global_mod_ldg_update==MODLDG_UPDATE_TIMERA )
	{
		global_mod_ldg_update = MODLDG_UPDATE_POLLING;
	}
	if( (dial_popup[POPUP_MAJ_MFPI7].ob_state & OS_DISABLED) && global_mod_ldg_update==MODLDG_UPDATE_MFPI7 )
	{
		global_mod_ldg_update = MODLDG_UPDATE_POLLING;
	}*/




	/* -------------------------- */
	/* Pop Up Mise a jour MOD LDG */
	/* -------------------------- */
	{
		OBJECT	*adr_popup;

		/* Adresse du pop up */
		rsrc_gaddr( R_TREE, POPUP_MODPOLLING, &adr_popup );
		Fcm_set_rsc_string( DL_MODLDG, MOD_UPDATE_POPUP, adr_popup[global_mod_ldg_update].ob_spec.free_string );
	}




	return;


}

