/*{{{}}}*/
/*********************************************************************
 *
 * SCSI-Aufrufe fÅr alle GerÑte
 *
 * $Source: u:\k\usr\src\scsi\cbhd\rcs\scsi.c,v $
 *
 * $Revision: 1.3 $
 *
 * $Author: Steffen_Engel $
 *
 * $Date: 1996/02/14 11:22:12 $
 *
 * $State: Exp $
 *
 **********************************************************************
 * History:
 *
 * $Log: scsi.c,v $
 * Revision 1.3  1996/02/14  11:22:12  Steffen_Engel
 * Maskierung in SetCmd6 korrigiert
 *
 * Revision 1.2  1995/12/21  01:23:42  S_Engel
 * Kommandostruktur immer lokal fÅr Reentranz
 *
 * Revision 1.1  1995/11/28  19:14:14  S_Engel
 * Initial revision
 *
 *
 *
 *********************************************************************/

#include <import.h>

#ifdef _GCC_
  #include <osbind.h>
#endif
#include <scsidrv/scsiio.h>

#include <export.h>
#include <scsidrv/scsi.h>

/*-------------------------------------------------------------------------*/
/*-                                                                       -*/
/*- Variablen                                                             -*/
/*-                                                                       -*/
/*-------------------------------------------------------------------------*/
tHandle   Handle;
tSCSICmd  SCmd;



/* exportierte Funktionen */

LONG TestUnitReady(void)
{{{
tCmd6 Cmd;
  SetCmd6(&Cmd, 0x00, 0, 0);
  return In(SetCmd((BYTE *)&Cmd, 6, NULL, 0, DefTimeout));
}}}


LONG Inquiry(void  *data, BOOLEAN Vital, UWORD VitalPage, WORD length)
{{{
tCmd6 Cmd;

  SetCmd6(&Cmd, 0x12, 0, length);

  if (Vital)
  {
    Cmd.LunAdr |= 1;                 /* Vital gefordert  */
    Cmd.Adr = VitalPage * 0x100;     /* Page eintragen   */
  }
  return (In(SetCmd((BYTE *)&Cmd, 6, data, length, 1000)));
}}}


LONG ModeSelect(UWORD        SelectFlags,
                   void        *Buffer,
                   UWORD        ParmLen)
{{{
tCmd6 Cmd;
  ParmLen = ParmLen
            + sizeof(tParmHead)       /* ParameterHeader                */
            + sizeof(tBlockDesc);     /* Block-Deskriptor               */

  SetCmd6(&Cmd, 0x15, 0, ParmLen);
  Cmd.LunAdr |= SelectFlags % 0x20;

  return Out(SetCmd((BYTE *)&Cmd, 6, Buffer, ParmLen, DefTimeout));
}}}


LONG ModeSense(UWORD     PageCode,
                  UWORD     PageControl,
                  void     *Buffer,
                  UWORD     ParmLen)
{{{
tCmd6 Cmd;
  ParmLen = ParmLen
            + sizeof(tParmHead)       /* ParameterHeader                */
            + sizeof(tBlockDesc);     /* Block-Deskriptor               */

  SetCmd6(&Cmd, 0x1A, 0, ParmLen);
  Cmd.Adr = ((PageControl * 64 + PageCode) % 0x100)*0x100;

  return In(SetCmd((BYTE *)&Cmd, 6, Buffer, ParmLen, DefTimeout));
}}}


LONG PreventMediaRemoval(BOOLEAN Prevent)
{{{
tCmd6 Cmd;

  if (Prevent)
    SetCmd6(&Cmd, 0x01E, 0, 1);
  else
    SetCmd6(&Cmd, 0x01E, 0, 0);

  return In(SetCmd((BYTE *)&Cmd, 6, NULL, 0, DefTimeout));
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


void SetCmd6(tCmd6 *Cmd,
             UWORD Opcode,
             ULONG BlockAdr,
             UWORD TransferLen)
{{{
  Cmd->Command = Opcode;
  Cmd->LunAdr  = LogicalUnit + (BlockAdr/0x10000L & 0x1F);
  Cmd->Adr     = BlockAdr % 0x10000L;
  Cmd->Len     = TransferLen;
  Cmd->Flags   = 0;
}}}

void SetCmd10(tCmd10 *Cmd,
              UWORD Opcode,
              ULONG BlockAdr,
              UWORD TransferLen)
{{{
  Cmd->Command   = Opcode;
  Cmd->Lun       = LogicalUnit;
  Cmd->Adr       = BlockAdr;
  Cmd->Reserved  = 0;
  Cmd->LenHigh   = TransferLen / 0x100;
  Cmd->LenLow    = TransferLen % 0x100;
  Cmd->Flags     = 0;
}}}

void SetCmd12(tCmd12 *Cmd,
              UWORD Opcode,
              ULONG BlockAdr,
              ULONG TransferLen)
{{{
  Cmd->Command = Opcode;
  Cmd->Lun     = LogicalUnit;
  Cmd->Adr     = BlockAdr;
  Cmd->Len     = TransferLen;
  Cmd->Reserved= 0;
  Cmd->Flags   = 0;
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

