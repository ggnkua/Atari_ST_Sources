/*
 * File:		am79c874.h
 * Purpose:		Driver for the AM79C874 10/100 Ethernet PHY
 *
 * Notes:		
 */

#ifndef _AM79C874_H_
#define _AM79C874_H_

/********************************************************************/

int am79c874_init(uint8, uint8, uint8, uint8);

/********************************************************************/

/* MII Register Addresses */
#define MII_AM79C874_CR         0  /* MII Management Control Register */
#define MII_AM79C874_SR         1  /* MII Management Status Register */
#define MII_AM79C874_PHYIDR1    2  /* PHY Identifier 1 Register */
#define MII_AM79C874_PHYIDR2    3  /* PHY Identifier 2 Register */
#define MII_AM79C874_ANAR       4  /* Auto-Negociation Advertissement Register */
#define MII_AM79C874_ANLPAR     5  /* Auto-Negociation Link Partner Register */
#define MII_AM79C874_ANER       6  /* Auto-Negociation Expansion Register */
#define MII_AM79C874_ANNPTR     7  /* Next Page Advertisement Register */
#define MII_AM79C874_MFR       16  /* Miscellaneous Feature Register */
#define MII_AM79C874_ICSR      17  /* Interrupt/Status Register      */
#define MII_AM79C874_DR        18  /* Diagnostic Register            */
#define MII_AM79C874_PMLR      19  /* Power and Loopback Register    */
#define MII_AM79C874_MCR       21  /* ModeControl Register           */
#define MII_AM79C874_DC        23  /* Disconnect Counter             */
#define MII_AM79C874_REC       24  /* Recieve Error Counter          */

/* Bit definitions and macros for MII_AM79C874_CR */
#define MII_AM79C874_CR_RESET       (0x8000)
#define MII_AM79C874_CR_LOOP        (0x4000)
#define MII_AM79C874_CR_100MB       (0x2000)
#define MII_AM79C874_CR_AUTON       (0x1000)
#define MII_AM79C874_CR_POWD        (0x0800)
#define MII_AM79C874_CR_ISO         (0x0400)
#define MII_AM79C874_CR_RST_NEG     (0x0200)
#define MII_AM79C874_CR_DPLX        (0x0100)
#define MII_AM79C874_CR_COL_TST     (0x0080)
#define MII_AM79C874_CR_SPEED_MASK  (0x2040)
#define MII_AM79C874_CR_1000_MPS    (0x0040)
#define MII_AM79C874_CR_100_MPS     (0x2000)
#define MII_AM79C874_CR_10_MPS      (0x0000)

/* Bit definitions and macros for MII_AM79C874_SR */
#define MII_AM79C874_SR_100T4       (0x8000)
#define MII_AM79C874_SR_100TXF      (0x4000)
#define MII_AM79C874_SR_100TXH      (0x2000)
#define MII_AM79C874_SR_10TF        (0x1000)
#define MII_AM79C874_SR_10TH        (0x0800)
#define MII_AM79C874_SR_PRE_SUP     (0x0040)
#define MII_AM79C874_SR_AUTN_COMP   (0x0020)
#define MII_AM79C874_SR_RF          (0x0010)
#define MII_AM79C874_SR_AUTN_ABLE   (0x0008)
#define MII_AM79C874_SR_LS          (0x0004)
#define MII_AM79C874_SR_JD          (0x0002)
#define MII_AM79C874_SR_EXT         (0x0001)

/* Bit definitions and macros for MII_AM79C874_ANLPAR */
#define MII_AM79C874_ANLPAR_NP        (0x8000)
#define MII_AM79C874_ANLPAR_ACK       (0x4000)
#define MII_AM79C874_ANLPAR_RF        (0x2000)
#define MII_AM79C874_ANLPAR_T4        (0x0200)
#define MII_AM79C874_ANLPAR_TXFD      (0x0100)
#define MII_AM79C874_ANLPAR_TX        (0x0080)
#define MII_AM79C874_ANLPAR_10FD      (0x0040)
#define MII_AM79C874_ANLPAR_10        (0x0020)
#define MII_AM79C874_ANLPAR_100       (0x0380)
#define MII_AM79C874_ANLPAR_PSB_MASK  (0x001F)
#define MII_AM79C874_ANLPAR_PSB_802_3 (0x0001)
#define MII_AM79C874_ANLPAR_PSB_802_9 (0x0002)

/* Bit definitions and macros for MII_AM79C874_DR */
#define MII_AM79C874_DR_DPLX          (0x0800)
#define MII_AM79C874_DR_DATA_RATE     (0x0400)
#define MII_AM79C874_DR_RX_PASS       (0x0200)
#define MII_AM79C874_DR_RX_LOCK       (0x0100)

#define AUTONEGLINK		(MII_AM79C874_SR_AUTN_COMP | MII_AM79C874_SR_LS)
										  
/********************************************************************/

#endif /* _AM79C874_H_ */
