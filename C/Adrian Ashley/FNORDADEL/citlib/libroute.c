/* #define megadebug */

/*
 * libroute.c -- routines to do intelligent routing
 *
 * 90Nov01 AA	Slightly updated from 3.4a sources (one clause in changeto())
 * 88Jul13 orc	Created.
 */

#include "ctdl.h"
#include "net.h"
#include "config.h"
#include "msg.h"
#include "citlib.h"

/*
 * * netlook()	Look up a nodename in ctdlnet.sys
 * * ckpath()	Check out a route from ctdlpath.sys
 * * ckalias()	Look up a nodename in ctdlpath.sys
 * * cknode()	Check out a node/domain thing
 * parsepath()	Tell caller whether it's a net address
 * findnode()	Figure access & directions to a node
 * changeto()	Modify to: address
 */

NETADDR route;	/* if path aliased, use this route */
char howto;	/* how the node was found */

/*
 * netlook() -- look up a nodename in ctdlnet.sys
 *
 * Unless you tell it to, it will not find the net
 * addresses of systems that are not on a net.
 */
static int
netlook(node, everything)
char *node;
int everything;
{
    int x;

#ifdef megadebug
    xprintf("\n DEBUG: call netlook(%s,%d)\n", node, everything);
#endif
    if ((x = netnmidx(node)) != ERROR && (everything || netBuf.what_net))
	return x;
    return ERROR;
}


/*
 * ckpath() -- see if the leading node of `route' is okay
 */
static int
ckpath(cost)
int *cost;
{
    LABEL node;
    char *p;
    int x;

#ifdef megadebug
    xprintf(" DEBUG: call ckpath(%s)\n", route);
#endif

    if (p=strchr(route, '!'))		/* only do bang-path aliasing */
	*p++ = 0;

    copystring(node, route, NAMESIZE);
    normalise(node);

    if ((x=netlook(node, NO)) != ERROR) {
#ifdef megadebug
	xprintf(" DEBUG: <%s> normally accessable\n", node);
#endif
	if (p)
	    strcpy(route, p);
    }
    else if (cfg.hub && (x = netlook(&cfg.codeBuf[cfg.hub], YES)) != ERROR)
	*cost += cfg.hubcost;

    *cost += netBuf.ld ? cfg.ld_cost : 0;
    return x;
}


/*
 * ckalias() -- look up a name in ctdlpath.sys
 */
static int
ckalias(node, cost, idx)
char *node;
int *cost;
int *idx;
{
    PATHBUF temp;
    LABEL name;
    FILE *pa, *safeopen();

#ifdef megadebug
    xprintf(" DEBUG: call ckalias(%s)\n", node);
#endif
    *idx = ERROR;
    ctdlfile(temp, cfg.netdir, "ctdlpath.sys");
    if ((cfg.flags.PATHALIAS) && (pa=safeopen(temp,"r"))) {
	while (fgets(temp, 100, pa)) {
	    route[0] = *cost = 0;
	    sscanf(temp, "%s %s %d", name, route, cost);
#ifdef megadebug
	    xprintf(" DEBUG: %s\t%s\t%d\n", name, route, *cost);
#endif
	    if (labelcmp(name, node) == 0) {
		fclose(pa);
		howto = iALIAS;
		return (route[0] && (*idx=ckpath(cost)) == ERROR) ? NO : YES;
	    }
	}
	fclose(pa);
    }
    return NO;
}

/*
 * findnode() -- get access & cost for a node
 */
findnode(node, cost)
char *node;
int  *cost;
{
    int x;
    char *p, *strrchr();

#ifdef megadebug
    xprintf(" DEBUG: call findnode(%s)\n", node);
#endif
    normalise(node);
restart:
    if (p=strrchr(node, '.'))
	if (ckalias(p, cost, &x))
	    if (x == ERROR) {
#ifdef megadebug
		xprintf(" DEBUG: self-domain <%s>\n", p);
#endif
		*p = 0;
		goto restart;
	    }
	    else {			/* pass off to another domain */
#ifdef megadebug
		xprintf(" DEBUG: domain <%s>\n", p);
#endif
		howto = iDOMAIN;
		return x;
	    }

    if (NNisok(node)) {
	route[0] = 0;
	if ((x=netlook(node, NO)) != ERROR) {
	    *cost = netBuf.ld ? cfg.ld_cost : 0;
	    howto = iDIRECT;
	    return x;
	}
	if (ckalias(node, cost, &x))
	    return x;
	if (cfg.hub) {
	    strcpy(route, node);
	    x = netlook(&cfg.codeBuf[cfg.hub], YES);
	    *cost = cfg.hubcost;
	    howto = iHUBBED;
	    return x;
	}
    }
    return ERROR;

}

/*
 * cknode() -- cut apart a domain address and find out if it's us.
 */
static int
cknode(node)
char *node;
{
    char *p, *strrchr();
    FILE *safeopen();
    int cost, x;

#ifdef megadebug
    xprintf(" DEBUG: call cknode(%s)\n", node);
#endif
    while (p=strrchr(node, '.')) {
#ifdef megadebug
	xprintf(" DEBUG: pick domain=<%s>\n", p);
#endif
	if (!labelcmp(p, ".citadel") || (ckalias(p, &cost, &x) && x == ERROR))
	    *p = 0;
	else
	    return NO;
    }
    /*
     * if it can't be resolved as a domain, treat it like a vanilla
     * address
     */
#ifdef megadebug
    xprintf(" DEBUG: node=%s, self=%s\n", node, &cfg.codeBuf[cfg.nodeName]);
#endif
    return labelcmp(node, &cfg.codeBuf[cfg.nodeName]) == 0;
}

/*
 * parsepath() -- take and parse a possible netpath.
 *
 * Return YES if it's a netpath & put first node into `node'.
 * If `edit' is true, cut the offending node off `netpath'.
 */
int
parsepath(netpath, node, edit)
char *netpath;
char *node;
int edit;
{
    NETADDR temp;
    char *p;
    char self;

    if (netpath == NULL || node == NULL)	/* be paranoid... */
	return NO;

restart:					/* ACK!! A goto! */

    if (p=strrchr(netpath,'@')) {		/* check name@system first */
	copystring(node, 1+p, NAMESIZE);
	normalise(node);
	if ((self = cknode(node)) || edit)
	    *p = 0;
	if (self)
	    goto restart;
	return YES;
    }
    strcpy(temp, netpath);
    if (p=strchr(temp,'!')) {			/* then bangpaths */
	*p++ = 0;
	copystring(node, temp, NAMESIZE);	/* pull out the node */
	normalise(node);
	if ((self = cknode(node)) || edit)
	    strcpy(netpath, p);
	if (self)
	    goto restart;
	return YES;
    }
    return NO;
}


/*
 * changeto() -- modify msgBuf.mbto for proper routing
 */
void
changeto(oldto, firstnode)
char *oldto;
char *firstnode;
{
    extern char howto;
    extern char route[];

#if 1	/* This is the new code from 3.4a */

    switch (howto) {
    case iALIAS:
	sprintf(msgBuf.mbto, route, firstnode);
	sprintf(ENDOFSTR(msgBuf.mbto), "!%s", oldto);
	break;
    case iHUBBED:
	sprintf(msgBuf.mbto, "%s!%s", firstnode, oldto);
	break;
    case iDOMAIN:
	sprintf(msgBuf.mbto, "%s@%s", oldto, firstnode);
	break;
    default:
	strcpy(msgBuf.mbto, oldto);
    }

#else	/* and this is the old code from 3.3b */

    if (howto == iALIAS) {
	sprintf(msgBuf.mbto, route, firstnode);
	sprintf(ENDOFSTR(msgBuf.mbto), "!%s", oldto);
    }
    else if (howto == iHUBBED)
	sprintf(msgBuf.mbto, "%s!%s", firstnode, oldto);
    else
	strcpy(msgBuf.mbto, oldto);

#endif

#ifdef megadebug
    xprintf(" DEBUG: msgBuf.mbto=%s\n", msgBuf.mbto);
#endif
}
