#include <stdio.h>

#include "main.h"
#include "ide_low.h"
#include "ide_high.h"
#include "acsi1.h"
#include "scsi.h"
#include "porty.h"

#define DEBUG_TXT 0

extern CMND AcsiCmnd;
extern DriveParams Master,Slave;

char ACSI_LastError, SCSI_ASC, SCSI_ASCQ;

//----------------------------------------------
// function that processes any ACSI command
void ACSI_ProcessCommand(void)
{
unsigned char a,b,i;
char FromMaster;

//printf("\nCmd: %x %x %x %x %x %x", AcsiCmnd.cmd[0], AcsiCmnd.cmd[1], AcsiCmnd.cmd[2], AcsiCmnd.cmd[3], AcsiCmnd.cmd[4], AcsiCmnd.cmd[5]);
SetBit(ACSI_o,ACSI_INT); 					// INT to H

switch(AcsiCmnd.cmd[1] & 0xE0)		// check the device #
	{
	case 0x00:	FromMaster = 1; break; // device # 0
	case 0x20:	FromMaster = 0; break; // device # 1
	
	default:	SCSI_SK   = SCSI_E_IllegalRequest;		// other devices = error 
				SCSI_ASC  = SCSI_ASC_LU_NOT_SUPPORTED;
				SCSI_ASCQ = SCSI_ASCQ_LU_NOT_SUPPORTED;
			
				ACSI_SendStatus(ACSI_S_ERROR,1); 

				printf("\nError: bad device #: %x %x %x %x %x %x", AcsiCmnd.cmd[0], AcsiCmnd.cmd[1], AcsiCmnd.cmd[2], AcsiCmnd.cmd[3], AcsiCmnd.cmd[4], AcsiCmnd.cmd[5]);
				
				return; 
				break;	
	}

// now check that if the wanted drive is present
if((FromMaster && !Master.Present) || (!FromMaster && !Slave.Present))
	{
	SCSI_SK   = SCSI_E_IllegalRequest;	// the device # is invalid  
	SCSI_ASC  = SCSI_ASC_LU_NOT_SUPPORTED;
	SCSI_ASCQ = SCSI_ASCQ_LU_NOT_SUPPORTED;
	
	ACSI_SendStatus(ACSI_S_ERROR,FromMaster); 
/*
	printf("\nError: Device not present!");
	if(FromMaster)
		{
		if(Master.Present)
			printf("MP");
		else
			printf("MM");
		}	
	else
		{
		if(Slave.Present)
			printf("SP");
		else
			printf("SM");
		}		
*/		
	return;
	} 
//------------------------------------------
switch((AcsiCmnd.cmd[0] & 0x1f))			// get only the command part of byte
	{
	case ACSI_C_DriveReady	: if((FromMaster && Master.Ready) ||
		 					    (!FromMaster && Slave.Ready))
									{
									SCSI_SK   = SCSI_E_NoSense;
									SCSI_ASC  = SCSI_ASC_NO_ADDITIONAL_SENSE;
									SCSI_ASCQ = SCSI_ASCQ_NO_ADDITIONAL_SENSE;
				
									ACSI_SendStatus(ACSI_S_OK,FromMaster);									
									}
							  else
									{
									SCSI_SK   = SCSI_E_NotReady;	// drive not ready  
									SCSI_ASC  = SCSI_ASC_LU_NOT_READY;
									SCSI_ASCQ = SCSI_ASCQ_CAUSE_NOT_REPORTABLE;
		
									ACSI_SendStatus(ACSI_S_BUSY,FromMaster);									
									}

							  if(DEBUG_TXT)
							    printf("\nDr");
									
							  break;
	//----------------------------------------------------
 	case ACSI_C_RestoreTo0	: SCSI_SK   = SCSI_E_NoSense;	// no error
		 					  SCSI_ASC  = SCSI_ASC_NO_ADDITIONAL_SENSE;
							  SCSI_ASCQ = SCSI_ASCQ_NO_ADDITIONAL_SENSE;

		 					  ACSI_SendStatus(ACSI_S_OK,FromMaster); break;
							  
	case ACSI_C_RequestSense: if(AcsiCmnd.cmd[4]==4)				 // if 4 bytes wanted
			 					  ACSI_RequestSense(FromMaster);	 // ACSI RS
							  else
			 					  SCSI_RequestSense(FromMaster);	 // SCSI RS
							   		  
							  if(DEBUG_TXT)
							    printf("\nRs");
		 					  break;

	case ACSI_C_FormatDrive	: 
/*
							  ACSI_LastError = ACSI_E_InvalidCommand; 
		 					  SCSI_ASC  = SCSI_ASC_NO_ADDITIONAL_SENSE;
							  SCSI_ASCQ = SCSI_ASCQ_NO_ADDITIONAL_SENSE;
*/		
//							  printf("\nFmt");
							  
							  SCSI_SK   = SCSI_E_NoSense;	// no error
		 					  SCSI_ASC  = SCSI_ASC_NO_ADDITIONAL_SENSE;
							  SCSI_ASCQ = SCSI_ASCQ_NO_ADDITIONAL_SENSE;

							  ACSI_SendStatus(ACSI_S_OK,FromMaster); 
							  
							  if(FromMaster)		// set a flag that we should be formating
							  	 Master.DoFormat=1;
							  else
							  	 Slave.DoFormat=1;
							  	  
							  break;

	//----------------------------------------------------
	case ACSI_C_ReadSector	: 
		 					  a = IDE_ReadSector(FromMaster, AcsiCmnd.cmd[4], 0, 
		 					      (AcsiCmnd.cmd[1] & 0x1F), AcsiCmnd.cmd[2], AcsiCmnd.cmd[3]);

							  if(a==0)
							  	{
								printf("\nRok");
								
							    SCSI_SK   = SCSI_E_NoSense;	// no error
		 					  	SCSI_ASC  = SCSI_ASC_NO_ADDITIONAL_SENSE;
							  	SCSI_ASCQ = SCSI_ASCQ_NO_ADDITIONAL_SENSE;
							  
		 					  	ACSI_SendStatus(ACSI_S_OK,FromMaster);
								}
							  else
							  	{
								printf("\nRerr");
								
							    SCSI_SK   = SCSI_E_AbortedCommand;	
		 					  	SCSI_ASC  = SCSI_ASC_NO_ADDITIONAL_SENSE;
							  	SCSI_ASCQ = SCSI_ASCQ_NO_ADDITIONAL_SENSE;
							  
		 					  	ACSI_SendStatus(ACSI_S_ERROR,FromMaster);
								}

							  if(DEBUG_TXT)
							  	printf("\nR");

		 					  break;
	//----------------------------------------------------
	case ACSI_C_WriteSector	: 
//							  printf("\nWRITE: %x %x %x %x %x %x", AcsiCmnd.cmd[0], AcsiCmnd.cmd[1], AcsiCmnd.cmd[2], AcsiCmnd.cmd[3], AcsiCmnd.cmd[4], AcsiCmnd.cmd[5]);
		 					  a = IDE_WriteSector(FromMaster, AcsiCmnd.cmd[4], 0, 
		 					      (AcsiCmnd.cmd[1] & 0x1F), AcsiCmnd.cmd[2], AcsiCmnd.cmd[3]);

 							  if(a==0)
							  	{
								printf("\nWok");

							    SCSI_SK   = SCSI_E_NoSense;	// no error
		 					  	SCSI_ASC  = SCSI_ASC_NO_ADDITIONAL_SENSE;
							  	SCSI_ASCQ = SCSI_ASCQ_NO_ADDITIONAL_SENSE;
							  
		 					  	ACSI_SendStatus(ACSI_S_OK,FromMaster);
								}
							  else
							  	{
								printf("\nWerr");

							    SCSI_SK   = SCSI_E_AbortedCommand;	
		 					  	SCSI_ASC  = SCSI_ASC_NO_ADDITIONAL_SENSE;
							  	SCSI_ASCQ = SCSI_ASCQ_NO_ADDITIONAL_SENSE;
							  
		 					  	ACSI_SendStatus(ACSI_S_ERROR,FromMaster);
								}

							  if(DEBUG_TXT)
							     printf("\nW");

		 					  break;
	//----------------------------------------------------
	
	case ACSI_C_SeekBlock	: SCSI_SK   = SCSI_E_NoSense;	// no error
		 					  SCSI_ASC  = SCSI_ASC_NO_ADDITIONAL_SENSE;
							  SCSI_ASCQ = SCSI_ASCQ_NO_ADDITIONAL_SENSE;
	
		 					  ACSI_SendStatus(ACSI_S_OK,FromMaster); break;
							  
	case ACSI_C_ModeSelect	: ACSI_ModeSelect(FromMaster); 		  
							  if(DEBUG_TXT)
							  	 printf("\nMSl");
		 					  break;
	case ACSI_C_ModeSense	: a = ACSI_ModeSense(FromMaster);	
	
		 					  ACSI_SendStatus(a,FromMaster);
							  		  
							  if(DEBUG_TXT)
  							  	 printf("\nMSnc");
		 					  break;
	
	case SCSI_C_INQUIRY		: SCSI_Inquiry(FromMaster); 
							  if(DEBUG_TXT)
  							  	 printf("\nI");
		 					  break;
	
	default					: 
							  printf("\nUnkn: %x %x %x %x %x %x", AcsiCmnd.cmd[0], AcsiCmnd.cmd[1], AcsiCmnd.cmd[2], AcsiCmnd.cmd[3], AcsiCmnd.cmd[4], AcsiCmnd.cmd[5]);

							  SCSI_SK	= SCSI_E_IllegalRequest; 
							  SCSI_ASC  = SCSI_ASC_InvalidCommandOperationCode;
							  SCSI_ASCQ = SCSI_ASCQ_NO_ADDITIONAL_SENSE;

							  ACSI_SendStatus(ACSI_S_ERROR,FromMaster); 
							  
							  break;
	}
}
//----------------------------------------------
void SCSI_Inquiry(char FromMaster)
{
char i,xx;
DriveParams *What;

if(FromMaster)	  	
	What = &Master;
else
	What = &Slave;

xx = AcsiCmnd.cmd[4];		  // how many bytes should be sent

for(i=0; i<xx; i++)			  
	{
	if(i>=8 && i<=31)		  // 8 or 16
		ACSI_DataIn(What->model[i-8]);
	else
		ACSI_DataIn(0);		
	}	

SCSI_ASC  = SCSI_ASC_NO_ADDITIONAL_SENSE;
SCSI_ASCQ = SCSI_ASCQ_NO_ADDITIONAL_SENSE;
SCSI_SK   = SCSI_E_NoSense;	// no error

ACSI_SendStatus(ACSI_S_OK,FromMaster);	  	 // and send that this went all OK
}
//----------------------------------------------
// send the final status byte
void ACSI_SendStatus(char status, char FromMaster)
{
unsigned char val,dev;

if(FromMaster)
	dev = 0;
else
	dev = 1;

val = (dev << 5) + status;	 	// make the status byte as (ID+Status)

ACSI_DATA_o = val;					// write the status out
ACSI_IsOutput();					// set ACSI as output

//ClrBit(EIMSK,0x02);					// turn OFF ACSI_CS interupt for a while
ClrBit(ACSI_o,ACSI_INT); 			// INT to L
/*
while(ACSI_i & ACSI_CS);			// wait until CS

SetBit(ACSI_o,ACSI_INT); 			// INT to H
SetBit(EIMSK,0x02);					// turn OFF ACSI_CS interupt for a while
ACSI_IsInput();						// set ACSI as output
*/
}
//----------------------------------------------
// DataIn = From drive to ST
void ACSI_DataIn(char Out)
{
ACSI_IsOutput();	   	  			// set ACSI as output
ACSI_DATA_o = Out;	  	  			// write out the data

ClrBit(ACSI_o,ACSI_DRQ); 			// DRQ to L

asm("nop");

SetBit(ACSI_o,ACSI_DRQ); 			// DRQ to H

ShortPause();
ShortPause();

ACSI_IsInput();						// set ACSI as input
}
//----------------------------------------------
// DataIn = From ST to drive
char ACSI_DataOut(void)
{
char val;

ACSI_IsInput();						// set ACSI as input

ClrBit(ACSI_o,ACSI_DRQ); 			// DRQ to L

asm("nop");

SetBit(ACSI_o,ACSI_DRQ); 			// DRQ to H

val = ACSI_DATA_i;					// read the value

ShortPause();
ShortPause();

return val;							// return the value   
}
//----------------------------------------------
// return the last error that occured
void ACSI_RequestSense(char FromMaster)
{
char i,xx;

xx = AcsiCmnd.cmd[4];		  // how many bytes should be sent

ACSI_DataIn(ACSI_LastError);  // send out error #

for(i=0; i<xx-1; i++)			  
	ACSI_DataIn(0);  		  

ACSI_SendStatus(ACSI_S_OK,FromMaster);	  	 // and send that this went all OK
SCSI_SK   = SCSI_E_NoSense;	// no error
}
//----------------------------------------------
// return the last error that occured
void SCSI_RequestSense(char FromMaster)
{
char i,xx;

if((FromMaster && Master.DoFormat==3) || (!FromMaster && Slave.DoFormat==3))
	SCSI_RequestSenseFormat(FromMaster);

xx = AcsiCmnd.cmd[4];		  // how many bytes should be sent

for(i=0; i<xx; i++)			  
	{
	switch(i)
		{
		case  0:	ACSI_DataIn(0xf0); 			   break; 	  	// error code 
		case  2:	ACSI_DataIn(ACSI_LastError);   break;		// sense key 
		case  7:	ACSI_DataIn(xx-7);			   break;		// AS length
		case 12:	ACSI_DataIn(SCSI_ASC);		   break;		// additional sense code
		case 13:	ACSI_DataIn(SCSI_ASCQ);		   break;		// additional sense code qualifier

		default:	ACSI_DataIn(0); break;  
		}
	}

ACSI_SendStatus(ACSI_S_OK,FromMaster);	  	 // and send that this went all OK
SCSI_SK   = SCSI_E_NoSense;	// no error
}
//----------------------------------------------
// return the status of formating
void SCSI_RequestSenseFormat(char FromMaster)
{
char i,xx;

xx = AcsiCmnd.cmd[4];		  // how many bytes should be sent

for(i=0; i<xx; i++)			  
	{
	switch(i)
		{
		case  0:	ACSI_DataIn(0xf0); 	    break; 	  	// error code 
		case  2:	ACSI_DataIn(2);    		break;		// sense key = NOT READY 
		case 12:	ACSI_DataIn(4);			break;		// add. sense code = LU NOT READY
		case 13:	ACSI_DataIn(4);			break;		// add. sense code qual = FORMAT IN PROGRESS
		case 15:	ACSI_DataIn(0x80);		break;		// Sense-Key specific: VALID
		//-------------
		case 16:	if(FromMaster)						// send the progress of format
			 			ACSI_DataIn(Master.FrmtProg_H);
					else
			 			ACSI_DataIn(Slave.FrmtProg_H);
					break;
		//-------------
		case 17:	if(FromMaster)						// send the progress of format
			 			ACSI_DataIn(Master.FrmtProg_L);
					else
			 			ACSI_DataIn(Slave.FrmtProg_L);
					break;
		//-------------
		default:	ACSI_DataIn(0); break;  
		}
	}

ACSI_SendStatus(ACSI_S_OK,FromMaster);	  	 // and send that this went all OK
SCSI_SK   = SCSI_E_NoSense;	// no error
}
//----------------------------------------------
// send the info about the drive to the ST, works now only for MODE SENSE(6)
char ACSI_ModeSense(char FromMaster)
{
unsigned char def,pc, PageCode, i;
DriveParams *What;

if(FromMaster)	  	
	What = &Master;
else
	What = &Slave;

pc       = (AcsiCmnd.cmd[2] & 0xC0)>>6;	// get the PC
PageCode = (AcsiCmnd.cmd[2] & 0x3f);
//----------------------
// find out the length of PageCode
switch(PageCode)
	{
	case 0x03:	def = 24; break;  	// PageCode 3
	
	case 0x3f:	def = 24; break;	// PageCode: ALL!
	
	default: 	def =  0; break;	   			
	}
//----------------------
// fill ouy the MODE PARAMETER HEADER (0-3) and MODE PARAMETER BLOCK DESCRIPTOR (4-11)
for(i=0; i<12; i++)
	switch(i)
		{
		case  0:   ACSI_DataIn(def + 12 - 1); break; // length of the next data
		case  3:   ACSI_DataIn(8); 	 	  	  break; // length of BLOCK DESCRIPTOR

		case 10:   ACSI_DataIn(2); 	 	  	  break; // BLOCK LENGTH
		
		default:   ACSI_DataIn(0); 			  break;	   // other values: zero			
		}
//----------------------
// now try to return the wanted MODE PAGE if supported
def = 0;

switch(PageCode)
	{
	case 0x03: SCSI_MS_Page_3(pc, AcsiCmnd.cmd[4]-12, FromMaster); break;

	// case 0x3f means ALL MODE PAGES 
	case 0x3f: SCSI_MS_Page_3(pc, AcsiCmnd.cmd[4]-12, FromMaster); 
		 	   break;
	
	default: def = 1; break;
	}	
//----------------------
if(!def)				// if page is supported
	{	
	SCSI_SK   = SCSI_E_NoSense;	// no error
	SCSI_ASC  = SCSI_ASC_NO_ADDITIONAL_SENSE;
	SCSI_ASCQ = SCSI_ASCQ_NO_ADDITIONAL_SENSE;

	return ACSI_S_OK;
	}
else 					// if page is NOT supported
	{
	SCSI_SK   = SCSI_E_IllegalRequest;  	  
	SCSI_ASC  = SCSI_ASC_InvalidFieldInCDB;
	SCSI_ASCQ = SCSI_ASCQ_InvalidFieldInCDB;

	return ACSI_S_ERROR;
	}
}
//----------------------------------------------
void SCSI_MS_Page_3(unsigned char pc, unsigned char len, unsigned char FromMaster)
{
unsigned char i;
DriveParams *What;

if((AcsiCmnd.cmd[1] & 0xE0)==0)	  	// info about master? (Device = 000)
	What = &Master;
else
	What = &Slave;

if(pc==0)	  	// current values?
	for(i=0; i<len; i++)
		switch(i)
			{
			case  0:	ACSI_DataIn(0x03); break;  // page #
			case  1:	ACSI_DataIn(0x16); break;  // length

			//----------------------------------------------
			// THESE VALUES ARE STOLEN FROM SEAGATE 1 GB DRIVE, may not be always correct
			case  3:	ACSI_DataIn(1); 	break;	  // TpZ  
			case  5:	ACSI_DataIn(1); 	break;	  // ASpT
			case  9:	ACSI_DataIn(8); 	break;	  // ATpLU  
			case 12:	ACSI_DataIn(0x20);	break;	  // DBpPS - h  
			case 13:	ACSI_DataIn(0); 	break;	  // DBpPS - l  
			case 15:	ACSI_DataIn(1); 	break;	  // Interleave  
			case 17:	ACSI_DataIn(0x24);	break;	  // TSF  
			case 19:	ACSI_DataIn(0x2d);	break;	  // CSF  
			//----------------------------------------------
			case 10:	ACSI_DataIn(What->SecPerTrack_H); break;
			case 11:	ACSI_DataIn(What->SecPerTrack_L); break;

//			case 12:	ACSI_DataIn(2); break;	   // bytes per physical sector
//			case 13:	ACSI_DataIn(0); break;
			
			case 20:	ACSI_DataIn(0xd0); break;  // hard- and soft-formatable, not removable
			default: 	ACSI_DataIn(0); break;	   // other values: zero			
			}
//-----------------
if(pc==1)	  	// changeable values?
	for(i=0; i<len; i++)
		switch(i)
			{
			case  0:	ACSI_DataIn(0x03); break;  // page #
			case  1:	ACSI_DataIn(0x16); break;  // length
			default:	ACSI_DataIn(0); break;	   // not changeable			
			}
}
//----------------------------------------------
// get the drive parameters from ST which should be set
void ACSI_ModeSelect(char FromMaster)
{
char i,val;

for(i=0; i<AcsiCmnd.cmd[4]; i++) // output only this many bytes
	val =  ACSI_DataOut();		 // get data from ACSI
	
ACSI_SendStatus(ACSI_S_OK,FromMaster);	  	 // and send that this went all OK
SCSI_SK   = SCSI_E_NoSense;	// no error
}
//----------------------------------------------
void WaitAbit(void)				// 100 us pause
{
unsigned char i;

for(i=0; i<88; i++)
	{
	ShortPause();
	ShortPause();
	ShortPause();
	}
}
//----------------------------------------------
void WaitMicro(unsigned char i)			// pause of (i * 1.125) us 
{
for(; i!=0; i--)
	{
	ShortPause();
	ShortPause();
	ShortPause();
	}
}
//----------------------------------------------

