/*
 * Brought to the Atari by Alan Hourihane <alanh@fairlite.co.uk>
 *
 * Hardware designed by Alan Hourihane <alanh@fairlite.co.uk>
 * 
 * The "Unicorn-USB" adapter driver !
 *
 * (C) Copyright 2004
 * Wolfgang Denk, DENX Software Engineering, wd@denx.de.
 *
 * This code is based on linux driver for sl811hs chip, source at
 * drivers/usb/host/sl811.c:
 *
 * SL811 Host Controller Interface driver for USB.
 *
 * Copyright (c) 2003/06, Courage Co., Ltd.
 *
 * Based on:
 *	1.uhci.c by Linus Torvalds, Johannes Erdfelt, Randy Dunlap,
 *	  Georg Acher, Deti Fliegl, Thomas Sailer, Roman Weissgaerber,
 *	  Adam Richter, Gregory P. Smith;
 *	2.Original SL811 driver (hc_sl811.o) by Pei Liu <pbl@cypress.com>
 *	3.Rewrited as sl811.o by Yin Aihua <yinah:couragetech.com.cn>
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#include "../../global.h"

#ifndef TOSONLY
#include "mint/mint.h"
#include "mint/mdelay.h"
#endif

#include "mint/endian.h"
#include "../../usb.h"
#include "mint/time.h"
#include "arch/timer.h"
#include "../../usb_api.h"

#define CONFIG_SYS_HZ CLOCKS_PER_SEC

#include "sl811.h"


unsigned long
get_hz_200(void)
{
	return *(volatile unsigned long *)0x04baL;
}

/****************************************************************************/
/* BEGIN kernel interface */

#ifndef TOSONLY
struct kentry	*kentry;
void sl811_hub_poll_thread(void *);
void sl811_hub_poll(PROC *proc, long dummy);
void sl811_hub_events(void);
#else
/* old handler */
extern void (*old_mfp_int)(void);

/* interrupt wrapper routine */
extern void interrupt_mfp (void);

extern unsigned long _PgmSize;

static int reset_stage = 0;
#endif
extern unsigned char check_flock(void);
struct usb_module_api   *api;

/* interrupt wrapper routine */
void unicorn_int (void);

/* END kernel interface */
/****************************************************************************/

long		submit_bulk_msg		(struct usb_device *, unsigned long , void *, long, long, unsigned long);
long		submit_control_msg	(struct usb_device *, unsigned long, void *,
					 unsigned short, struct devrequest *);
long		submit_int_msg		(struct usb_device *, unsigned long, void *, long, long);

static struct usb_port_status rh_status = { 0, 0 };
static struct usb_device *root_hub_dev = NULL;
static unsigned short root_address = 0;
static int intr = 0;
#ifdef TOSONLY
/* Global variables for tosdelay.c. Should be defined here to avoid
 * "multiple definition" errors from the linker with -fno-common.
 */
unsigned long loopcount_1_msec;
unsigned long delay_1usec;
#endif

static long sl811_rh_submit_urb(struct usb_device *usb_dev, unsigned long pipe,
			        void *data, unsigned short buf_len, struct devrequest *cmd);

/*
 * USB controller interface
 */

static long sl811_open		(struct ucdif *);
static long sl811_close		(struct ucdif *);
static long sl811_ioctl		(struct ucdif *, short, long);

static char lname[] = "Unicorn USB driver\0";

static struct ucdif sl811_uif = 
{
	0,			/* *next */
	USB_API_VERSION,	/* API */
	USB_CONTRLL,		/* class */
	lname,			/* lname */
	"sl811",		/* name */
	0,			/* unit */
	0,			/* flags */
	sl811_open,		/* open */
	sl811_close,		/* close */
	0,			/* resrvd1 */
	sl811_ioctl,		/* ioctl */
	0,			/* resrvd2 */
};


/*
 * FIXME... Need to read a config file....
 */
#define ACSI 1

/*
 * Macros for read/write access and interrupt handling.
 */
#define WRITEMODE (*(volatile unsigned short *)0xFFFF8606)
#define DACCESS (*(volatile unsigned short *)0xFFFF8604L)
#define MFP_GPIP (*(volatile unsigned char *)0xFFFFFA01L)
#define WRITEACC (*(volatile unsigned long *)0xFFFF8604L)

/*
 * Lock the ACSI port using FLOCK.
 */
#ifdef TOSONLY
#define LOCKUSB \
	unsigned long ret = 0; \
	if (!Super(1L)) { \
		ret = Super(0L); \
	} \
	while (check_flock() != 0);

#define UNLOCKUSB  \
	__asm__ volatile("clr.w 0x43e"); \
	if (ret) \
		SuperToUser(ret);
#else
#define LOCKUSB \
	{   \
		__asm__ volatile("1: tas.b 0x43e");        \
		__asm__ volatile("bne.b 1b");        \
	} 

#define UNLOCKUSB  \
	__asm__ volatile("clr.w 0x43e");
#endif
		

static inline void sl811_write (unsigned char index, unsigned char data)
{
	WRITEMODE = 0x88;
	WRITEACC = ((long)ACSI << 21) | 0x8a;
	DACCESS = index;
	DACCESS = data;
}

static inline unsigned char sl811_read (unsigned char index)
{
	register unsigned short data;

	WRITEMODE = 0x88;
	WRITEACC = ((long)ACSI << 21) | 0x8a;
	DACCESS = index;
	data = DACCESS;

	return (unsigned char)data;
}

/*
 * Read consecutive bytes of data from the SL811H/SL11H buffer
 */
static void inline sl811_read_buf(unsigned char offset, unsigned char *buf, unsigned char size)
{
	WRITEMODE = 0x88;
	WRITEACC = ((long)ACSI << 21) | 0x8a;

	if ((long)buf & 1) {
		/* Make it even, to prevent crashes on 68000. */
		DACCESS = offset++;
		*buf++ = (unsigned char) DACCESS;
		size--;
	}

	/* Speed optimization */
	while (size >= 16) {
		__asm__ volatile
		(
			"lea 0xffff8604,a1;"
			"move.l #0,d0;"
			"move.b %3,d0;"

			"move.w d0,(a1);"
			"move.w (a1),d4;"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.w (a1),d1;"
			"addq.l #1, d0;"
			"lsl.l #8, d4;"
			"move.b d1, d4;"
			"move.w d0,(a1);"
			"move.w (a1),d1;"
			"addq.l #1, d0;"
			"lsl.l #8, d4;"
			"move.b d1, d4;"
			"move.w d0,(a1);"
			"move.w (a1),d1;"
			"addq.l #1, d0;"
			"lsl.l #8, d4;"
			"move.b d1, d4;"

			"move.w d0,(a1);"
			"move.w (a1),d5;"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.w (a1),d1;"
			"addq.l #1, d0;"
			"lsl.l #8, d5;"
			"move.b d1, d5;"
			"move.w d0,(a1);"
			"move.w (a1),d1;"
			"addq.l #1, d0;"
			"lsl.l #8, d5;"
			"move.b d1, d5;"
			"move.w d0,(a1);"
			"move.w (a1),d1;"
			"addq.l #1, d0;"
			"lsl.l #8, d5;"
			"move.b d1, d5;"

			"move.w d0,(a1);"
			"move.w (a1),d6;"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.w (a1),d1;"
			"addq.l #1, d0;"
			"lsl.l #8, d6;"
			"move.b d1, d6;"
			"move.w d0,(a1);"
			"move.w (a1),d1;"
			"addq.l #1, d0;"
			"lsl.l #8, d6;"
			"move.b d1, d6;"
			"move.w d0,(a1);"
			"move.w (a1),d1;"
			"addq.l #1, d0;"
			"lsl.l #8, d6;"
			"move.b d1, d6;"

			"move.w d0,(a1);"
			"move.w (a1),d7;"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.w (a1),d1;"
			"addq.l #1, d0;"
			"lsl.l #8, d7;"
			"move.b d1, d7;"
			"move.w d0,(a1);"
			"move.w (a1),d1;"
			"addq.l #1, d0;"
			"lsl.l #8, d7;"
			"move.b d1, d7;"
			"move.w d0,(a1);"
			"move.w (a1),d1;"
			"addq.l #1, d0;"
			"lsl.l #8, d7;"
			"move.b d1, d7;"

			"move.l %2,a0;"
			"movem.l d4-d7,(a0);"
			"add.l #16,a0;"
			"move.b d0,%0;"
			"move.l a0,%1;"

			: "=d" (offset), "=m" (buf)
			: "m" (buf), "d" (offset)
			: "d0","d1","d4","d5","d6","d7","a0","a1"
		);
		
		size -= 16;
	}

	while (size--) {
		/* Auto-increment would have been nice, but it's 
		 * a hw bug of the SL811. So the workaround is baked
		 * into the ACSI adapter HW too.
		 *
		 * So you need to write address, then read or write data.
		 */
		DACCESS = offset++;
		*buf++ = (unsigned char) DACCESS;
	}
}

/*
 * Write consecutive bytes of data to the SL811H/SL11H buffer
 */
static void inline sl811_write_buf(unsigned char offset, unsigned char *buf, unsigned char size)
{
	WRITEMODE = 0x88;
	WRITEACC = ((long)ACSI << 21) | 0x8a;

	if ((long)buf & 1) {
		/* Make it even, to prevent crashes on 68000. */
		DACCESS = offset++;
		DACCESS = *buf++;
		size--;
	}

	while (size >= 16) {
		__asm__ volatile
		(
			"lea 0xffff8604,a1;"
			"move.l #0,d0;"
			"move.b %3,d0;"

			"move.l %2,a0;"
			"movem.l (a0),d4-d7;"
			"add.l #16,a0;"
			"move.l a0,%1;"

			"move.w d0,(a1);"
			"move.l d4,d1;"
			"swap d1;"
			"lsr.l #8, d1;"
			"move.w d1,(a1);"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.l d4,d1;"
			"swap d1;"
			"move.w d1,(a1);"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.l d4,d1;"
			"lsr.l #8, d1;"
			"move.w d1,(a1);"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.w d4,(a1);"
			"addq.l #1, d0;"

			"move.w d0,(a1);"
			"move.l d5,d1;"
			"swap d1;"
			"lsr.l #8, d1;"
			"move.w d1,(a1);"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.l d5,d1;"
			"swap d1;"
			"move.w d1,(a1);"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.l d5,d1;"
			"lsr.l #8, d1;"
			"move.w d1,(a1);"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.w d5,(a1);"
			"addq.l #1, d0;"

			"move.w d0,(a1);"
			"move.l d6,d1;"
			"swap d1;"
			"lsr.l #8, d1;"
			"move.w d1,(a1);"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.l d6,d1;"
			"swap d1;"
			"move.w d1,(a1);"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.l d6,d1;"
			"lsr.l #8, d1;"
			"move.w d1,(a1);"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.w d6,(a1);"
			"addq.l #1, d0;"

			"move.w d0,(a1);"
			"move.l d7,d1;"
			"swap d1;"
			"lsr.l #8, d1;"
			"move.w d1,(a1);"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.l d7,d1;"
			"swap d1;"
			"move.w d1,(a1);"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.l d7,d1;"
			"lsr.l #8, d1;"
			"move.w d1,(a1);"
			"addq.l #1, d0;"
			"move.w d0,(a1);"
			"move.w d7,(a1);"
			"addq.l #1, d0;"

			"move.b d0,%0;"

			: "=d" (offset), "=m" (buf)
			: "m" (buf), "d" (offset)
			: "d0","d1","d4","d5","d6","d7","a0","a1"
		);
		
		size -= 16;
	}

	while (size--) {
		/* Auto-increment would have been nice, but it's 
		 * a hw bug of the SL811. So the workaround is baked
		 * into the ACSI adapter HW too.
		 *
		 * So you need to write address, then read or write data.
		 */
		DACCESS = offset++;
		DACCESS = *buf++;
	}
}

static int usb_init_atari (void)
{
	unsigned char buf[SL811_DATA_LIMIT];
	int i;

	for (i = 0; i < SL811_DATA_LIMIT; i++) {
		buf[i] = i;
	}
	LOCKUSB;
	sl811_write_buf(SL811_DATA_START, buf, SL811_DATA_LIMIT);
	memset(buf, 0, SL811_DATA_LIMIT);
	sl811_read_buf(SL811_DATA_START, buf, SL811_DATA_LIMIT);
	UNLOCKUSB;
	for (i = 0; i < SL811_DATA_LIMIT; i++) {
		if (buf[i] != i) {
			DEBUG(("SL811 compare error index=0x%02x read=0x%02x 0x%02x 0x%02x 0x%02x\n", i, buf[i], buf[i+1], buf[i+2], buf[i+3]));
			return (-1);
		}
	}
	DEBUG(("SL811 ready\n"));
	return (0);
}

static void sl811_write_intr(unsigned char irq)
{
	sl811_write(SL811_INTR, irq);
}

static long sl811_hc_reset(void)
{
	unsigned char status;

	sl811_write(SL811_CTRL2, SL811_CTL2_HOST | SL811_12M_HI);
	sl811_write(SL811_CTRL1, SL811_CTRL1_RESET);

	mdelay(50);

	/* Disable hardware SOF generation, clear all irq status. */
	sl811_write(SL811_CTRL1, 0);
	mdelay(2);
	sl811_write(SL811_INTRSTS, 0xff);
	status = sl811_read(SL811_INTRSTS);

	if (status & SL811_INTR_NOTPRESENT) {
		/* Device is not present */
		DEBUG(("Device not present"));
		rh_status.wPortStatus &= ~(USB_PORT_STAT_CONNECTION | USB_PORT_STAT_ENABLE);
		rh_status.wPortChange |= USB_PORT_STAT_C_CONNECTION;
		intr = SL811_INTR_INSRMV;
		sl811_write_intr(intr);
	
		return 0;
	}

	/* Send SOF to address 0, endpoint 0. */
	sl811_write(SL811_LEN_B, 0);
	sl811_write(SL811_PIDEP_B, PIDEP(USB_PID_SOF, 0));
	sl811_write(SL811_DEV_B, 0x00);
	sl811_write(SL811_SOFLOW, SL811_12M_LOW);

	sl811_write(SL811_CTRL1, SL811_CTRL1_RESET);
	mdelay(50);

	if (status & SL811_INTR_SPEED_FULL) {
		/* full speed device connect directly to root hub */
		DEBUG(("Full speed Device attached"));

		sl811_write(SL811_CTRL2, SL811_CTL2_HOST | SL811_12M_HI);
		sl811_write(SL811_CTRL1, SL811_CTRL1_SOF);

		rh_status.wPortStatus |= USB_PORT_STAT_CONNECTION;
		rh_status.wPortStatus &= ~USB_PORT_STAT_LOW_SPEED;
	} else {
		/* slow speed device connect directly to root-hub */
		DEBUG(("Low speed Device attached"));

		sl811_write(SL811_CTRL2, SL811_CTL2_HOST | SL811_CTL2_DSWAP | SL811_12M_HI);
		sl811_write(SL811_CTRL1, SL811_CTRL1_SPEED_LOW | SL811_CTRL1_SOF);

		rh_status.wPortStatus |= USB_PORT_STAT_CONNECTION | USB_PORT_STAT_LOW_SPEED;
	}

	/* start the SOF or EOP */
	sl811_write(SL811_CTRL_B, SL811_USB_CTRL_ARM);
	mdelay(2);
	sl811_write(SL811_INTRSTS, 0xff);

	rh_status.wPortChange |= USB_PORT_STAT_C_CONNECTION;
	intr = SL811_INTR_DETECT | SL811_INTR_INSRMV;
	sl811_write_intr(intr);

	return 1;
}

static inline void
int_handle_tophalf(PROC *process, long arg)
{
	usb_rh_wakeup(&sl811_uif);
}

long
usb_lowlevel_init(void *dummy)
{
	long r;

	/*
	 * Check the adapter is functional.
	 */
	if (usb_init_atari() != 0) {
		c_conws("Unicorn USB not found\r\n");
		return -1;
	}

	/*
	 * Initialize the chip.
	 */
	LOCKUSB;
	r = sl811_hc_reset();
	UNLOCKUSB;
	if (r)
		usb_rh_wakeup(&sl811_uif);
	else
		rh_status.wPortChange = 0;

#ifdef TOSONLY
	//old_mfp_int = Setexc (0x70/4, (long) interrupt_mfp);
	{
		ret = Super(0L);
		old_mfp_int = (void*)*(volatile unsigned long *)0x400;
		*(volatile unsigned long *)0x400 = (unsigned long)interrupt_mfp;
		SuperToUser(ret);
	}
#else
	/*
	 * Start the root hub thread.
	 */
	r = kthread_create(NULL, sl811_hub_poll_thread, NULL, NULL, "unicorn");
	if (r)
	{
		return -1;
	}
#endif

	return 0;
}

long 
usb_lowlevel_stop(void *dummy)
{
	DEBUG(("USB SL811 DISABLED DUE TO LOWLEVEL STOP!"));
	
	LOCKUSB;
	sl811_write_intr(0);
	sl811_write(SL811_INTRSTS, 0xff);
	UNLOCKUSB;

	return 0;
}

static int calc_needed_buswidth(long bytes, long need_preamble)
{
	/*
	 * This is the performance optimizer.
	 *
	 * Basically the USB frame can contain a number of bits.
	 *
	 * Unfortunately, our poor ST's are only 8MHz 68000's and are
	 * slow in terms of USB rates. This means we need a larger slop
	 * for potentially missing the end of the frame, and resulting
	 * in device timeouts. Hence 5120 for full speed USB devices.
	 * Low speed use the alternate algorithm
	 *
	 * Reducing 5120 helps performance as we can slot more of our
	 * packets inside a USB frame, but it can result in timeouts if
	 * too low and the USB device could be shutdown.
	 */
	return !need_preamble ? bytes * 8 + 5120 : bytes * 64 + 3072;
}

static long sl811_send_packet(struct usb_device *dev, unsigned long pipe, unsigned char *buffer, long len, long flags)
{
	register unsigned char ctrl = SL811_USB_CTRL_ARM | SL811_USB_CTRL_ENABLE;
	register unsigned char status = 0;
	long err = 0;
	long nak = 0;
	long need_preamble = !(rh_status.wPortStatus & USB_PORT_STAT_LOW_SPEED) &&
		(dev->speed == USB_SPEED_LOW);
	int calc = calc_needed_buswidth(len, need_preamble);

	if (len > SL811_DATA_LIMIT) {
		ALERT(("Packet too large (%ldbytes)",len));
		return -1;
	}

	if (usb_pipeout(pipe))
		ctrl |= SL811_USB_CTRL_DIR_OUT;
	if (usb_gettoggle(dev, usb_pipeendpoint(pipe), usb_pipeout(pipe)))
		ctrl |= SL811_USB_CTRL_TOGGLE_1;
	if (need_preamble)
		ctrl |= SL811_USB_CTRL_PREAMBLE;

	sl811_write(SL811_INTRSTS, SL811_INTR_DONE_A);
	sl811_write_intr(SL811_INTR_DONE_A);
	while (err < 3) {
		register unsigned long time_start = get_hz_200();
		register unsigned char intrq;
		register int sofcnt;

		sl811_write(SL811_ADDR_A, SL811_DATA_START);
		sl811_write(SL811_LEN_A, len);
		if (usb_pipeout(pipe) && len && !nak)
			sl811_write_buf(SL811_DATA_START, buffer, len);

		sofcnt = sl811_read(SL811_SOFCNTDIV)*64;
		if (!(rh_status.wPortStatus & USB_PORT_STAT_LOW_SPEED) &&
			sofcnt < calc)
			ctrl |= SL811_USB_CTRL_SOF;
		else
			ctrl &= ~SL811_USB_CTRL_SOF;

		sl811_write(SL811_CTRL_A, ctrl);
		while (!((intrq = sl811_read(SL811_INTRSTS)) & SL811_INTR_DONE_A))
		{
			if (5*CONFIG_SYS_HZ < (get_hz_200() - time_start)) {
				DEBUG(("USB transmit timed out %d",sl811_read(SL811_INTR)));
				if (intrq & (SL811_INTR_INSRMV | SL811_INTR_DETECT)) {
#ifndef TOSONLY
					sl811_hc_reset();
					addroottimeout (0, int_handle_tophalf, 1);
#else
					reset_stage = 1;
#endif
				} else {
					sl811_write_intr(intr);
					sl811_write(SL811_INTRSTS, SL811_INTR_DONE_A);
				}
				return -USB_ST_CRC_ERR;
			}
		}

		sl811_write(SL811_INTRSTS, SL811_INTR_DONE_A);
		status = sl811_read(SL811_STS_A);

		if (status & SL811_USB_STS_ACK) {
			unsigned char remainder = sl811_read(SL811_CNT_A);
			if (remainder) {
		//		DEBUG(("usb transfer remainder = %d", remainder));
				len -= remainder;
			}
			if (usb_pipein(pipe) && len) {
				sl811_read_buf(SL811_DATA_START, buffer, len);
			}
			sl811_write_intr(intr);
			sl811_write(SL811_INTRSTS, SL811_INTR_DONE_A);
			return len;
		}

		if ((status & SL811_USB_STS_NAK) == SL811_USB_STS_NAK) {
			DEBUG(("NAK!"));
			nak++;
			if (flags & USB_BULK_FLAG_EARLY_TIMEOUT) {
				err++;
			}

			continue;
		}

		err++;
	}

	err = 0;

#if 0
	if (status) {
		c_conws("ERROR\n\r");
		hex_long(len);
		hex_long(status);
		c_conws("\r\n");
	}
#endif

	if (status & SL811_USB_STS_NAK)
		err |= USB_ST_NAK_REC;
	if (status & SL811_USB_STS_ERROR)
		err |= USB_ST_BUF_ERR;
	if (status & SL811_USB_STS_TIMEOUT)
		err |= USB_ST_CRC_ERR;
	if (status & SL811_USB_STS_STALL)
		err |= USB_ST_STALLED;

	DEBUG(("usb transfer error 0x%x", (int)status));

	sl811_write_intr(intr);
	sl811_write(SL811_INTRSTS, SL811_INTR_DONE_A);

	return -err;
}

long
submit_bulk_msg(struct usb_device *dev, unsigned long pipe, void *buffer,
		long len, long flags, unsigned long timeout)
{
	int devnum = usb_pipedevice(pipe);
	int dir_out = usb_pipeout(pipe);
	int ep = usb_pipeendpoint(pipe);

	long max = usb_maxpacket(dev, pipe);
	long done = 0;

	DEBUG(("dev = %ld pipe = %ld buf = 0x%lx size = 0x%lx dir_out = %d",
	       usb_pipedevice(pipe), usb_pipeendpoint(pipe), (unsigned long)buffer, len, dir_out));

	dev->status = -1;
	dev->act_len = 0;

	if (dev->devnum == -1) {
		c_conws("BAD DEVNUM, POSSIBLE DEVICE REMOVAL!\n\rn");
		return -1;
	}

	LOCKUSB;

#ifdef TOSONLY
	if (reset_stage == 1) {
		sl811_hc_reset();
		reset_stage = 0;
	}
#endif

//	max = SL811_DATA_LIMIT;
	sl811_write(SL811_DEV_A, devnum);
	sl811_write(SL811_PIDEP_A, PIDEP(!dir_out ? USB_PID_IN : USB_PID_OUT, ep));
	usb_settoggle(dev, ep, !dir_out, 1);
	while (done < len) {
		long res;
		long nlen = (max > (len - done)) ? (len - done) : max;

		res = sl811_send_packet(dev, pipe, (unsigned char*)buffer+done, nlen, flags);
		if (res < 0) {
			UNLOCKUSB;
			dev->act_len = done;
			dev->status = -res;
			return res;
		}
		done += res;
		usb_dotoggle(dev, ep, dir_out);

		if (!dir_out && res < nlen) /* short packet */
			break;
	}

	dev->act_len = done;
	dev->status = 0;

	UNLOCKUSB;

	return done;
}

long
submit_control_msg(struct usb_device *dev, unsigned long pipe, void *buffer,
		       unsigned short len, struct devrequest *setup)
{
	long done = 0;
	int devnum = usb_pipedevice(pipe);
	int ep = usb_pipeendpoint(pipe);
	long max = usb_maxpacket(dev, pipe);

	dev->status = -1;
	dev->act_len = 0;

	if (dev->devnum == -1) {
		c_conws("BAD DEVNUM, POSSIBLE DEVICE REMOVAL!\n\rn");
		return -1;
	}

	DEBUG(("dev = 0x%x pipe = %d buf = 0x%lx size = 0x%x rt = 0x%x req = 0x%x bus = %i",
	       devnum, ep, (unsigned long)buffer, len, setup->requesttype,
	       setup->request, sl811_read(SL811_SOFCNTDIV)*64));

	LOCKUSB;

	if (devnum == root_address) {
		long rret;
#ifdef TOSONLY
		if (reset_stage == 1) {
			sl811_hc_reset();
		}
		reset_stage = 0;
#endif
		rret = sl811_rh_submit_urb(dev, pipe, buffer, len, setup);
		UNLOCKUSB;
		return rret;
	}

#ifdef TOSONLY
	if (reset_stage == 1) {
		sl811_hc_reset();
		reset_stage = 0;

	}
#endif

	sl811_write(SL811_DEV_A, devnum);
	sl811_write(SL811_PIDEP_A, PIDEP(USB_PID_SETUP, ep));

	/* setup phase */
	usb_settoggle(dev, ep, 1, 0);
	if (sl811_send_packet(dev, usb_sndctrlpipe(dev, ep),
			      (unsigned char*)setup, sizeof(*setup), 0) == sizeof(*setup)) {
		int dir_in = usb_pipein(pipe);

		/* data phase */
		sl811_write(SL811_PIDEP_A,
			    PIDEP(dir_in ? USB_PID_IN : USB_PID_OUT, ep));
		usb_settoggle(dev, ep, usb_pipeout(pipe), 1);
	
//		max = SL811_DATA_LIMIT;

		dev->status = 0;

		while (done < len) {
			long res;
			long nlen = (max > (len - done)) ? (len - done) : max;
			res = sl811_send_packet(dev, pipe, (unsigned char*)buffer+done, nlen, 0);
			if (res < 0) {
				ALERT(("1status data failed!"));
				dev->status = -res;
				UNLOCKUSB;
				dev->act_len = done;
				return 0;
			}
			done += res;
			usb_dotoggle(dev, ep, usb_pipeout(pipe));

			if (dir_in && res < max) /* short packet */
				break;
		}

		/* status phase */
		sl811_write(SL811_PIDEP_A,
			    PIDEP(!dir_in ? USB_PID_IN : USB_PID_OUT, ep));
		usb_settoggle(dev, ep, !usb_pipeout(pipe), 1);
		if (sl811_send_packet(dev,
				      !dir_in ? usb_rcvctrlpipe(dev, ep) :
				      usb_sndctrlpipe(dev, ep),
				      0, 0, 0) < 0) {
			ALERT(("2status phase failed!"));
			dev->status = -1;
			done = 0;
		}
	} else {
		ALERT(("3setup phase failed!"));
		dev->status = -1;
		done = 0;
	}

	dev->act_len = done;

	UNLOCKUSB;

	return done;
}

long
submit_int_msg(struct usb_device *dev, unsigned long pipe, void *buffer,
		   long len, long interval)
{
	int devnum = usb_pipedevice(pipe);
	int dir_out = usb_pipeout(pipe);
	int ep = usb_pipeendpoint(pipe);
	long max = usb_maxpacket(dev, pipe);
	long done = 0;

	DEBUG(("dev = 0x%lx pipe = %#lx buf = 0x%lx size = %ld int = %ld", (unsigned long)dev, pipe,
	       (unsigned long)buffer, len, interval));

	LOCKUSB;
	sl811_write(SL811_DEV_A, devnum);
	sl811_write(SL811_PIDEP_A, PIDEP(!dir_out ? USB_PID_IN : USB_PID_OUT, ep));
	usb_settoggle(dev, ep, !dir_out, 1);
	while (done < len) {
		long res;
		long nlen = (max > (len - done)) ? (len - done) : max;

		res = sl811_send_packet(dev, pipe, (unsigned char*)buffer+done, nlen, 0);
		if (res < 0) {
			UNLOCKUSB;

			dev->act_len = done;
			dev->status = -res;
			return res;
		}
		done += res;
		usb_dotoggle(dev, ep, dir_out);

		if (!dir_out && res < nlen) /* short packet */
			break;
	}

	dev->act_len = done;

	dev->irq_handle(dev);

	UNLOCKUSB;

	return done;
}

/*
 * SL811 Virtual Root Hub
 */

/* Device descriptor */
static unsigned char sl811_rh_dev_des[] =
{
	0x12,		/*	__u8  bLength; */
	0x01,		/*	__u8  bDescriptorType; Device */
	0x10,		/*	__u16 bcdUSB; v1.1 */
	0x01,
	0x09,		/*	__u8  bDeviceClass; HUB_CLASSCODE */
	0x00,		/*	__u8  bDeviceSubClass; */
	0x00,		/*	__u8  bDeviceProtocol; */
	0x08,		/*	__u8  bMaxPacketSize0; 8 Bytes */
	0x00,		/*	__u16 idVendor; */
	0x00,
	0x00,		/*	__u16 idProduct; */
	0x00,
	0x00,		/*	__u16 bcdDevice; */
	0x00,
	0x00,		/*	__u8  iManufacturer; */
	0x02,		/*	__u8  iProduct; */
	0x01,		/*	__u8  iSerialNumber; */
	0x01		/*	__u8  bNumConfigurations; */
};

/* Configuration descriptor */
static unsigned char sl811_rh_config_des[] =
{
	0x09,		/*	__u8  bLength; */
	0x02,		/*	__u8  bDescriptorType; Configuration */
	0x19,		/*	__u16 wTotalLength; */
	0x00,
	0x01,		/*	__u8  bNumInterfaces; */
	0x01,		/*	__u8  bConfigurationValue; */
	0x00,		/*	__u8  iConfiguration; */
	0x40,		/*	__u8  bmAttributes;
			Bit 7: Bus-powered, 6: Self-powered, 5 Remote-wakwup,
			4..0: resvd */
	0x00,		/*	__u8  MaxPower; */

	/* interface */
	0x09,		/*	__u8  if_bLength; */
	0x04,		/*	__u8  if_bDescriptorType; Interface */
	0x00,		/*	__u8  if_bInterfaceNumber; */
	0x00,		/*	__u8  if_bAlternateSetting; */
	0x01,		/*	__u8  if_bNumEndpoints; */
	0x09,		/*	__u8  if_bInterfaceClass; HUB_CLASSCODE */
	0x00,		/*	__u8  if_bInterfaceSubClass; */
	0x00,		/*	__u8  if_bInterfaceProtocol; */
	0x00,		/*	__u8  if_iInterface; */

	/* endpoint */
	0x07,		/*	__u8  ep_bLength; */
	0x05,		/*	__u8  ep_bDescriptorType; Endpoint */
	0x81,		/*	__u8  ep_bEndpointAddress; IN Endpoint 1 */
	0x03,		/*	__u8  ep_bmAttributes; Interrupt */
	0x08,		/*	__u16 ep_wMaxPacketSize; */
	0x00,
	0xff		/*	__u8  ep_bInterval; 255 ms */
};

/* root hub class descriptor*/
static unsigned char sl811_rh_hub_des[] =
{
	0x09,			/*  __u8  bLength; */
	0x29,			/*  __u8  bDescriptorType; Hub-descriptor */
	0x01,			/*  __u8  bNbrPorts; */
	0x00,			/* __u16  wHubCharacteristics; */
	0x00,
	0x50,			/*  __u8  bPwrOn2pwrGood; 2ms */
	0x00,			/*  __u8  bHubContrCurrent; 0 mA */
	0xfc,			/*  __u8  DeviceRemovable; *** 7 Ports max *** */
	0xff			/*  __u8  PortPwrCtrlMask; *** 7 ports max *** */
};

/*
 * helper routine for returning string descriptors in UTF-16LE
 * input can actually be ISO-8859-1; ASCII is its 7-bit subset
 */
static int ascii2utf (char *s, unsigned char *utf, int utfmax)
{
	int retval;

	for (retval = 0; *s && utfmax > 1; utfmax -= 2, retval += 2) {
		*utf++ = *s++;
		*utf++ = 0;
	}
	return retval;
}

/*
 * root_hub_string is used by each host controller's root hub code,
 * so that they're identified consistently throughout the system.
 */
static int usb_root_hub_string (int id, unsigned char *data, long len)
{
	char buf [30];

	/* assert (len > (2 * (sizeof (buf) + 1)));
	   assert (strlen (type) <= 8);*/

	memset(buf, 0, sizeof(buf));
	/* language ids */
	if (id == 0) {
		*data++ = 4; *data++ = 3;	/* 4 bytes data */
		*data++ = 0; *data++ = 0;	/* some language id */
		return 4;

	/* serial number */
	} else if (id == 1) {
		strcat (buf, "0");

	/* product description */
	} else if (id == 2) {
		strcat (buf, "Unicorn USB Root Hub");

	/* id 3 == vendor description */

	/* unsupported IDs --> "stall" */
	} else
		return 0;

	ascii2utf (buf, data + 2, len - 2);
	data [0] = 2 + strlen(buf) * 2;
	data [1] = 3;
	return data [0];
}

/* helper macro */
#define OK(x)	len = (x); break

/*
 * This function handles all USB request to the the virtual root hub
 */
static inline long sl811_rh_submit_urb(struct usb_device *usb_dev, unsigned long pipe,
	 		        void *data, unsigned short buf_len, struct devrequest *cmd)
{
	unsigned char data_buf[16];
	unsigned char *bufp = data_buf;
	unsigned short len = 0;
	long status = 0;
	__u16 bmRType_bReq;
	__u16 wValue  = le2cpu16(cmd->value);
	__u16 wLength = le2cpu16(cmd->length);
#ifdef DEV_DEBUG
	__u16 wIndex  = le2cpu16(cmd->index);
#endif

	if (usb_pipeint(pipe)) {
		DEBUG(("interrupt transfer unimplemented!"));
		return 0;
	}

	bmRType_bReq  = cmd->requesttype | (cmd->request << 8);

	DEBUG(("submit rh urb, req = %d(%x) val = 0x%x index = 0x%x len=0x%x",
	       bmRType_bReq, bmRType_bReq, wValue, wIndex, wLength));

	/* Request Destination:
		   without flags: Device,
		   USB_RECIP_INTERFACE: interface,
		   USB_RECIP_ENDPOINT: endpoint,
		   USB_TYPE_CLASS means HUB here,
		   USB_RECIP_OTHER | USB_TYPE_CLASS  almost ever means HUB_PORT here
	*/
	switch (bmRType_bReq) {
	case RH_GET_STATUS:
		*(__u16 *)bufp = cpu2le16(1);
		OK(2);

	case RH_GET_STATUS | USB_RECIP_INTERFACE:
		*(__u16 *)bufp = cpu2le16(0);
		OK(2);

	case RH_GET_STATUS | USB_RECIP_ENDPOINT:
		*(__u16 *)bufp = cpu2le16(0);
		OK(2);

	case RH_GET_STATUS | USB_TYPE_CLASS:
		*(__u32 *)bufp = cpu2le32(0);
		OK(4);

	case RH_GET_STATUS | USB_RECIP_OTHER | USB_TYPE_CLASS:
		{
		long tmp;
		tmp = (long)rh_status.wPortChange<<16 | rh_status.wPortStatus;
		*(__u32 *)bufp = cpu2le32(tmp);
		OK(4);
		}

	case RH_CLEAR_FEATURE | USB_RECIP_ENDPOINT:
		switch (wValue) {
		case 1:
			OK(0);
		}
		break;

	case RH_CLEAR_FEATURE | USB_TYPE_CLASS:
		switch (wValue) {
		case C_HUB_LOCAL_POWER:
			OK(0);

		case C_HUB_OVER_CURRENT:
			OK(0);
		}
		break;

	case RH_CLEAR_FEATURE | USB_RECIP_OTHER | USB_TYPE_CLASS:
		switch (wValue) {
		case USB_PORT_FEAT_ENABLE:
			rh_status.wPortStatus &= ~USB_PORT_STAT_ENABLE;
			OK(0);

		case USB_PORT_FEAT_SUSPEND:
			rh_status.wPortStatus &= ~USB_PORT_STAT_SUSPEND;
			OK(0);

		case USB_PORT_FEAT_POWER:
			rh_status.wPortStatus &= ~USB_PORT_STAT_POWER;
			OK(0);

		case USB_PORT_FEAT_C_CONNECTION:
			rh_status.wPortChange &= ~USB_PORT_STAT_C_CONNECTION;
			OK(0);

		case USB_PORT_FEAT_C_ENABLE:
			rh_status.wPortChange &= ~USB_PORT_STAT_C_ENABLE;
			OK(0);

		case USB_PORT_FEAT_C_SUSPEND:
			rh_status.wPortChange &= ~USB_PORT_STAT_C_SUSPEND;
			OK(0);

		case USB_PORT_FEAT_C_OVER_CURRENT:
			rh_status.wPortChange &= ~USB_PORT_STAT_C_OVERCURRENT;
			OK(0);

		case USB_PORT_FEAT_C_RESET:
			rh_status.wPortChange &= ~USB_PORT_STAT_C_RESET;
			OK(0);
		}
		break;

	case RH_SET_FEATURE | USB_RECIP_OTHER | USB_TYPE_CLASS:
		switch (wValue) {
		case USB_PORT_FEAT_SUSPEND:
			rh_status.wPortStatus |= USB_PORT_STAT_SUSPEND;
			OK(0);

		case USB_PORT_FEAT_RESET:
			rh_status.wPortStatus |= USB_PORT_STAT_RESET;
			rh_status.wPortChange = 0;
			rh_status.wPortChange |= USB_PORT_STAT_C_RESET;
			rh_status.wPortStatus &= ~USB_PORT_STAT_RESET;
			rh_status.wPortStatus |= USB_PORT_STAT_ENABLE;
			OK(0);

		case USB_PORT_FEAT_POWER:
			rh_status.wPortStatus |= USB_PORT_STAT_POWER;
			OK(0);

		case USB_PORT_FEAT_ENABLE:
			rh_status.wPortStatus |= USB_PORT_STAT_ENABLE;
			OK(0);
		}
		break;

	case RH_SET_ADDRESS:
		root_address = wValue;
		OK(0);

	case RH_GET_DESCRIPTOR:
		switch ((wValue & 0xff00) >> 8) {
		case USB_DT_DEVICE:
			len = sizeof(sl811_rh_dev_des);
			bufp = sl811_rh_dev_des;
			OK(len);

		case USB_DT_CONFIG:
			len = sizeof(sl811_rh_config_des);
			bufp = sl811_rh_config_des;
			OK(len);

		case USB_DT_STRING:
			len = usb_root_hub_string(wValue & 0xff, data, wLength);
			if (len > 0) {
				bufp = data;
				OK(len);
			}

		default:
			status = -32;
		}
		break;

	case RH_GET_DESCRIPTOR | USB_TYPE_CLASS:
		len = sizeof(sl811_rh_hub_des);
		bufp = sl811_rh_hub_des;
		OK(len);

	case RH_GET_CONFIGURATION:
		bufp[0] = 0x01;
		OK(1);

	case RH_SET_CONFIGURATION:
		OK(0);

	default:
		DEBUG(("unsupported root hub command"));
		status = -32;
	}

	len = MIN(len, buf_len);
	if (data != bufp)
		memcpy(data, bufp, len);

	DEBUG(("len = %d, status = %ld", len, status));

	usb_dev->status = status;
	usb_dev->act_len = (long)len;

	return status == 0 ? usb_dev->act_len : usb_dev->status;
}

#ifdef TOSONLY
#define MSG_VERSION	"TOS"
#else
#define MSG_VERSION	"FreeMiNT"
#endif
#define MSG_BUILDDATE	__DATE__

#define MSG_BOOT	\
	"\033p Unicorn USB controller driver (" MSG_VERSION ") \033q\r\n"

#define MSG_GREET	\
	"Ported, mixed and shaken by Alan Hourihane.\r\n" \
	"Compiled " MSG_BUILDDATE ".\r\n\r\n"

/* --- Inteface functions -------------------------------------------------- */

static long
sl811_open (struct ucdif *u)
{
	DEBUG(("sl811 open"));
	return E_OK;
}

static long
sl811_close (struct ucdif *u)
{
	return E_OK;
}

static long
sl811_ioctl (struct ucdif *u, short cmd, long arg)
{
	long ret = E_OK;

	switch (cmd)
	{
		case LOWLEVEL_INIT :
		{
			ret = usb_lowlevel_init (u->ucd_priv);
			break;
		}
		case LOWLEVEL_STOP :
		{
			ret = usb_lowlevel_stop (u->ucd_priv);
			break;
		}
		case SUBMIT_CONTROL_MSG :
		{
			struct control_msg *ctrl_msg = (struct control_msg *)arg;
			ret = submit_control_msg (ctrl_msg->dev, ctrl_msg->pipe,
			 		    ctrl_msg->data, ctrl_msg->size, ctrl_msg->setup);	
			break;
		}
		case SUBMIT_BULK_MSG :
		{
			struct bulk_msg *bulk_msg = (struct bulk_msg *)arg;

			ret = submit_bulk_msg (bulk_msg->dev, bulk_msg->pipe,
				         bulk_msg->data, bulk_msg->len, 
					 bulk_msg->flags, bulk_msg->timeout);

			break;
		}
		case SUBMIT_INT_MSG :
		{
			struct int_msg *int_msg = (struct int_msg *)arg;

			ret = submit_int_msg(int_msg->dev, int_msg->pipe,
				       int_msg->buffer, int_msg->transfer_len, 
				       int_msg->interval);

			break;
		}
		default:
		{
			return ENOSYS;
		}
	}	
	return ret;
}

#ifdef TOSONLY
int init(int argc, char **argv, char **env);

int
init(int argc, char **argv, char **env)
#else
long init (struct kentry *, struct usb_module_api *, char **);

long
init (struct kentry *k, struct usb_module_api *uapi, char **reason)
#endif
{
	long ret;

#ifndef TOSONLY
	api	= uapi;
	kentry	= k;

	if (check_kentry_version())
		return -1;
#endif

	c_conws (MSG_BOOT);
	c_conws (MSG_GREET);
	DEBUG (("%s: enter init", __FILE__));

#ifdef TOSONLY
	/* Get USB cookie */
	if (!getcookie(_USB, (long *)&api)) {
		(void)Cconws("UNICORN failed to get _USB cookie\r\n");
		return -1;
	}
#endif

	ret = ucd_register(&sl811_uif, &root_hub_dev);
	if (ret)
	{
		DEBUG (("%s: ucd register failed!", __FILE__));
		return 1;
	}

	DEBUG (("%s: ucd register ok", __FILE__));

#ifdef TOSONLY
	c_conws("Unicorn USB driver installed.\r\n");

	Ptermres(_PgmSize,0);
#endif

	return 0;
}

void
unicorn_int (void)
{
#ifdef TOSONLY
	if (reset_stage != 0)
		return;
#endif

	if ((MFP_GPIP & 0x30) == 0x20) {
		unsigned char status;

		if (check_flock() != 0) { 
			return; 
		} 

		status = sl811_read(SL811_INTRSTS);
		sl811_write(SL811_INTRSTS, 0xfe);

		if (status & (SL811_INTR_INSRMV | SL811_INTR_DETECT)) {
#ifdef TOSONLY
			reset_stage = 1;
#else
			sl811_hc_reset();
#endif
			__asm__ volatile("clr.w 0x43e");
//			c_conws("RESET\r\n");
#ifndef TOSONLY
			addroottimeout (0, int_handle_tophalf, 1);
#endif
		} else {
			__asm__ volatile("clr.w 0x43e");
		}
	}
}

#ifndef TOSONLY
void
sl811_hub_poll(PROC *proc, long dummy)
{
	wake(WAIT_Q, (long)&sl811_hub_poll_thread);
}

void 
sl811_hub_poll_thread(void *dummy)
{

	/* join process group of loader, 
	 * otherwise doesn't ends when shutingdown
	 */

	for (;;)
	{
		unicorn_int();
		addtimeout(1000L, sl811_hub_poll);
		sleep(WAIT_Q, (long)&sl811_hub_poll_thread);
	}

	kthread_exit(0);
}
#endif
