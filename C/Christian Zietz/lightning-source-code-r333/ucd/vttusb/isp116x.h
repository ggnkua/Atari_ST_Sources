/*
 * Modified for Atari-EtherNat by David Gálvez. 2010 - 2011
 *
 * ISP116x register declarations and HCD data structures
 *
 * Copyright (C) 2007 Rodolfo Giometti <giometti@linux.it>
 * Copyright (C) 2007 Eurotech S.p.A. <info@eurotech.it>
 * Copyright (C) 2005 Olav Kongas <ok@artecdesign.ee>
 * Portions:
 * Copyright (C) 2004 Lothar Wassmann
 * Copyright (C) 2004 Psion Teklogix
 * Copyright (C) 2004 David Brownell
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
 */

#ifndef _VTTUSB_ISP116X_H
#define _VTTUSB_ISP116X_H

/* ------------------------------------------------------------------------- */

/* us of 1ms frame */
#define  MAX_LOAD_LIMIT		850

/* Full speed: max # of bytes to transfer for a single urb
   at a time must be < 1024 && must be multiple of 64.
   832 allows transfering 4kiB within 5 frames. */
#define MAX_TRANSFER_SIZE_FULLSPEED	832

/* Low speed: there is no reason to schedule in very big
   chunks; often the requested long transfers are for
   string descriptors containing short strings. */
#define MAX_TRANSFER_SIZE_LOWSPEED	64

/* Bytetime (us), a rough indication of how much time it
   would take to transfer a byte of useful data over USB */
#define BYTE_TIME_FULLSPEED	1
#define BYTE_TIME_LOWSPEED	20

/* Buffer sizes */
#define ISP116x_BUF_SIZE	4096
#define ISP116x_ITL_BUFSIZE	0
#define ISP116x_ATL_BUFSIZE	((ISP116x_BUF_SIZE) - 2*(ISP116x_ITL_BUFSIZE))

#define ISP116x_WRITE_OFFSET	0x80

/* --- Board settings -------------------------------------------------------*/

#define ISP116X_HCD_INT_ACT_HIGH
//#define ISP116X_HCD_INT_EDGE_TRIGGERED
#define ISP116X_HCD_SEL15kRES
#define ISP116X_HCD_OC_ENABLE
//#define ISP116X_HCD_REMOTE_WAKEUP_ENABLE

#define ISP116X_HCD_USE_UDELAY
//#define ISP116X_HCD_USE_EXTRA_DELAY

/*
 * ISP116x chips require certain delays between accesses to its
 * registers. The following timing options exist.
 *
 * 1. Configure your memory controller (the best)
 * 2. Use ndelay (easiest, poorest). For that, enable the following macro.
 *
 * Value is in microseconds.
 */
#ifdef ISP116X_HCD_USE_UDELAY
# define UDELAY		1
#endif

/*
 * On some (slowly?) machines an extra delay after data packing into
 * controller's FIFOs is required, * otherwise you may get the following
 * error:
 *
 *   uboot> usb start
 *   (Re)start USB...
 *   USB:   scanning bus for devices... isp116x: isp116x_submit_job: CTL:TIMEOUT
 *   isp116x: isp116x_submit_job: ****** FIFO not ready! ******
 *
 *         USB device not responding, giving up (status=4)
 *         isp116x: isp116x_submit_job: ****** FIFO not empty! ******
 *         isp116x: isp116x_submit_job: ****** FIFO not empty! ******
 *         isp116x: isp116x_submit_job: ****** FIFO not empty! ******
 *         3 USB Device(s) found
 *                scanning bus for storage devices... 0 Storage Device(s) found
 *
 * Value is in milliseconds.
 */
#ifdef ISP116X_HCD_USE_EXTRA_DELAY
# define EXTRA_DELAY	1	/* DEFAULT 2 */
#endif

/* --- ISP116x address registers in VTTUSB --------------------------------*/

#if defined(LIGHTNING_VME)

#ifndef __mc68030__
/* Mega STE */
#define ISP116X_HCD_ADDR	0xDF8004
#define ISP116X_HCD_DATA	0xDF8000
volatile unsigned char* const VTTUSB_CPLD_CR = (volatile unsigned char*) 0xDF8009;
#else
/* TT */
#define ISP116X_HCD_ADDR	0xFEFF8004
#define ISP116X_HCD_DATA	0xFEFF8000
volatile unsigned char* const VTTUSB_CPLD_CR = (volatile unsigned char*) 0xFEFF8009;
#endif

#elif defined(LIGHTNING_ST)
/* ST */
#define ISP116X_HCD_ADDR	0xF80004
#define ISP116X_HCD_DATA	0xF80000
volatile unsigned char* const VTTUSB_CPLD_CR = (volatile unsigned char*) 0xF80009;

#else
#error Must define LIGHTNING_VME or LIGHTNING_ST!
#endif

#define VTTUSB_INTMASK	(1u<<2)
#define VTTUSB_INTPOLL	(1u<<3)

/* --- ISP116x registers/bits ---------------------------------------------- */


#define	HCREVISION	0x00
#define	HCCONTROL	0x01
#define		HCCONTROL_HCFS	(3UL << 6)	/* host controller
						   functional state */
#define		HCCONTROL_USB_RESET	(0UL << 6)
#define		HCCONTROL_USB_RESUME	(1UL << 6)
#define		HCCONTROL_USB_OPER	(2UL << 6)
#define		HCCONTROL_USB_SUSPEND	(3UL << 6)
#define		HCCONTROL_RWC	(1UL << 9)	/* remote wakeup connected */
#define		HCCONTROL_RWE	(1UL << 10)	/* remote wakeup enable */
#define	HCCMDSTAT	0x02
#define		HCCMDSTAT_HCR	(1UL << 0)	/* host controller reset */
#define		HCCMDSTAT_SOC	(3UL << 16)	/* scheduling overrun count */
#define	HCINTSTAT	0x03
#define		HCINT_SO	(1UL << 0)	/* scheduling overrun */
#define		HCINT_WDH	(1UL << 1)	/* writeback of done_head */
#define		HCINT_SF	(1UL << 2)	/* start frame */
#define		HCINT_RD	(1UL << 3)	/* resume detect */
#define		HCINT_UE	(1UL << 4)	/* unrecoverable error */
#define		HCINT_FNO	(1UL << 5)	/* frame number overflow */
#define		HCINT_RHSC	(1UL << 6)	/* root hub status change */
#define		HCINT_OC	(1UL << 30)	/* ownership change */
#define		HCINT_MIE	(1UL << 31)	/* master interrupt enable */
#define	HCINTENB	0x04
#define	HCINTDIS	0x05
#define	HCFMINTVL	0x0d
#define	HCFMREM		0x0e
#define	HCFMNUM		0x0f
#define	HCLSTHRESH	0x11
#define	HCRHDESCA	0x12
#define		RH_A_NDP	(0x3UL << 0)	/* #downstream ports */
#define		RH_A_PSM	(1UL << 8)	/* power switching mode */
#define		RH_A_NPS	(1UL << 9)	/* no power switching */
#define		RH_A_DT		(1UL << 10)	/* device type (mbz) */
#define		RH_A_OCPM	(1UL << 11)	/* overcurrent protection
						   	mode */
#define		RH_A_NOCP	(1UL << 12)	/* no overcurrent protection */
#define		RH_A_POTPGT	(0xffUL << 24)	/* power on -> power good
						   	time */
#define	HCRHDESCB	0x13
#define		RH_B_DR		(0xffffUL << 0)	/* device removable flags */
#define		RH_B_PPCM	(0xffffUL << 16)	/* port power control mask */
#define	HCRHSTATUS	0x14
#define		RH_HS_LPS	(1UL << 0)	/* local power status */
#define		RH_HS_OCI	(1UL << 1)	/* over current indicator */
#define		RH_HS_DRWE	(1UL << 15)	/* device remote wakeup
						   	enable */
#define		RH_HS_LPSC	(1UL << 16)	/* local power status change */
#define		RH_HS_OCIC	(1UL << 17)	/* over current indicator
						   	change */
#define		RH_HS_CRWE	(1UL << 31)	/* clear remote wakeup
						   	enable */
#define	HCRHPORT1	0x15
#define		RH_PS_CCS	(1UL << 0)	/* current connect status */
#define		RH_PS_PES	(1UL << 1)	/* port enable status */
#define		RH_PS_PSS	(1UL << 2)	/* port suspend status */
#define		RH_PS_POCI	(1UL << 3)	/* port over current
						   	indicator */
#define		RH_PS_PRS	(1UL << 4)	/* port reset status */
#define		RH_PS_PPS	(1UL << 8)	/* port power status */
#define		RH_PS_LSDA	(1UL << 9)	/* low speed device attached */
#define		RH_PS_CSC	(1UL << 16)	/* connect status change */
#define		RH_PS_PESC	(1UL << 17)	/* port enable status change */
#define		RH_PS_PSSC	(1UL << 18)	/* port suspend status
						   	change */
#define		RH_PS_OCIC	(1UL << 19)	/* over current indicator
						   	change */
#define		RH_PS_PRSC	(1UL << 20)	/* port reset status change */
#define		HCRHPORT_CLRMASK	(0x1f << 16)
#define	HCRHPORT2	0x16
#define	HCHWCFG		0x20
#define		HCHWCFG_15KRSEL		(1 << 12)
#define		HCHWCFG_CLKNOTSTOP	(1 << 11)
#define		HCHWCFG_ANALOG_OC	(1 << 10)
#define		HCHWCFG_DACK_MODE	(1 << 8)
#define		HCHWCFG_EOT_POL		(1 << 7)
#define		HCHWCFG_DACK_POL	(1 << 6)
#define		HCHWCFG_DREQ_POL	(1 << 5)
#define		HCHWCFG_DBWIDTH_MASK	(0x03 << 3)
#define		HCHWCFG_DBWIDTH(n)	(((n) << 3) & HCHWCFG_DBWIDTH_MASK)
#define		HCHWCFG_INT_POL		(1 << 2)
#define		HCHWCFG_INT_TRIGGER	(1 << 1)
#define		HCHWCFG_INT_ENABLE	(1 << 0)
#define	HCDMACFG	0x21
#define		HCDMACFG_BURST_LEN_MASK	(0x03 << 5)
#define		HCDMACFG_BURST_LEN(n)	(((n) << 5) & HCDMACFG_BURST_LEN_MASK)
#define		HCDMACFG_BURST_LEN_1	HCDMACFG_BURST_LEN(0)
#define		HCDMACFG_BURST_LEN_4	HCDMACFG_BURST_LEN(1)
#define		HCDMACFG_BURST_LEN_8	HCDMACFG_BURST_LEN(2)
#define		HCDMACFG_DMA_ENABLE	(1 << 4)
#define		HCDMACFG_BUF_TYPE_MASK	(0x07 << 1)
#define		HCDMACFG_CTR_SEL	(1 << 2)
#define		HCDMACFG_ITLATL_SEL	(1 << 1)
#define		HCDMACFG_DMA_RW_SELECT	(1 << 0)
#define	HCXFERCTR	0x22
#define	HCuPINT		0x24
#define		HCuPINT_SOF		(1 << 0)
#define		HCuPINT_ATL		(1 << 1)
#define		HCuPINT_AIIEOT		(1 << 2)
#define		HCuPINT_OPR		(1 << 4)
#define		HCuPINT_SUSP		(1 << 5)
#define		HCuPINT_CLKRDY		(1 << 6)
#define	HCuPINTENB	0x25
#define	HCCHIPID	0x27
#define		HCCHIPID_MASK		0xff00
#define		HCCHIPID_MAGIC		0x6100
#define	HCSCRATCH	0x28
#define	HCSWRES		0x29
#define		HCSWRES_MAGIC		0x00f6
#define	HCITLBUFLEN	0x2a
#define	HCATLBUFLEN	0x2b
#define	HCBUFSTAT	0x2c
#define		HCBUFSTAT_ITL0_FULL	(1 << 0)
#define		HCBUFSTAT_ITL1_FULL	(1 << 1)
#define		HCBUFSTAT_ATL_FULL	(1 << 2)
#define		HCBUFSTAT_ITL0_DONE	(1 << 3)
#define		HCBUFSTAT_ITL1_DONE	(1 << 4)
#define		HCBUFSTAT_ATL_DONE	(1 << 5)
#define	HCRDITL0LEN	0x2d
#define	HCRDITL1LEN	0x2e
#define	HCITLPORT	0x40
#define	HCATLPORT	0x41

/* PTD accessor macros. */
#define PTD_GET_COUNT(p)	(((p)->count & PTD_COUNT_MSK) >> 0)
#define PTD_COUNT(v)		(((v) << 0) & PTD_COUNT_MSK)
#define PTD_GET_TOGGLE(p)	(((p)->count & PTD_TOGGLE_MSK) >> 10)
#define PTD_TOGGLE(v)		(((v) << 10) & PTD_TOGGLE_MSK)
#define PTD_GET_ACTIVE(p)	(((p)->count & PTD_ACTIVE_MSK) >> 11)
#define PTD_ACTIVE(v)		(((v) << 11) & PTD_ACTIVE_MSK)
#define PTD_GET_CC(p)		(((p)->count & PTD_CC_MSK) >> 12)
#define PTD_CC(v)		(((v) << 12) & PTD_CC_MSK)
#define PTD_GET_MPS(p)		(((p)->mps & PTD_MPS_MSK) >> 0)
#define PTD_MPS(v)		(((v) << 0) & PTD_MPS_MSK)
#define PTD_GET_SPD(p)		(((p)->mps & PTD_SPD_MSK) >> 10)
#define PTD_SPD(v)		(((v) << 10) & PTD_SPD_MSK)
#define PTD_GET_LAST(p)		(((p)->mps & PTD_LAST_MSK) >> 11)
#define PTD_LAST(v)		(((v) << 11) & PTD_LAST_MSK)
#define PTD_GET_EP(p)		(((p)->mps & PTD_EP_MSK) >> 12)
#define PTD_EP(v)		(((v) << 12) & PTD_EP_MSK)
#define PTD_GET_LEN(p)		(((p)->len & PTD_LEN_MSK) >> 0)
#define PTD_LEN(v)		(((v) << 0) & PTD_LEN_MSK)
#define PTD_GET_DIR(p)		(((p)->len & PTD_DIR_MSK) >> 10)
#define PTD_DIR(v)		(((v) << 10) & PTD_DIR_MSK)
#define PTD_GET_B5_5(p)		(((p)->len & PTD_B5_5_MSK) >> 13)
#define PTD_B5_5(v)		(((v) << 13) & PTD_B5_5_MSK)
#define PTD_GET_FA(p)		(((p)->faddr & PTD_FA_MSK) >> 0)
#define PTD_FA(v)		(((v) << 0) & PTD_FA_MSK)
#define PTD_GET_FMT(p)		(((p)->faddr & PTD_FMT_MSK) >> 7)
#define PTD_FMT(v)		(((v) << 7) & PTD_FMT_MSK)

/*  Hardware transfer status codes -- CC from ptd->count */
#define TD_CC_NOERROR      0x00
#define TD_CC_CRC          0x01
#define TD_CC_BITSTUFFING  0x02
#define TD_CC_DATATOGGLEM  0x03
#define TD_CC_STALL        0x04
#define TD_DEVNOTRESP      0x05
#define TD_PIDCHECKFAIL    0x06
#define TD_UNEXPECTEDPID   0x07
#define TD_DATAOVERRUN     0x08
#define TD_DATAUNDERRUN    0x09
    /* 0x0A, 0x0B reserved for hardware */
#define TD_BUFFEROVERRUN   0x0C
#define TD_BUFFERUNDERRUN  0x0D
    /* 0x0E, 0x0F reserved for HCD */
#define TD_NOTACCESSED     0x0F

/* ------------------------------------------------------------------------- */

#define	LOG2_PERIODIC_SIZE	5	/* arbitrary; this matches OHCI */
#define	PERIODIC_SIZE		(1 << LOG2_PERIODIC_SIZE)

/* Philips transfer descriptor */
struct ptd {
	unsigned short count;
#define	PTD_COUNT_MSK	(0x3ff << 0)
#define	PTD_TOGGLE_MSK	(1 << 10)
#define	PTD_ACTIVE_MSK	(1 << 11)
#define	PTD_CC_MSK	(0xf << 12)
	unsigned short mps;
#define	PTD_MPS_MSK	(0x3ff << 0)
#define	PTD_SPD_MSK	(1 << 10)
#define	PTD_LAST_MSK	(1 << 11)
#define	PTD_EP_MSK	(0xf << 12)
	unsigned short len;
#define	PTD_LEN_MSK	(0x3ff << 0)
#define	PTD_DIR_MSK	(3 << 10)
#define	PTD_DIR_SETUP	(0)
#define	PTD_DIR_OUT	(1)
#define	PTD_DIR_IN	(2)
#define	PTD_B5_5_MSK	(1 << 13)
	unsigned short faddr;
#define	PTD_FA_MSK	(0x7f << 0)
#define	PTD_FMT_MSK	(1 << 7)
} __attribute__ ((packed, aligned(2)));

struct isp116x_ep
{
	struct usb_device *udev;
	struct ptd ptd;

	unsigned char maxpacket;
	unsigned char epnum;
	unsigned char nextpid;

	unsigned short length;		/* of current packet */
	unsigned char *data;	/* to databuf */

	unsigned short error_count;
};

/* URB struct */
#define N_URB_TD		48
#define URB_DEL			1
typedef struct
{
	struct isp116x_ep *ed;
	void *transfer_buffer;	/* (in) associated data buffer */
	long actual_length;	/* (return) actual transfer length */
	unsigned long pipe;	/* (in) pipe information */
#if 0
	long state;
#endif
} urb_priv_t;

struct isp116x_platform_data
{
	/* Enable internal resistors on downstream ports */
	unsigned sel15Kres:1;
	/* On-chip overcurrent detection */
	unsigned oc_enable:1;
	/* Enable wakeup by devices on usb bus (e.g. wakeup
	   by attachment/detachment or by device activity
	   such as moving a mouse). When chosen, this option
	   prevents stopping internal clock, increasing
	   thereby power consumption in suspended state. */
	unsigned remote_wakeup_enable:1;
	/* INT output polarity */
	unsigned int_act_high:1;
	/* INT edge or level triggered */
	unsigned int_edge_triggered:1;

};

struct isp116x
{
	unsigned short *addr_reg;
	unsigned short *data_reg;

	struct isp116x_platform_data *board;

	struct dentry *dentry;
	unsigned long stat1, stat2, stat4, stat8, stat16;

	unsigned long intenb; /* "OHCI" interrupts */
	unsigned short irqenb; /* uP interrupts */

	/* Status flags */
	unsigned disabled:1;
	unsigned sleeping:1;

	/* Root hub registers */
	unsigned long rhdesca;
	unsigned long rhdescb;
	unsigned long rhstatus;
	unsigned long rhport[2];

	/* Schedule for the current frame */
	struct isp116x_ep *atl_active;
	long atl_buflen;
	long atl_bufshrt;
	long atl_last_dir;
	long atl_finishing;
};

/* ------------------------------------------------- */

/* Inter-io delay (ns). The chip is picky about access timings; it
 * expects at least:
 * 150ns delay between consecutive accesses to DATA_REG,
 * 300ns delay between access to ADDR_REG and DATA_REG
 * OE, WE MUST NOT be changed during these intervals
 */
#if defined(UDELAY)
# define	isp116x_delay(h,d)	udelay(d)
#else
# define	isp116x_delay(h,d)	do {} while (0)
#endif

/* ISP116x registers access */

static inline void write_le16_reg(volatile unsigned short * addr, short val);
static inline unsigned read_le16_reg(const volatile unsigned short *addr);

static inline void write_le16_reg(volatile unsigned short * addr, short val)
{
	*addr = SWAP16(val);
}

static inline unsigned read_le16_reg(const volatile unsigned short *addr)
{
	unsigned result = *addr;
	return SWAP16(result);
}

# define readw(addr)	(*(volatile unsigned short *)(addr))
# define writew(w,addr)	((*(volatile unsigned short *) (addr)) = (w))
# define raw_readw(addr)		read_le16_reg((volatile unsigned short *)(addr))
# define raw_writew(b,addr)		write_le16_reg((volatile unsigned short *)(addr),(b))


static inline void isp116x_write_addr(struct isp116x *isp116x, unsigned reg)
{
	raw_writew(reg & 0xff, isp116x->addr_reg );
	//isp116x_delay(isp116x, UDELAY);
}

static inline void isp116x_write_data16(struct isp116x *isp116x, unsigned short val)
{
	writew(val, isp116x->data_reg);
	//isp116x_delay(isp116x, UDELAY);
}

static inline void isp116x_raw_write_data16(struct isp116x *isp116x, unsigned short val)
{
	raw_writew(val, isp116x->data_reg);
	//isp116x_delay(isp116x, UDELAY);
}

static inline unsigned short isp116x_read_data16(struct isp116x *isp116x)
{
	unsigned short val;

	val = readw(isp116x->data_reg);
	//isp116x_delay(isp116x, UDELAY);

	return val;
}

static inline unsigned short isp116x_raw_read_data16(struct isp116x *isp116x)
{
	unsigned short val;

	val = raw_readw(isp116x->data_reg);
	//isp116x_delay(isp116x, UDELAY);

	return val;
}


static inline void isp116x_write_data32(struct isp116x *isp116x, unsigned long val)
{
	writew(val & 0xffff, isp116x->data_reg);
	//isp116x_delay(isp116x, UDELAY);
	writew(val >> 16, isp116x->data_reg);
	//isp116x_delay(isp116x, UDELAY);
}

/*
 * Added for EtherNat, to write HC registers without swapping them
 * EtherNat already swap them by hardware (i suppose.....)
 */
static inline void isp116x_raw_write_data32(struct isp116x *isp116x, unsigned long val)
{
	raw_writew(val & 0xffff, isp116x->data_reg);
	//isp116x_delay(isp116x, UDELAY);
	raw_writew(val >> 16, isp116x->data_reg);
	//isp116x_delay(isp116x, UDELAY);
}
/***********************************************/

static inline unsigned long isp116x_read_data32(struct isp116x *isp116x)
{
	unsigned long val;

	val = (unsigned long) readw(isp116x->data_reg);
	//isp116x_delay(isp116x, UDELAY);
	val |= ((unsigned long) readw(isp116x->data_reg)) << 16;
	//isp116x_delay(isp116x, UDELAY);

	return val;
}

/*
 * Added for EtherNat, to read HC registers without swapping them
 * EtherNat already swap them by hardware (i suppose.....)
 */
static inline unsigned long isp116x_raw_read_data32(struct isp116x *isp116x)
{
	unsigned long val;

	val = (unsigned long) raw_readw(isp116x->data_reg);
	//isp116x_delay(isp116x, UDELAY);
	val |= ((unsigned long) raw_readw(isp116x->data_reg)) << 16;
	//isp116x_delay(isp116x, UDELAY);

	return val;
}
/*******************************************************************/

static inline unsigned short isp116x_read_reg16(struct isp116x *isp116x, unsigned reg)
{
	isp116x_write_addr(isp116x, reg);
	return isp116x_raw_read_data16(isp116x);
}

static inline unsigned long isp116x_read_reg32(struct isp116x *isp116x, unsigned long reg)
{
	isp116x_write_addr(isp116x, reg);
	return isp116x_raw_read_data32(isp116x);
}

static inline void isp116x_write_reg16(struct isp116x *isp116x, unsigned reg,
				unsigned val)
{
	isp116x_write_addr(isp116x, reg | ISP116x_WRITE_OFFSET);
	isp116x_raw_write_data16(isp116x, (unsigned short) (val & 0xffff));
}

/* with Etehrnat used raw_write to avoid swapping bytes by software */
static inline void isp116x_write_reg32(struct isp116x *isp116x, unsigned long reg,
				unsigned long val)
{
	isp116x_write_addr(isp116x, reg | ISP116x_WRITE_OFFSET);
	isp116x_raw_write_data32(isp116x, (unsigned long) val);
}

/* --- USB HUB constants (not OHCI-specific; see hub.h) -------------------- */

/* destination of request */
#define RH_INTERFACE               0x01
#define RH_ENDPOINT                0x02
#define RH_OTHER                   0x03

#define RH_CLASS                   0x20
#define RH_VENDOR                  0x40

/* Requests: bRequest << 8 | bmRequestType */
#define RH_GET_STATUS           0x0080
#define RH_CLEAR_FEATURE        0x0100
#define RH_SET_FEATURE          0x0300
#define RH_SET_ADDRESS          0x0500
#define RH_GET_DESCRIPTOR       0x0680
#define RH_SET_DESCRIPTOR       0x0700
#define RH_GET_CONFIGURATION    0x0880
#define RH_SET_CONFIGURATION    0x0900
#define RH_GET_STATE            0x0280
#define RH_GET_INTERFACE        0x0A80
#define RH_SET_INTERFACE        0x0B00
#define RH_SYNC_FRAME           0x0C80
/* Our Vendor Specific Request */
#define RH_SET_EP               0x2000

/* Hub port features */
#define RH_PORT_CONNECTION         0x00
#define RH_PORT_ENABLE             0x01
#define RH_PORT_SUSPEND            0x02
#define RH_PORT_OVER_CURRENT       0x03
#define RH_PORT_RESET              0x04
#define RH_PORT_POWER              0x08
#define RH_PORT_LOW_SPEED          0x09

#define RH_C_PORT_CONNECTION       0x10
#define RH_C_PORT_ENABLE           0x11
#define RH_C_PORT_SUSPEND          0x12
#define RH_C_PORT_OVER_CURRENT     0x13
#define RH_C_PORT_RESET            0x14

/* Hub features */
#define RH_C_HUB_LOCAL_POWER       0x00
#define RH_C_HUB_OVER_CURRENT      0x01

#define RH_DEVICE_REMOTE_WAKEUP    0x00
#define RH_ENDPOINT_STALL          0x01

#define RH_ACK                     0x01
#define RH_REQ_ERR                 -1
#define RH_NACK                    0x00

#endif /* _VTTUSB_ISP116X_H */
