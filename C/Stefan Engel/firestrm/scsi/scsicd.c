/*{{{}}}*/
/*********************************************************************
 *
 * Kommandos zum Zugriff auf CD-ROMs
 *
 * $Source: /dev/f/kleister.ii/cbhd\RCS\SCSICD.C,v $
 *
 * $Revision: 1.1 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1995/11/13 23:45:52 $
 *
 * $State: Exp $
 *
 **********************************************************************
 * History:
 *
 * $Log: SCSICD.C,v $
 * Revision 1.1  1995/11/13  23:45:52  S_Engel
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
#include <scsicd.h>


LONG PauseResume(BOOLEAN Pause)
{{{
	SetCmd10(0x04B, 0, 0);
	if (Pause)
		Cmd10.LenLow = 0;
	else
		Cmd10.LenLow = 1;

	return In(SetCmd((BYTE*)&Cmd10, 6, NULL, 0, DefTimeout));
}}}


LONG PlayAudio(LONG BlockAdr, LONG TransLength)
{{{
	SetCmd12(0x0A5, BlockAdr, TransLength);
	return In(SetCmd((BYTE *)&Cmd12, 6, NULL, 0, DefTimeout));
}}}


LONG PlayAudioMSF(tMSF Start, tMSF Stop)
{{{
struct
{
	UBYTE Code;
	UBYTE Lun;
	tMSF	Startmsf;
	UBYTE Stopm;
	UBYTE Stops;
	UBYTE Stopf;
	UBYTE Flags;
} Cmd;

	Cmd.Code			= 0x47;
	Cmd.Lun 			= 0;
	Cmd.Startmsf	= Start;
	Cmd.Stopm 		= Stop.M;
	Cmd.Stops 		= Stop.S;
	Cmd.Stopf 		= Stop.F;
	Cmd.Flags 		= 0;

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

	Cmd.Code		= 0x48;
	Cmd.Lun 		= 0;
	Cmd.Res2		= 0;
	Cmd.Res3		= 0;
	Cmd.StartTr = StartTrack % 0x100;
	Cmd.StartIn = StartIndex % 0x100;
	Cmd.StopTr	= EndTrack %	0x100;
	Cmd.StopIn	= EndIndex % 0x100;
	Cmd.Res6		= 0;
	Cmd.Flags 	= 0;

	return In(SetCmd((BYTE *)&Cmd, 10, NULL, 0, DefTimeout));
}}}


LONG PlayAudioRelative(UWORD StartTrack, ULONG RelAdr, ULONG Len)
{{{
	SetCmd12(0xA9, RelAdr, Len);
	Cmd12.Reserved = StartTrack % 0x100;
	return In(SetCmd((BYTE *)&Cmd12, 12, NULL, 0, DefTimeout));
}}}


LONG ReadHeader(BOOLEAN  MSF, ULONG BlockAdr,
									 BYTE 	 *Mode, tMSF *AbsoluteAdr)
{{{
LONG		ret;
tMSF		Data[2];

	SetCmd10(0x44, BlockAdr, sizeof(Data));

	if (MSF)
	{
		Cmd10.Lun = 2;
	}

	ret = In(SetCmd((BYTE *)&Cmd10, 10, (void *)Data, sizeof(Data), DefTimeout));

	*Mode = Data[0].Resrvd;
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
	SetCmd10(0x43, 0, Len);
	if (MSF)
	{
		Cmd10.Lun |= 2;
	}

	Cmd10.Reserved = StartTrack;

	return In(SetCmd((BYTE *)&Cmd10, 10, Buffer, Len, DefTimeout));
}}}

				