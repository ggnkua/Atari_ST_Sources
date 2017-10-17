/*********************************************************************
 *
 * Copyright (C) 2004  Motorola, Inc.
 *  MOTOROLA, INC. All Rights Reserved.
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
#ifndef MCD_TSK_INIT_H
#define MCD_TSK_INIT_H 1

/*
 * Do not edit!
 */



/*
 * Task 0
 */
void  MCD_startDmaChainNoEu(int *currBD, short srcIncr, short destIncr, int xferSize, short xferSizeIncr, int *cSave, volatile TaskTableEntry *taskTable, int channel);


/*
 * Task 1
 */
void  MCD_startDmaSingleNoEu(char *srcAddr, short srcIncr, char *destAddr, short destIncr, int dmaSize, int dmaSizeMXferSize, short xferSizeIncr, int flags, int *currBD, int *cSave, volatile TaskTableEntry *taskTable, int channel);


/*
 * Task 2
 */
void  MCD_startDmaChainEu(int *currBD, short srcIncr, short destIncr, int xferSize, short xferSizeIncr, int *cSave, volatile TaskTableEntry *taskTable, int channel);


/*
 * Task 3
 */
void  MCD_startDmaSingleEu(char *srcAddr, short srcIncr, char *destAddr, short destIncr, int dmaSize, int dmaSizeMXferSize, short xferSizeIncr, int flags, int *currBD, int *cSave, volatile TaskTableEntry *taskTable, int channel);


/*
 * Task 4
 */
void  MCD_startDmaENetRcv(char *bDBase, char *currBD, char *rcvFifoPtr, volatile TaskTableEntry *taskTable, int channel);


/*
 * Task 5
 */
void  MCD_startDmaENetXmit(char *bDBase, char *currBD, char *xmitFifoPtr, volatile TaskTableEntry *taskTable, int channel);

#endif  /* MCD_TSK_INIT_H */
