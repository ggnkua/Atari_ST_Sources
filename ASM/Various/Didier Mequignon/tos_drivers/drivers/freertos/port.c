/*
    FreeRTOS V4.1.1 - Copyright (C) 2003-2006 Richard Barry.
    MCF548x Port - Copyright (C) 2008 Didier Mequignon.

    This file is part of the FreeRTOS distribution.

    FreeRTOS is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    FreeRTOS is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FreeRTOS; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    A special exception to the GPL can be applied should you wish to distribute
    a combined work that includes FreeRTOS, without being obliged to provide
    the source code for any proprietary components.  See the licensing section
    of http://www.FreeRTOS.org for full details of how and when the exception
    can be applied.

    ***************************************************************************
    See http://www.FreeRTOS.org for documentation, latest information, license
    and contact details.  Please ensure to read the configuration and relevant
    port sections of the online documentation.
    ***************************************************************************
*/

#include "config.h"
#include "FreeRTOS.h"
#include "FreeRTOSConfig.h"
#include "task.h"
#include "portmacro.h"
#include "../../include/ramcf68k.h"

#include "../lwip/perf.h"

typedef volatile unsigned long vuint32;
typedef volatile unsigned short vuint16;
typedef volatile unsigned char vuint8;

#ifdef MCF5445X
#include "mcf5445x.h"
#else /* MCF548X */
#include "mcf548x.h"
extern unsigned char __MBAR[];
#endif

#ifdef NETWORK
#ifdef LWIP

/* ------------------------ Defines --------------------------------------- */
#ifdef MCF5445X
#define SYSTEM_CLOCK                    133 // system bus frequency in MHz
#define portVECTOR_TIMER                ( 64 + INT0_HI_DTMR2 )
#else /* MCF548X */
#ifdef MCF547X
#define SYSTEM_CLOCK                    133 // system bus frequency in MHz
#else /* MCF548X */
#define SYSTEM_CLOCK                    100 // system bus frequency in MHz
#endif /* MCF547X */
#define portVECTOR_TIMER                ( 64 + 54 )
#endif
#define portVECTOR_SYSCALL              ( 32 + portTRAP_YIELD )

#define portNO_CRITICAL_NESTING         ( ( unsigned portLONG ) 0 )
#define portINITIAL_CRITICAL_NESTING    ( ( unsigned portLONG ) 10 )

/* ------------------------ Static variables ------------------------------ */
volatile unsigned portLONG              ulCriticalNesting;
static unsigned portLONG                portIntCounter;

/* ------------------------ Static functions ------------------------------ */
#if configUSE_PREEMPTION == 0
static void prvPortPreemptiveTick ( void ) __attribute__ ((interrupt_handler));
#else
static void prvPortPreemptiveTick ( void );
#endif

/* ------------------------ Start implementation -------------------------- */
#if( HAVE_USP == 1 )
portSTACK_TYPE *pxPortInitialiseStack( portSTACK_TYPE * pxTopOfStack, pdTASK_CODE pxCode,
 void *pvParameters, portSTACK_TYPE * pxContext, unsigned portBASE_TYPE uxSuper,  portSTACK_TYPE * pxTopOfUserStack, unsigned portBASE_TYPE uxMaskIntLevel )
#else
portSTACK_TYPE *pxPortInitialiseStack( portSTACK_TYPE * pxTopOfStack, pdTASK_CODE pxCode,
 void *pvParameters, portSTACK_TYPE * pxContext, unsigned portBASE_TYPE uxMaskIntLevel )
#endif
{
#if( HAVE_USP == 1 )
    if(uxSuper)
    {
#endif
        /* Place the parameter on the stack in the expected location. */
        *pxTopOfStack = ( portSTACK_TYPE ) pvParameters;
        pxTopOfStack--;

        /* Place dummy return address on stack. Tasks should never terminate so
         * we can set this to anything. */
        *pxTopOfStack = ( portSTACK_TYPE ) 0xDEADDEAC;
        pxTopOfStack--;
#if( HAVE_USP == 1 )
    }
    else
    {
        /* Place the parameter on the stack in the expected location. */
        *pxTopOfUserStack = ( portSTACK_TYPE ) pvParameters;
        pxTopOfUserStack--;    

        /* Place dummy return address on stack. Tasks should never terminate so
         * we can set this to anything. */
        *pxTopOfUserStack = ( portSTACK_TYPE ) 0xDEADDEAC;
    }
#endif

    /* Create a Motorola Coldfire exception stack frame. First comes the return
     * address. */
    *pxTopOfStack = ( portSTACK_TYPE ) pxCode;
    pxTopOfStack--;

    /* Format, fault-status, vector number for exception stack frame */
#if( HAVE_USP == 1 )
    if(uxSuper)
#endif
        *pxTopOfStack = 0x40002000UL | (portVECTOR_SYSCALL << 18) | ((uxMaskIntLevel & 7) << 8);
#if( HAVE_USP == 1 )
    else
        *pxTopOfStack = 0x40000000UL | (portVECTOR_SYSCALL << 18) | ((uxMaskIntLevel & 7) << 8);
#endif

    *pxContext++ = ( portSTACK_TYPE ) 0xD0;    /* D0 */
    *pxContext++ = ( portSTACK_TYPE ) 0xD1;    /* D1 */
    *pxContext++ = ( portSTACK_TYPE ) 0xD2;    /* D2 */
    *pxContext++ = ( portSTACK_TYPE ) 0xD3;    /* D3 */
    *pxContext++ = ( portSTACK_TYPE ) 0xD4;    /* D4 */
    *pxContext++ = ( portSTACK_TYPE ) 0xD5;    /* D5 */
    *pxContext++ = ( portSTACK_TYPE ) 0xD6;    /* D6 */
    *pxContext++ = ( portSTACK_TYPE ) 0xD7;    /* D7 */
    *pxContext++ = ( portSTACK_TYPE ) 0xA0;    /* A0 */
    *pxContext++ = ( portSTACK_TYPE ) 0xA1;    /* A1 */
    *pxContext++ = ( portSTACK_TYPE ) 0xA2;    /* A2 */
    *pxContext++ = ( portSTACK_TYPE ) 0xA3;    /* A3 */
    *pxContext++ = ( portSTACK_TYPE ) 0xA4;    /* A4 */
    *pxContext++ = ( portSTACK_TYPE ) 0xA5;    /* A5 */
    *pxContext++ = ( portSTACK_TYPE ) 0xA6;    /* A6 */
#if( HAVE_USP == 1 )
    if(uxSuper)
#endif
        *pxContext++ = ( portSTACK_TYPE ) (pxTopOfStack+3);   /* A7/USP just for info */
#if( HAVE_USP == 1 )
    else
        *pxContext++ = ( portSTACK_TYPE ) (pxTopOfUserStack); /* A7/USP */
#endif
    
#if( SAVE_FPU == 1 )
    *pxContext++ = ( portSTACK_TYPE ) 0x05000000; /* FSAVE IDLE state */
    *pxContext++ = ( portSTACK_TYPE ) 0x00;
    *pxContext++ = ( portSTACK_TYPE ) 0x00;
    *pxContext++ = ( portSTACK_TYPE ) 0x00;
    *pxContext++ = ( portSTACK_TYPE ) 0xFA;    /* FPIAR */
    *pxContext++ = ( portSTACK_TYPE ) 0x00;    /* FP0 */
    *pxContext++ = ( portSTACK_TYPE ) 0xF0;    /* FP0 */
    *pxContext++ = ( portSTACK_TYPE ) 0x00;    /* FP1 */
    *pxContext++ = ( portSTACK_TYPE ) 0xF1;    /* FP1 */
    *pxContext++ = ( portSTACK_TYPE ) 0x00;    /* FP2 */
    *pxContext++ = ( portSTACK_TYPE ) 0xF2;    /* FP2 */
    *pxContext++ = ( portSTACK_TYPE ) 0x00;    /* FP3 */
    *pxContext++ = ( portSTACK_TYPE ) 0xF3;    /* FP3 */
    *pxContext++ = ( portSTACK_TYPE ) 0x00;    /* FP4 */
    *pxContext++ = ( portSTACK_TYPE ) 0xF4;    /* FP4 */
    *pxContext++ = ( portSTACK_TYPE ) 0x00;    /* FP5 */
    *pxContext++ = ( portSTACK_TYPE ) 0xF5;    /* FP5 */
    *pxContext++ = ( portSTACK_TYPE ) 0x00;    /* FP6 */
    *pxContext++ = ( portSTACK_TYPE ) 0xF6;    /* FP6 */
    *pxContext++ = ( portSTACK_TYPE ) 0x00;    /* FP7 */
    *pxContext++ = ( portSTACK_TYPE ) 0xF7;    /* FP7 */
#endif

    /* Set the initial critical section nesting counter to zero. This value
     * is used to restore the value of ulCriticalNesting. */
    *pxContext++ = 0;
    
    return pxTopOfStack;
}

extern long pxCurrentTCB, tid_TOS;
extern volatile portTickType xTickCount;
#ifdef MCF5445X
unsigned long save_imrl0, save_imrl0_tos, save_imrh0, save_imrh0_tos, save_imrh1, save_imrh1_tos;
#else
unsigned long save_imrl, save_imrl_tos, save_imrh, save_imrh_tos;
extern void set_intfrcl(unsigned long mask);
extern void clr_intfrcl(unsigned long mask);
#endif

void
portSaveRestoreInt( int iSave )
{
    if( iSave )
    {
//        PERF_START_INT;
#ifdef MCF5445X
        if( pxCurrentTCB == tid_TOS )
        {
            save_imrl0_tos = MCF_INTC_IMRL0;
            save_imrh0_tos = MCF_INTC_IMRH0;
            save_imrh1_tos = MCF_INTC_IMRH1;
        }
        else
        {
            save_imrl0 = MCF_INTC_IMRL0;
            save_imrh0 = MCF_INTC_IMRH0;
            save_imrh1 = MCF_INTC_IMRH1;
        }
#else /* MCF548X */
        if( pxCurrentTCB == tid_TOS )
        {
            save_imrl_tos = MCF_INTC_IMRL;
            save_imrh_tos = MCF_INTC_IMRH;
        }
        else
        {
            save_imrl = MCF_INTC_IMRL;
            save_imrh = MCF_INTC_IMRH;
        }
#endif /* MCF5445X */
    }
    else
    {
#define _timer_ms 0x442
#define _hz_200   0x4BA
#ifdef MCF5445X
        if( pxCurrentTCB == tid_TOS )
        {
            MCF_INTC_IMRL0 = save_imrl0_tos & save_imrl0;
            MCF_INTC_IMRH0 = save_imrh0_tos & save_imrh0;
            MCF_INTC_IMRH1 = save_imrh1_tos & save_imrh1;
            if( *(unsigned short *)_timer_ms
             && *(unsigned long *)_hz_200 < (unsigned long)xTickCount )
            {
                MCF_INTC_INTFRCL0 |= INTC_INTFRCL_INTFRC6; /* force INT 6 */
                portIntCounter++;
                if(portIntCounter >= (configTICK_RATE_HZ / 50) )
                {
                   portIntCounter = 0;
                   MCF_INTC_INTFRCL0 |= INTC_INTFRCL_INTFRC6; /* force INT 4 */
                }
            }
        }
        else
        {
            MCF_INTC_IMRL0 = save_imrl0;
            MCF_INTC_IMRH0 = save_imrh0;
            MCF_INTC_IMRH1 = save_imrh1;
            MCF_INTC_INTFRCL0 &= ~(INTC_INTFRCL_INTFRC4 | INTC_INTFRCL_INTFRC6);
        }
#else /* MCF548X */
        if( pxCurrentTCB == tid_TOS )
        {
            MCF_INTC_IMRL = save_imrl_tos & save_imrl;
            MCF_INTC_IMRH = save_imrh_tos & save_imrh;
            if(*(unsigned short *)_timer_ms
             && *(unsigned long *)_hz_200 < (unsigned long)xTickCount )
            {
#ifndef MCF547X /* because INT7 is used on MCF5484LITE for PCI */
                set_intfrcl(MCF_INTC_INTFRCL_INTFRC6); // same cycle
#else
                MCF_INTC_INTFRCL |= MCF_INTC_INTFRCL_INTFRC6; /* force INT 6 */
#endif /* MCF547X */
                portIntCounter++;
                if(portIntCounter >= (configTICK_RATE_HZ / 50) )
                {
                    portIntCounter = 0;
#ifndef MCF547X /* because INT7 is used on MCF5484LITE for PCI */
                    set_intfrcl(MCF_INTC_INTFRCL_INTFRC4); // same cycle
#else
                    MCF_INTC_INTFRCL |= MCF_INTC_INTFRCL_INTFRC4; /* force INT 4 */
#endif /* MCF547X */
                }
            }
        }
        else
        {
            MCF_INTC_IMRL = save_imrl;
            MCF_INTC_IMRH = save_imrh;
#ifndef MCF547X /* because INT7 is used on MCF5484LITE for PCI */
            clr_intfrcl(~(MCF_INTC_INTFRCL_INTFRC4 | MCF_INTC_INTFRCL_INTFRC6)); // same cycle          
#else
            MCF_INTC_INTFRCL &= ~(MCF_INTC_INTFRCL_INTFRC4 | MCF_INTC_INTFRCL_INTFRC6);
#endif /* MCF547X */
        }
#endif /* MCF5445X */
//        PERF_STOP_INT("inter");
    }
}

/*
 * Called by portYIELD() or taskYIELD() to manually force a context switch.
 */
static void
prvPortYield( void )
{
#if (__GNUC__ <= 3)
    asm volatile (".chip 68060\n\t");
#endif
    asm volatile (" move.w #0x2700, sr\n\t");
#if _GCC_USES_FP == 1
    asm volatile (" unlk fp\n\t");
#endif
    asm volatile (" move.l d0, -(sp)\n\t"); 
    asm volatile (" move.l a0, -(sp)\n\t"); 
    asm volatile (" move.l usp, a0\n\t");
    asm volatile (" btst #5, 10(sp)\n\t");   // call in supervisor state
    asm volatile (" beq.s .user\n\t" );
    asm volatile (" move.b 8(sp), d0\r\n");  // get SP alignment bits from A7 stack frame
    asm volatile (" lsr.l #4, d0\n\t");
    asm volatile (" and.l #3, d0\n\t");
    asm volatile (" addq.l #8, d0\n\t");
    asm volatile (" addq.l #8, d0\n\t");
    asm volatile (" add.l sp, d0\n\t");
    asm volatile (" move.l d0, a0\n\t");
    asm volatile (".user:\n\t" );
    asm volatile (" moveq #0, d0\n\t");
    asm volatile (" move.w (a0), d0\n\t");
    asm volatile (" cmp.l #0xFE, d0\n\t");   // function
    asm volatile (" beq .set_ipl\n\t" );
    asm volatile (" cmp.l #0xFF, d0\n\t");   // function
    asm volatile (" beq .yield\n\t" );
    asm volatile (" move.l (sp)+, a0\n\t"); 
    asm volatile (" addq.l #4, sp\n\t"); 
    asm volatile (" moveq #-1, d0\n\t"); 
    asm volatile (" rte\n\t");
    asm volatile (".set_ipl:\n\t");
    asm volatile (" move.l d6, -(sp)\n\t"); 
    asm volatile (" move.l d7, -(sp)\n\t"); 
    asm volatile (" move.w 18(sp), d7\n\t"); // current SR
    asm volatile (" move.l d7, d0\n\t");     // prepare return value
    asm volatile (" and.l #0x700, d0\n\t");  // mask out IPL
    asm volatile (" lsr.l #8, d0\n\t");      // IPL
    asm volatile (" move.l 2(a0), d6\n\t");  // get argument
    asm volatile (" and.l #7, d6\n\t");      // least significant three bits
    asm volatile (" lsl.l #8, d6\n\t");      // move over to make mask
    asm volatile (" and.l #0xF8FF, d7\n\t"); // zero out current IPL
    asm volatile (" or.l d6, d7\n\t");       // place new IPL in SR
    asm volatile (" move.w d7, 18(sp)\n\t");
    asm volatile (" move.l (sp)+, d7\n\t");
    asm volatile (" move.l (sp)+, d6\n\t"); 
    asm volatile (" move.l (sp)+, a0\n\t");
    asm volatile (" addq.l #4, sp\n\t"); 
    asm volatile (" rte\n\t");;    
    asm volatile (".yield:\n\t");
    asm volatile (" move.l (sp)+, a0\n\t"); 
    asm volatile (" move.l (sp)+, d0\n\t"); 
     /* Perform the context switch.  First save the context of the current task. */
    portSAVE_CONTEXT(  );
    /* Find the highest priority task that is ready to run. */
    vTaskSwitchContext(  );
    /* Restore the context of the new task. */
    portRESTORE_CONTEXT(  );
}

void portYIELD(void)
{
    asm volatile (
                  " move.w #0xFF, -(sp)\n\t"
                  " trap %0\n\t"
                  " addq.l #2, sp" : : "i" (portTRAP_YIELD) : "d0", "d1", "a0", "a1", "memory", "cc" );
}

int vPortSetIPL( unsigned long int uiNewIPL )
{
#if 0 // ugly hack fixed by using portOldIPLTOS
    portSTACK_TYPE *p = (portSTACK_TYPE *) pxCurrentTCB;
    unsigned portBASE_TYPE uxStartIntLevel = (unsigned portBASE_TYPE) p[65];
    if(( pxCurrentTCB != tid_TOS ) && ( (unsigned portBASE_TYPE) uiNewIPL < uxStartIntLevel ) )
        uiNewIPL = (unsigned long int) uxStartIntLevel;
#endif
#if ( HAVE_USP == 1 )
		if( !xTaskIsSuper() || ( pxCurrentTCB == tid_TOS ) )
#else
    if(*(unsigned long *)(((portVECTOR_SYSCALL) * 4) + coldfire_vector_base)  == (unsigned long)prvPortYield)
#endif
    {
        register int iOldIPL __asm__("d0");
        asm volatile (
                      " move.l %1, -(sp)\n\t"
                      " move.w #0xFE, -(sp)\n\t"
                      " trap %2\n\t"
                      " addq.l #6, sp" : "=d" (iOldIPL) : "d" (uiNewIPL), "i" (portTRAP_YIELD) : "d1", "a0", "a1", "memory", "cc" ); 
        return( iOldIPL );
    }
    else
    {
        register int iOldIPL __asm__("d0");
        asm volatile (
                      " move.l %1, d6\n\t"     /* get argument */
                      " move.w sr, d7\n\t"     /* current SR */
                      " move.l d7, d0\n\t"     /* prepare return value */
                      " and.l #0x700, d0\n\t"  /* mask out IPL */
                      " lsr.l #8, d0\n\t"      /* IPL */
                      " and.l #7, d6\n\t"      /* least significant three bits */
                      " lsl.l #8, d6\n\t"      /* move over to make mask */
                      " and.l #0xF8FF, d7\n\t" /* zero out current IPL */
                      " or.l d6, d7\n\t"       /* place new IPL in SR */
                      " move.w d7, sr" : "=d" (iOldIPL) : "d" (uiNewIPL) : "d6", "d7", "memory", "cc" );
        return( iOldIPL );
    } 
}

#if configUSE_PREEMPTION == 0
/*
 * The ISR used for the scheduler tick depends on whether the cooperative or
 * the preemptive scheduler is being used.
 */
static void
prvPortPreemptiveTick ( void )
{
    /* The cooperative scheduler requires a normal IRQ service routine to
     * simply increment the system tick.
     */
    vTaskIncrementTick(  );
#ifdef MCF5445X
    MCF_DTIM_DTER(2) = DTIM_DTER_REF;
#else /* MCF548X */
	  MCF_SLT_SSR(0) |= MCF_SLT_SSR_ST; /* clear interrupt */
#endif
}

#else

static void
prvPortPreemptiveTick( void )
{
    asm volatile ( "move.w  #0x2700, sr\n\t" );
#if _GCC_USES_FP == 1
    asm volatile ( "unlk fp\n\t" );
#endif
    portSAVE_CONTEXT(  );
#ifdef MCF5445X
    MCF_DTIM_DTER(2) = DTIM_DTER_REF;
#else /* MCF548X */
	  MCF_SLT_SSR(0) |= MCF_SLT_SSR_ST; /* clear interrupt */
#endif
    vTaskIncrementTick(  );
    vTaskSwitchContext(  );
    portRESTORE_CONTEXT(  );
}
#endif

static int portOldIPL, portOldIPLTOS;

void
vPortEnterCritical()
{
    int level = portSET_IPL( portIPL_MAX );
    if( ulCriticalNesting == portNO_CRITICAL_NESTING )
    {
         if( pxCurrentTCB != tid_TOS )
               portOldIPL = level;
         else
               portOldIPLTOS = level;
    }
    /* Now interrupts are disabled ulCriticalNesting can be accessed
     * directly.  Increment ulCriticalNesting to keep a count of how many times
     * portENTER_CRITICAL() has been called. */
    ulCriticalNesting++;
}

void
vPortExitCritical()
{
    if( ulCriticalNesting > portNO_CRITICAL_NESTING )
    {
        /* Decrement the nesting count as we are leaving a critical section. */
        ulCriticalNesting--;
        /* If the nesting level has reached zero then interrupts should be
        re-enabled. */
        if( ulCriticalNesting == portNO_CRITICAL_NESTING )
            ( void )portSET_IPL( pxCurrentTCB != tid_TOS ? portOldIPL : portOldIPLTOS );
    }
}

static void rte_int(void)
{
#if _GCC_USES_FP == 1
	asm volatile (" unlk fp\n\t");
#endif
	asm volatile (" rte\n\t");	
}

portBASE_TYPE
xPortStartScheduler( void )
{
    asm volatile ( "move.w  #0x2700, sr\n\t" );

    *(unsigned long *)_hz_200 = 0;
    /* Add entry in vector table for yield system call. */
    *(unsigned long *)(((portVECTOR_SYSCALL) * 4) + coldfire_vector_base) = (unsigned long)prvPortYield;
    /* Add entry in vector table for periodic timer. */
    *(unsigned long *)(((portVECTOR_TIMER) * 4) + coldfire_vector_base) = (unsigned long)prvPortPreemptiveTick;
    /* sometimes spurious interrupt not fixed ! */
    *(unsigned long *)((24 * 4) + coldfire_vector_base) = (long)rte_int;

    ulCriticalNesting = portINITIAL_CRITICAL_NESTING;

    /* Configure the timer for the system clock. */
    if ( configTICK_RATE_HZ > 0)
    {
#ifdef MCF5445X
        /* Initialize the periodic timer interrupt. */
        MCF_DTIM_DTMR(2) = DTIM_DTMR_ORRI | DTIM_DTMR_FRR | DTIM_DTMR_CLK(1);
        MCF_DTIM_DTCN(2) = 0;
        MCF_DTIM_DTXMR(2) = 0;
        MCF_DTIM_DTRR(2) = (SYSTEM_CLOCK * 1000000UL) / configTICK_RATE_HZ;
        MCF_DTIM_DTMR(2) |= DTIM_DTMR_RST; /* run */
        /* Configure interrupt priority and level and unmask interrupt. */
        MCF_INTC_ICR0n(INT0_HI_DTMR2) = INTC_ICR_IL( 0x6 );
        MCF_INTC_IMRH0 &= ~INTC_IMRH_INT_MASK34;
        save_imrl0 = save_imrl0_tos = MCF_INTC_IMRL0;
        save_imrh0 = save_imrh0_tos = MCF_INTC_IMRH0;
        save_imrh1 = save_imrh1_tos = MCF_INTC_IMRH1; 
#else /* MCF548X */
        /* Initialize the periodic timer interrupt. */
        MCF_SLT_SLTCNT(0) = (SYSTEM_CLOCK * 1000000UL) / configTICK_RATE_HZ;
        MCF_SLT_SCR(0) = MCF_SLT_SCR_TEN | MCF_SLT_SCR_IEN | MCF_SLT_SCR_RUN;
        /* Configure interrupt priority and level and unmask interrupt. */
        MCF_INTC_ICR54 = MCF_INTC_ICRn_IL( 0x6 ) | MCF_INTC_ICRn_IP( 0x6 );
        MCF_INTC_IMRH &= ~MCF_INTC_IMRH_INT_MASK54;
        MCF_INTC_IMRL &= ~MCF_INTC_IMRL_MASKALL;
        save_imrl = save_imrl_tos = MCF_INTC_IMRL;
        save_imrh = save_imrh_tos = MCF_INTC_IMRH;
#endif 
    }
    
    /* Restore the context of the first task that is going to run. */
    portRESTORE_CONTEXT(  );
    /* Should not get here. */
    return pdTRUE;
}

void
vPortEndScheduler( void )
{
}

unsigned portBASE_TYPE
uxPortReadTimer( void ) /* vTaskStartTrace */
{
#ifdef MCF5445X
	return((unsigned portBASE_TYPE)MCF_DTIM_DTCN(2) / SYSTEM_CLOCK);
#else  /* MCF548X */
	return((unsigned portBASE_TYPE)(MCF_SLT_SLTCNT(0) - MCF_SLT_SCNT(0)) / SYSTEM_CLOCK);
#endif
}

#endif /* LWIP */
#endif /* NETWORK */
