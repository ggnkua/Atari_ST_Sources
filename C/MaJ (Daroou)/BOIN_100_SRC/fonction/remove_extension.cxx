/* ****************************** */
/* * Fonction Remove Extension  * */
/* *  14/08/2002 # 14/08/2002   * */
/* ****************************** */

/* Cette fonction retire l'extension de la chaine */

VOID remove_extension( CHAR *chaine )
{

	CHAR	*pt_char;


	/* on se positionne sur la fin de la chaine */
	pt_char=chaine+strlen(chaine);
	do
	{
		/* on recherche le premier point '.' dans la chaine */
	} while( *pt_char-- != '.' && pt_char>chaine );

	pt_char++;

	if( *pt_char== '.' ) *pt_char=0;

}
