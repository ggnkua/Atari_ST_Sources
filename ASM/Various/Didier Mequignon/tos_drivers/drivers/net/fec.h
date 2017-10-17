/*
 * File:    fec.h
 * Purpose: Driver for the Fast Ethernet Controller (FEC)
 *
 * Notes:       
 */

#ifndef _FEC_H_
#define _FEC_H_

/********************************************************************/
/* MII Speed Settings */
#define FEC_MII_10BASE_T        0
#define FEC_MII_100BASE_TX      1

/* MII Duplex Settings */
#define FEC_MII_HALF_DUPLEX     0
#define FEC_MII_FULL_DUPLEX     1

/* Timeout for MII communications */
#define FEC_MII_TIMEOUT         0x10000

/* External Interface Modes */
#define FEC_MODE_7WIRE          0
#define FEC_MODE_MII            1
#define FEC_MODE_LOOPBACK       2   /* Internal Loopback */

/*
 * FEC Event Log
 */
typedef struct {
    int errors;     /* total count of errors   */
    int hberr;      /* heartbeat error         */
    int babr;       /* babbling receiver       */
    int babt;       /* babbling transmitter    */
    int gra;        /* graceful stop complete  */
    int txf;        /* transmit frame          */
    int mii;        /* MII                     */
    int lc;         /* late collision          */
    int rl;         /* collision retry limit   */
    int xfun;       /* transmit FIFO underrrun */
    int xferr;      /* transmit FIFO error     */
    int rferr;      /* receive FIFO error      */
    int dtxf;       /* DMA transmit frame      */
    int drxf;       /* DMA receive frame       */
    int rfsw_inv;   /* Invalid bit in RFSW     */
    int rfsw_l;     /* RFSW Last in Frame      */
    int rfsw_m;     /* RFSW Miss               */
    int rfsw_bc;    /* RFSW Broadcast          */
    int rfsw_mc;    /* RFSW Multicast          */
    int rfsw_lg;    /* RFSW Length Violation   */
    int rfsw_no;    /* RFSW Non-octet          */
    int rfsw_cr;    /* RFSW Bad CRC            */
    int rfsw_ov;    /* RFSW Overflow           */
    int rfsw_tr;    /* RFSW Truncated          */
} FEC_EVENT_LOG;


int 
fec_mii_write(uint8 , uint8 , uint8 , uint16 );

int 
fec_mii_read(uint8 , uint8 , uint8 , uint16 *);

void
fec_mii_init(uint8, uint32);

void
fec_mib_init(uint8);

void
fec_mib_dump(uint8);

void
fec_log_init(uint8);

void
fec_log_dump(uint8);

void
fec_reg_dump(uint8);

void
fec_duplex (uint8, uint8);

uint8
fec_hash_address(const uint8 *);

void
fec_set_address (uint8 ch, const uint8 *);

void
fec_reset (uint8);

void
fec_init (uint8, uint8, uint8, const uint8 *);

void
fec_rx_start(uint8, int8 *, uint8);

void
fec_rx_continue(uint8);

void
fec_rx_restart(uint8);

void
fec_rx_stop (uint8);

void
fec_rx_frame(uint8, NIF *);

void
fec0_rx_frame(void);

void
fec1_rx_frame(void);

void
fec_tx_start(uint8, int8 *, uint8);

void
fec_tx_continue(uint8);

void
fec_tx_restart(uint8);

void
fec_tx_stop (uint8);

void
fec_tx_frame(uint8);

void
fec0_tx_frame(void);

void
fec1_tx_frame(void);

int
fec_send (uint8 , uint8 *, uint8 *, uint16 , NBUF *);

int
fec0_send(uint8 *, uint8 *, uint16 , NBUF *);

int
fec1_send(uint8 *, uint8 *, uint16 , NBUF *);

void
fec_irq_handler(uint8 ch);

void
fec_irq_enable(uint8, uint8, uint8);

void
fec_irq_disable(uint8);

int
fec_eth_start(uint8, uint8, uint8, uint8, uint8 *, int, 
              uint8, uint8, uint8, uint8, uint8);

void
fec_eth_stop(uint8);

/********************************************************************/

#endif /* _FEC_H_ */
