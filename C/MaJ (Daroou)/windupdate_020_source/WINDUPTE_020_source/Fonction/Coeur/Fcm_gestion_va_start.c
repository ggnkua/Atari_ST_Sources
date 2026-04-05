/* **[Fonction commune]******** */
/* * Gestion message          * */
/* * 08/12/2003 = 03/01/2013  * */
/* **************************** */


/* Prototypes */
VOID Fcm_gestion_va_start(VOID);


/* Fonction */
VOID Fcm_gestion_va_start(VOID)
{
/*
 * extern	FT_REDRAW	table_ft_redraw_win[NB_FENETRE];
 * extern	WORD		buffer_aes[16];
 * extern	WORD		h_win[NB_FENETRE];
 * extern	WORD		pxy[16];
 * extern	WORD		vdihandle;
 *
 */


	/* Si on recois des MSG APP_ARGV on utilise le tableau */
	/* Si on recois des msg VA_START on genere ce tableau comme pour la 
       gestion des APP_ARGV, … faire */



/*	sprintf(texte," Fcm_gestion_va_start");
	v_gtext(vdihandle,60*8,2*16,texte);*/

	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_gestion_va_start() - R‚ception message VA_START:"CRLF);
	log_print( FALSE );
	sprintf( buf_log, " - [0]=$%04x ,[1]=$%04x ,[2]=%04x ,[3]=$%04x ", buffer_aes[0], buffer_aes[1], buffer_aes[2], buffer_aes[3]);
	log_print( FALSE );
	sprintf( buf_log, " [4]=$%04x ,[5]=$%04x ,[6]=$%04x ,[7]=$%04x"CRLF, buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7]);
	log_print( FALSE );
	#endif


	{
		CHAR	*ptc_va_start_parms;

		ptc_va_start_parms=(CHAR *)( ((UWORD)buffer_aes[3]<<16) + (UWORD)buffer_aes[4] );


		#ifdef LOG_FILE
		sprintf( buf_log, " - adresse transmise=%p"CRLF, ptc_va_start_parms);
		log_print( FALSE );
		sprintf( buf_log, " - contenu={%s}"CRLF, ptc_va_start_parms);
		log_print( FALSE );
		#endif



		if( ptc_va_start_parms[0]!=0 && strlen(ptc_va_start_parms)<TAILLE_CHEMIN  )
		{

			if( ptc_va_start_parms[0]==0x27 )
			{
				ptc_va_start_parms++;
			}

			strcpy( Fcm_chemin_fichier, ptc_va_start_parms );


			if( Fcm_chemin_fichier[strlen(Fcm_chemin_fichier)-1]==0x27 )
			{
				Fcm_chemin_fichier[strlen(Fcm_chemin_fichier)-1]=0;
			}


			/* on regarde s'il y a un apostrophe <'> dans le nom    */
			/* Comme il est doubl‚ pour le diff‚rencier du marquage */
			/* Il faut en supprimer 1                               */
			{
				WORD index=0;
/*				WORD dummy;*/

				do
				{
					if( Fcm_chemin_fichier[index]==39 && Fcm_chemin_fichier[index+1]==39 )
					{
/*						dummy=index+1;
						do
						{
							chemin_fichier[dummy]=chemin_fichier[dummy+1];
							dummy++;
						} while( chemin_fichier[dummy]!=0 );*/

						strcpy( (Fcm_chemin_fichier+index), (Fcm_chemin_fichier+index+1) );
					}

				} while( Fcm_chemin_fichier[index++] !=0 );
			}



			/* on separe chemin et nom du fichier ... */
			{
				CHAR *ptc_find_slash;

				ptc_find_slash=Fcm_chemin_fichier+strlen(Fcm_chemin_fichier);

				do
				{
					ptc_find_slash--;
				} while( *ptc_find_slash != '\\' && *ptc_find_slash != '\0' );

				ptc_find_slash++;

				/* on copie le nom fichier */
				strcpy( Fcm_fichier, ptc_find_slash );

				/* on conserve le nom du chemin seulement */
				ptc_find_slash[0]=0;
			}



/* ********************************************* */
/* A coder la gestion Va_start vers l'application */
/* ********************************************* */



		}
		else
		{
			if( ptc_va_start_parms[0]==0)
			{
				Fcm_form_alerte(0, ALT_AV_NO_FILE);
			}
			else
			{
				Fcm_form_alerte(0, ALT_AV_BAD_FILE);
			}
		}
	}


	/* On saute … la fonction de l'appli pour g‚rer les messages recus... */
	gestion_va_start();


	return;


}

