/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 09/01/2016 * */
/* ***************************** */




#include "init_animation_bee.c"
#include "refresh_rsc_stats.c"



void gestion_fenetre_stats( int16 controlkey, int16 touche, int16 bouton );




void gestion_fenetre_stats( int16 controlkey, int16 touche, int16 bouton )
{

	OBJECT	*adr_formulaire;
	int16	objet;
/*	int16	valeur=0;*/
	int16	commande=0;


	/* suppression warning */
	objet=controlkey+touche;




	/* on cherche l'adresse du formulaire */
	rsrc_gaddr( R_TREE, DL_STATS, &adr_formulaire );

	objet = objc_find(adr_formulaire,0,4,souris.g_x,souris.g_y);


/*	{
		char texte[256];


		sprintf(texte,"gestion_fenetre_stats() Timer = %ld     ", Fcm_get_timer() );
		v_gtext(vdihandle,78*8,2*16, texte);
		sprintf(texte,"controlkey=%d touche=%x  bouton=%d  objet=%d  ", controlkey, touche, bouton, objet );
		v_gtext(vdihandle,78*8,3*16, texte);
	}*/





	if( touche )
	{
		switch( touche & 0xff )
		{
			case 0x2d:  /* -      */
			case 0x1f:  /* CTRL - */
				commande=2;
				objet=BT_STATS_BEE_MN;
				break;

			case 0x2b:  /* +      */
			case 0x0b:  /* CTRL + */
				commande=2;
				objet=BT_STATS_BEE_PL;
				break;

		}

		switch( (touche>>8) & 0xff )
		{
			case 0x4b: /*      fleche gauche */
			case 0x73: /* CTRL fleche gauche */
				commande=3;
				objet=BT_STATS_DEC_MN;
				break;

			case 0x4d: /*      fleche droite */
			case 0x74: /* CTRL fleche droite */
				commande=3;
				objet=BT_STATS_DEC_PL;
				break;

		}
	}






	if( bouton )
	{
		switch( objet )
		{
			case RB_STAT_OFF_VDI:
			case RB_STAT_OFF_VRAM:
			case RB_STAT_OFF_STRM:
			case RB_STAT_OFF_TTRM:
			case RB_STAT_CT60_VRM:
				commande=1;
				break;

			case BT_STATS_BEE_MN:
			case BT_STATS_BEE_PL:
/*				if( Fcm_gestion_objet_bouton( adr_formulaire, h_win[W_STATS], objet ) == objet )
				{*/
					commande=2;
/*				}*/
				break;

			case BT_STATS_DEC_MN:
			case BT_STATS_DEC_PL:
				commande=3;
				break;
		}
	}




	if( commande==0)
	{
		return;
	}




	if( commande==1 )
	{
		if( ((adr_formulaire+objet)->ob_state & OS_SELECTED) == 0 )
		{
			/* si l'objet n'est pas s‚lectionn‚ */

			/* on d‚select tous les objets du radio bouton */
			SET_BIT_W( (adr_formulaire+RB_STAT_OFF_VDI)->ob_state, OS_SELECTED, 0);
			SET_BIT_W( (adr_formulaire+RB_STAT_OFF_VRAM)->ob_state, OS_SELECTED, 0);
			SET_BIT_W( (adr_formulaire+RB_STAT_OFF_STRM)->ob_state, OS_SELECTED, 0);
			SET_BIT_W( (adr_formulaire+RB_STAT_OFF_TTRM)->ob_state, OS_SELECTED, 0);
			SET_BIT_W( (adr_formulaire+RB_STAT_CT60_VRM)->ob_state, OS_SELECTED, 0);

			/* on select le nouveau bouton */
			SET_BIT_W( (adr_formulaire+objet)->ob_state, OS_SELECTED, 1);

			Fcm_objet_draw( adr_formulaire, h_win[W_STATS], RB_STAT_OFF_VDI, FCM_WU_BLOCK );
			Fcm_objet_draw( adr_formulaire, h_win[W_STATS], RB_STAT_OFF_VRAM, FCM_WU_BLOCK );
			Fcm_objet_draw( adr_formulaire, h_win[W_STATS], RB_STAT_OFF_STRM, FCM_WU_BLOCK );
			Fcm_objet_draw( adr_formulaire, h_win[W_STATS], RB_STAT_OFF_TTRM, FCM_WU_BLOCK );
			Fcm_objet_draw( adr_formulaire, h_win[W_STATS], RB_STAT_CT60_VRM, FCM_WU_BLOCK );

			offscreen_mode=objet;

			change_offscreen_mode();
		}
	}






	if( commande==2 )
	{
		switch(objet)
		{
			case BT_STATS_BEE_MN:
				if( controlkey==K_CTRL )
				{
					gb_nb_bee=gb_nb_bee-10;
				}
				else
				{
					gb_nb_bee--;
				}
				break;

			case BT_STATS_BEE_PL:
				if( controlkey==K_CTRL )
				{
					gb_nb_bee=gb_nb_bee+10;
				}
				else
				{
					gb_nb_bee++;
				}
				break;
		}

		gb_nb_bee=MIN(NB_BEE_MAX, gb_nb_bee);
		gb_nb_bee=MAX(1, gb_nb_bee);

		init_animation_bee();
		refresh_rsc_stats();
		Fcm_objet_draw( adr_formulaire, h_win[W_STATS], FD_STATS_NB_BEE, FCM_WU_BLOCK );
		Fcm_objet_draw( adr_formulaire, h_win[W_STATS], FD_STAT_FRAME, FCM_WU_BLOCK );
	}






	if( commande==3 )
	{
		switch(objet)
		{
			case BT_STATS_DEC_MN:
				if( controlkey==K_CTRL )
				{
					gb_decalage_bee=gb_decalage_bee-10;
				}
				else
				{
					gb_decalage_bee--;
				}
				break;

			case BT_STATS_DEC_PL:
				if( controlkey==K_CTRL )
				{
					gb_decalage_bee=gb_decalage_bee+10;
				}
				else
				{
					gb_decalage_bee++;
				}
				break;
		}

			gb_decalage_bee=MAX(1, gb_decalage_bee);
			gb_decalage_bee=MIN(BEE_DECALAGE_MAX, gb_decalage_bee);

			init_animation_bee();
			refresh_rsc_stats();
			Fcm_objet_draw( adr_formulaire, h_win[W_STATS], FD_STATS_DECAL, FCM_WU_BLOCK );
	}


	return;


}

