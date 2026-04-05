/* **[Fonction Commune]********* */
/* *                           * */
/* * 17/11/2003  =  06/04/2013 * */
/* ***************************** */


#include "Fcm_gestion_checkbox.c"
#include "Fcm_active_sauve_config.c"
#include "Fcm_objet_change.c"
#include "Fcm_Gestion_Objet_Bouton.c"
#include "Fcm_sauver_config.c"
#include "Fcm_objet_draw.c"





/* Prototype */
VOID Fcm_gestion_fenetre_preference( const WORD controlkey, const WORD touche, const WORD bouton );


/* Fonction */
VOID Fcm_gestion_fenetre_preference( const WORD controlkey, const WORD touche, const WORD bouton )
{
	/* Variables Globales Externes:
	 *
	 * extern	GRECT	souris;
	 *
	 */

	OBJECT	*adr_formulaire_preference;
	OBJECT	*adr_menu;
	WORD	objet;
	WORD	valeur=0;
	WORD	commande=0;



	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_gestion_fenetre_preference(%d,%d,%d)"CRLF, controlkey,touche,bouton );
	log_print(FALSE);
	#endif



	/* on cherche l'adresse du formulaire et l'objet sous la souris */
	rsrc_gaddr( R_TREE, DL_OPT_PREF, &adr_formulaire_preference );

	objet = objc_find(adr_formulaire_preference,0,4,souris.g_x,souris.g_y);


	/* on cherche l'adresse du MENU */
	rsrc_gaddr( R_TREE, BARRE_MENU, &adr_menu);



	if( touche )
	{
		if( controlkey==K_ALT )
		{
			switch( touche )
			{
				case 0x1000:	/* Alt-a */
					commande=1;
					valeur=0;
					break;
				case 0x1400:	/* Alt-t */
					commande=2;
					valeur=0;
					break;
/*				case 0x0:*/		/* Alt-c */
/*					commande=3;
					valeur=0;
					break;*/
				case 0x1F00:	/* Alt-s */
					commande=4;
					valeur=1;
					break;
			}

		}
	}



	if( bouton )
	{
		switch( objet )
		{
			case PREF_SAVE_AUTO:
				commande=1;
				valeur=0;
				break;

/*			case PREF_WINFRAME:
				commande=2;
				valeur=0;
				break;*/

/*			case PREF_CLIC_UNTOP:
				commande=3;
				valeur=0;
				break;*/

			case PREF_SAVE_CONFIG:
				commande=4;
				valeur=0;
				break;
		}
	}












	/* ------------------------------------ */
	/* CheckBox : Sauver option en quittant */
	/* ------------------------------------ */
	if( commande==1)
	{
		/* On change l'‚tat de notre checkbox... */
		Fcm_gestion_checkbox( adr_formulaire_preference,  h_win[W_OPTION_PREFERENCE], PREF_SAVE_AUTO );

		if( (adr_formulaire_preference+PREF_SAVE_AUTO)->ob_state & OS_SELECTED )
		{
			menu_icheck( adr_menu, MN_SAUVER_CONFIG, OS_CHECKED );
		}
		else
		{
			menu_icheck( adr_menu, MN_SAUVER_CONFIG, 0 );
		}

		/* On active le bouton de sauvegarde des options */
		Fcm_active_sauve_config();
	}








	/* ---------------------------------------- */
	/* CheckBox : Clic sur fenetre arriŠre plan */
	/* ---------------------------------------- */
	if( commande==3)
	{
		/* A venir */
	}





	/* ------------------------- */
	/* Bouton Sauver les options */
	/* ------------------------- */
	if( commande==4)
	{
		if( ((adr_formulaire_preference+PREF_SAVE_CONFIG)->ob_state & OS_DISABLED) )
		{
			/* Si le bouton est disabled, on ne fait rien */
			return;
		}

		/* Si le bouton a ‚t‚ activ‚ au clavier */
		if(valeur)
		{
			Fcm_objet_change( adr_formulaire_preference, h_win[W_OPTION_PREFERENCE],PREF_SAVE_CONFIG, OS_SELECTED );
			evnt_timer(FCM_BT_PAUSE_DOWN);
			Fcm_objet_change( adr_formulaire_preference, h_win[W_OPTION_PREFERENCE],PREF_SAVE_CONFIG, 0 );
			evnt_timer(FCM_BT_PAUSE_UP);
		}
		else
		{
			/* Activ‚ avec la souris */
			if( Fcm_gestion_objet_bouton( adr_formulaire_preference, h_win[W_OPTION_PREFERENCE], PREF_SAVE_CONFIG ) != PREF_SAVE_CONFIG )
			{
				/* Bouton non valid‚, on quitte */
				return;
			}
		}

		Fcm_sauver_config(TRUE);
		SET_BIT_W( (adr_formulaire_preference+PREF_SAVE_CONFIG)->ob_state, OS_DISABLED, 1);
		Fcm_objet_draw( adr_formulaire_preference,  h_win[W_OPTION_PREFERENCE],PREF_SAVE_CONFIG, FCM_WU_BLOCK );
	}



	#ifdef PREF_BT_FERME
	sprintf( buf_log, "ERREUR #Fcm_gestion_fenetre_preference: supprimer gestion bouton fermer"CRLF );
	log_print(FALSE);
	#endif



	return;


}

