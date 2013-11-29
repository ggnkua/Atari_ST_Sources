/*==========================================================================*/
/* TOKEN.C
 * =======
 * universal data management
 *
 * - Data type is Token.
 * - Dynamic memory management for tokens.
 * - STACK STORAGE
 * - HASH TABLE STORAGE
 *
 *
 * Author: Pascal Fellerich
 *
 * rev 0.00	25-jan-1995	creation
 * rev 1.00 30-jan-1995 first official, fully debugged release
 * rev 1.01 24-apr-1996 dynamic token length to accommodate long strings.
 *
 */
/*==========================================================================*/

#include "scanner.h"

/*==========================================================================*/
/* global variables, visible from outside									*/
/*==========================================================================*/

long tk_created;				/* number of tokens created */
long tk_disposed;				/* number of tokens released */


/*==========================================================================*/
/* LOW LEVEL COMMON TOKEN FUNCTIONS											*/
/*==========================================================================*/

/*
 * tk_create:	create a new token.
 *
 * param:	desired data field length, 0 for default
 *
 * return:	Token ptr if successful
 *
 * global:	tk_created is incremented on success
 */
Token *tk_create(size_t datasize)
{
	Token	*t;

	if (datasize<=0) datasize = DEFNAME_LEN;		/* use default */

	/* round DOWN to the next block size */
	datasize = datasize & (-STRBLOCK_LEN);

	/* compute effective space taken by the token */
	datasize = sizeof(Token)+datasize;

	t = calloc(1, datasize);					/* alloc space */
	if (t)
	{
		tk_created++;
		/* t->tsize = datasize; */
	}
	else internal_error("tk_create() failed - OUT OF MEMORY!");
	return t;
}


/*
 * tk_dispose:
 *
 * param:	The token to be released. (NULL ptrs are also allowed)
 *
 * return:	TRUE if successful.
 *
 * global:	tk_disposed is incremented on success
 */
BOOL tk_dispose(Token *t)
{
	/* assert(t!=NULL); */					/* trap token null ptr */

	if (t==NULL) return FALSE;

	if (t->next!=NULL) {
		internal_error("tk_dispose() failed - token still in use");
		return FALSE;				/* must be unlinked! */
	};
	tk_disposed++;
	free(t);
	return TRUE;
}


/*
 * tk_zero:	zero out a token. Only data fields are zeroed out, the link ptr
 *			and the size field remain untouched.
 *
 * param:	ptr to the token.
 *
 * return:	none.
 */
void tk_zero(Token *t)
{
	Token	*tmp_next;				/* size_t	tmp_size; */

	assert(t!=NULL);				/* trap null ptr */

	tmp_next = t->next;				/* tmp_size = t->tsize; */
	memset(t, 0, sizeof(Token));	/* memset(t, 0, t->tsize ); */
	t->next = tmp_next;				/* t->tsize = tmp_size; */
}


/*
 * tk_copy:	copy a token. Both destination and copy must be valid tokens.
 *			The link pointer is not copied, the size field remains untouched
 *			as well.
 *
 * param:	dest, src: the destination and source tokens.
 *
 * return:	ptr to the destination
 */
Token *tk_copy(Token *dest, const Token *src)
{
	Token	*tmp_next;					/* size_t	tmp_size; */

	assert(dest!=NULL);					/* trap null ptr */
	assert(src!=NULL);					/* trap null ptr */

	tmp_next = dest->next;
	memcpy(dest, src, sizeof(Token)-STRBLOCK_LEN);
	strcpy(dest->name, src->name);
	dest->next = tmp_next;
	return dest;
}


/*
 * tk_dup:	duplicate a token. The copy has the null ptr nulled out. The
 *			name field is reduced to the effective size to save space.
 *			tk_dup(NULL) is synonym for tk_create(DEFNAME_LEN).
 *
 * param:	The token to be duplicated. If a NULL pointer is given,
 *			an empty token will be returned.
 *
 * return:	Pointer to the new token.
 *
 * calls:	create_token
 */
Token *tk_dup(Token *t)
{
	Token	*tnew;
	size_t	dsize;

	if (t==NULL) 						/* NULL ptr supplied */
		return tk_create(DEFNAME_LEN);	/* -> return empty token */

	dsize=strlen(t->name);				/* get effective name lenght */
	if ((tnew=tk_create(dsize))==NULL) return NULL;

	return tk_copy(tnew, t);
}



/* ======================================================================== */
/* TOKEN STACKS																*/
/* ======================================================================== */

/*
 * stack_init:	to be called on every stack before first use.
 *
 * param:	Stack *st - ptr to the new stack
 */
void stack_init(Stack *st)
{
	if (st==NULL) return;
	st->root=NULL;
	st->count=0;
}



/*
 * tk_push:	push the given token onto the stack. The token must not be linked
 *			into any other type of list.
 *
 * param:	Stack *st: the stack to be used
 *			Token *t : the token to be pushed onto the stack
 *
 * return:	TRUE if the operation was successful
 *
 */
BOOL tk_push(Stack *st, Token *t)
{
	assert(st!=NULL);					/* trap stack null ptr */
	assert(t!=NULL);					/* and also null Token ptr */
	
	if (t->next!=NULL) {
		internal_error("tk_push(): token already in use");
		return FALSE;					/* element already linked */
	}
	t->next = st->root;
	st->root = t;
	st->count++;						/* some book-keeping */
	return TRUE;
}


/*
 * tk_pop:	pop the upper token from the stack and return it. If the stack
 *			is empty, create an empty token and return it.
 *
 * param:	Stack *st: the stack to be used
 *
 * return:	Pointer to the token from the stack
 *
 * call:	tk_create
 */
Token *tk_pop(Stack *st)
{
	Token	*t;

	assert(st!=NULL);					/* trap stack null ptr */

	if (st->root==NULL)
	{									/* stack is empty */
		st->count=0;					/* reset book-keeping */
		return tk_create(1);			/* -> create minimum size token */
	}
	else
	{
		t = st->root;  					/* unlink element */
		st->root = t->next;
		t->next = NULL;					/* kill link pointer */
		st->count--;					/* some book-keeping */
		return t;
	}
}


/*
 * tk_peek: returns A POINTER to the upper token on the stack
 *
 * param:	Stack *st: the stack to be used
 *
 * return:	Pointer to the upper token
 *
 */
Token *tk_peek(Stack *st)
{
	assert(st!=NULL);					/* trap stack null ptr */

	return(st->root);
}


/*
 * tk_drop:	pop the upper token from the stack and kill it.
 *
 * param:	Stack *st: the stack to be used
 *
 * return:	TRUE if successful.
 *
 * call:	tk_dispose, tk_pop
 */
BOOL tk_drop(Stack *st)
{
	assert(st!=NULL);					/* trap stack null ptr */

	if (st->root==NULL) return FALSE;	/* empty stack... */
	else return tk_dispose(tk_pop(st));
}


/*
 * tk_stack_clear: empty a stack.
 *
 * param:	Stack *st: the stack to be cleared
 *
 * return:	NULL if successful, else pointer to the token from the stack
 *
 * call:	pop_token
 */
void tk_stack_clear(Stack *st)
{
	assert(st!=NULL);					/* trap stack null ptr */

	while (tk_drop(st));				/* do until failure... */
}


/*
 * tk_stack_isempty: return TRUE if stack is empty
 *
 * param:	Stack *st: the stack to be used
 *
 * return:	BOOL
 */
BOOL tk_stack_isempty(Stack *st)
{
	if (st==NULL) return TRUE;
	return (st->root==NULL);
}


/*
 * tk_stack_size: count the number of entries in a given stack.
 *
 * param:	Stack *st: the stack to be used
 *
 * return:	number of elements on the stack
 *
 */
long tk_stack_size(Stack *st)
{
	assert(st!=NULL);					/* trap stack null ptr */

	return st->count;
}


/* ======================================================================== */
/* HASH TABLES (internal use for TOKEN TABLES)								*/
/* ======================================================================== */

/* Internal functions:
 * description: This is a simple hash table management algorithm. It uses
 * chaining to resolve collisions -> simplest and most effective way, permits
 * load factors >1, so that the size of the table is not very critical.
 * The key is an ascii string, suitable for variable and label storage.
 * Most of this is taken from K&R's C-Bible...
 */

/*
 * the hash algorithm. Taken from K&R's C-Bible, page 144ff
 */
long hash(const char *key)
{
	long hv;

	for (hv=0; *key!='\0'; key++)
		hv = *key + 31 * hv;
	return labs(hv) % HASHSIZE;
}


/*
 * hsh_lookup: look for key in a given hashtable
 * param:	*tab[] - ptr to an array of token pointers, the hashtable
 *			*key   - ptr to the key string
 *
 * return:	token pointer if successful, NULL otherwise
 *
 */
Token *hsh_lookup(Hashtable tab, const char *key)
{
	Token	*np;

	for (np=tab[hash(key)]; np!=NULL; np=np->next)
		if (strcmp(key,np->name)==0)	return np;
	return NULL;
}


/*
 * hsh_insert:	inserts the token into the table. If the key is already in
 *				table, nothing will happen.
 *
 * param:	*tab[]	- the table
 *
 * return:	Token * - ptr to the new token in the table or NULL if unsucessful
 *
 */
Token *hsh_insert(Hashtable tab, Token *t)
{
	Token	*np;
	long	hv;

	np = hsh_lookup(tab, t->name);
	if (np == NULL)						/* key not found, ==> it's a new key */
	{
		np = t;
		hv = hash(np->name);
		np->next = tab[hv];				/* collision list insertion */
		tab[hv]  = np;
		return np;
	}
	return NULL;						/* element already there */
}


/*
 * hsh_remove:  removes an entry from the table.
 *
 * param:	*tab[]	- the table
 *			*key	- the ascii key
 *
 * return:	Ptr to the removed element.
 */
Token *hsh_remove(Hashtable tab, const char *key)
{
	Token	*np,*pp;
	long	hv;

	hv=hash(key);
	for (np=tab[hv], pp=NULL; np!=NULL; pp=np, np=np->next)
		if (strcmp(key,np->name)==0)
			break;							/* key was found, exit the loop */

	if (np == NULL) return NULL;			/* key not found, removal failed */

	if (pp == NULL)	tab[hv] = np->next;		/* linked list deletion */
	else			pp->next = np->next;	/* first/following elements */
	np->next=NULL;
	return np;								/* return the element */
}


/*==========================================================================*/
/* TOKEN TABLES 															*/
/*==========================================================================*/

/*
 * hashtable_init:	to be called for every hashtable before first use.
 *
 * param:	tab - ptr to the new hashtable
 */
void hashtable_init(Hashtable tab)
{
	int	i;

	assert(tab!=NULL);					/* trap null ptr */
	for (i=0; i<HASHSIZE; i++) tab[i]=NULL;
}



/*
 * tk_store:	move a token into a hash table. Overwrites previously stored
 *				identical tokens (which are deleted).
 *
 * param:	Hashtable tab - contains the tokens
 *			Token *t - pointer to the token to be stored
 *
 * return:	Pointer to the copy in the hash table.
 */
Token *tk_store(Hashtable tab, Token *t)
{
	assert(tab!=NULL);					/* trap null ptr */
	assert(t!=NULL);					/* trap null ptr */

	if (t->next) 						/* already in use? */
	{
		internal_error("tk_store(): token already in use");
		t = tk_dup(t);					/* quick fix... */
	}

	/* first remove old token (if any) */
	tk_dispose(hsh_remove(tab, t->name));

	return hsh_insert(tab, t);			/* store new token and return ptr */
}



/*
 * tk_locate: return a pointer to a token
 *
 * param:	Hashtable tab - contains the tokens
 *			Token *t - pointer to the token
 *
 * return:	Pointer to the token or NULL if not found.
 */
Token *tk_locate(Hashtable tab, Token *t)
{
	assert(tab!=NULL);					/* trap null ptr */
	assert(t!=NULL);					/* trap null ptr */

	return hsh_lookup(tab, t->name);
}



/*
 * tk_remove:	remove a token from the table and return it to the caller.
 *
 * param:	Hashtable tab - contains the tokens
 *			Token *t - pointer to the token
 *
 * return:	void
 */
Token *tk_remove(Hashtable tab, Token *t)
{
	assert(tab!=NULL);					/* trap null ptr */
	assert(t!=NULL);					/* trap null ptr */

	/* remove token from the table */
	return hsh_remove(tab, t->name);
}



/*
 * tk_table_clear: remove all tokens from a table and release memory
 *
 * param:	Hashtable tab - contains the tokens
 *
 * return:	void
 */
void tk_table_clear(Hashtable tab)
{
	Token	*np,*t;
	int		i;

	assert(tab!=NULL);					/* trap null ptr */
	for (i=0; i<HASHSIZE; i++)
	{
		for (np=tab[i]; np!=NULL; ) {
			t=np; np=np->next; t->next=NULL; tk_dispose(t);
		};
		tab[i]=NULL;
	};
}



/*
 * tk_table_scan: scans through all elements in a hash table and calls the
 *			user-defined function for every element. If that function
 *			returns TRUE, the entry is counted.
 *			scan_table then returns the number of counted (valid) entries.
 *
 * param:	tab	- the table to be counted
 *			BOOL (*examine)(Token *t) - the function to be executed.
 *					(NULL if none)
 *
 * return:	long		- number of elements
 */
long tk_table_scan(Hashtable tab, BOOL (*examine)(const Token *) )
{
	Token	*np;
	int		i;
	long	count=0;

	assert(tab!=NULL);					/* trap null ptr */

	for (i=0; i<HASHSIZE; i++)					/* go through the table */
		for (np=tab[i]; np!=NULL; np=np->next)	/* go through collision list */
		{
			if (examine==NULL) count++;			/* count always */
			else {
				if (examine(np)) count++;		/* count only if TRUE */
			};
		};
	return count;
}




/*==========================================================================*/
/* EOF			 															*/
/*==========================================================================*/
