/* **[Fonction Commune]********** */
/* *                            * */
/* * 28/11/2003 MaJ 14/08/2017  * */
/* ****************************** */


#include "Fcm_Set_Win_Position.c"
#include "Fcm_Form_Alerte.c"

#include "Fcm_rescale_def.h"


/* Prototype */
void Fcm_rescale_fenetre_info(void);


/* Fonction */
void Fcm_ouvre_fenetre_info( void )
{
	OBJECT	*adr_formulaire;
	int16	x,y,largeur,hauteur;
	int16	winx,winy,winw,winh;
	int16	flag_win;


	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"* Fcm_ouvre_fenetre_info() : hwin(%d)=", W_INFO_PRG );
	log_print(FALSE);
	#endif


	if( h_win[W_INFO_PRG]>0 )
	{
		buffer_aes[0]=WM_TOPPED;
		buffer_aes[1]=ap_id;
		buffer_aes[2]=0;
		buffer_aes[3]=h_win[W_INFO_PRG];
		appl_write( ap_id, 16, &buffer_aes );
	}
	else
	{
		Fcm_rescale_fenetre_info();
		
		flag_win=NAME|CLOSER|MOVER|BACKDROP|SMALLER;

		/* on recherche l'adresse du Formulaire */
		rsrc_gaddr( R_TREE, DL_INFO_PRG, &adr_formulaire );

		/* on demande … l'AES de le centrer sur le DeskTop */
		form_center( adr_formulaire, &winx, &winy, &winw, &winh );


		/* Calcul des dimensions de la fenetre en fonction */
		/* de la taille du formulaire                      */
		x       = winx;
		y       = winy;
		largeur = winw;
		hauteur = winh;

		/* on demande … l'AES de nous calculer la taille de la fenˆtre */
		/* en fonction de la zone de travail (taille formulaire)       */
		wind_calc( 0, flag_win,	x, y, largeur, hauteur, &winx, &winy, &winw, &winh );


		/* On applique les coordonn‚es sauvegard‚es dans le fichier de config si */
		/* pr‚sente, sinon on laisse les coordonn‚es centr‚es                    */
		Fcm_set_win_position( W_INFO_PRG, &winx, &winy );


		/* On demande … l'AES de cr‚er notre fenˆtre */
		h_win[W_INFO_PRG]=wind_create( flag_win, winx, winy, winw, winh);


		if( h_win[W_INFO_PRG] > 0 )
		{
			/* on m‚morise la position de la fenˆtre */
			win_posxywh[W_INFO_PRG][0]=winx;
			win_posxywh[W_INFO_PRG][1]=winy;
			win_posxywh[W_INFO_PRG][2]=winw;
			win_posxywh[W_INFO_PRG][3]=winh;

			#ifdef LOG_FILE
			sprintf( buf_log, "%2d ; x=%4d, y=%4d, w=%3d, h=%3d"CRLF, h_win[W_INFO_PRG], winx, winy, winw, winh );
			log_print(FALSE);
			#endif


			/* adresse du dialogue des titres de fenetre */
			rsrc_gaddr( R_TREE, DL_TITRE_FENETRE, &adr_formulaire );

			/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un nom ... */
			wind_set_str(h_win[W_INFO_PRG],WF_NAME,(adr_formulaire+TITRE_INFO)->ob_spec.free_string);
			/* ... et on demande … l'AES de l'ouvrir */
			wind_open(h_win[W_INFO_PRG],winx,winy,winw,winh);

		}
		else
		{
			int16 dummy;


			#ifdef LOG_FILE
			sprintf( buf_log, "‚chec"CRLF);
			log_print(FALSE);
			#endif

			h_win[W_INFO_PRG]=FCM_NO_OPEN_WINDOW;
/*			Fcm_form_alerte( 0, ALT_NO_WINDOWS );*/
			Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NO_WINDOWS, &dummy );

		}
	}

	return;

}








/* Fonction */
void Fcm_rescale_fenetre_info( void )
{
	OBJECT	*dial;
	int16    form_w;
	/*int16    gr_hwbox, gr_hhbox;*/
	int16	 gr_hwcar,gr_hhcar;
	int16	img_x;


	#define IMG_RENAISSANCE_WIDTH (144)
	#define IMG_RENAISSANCE_HEIGHT (99)

	/* Marre que le formulaire s'affiche mal d'une resolution a l'autre */
	/* tous les objets et le fond sont repositionner                    */

	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_rescale_fenetre_info()"CRLF );
	log_print(FALSE);
	#endif

	/* espace occuper par les caracteres de la fonte systeme */
	{
		int16 dummy;
		graf_handle( &gr_hwcar, &gr_hhcar, &dummy, &dummy );
		/*graf_handle( &gr_hwcar, &gr_hhcar, &gr_hwbox, &gr_hhbox );*/
/*		{
			char texte_surface[80];
			sprintf( texte_surface, "hwcar=%d hhcar=%d hwbox=%d hhbox=%d", gr_hwcar, gr_hhcar, gr_hwbox, gr_hhbox );
			v_gtext( vdihandle, 1*16, 2*16, texte_surface);
		}*/
	}

	/* on cherche l'adresse du formulaire et l'objet sous la souris */
	rsrc_gaddr( R_TREE, DL_INFO_PRG, &dial );

	img_x = 0;

	/* cadre titre */
	{
		dial[INFO_CDR_INVISIB].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[INFO_CDR_INVISIB].ob_y = FCM_RESCALE_MARGE_HAUT/2;

		dial[INFO_CDR_OMBRE].ob_x = 4;
		dial[INFO_CDR_OMBRE].ob_y = 4;

		dial[INFO_CDR_TITRE].ob_x = 0;
		dial[INFO_CDR_TITRE].ob_y = 0;

		dial[INFO_CDR_TITRE].ob_height = dial[INFO_CDR_TEXTE].ob_height * 2;
		dial[INFO_CDR_OMBRE].ob_height = dial[INFO_CDR_TITRE].ob_height;

		dial[INFO_CDR_TEXTE].ob_y = dial[INFO_CDR_TEXTE].ob_height / 2;

/*	{
			dial[INFO_CDR_TITRE].ob_spec.obspec.interiorcol = 5;
			char texte_surface[80];
			sprintf( texte_surface, "dial[INFO_CDR_TITRE].ob_spec.obspec.interiorcol=%d", dial[INFO_CDR_TITRE].ob_spec.obspec.interiorcol );
			v_gtext( vdihandle, 1*16, 2*16, texte_surface);
	}*/

		if( Fcm_screen.nb_plan<8 )
		{
			dial[INFO_CDR_TITRE].ob_spec.obspec.interiorcol = 0;
			dial[INFO_CDR_TITRE].ob_spec.obspec.framecol = 1;
			dial[INFO_CDR_TEXTE].ob_spec.tedinfo->te_color = dial[INFO_CDR_TEXTE].ob_spec.tedinfo->te_color & 0xF0FF; /* efface couleur texte */
			dial[INFO_CDR_TEXTE].ob_spec.tedinfo->te_color = dial[INFO_CDR_TEXTE].ob_spec.tedinfo->te_color | 0x0100; /* valeur 1 texte (noir) */
		}
		dial[INFO_CDR_INVISIB].ob_height = dial[INFO_CDR_OMBRE].ob_y + dial[INFO_CDR_OMBRE].ob_height;
		dial[INFO_CDR_INVISIB].ob_width = dial[INFO_CDR_OMBRE].ob_x + dial[INFO_CDR_OMBRE].ob_width;
	}

	/* image position verticale */
	{
		dial[INFO_IMG_RENAIS].ob_y = dial[INFO_CDR_INVISIB].ob_y;
	}

	/* license */
	{
		dial[INFO_TXT_LICENCE].ob_x = FCM_RESCALE_MARGE_GAUCHE*2;
		dial[INFO_TXT_LICENCE].ob_y = dial[INFO_CDR_INVISIB].ob_y + dial[INFO_CDR_INVISIB].ob_height + FCM_RESCALE_INTERLIGNE;
		img_x = MAX( img_x, dial[INFO_TXT_LICENCE].ob_x + dial[INFO_TXT_LICENCE].ob_width);
	}

	/* version */
	{
		dial[INFO_TXT_VERSION].ob_x = FCM_RESCALE_MARGE_GAUCHE*2;
		dial[INFO_TXT_VERSION].ob_y = dial[INFO_TXT_LICENCE].ob_y + dial[INFO_TXT_LICENCE].ob_height;

		dial[INFO_PRG_VERSION].ob_x = dial[INFO_TXT_VERSION].ob_x +dial[INFO_TXT_VERSION].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_PRG_VERSION].ob_y = dial[INFO_TXT_VERSION].ob_y;
		img_x = MAX( img_x, dial[INFO_PRG_VERSION].ob_x + dial[INFO_PRG_VERSION].ob_width);
	}

	/* date programme */
	{
		dial[INFO_PRG_DATE].ob_x = FCM_RESCALE_MARGE_GAUCHE*2;
		dial[INFO_PRG_DATE].ob_y = dial[INFO_TXT_VERSION].ob_y + dial[INFO_TXT_VERSION].ob_height;
		img_x = MAX( img_x, dial[INFO_PRG_DATE].ob_x + dial[INFO_PRG_DATE].ob_width);
	}

	if( dial[INFO_CDR_TEXTE].ob_width < (img_x-dial[INFO_TXT_LICENCE].ob_x)  )
	{
		/* on reduit la largeur du cadre */
		dial[INFO_CDR_TITRE].ob_width = img_x-dial[INFO_TXT_LICENCE].ob_x;
		dial[INFO_CDR_OMBRE].ob_width = dial[INFO_CDR_TITRE].ob_width;
		dial[INFO_CDR_TEXTE].ob_x = (dial[INFO_CDR_TITRE].ob_width - dial[INFO_CDR_TEXTE].ob_width) / 2;
	}

	/* image position horizontal */
	{
		dial[INFO_IMG_RENAIS].ob_x = img_x;
		form_w = dial[INFO_IMG_RENAIS].ob_x + IMG_RENAISSANCE_WIDTH;
	}

	/* debug message */
	{
		dial[INFO_DBUG].ob_x = FCM_RESCALE_MARGE_GAUCHE*2;
		dial[INFO_DBUG].ob_y = dial[INFO_IMG_RENAIS].ob_y + IMG_RENAISSANCE_HEIGHT /*dial[INFO_IMG_RENAIS].ob_height*/;
	}

	/* compiler le */
	{
		dial[INFO_COMPIL_TXT].ob_x = FCM_RESCALE_MARGE_GAUCHE/2;
		dial[INFO_COMPIL_TXT].ob_y = dial[INFO_DBUG].ob_y + dial[INFO_DBUG].ob_height;

		dial[INFO_COMPIL_DATE].ob_x = dial[INFO_COMPIL_TXT].ob_x +dial[INFO_COMPIL_TXT].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_COMPIL_DATE].ob_y = dial[INFO_COMPIL_TXT].ob_y;
	}

	/* gcc version */
	{
		dial[INFO_GCC_VER_TXT].ob_x = dial[INFO_COMPIL_DATE].ob_x +dial[INFO_COMPIL_DATE].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_GCC_VER_TXT].ob_y = dial[INFO_COMPIL_TXT].ob_y;

		dial[INFO_GCC_VER].ob_x = dial[INFO_GCC_VER_TXT].ob_x +dial[INFO_GCC_VER_TXT].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_GCC_VER].ob_y = dial[INFO_COMPIL_TXT].ob_y;
		form_w = MAX( form_w, dial[INFO_GCC_VER].ob_x +dial[INFO_GCC_VER].ob_width);
	}

	/* coeur , cible, gemlib */
	{
		dial[INFO_COEUR_TXT].ob_x = dial[INFO_COMPIL_TXT].ob_x;
		dial[INFO_COEUR_TXT].ob_y = dial[INFO_COMPIL_TXT].ob_y + dial[INFO_COMPIL_TXT].ob_height + 2;

		dial[INFO_COEUR_VER].ob_x = dial[INFO_COEUR_TXT].ob_x +dial[INFO_COEUR_TXT].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_COEUR_VER].ob_y = dial[INFO_COEUR_TXT].ob_y;

		dial[INFO_CPU_TXT].ob_x = dial[INFO_COEUR_VER].ob_x +dial[INFO_COEUR_VER].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_CPU_TXT].ob_y = dial[INFO_COEUR_TXT].ob_y;

		dial[INFO_CPU_TARGET].ob_x = dial[INFO_CPU_TXT].ob_x +dial[INFO_CPU_TXT].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_CPU_TARGET].ob_y = dial[INFO_COEUR_TXT].ob_y;

		dial[INFO_GEMLIB_TXT].ob_x = dial[INFO_CPU_TARGET].ob_x +dial[INFO_CPU_TARGET].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_GEMLIB_TXT].ob_y = dial[INFO_COEUR_TXT].ob_y;

		dial[INFO_GEMLIB_VER].ob_x = dial[INFO_GEMLIB_TXT].ob_x +dial[INFO_GEMLIB_TXT].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_GEMLIB_VER].ob_y = dial[INFO_COEUR_TXT].ob_y;
	}

	/* dimension du fond */
	dial[0].ob_width  = form_w + FCM_RESCALE_MARGE_DROITE;
	dial[0].ob_height = dial[INFO_COEUR_TXT].ob_y + dial[INFO_COEUR_TXT].ob_height + (FCM_RESCALE_MARGE_BAS/2);


	#undef IMG_RENAISSANCE_WIDTH
	#undef IMG_RENAISSANCE_HEIGHT


/*	{
		dial[INFO_CDR_TITRE].ob_x = 0;
		dial[INFO_CDR_TITRE].ob_y = 0;
		dial[INFO_CDR_TITRE].ob_height = gr_hhbox;
		dial[INFO_CDR_TITRE].ob_width  = gr_hwbox;


		dial[INFO_CDR_INVISIB].ob_height = dial[INFO_CDR_TITRE].ob_height + 10;
		dial[INFO_CDR_INVISIB].ob_width  = dial[INFO_CDR_INVISIB].ob_width + 10;
	}*/

	return;


}

