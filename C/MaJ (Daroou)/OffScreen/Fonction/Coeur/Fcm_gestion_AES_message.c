/* **[Fonction Commune]********** */
/* *                            * */
/* * Gestion des Messages AES   * */
/* * 11/04/2015 = 11/04/2015    * */
/* ****************************** */




#ifndef ___Fcm_gestion_aes_message___
#define ___Fcm_gestion_aes_message___





/* Prototype */
void Fcm_gestion_aes_message(void);


/* Fonction */
void Fcm_gestion_aes_message(void)
{

	int16	event,bouton,controlkey,touche,nb_click;
	int16   nb_boucle=0;



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF""CRLF"####  Fcm_gestion_aes_message()"CRLF""CRLF);
	log_print(FALSE);
	#endif


/*	{
		char texte[256];


		sprintf( texte, "entree Fcm_gestion_aes_message %ld   ", Fcm_get_timer() );
		v_gtext(vdihandle,4*8,8*16,texte);
	}*/

	do
	{
		event=evnt_multi( MU_MESAG|MU_TIMER,
						EVENT_BCLICK,3,0,
 						0,0,0,0,0,
						0,0,0,0,0,
						buffer_aes,40,
						&souris.g_x,&souris.g_y,&bouton,&controlkey,
						&touche,&nb_click);



		nb_boucle++;

/*		{
			char texte[256];


			sprintf( texte, "*** event=%d ($%x) - Buffer_aes[0]=%d($%x) %ld  ***", event, event, buffer_aes[0], buffer_aes[0], Fcm_get_timer() );
			v_gtext(vdihandle,4*8,4*16,texte);

			sprintf( texte, "Fcm_gestion_aes_message() *** nb_couble=%d    ", nb_boucle );
			v_gtext(vdihandle,4*8,5*16,texte);
		}*/



#ifdef LOG_FILE
sprintf( buf_log, "# Fcm_gestion_aes_message() event=%d - Buffer_aes[0]=%d(%x) [1]=%d [2]=%d [3]=%d [4]=%d [5]=%d [6]=%d [7]=%d"CRLF, event, buffer_aes[0],buffer_aes[0],buffer_aes[1],buffer_aes[2],buffer_aes[3],buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);
log_print(FALSE);
#endif


		/* ------------------------------------------------- */
		/*                      MU_MESAG                     */
		/* ================================================= */
		if( event & MU_MESAG )
		{
			nb_boucle=0;

			/* Que nous demande l'AES ? */
			switch( (uint16)buffer_aes[0] )
			{
/*				case 0x3039:*/
					/* Messahe interne appl_write() */
					/* Il faut redessiner le contenu de la fentre */
/*					gestion_timer();
					break;*/

				case WM_REDRAW:
					/* Il faut redessiner le contenu de la fentre */
					Fcm_gestion_redraw_fenetre();
					break;

				case WM_CLOSED:
					/* on ferme la fenetre */
					Fcm_gestion_Fermeture_Fenetre();
	 				break;

				case WM_MOVED:
					/* tremblement de terre, la fenetre bouge :) */
					Fcm_gestion_moved();
					break;

				case WM_BOTTOM:
					/* Oh... pourquoi doit-en se cacher ?  */
					/* on se met a l'arriere plan alors :( */
					Fcm_gestion_bottom();
	 				break;

				case WM_ONTOP:
					/* La fenetre du premier plan d'un autre appli disparait :) */
					/* et c'est nous qui prenons la place de premier :) */
					Fcm_gestion_ontop();
					break;

				case WM_UNTOPPED:
					/* Une autre fenetre nous a pris la premiere place :(     */
					/* l'aes nous previent que ne sommes plus au premier plan */
					Fcm_gestion_untopped();
					break;

				case WM_TOPPED:
					/* Bonne nouvelle... on repasse au premier plan :) */
					Fcm_gestion_topped();
					break;

				case WM_SHADED:
				case WM_UNSHADED:
					/* Le contenu de notre fenetre est cach‚ ou affich‚ */
					Fcm_gestion_shaded();
					break;

				case WM_FULLED:
/*					gestion_fulled();*/
					break;

				case WM_SIZED:
					/* on veut modifier les dimensions de notre fenˆtre */
/*					gestion_sized();*/
					break;	/* case WM_SIZED */


/*				case WM_ARROWED:
				case WM_HSLID:
				case WM_VSLID:*/
					/* Gestion des actions sur les ‚l‚ment de fenˆtre */
					/* gestion_slider_pattern();
					break;*/

				case WM_ICONIFY:
				case WM_ALLICONIFY:
					Fcm_gestion_iconify(controlkey);
	   				break;

				case WM_UNICONIFY:
					Fcm_gestion_uniconify();
	   				break;

/*				case AP_TERM:*/
					/* on doit mettre fin a notre application */
					/* alors on ferme tout et on quitte :(    */
/*					#ifdef LOG_FILE
					sprintf( buf_log, "# reception message AP_TERM"CRLF);
					log_print( FALSE );
					#endif
					return;
		   			break;*/


/*				case MN_SELECTED:*/
					/* l'utilisateur a cliqu‚ sur une entr‚e du Menu */
/*					Fcm_gestion_barre_menu();
					break;*/


/*				case LDG_QUIT:
				case LDG_LOST_LIB:
					Fcm_gestion_perte_ldg();
					break;*/

/*				case VA_START:
					Fcm_gestion_va_start();
					break;*/

/*				case AP_DRAGDROP:
					gestion_dragdrop();
					break;*/


/*				case AV_FILEINFO:
					sprintf(texte," Message AES %x ", AV_FILEINFO );
					v_gtext(vdihandle,4*8,1*16,texte);

					break;*/


				case 0xbaba:
					/* bubble gem */
					break;


				default:
					#ifdef LOG_FILE
					sprintf(texte,"Fcm_gestion_aes_message: Message AES inconnu: event=%d BUF[0]=%x BUF[1]=%x BUF[2]=%x BUF[3]=%x ",event, buffer_aes[0],buffer_aes[1],buffer_aes[2],buffer_aes[3]);
					v_gtext(vdihandle,4*8,3*16,texte);

					sprintf( buf_log, texte);
					log_print(FALSE);

					sprintf(texte,"BUF[4]=%x BUF[5]=%x BUF[6]=%x BUF[7]=%x "CRLF,buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);
					v_gtext(vdihandle,4*8,4*16,texte);
					sprintf( buf_log, texte);
					log_print(FALSE);
					#endif

					break;
			}

		}


	} while( nb_boucle < 5 );


	return;


}


#endif /* ___Fcm_gestion_aes_message___ */

