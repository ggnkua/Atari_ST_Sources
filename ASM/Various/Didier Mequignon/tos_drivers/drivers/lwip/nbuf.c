/*
 * Network buffer code based on the MCF523x examples from Freescale.
 *
 */

/* ------------------------ Platform includes ----------------------------- */
#include "config.h"
#include "net.h"
#ifdef MCF5445X
#include "mcf5445x.h"
#include "../../include/fire.h"
#else
#include "mcf548x.h"
#endif

/* ------------------------ lwIP includes --------------------------------- */

#include "mem.h"

#ifdef NETWORK
#ifdef LWIP

/* ------------------------ Static variables ------------------------------ */

#undef DEBUG

/*
 * This implements a simple static buffer descriptor
 * ring for each channel and each direction
 *
 * FEC Buffer Descriptors need to be aligned to a 4-byte boundary.
 * In order to accomplish this, data is over-allocated and manually
 * aligned at runtime
 * 
 * Enough space is allocated for each of the two FEC channels to have 
 * NUM_RXBDS Rx BDs and NUM_TXBDS Tx BDs
 * 
 */

#ifdef MCF5445X
nbuf_t *unaligned_bds = (nbuf_t *)(RAM_BASE_FEC);
#else /* MCF548X */
nbuf_t *unaligned_bds = (nbuf_t *)(__MBAR+0x13000);
// nbuf_t unaligned_bds[(2 * NUM_RXBDS) + (2 * NUM_TXBDS) + 1];
#endif

/*
 * These pointers are used to reference into the chunck of data set 
 * aside for buffer descriptors
 */
nbuf_t *RxBD;
nbuf_t *TxBD;

/* Macros to easier access to the BD ring */
#define RxBD(ch, i) RxBD[(ch * NUM_RXBDS) + i]
#define TxBD(ch, i) TxBD[(ch * NUM_TXBDS) + i]

/* Buffer descriptor indexes */
static uint8 rx_bd_idx[2];
static uint8 tx_bd_idx[2];
static uint8 tx_bd_idx_old[2];

/* Data Buffers */
uint8 *unaligned_tx_buffers[NUM_TXBDS * 2];
uint8 *unaligned_rx_buffers[NUM_RXBDS * 2];

/* ------------------------ Start implementation -------------------------- */
#ifdef DEBUG
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

int nbuf_init(uint8 ch)
{
  int i, j;
  ch &= 1;
#ifdef NBUF_USE_SYSTEM_RAM
  uint8 * free_mem = (uint8 *)((int)unaligned_bds + (sizeof(nbuf_t) * ((2 * NUM_RXBDS) + (2 * NUM_TXBDS) + 1)));
#endif
  /* Align Buffer Descriptors to 4-byte boundary */
  RxBD = (nbuf_t *)(((int)unaligned_bds + 3) & 0xFFFFFFFC);
  TxBD = (nbuf_t *)((int)RxBD + (sizeof(nbuf_t) * 2 * NUM_RXBDS));
  /* Initialize the Rx Buffer Descriptor ring */
  j = NUM_RXBDS * (int)ch;
#ifdef NBUF_USE_SYSTEM_RAM
  if(ch)
    free_mem += (RX_BUFFER_SIZE + 16) * NUM_RXBDS;    
#endif
  for(i = 0; i < NUM_RXBDS; i++, j++)
  {
    /* Initialize the BD */
#ifdef MCF5445X
    RxBD(ch, i).status = RX_BD_E;
    RxBD(ch, i).length = 0;
#else /* MCF548X */
    RxBD(ch, i).status = RX_BD_E | RX_BD_INTERRUPT;
    RxBD(ch, i).length = RX_BUFFER_SIZE;
#endif
#ifndef NBUF_USE_SYSTEM_RAM
    unaligned_rx_buffers[j] = (uint8 *)mem_malloc(RX_BUFFER_SIZE + 16);
#else
    unaligned_rx_buffers[j] = free_mem;
    free_mem += (RX_BUFFER_SIZE + 16);
#endif
    RxBD(ch, i).data = (uint8 *)((uint32)(unaligned_rx_buffers[j] + 15) & 0xFFFFFFF0);
    if(!RxBD(ch, i).data)
      return(1);
  }
  /* Set the WRAP bit on the last one */
  RxBD(ch, i-1).status |= RX_BD_W;
  /* Initialize the Tx Buffer Descriptor ring */
  j = NUM_TXBDS * (int)ch;
#ifdef NBUF_USE_SYSTEM_RAM
  if(ch)
    free_mem += (TX_BUFFER_SIZE + 16) * NUM_TXBDS;  
  else
    free_mem += (RX_BUFFER_SIZE + 16) * NUM_RXBDS;    
#endif
  for(i = 0; i < NUM_TXBDS; i++, j++)
  {
#ifdef MCF5445X
    TxBD(ch, i).status = TX_BD_L | TX_BD_TC;
#else /* MCF548X */
    TxBD(ch, i).status = TX_BD_INTERRUPT;
#endif
    TxBD(ch, i).length = 0;
#ifndef NBUF_USE_SYSTEM_RAM
    unaligned_tx_buffers[j] = (uint8 *)mem_malloc(TX_BUFFER_SIZE + 16);
#else
    unaligned_tx_buffers[j] = free_mem;
    free_mem += (TX_BUFFER_SIZE + 16);
#endif
    TxBD(ch, i).data = (uint8 *)((uint32)(unaligned_tx_buffers[j] + 15) & 0xFFFFFFF0);
    if(!TxBD(ch, i).data)
      return(1);
  }
  /* Set the WRAP bit on the last one */
  TxBD(ch, i-1).status |= TX_BD_W;
  /* Initialize the buffer descriptor indexes */
  for(i = 0; i < 2; tx_bd_idx_old[i] = tx_bd_idx[i] = rx_bd_idx[i] = 0, i++);
  return(0);
}

void nbuf_flush(uint8 ch)
{
#ifdef NBUF_USE_SYSTEM_RAM
  if(ch);
#else
  int i, j;
  j = NUM_RXBDS * ch;
  for(i = 0; i < NUM_RXBDS; i++, j++)
  {
    if(unaligned_rx_buffers[j])
      mem_free(unaligned_rx_buffers[j]);
  }
  j = NUM_TXBDS * ch;
  for(i = 0; i < NUM_TXBDS; i++, j++)
  {
    if(unaligned_tx_buffers[j])
      mem_free(unaligned_tx_buffers[j]);
  }
#endif
}

uint32 nbuf_get_start(uint8 ch, uint8 direction)
{
  /* Return the address of the first buffer descriptor in the ring.
     This routine is needed by the FEC of the MPC860T , MCF5282, and MCF523x
     in order to write the Rx/Tx descriptor ring start registers */
  switch(direction)
  {
    case NBUF_RX: return (uint32)((int)RxBD + (ch * sizeof(nbuf_t) * NUM_RXBDS));
    case NBUF_TX:
    default: return (uint32)((int)TxBD + (ch * sizeof(nbuf_t) * NUM_TXBDS));
  }  
}

nbuf_t *nbuf_rx_allocate(uint8 ch)
{
  /* Return a pointer to the next empty Rx Buffer Descriptor */
  int i = rx_bd_idx[ch];
  /* Check to see if the ring of BDs is full */
#ifdef DEBUG
  int status =  RxBD(ch, i).status;
  conws_debug("alloc RxBD(");
  hex_byte((char)ch);
  conws_debug(", ");
  hex_byte((char)i);
  conws_debug(") = ");
  hex_byte((char)((long)(status) >> 8));
  hex_byte((char)((long)(status)));
  conws_debug("\r\n");
#endif  
  if(RxBD(ch, i).status & RX_BD_E)
    return NULL;
  /* increment the circular index */
  rx_bd_idx[ch] = (uint8)((rx_bd_idx[ch] + 1) % NUM_RXBDS);
  return(&RxBD(ch, i));
}

nbuf_t *nbuf_tx_allocate(uint8 ch)
{
  /* Return a pointer to the next empty Tx Buffer Descriptor */
  int i = tx_bd_idx[ch];
  /* Check to see if the ring of BDs is full */
#ifdef DEBUG
  int status =  TxBD(ch, i).status;
  conws_debug("alloc TxBD(");
  hex_byte((char)ch);
  conws_debug(", ");
  hex_byte((char)i);
  conws_debug(") = ");
  hex_byte((char)((long)(status) >> 8));
  hex_byte((char)((long)(status)));
  conws_debug("\r\n");
#endif  
  if(TxBD(ch, i).status & TX_BD_R)
    return NULL;
  /* increment the circular index */
  tx_bd_idx[ch] = (uint8)((tx_bd_idx[ch] + 1) % NUM_TXBDS);
  return(&TxBD(ch, i));
}

nbuf_t *nbuf_tx_free(uint8 ch)
{
  int i = tx_bd_idx_old[ch];
#ifdef DEBUG
  int status =  TxBD(ch, i).status;
  conws_debug("free TxBD(");
  hex_byte((char)ch);
  conws_debug(", ");
  hex_byte((char)i);
  conws_debug(") = ");
  hex_byte((char)((long)(status) >> 8));
  hex_byte((char)((long)(status)));
  conws_debug("\r\n");
#endif  
  /* Check to see if the ring of BDs is empty */
  if((TxBD(ch, i).data == NULL) || (TxBD(ch, i).status & TX_BD_R))
    return NULL;
  /* Increment the circular index */
  tx_bd_idx_old[ch] = (uint8)((tx_bd_idx_old[ch] + 1) % NUM_TXBDS);
  return &TxBD(ch, i);
}

#endif /* LWIP */
#endif /* NETWORK */
