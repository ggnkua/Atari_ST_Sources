/*
 * File:    mcf548x_pll.h
 * Purpose: Register and bit definitions
 */

#ifndef __MCF548X_PLL_H__
#define __MCF548X_PLL_H__

/*********************************************************************
*
* System PLL (PLL)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_PLL_SPCR         (__MBAR+0x000300)

/* Bit definitions and macros for MCF_PLL_SPCR */
#define MCF_PLL_SPCR_MEMEN   (0x00000001)
#define MCF_PLL_SPCR_PCIEN   (0x00000002)
#define MCF_PLL_SPCR_FBEN    (0x00000004)
#define MCF_PLL_SPCR_CN0EN   (0x00000008)
#define MCF_PLL_SPCR_DMAEN   (0x00000010)
#define MCF_PLL_SPCR_FEC0EN  (0x00000020)
#define MCF_PLL_SPCR_FEC1EN  (0x00000040)
#define MCF_PLL_SPCR_USBEN   (0x00000080)
#define MCF_PLL_SPCR_PSCEN   (0x00000200)
#define MCF_PLL_SPCR_CN1EN   (0x00000800)
#define MCF_PLL_SPCR_CRYENA  (0x00001000)
#define MCF_PLL_SPCR_CRYENB  (0x00002000)
#define MCF_PLL_SPCR_COREN   (0x00004000)
#define MCF_PLL_SPCR_LOCK    (0x80000000)

/********************************************************************/

#endif /* __MCF548X_PLL_H__ */
