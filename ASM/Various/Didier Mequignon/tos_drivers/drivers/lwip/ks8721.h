/*
 * File:		ks8721.h
 * Purpose:		Driver for the Micrel KS8721 10/100 Ethernet PHY
 *
 * Notes:		
 */

#ifndef _KS8721_H_
#define _KS8721_H_

/********************************************************************/

int ks8721_init(uint8, uint8, uint8, uint8);

/********************************************************************/

/* MII Register Addresses */
#define KS8721_CTRL					(0x00)
#define KS8721_STAT					(0x01)
#define KS8721_PHY_ID1				(0x02)
#define KS8721_PHY_ID2				(0x03)
#define KS8721_AN_ADV				(0x04)
#define KS8721_AN_LINK_PAR			(0x05)
#define KS8721_AN_EXP				(0x06)
#define KS8721_AN_NPR				(0x07)
#define KS8721_LINK_NPA				(0x08)
#define KS8721_RXER_CNT				(0x15)
#define KS8721_ICSR					(0x1B)
#define KS8721_100TX_CTRL			(0x1F)

/* Bit definitions and macros for KS8721_CTRL */
#define KS8721_CTRL_RESET			(0x8000)
#define KS8721_CTRL_LOOP			(0x4000)
#define KS8721_CTRL_SPEED			(0x2000)
#define KS8721_CTRL_ANE				(0x1000)
#define KS8721_CTRL_PD				(0x0800)
#define KS8721_CTRL_ISOLATE			(0x0400)
#define KS8721_CTRL_RESTART_AN		(0x0200)
#define KS8721_CTRL_FDX				(0x0100)
#define KS8721_CTRL_COL_TEST		(0x0080)
#define KS8721_CTRL_DISABLE_TX		(0x0001)

/* Bit definitions and macros for KS8721_STAT */
#define KS8721_STAT_100BT4          (0x8000)
#define KS8721_STAT_100BTX_FDX      (0x4000)
#define KS8721_STAT_100BTX          (0x2000)
#define KS8721_STAT_10BT_FDX        (0x1000)
#define KS8721_STAT_10BT            (0x0800)
#define KS8721_STAT_NO_PREAMBLE     (0x0040)
#define KS8721_STAT_AN_COMPLETE     (0x0020)
#define KS8721_STAT_REMOTE_FAULT    (0x0010)
#define KS8721_STAT_AN_ABILITY      (0x0008)
#define KS8721_STAT_LINK            (0x0004)
#define KS8721_STAT_JABBER          (0x0002)
#define KS8721_STAT_EXTENDED        (0x0001)

/* Bit definitions and macros for KS8721_AN_ADV */
#define KS8721_AN_ADV_NEXT_PAGE		(0x8001)
#define KS8721_AN_ADV_REM_FAULT		(0x2001)
#define KS8721_AN_ADV_PAUSE			(0x0401)
#define KS8721_AN_ADV_100BT4		(0x0201)
#define KS8721_AN_ADV_100BTX_FDX	(0x0101)
#define KS8721_AN_ADV_100BTX		(0x0081)
#define KS8721_AN_ADV_10BT_FDX		(0x0041)
#define KS8721_AN_ADV_10BT			(0x0021)
#define KS8721_AN_ADV_802_3			(0x0001)
										  
/* Bit definitions and macros for KS8721_100TX_CTRL */
#define KS8721_100TX_CTRL_MODE_MASK     (0x001C)
#define KS8721_100TX_CTRL_MODE_AN       (0x0000)
#define KS8721_100TX_CTRL_MODE_10HDX    (0x0004)
#define KS8721_100TX_CTRL_MODE_100HDX   (0x0008)
#define KS8721_100TX_CTRL_MODE_DEFAULT  (0x000C)
#define KS8721_100TX_CTRL_MODE_10FDX    (0x0014)
#define KS8721_100TX_CTRL_MODE_100FDX   (0x0018)
#define KS8721_100TX_CTRL_MODE_ISOLATE  (0x001C)

/********************************************************************/

// Register values
#define   KS8721_ANADV_ADV_ALL       0x01E1
#define   KS8721_CTRL_AN_ENABLE      0x1280
#define   KS8721_CTRL_DEFAULT_MODE   0x2100
#define   KS8721_STAT_ANCOMPLETE     0x0020
#define   KS8721_STAT_FDUPLEX        0x5000

// Timeout for the auto-negotiation mode
#define   KS8721_TIMEOUT             5

#endif /* _KS8721_H_ */
