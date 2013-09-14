/*
 *	ERROR.C
 *
 *	26-May-1988	ml.	Started this.
 *	18-Jul-1990	ml.	Modified for FHDX.
 *
 */

#include <osbind.h>
#include <obdefs.h>
#include "define.h"
#include "addr.h"
#include "fhdx.h"

/*
 *  Errcode()
 *	Find error code for previous instruction which returned Check
 *  Condition Status.
 *
 *  Input:
 *	pdev - the physical device number.
 *
 */
errcode(pdev)
int pdev;
{
    char data[16];
    extern int rqsense(), pcode;
    int len;
    long ostack;
    UWORD error;

    if (pcode == 0x80)	/* if ST-506 drives */
    	len = 4;	/* non-extended Request Sense */
    else		/* else SCSI drives */
    	len = 16;	/* extended Request Sense */
    	
    ostack = Super(NULL);
    error = rqsense(pdev, len, data);
    delay();
    Super(ostack);
    
    if (error != 0)
        return err("[1][Cannot get error code!][  OK  ]");
        
    if (len == 4)	/* if non-extended Request Sense */
    	error = (UWORD)(data[0] & 0x7f);	/* error code at byte 0 */
    else		/* if extended Request Sense */
    	error = (UWORD)data[12];		/* error code at byte 12 */
    	
    itoa(error, data);
    strcpy(errnum[ERRNO].ob_spec, data);
    errnum[ERROK].ob_state = NORMAL;
    execform(errnum, 0);
}
