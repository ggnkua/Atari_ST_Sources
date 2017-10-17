/*
 * File:        nbuf.h
 * Purpose:     Definitions for network buffer management
 *
 * Notes:       These routines implement a network buffer scheme
 */

#ifndef _NBUF_H_
#define _NBUF_H_

/********************************************************************/
/*
 * Include the Queue structure definitions
 */
#include "queue.h"

/*
 * Number of network buffers to use
 */
#define NBUF_MAX    30 // 100

/*
 * Size of each buffer in bytes
 */
#define NBUF_SZ     2048

/*
 * Defines to identify all the buffer queues
 *  - FREE must always be defined as 0
 */
#define NBUF_FREE       0   /* available buffers */
#define NBUF_TX_RING    1   /* buffers in the Tx BD ring */
#define NBUF_RX_RING    2   /* buffers in the Rx BD ring */
#define NBUF_SCRATCH    3   /* misc */
#define NBUF_MAXQ       4   /* total number of queueus */

/* 
 * Buffer Descriptor Format 
 * 
 * Fields:
 * next     Pointer to next node in the queue
 * data     Pointer to the data buffer
 * offset   Index into buffer
 * length   Remaining bytes in buffer from (data + offset)
 */
typedef struct
{
    QNODE node;
    uint8 *data;   
    uint16 offset;
    uint16 length;
} NBUF;

/*
 * Functions to manipulate the network buffers.
 */
int
nbuf_init(void);

void
nbuf_flush(void);

NBUF *
nbuf_alloc (void);

void
nbuf_free(NBUF *);

NBUF *
nbuf_remove(int);

void
nbuf_add(int, NBUF *);

void
nbuf_reset(void);

void
nbuf_debug_dump(void);

/********************************************************************/

#endif  /* _NBUF_H_ */
