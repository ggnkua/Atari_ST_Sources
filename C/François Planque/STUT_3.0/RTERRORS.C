/*
 * rterrors.c
 *
 * Purpose:
 * --------
 * Routines de gestion des 'run time errors"
 * En particulier gestion d'un log ds une fenetre
 *
 * History:
 * --------
 * 26.09.94: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"RTERRORS.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>
	#include <string.h>   
	#include <stdlib.h>   
	#include	<errno.h>

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"
	#include	"WIN_PU.H"
	#include	"TEXT_PU.H"
	#include	"RTERR_PU.H"	
	#include	"FILES_PU.H"	


/*
 * ------------------------- MEMBRES PRIVES ----------------------------
 */
	/*
	 * fenetre de log des erreurs:
	 */
	WIPARAMS	*	M_pWiParams_Errors = NULL;



/*
 * ----------------------- OPERATIONS PRIVEES -------------------------
 */

 
/*
 * ------------------------ IMPLEMENTATION -------------------------
 */


/*
 * errors_CreateWinText(-)
 *
 * Purpose:
 * --------
 * Pr‚paration du log d'erreurs pour son affichage ne fenetre
 * ainsi que de ses paramŠtres d'affichage
 *
 * History:
 * --------
 * 25.05.94: fplanque: Created based on debug_CreateWinText()
 */
int	errors_CreateWinText( 						/* Out: OK1 si ouverture OK */
			TEXT_DRAWPAR * *	ppTextDrawPar )	/* In: Ptr sur conteneur des params d'affichage nlle fenetre */
{
	/*
	 * Cr‚e texte vide
	 */
	TEXTINFO * pTextInfo_Errors = create_TextInfo();

	/*
	 * Cr‚e des paramŠtres d'affichages pour ce texte:
	 */
	*ppTextDrawPar = create_TextDrawPar( pTextInfo_Errors, 200 );

	if ( *ppTextDrawPar == NULL )
	{
		return	WRONG0;
	}

	return	OK1;
}



/*
 * errors_OpenLogWin(-)
 *
 * Purpose:
 * --------
 * Param‚trage d'une fenˆtre texte en vue de son ouverture
 *
 * History:
 * --------
 * 26.09.94: fplanque: Created based on open_text()
 */
void	errors_OpenLogWin( 
			WIPARAMS 	 *	pWiParams, 			/* In: fenetre concern‚e */
			TEXT_DRAWPAR *	pTextDrawPar )		/* In: Parals d'aff texte */
{
	TEXTINFO *	pTextInfo = pTextDrawPar -> pTextInfo;

	/* 
	 * Pointe sur infos texte: 
	 */
	pWiParams -> content_ptr.textInfo= pTextInfo;	

	/* 
	 * Pointe sur informations texte en RAM: 
	 */
	pWiParams -> draw_ptr.pTextDrawPar	= pTextDrawPar;	

	calc_textSizeW( pWiParams );
	calc_textSizeH( pWiParams );
	pWiParams -> h_step = (pTextDrawPar -> n_cell_w) *8;	/* Saut par 8 car */
	pWiParams -> v_step = pTextDrawPar -> n_cell_h;		/* Saut par ligne */

	/*
	 * Options menu: 
	 */
	pWiParams -> menu_options.savedisk	= TRUE_1;	/* On peut sauver le contenu de la fenˆtre */
	pWiParams -> menu_options.affichage = PARAFF_TEXT;	/* On peut r‚gler la taille du texte */

	/*
	 * m‚mo adr Fenetres d'erreurs:
	 */
	M_pWiParams_Errors = pWiParams; 	/* Adr de la fenˆtre de debug */
	
}



/*
 * errors_CloseLogWin(-)
 *
 * Purpose:
 * --------
 * Fermeture du log d'erreurs ds fenetre
 * Appell‚ lors de la fermeture de la fenetre de type TYP_ERRORS
 * 
 * History:
 * --------
 * 26.09.94: fplanque: Created
 */
void errors_CloseLogWin(
			WIPARAMS	*	pWiParams_Closed )
{
	/*
	 * On vient de fermer la fenetre:
	 * il n'y a donc plus de fenetre de log des erreurs:
	 */
	M_pWiParams_Errors = NULL;

	/*
	 * Efface le log des erreurs en RAM:
	 * LibŠre le texte formatt‚:
	 */
	free_formatext( pWiParams_Closed -> draw_ptr.pTextDrawPar -> pTextInfo );

}




/*
 * errorLog_AddLine(-)
 *
 * Purpose:
 * --------
 *	Enregistrement d'un message d'erreur dans fenetre log
 * 
 * History:
 * --------
 * 25.09.94: fplanque: Created
 */
void	errorLog_AddLine(
			const char	* cpsz_ErrorMsg )
{
	if( M_pWiParams_Errors == NULL )
	{	/*
		 * Si fen d'erreurs pas encore ouverte, on va l'ouvrir:
		 */

 		ouvre_fenetre( CLASS_TEXT, TYP_ERRORS,
 							NULL,NULL,NULL,
 							" Messages d'erreur " );
	}

	/* text_addLineToEnd( M_pTextInfo_Errors, cpsz_ErrorMsg ); */

	add_textinf( M_pWiParams_Errors, cpsz_ErrorMsg );
}



/*
 * -------------------- BOITES d'ALERTES ERREUR ------------------
 */



/*
 * erreur(-)
 *
 * Purpose:
 * --------
 * Affiche boite d'alerte avec texte d'erreur
 *
 * History:
 * --------
 * 1992: fplanque: Created
 */
void erreur( const char *texte_erreur )
{
	int	choix;
	
	choix=form_alert(1,texte_erreur);

	if (choix == 1)
		exit( 0 );				/* Termine prg */
}


/*
 * erreur_rsrc(-)
 *
 * Purpose:
 * --------
 * Signale erreur dans fichier ressources
 *
 * History:
 * --------
 * 1992: fplanque: Created
 */
void erreur_rsrc( void )
{
	erreur("[3][Erreur innatendue!|Le fichier RSC|a du ˆtre endommag‚!][Quitter|Continuer]");
}



/*
 * alert(-)
 *
 * Purpose:
 * --------
 * Affiche boite d'alerte avec message d'erreur correspondant … un
 * certain code d'erreur
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 19.06.94: Plein de nouveaux codes d'erreur
 * 19.06.94: Fonction renvoie maintenant le bouton press‚
 */   
int alert( int type, ... )
{
	static	char	*unknown = "[3][Erreur No:         |                           |...][   OK   ]";
	int		n_reponse = 1;			/* Par d‚faut */

	switch( type )
	{
		case ENOENT:						/* Errno 2 */
			form_error( 2 );					/* File not found */
			break;
			
		case ENOTDIR:						/* Errno 20 */
			form_error( 3 );					/* Path not found */
			break;
			
		case	DLG_QUIT:				
			n_reponse = form_alert( 1, "[2][|"
														"Voulez-vous|"
														"vraiment quitter?]"
														"[Quitter|Annuler]");
			break;
			
		case	DLG_SAVE_QUIT:				
			n_reponse = form_alert( 1,"[3][Certains fichiers charg‚s|"
													"en m‚moire on ‚t‚ modifi‚s|"
													"mais n'ont pas encore ‚t‚|"
													"sauv‚s sur disque. Voulez|"
													"vous les sauver maintenant?]"
													"[Sauver|Jeter|Annuler]");
			break;

		case	DLG_SAVEBEFORECLOSE:
			n_reponse = form_alert( 1,"[2][Ce document a ‚t‚ modifi‚!|"
													"Voulez-vous sauver ces|"
													"modifications avant de|"
													"fermer le document?]"
													"[Sauver|Jeter|Annuler]");
			break;

		case	PERR_IMPOSSIBLE_OP:
			form_alert( 1,"[1][|"
									"Cette op‚ration|"
									"est impossible!]"
									"[ Abandon ]");
			break;
			
		case	PERR_NO_FILENAME:
			n_reponse = form_alert( 1 , "[3][|"
														"Vous n'avez pas donn‚|"
														"de nom de fichier!]"
														"[R‚essayer|Abandonner]");
			break;
			
		case	PERR_INCORRECT_PATH:
			n_reponse = form_alert( 1,"[3][|"
													"Le chemin d'accŠs sp‚cifi‚|"
													"est incorrect !]"
													"[R‚essayer|Abandonner]");
			break;

		case NOMEM_OPENDOC:
			form_alert( 1,"[3][|"
									"Il n'y a pas assez|"
									"de m‚moire libre pour|"
									"ouvrir ce document!]"
									"[ Abandon ]");
			break;

		case NOMEM_OPENFILE:
			form_alert( 1,"[3][|"
									"Il n'y a pas assez|"
									"de m‚moire libre pour|"
									"charger ce fichier!]"
									"[ Abandon ]");
			break;

		case NOMEM_SAVEDOC:
			form_alert( 1,"[3][|"
									"Il n'y a pas assez|"
									"de m‚moire libre pour|"
									"sauver ce document!]"
									"[ Abandon ]");
			break;

		case NOMEM_OPENWIN:
			form_alert( 1,"[3][D‚sol‚, il n'y a pas|"
									"assez de m‚moire interne|"
									"disponible pour ouvrir|"
									"une nouvelle fenˆtre!]"
									"[ Abandon ]");
			break;
		
		case NOMORE_WIN:
			form_alert( 1,"[1][D‚sol‚, il n'y a plus|"
									"de fenˆtre disponible|"
									"sur le bureau. Fermez|"
									"une fenˆtre inutilis‚e.]"
									"[ Abandon ]");
			break;

		case NOMEM_NEWBUF:
			form_alert( 1,"[1][D‚sol‚, il n'y a pas assez|"
									"de m‚moire interne pour|"
									"allouer un buffer de la|"
									"taille demand‚e. La taille|"
									"pr‚c‚dente est conserv‚e.]"
									"[Poursuivre]");
			break;
						

		case	QUERY_FILEFORMAT:
			n_reponse = form_alert( 1,"[2][Le fichier auquel vous essayez|"
													"d'acc‚der ne peut ˆtre exploit‚|"
													"automatiquement. D‚sirez-vous|"
													"sp‚cifier explicitement le|"
													"format de donn‚es utilis‚?]"
													"[Sp‚cifier|Abandon]");
			break;	


		case	QUERY_VDTFORMAT:
			n_reponse = form_alert( 1,"[2][S'agit-il d'un fichier|"
													"de pages vid‚otex cr‚‚|"
													"par STUT ONE version|"
													"2.3, 2.4, 2.5 ou 2.6?]"
													"[Oui|Non]");
			break;	


		case BAD_FILEFMT:
			form_alert( 1,"[1][Le format du fichier auquel|"
									"vous essayez d'acc‚der n'est|"
									"PAS RECONNU par la pr‚sente|"
									"version du logiciel! Donc:|"
									"Impossible de l'exploiter...]"
									"[ Abandon ]");
			break;
			
		case BAD_HEADFMT:
			form_alert( 1,"[1][Le header du fichier auquel vous|"
									"essayez d'acc‚der pourrait ˆtre|"
									"ALTERE ou bien ICOMPATIBLE avec|"
									"la pr‚sente version du logiciel!|"
									"Donc: Impossible … exploiter...]"
									"[ Abandon ]");
			break;
			
		case BAD_FILEOWN:
			form_alert( 1,"[1][Le fichier auquel vous|"
									"essayez d'acc‚der n'est pas|"
									"au FORMAT Stut One.|"
									"Il a ‚t‚ cr‚‚ par une autre|"
									"application non-compatible.]"
									"[ Abandon ]");
			break;
			
		case BAD_CONTENT:
		{
			static char *texte =   "[1][Op‚ration impossible:|"
												"Le fichier auquel|"
												"vous essayez d'acc‚der|"
												"n'est pas un fichier|"
												"de .............. ! ]"
												"[ Abandon ]";

			/* Argument suppl‚mentaire: */
			int		ftype;			/* Type de fichier */
			/* Argument variable: */
			va_list	adpar;
			/* Initialise ce pointeur: */
			va_start ( adpar, type );	/* Denier arg fixe = type */
			/* RecupŠre argument suppl‚mentaire: */
			ftype = va_arg( adpar, int );		

			/* Fixe type de donn‚es dans le texte: */
			switch ( ftype )
			{
				case	FS_ARBO:
					memcpy ( texte + 88, "d'arborescence !    ", 20 );
					break;

				case	FS_PAGES_ECRAN:
					memcpy ( texte + 88, "de pages ‚cran !    ", 20 );
					break;

				case	FS_INF:
					memcpy ( texte + 88, "de paramŠtres !     ", 20 );
					break;

				case	FS_INI:
					memcpy ( texte + 88, "de configuration !  ", 20 );
					break;

				case	FS_DATAS:
					memcpy ( texte + 88, "de bases de donn‚es!", 20 );
					break;
					
				case	FS_TEXTES:
					memcpy ( texte + 88, "de textes!          ", 20 );
					break;
					
				case	FS_DXF:
					memcpy ( texte + 88, "de donn‚es DXF !    ", 20 );
					break;
					
				default:
					ping();
			}

			/* Affiche alerte */
			form_alert( 1, texte );
			break;
		}
			
		case	UNEXPECTED_FFMT:
			form_alert( 1,"[1][Le fichier auquel vous essayez|"
									"d'acc‚der est endommag‚ et son|"
									"contenu ne peut ˆtre exploit‚!|"
									"(Causes possibles: Fausse manip,|"
									"disque d‚fectueux, virus...)]"
									"[ Abandon ]");
			break;

		case	BAD_VERSION:
			form_alert( 1,"[1][Le format du fichier|"
									"auquel vous essayez|"
									"d'acc‚der ne peut ˆtre|"
									"exploit‚ par cette|"
									"version de STUT ONE.]"
									"[ Abandon ]");
			break;
			
		case	DISK_CANTCREATEDIR:
			/* Ne peux pas cr‚er le dossier */
			form_alert( 1,"[3][Impossible de cr‚er|"
									"le dossier!]"
									"[ Abandon ]");
			break;

		case	DISK_CANTENTERDIR:
			form_alert( 1,"[3][Impossible d'ouvrir|"
									"le dossier!]"
									"[ Abandon ]");
			break;



		default:
			printf("Erreur: %d \n",type);		/* PROVISOIRE */
			form_alert( 1, unknown );
	}

	return	n_reponse;
}

