/* FEC driver for MCF547X/MCF548X/MCF5445X
 * Didier Mequignon 2007-2009, e-mail: aniplay@wanadoo.fr
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* ------------------------ System includes ------------------------------- */
#include <string.h>

/* ------------------------ Platform includes ----------------------------- */
#include "config.h"
#include "net.h"
#include "get.h"
#include "fec.h"
#include "../dma_utils/dma_utils.h"
#ifdef MCF5445X
#include "mcf5445x.h"
#define MCF_FEC_EIR_MII FEC_EIR_MII
#define MCF_FEC_EIMR_MII FEC_EIMR_MII
#define MCF_FEC_MMFR_ST_01 FEC_MMFR_ST_01
#define MCF_FEC_MMFR_OP_WRITE FEC_MMFR_OP_WR
#define MCF_FEC_MMFR_OP_READ FEC_MMFR_OP_RD
#define MCF_FEC_MMFR_PA FEC_MMFR_PA
#define MCF_FEC_MMFR_RA FEC_MMFR_RA
#define MCF_FEC_MMFR_TA_10 FEC_MMFR_TA_10
#define MCF_FEC_MMFR_DATA FEC_MMFR_DATA 
#define MCF_FEC_MSCR_MII_SPEED FEC_MSCR_MII_SPEED
#define MCF_FEC_ECR_RESET FEC_ECR_RESET
#define MCF_FEC_ECR_ETHER_EN FEC_ECR_ETHER_EN;
#define MCF_FEC_RCR_DRT FEC_RCR_DRT
#define MCF_FEC_TCR_FDEN FEC_TCR_FDEN
#else
#include "../mcdapi/MCD_dma.h"
#include "mcf548x.h"
#endif
#include "../../include/ramcf68k.h"
#define Setexc(num, vect) \
   *(unsigned long *)(((num) * 4) + coldfire_vector_base) = (unsigned long)vect

/* ------------------------ lwIP includes --------------------------------- */
#include "opt.h"
#include "def.h"
#include "mem.h"
#include "pbuf.h"
#include "sys.h"
#include "stats.h"
//#include "perf.h"
#include "etharp.h"
#include "debug.h"

/* ------------------------ Defines --------------------------------------- */
#define MCF_FEC_MTU             (1518)
#ifdef MCF5445X
#define FEC_RESET_DELAY         100
#else /* MCF548X */
#define V_FEC0                  (64+39)
#define V_FEC1                  (64+38)
#endif
#define TASK_PRIORITY           (30)

#ifdef NETWORK
#ifdef LWIP

/* ------------------------ Type definitions ------------------------------ */
typedef struct
{
  struct netif *netif;        /* lwIP network interface */
  struct eth_addr *self;      /* MAC address of FEC interface */
  uint8 ch;                   /* channel */
  xSemaphoreHandle tx_sem;    /* Control access to transmitter */
  xSemaphoreHandle rx_sem;    /* Semaphore to signal receive thread */  
//  sys_sem_t tx_sem;           /* Control access to transmitter */
//  sys_sem_t rx_sem;           /* Semaphore to signal receive thread */  
} fec_if_t;

/* ------------------------ Static variables ------------------------------ */
static fec_if_t *fecif_g[2];
static portBASE_TYPE xNeedSwitch;

/* ------------------------ Start implementation -------------------------- */

#ifdef MCF5445X
extern void fec0_rx_int(void);
extern void fec1_rx_int(void);
extern void fec0_tx_int(void);
extern void fec1_tx_int(void);
#else /* MCF548X */
static void fec0_rx_frame(void);
static void fec1_rx_frame(void);
static void fec0_tx_frame(void);
static void fec1_tx_frame(void);
#endif /* MCF5445X */
extern void flush_dc(void);
extern void fec0_int(void);
extern void fec1_int(void);
extern int phy_init(uint8 fec_ch, uint8 phy_addr, uint8 speed, uint8 duplex);

extern long pxCurrentTCB, tid_TOS;

#undef DEBUG_PRINT

#ifdef DEBUG_PRINT
extern void conout_debug(char c);
extern void conws_debug(char *buf);

static void hex_byte(char c)
{
  int val;
  val = (int)(c >> 4) & 0xF;
  val |= '0';
  if(val > '9')
    val += 7;
  conout_debug(val);
  val = (int)c & 0xF;
  val |= '0';
  if(val > '9')
    val += 7;
  conout_debug(val);
}
#endif

#ifdef MCF5445X

void fec0_rx_interrupt(void)
{
  asm volatile (
                "_fec0_rx_int:\n\t"
                " move.w #0x2700,SR\n\t"
                " lea -24(SP),SP\n\t"
                " movem.l D0-D2/A0-A2,(SP)\n\t"
                " clr.l -(SP)\n\t"
                " jsr _fec_rx_frame\n\t"
                " addq.l #4,SP\n\t"
                " movem.l (SP),D0-D2/A0-A2\n\t"
                " lea 24(SP),SP\n\t"
                " rte\n\t" );
}

void fec1_rx_interrupt(void)
{
  asm volatile (
                "_fec1_rx_int:\n\t"
                " move.w #0x2700,SR\n\t"
                " lea -24(SP),SP\n\t"
                " movem.l D0-D2/A0-A2,(SP)\n\t"
                " pea 1\n\t"
                " jsr _fec_rx_frame\n\t"
                " addq.l #4,SP\n\t"
                " movem.l (SP),D0-D2/A0-A2\n\t"
                " lea 24(SP),SP\n\t"
                " rte\n\t" );
}

void fec0_tx_interrupt(void)
{
  asm volatile (
                "_fec0_tx_int:\n\t"
                " move.w #0x2700,SR\n\t"
                " lea -24(SP),SP\n\t"
                " movem.l D0-D2/A0-A2,(SP)\n\t"
                " clr.l -(SP)\n\t"
                " jsr _fec_tx_frame\n\t"
                " addq.l #4,SP\n\t"
                " movem.l (SP),D0-D2/A0-A2\n\t"
                " lea 24(SP),SP\n\t"
                " rte\n\t" );
}

void fec1_tx_interrupt(void)
{
  asm volatile (
                "_fec1_tx_int:\n\t"
                " move.w #0x2700,SR\n\t"
                " lea -24(SP),SP\n\t"
                " movem.l D0-D2/A0-A2,(SP)\n\t"
                " pea 1\n\t"
                " jsr _fec_tx_frame\n\t"
                " addq.l #4,SP\n\t"
                " movem.l (SP),D0-D2/A0-A2\n\t"
                " lea 24(SP),SP\n\t"
                " rte\n\t" );
}

#endif

void fec0_interrupt(void)
{
  asm volatile (
                "_fec0_int:\n\t"
                " move.w #0x2700,SR\n\t"
                " lea -24(SP),SP\n\t"
                " movem.l D0-D2/A0-A2,(SP)\n\t"
                " clr.l -(SP)\n\t"
                " jsr _fec_interrupt_handler\n\t"
                " addq.l #4,SP\n\t"
                " movem.l (SP),D0-D2/A0-A2\n\t"
                " lea 24(SP),SP\n\t"
                " rte\n\t" );
}

void fec1_interrupt(void)
{
  asm volatile (
                "_fec1_int:\n\t"
                " move.w #0x2700,SR\n\t"
                " lea -24(SP),SP\n\t"
                " movem.l D0-D2/A0-A2,(SP)\n\t"
                " pea 1\n\t"
                " jsr _fec_interrupt_handler\n\t"
                " addq.l #4,SP\n\t"
                " movem.l (SP),D0-D2/A0-A2\n\t"
                " lea 24(SP),SP\n\t"
                " rte\n\t" );
}

void dma_interrrupt2(void)
{
  xNeedSwitch = pdFALSE;
  dma_interrupt_handler();
}

void dma_interrupt(void)
{
  portENTER_SWITCHING_ISR()
  dma_interrrupt2();
  portEXIT_SWITCHING_ISR(xNeedSwitch);
}

/* This function is called by the TCP/IP stack when an IP packet should be
 * sent. It uses the ethernet ARP module provided by lwIP to resolve the
 * destination MAC address. The ARP module will later call our low level
 * output function fec_output_raw.
 */
static err_t fec_output(struct netif * netif, struct pbuf * p, struct ip_addr * ipaddr )
{
  err_t res;
//  fec_if_t *fecif = netif->state;
  /* Make sure only one thread is in this function. */
//  sys_sem_wait(fecif->tx_sem);
  res = etharp_output(netif, ipaddr, p);
  return res;
}

static void eth_input(struct netif *netif, struct pbuf *p)
{
  struct eth_hdr *eth_hdr = p->payload;
  LWIP_ASSERT("eth_input: p != NULL ", p != NULL);
  switch(htons(eth_hdr->type))
  {
    case ETHTYPE_IP:
      /* Pass to ARP layer. */
      etharp_ip_input(netif, p);
      /* Skip Ethernet header. */
      pbuf_header(p, (s16_t) - sizeof(struct eth_hdr));
      /* Pass to network layer. */
      netif->input(p, netif);
      break;
    case ETHTYPE_ARP:
      /* Pass to ARP layer. */
      etharp_arp_input(netif, (struct eth_addr *)netif->hwaddr, p);
      break;
    default:
      pbuf_free(p);
      break;
  }
}

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
int fec_mii_write(uint8 ch, uint8 phy_addr, uint8 reg_addr, uint16 data)
{
  int timeout;
  uint32 eimr;
  /* Clear the MII interrupt bit */
  MCF_FEC_EIR(ch) = MCF_FEC_EIR_MII;
  /* Write to the MII Management Frame Register to kick-off the MII write */
  MCF_FEC_MMFR(ch) = MCF_FEC_MMFR_ST_01 | MCF_FEC_MMFR_OP_WRITE | MCF_FEC_MMFR_PA(phy_addr)
   | MCF_FEC_MMFR_RA(reg_addr) | MCF_FEC_MMFR_TA_10 | MCF_FEC_MMFR_DATA(data);
  /* Mask the MII interrupt */
  eimr = MCF_FEC_EIMR(ch);
  MCF_FEC_EIMR(ch) &= ~MCF_FEC_EIMR_MII;
  /* Poll for the MII interrupt (interrupt should be masked) */
  for(timeout = 0; timeout < FEC_MII_TIMEOUT; timeout++)
  {
    if(MCF_FEC_EIR(ch) & MCF_FEC_EIR_MII)
      break;
  }
  if(timeout == FEC_MII_TIMEOUT)
    return 0;
  /* Clear the MII interrupt bit */
  MCF_FEC_EIR(ch) = MCF_FEC_EIR_MII;
  /* Restore the EIMR */
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
int fec_mii_read(uint8 ch, uint8 phy_addr, uint8 reg_addr, uint16 *data)
{
  int timeout;
  /* Clear the MII interrupt bit */
  MCF_FEC_EIR(ch) = MCF_FEC_EIR_MII;
  /* Write to the MII Management Frame Register to kick-off the MII read */
  MCF_FEC_MMFR(ch) = MCF_FEC_MMFR_ST_01 | MCF_FEC_MMFR_OP_READ | MCF_FEC_MMFR_PA(phy_addr)
  | MCF_FEC_MMFR_RA(reg_addr) | MCF_FEC_MMFR_TA_10;
  /* Poll for the MII interrupt (interrupt should be masked) */
  for(timeout = 0; timeout < FEC_MII_TIMEOUT; timeout++)
  {
    if(MCF_FEC_EIR(ch) & MCF_FEC_EIR_MII)
      break;
  }
  if(timeout == FEC_MII_TIMEOUT)
    return 0;
  /* Clear the MII interrupt bit */
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
void fec_mii_init(uint8 ch, uint32 sys_clk)
{
  /* Initialize the MII clock (EMDC) frequency
     Desired MII clock is 2.5MHz
     MII Speed Setting = System_Clock / (2.5MHz * 2)
     (plus 1 to make sure we round up) */
  MCF_FEC_MSCR(ch) = MCF_FEC_MSCR_MII_SPEED((sys_clk/5)+1);
}

/********************************************************************/
/*
 * Set the duplex on the selected FEC controller
 *
 * Parameters:
 *  ch      FEC channel
 *  duplex  FEC_MII_FULL_DUPLEX or FEC_MII_HALF_DUPLEX
 */
void fec_duplex(uint8 ch, uint8 duplex)
{
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
static uint8 fec_hash_address(const uint8 *addr)
{
  uint32 crc;
  uint8 byte;
  int i, j;
  crc = 0xFFFFFFFF;
  for(i=0; i<6; ++i)
  {
    byte = addr[i];
    for(j=0; j<8; j++)
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
  return(uint8)(crc >> 26);
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
static void fec_set_address(uint8 ch, const uint8 *pa)
{
  uint8 crc;
  /* Set the Physical Address */
  MCF_FEC_PALR(ch) = (uint32)((pa[0]<<24) | (pa[1]<<16) | (pa[2]<<8) | pa[3]);
  MCF_FEC_PAUR(ch) = (uint32)((pa[4]<<24) | (pa[5]<<16));
  /* Calculate and set the hash for given Physical Address
     in the  Individual Address Hash registers */
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
static void fec_reset(uint8 ch)
{
  int i;
#ifdef MCF5445X
  /* Configure Interrupt vectors */
  if(ch)
  {
    Setexc(64+INT0_HI_FEC1_TXF, fec1_int);
    Setexc(64+INT0_HI_FEC1_TXB, fec1_tx_int);
    Setexc(64+INT0_HI_FEC1_UN, fec1_int);
    Setexc(64+INT0_HI_FEC1_RL, fec1_int);
    Setexc(64+INT0_HI_FEC1_RXF, fec1_int);
    Setexc(64+INT0_HI_FEC1_RXB, fec1_rx_int);
    Setexc(64+INT0_HI_FEC1_MII, fec1_int);
    Setexc(64+INT0_HI_FEC1_LC, fec1_int);
    Setexc(64+INT0_HI_FEC1_HBERR, fec1_int);
    Setexc(64+INT0_HI_FEC1_GRA, fec1_int);
    Setexc(64+INT0_HI_FEC1_EBERR, fec1_int);
    Setexc(64+INT0_HI_FEC1_BABT, fec1_int);
    Setexc(64+INT0_HI_FEC1_BABR, fec1_int);
  }
  else
  {
    Setexc(64+INT0_HI_FEC0_TXF, fec0_int);
    Setexc(64+INT0_HI_FEC0_TXB, fec0_tx_int);
    Setexc(64+INT0_HI_FEC0_UN, fec0_int);
    Setexc(64+INT0_HI_FEC0_RL, fec0_int);
    Setexc(64+INT0_HI_FEC0_RXF, fec0_int);
    Setexc(64+INT0_HI_FEC0_RXB, fec0_rx_int);
    Setexc(64+INT0_HI_FEC0_MII, fec0_int);
    Setexc(64+INT0_HI_FEC0_LC, fec0_int);
    Setexc(64+INT0_HI_FEC0_HBERR, fec0_int);
    Setexc(64+INT0_HI_FEC0_GRA, fec0_int);
    Setexc(64+INT0_HI_FEC0_EBERR, fec0_int);
    Setexc(64+INT0_HI_FEC0_BABT, fec0_int);
    Setexc(64+INT0_HI_FEC0_BABR, fec0_int);
  }  
  /* Set the Reset bit and clear the Enable bit */
  MCF_FEC_ECR(ch) = MCF_FEC_ECR_RESET;
  for(i = 0; (MCF_FEC_ECR(ch) & MCF_FEC_ECR_RESET) && (i < FEC_RESET_DELAY); i++)
  {
    asm volatile (" nop\n\t");
  }
#else /* MCF548X */
  /* Configure Interrupt vectors */
  if(ch)
    Setexc(V_FEC1, fec1_int);
  else
    Setexc(V_FEC0, fec0_int);
  /* Clear any events in the FIFO status registers */
  MCF_FEC_FECRFSR(ch) = (MCF_FEC_FECRFSR_OF | MCF_FEC_FECRFSR_UF | MCF_FEC_FECRFSR_RXW | MCF_FEC_FECRFSR_FAE | MCF_FEC_FECRFSR_IP);
  MCF_FEC_FECTFSR(ch) = (MCF_FEC_FECRFSR_OF | MCF_FEC_FECRFSR_UF | MCF_FEC_FECRFSR_RXW | MCF_FEC_FECRFSR_FAE | MCF_FEC_FECRFSR_IP);
  /* Reset the FIFOs */
  MCF_FEC_FRST(ch) |= MCF_FEC_FRST_SW_RST;
  MCF_FEC_FRST(ch) &= ~MCF_FEC_FRST_SW_RST;
  /* Set the Reset bit and clear the Enable bit */
  MCF_FEC_ECR(ch) = MCF_FEC_ECR_RESET;
  /* Wait at least 8 clock cycles */
  for(i = 0; i < 10; i++)
  {
    asm volatile (" nop\n\t"); 
  }
#endif /* MCF5445X */
}

/********************************************************************/
/*
 * Initialize the selected FEC
 *
 * Parameters:
 *  ch      FEC channel
 *  mode    External interface mode (RMII, MII, 7-wire, or internal loopback)
 *  pa      Physical (Hardware) Address for the selected FEC
 */
static void fec_init(uint8 ch, uint8 mode, uint8 duplex, const uint8 *pa)
{
#ifdef MCF5445X
  /* Enable all the external interface signals */
  if(ch)
  {
    MCF_GPIO_PAR_FEC &= ~GPIO_PAR_FEC_FEC1_MASK;
    switch(mode)
    {
      case FEC_MODE_MII:
      case FEC_MODE_LOOPBACK: MCF_GPIO_PAR_FEC |= GPIO_PAR_FEC_FEC1_MII; break;
      case FEC_MODE_7WIRE:
      case FEC_MODE_RMII:
      case FEC_MODE_RMII_LOOPBACK: MCF_GPIO_PAR_FEC |= GPIO_PAR_FEC_FEC1_RMII_ATA; break;
    }
  }
  else
  {
    MCF_GPIO_PAR_FEC &= ~GPIO_PAR_FEC_FEC0_MASK;
    switch(mode)
    {
      case FEC_MODE_MII:
      case FEC_MODE_LOOPBACK: MCF_GPIO_PAR_FEC |= GPIO_PAR_FEC_FEC0_MII; break;
      case FEC_MODE_7WIRE:
      case FEC_MODE_RMII:
      case FEC_MODE_RMII_LOOPBACK: MCF_GPIO_PAR_FEC |= GPIO_PAR_FEC_FEC0_RMII_ULPI; break;
    }
  }
  /* Clear the Individual and Group Address Hash registers */
  MCF_FEC_IALR(ch) = 0;
  MCF_FEC_IAUR(ch) = 0;
  MCF_FEC_GALR(ch) = 0;
  MCF_FEC_GAUR(ch) = 0;
  /* Set the Physical Address for the selected FEC */
  fec_set_address(ch, pa);
  /* Mask all FEC interrupts */
  MCF_FEC_EIMR(ch) = FEC_EIMR_MASK_ALL;
  /* Clear all FEC interrupt events */
  MCF_FEC_EIR(ch) = FEC_EIR_CLEAR_ALL;
  /* Initialize the Receive Control Register */
  MCF_FEC_RCR(ch) = FEC_RCR_MAX_FL(ETH_MAX_FRM)
#ifdef FEC_PROMISCUOUS
   | FEC_RCR_PROM
#endif
   | FEC_RCR_FCE;
  switch(mode)
  {
    case FEC_MODE_MII: MCF_FEC_RCR(ch) |= FEC_RCR_MII_MODE; break;
    case FEC_MODE_LOOPBACK: MCF_FEC_RCR(ch) |= (FEC_RCR_LOOP | FEC_RCR_PROM); break;
    case FEC_MODE_RMII:  MCF_FEC_RCR(ch) |= FEC_RCR_RMII_MODE; break;
    case FEC_MODE_RMII_LOOPBACK: MCF_FEC_RCR(ch) |= (FEC_RCR_RMII_LOOP | FEC_RCR_PROM); break;
  }
  /* Set maximum receive buffer size */
  MCF_FEC_EMRBR(ch) = TX_BUFFER_SIZE;
#else /* MCF548X */
  /* Enable all the external interface signals */
  if(mode == FEC_MODE_7WIRE)
  {
    if(ch)
      MCF_GPIO_PAR_FECI2CIRQ |= MCF_GPIO_PAR_FECI2CIRQ_PAR_E17;
    else
      MCF_GPIO_PAR_FECI2CIRQ |= MCF_GPIO_PAR_FECI2CIRQ_PAR_E07;
  }
  else if (mode == FEC_MODE_MII)
  {
    if(ch)
      MCF_GPIO_PAR_FECI2CIRQ |= (MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MDC_EMDC | MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MDIO_EMDIO
       | MCF_GPIO_PAR_FECI2CIRQ_PAR_E1MII | MCF_GPIO_PAR_FECI2CIRQ_PAR_E17);
    else
      MCF_GPIO_PAR_FECI2CIRQ |= (MCF_GPIO_PAR_FECI2CIRQ_PAR_E0MDC | MCF_GPIO_PAR_FECI2CIRQ_PAR_E0MDIO
       | MCF_GPIO_PAR_FECI2CIRQ_PAR_E0MII | MCF_GPIO_PAR_FECI2CIRQ_PAR_E07);
  }
  /* Clear the Individual and Group Address Hash registers */
  MCF_FEC_IALR(ch) = 0;
  MCF_FEC_IAUR(ch) = 0;
  MCF_FEC_GALR(ch) = 0;
  MCF_FEC_GAUR(ch) = 0;
  /* Set the Physical Address for the selected FEC */
  fec_set_address(ch, pa);
  /* Mask all FEC interrupts */
  MCF_FEC_EIMR(ch) = MCF_FEC_EIMR_MASK_ALL;
  /* Clear all FEC interrupt events */
  MCF_FEC_EIR(ch) = MCF_FEC_EIR_CLEAR_ALL;
  /* Initialize the Receive Control Register */
  MCF_FEC_RCR(ch) = MCF_FEC_RCR_MAX_FL(ETH_MAX_FRM)
#ifdef FEC_PROMISCUOUS
   | MCF_FEC_RCR_PROM
#endif
   | MCF_FEC_RCR_FCE;
  if(mode == FEC_MODE_MII)
    MCF_FEC_RCR(ch) |= MCF_FEC_RCR_MII_MODE;
  else if(mode == FEC_MODE_LOOPBACK)
    MCF_FEC_RCR(ch) |= (MCF_FEC_RCR_LOOP | MCF_FEC_RCR_PROM);
  /* Set the duplex */
  if(mode == FEC_MODE_LOOPBACK)
    /* Loopback mode must operate in full-duplex */
    fec_duplex(ch, FEC_MII_FULL_DUPLEX);
  else
    fec_duplex(ch, duplex);
  /* Set Rx FIFO alarm and granularity */
  MCF_FEC_FECRFCR(ch) = MCF_FEC_FECRFCR_FRM | MCF_FEC_FECRFCR_RXW_MSK | MCF_FEC_FECRFCR_GR(7);
  MCF_FEC_FECRFAR(ch) = MCF_FEC_FECRFAR_ALARM(768);
  /* Set Tx FIFO watermark, alarm and granularity */
  MCF_FEC_FECTFCR(ch) = MCF_FEC_FECTFCR_FRM | MCF_FEC_FECTFCR_TXW_MSK | MCF_FEC_FECTFCR_GR(7);
  MCF_FEC_FECTFAR(ch) = MCF_FEC_FECTFAR_ALARM(256);
  MCF_FEC_FECTFWR(ch) = MCF_FEC_FECTFWR_X_WMRK_256;
  /* Enable the transmitter to append the CRC */
  MCF_FEC_CTCWR(ch) = MCF_FEC_CTCWR_TFCW | MCF_FEC_CTCWR_CRC;
#endif /* MCF5445X */
}

#ifndef MCF5445X
/********************************************************************/
/*
 * Start the FEC Rx DMA task
 *
 * Parameters:
 *  ch      FEC channel
 *  rxbd    First Rx buffer descriptor in the chain
 */
static void fec_rx_start(uint8 ch, int8 *rxbd, uint8 pri)
{
  uint32 initiator;
  int channel, result;
  /* Make the initiator assignment */
  result = dma_set_initiator(DMA_FEC_RX(ch));
  /* Grab the initiator number */
  initiator = dma_get_initiator(DMA_FEC_RX(ch));
  /* Determine the DMA channel running the task for the selected FEC */
  channel = dma_set_channel(DMA_FEC_RX(ch), ch ? fec1_rx_frame : fec0_rx_frame);
#if RX_BUFFER_SIZE != 2048
#error "RX_BUFFER_SIZE must be set to 2048 for safe FEC operation"
#endif
  /* Start the Rx DMA task */
  MCD_startDma(channel, (s8*)rxbd, 0, (s8*)MCF_FEC_FECRFDR_ADDR(ch), 0, RX_BUFFER_SIZE, 0, initiator, (int)pri,
   MCD_FECRX_DMA | MCD_INTERRUPT | MCD_TT_FLAGS_CW | MCD_TT_FLAGS_RL | MCD_TT_FLAGS_SP, MCD_NO_CSUM | MCD_NO_BYTE_SWAP);
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
static void fec_rx_continue(uint8 ch)
{
  int channel;
  /* Determine the DMA channel running the task for the selected FEC */
  channel = dma_get_channel(DMA_FEC_RX(ch));
  /* Continue/restart the DMA task */
  if(channel != -1)
    MCD_continDma(channel);
}

/********************************************************************/
/*
 * Stop all frame receptions on the selected FEC
 *
 * Parameters:
 *  ch  FEC channel
 */
static void fec_rx_stop(uint8 ch)
{
  uint32 mask;
  int channel;
  /* Save off the EIMR value */
  mask = MCF_FEC_EIMR(ch);
  /* Mask all interrupts */
  MCF_FEC_EIMR(ch) = 0;
  /* Determine the DMA channel running the task for the selected FEC */
  channel = dma_get_channel(DMA_FEC_RX(ch));
  /* Kill the FEC Tx DMA task */
  if(channel != -1)
    MCD_killDma(channel);
  /* Free up the FEC requestor from the software maintained initiator list */
  dma_free_initiator(DMA_FEC_RX(ch));
  /* Free up the DMA channel */
  dma_free_channel(DMA_FEC_RX(ch));
  /* Restore the interrupt mask register value */
  MCF_FEC_EIMR(ch) = mask;
}

#endif /* MCF5455X */

/********************************************************************/
/*
 * Receive Frame interrupt task
 */
static void fec_rx_task(void *arg)
{
  fec_if_t *fecif = (fec_if_t *)arg;
  uint8 ch = fecif->ch;
  struct pbuf *p, *q;
  nbuf_t *pNBuf;
  int keep;
  uint8 *pPayLoad;
  while(1)
  {
//    sys_sem_wait(fecif->rx_sem);
    while(xSemaphoreAltTake(fecif->rx_sem, portMAX_DELAY) != pdTRUE); 
//    if(!ch) PERF_START;
#ifndef NBUF_USE_SYSTEM_RAM
    flush_dc();
#endif
    while((pNBuf = nbuf_rx_allocate(ch)) != NULL)
    {
      /* Check the Receive Frame Status Word for errors
       - The L bit should always be set
       - No undefined bits should be set
       - The upper 5 bits of the length should be cleared */
      if(!(pNBuf->status & RX_BD_L) || (pNBuf->status & 0x0608) || (pNBuf->length & 0xF800))
        keep = FALSE;
      else if(pNBuf->status & RX_BD_ERROR)
        keep = FALSE;
      else
        keep = TRUE;    
      if(keep)
      {
        /* The frame must no be valid. Perform some checks to see if the FEC
           driver is working correctly. */
        p = pbuf_alloc(PBUF_RAW, pNBuf->length, PBUF_POOL);
        if(p != NULL)
        {
#if ETH_PAD_SIZE
          pbuf_header(p, -ETH_PAD_SIZE);
#endif
          pPayLoad = pNBuf->data;
          for(q = p; q != NULL; q = q->next)
          {
            memcpy(q->payload, pPayLoad, q->len);
            pPayLoad += q->len;
          }
#ifdef DEBUG_PRINT
          {
            int i, j, val;
            for(j = 0; j < pNBuf->length; j += 16)
            {
              hex_byte((char)((long)(j) >> 8));
              hex_byte((char)((long)(j)));
              conout_debug(' ');
              for(i = 0; (i < 16) && (i + j < pNBuf->length); i++)
              {
                hex_byte((char)(pNBuf->data[i+j]));
                conout_debug(' ');
              } 
              for(i = 0; (i < 16) && (i + j < pNBuf->length); i++)
              {
                val = pNBuf->data[i+j] & 0xFF;
                if(val < ' ' || val > 127)
                  val = '.';
                conout_debug(val);
              }
              conws_debug("\r\n");
            }
          }
#endif
#if LINK_STATS
          lwip_stats.link.recv++;
#endif
#if ETH_PAD_SIZE
          pbuf_header(p, ETH_PAD_SIZE);
#endif
          /* Ethernet frame received. Handling it is not device dependent and therefore done in another function */
          eth_input(fecif->netif, p);         
        }
#ifdef DEBUG_PRINT
        else
          conws_debug("pbuf_alloc == NULL\r\n");
#endif      
      }
      else
      {
#ifdef DEBUG_PRINT
        conws_debug("drop frame\r\n");
#endif
#ifdef LINK_STATS
        lwip_stats.link.drop++;
        if(pNBuf->status & RX_BD_LG)
          lwip_stats.link.lenerr++;
        else if(pNBuf->status & (RX_BD_NO | RX_BD_OV))
          lwip_stats.link.err++;
        else
          lwip_stats.link.chkerr++;
#endif
      }
      /* Re-initialize the buffer descriptor - pointing it to the new data buffer */
#ifdef MCF5445X
      MCF_FEC_EIR(ch) |= FEC_EIR_RXF; /* Clear RX interrupt */
      pNBuf->length = 0;
      pNBuf->status = RX_BD_E;
      /* Try to fill Rx Buffer Descriptors */
      MCF_FEC_RDAR(ch) = FEC_RDAR_R_DES_ACTIVE; /* Descriptor polling active */
#else /* MCF548X */
      pNBuf->length = RX_BUFFER_SIZE;
      pNBuf->status &= (RX_BD_W | RX_BD_INTERRUPT);
      pNBuf->status |= RX_BD_E;
      fec_rx_continue(ch);
#endif
    }
//    if(!ch) PERF_STOP("fec_rx_task");
  }  
}

/********************************************************************/
/*
 * Receive Frame interrupt handler
 */
void fec_rx_frame(uint8 ch)
{
#ifdef DEBUG_PRINT
  conws_debug("fec_rx_frame\r\n");
#endif
  xNeedSwitch = xSemaphoreGiveFromISR(fecif_g[ch]->rx_sem, xNeedSwitch);
}

#ifndef MCF5445X

static void fec0_rx_frame(void)
{
  fec_rx_frame(0);
}

static void fec1_rx_frame(void)
{
  fec_rx_frame(1);
}

/********************************************************************/
/*
 * Start the FEC Tx DMA task
 *
 * Parameters:
 *  ch      FEC channel
 *  txbd    First Tx buffer descriptor in the chain
 */
static void fec_tx_start(uint8 ch, int8 *txbd, uint8 pri)
{
  uint32 initiator;
  int channel, result;
  /* Make the initiator assignment */
  result = dma_set_initiator(DMA_FEC_TX(ch));
  /* Grab the initiator number */
  initiator = dma_get_initiator(DMA_FEC_TX(ch));
  /* Determine the DMA channel running the task for the selected FEC */
  channel = dma_set_channel(DMA_FEC_TX(ch), ch ? fec1_tx_frame : fec0_tx_frame);
  /* Start the Tx DMA task */
  MCD_startDma(channel, (s8*)txbd, 0, (s8*)MCF_FEC_FECTFDR_ADDR(ch), 0, ETH_MTU, 0, initiator, (int)pri,
   MCD_FECTX_DMA | MCD_INTERRUPT | MCD_TT_FLAGS_CW | MCD_TT_FLAGS_RL | MCD_TT_FLAGS_SP, MCD_NO_CSUM | MCD_NO_BYTE_SWAP);
}

/********************************************************************/
/*
 * Stop all transmissions on the selected FEC and kill the DMA task
 *
 * Parameters:
 *  ch  FEC channel
 */
static void fec_tx_stop(uint8 ch)
{
  uint32 mask;
  int channel;
  /* Save off the EIMR value */
  mask = MCF_FEC_EIMR(ch);
  /* Mask all interrupts */
  MCF_FEC_EIMR(ch) = 0;
  /* If the Ethernet is still enabled... */
  if(MCF_FEC_ECR(ch) & MCF_FEC_ECR_ETHER_EN)
  {
    /* Issue the Graceful Transmit Stop */
    MCF_FEC_TCR(ch) |= MCF_FEC_TCR_GTS;
    /* Wait for the Graceful Stop Complete interrupt */
    while(!(MCF_FEC_EIR(ch) & MCF_FEC_EIR_GRA))
    {
      if(!(MCF_FEC_ECR(ch) & MCF_FEC_ECR_ETHER_EN))
        break;
    }
    /* Clear the Graceful Stop Complete interrupt */
    MCF_FEC_EIR(ch) = MCF_FEC_EIR_GRA;
  }
  /* Determine the DMA channel running the task for the selected FEC */
  channel = dma_get_channel(DMA_FEC_TX(ch));
  /* Kill the FEC Tx DMA task */
  if(channel != -1)
    MCD_killDma(channel);
  /* Free up the FEC requestor from the software maintained initiator list */
  dma_free_initiator(DMA_FEC_TX(ch));
  /* Free up the DMA channel */
  dma_free_channel(DMA_FEC_TX(ch));
  /* Restore the interrupt mask register value */
  MCF_FEC_EIMR(ch) = mask;
}

#endif /* MCF5445X */

/********************************************************************/
/*
 * Transmit Frame interrupt handler - this handler is called when the
 * DMA FEC Tx task generates an interrupt 
 *
 * Parameters:
 *  ch      FEC channel
 */
void fec_tx_frame(uint8 ch)
{
//  static nbuf_t *pNbuf;
#ifdef DEBUG_PRINT
  conws_debug("fec_tx_frame\r\n");
#endif
//  if((pNbuf = nbuf_tx_free(ch)) != NULL)
////  while((pNbuf = nbuf_tx_free(ch)) != NULL)
//    pNbuf->length = 0;
#ifdef MCF5445X
  MCF_FEC_EIR(ch) |= FEC_EIR_TXF; /* Clear TX interrupt */
#endif
}

#ifndef MCF5445X

static void fec0_tx_frame(void)
{
  fec_tx_frame(0);
}

static void fec1_tx_frame(void)
{
  fec_tx_frame(1);
}

#endif /* MCF5445X */

static err_t fec_output_raw(struct netif *netif, struct pbuf *p)
{
  err_t res;
  uint8 ch;
  nbuf_t *pNBuf;
  fec_if_t *fecif = netif->state;
  int i;
#ifndef MCF5445X
  int channel;
#endif
  struct pbuf *q;
#if ETH_PAD_SIZE
  pbuf_header(p, -ETH_PAD_SIZE);    /* drop the padding word */
#endif
  ch = fecif->ch;
//  if(!ch) PERF_START;
  while(xSemaphoreAltTake(fecif->tx_sem, portMAX_DELAY) != pdTRUE);
  /* Test if we can handle such big frames. If not drop it. */
  if(p->tot_len > MCF_FEC_MTU)
  {
#if LINK_STATS
    lwip_stats.link.lenerr++;
#endif
    res = ERR_BUF;
  }
  /* Test if our network buffer scheme can handle a packet of this size. If
     not drop it and return a memory error. */
  else if(p->tot_len > TX_BUFFER_SIZE)
  {
#ifdef LINK_STATS
    lwip_stats.link.memerr++;
#endif
    res = ERR_MEM;
  }
  /* Allocate a transmit buffer. If no buffer is available drop the frame. */
  else if((pNBuf = nbuf_tx_allocate(ch)) == NULL)
  {
    LWIP_ASSERT("fec_output_raw: pNBuf != NULL\r\n", pNBuf != NULL);
#ifdef LINK_STATS
    lwip_stats.link.memerr++;
#endif
    res = ERR_MEM;
  }
  else
  {
    q = p;
    i = 0;
    do
    {
      memcpy(&pNBuf->data[i], q->payload, q->len);
      i += q->len;
    }
    while((q = q->next) != NULL);
#ifdef DEBUG_PRINT
    {
      int j, val;
      conws_debug("fec_output_raw\r\n");
      for(j = 0; j < p->tot_len; j += 16)
      {
        hex_byte((char)((long)(j) >> 8));
        hex_byte((char)((long)(j)));
        conout_debug(' ');
        for(i = 0; (i < 16) && (i + j < p->tot_len); i++)
        {
          hex_byte((char)(pNBuf->data[i+j]));
          conout_debug(' ');
        } 
        for(i = 0; (i < 16) && (i + j < p->tot_len); i++)
        {
          val = pNBuf->data[i+j] & 0xFF;
          if(val < ' ' || val > 127)
            val = '.';
          conout_debug(val);
        }
        conws_debug("\r\n");
      }
    }
#endif
#ifndef NBUF_USE_SYSTEM_RAM
    flush_dc();
#endif
    pNBuf->length = p->tot_len;
    /* Set Frame ready for transmission */
    pNBuf->status |= (TX_BD_R | TX_BD_L);
#ifdef MCF5445X
    /* Activate transmit Buffer Descriptor polling */
    MCF_FEC_TDAR(ch) = FEC_TDAR_X_DES_ACTIVE; /* Descriptor polling active */
#else
    /* Determine the DMA channel running the task for the selected FEC */
    channel = dma_get_channel(DMA_FEC_TX(ch));
    /* Continue/restart the DMA task */
    if(channel != -1)
      MCD_continDma((int)channel);
#endif /* MCF5445X */
#if LINK_STATS
    lwip_stats.link.xmit++;
#endif
    res = ERR_OK;
  }
//  sys_sem_signal(fecif->tx_sem);
  xSemaphoreAltGive(fecif->tx_sem);
//  if(!ch) PERF_STOP("fec_output_raw");
#if ETH_PAD_SIZE
  pbuf_header(p, ETH_PAD_SIZE);
#endif
  return(res);
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
static void fec_irq_enable(uint8 ch, uint8 lvl, uint8 pri)
{
#ifdef MCF5445X
  if(pri);
  /* Setup the appropriate ICRs */
  if(ch)
  {
    MCF_INTC_ICR0n(INT0_HI_FEC1_TXF) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC1_TXB) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC1_UN) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC1_RL) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC1_RXF) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC1_RXB) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC1_MII) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC1_LC) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC1_HBERR) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC1_GRA) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC1_EBERR) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC1_BABT) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC1_BABR) = INTC_ICR_IL(lvl);
  }
  else
  {
    MCF_INTC_ICR0n(INT0_HI_FEC0_TXF) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC0_TXB) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC0_UN) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC0_RL) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC0_RXF) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC0_RXB) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC0_MII) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC0_LC) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC0_HBERR) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC0_GRA) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC0_EBERR) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC0_BABT) = INTC_ICR_IL(lvl);
    MCF_INTC_ICR0n(INT0_HI_FEC0_BABR) = INTC_ICR_IL(lvl);
  }  
  /* Clear any pending interrupt */
  MCF_FEC_EIR(ch) = FEC_EIR_CLEAR_ALL;
  /* Unmask all FEC interrupts */
  MCF_FEC_EIMR(ch) = FEC_EIMR_UNMASK_ALL;
  /* Unmask the FEC interrupts in the interrupt controller */
  if(ch)
    MCF_INTC_IMRH0 &= ~(INTC_IMRH_INT_MASK49 | INTC_IMRH_INT_MASK50
     | INTC_IMRH_INT_MASK51 | INTC_IMRH_INT_MASK52 | INTC_IMRH_INT_MASK53
     | INTC_IMRH_INT_MASK54 | INTC_IMRH_INT_MASK55 | INTC_IMRH_INT_MASK56
     | INTC_IMRH_INT_MASK57 | INTC_IMRH_INT_MASK58 | INTC_IMRH_INT_MASK59
     | INTC_IMRH_INT_MASK60 | INTC_IMRH_INT_MASK61);
  else
    MCF_INTC_IMRH0 &= ~(INTC_IMRH_INT_MASK36 | INTC_IMRH_INT_MASK37
     | INTC_IMRH_INT_MASK38 | INTC_IMRH_INT_MASK39 | INTC_IMRH_INT_MASK40
     | INTC_IMRH_INT_MASK41 | INTC_IMRH_INT_MASK42 | INTC_IMRH_INT_MASK43
     | INTC_IMRH_INT_MASK44 | INTC_IMRH_INT_MASK45 | INTC_IMRH_INT_MASK46
     | INTC_IMRH_INT_MASK47 | INTC_IMRH_INT_MASK48);
#else /* MCF548X */
  /* Setup the appropriate ICR */
  if(ch)
    MCF_INTC_ICR38 = (uint8)(MCF_INTC_ICRn_IP(pri) | MCF_INTC_ICRn_IL(lvl));
  else
    MCF_INTC_ICR39 = (uint8)(MCF_INTC_ICRn_IP(pri) | MCF_INTC_ICRn_IL(lvl));
  /* Clear any pending FEC interrupt events */
  MCF_FEC_EIR(ch) = MCF_FEC_EIR_CLEAR_ALL;
  /* Unmask all FEC interrupts */
  MCF_FEC_EIMR(ch) = MCF_FEC_EIMR_UNMASK_ALL;
  /* Unmask the FEC interrupt in the interrupt controller */
  if(ch)
    MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK38;
  else
    MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK39;
#endif /* MCF5445X */
}

/********************************************************************/
/*
 * Disable interrupts on the selected FEC
 *
 * Parameters:
 *  ch      FEC channel
 */
static void fec_irq_disable(uint8 ch)
{
#ifdef MCF5445X
  /* Mask all FEC interrupts */
  MCF_FEC_EIMR(ch) = FEC_EIMR_MASK_ALL;
  /* Mask the FEC interrupts in the interrupt controller */
  if(ch)
    MCF_INTC_IMRH0 |= (INTC_IMRH_INT_MASK49 | INTC_IMRH_INT_MASK50
     | INTC_IMRH_INT_MASK51 | INTC_IMRH_INT_MASK52 | INTC_IMRH_INT_MASK53
     | INTC_IMRH_INT_MASK54 | INTC_IMRH_INT_MASK55 | INTC_IMRH_INT_MASK56
     | INTC_IMRH_INT_MASK57 | INTC_IMRH_INT_MASK58 | INTC_IMRH_INT_MASK59
     | INTC_IMRH_INT_MASK60 | INTC_IMRH_INT_MASK61);
  else
    MCF_INTC_IMRH0 |= (INTC_IMRH_INT_MASK36 | INTC_IMRH_INT_MASK37
     | INTC_IMRH_INT_MASK38 | INTC_IMRH_INT_MASK39 | INTC_IMRH_INT_MASK40
     | INTC_IMRH_INT_MASK41 | INTC_IMRH_INT_MASK42 | INTC_IMRH_INT_MASK43
     | INTC_IMRH_INT_MASK44 | INTC_IMRH_INT_MASK45 | INTC_IMRH_INT_MASK46
     | INTC_IMRH_INT_MASK47 | INTC_IMRH_INT_MASK48);
#else /* MCF548X */
  /* Mask all FEC interrupts */
  MCF_FEC_EIMR(ch) = MCF_FEC_EIMR_MASK_ALL;
  /* Mask the FEC interrupt in the interrupt controller */
  if(ch)
    MCF_INTC_IMRH |= MCF_INTC_IMRH_INT_MASK38;
  else
    MCF_INTC_IMRH |= MCF_INTC_IMRH_INT_MASK39;
#endif /* MCF5445X */
}

/********************************************************************/
/*
 * Enable interrupts on the selected FEC
 *
 * Parameters:
 *  ch      FEC channel
 */
static void fec_enable(uint8 ch)
{
  fec_irq_enable(ch, FEC_INTC_LVL, ch ? FEC1_INTC_PRI : FEC0_INTC_PRI);
  /* Enable the transmit and receive processing */
  MCF_FEC_ECR(ch) |= MCF_FEC_ECR_ETHER_EN;
#ifdef MCF5445X
  /* Try to fill Rx Buffer Descriptors */
  MCF_FEC_RDAR(ch) = FEC_RDAR_R_DES_ACTIVE; /* Descriptor polling active */
#endif
}

/********************************************************************/
/*
 * Disable interrupts on the selected FEC
 *
 * Parameters:
 *  ch      FEC channel
 */
static void fec_disable(uint8 ch)
{                
  /* Mask the FEC interrupt in the interrupt controller */
  fec_irq_disable(ch);
  /* Disable the FEC channel */
  MCF_FEC_ECR(ch) &= ~MCF_FEC_ECR_ETHER_EN;
}

/********************************************************************/
/*
 * FEC interrupt handler
 * All interrupts are multiplexed into a single vector for each
 * FEC module. The lower level interrupt handler passes in the
 * channel to this handler. Note that the receive interrupt is
 * generated by the Multi-channel DMA FEC Rx task.
 */
void fec_interrupt_handler(uint8 ch)
{
  uint32 event;
  /* Determine which interrupt(s) asserted by AND'ing the
     pending interrupts with those that aren't masked */
  event = MCF_FEC_EIR(ch) & MCF_FEC_EIMR(ch);
#ifdef DEBUG_PRINT
  conws_debug("fec_int\r\n");
  if(event != MCF_FEC_EIR(ch))
    conws_debug("Pending but not enabled\r\n");
#endif
  /* Clear the event(s) in the EIR immediately */
  MCF_FEC_EIR(ch) = event;
}

/********************************************************************/
/*
 * Start the selected Ethernet port
 *
 * Parameters:
 *  ch      FEC channel
 */
err_t fec_eth_start(uint8 ch, uint8 trcvr, uint8 speed, uint8 duplex, struct netif *netif)
{
  err_t res;
  fec_if_t *fecif;
  fecif = mem_malloc(sizeof(fec_if_t));
  if(fecif != NULL)
  {
    /* Global copy used in ISR */
    fecif_g[ch] = fecif;
    fecif->self = (struct eth_addr *)&netif->hwaddr[0];
    fecif->netif = netif;
    fecif->ch = ch;
//    if((fecif->tx_sem = sys_sem_new(1)) == NULL)
//      res = ERR_MEM;
//    else if((fecif->rx_sem = sys_sem_new(0)) == NULL)
//      res = ERR_MEM;
    vSemaphoreCreateBinary(fecif->tx_sem);
    vSemaphoreCreateBinary(fecif->rx_sem);
    if(fecif->rx_sem != NULL)
      xSemaphoreAltTake(fecif->rx_sem, 1);
    if((fecif->tx_sem == NULL) || (fecif->rx_sem == NULL))
      res = ERR_MEM;
    else if(sys_thread_new(fec_rx_task, fecif, TASK_PRIORITY) == NULL)
      res = ERR_MEM;
    else
    {
      /* Disable FEC interrupts */
      fec_irq_disable(ch);
      netif->state = fecif;
      netif->name[0] = 'e';
      netif->name[1] = 'n';
      netif->hwaddr_len = ETH_ADDR_LEN;
      netif->mtu = MCF_FEC_MTU;
      netif->flags = NETIF_FLAG_BROADCAST;
      netif->output = fec_output;
      netif->linkoutput = fec_output_raw;
      board_get_ethaddr((uint8 *)fecif->self);
      if(nbuf_init(ch))
        res = ERR_MEM;
      else
      {
        fec_reset(ch);
        fec_init(ch, trcvr, duplex, (const uint8 *)fecif->self);
        netif->flags |= NETIF_FLAG_LINK_UP;     
        /* Initialize the PHY interface */
        if((trcvr == FEC_MODE_MII) && !phy_init(ch, FEC_PHY(ch), speed, duplex))
#if 1
          netif->flags &= ~NETIF_FLAG_LINK_UP;
#else
        {
          /* Flush the network buffers */
          nbuf_flush(ch);
          res = ERR_MEM;
        }
        else
#endif
        {
#ifdef MCF5445X
          /* Set receive and transmit descriptor base */
          MCF_FEC_ERDSR(ch) = (uint32)nbuf_get_start(ch, NBUF_RX);
          MCF_FEC_ETDSR(ch) = (uint32)nbuf_get_start(ch, NBUF_TX);
#else /* MCF548X */
          /* Enable the multi-channel DMA tasks */
          fec_rx_start(ch, (int8*)nbuf_get_start(ch, NBUF_RX), ch ? FEC1RX_DMA_PRI : FEC0TX_DMA_PRI);
          fec_tx_start(ch, (int8*)nbuf_get_start(ch, NBUF_TX), ch ? FEC1TX_DMA_PRI : FEC0TX_DMA_PRI);
#endif /* MCF5445X */
          fec_enable(ch);
          etharp_init();
          res = ERR_OK;
        }
      }
    }
    if(res != ERR_OK)
    {
      mem_free(fecif);
      if(fecif->tx_sem != NULL)
      	vQueueDelete((xQueueHandle)fecif->tx_sem);
//        sys_sem_free(fecif->tx_sem);
      if(fecif->rx_sem != NULL)
      	vQueueDelete((xQueueHandle)fecif->rx_sem);
//        sys_sem_free(fecif->rx_sem);
    }
  }
  else
    res = ERR_MEM;
  return(res);
}

/********************************************************************/
/*
 * Stop the selected Ethernet port
 *
 * Parameters:
 *  ch      FEC channel
 */
void fec_eth_stop(uint8 ch)
{
  int level;
  /* Disable interrupts */
  level = asm_set_ipl(7);
#ifndef MCF5445X
  /* Gracefully disable the receiver and transmitter */
  fec_tx_stop(ch);
  fec_rx_stop(ch);
#endif
  /* Disable FEC interrupts */
  fec_disable(ch);
  /* Flush the network buffers */
  nbuf_flush(ch);
  /* Restore interrupt level */
  asm_set_ipl(level);
}

err_t mcf_fec0_init(struct netif *netif)
{
#ifdef MCF5445X
  return(fec_eth_start(0, FEC_MODE_RMII, FEC_MII_100BASE_TX, FEC_MII_FULL_DUPLEX, netif));
#else /* MCF548X */
  return(fec_eth_start(0, FEC_MODE_MII, FEC_MII_100BASE_TX, FEC_MII_FULL_DUPLEX, netif));
#endif
}

err_t mcf_fec1_init(struct netif *netif)
{
#ifdef MCF5445X
  return(fec_eth_start(1, FEC_MODE_RMII, FEC_MII_100BASE_TX, FEC_MII_FULL_DUPLEX, netif));
#else /* MCF548X */
  return(fec_eth_start(1, FEC_MODE_MII, FEC_MII_100BASE_TX, FEC_MII_FULL_DUPLEX, netif));
#endif
}

#endif /* LWIP */
#endif /* NETWORK */
