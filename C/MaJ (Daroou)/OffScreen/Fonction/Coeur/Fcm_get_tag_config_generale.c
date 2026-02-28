/*=================================*/
/* Fonction recherchant tous les   */
/* TAG de configuration du coeur   */
/* de toutes les applis            */
/* 30/12/2012 # 11/01/2015         */
/*_________________________________*/


#include "Fcm_Get_Tag.c"
#include "Fcm_Conversion_ASCII_to_long.c"
#include "Fcm_Get_Win_Parametre.c"




#define TAILLE_BUFFER_TAGCONFIG  (TAILLE_CHEMIN*2)




/* Prototypes */
void Fcm_get_tag_config_generale(const char *pt_fichier_config, int16 *erreur_config, int16 *tag_absent);



/* Fonction */
void Fcm_get_tag_config_generale(const char *pt_fichier_config, int16 *erreur_config, int16 *tag_absent)
{

	int16	reponse;
	char	my_buffer[TAILLE_BUFFER_TAGCONFIG]="vide";



	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"* Fcm_get_tag_config_generale(%p,%8p,%8p)"CRLF, pt_fichier_config, erreur_config, tag_absent );
	log_print(FALSE);
	#endif



	/* ---------------------------- */
	/* Sauvegarde Auto de la config */
	/* ---------------------------- */
	{
		int32 dummy;

		reponse = Fcm_get_tag( "SAUVEGARDE_AUTO=", my_buffer, TAILLE_BUFFER_TAGCONFIG, pt_fichier_config );
		dummy=0;
		if( reponse==TRUE )
		{
			if( strlen(my_buffer)==1 )
			{
				dummy=Fcm_conversion_ascii_to_long( my_buffer );
			}
			else
			{
				*erreur_config=*erreur_config+1;
				#ifdef LOG_FILE
				sprintf( buf_log, "ERREUR !!! valeur pour TAG SAUVEGARDE_AUTO incorrect !"CRLF);
				log_print(FALSE);
				#endif
			}
		}
		else
		{
			*tag_absent=*tag_absent+1;
		}

		Fcm_save_option_auto=FALSE;
		if( dummy==1 )
		{
			Fcm_save_option_auto=TRUE;
		}
	}





	/* -------------------------------- */
	/* Sauvegarde position des fenetres */
	/* -------------------------------- */
	{
		int32 dummy;

		reponse = Fcm_get_tag( "SAUVEGARDE_WINPOS=", my_buffer, TAILLE_BUFFER_TAGCONFIG, pt_fichier_config );
		dummy=0;
		if( reponse==TRUE )
		{
			if( strlen(my_buffer)==1 )
			{
				dummy=Fcm_conversion_ascii_to_long( my_buffer );
			}
			else
			{
				*erreur_config=*erreur_config+1;
				#ifdef LOG_FILE
				sprintf( buf_log, "ERREUR !!! valeur pour TAG SAUVEGARDE_WINPOS incorrect !"CRLF);
				log_print(FALSE);
				#endif
			}
		}
		else
		{
			*tag_absent=*tag_absent+1;
		}

		Fcm_save_winpos=FALSE;
		if( dummy==1 )
		{
			Fcm_save_winpos=TRUE;
		}
	}





	/* ---------------------------------------- */
	/* Quiiter sur fermeture fenetre principale */
	/* ---------------------------------------- */
	{
		int32 dummy;

		reponse = Fcm_get_tag( "QUITTER_CLOSEWIN=", my_buffer, TAILLE_BUFFER_TAGCONFIG, pt_fichier_config );
		dummy=0;
		if( reponse==TRUE )
		{
			if( strlen(my_buffer)==1 )
			{
				dummy=Fcm_conversion_ascii_to_long( my_buffer );
			}
			else
			{
				*erreur_config=*erreur_config+1;
				#ifdef LOG_FILE
				sprintf( buf_log, "ERREUR !!! valeur pour TAG QUITTER_CLOSEWIN incorrect !"CRLF);
				log_print(FALSE);
				#endif
			}
		}
		else
		{
			*tag_absent=*tag_absent+1;
		}

		Fcm_quit_closewin=FALSE;
		if( dummy==1 )
		{
			Fcm_quit_closewin=TRUE;
		}
	}







	/* ---------------------------------------- */
	/* Langage code pour le RSC                 */
	/* ---------------------------------------- */
	{
		int32 dummy;

		reponse = Fcm_get_tag( "RSC_LANGAGE=", my_buffer, TAILLE_BUFFER_TAGCONFIG, pt_fichier_config );
		dummy=0;
		if( reponse==TRUE )
		{
			if( strlen(my_buffer)==1 )
			{
				dummy=Fcm_conversion_ascii_to_long( my_buffer );
			}
			else
			{
				*erreur_config=*erreur_config+1;
				#ifdef LOG_FILE
				sprintf( buf_log, "ERREUR !!! valeur pour TAG RSC_LANGAGE incorrect !"CRLF);
				log_print(FALSE);
				#endif
			}
		}
		else
		{
			*tag_absent=*tag_absent+1;
		}


		Fcm_rsc_langage_code=2;
		if( dummy>=0 && dummy <=9 )
		{
			Fcm_rsc_langage_code=dummy;
		}
	}











	/*****************************************************/
	/* ParamŠtres des fenetres                           */
	/*****************************************************/
	if( Fcm_save_winpos==TRUE )
	{
		/* on charge les positions seulement si la sauvegarde est active */
		Fcm_get_win_parametre( pt_fichier_config );
	}




	return;


}


#undef TAILLE_BUFFER_TAGCONFIG

