/* **[Fonction commune]******** */
/* * Gestion message          * */
/* *                          * */
/* * 27/11/2003 = 08/04/2013  * */
/* **************************** */


#ifndef ___Fcm_ouvre_fenetre_start___
#define ___Fcm_ouvre_fenetre_start___



#include "Fcm_Purge_Redraw.c"



/* Prototypes */
VOID Fcm_ouvre_fenetre_start(VOID);


/* Fonction */
VOID Fcm_ouvre_fenetre_start( VOID )
{
/*
 * extern	WORD	winpos[NB_FENETRE][5];
 *
 */

	WORD	win_index;


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"## Fcm_ouvre_fenetre_start()"CRLF);
	log_print(FALSE);
	#endif


	for( win_index=0; win_index<NB_FENETRE; win_index++)
	{

		#ifdef LOG_FILE
		sprintf( buf_log, " - h_win[%d]=%d"CRLF, win_index, h_win[win_index] );
		log_print(FALSE);
		#endif

		/* L'index 4 contient l'handle de la fenetre (qui est enregistr‚ dans le    */
		/* fichier de config), cela permet de savoir si la fenetre ‚tait ouverte    */
		/* lors de la sauvegarde de la config, sinon il contient FCM_NO_OPEN_WINDOW */

		if( h_win[win_index] == FCM_GO_OPEN_WINDOW )
		{
			/* On aiguille vers la fonction d'ouverture concern‚e */
			/* si la fonction est d‚fini dans notre tableau de pointeur de fonction */
			if( table_ft_ouvre_fenetre[win_index] != FCM_FONCTION_NON_DEFINI )
			{
				/* on appel la fonction */
				table_ft_ouvre_fenetre[win_index]();
				Fcm_purge_redraw();
			}
			else
			{
				#ifdef LOG_FILE
				sprintf( buf_log, "ERREUR !!! Fcm_ouvre_fenetre_start - Fonction ouverture non define !!! "CRLF  );
				log_print(FALSE);
				#endif
			}

		}
		else
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "-> fenetre ferm‚."CRLF );
			log_print(FALSE);
			#endif
		}
	}


	return;


}


#endif   /* ___Fcm_ouvre_fenetre_start___ */


