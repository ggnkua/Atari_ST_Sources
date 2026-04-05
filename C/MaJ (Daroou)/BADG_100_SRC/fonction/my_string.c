/* ****************************** */
/* * Fonction my_string()       * */
/* *  14/08/2002 # 14/08/2002   * */
/* ****************************** */


/*
 * Adaptation de la fonction GFA en C
 */

VOID my_string( CHAR *chaine, CHAR *caractere, ULONG nombre )
{
	while( nombre-- )
	{
		strcat( chaine, caractere );
	}
}

