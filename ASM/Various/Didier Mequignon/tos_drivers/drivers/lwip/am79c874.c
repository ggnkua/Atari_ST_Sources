/*
 * File:        am79c874.c
 * Purpose:     Driver for the AMD AM79C874 10/100 Ethernet PHY
 */

#include "config.h"
#include "net.h"
#include "fec.h"
#include "am79c874.h"

#ifdef NETWORK
#ifdef LWIP

#undef DEBUG

#ifdef DEBUG
extern void conws_debug(char *buf);
#endif

/********************************************************************/
/* Initialize the AM79C874 PHY
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
int am79c874_init(uint8 fec_ch, uint8 phy_addr, uint8 speed, uint8 duplex)
{
	int timeout;
	uint16 settings;
	if(speed); /* to do */
	if(duplex); /* to do */
	
	/* Initialize the MII interface */
	fec_mii_init(fec_ch, SYSTEM_CLOCK);
#ifdef DEBUG
	conws_debug("PHY reset\r\n");
#endif
	/* Reset the PHY */
	if(!fec_mii_write(fec_ch, phy_addr, MII_AM79C874_CR, MII_AM79C874_CR_RESET))
	{
#ifdef DEBUG
		conws_debug("PHY error reset\r\n");
#endif
		return 0;
	}
	/* Wait for the PHY to reset */
	for(timeout = 0; timeout < FEC_MII_TIMEOUT; timeout++)
	{
		fec_mii_read(fec_ch, phy_addr, MII_AM79C874_CR, &settings);
		if(!(settings & MII_AM79C874_CR_RESET))
			break;
	}
	if(timeout >= FEC_MII_TIMEOUT)
	{
#ifdef DEBUG
		conws_debug("PHY error reset timeout\r\n");
#endif
		return 0;
	}
#ifdef DEBUG
	conws_debug("PHY reset OK\r\n");
#endif
#ifdef DEBUG
	conws_debug("PHY Enable Auto-Negotiation\r\n");
#endif
	/* Enable Auto-Negotiation */
	if(!fec_mii_write(fec_ch, phy_addr, MII_AM79C874_CR, MII_AM79C874_CR_AUTON | MII_AM79C874_CR_RST_NEG))
	{
#ifdef DEBUG
		conws_debug("PHY error enable Auto-Negotiation\r\n");
#endif
		return 0;
	}
#ifdef DEBUG
	conws_debug("PHY Wait for auto-negotiation to complete\r\n");
#endif
	/* Wait for auto-negotiation to complete */
	for(timeout = 0; timeout < FEC_MII_TIMEOUT; timeout++)
	{
		settings = 0;
		fec_mii_read(fec_ch, phy_addr, MII_AM79C874_SR, &settings);
		if((settings & AUTONEGLINK) == AUTONEGLINK)
			break;
	}
	if(timeout >= FEC_MII_TIMEOUT)
	{
#ifdef DEBUG
		conws_debug("PHY Set the default mode\r\n");
#endif
		/* Set the default mode (Full duplex, 100 Mbps) */
		if(!fec_mii_write(fec_ch, phy_addr, MII_AM79C874_CR, MII_AM79C874_CR_100MB | MII_AM79C874_CR_DPLX))
		{
#ifdef DEBUG
			conws_debug("PHY error set default mode\r\n");
#endif
			return 0;
		}
	}
#ifdef DEBUG
	settings = 0;
	fec_mii_read(fec_ch, phy_addr, MII_AM79C874_DR, &settings);
	conws_debug("PHY Mode: ");	
	if(settings & MII_AM79C874_DR_DATA_RATE)
		conws_debug("100Mbps ");
	else
		conws_debug("10Mbps ");
	if(settings & MII_AM79C874_DR_DPLX)
		conws_debug("Full-duplex\r\n");
	else
		conws_debug("Half-duplex\r\n");
	conws_debug("PHY auto-negociation complete\r\n");
#endif
	return 1;
}
/********************************************************************/

#endif /* LWIP */
#endif /* NETWORK */
