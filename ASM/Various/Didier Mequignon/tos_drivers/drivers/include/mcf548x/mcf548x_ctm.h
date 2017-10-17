/*
 * File:    mcf548x_ctm.h
 * Purpose: Register and bit definitions
 */

#ifndef __MCF548X_CTM_H__
#define __MCF548X_CTM_H__

/*********************************************************************
*
* Comm Timer Module (CTM)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_CTM_CTCRF0           (*(vuint32*)(&__MBAR[0x007F00]))
#define MCF_CTM_CTCRF1           (*(vuint32*)(&__MBAR[0x007F04]))
#define MCF_CTM_CTCRF2           (*(vuint32*)(&__MBAR[0x007F08]))
#define MCF_CTM_CTCRF3           (*(vuint32*)(&__MBAR[0x007F0C]))
#define MCF_CTM_CTCRF(x)         (*(vuint32*)(&__MBAR[0x007F00+((x)*0x004)]))
#define MCF_CTM_CTCRV4           (*(vuint32*)(&__MBAR[0x007F10]))
#define MCF_CTM_CTCRV5           (*(vuint32*)(&__MBAR[0x007F14]))
#define MCF_CTM_CTCRV6           (*(vuint32*)(&__MBAR[0x007F18]))
#define MCF_CTM_CTCRV7           (*(vuint32*)(&__MBAR[0x007F1C]))
#define MCF_CTM_CTCRV(x)         (*(vuint32*)(&__MBAR[0x007F10+((x-4)*0x004)]))

/* Bit definitions and macros for MCF_CTM_CTCRF */
#define MCF_CTM_CTCRF_CRV(x)     (((x)&0x0000FFFF)<<0)
#define MCF_CTM_CTCRF_S(x)       (((x)&0x0000000F)<<16)
#define MCF_CTM_CTCRF_PCT(x)     (((x)&0x00000007)<<20)
#define MCF_CTM_CTCRF_M          (0x00800000)
#define MCF_CTM_CTCRF_IM         (0x01000000)
#define MCF_CTM_CTCRF_I          (0x80000000)
#define MCF_CTM_CTCRF_PCT_100    (0x00000000)
#define MCF_CTM_CTCRF_PCT_50     (0x00100000)
#define MCF_CTM_CTCRF_PCT_25     (0x00200000)
#define MCF_CTM_CTCRF_PCT_12p5   (0x00300000)
#define MCF_CTM_CTCRF_PCT_6p25   (0x00400000)
#define MCF_CTM_CTCRF_PCT_OFF    (0x00500000)
#define MCF_CTM_CTCRF_S_CLK_1    (0x00000000)
#define MCF_CTM_CTCRF_S_CLK_2    (0x00010000)
#define MCF_CTM_CTCRF_S_CLK_4    (0x00020000)
#define MCF_CTM_CTCRF_S_CLK_8    (0x00030000)
#define MCF_CTM_CTCRF_S_CLK_16   (0x00040000)
#define MCF_CTM_CTCRF_S_CLK_32   (0x00050000)
#define MCF_CTM_CTCRF_S_CLK_64   (0x00060000)
#define MCF_CTM_CTCRF_S_CLK_128  (0x00070000)
#define MCF_CTM_CTCRF_S_CLK_256  (0x00080000)

/* Bit definitions and macros for MCF_CTM_CTCRV */
#define MCF_CTM_CTCRV_CRV(x)     (((x)&0x00FFFFFF)<<0)
#define MCF_CTM_CTCRV_PCT(x)     (((x)&0x00000007)<<24)
#define MCF_CTM_CTCRV_M          (0x08000000)
#define MCF_CTM_CTCRV_S(x)       (((x)&0x0000000F)<<28)
#define MCF_CTM_CTCRV_S_CLK_1    (0x00000000)
#define MCF_CTM_CTCRV_S_CLK_2    (0x10000000)
#define MCF_CTM_CTCRV_S_CLK_4    (0x20000000)
#define MCF_CTM_CTCRV_S_CLK_8    (0x30000000)
#define MCF_CTM_CTCRV_S_CLK_16   (0x40000000)
#define MCF_CTM_CTCRV_S_CLK_32   (0x50000000)
#define MCF_CTM_CTCRV_S_CLK_64   (0x60000000)
#define MCF_CTM_CTCRV_S_CLK_128  (0x70000000)
#define MCF_CTM_CTCRV_S_CLK_256  (0x80000000)
#define MCF_CTM_CTCRV_PCT_100    (0x00000000)
#define MCF_CTM_CTCRV_PCT_50     (0x01000000)
#define MCF_CTM_CTCRV_PCT_25     (0x02000000)
#define MCF_CTM_CTCRV_PCT_12p5   (0x03000000)
#define MCF_CTM_CTCRV_PCT_6p25   (0x04000000)
#define MCF_CTM_CTCRV_PCT_OFF    (0x05000000)

/********************************************************************/

#endif /* __MCF548X_CTM_H__ */
