/* addr.c */
/*  04-Feb-88	ml.	Get addresses of all dialogues. */

#include <obdefs.h>
#include "fhdx.h"
#include "define.h"

OBJECT *menuobj;	/* -> menu tree */

/* Dialogue for About in menu */
OBJECT *abtdial;	/* -> about dialogue tree */

/* Box for current unit and disk type */
OBJECT *unittype;	/* display */

/* Dialogues for Controller Test */
OBJECT *ctrlpass;	/* test is passed */
OBJECT *ctrlfail;	/* test is failed */

/* Dialogues for Daisy Chain Test */
OBJECT *dchpass;	/* test is passed */
char   *nodcent;	/* missing 'dc' entry in wincap */
OBJECT *dchwfail;	/* test failed with write error */
OBJECT *dchrfail;	/* test failed with read error */
OBJECT *dchdfail;	/* test failed with data error */

/* Dialogues and Alerts for Format + Partition */
OBJECT *physdial;
OBJECT *dsknames;
OBJECT *fmtmsg;
OBJECT *nofmt;
OBJECT *nopart;
char *cantform;
char *cantpart;
char *cruptfmt;
char *notfmtd;

/* Dialogues and Alerts for Burn-in */
OBJECT *brninmsg;
OBJECT *bslform;
OBJECT *dskpass;
OBJECT *dskfail;

/* Dialogues and Alerts for Inputting Defect List */
OBJECT *npdeflst;
OBJECT *nputform;
OBJECT *askxam;
OBJECT *xamform;
OBJECT *edtform;
OBJECT *keepdefs;
char *cylis0;
char *cyl0bad;
char *npcmpent;
char *bghdnum;
char *bgcylnum;
char *bgbytnum;
char *deffull;
char *defemp;

/* Alert for Ship */
char *scommand;


/* Error messages */
OBJECT *errnum;
OBJECT *part2big;
OBJECT *partmsg;
char *autoboot;
char *bootread;
char *bslread;
char *bslwrite;
char *cruptbsl;
char *cyl0bad;
char *cylis0;
char *dskwrite;
char *fatread;
char *fatwrite;
char *manybad;
char *manyldev;
char *midrez;
char *nowincap;
char *nomemory;
char *rootbad;
char *rootread;
char *rootwrit;


getalladdr()
{
    if (rsrc_gaddr(0, MENUBAR, &menuobj) == 0
        || rsrc_gaddr(0, ABOUT, &abtdial) == 0
        || rsrc_gaddr(0, UNITTYPE, &unittype) == 0)
        
        return ERROR;

    if (rsrc_gaddr(0, CTRLPASS, &ctrlpass) == 0
        || rsrc_gaddr(0, CTRLFAIL, &ctrlfail) == 0)
        
        return ERROR;
        
    if (rsrc_gaddr(0, DCHPASS, &dchpass) == 0
        || rsrc_gaddr(5, NODCENT, &nodcent) == 0
        || rsrc_gaddr(0, DCHWFAIL, &dchwfail) == 0
        || rsrc_gaddr(0, DCHRFAIL, &dchrfail) == 0
        || rsrc_gaddr(0, DCHDFAIL, &dchdfail) == 0)
        
        return ERROR;
        
    if (rsrc_gaddr(0, DSKNAMES, &dsknames) == 0
        || rsrc_gaddr(0, PHYSDIAL, &physdial) == 0
        || rsrc_gaddr(0, FMTMSG, &fmtmsg) == 0
        || rsrc_gaddr(0, NOFMT, &nofmt) == 0
        || rsrc_gaddr(0, NOPART, &nopart) == 0
        || rsrc_gaddr(5, CANTFORM, &cantform) == 0
        || rsrc_gaddr(5, CANTPART, &cantpart) == 0
        || rsrc_gaddr(5, NOTFMTD, &notfmtd) == 0
        || rsrc_gaddr(5, CRUPTFMT, &cruptfmt) == 0)
        
        return ERROR;
        
    if (rsrc_gaddr(0, BRNINMSG, &brninmsg) == 0
        || rsrc_gaddr(0, BSLFORM, &bslform) == 0
        || rsrc_gaddr(0, DSKPASS, &dskpass) == 0
        || rsrc_gaddr(0, DSKFAIL, &dskfail) == 0)
        
        return ERROR;
	
    if (rsrc_gaddr(0, NPDEFLST, &npdeflst) == 0
        || rsrc_gaddr(0, NPUTFORM, &nputform) == 0
	|| rsrc_gaddr(0, ASKXAM, &askxam) == 0
        || rsrc_gaddr(0, XAMFORM, &xamform) == 0
        || rsrc_gaddr(0, EDTFORM, &edtform) == 0
        || rsrc_gaddr(0, KEEPDEFS, &keepdefs) == 0
	|| rsrc_gaddr(5, CYLIS0, &cylis0) == 0
	|| rsrc_gaddr(5, CYL0BAD, &cyl0bad) == 0
	|| rsrc_gaddr(5, NPCMPENT, &npcmpent) == 0
        || rsrc_gaddr(5, BGHDNUM, &bghdnum) == 0
        || rsrc_gaddr(5, BGCYLNUM, &bgcylnum) == 0
        || rsrc_gaddr(5, BGBYTNUM, &bgbytnum) == 0
        || rsrc_gaddr(5, DEFFULL, &deffull) == 0
        || rsrc_gaddr(5, DEFEMP, &defemp) == 0)
        
        return ERROR;

    if (rsrc_gaddr(5, SCOMMAND, &scommand) == 0)
        return ERROR;
        
    if (rsrc_gaddr(0, ERRNUM, &errnum) == 0
    	|| rsrc_gaddr(0, PART2BIG, &part2big) == 0
        || rsrc_gaddr(0, PARTMSG, &partmsg) == 0
        || rsrc_gaddr(5, NOWINCAP, &nowincap) == 0
        || rsrc_gaddr(5, NOMEMORY, &nomemory) == 0
        || rsrc_gaddr(5, FATREAD, &fatread) == 0
        || rsrc_gaddr(5, FATWRITE, &fatwrite) == 0
        || rsrc_gaddr(5, ROOTBAD, &rootbad) == 0
        || rsrc_gaddr(5, BOOTREAD, &bootread) == 0
        || rsrc_gaddr(5, ROOTREAD, &rootread) == 0
        || rsrc_gaddr(5, ROOTWRIT, &rootwrit) == 0)
        
        return ERROR;
        
    if (rsrc_gaddr(5, CYL0BAD, &cyl0bad) == 0
        || rsrc_gaddr(5, BSLREAD, &bslread) == 0
        || rsrc_gaddr(5, BSLWRITE, &bslwrite) == 0
        || rsrc_gaddr(5, CRUPTBSL, &cruptbsl) == 0
        || rsrc_gaddr(5, MANYLDEV, &manyldev) == 0
        || rsrc_gaddr(5, AUTOBOOT, &autoboot) == 0
        || rsrc_gaddr(5, MANYBAD, &manybad) == 0
        || rsrc_gaddr(5, DSKWRITE, &dskwrite) == 0
        || rsrc_gaddr(5, MIDREZ, &midrez) == 0)
        
        return ERROR;
            
    return OK;
}
