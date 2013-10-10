#include <iom64v.h>
#include <macros.h>
#include <stdio.h>

#include "init.h"
#include "porty.h"
#include "ide_low.h"
#include "ide_high.h"
#include "acsi1.h"
#include "scsi.h"
#include "main.h"

/*-----------------------------------------------------------*/
asm(".area vectors(abs) \n"			// this is because we want to set 
    ".org  	0x08 		\n"			// the interupt handling a bit different
	"sbic	0x10,0 		\n"			// and immediately check the line A1
	"jmp	Int1_A1_H 	\n"			// this happens when line A1 is high
	"jmp	Int1_A1_L 	\n");		// this happens when line A1 is low
/*-----------------------------------------------------------*/
extern int _textmode;

DriveParams Master,Slave;
CMND AcsiCmnd;
/*
unsigned char buffer[512];
unsigned int bufflen;
*/
/*-----------------------------------------------------------*/
void main(void)
	{
	char p1,p2,pom,act;
	unsigned int i;
	_textmode = 1;		 // pridavat ci nepridavat \r za \n v puts

	init_devices();

//	puts("ATmega64 up and running! [14]");

 //	IDE_init(1);		   // init the IDE devices

	while(!(ACSI_i & ACSI_CS));	   // wait until CS raises (if the ST is off, CS is always low)
	SEI(); 		   	 			   //re-enable interrupts
	
	Master.DoFormat = 0;
	Slave.DoFormat  = 0;

//	bufflen = 0;	
	//-----------------
  	while(1){
/*
			if(GetCharNoWait()=='d')
				{
				printf("\n\nCmd dump (%d bytes):\n", bufflen);
				
				for(i=0; i<bufflen; i++)
					printf("%x ", buffer[i]);
					
				bufflen = 0; 
				}
*/	
			if(AcsiCmnd.Proc==1)		// if we got the complete command and we are active
				ProcessCmd();
					
			if(Master.DoFormat==1)
				{
				Master.DoFormat = 3;	// set a flag that we're formating
				IDE_FormatDisk(1);
				Master.DoFormat = 0;	// set a flag that we've finished
				}

			if(Slave.DoFormat==1)
				{
				Slave.DoFormat = 3;		// set a flag that we're formating
				IDE_FormatDisk(0);
				Slave.DoFormat = 0;		// set a flag that we've finished
				}
			}
	}
/*-----------------------------------------------------------*/
void ProcessCmd(void)
{
AcsiCmnd.Proc   = 0;
AcsiCmnd.Active = 0;
				
printf("\nCmd[%d]: %x %x %x %x %x %x",AcsiCmnd.lng, AcsiCmnd.cmd[0], AcsiCmnd.cmd[1], AcsiCmnd.cmd[2], AcsiCmnd.cmd[3], AcsiCmnd.cmd[4], AcsiCmnd.cmd[5]);
				
if(AcsiCmnd.isICD)
	SCSI_ProcessCommand(AcsiCmnd.lng);
else
	ACSI_ProcessCommand();
}
//-----------------------------------------------------------
void SetUpCmd(void)
{
if((AcsiCmnd.cmd[0] & 0x1f)==0x1f)		// if the command is '0x1f'
	{
	AcsiCmnd.isICD = 1;					// then it's a ICD command
					
	switch((AcsiCmnd.cmd[1] & 0xe0)>>5)
		{
		case  0: AcsiCmnd.lng =  7; break;
		case  1: AcsiCmnd.lng = 11; break;
		case  2: AcsiCmnd.lng = 11; break;
		case  5: AcsiCmnd.lng = 13; break;
		default: AcsiCmnd.lng =  7; break;
		}
	}
else
	{
	AcsiCmnd.isICD = 0;
	AcsiCmnd.lng   = 6;
	}
}
/*-----------------------------------------------------------*/
//#pragma interrupt_handler int1_isr:3
//external interupt on INT1
//void int1_isr(void)
void int1_isr(unsigned int ACSIv)
{
char val;

SetBit(ACSI_o,ACSI_INT); 					// INT to H
ACSI_IsInput();								// set ACSI as input

val = (ACSIv >> 8) & 0xff;  		 	// get the value
//-------------
/*
buffer[bufflen] = val;
bufflen++;
*/
//-------------
if((ACSIv & 0x01)!=1)					// A1 was LOW?
	{
	AcsiCmnd.count = 0;
	AcsiCmnd.lng   = 6;
	AcsiCmnd.Proc  = 0;
	AcsiCmnd.isICD = 0;
	
	if(((val >> 5)& 0x07) == ACSI_ID)	// if the ST is talking to us
		AcsiCmnd.Active = 1; 			// then we are active and will respond
	else
		AcsiCmnd.Active = 0; 			// otherwise we are NOT active and will NOT respond
	}
	
if(AcsiCmnd.Active)		  				   	// if we are active
	{
	AcsiCmnd.cmd[AcsiCmnd.count] = val;		// store the byte
	AcsiCmnd.count++;			   			// increment the count

	if(AcsiCmnd.count < AcsiCmnd.lng)		// if it's not the last byte
		ClrBit(ACSI_o,ACSI_INT); 			// INT to L
	
	if(AcsiCmnd.count==2)
		SetUpCmd();

	if(AcsiCmnd.count==AcsiCmnd.lng)
		AcsiCmnd.Proc = 1;
	}
	
if(AcsiCmnd.count==15)
	AcsiCmnd.count=0;
}
/*-----------------------------------------------------------*/
int putchar(char c)			// this is because standart putchar puts on UART0 and we want UART1
    {
    if (_textmode && c == '\n')
        putchar('\r');

    while ((UCSR1A & 0x20) == 0)   // UDRE, data register empty
        ;
		
    UDR1 = c;
    return c;
    }
/*-----------------------------------------------------------*/
int getchar(void)			// this is because standart getchar gets from UART0 and we want UART1
    {
    while ((UCSR1A & (1<<RXC1)) == 0);	// wait until byte is received
	
    return UDR1;
    }
/*-----------------------------------------------------------*/
int GetCharNoWait(void)			
    {
    if((UCSR1A & (1<<RXC1)) != 0)
			  return UDR1;
	else
			  return -1;
    }
/*-----------------------------------------------------------*/
void Delay(char Time)
{	 // Time = 60 je zhruba 1 sekunda
char i;

for(i=0; i<Time; i++)
	OneMiliSecond();
}
//----------------------------------------------------------------------------- 
void OneMiliSecond(void)
{ // this function makes a loop lasting 126*126*(1/16MHz) = 1 ms  
char i,j;

for(i=0; i<126; i++)	
	for(j=0; j<126; j++)
		asm("nop\n");
}
//----------------------------------------------------------------------------- 
 
