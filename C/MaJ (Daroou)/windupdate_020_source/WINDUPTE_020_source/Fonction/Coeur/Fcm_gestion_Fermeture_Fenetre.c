/* **[Fonction commune]********* */
/* * Gestion fermeture fenetre * */
/* * 02/01/2013 = 06/04/2013   * */
/* ***************************** */



#include "Fcm_Fermer_Fenetre.c"




/* Prototype */
VOID Fcm_gestion_Fermeture_Fenetre(VOID);


/* Fonction */
VOID Fcm_gestion_Fermeture_Fenetre(VOID)
{
/*
 * extern	WORD		buffer_aes[16];
 *
 */

	WORD	win_index;


	/* Pour l'instant les fenetres sont ferm‚es directement, plus tard
	   quand le cas se presentera, coder un appel si necessaire a une
	   fonction specifique (tableur de pointeur) a la fenetre pour
       gerer sa fermeture ... */


	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_gestion_Fermeture_Fenetre() : handle=%d"CRLF, buffer_aes[3] );
	log_print(FALSE);
	#endif


	/* on cherche l'index de la fenetre dans la liste des handles */
	win_index = Fcm_get_indexwindow( buffer_aes[3]);



	if( win_index == FCM_NO_MY_WINDOW )
	{
		/* Bug AES ? ou du programme ;p */
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR - Ce n'est pas une fenetre … nous ;p"CRLF );
		log_print(FALSE);
		#endif

		return;
	}

	if( table_ft_ferme_fenetre[win_index] != FCM_FONCTION_NON_DEFINI )
	{
		table_ft_ferme_fenetre[win_index] ();
	}
	else
	{
		Fcm_fermer_fenetre(win_index);
	}


	return;




}

