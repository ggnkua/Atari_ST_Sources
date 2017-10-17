/*
 * MCF5445x Internal Memory Map
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#ifndef __MCF5445X__
#define __MCF5445X__

/*********************************************************************
* Cross-bar switch (XBS)
*********************************************************************/

/* Register read/write macros */
#define MCF_XBS_PRS1             (0xFC004100)
#define MCF_XBS_CRS1             (0xFC004110)
#define MCF_XBS_PRS2             (0xFC004200)
#define MCF_XBS_CRS2             (0xFC004210)
#define MCF_XBS_PRS3             (0xFC004300)
#define MCF_XBS_CRS3             (0xFC004310)
#define MCF_XBS_PRS4             (0xFC004400)
#define MCF_XBS_CRS4             (0xFC004410)
#define MCF_XBS_PRS5             (0xFC004500)
#define MCF_XBS_CRS5             (0xFC004510)
#define MCF_XBS_PRS6             (0xFC004600)
#define MCF_XBS_CRS6             (0xFC004610)
#define MCF_XBS_PRS7             (0xFC004700)
#define MCF_XBS_CRS7             (0xFC004710)

/* Bit definitions and macros for PRS group */
#define XBS_PRS_M0(x)			(((x)&0x00000007))	/* Core */
#define XBS_PRS_M1(x)			(((x)&0x00000007)<<4)	/* eDMA */
#define XBS_PRS_M2(x)			(((x)&0x00000007)<<8)	/* FEC0 */
#define XBS_PRS_M3(x)			(((x)&0x00000007)<<12)	/* FEC1 */
#define XBS_PRS_M5(x)			(((x)&0x00000007)<<20)	/* PCI controller */
#define XBS_PRS_M6(x)			(((x)&0x00000007)<<24)	/* USB OTG */
#define XBS_PRS_M7(x)			(((x)&0x00000007)<<28)	/* Serial Boot */

/* Bit definitions and macros for CRS group */
#define XBS_CRS_PARK(x)			(((x)&0x00000007))	/* Master parking ctrl */
#define XBS_CRS_PCTL(x)			(((x)&0x00000003)<<4)	/* Parking mode ctrl */
#define XBS_CRS_ARB			(0x00000100)	/* Arbitration Mode */
#define XBS_CRS_RO			(0x80000000)	/* Read Only */

#define XBS_CRS_PCTL_PARK_FIELD		(0)
#define XBS_CRS_PCTL_PARK_ON_LAST	(1)
#define XBS_CRS_PCTL_PARK_NONE		(2)
#define XBS_CRS_PCTL_PARK_CORE		(0)
#define XBS_CRS_PCTL_PARK_EDMA		(1)
#define XBS_CRS_PCTL_PARK_FEC0		(2)
#define XBS_CRS_PCTL_PARK_FEC1		(3)
#define XBS_CRS_PCTL_PARK_PCI		(5)
#define XBS_CRS_PCTL_PARK_USB		(6)
#define XBS_CRS_PCTL_PARK_SBF		(7)

/*********************************************************************
* FlexBus Chip Selects (FBCS)
*********************************************************************/

/* Register read/write macros */
#define MCF_FBCS0_CSAR           (0xFC008000)
#define MCF_FBCS0_CSMR           (0xFC008004)
#define MCF_FBCS0_CSCR           (0xFC008008)
#define MCF_FBCS1_CSAR           (0xFC00800C)
#define MCF_FBCS1_CSMR           (0xFC008010)
#define MCF_FBCS1_CSCR           (0xFC008014)
#define MCF_FBCS2_CSAR           (0xFC008018)
#define MCF_FBCS2_CSMR           (0xFC00801C)
#define MCF_FBCS2_CSCR           (0xFC008020)
#define MCF_FBCS3_CSAR           (0xFC008024)
#define MCF_FBCS3_CSMR           (0xFC008028)
#define MCF_FBCS3_CSCR           (0xFC00802C)
#define MCF_FBCS4_CSAR           (0xFC008030)
#define MCF_FBCS4_CSMR           (0xFC008034)
#define MCF_FBCS4_CSCR           (0xFC008038)
#define MCF_FBCS5_CSAR           (0xFC00803C)
#define MCF_FBCS5_CSMR           (0xFC008040)
#define MCF_FBCS5_CSCR           (0xFC008044)
#define MCF_FBCS_CSAR(x)         (0xFC008000+((x)*0x00C))
#define MCF_FBCS_CSMR(x)         (0xFC008004+((x)*0x00C))
#define MCF_FBCS_CSCR(x)         (0xFC008008+((x)*0x00C))

/* Bit definitions and macros for CSAR group */
#define FBCS_CSAR_BA(x)			((x)&0xFFFF0000)

/* Bit definitions and macros for CSMR group */
#define FBCS_CSMR_V			(0x00000001)	/* Valid bit */
#define FBCS_CSMR_WP			(0x00000100)	/* Write protect */
#define FBCS_CSMR_BAM(x)		(((x)&0x0000FFFF)<<16)	/* Base address mask */
#define FBCS_CSMR_BAM_4G		(0xFFFF0000)
#define FBCS_CSMR_BAM_2G		(0x7FFF0000)
#define FBCS_CSMR_BAM_1G		(0x3FFF0000)
#define FBCS_CSMR_BAM_1024M		(0x3FFF0000)
#define FBCS_CSMR_BAM_512M		(0x1FFF0000)
#define FBCS_CSMR_BAM_256M		(0x0FFF0000)
#define FBCS_CSMR_BAM_128M		(0x07FF0000)
#define FBCS_CSMR_BAM_64M		(0x03FF0000)
#define FBCS_CSMR_BAM_32M		(0x01FF0000)
#define FBCS_CSMR_BAM_16M		(0x00FF0000)
#define FBCS_CSMR_BAM_8M		(0x007F0000)
#define FBCS_CSMR_BAM_4M		(0x003F0000)
#define FBCS_CSMR_BAM_2M		(0x001F0000)
#define FBCS_CSMR_BAM_1M		(0x000F0000)
#define FBCS_CSMR_BAM_1024K		(0x000F0000)
#define FBCS_CSMR_BAM_512K		(0x00070000)
#define FBCS_CSMR_BAM_256K		(0x00030000)
#define FBCS_CSMR_BAM_128K		(0x00010000)
#define FBCS_CSMR_BAM_64K		(0x00000000)

/* Bit definitions and macros for CSCR group */
#define FBCS_CSCR_BSTW			(0x00000008)	/* Burst-write enable */
#define FBCS_CSCR_BSTR			(0x00000010)	/* Burst-read enable */
#define FBCS_CSCR_BEM			(0x00000020)	/* Byte-enable mode */
#define FBCS_CSCR_PS(x)			(((x)&0x00000003)<<6)	/* Port size */
#define FBCS_CSCR_AA			(0x00000100)	/* Auto-acknowledge */
#define FBCS_CSCR_WS(x)			(((x)&0x0000003F)<<10)	/* Wait states */
#define FBCS_CSCR_WRAH(x)		(((x)&0x00000003)<<16)	/* Write address hold or deselect */
#define FBCS_CSCR_RDAH(x)		(((x)&0x00000003)<<18)	/* Read address hold or deselect */
#define FBCS_CSCR_ASET(x)		(((x)&0x00000003)<<20)	/* Address setup */
#define FBCS_CSCR_SWSEN			(0x00800000)	/* Secondary wait state enable */
#define FBCS_CSCR_SWS(x)		(((x)&0x0000003F)<<26)	/* Secondary wait states */

#define FBCS_CSCR_PS_8			(0x00000040)
#define FBCS_CSCR_PS_16			(0x00000080)
#define FBCS_CSCR_PS_32			(0x00000000)

/*********************************************************************
* Interrupt Controller (INTC)
*********************************************************************/

/* Register read/write macros */
#define MCF_INTC_IPRH0         (0xFC048000)
#define MCF_INTC_IPRL0         (0xFC048004)
#define MCF_INTC_IMRH0         (0xFC048008)
#define MCF_INTC_IMRL0         (0xFC04800C)
#define MCF_INTC_INTFRCH0      (0xFC048010)
#define MCF_INTC_INTFRCL0      (0xFC048014)
#define MCF_INTC_ICONFIG0      (0xFC04801A)
#define MCF_INTC_SIMR0         (0xFC04801C)
#define MCF_INTC_CIMR0         (0xFC04801D)
#define MCF_INTC_ICR0          (0xFC048040)
#define MCF_INTC_ICR0n(x)      (0xFC048040+((x)*0x001))
#define MCF_INTC_SWIACK0       (0xFC0480E0)
#define MCF_INTC_L1IACK0       (0xFC0480E4)
#define MCF_INTC_L2IACK0       (0xFC0480E8)
#define MCF_INTC_L3IACK0       (0xFC0480EC)
#define MCF_INTC_L4IACK0       (0xFC0480F0)
#define MCF_INTC_L5IACK0       (0xFC0480F4)
#define MCF_INTC_L6IACK0       (0xFC0480F8)
#define MCF_INTC_L7IACK0       (0xFC0480FC)
#define MCF_INTC_LnIACK0(x)    (0xFC0480E4+((x)*0x004))
#define MCF_INTC_IPRH1         (0xFC04C000)
#define MCF_INTC_IPRL1         (0xFC04C004)
#define MCF_INTC_IMRH1         (0xFC04C008)
#define MCF_INTC_IMRL1         (0xFC04C00C)
#define MCF_INTC_INTFRCH1      (0xFC04C010)
#define MCF_INTC_INTFRCL1      (0xFC04C014)
#define MCF_INTC_ICONFIG1      (0xFC04C01A)
#define MCF_INTC_SIMR1         (0xFC04C01C)
#define MCF_INTC_CIMR1         (0xFC04C01D)
#define MCF_INTC_ICR1          (0xFC048040)
#define MCF_INTC_ICR1n(x)      (0xFC04C040+((x)*0x001))
#define MCF_INTC_SWIACK1       (0xFC04C0E0)
#define MCF_INTC_L1IACK1       (0xFC04C0E4)
#define MCF_INTC_L2IACK1       (0xFC04C0E8)
#define MCF_INTC_L3IACK1       (0xFC04C0EC)
#define MCF_INTC_L4IACK1       (0xFC04C0F0)
#define MCF_INTC_L5IACK1       (0xFC04C0F4)
#define MCF_INTC_L6IACK1       (0xFC04C0F8)
#define MCF_INTC_L7IACK1       (0xFC04C0FC)
#define MCF_INTC_LnIACK1(x)    (0xFC04C0E4+((x)*0x004))
#define MCF_INTC_GSWIACK       (0xFC0540E0)
#define MCF_INTC_GLnIACK(x)    (0xFC0540E0+((x)*0x001))

#define INT0_LO_RSVD0			(0)
#define INT0_LO_EPORT1			(1)
#define INT0_LO_EPORT2			(2)
#define INT0_LO_EPORT3			(3)
#define INT0_LO_EPORT4			(4)
#define INT0_LO_EPORT5			(5)
#define INT0_LO_EPORT6			(6)
#define INT0_LO_EPORT7			(7)
#define INT0_LO_EDMA_00			(8)
#define INT0_LO_EDMA_01			(9)
#define INT0_LO_EDMA_02			(10)
#define INT0_LO_EDMA_03			(11)
#define INT0_LO_EDMA_04			(12)
#define INT0_LO_EDMA_05			(13)
#define INT0_LO_EDMA_06			(14)
#define INT0_LO_EDMA_07			(15)
#define INT0_LO_EDMA_08			(16)
#define INT0_LO_EDMA_09			(17)
#define INT0_LO_EDMA_10			(18)
#define INT0_LO_EDMA_11			(19)
#define INT0_LO_EDMA_12			(20)
#define INT0_LO_EDMA_13			(21)
#define INT0_LO_EDMA_14			(22)
#define INT0_LO_EDMA_15			(23)
#define INT0_LO_EDMA_ERR		(24)
#define INT0_LO_SCM			(25)
#define INT0_LO_UART0			(26)
#define INT0_LO_UART1			(27)
#define INT0_LO_UART2			(28)
#define INT0_LO_RSVD1			(29)
#define INT0_LO_I2C			(30)
#define INT0_LO_QSPI			(31)
#define INT0_HI_DTMR0			(32)
#define INT0_HI_DTMR1			(33)
#define INT0_HI_DTMR2			(34)
#define INT0_HI_DTMR3			(35)
#define INT0_HI_FEC0_TXF		(36)
#define INT0_HI_FEC0_TXB		(37)
#define INT0_HI_FEC0_UN			(38)
#define INT0_HI_FEC0_RL			(39)
#define INT0_HI_FEC0_RXF		(40)
#define INT0_HI_FEC0_RXB		(41)
#define INT0_HI_FEC0_MII		(42)
#define INT0_HI_FEC0_LC			(43)
#define INT0_HI_FEC0_HBERR		(44)
#define INT0_HI_FEC0_GRA		(45)
#define INT0_HI_FEC0_EBERR		(46)
#define INT0_HI_FEC0_BABT		(47)
#define INT0_HI_FEC0_BABR		(48)
#define INT0_HI_FEC1_TXF		(49)
#define INT0_HI_FEC1_TXB		(50)
#define INT0_HI_FEC1_UN			(51)
#define INT0_HI_FEC1_RL			(52)
#define INT0_HI_FEC1_RXF		(53)
#define INT0_HI_FEC1_RXB		(54)
#define INT0_HI_FEC1_MII		(55)
#define INT0_HI_FEC1_LC			(56)
#define INT0_HI_FEC1_HBERR		(57)
#define INT0_HI_FEC1_GRA		(58)
#define INT0_HI_FEC1_EBERR		(59)
#define INT0_HI_FEC1_BABT		(60)
#define INT0_HI_FEC1_BABR		(61)
#define INT0_HI_SCMIR			(62)
#define INT0_HI_RTC_ISR			(63)
#define INT1_HI_DSPI_EOQF		(33)
#define INT1_HI_DSPI_TFFF		(34)
#define INT1_HI_DSPI_TCF		(35)
#define INT1_HI_DSPI_TFUF		(36)
#define INT1_HI_DSPI_RFDF		(37)
#define INT1_HI_DSPI_RFOF		(38)
#define INT1_HI_DSPI_RFOF_TFUF		(39)
#define INT1_HI_RNG_EI			(40)
#define INT1_HI_PIT0_PIF		(43)
#define INT1_HI_PIT1_PIF		(44)
#define INT1_HI_PIT2_PIF		(45)
#define INT1_HI_PIT3_PIF		(46)
#define INT1_HI_USBOTG_USBSTS		(47)
#define INT1_HI_SSI_ISR			(49)
#define INT1_HI_CCM_UOCSR		(53)
#define INT1_HI_ATA_ISR			(54)
#define INT1_HI_PCI_SCR			(55)
#define INT1_HI_PCI_ASR			(56)
#define INT1_HI_PLL_LOCKS		(57)

/* Bit definitions and macros for IPRH */
#define INTC_IPRH_INT32			(0x00000001)
#define INTC_IPRH_INT33			(0x00000002)
#define INTC_IPRH_INT34			(0x00000004)
#define INTC_IPRH_INT35			(0x00000008)
#define INTC_IPRH_INT36			(0x00000010)
#define INTC_IPRH_INT37			(0x00000020)
#define INTC_IPRH_INT38			(0x00000040)
#define INTC_IPRH_INT39			(0x00000080)
#define INTC_IPRH_INT40			(0x00000100)
#define INTC_IPRH_INT41			(0x00000200)
#define INTC_IPRH_INT42			(0x00000400)
#define INTC_IPRH_INT43			(0x00000800)
#define INTC_IPRH_INT44			(0x00001000)
#define INTC_IPRH_INT45			(0x00002000)
#define INTC_IPRH_INT46			(0x00004000)
#define INTC_IPRH_INT47			(0x00008000)
#define INTC_IPRH_INT48			(0x00010000)
#define INTC_IPRH_INT49			(0x00020000)
#define INTC_IPRH_INT50			(0x00040000)
#define INTC_IPRH_INT51			(0x00080000)
#define INTC_IPRH_INT52			(0x00100000)
#define INTC_IPRH_INT53			(0x00200000)
#define INTC_IPRH_INT54			(0x00400000)
#define INTC_IPRH_INT55			(0x00800000)
#define INTC_IPRH_INT56			(0x01000000)
#define INTC_IPRH_INT57			(0x02000000)
#define INTC_IPRH_INT58			(0x04000000)
#define INTC_IPRH_INT59			(0x08000000)
#define INTC_IPRH_INT60			(0x10000000)
#define INTC_IPRH_INT61			(0x20000000)
#define INTC_IPRH_INT62			(0x40000000)
#define INTC_IPRH_INT63			(0x80000000)

/* Bit definitions and macros for IPRL */
#define INTC_IPRL_INT0			(0x00000001)
#define INTC_IPRL_INT1			(0x00000002)
#define INTC_IPRL_INT2			(0x00000004)
#define INTC_IPRL_INT3			(0x00000008)
#define INTC_IPRL_INT4			(0x00000010)
#define INTC_IPRL_INT5			(0x00000020)
#define INTC_IPRL_INT6			(0x00000040)
#define INTC_IPRL_INT7			(0x00000080)
#define INTC_IPRL_INT8			(0x00000100)
#define INTC_IPRL_INT9			(0x00000200)
#define INTC_IPRL_INT10			(0x00000400)
#define INTC_IPRL_INT11			(0x00000800)
#define INTC_IPRL_INT12			(0x00001000)
#define INTC_IPRL_INT13			(0x00002000)
#define INTC_IPRL_INT14			(0x00004000)
#define INTC_IPRL_INT15			(0x00008000)
#define INTC_IPRL_INT16			(0x00010000)
#define INTC_IPRL_INT17			(0x00020000)
#define INTC_IPRL_INT18			(0x00040000)
#define INTC_IPRL_INT19			(0x00080000)
#define INTC_IPRL_INT20			(0x00100000)
#define INTC_IPRL_INT21			(0x00200000)
#define INTC_IPRL_INT22			(0x00400000)
#define INTC_IPRL_INT23			(0x00800000)
#define INTC_IPRL_INT24			(0x01000000)
#define INTC_IPRL_INT25			(0x02000000)
#define INTC_IPRL_INT26			(0x04000000)
#define INTC_IPRL_INT27			(0x08000000)
#define INTC_IPRL_INT28			(0x10000000)
#define INTC_IPRL_INT29			(0x20000000)
#define INTC_IPRL_INT30			(0x40000000)
#define INTC_IPRL_INT31			(0x80000000)

/* Bit definitions and macros for IMRH */
#define INTC_IMRH_INT_MASK32		(0x00000001)
#define INTC_IMRH_INT_MASK33		(0x00000002)
#define INTC_IMRH_INT_MASK34		(0x00000004)
#define INTC_IMRH_INT_MASK35		(0x00000008)
#define INTC_IMRH_INT_MASK36		(0x00000010)
#define INTC_IMRH_INT_MASK37		(0x00000020)
#define INTC_IMRH_INT_MASK38		(0x00000040)
#define INTC_IMRH_INT_MASK39		(0x00000080)
#define INTC_IMRH_INT_MASK40		(0x00000100)
#define INTC_IMRH_INT_MASK41		(0x00000200)
#define INTC_IMRH_INT_MASK42		(0x00000400)
#define INTC_IMRH_INT_MASK43		(0x00000800)
#define INTC_IMRH_INT_MASK44		(0x00001000)
#define INTC_IMRH_INT_MASK45		(0x00002000)
#define INTC_IMRH_INT_MASK46		(0x00004000)
#define INTC_IMRH_INT_MASK47		(0x00008000)
#define INTC_IMRH_INT_MASK48		(0x00010000)
#define INTC_IMRH_INT_MASK49		(0x00020000)
#define INTC_IMRH_INT_MASK50		(0x00040000)
#define INTC_IMRH_INT_MASK51		(0x00080000)
#define INTC_IMRH_INT_MASK52		(0x00100000)
#define INTC_IMRH_INT_MASK53		(0x00200000)
#define INTC_IMRH_INT_MASK54		(0x00400000)
#define INTC_IMRH_INT_MASK55		(0x00800000)
#define INTC_IMRH_INT_MASK56		(0x01000000)
#define INTC_IMRH_INT_MASK57		(0x02000000)
#define INTC_IMRH_INT_MASK58		(0x04000000)
#define INTC_IMRH_INT_MASK59		(0x08000000)
#define INTC_IMRH_INT_MASK60		(0x10000000)
#define INTC_IMRH_INT_MASK61		(0x20000000)
#define INTC_IMRH_INT_MASK62		(0x40000000)
#define INTC_IMRH_INT_MASK63		(0x80000000)

/* Bit definitions and macros for IMRL */
#define INTC_IMRL_INT_MASK0		(0x00000001)
#define INTC_IMRL_INT_MASK1		(0x00000002)
#define INTC_IMRL_INT_MASK2		(0x00000004)
#define INTC_IMRL_INT_MASK3		(0x00000008)
#define INTC_IMRL_INT_MASK4		(0x00000010)
#define INTC_IMRL_INT_MASK5		(0x00000020)
#define INTC_IMRL_INT_MASK6		(0x00000040)
#define INTC_IMRL_INT_MASK7		(0x00000080)
#define INTC_IMRL_INT_MASK8		(0x00000100)
#define INTC_IMRL_INT_MASK9		(0x00000200)
#define INTC_IMRL_INT_MASK10		(0x00000400)
#define INTC_IMRL_INT_MASK11		(0x00000800)
#define INTC_IMRL_INT_MASK12		(0x00001000)
#define INTC_IMRL_INT_MASK13		(0x00002000)
#define INTC_IMRL_INT_MASK14		(0x00004000)
#define INTC_IMRL_INT_MASK15		(0x00008000)
#define INTC_IMRL_INT_MASK16		(0x00010000)
#define INTC_IMRL_INT_MASK17		(0x00020000)
#define INTC_IMRL_INT_MASK18		(0x00040000)
#define INTC_IMRL_INT_MASK19		(0x00080000)
#define INTC_IMRL_INT_MASK20		(0x00100000)
#define INTC_IMRL_INT_MASK21		(0x00200000)
#define INTC_IMRL_INT_MASK22		(0x00400000)
#define INTC_IMRL_INT_MASK23		(0x00800000)
#define INTC_IMRL_INT_MASK24		(0x01000000)
#define INTC_IMRL_INT_MASK25		(0x02000000)
#define INTC_IMRL_INT_MASK26		(0x04000000)
#define INTC_IMRL_INT_MASK27		(0x08000000)
#define INTC_IMRL_INT_MASK28		(0x10000000)
#define INTC_IMRL_INT_MASK29		(0x20000000)
#define INTC_IMRL_INT_MASK30		(0x40000000)
#define INTC_IMRL_INT_MASK31		(0x80000000)

/* Bit definitions and macros for INTFRCH */
#define INTC_INTFRCH_INTFRC32		(0x00000001)
#define INTC_INTFRCH_INTFRC33		(0x00000002)
#define INTC_INTFRCH_INTFRC34		(0x00000004)
#define INTC_INTFRCH_INTFRC35		(0x00000008)
#define INTC_INTFRCH_INTFRC36		(0x00000010)
#define INTC_INTFRCH_INTFRC37		(0x00000020)
#define INTC_INTFRCH_INTFRC38		(0x00000040)
#define INTC_INTFRCH_INTFRC39		(0x00000080)
#define INTC_INTFRCH_INTFRC40		(0x00000100)
#define INTC_INTFRCH_INTFRC41		(0x00000200)
#define INTC_INTFRCH_INTFRC42		(0x00000400)
#define INTC_INTFRCH_INTFRC43		(0x00000800)
#define INTC_INTFRCH_INTFRC44		(0x00001000)
#define INTC_INTFRCH_INTFRC45		(0x00002000)
#define INTC_INTFRCH_INTFRC46		(0x00004000)
#define INTC_INTFRCH_INTFRC47		(0x00008000)
#define INTC_INTFRCH_INTFRC48		(0x00010000)
#define INTC_INTFRCH_INTFRC49		(0x00020000)
#define INTC_INTFRCH_INTFRC50		(0x00040000)
#define INTC_INTFRCH_INTFRC51		(0x00080000)
#define INTC_INTFRCH_INTFRC52		(0x00100000)
#define INTC_INTFRCH_INTFRC53		(0x00200000)
#define INTC_INTFRCH_INTFRC54		(0x00400000)
#define INTC_INTFRCH_INTFRC55		(0x00800000)
#define INTC_INTFRCH_INTFRC56		(0x01000000)
#define INTC_INTFRCH_INTFRC57		(0x02000000)
#define INTC_INTFRCH_INTFRC58		(0x04000000)
#define INTC_INTFRCH_INTFRC59		(0x08000000)
#define INTC_INTFRCH_INTFRC60		(0x10000000)
#define INTC_INTFRCH_INTFRC61		(0x20000000)
#define INTC_INTFRCH_INTFRC62		(0x40000000)
#define INTC_INTFRCH_INTFRC63		(0x80000000)

/* Bit definitions and macros for INTFRCL */
#define INTC_INTFRCL_INTFRC0		(0x00000001)
#define INTC_INTFRCL_INTFRC1		(0x00000002)
#define INTC_INTFRCL_INTFRC2		(0x00000004)
#define INTC_INTFRCL_INTFRC3		(0x00000008)
#define INTC_INTFRCL_INTFRC4		(0x00000010)
#define INTC_INTFRCL_INTFRC5		(0x00000020)
#define INTC_INTFRCL_INTFRC6		(0x00000040)
#define INTC_INTFRCL_INTFRC7		(0x00000080)
#define INTC_INTFRCL_INTFRC8		(0x00000100)
#define INTC_INTFRCL_INTFRC9		(0x00000200)
#define INTC_INTFRCL_INTFRC10		(0x00000400)
#define INTC_INTFRCL_INTFRC11		(0x00000800)
#define INTC_INTFRCL_INTFRC12		(0x00001000)
#define INTC_INTFRCL_INTFRC13		(0x00002000)
#define INTC_INTFRCL_INTFRC14		(0x00004000)
#define INTC_INTFRCL_INTFRC15		(0x00008000)
#define INTC_INTFRCL_INTFRC16		(0x00010000)
#define INTC_INTFRCL_INTFRC17		(0x00020000)
#define INTC_INTFRCL_INTFRC18		(0x00040000)
#define INTC_INTFRCL_INTFRC19		(0x00080000)
#define INTC_INTFRCL_INTFRC20		(0x00100000)
#define INTC_INTFRCL_INTFRC21		(0x00200000)
#define INTC_INTFRCL_INTFRC22		(0x00400000)
#define INTC_INTFRCL_INTFRC23		(0x00800000)
#define INTC_INTFRCL_INTFRC24		(0x01000000)
#define INTC_INTFRCL_INTFRC25		(0x02000000)
#define INTC_INTFRCL_INTFRC26		(0x04000000)
#define INTC_INTFRCL_INTFRC27		(0x08000000)
#define INTC_INTFRCL_INTFRC28		(0x10000000)
#define INTC_INTFRCL_INTFRC29		(0x20000000)
#define INTC_INTFRCL_INTFRC30		(0x40000000)
#define INTC_INTFRCL_INTFRC31		(0x80000000)

/* Bit definitions and macros for ICONFIG */
#define INTC_ICONFIG_EMASK		(0x0020)
#define INTC_ICONFIG_ELVLPRI1		(0x0200)
#define INTC_ICONFIG_ELVLPRI2		(0x0400)
#define INTC_ICONFIG_ELVLPRI3		(0x0800)
#define INTC_ICONFIG_ELVLPRI4		(0x1000)
#define INTC_ICONFIG_ELVLPRI5		(0x2000)
#define INTC_ICONFIG_ELVLPRI6		(0x4000)
#define INTC_ICONFIG_ELVLPRI7		(0x8000)

/* Bit definitions and macros for SIMR */
#define INTC_SIMR_SIMR(x)		(((x)&0x7F))

/* Bit definitions and macros for CIMR */
#define INTC_CIMR_CIMR(x)		(((x)&0x7F))

/* Bit definitions and macros for CLMASK */
#define INTC_CLMASK_CLMASK(x)		(((x)&0x0F))

/* Bit definitions and macros for SLMASK */
#define INTC_SLMASK_SLMASK(x)		(((x)&0x0F))

/* Bit definitions and macros for ICR group */
#define INTC_ICR_IL(x)			(((x)&0x07))

/*********************************************************************
* DMA Serial Peripheral Interface (DSPI)
*********************************************************************/

/* Register read/write macros */
#define MCF_DSPI_DMCR               (0xFC05C000)
#define MCF_DSPI_DTCR               (0xFC05C008)
#define MCF_DSPI_DCTAR0             (0xFC05C00C)
#define MCF_DSPI_DCTAR1             (0xFC05C010)
#define MCF_DSPI_DCTAR2             (0xFC05C014)
#define MCF_DSPI_DCTAR3             (0xFC05C018)
#define MCF_DSPI_DCTAR4             (0xFC05C01C)
#define MCF_DSPI_DCTAR5             (0xFC05C020)
#define MCF_DSPI_DCTAR6             (0xFC05C024)
#define MCF_DSPI_DCTAR7             (0xFC05C028)
#define MCF_DSPI_DCTAR(x)           (0xFC05C00C+((x)*0x004))
#define MCF_DSPI_DSR                (0xFC05C02C)
#define MCF_DSPI_DIRSR              (0xFC05C030)
#define MCF_DSPI_DTFR               (0xFC05C034)
#define MCF_DSPI_DRFR               (0xFC05C038)
#define MCF_DSPI_DTFDR0             (0xFC05C03C)
#define MCF_DSPI_DTFDR1             (0xFC05C040)
#define MCF_DSPI_DTFDR2             (0xFC05C044)
#define MCF_DSPI_DTFDR3             (0xFC05C048)
#define MCF_DSPI_DTFDR(x)           (0xFC05C03C+((x)*0x004))
#define MCF_DSPI_DRFDR0             (0xFC05C07C)
#define MCF_DSPI_DRFDR1             (0xFC05C080)
#define MCF_DSPI_DRFDR2             (0xFC05C084)
#define MCF_DSPI_DRFDR3             (0xFC05C088)
#define MCF_DSPI_DRFDR(x)           (0xFC05C07C+((x)*0x004))

/* Bit definitions and macros for DMCR */
#define DSPI_DMCR_HALT			(0x00000001)
#define DSPI_DMCR_SMPL_PT(x)		(((x)&0x00000003)<<8)
#define DSPI_DMCR_CRXF			(0x00000400)
#define DSPI_DMCR_CTXF			(0x00000800)
#define DSPI_DMCR_DRXF			(0x00001000)
#define DSPI_DMCR_DTXF			(0x00002000)
#define DSPI_DMCR_CSIS0			(0x00010000)
#define DSPI_DMCR_CSIS2			(0x00040000)
#define DSPI_DMCR_CSIS3			(0x00080000)
#define DSPI_DMCR_CSIS5			(0x00200000)
#define DSPI_DMCR_ROOE			(0x01000000)
#define DSPI_DMCR_PCSSE			(0x02000000)
#define DSPI_DMCR_MTFE			(0x04000000)
#define DSPI_DMCR_FRZ			(0x08000000)
#define DSPI_DMCR_DCONF(x)		(((x)&0x00000003)<<28)
#define DSPI_DMCR_CSCK			(0x40000000)
#define DSPI_DMCR_MSTR			(0x80000000)

/* Bit definitions and macros for DTCR */
#define DSPI_DTCR_SPI_TCNT(x)		(((x)&0x0000FFFF)<<16)

/* Bit definitions and macros for DCTAR group */
#define DSPI_DCTAR_BR(x)		(((x)&0x0000000F))
#define DSPI_DCTAR_DT(x)		(((x)&0x0000000F)<<4)
#define DSPI_DCTAR_ASC(x)		(((x)&0x0000000F)<<8)
#define DSPI_DCTAR_CSSCK(x)		(((x)&0x0000000F)<<12)
#define DSPI_DCTAR_PBR(x)		(((x)&0x00000003)<<16)
#define DSPI_DCTAR_PDT(x)		(((x)&0x00000003)<<18)
#define DSPI_DCTAR_PASC(x)		(((x)&0x00000003)<<20)
#define DSPI_DCTAR_PCSSCK(x)		(((x)&0x00000003)<<22)
#define DSPI_DCTAR_LSBFE		(0x01000000)
#define DSPI_DCTAR_CPHA			(0x02000000)
#define DSPI_DCTAR_CPOL			(0x04000000)
#define DSPI_DCTAR_TRSZ(x)		(((x)&0x0000000F)<<27)
#define DSPI_DCTAR_PCSSCK_1CLK		(0x00000000)
#define DSPI_DCTAR_PCSSCK_3CLK		(0x00400000)
#define DSPI_DCTAR_PCSSCK_5CLK		(0x00800000)
#define DSPI_DCTAR_PCSSCK_7CLK		(0x00A00000)
#define DSPI_DCTAR_PASC_1CLK		(0x00000000)
#define DSPI_DCTAR_PASC_3CLK		(0x00100000)
#define DSPI_DCTAR_PASC_5CLK		(0x00200000)
#define DSPI_DCTAR_PASC_7CLK		(0x00300000)
#define DSPI_DCTAR_PDT_1CLK		(0x00000000)
#define DSPI_DCTAR_PDT_3CLK		(0x00040000)
#define DSPI_DCTAR_PDT_5CLK		(0x00080000)
#define DSPI_DCTAR_PDT_7CLK		(0x000A0000)
#define DSPI_DCTAR_PBR_1CLK		(0x00000000)
#define DSPI_DCTAR_PBR_3CLK		(0x00010000)
#define DSPI_DCTAR_PBR_5CLK		(0x00020000)
#define DSPI_DCTAR_PBR_7CLK		(0x00030000)

/* Bit definitions and macros for DSR */
#define DSPI_DSR_RXPTR(x)		(((x)&0x0000000F))
#define DSPI_DSR_RXCTR(x)		(((x)&0x0000000F)<<4)
#define DSPI_DSR_TXPTR(x)		(((x)&0x0000000F)<<8)
#define DSPI_DSR_TXCTR(x)		(((x)&0x0000000F)<<12)
#define DSPI_DSR_RFDF			(0x00020000)
#define DSPI_DSR_RFOF			(0x00080000)
#define DSPI_DSR_TFFF			(0x02000000)
#define DSPI_DSR_TFUF			(0x08000000)
#define DSPI_DSR_EOQF			(0x10000000)
#define DSPI_DSR_TXRXS			(0x40000000)
#define DSPI_DSR_TCF			(0x80000000)

/* Bit definitions and macros for DIRSR */
#define DSPI_DIRSR_RFDFS		(0x00010000)
#define DSPI_DIRSR_RFDFE		(0x00020000)
#define DSPI_DIRSR_RFOFE		(0x00080000)
#define DSPI_DIRSR_TFFFS		(0x01000000)
#define DSPI_DIRSR_TFFFE		(0x02000000)
#define DSPI_DIRSR_TFUFE		(0x08000000)
#define DSPI_DIRSR_EOQFE		(0x10000000)
#define DSPI_DIRSR_TCFE			(0x80000000)

/* Bit definitions and macros for DTFR */
#define DSPI_DTFR_TXDATA(x)		(((x)&0x0000FFFF))
#define DSPI_DTFR_CS0			(0x00010000)
#define DSPI_DTFR_CS2			(0x00040000)
#define DSPI_DTFR_CS3			(0x00080000)
#define DSPI_DTFR_CS5			(0x00200000)
#define DSPI_DTFR_CTCNT			(0x04000000)
#define DSPI_DTFR_EOQ			(0x08000000)
#define DSPI_DTFR_CTAS(x)		(((x)&0x00000007)<<28)
#define DSPI_DTFR_CONT			(0x80000000)

/* Bit definitions and macros for DRFR */
#define DSPI_DRFR_RXDATA(x)		(((x)&0x0000FFFF))

/* Bit definitions and macros for DTFDR group */
#define DSPI_DTFDR_TXDATA(x)		(((x)&0x0000FFFF))
#define DSPI_DTFDR_TXCMD(x)		(((x)&0x0000FFFF)<<16)

/* Bit definitions and macros for DRFDR group */
#define DSPI_DRFDR_RXDATA(x)		(((x)&0x0000FFFF))

/*********************************************************************
* Edge Port Module (EPORT)
*********************************************************************/

/* Register read/write macros */
#define MCF_EPORT_EPPAR                (0xFC094000)
#define MCF_EPORT_EPDDR                (0xFC094004)
#define MCF_EPORT_EPIER                (0xFC094005)
#define MCF_EPORT_EPDR                 (0xFC094008)
#define MCF_EPORT_EPPDR                (0xFC094009)
#define MCF_EPORT_EPFR                 (0xFC09400C)

/* Bit definitions and macros for EPPAR */
#define EPORT_EPPAR_EPPA1(x)		(((x)&0x0003)<<2)
#define EPORT_EPPAR_EPPA2(x)		(((x)&0x0003)<<4)
#define EPORT_EPPAR_EPPA3(x)		(((x)&0x0003)<<6)
#define EPORT_EPPAR_EPPA4(x)		(((x)&0x0003)<<8)
#define EPORT_EPPAR_EPPA5(x)		(((x)&0x0003)<<10)
#define EPORT_EPPAR_EPPA6(x)		(((x)&0x0003)<<12)
#define EPORT_EPPAR_EPPA7(x)		(((x)&0x0003)<<14)
#define EPORT_EPPAR_LEVEL		(0)
#define EPORT_EPPAR_RISING		(1)
#define EPORT_EPPAR_FALLING		(2)
#define EPORT_EPPAR_BOTH		(3)
#define EPORT_EPPAR_EPPA7_LEVEL		(0x0000)
#define EPORT_EPPAR_EPPA7_RISING	(0x4000)
#define EPORT_EPPAR_EPPA7_FALLING	(0x8000)
#define EPORT_EPPAR_EPPA7_BOTH		(0xC000)
#define EPORT_EPPAR_EPPA6_LEVEL		(0x0000)
#define EPORT_EPPAR_EPPA6_RISING	(0x1000)
#define EPORT_EPPAR_EPPA6_FALLING	(0x2000)
#define EPORT_EPPAR_EPPA6_BOTH		(0x3000)
#define EPORT_EPPAR_EPPA5_LEVEL		(0x0000)
#define EPORT_EPPAR_EPPA5_RISING	(0x0400)
#define EPORT_EPPAR_EPPA5_FALLING	(0x0800)
#define EPORT_EPPAR_EPPA5_BOTH		(0x0C00)
#define EPORT_EPPAR_EPPA4_LEVEL		(0x0000)
#define EPORT_EPPAR_EPPA4_RISING	(0x0100)
#define EPORT_EPPAR_EPPA4_FALLING	(0x0200)
#define EPORT_EPPAR_EPPA4_BOTH		(0x0300)
#define EPORT_EPPAR_EPPA3_LEVEL		(0x0000)
#define EPORT_EPPAR_EPPA3_RISING	(0x0040)
#define EPORT_EPPAR_EPPA3_FALLING	(0x0080)
#define EPORT_EPPAR_EPPA3_BOTH		(0x00C0)
#define EPORT_EPPAR_EPPA2_LEVEL		(0x0000)
#define EPORT_EPPAR_EPPA2_RISING	(0x0010)
#define EPORT_EPPAR_EPPA2_FALLING	(0x0020)
#define EPORT_EPPAR_EPPA2_BOTH		(0x0030)
#define EPORT_EPPAR_EPPA1_LEVEL		(0x0000)
#define EPORT_EPPAR_EPPA1_RISING	(0x0004)
#define EPORT_EPPAR_EPPA1_FALLING	(0x0008)
#define EPORT_EPPAR_EPPA1_BOTH		(0x000C)

/* Bit definitions and macros for EPDDR */
#define EPORT_EPDDR_EPDD1		(0x02)
#define EPORT_EPDDR_EPDD2		(0x04)
#define EPORT_EPDDR_EPDD3		(0x08)
#define EPORT_EPDDR_EPDD4		(0x10)
#define EPORT_EPDDR_EPDD5		(0x20)
#define EPORT_EPDDR_EPDD6		(0x40)
#define EPORT_EPDDR_EPDD7		(0x80)

/* Bit definitions and macros for EPIER */
#define EPORT_EPIER_EPIE1		(0x02)
#define EPORT_EPIER_EPIE2		(0x04)
#define EPORT_EPIER_EPIE3		(0x08)
#define EPORT_EPIER_EPIE4		(0x10)
#define EPORT_EPIER_EPIE5		(0x20)
#define EPORT_EPIER_EPIE6		(0x40)
#define EPORT_EPIER_EPIE7		(0x80)

/* Bit definitions and macros for EPDR */
#define EPORT_EPDR_EPD1			(0x02)
#define EPORT_EPDR_EPD2			(0x04)
#define EPORT_EPDR_EPD3			(0x08)
#define EPORT_EPDR_EPD4			(0x10)
#define EPORT_EPDR_EPD5			(0x20)
#define EPORT_EPDR_EPD6			(0x40)
#define EPORT_EPDR_EPD7			(0x80)

/* Bit definitions and macros for EPPDR */
#define EPORT_EPPDR_EPPD1		(0x02)
#define EPORT_EPPDR_EPPD2		(0x04)
#define EPORT_EPPDR_EPPD3		(0x08)
#define EPORT_EPPDR_EPPD4		(0x10)
#define EPORT_EPPDR_EPPD5		(0x20)
#define EPORT_EPPDR_EPPD6		(0x40)
#define EPORT_EPPDR_EPPD7		(0x80)

/* Bit definitions and macros for EPFR */
#define EPORT_EPFR_EPF1			(0x02)
#define EPORT_EPFR_EPF2			(0x04)
#define EPORT_EPFR_EPF3			(0x08)
#define EPORT_EPFR_EPF4			(0x10)
#define EPORT_EPFR_EPF5			(0x20)
#define EPORT_EPFR_EPF6			(0x40)
#define EPORT_EPFR_EPF7			(0x80)

/*********************************************************************
* Serial Boot Facility (SBF)
*********************************************************************/

/* Register read/write macros */
#define MCF_SBF_SBFSR                  (0xFC0A0018)
#define MCF_SBF_SBFCR                  (0xFC0A0020)

/* Bit definitions and macros for SBFCR */
#define SBF_SBFCR_BLDIV(x)		(((x)&0x000F))	/* Boot loader clock divider */
#define SBF_SBFCR_FR			(0x0010)	/* Fast read */

/*********************************************************************
* Reset Controller Module (RCM)
*********************************************************************/

/* Register read/write macros */
#define MCF_RCM_RCR                    (0xFC0A0000)
#define MCF_RCM_RSR                    (0xFC0A0001)

/* Bit definitions and macros for RCR */
#define RCM_RCR_FRCRSTOUT		(0x40)
#define RCM_RCR_SOFTRST			(0x80)

/* Bit definitions and macros for RSR */
#define RCM_RSR_LOL			(0x01)
#define RCM_RSR_WDR_CORE		(0x02)
#define RCM_RSR_EXT			(0x04)
#define RCM_RSR_POR			(0x08)
#define RCM_RSR_SOFT			(0x20)

/*********************************************************************
* Chip Configuration Module (CCM)
*********************************************************************/

/* Register read/write macros */
#define MCF_CCM_CCR                    (0xFC0A0004)
#define MCF_CCM_RCON                   (0xFC0A0008)
#define MCF_CCM_CIR                    (0xFC0A000A)
#define MCF_CCM_MISCCR                 (0xFC0A0010)
#define MCF_CCM_CDR                    (0xFC0A0012)
#define MCF_CCM_UOCSR                  (0xFC0A0014)
#define MCF_CCM_SBFSR                  (0xFC0A0018)
#define MCF_CCM_SBFCR                  (0xFC0A0020)

/* Bit definitions and macros for CCR_360 */
#define CCM_CCR_360_PLLMULT2(x)		(((x)&0x0003))	/* 2-Bit PLL clock mode */
#define CCM_CCR_360_PCISLEW		(0x0004)	/* PCI pad slew rate mode */
#define CCM_CCR_360_PCIMODE		(0x0008)	/* PCI host/agent mode */
#define CCM_CCR_360_PLLMODE		(0x0010)	/* PLL Mode */
#define CCM_CCR_360_FBCONFIG(x)		(((x)&0x0007)<<5)	/* Flexbus/PCI port size configuration */
#define CCM_CCR_360_PLLMULT3(x)		(((x)&0x0007))	/* 3-Bit PLL Clock Mode */
#define CCM_CCR_360_OSCMODE		(0x0008)	/* Oscillator Clock Mode */
#define CCM_CCR_360_FBCONFIG_MASK	(0x00E0)
#define CCM_CCR_360_PLLMULT2_MASK	(0x0003)
#define CCM_CCR_360_PLLMULT3_MASK	(0x0007)
#define CCM_CCR_360_FBCONFIG_NM_NP_32	(0x0000)
#define CCM_CCR_360_FBCONFIG_NM_NP_8	(0x0020)
#define CCM_CCR_360_FBCONFIG_NM_NP_16	(0x0040)
#define CCM_CCR_360_FBCONFIG_M_P_16	(0x0060)
#define CCM_CCR_360_FBCONFIG_M_NP_32	(0x0080)
#define CCM_CCR_360_FBCONFIG_M_NP_8	(0x00A0)
#define CCM_CCR_360_FBCONFIG_M_NP_16	(0x00C0)
#define CCM_CCR_360_FBCONFIG_M_P_8	(0x00E0)
#define CCM_CCR_360_PLLMULT2_12X	(0x0000)
#define CCM_CCR_360_PLLMULT2_6X		(0x0001)
#define CCM_CCR_360_PLLMULT2_16X	(0x0002)
#define CCM_CCR_360_PLLMULT2_8X		(0x0003)
#define CCM_CCR_360_PLLMULT3_20X	(0x0000)
#define CCM_CCR_360_PLLMULT3_10X	(0x0001)
#define CCM_CCR_360_PLLMULT3_24X	(0x0002)
#define CCM_CCR_360_PLLMULT3_18X	(0x0003)
#define CCM_CCR_360_PLLMULT3_12X	(0x0004)
#define CCM_CCR_360_PLLMULT3_6X		(0x0005)
#define CCM_CCR_360_PLLMULT3_16X	(0x0006)
#define CCM_CCR_360_PLLMULT3_8X		(0x0007)

/* Bit definitions and macros for CCR_256 */
#define CCM_CCR_256_PLLMULT3(x)		(((x)&0x0007))	/* 3-Bit PLL clock mode */
#define CCM_CCR_256_OSCMODE		(0x0008)	/* Oscillator clock mode */
#define CCM_CCR_256_PLLMODE		(0x0010)	/* PLL Mode */
#define CCM_CCR_256_FBCONFIG(x)		(((x)&0x0007)<<5)	/* Flexbus/PCI port size configuration */
#define CCM_CCR_256_FBCONFIG_MASK	(0x00E0)
#define CCM_CCR_256_FBCONFIG_NM_32	(0x0000)
#define CCM_CCR_256_FBCONFIG_NM_8	(0x0020)
#define CCM_CCR_256_FBCONFIG_NM_16	(0x0040)
#define CCM_CCR_256_FBCONFIG_M_32	(0x0080)
#define CCM_CCR_256_FBCONFIG_M_8	(0x00A0)
#define CCM_CCR_256_FBCONFIG_M_16	(0x00C0)
#define CCM_CCR_256_PLLMULT3_MASK	(0x0007)
#define CCM_CCR_256_PLLMULT3_20X	(0x0000)
#define CCM_CCR_256_PLLMULT3_10X	(0x0001)
#define CCM_CCR_256_PLLMULT3_24X	(0x0002)
#define CCM_CCR_256_PLLMULT3_18X	(0x0003)
#define CCM_CCR_256_PLLMULT3_12X	(0x0004)
#define CCM_CCR_256_PLLMULT3_6X		(0x0005)
#define CCM_CCR_256_PLLMULT3_16X	(0x0006)
#define CCM_CCR_256_PLLMULT3_8X		(0x0007)

/* Bit definitions and macros for RCON_360 */
#define CCM_RCON_360_PLLMULT(x)		(((x)&0x0003))	/* PLL clock mode */
#define CCM_RCON_360_PCISLEW		(0x0004)	/* PCI pad slew rate mode */
#define CCM_RCON_360_PCIMODE		(0x0008)	/* PCI host/agent mode */
#define CCM_RCON_360_PLLMODE		(0x0010)	/* PLL Mode */
#define CCM_RCON_360_FBCONFIG(x)	(((x)&0x0007)<<5)	/* Flexbus/PCI port size configuration */

/* Bit definitions and macros for RCON_256 */
#define CCM_RCON_256_PLLMULT(x)		(((x)&0x0007))	/* PLL clock mode */
#define CCM_RCON_256_OSCMODE		(0x0008)	/* Oscillator clock mode */
#define CCM_RCON_256_PLLMODE		(0x0010)	/* PLL Mode */
#define CCM_RCON_256_FBCONFIG(x)	(((x)&0x0007)<<5)	/* Flexbus/PCI port size configuration */

/* Bit definitions and macros for CIR */
#define CCM_CIR_PRN(x)			(((x)&0x003F))	/* Part revision number */
#define CCM_CIR_PIN(x)			(((x)&0x03FF)<<6)	/* Part identification number */
#define CCM_CIR_PIN_MASK		(0xFFC0)
#define CCM_CIR_PRN_MASK		(0x003F)
#define CCM_CIR_PIN_MCF54450		(0x4F<<6)
#define CCM_CIR_PIN_MCF54451		(0x4D<<6)
#define CCM_CIR_PIN_MCF54452		(0x4B<<6)
#define CCM_CIR_PIN_MCF54453		(0x49<<6)
#define CCM_CIR_PIN_MCF54454		(0x4A<<6)
#define CCM_CIR_PIN_MCF54455		(0x48<<6)

/* Bit definitions and macros for MISCCR */
#define CCM_MISCCR_USBSRC		(0x0001)	/* USB clock source */
#define CCM_MISCCR_USBOC		(0x0002)	/* USB VBUS over-current sense polarity */
#define CCM_MISCCR_USBPUE		(0x0004)	/* USB transceiver pull-up enable */
#define CCM_MISCCR_SSISRC		(0x0010)	/* SSI clock source */
#define CCM_MISCCR_TIMDMA		(0x0020)	/* Timer DMA mux selection */
#define CCM_MISCCR_SSIPUS		(0x0040)	/* SSI RXD/TXD pull select */
#define CCM_MISCCR_SSIPUE		(0x0080)	/* SSI RXD/TXD pull enable */
#define CCM_MISCCR_BMT(x)		(((x)&0x0007)<<8)	/* Bus monitor timing field */
#define CCM_MISCCR_BME			(0x0800)	/* Bus monitor external enable bit */
#define CCM_MISCCR_LIMP			(0x1000)	/* Limp mode enable */
#define CCM_MISCCR_BMT_65536		(0)
#define CCM_MISCCR_BMT_32768		(1)
#define CCM_MISCCR_BMT_16384		(2)
#define CCM_MISCCR_BMT_8192		(3)
#define CCM_MISCCR_BMT_4096		(4)
#define CCM_MISCCR_BMT_2048		(5)
#define CCM_MISCCR_BMT_1024		(6)
#define CCM_MISCCR_BMT_512		(7)
#define CCM_MISCCR_SSIPUS_UP		(1)
#define CCM_MISCCR_SSIPUS_DOWN		(0)
#define CCM_MISCCR_TIMDMA_TIM		(1)
#define CCM_MISCCR_TIMDMA_SSI		(0)
#define CCM_MISCCR_SSISRC_CLKIN		(0)
#define CCM_MISCCR_SSISRC_PLL		(1)
#define CCM_MISCCR_USBOC_ACTHI		(0)
#define CCM_MISCCR_USBOV_ACTLO		(1)
#define CCM_MISCCR_USBSRC_CLKIN		(0)
#define CCM_MISCCR_USBSRC_PLL		(1)

/* Bit definitions and macros for CDR */
#define CCM_CDR_SSIDIV(x)		(((x)&0x00FF))	/* SSI oversampling clock divider */
#define CCM_CDR_LPDIV(x)		(((x)&0x000F)<<8)	/* Low power clock divider */

/* Bit definitions and macros for UOCSR */
#define CCM_UOCSR_XPDE			(0x0001)	/* On-chip transceiver pull-down enable */
#define CCM_UOCSR_UOMIE			(0x0002)	/* USB OTG misc interrupt enable */
#define CCM_UOCSR_WKUP			(0x0004)	/* USB OTG controller wake-up event */
#define CCM_UOCSR_PWRFLT		(0x0008)	/* VBUS power fault */
#define CCM_UOCSR_SEND			(0x0010)	/* Session end */
#define CCM_UOCSR_VVLD			(0x0020)	/* VBUS valid indicator */
#define CCM_UOCSR_BVLD			(0x0040)	/* B-peripheral valid indicator */
#define CCM_UOCSR_AVLD			(0x0080)	/* A-peripheral valid indicator */
#define CCM_UOCSR_DPPU			(0x0100)	/* D+ pull-up for FS enabled (read-only) */
#define CCM_UOCSR_DCR_VBUS		(0x0200)	/* VBUS discharge resistor enabled (read-only) */
#define CCM_UOCSR_CRG_VBUS		(0x0400)	/* VBUS charge resistor enabled (read-only) */
#define CCM_UOCSR_DMPD			(0x1000)	/* D- 15Kohm pull-down (read-only) */
#define CCM_UOCSR_DPPD			(0x2000)	/* D+ 15Kohm pull-down (read-only) */

/*********************************************************************
* General Purpose I/O Module (GPIO)
*********************************************************************/

/* Register read/write macros */                          
#define MCF_GPIO_PODR_FEC0H         (0xFC0A4000)
#define MCF_GPIO_PODR_FEC0L         (0xFC0A4001)
#define MCF_GPIO_PODR_SSI           (0xFC0A4002)
#define MCF_GPIO_PODR_FBCTL         (0xFC0A4003)
#define MCF_GPIO_PODR_BE            (0xFC0A4004)
#define MCF_GPIO_PODR_CS            (0xFC0A4005)
#define MCF_GPIO_PODR_DMA           (0xFC0A4006)
#define MCF_GPIO_PODR_FECI2C        (0xFC0A4007)
#define MCF_GPIO_PODR_UART          (0xFC0A4009)
#define MCF_GPIO_PODR_DSPI          (0xFC0A400A)
#define MCF_GPIO_PODR_TIMER         (0xFC0A400B)
#define MCF_GPIO_PODR_PCI           (0xFC0A400C)
#define MCF_GPIO_PODR_USB           (0xFC0A400D)
#define MCF_GPIO_PODR_ATAH          (0xFC0A400E)
#define MCF_GPIO_PODR_ATAL          (0xFC0A400F)
#define MCF_GPIO_PODR_FEC1H         (0xFC0A4010)
#define MCF_GPIO_PODR_FEC1L         (0xFC0A4011)
#define MCF_GPIO_PODR_FBADH         (0xFC0A4014)
#define MCF_GPIO_PODR_FBADMH        (0xFC0A4015)
#define MCF_GPIO_PODR_FBADML        (0xFC0A4016)
#define MCF_GPIO_PODR_FBADL         (0xFC0A4017)
#define MCF_GPIO_PDDR_FEC0H         (0xFC0A4018)
#define MCF_GPIO_PDDR_FEC0L         (0xFC0A4019)
#define MCF_GPIO_PDDR_SSI           (0xFC0A401A)
#define MCF_GPIO_PDDR_FBCTL         (0xFC0A401B)
#define MCF_GPIO_PDDR_BE            (0xFC0A401C)
#define MCF_GPIO_PDDR_CS            (0xFC0A401D)
#define MCF_GPIO_PDDR_DMA           (0xFC0A401E)
#define MCF_GPIO_PDDR_FECI2C        (0xFC0A401F)
#define MCF_GPIO_PDDR_UART          (0xFC0A4021)
#define MCF_GPIO_PDDR_DSPI          (0xFC0A4022)
#define MCF_GPIO_PDDR_TIMER         (0xFC0A4023)
#define MCF_GPIO_PDDR_PCI           (0xFC0A4024)
#define MCF_GPIO_PDDR_USB           (0xFC0A4025)
#define MCF_GPIO_PDDR_ATAH          (0xFC0A4026)
#define MCF_GPIO_PDDR_ATAL          (0xFC0A4027)
#define MCF_GPIO_PDDR_FEC1H         (0xFC0A4028)
#define MCF_GPIO_PDDR_FEC1L         (0xFC0A4029)
#define MCF_GPIO_PDDR_FBADH         (0xFC0A402C)
#define MCF_GPIO_PDDR_FBADMH        (0xFC0A402D)
#define MCF_GPIO_PDDR_FBADML        (0xFC0A402E)
#define MCF_GPIO_PDDR_FBADL         (0xFC0A402F)
#define MCF_GPIO_PPDSDR_FEC0H       (0xFC0A4030)
#define MCF_GPIO_PPDSDR_FEC0L       (0xFC0A4031)
#define MCF_GPIO_PPDSDR_SSI         (0xFC0A4032)
#define MCF_GPIO_PPDSDR_FBCTL       (0xFC0A4033)
#define MCF_GPIO_PPDSDR_BE          (0xFC0A4034)
#define MCF_GPIO_PPDSDR_CS          (0xFC0A4035)
#define MCF_GPIO_PPDSDR_DMA         (0xFC0A4036)
#define MCF_GPIO_PPDSDR_FECI2C      (0xFC0A4037)
#define MCF_GPIO_PPDSDR_UART        (0xFC0A4039)
#define MCF_GPIO_PPDSDR_DSPI        (0xFC0A403A)
#define MCF_GPIO_PPDSDR_TIMER       (0xFC0A403B)
#define MCF_GPIO_PPDSDR_PCI         (0xFC0A403C)
#define MCF_GPIO_PPDSDR_USB         (0xFC0A403D)
#define MCF_GPIO_PPDSDR_ATAH        (0xFC0A403E)
#define MCF_GPIO_PPDSDR_ATAL        (0xFC0A403F)
#define MCF_GPIO_PPDSDR_FEC1H       (0xFC0A4040)
#define MCF_GPIO_PPDSDR_FEC1L       (0xFC0A4041)
#define MCF_GPIO_PPDSDR_FBADH       (0xFC0A4044)
#define MCF_GPIO_PPDSDR_FBADMH      (0xFC0A4045)
#define MCF_GPIO_PPDSDR_FBADML      (0xFC0A4046)
#define MCF_GPIO_PPDSDR_FBADL       (0xFC0A4047)
#define MCF_GPIO_PCLRR_FEC0H        (0xFC0A4048)
#define MCF_GPIO_PCLRR_FEC0L        (0xFC0A4049)
#define MCF_GPIO_PCLRR_SSI          (0xFC0A404A)
#define MCF_GPIO_PCLRR_FBCTL        (0xFC0A404B)
#define MCF_GPIO_PCLRR_BE           (0xFC0A404C)
#define MCF_GPIO_PCLRR_CS           (0xFC0A404D)
#define MCF_GPIO_PCLRR_DMA          (0xFC0A404E)
#define MCF_GPIO_PCLRR_FECI2C       (0xFC0A404F)
#define MCF_GPIO_PCLRR_UART         (0xFC0A4051)
#define MCF_GPIO_PCLRR_DSPI         (0xFC0A4052)
#define MCF_GPIO_PCLRR_TIMER        (0xFC0A4053)
#define MCF_GPIO_PCLRR_PCI          (0xFC0A4054)
#define MCF_GPIO_PCLRR_USB          (0xFC0A4055)
#define MCF_GPIO_PCLRR_ATAH         (0xFC0A4056)
#define MCF_GPIO_PCLRR_ATAL         (0xFC0A4057)
#define MCF_GPIO_PCLRR_FEC1H        (0xFC0A4058)
#define MCF_GPIO_PCLRR_FEC1L        (0xFC0A405A) /* 0xFC0A4059 ??? */
#define MCF_GPIO_PCLRR_FBADH        (0xFC0A405C)
#define MCF_GPIO_PCLRR_FBADMH       (0xFC0A405D)
#define MCF_GPIO_PCLRR_FBADML       (0xFC0A405E)
#define MCF_GPIO_PCLRR_FBADL        (0xFC0A405F)
#define MCF_GPIO_PAR_FEC            (0xFC0A4060)
#define MCF_GPIO_PAR_DMA            (0xFC0A4061)
#define MCF_GPIO_PAR_FBCTL          (0xFC0A4062)
#define MCF_GPIO_PAR_DSPI           (0xFC0A4063)
#define MCF_GPIO_PAR_BE             (0xFC0A4064)
#define MCF_GPIO_PAR_CS             (0xFC0A4065)
#define MCF_GPIO_PAR_TIMER          (0xFC0A4066)
#define MCF_GPIO_PAR_USB            (0xFC0A4067)
#define MCF_GPIO_PAR_UART           (0xFC0A4069)
#define MCF_GPIO_PAR_FECI2C         (0xFC0A406A)
#define MCF_GPIO_PAR_SSI            (0xFC0A406C)
#define MCF_GPIO_PAR_ATA            (0xFC0A406E)
#define MCF_GPIO_PAR_IRQ            (0xFC0A4070)
#define MCF_GPIO_PAR_PCI            (0xFC0A4072)
#define MCF_GPIO_MSCR_SDRAM         (0xFC0A4074)
#define MCF_GPIO_MSCR_PCI           (0xFC0A4075)
#define MCF_GPIO_DSCR_I2C           (0xFC0A4078)
#define MCF_GPIO_DSCR_FLEXBUS       (0xFC0A4079)
#define MCF_GPIO_DSCR_FEC           (0xFC0A407A)
#define MCF_GPIO_DSCR_UART          (0xFC0A407B)
#define MCF_GPIO_DSCR_DSPI          (0xFC0A407C)
#define MCF_GPIO_DSCR_TIMER         (0xFC0A407D)
#define MCF_GPIO_DSCR_SSI           (0xFC0A407E)
#define MCF_GPIO_DSCR_DMA           (0xFC0A407F)
#define MCF_GPIO_DSCR_DEBUG         (0xFC0A4080)
#define MCF_GPIO_DSCR_RESET         (0xFC0A4081)
#define MCF_GPIO_DSCR_IRQ           (0xFC0A4082)
#define MCF_GPIO_DSCR_USB           (0xFC0A4083)
#define MCF_GPIO_DSCR_ATA           (0xFC0A4084)

/* Bit definitions and macros for PAR_FEC */
#define GPIO_PAR_FEC_FEC0(x)		(((x)&0x07))
#define GPIO_PAR_FEC_FEC1(x)		(((x)&0x07)<<4)
#define GPIO_PAR_FEC_FEC1_MASK		(0x8F)
#define GPIO_PAR_FEC_FEC1_MII		(0x70)
#define GPIO_PAR_FEC_FEC1_RMII_GPIO	(0x30)
#define GPIO_PAR_FEC_FEC1_RMII_ATA	(0x20)
#define GPIO_PAR_FEC_FEC1_ATA		(0x10)
#define GPIO_PAR_FEC_FEC1_GPIO		(0x00)
#define GPIO_PAR_FEC_FEC0_MASK		(0xF8)
#define GPIO_PAR_FEC_FEC0_MII		(0x07)
#define GPIO_PAR_FEC_FEC0_RMII_GPIO	(0x03)
#define GPIO_PAR_FEC_FEC0_RMII_ULPI	(0x02)
#define GPIO_PAR_FEC_FEC0_ULPI		(0x01)
#define GPIO_PAR_FEC_FEC0_GPIO		(0x00)

/* Bit definitions and macros for PAR_DMA */
#define GPIO_PAR_DMA_DREQ0		(0x01)
#define GPIO_PAR_DMA_DACK0(x)		(((x)&0x03)<<2)
#define GPIO_PAR_DMA_DREQ1(x)		(((x)&0x03)<<4)
#define GPIO_PAR_DMA_DACK1(x)		(((x)&0x03)<<6)
#define GPIO_PAR_DMA_DACK1_MASK		(0x3F)
#define GPIO_PAR_DMA_DACK1_DACK1	(0xC0)
#define GPIO_PAR_DMA_DACK1_ULPI_DIR	(0x40)
#define GPIO_PAR_DMA_DACK1_GPIO		(0x00)
#define GPIO_PAR_DMA_DREQ1_MASK		(0xCF)
#define GPIO_PAR_DMA_DREQ1_DREQ1	(0x30)
#define GPIO_PAR_DMA_DREQ1_USB_CLKIN	(0x10)
#define GPIO_PAR_DMA_DREQ1_GPIO		(0x00)
#define GPIO_PAR_DMA_DACK0_MASK		(0xF3)
#define GPIO_PAR_DMA_DACK0_DACK0	(0x0C)
#define GPIO_PAR_DMA_DACK0_ULPI_DIR	(0x04)
#define GPIO_PAR_DMA_DACK0_GPIO		(0x00)
#define GPIO_PAR_DMA_DREQ0_DREQ0	(0x01)
#define GPIO_PAR_DMA_DREQ0_GPIO		(0x00)

/* Bit definitions and macros for PAR_FBCTL */
#define GPIO_PAR_FBCTL_TS(x)		(((x)&0x03)<<3)
#define GPIO_PAR_FBCTL_RW		(0x20)
#define GPIO_PAR_FBCTL_TA		(0x40)
#define GPIO_PAR_FBCTL_OE		(0x80)
#define GPIO_PAR_FBCTL_OE_OE		(0x80)
#define GPIO_PAR_FBCTL_OE_GPIO		(0x00)
#define GPIO_PAR_FBCTL_TA_TA		(0x40)
#define GPIO_PAR_FBCTL_TA_GPIO		(0x00)
#define GPIO_PAR_FBCTL_RW_RW		(0x20)
#define GPIO_PAR_FBCTL_RW_GPIO		(0x00)
#define GPIO_PAR_FBCTL_TS_MASK		(0xE7)
#define GPIO_PAR_FBCTL_TS_TS		(0x18)
#define GPIO_PAR_FBCTL_TS_ALE		(0x10)
#define GPIO_PAR_FBCTL_TS_TBST		(0x08)
#define GPIO_PAR_FBCTL_TS_GPIO		(0x80)

/* Bit definitions and macros for PAR_DSPI */
#define GPIO_PAR_DSPI_SCK		(0x01)
#define GPIO_PAR_DSPI_SOUT		(0x02)
#define GPIO_PAR_DSPI_SIN		(0x04)
#define GPIO_PAR_DSPI_PCS0		(0x08)
#define GPIO_PAR_DSPI_PCS1		(0x10)
#define GPIO_PAR_DSPI_PCS2		(0x20)
#define GPIO_PAR_DSPI_PCS5		(0x40)
#define GPIO_PAR_DSPI_PCS5_PCS5		(0x40)
#define GPIO_PAR_DSPI_PCS5_GPIO		(0x00)
#define GPIO_PAR_DSPI_PCS2_PCS2		(0x20)
#define GPIO_PAR_DSPI_PCS2_GPIO		(0x00)
#define GPIO_PAR_DSPI_PCS1_PCS1		(0x10)
#define GPIO_PAR_DSPI_PCS1_GPIO		(0x00)
#define GPIO_PAR_DSPI_PCS0_PCS0		(0x08)
#define GPIO_PAR_DSPI_PCS0_GPIO		(0x00)
#define GPIO_PAR_DSPI_SIN_SIN		(0x04)
#define GPIO_PAR_DSPI_SIN_GPIO		(0x00)
#define GPIO_PAR_DSPI_SOUT_SOUT		(0x02)
#define GPIO_PAR_DSPI_SOUT_GPIO		(0x00)
#define GPIO_PAR_DSPI_SCK_SCK		(0x01)
#define GPIO_PAR_DSPI_SCK_GPIO		(0x00)

/* Bit definitions and macros for PAR_BE */
#define GPIO_PAR_BE_BS0			(0x01)
#define GPIO_PAR_BE_BS1			(0x04)
#define GPIO_PAR_BE_BS2(x)		(((x)&0x03)<<4)
#define GPIO_PAR_BE_BS3(x)		(((x)&0x03)<<6)
#define GPIO_PAR_BE_BE3_MASK		(0x3F)
#define GPIO_PAR_BE_BE3_BE3		(0xC0)
#define GPIO_PAR_BE_BE3_TSIZ1		(0x80)
#define GPIO_PAR_BE_BE3_GPIO		(0x00)
#define GPIO_PAR_BE_BE2_MASK		(0xCF)
#define GPIO_PAR_BE_BE2_BE2		(0x30)
#define GPIO_PAR_BE_BE2_TSIZ0		(0x20)
#define GPIO_PAR_BE_BE2_GPIO		(0x00)
#define GPIO_PAR_BE_BE1_BE1		(0x04)
#define GPIO_PAR_BE_BE1_GPIO		(0x00)
#define GPIO_PAR_BE_BE0_BE0		(0x01)
#define GPIO_PAR_BE_BE0_GPIO		(0x00)

/* Bit definitions and macros for PAR_CS */
#define GPIO_PAR_CS_CS1			(0x02)
#define GPIO_PAR_CS_CS2			(0x04)
#define GPIO_PAR_CS_CS3			(0x08)
#define GPIO_PAR_CS_CS3_CS3		(0x08)
#define GPIO_PAR_CS_CS3_GPIO		(0x00)
#define GPIO_PAR_CS_CS2_CS2		(0x04)
#define GPIO_PAR_CS_CS2_GPIO		(0x00)
#define GPIO_PAR_CS_CS1_CS1		(0x02)
#define GPIO_PAR_CS_CS1_GPIO		(0x00)

/* Bit definitions and macros for PAR_TIMER */
#define GPIO_PAR_TIMER_T0IN(x)		(((x)&0x03))
#define GPIO_PAR_TIMER_T1IN(x)		(((x)&0x03)<<2)
#define GPIO_PAR_TIMER_T2IN(x)		(((x)&0x03)<<4)
#define GPIO_PAR_TIMER_T3IN(x)		(((x)&0x03)<<6)
#define GPIO_PAR_TIMER_T3IN_MASK	(0x3F)
#define GPIO_PAR_TIMER_T3IN_T3IN	(0xC0)
#define GPIO_PAR_TIMER_T3IN_T3OUT	(0x80)
#define GPIO_PAR_TIMER_T3IN_U2RXD	(0x40)
#define GPIO_PAR_TIMER_T3IN_GPIO	(0x00)
#define GPIO_PAR_TIMER_T2IN_MASK	(0xCF)
#define GPIO_PAR_TIMER_T2IN_T2IN	(0x30)
#define GPIO_PAR_TIMER_T2IN_T2OUT	(0x20)
#define GPIO_PAR_TIMER_T2IN_U2TXD	(0x10)
#define GPIO_PAR_TIMER_T2IN_GPIO	(0x00)
#define GPIO_PAR_TIMER_T1IN_MASK	(0xF3)
#define GPIO_PAR_TIMER_T1IN_T1IN	(0x0C)
#define GPIO_PAR_TIMER_T1IN_T1OUT	(0x08)
#define GPIO_PAR_TIMER_T1IN_U2CTS	(0x04)
#define GPIO_PAR_TIMER_T1IN_GPIO	(0x00)
#define GPIO_PAR_TIMER_T0IN_MASK	(0xFC)
#define GPIO_PAR_TIMER_T0IN_T0IN	(0x03)
#define GPIO_PAR_TIMER_T0IN_T0OUT	(0x02)
#define GPIO_PAR_TIMER_T0IN_U2RTS	(0x01)
#define GPIO_PAR_TIMER_T0IN_GPIO	(0x00)

/* Bit definitions and macros for PAR_USB */
#define GPIO_PAR_USB_VBUSOC(x)		(((x)&0x03))
#define GPIO_PAR_USB_VBUSEN(x)		(((x)&0x03)<<2)
#define GPIO_PAR_USB_VBUSEN_MASK	(0xF3)
#define GPIO_PAR_USB_VBUSEN_VBUSEN	(0x0C)
#define GPIO_PAR_USB_VBUSEN_USBPULLUP	(0x08)
#define GPIO_PAR_USB_VBUSEN_ULPI_NXT	(0x04)
#define GPIO_PAR_USB_VBUSEN_GPIO	(0x00)
#define GPIO_PAR_USB_VBUSOC_MASK	(0xFC)
#define GPIO_PAR_USB_VBUSOC_VBUSOC	(0x03)
#define GPIO_PAR_USB_VBUSOC_ULPI_STP	(0x01)
#define GPIO_PAR_USB_VBUSOC_GPIO	(0x00)

/* Bit definitions and macros for PAR_UART */
#define GPIO_PAR_UART_U0TXD		(0x01)
#define GPIO_PAR_UART_U0RXD		(0x02)
#define GPIO_PAR_UART_U0RTS		(0x04)
#define GPIO_PAR_UART_U0CTS		(0x08)
#define GPIO_PAR_UART_U1TXD		(0x10)
#define GPIO_PAR_UART_U1RXD		(0x20)
#define GPIO_PAR_UART_U1RTS		(0x40)
#define GPIO_PAR_UART_U1CTS		(0x80)
#define GPIO_PAR_UART_U1CTS_U1CTS	(0x80)
#define GPIO_PAR_UART_U1CTS_GPIO	(0x00)
#define GPIO_PAR_UART_U1RTS_U1RTS	(0x40)
#define GPIO_PAR_UART_U1RTS_GPIO	(0x00)
#define GPIO_PAR_UART_U1RXD_U1RXD	(0x20)
#define GPIO_PAR_UART_U1RXD_GPIO	(0x00)
#define GPIO_PAR_UART_U1TXD_U1TXD	(0x10)
#define GPIO_PAR_UART_U1TXD_GPIO	(0x00)
#define GPIO_PAR_UART_U0CTS_U0CTS	(0x08)
#define GPIO_PAR_UART_U0CTS_GPIO	(0x00)
#define GPIO_PAR_UART_U0RTS_U0RTS	(0x04)
#define GPIO_PAR_UART_U0RTS_GPIO	(0x00)
#define GPIO_PAR_UART_U0RXD_U0RXD	(0x02)
#define GPIO_PAR_UART_U0RXD_GPIO	(0x00)
#define GPIO_PAR_UART_U0TXD_U0TXD	(0x01)
#define GPIO_PAR_UART_U0TXD_GPIO	(0x00)

/* Bit definitions and macros for PAR_FECI2C */
#define GPIO_PAR_FECI2C_SDA(x)		(((x)&0x0003))
#define GPIO_PAR_FECI2C_SCL(x)		(((x)&0x0003)<<2)
#define GPIO_PAR_FECI2C_MDIO0		(0x0010)
#define GPIO_PAR_FECI2C_MDC0		(0x0040)
#define GPIO_PAR_FECI2C_MDIO1(x)	(((x)&0x0003)<<8)
#define GPIO_PAR_FECI2C_MDC1(x)		(((x)&0x0003)<<10)
#define GPIO_PAR_FECI2C_MDC1_MASK	(0xF3FF)
#define GPIO_PAR_FECI2C_MDC1_MDC1	(0x0C00)
#define GPIO_PAR_FECI2C_MDC1_ATA_DIOR	(0x0800)
#define GPIO_PAR_FECI2C_MDC1_GPIO	(0x0000)
#define GPIO_PAR_FECI2C_MDIO1_MASK	(0xFCFF)
#define GPIO_PAR_FECI2C_MDIO1_MDIO1	(0x0300)
#define GPIO_PAR_FECI2C_MDIO1_ATA_DIOW	(0x0200)
#define GPIO_PAR_FECI2C_MDIO1_GPIO	(0x0000)
#define GPIO_PAR_FECI2C_MDC0_MDC0	(0x0040)
#define GPIO_PAR_FECI2C_MDC0_GPIO	(0x0000)
#define GPIO_PAR_FECI2C_MDIO0_MDIO0	(0x0010)
#define GPIO_PAR_FECI2C_MDIO0_GPIO	(0x0000)
#define GPIO_PAR_FECI2C_SCL_MASK	(0xFFF3)
#define GPIO_PAR_FECI2C_SCL_SCL		(0x000C)
#define GPIO_PAR_FECI2C_SCL_U2TXD	(0x0004)
#define GPIO_PAR_FECI2C_SCL_GPIO	(0x0000)
#define GPIO_PAR_FECI2C_SDA_MASK	(0xFFFC)
#define GPIO_PAR_FECI2C_SDA_SDA		(0x0003)
#define GPIO_PAR_FECI2C_SDA_U2RXD	(0x0001)
#define GPIO_PAR_FECI2C_SDA_GPIO	(0x0000)

/* Bit definitions and macros for PAR_SSI */
#define GPIO_PAR_SSI_MCLK		(0x0001)
#define GPIO_PAR_SSI_STXD(x)		(((x)&0x0003)<<2)
#define GPIO_PAR_SSI_SRXD(x)		(((x)&0x0003)<<4)
#define GPIO_PAR_SSI_FS(x)		(((x)&0x0003)<<6)
#define GPIO_PAR_SSI_BCLK(x)		(((x)&0x0003)<<8)
#define GPIO_PAR_SSI_BCLK_MASK		(0xFCFF)
#define GPIO_PAR_SSI_BCLK_BCLK		(0x0300)
#define GPIO_PAR_SSI_BCLK_U1CTS		(0x0200)
#define GPIO_PAR_SSI_BCLK_GPIO		(0x0000)
#define GPIO_PAR_SSI_FS_MASK		(0xFF3F)
#define GPIO_PAR_SSI_FS_FS		(0x00C0)
#define GPIO_PAR_SSI_FS_U1RTS		(0x0080)
#define GPIO_PAR_SSI_FS_GPIO		(0x0000)
#define GPIO_PAR_SSI_SRXD_MASK		(0xFFCF)
#define GPIO_PAR_SSI_SRXD_SRXD		(0x0030)
#define GPIO_PAR_SSI_SRXD_U1RXD		(0x0020)
#define GPIO_PAR_SSI_SRXD_GPIO		(0x0000)
#define GPIO_PAR_SSI_STXD_MASK		(0xFFF3)
#define GPIO_PAR_SSI_STXD_STXD		(0x000C)
#define GPIO_PAR_SSI_STXD_U1TXD		(0x0008)
#define GPIO_PAR_SSI_STXD_GPIO		(0x0000)
#define GPIO_PAR_SSI_MCLK_MCLK		(0x0001)
#define GPIO_PAR_SSI_MCLK_GPIO		(0x0000)

/* Bit definitions and macros for PAR_ATA */
#define GPIO_PAR_ATA_IORDY		(0x0001)
#define GPIO_PAR_ATA_DMARQ		(0x0002)
#define GPIO_PAR_ATA_RESET		(0x0004)
#define GPIO_PAR_ATA_DA0		(0x0020)
#define GPIO_PAR_ATA_DA1		(0x0040)
#define GPIO_PAR_ATA_DA2		(0x0080)
#define GPIO_PAR_ATA_CS0		(0x0100)
#define GPIO_PAR_ATA_CS1		(0x0200)
#define GPIO_PAR_ATA_BUFEN		(0x0400)
#define GPIO_PAR_ATA_BUFEN_BUFEN	(0x0400)
#define GPIO_PAR_ATA_BUFEN_GPIO		(0x0000)
#define GPIO_PAR_ATA_CS1_CS1		(0x0200)
#define GPIO_PAR_ATA_CS1_GPIO		(0x0000)
#define GPIO_PAR_ATA_CS0_CS0		(0x0100)
#define GPIO_PAR_ATA_CS0_GPIO		(0x0000)
#define GPIO_PAR_ATA_DA2_DA2		(0x0080)
#define GPIO_PAR_ATA_DA2_GPIO		(0x0000)
#define GPIO_PAR_ATA_DA1_DA1		(0x0040)
#define GPIO_PAR_ATA_DA1_GPIO		(0x0000)
#define GPIO_PAR_ATA_DA0_DA0		(0x0020)
#define GPIO_PAR_ATA_DA0_GPIO		(0x0000)
#define GPIO_PAR_ATA_RESET_RESET	(0x0004)
#define GPIO_PAR_ATA_RESET_GPIO		(0x0000)
#define GPIO_PAR_ATA_DMARQ_DMARQ	(0x0002)
#define GPIO_PAR_ATA_DMARQ_GPIO		(0x0000)
#define GPIO_PAR_ATA_IORDY_IORDY	(0x0001)
#define GPIO_PAR_ATA_IORDY_GPIO		(0x0000)

/* Bit definitions and macros for PAR_IRQ */
#define GPIO_PAR_IRQ_IRQ1		(0x02)
#define GPIO_PAR_IRQ_IRQ4		(0x10)
#define GPIO_PAR_IRQ_IRQ4_IRQ4		(0x10)
#define GPIO_PAR_IRQ_IRQ4_GPIO		(0x00)
#define GPIO_PAR_IRQ_IRQ1_IRQ1		(0x02)
#define GPIO_PAR_IRQ_IRQ1_GPIO		(0x00)

/* Bit definitions and macros for PAR_PCI */
#define GPIO_PAR_PCI_REQ0		(0x0001)
#define GPIO_PAR_PCI_REQ1		(0x0004)
#define GPIO_PAR_PCI_REQ2		(0x0010)
#define GPIO_PAR_PCI_REQ3(x)		(((x)&0x0003)<<6)
#define GPIO_PAR_PCI_GNT0		(0x0100)
#define GPIO_PAR_PCI_GNT1		(0x0400)
#define GPIO_PAR_PCI_GNT2		(0x1000)
#define GPIO_PAR_PCI_GNT3(x)		(((x)&0x0003)<<14)
#define GPIO_PAR_PCI_GNT3_MASK		(0x3FFF)
#define GPIO_PAR_PCI_GNT3_GNT3		(0xC000)
#define GPIO_PAR_PCI_GNT3_ATA_DMACK	(0x8000)
#define GPIO_PAR_PCI_GNT3_GPIO		(0x0000)
#define GPIO_PAR_PCI_GNT2_GNT2		(0x1000)
#define GPIO_PAR_PCI_GNT2_GPIO		(0x0000)
#define GPIO_PAR_PCI_GNT1_GNT1		(0x0400)
#define GPIO_PAR_PCI_GNT1_GPIO		(0x0000)
#define GPIO_PAR_PCI_GNT0_GNT0		(0x0100)
#define GPIO_PAR_PCI_GNT0_GPIO		(0x0000)
#define GPIO_PAR_PCI_REQ3_MASK		(0xFF3F)
#define GPIO_PAR_PCI_REQ3_REQ3		(0x00C0)
#define GPIO_PAR_PCI_REQ3_ATA_INTRQ	(0x0080)
#define GPIO_PAR_PCI_REQ3_GPIO		(0x0000)
#define GPIO_PAR_PCI_REQ2_REQ2		(0x0010)
#define GPIO_PAR_PCI_REQ2_GPIO		(0x0000)
#define GPIO_PAR_PCI_REQ1_REQ1		(0x0040)
#define GPIO_PAR_PCI_REQ1_GPIO		(0x0000)
#define GPIO_PAR_PCI_REQ0_REQ0		(0x0001)
#define GPIO_PAR_PCI_REQ0_GPIO		(0x0000)

/* Bit definitions and macros for MSCR_SDRAM */
#define GPIO_MSCR_SDRAM_SDCTL(x)	(((x)&0x03))
#define GPIO_MSCR_SDRAM_SDCLK(x)	(((x)&0x03)<<2)
#define GPIO_MSCR_SDRAM_SDDQS(x)	(((x)&0x03)<<4)
#define GPIO_MSCR_SDRAM_SDDATA(x)	(((x)&0x03)<<6)
#define GPIO_MSCR_SDRAM_SDDATA_MASK	(0x3F)
#define GPIO_MSCR_SDRAM_SDDATA_DDR1	(0xC0)
#define GPIO_MSCR_SDRAM_SDDATA_DDR2	(0x80)
#define GPIO_MSCR_SDRAM_SDDATA_FS_LPDDR	(0x40)
#define GPIO_MSCR_SDRAM_SDDATA_HS_LPDDR	(0x00)
#define GPIO_MSCR_SDRAM_SDDQS_MASK	(0xCF)
#define GPIO_MSCR_SDRAM_SDDQS_DDR1	(0x30)
#define GPIO_MSCR_SDRAM_SDDQS_DDR2	(0x20)
#define GPIO_MSCR_SDRAM_SDDQS_FS_LPDDR	(0x10)
#define GPIO_MSCR_SDRAM_SDDQS_HS_LPDDR	(0x00)
#define GPIO_MSCR_SDRAM_SDCLK_MASK	(0xF3)
#define GPIO_MSCR_SDRAM_SDCLK_DDR1	(0x0C)
#define GPIO_MSCR_SDRAM_SDCLK_DDR2	(0x08)
#define GPIO_MSCR_SDRAM_SDCLK_FS_LPDDR	(0x04)
#define GPIO_MSCR_SDRAM_SDCLK_HS_LPDDR	(0x00)
#define GPIO_MSCR_SDRAM_SDCTL_MASK	(0xFC)
#define GPIO_MSCR_SDRAM_SDCTL_DDR1	(0x03)
#define GPIO_MSCR_SDRAM_SDCTL_DDR2	(0x02)
#define GPIO_MSCR_SDRAM_SDCTL_FS_LPDDR	(0x01)
#define GPIO_MSCR_SDRAM_SDCTL_HS_LPDDR	(0x00)

/* Bit definitions and macros for MSCR_PCI */
#define GPIO_MSCR_PCI_PCI		(0x01)
#define GPIO_MSCR_PCI_PCI_HI_66MHZ	(0x01)
#define GPIO_MSCR_PCI_PCI_LO_33MHZ	(0x00)

/* Bit definitions and macros for DSCR_I2C */
#define GPIO_DSCR_I2C_I2C(x)		(((x)&0x03))
#define GPIO_DSCR_I2C_I2C_LOAD_50PF	(0x03)
#define GPIO_DSCR_I2C_I2C_LOAD_30PF	(0x02)
#define GPIO_DSCR_I2C_I2C_LOAD_20PF	(0x01)
#define GPIO_DSCR_I2C_I2C_LOAD_10PF	(0x00)

/* Bit definitions and macros for DSCR_FLEXBUS */
#define GPIO_DSCR_FLEXBUS_FBADL(x)		(((x)&0x03))
#define GPIO_DSCR_FLEXBUS_FBADH(x)		(((x)&0x03)<<2)
#define GPIO_DSCR_FLEXBUS_FBCTL(x)		(((x)&0x03)<<4)
#define GPIO_DSCR_FLEXBUS_FBCLK(x)		(((x)&0x03)<<6)
#define GPIO_DSCR_FLEXBUS_FBCLK_LOAD_50PF	(0xC0)
#define GPIO_DSCR_FLEXBUS_FBCLK_LOAD_30PF	(0x80)
#define GPIO_DSCR_FLEXBUS_FBCLK_LOAD_20PF	(0x40)
#define GPIO_DSCR_FLEXBUS_FBCLK_LOAD_10PF	(0x00)
#define GPIO_DSCR_FLEXBUS_FBCTL_LOAD_50PF	(0x30)
#define GPIO_DSCR_FLEXBUS_FBCTL_LOAD_30PF	(0x20)
#define GPIO_DSCR_FLEXBUS_FBCTL_LOAD_20PF	(0x10)
#define GPIO_DSCR_FLEXBUS_FBCTL_LOAD_10PF	(0x00)
#define GPIO_DSCR_FLEXBUS_FBADH_LOAD_50PF	(0x0C)
#define GPIO_DSCR_FLEXBUS_FBADH_LOAD_30PF	(0x08)
#define GPIO_DSCR_FLEXBUS_FBADH_LOAD_20PF	(0x04)
#define GPIO_DSCR_FLEXBUS_FBADH_LOAD_10PF	(0x00)
#define GPIO_DSCR_FLEXBUS_FBADL_LOAD_50PF	(0x03)
#define GPIO_DSCR_FLEXBUS_FBADL_LOAD_30PF	(0x02)
#define GPIO_DSCR_FLEXBUS_FBADL_LOAD_20PF	(0x01)
#define GPIO_DSCR_FLEXBUS_FBADL_LOAD_10PF	(0x00)

/* Bit definitions and macros for DSCR_FEC */
#define GPIO_DSCR_FEC_FEC0(x)		(((x)&0x03))
#define GPIO_DSCR_FEC_FEC1(x)		(((x)&0x03)<<2)
#define GPIO_DSCR_FEC_FEC1_LOAD_50PF	(0x0C)
#define GPIO_DSCR_FEC_FEC1_LOAD_30PF	(0x08)
#define GPIO_DSCR_FEC_FEC1_LOAD_20PF	(0x04)
#define GPIO_DSCR_FEC_FEC1_LOAD_10PF	(0x00)
#define GPIO_DSCR_FEC_FEC0_LOAD_50PF	(0x03)
#define GPIO_DSCR_FEC_FEC0_LOAD_30PF	(0x02)
#define GPIO_DSCR_FEC_FEC0_LOAD_20PF	(0x01)
#define GPIO_DSCR_FEC_FEC0_LOAD_10PF	(0x00)

/* Bit definitions and macros for DSCR_UART */
#define GPIO_DSCR_UART_UART0(x)		(((x)&0x03))
#define GPIO_DSCR_UART_UART1(x)		(((x)&0x03)<<2)
#define GPIO_DSCR_UART_UART1_LOAD_50PF	(0x0C)
#define GPIO_DSCR_UART_UART1_LOAD_30PF	(0x08)
#define GPIO_DSCR_UART_UART1_LOAD_20PF	(0x04)
#define GPIO_DSCR_UART_UART1_LOAD_10PF	(0x00)
#define GPIO_DSCR_UART_UART0_LOAD_50PF	(0x03)
#define GPIO_DSCR_UART_UART0_LOAD_30PF	(0x02)
#define GPIO_DSCR_UART_UART0_LOAD_20PF	(0x01)
#define GPIO_DSCR_UART_UART0_LOAD_10PF	(0x00)

/* Bit definitions and macros for DSCR_DSPI */
#define GPIO_DSCR_DSPI_DSPI(x)		(((x)&0x03))
#define GPIO_DSCR_DSPI_DSPI_LOAD_50PF	(0x03)
#define GPIO_DSCR_DSPI_DSPI_LOAD_30PF	(0x02)
#define GPIO_DSCR_DSPI_DSPI_LOAD_20PF	(0x01)
#define GPIO_DSCR_DSPI_DSPI_LOAD_10PF	(0x00)

/* Bit definitions and macros for DSCR_TIMER */
#define GPIO_DSCR_TIMER_TIMER(x)	(((x)&0x03))
#define GPIO_DSCR_TIMER_TIMER_LOAD_50PF	(0x03)
#define GPIO_DSCR_TIMER_TIMER_LOAD_30PF	(0x02)
#define GPIO_DSCR_TIMER_TIMER_LOAD_20PF	(0x01)
#define GPIO_DSCR_TIMER_TIMER_LOAD_10PF	(0x00)

/* Bit definitions and macros for DSCR_SSI */
#define GPIO_DSCR_SSI_SSI(x)		(((x)&0x03))
#define GPIO_DSCR_SSI_SSI_LOAD_50PF	(0x03)
#define GPIO_DSCR_SSI_SSI_LOAD_30PF	(0x02)
#define GPIO_DSCR_SSI_SSI_LOAD_20PF	(0x01)
#define GPIO_DSCR_SSI_SSI_LOAD_10PF	(0x00)

/* Bit definitions and macros for DSCR_DMA */
#define GPIO_DSCR_DMA_DMA(x)		(((x)&0x03))
#define GPIO_DSCR_DMA_DMA_LOAD_50PF	(0x03)
#define GPIO_DSCR_DMA_DMA_LOAD_30PF	(0x02)
#define GPIO_DSCR_DMA_DMA_LOAD_20PF	(0x01)
#define GPIO_DSCR_DMA_DMA_LOAD_10PF	(0x00)

/* Bit definitions and macros for DSCR_DEBUG */
#define GPIO_DSCR_DEBUG_DEBUG(x)	(((x)&0x03))
#define GPIO_DSCR_DEBUG_DEBUG_LOAD_50PF	(0x03)
#define GPIO_DSCR_DEBUG_DEBUG_LOAD_30PF	(0x02)
#define GPIO_DSCR_DEBUG_DEBUG_LOAD_20PF	(0x01)
#define GPIO_DSCR_DEBUG_DEBUG_LOAD_10PF	(0x00)

/* Bit definitions and macros for DSCR_RESET */
#define GPIO_DSCR_RESET_RESET(x)	(((x)&0x03))
#define GPIO_DSCR_RESET_RESET_LOAD_50PF	(0x03)
#define GPIO_DSCR_RESET_RESET_LOAD_30PF	(0x02)
#define GPIO_DSCR_RESET_RESET_LOAD_20PF	(0x01)
#define GPIO_DSCR_RESET_RESET_LOAD_10PF	(0x00)

/* Bit definitions and macros for DSCR_IRQ */
#define GPIO_DSCR_IRQ_IRQ(x)		(((x)&0x03))
#define GPIO_DSCR_IRQ_IRQ_LOAD_50PF	(0x03)
#define GPIO_DSCR_IRQ_IRQ_LOAD_30PF	(0x02)
#define GPIO_DSCR_IRQ_IRQ_LOAD_20PF	(0x01)
#define GPIO_DSCR_IRQ_IRQ_LOAD_10PF	(0x00)

/* Bit definitions and macros for DSCR_USB */
#define GPIO_DSCR_USB_USB(x)		(((x)&0x03))
#define GPIO_DSCR_USB_USB_LOAD_50PF	(0x03)
#define GPIO_DSCR_USB_USB_LOAD_30PF	(0x02)
#define GPIO_DSCR_USB_USB_LOAD_20PF	(0x01)
#define GPIO_DSCR_USB_USB_LOAD_10PF	(0x00)

/* Bit definitions and macros for DSCR_ATA */
#define GPIO_DSCR_ATA_ATA(x)		(((x)&0x03))
#define GPIO_DSCR_ATA_ATA_LOAD_50PF	(0x03)
#define GPIO_DSCR_ATA_ATA_LOAD_30PF	(0x02)
#define GPIO_DSCR_ATA_ATA_LOAD_20PF	(0x01)
#define GPIO_DSCR_ATA_ATA_LOAD_10PF	(0x00)

/*********************************************************************
* Random Number Generator (RNG)
*********************************************************************/

/* Register read/write macros */
#define MCF_RNG_RNGCR               (0xFC0B4000)
#define MCF_RNG_RNGSR               (0xFC0B4004)
#define MCF_RNG_RNGER               (0xFC0B4008)
#define MCF_RNG_RNGOUT              (0xFC0B400C)

/* Bit definitions and macros for RNGCR */
#define RNG_RNGCR_GO			(0x00000001)
#define RNG_RNGCR_HA			(0x00000002)
#define RNG_RNGCR_IM			(0x00000004)
#define RNG_RNGCR_CI			(0x00000008)

/* Bit definitions and macros for RNGSR */
#define RNG_RNGSR_SV			(0x00000001)
#define RNG_RNGSR_LRS			(0x00000002)
#define RNG_RNGSR_FUF			(0x00000004)
#define RNG_RNGSR_EI			(0x00000008)
#define RNG_RNGSR_OFL(x)		(((x)&0x000000FF)<<8)
#define RNG_RNGSR_OFS(x)		(((x)&0x000000FF)<<16)

/*********************************************************************
* SDRAM Controller (SDRAMC)
*********************************************************************/

/* Register read/write macros */
#define MCF_SDRAMC_SDMR             (0xFC0B8000)
#define MCF_SDRAMC_SDCR             (0xFC0B8004)
#define MCF_SDRAMC_SDCFG1           (0xFC0B8008)
#define MCF_SDRAMC_SDCFG2           (0xFC0B800C)
#define MCF_SDRAMC_SDCS0            (0xFC0B8110)
#define MCF_SDRAMC_SDCS1            (0xFC0B8114)

/* Bit definitions and macros for SDMR */
#define SDRAMC_SDMR_DDR2_AD(x)		(((x)&0x00003FFF))	/* Address for DDR2 */
#define SDRAMC_SDMR_CMD			(0x00010000)	/* Command */
#define SDRAMC_SDMR_AD(x)		(((x)&0x00000FFF)<<18)	/* Address */
#define SDRAMC_SDMR_BK(x)		(((x)&0x00000003)<<30)	/* Bank Address */
#define SDRAMC_SDMR_BK_LMR		(0x00000000)
#define SDRAMC_SDMR_BK_LEMR		(0x40000000)

/* Bit definitions and macros for SDCR */
#define SDRAMC_SDCR_DPD			(0x00000001)	/* Deep Power-Down Mode */
#define SDRAMC_SDCR_IPALL		(0x00000002)	/* Initiate Precharge All */
#define SDRAMC_SDCR_IREF		(0x00000004)	/* Initiate Refresh */
#define SDRAMC_SDCR_DQS_OE(x)		(((x)&0x00000003)<<10)	/* DQS Output Enable */
#define SDRAMC_SDCR_MEM_PS		(0x00002000)	/* Data Port Size */
#define SDRAMC_SDCR_REF_CNT(x)		(((x)&0x0000003F)<<16)	/* Periodic Refresh Counter */
#define SDRAMC_SDCR_OE_RULE		(0x00400000)	/* Drive Rule Selection */
#define SDRAMC_SDCR_ADDR_MUX(x)		(((x)&0x00000003)<<24)	/* Internal Address Mux Select */
#define SDRAMC_SDCR_DDR2_MODE		(0x08000000)	/* DDR2 Mode Select */
#define SDRAMC_SDCR_REF_EN		(0x10000000)	/* Refresh Enable */
#define SDRAMC_SDCR_DDR_MODE		(0x20000000)	/* DDR Mode Select */
#define SDRAMC_SDCR_CKE			(0x40000000)	/* Clock Enable */
#define SDRAMC_SDCR_MODE_EN		(0x80000000)	/* SDRAM Mode Register Programming Enable */
#define SDRAMC_SDCR_DQS_OE_BOTH		(0x00000C000)

/* Bit definitions and macros for SDCFG1 */
#define SDRAMC_SDCFG1_WT_LAT(x)		(((x)&0x00000007)<<4)	/* Write Latency */
#define SDRAMC_SDCFG1_REF2ACT(x)	(((x)&0x0000000F)<<8)	/* Refresh to active delay */
#define SDRAMC_SDCFG1_PRE2ACT(x)	(((x)&0x00000007)<<12)	/* Precharge to active delay */
#define SDRAMC_SDCFG1_ACT2RW(x)		(((x)&0x00000007)<<16)	/* Active to read/write delay */
#define SDRAMC_SDCFG1_RD_LAT(x)		(((x)&0x0000000F)<<20)	/* Read CAS Latency */
#define SDRAMC_SDCFG1_SWT2RWP(x)	(((x)&0x00000007)<<24)	/* Single write to read/write/precharge delay */
#define SDRAMC_SDCFG1_SRD2RWP(x)	(((x)&0x0000000F)<<28)	/* Single read to read/write/precharge delay */

/* Bit definitions and macros for SDCFG2 */
#define SDRAMC_SDCFG2_BL(x)		(((x)&0x0000000F)<<16)	/* Burst Length */
#define SDRAMC_SDCFG2_BRD2W(x)		(((x)&0x0000000F)<<20)	/* Burst read to write delay */
#define SDRAMC_SDCFG2_BWT2RWP(x)	(((x)&0x0000000F)<<24)	/* Burst write to read/write/precharge delay */
#define SDRAMC_SDCFG2_BRD2RP(x)		(((x)&0x0000000F)<<28)	/* Burst read to read/precharge delay */

/* Bit definitions and macros for SDCS group */
#define SDRAMC_SDCS_CSSZ(x)		(((x)&0x0000001F))	/* Chip-Select Size */
#define SDRAMC_SDCS_CSBA(x)		(((x)&0x00000FFF)<<20)	/* Chip-Select Base Address */
#define SDRAMC_SDCS_BA(x)		((x)&0xFFF00000)
#define SDRAMC_SDCS_CSSZ_DISABLE	(0x00000000)
#define SDRAMC_SDCS_CSSZ_1MBYTE		(0x00000013)
#define SDRAMC_SDCS_CSSZ_2MBYTE		(0x00000014)
#define SDRAMC_SDCS_CSSZ_4MBYTE		(0x00000015)
#define SDRAMC_SDCS_CSSZ_8MBYTE		(0x00000016)
#define SDRAMC_SDCS_CSSZ_16MBYTE	(0x00000017)
#define SDRAMC_SDCS_CSSZ_32MBYTE	(0x00000018)
#define SDRAMC_SDCS_CSSZ_64MBYTE	(0x00000019)
#define SDRAMC_SDCS_CSSZ_128MBYTE	(0x0000001A)
#define SDRAMC_SDCS_CSSZ_256MBYTE	(0x0000001B)
#define SDRAMC_SDCS_CSSZ_512MBYTE	(0x0000001C)
#define SDRAMC_SDCS_CSSZ_1GBYTE		(0x0000001D)
#define SDRAMC_SDCS_CSSZ_2GBYTE		(0x0000001E)
#define SDRAMC_SDCS_CSSZ_4GBYTE		(0x0000001F)

/*********************************************************************
* Synchronous Serial Interface (SSI)
*********************************************************************/

/* Register read/write macros */
#define MCF_SSI_TX0                 (0xFC0BC000)
#define MCF_SSI_TX1                 (0xFC0BC004)
#define MCF_SSI_RX0                 (0xFC0BC008)
#define MCF_SSI_RX1                 (0xFC0BC00C)
#define MCF_SSI_CR                  (0xFC0BC010)
#define MCF_SSI_ISR                 (0xFC0BC014)
#define MCF_SSI_IER                 (0xFC0BC018)
#define MCF_SSI_TCR                 (0xFC0BC01C)
#define MCF_SSI_RCR                 (0xFC0BC020)
#define MCF_SSI_CCR                 (0xFC0BC024)
#define MCF_SSI_FCSR                (0xFC0BC02C)
#define MCF_SSI_ACR                 (0xFC0BC038)
#define MCF_SSI_ACADD               (0xFC0BC03C)
#define MCF_SSI_ACDAT               (0xFC0BC040)
#define MCF_SSI_ATAG                (0xFC0BC044)
#define MCF_SSI_TMASK               (0xFC0BC048)
#define MCF_SSI_RMASK               (0xFC0BC04C)

/* Bit definitions and macros for CR */
#define SSI_CR_SSI_EN			(0x00000001)
#define SSI_CR_TE			(0x00000002)
#define SSI_CR_RE			(0x00000004)
#define SSI_CR_NET			(0x00000008)
#define SSI_CR_SYN			(0x00000010)
#define SSI_CR_I2S(x)			(((x)&0x00000003)<<5)
#define SSI_CR_MCE			(0x00000080)
#define SSI_CR_TCH			(0x00000100)
#define SSI_CR_CIS			(0x00000200)
#define SSI_CR_I2S_NORMAL		(0x00000000)
#define SSI_CR_I2S_MASTER		(0x00000020)
#define SSI_CR_I2S_SLAVE		(0x00000040)

/* Bit definitions and macros for ISR */
#define SSI_ISR_TFE0			(0x00000001)
#define SSI_ISR_TFE1			(0x00000002)
#define SSI_ISR_RFF0			(0x00000004)
#define SSI_ISR_RFF1			(0x00000008)
#define SSI_ISR_RLS			(0x00000010)
#define SSI_ISR_TLS			(0x00000020)
#define SSI_ISR_RFS			(0x00000040)
#define SSI_ISR_TFS			(0x00000080)
#define SSI_ISR_TUE0			(0x00000100)
#define SSI_ISR_TUE1			(0x00000200)
#define SSI_ISR_ROE0			(0x00000400)
#define SSI_ISR_ROE1			(0x00000800)
#define SSI_ISR_TDE0			(0x00001000)
#define SSI_ISR_TDE1			(0x00002000)
#define SSI_ISR_RDR0			(0x00004000)
#define SSI_ISR_RDR1			(0x00008000)
#define SSI_ISR_RXT			(0x00010000)
#define SSI_ISR_CMDDU			(0x00020000)
#define SSI_ISR_CMDAU			(0x00040000)

/* Bit definitions and macros for IER */
#define SSI_IER_TFE0			(0x00000001)
#define SSI_IER_TFE1			(0x00000002)
#define SSI_IER_RFF0			(0x00000004)
#define SSI_IER_RFF1			(0x00000008)
#define SSI_IER_RLS			(0x00000010)
#define SSI_IER_TLS			(0x00000020)
#define SSI_IER_RFS			(0x00000040)
#define SSI_IER_TFS			(0x00000080)
#define SSI_IER_TUE0			(0x00000100)
#define SSI_IER_TUE1			(0x00000200)
#define SSI_IER_ROE0			(0x00000400)
#define SSI_IER_ROE1			(0x00000800)
#define SSI_IER_TDE0			(0x00001000)
#define SSI_IER_TDE1			(0x00002000)
#define SSI_IER_RDR0			(0x00004000)
#define SSI_IER_RDR1			(0x00008000)
#define SSI_IER_RXT			(0x00010000)
#define SSI_IER_CMDU			(0x00020000)
#define SSI_IER_CMDAU			(0x00040000)
#define SSI_IER_TIE			(0x00080000)
#define SSI_IER_TDMAE			(0x00100000)
#define SSI_IER_RIE			(0x00200000)
#define SSI_IER_RDMAE			(0x00400000)

/* Bit definitions and macros for TCR */
#define SSI_TCR_TEFS			(0x00000001)
#define SSI_TCR_TFSL			(0x00000002)
#define SSI_TCR_TFSI			(0x00000004)
#define SSI_TCR_TSCKP			(0x00000008)
#define SSI_TCR_TSHFD			(0x00000010)
#define SSI_TCR_TXDIR			(0x00000020)
#define SSI_TCR_TFDIR			(0x00000040)
#define SSI_TCR_TFEN0			(0x00000080)
#define SSI_TCR_TFEN1			(0x00000100)
#define SSI_TCR_TXBIT0			(0x00000200)

/* Bit definitions and macros for RCR */
#define SSI_RCR_REFS			(0x00000001)
#define SSI_RCR_RFSL			(0x00000002)
#define SSI_RCR_RFSI			(0x00000004)
#define SSI_RCR_RSCKP			(0x00000008)
#define SSI_RCR_RSHFD			(0x00000010)
#define SSI_RCR_RFEN0			(0x00000080)
#define SSI_RCR_RFEN1			(0x00000100)
#define SSI_RCR_RXBIT0			(0x00000200)
#define SSI_RCR_RXEXT			(0x00000400)

/* Bit definitions and macros for CCR */
#define SSI_CCR_PM(x)			(((x)&0x000000FF))
#define SSI_CCR_DC(x)			(((x)&0x0000001F)<<8)
#define SSI_CCR_WL(x)			(((x)&0x0000000F)<<13)
#define SSI_CCR_PSR			(0x00020000)
#define SSI_CCR_DIV2			(0x00040000)

/* Bit definitions and macros for FCSR */
#define SSI_FCSR_TFWM0(x)		(((x)&0x0000000F))
#define SSI_FCSR_RFWM0(x)		(((x)&0x0000000F)<<4)
#define SSI_FCSR_TFCNT0(x)		(((x)&0x0000000F)<<8)
#define SSI_FCSR_RFCNT0(x)		(((x)&0x0000000F)<<12)
#define SSI_FCSR_TFWM1(x)		(((x)&0x0000000F)<<16)
#define SSI_FCSR_RFWM1(x)		(((x)&0x0000000F)<<20)
#define SSI_FCSR_TFCNT1(x)		(((x)&0x0000000F)<<24)
#define SSI_FCSR_RFCNT1(x)		(((x)&0x0000000F)<<28)

/* Bit definitions and macros for ACR */
#define SSI_ACR_AC97EN			(0x00000001)
#define SSI_ACR_FV			(0x00000002)
#define SSI_ACR_TIF			(0x00000004)
#define SSI_ACR_RD			(0x00000008)
#define SSI_ACR_WR			(0x00000010)
#define SSI_ACR_FRDIV(x)		(((x)&0x0000003F)<<5)

/* Bit definitions and macros for ACADD */
#define SSI_ACADD_SSI_ACADD(x)		(((x)&0x0007FFFF))

/* Bit definitions and macros for ACDAT */
#define SSI_ACDAT_SSI_ACDAT(x)		(((x)&0x0007FFFF))

/* Bit definitions and macros for ATAG */
#define SSI_ATAG_DDI_ATAG(x)		(((x)&0x0000FFFF))

/*********************************************************************
* Phase Locked Loop (PLL)
*********************************************************************/

/* Register read/write macros */
#define MCF_PLL_PCR                 (0xFC0C4000)
#define MCF_PLL_PSR                 (0xFC0C4004)

/* Bit definitions and macros for PCR */
#define PLL_PCR_OUTDIV1(x)		(((x)&0x0000000F))	/* Output divider for CPU clock frequency */
#define PLL_PCR_OUTDIV2(x)		(((x)&0x0000000F)<<4)	/* Output divider for internal bus clock frequency */
#define PLL_PCR_OUTDIV3(x)		(((x)&0x0000000F)<<8)	/* Output divider for Flexbus clock frequency */
#define PLL_PCR_OUTDIV4(x)		(((x)&0x0000000F)<<12)	/* Output divider for PCI clock frequency */
#define PLL_PCR_OUTDIV5(x)		(((x)&0x0000000F)<<16)	/* Output divider for USB clock frequency */
#define PLL_PCR_PFDR(x)			(((x)&0x000000FF)<<24)	/* Feedback divider for VCO frequency */
#define PLL_PCR_PFDR_MASK		(0x000F0000)
#define PLL_PCR_OUTDIV5_MASK		(0x000F0000)
#define PLL_PCR_OUTDIV4_MASK		(0x0000F000)
#define PLL_PCR_OUTDIV3_MASK		(0x00000F00)
#define PLL_PCR_OUTDIV2_MASK		(0x000000F0)
#define PLL_PCR_OUTDIV1_MASK		(0x0000000F)

/* Bit definitions and macros for PSR */
#define PLL_PSR_LOCKS			(0x00000001)	/* PLL lost lock - sticky */
#define PLL_PSR_LOCK			(0x00000002)	/* PLL lock status */
#define PLL_PSR_LOLIRQ			(0x00000004)	/* PLL loss-of-lock interrupt enable */
#define PLL_PSR_LOLRE			(0x00000008)	/* PLL loss-of-lock reset enable */

/*********************************************************************
* PCI
*********************************************************************/

/* Register read/write macros */
#define MCF_PCI_PCIIDR                      (0xFC0A8000)
#define MCF_PCI_PCISCR                      (0xFC0A8004)
#define MCF_PCI_PCICCRIR                    (0xFC0A8008)
#define MCF_PCI_PCICR1                      (0xFC0A800C)
#define MCF_PCI_PCIBAR0                     (0xFC0A8010)
#define MCF_PCI_PCIBAR1                     (0xFC0A8014)
#define MCF_PCI_PCIBAR2                     (0xFC0A8018)
#define MCF_PCI_PCIBAR3                     (0xFC0A801C)
#define MCF_PCI_PCIBAR4                     (0xFC0A8020)
#define MCF_PCI_PCIBAR5                     (0xFC0A8024)
#define MCF_PCI_PCIBAR(x)                   (0xFC0A8010+((x)*0x004))
#define MCF_PCI_PCICCPR                     (0xFC0A8028)
#define MCF_PCI_PCISID                      (0xFC0A802C)
#define MCF_PCI_PCIERBAR                    (0xFC0A8030)
#define MCF_PCI_PCICPR                      (0xFC0A8034)
#define MCF_PCI_PCICR2                      (0xFC0A803C)
#define MCF_PCI_PCIGSCR                     (0xFC0A8060)
#define MCF_PCI_PCITBATR0                   (0xFC0A8064)
#define MCF_PCI_PCITBATR1                   (0xFC0A8068)
#define MCF_PCI_PCITCR1                     (0xFC0A806C)
#define MCF_PCI_PCIIW0BTAR                  (0xFC0A8070)
#define MCF_PCI_PCIIW1BTAR                  (0xFC0A8074)
#define MCF_PCI_PCIIW2BTAR                  (0xFC0A8078)
#define MCF_PCI_PCIIWBTAR(x)                (0xFC0A8070+((x)*0x004))
#define MCF_PCI_PCIIWCR                     (0xFC0A8080)
#define MCF_PCI_PCIICR                      (0xFC0A8084)
#define MCF_PCI_PCIISR                      (0xFC0A8088)
#define MCF_PCI_PCITCR2                     (0xFC0A808C)
#define MCF_PCI_PCIITBATR0                  (0xFC0A8090)
#define MCF_PCI_PCIITBARR1                  (0xFC0A8094)
#define MCF_PCI_PCIITBARR2                  (0xFC0A8098)
#define MCF_PCI_PCIITBATR3                  (0xFC0A809C)
#define MCF_PCI_PCIITBARR4                  (0xFC0A80A0)
#define MCF_PCI_PCIITBARR5                  (0xFC0A80A4)
#define MCF_PCI_PCIITBATR(x)                (0xFC0A8090+((x)*0x004))
#define MCF_PCI_PCIINTR                     (0xFC0A80A8)
#define MCF_PCI_PCICAR                      (0xFC0A80F8)
#define MCF_PCIARB_PACR                     (0xFC0AC000)
#define MCF_PCIARB_PASR                     (0xFC0AC004)

/* Bit definitions and macros for SCR */
#define PCI_SCR_PE			(0x80000000)	/* Parity Error detected */
#define PCI_SCR_SE			(0x40000000)	/* System error signalled */
#define PCI_SCR_MA			(0x20000000)	/* Master aboart received */
#define PCI_SCR_TR			(0x10000000)	/* Target abort received */
#define PCI_SCR_TS			(0x08000000)	/* Target abort signalled */
#define PCI_SCR_DT			(0x06000000)	/* PCI_DEVSEL timing */
#define PCI_SCR_DP			(0x01000000)	/* Master data parity err */
#define PCI_SCR_FC			(0x00800000)	/* Fast back-to-back */
#define PCI_SCR_R			(0x00400000)	/* Reserved */
#define PCI_SCR_66M			(0x00200000)	/* 66Mhz */
#define PCI_SCR_C			(0x00100000)	/* Capabilities list */
#define PCI_SCR_F			(0x00000200)	/* Fast back-to-back enable */
#define PCI_SCR_S			(0x00000100)	/* SERR enable */
#define PCI_SCR_ST			(0x00000080)	/* Addr and Data stepping */
#define PCI_SCR_PER			(0x00000040)	/* Parity error response */
#define PCI_SCR_V			(0x00000020)	/* VGA palette snoop enable */
#define PCI_SCR_MW			(0x00000010)	/* Memory write and invalidate enable */
#define PCI_SCR_SP			(0x00000008)	/* Special cycle monitor or ignore */
#define PCI_SCR_B			(0x00000004)	/* Bus master enable */
#define PCI_SCR_M			(0x00000002)	/* Memory access control */
#define PCI_SCR_IO			(0x00000001)	/* I/O access control */

/* Bit definitions and macros for CR1 */
#define PCI_CR1_BIST(x)			((x & 0xFF) << 24)	/* Built in self test */
#define PCI_CR1_HDR(x)			((x & 0xFF) << 16)	/* Header type */
#define PCI_CR1_LTMR(x)			((x & 0xF8) << 8)	/* Latency timer */
#define PCI_CR1_CLS(x)			(x & 0x0F)	/* Cache line size */

/* Bit definitions and macros for BAR */
#define PCI_BAR_BAR0(x)			(x & 0xFFFC0000)
#define PCI_BAR_BAR1(x)			(x & 0xFFF00000)
#define PCI_BAR_BAR2(x)			(x & 0xFFC00000)
#define PCI_BAR_BAR3(x)			(x & 0xFF000000)
#define PCI_BAR_BAR4(x)			(x & 0xF8000000)
#define PCI_BAR_BAR5(x)			(x & 0xE0000000)
#define PCI_BAR_PREF			(0x00000004)	/* Prefetchable access */
#define PCI_BAR_RANGE			(0x00000002)	/* Fixed to 00 */
#define PCI_BAR_IO_M			(0x00000001)	/* IO / memory space */

/* Bit definitions and macros for CR2 */
#define PCI_CR2_MAXLAT(x)		((x & 0xFF) << 24)	/* Maximum latency */
#define PCI_CR2_MINGNT(x)		((x & 0xFF) << 16)	/* Minimum grant */
#define PCI_CR2_INTPIN(x)		((x & 0xFF) << 8)	/* Interrupt Pin */
#define PCI_CR2_INTLIN(x)		(x & 0xFF)	/* Interrupt Line */

/* Bit definitions and macros for GSCR */
#define PCI_GSCR_DRD			(0x80000000)	/* Delayed read discarded */
#define PCI_GSCR_PE			(0x20000000)	/* PCI_PERR detected */
#define PCI_GSCR_SE			(0x10000000)	/* SERR detected */
#define PCI_GSCR_ER			(0x08000000)	/* Error response detected */
#define PCI_GSCR_DRDE			(0x00008000)	/* Delayed read discarded enable */
#define PCI_GSCR_PEE			(0x00002000)	/* PERR detected interrupt enable */
#define PCI_GSCR_SEE			(0x00001000)	/* SERR detected interrupt enable */
#define PCI_GSCR_PR			(0x00000001)	/* PCI reset */

/* Bit definitions and macros for TCR */
#define PCI_TCR1_LD			(0x01000000)	/* Latency rule disable */
#define PCI_TCR1_PID			(0x00020000)	/* Prefetch invalidate and disable */
#define PCI_TCR1_P			(0x00010000)	/* Prefetch reads */
#define PCI_TCR1_WCD			(0x00000100)	/* Write combine disable */
#define PCI_TCR1_B5E			(0x00002000)	/*  */
#define PCI_TCR1_B4E			(0x00001000)	/*  */
#define PCI_TCR1_B3E			(0x00000800)	/*  */
#define PCI_TCR1_B2E			(0x00000400)	/*  */
#define PCI_TCR1_B1E			(0x00000200)	/*  */
#define PCI_TCR1_B0E			(0x00000100)	/*  */
#define PCI_TCR1_CR			(0x00000001)	/*  */

/* Bit definitions and macros for TBATR */
#define PCI_TBATR_BAT(x)		((x & 0xFFF) << 20)
#define PCI_TBATR_EN			(0x00000001)	/* Enable */

/* Bit definitions and macros for IWCR */
#define PCI_IWCR_W0C_IO			(0x08000000)	/* Windows Maps to PCI I/O */
#define PCI_IWCR_W0C_PRC_RDMUL		(0x04000000)	/* PCI Memory Read multiple */
#define PCI_IWCR_W0C_PRC_RDLN		(0x02000000)	/* PCI Memory Read line */
#define PCI_IWCR_W0C_PRC_RD		(0x00000000)	/* PCI Memory Read */
#define PCI_IWCR_W0C_EN			(0x01000000)	/* Enable - Register initialize */
#define PCI_IWCR_W1C_IO			(0x00080000)	/* Windows Maps to PCI I/O */
#define PCI_IWCR_W1C_PRC_RDMUL		(0x00040000)	/* PCI Memory Read multiple */
#define PCI_IWCR_W1C_PRC_RDLN		(0x00020000)	/* PCI Memory Read line */
#define PCI_IWCR_W1C_PRC_RD		(0x00000000)	/* PCI Memory Read */
#define PCI_IWCR_W1C_EN			(0x00010000)	/* Enable - Register initialize */
#define PCI_IWCR_W2C_IO			(0x00000800)	/* Windows Maps to PCI I/O */
#define PCI_IWCR_W2C_PRC_RDMUL		(0x00000400)	/* PCI Memory Read multiple */
#define PCI_IWCR_W2C_PRC_RDLN		(0x00000200)	/* PCI Memory Read line */
#define PCI_IWCR_W2C_PRC_RD		(0x00000000)	/* PCI Memory Read */
#define PCI_IWCR_W2C_EN			(0x00000100)	/* Enable - Register initialize */

/* Bit definitions and macros for ICR */
#define PCI_ICR_REE			(0x04000000)	/* Retry error enable */
#define PCI_ICR_IAE			(0x02000000)	/* Initiator abort enable */
#define PCI_ICR_TAE			(0x01000000)	/* Target abort enable */

/* Bit definitions and macros for CAR */
#define PCI_CAR_DWORD(x)                    (((x)&0x0000003F)<<2)
#define PCI_CAR_FUNCNUM(x)                  (((x)&0x00000007)<<8)
#define PCI_CAR_DEVNUM(x)                   (((x)&0x0000001F)<<11)
#define PCI_CAR_BUSNUM(x)                   (((x)&0x000000FF)<<16)
#define PCI_CAR_E                           (0x80000000)

/*********************************************************************
* System Control Module (SCM)
*********************************************************************/

/* Register read/write macros */
#define MCF_SCM_MPR                         (0xFC000000)
#define MCF_SCM_PACRA                       (0xFC000020)
#define MCF_SCM_PACRB                       (0xFC000024)
#define MCF_SCM_PACRC                       (0xFC000028)
#define MCF_SCM_PACRD                       (0xFC00002C)
#define MCF_SCM_PACRE                       (0xFC000040)
#define MCF_SCM_PACRF                       (0xFC000044)
#define MCF_SCM_PACRG                       (0xFC000048)
#define MCF_SCM_WCR                         (0xFC040013)
#define MCF_SCM_CWCR                        (0xFC040016)
#define MCF_SCM_CWSR                        (0xFC04001B)
#define MCF_SCM_SCMISR                      (0xFC04001F)
#define MCF_SCM_BCR                         (0xFC040024)
#define MCF_SCM_CFADR                       (0xFC040070)
#define MCF_SCM_CFIER                       (0xFC040075)
#define MCF_SCM_CFLOC                       (0xFC040076)
#define MCF_SCM_CFATR                       (0xFC040077)
#define MCF_SCM_CFDTR                       (0xFC04007C)

/* Bit definitions and macros for CWCR */
#define SCM_CWCR_RO      0x8000
#define SCM_CWCR_CWRWH   0x0100
#define SCM_CWCR_CWE     0x0080
#define SCM_CWCR_CWRI(x) (((x)&0x0003)<<5)
#define SCM_CWCR_CWT(x)  (((x)&0x001F))

/*********************************************************************
* Real-Tme Clock (RTC)
*********************************************************************/

/* Register read/write macros */
#define MCF_RTC_HOURMIN                     (0xFC03C000)
#define MCF_RTC_SECONDS                     (0xFC03C004)
#define MCF_RTC_ALRM_HM                     (0xFC03C008)
#define MCF_RTC_ALRM_SEC                    (0xFC03C00C)
#define MCF_RTC_CR                          (0xFC03C010)
#define MCF_RTC_ISR                         (0xFC03C014)
#define MCF_RTC_IER                         (0xFC03C018)
#define MCF_RTC_STPWCH                      (0xFC03C01C)
#define MCF_RTC_DAYS                        (0xFC03C020)
#define MCF_RTC_ALMR_DAY                    (0xFC03C024)
#define MCF_RTC_GOCU                        (0xFC03C034)
#define MCF_RTC_GOCL                        (0xFC03C038)

/* Bit definitions and macros for HOURMIN */
#define RTC_HOURMIN_MINUTES(x)	(((x)&0x0000003F))
#define RTC_HOURMIN_HOURS(x)	(((x)&0x0000001F)<<8)

/* Bit definitions and macros for SECONDS */
#define RTC_SECONDS_SECONDS(x)	(((x)&0x0000003F))

/* Bit definitions and macros for ALRM_HM */
#define RTC_ALRM_HM_MINUTES(x)	(((x)&0x0000003F))
#define RTC_ALRM_HM_HOURS(x)	(((x)&0x0000001F)<<8)

/* Bit definitions and macros for ALRM_SEC */
#define RTC_ALRM_SEC_SECONDS(x)	(((x)&0x0000003F))

/* Bit definitions and macros for CR */
#define RTC_CR_SWR		(0x00000001)
#define RTC_CR_XTL(x)		(((x)&0x00000003)<<5)
#define RTC_CR_EN		(0x00000080)
#define RTC_CR_32768		(0x0)
#define RTC_CR_32000		(0x1)
#define RTC_CR_38400		(0x2)

/* Bit definitions and macros for ISR */
#define RTC_ISR_SW		(0x00000001)
#define RTC_ISR_MIN		(0x00000002)
#define RTC_ISR_ALM		(0x00000004)
#define RTC_ISR_DAY		(0x00000008)
#define RTC_ISR_1HZ		(0x00000010)
#define RTC_ISR_HR		(0x00000020)
#define RTC_ISR_2HZ		(0x00000080)
#define RTC_ISR_SAM0		(0x00000100)
#define RTC_ISR_SAM1		(0x00000200)
#define RTC_ISR_SAM2		(0x00000400)
#define RTC_ISR_SAM3		(0x00000800)
#define RTC_ISR_SAM4		(0x00001000)
#define RTC_ISR_SAM5		(0x00002000)
#define RTC_ISR_SAM6		(0x00004000)
#define RTC_ISR_SAM7		(0x00008000)

/* Bit definitions and macros for IER */
#define RTC_IER_SW		(0x00000001)
#define RTC_IER_MIN		(0x00000002)
#define RTC_IER_ALM		(0x00000004)
#define RTC_IER_DAY		(0x00000008)
#define RTC_IER_1HZ		(0x00000010)
#define RTC_IER_HR		(0x00000020)
#define RTC_IER_2HZ		(0x00000080)
#define RTC_IER_SAM0		(0x00000100)
#define RTC_IER_SAM1		(0x00000200)
#define RTC_IER_SAM2		(0x00000400)
#define RTC_IER_SAM3		(0x00000800)
#define RTC_IER_SAM4		(0x00001000)
#define RTC_IER_SAM5		(0x00002000)
#define RTC_IER_SAM6		(0x00004000)
#define RTC_IER_SAM7		(0x00008000)

/* Bit definitions and macros for STPWCH */
#define RTC_STPWCH_CNT(x)	(((x)&0x0000003F))

/* Bit definitions and macros for DAYS */
#define RTC_DAYS_DAYS(x)	(((x)&0x0000FFFF))

/* Bit definitions and macros for ALRM_DAY */
#define RTC_ALRM_DAY_DAYS(x)	(((x)&0x0000FFFF))

/*********************************************************************
* Fast Ethernet Controller (FEC)
*********************************************************************/

/* Register read/write macros */
#define MCF_FEC_EIR0                     (0xFC030004)
#define MCF_FEC_EIMR0                    (0xFC030008)
#define MCF_FEC_RDAR0                    (0xFC030010)
#define MCF_FEC_TDAR0                    (0xFC030014)
#define MCF_FEC_ECR0                     (0xFC030024)
#define MCF_FEC_MMFR0                    (0xFC030040)
#define MCF_FEC_MSCR0                    (0xFC030044)
#define MCF_FEC_MIBC0                    (0xFC030064)
#define MCF_FEC_RCR0                     (0xFC030084)
#define MCF_FEC_TCR0                     (0xFC0300C4)
#define MCF_FEC_PALR0                    (0xFC0300E4)
#define MCF_FEC_PAUR0                    (0xFC0300E8)
#define MCF_FEC_OPD0                     (0xFC0300EC)
#define MCF_FEC_IAUR0                    (0xFC030118)
#define MCF_FEC_IALR0                    (0xFC03011C)
#define MCF_FEC_GAUR0                    (0xFC030120)
#define MCF_FEC_GALR0                    (0xFC030124)
#define MCF_FEC_TFWR0                    (0xFC030144)
#define MCF_FEC_FRBR0                    (0xFC03014C)
#define MCF_FEC_FRSR0                    (0xFC030150)
#define MCF_FEC_ERDSR0                   (0xFC030180)
#define MCF_FEC_ETDSR0                   (0xFC030184)
#define MCF_FEC_EMRBR0                   (0xFC030188)
#define MCF_FEC_RMON_T_DROP0             (0xFC030200)
#define MCF_FEC_RMON_T_PACKETS0          (0xFC030204)
#define MCF_FEC_RMON_T_BC_PKT0           (0xFC030208)
#define MCF_FEC_RMON_T_MC_PKT0           (0xFC03020C)
#define MCF_FEC_RMON_T_CRC_ALIGN0        (0xFC030210)
#define MCF_FEC_RMON_T_UNDERSIZE0        (0xFC030214)
#define MCF_FEC_RMON_T_OVERSIZE0         (0xFC030218)
#define MCF_FEC_RMON_T_FRAG0             (0xFC03021C)
#define MCF_FEC_RMON_T_JAB0              (0xFC030220)
#define MCF_FEC_RMON_T_COL0              (0xFC030224)
#define MCF_FEC_RMON_T_P640              (0xFC030228)
#define MCF_FEC_RMON_T_P65TO1270         (0xFC03022C)
#define MCF_FEC_RMON_T_P128TO2550        (0xFC030230)
#define MCF_FEC_RMON_T_P256TO5110        (0xFC030234)
#define MCF_FEC_RMON_T_P512TO10230       (0xFC030238)
#define MCF_FEC_RMON_T_P1024TO20470      (0xFC03023C)
#define MCF_FEC_RMON_T_P_GTE20480        (0xFC030240)
#define MCF_FEC_RMON_T_OCTETS0           (0xFC030244)
#define MCF_FEC_IEEE_T_DROP0             (0xFC030248)
#define MCF_FEC_IEEE_T_FRAME_OK0         (0xFC03024C)
#define MCF_FEC_IEEE_T_1COL0             (0xFC030250)
#define MCF_FEC_IEEE_T_MCOL0             (0xFC030254)
#define MCF_FEC_IEEE_T_DEF0              (0xFC030258)
#define MCF_FEC_IEEE_T_LCOL0             (0xFC03025C)
#define MCF_FEC_IEEE_T_EXCOL0            (0xFC030260)
#define MCF_FEC_IEEE_T_MACERR0           (0xFC030264)
#define MCF_FEC_IEEE_T_CSERR0            (0xFC030268)
#define MCF_FEC_IEEE_T_SQE0              (0xFC03026C)
#define MCF_FEC_IEEE_T_FDXFC0            (0xFC030270)
#define MCF_FEC_IEEE_T_OCTETS_OK0        (0xFC030274)
#define MCF_FEC_RMON_R_DROP0             (0xFC030280)
#define MCF_FEC_RMON_R_PACKETS0          (0xFC030284)
#define MCF_FEC_RMON_R_BC_PKT0           (0xFC030288)
#define MCF_FEC_RMON_R_MC_PKT0           (0xFC03028C)
#define MCF_FEC_RMON_R_CRC_ALIGN0        (0xFC030290)
#define MCF_FEC_RMON_R_UNDERSIZE0        (0xFC030294)
#define MCF_FEC_RMON_R_OVERSIZE0         (0xFC030298)
#define MCF_FEC_RMON_R_FRAG0             (0xFC03029C)
#define MCF_FEC_RMON_R_JAB0              (0xFC0302A0)
#define MCF_FEC_RMON_R_RESVD_00          (0xFC0302A4)
#define MCF_FEC_RMON_R_P640              (0xFC0302A8)
#define MCF_FEC_RMON_R_P65TO1270         (0xFC0302AC)
#define MCF_FEC_RMON_R_P128TO2550        (0xFC0302B0)
#define MCF_FEC_RMON_R_P256TO5110        (0xFC0302B4)
#define MCF_FEC_RMON_R_512TO10230        (0xFC0302B8)
#define MCF_FEC_RMON_R_1024TO20470       (0xFC0302BC)
#define MCF_FEC_RMON_R_P_GTE20480        (0xFC0302C0)
#define MCF_FEC_RMON_R_OCTETS0           (0xFC0302C4)
#define MCF_FEC_IEEE_R_DROP0             (0xFC0302C8)
#define MCF_FEC_IEEE_R_FRAME_OK0         (0xFC0302CC)
#define MCF_FEC_IEEE_R_CRC0              (0xFC0302D0)
#define MCF_FEC_IEEE_R_ALIGN0            (0xFC0302D4)
#define MCF_FEC_IEEE_R_MACERR0           (0xFC0302D8)
#define MCF_FEC_IEEE_R_FDXFC0            (0xFC0302DC)
#define MCF_FEC_IEEE_R_OCTETS_OK0        (0xFC0302E0)
#define MCF_FEC_EIR1                     (0xFC034004)
#define MCF_FEC_EIMR1                    (0xFC034008)
#define MCF_FEC_RDAR1                    (0xFC034010)
#define MCF_FEC_TDAR1                    (0xFC034014)
#define MCF_FEC_ECR1                     (0xFC034024)
#define MCF_FEC_MMFR1                    (0xFC034040)
#define MCF_FEC_MSCR1                    (0xFC034044)
#define MCF_FEC_MIBC1                    (0xFC034064)
#define MCF_FEC_RCR1                     (0xFC034084)
#define MCF_FEC_TCR1                     (0xFC0340C4)
#define MCF_FEC_PALR1                    (0xFC0340E4)
#define MCF_FEC_PAUR1                    (0xFC0340E8)
#define MCF_FEC_OPD1                     (0xFC0340EC)
#define MCF_FEC_IAUR1                    (0xFC034118)
#define MCF_FEC_IALR1                    (0xFC03411C)
#define MCF_FEC_GAUR1                    (0xFC034120)
#define MCF_FEC_GALR1                    (0xFC034124)
#define MCF_FEC_TFWR1                    (0xFC034144)
#define MCF_FEC_FRBR1                    (0xFC03414C)
#define MCF_FEC_FRSR1                    (0xFC034150)
#define MCF_FEC_ERDSR1                   (0xFC034180)
#define MCF_FEC_ETDSR1                   (0xFC034184)
#define MCF_FEC_EMRBR1                   (0xFC034188)
#define MCF_FEC_RMON_T_DROP1             (0xFC034200)
#define MCF_FEC_RMON_T_PACKETS1          (0xFC034204)
#define MCF_FEC_RMON_T_BC_PKT1           (0xFC034208)
#define MCF_FEC_RMON_T_MC_PKT1           (0xFC03420C)
#define MCF_FEC_RMON_T_CRC_ALIGN1        (0xFC034210)
#define MCF_FEC_RMON_T_UNDERSIZE1        (0xFC034214)
#define MCF_FEC_RMON_T_OVERSIZE1         (0xFC034218)
#define MCF_FEC_RMON_T_FRAG1             (0xFC03421C)
#define MCF_FEC_RMON_T_JAB1              (0xFC034220)
#define MCF_FEC_RMON_T_COL1              (0xFC034224)
#define MCF_FEC_RMON_T_P641              (0xFC034228)
#define MCF_FEC_RMON_T_P65TO1271         (0xFC03422C)
#define MCF_FEC_RMON_T_P128TO2551        (0xFC034230)
#define MCF_FEC_RMON_T_P256TO5111        (0xFC034234)
#define MCF_FEC_RMON_T_P512TO10231       (0xFC034238)
#define MCF_FEC_RMON_T_P1024TO20471      (0xFC03423C)
#define MCF_FEC_RMON_T_P_GTE20481        (0xFC034240)
#define MCF_FEC_RMON_T_OCTETS1           (0xFC034244)
#define MCF_FEC_IEEE_T_DROP1             (0xFC034248)
#define MCF_FEC_IEEE_T_FRAME_OK1         (0xFC03424C)
#define MCF_FEC_IEEE_T_1COL1             (0xFC034250)
#define MCF_FEC_IEEE_T_MCOL1             (0xFC034254)
#define MCF_FEC_IEEE_T_DEF1              (0xFC034258)
#define MCF_FEC_IEEE_T_LCOL1             (0xFC03425C)
#define MCF_FEC_IEEE_T_EXCOL1            (0xFC034260)
#define MCF_FEC_IEEE_T_MACERR1           (0xFC034264)
#define MCF_FEC_IEEE_T_CSERR1            (0xFC034268)
#define MCF_FEC_IEEE_T_SQE1              (0xFC03426C)
#define MCF_FEC_IEEE_T_FDXFC1            (0xFC034270)
#define MCF_FEC_IEEE_T_OCTETS_OK1        (0xFC034274)
#define MCF_FEC_RMON_R_DROP1             (0xFC034280)
#define MCF_FEC_RMON_R_PACKETS1          (0xFC034284)
#define MCF_FEC_RMON_R_BC_PKT1           (0xFC034288)
#define MCF_FEC_RMON_R_MC_PKT1           (0xFC03428C)
#define MCF_FEC_RMON_R_CRC_ALIGN1        (0xFC034290)
#define MCF_FEC_RMON_R_UNDERSIZE1        (0xFC034294)
#define MCF_FEC_RMON_R_OVERSIZE1         (0xFC034298)
#define MCF_FEC_RMON_R_FRAG1             (0xFC03429C)
#define MCF_FEC_RMON_R_JAB1              (0xFC0342A0)
#define MCF_FEC_RMON_R_RESVD_01          (0xFC0342A4)
#define MCF_FEC_RMON_R_P641              (0xFC0342A8)
#define MCF_FEC_RMON_R_P65TO1271         (0xFC0342AC)
#define MCF_FEC_RMON_R_P128TO2551        (0xFC0342B0)
#define MCF_FEC_RMON_R_P256TO5111        (0xFC0342B4)
#define MCF_FEC_RMON_R_512TO10231        (0xFC0342B8)
#define MCF_FEC_RMON_R_1024TO20471       (0xFC0342BC)
#define MCF_FEC_RMON_R_P_GTE20481        (0xFC0342C0)
#define MCF_FEC_RMON_R_OCTETS1           (0xFC0342C4)
#define MCF_FEC_IEEE_R_DROP1             (0xFC0342C8)
#define MCF_FEC_IEEE_R_FRAME_OK1         (0xFC0342CC)
#define MCF_FEC_IEEE_R_CRC1              (0xFC0342D0)
#define MCF_FEC_IEEE_R_ALIGN1            (0xFC0342D4)
#define MCF_FEC_IEEE_R_MACERR1           (0xFC0342D8)
#define MCF_FEC_IEEE_R_FDXFC1            (0xFC0342DC)
#define MCF_FEC_IEEE_R_OCTETS_OK1        (0xFC0342E0)
#define MCF_FEC_EIR(x)                   ((0xFC030004+((x)*0x4000)))
#define MCF_FEC_EIMR(x)                  ((0xFC030008+((x)*0x4000)))
#define MCF_FEC_RDAR(x)                  ((0xFC030010+((x)*0x4000)))
#define MCF_FEC_TDAR(x)                  ((0xFC030014+((x)*0x4000)))
#define MCF_FEC_ECR(x)                   ((0xFC030024+((x)*0x4000)))
#define MCF_FEC_MMFR(x)                  ((0xFC030040+((x)*0x4000)))
#define MCF_FEC_MSCR(x)                  ((0xFC030044+((x)*0x4000)))
#define MCF_FEC_MIBC(x)                  ((0xFC030064+((x)*0x4000)))
#define MCF_FEC_RCR(x)                   ((0xFC030084+((x)*0x4000)))
#define MCF_FEC_TCR(x)                   ((0xFC0300C4+((x)*0x4000)))
#define MCF_FEC_PALR(x)                  ((0xFC0300E4+((x)*0x4000)))
#define MCF_FEC_PAUR(x)                  ((0xFC0300E8+((x)*0x4000)))
#define MCF_FEC_OPD(x)                   ((0xFC0300EC+((x)*0x4000)))
#define MCF_FEC_IAUR(x)                  ((0xFC030118+((x)*0x4000)))
#define MCF_FEC_IALR(x)                  ((0xFC03011C+((x)*0x4000)))
#define MCF_FEC_GAUR(x)                  ((0xFC030120+((x)*0x4000)))
#define MCF_FEC_GALR(x)                  ((0xFC030124+((x)*0x4000)))
#define MCF_FEC_TFWR(x)                  ((0xFC030144+((x)*0x4000)))
#define MCF_FEC_FRBR(x)                  ((0xFC03014C+((x)*0x4000)))
#define MCF_FEC_FRSR(x)                  ((0xFC030150+((x)*0x4000)))
#define MCF_FEC_ERDSR(x)                 ((0xFC030180+((x)*0x4000)))
#define MCF_FEC_ETDSR(x)                 ((0xFC030184+((x)*0x4000)))
#define MCF_FEC_EMRBR(x)                 ((0xFC030188+((x)*0x4000)))
#define MCF_FEC_RMON_T_DROP(x)           ((0xFC030200+((x)*0x4000)))
#define MCF_FEC_RMON_T_PACKETS(x)        ((0xFC030204+((x)*0x4000)))
#define MCF_FEC_RMON_T_BC_PKT(x)         ((0xFC030208+((x)*0x4000)))
#define MCF_FEC_RMON_T_MC_PKT(x)         ((0xFC03020C+((x)*0x4000)))
#define MCF_FEC_RMON_T_CRC_ALIGN(x)      ((0xFC030210+((x)*0x4000)))
#define MCF_FEC_RMON_T_UNDERSIZE(x)      ((0xFC030214+((x)*0x4000)))
#define MCF_FEC_RMON_T_OVERSIZE(x)       ((0xFC030218+((x)*0x4000)))
#define MCF_FEC_RMON_T_FRAG(x)           ((0xFC03021C+((x)*0x4000)))
#define MCF_FEC_RMON_T_JAB(x)            ((0xFC030220+((x)*0x4000)))
#define MCF_FEC_RMON_T_COL(x)            ((0xFC030224+((x)*0x4000)))
#define MCF_FEC_RMON_T_P64(x)            ((0xFC030228+((x)*0x4000)))
#define MCF_FEC_RMON_T_P65TO127(x)       ((0xFC03022C+((x)*0x4000)))
#define MCF_FEC_RMON_T_P128TO255(x)      ((0xFC030230+((x)*0x4000)))
#define MCF_FEC_RMON_T_P256TO511(x)      ((0xFC030234+((x)*0x4000)))
#define MCF_FEC_RMON_T_P512TO1023(x)     ((0xFC030238+((x)*0x4000)))
#define MCF_FEC_RMON_T_P1024TO2047(x)    ((0xFC03023C+((x)*0x4000)))
#define MCF_FEC_RMON_T_P_GTE2048(x)      ((0xFC030240+((x)*0x4000)))
#define MCF_FEC_RMON_T_OCTETS(x)         ((0xFC030244+((x)*0x4000)))
#define MCF_FEC_IEEE_T_DROP(x)           ((0xFC030248+((x)*0x4000)))
#define MCF_FEC_IEEE_T_FRAME_OK(x)       ((0xFC03024C+((x)*0x4000)))
#define MCF_FEC_IEEE_T_1COL(x)           ((0xFC030250+((x)*0x4000)))
#define MCF_FEC_IEEE_T_MCOL(x)           ((0xFC030254+((x)*0x4000)))
#define MCF_FEC_IEEE_T_DEF(x)            ((0xFC030258+((x)*0x4000)))
#define MCF_FEC_IEEE_T_LCOL(x)           ((0xFC03025C+((x)*0x4000)))
#define MCF_FEC_IEEE_T_EXCOL(x)          ((0xFC030260+((x)*0x4000)))
#define MCF_FEC_IEEE_T_MACERR(x)         ((0xFC030264+((x)*0x4000)))
#define MCF_FEC_IEEE_T_CSERR(x)          ((0xFC030268+((x)*0x4000)))
#define MCF_FEC_IEEE_T_SQE(x)            ((0xFC03026C+((x)*0x4000)))
#define MCF_FEC_IEEE_T_FDXFC(x)          ((0xFC030270+((x)*0x4000)))
#define MCF_FEC_IEEE_T_OCTETS_OK(x)      ((0xFC030274+((x)*0x4000)))
#define MCF_FEC_RMON_R_DROP(x)           ((0xFC030280+((x)*0x4000)))
#define MCF_FEC_RMON_R_PACKETS(x)        ((0xFC030284+((x)*0x4000)))
#define MCF_FEC_RMON_R_BC_PKT(x)         ((0xFC030288+((x)*0x4000)))
#define MCF_FEC_RMON_R_MC_PKT(x)         ((0xFC03028C+((x)*0x4000)))
#define MCF_FEC_RMON_R_CRC_ALIGN(x)      ((0xFC030290+((x)*0x4000)))
#define MCF_FEC_RMON_R_UNDERSIZE(x)      ((0xFC030294+((x)*0x4000)))
#define MCF_FEC_RMON_R_OVERSIZE(x)       ((0xFC030298+((x)*0x4000)))
#define MCF_FEC_RMON_R_FRAG(x)           ((0xFC03029C+((x)*0x4000)))
#define MCF_FEC_RMON_R_JAB(x)            ((0xFC0302A0+((x)*0x4000)))
#define MCF_FEC_RMON_R_RESVD_0(x)        ((0xFC0302A4+((x)*0x4000)))
#define MCF_FEC_RMON_R_P64(x)            ((0xFC0302A8+((x)*0x4000)))
#define MCF_FEC_RMON_R_P65TO127(x)       ((0xFC0302AC+((x)*0x4000)))
#define MCF_FEC_RMON_R_P128TO255(x)      ((0xFC0302B0+((x)*0x4000)))
#define MCF_FEC_RMON_R_P256TO511(x)      ((0xFC0302B4+((x)*0x4000)))
#define MCF_FEC_RMON_R_512TO1023(x)      ((0xFC0302B8+((x)*0x4000)))
#define MCF_FEC_RMON_R_1024TO2047(x)     ((0xFC0302BC+((x)*0x4000)))
#define MCF_FEC_RMON_R_P_GTE2048(x)      ((0xFC0302C0+((x)*0x4000)))
#define MCF_FEC_RMON_R_OCTETS(x)         ((0xFC0302C4+((x)*0x4000)))
#define MCF_FEC_IEEE_R_DROP(x)           ((0xFC0302C8+((x)*0x4000)))
#define MCF_FEC_IEEE_R_FRAME_OK(x)       ((0xFC0302CC+((x)*0x4000)))
#define MCF_FEC_IEEE_R_CRC(x)            ((0xFC0302D0+((x)*0x4000)))
#define MCF_FEC_IEEE_R_ALIGN(x)          ((0xFC0302D4+((x)*0x4000)))
#define MCF_FEC_IEEE_R_MACERR(x)         ((0xFC0302D8+((x)*0x4000)))
#define MCF_FEC_IEEE_R_FDXFC(x)          ((0xFC0302DC+((x)*0x4000)))
#define MCF_FEC_IEEE_R_OCTETS_OK(x)      ((0xFC0302E0+((x)*0x4000)))

/* Bit definitions and macros for FEC_EIR */
#define FEC_EIR_CLEAR_ALL (0xFFF80000)
#define FEC_EIR_HBERR     (0x80000000)
#define FEC_EIR_BABR      (0x40000000)
#define FEC_EIR_BABT      (0x20000000)
#define FEC_EIR_GRA       (0x10000000)
#define FEC_EIR_TXF       (0x08000000)
#define FEC_EIR_TXB       (0x04000000)
#define FEC_EIR_RXF       (0x02000000)
#define FEC_EIR_RXB       (0x01000000)
#define FEC_EIR_MII       (0x00800000)
#define FEC_EIR_EBERR     (0x00400000)
#define FEC_EIR_LC        (0x00200000)
#define FEC_EIR_RL        (0x00100000)
#define FEC_EIR_UN        (0x00080000)

/* Bit definitions and macros for FEC_EIMR */
#define FEC_EIMR_UNMASK_ALL (0xFFF80000)
#define FEC_EIMR_MASK_ALL   (0x00000000)
#define FEC_EIMR_HBERR      (0x80000000)
#define FEC_EIMR_BABR       (0x40000000)
#define FEC_EIMR_BABT       (0x20000000)
#define FEC_EIMR_GRA        (0x10000000)
#define FEC_EIMR_TXF        (0x08000000)
#define FEC_EIMR_RXF        (0x02000000)
#define FEC_EIMR_RXB        (0x01000000)
#define FEC_EIMR_MII        (0x00800000)
#define FEC_EIMR_EBERR      (0x00400000)
#define FEC_EIMR_LC         (0x00200000)
#define FEC_EIMR_RL         (0x00100000)
#define FEC_EIMR_UN         (0x00080000)

/* Bit definitions and macros for FEC_RDAR */
#define FEC_RDAR_R_DES_ACTIVE	(0x01000000)

/* Bit definitions and macros for FEC_TDAR */
#define FEC_TDAR_X_DES_ACTIVE	(0x01000000)

/* Bit definitions and macros for FEC_ECR */
#define FEC_ECR_ETHER_EN	(0x00000002)
#define FEC_ECR_RESET		(0x00000001)

/* Bit definitions and macros for FEC_MMFR */
#define FEC_MMFR_DATA(x)	(((x)&0xFFFF))
#define FEC_MMFR_ST(x)		(((x)&0x03)<<30)
#define FEC_MMFR_ST_01		(0x40000000)
#define FEC_MMFR_OP_RD		(0x20000000)
#define FEC_MMFR_OP_WR		(0x10000000)
#define FEC_MMFR_PA(x)		(((x)&0x1F)<<23)
#define FEC_MMFR_RA(x)		(((x)&0x1F)<<18)
#define FEC_MMFR_TA(x)		(((x)&0x03)<<16)
#define FEC_MMFR_TA_10		(0x00020000)

/* Bit definitions and macros for FEC_MSCR */
#define FEC_MSCR_DIS_PREAMBLE	(0x00000080)
#define FEC_MSCR_MII_SPEED(x)	(((x)&0x3F)<<1)

/* Bit definitions and macros for FEC_MIBC */
#define FEC_MIBC_MIB_DISABLE	(0x80000000)
#define FEC_MIBC_MIB_IDLE	(0x40000000)

/* Bit definitions and macros for FEC_RCR */
#define FEC_RCR_MAX_FL(x)	(((x)&0x7FF)<<16)
#define FEC_RCR_RMII_ECHO (0x00000800)
#define FEC_RCR_RMII_LOOP (0x00000400)
#define FEC_RCR_RMII_10T  (0x00000200)
#define FEC_RCR_RMII_MODE (0x00000100)
#define FEC_RCR_FCE       (0x00000020)
#define FEC_RCR_BC_REJ    (0x00000010)
#define FEC_RCR_PROM      (0x00000008)
#define FEC_RCR_MII_MODE  (0x00000004)
#define FEC_RCR_DRT       (0x00000002)
#define FEC_RCR_LOOP      (0x00000001)

/* Bit definitions and macros for FEC_TCR */
#define FEC_TCR_RFC_PAUSE	(0x00000010)
#define FEC_TCR_TFC_PAUSE	(0x00000008)
#define FEC_TCR_FDEN		(0x00000004)
#define FEC_TCR_HBC		(0x00000002)
#define FEC_TCR_GTS		(0x00000001)

/* Bit definitions and macros for FEC_PAUR */
#define FEC_PAUR_PADDR2(x)	(((x)&0xFFFF)<<16)
#define FEC_PAUR_TYPE(x)	((x)&0xFFFF)

/* Bit definitions and macros for FEC_OPD */
#define FEC_OPD_PAUSE_DUR(x)	(((x)&0x0000FFFF)<<0)
#define FEC_OPD_OPCODE(x)	(((x)&0x0000FFFF)<<16)

/* Bit definitions and macros for FEC_TFWR */
#define FEC_TFWR_X_WMRK(x)	((x)&0x03)
#define FEC_TFWR_X_WMRK_64	(0x01)
#define FEC_TFWR_X_WMRK_128	(0x02)
#define FEC_TFWR_X_WMRK_192	(0x03)

/* Bit definitions and macros for FEC_FRBR */
#define FEC_FRBR_R_BOUND(x)	(((x)&0xFF)<<2)

/* Bit definitions and macros for FEC_FRSR */
#define FEC_FRSR_R_FSTART(x)	(((x)&0xFF)<<2)

/* Bit definitions and macros for FEC_ERDSR */
#define FEC_ERDSR_R_DES_START(x)	(((x)&0x3FFFFFFF)<<2)

/* Bit definitions and macros for FEC_ETDSR */
#define FEC_ETDSR_X_DES_START(x)	(((x)&0x3FFFFFFF)<<2)

/* Bit definitions and macros for FEC_EMRBR */
#define FEC_EMRBR_R_BUF_SIZE(x)		(((x)&0x7F)<<4)

/*********************************************************************
* I2C Module (I2C)
*********************************************************************/

/* Register read/write macros */
#define MCF_I2C_I2AR          (0xFC058000)
#define MCF_I2C_I2FDR         (0xFC058004)
#define MCF_I2C_I2CR          (0xFC058008)
#define MCF_I2C_I2SR          (0xFC05800C)
#define MCF_I2C_I2DR          (0xFC058010)
#define MCF_I2C_I2ICR         (0xFC058020)
                                               
/* Bit definitions and macros for MCF_I2C_I2AR */
#define MCF_I2C_I2AR_ADR(x)   (((x)&0x7F)<<1)

/* Bit definitions and macros for MCF_I2C_I2FDR */
#define MCF_I2C_I2FDR_IC(x)   (((x)&0x3F)<<0)

/* Bit definitions and macros for MCF_I2C_I2CR */
#define MCF_I2C_I2CR_RSTA     (0x04)
#define MCF_I2C_I2CR_TXAK     (0x08)
#define MCF_I2C_I2CR_MTX      (0x10)
#define MCF_I2C_I2CR_MSTA     (0x20)
#define MCF_I2C_I2CR_IIEN     (0x40)
#define MCF_I2C_I2CR_IEN      (0x80)

/* Bit definitions and macros for MCF_I2C_I2SR */
#define MCF_I2C_I2SR_RXAK     (0x01)
#define MCF_I2C_I2SR_IIF      (0x02)
#define MCF_I2C_I2SR_SRW      (0x04)
#define MCF_I2C_I2SR_IAL      (0x10)
#define MCF_I2C_I2SR_IBB      (0x20)
#define MCF_I2C_I2SR_IAAS     (0x40)
#define MCF_I2C_I2SR_ICF      (0x80)

/* Bit definitions and macros for MCF_I2C_I2DR */
#define MCF_I2C_I2DR_DATA(x)  (((x)&0xFF)<<0)

/* Bit definitions and macros for MCF_I2C_I2ICR */
#define MCF_I2C_I2ICR_IE      (0x01)
#define MCF_I2C_I2ICR_RE      (0x02)
#define MCF_I2C_I2ICR_TE      (0x04)
#define MCF_I2C_I2ICR_BNBE    (0x08)

/*********************************************************************
* Universal Asynchronous Receiver Transmitter (UART)
*********************************************************************/

/* Register read/write macros */                            
#define MCF_UART0_UMR                 (0xFC060000)
#define MCF_UART0_USR                 (0xFC060004)
#define MCF_UART0_UCSR                (0xFC060004)
#define MCF_UART0_UCR                 (0xFC060008)
#define MCF_UART0_URB                 (0xFC06000C)
#define MCF_UART0_UTB                 (0xFC06000C)
#define MCF_UART0_UIPCR               (0xFC060010)
#define MCF_UART0_UACR                (0xFC060010)
#define MCF_UART0_UISR                (0xFC060014)
#define MCF_UART0_UIMR                (0xFC060014)
#define MCF_UART0_UBG1                (0xFC060018)
#define MCF_UART0_UBG2                (0xFC06001C)
#define MCF_UART0_UIP                 (0xFC060034)
#define MCF_UART0_UOP1                (0xFC060038)
#define MCF_UART0_UOP0                (0xFC06003C)
#define MCF_UART1_UMR                 (0xFC064000)
#define MCF_UART1_USR                 (0xFC064004)
#define MCF_UART1_UCSR                (0xFC064004))
#define MCF_UART1_UCR                 (0xFC064008)
#define MCF_UART1_URB                 (0xFC06400C)
#define MCF_UART1_UTB                 (0xFC06400C)
#define MCF_UART1_UIPCR               (0xFC064010)
#define MCF_UART1_UACR                (0xFC064010)
#define MCF_UART1_UISR                (0xFC064014)
#define MCF_UART1_UIMR                (0xFC064014)
#define MCF_UART1_UBG1                (0xFC064018)
#define MCF_UART1_UBG2                (0xFC06401C)
#define MCF_UART1_UIP                 (0xFC064034)
#define MCF_UART1_UOP1                (0xFC064038)
#define MCF_UART1_UOP0                (0xFC06403C)
#define MCF_UART2_UMR                 (0xFC068000)
#define MCF_UART2_USR                 (0xFC068004)
#define MCF_UART2_UCSR                (0xFC068004)
#define MCF_UART2_UCR                 (0xFC068008)
#define MCF_UART2_URB                 (0xFC06800C)
#define MCF_UART2_UTB                 (0xFC06800C)
#define MCF_UART2_UIPCR               (0xFC068010)
#define MCF_UART2_UACR                (0xFC068010)
#define MCF_UART2_UISR                (0xFC068014)
#define MCF_UART2_UIMR                (0xFC068014)
#define MCF_UART2_UBG1                (0xFC068018)
#define MCF_UART2_UBG2                (0xFC06801C)
#define MCF_UART2_UIP                 (0xFC068034)
#define MCF_UART2_UOP1                (0xFC068038)
#define MCF_UART2_UOP0                (0xFC06803C)
#define MCF_UART_UMR(x)               (0xFC060000+((x)*0x4000))
#define MCF_UART_USR(x)               (0xFC060004+((x)*0x4000))
#define MCF_UART_UCSR(x)              (0xFC060004+((x)*0x4000))
#define MCF_UART_UCR(x)               (0xFC060008+((x)*0x4000))
#define MCF_UART_URB(x)               (0xFC06000C+((x)*0x4000))
#define MCF_UART_UTB(x)               (0xFC06000C+((x)*0x4000))
#define MCF_UART_UIPCR(x)             (0xFC060010+((x)*0x4000))
#define MCF_UART_UACR(x)              (0xFC060010+((x)*0x4000))
#define MCF_UART_UISR(x)              (0xFC060014+((x)*0x4000))
#define MCF_UART_UIMR(x)              (0xFC060014+((x)*0x4000))
#define MCF_UART_UBG1(x)              (0xFC060018+((x)*0x4000))
#define MCF_UART_UBG2(x)              (0xFC06001C+((x)*0x4000))
#define MCF_UART_UIP(x)               (0xFC060034+((x)*0x4000))
#define MCF_UART_UOP1(x)              (0xFC060038+((x)*0x4000))
#define MCF_UART_UOP0(x)              (0xFC06003C+((x)*0x4000))

/* Bit definitions and macros for UMR */
#define UART_UMR_BC(x)			(((x)&0x03))
#define UART_UMR_PT			(0x04)
#define UART_UMR_PM(x)			(((x)&0x03)<<3)
#define UART_UMR_ERR			(0x20)
#define UART_UMR_RXIRQ			(0x40)
#define UART_UMR_RXRTS			(0x80)
#define UART_UMR_SB(x)			(((x)&0x0F))
#define UART_UMR_TXCTS			(0x10)	/* Trsnsmit CTS */
#define UART_UMR_TXRTS			(0x20)	/* Transmit RTS */
#define UART_UMR_CM(x)			(((x)&0x03)<<6)	/* CM bits */
#define UART_UMR_PM_MULTI_ADDR		(0x1C)
#define UART_UMR_PM_MULTI_DATA		(0x18)
#define UART_UMR_PM_NONE		(0x10)
#define UART_UMR_PM_FORCE_HI		(0x0C)
#define UART_UMR_PM_FORCE_LO		(0x08)
#define UART_UMR_PM_ODD			(0x04)
#define UART_UMR_PM_EVEN		(0x00)
#define UART_UMR_BC_5			(0x00)
#define UART_UMR_BC_6			(0x01)
#define UART_UMR_BC_7			(0x02)
#define UART_UMR_BC_8			(0x03)
#define UART_UMR_CM_NORMAL		(0x00)
#define UART_UMR_CM_ECHO			(0x40)
#define UART_UMR_CM_LOCAL_LOOP		(0x80)
#define UART_UMR_CM_REMOTE_LOOP		(0xC0)
#define UART_UMR_SB_STOP_BITS_1		(0x07)
#define UART_UMR_SB_STOP_BITS_15	(0x08)
#define UART_UMR_SB_STOP_BITS_2		(0x0F)

/* Bit definitions and macros for USR */
#define UART_USR_RXRDY			(0x01)
#define UART_USR_FFULL			(0x02)
#define UART_USR_TXRDY			(0x04)
#define UART_USR_TXEMP			(0x08)
#define UART_USR_OE			(0x10)
#define UART_USR_PE			(0x20)
#define UART_USR_FE			(0x40)
#define UART_USR_RB			(0x80)

/* Bit definitions and macros for UCSR */
#define UART_UCSR_TCS(x)		(((x)&0x0F))
#define UART_UCSR_RCS(x)		(((x)&0x0F)<<4)
#define UART_UCSR_RCS_SYS_CLK		(0xD0)
#define UART_UCSR_RCS_CTM16		(0xE0)
#define UART_UCSR_RCS_CTM		(0xF0)
#define UART_UCSR_TCS_SYS_CLK		(0x0D)
#define UART_UCSR_TCS_CTM16		(0x0E)
#define UART_UCSR_TCS_CTM		(0x0F)

/* Bit definitions and macros for UCR */
#define UART_UCR_RXC(x)			(((x)&0x03))
#define UART_UCR_TXC(x)			(((x)&0x03)<<2)
#define UART_UCR_MISC(x)		(((x)&0x07)<<4)
#define UART_UCR_NONE			(0x00)
#define UART_UCR_STOP_BREAK		(0x70)
#define UART_UCR_START_BREAK		(0x60)
#define UART_UCR_BKCHGINT		(0x50)
#define UART_UCR_RESET_ERROR		(0x40)
#define UART_UCR_RESET_TX		(0x30)
#define UART_UCR_RESET_RX		(0x20)
#define UART_UCR_RESET_MR		(0x10)
#define UART_UCR_TX_DISABLED		(0x08)
#define UART_UCR_TX_ENABLED		(0x04)
#define UART_UCR_RX_DISABLED		(0x02)
#define UART_UCR_RX_ENABLED		(0x01)

/* Bit definitions and macros for UIPCR */
#define UART_UIPCR_CTS			(0x01)
#define UART_UIPCR_COS			(0x10)

/* Bit definitions and macros for UACR */
#define UART_UACR_IEC			(0x01)

/* Bit definitions and macros for UIMR */
#define UART_UIMR_TXRDY			(0x01)
#define UART_UIMR_RXRDY_FU		(0x02)
#define UART_UIMR_DB			(0x04)
#define UART_UIMR_COS			(0x80)

/* Bit definitions and macros for UISR */
#define UART_UISR_TXRDY			(0x01)
#define UART_UISR_RXRDY_FU		(0x02)
#define UART_UISR_DB			(0x04)
#define UART_UISR_RXFTO			(0x08)
#define UART_UISR_TXFIFO		(0x10)
#define UART_UISR_RXFIFO		(0x20)
#define UART_UISR_COS			(0x80)

/* Bit definitions and macros for UIP */
#define UART_UIP_CTS			(0x01)

/* Bit definitions and macros for UOP1 */
#define UART_UOP1_RTS			(0x01)

/* Bit definitions and macros for UOP0 */
#define UART_UOP0_RTS			(0x01)

/*********************************************************************
* DMA Timers (DTIM)
*********************************************************************/

/* Register read/write macros */      
#define MCF_DTIM_DTMR0                   (0xFC070000)
#define MCF_DTIM_DTXMR0                  (0xFC070002)
#define MCF_DTIM_DTER0                   (0xFC070003)
#define MCF_DTIM_DTRR0                   (0xFC070004)
#define MCF_DTIM_DTCR0                   (0xFC070008)
#define MCF_DTIM_DTCN0                   (0xFC07000C)
#define MCF_DTIM_DTMR1                   (0xFC074000)
#define MCF_DTIM_DTXMR1                  (0xFC074002)
#define MCF_DTIM_DTER1                   (0xFC074003)
#define MCF_DTIM_DTRR1                   (0xFC074004)
#define MCF_DTIM_DTCR1                   (0xFC074008)
#define MCF_DTIM_DTCN1                   (0xFC07400C)
#define MCF_DTIM_DTMR2                   (0xFC078000)
#define MCF_DTIM_DTXMR2                  (0xFC078002)
#define MCF_DTIM_DTER2                   (0xFC078003)
#define MCF_DTIM_DTRR2                   (0xFC078004)
#define MCF_DTIM_DTCR2                   (0xFC078008)
#define MCF_DTIM_DTCN2                   (0xFC07800C)
#define MCF_DTIM_DTMR3                   (0xFC07C000)
#define MCF_DTIM_DTXMR3                  (0xFC07C002)
#define MCF_DTIM_DTER3                   (0xFC07C003)
#define MCF_DTIM_DTRR3                   (0xFC07C004)
#define MCF_DTIM_DTCR3                   (0xFC07C008)
#define MCF_DTIM_DTCN3                   (0xFC07C00C)
#define MCF_DTIM_DTMR(x)                 (0xFC070000+((x)*0x4000))
#define MCF_DTIM_DTXMR(x)                (0xFC070002+((x)*0x4000))
#define MCF_DTIM_DTER(x)                 (0xFC070003+((x)*0x4000))
#define MCF_DTIM_DTRR(x)                 (0xFC070004+((x)*0x4000))
#define MCF_DTIM_DTCR(x)                 (0xFC070008+((x)*0x4000))
#define MCF_DTIM_DTCN(x)                 (0xFC07000C+((x)*0x4000))

/* Bit definitions and macros for DTMR */
#define DTIM_DTMR_RST		(0x0001)	/* Reset */
#define DTIM_DTMR_CLK(x)	(((x)&0x0003)<<1)	/* Input clock source */
#define DTIM_DTMR_FRR		(0x0008)	/* Free run/restart */
#define DTIM_DTMR_ORRI		(0x0010)	/* Output reference request/interrupt enable */
#define DTIM_DTMR_OM		(0x0020)	/* Output Mode */
#define DTIM_DTMR_CE(x)		(((x)&0x0003)<<6)	/* Capture Edge */
#define DTIM_DTMR_PS(x)		(((x)&0x00FF)<<8)	/* Prescaler value */
#define DTIM_DTMR_RST_EN	(0x0001)
#define DTIM_DTMR_RST_RST	(0x0000)
#define DTIM_DTMR_CE_ANY	(0x00C0)
#define DTIM_DTMR_CE_FALL	(0x0080)
#define DTIM_DTMR_CE_RISE	(0x0040)
#define DTIM_DTMR_CE_NONE	(0x0000)
#define DTIM_DTMR_CLK_DTIN	(0x0006)
#define DTIM_DTMR_CLK_DIV16	(0x0004)
#define DTIM_DTMR_CLK_DIV1	(0x0002)
#define DTIM_DTMR_CLK_STOP	(0x0000)

/* Bit definitions and macros for DTXMR */
#define DTIM_DTXMR_MODE16	(0x01)	/* Increment Mode */
#define DTIM_DTXMR_DMAEN	(0x80)	/* DMA request */

/* Bit definitions and macros for DTER */
#define DTIM_DTER_CAP		(0x01)	/* Capture event */
#define DTIM_DTER_REF		(0x02)	/* Output reference event */

/*********************************************************************
* Programmable Interrupt Timer Modules (PIT)
*********************************************************************/

/* Register read/write macros */      
#define MCF_PIT_PCSR0                    (0xFC080000)
#define MCF_PIT_PMR0                     (0xFC080002)
#define MCF_PIT_PCNTR0                   (0xFC080004)
#define MCF_PIT_PCSR1                    (0xFC084000)
#define MCF_PIT_PMR1                     (0xFC084002)
#define MCF_PIT_PCNTR1                   (0xFC084004)
#define MCF_PIT_PCSR2                    (0xFC088000)
#define MCF_PIT_PMR2                     (0xFC088002)
#define MCF_PIT_PCNTR2                   (0xFC088004)
#define MCF_PIT_PCSR3                    (0xFC08C000)
#define MCF_PIT_PMR3                     (0xFC08C002)
#define MCF_PIT_PCNTR3                   (0xFC08C004)
#define MCF_PIT_PCSR(x)                  (0xFC080000+((x)*0x4000))
#define MCF_PIT_PMR(x)                   (0xFC080000+((x)*0x4000))
#define MCF_PIT_PCNTR(x)                 (0xFC080000+((x)*0x4000))

/* Bit definitions and macros for PCSR */
#define PIT_PCSR_EN		(0x0001)
#define PIT_PCSR_RLD		(0x0002)
#define PIT_PCSR_PIF		(0x0004)
#define PIT_PCSR_PIE		(0x0008)
#define PIT_PCSR_OVW		(0x0010)
#define PIT_PCSR_HALTED		(0x0020)
#define PIT_PCSR_DOZE		(0x0040)
#define PIT_PCSR_PRE(x)		(((x)&0x000F)<<8)

/* Bit definitions and macros for PMR */
#define PIT_PMR_PM(x)		(x)

/* Bit definitions and macros for PCNTR */
#define PIT_PCNTR_PC(x)		(x)

/*********************************************************************
* Enhanced DMA (EDMA)
*********************************************************************/

/* Register read/write macros */
#define MCF_EDMA_CR                      (0xFC044000)
#define MCF_EDMA_ES                      (0xFC044004)
#define MCF_EDMA_ERQ                     (0xFC04400E)
#define MCF_EDMA_EEI                     (0xFC044016)
#define MCF_EDMA_SERQ                    (0xFC044018)
#define MCF_EDMA_CERQ                    (0xFC044019)
#define MCF_EDMA_SEEI                    (0xFC04401A)
#define MCF_EDMA_CEEI                    (0xFC04401B)
#define MCF_EDMA_CINT                    (0xFC04401C)
#define MCF_EDMA_CERR                    (0xFC04401D)
#define MCF_EDMA_SSRT                    (0xFC04401E)
#define MCF_EDMA_CDNE                    (0xFC04401F)
#define MCF_EDMA_INT                     (0xFC044026)
#define MCF_EDMA_ERR                     (0xFC04402E)
#define MCF_EDMA_DCHPRI0                 (0xFC044100)
#define MCF_EDMA_DCHPRI1                 (0xFC044101)
#define MCF_EDMA_DCHPRI2                 (0xFC044102)
#define MCF_EDMA_DCHPRI3                 (0xFC044103)
#define MCF_EDMA_DCHPRI4                 (0xFC044104)
#define MCF_EDMA_DCHPRI5                 (0xFC044105)
#define MCF_EDMA_DCHPRI6                 (0xFC044106)
#define MCF_EDMA_DCHPRI7                 (0xFC044107)
#define MCF_EDMA_DCHPRI8                 (0xFC044108)
#define MCF_EDMA_DCHPRI9                 (0xFC044109)
#define MCF_EDMA_DCHPRI10                (0xFC04410A)
#define MCF_EDMA_DCHPRI11                (0xFC04410B)
#define MCF_EDMA_DCHPRI12                (0xFC04410C)
#define MCF_EDMA_DCHPRI13                (0xFC04410D)
#define MCF_EDMA_DCHPRI14                (0xFC04410E)
#define MCF_EDMA_DCHPRI15                (0xFC04410F)
#define MCF_EDMA_DCHPRI(x)               ((0xFC044100+(x))
#define MCF_EDMA_TCD0                    (0xFC045000)
#define MCF_EDMA_TCD1                    (0xFC045020)
#define MCF_EDMA_TCD2                    (0xFC045040)
#define MCF_EDMA_TCD3                    (0xFC045060)
#define MCF_EDMA_TCD4                    (0xFC045080)
#define MCF_EDMA_TCD5                    (0xFC0450A0)
#define MCF_EDMA_TCD6                    (0xFC0450C0)
#define MCF_EDMA_TCD7                    (0xFC0450E0)
#define MCF_EDMA_TCD8                    (0xFC045100)
#define MCF_EDMA_TCD9                    (0xFC045120)
#define MCF_EDMA_TCD10                   (0xFC045140)
#define MCF_EDMA_TCD11                   (0xFC045160)
#define MCF_EDMA_TCD12                   (0xFC045180)
#define MCF_EDMA_TCD13                   (0xFC0451A0)
#define MCF_EDMA_TCD14                   (0xFC0451C0)
#define MCF_EDMA_TCD15                   (0xFC0451E0)
#define MCF_EDMA_TCD(x)                  (0xFC045000+((x)*0x20))

/*********************************************************************
* ATA
*********************************************************************/

#define MCF_ATA_TIME_OFF                 (0x90000000)
#define MCF_ATA_TIME_ON                  (0x90000001)
#define MCF_ATA_TIME_1                   (0x90000002)
#define MCF_ATA_TIME_2W                  (0x90000003)
#define MCF_ATA_TIME_2R                  (0x90000004)
#define MCF_ATA_TIME_AX                  (0x90000005)
#define MCF_ATA_TIME_PIORDX              (0x90000006)
#define MCF_ATA_TIME_4                   (0x90000007)
#define MCF_ATA_TIME_9                   (0x90000008)
#define MCF_ATA_TIME_M                   (0x90000009)
#define MCF_ATA_TIME_JN                  (0x9000000A)
#define MCF_ATA_TIME_D                   (0x9000000B)
#define MCF_ATA_TIME_K                   (0x9000000C)
#define MCF_ATA_TIME_ACK                 (0x9000000D)
#define MCF_ATA_TIME_ENV                 (0x9000000E)
#define MCF_ATA_TIME_RPX                 (0x9000000F)
#define MCF_ATA_TIME_ZAH                 (0x90000010)
#define MCF_ATA_TIME_MLIX                (0x90000011)
#define MCF_ATA_TIME_DVH                 (0x90000012)
#define MCF_ATA_TIME_DZFS                (0x90000013)
#define MCF_ATA_TIME_DVS                 (0x90000014)
#define MCF_ATA_TIME_CVH                 (0x90000015)
#define MCF_ATA_TIME_SS                  (0x90000016)
#define MCF_ATA_TIME_CYC                 (0x90000017)
#define MCF_ATA_FIFO_DATA32              (0x90000018)
#define MCF_ATA_FIFO_DATA16              (0x9000001C)
#define MCF_ATA_FIFO_FILL                (0x90000020)
#define MCF_ATA_CR                       (0x90000024)
#define MCF_ATA_ISR                      (0x90000028)
#define MCF_ATA_IER                      (0x9000002C)
#define MCF_ATA_ICR                      (0x90000030)
#define MCF_ATA_FIFO_ALARM               (0x90000034)
#define MCF_ATA_DRIVE_DATA               (0x900000A0)
#define MCF_ATA_DRIVE_FEATURES           (0x900000A4)
#define MCF_ATA_DRIVE_SECTOR_COUNT       (0x900000A8)
#define MCF_ATA_DRIVE_LBA_LOW            (0x900000AC)
#define MCF_ATA_DRIVE_LBA_MID            (0x900000B0)
#define MCF_ATA_DRIVE_LBA_HIGH           (0x900000B4)
#define MCF_ATA_DRIVE_DEV_HEAD           (0x900000B8)
#define MCF_ATA_DRIVE_STATUS             (0x900000BC)
#define MCF_ATA_DRIVE_COMMAND            (0x900000BC)
#define MCF_ATA_DRIVE_ALT_STATUS         (0x900000D8)
#define MCF_ATA_DRIVE_CONTROL            (0x900000D8)

/********************************************************************/

#endif				/* __MCF5445X__ */
