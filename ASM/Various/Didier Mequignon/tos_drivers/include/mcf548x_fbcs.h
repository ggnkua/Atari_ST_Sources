/*
 * File:    mcf548x_fbcs.h
 * Purpose: Register and bit definitions for the MCF548X
 *
 * Notes:   
 *  
 */

#ifndef __MCF548X_FBCS_H__
#define __MCF548X_FBCS_H__

/*********************************************************************
*
* FlexBus Chip Selects (FBCS)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_FBCS_CSAR0      (__MBAR+0x000500)
#define MCF_FBCS_CSMR0      (__MBAR+0x000504)
#define MCF_FBCS_CSCR0      (__MBAR+0x000508)
#define MCF_FBCS_CSAR1      (__MBAR+0x00050C)
#define MCF_FBCS_CSMR1      (__MBAR+0x000510)
#define MCF_FBCS_CSCR1      (__MBAR+0x000514)
#define MCF_FBCS_CSAR2      (__MBAR+0x000518)
#define MCF_FBCS_CSMR2      (__MBAR+0x00051C)
#define MCF_FBCS_CSCR2      (__MBAR+0x000520)
#define MCF_FBCS_CSAR3      (__MBAR+0x000524)
#define MCF_FBCS_CSMR3      (__MBAR+0x000528)
#define MCF_FBCS_CSCR3      (__MBAR+0x00052C)
#define MCF_FBCS_CSAR4      (__MBAR+0x000530)
#define MCF_FBCS_CSMR4      (__MBAR+0x000534)
#define MCF_FBCS_CSCR4      (__MBAR+0x000538)
#define MCF_FBCS_CSAR5      (__MBAR+0x00053C)
#define MCF_FBCS_CSMR5      (__MBAR+0x000540)
#define MCF_FBCS_CSCR5      (__MBAR+0x000544)
#define MCF_FBCS_CSAR(x)    (*(vuint32*)(void*)(&__MBAR[0x000500+((x)*0x00C)]))
#define MCF_FBCS_CSMR(x)    (*(vuint32*)(void*)(&__MBAR[0x000504+((x)*0x00C)]))
#define MCF_FBCS_CSCR(x)    (*(vuint32*)(void*)(&__MBAR[0x000508+((x)*0x00C)]))

/* Bit definitions and macros for MCF_FBCS_CSAR */
#define MCF_FBCS_CSAR_BA(x)        ((x)&0xFFFF0000)

/* Bit definitions and macros for MCF_FBCS_CSMR */
#define MCF_FBCS_CSMR_V            (0x00000001)
#define MCF_FBCS_CSMR_WP           (0x00000100)
#define MCF_FBCS_CSMR_BAM(x)       (((x)&0x0000FFFF)<<16)
#define MCF_FBCS_CSMR_BAM_4G       (0xFFFF0000)
#define MCF_FBCS_CSMR_BAM_2G       (0x7FFF0000)
#define MCF_FBCS_CSMR_BAM_1G       (0x3FFF0000)
#define MCF_FBCS_CSMR_BAM_1024M    (0x3FFF0000)
#define MCF_FBCS_CSMR_BAM_512M     (0x1FFF0000)
#define MCF_FBCS_CSMR_BAM_256M     (0x0FFF0000)
#define MCF_FBCS_CSMR_BAM_128M     (0x07FF0000)
#define MCF_FBCS_CSMR_BAM_64M      (0x03FF0000)
#define MCF_FBCS_CSMR_BAM_32M      (0x01FF0000)
#define MCF_FBCS_CSMR_BAM_16M      (0x00FF0000)
#define MCF_FBCS_CSMR_BAM_8M       (0x007F0000)
#define MCF_FBCS_CSMR_BAM_4M       (0x003F0000)
#define MCF_FBCS_CSMR_BAM_2M       (0x001F0000)
#define MCF_FBCS_CSMR_BAM_1M       (0x000F0000)
#define MCF_FBCS_CSMR_BAM_1024K    (0x000F0000)
#define MCF_FBCS_CSMR_BAM_512K     (0x00070000)
#define MCF_FBCS_CSMR_BAM_256K     (0x00030000)
#define MCF_FBCS_CSMR_BAM_128K     (0x00010000)
#define MCF_FBCS_CSMR_BAM_64K      (0x00000000)

/* Bit definitions and macros for MCF_FBCS_CSCR */
#define MCF_FBCS_CSCR_BSTW         (0x00000008)
#define MCF_FBCS_CSCR_BSTR         (0x00000010)
#define MCF_FBCS_CSCR_PS(x)        (((x)&0x00000003)<<6)
#define MCF_FBCS_CSCR_AA           (0x00000100)
#define MCF_FBCS_CSCR_WS(x)        (((x)&0x0000003F)<<10)
#define MCF_FBCS_CSCR_WRAH(x)      (((x)&0x00000003)<<16)
#define MCF_FBCS_CSCR_RDAH(x)      (((x)&0x00000003)<<18)
#define MCF_FBCS_CSCR_ASET(x)      (((x)&0x00000003)<<20)
#define MCF_FBCS_CSCR_SWSEN        (0x00800000)
#define MCF_FBCS_CSCR_SWS(x)       (((x)&0x0000003F)<<26)
#define MCF_FBCS_CSCR_PS_8         (0x0040)
#define MCF_FBCS_CSCR_PS_16        (0x0080)
#define MCF_FBCS_CSCR_PS_32        (0x0000)

/********************************************************************/

#endif /* __MCF548X_FBCS_H__ */
