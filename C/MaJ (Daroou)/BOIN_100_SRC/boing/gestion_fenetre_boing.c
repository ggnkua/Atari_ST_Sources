/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 28/05/2020 * */
/* ***************************** */




/* Fonction */
void gestion_fenetre_boing( const int16 controlkey, const int16 touche, const int16 bouton )
{
	int16	commande = 0;

	UNUSED(controlkey);



	if( touche )
	{
		switch( touche & 0xff00)
		{
			case 0x0100:	/* ESCape */
				commande=1;
				break;
		}
	}





	/* ------------------------- */
	/* Touche ESCape             */
	/* ------------------------- */
	if( commande == 1 )
	{
		fermer_fenetre_boing();
	}




	if( bouton > 0 )
	{
		static uint32 old_entry_timer=0;


		if( (Fcm_get_timer()-old_entry_timer) < 20 )
		{
			old_entry_timer = Fcm_get_timer();
			return;
		}

		old_entry_timer = Fcm_get_timer();

		global_animation_pause = !global_animation_pause;

		if( global_animation_pause )
		{
			/* en pause */
			sprintf( win_info_texte, "Pause" );
			wind_set_str(h_win[W_BOING],WF_INFO, win_info_texte);
		}
		else
		{
			/* On s'envoie un message pour récupérer le flux AES instantanément */
			/* sinon il y a attente d'1 seconde, evnt_multi(task timer) = 200   */
			appl_write( ap_id, 16, tube_gem);
		}
	}



/*
	if( win_iconified[W_BOING]==TRUE )
	{
		if( bouton==1 )
		{
			static uint32 old_entry_timer=0;
			static int16 old_pos_x=0;
			static int16 old_pos_y=0;
			        int16 mx, my, dummy;
			        int16 winw,winh;


			graf_mkstate(&mx, &my, &dummy, &dummy);

			if( (Fcm_get_timer()-old_entry_timer) < 20 )
			{



				wind_get(h_win[W_BOING],WF_WORKXYWH,&dummy,&dummy,&winw,&winh);


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
	}*/



	return;

}

