/*
 * Lists_Public.h
 */

typedef
	struct	SingleLink
	{
		struct SingleLink *	p_Next;
		union
		{
			int		n_Fnct;
			void *	ptr;
		}							pseudo_key;
	}
	SGLE_LINK_LIST_ELT;
		


void *	Lookup_SingleLinkList(
				void	*	p_Elt, 
				int		n_Fnct );
void *	Lookup_PtrInSingleLinkList(
				void	*	p_Elt, 
				void	*	ptr_sought );	/* In: pointeur … rechercher */

void	*	Get_ithEltInSingleLinkList( 	/* Out: Ptr sur elt d'index demand‚ */
				void *	pListElt_First,	/* In:  Ptr sur 1er elt */
				int		n_Index );			/* In:  No d'ordre */

void	*	Insert_InSingleLinkList(		/* Out: Nouveau d‚but de liste */
				void	*	pListElt_First,	/* In:  premier elt liste ou NULL si pas encore de liste */
				void	*	pListElt_New );	/* In:  Nouvel elt */ 

void	*	Append_ToSingleLinkList(		/* Out: Nouvelle fin de liste */
				void	*	pListElt_Any,		/* In:  Un elt de liste, de pref le dernier ou NULL si pas encore de liste */
				void	*	pListElt_New );	/* In:  Nouvel elt */ 

void	*	Duplicate_SingleLinkList( 
				const void *	pListElt_Srce, 	/* In: Ptr sur 1er elt liste source */
				size_t 			size_Element );		/* In: Taille d'un ‚l‚ment */

void	Delete_SingleLinkList( 
			void *	pListElt_First );
