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
#include "mydefs.h"
#include "addr.h"
#include "error.h"

extern int typedev;
extern int typedrv;

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
    extern long rqsense(), ostack;
    UWORD errnum;
	int mask = 0x0001;
	int set, scsidrv;
   
   	if (pdev > 15) return ERROR;
    ostack = Super(NULL);
	/* check #pdev device is set or not */
	set = typedev & (mask << pdev);
	scsidrv = typedrv & (mask << pdev);
	if ((set)||(scsidrv)) {	/* if set, it is a removable driver */
		errnum = rqsense(pdev, 16, data);
	} else {	/* if not set, it is a not removable driver */
   		errnum = rqsense(pdev, 4, data);
	}
    delay();
    Super(ostack);
    
    if (errnum != 0)
        return err("[1][Fatal error][OK]");
        
	if ((set)||(scsidrv))	{ /* if set, it is a removable driver */
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
