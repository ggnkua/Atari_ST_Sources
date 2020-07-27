/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 89/04/25 16:07:23 $
* =======================================================================
*
* $Locker: apratt $
* =======================================================================
*
* $Log:	klist.c,v $
* Revision 1.4  89/04/25  16:07:23  apratt
* Dumb dumb .. symcmp returns FALSE if they're DIFFERENT, not SAME
* like strcmp.  Fixed now.  Alas.
* 
* Revision 1.3  88/09/20  20:21:31  apratt
* Fixed busted klist code: would clobber all symbols unless there
* was only one symbol in the k list.
* 
 * Revision 1.2  88/08/24  10:34:47  apratt
 * Kill-list (actually "don't-kill" list) processing, initial rev.
 * 
* =======================================================================
*
* $Revision: 1.4 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/klist.c,v $
* =======================================================================
*
*************************************************************************
*/

/*
 * klist.c: manage the kill-list.
 *
 * The kill-list contains the symbols which are NOT to be clobbered
 * from global to local.  All other globals become locals before going
 * into the output.
 *
 * This probably isn't useful if you still have commons in the output,
 * which will be the case for -p links -- use -q for the same effect
 * as -p plus nailing commons into the BSS.
 *
 * Ignore the following if you aren't involved in building TOS.
 *
 * The intended use is for the operating system, mainly:  the BIOS
 * (including GEMDOS & VDI) is linked with "-u -q -k xdummyx" so it
 * has NO globals, and its commons are nailed into the BSS.  It has
 * two externals: the entry point for the AES, and the end of the
 * OS's memory usage.  The first is provided by AES 
 * (which is linked with "-q -k _gemjst").  The second is provided in
 * another magic way: a dummy .o file with a BSS symbol which is placed
 * last in the command line, so its bss symbol is placed at the end
 * of the BSS (that's why the -q not -p).
 *
 * kinit and kadd return TRUE for error; kinit is a no-op for now.
 * klook returns TRUE if the symbol exists in the kill list, else FALSE.
 *
 */

#include "aln.h"

static struct klist {
    char k_name[SYMLEN];
    struct klist *k_next;
} *kstart;

#define Newkill() (struct klist *)malloc((long)sizeof(struct klist))

kinit()
{
    return FALSE;	    /* no error; also no action */
}

kadd(name)
register char *name;
{
    register int i;
    register struct klist *kitem;
    register char *p;

    if (!(kitem = Newkill())) return TRUE;

    p = &kitem->k_name[0];
    for (i=0; *name && i<SYMLEN; i++) {
	*p++ = *name++;
    }
    while (i<SYMLEN) *p++ = 0, i++;

    kitem->k_next = kstart;
    kstart = kitem;
    return FALSE;
}
   
do_klist(header)
register struct OHEADER *header;
{
    register struct klist *kitem;
    register char *sptr, *send;
    register int type;
    char *sstart;

    sstart = header->ostbase;
    send = header->ostbase + header->ssize;
    
    for (sptr = sstart; sptr < send; sptr += 14) {
	for (kitem = kstart; kitem; kitem = kitem->k_next) {
	    if (symcmp(kitem->k_name,sptr)) {
	    	/* same - bail out w/o clobbering this one */
		goto noclobber;
	    }
	}
	/* fell out: must not be on the list */
	type = getword(sptr+8) & ~T_GLOBAL;
	putword(sptr+8,type);
noclobber: ;
    }
    return FALSE;
}
