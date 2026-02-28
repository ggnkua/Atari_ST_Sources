/* **[Fonction Commune]********* */
/* *                           * */
/* * 25/05/2015 MaJ 25/05/2015 * */
/* ***************************** */



#include "Fcm_file_exist.c"
#include "Fcm_gestion_pop_up.c"
#include "Fcm_libere_RSC.c"

#include "Fcm_set_config_generale.c"
#include "Fcm_charge_RSC.c"
#include "Fcm_my_menu_bar.c"
#include "Fcm_init_rsc_info.c"

#include "Fcm_ouvre_fenetre_start.c"
#include "Fcm_purge_redraw.c"

#include "Fcm_gestion_fermeture_programme.c"





#define TAILLE_CHEMIN_RSC (TAILLE_CHEMIN+TAILLE_FICHIER)



/* Prototype */
void Fcm_gestion_preference_langue( void );




/* Fonction */
void Fcm_gestion_preference_langue( void )
{

	char    my_buffer[ (TAILLE_CHEMIN+TAILLE_FICHIER) ];
	OBJECT *adr_popup;
	OBJECT *adr_dl_preference;
	int16   y;




	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"## Fcm_gestion_preference_langue()"CRLF );
	log_print( FALSE );
	sprintf( buf_log, "  - Fcm_rsc_langage_code : %d"CRLF, Fcm_rsc_langage_code );
	log_print( FALSE );
	#endif


	#ifdef LOG_FILE
	sprintf( buf_log, "Recherche langue disponible"CRLF );
	log_print( FALSE );
	#endif



	/* on v‚rifie que le buffer est assez grand */
	if( (strlen(Fcm_chemin_courant)+strlen("RSC\\xxx\\")+strlen(RSC_NOM)) >= TAILLE_CHEMIN_RSC )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR !!! Chemin RSC trop long (>=%d octets)"CRLF, TAILLE_CHEMIN_RSC );
		log_print( FALSE );
		#endif

		form_alert(1, "[3]["PRG_NOM"|Chemin RSC trop long !][  Quitter  ]" );
		return;
	}




	/* Adresse du pop up langue */
	rsrc_gaddr( R_TREE, POPUP_PREF_LANG, &adr_popup );


	{
		int16 idx_champ;

		for( idx_champ=PLANG_ANGLAIS; idx_champ<=PLANG_RUSSE; idx_champ++ )
		{
/*			SET_BIT_W( adr_popup[idx_champ].ob_state, OS_DISABLED, 0);*/
			SET_BIT_W( adr_popup[idx_champ].ob_flags, OF_HIDETREE, 1);
			SET_BIT_W( adr_popup[idx_champ].ob_state, OS_SELECTED, 0);
		}
	}


	y=0;


	sprintf( my_buffer, "%sRSC\\UK\\"RSC_NOM, Fcm_chemin_courant );
	if( Fcm_file_exist(my_buffer) == TRUE )
	{
		SET_BIT_W( adr_popup[PLANG_ANGLAIS].ob_flags, OF_HIDETREE, 0);

		y = y + adr_popup[PLANG_ANGLAIS].ob_height;

		#ifdef LOG_FILE
		sprintf( buf_log, "  Fichier ressource %s present"CRLF, my_buffer );
		log_print( FALSE );
		#endif
	}


	sprintf( my_buffer, "%sRSC\\DE\\"RSC_NOM, Fcm_chemin_courant );
	if( Fcm_file_exist(my_buffer) == TRUE )
	{
		SET_BIT_W( adr_popup[PLANG_ALLEMAND].ob_flags, OF_HIDETREE, 0);

		adr_popup[PLANG_ALLEMAND].ob_y = y;
		y = y + adr_popup[PLANG_ALLEMAND].ob_height;

		#ifdef LOG_FILE
		sprintf( buf_log, "  Fichier ressource %s present"CRLF, my_buffer );
		log_print( FALSE );
		#endif
	}


	sprintf( my_buffer, "%sRSC\\FR\\"RSC_NOM, Fcm_chemin_courant );
	if( Fcm_file_exist(my_buffer) == TRUE )
	{
		SET_BIT_W( adr_popup[PLANG_FRANCAIS].ob_flags, OF_HIDETREE, 0);

		adr_popup[PLANG_FRANCAIS].ob_y = y;
		y = y + adr_popup[PLANG_FRANCAIS].ob_height;

		#ifdef LOG_FILE
		sprintf( buf_log, "  Fichier ressource %s present"CRLF, my_buffer );
		log_print( FALSE );
		#endif
	}


	sprintf( my_buffer, "%sRSC\\ES\\"RSC_NOM, Fcm_chemin_courant );
	if( Fcm_file_exist(my_buffer) == TRUE )
	{
		SET_BIT_W( adr_popup[PLANG_ESPAGNOL].ob_flags, OF_HIDETREE, 0);

		adr_popup[PLANG_ESPAGNOL].ob_y = y;
		y = y + adr_popup[PLANG_ESPAGNOL].ob_height;

		#ifdef LOG_FILE
		sprintf( buf_log, "  Fichier ressource %s present"CRLF, my_buffer );
		log_print( FALSE );
		#endif
	}


	sprintf( my_buffer, "%sRSC\\IT\\"RSC_NOM, Fcm_chemin_courant );
	if( Fcm_file_exist(my_buffer) == TRUE )
	{
		SET_BIT_W( adr_popup[PLANG_ITALIEN].ob_flags, OF_HIDETREE, 0);

		adr_popup[PLANG_ITALIEN].ob_y = y;
		y = y + adr_popup[PLANG_ITALIEN].ob_height;

		#ifdef LOG_FILE
		sprintf( buf_log, "  Fichier ressource %s present"CRLF, my_buffer );
		log_print( FALSE );
		#endif
	}


	sprintf( my_buffer, "%sRSC\\SWE\\"RSC_NOM, Fcm_chemin_courant );
	if( Fcm_file_exist(my_buffer) == TRUE )
	{
		SET_BIT_W( adr_popup[PLANG_SUEDOIS].ob_flags, OF_HIDETREE, 0);

		adr_popup[PLANG_SUEDOIS].ob_y = y;
		y = y + adr_popup[PLANG_SUEDOIS].ob_height;

		#ifdef LOG_FILE
		sprintf( buf_log, "  Fichier ressource %s present"CRLF, my_buffer );
		log_print( FALSE );
		#endif
	}


	sprintf( my_buffer, "%sRSC\\UKR\\"RSC_NOM, Fcm_chemin_courant );
	if( Fcm_file_exist(my_buffer) == TRUE )
	{
		SET_BIT_W( adr_popup[PLANG_UKRAINIEN].ob_flags, OF_HIDETREE, 0);

		adr_popup[PLANG_UKRAINIEN].ob_y = y;
		y = y + adr_popup[PLANG_UKRAINIEN].ob_height;

		#ifdef LOG_FILE
		sprintf( buf_log, "  Fichier ressource %s present"CRLF, my_buffer );
		log_print( FALSE );
		#endif
	}


	sprintf( my_buffer, "%sRSC\\RU\\"RSC_NOM, Fcm_chemin_courant );
	if( Fcm_file_exist(my_buffer) == TRUE )
	{
		SET_BIT_W( adr_popup[PLANG_RUSSE].ob_flags, OF_HIDETREE, 0);

		adr_popup[PLANG_RUSSE].ob_y = y;
		y = y + adr_popup[PLANG_RUSSE].ob_height;

		#ifdef LOG_FILE
		sprintf( buf_log, "  Fichier ressource %s present"CRLF, my_buffer );
		log_print( FALSE );
		#endif
	}


	/* on redimensionne le pop up */
	adr_popup[PLANG_FOND].ob_height = y;



	/* Adresse du dialogue */
	rsrc_gaddr( R_TREE, DL_OPT_PREF, &adr_dl_preference );

	adr_popup[PLANG_FOND].ob_y = adr_dl_preference[PREF_POPUP_LANG].ob_y+adr_dl_preference[PREF_POPUP_LANG].ob_height;
	adr_popup[PLANG_FOND].ob_x = adr_dl_preference[PREF_POPUP_LANG].ob_x;



	{
		int16  winx,winy,winw,winh;
		int16  objet;


		/* on cherche les coordonn‚es de la fenˆtre */
		wind_get(h_win[W_OPTION_PREFERENCE],WF_WORKXYWH,&winx,&winy,&winw,&winh);

		adr_popup[PLANG_FOND].ob_x += winx;
		adr_popup[PLANG_FOND].ob_y += winy;

		adr_popup[PLANG_FOND].ob_y += (adr_dl_preference[PREF_POPUP_LANG].ob_spec.tedinfo->te_thickness * -1);
		adr_popup[PLANG_FOND].ob_y += (adr_popup[PLANG_FOND].ob_spec.obspec.framesize * -1);

		objet = Fcm_gestion_pop_up( adr_popup/*, h_win[W_OPTION_PREFERENCE]*/ );


		Fcm_purge_redraw();

/*		{
			char texte[256];

			sprintf( texte, "reponse pop up = %d   ", objet );
			v_gtext(vdihandle,4*8,2*16,texte);
		}*/



		/* ---------------------------------------------- */
		/* Mise … jour Langue dans le dialogue preference */
		/* ---------------------------------------------- */
		if( objet!=-1 && objet!=Fcm_rsc_langage_code )
		{
			int16 old_Fcm_rsc_langage_code;


			old_Fcm_rsc_langage_code=Fcm_rsc_langage_code;
			Fcm_rsc_langage_code = objet;


			{
				OBJECT	*adr_popup;

				rsrc_gaddr( R_TREE, POPUP_PREF_LANG, &adr_popup );
				Fcm_set_rsc_string( DL_OPT_PREF, PREF_POPUP_LANG, adr_popup[Fcm_rsc_langage_code].ob_spec.tedinfo->te_ptext );
			}


			{
				OBJECT	*adr_preference;

				rsrc_gaddr( R_TREE, DL_OPT_PREF, &adr_preference );
				Fcm_objet_draw( adr_preference, h_win[W_OPTION_PREFERENCE], PREF_POPUP_LANG, 0 );
			}




			Fcm_my_menu_bar( BARRE_MENU, MENU_REMOVE );
			Fcm_libere_RSC();

			if( Fcm_charge_RSC()==TRUE )
			{
				Fcm_set_config_generale();
				set_config();
				Fcm_init_rsc_info();
				Fcm_my_menu_bar( BARRE_MENU, MENU_INSTALL );

				if( Fcm_ft_rsc_init != FCM_FONCTION_NON_DEFINI )
				{
					/* R‚-initialisation des champs du RSC */
					Fcm_ft_rsc_init();
				}

			}
			else
			{
				Fcm_rsc_langage_code = old_Fcm_rsc_langage_code;

				if( Fcm_charge_RSC()==TRUE )
				{
					Fcm_set_config_generale();
					set_config();
					Fcm_init_rsc_info();
					Fcm_my_menu_bar( BARRE_MENU, MENU_INSTALL );

					if( Fcm_ft_rsc_init != FCM_FONCTION_NON_DEFINI )
					{
						/* R‚-initialisation des champs du RSC */
						Fcm_ft_rsc_init();
					}

				}
				else
				{
					/* on arrive pas recharger le rsc original */
					/* AP_TERM :(                              */
					Fcm_gestion_fermeture_programme();
				}

			}




			{
				int16 idx_win;

				for( idx_win=0; idx_win<NB_FENETRE; idx_win++ )
				{

					if( h_win[idx_win] != FCM_NO_OPEN_WINDOW )
					{
						Fcm_fermer_fenetre( idx_win );
						h_win[idx_win] = FCM_GO_OPEN_WINDOW;
					}
				}
				Fcm_ouvre_fenetre_start();
			}


		}



	}



	return;



}


#undef TAILLE_CHEMIN_RSC

