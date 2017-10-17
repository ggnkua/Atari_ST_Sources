/*
 * File:    mcf548x_slt.h
 * Purpose: Register and bit definitions for the MCF548X
 *
 * Notes:   
 *  
 */

#ifndef __MCF548X_SLT_H__
#define __MCF548X_SLT_H__

/*********************************************************************
*
* Slice Timers (SLT)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_SLT_SLTCNT0      (__MBAR+0x000900)
#define MCF_SLT_SCR0         (__MBAR+0x000904)
#define MCF_SLT_SCNT0        (__MBAR+0x000908)
#define MCF_SLT_SSR0         (__MBAR+0x00090C)
#define MCF_SLT_SLTCNT1      (__MBAR+0x000910)
#define MCF_SLT_SCR1         (__MBAR+0x000914)
#define MCF_SLT_SCNT1        (__MBAR+0x000918)
#define MCF_SLT_SSR1         (__MBAR+0x00091C)
#define MCF_SLT_SLTCNT(x)    (__MBAR+0x000900+((x)*0x010))
#define MCF_SLT_SCR(x)       (__MBAR+0x000904+((x)*0x010))
#define MCF_SLT_SCNT(x)      (__MBAR+0x000908+((x)*0x010))
#define MCF_SLT_SSR(x)       (__MBAR+0x00090C+((x)*0x010))

/* Bit definitions and macros for MCF_SLT_SCR */
#define MCF_SLT_SCR_TEN    (0x01000000)
#define MCF_SLT_SCR_IEN    (0x02000000)
#define MCF_SLT_SCR_RUN    (0x04000000)

/* Bit definitions and macros for MCF_SLT_SSR */
#define MCF_SLT_SSR_ST     (0x01000000)
#define MCF_SLT_SSR_BE     (0x02000000)

/********************************************************************/

#endif /* __MCF548X_SLT_H__ */
