/*
 *	usb_mem.c
 *
 * based from Emutos / BDOS
 * 
 * Copyright (c) 2001 Lineo, Inc.
 *
 * Authors: Karl T. Braun, Martin Doering, Laurent Vogel
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.
 */

#include "config.h"
#include <mint/errno.h>
#include <mint/osbind.h> 
#include <string.h>
#include "usb.h"

#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE 1
#endif

#undef USB_MEM_DEBUG

#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)

#ifdef	USB_MEM_DEBUG
#define	USB_MEM_PRINTF(fmt,args...)	board_printf(fmt ,##args)
#else
#define USB_MEM_PRINTF(fmt,args...)
#endif

#ifdef CONFIG_USB_MEM_NO_CACHE

extern char __NO_CACHE_MEMORY_BASE[];
extern char __NO_CACHE_MEMORY_SIZE[];

#endif /* CONFIG_USB_MEM_NO_CACHE */

static void *usb_buffer;
extern int asm_set_ipl(int level);
extern void *info_fvdi;
extern long offscren_reserved(void);

/* MD - Memory Descriptor */

#define MD struct _md_

MD
{
	MD *m_link;
	long m_start;
	long m_length;
};

/* MPB - Memory Partition Block */

#define MPB struct _mpb

MPB
{
	MD *mp_mfl;
	MD *mp_mal;
	MD *mp_rover;
};

#define MAXMD 100

static int count_md;
static MD tab_md[MAXMD];
static MPB pmd;

static MD *ffit(long amount, MPB *mp)
{
	MD *p,*q,*p1;                    /* free list is composed of MD's */
	int maxflg;
	long maxval;
	if(amount != -1)
	{
		amount += 15;                  /* 16 bytes alignment */
		amount &= 0xFFFFFFF0;
	}
	if((q = mp->mp_rover) == 0)      /* get rotating pointer */
		return(0) ;
	maxval = 0;
	maxflg = (amount == -1 ? TRUE : FALSE) ;
	p = q->m_link;                   /* start with next MD */
	do /* search the list for an MD with enough space */
	{
		if(p == 0)
		{
			/*  at end of list, wrap back to start  */
			q = (MD *) &mp->mp_mfl;      /*  q => mfl field  */
			p = q->m_link;               /*  p => 1st MD     */
		}
		if((!maxflg) && (p->m_length >= amount))
		{
			/*  big enough */
			if(p->m_length == amount)
				q->m_link = p->m_link;     /* take the whole thing */
			else
			{
				/* break it up - 1st allocate a new
				   MD to describe the remainder */
				if(count_md >= MAXMD)
					return(0);
				p1 = &tab_md[count_md++];
				/* init new MD */
				p1->m_length = p->m_length - amount;
				p1->m_start = p->m_start + amount;
				p1->m_link = p->m_link;
				p->m_length = amount;      /* adjust allocated block */
				q->m_link = p1;
			}
			/* link allocate block into allocated list,
			    mark owner of block, & adjust rover  */
			p->m_link = mp->mp_mal;
			mp->mp_mal = p;
			mp->mp_rover = (q == (MD *) &mp->mp_mfl ? q->m_link : q);
			return(p);                   /* got some */
		}
		else if(p->m_length > maxval)
			maxval = p->m_length;
		p = ( q=p )->m_link;
	}
	while(q != mp->mp_rover);
	/*  return either the max, or 0 (error)  */
	if(maxflg)
	{
		maxval -= 15; /* 16 bytes alignment */
		if(maxval < 0)
			maxval = 0;
		else
			maxval &= 0xFFFFFFF0;
	}
	return(maxflg ? (MD *) maxval : 0);
}

static void freeit(MD *m, MPB *mp)
{
	MD *p, *q;
	q = 0;
	for(p = mp->mp_mfl; p ; p = (q=p) -> m_link)
	{
		if(m->m_start <= p->m_start)
			break;
	}
	m->m_link = p;
	if(q)
		q->m_link = m;
	else
		mp->mp_mfl = m;
	if(!mp->mp_rover)
		mp->mp_rover = m;
	if(p)
	{
		if(m->m_start + m->m_length == p->m_start)
		{ /* join to higher neighbor */
			m->m_length += p->m_length;
			m->m_link = p->m_link;
			if(p == mp->mp_rover)
				mp->mp_rover = m;
			if(count_md>=0)
				count_md--;
		}
	}
	if(q)
	{
		if(q->m_start + q->m_length == m->m_start)
		{ /* join to lower neighbor */
			q->m_length += m->m_length;
			q->m_link = m->m_link;
			if(m == mp->mp_rover)
				mp->mp_rover = q;
			if(count_md>=0)
				count_md--;
		}
	}
}

int usb_free(void *addr)
{
	int level;
	MD *p, **q;
	MPB *mpb;
	mpb = &pmd;
	if(usb_buffer == NULL)
		return(EFAULT);
	level = asm_set_ipl(7);
	for(p = *(q = &mpb->mp_mal); p; p = *(q = &p->m_link))
	{
		if((long)addr == p->m_start)
			break;
	}
	if(!p)
	{
		asm_set_ipl(level);
		return(EFAULT);
	}
	*q = p->m_link;
	freeit(p, mpb);
	asm_set_ipl(level);
	USB_MEM_PRINTF("usb_free(0x%08X)\r\n", addr);
	return(0);
}

void *usb_malloc(long amount)
{
	int level;
	MD *m;
	if(usb_buffer == NULL)
		return(NULL);
	if(amount == -1L)
		return((void *)ffit(-1L,&pmd));
	if(amount <= 0 )
		return(0);
	if((amount & 1))
		amount++;
	level = asm_set_ipl(7);
	m = ffit(amount, &pmd);
	asm_set_ipl(level);
	USB_MEM_PRINTF("usb_malloc(%d) = 0x%08X\r\n", amount, (m == NULL) ? 0 : m->m_start);
	if(m == NULL)
		return(NULL);
	return((void *)m->m_start);
}

int usb_mem_init(void)
{
	if(usb_buffer != NULL)
		return(0);
#ifdef CONFIG_USB_MEM_NO_CACHE
	pmd.mp_mfl = pmd.mp_rover = &tab_md[0];
	tab_md[0].m_link = (MD *)NULL;
	usb_buffer = (void *)__NO_CACHE_MEMORY_BASE;
	tab_md[0].m_start = (long)usb_buffer;
	tab_md[0].m_length = (long)__NO_CACHE_MEMORY_SIZE;
#else /* !CONFIG_USB_MEM_NO_CACHE */
#if 0
	usb_buffer = (void *)offscren_reserved();
	if(usb_buffer == NULL)
#endif	
	usb_buffer = (void *)Mxalloc(USB_BUFFER_SIZE + 16, 0); /* STRAM - cache in writethough */
	if(usb_buffer == NULL)
		return(-1);
	pmd.mp_mfl = pmd.mp_rover = &tab_md[0];
	tab_md[0].m_link = (MD *)NULL;
	tab_md[0].m_start = ((long)usb_buffer + 15) & ~15;
	tab_md[0].m_length = USB_BUFFER_SIZE;	
#endif /* CONFIG_USB_MEM_NO_CACHE */
	pmd.mp_mal = (MD *)NULL;
	memset(usb_buffer, 0, tab_md[0].m_length);
	USB_MEM_PRINTF("USB malloc buffer at 0x%08X size %d\r\n", tab_md[0].m_start, tab_md[0].m_length);
	count_md = 1;
	return(0);
}

void usb_mem_stop(void)
{
#ifndef CONFIG_USB_MEM_NO_CACHE
	if(usb_buffer != NULL)
		Mfree(usb_buffer);
#endif
}

#endif /* CONFIG_USB_UHCI || CONFIG_USB_OHCI || CONFIG_USB_EHCI */


