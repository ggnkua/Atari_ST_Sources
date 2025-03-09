#ifndef __LIST__
#define __LIST__

/*
 * --------------------- Typdefinitionen --------
 */
typedef struct TNode{
	struct TNode *next;
	void         *pval;
} TNode;

typedef TNode  TList;

typedef int ( *TCmpF) ( void *e1, void *e2);
typedef void ( *Tv_pv) ( void *p);

/*
 * --------------------- Prototypen -------------
 */
TList *ls_Create( void);
TNode *ls_Insert( TNode *n, void *e);
TNode *ls_SInsert( TList *a, void *e, TCmpF cmp);
TNode *ls_RmNext( TNode *n);
void ls_ForAll( TList *a, Tv_pv func);
TNode *ls_Search( void *p, TList *a, TCmpF cmp);
void ls_Free( TList *a);
void ls_VFree( TList *a, Tv_pv ff);

#endif  /* __LIST__ */
