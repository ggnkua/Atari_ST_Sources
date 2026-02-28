/* **[Fonction Commune]********* */
/* *                           * */
/* * 28/05/2015 MaJ 02/06/2015 * */
/* ***************************** */




#ifndef ___Fcm_gestion_pop_up___
#define ___Fcm_gestion_pop_up___




#include "Fcm_gestion_redraw_fenetre.c"
#include "Fcm_gestion_shaded.c"
#include "Fcm_gestion_bottom.c"
#include "Fcm_mouse_no_bouton.c"
#include "Fcm_get_timer.c"
#include "Fcm_gestion_barre_menu.c"



#include "Fcm_gestion_Fermeture_Fenetre.c"
/*#include "Fcm_gestion_souris.c"*/
/*#include "Fcm_gestion_clavier.c"*/
/*#include "Fcm_gestion_va_start.c"*/
/*#include "Fcm_gestion_perte_ldg.c"*/
#include "Fcm_gestion_uniconify.c"
#include "Fcm_gestion_iconify.c"
/*#include "Fcm_gestion_topped.c"*/
/*#include "Fcm_gestion_untopped.c"*/
/*#include "Fcm_gestion_ontop.c"*/
#include "Fcm_gestion_moved.c"




#define POP_UP_BOX (0)



/* Prototype */
int16 Fcm_gestion_pop_up( OBJECT *pop_up/*, int16 handle_host_win*/ );
void  Fcm_redraw_pop_up(OBJECT *pop_up);




/* Fonction */
int16 Fcm_gestion_pop_up( OBJECT *pop_up/*, int16 handle_host_win*/ )
{

/*	char    my_buffer[ (TAILLE_CHEMIN+TAILLE_FICHIER) ];
	OBJECT *adr_popup;
	OBJECT *adr_dl_preference;
	int16   y;
*/
	int16	handle_win;
	int16   reponse_pop_up=0;
	int16   flag_mouse_no_bouton=1;
	int16   winx,winy,winw,winh;





	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"## Fcm_gestion_pop_up(%p)"CRLF, pop_up );
	log_print( FALSE );
	#endif


	Fcm_mouse_no_bouton();


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" - Tentative ouverture en fenetre"CRLF );
	log_print( FALSE );
	#endif

	{
		int16  epaisseur_cadre;
		int16  x,y,largeur,hauteur;
		uint16 win_flag;


		epaisseur_cadre = pop_up[POP_UP_BOX].ob_spec.obspec.framesize * -1;


		win_flag=0/*NAME*/;

		/* on demande … l'AES de le centrer sur le DeskTop */
/*		form_center( adr_formulaire, &winx, &winy, &winw, &winh );*/

		winx = pop_up[POP_UP_BOX].ob_x-epaisseur_cadre;
		winy = pop_up[POP_UP_BOX].ob_y-epaisseur_cadre;
		winw = pop_up[POP_UP_BOX].ob_width +epaisseur_cadre+epaisseur_cadre;
		winh = pop_up[POP_UP_BOX].ob_height+epaisseur_cadre+epaisseur_cadre;

		/* Calcul des dimensions de la fenetre en fonction */
		/* de la taille du formulaire                      */
		x       = winx;
		y       = winy;
		largeur = winw;
		hauteur = winh;

		/* on demande … l'AES de nous calculer la taille de la fenˆtre */
		/* en fonction de la zone de travail (taille formulaire)       */
		wind_calc( 0, win_flag,	x, y, largeur, hauteur, &winx, &winy, &winw, &winh );


		/* On demande … l'AES de cr‚er notre fenˆtre */
		handle_win=wind_create( win_flag, winx, winy, winw, winh);


		if( handle_win > 0 )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "handle win=%2d ; x=%4d, y=%4d, w=%3d, h=%3d"CRLF, handle_win, winx, winy, winw, winh );
			log_print(FALSE);
			#endif

			/* on demande … l'AES de l'ouvrir */
			wind_open(handle_win,winx,winy,winw,winh);
		}
		else
		{
			/* version bloquante */

			handle_win=FCM_NO_OPEN_WINDOW;

			wind_update(BEG_UPDATE);
/*			wind_update(BEG_MCTRL);*/
			objc_draw( pop_up,0,4, Fcm_screen.x_desktop, Fcm_screen.y_desktop, Fcm_screen.w_desktop, Fcm_screen.h_desktop);
		}
	}





	/* Gestion des ‚vŠnements et du pop up */
	{
		int16	event,bouton,controlkey,touche,nb_click;
/*		int16   nb_boucle=0;*/
		int16   old_select_objet=-1;



		#ifdef LOG_FILE
		sprintf( buf_log, CRLF""CRLF" - Gestion des ‚vŠnements et du pop up"CRLF""CRLF);
		log_print(FALSE);
		#endif



		do
		{
			event=evnt_multi( MU_MESAG|MU_TIMER|MU_BUTTON,
							EVENT_BCLICK,3,0,
 							0,0,0,0,0,
							0,0,0,0,0,
							buffer_aes,TASK_TIMER,
							&souris.g_x,&souris.g_y,&bouton,&controlkey,
							&touche,&nb_click);



/*			nb_boucle++;*/



/*			{
				char texte[256];


				sprintf( texte, "*** event=%d ($%x) - Buffer_aes[0]=%d($%x) %ld  ***", event, event, buffer_aes[0], buffer_aes[0], Fcm_get_timer() );
				v_gtext(vdihandle,4*8,4*16,texte);

				sprintf( texte, "Fcm_gestion_aes_message() *** nb_bouble=%d    ", nb_boucle );
				v_gtext(vdihandle,4*8,5*16,texte);
			}*/



#ifdef LOG_FILE
sprintf( buf_log, " - Gestion des ‚vŠnements et du pop up -  event=%d - Buffer_aes[0]=%d(0x%x) [1]=%d [2]=%d [3]=%d [4]=%d [5]=%d [6]=%d [7]=%d"CRLF, event, buffer_aes[0],buffer_aes[0],buffer_aes[1],buffer_aes[2],buffer_aes[3],buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);
log_print(FALSE);
#endif


			/* ------------------------------------------------- */
			/*                      MU_MESAG                     */
			/* ================================================= */
			if( event & MU_MESAG )
			{

				/* Que nous demande l'AES ? */
				switch( buffer_aes[0] )
				{
					case 0x3039:
						/* Message interne appl_write() */
						/* Il faut redessiner le contenu de la fenetre */
						gestion_timer();
						break;

					case WM_REDRAW:
						/* Il faut redessiner le contenu de la fentre */
						if( buffer_aes[3] == handle_win )
						{
							Fcm_redraw_pop_up( pop_up );
						}
						else
						{
							Fcm_gestion_redraw_fenetre();
						}
						break;

					case WM_BOTTOM:
						/* Oh... pourquoi doit-en se cacher ?  */
						/* on se met a l'arriere plan alors :( */
						Fcm_gestion_bottom();
/*						if( buffer_aes[3]==handle_host_win )*/
						{
							reponse_pop_up=-1;
						}
	 					break;

					case WM_SHADED:
					case WM_UNSHADED:
						/* Le contenu de notre fenetre est cach‚ ou affich‚ */
						Fcm_gestion_shaded();
/*						if( buffer_aes[3]==handle_host_win )*/
						{
							reponse_pop_up=-1;
						}
						break;

					case WM_TOPPED:
						/* Une autre fenetre nous a pris la premiere place :(     */
						/* l'aes nous previent que ne sommes plus au premier plan */
						reponse_pop_up=-1;
						break;

					case WM_UNTOPPED:
						/* Une autre fenetre nous a pris la premiere place :(     */
						/* l'aes nous previent que ne sommes plus au premier plan */
						if( buffer_aes[3]==handle_win )
						{
							reponse_pop_up=-1;
						}
						break;

					case MN_SELECTED:
						/* l'utilisateur a cliqu‚ sur une entr‚e du Menu */
						Fcm_gestion_barre_menu();
						reponse_pop_up=-1;
						break;


					case WM_CLOSED:
						/* on ferme la fenetre */
						Fcm_gestion_Fermeture_Fenetre();
						reponse_pop_up=-1;
	 					break;

					case WM_MOVED:
						/* tremblement de terre, la fenetre bouge :) */
						Fcm_gestion_moved();
						reponse_pop_up=-1;
						flag_mouse_no_bouton=0;
						break;

					case WM_ICONIFY:
					case WM_ALLICONIFY:
						Fcm_gestion_iconify(controlkey);
						reponse_pop_up=-1;
	   					break;

					case WM_UNICONIFY:
						Fcm_gestion_uniconify();
						reponse_pop_up=-1;
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
				int16 objet;


				objet = objc_find( pop_up, 0, 4, souris.g_x, souris.g_y);

/*				{
					char texte[256];

					sprintf( texte, "*** objet find = %d   ", objet );
					v_gtext(vdihandle,4*8,9*16,texte);
				}*/

/*				if( objet == -1 )*/
				{
					reponse_pop_up = objet;
				}


			}


			/* ------------------------------------------------- */
			/*                      MU_TIMER                     */
			/* ================================================= */
			if( event & MU_TIMER )
			{
				gestion_timer();
			}


			/* ------------------------------------------------- */
			/* Gestion entree pop up                             */
			/* ================================================= */
			{
				int16 objet;


				objet = objc_find( pop_up, 0, 4, souris.g_x, souris.g_y);

/*				{
					char texte[256];

					sprintf( texte, "*** objet find = %d   ", objet );
					v_gtext(vdihandle,4*8,10*16,texte);
					sprintf( texte, "*** old_select_objet = %d   ", old_select_objet );
					v_gtext(vdihandle,4*8,11*16,texte);
				}*/


				if( objet != -1 )
				{
					if( old_select_objet==-1 )
					{
						old_select_objet = objet;
						Fcm_objet_change( pop_up, handle_win, objet, OS_SELECTED );
					}
					else if( old_select_objet != objet )
					{
						Fcm_objet_change( pop_up, handle_win, old_select_objet, 0 );
						old_select_objet = objet;
						Fcm_objet_change( pop_up, handle_win, objet, OS_SELECTED );
					}
				}
				else
				{
					if( old_select_objet!=-1 )
					{
						Fcm_objet_change( pop_up, handle_win, old_select_objet, 0 );
						old_select_objet = objet;
					}
				}

			}


		} while( /*nb_boucle < 2000 &&*/ reponse_pop_up==0 );
	}













	if( handle_win > 0 )
	{
		wind_close( handle_win );
		wind_delete( handle_win );
	}
	else
	{
/*		wind_update(END_MCTRL);*/
		wind_update(END_UPDATE);
		form_dial( 3,0,0,0,0,winx,winy,winw,winh);
	}





	if( flag_mouse_no_bouton )
	{
		Fcm_mouse_no_bouton();
	}




	return(reponse_pop_up);


}





































/* Fonction */
void Fcm_redraw_pop_up( OBJECT *pop_up )
{
	GRECT	r1,r2;

	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"- Fcm_redraw_pop_up"CRLF );
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

/*				objc_draw( pop_up,0,4, Fcm_screen.x_desktop, Fcm_screen.y_desktop, Fcm_screen.w_desktop, Fcm_screen.h_desktop);*/
				objc_draw( pop_up,0,4, r2.g_x, r2.g_y, r2.g_w, r2.g_h);

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



#endif   /* ___Fcm_gestion_pop_up___ */


