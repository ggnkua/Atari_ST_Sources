/*
 * lect_msg.c
 *
 * Purpose:
 * -------- 
 * lecture des messages d'une rubrique:
 *
 * History:
 * --------
 * 18.12.94: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"LECT_MSG.C v1.00 - 02.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>					/* header standard */
	#include <string.h>					/* header tt de chaines */
	#include	<stdlib.h>					/* Pour malloc etc.. */
   

/*
 * Custom headers:
 */
	#include	"ARB_OUT.H"
	#include	"DEF_ARBO.H"

	#include "SPEC_PU.H"

	#include "DATPG_PU.H"
	#include "DBSYS_PU.H"
	#include	"DEBUG_PU.H"	
	#include	"SERV_PU.H"
	#include	"LINE0_PU.H"
	#include	"DBINT_PU.H"
	#include	"IOFLD_PU.H"
	#include "LECTM_PU.H"
	#include "GENRC_PU.H"
	#include "TERM_PU.H"
	#include "TEXT_PU.H"
	#include "SERCOMPU.H"

/*
 * Private methods:
 */
	static	BOOL	LectMsg_CanRead(						/* Out: TRUE_1 if allowed */
							VOIE				*	pVoie_curr,	/* In:  Voie concern‚e */
							COMPACT_RECORD	*	pCompRec	);	/* In:  Message concern‚ */		
	static	BOOL	LectMsg_MoveToNextMsg(
							VOIE *	pVoie_curr );
	static	BOOL	LectMsg_MoveToPrevMsg(
							VOIE *	pVoie_curr );
	static	void	LectMsg_DisplayRecChange(
							VOIE *	pVoie_curr );	/* In: Voie concern‚e */
	static	COMPACT_RECORD * LectMsg_FindNextAllowed(				/* In: prochain message trouv‚: */
							VOIE				*	pVoie_curr,
							COMPACT_RECORD	*	pCompRec );	/* In: Start */
	static	COMPACT_RECORD * LectMsg_FindPrevAllowed(				/* In: prochain message trouv‚: */
							VOIE				*	pVoie_curr,
							COMPACT_RECORD	*	pCompRec );	/* In: Start */

/*
 * --------------------------- METHODES -------------------------------
 */


/*
 * LectMsg_ENPG(-)
 *
 * Purpose:
 * --------
 * Traitrement des initialisations ENTER PAGE
 *
 * History:
 * --------
 * 18.12.94: fplanque: Created
 * 10.01.95: s‚paration entre affichage des donnes fixe et du 1er msg
 * 24.01.95: demande un DPAG
 */
void	LectMsg_ENPG(
			VOIE	*	pVoie_curr )		/* In: Voie concern‚e */
{
	/*
	 * valeurs Par d‚faut:
	 * Num‚ro de record en haut de l'‚cran:
	 * Num‚ro de record courant:
	 */
	pVoie_curr -> n_RecIndex_Curr = 1;
	pVoie_curr -> n_RecIndex_Top = pVoie_curr -> n_RecIndex_Curr;

	/*
	 * Cherche et sauve le champ qui affichera le texte
	 * et qui pourra ˆtre scroll‚:
	 */
	pVoie_curr -> pOutputFPar_CurrOut = Find_OutField( pVoie_curr, FO_TEXT );

	/*
	 * Ouvre base de donn‚es:
	 */
	register_action( pVoie_curr, OPDB, FB_RUB, 0, NULL );
	/*
	 * Affiche donn‚es 
	 */
	register_action( pVoie_curr, DDAT, 0, 0, NULL );
	register_action( pVoie_curr, DREC, 0, 0, NULL );
	register_action( pVoie_curr, DPAG, 0, 0, NULL );
}


/*
 * LectMsg_OPDB(-)
 *
 * Purpose:
 * --------
 * On vient d'ouvrir une base de donn‚es
 * -> traitement sp‚cial?
 *    ex: init ptr sur 1er record
 *
 * History:
 * --------
 * 12.01.94: fplanque: Created
 * 30.01.95: r‚cupŠre record … afficher transmis en param si c'est le cas
 */
void	LectMsg_OPDB(
			VOIE	*	pVoie_curr,		/* In: Voie concern‚e */
			int		n_fnct_base )	/* In: Fonction de la base de don‚es qu'on vient d'ouvrir */
{
	if( n_fnct_base == FB_RUB )
	{	/* 
		 * On vient d'ouvrir la rubrique:
		 * On va fixer un ptr sur le message en cours de lecture: 
		 */
		DATAPAGE			*	dbase = pVoie_curr -> database;		/* Base de donn‚es concern‚e */
		DATA_RECORDS	*	data_recs = dbase -> data.records;	/* Infos sur les enregistrements */
		COMPACT_RECORD	*	pCompRec_Locked_IN = pVoie_curr -> pCompRec_Locked_IN;	/* Record re‡u en paramŠtre */
		COMPACT_RECORD	*	compact_rec;
		
		/*
		 * cherche 1er Enregistrement … afficher 
		 */	
		if( pCompRec_Locked_IN != NULL && dbase ==  pVoie_curr -> pDataPage_LockedDB_IN )
		{	/*
			 * On a re‡u un record … lire en paramŠtre:
			 */
			compact_rec = pCompRec_Locked_IN;
		}
		else
		{	/*
			 * Pas de param indiquant premier record:
			 * On commence sur le premier:
			 */
			compact_rec =  data_recs -> first_record;
		}
		
		/*
		 * Se place sur le prochain record qu'on a le droit de lire
		 * Contr“le PRIVATE!
		 */
		compact_rec = LectMsg_FindNextAllowed( pVoie_curr, compact_rec );	

		/*
		 * v‚rifie qu'il y a un message qu'on est autoris‚ … lire:
		 */
		if( compact_rec == NULL )
		{
			return;
		}

		/*
		 * Si pas encore fait,
		 * Demande un lock de lecture sur l'enregistrement:
		 */
		if( compact_rec != pCompRec_Locked_IN )
		{	/*
			 * Si le message … lire n'est pas celui qu'on a re‡u en parametre
			 * (car le param est d‚j… lock‚)
			 * on locke ce record:
			 */
			compact_rec = DBInt_requestReadLock( pVoie_curr, compact_rec );
		}

		/*
		 * Sauve ptr sur message … lire: 
		 */
		pVoie_curr -> curr_comprec = compact_rec;
		 
	}
}


/*
 * LectMsg_DispData(-)
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
 * 10.01.95: fplanque: Created
 * 24.01.95: appel de OutFields_DisplayGroup()
 */
void	LectMsg_DispData(
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{
	/*
	 * Affichage champs groupe 1 (commentaire...):
	 */
	OutFields_DisplayGroup( pVoie_curr, 1, 0, 0 );
}


/*
 * LectMsg_DispMsg(-)
 *
 * Purpose:
 * --------
 * Affiche un message de rubrique sur l'‚cran du connect‚
 *
 * Notes:
 * ------
 * C'est la 1Šre page en tout cas qui est affich‚e
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 19.11.94: fplanque: affichage de nouveaux champs
 * 19.12.94: conserve le champ MTXT; appel de nlles sous routines
 * 08.01.95: Public/priv‚
 * 10.01.95: set_DisplayFields() est sorti ds dispData: il n'y sera execut‚ qu'une seule fois! mieux!
 * 24.01.95: appel de OutFields_DisplayGroup(); n'affiche pas le groupe 4, un msg DPAG est envoy‚ pour ‡a
 */
void	LectMsg_DispMsg( 
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{
	COMPACT_FIELD	* 	pCompField;

	/*
	 * Affichage des champs du groupe 2:
	 * (date, pub/priv, DSTA; MTIT)
	 */
	OutFields_DisplayGroup( pVoie_curr, 2, 0, 0 );

	/*
	 * Pr‚paration du texte du message courant
	 * qui sera affich‚ dans le groupe 4
	 * et qui pourra ˆtre scroll‚ par la suite:
	 */
	if( pVoie_curr -> pOutputFPar_CurrOut != NULL )
	{	/*
		 * S'il y a un champ d'affichage du texte (scrollable):
		 */
		pCompField = Find_FieldinCompactRecord( pVoie_curr -> curr_comprec, 	pVoie_curr -> pOutputFPar_CurrOut -> ul_CodeChamp );
		if( pCompField != NULL )
		{	/*
		 	 * Si on a trouv‚ le Champ … afficher dans le record:
		 	 */
			pVoie_curr -> pIOField_CurrOut = IOField_PrepareText( pVoie_curr -> pOutputFPar_CurrOut, (char *) (pCompField -> bytes), pCompField -> size_FieldLen );
		}
	}

}



/*
 * LectMsg_CanRead(-)
 *
 * Purpose:
 * --------
 * Check to see if user is allowed to read concerned message
 *
 * History:
 * --------
 * 12.01.95: fplanque: Created
 */
BOOL	LectMsg_CanRead(						/* Out: TRUE_1 if allowed */
			VOIE				*	pVoie_curr,	/* In:  Voie concern‚e */
			COMPACT_RECORD	*	pCompRec	)	/* In:  Message concern‚ */		
{
	RECORD_FLAGS		RecFlags = CompRec_GetRecFlags( pCompRec );
	COMPACT_FIELD * 	pCompField;

	if( ! RecFlags .b_Private )
	{	/*
		 * Il s'agit d'un message public
		 * on peut y aller
		 */
		return	TRUE_1;
	}

	/*
	 * Il s'agit d'un message priv‚:
	 */
	if( pVoie_curr -> pMsz_Login == NULL )
	{	/*
		 * Si le connect‚ n'est pas identifi‚:
		 */
		return	FALSE0;
	}
		 
	pCompField = Find_FieldinCompactRecord( pCompRec, 'DSTA' );
	if( pCompField == NULL || pCompField -> size_FieldLen == 0 )
	{	/*
		 * Si le destinatire n'est pas indiqu‚ dans le message:
		 */
		return	FALSE0;
	}

	if( Sstrcmp( (char *) (pCompField -> bytes), pVoie_curr -> pMsz_Login, '@' ) == 0 )
	{	/*
		 * Si les noms sont identiques:
		 */
		return	TRUE_1;				
	}
	
	return FALSE;
}

/*
 * LectMsg_FindNextAllowed(-)
 *
 * Purpose:
 * --------
 * Cherche prochain message que le connect‚ est autoris‚ … consulter
 *
 * History:
 * --------
 * 12.01.95: fplanque: Created
 */
COMPACT_RECORD * LectMsg_FindNextAllowed(				/* In: prochain message trouv‚: */
						VOIE				*	pVoie_curr,
						COMPACT_RECORD	*	pCompRec )	/* In: Start */
{
	while( pCompRec != NULL )
	{
		if( LectMsg_CanRead( pVoie_curr, pCompRec ) )
		{
			return	pCompRec;
		}
		
		/* 
		 * Passe au message suivant:
		 */
		pCompRec = pCompRec -> next;
	}

	return	NULL;
}


/*
 * LectMsg_FindPrevAllowed(-)
 *
 * Purpose:
 * --------
 * Cherche pr‚c‚dent message que le connect‚ est autoris‚ … consulter
 *
 * History:
 * --------
 * 12.01.95: fplanque: Created
 */
COMPACT_RECORD * LectMsg_FindPrevAllowed(				/* In: prochain message trouv‚: */
						VOIE				*	pVoie_curr,
						COMPACT_RECORD	*	pCompRec )	/* In: Start */
{
	while( pCompRec != NULL )
	{
		if( LectMsg_CanRead( pVoie_curr, pCompRec ) )
		{
			return	pCompRec;
		}
		
		/* 
		 * Passe au message suivant:
		 */
		pCompRec = pCompRec -> prev;
	}

	return	NULL;
}


/*
 * LectMsg_MoveToNextMsg(-)
 *
 * Purpose:
 * --------
 * Se d‚place sur le message suivant de la rubrique
 * (appui sur [*] SUITE)
 *
 * History:
 * --------
 * 19.12.94: fplanque: Created
 * 12.01.95: fplanque: contr“le des msgs priv‚s
 * 30.01.95: incr‚mente no de record
 */
BOOL	LectMsg_MoveToNextMsg(
			VOIE *	pVoie_curr )
{
	COMPACT_RECORD	*	curr_comprec = pVoie_curr -> curr_comprec;

	/*
	 * Cherche le prochain message qui s'adresse au connect‚:
	 */
	COMPACT_RECORD *	pCompRec_target = LectMsg_FindNextAllowed( pVoie_curr, curr_comprec -> next );

	if( pCompRec_target == NULL )
	{
		aff_msg_l0( pVoie_curr, "Pas de message suivant!" );
		return	FALSE0;
	}

	/* 
	 * Si on peut avancer: 
	 */
	DBInt_releaseReadLock( pVoie_curr, curr_comprec );	/* On sort de l'enregistrement courant */

	/*
	 * Demande un lock de lecture sur l'enregistrement suivant:
	 * Sauve ptr sur message … lire: 
	 */
	pVoie_curr -> curr_comprec  = DBInt_requestReadLock( pVoie_curr, pCompRec_target );

	/*
	 * Incr‚mente num‚ro de record:
	 */
	(pVoie_curr -> n_RecIndex_Curr) ++;
	pVoie_curr -> n_RecIndex_Top = pVoie_curr -> n_RecIndex_Curr;

	/*
	 * Affiche nouveau msg … l'‚cran:
	 */
	LectMsg_DisplayRecChange( pVoie_curr );
	return	TRUE_1;		/* On a chang‚ de record */

}


/*
 * LectMsg_MoveToPrevMsg(-)
 *
 * Purpose:
 * --------
 * Se d‚place sur le message pr‚c‚dent de la rubrique
 * (appui sur [*] RETOUR)
 *
 * History:
 * --------
 * 12.01.95: fplanque: contr“le des msgs priv‚s
 * 19.12.94: fplanque: Created
 * 30.01.95: d‚cr‚mente no de record
 */
BOOL	LectMsg_MoveToPrevMsg(
			VOIE *	pVoie_curr )
{
	COMPACT_RECORD	*	curr_comprec = pVoie_curr -> curr_comprec;

	/*
	 * Cherche le prochain message qui s'adresse au connect‚:
	 */
	COMPACT_RECORD *	pCompRec_target = LectMsg_FindPrevAllowed( pVoie_curr, curr_comprec -> prev );

	if( pCompRec_target == NULL )
	{
		aff_msg_l0( pVoie_curr, "Pas de message pr‚c‚dent!" );
		return	FALSE0;
	}

	/* 
	 * Si on peut reculer: 
	 */
	DBInt_releaseReadLock( pVoie_curr, curr_comprec );	/* On sort de l'enregistrement courant */

	/*
	 * Demande un lock de lecture sur l'enregistrement suivant:
	 * Sauve ptr sur message … lire: 
	 */
	pVoie_curr -> curr_comprec  = DBInt_requestReadLock( pVoie_curr, pCompRec_target );

	/*
	 * D‚cr‚mente num‚ro de record:
	 */
	if( pVoie_curr -> n_RecIndex_Curr > 1 )
	{
		(pVoie_curr -> n_RecIndex_Curr) --;
		pVoie_curr -> n_RecIndex_Top = pVoie_curr -> n_RecIndex_Curr;
	}

	/*
	 * Affiche nouveau msg … l'‚cran:
	 */
	LectMsg_DisplayRecChange( pVoie_curr );

	return	TRUE_1;		/* On a chang‚ de record */
}




/*
 * LectMsg_EraseCurrRec(-)
 *
 * Purpose:
 * --------
 * Contr“le si on peu effacer puis
 * Efface le record courament affich‚ … l'‚cran
 * et met … jour l'affichage
 *
 * History:
 * --------
 * 11.05.94: fplanque: Created
 * 17.05.94: fplanque: demande ReadLock lors du passage au msg suivant
 * 17.05.94: Demande Xlock avant d'effacer, si non accord‚, n'efface pas.
 * 24.09.94: correction bug lorsqu'on effa‡ait le dernier msg d'une rub
 * 12.01.95: appel de LectMsg_DisplayRecChange()
 * 13.01.95: met statut maj de la DB … MODIFIED
 * 15.03.95: appel de CompRec_Erase(); renvoie success/failure
 */
BOOL	LectMsg_EraseCurrRec( 		/* Out: TRUE if success */
			VOIE *	pVoie_curr )	/* In: Voie qui demande l'effacement */
{
	DATAPAGE			*	pDataPage_DB = pVoie_curr -> database;
	COMPACT_RECORD *	pCompRec_toKill = pVoie_curr -> curr_comprec;	/* Msg courament affich‚ */
	COMPACT_RECORD *	pCompRec_afterKill;	/* Message … afficher aprŠs avoir d‚truit le courant */

	if( pCompRec_toKill == NULL )
	{
		aff_msg_l0( pVoie_curr, "Pas de message … effacer!" );
		return	FALSE0;
	}

	add_textinf( pVoie_curr -> wi_params, "    Effacement du record courant" );


	/* 
 	 * S'il y a un message a effacer...
	 *
	 * Un peu paradoxalement, on commence par chercher le message
	 * sur lequel on ira aprŠs!
	 * Cherche le prochain msg qui s'adresse … nous:
	 */
	pCompRec_afterKill = LectMsg_FindNextAllowed( pVoie_curr, pCompRec_toKill -> next );
	if( pCompRec_afterKill == NULL )
	{	/*
		 * Si pas trouv‚ vers l'avant:
		 * Cherche vers l'arriŠre:
		 */
		pCompRec_afterKill = LectMsg_FindPrevAllowed( pVoie_curr, pCompRec_toKill -> prev );
	}

	/*
	 * Demande l'effacement:
	 */
	if( CompRec_Erase( pVoie_curr, pCompRec_toKill, pDataPage_DB ) == FALSE0 )
	{
		return	FALSE0;
	} 

	/*
	 * On va maintenant afficher un autre message:
	 */
	pVoie_curr -> curr_comprec = pCompRec_afterKill;	

	if( pCompRec_afterKill != NULL )
	{	/*
		 * Si on doit afficher un nouveau msg, cad S'il reste des messages
		 * Demande un lock de lecture sur le nouveau message:
		 */
		DBInt_requestReadLock( pVoie_curr, pCompRec_afterKill );
	}
	
	/*
	 * Mise … jour de l'affichage:
	 */
	LectMsg_DisplayRecChange( pVoie_curr );
	 
	return	TRUE_1;
}



/*
 * LectMsg_DisplayRecChange(-)
 *
 * Purpose:
 * --------
 * Affiche les informations du nouveau message (+1ere page)
 * auquel on vient de se rendre
 *
 * History:
 * --------
 * 19.12.94: fplanque: Created
 * 13.01.95: effacement des champs qui vont ˆtre renouvel‚s
 * 24.01.95: n'efface plus les champ: c'est automatik avant l"affichage maintenant
 * 25.01.95: demande DPAG
 * 28.03.95: n'efface plus le curseur
 */
void	LectMsg_DisplayRecChange(
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{
	register_action( pVoie_curr, DISP, FE_CHGREC, 0, NULL );		/* Demande affichage page ‚cran */
	register_action( pVoie_curr, DREC, 0, 0, NULL );		/* Affiche en tete message */
	register_action( pVoie_curr, DPAG, 0, 0, NULL );		/* Affiche 1ere page message */
	register_action( pVoie_curr, CPOS, 0, 0, NULL );		/* Repositionne curseur pour continuer ‚dition */
	register_action( pVoie_curr, WAIT, 0, 0, NULL );		/* Repasse en mode d'attente d'action */
}


/*
 * LectMsg_KeyAction(-)
 *
 * Purpose:
 * --------
 * R‚agit … la touche press‚e sur une page de LECTURE
 *
 * Suggest: 
 * --------
 * Provisoire:
 * Pas de v‚rification si le readlock du nouveau message est accept‚
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 10.05.94: fplanque: Ajout gestion [ANNULATION]->EFFACEMENT MESSAGE
 * 11.05.94: fplanque: Ajout de messages ligne0
 * 17.05.94: fplanque: Lib‚ration et demande de ReadLocks lors du chgt de msg
 * 24.09.94: correction bug autorisation touche annul
 * 24.09.94: possibilit‚ de taper des mots clef
 * 19.12.94: fplanque: enhanced!?
 * 06.01.94: corrig‚ bugs ds d‚pacement de pages
 * 12.04.95: Annulation trait‚ normalement, l'effacement est maintenant trait‚ comme une commande ‚ventuellement associ‚ … la touche ANNUL
 */
void	LectMsg_KeyAction( 
			KEYCODE	curr_keypress, /* In: Touche press‚e */
			VOIE	*	pVoie_curr )	/* In: Voie concern‚e */
{
	switch( curr_keypress )
	{
		case	KEY_RETOUR:
		case	KEY_SUITE:
		{	/*
			 * Ptr sur enregistrement courant: 
			 */
			COMPACT_RECORD	*	curr_comprec = pVoie_curr -> curr_comprec;
			IOFIELD			*	pIOField_CurrOut = pVoie_curr -> pIOField_CurrOut;
			int					nb_VisibleLines;
		
			/* 
			 * Teste s'il y a des messages: 
			 */
			if( curr_comprec == NULL || pIOField_CurrOut == NULL )
			{
				aff_msg_l0( pVoie_curr, "Pas de message!" );
				break;
			}

			/*
		 	 * S'il y a au moins 1 message: 
		 	 */
			affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */
		 	
		 	/*
		 	 * Nbre de lignes affich‚es:
		 	 */
		 	nb_VisibleLines = pIOField_CurrOut -> FPar.Input -> h;
		 	 
			if ( curr_keypress == KEY_RETOUR )
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

				LectMsg_MoveToPrevMsg( pVoie_curr );
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
	
				LectMsg_MoveToNextMsg( pVoie_curr );
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


		case	KEY_REPET:
		case	KEY_GUIDE:
		case	KEY_SOMM:
		case	KEY_ANNUL:
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

