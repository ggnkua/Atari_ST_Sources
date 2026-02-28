/* ********************************* */
/* * Fonction de conversion valeur * */
/* * ascii en valeur 32bits        * */
/* * 21/02/2002 # 11/01/2015       * */
/* ********************************* */



#ifndef __Fcm_conversion_ascii_to_long__
#define __Fcm_conversion_ascii_to_long__



/* Prototype */
int32 Fcm_conversion_ascii_to_long( const char *chaine );


/* Fonction */
int32 Fcm_conversion_ascii_to_long( const char *chaine )
{

	uint16	nb_digit;
	uint16	negatif;
	uint16  position;



	#ifdef LOG_FILE
	sprintf( buf_log, TAB16"* Fcm_conversion_ascii_to_long({%s})"CRLF, chaine);
	log_print(FALSE);
	#endif


	/* on se positionne sur le d‚but de la chaŒne */
	position=0;
	nb_digit=0;
	negatif=FALSE;


	/* --- Nombre n‚gatif ? --- */
	if( chaine[0] == '-' )
	{
		negatif=TRUE;
		position=1;
	}


	if( chaine[0] == '+' )
	{
		position=1;
	}


	if( position < strlen(chaine) )
	{

		do
		{
			/* on compte le nombre de chiffre pr‚sent      */
			/* La recherche s'arrˆte … la fin de la chaŒne */
			/* ou au premier caractŠre non valide */
			if( chaine[position]>0x2F &&  chaine[position]<0x3a )
			{
				nb_digit++;
				position++;
			}
			else
			{
				break;
			}
		} while( chaine[position] );

		position--; /* correction de la post-incr‚mentration */
	}
#ifdef LOG_FILE
	else
	{
	sprintf( buf_log, "ERREUR conversion_ascii_to_long: chaine incorrect"CRLF );
	log_print(FALSE);
	}
#endif

	if( nb_digit > 9 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR !!! * conversion_ascii_to_long: nombre trop grand (%d chiffres)"CRLF, nb_digit);
		log_print(FALSE);
		#endif

		return(0L);
	}


	if( nb_digit == 0 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR !!! * conversion_ascii_to_long: aucun chiffre trouv‚"CRLF );
		log_print(FALSE);
		#endif

		return(0L);
	}


	{
		uint16	valeur;
		uint16	dummy;
		uint32	multiplicateur=1;
		uint32  total=0;


		for( dummy=0; dummy<nb_digit; dummy++ )
		{
			valeur = chaine[position] - 0x30;	/* 0<=valeur<=9 */
			total = total + (valeur * multiplicateur);
			multiplicateur = multiplicateur * 10;
			position--;
		}


		#ifdef LOG_FILE
		sprintf( buf_log, TAB16" - total=(%ld) n‚gatif ?=%d"CRLF, total, negatif );
		log_print(FALSE);
		#endif

		if( negatif )
		{
			return( -total );
		}

		return( total );

	}


}


#endif

