/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 09/06/2018 MaJ 19/02/2024 * */
/* ***************************** */



/* -------------------------------------------------------------- */
/* permet de deplacer les sous-menus dans les petites resolutions */
/* afin quelle ne sortent pas de l'ecran a droite                 */
/* -------------------------------------------------------------- */
/* Reduit egalement le titre s'il sort de l'ecran                 */
/* Le titre ne doit sortir que partiellment de l'ecran, s'il sort */
/* totalement de l'ecran, rien a faire...                         */
/* -------------------------------------------------------------- */



/*
 *
 * 25/06/2020: Reduction du dernier Titre de MENU s'il sort de l'ecran
 *
 */






void Fcm_rescale_bar_menu( void )
{
	OBJECT	*dial;


	FCM_LOG_PRINT(CRLF"# Fcm_rescale_bar_menu()");


	/* on cherche l'adresse de la barre du Menu */
	dial = Fcm_adr_RTREE[BARRE_MENU];


	/* --------------------------------------------------------------------- */
	/* Reduction de la taille du dernier titre de MENU s'il sort de l'écran  */
	/* --------------------------------------------------------------------- */
	{
		int16 decalage_gauche;
		int16 idx_objet;
		int16 idx_parent;


		/* ROOT(G_IBOX) */
		/* pas de decalage normalement */
		decalage_gauche = dial[0].ob_x;

		//FCM_CONSOLE_ADD2("0. decalage_gauche = dial[0].ob_x=%d", dial[0].ob_x, G_GREEN );
		//FCM_CONSOLE_ADD2("dial[0].ob_width=%d", dial[0].ob_width, G_GREEN );

		/* ob_head designe le premier enfant de ROOT */
		/* c'est la BAR(G_BOX) */
		/* pas de decalage normalement */
		idx_objet = dial[0].ob_head;  
		decalage_gauche = decalage_gauche + dial[idx_objet].ob_x;

		//FCM_CONSOLE_ADD2("1. decalage_gauche = %d", decalage_gauche, G_GREEN );
		//FCM_CONSOLE_ADD2("dial[idx_objet].ob_width=%d", dial[idx_objet].ob_width, G_GREEN );

		/* on verifie qu'il s'agit bien d'une G_BOX, en cas */
		/* d'evolution de la structure dans l'avenir        */
		if( dial[idx_objet].ob_type == G_BOX )
		{
			/* ob_head designe le premier enfant de BAR(G_BOX) */
			/* un seul enfant, ACTIVE(G_IBOX)                  */
			/* decalage present normalement */
			idx_objet = dial[idx_objet].ob_head;
			decalage_gauche = decalage_gauche + dial[idx_objet].ob_x;

			//FCM_CONSOLE_ADD2("2. decalage_gauche = %d", decalage_gauche, G_GREEN );
			//FCM_CONSOLE_ADD2("dial[idx_objet].ob_width=%d", dial[idx_objet].ob_width, G_GREEN );


			/* on verifie qu'il s'agit bien d'une G_IBOX , en cas */
			/*	d'evolution de la structure dans l'avenir       */
			if( dial[idx_objet].ob_type == G_IBOX  )
			{
				idx_parent = idx_objet; /* ACTIVE(G_IBOX) */
			
				/* les enfants d' ACTIVE(G_IBOX) sont les titres de MENU */
				/* ob_head designe le premier enfant (G_TITLE)           */
				idx_objet = dial[idx_objet].ob_head;

				do
				{
					//FCM_CONSOLE_ADD3("dial[%d].ob_type=%d (G_TITLE 32)", idx_objet, dial[idx_objet].ob_type, G_GREEN );
					//FCM_CONSOLE_ADD3("dial[%d].ob_x=%d", idx_objet, dial[idx_objet].ob_x, G_GREEN );
					//FCM_CONSOLE_ADD3("dial[%d].ob_y=%d", idx_objet,  dial[idx_objet].ob_y, G_GREEN );
					//FCM_CONSOLE_ADD3("dial[%d].ob_width=%d", idx_objet,  dial[idx_objet].ob_width, G_GREEN );
					//FCM_CONSOLE_ADD3("dial[%d].ob_height=%d", idx_objet,  dial[idx_objet].ob_height, G_GREEN );
					//FCM_CONSOLE_ADD2("-- idx_parent=%d", idx_parent, G_WHITE );

					/* on verifie qu'il s'agit bien d'un objet G_TITLE */
					if( dial[idx_objet].ob_type == G_TITLE )
					{

//dial[6].ob_width = 120;

//FCM_CONSOLE_ADD2("dial[idx_objet].ob_spec.free_string={%s}", dial[idx_objet].ob_spec.free_string, G_YELLOW );
//FCM_CONSOLE_ADD3("==> X2=%d    Fcm_screen.w_desktop=%d", (decalage_gauche + (dial[idx_objet].ob_x + dial[idx_objet].ob_width - 1)), Fcm_screen.w_desktop, G_YELLOW );
//FCM_CONSOLE_ADD3("dial[%d].ob_width=%d", idx_objet, dial[idx_objet].ob_width, G_CYAN );

						/* est-ce que ca depasse de l'ecran ? */
						if( decalage_gauche + (dial[idx_objet].ob_x + dial[idx_objet].ob_width - 1) >= Fcm_screen.w_desktop )
						{
							int16 nb_char_possible;

							/* on verifier que le G_TITLE n'est pas hors ecran... */
							if( (decalage_gauche + dial[idx_objet].ob_x)  <  Fcm_screen.w_desktop )
							{
								/* on reduit le cadre du texte pour ne pas sortir de l'ecran */
								dial[idx_objet].ob_width = Fcm_screen.w_desktop - dial[idx_objet].ob_x - decalage_gauche + 0;

//FCM_CONSOLE_ADD2("=> recalage du Menu decalage_gauche=%d", decalage_gauche, G_CYAN );
//FCM_CONSOLE_ADD4("dial[%d].ob_width=%d  Fcm_screen.gr_hwchar=%d", idx_objet, dial[idx_objet].ob_width, Fcm_screen.gr_hwchar, G_CYAN );
//FCM_CONSOLE_ADD3("==> X2=%d    Fcm_screen.w_desktop=%d", (decalage_gauche + (dial[idx_objet].ob_x + dial[idx_objet].ob_width - 1)), Fcm_screen.w_desktop, G_YELLOW );

								/* on reduit la taille du texte pour ne pas sortir */
								/*  de l'ecran et continuer à gauche de l'ecran    */
								nb_char_possible = dial[idx_objet].ob_width / Fcm_screen.gr_hwchar;

//FCM_CONSOLE_ADD2("nb_char_possible=%d", nb_char_possible, G_GREEN );
//FCM_CONSOLE_ADD3("strlen( dial[%d].ob_spec.free_string )=%ld", idx_objet, strlen( dial[idx_objet].ob_spec.free_string ), G_GREEN );

								//dial[idx_objet].ob_spec.free_string[nb_char_possible-1]='*';
								if( strlen( dial[idx_objet].ob_spec.free_string )  >  (uint16)nb_char_possible )
								{
									dial[idx_objet].ob_spec.free_string[nb_char_possible] = 0;
								}
							}
							else
							{
								FCM_CONSOLE_DEBUG("ERREUR: Fcm_rescale_bar_menu() G_TITLE est hors ecran" );
							}
						}
					}
					else
					{
						FCM_CONSOLE_DEBUG("ERREUR: Fcm_rescale_bar_menu() objet n'est pas un G_TITLE" );
					}

					/* on cherche l'objet suivant, si plus d'objet, on recoit l'index de l'IBOX parent */
					idx_objet = dial[idx_objet].ob_next;

					//FCM_CONSOLE_ADD3("-- idx_parent=%d  idx_objet=%d", idx_parent, idx_objet, G_MAGENTA );

				} while( idx_objet != idx_parent );
			}
			else
			{
				FCM_CONSOLE_DEBUG("ERREUR: Fcm_rescale_bar_menu() objet n'est pas un G_IBOX" );
			}
		}
		else
		{
			FCM_CONSOLE_DEBUG("ERREUR: Fcm_rescale_bar_menu() objet n'est pas un G_BOX" );
		}
	}


//return;


	/* ---------------------------------------------- */
	/* Recalage des Sous-MENU pour qu'il ne sorte pas */
	/* de l'ecran en basse résolution                 */
	/* ---------------------------------------------- */
	{
		int16 ibox_parent;
		int16 idx_objet;
		int16 erreur = FALSE;


		FCM_LOG_PRINT("  * Recalage sous MENU");

		/* ROOT (G_IBOX) a deux enfants: BAR(G_BOX) et DROPDOWNS(G_IBOX)     */
		/* ob_head pointe sur le premier enfant BAR(G_BOX)                   */
		/* ob_tail pointe sur le dernier enfant DROPDOWNS(G_IBOX)            */
		/* https://freemint.github.io/tos.hyp/en/aes_fundamentals.html 8.2.4 */

		idx_objet  = dial[0].ob_tail; /* DROPDOWNS(G_IBOX) */
		ibox_parent = idx_objet;

		//FCM_CONSOLE_ADD2("G_IBOX contenant les sous menus=%d", idx_objet, G_GREEN );

		/* DROPDOWNS(G_IBOX) a pour enfant des G_BOX pour */
		/* chaque G_TITLE, chaque G_BOX est un sous-MENU  */
		/* ob_head pointe sur le premier enfant (G_BOX)   */
		idx_objet  = dial[idx_objet].ob_head;

		//FCM_CONSOLE_ADD2("index Premier sous MENU=%d", idx_objet, G_GREEN );

		do
		{
			//FCM_CONSOLE_ADD3("dial[%d].ob_type=%d", idx_objet, dial[idx_objet].ob_type, G_WHITE );
			//FCM_CONSOLE_ADD5("dial[].ob_x=%d  dial[].ob_y=%d  dial[].ob_width=%d  dial[].ob_height=%d", dial[idx_objet].ob_x, dial[idx_objet].ob_y, dial[idx_objet].ob_width, dial[idx_objet].ob_height, G_WHITE );

			/* on verifie qu'il s'agit bien d'un objet G_BOX */
			/* chaque sous MENU commence par une G_BOX       */
			if( dial[idx_objet].ob_type == G_BOX )
			{
				/* est-ce que ca depasse de l'ecran ? */
				if( (dial[idx_objet].ob_x + dial[idx_objet].ob_width) >= Fcm_screen.w_desktop )
				{
					/* on recale le sous menu au maximum a droite avec une marge de 4 pixels */
					dial[idx_objet].ob_x = Fcm_screen.w_desktop - dial[idx_objet].ob_width - 4;

					//FCM_CONSOLE_ADD("=> recalage du Menu", G_YELLOW );
					//FCM_CONSOLE_ADD3("dial[%d].ob_x=%d", idx_objet, dial[idx_objet].ob_x, G_YELLOW );
				}
			}
			else
			{
				erreur = TRUE;
				FCM_CONSOLE_DEBUG("ERREUR: Fcm_rescale_bar_menu() sousMenu objet n'est pas un G_BOX" );
			}

			/* on cherche l'objet suivant, si plus d'objet, on recoit l'index de l'IBOX parent */
			idx_objet = dial[idx_objet].ob_next;

			//FCM_CONSOLE_ADD3("idx_objet=%d  ibox_parent=%d", idx_objet, ibox_parent, G_LMAGENTA );
			
		} while( idx_objet != ibox_parent   &&   erreur == FALSE );
	}


	return;

}

