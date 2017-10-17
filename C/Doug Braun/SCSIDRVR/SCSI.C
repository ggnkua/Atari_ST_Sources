

#include <stdio.h>
#include <dos.h>
#include "scsi.h"


/* This is the host adapter address */
#define SCSIPORT 0x320

/* These are the variables that hold the data for the scsiop routine*/

static char busid;
static char far *cptr; 
static char far *dptr;
static unsigned dlen;
static unsigned adlen;

static struct scsibuf *curbuf;

static char rwflag;
static int status;
static int message;

	char scsimsg[80];

/* Following are the commands for SCSI operations */

void
scsiop(req)
struct scsireq *req;
{
    int s;
	long timeout;
	long maxtimeout;
	long contimeout;
	int statuscnt;

	cptr = req->cptr;
	dptr = req->dptr;
	dlen = req->dlen;
	busid = req->busid;

	req->error = 0;

	if (req->timeout > 0)
	{
		maxtimeout = req->timeout * 5000L;
		contimeout = req->timeout * 5000L;
	}
	else
	{
	    maxtimeout = 100 * 5000L;  /* 10 second default */
		contimeout = 100 * 5000L;
	}

	dma_connect();   /* tell controller to obey dma chip */

	if (connect(contimeout) != 0)	 /* select the controller on the scsi bus */
	{
		req->error |= S_BUSERROR | S_NOCONNECT;
		return;
	}

	statuscnt = 0;

	for (;;)
	{
		timeout = maxtimeout;
	    while (((s = inportb(SCSIPORT+1)) & 0x80) == 0)
		{
			if (timeout-- == 0)
			    goto timedout;

			if ((s & 0x10) == 0)
			    goto nomore;		/* No longer connected */
		}

		switch (s & 0x68)
		{
		case 0x40:    /* Get data */
			if (dlen <= 0)
			{
				req->error |= S_BUSERROR | S_OVERRUN;
				inportb(SCSIPORT);
			}
			else
			{
				rwflag = 0;
				do_dma();
			}
			break;

		case 0x00:    /* Put data */
			if (dlen <= 0)
			{
				req->error |= S_BUSERROR | S_OVERRUN;
				outportb(SCSIPORT, 0);
			}
			else
			{
				rwflag = 1;
				do_dma();
			}
			break;

		case 0x20:    /* Put command */
		    outportb(SCSIPORT, *cptr++);
		    short_delay();
			break;

		case 0x60:    /* Get status */
		    status = inportb(SCSIPORT);
			statuscnt++;
			req->error |= (status & 0xff);
		    short_delay();
			break;

		case 0x68:    /* Get message */
		    message = inportb(SCSIPORT);
			if (message != 0)
			    req->error |= S_BUSERROR | S_BADMESSAGE;
		    short_delay();
			break;

		default:
		    req->error |= S_BUSERROR | S_BADTRANS;
		    if (s & 0x40)
			    inportb(SCSIPORT);
			else
			    outportb(SCSIPORT, 0);
		    short_delay();
			break;
		}

	}

nomore:
	if (statuscnt != 1)
	    req->error |= S_BUSERROR | S_BADSTATUS;
	outportb(SCSIPORT, 0);	/* Turn off data bus lines */
	return;

timedout:
	req->error |= S_BUSERROR | S_TIMEOUT;
	outportb(SCSIPORT, 0);	/* Turn off data bus lines */
	return;
}



/* This waits until REQ is deasserted.  It will time out after a while */
short_delay()
{
    int j;

	j = 200;
	while (j--)
	{
	    inportb(SCSIPORT+1);
	}
}


do_dma()
{
	/* If the data buffer crosses a 64k boundary, it may take
	more than 1 operation to get it. Thus the loop */

	while (dlen > 0)
	{
		setup_dma();
		arm_dma();
		if (dma_wait() < 0)		/* wait for actual i/o */
		    break;
		disarm_dma();
	}
}


do_vdma()
{
	/* If the data buffer crosses a 64k boundary, it may take
	more than 1 operation to get it. Thus the loop */

	/* printf((CHARPTR)"        Doing vdma with curbuf: %Fp curbuf->dptr: %Fp\n", curbuf,  curbuf->dptr); */

	while (curbuf->dptr != NULL)
	{
	    dptr = curbuf->dptr;
		dlen = curbuf->dlen;
		curbuf++;

		/* printf((CHARPTR)"        Doing a VDMA iteration from %Fp of %d bytes\n", dptr, dlen); */

		while (dlen > 0)
		{
			setup_dma();
			arm_dma();
			if (dma_wait() < 0)		/* wait for actual i/o */
			    break;
			disarm_dma();
		}
	}
}


/* This resets the scsi bus: */

reset_scsi()
{
	static int cnt;

	cnt = 256;
	while (cnt-- > 0)
	{
		outportb(SCSIPORT+1,0);  /* was al */
		inportb(SCSIPORT+2);
		if ((inportb(SCSIPORT+1) & 0xfc) == 0)
		    return (0);
	};
	return (-1);
}




/* This sets up the dma based on dptr, dlen and rwflag */

setup_dma()
{
    unsigned pseg, poff;  /* physical address segment and offset */

	if (dlen <= 0)
	    return;

	poff = (unsigned)((FP_SEG(dptr) << 4) + FP_OFF(dptr));
	pseg = (unsigned)((FP_SEG(dptr) + (FP_OFF(dptr) >> 4)) >> 12);

    if ( poff + dlen < poff) /* wraparound */
	    adlen = -poff;  /* # of bytes in current 64k chunk */
	else
	    adlen = dlen;

	disable();
	outportb(0x0a, 0x07); /* ;clear channel 3 mask */

	/* write to mode register for: single mode, increment,
		auto. init. disable, read or write, channel 3. */

	outportb( 0x0b, rwflag ? 0x4b : 0x47); /* see if read or write */

	/* 4 high addr bits go in special i/o port */
	outportb (0x82, pseg);

	outportb(0x0c, 0); /* clear byte pointer flip-flop */

	/* send both bytes of address to address register 3 */
	outportb(0x06, poff & 0xff);
	outportb(0x06, poff >> 8);

	outportb(0x07, (adlen-1) & 0xff);
	outportb(0x07, (adlen-1) >> 8);  	/* send byte count - 1 to dma count reg 3 */

	enable();  /* restore interrupts */

	dptr += adlen;
	dlen -= adlen;

}



/* This connects to the correct address on the scsi bus */

connect(count)
long count;
{

	if (free_wait(count) != 0)
	    return (-2);

	outportb(SCSIPORT, busid);	/* output bus id for connect */
	outportb(SCSIPORT+2, 0); /* assert select */

	while (count--)
	{
  	    if ((inportb(SCSIPORT+1) & 0x10) == 0x10)
		{
			/* Clear select */
			inportb(SCSIPORT+2);
			return(0);
		}
	}

	/* Timed out */
    return (-1);
}


/* This waits until the bus is free before making a connection */

free_wait(count)
long count;
{
	while (count--)
	{
  	    if ((inportb(SCSIPORT+1) & 0xfc) == 0)
		    return (0);
	}

	return (-1);  /* time out */
}



/* This tests the bus status against ah, and returns whether or
not the condition is met. We check twice. */

scsi_test(cond)
int cond;
{
    if ((inportb(SCSIPORT+1) & 0xf8) == cond && (inportb(SCSIPORT+1) & 0xf8) == cond)
	    return (0);
	else
	    return(-1);
}



/* This loops, waiting for the DMA finish, for the data to run out.
It has an extra-long timeout. dmatimeout gives the timeout length */

dma_wait()
{
    static long cnt;
#ifdef DEBUG
	static int lobyte;
#endif

	cnt = 200000L;
	while (cnt--)
	{
		/* See if we have reached the status phase */
	    /* if ((inportb(SCSIPORT+1) & 0xf8) == 0xf0) */
		if (scsi_test(0xf0) == 0)
		{
#ifdef DEBUG
			outportb(0x0c, 0); /* clear byte pointer flip-flop */
			lobyte = inportb(0x07);
			printf((CHARPTR)"DMA residue at status: %d bytes\n",
				256 * inportb(0x07) + lobyte + 1);
#endif
			return (1);
		}

		/* See if DMA has reached Terminal Count */
		if (inportb(0x08) & 0x08)
		{
#ifdef DEBUG
			outportb(0x0c, 0); /* clear byte pointer flip-flop */
			lobyte = inportb(0x07);
			printf((CHARPTR)"DMA residue at TC: %d bytes\n",
				256 * inportb(0x07) + lobyte + 1);
#endif
			return (2);
		}
		
	}
#ifdef DEBUG
	printf((CHARPTR)"dma_wait times out\n");
	outportb(0x0c, 0); /* clear byte pointer flip-flop */
	lobyte = inportb(0x07);
	printf((CHARPTR)"DMA residue: %d bytes\n", 256 * inportb(0x07) + lobyte + 1);
#endif

	return (-1);
}


arm_dma()
{
	/* clear mask bit of channel 3, allowing dma to start */
	outportb(0x0a, 0x03);
}


disarm_dma()
{
    /* set mask bit of channel 3 */
	outportb(0x0a, 0x07);
}


/* These either enable or disable the host adapter's DRQ line
(for the DMA) or its INT line (to the interrupt controller). */

dma_connect()
{
	outportb(SCSIPORT+3, 0x01);
}


dma_disconnect()
{
    outportb(SCSIPORT+3, 0);
}


