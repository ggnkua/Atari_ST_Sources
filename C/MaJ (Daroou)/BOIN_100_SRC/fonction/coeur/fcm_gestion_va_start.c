/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 08/12/2003 MaJ 06/03/2024 * */
/* ***************************** */



/*
 * vieille fonction... a revoir un jour...
 *
 */
 
 
void Fcm_gestion_va_start(void)
{
	/* Si on recois des MSG APP_ARGV on utilise le tableau */
	/* Si on recois des msg VA_START on genere ce tableau comme pour la 
       gestion des APP_ARGV, … faire */


	FCM_LOG_PRINT("* Fcm_gestion_va_start() - R‚ception message VA_START:");
	FCM_LOG_PRINT4(" - [0]=$%04x ,[1]=$%04x ,[2]=%04x ,[3]=$%04x ", buffer_aes[0], buffer_aes[1], buffer_aes[2], buffer_aes[3]);
	FCM_LOG_PRINT4(" [4]=$%04x ,[5]=$%04x ,[6]=$%04x ,[7]=$%04x", buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7]);

	{
		char	*ptc_va_start_parms;

		ptc_va_start_parms=(char *)( ((uint32)buffer_aes[3]<<16) + (uint16)buffer_aes[4] );

		FCM_LOG_PRINT1(" - adresse transmise=%p", ptc_va_start_parms);
		FCM_LOG_PRINT1(" - contenu={%s}", ptc_va_start_parms);

		if( ptc_va_start_parms[0]!=0 && strlen(ptc_va_start_parms)<FCM_TAILLE_CHEMIN  )
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
				int16 idx=0;
/*				int16 dummy;*/

				do
				{
					if( Fcm_chemin_fichier[idx]==39 && Fcm_chemin_fichier[idx+1]==39 )
					{
/*						dummy=idx+1;
						do
						{
							chemin_fichier[dummy]=chemin_fichier[dummy+1];
							dummy++;
						} while( chemin_fichier[dummy]!=0 );*/

						{
							char buffer[512];
							strcpy( buffer, (Fcm_chemin_fichier+idx+1) );
							strcpy( (Fcm_chemin_fichier+idx), buffer );
							//strcpy( (Fcm_chemin_fichier+idx), (Fcm_chemin_fichier+idx+1) );
						}
					}

				} while( Fcm_chemin_fichier[idx++] !=0 );
			}



			/* on separe chemin et nom du fichier ... */
			{
				char *ptc_find_slash;

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
			if( ptc_va_start_parms[0] == 0 )
			{
				Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_AV_NO_FILE, 0 );
			}
			else
			{
				Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_AV_BAD_FILE, 0 );
			}
		}
	}


	/* On saute … la fonction de l'appli pour g‚rer les messages recus... */
	gestion_va_start();


	return;


}

