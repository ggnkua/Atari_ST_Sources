/* *[Console]******************* */
/* *                           * */
/* * 01/01/2024 MaJ 03/01/2024 * */
/* ***************************** */

void Fcm_console_add( char *cons_texte, int16 cons_color )
{
	static int16 flag_message_en_cours = FALSE;
	static int16 idx_message_a_afficher = -1;
	static int16 idx_message_save = 0;
	       int16 saut2ligne=TRUE;
	       int16 redraw_all=FALSE;



	/* On mémorise le messge reçu dans une liste car il y a réentrance      */
	/* si on recoit un nouveau message via Fcm_purge_aes_message()          */
	/* MyAES et TOSwin envoie des messages inconnu qui arrive à tout moment */
	/* MyAES: Message 80 lors de la fermeture du selecteur de fichier       */
	/* TOSwin: Message xx quand on clic sur la fenetre console, message à   */
	/*         toutes les applis, toutes les consoles de mes applis s'ouvre */
	/*         si elles sont en fonctionnement */
	{
		int16 idx;
		int16 compteur_recherche;

		/* (-1) si tous les messages ont été affiché */
		/* donc la liste des messages est vide       */
		if( idx_message_a_afficher == -1 )
		{
			idx_message_a_afficher = 0;
			idx_message_save = 0;
		}

		idx = idx_message_save;
		compteur_recherche = 0; /* savoir si la liste est saturé */

		do
		{
			if( Fcm_console_message_save[idx][0] == 0 )
			{
				/* emplacement vide, on enregistre le message */
				snprintf( Fcm_console_message_save[idx], FCM_CONSOLE_TEXTE_MAXLEN, "%d - %s", idx, cons_texte );
				Fcm_console_couleur_save[idx] = cons_color;
			}
			else
			{
				compteur_recherche++;
				idx++;

				if( idx == FCM_CONSOLE_MESSAGE_SAVE_MAX )  idx = 0;
			}
		} while ( compteur_recherche < FCM_CONSOLE_MESSAGE_SAVE_MAX );
	}


/* buffer pour mémoriser les messages Console (ré-entrance) */
//#define FCM_CONSOLE_MESSAGE_SAVE_MAX (6)
//char Fcm_console_message_save[FCM_CONSOLE_MESSAGE_SAVE_MAX][FCM_CONSOLE_TEXTE_MAXLEN];

	/* si on est déjà dans la fonction, on quitte, le message a été */
	/* enregistré dans la liste et sera bien affiché                */
	if( flag_message_en_cours == TRUE ) return;


	/* On entre dans la fonction */
	flag_message_en_cours = TRUE;


	/* une boucle pour afficher la liste des messages */
	do
	{
		int16 compteur_recherche;
		/*
		Le jour ou la console sera configurable, faire le test des couleurs d'affichage
		pour voir si elle est différente de la couleur du fond.
		*/


		/* La console n'est pas ouverte par defaut, seulement si un message est transmis.  */
		/* En cas de changement de langue, les fenetres sont fermées et ré-ouverte avec le */
		/* nouveau RSC, sauf la console */
		if( h_win[W_CONSOLE] <= 0 )
		{
			Fcm_console_ouvre_fenetre();
			Fcm_purge_aes_message();
		}

		/* a gere plus tard ???????????????????????????????????????????????????????????????????????????????????? */
		if( Fcm_screen.nb_plan < 4 )
		{
			cons_color = G_WHITE;
		}


		/* on vérifie si toutes les lignes de la console sont utilisée */
		/* en fait, c'est toujours 'plein', en ecrit tout le temps */
		/* dans la derniere ligne... */
		if( Fcm_struct_console_global.ligne_active == FCM_CONSOLE_MAXLIGNE )
		{
			int16 num_ligne;

			/* on deborde, on 'supprime' la premiere ligne, on deplace les autres */
			/* la derniere devient libre pour le nouveau texte                   */
			for( num_ligne=1; num_ligne<FCM_CONSOLE_MAXLIGNE ; num_ligne++ )
			{
				strcpy( Fcm_struct_console_texte[(num_ligne-1)].texte, Fcm_struct_console_texte[num_ligne].texte );
				Fcm_struct_console_texte[(num_ligne-1)].texte_color  = Fcm_struct_console_texte[num_ligne].texte_color;
				Fcm_struct_console_texte[(num_ligne-1)].texte_lenght = Fcm_struct_console_texte[num_ligne].texte_lenght;
			}

			Fcm_struct_console_global.ligne_active = (FCM_CONSOLE_MAXLIGNE-1);

			redraw_all=TRUE;
		}

		/* y a t-il un ou plusieurs CRLF ? */
		{
			char  *pt_position;

			do
			{
				pt_position = strstr(cons_texte, CRLF);

				if( pt_position != NULL )
				{
					/* on supprime le CRLF */
					strcpy( pt_position, (pt_position+2) );
				}
			} while( pt_position != NULL );
		}



		{
			char  *pt_position;

			pt_position = strstr(cons_texte, "NOCRLF");

			if( pt_position != NULL )
			{
				saut2ligne=FALSE;
				/* on supprime le 'NOCRLF' */
				strcpy( pt_position, (pt_position+6) );
			}
		}


		snprintf( Fcm_struct_console_texte[Fcm_struct_console_global.ligne_active].texte, FCM_CONSOLE_TEXTE_MAXLEN, /*"%s %d", */cons_texte/*, saut2ligne*/);
		
		Fcm_struct_console_texte[Fcm_struct_console_global.ligne_active].texte_color  = cons_color;
		Fcm_struct_console_texte[Fcm_struct_console_global.ligne_active].texte_lenght = strlen(Fcm_struct_console_texte[Fcm_struct_console_global.ligne_active].texte);



		//console_aes[0]=WM_REDRAW;            /* message type */
		//console_aes[1]=ap_id;                /* application id */
		//console_aes[2]=0;                    /* length of the message, 0 si message standard */
		//console_aes[3]=h_win[W_CONSOLE];     /* handle de la fenetre pour WM_REDRAW */

		if( redraw_all == TRUE )
		{
			console_aes[4]=Fcm_screen.x_desktop; /* pas besoin de determiner la zone de la console */
			console_aes[5]=Fcm_screen.y_desktop; /* la fonction redraw va la rechercher            */
			console_aes[6]=Fcm_screen.w_desktop;
			console_aes[7]=Fcm_screen.h_desktop;
			//appl_write( ap_id, 16, console_aes);
			Fcm_gestion_redraw_console();
		}
		else
		{
			int16	winx,winy,winw,winh;

			/* si la ligne est visible */
			if(    (Fcm_struct_console_global.ligne_active >= Fcm_struct_console_global.ligne_start)
				&& (Fcm_struct_console_global.ligne_active <= Fcm_struct_console_global.ligne_start+Fcm_struct_console_global.nbligne_visible) )
			{
				wind_get(h_win[W_CONSOLE],WF_WORKXYWH,&winx,&winy,&winw,&winh);

				winy = winy + ((Fcm_struct_console_global.ligne_active - Fcm_struct_console_global.ligne_start)*Fcm_struct_console_global.char_cellh);
				winh = Fcm_struct_console_global.char_cellh;

				console_aes[4]=winx;
				console_aes[5]=winy;
				console_aes[6]=winw;
				console_aes[7]=winh;
				//appl_write( ap_id, 16, console_aes);
				Fcm_gestion_redraw_console();
			}
		}
		Fcm_purge_aes_message();
		//evnt_timer(0);



		if( saut2ligne == TRUE )
		{
			/* il y avait un saut de ligne, on avance d'une ligne pour le prochain texte */
			Fcm_struct_console_global.ligne_active++;
		}


	/* on sort de la boucle quand il n'y a plus de message à afficher */
	} while ( compteur_recherche < FCM_CONSOLE_MESSAGE_SAVE_MAX );


	flag_message_en_cours=FALSE;

	return;

}

