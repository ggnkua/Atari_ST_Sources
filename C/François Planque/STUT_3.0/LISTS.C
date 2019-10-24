/*
 * Lists.c
 *
 * Purpose:
 * --------
 * Gestion de listes
 * Pour toute liste chain‚e commen‡ant par:
 * 	void *	next
 *		int		fnct_no
 *
 * 18.11.94: created
 */ 

	#include "!OPTIONS.H"

	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

/*
 * Custom Headers
 */ 
	#include "LISTS_PU.H"
	#include "S_MALLOC.H"


/*
 * Lookup_SingleLinkList(-)
 *
 * 18.11.94: fplanque: Created
 */
void *	Lookup_SingleLinkList(
				void	*	p_Elt, 
				int		n_Fnct )
{
	while( p_Elt != NULL )
	{	
		if( ((SGLE_LINK_LIST_ELT *) p_Elt) -> pseudo_key.n_Fnct == n_Fnct )
		{
			break;
		}

		p_Elt = ((SGLE_LINK_LIST_ELT *) p_Elt) -> p_Next;
	}
	
	return	p_Elt;
}


/*
 * Lookup_PtrInSingleLinkList(-)
 *
 * 25.01.95: fplanque: Created based on Lookup_SingleLinkList
 */
void *	Lookup_PtrInSingleLinkList(
				void	*	p_Elt, 
				void	*	ptr_sought )	/* In: pointeur … rechercher */
{
	while( p_Elt != NULL )
	{	
		if( ((SGLE_LINK_LIST_ELT *) p_Elt) -> pseudo_key.ptr == ptr_sought )
		{
			break;
		}

		p_Elt = ((SGLE_LINK_LIST_ELT *) p_Elt) -> p_Next;
	}
	
	return	p_Elt;
}


/*
 * Get_ithEltInSingleLinkList(-)
 *
 * Purpose:
 * --------
 * Trouve un elt en fnct de son num‚ro d'ordre ds la liste
 *
 * History:
 * --------
 * 04.12.94: fplanque: Created
 */
void	*	Get_ithEltInSingleLinkList( 	/* Out: Ptr sur elt d'index demand‚ */
				void *	pListElt_First,	/* In:  Ptr sur 1er elt */
				int		n_Index )			/* In:  No d'ordre */
{
	SGLE_LINK_LIST_ELT	*	pSLLE_Curr = pListElt_First;

	int	i;		/* Compteur */

	for( i=0; i < n_Index  &&  pSLLE_Curr != NULL; i++ )
	{	/*
		 * Tant qu'on est pas arriv‚ au champ qui nous int‚resse 
		 * et qu'on est pas … la fin de la liste: 
		 * Passe au champ suivant...
		 */
		pSLLE_Curr = pSLLE_Curr -> p_Next;
	}

	return	pSLLE_Curr;		/* Ptr sur params; NULL si pas trouv‚ */
}
   


/*
 * Append_ToSingleLinkList(-)
 *
 * 29.11.94: fplanque: Created
 */
void	*	Append_ToSingleLinkList(		/* Out: Nouvelle fin de liste */
				void	*	pListElt_Any,		/* In:  Un elt de liste, de pref le dernier (sinon on le cherchera nous meme) ou NULL si pas encore de liste */
				void	*	pListElt_New )		/* In:  Nouvel elt */ 
{
	SGLE_LINK_LIST_ELT	*	pSLLE_Last	= pListElt_Any;
	SGLE_LINK_LIST_ELT	*	pSLLE_New	= pListElt_New;

	if( pSLLE_Last != NULL )
	{
		while( pSLLE_Last -> p_Next != NULL )
		{
			pSLLE_Last = pSLLE_Last -> p_Next;
		}	
	
		pSLLE_Last -> p_Next = pSLLE_New;
	}

	pSLLE_New -> p_Next = NULL;
	
	
	return	pSLLE_New;
}


/*
 * Insert_InSingleLinkList(-)
 *
 * InsŠre en premiŠre position
 *
 * 25.01.95: fplanque: Created
 */
void	*	Insert_InSingleLinkList(		/* Out: Nouveau d‚but de liste */
				void	*	pListElt_First,	/* In:  premier elt liste ou NULL si pas encore de liste */
				void	*	pListElt_New )		/* In:  Nouvel elt */ 
{
	SGLE_LINK_LIST_ELT	*	pSLLE_New	= pListElt_New;

	pSLLE_New -> p_Next = pListElt_First;
	
	return	pSLLE_New;
}



/*
 * Duplicate_SingleLinkList(-)
 *
 * Purpose:
 * --------
 * Duplique une liste simplement chain‚e
 *
 * Notes:
 * ------
 * A n'utiliser que si les elements … copier ne contiennent pas de pointeurs
 * et en particulier pas de psz car les objets point‚s ne seraient pas copi‚s.
 *
 * History:
 * --------
 * 04.12.94: fplanque: Created by using dup_fieldpar()
 */
void	*	Duplicate_SingleLinkList( 
				const void *	pListElt_Srce, 	/* In: Ptr sur 1er elt liste source */
				size_t 			size_Element )		/* In: Taille d'un ‚l‚ment */
{
	/*
	 * Pointeurs: 
	 */
	const SGLE_LINK_LIST_ELT *		pSLLE_Srce = pListElt_Srce;	/* 1er elt de la liste destination */
	SGLE_LINK_LIST_ELT *		pSLLE_FirstDest;			/* 1er elt de la liste destination */
	SGLE_LINK_LIST_ELT * *	lastptr_to_next = &pSLLE_FirstDest;	/* Adr du dernier ptr sur le champ suivant */
	SGLE_LINK_LIST_ELT *		pSLLE_Dest;					/* Elt courant de la liste destination */

	/*
	 * Copie tous les ‚l‚ments: 
	 */
	while( pSLLE_Srce != NULL )
	{
		/*
		 * Cr‚e nouvel ‚l‚ment; 
		 */
		pSLLE_Dest = MALLOC( size_Element );

		/*
		 * Copie le contenu: 
		 */
		memcpy( pSLLE_Dest, pSLLE_Srce, size_Element );

		/*
		 * Lie ce champ au pr‚c‚dent: 
		 */
		*lastptr_to_next = pSLLE_Dest;
		/*
		 * Nouvelle adr du dernier ptr sur champ suivant: 
		 */
		lastptr_to_next = &(pSLLE_Dest -> p_Next);
						
		/*
		 * Passe au champ source suivant: 
		 */
		pSLLE_Srce = pSLLE_Srce -> p_Next;
	}

	/*
	 * Signale fin de la liste: 
	 */
	*lastptr_to_next = NULL;

	/*
	 * Retourne ptr sur nlle liste: 
	 */
	return	pSLLE_FirstDest;
}



/*
 * Delete_SingleLinkList(-)
 *
 * Purpose:
 * --------
 * Efface 1 liste chain‚e d'‚l‚ments
 *
 * History:
 * --------
 * 04.12.94: fplanque: Created
 */
void	Delete_SingleLinkList( 
			void *	pListElt_First )
{
	SGLE_LINK_LIST_ELT *	pSLLE_This = pListElt_First;
	SGLE_LINK_LIST_ELT *	pSLLE_Next;
	
	while( pSLLE_This != NULL )
	{
		pSLLE_Next = pSLLE_This -> p_Next;		/* Champ suivant */

		FREE( pSLLE_This );							/* Efface le champ courant */

		pSLLE_This = pSLLE_Next;					/* Passe au champ suivant */
	}
}
