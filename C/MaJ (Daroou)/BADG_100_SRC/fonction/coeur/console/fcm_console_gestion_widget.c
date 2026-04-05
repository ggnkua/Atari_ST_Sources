/**[Console]********************/
/*                             */
/* 03/01/2024 MaJ 03/01/2024   */
/* *****************************/

void Fcm_console_gestion_widget( void )
{
	int16 old_ligne_start;
	int16 old_lettre_start;



	old_ligne_start  = Fcm_struct_console_global.ligne_start;
	old_lettre_start = Fcm_struct_console_global.lettre_start;


	if( buffer_aes[0] == WM_ARROWED )
	{
		switch( buffer_aes[4] )
		{
			case WA_UPPAGE: /* page up */
				Fcm_struct_console_global.ligne_start = MAX( 0 , (Fcm_struct_console_global.ligne_start - Fcm_struct_console_global.nbligne_visible) );
				break;
			case WA_DNPAGE: /* page down */
				Fcm_struct_console_global.ligne_start = Fcm_struct_console_global.ligne_start + Fcm_struct_console_global.nbligne_visible;
				Fcm_struct_console_global.ligne_start = MIN( (FCM_CONSOLE_MAXLIGNE-Fcm_struct_console_global.nbligne_visible) , Fcm_struct_console_global.ligne_start );
				break;
			case WA_UPLINE: /* row up */
				Fcm_struct_console_global.ligne_start = MAX( 0 , (Fcm_struct_console_global.ligne_start - 1) );
				break;
			case WA_DNLINE: /* row down */
				Fcm_struct_console_global.ligne_start = Fcm_struct_console_global.ligne_start + 1;
				Fcm_struct_console_global.ligne_start = MIN( (FCM_CONSOLE_MAXLIGNE-Fcm_struct_console_global.nbligne_visible) , Fcm_struct_console_global.ligne_start );
				break;



			case WA_LFPAGE: /* page left */
				Fcm_struct_console_global.lettre_start = MAX( 0 , (Fcm_struct_console_global.lettre_start - Fcm_struct_console_global.nblettre_visible) );
				break;
			case WA_RTPAGE: /* page right */
				Fcm_struct_console_global.lettre_start = Fcm_struct_console_global.lettre_start + Fcm_struct_console_global.nblettre_visible;
				Fcm_struct_console_global.lettre_start = MIN( (FCM_CONSOLE_TEXTE_MAXLEN-Fcm_struct_console_global.nblettre_visible) , Fcm_struct_console_global.lettre_start );
				break;
			case WA_LFLINE: /* column left */
				Fcm_struct_console_global.lettre_start = MAX( 0 , (Fcm_struct_console_global.lettre_start - 1) );
				break;
			case WA_RTLINE: /* column right */
				Fcm_struct_console_global.lettre_start = Fcm_struct_console_global.lettre_start + 1;
				Fcm_struct_console_global.lettre_start = MIN( (FCM_CONSOLE_TEXTE_MAXLEN-Fcm_struct_console_global.nblettre_visible) , Fcm_struct_console_global.lettre_start );
				break;
			case WA_WHEEL: /* mouse wheel */
				break;
		}
	}



	/* Slider barre Verticale */
	if( buffer_aes[0] == WM_VSLID )
	{
		Fcm_struct_console_global.ligne_start = ( buffer_aes[4] * (FCM_CONSOLE_MAXLIGNE-Fcm_struct_console_global.nbligne_visible) ) / 1000;
		Fcm_struct_console_global.ligne_start = MAX( 0 , Fcm_struct_console_global.ligne_start );
		Fcm_struct_console_global.ligne_start = MIN( (FCM_CONSOLE_MAXLIGNE-Fcm_struct_console_global.nbligne_visible) , Fcm_struct_console_global.ligne_start );
	}



	/* Slider barre Horizontale */
	if( buffer_aes[0] == WM_HSLID )
	{
		Fcm_struct_console_global.lettre_start = ( buffer_aes[4] * (FCM_CONSOLE_TEXTE_MAXLEN-Fcm_struct_console_global.nblettre_visible) ) / 1000;
		Fcm_struct_console_global.lettre_start = MAX( 0 , Fcm_struct_console_global.lettre_start );
		Fcm_struct_console_global.lettre_start = MIN( (FCM_CONSOLE_TEXTE_MAXLEN-Fcm_struct_console_global.nblettre_visible) , Fcm_struct_console_global.lettre_start );
	}




	if( old_ligne_start != Fcm_struct_console_global.ligne_start || old_lettre_start != Fcm_struct_console_global.lettre_start)
	{
		/* mise a jour des slider H et V */
		Fcm_console_set_slider();


		buffer_aes[0]=WM_REDRAW;            /* message type */
		buffer_aes[1]=ap_id;                /* application id */
		buffer_aes[2]=0;                    /* length of the message, 0 si message standard */
		buffer_aes[3]=h_win[W_CONSOLE];     /* handle de la fenetre pour WM_REDRAW */
		buffer_aes[4]=Fcm_screen.x_desktop; /* pas besoin de determiner la zone de la console */
		buffer_aes[5]=Fcm_screen.y_desktop; /* la fonction redraw va la rechercher            */
		buffer_aes[6]=Fcm_screen.w_desktop;
		buffer_aes[7]=Fcm_screen.h_desktop;

		appl_write( ap_id, 16, buffer_aes);
	}


	return;


}

