/*
 * from K&R "The C Prograamming language"
 * Table lookup routines
 *
 */
#define INLOOK 1

#include <stdio.h>
#include "lookup.h"

extern struct
lexlist	(*(*lextable))[];/* global pointer for lexical analyser hash table */

/*
 * hash - for a hash value for string s
 *
 */
int hash(s)
char *s;
{
	int	hashval;

	for (hashval = 0; *s != '\0';)
		hashval += *s++;
	return (hashval % HASHMAX);
}

/*
 * lookup - lookup for a string s in the hash table
 *
 */
struct hashlist
*lookup(s, hashtab)
char *s;
struct hashlist *hashtab[];
{
	struct hashlist *np;

	for (np = hashtab[hash(s)]; np != NULL; np = np->next)
		if (strcmp(s, np->name) == 0)
			return(np);	/* found     */
	return(NULL);		/* not found */
}

/*
 * install - install a string name in hashtable and its value def
 * at a given hashtable.
 */
struct hashlist
*install(name,def,hashtab)
char *name;
char *def;
struct hashlist *hashtab[];
{
	int hashval;
	struct hashlist *np, *lookup();
	char *strsave(), *malloc();

	if ((np = lookup(name, hashtab)) == NULL) {	/* not found.. */
		np = (struct hashlist *) malloc(sizeof(*np));
				if (np == NULL)
			return(NULL);
		if ((np->name = strsave(name)) == NULL)
			return(NULL);
		hashval = hash(np->name);
		np->next = hashtab[hashval];
		hashtab[hashval] = np;
	} else					/* found..     */
		free(np->def);			/* free prev.  */
	if ((np->def = strsave(def)) == NULL)
		return(NULL);
	return(np);
}

/*
 * strsave - save string s somewhere
 *
 */
char
*strsave(s)
char *s;
{
	char *p, *malloc();
	register int n;

	n = strlen(s) + 1;
	if ((p = malloc(n)) != NULL)
			strcpy(p, s);
	return(p);
}

/*
 * lexinstal - instal a string name in hashtable and its value
 *	       used by lexical analyser to quickly match a token
 *	       and return its lexical value.
 *
 */
struct lexlist
*lexinstal(name,val,flag,lextable)
char *name;
int val;
int flag;
struct lexlist *lextable[];
{
	int hashval;
	struct lexlist *np,*lexlook();
	char *strsave(), *malloc();

	if ((np = lexlook(name,lextable)) == NULL) {	/* not found.. */
		np = (struct lexlist *) malloc(sizeof(*np));
		if (np == NULL)
			return(NULL);
		if ((np->name = strsave(name)) == NULL)
			return(NULL);
		hashval = hash(np->name);
		np->link = lextable[hashval];
		lextable[hashval] = np;
	}
	np->val = val;				/* replace prev */
	np->flag = flag;
	return(np);
}

/*
 * lexlook - lookup for a string s in the hash table
 *	     used by lexinstal only.
 *
 */
struct lexlist
*lexlook(s,table)
char *s;
struct lexlist *table[];
{
	struct lexlist *np;

	for (np = table[hash(s)]; np != NULL; np = np->link)
		if (strcmp(s, np->name) == 0)
			return(np);	/* found     */
	return(NULL);		/* not found */
}

/*
 * remove an item from the hash table forever
 *
 */
struct lexlist
*remove(s, table)
char *s;
struct lexlist *table[];
{
	struct lexlist *np, *xp;

	np = table[hash(s)];
	xp = np;
	while (np != NULL) {
		if (strcmp(s, np->name) == 0) {
			xp->link = np->link;	/* remoe the link */
			return(np);		/* return the lost */
		}
		xp = np;
		np = np->link;
	}
	return(NULL);
}

