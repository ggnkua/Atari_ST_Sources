/*
 * File:	dma_utils.c
 * Purpose: General purpose utilities for the multi-channel DMA
 *
 * Notes:   The methodology used in these utilities assumes that
 *          no single initiator will be tied to more than one
 *          task/channel
 */

#include <osbind.h>
#include "config.h"
#include "net.h"
#include "dma_utils.h"
#ifdef MCF5445X
#include "mcf5445x.h"
#else
#include "../mcdapi/MCD_dma.h"
#include "mcf548x.h"
#endif

extern void ltoa(char *buf, long n, unsigned long base);

#ifdef NETWORK
#ifndef LWIP

/*
 * This global keeps track of which initiators have been
 * used of the available assignments.  Initiators 0-15 are
 * hardwired.  Initiators 16-31 are multiplexed and controlled
 * via the Initiatior Mux Control Register (IMCR).  The
 * assigned requestor is stored with the associated initiator
 * number.
 */
static int8 used_reqs[32];

DMA_CHANNEL_STRUCT dma_channel[NCHANNELS];

void dma_init_tables(void)
{
    int i;
    used_reqs[0] = DMA_ALWAYS;
    used_reqs[1] = DMA_DSPI_RX;
    used_reqs[2] = DMA_DSPI_TX;
    used_reqs[3] = DMA_DREQ0;
    used_reqs[4] = DMA_PSC0_RX;
    used_reqs[5] = DMA_PSC0_TX;
    used_reqs[6] = DMA_USBEP0;
    used_reqs[7] = DMA_USBEP1;
    used_reqs[8] = DMA_USBEP2;
    used_reqs[9] = DMA_USBEP3;
    used_reqs[10] = DMA_PCI_TX;
    used_reqs[11] = DMA_PCI_RX;
    used_reqs[12] = DMA_PSC1_RX;
    used_reqs[13] = DMA_PSC1_TX;
    used_reqs[14] = DMA_I2C_RX;
    used_reqs[15] = DMA_I2C_TX;
    for(i=16; i<32; used_reqs[i++] = 0);
    for(i=0; i<NCHANNELS; i++)
    {
        dma_channel[i].req = -1;
        dma_channel[i].handler = NULL;
    }
}

/********************************************************************/
/*
 * Enable all DMA interrupts
 *
 * Parameters:
 *  pri     Interrupt Priority
 *  lvl     Interrupt Level
 */
void
dma_irq_enable(uint8 lvl, uint8 pri)
{
//    ASSERT(lvl > 0 && lvl < 8);
//    ASSERT(pri < 8);

    /* Setup the DMA ICR (#48) */
    MCF_INTC_ICR48 = 0
        | MCF_INTC_ICRn_IP(pri)
        | MCF_INTC_ICRn_IL(lvl);

    /* Unmask all task interrupts */
    MCF_DMA_DIMR = 0;

    /* Clear the interrupt pending register */
    MCF_DMA_DIPR = 0;

    /* Unmask the DMA interrupt in the interrupt controller */
    MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK48;
}
/********************************************************************/
/*
 * Disable all DMA interrupts
 */
void
dma_irq_disable(void)
{
    /* Mask all task interrupts */
    MCF_DMA_DIMR = (uint32)~0;

    /* Clear any pending task interrupts */
    MCF_DMA_DIPR = (uint32)~0;

    /* Mask the DMA interrupt in the interrupt controller */
    MCF_INTC_IMRH |= MCF_INTC_IMRH_INT_MASK48;
}
/********************************************************************/
/*
 * Attempt to enable the provided Initiator in the Initiator
 * Mux Control Register
 *
 * Parameters:
 *  initiator   Initiator identifier
 *
 * Return Value:
 *  1   if unable to make the assignment
 *  0   successful
 */
int
dma_set_initiator(int initiator)
{
    switch (initiator)
    {
        case DMA_ALWAYS:
        case DMA_DSPI_RX:
        case DMA_DSPI_TX:
        case DMA_DREQ0:
        case DMA_PSC0_RX:
        case DMA_PSC0_TX:
        case DMA_USBEP0:
        case DMA_USBEP1:
        case DMA_USBEP2:
        case DMA_USBEP3:
        case DMA_PCI_TX:
        case DMA_PCI_RX:
        case DMA_PSC1_RX:
        case DMA_PSC1_TX:
        case DMA_I2C_RX:
        case DMA_I2C_TX:
            /* These initiators are always active */
            break;
        case DMA_FEC0_RX:
            MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC16(3))
                            | MCF_DMA_IMCR_SRC16_FEC0RX;
            used_reqs[16] = DMA_FEC0_RX;
            break;
        case DMA_FEC0_TX:
            MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC17(3))
                            | MCF_DMA_IMCR_SRC17_FEC0TX;
            used_reqs[17] = DMA_FEC0_TX;
            break;
        case DMA_FEC1_RX:
            MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC20(3))
                            | MCF_DMA_IMCR_SRC20_FEC1RX;
            used_reqs[20] = DMA_FEC1_RX;
            break;
        case DMA_FEC1_TX:
            if (used_reqs[21] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC21(3))
                                | MCF_DMA_IMCR_SRC21_FEC1TX;
                used_reqs[21] = DMA_FEC1_TX;
            }
            else if (used_reqs[25] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC25(3))
                                | MCF_DMA_IMCR_SRC25_FEC1TX;
                used_reqs[25] = DMA_FEC1_TX;
            }
            else if (used_reqs[31] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC31(3))
                                | MCF_DMA_IMCR_SRC31_FEC1TX;
                used_reqs[31] = DMA_FEC1_TX;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_DREQ1:
            if (used_reqs[29] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC29(3))
                                | MCF_DMA_IMCR_SRC29_DREQ1;
                used_reqs[29] = DMA_DREQ1;
            }
            else if (used_reqs[21] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC21(3))
                                | MCF_DMA_IMCR_SRC21_DREQ1;
                used_reqs[21] = DMA_DREQ1;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_CTM0:
            if (used_reqs[24] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC24(3))
                                | MCF_DMA_IMCR_SRC24_CTM0;
                used_reqs[24] = DMA_CTM0;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_CTM1:
            if (used_reqs[25] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC25(3))
                                | MCF_DMA_IMCR_SRC25_CTM1;
                used_reqs[25] = DMA_CTM1;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_CTM2:
            if (used_reqs[26] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC26(3))
                                | MCF_DMA_IMCR_SRC26_CTM2;
                used_reqs[26] = DMA_CTM2;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_CTM3:
            if (used_reqs[27] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC27(3))
                                | MCF_DMA_IMCR_SRC27_CTM3;
                used_reqs[27] = DMA_CTM3;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_CTM4:
            if (used_reqs[28] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC28(3))
                                | MCF_DMA_IMCR_SRC28_CTM4;
                used_reqs[28] = DMA_CTM4;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_CTM5:
            if (used_reqs[29] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC29(3))
                                | MCF_DMA_IMCR_SRC29_CTM5;
                used_reqs[29] = DMA_CTM5;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_CTM6:
            if (used_reqs[30] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC30(3))
                                | MCF_DMA_IMCR_SRC30_CTM6;
                used_reqs[30] = DMA_CTM6;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_CTM7:
            if (used_reqs[31] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC31(3))
                                | MCF_DMA_IMCR_SRC31_CTM7;
                used_reqs[31] = DMA_CTM7;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_USBEP4:
            if (used_reqs[26] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC26(3))
                                | MCF_DMA_IMCR_SRC26_USBEP4;
                used_reqs[26] = DMA_USBEP4;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_USBEP5:
            if (used_reqs[27] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC27(3))
                                | MCF_DMA_IMCR_SRC27_USBEP5;
                used_reqs[27] = DMA_USBEP5;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_USBEP6:
            if (used_reqs[28] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC28(3))
                                | MCF_DMA_IMCR_SRC28_USBEP6;
                used_reqs[28] = DMA_USBEP6;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_PSC2_RX:
            if (used_reqs[28] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC28(3))
                                | MCF_DMA_IMCR_SRC28_PSC2RX;
                used_reqs[28] = DMA_PSC2_RX;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_PSC2_TX:
            if (used_reqs[29] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC29(3))
                                | MCF_DMA_IMCR_SRC29_PSC2TX;
                used_reqs[29] = DMA_PSC2_TX;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_PSC3_RX:
            if (used_reqs[30] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC30(3))
                                | MCF_DMA_IMCR_SRC30_PSC3RX;
                used_reqs[30] = DMA_PSC3_RX;
            }
            else /* No empty slots */
                return 1;
            break;
        case DMA_PSC3_TX:
            if (used_reqs[31] == 0)
            {
                MCF_DMA_IMCR = (MCF_DMA_IMCR & ~MCF_DMA_IMCR_SRC31(3))
                                | MCF_DMA_IMCR_SRC31_PSC3TX;
                used_reqs[31] = DMA_PSC3_TX;
            }
            else /* No empty slots */
                return 1;
            break;
        default:
            return 1;
    }
    return 0;
}
/********************************************************************/
/*
 * Return the initiator number for the given requestor
 *
 * Parameters:
 *  requestor   Initiator/Requestor identifier
 *
 * Return Value:
 *  The initiator number (0-31) if initiator has been assigned
 *  0 (always initiator) otherwise
 */
uint32
dma_get_initiator(int requestor)
{
    uint32 i;

    for (i=0; i<sizeof(used_reqs); ++i)
    {
        if (used_reqs[i] == requestor)
            return i;
    }
    return 0;
}
/********************************************************************/
/*
 * Remove the given initiator from the active list
 *
 * Parameters:
 *  requestor   Initiator/Requestor identifier
 */
void
dma_free_initiator(int requestor)
{
    uint32 i;

    for (i=16; i<sizeof(used_reqs); ++i)
    {
        if (used_reqs[i] == requestor)
        {
            used_reqs[i] = 0;
            break;
        }
    }
}
/********************************************************************/
/*
 * Attempt to find an available channel and mark it as used
 *
 * Parameters:
 *  requestor   Initiator/Requestor identifier
 *
 * Return Value:
 *  First available channel or -1 if they are all occupied
 */
int
dma_set_channel(int requestor, void (*handler)(void))
{
    int i;

    /* Check to see if this requestor is already assigned to a channel */
    if(requestor && (i = dma_get_channel(requestor)) != -1)
        return i;

    for (i=0; i<NCHANNELS; ++i)
    {
        if (dma_channel[i].req == -1)
        {
            dma_channel[i].req = requestor;
            dma_channel[i].handler = handler;
            return i;
        }
    }

    /* All channels taken */
    return -1;
}
/********************************************************************/
/*
 * Return the channel being initiated by the given requestor
 *
 * Parameters:
 *  requestor   Initiator/Requestor identifier
 *
 * Return Value:
 *  Channel that the requestor is controlling or -1 if hasn't been
 *  activated
 */
int
dma_get_channel(int requestor)
{
    uint32 i;

    for (i=0; i<NCHANNELS; ++i)
    {
        if (dma_channel[i].req == requestor)
            return i;
    }
    return -1;
}
/********************************************************************/
/*
 * Remove the channel being initiated by the given requestor from
 * the active list
 *
 * Parameters:
 *  requestor   Initiator/Requestor identifier
 */
void
dma_free_channel(int requestor)
{
    uint32 i;

    for (i=0; i<NCHANNELS; ++i)
    {
        if (dma_channel[i].req == requestor)
        {
            dma_channel[i].req = -1;
            dma_channel[i].handler = NULL;
            break;
        }
    }
}

void
dma_clear_channel(int channel)
{
    if(channel >= 0 && channel < NCHANNELS)
    {
        dma_channel[channel].req = -1;
        dma_channel[channel].handler = NULL;
    }
}
/********************************************************************/
/*
 * This is the catch-all interrupt handler for the mult-channel DMA
 */
void dma_interrupt_handler (void)
{
    uint32 i, interrupts;

    /*
     * Determine which interrupt(s) triggered by AND'ing the
     * pending interrupts with those that aren't masked.
     */
    interrupts = MCF_DMA_DIPR & ~MCF_DMA_DIMR;

    /* Make sure we are here for a reason */
//    ASSERT(interrupts != 0);

    /* Clear the interrupt in the pending register */
    MCF_DMA_DIPR = interrupts;

    for (i=0; i<16; ++i, interrupts>>=1)
    {
        if (interrupts & 0x1)
        {
            /* If there is a handler, call it */
            if (dma_channel[i].handler != NULL)
            {
#if 0 // #ifdef DEBUG                
	              display_string("dma_int 0x");
	              hex_long(i);
	              display_string("\r\n");
#endif	   
                dma_channel[i].handler();
            }
        }
    }
}
/********************************************************************/
/*
 * Display some of the registers for debugging
 */
void
dma_reg_dump (void)
{
#if 0 // #ifdef DEBUG_PRINT
    char buf[10];
    Cconws("\r\n------------- DMA -------------");
    Cconws("\r\nTASKBAR  0x");
    ltoa(buf, MCF_DMA_TASKBAR, 16);
    Cconws(buf); 
    Cconws("\r\nCP       0x");
    ltoa(buf, MCF_DMA_CP, 16);
    Cconws(buf);     
    Cconws("\r\nEP       0x");
    ltoa(buf, MCF_DMA_EP, 16);
    Cconws(buf);        
    Cconws("\r\nVP       0x");
    ltoa(buf, MCF_DMA_VP, 16);
    Cconws(buf);    
    Cconws("\r\nDIPR     0x");
    ltoa(buf, MCF_DMA_DIPR, 16);
    Cconws(buf);  
    Cconws("\r\nDIMR     0x");
    ltoa(buf, MCF_DMA_DIMR, 16);
    Cconws(buf);  
    Cconws("\r\nTCR0     0x");
    ltoa(buf, MCF_DMA_TCR0, 16);
    Cconws(buf);  
    Cconws("\r\nTCR1     0x");
    ltoa(buf, MCF_DMA_TCR1, 16);
    Cconws(buf);  
    Cconws("\r\nTCR2     0x");
    ltoa(buf, MCF_DMA_TCR2, 16);
    Cconws(buf);  
    Cconws("\r\nCR3     0x");
    ltoa(buf, MCF_DMA_TCR3, 16);
    Cconws(buf);  
    Cconws("\r\nTCR4     0x");
    ltoa(buf, MCF_DMA_TCR4, 16);
    Cconws(buf);
    Cconws("\r\nTCR5     0x");
    ltoa(buf, MCF_DMA_TCR5, 16);
    Cconws(buf);  
    Cconws("\r\nTCR6     0x");
    ltoa(buf, MCF_DMA_TCR6, 16);
    Cconws(buf);  
    Cconws("\r\nTCR7     0x");
    ltoa(buf, MCF_DMA_TCR7, 16);
    Cconws(buf);  
    Cconws("\r\nTCR8     0x");
    ltoa(buf, MCF_DMA_TCR8, 16);
    Cconws(buf);  
    Cconws("\r\nTCR9     0x");
    ltoa(buf, MCF_DMA_TCR9, 16);
    Cconws(buf);  
    Cconws("\r\nTCR10    0x");
    ltoa(buf, MCF_DMA_TCR10, 16);
    Cconws(buf);  
    Cconws("\r\nTCR11    0x");
    ltoa(buf, MCF_DMA_TCR11, 16);
    Cconws(buf);  
    Cconws("\r\nTCR12    0x");
    ltoa(buf, MCF_DMA_TCR12, 16);
    Cconws(buf);
    Cconws("\r\nTCR13    0x");
    ltoa(buf, MCF_DMA_TCR13, 16);
    Cconws(buf);  
    Cconws("\r\nTCR14    0x");
    ltoa(buf, MCF_DMA_TCR14, 16);
    Cconws(buf);  
    Cconws("\r\nTCR15    0x");
    ltoa(buf, MCF_DMA_TCR15, 16);
    Cconws(buf);  
    Cconws("\r\nIMCR     0x");
    ltoa(buf, MCF_DMA_IMCR, 16);
    Cconws(buf);  
    Cconws("\r\nPTDDBG   0x");
    ltoa(buf, MCF_DMA_PTDDBG, 16);
    Cconws(buf);
    Cconws("\r\n--------------------------------\r\n");
#endif
}
/********************************************************************/

#endif /* LWIP */
#endif /* NETWORK */

