/*
 * File:    fec.c
 * Purpose: Driver for the Fast Ethernet Controller (FEC)
 *
 * Notes:
 */

#include "config.h"

#ifdef NETWORK
#ifndef LWIP

#include <osbind.h>
#include "net.h"
#include "fec.h"
#include "fecbd.h"
#include "net_timer.h"
#include "../dma_utils/dma_utils.h"
#ifdef MCF5445X
#include "mcf5445x.h"
#error MCF5445X not supported, change settings inside config.h to LWIP
#else
#include "../mcdapi/MCD_dma.h"
#include "mcf548x.h"
#endif

extern void ltoa(char *buf, long n, unsigned long base);
extern int phy_init(uint8 fec_ch, uint8 phy_addr, uint8 speed, uint8 duplex);
extern NIF nif[];

/********************************************************************/

FEC_EVENT_LOG fec_log[2];

/********************************************************************/
/*
 * Write a value to a PHY's MII register.
 *
 * Parameters:
 *  ch          FEC channel
 *  phy_addr    Address of the PHY.
 *  reg_addr    Address of the register in the PHY.
 *  data        Data to be written to the PHY register.
 *
 * Return Values:
 *  0 on failure
 *  1 on success.
 *
 * Please refer to your PHY manual for registers and their meanings.
 * mii_write() polls for the FEC's MII interrupt event (which should
 * be masked from the interrupt handler) and clears it. If after a
 * suitable amount of time the event isn't triggered, a value of 0
 * is returned.
 */
int
fec_mii_write(uint8 ch, uint8 phy_addr, uint8 reg_addr, uint16 data)
{
    int timeout;
    uint32 eimr;

//    ASSERT(ch == 0 || ch == 1);

    /*
     * Clear the MII interrupt bit
     */
    MCF_FEC_EIR(ch) = MCF_FEC_EIR_MII;

    /*
     * Write to the MII Management Frame Register to kick-off
     * the MII write
     */
    MCF_FEC_MMFR(ch) = 0
        | MCF_FEC_MMFR_ST_01
        | MCF_FEC_MMFR_OP_WRITE
        | MCF_FEC_MMFR_PA(phy_addr)
        | MCF_FEC_MMFR_RA(reg_addr)
        | MCF_FEC_MMFR_TA_10
        | MCF_FEC_MMFR_DATA(data);

    /*
     * Mask the MII interrupt
     */
    eimr = MCF_FEC_EIMR(ch);
    MCF_FEC_EIMR(ch) &= ~MCF_FEC_EIMR_MII;

    /*
     * Poll for the MII interrupt (interrupt should be masked)
     */
    for (timeout = 0; timeout < FEC_MII_TIMEOUT; timeout++)
    {
        if (MCF_FEC_EIR(ch) & MCF_FEC_EIR_MII)
            break;
    }
    if(timeout == FEC_MII_TIMEOUT)
        return 0;

    /*
     * Clear the MII interrupt bit
     */
    MCF_FEC_EIR(ch) = MCF_FEC_EIR_MII;

    /*
     * Restore the EIMR
     */
    MCF_FEC_EIMR(ch) = eimr;

    return 1;
}
/********************************************************************/
/*
 * Read a value from a PHY's MII register.
 *
 * Parameters:
 *  ch          FEC channel
 *  phy_addr    Address of the PHY.
 *  reg_addr    Address of the register in the PHY.
 *  data        Pointer to storage for the Data to be read
 *              from the PHY register (passed by reference)
 *
 * Return Values:
 *  0 on failure
 *  1 on success.
 *
 * Please refer to your PHY manual for registers and their meanings.
 * mii_read() polls for the FEC's MII interrupt event (which should
 * be masked from the interrupt handler) and clears it. If after a
 * suitable amount of time the event isn't triggered, a value of 0
 * is returned.
 */
int
fec_mii_read(uint8 ch, uint8 phy_addr, uint8 reg_addr, uint16 *data)
{
    int timeout;

//    ASSERT(ch == 0 || ch == 1);

    /*
     * Clear the MII interrupt bit
     */
    MCF_FEC_EIR(ch) = MCF_FEC_EIR_MII;

    /*
     * Write to the MII Management Frame Register to kick-off
     * the MII read
     */
    MCF_FEC_MMFR(ch) = 0
        | MCF_FEC_MMFR_ST_01
        | MCF_FEC_MMFR_OP_READ
        | MCF_FEC_MMFR_PA(phy_addr)
        | MCF_FEC_MMFR_RA(reg_addr)
        | MCF_FEC_MMFR_TA_10;

    /*
     * Poll for the MII interrupt (interrupt should be masked)
     */
    for (timeout = 0; timeout < FEC_MII_TIMEOUT; timeout++)
    {
        if (MCF_FEC_EIR(ch) & MCF_FEC_EIR_MII)
            break;
    }

    if(timeout == FEC_MII_TIMEOUT)
        return 0;

    /*
     * Clear the MII interrupt bit
     */
    MCF_FEC_EIR(ch) = MCF_FEC_EIR_MII;

    *data = (uint16)(MCF_FEC_MMFR(ch) & 0x0000FFFF);

    return 1;
}
/********************************************************************/
/*
 * Initialize the MII interface controller
 *
 * Parameters:
 *  ch      FEC channel
 *  sys_clk System Clock Frequency (in MHz)
 */
void
fec_mii_init(uint8 ch, uint32 sys_clk)
{
//    ASSERT(ch == 0 || ch == 1);

    /*
     * Initialize the MII clock (EMDC) frequency
     *
     * Desired MII clock is 2.5MHz
     * MII Speed Setting = System_Clock / (2.5MHz * 2)
     * (plus 1 to make sure we round up)
     */
    MCF_FEC_MSCR(ch) = MCF_FEC_MSCR_MII_SPEED((sys_clk/5)+1);

    /*
     * Make sure the external interface signals are enabled
     */
    if (ch == 1)
        MCF_GPIO_PAR_FECI2CIRQ |= 0
            | MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MDC_EMDC
            | MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MDIO_EMDIO;
    else
        MCF_GPIO_PAR_FECI2CIRQ |= 0
            | MCF_GPIO_PAR_FECI2CIRQ_PAR_E0MDC
            | MCF_GPIO_PAR_FECI2CIRQ_PAR_E0MDIO;
}
/********************************************************************/
/* Initialize the MIB counters
 *
 * Parameters:
 *  ch      FEC channel
 */
void
fec_mib_init(uint8 ch)
{
//    ASSERT(ch == 0 || ch == 1);
//To do
}
/********************************************************************/
/* Display the MIB counters
 *
 * Parameters:
 *  ch      FEC channel
 */
void
fec_mib_dump(uint8 ch)
{
//    ASSERT(ch == 0 || ch == 1);
//To do
}
/********************************************************************/
/* Initialize the FEC log
 *
 * Parameters:
 *  ch      FEC channel
 */
void
fec_log_init(uint8 ch)
{
   int i;
   char *ptr = (char *)&fec_log[ch];
//    ASSERT(ch == 0 || ch == 1);
    for(i=0; i<sizeof(FEC_EVENT_LOG); *ptr++ = 0, i++);
}
/********************************************************************/
/* Display the FEC log
 *
 * Parameters:
 *  ch      FEC channel
 */
void
fec_log_dump(uint8 ch)
{
#if 0 // #ifdef DEBUG_PRINT
    char buf[10];
//    ASSERT(ch == 0 || ch == 1);
    if(ch == 0) 
        Cconws("\r\n   FEC0");
    else
        Cconws("\r\n   FEC1");
    Cconws(" Log\r\n---------------\r\nTotal: ");
    ltoa(buf, fec_log[ch].errors, 10);
    Cconws(buf);
    Cconws("\r\nhberr: ");
    ltoa(buf, fec_log[ch].hberr, 10);
    Cconws(buf);
    Cconws("\r\nbabr:  ");
    ltoa(buf, fec_log[ch].babr, 10);
    Cconws(buf);
    Cconws("\r\nbabt:  ");
    ltoa(buf, fec_log[ch].babt, 10);
    Cconws(buf);
    Cconws("\r\ngra:   ");
    ltoa(buf, fec_log[ch].gra, 10);
    Cconws(buf);
    Cconws("\r\ntxf:   ");
    ltoa(buf, fec_log[ch].txf, 10);
    Cconws(buf);
    Cconws("\r\nmii:   ");
    ltoa(buf, fec_log[ch].mii, 10);
    Cconws(buf); 
    Cconws("\r\nlc:    ");
    ltoa(buf, fec_log[ch].lc, 10);
    Cconws(buf); 
    Cconws("\r\nrl:    ");
    ltoa(buf, fec_log[ch].rl, 10);
    Cconws(buf); 
    Cconws("\r\nxfun:  ");
    ltoa(buf, fec_log[ch].xfun, 10);
    Cconws(buf); 
    Cconws("\r\nxferr: ");
    ltoa(buf, fec_log[ch].xferr, 10);
    Cconws(buf); 
    Cconws("\r\nrferr: ");
    ltoa(buf, fec_log[ch].rferr, 10);
    Cconws(buf); 
    Cconws("\r\ndtxf:  ");
    ltoa(buf, fec_log[ch].dtxf, 10);
    Cconws(buf); 
    Cconws("\r\ndrxf:  ");
    ltoa(buf, fec_log[ch].drxf, 10);
    Cconws(buf); 
    Cconws("\r\n\r\nRFSW:\r\ninv:   ");
    ltoa(buf, fec_log[ch].rfsw_inv, 10);
    Cconws(buf); 
    Cconws("\r\nm:     ");
    ltoa(buf, fec_log[ch].rfsw_m, 10);
    Cconws(buf); 
    Cconws("\r\nbc:    ");
    ltoa(buf, fec_log[ch].rfsw_bc, 10);
    Cconws(buf); 
    Cconws("\r\nmc:    ");
    ltoa(buf, fec_log[ch].rfsw_mc, 10);
    Cconws(buf); 
    Cconws("\r\nlg:    ");
    ltoa(buf, fec_log[ch].rfsw_lg, 10);
    Cconws(buf); 
    Cconws("\r\nno:    ");
    ltoa(buf, fec_log[ch].rfsw_no, 10);
    Cconws(buf); 
    Cconws("\r\ncr:    ");
    ltoa(buf, fec_log[ch].rfsw_cr, 10);
    Cconws(buf); 
    Cconws("\r\nov:    ");
    ltoa(buf, fec_log[ch].rfsw_ov, 10);
    Cconws(buf); 
    Cconws("\r\ntr:    ");
    ltoa(buf, fec_log[ch].rfsw_tr, 10);
    Cconws(buf); 
    Cconws("\r\n---------------\r\n\r\n");
#endif
}
/********************************************************************/
/*
 * Display some of the registers for debugging
 *
 * Parameters:
 *  ch      FEC channel
 */
void
fec_reg_dump(uint8 ch)
{
#if 0 // #ifdef DEBUG_PRINT
    char buf[10];
    if(ch == 0)
        Cconws("\r\n------------- FEC0");
    else
        Cconws("\r\n------------- FEC1");
    Cconws(" -------------");
    Cconws("\r\nEIR      0x");
    ltoa(buf, MCF_FEC_EIR(ch), 16);
    Cconws(buf); 
    Cconws("\r\nEIMR     0x");
    ltoa(buf, MCF_FEC_EIMR(ch), 16);
    Cconws(buf); 
    Cconws("\r\nECR      0x");
    ltoa(buf, MCF_FEC_ECR(ch), 16);
    Cconws(buf); 
    Cconws("\r\nRCR      0x");
    ltoa(buf, MCF_FEC_RCR(ch), 16);
    Cconws(buf); 
    Cconws("\r\nR_HASH   0x");
    ltoa(buf, MCF_FEC_R_HASH(ch), 16);
    Cconws(buf); 
    Cconws("\r\nTCR      0x");
    ltoa(buf, MCF_FEC_TCR(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECTFWR  0x");
    ltoa(buf, MCF_FEC_FECTFWR(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECRFSR  0x");
    ltoa(buf, MCF_FEC_FECRFSR(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECRFCR  0x");
    ltoa(buf, MCF_FEC_FECRFCR(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECRLRFP 0x");
    ltoa(buf, MCF_FEC_FECRLRFP(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECRLWFP 0x");
    ltoa(buf, MCF_FEC_FECRLWFP(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECRFAR  0x");
    ltoa(buf, MCF_FEC_FECRFAR(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECRFRP  0x");
    ltoa(buf, MCF_FEC_FECRFRP(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECRFWP  0x");
    ltoa(buf, MCF_FEC_FECRFWP(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECTFSR  0x");
    ltoa(buf, MCF_FEC_FECTFSR(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECTFCR  0x");
    ltoa(buf, MCF_FEC_FECTFCR(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECTLRFP 0x");
    ltoa(buf, MCF_FEC_FECTLRFP(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECTLWFP 0x");
    ltoa(buf, MCF_FEC_FECTLWFP(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECTFAR  0x");
    ltoa(buf, MCF_FEC_FECTFAR(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECTFRP  0x");
    ltoa(buf, MCF_FEC_FECTFRP(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFECTFWP  0x");
    ltoa(buf, MCF_FEC_FECTFWP(ch), 16);
    Cconws(buf); 
    Cconws("\r\nFRST     0x");
    ltoa(buf, MCF_FEC_FRST(ch), 16);
    Cconws(buf); 
    Cconws("\r\n--------------------------------\r\n");
#endif
}
/********************************************************************/
/*
 * Set the duplex on the selected FEC controller
 *
 * Parameters:
 *  ch      FEC channel
 *  duplex  FEC_MII_FULL_DUPLEX or FEC_MII_HALF_DUPLEX
 */
void
fec_duplex (uint8 ch, uint8 duplex)
{
//    ASSERT(ch == 0 || ch == 1);

    switch (duplex)
    {
        case FEC_MII_HALF_DUPLEX:
            MCF_FEC_RCR(ch) |= MCF_FEC_RCR_DRT;
            MCF_FEC_TCR(ch) &= (uint32)~MCF_FEC_TCR_FDEN;
            break;
        case FEC_MII_FULL_DUPLEX:
        default:
            MCF_FEC_RCR(ch) &= (uint32)~MCF_FEC_RCR_DRT;
            MCF_FEC_TCR(ch) |= MCF_FEC_TCR_FDEN;
            break;
    }
}
/********************************************************************/
/*
 * Generate the hash table settings for the given address
 *
 * Parameters:
 *  addr    48-bit (6 byte) Address to generate the hash for
 *
 * Return Value:
 *  The 6 most significant bits of the 32-bit CRC result
 */
uint8
fec_hash_address(const uint8 *addr)
{
    uint32 crc;
    uint8 byte;
    int i, j;

    crc = 0xFFFFFFFF;
    for(i=0; i<6; ++i)
    {
        byte = addr[i];
        for(j=0; j<8; ++j)
        {
            if((byte & 0x01)^(crc & 0x01))
            {
                crc >>= 1;
                crc = crc ^ 0xEDB88320;
            }
            else
                crc >>= 1;
            byte >>= 1;
        }
    }
    return (uint8)(crc >> 26);
}
/********************************************************************/
/*
 * Set the Physical (Hardware) Address and the Individual Address
 * Hash in the selected FEC
 *
 * Parameters:
 *  ch  FEC channel
 *  pa  Physical (Hardware) Address for the selected FEC
 */
void
fec_set_address (uint8 ch, const uint8 *pa)
{
    uint8 crc;

//    ASSERT(ch == 0 || ch == 1);

    /*
     * Set the Physical Address
     */
    MCF_FEC_PALR(ch) = (uint32)((pa[0]<<24) | (pa[1]<<16) | (pa[2]<<8) | pa[3]);
    MCF_FEC_PAUR(ch) = (uint32)((pa[4]<<24) | (pa[5]<<16));

    /*
     * Calculate and set the hash for given Physical Address
     * in the  Individual Address Hash registers
     */
    crc = fec_hash_address(pa);
    if(crc >= 32)
        MCF_FEC_IAUR(ch) |= (uint32)(1 << (crc - 32));
    else
        MCF_FEC_IALR(ch) |= (uint32)(1 << crc);
}
/********************************************************************/
/*
 * Reset the selected FEC controller
 *
 * Parameters:
 *  ch      FEC channel
 */
void
fec_reset (uint8 ch)
{
    int i;

//    ASSERT(ch == 0 || ch == 1);

    /* Clear any events in the FIFO status registers */
    MCF_FEC_FECRFSR(ch) = (0
        | MCF_FEC_FECRFSR_OF
        | MCF_FEC_FECRFSR_UF
        | MCF_FEC_FECRFSR_RXW
        | MCF_FEC_FECRFSR_FAE
        | MCF_FEC_FECRFSR_IP);
    MCF_FEC_FECTFSR(ch) = (0
        | MCF_FEC_FECRFSR_OF
        | MCF_FEC_FECRFSR_UF
        | MCF_FEC_FECRFSR_RXW
        | MCF_FEC_FECRFSR_FAE
        | MCF_FEC_FECRFSR_IP);

    /* Reset the FIFOs */
    MCF_FEC_FRST(ch) |= MCF_FEC_FRST_SW_RST;
    MCF_FEC_FRST(ch) &= ~MCF_FEC_FRST_SW_RST;

    /* Set the Reset bit and clear the Enable bit */
    MCF_FEC_ECR(ch) = MCF_FEC_ECR_RESET;

    /* Wait at least 8 clock cycles */
    for (i = 0; i < 10; i++)
    {
  	    asm volatile (" nop\n\t"); 
    }
}
/********************************************************************/
/*
 * Initialize the selected FEC
 *
 * Parameters:
 *  ch      FEC channel
 *  mode    External interface mode (MII, 7-wire, or internal loopback)
 *  pa      Physical (Hardware) Address for the selected FEC
 */
void
fec_init (uint8 ch, uint8 mode, uint8 duplex, const uint8 *pa)
{
//    ASSERT(ch == 0 || ch == 1);

    /*
     * Enable all the external interface signals
     */
    if (mode == FEC_MODE_7WIRE)
    {
        if (ch == 1)
            MCF_GPIO_PAR_FECI2CIRQ |= MCF_GPIO_PAR_FECI2CIRQ_PAR_E17;
        else
            MCF_GPIO_PAR_FECI2CIRQ |= MCF_GPIO_PAR_FECI2CIRQ_PAR_E07;
    }
    else if (mode == FEC_MODE_MII)
    {
        if (ch == 1)
            MCF_GPIO_PAR_FECI2CIRQ |= 0
                | MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MDC_EMDC
                | MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MDIO_EMDIO
                | MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MII
                | MCF_GPIO_PAR_FECI2CIRQ_PAR_E17;
        else
            MCF_GPIO_PAR_FECI2CIRQ |= 0
                | MCF_GPIO_PAR_FECI2CIRQ_PAR_E0MDC
                | MCF_GPIO_PAR_FECI2CIRQ_PAR_E0MDIO
                | MCF_GPIO_PAR_FECI2CIRQ_PAR_E0MII
                | MCF_GPIO_PAR_FECI2CIRQ_PAR_E07;
    }

    /*
     * Clear the Individual and Group Address Hash registers
     */
    MCF_FEC_IALR(ch) = 0;
    MCF_FEC_IAUR(ch) = 0;
    MCF_FEC_GALR(ch) = 0;
    MCF_FEC_GAUR(ch) = 0;

    /*
     * Set the Physical Address for the selected FEC
     */
    fec_set_address(ch, pa);

    /*
     * Mask all FEC interrupts
     */
    MCF_FEC_EIMR(ch) = MCF_FEC_EIMR_MASK_ALL;

    /*
     * Clear all FEC interrupt events
     */
    MCF_FEC_EIR(ch) = MCF_FEC_EIR_CLEAR_ALL;

    /*
     * Initialize the Receive Control Register
     */
    MCF_FEC_RCR(ch) = 0
        | MCF_FEC_RCR_MAX_FL(ETH_MAX_FRM)
    #ifdef FEC_PROMISCUOUS
        | MCF_FEC_RCR_PROM
    #endif
        | MCF_FEC_RCR_FCE;

    if (mode == FEC_MODE_MII)
        MCF_FEC_RCR(ch) |= MCF_FEC_RCR_MII_MODE;

    else if (mode == FEC_MODE_LOOPBACK)
        MCF_FEC_RCR(ch) |= (MCF_FEC_RCR_LOOP | MCF_FEC_RCR_PROM);

    /*
     * Set the duplex
     */
    if (mode == FEC_MODE_LOOPBACK)
        /* Loopback mode must operate in full-duplex */
        fec_duplex(ch, FEC_MII_FULL_DUPLEX);
    else
        fec_duplex(ch, duplex);

    /*
     * Set Rx FIFO alarm and granularity
     */
    MCF_FEC_FECRFCR(ch) = 0
        | MCF_FEC_FECRFCR_FRM
        | MCF_FEC_FECRFCR_RXW_MSK
        | MCF_FEC_FECRFCR_GR(7);
    MCF_FEC_FECRFAR(ch) = MCF_FEC_FECRFAR_ALARM(768);

    /*
     * Set Tx FIFO watermark, alarm and granularity
     */
    MCF_FEC_FECTFCR(ch) = 0
        | MCF_FEC_FECTFCR_FRM
        | MCF_FEC_FECTFCR_TXW_MSK
        | MCF_FEC_FECTFCR_GR(7);
    MCF_FEC_FECTFAR(ch) = MCF_FEC_FECTFAR_ALARM(256);
    MCF_FEC_FECTFWR(ch) = MCF_FEC_FECTFWR_X_WMRK_256;

    /*
     * Enable the transmitter to append the CRC
     */
    MCF_FEC_CTCWR(ch) = 0
        | MCF_FEC_CTCWR_TFCW
        | MCF_FEC_CTCWR_CRC;
}
/********************************************************************/
/*
 * Start the FEC Rx DMA task
 *
 * Parameters:
 *  ch      FEC channel
 *  rxbd    First Rx buffer descriptor in the chain
 */
void
fec_rx_start(uint8 ch, int8 *rxbd, uint8 pri)
{
    uint32 initiator;
    int channel, result;
    void fec0_rx_frame(void);
    void fec1_rx_frame(void);

//    ASSERT(ch == 0 || ch == 1);

    /*
     * Make the initiator assignment
     */
    result = dma_set_initiator(DMA_FEC_RX(ch));
//    ASSERT(result == 0);

    /*
     * Grab the initiator number
     */
    initiator = dma_get_initiator(DMA_FEC_RX(ch));

    /*
     * Determine the DMA channel running the task for the
     * selected FEC
     */
    channel = dma_set_channel(DMA_FEC_RX(ch),
                              (ch == 0) ? fec0_rx_frame : fec1_rx_frame);
//    ASSERT(channel != -1);

    /*
     * Start the Rx DMA task
     */
    MCD_startDma(channel,
                 (s8*)rxbd,
                 0,
                 (s8*)MCF_FEC_FECRFDR_ADDR(ch),
                 0,
                 RX_BUF_SZ,
                 0,
                 initiator,
                 (int)pri,
                 0 
                   | MCD_FECRX_DMA   
                   | MCD_INTERRUPT
                   | MCD_TT_FLAGS_CW 
                   | MCD_TT_FLAGS_RL
                   | MCD_TT_FLAGS_SP
                   ,
                 0 
                   | MCD_NO_CSUM
                   | MCD_NO_BYTE_SWAP
                 );
}
/********************************************************************/
/*
 * Continue the Rx DMA task
 *
 * This routine is called after the DMA task has halted after
 * encountering an Rx buffer descriptor that wasn't marked as
 * ready. There is no harm in calling the DMA continue routine
 * if the DMA is not halted.
 *
 * Parameters:
 *  ch      FEC channel
 */
void
fec_rx_continue(uint8 ch)
{
    int channel;

//    ASSERT(ch == 0 || ch == 1);

    /*
     * Determine the DMA channel running the task for the
     * selected FEC
     */
    channel = dma_get_channel(DMA_FEC_RX(ch));
//    ASSERT(channel != -1);

    /*
     * Continue/restart the DMA task
     */
    if (channel != -1)
	    MCD_continDma(channel);
}
/********************************************************************/
/*
 * Stop all frame receptions on the selected FEC
 *
 * Parameters:
 *  ch  FEC channel
 */
void
fec_rx_stop (uint8 ch)
{
    uint32 mask;
    int channel;

//    ASSERT(ch == 0 || ch == 1);

    /* Save off the EIMR value */
    mask = MCF_FEC_EIMR(ch);

    /* Mask all interrupts */
    MCF_FEC_EIMR(ch) = 0;

    /*
     * Determine the DMA channel running the task for the
     * selected FEC
     */
    channel = dma_get_channel(DMA_FEC_RX(ch));

    /* Kill the FEC Tx DMA task */
    if (channel != -1)
        MCD_killDma(channel);

    /* 
     * Free up the FEC requestor from the software maintained 
     * initiator list 
     */
    dma_free_initiator(DMA_FEC_RX(ch));

    /* Free up the DMA channel */
    dma_free_channel(DMA_FEC_RX(ch));

    /* Restore the interrupt mask register value */
    MCF_FEC_EIMR(ch) = mask;
}
/********************************************************************/
/*
 * Receive Frame interrupt handler
 *
 * Parameters:
 *  nif     Pointer to Network Interface structure
 *  ch      FEC channel
 */
void
fec_rx_frame(uint8 ch, NIF *nif)
{
    ETH_HDR *eth_hdr;
    FECBD *pRxBD;
    NBUF *cur_nbuf, *new_nbuf;
    int keep;
    
#ifdef DEBUG_PRINT
    display_string("fec_rx_frame\r\n");
#endif

#if (__GNUC__ > 3)
    asm volatile (" .chip 68060\n\t cpusha DC\n\t .chip 5485\n\t"); /* from CF68KLIB */
#else
    asm volatile (" .chip 68060\n\t cpusha DC\n\t .chip 5200\n\t"); /* from CF68KLIB */
#endif
    
    while ((pRxBD = fecbd_rx_alloc(ch)) != NULL)
    {
        fec_log[ch].drxf++;
        keep = TRUE;

        /*
         * Check the Receive Frame Status Word for errors
         *  - The L bit should always be set
         *  - No undefined bits should be set
         *  - The upper 5 bits of the length should be cleared
         */
        if (!(pRxBD->status & RX_BD_L) || (pRxBD->status & 0x0608) 
                                       || (pRxBD->length & 0xF800))
        {
            keep = FALSE;
            fec_log[ch].rfsw_inv++;
        }
        else if (pRxBD->status & RX_BD_ERROR)
        {
            keep = FALSE;
            if (pRxBD->status & RX_BD_NO)
                fec_log[ch].rfsw_no++;
            if (pRxBD->status & RX_BD_CR)
                fec_log[ch].rfsw_cr++;
            if (pRxBD->status & RX_BD_OV)
                fec_log[ch].rfsw_ov++;
            if (pRxBD->status & RX_BD_TR)
                fec_log[ch].rfsw_tr++;
        }
        else
        {
            if (pRxBD->status & RX_BD_LG)
                fec_log[ch].rfsw_lg++;
            if (pRxBD->status & RX_BD_M)
                fec_log[ch].rfsw_m++;
            if (pRxBD->status & RX_BD_BC)
                fec_log[ch].rfsw_bc++;
            if (pRxBD->status & RX_BD_MC)
                fec_log[ch].rfsw_mc++;
        }

        if (keep)
        {
            /* 
             * Pull the network buffer off the Rx ring queue 
             */
            cur_nbuf = nbuf_remove(NBUF_RX_RING);
//            ASSERT(cur_nbuf);
//            ASSERT(cur_nbuf->data == pRxBD->data);

            /*
             * Copy the buffer descriptor information to the network buffer
             */
            cur_nbuf->length = (pRxBD->length - (ETH_HDR_LEN + ETH_CRC_LEN));
            cur_nbuf->offset = ETH_HDR_LEN;

            /*
             * Get a new buffer pointer for this buffer descriptor
             */
            new_nbuf = nbuf_alloc();
            if (new_nbuf == NULL)
            {
                #ifdef DEBUG_PRINT
                    Cconws("nbuf_alloc() failed\r\n");
                #endif
                /*
                 * Can't allocate a new network buffer, so we
                 * have to trash the received data and reuse the buffer
                 * hoping that some buffers will free up in the system
                 * and this frame will be re-transmitted by the host
                 */
                pRxBD->length = RX_BUF_SZ;
                pRxBD->status &= (RX_BD_W | RX_BD_INTERRUPT);
                pRxBD->status |= RX_BD_E;
                nbuf_add(NBUF_RX_RING, cur_nbuf);
                fec_rx_continue(ch);
                continue;
            }

#ifdef DEBUG_PRINT
            {
            int i;
            for(i = 0; i < pRxBD->length; hex_byte(pRxBD->data[i++]), display_char(' '));
            display_string("\r\n");
            }
#endif

            /*
             * Add the new network buffer to the Rx ring queue
             */
            nbuf_add(NBUF_RX_RING, new_nbuf);

            /*
             * Re-initialize the buffer descriptor - pointing it
             * to the new data buffer.  The previous data buffer
             * will be passed up the stack
             */
            pRxBD->data = new_nbuf->data;
            pRxBD->length = RX_BUF_SZ;
            pRxBD->status &= (RX_BD_W | RX_BD_INTERRUPT);
            pRxBD->status |= RX_BD_E;


            /*
             * Let the DMA know that there is a new Rx BD (in case the 
             * ring was full and the DMA was waiting for an empty one)
             */
            fec_rx_continue(ch);

            /*
             * Get pointer to the frame data inside the network buffer
             */
            eth_hdr = (ETH_HDR *)cur_nbuf->data;
            
            /*
             * Pass the received packet up the network stack if the 
             * protocol is supported in our network interface (NIF)
             */
            if (nif_protocol_exist(nif,eth_hdr->type))
            {
                nif_protocol_handler(nif, eth_hdr->type, cur_nbuf);
            }
            else
                nbuf_free(cur_nbuf);
        }
        else 
        {
            /* 
             * This frame isn't a keeper
             * Reset the status and length, but don't need to get another
             * buffer since we are trashing the data in the current one
             */
            pRxBD->length = RX_BUF_SZ;
            pRxBD->status &= (RX_BD_W | RX_BD_INTERRUPT);
            pRxBD->status |= RX_BD_E;

            /*
             * Move the current buffer from the beginning to the end of the 
             * Rx ring queue
             */
            cur_nbuf = nbuf_remove(NBUF_RX_RING);
            nbuf_add(NBUF_RX_RING, cur_nbuf);

            /*
             * Let the DMA know that there are new Rx BDs (in case
             * it is waiting for an empty one)
             */
            fec_rx_continue(ch);
        }
    }
}

void
fec0_rx_frame(void)
{
    fec_rx_frame(0, &nif[0]);
}

void
fec1_rx_frame(void)
{
    fec_rx_frame(1, &nif[1]);
}
/********************************************************************/
/*
 * Start the FEC Tx DMA task
 *
 * Parameters:
 *  ch      FEC channel
 *  txbd    First Tx buffer descriptor in the chain
 */
void
fec_tx_start(uint8 ch, int8 *txbd, uint8 pri)
{
    uint32 initiator;
    int channel, result;
    void fec0_tx_frame(void);
    void fec1_tx_frame(void);

    /*
     * Make the initiator assignment
     */
    result = dma_set_initiator(DMA_FEC_TX(ch));
//    ASSERT(result == 0);

    /*
     * Grab the initiator number
     */
    initiator = dma_get_initiator(DMA_FEC_TX(ch));
//    ASSERT(initiator != 0);

    /*
     * Determine the DMA channel running the task for the
     * selected FEC
     */
    channel = dma_set_channel(DMA_FEC_TX(ch),
                              (ch == 0) ? fec0_tx_frame : fec1_tx_frame);
//    ASSERT(channel != -1);

    /*
     * Start the Tx DMA task
     */
    MCD_startDma(channel,
                 (s8*)txbd,
                 0,
                 (s8*)MCF_FEC_FECTFDR_ADDR(ch),
                 0,
                 ETH_MTU,
                 0,
                 initiator,
                 (int)pri,
                 0 | MCD_FECTX_DMA   
                   | MCD_INTERRUPT
                   | MCD_TT_FLAGS_CW 
                   | MCD_TT_FLAGS_RL
                   | MCD_TT_FLAGS_SP
                   ,
                 0 | MCD_NO_CSUM
                   | MCD_NO_BYTE_SWAP
                 );
}
/********************************************************************/
/*
 * Stop all transmissions on the selected FEC and kill the DMA task
 *
 * Parameters:
 *  ch  FEC channel
 */
void
fec_tx_stop (uint8 ch)
{
    uint32 mask;
    int channel;

//    ASSERT(ch == 0 || ch == 1);

    /* Save off the EIMR value */
    mask = MCF_FEC_EIMR(ch);

    /* Mask all interrupts */
    MCF_FEC_EIMR(ch) = 0;

    /* If the Ethernet is still enabled... */
    if (MCF_FEC_ECR(ch) & MCF_FEC_ECR_ETHER_EN)
    {
        /* Issue the Graceful Transmit Stop */
        MCF_FEC_TCR(ch) |= MCF_FEC_TCR_GTS;

        /* Wait for the Graceful Stop Complete interrupt */
        while(!(MCF_FEC_EIR(ch) & MCF_FEC_EIR_GRA))
        {
            if (!(MCF_FEC_ECR(ch) & MCF_FEC_ECR_ETHER_EN))
                break;
        }

        /* Clear the Graceful Stop Complete interrupt */
        MCF_FEC_EIR(ch) = MCF_FEC_EIR_GRA;
    }

    /*
     * Determine the DMA channel running the task for the
     * selected FEC
     */
    channel = dma_get_channel(DMA_FEC_TX(ch));
//    ASSERT(channel != -1);

    /* Kill the FEC Tx DMA task */
    if (channel != -1)
    	MCD_killDma(channel);

    /* 
     * Free up the FEC requestor from the software maintained 
     * initiator list 
     */
    dma_free_initiator(DMA_FEC_TX(ch));

    /* Free up the DMA channel */
    dma_free_channel(DMA_FEC_TX(ch));

    /* Restore the interrupt mask register value */
    MCF_FEC_EIMR(ch) = mask;
}
/********************************************************************/
/*
 * Trasmit Frame interrupt handler - this handler is called when the
 * DMA FEC Tx task generates an interrupt 
 *
 * Parameters:
 *  ch      FEC channel
 */
void
fec_tx_frame(uint8 ch)
{
    FECBD *pTxBD;
    NBUF *pNbuf;

#ifdef DEBUG_PRINT
    display_string("fec_tx_frame\r\n");
#endif

    while ((pTxBD = fecbd_tx_free(ch)) != NULL)
    {
        fec_log[ch].dtxf++;

        /*
         * Grab the network buffer associated with this buffer descriptor
         */
        pNbuf = nbuf_remove(NBUF_TX_RING);
//        ASSERT(pNbuf);
//        ASSERT(pNbuf->data == pTxBD->data);

        /*
         * Free up the network buffer that was just transmitted
         */
        nbuf_free(pNbuf);

        /*
         * Re-initialize the Tx BD
         */
        pTxBD->data = NULL;
        pTxBD->length = 0;
    }    
}

void
fec0_tx_frame(void)
{
    fec_tx_frame(0);
}

void
fec1_tx_frame(void)
{
    fec_tx_frame(1);
}
/********************************************************************/
/*
 * Send a packet out the selected FEC
 *
 * Parameters:
 *  ch      FEC channel
 *  nif     Pointer to Network Interface (NIF) structure
 *  dst     Destination MAC Address
 *  src     Source MAC Address
 *  type    Ethernet Frame Type
 *  length  Number of bytes to be transmitted (doesn't include type, 
 *          src, or dest byte count)
 *  pkt     Pointer packet network buffer
 *
 * Return Value:
 *  1       success
 *  0       otherwise
 */
int
fec_send (uint8 ch, uint8 *dst, uint8 *src, uint16 type, NBUF *nbuf)
{
    FECBD *pTxBD;
    int i, channel;
    uint32 mask;
//    ASSERT(ch == 0 || ch == 1);
    
    /* Check the length */
    if ((nbuf->length + ETH_HDR_LEN) > ETH_MTU)
        return 0;

    /* 
     * Copy the destination address, source address, and Ethernet 
     * type into the packet 
     */
    memcpy(&nbuf->data[0],  dst,   6);
    memcpy(&nbuf->data[6],  src,   6);
    memcpy(&nbuf->data[12], &type, 2);
    
    /*
     * Grab the next available Tx Buffer Descriptor
     */
#if 0
    timer_set_secs(TIMER_NETWORK+1, 1);
    while ((pTxBD = fecbd_tx_alloc(ch)) == NULL)
    {
        if(!timer_get_reference(1))
        {
            #ifdef DEBUG_PRINT
                Cconws("Unable to allocate a free TxBD\r\n");     
//                fecbd_dump(ch);
//                nbuf_debug_dump();
//                fec_reg_dump(ch);
//                dma_reg_dump();
//                fec_log_dump(ch);
            #endif
            return 0;
        }
    }    
#else
    for (i = 0; i < 1000; ++i) 
    {
        if ((pTxBD = fecbd_tx_alloc(ch)) != NULL)
            break;
    }
    if (i == 1000) 
    {
        #ifdef DEBUG_PRINT
            Cconws("Unable to allocate a free TxBD\r\n");     
//            fecbd_dump(ch);
//            nbuf_debug_dump();
//            fec_reg_dump(ch);
//            dma_reg_dump();
//            fec_log_dump(ch);
        #endif
        return 0;
    }
#endif

    /*
     * Put the network buffer into the Tx waiting queue
     */
    nbuf_add(NBUF_TX_RING, nbuf);
    
#ifdef DEBUG_PRINT
    display_string("fec_send\r\n");
    for(i = 0; i < nbuf->length + ETH_HDR_LEN; hex_byte(nbuf->data[i++]), display_char(' '));
    display_string("\r\n");
#endif

#if (__GNUC__ > 3)
    asm volatile (" .chip 68060\n\t cpusha DC\n\t .chip 5485\n\t"); /* from CF68KLIB */
#else
    asm volatile (" .chip 68060\n\t cpusha DC\n\t .chip 5200\n\t"); /* from CF68KLIB */
#endif

    /* Save off the EIMR value */
    mask = MCF_FEC_EIMR(ch);

    /* Mask all interrupts */
    MCF_FEC_EIMR(ch) = 0;

    /* 
     * Setup the buffer descriptor for transmission
     */
    pTxBD->data = nbuf->data;
    pTxBD->length = nbuf->length + ETH_HDR_LEN;
    pTxBD->status |= (TX_BD_R | TX_BD_L);

    /* Restore the interrupt mask register value */
    MCF_FEC_EIMR(ch) = mask;

    /*
     * Determine the DMA channel running the task for the
     * selected FEC
     */
    channel = dma_get_channel(DMA_FEC_TX(ch));
//    ASSERT(channel != -1);

    /*
     * Continue/restart the DMA task
     */
    if (channel != -1)
      MCD_continDma((int)channel);

    return 1;
}

int
fec0_send(uint8 *dst, uint8 *src, uint16 type, NBUF *nbuf)
{
    return fec_send(0, dst, src, type, nbuf);
}

int
fec1_send(uint8 *dst, uint8 *src, uint16 type, NBUF *nbuf)
{
    return fec_send(1, dst, src, type, nbuf);
}
/********************************************************************/
/*
 * Enable interrupts on the selected FEC
 *
 * Parameters:
 *  ch      FEC channel
 *  pri     Interrupt Priority
 *  lvl     Interrupt Level
 */
void
fec_irq_enable(uint8 ch, uint8 lvl, uint8 pri)
{
//    ASSERT(ch == 0 || ch == 1);
//    ASSERT(lvl > 0 && lvl < 8);
//    ASSERT(pri < 8);

    /*
     * Setup the appropriate ICR
     */
    MCF_INTC_ICRn((ch == 0) ? 39 : 38) = (uint8)(0
        | MCF_INTC_ICRn_IP(pri)
        | MCF_INTC_ICRn_IL(lvl));

    /*
     * Clear any pending FEC interrupt events
     */
    MCF_FEC_EIR(ch) = MCF_FEC_EIR_CLEAR_ALL;

    /*
     * Unmask all FEC interrupts
     */
    MCF_FEC_EIMR(ch) = MCF_FEC_EIMR_UNMASK_ALL;

    /*
     * Unmask the FEC interrupt in the interrupt controller
     */
    if (ch == 0)
        MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK39;
    else
        MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK38;
}
/********************************************************************/
/*
 * Disable interrupts on the selected FEC
 *
 * Parameters:
 *  ch      FEC channel
 */
void
fec_irq_disable(uint8 ch)
{
//    ASSERT(ch == 0 || ch == 1);

    /*
     * Mask all FEC interrupts
     */
    MCF_FEC_EIMR(ch) = MCF_FEC_EIMR_MASK_ALL;

    /*
     * Mask the FEC interrupt in the interrupt controller
     */
    if (ch == 0)
        MCF_INTC_IMRH |= MCF_INTC_IMRH_INT_MASK39;
    else
        MCF_INTC_IMRH |= MCF_INTC_IMRH_INT_MASK38;
}
/********************************************************************/
/*
 * FEC interrupt handler
 * All interrupts are multiplexed into a single vector for each
 * FEC module. The lower level interrupt handler passes in the
 * channel to this handler. Note that the receive interrupt is
 * generated by the Multi-channel DMA FEC Rx task.
 *
 * Parameters:
 * ch       FEC channel
 */
void
fec_irq_handler(uint8 ch)
{
    uint32 event;

    /*
     * Determine which interrupt(s) asserted by AND'ing the
     * pending interrupts with those that aren't masked.
     */
    event = MCF_FEC_EIR(ch) & MCF_FEC_EIMR(ch);

    #ifdef DEBUG_PRINT
    display_string("fec_int\r\n");
    if (event != MCF_FEC_EIR(ch))
        display_string("Pending but not enabled\r\n");
//        Cconws("Pending but not enabled\r\n");
//        printf("Pending but not enabled: 0x%08X\r\n",(event ^ MCF_FEC_EIR(ch)));
    #endif

    /*
     * Clear the event(s) in the EIR immediately
     */
    MCF_FEC_EIR(ch) = event;

    if (event & MCF_FEC_EIR_RFERR)
    {
        fec_log[ch].errors++;
        fec_log[ch].rferr++;
        #ifdef DEBUG_PRINT
        display_string("RFERR\r\n");
//        Cconws("RFERR\r\n");
//        printf("FECRFSR%d = 0x%08x\n",ch,MCF_FEC_FECRFSR(ch));
        fec_eth_stop(ch);
        #endif
    }
    if (event & MCF_FEC_EIR_XFERR)
    {
        fec_log[ch].errors++;
        fec_log[ch].xferr++;
        #ifdef DEBUG_PRINT
        display_string("XFERR\r\n");
//        Cconws("XFERR\r\n");
        #endif
    }
    if (event & MCF_FEC_EIR_XFUN)
    {
        fec_log[ch].errors++;
        fec_log[ch].xfun++;
        #ifdef DEBUG_PRINT
        display_string("XFUN\r\n");
//        Cconws("XFUN\r\n");
        fec_eth_stop(ch);
        #endif
    }
    if (event & MCF_FEC_EIR_RL)
    {
        fec_log[ch].errors++;
        fec_log[ch].rl++;
        #ifdef DEBUG_PRINT
        display_string("RL\r\n");
//        Cconws("RL\r\n");
        #endif
    }
    if (event & MCF_FEC_EIR_LC)
    {
        fec_log[ch].errors++;
        fec_log[ch].lc++;
        #ifdef DEBUG_PRINT
        display_string("LC\r\n");
//        Cconws("LC\r\n");
        #endif
    }
    if (event & MCF_FEC_EIR_MII)
    {
        fec_log[ch].mii++;
    }
    if (event & MCF_FEC_EIR_TXF)
    {
        fec_log[ch].txf++;
    }
    if (event & MCF_FEC_EIR_GRA)
    {
        fec_log[ch].gra++;
    }
    if (event & MCF_FEC_EIR_BABT)
    {
        fec_log[ch].errors++;
        fec_log[ch].babt++;
        #ifdef DEBUG_PRINT
        display_string("BABT\r\n");
//        Cconws("BABT\r\n");
        #endif
    }
    if (event & MCF_FEC_EIR_BABR)
    {
        fec_log[ch].errors++;
        fec_log[ch].babr++;
        #ifdef DEBUG_PRINT
        display_string("BABR\r\n");
//        Cconws("BABR\r\n");
        #endif
    }
    if (event & MCF_FEC_EIR_HBERR)
    {
        fec_log[ch].errors++;
        fec_log[ch].hberr++;
        #ifdef DEBUG_PRINT
        display_string("HBERR\r\n");
//        Cconws("HBERR\r\n");
        #endif
    }
}

/********************************************************************/
/*
 * Configure the selected Ethernet port and enable all operations
 *
 * Parameters:
 *  ch      FEC channel
 *  trcvr   Transceiver mode (MII, 7-Wire or internal loopback)
 *  speed   Maximum operating speed (valid in MII mode only)
 *  duplex  Full or Half-duplex (MII only)
 *  mac     Physical (MAC) Address
 *  sys_clk System clock frequency - used for MII speed calculation
 *  phya    Address of the MII Phy (valid in MII mode only)
 *  flvl    FEC interrupt level
 *  fpri    FEC interrupt priority
 *  dtxpri  Tx DMA task priority
 *  drxpri  Rx DMA task priority
 *
 * Return Value:
 *  1 if the Ethernet was successfully started
 *  0 otherwise 
 */
int
fec_eth_start(uint8 ch, uint8 trcvr, uint8 speed, uint8 duplex, uint8 *mac,
              int sys_clk, uint8 phya, uint8 flvl, uint8 fpri,
              uint8 dtxpri, uint8 drxpri)
{
//    ASSERT(ch == 0 || ch == 1);

    /*
     * Disable FEC interrupts
     */
    fec_irq_disable(ch);

    /*
     * Initialize the event log
     */
    fec_log_init(ch);

    /*
     * Initialize the network buffers and fec buffer descriptors
     */
    if (nbuf_init() != 0)
    	return 0;
    
    fecbd_init(ch);

    /*
     * Initialize the FEC
     */
    fec_reset(ch);
    fec_init(ch, trcvr, duplex, mac);

    if (trcvr == FEC_MODE_MII)
    {
        /* Initialize the PHY interface */
        if (!phy_init(ch, phya, speed, duplex))
        {
            /* Flush the network buffers */
            nbuf_flush();
            return 0;
        }
    }

    /*
     * Enable the multi-channel DMA tasks
     */
    fec_rx_start(ch, (int8*)fecbd_get_start(ch,Rx), drxpri);
    fec_tx_start(ch, (int8*)fecbd_get_start(ch,Tx), dtxpri);

    /*
     * Initialize and enable FEC interrupts
     */
    fec_irq_enable(ch, flvl, fpri);

    /*
     * Enable the FEC channel
     */
    MCF_FEC_ECR(ch) |= MCF_FEC_ECR_ETHER_EN;

    return 1;
}
/********************************************************************/
/*
 * Stop the selected Ethernet port
 *
 * Parameters:
 *  ch      FEC channel
 */
void
fec_eth_stop(uint8 ch)
{
    int level;
    
    /*
     * Disable interrupts
     */
    level = asm_set_ipl(7);

    /*
     * Gracefully disable the receiver and transmitter
     */
    fec_tx_stop(ch);
    fec_rx_stop(ch);

    /*
     * Disable FEC interrupts
     */
    fec_irq_disable(ch);

    /*
     * Disable the FEC channel
     */
    MCF_FEC_ECR(ch) &= ~MCF_FEC_ECR_ETHER_EN;

    /* 
     * Flush the network buffers
     */
    nbuf_flush();

    /* 
     * Restore interrupt level
     */
    asm_set_ipl(level);
}
/********************************************************************/

#endif /* LWIP */
#endif /* NETWORK */
