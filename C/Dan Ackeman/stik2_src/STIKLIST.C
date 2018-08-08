/* Must define STiKListKeyType and STiKListValType before including this file! */typedef struct stik_lnde{	STiKListKeyType	key;	STiKListValType	val;	struct stik_lnde	*next;} *STiKListNode;typedef STiKListNode	*STiKList;static  voidSTiKListDeleteNode( STiKListNode n ){	STiKfree( (char *)n );}static  voidSTiKListDelete( STiKList lst ){	STiKListNode	n = (STiKListNode) lst;	STiKListNode	i;	while ( n != NULL )	{		i = n->next;		STiKListDeleteNode( n );		n = i;	}}static  STiKListSTiKListInit( STiKList lst ){	if ( lst != NULL )		STiKListDelete( lst );	return NULL;}static  intSTiKListEmpty( STiKList lst ){	return ( lst == NULL );}static  STiKListNodeSTiKListNewNode( STiKListKeyType k, STiKListValType v ){	STiKListNode	n = (STiKListNode) STiKmalloc( sizeof(struct stik_lnde) );	n->key = k;	n->val = v;	n->next = NULL;	return n;}static  STiKListSTiKListInsertNode( STiKList lst, STiKListNode n ){	if ( lst != NULL )	{		n->next = (STiKListNode) lst;	}	return (STiKList) n;}static  STiKListSTiKListAdd( STiKList lst, STiKListKeyType k, STiKListValType v ){	return STiKListInsertNode( lst, STiKListNewNode( k, v ) );}static  STiKListNodeSTiKListGetAnyNode( STiKList lst ){	return (STiKListNode) lst;}static STiKListNode
STiKListGetNextNode( STiKList lst, STiKListNode n )
{
	(void) lst;

	if ( n == NULL )
	{
		return NULL;
	}
	else
	{
		return n->next;
	}
}

static  STiKListValTypeSTiKListFindKey( STiKList lst, STiKListKeyType k ){	STiKListNode	n = (STiKListNode) lst;	while ( ( n != NULL ) && ( n->key != k ) )	{		n = n->next;	}	if ( n != NULL )	{		return n->val;	}	else	{		return (STiKListValType) 0;	}}static  STiKListSTiKListRemoveKey( STiKList lst, STiKListKeyType k ){	STiKListNode	n = (STiKListNode) lst;	STiKListNode	p = n;	if ( ( n->next == NULL ) && ( n->key == k ) )	{		STiKListDeleteNode( p );		return NULL;	}	else if ( n->key == k )	{		n=n->next;		STiKListDeleteNode( p );		return (STiKList) n;	}	else	{		while ( ( n->next != NULL ) && ( n->next->key != k ) )		{			n = n->next;		}		p = n->next;		n->next = n->next->next;		STiKListDeleteNode( p );		return lst;	}}static  STiKListSTiKListRemoveNode( STiKList lst, STiKListKeyType k ){	STiKListNode	n = (STiKListNode) lst;	/*STiKListNode	p = n;*/	if ( ( n->next == NULL ) && ( n->key == k ) )	{		return NULL;	}	else if ( n->key == k )	{		return (STiKList) n->next;	}	else	{		while ( ( n->next != NULL ) && ( n->next->key != k ) )		{			n = n->next;		}		/*p = n->next;*/		n->next = n->next->next;		return lst;	}}