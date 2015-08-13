#include <stdio.h>
#include "as.h"
#include "table.h"
#include "lookup.h"

extern int Pass;
extern int Debug;

#define HASHSIZE 203                            /* width of hash table */
static struct nlist *hashtab[HASHSIZE] = {0};   /* symbol table */

/*
 *      hash --- form hash value for string s
 */
hash(s)
register char *s;
{
	register int hashval = 0;

	while(*s)
		hashval += *s++;
	return(hashval % HASHSIZE );
}

/*
 *      install --- add a symbol to the table
 */
install(str,val,type)
char    *str;
int     val;
char    type;
{
	register struct nlist *np;
	int     i;
	char *malloc();
	extern char *tnames[];

	if( !alpha(*str) ){
		serror("Illegal Symbol Name: %s",str);
		return;
		}
	if( (np = lookup(str)) != NULL ){
		if( Pass==2 ){
			if( np->sym_def == val && np->sym_type == type )
				return;
			else{
				error("Phasing Error");
				return;
				}
			}
		if( np->sym_type != SYM )
			serror("Reserved Symbol Name: %s",str);
		else
			serror("Symbol Redefined: %s",str);
		return;
		}

if(Debug&LOOKUP)printf("Install: %s=0x%x(%s)\n",str,val,tnames[type]);

	/* enter new symbol */
	np = (struct nlist *) malloc(sizeof(struct nlist));
	if( np == (struct nlist *)ERR ){
		error("Symbol table full");
		return;
		}
	np->sym_name = malloc(strlen(str)+1);
	if( np->sym_name == (char *)ERR ){
		error("Symbol table full");
		return;
		}
	strcpy(np->sym_name,str);
	np->sym_def  = val;
	np->sym_type = type;
	i = hash(np->sym_name);
	np->sym_next = hashtab[i];
	hashtab[i] = np;
	return;
}

/*
 *      lookup --- find string in symbol table
 */
struct nlist *
lookup(name)
register char *name;
{
	register struct nlist *np;

	for( np = hashtab[hash(name)] ; np != NULL ; np = np->sym_next)
		if( strcmp(name,np->sym_name)==0 )
			return(np);
	if(Pass==2)
		serror("Undefined: %s",name);
	return(NULL);
}

/*
 *      mne_look --- mnemonic lookup
 *
 *      Return pointer to an mne structure if found.
 */
struct mne *
mne_look(str)
char    *str;
{
	register struct mne *low,*high,*mid;
	int     cond;
	extern struct mne mnemonic[];
	extern int Nmne;

	low =  &mnemonic[0];
	high = &mnemonic[ Nmne-1 ]; /* last entry in table is always empty */
	while (low <= high){
		mid = low + (high-low)/2;
		if( ( cond = strcmp(str,mid->mne_name)) < 0)
			high = mid - 1;
		else if (cond > 0)
			low = mid + 1;
		else
			return(mid);
	}
	return(NULL);
}

/*
 *      dump_syms --- print statistics about symbol table usage
 */
dump_syms()
{
	register int i;
	register int total;
	register int gtotal = 0;
	register struct nlist *s;
	int     minlist = 9999999;
	int     maxlist = 0;


	printf("Symbol table distribution\n");
	for(i=0;i<HASHSIZE;i++){
		total = 0;
		for(s = hashtab[i]; s != NULL; s=s->sym_next)
			total++;
		printf("%d ",total);
		if( total > maxlist )
			maxlist = total;
		if( total < minlist )
			minlist = total;
		gtotal += total;
		if( (i%20) == 19 )
			printf("\n");
		}
	printf("\nTotal symbols: %d\n",gtotal);
	printf("Minimum list length: %d\n",minlist);
	printf("Maximum list length: %d\n",maxlist);
}
