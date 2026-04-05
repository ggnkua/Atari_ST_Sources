/* **[Boing]******************** */
/* *                           * */
/* * 25/09/2023 MaJ 25/09/2023 * */
/* ***************************** */



#include "../fonction/graphique/Fcm_make_liste_redraw_transparent.c"




/* prototype */
void calcul_screen( void );



/* Fonction */
void calcul_screen( void )
{


/*
	#ifdef LOG_FILE
	sprintf( buf_log, " * START calcul_screen()"CRLF );
	log_print( FALSE );
	#endif
*/


	/* ********************************************** */
	/*   on calcul la nouvelle position des sprites   */
	/* ********************************************** */



	/* ==================================================== */
	/* Sprite Boing Ball                                    */
	/* ==================================================== */

	/* ------------------------------ */
	/* Trajectoire Y BALL             */
	/* ------------------------------ */
	/* La version avec calcul en temps réel est desactivé,  */
	/* on utilise un tableau avec les valeurs pré-calculées */
	/* calculé dans init_animation()                        */
	{
		static int16 idx=0;

		boing_ball_xywh.g_y = boing_ball_y[idx];

		if(idx == BOING_BALL_Y_BOING)
		{
			if(global_mute_sound == FALSE) Fcm_sound_play( &global_son_sol );
		}

		if(idx == BOING_BALL_Y_END)
		{
			idx = 0;
		}

		idx++;
	}



	/* ------------------------------ */
	/* Trajectoire X BALL             */
	/* ------------------------------ */
	{
		static int16 direction    = BALL_RIGHT;
		static int16 pas_x        = BALL_PAS_X;


		boing_ball_xywh.g_x = boing_ball_xywh.g_x + pas_x;


		/* ------------------------------ */
		/* rotation de la BALL            */
		/* ------------------------------ */
		if( direction == BALL_RIGHT )
		{
			idx_boing_ball++;

			if( idx_boing_ball >= NB_BOING_BALL )  idx_boing_ball = 0;
		}
		else
		{
			idx_boing_ball--;

			if( idx_boing_ball < 0 )  idx_boing_ball = (NB_BOING_BALL-1);
		}


		/* ------------------------------ */
		/* d‚placement X de la BALL       */
		/* ------------------------------ */
		if( direction == BALL_RIGHT )
		{
			if( boing_ball_xywh.g_x > BALL_POS_X_MAX)
			{
				pas_x     = -pas_x;
				direction = BALL_LEFT;
				if( global_mute_sound == FALSE ) Fcm_sound_play( &global_son_droite );
			}
		}
		else
		{
			if( boing_ball_xywh.g_x < BALL_POS_X_MIN)
			{
				pas_x     = -pas_x;
				direction = BALL_RIGHT;
				if( global_mute_sound == FALSE ) Fcm_sound_play( &global_son_gauche );
			}
		}
	}


	/* ==================================================== */
	/* Sprite Boing Ball Ombre                              */
	/* ==================================================== */
	boing_ombre_xywh.g_y = boing_ball_xywh.g_y + BOING_OMBRE_DECALAGE_Y;
	boing_ombre_xywh.g_x = boing_ball_xywh.g_x + BOING_OMBRE_DECALAGE_X;






	/* -------------------------------------------------- */
	/* Construction des listes de restauration des fonds, */
	/* affichage sprite, redraw ecran                     */
	/* -------------------------------------------------- */

	/* on repart de z‚ro */
	Fcm_nb_liste_restaure_fond=0;
	Fcm_nb_liste_refresh_ecran=0;

	/* Sprite Boing Ball et Ombre sont des sprites avec partie transparente */

	Fcm_make_liste_redraw_transparent( &boing_ball_xywh, &boing_ball_xywh_old, pxy_boing_ball );
	*(&boing_ball_xywh_old) = *(&boing_ball_xywh);

	Fcm_make_liste_redraw_transparent( &boing_ombre_xywh, &boing_ombre_xywh_old, pxy_boing_ombre );
	*(&boing_ombre_xywh_old) = *(&boing_ombre_xywh);

	/* pxy_boing_xxx[] : zone du sprite à afficher */
	/* !!! Attention !!! si pxy_xxx[0]==-1 ne pas afficher => hors écran */
	/* avec boing ça n'arrive jamais, donc pas de test inutile  */



	return;

}

