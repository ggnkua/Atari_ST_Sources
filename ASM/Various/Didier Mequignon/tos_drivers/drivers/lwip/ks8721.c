/*
 * File:        ks8721.c
 * Purpose:     Driver for the Micrel KS8721 10/100 Ethernet PHY
 *
 * Notes:       
 */

#include "config.h"
#include "mcf5xxx.h"
#include "nbuf.h"
#include "fec.h"
#include "ks8721.h"

#ifdef NETWORK
#ifdef LWIP

#undef DEBUG

#ifdef DEBUG
extern void conws_debug(char *buf);
#endif

/********************************************************************/
/* Initialize the KS8721 PHY
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
#if 0
int ks8721_init(uint8 fec_ch, uint8 phy_addr, uint8 speed, uint8 duplex)
{
    int timeout;
    uint16 settings;
    /* Disable Auto-Negotiation */
    if (fec_mii_write(fec_ch, phy_addr, KS8721_CTRL, 0))
        return 0;
    /* Reset the PHY */
    if (fec_mii_write(fec_ch, phy_addr, KS8721_CTRL, KS8721_CTRL_RESET))
        return 0;
    /* 
     * Read back the contents of the CTRL register and verify
     * that RESET is not set - this is a sanity check to ensure
     * that we are talking to the PHY correctly. RESET should
     * always be cleared.
     */
    if (fec_mii_read(fec_ch, phy_addr, KS8721_CTRL, &settings))
        return 0;
    if (settings & KS8721_CTRL_RESET)
        return 0;
    if (speed == FEC_MII_10BASE_T)
    {
        settings = (uint16)((duplex == FEC_MII_FULL_DUPLEX) 
            ? (KS8721_AN_ADV_10BT_FDX | KS8721_AN_ADV_10BT) 
            : KS8721_AN_ADV_10BT);
    }
    else /* (speed == FEC_MII_100BASE_TX) */
    {
        settings = (uint16)((duplex == FEC_MII_FULL_DUPLEX)  
            ? (KS8721_AN_ADV_100BTX_FDX | KS8721_AN_ADV_100BTX
             | KS8721_AN_ADV_10BT_FDX   | KS8721_AN_ADV_10BT) 
            : (KS8721_AN_ADV_100BTX | KS8721_AN_ADV_10BT));
    }
    /* Set the Auto-Negotiation Advertisement Register */
    if (fec_mii_write(fec_ch, phy_addr, KS8721_AN_ADV, settings))
        return 0;
    /* Enable Auto-Negotiation */
    if (fec_mii_write(fec_ch, phy_addr, KS8721_CTRL, (KS8721_CTRL_ANE
                                                | KS8721_CTRL_RESTART_AN)))
        return 0;
    for (timeout = 0; timeout < FEC_MII_TIMEOUT; ++timeout)
    {
        /* Read PHY status register */
        if (fec_mii_read(fec_ch, phy_addr, KS8721_STAT, &settings))
            return 0;
        if (settings & KS8721_STAT_AN_COMPLETE)
            break;
    }
    if (timeout == FEC_MII_TIMEOUT)
        return 0;
    /* 
     * Read 100BaseTX PHY Control Register 
     */
    if (fec_mii_read(fec_ch, phy_addr, KS8721_100TX_CTRL, &settings))
        return 0;
    /*
     * Set the proper duplex in the FEC now that we have auto-negotiated
     */
    if (((settings & KS8721_100TX_CTRL_MODE_MASK) == KS8721_100TX_CTRL_MODE_10HDX) ||
        ((settings & KS8721_100TX_CTRL_MODE_MASK) == KS8721_100TX_CTRL_MODE_100HDX))
        fec_duplex(fec_ch, FEC_MII_HALF_DUPLEX);
    else
        fec_duplex(fec_ch, FEC_MII_FULL_DUPLEX);
    #ifdef DEBUG
        conws_debug("\nPHY Mode: ");
        switch (settings & KS8721_100TX_CTRL_MODE_MASK)
        {
        case KS8721_100TX_CTRL_MODE_AN : 
            conws_debug("Auto-negotiating\n");
            break;
        case KS8721_100TX_CTRL_MODE_10HDX :    
            conws_debug("10Mbps Half-duplex\n");
            break;
        case KS8721_100TX_CTRL_MODE_100HDX : 
            conws_debug("100Mbps Half-duplex\n");
            break;
        case KS8721_100TX_CTRL_MODE_DEFAULT : 
            conws_debug("Default\n");
            break;
        case KS8721_100TX_CTRL_MODE_10FDX : 
            conws_debug("10Mbps Full-duplex\n");
            break;
        case KS8721_100TX_CTRL_MODE_100FDX : 
            conws_debug("100Mbps Full-duplex\n");
            break;
        case KS8721_100TX_CTRL_MODE_ISOLATE : 
            conws_debug("Isolation\n");
            break;
        default:
            conws_debug("Unknown\n");
        }
    #endif
    return 1;
}
#else
int ks8721_init(uint8 fec_ch, uint8 phy_addr, uint8 speed, uint8 duplex)
{
	uint16 data;
	int fduplex, time, flag = 0;
	if(speed); /* to do */
	if(duplex); /* to do */

  // Initialize the MII interface
  fec_mii_init(fec_ch, SYSTEM_CLOCK);
	// Reset
	if(!fec_mii_write(fec_ch, phy_addr, KS8721_CTRL, KS8721_CTRL_RESET))
		return 0;
	// Read back    
	if(!fec_mii_read(fec_ch, phy_addr, KS8721_CTRL, &data))
		return 0;
	// If reset bit is set, return
	if(data & KS8721_CTRL_RESET)
		return 0;
	// Disable  the auto-negotiation 
	if(!fec_mii_write(fec_ch, phy_addr, KS8721_CTRL, 0))
		return 0;
	// Set the auto-negotiation advertisement register 
	if(!fec_mii_write(fec_ch, phy_addr, KS8721_AN_ADV, KS8721_ANADV_ADV_ALL))
		return 0;
	// Enable the auto-negotiation
	if(!fec_mii_write(fec_ch, phy_addr, KS8721_CTRL, KS8721_CTRL_AN_ENABLE))
		return 0;
	// Wait for the auto-negotiation completion
  for(time = 0; time < FEC_MII_TIMEOUT; ++time)
  {
		// Read PHY status register
		if(!fec_mii_read(fec_ch, phy_addr, KS8721_STAT, &data))
			return 0;
    if(data & KS8721_STAT_ANCOMPLETE)
    {
      flag = 1;
      break;
    }
	}
	if(flag)
	{
		// Set the duplex flag     
		if(data & KS8721_STAT_FDUPLEX)
			fduplex = 1;
		else
			fduplex = 0;
		return 1;
	}
	// Set the default mode (Full duplex, 100 Mbps) 
	if(!fec_mii_write(fec_ch, phy_addr, KS8721_CTRL, KS8721_CTRL_DEFAULT_MODE))
		return 0;
	fduplex = KS8721_CTRL_DEFAULT_MODE & 0x100;
  return 1;
}
#endif

#endif /* LWIP */
#endif /* NETWORK */
