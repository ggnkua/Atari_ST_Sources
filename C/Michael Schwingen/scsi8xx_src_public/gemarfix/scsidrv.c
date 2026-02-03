/*
	gcc sichert D2/A2 nicht - global belegen, damit die bei Aufrufen per
	SCSI-Treiber nicht ver„ndert werden
*/
register long _save_a2 __asm__("a2");
register long _save_d2 __asm__("d2");

//#include <string.h>
#include <osbind.h>
#define cdecl
#include "scsidefs.h"
#include <stdio.h>
#include "proto.h"

#define MAX_TRANSFER 0x01000000L

LONG cdecl sd_inquirescsi(WORD what, tBusInfo *Info);
LONG cdecl sd_open(WORD BusNo, const DLONG *SCSIId, ULONG *MaxLen);

LONG cdecl (*old_inquirescsi)  (WORD, tBusInfo *);
LONG cdecl (*old_open)         (WORD, const DLONG *, ULONG *);

/**************************************************************************/
LONG cdecl sd_inquirescsi(WORD what, tBusInfo *Info)
{
	LONG status;
	status = old_inquirescsi(what, Info);
	if(Info->MaxLen > MAX_TRANSFER)
		Info->MaxLen = MAX_TRANSFER;
	return status;
}

/**************************************************************************/
LONG cdecl sd_open(WORD BusNo, const DLONG *SCSIId, ULONG *MaxLen)
{
	LONG status;

	status = old_open(BusNo, SCSIId, MaxLen);
	if (MaxLen && *MaxLen > MAX_TRANSFER)
		*MaxLen = MAX_TRANSFER;
	return status;
}

/**************************************************************************/
extern ULONG _PgmSize;

int main(void)
{
	ULONG old_ssp;
	tScsiCall *cookie;

	bprintf("Gemar-FIX V1.1 (C) 1998 M. Schwingen\n");

	old_ssp = Super(0l);
	cookie = GetSCSICookie();
	Super(old_ssp);

	if(!cookie)
	{
		bprintf("No SCSI cookie found. GEMAR fix not installed.\n");
		return 0;
	}
	if(cookie->Version < 0x0100)
	{
		bprintf("Wrong SCSI cookie version $%04X. GEMAR fix not installed.\n",
			cookie->Version);
		return 0;
	}

	bprintf("Installing GEMAR fix: MaxTransferLen limited to %lu.\n", MAX_TRANSFER);
	old_inquirescsi = cookie->InquireSCSI;
	old_open = cookie->Open;
	cookie->Open = sd_open;
	cookie->InquireSCSI = sd_inquirescsi;

	Ptermres(_PgmSize, 0);
	return 0;
}
