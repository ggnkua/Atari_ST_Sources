#include <iom64v.h>
#include <stdio.h>

#include "porty.h"
#include "ide_low.h"
#include "ide_high.h"
#include "acsi1.h"
#include "scsi.h"
#include "main.h"

extern DriveParams Master,Slave;
extern CMND AcsiCmnd;
extern char ACSI_LastError, SCSI_ASC, SCSI_ASCQ;
//----------------------------------------------------------------------------- 
// just show the drive parameters from its structure
void IDE_ShowDriveParams(char ForMaster)
{
DriveParams *What;

if(ForMaster)	  			 // what are we setting?
	{
	What = &Master;
	printf("\n\nDumping info about: Master");
	}
else
	{
	What = &Slave;
	printf("\n\nDumping info about: Slave");
	}

if((ForMaster && !Master.Present) || (!ForMaster && !Slave.Present))
	{
	printf(" - not dumping, because drive not present.");
	return; 	 // if trying to set the absent device, just quit
	}

printf("\nCylinders : [%x %x]",What->NumOfCyls_H,   What->NumOfCyls_L); 
printf("\nHeads     : [%x %x]",What->NumOfHeads_H,  What->NumOfHeads_L);
printf("\nSect/Track: [%x %x]",What->SecPerTrack_H, What->SecPerTrack_L); 

if(What->LBAsupport)		 // if LBA supported
	printf("\nLBA support: YES");
else
	printf("\nLBA support: NO");
						
printf("\nLBA sectors: [%x %x %x %x] ",What->LBACapacity_H,  What->LBACapacity_MH,
			  		  	  	 		  What->LBACapacity_ML, What->LBACapacity_L); 
}
//----------------------------------------------------------------------------- 
// get the drive parameters 
char IDE_GetAndShowDriveParams(char ForMaster)
{
char res,i,res2;

if(ForMaster)	  			 // what are we setting?
	printf("\n\nDumping info about: Master");
else
	printf("\n\nDumping info about: Slave");

if((ForMaster && !Master.Present) || (!ForMaster && !Slave.Present))
	{
	printf(" - not dumping, because drive not present.");
	return 1; 	 // if trying to set the absent device, just quit
	}

IDE_SetActive(ForMaster);		   // set active drive
//-----------------------
// now we just want the drive to identify itself 
IDE_waitForReady(ForMaster);	   // wait until ready

IDE_IsOutput();				  

IDE = 0x7f;					  	   // COMMAND REGISTER
IDE_putB(0xec);					   // command: DRIVE IDENTIFY

res = IDE_waitForDRQ();			   
if(res!=0)						   // if error
	return res;					   // return it
	
IDE_IsInput();				  
IDE = 0x47;					  	   // address: DATA register 

for(i=0; i<255; i++)			   // read the data
	{
	res  = IDE_getWlo();		   // get the data
	res2 = IDE_getWHi();
	
	switch(i)
			 {
			 case 1:	printf("\nCylinders : [%x %x]",res2,res); break;
			 case 3:	printf("\nHeads     : [%x %x]",res2,res); break;
			 case 6:	printf("\nSect/Track: [%x %x]",res2,res); break;
			 case 49:	if(res2 & 0x02)		 // if LBA supported
			 				printf("\nLBA support: YES");
						else
			 				printf("\nLBA support: NO");
						break;
						
			 case 60:	printf("\nLBA sectors - lower  half [%x %x] ",res2,res); break;
			 case 61:	printf("\nLBA sectors - higher half [%x %x] ",res2,res); break;
			 }
	}

// WARNING! COMPILER PROBLEM - IF THE CONDITION IS i<256 IN THE FOR CYCLE AND i=char, WONT MAKE ANY CYCLE!
res  = IDE_getWlo();		   // get the data
res2 = IDE_getWHi();

return 0;
}
//----------------------------------------------------------------------------- 
char IDE_ReadSector(char FromMaster, char Count, 
	 				char adr_H, char adr_MH, char adr_ML, char adr_L)
{
DriveParams *What, temp;
unsigned long address;	
char hlp,i, res1, res2,j;

if((FromMaster && !Master.Present) || (!FromMaster && !Slave.Present))
	{
//	printf("\nDrive not present!");
	return 1; 	 // if trying to set the absent device, just quit
	}
//-----------------------------
if(FromMaster)	  			 // what are we setting?
	What = &Master;
else
	What = &Slave;

What->Ready = 0;
	
// check if the sector is in range. If not, quit with error
if(!IDE_SectorIsInRange(FromMaster,adr_H, adr_MH, adr_ML, adr_L))
	return 1;

//-------------
IDE_waitForReady(FromMaster);	   // wait until ready

IDE_IsOutput();					   // set IDE databa bus as output				  
//-------------

if(!What->LBAsupport)  		  // if the drive doesn't support LBA
	{						  // then we have to recalculate this to CHS
	LBAtoCHS(adr_H, adr_MH, adr_ML, adr_L, &temp, FromMaster);

	//-----------------------
	IDE = IDE_R_Head;		 		   // CHS address: Device/head reg.
	hlp = temp.NumOfHeads_L & 0x0f;	   // only 4 lower bits
	hlp |= 0xA0;  			 		   // set upper half as 1010 (not LBA)
	
	if(!FromMaster)
		hlp |= 0x10;		// set the SLAVE bit
	
	IDE_putB(hlp);		// write it to the reg.

	IDE_waitForReady(FromMaster);	   // wait until ready
	IDE_IsOutput();					   // set IDE databa bus as output				  
	//----------------------
	// time to set the address of sector
	IDE = IDE_R_sect;		   	  	   // CHS address: Sector
	IDE_putB(temp.SecPerTrack_L);	   // write it to the reg.
	
	IDE = IDE_R_Cyl_L;				   // CHS address: Cylinder, lower part
	IDE_putB(temp.NumOfCyls_L); 	   	   // write it to the reg.

	IDE = IDE_R_Cyl_H;				   // CHS address: Cylinder, higher part
	IDE_putB(temp.NumOfCyls_H);		   // write it to the reg.
	}
else 						// if drive supports LBA
	{
	//----------------------
	IDE = IDE_R_LBA_H;		// LBA bits 24-27
	hlp = adr_H & 0x0f;		// only 4 lower bits
	hlp |= 0xE0;  			// set upper half as 1110
	
	if(!FromMaster)
		hlp |= 0x10;		// set the SLAVE bit
	
	IDE_putB(hlp);		// write it to the reg.

	IDE_waitForReady(FromMaster);	   // wait until ready

	IDE_IsOutput();					   // set IDE data bus as output				  

	//-----------------------
	// time to set the address of sector
	IDE = IDE_R_LBA_L;		// LBA bits 0-7
	IDE_putB(adr_L);		// write it to the reg.
	
	IDE = IDE_R_LBA_ML;		// LBA bits 8-15
	IDE_putB(adr_ML);		// write it to the reg.

	IDE = IDE_R_LBA_MH;		// LBA bits 16-23
	IDE_putB(adr_MH);		// write it to the reg.
	}

//-----------------------
// now the count of sectors
IDE = IDE_R_sect_cnt;	   // sector count register
IDE_putB(Count);		 
//-----------------------
// issue a command
IDE = IDE_R_command;	   // command reg.	
IDE_putB(0x21);			   // Command: Read Sector		 

hlp = IDE_waitForDRQ();		   // wait until the drive has the data ready
	
if(hlp!=0)					   // if error occured
	{
	printf("\nError (%X) when reading sectors!",hlp);
	IDE_DoReset();
	return hlp;				   // return the error
	}
		
IDE_IsInput();					   // set IDE databa bus as input				  
IDE = IDE_R_data;
	
for(i=0; i<Count; i++)		   	  // read 'i' sectors
	for(hlp=0; hlp<128; hlp++)	  // read the whole sector
		for(j=0; j<2; j++)		  // read 4 bytes (2 in each loop)
			{
			res1 = IDE_getWlo();
			res2 = IDE_getWHi();

  			ACSI_DataIn(res1);	 // send bytes to ST
  			ACSI_DataIn(res2);
			}
	
What->Ready = 1;
	
return 0;
}
//----------------------------------------------------------------------------- 
char IDE_WriteSector(char FromMaster, char Count, 
	 				 char adr_H, char adr_MH, char adr_ML, char adr_L)
{
DriveParams *What, temp;
unsigned long address;	
char hlp,i, res1, res2,j,tmp;

if((FromMaster && !Master.Present) || (!FromMaster && !Slave.Present))
	{
//	printf("\nDrive not present!");
	return 1; 	 // if trying to set the absent device, just quit
	}
//-----------------------------
if(FromMaster)	  			 // what are we setting?
	What = &Master;
else
	What = &Slave;

What->Ready = 0;
	
// check if the sector is in range. If not, quit with error
if(!IDE_SectorIsInRange(FromMaster,adr_H, adr_MH, adr_ML, adr_L))
	return 1;
	
//-------------
IDE_waitForReady(FromMaster);	   // wait until ready

IDE_IsOutput();					   // set IDE databa bus as output				  
//-------------
if(!What->LBAsupport)  		  // if the drive doesn't support LBA
	{						  // then we have to recalculate this to CHS
	LBAtoCHS(adr_H, adr_MH, adr_ML, adr_L, &temp, FromMaster);

	//-----------------------
	IDE = IDE_R_Head;		 		   // CHS address: Device/head reg.
	hlp = temp.NumOfHeads_L & 0x0f;	   // only 4 lower bits
	hlp |= 0xA0;  			 		   // set upper half as 1010 (not LBA)
	
	if(!FromMaster)
		hlp |= 0x10;		// set the SLAVE bit
	
	IDE_putB(hlp);		// write it to the reg.

	IDE_waitForReady(FromMaster);	   // wait until ready
	IDE_IsOutput();					   // set IDE databa bus as output				  
	//----------------------
	// time to set the address of sector
	IDE = IDE_R_sect;		   	  	   // CHS address: Sector
	IDE_putB(temp.SecPerTrack_L);	   // write it to the reg.
	
	IDE = IDE_R_Cyl_L;				   // CHS address: Cylinder, lower part
	IDE_putB(temp.NumOfCyls_L); 	   	   // write it to the reg.

	IDE = IDE_R_Cyl_H;				   // CHS address: Cylinder, higher part
	IDE_putB(temp.NumOfCyls_H);		   // write it to the reg.
	}
else 						// if drive supports LBA
	{
	//----------------------
	IDE = IDE_R_LBA_H;		// LBA bits 24-27
	hlp = adr_H & 0x0f;		// only 4 lower bits
	hlp |= 0xE0;  			// set upper half as 1110
	
	if(!FromMaster)
		hlp |= 0x10;		// set the SLAVE bit
	
	IDE_putB(hlp);		// write it to the reg.

	IDE_waitForReady(FromMaster);	   // wait until ready

	IDE_IsOutput();					   // set IDE data bus as output				  
	//-----------------------
	// time to set the address of sector
	IDE = IDE_R_LBA_L;		// LBA bits 0-7
	IDE_putB(adr_L);		// write it to the reg.
	
	IDE = IDE_R_LBA_ML;		// LBA bits 8-15
	IDE_putB(adr_ML);		// write it to the reg.

	IDE = IDE_R_LBA_MH;		// LBA bits 16-23
	IDE_putB(adr_MH);		// write it to the reg.
	}

//-----------------------
// now the count of sectors
IDE = IDE_R_sect_cnt;	   // sector count register
IDE_putB(Count);		 
//-----------------------
// issue a command
IDE = IDE_R_command;	   // command reg.	
IDE_putB(0x31);			   // Command: Write Sector		 

hlp = IDE_waitForDRQ();		   // wait until the drive has the data ready
	
if(hlp!=0)					   // if error occured
	{
	IDE_DoReset();
	printf("\nError (%X) when writing sectors!",hlp);
	return hlp;				   // return the error
	}

IDE_IsOutput();					   // set IDE databa bus as output				  
IDE = IDE_R_data;
	
for(i=0; i<Count; i++)		   	  // read 'i' sectors
	for(hlp=0; hlp<128; hlp++)	  // read the whole sector
		for(j=0; j<2; j++)		  // read 4 bytes (2 in each loop)
			{
			res1 = ACSI_DataOut(); 
			res2 = ACSI_DataOut();

			IDE_putW(res2, res1);
			}		
	
What->Ready = 1;
	
return 0;
}
//-----------------------------------------------------------------------------
// init the drives
void IDE_init(unsigned char doDiag)
{
char ret;

IDE_Reset();

Master.Ready = 0;
Slave.Ready  = 0;

if(OnRealHW)
	printf("-> Initialization of IDE drives... ");
	
Master.Present = 1;		   // FAKE that Master present because of IDE_waitForReady

//IDE_SetActive(1);		   // set active - master

IDE_waitForReady(1);	   // wait until master spins up

if(doDiag)
	{
	IDE = 0x7f;				   // adress of command register
	IDE_IsOutput();			   // set the data ports as output
	IDE_putB(0x90);			   // write command: EXECUTE DRIVE DIAGNOSTICS
	}
	
IDE_waitForReady(1);	   // wait until diagnostics finishes up
//---------------------------
ret = IDE_getError();	   // after the diagnostics this should contain if we got master and slave

printf("\nWe got this situation: %x",ret);

switch(ret)				   // depending on the return value
	{
	case 0x00:	Master.Present=0; Slave.Present=1; break;
	case 0x01:	Master.Present=1; Slave.Present=1; break;  // slave passed or not present
	case 0x81:	Master.Present=1; Slave.Present=0; break;  // slave failed
	default:	Master.Present=0; Slave.Present=0; break;  // in other cases both failed or there's bullshit in the error-reg.
	}
//---------------------------
if(Slave.Present)				  // if slave has passed or is not present
	{							  // now we should test if it's realy present
	Delay(100);

	IDE_IsOutput();				  
	IDE_SetActive(0);		   // set active - slave

	IDE = 0x57;				   // adress of sector-count-register
	IDE_putB(0x00);			   // use 0 sectors

	IDE = 0x7f;				   // adress of command register
	IDE_putB(0x91);			   // INIT DRIVE PARAMETERS, but with wrong n. of sectors

	// here should be a short break
	// !!! IF THE NEXT ISN'T A BREAK, THEN THIS ALL WE FREEZE UP (don't know why) 
	// WITH VALUE 100 IT WAS OK
	Delay(5);
	
	ret = IDE_getError();	   // now we try to read the error
	
	if(ret==0)				   // if no error at all (and there should be an error if drive is connected)
		{
		printf("\nSLAVE not present.");
		Slave.Present=0;	   // then slave is not realy present
		}
	}
//---------------
// now is time to init drive parameters to make it usable
if(Master.Present)			   // if the drive is there and it passed 
	{
	IDE_GetDriveParams(1);	   // get drive parameters
	IDE_InitDriveParams(1);	   // init drive parameters
	
	Master.Ready = 1;
	}

if(Slave.Present)			   // if the drive is there and it passed 
	{
	IDE_GetDriveParams(0);	   // get drive parameters
	IDE_InitDriveParams(0);	   // init drive parameters

	Slave.Ready  = 1;
	}

if(OnRealHW)
	{
	printf("\nDone!");

	if(Master.Present)
		IDE_ShowDriveParams(1);
		
	if(Slave.Present)
		IDE_ShowDriveParams(0);
	}
}
//-----------------------------------------------------------------------------
// this does the formating of drive, now actualy only 'zero-fill'
char IDE_FormatDisk(char FromMaster)
{
DriveParams *What, temp;
unsigned long adrMAX,adr,spt,noh,noc, progr, oneP;
unsigned char adrH,adrMH,adrML,adrL;	

if((FromMaster && !Master.Present) || (!FromMaster && !Slave.Present))
	{
	printf("\nDrive not present!");
	return 1; 	 // if trying to set the absent device, just quit
	}
//-----------------------------
if(FromMaster)	  			 // what are we setting?
	What = &Master;
else
	What = &Slave;

What->Ready = 0;	   			 // set that the drive isn't ready
//-----------------------------
if(What->LBAsupport)
	{
	adrMAX =  (((unsigned long)What->LBACapacity_H) << 24) + (((unsigned long)What->LBACapacity_MH) << 16) 
    	    + (((unsigned long)What->LBACapacity_ML) << 8) + (((unsigned long)What->LBACapacity_L)  << 0);
	}
else
 	{
	spt = ((unsigned long)What->SecPerTrack_L) + ((unsigned long)What->SecPerTrack_H)<<8; 
	noh = ((unsigned long)What->NumOfHeads_L)  + ((unsigned long)What->NumOfHeads_H)<<8; 
	noc = ((unsigned long)What->NumOfCyls_L)   + ((unsigned long)What->NumOfCyls_H)<<8; 
	
	adrMAX = spt * noh * noc;
	}
//-----------------------------
// calculate how many is 1% of the disk size (in sectors)
oneP = adrMAX / 100;

for(adr=0; adr<adrMAX; adr++)
	{
	adrH  = (adr >> 24) & 0xff;
	adrMH = (adr >> 16) & 0xff;
	adrML = (adr >>  8) & 0xff;
	adrL  = (adr >>  0) & 0xff;

	// calculate the progress of formating
	progr = adr / oneP;	  	   // progress = current_sector / sectors_per_1%
	What->FrmtProg_H = (progr >> 8) & 0xff;
	What->FrmtProg_L = (progr >> 0) & 0xff;
	
	// write sector full of zeros
	IDE_WriteZeroSector(FromMaster, 1, adrH, adrMH, adrML, adrL);

	// because formating may last very long, we will process the commands also here	
	if(AcsiCmnd.Proc==1)		// if we got the complete command and we are active
		ProcessCmd();
	}
//-----------------------------
What->Ready = 1;				   // set that the drive is ready

return 0;
}
//-----------------------------------------------------------------------------
char IDE_WriteZeroSector(char FromMaster, char Count, 
	 				 char adr_H, char adr_MH, char adr_ML, char adr_L)
{
DriveParams *What, temp;
unsigned long address;	
char hlp,i, res1, res2,j,tmp;

if((FromMaster && !Master.Present) || (!FromMaster && !Slave.Present))
	{
	printf("\nDrive not present!");
	return 1; 	 // if trying to set the absent device, just quit
	}
//-----------------------------
if(FromMaster)	  			 // what are we setting?
	What = &Master;
else
	What = &Slave;

What->Ready = 0;	   			 // set that the drive isn't ready
	
// check if the sector is in range. If not, quit with error
if(!IDE_SectorIsInRange(FromMaster,adr_H, adr_MH, adr_ML, adr_L))
	return 1;
	
//-------------
IDE_waitForReady(FromMaster);	   // wait until ready

IDE_IsOutput();					   // set IDE databa bus as output				  

//-------------

if(!What->LBAsupport)  		  // if the drive doesn't support LBA
	{						  // then we have to recalculate this to CHS
	LBAtoCHS(adr_H, adr_MH, adr_ML, adr_L, &temp, FromMaster);

	//-----------------------
	IDE = IDE_R_Head;		 		   // CHS address: Device/head reg.
	hlp = temp.NumOfHeads_L & 0x0f;	   // only 4 lower bits
	hlp |= 0xA0;  			 		   // set upper half as 1010 (not LBA)
	
	if(!FromMaster)
		hlp |= 0x10;		// set the SLAVE bit
	
	IDE_putB(hlp);		// write it to the reg.

	IDE_waitForReady(FromMaster);	   // wait until ready
	IDE_IsOutput();					   // set IDE databa bus as output				  
	//----------------------
	// time to set the address of sector
	IDE = IDE_R_sect;		   	  	   // CHS address: Sector
	IDE_putB(temp.SecPerTrack_L);	   // write it to the reg.
	
	IDE = IDE_R_Cyl_L;				   // CHS address: Cylinder, lower part
	IDE_putB(temp.NumOfCyls_L); 	   	   // write it to the reg.

	IDE = IDE_R_Cyl_H;				   // CHS address: Cylinder, higher part
	IDE_putB(temp.NumOfCyls_H);		   // write it to the reg.
	}
else 						// if drive supports LBA
	{
	//----------------------
	IDE = IDE_R_LBA_H;		// LBA bits 24-27
	hlp = adr_H & 0x0f;		// only 4 lower bits
	hlp |= 0xE0;  			// set upper half as 1110
	
	if(!FromMaster)
		hlp |= 0x10;		// set the SLAVE bit
	
	IDE_putB(hlp);		// write it to the reg.

	IDE_waitForReady(FromMaster);	   // wait until ready

	IDE_IsOutput();					   // set IDE data bus as output				  

	//-----------------------
	// time to set the address of sector
	IDE = IDE_R_LBA_L;		// LBA bits 0-7
	IDE_putB(adr_L);		// write it to the reg.
	
	IDE = IDE_R_LBA_ML;		// LBA bits 8-15
	IDE_putB(adr_ML);		// write it to the reg.

	IDE = IDE_R_LBA_MH;		// LBA bits 16-23
	IDE_putB(adr_MH);		// write it to the reg.
	}

//-----------------------
// now the count of sectors
IDE = IDE_R_sect_cnt;	   // sector count register
IDE_putB(Count);		 
//-----------------------
// issue a command
IDE = IDE_R_command;	   // command reg.	
IDE_putB(0x31);			   // Command: Write Sector		 

hlp = IDE_waitForDRQ();		   // wait until the drive has the data ready
	
if(hlp!=0)					   // if error occured
	{
	printf("\nError (%X) when writing sectors!",hlp);
	IDE_DoReset();
	return hlp;				   // return the error
	}
		
IDE_IsOutput();					   // set IDE databa bus as output				  
IDE = IDE_R_data;
	
for(i=0; i<Count; i++)		   	  // read 'i' sectors
	for(hlp=0; hlp<128; hlp++)	  // read the whole sector
		for(j=0; j<2; j++)		  // read 4 bytes (2 in each loop)
			IDE_putW(0,0);
	
What->Ready = 1;
	
return 0;
}
//-----------------------------------------------------------------------------
