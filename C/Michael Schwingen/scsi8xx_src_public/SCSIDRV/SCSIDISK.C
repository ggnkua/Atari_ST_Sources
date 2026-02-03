/*{{{}}}*/
/*********************************************************************
 *
 * Kommandos zum Zugriff auf Platten
 *
 * $Source: u:\k\usr\src\scsi\cbhd\rcs\scsidisk.c,v $
 *
 * $Revision: 1.3 $
 *
 * $Author: Steffen_Engel $
 *
 * $Date: 1996/02/14 11:21:56 $
 *
 * $State: Exp $
 *
 **********************************************************************
 * History:
 *
 * $Log: scsidisk.c,v $
 * Revision 1.3  1996/02/14  11:21:56  Steffen_Engel
 * Korrektur von cMaxBlockAdr
 *
 * Revision 1.2  1995/11/28  19:14:14  S_Engel
 * *** empty log message ***
 *
 * Revision 1.1  1995/11/13  23:45:30  S_Engel
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
#include <scsidrv/scsidisk.h>


LONG Read6(ULONG BlockAdr,
                UWORD TransferLen, void *buffer)
{{{
LONG ret;
tCmd6 Cmd;

  while (TransferLen > MaxDmaLen / BlockLen)
  {
    SetCmd6(&Cmd, 0x08, BlockAdr, MaxDmaLen / BlockLen);
    ret = In(SetCmd((BYTE *)&Cmd, 6, buffer, MaxDmaLen / BlockLen * BlockLen, DefTimeout));
    if (ret != 0)
      return ret;

    BlockAdr += MaxDmaLen / BlockLen;
    TransferLen -= MaxDmaLen / BlockLen;
    buffer = (void *)((long)buffer + MaxDmaLen / BlockLen * BlockLen);
  }

  SetCmd6(&Cmd, 0x08, BlockAdr, TransferLen);
  return In(SetCmd((BYTE *)&Cmd, 6, buffer, BlockLen * (ULONG)TransferLen, DefTimeout));
}}}

LONG Read10(ULONG BlockAdr,
                UWORD TransferLen, void *buffer)
{{{
LONG ret;
tCmd10 Cmd;

  while (TransferLen > MaxDmaLen / BlockLen)
  {
    SetCmd10(&Cmd, 0x028, BlockAdr, MaxDmaLen / BlockLen);
    ret = In(SetCmd((BYTE *)&Cmd, 10, buffer, MaxDmaLen / BlockLen * BlockLen, 20*200));
    if (ret != 0)
      return ret;
    BlockAdr += MaxDmaLen / BlockLen;
    TransferLen -= MaxDmaLen / BlockLen;
    buffer = (void *)((long)buffer + MaxDmaLen / BlockLen * BlockLen);
  }

  SetCmd10(&Cmd, 0x028, BlockAdr, TransferLen);
  return In(SetCmd((BYTE *)&Cmd, 10, buffer, BlockLen * (ULONG)TransferLen, 20*200));
}}}


LONG Write6(ULONG BlockAdr,
                UWORD TransferLen, void *buffer)
{{{
LONG ret;
tCmd6 Cmd;

  while (TransferLen > MaxDmaLen / BlockLen)
  {
    SetCmd6(&Cmd, 0x0A, BlockAdr, MaxDmaLen / BlockLen);
    ret = Out(SetCmd((BYTE *)&Cmd, 6, buffer, MaxDmaLen / BlockLen * BlockLen, 20*200));
    if (ret != 0)
      return ret;
    BlockAdr += MaxDmaLen / BlockLen;
    TransferLen -= MaxDmaLen / BlockLen;
    buffer = (void *)((long)buffer + MaxDmaLen / BlockLen * BlockLen);
  }

  SetCmd6(&Cmd, 0x0A, BlockAdr, TransferLen);
  return Out(SetCmd((BYTE *)&Cmd, 6, buffer, BlockLen * (ULONG)TransferLen, 20*200));
}}}

LONG Write10(ULONG BlockAdr,
                UWORD TransferLen, void *buffer)
{{{
LONG ret;
tCmd10 Cmd;

  while (TransferLen > MaxDmaLen / BlockLen)
  {
    SetCmd10(&Cmd, 0x02A, BlockAdr, MaxDmaLen / BlockLen);
    ret = Out(SetCmd((BYTE *)&Cmd, 10, buffer, MaxDmaLen / BlockLen * BlockLen, 20*200));
    if (ret != 0)
      return ret;
    BlockAdr += MaxDmaLen / BlockLen;
    TransferLen -= MaxDmaLen / BlockLen;
    buffer = (void *)((long)buffer + MaxDmaLen / BlockLen * BlockLen);
  }

  SetCmd10(&Cmd, 0x02A, BlockAdr, TransferLen);
  return Out(SetCmd((BYTE *)&Cmd, 10, buffer, BlockLen * (ULONG)TransferLen, 20*200));
}}}


#define cMaxBlockAdr  0x001FFFFF /* Max. Blocknummer bei Read6/Write6  */


LONG Read(ULONG BlockAdr,
              UWORD TransferLen, void *buffer)
{{{
  if (BlockAdr > cMaxBlockAdr)
    return Read10(BlockAdr, TransferLen, buffer);
  else
    return Read6(BlockAdr, TransferLen, buffer);
}}}


LONG Write(ULONG BlockAdr,
              UWORD TransferLen, void *buffer)
{{{
  if (BlockAdr > cMaxBlockAdr)
    return Write10(BlockAdr, TransferLen, buffer);
  else
    return Write6(BlockAdr, TransferLen, buffer);
}}}



LONG StartStop(BOOLEAN LoadEject, BOOLEAN StartFlag)
{{{
tCmd6 Cmd;

  if (StartFlag)
    SetCmd6(&Cmd, 0x01B,0,1);
  else
    SetCmd6(&Cmd, 0x01B,0,0);

  if (LoadEject)
    Cmd.Len |= 2;

  return In(SetCmd((BYTE *)&Cmd, 6, NULL, 0, 60*200));
}}}


LONG ReadCapacity(BOOLEAN PMI, ULONG *BlockAdr, ULONG *BlockLen)
{{{
ULONG Data[2];
LONG ret;
tCmd10 Cmd;

  SetCmd10(&Cmd, 0x25, *BlockAdr, 0);

  if (PMI)
    Cmd.LenLow = 1;

  /* und rufen */
  ret = In(SetCmd((BYTE *)&Cmd, 10, Data, sizeof(Data), DefTimeout));

  /* und Antwort, bitte */
  if (ret == 0)
  {
    *BlockAdr = Data[0];
    *BlockLen = Data[1];
  }

  return ret;
}}}


BOOLEAN init_scsidisk (void)
{{{
  return TRUE;  /* hier gibts nix zu tun */
}}}

