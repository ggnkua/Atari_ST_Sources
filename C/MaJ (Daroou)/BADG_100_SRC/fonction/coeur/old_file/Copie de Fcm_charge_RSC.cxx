/* **[Fonction Commune]************ */
/* * Chargement d'un ressource    * */
/* * 09/08/2003 :: 09/01/2015     * */
/* ******************************** */



#ifndef ____Fcm_charge_RSC___
#define ____Fcm_charge_RSC___



#include "Fcm_file_exist.c"
#include "Fcm_check_rsc_alerte.c"



#define TAILLE_CHEMIN_RSC (TAILLE_CHEMIN+TAILLE_FICHIER)



/* Prototype */
int16 Fcm_charge_RSC( void );


/* Fonction */
int16 Fcm_charge_RSC( void )
{

	/*char my_buffer[ (TAILLE_CHEMIN+TAILLE_FICHIER) ];*/
	char my_buffer[ TAILLE_CHEMIN_RSC ];



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"#### Fcm_charge_RSC() : {"RSC_NOM"}"CRLF );
	log_print( FALSE );
	sprintf( buf_log, "  - Fcm_rsc_langage_code : %d"CRLF, Fcm_rsc_langage_code );
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

		return(FALSE);
	}




	/* On construit le chemin+fichier du RSC */
	/* ------------------------------------- */

	strcpy( my_buffer, Fcm_chemin_courant );
	strcat( my_buffer, "RSC\\" );

	switch( Fcm_rsc_langage_code )
	{
		case PLANG_ANGLAIS:
			strcat( my_buffer, "UK\\" );
			break;

		case PLANG_ALLEMAND:
			strcat( my_buffer, "DE\\" );
			break;

		case PLANG_FRANCAIS:
			strcat( my_buffer, "FR\\" );
			break;

		case PLANG_ESPAGNOL:
			strcat( my_buffer, "ES\\" );
			break;

		case PLANG_ITALIEN:
			strcat( my_buffer, "ITA\\" );
			break;

		case PLANG_SUEDOIS:
			strcat( my_buffer, "SWE\\" );
			break;

		case PLANG_UKRAINIEN:
			strcat( my_buffer, "UKR\\" );
			break;

		case PLANG_RUSSE:
			strcat( my_buffer, "RU\\" );
			break;

		default:
			strcat( my_buffer, "FR\\" );
			Fcm_rsc_langage_code=PLANG_FRANCAIS;
			break;
	}

	strcat( my_buffer, RSC_NOM  );




	/* on v‚rifie que le buffer n'a pas d‚bord‚ au cas o— */
	if( strlen(my_buffer) > TAILLE_CHEMIN_RSC )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "  ERREUR !!! d‚bordement du buffer"CRLF );
		log_print( FALSE );
		#endif

		/* D‚bordement du buffer, on quitte */
		form_alert(1, "[3]["PRG_NOM"|Chemin RSC trop long.|D‚bordement du buffer.|m‚moire ‚cras‚ !][  Quitter  ]" );

		return(FALSE);
	}




	if( Fcm_file_exist(my_buffer) != TRUE )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "  - Fichier ressource absent {%s}"CRLF, my_buffer );
		log_print( FALSE );
		sprintf( buf_log, "  - Prise en compte du RSC par d‚faut (FR) "CRLF );
 		log_print( FALSE );
		#endif

		strcpy( my_buffer, Fcm_chemin_courant );
		strcat( my_buffer, "RSC\\FR\\" );
		strcat( my_buffer, RSC_NOM  );

		Fcm_rsc_langage_code=PLANG_FRANCAIS;

	}



	#ifdef LOG_FILE
	sprintf( buf_log, "  - Nom du ressource … charger: {%s}"CRLF, my_buffer );
	log_print( FALSE );
	#endif




	if( rsrc_load(my_buffer) )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "  - RSC charg‚"CRLF""CRLF );
		log_print( FALSE );
		#endif

		if( Fcm_check_rsc_alerte()==0 )
		{
			return(TRUE);
		}

		return(FALSE);
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "  ERREUR -  Fichier ressource introuvable {%s}"CRLF, my_buffer );
	log_print( FALSE );
	#endif

	/* RSC introuvable, on quitte */
	form_alert(1, "[3]["PRG_NOM"| |RSC introuvable|RSC not found][  Quitter  ]");


	return(FALSE);


}


#undef TAILLE_CHEMIN_RSC



#endif  /* ____Fcm_charge_RSC___ */

