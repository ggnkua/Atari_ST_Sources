/****************************************************************************
 *
 * Definitionen und Kommandos fÅr SCSI-Calls in C
 *
 * $Source: f:\kleister.ii\cbhd\RCS\scsilib.h,v $
 *
 * $Revision: 1.6 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1995/10/22 15:43:34 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsilib.h,v $
 * Revision 1.6  1995/10/22  15:43:34  S_Engel
 * Kommentare leicht Åberarbeitet
 *
 * Revision 1.5  1995/10/03  12:49:08  S_Engel
 * Typendefinitionen nach scsidefs Åbertragen
 *
 * Revision 1.4  1995/09/29  09:12:16  S_Engel
 * alles nîtige fÅr virtuelles RAM
 *
 * Revision 1.3  1995/06/16  12:06:46  S_Engel
 * *** empty log message ***
 *
 * Revision 1.2  1995/03/09  09:53:16  S_Engel
 * Flags: Disconnect eingefÅhrt
 *
 * Revision 1.1  1995/03/05  18:54:16  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************/


#ifndef __SCSIIO_H
#define __SCSIIO_H

#include <portab.h>
#include "scsidefs.h"                                 /* Typen fÅr SCSI-Lib */

/*****************************************************************************
 * Typen
 *****************************************************************************/


/*****************************************************************************
 * Konstanten                                                                *
 *****************************************************************************/
#define DefTimeout 2000



/*****************************************************************************
 * Variablen
 *****************************************************************************/

GLOBAL tpScsiCall scsicall;     /* READ ONLY!! */

GLOBAL BOOLEAN    HasVirtual;   /* READ ONLY!! */

GLOBAL tReqData   ReqBuff;      /* Request Sense Buffer fÅr alle Kommandos */

/*****************************************************************************
 * Funktionen und zugehîrige Typen
 *****************************************************************************/

/* fÅr In und Out kînnen diese Routinen gerufen werden, sie beachten selbsttÑtig,
 * wenn bei virtuellem RAM die Daten umkopiert werden mÅssen
 */
LONG cdecl In          (tpSCSICmd Parms);

LONG cdecl Out         (tpSCSICmd Parms);

LONG cdecl InquireSCSI (WORD          what,
                        tBusInfo     *Info);

LONG cdecl InquireBus  (WORD          what,
                        WORD          BusNo,
                        tDevInfo     *Dev);

LONG cdecl CheckDev    (WORD          BusNo,
                        const DLONG  *DevNo,
                        char         *Name,
                        UWORD        *Features);

LONG cdecl RescanBus   (WORD          BusNo);

LONG cdecl Open        (WORD          bus,
                        const DLONG  *Id,
                        ULONG        *MaxLen);

LONG cdecl Close       (tHandle       handle);

LONG cdecl Error       (tHandle       handle,
                        WORD          rwflag,
                        WORD          ErrNo);



BOOLEAN init_scsiio (void);
  /* Initialisierung des Moduls */

#endif
