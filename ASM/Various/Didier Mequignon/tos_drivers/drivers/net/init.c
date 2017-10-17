/*
 * File:        init.c
 * Purpose:     Board specific routines for M5485EVB and the M5475EVB
 *
 * Notes:
 *
 */

#include <osbind.h>
#include "config.h"
#include "ct60.h"
#include "net.h"
#include "get.h"
#include "fec.h"
#include "dma_utils.h"
#include "../mcdapi/MCD_dma.h"

#define OFFSET_INT_CF68KLIB     (64)
#define V_FEC0                  (64+39+OFFSET_INT_CF68KLIB)
#define V_FEC1                  (64+38+OFFSET_INT_CF68KLIB)
#define V_DMA                   (64+48+OFFSET_INT_CF68KLIB)

extern void fec0_int(void);
extern void fec1_int(void);
extern void ltoa(char *buf, long n, unsigned long base);

#ifdef NETWORK
#ifndef LWIP

/* Define one network interface */

IP_INFO     ip_info;
ARP_INFO    arp_info;

static void fec0_interrupt(void)
{
	asm volatile (
		"_fec0_int:\n\t"
		" lea -24(SP),SP\n\t"
		" movem.l D0-D2/A0-A2,(SP)\n\t"
		" clr.l -(SP)\n\t"
		" jsr _fec_irq_handler\n\t"
		" addq.l #4,SP\n\t"
		" movem.l (SP),D0-D2/A0-A2\n\t"
		" lea 24(SP),SP\n\t"
		" rte\n\t" );
}

static void fec1_interrupt(void)
{
		"_fec1_int:\n\t"
		" lea -24(SP),SP\n\t"
		" movem.l D0-D2/A0-A2,(SP)\n\t"
		" pea 1\n\t"
		" jsr _fec_irq_handler\n\t"
		" addq.l #4,SP\n\t"
		" movem.l (SP),D0-D2/A0-A2\n\t"
		" lea 24(SP),SP\n\t"
		" rte\n\t" );
}

#ifdef TEST_NETWORK

/********************************************************************/
/*
 * Physical (MAC) Addresses
 */
ETH_ADDR src = {0x00,0xCF,0x54,0x85,0xCF,0x00};
ETH_ADDR dst = {0x00,0xCF,0x54,0x85,0xCF,0x01};
ETH_ADDR bcst = {0xFF,0xFF,0xFF,0xFF,0xFF,0xFF};

/*
 * The packet to send - the Tx buffer must be 32-bit aligned, so
 * it is declared as a uin32 here so the linker will automatically
 * align it on that boundary.
 */
uint32 packet[1520/sizeof(uint32)];

/*
 * Get access to the log kept by fec.c
 */
extern FEC_EVENT_LOG fec_log[];

/********************************************************************/
/*
 * Transmit Test on an individual FEC channel
 *
 * Parameters:
 *  ch      FEC channel
 *  mode    Transceiver mode (MII, 7-Wire or internal loopback)
 *  speed   Maximum operating speed (MII only)
 *  duplex  Full or Half-duplex (MII only)
 *
 * Return Value:
 *  0 if tests are successful
 *  1 otherwise
 */
int tx_test(uint8 ch, uint8 mode, uint8 speed, uint8 duplex)
{
    int i, status;
    NBUF *pNbuf;

    /*
     * Display our test parameters
     */
    Cconws("\r\n\r\nFEC");
    Cconout(ch+'0');
    Cconws(" Tx Test\r\nMode:  ");

    if (mode == FEC_MODE_LOOPBACK)
        Cconws("Internal Loopback");
    else if (mode == FEC_MODE_MII)
        Cconws("MII");
    else
        Cconws("7-Wire");
    Cconws("\r\n");

    if (mode == FEC_MODE_MII)
    {
        Cconws("Speed:  ");
        if (speed == FEC_MII_10BASE_T)
            Cconws("10");
        else
            Cconws("100");
        Cconws("\r\nDuplex: ");

        if (duplex == FEC_MII_HALF_DUPLEX)
            Cconws("HALF");
        else
            Cconws("FULL");
        Cconws("\r\n");
    }

	  /* Build the Tx Packet */
    for (i=0; i<sizeof(packet)/sizeof(uint32); ++i)
        packet[i] = (uint32)((uint8)i<<24 | (uint8)i<<16 | (uint8)i<<8 | (uint8)i);

    /* Initialize the Ethernet */
    status = fec_eth_start(ch, mode, speed, duplex, src, 
                           SYSTEM_CLOCK, 
                           FEC_PHY(ch), 
                           FEC_INTC_LVL,
                           FEC_INTC_PRI,
                           FECTX_DMA_PRI,
                           FECRX_DMA_PRI);
    if (!status)
    {
        /* 
         * Couldn't communicate with the PHY or the PHY
         * couldn't establish a link with a link partner
         */
        Cconws("Failed to start the Ethernet channel\r\n");
        Cconws("Test failed\r\n");
        Cnecin();
        return 1;
    }

    /* 
     * Send packets from size ETH_MIN_DATA to ETH_MAX_DATA
     */
    i = ETH_MIN_DATA;
    while (1)
    {
        pNbuf = nbuf_alloc();
        if (pNbuf == NULL)
        {
            Cconws("nbuf_alloc() failed\r\n");
            nbuf_debug_dump();
            while(1);
        }
        pNbuf->length = i;
        memcpy(pNbuf->data,(uint8 *)packet,i);
        if (!fec_send(ch,dst,src,ETH_FRM_TEST,pNbuf))
        {
            nbuf_free(pNbuf);
            break;
        }
        if (++i > ETH_MAX_DATA)
            break;
    }

    /* Wait a bit to let the FEC finish up */
    for (i = 0; i < 1000000; asm volatile (" nop\n\t"); i++);

    /* Stop the Ethernet */
    fec_eth_stop(ch);

    /*
     * Dump the FEC log
     */
    fec_log_dump(ch);
	
	if ((fec_log[ch].dtxf != (ETH_MAX_DATA - ETH_MIN_DATA + 1)) || 
        (fec_log[ch].errors != 0)                               ||
        ((mode == FEC_MODE_LOOPBACK) && (fec_log[ch].dtxf != fec_log[ch].drxf)))
    {
        Cconws("Test failed\r\n");
        Cnecin();
        return 1;
    }
    else
    {
        Cconws("Test passed\r\n");
        return 0;
    }
}

#endif

int net_init(uint8 ch)
{
	IP_ADDR client;
	IP_ADDR gateway;
	IP_ADDR netmask;
	board_get_client(client);
	board_get_gateway(gateway);
	board_get_netmask(netmask);
	arp_init(&arp_info);
	nif_bind_protocol(&nif[ch],ETH_FRM_ARP,arp_handler,(void *)&arp_info);
	ip_init(&ip_info,client,gateway,netmask);
	nif_bind_protocol(&nif[ch],ETH_FRM_IP,ip_handler,(void *)&ip_info);
	udp_init();
	return TRUE;
}

int init_network(void)
{
	int status;
	unsigned long cacr;
	uint8 mac[6];
	if(fec0_interrupt);
	if(fec1_interrupt);
	Setexc(V_FEC0, fec0_int);
	Setexc(V_FEC1, fec1_int);
	/* disable the caches */
	cacr=ct60_cache(-1);
	ct60_cache(0);
#ifdef TEST_NETWORK
	tx_test(0,FEC_MODE_LOOPBACK,0,0);
	tx_test(1,FEC_MODE_LOOPBACK,0,0);
	tx_test(0,FEC_MODE_MII,FEC_MII_100BASE_TX,FEC_MII_FULL_DUPLEX);
	tx_test(0,FEC_MODE_MII,FEC_MII_100BASE_TX,FEC_MII_HALF_DUPLEX);
	tx_test(0,FEC_MODE_MII,FEC_MII_10BASE_T,FEC_MII_FULL_DUPLEX);
	tx_test(0,FEC_MODE_MII,FEC_MII_10BASE_T,FEC_MII_HALF_DUPLEX);
	tx_test(1,FEC_MODE_MII,FEC_MII_100BASE_TX,FEC_MII_FULL_DUPLEX);
	tx_test(1,FEC_MODE_MII,FEC_MII_100BASE_TX,FEC_MII_HALF_DUPLEX);
	tx_test(1,FEC_MODE_MII,FEC_MII_10BASE_T,FEC_MII_FULL_DUPLEX);
	tx_test(1,FEC_MODE_MII,FEC_MII_10BASE_T,FEC_MII_HALF_DUPLEX);
#endif
	/* Get user programmed MAC address */
	board_get_ethaddr(mac);
	/* Initialize the network interface structure */
	nif_init(&nif[ETHERNET_PORT]);
	nif[ETHERNET_PORT].mtu = ETH_MTU;
	nif[ETHERNET_PORT].send = (ETHERNET_PORT == 0) ? fec0_send : fec1_send;
	/* Initialize the Ethernet port */
	status = fec_eth_start(ETHERNET_PORT, /* Which FEC to use */
	                        FEC_MODE_MII, /* Use MII mode */
	                  FEC_MII_100BASE_TX, /* Allow 10 and 100Mbps */
	                 FEC_MII_FULL_DUPLEX, /* Allow Full and Half Duplex */
	                                 mac,
	                        SYSTEM_CLOCK, 
	              FEC_PHY(ETHERNET_PORT), 
	                        FEC_INTC_LVL,
	                        FEC_INTC_PRI,
	                       FECTX_DMA_PRI,
	                      FECRX_DMA_PRI);
	/* enable the caches */
	if(cacr & 0x80008000)
		ct60_cache(1);
	if(!status)
	{
		/* Couldn't communicate with the PHY or the PHY
		   couldn't establish a link with a link partner */
			Cconws("Failed to start the Ethernet channel\r\n");
			return FALSE;
	}
	/* Copy the Ethernet address to the NIF structure */
	memcpy(nif[ETHERNET_PORT].hwa, mac, 6);
#ifdef DEBUG_PRINT
	{
		char buf[10];
		int i;
		Cconws("Ethernet Address is ");
		for (i = 0; i < 6; i++)
		{
			ltoa(buf, nif[ETHERNET_PORT].hwa[i], 16);
			Cconws(buf);
			if(i < 5)
				Cconout(':');
		}
		Cconws("\r\n"); 
	}
#endif
  /* Initialize network stack */
  net_init(ETHERNET_PORT);
	return TRUE;
}

void end_network(void)
{
	/* Disable the Ethernet port */
	fec_eth_stop(ETHERNET_PORT);
}

#endif /* LWIP */
#endif /* NETWORK */
