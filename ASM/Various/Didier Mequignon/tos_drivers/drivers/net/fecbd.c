/*
 * File:	fecbd.c
 * Purpose: Provide a simple buffer management driver
 *
 * Notes:		
 */

#include <osbind.h>
#include "config.h"
#include "net.h"
#include "../mcdapi/MCD_dma.h"
#include "fecbd.h"
#include "nbuf.h"
#include "eth.h"

extern void ltoa(char *buf, long n, unsigned long base);

#ifdef NETWORK
#ifndef LWIP

/*
 * This implements a simple static buffer descriptor
 * ring for each channel and each direction
 *
 * FEC Buffer Descriptors need to be aligned to a 4-byte boundary.
 * In order to accomplish this, data is over-allocated and manually
 * aligned at runtime
 * 
 * Enough space is allocated for each of the two FEC channels to have 
 * NRXBD Rx BDs and NTXBD Tx BDs
 * 
 */
FECBD unaligned_bds[(2 * NRXBD) + (2 * NTXBD) + 1];

/*
 * These pointers are used to reference into the chunck of data set 
 * aside for buffer descriptors
 */
FECBD *RxBD;
FECBD *TxBD;

/*
 * Macros to easier access to the BD ring
 */
#define RxBD(ch, i)     RxBD[(ch * NRXBD) + i]
#define TxBD(ch, i)     TxBD[(ch * NRXBD) + i]

/* 
 * Buffer descriptor indexes 
 */
static int iTxbd_new;
static int iTxbd_old;
static int iRxbd;

/********************************************************************/
/*
 * Initialize the FEC Buffer Descriptor ring 
 * Buffer Descriptor format is defined by the MCDAPI
 *
 * Parameters:
 *  ch      FEC channel
 */
void
fecbd_init(uint8 ch)
{
    NBUF *nbuf;
    int i;
    
    /* 
     * Align Buffer Descriptors to 4-byte boundary 
     */
    RxBD = (FECBD *)(((int)unaligned_bds + 3) & 0xFFFFFFFC);
    TxBD = (FECBD *)((int)RxBD + (sizeof(FECBD) * 2 * NTXBD));

    /* 
     * Initialize the Rx Buffer Descriptor ring 
     */
    for (i = 0; i < NRXBD; ++i)
    {
        /* Grab a network buffer from the free list */
        nbuf = nbuf_alloc();
//        ASSERT(nbuf);

        /* Initialize the BD */
        RxBD(ch, i).status = RX_BD_E | RX_BD_INTERRUPT;
        RxBD(ch, i).length = RX_BUF_SZ;
        RxBD(ch, i).data =  nbuf->data;

        /* Add the network buffer to the Rx queue */
        nbuf_add(NBUF_RX_RING, nbuf);
    }

    /*
     * Set the WRAP bit on the last one
     */
    RxBD(ch, i-1).status |= RX_BD_W;

    /* 
     * Initialize the Tx Buffer Descriptor ring 
     */
    for (i = 0; i < NTXBD; ++i)
    {
        TxBD(ch, i).status = TX_BD_INTERRUPT;
        TxBD(ch, i).length = 0;
        TxBD(ch, i).data = NULL;
    }

    /*
     * Set the WRAP bit on the last one
     */
    TxBD(ch, i-1).status |= TX_BD_W;

	/* 
     * Initialize the buffer descriptor indexes 
     */
	iTxbd_new = iTxbd_old = iRxbd = 0;
}
/********************************************************************/
void
fecbd_dump(uint8 ch)
{
#ifdef DEBUG_PRINT
    int i;
    char buf[10];
    if(ch == 0)
        Cconws("\r\n------------ FEC0");
    else
        Cconws("\r\n------------ FEC1");
    Cconws(" BDs -----------\r\n");
    Cconws("RxBD Ring\r\n");
    for (i=0; i<NRXBD; i++)
    {
        ltoa(buf, i, 10);
        Cconws(buf);
        Cconws(": BD Addr=0x");
        ltoa(buf, (int)&RxBD(ch,i), 16);
        Cconws(buf);
        Cconws(", Ctrl=0x");
        ltoa(buf, RxBD(ch,i).status, 16);
        Cconws(buf);
        Cconws(", Lgth=");
        ltoa(buf, RxBD(ch,i).length, 10);
        Cconws(buf);
        Cconws(", DataPtr=0x");
        ltoa(buf, (int)RxBD(ch,i).data, 16);
        Cconws(buf);
        Cconws("\r\n");
    }
    Cconws("TxBD Ring\r\n");
    for (i=0; i<NTXBD; i++)
    {
        ltoa(buf, i, 10);
        Cconws(buf);
        Cconws(": BD Addr=0x");
        ltoa(buf, (int)&TxBD(ch,i), 16);
        Cconws(buf);
        Cconws(", Ctrl=0x");
        ltoa(buf, TxBD(ch,i).status, 16);
        Cconws(buf);
        Cconws(", Lgth=");
        ltoa(buf, TxBD(ch,i).length, 10);
        Cconws(buf);
        Cconws(", DataPtr=0x");
        ltoa(buf, (int)TxBD(ch,i).data, 16);
        Cconws(buf);
        Cconws("\r\n");
    }
    Cconws("--------------------------------\r\n\r\n");
#endif
}
/********************************************************************/
/* 
 * Return the address of the first buffer descriptor in the ring.
 *
 * Parameters:
 *  ch          FEC channel
 *  direction   Rx or Tx Macro
 *
 * Return Value:
 *  The start address of the selected Buffer Descriptor ring
 */
uint32
fecbd_get_start(uint8 ch, uint8 direction)
{
	switch (direction)
    {
        case Rx:
            return (uint32)((int)RxBD + (ch * sizeof(FECBD) * NRXBD));
        case Tx:
        default:
            return (uint32)((int)TxBD + (ch * sizeof(FECBD) * NTXBD));
	}
}
/********************************************************************/
FECBD *
fecbd_rx_alloc(uint8 ch)
{
	int i = iRxbd;

	/* Check to see if the ring of BDs is full */
	if (RxBD(ch, i).status & RX_BD_E)
		return NULL;

	/* Increment the circular index */
	iRxbd = (uint8)((iRxbd + 1) % NRXBD);

	return &RxBD(ch, i);
}
/********************************************************************/
/*
 * This function keeps track of the next available Tx BD in the ring
 *
 * Parameters:
 *  ch  FEC channel
 *
 * Return Value:
 *  Pointer to next available buffer descriptor.
 *  NULL if the BD ring is full
 */
FECBD *
fecbd_tx_alloc(uint8 ch)
{
	int i = iTxbd_new;

	/* Check to see if the ring of BDs is full */
	if (TxBD(ch, i).status & TX_BD_R)
		return NULL;

	/* Increment the circular index */
	iTxbd_new = (uint8)((iTxbd_new + 1) % NTXBD);

	return &TxBD(ch, i);
}
/********************************************************************/
/*
 * This function keeps track of the Tx BDs that have already been
 * processed by the FEC
 *
 * Parameters:
 *  ch  FEC channel
 *
 * Return Value:
 *  Pointer to the oldest buffer descriptor that has already been sent
 *  by the FEC, NULL if the BD ring is empty
 */
FECBD *
fecbd_tx_free(uint8 ch)
{
	int i = iTxbd_old;

	/* Check to see if the ring of BDs is empty */
	if ((TxBD(ch, i).data == NULL) || (TxBD(ch, i).status & TX_BD_R))
		return NULL;

	/* Increment the circular index */
	iTxbd_old = (uint8)((iTxbd_old + 1) % NTXBD);

	return &TxBD(ch, i);
}
/********************************************************************/

#endif /* LWIP */
#endif /* NETWORK */
