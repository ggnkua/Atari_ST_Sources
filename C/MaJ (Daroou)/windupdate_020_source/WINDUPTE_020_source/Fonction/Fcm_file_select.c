/**[Fonction commune]***************/
/* 21/01/2013 # 21/01/2013         */
/***********************************/


#define TAILLE_MY_BUFFER  (TAILLE_CHEMIN*2)


/* Prototype */
WORD Fcm_file_select( WORD titre_rsc,CHAR *chemin, CHAR *fichier, CHAR *masque);


/* Fonction */
WORD Fcm_file_select( WORD titre_idx,CHAR *chemin, CHAR *fichier, CHAR *masque)
{
	OBJECT	*adr_formulaire;
	CHAR my_buffer[TAILLE_MY_BUFFER];
	CHAR old_chemin[TAILLE_CHEMIN];
	CHAR old_fichier[TAILLE_FICHIER];
	CHAR *position;
	WORD bouton;
	WORD reponse;




	if( strlen(chemin)>(TAILLE_CHEMIN-3) || strlen(fichier)>TAILLE_FICHIER )
	{
		Fcm_form_alerte( 0, ALT_ERR_OVERWRIT );

		#ifdef LOG_FILE
		sprintf( buf_log, "# ERREUR - Fcm_file_select() - d‚bordement d'un buffer !!! "CRLF );
		log_print(FALSE);
		#endif

		return(FALSE);
	}



	/* backup */
	strcpy( old_chemin , chemin );
	strcpy( old_fichier, fichier);

	/* on cherche l'adresse du dialogue contenant les titres */
	rsrc_gaddr( R_TREE, DL_TITRE_FENETRE, &adr_formulaire );


	strcpy( my_buffer, "Wrong Title, 30 char max");
	if( strlen( (adr_formulaire+titre_idx)->ob_spec.free_string ) <31 )
	{
		strcpy( my_buffer, (adr_formulaire+titre_idx)->ob_spec.free_string );
	}



	strcat( chemin, masque );


	/* Si on a un AES 1.40 ou plus, on utilise */
	/* le selecteur de fichier ‚tendu          */
	if( systeme.aes_version>=0x140 )
	{
		reponse=fsel_exinput(chemin,fichier,&bouton,my_buffer);
	}
	else
	{
		reponse=fsel_input(chemin,fichier,&bouton);
	}

	/* On retire le mask du chemin */
	position=strstr( chemin, masque );
	if( position != NULL )
	{
		position[0]='\0';
	}


	/* reponse == 0 en cas d'erreur, sinon 1 */
	if( reponse && bouton==FSEL_OK )
	{
		if( (strlen(chemin)+strlen(fichier)) < TAILLE_MY_BUFFER )
		{
			strcpy( my_buffer, chemin);
			strcat( my_buffer, fichier);
			reponse=Fcm_file_exist(my_buffer);


			if( reponse< 0 )
			{
				Fcm_form_alerte( 0, ALT_FILE_NOFOUND );
				strcpy( chemin , old_chemin  );
				strcpy( fichier, old_fichier );
				return(FALSE);
			}

			return( TRUE );

		}

	}


	return(FALSE);


}


#undef TAILLE_MY_BUFFER

