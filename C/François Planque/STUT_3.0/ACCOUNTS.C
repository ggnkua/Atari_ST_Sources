/*
 * lect_msg.c
 *
 * Purpose:
 * -------- 
 * lecture des messages d'une rubrique:
 *
 * Notes:
 * ------
 *
 * History:
 * --------
 * 18.12.94: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"ACCOUNTS.C v1.00 - 03.95"
          

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
	#include "ACOUNTPU.H"
	#include "TERM_PU.H"
	#include "TEXT_PU.H"
	#include	"SERCOMPU.H"


/*
 * Prototypes:
 */
	static	void	Voie_RecIdData(
				VOIE 			*	pVoie_curr,			/* In: Voie concern‚e */
				const char	*	cpsz_UserName,		/* In: Pseudo */
				const char	*	cpsz_FirstName,	/* In: Pr‚nom */
				const char	*	cpsz_LastName );	/* In: Nom */

	static	void	Record_InFieldsToDB( VOIE *pVoie_curr );


/*
 * --------------------------- METHODES -------------------------------
 */


/*
 * Voie_RecAccntData(-)
 *
 * Purpose:
 * --------
 * La voie m‚morise les nouvelles donn‚es d'identification
 * et les affiche ds la log window au passage
 *
 * Suggest:
 * --------
 * Inclure pointeur sur compte
 *
 * History:
 * --------
 * 14.01.95: fplanque: Crated
 */
void	Voie_RecIdData(
			VOIE 			*	pVoie_curr,			/* In: Voie concern‚e */
			const char	*	cpsz_UserName,		/* In: Pseudo */
			const char	*	cpsz_FirstName,	/* In: Pr‚nom */
			const char	*	cpsz_LastName )	/* In: Nom */
{
	if( cpsz_UserName != NULL )
	{
		sprintf( G_tmp_buffer, "   UserName: %s", cpsz_UserName );
		add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );
	}
	freeOld_dupString( &(pVoie_curr -> pMsz_Login), cpsz_UserName );

	if( cpsz_FirstName != NULL )
	{
		sprintf( G_tmp_buffer, "   Pr‚nom: %s", cpsz_FirstName );
		add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );
	}
	freeOld_dupString( &(pVoie_curr -> pMsz_FirstName), cpsz_FirstName );

	if( cpsz_LastName != NULL )
	{
		sprintf( G_tmp_buffer, "   Nom: %s", cpsz_LastName );
		add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );
	}
	freeOld_dupString( &(pVoie_curr -> pMsz_LastName), cpsz_LastName );
}



/*
 * keyaction_Identification(-)
 *
 * Purpose:
 * --------
 * R‚agit … la touche press‚ sur une page IDENTIFY
 *
 * Suggest:
 * --------
 * Gestion pr‚nom et nom
 *
 * History:
 * --------
 * 13.11.94: fplanque: Created
 * 14.11.94: enhanced
 * 16.11.94: possibilit‚ chgt de page aprŠs entr‚e Lastname
 * 27.11.94: utilise try_FieldMove()
 * 05.12.94: utilise Move_FocusTo...
 */
void	keyaction_Identification(
			KEYCODE	curr_keypress, 
			VOIE 	*	pVoie_curr )
{
	switch( curr_keypress )
	{
		case	KEY_ENVOI:				
		{
			const char *	cpsz_UserName;
			const char *	cpsz_FirstName;
			const char *	cpsz_LastName;
			const char *	cpsz_Password;
		
			/*
			 * V‚rifie si le mec tape un mot clef:
			 */
			if( serv_handleKeyword( pVoie_curr, '*' ) )
			{
				break;
			}
		
			/*
			 * Le mec n'a pas tap‚ de mot clef:
			 * C'est donc une validation de son login:
			 * V‚rifie si les champs sont correctement remplis:
			 */
			if( ! validate_InFields( pVoie_curr ) )
			{
				break;
			} 
			 
			/* 
			 * On va chercher son compte:
			 */

			cpsz_UserName	= aim_InField( pVoie_curr, FEI_USERNAME );
			cpsz_FirstName = aim_InField( pVoie_curr, FEI_FIRSTNAME );
			cpsz_LastName 	= aim_InField( pVoie_curr, FEI_LASTNAME );
		 	cpsz_Password 	= aim_InField( pVoie_curr, FEI_PASSWORD );

			if( cpsz_UserName  == NULL && 
				 cpsz_FirstName == NULL &&
				 cpsz_LastName  == NULL )
			{	/*
				 * S'il n'y a pas de champ pour renseigner sur l'identit‚ du cnt:
				 */
				aff_msg_l0( pVoie_curr, "Impossible de vous identifier!" );
				add_textinf( pVoie_curr -> wi_params, "  Aucun champ pour identifier le connect‚!" );
				break;
			}

			/*
			 * Tente de trouver le connect‚ dans l'annuaire:
			 */
			{
				DATAPAGE			*	pDataPg_dbase = pVoie_curr -> database;	/* Base de donn‚es concern‚e */
				DATA_RECORDS	*	pDataRecords = pDataPg_dbase -> data.records;	/* Infos sur les enregistrements */
				COMPACT_RECORD *	pCompactRec_Account;

				/*
				 * Cherche compte:
				 */
				pCompactRec_Account = Find_CompactRecByField( pDataRecords -> first_record, 'USER', cpsz_UserName );

				if( pCompactRec_Account != NULL )
				{
					COMPACT_FIELD	* pCompactFld_Password;
				
					/*
					 * Cherche password:
					 */
					pCompactFld_Password = Find_FieldinCompactRecord( pCompactRec_Account, 'PASS' );
					if( pCompactFld_Password == NULL )
					{
						aff_msg_l0( pVoie_curr, "Compte incorrectement valid‚!" );
						sprintf( G_tmp_buffer, "  Pas de mot de passe ('PASS') pour [%s]!", cpsz_UserName );
						add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );
						break;
					}	
					
					if( strcmp( (char *) (pCompactFld_Password -> bytes), cpsz_Password ) != 0 )
					{	/*
						 * Password incorrect:
						 */
						aff_msg_l0( pVoie_curr, "Mot de passe incorrect!" );
						Move_FocusToInField_byFnct( pVoie_curr, FEI_PASSWORD, FE_LOGINDENIED );
						break;					
					}
				}
			}

			/*
			 * Valid‚:
			 */
			affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */

			/*
			 * m‚morise pseudo, nom, pr‚nom et les affiche:
			 */
			Voie_RecIdData( pVoie_curr, cpsz_UserName, cpsz_FirstName, cpsz_LastName );

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

		case	KEY_REPET:
		case	KEY_GUIDE:
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
 * keyaction_NewAccount(-)
 *
 * Purpose:
 * --------
 * R‚agit … la touche press‚ sur une page NEW_ACCOUNT
 *
 * Suggest:
 * ------
 * Gestion pr‚nom et nom
 *
 * History:
 * --------
 * 05.12.94: fplanque: Created
 * 14.01.95: v‚rifie si compte existe d‚j…; m‚mo username
 */
void	keyaction_NewAccount(
			KEYCODE	curr_keypress, 
			VOIE 	*	pVoie_curr )
{
	switch( curr_keypress )
	{
		case	KEY_ENVOI:				
		{
			const char *	cpsz_UserName;
			const char *	cpsz_FirstName;
			const char *	cpsz_LastName;

			/*
			 * V‚rifie si le mec tape un mot clef:
			 */
			if( serv_handleKeyword( pVoie_curr, '*' ) )
			{
				break;
			}

			/*
			 * V‚rifie si les champs sont correctement remplis:
			 */
			if( ! validate_InFields( pVoie_curr ) )
			{
				break;
			} 
			
			affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */

			/*
			 * V‚rifie si le UserName n'existe pas d‚j…:
			 */
			cpsz_UserName	= aim_InField( pVoie_curr, FEI_USERNAME );
			cpsz_FirstName = aim_InField( pVoie_curr, FEI_FIRSTNAME );
			cpsz_LastName 	= aim_InField( pVoie_curr, FEI_LASTNAME );

			if( cpsz_UserName  == NULL && 
				 cpsz_FirstName == NULL &&
				 cpsz_LastName  == NULL )
			{	/*
				 * S'il n'y a pas de champ pour renseigner sur l'identit‚ du cnt:
				 */
				aff_msg_l0( pVoie_curr, "Impossible de vous identifier!" );
				add_textinf( pVoie_curr -> wi_params, "  Aucun champ pour identifier le connect‚!" );
				break;
			}
			
			{
				DATAPAGE			*	pDataPg_dbase = pVoie_curr -> database;	/* Base de donn‚es concern‚e */
				DATA_RECORDS	*	pDataRecords = pDataPg_dbase -> data.records;	/* Infos sur les enregistrements */
				COMPACT_RECORD *	pCompactRec_Account;
	
				/*
				 * Cherche compte:
				 */
				pCompactRec_Account = Find_CompactRecByField( pDataRecords -> first_record, 'USER', cpsz_UserName );

				if( pCompactRec_Account != NULL )
				{
					aff_msg_l0( pVoie_curr, "Ce compte existe d‚j…!" );
					sprintf( G_tmp_buffer, "   Le compte [%s] existe d‚j…!", cpsz_UserName );
					add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );
					break;
				}	

			}
			
			/*
		 	 * On va cr‚er le nouveau compte: 
			 */
			aff_msg_l0( pVoie_curr, "Cr‚ation du compte." );
			add_textinf( pVoie_curr -> wi_params, "   Cr‚ation d'un nouveau compte..." );

			/*
			 * m‚morise pseudo, nom, pr‚nom et les affiche:
			 */
			Voie_RecIdData( pVoie_curr, cpsz_UserName, cpsz_FirstName, cpsz_LastName );

			/*
		 	 * ----------------------------------
			 * Enregistrement des champs ‚dit‚es:
		 	 * ----------------------------------
			 */
			Record_InFieldsToDB( pVoie_curr );

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

		case	KEY_REPET:
		case	KEY_GUIDE:
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
 * Record_InFieldsToDB(-)
 *
 * Purpose:
 * --------
 * Enregistrement les donn‚es d'un formulaire ds une base de donn‚es
 * G‚n‚ralement aprŠs appui sur ENVOI!
 *
 * Notes:
 * ------
 *
 * History:
 * --------
 * 04.12.94: fplanque: derived from Record_MessageToDB
 * 23.01.95: utilse le CodeChamp interne des params du champ, pour signer chaque champ!
 */
void	Record_InFieldsToDB( 
				VOIE	*	pVoie_curr )	/* In: Voie courante */
{
	IOFIELD			*	pInField_Curr;

	RECORD_FIELD 	*	pListElt_First;
	RECORD_FIELD 	*	pListElt_New;
	RECORD_FIELD 	*	pListElt_Prev = NULL;
	
	COMPACT_RECORD	*	compact_msg;			/* Message compact‚ */
	DATAPAGE			*	pDataPage_DB = pVoie_curr -> database;	/* Base de donn‚es concern‚e */
	
	/*
	 * +---------------------------------------------------+ 
	 * |  Cr‚ation des champs du message en liste chain‚e  |
	 * +---------------------------------------------------+ 
	 * ----
	 * HEAD
	 * ----
	 */
	pListElt_New	= Create_HeaderFld( &G_RecNb_Null, TRUE_1 );
	pListElt_Prev = Append_ToSingleLinkList( pListElt_Prev, pListElt_New );
	pListElt_First	= pListElt_Prev;


	/*
	 * ----
	 * Ajout du contenu de tous les champs ‚ditables
	 * de la page arbo, cad du formulaire:
	 * ----
	 */
	for(	pInField_Curr = pVoie_curr -> pIOField_ListIn;
			pInField_Curr != NULL;
			pInField_Curr = pInField_Curr -> p_next )
	{	/*
		 * Pour chaque champ de saisie du formulaire:
		 */
		pListElt_New	 = Create_TextRecFld( pInField_Curr -> FPar.Input -> ul_CodeChamp, pInField_Curr );

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
	compact_msg = Create_CompactRecord( pListElt_First );


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
	 * +---------------------------------------------------+ 
	 * |  Insertion de ce RECORD dans la base de donn‚es:  |
	 * +---------------------------------------------------+
	 */
	DBInt_AppendCompRecToDB( pVoie_curr, compact_msg, pDataPage_DB );

	
	/*
	 * Un enregistrement de plus d'effectu‚ sur cette page arbo: 
	 */
	pVoie_curr -> nb_records ++ ;

}


