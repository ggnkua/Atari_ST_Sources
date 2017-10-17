/*
 * File:		bcm5222.h
 * Purpose:		Driver for the BCM5222 10/100 Ethernet PHY
 *
 * Notes:		
 */

#ifndef _BCM5222_H_
#define _BCM5222_H_

/********************************************************************/

int
bcm5222_init(uint8, uint8, uint8, uint8);

void 
bcm5222_get_reg(uint16*, uint16*);

/********************************************************************/

/* MII Register Addresses */
#define BCM5222_CTRL				(0x00)
#define BCM5222_STAT				(0x01)
#define BCM5222_PHY_ID1				(0x02)
#define BCM5222_PHY_ID2				(0x03)
#define BCM5222_AN_ADV				(0x04)
#define BCM5222_AN_LINK_PAR			(0x05)
#define BCM5222_AN_EXP				(0x06)
#define BCM5222_AN_NPR				(0x07)
#define BCM5222_LINK_NPA			(0x08)
#define BCM5222_ACSR    			(0x18)

/* Bit definitions and macros for BCM5222_CTRL */
#define BCM5222_CTRL_RESET			(0x8000)
#define BCM5222_CTRL_LOOP			(0x4000)
#define BCM5222_CTRL_SPEED			(0x2000)
#define BCM5222_CTRL_ANE			(0x1000)
#define BCM5222_CTRL_PD				(0x0800)
#define BCM5222_CTRL_ISOLATE		(0x0400)
#define BCM5222_CTRL_RESTART_AN		(0x0200)
#define BCM5222_CTRL_FDX			(0x0100)
#define BCM5222_CTRL_COL_TEST		(0x0080)


/* Bit definitions and macros for BCM5222_STAT */
#define BCM5222_STAT_100BT4         (0x8000)
#define BCM5222_STAT_100BTX_FDX     (0x4000)
#define BCM5222_STAT_100BTX         (0x2000)
#define BCM5222_STAT_10BT_FDX       (0x1000)
#define BCM5222_STAT_10BT           (0x0800)
#define BCM5222_STAT_NO_PREAMBLE    (0x0040)
#define BCM5222_STAT_AN_COMPLETE    (0x0020)
#define BCM5222_STAT_REMOTE_FAULT   (0x0010)
#define BCM5222_STAT_AN_ABILITY     (0x0008)
#define BCM5222_STAT_LINK           (0x0004)
#define BCM5222_STAT_JABBER         (0x0002)
#define BCM5222_STAT_EXTENDED       (0x0001)

/* Bit definitions and macros for BCM5222_AN_ADV */
#define BCM5222_AN_ADV_NEXT_PAGE    (0x8001)
#define BCM5222_AN_ADV_REM_FAULT	(0x2001)
#define BCM5222_AN_ADV_PAUSE		(0x0401)
#define BCM5222_AN_ADV_100BT4		(0x0201)
#define BCM5222_AN_ADV_100BTX_FDX	(0x0101)
#define BCM5222_AN_ADV_100BTX		(0x0081)
#define BCM5222_AN_ADV_10BT_FDX		(0x0041)
#define BCM5222_AN_ADV_10BT		    (0x0021)
#define BCM5222_AN_ADV_802_3		(0x0001)

/* Bit definitions and macros for BCM5222_ACSR */
#define BCM5222_ACSR_100BTX         (0x0002)
#define BCM5222_ACSR_FDX            (0x0001)
										  
/********************************************************************/

#endif /* _BCM5222_H_ */
