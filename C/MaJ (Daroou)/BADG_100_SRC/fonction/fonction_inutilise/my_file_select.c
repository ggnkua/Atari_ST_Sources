/* **[Fonction Commune]******** */
/* * Fonction File Select     * */
/* * 25/01/2002 # 20/08/2003  * */
/* **************************** */

/* Cette fonction utilise la fonction AES et ne fait que  */
/* modifier le chemin re‡u en r‚ponse. La fonction retire */
/* simplement le masque de s‚lection                      */


VOID my_file_select(CHAR *chemin,CHAR *fichier,WORD *bouton,CHAR *titre)
{
/*
 * extern	WORD	aes_version;
 *
 */


	if( systeme.aes_version < 0x140 )
	{
		/* appel du s‚lecteur de fichier standard */
		fsel_input( chemin, fichier, bouton );
	}
	else
	{
		/* appel du s‚lecteur de fichier ‚tendu (TOS 1.4 mini) */
		fsel_exinput( chemin, fichier, bouton, titre );
	}

	/* on vire le mask pr‚sent dans le chemin */
	/* on se place … la fin de la chaŒne */
	chemin=chemin+strlen(chemin);

	/* on cherche '\' */
	while( *chemin != '\\' )
	{
		chemin--;
	}
	/* on arrete la chaine juste aprŠs '\' */
	chemin[1]=NULL;

#ifdef  NB_FENETRE
	Fcm_purge_aes_message();
#endif


}

