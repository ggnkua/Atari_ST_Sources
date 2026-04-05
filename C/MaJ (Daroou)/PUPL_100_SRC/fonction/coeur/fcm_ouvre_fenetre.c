/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 05/05/2018 MaJ 13/03/2026 * */
/* ***************************** */



/*
 *
 * Fonction ouvrant une fenetre AES
 *
 * Si win_xywh est NULL, ouverture d'un dialogue 
 * Sinon, utilise win_xywh comme dimension de la zone de travail
 *
 */



void Fcm_ouvre_fenetre( uint16 index_tab_win, GRECT *win_xywh )
{
	int16	winx, winy, winw, winh;


FCM_LOG_PRINT1("* Fcm_ouvre_fenetre(idx=%d)", index_tab_win );
if( win_xywh != NULL )
{
	FCM_LOG_PRINT4(CRLF" win_xywh.g_x=%d win_xywh.g_y=%d win_xywh.g_w=%d win_xywh.g_h=%d", win_xywh->g_x, win_xywh->g_y, win_xywh->g_w, win_xywh->g_h );
}
else
{
	FCM_LOG_PRINT(CRLF" win_xywh == NULL" );
}

//FCM_CONSOLE_ADD2("* Fcm_ouvre_fenetre(index=%d)", index_tab_win, G_GREEN );


	/* Arrete de boire */
	if( index_tab_win > NB_FENETRE )
	{
		FCM_LOG_PRINT2("ERREUR index trop grand (NB_FENETRE=%d - index=%d)", NB_FENETRE, index_tab_win);
		FCM_CONSOLE_DEBUG("Fcm_ouvre_fenetre() : index win trop grand");
		return;
	}


	/* Fenetre deja ouverte ? */
	if( h_win[index_tab_win] > 0 )
	{
		buffer_aes[0] = WM_TOPPED;
		buffer_aes[1] = ap_id;
		buffer_aes[2] = 0;
		buffer_aes[3] = h_win[index_tab_win];
		appl_write( ap_id, 16, &buffer_aes );
		return;
	}


	/* ------------------------------------------------ */
	/* Ouverture fenetre avec les dimensions transmises */
	/* ------------------------------------------------ */
	if( win_xywh != NULL )
	{
		int16 x, y, largeur, hauteur;


		x       = win_xywh->g_x;
		y       = win_xywh->g_y;
		largeur = win_xywh->g_w;
		hauteur = win_xywh->g_h;

		/* on demande … l'AES de nous calculer la taille de la fenˆtre
		 * en fonction de la zone de travail (taille formulaire)
		 */
		wind_calc( WC_BORDER, win_widgets[index_tab_win], x, y, largeur, hauteur, &winx, &winy, &winw, &winh );
	}


	/* ------------------------------------------------- */
	/* Ouverture fenetre avec les dimensions du dialogue */
	/* ------------------------------------------------- */
	if( win_xywh == NULL )
	{
//FCM_LOG_PRINT2(" win_rsc[%d]=%d", index_tab_win, win_rsc[index_tab_win]);
//FCM_CONSOLE_DEBUG2("win_rsc[%d]=%d", index_tab_win, win_rsc[index_tab_win]);

		if( win_rsc[index_tab_win] != FCM_NO_RSC_DEFINED )
		{
			/* on demande … l'AES de le centrer sur le DeskTop au */
			/* cas ou la position de la fenetre n'a pas ete sauve */
			form_center( Fcm_adr_RTREE[ win_rsc[index_tab_win] ], &winx, &winy, &winw, &winh );
			/* (A.C. 6.80) The values that form_center() returns in x, y, w, and h, are not necessarily the
			   same as the object’s. These values take into account negative borders, outlining,
			   and shadowing. This is meant to provide a suitable clipping rectangle for objc_draw() */

//FCM_CONSOLE_DEBUG("");
//FCM_CONSOLE_DEBUG4("form_center: winx=%d winy=%d winw=%d winh=%d", winx, winy, winw, winh);
//FCM_CONSOLE_DEBUG4("form_center: winx=%d winy=%d winw=%d winh=%d", Fcm_adr_RTREE[win_rsc[index_tab_win]]->ob_x, Fcm_adr_RTREE[win_rsc[index_tab_win]]->ob_y, Fcm_adr_RTREE[win_rsc[index_tab_win]]->ob_width, Fcm_adr_RTREE[win_rsc[index_tab_win]]->ob_height);

			{
				int16 x, y, largeur, hauteur;

				/* Calcul des dimensions de la fenetre en fonction */
				/* de la taille du formulaire                      */
				x       = winx;
				y       = winy;
				largeur = winw;
				hauteur = winh;

				/* on demande … l'AES de nous calculer la taille de la fenˆtre */
				/* en fonction de la zone de travail (taille formulaire)       */
				wind_calc( WC_BORDER, win_widgets[index_tab_win], x, y, largeur, hauteur, &winx, &winy, &winw, &winh );

			}
		}
		else
		{
			/* Cette erreur ne devrait pas arriver normalement */
			/* Seulement si FCM_W_INDEX_APP_START est modifié, dans ce cas, */
			/* les index de fenetre dans le fichier de config ne sont plus  */
			/* valide, ne corespondent plus au nouveau indexage...          */
			/* le probleme est resolu apres la sauvegarde du nouveau fichier de config */
			FCM_LOG_PRINT("WARNING : RSC non defini ouverture impossible");

			FCM_CONSOLE_DEBUG("WARNING : RSC non defini ouverture impossible");
			FCM_CONSOLE_DEBUG("Si fichier de config d'une vieille version,");
			FCM_CONSOLE_DEBUG("une sauvegarde de la config rectifie le probleme");
		}

	}


	{ /* ---- PROVISOIRE --- le temps d'ajouter la gestion des SLIDERS sur formulaire plus grand que l'ecran --- PROVISOIRE --- */
		int16 dummy;
					/* On applique les coordonn‚es sauvegard‚es dans le fichier de config si */
					/* pr‚sente, sinon on laisse les coordonn‚es centr‚es                    */
					Fcm_set_win_position( index_tab_win, &winx, &winy, &dummy, &dummy  );

					/* a la base, seul x et y été appliqué, avec la console, ajout de w et h, mais ca induit */
					/* un probleme avec les formulaire, l'appli sauvé en ST Low  et rechargé en ST High, les */
					/* formulaires se retrouve avec la taille de la ST LOW  (hauteur/2) */
					/* Quand la gestion des sliders sera opé, des test seront fait pour ajuster les dimensions */
					/* Donc pour l'instant, la console n'est pas ajusté en w ey h */
	}


FCM_LOG_PRINT5("win_create() widget=%2d , x=%4d, y=%4d, w=%4d, h=%4d"CRLF, win_widgets[index_tab_win], winx, winy, winw, winh );

	/* On demande … l'AES de cr‚er notre fenˆtre */
	h_win[index_tab_win] = wind_create( win_widgets[index_tab_win], winx, winy, winw, winh);

	if( h_win[index_tab_win] > 0 )
	{
		/* on m‚morise la position de la fenˆtre meme si inutilisé */
		win_posxywh[index_tab_win][0]=winx;
		win_posxywh[index_tab_win][1]=winy;
		win_posxywh[index_tab_win][2]=winw;
		win_posxywh[index_tab_win][3]=winh;

//FCM_LOG_PRINT6("h_win(%d)=%2d ; x=%4d, y=%4d, w=%3d, h=%3d"CRLF, index_tab_win, h_win[index_tab_win], winx, winy, winw, winh );


		if( win_widgets[index_tab_win] & NAME )
		{
//FCM_CONSOLE_DEBUG("Ajout titre fenetre");
			/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un titre... */
			wind_set_str( h_win[index_tab_win], WF_NAME, fcm_win_titre_texte[index_tab_win] );
		}

		if( win_widgets[index_tab_win] & INFO )
		{
//FCM_CONSOLE_DEBUG("Ajout info fenetre");
			/* barre info */
			wind_set_str( h_win[index_tab_win], WF_INFO, fcm_win_info_texte[index_tab_win] );
		}


		/* on demande … l'AES de l'ouvrir */
		wind_open( h_win[index_tab_win], winx, winy, winw, winh );

		Fcm_purge_aes_message();

wind_get(h_win[index_tab_win],WF_WORKXYWH,&winx,&winy,&winw,&winh);
FCM_LOG_PRINT4("WF_WORKXYWH:: x=%4d, y=%4d, w=%4d, h=%4d"CRLF, winx, winy, winw, winh );


	}
	else
	{
		FCM_LOG_PRINT("‚chec ouverture fenetre");

		h_win[index_tab_win] = FCM_NO_OPEN_WINDOW;

		Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NO_WINDOWS, 0 );
	}


	return;


}

