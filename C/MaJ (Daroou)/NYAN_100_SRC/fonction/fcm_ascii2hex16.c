/* -------------------------------------------------------------------- */
/* convertit une chaine ascii au format hexadecimal en valeur numerique */
/* '1f4d' (4 octets) devient 0x1f4d (2 octets)                          */
/* la chaine peut contenir de 0 a 4 caractere et doit etre au format C  */
/* (terminer par un caractere '\0')                                     */
/* -------------------------------------------------------------------- */
/* retourne 0 si la conversion a eu lieu ou un code d'erreur:           */
/* 1 -> la chaine contient plus de 4 caractere ou aucun                 */
/* 2 -> un caractere non hexadecimal a ete trouve dans la chaine        */
/* -------------------------------------------------------------------- */



#ifndef __ascii2hex16__
#define __ascii2hex16__


uint16 Fcm_ascii2hex16( const char *strhex, uint16 *valeur_numerique);



uint16 Fcm_ascii2hex16( const char *strhex, uint16 *valeur_numerique)
{
    uint16 nombre_digit;
	uint16 valeur_digit;
    uint16 idx_boucle;


	*valeur_numerique = 0;

	nombre_digit = strlen(strhex);
	/*printf("\nchaine={%s} \n", strhex);*/
	/*printf("nombre_digit=%d \n", nombre_digit);*/

	/* 4 caracteres max pour une valeur 16 bits */
	if (nombre_digit > 4  ||  nombre_digit == 0)
	{
		return 1; /* erreur */
	}

    for (idx_boucle=0; idx_boucle<nombre_digit; idx_boucle++)
    {
		/* chaque digit hexa represente 4 bits                  */
		/* on decale de 4 bits pour acceuillir le nouveau digit */
		/* dans la premiere boucle, valeur_numerique vaut 0     */
		*valeur_numerique = *valeur_numerique << 4;  

		/* on verifie le contenu de la valeur hexa */
		if( strchr( "0123456789ABCDEFabcdef", strhex[idx_boucle] ) == NULL )
		{
			return 2; /* erreur */
		}

		/* on convertit le code ASCII en numerique */
		if (strhex[idx_boucle] > 96)  /* 'a' => ASCII 97 */
		{
			valeur_digit = strhex[idx_boucle] - 'a' + 10; /* +10 car 'a' vaut 10 en decimal */
		}
		else if (strhex[idx_boucle] > 64)  /* 'A' => ASCII 65 */
		{
			valeur_digit = strhex[idx_boucle] - 'A' + 10;
		}
		else            /* '0' => ASCII 48 */
		{
			valeur_digit = strhex[idx_boucle] - '0';
		}

		*valeur_numerique = *valeur_numerique + valeur_digit;

        /*printf("strhex[%d]=%d  valeur_digit=%d   valeur_numerique=%x \n", idx_boucle, strhex[idx_boucle], valeur_digit, *valeur_numerique);*/

    } /* end for (idx_boucle=0; idx_boucle<nb_digit; idx_boucle++) */


	return 0; /* pas d'erreur */
}


#endif /*  __ascii2hex16__ */

