/* ******************************* */
/* * Fonction Remove Chemin      * */
/* *  02/07/2017 MaJ 02/07/2017  * */
/* ******************************* */


#ifndef ___Fcm_remove_chemin___
#define ___Fcm_remove_chemin___



/* Cette fonction retire le chemin de la chaine  */
/* il restera que le nom du fichier et extension */
void Fcm_remove_chemin( char *chaine );


void Fcm_remove_chemin( char *chaine )
{

	char	*pt_char;


	/* on se positionne sur la fin de la chaine */
	pt_char=chaine+strlen(chaine);
	do
	{
		/* on recherche le premier point '\' dans la chaine */
	} while( *pt_char-- != '\\' && pt_char>chaine );

	/* on copie le nom du fichier et extension au debut de la chaine */
	/* [2] pour passer la post-decrementation et le '\'              */
	strcpy( chaine, &pt_char[2] );
	
	return;

}

#endif /* ___Fcm_remove_chemin___ */

