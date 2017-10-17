/* time / delay functions for the CT60/CTPCI & Coldfire boards
 * Didier Mequignon 2005-2011, e-mail: aniplay@wanadoo.fr
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "config.h"
#include <mint/osbind.h>
#include <mint/sysvars.h>
#include <string.h>
#include "fb.h"
#include "../include/fire.h"

typedef struct
{
	long xbra;
	long ident;
	long old_address;
	short caller[13];
} XBRA;

static long time_out;

#ifdef COLDFIRE

#ifdef MCF5445X

long get_timer(void)
{
	return(*(volatile long *)MCF_DTIM_DTCN1);
}

void start_timeout(void)
{
	time_out = get_timer();
}

int end_timeout(long msec)
{
	msec *= 1000;
	return(((get_timer() - time_out) < msec) ? 0 : 1);
}

void udelay(long usec)
{
	long dcnt1 = *((volatile long *)MCF_DTIM_DTCN1);
	while((*((volatile long *)MCF_DTIM_DTCN1) - dcnt1) < usec);
}

void mdelay(long msec)
{
	long val = get_timer();
	msec *= 1000;
	while((get_timer() - val) < msec);
}

#else /* MCF548X */

long get_timer(void)
{
	return(~(*(volatile long *)MCF_SLT_SCNT1));
}

void start_timeout(void)
{
	time_out = get_timer();
}

int end_timeout(long msec)
{
	msec *= (1000 * SYSTEM_CLOCK);
	return(((get_timer() - time_out) < msec) ? 0 : 1);
}

void udelay(long usec)
{
	long scnt1 = *((volatile long *)MCF_SLT_SCNT1);
	usec *= SYSTEM_CLOCK;
	while((scnt1 - *((volatile long *)MCF_SLT_SCNT1)) < usec);
}

void mdelay(long msec)
{
	long val = get_timer();
	msec *= (1000 * SYSTEM_CLOCK);
	while((get_timer() - val) < msec);
}

#endif /* MCF5445X */

#else /* ATARI */

long get_timer(void) /* try to get a precise timer on F030 */
{
	register long retvalue __asm__("d0");
	asm volatile (
		"move.w SR,-(SP)\n\t"
		"or.w #0x700,SR\n\t"       /* no interrupts	*/
		"move.l 0x4BA,D0\n\t"      /* _hz_200 */
		"asl.l #8,D0\n\t"
		"moveq #0,D1\n\t"
		"move.b 0xFFFFFA23,D1\n\t" /* TCDR timer C MFP */
		"subq.b #1,D1\n\t"         /* 0-191 */
		"asl.l #8,D1\n\t"	         /* *256  */
		"divu #192,D1\n\t"         /* 0-255 */
		"not.b D1\n\t"
		"move.b D1,D0\n\t"
		"move.w (SP)+,SR\n\t"	: "=r"(retvalue) : : "d1", "cc" );
	return(retvalue);	
}

void start_timeout(void)
{
	time_out = get_timer();
}

int end_timeout(long msec)
{
	msec <<= 8;
	msec /= 5;
	return(((get_timer() - time_out) < msec) ? 0 : 1);
}

void udelay(long usec)
{
	unsigned char tcdr;
	while(usec > 0)
	{
		tcdr = *((volatile unsigned char *)0xFFFFFA23);
		while(*((volatile unsigned char *)0xFFFFFA23) == tcdr); /* 26 uS timer C MFP */
		usec -= 26;
	}
}

void mdelay(long msec)
{
	long val = get_timer();
	msec <<= 8;
	msec /= 5;
	while((get_timer() - val) < msec);
}

#endif /* COLDFIRE */

static long vbl_stack[512];
static long save_stack;

void install_vbl_timer(void *func, int remove)
{
#ifdef COLDFIRE
#if defined(NETWORK) && defined (LWIP) && defined(DRIVER_IN_ROM)
#if (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)) && defined(CONFIG_USB_MEM_NO_CACHE) && defined(CONFIG_USB_MEM_NO_CACHE)
	extern void *usb_malloc(long amount);
	extern int usb_free(void *addr);
#endif
	extern void flush_dc(void);
	extern unsigned long pxCurrentTCB, tid_TOS;
#endif
#endif /* COLDFIRE */
	XBRA *xbra;
	int i = (int)*nvbls;
	void (**func_vbl)(void);
	func_vbl = *_vblqueue;
	func_vbl += 2; /* 2 first vectors are used by the VDI cursors mouse and text */
	i-=2;
	while(--i >= 0)
	{
		if(remove && (*func_vbl != NULL))
		{
			xbra = (XBRA *)((long)*func_vbl - 12);
			if((xbra->xbra == 'XBRA') && (xbra->ident == '_PCI')
			 && (xbra->caller[0] == 0x23CF) && (*(long *)&xbra->caller[7] == (long)func))
			{
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP) && defined(DRIVER_IN_ROM) && defined(CONFIG_USB_MEM_NO_CACHE) && (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI))
			if(pxCurrentTCB != tid_TOS)
				usb_free(xbra);
			else
#endif
				Funcs_free(xbra);
				*func_vbl = NULL;		/* remove old vector */	
			}
		}
		if(*func_vbl == NULL)
		{
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP) && defined(DRIVER_IN_ROM) && defined(CONFIG_USB_MEM_NO_CACHE) && (defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI))
			if(pxCurrentTCB != tid_TOS)
				xbra = (XBRA *)usb_malloc(sizeof(XBRA));
			else
#endif
				xbra = (XBRA *)Funcs_malloc(sizeof(XBRA),3);
			if(xbra != NULL)
			{
				xbra->xbra = 'XBRA';
				xbra->ident = '_PCI';
				xbra->caller[0] = 0x23CF; /* move.l SP,xxxx */
				*(long *)&xbra->caller[1] = (long)&save_stack;
				xbra->caller[3] = 0x4FF9; /* lea xxxx,SP */
				*(long *)&xbra->caller[4] = (long)&vbl_stack[512];
				xbra->caller[6] = 0x4EB9; /* jsr xxxx */
				*(long *)&xbra->caller[7] = (long)func;
				xbra->caller[9] = 0x2E79; /* move.l xxxx,SP */
				*(long *)&xbra->caller[10] = (long)&save_stack;
				xbra->caller[12] = 0x4E75; /* rts */
#ifdef COLDFIRE
#if defined(NETWORK) && defined (LWIP) && defined(DRIVER_IN_ROM)
				if(pxCurrentTCB != tid_TOS)
					flush_dc();
				else
#endif
#if (__GNUC__ > 3)
					asm volatile (" .chip 68060\n\t cpusha BC\n\t .chip 5485\n\t"); /* from CF68KLIB */
#else
					asm volatile (" .chip 68060\n\t cpusha BC\n\t .chip 5200\n\t"); /* from CF68KLIB */
#endif
#else /* 68060 */
				asm volatile (" cpusha BC\n\t");
#endif /* COLDFIRE */
				*func_vbl = (void(*)())&xbra->caller[0];
				xbra->old_address = 0;
			}
			break;
		}
		func_vbl++;
	}	
}

void uninstall_vbl_timer(void *func)
{
	XBRA *xbra;
	int i = (int)*nvbls;
	void (**func_vbl)(void);
	func_vbl = *_vblqueue;
	while(--i > 0)
	{
		if(*func_vbl != NULL)
		{
			xbra = (XBRA *)((long)*func_vbl - 12);
			if((xbra->xbra == 'XBRA') && (xbra->ident == '_PCI')
			 && (xbra->caller[0] == 0x23CF) && (*(long *)&xbra->caller[7] == (long)func))
			{
				Funcs_free(xbra);
				*func_vbl = NULL;		/* remove old vector */	
				break;
			}
		}
		func_vbl++;
	}
}


