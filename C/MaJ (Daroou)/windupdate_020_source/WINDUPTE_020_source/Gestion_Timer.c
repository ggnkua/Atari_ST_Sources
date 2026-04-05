/* **[WindUpdate]*************** */
/* *                           * */
/* * Gestion Timer             * */
/* * 20/12/2012 MaJ 29/01/2015 * */
/* ***************************** */




void gestion_timer( void )
{
	static	int16	compteur=0;
			OBJECT	*adr_formulaire;




	if( bar_direction==BAR_MOVE_LTOR)
	{
		/* de gauche … droite */

		bar_position=bar_position+BAR_PAS;

		if( (bar_position+bar_largeur) > BAR_POSITION_MAX )
		{
			if( bar_largeur > BAR_LARGEUR_MINI )
			{
				bar_largeur=MAX(BAR_LARGEUR_MINI, (bar_largeur-BAR_PAS) );
				bar_position=BAR_POSITION_MAX-bar_largeur;
			}
			else
			{
				bar_direction=BAR_MOVE_RTOL;
				bar_largeur=bar_largeur+BAR_PAS;
				bar_position=BAR_POSITION_MAX-bar_largeur;
			}
		}
		else
		{
			if( bar_largeur < BAR_LARGEUR )
			{
				bar_largeur=MIN( BAR_LARGEUR, (bar_largeur+BAR_PAS) );
				bar_position=BAR_POSITION_MINI;
			}
		}
	}
	else
	{
		/* de droite … gauche */
		bar_position=bar_position-BAR_PAS;

		if( bar_position < BAR_POSITION_MINI )
		{
			if( bar_largeur > BAR_LARGEUR_MINI )
			{
				bar_position=BAR_POSITION_MINI;
				bar_largeur=MAX(BAR_LARGEUR_MINI, (bar_largeur-BAR_PAS) );
			}
			else
			{
				bar_direction=1;
				bar_largeur=bar_largeur+BAR_PAS;
				bar_position=BAR_POSITION_MINI;
			}
		}
		else
		{
			if( bar_largeur < BAR_LARGEUR )
			{
				bar_largeur=MIN( BAR_LARGEUR, (bar_largeur+BAR_PAS) );
			}
		}
	}




	/* on cherche l'adresse du formulaire */
	rsrc_gaddr( R_TREE, DL_WINDUPDATE, &adr_formulaire );


	/* Position barre de progression */
	(adr_formulaire+WU_POSITION_BAR)->ob_x     = bar_position;
	(adr_formulaire+WU_POSITION_BAR)->ob_width = bar_largeur;

	/* position cache avant */
	(adr_formulaire+WU_BAR_AVANT)->ob_x     = 0;
	(adr_formulaire+WU_BAR_AVANT)->ob_width = bar_position;

	/* position cache arriere */
	(adr_formulaire+WU_BAR_ARRIERE)->ob_x     = bar_position+bar_largeur;
	(adr_formulaire+WU_BAR_ARRIERE)->ob_width = BAR_FOND-(bar_position+bar_largeur);




	if( h_win[W_WINDUPDATE] != FCM_NO_OPEN_WINDOW &&  win_iconified[W_WINDUPDATE] != TRUE)
	{
		GRECT	r1,r2;

		/* coordonnee de la zone a redessinner */
		/* Ici, on ne s'occupe de que redessinner la bar pour le test */
		rsrc_gaddr( R_TREE, DL_WINDUPDATE, &adr_formulaire );

		objc_offset(adr_formulaire,WU_I_FOND_BAR,&r1.g_x,&r1.g_y);
		r1.g_w=(adr_formulaire+WU_I_FOND_BAR)->ob_width;
		r1.g_h=(adr_formulaire+WU_I_FOND_BAR)->ob_height;


		redraw_demande++;


		/* on bloque l'interraction graphique AES                   */
		/* Pendant notre redraw, les sorties graphiques des autres  */
		/* appli doit etre bloqu‚ momentan‚ment                     */
		/* Wind_Update bloque donc notre application jusqu'… ce que */
		/* nous pouvons … notre tour monopolis‚ l'‚cran pour y      */
		/* dessiner dessus.                                         */
		/* Avec les nouveaux AES, au lieu de rester bloquer …       */
		/* attendre l'autorisation de gribouiller sur l'‚cran       */
		/* WindUpdate() nous indique si l'‚cran est libre ou non    */
		/* Si notre Redraw n'est pas important, on peut l'esquiver  */
		/* pour continuer … travailler sur les autres taches du     */
		/* programme (calcul, surveiller un port, envoie de donn‚e).*/
		/* Ce programme test cette nouvelle fonctionnalit‚e.        */
		/* La barre d'animation n'est affich‚ que si l'‚cran est    */
		/* libre avec l'option non bloquante ou affich‚ tout le     */
		/* temps avec la fonction d'origine.                        */

		if( wind_update(BEG_UPDATE|mask_windupdate) )
		{


			wind_get(h_win[W_WINDUPDATE],WF_FIRSTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

			while ( r2.g_w && r2.g_h )
			{
				if ( rc_intersect(&r1,&r2) )
				{
					pxy[0] = r2.g_x;
					pxy[1] = r2.g_y;
					pxy[2] = r2.g_x + r2.g_w - 1;
					pxy[3] = r2.g_y + r2.g_h - 1;

					graf_mouse(M_OFF, NULL);

					vs_clip( vdihandle, CLIP_ON, pxy );

					objc_draw( adr_formulaire, WU_I_FOND_BAR,1,r2.g_x,r2.g_y,r2.g_w,r2.g_h );

				 	vs_clip( vdihandle, CLIP_OFF, 0);

					graf_mouse(M_ON, NULL);

				}

				wind_get(h_win[W_WINDUPDATE],WF_NEXTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);
			}

			wind_update(END_UPDATE);

			redraw_effectue++;

			if( redraw_mode_flag==FRAME_REDRAW_EFFECTUE )
			{
				if( redraw_effectue_consecutif==0 ) redraw_effectue_consecutif=1;
				redraw_effectue_consecutif++;
				redraw_effectue_consecutif_record = MAX(redraw_effectue_consecutif_record,redraw_effectue_consecutif);
			}
			else
			{
				redraw_effectue_consecutif=0;
			}

			redraw_mode_flag=FRAME_REDRAW_EFFECTUE;
		}
		else
		{
			redraw_esquive++;

			if( redraw_mode_flag==FRAME_REDRAW_ESQUIVE )
			{
				if( redraw_esquive_consecutif==0 ) redraw_esquive_consecutif=1;

				redraw_esquive_consecutif++;
				redraw_esquive_consecutif_record=MAX(redraw_esquive_consecutif_record,redraw_esquive_consecutif);
			}
			else
			{
				redraw_esquive_consecutif=0;
			}
			redraw_mode_flag=FRAME_REDRAW_ESQUIVE;

		}

		if(redraw_demande>999999)
		{
	 		redraw_demande=0;
			redraw_effectue=0;
			redraw_esquive=0;
			redraw_effectue_consecutif=0;
			redraw_esquive_consecutif=0;
			redraw_effectue_consecutif_record=0;
			redraw_esquive_consecutif_record=0;
			redraw_mode_flag=0;
		}



		/* On met … jour les stats */
		sprintf( (adr_formulaire+WU_REDRAW_START)->ob_spec.tedinfo->te_ptext, "%ld", redraw_demande );

		sprintf( (adr_formulaire+WU_REDRAW_FINISH)->ob_spec.tedinfo->te_ptext, "%ld", redraw_effectue );
		sprintf( (adr_formulaire+WU_CONSEC_FINISH)->ob_spec.tedinfo->te_ptext, "%ld", redraw_effectue_consecutif );
		sprintf( (adr_formulaire+WU_RECORD_FINISH)->ob_spec.tedinfo->te_ptext, "%ld", redraw_effectue_consecutif_record );


		sprintf( (adr_formulaire+WU_REDRAW_SKIP)->ob_spec.tedinfo->te_ptext, "%ld", redraw_esquive );
		sprintf( (adr_formulaire+WU_CONSEC_SKIP)->ob_spec.tedinfo->te_ptext, "%ld", redraw_esquive_consecutif );
		sprintf( (adr_formulaire+WU_RECORD_SKIP)->ob_spec.tedinfo->te_ptext, "%ld", redraw_esquive_consecutif_record );


		compteur++;

		/* on affiche les stats qu'un event timer sur 10 pour ne     */
		/* pas alourdir la messagerie AES sauf si temps r‚el demand‚ */
		if( compteur>redraw_skip_compteur )
		{
			compteur=0;

			/* On re-affiche les stats */
			Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_REDRAW_START, mask_noblock_nombre );

			Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_REDRAW_FINISH, mask_noblock_nombre );
			Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_CONSEC_FINISH, mask_noblock_nombre );
			Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_RECORD_FINISH, mask_noblock_nombre );

			Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_REDRAW_SKIP, mask_noblock_nombre );
			Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_CONSEC_SKIP, mask_noblock_nombre );
			Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_RECORD_SKIP, mask_noblock_nombre );
		}
	}


	return;

}

