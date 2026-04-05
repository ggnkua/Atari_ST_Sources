/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 21/05/2020 * */
/* ***************************** */




/* Prototype */
void gestion_fenetre_nyancat( const int16 controlkey, const int16 touche, const int16 bouton );



/* Fonction */
void gestion_fenetre_nyancat( const int16 controlkey, const int16 touche, const int16 bouton )
{
	int16	commande = 0;

	UNUSED(controlkey);


	#ifdef LOG_FILE
	sprintf( buf_log, "#gestion_fenetre_nyancat(%d,%d,%d)"CRLF, controlkey,touche,bouton );
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
		fermer_fenetre_nyancat();
	}



	/* gestion mise en pause ou hors pause */
	if( bouton > 0 )
	{
		/*static uint32 old_entry_timer = 0;*/

	/*#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_get_timer()-old_entry_timer (%ld) "CRLF, Fcm_get_timer()-old_entry_timer );
	log_print(FALSE);
	#endif
*/
/*		if( (Fcm_get_timer()-old_entry_timer) < 200 )*/
		{
			/* tant que le bouton est enfonce, on boucle      */
			/* cela permet d'eviter les 'rebonds' sur le clic */
/*			old_entry_timer=Fcm_get_timer();
			return;*/
		}

		/* bouton relache, on switch en pause ou non */
		/*old_entry_timer=Fcm_get_timer();*/

		global_animation_pause= !global_animation_pause;

		if( global_animation_pause )
		{
			/* en pause */
			sprintf( win_info_texte, "Pause" );
			wind_set_str(h_win[W_NYANCAT],WF_INFO, win_info_texte);
			if( global_mute_sound == FALSE )
			{
				//Fcm_musique_pause( &global_musique );
				sound_pause();
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
				//Fcm_musique_play( &global_musique );
				sound_play();
			}
		}

		/* on attend le relachement du bouton pour éviter les rebonds */
		Fcm_mouse_no_bouton();
	}


	return;


}

