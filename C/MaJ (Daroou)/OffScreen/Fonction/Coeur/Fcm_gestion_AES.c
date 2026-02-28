/* **[Fonction Commune]********** */
/* *                            * */
/* * Gestion des evenements AES * */
/* * 27/11/2003 = 06/04/2013    * */
/* ****************************** */


#include <AV.H>
#include <LDG.H>
#include "Fcm_gestion_Fermeture_Fenetre.c"
#include "Fcm_gestion_souris.c"
#include "Fcm_gestion_clavier.c"
#include "Fcm_gestion_barre_menu.c"
#include "Fcm_gestion_va_start.c"
#include "Fcm_gestion_perte_ldg.c"
#include "Fcm_gestion_uniconify.c"
#include "Fcm_gestion_iconify.c"
#include "Fcm_gestion_shaded.c"
#include "Fcm_gestion_topped.c"
#include "Fcm_gestion_untopped.c"
#include "Fcm_gestion_ontop.c"
#include "Fcm_gestion_bottom.c"
#include "Fcm_gestion_moved.c"
#include "Fcm_gestion_redraw_fenetre.c"




/* Prototype */
void Fcm_gestion_aes(void);




/* Fonction */
void Fcm_gestion_aes(void)
{
/*
 *
 * extern	uint16	buffer_aes[16];
 * extern	GRECT	souris;
 *
 */
	int16	event,bouton,controlkey,touche,nb_click;





	#ifdef LOG_FILE
	sprintf( buf_log, CRLF""CRLF"####  Fcm_gestion_aes() Boucle principale"CRLF""CRLF);
	log_print(FALSE);
	#endif


	while(1)
	{

		event=evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG|MU_TIMER,
						EVENT_BCLICK,3,0,
 						0,0,0,0,0,
						0,0,0,0,0,
						buffer_aes,TASK_TIMER/*Fcm_timer_eventmulti*/,
						&souris.g_x,&souris.g_y,&bouton,&controlkey,
						&touche,&nb_click);



		/* ------------------------------------------------- */
		/*                      MU_MESAG                     */
		/* ================================================= */
		if( event & MU_MESAG )
		{
			/* Que nous demande l'AES ? */
			switch( (uint16)buffer_aes[0] )
			{
				case 0x3039:  /* auto appl_write()  */
					/* Il faut redessiner le contenu de la fentre */
					gestion_timer();
					break;

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

				case AP_TERM:
					/* on doit mettre fin a notre application */
					/* alors on ferme tout et on quitte :(    */
					#ifdef LOG_FILE
					sprintf( buf_log, "# reception message AP_TERM"CRLF);
					log_print( FALSE );
					#endif
					return;
		   			break;


				case MN_SELECTED:
					/* l'utilisateur a cliqu‚ sur une entr‚e du Menu */
					Fcm_gestion_barre_menu();
					break;


				case LDG_QUIT:
				case LDG_LOST_LIB:
					Fcm_gestion_perte_ldg();
					break;

				case VA_START:
					Fcm_gestion_va_start();
					break;

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
/*					sprintf(texte," Message AES inconnu : [event: %d | buffer_aes[0]: %d] ",event,buffer_aes[0]);
					v_gtext(vdihandle,4*8,2*16,texte);*/

					sprintf(texte,"Fcm_gest_AES: Message AES inconnu: event=0x%x BUF[0]=0x%x BUF[1]=0x%x BUF[2]=0x%x BUF[3]=0x%x ",event, buffer_aes[0],buffer_aes[1],buffer_aes[2],buffer_aes[3]);
					v_gtext(vdihandle,4*8,3*16,texte);

					sprintf( buf_log, texte);
					log_print(FALSE);
					sprintf(texte,"BUF[4]=0x%x BUF[5]=0x%x BUF[6]=0x%x BUF[7]=0x%x "CRLF,buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);
					v_gtext(vdihandle,4*8,4*16,texte);
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
			Fcm_gestion_souris( controlkey, bouton );
		}



		/* ------------------------------------------------- */
		/*                      MU_KEYBD                     */
		/* ================================================= */
		if( event & MU_KEYBD)
		{
			Fcm_gestion_clavier( controlkey, touche );
		}


		/* ------------------------------------------------- */
		/*                      MU_TIMER                     */
		/* ================================================= */
		if( event & MU_TIMER )
		{
			gestion_timer();
		}


	} /* =>    END while(1)    <= */


}

