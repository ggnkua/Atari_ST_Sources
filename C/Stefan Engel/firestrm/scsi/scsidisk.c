/*{{{}}}*/
/*********************************************************************
 *
 * Kommandos zum Zugriff auf Platten
 *
 * $Source: /dev/f/kleister.ii/cbhd\RCS\SCSIDISK.C,v $
 *
 * $Revision: 1.1 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1995/11/13 23:45:30 $
 *
 * $State: Exp $
 *
 **********************************************************************
 * History:
 *
 * $Log: SCSIDISK.C,v $
 * Revision 1.1  1995/11/13  23:45:30  S_Engel
 * Initial revision
 *
 *
 *
 *********************************************************************/

#include <import.h>
#include <portab.h>

#include <scsiio.h>
#include <scsi.h>

#include <export.h>
#include <scsidisk.h>


LONG Read6(ULONG BlockAdr,
                UWORD TransferLen, void *buffer)
{{{
LONG ret;

  while (TransferLen > MaxDmaLen / BlockLen)
  {
    SetCmd6(0x08, BlockAdr, MaxDmaLen / BlockLen);
    ret = In(SetCmd((BYTE *)&Cmd6, 6, buffer, MaxDmaLen / BlockLen * BlockLen, DefTimeout));
    if (ret != 0)
      return ret;

    BlockAdr += MaxDmaLen / BlockLen;
    TransferLen -= MaxDmaLen / BlockLen;
    buffer = (void *)((long)buffer + MaxDmaLen / BlockLen * BlockLen);
  }

  SetCmd6(0x08, BlockAdr, TransferLen);
  return In(SetCmd((BYTE *)&Cmd6, 6, buffer, BlockLen * (ULONG)TransferLen, DefTimeout));
}}}

LONG Read10(ULONG BlockAdr,
                UWORD TransferLen, void *buffer)
{{{
LONG ret;

  while (TransferLen > MaxDmaLen / BlockLen)
  {
    SetCmd10(0x028, BlockAdr, MaxDmaLen / BlockLen);
    ret = In(SetCmd((BYTE *)&Cmd10, 10, buffer, MaxDmaLen / BlockLen * BlockLen, 20*200));
    if (ret != 0)
      return ret;
    BlockAdr += MaxDmaLen / BlockLen;
    TransferLen -= MaxDmaLen / BlockLen;
    buffer = (void *)((long)buffer + MaxDmaLen / BlockLen * BlockLen);
  }

  SetCmd10(0x028, BlockAdr, TransferLen);
  return In(SetCmd((BYTE *)&Cmd10, 10, buffer, BlockLen * (ULONG)TransferLen, 20*200));
}}}


LONG Write6(ULONG BlockAdr,
                UWORD TransferLen, void *buffer)
{{{
LONG ret;

  while (TransferLen > MaxDmaLen / BlockLen)
  {
    SetCmd6(0x0A, BlockAdr, MaxDmaLen / BlockLen);
    ret = Out(SetCmd((BYTE *)&Cmd6, 6, buffer, MaxDmaLen / BlockLen * BlockLen, 20*200));
    if (ret != 0)
      return ret;
    BlockAdr += MaxDmaLen / BlockLen;
    TransferLen -= MaxDmaLen / BlockLen;
    buffer = (void *)((long)buffer + MaxDmaLen / BlockLen * BlockLen);
  }

  SetCmd6(0x0A, BlockAdr, TransferLen);
  return Out(SetCmd((BYTE *)&Cmd6, 6, buffer, BlockLen * (ULONG)TransferLen, 20*200));
}}}

LONG Write10(ULONG BlockAdr,
                UWORD TransferLen, void *buffer)
{{{
LONG ret;

  while (TransferLen > MaxDmaLen / BlockLen)
  {
    SetCmd10(0x02A, BlockAdr, MaxDmaLen / BlockLen);
    ret = Out(SetCmd((BYTE *)&Cmd10, 10, buffer, MaxDmaLen / BlockLen * BlockLen, 20*200));
    if (ret != 0)
      return ret;
    BlockAdr += MaxDmaLen / BlockLen;
    TransferLen -= MaxDmaLen / BlockLen;
    buffer = (void *)((long)buffer + MaxDmaLen / BlockLen * BlockLen);
  }

  SetCmd10(0x02A, BlockAdr, TransferLen);
  return Out(SetCmd((BYTE *)&Cmd10, 10, buffer, BlockLen * (ULONG)TransferLen, 20*200));
}}}


#define cMaxBlockAdr  0x003FFFFF /* Max. Blocknummer bei Read6/Write6  */


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

  if (StartFlag)
    SetCmd6(0x01B,0,1);
  else
    SetCmd6(0x01B,0,0);

  if (LoadEject)
    Cmd6.Len |= 1;

  return In(SetCmd((BYTE *)&Cmd6, 6, NULL, 0, 60*200));
}}}


LONG ReadCapacity(BOOLEAN PMI, ULONG *BlockAdr, ULONG *BlockLen)
{{{
ULONG Data[2];
LONG ret;

  SetCmd10(0x25, *BlockAdr, 0);

  if (PMI)
    Cmd10.LenLow = 1;

  /* und rufen */
  ret = In(SetCmd((BYTE *)&Cmd10, 10, Data, sizeof(Data), DefTimeout));

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

