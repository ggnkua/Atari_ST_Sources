/* **[Fonction Commune]************ */
/* * Chargement d'un ressource    * */
/* * 09/08/2003 :: 09/01/2015     * */
/* ******************************** */



#include "Fcm_file_exist.c"




/* Prototype */
int16 Fcm_charge_RSC( void );


/* Fonction */
int16 Fcm_charge_RSC( void )
{

	char my_buffer[ (TAILLE_CHEMIN+TAILLE_FICHIER) ];



	#ifdef LOG_FILE
	sprintf( buf_log, "  ## Fcm_charge_RSC() : {"RSC_NOM"}"CRLF );
	log_print( FALSE );
	sprintf( buf_log, "  - TOS langage : %d"CRLF, systeme.tos_langage );
	log_print( FALSE );
	#endif


	/* on v‚rifie que le buffer est assez grand */
	if( (strlen(Fcm_chemin_courant)+strlen(RSC_NOM)+4) > (TAILLE_CHEMIN+TAILLE_FICHIER) )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR !!! Chemin RSC trop long (>%d octets)"CRLF, (TAILLE_CHEMIN+TAILLE_FICHIER) );
		log_print( FALSE );
		#endif

		form_alert(1, "[3]["PRG_NOM"|Chemin RSC trop long !][  Quitter  ]" );

		return(FALSE);
	}




	/* On construit le chemin+fichier du RSC */
	/* ------------------------------------- */

	strcpy( my_buffer, Fcm_chemin_courant );

	switch( systeme.tos_langage )
	{
		case 0:
		case 3:
			strcat( my_buffer, "UK\\" );
			break;

		case 1:
			strcat( my_buffer, "DE\\" );
			break;

		case 2:
			strcat( my_buffer, "FR\\" );
			break;

		case 4:
			strcat( my_buffer, "SP\\" );
			break;

		case 5:
			strcat( my_buffer, "IT\\" );
			break;

		case 6:
			strcat( my_buffer, "SW\\" );
			break;

		case 7:
			strcat( my_buffer, "SF\\" );
			break;

		case 8:
			strcat( my_buffer, "SG\\" );
			break;

		case 9:
			strcat( my_buffer, "TK\\" );
			break;

		case 10:
			strcat( my_buffer, "FD\\" );
			break;

		case 11:
			strcat( my_buffer, "NW\\" );
			break;

		case 12:
			strcat( my_buffer, "DK\\" );
			break;

		case 13:
			strcat( my_buffer, "SA\\" );
			break;

		case 14:
			strcat( my_buffer, "HD\\" );
			break;

		case 15:
			strcat( my_buffer, "CZ\\" );
			break;

		case 16:
			strcat( my_buffer, "HG\\" );
			break;

		default:
			strcat( my_buffer, "FR\\" );
			break;
	}

	strcat( my_buffer, RSC_NOM  );




	/* on v‚rifie que le buffer n'a pas d‚bord‚ */
	if( strlen(my_buffer) > (TAILLE_CHEMIN+TAILLE_FICHIER) )
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
		strcat( my_buffer, "FR\\" );
		strcat( my_buffer, RSC_NOM  );
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

		return( TRUE );
	}


	/* RSC introuvable, on quitte */
	form_alert(1, "[3]["PRG_NOM"| |RSC introuvable|RSC not found][  Quitter  ]");


	return(FALSE);


}

