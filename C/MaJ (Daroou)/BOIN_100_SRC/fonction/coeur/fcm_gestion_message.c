/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 27/02/2024 MaJ 27/02/2024 * */
/* ***************************** */



void Fcm_gestion_message( void )
{
	static int16 Fcm_gestion_message_compteur = 0;


	/* pour compter et voir si ré-entrance */
	Fcm_gestion_message_compteur++;
FCM_LOG_PRINT1("* [%d] Fcm_gestion_message", Fcm_gestion_message_compteur);

FCM_LOG_PRINT1( "@ MU_MESAG (%d)", buffer_aes[0] );


	/* Que nous demande l'AES ? */
	switch( (uint16)buffer_aes[0] )
	{
		case 0x3039:
			/* Message interne 0x3039 (12345) - auto appl_write() */
			if( Fcm_init_appli_terminer == TRUE )  gestion_timer();
			break;

		case WM_REDRAW:
			/* Il faut redessiner le contenu de la fentre */
			Fcm_gestion_redraw_fenetre();
			break;

		case WM_CLOSED:
			/* on ferme la fenetre */
			Fcm_gestion_fermeture_fenetre();
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
			/* sera implemente le jour ou se sera utilise ;) */
/*					Fcm_gestion_fulled();*/
			/*break;*/

		case WM_SIZED:
			/* on veut modifier les dimensions de notre fenˆtre */
			Fcm_gestion_sized();
			break;


		case WM_ARROWED:
		case WM_HSLID:
		case WM_VSLID:
			/* Gestion des actions sur les ‚l‚ment de fenˆtre */
			/*Fcm_gestion_sliders();*/
			Fcm_gestion_widgets();
			break;

		case WM_ICONIFY:
		case WM_ALLICONIFY:
			Fcm_gestion_iconify();
			break;

		case WM_UNICONIFY:
			Fcm_gestion_uniconify();
			break;

		case AP_TERM:
			/* on doit mettre fin a notre application */
			FCM_LOG_PRINT( "# reception message AP_TERM");
			Fcm_quitter_application = TRUE;
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

		/* Tous les messages non géré pour le moment */
		case CH_EXIT:
		case SC_CHANGED:
		case 0xbaba:
			/* bubble gem */
			break;


		default:
			FCM_CONSOLE_DEBUG5("MU_MESAG inconnu: [0]=%d(0x%x) [1]=%d [2]=%d [3]=%d", buffer_aes[0], buffer_aes[0],buffer_aes[1],buffer_aes[2],buffer_aes[3]);
			FCM_CONSOLE_DEBUG4("[4]=%d [5]=%d [6]=%d [7]=%d ", buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);
			break;
	}


	Fcm_gestion_message_compteur--;


	return;


}

