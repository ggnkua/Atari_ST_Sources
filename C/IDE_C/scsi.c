#include <stdio.h>

#include "main.h"
#include "ide_low.h"
#include "ide_high.h"
#include "acsi1.h"
#include "scsi.h"
#include "porty.h"

#define SHOW_CMD  0

extern CMND AcsiCmnd;
extern DriveParams Master,Slave;

extern char ACSI_LastError, SCSI_ASC, SCSI_ASCQ;
//---------------------------------------------
void SCSI_ProcessCommand(char length)
{
unsigned char a,b,i;
char FromMaster;

SetBit(ACSI_o,ACSI_INT); 			// INT to H, should do nothing, but just to be shure

//printf("1->");

switch(AcsiCmnd.cmd[2] & 0xE0)		// check the device #
	{
	case 0x00:	FromMaster = 1; break; // device # 0
	case 0x20:	FromMaster = 0; break; // device # 1
	
	default:	SCSI_SK   = SCSI_E_IllegalRequest;		// other devices = error 
				SCSI_ASC  = SCSI_ASC_LU_NOT_SUPPORTED;
				SCSI_ASCQ = SCSI_ASCQ_LU_NOT_SUPPORTED;
				ACSI_SendStatus(ACSI_S_ERROR,1); 

//				AcsiCmnd.Active = 0;		 			// deactivate; a sign that we processed the command
				return; break;	
	}

// now check that if the wanted drive is present
if((FromMaster && !Master.Present) || (!FromMaster && !Slave.Present))
	{
	SCSI_SK	   	   = SCSI_E_IllegalRequest;		   // the device # is invalid  
	SCSI_ASC       = SCSI_ASC_LU_NOT_SUPPORTED;
	SCSI_ASCQ      = SCSI_ASCQ_LU_NOT_SUPPORTED;
	ACSI_SendStatus(ACSI_S_ERROR,FromMaster); 

//	AcsiCmnd.Active = 0;		 			// deactivate; a sign that we processed the command
	return;
	} 
//------------------------------------------
switch(AcsiCmnd.cmd[1])			
	{
	case SCSI_C_READ_CAPACITY: 		SCSI_ReadCapacity(FromMaster); 
		 							break;

	case SCSI_C_INQUIRY:			ICD_SCSI6_to_ACSI();
		 							SCSI_Inquiry(FromMaster);
		 							break;
  	//------------------------------
	// commands with length 6 bytes
/*
	case SCSI_C_WRITE6:	  	   	
	case SCSI_C_READ6:
	case SCSI_C_START_STOP_UNIT:
	case SCSI_C_FORMAT_UNIT:
	case SCSI_C_REQUEST_SENSE:
	case SCSI_C_TEST_UNIT_READY:	
*/
  	//------------------------------
	// commands with length 10 bytes
/*
	case SCSI_C_WRITE10:
	case SCSI_C_READ10:
	case SCSI_C_WRITE_LONG:
	case SCSI_C_READ_LONG:
	case SCSI_C_READ_CAPACITY:
*/	
  	//------------------------------
	default:
				printf("\nICD (%d): ", length);
				
				printf("%x %x %x %x ", AcsiCmnd.cmd[0], AcsiCmnd.cmd[1], AcsiCmnd.cmd[2], AcsiCmnd.cmd[3]);
				printf("%x %x %x %x ", AcsiCmnd.cmd[4], AcsiCmnd.cmd[5], AcsiCmnd.cmd[6], AcsiCmnd.cmd[7]);
				printf("%x %x %x", AcsiCmnd.cmd[8], AcsiCmnd.cmd[9], AcsiCmnd.cmd[10]);
				
				SCSI_SK	  = SCSI_E_IllegalRequest; 
				SCSI_ASC  = SCSI_ASC_InvalidCommandOperationCode;
				SCSI_ASCQ = SCSI_ASCQ_NO_ADDITIONAL_SENSE;
				
				ACSI_SendStatus(ACSI_S_ERROR,FromMaster);
				break; 
	}
	
//AcsiCmnd.Active = 0;
}
//---------------------------------------------
void SCSI_ReadCapacity(char FromMaster)
{	 // return disk capaticy and sector size
DriveParams *What;

if(FromMaster)	  	
	What = &Master;
else
	What = &Slave;

ACSI_DataIn(What->LBACapacity_H);	   // return capacity
ACSI_DataIn(What->LBACapacity_MH);
ACSI_DataIn(What->LBACapacity_ML);
ACSI_DataIn(What->LBACapacity_L);

ACSI_DataIn(0);					  	   // return sector size 
ACSI_DataIn(0);
ACSI_DataIn(2);
ACSI_DataIn(0);

SCSI_SK   = SCSI_E_NoSense;	// no error
SCSI_ASC  = SCSI_ASC_NO_ADDITIONAL_SENSE;
SCSI_ASCQ = SCSI_ASCQ_NO_ADDITIONAL_SENSE;
				
ACSI_SendStatus(ACSI_S_OK,FromMaster);
}
//---------------------------------------------
void ICD_SCSI6_to_ACSI(void)
{
AcsiCmnd.cmd[0] = AcsiCmnd.cmd[1];
AcsiCmnd.cmd[1] = AcsiCmnd.cmd[2];
AcsiCmnd.cmd[2] = AcsiCmnd.cmd[3];
AcsiCmnd.cmd[3] = AcsiCmnd.cmd[4];
AcsiCmnd.cmd[4] = AcsiCmnd.cmd[5];
AcsiCmnd.cmd[5] = AcsiCmnd.cmd[6];
}
//---------------------------------------------

