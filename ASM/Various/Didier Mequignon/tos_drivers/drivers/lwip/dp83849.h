/*
 * File:		dp83849.h
 * Purpose:		Driver for the DP83849 10/100 Ethernet PHY
 *
 * Notes:		
 */

#ifndef _DP83849_H_
#define _DP83849_H_

/********************************************************************/

int dp83849_init(uint8, uint8, uint8, uint8);

/********************************************************************/

/* MII Register Addresses */
#define PHY_BMCR     0x00
#define PHY_BMSR     0x01
#define PHY_PHYIDR1  0x02
#define PHY_PHYIDR2  0x03
#define PHY_ANAR     0x04
#define PHY_ANLPAR   0x05
#define PHY_ANER     0x06
#define PHY_ANNPTR   0x07
#define PHY_ANLPNP   0x08
#define PHY_1000BTCR 0x09
#define PHY_1000BTSR 0x0A
#define PHY_PHYSTS   0x10
#define PHY_MIPSCR   0x11
#define PHY_MIPGSR   0x12
#define PHY_DCR      0x13
#define PHY_FCSCR    0x14
#define PHY_RECR     0x15
#define PHY_PCSR     0x16
#define PHY_LBR      0x17
#define PHY_10BTSCR  0x18
#define PHY_PHYCTRL  0x19

/* Bit definitions and macros for PHY_BMCR */
#define PHY_BMCR_RESET       (0x8000)
#define PHY_BMCR_LOOP        (0x4000)
#define PHY_BMCR_100MB       (0x2000)
#define PHY_BMCR_AUTON       (0x1000)
#define PHY_BMCR_POWD        (0x0800)
#define PHY_BMCR_ISO         (0x0400)
#define PHY_BMCR_RST_NEG     (0x0200)
#define PHY_BMCR_DPLX        (0x0100)
#define PHY_BMCR_COL_TST     (0x0080)
#define PHY_BMCR_SPEED_MASK  (0x2040)
#define PHY_BMCR_1000_MPS    (0x0040)
#define PHY_BMCR_100_MPS     (0x2000)
#define PHY_BMCR_10_MPS      (0x0000)

/* Bit definitions and macros for PHY_BMSR */
#define PHY_BMSR_100T4       (0x8000)
#define PHY_BMSR_100TXF      (0x4000)
#define PHY_BMSR_100TXH      (0x2000)
#define PHY_BMSR_10TF        (0x1000)
#define PHY_BMSR_10TH        (0x0800)
#define PHY_BMSR_PRE_SUP     (0x0040)
#define PHY_BMSR_AUTN_COMP   (0x0020)
#define PHY_BMSR_RF          (0x0010)
#define PHY_BMSR_AUTN_ABLE   (0x0008)
#define PHY_BMSR_LS          (0x0004)
#define PHY_BMSR_JD          (0x0002)
#define PHY_BMSR_EXT         (0x0001)

/* Bit definitions and macros for PHY_ANLPAR */
#define PHY_ANLPAR_NP        (0x8000)
#define PHY_ANLPAR_ACK       (0x4000)
#define PHY_ANLPAR_RF        (0x2000)
#define PHY_ANLPAR_T4        (0x0200)
#define PHY_ANLPAR_TXFD      (0x0100)
#define PHY_ANLPAR_TX        (0x0080)
#define PHY_ANLPAR_10FD      (0x0040)
#define PHY_ANLPAR_10        (0x0020)
#define PHY_ANLPAR_100       (0x0380)
#define PHY_ANLPAR_PSB_MASK  (0x001F)
#define PHY_ANLPAR_PSB_802_3 (0x0001)
#define PHY_ANLPAR_PSB_802_9 (0x0002)

#define AUTONEGLINK		(PHY_BMSR_AUTN_COMP | PHY_BMSR_LS)
										  
/********************************************************************/

#endif /* _DP83849_H_ */
