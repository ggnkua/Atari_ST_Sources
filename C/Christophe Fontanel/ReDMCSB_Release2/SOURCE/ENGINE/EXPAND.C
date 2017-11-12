#include "DEFS.H"

overlay "memory"

VOID F466_rzzz_EXPAND_GraphicToBitmap(P871_puc_Graphic, P872_puc_Bitmap, P873_i_X, P874_i_Y)
unsigned char* P871_puc_Graphic;
unsigned char* P872_puc_Bitmap;
int P873_i_X;
int P874_i_Y;
{
        asm {
                        movem.l D4-D7/A2-A6,-(A7)
                        movea.l P871_puc_Graphic(A6),A0
                        movea.l P872_puc_Bitmap(A6),A1
                        move.w  P873_i_X(A6),D5
                        move.w  P874_i_Y(A6),D4
                        move.w  (A0)+,D7                        /* Bitmap width in pixels */
                        move.w  (A0)+,D6                        /* Bitmap height in pixels */
                        add.w   #0x000F,D7
                        lsr.w   #1,D7
                        and.w   #0xFFF8,D7                      /* Byte width (after normalization to make sure the width is a multiple of 16 pixels = 8 bytes = 1 unit) */
                        cmpa.l  #0x00000000,A1
                        bne.s   T466_001                        /* Branch if bitmap address is not null else expand directly to the physical screen memory. In the game this condition is always true as the function is always called with a non null value for P872_puc_Bitmap */
                        move.l  A0,-(A7)                        /* Backup A0 to the stack */
                        move.w  #0x0002,-(A7)                   /* XBIOS function $02: void *Physbase(void); Returns the physical start address of the video memory */
                        trap    #14
                        addq.l  #2,A7
                        movea.l D0,A1                           /* A1 = Address of physical video memory */
                        movea.l (A7)+,A0                        /* Restore A0 from the stack */
                        move.w  #160,D0
                        cmp.w   D0,D7
                        beq.s   T466_001                        /* Branch if normalized bitmap width in bytes = 160 bytes = 320 pixels */
                        lsr.w   #1,D5                           /* Convert destination X in pixels to destination X in bytes */
                        and.w   #0xFFF8,D5                      /* Convert destination X in bytes to destination X in number of units (16 pixels = 8 bytes) */
                        adda.w  D5,A1
                        mulu.w  D0,D4
                        adda.w  D4,A1                           /* Address of first word to modify at X, Y in bitmap */
                        movea.l A1,A3
                        adda.w  D7,A3
                        subq.w  #1,D6
                        mulu.w  D0,D6
                        add.l   A3,D6                           /* Address of the first word after the last word of bitmap data */
                        move.w  D0,D4                           /* D4 = 160. Screen size in bytes */
                        sub.w   D7,D4
                        move.w  D4,D7
                        swap    D7                              /* Most significant word in D7 = screen size in bytes - bitmap width in bytes */
                        move.w  D0,D7                           /* Least significant word in D7 = 160 */
                        bra.s   T466_002
                T466_001:
                        mulu.w  D7,D6                           /* D6 = bitmap size in bytes */
                        movea.l A1,A3                           /* Address of bitmap */
                        adda.l  D6,A3
                        move.l  A3,D6                           /* Address of the first word after the last word of bitmap data */
                T466_002:
                        clr.l   (A1)                            /* Clear the first bitmap unit to prepare the first draw operation */
                        clr.l   4(A1)
                        moveq   #0x0F,D0                        /* Index of the first pixel left to draw in current bitmap unit */
                        moveq   #0,D4
                        lea     V466_1_Masks1(PC),A4
                        lea     V466_2_Masks2(PC),A5
                        lea     V466_3_BitmapUnits(PC),A6
                T466_003_ProcessBitmapCommand:
                        move.b  (A0)+,D3
                        move.b  D3,D2
                        bmi.s   T466_008_MultiByteCommand
                        lsr.b   #4,D3
                        beq.s   T466_012
                        and.w   #0x000F,D2
                        moveq   #1,D1
                        add.b   D3,D1
                T466_004:
                        lsl.w   #3,D2
                        movea.l A6,A2
                        adda.w  D2,A2
                T466_005:
                        bsr.s   T466_013_Subroutine_DrawPixelsInCurrentUnit
                        tst.w   D1
                        beq.s   T466_003_ProcessBitmapCommand
                        cmpi.w  #16,D1
                        bcs.s   T466_005
                        move.l  (A2),D3
                        move.l  4(A2),D5
                        subi.w  #16,D1
                T466_006:
                        move.l  D3,(A1)+
                        move.l  D5,(A1)+
                        cmpa.l  A1,A3
                        bne.s   T466_007
                        bsr     T466_018_Subroutine
                T466_007:
                        subi.w  #16,D1
                        bcc.s   T466_006
                        clr.l   (A1)
                        clr.l   4(A1)
                        addi.w  #16,D1
                        bne.s   T466_005
                        bra.s   T466_003_ProcessBitmapCommand
                T466_008_MultiByteCommand:
                        andi.w  #0x000F,D2
                        moveq   #0,D1
                        move.b  (A0)+,D1
                        btst    #6,D3
                        beq.s   T466_009_TwoBytesCommand
                        asl.w   #8,D1
                        move.b  (A0)+,D1
                T466_009_TwoBytesCommand:
                        addq.w  #1,D1
                        btst    #4,D3
                        beq.s   T466_004
                        btst    #5,D3
                        beq     T466_020
                        movea.l A1,A2
                        suba.w  D7,A2
                T466_010_LoopCopy:
                        bsr.s   T466_013_Subroutine_DrawPixelsInCurrentUnit
                        tst.l   D5
                        beq.s   T466_011
                        movea.l D5,A2
                T466_011:
                        addq.l  #8,A2
                        tst.w   D1
                        bne.s   T466_010_LoopCopy
                T466_012:
                        bsr     T466_022_Subroutine_DrawSinglePixel
                        bra     T466_003_ProcessBitmapCommand
                T466_013_Subroutine_DrawPixelsInCurrentUnit: /* Subroutine to draw pixels in the current bitmap unit */
                        move.b  D0,D4
                        add.w   D4,D4
                        add.w   D4,D4
                        move.l  0(A4,D4.w),D3
                        cmp.l   D1,D0
                        bmi.s   T466_014_UnitFull
                        sub.w   D1,D0
                        move.b  D0,D4
                        add.w   D4,D4
                        add.w   D4,D4
                        and.l   0(A5,D4.w),D3
                        moveq   #0,D1
                        bra.s   T466_015_DrawMultiplePixels
                T466_014_UnitFull:
                        sub.w   D0,D1
                        subq.w  #1,D1
                        moveq   #-1,D0
                T466_015_DrawMultiplePixels:
                        move.l  (A2),D5
                        and.l   D3,D5
                        or.l    D5,(A1)+
                        move.l  4(A2),D5
                        and.l   D3,D5
                        or.l    D5,(A1)+
                        moveq   #0,D5
                        tst.w   D0
                        bmi.s   T466_017
                        subq.l  #8,A1
                        rts
                T466_016:
                        addq.l  #8,A1
                T466_017:
                        cmpa.l  A1,A3
                        bne.s   T466_019_ClearUnit
                T466_018_Subroutine:
                        cmp.l   A1,D6
                        beq     T466_042                        /* If end of bitmap has been reached (bitmap is fully expanded) */
                        adda.w  D7,A3
                        swap    D7
                        adda.w  D7,A1
                        move.l  A2,D5
                        add.w   D7,D5                           /* BUG0_01 Coding error without consequence. The 16 bit value in D7 is added to D5 (which contains an address) without extending the value to 32 bit. The resulting address may be incorrect if there is a carry. No consequence as this portion of code is never executed in the game because A3 is always equal to D6 for conditions at T466_017 and T466_018_Subroutine */
                        swap    D7
                T466_019_ClearUnit:
                        moveq   #15,D0
                        clr.l   (A1)
                        clr.l   4(A1)
                        rts
                T466_020:
                        lsr.w   #1,D1
                        bcc.s   T466_021
                        bsr.s   T466_022_Subroutine_DrawSinglePixel
                T466_021:
                        move.b  (A0),D2
                        lsr.b   #4,D2
                        bsr.s   T466_022_Subroutine_DrawSinglePixel
                        move.b  (A0)+,D2
                        bsr.s   T466_022_Subroutine_DrawSinglePixel
                        subq.w  #1,D1
                        bne.s   T466_021
                        bra     T466_003_ProcessBitmapCommand
                T466_022_Subroutine_DrawSinglePixel: /* Subroutine to draw one pixel whose 4 bit color index is stored in D2. The pixel index in the unit is stored in D0 */
                        clr.w   D3
                        bset    D0,D3                           /* D3 is a mask with only one bit set */
                        andi.w  #0x000F,D2                      /* D2 value is 0 to 15 (color index) */
                        add.w   D2,D2                           /* Each entry in jumptable below is 2 bytes large */
                        jmp     2(PC,D2.w)
                T466_023:
                        bra.s   T466_027
                        bra.s   T466_026
                        bra.s   T466_032
                        bra.s   T466_025
                        bra.s   T466_034
                        bra.s   T466_029
                        bra.s   T466_031
                        bra.s   T466_024
                        bra.s   T466_037
                        bra.s   T466_036
                        bra.s   T466_038
                        bra.s   T466_035
                        bra.s   T466_033
                        bra.s   T466_028
                        bra.s   T466_030
                        or.w    D3,6(A1)
                T466_024:
                        or.w    D3,4(A1)
                T466_025:
                        or.w    D3,2(A1)
                T466_026:
                        or.w    D3,(A1)
                T466_027:
                        subq.w  #1,D0
                        bmi     T466_016
                        rts
                T466_028:
                        or.w    D3,6(A1)
                T466_029:
                        or.w    D3,4(A1)
                        or.w    D3,(A1)
                        subq.w  #1,D0
                        bmi     T466_016
                        rts
                T466_030:
                        or.w    D3,6(A1)
                T466_031:
                        or.w    D3,4(A1)
                T466_032:
                        or.w    D3,2(A1)
                        subq.w  #1,D0
                        bmi     T466_016
                        rts
                T466_033:
                        or.w    D3,6(A1)
                T466_034:
                        or.w    D3,4(A1)
                        subq.w  #1,D0
                        bmi     T466_016
                        rts
                T466_035:
                        or.w    D3,2(A1)
                T466_036:
                        or.w    D3,(A1)
                T466_037:
                        or.w    D3,6(A1)
                        subq.w  #1,D0
                        bmi     T466_016
                        rts
                T466_038:
                        or.w    D3,6(A1)
                        or.w    D3,2(A1)
                        subq.w  #1,D0
                        bmi     T466_016
                        rts
                V466_1_Masks1:                                     /* Two tables of 16 long binary masks. One mask from each table may be combined with AND to form the mask of bits to manipulate in a bitmap unit. Actually the values in these tables are longs but using dc.l produces wrong code because of a bug in the Megamax C compiler */
                        dc.w    0x0001,0x0001,0x0003,0x0003
                        dc.w    0x0007,0x0007,0x000F,0x000F
                        dc.w    0x001F,0x001F,0x003F,0x003F
                        dc.w    0x007F,0x007F,0x00FF,0x00FF
                        dc.w    0x01FF,0x01FF,0x03FF,0x03FF
                        dc.w    0x07FF,0x07FF,0x0FFF,0x0FFF
                        dc.w    0x1FFF,0x1FFF,0x3FFF,0x3FFF
                        dc.w    0x7FFF,0x7FFF,0xFFFF,0xFFFF
                V466_2_Masks2:
                        dc.w    0xFFFE,0xFFFE,0xFFFC,0xFFFC
                        dc.w    0xFFF8,0xFFF8,0xFFF0,0xFFF0
                        dc.w    0xFFE0,0xFFE0,0xFFC0,0xFFC0
                        dc.w    0xFF80,0xFF80,0xFF00,0xFF00
                        dc.w    0xFE00,0xFE00,0xFC00,0xFC00
                        dc.w    0xF800,0xF800,0xF000,0xF000
                        dc.w    0xE000,0xE000,0xC000,0xC000
                        dc.w    0x8000,0x8000,0x0000,0x0000
                V466_3_BitmapUnits:                             /* For each color index 0 to 15, a bitmap unit (4 words, 8 bytes, 16 pixels) where all pixels have the corresponding colox index. These bitmap units are used as a source of pixel data when drawing multiple pixels of the same color */
                        dc.w    0x0000,0x0000,0x0000,0x0000
                        dc.w    0xFFFF,0x0000,0x0000,0x0000
                        dc.w    0x0000,0xFFFF,0x0000,0x0000
                        dc.w    0xFFFF,0xFFFF,0x0000,0x0000
                        dc.w    0x0000,0x0000,0xFFFF,0x0000
                        dc.w    0xFFFF,0x0000,0xFFFF,0x0000
                        dc.w    0x0000,0xFFFF,0xFFFF,0x0000
                        dc.w    0xFFFF,0xFFFF,0xFFFF,0x0000
                        dc.w    0x0000,0x0000,0x0000,0xFFFF
                        dc.w    0xFFFF,0x0000,0x0000,0xFFFF
                        dc.w    0x0000,0xFFFF,0x0000,0xFFFF
                        dc.w    0xFFFF,0xFFFF,0x0000,0xFFFF
                        dc.w    0x0000,0x0000,0xFFFF,0xFFFF
                        dc.w    0xFFFF,0x0000,0xFFFF,0xFFFF
                        dc.w    0x0000,0xFFFF,0xFFFF,0xFFFF
                        dc.w    0xFFFF,0xFFFF,0xFFFF,0xFFFF
                T466_042:
                        addq.l  #4,A7
                        movem.l (A7)+,D4-D7/A2-A6
        }
}
