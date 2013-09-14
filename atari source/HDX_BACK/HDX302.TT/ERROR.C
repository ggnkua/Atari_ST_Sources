/*
 *	ERROR.C
 *
 *	26-May-1988	ml.	Started this.
 *  14-Mar-1989 jye. add codes so that can differ what kind 
 *					 driver currently deal with.
 *
 */

#include "osbind.h"
#include "obdefs.h" 
#include "defs.h"
#include "addr.h"
#include "error.h"

extern char typedev;

/*
 *  Errcode()
 *	Find error code for previous instruction which returned Check
 *  Condition Status.
 *
 *  Input:
 *	pdev - the physical device number (0 -> 7).
 *  Return:
 *	errnum - the error code.
 */
errcode(pdev)
int pdev;
{
    char data[128];
    extern long rq_sense(), ostack;
    extern long rq_xsense();
    UWORD errnum;
	char mask = 0x01;
	char set;
   
    ostack = Super(NULL);
	/* check #pdev device is set or not */
	set = typedev & (mask << pdev);
	if (set) {	/* if set, it is a removable driver */
		errnum = rq_xsense(pdev, data);
	} else {	/* if not set, it is a not removable driver */
   		errnum = rq_sense(pdev, data);
	}
    delay();
    Super(ostack);
    
    if (errnum != 0)
        return err("[1][Fatal error][OK]");
        
	if (set)	{ /* if set, it is a removable driver */
    	errnum = (UWORD)data[12];
	} else { /* if not set, it is a not removable driver */
    	data[0] &= 0x7f;		/* mask out advalid bit */
    	errnum = (UWORD)data[0];
	}
    return errnum;		/* return it */
}


/*
 *  Tsterr()
 *	Given an error code, test if it is a medium change error
 *  or a write protection error.  Put up the appropiate box if
 *  it is either one of those, and return OK.  
 *	If it is not either of those, return ERROR.
 *
 */
tsterr(errnum)
UWORD errnum;
{
    switch(errnum) {
    	case MDMCHGD:
    	    err(mdmchng);
    	    break;
    	
    	case WRTPRTD:
    	    err(wrprotct);
    	    break;
    	    
    	case DEVNRDY:
    	    err(drvnrdy);
    	    break;
    	    
    	default:
    	    return ERROR;
    }
    return OK;
}
