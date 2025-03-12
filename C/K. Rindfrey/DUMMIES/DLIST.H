#ifndef __DLIST__
#define __DLIST__

/*
 * --------------------- Typdefinitionen --------
 */
typedef struct TDNode{
	struct TDNode	*next;
	struct TDNode	*prev;
	void				*pval;
} TDNode;

typedef TDNode     TDList;

typedef int ( *TCmpF) ( void *e1, void *e2);
typedef void ( *Tv_pv) ( void *p);

/*
 * --------------------- Defines ----------------
 */
 #define dl_InsPrev(n,e) dl_InsNext((n)->prev,e)
/*
 * FÅgt e als VorgÑnger von n ein.
 * RÅckgabe : Zeiger auf VorgÑngerknoten von n.
 */

/*
 * --------------------- Prototypen -------------
 */
TDList *dl_Create( void);
TDNode *dl_InsNext( TDNode *np, void *ep);
TDNode *dl_Remove( TDNode *n);
TDNode *dl_Search( void *p, TDList *a,
                                    TCmpF cmp);
TDNode *dl_RevSearch( void *p, TDList *a,
                                    TCmpF cmp);
void dl_ForAll( TDList *a, Tv_pv func);

#endif /* __DLIST__ */
