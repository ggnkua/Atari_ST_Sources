/* **[Fonction Commune]********** */
/* *                            * */
/* * 14/08/2002 MaJ 15/03/2024  * */
/* ****************************** */



#ifndef ___FCM_REMOVE_EXTENSION_C___
#define ___FCM_REMOVE_EXTENSION_C___


/* Cette fonction retire l'extension de la chaine */


void Fcm_remove_extension( char *chaine );


void Fcm_remove_extension( char *chaine )
{
	char	*pt_char;


	FCM_LOG_PRINT1("* Fcm_remove_extension{%s}", chaine );

	pt_char = strrchr(chaine, '.');

	if( pt_char != NULL )
	{
		pt_char[0] = '\0';
	}
	else
	{
		FCM_CONSOLE_DEBUG("Fcm_remove_extension() : aucun '.' trouve");
	}

	FCM_LOG_PRINT1("  => {%s}", chaine );


	return;

}


#endif /* ___FCM_REMOVE_EXTENSION_C___ */

