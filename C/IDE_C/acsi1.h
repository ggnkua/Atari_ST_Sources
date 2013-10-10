//#define ACSI_IsInput()	{DDRC = 0x00; PORTC=0xff;}	// internal pull-up
#define ACSI_IsInput()	{DDRC = 0x00;}	// internal pull-up
#define ACSI_IsOutput()	{DDRC = 0xff;}

//---------------------------------------------
// ACSI COMMANDS
#define ACSI_C_DriveReady		0x00
#define ACSI_C_RestoreTo0		0x01
#define ACSI_C_RequestSense		0x03
#define ACSI_C_FormatDrive		0x04
#define ACSI_C_ReadSector		0x08
#define ACSI_C_WriteSector		0x0a
#define ACSI_C_SeekBlock		0x0b
#define ACSI_C_ModeSelect		0x15
#define ACSI_C_ModeSense		0x1a

#define SCSI_C_INQUIRY			0x12

//---------------------------------------------
// ACSI DRIVE ERRORS 
/*
#define ACSI_E_NoSense		  		  0x00
#define ACSI_E_NoIndex	 	  		  0x01
#define ACSI_E_NoSeek	 	  		  0x02
#define ACSI_E_WriteFault	  		  0x03	  
#define ACSI_E_DriveNotReady  		  0x04
#define ACSI_E_NoTrack00	  		  0x06

// ACSI CONTROLLER ERRORS
#define ACSI_E_ID_ECC	 	   	  	  0x10
#define ACSI_E_Uncorectable	  	  	  0x11
#define ACSI_E_ID_AddressMarkNF	  	  0x12
#define ACSI_E_Data_AdrMarkNF	  	  0x13
#define ACSI_E_RecordNotFound	  	  0x14
#define ACSI_E_SeekError		  	  0x15
#define ACSI_E_DataCheckInNoRetryMode 0x18
#define ACSI_E_ECCerrorDuringVerify	  0x19
#define ACSI_E_BadBlock				  0x1a
#define ACSI_E_UnformatedBadFormat	  0x1c

// ACSI COMMAND ERRORS
#define ACSI_E_InvalidCommand		  0x20
#define ACSI_E_InvalidAddress		  0x21
#define ACSI_E_VolumeOverflow		  0x23
#define ACSI_E_InvalidArgument		  0x24
#define ACSI_E_InvalidDriveNumber	  0x25
#define ACSI_E_ByteZeroParityCheck	  0x26
#define ACSI_E_CartridgeChanged		  0x28
#define ACSI_E_ErrorCountOverflow	  0x2c

// ACSI OTHER FAILURES
#define ACSI_E_SelfTestFailed	  	  0x30
*/
//---------------------------------------------
// ACSI STATUS CODES
#define ACSI_S_OK					  0x00
#define ACSI_S_ERROR				  0x02
#define ACSI_S_BUSY					  0x08
//---------------------------------------------


// function that processes any ACSI command
void ACSI_ProcessCommand(void);

// send the final status byte
void ACSI_SendStatus(char status, char FromMaster);

// return the last error that occured
void ACSI_RequestSense(char FromMaster);

void SCSI_RequestSense(char FromMaster);
// return the status of formating
void SCSI_RequestSenseFormat(char FromMaster);

// DataIn = From drive to ST
void ACSI_DataIn(char Out);

// DataIn = From ST to drive
char ACSI_DataOut(void);

// send the info about the drive to the ST
char ACSI_ModeSense(char FromMaster);

// get the drive parameters from ST which should be set
void ACSI_ModeSelect(char FromMaster);

void SCSI_Inquiry(char FromMaster);

// 100 us pause
void WaitAbit(void);				

// pause of (i * 1.125) us
void WaitMicro(unsigned char i);			 

// Mode Sense page returning
void SCSI_MS_Page_3(unsigned char pc, unsigned char len, unsigned char FromMaster);

//---------------------------------------------

