/* **[Fonction commune]********* */
/* *                           * */
/* * 01/03/2015 MaJ 03/04/2015 * */
/* ***************************** */



#ifndef __Fcm_check_rsc_alerte__
#define __Fcm_check_rsc_alerte__





/* Prototype */
int16 Fcm_check_rsc_alerte( void );
int16 Fcm_check_g_string( char *alerte_string );




/* Fonction */
int16 Fcm_check_rsc_alerte( void )
{
	int16   objet_next, /*objet_dernier_enfant,*/objet_premier_enfant;
	int16   reponse=0;
	int16   erreur=0;
	OBJECT *adr_formulaire=0;


	#ifdef LOG_FILE
	sprintf( buf_log, "## Fcm_check_rsc_alerte()"CRLF);
	log_print( FALSE );
	#endif






	reponse = rsrc_gaddr( R_TREE, DL_ALERTE_COEUR, &adr_formulaire );


	#ifdef LOG_FILE
	sprintf( buf_log, "adr_formulaire=%p, &adr_formulaire=%p"CRLF, adr_formulaire, &adr_formulaire);
	log_print( FALSE );
	#endif

	if( reponse==0 || adr_formulaire<(OBJECT *)0 )
	{
		form_alert(1, "[3][RSC ERROR|DL_ALERTE_COEUR absent|DL_ALERTE_COEUR not found][  Hmmmm ]");
		return(-1);
	}

	objet_premier_enfant=(adr_formulaire)->ob_head;
/*	objet_dernier_enfant=(adr_formulaire)->ob_tail;*/


	#ifdef LOG_FILE
	sprintf( buf_log, "objet_premier_enfant=%02d"CRLF, objet_premier_enfant);
	log_print( FALSE );
	#endif


	if( objet_premier_enfant == -1 )
	{
		form_alert(1, "[3][RSC ERROR|DL_ALERTE_COEUR erreur|DL_ALERTE_COEUR error][  #1 Hmmmm ]");
		return(-1);
	}


	objet_next = objet_premier_enfant;


	do
	{

		if( (adr_formulaire+objet_next)->ob_type != G_STRING )
		{
			erreur=1;

			#ifdef LOG_FILE
			sprintf( buf_log, "-> objet_next=%02d - erreur=%d"CRLF, objet_next, erreur);
			log_print( FALSE );
			#endif
		}
		else
		{

			#ifdef LOG_FILE
			sprintf( buf_log, "-> objet_next=%02d - erreur=%d"CRLF, objet_next, erreur);
			log_print( FALSE );
			#endif

			erreur=Fcm_check_g_string( (adr_formulaire+objet_next)->ob_spec.free_string );


			objet_next=(adr_formulaire+objet_next)->ob_next;

			#ifdef LOG_FILE
			sprintf( buf_log, "#----------> objet_next=%02d - erreur=%d"CRLF, objet_next, erreur);
			log_print( FALSE );
			#endif
		}


	} while( objet_next!=0 && erreur==0 );


	if(erreur!=0)
	{
		form_alert(1, "[3][RSC ERROR|des erreurs trouv‚e(s)|dans les textes alertes|many error found in|alert text][ check RSC ]");
		return(erreur);
	}















	reponse = rsrc_gaddr( R_TREE, DL_ALERTE_APPLI, &adr_formulaire );


	#ifdef LOG_FILE
	sprintf( buf_log, "adr_formulaire=%p, &adr_formulaire=%p"CRLF, adr_formulaire, &adr_formulaire);
	log_print( FALSE );
	#endif

	if( reponse==0 || adr_formulaire<(OBJECT *)0 )
	{
		form_alert(1, "[3][RSC ERROR|DL_ALERTE_APPLI absent|DL_ALERTE_APPLI not found][  Hmmmm ]");
		return(-1);
	}

	objet_premier_enfant=(adr_formulaire)->ob_head;
/*	objet_dernier_enfant=(adr_formulaire)->ob_tail;*/


	#ifdef LOG_FILE
	sprintf( buf_log, "objet_premier_enfant=%02d"CRLF, objet_premier_enfant);
	log_print( FALSE );
	#endif


	if( objet_premier_enfant == -1 )
	{
		form_alert(1, "[3][RSC ERROR|aucune alerte trouv‚][  #1 Hmmmm ]");
		return(-1);
	}


	objet_next = objet_premier_enfant;


	do
	{

		if( (adr_formulaire+objet_next)->ob_type != G_STRING )
		{
			erreur=1;

			#ifdef LOG_FILE
			sprintf( buf_log, "-> objet_next=%02d - erreur=%d"CRLF, objet_next, erreur);
			log_print( FALSE );
			#endif
		}
		else
		{

			#ifdef LOG_FILE
			sprintf( buf_log, "-> objet_next=%02d - erreur=%d"CRLF, objet_next, erreur);
			log_print( FALSE );
			#endif

			erreur=Fcm_check_g_string( (adr_formulaire+objet_next)->ob_spec.free_string );


			objet_next=(adr_formulaire+objet_next)->ob_next;

			#ifdef LOG_FILE
			sprintf( buf_log, "#----------> objet_next=%02d - erreur=%d"CRLF, objet_next, erreur);
			log_print( FALSE );
			#endif
		}


	} while( objet_next!=0 && erreur==0 );


	if(erreur!=0)
	{
		form_alert(1, "[3][RSC ERROR|des erreurs trouv‚e(s)|dans les textes alertes|many error found in|alert text][ check RSC ]");
		return(erreur);
	}







	return(0);


}


















/* Fonction */
int16 Fcm_check_g_string( char *alerte_string )
{

	int16 index;
	int16 end=strlen(alerte_string);



	#ifdef LOG_FILE
	sprintf( buf_log, "# Fcm_check_g_string( %s )"CRLF, alerte_string );
	log_print( FALSE );
	#endif


	/* -------------------------------------------------------------------- */
	/* v‚rification icone                                                   */
	/* -------------------------------------------------------------------- */
	if( alerte_string[0]!='[' || alerte_string[2]!=']' || alerte_string[1]<'0' || alerte_string[1]>'3' )
	{
#ifdef LOG_FILE
sprintf( buf_log, "!!! Erreur Format icone"CRLF );
log_print( FALSE );
#endif
		return(-1);
	}




	/* -------------------------------------------------------------------- */
	/* v‚rification texte alerte                                            */
	/* -------------------------------------------------------------------- */
	{
		int16 nbcar=0;
		int16 totalcar=0;
		int16 champ=0;
		int16 fin=0;
		int16 erreur=0;

		index=4;

		do
		{

/*			#ifdef LOG_FILE
			sprintf( buf_log, "%c", alerte_string[index] );
			log_print( FALSE );
			#endif*/

			if( alerte_string[index]!='|' && alerte_string[index]!=']' )
			{
				nbcar++;
				index++; 
			}
			else
			{

/*				#ifdef LOG_FILE
				sprintf( buf_log, " %d"CRLF, nbcar );
				log_print( FALSE );
				#endif*/

				champ++;

				if( nbcar>30 )
				{
					/* erreur */
					erreur=9;

#ifdef LOG_FILE
sprintf( buf_log, "!!! Erreur Taille de champ sup‚rieur … 30 caractŠres"CRLF );
log_print( FALSE );
#endif

				}

				if( alerte_string[index]==']' )
				{
					fin=1;
				}

				if( champ>5 )
				{
					/* erreur*/
					erreur=2;

#ifdef LOG_FILE
sprintf( buf_log, "!!! Erreur Nombre de champ sup‚rieur … 5"CRLF );
log_print( FALSE );
#endif

				}

				index++;
				totalcar=totalcar+nbcar;
				nbcar=0;

			}

			if( index==end )
			{
				/* erreur */
				erreur=3;

#ifdef LOG_FILE
sprintf( buf_log, "!!! Erreur Format incomplet, balise fermeture ?"CRLF );
log_print( FALSE );
#endif

			}

		} while( fin==0 && erreur==0 );


		totalcar=totalcar+nbcar;

		if(totalcar==0)
		{
			erreur=8;

#ifdef LOG_FILE
sprintf( buf_log, "!!! Erreur aucun caractŠre ???"CRLF );
log_print( FALSE );
#endif
		}


		if(erreur!=0)
		{
			return(erreur);
		}


	}


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"----------------------------"CRLF );
	log_print( FALSE );
	#endif


	/* -------------------------------------------------------------------- */
	/* v‚rification des boutons                                             */
	/* -------------------------------------------------------------------- */
	{
		int16 nbcar=0;
		int16 totalcar=0;
		int16 champ=0;
		int16 fin=0;
		int16 erreur=0;


		if( alerte_string[index]!='[' )
		{
			erreur=11;
		}
		else
		{
			index++;


			do
			{

/*				#ifdef LOG_FILE
				sprintf( buf_log, "%c", alerte_string[index] );
				log_print( FALSE );
				#endif*/

				if( alerte_string[index]!='|' && alerte_string[index]!=']' )
				{
					nbcar++;
					index++; 
				}
				else
				{

/*					#ifdef LOG_FILE
					sprintf( buf_log, " %d"CRLF, nbcar );
					log_print( FALSE );
					#endif*/

					champ++;

					if( nbcar>10 )
					{
						/* erreur */
						erreur=19;

#ifdef LOG_FILE
sprintf( buf_log, "!!! Erreur texte bouton sup‚rieur … 10 caractŠres"CRLF );
log_print( FALSE );
#endif

					}

					if( alerte_string[index]==']' )
					{
						fin=1;
					}

					if( champ>3 )
					{
						/* erreur*/
						erreur=12;

#ifdef LOG_FILE
sprintf( buf_log, "!!! Erreur maximum 3 boutons"CRLF );
log_print( FALSE );
#endif

					}

					index++;
					totalcar=totalcar+nbcar;
					nbcar=0;

				}

				if( fin==0 && index==end )
				{
					/* erreur */
					erreur=13;

#ifdef LOG_FILE
sprintf( buf_log, "!!! Erreur Format, balise de fin bouton ?"CRLF );
log_print( FALSE );
#endif

				}

			} while( fin==0 && erreur==0 );


			totalcar=totalcar+nbcar;

			if(totalcar==0)
			{
				erreur=18;

#ifdef LOG_FILE
sprintf( buf_log, "!!! Erreur aucun caractŠre bouton ?"CRLF );
log_print( FALSE );
#endif

			}
		}


		if(erreur!=0)
		{
			return(erreur);
		}


	}


	return(0);


}






#endif /* __Fcm_check_rsc_alerte__ */

