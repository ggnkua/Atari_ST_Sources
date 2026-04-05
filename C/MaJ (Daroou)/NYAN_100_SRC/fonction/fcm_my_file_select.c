/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 21/01/2013 MaJ 22/02/2024 * */
/* ***************************** */



#ifndef ___FCM_MY_FILE_SELECT_C___
#define ___FCM_MY_FILE_SELECT_C___


/*
 * 09/03/2024: changement de méthode pour le titre du selecteur de fichier,
 * au lieu de transmettre un index vers une STRING du RSC, il faut transmettre
 * un pointeur sur le titre, afin de rendre indépendant du RSC cette fonction.
 * 
 *
 */




/* c'est la meme routine que Fcm_file_select() sauf que le fichier n'est pas     */
/* ajouter au chemin a la fin, ne sachant plus si Fcm_file_select() est utilisé  */
/* par d'autre appli, je l'ai cloné. Fcm_file_select() n'est plus utilisé...     */


/* Fcm_file_select()    reponse chemin = chemin + fichier  (obsolete)  */
/* Fcm_my_file_select() reponse chemin = chemin  et fichier = fichier  */


#define FSL_TAILLE_CHEMIN  (FCM_TAILLE_CHEMIN)
#define FSL_TAILLE_FICHIER (FCM_TAILLE_FICHIER)
#define FSL_TAILLE_TITRE   (32)
#define FSL_TAILLE_MASQUE  (5)     /* '*.???' */


#define FSL_ERROR_BUFFER_TOO_SMALL  (-5001)
#define FSL_ERROR_BUFFER_CRUSHED    (-5002)
#define FSL_ERROR_FSEL_INPUT        (-5003)
/*#define FSL_ERROR_FILE_NOT_FOUND    (-5004)*/ /* possible ? */



/* -----------------------------------------

   reponse:

   FALSE   : selecteur de fichier Annul‚
			 chemin et fichier ne sont pas modifier

   TRUE    : selecteur de fichier Valid‚
             chemin et fichier contiennent la reponse

   negatif : Erreur

   ----------------------------------------- */



/* Prototype */
//int16 Fcm_my_file_select( int16 titre_rsc, uint16 size_chemin, uint16 size_fichier, char *chemin, char *fichier, const char *masque);
int16 Fcm_my_file_select( char *titre_fsel, uint16 size_chemin, uint16 size_fichier, char *chemin, char *fichier, const char *masque);






/* Fonction */
int16 Fcm_my_file_select( char *titre_fsel, uint16 size_chemin, uint16 size_fichier, char *chemin, char *fichier, const char *masque)
{
	char fsl_titre[FSL_TAILLE_TITRE];
	char fsl_chemin[FSL_TAILLE_CHEMIN];
	char fsl_fichier[FSL_TAILLE_FICHIER];


	FCM_LOG_PRINT6("# Fcm_my_file_select(%p, %d, %d, %p, %p, %p)", titre_fsel, size_chemin, size_fichier, chemin, fichier, masque );
	FCM_LOG_PRINT1("  chemin={%s}", chemin );
	FCM_LOG_PRINT1("  fichier={%s}", fichier );
	FCM_LOG_PRINT1("  masque={%s}", masque );


	/* On verifie la taille du chemin (-5 pour le masque) */
	if( strlen(chemin) > (FSL_TAILLE_CHEMIN-5) )
	{
		FCM_LOG_PRINT("ERREUR : Fcm_my_file_select() taille buffer trop petit pour le chemin");
		FCM_CONSOLE_DEBUG("ERREUR : Fcm_my_file_select() taille buffer trop petit pour le chemin");
		FCM_CONSOLE_DEBUG1("%ld char}", strlen(chemin));

		return(FSL_ERROR_BUFFER_TOO_SMALL);
	}


	/* On verifie la taille du fichier */
	if( strlen(fichier) > FSL_TAILLE_FICHIER )
	{
		FCM_LOG_PRINT("ERREUR : Fcm_my_file_select() taille buffer trop petit pour le fichier");
		FCM_CONSOLE_DEBUG("ERREUR : Fcm_my_file_select() taille buffer trop petit pour le fichier");
		FCM_CONSOLE_DEBUG1("%ld char}", strlen(fichier));

		return(FSL_ERROR_BUFFER_TOO_SMALL);
	}


	/* On verifie la taille du masque */
	if( strlen(masque) > FSL_TAILLE_MASQUE )
	{
		FCM_LOG_PRINT("ERREUR - Fcm_my_file_select() - masque trop long");
		FCM_CONSOLE_DEBUG("ERREUR : Fcm_my_file_select() masque trop long");
		FCM_CONSOLE_DEBUG1("{%s}", masque);

		return(FSL_ERROR_BUFFER_TOO_SMALL);
	}

	/* verification faite, on peut copier */
	strcpy( fsl_chemin, chemin );
	strcat( fsl_chemin, masque );

	strcpy( fsl_fichier, fichier);


	{
		//OBJECT	*adr_formulaire;

		/* on cherche l'adresse du dialogue contenant les titres */
		//rsrc_gaddr( R_TREE, DL_TITRE_FENETRE, &adr_formulaire );
		//adr_formulaire = Fcm_adr_RTREE[DL_TITRE_FENETRE];

		if( strlen( titre_fsel /*adr_formulaire[titre_idx].ob_spec.free_string*/ )   <   (FSL_TAILLE_TITRE-1) )
		{
			strcpy( fsl_titre, titre_fsel /*adr_formulaire[titre_idx].ob_spec.free_string*/ );
		}
		else
		{
			FCM_LOG_PRINT("ERREUR : Fcm_my_file_select() taille titre trop long");
			FCM_CONSOLE_DEBUG("ERREUR : Fcm_my_file_select() taille titre trop long");
			FCM_CONSOLE_DEBUG1("%ld char", strlen( titre_fsel /*adr_formulaire[titre_idx].ob_spec.free_string*/) );
		}
	}


	{
		int16    bouton;
		int16    reponse;

		/* Si on a un AES 1.40 ou plus, on utilise */
		/* le selecteur de fichier ‚tendu          */
		//wind_update(BEG_MCTRL);   /* MyAES rale si BEG_MCTRL activé */
		if( Fcm_systeme.aes_version >= 0x140 )
		{
			reponse = fsel_exinput(fsl_chemin, fsl_fichier,&bouton,fsl_titre);
		}
		else
		{
			reponse = fsel_input(fsl_chemin,fsl_fichier,&bouton);
		}
		//wind_update(END_MCTRL);


		/* on v‚rifie si les buffers n'ont pas d‚bord‚ */
		if( strlen(fsl_chemin) >= FSL_TAILLE_CHEMIN || strlen(fsl_fichier) >= FSL_TAILLE_FICHIER )
		{
			FCM_LOG_PRINT2("ERREUR - Fcm_file_select() - Un ou deux buffer ont ‚t‚ ‚cras‚ ! "CRLF"chemin={%s}"CRLF"fichier={%s}"CRLF, fsl_chemin, fsl_fichier);
			FCM_CONSOLE_DEBUG("ERREUR : Fcm_my_file_select() buffer ecras‚ ");
			FCM_CONSOLE_DEBUG2("fsl_chemin: %ld char MAX(%d)", strlen(fsl_chemin), FSL_TAILLE_CHEMIN );
			FCM_CONSOLE_DEBUG2("fsl_fichier: %ld char MAX(%d)", strlen(fsl_fichier), FSL_TAILLE_FICHIER );
			FCM_CONSOLE_DEBUG("Panic : le programme / systeme est corrompu... Quitter le navire !");

			return(FSL_ERROR_BUFFER_CRUSHED);
		}


		/* reponse == 0 en cas d'erreur */
		if( reponse == 0 )
		{
			return( FSL_ERROR_FSEL_INPUT );
		}

		/* bouton Annuler (1==OK) */
		if( bouton == 0 )
		{
			return FALSE;
		}
	}




	/* ------------------------------ */
	/* Le file selecteur a ‚t‚ valid‚ */
	/* ------------------------------ */

	{
		char *position_slash;

		FCM_LOG_PRINT1("fsl_chemin={%s}", fsl_chemin);
		FCM_LOG_PRINT1("fsl_fichier={%s}", fsl_fichier);

		position_slash = strrchr( fsl_chemin, '\\' );

		if( position_slash != NULL )
		{
			position_slash[1] = '\0';
		}

		FCM_LOG_PRINT1("fsl_chemin={%s} suppression masque", fsl_chemin );


		if( strlen(fsl_chemin) < size_chemin )
		{
			strcpy( chemin, fsl_chemin);
		}
		else
		{
			FCM_CONSOLE_DEBUG("ERREUR : Fcm_my_file_select() buffer appel trop petit");
			FCM_CONSOLE_DEBUG2("fsl_chemin: %ld char size_chemin=%d", strlen(fsl_chemin), size_chemin );

			return FSL_ERROR_BUFFER_TOO_SMALL;
		}

		if( strlen(fsl_fichier) < size_fichier )
		{
			strcpy( fichier, fsl_fichier);
		}
		else
		{
			FCM_CONSOLE_DEBUG("ERREUR : Fcm_my_file_select() buffer appel trop petit");
			FCM_CONSOLE_DEBUG2("fsl_fichier: %ld char , size_fichier=%d", strlen(fsl_fichier), size_fichier );

			return FSL_ERROR_BUFFER_TOO_SMALL;
		}
	}


	return TRUE;


}


#endif  /* ___FCM_MY_FILE_SELECT_C___ */

