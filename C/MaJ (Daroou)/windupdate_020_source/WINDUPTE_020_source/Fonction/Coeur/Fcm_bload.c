/**[Fonction commune]***************/
/* Fonction GFA adapt‚ et am‚lior‚ */
/* 16/09/2001 # 11/01/2015         */
/***********************************/


#include "Coeur_define.c"




/* Prototype */
int32 Fcm_bload(const char *nom_fichier, const char * adresse, int32 saut, int32 nombre);


/* Fonction */
int32 Fcm_bload(const char *nom_fichier, const char * adresse, int32 saut, int32 nombre)
{

	int32	handle_fichier;
	int32	nombre_charger;
	int32	reponse=0;
	int32	dummy;



	#ifdef LOG_FILE
	sprintf( buf_log, TAB8"* Fcm_bload( {%s}, 0x%p, %ld, %ld )"CRLF, nom_fichier, adresse, saut, nombre );
	log_print( FALSE );
	#endif


	/* Ouverture du fichier */
	handle_fichier=Fopen(nom_fichier,S_READ);


	/* Si erreur on retourne l'erreur */
	if(handle_fichier<0)
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR Bload, handle=%ld"CRLF, handle_fichier );
		log_print( FALSE );
		#endif

		return(handle_fichier);
	}



	/* Si on doit se positioner dans le fichier */
	if( saut>0 )
	{
		reponse=Fseek(saut,handle_fichier,SEEK_SET);

		/* Si le saut a ‚chou‚ ou si le fichier est trop court */
		if( reponse != saut )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "ERREUR bload saut -> demand‚=%ld, -> reponse=%ld"CRLF, saut, reponse );
			log_print( FALSE );
			#endif

		 	return(-99);
		}
	}


	reponse=0;

	if( nombre>0 )
	{
		dummy=nombre;
		do
		{
			nombre_charger = Fread( handle_fichier, dummy, adresse );

/*			#ifdef LOG_FILE
			sprintf( buf_log, "Fread (%ld, %p)"CRLF, nombre_charger, adresse );
			log_print( FALSE );
			#endif
*/

			if( nombre_charger<0 )
			{
				#ifdef LOG_FILE
				sprintf( buf_log, "ERREUR bload Fread erreur (%ld)"CRLF, nombre_charger );
				log_print( FALSE );
				#endif
				reponse=nombre_charger;
				break;
			}


			if(nombre_charger==0 && dummy>0)
			{
				#ifdef LOG_FILE
				sprintf( buf_log, "ERREUR bload fin de fichier atteinte (restait … charger: %ld octets)"CRLF, dummy );
				log_print( FALSE );
				#endif

				dummy=0;
				reponse=-1;

			}
			else
			{
				dummy   = dummy   - nombre_charger;
				adresse = adresse + nombre_charger;
				reponse = reponse + nombre_charger;
			}

			/* On sait jamais, si on charge plus qu'il n'en faut ;-) */
			if( dummy < 0 )
			{
				#ifdef LOG_FILE
				sprintf( buf_log, "ERREUR, bload d‚passement de quantit‚ … charger, Stop bload, possible d‚bordement du buffer (surplus=%ld)"CRLF, dummy );
				log_print( FALSE );
				#endif

				dummy=0;
				reponse=-1;

			}

		} while( dummy );
	}




	/* totalit‚ du fichier */
	if(nombre==-1)
	{
		do
		{
			nombre_charger = Fread(handle_fichier,4096L,adresse);

/*			#ifdef LOG_FILE
			sprintf( buf_log, "Fread (%ld, %p)"CRLF, nombre_charger, adresse );
			log_print( FALSE );
			#endif
*/
			if( nombre_charger<0 )
			{
				#ifdef LOG_FILE
				sprintf( buf_log, "ERREUR bload Fread erreur (%ld)"CRLF, nombre_charger );
				log_print( FALSE );
				#endif
				reponse=nombre_charger;
				break;
			}

			adresse = adresse + nombre_charger;
			reponse = reponse + nombre_charger;

		} while(nombre_charger);
	}


	Fclose(handle_fichier);


	if( reponse>0 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, TAB8" - %ld octets charg‚s"CRLF, reponse );
		log_print( FALSE );
		#endif
	}


	return(reponse);


}

