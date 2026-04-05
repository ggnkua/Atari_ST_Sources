/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 29/12/2012 MaJ 29/11/2025 * */
/* ***************************** */



#ifndef __FCM_OBJET_DRAW_C__
#define __FCM_OBJET_DRAW_C__




/*
 * 21/06/2020: désactivation du clipping VDI, le clipping est inclu dans objc_draw()
 * 21/06/2020: désactivation Mouse Off/On; EmuTOS cache la souris automatiquement, donc le TOS aussi, à vérifier
 *
 */


void Fcm_objet_draw( OBJECT *adr_formulaire, int16 handle_win, uint16 objet, int16 windupdate_mode )
{

	FCM_LOG_PRINT4("* Fcm_objet_draw() - ad_frm=%p, hdl=%d, obj=%d, upd=$%x", adr_formulaire, handle_win, objet, windupdate_mode);
//FCM_CONSOLE_DEBUG4(" - adr_form=%p, handle=%d, objet=%d, update mode=$%x", adr_formulaire, handle_win, objet, windupdate_mode);
	

	/* si l'extension AES no block pour wind_update() n'est pas dispo */
	if( Fcm_systeme.noblock == 0 )  windupdate_mode = FCM_WU_BLOCK; /* 0 */


	/*
	 * Si handle_win non valide (FCM_NO_OPEN_WINDOW) affichage brut de l'objet
	 * Si handle_win est valide, affichage standard AES en fenetre
	 * Sinon, on quitte (fenetre shaded ou erreur d'handle)
	 *
	 */


	if( handle_win < 1  && 	handle_win != FCM_NO_OPEN_WINDOW )
	{
		FCM_CONSOLE_DEBUG3("Fcm_objet_draw() : handle_win (%d) incorrect : objet=%d Form=%p", handle_win, objet, adr_formulaire);
		return;
	}



	if( handle_win > 0 )
	{
		int16 index_win;


		/* on cherche l'index du tableau correspondant … ce handle de fenetre */
		index_win = Fcm_get_indexwindow( handle_win );

//FCM_LOG_PRINT1(" - index_win=%d", index_win);

		if( index_win != FCM_NO_MY_WINDOW )
		{
			if( win_shaded[index_win] == TRUE )
			{
				FCM_LOG_PRINT(" - win_shaded, no draw");
				FCM_CONSOLE_DEBUG("Fcm_objet_draw() : win_shaded, no draw");

				return;
			}
		}

//FCM_LOG_PRINT(" - pas d'erreur index_win");
	}


	{
		GRECT	r1,r2;

		/* coordonnee de la zone de l'objet a redessinner */
//		objc_offset( adr_formulaire, (int16)objet, &r1.g_x, &r1.g_y );

		/* cadre epaisseur max de 4 */
//		r1.g_x = r1.g_x - 4;
//		r1.g_y = r1.g_y - 4;
//		r1.g_w = adr_formulaire[objet].ob_width  + ( 4 * 2 );
//		r1.g_h = adr_formulaire[objet].ob_height + ( 4 * 2 );


		/* coordonnee de la zone de l'objet a redessinner */
		objc_offset( adr_formulaire, (int16)objet, &r1.g_x, &r1.g_y);

		r1.g_w = adr_formulaire[objet].ob_width;
		r1.g_h = adr_formulaire[objet].ob_height;

		{
			int16 epaisseur_cadre;
			int16 type_objet = adr_formulaire[objet].ob_type & 0xff;


			switch(type_objet)
			{
				case G_STRING:
				case G_IMAGE:
				case G_ICON:
				case G_CICON:
				case G_USERDEF:
				case G_BUTTON:
				case G_TEXT:
				case G_FTEXT:
					epaisseur_cadre = 0;
					break;

				case G_BOXTEXT:
				case G_FBOXTEXT:
					epaisseur_cadre = adr_formulaire[objet].ob_spec.tedinfo->te_thickness;
					break;

				case G_BOX:
				case G_IBOX:
				case G_BOXCHAR:
					epaisseur_cadre = adr_formulaire[objet].ob_spec.obspec.framesize;
					break;

				default:
					FCM_LOG_PRINT1("ERREUR Fcm_objet_draw, type objet non reconnu (%d)", type_objet);

					FCM_CONSOLE_DEBUG1("fcm_objet_draw() type objet non reconnu (%d)", type_objet);

					epaisseur_cadre=0;
			}


			if( epaisseur_cadre < 0 )
			{
//				int epaisseur = (int)epaisseur_cadre;

				/* si n‚gatif, cadre vers l'exterieur */
//				epaisseur_cadre = (int16)ABS(epaisseur);
//FCM_CONSOLE_DEBUG1("fcm_objet_draw() 1- epaisseur_cadre=%d", epaisseur_cadre);
				epaisseur_cadre = -epaisseur_cadre;
//FCM_CONSOLE_DEBUG1("fcm_objet_draw() 2- epaisseur_cadre=%d", epaisseur_cadre);

				/* on ajuste la zone … redessiner au cadre */
				r1.g_x = r1.g_x - epaisseur_cadre;
				r1.g_y = r1.g_y - epaisseur_cadre;
				r1.g_w = r1.g_w + (epaisseur_cadre * 2);
				r1.g_h = r1.g_h + (epaisseur_cadre * 2);
			}


//			int16 type_objet = adr_formulaire[objet].ob_type & 0xff;

//FCM_CONSOLE_ADD4("Objc_draw() objet=%d type_objet=%d epaisseur_cadre=%d", objet, type_objet, epaisseur_cadre, G_YELLOW );

			/* L'objet est-il cach‚ ou n'a pas de fond ? */
			if( ( adr_formulaire[objet].ob_flags & OF_HIDETREE) 
				  ||  type_objet == G_TEXT
				  ||  type_objet == G_STRING
				  ||  type_objet == G_IMAGE )
			{
				/* Si l'objet est cach‚, ou si c'est un objet qui n'a
				 * pas de fond, on r‚affiche seulement la zone de l'objet 
				 * avec le fond de l'objet pŠre.
				 */
				do
				{
					objet = (uint16)Fcm_get_objet_parent( adr_formulaire, (int16)objet );
//FCM_CONSOLE_ADD2("Objc_draw() reponse Fcm_get_objet_parent() %d", objet, G_YELLOW );
					/* Si le pere est une IBOX ou est cach‚, on cherche   */
					/* le pere de niveau sup‚rieur jusqu'… l'objet racine */
				}
				while(	objet != 0
						&&  (   (adr_formulaire[objet].ob_flags & OF_HIDETREE)
								|| (adr_formulaire[objet].ob_type == G_IBOX)   ) );
			}
		}







//		do
//		{
//			objet=Fcm_get_objet_parent( adr_formulaire, objet );
			/* Si le pere est une IBOX ou est cach‚, on cherche   */
			/* le pere de niveau sup‚rieur jusqu'… l'objet racine */
//		}
//		while( objet != 0  &&  ((adr_formulaire[objet].ob_flags & OF_HIDETREE)  ||  (adr_formulaire[objet].ob_type == G_IBOX)) );


//FCM_CONSOLE_ADD2("Fcm_get_objet_parent() %d", objet, G_YELLOW );



		if( handle_win > 0 )
		{
			/* Affichage standard AES en fenetre */

			FCM_LOG_PRINT1(" - redraw objet fenˆtre (obj %d)", objet);

			wind_get( handle_win, WF_WORKXYWH, &r2.g_x, &r2.g_y, &r2.g_w, &r2.g_h );

			if(   wind_update( BEG_UPDATE|windupdate_mode )   )
			{
				wind_get( handle_win, WF_FIRSTXYWH, &r2.g_x, &r2.g_y, &r2.g_w, &r2.g_h );

				while ( r2.g_w  &&  r2.g_h )
				{
					if (  rc_intersect( &r1, &r2 )  )
					{
						objc_draw( adr_formulaire, (int16)objet,7,r2.g_x,r2.g_y,r2.g_w,r2.g_h );
					}

					wind_get( handle_win, WF_NEXTXYWH, &r2.g_x, &r2.g_y, &r2.g_w, &r2.g_h );
				}

				wind_update(END_UPDATE);
			}
		}
		else
		{
			FCM_LOG_PRINT(" - redraw objc_draw brut");
FCM_CONSOLE_DEBUG(" - redraw objc_draw brut");

			/* Affichage direct … l'‚cran */
			objc_draw( adr_formulaire, (int16)objet, 7, r1.g_x, r1.g_y, r1.g_w, r1.g_h );
		}
	}


	return;


}


#endif   /*   __FCM_OBJET_DRAW_C__   */

