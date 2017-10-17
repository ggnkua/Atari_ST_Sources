/*
 * File:    mcf548x_sdramc.h
 * Purpose: Register and bit definitions for the MCF548X
 *
 * Notes:   
 *  
 */

#ifndef __MCF548X_SDRAMC_H__
#define __MCF548X_SDRAMC_H__

/*********************************************************************
*
* SDRAM Controller (SDRAMC)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_SDRAMC_SDRAMDS      (__MBAR+0x000004)
#define MCF_SDRAMC_CS0CFG       (__MBAR+0x000020)
#define MCF_SDRAMC_CS1CFG       (__MBAR+0x000024)
#define MCF_SDRAMC_CS2CFG       (__MBAR+0x000028)
#define MCF_SDRAMC_CS3CFG       (__MBAR+0x00002C)
#define MCF_SDRAMC_CSnCFG(x)    (*(vuint32*)(void*)(&__MBAR[0x000020+((x)*0x004)]))
#define MCF_SDRAMC_SDMR         (__MBAR+0x000100)
#define MCF_SDRAMC_SDCR         (__MBAR+0x000104)
#define MCF_SDRAMC_SDCFG1       (__MBAR+0x000108)
#define MCF_SDRAMC_SDCFG2       (__MBAR+0x00010C)

/* Bit definitions and macros for MCF_SDRAMC_SDRAMDS */
#define MCF_SDRAMC_SDRAMDS_SB_D(x)         (((x)&0x00000003)<<0)
#define MCF_SDRAMC_SDRAMDS_SB_S(x)         (((x)&0x00000003)<<2)
#define MCF_SDRAMC_SDRAMDS_SB_A(x)         (((x)&0x00000003)<<4)
#define MCF_SDRAMC_SDRAMDS_SB_C(x)         (((x)&0x00000003)<<6)
#define MCF_SDRAMC_SDRAMDS_SB_E(x)         (((x)&0x00000003)<<8)
#define MCF_SDRAMC_SDRAMDS_DRIVE_8MA       (0x02)
#define MCF_SDRAMC_SDRAMDS_DRIVE_16MA      (0x01)
#define MCF_SDRAMC_SDRAMDS_DRIVE_24MA      (0x00)
#define MCF_SDRAMC_SDRAMDS_DRIVE_NONE      (0x03)

/* Bit definitions and macros for MCF_SDRAMC_CSnCFG */
#define MCF_SDRAMC_CSnCFG_CSSZ(x)          (((x)&0x0000001F)<<0)
#define MCF_SDRAMC_CSnCFG_CSBA(x)          (((x)&0x00000FFF)<<20)
#define MCF_SDRAMC_CSnCFG_CSSZ_DIABLE      (0x00000000)
#define MCF_SDRAMC_CSnCFG_CSSZ_1MBYTE      (0x00000013)
#define MCF_SDRAMC_CSnCFG_CSSZ_2MBYTE      (0x00000014)
#define MCF_SDRAMC_CSnCFG_CSSZ_4MBYTE      (0x00000015)
#define MCF_SDRAMC_CSnCFG_CSSZ_8MBYTE      (0x00000016)
#define MCF_SDRAMC_CSnCFG_CSSZ_16MBYTE     (0x00000017)
#define MCF_SDRAMC_CSnCFG_CSSZ_32MBYTE     (0x00000018)
#define MCF_SDRAMC_CSnCFG_CSSZ_64MBYTE     (0x00000019)
#define MCF_SDRAMC_CSnCFG_CSSZ_128MBYTE    (0x0000001A)
#define MCF_SDRAMC_CSnCFG_CSSZ_256MBYTE    (0x0000001B)
#define MCF_SDRAMC_CSnCFG_CSSZ_512MBYTE    (0x0000001C)
#define MCF_SDRAMC_CSnCFG_CSSZ_1GBYTE      (0x0000001D)
#define MCF_SDRAMC_CSnCFG_CSSZ_2GBYTE      (0x0000001E)
#define MCF_SDRAMC_CSnCFG_CSSZ_4GBYTE      (0x0000001F)

/* Bit definitions and macros for MCF_SDRAMC_SDMR */
#define MCF_SDRAMC_SDMR_CMD                (0x00010000)
#define MCF_SDRAMC_SDMR_AD(x)              (((x)&0x00000FFF)<<18)
#define MCF_SDRAMC_SDMR_BNKAD(x)           (((x)&0x00000003)<<30)
#define MCF_SDRAMC_SDMR_BNKAD_LMR          (0x00000000)
#define MCF_SDRAMC_SDMR_BNKAD_LEMR         (0x40000000)

/* Bit definitions and macros for MCF_SDRAMC_SDCR */
#define MCF_SDRAMC_SDCR_IPALL              (0x00000002)
#define MCF_SDRAMC_SDCR_IREF               (0x00000004)
#define MCF_SDRAMC_SDCR_BUFF               (0x00000010)
#define MCF_SDRAMC_SDCR_DQS_OE(x)          (((x)&0x0000000F)<<8)
#define MCF_SDRAMC_SDCR_RCNT(x)            (((x)&0x0000003F)<<16)
#define MCF_SDRAMC_SDCR_DRIVE              (0x00400000)
#define MCF_SDRAMC_SDCR_AP                 (0x00800000)
#define MCF_SDRAMC_SDCR_MUX(x)             (((x)&0x00000003)<<24)
#define MCF_SDRAMC_SDCR_REF                (0x10000000)
#define MCF_SDRAMC_SDCR_DDR                (0x20000000)
#define MCF_SDRAMC_SDCR_CKE                (0x40000000)
#define MCF_SDRAMC_SDCR_MODE_EN            (0x80000000)

/* Bit definitions and macros for MCF_SDRAMC_SDCFG1 */
#define MCF_SDRAMC_SDCFG1_WTLAT(x)         (((x)&0x00000007)<<4)
#define MCF_SDRAMC_SDCFG1_REF2ACT(x)       (((x)&0x0000000F)<<8)
#define MCF_SDRAMC_SDCFG1_PRE2ACT(x)       (((x)&0x00000007)<<12)
#define MCF_SDRAMC_SDCFG1_ACT2RW(x)        (((x)&0x00000007)<<16)
#define MCF_SDRAMC_SDCFG1_RDLAT(x)         (((x)&0x0000000F)<<20)
#define MCF_SDRAMC_SDCFG1_SWT2RD(x)        (((x)&0x00000007)<<24)
#define MCF_SDRAMC_SDCFG1_SRD2RW(x)        (((x)&0x0000000F)<<28)

/* Bit definitions and macros for MCF_SDRAMC_SDCFG2 */
#define MCF_SDRAMC_SDCFG2_BL(x)            (((x)&0x0000000F)<<16)
#define MCF_SDRAMC_SDCFG2_BRD2WT(x)        (((x)&0x0000000F)<<20)
#define MCF_SDRAMC_SDCFG2_BWT2RW(x)        (((x)&0x0000000F)<<24)
#define MCF_SDRAMC_SDCFG2_BRD2PRE(x)       (((x)&0x0000000F)<<28)

/********************************************************************/

#endif /* __MCF548X_SDRAMC_H__ */
