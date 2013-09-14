/* addr.c */
/*  04-Feb-88	ml.	Get addresses of all dialogues. */

#include "obdefs.h"
#include "defs.h"
#include "hdx.h"
#include "addr.h"

getalladdr()
{
    /* Dialogues shared by routines */
    if (rsrc_gaddr(0, MENUBAR, &menuobj) == 0
        || rsrc_gaddr(0, ABOUT, &abtdial) == 0
        || rsrc_gaddr(5, NOWINCAP, &nowincap) == 0
	|| rsrc_gaddr(0, PHYSDEV, &physdial) == 0
	|| rsrc_gaddr(0, LOGDEV, &logdial) == 0)
        return ERROR;

    /* Dialogues for Format */        
    if (rsrc_gaddr(0, FWARNING, &fwarning) == 0
        || rsrc_gaddr(0, DSKNAMES, &dsknames) == 0
        || rsrc_gaddr(0, NOFMT, &nofmt) == 0
	|| rsrc_gaddr(0, FMTFNL, &fmtfnl) == 0
	|| rsrc_gaddr(0, FMTMSG, &fmtmsg) == 0
	|| rsrc_gaddr(0, DMRKMSG, &dmrkmsg) == 0
        || rsrc_gaddr(0, CANTFORM, &cantform) == 0)
	return ERROR;
        
    /* Dialogues for Partition */
    if (rsrc_gaddr(0, PWARNING, &pwarning) == 0
	|| rsrc_gaddr(0, PARTPNL, &ppnl) == 0
	|| rsrc_gaddr(0, PICKPART, &p) == 0
        || rsrc_gaddr(0, NOPART, &nopart) == 0
	|| rsrc_gaddr(0, PARTFNL, &partfnl) == 0
	|| rsrc_gaddr(0, PARTMSG, &partmsg) == 0
	|| rsrc_gaddr(0, PART2BIG, &part2big) == 0
        || rsrc_gaddr(0, CANTPART, &cantpart) == 0)
	return ERROR;

    /* Dialogues for Zero */	
    if (rsrc_gaddr(0, ZWARNING, &zwarning) == 0
	|| rsrc_gaddr(0, ZEROFNL, &zerofnl) == 0
	|| rsrc_gaddr(5, HDRWRITE, &hdrwrite) == 0
	|| rsrc_gaddr(0, ZEROMSG, &zeromsg) == 0)
	return ERROR;
	
    /* Dialogues for Markbad */
    if (rsrc_gaddr(0, MWARNING, &mwarning) == 0
	|| rsrc_gaddr(0, LMRKMSG, &lmrkmsg) == 0
	|| rsrc_gaddr(0, LMRKFILE, &lmrkfile) == 0
	|| rsrc_gaddr(0, LMRKSUB, &lmrksub) == 0
	|| rsrc_gaddr(0, MARKORPH, &markorph) == 0
	|| rsrc_gaddr(5, SVFILES, &svfiles) == 0
	|| rsrc_gaddr(5, NSFILES, &nsfiles) == 0
	|| rsrc_gaddr(0, NODRSLOT, &nodrslot) == 0
	|| rsrc_gaddr(0, LMRKDONE, &lmrkdone) == 0)
	return ERROR;

    /* Dialogues for Ship */
    if (rsrc_gaddr(0, SWARNING, &shipdial) == 0
	|| rsrc_gaddr(0, SHIPDEV, &shipdev) == 0
	|| rsrc_gaddr(0, SHIPFNL, &shipfnl) == 0
	|| rsrc_gaddr(0, SCOMMAND, &scommand) == 0)
	return ERROR;

    /* Error messages */
    if (rsrc_gaddr(5, BSLREAD, &bslread) == 0
        || rsrc_gaddr(5, BSLWRITE, &bslwrite) == 0
        || rsrc_gaddr(5, CRUPTBSL, &cruptbsl) == 0
        || rsrc_gaddr(5, FATREAD, &fatread) == 0
        || rsrc_gaddr(5, FATWRITE, &fatwrite) == 0
        || rsrc_gaddr(5, BADFAT, &badfat) == 0
        || rsrc_gaddr(5, DIRREAD, &dirread) == 0
        || rsrc_gaddr(5, DIRWRITE, &dirwrite) == 0
        || rsrc_gaddr(5, SDIRREAD, &sdirread) == 0
        || rsrc_gaddr(5, SDIRWRIT, &sdirwrit) == 0
        || rsrc_gaddr(5, ROOTREAD, &rootread) == 0
        || rsrc_gaddr(5, ROOTWRIT, &rootwrit) == 0
        || rsrc_gaddr(5, BOOTREAD, &bootread) == 0
        || rsrc_gaddr(5, BOOTWRIT, &bootwrit) == 0)
        return ERROR;
        
    if (rsrc_gaddr(5, NOMEMORY, &nomemory) == 0
	|| rsrc_gaddr(5, RSRVBAD, &rsrvbad) == 0
        || rsrc_gaddr(5, MANYLDEV, &manyldev) == 0
        || rsrc_gaddr(5, AUTOBOOT, &autoboot) == 0
        || rsrc_gaddr(5, CANTDEL, &cantdel) == 0
        || rsrc_gaddr(5, CRUPTFMT, &cruptfmt) == 0)
        return ERROR;
            
    if (rsrc_gaddr(5, MANYBAD, &manybad) == 0
	|| rsrc_gaddr(5, NOMENU, &nomenu) == 0
	|| rsrc_gaddr(5, OLDFMT, &oldfmt) == 0
	|| rsrc_gaddr(5, NEXSMEM, &nexsmem) == 0
	|| rsrc_gaddr(0, WRONPARM, &wronparm) == 0
	|| rsrc_gaddr(5, MDACH, &mdach) == 0
	|| rsrc_gaddr(5, MDMCHNG, &mdmchng) == 0
	|| rsrc_gaddr(5, WRPROTCT, &wrprotct) == 0)
	return ERROR;
	
    return OK;
}
