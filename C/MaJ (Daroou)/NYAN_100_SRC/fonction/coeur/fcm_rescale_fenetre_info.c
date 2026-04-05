/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 28/11/2003 MaJ 03/03/2024 * */
/* ***************************** */



#include "fcm_rescale_def.h"



void Fcm_rescale_fenetre_info( void )
{
	OBJECT	*dial;
	int16    form_w;
	int16	 img_x;


	FCM_LOG_PRINT( CRLF"# Fcm_rescale_fenetre_info()" );

	/* Marre que le formulaire s'affiche mal d'une resolution a l'autre */
	/* tous les objets et le fond sont repositionné                     */


	dial = Fcm_adr_RTREE[DL_INFO_PRG];

	img_x = 0;


	/* cadre titre */
	{
		dial[INFO_CDR_INVISIB].ob_x = FCM_RESCALE_MARGE_GAUCHE/2;
		dial[INFO_CDR_INVISIB].ob_y = FCM_RESCALE_MARGE_HAUT/2;

		dial[INFO_CDR_OMBRE].ob_x = 4;
		dial[INFO_CDR_OMBRE].ob_y = 4;

		dial[INFO_CDR_TITRE].ob_x = 0;
		dial[INFO_CDR_TITRE].ob_y = 0;

		dial[INFO_CDR_TITRE].ob_height = dial[INFO_CDR_TEXTE].ob_height * 2;
		dial[INFO_CDR_OMBRE].ob_height = dial[INFO_CDR_TITRE].ob_height;

		dial[INFO_CDR_TEXTE].ob_y = dial[INFO_CDR_TEXTE].ob_height / 2;

		if( Fcm_screen.nb_plan<4 )
		{
			dial[INFO_CDR_TITRE].ob_spec.obspec.interiorcol = 0;
			dial[INFO_CDR_TITRE].ob_spec.obspec.framecol = 1;
			dial[INFO_CDR_TEXTE].ob_spec.tedinfo->te_color = dial[INFO_CDR_TEXTE].ob_spec.tedinfo->te_color & 0xF0FF; /* efface couleur texte */
			dial[INFO_CDR_TEXTE].ob_spec.tedinfo->te_color = dial[INFO_CDR_TEXTE].ob_spec.tedinfo->te_color | 0x0100; /* valeur 1 texte (noir) */
		}
		dial[INFO_CDR_INVISIB].ob_height = dial[INFO_CDR_OMBRE].ob_y + dial[INFO_CDR_OMBRE].ob_height;
		dial[INFO_CDR_INVISIB].ob_width  = dial[INFO_CDR_OMBRE].ob_x + dial[INFO_CDR_OMBRE].ob_width;
	}


	/* image position verticale */
	{
		dial[INFO_IMG_RENAIS].ob_y = dial[INFO_CDR_INVISIB].ob_y;
//FCM_CONSOLE_ADD2("dial[INFO_IMG_RENAIS].ob_height=%d", dial[INFO_IMG_RENAIS].ob_height, G_GREEN );
	}


	/* license */
	{
		dial[INFO_TXT_LICENCE].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[INFO_TXT_LICENCE].ob_y = dial[INFO_CDR_INVISIB].ob_y + dial[INFO_CDR_INVISIB].ob_height + FCM_RESCALE_INTERLIGNE;
		img_x = MAX( img_x, dial[INFO_TXT_LICENCE].ob_x + dial[INFO_TXT_LICENCE].ob_width);
	}


	/* version */
	{
		dial[INFO_TXT_VERSION].ob_x = dial[INFO_TXT_LICENCE].ob_x;
		dial[INFO_TXT_VERSION].ob_y = dial[INFO_TXT_LICENCE].ob_y + dial[INFO_TXT_LICENCE].ob_height;

		dial[INFO_PRG_VERSION].ob_x = dial[INFO_TXT_VERSION].ob_x +dial[INFO_TXT_VERSION].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_PRG_VERSION].ob_y = dial[INFO_TXT_VERSION].ob_y;
		img_x = MAX( img_x, dial[INFO_PRG_VERSION].ob_x + dial[INFO_PRG_VERSION].ob_width);
	}


	/* date programme */
	{
		dial[INFO_PRG_DATE].ob_x = dial[INFO_TXT_LICENCE].ob_x;
		dial[INFO_PRG_DATE].ob_y = dial[INFO_TXT_VERSION].ob_y + dial[INFO_TXT_VERSION].ob_height;
		img_x = MAX( img_x, dial[INFO_PRG_DATE].ob_x + dial[INFO_PRG_DATE].ob_width);
	}


	/* debug message */
	{
		dial[INFO_DBUG].ob_x = FCM_RESCALE_MARGE_GAUCHE*2;
		dial[INFO_DBUG].ob_y = dial[INFO_IMG_RENAIS].ob_y + dial[INFO_IMG_RENAIS].ob_height;
	}


	/* compile le */
	{
		dial[INFO_COMPIL_TXT].ob_x = FCM_RESCALE_MARGE_GAUCHE/2;
		dial[INFO_COMPIL_TXT].ob_y = dial[INFO_DBUG].ob_y + dial[INFO_DBUG].ob_height;

		dial[INFO_COMPIL_DATE].ob_x = dial[INFO_COMPIL_TXT].ob_x +dial[INFO_COMPIL_TXT].ob_width + (FCM_RESCALE_ESPACE/2);
		dial[INFO_COMPIL_DATE].ob_y = dial[INFO_COMPIL_TXT].ob_y;
	}


	/* gcc version */
	{
		dial[INFO_GCC_VER_TXT].ob_x = dial[INFO_COMPIL_DATE].ob_x + dial[INFO_COMPIL_DATE].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_GCC_VER_TXT].ob_y = dial[INFO_COMPIL_TXT].ob_y;

		dial[INFO_GCC_VER].ob_x = dial[INFO_GCC_VER_TXT].ob_x + dial[INFO_GCC_VER_TXT].ob_width + (FCM_RESCALE_ESPACE/2);
		dial[INFO_GCC_VER].ob_y = dial[INFO_COMPIL_TXT].ob_y;
		form_w = dial[INFO_GCC_VER].ob_x +dial[INFO_GCC_VER].ob_width;
	}


	/* CPU cible, gemlib , libC */
	{
		dial[INFO_CPU_TXT].ob_x = dial[INFO_COMPIL_TXT].ob_x;
		dial[INFO_CPU_TXT].ob_y = dial[INFO_COMPIL_TXT].ob_y + dial[INFO_COMPIL_TXT].ob_height + 2;

		dial[INFO_CPU_TARGET].ob_x = dial[INFO_CPU_TXT].ob_x +dial[INFO_CPU_TXT].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_CPU_TARGET].ob_y = dial[INFO_CPU_TXT].ob_y;

		dial[INFO_GEMLIB_TXT].ob_x = dial[INFO_CPU_TARGET].ob_x +dial[INFO_CPU_TARGET].ob_width + (FCM_RESCALE_ESPACE*4);
		dial[INFO_GEMLIB_TXT].ob_y = dial[INFO_CPU_TXT].ob_y;

		dial[INFO_GEMLIB_VER].ob_x = dial[INFO_GEMLIB_TXT].ob_x +dial[INFO_GEMLIB_TXT].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_GEMLIB_VER].ob_y = dial[INFO_CPU_TXT].ob_y;

		dial[INFO_LIBC_TYPE].ob_x = dial[INFO_GEMLIB_VER].ob_x +dial[INFO_GEMLIB_VER].ob_width + (FCM_RESCALE_ESPACE*4);
		dial[INFO_LIBC_TYPE].ob_y = dial[INFO_CPU_TXT].ob_y;

		form_w = MAX( form_w, dial[INFO_LIBC_TYPE].ob_x +dial[INFO_LIBC_TYPE].ob_width);
	}


	/* coeur , RSC builder */
	{
		dial[INFO_COEUR_TXT].ob_x = dial[INFO_COMPIL_TXT].ob_x;
		dial[INFO_COEUR_TXT].ob_y = dial[INFO_CPU_TXT].ob_y + dial[INFO_CPU_TXT].ob_height + 2;

		dial[INFO_COEUR_VER].ob_x = dial[INFO_COEUR_TXT].ob_x +dial[INFO_COEUR_TXT].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_COEUR_VER].ob_y = dial[INFO_COEUR_TXT].ob_y;

/* *** Temporaire *** le temps que toutes les applis passent à RSC Builder */
#ifdef INFO_RSCBUILD_TX
		dial[INFO_RSCBUILD_TX].ob_x = dial[INFO_COEUR_VER].ob_x +dial[INFO_COEUR_VER].ob_width + (FCM_RESCALE_ESPACE*4);
		dial[INFO_RSCBUILD_TX].ob_y = dial[INFO_COEUR_TXT].ob_y;

		dial[INFO_RSCBUILD_V].ob_x = dial[INFO_RSCBUILD_TX].ob_x +dial[INFO_RSCBUILD_TX].ob_width + FCM_RESCALE_ESPACE;
		dial[INFO_RSCBUILD_V].ob_y = dial[INFO_COEUR_TXT].ob_y;

		form_w = MAX( form_w, dial[INFO_RSCBUILD_V].ob_x +dial[INFO_RSCBUILD_V].ob_width);
#else
		form_w = MAX( form_w, dial[INFO_COEUR_VER].ob_x +dial[INFO_COEUR_VER].ob_width);
#endif
	}




	/* image position horizontal */
	{
		dial[INFO_IMG_RENAIS].ob_x = MAX( img_x, (form_w - dial[INFO_IMG_RENAIS].ob_width) ) + 8; /* y a un espace vide autour de l'image */
		form_w = dial[INFO_IMG_RENAIS].ob_x + dial[INFO_IMG_RENAIS].ob_width - 8;
	}


	/* redimenssionnement cadre titre et centrage du titre */
	{
		dial[INFO_CDR_TEXTE].ob_width = (int16)strlen( dial[INFO_CDR_TEXTE].ob_spec.tedinfo->te_ptext ) * FCM_RESCALE_WCHAR;

//FCM_CONSOLE_DEBUG1("dial[INFO_CDR_TEXTE].ob_spec.tedinfo->te_ptext={%s}", dial[INFO_CDR_TEXTE].ob_spec.tedinfo->te_ptext );
//FCM_CONSOLE_DEBUG1("strlen( dial[INFO_CDR_TEXTE].ob_spec.tedinfo->te_ptext )=%d", (int16)strlen( dial[INFO_CDR_TEXTE].ob_spec.tedinfo->te_ptext ));
//FCM_CONSOLE_DEBUG1("dial[INFO_CDR_TEXTE].ob_width=%d", dial[INFO_CDR_TEXTE].ob_width);

		dial[INFO_CDR_TITRE].ob_width = MAX( (dial[INFO_CDR_TEXTE].ob_width + (FCM_RESCALE_ESPACE*2)), (dial[INFO_IMG_RENAIS].ob_x + 16 - dial[INFO_CDR_INVISIB].ob_x));
		dial[INFO_CDR_OMBRE].ob_width = dial[INFO_CDR_TITRE].ob_width;

//FCM_CONSOLE_DEBUG1("dial[INFO_CDR_TITRE].ob_width=%d", dial[INFO_CDR_TITRE].ob_width );

		dial[INFO_CDR_TEXTE].ob_x = (dial[INFO_CDR_TITRE].ob_width - dial[INFO_CDR_TEXTE].ob_width) / 2;
//FCM_CONSOLE_DEBUG1("dial[INFO_CDR_TEXTE].ob_x=%d", dial[INFO_CDR_TEXTE].ob_x );
	}


	/* dimension du fond */
	dial[0].ob_width  = form_w + FCM_RESCALE_MARGE_DROITE;
	dial[0].ob_height = dial[INFO_COEUR_TXT].ob_y + dial[INFO_COEUR_TXT].ob_height + (FCM_RESCALE_MARGE_BAS/2);


	return;


}

