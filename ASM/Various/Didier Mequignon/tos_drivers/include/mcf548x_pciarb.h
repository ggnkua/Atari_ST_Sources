/*
 * File:    mcf548x_pciarb.h
 * Purpose: Register and bit definitions for the MCF548X
 *
 * Notes:   
 *  
 */

#ifndef __MCF548X_PCIARB_H__
#define __MCF548X_PCIARB_H__

/*********************************************************************
*
* PCI Arbiter Module (PCIARB)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_PCIARB_PACR    (__MBAR+0x000C00)
#define MCF_PCIARB_PASR    (__MBAR+0x000C04)

/* Bit definitions and macros for MCF_PCIARB_PACR */
#define MCF_PCIARB_PACR_INTMPRI         (0x00000001)
#define MCF_PCIARB_PACR_EXTMPRI(x)      (((x)&0x0000001F)<<1)
#define MCF_PCIARB_PACR_INTMINTEN       (0x00010000)
#define MCF_PCIARB_PACR_EXTMINTEN(x)    (((x)&0x0000001F)<<17)
#define MCF_PCIARB_PACR_PKMD            (0x40000000)
#define MCF_PCIARB_PACR_DS              (0x80000000)

/* Bit definitions and macros for MCF_PCIARB_PASR */
#define MCF_PCIARB_PASR_ITLMBK          (0x00010000)
#define MCF_PCIARB_PASR_EXTMBK(x)       (((x)&0x0000001F)<<17)

/********************************************************************/

#endif /* __MCF548X_PCIARB_H__ */
