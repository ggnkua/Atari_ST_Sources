/*
 * list_db.c
 *
 * Purpose:
 * -------- 
 * liste des messages d'une rubrique:
 *
 * History:
 * --------
 * 24.01.95: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"LIST_DB.C v1.00 - 02.95"
          

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
	#include	"SERV_PU.H"
	#include	"LINE0_PU.H"
	#include	"DBINT_PU.H"
	#include	"IOFLD_PU.H"
	#include "LISTD_PU.H"
	#include "GENRC_PU.H"
	#include "TERM_PU.H"
	#include "TEXT_PU.H"
	#include "SERCOMPU.H"


/*			
 * --------------------------- METHODES -------------------------------
 */


/*
 * ListDB_ENPG(-)
 *
 * Purpose:
 * --------
 * Traitrement des initialisations ENTER PAGE
 *
 * History:
 * --------
 * 24.01.95: fplanque: Created
 */
void	ListDB_ENPG(
			VOIE	*	pVoie_curr,		/* In: Voie concern‚e */
			int		n_DBFnct )		/* In: Fonction Db … utiliser */
{
	/*
	 * Ouvre base de donn‚es:
	 */
	register_action( pVoie_curr, OPDB, n_DBFnct, 0, NULL );
	/*
	 * Affiche donn‚es 
	 */
	register_action( pVoie_curr, DDAT, 0, 0, NULL );
	register_action( pVoie_curr, DPAG, 0, 0, NULL );
}



/*
 * ListDB_OPDB(-)
 *
 * Purpose:
 * --------
 * On vient d'ouvrir une base de donn‚es
 * -> traitement sp‚cial?
 *
 * History:
 * --------
 * 25.01.95: fplanque: Created base on LectMsg_OPDB
 * 30.01.95: demande readlocks sur tout ce qui va ˆtre affich‚ et saue ptrs dans un tableau cr‚‚ dynamiquement
 */
void	ListDB_OPDB(
			VOIE	*	pVoie_curr )		/* In: Voie concern‚e */
{
	ARBO_LISTPARS	* pArboListPars = pVoie_curr -> arboparams -> pArboListPars;

	/* 
	 * On vient d'ouvrir la DB:
	 * On va fixer un ptr sur le message en cours de lecture: 
	 */
	DATAPAGE			*	dbase = pVoie_curr -> database;		/* Base de donn‚es concern‚e */
	DATA_RECORDS	*	data_recs = dbase -> data.records;	/* Infos sur les enregistrements */

	/*
 	 * Sauve Ptr sur 1er record:
	 */	
	COMPACT_RECORD * pCompRec = data_recs -> first_record;	

	/*
	 * Calcule le nombre de records qui vont ˆtre affich‚s:
	 */
	int	nb_DisplayedRecs;
	int	nb_MaxDisplayedRecs = pArboListPars -> nb_Cols * pArboListPars -> nb_Lines;
	COMPACT_RECORD * * pTCompRec_ptrs;

	/*
	 * Alloue une zone pour les pointeurs vers les messages:
	 */
	pTCompRec_ptrs = MALLOC( sizeof(COMPACT_RECORD*) * nb_MaxDisplayedRecs );
	pVoie_curr -> pTCompRec_ptrs = pTCompRec_ptrs;
	pVoie_curr -> nb_MaxDisplayedRecs = nb_MaxDisplayedRecs;

	/*
	 * Parcourt les messages :
	 * et prends un Readlock sur tout ce qu'on rencontre
	 * pour l'afficher sur la page courante:
	 */
	for( nb_DisplayedRecs = 0 ;
			pCompRec != NULL && nb_DisplayedRecs < nb_MaxDisplayedRecs ; 
			 pCompRec = pCompRec -> next )
	{	
		/*
		 * Demande un lock de lecture sur le record:
		 * et sauve ptr dans le tableau des pts d'accŠs. NULL si pas obtenu
		 * Un record de plus d'affich‚:
		 */
		pTCompRec_ptrs[ nb_DisplayedRecs ++ ] = DBInt_requestReadLock( pVoie_curr, pCompRec );
	}

	/*
	 * On met ‡a … NULL parce que les ptrs se trouvent dans le tableau!
	 *
	pVoie_curr -> curr_comprec = NULL;

	/*
	 * Nombre de records effectivement affich‚s:
	 */
	pVoie_curr -> nb_DisplayedRecs = nb_DisplayedRecs;

	/*
	 * Num‚ro de record en haut de l'‚cran:
	 * Num‚ro de record courant:
	 */
	pVoie_curr -> n_RecIndex_Top = 1;
	pVoie_curr -> n_RecIndex_Curr = 1;

}


/*
 * ListDB_DispData(-)
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
 * 24.01.95: fplanque: Created
 */
void	ListDB_DispData(
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{
	/*
	 * Affichage champs groupe 1 (commentaire...):
	 */
	OutFields_DisplayGroup( pVoie_curr, 1, 0, 0 );

	/*
	 * Nu‚mro de page courant:
	 * (A d‚placer qd ce sera dispo vers 'DispMSG' cad Groupe 2!)
	 */
	pVoie_curr -> n_PageNumber_Curr = 1;
}



/*
 * ListDB_DispPage(-)
 *
 * Purpose:
 * --------
 * Affiche une page de liste
 *
 * Notes:
 * ------
 * Readlocks?
 *
 * History:
 * --------
 * 25.01.95: fplanque: Created
 * 30.01.95: prend les comprecs dans le tableau
 */
void	ListDB_DispPage(
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{
	ARBO_LISTPARS	* pArboListPars = pVoie_curr -> arboparams -> pArboListPars;

	COMPACT_RECORD ** pTCompRec_ptrs = pVoie_curr -> pTCompRec_ptrs;
	
	/*
	 * Compteurs de boucles, colones, et lignes:
	 */
	int	n_Column;
	int	n_Line;
	int	n_IndexCompRecCurr = 0;		/* Index du record en cours d'affichage */
	/*
	 * Offsets d'affichage par rapport aux champs de r‚f‚rence
	 * du groupe 4:
	 */
	int	n_XOffset = 0;
	int	n_YOffset;

	for( n_Column = 1; n_Column <= pArboListPars -> nb_Cols; n_Column++ )
	{
		/*
		 * On commence une nouvelle colonne:
		 */
		n_YOffset = 0;

		for( n_Line = 1; n_Line <= pArboListPars -> nb_Lines; n_Line++ )
		{
			if( n_IndexCompRecCurr >= pVoie_curr -> nb_DisplayedRecs )
			{	/*
				 * S'il n'y a plus rien … afficher!
				 */
				return;
			}

			/*
			 * Affichage des champs du groupe 4:
			 */
			pVoie_curr -> curr_comprec = pTCompRec_ptrs[ n_IndexCompRecCurr ];
			OutFields_DisplayGroup( pVoie_curr, 4, n_XOffset, n_YOffset );
	
			/*
			 * Prochain no de record:
			 */
			 n_IndexCompRecCurr ++;						/* Relatif … la page */
			 (pVoie_curr -> n_RecIndex_Curr) ++;	/* + ou - Relatif au d‚but du groupe */
			
			/*
			 * Descend … l'‚cran:
			 */
			n_YOffset += pArboListPars -> n_InterLine;
		}
	
		/*
		 * Passe … la colonne suivante … l'‚cran:
		 */
		n_XOffset += pArboListPars -> n_InterCol;
	}
}


/*
 * ListMsg_ChgePage(-)
 *
 * Purpose:
 * --------
 * Changement de page dans la liste suite … pression sur SUITE ou RETOUR
 *
 * History:
 * --------
 * 13.02.95: fplanque: Created
 */
void	ListMsg_ChgePage( 
			VOIE	*	pVoie_curr,			/* In: Voie concern‚e */
			KEYCODE	curr_keypress )	/* In: Touche press‚e */
{
	/*
	 * Tableau des readlocks courants:
	 */
	COMPACT_RECORD * * pTCompRec_ptrs = pVoie_curr -> pTCompRec_ptrs;
	COMPACT_RECORD * pCompRec;
	int 	i;
	int	nb_DisplayedRecs = pVoie_curr -> nb_DisplayedRecs;
	int	nb_MaxDisplayedRecs = pVoie_curr -> nb_MaxDisplayedRecs;

	if( nb_DisplayedRecs == 0 )
	{	/*
		 * S'il n'y a rien d'affich‚
		 * ... c'est qu'il n'y a rien … afficher!
		 */
		aff_msg_l0( pVoie_curr, "Liste vide!" );
		return;
	}

	affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */

	if( curr_keypress == KEY_RETOUR )
	{	/*
		 * Retour:
		 */
		COMPACT_RECORD * pCompRec_CurrTop = pTCompRec_ptrs[ 0 ];
		if( pCompRec_CurrTop == NULL || pCompRec_CurrTop -> prev == NULL )
		{
			aff_msg_l0( pVoie_curr, "D‚but de liste!" );
			return;
		}

		/*
		 * LibŠre locks actuels:
		 */
		for( i=0; i < nb_DisplayedRecs; i++ )
		{
			DBInt_releaseReadLock( pVoie_curr, pTCompRec_ptrs[ i ] );				
		}

		/*
		 * Essaye d'aller d'une page en arriŠre:
		 */
		i=1;
		pCompRec = pCompRec_CurrTop -> prev;
		while( i < nb_MaxDisplayedRecs && pCompRec -> prev != NULL )
		{
			i++;
			pCompRec = pCompRec -> prev;
		}	

		/*
		 * Num‚ro de record en haut de l'‚cran:
		 * Num‚ro de record courant:
		 */
		pVoie_curr -> n_RecIndex_Top -= i;
		if( pVoie_curr -> n_RecIndex_Top < 1 )
		{	/* On ne peut descendre en dessous de "1" */
			pVoie_curr -> n_RecIndex_Top = 1;
		}
		pVoie_curr -> n_RecIndex_Curr = pVoie_curr -> n_RecIndex_Top;

		/*
		 * Parcourt les messages suivants:
		 * et prends un Readlock sur tout ce qu'on rencontre
		 * pour l'afficher sur la page suivante:
		 */
		for( nb_DisplayedRecs = 0;
				pCompRec != NULL && nb_DisplayedRecs < nb_MaxDisplayedRecs; 
				 pCompRec = pCompRec -> next )
		{	
			/*
			 * Demande un lock de lecture sur le record:
			 * et sauve ptr dans le tableau des pts d'accŠs. NULL si pas obtenu
			 * Un record de plus d'affich‚:
			 */
			pTCompRec_ptrs[ nb_DisplayedRecs ++ ] = DBInt_requestReadLock( pVoie_curr, pCompRec );
		}

		/*
		 * Nombre de records effectivement affich‚s:
		 */
		pVoie_curr -> nb_DisplayedRecs = nb_DisplayedRecs;
	
		/*
		 * Demande r‚affichage page:
		 */
		Generic_DisplayPageChange( pVoie_curr );

	}
	else
	{	/*
		 * Suite:
		 */	
		COMPACT_RECORD * pCompRec_CurrBottom = pTCompRec_ptrs[ nb_DisplayedRecs -1 ];
		if( pCompRec_CurrBottom == NULL || pCompRec_CurrBottom -> next == NULL )
		{
			aff_msg_l0( pVoie_curr, "Fin de liste!" );
			return;
		}
	
		/*
		 * LibŠre locks actuels:
		 */
		for( i=0; i < nb_DisplayedRecs; i++ )
		{
			DBInt_releaseReadLock( pVoie_curr, pTCompRec_ptrs[ i ] );				
		}
	
		/*
		 * Num‚ro de record en haut de l'‚cran:
		 * Num‚ro de record courant:
		 */
		pVoie_curr -> n_RecIndex_Top += nb_DisplayedRecs;
		pVoie_curr -> n_RecIndex_Curr = pVoie_curr -> n_RecIndex_Top;

		/*
		 * Parcourt les messages suivants:
		 * et prends un Readlock sur tout ce qu'on rencontre
		 * pour l'afficher sur la page suivante:
		 */
		for( nb_DisplayedRecs = 0 , pCompRec = pCompRec_CurrBottom -> next ;
				pCompRec != NULL && nb_DisplayedRecs < nb_MaxDisplayedRecs; 
				 pCompRec = pCompRec -> next )
		{	
			/*
			 * Demande un lock de lecture sur le record:
			 * et sauve ptr dans le tableau des pts d'accŠs. NULL si pas obtenu
			 * Un record de plus d'affich‚:
			 */
			pTCompRec_ptrs[ nb_DisplayedRecs ++ ] = DBInt_requestReadLock( pVoie_curr, pCompRec );
		}

		/*
		 * Nombre de records effectivement affich‚s:
		 */
		pVoie_curr -> nb_DisplayedRecs = nb_DisplayedRecs;
	
		/*
		 * Demande r‚affichage page:
		 */
		Generic_DisplayPageChange( pVoie_curr );
	}
}


/* 
 * ListDB_AccessRecbyNo(-)
 *
 * AccŠs … un record d'aprŠs son num‚ro
 * tel qu'il est courament affich‚ … l'‚cran 
 * du terminal
 *
 * 15.03.95: Created
 */
COMPACT_RECORD *	ListDB_AccessRecbyNo(	/* Out: Record demand‚ ou NULL */
							VOIE	*	pVoie_curr,	/* In:  Voie concern‚e */
							long		l_number )	/* In:  No du rec d‚sir‚ */			
{
	if( l_number >= pVoie_curr -> n_RecIndex_Top && l_number < pVoie_curr -> n_RecIndex_Curr )
	{
		int	n_RecIndex = (int) (l_number - pVoie_curr -> n_RecIndex_Top);
		COMPACT_RECORD * pCompactRec_Target = pVoie_curr -> pTCompRec_ptrs[ n_RecIndex ];

		if( pCompactRec_Target == NULL )
		{	/*
			 * Impossible d'acc‚der … ce Record:
			 * Cause probable: il ‚tait lock‚ lors de la constitution de la liste:
			 */
			aff_msg_l0( pVoie_curr, "Enregistrement incaccessible!" );
			sprintf( G_tmp_buffer, "     Enregistrement %ld incaccessible!", l_number );
			add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );
			return	NULL;
		}
		
		return	pCompactRec_Target;
	}

	aff_msg_l0( pVoie_curr, "Num‚ro enregistrement incorrect!" );
	add_textinf( pVoie_curr -> wi_params, "     Num‚ro de record hors limites!" );

	return	NULL;
}			


/*
 * ListDB_CmdDelRec(-)
 *
 * Purpose:
 * --------
 * Commande Delete d‚terminant l'effacement
 *
 * History:
 * --------
 * 15.03.95: fplanque: Created
 */
BOOL	ListDB_CmdDelRec(					/* Out: !FALSE si succŠs */
			VOIE	*	pVoie_curr,			/* In:  Voie concern‚e */
			char	*	piBsz_Arguments )	/* In:  Arguments pass‚s derriŠre la commande */
{
	long					l_number;
	COMPACT_RECORD * 	pCompactRec_Target;
	
	/*
	 * Essaie d'extraire no de record … effacer:
	 */
	if( !extract_number( piBsz_Arguments, &l_number ) )
	{	/*
		 * Pas de num‚ro!
		 */
		aff_msg_l0( pVoie_curr, "ParamŠtre manquant!" );
		add_textinf( pVoie_curr -> wi_params, "    ParamŠtre manquant!" );
		return FALSE0;
	}
	
	/*
	 * Essaie d'acc‚der au record concern‚:
	 */
	pCompactRec_Target = ListDB_AccessRecbyNo( pVoie_curr, l_number );
	if( pCompactRec_Target == NULL )
	{	/*
		 * Echec accŠs:
		 */
		return FALSE0;
	}
		
	sprintf( G_tmp_buffer, "    Effacement du record no: %ld", l_number );
	add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );
	
	/*
	 * Demande l'effacement:
	 */
	if( CompRec_Erase( pVoie_curr, pCompactRec_Target, pVoie_curr -> database ) == FALSE0 )
	{
		return	FALSE0;
	} 	

	/*
	 * Efface le pointeur du tableau de liste
	 * vers le record n'existant plus.
	 */
	{
		int	n_RecIndex = (int) (l_number - pVoie_curr -> n_RecIndex_Top);
		/*
 		 * Test de coh‚rence:
		 */
		if( pVoie_curr -> pTCompRec_ptrs[ n_RecIndex ] == pCompactRec_Target )
		{	/*
			 * Oublie ce record:
			 */
			pVoie_curr -> pTCompRec_ptrs[ n_RecIndex ] = NULL;
		}
		else
		{
			signale( "Ne trouve plus record dans table de liste!" );
		}
	}

	/*
	 * Il faut mettre … jour l'affichage!
	 */
	

	return	TRUE_1;
}



/*
 * ListMsg_KeyAction(-)
 *
 * Purpose:
 * --------
 * R‚agit … la touche press‚e sur une page de Liste
 *
 * History:
 * --------
 * 30.01.95: fplanque: Created
 * 15.03.95: affinement effacement message
 */
void	ListMsg_KeyAction( 
			KEYCODE	curr_keypress, /* In: Touche press‚e */
			VOIE	*	pVoie_curr )	/* In: Voie concern‚e */
{
	switch( curr_keypress )
	{
		case	KEY_RETOUR:
		case	KEY_SUITE:
			/*
			 * On veut changer de page:
			 */
			ListMsg_ChgePage( pVoie_curr, curr_keypress ); 
			break;
					
		case	KEY_ENVOI:				
		{	/*
	 		 * Obtient ligne de commande:	
	 		 * (NE PAS MODIFIER la ligne de commande!)
			 */
			const char * cpBsz_CmdLine = aim_CurrField( pVoie_curr );
			
			long	l_number;
			
			if( extract_number( cpBsz_CmdLine, &l_number ) )
			{	/*
				 * Demande d'accŠs direct:
				 * Essaie d'acc‚der au record concern‚:
				 */
				COMPACT_RECORD * pCompactRec_Target;

				sprintf( G_tmp_buffer, "  AccŠs direct au record no: %ld", l_number );
				add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );

				pCompactRec_Target = ListDB_AccessRecbyNo( pVoie_curr, l_number );
				if( pCompactRec_Target == NULL )
				{	/*
					 * Echec accŠs:
					 */
					return;
				}
				
				/*
				 * Demande Changement de page:
				 */
				if( follow_ArboLink( pVoie_curr, FL_WATCH ) == TRUE_1 )
				{	/*
					 * M‚morise ptr sur le record et sa DB 
					 * en guise parametres pour la page arbo suivante:
					 */
					pVoie_curr -> pDataPage_LockedDB_OUT = pVoie_curr -> database;
					pVoie_curr -> pCompRec_Locked_OUT = pCompactRec_Target;
					/*
					 * Supprime m‚mo readlock de la liste
					 * pour ‚viter lib‚ration automatique au changement de page:
					 */
					DBInt_RemoveLockFromList( pVoie_curr, pCompactRec_Target );
				}
				return;
			}

			/*
			 * On n'a pas tap‚ un nombre...
			 */

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
		}

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

	}
}

