
/* **************************** */
/* * Fonction Majuscule       * */
/* * 11/05/2002 # 11/05/2002  * */
/* **************************** */

/* Cette fonction met la chaine en majuscule */

VOID majuscule( CHAR *chaine )
{

	CHAR	*pt_char;
	CHAR	*pt_write;

	/* on se positionne sur le d‚but du chemin */
	pt_char=chaine;
	pt_write=chaine;

	do
	{
		/* on recherche les anti-slash jusqu'… la fin de la */
		/* chaŒne, … chaque fois sa position est sauv‚      */
		if(*pt_char>0x60 && *pt_char<0x7c )	*pt_write=(*pt_char-32);

		pt_write++;

	} while( *pt_char++ );


}
