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

#ifndef _SCSI_H
#define _SCSI_H

/*--- Defines ---*/

/* status byte */
#define SCSI_STATUS_MASK			0x3e
#define SCSI_STATUS_GOOD			0x00
#define SCSI_STATUS_CHECKCONDITION	0x02
#define SCSI_STATUS_CONDITIONMET	0x04
#define SCSI_STATUS_BUSY			0x08
#define SCSI_STATUS_INTERMEDIATE	0x10
#define SCSI_STATUS_INTER_CONDMET	0x14
#define SCSI_STATUS_RESERV_CONFLICT	0x18
#define SCSI_STATUS_TERMINATED		0x22
#define SCSI_STATUS_QUEUEFULL		0x28

/* bits in control byte of a scsi command */
#define SCSI_CONTROL_LINK	(1<<0)
#define SCSI_CONTROL_FLAG	(1<<1)

/*--- Types ---*/

typedef struct {
	unsigned short *handle;	/* Handle of SCSIdrv device */
	unsigned char lun;		/* Logical unit number of device */
	unsigned char control;	/* Control byte (last byte of a SCSI command) */ 
	unsigned long maxlen;	/* Max transfer len */
	unsigned long timeout;	/* Timeout in ms for command */
} scsi_device_t;

typedef struct {
	unsigned char periph;	/* bits 7-5: qualifier */
							/* bits 4-0: device type */
	unsigned char rmb;		/* bit 7: rmb */
							/* bits 6-0: device type modifier */
	unsigned char version;	/* bits 7-6: iso version */
							/* bits 5-3: ecma version */
							/* bits 2-0: ansi version */
	unsigned char misc1;	/* bit 7: aenc */
							/* bit 6: trmiop */
							/* bits 5-4: reserved */
							/* buts 3-0: response data format */
	unsigned char addlen;	/* additional length */
	unsigned char reserved1[2];
	unsigned char misc2;	/* bit 7: reladr */
							/* bit 6: wbus32 */
							/* bit 5: wbus16 */
							/* bit 4: sync */
							/* bit 3: linked */
							/* bit 2: reserved */
							/* bit 1: cmdque */
							/* bit 0: stfre */
	unsigned char vendor[8];	/* vendor id */
	unsigned char product[16];	/* product id */
	unsigned char rev[4];		/* product revision */
	/* these are first 36 bytes of inquiry data */
	/* the following bytes are vendor specific and reserved bytes */
} scsi_inquire_data_t __attribute__((packed)) ;

/*--- Variables ---*/

extern unsigned char scsi_SenseBuffer[18];

/*--- The SCSI functions ---*/

/* All devices */

	/* Mandatory functions */			/* done */
/* 8.2.5  */	long scsi_Inquiry(scsi_device_t *dev, void *data, unsigned char length, int vital, unsigned char pagecode);
/* 8.2.14 */	long scsi_RequestSense(scsi_device_t *dev, void *data, unsigned char length);
/* 8.2.15 */	long scsi_SendDiagnostic(scsi_device_t *dev, void *data, unsigned short length, int pf, int selftest, int devofl, int unitofl);
/* 8.2.16 */	long scsi_TestUnitReady(scsi_device_t *dev);

	/* Optional functions */			/* done */
/* 8.2.1  */	long scsi_ChangeDefinition(scsi_device_t *dev, void *data, unsigned char length, int save, int definition);
/* 8.2.2  */	long scsi_Compare(scsi_device_t *dev, void *data, unsigned long length, int pad);
/* 8.2.3  */	long scsi_Copy(scsi_device_t *dev, void *data, unsigned long length, int pad);
/* 8.2.4  */	long scsi_CopyAndVerify(scsi_device_t *dev, void *data, unsigned long length, int pad, int bytechk);
/* 8.2.6  */	long scsi_LogSelect(scsi_device_t *dev, void *data, unsigned short length, int pcr, int sp);
/* 8.2.7  */	long scsi_LogSense(scsi_device_t *dev, void *data, unsigned short length, int ppc, int sp, int pc, int pagecode, unsigned short param_ptr);
/* 8.2.12 */	long scsi_ReadBuffer(scsi_device_t *dev, void *data, unsigned long length, unsigned long offset, int bufferid, int mode);
/* 8.2.13 */	long scsi_ReceiveDiagnosticResults(scsi_device_t *dev, void *data, unsigned short length);
/* 8.2.17 */	long scsi_WriteBuffer(scsi_device_t *dev, void *data, unsigned long length, unsigned long offset, int bufferid, int mode);

	/* Device specific functions */		/* done */
/* 8.2.8  */	long scsi_ModeSelect6(scsi_device_t *dev, void *data, unsigned char length, int pf, int sp);
/* 8.2.9  */	long scsi_ModeSelect10(scsi_device_t *dev, void *data, unsigned short length, int pf, int sp);
/* 8.2.10 */	long scsi_ModeSense6(scsi_device_t *dev, void *data, unsigned char length, int dbd, int pc, int pagecode);
/* 8.2.11 */	long scsi_ModeSense10(scsi_device_t *dev, void *data, unsigned short length, int dbd, int pc, int pagecode);

/* Direct access devices */

	/* Mandatory functions */			/* done */
/* 9.2.1  */	long scsi_FormatUnit(scsi_device_t *dev, void *data, unsigned short interleave, unsigned char vendor, int fmtdata, int cmplst, int defectformat);
/* 9.2.5  */	long scsi_Read6(scsi_device_t *dev, void *data, unsigned long numblock, unsigned char length);
/* 9.2.6  */	long scsi_Read10(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int dpo, int fua, int reladr);
/* 9.2.7  */	long scsi_ReadCapacity(scsi_device_t *dev, void *data, unsigned long numblock, int pmi, int reladr);
/* 9.2.11 */	long scsi_Release_diracc(scsi_device_t *dev, void *data, int trdparty, int deviceid, int extent, unsigned char reservation);
/* 9.2.12 */	long scsi_Reserve_diracc(scsi_device_t *dev, void *data, unsigned short length, int trdparty, int deviceid, int extent, unsigned char reservation);

	/* Optional functions */	/* done, check 9.2.10 */
/* 9.2.2  */	long scsi_LockUnlockCache(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int lock, int reladr);
/* 9.2.3  */	long scsi_PreFetch(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int immed, int reladr);
/* 9.2.4  */	long scsi_PreventAllowMediumRemoval(scsi_device_t *dev, void *data, int prevent);
/* 9.2.8  */	long scsi_ReadDefectData10(scsi_device_t *dev, void *data, unsigned short length, int plist, int glist, int defectformat);
/* 9.2.9  */	long scsi_ReadLong(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int correct, int reladr);
/* 9.2.10 */	long scsi_ReassignBlocks(scsi_device_t *dev, void *data, unsigned short length);
/* 9.2.13 */	long scsi_RezeroUnit(scsi_device_t *dev);
/* 9.2.14.1 */	long scsi_SearchDataEqual10(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int invert, int spndat, int reladr);
/* 9.2.14.2 */	long scsi_SearchDataHigh10(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int invert, int spndat, int reladr);
/* 9.2.14.3 */	long scsi_SearchDataLow10(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int invert, int spndat, int reladr);
/* 9.2.15 */	long scsi_Seek6(scsi_device_t *dev, unsigned long numblock);
/* 9.2.15 */	long scsi_Seek10(scsi_device_t *dev, unsigned long numblock);
/* 9.2.16 */	long scsi_SetLimits10(scsi_device_t *dev, unsigned long numblock, unsigned short length, int rdinh, int wrinh);
/* 9.2.17 */	long scsi_StartStopUnit(scsi_device_t *dev, int immed, int loej, int start);
/* 9.2.18 */	long scsi_SynchronizeCache(scsi_device_t *dev, unsigned long numblock, unsigned short length, int immed, int reladr);
/* 9.2.19 */	long scsi_Verify10_diracc(scsi_device_t *dev, unsigned long numblock, unsigned short length, int dpo, int bytechk, int reladr);
/* 9.2.20 */	long scsi_Write6(scsi_device_t *dev, void *data, unsigned long numblock, unsigned char length);
/* 9.2.21 */	long scsi_Write10_diracc(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int dpo, int fua, int reladr);
/* 9.2.22 */	long scsi_WriteAndVerify10_diracc(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int dpo, int bytechk, int reladr);
/* 9.2.23 */	long scsi_WriteLong(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int reladr);
/* 9.2.24 */	long scsi_WriteSame(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int pbdata, int lbdata, int reladr);

/* Sequential access devices */

	/* Mandatory functions */	/* done */
/* 10.2.1  */	long scsi_Erase(scsi_device_t *dev, int immed, int longerase);
/* 10.2.4  */	long scsi_Read_seqacc(scsi_device_t *dev, void *data, unsigned long length, int sili, int fixed);
/* 10.2.5  */	long scsi_ReadBlockLimits(scsi_device_t *dev, void *data);
/* 10.2.9  */	long scsi_ReleaseUnit(scsi_device_t *dev, int trdparty, int deviceid, int reserved);
/* 10.2.10 */	long scsi_ReserveUnit(scsi_device_t *dev, int trdparty, int deviceid, int reserved);
/* 10.2.11 */	long scsi_Rewind(scsi_device_t *dev, int immed);
/* 10.2.12 */	long scsi_Space(scsi_device_t *dev, unsigned long length, int code);
/* 10.2.14 */	long scsi_Write_seqacc(scsi_device_t *dev, void *data, unsigned long length, int fixed);
/* 10.2.15 */	long scsi_WriteFilemarks(scsi_device_t *dev, void *data, unsigned long length, int wsmk, int immed);

	/* Optional functions */	/* done */
/* 10.2.2  */	long scsi_LoadUnload(scsi_device_t *dev, int immed, int eot, int reten, int load);
/* 10.2.3  */	long scsi_Locate(scsi_device_t *dev, unsigned long numblock, unsigned char partition, int bt, int cp, int immed);
/* 10.2.6  */	long scsi_ReadPosition(scsi_device_t *dev, void *data, int bt);
/* 10.2.7  */	long scsi_ReadReverse(scsi_device_t *dev, void *data, unsigned long length, int sili, int fixed);
/* 10.2.8  */	long scsi_RecoverBufferedData_seqacc(scsi_device_t *dev, void *data, unsigned long length, int sili, int fixed);
/* 10.2.13 */	long scsi_Verify6_seqacc(scsi_device_t *dev,void *data,  unsigned long length, int immed, int bytcmp, int fixed);

/* Printer devices */

	/* Mandatory functions */	/* done */
/* 11.2.2 */	long scsi_Print(scsi_device_t *dev, void *data, unsigned long length);

	/* Optional functions */	/* done */
/* 11.2.1 */	long scsi_Format(scsi_device_t *dev, void *data, unsigned long length, int format);
/* 11.2.3 */	long scsi_RecoverBufferedData_prn(scsi_device_t *dev, void *data, unsigned long length);
/* 11.2.4 */	long scsi_SlewAndPrint(scsi_device_t *dev, void *data, unsigned short length, unsigned char slew, int channel);
/* 11.2.5 */	long scsi_StopPrint(scsi_device_t *dev, int retain, unsigned char vendor);
/* 11.2.6 */	long scsi_SynchronizeBuffer(scsi_device_t *dev);

/* Processor devices */

	/* Mandatory functions */	/* done */
/* 12.2.2 */	long scsi_Send_proc(scsi_device_t *dev, void *data, unsigned long length, int aen);

	/* Optional functions */	/* done */
/* 12.2.1 */	long scsi_Receive(scsi_device_t *dev, void *data, unsigned long length);

/* Write-once devices */

	/* Mandatory functions */

	/* Optional functions */

/* CD-ROM devices */

	/* Mandatory functions */	/* done */
/* 14.2.8 */	long scsi_ReadCdromCapacity(scsi_device_t *dev, void *data, unsigned long numblock, int reladr, int pmi);

	/* Optional functions */	/* done */
/* 14.2.1 */	long scsi_PauseResume(scsi_device_t *dev, int resume);
/* 14.2.2 */	long scsi_PlayAudio10(scsi_device_t *dev, unsigned long numblock, unsigned short length, int reladr);
/* 14.2.3 */	long scsi_PlayAudio12(scsi_device_t *dev, unsigned long numblock, unsigned long length, int reladr);
/* 14.2.4 */	long scsi_PlayAudioMsf(scsi_device_t *dev, unsigned long start, unsigned long end);
/* 14.2.5 */	long scsi_PlayAudioTrackIndex(scsi_device_t *dev, unsigned char start_track, unsigned char start_index, unsigned char end_track, unsigned char end_index);
/* 14.2.6 */	long scsi_PlayAudioTrackRelative10(scsi_device_t *dev, unsigned long numblock, unsigned short length, unsigned char track);
/* 14.2.7 */	long scsi_PlayAudioTrackRelative12(scsi_device_t *dev, unsigned long numblock, unsigned long length, unsigned char track);
/* 14.2.9 */	long scsi_ReadHeader(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int msf);
/* 14.2.10 */	long scsi_ReadSubChannel(scsi_device_t *dev, void *data, unsigned short length, int msf, int subq, unsigned char format, unsigned char track);
/* 14.2.11 */	long scsi_ReadToc(scsi_device_t *dev, void *data, unsigned short length, int msf, unsigned char track);

/* Scanner devices */

	/* Mandatory functions */	/* done */
/* 15.2.4 */	long scsi_Read_scan(scsi_device_t *dev, void *data, unsigned long length, unsigned char dtcode, unsigned short dtqualifier);
/* 15.2.7 */	long scsi_SetWindow(scsi_device_t *dev, void *data, unsigned long length);

	/* Optional functions */	/* done */
/* 15.2.1 */	long scsi_GetDataBufferStatus(scsi_device_t *dev, void *data, unsigned short length, int wait);
/* 15.2.2 */	long scsi_GetWindow(scsi_device_t *dev, void *data, unsigned long length, int single, unsigned char window);
/* 15.2.3 */	long scsi_ObjectPosition(scsi_device_t *dev, void *data, unsigned long length, int position);
/* 15.2.5 */	long scsi_Scan(scsi_device_t *dev, void *data, unsigned char length);
/* 15.2.6 */	long scsi_Send_scan(scsi_device_t *dev, void *data, unsigned long length, unsigned char dtcode, unsigned short dtqualifier);

/* Optical memory devices */

	/* Mandatory functions */	/* done */
/* 16.2.13 */	long scsi_Write10_optmem(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int dpo, int fua, int ebp, int reladr);

	/* Optional functions */	/* done */
/* 16.2.1 */	long scsi_Erase10(scsi_device_t *dev, unsigned long numblock, unsigned short length, int era, int reladr);
/* 16.2.2 */	long scsi_Erase12(scsi_device_t *dev, unsigned long numblock, unsigned long length, int era, int reladr);
/* 16.2.3 */	long scsi_MediumScan(scsi_device_t *dev, void *data, unsigned long numblock, unsigned char length, int wbs, int asa, int rsd, int pra, int reladr);
/* 16.2.4 */	long scsi_Read12(scsi_device_t *dev, void *data, unsigned long numblock, unsigned long length, int dpo, int fua, int reladr);
/* 16.2.5 */	long scsi_ReadDefectData12(scsi_device_t *dev, void *data, unsigned long length, int plist, int glist, int format);
/* 16.2.6 */	long scsi_ReadGeneration(scsi_device_t *dev, void *data, unsigned long numblock, unsigned char length, int reladr);
/* 16.2.7 */	long scsi_ReadUpdatedBlock(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int dpo, int fua, int reladr, int latest);
/* 16.2.8.1 */	long scsi_SearchDataEqual12(scsi_device_t *dev, void *data, unsigned long numblock, unsigned long length, int invert, int spndat, int reladr);
/* 16.2.8.2 */	long scsi_SearchDataHigh12(scsi_device_t *dev, void *data, unsigned long numblock, unsigned long length, int invert, int spndat, int reladr);
/* 16.2.8.3 */	long scsi_SearchDataLow12(scsi_device_t *dev, void *data, unsigned long numblock, unsigned long length, int invert, int spndat, int reladr);
/* 16.2.9 */	long scsi_SetLimits12(scsi_device_t *dev, unsigned long numblock, unsigned long length, int rdinh, int wrinh);
/* 16.2.10 */	long scsi_UpdateBlock(scsi_device_t *dev, unsigned long numblock, int reladr);
/* 16.2.11 */	long scsi_Verify10_optmem(scsi_device_t *dev, unsigned long numblock, unsigned short length, int dpo, int blkvfy, int bytechk, int reladr);
/* 16.2.12 */	long scsi_Verify12(scsi_device_t *dev, unsigned long numblock, unsigned long length, int dpo, int blkvfy, int bytechk, int reladr);
/* 16.2.14 */	long scsi_Write12(scsi_device_t *dev, void *data, unsigned long numblock, unsigned long length, int dpo, int fua, int ebp, int reladr);
/* 16.2.15 */	long scsi_WriteAndVerify10_optmem(scsi_device_t *dev, void *data, unsigned long numblock, unsigned short length, int dpo, int ebp, int bytechk, int reladr);
/* 16.2.16 */	long scsi_WriteAndVerify12(scsi_device_t *dev, void *data, unsigned long numblock, unsigned long length, int dpo, int ebp, int bytechk, int reladr);

/* Medium-changer devices */

	/* Mandatory functions */	/* done */
/* 17.2.3 */	long scsi_MoveMedium(scsi_device_t *dev, unsigned short transport, unsigned short source, unsigned short dest, int invert);

	/* Optional functions */	/* done */
/* 17.2.1 */	long scsi_ExchangeMedium(scsi_device_t *dev, unsigned short transport, unsigned short source, unsigned short dest1, unsigned short dest2, int invert1, int invert2);
/* 17.2.2 */	long scsi_InitializeElementStatus(scsi_device_t *dev);
/* 17.2.4 */	long scsi_PositionToElement(scsi_device_t *dev, unsigned short transport, unsigned short dest, int invert);
/* 17.2.5 */	long scsi_ReadElementStatus(scsi_device_t *dev, void *data, unsigned long length, unsigned short start, unsigned short number, int voltag, int elttype);
/* 17.2.6 */	long scsi_RequestVolumeElementAddress(scsi_device_t *dev, void *data, unsigned long length, unsigned short element, unsigned short number, int voltag, int elttype);
/* 17.2.7 */	long scsi_Release_medchg(scsi_device_t *dev, void *data, int trdparty, int deviceid, int element, unsigned char reservation);
/* 17.2.8 */	long scsi_Reserve_medchg(scsi_device_t *dev, void *data, unsigned short length, int trdparty, int deviceid, int element, unsigned char reservation);
/* 17.2.9 */	long scsi_SendVolumeTag(scsi_device_t *dev, void *data, unsigned short length, unsigned short element, int elttype, int sendaction);

/* Communication devices */

	/* Mandatory functions */	/* done */
/* 18.2.4 */	long scsi_SendMessage6(scsi_device_t *dev, void *data, unsigned long length);

	/* Optional functions */	/* done */
/* 18.2.1 */	long scsi_GetMessage6(scsi_device_t *dev, void *data, unsigned long length);
/* 18.2.2 */	long scsi_GetMessage10(scsi_device_t *dev, void *data, unsigned short stream, unsigned short length);
/* 18.2.3 */	long scsi_GetMessage12(scsi_device_t *dev, void *data, unsigned short stream, unsigned long length);
/* 18.2.5 */	long scsi_SendMessage10(scsi_device_t *dev, void *data, unsigned short stream, unsigned short length);
/* 18.2.6 */	long scsi_SendMessage12(scsi_device_t *dev, void *data, unsigned short stream, unsigned long length);

#endif /* _SCSI_H */
