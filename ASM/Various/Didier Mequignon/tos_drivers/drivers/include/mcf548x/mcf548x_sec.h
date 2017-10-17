/*
 * File:    mcf548x_sec.h
 * Purpose: Register and bit definitions
 */

#ifndef __MCF548X_SEC_H__
#define __MCF548X_SEC_H__

/*********************************************************************
*
* Integrated Security Engine (SEC)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_SEC_EUACRH                    (*(vuint32*)(&__MBAR[0x021000]))
#define MCF_SEC_EUACRL                    (*(vuint32*)(&__MBAR[0x021004]))
#define MCF_SEC_EUASRH                    (*(vuint32*)(&__MBAR[0x021028]))
#define MCF_SEC_EUASRL                    (*(vuint32*)(&__MBAR[0x02102C]))
#define MCF_SEC_SIMRH                     (*(vuint32*)(&__MBAR[0x021008]))
#define MCF_SEC_SIMRL                     (*(vuint32*)(&__MBAR[0x02100C]))
#define MCF_SEC_SISRH                     (*(vuint32*)(&__MBAR[0x021010]))
#define MCF_SEC_SISRL                     (*(vuint32*)(&__MBAR[0x021014]))
#define MCF_SEC_SICRH                     (*(vuint32*)(&__MBAR[0x021018]))
#define MCF_SEC_SICRL                     (*(vuint32*)(&__MBAR[0x02101C]))
#define MCF_SEC_SIDR                      (*(vuint32*)(&__MBAR[0x021020]))
#define MCF_SEC_SMCR                      (*(vuint32*)(&__MBAR[0x021030]))
#define MCF_SEC_MEAR                      (*(vuint32*)(&__MBAR[0x021038]))
#define MCF_SEC_CCCR0                     (*(vuint32*)(&__MBAR[0x02200C]))
#define MCF_SEC_CCCR1                     (*(vuint32*)(&__MBAR[0x02300C]))
#define MCF_SEC_CCPSRH0                   (*(vuint32*)(&__MBAR[0x022010]))
#define MCF_SEC_CCPSRH1                   (*(vuint32*)(&__MBAR[0x023010]))
#define MCF_SEC_CCPSRL0                   (*(vuint32*)(&__MBAR[0x022014]))
#define MCF_SEC_CCPSRL1                   (*(vuint32*)(&__MBAR[0x023014]))
#define MCF_SEC_CDPR0                     (*(vuint32*)(&__MBAR[0x022044]))
#define MCF_SEC_CDPR1                     (*(vuint32*)(&__MBAR[0x023044]))
#define MCF_SEC_FR0                       (*(vuint32*)(&__MBAR[0x02204C]))
#define MCF_SEC_FR1                       (*(vuint32*)(&__MBAR[0x02304C]))
#define MCF_SEC_AFRCR                     (*(vuint32*)(&__MBAR[0x028018]))
#define MCF_SEC_AFSR                      (*(vuint32*)(&__MBAR[0x028028]))
#define MCF_SEC_AFISR                     (*(vuint32*)(&__MBAR[0x028030]))
#define MCF_SEC_AFIMR                     (*(vuint32*)(&__MBAR[0x028038]))
#define MCF_SEC_DRCR                      (*(vuint32*)(&__MBAR[0x02A018]))
#define MCF_SEC_DSR                       (*(vuint32*)(&__MBAR[0x02A028]))
#define MCF_SEC_DISR                      (*(vuint32*)(&__MBAR[0x02A030]))
#define MCF_SEC_DIMR                      (*(vuint32*)(&__MBAR[0x02A038]))
#define MCF_SEC_MDRCR                     (*(vuint32*)(&__MBAR[0x02C018]))
#define MCF_SEC_MDSR                      (*(vuint32*)(&__MBAR[0x02C028]))
#define MCF_SEC_MDISR                     (*(vuint32*)(&__MBAR[0x02C030]))
#define MCF_SEC_MDIMR                     (*(vuint32*)(&__MBAR[0x02C038]))
#define MCF_SEC_RNGRCR                    (*(vuint32*)(&__MBAR[0x02E018]))
#define MCF_SEC_RNGSR                     (*(vuint32*)(&__MBAR[0x02E028]))
#define MCF_SEC_RNGISR                    (*(vuint32*)(&__MBAR[0x02E030]))
#define MCF_SEC_RNGIMR                    (*(vuint32*)(&__MBAR[0x02E038]))
#define MCF_SEC_AESRCR                    (*(vuint32*)(&__MBAR[0x032018]))
#define MCF_SEC_AESSR                     (*(vuint32*)(&__MBAR[0x032028]))
#define MCF_SEC_AESISR                    (*(vuint32*)(&__MBAR[0x032030]))
#define MCF_SEC_AESIMR                    (*(vuint32*)(&__MBAR[0x032038]))

/* Bit definitions and macros for MCF_SEC_EUACRH */
#define MCF_SEC_EUACRH_AFEU(x)            (((x)&0x0000000F)<<0)
#define MCF_SEC_EUACRH_MDEU(x)            (((x)&0x0000000F)<<8)
#define MCF_SEC_EUACRH_RNG(x)             (((x)&0x0000000F)<<24)
#define MCF_SEC_EUACRH_RNG_NOASSIGN       (0x00000000)
#define MCF_SEC_EUACRH_RNG_CHA0           (0x01000000)
#define MCF_SEC_EUACRH_RNG_CHA1           (0x02000000)
#define MCF_SEC_EUACRH_MDEU_NOASSIGN      (0x00000000)
#define MCF_SEC_EUACRH_MDEU_CHA0          (0x00000100)
#define MCF_SEC_EUACRH_MDEU_CHA1          (0x00000200)
#define MCF_SEC_EUACRH_AFEU_NOASSIGN      (0x00000000)
#define MCF_SEC_EUACRH_AFEU_CHA0          (0x00000001)
#define MCF_SEC_EUACRH_AFEU_CHA1          (0x00000002)

/* Bit definitions and macros for MCF_SEC_EUACRL */
#define MCF_SEC_EUACRL_AESU(x)            (((x)&0x0000000F)<<16)
#define MCF_SEC_EUACRL_DEU(x)             (((x)&0x0000000F)<<24)
#define MCF_SEC_EUACRL_DEU_NOASSIGN       (0x00000000)
#define MCF_SEC_EUACRL_DEU_CHA0           (0x01000000)
#define MCF_SEC_EUACRL_DEU_CHA1           (0x02000000)
#define MCF_SEC_EUACRL_AESU_NOASSIGN      (0x00000000)
#define MCF_SEC_EUACRL_AESU_CHA0          (0x00010000)
#define MCF_SEC_EUACRL_AESU_CHA1          (0x00020000)

/* Bit definitions and macros for MCF_SEC_EUASRH */
#define MCF_SEC_EUASRH_AFEU(x)            (((x)&0x0000000F)<<0)
#define MCF_SEC_EUASRH_MDEU(x)            (((x)&0x0000000F)<<8)
#define MCF_SEC_EUASRH_RNG(x)             (((x)&0x0000000F)<<24)

/* Bit definitions and macros for MCF_SEC_EUASRL */
#define MCF_SEC_EUASRL_AESU(x)            (((x)&0x0000000F)<<16)
#define MCF_SEC_EUASRL_DEU(x)             (((x)&0x0000000F)<<24)

/* Bit definitions and macros for MCF_SEC_SIMRH */
#define MCF_SEC_SIMRH_AERR                (0x08000000)
#define MCF_SEC_SIMRH_CHA0DN              (0x10000000)
#define MCF_SEC_SIMRH_CHA0ERR             (0x20000000)
#define MCF_SEC_SIMRH_CHA1DN              (0x40000000)
#define MCF_SEC_SIMRH_CHA1ERR             (0x80000000)

/* Bit definitions and macros for MCF_SEC_SIMRL */
#define MCF_SEC_SIMRL_TEA                 (0x00000040)
#define MCF_SEC_SIMRL_DEUDN               (0x00000100)
#define MCF_SEC_SIMRL_DEUERR              (0x00000200)
#define MCF_SEC_SIMRL_AESUDN              (0x00001000)
#define MCF_SEC_SIMRL_AESUERR             (0x00002000)
#define MCF_SEC_SIMRL_MDEUDN              (0x00010000)
#define MCF_SEC_SIMRL_MDEUERR             (0x00020000)
#define MCF_SEC_SIMRL_AFEUDN              (0x00100000)
#define MCF_SEC_SIMRL_AFEUERR             (0x00200000)
#define MCF_SEC_SIMRL_RNGDN               (0x01000000)
#define MCF_SEC_SIMRL_RNGERR              (0x02000000)

/* Bit definitions and macros for MCF_SEC_SISRH */
#define MCF_SEC_SISRH_AERR                (0x08000000)
#define MCF_SEC_SISRH_CHA0DN              (0x10000000)
#define MCF_SEC_SISRH_CHA0ERR             (0x20000000)
#define MCF_SEC_SISRH_CHA1DN              (0x40000000)
#define MCF_SEC_SISRH_CHA1ERR             (0x80000000)

/* Bit definitions and macros for MCF_SEC_SISRL */
#define MCF_SEC_SISRL_TEA                 (0x00000040)
#define MCF_SEC_SISRL_DEUDN               (0x00000100)
#define MCF_SEC_SISRL_DEUERR              (0x00000200)
#define MCF_SEC_SISRL_AESUDN              (0x00001000)
#define MCF_SEC_SISRL_AESUERR             (0x00002000)
#define MCF_SEC_SISRL_MDEUDN              (0x00010000)
#define MCF_SEC_SISRL_MDEUERR             (0x00020000)
#define MCF_SEC_SISRL_AFEUDN              (0x00100000)
#define MCF_SEC_SISRL_AFEUERR             (0x00200000)
#define MCF_SEC_SISRL_RNGDN               (0x01000000)
#define MCF_SEC_SISRL_RNGERR              (0x02000000)

/* Bit definitions and macros for MCF_SEC_SICRH */
#define MCF_SEC_SICRH_AERR                (0x08000000)
#define MCF_SEC_SICRH_CHA0DN              (0x10000000)
#define MCF_SEC_SICRH_CHA0ERR             (0x20000000)
#define MCF_SEC_SICRH_CHA1DN              (0x40000000)
#define MCF_SEC_SICRH_CHA1ERR             (0x80000000)

/* Bit definitions and macros for MCF_SEC_SICRL */
#define MCF_SEC_SICRL_TEA                 (0x00000040)
#define MCF_SEC_SICRL_DEUDN               (0x00000100)
#define MCF_SEC_SICRL_DEUERR              (0x00000200)
#define MCF_SEC_SICRL_AESUDN              (0x00001000)
#define MCF_SEC_SICRL_AESUERR             (0x00002000)
#define MCF_SEC_SICRL_MDEUDN              (0x00010000)
#define MCF_SEC_SICRL_MDEUERR             (0x00020000)
#define MCF_SEC_SICRL_AFEUDN              (0x00100000)
#define MCF_SEC_SICRL_AFEUERR             (0x00200000)
#define MCF_SEC_SICRL_RNGDN               (0x01000000)
#define MCF_SEC_SICRL_RNGERR              (0x02000000)

/* Bit definitions and macros for MCF_SEC_SIDR */
#define MCF_SEC_SIDR_VERSION(x)           (((x)&0xFFFFFFFF)<<0)

/* Bit definitions and macros for MCF_SEC_SMCR */
#define MCF_SEC_SMCR_CURR_CHAN(x)         (((x)&0x0000000F)<<4)
#define MCF_SEC_SMCR_SWR                  (0x01000000)
#define MCF_SEC_SMCR_CURR_CHAN_1          (0x00000010)
#define MCF_SEC_SMCR_CURR_CHAN_2          (0x00000020)

/* Bit definitions and macros for MCF_SEC_MEAR */
#define MCF_SEC_MEAR_ADDRESS(x)           (((x)&0xFFFFFFFF)<<0)

/* Bit definitions and macros for MCF_SEC_CCCR */
#define MCF_SEC_CCCR_RST                  (0x00000001)
#define MCF_SEC_CCCR_CDIE                 (0x00000002)
#define MCF_SEC_CCCR_NT                   (0x00000004)
#define MCF_SEC_CCCR_NE                   (0x00000008)
#define MCF_SEC_CCCR_WE                   (0x00000010)
#define MCF_SEC_CCCR_BURST_SIZE(x)        (((x)&0x00000007)<<8)
#define MCF_SEC_CCCR_BURST_SIZE_2         (0x00000000)
#define MCF_SEC_CCCR_BURST_SIZE_8         (0x00000100)
#define MCF_SEC_CCCR_BURST_SIZE_16        (0x00000200)
#define MCF_SEC_CCCR_BURST_SIZE_24        (0x00000300)
#define MCF_SEC_CCCR_BURST_SIZE_32        (0x00000400)
#define MCF_SEC_CCCR_BURST_SIZE_40        (0x00000500)
#define MCF_SEC_CCCR_BURST_SIZE_48        (0x00000600)
#define MCF_SEC_CCCR_BURST_SIZE_56        (0x00000700)

/* Bit definitions and macros for MCF_SEC_CCPSRH */
#define MCF_SEC_CCPSRH_STATE(x)           (((x)&0x000000FF)<<0)

/* Bit definitions and macros for MCF_SEC_CCPSRL */
#define MCF_SEC_CCPSRL_PAIR_PTR(x)        (((x)&0x000000FF)<<0)
#define MCF_SEC_CCPSRL_EUERR              (0x00000100)
#define MCF_SEC_CCPSRL_SERR               (0x00000200)
#define MCF_SEC_CCPSRL_DERR               (0x00000400)
#define MCF_SEC_CCPSRL_PERR               (0x00001000)
#define MCF_SEC_CCPSRL_TEA                (0x00002000)
#define MCF_SEC_CCPSRL_SD                 (0x00010000)
#define MCF_SEC_CCPSRL_PD                 (0x00020000)
#define MCF_SEC_CCPSRL_SRD                (0x00040000)
#define MCF_SEC_CCPSRL_PRD                (0x00080000)
#define MCF_SEC_CCPSRL_SG                 (0x00100000)
#define MCF_SEC_CCPSRL_PG                 (0x00200000)
#define MCF_SEC_CCPSRL_SR                 (0x00400000)
#define MCF_SEC_CCPSRL_PR                 (0x00800000)
#define MCF_SEC_CCPSRL_MO                 (0x01000000)
#define MCF_SEC_CCPSRL_MI                 (0x02000000)
#define MCF_SEC_CCPSRL_STAT               (0x04000000)

/* Bit definitions and macros for MCF_SEC_CDPR */
#define MCF_SEC_CDPR_CURRENT_DESC_PTR(x)  (((x)&0xFFFFFFFF)<<0)

/* Bit definitions and macros for MCF_SEC_FR */
#define MCF_SEC_FR_FETCH_ADDR(x)          (((x)&0xFFFFFFFF)<<0)

/* Bit definitions and macros for MCF_SEC_AFRCR */
#define MCF_SEC_AFRCR_SR                  (0x01000000)
#define MCF_SEC_AFRCR_MI                  (0x02000000)
#define MCF_SEC_AFRCR_RI                  (0x04000000)

/* Bit definitions and macros for MCF_SEC_AFSR */
#define MCF_SEC_AFSR_RD                   (0x01000000)
#define MCF_SEC_AFSR_ID                   (0x02000000)
#define MCF_SEC_AFSR_IE                   (0x04000000)
#define MCF_SEC_AFSR_OFE                  (0x08000000)
#define MCF_SEC_AFSR_IFW                  (0x10000000)
#define MCF_SEC_AFSR_HALT                 (0x20000000)

/* Bit definitions and macros for MCF_SEC_AFISR */
#define MCF_SEC_AFISR_DSE                 (0x00010000)
#define MCF_SEC_AFISR_KSE                 (0x00020000)
#define MCF_SEC_AFISR_CE                  (0x00040000)
#define MCF_SEC_AFISR_ERE                 (0x00080000)
#define MCF_SEC_AFISR_IE                  (0x00100000)
#define MCF_SEC_AFISR_OFU                 (0x02000000)
#define MCF_SEC_AFISR_IFO                 (0x04000000)
#define MCF_SEC_AFISR_IFE                 (0x10000000)
#define MCF_SEC_AFISR_OFE                 (0x20000000)
#define MCF_SEC_AFISR_AE                  (0x40000000)
#define MCF_SEC_AFISR_ME                  (0x80000000)

/* Bit definitions and macros for MCF_SEC_AFIMR */
#define MCF_SEC_AFIMR_DSE                 (0x00010000)
#define MCF_SEC_AFIMR_KSE                 (0x00020000)
#define MCF_SEC_AFIMR_CE                  (0x00040000)
#define MCF_SEC_AFIMR_ERE                 (0x00080000)
#define MCF_SEC_AFIMR_IE                  (0x00100000)
#define MCF_SEC_AFIMR_OFU                 (0x02000000)
#define MCF_SEC_AFIMR_IFO                 (0x04000000)
#define MCF_SEC_AFIMR_IFE                 (0x10000000)
#define MCF_SEC_AFIMR_OFE                 (0x20000000)
#define MCF_SEC_AFIMR_AE                  (0x40000000)
#define MCF_SEC_AFIMR_ME                  (0x80000000)

/* Bit definitions and macros for MCF_SEC_DRCR */
#define MCF_SEC_DRCR_SR                   (0x01000000)
#define MCF_SEC_DRCR_MI                   (0x02000000)
#define MCF_SEC_DRCR_RI                   (0x04000000)

/* Bit definitions and macros for MCF_SEC_DSR */
#define MCF_SEC_DSR_RD                    (0x01000000)
#define MCF_SEC_DSR_ID                    (0x02000000)
#define MCF_SEC_DSR_IE                    (0x04000000)
#define MCF_SEC_DSR_OFR                   (0x08000000)
#define MCF_SEC_DSR_IFW                   (0x10000000)
#define MCF_SEC_DSR_HALT                  (0x20000000)

/* Bit definitions and macros for MCF_SEC_DISR */
#define MCF_SEC_DISR_DSE                  (0x00010000)
#define MCF_SEC_DISR_KSE                  (0x00020000)
#define MCF_SEC_DISR_CE                   (0x00040000)
#define MCF_SEC_DISR_ERE                  (0x00080000)
#define MCF_SEC_DISR_IE                   (0x00100000)
#define MCF_SEC_DISR_KPE                  (0x00200000)
#define MCF_SEC_DISR_OFU                  (0x02000000)
#define MCF_SEC_DISR_IFO                  (0x04000000)
#define MCF_SEC_DISR_IFE                  (0x10000000)
#define MCF_SEC_DISR_OFE                  (0x20000000)
#define MCF_SEC_DISR_AE                   (0x40000000)
#define MCF_SEC_DISR_ME                   (0x80000000)

/* Bit definitions and macros for MCF_SEC_DIMR */
#define MCF_SEC_DIMR_DSE                  (0x00010000)
#define MCF_SEC_DIMR_KSE                  (0x00020000)
#define MCF_SEC_DIMR_CE                   (0x00040000)
#define MCF_SEC_DIMR_ERE                  (0x00080000)
#define MCF_SEC_DIMR_IE                   (0x00100000)
#define MCF_SEC_DIMR_KPE                  (0x00200000)
#define MCF_SEC_DIMR_OFU                  (0x02000000)
#define MCF_SEC_DIMR_IFO                  (0x04000000)
#define MCF_SEC_DIMR_IFE                  (0x10000000)
#define MCF_SEC_DIMR_OFE                  (0x20000000)
#define MCF_SEC_DIMR_AE                   (0x40000000)
#define MCF_SEC_DIMR_ME                   (0x80000000)

/* Bit definitions and macros for MCF_SEC_MDRCR */
#define MCF_SEC_MDRCR_SR                  (0x01000000)
#define MCF_SEC_MDRCR_MI                  (0x02000000)
#define MCF_SEC_MDRCR_RI                  (0x04000000)

/* Bit definitions and macros for MCF_SEC_MDSR */
#define MCF_SEC_MDSR_RD                   (0x01000000)
#define MCF_SEC_MDSR_ID                   (0x02000000)
#define MCF_SEC_MDSR_IE                   (0x04000000)
#define MCF_SEC_MDSR_IFW                  (0x10000000)
#define MCF_SEC_MDSR_HALT                 (0x20000000)

/* Bit definitions and macros for MCF_SEC_MDISR */
#define MCF_SEC_MDISR_DSE                 (0x00010000)
#define MCF_SEC_MDISR_KSE                 (0x00020000)
#define MCF_SEC_MDISR_CE                  (0x00040000)
#define MCF_SEC_MDISR_ERE                 (0x00080000)
#define MCF_SEC_MDISR_IE                  (0x00100000)
#define MCF_SEC_MDISR_IFO                 (0x04000000)
#define MCF_SEC_MDISR_AE                  (0x40000000)
#define MCF_SEC_MDISR_ME                  (0x80000000)

/* Bit definitions and macros for MCF_SEC_MDIMR */
#define MCF_SEC_MDIMR_DSE                 (0x00010000)
#define MCF_SEC_MDIMR_KSE                 (0x00020000)
#define MCF_SEC_MDIMR_CE                  (0x00040000)
#define MCF_SEC_MDIMR_ERE                 (0x00080000)
#define MCF_SEC_MDIMR_IE                  (0x00100000)
#define MCF_SEC_MDIMR_IFO                 (0x04000000)
#define MCF_SEC_MDIMR_AE                  (0x40000000)
#define MCF_SEC_MDIMR_ME                  (0x80000000)

/* Bit definitions and macros for MCF_SEC_RNGRCR */
#define MCF_SEC_RNGRCR_SR                 (0x01000000)
#define MCF_SEC_RNGRCR_MI                 (0x02000000)
#define MCF_SEC_RNGRCR_RI                 (0x04000000)

/* Bit definitions and macros for MCF_SEC_RNGSR */
#define MCF_SEC_RNGSR_RD                  (0x01000000)
#define MCF_SEC_RNGSR_O                   (0x02000000)
#define MCF_SEC_RNGSR_IE                  (0x04000000)
#define MCF_SEC_RNGSR_OFR                 (0x08000000)
#define MCF_SEC_RNGSR_HALT                (0x20000000)

/* Bit definitions and macros for MCF_SEC_RNGISR */
#define MCF_SEC_RNGISR_IE                 (0x00100000)
#define MCF_SEC_RNGISR_OFU                (0x02000000)
#define MCF_SEC_RNGISR_AE                 (0x40000000)
#define MCF_SEC_RNGISR_ME                 (0x80000000)

/* Bit definitions and macros for MCF_SEC_RNGIMR */
#define MCF_SEC_RNGIMR_IE                 (0x00100000)
#define MCF_SEC_RNGIMR_OFU                (0x02000000)
#define MCF_SEC_RNGIMR_AE                 (0x40000000)
#define MCF_SEC_RNGIMR_ME                 (0x80000000)

/* Bit definitions and macros for MCF_SEC_AESRCR */
#define MCF_SEC_AESRCR_SR                 (0x01000000)
#define MCF_SEC_AESRCR_MI                 (0x02000000)
#define MCF_SEC_AESRCR_RI                 (0x04000000)

/* Bit definitions and macros for MCF_SEC_AESSR */
#define MCF_SEC_AESSR_RD                  (0x01000000)
#define MCF_SEC_AESSR_ID                  (0x02000000)
#define MCF_SEC_AESSR_IE                  (0x04000000)
#define MCF_SEC_AESSR_OFR                 (0x08000000)
#define MCF_SEC_AESSR_IFW                 (0x10000000)
#define MCF_SEC_AESSR_HALT                (0x20000000)

/* Bit definitions and macros for MCF_SEC_AESISR */
#define MCF_SEC_AESISR_DSE                (0x00010000)
#define MCF_SEC_AESISR_KSE                (0x00020000)
#define MCF_SEC_AESISR_CE                 (0x00040000)
#define MCF_SEC_AESISR_ERE                (0x00080000)
#define MCF_SEC_AESISR_IE                 (0x00100000)
#define MCF_SEC_AESISR_OFU                (0x02000000)
#define MCF_SEC_AESISR_IFO                (0x04000000)
#define MCF_SEC_AESISR_IFE                (0x10000000)
#define MCF_SEC_AESISR_OFE                (0x20000000)
#define MCF_SEC_AESISR_AE                 (0x40000000)
#define MCF_SEC_AESISR_ME                 (0x80000000)

/* Bit definitions and macros for MCF_SEC_AESIMR */
#define MCF_SEC_AESIMR_DSE                (0x00010000)
#define MCF_SEC_AESIMR_KSE                (0x00020000)
#define MCF_SEC_AESIMR_CE                 (0x00040000)
#define MCF_SEC_AESIMR_ERE                (0x00080000)
#define MCF_SEC_AESIMR_IE                 (0x00100000)
#define MCF_SEC_AESIMR_OFU                (0x02000000)
#define MCF_SEC_AESIMR_IFO                (0x04000000)
#define MCF_SEC_AESIMR_IFE                (0x10000000)
#define MCF_SEC_AESIMR_OFE                (0x20000000)
#define MCF_SEC_AESIMR_AE                 (0x40000000)
#define MCF_SEC_AESIMR_ME                 (0x80000000)

/********************************************************************/

#endif /* __MCF548X_SEC_H__ */
