/* **[Pupul]******************** */
/* *                           * */
/* * 20/08/2014 MaJ 01/04/2026 * */
/* ***************************** */

#include "affiche_screen.c"





/* Fonction */
void gestion_timer( void )
{

	static uint32 old_timer_fps    = 0;
	static uint32 timer_next_frame = 0;
	static int16  frame_cpt        = 0;
	       uint32 timer;



	if( global_animation_pause )
	{
		return;
	}


	/* ----------------------------------------------- */
	/* Si la music  est active, on alimente la MOD.LDG */
	/* ----------------------------------------------- */
	if( global_mute_sound==FALSE && global_mod_ldg_update==MODLDG_UPDATE_POLLING )
	{
		#ifdef LOG_FILE
		uint32 xxxtimer;
		xxxtimer = Fcm_get_timer();
		#endif

		/* on alimente le buffer MOD */
		mod_checkbuf();


		#ifdef LOG_FILE
		xxxtimer = Fcm_get_timer()-xxxtimer;
		sprintf(buf_log,"mod_checkbuf() time => %ld/200 sec ", xxxtimer);
		log_print(FALSE);
		#endif
	}




	timer=Fcm_get_timer();


	/* si l'option MAX FPS n'est pas coché, on limite le fps */
	if( global_max_fps == FALSE )
	{
		/* doit-on construire une frame ? */
		if( (timer < timer_next_frame) )
		{
			/* trop tot, on revient plus tard */
			//appl_write( ap_id, 16, tube_gem);

			//return;

			do
			{
				timer = Fcm_get_timer();

			} while( timer < timer_next_frame );
		}

		/* on cale le timer pour la prochaine frame */
		timer_next_frame = timer_next_frame + FPS_TIMER_NEXT_FRAME;
	}





	{
		uint32 timer_one_frame = Fcm_get_timer();

		build_screen();     /* construction de la frame dans le framebuffer */
		affiche_screen();   /* affichage de la frame a l'ecran */
		frame_cpt++;        /* on compte le nombre de framme affichée */

		global_charge_build_screen = global_charge_build_screen + (Fcm_get_timer() - timer_one_frame);
	}



	/* Si une seconde s'est ‚coul‚, on affiche les infos */
	if( (timer - old_timer_fps) >= 200 )
	{
		/* temps mis pour réaliser un cycle (en milliseconde) temps moyen */
		global_charge_build_frame = (global_charge_build_screen * 5) / (uint32)frame_cpt;

		/* Calcul de la charge */
		if( frame_cpt < FPS )
		{
			global_charge_build_screen = (FPS * 100) / (uint32)frame_cpt;
		}
		else
		{
			global_charge_build_screen = global_charge_build_screen / 2;  /* ( (global_charge_build_screen*5) / 1000 * 100 ) */
		}

//		global_charge_build_screen = MIN(global_charge_build_screen, 999);


		/* affichage des infos en fenêtre  */
		/* ------------------------------- */
		sprintf( win_info_texte, "%d/%d Fps  %ld%%  %ld ms/frame  %dbits", frame_cpt, FPS, global_charge_build_screen, global_charge_build_frame, Fcm_screen.nb_plan );
		wind_set_str(h_win[W_PUPUL],WF_INFO, win_info_texte);

		frame_cpt       = 0;
		old_timer_fps   = timer;
		timer_next_frame = timer + FPS_TIMER_NEXT_FRAME;
//		old_timer_frame = timer;
		global_charge_build_screen = 0;

	}


	/* On s'envoie un message pour récupérer le flux AES instantanément */
	appl_write( ap_id, 16, tube_gem);


	return;


}
