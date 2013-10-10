#include <iom64v.h>
#include <stdio.h>

#include "porty.h"
#include "ide_low.h"
#include "ide_high.h"

extern DriveParams Master,Slave;

extern void Delay(char Time);
//----------------------------------------------------------------------------- 
void ShortPause(void)
{
asm("nop\n");
asm("nop\n");
asm("nop\n");
asm("nop\n");
}
//----------------------------------------------------------------------------- 
// put one byte on IDE bus
void IDE_putB(char what)
{
 	 ClrBit(IDE,IDE_WR);		 // clear Write bit on IDE

	 IDE_DATA_low_o = what;		 // write data on the lower IDE data 
	 IDE_DATA_hi_o  = 0;
	 
	 ShortPause();

 	 SetBit(IDE,IDE_WR);		 // set Write bit on IDE
}
//----------------------------------------------------------------------------- 
// put one word on IDE bus
void IDE_putW(char Hi, char Lo)
{
 	 ClrBit(IDE,IDE_WR);		 // clear Write bit on IDE

	 IDE_DATA_low_o = Lo;			 // write data on the lower IDE data 
	 IDE_DATA_hi_o  = Hi;			 // write data on the uppder IDE data 

 	 ShortPause();
	 
 	 SetBit(IDE,IDE_WR);		 // set Write bit on IDE
}
//----------------------------------------------------------------------------- 
// get one byte from IDE bus
char IDE_getB(void)
{
 	 char aa;
	 
	 ClrBit(IDE,IDE_RD);		 // clear Read bit on IDE

 	 ShortPause();
	 aa = IDE_DATA_low_i;		 // get data from the lower IDE data 
	 
 	 SetBit(IDE,IDE_RD);		 // set Read bit on IDE

	 return aa;
}
//----------------------------------------------------------------------------- 
// get two bytes from IDE bus
//!!! POZOR, PRI TOMTO RIADKU HLASI WAROWANIE:
// warning: Studio version below 4.06 does not support 'const' data type
/*
void IDE_getW(char *where)
{
 	 ClrBit(IDE,IDE_RD);		 // clear Read bit on IDE

	 where[0] = IDE_DATA_low;	 // get data from the lower IDE data 
	 where[1] = IDE_DATA_hi;	 // get data from the upper IDE data 

 	 SetBit(IDE,IDE_RD);		 // set Read bit on IDE
}
*/
//----------------------------------------------------------------------------- 
// Get IDE word, LOW byte
char IDE_getWlo(void)
{
 	 ClrBit(IDE,IDE_RD);		 // clear Read bit on IDE

	 ShortPause();

	 return IDE_DATA_low_i;	 	 // get data from the lower IDE data 
}
//----------------------------------------------------------------------------- 
// Get IDE word, HI byte
char IDE_getWHi(void)
{
 	 char aa;
	 aa = IDE_DATA_hi_i;	 		// get data from the upper IDE data 

 	 SetBit(IDE,IDE_RD);		 // set Read bit on IDE

	 return aa;
}
//----------------------------------------------------------------------------- 
char IDE_getError(void)
{
IDE = 0x67;			   // set the right control-signals combination
IDE_IsInput();		   // set IDE data lines to output

return IDE_getB();	   // return the error (in LSB of IDE data)
}
//----------------------------------------------------------------------------- 
// wait until the DRQ bit goes high
char IDE_waitForDRQ(void)
{
char in;

IDE_IsInput();
IDE = 0x7f;  			  	   // adress of status-register

while(1)					   // wait-loop for DRQ
	{
	in = IDE_getB();			   // read status

	if(in & IDE_b_error)   		   // if error
		return IDE_getError();	   // return error #

	if(in & IDE_b_DRQ)			   // if DRQ bit set
		break;					   // end loop
	}	
	
return 0;						   // return that there was no error
}
//----------------------------------------------------------------------------- 
// wait until ready
void IDE_waitForReady(char ForMaster)
{
char in;

if((ForMaster && !Master.Present) || (!ForMaster && !Slave.Present))
	return; 	 // if trying to wait for absent device, just quit
//-------
// SELECT master or slave
IDE_SetActive(ForMaster);

//-------
// CHECK the right bits
IDE_IsInput();
IDE = 0x7b;  			   // address of status-register

while(1){
		in = IDE_getB();   // read byte from IDE 

		if((in & IDE_b_READY) && !(in & IDE_b_BUSY))
			break;			  // if not busy and ready, break		
		}
}
//----------------------------------------------------------------------------- 
void IDE_SetActive(char mast)
{
IDE_IsOutput();
IDE = 0x77;	   			   // address of LBA hi reg., also Master/Slave select

if(mast)
	IDE_putB(0xe0);		   // select master
else
	IDE_putB(0xf0);		   // select slave
}
//----------------------------------------------------------------------------- 
// SET the drive parameters from its structure
char IDE_InitDriveParams(char ForMaster)
{
DriveParams *What;
char tmp;

if(ForMaster)	  			 // what are we setting?
	What = &Master;
else
	What = &Slave;

if((ForMaster && !Master.Present) || (!ForMaster && !Slave.Present))
	return 1; 	 // if trying to set the absent device, just quit

IDE_waitForReady(ForMaster);	   // wait until it gets ready
	
IDE_IsOutput();				  
//-----------------------------
IDE = 0x57;					  	   // Sector-count register
IDE_putW(0, What->SecPerTrack_L);
//-----------------------------
IDE = 0x5f;					  	   // LBA hi
tmp = (What->NumOfHeads_L - 1);

if(!ForMaster)
	tmp = tmp | 0x10;	  	   	   // set the slave bit 

IDE_putW(0, tmp);				   // set it
//-----------------------------
IDE = 0x7f;					  	   // COMMAND REGISTER
IDE_putB(0x91);					   // command: Initialize device parameters

IDE_waitForReady(ForMaster);	   // wait until it gets ready

return IDE_getError();
}
//-----------------------------------------------------------------------------
// get the drive parameters in its structure
char IDE_GetDriveParams(char ForMaster)
{
char res,i,res2;
DriveParams *What;

if(ForMaster)	  			 // what are we setting?
	What = &Master;
else
	What = &Slave;

if((ForMaster && !Master.Present) || (!ForMaster && !Slave.Present))
	return 1; 	 // if trying to set the absent device, just quit

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
			 case 1:	What->NumOfCyls_H = res2;
			 	  		What->NumOfCyls_L = res;  		break;
								 
			 case 3:	What->NumOfHeads_H = res2;
			 	  		What->NumOfHeads_L = res; 		break;

			 case 6:	What->SecPerTrack_H = res2;
			 	  		What->SecPerTrack_L = res;		break;
						
			 case 49:	if(res2 & 0x02)		 // if LBA supported
			 	  			What->LBAsupport = 1;
						else
			 	  			What->LBAsupport = 0;
						break;
						
			 case 60:	What->LBACapacity_ML = res2;
			 	  		What->LBACapacity_L  = res;		break;
	 
			 case 61:	What->LBACapacity_MH = res;
			 	  		What->LBACapacity_H  = res2;	break;
			 }
			 
		if(i>=27 && i<=46)					 // get model name, etc.
			{
			What->model[((i-27)<<1) + 0] = res2;
			What->model[((i-27)<<1) + 1] = res;
			}
	}
	
// WARNING! COMPILER PROBLEM - IF THE CONDITION IS i<256 IN THE FOR CYCLE AND i=char, WONT MAKE ANY CYCLE!
res  = IDE_getWlo();		   // get the data
res2 = IDE_getWHi();
	
return IDE_getError();
}
//----------------------------------------------------------------------------- 
void IDE_Reset(void)
{
ClrBit(PORTB,IDE_RESET);

Delay(1);

SetBit(PORTB,IDE_RESET);
}
//----------------------------------------------------------------------------- 
void IDE_DoReset(void)
{
printf("\nPerforming RESET...");

IDE_Reset();

IDE_init(0);
}
//----------------------------------------------------------------------------- 
// Input : LBA Address of sector in adr_H, _MH, _ML, _L
// Output: CHS address of sectof in Out->SecPerTrack_L, Out->NumOfHeads_L, Out->NumOfCyls_L
void LBAtoCHS(char adr_H, char adr_MH, char adr_ML, char adr_L,
	 		  DriveParams *Out,
	 		  char ForMaster)
{
DriveParams *Who;

// 32-bit values
unsigned long Heads,Cyls,SpT; 
unsigned long LBA, SpH, hlp;

// 16-bit values
unsigned int H, C, S;

if(ForMaster)	  			 // what are we using?
	Who = &Master;
else
	Who = &Slave;

// make a 32-bit value of LBA address from four 8-bit values
LBA =  (((unsigned long)adr_H) << 24) + (((unsigned long)adr_MH) << 16) 
     + (((unsigned long)adr_ML) << 8) + (((unsigned long)adr_L) << 0); 
	
// make 32-bit values from 8-bit values even thought:
// Heads - only 4 bits, Cyls - only 10 bits, Sects - only 8 bits
Heads = (Who->NumOfHeads_H  << 8) + (Who->NumOfHeads_L);
Cyls  = (Who->NumOfCyls_H   << 8) + (Who->NumOfCyls_L);
SpT   = (Who->SecPerTrack_H << 8) + (Who->SecPerTrack_L);

// now calculate Sectors-Per-Head (sectors per surface)
SpH   = SpT * Cyls;

//-------------------------
// now it's time for the conversion
// head #:
H = LBA / SpH;	  

// help variable
hlp = LBA % SpH;

// cylinder #:
C = hlp / SpT;

// sector #:
S = (hlp % SpT) + 1;
//-------------------------
// time to store the values
Out->SecPerTrack_L = (S     ) & 0xff;
Out->SecPerTrack_H = (S >> 8) & 0xff;

Out->NumOfCyls_L   = (C     ) & 0xff;
Out->NumOfCyls_H   = (C >> 8) & 0xff;

Out->NumOfHeads_L  = (H     ) & 0xff;
Out->NumOfHeads_H  = (H >> 8) & 0xff;
}
//----------------------------------------------------------------------------- 
char IDE_SectorIsInRange(char FromMaster, 
                         char adr_H, char adr_MH, char adr_ML, char adr_L)
{
DriveParams *What;
unsigned long adrIN, adrMAX,spt,noh,noc;

if(FromMaster)	  			 // what are we setting?
	What = &Master;
else
	What = &Slave;

adrIN  =  (((unsigned long)adr_H) << 24) + (((unsigned long)adr_MH) << 16) 
        + (((unsigned long)adr_ML) << 8) + (((unsigned long)adr_L) << 0); 
//-------
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
//-------
if(adrIN < (adrMAX-1))
	return 1;
else
	return 0;
}
//----------------------------------------------------------------------------- 

