/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 01/03/2015 MaJ 02/03/2024 * */
/* ***************************** */



#ifndef __FCM_CHECK_RSC_ALERTE_C__
#define __FCM_CHECK_RSC_ALERTE_C__


/*
 * 
 * - Fcm_check_rsc_alerte()
 *
 * fonctions internes :
 * - Fcm_check_g_string()
 * - Fcm_check_dial_alerte()
 *
 */


/* Prototype */
int16 Fcm_check_g_string( char *alerte_string );
int16 Fcm_check_dial_alerte( OBJECT *adr_formulaire );



int16 Fcm_check_rsc_alerte( void )
{
	int16   erreur = 0;


	FCM_LOG_PRINT("* Fcm_check_rsc_alerte()");


	FCM_LOG_PRINT("  - Controle DL_ALERTE_COEUR");
//FCM_CONSOLE_DEBUG("  - Controle DL_ALERTE_COEUR");

	erreur = Fcm_check_dial_alerte( Fcm_adr_RTREE[DL_ALERTE_COEUR] );

	FCM_LOG_PRINT1("=> erreur=%d"CRLF"  - Controle DL_ALERTE_APPLI", erreur );
//FCM_CONSOLE_DEBUG("  - Controle DL_ALERTE_APPLI");

	erreur = Fcm_check_dial_alerte( Fcm_adr_RTREE[DL_ALERTE_APPLI] );

	FCM_LOG_PRINT1("=> erreur=%d  "CRLF" FIN Fcm_check_rsc_alerte()"CRLF, erreur );


	return(erreur);

}




int16 Fcm_check_dial_alerte( OBJECT *adr_formulaire )
{
	int16   objet_premier_enfant;
	int16   objet_next;
	int16   erreur;


	/* ob_head pointe sur le premier enfant */
	/* ob_tail pointe sur le dernier enfant */
	objet_premier_enfant = adr_formulaire[0].ob_head;

	FCM_LOG_PRINT2("    adr_formulaire=0x%p , objet_premier_enfant=(%d)", adr_formulaire, objet_premier_enfant);

	if( objet_premier_enfant == -1 )
	{
		form_alert(1, "[3][RSC ERROR|DL_ALERTE_xxxxx erreur|DL_ALERTE_xxxxx error][  #1 Hmmmm ]");
		return(-1);
	}


	objet_next = objet_premier_enfant;
	erreur = 0;

	do
	{
		if( adr_formulaire[objet_next].ob_type != G_STRING )
		{
			erreur = 1;

			FCM_LOG_PRINT2("-> #ERREUR# objet_next=%02d - erreur=%d", objet_next, erreur);
			FCM_CONSOLE_DEBUG1("Fcm_check_dial_alerte() objet %d n'est pas un G_STRING", objet_next);
		}
		else
		{
			erreur = Fcm_check_g_string( adr_formulaire[objet_next].ob_spec.free_string );

			objet_next = adr_formulaire[objet_next].ob_next;
		}

		/* Quand il n'y a plus d'objet, objet_next pointera sur l'objet parent */
		/* L'objet parent est le dialogue (index 0) */
	} while( objet_next != 0   &&   erreur == 0 );



	if( erreur != 0 )
	{
		form_alert(1, "[3][RSC ERROR|des erreurs trouv‚e(s)|dans les textes alertes|many error found in|alert text][ check RSC ]");
		return(erreur);
	}


	return(0);

}




int16 Fcm_check_g_string( char *alerte_string )
{
	int16 idx;
	int16 end;


//FCM_LOG_PRINT1("=> Fcm_check_g_string {%s}", alerte_string );

	/* -------------------------------------------------------------------- */
	/* v‚rification icone                                                   */
	/* -------------------------------------------------------------------- */
	if( alerte_string[0] != '['  ||  alerte_string[2] != ']'  ||  alerte_string[1] < '0'  ||  alerte_string[1] > '3' )
	{
		FCM_LOG_PRINT1("Erreur {%s}", alerte_string );
		FCM_LOG_PRINT("Erreur Format icone");
		FCM_CONSOLE_DEBUG("Fcm_check_g_string() : Erreur Format icone");

		return(-1);
	}


	end = strlen(alerte_string);

	/* -------------------------------------------------------------------- */
	/* v‚rification texte alerte                                            */
	/* -------------------------------------------------------------------- */
	{
		int16 nbcar = 0;
		int16 totalcar = 0;
		int16 champ = 0;
		int16 fin = 0;
		int16 erreur = 0;

		idx=4; /* idx premier caractere */

		do
		{
			if( alerte_string[idx] != '|'   &&   alerte_string[idx] != ']' )
			{
				nbcar++;
				idx++; 
			}
			else
			{
				champ++;

				if( nbcar > 30 )
				{
					erreur = 9;

					FCM_LOG_PRINT("rreur Taille de champ sup‚rieur … 30 caractŠres");
					FCM_CONSOLE_DEBUG("Fcm_check_g_string() : Erreur Taille de champ sup‚rieur … 30 caractŠres");
				}

				if( alerte_string[idx] == ']' )
				{
					fin = 1;
				}

				if( champ > 5 )
				{
					erreur = 2;

					FCM_LOG_PRINT("Erreur Nombre de champ sup‚rieur … 5");
					FCM_CONSOLE_DEBUG("Fcm_check_g_string() : Erreur Nombre de champ sup‚rieur … 5");
				}

				idx++;
				totalcar = totalcar + nbcar;
				nbcar = 0;
			}

			/* fin de chaine ? */
			if( idx == end )
			{
				erreur = 3;

				FCM_LOG_PRINT("Erreur Format incomplet, balise ']' ?");
				FCM_CONSOLE_DEBUG("Fcm_check_g_string() : balise ']' absente");
			}

		} while( fin == 0   &&   erreur == 0 );


		totalcar = totalcar + nbcar;

		if( totalcar == 0 )
		{
			erreur=8;

			FCM_LOG_PRINT("Erreur aucun caractŠre ?");
			FCM_CONSOLE_DEBUG("Fcm_check_g_string() : taille alerte nulle");
		}

		if( erreur != 0 )
		{
			FCM_LOG_PRINT1("Erreur {%s}", alerte_string );
			return(erreur);
		}
	}


	/* -------------------------------------------------------------------- */
	/* v‚rification des boutons                                             */
	/* -------------------------------------------------------------------- */
	{
		int16 nbcar = 0;
		int16 totalcar = 0;
		int16 champ = 0;
		int16 fin= 0;
		int16 erreur = 0;


		if( alerte_string[idx] != '[' )
		{
			erreur = 11;
		}
		else
		{
			idx++;

			do
			{
				if( alerte_string[idx] != '|'   &&   alerte_string[idx] != ']' )
				{
					nbcar++;
					idx++; 
				}
				else
				{
					champ++;

					if( nbcar > 10 )
					{
						erreur = 19;

						FCM_LOG_PRINT("Erreur texte bouton sup‚rieur … 10 caractŠres");
						FCM_CONSOLE_DEBUG("Fcm_check_g_string() : taille bouton > 10");
					}

					if( alerte_string[idx] == ']' )
					{
						fin = 1;
					}

					if( champ > 3 )
					{
						erreur = 12;

						FCM_LOG_PRINT("Erreur maximum 3 boutons");
						FCM_CONSOLE_DEBUG("Fcm_check_g_string() : plus de 3 boutons ?");
					}

					idx++;
					totalcar = totalcar + nbcar;
					nbcar = 0;
				}

				if( fin == 0   &&   idx == end )
				{
					erreur=13;

					FCM_LOG_PRINT("Erreur Format, balise ']' bouton ?");
					FCM_CONSOLE_DEBUG("Fcm_check_g_string() :  bouton pas de balise ']'");
				}

			} while( fin == 0   &&   erreur == 0 );


			totalcar = totalcar + nbcar;

			if( totalcar == 0 )
			{
				erreur=18;

				FCM_LOG_PRINT("Erreur aucun caractŠre bouton ?");
				FCM_CONSOLE_DEBUG("Fcm_check_g_string() :  aucun caractere pour les boutons ?");
			}
		}

		if( erreur != 0 )
		{
			FCM_LOG_PRINT1("Erreur {%s}", alerte_string);
			return(erreur);
		}
	}


	return(0);

}


#endif /* __FCM_CHECK_RSC_ALERTE_C__ */

