/*
 * File:		msc.c
 * Purpose:		Mass Storage
 */

#include "usb.h"
#include "msc.h"

#ifdef USB_DEVICE
#ifdef NETWORK
#ifdef LWIP

#undef DEBUG

/* Mass Storage Memory Layout */
#define MSC_BlockSize 512
/* Max In/Out Packet Size */
#define MSC_MAX_PACKET 512

static uint8 *Memory;                 /* Ram-disk Base Address */
static uint32 MSC_MemorySize;         /* Ram-disk Size */
static uint32 MSC_BlockCount;         /* Sector Count */
static uint32 MSC_MaxPacket;          /* 64 for USB 1.1 and 512 for USB 2.0 */
static BOOL MemOK;                    /* Memory OK */
static uint32 Offset;                 /* R/W Offset */
static uint32 Length;                 /* R/W Length */
static uint32 BulkStage;              /* Bulk Stage */
uint8 BulkBuf[MSC_MAX_PACKET];        /* Bulk In/Out Buffer */
MSC_CBW CBW;                          /* Command Block Wrapper */
MSC_CSW CSW;                          /* Command Status Wrapper */
uint8 RootSector[MSC_BlockSize];      /* Master Boot Record */

extern xSemaphoreHandle xSemaphoreBDOS;
extern uint8 *address_ram_disk;
extern uint32 size_ram_disk, change_ram_disk, write_protect_ram_disk, ext_write_protect_ram_disk;
static uint32 device_reset;
static int32 timeout_wp, timeout_in, timeout_out;

static BOOL MSC_Reset(void);
static uint32 MSC_GetCBW(uint8 *buf, uint32 size);
static uint32 MSC_SetCSW(void);

static void usb_timeout(void *pvParameters)
{
#define TIMEOUT ((int32)configTICK_RATE_HZ*2)
	if(pvParameters);
	timeout_wp = timeout_in = timeout_out = -1;
	while(1)
	{
		vTaskDelay(1);
		if((timeout_wp >= 0) && (write_protect_ram_disk == FALSE))
		{
			timeout_wp++;
			if(timeout_wp >= TIMEOUT)
				timeout_wp = -1;			
			else
				ext_write_protect_ram_disk = TRUE; /* BDOS cannot write */
		}
		else
			ext_write_protect_ram_disk = FALSE;
		if(timeout_in >= 0)
		{
			timeout_in++;
			if(timeout_in >= TIMEOUT)
			{
				printf("Timeout USB BULK IN\r\n");
				usb_ep_stall(BULK_IN);
				BulkStage = MSC_BS_CBW;
				timeout_in = -1;
			}
		}
		if(timeout_out >= 0)
		{
			timeout_out++;
			if(timeout_out >= TIMEOUT*2)
			{
				printf("Timeout USB BULK OUT\r\n");
				usb_ep_stall(BULK_OUT);
				CSW.bStatus = CSW_PHASE_ERROR;
				MSC_SetCSW();
				timeout_out = -1;
			}
		}
	}
}

void init_usb_device(void)
{
	static uint8 boot[] = {0xEB,0x3C,0x90,'M','S','D','O','S','5','.','0'};
	static uint8 end_boot[] = {
	0x01,0x00,0x00,0x00, /* Hidden sectors before the partition */
	0x00,0x00,0x00,0x00,0x00,0x00,0x29,0x74,0x19,0x02,0x27,'M', 'C', 'F', '5', '4',
	'8' ,'5', ' ', 'U', 'S', 'B', 'F', 'A', 'T', '1', '6', ' ', ' ', ' ', 0x33,0xC9,
	0x8E,0xD1,0xBC,0xF0,0x7B,0x8E,0xD9,0xB8,0x00,0x20,0x8E,0xC0,0xFC,0xBD,0x00,0x7C,
	0x38,0x4E,0x24,0x7D,0x24,0x8B,0xC1,0x99,0xE8,0x3C,0x01,0x72,0x1C,0x83,0xEB,0x3A,
	0x66,0xA1,0x1C,0x7C,0x26,0x66,0x3B,0x07,0x26,0x8A,0x57,0xFC,0x75,0x06,0x80,0xCA,
	0x02,0x88,0x56,0x02,0x80,0xC3,0x10,0x73,0xEB,0x33,0xC9,0x8A,0x46,0x10,0x98,0xF7,
	0x66,0x16,0x03,0x46,0x1C,0x13,0x56,0x1E,0x03,0x46,0x0E,0x13,0xD1,0x8B,0x76,0x11,
	0x60,0x89,0x46,0xFC,0x89,0x56,0xFE,0xB8,0x20,0x00,0xF7,0xE6,0x8B,0x5E,0x0B,0x03,
	0xC3,0x48,0xF7,0xF3,0x01,0x46,0xFC,0x11,0x4E,0xFE,0x61,0xBF,0x00,0x00,0xE8,0xE6,
	0x00,0x72,0x39,0x26,0x38,0x2D,0x74,0x17,0x60,0xB1,0x0B,0xBE,0xA1,0x7D,0xF3,0xA6,
	0x61,0x74,0x32,0x4E,0x74,0x09,0x83,0xC7,0x20,0x3B,0xFB,0x72,0xE6,0xEB,0xDC,0xA0,
	0xFB,0x7D,0xB4,0x7D,0x8B,0xF0,0xAC,0x98,0x40,0x74,0x0C,0x48,0x74,0x13,0xB4,0x0E,
	0xBB,0x07,0x00,0xCD,0x10,0xEB,0xEF,0xA0,0xFD,0x7D,0xEB,0xE6,0xA0,0xFC,0x7D,0xEB,
	0xE1,0xCD,0x16,0xCD,0x19,0x26,0x8B,0x55,0x1A,0x52,0xB0,0x01,0xBB,0x00,0x00,0xE8,
	0x3B,0x00,0x72,0xE8,0x5B,0x8A,0x56,0x24,0xBE,0x0B,0x7C,0x8B,0xFC,0xC7,0x46,0xF0,
	0x3D,0x7D,0xC7,0x46,0xF4,0x29,0x7D,0x8C,0xD9,0x89,0x4E,0xF2,0x89,0x4E,0xF6,0xC6,
	0x06,0x96,0x7D,0xCB,0xEA,0x03,0x00,0x00,0x20,0x0F,0xB6,0xC8,0x66,0x8B,0x46,0xF8,
	0x66,0x03,0x46,0x1C,0x66,0x8B,0xD0,0x66,0xC1,0xEA,0x10,0xEB,0x5E,0x0F,0xB6,0xC8,
	0x4A,0x4A,0x8A,0x46,0x0D,0x32,0xE4,0xF7,0xE2,0x03,0x46,0xFC,0x13,0x56,0xFE,0xEB,
	0x4A,0x52,0x50,0x06,0x53,0x6A,0x01,0x6A,0x10,0x91,0x8B,0x46,0x18,0x96,0x92,0x33,
	0xD2,0xF7,0xF6,0x91,0xF7,0xF6,0x42,0x87,0xCA,0xF7,0x76,0x1A,0x8A,0xF2,0x8A,0xE8,
	0xC0,0xCC,0x02,0x0A,0xCC,0xB8,0x01,0x02,0x80,0x7E,0x02,0x0E,0x75,0x04,0xB4,0x42,
	0x8B,0xF4,0x8A,0x56,0x24,0xCD,0x13,0x61,0x61,0x72,0x0B,0x40,0x75,0x01,0x42,0x03,
	0x5E,0x0B,0x49,0x75,0x06,0xF8,0xC3,0x41,0xBB,0x00,0x00,0x60,0x66,0x6A,0x00,0xEB,
	0xB0,0x4E,0x54,0x4C,0x44,0x52,0x20,0x20,0x20,0x20,0x20,0x20,0x0D,0x0A,0x52,0x65,
	0x6D,0x6F,0x76,0x65,0x20,0x64,0x69,0x73,0x6B,0x73,0x20,0x6F,0x72,0x20,0x6F,0x74,
	0x68,0x65,0x72,0x20,0x6D,0x65,0x64,0x69,0x61,0x2E,0xFF,0x0D,0x0A,0x44,0x69,0x73,
	0x6B,0x20,0x65,0x72,0x72,0x6F,0x72,0xFF,0x0D,0x0A,0x50,0x72,0x65,0x73,0x73,0x20,
	0x61,0x6E,0x79,0x20,0x6B,0x65,0x79,0x20,0x74,0x6F,0x20,0x72,0x65,0x73,0x74,0x61,
	0x72,0x74,0x0D,0x0A,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAC,0xCB,0xD8,0x55,0xAA };
#if 0
	static uint8 root[] = {
	0x33,0xC0,0x8E,0xD0,0xBC,0x00,0x7C,0xFB,0x50,0x07,0x50,0x1F,0xFC,0xBE,0x1B,0x7C,
	0xBF,0x1B,0x06,0x50,0x57,0xB9,0xE5,0x01,0xF3,0xA4,0xCB,0xBE,0xBE,0x07,0xB1,0x04,
	0x38,0x2C,0x7C,0x09,0x75,0x15,0x83,0xC6,0x10,0xE2,0xF5,0xCD,0x18,0x8B,0x14,0x8B,
	0xEE,0x83,0xC6,0x10,0x49,0x74,0x16,0x38,0x2C,0x74,0xF6,0xBE,0x10,0x07,0x4E,0xAC,
	0x3C,0x00,0x74,0xFA,0xBB,0x07,0x00,0xB4,0x0E,0xCD,0x10,0xEB,0xF2,0x89,0x46,0x25,
	0x96,0x8A,0x46,0x04,0xB4,0x06,0x3C,0x0E,0x74,0x11,0xB4,0x0B,0x3C,0x0C,0x74,0x05,
	0x3A,0xC4,0x75,0x2B,0x40,0xC6,0x46,0x25,0x06,0x75,0x24,0xBB,0xAA,0x55,0x50,0xB4,
	0x41,0xCD,0x13,0x58,0x72,0x16,0x81,0xFB,0x55,0xAA,0x75,0x10,0xF6,0xC1,0x01,0x74,
	0x0B,0x8A,0xE0,0x88,0x56,0x24,0xC7,0x06,0xA1,0x06,0xEB,0x1E,0x88,0x66,0x04,0xBF,
	0x0A,0x00,0xB8,0x01,0x02,0x8B,0xDC,0x33,0xC9,0x83,0xFF,0x05,0x7F,0x03,0x8B,0x4E,
	0x25,0x03,0x4E,0x02,0xCD,0x13,0x72,0x29,0xBE,0x46,0x07,0x81,0x3E,0xFE,0x7D,0x55,
	0xAA,0x74,0x5A,0x83,0xEF,0x05,0x7F,0xDA,0x85,0xF6,0x75,0x83,0xBE,0x27,0x07,0xEB,
	0x8A,0x98,0x91,0x52,0x99,0x03,0x46,0x08,0x13,0x56,0x0A,0xE8,0x12,0x00,0x5A,0xEB,
	0xD5,0x4F,0x74,0xE4,0x33,0xC0,0xCD,0x13,0xEB,0xB8,0x00,0x00,0x00,0x00,0x00,0x00,
	0x56,0x33,0xF6,0x56,0x56,0x52,0x50,0x06,0x53,0x51,0xBE,0x10,0x00,0x56,0x8B,0xF4,
	0x50,0x52,0xB8,0x00,0x42,0x8A,0x56,0x24,0xCD,0x13,0x5A,0x58,0x8D,0x64,0x10,0x72,
	0x0A,0x40,0x75,0x01,0x42,0x80,0xC7,0x02,0xE2,0xF7,0xF8,0x5E,0xC3,0xEB,0x74,0x49,
	0x6E,0x76,0x61,0x6C,0x69,0x64,0x20,0x70,0x61,0x72,0x74,0x69,0x74,0x69,0x6F,0x6E,
	0x20,0x74,0x61,0x62,0x6C,0x65,0x00,0x45,0x72,0x72,0x6F,0x72,0x20,0x6C,0x6F,0x61,
	0x64,0x69,0x6E,0x67,0x20,0x6F,0x70,0x65,0x72,0x61,0x74,0x69,0x6E,0x67,0x20,0x73,
	0x79,0x73,0x74,0x65,0x6D,0x00,0x4D,0x69,0x73,0x73,0x69,0x6E,0x67,0x20,0x6F,0x70,
	0x65,0x72,0x61,0x74,0x69,0x6E,0x67,0x20,0x73,0x79,0x73,0x74,0x65,0x6D,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x8B,0xFC,0x1E,0x57,0x8B,0xF5,0xCB,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,
	0x00,0x00,0x04,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x55,0xAA };
	memcpy(RootSector, root, sizeof(root));
#else
	memset(RootSector, 0, sizeof(RootSector)); 
	RootSector[0x1FE] = 0x55;
	RootSector[0x1FF] = 0xAA;
	RootSector[0x1BE + 0x04] = 0x04; /* FAT16 up to 32M */
	RootSector[0x1BE + 0x08] = 0x01; /* Relative offset to the partition in sectors (LBA) */
#endif
	Memory = address_ram_disk;
	MSC_MemorySize = size_ram_disk + sizeof(RootSector);
	/* Fix boot sector for MSDOS */
	memcpy(&Memory[0], boot, sizeof(boot));
	Memory[0x15] = 0xF8; /* Media */
	memcpy(&Memory[0x1C], end_boot, sizeof(end_boot));
	RootSector[0x1BE + 0x0C] = Memory[0x13]; /* Size of the partition in sectors */
	RootSector[0x1BE + 0x0D] = Memory[0x14];
	MSC_BlockCount = MSC_MemorySize / MSC_BlockSize;
	MSC_MaxPacket = 64;
	device_reset = FALSE;
	xTaskCreate(usb_timeout, "USBT", configMINIMAL_STACK_SIZE, NULL, 6, NULL);
	MSC_Reset();
	usb_device_init(); /* USB driver init */
}

static BOOL MSC_Reset(void)
{
	BulkStage = MSC_BS_CBW;
	return(TRUE);
}

static BOOL MSC_WriteProtect(void)
{
	return(write_protect_ram_disk ? TRUE : FALSE);	
}

static BOOL MSC_GetMaxLUN(uint8 *EP0Buf)
{
	EP0Buf[0] = 0; /* No LUN associated with this device */
	return(TRUE);
}

static uint32 MSC_MemoryRead(void)
{
	uint32 size, error, bytes_sent = 0;
	if(Length > MSC_MaxPacket)
		size = MSC_MaxPacket;
	else
		size = Length;
	if((Offset + size) > MSC_MemorySize)
	{
		size = MSC_MemorySize - Offset;
		BulkStage = MSC_BS_DATA_IN_LAST_STALL;
	}
	error = usb_ep_is_busy(BULK_IN);
	if(error != USB_EP_IS_FREE)
		printf("usb_ep_is_busy EP%d error:%s\r\n", BULK_IN, (error == USB_EP_IS_BUSY) ? "BUSY" : "RESET");
	else
	{
		if(Offset >= MSC_BlockSize)
			error = usb_tx_data(BULK_IN, &Memory[Offset - MSC_BlockSize], size);
		else
		{
			if(size > MSC_BlockSize)
			{
				size = MSC_BlockSize;
				BulkStage = MSC_BS_DATA_IN_LAST_STALL;
			}
			error = usb_tx_data(BULK_IN, &RootSector[Offset], size);
		}
		if(error != USB_CMD_SUCCESS)
			printf("usb_tx_data error:%d\r\n", error);
		else
		{
			bytes_sent = size;
			Offset += size;
			Length -= size;
			CSW.dDataResidue -= size;
		}
	}
	if(Length == 0)
		BulkStage = MSC_BS_DATA_IN_LAST;
	if(BulkStage != MSC_BS_DATA_IN)
		CSW.bStatus = CSW_CMD_PASSED;
	return(bytes_sent);
}

static uint32 MSC_MemoryWrite(uint8 *buf, uint32 size)
{
	uint32 bytes_sent = 0;
	if((Offset + size) > MSC_MemorySize)
	{
		size = MSC_MemorySize - Offset;
		BulkStage = MSC_BS_CSW;
		usb_ep_stall(BULK_OUT);
	}
	if(Offset >= MSC_BlockSize)
	{
	  while(xSemaphoreAltTake(xSemaphoreBDOS, portMAX_DELAY) != pdTRUE);
		memcpy(&Memory[Offset - MSC_BlockSize], buf, size);
		change_ram_disk = 2; /* Media Change */
  	xSemaphoreAltGive(xSemaphoreBDOS);
	}
	else
	{
		if(size > MSC_BlockSize)
		{
			size = MSC_BlockSize;
			BulkStage = MSC_BS_CSW;
			usb_ep_stall(BULK_OUT);
		}
		memcpy(&RootSector[Offset], buf, size);
	}
	Offset += size;
	Length -= size;
	CSW.dDataResidue -= size;
	if((Length == 0) || (BulkStage == MSC_BS_CSW))
	{
		CSW.bStatus = CSW_CMD_PASSED;
		bytes_sent = MSC_SetCSW();
	}
	return(bytes_sent);
}

static uint32 MSC_MemoryVerify(uint8 *buf, uint32 size)
{
	uint32 bytes_sent = 0;
	if((Offset + size) > MSC_MemorySize)
	{
		size = MSC_MemorySize - Offset;
		BulkStage = MSC_BS_CSW;
		usb_ep_stall(BULK_OUT);
	}
	if(Offset >= MSC_BlockSize)
	{
	  while(xSemaphoreAltTake(xSemaphoreBDOS, portMAX_DELAY) != pdTRUE);
		if(memcmp(&Memory[Offset - MSC_BlockSize], buf, size))
			MemOK = FALSE;
  	xSemaphoreAltGive(xSemaphoreBDOS);
	}
	else
	{
		if(size > MSC_BlockSize)
		{
			size = MSC_BlockSize;
			BulkStage = MSC_BS_CSW;
			usb_ep_stall(BULK_OUT);
		}
		if(memcmp(&RootSector[Offset], buf, size))
			MemOK = FALSE;
	}
	Offset += size;
	Length -= size;
	CSW.dDataResidue -= size;
	if((Length == 0) || (BulkStage == MSC_BS_CSW))
	{
		CSW.bStatus = (MemOK) ? CSW_CMD_PASSED : CSW_CMD_FAILED;
		bytes_sent= MSC_SetCSW();
	}
	return(bytes_sent);
}

static int32 MSC_RWSetup(void)
{
	uint32 n;
	/* Logical Block Address of First Block */
	n = *(uint32 *)&CBW.CB[2];
	Offset = n * MSC_BlockSize;
	/* Number of Blocks to transfer */
	n = (uint32)(CBW.CB[7] <<  8) | (CBW.CB[8] <<  0);
	Length = n * MSC_BlockSize;
	if(CBW.dDataLength != Length)
	{
		usb_ep_stall(BULK_IN);
		usb_ep_stall(BULK_OUT);
		CSW.bStatus = CSW_PHASE_ERROR;
		return((int32)MSC_SetCSW());
	}
	return(-1); /* OK */
}
           
static int32 DataInFormat(void)
{
	if(CBW.dDataLength == 0)
	{
		CSW.bStatus = CSW_PHASE_ERROR;
		return((int32)MSC_SetCSW());
	}
	if((CBW.bmFlags & 0x80) == 0)
	{
		usb_ep_stall(BULK_OUT);
		CSW.bStatus = CSW_PHASE_ERROR;
		return((int32)MSC_SetCSW());
	}
	return(-1); /* OK */
}

static uint32 DataInTransfer(uint8 *buf, uint32 size)
{
	uint32 error, bytes_sent = 0;
	if(size > CBW.dDataLength)
		size = CBW.dDataLength;
	error = usb_ep_is_busy(BULK_IN);
	if(error != USB_EP_IS_FREE)
		printf("usb_ep_is_busy EP%d error:%s\r\n", BULK_IN, (error == USB_EP_IS_BUSY) ? "BUSY" : "RESET");
	else
	{
		error = usb_tx_data(BULK_IN, buf, size);
		if(error != USB_CMD_SUCCESS)
			printf("usb_tx_data error:%d\r\n", error);
		else
		{
			bytes_sent = size;
			CSW.dDataResidue -= size;
		}
	}
	BulkStage = MSC_BS_DATA_IN_LAST;
	CSW.bStatus = CSW_CMD_PASSED;
	timeout_in = 0;
	return(bytes_sent);
}

static void SetCSWbStatus(void)
{
	if(xSemaphoreAltTake(xSemaphoreBDOS, 0) != pdTRUE)
		CSW.bStatus = CSW_CMD_FAILED;
	else
	{
		CSW.bStatus = CSW_CMD_PASSED;
		xSemaphoreAltGive(xSemaphoreBDOS);
	}
}

static uint32 MSC_TestUnitReady(void)
{
#ifdef DEBUG
	printf("TestUnitReady\r\n");
#endif
	timeout_wp = 0;
	if(CBW.dDataLength)
	{
		if(CBW.bmFlags & 0x80)
			usb_ep_stall(BULK_IN);
		else
			usb_ep_stall(BULK_OUT);
	}
	SetCSWbStatus();
	return(MSC_SetCSW());
}

static uint32 MSC_RequestSense(void)
{
	uint32 ret;
#ifdef DEBUG
	printf("RequestSense\r\n");
#endif
	if((ret = DataInFormat()) != -1)
		return(ret);
	BulkBuf[0] = 0x70; /* Response Code */
	BulkBuf[1] = 0x00;
	BulkBuf[2] = 0x02; /* Sense Key */
	BulkBuf[3] = 0x00;
	BulkBuf[4] = 0x00;
	BulkBuf[5] = 0x00;
	BulkBuf[6] = 0x00;
	BulkBuf[7] = 0x0A; /* Additional Length */
	BulkBuf[8] = 0x00;
	BulkBuf[9] = 0x00;
	BulkBuf[10] = 0x00;
	BulkBuf[11] = 0x00;
	BulkBuf[12] = 0x30; /* ASC */
	BulkBuf[13] = 0x01; /* ASCQ */
	BulkBuf[14] = 0x00;
	BulkBuf[15] = 0x00;
	BulkBuf[16] = 0x00;
	BulkBuf[17] = 0x00;
	return(DataInTransfer(BulkBuf, 18));
}

static uint32 MSC_Inquiry(void)
{
	uint32 ret;
#ifdef DEBUG
	printf("Inquiry\r\n");
#endif
	if((ret = DataInFormat()) != -1)
		return(ret);
	BulkBuf[0] = 0x00; /* Direct Access Device */
	BulkBuf[1] = 0x80; /* RMB = 1: Removable Medium */
	BulkBuf[2] = 0x00; /* Version: No conformance claim to standard */
	BulkBuf[3] = 0x01;
	BulkBuf[4] = 36-4; /* Additional Length */
	BulkBuf[5] = 0x80; /* SCCS = 1: Storage Controller Component */
	BulkBuf[6] = 0x00;
	BulkBuf[7] = 0x00;
	BulkBuf[8] =  'F'; /* Vendor Identification */
	BulkBuf[9] =  'r';
	BulkBuf[10] = 'e';
	BulkBuf[11] = 'e';
	BulkBuf[12] = 's';
	BulkBuf[13] = 'c';
	BulkBuf[14] = 'a';
	BulkBuf[15] = 'l';
	BulkBuf[16] = 'M'; /* Product Identification */
	BulkBuf[17] = 'C';
	BulkBuf[18] = 'F';
	BulkBuf[19] = '5';
	BulkBuf[20] = '4';
	BulkBuf[21] = '8';
	BulkBuf[22] = '5';
	BulkBuf[23] = ' ';
	BulkBuf[24] = 'D';
	BulkBuf[25] = 'i';
	BulkBuf[26] = 's';
	BulkBuf[27] = 'k';
	BulkBuf[28] = ' ';
	BulkBuf[29] = ' ';
	BulkBuf[30] = ' ';
	BulkBuf[31] = ' ';
	BulkBuf[32] = '1'; /* Product Revision Level */
	BulkBuf[33] = '.';
	BulkBuf[34] = '0';
	BulkBuf[35] = ' ';
	return(DataInTransfer(BulkBuf, 36));
}

static uint32 MSC_ModeSense6(void)
{
	uint32 ret;
#ifdef DEBUG
	printf("ModeSense6\r\n");
#endif
	if((ret = DataInFormat()) != -1)
		return(ret);
	BulkBuf[0] = 0x03;
	BulkBuf[1] = 0x00;
	BulkBuf[2] = 0x00;
	BulkBuf[3] = 0x00;
	return(DataInTransfer(BulkBuf, 4));
}

static uint32 MSC_ModeSense10(void)
{
	uint32 ret;
#ifdef DEBUG
	printf("ModeSense10\r\n");
#endif
	if((ret = DataInFormat()) != -1)
		return(ret);
	BulkBuf[0] = 0x00;
	BulkBuf[1] = 0x06;
	BulkBuf[2] = 0x00;
	if(MSC_WriteProtect())
		BulkBuf[3] = 0x80;
	else
		BulkBuf[3] = 0x00;
	BulkBuf[4] = 0x00;
	BulkBuf[5] = 0x00;
	BulkBuf[6] = 0x00;
	BulkBuf[7] = 0x00;
	return(DataInTransfer(BulkBuf, 8));
}

static uint32 MSC_ReadCapacity(void)
{
	uint32 ret;
#ifdef DEBUG
	printf("ReadCapacity\r\n");
#endif
	if((ret = DataInFormat()) != -1)
		return(ret);
	*(uint32 *)&BulkBuf[0] = MSC_BlockCount - 1; /* Last Logical Block */
	*(uint32 *)&BulkBuf[4] = MSC_BlockSize; /* Block Length */
	return(DataInTransfer(BulkBuf, 8));
}

static uint32 MSC_ReadFormatCapacity(void)
{
	uint32 ret;
#ifdef DEBUG
	printf("ReadFormatCapacity\r\n");
#endif
	if((ret = DataInFormat()) != -1)
		return(ret);
	BulkBuf[0] = 0x00;
	BulkBuf[1] = 0x00;
	BulkBuf[2] = 0x00;
	BulkBuf[3] = 0x08; /* Capacity List Length */
	*(uint32 *)&BulkBuf[4] = MSC_BlockCount; /* Block Count */
	*(uint32 *)&BulkBuf[8] = MSC_BlockSize; /* Block Length */
	BulkBuf[8] = 0x02; /* Descriptor Code: Formatted Media */
	return(DataInTransfer(BulkBuf, 12));
}

static uint32 MSC_GetCBW(uint8 *buf, uint32 size)
{
	uint32 ret, bytes_sent = 0;
	memcpy((uint8 *)&CBW, buf, CBW_LEN);
	swp68l(&CBW.dDataLength);
	if((size == CBW_LEN) && (CBW.dSignature == MSC_CBW_Signature))
	{
		/* Valid CBW */
		CSW.dTag = CBW.dTag;
		CSW.dDataResidue = CBW.dDataLength;
		if((CBW.bLUN != 0) || (CBW.bCBLength < 1) || (CBW.bCBLength > 16))
		{
			CSW.bStatus = CSW_CMD_FAILED;
			bytes_sent = MSC_SetCSW();
		}
		else
		{
			switch(CBW.CB[0])
			{
				case SCSI_TEST_UNIT_READY: bytes_sent = MSC_TestUnitReady(); break;
				case SCSI_REQUEST_SENSE: bytes_sent = MSC_RequestSense(); break;
				case SCSI_INQUIRY: bytes_sent = MSC_Inquiry(); break;
				case SCSI_MODE_SENSE6: bytes_sent = MSC_ModeSense6(); break;
				case SCSI_MODE_SENSE10: bytes_sent = MSC_ModeSense10(); break;
				case SCSI_READ_FORMAT_CAPACITIES: bytes_sent = MSC_ReadFormatCapacity(); break;
				case SCSI_READ_CAPACITY: bytes_sent = MSC_ReadCapacity(); break;
				case SCSI_READ10:
#ifdef DEBUG
					printf("MemoryRead10 %d sector(s) at sector %d\r\n",
					 (uint32)(CBW.CB[7] <<  8) | (CBW.CB[8] <<  0), *(uint32 *)&CBW.CB[2]);
#endif
					if((ret = MSC_RWSetup()) == -1) /* OK */
					{
						if((CBW.bmFlags & 0x80) != 0)
						{
							BulkStage = MSC_BS_DATA_IN;
							bytes_sent = MSC_MemoryRead();
							timeout_in = 0;
						}
						else
						{
							usb_ep_stall(BULK_OUT);
							CSW.bStatus = CSW_PHASE_ERROR;
							bytes_sent = MSC_SetCSW();
						}
					}
					else
						bytes_sent = ret;
					break;
				case SCSI_WRITE10:
					if((ret = MSC_RWSetup()) == -1) /* OK */
					{
						if((CBW.bmFlags & 0x80) == 0)
						{
						 	if(usb_set_rx_buffer(BULK_OUT, CBW.dDataLength)) /* malloc */
							{
								BulkStage = MSC_BS_DATA_OUT;
								MemOK = TRUE;
								timeout_out = 0;
							}
							else
							{
								usb_ep_stall(BULK_IN);
								CSW.bStatus = CSW_CMD_FAILED;
								bytes_sent = MSC_SetCSW();
							}
						}
						else
						{
							usb_ep_stall(BULK_IN);
							CSW.bStatus = CSW_PHASE_ERROR;
							bytes_sent = MSC_SetCSW();
						}
					}
					else
						bytes_sent = ret;
#ifdef DEBUG
					printf("MemoryWrite10 %d sector(s) at sector %d\r\n",
					 (uint32)(CBW.CB[7] <<  8) | (CBW.CB[8] <<  0), *(uint32 *)&CBW.CB[2]);
#endif
					break;
				case SCSI_VERIFY10:
					if((ret = MSC_RWSetup()) == -1) /* OK */
					{
						if((CBW.bmFlags & 0x80) == 0)
						{
						 	if(usb_set_rx_buffer(BULK_OUT, CBW.dDataLength)) /* malloc */
							{
								BulkStage = MSC_BS_DATA_OUT;
								MemOK = TRUE;
								timeout_out = 0;
							}
							else
							{
								usb_ep_stall(BULK_IN);
								CSW.bStatus = CSW_CMD_FAILED;
								bytes_sent = MSC_SetCSW();
							}
						}
						else
						{						
							usb_ep_stall(BULK_IN);
							CSW.bStatus = CSW_PHASE_ERROR;
							bytes_sent = MSC_SetCSW();
						}
					}
					else
						bytes_sent = ret;
#ifdef DEBUG
						printf("MemoryVerify10 %d sector(s) at sector %d\r\n",
						 (uint32)(CBW.CB[7] <<  8) | (CBW.CB[8] <<  0), *(uint32 *)&CBW.CB[2]);
#endif
					break;
				default:
#ifdef DEBUG
					printf("SCSI 0x%02x unknow command\r\n", CBW.CB[0]);
#endif
					CSW.bStatus = CSW_CMD_FAILED;
					bytes_sent = MSC_SetCSW();
					break;
			}
		}
	}
	else
	{
		printf("USB Invalid CBW (size:%d, signature:0x%x)\r\n", size, CBW.dSignature);
		/* Invalid CBW */
		usb_ep_stall(BULK_IN);
		usb_ep_stall(BULK_OUT);
		BulkStage = MSC_BS_ERROR;
	}
	return(bytes_sent);
}

static uint32 MSC_SetCSW(void)
{
	uint32 error, bytes_sent = 0;
	CSW.dSignature = MSC_CSW_Signature;
	swp68l(&CSW.dDataResidue);
	error = usb_ep_is_busy(BULK_IN);
	if(error != USB_EP_IS_FREE)
		printf("usb_ep_is_busy EP%d error:%s\r\n", BULK_IN, (error == USB_EP_IS_BUSY) ? "BUSY" : "RESET");
	else
	{
		error= usb_tx_data(BULK_IN, (uint8 *)&CSW, CSW_LEN);
		if(error != USB_CMD_SUCCESS)
			printf("usb_tx_data error:%d\r\n", error);
		else
			bytes_sent = CSW_LEN;
	}
	BulkStage = MSC_BS_CSW;
	timeout_in = 0;
	timeout_out = -1;
	return(bytes_sent);
}

static uint32 MSC_BulkIn(void)
{
	uint32 bytes_sent = 0;
/*	printf("MSC_BulkIn BulkStage:%s\r\n",
	 BulkStage == MSC_BS_CBW ? "MSC_BS_CBW" :
	 BulkStage == MSC_BS_DATA_OUT ? "MSC_BS_DATA_OUT" :
	 BulkStage == MSC_BS_DATA_IN ? "MSC_BS_DATA_IN" :
	 BulkStage == MSC_BS_DATA_IN_LAST ? "MSC_BS_DATA_IN_LAST" :
	 BulkStage == MSC_BS_DATA_IN_LAST_STALL ? "MSC_BS_DATA_IN_LAST_STALL" :
	 BulkStage == MSC_BS_CSW ? "MSC_BS_CSW" : "MSC_BS_ERROR");
*/
	switch(BulkStage)
	{
		case MSC_BS_DATA_IN:
			if(CBW.CB[0] == SCSI_READ10)
				bytes_sent = MSC_MemoryRead();
			timeout_in = 0;
			break;
		case MSC_BS_DATA_IN_LAST_STALL:
			usb_ep_stall(BULK_IN);
		case MSC_BS_DATA_IN_LAST:
			bytes_sent = MSC_SetCSW();
			break;
		case MSC_BS_CSW:
			BulkStage = MSC_BS_CBW;
			timeout_in = -1;
			break;
	}
/*	printf("=> BulkStage:%s\r\n",
	 BulkStage == MSC_BS_CBW ? "MSC_BS_CBW" :
	 BulkStage == MSC_BS_DATA_OUT ? "MSC_BS_DATA_OUT" :
	 BulkStage == MSC_BS_DATA_IN ? "MSC_BS_DATA_IN" :
	 BulkStage == MSC_BS_DATA_IN_LAST ? "MSC_BS_DATA_IN_LAST" :
	 BulkStage == MSC_BS_DATA_IN_LAST_STALL ? "MSC_BS_DATA_IN_LAST_STALL" :
	 BulkStage == MSC_BS_CSW ? "MSC_BS_CSW" : "MSC_BS_ERROR");
*/
	return(bytes_sent);
}

static uint32 MSC_BulkOut(uint8 *buf, uint32 size)
{
	uint32 bytes_sent = 0;
/*	printf("MSC_BulkOut BulkStage:%s\r\n",
	 BulkStage == MSC_BS_CBW ? "MSC_BS_CBW" :
	 BulkStage == MSC_BS_DATA_OUT ? "MSC_BS_DATA_OUT" :
	 BulkStage == MSC_BS_DATA_IN ? "MSC_BS_DATA_IN" :
	 BulkStage == MSC_BS_DATA_IN_LAST ? "MSC_BS_DATA_IN_LAST" :
	 BulkStage == MSC_BS_DATA_IN_LAST_STALL ? "MSC_BS_DATA_IN_LAST_STALL" :
	 BulkStage == MSC_BS_CSW ? "MSC_BS_CSW" : "MSC_BS_ERROR");
*/
	switch(BulkStage)
	{
		case MSC_BS_CBW:
			bytes_sent = MSC_GetCBW(buf, size);
			break;
		case MSC_BS_DATA_OUT:
			switch(CBW.CB[0])
			{
				case SCSI_WRITE10: bytes_sent = MSC_MemoryWrite(buf, size); break;
				case SCSI_VERIFY10: bytes_sent = MSC_MemoryVerify(buf, size); break;
			}
			timeout_out = 0;
      break;
		default:
			usb_ep_stall(BULK_OUT);
			CSW.bStatus = CSW_PHASE_ERROR;
			bytes_sent = MSC_SetCSW();
			break;
	}

/*	printf("=> BulkStage:%s\r\n",
	 BulkStage == MSC_BS_CBW ? "MSC_BS_CBW" :
	 BulkStage == MSC_BS_DATA_OUT ? "MSC_BS_DATA_OUT" :
	 BulkStage == MSC_BS_DATA_IN ? "MSC_BS_DATA_IN" :
	 BulkStage == MSC_BS_DATA_IN_LAST ? "MSC_BS_DATA_IN_LAST" :
	 BulkStage == MSC_BS_DATA_IN_LAST_STALL ? "MSC_BS_DATA_IN_LAST_STALL" :
	 BulkStage == MSC_BS_CSW ? "MSC_BS_CSW" : "MSC_BS_ERROR");
*/
	return(bytes_sent);
}

uint32 usb_endpoint(uint32 epnum, uint8 *buf, uint32 size)
{
	uint32 bytes_sent = 0;
	switch(epnum)
	{
		case BULK_OUT: bytes_sent = MSC_BulkOut(buf, size); break;
		case BULK_IN: bytes_sent = MSC_BulkIn(); break;
  }
  return(bytes_sent);
}

void usb_vendreq_service(uint8 bmRequestType, uint8 bRequest, uint16 wValue, uint16 wIndex, uint16 wLength)
{
	static uint8 value;
	if(bmRequestType < IN)
	{
		/* Direction of data transfer is from Host to Device */
		if((bmRequestType == (CLASS | RQ_INTERFACE))
		 && (bRequest == MSC_REQUEST_RESET)
		 && MSC_Reset())
		{
			usb_vendreq_done(OTHER_ERROR);
			return;
		}
	}
	else
	{
		/* Direction of data transfer is from Device to Host */
		if((bmRequestType == (IN | CLASS | RQ_INTERFACE))
		 && (bRequest == MSC_REQUEST_GET_MAX_LUN)
		 && (wLength == 1) && MSC_GetMaxLUN(&value))
		{
			usb_vendreq_done(SUCCESS);
			usb_tx_data(CONTROL_IN, &value, (uint32)wLength);
			return;
		}
	}
	usb_vendreq_done(NOT_SUPPORTED_COMMAND);
}

void usb_devcfg_notice(uint8 flags, uint8 value, uint32 altsetting)
{
	/* Device is configured */
	if(flags & CONFIGURATION_CHG)
		device_reset = FALSE;
	if(altsetting);
}

void usb_ep_tx_done(uint32 epnum)
{
	if(epnum);
}

void usb_ep_rx_done(uint32 epnum, uint8 status)
{
	if(epnum);
	if(status);
}

void usb_ep_halt(uint32 epnum)
{
	if(epnum);
}

void usb_ep_unhalt(uint32 epnum)
{
	if(epnum);
}

void usb_buschg_notice(uint32 status, uint32 hs)
{
	if(status == RESET)
	{
		if(hs)
			MSC_MaxPacket = MSC_MAX_PACKET; /* USB 2.0 */
		else
			MSC_MaxPacket = 64;             /* USB 1.10 */
		device_reset = TRUE;
		timeout_in = timeout_out = -1;
		printf("USB reset %s\r\n", hs ? "High-Speed" : "Full-Speed");
	}
}

void usb_fifo_event(uint32 epnum, uint8 event)
{
	if(epnum);
	if(event);
}

#endif /* LWIP */
#endif /* NETWORK */
#endif /* USB_DEVICE */
