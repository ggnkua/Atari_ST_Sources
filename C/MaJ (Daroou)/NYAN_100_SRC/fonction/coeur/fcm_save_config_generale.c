/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 31/12/2012 MaJ 02/03/2024 * */
/* ***************************** */



/*
 * Fonction sauvant tous les TAG de configuration,
 * commun … toutes les applis
 *
 */


#ifndef __FCM_SAVE_CONFIG_GENERALE_C__
#define __FCM_SAVE_CONFIG_GENERALE_C__


#define  MY_BUFFER_SIZE  (32)


void Fcm_save_config_generale(const int16 handle_fichier)
{

	Fcm_fprint( handle_fichier, "");
	Fcm_fprint( handle_fichier, "-=- Configuration g‚n‚rale Coeur application -=-");
	Fcm_fprint( handle_fichier, "");
	Fcm_fprint( handle_fichier, "");


	Fcm_fprint( handle_fichier, "# Pr‚f‚rence Configuration");

	{
		char my_buffer[MY_BUFFER_SIZE];

		snprintf( my_buffer, MY_BUFFER_SIZE, "SAUVEGARDE_AUTO=%d", Fcm_save_option_auto );
		Fcm_fprint( handle_fichier, my_buffer );

		snprintf( my_buffer, MY_BUFFER_SIZE, "SAUVEGARDE_WINPOS=%d", Fcm_save_winpos );
		Fcm_fprint( handle_fichier, my_buffer );

		snprintf( my_buffer, MY_BUFFER_SIZE, "QUITTER_CLOSEWIN=%d", Fcm_quit_closewin );
		Fcm_fprint( handle_fichier, my_buffer );

		snprintf( my_buffer, MY_BUFFER_SIZE, "RSC_LANGAGE=%d", Fcm_rsc_langage_code );
		Fcm_fprint( handle_fichier, my_buffer );
	}

	Fcm_fprint( handle_fichier, "");



	Fcm_fprint( handle_fichier, "# Position et paramŠtre des fenˆtres");
	Fcm_fprint( handle_fichier, "# 00 DialTemp 01 LAunch 02 InfoPrg 03 Option 04 Console 05 PopUp 06 FormAlert");
	
	{
		char	my_buffer[MY_BUFFER_SIZE];
		int16	idx;
		int16   openwinflag;


		for( idx=0; idx < NB_FENETRE; idx++)
		{
			openwinflag = FCM_NO_OPEN_WINDOW;

			/* En cas d'erreur au chargement, si les fenetres n'ont pas reussi a etre ouverte */
			/* l'handle est alors encore positionne sur la valeur du fichier de config        */
			/* soit FCM_NO_OPEN_WINDOW ou FCM_GO_OPEN_WINDOW                                  */
			if( h_win[idx] > 0   ||   h_win[idx] == FCM_GO_OPEN_WINDOW )  openwinflag = FCM_GO_OPEN_WINDOW;

			/* Si largeur ou hauteur null, on invalide le positionnement */
			if( win_posxywh[idx][2] == 0   ||   win_posxywh[idx][3] == 0 )
			{
				win_posxywh[idx][0] = FCM_NO_WINPOS;
				win_posxywh[idx][1] = FCM_NO_WINPOS;
			}

			snprintf( my_buffer, MY_BUFFER_SIZE, "WINPOS_%02dX=%d", idx, win_posxywh[idx][0] );
			Fcm_fprint( handle_fichier, my_buffer );
			snprintf( my_buffer, MY_BUFFER_SIZE, "WINPOS_%02dY=%d", idx, win_posxywh[idx][1] );
			Fcm_fprint( handle_fichier, my_buffer );
			snprintf( my_buffer, MY_BUFFER_SIZE, "WINPOS_%02dW=%d", idx, win_posxywh[idx][2] );
			Fcm_fprint( handle_fichier, my_buffer );
			snprintf( my_buffer, MY_BUFFER_SIZE, "WINPOS_%02dH=%d", idx, win_posxywh[idx][3] );
			Fcm_fprint( handle_fichier, my_buffer );
			snprintf( my_buffer, MY_BUFFER_SIZE, "WINPOS_%02dOpen=%d", idx, openwinflag );
			Fcm_fprint( handle_fichier, my_buffer );
		}
	}

	Fcm_fprint( handle_fichier, "");


	return;

}


#undef  MY_BUFFER_SIZE  


#endif  /*  __FCM_SAVE_CONFIG_GENERALE_C__  */

