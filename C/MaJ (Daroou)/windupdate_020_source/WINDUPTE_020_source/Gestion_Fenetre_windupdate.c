/* **[WindUpdate]*************** */
/* *                           * */
/* * 20/12/2012 MaJ 29/01/2015 * */
/* ***************************** */



void gestion_fenetre_windupdate( int16 controlkey, int16 touche, int16 bouton )
{

	OBJECT	*adr_formulaire;
	int16	objet;
	int16	valeur=0;
	int16	commande=0;



	/* on cherche l'adresse du formulaire */
	rsrc_gaddr( R_TREE, DL_WINDUPDATE, &adr_formulaire );

	objet = objc_find(adr_formulaire,0,4,souris.g_x,souris.g_y);


	if( touche )
	{

		if( controlkey==0 )
		{
			switch( touche & 0xff )
			{
				case 13: /* Touche entr‚e */
					commande=3;
					valeur=0;
					break;
			}
		}


		if( controlkey==K_ALT )
		{
			switch( touche )
			{
				case 0x1700:	/* Alt-i */
					commande=1;
					valeur=WU_BLOCK;
					break;
				case 0x3100:	/* Alt-n */
					commande=1;
					valeur=WU_NOBLOCK;
					break;
				case 0x1300:	/* Alt-r */
					commande=3;
					valeur=0;
					break;
				case 0x1200:	/* Alt-e */
					commande=2;
					break;
				case 0x1800:	/* Alt-o */
					commande=4;
					break;
			}

		}
	}


	if( bouton )
	{
		switch( objet )
		{
			case WU_BLOCK:
			case WU_NOBLOCK:
				commande=1;
				valeur=objet;
				break;


			case WU_BT_RAZ:
				if( Fcm_gestion_objet_bouton( adr_formulaire, h_win[W_WINDUPDATE], objet )== objet )
				{
					commande=3;
					valeur=1;
				}
				break;


			case WU_BT_FULLTIME:
				commande=2;
				break;


			case WU_NOMBRE_MODE:
				commande=4;
				break;

		}
	}




	/* Commande==1, gestion du radiobutton BEG_UPDATE / BEG NOBLOCK */
	if( commande==1 )
	{
		if( ((adr_formulaire+valeur)->ob_state & OS_SELECTED) == 0 )
		{
			/* si l'objet n'est pas s‚lectionn‚ */

			/* on d‚select tous les objets du radio bouton */
			SET_BIT_W( (adr_formulaire+WU_BLOCK)->ob_state, OS_SELECTED, 0);
			SET_BIT_W( (adr_formulaire+WU_NOBLOCK)->ob_state, OS_SELECTED, 0);

			/* on select le nouveau bouton */
			SET_BIT_W( (adr_formulaire+valeur)->ob_state, OS_SELECTED, 1);


			Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_BLOCK, FCM_WU_BLOCK );
			Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_NOBLOCK, FCM_WU_BLOCK );


			mask_windupdate=FCM_WU_BLOCK;

			if( ((adr_formulaire+WU_NOBLOCK)->ob_state & OS_SELECTED) == 1 )
			{
				mask_windupdate=FCM_WU_NO_BLOCK;
			}

		}

		Fcm_active_sauve_config();

	}



	/* Commande 2, gestion du checkbox 'Temps r‚el' */
	if( commande==2 )
	{
		int16 etat_checkbox;

		/* On change l'‚tat de notre checkbox... */
		etat_checkbox=Fcm_gestion_checkbox( adr_formulaire,  h_win[W_WINDUPDATE], WU_BT_FULLTIME );

		redraw_skip_compteur=WU_SKIP_COMPTEUR;

		if( etat_checkbox )
		{
			redraw_skip_compteur=0;
		}

		Fcm_active_sauve_config();

	}







	/* Remise … z‚ro des compteurs */
	if( commande==3)
	{
		/* Si le bouton a ‚t‚ activ‚ au clavier */
		if( valeur==0)
		{
			Fcm_objet_change( adr_formulaire, h_win[W_WINDUPDATE],WU_BT_RAZ, OS_SELECTED );
			evnt_timer(FCM_BT_PAUSE_DOWN);
			Fcm_objet_change( adr_formulaire, h_win[W_WINDUPDATE],WU_BT_RAZ, 0 );
			evnt_timer(FCM_BT_PAUSE_UP);
		}

		redraw_demande=0;
		redraw_effectue=0;
		redraw_esquive=0;
		redraw_effectue_consecutif=0;
		redraw_esquive_consecutif=0;
		redraw_effectue_consecutif_record=0;
		redraw_esquive_consecutif_record=0;
		redraw_mode_flag=0;
	}




	/* Commande==4, gestion du checkbox 'NO_BLOCK' */
	if( commande==4 )
	{
		int16 etat_checkbox;

		/* On change l'‚tat de notre checkbox... */
		etat_checkbox=Fcm_gestion_checkbox( adr_formulaire,  h_win[W_WINDUPDATE], WU_NOMBRE_MODE );

		mask_noblock_nombre=0;

		if( etat_checkbox )
		{
			mask_noblock_nombre=FCM_WU_NO_BLOCK;
		}

		Fcm_active_sauve_config();

	}



	return;


}

