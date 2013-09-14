/*
 *	ERROR.C
 *
 *	26-May-1988	ml.	Started this.
 *
 */

#include "osbind.h"
#include "obdefs.h" 
#include "defs.h"
#include "addr.h"
#include "error.h"

/*
 *  Errcode()
 *	Find error code for previous instruction which returned Check
 *  Condition Status.
 *
 *  Input:
 *	pdev - the physical device number (0 -> 7).
 *
 *  Return:
 *	errnum - the error code.
 */
errcode(pdev)
int pdev;
{
    char data[16];
    extern long rq_sense(), ostack;
    UWORD errnum;
   
    ostack = Super(NULL);
    errnum = rq_sense(pdev, data);
    delay();
    Super(ostack);
    
    if (errnum != 0)
        return err("[1][Fatal error][OK]");
        
    data[0] &= 0x7f;		/* mask out advalid bit */
    errnum = (UWORD)data[0];
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
    	    
    	default:
    	    return ERROR;
    }
    return OK;
}
