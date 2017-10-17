/*
 * File:        bcm5222.c
 * Purpose:     Driver for the Micrel BCM5222 10/100 Ethernet PHY
 *
 * Notes:       This driver was written specifically for the M5475EVB
 *              and M5485EVB.  These boards use the MII signals from
 *              FEC0 to control the PHY.  Therefore the fec_ch parameter
 *              is ignored when doing MII reads and writes.
 */

#include "config.h"
#include "net.h"
#include "fec.h"
#include "bcm5222.h"

#ifdef NETWORK
#ifdef LWIP

#undef DEBUG

#ifdef DEBUG
extern void conws_debug(char *buf);
#endif

/********************************************************************/
/* Initialize the BCM5222 PHY
 *
 * This function sets up the Auto-Negotiate Advertisement register
 * within the PHY and then forces the PHY to auto-negotiate for
 * it's settings.
 * 
 * Params:
 *  fec_ch      FEC channel
 *  phy_addr    Address of the PHY.
 *  speed       Desired speed (10BaseT or 100BaseTX)
 *  duplex      Desired duplex (Full or Half)
 *
 * Return Value:
 *  0 if MII commands fail
 *  1 otherwise
 */
int bcm5222_init(uint8 fec_ch, uint8 phy_addr, uint8 speed, uint8 duplex)
{
	int timeout;
	uint16 settings;
	/* Initialize the MII interface */
	fec_mii_init(fec_ch, SYSTEM_CLOCK);
#ifdef DEBUG
	conws_debug("PHY reset\r\n");
#endif
	/* Reset the PHY */
	if(!fec_mii_write(fec_ch, phy_addr, BCM5222_CTRL, BCM5222_CTRL_RESET | BCM5222_CTRL_ANE))
		return 0;
	/* Wait for the PHY to reset */
	for(timeout = 0; timeout < FEC_MII_TIMEOUT; timeout++)
	{
		fec_mii_read(fec_ch, phy_addr, BCM5222_CTRL, &settings);
		if(!(settings & BCM5222_CTRL_RESET))
			break;
	}
	if(timeout >= FEC_MII_TIMEOUT)
		return 0;
#ifdef DEBUG
	conws_debug("PHY reset OK\r\n");
#endif
	settings = (BCM5222_AN_ADV_NEXT_PAGE | BCM5222_AN_ADV_PAUSE);
	if(speed == FEC_MII_10BASE_T)
		settings |= (uint16)((duplex == FEC_MII_FULL_DUPLEX) 
		         ? (BCM5222_AN_ADV_10BT_FDX | BCM5222_AN_ADV_10BT) 
		         : BCM5222_AN_ADV_10BT);
	else /* (speed == FEC_MII_100BASE_TX) */
		settings = (uint16)((duplex == FEC_MII_FULL_DUPLEX)  
		         ? (BCM5222_AN_ADV_100BTX_FDX | BCM5222_AN_ADV_100BTX
		          | BCM5222_AN_ADV_10BT_FDX | BCM5222_AN_ADV_10BT) 
		          : (BCM5222_AN_ADV_100BTX | BCM5222_AN_ADV_10BT));
	/* Set the Auto-Negotiation Advertisement Register */
	if(!fec_mii_write(fec_ch, phy_addr, BCM5222_AN_ADV, settings))
		return 0;
#ifdef DEBUG
	conws_debug("PHY Enable Auto-Negotiation\r\n");
#endif
	/* Enable Auto-Negotiation */
	if(!fec_mii_write(fec_ch, phy_addr, BCM5222_CTRL, (BCM5222_CTRL_ANE | BCM5222_CTRL_RESTART_AN)))
		return 0;
#ifdef DEBUG
	conws_debug("PHY Wait for auto-negotiation to complete\r\n");
#endif
	/* Wait for auto-negotiation to complete */
	for(timeout = 0; timeout < FEC_MII_TIMEOUT; timeout++)
	{
		if(!fec_mii_read(fec_ch, phy_addr, BCM5222_STAT, &settings))
			return 0;
		if(settings & BCM5222_STAT_AN_COMPLETE)
			break;
	}
	if(timeout < FEC_MII_TIMEOUT)
	{
#ifdef DEBUG
	  conws_debug("PHY auto-negociation complete\r\n");
#endif
		/* Read Auxiliary Control/Status Register */
		if(!fec_mii_read(fec_ch, phy_addr, BCM5222_ACSR, &settings))
			return 0;
	}
	else
	{
#ifdef DEBUG
	  conws_debug("PHY Set the default mode\r\n");
#endif
		/* Set the default mode (Full duplex, 100 Mbps) */
		if(!fec_mii_write(fec_ch, phy_addr, BCM5222_ACSR, settings = (BCM5222_ACSR_100BTX | BCM5222_ACSR_FDX)))
			return 0;
	}
	/* Set the proper duplex in the FEC now that we have auto-negotiated */
	if(settings & BCM5222_ACSR_FDX)
		fec_duplex(fec_ch, FEC_MII_FULL_DUPLEX);
	else
		fec_duplex(fec_ch, FEC_MII_HALF_DUPLEX);
#ifdef DEBUG
	conws_debug("PHY Mode: ");
	if(settings & BCM5222_ACSR_100BTX)
		conws_debug("100Mbps ");
	else
		conws_debug("10Mbps ");
	if(settings & BCM5222_ACSR_FDX)
		conws_debug("Full-duplex\r\n");
	else
		conws_debug("Half-duplex\r\n");
#endif
	return 1;
}
/********************************************************************/
void bcm5222_get_reg(uint16* status0, uint16* status1)
{
	fec_mii_read(0, 0x00, 0x00000000, &status0[0]); 
	fec_mii_read(0, 0x00, 0x00000001, &status0[1]); 
	fec_mii_read(0, 0x00, 0x00000004, &status0[4]); 
	fec_mii_read(0, 0x00, 0x00000005, &status0[5]); 
	fec_mii_read(0, 0x00, 0x00000006, &status0[6]); 
	fec_mii_read(0, 0x00, 0x00000007, &status0[7]); 
	fec_mii_read(0, 0x00, 0x00000008, &status0[8]); 
	fec_mii_read(0, 0x00, 0x00000010, &status0[16]);
	fec_mii_read(0, 0x00, 0x00000011, &status0[17]);
	fec_mii_read(0, 0x00, 0x00000012, &status0[18]);
	fec_mii_read(0, 0x00, 0x00000013, &status0[19]);
	fec_mii_read(0, 0x00, 0x00000018, &status0[24]);
	fec_mii_read(0, 0x00, 0x00000019, &status0[25]);
	fec_mii_read(0, 0x00, 0x0000001B, &status0[27]);
	fec_mii_read(0, 0x00, 0x0000001C, &status0[28]);
	fec_mii_read(0, 0x00, 0x0000001E, &status0[30]);
	fec_mii_read(0, 0x01, 0x00000000, &status1[0]);
	fec_mii_read(0, 0x01, 0x00000001, &status1[1]);
	fec_mii_read(0, 0x01, 0x00000004, &status1[4]);
	fec_mii_read(0, 0x01, 0x00000005, &status1[5]);
	fec_mii_read(0, 0x01, 0x00000006, &status1[6]);
	fec_mii_read(0, 0x01, 0x00000007, &status1[7]);
	fec_mii_read(0, 0x01, 0x00000008, &status1[8]);
	fec_mii_read(0, 0x01, 0x00000010, &status1[16]);
	fec_mii_read(0, 0x01, 0x00000011, &status1[17]);
	fec_mii_read(0, 0x01, 0x00000012, &status1[18]);
	fec_mii_read(0, 0x01, 0x00000013, &status1[19]);
	fec_mii_read(0, 0x01, 0x00000018, &status1[24]);
	fec_mii_read(0, 0x01, 0x00000019, &status1[25]);
	fec_mii_read(0, 0x01, 0x0000001B, &status1[27]);
	fec_mii_read(0, 0x01, 0x0000001C, &status1[28]);
	fec_mii_read(0, 0x01, 0x0000001E, &status1[30]);
}
/********************************************************************/

#endif /* LWIP */
#endif /* NETWORK */
