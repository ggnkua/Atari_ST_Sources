/*{{{}}}*/
/*********************************************************************
 *
 * SCSI-Aufrufe fÅr alle GerÑte
 *
 * $Source$
 *
 * $Revision$
 *
 * $Author$
 *
 * $Date$
 *
 * $State$
 *
 **********************************************************************
 * History:
 *
 * $Log$
 *
 *
 *********************************************************************/

#include <import.h>
#ifdef __PUREC__
#else
  #include <osbind.h>
#endif
#include "scsiio.h"

#include <export.h>
#include "scsi.h"

/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- Variablen                                                             -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
tHandle   Handle;
tSCSICmd  SCmd;



/* exportierte Funktionen */

LONG TestUnitReady(void)
{
  SetCmd6(0x00, 0, 0);
  return In(SetCmd((BYTE *)&Cmd6, 6, NULL, 0, DefTimeout));
}


LONG Inquiry(void  *data, BOOLEAN Vital, UWORD VitalPage, WORD length)
{{{

  SetCmd6(0x12, 0, length);

  if (Vital)
  {
    Cmd6.LunAdr |= 1;                 /* Vital gefordert  */
    Cmd6.Adr = VitalPage * 0x100;     /* Page eintragen   */
  }
  return (In(SetCmd((BYTE *)&Cmd6, 6, data, length, 1000)));
}}}


LONG ModeSelect(UWORD        SelectFlags,
                   void        *Buffer,
                   UWORD        ParmLen)
{{{
  ParmLen = ParmLen
            + sizeof(tParmHead)       /* ParameterHeader                */
            + sizeof(tBlockDesc);     /* Block-Deskriptor               */

  SetCmd6(0x15, 0, ParmLen);
  Cmd6.LunAdr |= SelectFlags % 0x20;

  return Out(SetCmd((BYTE *)&Cmd6, 6, Buffer, ParmLen, DefTimeout));
}}}


LONG ModeSense(UWORD     PageCode,
                  UWORD     PageControl,
                  void     *Buffer,
                  UWORD     ParmLen)
{{{
  ParmLen = ParmLen
            + sizeof(tParmHead)       /* ParameterHeader                */
            + sizeof(tBlockDesc);     /* Block-Deskriptor               */

  SetCmd6(0x1A, 0, ParmLen);
  Cmd6.Adr = ((PageControl * 64 + PageCode) % 0x100)*0x100;

  return In(SetCmd((BYTE *)&Cmd6, 6, Buffer, ParmLen, DefTimeout));
}}}


LONG PreventMediaRemoval(BOOLEAN Prevent)
{{{
  if (Prevent)
    SetCmd6(0x01E,0,1);
  else
    SetCmd6(0x01E,0,0);

  return In(SetCmd((BYTE *)&Cmd6, 6, NULL, 0, DefTimeout));
}}}


long ssp;

void SuperOn(void)
{{{
  ssp = Super(0);
}}}

void SuperOff(void)
{{{
  Super((void *) ssp);
}}}

void Wait(ULONG Ticks)
{{{
long *hz200 = (long *)0x4ba;
long endtime;

  endtime = *hz200 + Ticks;

  while (*hz200 < endtime)
  {
  }
}}}

void SetBlockSize(ULONG NewLen)
{{{
  BlockLen = NewLen;
}}}

ULONG GetBlockSize()
{{{
  return BlockLen;
}}}


void SetScsiUnit(tHandle handle, WORD Lun, ULONG MaxLen)
{{{
  Handle = handle;
  LogicalUnit = Lun*32;
  MaxDmaLen = MaxLen;
}}}


void SetCmd6(UWORD Cmd,
             ULONG BlockAdr,
             UWORD TransferLen)
{{{
  Cmd6.Command = Cmd;
  Cmd6.LunAdr  = LogicalUnit + BlockAdr/0x10000 % 0x1F;
  Cmd6.Adr     = BlockAdr;
  Cmd6.Len     = TransferLen;
  Cmd6.Flags   = 0;
}}}

void SetCmd10(UWORD Cmd,
              ULONG BlockAdr,
              UWORD TransferLen)
{{{
  Cmd10.Command   = Cmd;
  Cmd10.Lun       = LogicalUnit;
  Cmd10.Adr       = BlockAdr;
  Cmd10.Reserved  = 0;
  Cmd10.LenHigh   = TransferLen / 0x100;
  Cmd10.LenLow    = TransferLen % 0x100;
  Cmd10.Flags     = 0;
}}}

void SetCmd12(UWORD Cmd,
              ULONG BlockAdr,
              ULONG TransferLen)
{{{
  Cmd12.Command = Cmd;
  Cmd12.Lun     = LogicalUnit;
  Cmd12.Adr     = BlockAdr;
  Cmd12.Len     = TransferLen;
  Cmd12.Reserved= 0;
  Cmd12.Flags   = 0;
}}}


tpSCSICmd SetCmd(BYTE    *Cmd,
                 WORD     CmdLen,
                 void    *Buffer,
                 ULONG    Len,
                 ULONG    TimeOut)
{{{
  SCmd.Handle = Handle;
  SCmd.Cmd    = Cmd;
  SCmd.CmdLen = CmdLen;
  SCmd.Buffer = Buffer;
  SCmd.TransferLen = Len;
  SCmd.SenseBuffer = ReqBuff;
  SCmd.Timeout  = TimeOut;
  SCmd.Flags    = ScsiFlags;
  return &SCmd;
}}}

BOOLEAN init_scsi()
{
  /* Defaults setzen */
  SetBlockSize(512L);

  return init_scsiio();
}
