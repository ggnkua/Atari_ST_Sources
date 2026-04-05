/**[Fonction commune]*********/
/*                           */
/* 21/01/2013 MaJ 03/01/2017 */
/*****************************/




#ifndef ___Fcm_file_select___
#define ___Fcm_file_select___




#define FSL_TAILLE_CHEMIN  (512)
#define FSL_TAILLE_FICHIER (256)

#define FSL_ERROR_BUFFER_TOO_SMALL  (-5001)
#define FSL_ERROR_BUFFER_CRUSHED    (-5002)
#define FSL_ERROR_FSEL_INPUT        (-5003)
/*#define FSL_ERROR_FILE_NOT_FOUND    (-5004)*/


/* -----------------------------------------

   reponse:

   FALSE   : selection Annul‚
   TRUE    : selection Valid‚
             chemin contient la reponse

   negatif : Erreur

   ----------------------------------------- */



/* Prototype */
int16 Fcm_file_select( int16 titre_rsc, uint16 size_chemin, char *chemin, const char *fichier, const char *masque);


/* Fonction */
int16 Fcm_file_select( int16 titre_idx, uint16 size_chemin, char *chemin, const char *fichier, const char *masque)
{
	char     fsl_titre[32];
	char     fsl_chemin[FSL_TAILLE_CHEMIN];
	char     fsl_fichier[FSL_TAILLE_FICHIER];



#ifdef LOG_FILE
sprintf( buf_log, "#0"CRLF );
log_print(FALSE);
#endif




/*{
	char texte[256];

	sprintf(texte,"size_chemin=%d chemin={%s}      ", size_chemin, chemin );
	v_gtext(vdihandle,2*8,2*16,texte);
	sprintf(texte,"fichier={%s} masque={%s}     ", fichier, masque );
	v_gtext(vdihandle,2*8,3*16,texte);
}*/




	if( strlen(chemin)>(FSL_TAILLE_CHEMIN-5) )
	{
#ifdef LOG_FILE
sprintf( buf_log, "#ERREUR - Fcm_file_select() - taille buffer trop petite ! "CRLF );
log_print(FALSE);
#endif

		return(FSL_ERROR_BUFFER_TOO_SMALL);
	}

#ifdef LOG_FILE
sprintf( buf_log, "#a"CRLF );
log_print(FALSE);
#endif

	strcpy( fsl_chemin , chemin );
	strcat( fsl_chemin, masque );

	strcpy( fsl_fichier, fichier);

#ifdef LOG_FILE
sprintf( buf_log, "#b"CRLF );
log_print(FALSE);
#endif


	{
		OBJECT	*adr_formulaire;


		/* on cherche l'adresse du dialogue contenant les titres */
		rsrc_gaddr( R_TREE, DL_TITRE_FENETRE, &adr_formulaire );


		strcpy( fsl_titre, "Wrong Title, 30 char max");
		if( strlen( (adr_formulaire+titre_idx)->ob_spec.free_string ) <31 )
		{
			strcpy( fsl_titre, (adr_formulaire+titre_idx)->ob_spec.free_string );
		}
	}

#ifdef LOG_FILE
sprintf( buf_log, "#c"CRLF );
log_print(FALSE);
#endif


	{
		int16    bouton;
		int16    reponse;

		/* Si on a un AES 1.40 ou plus, on utilise */
		/* le selecteur de fichier ‚tendu          */
		wind_update(BEG_MCTRL);
		if( systeme.aes_version>=0x140 )
		{
			reponse=fsel_exinput(fsl_chemin, fsl_fichier,&bouton,fsl_titre);
		}
		else
		{
			reponse=fsel_input(fsl_chemin,fsl_fichier,&bouton);
		}
		wind_update(END_MCTRL);


/*		{
			char texte[256];

			sprintf(texte,"fsl_chemin={%s}      ", fsl_chemin );
			v_gtext(vdihandle,2*8,5*16,texte);
			sprintf(texte,"fsl_fichier={%s} reponse=%d bouton=%d     ", fsl_fichier, reponse, bouton );
			v_gtext(vdihandle,2*8,6*16,texte);
		}*/


		/* on v‚rifie si les buffers n'ont pas d‚bord‚ */
		if( strlen(fsl_chemin) >= FSL_TAILLE_CHEMIN || strlen(fsl_fichier) >= FSL_TAILLE_FICHIER )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "#ERREUR - Fcm_file_select() - Un ou deux buffer ont ‚t‚ ‚cras‚ ! "CRLF );
			log_print(FALSE);
			#endif

			return(FSL_ERROR_BUFFER_CRUSHED);
		}


		/* Erreur file select           */
		/* reponse == 0 en cas d'erreur */
		if( reponse == 0 )
		{
			return( FSL_ERROR_FSEL_INPUT );
		}


		if( bouton==0 )
		{
			return FALSE;
		}

	}





	/* ------------------------------ */
	/* Le file selecteur a ‚t‚ valid‚ */
	/* ------------------------------ */

	{
		char *position_masque;


		/* On retire le mask du chemin */
		position_masque=strstr( fsl_chemin, masque );

		if( position_masque != NULL )
		{
			position_masque[0] = '\0';
		}


/*		{
			char texte[256];

			sprintf(texte,"fsl_chemin={%s}      ", fsl_chemin );
			v_gtext(vdihandle,2*8,8*16,texte);
			sprintf(texte,"fsl_fichier={%s}      ", fsl_fichier );
			v_gtext(vdihandle,2*8,9*16,texte);
		}*/


		if( (strlen(fsl_chemin)+strlen(fsl_fichier)) < size_chemin )
		{
			strcpy( chemin, fsl_chemin);
			strcat( chemin, fsl_fichier);
		}

	}


/*		{
			char texte[256];

			sprintf(texte,"chemin={%s}      ", chemin );
			v_gtext(vdihandle,2*8,11*16,texte);
		}*/

	return(TRUE);


}


#endif  /* ___Fcm_file_select___ */

