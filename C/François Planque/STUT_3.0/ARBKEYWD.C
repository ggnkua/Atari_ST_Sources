/*
 * ArbKeyWd.c
 *
 * Purpose:
 * --------
 * Fonction de gestion des params mots clefs
 *
 * Notes:
 * ------
 *
 * History:
 * --------
 * 14.03.95: fplanque: Created
 * 29.03.95: changed specs
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"ARBKEYWD.C v2.00 - 03.95"
 

/*
 * System headers:
 */
	#include	<stdio.h>
	#include <stdlib.h>					
	#include	<string.h>					/* Memcpy etc... */
	#include	<aes.h>						/* header AES */  
	
/*
 * Custom headers:
 */
	#include "SPEC_PU.H"					/* Listes... */	
	#include "S_MALLOC.H"
	#include	"DFSTRUCT.H"
	#include	"FILES_PU.H"	
	#include "ARBKEYPU.H"	
	#include	"DEF_ARBO.H" 
	#include "POPUP_PU.H"
	#include "LISTS_PU.H"
	#include "ARBGENPU.H"

/*
 * Prototypes:
 */
	extern FNCTSPEC G_fnctlink[];	

/*
 * Variables:
 */
	/*
	 * Popup de choix d'une action (mot clef)
	 */
	POPUP_ENTRY	G_Popup_ActionMenu[]=
	{								
		"  Aucune",						ACTION_NONE,
		"  Efface Ecran",				ACTION_CLS,
		"  Efface Tout l'ecran",	ACTION_FULLCLS,
		"  2 Bombes!!!",				ACTION_2BOMBES,
		"  Efface Enregistrement",	ACTION_DEL_RECORD,
		NULL,								0xFFFF
	};


/*
 *	--------------------- GESTION DE LISTES --------------------------
 */

/*
 * KeyWordLElt_Create(-)
 *
 * Purpose:
 * --------
 * Cr‚e un mot clef de liste
 *
 * 15.03.95: Created
 * 29.03.95: Extended big time
 */
KEYWORD_LIST * KeyWordLElt_Create(		/* Out: Commande cr‚‚e */
						int		n_Event,		/* In:  Code ‚vŠnement */
						int		n_Action1,	/* In:  Action a entreprendre */
						int		n_Action2,	/* In:  Action a entreprendre */
						char	*	psz_Cmd,		/* In:  Commande … taper */
						char	*	psz_Dest )	/* In:  Page arbo destination */
{
	KEYWORD_LIST * pKeyWordLElt = MALLOC( sizeof( KEYWORD_LIST ) );
	
	pKeyWordLElt -> next = NULL;
	pKeyWordLElt -> n_Event = n_Event;
	pKeyWordLElt -> n_Action1 = n_Action1;
	pKeyWordLElt -> n_Action2 = n_Action2;
	pKeyWordLElt -> u_flags = 0;
	pKeyWordLElt -> psz_KeyWord = psz_Cmd;
	pKeyWordLElt -> psz_DestPage = psz_Dest;

	return	pKeyWordLElt;
}


/*
 * CmdList_Replace1Content(-)
 *
 * Modifie les params d'un elt ds une liste de commandes
 *
 * 29.03.95: fplanque: created based on TextParList_Replace1Content
 * 12.04.95: Corrected several bugs
 */
BOOL	CmdList_Replace1Content(			/* Out: TRUE_1 si ok */
				KEYWORD_LIST * pCmd_List,	/* In: Liste de Commandes */
				int				n_Event,		/* In: Code ‚vŠnement */
				int				n_Action1,	/* In: Action a entreprendre */
				int				n_Action2,	/* In: Action a entreprendre */
				char			*	psz_Cmd,		/* In: Commande … taper */
				char			*	psz_Dest )	/* In: Page arbo destination */
{
	KEYWORD_LIST *	pCmd_Found;
	
	/*
	 * Cherche par de fonction demand‚e:
	 */
	pCmd_Found = Lookup_SingleLinkList( pCmd_List, n_Event );
	if( pCmd_Found == NULL )
	{
		return	FALSE0;
	}

	/*
	 * Trouv‚, remplace le nom:
	 */
	pCmd_Found -> n_Action1 = n_Action1;
	pCmd_Found -> n_Action2 = n_Action2;
	free_String( pCmd_Found -> psz_KeyWord );
	pCmd_Found -> psz_KeyWord = dup_String( psz_Cmd );
	free_String( pCmd_Found -> psz_DestPage );
	pCmd_Found -> psz_DestPage = dup_String( psz_Dest );
	
	return 	TRUE_1;
}			



/*
 * KeyWordLElt_Destroy(-)
 *
 * D‚truit un mot clef de liste
 *
 * 16.03.95: Created
 */
void KeyWordLElt_Destroy(
		KEYWORD_LIST * pKeyWordLElt ) /* In: Elt … d‚truire */
{
	free_String( pKeyWordLElt -> psz_KeyWord );
	free_String( pKeyWordLElt -> psz_DestPage );

	FREE( pKeyWordLElt );
}



/*
 * findElt_KWLst_byIndex(-)
 *
 * Purpose:
 * --------
 * Trouve un elt ds une liste en fonction de son index
 *
 * History:
 * --------
 * 24.05.94: fplanque: Created
 */
KEYWORD_LIST *	findElt_KWLst_byIndex( 	/* Out: Elt trouv‚ */
			KEYWORD_LIST *	pDblTxt_List,	/* In:  Liste … parcourir */
			int				 n_index )		/* In:  Index */
{
	int i;
	KEYWORD_LIST * pDblTxt_elt = pDblTxt_List;
	
	for( i=0; i<n_index && pDblTxt_elt != NULL; i++ )
	{
		pDblTxt_elt = pDblTxt_elt -> next;
	}

	/*
	 * Retourne ptr sur l'elt trouv‚:
	 */
	return	pDblTxt_elt;
}


/*
 * findElt_KWLst_by1stName(-)
 *
 * Purpose:
 * --------
 * Trouve un elt ds une liste en fonction de son 1er nom
 *
 * History:
 * --------
 * 24.05.94: fplanque: Created
 */
KEYWORD_LIST *	findElt_KWLst_by1stName( 	
			KEYWORD_LIST * pDblTxt_List,
			const char	 * cpsz_SearchString )
{
	KEYWORD_LIST * pDblTxt_elt = pDblTxt_List;
	
	while( pDblTxt_elt != NULL )
	{
		if( strcmp( pDblTxt_elt -> psz_KeyWord, cpsz_SearchString ) == 0 )
		{	/*
			 * Retourne ptr sur l'elt trouv‚:
			 */
			return	pDblTxt_elt;
		}
		pDblTxt_elt = pDblTxt_elt -> next;
	}

	return	NULL;		/* Pas trouv‚ */

}



/*
 * dup_KeyWordList(-)
 *
 * Purpose:
 * --------
 * Duplique une liste de params commandes
 *
 * History:
 * --------
 * 18.05.94: fplanque: Created based on dup_voies()
 * 21.09.94: fplanque: Utilise dup_String()
 * 15.03.95: appel de KeyWordLElt_Create()
 * 29.03.95: extended
 */
KEYWORD_LIST	*dup_KeyWordList( 
		const KEYWORD_LIST * pDblTxt_srce )
{
	KEYWORD_LIST  *	pDblTxt_dest1st;		/* 1er elt de la liste destination */
	KEYWORD_LIST * *	lastptr_to_next = &pDblTxt_dest1st;	/* Adr du dernier ptr sur le champ suivant */
	KEYWORD_LIST  *	pDblTxt_destCurr;		/* Elt courant de la liste destination */

	/*
	 * Copie tous les elts: 
	 */
	while( pDblTxt_srce != NULL )
	{
		/*
		 * Cr‚e nouvel elt:
		 */
		pDblTxt_destCurr = KeyWordLElt_Create( 
										pDblTxt_srce -> n_Event,
										pDblTxt_srce -> n_Action1,
										pDblTxt_srce -> n_Action2,
										dup_String( pDblTxt_srce -> psz_KeyWord ), 
										dup_String( pDblTxt_srce -> psz_DestPage ) );

		/*
		 * Lie ce champ au pr‚c‚dent: 
		 */
		*lastptr_to_next = pDblTxt_destCurr;

		/*
		 * Nouvelle adr du dernier ptr sur champ suivant: 
		 */
		lastptr_to_next = &(pDblTxt_destCurr -> next);

		/*
		 * Passe au champ source suivant: 
		 */
		pDblTxt_srce = pDblTxt_srce -> next;
	}



	/*
	 * Signale fin de la liste: 
	 */
	*lastptr_to_next = NULL;

	/*
	 * Retourne ptr sur nlle liste: 
	 */
	return	pDblTxt_dest1st;
}



/*
 * CmdList_Create(-)
 *
 * Purpose:
 * --------
 * Cr‚e une liste de params commandes
 *
 * History:
 * --------
 * 29.03.95: fplanque: Created
 * 21.09.94: fplanque: Utilise dup_String()
 * 15.03.95: appel de KeyWordLElt_Create()
 * 29.03.95: extended
 */
KEYWORD_LIST	*CmdList_Create( 
						const KEYWORD_LIST * pKWElt_srce )
{
	KEYWORD_LIST  *	pDblTxt_dest1st;		/* 1er elt de la liste destination */
	KEYWORD_LIST * *	lastptr_to_next = &pDblTxt_dest1st;	/* Adr du dernier ptr sur le champ suivant */
	KEYWORD_LIST  *	pDblTxt_destCurr;		/* Elt courant de la liste destination */
	int 					i;

	for( i=0; pKWElt_srce[i] .n_Event != NIL; i++ )
	{	/*
		 * Cr‚e nouvel elt:
		 */
		pDblTxt_destCurr = KeyWordLElt_Create( 
										pKWElt_srce[i] .n_Event,
										pKWElt_srce[i] .n_Action1,
										pKWElt_srce[i] .n_Action2,
										dup_String( pKWElt_srce[i] .psz_KeyWord ), 
										dup_String( pKWElt_srce[i] .psz_DestPage ) );

		/*
		 * Lie ce champ au pr‚c‚dent: 
		 */
		*lastptr_to_next = pDblTxt_destCurr;
		/*
		 * Nouvelle adr du dernier ptr sur champ suivant: 
		 */
		lastptr_to_next = &(pDblTxt_destCurr -> next);
	}

	/*
	 * Signale fin de la liste: 
	 */
	*lastptr_to_next = NULL;

	/*
	 * Retourne ptr sur nlle liste: 
	 */
	return	pDblTxt_dest1st;
}


/*
 * free_KeyWordList(-)
 *
 * Purpose:
 * --------
 * LibŠre: efface une liste chain‚e de la m‚moire
 *
 * Notes:
 * ------
 * attentions aux cas G_empty
 *
 * History:
 * --------
 * 24.05.94: fplanque: Created
 * 16.03.95: appel de KeyWordLElt_Destroy()
 */
void	free_KeyWordList( 	
			KEYWORD_LIST * pDblTxt_List )
{
	KEYWORD_LIST * pDblTxt_CurrElt = pDblTxt_List;
	KEYWORD_LIST * pDblTxt_NextElt;

	while( pDblTxt_CurrElt != NULL )
	{
		pDblTxt_NextElt = pDblTxt_CurrElt -> next;

		KeyWordLElt_Destroy( pDblTxt_CurrElt );
		
		pDblTxt_CurrElt = pDblTxt_NextElt;
	}
}



/*
 * cree_ligne_KeyWord(-)
 *
 * Purpose:
 * --------
 * Cr‚e une ligne d'infos sur un elt de liste KEYWORD_LIST
 * pour l'ins‚rer ds liste 
 *
 * History:
 * --------
 * 18.05.94: fplanque: Created based on cree_ligne_voie()
 * 15.03.95: on recommence tout
 * 12.04.95: enhanced
 */
char * cree_ligne_KeyWord( 					/* Out: Ligne de texte g‚n‚r‚e */
			KEYWORD_LIST *	pDblText_curr,		/* In:  Elt de liste … transformer en ligne */
			BOOL				b_MotClef )			/* In:  True s'il s'agit d'un mot clef */
{
	size_t	st_len;
	const	char	*	cpsz;

	const size_t	st_LongMotClef	= 14;	/* In:  Long max du champ mot clef */
	const size_t	st_LongAction	= 14;	/* In:  Long max du champ action */
	const size_t	st_LongTotale	= 43;	/* In:  Long totale */

	/*
	 * Init buffer de composition:
	 */
	memset( G_tmp_buffer, ' ', st_LongTotale );

	if( b_MotClef )
	{	/*
		 * Mot clef:
		 */
		cpsz = pDblText_curr -> psz_KeyWord;
	}
	else
	{	/*
		 * Touche press‚e:
		 */
		cpsz = fnct_spec( G_fnctlink, pDblText_curr -> n_Event ) -> fnct_name;
	}
	st_len = len_String( cpsz );
	copy_String( G_tmp_buffer, cpsz );
	G_tmp_buffer[ st_len ] = ' ';
	G_tmp_buffer[ st_LongMotClef-1 ] = ' ';

	/*
	 * Action:
	 */
	cpsz = get_popup_name( G_Popup_ActionMenu, pDblText_curr-> n_Action1 );
	st_len = len_String( cpsz );
	copy_String( G_tmp_buffer + st_LongMotClef, cpsz );
	G_tmp_buffer[ st_LongMotClef + st_len ] = ' ';
	G_tmp_buffer[ st_LongMotClef + st_LongAction -1 ] = ' ';
	
	/*
	 * Destination:
	 */
	cpsz = pDblText_curr -> psz_DestPage;
	st_len = len_String( cpsz );
	copy_String( G_tmp_buffer + st_LongMotClef + st_LongAction, cpsz );
	G_tmp_buffer[ st_LongMotClef + st_LongAction + st_len ] = '\0';

	/*
	 * Fin de chaŒne:
	 */
	G_tmp_buffer[ st_LongTotale ] = '\0';

	/*
	 * Sauve chaine dans tableau:
	 */		
	return	STRDUP( G_tmp_buffer );
}



/*
 * cree_liste_KeyWord(-)
 *
 * Purpose:
 * --------
 * Creation d'une liste de descripteurs textuels
 * sous forme de tableau de ptrs sur strings
 * correspondant … une liste chain‚e de type KEYWORD_LIST
 *
 * Algorythm:
 * ----------  
 * appelle cree_ligne_KeyWord() pour chaque ligne
 *
 * Notes:
 * ------
 * Si nb_lignes = 0, on alloue qd mˆme un tableau de taille nulle.
 *
 * History:
 * --------
 * 18.05.94: fplanque: Created
 * 12.04.95: enlev‚ parametres de longueur, ajout‚ b_Command
 */
int	cree_liste_KeyWord(	 					/* Out: Nbre de lignes dans la liste */
			KEYWORD_LIST *	pDblText_First,	/* In:  Ptr sur 1er elt de liste chain‚e */
			BOOL				b_Command,			/* In:  TRUE s'il s'agit de commandes, non pas d'ebents */
			char 		* * *	pTpS_lignes )		/* Out: Ptr sur Tableau de ptrs sur strings */
{
	KEYWORD_LIST *	pDblText_curr = pDblText_First;
	char 			* *	TpS_lignes;			/* Tableau contenant les lignes */
	int				 	nb_lignes = 0;
	int					i;

	/* 
	 * Compte lignes: 
	 */
	while( pDblText_curr != NULL )
	{
		nb_lignes ++;						/* 1 ligne de plus */
		pDblText_curr = pDblText_curr -> next;
	}


	/*
	 * Cr‚e zones de stockage: 
	 */
	TpS_lignes = (char * *) MALLOC( sizeof( char* ) * nb_lignes );

	/* 
	 * Remplit tableau: 
	 */
	pDblText_curr = pDblText_First;		/* Commence sur 1Šre page ‚cran de la page arbo */
	for ( i=0; i<nb_lignes; i++ )
	{
		/*
		 * Cr‚e chaine et la Sauve dans tableau:
		 */		
		TpS_lignes[ i ] = cree_ligne_KeyWord( pDblText_curr, b_Command );
	
		/*
		 * Elt de liste suivant: 
		 */
		pDblText_curr = pDblText_curr -> next;
	}

	/*
	 * Valeurs en retour: 
	 */
	*pTpS_lignes = TpS_lignes;

	return	nb_lignes;
	
}


/*
 * detruit_listeTpS(-)
 *
 * Purpose:
 * --------
 * Destruction d'une liste sous forme de tableau de ptrs sur strings
 *
 * Notes:
 * ------
 * G_empty_string est utilis‚ pour les chaines vides et ne doit
 * pas ˆtre d‚sallou‚ (FREE())
 *
 * History:
 * --------
 * 18.05.94: fplanque: Created
 */
void	detruit_listeTpS(	 	
			char * *	TpS_lignes,			/* In: Tableau de ptrs sur strings */
			int		nb_lignes )			/* In: Nbre de lignes ds le tableau */
{
	int i;
	
	/*
	 * LibŠre les strings:
	 */
	for ( i=0; i<nb_lignes; i++ )
	{
		if( TpS_lignes[ i ] != G_empty_string )
		{	/* 
			 * S'il y a un string … effacer: 
			 */
			FREE( TpS_lignes[ i ] );
		}
	}

	/*
	 * LibŠres la zone de stockage du tableau: 
	 */
	FREE( TpS_lignes );
}



/*
 * load_motsclefs(-)
 *
 * Purpose:
 * --------
 * Charge mots clefs relatifs … une page arbo
 *
 * Notes:
 * ------
 *
 * History:
 * --------
 * 24.05.94: fplanque: Created
 * 15.03.95: appel de KeyWordLElt_Create()
 * 29.03.95: extended
 * 08.04.95: petites modifs
 */
KEYWORD_LIST * load_motsclefs( 
						FILE	*	fstream,		/* In: fichier ds lequel on lit */
						CMD_KIND	CmdKind,		/* In: type de donn‚es */
						int		n_Version )	/* In: Version du fichier */
{
	size_t			load_res;			/* R‚sultat de l'op‚ration de chargement */
	KEYWORD_LIST *	p_first;				/* 1er paramŠtre */
	KEYWORD_LIST **pp_lastnext = &p_first;	/* Adr Ptr sur prochain ds le pr‚c‚dent */
	KEYWORD_LIST *	p_current;			/* Param courant */
	char			 * psz_Cmd = NULL;
	char			 * psz_Dest;
	UINT				u_Event;
	int				n_Action1;
	int				n_Action2;
	UINT				u_flags;

	/*
	 * Mots clefs: 
	 */
	while
	( 
		load_res = fread( &u_Event, sizeof( unsigned ), 1, fstream ),
		load_res == 1 /*PasFinFichier*/  &&  u_Event != 0xFFFF /*PasFinListe*/
	)
	{	/*
		 * Tant qu'il y a des trucs … charger: 
		 */
		if( n_Version < 0x0005 )
		{	/*
			 * Anciens formats:
			 */
			n_Action1 = ACTION_NONE;
			n_Action2 = ACTION_NONE;
			u_flags	 = 0;						/* 08.04.95 */

			if( CmdKind == CMD_KEYWORD )
			{	/*
				 * Mot clef:
				 */
				u_Event = FL_ENVOI;	/* Par d‚faut, l'evt est ENVOI */
	
				psz_Cmd  = load_String( fstream );
				if( n_Version >= 0x004 )
				{
					fread( &n_Action1, sizeof( n_Action1 ), 1, fstream );
				}
				else
				{
					n_Action2 = ACTION_FULLCLS;
				}
			}
			else
			{	/*
				 * si lien arbo ancien format, pas de donn‚es compl‚mentaires
				 * … charger... mais:
				 */
				n_Action2 = ACTION_FULLCLS;
			}
			
			/*
			 * Charge destination:
			 */
			psz_Dest = load_String( fstream );
		}
		else
		{	/*
			 * Nouveau formats (v0.05):
			 * u_Event est d‚j… charg‚!
			 */
			fread( &n_Action1, sizeof( n_Action1 ), 1, fstream );
			fread( &n_Action2, sizeof( n_Action2 ), 1, fstream );
			fread( &u_flags,   sizeof( u_flags ),   1, fstream );
			psz_Cmd = load_String( fstream );
			psz_Dest = load_String( fstream );
		}
		
		/*
		 * Cr‚e le mot clef: 
		 */
		p_current = KeyWordLElt_Create( u_Event, n_Action1, n_Action2, psz_Cmd, psz_Dest );
		
		/*
		 * Liaison avec le pr‚c‚dent: 
		 */
		*pp_lastnext = p_current;	/* Indique adresse du MC courant */

		/*
		 * Sauve adresse du ptr dans lequel il va falloir placer l'adr du param suivant: 
		 */
		pp_lastnext = &( p_current -> next );			
	}

	/*
	 * Signale fin de la liste: 
	 */
	*pp_lastnext = NULL;		/* Plus de MC aprŠs */

	/*
	 * Contr“le si le chargement est ok: 
	 */
	if( u_Event != 0xFFFF )
	{	/*
		 * S'il y a eu un problŠme: 
		 * Efface le d‚but de liste: 
		 */
		free_KeyWordList( p_first );
		p_first = NULL;	/* Plus de liste */
	}

	/* 
	 * Renvoie l'adresse du 1er mot clef: 
	 */
	return	p_first;
}




/*
 * save_motsclef(-)
 *
 * Purpose:
 * --------
 * Sauve les mots clefs
 *
 * Notes:
 * ------
 *
 * History:
 * --------
 * 24.05.94: fplanque: Created
 * 31.03.95: format de fichier v0.05
 */
void	save_motsclef( 
			FILE 			 	*	fstream,
			KEYWORD_LIST	*	p_MotsClefs )
{
	/*
	 * Sauve mots clefs: 
	 */
	while( p_MotsClefs != NULL )
	{	/* 
		 * Tant qu'il y a des mots-clefs … sauver 
	 	 * Sauve event, action et flags: 
	 	 */
		fwrite( &(p_MotsClefs -> n_Event), sizeof(int) * 3 + sizeof(UINT), 1, fstream );
		/*
		 * Sauve mot clef:
		 */
		save_String( p_MotsClefs -> psz_KeyWord, fstream );	/* Sauve texte */
		/*
		 * Sauve destination: 
		 */
		save_String( p_MotsClefs -> psz_DestPage, fstream );	/* Sauve texte */

		/*
		 * Passe au paramŠtre suivant: 
		 */
		p_MotsClefs = p_MotsClefs -> next;
	}

	/*
	 * Fin de la liste: 
	 */
	fputc( 0xFF, fstream );		/* Ajoute 0xFFFF pour signaler */
	fputc( 0xFF, fstream );		/* La fin de la liste */
}

