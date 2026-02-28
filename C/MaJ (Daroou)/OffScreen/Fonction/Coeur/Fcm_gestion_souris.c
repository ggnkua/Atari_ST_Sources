/* ****************************** */
/* * Gestion ‚vŠnement souris   * */
/* * 21/01/2002 MaJ 30/01/2016  * */
/* ****************************** */



#include "Fcm_point_in_area.c"




/* Prototype */
void Fcm_gestion_souris( const int16 controlkey, int16 bouton );




/* Fonction */
void Fcm_gestion_souris( const int16 controlkey, int16 bouton )
{

	int16 win_handle;
	int16 win_index;
	int16 flag_go_gestion_fenetre=FALSE;



	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_gestion_souris(%d,%d)"CRLF, controlkey, bouton );
	log_print(FALSE);
	#endif





	/* hack pour utilisation sous TOS lorsque des appl_write sont utilis‚s */
	/* dans ce cas evnt_multi ne renvoi plus la valeur du bouton appuy‚    */
	/* cela ce produit sous TOS Milan, TOS TT, TOS Falcon                  */
	/* c'est soit une limitation de ces TOS soit un bug de mon code        */
	/* ceci est un patch provisoire                                        */
	if( bouton==0 )
	{
		int16	dummy;


		graf_mkstate( &dummy, &dummy, &bouton, &dummy);

		if( bouton==0 )
		{
			bouton=1;
		}
	}



	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_gestion_souris(%d,%d) (apres patch)"CRLF, controlkey, bouton );
	log_print(FALSE);
	#endif



	/* Avant d'aiguiller l'‚vŠnement souris sur la fenetre concern‚  */
	/* On fait quelque controle pour ‚viter d'y aller pour rien      */
	/* ------------------------------------------------------------- */
	/* win_mouse_through[]: indique si l'event souris doit etre      */
	/*                      passer imp‚rativement … la fenetre       */
	/*                      Ex: fenetre de dessin, jeu, etc...       */
	/* ------------------------------------------------------------- */
	/* Si la fenetre est un dialogue ou en partie, alors seulement   */
	/* si l'objet point‚ a un ob_flag de mis, on passe a sa fonction */
	/* de Gestion et … condition que celui-ci ne soit pas d‚j…       */
	/* s‚lectionn‚ (si selectable) ou disabled                       */
	/* ------------------------------------------------------------- */
	/* ------------------------------------------------------------- */






	/* On cherche l' Handle de la fenetre concern‚ */
	win_handle = wind_find( souris.g_x, souris.g_y );

	/* on recherche l'index correspondant */
	win_index = Fcm_get_indexwindow(win_handle);



	/* La souris peut bouger bouton enfonc‚, on v‚rifie */
	/* si la fenetre sous la souris nous appartient...  */
	if( win_index == FCM_NO_MY_WINDOW )
	{
		/* Ce n'est pas une de nos fenetres ! */
		/* on ne fait rien, on retourne dans la boucle gestion AES */
/*		Fcm_mouse_no_bouton();*/
		return;
	}



	/* Maintenant, on  regarde si la souris est */
	/* dans l'espace de travail de la fenetre   */
	{
		GRECT	surface;

		/* on cherche les coordonn‚es de la surface de travail de la fenˆtre */
		wind_get(win_handle,WF_WORKXYWH,&surface.g_x,&surface.g_y,&surface.g_w,&surface.g_h);

		if( Fcm_point_in_area(&souris, &surface) == 0 )
		{
			/* La souris n'est pas sur l'espace de travail */
/*			Fcm_mouse_no_bouton();*/
			return;
		}
	}





	/* S'il y a des objets ressources dans la fenetre, */
	/* on regarde si un objet a ‚t‚ cliqu‚             */
	if( win_rsc[win_index] != FCM_NO_WIN_RSC )
	{
		OBJECT	*adr_formulaire;
		int16	objet;

		/* on cherche l'adresse du formulaire */
		rsrc_gaddr( R_TREE, win_rsc[win_index], &adr_formulaire );
		objet=objc_find(adr_formulaire,0,7,souris.g_x,souris.g_y);


		if( objet != FCM_NO_OBJET_FOUND )
		{
			/* Un objet a ‚t‚ trouv‚ … cette position  */
			/* On regarde la situation de son OB_FLAG. */
			/* Si aucun flag n'est position‚, c'est un */
			/* objet d‚coratif, pas besoin de d‚ranger */
			/* la fonction de gestion de cette fenetre */
			/* ob_flags==32 -> dernier objet           */

/*	{
		char texte[256];
		sprintf(texte,"(adr_formulaire+objet)->ob_flags=%d     ", (adr_formulaire+objet)->ob_flags );
		v_gtext(vdihandle,75*8,2*16, texte);
		sprintf(texte,"((adr_formulaire+objet)->ob_state & OS_DISABLED)=%d     ", ((adr_formulaire+objet)->ob_state & OS_DISABLED) );
		v_gtext(vdihandle,75*8,3*16, texte);
	}*/

			if( ((adr_formulaire+objet)->ob_flags & 0xff) && ((adr_formulaire+objet)->ob_flags & 0xff) !=32 )
			{
				/* on va tout de meme regarder si l'objet */
				/* est DISABLED                           */
				if( ((adr_formulaire+objet)->ob_state & OS_DISABLED) )
				{
					/* l'objet est DISABLED, on s'en va */
/*					Fcm_mouse_no_bouton();*/
					return;
				}
				else
				{
					flag_go_gestion_fenetre=TRUE;
				}
			}
		}
	}




	/* Si on a obtenu la permission, ou si la fenetre veut */
	/* imperativement recevoir les evenement souris,  on   */
	/* lance la fonction de gestion de cette fenetre       */
	if( flag_go_gestion_fenetre || win_mouse_through[win_index] )
	{

		#ifdef LOG_FILE
		sprintf( buf_log, "# Appel fonction dynamique gestion souris"CRLF );
		log_print(FALSE);
		sprintf( buf_log, "  -> win_index=%d, adresse fonction=%08lx"CRLF, win_index, (LONG)table_ft_gestion_win[win_index] );
		log_print(FALSE);
		sprintf( buf_log, "  -> controlkey=%d, bouton=%d"CRLF, controlkey, bouton );
		log_print(FALSE);
		#endif




		if( table_ft_gestion_win[win_index] != FCM_FONCTION_NON_DEFINI )
		{
			table_ft_gestion_win[win_index](controlkey, 0, bouton);
			return;
		}
	}


	/* Si l'utilisateur a le doigt lourd... */
/*	Fcm_mouse_no_bouton();*/


	return;


}

