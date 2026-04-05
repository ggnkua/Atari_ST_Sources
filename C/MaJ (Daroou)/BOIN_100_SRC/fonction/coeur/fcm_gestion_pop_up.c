/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 28/05/2015 MaJ 29/11/2025 * */
/* ***************************** */


/* -------------------------------------------------------------------- */
/* Cette fonction initialise le popup, le place si possible a l'endroit */
/* du bouton popup, l'ouvre si possible dans une fenetre, reorganise le */
/* popup si des ligne sont caché et le gère                             */
/* -------------------------------------------------------------------- */


#ifndef ___FCM_GESTION_POP_UP_C___
#define ___FCM_GESTION_POP_UP_C___


#define POP_UP_BOX (0)


/* -------------------------------------------- *
 *
 * dial_formulaire : index du formulaire qui
 *                   contient le bouton PopUP
 *
 * index_bouton_popup : index du bouton PopUP
 *
 * dial_popup : index du dialogue PopUP
 *
 * -------------------------------------------- */



int16 Fcm_gestion_pop_up( int16 dial_formulaire, int16 index_bouton_popup, int16 dial_popup )
{
	OBJECT *pop_up;
	int16   winx, winy, winw, winh;
	int16   flag_mouse_no_bouton = TRUE;
	int16   reponse_pop_up = 0;

	#define NB_LIGNE_POPUP (pop_up[0].ob_tail)


	/* FCM_CONSOLE_ADD() message console pour debug - analyse */
	//FCM_CONSOLE_ADD("Fcm_gestion_pop_up", G_GREEN);
	FCM_LOG_PRINT3(CRLF"# Fcm_gestion_pop_up(%d, %d, %d)"CRLF, dial_formulaire, index_bouton_popup, dial_popup);


	/* Adresse du pop up */
	pop_up = Fcm_adr_RTREE[dial_popup];

	/* initialisation du POP UP     */
	/* on de-selectionne les objets */
	{
		int16 idx_champ;

		for( idx_champ=1; idx_champ <= NB_LIGNE_POPUP; idx_champ++ )
		{
			SET_BIT_W( pop_up[idx_champ].ob_state, OS_SELECTED, 0);
		}
	}


	{
		OBJECT	*adr_dial_formulaire;


		adr_dial_formulaire = Fcm_adr_RTREE[dial_formulaire];

		/* on repositionne les objets du popup et on les redimensionne avec les dimensions */
		/* du bouton PopUp du formulaire de l'application */
		{
			int16 idx;
			int16 ligne_pos_y = 0;


			for( idx=1; idx <= NB_LIGNE_POPUP; idx++ )
			{
				/* s'il n'est pas caché */
				if( (pop_up[idx].ob_flags & OF_HIDETREE) == 0 )
				{
					pop_up[idx].ob_x      = 0;
					pop_up[idx].ob_y      = ligne_pos_y;
					pop_up[idx].ob_width  = adr_dial_formulaire[index_bouton_popup].ob_width;
					pop_up[idx].ob_height = adr_dial_formulaire[index_bouton_popup].ob_height;

					ligne_pos_y = ligne_pos_y + adr_dial_formulaire[index_bouton_popup].ob_height;
				}
			}

			/* dimension du fond du popup */
			pop_up[POP_UP_BOX].ob_width  = adr_dial_formulaire[index_bouton_popup].ob_width;
			pop_up[POP_UP_BOX].ob_height = ligne_pos_y;
		}


		/* on repositionne le popup par rapport au bouton popup du dialogue */
		{
			int16 reponse;
			int16 pos_x, pos_y;

			reponse = objc_offset( adr_dial_formulaire, index_bouton_popup, &pos_x, &pos_y );

			if( reponse != 0 )
			{
				pop_up[POP_UP_BOX].ob_x = pos_x;
				pop_up[POP_UP_BOX].ob_y = pos_y + adr_dial_formulaire[index_bouton_popup].ob_height + 2;
			}
			else
			{
				FCM_CONSOLE_DEBUG("Fcm_gestion_pop_up : erreur objc_offset() reponse=0");

				pop_up[POP_UP_BOX].ob_x=32;
				pop_up[POP_UP_BOX].ob_y=32;
			}
		}
	}


	/* on verifie qu'il ne sort pas de l'ecran */
	if( (pop_up[POP_UP_BOX].ob_x + pop_up[POP_UP_BOX].ob_width) > Fcm_screen.width )
	{
		pop_up[POP_UP_BOX].ob_x = Fcm_screen.width - pop_up[POP_UP_BOX].ob_width - 4;
	}

	if( pop_up[POP_UP_BOX].ob_x < 0 )
	{
		pop_up[POP_UP_BOX].ob_x = 0;
	}

	if( (pop_up[POP_UP_BOX].ob_y + pop_up[POP_UP_BOX].ob_height) > Fcm_screen.height )
	{
		pop_up[POP_UP_BOX].ob_y = Fcm_screen.height - pop_up[POP_UP_BOX].ob_height - 4;
	}


	/* On bloque les boutons souris, sinon le PopUp se referme de suite */
	Fcm_mouse_no_bouton();


	FCM_LOG_PRINT(" - Tentative ouverture en fenetre");

	/* Tentative ouverture du popup dans une fenetre */
	{
		/* epaisseur cadre, positif, epaisseur vers l'interieur, negatif, vers l'exterieur */
		pop_up[POP_UP_BOX].ob_spec.obspec.framesize = -1;

		/* ajustement avec l'epaisseur du cadre */
		winx = pop_up[POP_UP_BOX].ob_x - 1;
		winy = pop_up[POP_UP_BOX].ob_y - 1;
		winw = pop_up[POP_UP_BOX].ob_width  + 2;
		winh = pop_up[POP_UP_BOX].ob_height + 2;

		/* Calcul des dimensions de la fenetre en fonction de la taille du PopUp */
		{
			int16  x, y, largeur, hauteur;


			x       = winx;
			y       = winy;
			largeur = winw;
			hauteur = winh;

			/* on demande … l'AES de nous calculer la taille de la fenˆtre */
			/* en fonction de la zone de travail (surface du popup)        */
			wind_calc( WC_BORDER, 0, x, y, largeur, hauteur, &winx, &winy, &winw, &winh );
		}

		/* On demande … l'AES de cr‚er notre fenˆtre */
		h_win[W_POPUP] = wind_create( 0, winx, winy, winw, winh);
		//h_win[W_POPUP] = -1;
		

		if( h_win[W_POPUP] > 0 )
		{
			FCM_LOG_PRINT5("handle win=%2d ; x=%4d, y=%4d, w=%3d, h=%3d"CRLF, h_win[W_POPUP], winx, winy, winw, winh );
			//FCM_CONSOLE_ADD("PopUp en fenetre", G_YELLOW);

			/* on demande … l'AES de l'ouvrir */
			wind_open( h_win[W_POPUP], winx, winy, winw, winh );

			/* Le Coeur s'occupe du Redraw du PopUp */
			win_rsc[W_POPUP] = dial_popup;

			Fcm_purge_aes_message();
		}
		else
		{
			FCM_LOG_PRINT("pas de fenetre");
			//FCM_CONSOLE_ADD("PopUp AES bloquant", G_YELLOW);

			/* version bloquante */
			h_win[W_POPUP] = FCM_NO_OPEN_WINDOW;

			wind_update(BEG_UPDATE);
			wind_update(BEG_MCTRL); /* Necessaire, sinon les clics souris sont transmis à l'appli sous le PopUp */
			objc_draw( pop_up, 0, 4, Fcm_screen.x_desktop, Fcm_screen.y_desktop, Fcm_screen.w_desktop, Fcm_screen.h_desktop);
		}
	}


	/* Gestion des ‚vŠnements et du pop up */
	{
		int16 event, bouton, nb_click;
		int16 old_select_objet = -1;
		/*int16 controlkey,touche;*/   /* Pas de surveillance clavier MU_KEYBD */


		FCM_LOG_PRINT(" - Gestion des ‚vŠnements et du pop up");

		do
		{
			event = evnt_multi( MU_MESAG|MU_TIMER|MU_BUTTON,
							FCM_EVENT_MBCLICKS, FCM_EVENT_MBMASK, FCM_EVENT_MBSTATE,
 							0,0,0,0,0,
							0,0,0,0,0,
							buffer_aes,50,
							&souris.g_x,&souris.g_y,&bouton,NULL/*&controlkey*/,
							NULL/*&touche*/,&nb_click);

			FCM_LOG_PRINT5(" - event=%d - Buffer_aes[0]=%d(0x%x) [1]=%d [2]=%d", event, buffer_aes[0],buffer_aes[0],buffer_aes[1],buffer_aes[2]);
			FCM_LOG_PRINT5(" [3]=%d [4]=%d [5]=%d [6]=%d [7]=%d", buffer_aes[3],buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);

			/* ------------------------------------------------- */
			/*                      MU_MESAG                     */
			/* ================================================= */
			/* En version bloquante, aucun MU_MESAG normalement  */
			if( event & MU_MESAG )
			{
				int16 save_buffer_aes[16];


				//if( buffer_aes[0] != 0x3039 ) FCM_CONSOLE_ADD2("MU_MESAG (%d)", buffer_aes[0], G_LMAGENTA);

				memcpy( save_buffer_aes, buffer_aes, sizeof(save_buffer_aes) );
				Fcm_gestion_message();
				memcpy( buffer_aes, save_buffer_aes, sizeof(buffer_aes) );


				switch( buffer_aes[0] )
				{
					case WM_REDRAW:
					case 0x3039:
						/* Le PopUp reste ouvert */
						break;

					case WM_ONTOP:
						/* Message reçu apres l'ouverture de la fenetre PopUp */
						if( buffer_aes[3] != h_win[W_POPUP] )
						{
							/* Si une autre fenetre passe au premier plan... */
							reponse_pop_up = -1; /* on ferme le PopUp */
						}
						break;

					case WM_MOVED:
					case WM_SIZED:
					case WM_ARROWED:
					case WM_HSLID:
					case WM_VSLID:
						/* Pour ne pas bloquer le deplacement temps réel */
						flag_mouse_no_bouton = FALSE;
						reponse_pop_up = -1;
						break;

					case WM_UNTOPPED:
						if( buffer_aes[3] == h_win[W_POPUP] )
						{
							/* La fenetre PopUp n'est plus au premier plan... */
							reponse_pop_up = -1;
						}
						break;

					default:
						/* Tout autre MU_MESAG ferme le PopUp */
						reponse_pop_up = -1;
						break;
				}
			}


			if( reponse_pop_up == 0 )
			{
				/* ------------------------------------------------- */
				/*                      MU_BUTTON                    */
				/* ================================================= */
				if( event & MU_BUTTON )
				{
					int16 objet;


					objet = objc_find( pop_up, 0, 4, souris.g_x, souris.g_y);

					if( objet == -1 )
					{
						/* -1 si en dehors du PopUp */
						reponse_pop_up = -1;
					}
					else
					{
						/* clic sur une ligne disabled ne fait rien */
						if( (pop_up[objet].ob_state & OS_DISABLED) == 0 )
						{
							/* ligne active, on valide le PopUp */
							reponse_pop_up = objet;
						}
					}
				}


				/* ------------------------------------------------- */
				/*                      MU_TIMER                     */
				/* ================================================= */
				if( event & MU_TIMER )
				{
					//FCM_CONSOLE_ADD("MU_TIMER", G_WHITE);
					if( h_win[W_POPUP] > 0 ) gestion_timer();
				}


				/* ------------------------------------------------- */
				/* Gestion selection ligne du Pop Up                 */
				/* ================================================= */
				{
					int16 objet;


					objet = objc_find( pop_up, 0, 4, souris.g_x, souris.g_y);

					/* objet == -1 si la souris ne se trouve pas sur le dialogue */
					/* objet 0 : fond du dialogue */
					if( objet > 0 )
					{
						if( (pop_up[objet].ob_state & OS_DISABLED) == 0 )
						{
							if( objet != old_select_objet )
							{
								/* Active la nouvelle ligne */
								Fcm_objet_change( pop_up, h_win[W_POPUP], (uint16)objet, OS_SELECTED );

								if( old_select_objet != -1 )
								{
									/* De-selectionne l'ancienne ligne */
									Fcm_objet_change( pop_up, h_win[W_POPUP], (uint16)old_select_objet, 0 );
								}
								old_select_objet = objet;
							}
						}
					}
				}
			}

		} while( reponse_pop_up == 0 );
	}


	if( h_win[W_POPUP] > 0 )
	{
		Fcm_fermer_fenetre( W_POPUP );
	}
	else
	{
		wind_update(END_MCTRL);
		wind_update(END_UPDATE);
		form_dial(FMD_FINISH, 0, 0, 0, 0, winx, winy, winw, winh);
	}

	/* On purge les redraw avant de quitter, car avant de retourner   */
	/* dans la boucle AES, la fonction qui a appelé le PopUP va gérer */
	/* la reponse et rencontrer, peut-etre, moult probleme ...        */
	Fcm_purge_aes_message();

	if( flag_mouse_no_bouton )
	{
		Fcm_mouse_no_bouton();
	}

//FCM_CONSOLE_ADD("End Fcm_gestion_pop_up", G_WHITE);

	return(reponse_pop_up);

}


#endif   /* ___FCM_GESTION_POP_UP_C___ */

