/*
 * DbInterface.c
 *
 * Purpose:
 * --------
 * Interface entre serveur et gestion de bases de donn‚es DXF
 *
 * History:
 * --------
 * 08.12.94: fplanque: Created
 */

   #include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"DBINTERF.C v1.00 - 03.95"

/*
 * System headers:
 */
	#include <stdio.h>
	#include <string.h>
	   

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"
	#include "S_MALLOC.H"
	#include	"DEBUG_PU.H"	
	#include "DATPG_PU.H"
	#include "DBSYS_PU.H"
	#include "SERV_PU.H"
	#include "LISTS_PU.H"
	#include "FILES_PU.H"
	#include "TEXT_PU.H"
	#include "DBINT_PU.H"
	#include	"LINE0_PU.H"

 
/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * LectMsg_EraseCurrRec(-)
 *
 * Purpose:
 * --------
 * Contr“le si on peu effacer puis
 * Efface le record demand‚ de la base demand‚e
 *
 * History:
 * --------
 * 17.05.94: Demande Xlock avant d'effacer, si non accord‚, n'efface pas.
 * 13.01.95: met statut maj de la DB … MODIFIED
 * 15.03.95: extracted from LectMsg_EraseCurrRec(-)
 */
BOOL	CompRec_Erase(										/* Out: TRUE if success */
			VOIE 				*	pVoie_curr,				/* In:  Voie concern‚e */
			COMPACT_RECORD *	pCompRec_toKill,	/* In:  Ptr sur le Record … supprimer */
			DATAPAGE			*	pDataPage_DB )			/* In:  Base de donn‚es concern‚e */
{
	DATA_RECORDS	*	pDataRecs_dbase = pDataPage_DB -> data.records;
	COMPACT_RECORD *	pCompRec_prev;
	COMPACT_RECORD *	pCompRec_next;

	/*
	 * V‚rification de l'int‚grit‚ du champ:
	 */
	MCHECK( pCompRec_toKill );

	/*
	 * Demande la Transformation du ReadLock sur ce message
	 * en XLock (exclusif). Ce ne sera possible que si le message n'est
	 * pas d‚j… utilis‚.
 	 */
	if( DBInt_changeReadToXLock( pVoie_curr, pCompRec_toKill ) == FAILURE_1 )
	{	/* 
		 * Si l'effacement de ce record pose un conflit d'accŠs:
		 */
		aff_msg_l0( pVoie_curr, "Ce message est utilis‚ par un tiers!" );
		return FALSE0;	
	}


	aff_msg_l0( pVoie_curr, "Effacement en cours..." );

	/*
	 * Effacement de la liste: 
	 */
	pCompRec_prev = pCompRec_toKill -> prev;			/* Msg pr‚c‚dent */
	pCompRec_next = pCompRec_toKill -> next;			/* Msg suivant */
	
	/*
	 * Etabli lien prev -> next
	 */
	if( pCompRec_prev != NULL )
	{	/*
		 * Pas d‚but de liste: 
		 */
		pCompRec_prev -> next = pCompRec_next;
	}
	else
	{
		pDataRecs_dbase -> first_record = pCompRec_next;
	}

	/*
	 * Etabli lien prev <- next
	 */
	if( pCompRec_next != NULL )
	{	/* 
		 * Pas fin de liste: 
		 */
		pCompRec_next -> prev = pCompRec_prev;
	}
	else
	{
		pDataRecs_dbase -> last_record = pCompRec_prev;
	}

	/*
	 * 1 message de moins: 
	 */
	pDataRecs_dbase -> nb_records --;
	
	/*
	 * EnlŠve XLock: pour ne pas se planter lors de actions_AtPageExit()
	 */
	DBInt_releaseXLock( pVoie_curr, pCompRec_toKill );

	FREE( pCompRec_toKill );
	pCompRec_toKill = NULL;	/* S‚curit‚ */

	/*
	 * Signale que la DataPage a ‚t‚ modifi‚e:
	 */
	dataPage_chgSavState( pDataPage_DB, SSTATE_MODIFIED, TRUE_1, TRUE_1 );

	aff_msg_l0( pVoie_curr, "OK." );

	return	TRUE_1;
}


/*
 * CompRec_GetRecFlags(-)
 *
 * Retourne les flags d'un record
 *
 * 10.01.95: fplanque: Created
 */
RECORD_FLAGS CompRec_GetRecFlags(						/* Out: Flags du record, tout est … z‚ro si yen a pas */
					COMPACT_RECORD	*	PCompactRecord )	/* In: Record dont on veut connaitre les flags */
{
	HEAD_STRING *	pHeadString = &(PCompactRecord -> data.header .header);
	
	if( pHeadString -> rec_length > sizeof( ULONG ) + 2 * sizeof( RECORD_NUMBER ) )
	{	/*
		 * Il y a un champ record Flags:
		 */
		return	pHeadString -> RecFlags;	
	}
	else
	{
		RECORD_FLAGS	RecFlags_Empty = { 0, 0 };
		return	RecFlags_Empty;
	}
}


/*
 * Create_TextRecFld(-)
 *
 * Purpose:
 * --------
 * Cr‚ation d'un texte dans un champ texte
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 27.11.94: changed a lot from fill_textfield()
 * 01.12.94: prend id champ en paramŠtre
 * 08.12.94: diff‚rents modes de compactage
 */
RECORD_FIELD	*	Create_TextRecFld( 	/* Out: Champ de DB cr‚‚ */
		const	ULONG			cUL_FieldId,	/* In:  Identificateur du champ */
		const IOFIELD	*	cpInField )		/* In:  Champ de saisie dont on doit ins‚rer le contenu */
{
	size_t		field_length;
	char		*	field_string;
	TEXTLINE	*	pTextLine_First;
	int			n_CompactingMode;
	
	/*
	 * Cr‚e champ:
	 */
	RECORD_FIELD	*	pRecField = MALLOC( sizeof( RECORD_FIELD ) );

	/*
	 * Pas de champ suivant pour l'instant:
	 */
	pRecField -> next = NULL;

	/*
	 * ID du champ 
	 */
	pRecField -> field_id = cUL_FieldId;

	/*
	 * Texte … compacter:
	 */
	pTextLine_First = cpInField -> pTextInfo -> firstline -> next;

	/*
	 * Mode de compactage:
	 */
	if( cpInField -> FPar.Input -> InFieldFlags .b_MultiParagraph )
	{	/*
		 * Si on accŠpte plusieurs paragraphes:
		 */
		n_CompactingMode = FMTMODE_REZO;
	}
	else
	{
		n_CompactingMode = FMTMODE_SGLETEXTLINE;
	}


	/*
	 * Compacte le texte: 
	 */
	field_length = compact_text( pTextLine_First, n_CompactingMode, &field_string );

	/*
	 * Assure une longueur paire:
	 * Normalement compact_text() s'en est d‚j… oqp grƒce au param FMTMODE_REZO
	 * mais on se la joue prudence ici.. on sait jamais ski peut arriver par suite demodifs ult‚rieures
	 */
	field_length = (field_length+1) & PARITY;

	/*
	 * Fixe donn‚es dans le champ texte: 
	 */
	pRecField -> length		 = field_length;	/* Longueur chaine */
	pRecField -> info.string = field_string;	/* Sauve adresse */
	
	return	pRecField;
}



/*
 * DBInt_AppendCompRecToDB(-)
 *
 * Purpose:
 * --------
 * Ajoute un COMPACT RECORD … une base de donn‚es
 * lorsqu'un connect‚ a entr‚ une information:
 *
 * History:
 * --------
 * 16.12.94: fplanque: Created
 * 13.02.95: Sauvegarde sur disque
 */
void	DBInt_AppendCompRecToDB(
			VOIE 				*	pVoie_curr,		/* In:  Voie concern‚e */
			COMPACT_RECORD *	pCompactRec,	/* In: Ptr sur le Record … ajouter */
			DATAPAGE			*	pDataPage_DB )	/* In: Base de donn‚es concern‚e */
{
	SSTATE SState = dataPage_getSavState( pDataPage_DB );
	
	/*
	 * V‚rification de l'int‚grit‚ du champ:
	 */
	MCHECK( pCompactRec );

	/*
	 * Ajoute record ds DB:
	 */
	Append_CompactRecToDB( pCompactRec, pDataPage_DB -> data.records );

	if( SState == SSTATE_SAVED )
	{	/*
		 * Si la base de donn‚es n'‚tait pas d‚j… modifi‚e,
		 * On va sauver le nouveau record en fin de fichier!
		 * Comme ‡a on peut laisser la base en statut SAVED
		 * Ce qui est plus sur en cas de plantage ult‚rieur! (cool!)
		 */

		if( set_DtPgFilePath( pDataPage_DB ) == TRUE_1 )
		{
			sprintf( G_tmp_buffer, "   Sauvegarde dans %s\\%s", G_filepath, G_filename );
			add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );

			if( Append_CompRecToDXFFile( pCompactRec ) == TRUE_1 )
			{	
				return;
			}
			else
			{
				TRACE0("Append Failed");
			}
		}
		else
		{
			TRACE0("set_DtPgFilePath() Failed");
		}

		/*
		 * Echec: on a pas pu sauver:
		 * Signale que la DataPage a ‚t‚ modifi‚e
		 * pour sauvegarde ult‚rieure:
		 */
	 	dataPage_chgSavState( pDataPage_DB, SSTATE_MODIFIED, TRUE_1, TRUE_1 );
	}
}


/*
 * ----------------------- Record locks -----------------------------
 */


/*
 * DBInt_AddLockToList(-)
 *
 * Purpose:
 * --------
 * Cr‚ee un  m‚mo sur un ReadLock
 * et l'ajoute … la liste des m‚mos
 *
 * History:
 * --------
 * 30.01.95: fplanque: created
 */
void	DBInt_AddLockToList(
			VOIE *				pVoie_curr,	/* In:  Voie concern‚e */
			COMPACT_RECORD *	pCompRec ) 	/* In:  Ptr sur record … d‚locker */
{
	COMPREC_LISTELT * pCRListElt = MALLOC( sizeof( COMPREC_LISTELT ) );

	pCRListElt -> pCompRec = pCompRec;

	pVoie_curr -> pCRLstElt_1stRLock = Insert_InSingleLinkList( pVoie_curr -> pCRLstElt_1stRLock, pCRListElt );
}


/*
 * DBInt_requestReadLock(-)
 *
 * Purpose:
 * --------
 * Demande et positionne un Lock de lecture sur un enregistrement
 * Lorsqu'une voie a demand‚ un ReadLock, elle peut librement
 * lire le record, elle n'a, par contre, pas le droit de le modifier.
 *
 * Algorythm:
 * ----------
 * Appelle request_ReadLock()
 * M‚morise ce lock dans la voie
 *
 * Notes:
 * ------
 * Plusieurs voies/fonctions peuvent detenir simultan‚ment un ReadLock
 * sur le mˆme record
 * Lib‚rer avec DBInt_releaseReadLock()
 *
 * History:
 * --------
 * 25.01.95: fplanque: Created
 */
COMPACT_RECORD *	DBInt_requestReadLock( 		/* Out: NULL si imposs, sinon ptr sur locked rec */
				VOIE *				pVoie_curr,	/* In: Voie concern‚e */
				COMPACT_RECORD *	pCompRec ) 	/* In:  Ptr sur record … locker */
{
	if( request_ReadLock( pCompRec ) != SUCCESS0 )
	{
		return	NULL;
	}

	/*
	 * M‚morise le lock!
	 */
	DBInt_AddLockToList( pVoie_curr, pCompRec );

	return	pCompRec;
} 


/*
 * DBInt_RemoveLockFromList(-)
 *
 * Purpose:
 * --------
 * EnlŠve le m‚mo sur un ReadLock de la liste des m‚mos
 *
 * History:
 * --------
 * 25.01.95: fplanque: created
 * 30.01.95: corrig‚ bug prevnext
 */
void	DBInt_RemoveLockFromList(
			VOIE *				pVoie_curr,	/* In:  Voie concern‚e */
			COMPACT_RECORD *	pCompRec ) 	/* In:  Ptr sur record … d‚locker */
{
	COMPREC_LISTELT ** ppCRListElt_PrevNext = &(pVoie_curr -> pCRLstElt_1stRLock);
	COMPREC_LISTELT * pCRListElt_List;

	for(  pCRListElt_List = pVoie_curr -> pCRLstElt_1stRLock;
			 pCRListElt_List != NULL;
			  pCRListElt_List = pCRListElt_List -> pCRListElt_next )
			 
	{
		if( pCRListElt_List -> pCompRec == pCompRec )
		{
			*ppCRListElt_PrevNext = pCRListElt_List -> pCRListElt_next;
			
			FREE( pCRListElt_List );
			
			return;
		}

		ppCRListElt_PrevNext = &( pCRListElt_List -> pCRListElt_next );
	}

	signale( "Voie … lib‚r‚ un Lock qu'elle n'avait pas r‚serv‚!" );
}


/*
 * DBInt_releaseReadLock(-)
 *
 * Purpose:
 * --------
 * LibŠre le read lock qu'une vois/fonction avait sur un record
 *
 * Algorythm:
 * ----------  
 * appelle release_ReadLock
 * enlŠve de la liste des readlocks de la voie
 *
 * Notes:
 * ------
 * Plusieurs voies/fonctions peuvent detenir simultan‚ment un ReadLock
 * sur le mˆme record
 *
 * History:
 * --------
 * 25.01.95: fplanque: Created 
 * 15.03.95: esc on NULL
 */
void	DBInt_releaseReadLock(
			VOIE *				pVoie_curr,	/* In: Voie concern‚e */
			COMPACT_RECORD *	pCompRec ) 	/* In:  Ptr sur record … d‚locker */
{
	if( pCompRec == NULL )
	{
		return;
	}

	/* TRACE0( "Releasing 1 readlock!" ); */

	/*
	 * lib‚ration effective du readlock:
	 */
	release_ReadLock( pCompRec );

	/*
	 * Supprime m‚mo readlock:
	 */
	DBInt_RemoveLockFromList( pVoie_curr, pCompRec );
}





/*
 * DBInt_changeReadToXLock(-)
 *
 * Purpose:
 * --------
 * Essaie de modifier un ReadLock sur un record en XLock
 *
 * Algorythm:
 * ----------  
 * appelle change_ReadToXLock()
 * si le changement est accept‚,
 *    change le m‚mo interne de la voie de Read vers X
 *
 * Notes:
 * ------
 * Si quelqu'un d'autre detient egalement un Readlock sur le record
 * en question, le XLock ne peut pas ˆtre attribu‚.
 *
 * History:
 * --------
 * 25.01.95: fplanque: Created
 */
int	DBInt_changeReadToXLock( 			/* Out: !=0 si impossible */
			VOIE *				pVoie_curr,	/* In: Voie concern‚e */
			COMPACT_RECORD *	pCompRec ) 	/* In:  Ptr sur record … locker */
{
	int	n_Result;

	/*
	 * SECURITE:
	 * V‚rifie qu'il n'y a pas d‚j… un XLock de fait par cette voie:
	 */
	if( pVoie_curr -> pCompRec_XLock != NULL )
	{
		signale( "Impossible d'attribuer plus d'un XLock … une voie!" );
		return	FAILURE_1;
	}


	/*
	 * Tente de changer le lock:
	 */
	n_Result = change_ReadToXLock( pCompRec );
	if( n_Result != SUCCESS0 )
	{	/*
		 * Echec:
		 */
		return	n_Result;
	}

	/*
	 * M‚morise le XLock:
	 */
	pVoie_curr -> pCompRec_XLock = pCompRec;

	/*
	 * retire le m‚mo indiquant un ReadLock sur ce champ:
	 */
	DBInt_RemoveLockFromList( pVoie_curr, pCompRec );

	return	SUCCESS0;
} 


/*
 * DBInt_releaseXLock(-)
 *
 * Purpose:
 * --------
 * LibŠre le lock exclusif qu'on avait sur un record
 *
 * Algorythm:
 * ----------  
 * appelle release_XLock()
 * supprime m‚mo
 *
 * History:
 * --------
 * 25.01.95: fplanque: Created
 */
void	DBInt_releaseXLock(
			VOIE *				pVoie_curr,	/* In: Voie concern‚e */
			COMPACT_RECORD *	pCompRec ) 	/* In: Ptr sur record … d‚locker */
{
	release_XLock( pCompRec );

	if( pVoie_curr -> pCompRec_XLock != pCompRec )
	{
		signale( "Voie a lib‚r‚ un XLock qu'elle n'avait pas r‚serv‚" );
		return;
	}
	
	pVoie_curr -> pCompRec_XLock = NULL;
}



/*
 * DBInt_ReleaseAllLocks(-)
 *
 * Purpose:
 * --------
 * EnlŠve tous les locks (lecture et ecriture)
 * sur records que la voie s'est attribu‚
 *
 * History:
 * --------
 * 26.01.95: fplanque: Created
 */
void	DBInt_ReleaseAllLocks(
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{
	/*
	 * Release des locks de lecture:
	 */
	while( pVoie_curr -> pCRLstElt_1stRLock != NULL )
	{
		DBInt_releaseReadLock( pVoie_curr, pVoie_curr -> pCRLstElt_1stRLock -> pCompRec );
	}

	/*
	 * release du XLock:
	 */
	if( pVoie_curr -> pCompRec_XLock != NULL )
	{
		DBInt_releaseXLock( pVoie_curr, pVoie_curr -> pCompRec_XLock );
	} 
}
