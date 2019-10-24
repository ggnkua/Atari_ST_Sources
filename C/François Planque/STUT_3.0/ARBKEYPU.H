/*
 * Arbo_Keyword_Public.h
 *
 * 14.03.95: created
 */

#ifndef _ARBKEYWD_PU_H_ 
#define _ARBKEYWD_PU_H_

#include "ARBKEYWD.H"
#include "POPUP.H"

typedef
	enum
	{
		CMD_EVENT,
		CMD_KEYWORD
	}
	CMD_KIND;
	

extern	POPUP_ENTRY	G_Popup_ActionMenu[];

KEYWORD_LIST * KeyWordLElt_Create(
						int		n_Event,		/* In: Code ‚vŠnement */
						int		n_Action1,	/* In: Action a entreprendre */
						int		n_Action2,	/* In: Action a entreprendre */
						char	*	psz_Cmd,		/* In: Commande … taper */
						char	*	psz_Dest );	/* In: Page arbo destination */

BOOL	CmdList_Replace1Content(			/* Out: TRUE_1 si ok */
				KEYWORD_LIST * pCmd_List,		/* In: Liste de Commandes */
				int				n_Event,			/* In: Code ‚vŠnement */
				int				n_Action1,		/* In: Action a entreprendre */
				int				n_Action2,		/* In: Action a entreprendre */
				char			*	psz_Cmd,			/* In: Commande … taper */
				char			*	psz_Dest );		/* In: Page arbo destination */

void KeyWordLElt_Destroy(
		KEYWORD_LIST * pKeyWordLElt ); /* In: Elt … d‚truire */

void	save_motsclef( 
							FILE 			 	*	fstream,
							KEYWORD_LIST	*	p_MotsClefs );

KEYWORD_LIST *load_motsclefs( 
							FILE	*	fstream,			/* In: fichier ds lequel on lit */
							CMD_KIND	CmdKind,			/* In: type de donn‚es */
							int		n_Version );	/* In: Version du fichier */

extern	KEYWORD_LIST *	findElt_KWLst_byIndex( 	
										KEYWORD_LIST * pDblTxt_List,
										int				 n_index );

extern	KEYWORD_LIST *	findElt_KWLst_by1stName( 	
										KEYWORD_LIST * pDblTxt_List,
										const char	  * cpsz_SearchString );

extern	KEYWORD_LIST	*dup_KeyWordList( 
									const KEYWORD_LIST * pDblTxt_srce );
KEYWORD_LIST	*CmdList_Create( 
						const KEYWORD_LIST * pKWElt_srce );

extern	void	free_KeyWordList( 	
									KEYWORD_LIST * pDblTxt_List );

char * cree_ligne_KeyWord( 					/* Out: Ligne de texte g‚n‚r‚e */
			KEYWORD_LIST *	pDblText_curr,		/* In:  Elt de liste … transformer en ligne */
			BOOL				b_MotClef );		/* In:  True s'il s'agit d'un mot clef */

int	cree_liste_KeyWord(	 					/* Out: Nbre de lignes dans la liste */
			KEYWORD_LIST *	pDblText_First,	/* In:  Ptr sur 1er elt de liste chain‚e */
			BOOL				b_Command,			/* In:  TRUE s'il s'agit de commandes, non pas d'ebents */
			char 		* * *	pTpS_lignes );		/* Out: Ptr sur Tableau de ptrs sur strings */

extern	void	detruit_listeTpS(	 	
						char * *	TpS_lignes,			/* In: Tableau de ptrs sur strings */
						int		nb_lignes );		/* In: Nbre de lignes ds le tableau */


#endif /* #ifndef _ARBKEYWD_PU_H_  */