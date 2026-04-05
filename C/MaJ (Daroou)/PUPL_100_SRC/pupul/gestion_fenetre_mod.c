/* **[Pupul]******************** */
/* *                           * */
/* * 09/11/2023 MaJ 09/11/2023 * */
/* ***************************** */


#include "../fonction/coeur/Fcm_gestion_bit_objet.c"
#include "../fonction/coeur/Fcm_objet_change.c"
#include "../fonction/coeur/Fcm_Gestion_Objet_Bouton.c"
#include "../fonction/coeur/Fcm_sauver_config.c"
//#include "../fonction/Fcm_my_file_select.c"
//#include "../fonction/Fcm_formate_cheminfichier.c"

#include "set_mod_config.c"
#include "affiche_error.c"

//#include "demande_redemarrage.c"


//extern int16 Fcm_image_cache_actif;
//extern char  Fcm_chemin_image_cache[FCM_TAILLE_CHEMIN];



/* Prototype */
void gestion_fenetre_mod( const int16 controlkey, const int16 touche, const int16 bouton );


/* Fonction */
void gestion_fenetre_mod( const int16 controlkey, const int16 touche, const int16 bouton )
{

	OBJECT	*adr_dialogue;
	int16	 objet;
	int16	 valeur = 0;
	int16	 commande = 0;



	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_gestion_fenetre_mod(%d,%d ($%04x),%d)"CRLF, controlkey,touche, touche, bouton );
	log_print(FALSE);
	#endif


	/* on cherche l'adresse du formulaire et l'objet sous la souris */
	rsrc_gaddr( R_TREE, DL_MODLDG, &adr_dialogue );

	objet = objc_find(adr_dialogue,0,4,souris.g_x,souris.g_y);


	if( touche )
	{
		switch( touche & 0xff)
		{
			case 0x0D:	/* return */
				commande=4;
				valeur=1;
				break;
		}

		switch( touche & 0xff00)
		{
			case 0x0100:	/* ESCape */
				commande=5;
				break;
		}


		if( controlkey==K_ALT )
		{
			switch( touche )
			{
//				case 0x1700:	/* Alt-i  activer cache */
//					commande=6;
//					valeur=0;
//					break;
//				case 0x1900:	/* Alt-p  chemin cache */
//					commande=7;
//					valeur=0;
//					break;
//				case 0x2100:	/* Alt-f  force to monochrome */
//					commande=1;
//					valeur=0;
//					break;
//				case 0x1000:	/* Alt-a  animation full speed */
//				case 0x2f00:	/* Alt-v  animation full speed */
//					commande=2;
//					valeur=0;
//					break;
//				case 0x2e00:	/* Alt-c  couper son */
//					commande=3;
//					valeur=0;
//					break;
				case 0x1F00:	/* Alt-s Sauver */
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
			case MOD_BT_SAUVER:
				commande=4;
				valeur=0;
				break;

			case MOD_UPDATE_POPUP:
				commande=10;
				valeur=0;
				break;

			case MOD_FREQ_POPUP:
				commande=11;
				valeur=0;
				break;

		}
	}







	/* ------------------------- */
	/* Bouton Sauver les options */
	/* ------------------------- */
	if( commande == 4 )
	{
		/* Si le bouton a ‚t‚ activ‚ au clavier */
		if( valeur )
		{
			Fcm_objet_change( adr_dialogue, h_win[W_MODLDG],MOD_BT_SAUVER, OS_SELECTED );
			evnt_timer(FCM_BT_PAUSE_DOWN);
			Fcm_objet_change( adr_dialogue, h_win[W_MODLDG],MOD_BT_SAUVER, 0 );
			evnt_timer(FCM_BT_PAUSE_UP);
		}
		else
		{
			/* Activ‚ avec la souris */
			if( Fcm_gestion_objet_bouton( adr_dialogue, h_win[W_MODLDG], MOD_BT_SAUVER ) != MOD_BT_SAUVER )
			{
				/* Bouton non valid‚, on quitte */
				return;
			}
		}

		Fcm_sauver_config(TRUE);

		if( valeur==1 || (bouton!=2 && valeur==0) )
		{
			Fcm_fermer_fenetre( W_MODLDG );
		}
	}



	/* ------------------------- */
	/* Touche ESCape             */
	/* ------------------------- */
	if( commande == 5 )
	{
		Fcm_fermer_fenetre( W_MODLDG );
		return;
	}







	/* -------------------------- */
	/* Pop Up Mise a jour MOD LDG */
	/* -------------------------- */
	if( commande == 10 )
	{
		OBJECT	*dial_popup;


		/* Adresse du pop up */
		rsrc_gaddr( R_TREE, POPUP_MODPOLLING, &dial_popup );

		objet = Fcm_gestion_pop_up( DL_MODLDG, MOD_UPDATE_POPUP, POPUP_MODPOLLING);


		/* ---------------------------------------------- */
		/* Mise … jour du popup                           */
		/* ---------------------------------------------- */
		if( objet!=-1 && objet!=global_mod_ldg_update )
		{
			Fcm_set_rsc_string( DL_MODLDG, MOD_UPDATE_POPUP, dial_popup[objet].ob_spec.free_string );
			global_mod_ldg_update = (uint16)objet;
			Fcm_objet_draw( adr_dialogue, h_win[W_MODLDG], MOD_UPDATE_POPUP, FCM_WU_BLOCK );

			set_mod_config();
		}
	}





	/* ------------------------------------ */
	/* Pop Up frequence restitution MOD LDG */
	/* ------------------------------------ */
	if( commande == 11 )
	{
		OBJECT	*dial_popup;


		/* Adresse du pop up */
		rsrc_gaddr( R_TREE, POPUP_MOD_FREQ, &dial_popup );

		objet = Fcm_gestion_pop_up( DL_MODLDG, MOD_FREQ_POPUP, POPUP_MOD_FREQ);


		/* ---------------------------------------------- */
		/* Mise … jour du popup                           */
		/* ---------------------------------------------- */
		if( objet != -1   &&   objet != global_mod_ldg_frequence )
		{
			Fcm_set_rsc_string( DL_MODLDG, MOD_FREQ_POPUP, dial_popup[objet].ob_spec.free_string );
			global_mod_ldg_frequence = (uint16)objet;
			Fcm_objet_draw( adr_dialogue, h_win[W_MODLDG], MOD_FREQ_POPUP, FCM_WU_BLOCK );

			set_mod_config();
		}

	}



	return;


}

