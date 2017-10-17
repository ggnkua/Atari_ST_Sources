/*
 * File:	nbuf.c
 * Purpose:	Implementation of network buffer scheme.
 *
 * Notes:	
 */

#include <osbind.h>
#include "config.h"
#include "queue.h"
#include "net.h"

#ifdef NETWORK
#ifndef LWIP

extern void ltoa(char *buf, long n, unsigned long base);

/********************************************************************/
/*
 * Queues used for network buffer storage
 */
QUEUE nbuf_queue[NBUF_MAXQ];

/*
 * Some devices require line-aligned buffers.  In order to accomplish
 * this, the nbuf data is over-allocated and adjusted.  The following
 * array keeps track of the original data pointer returned by malloc
 */
ADDRESS unaligned_buffers[NBUF_MAX];

/********************************************************************/
/*
 * Initialize all the network buffer queues
 *
 * Return Value:
 *  0 success
 *  1 failure
 */
int
nbuf_init(void)
{
    int i;
    NBUF *nbuf;

    for (i=0; i<NBUF_MAXQ; ++i)
    {
        /* Initialize all the queues */
        queue_init(&nbuf_queue[i]);
    }

    for (i=0; i<NBUF_MAX; ++i)
    {
        /* Allocate memory for the network buffer structure */
        nbuf = (NBUF *)Mxalloc(sizeof(NBUF), 3);
        if (!nbuf)
        {
//            ASSERT(nbuf);
            return 1;
        }

        /* Allocate memory for the actual data */
        unaligned_buffers[i] = (ADDRESS)Mxalloc(NBUF_SZ + 16, 3);
        nbuf->data = (uint8 *)((uint32)(unaligned_buffers[i] + 15) & 0xFFFFFFF0);
        if (!nbuf->data)
        {
//            ASSERT(nbuf->data);
            return 1;
        }

        /* Initialize the network buffer */
        nbuf->offset = 0;
        nbuf->length = 0;

        /* Add the network buffer to the free list */
        queue_add(&nbuf_queue[NBUF_FREE], (QNODE *)nbuf);
    }
    
    return 0;
}
/********************************************************************/
/* 
 * Return all the allocated memory to the heap
 */
void
nbuf_flush(void)
{
    NBUF *nbuf;
    int i, level = asm_set_ipl(7);
    int n = 0;

    for (i=0; i<NBUF_MAX; ++i)
        Mfree((uint8*)unaligned_buffers[i]);

    for (i=0; i<NBUF_MAXQ; ++i)
    {
        while ((nbuf = (NBUF *)queue_remove(&nbuf_queue[i])) != NULL)
        {
            Mfree(nbuf);
            ++n;
        }
    }
//    ASSERT(n == NBUF_MAX);
    asm_set_ipl(level);
}
/********************************************************************/
/* 
 * Allocate a network buffer from the free list
 *
 * Return Value:
 *  Pointer to a free network buffer
 *  NULL if none are available
 */
NBUF *
nbuf_alloc(void)
{
    NBUF *nbuf;
    int level = asm_set_ipl(7);

    nbuf = (NBUF *)queue_remove(&nbuf_queue[NBUF_FREE]);
    asm_set_ipl(level);
    return nbuf;
}
/********************************************************************/
/*
 * Add the specified network buffer back to the free list
 *
 * Parameters:
 *  nbuf    Buffer to add back to the free list
 */
void
nbuf_free(NBUF *nbuf)
{
    int level = asm_set_ipl(7);

    nbuf->offset = 0;
    nbuf->length = NBUF_SZ;
    queue_add(&nbuf_queue[NBUF_FREE],(QNODE *)nbuf);

    asm_set_ipl(level);
}
/********************************************************************/
/*
 * Remove a network buffer from the specified queue
 *
 * Parameters:
 *  q   The index that identifies the queue to pull the buffer from
 */
NBUF *
nbuf_remove(int q)
{
    NBUF *nbuf;
    int level = asm_set_ipl(7);

    nbuf = (NBUF *)queue_remove(&nbuf_queue[q]);
    asm_set_ipl(level);
    return nbuf;
}
/********************************************************************/
/*
 * Add a network buffer to the specified queue
 *
 * Parameters:
 *  q   The index that identifies the queue to add the buffer to
 */
void
nbuf_add(int q, NBUF *nbuf)
{
    int level = asm_set_ipl(7);
    queue_add(&nbuf_queue[q],(QNODE *)nbuf);
    asm_set_ipl(level);
}
/********************************************************************/
/*
 * Put all the network buffers back into the free list 
 */
void
nbuf_reset(void)
{
    NBUF *nbuf;
    int i, level = asm_set_ipl(7);

    for (i=1; i<NBUF_MAXQ; ++i)
    {
        while ((nbuf = nbuf_remove(i)) != NULL)
            nbuf_free(nbuf);
    }
    asm_set_ipl(level);
}
/********************************************************************/
/*
 * Display all the nbuf queues
 */
void
nbuf_debug_dump(void)
{
#ifdef DEBUG_PRINT
    NBUF *nbuf;
    int i, j, level;
    
    level = asm_set_ipl(7);

    for (i=0; i<NBUF_MAXQ; ++i)
    {
        char buf[10];
        Cconws("\r\nQueue ");
        ltoa(buf, i, 10);
        Cconws(buf);
        Cconws("\tBuffer Location\tOffset\tLength\r\n");
        Cconws("---------------------------------------------\r\n");
        j = 0;
        nbuf = (NBUF *)queue_peek(&nbuf_queue[i]);
        while (nbuf != NULL)
        {
           Cconws("       \t");
           ltoa(buf, j++, 10);
           Cconws(buf);
           Cconws("\t  0x");
           ltoa(buf, (int)nbuf->data, 16);
           Cconws(buf);
           Cconws("\t0x");
           ltoa(buf, nbuf->offset, 16);
           Cconws(buf);
           Cconws("\t0x");
           ltoa(buf, nbuf->length, 16);
           Cconws(buf);
           Cconws("\r\n");
           nbuf = (NBUF *)nbuf->node.next;
        }
    }

    asm_set_ipl(level);
#endif
}
/********************************************************************/

#endif /* LWIP */
#endif /* NETWORK */
