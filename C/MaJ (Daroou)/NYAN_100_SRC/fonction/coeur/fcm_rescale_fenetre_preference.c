/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 17/11/2003 MaJ 19/02/2024 * */
/* ***************************** */


#include "fcm_rescale_def.h"



void Fcm_rescale_fenetre_preference( void )
{
	OBJECT	*dial;
	int16    form_w;
	int16    checkbox_size;


	FCM_LOG_PRINT( CRLF"# Fcm_rescale_fenetre_preference()" );

	/* Marre que le formulaire s'affiche mal d'une resolution a l'autre */
	/* tous les objets et le fond sont repositionner                    */


	dial = Fcm_adr_RTREE[DL_OPT_PREF];


	checkbox_size = MAX( 8, FCM_RESCALE_WCHAR);

	/* sauve position des fenetre */
	{
		dial[CHK_SAVE_WINPOS].ob_width = checkbox_size;
		dial[CHK_SAVE_WINPOS].ob_height = FCM_RESCALE_HCHAR;

		dial[CHK_SAVE_WINPOS].ob_y = FCM_RESCALE_MARGE_HAUT;
		dial[CHK_SAVE_WINPOS].ob_x = FCM_RESCALE_MARGE_GAUCHE;

		dial[PREF_SAVE_WINPOS].ob_y = dial[CHK_SAVE_WINPOS].ob_y;
		dial[PREF_SAVE_WINPOS].ob_x = dial[CHK_SAVE_WINPOS].ob_x + dial[CHK_SAVE_WINPOS].ob_width + FCM_RESCALE_ESPACE;

		form_w = dial[PREF_SAVE_WINPOS].ob_x + dial[PREF_SAVE_WINPOS].ob_width;
	}

	/* quitter sur fermeture fenetre principale */
	{
		dial[CHK_CLOSE_QUIT].ob_width = checkbox_size;
		dial[CHK_CLOSE_QUIT].ob_height = FCM_RESCALE_HCHAR;

		dial[CHK_CLOSE_QUIT].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[CHK_CLOSE_QUIT].ob_y = dial[CHK_SAVE_WINPOS].ob_y + dial[CHK_SAVE_WINPOS].ob_height + FCM_RESCALE_INTERLIGNE;

		dial[PREF_CLOSE_QUIT].ob_x = dial[CHK_CLOSE_QUIT].ob_x + dial[CHK_CLOSE_QUIT].ob_width + FCM_RESCALE_ESPACE;
		dial[PREF_CLOSE_QUIT].ob_y = dial[CHK_CLOSE_QUIT].ob_y;

		form_w = MAX( form_w, (dial[PREF_CLOSE_QUIT].ob_x + dial[PREF_CLOSE_QUIT].ob_width) );
	}

	/* sauver les options en quittant */
	{
		dial[CHK_SAVE_AUTO].ob_width = checkbox_size;
		dial[CHK_SAVE_AUTO].ob_height = FCM_RESCALE_HCHAR;

		dial[CHK_SAVE_AUTO].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[CHK_SAVE_AUTO].ob_y = dial[CHK_CLOSE_QUIT].ob_y + dial[CHK_CLOSE_QUIT].ob_height + FCM_RESCALE_INTERLIGNE;

		dial[PREF_SAVE_AUTO].ob_x = dial[CHK_SAVE_AUTO].ob_x + dial[CHK_SAVE_AUTO].ob_width + FCM_RESCALE_ESPACE;
		dial[PREF_SAVE_AUTO].ob_y = dial[CHK_SAVE_AUTO].ob_y;

		form_w = MAX( form_w, (dial[PREF_SAVE_AUTO].ob_x + dial[PREF_SAVE_AUTO].ob_width) );
	}

	/* bouton sauver */
	{
		dial[PREF_SAVE_CONFIG].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[PREF_SAVE_CONFIG].ob_y = dial[CHK_SAVE_AUTO].ob_y + dial[CHK_SAVE_AUTO].ob_height + FCM_RESCALE_LIGNEVIDE;
	}

	/* popup langue */
	{
		/* popup */
		dial[PREF_POPUP_LANG].ob_x = form_w - dial[PREF_POPUP_LANG].ob_width;
		dial[PREF_POPUP_LANG].ob_y = dial[PREF_SAVE_CONFIG].ob_y;

		/* label */
		dial[PREF_POPUP_LABEL].ob_x = dial[PREF_POPUP_LANG].ob_x - dial[PREF_POPUP_LABEL].ob_width - FCM_RESCALE_ESPACE;
		dial[PREF_POPUP_LABEL].ob_y = dial[PREF_SAVE_CONFIG].ob_y;

		/* on controle que le bouton et popup ne se superpose pas */
		if( dial[PREF_POPUP_LABEL].ob_x < (dial[PREF_SAVE_CONFIG].ob_x+dial[PREF_SAVE_CONFIG].ob_width+(FCM_RESCALE_ESPACE*2)) )
		{
			dial[PREF_POPUP_LABEL].ob_x = dial[PREF_SAVE_CONFIG].ob_x + dial[PREF_SAVE_CONFIG].ob_width + (FCM_RESCALE_ESPACE*2);
			dial[PREF_POPUP_LANG].ob_x = dial[PREF_POPUP_LABEL].ob_x + dial[PREF_POPUP_LABEL].ob_width + FCM_RESCALE_ESPACE;
			form_w = MAX( form_w, (dial[PREF_POPUP_LANG].ob_x + dial[PREF_POPUP_LANG].ob_width) );
		}
	}

	/* dimension du fond */
	dial[0].ob_width  = form_w + FCM_RESCALE_MARGE_DROITE;
	dial[0].ob_height = dial[PREF_SAVE_CONFIG].ob_y + dial[PREF_SAVE_CONFIG].ob_height + FCM_RESCALE_INTERLIGNE + FCM_RESCALE_MARGE_BAS;


	return;

}

