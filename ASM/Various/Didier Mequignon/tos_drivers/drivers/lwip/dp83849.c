/*
 * File:        dp83849.c
 * Purpose:     Driver for the National DP83849 10/100 Ethernet PHY
 */

#include "config.h"
#include "net.h"
#include "fec.h"
#include "dp83849.h"

#ifdef NETWORK
#ifdef LWIP

#undef DEBUG

#ifdef DEBUG
extern void conws_debug(char *buf);
#endif

/********************************************************************/
/* Initialize the DP83849 PHY
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
int dp83849_init(uint8 fec_ch, uint8 phy_addr, uint8 speed, uint8 duplex)
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
	if(!fec_mii_write(fec_ch, phy_addr, PHY_BMCR, PHY_BMCR_RESET))
		return 0;
	/* Wait for the PHY to reset */
	for(timeout = 0; timeout < FEC_MII_TIMEOUT; timeout++)
	{
		fec_mii_read(fec_ch, phy_addr, PHY_BMCR, &settings);
		if(!(settings & PHY_BMCR_RESET))
			break;
	}
	if(timeout >= FEC_MII_TIMEOUT)
		return 0;
#ifdef DEBUG
	conws_debug("PHY reset OK\r\n");
#endif
	for(timeout = 0; timeout < FEC_MII_TIMEOUT; timeout++)
	{
		settings = 0;
		fec_mii_read(fec_ch, phy_addr, PHY_BMSR, &settings);
		if((settings & AUTONEGLINK) == AUTONEGLINK)
			break;
	}
	if(timeout >= FEC_MII_TIMEOUT)
	{
#ifdef DEBUG
		conws_debug("PHY Set the default mode\r\n");
#endif
		/* to do */
		return 0;
	}
#ifdef DEBUG
	conws_debug("PHY auto-negociation complete\r\n");
#endif
	return 1;
}
/********************************************************************/

#endif /* LWIP */
#endif /* NETWORK */
