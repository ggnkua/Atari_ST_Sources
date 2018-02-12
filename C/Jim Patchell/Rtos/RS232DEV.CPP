/**********************************************************************
** RS232 Device Driver                                               **
** Copyright (c) 1995 Jim Patchell                                   **
**
***********************************************************************
**  This file provides a good example of a device driver.            **
**
** As you can see by the date above, this has been around a while.
** A device driver has a table of entry points, this is of type
** H_JVEC, defined in cio.h
**
** open: procedure for opening up a io channel
** close:procedure for closing down an io channel (release)
** get: character input, gets a single character from the device
** read: reads a buffer of data from a device
** put: character output, puts a character out to a device
** write: writes a buffer of data to a device
** status: get current status of device
** xio: mulitpurpose functions, performs any other needed function
** init: called to set up device.  init will call the central i/o (cio)
** io manager to install the device driver.
**                                                                   **
**********************************************************************/
#define RS232_BUILD	//we need all defines

#include <stdio.h>
#include "task.h"
#include "queue.h"
#include "rs232.h"
#include "cio.h"
#include <stdarg.h>

static int BRIndex[2]={RS232_BAUDRATE_9600,RS232_BAUDRATE_9600};
IO_REC TRecs[2],RRecs[2];	//two transmit, two recieve buffers
char ImrShadow=0;
char acr_shad;

static const int BaudRates[13] = {
	BAUDRATE_75,
	BAUDRATE_110,
	BAUDRATE_134,
	BAUDRATE_150,
	BAUDRATE_300,
	BAUDRATE_600,
	BAUDRATE_1200,
	BAUDRATE_1800,
	BAUDRATE_2000,
	BAUDRATE_2400,
	BAUDRATE_4800,
	BAUDRATE_9600,
	BAUDRATE_19200
};

static const int Parity[3] = {
	PARITY_NONE,
	PARITY_EVEN,
	PARITY_ODD
};

static const int StopBits[2] = {
	STOPBIT_1,
	STOPBIT_2
};

#pragma function(calling)

static long R_open(IOCB *iocb,va_list argp);
static long R_close(IOCB *iocb,va_list argp);
static long R_get(IOCB *iocb,va_list argp);
static long R_read(IOCB *iocb,va_list argp);
static long R_put(IOCB *iocb,int a,va_list argp);
static long R_write(IOCB *iocb,va_list argp);
static long R_status(IOCB *iocb,va_list argp);
static long R_xio(int cmd,IOCB *iocb,va_list argp);

#pragma function()

static const H_JVEC r_vec = {
	R_open,
	R_close,
	R_get,
	R_read,
	R_put,
	R_write,
	R_status,
	R_xio,
	R_init
};

extern "C" void EnableInterrupt(void);
extern int p_error(int,...);

/*
** initialize the RS-232 handler
*/
static void init_uart(void);

//static int LookupBaudIndex(int baud)
//{
	/*---------------------------------------------------------
	**	this routine scans thru the BAUD rate table above and
	**  returns an INDEX NUMBER for the baud rate
	---------------------------------------------------------*/
//	int i;

//	for(i=0;i<13;++i)
//		if(baud == BaudRates[i])
//			return i;
//	return -1;	/*	this is an error	*/
//}

static int LookupParity(int parity)
{
	/*--------------------------------------------------------
	** this routine scans thru the parity table above and
	** returns an INDEX NUMBER for the parity setting
	**------------------------------------------------------*/
	int i;

	for(i=0;i<4;++i)
		if(parity == Parity[i])
			return i;
	return -1;

}

static int LookupStopBits(int sb)
{
	/*-------------------------------------------------------
	** this routine scans thru the stop bit table above and
	** returns an INDEX NUMBER for the stop bit setting
	**-----------------------------------------------------*/
	int i;

	for(i=0;i<2;++i)
		if(sb == StopBits[i])
			return i;
	return -1;
}

/*-------------------------------------------------------------------
** code for device driver entry points
**-----------------------------------------------------------------*/

extern "C" {

long R_init(void)
{
	static const int PutIrqMasks[2] = {0x01,0x10};
	static const int GetIrqMasks[2] = {0x02,0x20};
	static const int DsrBits[2] = {1,2};
	static const long Command[2] = {COMMAND_REG_A,COMMAND_REG_B};
	static const long Status[2] = {STATUS_REG_A,STATUS_REG_B};
	static const long Mode[2] = {MODE_REG_A,MODE_REG_B};
	static const long Data[2] = {DATA_REG_A,DATA_REG_B};

//	init_irq();	/*	initialize interrupts for UART	*/
	/*
	** initialize IO descriptors for Uarts
	*/
	int i;

	init_uart();
	for(i=0;i<2;++i)
	{
		RRecs[i].buffer = new char[1024];	//make some big buffers
		TRecs[i].buffer = new char[1024];
		RRecs[i].size = 1024;
		TRecs[i].size = 1024;
		RRecs[i].head = 0;
		TRecs[i].head = 0;
		RRecs[i].tail = 0;
		TRecs[i].tail = 0;
		RRecs[i].nchars=0;
		TRecs[i].nchars=0;
		RRecs[i].high = 1000;
		RRecs[i].low = 0;
		TRecs[i].high = 1000;
		TRecs[i].low = 24;
		RRecs[i].eotchar = '\n';
		TRecs[i].eotchar = '\n';
		//------------------------------------------
		// create semaphore names
		//------------------------------------------
		sprintf(RRecs[i].buffer,"RRECS_RS232DEV%d",i);
		sprintf(TRecs[i].buffer,"TRECS_RS232DEV%d",i);
		RRecs[i].IOEvent = new TSemaphore(0,1,RRecs[i].buffer);
		TRecs[i].IOEvent = new TSemaphore(0,1,TRecs[i].buffer);
		RRecs[i].putirqmsk = PutIrqMasks[i];
		TRecs[i].putirqmsk = PutIrqMasks[i];
		RRecs[i].getirqmsk = GetIrqMasks[i];
		TRecs[i].getirqmsk = GetIrqMasks[i];
		RRecs[i].dsrbit = DsrBits[i];
		TRecs[i].dsrbit = DsrBits[i];
		RRecs[i].uartdata = (char *)Data[i];
		TRecs[i].uartdata = (char *)Data[i];
		RRecs[i].statusreg = (char *)Status[i];
		TRecs[i].statusreg = (char *)Status[i];
		RRecs[i].bsreg = (char *)BIT_SET_COMMAND;
		TRecs[i].brreg = (char *)BIT_RESET_COMMAND;
		RRecs[i].modereg = (char *)Mode[i];
		TRecs[i].modereg = (char *)Mode[i];
		RRecs[i].cmdreg = (char *)Command[i];
		TRecs[i].cmdreg = (char *)Command[i];
		RRecs[i].timeout = 0;
		TRecs[i].timeout = 0;
		sprintf(TRecs[i].buffer,"TRECS_BLOCKER%d",i);
		TRecs[i].WritersBlock = new Wait(1,TRecs[i].buffer);	//blocking semaphore, one use
	}
	*(char *)INTERRUPT_VECTOR_REG = 0x40;
	EnableInterrupt();
	return AddHandler("R",&r_vec);
}

}

static void init_uart(void)
{
	*((char *)(INTERRUPT_MASK_REG)) = 0x0;	/* DISABLE INTERRUPTS */

	*((char *)(COMMAND_REG_A)) = 0x10;	/* reset MR ptr */
	*((char *)(COMMAND_REG_A)) = 0x20;   /* reset rxr	*/
	*((char *)(COMMAND_REG_A)) = 0x30;   /* reset TXD */
	*((char *)(MODE_REG_A)) = 0x13;		/*	no parity, 8 bits	*/
	*((char *)(MODE_REG_A)) = 0x07;		/*	1 stop bit	*/
	*((char *)(STATUS_REG_A) ) = BAUDRATE_19200;	/*	9600 buad	*/
	*((char *)(COMMAND_REG_A)) = 0x04;	/*	transmit enabled	*/
	*((char *)(COMMAND_REG_A)) = 0x01;   /* recieve enabled */

	acr_shad = 0x8c;
	*((char *)(AUX_CONTROL_REG)) = acr_shad;	/*	enable change bits on ip2 and ip3	*/

	*((char *)(COMMAND_REG_B)) = 0x10;	/* reset MR ptr */
	*((char *)(COMMAND_REG_B)) = 0x20;   /* reset rxr	*/
	*((char *)(COMMAND_REG_B)) = 0x30;   /* reset TXD */
	*((char *)(MODE_REG_B)) = 0x93;		/*	no parity, 8 bits	*/
	*((char *)(MODE_REG_B)) = 0x07;		/*	1 stop bit	*/
	*((char *)(STATUS_REG_B) ) = BAUDRATE_9600; 	/* 9600 Baud	*/
	*((char *)(COMMAND_REG_B)) = 0x04; 	/*	transmit enabled	*/
	*((char *)(COMMAND_REG_B)) = 0x01;   /* recieve enabled */

	*((char *)(BIT_SET_COMMAND)) = 0x0f;	/*	 set all handshake lines	*/
}


static long R_open(IOCB *iocb,va_list argp)
{
	int dev = iocb->devnum - 1;
	int sr;

	if (iocb->mode & READ_ONLY)
	{
		/*
		**	enable system interrupts
		*/
		sr = EnterCritical();	/*	disable interrupts	*/
		RRecs[dev].head = 0;
		RRecs[dev].tail = 0;
		RRecs[dev].nchars = 0;
		ImrShadow |= RRecs[dev].getirqmsk;	/*	enable interrupt bit	*/
		*((char *)(INTERRUPT_MASK_REG)) = ImrShadow;
		ExitCritical(sr);
	}
	if(iocb->mode & WRITE_ONLY)
	{
		TRecs[dev].head = 0;
		TRecs[dev].tail = 0;
		TRecs[dev].nchars = 0;
	}
	return(0);
}

static long R_close(IOCB *iocb,va_list argp)
{
	/*
	** disable the UART interrupts
	*/
	int dev = iocb->devnum - 1;
	int v;
	int sr;

	v = RRecs[dev].getirqmsk;
	v |= RRecs[dev].putirqmsk;
	sr = EnterCritical();
	ImrShadow &= ~v;
	*((char *)(INTERRUPT_MASK_REG)) = ImrShadow;
	ExitCritical(sr);
	return(0);
}

static long R_get(IOCB *iocb,va_list argp)
{
	/************************************************************************
	** get a character from the RS232 port buffer
	**
	** If there are no characters in the buffer, pend until there is.
	** Pending is required so that other tasks can be running when there
	** are no characters and we don't tie things up waiting to run
	**
	************************************************************************/
	int dev;	//minor device number
	int error=0;	//multitasking error status
	int c;
	int sr;

	dev = iocb->devnum - 1;	//get the device number
	sr = EnterCritical();
	if(!RRecs[dev].nchars)	//are there any characters to get	?
	{
		if(RRecs[dev].timeout < 0)	//instant respose?
		{
			ExitCritical(sr);
			return (long)RS232_TIMEOUT;
		}
		else
		{
			ExitCritical(sr);
			//
			// suspend task while waiting for characters
			error = RRecs[dev].IOEvent->Pend(RRecs[dev].timeout);
			if(error == EVENT_TIMEOUT)
				return (long)RS232_TIMEOUT;
			sr = EnterCritical();
		}
	}
	c = (unsigned char)RRecs[dev].buffer[RRecs[dev].tail++];	//get char
	if(RRecs[dev].tail == RRecs[dev].size)
		RRecs[dev].tail = 0;		//wrap circular buffer
	if(--RRecs[dev].nchars <= RRecs[dev].low)		//decrement total number of chars
	{
		//low water mark was reached.  Fiddle with flow control lines
		*RRecs[dev].bsreg = (char)RRecs[dev].dsrbit;	//open up floodgate
	}
	ExitCritical(sr);
	return (long)c;
}

static long R_read(IOCB *iocb,va_list argp)
{
	long i;
	char *b = va_arg(argp,char *);
	long count = va_arg(argp,long);

	for(i=0;i<count;++i,++b)
		*b = (char)R_get(iocb,argp);
	return i;
}

static long R_put(IOCB *iocb,int c,va_list argp)
{
	/*********************************************************************
	**
	** Put a character into an RS232 buffer
	**
	**	If the buffer is full, pend on buffer empty.  This will allow
	** other tasks to execute while waiting for the buffer to empty
	**
	*********************************************************************/

	int error=0;	//multitasking error status
	IO_REC *dev = &TRecs[iocb->devnum - 1];
	int sr;

	sr = EnterCritical();			//disable interrupts
	if(dev->nchars == dev->size)	//is buffer FULL?
	{
		if(!(ImrShadow & dev->putirqmsk))
		{
			ImrShadow |= dev->putirqmsk;
			*((char *)INTERRUPT_MASK_REG) = ImrShadow;
		}
		ExitCritical(sr);
		if(dev->timeout < 0)	//return immeadiately?
		{
			return (long) RS232_TIMEOUT;	//return timeout error
		}
		else
		{
			error = dev->IOEvent->Pend(dev->timeout);
		}
		sr = EnterCritical();
	}
	//
	// put data into output buffer
	//
	dev->buffer[dev->head++] = (char)c;
	if(dev->head == dev->size)
		dev->head = 0;	//wrap buffer
	dev->nchars++;
	if(((c == dev->eotchar) || (dev->eotchar < 0)) && !(ImrShadow & dev->putirqmsk))
	{
		ImrShadow |= dev->putirqmsk;
		*((char *)INTERRUPT_MASK_REG) = ImrShadow;
	}
	ExitCritical(sr);
	return 0l;
}

static long R_write(IOCB *iocb,va_list argp)
{
	long i;
	IO_REC *dev = &TRecs[iocb->devnum - 1];
	char *b = va_arg(argp,char *);
	long count = va_arg(argp,long);

	dev->WritersBlock->Pend();
	for(i=0;i<count;++i,++b)
		R_put(iocb,(int)(unsigned char)*b,argp);
	dev->WritersBlock->Post(0);
	return i;
}

static long R_xio(int cmd,IOCB *iocb,va_list argp)
{
	volatile int a;	/*	temp variable	*/
	int dev = iocb->devnum - 1;
	long retval=0;
	char *buffer = va_arg(argp,char *);
	long count = va_arg(argp,long);
	int aux = va_arg(argp,int);
	/*
	** execute misc function needed by RS-232 port
	*/
	switch(cmd)	/*	decode command	*/
	{
		case SET_BAUD_RATE:
			/*
			** baud rate is in aux (an int)
			*/
			BRIndex[dev] = aux;	/*	store baudrate for later	*/
			*(RRecs[dev].statusreg) = (char)BaudRates[aux];
			break;
		case SEND_BREAK:
			break;
		case WAIT_EMPTY:
			/*	wait for transmit buffer to empty	*/
			while(TRecs[dev].tail != TRecs[dev].head);	/*	wait for index to be equal	*/
			break;
		case SET_MODE:
			break;
		case SET_INPUT_BUFFER:
			break;
		case SET_OUTPUT_BUFFER:
			break;
		case MEM_PROTECT:	/*	set memprotect hardware line	*/
			/*
			** Aux = 0->mem protect off
			** Aux = 1->mem protect on
			*/
			if(aux)
				*((char *)(BIT_RESET_COMMAND)) = SET_PROTECT_BIT;
			else
				*((char *)(BIT_SET_COMMAND)) = SET_PROTECT_BIT;
			break;
		case SET_ERROR:
			/*
			** Aux = 0->turn error light off
			** Aux = 1->turn error light on
			*/
			if(aux)
				*((char *)(BIT_RESET_COMMAND)) = SET_ERROR_BIT;
			else
				*((char *)(BIT_SET_COMMAND)) = SET_ERROR_BIT;
			break;
		case SET_ACTIVE:
			/*
			** Aux = 0->turn active light off
			** aux = 1->turn active light on
			*/
			if(aux)
				*((char *)(BIT_RESET_COMMAND)) = SET_ACTIVE_BIT;
			else
				*((char *)(BIT_SET_COMMAND)) = SET_ACTIVE_BIT;
			break;
		case READ_INPORT:
			return *((char *)(INPUT_PORT_REG));
			break;
		case RS232_SET_PARITY:
			/*	reset MR pointer to MR1	*/
			*(RRecs[dev].cmdreg) = 0x10;
			/*	get mode reg variable	*/
			a = (int)*(RRecs[dev].modereg);
			a &= ~PARITY_MASK;
			a |= Parity[aux];
			/*	reset MR pointer to MR1	*/
			*(RRecs[dev].cmdreg) = 0x10;
			*(RRecs[dev].modereg) = (char)a;
			break;
		case RS232_SET_BITS:
			/*
			** set number of data bits
			*/
			/*	reset MR pointer to MR1	*/
			*(RRecs[dev].cmdreg) = 0x10;
			/*	get mode reg variable	*/
			a = (int)*(RRecs[dev].modereg);
			a &= ~0x03;	/*	mask off bits / character */
			a |= aux & 0x03;		/*	new bits per char	*/
			/*	reset MR pointer to MR1	*/
			*(RRecs[dev].cmdreg) = 0x10;
			*(RRecs[dev].modereg) = (char)a;
			break;
		case RS232_SET_STOP:
			/*
			** set number of stop bits
			*/
			/*	reset MR pointer to MR1	*/
			*(RRecs[dev].cmdreg) = 0x10;
			/*	get mode reg variable	*/
			a = (int)*(RRecs[dev].modereg);
			a = (int)*(RRecs[dev].modereg);	/*	now point to MR2	*/
			a &= ~0x0f;						/*	mask off bits / character */
			a |= StopBits[aux];		/*	new bits per char	*/
			*(RRecs[dev].modereg) = (char)a;
			break;
		case RS232_GET_BAUD:
			retval = (long)BRIndex[dev];
			break;
		case RS232_GET_PARITY:
			/*	reset MR pointer to MR1	*/
			*(RRecs[dev].cmdreg) = 0x10;
			/*	get mode reg variable	*/
			a = (int)*(RRecs[dev].modereg);
			a &= PARITY_MASK;
			retval = (long)LookupParity(a);
			break;
		case RS232_GET_BITS:
			/*	reset MR pointer to MR1	*/
			*(RRecs[dev].cmdreg) = 0x10;
			/*	get mode reg variable	*/
			retval = (long)*(RRecs[dev].modereg) & 0x03;
			break;
		case RS232_GET_STOP:
			/*	reset MR pointer to MR1	*/
			*(RRecs[dev].cmdreg) = 0x10;
			/*	get mode reg variable	*/
			a = (int)*(RRecs[dev].modereg);
			a = (int)*(RRecs[dev].modereg) & 0x0f;	/*	access of MR2	*/
			retval = (long) LookupStopBits(a);
			break;
		case RS232_SET_PUTEOT:
			TRecs[dev].eotchar = aux;
			break;
		case RS232_SET_RTIMEOUT:
			RRecs[dev].timeout = aux;
			break;
		case RS232_SET_GETEOT:
			RRecs[dev].eotchar = aux;
			break;

	}	/*	end of switch command	*/

	return(retval);
}

static long R_status(IOCB *iocb,va_list argp)
{
	/*
	** This code returns the number of bytes in the
	** recieve buffer
	*/
	int dev = iocb->devnum - 1;
	char *buffer = va_arg(argp,char *);
	long count = va_arg(argp,long);
	int aux = va_arg(argp,int);

	switch(aux)		/*	which status function	*/
	{
		case RECEIVE_STAT:
			return RRecs[dev].nchars;	/*	return number of characters	*/
		case SEND_STAT:
			return TRecs[dev].nchars;	/*	return number of xmit chars	*/
	}


	return(RRecs[dev].nchars);		/*	default, return recieve chars	*/
}

#pragma function(calling)

extern "C" {

void HandlePutInterrupt(int d)
{
	//--------------------------------------
	// this function is called by the uart
	// isr handler in response to a PUT
	//--------------------------------------
	IO_REC *t = &TRecs[d];		//get address of device record

	while(*t->statusreg & 0x04)
	{
		if(!t->nchars)		//is buffer empty?
		{
			ImrShadow &= ~t->putirqmsk;		//disable transmit interrupt
			*((char *)INTERRUPT_MASK_REG) = ImrShadow;
			goto exit;	//just leave
		}
		else				//buffer still has data, put it out
		{
			*t->uartdata = t->buffer[t->tail++];	//stuff data into data reg
			if(t->tail == t->size)
				t->tail = 0;						//wrap circular buffer
			if(--t->nchars <= t->low)				//reach low water? or below?
			{
				if(t->IOEvent->GetCount() < 0)		//task pending?
					t->IOEvent->Post(0);		//Let calling task know
			}
		}
	}		//keep stuffing chars while you can
exit:
	return;
}

void HandleGetInterrupt(int d)
{
	//--------------------------------------
	// this function is called by the uart
	// isr handler in response to a GET
	//--------------------------------------
	IO_REC *t = &RRecs[d];		//address of IO descriptor
	char c;

	do
	{

		c = *t->uartdata;
		if(t->nchars < t->size)		//is there space?
		{
			t->buffer[t->head++] = c;	//get data from uart
			if(t->head == t->size)
				t->head = 0;			//wrap buffer
			++t->nchars;				//increment character count
		}
		if(t->nchars == t->high)	//high water mark?
		{
			*t->brreg = (char)t->dsrbit;	//stop up flood gate
			if(t->IOEvent->GetCount() < 0)	//if task pending
				t->IOEvent->Post(0);
		}
		//--------------------------------------------
		// check end of transmission character
		// if it is less than zero, post semaphore anyway
		//--------------------------------------------
		else if ((c == t->eotchar) || (t->eotchar < 0))
		{
			if(t->IOEvent->GetCount() < 0)	//if task pending
				t->IOEvent->Post(0);
		}
	}while(*t->statusreg & 0x01);		//read as many as posible
}

}	//end of extern C
