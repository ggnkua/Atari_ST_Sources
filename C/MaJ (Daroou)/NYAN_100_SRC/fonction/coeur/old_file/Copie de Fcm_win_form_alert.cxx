/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 03/01/2017 MaJ 01/07/2017 * */
/* ***************************** */


#ifndef ___Fcm_win_form_alert___
#define ___Fcm_win_form_alert___

#include "Fcm_rescale_def.h"



/* Prototype */
/*int16 Fcm_win_form_alert( OBJECT *text_form_alert);*/
void Fcm_redraw_win_form_alert( void );
void Fcm_rescale_win_form_alert( void );



/* Fonction */
int16 Fcm_win_form_alert( /*const*/ int16 defaut_bouton, const char *text_form_alert )
{

	OBJECT *adr_form_alert;
	int16	handle_win;
	int16   reponse_dialogue=0;
	char    win_form_titre[]=PRG_FULL_NOM" Alert";
/*	char text_form_alert[]="[1][123456789012345678901234567890|123456789012345678901234567890|123456789012345678901234567890|123456789012345678901234567890|123456789012345678901234567890][1234567890|1234567890|1234567890]";
	defaut_bouton=3;*/

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"## Fcm_win_form_alert(%d, %s)"CRLF, defaut_bouton, text_form_alert );
	log_print( FALSE );
	#endif

	/* ouverture en fenetre ou en alerte systeme */
	{
		int16  winx,winy,winw,winh;
		int16  x,y,largeur,hauteur;
		int16  win_widgets;

		
		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" - Tentative ouverture en fenetre"CRLF );
		log_print( FALSE );
		#endif

		/*Fcm_rescale_win_form_alert();*/

		win_widgets=NAME|MOVER;

		/* on recherche l'adresse du Formulaire */
		rsrc_gaddr( R_TREE, DL_FORM_ALERT, &adr_form_alert );

		/* on demande … l'AES de le centrer sur le DeskTop */
		form_center( adr_form_alert, &winx, &winy, &winw, &winh );

		/* Calcul des dimensions de la fenetre en fonction */
		/* de la taille du formulaire                      */
		x       = winx;
		y       = winy;
		largeur = winw;
		hauteur = winh;


		{
			int16 dummy;
			
			graf_mkstate( &souris.g_x, &souris.g_y, &dummy, &dummy);
			/* on place le dialoque pres du curseur de la souris */
			x = souris.g_x - (largeur/2);
			y = souris.g_y - hauteur;

			/* on verifie que le dialogue n'est pas hors ecran */
			x = MAX( x, Fcm_screen.x_desktop );
			x = MIN( x, (Fcm_screen.w_desktop-largeur) );
			y = MAX( y, Fcm_screen.y_desktop );
			y = MIN( y, (Fcm_screen.h_desktop-hauteur) );
			y = MAX( y, (Fcm_screen.y_desktop+32) ); /* espace de 32 pixel pour la barre de titre de la fenetre */

			adr_form_alert->ob_x = x;
			adr_form_alert->ob_y = y;
		}


		/* on demande … l'AES de nous calculer la taille de la fenˆtre */
		/* en fonction de la zone de travail (taille formulaire)       */
		wind_calc( 0, win_widgets,	x, y, largeur, hauteur, &winx, &winy, &winw, &winh );


		/* On demande … l'AES de cr‚er notre fenˆtre */
		handle_win=wind_create( win_widgets, winx, winy, winw, winh);


		if( handle_win>0  )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "handle win=%2d ; x=%4d, y=%4d, w=%3d, h=%3d"CRLF, handle_win, winx, winy, winw, winh );
			log_print(FALSE);
			#endif

			/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un nom ... */
			wind_set_str(handle_win,WF_NAME, win_form_titre);

			/* on demande … l'AES de l'ouvrir */
			wind_open(handle_win,winx,winy,winw,winh);
		}
		else
		{
			/* version bloquante */
			return form_alert( defaut_bouton, text_form_alert );
		
		}
	}

	/* ---------------------------------------------------- */
	/* Affichage en fenêtre, il faut remplir le dialoque et */
	/* activer/desactiver certain objet                     */
	/* ---------------------------------------------------- */

	/*{
		char texte_winform[256];

		sprintf( texte_winform, "texte={%s}", text_form_alert );
		v_gtext(vdihandle,1*8,3*16,texte_winform);
	}*/

	{
		int16 image_type;
		
		image_type=(int16)(text_form_alert[1] - '1');  /* valeur decimal: ASCII '1' => 49 */

		/*{
			char texte_winform[256];
			sprintf( texte_winform, "image_type=%d   ", image_type );
			v_gtext(vdihandle,1*8,5*16,texte_winform);
		}*/

		/* on desactive tous les images */
		SET_BIT_W( (adr_form_alert+FORM_BT_EXCLA  )->ob_flags,   OF_HIDETREE, 1);
		SET_BIT_W( (adr_form_alert+FORM_BT_INTERRO)->ob_flags,   OF_HIDETREE, 1);
		SET_BIT_W( (adr_form_alert+FORM_BT_STOP   )->ob_flags,   OF_HIDETREE, 1);

		/* on les positionne au bon endroit */
/*		(adr_form_alert+FORM_BT_EXCLA  )->ob_y=0;
		(adr_form_alert+FORM_BT_INTERRO)->ob_y=0;
		(adr_form_alert+FORM_BT_STOP   )->ob_y=0;*/

		/* on active la bonne image */
		SET_BIT_W( (adr_form_alert+(FORM_BT_EXCLA+image_type/*-1*/))->ob_flags, OF_HIDETREE, 0);


	}


	{
		int16 idx_ligne;
		int16 idx_char;
		int16 max_char;
		char *pt_text_form_alert;
		int16 nb_bouton;
		
		max_char=strlen(text_form_alert);

		/* format texte alert                              */
		/* [x][ligne 1|ligne x|...][bouton 1|bouton x|...] */
		/* la premiere ligne commence en position 4        */


		/* Remplissage des lignes de texte */
		idx_ligne=0;
		pt_text_form_alert = (adr_form_alert+(FORM_LIGNE1+idx_ligne))->ob_spec.free_string;
		for( idx_char=4; idx_char<max_char; idx_char++ )
		{
			if( text_form_alert[idx_char] == '|' || text_form_alert[idx_char] == ']' )
			{
				/* fin de ligne ? */
				*pt_text_form_alert=0;  /* null byte, end of string */
				
				/* on pointe sur la prochaine ligne */
				idx_ligne++;
				pt_text_form_alert = (adr_form_alert+(FORM_LIGNE1+idx_ligne))->ob_spec.free_string;

				if( text_form_alert[idx_char] == ']' )
				{
					/* c'est la fin des lignes */
					break;
				}
			}
			else
			{
				/* on copie les caracteres de la ligne courante */
				*pt_text_form_alert++ = text_form_alert[idx_char];
			}
		}

		/* on efface les lignes inutilisées */
		for( ; idx_ligne<5; idx_ligne++ )
		{
			pt_text_form_alert = (adr_form_alert+(FORM_LIGNE1+idx_ligne))->ob_spec.free_string;
			*pt_text_form_alert=0;  /* null byte, end of string */
		}


		/*{
			char texte_winform[256];
			sprintf( texte_winform, "texte idx_ligne=%d   ", idx_ligne );
			v_gtext(vdihandle,1*8,6*16,texte_winform);
		}*/


		/* Remplissage des boutons */
		idx_char = idx_char + 2;   /* on passe les caracteres '][' */
		idx_ligne=0;
		pt_text_form_alert = (adr_form_alert+(FORM_BOUTON1+idx_ligne))->ob_spec.free_string;
		for( ; idx_char<max_char; idx_char++ )
		{
			if( text_form_alert[idx_char] == '|' || text_form_alert[idx_char] == ']' )
			{
				/* fin du texte bouton  ? */
				*pt_text_form_alert=0;  /* null byte, end of string */

				/* on pointe sur le prochaine bouton */
				idx_ligne++;
				SET_BIT_W( (adr_form_alert+(FORM_BOUTON1+idx_ligne))->ob_flags,   OF_HIDETREE, 0 );
				pt_text_form_alert = (adr_form_alert+(FORM_BOUTON1+idx_ligne))->ob_spec.free_string;

				if( text_form_alert[idx_char] == ']' )
				{
					/* c'est la fin des lignes */
					break;
				}
			}
			else
			{
				/* on copie les caracteres du bouton courant */
				*pt_text_form_alert++ = text_form_alert[idx_char];
			}
		}

		/* on memorise le nombre de bouton pour le centrage des boutons */
		nb_bouton=idx_ligne;
		
		/* on cache les boutons inutilisées */
		for( ; idx_ligne<3; idx_ligne++ )
		{
			SET_BIT_W( (adr_form_alert+(FORM_BOUTON1+idx_ligne))->ob_flags,   OF_HIDETREE, 1 );
		}



		/*{
			char texte_winform[256];
			sprintf( texte_winform, "bouton idx_ligne=%d  nb_bouton=%d ", idx_ligne, nb_bouton );
			v_gtext(vdihandle,1*8,7*16,texte_winform);
		}*/


		/* on centre les boutons */
		{
			int16 largeur_total_bouton=0;
			int16 ecart_bouton=0;
			
			for( idx_ligne=0; idx_ligne<nb_bouton; idx_ligne++ )
			{
				largeur_total_bouton = largeur_total_bouton + (adr_form_alert+(FORM_BOUTON1+idx_ligne))->ob_width;
			}

			ecart_bouton = (adr_form_alert->ob_width-largeur_total_bouton) / (nb_bouton+1);
			/*{
				char texte_winform[256];
				sprintf( texte_winform, "largeur_total_bouton=%d  ecart_bouton=%d  adr_form_alert->ob_width=%d", largeur_total_bouton, ecart_bouton, adr_form_alert->ob_width );
				v_gtext(vdihandle,1*8,8*16,texte_winform);
			}*/

			/* au minimum, il y a un bouton */
			(adr_form_alert+FORM_BOUTON1)->ob_x = ecart_bouton;
			idx_ligne=1;
			for( ; idx_ligne<nb_bouton; idx_ligne++ )
			{
				(adr_form_alert+(FORM_BOUTON1+idx_ligne))->ob_x = (adr_form_alert+(FORM_BOUTON1+idx_ligne-1))->ob_x + (adr_form_alert+(FORM_BOUTON1+idx_ligne-1))->ob_width + ecart_bouton;
			}

		}

		/*defaut_bouton=3;*/
		/* on active le bouton par defaut */
		for( idx_ligne=0; idx_ligne<nb_bouton; idx_ligne++ )
		{
			if( defaut_bouton == (idx_ligne+1) )
			{
				SET_BIT_W( (adr_form_alert+(FORM_BOUTON1+idx_ligne))->ob_flags,   OF_DEFAULT, 1 );
			}
			else
			{
				SET_BIT_W( (adr_form_alert+(FORM_BOUTON1+idx_ligne))->ob_flags,   OF_DEFAULT, 0 );
			}
		}
	
	}






	/* Gestion des ‚vŠnements et du dialogue */
	{
		int16	event,bouton,controlkey,touche,nb_click;



		#ifdef LOG_FILE
		sprintf( buf_log, CRLF""CRLF" - Gestion des ‚vŠnements et du dialogue"CRLF""CRLF);
		log_print(FALSE);
		#endif



		do
		{
			event=evnt_multi( MU_MESAG|MU_TIMER|MU_BUTTON|MU_KEYBD,
							FCM_EVENT_MBCLICKS, FCM_EVENT_MBMASK, FCM_EVENT_MBSTATE,
 							0,0,0,0,0,
							0,0,0,0,0,
							buffer_aes,TASK_TIMER,
							&souris.g_x,&souris.g_y,&bouton,&controlkey,
							&touche,&nb_click);






			/*{
				char texte_winform[256];

				if( buffer_aes[0]!=WM_REDRAW &&  buffer_aes[0]!=0x3039 )
				{
					sprintf( texte_winform, "*** event=%d ($%x) - Buffer_aes[0]=%d($%x) %ld  ***", event, event, buffer_aes[0], buffer_aes[0], Fcm_get_timer() );
					v_gtext(vdihandle,1*8,4*16,texte_winform);
				}
			}*/



/*#ifdef LOG_FILE
sprintf( buf_log, " - Gestion des ‚vŠnements et du pop up -  event=%d - Buffer_aes[0]=%d(0x%x) [1]=%d [2]=%d [3]=%d [4]=%d [5]=%d [6]=%d [7]=%d"CRLF, event, buffer_aes[0],buffer_aes[0],buffer_aes[1],buffer_aes[2],buffer_aes[3],buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);
log_print(FALSE);
#endif*/


			/* ------------------------------------------------- */
			/*                      MU_MESAG                     */
			/* ================================================= */
			if( event & MU_MESAG )
			{

				/* Que nous demande l'AES ? */
				switch( buffer_aes[0] )
				{
					case 12345:
						/* Message interne appl_write() */
						/* Il faut redessiner le contenu de la fenetre */
						if( Fcm_init_appli_terminer==TRUE ) gestion_timer();
						break;

					case WM_REDRAW:
						/* Il faut redessiner le contenu de la fentre */
						if( buffer_aes[3] == handle_win ) {
							Fcm_redraw_win_form_alert();
						} else {
							Fcm_gestion_redraw_fenetre();
						}
						break;

					case WM_BOTTOM:
						/* Oh... pourquoi doit-en se cacher ?  */
						/* on se met a l'arriere plan alors :( */
	 					break;

					case WM_SHADED:
					case WM_UNSHADED:
						/* Le contenu de notre fenetre est cach‚ ou affich‚ */
						Fcm_gestion_shaded();
						break;

					case WM_TOPPED:
					case WM_ONTOP:
						/* Une autre fenetre nous a pris la premiere place :(     */
						/* l'aes nous previent que ne sommes plus au premier plan */
						wind_set(handle_win,WF_TOP,buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);
						break;

					case WM_UNTOPPED:
						/* Une autre fenetre nous a pris la premiere place :(     */
						/* l'aes nous previent que ne sommes plus au premier plan */
						break;

					case MN_SELECTED:
						/* l'utilisateur a cliqu‚ sur une entr‚e du Menu */
						/* On remet le MENU dans son ‚tat d'origine      */
						/* On ne tient pas compte de la demande          */
						Fcm_menu_tnormal( BARRE_MENU, buffer_aes[3], 1 );
						break;

					case WM_CLOSED:
						/* on ferme la fenetre */
/*						if( buffer_aes[3]==handle_win )
						{
							reponse_dialogue=-1;
						}*/
	 					break;

					case WM_MOVED:
						/* tremblement de terre, la fenetre bouge :) */
						if( buffer_aes[3]==handle_win )
						{
							wind_set(buffer_aes[3],WF_CURRXYWH,buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);
							wind_get(buffer_aes[3],WF_WORKXYWH,&buffer_aes[4],&buffer_aes[5],&buffer_aes[6],&buffer_aes[7]);
							adr_form_alert->ob_x = buffer_aes[4];
							adr_form_alert->ob_y = buffer_aes[5];
						}
						else
						{
							Fcm_gestion_moved();
						}
						break;

					case WM_ICONIFY:
					case WM_ALLICONIFY:
						Fcm_gestion_iconify(controlkey);
	   					break;

					case WM_UNICONIFY:
						Fcm_gestion_uniconify();
		   				break;


/*					case AP_TERM:*/
						/* on doit mettre fin a notre application */
						/* alors on ferme tout et on quitte :(    */
/*						#ifdef LOG_FILE
						sprintf( buf_log, "# reception message AP_TERM"CRLF);
						log_print( FALSE );
						#endif
						return;
		   				break;*/


					default:
						#ifdef LOG_FILE
						sprintf(texte,"Message AES inconnu: event=%d BUF[0]=%d(0x%x) BUF[1]=%d BUF[2]=%d BUF[3]=%d ",event, buffer_aes[0], buffer_aes[0],buffer_aes[1],buffer_aes[2],buffer_aes[3]);
						v_gtext(vdihandle,4*8,6*16,texte);

						sprintf( buf_log, texte);
						log_print(FALSE);

						sprintf(texte,"BUF[4]=%d BUF[5]=%d BUF[6]=%d BUF[7]=%d "CRLF,buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);
						v_gtext(vdihandle,4*8,7*16,texte);
						sprintf( buf_log, texte);
						log_print(FALSE);
						#endif

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

				/*{
					char texte_winform[256];

					sprintf( texte_winform, "*** objet find = %d   ", objet );
					v_gtext(vdihandle,1*8,2*16,texte_winform);
				}*/

				if( objet>=FORM_BOUTON1 && objet<=(FORM_BOUTON1+2) )
				{
					if( Fcm_gestion_objet_bouton( adr_form_alert, handle_win, objet ) == objet )
					{
						/* Bouton  valid‚ */
						reponse_dialogue = objet - FORM_BOUTON1 + 1;
					}

				}

				/*{
					char texte_winform[256];

					sprintf( texte_winform, "*** objet=%d reponse_dialogue=%d                  ", objet, reponse_dialogue );
					v_gtext(vdihandle,1*8,3*16,texte_winform);
				}*/


			}


			/* ------------------------------------------------- */
			/*                      MU_KEYBD                     */
			/* ================================================= */
			if( event & MU_KEYBD)
			{
				int16  bouton_selection=-1;
				
				/*{
					char texte_winform[256];

					sprintf( texte_winform, "*** controlkey=$%x touche=$%x   ", controlkey, touche );
					v_gtext(vdihandle,1*8,1*16,texte_winform);
				}*/
				
				switch( touche & 0xff00 )
				{
					case 0x7200:  /* Return 1 */
					case 0x1C00:  /* Return 2 */
						if( defaut_bouton!=0 )
						{
							bouton_selection=defaut_bouton;
						}
						break;
					case 0x3b00:  /* F1 */
						bouton_selection=1;
						break;
					case 0x3c00:  /* F2 */
						bouton_selection=2;
						break;
					case 0x3d00:  /* F3 */
						bouton_selection=3;
						break;
				}

				if( bouton_selection != -1 )
				{
					if( ((adr_form_alert+(FORM_BOUTON1+bouton_selection-1))->ob_flags  & OF_HIDETREE) == 0 )
					{
						reponse_dialogue = bouton_selection;
						Fcm_objet_change( adr_form_alert, handle_win,(FORM_BOUTON1+bouton_selection-1), OS_SELECTED );
						evnt_timer(FCM_BT_PAUSE_DOWN);
						Fcm_objet_change( adr_form_alert, handle_win,(FORM_BOUTON1+bouton_selection-1), 0 );
						evnt_timer(FCM_BT_PAUSE_UP);
					}
				}

				/*{
					char texte_winform[256];

					sprintf( texte_winform, "*** bouton_selection=$%x reponse_dialogue=$%x   ", bouton_selection, reponse_dialogue );
					v_gtext(vdihandle,1*8,2*16,texte_winform);
				}*/
				/*reponse_dialogue=0;*/
			}


			/* ------------------------------------------------- */
			/*                      MU_TIMER                     */
			/* ================================================= */
			if( event & MU_TIMER )
			{
				if( Fcm_init_appli_terminer==TRUE ) gestion_timer();
			}



		} while( reponse_dialogue==0 );
	}





	if( handle_win > 0 )
	{
		wind_close( handle_win );
		wind_delete( handle_win );
	}


	return(reponse_dialogue);


}






















/* Fonction */
void Fcm_redraw_win_form_alert( void )
{
	OBJECT *adr_dialogue;
	GRECT	r1,r2;


	/* on recherche l'adresse du Formulaire */
	rsrc_gaddr( R_TREE, DL_FORM_ALERT, &adr_dialogue );


	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"- Fcm_redraw_win_form_alert"CRLF );
	log_print(FALSE);
	#endif


	/* coordonnee de la zone a redessinner */
	r1.g_x = buffer_aes[4];
	r1.g_y = buffer_aes[5];
	r1.g_w = buffer_aes[6];
	r1.g_h = buffer_aes[7];


	/* On r‚serve l'‚cran pour ne pas entrer en conflict avec des     */
	/* affichages venant d'autres applications.                       */
	/* Si une appli a d‚j… r‚serv‚ l'‚cran, la fonction Wind_Update() */
	/* va attendre jusqu'… ce que l'‚cran soit lib‚r‚...              */
	if( wind_update(BEG_UPDATE) )  
	{

		/* C'est bon, on peut redessiner notre fenetre... */
		wind_get(buffer_aes[3],WF_FIRSTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);

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

				/*objc_draw( adr_dialogue,0,4, Fcm_screen.x_desktop, Fcm_screen.y_desktop, Fcm_screen.w_desktop, Fcm_screen.h_desktop);*/
				objc_draw( adr_dialogue,0,4, r2.g_x, r2.g_y, r2.g_w, r2.g_h);

			 	vs_clip( vdihandle, CLIP_OFF, 0);
				graf_mouse(M_ON, NULL);
			}

			wind_get(buffer_aes[3],WF_NEXTXYWH,&r2.g_x,&r2.g_y,&r2.g_w,&r2.g_h);
		}

		/* On libŠre l'‚cran */
		wind_update(END_UPDATE);
	}


	return;


}



#endif   /* ___Fcm_win_form_alert___ */



void Fcm_rescale_win_form_alert (void )
{

	OBJECT	*dial;
	/*int16    form_w;*/
	/*int16    gr_hwbox, gr_hhbox;*/
	int16	 gr_hwcar,gr_hhcar;


	

	#define IMG_FORM_WIDTH  (32)
	#define IMG_FORM_HEIGHT (32)

	
	/* Marre que le formulaire s'affiche mal d'une resolution a l'autre */
	/* tous les objets et le fond sont repositionner                    */

	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_rescale_fenetre_launch()"CRLF );
	log_print(FALSE);
	#endif


	/* espace occuper par les caracteres de la fonte systeme */
	{
		int16 dummy;

		/*graf_handle( &gr_hwcar, &gr_hhcar, &gr_hwbox, &gr_hhbox );*/
		graf_handle( &gr_hwcar, &gr_hhcar, &dummy, &dummy );
/*		{
			char texte_surface[80];
			sprintf( texte_surface, "gr_hwcar=%d, gr_hhcar=%d, gr_hwbox=%d, gr_hhbox=%d", gr_hwcar, gr_hhcar, gr_hwbox, gr_hhbox );
			v_gtext( vdihandle, 1*16, 2*16, texte_surface);
		}*/
	}


	/* on cherche l'adresse du formulaire et l'objet sous la souris */
	rsrc_gaddr( R_TREE, DL_FORM_ALERT, &dial );
/*
FORM_CADRE_IMAGE
#define DL_FORM_ALERT    7   
#define FORM_BT_EXCLA    2   
#define FORM_BT_INTERRO  3   
#define FORM_BT_STOP     4   
#define FORM_LIGNE1      5   
#define FORM_LIGNE2      6   
#define FORM_LIGNE3      7   
#define FORM_LIGNE4      8   
#define FORM_LIGNE5      9   
#define FORM_BOUTON1     10  
#define FORM_BOUTON2     11  
#define FORM_BOUTON3     12  
*/
		{
			char texte_surface[80];
			sprintf( texte_surface, "dial[0].ob_width=%d", dial[0].ob_width );
			v_gtext( vdihandle, 1*16, 2*16, texte_surface);
		}
	dial[FORM_CADRE_IMAGE].ob_x     = FCM_RESCALE_MARGE_GAUCHE;
	dial[FORM_CADRE_IMAGE].ob_y     = FCM_RESCALE_MARGE_HAUT;

	dial[FORM_BT_EXCLA].ob_x     = 0;
	dial[FORM_BT_EXCLA].ob_y     = 0;
	dial[FORM_BT_INTERRO].ob_x     = 0;
	dial[FORM_BT_INTERRO].ob_y     = 0;
	dial[FORM_BT_STOP].ob_x     = 0;
	dial[FORM_BT_STOP].ob_y     = 0;

	dial[FORM_LIGNE1].ob_x     = dial[FORM_CADRE_IMAGE].ob_x + IMG_FORM_WIDTH + FCM_RESCALE_ESPACE;
	dial[FORM_LIGNE1].ob_y     = FCM_RESCALE_MARGE_HAUT;
	
/*	dial[LAUNCH_BOX].ob_x       = FCM_RESCALE_MARGE_GAUCHE;
	dial[LAUNCH_BOX].ob_y       = dial[LAUNCH_IMAGE].ob_y + IMG_LAUNCH_HEIGHT + FCM_RESCALE_INTERLIGNE;
	dial[LAUNCH_FOND].ob_width  = dial[LAUNCH_BOX].ob_x + dial[LAUNCH_BOX].ob_width + FCM_RESCALE_MARGE_DROITE;
	dial[LAUNCH_IMAGE].ob_x     = (dial[LAUNCH_FOND].ob_width - IMG_LAUNCH_WIDTH) / 2;
	dial[LAUNCH_FOND].ob_height = dial[LAUNCH_BOX].ob_y + dial[LAUNCH_BOX].ob_height + FCM_RESCALE_MARGE_BAS;
*/

	#undef IMG_FORM_WIDTH
	#undef IMG_FORM_HEIGHT


	return;

}