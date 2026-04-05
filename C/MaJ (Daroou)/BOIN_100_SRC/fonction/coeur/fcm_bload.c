/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 16/09/2001 MaJ 05/03/2024 * */
/* ***************************** */



/*
 * Fonction GFA adapt‚
 *
 */


int32 Fcm_bload( const char *nom_fichier, const char *adresse, int32 saut, int32 nombre )
{
	int32	handle_fichier;
	int32	reponse;

#ifdef LOG_FILE
	uint32  timer=Fcm_get_timer();
#endif


	FCM_LOG_PRINT4(CRLF"* Fcm_bload( {%s}, %p, %ld, %ld )", nom_fichier, adresse, saut, nombre );
//FCM_CONSOLE_DEBUG3("* Fcm_bload( {}, adr=%p, saut=%ld, nombre=%ld )", adresse, saut, nombre );
//FCM_CONSOLE_DEBUG1("  file{%s}", nom_fichier );


	if( nombre == -1 )
	{
		FCM_LOG_PRINT("-1 pour nombre n'est plus valide par securite");
		FCM_CONSOLE_DEBUG("Fcm_bload() : -1 pour nombre n'est plus valide par securite");

		return(-99);
	}

	if( nombre == 0 )
	{
		FCM_LOG_PRINT("nombre == 0");
		FCM_CONSOLE_DEBUG("Fcm_bload() : nombre == 0");

		return(-99);
	}


	/* Ouverture du fichier */
	handle_fichier = Fopen( nom_fichier, S_READ );

	/* Si erreur on retourne l'erreur */
	if( handle_fichier < 0 )
	{
		FCM_LOG_PRINT1("ERREUR Bload, handle=%ld", handle_fichier );
		FCM_CONSOLE_DEBUG1("Fcm_bload() : erreur ouverture fichier (%ld)", handle_fichier);

		return( handle_fichier );
	}


	/* Si on doit se positioner dans le fichier */
	if( saut > 0 )
	{
		reponse = Fseek( saut, handle_fichier, SEEK_SET );

		/* Si le saut a ‚chou‚ ou si le fichier est trop court */
		if( reponse != saut )
		{
			FCM_LOG_PRINT2("ERREUR bload saut -> demand‚=%ld, -> reponse=%ld", saut, reponse );
			FCM_CONSOLE_DEBUG2("Fcm_bload() : erreur valeur de saut %ld (%ld)", saut, reponse);

		 	return(-99);
		}
	}


	{
		int32	nombre_charger;
		int32   sizetoload;

		reponse = 0;

		do
		{
			/* on charge par bloc de 32 ko pour ne pas bloquer le systŠme */
			sizetoload = MIN( nombre, 32768L );
			evnt_timer(20);

			nombre_charger = Fread( handle_fichier, sizetoload, adresse );
//FCM_CONSOLE_DEBUG1("Fcm_bload() : nombre_charger %ld", nombre_charger);

			if( nombre_charger < 0 )
			{
				FCM_LOG_PRINT1("ERREUR bload Fread erreur (%ld)", nombre_charger );
				FCM_CONSOLE_DEBUG1("Fcm_bload() : erreur Fread (%ld)", nombre_charger);

				reponse = nombre_charger;
				break;
			}


			if( nombre_charger == 0   &&   nombre > 0 )
			{
				FCM_LOG_PRINT1("ERREUR bload fin de fichier atteinte (restait … charger: %ld octets)", nombre );
				FCM_CONSOLE_DEBUG1("Fcm_bload() : fin de fichier atteinte (restait … charger: %ld octets)", nombre );

				nombre = 0;
				reponse = -1;
			}
			else
			{
				nombre  = nombre  - nombre_charger;
				adresse = adresse + nombre_charger;
				reponse = reponse + nombre_charger;
			}

			/* On sait jamais, si on charge plus qu'il n'en faut ;-) */
			if( nombre < 0 )
			{
				FCM_LOG_PRINT1("ERREUR, bload d‚passement de quantit‚ … charger, Stop bload, possible d‚bordement du buffer (surplus=%ld)", nombre );
				FCM_CONSOLE_DEBUG1("Fcm_bload() : d‚passement de quantit‚ … charger, Stop bload, possible d‚bordement du buffer (surplus=%ld)", nombre );

				nombre = 0;
				reponse = -1;
			}

		} while( nombre );
	}


	Fclose(handle_fichier);


	if( reponse > 0 )
	{
		FCM_LOG_PRINT2("  %ld octets charg‚s en %ld/200Šme seconde(s)", reponse, (Fcm_get_timer()-timer) );
//FCM_CONSOLE_DEBUG1("Fcm_bload() : %ld octets charg‚s", reponse);
	}


	return( reponse );


}

