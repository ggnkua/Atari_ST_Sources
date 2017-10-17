/*
 * File:        net.h
 * Purpose:     Network definitions and prototypes for dBUG.
 *
 * Notes:
 */

#ifndef _NET_H
#define _NET_H

#define int8 char
#define int16 short
#define int32 long
#define uint8 unsigned char
#define uint16 unsigned short
#define uint32 unsigned long
#define vuint8 volatile unsigned char
#define vuint16 volatile unsigned short
#define vuint32 volatile unsigned long
#define NULL (void *)0
#define FALSE 0
#define TRUE 1

#define TIMER_NETWORK 0

/*
 * Ethernet Info
 */
#define FEC_PHY0            (0x00)
#define FEC_PHY1            (0x01)
#define FEC_PHY(x)          ((x == 0) ? FEC_PHY0 : FEC_PHY1)
#ifdef MCF5445X
#define phy_init            dp83849_init
#else /* MCF547X - MCF548X */
#ifdef MCF547X
#define phy_init            am79c874_init
#else /* MCF548X */
#define phy_init            bcm5222_init
#endif /* MCF547X */
#endif /* MCF5445X */

/*
 * Interrupt Priorities
 */
#define DMA_INTC_LVL 5
#define DMA_INTC_PRI 3
#define FEC_INTC_LVL 5
#define FEC_INTC_PRI 0

/*
 * DMA Task Priorities
 */
#define FECRX_DMA_PRI 3
#define FECTX_DMA_PRI 4

/* 
 * System Bus Clock Info 
 */
#ifdef MCF5445X
#define SYSTEM_CLOCK 132    // system bus frequency in MHz
#else /* MCF547X - MCF548X */
#ifdef MCF547X
#define SYSTEM_CLOCK 132    // system bus frequency in MHz
#else /* MCF548X */
#define SYSTEM_CLOCK 100    // system bus frequency in MHz
#endif /* MCF547X */
#endif /* MCF5445X */

extern unsigned char __MBAR[];
extern unsigned char __MCDAPI_START[];

extern long length(const char *text);
extern void copy(const char *src, char *dest);

#define strcpy(dest,src) copy((const char *)src,(char *)dest)
#define strlen(a) length((const char *)a)
extern int asm_set_ipl(int level);

/********************************************************************/

/*
 * Include information and prototypes for all protocols
 */
#include "eth.h"
#include "nbuf.h"
#include "nif.h"
#include "ip.h"
#include "icmp.h"
#include "arp.h"
#include "udp.h"
#include "tftp.h"

#endif  /* _NET_H */

