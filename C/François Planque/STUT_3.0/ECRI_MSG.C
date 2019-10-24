/*
 * ecri_msg.c
 *
 * Purpose:
 * -------- 
 * ecriture des messages d'une rubrique
 *
 * History:
 * --------
 * 21.01.95: fplanque: Created
 */

 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"ECRI_MSG.C v1.00 - 03.95"
 
/*
 * System headers:
 */
	#include	<stdio.h>					/* header standard */
	#include <string.h>					/* header tt de chaines */
   

/*
 * Custom headers:
 */
	#include "SPEC_PU.H"
	#include "S_MALLOC.H"
	#include "DEF_ARBO.H"
	#include "DATPG_PU.H"
	#include "DBSYS_PU.H"
	#include	"DEBUG_PU.H"	
	#include	"LISTS_PU.H"
	#include	"SERV_PU.H"
	#include	"LINE0_PU.H"
	#include	"DBINT_PU.H"
	#include	"IOFLD_PU.H"
	#include "GENRC_PU.H"
	#include "TERM_PU.H"
	#include "TEXT_PU.H"
	#include	"SERCOMPU.H"


	static	void	Record_MessageToDB( 
			VOIE *	pVoie_curr, 
			BOOL		b_Private );		/* In: !=0 si le message est priv‚ */

/*
 * --------------------------- METHODES -------------------------------
 */

/*
 * EcriMsg_ENPG(-)
 *
 * Purpose:
 * --------
 * Traitrement des initialisations ENTER PAGE
 *
 * History:
 * --------
 * 21.01.95: fplanque: Created
 */
void	EcriMsg_ENPG(
			VOIE	*	pVoie_curr )		/* In: Voie concern‚e */
{
	/*
	 * Ouvre base de donn‚es:
	 */
	register_action( pVoie_curr, OPDB, FB_RUB, 0, NULL ); 
	/*
	 * Affiche donn‚es 
	 */
	register_action( pVoie_curr, DDAT, 0, 0, NULL );
}



/*
 * EcriMsg_DispData(-)
 *
 * Purpose:
 * --------
 * Affiche les donn‚es initiales … l'‚cran:
 *
 * Notes:
 * ------
 * Ceci n'est normalement ‚x‚cut‚ qu'une seule fois … l'entr‚e de la page
 *
 * History:
 * --------
 * 10.01.95: fplanque: Created based on LectMsg_DispData()
 * 24.01.95: appel de OutFields_DisplayGroup()
 */
void	EcriMsg_DispData(
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{
	/*
	 * Affichage champs groupe 1 (commentaire...):
	 */
	OutFields_DisplayGroup( pVoie_curr, 1, 0, 0 );
}




/*
 * keyaction_ecri_msg(-)
 *
 * Purpose:
 * --------
 * R‚agit … la touche press‚ sur une page d'ECRITURE
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 27.11.94: fplanque: gestion du champ TITLE
 * 05.12.94: utilise Move_FocusTo...
 * 09.12.94: envoi peut valider depuis n'importe kel champ, gestion suite/retour normal
 * 13.12.94: prise en compte de Private
 */
void	keyaction_ecri_msg(
			KEYCODE	curr_keypress, 	/* In: touche press‚e */
			VOIE 	*	pVoie_curr )		/* In: voie concern‚e */
{
	switch( curr_keypress )
	{
		case	KEY_ENVOI:				
		{
			BOOL				b_Private = FALSE0;	/* Par d‚faut, le message est public */
			const char *	cpsz_PublicPrivate;
		
			/*
			 * V‚rifie si le mec tape un mot clef:
			 */
			if( serv_handleKeyword( pVoie_curr, '*' ) )
			{
				break;
			}

			/*
			 * On a pas tap‚ un mot clef:
			 * On traite envoi comme une validation du msg:
			 * Controle si on peut enregistrer: 
			 */
			if( pVoie_curr -> nb_records >= 1 )		/* Limite … 1 enregistrement */
			{	/*
				 * Enregistrement impossible:
				 */
				aff_msg_l0( pVoie_curr, "Duplicata interdit!" );
				break;
			}
		
			/*
			 * V‚rifie si les champs sont correctement remplis:
			 */
			if( ! validate_InFields( pVoie_curr ) )
			{
				break;
			} 

			/*
			 * D‚termine si le message est priv‚:
			 */
		 	cpsz_PublicPrivate = aim_InField( pVoie_curr, FEI_PUBPRIV );
			if( cpsz_PublicPrivate != NULL && (cpsz_PublicPrivate[0] == 'V' || cpsz_PublicPrivate[0] == 'v'))
			{	/*
				 * Le message est priv‚:
				 */
				const char *	cpsz_Destinataire;

				b_Private = TRUE_1;

				/*
				 * On v‚rifie qu'on a sp‚cifi‚ un destinataire:
				 */
			 	cpsz_Destinataire = aim_InField( pVoie_curr, FEI_DEST );
				if( cpsz_Destinataire == NULL || cpsz_Destinataire[0] == '\0' ) 
				{	/*
					 * Message priv‚ sans destinataire:
					 */
					aff_msg_l0( pVoie_curr, "Msg Priv‚ sans Destinataire!" );
					Move_FocusToInField_byFnct( pVoie_curr, FEI_DEST, FEI_DEST );
					break;
				}
				
			}

			/*
		 	 * On va enregister: 
			 */
			affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */
			add_textinf( pVoie_curr -> wi_params, "   Enregistrement du message" );
			aff_msg_l0( pVoie_curr, "Enregistrement du message." );

			/*
		 	 * ----------------------------------
			 * Enregistrement des champs ‚dit‚es:
		 	 * ----------------------------------
			 */
			Record_MessageToDB( pVoie_curr, b_Private );

			/*
			 * Demande Changement de page:
			 */
			follow_KeyArboLink( pVoie_curr, curr_keypress );
		}
			break;


		case	KEY_SUITE:
			Move_FocusToNextInField( pVoie_curr );
			break;

		case	KEY_RETOUR:
			Move_FocusToPrevInField( pVoie_curr );
			break;

		case	KEY_GUIDE:
			/*
			 * test:
			 */
			/*	InField_Clear( pVoie_curr, pVoie_curr -> pIOField_CurrIn ); */
			
		case	KEY_REPET:
		case	KEY_SOMM:
			affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */
			/*
			 * Demande Changement de page:
			 */
			follow_KeyArboLink( pVoie_curr, curr_keypress );
			break;

	}
}



/*
 * Record_MessageToDB(-)
 *
 * Purpose:
 * --------
 * Enregistrement un message ‚dit‚
 * ex: message en rubrique
 * G‚n‚ralement aprŠs appui sur ENVOI!
 *
 * Algorythm:
 * ----------  
 *
 * Notes:
 * ------
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 17.05.94: fplanque: initialise Locks lors de la cr‚ation du message
 * 16.11.94: ajoute du champ MPSE
 * 18.11.94: DSTA prend nom de la rub comme destinataire
 * 29.11.94: nouveau systeme de cr‚ation de fields
 * 01.12.94: cr‚ation titre
 * 14.12.94 gestion d'un destinataire particulier
 */
void	Record_MessageToDB( 
			VOIE *	pVoie_curr, 
			BOOL		b_Private )		/* In: !=0 si le message est priv‚ */
{
	IOFIELD			*	pInField;

	RECORD_FIELD 	*	pListElt_First;
	RECORD_FIELD 	*	pListElt_New;
	RECORD_FIELD 	*	pListElt_Prev = NULL;
	
	COMPACT_RECORD	*	pCompRec;			/* Message compact‚ */
	DATAPAGE			*	pDataPage_DB = pVoie_curr -> database;	/* Base de donn‚es concern‚e */
	char				*	pisz_tmp;
	
	/*
	 * +---------------------------------------------------+ 
	 * |  Cr‚ation des champs du message en liste chain‚e  |
	 * +---------------------------------------------------+ 
	 * ----
	 * HEAD
	 * ----
	 */
	pListElt_New	= Create_HeaderFld( &G_RecNb_Null, b_Private );
	pListElt_Prev	= Append_ToSingleLinkList( pListElt_Prev, pListElt_New );
	pListElt_First	= pListElt_Prev;

	/*
	 * ----
	 * DSTA
	 * ----
	 */
	strcpy( G_tmp_buffer, "ALL" );	/* Par d‚faut */

	if( get_InFieldPars( pVoie_curr, FEI_DEST, &pInField ) == FLD_READY )
	{	/*
		 * Le message est adress‚ … une personne en particulier:
		 */
		char * pMsz_Dest;
		compact_text( pInField -> pTextInfo -> firstline -> next, FMTMODE_SGLETEXTLINE, &pMsz_Dest );
		  
		if( pMsz_Dest[0] != '\0' )
		{	/*
			 * Si un destinataire a ‚t‚ sp‚cifi‚:
			 */
			strcpy( G_tmp_buffer, pMsz_Dest );
		}
		
		FREE( pMsz_Dest );
	}

	strcat( G_tmp_buffer, "@" );
	strcat( G_tmp_buffer, pDataPage_DB -> nom );	/* Nom de la rubrique */
	pisz_tmp = strBchr( G_tmp_buffer, '.' );
	if( pisz_tmp != NULL )
	{	/* 
		 * Efface l'extension (… partir du point)
		 */
		*pisz_tmp = '\0'; 
	}
	strcat( G_tmp_buffer, ".RUB.LOCAL" );	/* Localisation */
	/*
	 * Cr‚e champ DSTA:
	 */
	pListElt_New = Create_SimpleRecFld( 'DSTA', G_tmp_buffer );
	pListElt_Prev = Append_ToSingleLinkList( pListElt_Prev, pListElt_New );


	/*
	 * ----
	 * MPSE
	 * CTCA
	 * ----
	 */
	if( pVoie_curr -> pMsz_Login != NULL )
	{
		pListElt_New = Create_SimpleRecFld( 'MPSE', pVoie_curr -> pMsz_Login );
		pListElt_Prev = Append_ToSingleLinkList( pListElt_Prev, pListElt_New );

		pListElt_New = Create_SimpleRecFld( 'CTCA', pVoie_curr -> pMsz_Login );
		pListElt_Prev = Append_ToSingleLinkList( pListElt_Prev, pListElt_New );
	}


	/*
	 * ----
	 * MTIT
	 * ----
	 */
	if( get_InFieldPars( pVoie_curr, FEI_TITLE, &pInField ) == FLD_READY )
	{
		pListElt_New	 = Create_TextRecFld( 'MTIT', pInField );
		pListElt_Prev	 = Append_ToSingleLinkList( pListElt_Prev, pListElt_New );
	}


	/*
	 * ----
	 * MTXT
	 * ----
    * Trouve 1ere ligne du texte
	 */
	if( get_InFieldPars( pVoie_curr, FEI_TEXT, &pInField ) == FLD_READY )
	{
		pListElt_New	 = Create_TextRecFld( 'MTXT', pInField );
		pListElt_Prev	 = Append_ToSingleLinkList( pListElt_Prev, pListElt_New );
	}


	/*
	 * ----
	 * FOOT
	 * ----
	 */
	pListElt_New	= Create_FooterFld( );
	pListElt_Prev	= Append_ToSingleLinkList( pListElt_Prev, pListElt_New );
	

	/*
	 * +----------------------------------+
	 * |  Composition du message complet  |
	 * +----------------------------------+
	 */
	pCompRec = Create_CompactRecord( pListElt_First );


	/*
	 * +------------------------------------+
	 * | LibŠre liste de champs temporaires |
	 * +------------------------------------+
	 */
	pListElt_New = pListElt_First;
	while( pListElt_New != NULL )
	{
		pListElt_Prev = pListElt_New;
		pListElt_New = pListElt_New -> next;
		
		FREE( pListElt_Prev -> info.string );
		FREE( pListElt_Prev );	
	}

	
	/*
	 * +----------------------------------------------------+ 
	 * |  Insertion de ce message dans la base de donn‚es:  |
	 * +----------------------------------------------------+
	 */
	DBInt_AppendCompRecToDB( pVoie_curr, pCompRec, pDataPage_DB );


	/*
	 * Un enregistrement de plus d'effectu‚ sur cette page arbo: 
	 */
	pVoie_curr -> nb_records ++ ;

}

