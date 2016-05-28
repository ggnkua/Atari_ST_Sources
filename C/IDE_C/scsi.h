// commands with length 6 bytes
#define SCSI_C_WRITE6	  	   	0x0a
#define SCSI_C_READ6		   	0x08
#define SCSI_C_START_STOP_UNIT	0x1b	
#define SCSI_C_FORMAT_UNIT		0x04	
#define SCSI_C_INQUIRY			0x12	
#define SCSI_C_REQUEST_SENSE	0x03	
#define SCSI_C_TEST_UNIT_READY	0x00	

// commands with length 10 bytes
#define SCSI_C_WRITE10			0x2a
#define SCSI_C_READ10			0x28
#define SCSI_C_WRITE_LONG		0x3f
#define SCSI_C_READ_LONG		0x3e
#define SCSI_C_READ_CAPACITY	0x25

// errors
#define SCSI_E_NoSense			0x00
#define SCSI_E_RecoveredError	0x01
#define SCSI_E_NotReady			0x02
#define SCSI_E_MediumError		0x03
#define SCSI_E_HardwareError	0x04
#define SCSI_E_IllegalRequest	0x05
#define SCSI_E_UnitAttention	0x06
#define SCSI_E_DataProtect		0x07
#define SCSI_E_BlankCheck		0x08
#define SCSI_E_VendorSpecific	0x09
#define SCSI_E_CopyAborted		0x0a
#define SCSI_E_AbortedCommand	0x0b
#define SCSI_E_Equal			0x0c
#define SCSI_E_VolumeOverflow	0x0d
#define SCSI_E_Miscompare		0x0e
//------------------------------------------------------
// SCSI ADITIONAL SENSE CODES
#define SCSI_ASC_LU_NOT_READY				0x04
#define SCSI_ASC_LU_NOT_SUPPORTED			0x25
#define SCSI_ASC_NO_ADDITIONAL_SENSE		0x00

// SCSI ADITIONAL SENSE CODE QUALIFIER

#define SCSI_ASCQ_CAUSE_NOT_REPORTABLE		0x00
#define SCSI_ASCQ_FORMAT_IN_PROGRESS		0x04
#define SCSI_ASCQ_NO_ADDITIONAL_SENSE		0x00
#define SCSI_ASCQ_LU_NOT_SUPPORTED			0x00

// ASC & ASCQ
#define SCSI_ASC_InvalidFieldInCDB					0x24
#define SCSI_ASCQ_InvalidFieldInCDB					0x00

#define SCSI_ASC_InvalidCommandOperationCode		0x20
#define SCSI_ASCQ_NoAdditionalASCQ					0x00

#define SCSI_SK			ACSI_LastError
// function that processes any SCSI command
void SCSI_ProcessCommand(char length);

void SCSI_ReadCapacity(char FromMaster);

// convert ICD SCSI 6-byte command to normal ACSI command 
void ICD_SCSI6_to_ACSI(void);
