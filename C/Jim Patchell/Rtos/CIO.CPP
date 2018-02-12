/*************************************************************************
**	C version of CIO
**	Copyright (c) 1991 Jim Patchell
**
**	This is the Central Input Output device handler.  This is probably
**	a lame attempt to make access to various I/O devices a little more
**	orthagonal.  Maybe, maybe not.
**
**  The interface function, cio only requires one parameter, but accepts
**	a variable number of parameters depending on the type of function
**	it is that is being executed.
**
**	The functions that can be executed are:
**
**		add handler
**		open
**		close
**		get
**		get record (read)
**		put
**		put record (write)
**		status
**		special command (xio)
**
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "cio.h"
#include "task.h"
#include "queue.h"

/*
	cio global variables
*/

static IOCB Iocb[32];	/*	space for 32 I/O channeles	*/
static HTABS htabs[20];	/*	space for 20 I/O devices	*/
static int last_dev = 0;	/*	last device entry in table	*/

static free_iocb(int handle);
static find_free_iocb(void);
static dev_search(int handle);

static Wait *IocbEvent = NULL;

extern "C" long cio(va_list argp)
{
	int handle;
	int a;	/*	temporary data storage	*/
	IOCB *iocb;
	int cmd;
	long b;		//another temporary data storage
	cmd = va_arg(argp,int);		//get function command
	iocb = Iocb;
	switch(cmd)
	{
		case ADD_HANDLER:
			/*
			** This command is used to insert handler vector into HTABS
			** called as: cio(cmd,devname,table)
			*/
			IocbEvent->Pend();
			htabs[last_dev].dev_name = va_arg(argp,char *);	/*	device name	*/
			htabs[last_dev].HtabsEntry = va_arg(argp,H_JVEC *);	/*	address of table	*/
			++last_dev;
			IocbEvent->Post();		//unblock add handler
			break;
		case OPEN:
			IocbEvent->Pend();
			if((handle = find_free_iocb()) == -1)
			{
				IocbEvent->Post();
				return(CIO_NO_HANDLES);
			}
			/*
				get open parrameters off of stack
				passed as cio(cmd,name,mode)
			*/
			iocb += handle;
			iocb->dev_name = va_arg(argp,char *);
			iocb->mode = va_arg(argp,int);
			if(( iocb->ichid = dev_search(handle)) < 0)
			{
				IocbEvent->Post();
				return(CIO_NO_DEVICE);	/*	could not find device handle	*/
			}
			/* we have laid claim to the IOCB, release iocbevent	*/
			IocbEvent->Post();
			if((a = (*htabs[iocb->ichid].HtabsEntry->openv)(iocb,argp)) < 0)
			{
				handle = a;		//return ERROR
				iocb->ichid = -1;	//free up IOCB again
			}
			return(handle);
		case CLOSE:
			/*
				get close parrameters off of stack
				passes as: cio(cmd,handle);
			*/
			handle = va_arg(argp,int);
			iocb += handle;
			if(handle > MAX_HANDLE || handle < 0)
				return(CIO_INVLD_HNDL);
			if(iocb->ichid < 0)
				return(CIO_NOT_OPEN);
			(*htabs[iocb->ichid].HtabsEntry->closv)(iocb,argp);
			return(free_iocb(handle));
		case GETC:
			/*
			** Get character from handler
			** called as:  cio(GETC,handle)
			*/
			handle = va_arg(argp,int);
			if(handle > MAX_HANDLE || handle < 0)
				return(CIO_INVLD_HNDL);
			iocb += handle;
			if(iocb->ichid < 0)
				return(CIO_NOT_OPEN);
			if((cmd & iocb->mode) == 0)
				return(CIO_WRONLY);
			//
			// look up function
			//
			return ( (*htabs[iocb->ichid].HtabsEntry->getv)(iocb,argp)  );
		case READ:
			/*
			** Get a character buffer from handler
			** called as: cio(READ,handle,buffer,count)
			** driver function returns either an error or
			** actual number of bytes read
			*/
			handle = va_arg(argp,int);
			if(handle > MAX_HANDLE || handle < 0)
				return(CIO_INVLD_HNDL);
			iocb += handle;
			if(iocb->ichid < 0)
				return(CIO_NOT_OPEN);
			if((cmd & iocb->mode) == 0)
				return(CIO_WRONLY);
			//
			//look up function
			//
			return (*htabs[iocb->ichid].HtabsEntry->readv)(iocb,argp);
		case PUTC:
			/*
			** Put data to device
			**           : cio(PUTC,handle,data)
			*/
			handle = va_arg(argp,int);
			if(handle > MAX_HANDLE || handle < 0)
				return(CIO_INVLD_HNDL);
			iocb += handle;
			if(iocb->ichid < 0)
				return(CIO_NOT_OPEN);
			if((iocb->mode & cmd) == 0)
				return(CIO_RDONLY);	/*	read only error	*/
			a = va_arg(argp,int);
			//
			//look up function
			//
			return( (*htabs[iocb->ichid].HtabsEntry->putv)(iocb,a,argp));
		case WRITE:
			/*
			** Write buffer to a device
			**  called as: cio(WRITE,handle,buffer,count);
			** returns either an error or actual number of bytes written
			*/
			handle = va_arg(argp,int);
			if(handle > MAX_HANDLE || handle < 0)
				return(CIO_INVLD_HNDL);
			iocb += handle;
			if(iocb->ichid < 0)
				return(CIO_NOT_OPEN);
			if((iocb->mode & cmd) == 0)
				return(CIO_RDONLY);	/*	read only error	*/
			return( (*htabs[iocb->ichid].HtabsEntry->writev)(iocb,argp));
		case STATUS:
			/*
			** This is where a status call is handled
			**
			** called as: cio(cmd,handle,NULL,buffer,count,aux)
			**
			** if handle is -1, then devname is used to open iocb
			** buffer is where status info is put, device dependent
			** parameters in this case are as follows:
			** cio(cmd,-1,devname,buffer,count,aux)
			*/
			handle = va_arg(argp,int);
			if(handle < 0)
			{	/*	this is immeadiate operation	*/
				IocbEvent->Pend();
				if((handle = find_free_iocb()) == -1)
				{
					IocbEvent->Post();
					return(CIO_NO_HANDLES);	/* open up an IOCB	*/
				}
				iocb += handle;
				iocb->dev_name = va_arg(argp,char *);
				if(( iocb->ichid = dev_search(handle)) < 0)
				{
					IocbEvent->Post();
					return(CIO_NO_DEVICE);	/*	could not find device handle	*/
				}
				/* we have grabed this IOCB	*/
				IocbEvent->Post();
				b = (*htabs[iocb->ichid].HtabsEntry->statv)(iocb,argp);
				free_iocb(handle);	/*	close iocb	*/
				return(b);
			}
			else
			{	/*	valid handle for already open iocb	*/
				iocb += handle;
				if(handle > MAX_HANDLE || handle < 0)
					return(CIO_INVLD_HNDL);
				return((*htabs[iocb->ichid].HtabsEntry->statv)(iocb,argp) );
			}
		default:
			/*
			** This is where the special commands are handled
			** called as:  cio(cmd,handle,buffer,count,aux)
			** if handle is -1, then parameters are as follows
			** called as:  cio(cmd,-1,dev_name,buffer,count,aux)
			*/
			if((handle = va_arg(argp,int)) < 0)
			{
				/*
					this is an immediate operation
				*/
				IocbEvent->Pend();
				if((handle = find_free_iocb()) == -1)
				{
					IocbEvent->Post();
					return(-1);	/* open up an IOCB	*/
				}
				iocb += handle;
				iocb->dev_name = va_arg(argp,char *);
				if(( iocb->ichid = dev_search(handle)) < 0)	/*	locate handler entry table	*/
				{
					IocbEvent->Post();
					return(-1);	/*	could not find device handle	*/
				}
				/*	we have grabbed the IOCB	*/
				IocbEvent->Post();
				b = (*htabs[iocb->ichid].HtabsEntry->specv)(cmd,iocb,argp);
				free_iocb(handle);
				return(b);
			}
			else
			{
				/*
				** iocb is already open
				*/
				iocb += handle;
				va_arg(argp,char *);	//get rid of dummy device name
				return((*htabs[iocb->ichid].HtabsEntry->specv)(cmd,iocb,argp));
			}
	}	/*	end switch cmd	*/
	return 0l;	//everything is peachy keen
}

static dev_search(int handle)
{
	/*
		search device table for device named and return index into
		device table
	*/
	int i;
	HTABS *ht;
	IOCB *iocb;
	char *n,un[4];		/*unit numbers up to 999	*/
	int l;		/*	legnth of device name	*/

	iocb = Iocb + handle;
	l = strcspn(iocb->dev_name,":123456789");	/*	we need to find what is not unit number	*/
	ht = htabs + last_dev - 1;									/*	point to handler table	*/


	for(i=last_dev -1;(i > -1) && strncmp(iocb->dev_name,ht->dev_name,l) ;--i,--ht);
	if(i >= 0)
	{
		/*
		** ok, now we need to locate the unit number
		*/
		n = iocb->dev_name + l;
		if((l = strcspn(n,":")) == 0)
		{
			iocb->devnum = 1;		/*	default unit number	*/
		}
		else
		{
			strncpy(un,n,l);
			un[l] = '\0';
			iocb->devnum = atoi(un);	/*	convert unit number	*/
		}
	}
	return(i);
}

static find_free_iocb(void)
{
	int i;
	IOCB *iocb;

	for(i=0,iocb = Iocb;i<32;++i,++iocb)
	{
		if(iocb->ichid == -1)
			return(i);
	}
	return(-1);
}

static free_iocb(int handle)
{
	Iocb[handle].ichid = -1;
	return(0);
}

extern "C" void init_iocb(void)
{
	int i;
	IOCB *iocb;

	IocbEvent = new Wait(1,"CIO_BLOCKING_SEMAPHORE");	//create blocking semaphore for CIO
	for(i=0,iocb = Iocb;i<32;++i,++iocb)
	{
		iocb->ichid = -1;
		iocb->p = (void *)0;
	}
	last_dev = 0;
}
