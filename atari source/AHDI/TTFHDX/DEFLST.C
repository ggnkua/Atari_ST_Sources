/*  deflst.c */

/*  21-Jan-88	ml	Started this.	*/

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include "fhdx.h"
#include "define.h"
#include "part.h"
#include "bsl.h"
#include "deflst.h"
#include "addr.h"


/* Externs from fhdx.c */
extern SECTOR *badbuf;
extern int maxbadsects;
extern int wdesk, hdesk;
extern int rebootp;

/* Globals for this file */
int npndefs;		/* number of defects entered */
PADDR *nppaddr;		/* inputted defect list */

/*
 *  Figure out disk format and tester used.
 *	Return:
 *		NPUTSTRT - ready to start the inputing.
 *		NPUTCN - user bail out.
 */
figtst()
{
    int done=0, selfmt=0, seltst=0;
    
    while (!done) {
    	done = TRUE;
    	npdeflst[TSTRMFM].ob_state = NORMAL;
    	npdeflst[TSTRRLL].ob_state = NORMAL;
        npdeflst[NPUTSTRT].ob_state = NORMAL;
        npdeflst[NPUTCN].ob_state = NORMAL;
        if (execform(npdeflst, 0) != NPUTSTRT)
            return NPUTCN;
    
        if (npdeflst[TSTRMFM].ob_state & SELECTED) {
            tst = MFM;
            seltst = 1;
        } else if (npdeflst[TSTRRLL].ob_state & SELECTED) {
            tst = RLL;
            seltst = 1;
        }
        
        if (!seltst) {		/* haven't selected either */
            done = 0;			/* Prompt them again */
        }
    }
    return NPUTSTRT;
}



/*
 * Input defects.
 */
nputdeflst()
{
    int stat;		/* status return from user */    
    int done = 0;
    int stent;		/* starting entry to display */
    int ret;

    /* Allocate memory to hold defects */
    if ((nppaddr = mymalloc(maxbadsects*(sizeof(PADDR)))) <= 0) {
        err(nomemory);
        return NOMEM;
    }
    
    npndefs = 0;		/* no defects entered yet */
        
    /* Put up box for input */
    nputform[NPUTDONE].ob_state = NORMAL;
    nputform[NPUTNXT].ob_state = NORMAL;
    strcpy((nputform[NPHDNUM].ob_spec)->te_ptext, "@");
    strcpy((nputform[NPCYLNUM].ob_spec)->te_ptext, "@234");
    strcpy((nputform[NPBYTOFF].ob_spec)->te_ptext, "@2345");
    graf_mouse(ARROW, 0L);
    dsplymsg(nputform);
    stent = NPHDNUM;
    while (!done) {
    	nputform[NPUTDONE].ob_state = NORMAL;	/* reset DONE button */
	nputform[NPUTNXT].ob_state = NORMAL;	/* reset NEXT button */
	objc_draw(nputform, NPUTDONE, MAX_DEPTH, 0, 0, wdesk, hdesk);
	objc_draw(nputform, NPUTNXT, MAX_DEPTH, 0, 0, wdesk, hdesk);
        stat = form_do(nputform, stent);	/* hand over to user */
        
        /* Check validity of input and perform appropiate action */
        switch (chknput(nputform, NPHDNUM, NPCYLNUM, NPBYTOFF)) {
        	
            case OK:
                if (npndefs == maxbadsects) {
                    err(deffull);
                    done = TRUE;
                    break;
                }
                gpaddr(&nppaddr[npndefs], nputform, NPHDNUM, NPCYLNUM,
                		NPBYTOFF);
                npndefs++;
		if (stat == NPUTDONE) {	/* no more input */
            	    done = TRUE;	/* Exit */
        	} else {
		    clrnput(nputform, NPHDNUM, NPCYLNUM, NPBYTOFF, NPUTBOX);
		    stent = NPHDNUM;
		}
                break;
                
            case INCMPL:
                form_alert(1, npcmpent);
                stent = NPHDNUM;
                break;
                
            case EMPTY:
		if (stat == NPUTDONE) {	/* no more input */
            	    done = TRUE;		/* Exit */
        	} else 
		    stent = NPHDNUM;
            	break;
            
            case HD2BIG:
                form_alert(1, bghdnum);
                clrnput(nputform, NPHDNUM, -1, -1, NPUTBOX);
                stent = NPHDNUM;
                break;

	    case CYLNUM0:
	        if (form_alert(1, cylis0) != 1) {
		    clrnput(nputform, -1, NPCYLNUM, -1, NPUTBOX);
		    stent = NPCYLNUM;
        	} else {
        	    ret = err(cyl0bad);
        	    goto nputend;
        	}
                break;
                
            case CYL2BIG:
                form_alert(1, bgcylnum);
                clrnput(nputform, -1, NPCYLNUM, -1, NPUTBOX);
                stent = NPCYLNUM;
                break;

            case BYT2BIG:
                form_alert(1, bgbytnum);
                clrnput(nputform, -1, -1, NPBYTOFF, NPUTBOX);
                stent = NPBYTOFF;
                break;
                
            default:
                break;
        }
    }
    ret = OK;
nputend:
    erasemsg();
    return (ret);
}



/* 
 *  Get validated physical block address.
 */
gpaddr(paddr, entry, hdnum, cylnum, btoffst)
PADDR *paddr;
OBJECT entry[];
int hdnum, cylnum, btoffst;
{
    paddr->exist = TRUE;
    paddr->head = atoi(entry[hdnum].ob_spec->te_ptext);
    paddr->cylndr = atoi(entry[cylnum].ob_spec->te_ptext);
    paddr->btoffst = atoi(entry[btoffst].ob_spec->te_ptext);
}


/*
 * Clear value(s) current entry only if index is passed in.
 *	positive ?num - index
 *	negative ?num - don't clear it
 */
clrnput(entry, hdnum, cylnum, btoffst, boxnum)
OBJECT entry[];
int hdnum, cylnum, btoffst, boxnum;
{
    char **tptr;
    
    if (hdnum >= 0) {
    	tptr = entry[hdnum].ob_spec;
	**tptr = '@';
    }
    if (cylnum >= 0) {
    	tptr = entry[cylnum].ob_spec;
	**tptr = '@';
    }
    if (btoffst >= 0) {
    	tptr = entry[btoffst].ob_spec;
	**tptr = '@';
    }
    objc_draw(entry, boxnum, MAX_DEPTH, 0, 0, wdesk, hdesk);
}

    
/*
 *  Check if current entry have valid values and whether
 *  it is a complete entry.
 *	Return OK or the appropiate error defined in deflst.h
 */
chknput(entry, hdnum, cylnum, btoffst)
OBJECT entry[];
int hdnum, cylnum, btoffst;
{
   int numnput=0;	/* number of input found so far */
   char **tptr;
   int num;		/* the inputted number */

   /* Check head number */
   tptr = entry[hdnum].ob_spec;
   if (**tptr >= '0' && **tptr <= '9') {
   	numnput++;
   	if (atoi(*tptr) >= maxpaddr.head)
   	    return HD2BIG;
   }
   
   /* Check cylinder number */   
   tptr = entry[cylnum].ob_spec;
   if (**tptr >= '0' && **tptr <= '9') {
   	numnput++;
   	if (!(num = atoi(*tptr)))
   	    return CYLNUM0;
   	if (num >= maxpaddr.cylndr)
   	    return CYL2BIG;
   }
   
   /* Check byte offset */   
   tptr = entry[btoffst].ob_spec;
   if (**tptr >= '0' && **tptr <= '9') {
   	numnput++;
   	if (atoi(*tptr) >= maxpaddr.btoffst)
   	    return BYT2BIG;
   }
   
   if (numnput == 0)
       return EMPTY;
       
   if (numnput < 3)
       return INCMPL;
       
   return OK;
}



/*
 *  Calculate corresponding sector numbers for defects input.
 *	Input:
 *		hinfo - hard disk info. (e.g. #heads, #cylinders, etc..)
 *		pbps - number of bytes per sector physically.
 *			(i.e. including index)
 *	Return:
 *		nbad - number of bad sectors to be added to BSL.
 *		ERROR - if anything is wrong.
 *	Comments:
 *		New calculated sector number is searched for in
 *	badbuf before adding onto it.  This ensures that no duplicates
 *	of a sector would appear in the BSL.
 */
calcsect(hinfo, pbps)
HINFO *hinfo;
int pbps;
{
    int i;		/* index into defect list */
    int ldb;		/* byte number of the last data byte on a track */
    int offset;		/* byte offset from index */
    int rndup;		/* byte offset rndup */
    int spt;		/* sectors per track */
    int spc;		/* sectors per cylinder */
    SECTOR sectnum;	/* sector number on track */
    int j;		/* index into buffer of bad sector numbers */
    int nbad;		/* num bad sectors so far */
    
    spt = hinfo->hi_spt;
    spc = spt * hinfo->hi_dhc;
    ldb = NDXPULS + ((unsigned int)hinfo->hi_spt * pbps) - 1;
    
    nbad = 0;
    for (i = 0; i < npndefs; i++) {
	offset = nppaddr[i].btoffst;
	
    	if (fmt != tst) {
    	    rndup = 0;
    	    if (offset % 2)
    	        rndup = 1;
    	    if (fmt == RLL && tst == MFM) {
    	        offset *= 3;
    	        offset >>= 1;
    	    } else if (fmt == MFM && tst == RLL) {
    	    	offset <<= 1;
    	    	offset /= 3;
    	    }
	    offset += rndup;
	}
    	
    	if (offset < NDXPULS)
    	    offset = NDXPULS;		/* bump up to 1st data sector */
    	else if (offset > ldb)
    	    offset = ldb;		/* bump back to last data sector */
    	    
    	sectnum = (offset - NDXPULS) / pbps;
    	sectnum += (long)(spc * nppaddr[i].cylndr)
    			+ (long)(spt * nppaddr[i].head);
    	
    	for (j = 0; j < nbad; j++)
       	    if (sectnum == *(badbuf+j))
    	        break;

    	if (j == nbad) {
    	    *(badbuf+nbad) = sectnum;
    	    nbad++;
    	}
    }
    free(nppaddr);
    return nbad;
}
