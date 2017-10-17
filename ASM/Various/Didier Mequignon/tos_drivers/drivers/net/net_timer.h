/*
 * File:        net_timer.h
 * Purpose:     Provide a timer use by the dBUG network as a timeout
 *              indicator
 *
 * Notes:
 */

#ifndef _TIMER_H_
#define _TIMER_H_

#if 0
#define ISR_DBUG_ISR        (0x01)

/********************************************************************/

typedef struct
{
    uint8   ch;         /* which channel is this structure for? */
    uint8   lvl;        /* Interrupt level for this channel */
    uint8   pri;        /* Interrupt priority for this channel */
    uint8   reference;  /* timeout indicator */
    uint32  gms;        /* mode select register value */
    uint16  pre;        /* prescale value */
    uint16  cnt;        /* prescaled clocks for timeout */
} NET_TIMER;

/********************************************************************/

uint32 timer_init(uint8, uint8, uint8);

#endif


uint32 timer_set_secs(uint8 ch, uint32 secs);
uint32 timer_get_reference(uint8 ch);

#if 0
uint32 timer_init(uint8 ch, uint8 lvl, uint8 pri);

/********************************************************************/

/* Vector numbers for all the timer channels */
#define TIMER_VECTOR(x)     (126-x)

/********************************************************************/

#endif

#endif
