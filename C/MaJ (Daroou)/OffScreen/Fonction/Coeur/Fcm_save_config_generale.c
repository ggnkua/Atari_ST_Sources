/*=================================*/
/* Fonction sauvant tous les       */
/* TAG de configuration, commun Ö  */
/* toutes les applis               */
/* 31/12/2012 # 09/04/2013         */
/*_________________________________*/




#ifndef __Fcm_save_config_generale__
#define __Fcm_save_config_generale__




/* Prototypes */
VOID Fcm_save_config_generale(const WORD handle_fichier);


/* Fonction */
VOID Fcm_save_config_generale(const WORD handle_fichier)
{


	Fcm_fprint( handle_fichier, "");
	Fcm_fprint( handle_fichier, "-=- Configuration gÇnÇrale Coeur application -=-");
	Fcm_fprint( handle_fichier, "");
	Fcm_fprint( handle_fichier, "");


/*	Fcm_fprint( handle_fichier, "# Chemin et dernier fichier ouvert");

	{
		CHAR	my_buffer[TAILLE_CHEMIN+TAILLE_FICHIER];


		sprintf( my_buffer, "CHEMIN_SOURCE=%s", Fcm_chemin_source );
		Fcm_fprint( handle_fichier, my_buffer );

		sprintf( my_buffer, "CHEMIN_DESTINATION=%s", Fcm_chemin_destination );
		Fcm_fprint( handle_fichier, my_buffer );

		sprintf( my_buffer, "DERNIER_FICHIER=%s", Fcm_fichier_source );
		Fcm_fprint( handle_fichier, my_buffer );
	}

	Fcm_fprint( handle_fichier, "");
*/


	Fcm_fprint( handle_fichier, "# PrÇfÇrence Configuration");

	{
		CHAR	my_buffer[128];
/*		OBJECT	*adr_formulaire;*/
/*		WORD	valeur;*/


/*		rsrc_gaddr( R_TREE, DL_OPT_PREF, &adr_formulaire );*/

/*		valeur=0;
		if( adr_formulaire[PREF_SAVE_AUTO].ob_state & OS_SELECTED )
		{
			valeur=1;
		}
		sprintf( my_buffer, "SAUVEGARDE_AUTO=%d", valeur );*/
		sprintf( my_buffer, "SAUVEGARDE_AUTO=%d", Fcm_save_option_auto );
		Fcm_fprint( handle_fichier, my_buffer );


/*		valeur=0;
		if( adr_formulaire[PREF_SAVE_WINPOS].ob_state & OS_SELECTED )
		{
			valeur=1;
		}
		sprintf( my_buffer, "SAUVEGARDE_WINPOS=%d", valeur );*/
		sprintf( my_buffer, "SAUVEGARDE_WINPOS=%d", Fcm_save_winpos );
		Fcm_fprint( handle_fichier, my_buffer );



/*		valeur=0;
		if( adr_formulaire[PREF_CLOSE_QUIT].ob_state & OS_SELECTED )
		{
			valeur=1;
		}
		sprintf( my_buffer, "QUITTER_CLOSEWIN=%d", valeur );*/
		sprintf( my_buffer, "QUITTER_CLOSEWIN=%d", Fcm_quit_closewin );
		Fcm_fprint( handle_fichier, my_buffer );


		sprintf( my_buffer, "RSC_LANGAGE=%d", Fcm_rsc_langage_code );
		Fcm_fprint( handle_fichier, my_buffer );



/*		valeur=0;
		if( (adr_formulaire+PREF_WINFRAME)->ob_state & OS_SELECTED )
		{
			valeur=1;
		}
		sprintf( my_buffer, "WINFRAME=%d", valeur );
		Fcm_fprint( handle_fichier, my_buffer );*/
	}

	Fcm_fprint( handle_fichier, "");




/*	Fcm_fprint( handle_fichier, "# Position et paramätre des fenàtres");

	{
		CHAR	my_buffer[TAILLE_BUFFER];
		WORD	index;
		int16   openwinflag;


		for( index=0; index<NB_FENETRE; index++)
		{
			openwinflag=h_win[index];
			if( openwinflag>0 ) openwinflag=1;

			sprintf( my_buffer,"WINPOS_%02d=%d,%d,%d,%d,%d,%d", index,
							win_posxywh[index][0], win_posxywh[index][1],
							win_posxywh[index][2], win_posxywh[index][3],
							openwinflag, 0 );
			Fcm_fprint( handle_fichier, my_buffer );
		}
	}

	Fcm_fprint( handle_fichier, "");
*/

	Fcm_fprint( handle_fichier, "# Position et paramätre des fenàtres");

	{
		CHAR	my_buffer[TAILLE_BUFFER];
		WORD	index;
		int16   openwinflag;


		for( index=0; index<NB_FENETRE; index++)
		{
			openwinflag=h_win[index];
			if( openwinflag>0 ) openwinflag=1;

			sprintf( my_buffer,"WINPOS_%02dX=%d", index, win_posxywh[index][0] );
			Fcm_fprint( handle_fichier, my_buffer );
			sprintf( my_buffer,"WINPOS_%02dY=%d", index, win_posxywh[index][1] );
			Fcm_fprint( handle_fichier, my_buffer );
			sprintf( my_buffer,"WINPOS_%02dW=%d", index, win_posxywh[index][2] );
			Fcm_fprint( handle_fichier, my_buffer );
			sprintf( my_buffer,"WINPOS_%02dH=%d", index, win_posxywh[index][3] );
			Fcm_fprint( handle_fichier, my_buffer );
			sprintf( my_buffer,"WINPOS_%02dOpen=%d", index, openwinflag );
			Fcm_fprint( handle_fichier, my_buffer );

		}
	}

	Fcm_fprint( handle_fichier, "");



	return;

}


#endif

