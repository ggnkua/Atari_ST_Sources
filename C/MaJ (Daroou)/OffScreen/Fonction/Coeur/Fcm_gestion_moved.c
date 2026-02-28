/* **[Fonction Commune]********* */
/* * Gestion Moved             * */
/* * 10/12/2001 Maj 29/03/2015 * */
/* ***************************** */



#ifndef ___Fcm_gestion_moved___
#define ___Fcm_gestion_moved___



/*#include "Fcm_gestion_redraw_fenetre.c"*/



/* Prototypes */
void Fcm_gestion_moved(void);



/* Fonction */
void Fcm_gestion_moved(void)
{

	int16 index_win;


	/*	Lors d'un message WM_MOVED, nous devons modifier la position */
	/*	de la fenetre, ainsi que la position des objets present dans */
	/*	cette fenetre. Ensuite, si n‚cessaire, l'AES va nous envoyer */
	/*	un message WM_REDRAW pour redessiner la totalit‚ (sous TOS)  */
	/*	ou une partie de la fenetre (les AES modernes d‚placent      */
	/*	automatiquement le contenu de la fenetre visible, il demande */
	/*	juste a redessinner les parties absentes.                    */



	/* la fenetre a boug‚, on place la fenetre sur sa nouvelle position */
	wind_set(buffer_aes[3],WF_CURRXYWH,buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);


	/* buffer_aes[3] est l'handle AES de la fenetre    */
	/* on cherche son index dans notre liste (tableau) */
	index_win = Fcm_get_indexwindow( buffer_aes[3] );


	/* on verifie si c'est une de nos fenetres par s‚curit‚ */
	if( index_win != FCM_NO_MY_WINDOW )
	{

		/* Si la fenetre n'est pas iconifi‚, on m‚morise   */
		/* la position. Cela permet de replacer la fenetre */
		/* au bon endroit aprŠs une d‚siconification       */
		if( win_iconified[index_win]==FALSE )
		{
			win_posxywh[index_win][0]=buffer_aes[4];
			win_posxywh[index_win][1]=buffer_aes[5];
		}

		/* on repositionne notre formulaire de fenetre */
		/* s'il y en a de pr‚sent                      */
		if( win_rsc[index_win] != FCM_NO_RSC_DEFINED )
		{
			OBJECT	*adr_formulaire;

			/* On r‚cupŠre l'espace de travail de la fenetre */
			wind_get(buffer_aes[3],WF_WORKXYWH,&buffer_aes[4],&buffer_aes[5],&buffer_aes[6],&buffer_aes[7]);


			/* on modifie la position du formulaire */
			rsrc_gaddr(R_TREE, win_rsc[index_win], &adr_formulaire);
			adr_formulaire->ob_x=buffer_aes[4];
			adr_formulaire->ob_y=buffer_aes[5];
		}
	}


	/* une fenetre a boug‚, on active le bouton pour */
	/* pouvoir sauver la config dans les pref‚rences */
/*	Fcm_active_sauve_config();*/


	return;


}


#endif  /* ___Fcm_gestion_moved___ */


