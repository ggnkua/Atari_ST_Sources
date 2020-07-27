/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:25 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	hash.c,v $
* Revision 1.1  88/08/23  14:20:25  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/hash.c,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * hash.c: functions which maintain a hash table for global symbols and
 *	   common regions
 *
 * In the descriptions below, `flag' should be TRUE for GLOBALS and FALSE
 * for COMMONS.
 *
 * hash_add(symbol,ofile)
 *	If the symbol exists in the hash table, and its type doesn't match
 *	the current type, report an error and set errflag.
 *	Else if the symbol exists and it DOES match, deal with it (either
 *	report an error (GLOBALS) or fold the sizes (COMMONS)).
 *	Else if the symbol doesn't already exist, add it.
 *
 * add_unresolved(symbol,ofile)
 *	Adds the symbol/ofile pair to the (flat) Unresolved list.
 *
 * static add_to_hlist(ptr,symbol,ofile,value,flag)
 *	Common subroutine for adding; ptr is &unresolved or &globals[bucket]
 *	or &commons[bucket].
 *
 * struct HREC *lookup(sym)
 *	Returns a pointer to the HREC containing this symbol in the htable,
 *	or NULL if none.
 */

#include "aln.h"

int dohash(s)
register char *s;
{
    register int i = (s[0]+s[1]+s[2]+s[3]+s[4]+s[5]+s[6]+s[7]) % NBUCKETS;
    return i;
}

hash_add(sym,ofile)
register char *sym;		/* this is a pointer into ofile's symtab */
struct OFILE *ofile;
{
    register struct HREC *hptr;
    register long value = getlong(sym+10);
    register int type = getword(sym+8);
    register int flag = !iscommon(type);
    
    DEBUG3("hash_add(%s,%s,%lx,",make_string(sym), ofile->o_name,value);
    DEBUG2("%x,%s)\n",type,flag ? "GLOBAL" : "COMMON");

    if ((hptr = lookup(sym)) == NULL) {
	return add_to_hlist(&htable[dohash(sym)], sym, ofile, value, type);
    }

    /* already there! */

    if (iscommon(type) && !iscommon(hptr->h_type)) {
	/* mismatch: global came first; warn and keep the global one */
	if (wflag) {
	    printf("Warning: %s: global from ",make_string(sym));
	    put_name(hptr->h_ofile);
	    printf(" used, common from ");
	    put_name(ofile);
	    printf(" discarded.\n");
	}
	putword(sym+8,T_EXTERN);
	putlong(sym+10,0L);
    }
    else if (iscommon(hptr->h_type) && !iscommon(type)) {
	/* mismatch: common came first; warn and keep the global one */
	if (wflag) {
	    printf("Warning: %s: global from ",make_string(sym));
	    put_name(ofile);
	    printf(" used, common from ");
	    put_name(hptr->h_ofile);
	    printf(" discarded.\n");
	}
	hptr->h_type = type;
	hptr->h_ofile = ofile;
	hptr->h_value = value;
    }
    else if (flag) {			/* they're both global */
	/* global exported by another ofile; warn and make this one extern */
	if (wflag) {
	    printf("Duplicate symbol %s: ",make_string(sym));
	    put_name(hptr->h_ofile);
	    printf(" used, ");
	    put_name(ofile);
	    printf(" discarded\n");
	}
	putword(sym+8,T_EXTERN);
    }

    else {			/* they're both common */
	if (hptr->h_value < value) {
	    DEBUG0("New size prevails!\n");
	    hptr->h_value = value;
	    hptr->h_ofile = ofile;
	}
    }
    return FALSE;
}

add_unresolved(sym,ofile)
char *sym;
struct OFILE *ofile;
{
    DEBUG2("add_unresolved(%s,%s)\n",make_string(sym),ofile->o_name);

    return add_to_hlist(&unresolved,sym,ofile,0L,0);
}

struct HREC *lookup(sym)
register char *sym;
{
    register struct HREC *hptr = htable[dohash(sym)];

    while (hptr != NULL) {
	if (symcmp(sym,hptr->h_sym)) {
	    return hptr;
	}
	hptr = hptr->h_next;
    }
    return NULL;
}

add_to_hlist(hptr,sym,ofile,value,type)
struct HREC **hptr;
char *sym;
struct OFILE *ofile;
long value;
int type;
{
    register struct HREC *htemp;

    if ((htemp = Newhrec()) == NULL) {
	printf("Out of memory\n");
	return TRUE;
    }
    symcopy(htemp->h_sym,sym);
    htemp->h_ofile = ofile;
    htemp->h_value = value;
    htemp->h_type = type;

    htemp->h_next = *hptr;
    *hptr = htemp;
    return FALSE;
}

hash_free()
{
    register int i;
    register struct HREC *htemp, *hptr;
    
    for (i=0; i<NBUCKETS; i++) {
	hptr = htable[i];
	while (hptr) {
	    htemp = hptr->h_next;
	    free(hptr);
	    hptr = htemp;
	}
    }
}
