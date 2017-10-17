/*
 * Network buffer code based on the MCF548x examples from Freescale.
 *
 * Freescale explicitly grants the redistribution and modification
 * of these source files. The complete licensing information is
 * available in the file LICENSE_FREESCALE.TXT.
 *
 */

#ifndef _NBUF_H
#define _NBUF_H

#define NBUF_USE_SYSTEM_RAM

/* ------------------------ Defines --------------------------------------- */
#define NBUF_RX                 (1)
#define NBUF_TX                 (0)

#define RX_BUFFER_SIZE          (2048)
#define TX_BUFFER_SIZE          (1520)

/* Number of Receive and Transmit Buffers and Buffer Descriptors */
#ifdef NBUF_USE_SYSTEM_RAM
#ifdef MCF5445X
#define NUM_RXBDS               (2)
#define NUM_TXBDS               (2)
#else /* MCF548X */
#define NUM_RXBDS               (2)
#define NUM_TXBDS               (2)
#endif
#else
#define NUM_RXBDS               (20)
#define NUM_TXBDS               (20)
#endif

/* ------------------------ Defines ( Buffer Descriptor Flags )------------ */
/*
 * Bit level definitions for status field of buffer descriptors
 */
#define TX_BD_R			0x8000
#define TX_BD_TO1		0x4000
#define TX_BD_W			0x2000
#define TX_BD_TO2		0x1000
#define TX_BD_INTERRUPT 0x1000  /* MCF547x/8x Only */
#define TX_BD_L			0x0800
#define TX_BD_TC		0x0400
#define TX_BD_DEF		0x0200  /* MCF5272 Only */
#define TX_BD_ABC		0x0200
#define TX_BD_HB		0x0100  /* MCF5272 Only */
#define TX_BD_LC		0x0080  /* MCF5272 Only */
#define TX_BD_RL		0x0040  /* MCF5272 Only */
#define TX_BD_UN		0x0002  /* MCF5272 Only */
#define TX_BD_CSL		0x0001  /* MCF5272 Only */

#define RX_BD_E			0x8000
#define RX_BD_R01		0x4000
#define RX_BD_W			0x2000
#define RX_BD_R02		0x1000
#define RX_BD_INTERRUPT 0x1000  /* MCF547x/8x Only */
#define RX_BD_L			0x0800
#define RX_BD_M			0x0100
#define RX_BD_BC		0x0080
#define RX_BD_MC		0x0040
#define RX_BD_LG		0x0020
#define RX_BD_NO		0x0010
#define RX_BD_CR		0x0004
#define RX_BD_OV		0x0002
#define RX_BD_TR		0x0001
#define RX_BD_ERROR     (RX_BD_NO | RX_BD_CR | RX_BD_OV | RX_BD_TR)

/*
 * The following defines are provided by the MCF547x/8x 
 * DMA API.  These are shown here to show their correlation
 * to the other FEC buffer descriptor status bits
 * 
 * #define MCD_FEC_BUF_READY   0x8000
 * #define MCD_FEC_WRAP        0x2000
 * #define MCD_FEC_INTERRUPT   0x1000
 * #define MCD_FEC_END_FRAME   0x0800
 */

/* ------------------------ Type definitions ------------------------------ */
typedef struct
{
	uint16 status;     /* control and status */
	uint16 length;     /* transfer length */
	uint8 *data;       /* buffer address */
} nbuf_t;

/* ------------------------ Prototypes ------------------------------------ */

int nbuf_init(uint8 ch);
void nbuf_flush(uint8 ch);
uint32 nbuf_get_start(uint8 ch, uint8 direction);
nbuf_t *nbuf_rx_allocate(uint8 ch);
nbuf_t *nbuf_tx_allocate(uint8 ch);
nbuf_t *nbuf_tx_free(uint8 ch);
void nbuf_rx_release(nbuf_t *);
void nbuf_tx_release(nbuf_t *);
int nbuf_rx_next_ready(void);

#endif
