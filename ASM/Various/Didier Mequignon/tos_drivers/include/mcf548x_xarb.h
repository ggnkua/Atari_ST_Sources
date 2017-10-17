/*
 * File:    mcf548x_xarb.h
 * Purpose: Register and bit definitions
 */

#ifndef __MCF548X_XARB_H__
#define __MCF548X_XARB_H__

/*********************************************************************
*
* XL Bus Arbiter (XARB)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_XARB_CFG             (__MBAR+0x000240)
#define MCF_XARB_VER             (__MBAR+0x000244)
#define MCF_XARB_SR              (__MBAR+0x000248)
#define MCF_XARB_IMR             (__MBAR+0x00024C)
#define MCF_XARB_ADRCAP          (__MBAR+0x000250)
#define MCF_XARB_SIGCAP          (__MBAR+0x000254)
#define MCF_XARB_ADRTO           (__MBAR+0x000258)
#define MCF_XARB_DATTO           (__MBAR+0x00025C)
#define MCF_XARB_BUSTO           (__MBAR+0x000260)
#define MCF_XARB_PRIEN           (__MBAR+0x000264)
#define MCF_XARB_PRI             (__MBAR+0x000268)

/* Bit definitions and macros for MCF_XARB_CFG */
#define MCF_XARB_CFG_AT          (0x00000002)
#define MCF_XARB_CFG_DT          (0x00000004)
#define MCF_XARB_CFG_BA          (0x00000008)
#define MCF_XARB_CFG_PM(x)       (((x)&0x00000003)<<5)
#define MCF_XARB_CFG_SP(x)       (((x)&0x00000007)<<8)
#define MCF_XARB_CFG_PLDIS       (0x80000000)

/* Bit definitions and macros for MCF_XARB_SR */
#define MCF_XARB_SR_AT           (0x00000001)
#define MCF_XARB_SR_DT           (0x00000002)
#define MCF_XARB_SR_BA           (0x00000004)
#define MCF_XARB_SR_TTM          (0x00000008)
#define MCF_XARB_SR_ECW          (0x00000010)
#define MCF_XARB_SR_TTR          (0x00000020)
#define MCF_XARB_SR_TTA          (0x00000040)
#define MCF_XARB_SR_MM           (0x00000080)
#define MCF_XARB_SR_SEA          (0x00000100)

/* Bit definitions and macros for MCF_XARB_IMR */
#define MCF_XARB_IMR_ATE         (0x00000001)
#define MCF_XARB_IMR_DTE         (0x00000002)
#define MCF_XARB_IMR_BAE         (0x00000004)
#define MCF_XARB_IMR_TTME        (0x00000008)
#define MCF_XARB_IMR_ECWE        (0x00000010)
#define MCF_XARB_IMR_TTRE        (0x00000020)
#define MCF_XARB_IMR_TTAE        (0x00000040)
#define MCF_XARB_IMR_MME         (0x00000080)
#define MCF_XARB_IMR_SEAE        (0x00000100)

/* Bit definitions and macros for MCF_XARB_SIGCAP */
#define MCF_XARB_SIGCAP_TT(x)    (((x)&0x0000001F)<<0)
#define MCF_XARB_SIGCAP_TBST     (0x00000020)
#define MCF_XARB_SIGCAP_TSIZ(x)  (((x)&0x00000007)<<7)

/* Bit definitions and macros for MCF_XARB_ADRTO */
#define MCF_XARB_ADRTO_ADRTO(x)  (((x)&0x0FFFFFFF)<<0)

/* Bit definitions and macros for MCF_XARB_DATTO */
#define MCF_XARB_DATTO_DATTO(x)  (((x)&0x0FFFFFFF)<<0)

/* Bit definitions and macros for MCF_XARB_PRIEN */
#define MCF_XARB_PRIEN_M0        (0x00000001)
#define MCF_XARB_PRIEN_M2        (0x00000004)
#define MCF_XARB_PRIEN_M3        (0x00000008)

/* Bit definitions and macros for MCF_XARB_PRI */
#define MCF_XARB_PRI_M0P(x)      (((x)&0x00000007)<<0)
#define MCF_XARB_PRI_M2P(x)      (((x)&0x00000007)<<8)
#define MCF_XARB_PRI_M3P(x)      (((x)&0x00000007)<<12)

/********************************************************************/

#endif /* __MCF548X_XARB_H__ */
