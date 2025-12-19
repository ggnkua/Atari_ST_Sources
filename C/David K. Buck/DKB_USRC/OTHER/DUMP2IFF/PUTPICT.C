/** putpict.c ***************************************************/
/* PutPict().  Given a BitMap and a color map in RAM on the 	*/
/* Amiga, outputs as an ILBM.  See /iff/ilbm.h & /iff/ilbmw.c.	*/
/*                   23-Jan-86  				*/
/*                                                              */
/* By Jerry Morrison and Steve Shaw, Electronic Arts.           */
/* This software is in the public domain.                       */
/*                                                              */
/* This version for the Commodore-Amiga computer.               */
/*                                                              */
/****************************************************************/
#include "iff/intuall.h"
#include "iff/gio.h"
#include "iff/ilbm.h"
#include "iff/putpict.h"

#define MaxDepth 5
static IFFP ifferror = 0;

#define CkErr(expression)  {if (ifferror == IFF_OKAY) ifferror = (expression);}
    
/*****************************************************************************/
/* IffErr                                                                    */
/*                                                                           */
/* Returns the iff error code and resets it to zero                          */
/*                                                                           */
/*****************************************************************************/
IFFP IffErr()
   {
   IFFP i;
   i = ifferror;
   ifferror = 0;
   return(i);
   }

/*****************************************************************************/
/* PutPict()                                                                 */
/*                                                                           */
/* Put a picture into an IFF file                                            */
/* Pass in mask == NULL for no mask.                                         */
/*                                                                           */
/* Buffer should be big enough for one packed scan line                      */
/* Buffer used as temporary storage to speed-up writing.                     */
/* A large buffer, say 8KB, is useful for minimizing Write and Seek calls.   */
/* (See /iff/gio.h & /iff/gio.c).                                            */
/*****************************************************************************/
    
BOOL PutPict(file, vp, buffer, bufsize)
    LONG file;
    struct ViewPort *vp;
    BYTE *buffer;
    LONG bufsize;
    {
    int pageW, pageH;
    BitMapHeader bmHdr;
    GroupContext fileContext, formContext;

    pageW = vp->DWidth;
    pageH = vp->DHeight;

    ifferror = InitBMHdr(&bmHdr,
	vp->RasInfo->BitMap, 
	mskNone, 
	cmpByteRun1,
	0,
	pageW, 
	pageH );
	
/* use buffered write for speedup, if it is big-enough for both
 * PutBODY's buffer and a gio buffer.*/
#define BODY_BUFSIZE 512
    if (ifferror == IFF_OKAY  &&  bufsize > 2*BODY_BUFSIZE) {
	if (GWriteDeclare(file, buffer+BODY_BUFSIZE, bufsize-BODY_BUFSIZE) < 0)
	    ifferror = DOS_ERROR;
	bufsize = BODY_BUFSIZE;
	}
    
    CkErr(OpenWIFF(file, &fileContext, szNotYetKnown) );
    CkErr(StartWGroup(&fileContext, FORM, szNotYetKnown, ID_ILBM, &formContext) );

    CkErr(PutCk(&formContext, ID_BMHD, sizeof(BitMapHeader), (BYTE *)&bmHdr));

    CkErr(PutCAMG(&formContext, vp->Modes));

    if (vp->ColorMap != NULL)
	CkErr( PutCMAP(&formContext, vp));
    CkErr( PutBODY(&formContext, vp->RasInfo->BitMap, NULL, &bmHdr, buffer, bufsize) );

    CkErr( EndWGroup(&formContext) );
    CkErr( CloseWGroup(&fileContext) );
    if (GWriteUndeclare(file) < 0  &&  ifferror == IFF_OKAY)
	ifferror = DOS_ERROR;
    return( (BOOL)(ifferror != IFF_OKAY) );
    }    

 
