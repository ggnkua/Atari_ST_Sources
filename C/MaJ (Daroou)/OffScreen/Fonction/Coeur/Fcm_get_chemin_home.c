/* **[Fonction commune]************************* */
/* * Recherche le chemin d‚fini par HOME       * */
/* * 15/08/2003  =  10/01/2015                 * */
/* ********************************************* */


#include "Fcm_Get_Shel_Envrn.c"
#include "Fcm_dir_exist.c"



/* Prototypes */
void Fcm_get_chemin_home( char *mon_chemin, const uint16 size_max );



/* Fonction */
void Fcm_get_chemin_home( char *mon_chemin, const uint16 size_max )
{
/*
 *
 */


	/* On recherche le chemin HOME d‚fini par le systŠme        */
	/* Le resultat est placŠ dans la chaine donn‚e en parametre */
	/* Si HOME n'est pas trouv‚, on le cherche manuellement     */
	/* Au pire, il sera defini sur C:\ si pr‚sent ou … d‚faut   */
	/* au niveau de l'application                               */


	#ifdef LOG_FILE
	sprintf( buf_log, TAB4"* Fcm_get_chemin_home({%s},%d)"CRLF, mon_chemin, size_max );
	log_print(FALSE);
	#endif


	mon_chemin[0]=0;


	if( Fcm_get_shel_envrn( mon_chemin, "HOME=", (size_max-1) ) == TRUE )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, TAB4" - HOME={%s}"CRLF,mon_chemin );
		log_print(FALSE);
		#endif

		/* si la variable a ‚t‚ trouv‚ */
		if( strlen(mon_chemin) !=0 )
		{
			/* on v‚rifie qu'il y a un backslash en fin de chemin */
			if( mon_chemin[ strlen(mon_chemin)-1 ] != '\\' )
			{
				/* sinon on l'ajoute */
				strcat( mon_chemin, "\\" );

				#ifdef LOG_FILE
				sprintf( buf_log, TAB4" - HOME={%s} correction."CRLF, mon_chemin );
				log_print(FALSE);
				#endif
			}

			return;
		}
	}



	#ifdef LOG_FILE
	sprintf( buf_log, TAB4" - Variable d'environnement non d‚fini, recherche manuelle"CRLF );
	log_print(FALSE);
	#endif




	/* -----------------------------------------------------------*/
	strcpy( mon_chemin, "C:\\HOME\\" );

	#ifdef LOG_FILE
	sprintf( buf_log, TAB4" - Recherche de %s"CRLF, mon_chemin );
	log_print(FALSE);
	#endif

	if( Fcm_dir_exist(mon_chemin) )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, TAB4" - chemin {%s} valide"CRLF, mon_chemin );
		log_print(FALSE);
		#endif

		return;
	}


	/* -----------------------------------------------------------*/
	/* C:\HOME\ n'existe pas, on tente C:\ ..                     */
	strcpy( mon_chemin, "C:\\" );

	#ifdef LOG_FILE
	sprintf( buf_log, TAB4" - Recherche de %s"CRLF, mon_chemin );
	log_print(FALSE);
	#endif

	if( Fcm_dir_exist( mon_chemin ) )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, TAB4" - chemin {%s} valide"CRLF, mon_chemin );
		log_print(FALSE);
		#endif

		return;
	}


	/* -----------------------------------------------------------*/
	/* Pas de disque dur ? on prend le chemin de l'application    */

	mon_chemin[0]=0;

	if( size_max > strlen(Fcm_chemin_courant) )
	{
		strcpy( mon_chemin, Fcm_chemin_courant );

		#ifdef LOG_FILE
		sprintf( buf_log, TAB4" - HOME introuvrable, r‚pertoire de l'application utilis‚: %s"CRLF, mon_chemin );
		log_print(FALSE);
		#endif

		return;
	}

	#ifdef LOG_FILE
	sprintf( buf_log, TAB4" - HOME non defini, buffer trop faible pour le chemin courant"CRLF );
	log_print(FALSE);
	#endif


	return;


}

