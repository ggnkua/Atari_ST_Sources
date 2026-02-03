/*{{{}}}*/
/*********************************************************************
 *
 * Kommandos zum Zugriff auf CD-ROMs
 *
 * $Source: u:\k\usr\src\scsi\cbhd\rcs\scsicd.c,v $
 *
 * $Revision: 1.4 $
 *
 * $Author: Steffen_Engel $
 *
 * $Date: 1996/02/14 11:29:58 $
 *
 * $State: Exp $
 *
 **********************************************************************
 * History:
 *
 * $Log: scsicd.c,v $
 * Revision 1.4  1996/02/14  11:29:58  Steffen_Engel
 * Diverser Kleinkram
 *
 * Revision 1.3  1995/12/21  01:24:08  S_Engel
 * Kommandostruktur immer lokal fÅr Reentranz
 *
 * Revision 1.2  1995/11/28  19:14:14  S_Engel
 * *** empty log message ***
 *
 * Revision 1.1  1995/11/13  23:45:52  S_Engel
 * Initial revision
 *
 *
 *
 *********************************************************************/

#include <import.h>
#include <portab.h>

#include <scsidrv/scsiio.h>
#include <scsidrv/scsi.h>

#include <export.h>
#include <scsidrv/scsicd.h>


LONG PauseResume(BOOLEAN Pause)
{{{
tCmd10 Cmd;

  SetCmd10(&Cmd, 0x04B, 0, 0);
  if (Pause)
    Cmd.LenLow = 0;
  else
    Cmd.LenLow = 1;

  return In(SetCmd((BYTE*)&Cmd, 6, NULL, 0, DefTimeout));
}}}


LONG PlayAudio(LONG BlockAdr, LONG TransLength)
{{{
tCmd12 Cmd;
  SetCmd12(&Cmd, 0x0A5, BlockAdr, TransLength);
  return In(SetCmd((BYTE *)&Cmd, 6, NULL, 0, DefTimeout));
}}}


LONG PlayAudioMSF(tMSF Start, tMSF Stop)
{{{
struct
{
  UBYTE Code;
  UBYTE Lun;
  tMSF  Startmsf;
  UBYTE Stopm;
  UBYTE Stops;
  UBYTE Stopf;
  UBYTE Flags;
} Cmd;

  Cmd.Code      = 0x47;
  Cmd.Lun       = 0;
  Cmd.Startmsf  = Start;
  Cmd.Stopm     = Stop.s.M;
  Cmd.Stops     = Stop.s.S;
  Cmd.Stopf     = Stop.s.F;
  Cmd.Flags     = 0;

  return In(SetCmd((BYTE *)&Cmd, 10, NULL, 0, DefTimeout));
}}}


LONG PlayAudioTrack(UWORD StartTrack, UWORD StartIndex, UWORD EndTrack, UWORD EndIndex)
{{{

struct
{
  BYTE Code;
  BYTE Lun;
  BYTE Res2;
  BYTE Res3;
  BYTE StartTr;
  BYTE StartIn;
  BYTE Res6;
  BYTE StopTr;
  BYTE StopIn;
  BYTE Flags;
}Cmd;

  Cmd.Code    = 0x48;
  Cmd.Lun     = 0;
  Cmd.Res2    = 0;
  Cmd.Res3    = 0;
  Cmd.StartTr = StartTrack % 0x100;
  Cmd.StartIn = StartIndex % 0x100;
  Cmd.StopTr  = EndTrack %  0x100;
  Cmd.StopIn  = EndIndex % 0x100;
  Cmd.Res6    = 0;
  Cmd.Flags   = 0;

  return In(SetCmd((BYTE *)&Cmd, 10, NULL, 0, DefTimeout));
}}}


LONG PlayAudioRelative(UWORD StartTrack, ULONG RelAdr, ULONG Len)
{{{
tCmd12 Cmd;
  SetCmd12(&Cmd, 0xA9, RelAdr, Len);
  Cmd.Reserved = StartTrack % 0x100;
  return In(SetCmd((BYTE *)&Cmd, 12, NULL, 0, DefTimeout));
}}}


LONG ReadHeader(BOOLEAN  MSF, ULONG BlockAdr,
                   BYTE    *Mode, tMSF *AbsoluteAdr)
{{{
LONG    ret;
tMSF    Data[2];
tCmd10 Cmd;

  SetCmd10(&Cmd, 0x44, BlockAdr, sizeof(Data));

  if (MSF)
  {
    Cmd.Lun = 2;
  }

  ret = In(SetCmd((BYTE *)&Cmd, 10, (void *)Data, sizeof(Data), DefTimeout));

  *Mode = Data[0].s.Resrvd;
  *AbsoluteAdr = Data[1];
  return ret;
}}}


LONG ReadSubChannel(BOOLEAN MSF, BOOLEAN SUBQ,
                    UWORD SubFormat, UWORD Track,
                    void *Data, UWORD Len)
{{{
struct{
  BYTE opcode;
  BYTE lun;
  BYTE subq;
  BYTE subform;
  UWORD res;
  BYTE track;
  BYTE lenhigh;
  BYTE lenlow;
  BYTE flag;
}Cmd;

  Cmd.opcode = 0x42;

  if (MSF)
    Cmd.lun = 2;
  else
    Cmd.lun = 0;

  if (SUBQ)
    Cmd.subq = 0x40;
  else
    Cmd.subq = 0;

  Cmd.subform = SubFormat;
  Cmd.res = 0;
  Cmd.track = Track;
  Cmd.lenlow = Len % 0x100;
  Cmd.lenhigh = Len % 0x100;
  Cmd.flag = 0;

  return In(SetCmd((BYTE *)&Cmd, 10, Data, Len, DefTimeout));
}}}


LONG ReadTOC(BOOLEAN MSF, UWORD StartTrack,
                  void *Buffer, UWORD Len)
{{{
tCmd10 Cmd;
  SetCmd10(&Cmd, 0x43, 0, Len);
  if (MSF)
  {
    Cmd.Lun |= 2;
  }

  Cmd.Reserved = StartTrack;

  return In(SetCmd((BYTE *)&Cmd, 10, Buffer, Len, DefTimeout));
}}}

BOOLEAN init_scsicd(void)
{{{
  return TRUE;  /* hier gibts nix zu tun */
}}}        