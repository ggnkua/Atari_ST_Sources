/*
	SCSI functions

	Copyright (C) 2002	Patrice Mandin

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/

#include <stdio.h>
#include <stdlib.h>

#include "scsidrv.h"
#include "scsi.h"

/*--- Defines ---*/

/* The SCSI operation codes */

/* All devices */

	/* Mandatory functions */
#define SCSI_CMD_INQUIRY		0x12
#define SCSI_CMD_REQUESTSENSE	0x03
#define SCSI_CMD_SENDDIAGNOSTIC	0x1d
#define SCSI_CMD_TESTUNITREADY	0x00

	/* Optional functions */
#define SCSI_CMD_CHANGEDEFINITION			0x40
#define SCSI_CMD_COMPARE					0x39
#define SCSI_CMD_COPY						0x18
#define SCSI_CMD_COPYANDVERIFY				0x3a
#define SCSI_CMD_LOGSELECT					0x4c
#define SCSI_CMD_LOGSENSE					0x4d
#define SCSI_CMD_READBUFFER					0x3c
#define SCSI_CMD_RECEIVEDIAGNOSTICRESULTS	0x1c
#define SCSI_CMD_WRITEBUFFER				0x3b

	/* Device specific functions */
#define SCSI_CMD_MODESELECT6	0x15
#define SCSI_CMD_MODESELECT10	0x55
#define SCSI_CMD_MODESENSE6		0x1a
#define SCSI_CMD_MODESENSE10	0x5a

/* Direct access devices */

	/* Mandatory functions */
#define SCSI_CMD_FORMATUNIT		0x04
#define SCSI_CMD_READ6			0x08
#define SCSI_CMD_READ10			0x28
#define SCSI_CMD_READCAPACITY	0x25
#define SCSI_CMD_RELEASE		0x17
#define SCSI_CMD_RESERVE		0x16

	/* Optional functions */
#define SCSI_CMD_LOCKUNLOCKCACHE			0x36
#define SCSI_CMD_PREFETCH					0x34
#define SCSI_CMD_PREVENTALLOWMEDIUMREMOVAL	0x1e
#define SCSI_CMD_READDEFECTDATA				0x37
#define SCSI_CMD_READLONG					0x3e
#define SCSI_CMD_REASSIGNBLOCKS				0x07
#define SCSI_CMD_REZEROUNIT					0x01
#define SCSI_CMD_SEARCHDATAEQUAL			0x31
#define SCSI_CMD_SEARCHDATAHIGH				0x30
#define SCSI_CMD_SEARCHDATALOW				0x32
#define SCSI_CMD_SEEK6						0x0b
#define SCSI_CMD_SEEK10						0x2b
#define SCSI_CMD_SETLIMITS10				0x33
#define SCSI_CMD_STARTSTOPUNIT				0x1b
#define SCSI_CMD_SYNCHRONIZECACHE			0x35
#define SCSI_CMD_VERIFY10					0x2f
#define SCSI_CMD_WRITE6						0x0a
#define SCSI_CMD_WRITE10					0x2a
#define SCSI_CMD_WRITEANDVERIFY10			0x2e
#define SCSI_CMD_WRITELONG					0x3f
#define SCSI_CMD_WRITESAME					0x41

/* Sequential access devices */

	/* Mandatory functions */
#define SCSI_CMD_ERASE				0x19
#define SCSI_CMD_READ_SA			0x08
#define SCSI_CMD_READBLOCKLIMITS	0x05
#define SCSI_CMD_REWIND				0x01
#define SCSI_CMD_SPACE				0x11
#define SCSI_CMD_WRITE				0x0a
#define SCSI_CMD_WRITEFILEMARKS		0x10

	/* Optional functions */
#define SCSI_CMD_LOADUNLOAD				0x1b
#define SCSI_CMD_LOCATE					0x2b
#define SCSI_CMD_READPOSITION			0x34
#define SCSI_CMD_READREVERSE			0x0f
#define SCSI_CMD_RECOVERBUFFEREDDATA	0x14
#define SCSI_CMD_VERIFY6				0x13

/* Printer devices */

	/* Mandatory functions */
#define SCSI_CMD_PRINT	0x0a

	/* Optional functions */
#define SCSI_CMD_FORMAT				0x04
#define SCSI_CMD_SLEWANDPRINT		0x0b
#define SCSI_CMD_STOPPRINT			0x1b
#define SCSI_CMD_SYNCHRONIZEBUFFER	0x10

/* Processor devices */

	/* Mandatory functions */
#define SCSI_CMD_SEND_PROC	0x0a

	/* Optional functions */
#define SCSI_CMD_RECEIVE	0x08

/* Write-once devices */

	/* Mandatory functions */

	/* Optional functions */

/* CD-ROM devices */

	/* Mandatory functions */
#define SCSI_CMD_READCDROMCAPACITY	0x25

	/* Optional functions */
#define SCSI_CMD_PAUSERESUME				0x4b
#define SCSI_CMD_PLAYAUDIO10				0x45
#define SCSI_CMD_PLAYAUDIO12				0xa5
#define SCSI_CMD_PLAYAUDIOMSF				0x47
#define SCSI_CMD_PLAYAUDIOTRACKINDEX		0x48
#define SCSI_CMD_PLAYAUDIOTRACKRELATIVE10	0x49
#define SCSI_CMD_PLAYAUDIOTRACKRELATIVE12	0xa9
#define SCSI_CMD_READHEADER					0x44
#define SCSI_CMD_READSUBCHANNEL				0x42
#define SCSI_CMD_READTOC					0x43

/* Scanner devices */

	/* Mandatory functions */
#define SCSI_CMD_READ_SCAN	0x28
#define SCSI_CMD_SETWINDOW	0x24

	/* Optional functions */
#define SCSI_CMD_GETDATABUFFERSTATUS	0x34
#define SCSI_CMD_GETWINDOW				0x25
#define SCSI_CMD_OBJECTPOSITION			0x31
#define SCSI_CMD_SCAN					0x1b
#define SCSI_CMD_SEND_SCAN				0x2a

/* Optical memory devices */

	/* Mandatory functions */

	/* Optional functions */
#define SCSI_CMD_ERASE10			0x2c
#define SCSI_CMD_ERASE12			0xac
#define SCSI_CMD_MEDIUMSCAN			0x38
#define SCSI_CMD_READ12				0xa8
#define SCSI_CMD_READDEFECTDATA12	0xb7
#define SCSI_CMD_READGENERATION		0x29
#define SCSI_CMD_READUPDATEDBLOCK	0x2d
#define SCSI_CMD_SEARCHDATAEQUAL12	0xb1
#define SCSI_CMD_SEARCHDATAHIGH12	0xb0
#define SCSI_CMD_SEARCHDATALOW12	0xb2
#define SCSI_CMD_SETLIMITS12		0xb3
#define SCSI_CMD_UPDATEBLOCK		0x3d
#define SCSI_CMD_VERIFY12			0xaf
#define SCSI_CMD_WRITE12			0xaa
#define SCSI_CMD_WRITEANDVERIFY12	0xae

/* Medium-changer devices */

	/* Mandatory functions */
#define SCSI_CMD_MOVEMEDIUM	0xa5

	/* Optional functions */
#define SCSI_CMD_EXCHANGEMEDIUM				0xa6
#define SCSI_CMD_INITIALIZEELEMENTSTATUS	0x07
#define SCSI_CMD_POSITIONTOELEMENT			0x2b
#define SCSI_CMD_READELEMENTSTATUS			0xb8
#define SCSI_CMD_SENDVOLUMETAG				0x16

/* Communication devices */

	/* Mandatory functions */
#define SCSI_CMD_SENDMESSAGE6	0x0a

	/* Optional functions */
#define SCSI_CMD_GETMESSAGE6	0x08
#define SCSI_CMD_GETMESSAGE10	0x28
#define SCSI_CMD_GETMESSAGE12	0xa8
#define SCSI_CMD_SENDMESSAGE10	0x2a
#define SCSI_CMD_SENDMESSAGE12	0xaa

/*--- Types ---*/

typedef struct {
	unsigned char operation;
	unsigned char lun;		/* bit 7-5 are lun bits */
							/* bit 4-0 are bits 20-16 of block address */
	unsigned short block;	/* bits 15-0 of block address, big endian */
	unsigned char length;
	unsigned char control;
} scsi_cmd6_t __attribute__((packed));

typedef struct {
	unsigned char operation;
	unsigned char lun;
	unsigned long block;	/* big endian */
	unsigned char reserved;
	unsigned short length;	/* big endian */
	unsigned char control;
} scsi_cmd10_t __attribute__((packed));

typedef struct {
	unsigned char operation;
	unsigned char lun;
	unsigned long block;	/* big endian */
	unsigned long length;	/* big endian */
	unsigned char reserved;
	unsigned char control;
} scsi_cmd12_t __attribute__((packed));

/*--- Variables ---*/

unsigned char scsi_SenseBuffer[18];

/*--- Functions prototypes ---*/

static void scsi_initcmd(scsi_cmd_t *command, void *scsi_cmd, int scsi_cmd_len, scsi_device_t *dev, void *data);
static void scsi_initcmd6(scsi_cmd6_t *command, unsigned char op, unsigned char lun, unsigned long block, unsigned char length, unsigned char control);
static void scsi_initcmd10(scsi_cmd10_t *command, unsigned char op, unsigned char lun, unsigned long block, unsigned short length, unsigned char control);
static void scsi_initcmd12(scsi_cmd12_t *command, unsigned char op, unsigned char lun, unsigned long block, unsigned long length, unsigned char control);

/*--- Functions ---*/

/* some utility functions */
static void scsi_initcmd(scsi_cmd_t *command, void *scsi_cmd, int scsi_cmd_len, scsi_device_t *dev, void *data)
{
	command->handle = dev->handle;
	command->cmd = scsi_cmd;
	command->cmdlen = scsi_cmd_len;
	command->buffer = data;
	command->transferlen = dev->maxlen;
	command->sensebuffer = scsi_SenseBuffer;
	command->timeout = dev->timeout;
	command->flags = 0;
}

static void scsi_initcmd6(scsi_cmd6_t *command, unsigned char op, unsigned char lun, unsigned long block, unsigned char length, unsigned char control)
{
	command->operation = op;
	command->lun = (lun & 7)<<5;
	command->lun |= (block>>16) & ((1<<5)-1);
	command->block = block & ((1<<16)-1);
	command->length = length;
	command->control = control;
}

static void scsi_initcmd10(scsi_cmd10_t *command, unsigned char op, unsigned char lun, unsigned long block, unsigned short length, unsigned char control)
{
	command->operation = op;
	command->lun = (lun & 7)<<5;
	command->block = block;
	command->reserved = 0;
	command->length = length;
	command->control = control;
}

static void scsi_initcmd12(scsi_cmd12_t *command, unsigned char op, unsigned char lun, unsigned long block, unsigned long length, unsigned char control)
{
	command->operation = op;
	command->lun = (lun & 7)<<5;
	command->block = block;
	command->length = length;
	command->reserved = 0;
	command->control = control;
}

/*--- The SCSI functions ---*/

/* All devices */

	/* Mandatory functions */

long scsi_Inquiry(scsi_device_t *dev, void *data, unsigned char length, int vital, unsigned char pagecode)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long	numblock;

	numblock = pagecode<<8;
	numblock |= (vital & 1)<<16;
	scsi_initcmd6(&cmd6, SCSI_CMD_INQUIRY, dev->lun, numblock, length, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_RequestSense(scsi_device_t *dev, void *data, unsigned char length)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;

	scsi_initcmd6(&cmd6, SCSI_CMD_REQUESTSENSE, dev->lun, 0, length, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_SendDiagnostic(scsi_device_t *dev, void *data, unsigned short length, int pf, int selftest, int devofl, int unitofl)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long	numblock;

	numblock = (length>>8) & 0xff;
	numblock |= (pf & 1)<<20;
	numblock |= (selftest & 1)<<18;
	numblock |= (devofl & 1)<<17;
	numblock |= (unitofl & 1)<<16;
	scsi_initcmd6(&cmd6, SCSI_CMD_SENDDIAGNOSTIC, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_TestUnitReady(scsi_device_t *dev)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;

	scsi_initcmd6(&cmd6, SCSI_CMD_TESTUNITREADY, dev->lun, 0, 0, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, NULL);

	return scsidrv_in(&cmd);
}

	/* Optional functions */

long scsi_ChangeDefinition(scsi_device_t *dev, void *data, unsigned char length, int save, int definition)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;
	unsigned long	numblock;

	numblock = (save & 1)<<24;
	numblock |= (definition & 0x7f)<<16;
	scsi_initcmd10(&cmd10, SCSI_CMD_CHANGEDEFINITION, dev->lun, numblock, length, dev->control);
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_Compare(scsi_device_t *dev, void *data, unsigned long length, int pad)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;
	unsigned long	numblock;

	numblock = length & ((1<<24)-1);
	scsi_initcmd10(&cmd10, SCSI_CMD_COMPARE, dev->lun, numblock, 0, dev->control);
	cmd10.lun |= (pad & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_Copy(scsi_device_t *dev, void *data, unsigned long length, int pad)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long	numblock;

	numblock = (pad & 1)<<16;
	numblock |= (length & 0xffff00)>>8;
	length &= 0x0000ff;
	scsi_initcmd6(&cmd6, SCSI_CMD_COPY, dev->lun, numblock, length, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_CopyAndVerify(scsi_device_t *dev, void *data, unsigned long length, int pad, int bytechk)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;
	unsigned long	numblock;

	numblock = length & ((1<<24)-1);
	scsi_initcmd10(&cmd10, SCSI_CMD_COPYANDVERIFY, dev->lun, numblock, 0, dev->control);
	cmd10.lun |= (pad & 1)<<0;
	cmd10.lun |= (bytechk & 1)<<1;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_LogSelect(scsi_device_t *dev, void *data, unsigned short length, int pcr, int sp)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_LOGSELECT, dev->lun, 0, length, dev->control);
	cmd10.lun |= (sp & 1)<<0;
	cmd10.lun |= (pcr & 1)<<1;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_LogSense(scsi_device_t *dev, void *data, unsigned short length, int ppc, int sp, int pc, int pagecode, unsigned short param_ptr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;
	unsigned long numblock;

	numblock = (pc & 3)<<6;
	numblock |= (pagecode & ((1<<6)-1))<<24;
	numblock |= (param_ptr & 0xff00)>>8;
	scsi_initcmd10(&cmd10, SCSI_CMD_LOGSENSE, dev->lun, numblock, length, dev->control);
	cmd10.reserved = param_ptr & 0xff;
	cmd10.lun |= (sp & 1)<<0;
	cmd10.lun |= (ppc & 1)<<1;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ReadBuffer(scsi_device_t *dev, void *data, unsigned long length, unsigned long offset, int bufferid, int mode)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;
	unsigned long numblock;

	numblock = (bufferid & 0xff)<<24;
	numblock |= offset & ((1<<24)-1);
	scsi_initcmd10(&cmd10, SCSI_CMD_READBUFFER, dev->lun, numblock, length, dev->control);
	cmd10.reserved = (length>>16) & 0xff;
	cmd10.lun |= (mode & 7)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ReceiveDiagnosticResults(scsi_device_t *dev, void *data, unsigned short length)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long	numblock;

	numblock = (length>>8) & 0xff;
	scsi_initcmd6(&cmd6, SCSI_CMD_RECEIVEDIAGNOSTICRESULTS, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_WriteBuffer(scsi_device_t *dev, void *data, unsigned long length, unsigned long offset, int bufferid, int mode)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;
	unsigned long numblock;

	numblock = (bufferid & 0xff)<<24;
	numblock |= offset & ((1<<24)-1);
	scsi_initcmd10(&cmd10, SCSI_CMD_WRITEBUFFER, dev->lun, numblock, length, dev->control);
	cmd10.reserved = (length>>16) & 0xff;
	cmd10.lun |= (mode & 7)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

	/* Device specific functions */

long scsi_ModeSelect6(scsi_device_t *dev, void *data, unsigned char length, int pf, int sp)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long	numblock;

	numblock = (pf & 1)<<20;
	numblock |= (sp & 1)<<16;
	scsi_initcmd6(&cmd6, SCSI_CMD_MODESELECT6, dev->lun, numblock, length, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_ModeSelect10(scsi_device_t *dev, void *data, unsigned short length, int pf, int sp)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;
	unsigned long	numblock;

	scsi_initcmd10(&cmd10, SCSI_CMD_MODESELECT10, dev->lun, 0, length, dev->control);
	cmd10.lun |= (pf & 1)<<4;
	cmd10.lun |= (sp & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_ModeSense6(scsi_device_t *dev, void *data, unsigned char length, int dbd, int pc, int pagecode)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long	numblock;

	numblock = (dbd & 1)<<19;
	numblock |= (pc & 3)<<14;
	numblock |= (pagecode & ((1<<6)-1))<<8;
	scsi_initcmd6(&cmd6, SCSI_CMD_MODESENSE6, dev->lun, numblock, length, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ModeSense10(scsi_device_t *dev, void *data, unsigned short length, int dbd, int pc, int pagecode)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;
	unsigned long	numblock;

	numblock |= (pc & 3)<<30;
	numblock |= (pagecode & ((1<<6)-1))<<24;

	scsi_initcmd10(&cmd10, SCSI_CMD_MODESENSE10, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (dbd & 1)<<3;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

/* Direct access devices */

	/* Mandatory functions */

long scsi_FormatUnit(scsi_device_t *dev, void *data, unsigned short interleave, unsigned char vendor, int fmtdata, int cmplst, int defectformat)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long	numblock;

	numblock = (fmtdata & 1)<<20;
	numblock |= (cmplst & 3)<<19;
	numblock |= (defectformat & ((1<<3)-1))<<16;
	numblock |= (vendor & ((1<<8)-1))<<8;
	numblock |= (interleave>>8) & 0xff;
	scsi_initcmd6(&cmd6, SCSI_CMD_FORMATUNIT, dev->lun, numblock, interleave & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_Read6(scsi_device_t *dev, void *data, unsigned long numblock, unsigned char length)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;

	numblock &= ((1<<21)-1);
	scsi_initcmd6(&cmd6, SCSI_CMD_READ6, dev->lun, numblock, length, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_Read10(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int dpo, int fua, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_READ10, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (dpo & 1)<<4;
	cmd10.lun |= (fua & 1)<<3;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ReadCapacity(scsi_device_t *dev, void *data, unsigned long numblock, int pmi, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_READCAPACITY, dev->lun, numblock, pmi & 1, dev->control);
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_Release_diracc(scsi_device_t *dev, void *data, int trdparty, int deviceid, int extent, unsigned char reservation)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long	numblock;

	numblock = (trdparty & 1)<<20;
	numblock |= (deviceid & 7)<<17;
	numblock |= (extent & 1)<<16;
	numblock |= reservation<<8;

	scsi_initcmd6(&cmd6, SCSI_CMD_RELEASE, dev->lun, numblock, 0, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_Reserve_diracc(scsi_device_t *dev, void *data, unsigned short length, int trdparty, int deviceid, int extent, unsigned char reservation)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long	numblock;

	numblock = (trdparty & 1)<<20;
	numblock |= (deviceid & 7)<<17;
	numblock |= (extent & 1)<<16;
	numblock |= reservation<<8;
	numblock |= (length>>8) & 0xff;

	scsi_initcmd6(&cmd6, SCSI_CMD_RESERVE, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

	/* Optional functions */

long scsi_LockUnlockCache(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int lock, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_LOCKUNLOCKCACHE, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (lock & 1)<<1;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_PreFetch(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int immed, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_PREFETCH, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (immed & 1)<<1;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_PreventAllowMediumRemoval(scsi_device_t *dev, void *data, int prevent)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;

	scsi_initcmd6(&cmd6, SCSI_CMD_PREVENTALLOWMEDIUMREMOVAL, dev->lun, 0, prevent & 1, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ReadDefectData10(scsi_device_t *dev, void *data, unsigned short length, int plist, int glist, int defectformat)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;
	unsigned long numblock;

	numblock = (plist & 1)<<28;
	numblock |= (glist & 1)<<27;
	numblock |= (defectformat & ((1<<3)-1))<<24;
	scsi_initcmd10(&cmd10, SCSI_CMD_READDEFECTDATA, dev->lun, numblock, length, dev->control);
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ReadLong(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int correct, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_READLONG, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (correct & 1)<<1;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ReassignBlocks(scsi_device_t *dev, void *data, unsigned short length)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;

	scsi_initcmd6(&cmd6, SCSI_CMD_REASSIGNBLOCKS, dev->lun, 0, 0, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_RezeroUnit(scsi_device_t *dev)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;

	scsi_initcmd6(&cmd6, SCSI_CMD_REZEROUNIT, dev->lun, 0, 0, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_SearchDataEqual10(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int invert, int spndat, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_SEARCHDATAEQUAL, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (invert & 1)<<4;
	cmd10.lun |= (spndat & 1)<<1;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_SearchDataHigh10(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int invert, int spndat, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_SEARCHDATAHIGH, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (invert & 1)<<4;
	cmd10.lun |= (spndat & 1)<<1;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_SearchDataLow10(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int invert, int spndat, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_SEARCHDATALOW, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (invert & 1)<<4;
	cmd10.lun |= (spndat & 1)<<1;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_Seek6(scsi_device_t *dev, unsigned long numblock)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;

	scsi_initcmd6(&cmd6, SCSI_CMD_SEEK6, dev->lun, numblock, 0, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_Seek10(scsi_device_t *dev, unsigned long numblock)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_SEEK10, dev->lun, numblock, 0, dev->control);
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_SetLimits10(scsi_device_t *dev, unsigned long numblock, unsigned short length, int rdinh, int wrinh)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_SETLIMITS10, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (rdinh & 1)<<1;
	cmd10.lun |= (wrinh & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_StartStopUnit(scsi_device_t *dev, int immed, int loej, int start)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;
	unsigned char length;

	numblock = (immed & 1)<<16;
	length = (loej & 1)<<1;
	length |= (start & 1)<<0;
	scsi_initcmd6(&cmd6, SCSI_CMD_STARTSTOPUNIT, dev->lun, numblock, length, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_SynchronizeCache(scsi_device_t *dev, unsigned long numblock, unsigned short length, int immed, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_SYNCHRONIZECACHE, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (immed & 1)<<1;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_Verify10_diracc(scsi_device_t *dev, unsigned long numblock, unsigned short length, int dpo, int bytechk, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_VERIFY10, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (dpo & 1)<<4;
	cmd10.lun |= (bytechk & 1)<<1;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_Write6(scsi_device_t *dev, void *data, unsigned long numblock, unsigned char length)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;

	numblock &= (1<<21)-1;
	scsi_initcmd6(&cmd6, SCSI_CMD_WRITE6, dev->lun, numblock, length, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_Write10_diracc(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int dpo, int fua, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_WRITE10, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (dpo & 1)<<4;
	cmd10.lun |= (fua & 1)<<3;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_WriteAndVerify10_diracc(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int dpo, int bytechk, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_WRITEANDVERIFY10, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (dpo & 1)<<4;
	cmd10.lun |= (bytechk & 1)<<1;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_WriteLong(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_WRITELONG, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_WriteSame(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int pbdata, int lbdata, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_WRITESAME, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (pbdata & 1)<<2;
	cmd10.lun |= (lbdata & 1)<<1;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

/* Sequential access devices */

	/* Mandatory functions */

long scsi_Erase(scsi_device_t *dev, int immed, int longerase)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (immed & 1)<<17;
	numblock |= (longerase & 1)<<16;
	scsi_initcmd6(&cmd6, SCSI_CMD_WRITE6, dev->lun, numblock, 0, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_Read_seqacc(scsi_device_t *dev, void *data, unsigned long length, int sili, int fixed)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (sili & 1)<<17;
	numblock |= (fixed & 1)<<16;
	numblock |= (length>>8) & 0xffff;
	scsi_initcmd6(&cmd6, SCSI_CMD_READ_SA, dev->lun, numblock, length & 0xf, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ReadBlockLimits(scsi_device_t *dev, void *data)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;

	scsi_initcmd6(&cmd6, SCSI_CMD_READBLOCKLIMITS, dev->lun, 0, 0, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ReleaseUnit(scsi_device_t *dev, int trdparty, int deviceid, int reserved)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (trdparty & 1)<<20;
	numblock |= (deviceid & 7)<<17;
	numblock |= (reserved & 1)<<16;
	scsi_initcmd6(&cmd6, SCSI_CMD_RELEASE, dev->lun, numblock, 0, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_ReserveUnit(scsi_device_t *dev, int trdparty, int deviceid, int reserved)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (trdparty & 1)<<20;
	numblock |= (deviceid & 7)<<17;
	numblock |= (reserved & 1)<<16;
	scsi_initcmd6(&cmd6, SCSI_CMD_RESERVE, dev->lun, numblock, 0, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_Rewind(scsi_device_t *dev, int immed)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (immed & 1)<<16;
	scsi_initcmd6(&cmd6, SCSI_CMD_REWIND, dev->lun, numblock, 0, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_Space(scsi_device_t *dev, unsigned long length, int code)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (code & 7)<<16;
	numblock |= (length>>8) & 0xffff;
	scsi_initcmd6(&cmd6, SCSI_CMD_SPACE, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_Write_seqacc(scsi_device_t *dev, void *data, unsigned long length, int fixed)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (fixed & 1)<<16;
	numblock |= (length>>8) & 0xffff;
	scsi_initcmd6(&cmd6, SCSI_CMD_WRITE, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_WriteFilemarks(scsi_device_t *dev, void *data, unsigned long length, int wsmk, int immed)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (wsmk & 1)<<17;
	numblock = (immed & 1)<<16;
	numblock |= (length>>8) & 0xffff;
	scsi_initcmd6(&cmd6, SCSI_CMD_WRITEFILEMARKS, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

	/* Optional functions */

long scsi_LoadUnload(scsi_device_t *dev, int immed, int eot, int reten, int load)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;
	unsigned char length;

	numblock = (immed & 1)<<16;
	length = (eot & 1)<<2;	
	length = (reten & 1)<<1;	
	length = (load & 1)<<0;	
	scsi_initcmd6(&cmd6, SCSI_CMD_LOADUNLOAD, dev->lun, numblock, length, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_Locate(scsi_device_t *dev, unsigned long numblock, unsigned char partition, int bt, int cp, int immed)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_LOCATE, dev->lun, (numblock>>8) & 0xffffff, partition, dev->control);
	cmd10.lun |= (bt & 1)<<2;
	cmd10.lun |= (cp & 1)<<1;
	cmd10.lun |= (immed & 1)<<0;
	cmd10.reserved = numblock & 0xff;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_ReadPosition(scsi_device_t *dev, void *data, int bt)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_READPOSITION, dev->lun, 0, 0, dev->control);
	cmd10.lun |= (bt & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ReadReverse(scsi_device_t *dev, void *data, unsigned long length, int sili, int fixed)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (length>>8) & 0xffff;
	numblock |= (sili & 1)<<17;
	numblock |= (fixed & 1)<<16;
	scsi_initcmd6(&cmd6, SCSI_CMD_READREVERSE, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_RecoverBufferedData_seqacc(scsi_device_t *dev, void *data, unsigned long length, int sili, int fixed)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (length>>8) & 0xffff;
	numblock |= (sili & 1)<<17;
	numblock |= (fixed & 1)<<16;
	scsi_initcmd6(&cmd6, SCSI_CMD_RECOVERBUFFEREDDATA, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_Verify6_seqacc(scsi_device_t *dev, void *data, unsigned long length, int immed, int bytcmp, int fixed)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (length>>8) & 0xffff;
	numblock |= (immed & 1)<<18;
	numblock |= (bytcmp & 1)<<17;
	numblock |= (fixed & 1)<<16;
	scsi_initcmd6(&cmd6, SCSI_CMD_VERIFY6, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

/* Printer devices */

	/* Mandatory functions */

long scsi_Print(scsi_device_t *dev, void *data, unsigned long length)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (length>>8) & 0xffff;
	scsi_initcmd6(&cmd6, SCSI_CMD_PRINT, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

	/* Optional functions */

long scsi_Format(scsi_device_t *dev, void *data, unsigned long length, int format)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (length>>8) & 0xffff;
	numblock |= (format & 3)<<16;
	scsi_initcmd6(&cmd6, SCSI_CMD_FORMAT, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_RecoverBufferedData_prn(scsi_device_t *dev, void *data, unsigned long length)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (length>>8) & 0xffff;
	scsi_initcmd6(&cmd6, SCSI_CMD_RECOVERBUFFEREDDATA, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_SlewAndPrint(scsi_device_t *dev, void *data, unsigned short length, unsigned char slew, int channel)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (length>>8) & 0xff;
	numblock |= slew <<8;
	numblock |= (channel & 1)<<16;
	scsi_initcmd6(&cmd6, SCSI_CMD_SLEWANDPRINT, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_StopPrint(scsi_device_t *dev, int retain, unsigned char vendor)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (retain & 1)<<16;
	numblock |= vendor <<8;
	scsi_initcmd6(&cmd6, SCSI_CMD_STOPPRINT, dev->lun, numblock, 0, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_SynchronizeBuffer(scsi_device_t *dev)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;

	scsi_initcmd6(&cmd6, SCSI_CMD_SYNCHRONIZEBUFFER, dev->lun, 0, 0, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, NULL);

	return scsidrv_in(&cmd);
}

/* Processor devices */

	/* Mandatory functions */

long scsi_Send_proc(scsi_device_t *dev, void *data, unsigned long length, int aen)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (length>>8) & 0xffff;
	numblock |= (aen & 1)<<16;
	scsi_initcmd6(&cmd6, SCSI_CMD_SEND_PROC, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

	/* Optional functions */

long scsi_Receive(scsi_device_t *dev, void *data, unsigned long length)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long numblock;

	numblock = (length>>8) & 0xffff;
	scsi_initcmd6(&cmd6, SCSI_CMD_RECEIVE, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

/* Write-once devices */

	/* Mandatory functions */

	/* Optional functions */

/* CD-ROM devices */

	/* Mandatory functions */

long scsi_ReadCdromCapacity(scsi_device_t *dev, void *data, unsigned long numblock, int reladr, int pmi)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_READCDROMCAPACITY, dev->lun, numblock, pmi & 1, dev->control);
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

	/* Optional functions */

long scsi_PauseResume(scsi_device_t *dev, int resume)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_PAUSERESUME, dev->lun, 0, resume & 1, dev->control);
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_PlayAudio10(scsi_device_t *dev, unsigned long numblock, unsigned short length, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_PLAYAUDIO10, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_PlayAudio12(scsi_device_t *dev, unsigned long numblock, unsigned long length, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_PLAYAUDIO12, dev->lun, numblock, length, dev->control);
	cmd12.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_PlayAudioMsf(scsi_device_t *dev, unsigned long start, unsigned long end)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_PLAYAUDIOMSF, dev->lun, start & 0xffffff, end & 0xffff, dev->control);
	cmd10.reserved = end>>16;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_PlayAudioTrackIndex(scsi_device_t *dev, unsigned char start_track, unsigned char start_index, unsigned char end_track, unsigned char end_index)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_PLAYAUDIOTRACKINDEX, dev->lun, (start_track<<8)|start_index, (end_track<<8)|end_index, dev->control);
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_PlayAudioTrackRelative10(scsi_device_t *dev, unsigned long numblock, unsigned short length, unsigned char track)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_PLAYAUDIOTRACKRELATIVE10, dev->lun, numblock, length, dev->control);
	cmd10.reserved = track;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_PlayAudioTrackRelative12(scsi_device_t *dev, unsigned long numblock, unsigned long length, unsigned char track)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_PLAYAUDIOTRACKRELATIVE12, dev->lun, numblock, length, dev->control);
	cmd12.reserved = track;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_ReadHeader(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int msf)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_READHEADER, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (msf & 1)<<1;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ReadSubChannel(scsi_device_t *dev, void *data, unsigned short length, int msf, int subq, unsigned char format, unsigned char track)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;
	unsigned long	numblock;

	numblock = (subq & 1)<<30;
	numblock |= format<<16;

	scsi_initcmd10(&cmd10, SCSI_CMD_READSUBCHANNEL, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (msf & 1)<<1;
	cmd10.reserved = track;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ReadToc(scsi_device_t *dev, void *data, unsigned short length, int msf, unsigned char track)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_READTOC, dev->lun, 0, length, dev->control);
	cmd10.lun |= (msf & 1)<<1;
	cmd10.reserved = track;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

/* Scanner devices */

	/* Mandatory functions */

long scsi_Read_scan(scsi_device_t *dev, void *data, unsigned long length, unsigned char dtcode, unsigned short dtqualifier)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;
	unsigned long	numblock;

	numblock = dtcode<<24;
	numblock |= dtqualifier;

	scsi_initcmd10(&cmd10, SCSI_CMD_READ_SCAN, dev->lun, numblock, length & 0xffff, dev->control);
	cmd10.reserved = length>>16;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_SetWindow(scsi_device_t *dev, void *data, unsigned long length)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_SETWINDOW, dev->lun, 0, length & 0xffff, dev->control);
	cmd10.reserved = length>>16;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

	/* Optional functions */

long scsi_GetDataBufferStatus(scsi_device_t *dev, void *data, unsigned short length, int wait)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_GETDATABUFFERSTATUS, dev->lun, 0, length, dev->control);
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_GetWindow(scsi_device_t *dev, void *data, unsigned long length, int single, unsigned char window)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_GETWINDOW, dev->lun, window, length & 0xffff, dev->control);
	cmd10.lun |= (single & 1)<<0;
	cmd10.reserved = length>>16;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ObjectPosition(scsi_device_t *dev, void *data, unsigned long length, int position)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_OBJECTPOSITION, dev->lun, length<<8, 0, dev->control);
	cmd10.lun |= (position & 7)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_Scan(scsi_device_t *dev, void *data, unsigned char length)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;

	scsi_initcmd6(&cmd6, SCSI_CMD_SCAN, dev->lun, 0, length, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_Send_scan(scsi_device_t *dev, void *data, unsigned long length, unsigned char dtcode, unsigned short dtqualifier)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;
	unsigned long	numblock;

	numblock = dtcode<<24;
	numblock |= dtqualifier;

	scsi_initcmd10(&cmd10, SCSI_CMD_SEND_SCAN, dev->lun, numblock, length & 0xffff, dev->control);
	cmd10.reserved = length>>16;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

/* Optical memory devices */

	/* Mandatory functions */

long scsi_Write10_optmem(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int dpo, int fua, int ebp, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_WRITE10, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (dpo & 1)<<4;
	cmd10.lun |= (fua & 1)<<3;
	cmd10.lun |= (ebp & 1)<<2;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

	/* Optional functions */

long scsi_Erase10(scsi_device_t *dev, unsigned long numblock, unsigned short length, int era, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_ERASE10, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (era & 1)<<2;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_Erase12(scsi_device_t *dev, unsigned long numblock, unsigned long length, int era, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_ERASE12, dev->lun, numblock, length, dev->control);
	cmd12.lun |= (era & 1)<<2;
	cmd12.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_MediumScan(scsi_device_t *dev, void *data, unsigned long numblock, unsigned char length, int wbs, int asa, int rsd, int pra, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_MEDIUMSCAN, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (wbs & 1)<<4;
	cmd10.lun |= (asa & 1)<<3;
	cmd10.lun |= (rsd & 1)<<2;
	cmd10.lun |= (pra & 1)<<1;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_Read12(scsi_device_t *dev, void *data, unsigned long numblock, unsigned long length, int dpo, int fua, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_READ12, dev->lun, numblock, length, dev->control);
	cmd12.lun |= (dpo & 1)<<4;
	cmd12.lun |= (fua & 1)<<3;
	cmd12.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ReadDefectData12(scsi_device_t *dev, void *data, unsigned long length, int plist, int glist, int format)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_READDEFECTDATA12, dev->lun, 0, length, dev->control);
	cmd12.lun |= (plist & 1)<<4;
	cmd12.lun |= (glist & 1)<<3;
	cmd12.lun |= (format & 7)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ReadGeneration(scsi_device_t *dev, void *data, unsigned long numblock, unsigned char length, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_READGENERATION, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_ReadUpdatedBlock(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int dpo, int fua, int reladr, int latest)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_READGENERATION, dev->lun, numblock, length & ((1<<15)-1), dev->control);
	cmd10.lun |= (dpo & 4)<<0;
	cmd10.lun |= (fua & 3)<<0;
	cmd10.lun |= (reladr & 1)<<0;
	cmd10.length |= (latest & 1)<<15;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_SearchDataEqual12(scsi_device_t *dev, void *data, unsigned long numblock, unsigned long length, int invert, int spndat, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_SEARCHDATAEQUAL12, dev->lun, numblock, length, dev->control);
	cmd12.lun |= (invert & 1)<<4;
	cmd12.lun |= (spndat & 1)<<1;
	cmd12.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_SearchDataHigh12(scsi_device_t *dev, void *data, unsigned long numblock, unsigned long length, int invert, int spndat, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_SEARCHDATAHIGH12, dev->lun, numblock, length, dev->control);
	cmd12.lun |= (invert & 1)<<4;
	cmd12.lun |= (spndat & 1)<<1;
	cmd12.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_SearchDataLow12(scsi_device_t *dev, void *data, unsigned long numblock, unsigned long length, int invert, int spndat, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_SEARCHDATALOW12, dev->lun, numblock, length, dev->control);
	cmd12.lun |= (invert & 1)<<4;
	cmd12.lun |= (spndat & 1)<<1;
	cmd12.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_SetLimits12(scsi_device_t *dev, unsigned long numblock, unsigned long length, int rdinh, int wrinh)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_SETLIMITS12, dev->lun, numblock, length, dev->control);
	cmd12.lun |= (rdinh & 1)<<1;
	cmd12.lun |= (wrinh & 1)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_UpdateBlock(scsi_device_t *dev, unsigned long numblock, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_UPDATEBLOCK, dev->lun, numblock, 0, dev->control);
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_Verify10_optmem(scsi_device_t *dev, unsigned long numblock, unsigned short length, int dpo, int blkvfy, int bytechk, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_VERIFY10, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (dpo & 1)<<4;
	cmd10.lun |= (blkvfy & 1)<<2;
	cmd10.lun |= (bytechk & 1)<<1;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_Verify12(scsi_device_t *dev, unsigned long numblock, unsigned long length, int dpo, int blkvfy, int bytechk, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_VERIFY12, dev->lun, numblock, length, dev->control);
	cmd12.lun |= (dpo & 1)<<4;
	cmd12.lun |= (blkvfy & 1)<<2;
	cmd12.lun |= (bytechk & 1)<<1;
	cmd12.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_Write12(scsi_device_t *dev, void *data, unsigned long numblock, unsigned long length, int dpo, int fua, int ebp, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_WRITE12, dev->lun, numblock, length, dev->control);
	cmd12.lun |= (dpo & 1)<<4;
	cmd12.lun |= (fua & 1)<<3;
	cmd12.lun |= (ebp & 1)<<2;
	cmd12.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_WriteAndVerify10_optmem(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int dpo, int ebp, int bytechk, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_WRITEANDVERIFY10, dev->lun, numblock, length, dev->control);
	cmd10.lun |= (dpo & 1)<<4;
	cmd10.lun |= (ebp & 1)<<3;
	cmd10.lun |= (bytechk & 1)<<1;
	cmd10.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_WriteAndVerify12(scsi_device_t *dev, void *data, unsigned long numblock, unsigned long length, int dpo, int ebp, int bytechk, int reladr)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_WRITEANDVERIFY12, dev->lun, numblock, length, dev->control);
	cmd12.lun |= (dpo & 1)<<4;
	cmd12.lun |= (ebp & 1)<<3;
	cmd12.lun |= (bytechk & 1)<<1;
	cmd12.lun |= (reladr & 1)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, data);

	return scsidrv_out(&cmd);
}

/* Medium-changer devices */

	/* Mandatory functions */

long scsi_MoveMedium(scsi_device_t *dev, unsigned short transport, unsigned short source, unsigned short dest, int invert)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_MOVEMEDIUM, dev->lun, (transport<<16)|source, dest<<16, dev->control);
	cmd12.reserved = (invert & 1)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, NULL);

	return scsidrv_in(&cmd);
}

	/* Optional functions */

long scsi_ExchangeMedium(scsi_device_t *dev, unsigned short transport, unsigned short source, unsigned short dest1, unsigned short dest2, int invert1, int invert2)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_EXCHANGEMEDIUM, dev->lun, (transport<<16)|source, (dest1<<16)|dest2, dev->control);
	cmd12.reserved = (invert2 & 1)<<1;
	cmd12.reserved |= (invert1 & 1)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_InitializeElementStatus(scsi_device_t *dev)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;

	scsi_initcmd6(&cmd6, SCSI_CMD_INITIALIZEELEMENTSTATUS, dev->lun, 0, 0, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_PositionToElement(scsi_device_t *dev, unsigned short transport, unsigned short dest, int invert)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_POSITIONTOELEMENT, dev->lun, (transport<<16)|dest, 0, dev->control);
	cmd10.reserved = (invert & 1)<<0;
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, NULL);

	return scsidrv_in(&cmd);
}

long scsi_ReadElementStatus(scsi_device_t *dev, void *data, unsigned long length, unsigned short start, unsigned short number, int voltag, int elttype)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_READELEMENTSTATUS, dev->lun, (start<<16)|number, length & ((1<<24)-1), dev->control);
	cmd12.lun |= (voltag & 1)<<4;
	cmd12.lun |= (elttype & 15)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_RequestVolumeElementAddress(scsi_device_t *dev, void *data, unsigned long length, unsigned short element, unsigned short number, int voltag, int elttype)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_READELEMENTSTATUS, dev->lun, (element<<16)|number, length & ((1<<24)-1), dev->control);
	cmd12.lun |= (voltag & 1)<<4;
	cmd12.lun |= (elttype & 15)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_Release_medchg(scsi_device_t *dev, void *data, int trdparty, int deviceid, int element, unsigned char reservation)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long	numblock;

	numblock = (trdparty & 1)<<20;
	numblock |= (deviceid & 7)<<17;
	numblock |= (element & 1)<<16;
	numblock |= reservation<<8;

	scsi_initcmd6(&cmd6, SCSI_CMD_RELEASE, dev->lun, numblock, 0, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_Reserve_medchg(scsi_device_t *dev, void *data, unsigned short length, int trdparty, int deviceid, int element, unsigned char reservation)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;
	unsigned long	numblock;

	numblock = (trdparty & 1)<<20;
	numblock |= (deviceid & 7)<<17;
	numblock |= (element & 1)<<16;
	numblock |= reservation<<8;
	numblock |= (length>>8) & 0xff;

	scsi_initcmd6(&cmd6, SCSI_CMD_RESERVE, dev->lun, numblock, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_SendVolumeTag(scsi_device_t *dev, void *data, unsigned short length, unsigned short element, int elttype, int sendaction)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_SENDVOLUMETAG, dev->lun, (element<<16)|(sendaction & 31), length, dev->control);
	cmd12.lun |= (elttype & 15)<<0;
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, data);

	return scsidrv_out(&cmd);
}

/* Communication devices */

	/* Mandatory functions */

long scsi_SendMessage6(scsi_device_t *dev, void *data, unsigned long length)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;

	scsi_initcmd6(&cmd6, SCSI_CMD_SENDMESSAGE6, dev->lun, (length>>8) & 0xffff, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_out(&cmd);
}

	/* Optional functions */

long scsi_GetMessage6(scsi_device_t *dev, void *data, unsigned long length)
{
	scsi_cmd_t	cmd;
	scsi_cmd6_t	cmd6;

	scsi_initcmd6(&cmd6, SCSI_CMD_GETMESSAGE6, dev->lun, (length>>8) & 0xffff, length & 0xff, dev->control);
	scsi_initcmd(&cmd, &cmd6, sizeof(cmd6), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_GetMessage10(scsi_device_t *dev, void *data, unsigned short stream, unsigned short length)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_GETMESSAGE10, dev->lun, stream, length, dev->control);
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_GetMessage12(scsi_device_t *dev, void *data, unsigned short stream, unsigned long length)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_GETMESSAGE12, dev->lun, stream, length, dev->control);
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, data);

	return scsidrv_in(&cmd);
}

long scsi_SendMessage10(scsi_device_t *dev, void *data, unsigned short stream, unsigned short length)
{
	scsi_cmd_t	cmd;
	scsi_cmd10_t	cmd10;

	scsi_initcmd10(&cmd10, SCSI_CMD_SENDMESSAGE10, dev->lun, stream, length, dev->control);
	scsi_initcmd(&cmd, &cmd10, sizeof(cmd10), dev, data);

	return scsidrv_out(&cmd);
}

long scsi_SendMessage12(scsi_device_t *dev, void *data, unsigned short stream, unsigned long length)
{
	scsi_cmd_t	cmd;
	scsi_cmd12_t	cmd12;

	scsi_initcmd12(&cmd12, SCSI_CMD_SENDMESSAGE12, dev->lun, stream, length, dev->control);
	scsi_initcmd(&cmd, &cmd12, sizeof(cmd12), dev, data);

	return scsidrv_out(&cmd);
}
