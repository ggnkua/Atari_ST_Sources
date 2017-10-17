/*{{{}}}*/
/****************************************************************************
 *
 * Definitionen fÅr SCSI-Calls in C
 *
 * $Source: u:\usr\src\scsi\cbhd\RCS\scsiio.c,v $
 *
 * $Revision: 1.7 $
 *
 * $Author: Steffen_Engel $
 *
 * $Date: 1997/03/24 08:38:42 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsiio.c,v $
 * Revision 1.7  1997/03/24  08:38:42  Steffen_Engel
 * Win32-Teil eingebaut
 * mit USEASPI wird statt einens SCSI-Treibers, ein ASPI32-Treiber verwendet
 * damit kînnen die Programme auch auf NT/95 benutzt werden.
 *
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

#include "scsidrv/scsidefs.h"

#ifndef USEASPI
  #include "cookie.h"
#else
  #include <windows.h>
  #include "aspi_w32.h"
#endif

#include <export.h>
#include "scsidrv/scsiio.h"

/* lokale Variablen */
char *VirtBuffer;

#ifdef USEASPI
  #define       MAXBUS 10
  HINSTANCE     ASPI;
#endif



#ifndef USEASPI
/* nach den SCSI-Cookie suchen */
void srch_cookie(void)
{{{

  COOKIE *cookie;

  DriverRev = 0;

  cookie = getcookie((ULONG)0x53435349L);          /* SCSI */

  if (cookie != NULL)
  {
    scsicall = (tpScsiCall) cookie->val;

    /* Revision merken */
    DriverRev = scsicall->Version;

    if ((scsicall->Version >> 8) != (SCSIRevision >> 8))
      scsicall = NULL;
  }

  cookie = getcookie((ULONG)0x504d4d55L);          /* PMMU */
  HasVirtual = (cookie != NULL) && (cookie->val != 0L);

}}}
#endif


#ifdef USEASPI
/*-----------------------------------------------------------------------
 *
 * die aspi-Nutzung fÅr NT/95 arbeitet nicht mit direktem umsetzen der
 * Aufrufe, da evtl. jemand direkt Åber scsicall ruft
 * Daher wird scsicall mit dieser Tabelle belegt
 *
 *-----------------------------------------------------------------------*/

void clear(void *buf, LONG size)
{{{
LONG count;
char *buffer;

        buffer = (char *) buf;                                  
        for (count = 0; count < size; count++)
          buffer[count] = 0;
}}}

void abort_srb(SRB *srb)
{{{
SRB srb2;

        srb2.head = srb->head;
        srb2.head.SRB_Cmd = SC_ABORT_SRB;
        srb2.srb.abort.SRB_ToAbort = srb;
        SendASPI32Command(&srb2); 
        srb->head.SRB_Status = SS_ABORTED;
}}}



LONG cdecl aspi_In_Out(tpSCSICmd Parms, WORD in)
{{{
SRB   srb;
WORD  count;
LONG  ret = 0;
LONG  status;
HANDLE ASPICompletionEvent;

  /* srb lîschen */
  clear(&srb, sizeof(srb));
  /* srb-Werte setzen */
  srb.head.SRB_Cmd = SC_EXEC_SCSI_CMD;
  srb.head.SRB_HaId = (BYTE)((ULONG)Parms->Handle>>16);

        if (in)
                srb.head.SRB_Flags |= SRB_DIR_IN; 
        else
                srb.head.SRB_Flags |= SRB_DIR_OUT; 

        srb.head.SRB_Flags |= SRB_EVENT_NOTIFY;

  srb.srb.scsicmd.SRB_Target = (BYTE)((ULONG)Parms->Handle & 0xFF);
  srb.srb.scsicmd.SRB_Lun    = Parms->Cmd[1] >> 5;
  srb.srb.scsicmd.SRB_BufLen = Parms->TransferLen;
  srb.srb.scsicmd.SRB_BufPointer = Parms->Buffer;
  srb.srb.scsicmd.SRB_SenseLen = 16;
  srb.srb.scsicmd.SRB_CDBLen = (BYTE)Parms->CmdLen;
  for (count = 0; count < 16; count++)
  {
    srb.srb.scsicmd.CDBByte[count] = Parms->Cmd[count];
  }

        if ((ASPICompletionEvent = CreateEvent(NULL, FALSE, FALSE, NULL)) == NULL)
        {
                return -1;
        }
        srb.srb.scsicmd.SRB_PostProc = ASPICompletionEvent;

  status = SendASPI32Command(&srb);

  if (srb.head.SRB_Status == SS_PENDING)
  {
                if (WaitForSingleObject(ASPICompletionEvent, Parms->Timeout*5) == WAIT_OBJECT_0)
                {
                        ResetEvent(ASPICompletionEvent);
                }                               
  }

  switch (srb.head.SRB_Status)
  {
    case SS_PENDING:      /* Timeout */
      abort_srb(&srb);
      ret = -1;
      break;
    case SS_COMP:
      ret = 0;
      break;
    case SS_ERR:
      for (count = 0; count < 16; count++)
      {
        Parms->SenseBuffer[count] = srb.srb.scsicmd.SenseArea[count];
      }
      ret = 2;       /* Check Condition */
      break;

    default:
      ret = -1;
  }
  return ret;
}}}

LONG cdecl aspi_In(tpSCSICmd Parms)
{{{
        return aspi_In_Out(Parms, 1);
}}}

LONG cdecl aspi_Out(tpSCSICmd Parms)
{{{
        return aspi_In_Out(Parms, 0);
}}}

LONG cdecl aspi_InquireSCSI (WORD          what,
                                                                                                                 tBusInfo     *Info)
{{{
WORD bus, nhosts;
ULONG   status;
SRB   srb;


        if (ASPI == NULL)
                return -1L;

        if (what == cInqFirst)
        {
                Info->Private.BusIds=0;
        }

        /* welchen als n‰chsten melden? */
        bus=0;
        while ((1<<bus) & Info->Private.BusIds)
          bus++;

        if (bus > MAXBUS)
                return -1;

  status = GetASPI32SupportInfo();
  nhosts = (WORD)(status & 0xff);
        if (bus >= nhosts)
                return -1L;

        /* bit in der tabelle gemeldeter Busse setzen */
        Info->Private.BusIds|=1<<bus;

        /* informationen ¸ber den Bus holen */
  clear(&srb, sizeof(srb));
  srb.head.SRB_Cmd  = SC_HA_INQUIRY;
  srb.head.SRB_HaId = (BYTE) bus;
  status = SendASPI32Command(&srb);

        strcpy(Info->BusName, srb.srb.ha.HA_Identifier);
        Info->BusNo = bus;
        Info->Features = cArbit | cAllCmds | cTargCtrl;
        Info->MaxLen = 64L*1024L;
        return 0L;
}}}

LONG cdecl aspi_InquireBus  (WORD          what,
                                                                                                                 WORD          BusNo,
                                                                                                                 tDevInfo     *Dev)
{{{
SRB srb;
LONG status;

        if (ASPI == NULL)
        {
                return -1L;
        }

        /* welche Id ist dran? */                       
        if (what == cInqFirst)
        {
                Dev->Private[0] = 0;
        }
        else
        {
                Dev->Private[0]++;
        }

        /* aspi fragen, ob das in Ordnung ist */
        do
        {
          clear(&srb, sizeof(srb));
                srb.head.SRB_Cmd  = SC_GET_DEV_TYPE;
                srb.head.SRB_HaId = (BYTE)BusNo;
                srb.srb.devblock.SRB_Target = (BYTE) Dev->Private[0];
                status = SendASPI32Command(&srb);
                while (srb.head.SRB_Status == SS_PENDING)
                {
                }

                if (Dev->Private[0] >= 64)
                        return -1L;

                if (status == SS_NO_DEVICE) 
                {
                        abort_srb(&srb);
                        Dev->Private[0]++;
                }
        } while (status == SS_NO_DEVICE); 

        Dev->SCSIId.hi = 0;
        Dev->SCSIId.lo = Dev->Private[0];

        return 0;
}}}


LONG cdecl aspi_CheckDev    (WORD          BusNo,
                             const DLONG  *DevNo,
                             char         *Name,
                             UWORD        *Features)
{{{
SRB srb;
LONG status;

  clear(&srb, sizeof(srb));
        srb.head.SRB_Cmd  = SC_GET_DEV_TYPE;
        srb.head.SRB_HaId = (BYTE)BusNo;
        srb.srb.devblock.SRB_Target = (BYTE) DevNo->lo;
        status = SendASPI32Command(&srb);
        while (srb.head.SRB_Status == SS_PENDING)
        {
        }

        if (status == SS_NO_DEVICE) 
        {
                abort_srb(&srb);
                return -1;
        }

        /* informationen ¸ber den Bus holen */
  clear(&srb, sizeof(srb));
  srb.head.SRB_Cmd  = SC_HA_INQUIRY;
  srb.head.SRB_HaId = (BYTE) BusNo;
  status = SendASPI32Command(&srb);

        strcpy(Name, srb.srb.ha.HA_Identifier);
        *Features = cArbit | cAllCmds | cTargCtrl;

        return 0;
}}}

LONG cdecl aspi_RescanBus   (WORD          BusNo)
{{{
  return 0L;
}}}

LONG cdecl aspi_Open        (WORD          bus,
                             const DLONG  *Id,
                             ULONG        *MaxLen)
{{{
  *MaxLen = 64*1024;   /* das ist unter ASPI sicher */
  return (((LONG) bus) << 16) + Id->lo;
}}}


LONG cdecl aspi_Close       (tHandle       handle)
{{{
  return 0;
}}}


LONG cdecl aspi_Error       (tHandle       handle,
                                                                                                                 WORD          rwflag,
                                                                                                                 WORD          ErrNo)
{{{
  return 0;
}}}


tScsiCall aspi_tab;

void aspi_init(void)
{{{
  aspi_tab.Version = SCSIRevision;
  aspi_tab.In = aspi_In;
  aspi_tab.Out = aspi_Out;
  aspi_tab.InquireSCSI = aspi_InquireSCSI;
  aspi_tab.InquireBus = aspi_InquireBus;
  aspi_tab.CheckDev = aspi_CheckDev;
  aspi_tab.RescanBus = aspi_RescanBus;

  aspi_tab.Open = aspi_Open;
  aspi_tab.Close = aspi_Close;
  aspi_tab.Error = aspi_Error;

        /* ASPI-DLL laden */
        if (NULL == ASPI)
        {
                ASPI = LoadLibrary("WNASPI32.DLL");
                if (NULL == ASPI)
                {
                        printf("ASPI-Treiber nicht gefunden");
                }
                else
                {
                        GetASPI32SupportInfo = (tGetASPI32SupportInfo) GetProcAddress(ASPI, "GetASPI32SupportInfo");
                        SendASPI32Command = (tSendASPI32Command) GetProcAddress(ASPI, "SendASPI32Command");
                }
        }

}}}

#endif


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

#ifndef USEASPI

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
#else
  /* einen ASPI-Handler an dieser Stelle in der normale Handlerstruktur
   * vorgaukeln */
  aspi_init();
  scsicall = &aspi_tab;
#endif

  }
  return (scsicall != NULL);
}}}
        
