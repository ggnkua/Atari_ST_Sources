/* ******************************** */
/* *     Fonction LibŠre RAM      * */
/* *   11/05/2002 MaJ 16/04/2024  * */
/* ******************************** */


#ifndef __FCM_LIBERE_RAM_C__
#define __FCM_LIBERE_RAM_C__


#include "fcm_reserve_ram.h"




int32 Fcm_libere_ram( uint32 adresse )
{


	int16	index_table_pointeur;
	uint32	*pt_get_key;



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF""CRLF""TAB8"* Fcm_libere_ram(%08lx)"CRLF, adresse);
	log_print(FALSE);
	#endif


	/* ---------------------------------------------------------- */
	/* Liste des blocs memoires utilise, uniquement en mode DEBUG */
	/* ---------------------------------------------------------- */
	#ifdef LOG_FILE
	if( adresse == FCM_LIBERE_RAM_CHECK )
	{
		{
			int16 idx;
			int16 bloc_present=FALSE;

			strcpy( buf_log, TAB8"### Vérification de bloc memoire encore utilise ###"CRLF""TAB8);
			log_print(FALSE);


			for( idx=0; idx<RAM_MAX_POINTEUR; idx++ )
			{
				if( RAM_table_pointeur[idx] != 0 )
				{
					bloc_present=TRUE;
					sprintf( buf_log, "[%d]", idx);
					log_print(FALSE);
				}
			}
			if( bloc_present==TRUE )
			{
				sprintf( buf_log, " ce bloc est encore en service"CRLF""CRLF);
				log_print(FALSE);
			}
			else
			{
				sprintf( buf_log, "plus aucun bloc en service"CRLF""CRLF);
				log_print(FALSE);
			}

		}
		return( FALSE );
	}
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
	pt_get_key=(uint32 *)RAM_table_key[index_table_pointeur];


	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" - Controle de la cl‚ : adresse cl‚=%08lx (offset=+%ld)"CRLF, (uint32)pt_get_key, ((uint32)pt_get_key-adresse) );
	log_print(FALSE);
	#endif



	if( pt_get_key[0] != 0x12345678   ||   pt_get_key[1] != 0x87654321 )
	{
#ifdef LOG_FILE
strcpy( buf_log, "ERREUR !!! => Cl‚ de controle ‚cras‚ ! d‚bordement de bloc !!!"CRLF);
log_print(FALSE);
#endif
		FCM_CONSOLE_DEBUG2("Fcm_libere_ram() : Controle de la cl‚ : adresse cl‚=%08lx (offset=+%ld)", (uint32)pt_get_key, ((uint32)pt_get_key-adresse) );
		FCM_CONSOLE_DEBUG2("Fcm_libere_ram() : pt_get_key[0]=%lx pt_get_key[1]=%lx", pt_get_key[0], pt_get_key[1] );
		FCM_CONSOLE_DEBUG("Fcm_libere_ram() : Cl‚ de controle ‚cras‚ ! d‚bordement de bloc");
		evnt_timer(8000);
	}
	else
	{
		/* La cl‚ n'a pas ‚t‚ ‚cras‚, donc aucun d‚bordement normalement ;) */
#ifdef LOG_FILE
strcpy( buf_log, TAB8" - Cl‚ de controle intact."CRLF);
log_print(FALSE);
#endif
//FCM_CONSOLE_DEBUG("Fcm_libere_ram() : Cl‚ de controle intact.");
	}





	{
		int32 reponse;


FCM_LOG_PRINT1(CRLF">> Mfree( $%08lx )", adresse );

		reponse = Mfree(adresse);

FCM_LOG_PRINT1(">> Reponse = %ld"CRLF, reponse );

		/* ------------------------ */
		/* On libŠre le bloc de RAM */
		/* ------------------------ */
		if( reponse != 0 )
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
				log_print(FALSE);
				#endif
			}

			else
			{
				#ifdef LOG_FILE
				sprintf( buf_log, TAB8"   (Reste %d bloc(s) en cours d'utilisation)"CRLF,RAM_nb_malloc);
				log_print(FALSE);
				#endif

				#ifdef LOG_FILE
				{
					int16 idx;

					for( idx=0; idx<RAM_MAX_POINTEUR; idx++ )
					{
						if( RAM_table_pointeur[idx] != 0 )
						{
							sprintf( buf_log, "[%d]", idx);
							log_print(FALSE);
						}
					}
				}
				sprintf( buf_log, " bloc encore en service"CRLF);
				log_print(FALSE);
				#endif

			}


/*		#ifdef LOG_FILE
		log_print(FALSE);
		#endif*/

		}
	}


	return(0L);


}


#endif   /*   __FCM_LIBERE_RAM_C__   */

