/*
 * File:        net.h
 * Purpose:     Network definitions and prototypes.
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
#ifndef NULL
#define NULL (void *)0
#endif
#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE 1
#endif

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

/* Interrupt Priorities */
#define DMA_INTC_LVL 6 // 5
#define DMA_INTC_PRI 7 // 3
#define FEC_INTC_LVL 5
#define FEC0_INTC_PRI 1
#define FEC1_INTC_PRI 0

#ifdef MCF5445X

/* System Bus Clock Info */
#define SYSTEM_CLOCK 132    // system bus frequency in MHz

#else /* MCF548X */

/* DMA Task Priorities */
#define FEC0TX_DMA_PRI 4
#define FEC0RX_DMA_PRI 3
#define FEC1TX_DMA_PRI 2
#define FEC1RX_DMA_PRI 1

/* System Bus Clock Info */
#ifdef MCF547X
#define SYSTEM_CLOCK 132    // system bus frequency in MHz
#else /* MCF548X */
#define SYSTEM_CLOCK 100    // system bus frequency in MHz
#endif /* MCF547X */

/* Flash */
#define INTEL_C3_FLASH_28F320C3B

extern unsigned char __MBAR[];
extern unsigned char __MCDAPI_START[];

#endif /* MCF5445X */

extern int asm_set_ipl(int level);

/* functions to convert between host and network byte order (big endian) */
#define	ntohl(x) (x)
#define	ntohs(x) (x)
#define	htonl(x) (x)
#define	htons(x) (x)

/********************************************************************/

/*
 * Include information and prototypes for all protocols
 */
#include "eth.h"
#include "nbuf.h"

/********************************************************************/

int net_init(uint8 ch);

/********************************************************************/

#endif  /* _NET_H */

