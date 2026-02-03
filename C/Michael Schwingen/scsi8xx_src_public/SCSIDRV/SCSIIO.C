/*{{{}}}*/
/****************************************************************************
 *
 * Definitionen fÅr SCSI-Calls in C
 *
 * $Source: u:\k\usr\src\scsi\cbhd\rcs\scsiio.c,v $
 *
 * $Revision: 1.6 $
 *
 * $Author: Steffen_Engel $
 *
 * $Date: 1996/02/14 11:29:58 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsiio.c,v $
 * Revision 1.6  1996/02/14  11:29:58  Steffen_Engel
 * Diverser Kleinkram
 *
 * Revision 1.5  1995/11/28  19:14:14  S_Engel
 * *** empty log message ***
 *
 * Revision 1.4  1995/10/22  15:42:28  S_Engel
 * Anpassung auf lange Handles
 *
 * Revision 1.3  1995/10/03  12:55:34  S_Engel
 * Textklappungen, Initialisierung nur maximal einmal
 *
 * Revision 1.2  1995/09/29  09:14:30  S_Engel
 * virtuelles RAM wird berÅcksichtigt
 *
 * Revision 1.1  1995/06/16  12:06:46  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************/

#include <import.h>

#ifdef __PUREC__
  #include <tos.h>
#endif

#ifdef _GCC_
  #include <string.h>
  #include <osbind.h>
#endif

#include "cookie.h"

#include <export.h>
#include <scsidrv/scsiio.h>

char *VirtBuffer;

/* nach den SCSI-Cookie suchen */
void srch_cookie(void)
{{{

  COOKIE *cookie;

  cookie = getcookie((ULONG)0x53435349);          /* SCSI */
/*cookie = NULL;*/

  if (cookie != NULL)
  {
    scsicall = (tpScsiCall) cookie->val;
    if (scsicall->Version != SCSIRevision)
      scsicall = NULL;
  }

  cookie = getcookie((ULONG)0x504d4d55);          /* PMMU */
  HasVirtual = (cookie != NULL) && (cookie->val != 0L);

}}}


/* In und Out erst Åber eigene Prozeduren, wegen virtuellem RAM */
LONG cdecl In(tpSCSICmd Parms)
{{{
  void  *oldbuf;
  ULONG *phystop = (ULONG *)0x42e;
  LONG  ret;

  if (scsicall == NULL)
    return -1L;


  if (HasVirtual && ((ULONG)Parms->Buffer > *phystop))
  {
    oldbuf = Parms->Buffer;
    Parms->Buffer = VirtBuffer;

    /* jetzt den Transfer */
    ret = (scsicall->In(Parms));

    /* Daten kopieren */
    memcpy(oldbuf, Parms->Buffer, Parms->TransferLen);

    /* und Ergebnis melden */
    return ret;
  }
  else
  {
    return (scsicall->In(Parms));
  }
}}}

LONG cdecl Out(tpSCSICmd Parms)
{{{
  ULONG *phystop = (ULONG *)0x42e;

  if (scsicall == NULL)
    return -1L;

  if (HasVirtual && ((ULONG)Parms->Buffer > *phystop))
  {

    /* Daten kopieren */
    memcpy(VirtBuffer, Parms->Buffer, Parms->TransferLen);

    /* und neue Quelladresse eintragen */
    Parms->Buffer = VirtBuffer;

  }

  return (scsicall->Out(Parms));
}}}

LONG cdecl InquireSCSI (WORD          what,
                        tBusInfo     *Info)
{{{
  if (scsicall != NULL)
    return (scsicall->InquireSCSI(what, Info));
  else
    return -1L;
}}}

LONG cdecl InquireBus  (WORD          what,
                        WORD          BusNo,
                        tDevInfo     *Dev)
{{{
  if (scsicall != NULL)
    return (scsicall->InquireBus(what, BusNo, Dev));
  else
    return -1L;
}}}

LONG cdecl CheckDev    (WORD          BusNo,
                        const DLONG  *DevNo,
                        char         *Name,
                        UWORD        *Features)
{{{
  if (scsicall != NULL)
    return (scsicall->CheckDev(BusNo, DevNo, Name, Features));
  else
    return -1;

}}}

LONG cdecl RescanBus   (WORD          BusNo)
{{{
  if (scsicall != NULL)
    return (scsicall->RescanBus(BusNo));
  else
    return -1L;
}}}

LONG cdecl Open        (WORD          bus,
                        const DLONG  *Id,
                        ULONG        *MaxLen)
{{{
  if (scsicall != NULL)
    return (scsicall->Open(bus, Id, MaxLen));
  else
    return -1;
}}}


LONG cdecl Close       (tHandle       handle)
{{{
  if (scsicall != NULL)
    return (scsicall->Close(handle));
  else
    return -1;
}}}


LONG cdecl Error       (tHandle       handle,
                        WORD          rwflag,
                        WORD          ErrNo)
{{{
  if (scsicall != NULL)
    return (scsicall->Error(handle, rwflag, ErrNo));
  else
    return -1L;
}}}

BOOLEAN isinit = FALSE;

BOOLEAN init_scsiio()
{{{
  if (!isinit)
  {
    isinit      = TRUE;
    scsicall    = NULL;
    VirtBuffer  = NULL;

    srch_cookie();

    if (HasVirtual)
    {
      /* bei virtuellem RAM mÅssen wir jetzt einen Puffer im ST-RAM allozieren */
      VirtBuffer = (char *)Mxalloc(64L*1024L, 0); /* 64 kB im ST-RAM */
      if ((LONG)VirtBuffer <= 0)
        {
          if (VirtBuffer == NULL)
          {
            /* ohne Puffer lÑuft hier nix */
            return FALSE;
          }
          else
          {
            VirtBuffer = NULL;
          }
        }
    }

  }
  return (scsicall != NULL);
}}}
        
