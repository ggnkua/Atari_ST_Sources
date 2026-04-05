/* **[Wind_Update]************** */
/* *                           * */
/* * 20/01/2013 MaJ 29/01/2015 * */
/* ***************************** */




void save_config( const int16 handle_fichier )
{

		/* ---------------------------------------------- */
		/* paramŠtre de config propre … cette application */
		/* ---------------------------------------------- */


		Fcm_fprint( handle_fichier, "# Wind_Update Mode");

		{
			char	my_buffer[TAILLE_BUFFER];
			OBJECT	*adr_formulaire;
			int16	valeur;


			rsrc_gaddr( R_TREE,  win_rsc[W_WINDUPDATE], &adr_formulaire );

			valeur=0;
			if( (adr_formulaire+WU_NOBLOCK)->ob_state & OS_SELECTED )
			{
				valeur=1;
			}
			sprintf( my_buffer, "WU_WINDUPDATE_MODE=%d", valeur );
			Fcm_fprint( handle_fichier, my_buffer );
		}

		Fcm_fprint( handle_fichier, "");






		Fcm_fprint( handle_fichier, "# Wind_Update Temps r‚el Mode");

		{
			char	my_buffer[TAILLE_BUFFER];
			OBJECT	*adr_formulaire;
			int16	valeur;


			rsrc_gaddr( R_TREE,  win_rsc[W_WINDUPDATE], &adr_formulaire );

			valeur=0;
			if( (adr_formulaire+WU_BT_FULLTIME)->ob_state & OS_SELECTED )
			{
				valeur=1;
			}
			sprintf( my_buffer, "WU_WINDUPDATE_REALTIME=%d", valeur );
			Fcm_fprint( handle_fichier, my_buffer );
		}

		Fcm_fprint( handle_fichier, "");







		Fcm_fprint( handle_fichier, "# Wind_Update Mode NO_BLOCK pour les stats");

		{
			char	my_buffer[TAILLE_BUFFER];
			OBJECT	*adr_formulaire;
			int16	valeur;


			rsrc_gaddr( R_TREE,  win_rsc[W_WINDUPDATE], &adr_formulaire );

			valeur=0;
			if( (adr_formulaire+WU_NOMBRE_MODE)->ob_state & OS_SELECTED )
			{
				valeur=1;
			}
			sprintf( my_buffer, "WU_NOMBRE_NOBLOCK=%d", valeur );
			Fcm_fprint( handle_fichier, my_buffer );
		}

		Fcm_fprint( handle_fichier, "");



	return;

}

