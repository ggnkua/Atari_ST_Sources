/*
 * Modified for Atari-EtherNat by David Gálvez. 2010 - 2011
 *
 * ISP116x HCD (Host Controller Driver) for u-boot.
 *
 * Copyright (C) 2006-2007 Rodolfo Giometti <giometti@linux.it>
 * Copyright (C) 2006-2007 Eurotech S.p.A. <info@eurotech.it>
 *
 * This file is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 *
 *
 * Derived in part from the SL811 HCD driver "u-boot/drivers/usb/sl811_usb.c"
 * (original copyright message follows):
 *
 *    (C) Copyright 2004
 *    Wolfgang Denk, DENX Software Engineering, wd@denx.de.
 *
 *    This code is based on linux driver for sl811hs chip, source at
 *    drivers/usb/host/sl811.c:
 *
 *    SL811 Host Controller Interface driver for USB.
 *
 *    Copyright (c) 2003/06, Courage Co., Ltd.
 *
 *    Based on:
 *         1.uhci.c by Linus Torvalds, Johannes Erdfelt, Randy Dunlap,
 *           Georg Acher, Deti Fliegl, Thomas Sailer, Roman Weissgaerber,
 *           Adam Richter, Gregory P. Smith;
 *         2.Original SL811 driver (hc_sl811.o) by Pei Liu <pbl@cypress.com>
 *         3.Rewrited as sl811.o by Yin Aihua <yinah:couragetech.com.cn>
 *
 *    [[GNU/GPL disclaimer]]
 *
 * and in part from AU1x00 OHCI HCD driver "u-boot/cpu/mips/au1x00_usb_ohci.c"
 * (original copyright message follows):
 *
 *    URB OHCI HCD (Host Controller Driver) for USB on the AU1x00.
 *
 *    (C) Copyright 2003
 *    Gary Jennejohn, DENX Software Engineering <garyj@denx.de>
 *
 *    [[GNU/GPL disclaimer]]
 *
 *    Note: Part of this code has been derived from linux
 *   Modified for Atari TT VME USB Interface by Ingo Uhlemann 2017
 */

#include <stddef.h>
#include <stdarg.h>
#include <mint/osbind.h> /* Setexc */

#ifndef TOSONLY
#include "mint/mint.h"
#include "libkern/libkern.h"
#include "mint/mdelay.h"
#endif

#include "../../global.h"

#include "mint/dcntl.h"
#include "mint/arch/asm_spl.h" /* spl() */
#include "mint/swap.h"
#include "../../usb.h"
#include "../../usb_api.h"

#include "vttusb_int.h"

#define VER_MAJOR	1
#define VER_MINOR	0
#define VER_STATUS

#ifndef TOSONLY
#define MSG_VERSION	str (VER_MAJOR) "." str (VER_MINOR) str (VER_STATUS)
#else
#define MSG_VERSION "(TOS)"
#endif
#define MSG_BUILDDATE	__DATE__

#define MSG_BOOT	\
	"\033p Lightning VME/ST USB controller driver " MSG_VERSION " \033q\r\n"

#define MSG_GREET	\
	"Ported, mixed and shaken by David Galvez.\r\nAdapted by Ingo Uhlemann and Christian Zietz\r\n" \
	"Compiled " MSG_BUILDDATE ".\r\n\r\n"

/*
 * Enable the following defines if you wish enable extra debugging messages.
 */
#ifdef DEV_DEBUG
# define TRACE_EXTRA		/* enable tracing code */
# define VERBOSE		/* verbose debugging messages */
#endif

#if defined(__mc68030__) || defined(__mc68040__) || defined(__mc68060__)
static ulong delay_150ns;
static ulong delay_300ns;
#endif
#include "isp116x.h"

#define DRIVER_VERSION	"02 Feb 2011"

/****************************************************************************/
/* BEGIN kernel interface */

#ifndef TOSONLY
struct kentry	*kentry;
#define ENSURE_SUPER (0);
#define RESTORE_SUPER(x) {x=x;};
#else

#if 0
/* Debug console output for TOS */
static char debugbuffer[512];
long	_cdecl kvsprintf	(char *buf, long buflen, const char *fmt, va_list args) __attribute__((format(printf, 3, 0)));
static void my_printmsg(const char *fmt, ...) 
{
	va_list args;
	
	va_start (args, fmt);
	kvsprintf (debugbuffer, sizeof(debugbuffer)-1, fmt, args);	
	va_end (args);
	(void)Cconws(debugbuffer);
	(void)Cconws("\r\n");
}
#endif

#define ENSURE_SUPER ((!Super(1L))?Super(0L):0L)
#define RESTORE_SUPER(x) {if (x) SuperToUser(x); }

extern unsigned long _PgmSize;
int isHddriverModule(void); /* in entry.S */

/* replacement functions */
#undef c_conws
#define c_conws (void)Cconws

#define _USB 0x5f555342L
#define CJAR ((struct cookie **) 0x5a0)

static inline struct usb_module_api *
get_usb_cookie (void)
{
	struct usb_module_api *api;
	long ret;
	struct cookie *cjar;

	ret = ENSURE_SUPER;

	api = NULL;
	cjar = *CJAR;

	while (cjar->tag)
	{
		if (cjar->tag == _USB)
		{
			api = (struct usb_module_api *)cjar->value;
	
			RESTORE_SUPER(ret);

			return api;
		}

		cjar++;
	}

	RESTORE_SUPER(ret);

	return NULL;
}

#endif

struct usb_module_api *api;

/* END kernel interface */
/****************************************************************************/

static struct usb_device *root_hub_dev = NULL;
static struct isp116x isp116x_dev;
struct isp116x_platform_data isp116x_board;
static long got_rhsc;		/* root hub status change */
struct usb_device *devgone;	/* device which was disconnected */
static long rh_devnum;		/* address of Root Hub endpoint */
static int found = 0;

static char job_in_progress = 0;

extern short max_xfer_len;	/* maximum transfer length, configurable via config block */
extern short enable_ocp;	/* enable/disable overcurrent proection, configurable via config block */
extern short use_blitter;	/* use Blitter if available, configurable via config block */

#ifdef TOSONLY
/* Global variables for tosdelay.c. Should be defined here to avoid
 * "multiple definition" errors from the linker with -fno-common.
 */
unsigned long loopcount_1_msec;
unsigned long delay_1usec;
#endif

#ifdef VTTUSB_HW_INT
/*
 * interrupt handling - bottom half
 */
void _cdecl	vttusb_int	(void);

#ifndef TOSONLY
/*
 * interrupt handling - top half
 */
static void	int_handle_tophalf	(PROC *p, long arg);
#endif // TOSONLY
#endif // VTTUSB_HW_INT

/*
 *Function prototypes
 */
long 		isp116x_check_id	(struct isp116x *);
static long	isp116x_reset		(struct isp116x *);
long		submit_bulk_msg		(struct usb_device *, unsigned long , void *, long, long, unsigned long);
long		submit_control_msg	(struct usb_device *, unsigned long, void *,
					 long, struct devrequest *);
long		submit_int_msg		(struct usb_device *, unsigned long, void *, long, long);

//long _cdecl	init			(struct kentry *, struct usb_module_api *, char **);

/*
 * USB controller interface
 */

static long _cdecl	vttusb_open		(struct ucdif *);
static long _cdecl	vttusb_close		(struct ucdif *);
static long _cdecl	vttusb_ioctl		(struct ucdif *, short, long);

static char lname[] = "Lightning VME USB driver\0";

static struct ucdif vttusb_uif =
{
	0,			/* *next */
	USB_API_VERSION,	/* API */
	USB_CONTRLL,		/* class */
	lname,			/* lname */
	"blitz",		/* name */
	0,			/* unit */
	0,			/* flags */
	vttusb_open,		/* open */
	vttusb_close,		/* close */
	0,			/* resrvd1 */
	vttusb_ioctl,		/* ioctl */
	0,			/* resrvd2 */
};

/* ------------------------------------------------------------------------- */

#define min1_t(type,x,y)	\
	({ type __x = (x); type __y = (y); __x < __y ? __x : __y; })

/* Galvez: added to avoid shadow warnings */
#define min2_t(type,x,y)	\
	({ type __a = (x); type __b = (y); __a < __b ? __a : __b; })

/* ------------------------------------------------------------------------- */


/* --- Debugging functions ------------------------------------------------- */

#define isp116x_show_reg(d, r) {				\
	if ((r) < 0x20)						\
	{							\
		DEBUG(("%12s[%02x]: %08lx", #r,			\
			r, isp116x_read_reg32(d, r)));		\
	}							\
	else							\
	{							\
		DEBUG(("%12s[%02x]:     %04x", #r,		\
			r, isp116x_read_reg16(d, r)));		\
	}							\
}

#define isp116x_show_regs(d) {					\
	isp116x_show_reg(d, HCREVISION);			\
	isp116x_show_reg(d, HCCONTROL);				\
	isp116x_show_reg(d, HCCMDSTAT);				\
	isp116x_show_reg(d, HCINTSTAT);				\
	isp116x_show_reg(d, HCINTENB);				\
	isp116x_show_reg(d, HCFMINTVL);				\
	isp116x_show_reg(d, HCFMREM);				\
	isp116x_show_reg(d, HCFMNUM);				\
	isp116x_show_reg(d, HCLSTHRESH);			\
	isp116x_show_reg(d, HCRHDESCA);				\
	isp116x_show_reg(d, HCRHDESCB);				\
	isp116x_show_reg(d, HCRHSTATUS);			\
	isp116x_show_reg(d, HCRHPORT1);				\
	isp116x_show_reg(d, HCRHPORT2);				\
	isp116x_show_reg(d, HCHWCFG);				\
	isp116x_show_reg(d, HCDMACFG);				\
	isp116x_show_reg(d, HCXFERCTR);				\
	isp116x_show_reg(d, HCuPINT);				\
	isp116x_show_reg(d, HCuPINTENB);			\
	isp116x_show_reg(d, HCCHIPID);				\
	isp116x_show_reg(d, HCSCRATCH);				\
	isp116x_show_reg(d, HCITLBUFLEN);			\
	isp116x_show_reg(d, HCATLBUFLEN);			\
	isp116x_show_reg(d, HCBUFSTAT);				\
	isp116x_show_reg(d, HCRDITL0LEN);			\
	isp116x_show_reg(d, HCRDITL1LEN);			\
}


#if defined(TRACE_EXTRA)

static long
isp116x_get_current_frame_number(struct usb_device *usb_dev)
{
	struct isp116x *isp116x = &isp116x_dev;

	return isp116x_read_reg32(isp116x, HCFMNUM);
}

static void
dump_msg(struct usb_device *dev, unsigned long pipe, void *buffer,
		     long len, char *str)
{
#if defined(VERBOSE)
	long i;
	char build_str[64];
	char buf[(len * 4) + 24 + 6];
#endif
	DEBUG(("%s URB:[%4lx] dev:%2ld,ep:%2ld-%c,type:%s,len:%ld stat:0x%lx",
				str, isp116x_get_current_frame_number(dev),
				usb_pipedevice(pipe), usb_pipeendpoint(pipe),
				usb_pipeout(pipe)  ? 'O' : 'I',
				usb_pipetype(pipe) < 2 ?
				(usb_pipeint(pipe) ? "INTR" : "ISOC") :
				(usb_pipecontrol(pipe) ? "CTRL" : "BULK"),
				len, dev->status));

#if defined(VERBOSE)
	buf[0] = '\0';
	if (len > 0 && buffer)
	{
		sprintf(build_str, sizeof(build_str), __FILE__ ": data(%ld):", len);
		strcat(buf, build_str);
		for (i = 0; i < 16 && i < len; i++)
		{
			sprintf(build_str, sizeof(build_str), " %02x", ((unsigned char *) buffer)[i]);
			strcat(buf, build_str);
		}
		sprintf(build_str, sizeof(build_str), "%s\r\n", i < len ? "..." : "");
		strcat(buf, build_str);
		DEBUG((buf));
	}
#endif
}

# define PTD_DIR_STR(ptd)  ({char __c;		\
	switch(PTD_GET_DIR(ptd)){		\
	case 0:  __c = 's'; break;		\
	case 1:  __c = 'o'; break;		\
	default: __c = 'i'; break;		\
	}; __c;})

/*
  Dump PTD info. The code documents the format
  perfectly, right :)
*/
static inline void
dump_ptd(struct ptd *ptd)
{
#if defined(VERBOSE)
	long k;
	char build_str[64];
	char buf[64 + 4 * sizeof(struct ptd)];
#endif

	DEBUG(("PTD(ext) : cc:%x %d%c%d %d,%d,%d t:%x %x%x%x",
	    PTD_GET_CC(ptd),
	    PTD_GET_FA(ptd), PTD_DIR_STR(ptd), PTD_GET_EP(ptd),
	    PTD_GET_COUNT(ptd), PTD_GET_LEN(ptd), PTD_GET_MPS(ptd),
	    PTD_GET_TOGGLE(ptd),
	    PTD_GET_ACTIVE(ptd), PTD_GET_SPD(ptd), PTD_GET_LAST(ptd)));
#if defined(VERBOSE)
	buf[0] = '\0';
	sprintf(build_str, sizeof(build_str), "isp116x: %s: PTD(byte): ", __FUNCTION__);
	strcat(buf, build_str);
	for (k = 0; k < sizeof(struct ptd); ++k) /* Galvez: note that bytes in the words are shown swapped */
	{
		sprintf(build_str, sizeof(build_str),"%02x ", ((unsigned char *) ptd)[k]);
		strcat(buf, build_str);
	}
	DEBUG((buf));
#endif
}

static inline void
dump_ptd_data(struct ptd *ptd, unsigned char * buffer, long type)
{
#if defined(VERBOSE)
	long k;
	char build_str[64];
	char buf[64 + 4 * PTD_GET_LEN(ptd)];

	buf[0] = '\0';
	if (type == 0 /* 0ut data */ )
	{
		sprintf(build_str, sizeof(build_str), "isp116x: %s: out data: ", __FUNCTION__);
		strcat(buf, build_str);
		for (k = 0; k < PTD_GET_LEN(ptd); ++k)
		{
			sprintf(build_str, sizeof(build_str), "%02x ", ((unsigned char *) buffer)[k]);
			strcat(buf, build_str);
		}
		DEBUG((buf));
	}
	if (type == 1 /* 1n data */ )
	{
		sprintf(build_str, sizeof(build_str), "isp116x: %s: in data: ", __FUNCTION__);
		strcat(buf, build_str);
		for (k = 0; k < PTD_GET_COUNT(ptd); ++k)
		{
			sprintf(build_str, sizeof(build_str), "%02x ", ((unsigned char *) buffer)[k]);
			strcat(buf, build_str);
		}
		DEBUG((buf));
	}


	if (PTD_GET_LAST(ptd))
	{
		DEBUG(("--- last PTD ---"));
	}
#endif
}

#else

# define dump_msg(dev, pipe, buffer, len, str)			do { } while (0)
# define dump_pkt(dev, pipe, buffer, len, setup, str, small)	do {} while (0)

# define dump_ptd(ptd)			do {} while (0)
# define dump_ptd_data(ptd, buf, type)	do {} while (0)

#endif /* TRACE_EXTRA */

/* --- Virtual Root Hub ---------------------------------------------------- */

/* Device descriptor */
static unsigned char root_hub_dev_des[] =
{
	0x12,			/*  unsigned char  bLength; */
	0x01,			/*  unsigned char  bDescriptorType; Device */
	0x10,			/*  unsigned short bcdUSB; v1.1 */
	0x01,
	0x09,			/*  unsigned char  bDeviceClass; HUB_CLASSCODE */
	0x00,			/*  unsigned char  bDeviceSubClass; */
	0x00,			/*  unsigned char  bDeviceProtocol; */
	0x08,			/*  unsigned char  bMaxPacketSize0; 8 Bytes */
	0x00,			/*  unsigned short idVendor; */
	0x00,
	0x00,			/*  unsigned short idProduct; */
	0x00,
	0x00,			/*  unsigned short bcdDevice; */
	0x00,
	0x00,			/*  unsigned char  iManufacturer; */
	0x01,			/*  unsigned char  iProduct; */
	0x00,			/*  unsigned char  iSerialNumber; */
	0x01			/*  unsigned char  bNumConfigurations; */
};

/* Configuration descriptor */
static unsigned char root_hub_config_des[] =
{
	0x09,			/*  unsigned char  bLength; */
	0x02,			/*  unsigned char  bDescriptorType; Configuration */
	0x19,			/*  unsigned short wTotalLength; */
	0x00,
	0x01,			/*  unsigned char  bNumInterfaces; */
	0x01,			/*  unsigned char  bConfigurationValue; */
	0x00,			/*  unsigned char  iConfiguration; */
	0x40,			/*  unsigned char  bmAttributes;
				   Bit 7: Bus-powered, 6: Self-powered, 5 Remote-wakwup, 4..0: resvd */
	0x00,			/*  unsigned char  MaxPower; */

	/* interface */
	0x09,			/*  unsigned char  if_bLength; */
	0x04,			/*  unsigned char  if_bDescriptorType; Interface */
	0x00,			/*  unsigned char  if_bInterfaceNumber; */
	0x00,			/*  unsigned char  if_bAlternateSetting; */
	0x01,			/*  unsigned char  if_bNumEndpoints; */
	0x09,			/*  unsigned char  if_bInterfaceClass; HUB_CLASSCODE */
	0x00,			/*  unsigned char  if_bInterfaceSubClass; */
	0x00,			/*  unsigned char  if_bInterfaceProtocol; */
	0x00,			/*  unsigned char  if_iInterface; */

	/* endpoint */
	0x07,			/*  unsigned char  ep_bLength; */
	0x05,			/*  unsigned char  ep_bDescriptorType; Endpoint */
	0x81,			/*  unsigned char  ep_bEndpointAddress; IN Endpoint 1 */
	0x03,			/*  unsigned char  ep_bmAttributes; Interrupt */
	0x00,			/*  unsigned short ep_wMaxPacketSize; ((MAX_ROOT_PORTS + 1) / 8 */
	0x02,
	0xff			/*  unsigned char  ep_bInterval; 255 ms */
};

static unsigned char root_hub_str_index0[] =
{
	0x04,			/*  unsigned char  bLength; */
	0x03,			/*  unsigned char  bDescriptorType; String-descriptor */
	0x09,			/*  unsigned char  lang ID */
	0x04,			/*  unsigned char  lang ID */
};

static unsigned char root_hub_str_index1[] =
{
	0x26,			/*  unsigned char  bLength; */
	0x03,			/*  unsigned char  bDescriptorType; String-descriptor */
	'L',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	'i',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	'g',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	'h',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	't',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	'n',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	'i',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	'n',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	'g',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	' ',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	'R',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	'o',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	'o',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	't',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	' ',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	'H',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	'u',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */
	'b',			/*  unsigned char  Unicode */
	0,			/*  unsigned char  Unicode */	
};

/*
 * Hub class-specific descriptor is constructed dynamically
 */

/* --- Virtual root hub management functions ------------------------------- */

static long
rh_check_port_status(struct isp116x *isp116x)
{
	unsigned long temp, ndp, i;
	long res;

	res = -1;
	temp = isp116x_read_reg32(isp116x, HCRHDESCA); /* falsch: HCRHSTATUS */
	ndp = (temp & RH_A_NDP);
	for (i = 0; i < ndp; i++)
	{
		temp = isp116x_read_reg32(isp116x, HCRHPORT1 + i);
		/* check for a device disconnect */
		if (((temp & (RH_PS_PESC | RH_PS_CSC)) ==
		     (RH_PS_PESC | RH_PS_CSC)) && ((temp & RH_PS_CCS) == 0))
		{
			res = i;
			break;
		}
	}
	return res;
}

/* --- HC management functions --------------------------------------------- */

/* locking functions */
inline static char lock_usb(char *lock) {
	char ret = 0;

	__asm("tas %1\n\t"
	      "seq %0"
	      : "=d" (ret)   /* outputs */
	      : "m"  (*lock) /* inputs, note that this really has to be "*lock", not "lock" */
	      : "cc");       /* clobbers condition codes */

	return ret;
}

inline static void unlock_usb(char *lock) {
	*lock = 0;
}

/* Write len bytes to fifo, pad till 32-bit boundary
 */
static void
write_ptddata_to_fifo(struct isp116x *isp116x, void *buf, long len)
{
#if 1
/* A0.L = source = memory */
/* A1.L = destination = fifo */
/* D2.L = length = byte count (0 .. 32000 wegen dbra) */
__asm("movea.l %0, A1\n\tmovea.l %1, A0\n\tmove.l %2, D2\n" /* setup inputs */
	"mem2isp:      move.l    D2,D1\n"           /* set up loop counter */
	"              asr.l     #1,D1\n"           /* D1.L = word count */
	"\n"
	"              move.l    A0,D0\n"           /* check source alignment */
	"              andi.l    #1,D0\n"           /* source word-aligned? */
	"              beq.s     m2i_ev1\n"         /* yes: jmp */
	"              bra.s     m2i_od1\n"
	"\n" /* ------------------------------------ */
	"m2i_od:       move.b    (A0)+,D0\n"        /* read 1st byte from memory        4/12 */
	"              lsl.w     #8,D0\n"           /* shift up                         2/22 */
	"              move.b    (A0)+,D0\n"        /* read 2nd byte from memory        2/12 */
	"              move.w    D0,(A1)\n"         /* write word to fifo               2/12 */
	"m2i_od1:      dbra      D1,m2i_od\n"       /*                                  4/10 */
	"              bra.s     m2i_ali\n"         /*                                  2/10 */
	"\n"
	"m2i_ev:       move.w    (A0)+,(A1)\n"      /* copy word from memory to fifo    2/12 */
	"m2i_ev1:      dbra      D1,m2i_ev\n"       /*                                  4/10 */
	"\n" /* ------------------------------------ */
	"m2i_ali:      andi.l    #3,D2\n"           /* len alignment = 0? (long-word)   6/16 */
	"              beq.s     m2i_done\n"        /* yes: jmp, nothing left to do     2/10 */
	"\n"
	"              cmpi.w    #2,D2\n"           /* len alignment = 2? (word)        4/ 8 */
	"              beq.s     m2i_wal\n"         /* yes: jmp, send one dummy word    2/10 */
	"\n"
	"              moveq     #0,D0\n"           /* prepare to read last byte..      2/ 4 */
	"              move.b    (A0)+,D0\n"        /* ..from memory                    2/12 */
	"              lsl.w     #8,D0\n"           /* shift up                         2/22 */
	"              move.w    D0,(A1)\n"         /* write word to fifo               2/12 */
	"\n"
	"              cmpi.w    #3,D2\n"           /* len alignment = 3?               2/12 */
	"              beq.s     m2i_done\n"        /* yes: jmp, nothing left to do     2/10 */
	"\n"
	"m2i_wal:      move.w    #0,(A1)\n"         /* write dummy word to fifo         2/12 */
	"m2i_done:\n"
        : /* no outputs */
        : "g" (isp116x->data_reg), "g" (buf), "g" (len) /* inputs */
        : "%%d0", "%%d1", "%%d2", "%%a0", "%%a1" /* clobbered registers */);

#else
	unsigned char *dp = (unsigned char *) buf;
	unsigned short *dp2 = (unsigned short *) buf;
	unsigned short w;
	long quot = len % 4;

/* For EtherNat, take the raw_write out in write functions, here we don't
 * like that EtherNat swap the bytes for us, so we swap them before we send
 * them, then the bytes will arrive to the USB device with the correct positions
 */
	if ((unsigned long)dp2 & 1)
	{
		ALERT(("Unaligned access"));
		/* not aligned */
		for (; len > 1; len -= 2)
		{
			w = *dp++;
			w |= *dp++ << 8;
			isp116x_write_data16(isp116x, w);
		}
		if (len)
			isp116x_write_data16(isp116x, (unsigned short) * dp);
	}
	else
	{
		/* aligned */
		for (; len > 1; len -= 2)
			isp116x_write_data16(isp116x, *dp2++);
		if (len)
		{
			isp116x_raw_write_data16(isp116x, 0xff & *((unsigned char *) dp2));
		}
	}
	if (quot == 1 || quot == 2)
		isp116x_write_data16(isp116x, 0);
#endif
}

#ifdef LIGHTNING_VME
#ifndef __mc68030__
/* Lightning VME & MegaSTE => always has Blitter */
#define HAS_BLITTER (1)
#else
/* Lightning VME & TT => never has Blitter */
#define HAS_BLITTER (0)
#endif
#endif

#ifdef LIGHTNING_ST
/* Lightning ST => have to check for Blitter at runtime */
#define HAS_BLITTER (1)
#endif

struct blitter {
	unsigned short srcinc_x;
	unsigned short srcinc_y;
	unsigned long  srcaddr;
	unsigned short endmask[3];
	unsigned short dstinc_x;
	unsigned short dstinc_y;
	unsigned long  dstaddr;
	unsigned short xcount;
	unsigned short ycount;
	unsigned short hop_op;
	unsigned short misc;
};

static volatile struct blitter *const BLITTER = (volatile struct blitter *)(0xFFFF8A20L);

/* Read len bytes from fifo and then read till 32-bit boundary
 */
static void
read_ptddata_from_fifo(struct isp116x *isp116x, void *buf, long len)
{
/* A0.L = source = fifo */
/* A1.L = destination = memory */
/* D2.L = length = byte count (0 .. 32000 wegen dbra) */

/* ST, Mega STE: Use Blitter when some conditions are met. In particular, check that Blitter is not already busy. */
if (HAS_BLITTER && use_blitter && (len>=256) && !(len & 1) && !((unsigned long)buf & 1) && !(BLITTER->misc & 0x8000)) {
	BLITTER->srcinc_x = 0;
	BLITTER->srcinc_y = 0;
	BLITTER->srcaddr = (unsigned long)isp116x->data_reg;
	BLITTER->endmask[0] = BLITTER->endmask[1] = BLITTER->endmask[2] = 0xFFFF;
	BLITTER->dstinc_x = 2;
	BLITTER->dstinc_y = 2;
	BLITTER->dstaddr = (unsigned long)buf;
	BLITTER->xcount = len>>1;
	BLITTER->ycount = 1;
	BLITTER->hop_op = 0x0203;
	BLITTER->misc   = 1<<(6+8); // HOG;
	__asm("blloop: tas %0.w\n\t" // (re)start the BLiTTER
          "nop\n\t"                     // BLITTER will need a few cycles
          "bmi.s blloop"               // Loop if register shows "busy"
		  : "+m"(BLITTER->misc) :  :"cc");
} 
else 
{
	__asm("movea.l %0, A0\n\tmovea.l %1, A1\n\tmove.l %2, D2\n" /* setup inputs */
		"isp2mem:      move.l    D2,D1\n"           /* set up loop counter */
		"              asr.l     #1,D1\n"           /* D1.L = word count */
		"\n"
		"              move.l    A1,D0\n"           /* check destination alignment */
		"              andi.l    #1,D0\n"           /* destination word-aligned? */
		"              beq.s     i2m_ev1\n"         /* yes: jmp */
		"              bra.s     i2m_od1\n"
		"\n" /* ------------------------------------ */
		"i2m_od:       move.w    (A0),D0\n"         /* read word from fifo */
		"              move.b    D0,1(A1)\n"        /* write 2nd byte to memory */
		"              lsr.w     #8,D0\n"           /* shift down */
		"              move.b    D0,(A1)\n"         /* write 1st byte to memory */
		"              addq.l    #2,A1\n"           /* increment destination pointer    2/ 8 */
		"i2m_od1:      dbra      D1,i2m_od\n"
		"              bra.s     i2m_ali\n"
		"\n"
		"i2m_ev:       move.w    (A0),(A1)+\n"      /* copy word from fifo to memory */
		"i2m_ev1:      dbra      D1,i2m_ev\n"
		"\n" /* ------------------------------------ */
		"i2m_ali:      andi.l    #3,D2\n"           /* len alignment = 0? (long-word)   6/16 */
		"              beq.s     i2m_done\n"        /* yes: jmp, nothing left to do     2/10 */
		"\n"
		"              cmpi.w    #2,D2\n"           /* len alignment = 2? (word)        4/ 8 */
		"              beq.s     i2m_wal\n"         /* yes: jmp, dump one more word     2/10 */
		"\n"
		"              move.w    (A0),D0\n"         /* read word from fifo              2/12 */
		"              lsr.w     #8,D0\n"           /* shift down */
		"              move.b    D0,(A1)+\n"        /* write last byte to memory        2/12 */
		"\n"
		"              cmpi.w    #3,D2\n"           /* len alignment = 3?               2/12 */
		"              beq.s     i2m_done\n"        /* yes: jmp, nothing left to do     2/10 */
		"\n"
		"i2m_wal:      move.w    (A0),D0\n"         /* dump word from fifo              2/12 */
		"i2m_done:\n"
			: /* no outputs */
			: "g" (isp116x->data_reg), "g" (buf), "g" (len) /* inputs */
			: "%%d0", "%%d1", "%%d2", "%%a0", "%%a1" /* clobbered registers */);
}
}

/* Write PTD's and data for scheduled transfers into the fifo ram.
 * Fifo must be empty and ready
 */
static void
pack_fifo(struct isp116x *isp116x, struct usb_device *dev,
		      unsigned long pipe, struct ptd *ptd, void *data,
		      long len)
{
	long buflen;
	long done;
	
	if ((PTD_GET_DIR(ptd) == PTD_DIR_OUT) || (PTD_GET_DIR(ptd) == PTD_DIR_SETUP)) {
		buflen = sizeof(struct ptd) + len;
	} else {
		buflen = sizeof(struct ptd);
	}

	DEBUG(("--- pack buffer 0x%p - %ld bytes (fifo %ld) ---", data, len, buflen));

	isp116x_write_reg16(isp116x, HCuPINT, HCuPINT_AIIEOT);

	isp116x_write_reg16(isp116x, HCXFERCTR, buflen);
	isp116x_write_addr(isp116x, HCATLPORT | ISP116x_WRITE_OFFSET);

	done = 0;
	//DEBUG(("i=%ld - done=%ld - len=%d", i, done, PTD_GET_LEN(ptd)));

	/* For EtherNAT, use raw_write to don't swap bytes */
	dump_ptd(ptd);
	isp116x_raw_write_data16(isp116x, ptd->count);
	isp116x_raw_write_data16(isp116x, ptd->mps);
	isp116x_raw_write_data16(isp116x, ptd->len);
	isp116x_raw_write_data16(isp116x, ptd->faddr);

	dump_ptd_data(ptd, (unsigned char *) data + done, 0);

	if ((PTD_GET_DIR(ptd) == PTD_DIR_OUT) || (PTD_GET_DIR(ptd) == PTD_DIR_SETUP)) {
		/* This part is critical, disamble interrupts */
		unsigned long ret = ENSURE_SUPER;
		set_int_lvl6();
		write_ptddata_to_fifo(isp116x,
				      (unsigned char *) data + done,
				      PTD_GET_LEN(ptd));
		set_old_int_lvl();
		RESTORE_SUPER(ret);
	}

	done += PTD_GET_LEN(ptd);
}

/* Read the processed PTD's and data from fifo ram back to URBs' buffers.
 * Fifo must be full and done
 */
static long
unpack_fifo(struct isp116x *isp116x, struct usb_device *dev,
		       unsigned long pipe, struct ptd *ptd, void *data,
		       long len)
{
	long buflen;
	long done, cc, ret;
	
	if (PTD_GET_DIR(ptd) == PTD_DIR_IN) {
		buflen = sizeof(struct ptd) + len;
	} else {
		buflen = sizeof(struct ptd);
	}

	isp116x_write_reg16(isp116x, HCuPINT, HCuPINT_AIIEOT);
	isp116x_write_reg16(isp116x, HCXFERCTR, buflen);
	isp116x_write_addr(isp116x, HCATLPORT);

	ret = TD_CC_NOERROR;
	done = 0;

	/* For EtherNAT, use raw_read to don't swap bytes */
	ptd->count = isp116x_raw_read_data16(isp116x);
	ptd->mps = isp116x_raw_read_data16(isp116x);
	ptd->len = isp116x_raw_read_data16(isp116x);
	ptd->faddr = isp116x_raw_read_data16(isp116x);
	dump_ptd(ptd);

	/* when cc is 15 the data has not being touch by the HC
	 * so we have to read all to empty completly the buffer
	 */
//		if (PTD_GET_COUNT(ptd) != 0 || PTD_GET_CC(ptd) == 15)
	if (PTD_GET_DIR(ptd) == PTD_DIR_IN) {
		/* This part is critical, disamble interrupts */
		unsigned long ret2 = ENSURE_SUPER;
		set_int_lvl6();
		read_ptddata_from_fifo(isp116x,
				       (unsigned char *) data + done,
				       PTD_GET_LEN(ptd));
		set_old_int_lvl();
		RESTORE_SUPER(ret2);
	}
	dump_ptd_data(ptd, (unsigned char *) data + done, 1);

	done += PTD_GET_LEN(ptd);

	cc = PTD_GET_CC(ptd);

	/* Data underrun means basically that we had more buffer space than
	 * the function had data. It is perfectly normal but upper levels have
	 * to know how much we actually transferred.
	 */
	if (cc == TD_NOTACCESSED ||
			(cc != TD_CC_NOERROR && (ret == TD_CC_NOERROR || ret == TD_DATAUNDERRUN)))
		ret = cc;

	DEBUG(("--- unpack buffer 0x%p - %ld bytes (fifo %ld) count: %d ---", data, len, buflen, PTD_GET_COUNT(ptd)));

	return ret;
}

/* Interrupt handling
 */
static long
isp116x_interrupt(struct isp116x *isp116x)
{
	unsigned short irqstat;
	unsigned long intstat;
	long ret = 0;

	isp116x_write_reg16(isp116x, HCuPINTENB, 0);
	irqstat = isp116x_read_reg16(isp116x, HCuPINT);
	isp116x_write_reg16(isp116x, HCuPINT, irqstat);
	DEBUG((">>>>>> irqstat %x <<<<<<", irqstat));

	if (irqstat & HCuPINT_ATL)
	{
		DEBUG((">>>>>> HCuPINT_ATL <<<<<<"));
		//udelay(500);
		ret = 1;
	}

	if (irqstat & HCuPINT_OPR)
	{
		intstat = isp116x_read_reg32(isp116x, HCINTSTAT);
		isp116x_write_reg32(isp116x, HCINTSTAT, intstat);
		DEBUG((">>>>>> HCuPINT_OPR %lx <<<<<<", intstat));

		if (intstat & HCINT_UE)
		{
			ALERT(("unrecoverable error, controller disabled"));

			/* FIXME: be optimistic, hope that bug won't repeat
			 * often. Make some non-interrupt context restart the
			 * controller. Count and limit the retries though;
			 * either hardware or software errors can go forever...
			 */
			isp116x_reset(isp116x);
			ret = -1;
			return -1;
		}

		if (intstat & HCINT_RHSC)
		{
			got_rhsc = 1;
			ret = 1;
			/* When root hub or any of its ports is going
			   to come out of suspend, it may take more
			   than 10ms for status bits to stabilize. */
			mdelay(20);
		}

		if (intstat & HCINT_SO)
		{
			ALERT(("schedule overrun"));
			ret = -1;
		}

		irqstat &= ~HCuPINT_OPR;
	}

	isp116x_write_reg16(isp116x, HCuPINTENB, isp116x->irqenb);
	return ret;
}

/* With one PTD we can transfer almost 1K in one go;
 * HC does the splitting into endpoint digestible transactions
 */
static struct ptd ptd[1];

static inline long
max_transfer_len(struct usb_device *dev, unsigned long pipe)
{
	unsigned mpck = usb_maxpacket(dev, pipe);

	/* One PTD can transfer 1023 bytes but try to always
	 * transfer multiples of endpoint buffer size
	 */
	
	if (max_xfer_len < mpck) {
		/* Regardless of user's setting, always allow 
		 * at least one packet or 1023 bytes, whichever is less. */
		return min1_t(long,mpck,1023L);
	} else {
		return max_xfer_len / mpck * mpck;
	}
}

/* Check if there is an interrupt request by the keyboard ACIA.
 * TOS might not be able it by itself due to the interrupt level.
 * Returns != 0 if there is a pending interrupt request.
 */
static inline int keybd_acia_int() 
{
	unsigned char keyctl = *(unsigned char*)(0xFFFFFC00UL);
	return (keyctl & 0x80);
}

/* Returns the current interrupt level of the CPU.
 * Must only be called in supervisor mode.
 */
static inline unsigned int get_int_lvl() {
	unsigned int sr;
	__asm("move sr,%0" : "=d" (sr) : /* no inputs */);
	return (sr >> 8) & 7;
}

/* Do an USB transfer
 */
static long
isp116x_submit_job(struct usb_device *dev, unsigned long pipe,
			      long dir, void *buffer, long len, long flags,
                  unsigned long time_out)
{
	struct isp116x *isp116x = &isp116x_dev;
	long type = usb_pipetype(pipe);
	long epnum = usb_pipeendpoint(pipe);
	long max = usb_maxpacket(dev, pipe);
	long dir_out = usb_pipeout(pipe);
	long speed_low = usb_pipeslow(pipe);
	long i, done = 0, stat, timeout, cc;

	/* Use supplied timeout when function is busy and NAKs transactions for a while */
	/* However, do not retry interrupt transfers in case of NAK. Report an error and leave it to the
	upper level driver to retry the transfer in regular intervals. */
	/* Also do not retry when driver explicitly requests and early timeout (used in Ethernet driver). */
	long retries = ((type == PIPE_INTERRUPT) || (flags == USB_BULK_FLAG_EARLY_TIMEOUT))?0:time_out;
	long critical_retries = (type == PIPE_INTERRUPT)?0:5;
	short set_extra_delay = 0;
	
#ifdef TOSONLY	
	long check_keybd = 0;	
	/* When in supervisor mode and int level >=6 then we're probably being called from a timer IRQ */
	/* In that case, we need to check for the keyboard interrupt so that no characters get dropped */
	if (Super(1L) && (get_int_lvl() >= 6)) {
		check_keybd = 1;
	}
#endif

	DEBUG(("------------------------------------------------"));
	dump_msg(dev, pipe, buffer, len, "SUBMIT");
	DEBUG(("------------------------------------------------"));

	if (len >= 1024)
	{
		ALERT(("Too big job"));
		dev->status = USB_ST_CRC_ERR;
		return -1;
	}

	if (isp116x->disabled)
	{
		DEBUG(("EPIPE"));
		dev->status = USB_ST_CRC_ERR;
		return -1;
	}

	/* device pulled? Shortcut the action. */
	if (devgone == dev)
	{
		ALERT(("ENODEV"));
		dev->status = USB_ST_CRC_ERR;
		return USB_ST_CRC_ERR;
	}

	if (!max)
	{
		ALERT(("pipesize for pipe %lx is zero", pipe));
		dev->status = USB_ST_CRC_ERR;
		return -1;
	}

	if (type == PIPE_ISOCHRONOUS)
	{
		ALERT(("isochronous transfers not supported"));
		dev->status = USB_ST_CRC_ERR;
		return -1;
	}
	
	/* Another job in progress */
	if (!lock_usb(&job_in_progress)) {
		ALERT(("Another USB job in progress -- must not happen"));
		dev->status = USB_ST_BUF_ERR;
		return -1;
	}	

	/* FIFO not empty? */
	if (isp116x_read_reg16(isp116x, HCBUFSTAT) & HCBUFSTAT_ATL_FULL)
	{
		DEBUG(("****** FIFO not empty! ******"));
		dev->status = USB_ST_BUF_ERR;
		unlock_usb(&job_in_progress);
		return -1;
	}

retry:
	isp116x_write_reg32(isp116x, HCINTSTAT, 0xff);
	/* Prepare the PTD data */
	ptd->count = PTD_CC_MSK | PTD_ACTIVE_MSK |
		PTD_TOGGLE(usb_gettoggle(dev, epnum, dir_out));
	ptd->mps = PTD_MPS(max) | PTD_SPD(speed_low) | PTD_EP(epnum) | PTD_LAST_MSK;
	ptd->len = PTD_LEN(len) | PTD_DIR(dir) | PTD_B5_5(type == PIPE_INTERRUPT);
	ptd->faddr = PTD_FA(usb_pipedevice(pipe));

retry_same:

	/* FIFO not empty? */
	if (isp116x_read_reg16(isp116x, HCBUFSTAT) & HCBUFSTAT_ATL_FULL)
	{
		DEBUG(("****** FIFO not empty! (2) ******"));
		dev->status = USB_ST_BUF_ERR;
		unlock_usb(&job_in_progress);
		return -1;
	}

	/* Pack data into FIFO ram */
	pack_fifo(isp116x, dev, pipe, ptd, buffer, len);

# ifdef EXTRA_DELAY
	mdelay(EXTRA_DELAY);
# endif
	if(set_extra_delay)
		mdelay(4);

	/* Start the data transfer */

	/* Allow more time for a BULK device to react - some are slow */
	if (usb_pipebulk(pipe))
		timeout = 5000; /* Galvez: default = 5000 */
	else
		timeout = 1000;

	/* Wait for it to complete */
	for (;;)
	{
		/* Check whether the controller is done */
		stat = isp116x_interrupt(isp116x);

		if (stat < 0)
		{
			dev->status = USB_ST_CRC_ERR;
			break;
		}
		if (stat > 0)
			break;

		/* Check the timeout */
		if (--timeout)
			udelay(1);
		else
		{
			DEBUG(("CTL:TIMEOUT "));
			stat = USB_ST_CRC_ERR;
			break;
		}

#ifdef TOSONLY		
		/* Check the keyboard  */
		if (check_keybd && keybd_acia_int()) {
			fake_hwint();
		}
#endif
	}

	/* We got an Root Hub Status Change interrupt */
	if (got_rhsc)
	{
		isp116x_show_regs(isp116x);

		got_rhsc = 0;

		/* Abuse timeout */
		timeout = rh_check_port_status(isp116x);
		if (timeout >= 0)
		{
			/*
			 * FIXME! NOTE! AAAARGH!
			 * This is potentially dangerous because it assumes
			 * that only one device is ever plugged in!
			 */
			devgone = dev;
		}
	}

	/* Ok, now we can read transfer status */

	/* FIFO not ready? */
	if (!(isp116x_read_reg16(isp116x, HCBUFSTAT) & HCBUFSTAT_ATL_DONE))
	{
		DEBUG(("****** FIFO not ready! ******"));
		dev->status = USB_ST_BUF_ERR;
		unlock_usb(&job_in_progress);
		return -1;
	}

	/* Unpack data from FIFO ram */
	cc = unpack_fifo(isp116x, dev, pipe, ptd, buffer, len);

	i = PTD_GET_COUNT(ptd);
	done += i;
	buffer = (char *)buffer + i;
	len -= i;

	/* Bugfix for possible ISP1160 hardware bug:
	 * If B5_5 was set (for an interrupt transfer), the PTD will return with CC=0, count=0 when the device
	 * has in fact NAKed the transaction. The chip will have updated the toggle bit erroneously.
	 */
	if (PTD_GET_B5_5(ptd) && !cc && !PTD_GET_COUNT(ptd)) {
		/* Toggle it back so that driver can do its usual processing. */
		ptd->count ^= PTD_TOGGLE_MSK;
	}

	/* There was some kind of real problem; Prepare the PTD again
	 * and retry from the failed transaction on
	 */
	if (cc && cc != TD_NOTACCESSED && cc != TD_DATAUNDERRUN)
	{
		DEBUG(("PROBLEM cc: %ld (retry %ld)", cc, 5L-critical_retries));
		if (critical_retries)
		{
			critical_retries -= 1;
			/* The chip will have toggled the toggle bit for the failed
			 * transaction too. We have to toggle it back.
			 */
			usb_settoggle(dev, epnum, dir_out, !PTD_GET_TOGGLE(ptd));
			goto retry;
		}
	}
	/* "Normal" errors; TD_NOTACCESSED would mean in effect that the function have NAKed
	 * the transactions from the first on for the whole frame. It may be busy and we retry
	 * with the same PTD. PTD_ACTIVE (and not TD_NOTACCESSED) would mean that some of the
	 * PTD didn't make it because the function was busy or the frame ended before the PTD
	 * finished. We prepare the rest of the data and try again.
	 */
	else if ( cc == TD_NOTACCESSED ||  PTD_GET_ACTIVE(ptd) ||  ( cc != TD_DATAUNDERRUN && PTD_GET_COUNT(ptd) < PTD_GET_LEN(ptd)))
	{
		if ((!cc) && (PTD_GET_COUNT(ptd) > 0) && (PTD_GET_ACTIVE(ptd))) {
			/* Simply wasn't finished because frame ended: continue in the next frame, regardless of retry counter. */
			usb_settoggle(dev, epnum, dir_out, PTD_GET_TOGGLE(ptd));
			goto retry;
		}
		if (retries)
		{
			--retries;
			if (cc == TD_NOTACCESSED && PTD_GET_ACTIVE(ptd) && !PTD_GET_COUNT(ptd))
			{
				set_extra_delay = 1;
				goto retry_same;
			}
			usb_settoggle(dev, epnum, dir_out, PTD_GET_TOGGLE(ptd));
			goto retry;
		}
	}

	if (cc != TD_CC_NOERROR && cc != TD_DATAUNDERRUN)
	{
		DEBUG(("****** completion code error %lx ******", cc));
		switch (cc)
		{
			case TD_CC_BITSTUFFING:
				dev->status = USB_ST_BIT_ERR;
				break;
			case TD_CC_STALL:
				dev->status = USB_ST_STALLED;
				break;
			case TD_BUFFEROVERRUN:
			case TD_BUFFERUNDERRUN:
				dev->status = USB_ST_BUF_ERR;
				break;
			default:
				dev->status = USB_ST_CRC_ERR;
		}
		unlock_usb(&job_in_progress);
		return -cc;
	}
	else
		usb_settoggle(dev, epnum, dir_out, PTD_GET_TOGGLE(ptd));

	dump_msg(dev, pipe, buffer, len, "SUBMIT(ret)");

	dev->status = 0;
	unlock_usb(&job_in_progress);
	return done;
}

/* Adapted from au1x00_usb_ohci.c
 */
static long
isp116x_submit_rh_msg(struct usb_device *dev, unsigned long pipe,
				 void *buffer, long transfer_len,
				 struct devrequest *cmd)
{
	struct isp116x *isp116x = &isp116x_dev;
	unsigned long tmp = 0;

	long leni = transfer_len;
	long len = 0;
	long stat = 0;
	unsigned long datab[4];
	unsigned char *data_buf = (unsigned char *) datab;
	unsigned short bmRType_bReq;
	unsigned short wValue;
	unsigned short wIndex;
	unsigned short wLength;
	union { unsigned char *cp; unsigned short *sp; } up = {data_buf};

	if (usb_pipeint(pipe))
	{
		ALERT(("Root-Hub submit IRQ: NOT implemented"));
		return 0;
	}

	bmRType_bReq = cmd->requesttype | (cmd->request << 8);
	wValue = swap_16(cmd->value);
	wIndex = swap_16(cmd->index);
	wLength = swap_16(cmd->length);

	DEBUG(("--- HUB ----------------------------------------"));
	DEBUG(("submit rh urb, req=%x val=0x%x index=0x%x len=%d",
	    bmRType_bReq, wValue, wIndex, wLength);
	dump_msg(dev, pipe, buffer, transfer_len, "RH"));
	DEBUG(("------------------------------------------------"));

	switch (bmRType_bReq)
	{
		case RH_GET_STATUS:
			DEBUG(("RH_GET_STATUS"));

			*up.sp = swap_16(1);
			len = 2;
			break;

		case RH_GET_STATUS | RH_INTERFACE:
			DEBUG(("RH_GET_STATUS | RH_INTERFACE"));

			*up.sp = swap_16(0);
			len = 2;
			break;

		case RH_GET_STATUS | RH_ENDPOINT:
			DEBUG(("RH_GET_STATUS | RH_ENDPOINT"));

			*up.sp = swap_16(0);
			len = 2;
			break;

		case RH_GET_STATUS | RH_CLASS:
			DEBUG(("RH_GET_STATUS | RH_CLASS"));

			tmp = isp116x_read_reg32(isp116x, HCRHSTATUS);

			*(unsigned long *) data_buf = swap_32(tmp & ~(RH_HS_CRWE | RH_HS_DRWE));
			len = 4;
			break;

		case RH_GET_STATUS | RH_OTHER | RH_CLASS:
			DEBUG(("RH_GET_STATUS | RH_OTHER | RH_CLASS"));

			tmp = isp116x_read_reg32(isp116x, HCRHPORT1 + wIndex - 1);
			*(unsigned long *) data_buf = swap_32(tmp);
			isp116x_show_regs(isp116x);
			len = 4;
			break;

		case RH_CLEAR_FEATURE | RH_ENDPOINT:
			DEBUG(("RH_CLEAR_FEATURE | RH_ENDPOINT"));

			switch (wValue)
			{
				case RH_ENDPOINT_STALL:
				DEBUG(("C_HUB_ENDPOINT_STALL"));
				len = 0;
				break;
			}
			break;

		case RH_CLEAR_FEATURE | RH_CLASS:
			DEBUG(("RH_CLEAR_FEATURE | RH_CLASS"));

			switch (wValue)
			{
			case RH_C_HUB_LOCAL_POWER:
				DEBUG(("C_HUB_LOCAL_POWER"));
				len = 0;
				break;

			case RH_C_HUB_OVER_CURRENT:
				DEBUG(("C_HUB_OVER_CURRENT"));
				isp116x_write_reg32(isp116x, HCRHSTATUS, RH_HS_OCIC);
				len = 0;
				break;
			}
			break;

		case RH_CLEAR_FEATURE | RH_OTHER | RH_CLASS:
			DEBUG(("RH_CLEAR_FEATURE | RH_OTHER | RH_CLASS"));

			switch (wValue)
			{
				case RH_PORT_ENABLE:
					isp116x_write_reg32(isp116x, HCRHPORT1 + wIndex - 1,
							    RH_PS_CCS);
					len = 0;
					break;

				case RH_PORT_SUSPEND:
					isp116x_write_reg32(isp116x, HCRHPORT1 + wIndex - 1,
							    RH_PS_POCI);
					len = 0;
					break;

				case RH_PORT_POWER:
					isp116x_write_reg32(isp116x, HCRHPORT1 + wIndex - 1,
							    RH_PS_LSDA);
					len = 0;
					break;

				case RH_C_PORT_CONNECTION:
					isp116x_write_reg32(isp116x, HCRHPORT1 + wIndex - 1,
							    RH_PS_CSC);
					len = 0;
					break;

				case RH_C_PORT_ENABLE:
					isp116x_write_reg32(isp116x, HCRHPORT1 + wIndex - 1,
							    RH_PS_PESC);
					len = 0;
					break;

				case RH_C_PORT_SUSPEND:
					isp116x_write_reg32(isp116x, HCRHPORT1 + wIndex - 1,
							    RH_PS_PSSC);
					len = 0;
					break;

				case RH_C_PORT_OVER_CURRENT:
					isp116x_write_reg32(isp116x, HCRHPORT1 + wIndex - 1,
							    RH_PS_POCI);
					len = 0;
					break;

				case RH_C_PORT_RESET:
					isp116x_write_reg32(isp116x, HCRHPORT1 + wIndex - 1,
							    RH_PS_PRSC);
					len = 0;
					break;

				default:
					ALERT(("invalid wValue"));
					stat = USB_ST_STALLED;
			}

			isp116x_show_regs(isp116x);
			break;

		case RH_SET_FEATURE | RH_OTHER | RH_CLASS:
			DEBUG(("RH_SET_FEATURE | RH_OTHER | RH_CLASS"));

			switch (wValue)
			{
				case RH_PORT_SUSPEND:
					isp116x_write_reg32(isp116x, HCRHPORT1 + wIndex - 1,
							    RH_PS_PSS);
					len = 0;
					break;

				case RH_PORT_RESET:
					/* Spin until any current reset finishes */
					while (1)
					{
					tmp = isp116x_read_reg32(isp116x,
						       HCRHPORT1 + wIndex - 1);
					if (!(tmp & RH_PS_PRS))
						break;
					mdelay(1);
					}
					isp116x_write_reg32(isp116x, HCRHPORT1 + wIndex - 1,
							    RH_PS_PRS);
					mdelay(10);
					len = 0;
					break;

				case RH_PORT_POWER:
					isp116x_write_reg32(isp116x, HCRHPORT1 + wIndex - 1,
							    RH_PS_PPS);
					len = 0;
					break;

				case RH_PORT_ENABLE:
					isp116x_write_reg32(isp116x, HCRHPORT1 + wIndex - 1,
							    RH_PS_PES);
					len = 0;
					break;

				default:
					ALERT(("invalid wValue"));
					stat = USB_ST_STALLED;
			}
			isp116x_show_regs(isp116x);
			break;

		case RH_SET_ADDRESS:
			DEBUG(("RH_SET_ADDRESS"));

			rh_devnum = wValue;
			len = 0;
			break;

		case RH_GET_DESCRIPTOR:
			DEBUG(("RH_GET_DESCRIPTOR: %x, %d", wValue, wLength));

			switch (wValue)
			{
				case (USB_DT_DEVICE << 8):	/* device descriptor */
					len = min1_t(unsigned long,
							leni, min2_t(unsigned long,
							sizeof(root_hub_dev_des),
							wLength));
				data_buf = root_hub_dev_des;
				break;

				case (USB_DT_CONFIG << 8):	/* configuration descriptor */
					len = min1_t(unsigned long,
							leni, min2_t(unsigned long,
							sizeof(root_hub_config_des),
							wLength));
					data_buf = root_hub_config_des;
					break;

				case ((USB_DT_STRING << 8) | 0x00):	/* string 0 descriptors */
					len = min1_t(unsigned long,
							leni, min2_t(unsigned long,
							sizeof(root_hub_str_index0),
							wLength));
					data_buf = root_hub_str_index0;
					break;

				case ((USB_DT_STRING << 8) | 0x01):	/* string 1 descriptors */
					len = min1_t(unsigned long,
							leni, min2_t(unsigned long,
							sizeof(root_hub_str_index1),
							wLength));
					data_buf = root_hub_str_index1;
					break;

				default:
					ALERT(("invalid wValue"));
					stat = USB_ST_STALLED;
			}
			break;

		case RH_GET_DESCRIPTOR | RH_CLASS:
			DEBUG(("RH_GET_DESCRIPTOR | RH_CLASS"));

			tmp = isp116x_read_reg32(isp116x, HCRHDESCA);

			data_buf[0] = 0x09;	/* min length; */
			data_buf[1] = 0x29;
			data_buf[2] = tmp & RH_A_NDP;
			data_buf[3] = 0;
			if (tmp & RH_A_PSM)	/* per-port power switching? */
				data_buf[3] |= 0x01;
			if (tmp & RH_A_NOCP)	/* no overcurrent reporting? */
				data_buf[3] |= 0x10;
			else if (tmp & RH_A_OCPM)	/* per-port overcurrent rep? */
				data_buf[3] |= 0x08;

			/* Corresponds to data_buf[4-7] */
			datab[1] = 0;
			data_buf[5] = (tmp & RH_A_POTPGT) >> 24;

			tmp = isp116x_read_reg32(isp116x, HCRHDESCB);

			data_buf[7] = tmp & RH_B_DR;
			if (data_buf[2] < 7)
				data_buf[8] = 0xff;
			else
			{
				data_buf[0] += 2;
				data_buf[8] = (tmp & RH_B_DR) >> 8;
				data_buf[10] = data_buf[9] = 0xff;
			}

			len = min1_t(unsigned long, leni,
					 min2_t(unsigned long, data_buf[0], wLength));
			break;

		case RH_GET_CONFIGURATION:
			DEBUG(("RH_GET_CONFIGURATION"));

			*(unsigned char *) data_buf = 0x01;
			len = 1;
			break;

		case RH_SET_CONFIGURATION:
			DEBUG(("RH_SET_CONFIGURATION"));

			isp116x_write_reg32(isp116x, HCRHSTATUS, RH_HS_LPSC);
			len = 0;
			break;

		default:
			ALERT(("*** *** *** unsupported root hub command *** *** ***"));
			stat = USB_ST_STALLED;
	}

	len = min1_t(long, len, leni);
	if (buffer != data_buf)
		memcpy(buffer, data_buf, len);

	dev->act_len = len;
	dev->status = stat;
	DEBUG(("dev act_len %ld, status %ld", dev->act_len, dev->status));

	dump_msg(dev, pipe, buffer, transfer_len, "RH(ret)");

	return stat;
}

/* --- Transfer functions -------------------------------------------------- */

long
submit_int_msg(struct usb_device *dev, unsigned long pipe, void *buffer,
		long len, long interval)
{
	DEBUG(("dev=0x%p pipe=%lx buf=0x%p size=%ld int=%ld",
		dev, pipe, buffer, len, interval));

	return -1;
}

long
submit_control_msg(struct usb_device *dev, unsigned long pipe, void *buffer,
		   long len, struct devrequest *setup)
{
	long devnum = usb_pipedevice(pipe);
	long epnum = usb_pipeendpoint(pipe);
	long max = max_transfer_len(dev, pipe);
	long dir_in = usb_pipein(pipe);
	long done, ret;


	/* Control message is for the HUB? */
	if (devnum == rh_devnum)
		return isp116x_submit_rh_msg(dev, pipe, buffer, len, setup);

	/* Ok, no HUB message so send the message to the device */

	/* Setup phase */
	DEBUG(("--- SETUP PHASE --------------------------------"));
	usb_settoggle(dev, epnum, 1, 0);


	ret = isp116x_submit_job(dev, pipe,
				PTD_DIR_SETUP,
				 setup, sizeof(struct devrequest), 0, USB_CNTL_TIMEOUT * 5);
	if (ret < 0)
	{
		DEBUG(("control setup phase error (ret = %ld", ret));
		return -1;
	}

	/* Data phase */
	DEBUG(("--- DATA PHASE ---------------------------------"));
	done = 0;
	usb_settoggle(dev, epnum, !dir_in, 1);
	while (done < len)
	{
		ret = isp116x_submit_job(dev, pipe,
					 dir_in ? PTD_DIR_IN : PTD_DIR_OUT,
					 (unsigned char *) buffer + done,
					 max > len - done ? len - done : max, 0, USB_CNTL_TIMEOUT * 5);
		if (ret < 0)
		{
			DEBUG(("control data phase error (ret = %ld)", ret));
			return -1;
		}
		done += ret;

		if (dir_in && ret < max)	/* short packet */
			break;
	}

	/* Status phase */
	DEBUG(("--- STATUS PHASE -------------------------------"));
	usb_settoggle(dev, epnum, !dir_in, 1);
	ret = isp116x_submit_job(dev, pipe,
				 !dir_in ? PTD_DIR_IN : PTD_DIR_OUT, NULL, 0, 0, USB_CNTL_TIMEOUT * 5);
	if (ret < 0)
	{
		DEBUG(("control status phase error (ret = %ld", ret));
		return -1;
	}

	dev->act_len = done;

	dump_msg(dev, pipe, buffer, len, "DEV(ret)");

	return done;
}

long
submit_bulk_msg(struct usb_device *dev, unsigned long pipe, void *buffer,
		long len, long flags, unsigned long timeout)
{
	long dir_out = usb_pipeout(pipe);
	long max = max_transfer_len(dev, pipe);
	long done, ret;

	DEBUG(("--- BULK ---------------------------------------"));
	DEBUG(("dev=%ld pipe=%ld buf=0x%p size=%ld dir_out=%ld",
		usb_pipedevice(pipe), usb_pipeendpoint(pipe), buffer, len, dir_out));
	done = 0;
	while (done < len)
	{

		ret = isp116x_submit_job(dev, pipe,
					 !dir_out ? PTD_DIR_IN : PTD_DIR_OUT,
					 (unsigned char *) buffer + done,
					 max > len - done ? len - done : max, flags, timeout);

		if (ret < 0)
		{
			DEBUG(("error on bulk message (ret = %ld)", ret));
			return -1;
		}

		done += ret;

		if (!dir_out && ret < max)	/* short packet */
			break;
	}

	dev->act_len = done;

	return 0;
}


/* --- Basic functions ----------------------------------------------------- */


# if 0
/* GALVEZ: Test function */
static long GALVEZ_test_function( struct isp116x *isp116x )
{
	short rwc;

	rwc = isp116x_read_reg16(isp116x, HCCONTROL) & HCCONTROL_RWC;
	if (rwc)
	{
		INFO ("remote wake-up supported \n\r");
	}
	return 0;

}
# endif

static long
isp116x_sw_reset(struct isp116x *isp116x)
{
	long retries = 15;
	long ret = 0;

	isp116x->disabled = 1;

	isp116x_write_reg16(isp116x, HCSWRES, HCSWRES_MAGIC);
	isp116x_write_reg32(isp116x, HCCMDSTAT, HCCMDSTAT_HCR);

	while (--retries)
	{
		/* It usually resets within 1 ms */
		/* GALVEZ: not enough for TOS, try 7 ms */
		mdelay(7);
		if (!(isp116x_read_reg32(isp116x, HCCMDSTAT) & HCCMDSTAT_HCR))
			break;
	}

	if (!retries)
	{
		DEBUG(("software reset timeout"));
		ret = -1;
	}

# if 0
	/* GALVEZ: DEBUG SOFTWARE RESET */

	retries = 5000;

	while (--retries){
		if ((isp116x_read_reg32(isp116x, HCCMDSTAT) & HCCMDSTAT_HCR)) {
			INFO ("HCR: 1 retries: %d\n\r",retries);
		}
	}
# endif /* END DEBUG */

	return ret;
}

static long
isp116x_reset(struct isp116x *isp116x)
{
	unsigned long t;
	unsigned short clkrdy = 0;
	long ret, timeout = 15;/* ms
				* Galvez: 15 ms sometimes isn't enough,
				* for EtherNat under TOS ??????? increased to 150 ms
				*/

	ret = isp116x_sw_reset(isp116x);

	if (ret)
		return ret;

	for (t = 0; t < timeout; t++)
	{
		clkrdy = isp116x_read_reg16(isp116x, HCuPINT) & HCuPINT_CLKRDY;
		if (clkrdy)
			break;
		mdelay(1);
	}
	if (!clkrdy)
	{
		ALERT(("clock not ready after %ldms", timeout));
		/* After sw_reset the clock won't report to be ready, if
		   H_WAKEUP pin is high. */
		DEBUG(("please make sure that the H_WAKEUP pin is pulled low!"));
		ret = -1;
	}
	return ret;
}

static void
isp116x_stop(struct isp116x *isp116x)
{
	unsigned long val;

#if 1
	/* EtherNAT control register, disable interrupt for USB */
	*VTTUSB_CPLD_CR = (*VTTUSB_CPLD_CR) & ~VTTUSB_INTMASK;
#endif
	isp116x_write_reg16(isp116x, HCuPINTENB, 0);

	/* Switch off ports' power, some devices don't come up
	   after next 'start' without this */
	val = isp116x_read_reg32(isp116x, HCRHDESCA);
	val &= ~(RH_A_NPS | RH_A_PSM);
	isp116x_write_reg32(isp116x, HCRHDESCA, val);
	isp116x_write_reg32(isp116x, HCRHSTATUS, RH_HS_LPS);

	isp116x_sw_reset(isp116x);
}

#ifndef TOSONLY
#ifdef VTTUSB_HW_INT

static void
int_handle_tophalf(PROC *process, long arg)
{
	struct isp116x *isp116x = &isp116x_dev;

	if (isp116x->rhport[0] & RH_PS_CSC)
	{
		mdelay(10);
		usb_rh_wakeup(&vttusb_uif);
	}

	if (isp116x->rhport[1] & RH_PS_CSC)
	{
		mdelay(10);
		usb_rh_wakeup(&vttusb_uif);
	}

}

#else // !VTTUSB_HW_INT

void vttusb_hub_poll_thread(void *);
void vttusb_hub_poll(PROC *proc, long dummy);

void
vttusb_hub_poll(PROC *proc, long dummy)
{
	wake(WAIT_Q, (long)&vttusb_hub_poll_thread);
}

void 
vttusb_hub_poll_thread(void *dummy)
{
	for (;;)
	{
		usb_rh_wakeup(&vttusb_uif);
		addtimeout(1500L, vttusb_hub_poll);
		sleep(WAIT_Q, (long)&vttusb_hub_poll_thread);
	}

	kthread_exit(0);
}

#endif // VTTUSB_HW_INT
#endif // TOSONLY

#ifdef VTTUSB_HW_INT
void _cdecl
vttusb_int(void)
{
	struct isp116x *isp116x = &isp116x_dev;
	unsigned short irqstat;
	unsigned long intstat;

	/* Shut out all further interrupts */
	*VTTUSB_CPLD_CR = (*VTTUSB_CPLD_CR) & ~VTTUSB_INTMASK;
	isp116x_write_reg16(isp116x, HCuPINTENB, 0);
	irqstat = isp116x_read_reg16(isp116x, HCuPINT);
	isp116x_write_reg16(isp116x, HCuPINT, irqstat);

	set_old_int_lvl();

	if (irqstat & HCuPINT_OPR)
	{
		intstat = isp116x_read_reg32(isp116x, HCINTSTAT);
		isp116x_write_reg32(isp116x, HCINTSTAT, intstat);

		if (intstat & HCINT_RHSC)
		{
			isp116x->rhstatus = isp116x_read_reg32(isp116x, HCRHSTATUS);
			isp116x->rhport[0] = isp116x_read_reg32(isp116x, HCRHPORT1);
			isp116x->rhport[1] = isp116x_read_reg32(isp116x, HCRHPORT2);

#ifndef TOSONLY
			addroottimeout (0L, int_handle_tophalf, 0x1);
#else
			//got_rhsc = 1;
#endif
		}
	}

	isp116x_write_reg16(isp116x, HCuPINTENB, HCuPINT_OPR);
	set_int_lvl6();
	/* Enable CPLD USB interrupt again */
	*VTTUSB_CPLD_CR = (*VTTUSB_CPLD_CR) | VTTUSB_INTMASK;
}
#endif // VTTUSB_HW_INT

/*
 *  Configure the chip. The chip must be successfully reset by now.
 */
static long
isp116x_start(struct isp116x *isp116x)
{
	struct isp116x_platform_data *board = isp116x->board;
	unsigned long val;

	/* Clear interrupt status and disable all interrupt sources */
	isp116x_write_reg16(isp116x, HCuPINT, 0xff);
	isp116x_write_reg16(isp116x, HCuPINTENB, 0);

	isp116x_write_reg16(isp116x, HCITLBUFLEN, ISP116x_ITL_BUFSIZE);
	isp116x_write_reg16(isp116x, HCATLBUFLEN, ISP116x_ATL_BUFSIZE);

	/* Hardware configuration */
	val = HCHWCFG_DBWIDTH(1);

	if (board->int_act_high)
		val |= HCHWCFG_INT_POL;
	if (board->int_edge_triggered)
		val |= HCHWCFG_INT_TRIGGER;
	if (board->sel15Kres)
		val |= HCHWCFG_15KRSEL;
	/* Remote wakeup won't work without working clock */
	if (board->remote_wakeup_enable)
		val |= HCHWCFG_CLKNOTSTOP;
	if (board->oc_enable)
		val |= HCHWCFG_ANALOG_OC;
	isp116x_write_reg16(isp116x, HCHWCFG, val);

	/* --- Root hub configuration */
	val = (25L << 24) & RH_A_POTPGT;
	/* AN10003_1.pdf recommends RH_A_NPS (no power switching) to
	   be always set. Yet, instead, we request individual port
	   power switching. */
	val |= RH_A_PSM;
	/* Report overcurrent per port */
	val |= RH_A_OCPM;
	isp116x_write_reg32(isp116x, HCRHDESCA, val);
	isp116x->rhdesca = isp116x_read_reg32(isp116x, HCRHDESCA);

	val = RH_B_PPCM;
	isp116x_write_reg32(isp116x, HCRHDESCB, val);
	isp116x->rhdescb = isp116x_read_reg32(isp116x, HCRHDESCB);

	val = 0;
	if (board->remote_wakeup_enable)
		val |= RH_HS_DRWE;
	isp116x_write_reg32(isp116x, HCRHSTATUS, val);
	isp116x->rhstatus = isp116x_read_reg32(isp116x, HCRHSTATUS);

	isp116x_write_reg32(isp116x, HCFMINTVL, 0x27782edf);

	/* Go operational */
	val = HCCONTROL_USB_OPER;
	if (board->remote_wakeup_enable)
		val |= HCCONTROL_RWE;
	isp116x_write_reg32(isp116x, HCCONTROL, val);

	/* Disable ports to avoid race in device enumeration */
	isp116x_write_reg32(isp116x, HCRHPORT1, RH_PS_CCS);
	isp116x_write_reg32(isp116x, HCRHPORT2, RH_PS_CCS);

#ifdef VTTUSB_HW_INT
	/* Set handler and interrupt for Root Hub Status Change */
	old_int = Setexc (0xC3, (long)interrupt);
#endif

	isp116x->intenb = HCINT_MIE | HCINT_RHSC; /* HCINT_UE */
	isp116x_write_reg32(isp116x, HCINTENB, isp116x->intenb);
	isp116x->irqenb = HCuPINT_OPR; /* HCuPINT_ATL | HCuPINT_SUSP */
	isp116x_write_reg16(isp116x, HCuPINTENB, isp116x->irqenb);
	val = isp116x_read_reg16(isp116x, HCHWCFG);
	val |= HCHWCFG_INT_ENABLE;
	isp116x_write_reg16(isp116x, HCHWCFG, val);

#if !defined(TOSONLY) && defined(VTTUSB_HW_INT)
	/* EtherNAT control register, enable interrupt for USB */
	*VTTUSB_CPLD_CR = (*VTTUSB_CPLD_CR) | VTTUSB_INTMASK;
#else
	/* EtherNAT control register, disable interrupt for USB */
	*VTTUSB_CPLD_CR = (*VTTUSB_CPLD_CR) & ~VTTUSB_INTMASK;
#endif

	/* Install polling routine instead */
#if !defined(TOSONLY) && !defined(VTTUSB_HW_INT)
	long r;
	r = kthread_create(NULL, vttusb_hub_poll_thread, NULL, NULL, "lightning");
	if (r)
	{
		/* XXX todo -> exit gracefully */
		//DEBUG((/*0000000a*/"can't create NetUSBee kernel thread"));
	}
#endif

	isp116x_show_regs(isp116x);

	isp116x->disabled = 0;

	return 0;
}

/* --- Inteface functions -------------------------------------------------- */

static long _cdecl
vttusb_open(struct ucdif *u)
{
	return E_OK;
}

static long _cdecl
vttusb_close(struct ucdif *u)
{
	return E_OK;
}

static long _cdecl
vttusb_ioctl(struct ucdif *u, short cmd, long arg)
{
	long ret = E_OK;

	switch (cmd)
	{
		case FS_INFO:
		{
			*(long *)arg = (((long)VER_MAJOR << 16) | VER_MINOR);
			break;
		}
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
						  ctrl_msg->data, ctrl_msg->size,
						  ctrl_msg->setup);
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



/* --- Init functions ------------------------------------------------------ */

long
isp116x_check_id(struct isp116x *isp116x)
{
	unsigned short val;

	val = isp116x_read_reg16(isp116x, HCCHIPID);
	DEBUG(("chip ID: %x", val));

	if ((val & HCCHIPID_MASK) != HCCHIPID_MAGIC)
	{
		ALERT(("invalid chip ID %04x", val));
		return -1;
	}

	return 0;
}

long
usb_lowlevel_init(void *dummy)
{
//	unsigned short val;

	struct isp116x *isp116x = &isp116x_dev;

	got_rhsc = rh_devnum = 0;

	/* Init device registers addr */
	isp116x->addr_reg = (unsigned short *) ISP116X_HCD_ADDR;
	isp116x->data_reg = (unsigned short *) ISP116X_HCD_DATA;

	/* Disable USB interrupt in the EtherNat board */
	*VTTUSB_CPLD_CR = (*VTTUSB_CPLD_CR) & ~VTTUSB_INTMASK;

	/* Setup specific board settings */
#ifdef ISP116X_HCD_INT_ACT_HIGH
	isp116x_board.int_act_high = 1;
#endif
#ifdef ISP116X_HCD_INT_EDGE_TRIGGERED
	isp116x_board.int_edge_triggered = 0;
#endif
#ifdef ISP116X_HCD_SEL15kRES
	isp116x_board.sel15Kres = 1;
#endif
#ifdef ISP116X_HCD_OC_ENABLE
	if (!enable_ocp) {
		/* user wants to disable overcurrent protection */
		isp116x_board.oc_enable = 0;
	} else {
		isp116x_board.oc_enable = 1;
	}
#endif
#ifdef ISP116X_HCD_REMOTE_WAKEUP_ENABLE
	isp116x_board.remote_wakeup_enable = 1;
#endif
	isp116x->board = &isp116x_board;

	/* Try to get ISP116x silicon chip ID */
	if (isp116x_check_id(isp116x) < 0)
		return (-1);

	isp116x->disabled = 1;
	isp116x->sleeping = 0;

	/* Hook a routine into the reset vector to turning off
	 * main USB interrupt in case something goes wrong.
	 * In the future if this module could be loaded/unloaded
	 * we should check that we didn't hook before
	 */
#ifndef TOSONLY	
	hook_reset_vector();
#endif

	isp116x_reset(isp116x);
	isp116x_start(isp116x);

	return 0;
}

long
usb_lowlevel_stop(void *dummy)
{
	struct isp116x *isp116x = &isp116x_dev;

	if (!isp116x->disabled)
		isp116x_stop(isp116x);

	return 0;
}

void
vttusb_probe_c(void)
{
	if (!((*VTTUSB_CPLD_CR) == (*VTTUSB_CPLD_CR)))
		return;

	found = 1;
}

#ifdef TOSONLY
int init(int argc, char **argv, char **env);

int
init(int argc, char **argv, char **env)
#else
long _cdecl init (struct kentry *, struct usb_module_api *, char **);

long
init (struct kentry *k, struct usb_module_api *uapi, char **reason)
#endif
{
	long ret;
	short sr;

#ifndef TOSONLY
	api	= uapi;
	kentry	= k;

	if (check_kentry_version())
		return -1;
#endif

	/* Check that the vTTusb card can be found */
	ret = ENSURE_SUPER;
	sr = spl7 ();
	vttusb_probe_asm();
	spl (sr);
	RESTORE_SUPER(ret);

	if(!found)
	{
		c_conws ("\n\r\033pLightning VME/ST not found!\033q\n\n\r");
		DEBUG (("Lightning VME/ST not found!"));
		return -1;
	}

	c_conws (MSG_BOOT);
	c_conws (MSG_GREET);
	
	/* Configuration of max. transfer length */
	if ((max_xfer_len < 256) || (max_xfer_len > 1023)) {
		max_xfer_len = 1023; /* maximum supported by ISP1160 */
	}
	DEBUG(("Max. USB transfer size = %d", max_xfer_len));

	/* Check for Blitter */
	use_blitter = use_blitter && HAS_BLITTER && ((Blitmode(-1) & 2)?1:0);

	DEBUG (("%s: enter init", __FILE__));

#ifdef TOSONLY
	api = get_usb_cookie();
	if (!api) {
		(void)Cconws("Lightning VME/ST failed to get _USB cookie\r\n");
		return -1;
	}

	/* for precise mdelay/udelay relative to CPU power */
	set_tos_delay();
#endif

#if defined(__mc68030__) || defined(__mc68040__) || defined(__mc68060__)
#ifdef TOSONLY
	delay_150ns = loopcount_1_msec * 15 / 100000;
	delay_300ns = loopcount_1_msec * 3 / 10000;
#else
	delay_150ns = getloops4ns(150);
	delay_300ns = getloops4ns(300);
#endif /* TOSONLY */
#endif /* (__mc68030__) || (__mc68040__) || (__mc68060__) */

	ret = ucd_register(&vttusb_uif, &root_hub_dev);
	if (ret)
	{
		DEBUG (("%s: ucd register failed!", __FILE__));
		return 1;
	}

	DEBUG (("%s: ucd register ok", __FILE__));

#ifdef TOSONLY
	c_conws("vTTusb driver installed");
	/* terminate and stay resident */
	if (isHddriverModule()) {
		c_conws(" as HDDRIVER module.\r\n");
		return 0;
	} else {
		c_conws(".\r\n");
		Ptermres(_PgmSize, 0);
	}
#endif
	return 0;
}
