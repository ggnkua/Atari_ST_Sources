/*
 * File:    mcf548x_sram.h
 * Purpose: Register and bit definitions
 */

#ifndef __MCF548X_SRAM_H__
#define __MCF548X_SRAM_H__

/*********************************************************************
*
* 32KByte System SRAM (SRAM)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_SRAM_SSCR                 (*(vuint32*)(&__MBAR[0x01FFC0]))
#define MCF_SRAM_TCCR                 (*(vuint32*)(&__MBAR[0x01FFC4]))
#define MCF_SRAM_TCCRDR               (*(vuint32*)(&__MBAR[0x01FFC8]))
#define MCF_SRAM_TCCRDW               (*(vuint32*)(&__MBAR[0x01FFCC]))
#define MCF_SRAM_TCCRSEC              (*(vuint32*)(&__MBAR[0x01FFD0]))

/* Bit definitions and macros for MCF_SRAM_SSCR */
#define MCF_SRAM_SSCR_INLV            (0x00010000)

/* Bit definitions and macros for MCF_SRAM_TCCR */
#define MCF_SRAM_TCCR_BANK0_TC(x)     (((x)&0x0000000F)<<0)
#define MCF_SRAM_TCCR_BANK1_TC(x)     (((x)&0x0000000F)<<8)
#define MCF_SRAM_TCCR_BANK2_TC(x)     (((x)&0x0000000F)<<16)
#define MCF_SRAM_TCCR_BANK3_TC(x)     (((x)&0x0000000F)<<24)

/* Bit definitions and macros for MCF_SRAM_TCCRDR */
#define MCF_SRAM_TCCRDR_BANK0_TC(x)   (((x)&0x0000000F)<<0)
#define MCF_SRAM_TCCRDR_BANK1_TC(x)   (((x)&0x0000000F)<<8)
#define MCF_SRAM_TCCRDR_BANK2_TC(x)   (((x)&0x0000000F)<<16)
#define MCF_SRAM_TCCRDR_BANK3_TC(x)   (((x)&0x0000000F)<<24)

/* Bit definitions and macros for MCF_SRAM_TCCRDW */
#define MCF_SRAM_TCCRDW_BANK0_TC(x)   (((x)&0x0000000F)<<0)
#define MCF_SRAM_TCCRDW_BANK1_TC(x)   (((x)&0x0000000F)<<8)
#define MCF_SRAM_TCCRDW_BANK2_TC(x)   (((x)&0x0000000F)<<16)
#define MCF_SRAM_TCCRDW_BANK3_TC(x)   (((x)&0x0000000F)<<24)

/* Bit definitions and macros for MCF_SRAM_TCCRSEC */
#define MCF_SRAM_TCCRSEC_BANK0_TC(x)  (((x)&0x0000000F)<<0)
#define MCF_SRAM_TCCRSEC_BANK1_TC(x)  (((x)&0x0000000F)<<8)
#define MCF_SRAM_TCCRSEC_BANK2_TC(x)  (((x)&0x0000000F)<<16)
#define MCF_SRAM_TCCRSEC_BANK3_TC(x)  (((x)&0x0000000F)<<24)

/********************************************************************/

#endif /* __MCF548X_SRAM_H__ */
