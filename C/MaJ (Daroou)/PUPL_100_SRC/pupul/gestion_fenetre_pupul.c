/* **[Pupul]******************** */
/* *                           * */
/* * 20/02/2015 MaJ 09/11/2023 * */
/* ***************************** */

#include  "../fonction/ldg/mod.h"

#include  "set_mod_play.c"


/* Prototype */
void gestion_fenetre_pupul( const int16 controlkey, const int16 touche, const int16 bouton );



/* Fonction */
void gestion_fenetre_pupul( const int16 controlkey, const int16 touche, const int16 bouton )
{
	int16	commande = 0;

	UNUSED(controlkey);


	#ifdef LOG_FILE
	sprintf( buf_log, "#gestion_fenetre_pupul(%d,%d,%d)"CRLF, controlkey,touche,bouton );
	log_print(FALSE);
	#endif


	if( touche )
	{
		switch( touche & 0xff00)
		{
			case 0x0100:	/* ESCape */
				commande = 1;
				break;
		}
	}



	/* ------------------------- */
	/* Touche ESCape             */
	/* ------------------------- */
	if( commande == 1 )
	{
		fermer_fenetre_pupul();
	}



	/* gestion mise en pause ou hors pause */
	if( bouton > 0 )
	{
		global_animation_pause= !global_animation_pause;

		if( global_animation_pause )
		{
			/* en pause */
			sprintf( win_info_texte, "Pause" );
			wind_set_str(h_win[W_PUPUL],WF_INFO, win_info_texte);
			if( global_mute_sound == FALSE )
			{
				/* Si le son n'est pas désactivé (checkbox -> dialogue Options), on met en pause */
				mod_stop();
			}
		}
		else
		{
			/* pause terminee */
			/* On s'envoie un message pour récupérer le flux AES instantanément */
			/* sinon il y a attente d'1 seconde, evnt_multi(task timer) = 200   */
			appl_write( ap_id, 16, tube_gem);
			
			
			if( global_mute_sound == FALSE ) 
			{
				/* Si le son n'est pas désactivé (checkbox -> dialogue Options), on relance la musique */
				set_mod_play();
			}
		}

		/* on attend le relachement du bouton pour éviter les rebonds */
		Fcm_mouse_no_bouton();
	}



/*

  sous magic, les clics sont gérés sur une fenetre iconifié, j'avais donc
  codé le déplacement de la zone visible avec clic gauche (glisser) et recentrage
  avec clic droit....

	if( win_iconified[W_PUPUL]==TRUE )
	{
		if( bouton==1 )
		{
			static uint32 old_entry_timer=0;
			static uint16 old_pos_x=0;
			static uint16 old_pos_y=0;
			        int16 mx, my, dummy;
			        int16 winw,winh;


			graf_mkstate(&mx, &my, &dummy, &dummy);

			if( (Fcm_get_timer()-old_entry_timer) < 20 )
			{

				wind_get(h_win[W_PUPUL],WF_WORKXYWH,&dummy,&dummy,&winw,&winh);


				view_iconified_x=view_iconified_x - (mx - old_pos_x);
				view_iconified_y=view_iconified_y - (my - old_pos_y);

				view_iconified_x=MAX(0, view_iconified_x);
				view_iconified_y=MAX(0, view_iconified_y);

				view_iconified_x=MIN( (SCREEN_WIDTH -winw), view_iconified_x);
				view_iconified_y=MIN( (SCREEN_HEIGHT-winh), view_iconified_y);


			}

			old_entry_timer=Fcm_get_timer();
			old_pos_x=mx;
			old_pos_y=my;
		}


		if( bouton==2 )
		{
			view_iconified_x=view_iconified_cx;
			view_iconified_y=view_iconified_cy;
		}
	}
*/


	return;

}

