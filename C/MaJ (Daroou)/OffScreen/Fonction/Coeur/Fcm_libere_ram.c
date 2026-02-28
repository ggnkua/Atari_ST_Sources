/* ******************************** */
/* *     Fonction LibŠre RAM      * */
/* *   11/05/2002 :: 20/04/2013   * */
/* ******************************** */


#ifndef __Fcm_libere_ram__
#define __Fcm_libere_ram__



#include "Fcm_Reserve_Ram.c"



/* Prototype */
LONG Fcm_libere_ram( ULONG adresse );


/* Fonction */
LONG Fcm_libere_ram( ULONG adresse )
{
/*
 *
 */


	WORD	index_table_pointeur;
	ULONG	*pt_get_key;



	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"* Fcm_libere_ram(%08lx)"CRLF, adresse);
	log_print(FALSE);
	#endif



	/* ----------------- */
	/* Adresse correct ? */
	/* ----------------- */
	if( adresse < 2048 )
	{
		#ifdef LOG_FILE
		strcpy( buf_log, "ERREUR ! Adresse invalide"CRLF);
		log_print(FALSE);
		#endif

		return( FALSE );
	}




	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - Lib‚ration  RAM, lib‚ration bloc … l'adresse=$%08lx"CRLF, adresse);
	log_print(FALSE);
	#endif


	for( index_table_pointeur=0; index_table_pointeur<RAM_MAX_POINTEUR; index_table_pointeur++)
	{
		if( RAM_table_pointeur[index_table_pointeur] == adresse ) break;
	}


	/* Si le pointeur n'a pas ‚t‚ trouv‚ */
	if( index_table_pointeur == RAM_MAX_POINTEUR )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR !!! aucun bloc r‚serv‚ … cette adresse ou d‚passement de capacit‚ gestion malloc"CRLF);
		log_print(FALSE);
		#endif

		return( FALSE );
	}




	RAM_table_pointeur[index_table_pointeur] = 0;


	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - [L%d] Lib‚ration  RAM, adresse=$%08lx"CRLF, index_table_pointeur, adresse);
	log_print(FALSE);
	#endif




	/* ------------------------------------------------------------ */
	/* On controle la cl‚ pour voir s'il y a eu d‚bordement du bloc */
	/* ------------------------------------------------------------ */
	pt_get_key=(ULONG *)RAM_table_key[index_table_pointeur];

	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - Controle de la cl‚ : adresse cl‚=%08lx (offset=+%ld)"CRLF, (ULONG)pt_get_key, ((ULONG)pt_get_key-adresse) );
	log_print(FALSE);
	#endif


	#ifdef LOG_FILE
	strcpy( buf_log, "ERREUR !!! => Cl‚ de controle ‚cras‚ ! d‚bordement de bloc !!!"CRLF);
	#endif

	if( *pt_get_key==0x12345678 )
	{
		pt_get_key++;
		if(  *pt_get_key==0x87654321 )
		{
			/* La cl‚ n'a pas ‚t‚ ‚cras‚, donc aucun d‚bordement normalement ;) */
			#ifdef LOG_FILE
			strcpy( buf_log, TAB8" - Cl‚ de controle intact."CRLF);
			#endif
		}
	}

	#ifdef LOG_FILE
	log_print(FALSE);
	#endif



	/* ------------------------ */
	/* On libŠre le bloc de RAM */
	/* ------------------------ */
	if( Mfree(adresse) != 0 )
	{
		#ifdef ALT_ERR_FREE_RAM
		form_alerte( 0,	ALT_ERR_FREE_RAM );
		#endif

		#ifdef LOG_FILE
		strcpy( buf_log, "ERREUR => reponse (Mfree) lib‚ration du bloc."CRLF);
		log_print(FALSE);
		#endif
	}
	else
	{

		RAM_nb_malloc--;

		if( RAM_nb_malloc==0 )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, TAB8"   (Plus de bloc en cours d'utilisation)"CRLF);
			#endif
		}

		else
		{
			#ifdef LOG_FILE
			sprintf( buf_log, TAB8"   (Reste %d bloc(s) en cours d'utilisation)"CRLF,RAM_nb_malloc);
			#endif
		}


		#ifdef LOG_FILE
		log_print(FALSE);
		#endif

	}


	return(0L);


}


#endif

