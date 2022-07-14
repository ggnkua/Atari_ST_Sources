/*
 * Adapted for FreeMiNT by David Galvez 2014
 * Ported for Atari by Didier Mequignon
 *
 * Copyright (c) 2007-2008, Juniper Networks, Inc.
 * Copyright (c) 2008, Excito Elektronik i Skåne AB
 * Copyright (c) 2008, Michael Trimarchi <trimarchimichael@yahoo.it>
 *
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

#ifndef TOSONLY
#if 0
# define DEV_DEBUG
#endif
#endif

#include <stddef.h>
#ifndef TOSONLY
#include "mint/mint.h"
#endif
#include "mint/dcntl.h"
#include "mint/ssystem.h"
#include "mint/pcibios.h"

#include "../../global.h"

#ifndef TOSONLY
#include "mint/time.h"
#include "arch/timer.h"
#include "mint/mdelay.h"
#endif

#include "mint/endian.h"
#include "../../usb.h"
#include "../../usb_api.h"

#include "ehci.h"


#define VER_MAJOR	0
#define VER_MINOR	1
#define VER_STATUS

#ifdef TOSONLY
#define MSG_VERSION    "TOS"
#else
#define MSG_VERSION    "FreeMiNT"
#endif
#define MSG_BUILDDATE	__DATE__

#define MSG_BOOT	\
	"\033p EHCI USB controller driver " MSG_VERSION " \033q\r\n"

#define MSG_GREET	\
	"Ported by David Galvez.\r\n" \
	"Compiled " MSG_BUILDDATE ".\r\n\r\n"

#define MSG_MINT	\
	"\033pMiNT too old!\033q\r\n"

#define MSG_FAILURE	\
	"\7\r\nSorry, failed!\r\n\r\n"

/*
 * kernel interface
 */

#ifndef TOSONLY
struct kentry	*kentry;
struct ucdinfo	*uinf;
#else
extern unsigned long _PgmSize;
extern void cpush(void *base, long size);
#endif
struct usb_module_api   *api;

/*
 * USB controller interface
 */

static long _cdecl	ehci_open		(struct ucdif *);
static long _cdecl	ehci_close		(struct ucdif *);
static long _cdecl	ehci_ioctl		(struct ucdif *, short, long);

static char lname[] = "EHCI-PCI USB driver\0";

/*
 * Function prototypes
 */

void		ehci_usb_enable_interrupt	(long);
void		ehci_show_registers	(struct ehci *);
void		ehci_show_qh		(struct QH *, struct ehci *);
void		__ehci_powerup_fixup	(unsigned long *, unsigned long *);

long		submit_bulk_msg		(struct usb_device *, unsigned long, void *, long, long, unsigned long);
long		submit_control_msg	(struct usb_device *, unsigned long, void *, long, struct devrequest *);
long		submit_int_msg		(struct usb_device *, unsigned long, void *, long, long);

/*
 * Structures
 */

#if __GNUC_PREREQ(8,1)
#pragma GCC diagnostic ignored "-Wpacked-not-aligned"
#endif

struct descriptor {
	struct usb_hub_descriptor hub;
	struct usb_device_descriptor device;
	struct usb_config_descriptor config;
	struct usb_interface_descriptor interface;
	struct usb_endpoint_descriptor endpoint;
} __attribute__ ((packed));

static struct descriptor rom_descriptor = {
	{
		0x8,		/* bDescLength */
		0x29,		/* bDescriptorType: hub descriptor */
		2,		/* bNrPorts -- runtime modified */
		0,		/* wHubCharacteristics */
		10,		/* bPwrOn2PwrGood */
		0,		/* bHubCntrCurrent */
		{},		/* Device removable */
		{}		/* at most 7 ports! XXX */
	},
	{
		0x12,		/* bLength */
		1,		/* bDescriptorType: UDESC_DEVICE */
		0x0002,		/* bcdUSB: v2.0 cpu2le16(0x0200)*/
		9,		/* bDeviceClass: UDCLASS_HUB */
		0,		/* bDeviceSubClass: UDSUBCLASS_HUB */
		1,		/* bDeviceProtocol: UDPROTO_HSHUBSTT */
		64,		/* bMaxPacketSize: 64 bytes */
		0x0000,		/* idVendor */
		0x0000,		/* idProduct */
		0x0001,		/* bcdDevice cpu2le16(0x0100)*/
		1,		/* iManufacturer */
		2,		/* iProduct */
		0,		/* iSerialNumber */
		1		/* bNumConfigurations: 1 */
	},
	{
		0x9,
		2,		/* bDescriptorType: UDESC_CONFIG */
		(0x19 << 8),	/* cpu_to_le16(0x19), */
		1,		/* bNumInterface */
		1,		/* bConfigurationValue */
		0,		/* iConfiguration */
		0x40,		/* bmAttributes: UC_SELF_POWER */
		0		/* bMaxPower */
	},
	{
		0x9,		/* bLength */
		4,		/* bDescriptorType: UDESC_INTERFACE */
		0,		/* bInterfaceNumber */
		0,		/* bAlternateSetting */
		1,		/* bNumEndpoints */
		9,		/* bInterfaceClass: UICLASS_HUB */
		0,		/* bInterfaceSubClass: UISUBCLASS_HUB */
		0,		/* bInterfaceProtocol: UIPROTO_HSHUBSTT */
		0		/* iInterface */
	},
	{
		0x7,		/* bLength */
		5,		/* bDescriptorType: UDESC_ENDPOINT */
		0x81,		/* bEndpointAddress: UE_DIR_IN | EHCI_INTR_ENDPT */
		3,		/* bmAttributes: UE_INTERRUPT */
		8, 0,		/* wMaxPacketSize */
		255		/* bInterval */
	},
};

#ifdef TOSONLY
/* Global variables for tosdelay.c. Should be defined here to avoid
 * "multiple definition" errors from the linker with -fno-common.
 */
unsigned long loopcount_1_msec;
unsigned long delay_1usec;
#endif

#if defined(CONFIG_EHCI_IS_TDI)
#define ehci_is_TDI()	(1)
#else
#define ehci_is_TDI()	(0)
#endif

/*
 * Debug functions
 */

void ehci_show_registers(struct ehci *gehci)
{
	int i = gehci->descriptor->hub.bNbrPorts;

	DEBUG(("--- REGISTERS ---"));
	DEBUG(("[CAPBAS] %08lx", ehci_readl(&gehci->hccr->cr_capbase)));
	DEBUG(("[HCSPAR] %08lx", ehci_readl(&gehci->hccr->cr_hcsparams)));
	DEBUG(("[HCCPAR] %08lx", ehci_readl(&gehci->hccr->cr_hccparams)));

	while (i) {
		unsigned long *ptr = (unsigned long *)&gehci->hccr->cr_hcsp_portrt[i - 1];
		(void)ptr;
		
		DEBUG(("capability reg port[%d] 0x%08lx", 
			i, ehci_readl(ptr)));
		i--;
	};

	DEBUG(("[USBCMD] %08lx", ehci_readl(&gehci->hcor->or_usbcmd)));
	DEBUG(("[USBSTS] %08lx", ehci_readl(&gehci->hcor->or_usbsts)));
	DEBUG(("[USBINR] %08lx", ehci_readl(&gehci->hcor->or_usbintr)));
	DEBUG(("[FRIDNX] %08lx", ehci_readl(&gehci->hcor->or_frindex)));
	DEBUG(("[CTRLDS] %08lx", ehci_readl(&gehci->hcor->or_ctrldssegment)));
	DEBUG(("[PERDLB] %08lx", ehci_readl(&gehci->hcor->or_periodiclistbase)));
	DEBUG(("[ASYNCL] %08lx", ehci_readl(&gehci->hcor->or_asynclistaddr)));
	DEBUG(("[CNFLAG] %08lx", ehci_readl(&gehci->hcor->or_configflag)));
	i = gehci->descriptor->hub.bNbrPorts;
	while (i) {
		DEBUG(("status reg port[%d] 0x%08lx", 
			i, ehci_readl(&gehci->hcor->or_portsc[i - 1])));
		i--;
	};
	DEBUG(("[SYSTUN] %08lx", ehci_readl(&gehci->hcor->or_systune)));
}

void ehci_show_qh(struct QH *qh, struct ehci *gehci)
{
	DEBUG(("--- QUEUE HEAD ---"));
	DEBUG(("[0x%08lx] %08lx", ((unsigned long)qh) + 0, hc32_to_cpu(qh->qh_link)));
	DEBUG(("[0x%08lx] %08lx", ((unsigned long)qh) + 4, hc32_to_cpu(qh->qh_endpt1)));
	DEBUG(("[0x%08lx] %08lx", ((unsigned long)qh) + 8, hc32_to_cpu(qh->qh_endpt2)));
	DEBUG(("[0x%08lx] %08lx - current qTD", ((unsigned long)qh) + 12, hc32_to_cpu(qh->qh_curtd)));
	DEBUG(("[0x%08lx] %08lx - next qtd", ((unsigned long)qh) + 16, hc32_to_cpu(qh->qh_overlay.qt_next)));
	DEBUG(("[0x%08lx] %08lx", ((unsigned long)qh) + 20, hc32_to_cpu(qh->qh_overlay.qt_altnext)));
	DEBUG(("[0x%08lx] %08lx - token", ((unsigned long)qh) + 24, hc32_to_cpu(qh->qh_overlay.qt_token)));
	DEBUG(("[0x%08lx] %08lx - buffer", ((unsigned long)qh) + 28, hc32_to_cpu(qh->qh_overlay.qt_buffer[0])));

	if (qh->qh_curtd != 0) {
		DEBUG(("--- current qTD ---"));
		DEBUG(("[0x%08lx] [0x%08lx]- next qTD", 
					hc32_to_cpu(qh->qh_curtd + gehci->dma_offset), 
					hc32_to_cpu(qh->qh_curtd)));
		DEBUG(("[0x%08lx] %08lx", 
					(((unsigned long)hc32_to_cpu(qh->qh_curtd)) + 4), 
					hc32_to_cpu(*(((unsigned long *)hc32_to_cpu(qh->qh_curtd)) + 1))));
		DEBUG(("[0x%08lx] %08lx - token", 
					(((unsigned long)hc32_to_cpu(qh->qh_curtd)) + 8), 
					hc32_to_cpu(*(((unsigned long *)hc32_to_cpu(qh->qh_curtd)) + 2))));
		DEBUG(("[0x%08lx] %08lx - buffer", 
					(((unsigned long)hc32_to_cpu(qh->qh_curtd)) + 12), 
					hc32_to_cpu(*(((unsigned long *)hc32_to_cpu(qh->qh_curtd)) + 3))));
	}
}

/*
 * Cache functions
 */

/*
 * The kernel doesn't export a function in kentry to invalidate
 * caches, so until then we have our own function here. Also
 * we're lazy and for now we invalidate the entire data cache.
 */
static inline void invalidate_dcache(void)
{
#ifdef __mcoldfire__
	s_system(S_CTRLCACHE, CTRLCACHE_DCINVA, CTRLCACHE_DCINVA);
#endif
#if defined(__mc68040__) || defined(__mc68060__)
	asm ("cinva dc");
#endif
#ifdef __mc68030__
	/* 68030 is a writethrough data cache, so we're fine */
#endif
}

/* Function to flush the entire data cache, MiNT drivers can also
 * use the functions exported by the kernel in kentry (cpush) to
 * to flush specific areas of the cache. TOS drivers have support
 * for that function too.
 * There is only PCI hardware for machines with a 040, 060 and
 * ColdFire CPUs, so we use savely the "cpush" instruction.
 */

static void flush_dcache(void)
{
#if defined (__mc68040__) || defined(__mc68060__) || defined(__mcoldfdire__)
	asm("cpusha dc");
#else
	/* Nothing */
#endif
}


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

/*
 * EHCI functions
 */

static inline long max_transfer_len(struct ehci *gehci,void *buf)
{
	unsigned long maxlen, first_page_offset;
	unsigned long addr;
	long r;

	r = ehci_bus_getaddr(gehci, (unsigned long)buf, &addr);
	if (r < 0)
	{
		DEBUG(("EHCI_HCD: Unable to get bus address"));
		return -1;
	}

	/* One qTD can transfer 5 * 4K, but this is with a perfect 4k aligment,
	 * note that only the first 4k page is allowed to be unaligned.
	 */
	maxlen = 5 * 4096;
	first_page_offset = addr & 4095;
	maxlen -= first_page_offset;

	/*
	 * In order to keep each USB packet within a qTD transfer,
	 * align the qTD transfer size to 512 bytes.
	 */
	maxlen &= ~(512 - 1);

	return maxlen;
}

void __ehci_powerup_fixup(unsigned long *status_reg, unsigned long *reg)
{
	mdelay(50);
}
void ehci_powerup_fixup(unsigned long *status_reg, unsigned long *reg)
	__attribute__((weak, alias("__ehci_powerup_fixup")));

static long handshake(unsigned long *ptr, unsigned long mask, unsigned long done, long usec)
{
	unsigned long result;
	do
	{
		result = ehci_readl(ptr);
		udelay(5);
		if(result == ~(unsigned long)0)
			return -1;
		result &= mask;
		if(result == done)
			return 0;
		usec--;
	}
	while(usec > 0);
	return -1;
}

static long ehci_reset(struct ehci *gehci)
{
	unsigned long cmd;
	unsigned long tmp;
	unsigned long *reg_ptr;
	long ret = 0;

	ehci_bus_reset(gehci);

	cmd = ehci_readl(&gehci->hcor->or_usbcmd);
	cmd = (cmd & ~CMD_RUN) | CMD_RESET;
	ehci_writel(&gehci->hcor->or_usbcmd, cmd);
	ret = handshake((unsigned long *)&gehci->hcor->or_usbcmd, CMD_RESET, 0, 250L * 1000L);
	if(ret < 0)
	{
		ALERT(("EHCI fail to reset"));
		goto out;
	}
	if(ehci_is_TDI())
	{
		reg_ptr = (unsigned long *)((unsigned char *)gehci->hcor + USBMODE);
		tmp = ehci_readl(reg_ptr);
		tmp |= USBMODE_CM_HC;
#if defined(CONFIG_EHCI_MMIO_BIG_ENDIAN)
		tmp |= USBMODE_BE;
#endif
		ehci_writel(reg_ptr, tmp);
	}
out:
	return ret;
}

static void *ehci_alloc(struct ehci *gehci, size_t sz, size_t align, unsigned long *td_offset)
{
	static long ntds;
	void *p;
	switch(sz)
	{
		case sizeof(struct QH):
			p = gehci->qh;
			ntds = 0;
			break;
		case sizeof(struct qTD):
			if(ntds == 3)
			{
				DEBUG(("out of TDs"));
				return NULL;
			}
			p = gehci->td[ntds];
			*td_offset = gehci->td_offset[ntds];
			ntds++;
			break;
		default:
			DEBUG(("unknown allocation size"));
			return NULL;
	}
	memset(p, 0, sz);
	return p;
}

static long ehci_td_buffer(struct ehci *gehci, struct qTD *td, void *buf, size_t sz)
{
	unsigned long delta, next;
	unsigned long addr;
	long idx, r;

	r = ehci_bus_getaddr(gehci, (unsigned long)buf, &addr);
	if (r < 0)
	{
		DEBUG(("EHCI_HCD: Unable to get bus address"));
		return -1;
	}

	if (addr & (M68K_CACHE_LINE_SIZE - 1))
		DEBUG(("EHCI-HCD: Misaligned buffer address (0x%08lx)", (unsigned long)buf));

	cpush(buf, sz);

	idx = 0;
	while(idx < 5)
	{
		td->qt_buffer[idx] = cpu_to_hc32(addr);
		next = (addr + 4096) & ~4095;
		delta = next - addr;
		if (delta >= sz)
			break;
		sz -= delta;
		addr = next;
		idx++;
	}
	if(idx == 5)
	{
		DEBUG(("out of buffer pointers (%lu bytes left)", sz));
		return -1;
	}
	return 0;
}

static inline unsigned char ehci_encode_speed(enum usb_device_speed speed)
{
	#define QH_HIGH_SPEED	2
	#define QH_FULL_SPEED	0
	#define QH_LOW_SPEED	1
	if (speed == USB_SPEED_HIGH)
		return QH_HIGH_SPEED;
	if (speed == USB_SPEED_LOW)
		return QH_LOW_SPEED;
	return QH_FULL_SPEED;
}

static long ehci_submit_async(struct usb_device *dev, unsigned long pipe, void *buffer, long length, struct devrequest *req, unsigned long timeout)
{
	struct QH *qh;
	struct qTD *td;
	volatile struct qTD *vtd;
	unsigned long ts;
	unsigned long *tdp;
	unsigned long endpt, token, usbsts;
	unsigned long c, toggle;
	unsigned long cmd;
	long ret = 0;
	unsigned long td_offset = 0;	/* make compiler happy */

	struct ehci *gehci = (struct ehci *)dev->controller->ucd_priv;

	/* Another job in progress */
	if (!lock_usb(&gehci->job_in_progress))
	{
		DEBUG(("Another USB job in progress -- must not happen"));
		dev->status = USB_ST_BUF_ERR;
		return -1;
	}

	DEBUG(("dev=0x%lx, pipe=0x%lx, buffer=0x%lx, length=%ld, req=0x%lx", (unsigned long)dev, pipe, (unsigned long)buffer, length, (unsigned long)req));
	if(req != NULL)
		DEBUG(("ehci_submit_async req=%u (0x%x), type=%u (0x%x), value=%u (0x%x), index=%u",
		req->request, req->request, req->requesttype, req->requesttype,
		le2cpu16(req->value), le2cpu16(req->value), le2cpu16(req->index)));
	qh = ehci_alloc(gehci, sizeof(struct QH), 32, &td_offset);

	if(qh == NULL)
	{
		DEBUG(("unable to allocate QH"));
		unlock_usb(&gehci->job_in_progress);
		return -1;
	}
#ifdef TOSONLY
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
#endif
	toggle = usb_gettoggle(dev, usb_pipeendpoint(pipe), usb_pipeout(pipe));

	qh->qh_link = cpu_to_hc32(((unsigned long)gehci->qh_list_busaddr) | QH_LINK_TYPE_QH);
	c = (usb_pipespeed(pipe) != USB_SPEED_HIGH && usb_pipeendpoint(pipe) == 0) ? 1 : 0;

	endpt = (8UL << 28) | (c << 27) | (usb_maxpacket(dev, pipe) << 16) |
		(0 << 15) | (1 << 14) | (ehci_encode_speed(usb_pipespeed(pipe)) << 12) |
		(usb_pipeendpoint(pipe) << 8) | (0 << 7) | (usb_pipedevice(pipe) << 0);
	qh->qh_endpt1 = cpu_to_hc32(endpt);
	endpt = (1UL << 30) | (dev->portnr << 23) | (dev->parent->devnum << 16) | (0 << 8) | (0 << 0);
	qh->qh_endpt2 = cpu_to_hc32(endpt);
	qh->qh_overlay.qt_next = cpu_to_hc32(QT_NEXT_TERMINATE);

	td = NULL;
	tdp = &qh->qh_overlay.qt_next;

	if(req != NULL)
	{
		td = ehci_alloc(gehci, sizeof(struct qTD), 32, &td_offset);
		if(td == NULL)
		{
			DEBUG(("unable to allocate SETUP td"));
			goto fail;
		}
		td->qt_next = cpu_to_hc32(QT_NEXT_TERMINATE);
		td->qt_altnext = cpu_to_hc32(QT_NEXT_TERMINATE);
		token = (0UL << 31) | (sizeof(*req) << 16) | (0 << 15) |
			(0 << 12) | (3 << 10) | (2 << 8) | (0x80 << 0);
		td->qt_token = cpu_to_hc32(token);

		if(ehci_td_buffer(gehci, td, req, sizeof(*req)) != 0)
		{
			DEBUG(("unable construct SETUP td"));
			goto fail;
		}
		*tdp = cpu_to_hc32((unsigned long)td - td_offset);
		tdp = &td->qt_next;
		toggle = 1;
	}

	if(length > 0 || req == NULL)
	{
		td = ehci_alloc(gehci, sizeof(struct qTD), 32, &td_offset);
		if(td == NULL)
		{
			DEBUG(("unable to allocate DATA td"));
			goto fail;
		}
		td->qt_next = cpu_to_hc32(QT_NEXT_TERMINATE);
		td->qt_altnext = cpu_to_hc32(QT_NEXT_TERMINATE);
		token = (toggle << 31) | (length << 16) | ((req == NULL ? 1U : 0) << 15) |
			(0 << 12) | (3 << 10) | ((usb_pipein(pipe) ? 1 : 0) << 8) | (0x80 << 0);
		td->qt_token = cpu_to_hc32(token);
		if(ehci_td_buffer(gehci, td, buffer, length) != 0)
		{
			DEBUG(("unable construct DATA td"));
			goto fail;
		}
		*tdp = cpu_to_hc32((unsigned long)td - td_offset);
		tdp = &td->qt_next;
	}

	if(req != NULL)
	{
		td = ehci_alloc(gehci, sizeof(struct qTD), 32, &td_offset);
		if(td == NULL)
		{
			DEBUG(("unable to allocate ACK td"));
			goto fail;
		}
		td->qt_next = cpu_to_hc32(QT_NEXT_TERMINATE);
		td->qt_altnext = cpu_to_hc32(QT_NEXT_TERMINATE);
		token = (toggle << 31) | (0UL << 16) | (1U << 15) | (0 << 12) |
			(3 << 10) | ((usb_pipein(pipe) ? 0 : 1) << 8) | (0x80 << 0);
		td->qt_token = cpu_to_hc32(token);
		*tdp = cpu_to_hc32((unsigned long)td - td_offset);
		tdp = &td->qt_next;
	}

	gehci->qh_list->qh_link = cpu_to_hc32(((unsigned long)gehci->qh_busaddr) | QH_LINK_TYPE_QH);
	/* Flush data cache */
	flush_dcache();
	usbsts = ehci_readl(&gehci->hcor->or_usbsts);
	ehci_writel(&gehci->hcor->or_usbsts, (usbsts & 0x3f));

	/* Enable async. schedule. */
	cmd = ehci_readl(&gehci->hcor->or_usbcmd);
	cmd |= CMD_ASE;
	ehci_writel(&gehci->hcor->or_usbcmd, cmd);
	ret = handshake((unsigned long *)&gehci->hcor->or_usbsts, STS_ASS, STS_ASS, 100L * 1000L);
	if(ret < 0)
	{
		ALERT(("EHCI fail timeout STS_ASS set (usbsts=%lx)", ehci_readl(&gehci->hcor->or_usbsts)));
		goto fail;
	}

	/* Wait for TDs to be processed. */
	ts = 0;
	vtd = td;
	do
	{
		/* Invalidate dcache */
		invalidate_dcache();
		token = hc32_to_cpu(vtd->qt_token);
		if(!(token & 0x80))
			break;
		mdelay(1);
		ts++;
	}
	while(ts < timeout);

	/* Invalidate the memory area occupied by buffer */
	/* invalidate_dcache(); */

	/* Our function to invalidate the data cache invalidates
	 * the entire cache so we don't need to invalidate the
	 * data cache again, as long as we don't invalidate
	 * "per address" we are good.
	 */


	/* Check that the TD processing happened */
	if (token & 0x80) {
		DEBUG(("EHCI timed out on TD - token=%02lx", 0xff & token));
	}

	/* Disable async schedule. */
	cmd = ehci_readl(&gehci->hcor->or_usbcmd);
	cmd &= ~CMD_ASE;
	ehci_writel(&gehci->hcor->or_usbcmd, cmd);
	ret = handshake((unsigned long *)&gehci->hcor->or_usbsts, STS_ASS, 0, 100L * 1000L);
	if(ret < 0)
	{
		ALERT(("EHCI fail timeout STS_ASS reset (usbsts=%lx)", ehci_readl(&gehci->hcor->or_usbsts)));
		goto fail;
	}

	gehci->qh_list->qh_link = cpu_to_hc32(((unsigned long)gehci->qh_list_busaddr) | QH_LINK_TYPE_QH);
	if(!(token & 0x80))
	{
		DEBUG(("TOKEN=%lx", token));
		switch(token & 0xfc)
		{
			case 0:
				toggle = token >> 31;
				usb_settoggle(dev, usb_pipeendpoint(pipe), usb_pipeout(pipe), toggle);
				dev->status = 0;
				break;
			case 0x40:
				dev->status = USB_ST_STALLED;
				break;
			case 0xa0:
			case 0x20:
				dev->status = USB_ST_BUF_ERR;
				break;
			case 0x50:
			case 0x10:
				dev->status = USB_ST_BABBLE_DET;
				break;
			default:
				dev->status = USB_ST_CRC_ERR;
				if ((token & 0x40) == 0x40)
					dev->status |= USB_ST_STALLED;
				break;
		}
		dev->act_len = length - ((token >> 16) & 0x7fff);
	}
	else
	{
		dev->act_len = 0;
		DEBUG(("dev=%ld, usbsts=0x%lx, p[1]=0x%lx, p[2]=0x%lx",
		 dev->devnum, ehci_readl(&gehci->hcor->or_usbsts), ehci_readl(&gehci->hcor->or_portsc[0]), ehci_readl(&gehci->hcor->or_portsc[1])));
	}
#ifdef TOSONLY
	if (oldmode) SuperToUser(oldmode);
#endif
	unlock_usb(&gehci->job_in_progress);
	return (dev->status != USB_ST_NOT_PROC) ? 0 : -1;
fail:
	if(ehci_readl(&gehci->hcor->or_usbsts) & STS_HSE) /* Host System Error */
	{
		ALERT(("EHCI Host System Error"));
		ehci_bus_error(gehci);
	}
#ifdef TOSONLY
	if (oldmode) SuperToUser(oldmode);
#endif
	unlock_usb(&gehci->job_in_progress);
	return -1;
}

static long ehci_submit_root(struct usb_device *dev, unsigned long pipe, void *buffer, long length, struct devrequest *req)
{
	unsigned char tmpbuf[4];
	unsigned short typeReq;
	void *srcptr = NULL;
	long len, srclen;
	unsigned long reg;
	unsigned long *status_reg;

	struct ehci *gehci = (struct ehci *)dev->controller->ucd_priv;

	if(le2cpu16(req->index) > CONFIG_SYS_USB_EHCI_MAX_ROOT_PORTS)
	{
		ALERT(("The request port(%d) is not configured", le2cpu16(req->index) - 1));
		DEBUG(("The request port(%d) is not configured", le2cpu16(req->index) - 1));
		return -1;
	}

	status_reg = (unsigned long *)&gehci->hcor->or_portsc[le2cpu16(req->index) - 1];
	srclen = 0;
	DEBUG(("ehci_submit_root req=%u (0x%x), type=%u (0x%x), value=%u, index=%u",
	 req->request, req->request, req->requesttype, req->requesttype, le2cpu16(req->value), le2cpu16(req->index)));
	typeReq = req->request | req->requesttype << 8;
	switch(typeReq)
	{
		case DeviceRequest | USB_REQ_GET_DESCRIPTOR:
			switch(le2cpu16(req->value) >> 8)
			{
				case USB_DT_DEVICE:
					DEBUG(("USB_DT_DEVICE request"));
					srcptr = &gehci->descriptor->device;
					srclen = 0x12;
					break;
				case USB_DT_CONFIG:
					DEBUG(("USB_DT_CONFIG config"));
					srcptr = &gehci->descriptor->config;
					srclen = 0x19;
					break;
				case USB_DT_STRING:
					DEBUG(("USB_DT_STRING config"));
					switch(le2cpu16(req->value) & 0xff)
					{
						case 0:	/* Language */
							srcptr = "\4\3\1\0";
							srclen = 4;
							break;
						case 1:	/* Vendor */
							srcptr = "\16\3N\0E\0C\0";
							srclen = 8;
							break;
						case 2:	/* Product */
							srcptr = "\52\3E\0H\0C\0I\0 \0H\0o\0s\0t\0 \0C\0o\0n\0t\0r\0o\0l\0l\0e\0r\0";
							srclen = 42;
							break;
						default:
							DEBUG(("unknown value DT_STRING %x",
							le2cpu16(req->value)));
							goto unknown;
					}
					break;
				default:
					DEBUG(("unknown value %x", le2cpu16(req->value)));
					goto unknown;
			}
			break;
		case USB_REQ_GET_DESCRIPTOR | ((USB_DIR_IN | USB_RT_HUB) << 8):
			switch(le2cpu16(req->value) >> 8)
			{
				case USB_DT_HUB:
					DEBUG(("USB_DT_HUB config"));
					srcptr = &gehci->descriptor->hub;
					srclen = 0x8;
					break;
				default:
					DEBUG(("unknown value %x", le2cpu16(req->value)));
					goto unknown;
			}
			break;
		case USB_REQ_SET_ADDRESS | (USB_RECIP_DEVICE << 8):
			DEBUG(("USB_REQ_SET_ADDRESS"));
			gehci->rootdev = le2cpu16(req->value);
			break;
		case DeviceOutRequest | USB_REQ_SET_CONFIGURATION:
			DEBUG(("USB_REQ_SET_CONFIGURATION"));
			/* Nothing to do */
			break;
		case USB_REQ_GET_STATUS | ((USB_DIR_IN | USB_RT_HUB) << 8):
			tmpbuf[0] = 1;	/* USB_STATUS_SELFPOWERED */
			tmpbuf[1] = 0;
			srcptr = tmpbuf;
			srclen = 2;
			break;
		case USB_REQ_GET_STATUS | ((USB_RT_PORT | USB_DIR_IN) << 8):
			memset(tmpbuf, 0, 4);
			reg = ehci_readl(status_reg);
			if(reg & EHCI_PS_CS)
				tmpbuf[0] |= USB_PORT_STAT_CONNECTION;
			if(reg & EHCI_PS_PE)
				tmpbuf[0] |= USB_PORT_STAT_ENABLE;
			if(reg & EHCI_PS_SUSP)
				tmpbuf[0] |= USB_PORT_STAT_SUSPEND;
			if(reg & EHCI_PS_OCA)
				tmpbuf[0] |= USB_PORT_STAT_OVERCURRENT;
			if (reg & EHCI_PS_PR)
				tmpbuf[0] |= USB_PORT_STAT_RESET;
			if(reg & EHCI_PS_PP)
				tmpbuf[1] |= USB_PORT_STAT_POWER >> 8;
			if(ehci_is_TDI())
			{
				switch((reg >> 26) & 3)
				{
					case 0: break;
					case 1: tmpbuf[1] |= USB_PORT_STAT_LOW_SPEED >> 8; break;
					case 2:
					default: tmpbuf[1] |= USB_PORT_STAT_HIGH_SPEED >> 8; break;
				}
			}
			else
				tmpbuf[1] |= USB_PORT_STAT_HIGH_SPEED >> 8;
			if(reg & EHCI_PS_CSC)
				tmpbuf[2] |= USB_PORT_STAT_C_CONNECTION;
			if(reg & EHCI_PS_PEC)
				tmpbuf[2] |= USB_PORT_STAT_C_ENABLE;
			if(reg & EHCI_PS_OCC)
				tmpbuf[2] |= USB_PORT_STAT_C_OVERCURRENT;
			if(gehci->portreset & (1 << le2cpu16(req->index)))
				tmpbuf[2] |= USB_PORT_STAT_C_RESET;
			srcptr = tmpbuf;
			srclen = 4;
			break;
		case USB_REQ_SET_FEATURE | ((USB_DIR_OUT | USB_RT_PORT) << 8):
			reg = ehci_readl(status_reg);
			reg &= ~EHCI_PS_CLEAR;
			switch(le2cpu16(req->value))
			{
				case USB_PORT_FEAT_ENABLE:
					reg |= EHCI_PS_PE;
					ehci_writel(status_reg, reg);
					break;
				case USB_PORT_FEAT_POWER:
					if(HCS_PPC(ehci_readl(&gehci->hccr->cr_hcsparams)))
					{
						reg |= EHCI_PS_PP;
						ehci_writel(status_reg, reg);
					}
					break;
				case USB_PORT_FEAT_RESET:
					if((reg & (EHCI_PS_PE | EHCI_PS_CS)) == EHCI_PS_CS && !ehci_is_TDI() && EHCI_PS_IS_LOWSPEED(reg))
					{
						/* Low speed device, give up ownership. */
						DEBUG(("port %d low speed --> companion", le2cpu16(req->index)));
						reg |= EHCI_PS_PO;
						ehci_writel(status_reg, reg);
						gehci->companion |= (1 << le2cpu16(req->index));
						break;
					}
					else
					{
						int ret;

						reg |= EHCI_PS_PR;
						reg &= ~EHCI_PS_PE;
						ehci_writel(status_reg, reg);
						/*
						 * caller must wait, then call GetPortStatus
						 * usb 2.0 specification say 50 ms resets on root
						 */
						ehci_powerup_fixup(status_reg, &reg);
						ehci_writel(status_reg, reg & ~EHCI_PS_PR);
						/*
						* A host controller must terminate the reset
						* and stabilize the state of the port within
						* 2 milliseconds
						*/
						ret = handshake(status_reg, EHCI_PS_PR, 0,
								2 * 1000L);
						if (!ret)
							gehci->portreset |=
								1 << le2cpu16(req->index);
						else
							ALERT(("port(%d) reset error",
								le2cpu16(req->index) - 1));
					}
					break;
				default:
					DEBUG(("unknown feature %x", le2cpu16(req->value)));
					goto unknown;
			}
			/* unblock posted writes */
			(void)ehci_readl(&gehci->hcor->or_usbcmd);
			break;
		case USB_REQ_CLEAR_FEATURE | ((USB_DIR_OUT | USB_RT_PORT) << 8):
			reg = ehci_readl(status_reg);
			switch(le2cpu16(req->value))
			{
				case USB_PORT_FEAT_ENABLE:
					reg &= ~EHCI_PS_PE;
					break;
				case USB_PORT_FEAT_C_ENABLE:
					reg = (reg & ~EHCI_PS_CLEAR) | EHCI_PS_PE;
					break;
				case USB_PORT_FEAT_POWER:
					if(HCS_PPC(ehci_readl(&gehci->hccr->cr_hcsparams)))
						reg = reg & ~(EHCI_PS_CLEAR | EHCI_PS_PP);
				case USB_PORT_FEAT_C_CONNECTION:
					reg = (reg & ~EHCI_PS_CLEAR) | EHCI_PS_CSC;
					break;
				case USB_PORT_FEAT_OVER_CURRENT:
					reg = (reg & ~EHCI_PS_CLEAR) | EHCI_PS_OCC;
					break;
				case USB_PORT_FEAT_C_RESET:
					gehci->portreset &= ~(1 << le2cpu16(req->index));
					break;
				default:
					DEBUG(("unknown feature %x", le2cpu16(req->value)));
					goto unknown;
			}
			ehci_writel(status_reg, reg);
			/* unblock posted write */
			(void)ehci_readl(&gehci->hcor->or_usbcmd);
			break;
		default:
			DEBUG(("Unknown request"));
			goto unknown;
	}
	mdelay(1);
	len = MIN3(srclen, le2cpu16(req->length), length);
	if(srcptr != NULL && len > 0)
		memcpy(buffer, srcptr, len);
	else
		DEBUG(("Len is 0"));
	dev->act_len = len;
	dev->status = 0;
	return 0;
unknown:
	DEBUG(("requesttype=%x, request=%x, value=%x, index=%x, length=%x",
	 req->requesttype, req->request, le2cpu16(req->value), le2cpu16(req->index), le2cpu16(req->length)));
	dev->act_len = 0;
	dev->status = USB_ST_STALLED;
	return -1;
}

static void hc_free_buffers(struct ehci *ehci)
{
	long i;
	if(ehci->descriptor != NULL)
	{
		kfree(ehci->descriptor);
		ehci->descriptor = NULL;
	}
	for(i = 0; i < 3; i++)
	{
		if(ehci->td_unaligned[i] != NULL)
		{
			kfree(ehci->td_unaligned[i]);
			ehci->td_unaligned[i] = NULL;
		}
	}
	if(ehci->qh_unaligned != NULL)
	{
		kfree(ehci->qh_unaligned);
		ehci->qh_unaligned = NULL;
	}
	if(ehci->qh_list_unaligned != NULL)
	{
		kfree(ehci->qh_list_unaligned);
		ehci->qh_list_unaligned = NULL;
	}
}

/*
 * Polling functions for the root hub (disable by default)
 */

#define EHCI_POLL
#if defined(EHCI_POLL) && !defined(TOSONLY)
static void ehci_hub_poll_thread(void *);
static void ehci_hub_poll(PROC *proc, long dummy);

static void ehci_hub_poll(PROC *proc, long dummy)
{
	wake(WAIT_Q, (long)&ehci_hub_poll_thread);
}

static void ehci_hub_poll_thread(void *ptr)
{
	struct ehci *gehci = (struct ehci *)ptr;
	struct ucdif *ehci_uif = gehci->controller;

	for (;;)
	{
		usb_rh_wakeup(ehci_uif);
		addtimeout(1000L, ehci_hub_poll);
		sleep(WAIT_Q, (long)&ehci_hub_poll_thread);
	}

	kthread_exit(0);
}
#endif /* EHCI_POLL && !TOSONLY */

/*
 * IOCTL functions
 */

long usb_lowlevel_init(void *ucd_priv)
{
	long i, r;
	unsigned long reg;
	unsigned long cmd;

	struct ehci *gehci = (struct ehci*)ucd_priv;

	gehci->job_in_progress = 0;

	gehci->qh_list_unaligned = (struct QH *)kmalloc(sizeof(struct QH) + 32);
	if(gehci->qh_list_unaligned == NULL)
	{
		DEBUG(("QHs malloc failed"));
		hc_free_buffers(gehci);
		return(-1);
	}
	gehci->qh_list = (struct QH *)(((unsigned long)gehci->qh_list_unaligned + 31) & ~31);
	memset(gehci->qh_list, 0, sizeof(struct QH));

	gehci->qh_unaligned = (struct QH *)kmalloc(sizeof(struct QH) + 32);
	if(gehci->qh_unaligned == NULL)
	{
		DEBUG(("QHs malloc failed"));
		hc_free_buffers(gehci);
		return(-1);
	}
	gehci->qh = (struct QH *)(((unsigned long)gehci->qh_unaligned + 31) & ~31);
	memset(gehci->qh, 0, sizeof(struct QH));

	for(i = 0; i < 3; i++)
	{
		gehci->td_unaligned[i] = (struct qTD *)kmalloc(sizeof(struct qTD) + 32);
		if(gehci->td_unaligned[i] == NULL)
		{
			DEBUG(("TDs malloc failed"));
			hc_free_buffers(gehci);
			return(-1);
		}
		gehci->td[i] = (struct qTD *)(((unsigned long)gehci->td_unaligned[i] + 31) & ~31);
		memset(gehci->td[i], 0, sizeof(struct qTD));
	}

	gehci->descriptor = (struct descriptor *)kmalloc(sizeof(struct descriptor));
	if(gehci->descriptor == NULL)
	{
		DEBUG(("decriptor malloc failed"));
		hc_free_buffers(gehci);
		return(-1);
	}
	memcpy(gehci->descriptor, &rom_descriptor, sizeof(struct descriptor));

	if(ehci_bus_init(gehci)) 
	{
		hc_free_buffers(gehci);
		return (-1);
	};
	gehci->hcor = (struct ehci_hcor *)((unsigned long)gehci->hccr + HC_LENGTH(ehci_readl(&gehci->hccr->cr_capbase)));

	/* Get bus addresses */
	r = ehci_bus_getaddr(gehci, (unsigned long)gehci->qh_list, (unsigned long *)&gehci->qh_list_busaddr);
	if(r < 0)
	{
		DEBUG(("Getting qh_list bus address failed"));
		hc_free_buffers(gehci);
		return(-1);
	}

	r = ehci_bus_getaddr(gehci, (unsigned long)gehci->qh, (unsigned long *)&gehci->qh_busaddr);
	if(r < 0)
	{
		DEBUG(("Getting qh bus address failed"));
		hc_free_buffers(gehci);
		return(-1);
	}

	for(i = 0; i < 3; i++)
	{
		r = ehci_bus_getaddr(gehci, (unsigned long)gehci->td[i], (unsigned long *)&gehci->td_busaddr[i]);
		if(r < 0)
		{
			DEBUG(("Getting td bus address failed"));
			hc_free_buffers(gehci);
			return(-1);
		}
		gehci->td_offset[i] = (unsigned long)gehci->td[i] - (unsigned long)gehci->td_busaddr[i];
	}

	/* EHCI spec section 4.1 */
	if(ehci_reset(gehci) != 0)
	{
		hc_free_buffers(gehci);
		return(-1);
	}
	/* Set head of reclaim list */
	gehci->qh_list->qh_link = cpu_to_hc32(((unsigned long)gehci->qh_list_busaddr) | QH_LINK_TYPE_QH);
	gehci->qh_list->qh_endpt1 = cpu_to_hc32((1UL << 15) | (USB_SPEED_HIGH << 12));
	gehci->qh_list->qh_curtd = cpu_to_hc32(QT_NEXT_TERMINATE);
	gehci->qh_list->qh_overlay.qt_next = cpu_to_hc32(QT_NEXT_TERMINATE);
	gehci->qh_list->qh_overlay.qt_altnext = cpu_to_hc32(QT_NEXT_TERMINATE);
	gehci->qh_list->qh_overlay.qt_token = cpu_to_hc32(0x40);

	/* Set async. queue head pointer. */
	ehci_writel(&gehci->hcor->or_asynclistaddr, (unsigned long)gehci->qh_list_busaddr);
	reg = ehci_readl(&gehci->hccr->cr_hcsparams);
	gehci->descriptor->hub.bNbrPorts = HCS_N_PORTS(reg);
	DEBUG(("Register %lx NbrPorts %d", reg, gehci->descriptor->hub.bNbrPorts));

	/* Port Indicators */
	if(HCS_INDICATOR(reg))
		gehci->descriptor->hub.wHubCharacteristics |= 0x80;
	/* Port Power Control */

	if(HCS_PPC(reg))
		gehci->descriptor->hub.wHubCharacteristics |= 0x01;
	/* Start the host controller. */
	cmd = ehci_readl(&gehci->hcor->or_usbcmd);

	/*
	 * Philips, Intel, and maybe others need CMD_RUN before the
	 * root hub will detect new devices (why?); NEC doesn't
	 */
	cmd &= ~(CMD_LRESET|CMD_IAAD|CMD_PSE|CMD_ASE|CMD_RESET);
	cmd |= CMD_RUN;
	ehci_writel(&gehci->hcor->or_usbcmd, cmd);

	/* take control over the ports */
	ehci_writel(&gehci->hcor->or_configflag, FLAG_CF);

	/* unblock posted write */
	cmd = ehci_readl(&gehci->hcor->or_usbcmd);
	mdelay(5);
	reg = HC_VERSION(ehci_readl(&gehci->hccr->cr_capbase));

#if defined(EHCI_POLL) && !defined(TOSONLY)
	r = kthread_create(NULL, ehci_hub_poll_thread, gehci, NULL, "ehci");
	if (r)
	{
		/* XXX todo -> exit gracefully */
		DEBUG(("can't create NetUSBee kernel thread"));
	}
#endif /* EHCI_POLL && !TOSONLY */

	/* turn on interrupts */
	ehci_writel(&gehci->hcor->or_usbintr, INTR_PCDE);

	gehci->rootdev = 0;
	gehci->ehci_inited = 1;

	return 0;
}

long usb_lowlevel_stop(void *ucd_priv)
{
	unsigned long cmd;

	struct ehci *gehci = (struct ehci*)ucd_priv;

	if(!gehci->ehci_inited)
		return(0);
	/* turn off interrupts */
	ehci_writel(&gehci->hcor->or_usbintr, 0);

	/* stop the controller */
	cmd = ehci_readl(&gehci->hcor->or_usbcmd);
	cmd &= ~CMD_RUN;
	ehci_writel(&gehci->hcor->or_usbcmd, cmd);

	/* turn off all ports => todo */
	/* use the companions */
	ehci_writel(&gehci->hcor->or_configflag, 0);

	/* unblock posted write */
	cmd = ehci_readl(&gehci->hcor->or_usbcmd);
	ehci_reset(gehci);
	hc_free_buffers(gehci);
	gehci->ehci_inited = 0;

	ehci_bus_stop(gehci);

	return(0);
}

long submit_bulk_msg(struct usb_device *dev, unsigned long pipe, void *buffer, long length, long flags, unsigned long timeout)
{
	long ret, done, max;
	long dir_out = usb_pipeout(pipe);

	struct ehci *gehci = (struct ehci *)dev->controller->ucd_priv;

	if(usb_pipetype(pipe) != PIPE_BULK)
	{
		DEBUG(("non-bulk pipe (type=%lu)", usb_pipetype(pipe)));
		return -1;
	}

	/* We must to take care about not sending the host controller more data
	 * than it can digest, in perfect conditions of aligment max is 5 * 4k.
	 * (See EHCI specification 3.5.3)
	 */
	done= 0;
	while(done < length)
	{
		max = max_transfer_len(gehci, (unsigned char *) buffer + done);
		if (max < 0)
		{
			DEBUG(("error getting max transfer length (bulk message)"));
			return -1;
		}
		ret = ehci_submit_async(dev, pipe, (unsigned char *) buffer + done,
					max > length - done ? length - done : max,
					NULL, timeout);
		if (ret < 0)
		{
			DEBUG(("error on bulk message"));
			return ret;
		}
		else if (!dev->act_len)
			/* No data was transfered,
			 * return and let upper
			 * layers check why
			 */
			return 0;

		done += dev->act_len;

		if (!dir_out && dev->act_len < max)	/* short packet */
			break;
	}
	dev->act_len = done;

	return 0;

}

long submit_control_msg(struct usb_device *dev, unsigned long pipe, void *buffer, long length, struct devrequest *setup)
{
	struct ehci *gehci = (struct ehci *)dev->controller->ucd_priv;

	if(usb_pipetype(pipe) != PIPE_CONTROL)
	{
		DEBUG(("non-control pipe (type=%lu)", usb_pipetype(pipe)));
		return -1;
	}
	if(usb_pipedevice(pipe) == gehci->rootdev)
	{
		if(gehci->rootdev == 0)
			dev->speed = USB_SPEED_HIGH;
		return ehci_submit_root(dev, pipe, buffer, length, setup);
	}
	return ehci_submit_async(dev, pipe, buffer, length, setup, 5 * USB_CNTL_TIMEOUT);
}

long submit_int_msg(struct usb_device *dev, unsigned long pipe, void *buffer, long length, long interval)
{
	DEBUG(("submit_int_msg dev=%p, pipe=%lu, buffer=%p, length=%ld, interval=%ld", dev, pipe, buffer, length, interval));
	return -1;
}

/*
 * Inteface functions
 */

static long _cdecl
ehci_open(struct ucdif *u)
{
	return E_OK;
}

static long _cdecl
ehci_close(struct ucdif *u)
{
	return E_OK;
}

static long _cdecl
ehci_ioctl(struct ucdif *u, short cmd, long arg)
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

/*
 * Init functions
 */

char fail_kentry[] = "wrong kentry version";
char fail_probe[] = "probe failed";

long
ehci_alloc_ucdif(struct ucdif **u)
{
	struct ucdif *ehci_uif;

	if(!(*u = (struct ucdif *)kmalloc(sizeof(struct ucdif))))
		return -1;
	ehci_uif = *u;

	ehci_uif->next = 0;
	ehci_uif->api_version = USB_API_VERSION;
	ehci_uif->class = USB_CONTRLL;
	ehci_uif->lname = lname;
	ehci_uif->unit = 0;
	ehci_uif->flags = 0;
	ehci_uif->open = ehci_open;
	ehci_uif->close = ehci_close;
	ehci_uif->resrvd1 = 0;
	ehci_uif->ioctl = ehci_ioctl;
	ehci_uif->resrvd2 = 0;
	strcpy(ehci_uif->name, "ehci-pci");
	if(!(ehci_uif->ucd_priv = (void *)kmalloc(sizeof(struct ehci))))
		return -1;

	return 0;
}

/* Entry function */

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
	kentry	= k;
	api = uapi;

	if (check_kentry_version())
	{
		*reason = fail_kentry;
		return -1;
	}
#else
	/* Get USB cookie */
	if (!getcookie(_USB, (long *)&api))
	{
		(void)Cconws("EHCI: failed to get _USB cookie\r\n");
		return -1;
	}

	/* for precise mdelay/udelay relative to CPU power */
	set_tos_delay();
#endif
	ret = ehci_bus_probe();
	if (ret < 0) 
	{
#ifndef TOSONLY
		*reason = fail_probe;
#endif
		return -1;
	}

	c_conws (MSG_BOOT);
	c_conws (MSG_GREET);

#ifdef TOSONLY
	c_conws("EHCI USB driver installed.\r\n");
	Ptermres(_PgmSize,0);
#endif

	return 0;
}
