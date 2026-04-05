/* **[Fonction Commune]************* */
/* *  * */
/* * 21/02/2002  MaJ   14/02/2024  * */
/* ********************************* */


#ifndef __FCM_CONVERSION_ASCII_TO_LONG_C__
#define __FCM_CONVERSION_ASCII_TO_LONG_C__


int32 Fcm_conversion_ascii_to_long( const char *chaine )
{
	uint16	nb_digit;
	uint16	negatif;
	uint16  position;

#warning "ne plus utilser cette fonction, utilser atol()"

	FCM_LOG_PRINT1( "  * Fcm_conversion_ascii_to_long({%s})", chaine );


	/* on se positionne sur le d‚but de la chaŒne */
	position=0;
	nb_digit=0;
	negatif=FALSE;


	if( strlen(chaine) == 0 )
	{
		FCM_LOG_PRINT("    chaine vide");
		return(0L);
	}


	/* --- Nombre n‚gatif ? --- */
	if( chaine[0] == '-' )
	{
		negatif = TRUE;
		position = 1;
	}


	if( chaine[0] == '+' ) position=1;


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
	else
	{
		FCM_LOG_PRINT( "  ERREUR : chaine incorrect" );
	}


	if( nb_digit > 10 )
	{
		FCM_LOG_PRINT1( "  ERREUR : nombre trop grand (%d chiffres)", nb_digit);
		return(0L);
	}


	if( nb_digit == 0 )
	{
		FCM_LOG_PRINT( "  ERREUR : aucun chiffre trouv‚");
		return(0L);
	}



	{
		uint16	valeur;
		uint16	dummy;
		uint32	multiplicateur=1;
		int32  total=0;


		for( dummy=0; dummy<nb_digit; dummy++ )
		{
			valeur = chaine[position] - 0x30;	/* 0<=valeur<=9 */
			total = total + (int32)(valeur * multiplicateur);
			multiplicateur = multiplicateur * 10;
			position--;
		}

		FCM_LOG_PRINT2( "    total=(%ld) n‚gatif ?=%d", total, negatif);

		if( negatif )
		{
			return( -total );
		}

		return( total );

	}


}


#endif  /*   __FCM_CONVERSION_ASCII_TO_LONG_C__   */

