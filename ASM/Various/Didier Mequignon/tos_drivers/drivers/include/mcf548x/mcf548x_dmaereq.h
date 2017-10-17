/*
 * File:    mcf548x_dmaereq.h
 * Purpose: Register and bit definitions
 */

#ifndef __MCF548X_DMAEREQ_H__
#define __MCF548X_DMAEREQ_H__

/*********************************************************************
*
* Multi-Channel DMA External Requests (DMAEREQ)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_DMAEREQ0_BAR                    (*(vuint32*)(&__MBAR[0x000D00]))
#define MCF_DMAEREQ0_MASK                   (*(vuint32*)(&__MBAR[0x000D04]))
#define MCF_DMAEREQ0_CTRL                   (*(vuint32*)(&__MBAR[0x000D08]))
#define MCF_DMAEREQ1_BAR                    (*(vuint32*)(&__MBAR[0x000D10]))
#define MCF_DMAEREQ1_MASK                   (*(vuint32*)(&__MBAR[0x000D14]))
#define MCF_DMAEREQ1_CTRL                   (*(vuint32*)(&__MBAR[0x000D18]))
#define MCF_DMAEREQ_BAR(x)                  (*(vuint32*)(&__MBAR[0x000D00+((x)*0x010)]))
#define MCF_DMAEREQ_MASK(x)                 (*(vuint32*)(&__MBAR[0x000D04+((x)*0x010)]))
#define MCF_DMAEREQ_CTRL(x)                 (*(vuint32*)(&__MBAR[0x000D08+((x)*0x010)]))

/* Bit definitions and macros for MCF_DMAEREQ_BAR */
#define MCF_DMAEREQ_BAR_BASE_ADDRESS(x)     (((x)&0xFFFFFFFF)<<0)

/* Bit definitions and macros for MCF_DMAEREQ_MASK */
#define MCF_DMAEREQ_MASK_ADDR_MASK(x)       (((x)&0xFFFFFFFF)<<0)

/* Bit definitions and macros for MCF_DMAEREQ_CTRL */
#define MCF_DMAEREQ_CTRL_EN                 (0x00000001)
#define MCF_DMAEREQ_CTRL_SYNC               (0x00000002)
#define MCF_DMAEREQ_CTRL_DACKWID(x)         (((x)&0x00000003)<<2)
#define MCF_DMAEREQ_CTRL_BSEL(x)            (((x)&0x00000003)<<4)
#define MCF_DMAEREQ_CTRL_MD(x)              (((x)&0x00000003)<<6)
#define MCF_DMAEREQ_CTRL_MD_IDLE            (0x00000000)
#define MCF_DMAEREQ_CTRL_MD_LEVEL           (0x00000040)
#define MCF_DMAEREQ_CTRL_MD_EDGE            (0x00000080)
#define MCF_DMAEREQ_CTRL_MD_PIPED           (0x000000C0)
#define MCF_DMAEREQ_CTRL_BSEL_MEM_WRITE     (0x00000000)
#define MCF_DMAEREQ_CTRL_BSEL_MEM_READ      (0x00000010)
#define MCF_DMAEREQ_CTRL_BSEL_PERIPH_WRITE  (0x00000020)
#define MCF_DMAEREQ_CTRL_BSEL_PERIPH_READ   (0x00000030)
#define MCF_DMAEREQ_CTRL_DACKWID_ONE        (0x00000000)
#define MCF_DMAEREQ_CTRL_DACKWID_TWO        (0x00000004)
#define MCF_DMAEREQ_CTRL_DACKWID_THREE      (0x00000008)
#define MCF_DMAEREQ_CTRL_DACKWID_FOUR       (0x0000000C)

/********************************************************************/

#endif /* __MCF548X_DMAEREQ_H__ */
