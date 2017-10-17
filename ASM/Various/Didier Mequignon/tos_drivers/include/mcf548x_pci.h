/*
 * File:    mcf548x_pci.h
 * Purpose: Register and bit definitions for the MCF548X
 *
 * Notes:   
 *  
 */

#ifndef __MCF548X_PCI_H__
#define __MCF548X_PCI_H__

/*********************************************************************
*
* PCI Bus Controller (PCI)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_PCI_PCIIDR        (__MBAR+0x000B00)
#define MCF_PCI_PCISCR        (__MBAR+0x000B04)
#define MCF_PCI_PCICCRIR      (__MBAR+0x000B08)
#define MCF_PCI_PCICR1        (__MBAR+0x000B0C)
#define MCF_PCI_PCIBAR0       (__MBAR+0x000B10)
#define MCF_PCI_PCIBAR1       (__MBAR+0x000B14)
#define MCF_PCI_PCICR2        (__MBAR+0x000B3C)
#define MCF_PCI_PCIGSCR       (__MBAR+0x000B60)
#define MCF_PCI_PCITBATR0     (__MBAR+0x000B64)
#define MCF_PCI_PCITBATR1     (__MBAR+0x000B68)
#define MCF_PCI_PCITCR        (__MBAR+0x000B6C)
#define MCF_PCI_PCIIW0BTAR    (__MBAR+0x000B70)
#define MCF_PCI_PCIIW1BTAR    (__MBAR+0x000B74)
#define MCF_PCI_PCIIW2BTAR    (__MBAR+0x000B78)
#define MCF_PCI_PCIIWCR       (__MBAR+0x000B80)
#define MCF_PCI_PCIICR        (__MBAR+0x000B84)
#define MCF_PCI_PCIISR        (__MBAR+0x000B88)
#define MCF_PCI_PCICAR        (__MBAR+0x000BF8)
#define MCF_PCI_PCITPSR       (__MBAR+0x008400)
#define MCF_PCI_PCITSAR       (__MBAR+0x008404)
#define MCF_PCI_PCITTCR       (__MBAR+0x008408)
#define MCF_PCI_PCITER        (__MBAR+0x00840C)
#define MCF_PCI_PCITNAR       (__MBAR+0x008410)
#define MCF_PCI_PCITLWR       (__MBAR+0x008414)
#define MCF_PCI_PCITDCR       (__MBAR+0x008418)
#define MCF_PCI_PCITSR        (__MBAR+0x00841C)
#define MCF_PCI_PCITFDR       (__MBAR+0x008440)
#define MCF_PCI_PCITFSR       (__MBAR+0x008444)
#define MCF_PCI_PCITFCR       (__MBAR+0x008448)
#define MCF_PCI_PCITFAR       (__MBAR+0x00844C)
#define MCF_PCI_PCITFRPR      (__MBAR+0x008450)
#define MCF_PCI_PCITFWPR      (__MBAR+0x008454)
#define MCF_PCI_PCIRPSR       (__MBAR+0x008480)
#define MCF_PCI_PCIRSAR       (__MBAR+0x008484)
#define MCF_PCI_PCIRTCR       (__MBAR+0x008488)
#define MCF_PCI_PCIRER        (__MBAR+0x00848C)
#define MCF_PCI_PCIRNAR       (__MBAR+0x008490)
#define MCF_PCI_PCIRDCR       (__MBAR+0x008498)
#define MCF_PCI_PCIRSR        (__MBAR+0x00849C)
#define MCF_PCI_PCIRFDR       (__MBAR+0x0084C0)
#define MCF_PCI_PCIRFSR       (__MBAR+0x0084C4)
#define MCF_PCI_PCIRFCR       (__MBAR+0x0084C8)
#define MCF_PCI_PCIRFAR       (__MBAR+0x0084CC)
#define MCF_PCI_PCIRFRPR      (__MBAR+0x0084D0)
#define MCF_PCI_PCIRFWPR      (__MBAR+0x0084D4)

/* Bit definitions and macros for MCF_PCI_PCIIDR */
#define MCF_PCI_PCIIDR_VENDORID(x)            (((x)&0x0000FFFF)<<0)
#define MCF_PCI_PCIIDR_DEVICEID(x)            (((x)&0x0000FFFF)<<16)

/* Bit definitions and macros for MCF_PCI_PCISCR */
#define MCF_PCI_PCISCR_M                      (0x00000002)
#define MCF_PCI_PCISCR_B                      (0x00000004)
#define MCF_PCI_PCISCR_SP                     (0x00000008)
#define MCF_PCI_PCISCR_MW                     (0x00000010)
#define MCF_PCI_PCISCR_PER                    (0x00000040)
#define MCF_PCI_PCISCR_S                      (0x00000100)
#define MCF_PCI_PCISCR_F                      (0x00000200)
#define MCF_PCI_PCISCR_C                      (0x00100000)
#define MCF_PCI_PCISCR_66M                    (0x00200000)
#define MCF_PCI_PCISCR_R                      (0x00400000)
#define MCF_PCI_PCISCR_FC                     (0x00800000)
#define MCF_PCI_PCISCR_DP                     (0x01000000)
#define MCF_PCI_PCISCR_DT(x)                  (((x)&0x00000003)<<25)
#define MCF_PCI_PCISCR_TS                     (0x08000000)
#define MCF_PCI_PCISCR_TR                     (0x10000000)
#define MCF_PCI_PCISCR_MA                     (0x20000000)
#define MCF_PCI_PCISCR_SE                     (0x40000000)
#define MCF_PCI_PCISCR_PE                     (0x80000000)

/* Bit definitions and macros for MCF_PCI_PCICCRIR */
#define MCF_PCI_PCICCRIR_REVID(x)             (((x)&0x000000FF)<<0)
#define MCF_PCI_PCICCRIR_CLASSCODE(x)         (((x)&0x00FFFFFF)<<8)

/* Bit definitions and macros for MCF_PCI_PCICR1 */
#define MCF_PCI_PCICR1_CACHELINESIZE(x)       (((x)&0x0000000F)<<0)
#define MCF_PCI_PCICR1_LATTIMER(x)            (((x)&0x000000FF)<<8)
#define MCF_PCI_PCICR1_HEADERTYPE(x)          (((x)&0x000000FF)<<16)
#define MCF_PCI_PCICR1_BIST(x)                (((x)&0x000000FF)<<24)

/* Bit definitions and macros for MCF_PCI_PCIBAR0 */
#define MCF_PCI_PCIBAR0_IO                    (0x00000001)
#define MCF_PCI_PCIBAR0_RANGE(x)              (((x)&0x00000003)<<1)
#define MCF_PCI_PCIBAR0_PREF                  (0x00000008)
#define MCF_PCI_PCIBAR0_BAR0(x)               (((x)&0x00003FFF)<<18)

/* Bit definitions and macros for MCF_PCI_PCIBAR1 */
#define MCF_PCI_PCIBAR1_IO                    (0x00000001)
#define MCF_PCI_PCIBAR1_PREF                  (0x00000008)
#define MCF_PCI_PCIBAR1_BAR1(x)               (((x)&0x00000003)<<30)

/* Bit definitions and macros for MCF_PCI_PCICR2 */
#define MCF_PCI_PCICR2_INTLINE(x)             (((x)&0x000000FF)<<0)
#define MCF_PCI_PCICR2_INTPIN(x)              (((x)&0x000000FF)<<8)
#define MCF_PCI_PCICR2_MINGNT(x)              (((x)&0x000000FF)<<16)
#define MCF_PCI_PCICR2_MAXLAT(x)              (((x)&0x000000FF)<<24)

/* Bit definitions and macros for MCF_PCI_PCIGSCR */
#define MCF_PCI_PCIGSCR_PR                    (0x00000001)
#define MCF_PCI_PCIGSCR_SEE                   (0x00001000)
#define MCF_PCI_PCIGSCR_PEE                   (0x00002000)
#define MCF_PCI_PCIGSCR_SE                    (0x10000000)
#define MCF_PCI_PCIGSCR_PE                    (0x20000000)

/* Bit definitions and macros for MCF_PCI_PCITBATR0 */
#define MCF_PCI_PCITBATR0_EN                  (0x00000001)
#define MCF_PCI_PCITBATR0_BAT0(x)             (((x)&0x00003FFF)<<18)

/* Bit definitions and macros for MCF_PCI_PCITBATR1 */
#define MCF_PCI_PCITBATR1_EN                  (0x00000001)
#define MCF_PCI_PCITBATR1_BAT1(x)             (((x)&0x00000003)<<30)

/* Bit definitions and macros for MCF_PCI_PCITCR */
#define MCF_PCI_PCITCR_P                      (0x00010000)
#define MCF_PCI_PCITCR_LD                     (0x01000000)

/* Bit definitions and macros for MCF_PCI_PCIIW0BTAR */
#define MCF_PCI_PCIIW0BTAR_WTA0(x)            (((x)&0x000000FF)<<8)
#define MCF_PCI_PCIIW0BTAR_WAM0(x)            (((x)&0x000000FF)<<16)
#define MCF_PCI_PCIIW0BTAR_WBA0(x)            (((x)&0x000000FF)<<24)

/* Bit definitions and macros for MCF_PCI_PCIIW1BTAR */
#define MCF_PCI_PCIIW1BTAR_WTA1(x)            (((x)&0x000000FF)<<8)
#define MCF_PCI_PCIIW1BTAR_WAM1(x)            (((x)&0x000000FF)<<16)
#define MCF_PCI_PCIIW1BTAR_WBA1(x)            (((x)&0x000000FF)<<24)

/* Bit definitions and macros for MCF_PCI_PCIIW2BTAR */
#define MCF_PCI_PCIIW2BTAR_WTA2(x)            (((x)&0x000000FF)<<8)
#define MCF_PCI_PCIIW2BTAR_WAM2(x)            (((x)&0x000000FF)<<16)
#define MCF_PCI_PCIIW2BTAR_WBA2(x)            (((x)&0x000000FF)<<24)

/* Bit definitions and macros for MCF_PCI_PCIIWCR */
#define MCF_PCI_PCIIWCR_WINCTRL2(x)           (((x)&0x0000000F)<<8)
#define MCF_PCI_PCIIWCR_WINCTRL1(x)           (((x)&0x0000000F)<<16)
#define MCF_PCI_PCIIWCR_WINCTRL0(x)           (((x)&0x0000000F)<<24)
#define MCF_PCI_PCIIWCR_WINCTRL0_MEMREAD      (0x01000000)
#define MCF_PCI_PCIIWCR_WINCTRL0_MEMRDLINE    (0x03000000)
#define MCF_PCI_PCIIWCR_WINCTRL0_MEMRDMUL     (0x05000000)
#define MCF_PCI_PCIIWCR_WINCTRL0_IO           (0x09000000)
#define MCF_PCI_PCIIWCR_WINCTRL1_MEMREAD      (0x00010000)
#define MCF_PCI_PCIIWCR_WINCTRL1_MEMRDLINE    (0x00030000)
#define MCF_PCI_PCIIWCR_WINCTRL1_MEMRDMUL     (0x00050000)
#define MCF_PCI_PCIIWCR_WINCTRL1_IO           (0x00090000)
#define MCF_PCI_PCIIWCR_WINCTRL2_MEMREAD      (0x00000100)
#define MCF_PCI_PCIIWCR_WINCTRL2_MEMRDLINE    (0x00000300)
#define MCF_PCI_PCIIWCR_WINCTRL2_MEMRDMUL     (0x00000500)
#define MCF_PCI_PCIIWCR_WINCTRL2_IO           (0x00000900)

/* Bit definitions and macros for MCF_PCI_PCIICR */
#define MCF_PCI_PCIICR_MAXRETRY(x)            (((x)&0x000000FF)<<0)
#define MCF_PCI_PCIICR_TAE                    (0x01000000)
#define MCF_PCI_PCIICR_IAE                    (0x02000000)
#define MCF_PCI_PCIICR_REE                    (0x04000000)

/* Bit definitions and macros for MCF_PCI_PCIISR */
#define MCF_PCI_PCIISR_TA                     (0x01000000)
#define MCF_PCI_PCIISR_IA                     (0x02000000)
#define MCF_PCI_PCIISR_RE                     (0x04000000)

/* Bit definitions and macros for MCF_PCI_PCICAR */
#define MCF_PCI_PCICAR_DWORD(x)               (((x)&0x0000003F)<<2)
#define MCF_PCI_PCICAR_FUNCNUM(x)             (((x)&0x00000007)<<8)
#define MCF_PCI_PCICAR_DEVNUM(x)              (((x)&0x0000001F)<<11)
#define MCF_PCI_PCICAR_BUSNUM(x)              (((x)&0x000000FF)<<16)
#define MCF_PCI_PCICAR_E                      (0x80000000)

/* Bit definitions and macros for MCF_PCI_PCITPSR */
#define MCF_PCI_PCITPSR_PKTSIZE(x)            (((x)&0x0000FFFF)<<16)

/* Bit definitions and macros for MCF_PCI_PCITTCR */
#define MCF_PCI_PCITTCR_DI                    (0x00000001)
#define MCF_PCI_PCITTCR_W                     (0x00000010)
#define MCF_PCI_PCITTCR_MAXBEATS(x)           (((x)&0x00000007)<<8)
#define MCF_PCI_PCITTCR_MAXRETRY(x)           (((x)&0x000000FF)<<16)
#define MCF_PCI_PCITTCR_PCICMD(x)             (((x)&0x0000000F)<<24)

/* Bit definitions and macros for MCF_PCI_PCITER */
#define MCF_PCI_PCITER_NE                     (0x00010000)
#define MCF_PCI_PCITER_IAE                    (0x00020000)
#define MCF_PCI_PCITER_TAE                    (0x00040000)
#define MCF_PCI_PCITER_RE                     (0x00080000)
#define MCF_PCI_PCITER_SE                     (0x00100000)
#define MCF_PCI_PCITER_FEE                    (0x00200000)
#define MCF_PCI_PCITER_ME                     (0x01000000)
#define MCF_PCI_PCITER_BE                     (0x08000000)
#define MCF_PCI_PCITER_CM                     (0x10000000)
#define MCF_PCI_PCITER_RF                     (0x40000000)
#define MCF_PCI_PCITER_RC                     (0x80000000)

/* Bit definitions and macros for MCF_PCI_PCITDCR */
#define MCF_PCI_PCITDCR_PKTSDONE(x)           (((x)&0x0000FFFF)<<0)
#define MCF_PCI_PCITDCR_BYTESDONE(x)          (((x)&0x0000FFFF)<<16)

/* Bit definitions and macros for MCF_PCI_PCITSR */
#define MCF_PCI_PCITSR_IA                     (0x00010000)
#define MCF_PCI_PCITSR_TA                     (0x00020000)
#define MCF_PCI_PCITSR_RE                     (0x00040000)
#define MCF_PCI_PCITSR_SE                     (0x00080000)
#define MCF_PCI_PCITSR_FE                     (0x00100000)
#define MCF_PCI_PCITSR_BE1                    (0x00200000)
#define MCF_PCI_PCITSR_BE2                    (0x00400000)
#define MCF_PCI_PCITSR_BE3                    (0x00800000)
#define MCF_PCI_PCITSR_NT                     (0x01000000)

/* Bit definitions and macros for MCF_PCI_PCITFSR */
#define MCF_PCI_PCITFSR_EMT                   (0x00010000)
#define MCF_PCI_PCITFSR_ALARM                 (0x00020000)
#define MCF_PCI_PCITFSR_FU                    (0x00040000)
#define MCF_PCI_PCITFSR_FR                    (0x00080000)
#define MCF_PCI_PCITFSR_OF                    (0x00100000)
#define MCF_PCI_PCITFSR_UF                    (0x00200000)
#define MCF_PCI_PCITFSR_RXW                   (0x00400000)

/* Bit definitions and macros for MCF_PCI_PCITFCR */
#define MCF_PCI_PCITFCR_OF_MSK                (0x00080000)
#define MCF_PCI_PCITFCR_UF_MSK                (0x00100000)
#define MCF_PCI_PCITFCR_RXW_MSK               (0x00200000)
#define MCF_PCI_PCITFCR_FAE_MSK               (0x00400000)
#define MCF_PCI_PCITFCR_IP_MSK                (0x00800000)
#define MCF_PCI_PCITFCR_GR(x)                 (((x)&0x00000007)<<24)

/* Bit definitions and macros for MCF_PCI_PCITFAR */
#define MCF_PCI_PCITFAR_ALARM(x)              (((x)&0x0000007F)<<0)

/* Bit definitions and macros for MCF_PCI_PCITFRPR */
#define MCF_PCI_PCITFRPR_READ(x)              (((x)&0x00000FFF)<<0)

/* Bit definitions and macros for MCF_PCI_PCITFWPR */
#define MCF_PCI_PCITFWPR_WRITE(x)             (((x)&0x00000FFF)<<0)

/* Bit definitions and macros for MCF_PCI_PCIRPSR */
#define MCF_PCI_PCIRPSR_PKTSIZE(x)            (((x)&0x0000FFFF)<<16)

/* Bit definitions and macros for MCF_PCI_PCIRTCR */
#define MCF_PCI_PCIRTCR_DI                    (0x00000001)
#define MCF_PCI_PCIRTCR_W                     (0x00000010)
#define MCF_PCI_PCIRTCR_MAXBEATS(x)           (((x)&0x00000007)<<8)
#define MCF_PCI_PCIRTCR_FB                    (0x00001000)
#define MCF_PCI_PCIRTCR_MAXRETRY(x)           (((x)&0x000000FF)<<16)
#define MCF_PCI_PCIRTCR_PCICMD(x)             (((x)&0x0000000F)<<24)

/* Bit definitions and macros for MCF_PCI_PCIRER */
#define MCF_PCI_PCIRER_NE                     (0x00010000)
#define MCF_PCI_PCIRER_IAE                    (0x00020000)
#define MCF_PCI_PCIRER_TAE                    (0x00040000)
#define MCF_PCI_PCIRER_RE                     (0x00080000)
#define MCF_PCI_PCIRER_SE                     (0x00100000)
#define MCF_PCI_PCIRER_FEE                    (0x00200000)
#define MCF_PCI_PCIRER_ME                     (0x01000000)
#define MCF_PCI_PCIRER_BE                     (0x08000000)
#define MCF_PCI_PCIRER_CM                     (0x10000000)
#define MCF_PCI_PCIRER_FE                     (0x20000000)
#define MCF_PCI_PCIRER_RF                     (0x40000000)
#define MCF_PCI_PCIRER_RC                     (0x80000000)

/* Bit definitions and macros for MCF_PCI_PCIRDCR */
#define MCF_PCI_PCIRDCR_PKTSDONE(x)           (((x)&0x0000FFFF)<<0)
#define MCF_PCI_PCIRDCR_BYTESDONE(x)          (((x)&0x0000FFFF)<<16)

/* Bit definitions and macros for MCF_PCI_PCIRSR */
#define MCF_PCI_PCIRSR_IA                     (0x00010000)
#define MCF_PCI_PCIRSR_TA                     (0x00020000)
#define MCF_PCI_PCIRSR_RE                     (0x00040000)
#define MCF_PCI_PCIRSR_SE                     (0x00080000)
#define MCF_PCI_PCIRSR_FE                     (0x00100000)
#define MCF_PCI_PCIRSR_BE1                    (0x00200000)
#define MCF_PCI_PCIRSR_BE2                    (0x00400000)
#define MCF_PCI_PCIRSR_BE3                    (0x00800000)
#define MCF_PCI_PCIRSR_NT                     (0x01000000)

/* Bit definitions and macros for MCF_PCI_PCIRFSR */
#define MCF_PCI_PCIRFSR_EMT                   (0x00010000)
#define MCF_PCI_PCIRFSR_ALARM                 (0x00020000)
#define MCF_PCI_PCIRFSR_FU                    (0x00040000)
#define MCF_PCI_PCIRFSR_FR                    (0x00080000)
#define MCF_PCI_PCIRFSR_OF                    (0x00100000)
#define MCF_PCI_PCIRFSR_UF                    (0x00200000)
#define MCF_PCI_PCIRFSR_RXW                   (0x00400000)

/* Bit definitions and macros for MCF_PCI_PCIRFCR */
#define MCF_PCI_PCIRFCR_OF_MSK                (0x00080000)
#define MCF_PCI_PCIRFCR_UF_MSK                (0x00100000)
#define MCF_PCI_PCIRFCR_RXW_MSK               (0x00200000)
#define MCF_PCI_PCIRFCR_FAE_MSK               (0x00400000)
#define MCF_PCI_PCIRFCR_IP_MSK                (0x00800000)
#define MCF_PCI_PCIRFCR_GR(x)                 (((x)&0x00000007)<<24)

/* Bit definitions and macros for MCF_PCI_PCIRFAR */
#define MCF_PCI_PCIRFAR_ALARM(x)              (((x)&0x0000007F)<<0)

/* Bit definitions and macros for MCF_PCI_PCIRFRPR */
#define MCF_PCI_PCIRFRPR_READ(x)              (((x)&0x00000FFF)<<0)

/* Bit definitions and macros for MCF_PCI_PCIRFWPR */
#define MCF_PCI_PCIRFWPR_WRITE(x)             (((x)&0x00000FFF)<<0)

/********************************************************************/

#endif /* __MCF548X_PCI_H__ */
