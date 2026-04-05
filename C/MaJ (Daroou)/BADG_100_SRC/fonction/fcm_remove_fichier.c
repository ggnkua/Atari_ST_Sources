/* **[Fonction Commune]********** */
/* *                            * */
/* * 13/07/2017 MaJ 20/02/2024  * */
/* ****************************** */


#ifndef ___FCM_REMOVE_FICHIER_C___
#define ___FCM_REMOVE_FICHIER_C___


void Fcm_remove_fichier( char *chaine );


/* Cette fonction 'retire' le fichier de la chaine. */
/* il restera que le chemin du fichier              */

/* Attention: si un chemin est transmis sans fichier la */
/* fonction va ecrire un NULL byte après le dernier '\' */
/* Si la chaine a assez de place pour un nom de fichier */
/* aucun probleme ne devrait arriver ;)                 */


/* avant la mise a jour, la fonction effacé le dernier '\' */
/* je sais pas si c'etait voulu ou un bug, je sais pas qui */
/* utilisait cette fonction... PaulaNG ?                   */
/* maintenant, le chemin garde le '\' de fin               */


void Fcm_remove_fichier( char *chaine )
{
	char	*pt_char;


	FCM_LOG_PRINT1("* Fcm_remove_fichier{%s}", chaine );

	pt_char = strrchr(chaine, '\\');

	if( pt_char != NULL )
	{
		pt_char[1] = '\0';
	}
	else
	{
		FCM_CONSOLE_DEBUG("Fcm_remove_fichier() : aucun \\ trouve, chemin non conforme");
	}

	FCM_LOG_PRINT1("  => {%s}", chaine );


	return;

}

#endif /* ___FCM_REMOVE_FICHIER_C___ */

