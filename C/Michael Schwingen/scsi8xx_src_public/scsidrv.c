/***************************************************************************
 *   Copyright (C) 1998-1999 Michael Schwingen                             *
 *   michael@schwingen.org                                                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.           *
 ***************************************************************************/
/*
	gcc sichert D2/A2 nicht - global belegen, damit die bei Aufrufen per
	SCSI-Treiber nicht ver„ndert werden */
register long _save_a2 __asm__("a2");
register long _save_d2 __asm__("d2");

#define LEAVE if(1) {goto func_exit;}

#define TIMEOUT (10L*200L)

#include <string.h>
#include <osbind.h>
#define cdecl
#include "scsidefs.h"
#include <stdio.h>
#include "proto.h"
#include "scsi.h"
#include "globals.h"

#define EINVHDL -1
#define ENMHDL -1
#define EDRIVNR -2
#define EUNDEV -15
#define EACCDN -36

#define MAX_TRANSFER (512L*1024L*1024L)

#define FEATURES (cArbit | cAllCmds | cTargCtrl | cScatterGather)

#define NUM_HANDLES 100

struct HANDLE
{
	UWORD Features;
	UWORD bus;
	UWORD id;
	UWORD errors;
	UBYTE used;
};

struct HANDLE handles[NUM_HANDLES];

LONG cdecl unimpl(void);
LONG cdecl sd_in(tpSCSICmd Parms);
LONG cdecl sd_out(tpSCSICmd Parms);
LONG cdecl sd_inquirescsi(WORD what, tBusInfo *Info);
LONG cdecl sd_inquirebus(WORD what, WORD BusNo, tDevInfo *Dev);
LONG cdecl sd_checkdev(WORD BusNo, const DLONG *SCSIId, char *Name, UWORD *Features);
LONG cdecl sd_rescanbus(WORD BusNo);
LONG cdecl sd_open(WORD BusNo, const DLONG *SCSIId, ULONG *MaxLen);
LONG cdecl sd_close(tHandle handle);
LONG cdecl sd_error(tHandle handle, WORD rwflag, WORD ErrNo);

LONG cdecl unimpl(void)
{
	return -1;
}


tScsiCall old_scsi_cookie;
tScsiCall my_scsi_cookie = {
	0x0101,	/* version */
	sd_in,
	sd_out,
	sd_inquirescsi,
	sd_inquirebus,
	sd_checkdev,
	sd_rescanbus,
	sd_open,
	sd_close,
	sd_error,
	(LONG(*)(WORD,tpTargetHandler)) unimpl, /* Install */
	(LONG(*)(WORD,tpTargetHandler)) unimpl, /* Deinstall */
	(LONG(*)(WORD,BYTE *)) unimpl,          /* GetCmd */
	(LONG(*)(WORD,BYTE *, ULONG)) unimpl,   /* SendData */
	(LONG(*)(WORD,void *, ULONG)) unimpl,   /* GetData */
	(LONG(*)(WORD,UWORD)) unimpl,           /* SendStatus */
	(LONG(*)(WORD,UWORD)) unimpl,           /* SendMsg */
	(LONG(*)(WORD,UWORD *)) unimpl,         /* GetMsg */
	0
};

int my_busno = 0;

/**************************************************************************/
LONG cdecl sd_inquirescsi(WORD what, tBusInfo *Info)
{
	dprintf(DB_SD,"inquirescsi: %d, BusIds $%08lX\n",what, Info->Private.BusIds);
	if (what == cInqFirst)
	{
		Info->Private.BusIds = 0;
	}
	if ((Info->Private.BusIds & (1L<<my_busno)) == 0)
	{
		Info->Private.BusIds |= 1L<<my_busno;
		sprintf(Info->BusName,"SymSCSI%d",0);
		Info->BusNo = my_busno;
		Info->Features = FEATURES;
		Info->MaxLen = MAX_TRANSFER;
		return 0;
	}
	if(old_scsi_cookie.InquireSCSI)
		return old_scsi_cookie.InquireSCSI(what, Info);
	return -1;
}

/**************************************************************************/
LONG cdecl sd_inquirebus(WORD what, WORD BusNo, tDevInfo *Dev)
{
	int i;
	
	dprintf(DB_SD,"inquirebus: Bus %d, what=%d",BusNo, what);
	if (BusNo != my_busno)
	{
		if(old_scsi_cookie.InquireBus)
		{
			LONG ret = old_scsi_cookie.InquireBus(what, BusNo, Dev);
			dprintf(DB_SD,"-> return %ld, ID %ld\n",ret,Dev->SCSIId.lo);
			return ret;
		}
		else
			return -1;
	}
	if (what == cInqFirst)
	{
		Dev->SCSIId.hi = 0;
		Dev->last_id = 0;
	}
	for(i=Dev->last_id; i<MAX_DEVICE; i++)
		if(dev_flags[i].DeviceOK)
		{
			Dev->last_id = i+1;
			Dev->SCSIId.lo = i;
			dprintf(DB_SD,"-> return 0, ID %ld\n",Dev->SCSIId.lo);
			return 0;
		}
	dprintf(DB_SD,"-> return -1\n");
	return -1; /* keine weiteren Devices */
}
/**************************************************************************/

static UBYTE test_unit_ready[] = { 0,0,0,0,0,0 };
static UBYTE inquiry[] = { 0x12,0,0,0,36,0 };
static UBYTE start_stop[] = { 0x1B, 0, 0, 0, 1, 0 };

/**************************************************************************/
LONG cdecl sd_checkdev(WORD BusNo, const DLONG *SCSIId, char *Name, UWORD *Features)
{
	int id;
	LONG ret;

	dprintf(DB_SD,"checkdev: Bus %d, id %ld",BusNo, SCSIId->lo);
	if (BusNo != my_busno)
	{
		if(old_scsi_cookie.CheckDev)
			ret = old_scsi_cookie.CheckDev(BusNo, SCSIId, Name, Features);
		else
			ret = -1;
		dprintf(DB_SD," -> %d\n",ret);
		return ret;
	}
	
	id = SCSIId->lo;
	
	if (SCSIId->hi || id > MAX_DEVICE)
	{
		dprintf(DB_SD," -> -1\n");
		return -1;
	}

	if ( !dev_flags[id].DeviceOK)
	{
		int result;
		UBYTE buffer[40];
		
		result = DoCommand(id, test_unit_ready, buffer, 0, TIMEOUT);
		if (result == 2)
			result = DoCommand(id, test_unit_ready, buffer, 0, TIMEOUT);
		dev_flags[id].DeviceOK = (result >= 0);
		if(!dev_flags[id].DeviceOK)
		{
			dprintf(DB_SD," -> -1\n");
			return -1;
		}
	}
	
	sprintf(Name,"SymSCSI%d",0);
	*Features = FEATURES;
	dprintf(DB_SD," -> 0\n");
	return 0;
}

static UBYTE request_sense[] = { 0x03, 0x00, 0x00, 0x00, 18, 0x00 };
/**************************************************************************/
LONG cdecl sd_rescanbus(WORD BusNo)
{
	int id;
	static int did_print = 0;

	dprintf(DB_SD,"rescanbus: Bus %d\n",BusNo);	
	if (BusNo != my_busno)
	{
		if(old_scsi_cookie.RescanBus)
			return old_scsi_cookie.RescanBus(BusNo);
		else
			return -1;
	}
	
	for(id=0; id<=MAX_DEVICE; id++)
		dev_flags[id].DeviceOK = 1;

	for(id=0; id<MAX_DEVICE; id++)
	{
		int result, do_start = 0;
		UBYTE buffer[40];
		
		if((1<<id) & scsi_scan_mask)
		{
			result = DoCommand(id, test_unit_ready, buffer, 0, TIMEOUT);
			if (result == STAT_CHECK_COND)
				result = DoCommand(id, test_unit_ready, buffer, 0, TIMEOUT);
			dev_flags[id].DeviceOK = (result >= 0);
			if (result == STAT_CHECK_COND)
			{
				int stat2;
				memset(buffer, 0x00, 18);
				stat2 = (int) DoCommand(id, request_sense, buffer, 18, TIMEOUT);
				dprintf(DB_SD,"REQSENSE: status $%02X, error code $%02X, key $%02X, ASC $%02X, ASCQ $%02X\n",
				          stat2, buffer[0], buffer[2] & 15, buffer[12], buffer[13]);
		
				if (stat2 == 0 && buffer[0] == 0x70 && buffer[12] == 0x4) /* NOT READY */
					do_start = 1;
			}
			if(dev_flags[id].DeviceOK)
			{
				if (did_print == 0)
				{
					result = DoCommand(id, inquiry, buffer, 36, TIMEOUT);
					buffer[0x20] = 0;
					if(result < 0)
					{
						buffer[8] = '?';
						buffer[9] = 0;
					}
					bprintf("ID%d: '%s'", id, buffer+8);
					if ((buffer[0] & 15) == 0 && do_start) /* direct access device */
					{
						bprintf("  sending START UNIT ... ");
						result = DoCommand(id, start_stop, buffer, 0, 60*200L);
						bprintf(result == 0 ? "OK\n" : "TIMEOUT!\n");
					}
					bprintf("\n");
				}
			}
		}
	}
	did_print = 1;
	return 0;
}

/**************************************************************************/
LONG cdecl sd_open(WORD BusNo, const DLONG *SCSIId, ULONG *MaxLen)
{
	UWORD id;
	int i;
	LONG result;

	dprintf(DB_SD,"open: Bus %d, ID %ld -> ",BusNo, SCSIId->lo);
	if (BusNo != my_busno)
	{
		if(old_scsi_cookie.Open)
		{
			result = old_scsi_cookie.Open(BusNo, SCSIId, MaxLen);
			LEAVE;
		}
		else
		{
			result = -1;
			LEAVE;
		}
	}
	if (SCSIId->hi || SCSIId->lo > MAX_DEVICE)
	{
		dprintf(DB_SD,"open: unknown ID $%lX:%lX\n",SCSIId->hi, SCSIId->lo);
		result = EUNDEV;
		LEAVE;
	}
	id = (UWORD)  SCSIId->lo;
	if ( !dev_flags[id].DeviceOK)
	{
		result = EUNDEV;
		LEAVE;
	}

	for(i=0; i<NUM_HANDLES; i++)
		if( !handles[i].used)
		{
			handles[i].Features = FEATURES;
			handles[i].bus = BusNo;
			handles[i].id = id;
			handles[i].errors = 0;
			handles[i].used=1;
			if (MaxLen)
				*MaxLen = MAX_TRANSFER;
			result = (LONG)(&handles[i]);
			LEAVE;
		}
	result = ENMHDL;
func_exit:
	dprintf(DB_SD,"return %ld\n",result);
	return result;
}

/**************************************************************************/
LONG cdecl sd_close(tHandle handle)
{
	dprintf(DB_SD,"close: handle %p\n",handle);
	if (handle < handles || handle > &handles[NUM_HANDLES])
	{
		if(old_scsi_cookie.Close)
			return old_scsi_cookie.Close(handle);
		else
			return EINVHDL;
	}
	if(handle->used)
	{
		handle->used = 0;
		return 0;
	}
	return -1;
}

/**************************************************************************/
LONG cdecl sd_error(tHandle handle, WORD rwflag, WORD ErrNo)
{
	int i;
	UWORD mask = 1 << ErrNo;
	dprintf(DB_SD,"sd_error: handle %p, rw %d, errno %d\n",handle, rwflag, ErrNo);
	if (handle < handles || handle > &handles[NUM_HANDLES])
	{
		if(old_scsi_cookie.Error)
		{
			UWORD status;
			status = old_scsi_cookie.Error(handle, rwflag, ErrNo);
			dprintf(DB_SD,"chain: return $%04x\n",status);
			return status;
		}
		else
			return EINVHDL;
	}
	if (rwflag == cErrRead)
	{
		UWORD status = handle->errors;
		handle->errors = 0;
		dprintf(DB_SD,"return $%04x\n",status);
		return status;
	}
	for(i = 0; i < NUM_HANDLES; i++)
	{
		if(handles[i].used && 
		   handles[i].id == handle->id && 
		   handles[i].bus == handle->bus &&
		   &handles[i] != handle)
		{
			handles[i].errors |= mask;
		}
	}
	return 0;
}

/* called by lowlevel driver whenever a bus reset was executed */
void post_busreset(void)
{
	int i;
	for(i = 0; i < NUM_HANDLES; i++)
	{
		if(handles[i].used)
			handles[i].errors |= cErrReset;
	}
}

/**************************************************************************/

LONG cdecl sd_in(tpSCSICmd p)
{
	LONG result;
	
	dprintf(DB_SD,"IN: param at %p, handle %p, cmd %02X %02X %02X %02X %02X %02X, count %ld\n",
	        p, p->Handle, p->Cmd[0],p->Cmd[1],p->Cmd[2],p->Cmd[3],p->Cmd[4],p->Cmd[5],
	        p->TransferLen);

	if (p->Handle < handles || p->Handle > &handles[NUM_HANDLES] || !p->Handle->used)
	{
		if(old_scsi_cookie.In)
		{
			dprintf(DB_SD,"chain to old handler:");
			result = old_scsi_cookie.In(p);
			LEAVE;
		}
		else
		{
			result = EINVHDL;
			LEAVE;
		}
	}

	if (p->TransferLen > MAX_TRANSFER)
	{
		result = DATATOOLONG;
		LEAVE;
	}
	
	if(p->Handle->errors)
	{
		dprintf(DB_SD,"pending error!\n");
		result = PENDINGERROR;
		LEAVE;
	}
		
	result = DoCommand(p->Handle->id, p->Cmd, p->Buffer, p->TransferLen, p->Timeout);	

	if (result == STAT_CHECK_COND && p->SenseBuffer)
	{
		int stat2;
		memset(p->SenseBuffer, 0x00, 18);
		stat2 = (int) DoCommand(p->Handle->id, request_sense, p->SenseBuffer, 18, TIMEOUT);
		dprintf(DB_SD,"REQSENSE: status $%02X, error code $%02X, key $%02X, ASC $%02X, ASCQ $%02X\n",
		          stat2, p->SenseBuffer[0], p->SenseBuffer[2] & 15, p->SenseBuffer[12], p->SenseBuffer[13]);

		if (stat2 == 0 && p->SenseBuffer[0] == 0x70 &&
		    p->SenseBuffer[12] == 0x28 && p->SenseBuffer[0x13] == 0x00)
		{
			dprintf(DB_SD,"force Mediach: ");
			sd_error(p->Handle, 1, 0);
		}
		if(stat2 == 0 && p->SenseBuffer[0] == 0x70 &&
		   p->SenseBuffer[12] == 0x29 && p->SenseBuffer[0x13] == 0x00)
		{
			dprintf(DB_SD,"force Reset: ");
			sd_error(p->Handle, 1, 1);
		}
	}
func_exit:
	dprintf(DB_SD,"-> return %ld\n",result);
	return result;
}

/**************************************************************************/

LONG cdecl sd_out(tpSCSICmd p)
{
	LONG result;
	
	dprintf(DB_SD,"OUT: param at %p, handle %p, cmd %02X %02X %02X %02X %02X %02X, count %ld\n",
	        p, p->Handle, p->Cmd[0],p->Cmd[1],p->Cmd[2],p->Cmd[3],p->Cmd[4],p->Cmd[5],
	        p->TransferLen);

	if (p->Handle < handles || p->Handle > &handles[NUM_HANDLES] || !p->Handle->used)
	{
		if(old_scsi_cookie.Out)
		{
			dprintf(DB_SD,"chain to old handler:");
			result = old_scsi_cookie.Out(p);
			LEAVE;
		}
		else
		{
			result = EINVHDL;
			LEAVE;
		}
	}

	if (p->TransferLen > MAX_TRANSFER)
	{
		result = DATATOOLONG;
		LEAVE;
	}
	
	if(p->Handle->errors)
	{
		dprintf(DB_SD,"pending error!\n");
		result = PENDINGERROR;
		LEAVE;
	}
		
	result = DoCommand(p->Handle->id, p->Cmd, p->Buffer, p->TransferLen, p->Timeout);	

	if (result == STAT_CHECK_COND && p->SenseBuffer)
	{
		int stat2;
		memset(p->SenseBuffer, 0x00, 18);
		stat2 = (int) DoCommand(p->Handle->id, request_sense, p->SenseBuffer, 18, TIMEOUT);
		dprintf(DB_SD,"REQSENSE: status $%02X, error code $%02X, key $%02X, ASC $%02X, ASCQ $%02X\n",
		          stat2, p->SenseBuffer[0], p->SenseBuffer[2] & 15, p->SenseBuffer[12], p->SenseBuffer[13]);

		if (stat2 == 0 && p->SenseBuffer[0] == 0x70 &&
		    p->SenseBuffer[12] == 0x28 && p->SenseBuffer[0x13] == 0x00)
		{
			dprintf(DB_SD,"force Mediach: ");
			sd_error(p->Handle, 1, 0);
		}
		if(stat2 == 0 && p->SenseBuffer[0] == 0x70 &&
		   p->SenseBuffer[12] == 0x29 && p->SenseBuffer[0x13] == 0x00)
		{
			dprintf(DB_SD,"force Reset: ");
			sd_error(p->Handle, 1, 1);
		}
	}
func_exit:
	dprintf(DB_SD,"-> return %ld\n",result);
	return result;
}

#if 0 /* old version */
/**************************************************************************/
LONG cdecl sd_out(tpSCSICmd p)
{
	long status;
	
	if (p->Handle < handles || p->Handle > &handles[NUM_HANDLES] || !p->Handle->used)
	{
		if(old_scsi_cookie.Out)
		{
			LONG ret;
			dprintf(DB_SD,"OUT: cmd %02X %02X %02X %02X %02X %02X, count %ld",
			        p->Cmd[0],p->Cmd[1],p->Cmd[2],p->Cmd[3],p->Cmd[4],p->Cmd[5],
			        p->TransferLen);
			ret = old_scsi_cookie.Out(p);
			dprintf(DB_SD," -> %d\n",ret);
			return ret;
		}
		else
			return EINVHDL;
	}

	if (p->TransferLen > MAX_TRANSFER)
		return DATATOOLONG;
	
	if(p->Handle->errors)
	{
		dprintf(DB_SD,"pending error!\n");
		return PENDINGERROR;
	}
		
	status = DoCommand(p->Handle->id, p->Cmd, p->Buffer, p->TransferLen, p->Timeout);	

	if (status == STAT_CHECK_COND && p->SenseBuffer)
	{
		int stat2;
		memset(p->SenseBuffer, 0x00, 18);
		stat2 = (int) DoCommand(p->Handle->id, request_sense, p->SenseBuffer, 18, TIMEOUT);
		dprintf(DB_SD,"REQSENSE: status $%02X, error code $%02X, key $%02X, ASC $%02X, ASCQ $%02X\n",
		          stat2, p->SenseBuffer[0], p->SenseBuffer[2] & 15, p->SenseBuffer[12], p->SenseBuffer[13]);

		if (stat2 == 0 && p->SenseBuffer[0] == 0x70 &&
		    p->SenseBuffer[12] == 0x28 && p->SenseBuffer[0x13] == 0x00)
		{
			dprintf(DB_SD,"force Mediach: ");
			sd_error(p->Handle, 1, 0);
		}
		if(stat2 == 0 && p->SenseBuffer[0] == 0x70 &&
		   p->SenseBuffer[12] == 0x29 && p->SenseBuffer[0x13] == 0x00)
		{
			dprintf(DB_SD,"force Reset: ");
			sd_error(p->Handle, 1, 1);
		}
	}
	return status;
}
#endif

/**************************************************************************/
LONG sd_init(void)
{
	tBusInfo businfo;
	UBYTE used_buses[MAXBUSNO+1];
	LONG ret;
	int i;

	memset(&old_scsi_cookie, 0x00, sizeof(old_scsi_cookie));
	memset(&used_buses, 0x00, sizeof(used_buses));
	
	if(Install_SCSI(sizeof(my_scsi_cookie)))
	{
		bprintf("found old SCSI cookie.\n");
		ret = old_scsi_cookie.InquireSCSI(cInqFirst, &businfo);
		while (ret == 0)
		{
			bprintf("Scan Bus: Bus #%d = '%s', Features $%04X, MaxLen $%lX\n",
				businfo.BusNo, businfo.BusName, businfo.Features, businfo.MaxLen);
			used_buses[businfo.BusNo] = 1;
			ret = old_scsi_cookie.InquireSCSI(cInqNext, &businfo);
		}
	}

	for(i=1; i<MAXBUSNO; i++)
		if(used_buses[i] == 0)
		{
			my_busno = i;
			break;
		}
	bprintf("using bus number %d, SCSI ID %d\n",my_busno, my_scsi_id);

	memset(&handles, 0, sizeof(handles));
	return sd_rescanbus(my_busno);
}


