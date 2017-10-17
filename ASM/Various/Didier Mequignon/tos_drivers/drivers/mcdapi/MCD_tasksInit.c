/*********************************************************************
 *
 * Copyright (C) 2004  Motorola, Inc.
 *	MOTOROLA, INC. All Rights Reserved.  
 *  You are hereby granted a copyright license to use
 *  the SOFTWARE so long as this entire notice is
 *  retained without alteration in any modified and/or redistributed
 *  versions, and that such modified versions are clearly identified
 *  as such. No licenses are granted by implication, estoppel or
 *  otherwise under any patents or trademarks of Motorola, Inc. This 
 *  software is provided on an "AS IS" basis and without warranty.
 *
 *  To the maximum extent permitted by applicable law, MOTOROLA 
 *  DISCLAIMS ALL WARRANTIES WHETHER EXPRESS OR IMPLIED, INCLUDING 
 *  IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
 *  PURPOSE AND ANY WARRANTY AGAINST INFRINGEMENT WITH REGARD TO THE 
 *  SOFTWARE (INCLUDING ANY MODIFIED VERSIONS THEREOF) AND ANY 
 *  ACCOMPANYING WRITTEN MATERIALS.
 * 
 *  To the maximum extent permitted by applicable law, IN NO EVENT
 *  SHALL MOTOROLA BE LIABLE FOR ANY DAMAGES WHATSOEVER (INCLUDING 
 *  WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS, BUSINESS 
 *  INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR OTHER PECUNIARY
 *  LOSS) ARISING OF THE USE OR INABILITY TO USE THE SOFTWARE.   
 * 
 *  Motorola assumes no responsibility for the maintenance and support
 *  of this software
 ********************************************************************/
/*
 * Do not edit!
 */
 /*
 * File:		MCD_tasksInit.c
 * Purpose:		Function for initialize variable tables of different
 *              types of tasks.
 *
 * Notes:
 *
 *
 * Modifications:
 *  	
 *
 */ 

#include "config.h"
#include "MCD_dma.h"

#ifdef NETWORK

extern dmaRegs *MCD_dmaBar;

/*
 * Task 0
 */

void  MCD_startDmaChainNoEu(int *currBD, short srcIncr, short destIncr, int xferSize, short xferSizeIncr, int *cSave, volatile TaskTableEntry *taskTable, int channel)
{

	MCD_SET_VAR(taskTable+channel, 2, (u32)currBD);	/* var[2] */
	MCD_SET_VAR(taskTable+channel, 25, (u32)(0xe000 << 16) | (0xffff & srcIncr));	/* inc[1] */
	MCD_SET_VAR(taskTable+channel, 24, (u32)(0xe000 << 16) | (0xffff & destIncr));	/* inc[0] */
	MCD_SET_VAR(taskTable+channel, 19, (u32)xferSize);	/* var[19] */
	MCD_SET_VAR(taskTable+channel, 26, (u32)(0x2000 << 16) | (0xffff & xferSizeIncr));	/* inc[2] */
	MCD_SET_VAR(taskTable+channel, 0, (u32)cSave);	/* var[0] */
	MCD_SET_VAR(taskTable+channel, 1, (u32)0x00000000);	/* var[1] */
	MCD_SET_VAR(taskTable+channel, 3, (u32)0x00000000);	/* var[3] */
	MCD_SET_VAR(taskTable+channel, 4, (u32)0x00000000);	/* var[4] */
	MCD_SET_VAR(taskTable+channel, 5, (u32)0x00000000);	/* var[5] */
	MCD_SET_VAR(taskTable+channel, 6, (u32)0x00000000);	/* var[6] */
	MCD_SET_VAR(taskTable+channel, 7, (u32)0x00000000);	/* var[7] */
	MCD_SET_VAR(taskTable+channel, 8, (u32)0x00000000);	/* var[8] */
	MCD_SET_VAR(taskTable+channel, 9, (u32)0x00000000);	/* var[9] */
	MCD_SET_VAR(taskTable+channel, 10, (u32)0x00000000);	/* var[10] */
	MCD_SET_VAR(taskTable+channel, 11, (u32)0x00000000);	/* var[11] */
	MCD_SET_VAR(taskTable+channel, 12, (u32)0x00000000);	/* var[12] */
	MCD_SET_VAR(taskTable+channel, 13, (u32)0x00000000);	/* var[13] */
	MCD_SET_VAR(taskTable+channel, 14, (u32)0x00000000);	/* var[14] */
	MCD_SET_VAR(taskTable+channel, 15, (u32)0x00000000);	/* var[15] */
	MCD_SET_VAR(taskTable+channel, 16, (u32)0x00000000);	/* var[16] */
	MCD_SET_VAR(taskTable+channel, 17, (u32)0x00000000);	/* var[17] */
	MCD_SET_VAR(taskTable+channel, 18, (u32)0x00000000);	/* var[18] */
	MCD_SET_VAR(taskTable+channel, 20, (u32)0x00000000);	/* var[20] */
	MCD_SET_VAR(taskTable+channel, 21, (u32)0x00000010);	/* var[21] */
	MCD_SET_VAR(taskTable+channel, 22, (u32)0x00000004);	/* var[22] */
	MCD_SET_VAR(taskTable+channel, 23, (u32)0x00000080);	/* var[23] */
	MCD_SET_VAR(taskTable+channel, 27, (u32)0x00000000);	/* inc[3] */
	MCD_SET_VAR(taskTable+channel, 28, (u32)0x60000000);	/* inc[4] */
	MCD_SET_VAR(taskTable+channel, 29, (u32)0x80000001);	/* inc[5] */
	MCD_SET_VAR(taskTable+channel, 30, (u32)0x80000000);	/* inc[6] */
	MCD_SET_VAR(taskTable+channel, 31, (u32)0x40000000);	/* inc[7] */

    /* Set the task's Enable bit in its Task Control Register */
    MCD_dmaBar->taskControl[channel] |= (u16)0x8000; /* add a MACRO HERE TBD*/
	

}


/*
 * Task 1
 */
 
void  MCD_startDmaSingleNoEu(char *srcAddr, short srcIncr, char *destAddr, short destIncr, int dmaSize, int dmaSizeMXferSize, short xferSizeIncr, int flags, int *currBD, int *cSave, volatile TaskTableEntry *taskTable, int channel)
{
	
	MCD_SET_VAR(taskTable+channel, 13, (u32)srcAddr);	/* var[13] */
	MCD_SET_VAR(taskTable+channel, 25, (u32)(0xe000 << 16) | (0xffff & srcIncr));	/* inc[1] */
	MCD_SET_VAR(taskTable+channel, 4, (u32)destAddr);	/* var[4] */
	MCD_SET_VAR(taskTable+channel, 24, (u32)(0xe000 << 16) | (0xffff & destIncr));	/* inc[0] */
	MCD_SET_VAR(taskTable+channel, 6, (u32)dmaSize);	/* var[6] */
	MCD_SET_VAR(taskTable+channel, 7, (u32)dmaSizeMXferSize);	/* var[7] */
	MCD_SET_VAR(taskTable+channel, 26, (u32)(0x2000 << 16) | (0xffff & xferSizeIncr));	/* inc[2] */
	MCD_SET_VAR(taskTable+channel, 9, (u32)flags);	/* var[9] */
	MCD_SET_VAR(taskTable+channel, 1, (u32)currBD);	/* var[1] */
	MCD_SET_VAR(taskTable+channel, 0, (u32)cSave);	/* var[0] */
	MCD_SET_VAR(taskTable+channel, 2, (u32)0x00000000);	/* var[2] */
	MCD_SET_VAR(taskTable+channel, 3, (u32)0x00000000);	/* var[3] */
	MCD_SET_VAR(taskTable+channel, 5, (u32)0x00000000);	/* var[5] */
	MCD_SET_VAR(taskTable+channel, 8, (u32)0x00000000);	/* var[8] */
	MCD_SET_VAR(taskTable+channel, 10, (u32)0x00000000);	/* var[10] */
	MCD_SET_VAR(taskTable+channel, 11, (u32)0x00000000);	/* var[11] */
	MCD_SET_VAR(taskTable+channel, 12, (u32)0x00000000);	/* var[12] */
	MCD_SET_VAR(taskTable+channel, 14, (u32)0x00000000);	/* var[14] */
	MCD_SET_VAR(taskTable+channel, 15, (u32)0x00000000);	/* var[15] */
	MCD_SET_VAR(taskTable+channel, 16, (u32)0x00000004);	/* var[16] */
	MCD_SET_VAR(taskTable+channel, 17, (u32)0x00000080);	/* var[17] */
	MCD_SET_VAR(taskTable+channel, 27, (u32)0x00000000);	/* inc[3] */
	MCD_SET_VAR(taskTable+channel, 28, (u32)0x80000001);	/* inc[4] */
	MCD_SET_VAR(taskTable+channel, 29, (u32)0x40000000);	/* inc[5] */


    /* enable the task */
    MCD_dmaBar->taskControl[channel] |= (u16)0x8000; /* add a MACRO HERE TBD*/
}


/*
 * Task 2
 */
#ifdef MCD_INCLUDE_EU
 
void  MCD_startDmaChainEu(int *currBD, short srcIncr, short destIncr, int xferSize, short xferSizeIncr, int *cSave, volatile TaskTableEntry *taskTable, int channel)
{
	
	MCD_SET_VAR(taskTable+channel, 2, (u32)currBD);	/* var[2] */
	MCD_SET_VAR(taskTable+channel, 25, (u32)(0xe000 << 16) | (0xffff & srcIncr));	/* inc[1] */
	MCD_SET_VAR(taskTable+channel, 24, (u32)(0xe000 << 16) | (0xffff & destIncr));	/* inc[0] */
	MCD_SET_VAR(taskTable+channel, 19, (u32)xferSize);	/* var[19] */
	MCD_SET_VAR(taskTable+channel, 26, (u32)(0x2000 << 16) | (0xffff & xferSizeIncr));	/* inc[2] */
	MCD_SET_VAR(taskTable+channel, 0, (u32)cSave);	/* var[0] */
	MCD_SET_VAR(taskTable+channel, 1, (u32)0x00000000);	/* var[1] */
	MCD_SET_VAR(taskTable+channel, 3, (u32)0x00000000);	/* var[3] */
	MCD_SET_VAR(taskTable+channel, 4, (u32)0x00000000);	/* var[4] */
	MCD_SET_VAR(taskTable+channel, 5, (u32)0x00000000);	/* var[5] */
	MCD_SET_VAR(taskTable+channel, 6, (u32)0x00000000);	/* var[6] */
	MCD_SET_VAR(taskTable+channel, 7, (u32)0x00000000);	/* var[7] */
	MCD_SET_VAR(taskTable+channel, 8, (u32)0x00000000);	/* var[8] */
	MCD_SET_VAR(taskTable+channel, 9, (u32)0x00000000);	/* var[9] */
	MCD_SET_VAR(taskTable+channel, 10, (u32)0x00000000);	/* var[10] */
	MCD_SET_VAR(taskTable+channel, 11, (u32)0x00000000);	/* var[11] */
	MCD_SET_VAR(taskTable+channel, 12, (u32)0x00000000);	/* var[12] */
	MCD_SET_VAR(taskTable+channel, 13, (u32)0x00000000);	/* var[13] */
	MCD_SET_VAR(taskTable+channel, 14, (u32)0x00000000);	/* var[14] */
	MCD_SET_VAR(taskTable+channel, 15, (u32)0x00000000);	/* var[15] */
	MCD_SET_VAR(taskTable+channel, 16, (u32)0x00000000);	/* var[16] */
	MCD_SET_VAR(taskTable+channel, 17, (u32)0x00000000);	/* var[17] */
	MCD_SET_VAR(taskTable+channel, 18, (u32)0x00000000);	/* var[18] */
	MCD_SET_VAR(taskTable+channel, 20, (u32)0x00000000);	/* var[20] */
	MCD_SET_VAR(taskTable+channel, 21, (u32)0x00000010);	/* var[21] */
	MCD_SET_VAR(taskTable+channel, 22, (u32)0x00000004);	/* var[22] */
	MCD_SET_VAR(taskTable+channel, 23, (u32)0x00000080);	/* var[23] */
	MCD_SET_VAR(taskTable+channel, 27, (u32)0x00000000);	/* inc[3] */
	MCD_SET_VAR(taskTable+channel, 28, (u32)0x60000000);	/* inc[4] */
	MCD_SET_VAR(taskTable+channel, 29, (u32)0x80000001);	/* inc[5] */
	MCD_SET_VAR(taskTable+channel, 30, (u32)0x80000000);	/* inc[6] */
	MCD_SET_VAR(taskTable+channel, 31, (u32)0x40000000);	/* inc[7] */

    /*enable the task*/
    MCD_dmaBar->taskControl[channel] |= (u16)0x8000; /* add a MACRO HERE TBD*/
}


/*
 * Task 3
 */
 
void  MCD_startDmaSingleEu(char *srcAddr, short srcIncr, char *destAddr, short destIncr, int dmaSize, int dmaSizeMXferSize, short xferSizeIncr, int flags, int *currBD, int *cSave, volatile TaskTableEntry *taskTable, int channel)
{
	
	MCD_SET_VAR(taskTable+channel, 13, (u32)srcAddr);	/* var[13] */
	MCD_SET_VAR(taskTable+channel, 25, (u32)(0xe000 << 16) | (0xffff & srcIncr));	/* inc[1] */
	MCD_SET_VAR(taskTable+channel, 4, (u32)destAddr);	/* var[4] */
	MCD_SET_VAR(taskTable+channel, 24, (u32)(0xe000 << 16) | (0xffff & destIncr));	/* inc[0] */
	MCD_SET_VAR(taskTable+channel, 6, (u32)dmaSize);	/* var[6] */
	MCD_SET_VAR(taskTable+channel, 7, (u32)dmaSizeMXferSize);	/* var[7] */
	MCD_SET_VAR(taskTable+channel, 26, (u32)(0x2000 << 16) | (0xffff & xferSizeIncr));	/* inc[2] */
	MCD_SET_VAR(taskTable+channel, 9, (u32)flags);	/* var[9] */
	MCD_SET_VAR(taskTable+channel, 1, (u32)currBD);	/* var[1] */
	MCD_SET_VAR(taskTable+channel, 0, (u32)cSave);	/* var[0] */
	MCD_SET_VAR(taskTable+channel, 2, (u32)0x00000000);	/* var[2] */
	MCD_SET_VAR(taskTable+channel, 3, (u32)0x00000000);	/* var[3] */
	MCD_SET_VAR(taskTable+channel, 5, (u32)0x00000000);	/* var[5] */
	MCD_SET_VAR(taskTable+channel, 8, (u32)0x00000000);	/* var[8] */
	MCD_SET_VAR(taskTable+channel, 10, (u32)0x00000000);	/* var[10] */
	MCD_SET_VAR(taskTable+channel, 11, (u32)0x00000000);	/* var[11] */
	MCD_SET_VAR(taskTable+channel, 12, (u32)0x00000000);	/* var[12] */
	MCD_SET_VAR(taskTable+channel, 14, (u32)0x00000000);	/* var[14] */
	MCD_SET_VAR(taskTable+channel, 15, (u32)0x00000000);	/* var[15] */
	MCD_SET_VAR(taskTable+channel, 16, (u32)0x00000004);	/* var[16] */
	MCD_SET_VAR(taskTable+channel, 17, (u32)0x00000080);	/* var[17] */
	MCD_SET_VAR(taskTable+channel, 27, (u32)0x00000000);	/* inc[3] */
	MCD_SET_VAR(taskTable+channel, 28, (u32)0x80000001);	/* inc[4] */
	MCD_SET_VAR(taskTable+channel, 29, (u32)0x40000000);	/* inc[5] */

    /*enable the task*/
    MCD_dmaBar->taskControl[channel] |= (u16)0x8000; /* add a MACRO HERE TBD*/

}

#endif

/*
 * Task 4
 */
 
void  MCD_startDmaENetRcv(char *bDBase, char *currBD, char *rcvFifoPtr, volatile TaskTableEntry *taskTable, int channel)
{
	
	MCD_SET_VAR(taskTable+channel, 0, (u32)bDBase);	/* var[0] */
	MCD_SET_VAR(taskTable+channel, 4, (u32)currBD);	/* var[4] */
	MCD_SET_VAR(taskTable+channel, 7, (u32)rcvFifoPtr);	/* var[7] */
	MCD_SET_VAR(taskTable+channel, 1, (u32)0x00000000);	/* var[1] */
	MCD_SET_VAR(taskTable+channel, 2, (u32)0x00000000);	/* var[2] */
	MCD_SET_VAR(taskTable+channel, 3, (u32)0x00000000);	/* var[3] */
	MCD_SET_VAR(taskTable+channel, 5, (u32)0x00000000);	/* var[5] */
	MCD_SET_VAR(taskTable+channel, 6, (u32)0x00000000);	/* var[6] */
	MCD_SET_VAR(taskTable+channel, 8, (u32)0x00000000);	/* var[8] */
	MCD_SET_VAR(taskTable+channel, 9, (u32)0x00000000);	/* var[9] */
	MCD_SET_VAR(taskTable+channel, 10, (u32)0x0000ffff);	/* var[10] */
	MCD_SET_VAR(taskTable+channel, 11, (u32)0x30000000);	/* var[11] */
	MCD_SET_VAR(taskTable+channel, 12, (u32)0x0fffffff);	/* var[12] */
	MCD_SET_VAR(taskTable+channel, 13, (u32)0x00000008);	/* var[13] */
	MCD_SET_VAR(taskTable+channel, 24, (u32)0x00000000);	/* inc[0] */
	MCD_SET_VAR(taskTable+channel, 25, (u32)0x60000000);	/* inc[1] */
	MCD_SET_VAR(taskTable+channel, 26, (u32)0x20000004);	/* inc[2] */
	MCD_SET_VAR(taskTable+channel, 27, (u32)0x40000000);	/* inc[3] */
    /*enable the task*/
    MCD_dmaBar->taskControl[channel] |= (u16)0x8000; /* add a MACRO HERE TBD*/

}


/*
 * Task 5
 */
 
void  MCD_startDmaENetXmit(char *bDBase, char *currBD, char *xmitFifoPtr, volatile TaskTableEntry *taskTable, int channel)
{
	
	MCD_SET_VAR(taskTable+channel, 0, (u32)bDBase);	/* var[0] */
	MCD_SET_VAR(taskTable+channel, 3, (u32)currBD);	/* var[3] */
	MCD_SET_VAR(taskTable+channel, 11, (u32)xmitFifoPtr);	/* var[11] */
	MCD_SET_VAR(taskTable+channel, 1, (u32)0x00000000);	/* var[1] */
	MCD_SET_VAR(taskTable+channel, 2, (u32)0x00000000);	/* var[2] */
	MCD_SET_VAR(taskTable+channel, 4, (u32)0x00000000);	/* var[4] */
	MCD_SET_VAR(taskTable+channel, 5, (u32)0x00000000);	/* var[5] */
	MCD_SET_VAR(taskTable+channel, 6, (u32)0x00000000);	/* var[6] */
	MCD_SET_VAR(taskTable+channel, 7, (u32)0x00000000);	/* var[7] */
	MCD_SET_VAR(taskTable+channel, 8, (u32)0x00000000);	/* var[8] */
	MCD_SET_VAR(taskTable+channel, 9, (u32)0x00000000);	/* var[9] */
	MCD_SET_VAR(taskTable+channel, 10, (u32)0x00000000);	/* var[10] */
	MCD_SET_VAR(taskTable+channel, 12, (u32)0x00000000);	/* var[12] */
	MCD_SET_VAR(taskTable+channel, 13, (u32)0x0000ffff);	/* var[13] */
	MCD_SET_VAR(taskTable+channel, 14, (u32)0xffffffff);	/* var[14] */
	MCD_SET_VAR(taskTable+channel, 15, (u32)0x00000004);	/* var[15] */
	MCD_SET_VAR(taskTable+channel, 16, (u32)0x00000008);	/* var[16] */
	MCD_SET_VAR(taskTable+channel, 24, (u32)0x00000000);	/* inc[0] */
	MCD_SET_VAR(taskTable+channel, 25, (u32)0x60000000);	/* inc[1] */
	MCD_SET_VAR(taskTable+channel, 26, (u32)0x40000000);	/* inc[2] */
	MCD_SET_VAR(taskTable+channel, 27, (u32)0xc000fffc);	/* inc[3] */
	MCD_SET_VAR(taskTable+channel, 28, (u32)0xe0000004);	/* inc[4] */
	MCD_SET_VAR(taskTable+channel, 29, (u32)0x80000000);	/* inc[5] */
	MCD_SET_VAR(taskTable+channel, 30, (u32)0x4000ffff);	/* inc[6] */
	MCD_SET_VAR(taskTable+channel, 31, (u32)0xe0000001);	/* inc[7] */

    /*enable the task*/
    MCD_dmaBar->taskControl[channel] |= (u16)0x8000; /* add a MACRO HERE TBD*/

}

#endif /* NETWORK */
