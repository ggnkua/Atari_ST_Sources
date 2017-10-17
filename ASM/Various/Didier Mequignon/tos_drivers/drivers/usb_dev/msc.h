/*
 * File:		msc.h
 * Purpose:		Mass Storage definitions
 */

#ifndef MSC_H
#define MSC_H

/* USB Mass Storage Class Endpoint numbers */
#define CONTROL_IN               0
#define CONTROL_OUT              0
#define BULK_IN                  1
#define BULK_OUT                 2

/* Interface Classes */
#define MASS_STORAGE_INTERFACE     0x08

/* MSC Subclass Codes */
#define MSC_SUBCLASS_RBC           0x01
#define MSC_SUBCLASS_SFF8020I_MMC2 0x02
#define MSC_SUBCLASS_QIC157        0x03
#define MSC_SUBCLASS_UFI           0x04
#define MSC_SUBCLASS_SFF8070I      0x05
#define MSC_SUBCLASS_SCSI          0x06

/* MSC Protocol Codes */
#define MSC_PROTOCOL_CBI_INT    0x00
#define MSC_PROTOCOL_CBI_NOINT  0x01
#define MSC_PROTOCOL_BULK_ONLY  0x50

/* MSC Request Codes */
#define MSC_REQUEST_RESET       0xFF
#define MSC_REQUEST_GET_MAX_LUN 0xFE

/* MSC Bulk-only Stage */
#define MSC_BS_CBW                0 /* Command Block Wrapper */
#define MSC_BS_DATA_OUT           1 /* Data Out Phase */
#define MSC_BS_DATA_IN            2 /* Data In Phase */
#define MSC_BS_DATA_IN_LAST       3 /* Data In Last Phase */
#define MSC_BS_DATA_IN_LAST_STALL 4 /* Data In Last Phase with Stall */
#define MSC_BS_CSW                5 /* Command Status Wrapper */
#define MSC_BS_ERROR              6 /* Error */      

/* Bulk-only Command Block Wrapper */
typedef struct _MSC_CBW
{
	uint32 dSignature;
	uint32 dTag;
	uint32 dDataLength;
	uint8 bmFlags;
	uint8 bLUN;
	uint8 bCBLength;
	uint8 CB[16];
} MSC_CBW;

#define CBW_LEN 31

/* Bulk-only Command Status Wrapper */
typedef struct _MSC_CSW
{
	uint32 dSignature;
	uint32 dTag;
	uint32 dDataResidue;
	uint8 bStatus;
} MSC_CSW;

#define CSW_LEN 13

#define MSC_CBW_Signature               0x55534243 // USBC
#define MSC_CSW_Signature               0x55534253 // USBS

/* CSW Status Definitions */
#define CSW_CMD_PASSED                  0x00
#define CSW_CMD_FAILED                  0x01
#define CSW_PHASE_ERROR                 0x02

/* SCSI Commands */
#define SCSI_TEST_UNIT_READY            0x00
#define SCSI_REQUEST_SENSE              0x03
#define SCSI_FORMAT_UNIT                0x04
#define SCSI_INQUIRY                    0x12
#define SCSI_MODE_SELECT6               0x15
#define SCSI_MODE_SENSE6                0x1A
#define SCSI_START_STOP_UNIT            0x1B
#define SCSI_MEDIA_REMOVAL              0x1E
#define SCSI_READ_FORMAT_CAPACITIES     0x23
#define SCSI_READ_CAPACITY              0x25
#define SCSI_READ10                     0x28
#define SCSI_WRITE10                    0x2A
#define SCSI_VERIFY10                   0x2F
#define SCSI_MODE_SELECT10              0x55
#define SCSI_MODE_SENSE10               0x5A

#endif /* MSC_H */
