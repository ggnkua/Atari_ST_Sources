/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 03/01/2017 MaJ 28/02/2024 * */
/* ***************************** */



#ifndef ___FCM_WIN_FORM_ALERT_C___
#define ___FCM_WIN_FORM_ALERT_C___


#include "Fcm_rescale_def.h"


/* fonction interne a ce fichier */
void Fcm_rescale_win_form_alert( void );



/*
Remarque: Avec le form_alert en fenetre, il y a un problème de réentrance, si une erreur
  est répété dans la fonction gestion_timer() qui est appelé par la boucle evnt_multi().

  Appli::Erreur <=> Fcm_win_form_alert() <=> Fcm_gestion_message() <=> gestion_timer()

  Mise en place d'un semaphore qui empeche d'ouvrir une seconde Alerte en fenetre, et
  appel du form_alert() de l'AES pour la nouvelle erreur.
*/



int16 Fcm_win_form_alert( const int16 defaut_bouton, const char *text_form_alert )
{
	static	int16   win_form_alert_active = FALSE;
			OBJECT *adr_form_alert;
			int16   reponse_dialogue = 0;


	FCM_LOG_PRINT1( CRLF"# Fcm_win_form_alert() def bt=%d", defaut_bouton );
//FCM_LOG_PRINT1( "  {%s}", text_form_alert );


	/* Si seconde Alerte consecutif ... */
	if( win_form_alert_active == TRUE )
	{
		FCM_CONSOLE_DEBUG("Fcm_win_form_alert() : Reentrance de la fonction");
		FCM_CONSOLE_DEBUG("Appel form_alert AES");

		/* version AES (bloquante) */
		return form_alert( defaut_bouton, text_form_alert );
	}

	win_form_alert_active = TRUE;


	adr_form_alert = Fcm_adr_RTREE[DL_FORM_ALERT];

	/* Si affichage en fenêtre, il faut remplir le dialoque */
	/* et activer/desactiver certain objet                  */
	/* ---------------------------------------------------- */
	{
		int16 image_type;

		image_type = (int16)(text_form_alert[1] - '1');  /* valeur decimal: ASCII '1' => 49 */

		/* on desactive toutes les images */
		SET_BIT_W( adr_form_alert[FORM_BT_EXCLA  ].ob_flags, OF_HIDETREE, 1);
		SET_BIT_W( adr_form_alert[FORM_BT_INTERRO].ob_flags, OF_HIDETREE, 1);
		SET_BIT_W( adr_form_alert[FORM_BT_STOP   ].ob_flags, OF_HIDETREE, 1);

		/* on active la bonne image */
		SET_BIT_W( adr_form_alert[FORM_BT_EXCLA + image_type].ob_flags, OF_HIDETREE, 0);
	}


	/* Construction du formulaire avec les donnees de la chaine 'text_form_alert'    */
	/* ----------------------------------------------------------------------------- */
	/* Aucun test de depassement de chaine n'est fait ici, les chaines de form alert */
	/* ont ete verifiees avec Fcm_check_rsc_alerte() */
	{
		int16 idx_ligne;
		int16 idx_char;
		int16 total_char_text_form_alert;
		char *pt_text_form_alert;
		int16 nb_bouton;


		total_char_text_form_alert = strlen(text_form_alert);

		/* format texte alert                              */
		/* [x][ligne 1|ligne n|...][bouton 1|bouton z|...] */
		/* la premiere ligne commence en position 4        */


		/* Remplissage des lignes de texte                            */
		/* ---------------------------------------------------------- */
		/* idx_ligne est l'index des STRING du dialogue DL_FORM_ALERT */ 
		{
			pt_text_form_alert = adr_form_alert[FORM_LIGNE1].ob_spec.free_string;

			for( idx_char=4, idx_ligne=0; idx_char < total_char_text_form_alert; idx_char++ )
			{
				if( text_form_alert[idx_char] == '|'  ||  text_form_alert[idx_char] == ']' )
				{
					/* fin de ligne ou fin du texte */
					*pt_text_form_alert=0;  /* null byte, end of string */

					idx_ligne++; /* on pointe sur la prochaine ligne, s'il y en a une */

					/* Est-ce la fin du text form alerte ? */
					if( text_form_alert[idx_char] == ']' )  break;

					/* sinon, on pointe sur la prochaine ligne text (STRING) du formulaire */
					pt_text_form_alert = adr_form_alert[FORM_LIGNE1 + idx_ligne].ob_spec.free_string;
				}
				else
				{
					/* on copie les caracteres de la ligne courante */
					*pt_text_form_alert++ = text_form_alert[idx_char];
				}
			}

			/* on efface les lignes (STRING) inutilisées du dialogue DL_FORM_ALERT */
			/* 5 STRING  =>  idx_ligne 0-4 , si 5 lignes presentes, idx_ligne==5   */
			for( ; idx_ligne<5; idx_ligne++ )
			{
				*adr_form_alert[FORM_LIGNE1 + idx_ligne].ob_spec.free_string = 0; /* null byte */
			}
		}


		/* Remplissage des boutons */
		/* ----------------------- */
		{
			idx_char = idx_char + 2;   /* on passe les caracteres '][' */

			pt_text_form_alert = adr_form_alert[FORM_BOUTON1].ob_spec.free_string;

			for( idx_ligne=0; idx_char < total_char_text_form_alert; idx_char++ )
			{
				if( text_form_alert[idx_char] == '|' || text_form_alert[idx_char] == ']' )
				{
					/* fin du texte bouton */
					*pt_text_form_alert = 0;  /* null byte, end of string */

					idx_ligne++; /* on pointe sur le prochaine bouton, s'il y en a un */

					/* c'est la fin des boutons */
					if( text_form_alert[idx_char] == ']' )  break;

					/* sinon, on pointe sur le prochain bouton */
					SET_BIT_W( adr_form_alert[FORM_BOUTON1 + idx_ligne].ob_flags, OF_HIDETREE, 0 );     /* on active le bouton */
					pt_text_form_alert = adr_form_alert[FORM_BOUTON1 + idx_ligne].ob_spec.free_string;
				}
				else
				{
					/* on copie les caracteres du bouton courant */
					*pt_text_form_alert++ = text_form_alert[idx_char];
				}
			}

			/* on memorise le nombre de bouton (pour le centrage) */
			nb_bouton = idx_ligne;

			/* on cache les boutons inutilisées (3 boutons max => 0-2) */
			/* si 3 boutons present, idx_ligne==3 */
			for( ; idx_ligne<3; idx_ligne++ )
			{
				SET_BIT_W( adr_form_alert[FORM_BOUTON1 + idx_ligne].ob_flags, OF_HIDETREE, 1 );
			}

			/* on centre les boutons */
			{
				int16 largeur_total_bouton = 0;
				int16 ecart_bouton = 0;

				for( idx_ligne=0; idx_ligne < nb_bouton; idx_ligne++ )
				{
					largeur_total_bouton = largeur_total_bouton + adr_form_alert[FORM_BOUTON1 + idx_ligne].ob_width;
				}

				/* objet 0 est le 'fond' du dialogue */
				ecart_bouton = (adr_form_alert[0].ob_width - largeur_total_bouton) / (nb_bouton + 1);

				/* au minimum, il y a un bouton */
				adr_form_alert[FORM_BOUTON1].ob_x = ecart_bouton;
				for( idx_ligne=1; idx_ligne < nb_bouton; idx_ligne++ )
				{
					adr_form_alert[FORM_BOUTON1 + idx_ligne].ob_x = adr_form_alert[FORM_BOUTON1 + idx_ligne - 1].ob_x + adr_form_alert[FORM_BOUTON1 + idx_ligne - 1].ob_width + ecart_bouton;
				}
			}

			/* on active le bouton par defaut */
			for( idx_ligne=0; idx_ligne < nb_bouton; idx_ligne++ )
			{
				if( defaut_bouton == (idx_ligne + 1) )
				{
					SET_BIT_W( adr_form_alert[FORM_BOUTON1 + idx_ligne].ob_flags, OF_DEFAULT, 1 );
				}
				else
				{
					SET_BIT_W( adr_form_alert[FORM_BOUTON1 + idx_ligne].ob_flags, OF_DEFAULT, 0 );
				}
			}
		}
	}





	/* ouverture en fenetre ou en alerte systeme */
	/* ----------------------------------------- */
	{
		int16  winx,winy,winw,winh;


//FCM_LOG_PRINT( " - Tentative ouverture en fenetre");


		Fcm_rescale_win_form_alert();

		{
			int16  x, y, largeur, hauteur;


			/* Calcul des dimensions de la fenetre en fonction */
			/* de la taille du formulaire                      */
			{
				int16  dummy;
				graf_mkstate( &souris.g_x, &souris.g_y, &dummy, &dummy);
			}

			largeur = adr_form_alert[0].ob_width;
			hauteur = adr_form_alert[0].ob_height;

			/* on place le dialoque pres du curseur de la souris */
			x = souris.g_x - (largeur / 2);
			y = souris.g_y - (hauteur / 2);

			/* on verifie que le dialogue n'est pas hors ecran */
			x = MAX( x, (Fcm_screen.x_desktop + 2) );
			x = MIN( x, (Fcm_screen.w_desktop - largeur - 2) );
			y = MAX( y, (Fcm_screen.y_desktop + 2) );
			y = MIN( y, (Fcm_screen.h_desktop - hauteur - 2) );
			y = MAX( y, (Fcm_screen.y_desktop + Fcm_screen.gr_hhbox + 4) ); /* espace pour la barre de titre de la fenetre */

			/* on demande … l'AES de nous calculer la taille de la fenˆtre */
			/* en fonction de la zone de travail (taille formulaire)       */
			wind_calc( WC_BORDER, NAME|MOVER, x, y, largeur, hauteur, &winx, &winy, &winw, &winh );

			adr_form_alert[0].ob_x = x;
			adr_form_alert[0].ob_y = y;
		}

		/* On demande … l'AES de cr‚er notre fenˆtre */
		h_win[W_FORM_ALERT] = wind_create( NAME|MOVER, winx, winy, winw, winh);
		//h_win[W_FORM_ALERT] = -1;

		if( h_win[W_FORM_ALERT] > 0  )
		{
//FCM_LOG_PRINT5(" - handle win=%d ; x=%d, y=%d, w=%d, h=%d", h_win[W_FORM_ALERT], winx, winy, winw, winh );
//FCM_CONSOLE_ADD("WinAlerte en fenetre", G_YELLOW);

			/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un nom ... */
			snprintf( fcm_win_titre_texte[W_FORM_ALERT], FCM_WIN_TITRE_MAXSIZE, PRG_FULL_NOM" Alert");
			wind_set_str( h_win[W_FORM_ALERT], WF_NAME, fcm_win_titre_texte[W_FORM_ALERT] );

			/* on demande … l'AES de l'ouvrir */
			wind_open(h_win[W_FORM_ALERT],winx,winy,winw,winh);

			/* Le Coeur s'occupe du Redraw */
			win_rsc[W_FORM_ALERT] = DL_FORM_ALERT;
		}
		else
		{
//FCM_LOG_PRINT("pas de fenetre");
//FCM_CONSOLE_ADD("WinAlerte AES bloquant", G_YELLOW);

			h_win[W_FORM_ALERT] = FCM_NO_OPEN_WINDOW;

			/* version AES (bloquante) */
			return form_alert( defaut_bouton, text_form_alert );
		}
	}




	/* Gestion des ‚vŠnements et du dialogue */
	{
		int16	event, bouton, controlkey, touche, nb_click;


//FCM_LOG_PRINT(" - Gestion des ‚vŠnements et du dialogue");

		do
		{
			event = evnt_multi( MU_MESAG|MU_TIMER|MU_BUTTON|MU_KEYBD,
							FCM_EVENT_MBCLICKS, FCM_EVENT_MBMASK, FCM_EVENT_MBSTATE,
 							0,0,0,0,0,
							0,0,0,0,0,
							buffer_aes,TASK_TIMER,
							&souris.g_x,&souris.g_y,&bouton,&controlkey,
							&touche,&nb_click);


			/* ------------------------------------------------- */
			/*                      MU_MESAG                     */
			/* ================================================= */
			if( event & MU_MESAG )
			{
				//if( buffer_aes[0] != 0x3039 ) FCM_CONSOLE_ADD2("MU_MESAG (%d)", buffer_aes[0], G_LMAGENTA);


				/* On bloque certains types de message qui ne doivent */
				/* pas etre utilisé tant que l'alerte est active      */
				switch( buffer_aes[0] )
				{
					case WM_TOPPED:
						/* Le win form_alert reste au premier plan */
						wind_set(h_win[W_FORM_ALERT], WF_TOP, buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);
						/* on doit redéfinir la forme du pointeur souris (ref Atari Compendium 1992 p.687)*/
						graf_mouse(ARROW, NULL);
						break;

					case MN_SELECTED:
						/* l'utilisateur a cliqu‚ sur une entr‚e du Menu */
						/* On remet le MENU dans son ‚tat d'origine      */
						/* On ne tient pas compte de la demande          */
						Fcm_menu_tnormal( BARRE_MENU, buffer_aes[3], 1 );
						break;

					case AP_TERM:
						/* If for some reason, your process can not shut down you must inform */
						/* the AES by sending an AP_TFAIL (51) message by using */
						/* shel_write() mode 10 (see shel_write()). (A.C 6.69) */
						/* pas sur des parametre, donc desactié pour le moment */
						//memset( buffer_aes, 0, sizeof(buffer_aes) );
						//buffer_aes[0]=AP_TFAIL;
						//buffer_aes[0]=ap_id; error code ???
						//shel_write( SWM_AESMSG, 0, 0, buffer_aes, 0 ??? );
						break;

					case WM_CLOSED:
						{
							int16 win_index = Fcm_get_indexwindow( buffer_aes[3] );

							if( win_index != FCM_NO_MY_WINDOW  &&  win_index != FCM_W_INDEX_APP_START)
							{
								/* FCM_W_INDEX_APP_START = index fenetre principale */
								if( table_ft_ferme_fenetre[win_index] == FCM_FONCTION_NON_DEFINI )
								{
									/* S'il n'y a pas de fonction qui gère la fermeture de   */
									/* la fenêtre, et que c'est pas la fenetre principale de */
									/* l'appli, on peut la fermer durant un win_form_alert   */
									Fcm_fermer_fenetre( win_index );
								}
							}
						}
					case WM_ICONIFY:
					case WM_ALLICONIFY:
					case WM_UNICONIFY:
						/* message bloqué, on ne fait rien */
						break;


					default:
						/* Les autres messages peuvent être gérer par le Coeur */
						Fcm_gestion_message();
						break;
				}
			}


			/* ------------------------------------------------- */
			/*                      MU_BUTTON                    */
			/* ================================================= */
			if( event & MU_BUTTON )
			{
				int16 objet=0;

				objet = objc_find( adr_form_alert, 0, 4, souris.g_x, souris.g_y);

				if( objet >= FORM_BOUTON1   &&   objet <= (FORM_BOUTON1+2) )
				{
					if( Fcm_gestion_objet_bouton( adr_form_alert, h_win[W_FORM_ALERT], (uint16)objet ) == objet )
					{
						/* Bouton  valid‚ */
						reponse_dialogue = objet - FORM_BOUTON1 + 1;
					}
				}
			}


			/* ------------------------------------------------- */
			/*                      MU_KEYBD                     */
			/* ================================================= */
			if( event & MU_KEYBD)
			{
				int16  bouton_selection=-1;


				switch( touche & 0xff00 )
				{
					case 0x7200:  /* Return 1 */
					case 0x1C00:  /* Return 2 */
						if( defaut_bouton != 0 )
						{
							bouton_selection = defaut_bouton;
						}
						break;
					case 0x3b00:  /* F1 */
						bouton_selection = 1;
						break;
					case 0x3c00:  /* F2 */
						bouton_selection = 2;
						break;
					case 0x3d00:  /* F3 */
						bouton_selection = 3;
						break;
				}

				if( bouton_selection != -1 )
				{
					if( ( adr_form_alert[FORM_BOUTON1 + bouton_selection - 1].ob_flags  & OF_HIDETREE) == 0 )
					{
						reponse_dialogue = bouton_selection;

						Fcm_objet_change( adr_form_alert, h_win[W_FORM_ALERT],(FORM_BOUTON1 + bouton_selection - 1), OS_SELECTED );
						evnt_timer(FCM_BT_PAUSE_DOWN);
						Fcm_objet_change( adr_form_alert, h_win[W_FORM_ALERT],(FORM_BOUTON1 + bouton_selection - 1), 0 );
						evnt_timer(FCM_BT_PAUSE_UP);
					}
				}
			}


			/* ------------------------------------------------- */
			/*                      MU_TIMER                     */
			/* ================================================= */
			if( event & MU_TIMER )
			{
				if( Fcm_init_appli_terminer == TRUE ) gestion_timer();
			}


		} while( reponse_dialogue==0 );
	}


	if( h_win[W_FORM_ALERT] > 0 )
	{
		Fcm_fermer_fenetre( W_FORM_ALERT );
	}


	FCM_LOG_PRINT(" - Fin Fcm_win_form_alert");
//FCM_CONSOLE_ADD("End Fcm_win_form_alert", G_WHITE);


	/* pour eviter la réentrance de la fonction */
	win_form_alert_active = FALSE;


	return(reponse_dialogue);


}





void Fcm_rescale_win_form_alert (void )
{
	OBJECT	*dial;
	int16    form_w, nb_bouton;
	int16    largeur_total_bouton;


	#define IMG_FORM_WIDTH  (32)
	#define IMG_FORM_HEIGHT (32)

	
	/* Marre que le formulaire s'affiche mal d'une resolution a l'autre */
	/* tous les objets et le fond sont repositionner                    */

//FCM_LOG_PRINT(" - Fcm_rescale_win_form_alert");


	dial = Fcm_adr_RTREE[DL_FORM_ALERT];


	dial[FORM_CADRE_IMAGE].ob_x = FCM_RESCALE_MARGE_GAUCHE;
	dial[FORM_CADRE_IMAGE].ob_y = FCM_RESCALE_MARGE_HAUT;

	dial[FORM_BT_EXCLA  ].ob_x = 0;
	dial[FORM_BT_EXCLA  ].ob_y = 0;
	dial[FORM_BT_INTERRO].ob_x = 0;
	dial[FORM_BT_INTERRO].ob_y = 0;
	dial[FORM_BT_STOP   ].ob_x = 0;
	dial[FORM_BT_STOP   ].ob_y = 0;

	dial[FORM_LIGNE1].ob_x = dial[FORM_CADRE_IMAGE].ob_x + IMG_FORM_WIDTH + FCM_RESCALE_ESPACE;
	dial[FORM_LIGNE1].ob_y = FCM_RESCALE_MARGE_HAUT;
	form_w = (int16)strlen(dial[FORM_LIGNE1].ob_spec.free_string) * FCM_RESCALE_WCHAR;

	dial[FORM_LIGNE2].ob_x = dial[FORM_LIGNE1].ob_x;
	dial[FORM_LIGNE2].ob_y = dial[FORM_LIGNE1].ob_y + dial[FORM_LIGNE1].ob_height;
	form_w = MAX(form_w, (int16)strlen(dial[FORM_LIGNE2].ob_spec.free_string) * FCM_RESCALE_WCHAR);

	dial[FORM_LIGNE3].ob_x = dial[FORM_LIGNE1].ob_x;
	dial[FORM_LIGNE3].ob_y = dial[FORM_LIGNE2].ob_y + dial[FORM_LIGNE2].ob_height;
	form_w = MAX(form_w, (int16)strlen(dial[FORM_LIGNE3].ob_spec.free_string) * FCM_RESCALE_WCHAR);

	dial[FORM_LIGNE4].ob_x = dial[FORM_LIGNE1].ob_x;
	dial[FORM_LIGNE4].ob_y = dial[FORM_LIGNE3].ob_y + dial[FORM_LIGNE3].ob_height;
	form_w = MAX(form_w, (int16)strlen(dial[FORM_LIGNE4].ob_spec.free_string) * FCM_RESCALE_WCHAR);

	dial[FORM_LIGNE5].ob_x = dial[FORM_LIGNE1].ob_x;
	dial[FORM_LIGNE5].ob_y = dial[FORM_LIGNE4].ob_y + dial[FORM_LIGNE4].ob_height;
	form_w = MAX(form_w, (int16)strlen(dial[FORM_LIGNE5].ob_spec.free_string) * FCM_RESCALE_WCHAR);

	form_w = form_w + dial[FORM_LIGNE1].ob_x + FCM_RESCALE_MARGE_DROITE;


	dial[FORM_BOUTON1].ob_y = dial[FORM_LIGNE5].ob_y + dial[FORM_LIGNE5].ob_height + FCM_RESCALE_INTERLIGNE;
	dial[FORM_BOUTON2].ob_y = dial[FORM_BOUTON1].ob_y ;
	dial[FORM_BOUTON3].ob_y = dial[FORM_BOUTON1].ob_y ;

	{
		dial[FORM_BOUTON1].ob_width = ((int16)strlen(dial[FORM_BOUTON1].ob_spec.free_string) + 2) * FCM_RESCALE_WCHAR;
		largeur_total_bouton = dial[FORM_BOUTON1].ob_width;

		if( dial[FORM_BOUTON2].ob_flags & OF_HIDETREE )
		{
			nb_bouton=1;
		}
		else
		{
			dial[FORM_BOUTON2].ob_width = ((int16)strlen(dial[FORM_BOUTON2].ob_spec.free_string) + 2) * FCM_RESCALE_WCHAR;
			largeur_total_bouton = largeur_total_bouton +dial[FORM_BOUTON2].ob_width;

			if( dial[FORM_BOUTON3].ob_flags & OF_HIDETREE )
			{
				nb_bouton=2;
			}
			else
			{
				nb_bouton=3;
				dial[FORM_BOUTON3].ob_width = ((int16)strlen(dial[FORM_BOUTON3].ob_spec.free_string) + 2) * FCM_RESCALE_WCHAR;
				largeur_total_bouton = largeur_total_bouton +dial[FORM_BOUTON3].ob_width;
			}
		}

		form_w = MAX( form_w, (largeur_total_bouton + (FCM_RESCALE_WCHAR * (nb_bouton+1)) ) );
	}


	{
		int16 espace_bouton;


		espace_bouton = (form_w - largeur_total_bouton) / (nb_bouton+1);

		dial[FORM_BOUTON1].ob_x = espace_bouton;

		if( nb_bouton > 1 )
		{
			dial[FORM_BOUTON2].ob_x = dial[FORM_BOUTON1].ob_x + dial[FORM_BOUTON1].ob_width + espace_bouton;
		}
		if( nb_bouton == 3 )
		{
			dial[FORM_BOUTON3].ob_x = dial[FORM_BOUTON2].ob_x + dial[FORM_BOUTON2].ob_width + espace_bouton;
		}
	}


	dial[0].ob_width  = form_w;
	dial[0].ob_height  = dial[FORM_BOUTON1].ob_y + dial[FORM_BOUTON1].ob_height + FCM_RESCALE_INTERLIGNE + FCM_RESCALE_MARGE_BAS;


	#undef IMG_FORM_WIDTH
	#undef IMG_FORM_HEIGHT


	return;

}


#endif   /* ___FCM_WIN_FORM_ALERT_C___ */

