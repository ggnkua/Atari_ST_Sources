/* **[Fonction commune]******** */
/* * Gestion message          * */
/* * 05/12/2003 = 06/04/2013  * */
/* **************************** */


#ifndef ___Fcm_gestion_iconify___
#define ___Fcm_gestion_iconify___



#include "Fcm_Fermer_Fenetre.c"



/* Prototypes */
VOID Fcm_gestion_iconify( const WORD controlkey);


/* Fonction */
VOID Fcm_gestion_iconify( const WORD controlkey)
{
/*
 * extern	FT_REDRAW	table_ft_redraw_win[NB_FENETRE];
 * extern	WORD		buffer_aes[16];
 * extern	WORD		h_win[NB_FENETRE];
 * extern	WORD		pxy[16];
 * extern	WORD		vdihandle;
 *
 */
	WORD win_index;


	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_gestion_iconify( controlkey=%d )"CRLF, controlkey );
	log_print(FALSE);
	#endif


	/* Gestion des iconifications des fenetres */
	/* En cas d'iconification globale (Control+smaller), c'est la fenetre */
	/* cliqu‚ qui sera iconifi‚ et donnera son 'motif' pour le contenu    */


	win_index = Fcm_get_indexwindow( buffer_aes[3] );


	if( win_index != FCM_NO_MY_WINDOW )
	{

		/* WIN Iconify */
		if( buffer_aes[0]==WM_ICONIFY && controlkey==0 )
		{
			wind_set( buffer_aes[3], WF_ICONIFY, buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7] );
			win_iconified[win_index]=TRUE;

			return;
		}


		/* Si on arrive ici, c'est soit un WM_ICONIFY avec une */
		/* touche de controle appuy‚ ou WM_ALLICONIFY          */

		/* WIN ALLIconify */
		if( buffer_aes[0]==WM_ALLICONIFY || controlkey==K_CTRL )
		{
			WORD dummy;

			for( dummy=0; dummy<NB_FENETRE; dummy++)
			{
				if( h_win[dummy]!=FCM_NO_OPEN_WINDOW && dummy!=win_index )
				{
					win_iconified[dummy]=TRUE;
					Fcm_fermer_fenetre(dummy);
				}
			}

			wind_set( h_win[win_index], WF_ICONIFY, buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7] );
			win_iconified[win_index]=TRUE;
			win_all_iconified_flag=TRUE;


			return;
		}



		/* WIN ALLIconify avec touche ALT */
		if( controlkey==K_ALT )
		{
			WORD dummy;


			wind_set( buffer_aes[3], WF_ICONIFY, buffer_aes[4], buffer_aes[5], buffer_aes[6], buffer_aes[7] );
			win_iconified[win_index]=TRUE;


			for( dummy=0; dummy<NB_FENETRE; dummy++)
			{
				if( h_win[dummy]!=FCM_NO_OPEN_WINDOW  )
				{
					if( dummy!=win_index && win_iconified[dummy]==FALSE )
					{
						buffer_aes[0]=WF_ICONIFY;
						buffer_aes[1]=ap_id;
						buffer_aes[2]=0;
						buffer_aes[3]=h_win[dummy];
						appl_write( ap_id, 16, &buffer_aes );
					}
				}
			}

			return;
		}




	}


	return;

}


#endif  /* ___Fcm_gestion_iconify___ */


