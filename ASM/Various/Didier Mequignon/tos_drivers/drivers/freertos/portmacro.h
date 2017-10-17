/*
    FreeRTOS V4.1.1 - Copyright (C) 2003-2006 Richard Barry.
    MCF5485 Port - Copyright (C) 2006 Christian Walter.

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

#ifndef PORTMACRO_H
#define PORTMACRO_H

/* ------------------------ Data types for Coldfire ----------------------- */
#define portCHAR        char
#define portFLOAT       float
#define portDOUBLE      double
#define portLONG        long
#define portSHORT       short
#define portSTACK_TYPE  unsigned int
#define portBASE_TYPE   int
#define tskSTACK_FILL_TYPE  ( 0xa5a5a5a5 )

#define HAVE_USP 1

#ifdef MCF5445X
#define SAVE_FPU 0
#else
#define SAVE_FPU 1
#endif

#if( USE_16_BIT_TICKS == 1 )
    typedef unsigned portSHORT portTickType;
    #define portMAX_DELAY ( portTickType ) 0xffff
#else
    typedef unsigned portLONG portTickType;
    #define portMAX_DELAY ( portTickType ) 0xffffffff
#endif

/* ------------------------ Architecture specifics ------------------------ */
#define portSTACK_GROWTH                ( -1 )
#define portTICK_RATE_MS                ( ( portTickType ) 1000 / configTICK_RATE_HZ )
#define portBYTE_ALIGNMENT              4

#define portTRAP_YIELD                  0   /* Trap 0 */
#define portIPL_MAX                     7   /* Only NMI interrupt 7 allowed. */

/* ------------------------ FreeRTOS macros for port ---------------------- */

/*
 * This function must be called when the current state of the active task
 * should be stored. It must be called immediately after exception
 * processing from the CPU, i.e. there exists a Coldfire exception frame at
 * the current position in the stack. The function reserves space on
 * the stack for the CPU registers and other task dependent values (e.g
 * ulCriticalNesting) and updates the top of the stack in the TCB.
 */
#if (__GNUC__ <= 3) 

#if( HAVE_USP == 1 )
#if( SAVE_FPU == 1 )
#define portSAVE_CONTEXT()                                                   \
    asm volatile (                                                           \
                   ".chip     68060\n\t"                                     \
                   " move.l   a0, -(sp)\n\t"                                 \
                   " move.l   a1, -(sp)\n\t"                                 \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " lea.l    8(sp), a1\n\t"                                 \
                   " move.l   a1, (a0)+\n\t"                                 \
                   " move.l   usp, a1\n\t"                                   \
                   " move.l   a1, 60(a0)\n\t"                                \
                   " lea.l    64(a0), a1\n\t"                                \
                   " fsave    (a1)\n\t"                                      \
                   " lea.l    16(a1), a1\n\t"                                \
                   " fmove.l  fpiar, (a1)+\n\t"                              \
                   " fmovem.x fp0-fp7, (a1)\n\t"                             \
                   " lea.l    64(a1), a1\n\t"                                \
                   " move.l   _ulCriticalNesting, (a1)\n\t"                  \
                   " move.l   (sp)+, a1\n\t"                                 \
                   " movem.l  d0-d7, (a0)\n\t"                               \
                   " movem.l  a1-a6, 36(a0)\n\t"                             \
                   ".chip     5200\n\t"                                      \
                   " move.l   (sp)+, 32(a0)\n\t"                             \
                   " pea.l    1\n\t"                                         \
                   " jsr      _portSaveRestoreInt\n\t"                       \
                   " addq.l   #4,sp" );
#else
#ifdef MCF5445X
#define portSAVE_CONTEXT()                                                   \
    asm volatile (                                                           \
                   ".chip     68060\n\t"                                     \
                   " move.l   a0, -(sp)\n\t"                                 \
                   " move.l   a1, -(sp)\n\t"                                 \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " lea.l    8(sp), a1\n\t"                                 \
                   " move.l   a1, (a0)+\n\t"                                 \
                   " move.l   usp, a1\n\t"                                   \
                   " move.l   a1, 60(a0)\n\t"                                \
                   " lea.l    64(a0), a1\n\t"                                \
                   " move.l   _ulCriticalNesting, (a1)\n\t"                  \
                   " move.l   (sp)+, a1\n\t"                                 \
                   " movem.l  d0-d7, (a0)\n\t"                               \
                   " movem.l  a1-a6, 36(a0)\n\t"                             \
                   ".chip     5200\n\t"                                      \
                   " move.l   (sp)+, 32(a0)\n\t"                             \
                   " pea.l    1\n\t"                                         \
                   " jsr      _portSaveRestoreInt\n\t"                       \
                   " addq.l   #4,sp" );
#else /* MCF548X */   
#define portSAVE_CONTEXT()                                                   \
    asm volatile (                                                           \
                   ".chip     68060\n\t"                                     \
                   " move.l   a0, -(sp)\n\t"                                 \
                   " move.l   a1, -(sp)\n\t"                                 \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " lea.l    8(sp), a1\n\t"                                 \
                   " move.l   a1, (a0)+\n\t"                                 \
                   " move.l   usp, a1\n\t"                                   \
                   " move.l   a1, 60(a0)\n\t"                                \
                   " lea.l    64(a0), a1\n\t"                                \
                   " move.l   _ulCriticalNesting, (a1)\n\t"                  \
                   " move.l   (sp)+, a1\n\t"                                 \
                   " movem.l  d0-d7, (a0)\n\t"                               \
                   " movem.l  a1-a6, 36(a0)\n\t"                             \
                   ".chip     5200\n\t"                                      \
                   " move.l   (sp)+, 32(a0)\n\t"                             \
                   " pea.l    1\n\t"                                         \
                   " jsr      _portSaveRestoreInt\n\t"                       \
                   " addq.l   #4,sp" );
#endif /* MCF5445X */
#endif
#else /* SAVE_USP == 0 */
#if( SAVE_FPU == 1 )
#define portSAVE_CONTEXT()                                                   \
    asm volatile (                                                           \
                   ".chip     68060\n\t"                                     \
                   " move.l   a0, -(sp)\n\t"                                 \
                   " move.l   a1, -(sp)\n\t"                                 \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " lea.l    8(sp), a1\n\t"                                 \
                   " move.l   a1, (a0)+\n\t"                                 \
                   " lea.l    64(a0), a1\n\t"                                \
                   " fsave    (a1)\n\t"                                      \
                   " lea.l    16(a1), a1\n\t"                                \
                   " fmove.l  fpiar, (a1)+\n\t"                              \
                   " fmovem.x fp0-fp7, (a1)\n\t"                             \
                   " lea.l    64(a1), a1\n\t"                                \
                   " move.l   _ulCriticalNesting, (a1)\n\t"                  \
                   " move.l   (sp)+, a1\n\t"                                 \
                   " movem.l  d0-d7, (a0)\n\t"                               \
                   " movem.l  a1-a6, 36(a0)\n\t"                             \
                   ".chip     5200\n\t"                                      \
                   " move.l   (sp)+, 32(a0)" );
#else
#define portSAVE_CONTEXT()                                                   \
    asm volatile (                                                           \
                   " move.l   a0, -(sp)\n\t"                                 \
                   " move.l   a1, -(sp)\n\t"                                 \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " lea.l    8(sp), a1\n\t"                                 \
                   " move.l   a1, (a0)+\n\t"                                 \
                   " lea.l    64(a0), a1\n\t"                                \
                   " move.l   _ulCriticalNesting, (a1)\n\t"                  \
                   " move.l   (sp)+, a1\n\t"                                 \
                   " movem.l  d0-d7, (a0)\n\t"                               \
                   " movem.l  a1-a6, 36(a0)\n\t"                             \
                   " move.l   (sp)+, 32(a0)" );
#endif
#endif

/*.
 * This function restores the current active and continues its execution.
 * It loads the current TCB and restores the processor registers, the
 * task dependent values (e.g ulCriticalNesting). Finally execution
 * is continued by executing an rte instruction.
 */
#if( HAVE_USP == 1 )
#if( SAVE_FPU == 1 )
#define portRESTORE_CONTEXT()                                                \
    asm volatile ( ".chip     68060\n\t"                                     \
                   " clr.l    -(sp)\n\t"                                     \
                   " jsr      _portSaveRestoreInt\n\t"                       \
                   " addq.l   #4,sp\n\t"                                     \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " move.l   (a0)+, sp\n\t"                                 \
                   " move.l   60(a0), a1\n\t"                                \
                   " move.l   a1, usp\n\t"                                   \
                   " lea.l    80(a0), a1\n\t"                                \
                   " fmove.l  (a1)+, fpiar\n\t"                              \
                   " fmovem.x (a1), fp0-fp7\n\t"                             \
                   " frestore -20(a1)\n\t"                                   \
                   " lea.l    64(a1), a1\n\t"                                \
                   " move.l   (a1), _ulCriticalNesting\n\t"                  \
                   " movem.l  (a0), d0-d7/a0-a6\n\t"                         \
                   ".chip     5200\n\t"                                      \
                   " rte\n\t" );
#else
#ifdef MCF5445X
#define portRESTORE_CONTEXT()                                                \
    asm volatile ( ".chip     68060\n\t"                                     \
                   " clr.l    -(sp)\n\t"                                     \
                   " jsr      _portSaveRestoreInt\n\t"                       \
                   " addq.l   #4,sp\n\t"                                     \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " move.l   (a0)+, sp\n\t"                                 \
                   " move.l   60(a0), a1\n\t"                                \
                   " move.l   a1, usp\n\t"                                   \
                   " lea.l    64(a0), a1\n\t"                                \
                   " move.l   (a1), _ulCriticalNesting\n\t"                  \
                   " movem.l  (a0), d0-d7/a0-a6\n\t"                         \
                   ".chip     5200\n\t"                                      \
                   " rte\n\t" );
#else /* MCF548X */
#define portRESTORE_CONTEXT() do {                                           \
    asm volatile ( ".chip     68060\n\t"                                     \
                   " clr.l    -(sp)\n\t"                                     \
                   " jsr      _portSaveRestoreInt\n\t"                       \
                   " addq.l   #4,sp\n\t"                                     \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " move.l   (a0)+, sp\n\t"                                 \
                   " move.l   60(a0), a1\n\t"                                \
                   " move.l   a1, usp\n\t"                                   \
                   " lea.l    64(a0), a1\n\t"                                \
                   " move.l   (a1), _ulCriticalNesting\n\t"                  \
                   " movem.l  (a0), d0-d7/a0-a6\n\t"                         \
                   ".chip     5200\n\t"                                      \
                   " rte\n\t" );
#endif /* MCF5445X */    
#endif
#else /* SAVE_USP == 0 */
#if( SAVE_FPU == 1 )
#define portRESTORE_CONTEXT()                                                \
    asm volatile ( ".chip     68060\n\t"                                     \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " move.l   (a0)+, sp\n\t"                                 \
                   " lea.l    80(a0), a1\n\t"                                \
                   " fmove.l  (a1)+, fpiar\n\t"                              \
                   " fmovem.x (a1), fp0-fp7\n\t"                             \
                   " frestore -20(a1)\n\t"                                   \
                   " lea.l    64(a1), a1\n\t"                                \
                   " move.l   (a1), _ulCriticalNesting\n\t"                  \
                   " movem.l  (a0), d0-d7/a0-a6\n\t"                         \
                   ".chip     5200\n\t"                                      \
                   " rte\n\t" );
#else
#define portRESTORE_CONTEXT()                                                \
    asm volatile ( " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " move.l   (a0)+, sp\n\t"                                 \
                   " lea.l    64(a0), a1\n\t"                                \
                   " move.l   (a1), _ulCriticalNesting\n\t"                  \
                   " movem.l  (a0), d0-d7/a0-a6\n\t"                         \
                   " rte\n\t" );
#endif            
#endif      

#if( SAVE_FPU == 1 )
#define portRESTORE_FAST_CONTEXT()                                           \
    asm volatile ( ".chip     68060\n\t"                                     \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " move.l   (a0)+, sp\n\t"                                 \
                   " lea.l    148(a0), a1\n\t"                               \
                   " move.l   (a1), _ulCriticalNesting\n\t"                  \
                   " movem.l  (a0), d0-d1\n\t"                               \
                   " lea.l    32(a0),a0\n\t"                                 \
                   " movem.l  (a0), a0-a1\n\t"                               \
                   ".chip     5200\n\t"                                      \
                   " rte\n\t" );
#else
#define portRESTORE_FAST_CONTEXT()                                           \
    asm volatile ( " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " move.l   (a0)+, sp\n\t"                                 \
                   " lea.l    64(a0), a1\n\t"                                \
                   " move.l   (a1), _ulCriticalNesting\n\t"                  \
                   " movem.l  (a0), d0-d1\n\t"                               \
                   " lea.l    32(a0),a0\n\t"                                 \
                   " movem.l  (a0), a0-a1\n\t"                               \
                   " rte\n\t" );
#endif

#else /* __GNUC__ > 3 */

#if( HAVE_USP == 1 )
#if( SAVE_FPU == 1 )
#define portSAVE_CONTEXT()                                                   \
    asm volatile (                                                           \
                   " move.l   a0, -(sp)\n\t"                                 \
                   " move.l   a1, -(sp)\n\t"                                 \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " lea.l    8(sp), a1\n\t"                                 \
                   " move.l   a1, (a0)+\n\t"                                 \
                   " move.l   usp, a1\n\t"                                   \
                   " move.l   a1, 60(a0)\n\t"                                \
                   " lea.l    64(a0), a1\n\t"                                \
                   " fsave    (a1)\n\t"                                      \
                   " lea.l    16(a1), a1\n\t"                                \
                   " fmove.l  fpiar, (a1)+\n\t"                              \
                   " fmovem.d fp0-fp7, (a1)\n\t"                             \
                   " lea.l    64(a1), a1\n\t"                                \
                   " move.l   _ulCriticalNesting, (a1)\n\t"                  \
                   " move.l   (sp)+, a1\n\t"                                 \
                   " movem.l  d0-d7, (a0)\n\t"                               \
                   " movem.l  a1-a6, 36(a0)\n\t"                             \
                   " move.l   (sp)+, 32(a0)\n\t"                             \
                   " pea.l    1\n\t"                                         \
                   " jsr      _portSaveRestoreInt\n\t"                       \
                   " addq.l   #4,sp" );
#else
#ifdef MCF5445X
#define portSAVE_CONTEXT()                                                   \
    asm volatile (                                                           \
                   " move.l   a0, -(sp)\n\t"                                 \
                   " move.l   a1, -(sp)\n\t"                                 \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " lea.l    8(sp), a1\n\t"                                 \
                   " move.l   a1, (a0)+\n\t"                                 \
                   " move.l   usp, a1\n\t"                                   \
                   " move.l   a1, 60(a0)\n\t"                                \
                   " lea.l    64(a0), a1\n\t"                                \
                   " move.l   _ulCriticalNesting, (a1)\n\t"                  \
                   " move.l   (sp)+, a1\n\t"                                 \
                   " movem.l  d0-d7, (a0)\n\t"                               \
                   " movem.l  a1-a6, 36(a0)\n\t"                             \
                   " move.l   (sp)+, 32(a0)\n\t"                             \
                   " pea.l    1\n\t"                                         \
                   " jsr      _portSaveRestoreInt\n\t"                       \
                   " addq.l   #4,sp" );
#else /* MCF548X */   
#define portSAVE_CONTEXT()                                                   \
    asm volatile (                                                           \
                   " move.l   a0, -(sp)\n\t"                                 \
                   " move.l   a1, -(sp)\n\t"                                 \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " lea.l    8(sp), a1\n\t"                                 \
                   " move.l   a1, (a0)+\n\t"                                 \
                   " move.l   usp, a1\n\t"                                   \
                   " move.l   a1, 60(a0)\n\t"                                \
                   " lea.l    64(a0), a1\n\t"                                \
                   " move.l   _ulCriticalNesting, (a1)\n\t"                  \
                   " move.l   (sp)+, a1\n\t"                                 \
                   " movem.l  d0-d7, (a0)\n\t"                               \
                   " movem.l  a1-a6, 36(a0)\n\t"                             \
                   " move.l   (sp)+, 32(a0)\n\t"                             \
                   " pea.l    1\n\t"                                         \
                   " jsr      _portSaveRestoreInt\n\t"                       \
                   " addq.l   #4,sp" );
#endif /* MCF5445X */
#endif
#else /* SAVE_USP == 0 */
#if( SAVE_FPU == 1 )
#define portSAVE_CONTEXT()                                                   \
    asm volatile (                                                           \
                   " move.l   a0, -(sp)\n\t"                                 \
                   " move.l   a1, -(sp)\n\t"                                 \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " lea.l    8(sp), a1\n\t"                                 \
                   " move.l   a1, (a0)+\n\t"                                 \
                   " lea.l    64(a0), a1\n\t"                                \
                   " fsave    (a1)\n\t"                                      \
                   " lea.l    16(a1), a1\n\t"                                \
                   " fmove.l  fpiar, (a1)+\n\t"                              \
                   " fmovem.d fp0-fp7, (a1)\n\t"                             \
                   " lea.l    64(a1), a1\n\t"                                \
                   " move.l   _ulCriticalNesting, (a1)\n\t"                  \
                   " move.l   (sp)+, a1\n\t"                                 \
                   " movem.l  d0-d7, (a0)\n\t"                               \
                   " movem.l  a1-a6, 36(a0)\n\t"                             \
                   " move.l   (sp)+, 32(a0)" );
#else
#define portSAVE_CONTEXT()                                                   \
    asm volatile (                                                           \
                   " move.l   a0, -(sp)\n\t"                                 \
                   " move.l   a1, -(sp)\n\t"                                 \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " lea.l    8(sp), a1\n\t"                                 \
                   " move.l   a1, (a0)+\n\t"                                 \
                   " lea.l    64(a0), a1\n\t"                                \
                   " move.l   _ulCriticalNesting, (a1)\n\t"                  \
                   " move.l   (sp)+, a1\n\t"                                 \
                   " movem.l  d0-d7, (a0)\n\t"                               \
                   " movem.l  a1-a6, 36(a0)\n\t"                             \
                   " move.l   (sp)+, 32(a0)" );
#endif
#endif

/*.
 * This function restores the current active and continues its execution.
 * It loads the current TCB and restores the processor registers, the
 * task dependent values (e.g ulCriticalNesting). Finally execution
 * is continued by executing an rte instruction.
 */
#if( HAVE_USP == 1 )
#if( SAVE_FPU == 1 )
#define portRESTORE_CONTEXT()                                                \
    asm volatile ( " clr.l    -(sp)\n\t"                                     \
                   " jsr      _portSaveRestoreInt\n\t"                       \
                   " addq.l   #4,sp\n\t"                                     \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " move.l   (a0)+, sp\n\t"                                 \
                   " move.l   60(a0), a1\n\t"                                \
                   " move.l   a1, usp\n\t"                                   \
                   " lea.l    80(a0), a1\n\t"                                \
                   " fmove.l  (a1)+, fpiar\n\t"                              \
                   " fmovem.d (a1), fp0-fp7\n\t"                             \
                   " frestore -20(a1)\n\t"                                   \
                   " lea.l    64(a1), a1\n\t"                                \
                   " move.l   (a1), _ulCriticalNesting\n\t"                  \
                   " movem.l  (a0), d0-d7/a0-a6\n\t"                         \
                   " rte\n\t" );
#else
#ifdef MCF5445X
#define portRESTORE_CONTEXT()                                                \
    asm volatile ( " clr.l    -(sp)\n\t"                                     \
                   " jsr      _portSaveRestoreInt\n\t"                       \
                   " addq.l   #4,sp\n\t"                                     \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " move.l   (a0)+, sp\n\t"                                 \
                   " move.l   60(a0), a1\n\t"                                \
                   " move.l   a1, usp\n\t"                                   \
                   " lea.l    64(a0), a1\n\t"                                \
                   " move.l   (a1), _ulCriticalNesting\n\t"                  \
                   " movem.l  (a0), d0-d7/a0-a6\n\t"                         \
                   " rte\n\t" );
#else /* MCF548X */
#define portRESTORE_CONTEXT() do {                                           \
    asm volatile ( " clr.l    -(sp)\n\t"                                     \
                   " jsr      _portSaveRestoreInt\n\t"                       \
                   " addq.l   #4,sp\n\t"                                     \
                   " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " move.l   (a0)+, sp\n\t"                                 \
                   " move.l   60(a0), a1\n\t"                                \
                   " move.l   a1, usp\n\t"                                   \
                   " lea.l    64(a0), a1\n\t"                                \
                   " move.l   (a1), _ulCriticalNesting\n\t"                  \
                   " movem.l  (a0), d0-d7/a0-a6\n\t"                         \
                   " rte\n\t" );
#endif /* MCF5445X */    
#endif
#else /* SAVE_USP == 0 */
#if( SAVE_FPU == 1 )
#define portRESTORE_CONTEXT()                                                \
    asm volatile ( " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " move.l   (a0)+, sp\n\t"                                 \
                   " lea.l    80(a0), a1\n\t"                                \
                   " fmove.l  (a1)+, fpiar\n\t"                              \
                   " fmovem.d (a1), fp0-fp7\n\t"                             \
                   " frestore -20(a1)\n\t"                                   \
                   " lea.l    64(a1), a1\n\t"                                \
                   " move.l   (a1), _ulCriticalNesting\n\t"                  \
                   " movem.l  (a0), d0-d7/a0-a6\n\t"                         \
                   " rte\n\t" );
#else
#define portRESTORE_CONTEXT()                                                \
    asm volatile ( " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " move.l   (a0)+, sp\n\t"                                 \
                   " lea.l    64(a0), a1\n\t"                                \
                   " move.l   (a1), _ulCriticalNesting\n\t"                  \
                   " movem.l  (a0), d0-d7/a0-a6\n\t"                         \
                   " rte\n\t" );
#endif            
#endif      

#if( SAVE_FPU == 1 )
#define portRESTORE_FAST_CONTEXT()                                           \
    asm volatile ( " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " move.l   (a0)+, sp\n\t"                                 \
                   " lea.l    148(a0), a1\n\t"                               \
                   " move.l   (a1), _ulCriticalNesting\n\t"                  \
                   " movem.l  (a0), d0-d1\n\t"                               \
                   " lea.l    32(a0),a0\n\t"                                 \
                   " movem.l  (a0), a0-a1\n\t"                               \
                   " rte\n\t" );
#else
#define portRESTORE_FAST_CONTEXT()                                           \
    asm volatile ( " move.l   _pxCurrentTCB, a0\n\t"                         \
                   " move.l   (a0)+, sp\n\t"                                 \
                   " lea.l    64(a0), a1\n\t"                                \
                   " move.l   (a1), _ulCriticalNesting\n\t"                  \
                   " movem.l  (a0), d0-d1\n\t"                               \
                   " lea.l    32(a0),a0\n\t"                                 \
                   " movem.l  (a0), a0-a1\n\t"                               \
                   " rte\n\t" );
#endif

#endif /* __GNUC >= 3 */

#define portENTER_CRITICAL()                                                 \
    vPortEnterCritical();

#define portEXIT_CRITICAL()                                                  \
    vPortExitCritical();

#define portSET_IPL( xIPL )                                                  \
    vPortSetIPL( xIPL )

#define portDISABLE_INTERRUPTS() \
    do { ( void )portSET_IPL( portIPL_MAX ); } while( 0 )

#if 0 // incompatible with tasks working with different level of interrupts
#define portENABLE_INTERRUPTS() \
    do { ( void )portSET_IPL( 0 ); } while( 0 )
#endif

#define portNOP()                                                            \
    asm volatile ("nop\n\t")

#if _GCC_USES_FP == 1
#define portENTER_SWITCHING_ISR()                                            \
    asm volatile ( " move.w  #0x2700, sr\n\t"                                \
                   " unlk fp\n\t" );                                         \
    /* Save the context of the interrupted task. */                          \
    portSAVE_CONTEXT(  );                                                    \
    {
#else
#define portENTER_SWITCHING_ISR()                                            \
    asm volatile (" move.w  #0x2700, sr\n\t");                                   \
    /* Save the context of the interrupted task. */                          \
    portSAVE_CONTEXT(  );                                                    \
    {
#endif

#define portEXIT_SWITCHING_ISR( SwitchRequired )                             \
        /* If a switch is required we call vTaskSwitchContext(). */          \
        if( SwitchRequired )                                                 \
        {                                                                    \
            vTaskSwitchContext(  );                                          \
            portRESTORE_CONTEXT(  );                                         \
        }                                                                    \
    }                                                                        \
    portRESTORE_FAST_CONTEXT(  );

/* ------------------------ Function prototypes --------------------------- */
void vPortEnterCritical( void );
void vPortExitCritical( void );
void portYIELD( void );
int vPortSetIPL( unsigned long int uiNewIPL );
void portSaveRestoreInt( int iSave );
unsigned portBASE_TYPE uxPortReadTimer( void );

/* ------------------------ Compiler specifics ---------------------------- */
#define portTASK_FUNCTION_PROTO( vFunction, pvParameters )                   \
    void vFunction( void *pvParameters )

#define portTASK_FUNCTION( vFunction, pvParameters )                         \
    void vFunction( void *pvParameters )

#endif

