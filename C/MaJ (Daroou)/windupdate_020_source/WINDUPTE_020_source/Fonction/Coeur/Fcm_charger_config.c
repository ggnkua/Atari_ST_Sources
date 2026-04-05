/* **[Fonction Commune]******************* */
/* * Chargement Fichier de configuration * */
/* * 20/01/2013 - 30/01/2015             * */
/* *************************************** */


#include "Fcm_Reserve_Ram.c"
#include "Fcm_Libere_Ram.c"
#include "Fcm_Bload.c"
#include "Fcm_Get_Chemin_Home.c"
#include "Fcm_file_size.c"
#include "Fcm_get_tag_config_generale.c"
#include "Fcm_set_config_generale.c"




/* Prototype */
int16 Fcm_charger_config( void );


/* Fonction */
int16 Fcm_charger_config( void )
{

	char   *pt_fichier_config=NULL;
	int32	taille_fichier_config=0;



	#ifdef LOG_FILE
	sprintf( buf_log, "## Fcm_charger_config()"CRLF);
	log_print( FALSE );
	#endif


	/*----------------------------------------------------------*/
	/* On r‚cupŠre le chemin d‚fini par HOME                    */
	/*----------------------------------------------------------*/

	Fcm_get_chemin_home( Fcm_chemin_config, (TAILLE_CHEMIN_CONFIG-strlen(INF_NOM)) );
	strcat( Fcm_chemin_config, INF_NOM);

	#ifdef LOG_FILE
	sprintf( buf_log, "- Fichier Config: {%s}"CRLF,Fcm_chemin_config );
	log_print( FALSE );
	#endif




	/*----------------------------------------------------------*/
	/* Chargement du fichier de config                          */
	/*----------------------------------------------------------*/

	taille_fichier_config = Fcm_file_size(Fcm_chemin_config);

	#ifdef LOG_FILE
	sprintf( buf_log, "- Taille Fichier Config: {%ld}"CRLF,taille_fichier_config );
	log_print( FALSE );
	#endif


	if( taille_fichier_config>0 )
	{
		/* on reserve la quantit‚ de RAM n‚cessaire + 1 octet pour le Null byte de fin */
		pt_fichier_config = (char *)Fcm_reserve_ram( (taille_fichier_config+1), MX_PREFTTRAM|MX_PRIVATE );

		if( pt_fichier_config < (char *)2048 )
		{
			Fcm_form_alerte( 0, ALT_NORAMCONFIG );

			#ifdef LOG_FILE
			sprintf( buf_log, "## FIN ** Fcm_charger_config()"CRLF);
			log_print( FALSE );
			#endif
			return(FALSE);
		}


		/* Chargement du fichier de configuration */
		{
			uint32 octet_charger;

/*			#ifdef LOG_FILE
			sprintf( buf_log, "*** %p"CRLF, pt_fichier_config );
			log_print( FALSE );
			#endif
*/
			/* Chargement du fichier en mode binaire */
			octet_charger=Fcm_bload(Fcm_chemin_config, pt_fichier_config, 0L, -1L);

/*			#ifdef LOG_FILE
			sprintf( buf_log, "*** %p"CRLF, pt_fichier_config );
			log_print( FALSE );
			#endif
*/

			if( octet_charger != (uint32)taille_fichier_config )
			{
				#ifdef LOG_FILE
				sprintf( buf_log, "ERREUR: Taille fichier=%ld Octet charg‚=%ld"CRLF,taille_fichier_config,octet_charger);
				log_print( FALSE );
				#endif
			}

			taille_fichier_config=octet_charger;
			pt_fichier_config[octet_charger-1]=0;
		}










		{
			int16 erreur_config=0;	/* erreur de valeur pour un TAG */
			int16 tag_absent=0;		/* variable avsente */



			/* --------------------------------------------------------- */
			/* On r‚cupere tous les TAG commun … toutes les applications */
			/* --------------------------------------------------------- */
			Fcm_get_tag_config_generale(pt_fichier_config, &erreur_config, &tag_absent);


			/* --------------------------------------------------------- */
			/* Ici , tous les TAG propre … l'application                 */
			/* --------------------------------------------------------- */
			get_tag_config(pt_fichier_config, &erreur_config, &tag_absent);


			/*****************************************************/
			/* si des erreurs ont ‚t‚ d‚tect‚es                  */
			/*****************************************************/
			{
				char	my_buffer[TAILLE_BUFFER];
				char	*pt_chaine;

				if( erreur_config>0 || tag_absent>0 )
				{
					rsrc_gaddr( R_STRING, ALT_BAD_CONFIG, &pt_chaine );

					if( strlen(pt_chaine) < (TAILLE_BUFFER-5) )
					{
						sprintf( my_buffer, pt_chaine, erreur_config, tag_absent );
						form_alert(1, my_buffer);
					}
					else
					{
						#ifdef LOG_FILE
						sprintf( buf_log, "ERREUR - Taille buffer trop faible"CRLF );
						log_print( FALSE );
						#endif
						form_alert(1, pt_chaine);
					}
				}
			}
		}

		Fcm_libere_ram( (uint32)pt_fichier_config );

	}
	else
	{
		/* Le fichier de config n'existe pas ou sa taille est 0 */
		Fcm_form_alerte( 0, ALT_NO_INF_FILE );
		/* on ouvre la fenetre info par d‚faut */
		h_win[W_INFO_PRG]=FCM_GO_OPEN_WINDOW;
	}



	/* On met en place les paramŠtres de la config ou les paramŠtres par d‚faut */


	/* ParamŠtres communs aux applis */
	Fcm_set_config_generale();


	/* ParamŠtres propres … l'appli */
	set_config();


	#ifdef LOG_FILE
	sprintf( buf_log, "## FIN ** Fcm_charger_config()"CRLF);
	log_print( FALSE );
	#endif


	return(TRUE);


}

