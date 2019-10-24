/*
 * DispText.c
 *
 * Purpose:
 * -------- 
 * Affichage d'un texte
 *
 * History:
 * --------
 * 05.01.95: fplanque: Created
 */

 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"DISPTEXT.C v1.00 - 03.95"

/*
 * System headers:
 */
	#include	<stdio.h>					/* header standard */
	#include <string.h>					/* header tt de chaines */
	#include	<stdlib.h>					/* Pour malloc etc.. */
   

/*
 * Custom headers:
 */
	#include "ARB_OUT.H"
	#include "DEF_ARBO.H"

	#include "SPEC_PU.H"

	#include "DBSYS_PU.H"
	#include	"DEBUG_PU.H"	
	#include	"SERV_PU.H"
	#include	"LINE0_PU.H"
	#include	"IOFLD_PU.H"
	#include "LECTM_PU.H"		/* On y empreinte certaines routines */
	#include "DISPT_PU.H"
	#include "GENRC_PU.H"
	#include "TERM_PU.H"
	#include "TEXT_PU.H"
	#include "SERCOMPU.H"


/*
 * --------------------------- METHODES -------------------------------
 */


/*
 * DispText_ENPG(-)
 *
 * Purpose:
 * --------
 * Traitrement des initialisations ENTER PAGE
 *
 * History:
 * --------
 * 05.01.94: fplanque: Created
 * 24.01.95: demande un DPAG
 */
void	DispText_ENPG(
			VOIE	*	pVoie_curr )		/* In: Voie concern‚e */
{
	/*
	 * Cherche et sauve le champ qui affichera le texte
	 * et qui pourra ˆtre scroll‚:
	 */
	pVoie_curr -> pOutputFPar_CurrOut = Find_OutField( pVoie_curr, FO_TEXT );

	/*
	 * Ouvre fichier texte:
	 */
	register_action( pVoie_curr, OTXT, FT_TEXT, 0, NULL );

	/*
	 * Affiche donn‚es:
	 */
	register_action( pVoie_curr, DDAT, 0, 0, NULL );
	register_action( pVoie_curr, DPAG, 0, 0, NULL );
}




/*
 * DispText_DispData(-)
 *
 * Purpose:
 * --------
 * Affiche les donn‚es initiales … l'‚cran:
 *
 * History:
 * --------
 * 06.01.95: fplanque: Created based on LectMsg_DispMsg()
 * 08.01.95: affiche commentaire
 * 24.01.95: appel de OutFields_DisplayGroup(); prepare texte … afficher
 */
void	DispText_DispData( 
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{
	/*
	 * -------------------------
	 * Affichage champs groupe 1 (commentaire...):
	 * -------------------------
	 */
	OutFields_DisplayGroup( pVoie_curr, 1, 0, 0 );

	/*
	 * Pr‚paration du texte demand‚
	 * qui sera affich‚ dans le groupe 4
	 * et qui pourra ˆtre scroll‚ par la suite:
	 */
	if( pVoie_curr -> pOutputFPar_CurrOut != NULL )
	{	/*
		 * S'il y a un champ d'affichage du texte (scrollable):
		 */
		DATABLOCK	* pDataBlk_Text = pVoie_curr -> pDataPage_OpenText -> data.dataBlock;

		pVoie_curr -> pIOField_CurrOut = IOField_PrepareText( pVoie_curr -> pOutputFPar_CurrOut, pDataBlk_Text -> p_block, pDataBlk_Text -> ul_length );
	}

}



/*
 * DispText_KeyAction(-)
 *
 * Purpose:
 * --------
 * R‚agit … la touche press‚e sur une page d'affichage de TEXTE
 *
 * Suggest: 
 * --------
 * Provisoire:
 * Pas de v‚rification si le readlock du nouveau message est accept‚
 *
 * History:
 * --------
 * 06.01.95: fplanque: Created based on LectMsg_..
 */
void	DispText_KeyAction( 
			KEYCODE	curr_keypress, /* In: Touche press‚e */
			VOIE	*	pVoie_curr )	/* In: Voie concern‚e */
{
	switch( curr_keypress )
	{
		case	KEY_RETOUR:
		case	KEY_SUITE:
		{
			IOFIELD			*	pIOField_CurrOut = pVoie_curr -> pIOField_CurrOut;
			int					nb_VisibleLines;
		
			/* 
			 * Teste s'il y a des messages: 
			 */
			if( pIOField_CurrOut == NULL )
			{
				aff_msg_l0( pVoie_curr, "Pas de texte!" );
				break;
			}

			affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */
		 	
		 	/*
		 	 * Nbre de lignes affich‚es:
		 	 */
		 	nb_VisibleLines = pIOField_CurrOut -> FPar.Input -> h;
		 	 
			if( curr_keypress == KEY_RETOUR )
			{	/*
				 * Tentative de recul: 
				 */
				if( IOField_MoveTopLine( pIOField_CurrOut, -nb_VisibleLines ) < 0 )
				{	/*
					 * On est pas sur la premiŠre page du message:
					 */
					Generic_DisplayPageChange( pVoie_curr );
					break;
				}
				
			}
			else
			{	/*
				 * Tentative d'avancement: 
				 */
				TEXTLINE	*	pTextLine_CurrTop = pIOField_CurrOut -> pTextLine_Top;
				 
				if( IOField_MoveTopLine( pIOField_CurrOut, nb_VisibleLines ) == nb_VisibleLines )
				{	/*
					 * On est pas sur la derniŠre page du message:
					 */
					Generic_DisplayPageChange( pVoie_curr );
					break;
				}
				
				/*
				 * On ne se d‚place pas dans le message:
				 */
				pIOField_CurrOut -> pTextLine_Top = pTextLine_CurrTop;

			}
		
		}	
			break;
			
		
		case	KEY_ENVOI:				
			if( ! serv_handleKeyword( pVoie_curr, '\0' ) )
			{	/*
				 * Si pas de mot clef:
				 */
				affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */

				/*
				 * Demande Changement de page:
				 */
				follow_KeyArboLink( pVoie_curr, curr_keypress );
			}
			break;


		case	KEY_ANNUL:
		case	KEY_REPET:
		case	KEY_GUIDE:
		case	KEY_SOMM:
		case	KEY_CORREC:
			affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */
			/*
			 * Demande Changement de page:
			 */
			follow_KeyArboLink( pVoie_curr, curr_keypress );
			break;

		default:
			signale("Code touche inconnu");
	}

}

