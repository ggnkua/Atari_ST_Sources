/*-
 * Copyright (c) 2007-2008, Juniper Networks, Inc.
 * Copyright (c) 2008, Michael Trimarchi <trimarchimichael@yahoo.it>
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation version 2 of
 * the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#ifndef USB_EHCI_H
#define USB_EHCI_H

#if !defined(CONFIG_SYS_USB_EHCI_MAX_ROOT_PORTS)
#define CONFIG_SYS_USB_EHCI_MAX_ROOT_PORTS	5
#endif

/* (shifted) direction/type/recipient from the USB 2.0 spec, table 9.2 */
#define DeviceRequest \
	((USB_DIR_IN | USB_TYPE_STANDARD | USB_RECIP_DEVICE) << 8)

#define DeviceOutRequest \
	((USB_DIR_OUT | USB_TYPE_STANDARD | USB_RECIP_DEVICE) << 8)

#define InterfaceRequest \
	((USB_DIR_IN | USB_TYPE_STANDARD | USB_RECIP_INTERFACE) << 8)

#define EndpointRequest \
	((USB_DIR_IN | USB_TYPE_STANDARD | USB_RECIP_INTERFACE) << 8)

#define EndpointOutRequest \
	((USB_DIR_OUT | USB_TYPE_STANDARD | USB_RECIP_INTERFACE) << 8)

/*
 * Register Space.
 */
struct ehci_hccr {
	unsigned long cr_capbase;
#define HC_LENGTH(p)		(((p) >> 0) & 0x00ff)
#define HC_VERSION(p)		(((p) >> 16) & 0xffff)
	unsigned long cr_hcsparams;
#define HCS_PPC(p)		((p) & (1 << 4))
#define HCS_INDICATOR(p)	((p) & (1UL << 16)) /* Port indicators */
#define HCS_N_PORTS(p)		(((p) >> 0) & 0xf)
	unsigned long cr_hccparams;
	unsigned char cr_hcsp_portrt[8];
} __attribute__ ((packed, aligned(4)));

struct ehci_hcor {
	unsigned long or_usbcmd;
#define CMD_PARK	(1UL << 11)		/* enable "park" */
#define CMD_PARK_CNT(c)	(((c) >> 8) & 3UL)	/* how many transfers to park */
#define CMD_ASE		(1UL << 5)		/* async schedule enable */
#define CMD_LRESET	(1UL << 7)		/* partial reset */
#define CMD_IAAD	(1UL << 5)		/* "doorbell" interrupt */
#define CMD_PSE		(1UL << 4)		/* periodic schedule enable */
#define CMD_RESET	(1UL << 1)		/* reset HC not bus */
#define CMD_RUN		(1UL << 0)		/* start/stop HC */
	unsigned long or_usbsts;
#define STS_ASS		(1UL << 15)
#define STS_PSSTAT	(1UL << 14)
#define STS_RECL	(1UL << 13)
#define STS_HALT	(1UL << 12)
#define STS_IAA		(1UL << 5)
#define STS_HSE		(1UL << 4)
#define STS_FLR		(1UL << 3)
#define STS_PCD		(1UL << 2)
#define STS_USBERRINT	(1UL << 1)
#define STS_USBINT	(1UL << 0)
	unsigned long or_usbintr;
#define INTR_IAAE	(1UL << 5)
#define INTR_HSEE	(1UL << 4)
#define INTR_FLRE	(1UL << 3)
#define INTR_PCDE	(1UL << 2)
#define INTR_USBERRINTE	(1UL << 1)
#define INTR_USBINTE	(1UL << 0)
	unsigned long or_frindex;
	unsigned long or_ctrldssegment;
	unsigned long or_periodiclistbase;
	unsigned long or_asynclistaddr;
	unsigned long _reserved_[9];
	unsigned long or_configflag;
#define FLAG_CF		(1UL << 0)	/* true:  we'll support "high speed" */
	unsigned long or_portsc[CONFIG_SYS_USB_EHCI_MAX_ROOT_PORTS];
	unsigned long or_systune;
} __attribute__ ((packed, aligned(4)));

#define USBMODE		0x68		/* USB Device mode */
#define USBMODE_SDIS	(1 << 3)	/* Stream disable */
#define USBMODE_BE	(1 << 2)	/* BE/LE endiannes select */
#define USBMODE_CM_HC	(3 << 0)	/* host controller mode */
#define USBMODE_CM_IDLE	(0 << 0)	/* idle state */

#if defined CONFIG_EHCI_DESC_BIG_ENDIAN
#define	ehci_readl(x)		(*((volatile unsigned long *)(x)))
#define ehci_writel(a, b)	(*((volatile unsigned long *)(a)) = ((volatile unsigned long)b))
#else
#define ehci_readl(x)		le2cpu32((*((volatile unsigned long *)(x))))
#define ehci_writel(a, b)	(*((volatile unsigned long *)(a)) = cpu2le32(((volatile unsigned long)b)))
#endif

#if defined CONFIG_EHCI_MMIO_BIG_ENDIAN
#define hc32_to_cpu(x)		be2cpu32((x))
#define cpu_to_hc32(x)		cpu2be32((x))
#else
#define hc32_to_cpu(x)		le2cpu32((x))
#define cpu_to_hc32(x)		cpu2le32((x))
#endif

#define EHCI_PS_WKOC_E		(1UL << 22)	/* RW wake on over current */
#define EHCI_PS_WKDSCNNT_E	(1UL << 21)	/* RW wake on disconnect */
#define EHCI_PS_WKCNNT_E	(1UL << 20)	/* RW wake on connect */
#define EHCI_PS_PO		(1UL << 13)	/* RW port owner */
#define EHCI_PS_PP		(1UL << 12)	/* RW,RO port power */
#define EHCI_PS_LS		(3UL << 10)	/* RO line status */
#define EHCI_PS_PR		(1UL << 8)	/* RW port reset */
#define EHCI_PS_SUSP		(1UL << 7)	/* RW suspend */
#define EHCI_PS_FPR		(1UL << 6)	/* RW force port resume */
#define EHCI_PS_OCC		(1UL << 5)	/* RWC over current change */
#define EHCI_PS_OCA		(1UL << 4)	/* RO over current active */
#define EHCI_PS_PEC		(1UL << 3)	/* RWC port enable change */
#define EHCI_PS_PE		(1UL << 2)	/* RW port enable */
#define EHCI_PS_CSC		(1UL << 1)	/* RWC connect status change */
#define EHCI_PS_CS		(1UL << 0)	/* RO connect status */
#define EHCI_PS_CLEAR		(EHCI_PS_OCC | EHCI_PS_PEC | EHCI_PS_CSC)

#define EHCI_PS_IS_LOWSPEED(x)	(((x) & EHCI_PS_LS) == (1 << 10))

/*
 * Schedule Interface Space.
 *
 * IMPORTANT: Software must ensure that no interface data structure
 * reachable by the EHCI host controller spans a 4K page boundary!
 *
 * Periodic transfers (i.e. isochronous and interrupt transfers) are
 * not supported.
 */

/* Queue Element Transfer Descriptor (qTD). */
struct qTD {
	/* this part defined by EHCI spec */
	unsigned long qt_next;		/* see EHCI 3.5.1 */
#define	QT_NEXT_TERMINATE	1
	unsigned long qt_altnext;		/* see EHCI 3.5.2 */
	unsigned long qt_token;		/* see EHCI 3.5.3 */
#define QT_BUFFER_CNT	5
	unsigned long qt_buffer[QT_BUFFER_CNT];		/* see EHCI 3.5.4 */
	unsigned long qt_buffer_hi[QT_BUFFER_CNT];	/* Appendix B */
	/* pad struct for 32 byte alignment */
	unsigned long unused[3];
};

/* Queue Head (QH). */
struct QH {
	unsigned long qh_link;
#define	QH_LINK_TERMINATE	1
#define	QH_LINK_TYPE_ITD	0
#define	QH_LINK_TYPE_QH		2
#define	QH_LINK_TYPE_SITD	4
#define	QH_LINK_TYPE_FSTN	6
	unsigned long qh_endpt1;
	unsigned long qh_endpt2;
	unsigned long qh_curtd;
	struct qTD qh_overlay;
	/*
	 * Add dummy fill value to make the size of this struct
	 * aligned to 32 bytes
	 */
	unsigned char fill[16];
};

struct ehci {
	void *bus;				/* Inteface with bus/platform. (ex: pci) */
	struct ucdif *controller;
	long big_endian;
	struct ehci_hccr *hccr;		/* R/O registers, not need for volatile */
	volatile struct ehci_hcor *hcor;
	struct QH *qh_list_unaligned;
	struct QH *qh_list;
	struct QH *qh_list_busaddr;
	struct QH *qh_unaligned;
	struct QH *qh;
	struct QH *qh_busaddr;
	struct qTD *td_unaligned[3];
	struct qTD *td[3];
	struct qTD *td_busaddr[3];
	unsigned long td_offset[3];
	struct descriptor *descriptor;
	long irq;
	unsigned long dma_offset;
	const char *slot_name;
	char ehci_inited;
	long rootdev;
	unsigned short portreset;
	unsigned short companion;
	char job_in_progress;
};

/* Functions prototypes */

long ehci_hcd_init(void);
long ehci_hcd_stop(void);
long ehci_alloc_ucdif(struct ucdif **);
long ehci_interrupt_handle(long, long);

/* Interface with bus/platform */

struct ehci_bus {
	long (*init)(void *);
	void (*stop)(struct ehci *);
	long (*probe)(void);
	long (*reset)(struct ehci *);
	void (*error)(struct ehci *);
	unsigned long (*getaddr)(struct ehci *, unsigned long, unsigned long *);
};

#define ehci_bus_init		ehci_bus.init
#define ehci_bus_stop		ehci_bus.stop
#define ehci_bus_probe		ehci_bus.probe
#define ehci_bus_reset		ehci_bus.reset
#define ehci_bus_error		ehci_bus.error
#define ehci_bus_getaddr	ehci_bus.getaddr

extern struct ehci_bus ehci_bus;

#endif /* USB_EHCI_H */
