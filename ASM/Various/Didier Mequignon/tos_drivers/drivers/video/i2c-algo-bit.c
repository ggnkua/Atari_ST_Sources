/* ------------------------------------------------------------------------- */
/* i2c-algo-bit.c i2c driver algorithms for bit-shift adapters		     */
/* ------------------------------------------------------------------------- */
/*   Copyright (C) 1995-2000 Simon G. Vogl

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.		     */
/* ------------------------------------------------------------------------- */

/* With some changes from Frodo Looijaard <frodol@dds.nl>, Kyösti Mälkki
   <kmalkki@cc.hut.fi> and Jean Delvare <khali@linux-fr.org> */

#include "config.h"
#include <mint/errno.h>
#include "i2c.h"
#include "i2c-algo-bit.h"
#include "relocate.h"

#ifndef NULL
#define NULL ((void *)0)
#endif

#undef DEBUG

#ifdef CONFIG_FB_RADEON_I2C

extern void start_timeout(void);
extern int end_timeout(long msec);
extern void udelay(long usec);

/* --- setting states on the bus with the right timing: ---------------	*/

#define setsda(adap,val) adap->setsda(adap->data, val)
#define setscl(adap,val) adap->setscl(adap->data, val)
#define getsda(adap) adap->getsda(adap->data)
#define getscl(adap) adap->getscl(adap->data)

static inline void sdalo(struct i2c_algo_bit_data *adap)
{
	setsda(adap,0);
	udelay(adap->udelay);
}

static inline void sdahi(struct i2c_algo_bit_data *adap)
{
	setsda(adap,1);
	udelay(adap->udelay);
}

static inline void scllo(struct i2c_algo_bit_data *adap)
{
	setscl(adap,0);
	udelay(adap->udelay);
}

/*
 * Raise scl line, and do checking for delays. This is necessary for slower
 * devices.
 */
static inline int sclhi(struct i2c_algo_bit_data *adap)
{
	setscl(adap,1);
	/* Not all adapters have scl sense line... */
	if(adap->getscl == NULL )
	{
		udelay(adap->udelay);
		return 0;
	}
	start_timeout();
	while(! getscl(adap))
	{	
 		/* the hw knows how to read the clock line,
 		 * so we wait until it actually gets high.
 		 * This is safer as some chips may hold it low
 		 * while they are processing data internally. 
 		 */
		if(end_timeout((long)adap->timeout))
			return -ETIMEDOUT;
	}
	udelay(adap->udelay);
	return 0;
} 


/* --- other auxiliary functions --------------------------------------	*/
static void i2c_start(struct i2c_algo_bit_data *adap) 
{
	/* assert: scl, sda are high */
	sdalo(adap);
	scllo(adap);
}

static void i2c_repstart(struct i2c_algo_bit_data *adap) 
{
	/* scl, sda may not be high */
	setsda(adap,1);
	sclhi(adap);
	udelay(adap->udelay);
	sdalo(adap);
	scllo(adap);
}

static void i2c_stop(struct i2c_algo_bit_data *adap) 
{
	/* assert: scl is low */
	sdalo(adap);
	sclhi(adap); 
	sdahi(adap);
}

/* send a byte without start cond., look for arbitration, 
   check ackn. from slave */
/* returns:
 * 1 if the device acknowledged
 * 0 if the device did not ack
 * -ETIMEDOUT if an error occurred (while raising the scl line)
 */
static int i2c_outb(struct i2c_adapter *i2c_adap, char c)
{
	int i;
	int sb;
	int ack;
	struct i2c_algo_bit_data *adap = i2c_adap->algo_data;
	/* assert: scl is low */
	for( i=7 ; i>=0 ; i-- )
	{
		sb = c & ( 1 << i );
		setsda(adap,sb);
		udelay(adap->udelay);
		if(sclhi(adap)<0)
		{ /* timed out */
			sdahi(adap); /* we don't want to block the net */
#ifdef DEBUG
			DPRINT("i2c_outb ETIMEDOUT\r\n");	
#endif
			return -ETIMEDOUT;
		};
		/* do arbitration here: 
		 * if ( sb && ! getsda(adap) ) -> ouch! Get out of here.
		 */
		setscl(adap, 0 );
		udelay(adap->udelay);
	}
	sdahi(adap);
	if(sclhi(adap)<0)
	{
		/* timeout */
#ifdef DEBUG
		DPRINT("i2c_outb ETIMEDOUT\r\n");	
#endif
		return -ETIMEDOUT;
	}
	/* read ack: SDA should be pulled down by slave */
	ack = getsda(adap);	/* ack: sda is pulled low ->success.	 */
	scllo(adap);
#ifdef DEBUG
	DPRINTVALHEX("i2c_outb ",(unsigned long)(c & 0xff));
	DPRINTVAL(" ack ",(long)(0==ack));
	DPRINT("\r\n");	
#endif
	return 0==ack;		/* return 1 if device acked	 */
	/* assert: scl is low (sda undef) */
}

static int i2c_inb(struct i2c_adapter *i2c_adap) 
{
	/* read byte via i2c port, without start/stop sequence	*/
	/* acknowledge is sent in i2c_read.			*/
	int i;
	unsigned char indata=0;
	struct i2c_algo_bit_data *adap = i2c_adap->algo_data;
	/* assert: scl is low */
	sdahi(adap);
	for(i=0;i<8;i++)
	{
		if(sclhi(adap)<0)
		{
			/* timeout */
#ifdef DEBUG
			DPRINT("i2c_inb TIMEDOUT\r\n");
#endif
			return -ETIMEDOUT;
		}
		indata *= 2;
		if(getsda(adap)) 
			indata |= 0x01;
		scllo(adap);
	}
	/* assert: scl is low */
#ifdef DEBUG
	DPRINTVALHEX("i2c_inb ",(unsigned long)(indata & 0xff));
	DPRINT("\r\n");	
#endif	
	return (int) (indata & 0xff);
}

/*
 * Sanity check for the adapter hardware - check the reaction of
 * the bus lines only if it seems to be idle.
 */
static int test_bus(struct i2c_algo_bit_data *adap)
{
	int scl,sda;
	sda=getsda(adap);
	scl=(adap->getscl==NULL?1:getscl(adap));
	if(!scl || !sda )
		goto bailout;
	sdalo(adap);
	sda=getsda(adap);
	scl=(adap->getscl==NULL?1:getscl(adap));
	if(sda !=0 || scl == 0)
		goto bailout;
	sdahi(adap);
	sda=getsda(adap);
	scl=(adap->getscl==NULL?1:getscl(adap));
	if (sda == 0 || scl ==0)
		goto bailout;
	scllo(adap);
	sda=getsda(adap);
	scl=(adap->getscl==NULL?0:getscl(adap));
	if(scl !=0 || sda == 0)
		goto bailout;
	sclhi(adap);
	sda=getsda(adap);
	scl=(adap->getscl==NULL?1:getscl(adap));
	if(scl == 0 || sda ==0)
		goto bailout;
	return 0;
bailout:
	sdahi(adap);
	sclhi(adap);
	return -ENODEV;
}

/* ----- Utility functions
 */

/* try_address tries to contact a chip for a number of
 * times before it gives up.
 * return values:
 * 1 chip answered
 * 0 chip did not answer
 * -x transmission error
 */
static inline int try_address(struct i2c_adapter *i2c_adap,
		       unsigned char addr, int retries)
{
	struct i2c_algo_bit_data *adap = i2c_adap->algo_data;
	int i,ret = -1;
	for(i=0;i<=retries;i++)
	{
		ret = i2c_outb(i2c_adap,addr);
		if(ret==1)
			break;	/* success! */
		i2c_stop(adap);
		udelay(5);
		if(i==retries)  /* no success */
			break;
		i2c_start(adap);
		udelay(adap->udelay);
	}
	return ret;
}

static int sendbytes(struct i2c_adapter *i2c_adap, struct i2c_msg *msg)
{
	struct i2c_algo_bit_data *adap = i2c_adap->algo_data;
	char c;
	const char *temp = (const char *)msg->buf;
	int count = msg->len;
	unsigned short nak_ok = msg->flags & I2C_M_IGNORE_NAK; 
	int retval;
	int wrcount=0;
	while(count > 0)
	{
		c = *temp;
		retval = i2c_outb(i2c_adap,c);
		if((retval>0) || (nak_ok && (retval==0)))
		{ /* ok or ignored NAK */
			count--; 
			temp++;
			wrcount++;
		}
		else
		{ /* arbitration or no acknowledge */
			i2c_stop(adap);
			return (retval<0)? retval : -EFAULT;
			        /* got a better one ?? */
		}
	}
	return wrcount;
}

static inline int readbytes(struct i2c_adapter *i2c_adap, struct i2c_msg *msg)
{
	int inval;
	int rdcount=0;   	/* counts bytes read */
	struct i2c_algo_bit_data *adap = i2c_adap->algo_data;
	char *temp = (char *)msg->buf;
	int count = msg->len;
	while(count > 0)
	{
		inval = i2c_inb(i2c_adap);
		if(inval>=0)
		{
			*temp = inval;
			rdcount++;
		}
		else
		  /* read timed out */
			break;
		temp++;
		count--;
		if(msg->flags & I2C_M_NO_RD_ACK)
			continue;
		if( count > 0 )
			/* send ack */
			sdalo(adap);
		else
			sdahi(adap);	/* neg. ack on last byte */
		if(sclhi(adap)<0)
		{	/* timeout */
			sdahi(adap);
			return -ETIMEDOUT;
		};
		scllo(adap);
		sdahi(adap);
	}
	return rdcount;
}

/* doAddress initiates the transfer by generating the start condition (in
 * try_address) and transmits the address in the necessary format to handle
 * reads, writes as well as 10bit-addresses.
 * returns:
 *  0 everything went okay, the chip ack'ed, or IGNORE_NAK flag was set
 * -x an error occurred (like: -EREMOTEIO if the device did not answer, or
 *	-ETIMEDOUT, for example if the lines are stuck...) 
 */
static inline int bit_doAddress(struct i2c_adapter *i2c_adap, struct i2c_msg *msg) 
{
	unsigned short flags = msg->flags;
	unsigned short nak_ok = msg->flags & I2C_M_IGNORE_NAK;
	struct i2c_algo_bit_data *adap = i2c_adap->algo_data;
	unsigned char addr;
	int ret, retries;
	retries = nak_ok ? 0 : i2c_adap->retries;
	if(flags & I2C_M_TEN)
	{ 
		/* a ten bit address */
		addr = 0xf0 | (( msg->addr >> 7) & 0x03);
		/* try extended address code...*/
		ret = try_address(i2c_adap, addr, retries);
		if((ret != 1) && !nak_ok)
			return -EREMOTEIO;
		/* the remaining 8 bit address */
		ret = i2c_outb(i2c_adap,msg->addr & 0x7f);
		if((ret != 1) && !nak_ok)
			/* the chip did not ack / xmission error occurred */
			return -EREMOTEIO;
		if(flags & I2C_M_RD)
		{
			i2c_repstart(adap);
			/* okay, now switch into reading mode */
			addr |= 0x01;
			ret = try_address(i2c_adap, addr, retries);
			if ((ret!=1) && !nak_ok)
				return -EREMOTEIO;
		}
	}
	else
	{		/* normal 7bit address	*/
		addr = ( msg->addr << 1 );
		if(flags & I2C_M_RD )
			addr |= 1;
		if(flags & I2C_M_REV_DIR_ADDR )
			addr ^= 1;
		ret = try_address(i2c_adap, addr, retries);
		if((ret!=1) && !nak_ok)
			return -EREMOTEIO;
	}
	return 0;
}

static int bit_xfer(struct i2c_adapter *i2c_adap, struct i2c_msg msgs[], int num)
{
	struct i2c_msg *pmsg;
	struct i2c_algo_bit_data *adap = i2c_adap->algo_data;
	int i,ret;
	unsigned short nak_ok;
	i2c_start(adap);
	for(i=0;i<num;i++)
	{
		pmsg = &msgs[i];
		nak_ok = pmsg->flags & I2C_M_IGNORE_NAK; 
		if(!(pmsg->flags & I2C_M_NOSTART))
		{
			if(i)
				i2c_repstart(adap);
			ret = bit_doAddress(i2c_adap, pmsg);
			if((ret != 0) && !nak_ok)
				return (ret<0) ? ret : -EREMOTEIO;
		}
		if(pmsg->flags & I2C_M_RD )
		{
			/* read bytes into buffer*/
			ret = readbytes(i2c_adap, pmsg);
			if(ret < pmsg->len)
				return (ret<0)? ret : -EREMOTEIO;
		}
		else
		{
			/* write bytes from buffer */
			ret = sendbytes(i2c_adap, pmsg);
			if(ret < pmsg->len )
				return (ret<0) ? ret : -EREMOTEIO;
		}
	}
	i2c_stop(adap);
	return num;
}

/* -----exported algorithm data: -------------------------------------	*/

static struct i2c_algorithm i2c_bit_algo = {
	.master_xfer	= bit_xfer,
};

/* 
 * registering functions to load algorithms at runtime 
 */
int i2c_bit_add_bus(struct i2c_adapter *adap)
{
	struct i2c_algo_bit_data *bit_adap = adap->algo_data;
	if(1)
	{
		int ret = test_bus(bit_adap);
		if(ret<0)
			return -ENODEV;
	}
	/* register new adapter to i2c module... */
	adap->algo = &i2c_bit_algo;
	adap->timeout = 100;	/* default values, should	*/
	adap->retries = 3;	/* be replaced by defines	*/
	return 0;
}

int i2c_bit_del_bus(struct i2c_adapter *adap)
{
	return(0);
}

/* ----------------------------------------------------
 * the functional interface to the i2c busses.
 * ----------------------------------------------------
 */

int i2c_transfer(struct i2c_adapter * adap, struct i2c_msg *msgs, int num)
{
	int ret;
	if(adap->algo->master_xfer)
	{
		ret = adap->algo->master_xfer(adap,msgs,num);
		return ret;
	}
	else
		return -ENOSYS;
}

#endif /* CONFIG_FB_RADEON_I2C */
