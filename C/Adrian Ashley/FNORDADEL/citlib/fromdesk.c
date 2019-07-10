#include <stdio.h>
#include <basepage.h>

/*
 *  89Nov26 12:29 am GMT from jmw@tasis.utas.oz.au@munnari.oz.uucp
 * A recent article suggested three possible methods by which a process could 
 * determine whether it was being run from the desktop or from a shell. I'd
 * like to suggest another method which works for me. I don't suggest that it
 * is foolproof however. It simply requires moving the basepage ptr up to its 
 * parent until it becomes null. If this requires three iterations then the
 * program is running from the desktop. Any more and it is running from a
 * shell. 
 *
 * The following piece of code works with MWC: 
 *
 *   ...
 *
 * John M Williams 
 * ACSnet: jmw@tasis.utas.oz	ARPA: 	jmw%tasis.utas.oz@uunet.uu.net 
 * UUCP: 	{enea,hplabs,mcvax,uunet,ukc}!munnari!tasis.utas.oz!jmw 
 */

int
fromdesk(void) 
{ 
    BASEPAGE *bp;
    int i = 0;

#ifdef MWC
    bp = (BASEPAGE **) BP->p_parent;
#else
    bp = (BASEPAGE *) _base->p_parent;		/* gcc version (we hope) */
#endif
    while (bp != 0) { 
	i++;
#ifdef MWC
	bp = (BASEPAGE **) bp->p_parent;
#else
	bp = (BASEPAGE *) bp->p_parent;
#endif
    } 
    return (i == 3);
}

void
hitkey(void)
{
    printf("\nHit any key to continue");
    fflush(stdout);
    (void)getchar();
    putchar('\n');
}
