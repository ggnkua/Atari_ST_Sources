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
/*
 * File:        MCD_tasks.c
 * Purpose:     Contains task code and structures for Multi-channel DMA
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

u32 MCD_varTab0[];
u32 MCD_varTab1[];
u32 MCD_varTab2[];
u32 MCD_varTab3[];
u32 MCD_varTab4[];
u32 MCD_varTab5[];
u32 MCD_varTab6[];
u32 MCD_varTab7[];
u32 MCD_varTab8[];
u32 MCD_varTab9[];
u32 MCD_varTab10[];
u32 MCD_varTab11[];
u32 MCD_varTab12[];
u32 MCD_varTab13[];
u32 MCD_varTab14[];
u32 MCD_varTab15[];

u32 MCD_funcDescTab0[];
#ifdef MCD_INCLUDE_EU
u32 MCD_funcDescTab1[];
u32 MCD_funcDescTab2[];
u32 MCD_funcDescTab3[];
u32 MCD_funcDescTab4[];
u32 MCD_funcDescTab5[];
u32 MCD_funcDescTab6[];
u32 MCD_funcDescTab7[];
u32 MCD_funcDescTab8[];
u32 MCD_funcDescTab9[];
u32 MCD_funcDescTab10[];
u32 MCD_funcDescTab11[];
u32 MCD_funcDescTab12[];
u32 MCD_funcDescTab13[];
u32 MCD_funcDescTab14[];
u32 MCD_funcDescTab15[];
#endif

u32 MCD_contextSave0[];
u32 MCD_contextSave1[];
u32 MCD_contextSave2[];
u32 MCD_contextSave3[];
u32 MCD_contextSave4[];
u32 MCD_contextSave5[];
u32 MCD_contextSave6[];
u32 MCD_contextSave7[];
u32 MCD_contextSave8[];
u32 MCD_contextSave9[];
u32 MCD_contextSave10[];
u32 MCD_contextSave11[];
u32 MCD_contextSave12[];
u32 MCD_contextSave13[];
u32 MCD_contextSave14[];
u32 MCD_contextSave15[];

u32 MCD_realTaskTableSrc[] =
{
    0x00000000,
    0x00000000,
    (u32)MCD_varTab0,   /* Task 0 Variable Table */
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave0,  /* Task 0 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab1,   /* Task 1 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab1,  /* Task 1 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave1,  /* Task 1 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab2,   /* Task 2 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab2,  /* Task 2 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave2,  /* Task 2 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab3,   /* Task 3 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab3,  /* Task 3 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave3,  /* Task 3 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab4,   /* Task 4 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab4,  /* Task 4 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave4,  /* Task 4 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab5,   /* Task 5 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab5,  /* Task 5 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave5,  /* Task 5 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab6,   /* Task 6 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab6,  /* Task 6 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave6,  /* Task 6 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab7,   /* Task 7 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab7,  /* Task 7 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave7,  /* Task 7 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab8,   /* Task 8 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab8,  /* Task 8 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave8,  /* Task 8 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab9,   /* Task 9 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab9,  /* Task 9 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave9,  /* Task 9 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab10,  /* Task 10 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab10, /* Task 10 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave10, /* Task 10 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab11,  /* Task 11 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab11, /* Task 11 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave11, /* Task 11 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab12,  /* Task 12 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab12, /* Task 12 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave12, /* Task 12 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab13,  /* Task 13 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab13, /* Task 13 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave13, /* Task 13 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab14,  /* Task 14 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab14, /* Task 14 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave14, /* Task 14 context save space */
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_varTab15,  /* Task 15 Variable Table */
#ifdef MCD_INCLUDE_EU
    (u32)MCD_funcDescTab15, /* Task 15 Function Descriptor Table & Flags */
#else
    (u32)MCD_funcDescTab0,  /* Task 0 Function Descriptor Table & Flags */
#endif
    0x00000000,
    0x00000000,
    (u32)MCD_contextSave15, /* Task 15 context save space */
    0x00000000,
};


u32 MCD_varTab0[] =
{   /* Task 0 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};


u32 MCD_varTab1[] =
{   /* Task 1 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_varTab2[]=
{   /* Task 2 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_varTab3[]=
{   /* Task 3 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_varTab4[]=
{   /* Task 4 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_varTab5[]=
{   /* Task 5 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_varTab6[]=
{   /* Task 6 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_varTab7[]=
{   /* Task 7 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_varTab8[]=
{   /* Task 8 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_varTab9[]=
{   /* Task 9 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_varTab10[]=
{   /* Task 10 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_varTab11[]=
{   /* Task 11 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_varTab12[]=
{   /* Task 12 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_varTab13[]=
{   /* Task 13 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_varTab14[]=
{   /* Task 14 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_varTab15[]=
{   /* Task 15 Variable Table */
    0x00000000, /* var[0] */
    0x00000000, /* var[1] */
    0x00000000, /* var[2] */
    0x00000000, /* var[3] */
    0x00000000, /* var[4] */
    0x00000000, /* var[5] */
    0x00000000, /* var[6] */
    0x00000000, /* var[7] */
    0x00000000, /* var[8] */
    0x00000000, /* var[9] */
    0x00000000, /* var[10] */
    0x00000000, /* var[11] */
    0x00000000, /* var[12] */
    0x00000000, /* var[13] */
    0x00000000, /* var[14] */
    0x00000000, /* var[15] */
    0x00000000, /* var[16] */
    0x00000000, /* var[17] */
    0x00000000, /* var[18] */
    0x00000000, /* var[19] */
    0x00000000, /* var[20] */
    0x00000000, /* var[21] */
    0x00000000, /* var[22] */
    0x00000000, /* var[23] */
    0xe0000000, /* inc[0] */
    0x20000000, /* inc[1] */
    0x2000ffff, /* inc[2] */
    0x00000000, /* inc[3] */
    0x00000000, /* inc[4] */
    0x00000000, /* inc[5] */
    0x00000000, /* inc[6] */
    0x00000000, /* inc[7] */
};

u32 MCD_funcDescTab0[]=
{   /* Task 0 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

#ifdef MCD_INCLUDE_EU
u32 MCD_funcDescTab1[]=
{   /* Task 1 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

u32 MCD_funcDescTab2[]=
{   /* Task 2 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

u32 MCD_funcDescTab3[]=
{   /* Task 3 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

u32 MCD_funcDescTab4[]=
{   /* Task 4 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

u32 MCD_funcDescTab5[]=
{   /* Task 5 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

u32 MCD_funcDescTab6[]=
{   /* Task 6 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

u32 MCD_funcDescTab7[]=
{   /* Task 7 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

u32 MCD_funcDescTab8[]=
{   /* Task 8 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

u32 MCD_funcDescTab9[]=
{   /* Task 9 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

u32 MCD_funcDescTab10[]=
{   /* Task 10 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

u32 MCD_funcDescTab11[]=
{   /* Task 11 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

u32 MCD_funcDescTab12[]=
{   /* Task 12 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

u32 MCD_funcDescTab13[]=
{   /* Task 13 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

u32 MCD_funcDescTab14[]=
{   /* Task 14 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};

u32 MCD_funcDescTab15[]=
{   /* Task 15 Function Descriptor Table */
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0xa0045670, /* mainFunc(), EU# 3 */
    0xa0000000, /* rsduFunc(), EU# 3 */
    0xa0000000, /* crcAccumVal(), EU# 3 */
    0x20000000, /* setCrcAccum(), EU# 3 */
    0x21800000, /* and(), EU# 3 */
    0x21e00000, /* or(), EU# 3 */
    0x20400000, /* add(), EU# 3 */
    0x20500000, /* sub(), EU# 3 */
    0x205a0000, /* andNot(), EU# 3 */
    0x202fa000, /* andReadyBit(), EU# 3 */
    0x202f9000, /* andNotReadyBit(), EU# 3 */
    0x202ea000, /* andWrapBit(), EU# 3 */
    0x202da000, /* andEndFrameBit(), EU# 3 */
    0x202e2000, /* andInterruptBit(), EU# 3 */
    0x202f2000, /* andLoopBit(), EU# 3 */
    0x2020a000, /* andCrcRestartBit(), EU# 3 */
};
#endif /*MCD_INCLUDE_EU*/

u32 MCD_contextSave0[128];  /* Task 0 context save space */
u32 MCD_contextSave1[128];  /* Task 1 context save space */
u32 MCD_contextSave2[128];  /* Task 2 context save space */
u32 MCD_contextSave3[128];  /* Task 3 context save space */
u32 MCD_contextSave4[128];  /* Task 4 context save space */
u32 MCD_contextSave5[128];  /* Task 5 context save space */
u32 MCD_contextSave6[128];  /* Task 6 context save space */
u32 MCD_contextSave7[128];  /* Task 7 context save space */
u32 MCD_contextSave8[128];  /* Task 8 context save space */
u32 MCD_contextSave9[128];  /* Task 9 context save space */
u32 MCD_contextSave10[128]; /* Task 10 context save space */
u32 MCD_contextSave11[128]; /* Task 11 context save space */
u32 MCD_contextSave12[128]; /* Task 12 context save space */
u32 MCD_contextSave13[128]; /* Task 13 context save space */
u32 MCD_contextSave14[128]; /* Task 14 context save space */
u32 MCD_contextSave15[128]; /* Task 15 context save space */

/* Task Descriptor Tables - the guts */
u32 MCD_ChainNoEu_TDT[];
u32 MCD_SingleNoEu_TDT[];
#ifdef MCD_INCLUDE_EU
u32 MCD_ChainEu_TDT[];
u32 MCD_SingleEu_TDT[];
#endif
u32 MCD_ENetRcv_TDT[];
u32 MCD_ENetXmit_TDT[];

u32 MCD_modelTaskTableSrc[]=
{
    (u32)MCD_ChainNoEu_TDT,
    (u32)&((u8*)MCD_ChainNoEu_TDT)[0x00000178],
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_SingleNoEu_TDT,
    (u32)&((u8*)MCD_SingleNoEu_TDT)[0x000000d4],
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
#ifdef MCD_INCLUDE_EU
    (u32)MCD_ChainEu_TDT,
    (u32)&((u8*)MCD_ChainEu_TDT)[0x00000180],
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_SingleEu_TDT,
    (u32)&((u8*)MCD_SingleEu_TDT)[0x000000dc],
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
#endif
    (u32)MCD_ENetRcv_TDT,
    (u32)&((u8*)MCD_ENetRcv_TDT)[0x0000009C],
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    (u32)MCD_ENetXmit_TDT,
    (u32)&((u8*)MCD_ENetXmit_TDT)[0x000000d0],
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
};

u32 MCD_ChainNoEu_TDT[]=
{
    0x80004000, /* 0000(:370):  LCDEXT: idx0 = 0x00000000; ; */
    0x8118801b, /* 0004(:370):  LCD: idx1 = var2; idx1 once var0; idx1 += inc3 */
    0xb8ca0018, /* 0008(:371):    LCD: idx2 = *(idx1 + var20); idx2 once var0; idx2 += inc3 */
    0x10004b10, /* 000C(:372):      DRD1A: var18 = idx2; FN=0 MORE init=0 WS=0 RS=0 */
    0x7000000c, /* 0010(:373):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=12 EXT MORE init=0 WS=0 RS=0 */
    0x024cf89f, /* 0014(:373):      DRD2B1: var9 = EU3(); EU3(idx2)  */
    0x60000009, /* 0018(:374):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=9 EXT init=0 WS=0 RS=0 */
    0x080cf89f, /* 001C(:374):      DRD2B1: idx0 = EU3(); EU3(idx2)  */
    0x000001f8, /* 0020(:0):    NOP */
    0x98180524, /* 0024(:378):  LCD: idx0 = idx0; idx0 != var20; idx0 += inc4 */
    0x8118801b, /* 0028(:380):    LCD: idx1 = var2; idx1 once var0; idx1 += inc3 */
    0xf8ca001a, /* 002C(:381):      LCDEXT: idx2 = *(idx1 + var20 + 8); idx2 once var0; idx2 += inc3 */
    0xb8ca601b, /* 0030(:382):      LCD: idx3 = *(idx1 + var20 + 12); ; idx3 += inc3 */
    0x10004310, /* 0034(:384):        DRD1A: var16 = idx2; FN=0 MORE init=0 WS=0 RS=0 */
    0x00001718, /* 0038(:385):        DRD1A: var5 = idx3; FN=0 init=0 WS=0 RS=0 */
    0xb8ca001d, /* 003C(:387):      LCD: idx2 = *(idx1 + var20 + 20); idx2 once var0; idx2 += inc3 */
    0x10001f10, /* 0040(:388):        DRD1A: var7 = idx2; FN=0 MORE init=0 WS=0 RS=0 */
    0x60000007, /* 0044(:389):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=7 EXT init=0 WS=0 RS=0 */
    0x020cf893, /* 0048(:389):        DRD2B1: var8 = EU3(); EU3(idx2,var19)  */
    0x98ca001c, /* 004C(:391):      LCD: idx2 = idx1 + var20 + 4; idx2 once var0; idx2 += inc3 */
    0x00000710, /* 0050(:392):        DRD1A: var1 = idx2; FN=0 init=0 WS=0 RS=0 */
    0x98ca8018, /* 0054(:393):      LCD: idx2 = idx1 + var21; idx2 once var0; idx2 += inc3 */
    0x10002b10, /* 0058(:394):        DRD1A: var10 = idx2; FN=0 MORE init=0 WS=0 RS=0 */
    0x0000c828, /* 005C(:395):        DRD1A: *idx2 = var5; FN=0 init=0 WS=0 RS=0 */
    0x000001f8, /* 0060(:0):      NOP */
    0xc14ae018, /* 0064(:399):    LCDEXT: idx1 = var2 + var21; ; idx1 += inc3 */
    0xc004a51d, /* 0068(:399):    LCDEXT: idx2 = var0, idx3 = var9; idx3 == var20; idx2 += inc3, idx3 += inc5 */
    0x811a601b, /* 006C(:400):    LCD: idx4 = var2; ; idx4 += inc3 */
    0xc28a21c2, /* 0070(:403):      LCDEXT: idx5 = var5, idx6 = var20; idx6 < var7; idx5 += inc0, idx6 += inc2 */
    0x881be009, /* 0074(:403):      LCD: idx7 = var16; ; idx7 += inc1 */
    0x03fed7b8, /* 0078(:406):        DRD1A: *idx7; FN=0 init=31 WS=3 RS=3 */
    0xda9b001b, /* 007C(:408):      LCDEXT: idx5 = idx5, idx6 = idx6; idx5 once var0; idx5 += inc3, idx6 += inc3 */
    0x9b9be01b, /* 0080(:408):      LCD: idx7 = idx7; ; idx7 += inc3 */
    0x1000cb20, /* 0084(:409):        DRD1A: *idx2 = idx4; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 0088(:410):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf896, /* 008C(:410):        DRD2B1: idx2 = EU3(); EU3(idx2,var22)  */
    0x1000cb28, /* 0090(:411):        DRD1A: *idx2 = idx5; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 0094(:412):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf896, /* 0098(:412):        DRD2B1: idx2 = EU3(); EU3(idx2,var22)  */
    0x1000cb30, /* 009C(:413):        DRD1A: *idx2 = idx6; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 00A0(:414):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf896, /* 00A4(:414):        DRD2B1: idx2 = EU3(); EU3(idx2,var22)  */
    0x1000cb38, /* 00A8(:415):        DRD1A: *idx2 = idx7; FN=0 MORE init=0 WS=0 RS=0 */
    0x0000c728, /* 00AC(:416):        DRD1A: *idx1 = idx5; FN=0 init=0 WS=0 RS=0 */
    0x000001f8, /* 00B0(:0):      NOP */
    0xc14ae018, /* 00B4(:420):    LCDEXT: idx1 = var2 + var21; ; idx1 += inc3 */
    0xc004a5dd, /* 00B8(:420):    LCDEXT: idx2 = var0, idx3 = var9; idx3 == var23; idx2 += inc3, idx3 += inc5 */
    0x811a601b, /* 00BC(:421):    LCD: idx4 = var2; ; idx4 += inc3 */
    0xda9b001b, /* 00C0(:424):      LCDEXT: idx5 = idx5, idx6 = idx6; idx5 once var0; idx5 += inc3, idx6 += inc3 */
    0x9b9be01b, /* 00C4(:424):      LCD: idx7 = idx7; ; idx7 += inc3 */
    0x0000d3a0, /* 00C8(:425):        DRD1A: *idx4; FN=0 init=0 WS=0 RS=0 */
    0xc28a21c2, /* 00CC(:427):      LCDEXT: idx5 = var5, idx6 = var20; idx6 < var7; idx5 += inc0, idx6 += inc2 */
    0x881be009, /* 00D0(:427):      LCD: idx7 = var16; ; idx7 += inc1 */
    0x0bfed7b8, /* 00D4(:430):        DRD1A: *idx7; FN=0 TFD init=31 WS=3 RS=3 */
    0xda9b001b, /* 00D8(:432):      LCDEXT: idx5 = idx5, idx6 = idx6; idx5 once var0; idx5 += inc3, idx6 += inc3 */
    0x9b9be01b, /* 00DC(:432):      LCD: idx7 = idx7; ; idx7 += inc3 */
    0x1000cb20, /* 00E0(:433):        DRD1A: *idx2 = idx4; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 00E4(:434):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf896, /* 00E8(:434):        DRD2B1: idx2 = EU3(); EU3(idx2,var22)  */
    0x1000cb28, /* 00EC(:435):        DRD1A: *idx2 = idx5; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 00F0(:436):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf896, /* 00F4(:436):        DRD2B1: idx2 = EU3(); EU3(idx2,var22)  */
    0x1000cb30, /* 00F8(:437):        DRD1A: *idx2 = idx6; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 00FC(:438):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf896, /* 0100(:438):        DRD2B1: idx2 = EU3(); EU3(idx2,var22)  */
    0x1000cb38, /* 0104(:439):        DRD1A: *idx2 = idx7; FN=0 MORE init=0 WS=0 RS=0 */
    0x0000c728, /* 0108(:440):        DRD1A: *idx1 = idx5; FN=0 init=0 WS=0 RS=0 */
    0x000001f8, /* 010C(:0):      NOP */
    0x8118801b, /* 0110(:444):    LCD: idx1 = var2; idx1 once var0; idx1 += inc3 */
    0x8a19001b, /* 0114(:446):      LCD: idx2 = var20; idx2 once var0; idx2 += inc3 */
    0x6000000e, /* 0118(:447):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=14 EXT init=0 WS=0 RS=0 */
    0x088cf49f, /* 011C(:447):        DRD2B1: idx2 = EU3(); EU3(var18)  */
    0xd9190536, /* 0120(:448):      LCDEXT: idx2 = idx2; idx2 == var20; idx2 += inc6 */
    0x98ca0018, /* 0124(:448):      LCD: idx3 = idx1 + var20; idx3 once var0; idx3 += inc3 */
    0x6000000a, /* 0128(:450):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=10 EXT init=0 WS=0 RS=0 */
    0x0cccfcdf, /* 012C(:450):        DRD2B1: *idx3 = EU3(); EU3(*idx3)  */
    0x000001f8, /* 0130(:0):      NOP */
    0xa14a001e, /* 0134(:453):    LCD: idx1 = *(var2 + var20 + 24); idx1 once var0; idx1 += inc3 */
    0x10000b08, /* 0138(:454):      DRD1A: var2 = idx1; FN=0 MORE init=0 WS=0 RS=0 */
    0x10002c90, /* 013C(:455):      DRD1A: var11 = var18; FN=0 MORE init=0 WS=0 RS=0 */
    0xb8ca0018, /* 0140(:456):      LCD: idx2 = *(idx1 + var20); idx2 once var0; idx2 += inc3 */
    0x10004b10, /* 0144(:457):        DRD1A: var18 = idx2; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000009, /* 0148(:458):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=9 EXT MORE init=0 WS=0 RS=0 */
    0x080cf89f, /* 014C(:458):        DRD2B1: idx0 = EU3(); EU3(idx2)  */
    0x6000000c, /* 0150(:459):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=12 EXT init=0 WS=0 RS=0 */
    0x024cf89f, /* 0154(:459):        DRD2B1: var9 = EU3(); EU3(idx2)  */
    0x000001f8, /* 0158(:0):      NOP */
    0x8a18801b, /* 015C(:465):    LCD: idx1 = var20; idx1 once var0; idx1 += inc3 */
    0x7000000d, /* 0160(:466):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=13 EXT MORE init=0 WS=0 RS=0 */
    0x084cf2df, /* 0164(:466):      DRD2B1: idx1 = EU3(); EU3(var11)  */
    0xd899053f, /* 0168(:467):      LCDEXT: idx2 = idx1; idx2 > var20; idx2 += inc7 */
    0x8019801b, /* 016C(:467):      LCD: idx3 = var0; idx3 once var0; idx3 += inc3 */
    0x040001f8, /* 0170(:468):        DRD1A: FN=0 INT init=0 WS=0 RS=0 */
    0x000001f8, /* 0174(:0):      NOP */
    0x000001f8, /* 0178(:0):    NOP */
};
u32 MCD_SingleNoEu_TDT[]=
{
    0x8318001b, /* 0000(:646):  LCD: idx0 = var6; idx0 once var0; idx0 += inc3 */
    0x7000000c, /* 0004(:647):    DRD2A: EU0=0 EU1=0 EU2=0 EU3=12 EXT MORE init=0 WS=0 RS=0 */
    0x080cf81f, /* 0008(:647):    DRD2B1: idx0 = EU3(); EU3(idx0)  */
    0x8318801b, /* 000C(:648):    LCD: idx1 = var6; idx1 once var0; idx1 += inc3 */
    0x6000000d, /* 0010(:649):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=13 EXT init=0 WS=0 RS=0 */
    0x084cf85f, /* 0014(:649):      DRD2B1: idx1 = EU3(); EU3(idx1)  */
    0x000001f8, /* 0018(:0):    NOP */
    0x8498001b, /* 001C(:653):  LCD: idx0 = var9; idx0 once var0; idx0 += inc3 */
    0x7000000c, /* 0020(:654):    DRD2A: EU0=0 EU1=0 EU2=0 EU3=12 EXT MORE init=0 WS=0 RS=0 */
    0x020cf81f, /* 0024(:654):    DRD2B1: var8 = EU3(); EU3(idx0)  */
    0x6000000d, /* 0028(:655):    DRD2A: EU0=0 EU1=0 EU2=0 EU3=13 EXT init=0 WS=0 RS=0 */
    0x028cf81f, /* 002C(:655):    DRD2B1: var10 = EU3(); EU3(idx0)  */
    0xc404601b, /* 0030(:658):  LCDEXT: idx0 = var8, idx1 = var8; ; idx0 += inc3, idx1 += inc3 */
    0xc00423dc, /* 0034(:658):  LCDEXT: idx2 = var0, idx3 = var8; idx3 == var15; idx2 += inc3, idx3 += inc4 */
    0x809a601b, /* 0038(:659):  LCD: idx4 = var1; ; idx4 += inc3 */
    0xc207a182, /* 003C(:662):    LCDEXT: idx5 = var4, idx6 = var15; idx6 < var6; idx5 += inc0, idx6 += inc2 */
    0x869be009, /* 0040(:662):    LCD: idx7 = var13; ; idx7 += inc1 */
    0x03fed7b8, /* 0044(:665):      DRD1A: *idx7; FN=0 init=31 WS=3 RS=3 */
    0xda9b001b, /* 0048(:667):    LCDEXT: idx5 = idx5, idx6 = idx6; idx5 once var0; idx5 += inc3, idx6 += inc3 */
    0x9b9be01b, /* 004C(:667):    LCD: idx7 = idx7; ; idx7 += inc3 */
    0x70000006, /* 0050(:669):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf890, /* 0054(:669):      DRD2B1: idx2 = EU3(); EU3(idx2,var16)  */
    0x1000cb28, /* 0058(:670):      DRD1A: *idx2 = idx5; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 005C(:671):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf890, /* 0060(:671):      DRD2B1: idx2 = EU3(); EU3(idx2,var16)  */
    0x1000cb30, /* 0064(:672):      DRD1A: *idx2 = idx6; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 0068(:673):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf890, /* 006C(:673):      DRD2B1: idx2 = EU3(); EU3(idx2,var16)  */
    0x0000cb38, /* 0070(:674):      DRD1A: *idx2 = idx7; FN=0 init=0 WS=0 RS=0 */
    0x000001f8, /* 0074(:0):    NOP */
    0xc404601b, /* 0078(:678):  LCDEXT: idx0 = var8, idx1 = var8; ; idx0 += inc3, idx1 += inc3 */
    0xc004245c, /* 007C(:678):  LCDEXT: idx2 = var0, idx3 = var8; idx3 == var17; idx2 += inc3, idx3 += inc4 */
    0x809a601b, /* 0080(:679):  LCD: idx4 = var1; ; idx4 += inc3 */
    0xda9b001b, /* 0084(:682):    LCDEXT: idx5 = idx5, idx6 = idx6; idx5 once var0; idx5 += inc3, idx6 += inc3 */
    0x9b9be01b, /* 0088(:682):    LCD: idx7 = idx7; ; idx7 += inc3 */
    0x0000d3a0, /* 008C(:683):      DRD1A: *idx4; FN=0 init=0 WS=0 RS=0 */
    0xc207a182, /* 0090(:685):    LCDEXT: idx5 = var4, idx6 = var15; idx6 < var6; idx5 += inc0, idx6 += inc2 */
    0x869be009, /* 0094(:685):    LCD: idx7 = var13; ; idx7 += inc1 */
    0x0bfed7b8, /* 0098(:688):      DRD1A: *idx7; FN=0 TFD init=31 WS=3 RS=3 */
    0xda9b001b, /* 009C(:690):    LCDEXT: idx5 = idx5, idx6 = idx6; idx5 once var0; idx5 += inc3, idx6 += inc3 */
    0x9b9be01b, /* 00A0(:690):    LCD: idx7 = idx7; ; idx7 += inc3 */
    0x70000006, /* 00A4(:692):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf890, /* 00A8(:692):      DRD2B1: idx2 = EU3(); EU3(idx2,var16)  */
    0x1000cb28, /* 00AC(:693):      DRD1A: *idx2 = idx5; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 00B0(:694):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf890, /* 00B4(:694):      DRD2B1: idx2 = EU3(); EU3(idx2,var16)  */
    0x1000cb30, /* 00B8(:695):      DRD1A: *idx2 = idx6; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 00BC(:696):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf890, /* 00C0(:696):      DRD2B1: idx2 = EU3(); EU3(idx2,var16)  */
    0x0000cb38, /* 00C4(:697):      DRD1A: *idx2 = idx7; FN=0 init=0 WS=0 RS=0 */
    0x000001f8, /* 00C8(:0):    NOP */
    0xc51803ed, /* 00CC(:701):  LCDEXT: idx0 = var10; idx0 > var15; idx0 += inc5 */
    0x8018801b, /* 00D0(:701):  LCD: idx1 = var0; idx1 once var0; idx1 += inc3 */
    0x040001f8, /* 00D4(:702):    DRD1A: FN=0 INT init=0 WS=0 RS=0 */
};
#ifdef MCD_INCLUDE_EU
u32 MCD_ChainEu_TDT[]=
{
    0x80004000, /* 0000(:928):  LCDEXT: idx0 = 0x00000000; ; */
    0x8118801b, /* 0004(:928):  LCD: idx1 = var2; idx1 once var0; idx1 += inc3 */
    0xb8ca0018, /* 0008(:929):    LCD: idx2 = *(idx1 + var20); idx2 once var0; idx2 += inc3 */
    0x10004b10, /* 000C(:930):      DRD1A: var18 = idx2; FN=0 MORE init=0 WS=0 RS=0 */
    0x7000000c, /* 0010(:931):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=12 EXT MORE init=0 WS=0 RS=0 */
    0x024cf89f, /* 0014(:931):      DRD2B1: var9 = EU3(); EU3(idx2)  */
    0x60000009, /* 0018(:932):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=9 EXT init=0 WS=0 RS=0 */
    0x080cf89f, /* 001C(:932):      DRD2B1: idx0 = EU3(); EU3(idx2)  */
    0x000001f8, /* 0020(:0):    NOP */
    0x98180524, /* 0024(:936):  LCD: idx0 = idx0; idx0 != var20; idx0 += inc4 */
    0x8118801b, /* 0028(:938):    LCD: idx1 = var2; idx1 once var0; idx1 += inc3 */
    0xf8ca001a, /* 002C(:939):      LCDEXT: idx2 = *(idx1 + var20 + 8); idx2 once var0; idx2 += inc3 */
    0xb8ca601b, /* 0030(:940):      LCD: idx3 = *(idx1 + var20 + 12); ; idx3 += inc3 */
    0x10004310, /* 0034(:942):        DRD1A: var16 = idx2; FN=0 MORE init=0 WS=0 RS=0 */
    0x00001718, /* 0038(:943):        DRD1A: var5 = idx3; FN=0 init=0 WS=0 RS=0 */
    0xb8ca001d, /* 003C(:945):      LCD: idx2 = *(idx1 + var20 + 20); idx2 once var0; idx2 += inc3 */
    0x10001f10, /* 0040(:946):        DRD1A: var7 = idx2; FN=0 MORE init=0 WS=0 RS=0 */
    0x60000007, /* 0044(:947):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=7 EXT init=0 WS=0 RS=0 */
    0x020cf893, /* 0048(:947):        DRD2B1: var8 = EU3(); EU3(idx2,var19)  */
    0x98ca001c, /* 004C(:949):      LCD: idx2 = idx1 + var20 + 4; idx2 once var0; idx2 += inc3 */
    0x00000710, /* 0050(:950):        DRD1A: var1 = idx2; FN=0 init=0 WS=0 RS=0 */
    0x98ca8018, /* 0054(:951):      LCD: idx2 = idx1 + var21; idx2 once var0; idx2 += inc3 */
    0x10002b10, /* 0058(:952):        DRD1A: var10 = idx2; FN=0 MORE init=0 WS=0 RS=0 */
    0x0000c828, /* 005C(:953):        DRD1A: *idx2 = var5; FN=0 init=0 WS=0 RS=0 */
    0x000001f8, /* 0060(:0):      NOP */
    0xc14ae018, /* 0064(:957):    LCDEXT: idx1 = var2 + var21; ; idx1 += inc3 */
    0xc004a51d, /* 0068(:957):    LCDEXT: idx2 = var0, idx3 = var9; idx3 == var20; idx2 += inc3, idx3 += inc5 */
    0x811a601b, /* 006C(:958):    LCD: idx4 = var2; ; idx4 += inc3 */
    0xc28a21c2, /* 0070(:961):      LCDEXT: idx5 = var5, idx6 = var20; idx6 < var7; idx5 += inc0, idx6 += inc2 */
    0x881be009, /* 0074(:961):      LCD: idx7 = var16; ; idx7 += inc1 */
    0x63fe0000, /* 0078(:964):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=0 EXT init=31 WS=3 RS=3 */
    0x0d4cfddf, /* 007C(:964):        DRD2B1: *idx5 = EU3(); EU3(*idx7)  */
    0xda9b001b, /* 0080(:966):      LCDEXT: idx5 = idx5, idx6 = idx6; idx5 once var0; idx5 += inc3, idx6 += inc3 */
    0x9b9be01b, /* 0084(:966):      LCD: idx7 = idx7; ; idx7 += inc3 */
    0x1000cb20, /* 0088(:967):        DRD1A: *idx2 = idx4; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 008C(:968):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf896, /* 0090(:968):        DRD2B1: idx2 = EU3(); EU3(idx2,var22)  */
    0x1000cb28, /* 0094(:969):        DRD1A: *idx2 = idx5; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 0098(:970):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf896, /* 009C(:970):        DRD2B1: idx2 = EU3(); EU3(idx2,var22)  */
    0x1000cb30, /* 00A0(:971):        DRD1A: *idx2 = idx6; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 00A4(:972):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf896, /* 00A8(:972):        DRD2B1: idx2 = EU3(); EU3(idx2,var22)  */
    0x1000cb38, /* 00AC(:973):        DRD1A: *idx2 = idx7; FN=0 MORE init=0 WS=0 RS=0 */
    0x0000c728, /* 00B0(:974):        DRD1A: *idx1 = idx5; FN=0 init=0 WS=0 RS=0 */
    0x000001f8, /* 00B4(:0):      NOP */
    0xc14ae018, /* 00B8(:978):    LCDEXT: idx1 = var2 + var21; ; idx1 += inc3 */
    0xc004a5dd, /* 00BC(:978):    LCDEXT: idx2 = var0, idx3 = var9; idx3 == var23; idx2 += inc3, idx3 += inc5 */
    0x811a601b, /* 00C0(:979):    LCD: idx4 = var2; ; idx4 += inc3 */
    0xda9b001b, /* 00C4(:982):      LCDEXT: idx5 = idx5, idx6 = idx6; idx5 once var0; idx5 += inc3, idx6 += inc3 */
    0x9b9be01b, /* 00C8(:982):      LCD: idx7 = idx7; ; idx7 += inc3 */
    0x0000d3a0, /* 00CC(:983):        DRD1A: *idx4; FN=0 init=0 WS=0 RS=0 */
    0xc28a21c2, /* 00D0(:985):      LCDEXT: idx5 = var5, idx6 = var20; idx6 < var7; idx5 += inc0, idx6 += inc2 */
    0x881be009, /* 00D4(:985):      LCD: idx7 = var16; ; idx7 += inc1 */
    0x6bfe0000, /* 00D8(:988):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=0 TFD EXT init=31 WS=3 RS=3 */
    0x0d4cfddf, /* 00DC(:988):        DRD2B1: *idx5 = EU3(); EU3(*idx7)  */
    0xda9b001b, /* 00E0(:990):      LCDEXT: idx5 = idx5, idx6 = idx6; idx5 once var0; idx5 += inc3, idx6 += inc3 */
    0x9b9be01b, /* 00E4(:990):      LCD: idx7 = idx7; ; idx7 += inc3 */
    0x1000cb20, /* 00E8(:991):        DRD1A: *idx2 = idx4; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 00EC(:992):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf896, /* 00F0(:992):        DRD2B1: idx2 = EU3(); EU3(idx2,var22)  */
    0x1000cb28, /* 00F4(:993):        DRD1A: *idx2 = idx5; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 00F8(:994):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf896, /* 00FC(:994):        DRD2B1: idx2 = EU3(); EU3(idx2,var22)  */
    0x1000cb30, /* 0100(:995):        DRD1A: *idx2 = idx6; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 0104(:996):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf896, /* 0108(:996):        DRD2B1: idx2 = EU3(); EU3(idx2,var22)  */
    0x1000cb38, /* 010C(:997):        DRD1A: *idx2 = idx7; FN=0 MORE init=0 WS=0 RS=0 */
    0x0000c728, /* 0110(:998):        DRD1A: *idx1 = idx5; FN=0 init=0 WS=0 RS=0 */
    0x000001f8, /* 0114(:0):      NOP */
    0x8118801b, /* 0118(:1002):    LCD: idx1 = var2; idx1 once var0; idx1 += inc3 */
    0x8a19001b, /* 011C(:1004):      LCD: idx2 = var20; idx2 once var0; idx2 += inc3 */
    0x6000000e, /* 0120(:1005):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=14 EXT init=0 WS=0 RS=0 */
    0x088cf49f, /* 0124(:1005):        DRD2B1: idx2 = EU3(); EU3(var18)  */
    0xd9190536, /* 0128(:1006):      LCDEXT: idx2 = idx2; idx2 == var20; idx2 += inc6 */
    0x98ca0018, /* 012C(:1006):      LCD: idx3 = idx1 + var20; idx3 once var0; idx3 += inc3 */
    0x6000000a, /* 0130(:1008):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=10 EXT init=0 WS=0 RS=0 */
    0x0cccfcdf, /* 0134(:1008):        DRD2B1: *idx3 = EU3(); EU3(*idx3)  */
    0x000001f8, /* 0138(:0):      NOP */
    0xa14a001e, /* 013C(:1011):    LCD: idx1 = *(var2 + var20 + 24); idx1 once var0; idx1 += inc3 */
    0x10000b08, /* 0140(:1012):      DRD1A: var2 = idx1; FN=0 MORE init=0 WS=0 RS=0 */
    0x10002c90, /* 0144(:1013):      DRD1A: var11 = var18; FN=0 MORE init=0 WS=0 RS=0 */
    0xb8ca0018, /* 0148(:1014):      LCD: idx2 = *(idx1 + var20); idx2 once var0; idx2 += inc3 */
    0x10004b10, /* 014C(:1015):        DRD1A: var18 = idx2; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000009, /* 0150(:1016):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=9 EXT MORE init=0 WS=0 RS=0 */
    0x080cf89f, /* 0154(:1016):        DRD2B1: idx0 = EU3(); EU3(idx2)  */
    0x6000000c, /* 0158(:1017):        DRD2A: EU0=0 EU1=0 EU2=0 EU3=12 EXT init=0 WS=0 RS=0 */
    0x024cf89f, /* 015C(:1017):        DRD2B1: var9 = EU3(); EU3(idx2)  */
    0x000001f8, /* 0160(:0):      NOP */
    0x8a18801b, /* 0164(:1023):    LCD: idx1 = var20; idx1 once var0; idx1 += inc3 */
    0x7000000d, /* 0168(:1024):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=13 EXT MORE init=0 WS=0 RS=0 */
    0x084cf2df, /* 016C(:1024):      DRD2B1: idx1 = EU3(); EU3(var11)  */
    0xd899053f, /* 0170(:1025):      LCDEXT: idx2 = idx1; idx2 > var20; idx2 += inc7 */
    0x8019801b, /* 0174(:1025):      LCD: idx3 = var0; idx3 once var0; idx3 += inc3 */
    0x040001f8, /* 0178(:1026):        DRD1A: FN=0 INT init=0 WS=0 RS=0 */
    0x000001f8, /* 017C(:0):      NOP */
    0x000001f8, /* 0180(:0):    NOP */
};
u32 MCD_SingleEu_TDT[]=
{
    0x8318001b, /* 0000(:1204):  LCD: idx0 = var6; idx0 once var0; idx0 += inc3 */
    0x7000000c, /* 0004(:1205):    DRD2A: EU0=0 EU1=0 EU2=0 EU3=12 EXT MORE init=0 WS=0 RS=0 */
    0x080cf81f, /* 0008(:1205):    DRD2B1: idx0 = EU3(); EU3(idx0)  */
    0x8318801b, /* 000C(:1206):    LCD: idx1 = var6; idx1 once var0; idx1 += inc3 */
    0x6000000d, /* 0010(:1207):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=13 EXT init=0 WS=0 RS=0 */
    0x084cf85f, /* 0014(:1207):      DRD2B1: idx1 = EU3(); EU3(idx1)  */
    0x000001f8, /* 0018(:0):    NOP */
    0x8498001b, /* 001C(:1211):  LCD: idx0 = var9; idx0 once var0; idx0 += inc3 */
    0x7000000c, /* 0020(:1212):    DRD2A: EU0=0 EU1=0 EU2=0 EU3=12 EXT MORE init=0 WS=0 RS=0 */
    0x020cf81f, /* 0024(:1212):    DRD2B1: var8 = EU3(); EU3(idx0)  */
    0x6000000d, /* 0028(:1213):    DRD2A: EU0=0 EU1=0 EU2=0 EU3=13 EXT init=0 WS=0 RS=0 */
    0x028cf81f, /* 002C(:1213):    DRD2B1: var10 = EU3(); EU3(idx0)  */
    0xc404601b, /* 0030(:1216):  LCDEXT: idx0 = var8, idx1 = var8; ; idx0 += inc3, idx1 += inc3 */
    0xc00423dc, /* 0034(:1216):  LCDEXT: idx2 = var0, idx3 = var8; idx3 == var15; idx2 += inc3, idx3 += inc4 */
    0x809a601b, /* 0038(:1217):  LCD: idx4 = var1; ; idx4 += inc3 */
    0xc207a182, /* 003C(:1220):    LCDEXT: idx5 = var4, idx6 = var15; idx6 < var6; idx5 += inc0, idx6 += inc2 */
    0x869be009, /* 0040(:1220):    LCD: idx7 = var13; ; idx7 += inc1 */
    0x63fe0000, /* 0044(:1223):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=0 EXT init=31 WS=3 RS=3 */
    0x0d4cfddf, /* 0048(:1223):      DRD2B1: *idx5 = EU3(); EU3(*idx7)  */
    0xda9b001b, /* 004C(:1225):    LCDEXT: idx5 = idx5, idx6 = idx6; idx5 once var0; idx5 += inc3, idx6 += inc3 */
    0x9b9be01b, /* 0050(:1225):    LCD: idx7 = idx7; ; idx7 += inc3 */
    0x70000006, /* 0054(:1227):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf890, /* 0058(:1227):      DRD2B1: idx2 = EU3(); EU3(idx2,var16)  */
    0x1000cb28, /* 005C(:1228):      DRD1A: *idx2 = idx5; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 0060(:1229):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf890, /* 0064(:1229):      DRD2B1: idx2 = EU3(); EU3(idx2,var16)  */
    0x1000cb30, /* 0068(:1230):      DRD1A: *idx2 = idx6; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 006C(:1231):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf890, /* 0070(:1231):      DRD2B1: idx2 = EU3(); EU3(idx2,var16)  */
    0x0000cb38, /* 0074(:1232):      DRD1A: *idx2 = idx7; FN=0 init=0 WS=0 RS=0 */
    0x000001f8, /* 0078(:0):    NOP */
    0xc404601b, /* 007C(:1236):  LCDEXT: idx0 = var8, idx1 = var8; ; idx0 += inc3, idx1 += inc3 */
    0xc004245c, /* 0080(:1236):  LCDEXT: idx2 = var0, idx3 = var8; idx3 == var17; idx2 += inc3, idx3 += inc4 */
    0x809a601b, /* 0084(:1237):  LCD: idx4 = var1; ; idx4 += inc3 */
    0xda9b001b, /* 0088(:1240):    LCDEXT: idx5 = idx5, idx6 = idx6; idx5 once var0; idx5 += inc3, idx6 += inc3 */
    0x9b9be01b, /* 008C(:1240):    LCD: idx7 = idx7; ; idx7 += inc3 */
    0x0000d3a0, /* 0090(:1241):      DRD1A: *idx4; FN=0 init=0 WS=0 RS=0 */
    0xc207a182, /* 0094(:1243):    LCDEXT: idx5 = var4, idx6 = var15; idx6 < var6; idx5 += inc0, idx6 += inc2 */
    0x869be009, /* 0098(:1243):    LCD: idx7 = var13; ; idx7 += inc1 */
    0x6bfe0000, /* 009C(:1246):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=0 TFD EXT init=31 WS=3 RS=3 */
    0x0d4cfddf, /* 00A0(:1246):      DRD2B1: *idx5 = EU3(); EU3(*idx7)  */
    0xda9b001b, /* 00A4(:1248):    LCDEXT: idx5 = idx5, idx6 = idx6; idx5 once var0; idx5 += inc3, idx6 += inc3 */
    0x9b9be01b, /* 00A8(:1248):    LCD: idx7 = idx7; ; idx7 += inc3 */
    0x70000006, /* 00AC(:1250):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf890, /* 00B0(:1250):      DRD2B1: idx2 = EU3(); EU3(idx2,var16)  */
    0x1000cb28, /* 00B4(:1251):      DRD1A: *idx2 = idx5; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 00B8(:1252):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf890, /* 00BC(:1252):      DRD2B1: idx2 = EU3(); EU3(idx2,var16)  */
    0x1000cb30, /* 00C0(:1253):      DRD1A: *idx2 = idx6; FN=0 MORE init=0 WS=0 RS=0 */
    0x70000006, /* 00C4(:1254):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=6 EXT MORE init=0 WS=0 RS=0 */
    0x088cf890, /* 00C8(:1254):      DRD2B1: idx2 = EU3(); EU3(idx2,var16)  */
    0x0000cb38, /* 00CC(:1255):      DRD1A: *idx2 = idx7; FN=0 init=0 WS=0 RS=0 */
    0x000001f8, /* 00D0(:0):    NOP */
    0xc51803ed, /* 00D4(:1259):  LCDEXT: idx0 = var10; idx0 > var15; idx0 += inc5 */
    0x8018801b, /* 00D8(:1259):  LCD: idx1 = var0; idx1 once var0; idx1 += inc3 */
    0x040001f8, /* 00DC(:1260):    DRD1A: FN=0 INT init=0 WS=0 RS=0 */
};
#endif
u32 MCD_ENetRcv_TDT[]=
{
    0x80004000, /* 0000(:1334):  LCDEXT: idx0 = 0x00000000; ; */
    0x82188000, /* 0004(:1334):  LCD: idx1 = var4; idx1 once var0; idx1 += inc0 */
    0x10000788, /* 0008(:1335):    DRD1A: var1 = *idx1; FN=0 MORE init=0 WS=0 RS=0 */
    0x60000009, /* 000C(:1336):    DRD2A: EU0=0 EU1=0 EU2=0 EU3=9 EXT init=0 WS=0 RS=0 */
    0x080cf05f, /* 0010(:1336):    DRD2B1: idx0 = EU3(); EU3(var1)  */
    0x98180249, /* 0014(:1339):  LCD: idx0 = idx0; idx0 != var9; idx0 += inc1 */
    0x82448004, /* 0018(:1341):    LCD: idx1 = var4 + var9 + 4; idx1 once var0; idx1 += inc0 */
    0x7000000d, /* 001C(:1342):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=13 EXT MORE init=0 WS=0 RS=0 */
    0x014cf05f, /* 0020(:1342):      DRD2B1: var5 = EU3(); EU3(var1)  */
    0x7000000b, /* 0024(:1343):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=11 EXT MORE init=0 WS=0 RS=0 */
    0x020cf05f, /* 0028(:1343):      DRD2B1: var8 = EU3(); EU3(var1)  */
    0x70000004, /* 002C(:1344):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=4 EXT MORE init=0 WS=0 RS=0 */
    0x018cf04a, /* 0030(:1344):      DRD2B1: var6 = EU3(); EU3(var1,var10)  */
    0x70000004, /* 0034(:1345):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=4 EXT MORE init=0 WS=0 RS=0 */
    0x004cf04b, /* 0038(:1345):      DRD2B1: var1 = EU3(); EU3(var1,var11)  */
    0x00000b88, /* 003C(:1348):      DRD1A: var2 = *idx1; FN=0 init=0 WS=0 RS=0 */
    0xc4838190, /* 0040(:1351):    LCDEXT: idx1 = var9, idx2 = var7; idx1 < var6; idx1 += inc2, idx2 += inc0 */
    0x8119e012, /* 0044(:1351):    LCD: idx3 = var2; ; idx3 += inc2 */
    0x03e0cf90, /* 0048(:1354):      DRD1A: *idx3 = *idx2; FN=0 init=31 WS=0 RS=0 */
    0x81188000, /* 004C(:1357):    LCD: idx1 = var2; idx1 once var0; idx1 += inc0 */
    0x000ac788, /* 0050(:1358):      DRD1A: *idx1 = *idx1; FN=0 init=0 WS=1 RS=1 */
    0xc4838000, /* 0054(:1360):    LCDEXT: idx1 = var9, idx2 = var7; idx1 once var0; idx1 += inc0, idx2 += inc0 */
    0x8219e000, /* 0058(:1360):    LCD: idx3 = var4; ; idx3 += inc0 */
    0x70000004, /* 005C(:1368):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=4 EXT MORE init=0 WS=0 RS=0 */
    0x084cfc8c, /* 0060(:1368):      DRD2B1: idx1 = EU3(); EU3(*idx2,var12)  */
    0x60000005, /* 0064(:1371):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=5 EXT init=0 WS=0 RS=0 */
    0x0cccf841, /* 0068(:1371):      DRD2B1: *idx3 = EU3(); EU3(idx1,var1)  */
    0x82468000, /* 006C(:1377):    LCD: idx1 = var4 + var13; idx1 once var0; idx1 += inc0 */
    0xc419025b, /* 0070(:1379):      LCDEXT: idx2 = var8; idx2 > var9; idx2 += inc3 */
    0x80198000, /* 0074(:1379):      LCD: idx3 = var0; idx3 once var0; idx3 += inc0 */
    0x00008400, /* 0078(:1380):        DRD1A: idx1 = var0; FN=0 init=0 WS=0 RS=0 */
    0x00001308, /* 007C(:1381):      DRD1A: var4 = idx1; FN=0 init=0 WS=0 RS=0 */
    0x82188000, /* 0080(:1384):    LCD: idx1 = var4; idx1 once var0; idx1 += inc0 */
    0x10000788, /* 0084(:1385):      DRD1A: var1 = *idx1; FN=0 MORE init=0 WS=0 RS=0 */
    0x60000009, /* 0088(:1386):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=9 EXT init=0 WS=0 RS=0 */
    0x080cf05f, /* 008C(:1386):      DRD2B1: idx0 = EU3(); EU3(var1)  */
    0xc2988249, /* 0090(:1389):    LCDEXT: idx1 = var5; idx1 != var9; idx1 += inc1 */
    0x80190000, /* 0094(:1389):    LCD: idx2 = var0; idx2 once var0; idx2 += inc0 */
    0x040001f8, /* 0098(:1390):      DRD1A: FN=0 INT init=0 WS=0 RS=0 */
    0x000001f8, /* 009C(:0):    NOP */
};
u32 MCD_ENetXmit_TDT[]=
{
    0x80004000, /* 0000(:1465):  LCDEXT: idx0 = 0x00000000; ; */
    0x81988000, /* 0004(:1465):  LCD: idx1 = var3; idx1 once var0; idx1 += inc0 */
    0x10000788, /* 0008(:1466):    DRD1A: var1 = *idx1; FN=0 MORE init=0 WS=0 RS=0 */
    0x60000009, /* 000C(:1467):    DRD2A: EU0=0 EU1=0 EU2=0 EU3=9 EXT init=0 WS=0 RS=0 */
    0x080cf05f, /* 0010(:1467):    DRD2B1: idx0 = EU3(); EU3(var1)  */
    0x98180309, /* 0014(:1470):  LCD: idx0 = idx0; idx0 != var12; idx0 += inc1 */
    0x80004003, /* 0018(:1472):    LCDEXT: idx1 = 0x00000003; ; */
    0x81c60004, /* 001C(:1472):    LCD: idx2 = var3 + var12 + 4; idx2 once var0; idx2 += inc0 */
    0x7000000d, /* 0020(:1473):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=13 EXT MORE init=0 WS=0 RS=0 */
    0x014cf05f, /* 0024(:1473):      DRD2B1: var5 = EU3(); EU3(var1)  */
    0x7000000b, /* 0028(:1474):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=11 EXT MORE init=0 WS=0 RS=0 */
    0x028cf05f, /* 002C(:1474):      DRD2B1: var10 = EU3(); EU3(var1)  */
    0x7000000c, /* 0030(:1475):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=12 EXT MORE init=0 WS=0 RS=0 */
    0x018cf05f, /* 0034(:1475):      DRD2B1: var6 = EU3(); EU3(var1)  */
    0x70000004, /* 0038(:1476):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=4 EXT MORE init=0 WS=0 RS=0 */
    0x01ccf04d, /* 003C(:1476):      DRD2B1: var7 = EU3(); EU3(var1,var13)  */
    0x10000b90, /* 0040(:1477):      DRD1A: var2 = *idx2; FN=0 MORE init=0 WS=0 RS=0 */
    0x60000004, /* 0044(:1478):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=4 EXT init=0 WS=0 RS=0 */
    0x020cf0a1, /* 0048(:1478):      DRD2B1: var8 = EU3(); EU3(var2,idx1)  */
    0xc3188312, /* 004C(:1481):    LCDEXT: idx1 = var6; idx1 > var12; idx1 += inc2 */
    0x83c70000, /* 0050(:1481):    LCD: idx2 = var7 + var14; idx2 once var0; idx2 += inc0 */
    0x00001f10, /* 0054(:1482):      DRD1A: var7 = idx2; FN=0 init=0 WS=0 RS=0 */
    0xc583a3c3, /* 0058(:1484):    LCDEXT: idx1 = var11, idx2 = var7; idx2 >= var15; idx1 += inc0, idx2 += inc3 */
    0x81042325, /* 005C(:1484):    LCD: idx3 = var2, idx4 = var8; idx4 == var12; idx3 += inc4, idx4 += inc5 */
    0x03e0c798, /* 0060(:1489):      DRD1A: *idx1 = *idx3; FN=0 init=31 WS=0 RS=0 */
    0xd8990000, /* 0064(:1492):    LCDEXT: idx1 = idx1, idx2 = idx2; idx1 once var0; idx1 += inc0, idx2 += inc0 */
    0x9999e000, /* 0068(:1492):    LCD: idx3 = idx3; ; idx3 += inc0 */
    0x000acf98, /* 006C(:1493):      DRD1A: *idx3 = *idx3; FN=0 init=0 WS=1 RS=1 */
    0xd8992306, /* 0070(:1495):    LCDEXT: idx1 = idx1, idx2 = idx2; idx2 > var12; idx1 += inc0, idx2 += inc6 */
    0x9999e03f, /* 0074(:1495):    LCD: idx3 = idx3; ; idx3 += inc7 */
    0x03eac798, /* 0078(:1498):      DRD1A: *idx1 = *idx3; FN=0 init=31 WS=1 RS=1 */
    0xd8990000, /* 007C(:1501):    LCDEXT: idx1 = idx1, idx2 = idx2; idx1 once var0; idx1 += inc0, idx2 += inc0 */
    0x9999e000, /* 0080(:1501):    LCD: idx3 = idx3; ; idx3 += inc0 */
    0x000acf98, /* 0084(:1502):      DRD1A: *idx3 = *idx3; FN=0 init=0 WS=1 RS=1 */
    0xd8990000, /* 0088(:1504):    LCDEXT: idx1 = idx1, idx2 = idx2; idx1 once var0; idx1 += inc0, idx2 += inc0 */
    0x99832302, /* 008C(:1504):    LCD: idx3 = idx3, idx4 = var6; idx4 > var12; idx3 += inc0, idx4 += inc2 */
    0x0beac798, /* 0090(:1507):      DRD1A: *idx1 = *idx3; FN=0 TFD init=31 WS=1 RS=1 */
    0x81988000, /* 0094(:1509):    LCD: idx1 = var3; idx1 once var0; idx1 += inc0 */
    0x6000000a, /* 0098(:1510):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=10 EXT init=0 WS=0 RS=0 */
    0x0c4cfc5f, /* 009C(:1510):      DRD2B1: *idx1 = EU3(); EU3(*idx1)  */
    0x81c80000, /* 00A0(:1512):    LCD: idx1 = var3 + var16; idx1 once var0; idx1 += inc0 */
    0xc5190312, /* 00A4(:1514):      LCDEXT: idx2 = var10; idx2 > var12; idx2 += inc2 */
    0x80198000, /* 00A8(:1514):      LCD: idx3 = var0; idx3 once var0; idx3 += inc0 */
    0x00008400, /* 00AC(:1515):        DRD1A: idx1 = var0; FN=0 init=0 WS=0 RS=0 */
    0x00000f08, /* 00B0(:1516):      DRD1A: var3 = idx1; FN=0 init=0 WS=0 RS=0 */
    0x81988000, /* 00B4(:1519):    LCD: idx1 = var3; idx1 once var0; idx1 += inc0 */
    0x10000788, /* 00B8(:1520):      DRD1A: var1 = *idx1; FN=0 MORE init=0 WS=0 RS=0 */
    0x60000009, /* 00BC(:1521):      DRD2A: EU0=0 EU1=0 EU2=0 EU3=9 EXT init=0 WS=0 RS=0 */
    0x080cf05f, /* 00C0(:1521):      DRD2B1: idx0 = EU3(); EU3(var1)  */
    0xc2988309, /* 00C4(:1524):    LCDEXT: idx1 = var5; idx1 != var12; idx1 += inc1 */
    0x80190000, /* 00C8(:1524):    LCD: idx2 = var0; idx2 once var0; idx2 += inc0 */
    0x040001f8, /* 00CC(:1525):      DRD1A: FN=0 INT init=0 WS=0 RS=0 */
    0x000001f8, /* 00D0(:0):    NOP */
};

#endif
