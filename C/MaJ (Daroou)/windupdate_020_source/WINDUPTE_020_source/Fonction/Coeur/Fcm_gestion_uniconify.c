/* **[Fonction commune]******** */
/* * Gestion message          * */
/* * 05/12/2003 = 06/04/2013  * */
/* **************************** */


#include "Fcm_Purge_Redraw.c"




/* Prototypes */
VOID Fcm_gestion_uniconify(VOID);


/* Fonction */
VOID Fcm_gestion_uniconify(VOID)
{
/*
 * extern	FT_REDRAW	table_ft_redraw_win[NB_FENETRE];
 * extern	WORD		buffer_aes[16];
 * extern	WORD		h_win[NB_FENETRE];
 * extern	WORD		pxy[16];
 * extern	WORD		vdihandle;
 *
 */
	WORD win_index;


	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_gestion_uniconify()"CRLF );
	log_print(FALSE);
	#endif


	/* On cherche l'index de la fenetre */
	win_index = Fcm_get_indexwindow( buffer_aes[3] );


	/* S'il s'agit d'une fenetre qui nous appartient */
	if( win_index != FCM_NO_MY_WINDOW )
	{

		/* On d‚s-iconify et m‚morise son ‚tat */
		wind_set( buffer_aes[3], WF_UNICONIFY,  buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7] );
		win_iconified[win_index]=FALSE;

		/* L'AES redimensionne et place la fenetre dans son etat normal */
		/* et nous envoie un message de redraw sur cette fenetre        */
		Fcm_purge_redraw();


		/* All uniconify ? */
		if( win_all_iconified_flag==FALSE )
		{
			/* Non, on peut quitter */
			return;
		}


		/* All uniconify */
		{
			WORD dummy;

			/* On memorise l'etat */
			win_all_iconified_flag=FALSE;

			/* On cherche toutes les fenetres iconifi‚es et on les rouvre */
			for( dummy=0; dummy<NB_FENETRE; dummy++)
			{
				if( win_iconified[dummy]==TRUE && dummy!=win_index )
				{
					win_iconified[dummy]=FALSE;

					if( table_ft_ouvre_fenetre[dummy] != FCM_FONCTION_NON_DEFINI )
					{
						table_ft_ouvre_fenetre[dummy]();
						Fcm_purge_redraw();
					}
					else
					{
						#ifdef LOG_FILE
						sprintf( buf_log, " !!! ERREUR !!! Gestion UnIconify - Fonction ouverture non define !!! (index=%d)"CRLF, dummy );
						log_print(FALSE);
						#endif
					}
				}
			}
		}
	}


	return;
}

