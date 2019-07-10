/************************************************************************
 *				rmalias.c				*
 *			Do network roomname aliasing			*
 *									*
 * 90Aug27 AA	Renamed from libalias.c					*
 * 88Aug31 orc	alias loader rewritten to avoid library crashes.	*
 * 88Jul15 orc	xstrdup() moved to libdep.c				*
 * 87Oct09 orc	Written.						*
 ************************************************************************/

#include "ctdl.h"

/************************************************************************
 *									*
 *	load_alias()		Load aliases from a file		*
 *	chk_name()		return the alias for a name		*
 *	chk_alias()		return the name for an alias		*
 *									*
 ************************************************************************/

struct alias {
    int  a_sys;
    char *a_name;
    char *a_alias;
    struct alias *a_next;
};

FILE *safeopen();

#define	LISTSIZE	(sizeof(struct alias))

struct alias *
load_alias(where)
char *where;
{
    FILE *f;
    char line[120], *xstrdup(), *strtok();
    char *system, *ourname, *theirname;
    struct alias *base = NULL, *p;

    if (f=safeopen(where, "r")) {
	while (fgets(line,120,f)) {
	    /*
	     * fugly code in case the libraries are braindamaged and can't
	     * deal with empty string input to strtok()
	     */
	    if (system=strtok(line, "\t\n"))
		normalise(system);
	    else
		continue;
	    if (ourname=strtok(NULL, "\t\n"))
		normalise(ourname);
	    else
		continue;
	    if (theirname=strtok(NULL, "\t\n"))
		normalise(theirname);
	    else
		continue;
	    
	    p = (struct alias *) xmalloc(sizeof(struct alias));
	    p->a_name = xstrdup(ourname);
	    p->a_alias= xstrdup(theirname);
	    
	    p->a_sys = netnmidx(system);	/* find netTab index... */
	    if (p->a_sys == ERROR && stricmp(system, "%all") != 0)
		crashout("alias system <%s>", system);

	    p->a_next = base;
	    base = p;
	}
	fclose(f);
	return base;
    }
    return NULL;
}

char *
chk_alias(tab, sys, name)
struct alias *tab;
int sys;
char *name;
{
    struct alias *blind = NULL;
    
    while (tab) {
	if (stricmp(tab->a_name, name) == 0) {
	    if (tab->a_sys == sys)
		return tab->a_alias;
	    else if (tab->a_sys == ERROR)
		blind = tab;
	}
	tab = tab->a_next;
    }
    return blind ? blind->a_alias : name;
}

char *
chk_name(tab, sys, alias)
struct alias *tab;
int sys;
char *alias;
{
    struct alias *blind = NULL;
    
    while (tab) {
	if (stricmp(tab->a_alias, alias) == 0) {
	    if (tab->a_sys == sys)
		return tab->a_name;
	    else if (tab->a_sys == ERROR)
		blind = tab;
	}
	tab = tab->a_next;
    }
    return blind ? blind->a_name : alias;
}
