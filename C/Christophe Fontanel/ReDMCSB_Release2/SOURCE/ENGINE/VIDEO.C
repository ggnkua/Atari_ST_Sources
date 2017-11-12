#include "DEFS.H"

overlay "show"

VOID F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(P186_puc_Bitmap_Source, P187_puc_Bitmap_Destination, P188_i_SourcePixelWidth, P189_i_SourceHeight, P190_i_DestinationPixelWidth, P191_i_DestinationHeight, P192_puc_PaletteChanges)
unsigned char* P186_puc_Bitmap_Source;
unsigned char* P187_puc_Bitmap_Destination;
int P188_i_SourcePixelWidth;
int P189_i_SourceHeight;
int P190_i_DestinationPixelWidth;
int P191_i_DestinationHeight;
unsigned char* P192_puc_PaletteChanges;
{
        long L0226_l_HeightRatio;
        long L0227_l_WidthRatio;
        int L0228_i_SourceUnitWidth;


        asm {
                        movem.l D4-D7/A2-A5,-(A7)
                        movea.l P192_puc_PaletteChanges(A6),A5
                        movea.l P186_puc_Bitmap_Source(A6),A0
                        movea.l P187_puc_Bitmap_Destination(A6),A1
                        moveq   #0,D1
                        move.w  P188_i_SourcePixelWidth(A6),D1
                        moveq   #0x0F,D0
                        add.w   D1,D0
                        and.w   #0xFFF0,D0
                        lsr.w   #1,D0
                        move.w  D0,L0228_i_SourceUnitWidth(A6)
                        move.w  P190_i_DestinationPixelWidth(A6),D3
                        moveq   #0x0A,D2
                        lsl.l   D2,D1                                   /* 1024 * P188_i_SourcePixelWidth */
                        divu    D3,D1                                   /* 1024 * P188_i_SourcePixelWidth / P190_i_DestinationPixelWidth */
                        andi.l  #0x0000FFFF,D1
                        lsl.l   #6,D1                                   /* 65536 * P188_i_SourcePixelWidth / P190_i_DestinationPixelWidth */
                        movea.l D1,A2
                        lsr.l   #1,D1                                   /* 32768 * P188_i_SourcePixelWidth / P190_i_DestinationPixelWidth */
                        addi.l  #0x00007FFF,D1                          /* (32768 * P188_i_SourcePixelWidth / P190_i_DestinationPixelWidth) + 32767 */
                        move.l  D1,L0227_l_WidthRatio(A6)
                        moveq   #0,D1
                        move.w  P189_i_SourceHeight(A6),D1
                        lsl.l   D2,D1
                        divu    P191_i_DestinationHeight(A6),D1
                        andi.l  #0x0000FFFF,D1
                        lsl.l   #6,D1
                        move.l  D1,L0226_l_HeightRatio(A6)              /* 65536 * P189_i_SourceHeight / P191_i_DestinationHeight */
                        lsr.l   #1,D1
                        addi.l  #0x00007FFF,D1
                        movea.l D1,A4
                        swap    D1
                        mulu.w  D1,D0
                        adda.w  D0,A0
                        move.w  D3,-(A7)
                T129_001_Loop:
                        movea.w #0xFFFF,A3
                        move.l  L0227_l_WidthRatio(A6),D4
                        move.l  #0x80008000,D7
                T129_002_Loop:
                        moveq   #0,D2
                        moveq   #0,D3
                T129_003_Loop:
                        swap    D4
                        moveq   #0xF0,D6
                        and.w   D4,D6
                        cmp.w   A3,D6
                        beq.s   T129_004
                        movea.w D6,A3
                        lsr.w   #1,D6
                        movem.l 0x00(A0,D6.w),D0-D1
                T129_004:
                        moveq   #0x0F,D6
                        and.w   D4,D6
                        neg.w   D6
                        addi.w  #0x000F,D6
                        moveq   #0,D5
                        btst    D6,D0
                        beq.s   T129_005
                        moveq   #2,D5
                T129_005:
                        btst    D6,D1
                        beq.s   T129_006
                        addq.w  #8,D5
                T129_006:
                        addi.w  #0x0010,D6
                        btst    D6,D0
                        beq.s   T129_007
                        addq.w  #1,D5
                T129_007:
                        btst    D6,D1
                        beq.s   T129_008
                        addq.w  #4,D5
                T129_008:
                        move.b  0x00(A5,D5.w),D5                        /* Each code section below is 10 bytes large, this is why values in PaletteChanges are (10 * color index) */
                        jmp     2(PC,D5.w)
                T129_009:
                        bra     T129_010                                /* 0 */
                        nop
                        nop
                        nop
                        swap    D2                                      /* 1 */
                        or.w    D7,D2
                        swap    D2
                        bra     T129_010
                        or.w    D7,D2                                   /* 2 */
                        bra     T129_010
                        nop
                        nop
                        or.l    D7,D2                                   /* 3 */
                        bra     T129_010
                        nop
                        nop
                        swap    D3                                      /* 4 */
                        or.w    D7,D3
                        swap    D3
                        bra     T129_010
                        move.w  D7,D6                                   /* 5 */
                        swap    D6
                        or.l    D6,D2
                        or.l    D6,D3
                        bra.s   T129_010
                        or.w    D7,D2                                   /* 6 */
                        swap    D3
                        or.w    D7,D3
                        swap    D3
                        bra.s   T129_010
                        or.l    D7,D2                                   /* 7 */
                        swap    D3
                        or.w    D7,D3
                        swap    D3
                        bra.s   T129_010
                        or.w    D7,D3                                   /* 8 */
                        bra.s   T129_010
                        nop
                        nop
                        nop
                        or.w    D7,D3                                   /* 9 */
                        swap    D2
                        or.w    D7,D2
                        swap    D2
                        bra.s   T129_010
                        or.w    D7,D2                                   /* 10 */
                        or.w    D7,D3
                        bra.s   T129_010
                        nop
                        nop
                        or.l    D7,D2                                   /* 11 */
                        or.w    D7,D3
                        bra.s   T129_010
                        nop
                        nop
                        or.l    D7,D3                                   /* 12 */
                        bra.s   T129_010
                        nop
                        nop
                        nop
                        swap    D2                                      /* 13 */
                        or.w    D7,D2
                        swap    D2
                        or.l    D7,D3
                        bra.s   T129_010
                        or.w    D7,D2                                   /* 14 */
                        or.l    D7,D3
                        bra.s   T129_010
                        nop
                        nop
                        or.l    D7,D2                                   /* 15 */
                        or.l    D7,D3
                T129_010:
                        subq.w  #1,(A7)
                        beq.s   T129_011
                        swap    D4
                        add.l   A2,D4
                        ror.l   #1,D7
                        bcc     T129_003_Loop
                        move.l  D2,(A1)+
                        move.l  D3,(A1)+
                        bra     T129_002_Loop
                T129_011:
                        move.l  D2,(A1)+
                        move.l  D3,(A1)+
                        subq.w  #1,P191_i_DestinationHeight(A6)
                        beq.s   T129_012
                        move.l  A4,D2
                        move.l  D2,D3
                        add.l   L0226_l_HeightRatio(A6),D3
                        movea.l D3,A4
                        swap    D2
                        swap    D3
                        sub.w   D2,D3
                        mulu.w  L0228_i_SourceUnitWidth(A6),D3
                        adda.w  D3,A0
                        move.w  P190_i_DestinationPixelWidth(A6),(A7)
                        bra     T129_001_Loop
                T129_012:
                        addq.w  #2,A7
                        movem.l (A7)+,D4-D7/A2-A5
        }
}

VOID F130_xxxx_VIDEO_FlipHorizontal(P193_puc_Bitmap, P194_i_ByteWidth, P195_i_Height)
unsigned char* P193_puc_Bitmap;
register int P194_i_ByteWidth;
register int P195_i_Height;
{
        asm {
                        movem.l A2-A4,-(A7)
                        movea.l P193_puc_Bitmap(A6),A0
                        lea     V130_1_xxx_FlippedBytesArray(PC),A2
                        moveq   #0,D0
                        moveq   #0,D1
                        move.w  P194_i_ByteWidth,D3
                        lsr.w   #3,P194_i_ByteWidth
                        movea.l A0,A1
                        adda.w  D3,A1
                        subq.l  #6,A1
                        movea.l A0,A3
                        movea.l A1,A4
                T130_001_Loop:
                        move.w  P194_i_ByteWidth,D2
                T130_002:
                        subq.w  #2,D2
                        bmi.s   T130_003
                        move.b  (A0),D0
                        move.b  -(A1),D1
                        move.b  0x00(A2,D0.w),(A1)
                        move.b  0x00(A2,D1.w),(A0)+
                        move.b  (A0),D0
                        move.b  -(A1),D1
                        move.b  0x00(A2,D0.w),(A1)
                        move.b  0x00(A2,D1.w),(A0)+
                        addq.l  #4,A1
                        move.b  (A0),D0
                        move.b  -(A1),D1
                        move.b  0x00(A2,D0.w),(A1)
                        move.b  0x00(A2,D1.w),(A0)+
                        move.b  (A0),D0
                        move.b  -(A1),D1
                        move.b  0x00(A2,D0.w),(A1)
                        move.b  0x00(A2,D1.w),(A0)+
                        addq.l  #4,A1
                        move.b  (A0),D0
                        move.b  -(A1),D1
                        move.b  0x00(A2,D0.w),(A1)
                        move.b  0x00(A2,D1.w),(A0)+
                        move.b  (A0),D0
                        move.b  -(A1),D1
                        move.b  0x00(A2,D0.w),(A1)
                        move.b  0x00(A2,D1.w),(A0)+
                        addq.l  #4,A1
                        move.b  (A0),D0
                        move.b  -(A1),D1
                        move.b  0x00(A2,D0.w),(A1)
                        move.b  0x00(A2,D1.w),(A0)+
                        move.b  (A0),D0
                        move.b  -(A1),D1
                        move.b  0x00(A2,D0.w),(A1)
                        move.b  0x00(A2,D1.w),(A0)+
                        tst.w   D2
                        beq.s   T130_004
                        suba.w  #0x000C,A1
                        bra.s   T130_002
                T130_003:
                        move.b  (A0),D0
                        move.b  -(A1),D1
                        move.b  0x00(A2,D0.w),(A1)
                        move.b  0x00(A2,D1.w),(A0)
                        addq.l  #2,A0
                        addq.l  #2,A1
                        move.b  (A0),D0
                        move.b  (A1),D1
                        move.b  0x00(A2,D0.w),(A1)
                        move.b  0x00(A2,D1.w),(A0)
                        addq.l  #2,A0
                        addq.l  #2,A1
                        move.b  (A0),D0
                        move.b  (A1),D1
                        move.b  0x00(A2,D0.w),(A1)
                        move.b  0x00(A2,D1.w),(A0)
                        addq.l  #2,A0
                        addq.l  #2,A1
                        move.b  (A0),D0
                        move.b  (A1),D1
                        move.b  0x00(A2,D0.w),(A1)
                        move.b  0x00(A2,D1.w),(A0)
                T130_004:
                        subq.w  #1,P195_i_Height
                        beq     T130_006_Return
                        adda.w  D3,A3
                        movea.l A3,A0
                        adda.w  D3,A4
                        movea.l A4,A1
                        bra     T130_001_Loop
                V130_1_xxx_FlippedBytesArray:                           /* Each byte in the table contains the value of its index flipped. Example 00000101 => 10100000. Byte $05 (6th byte) in the table has value $A0 */
                        dc.b    0x00,0x80,0x40,0xC0,0x20,0xA0,0x60,0xE0
                        dc.b    0x10,0x90,0x50,0xD0,0x30,0xB0,0x70,0xF0
                        dc.b    0x08,0x88,0x48,0xC8,0x28,0xA8,0x68,0xE8
                        dc.b    0x18,0x98,0x58,0xD8,0x38,0xB8,0x78,0xF8
                        dc.b    0x04,0x84,0x44,0xC4,0x24,0xA4,0x64,0xE4
                        dc.b    0x14,0x94,0x54,0xD4,0x34,0xB4,0x74,0xF4
                        dc.b    0x0C,0x8C,0x4C,0xCC,0x2C,0xAC,0x6C,0xEC
                        dc.b    0x1C,0x9C,0x5C,0xDC,0x3C,0xBC,0x7C,0xFC
                        dc.b    0x02,0x82,0x42,0xC2,0x22,0xA2,0x62,0xE2
                        dc.b    0x12,0x92,0x52,0xD2,0x32,0xB2,0x72,0xF2
                        dc.b    0x0A,0x8A,0x4A,0xCA,0x2A,0xAA,0x6A,0xEA
                        dc.b    0x1A,0x9A,0x5A,0xDA,0x3A,0xBA,0x7A,0xFA
                        dc.b    0x06,0x86,0x46,0xC6,0x26,0xA6,0x66,0xE6
                        dc.b    0x16,0x96,0x56,0xD6,0x36,0xB6,0x76,0xF6
                        dc.b    0x0E,0x8E,0x4E,0xCE,0x2E,0xAE,0x6E,0xEE
                        dc.b    0x1E,0x9E,0x5E,0xDE,0x3E,0xBE,0x7E,0xFE
                        dc.b    0x01,0x81,0x41,0xC1,0x21,0xA1,0x61,0xE1
                        dc.b    0x11,0x91,0x51,0xD1,0x31,0xB1,0x71,0xF1
                        dc.b    0x09,0x89,0x49,0xC9,0x29,0xA9,0x69,0xE9
                        dc.b    0x19,0x99,0x59,0xD9,0x39,0xB9,0x79,0xF9
                        dc.b    0x05,0x85,0x45,0xC5,0x25,0xA5,0x65,0xE5
                        dc.b    0x15,0x95,0x55,0xD5,0x35,0xB5,0x75,0xF5
                        dc.b    0x0D,0x8D,0x4D,0xCD,0x2D,0xAD,0x6D,0xED
                        dc.b    0x1D,0x9D,0x5D,0xDD,0x3D,0xBD,0x7D,0xFD
                        dc.b    0x03,0x83,0x43,0xC3,0x23,0xA3,0x63,0xE3
                        dc.b    0x13,0x93,0x53,0xD3,0x33,0xB3,0x73,0xF3
                        dc.b    0x0B,0x8B,0x4B,0xCB,0x2B,0xAB,0x6B,0xEB
                        dc.b    0x1B,0x9B,0x5B,0xDB,0x3B,0xBB,0x7B,0xFB
                        dc.b    0x07,0x87,0x47,0xC7,0x27,0xA7,0x67,0xE7
                        dc.b    0x17,0x97,0x57,0xD7,0x37,0xB7,0x77,0xF7
                        dc.b    0x0F,0x8F,0x4F,0xCF,0x2F,0xAF,0x6F,0xEF
                        dc.b    0x1F,0x9F,0x5F,0xDF,0x3F,0xBF,0x7F,0xFF
                T130_006_Return:
                        movem.l (A7)+,A2-A4
        }
}

VOID F131_xxxx_VIDEO_FlipVertical(P196_puc_Bitmap, P197_i_ByteWidth, P198_i_Height)
unsigned char* P196_puc_Bitmap;
int P197_i_ByteWidth;
int P198_i_Height;
{
        asm {
                        movem.l D4-D7/A2,-(A7)
                        move.w  P198_i_Height(A6),D7
                        move.w  P197_i_ByteWidth(A6),D6         /* This value is always a multiple of 8 because the width of images is always a multiple of 16 pixels */
                        movea.l P196_puc_Bitmap(A6),A0          /* A0 will successively point to half of the image lines starting from the first line */
                        movea.l A0,A1
                        move.w  D7,D0
                        subq.w  #1,D0
                        mulu.w  D6,D0
                        adda.w  D0,A1                           /* Address of the last line in the image. A1 will sucessively point to half of the image lines starting from the last line */
                        movea.w D6,A2
                        adda.w  A2,A2                           /* Width in pixels */
                        lsr.w   #3,D6                           /* Number of 8 bytes blocks (16 pixels) in one line */
                T131_001_Loop:
                        subq.w  #2,D7                           /* The number of image lines left to process is decreased */
                        bmi     T131_006_Return                 /* If the number of lines left to process is less than 2 then no more lines can be swapped */
                        swap    D7                              /* The most significant word of D7 now contains the number of image lines left to process */
                        move.w  D6,D7                           /* The least significant word of D7 now contains the number of longs to swap between lines */
                T131_002_Loop:
                        subq.w  #3,D7
                        bmi.s   T131_003                        /* If there are less than 3 blocks of 8 bytes left to swap between lines */
                        movem.l (A0),D0-D5                      /* Save 6x4 = 24 bytes from address A0 to registers */
                        move.l  (A1)+,(A0)+                     /* Copy 4 bytes from address A1 to address A0 */
                        move.l  (A1)+,(A0)+                     /* Copy 4 bytes from address A1 to address A0 */
                        move.l  (A1)+,(A0)+                     /* Copy 4 bytes from address A1 to address A0 */
                        move.l  (A1)+,(A0)+                     /* Copy 4 bytes from address A1 to address A0 */
                        move.l  (A1)+,(A0)+                     /* Copy 4 bytes from address A1 to address A0 */
                        move.l  (A1)+,(A0)+                     /* Copy 4 bytes from address A1 to address A0 */
                        movem.l D0-D5,-0x0018(A1)               /* Restore 24 bytes from registers to address A1 - 24. This effectively swaps 24 bytes from the first line of image and last line of image */
                        tst.w   D7
                        bne.s   T131_002_Loop
                        bra.s   T131_005
                T131_003:
                        addq.w  #2,D7
                T131_004:
                        move.l  (A0),D0                         /* Save 4 bytes from address A0 to D0 */
                        move.l  (A1),(A0)+                      /* Copy 4 bytes from address A1 to address A0 */
                        move.l  D0,(A1)+                        /* Restore 4 bytes from D0 to address A1. This effectively swaps 4 bytes */
                        move.l  (A0),D0                         /* Save 4 bytes from address A0 to D0 */
                        move.l  (A1),(A0)+                      /* Copy 4 bytes from address A1 to address A0 */
                        move.l  D0,(A1)+                        /* Restore 4 bytes from D0 to address A1. This effectively swaps 4 bytes */ 
                        dbf     D7,T131_004
                T131_005:
                        suba.w  A2,A1                           /* Move A1 to point to the previous line */
                        swap    D7                              /* The least significant word of D7 now contains the number of image lines left to process. The most significant word of D7 now contains the number of longs to swap between lines */
                        tst.w   D7
                        bne     T131_001_Loop                   /* If there are lines left to swap */
                T131_006_Return:
                        movem.l (A7)+,D4-D7/A2
        }
}

/* Blit part of P199_puc_Bitmap_Source at coordinates P202_i_X, P203_i_Y to P200_puc_Bitmap_Destination at coordinates specified in P201_pc_Box and with transparent color P206_i_TransparentColor */
VOID F132_xzzz_VIDEO_Blit(P199_puc_Bitmap_Source, P200_puc_Bitmap_Destination, P201_pc_Box, P202_i_X, P203_i_Y, P204_i_SourceByteWidth, P205_i_DestinationByteWidth, P206_i_TransparentColor)
unsigned char* P199_puc_Bitmap_Source;
unsigned char* P200_puc_Bitmap_Destination;
char* P201_pc_Box;
int P202_i_X;
int P203_i_Y;
int P204_i_SourceByteWidth;
int P205_i_DestinationByteWidth;
int P206_i_TransparentColor;
{
        int L0229_i_LinePixelCount;
        int L0230_i_FirstUnitMask;
        int L0231_i_LastUnitMask;


        asm {
                        movem.l D4-D7/A2-A5,-(A7)
                        movea.l P199_puc_Bitmap_Source(A6),A0
                        movea.l P200_puc_Bitmap_Destination(A6),A1
                        move.w  P206_i_TransparentColor(A6),D0
                        move.w  P205_i_DestinationByteWidth(A6),D1
                        move.w  P204_i_SourceByteWidth(A6),D2
                        move.w  P203_i_Y(A6),D3
                        move.w  P202_i_X(A6),D4
                        cmpa.l  #0x00000000,A1
                        bne.s   T132_001                                /* If P200_puc_Bitmap_Destination = NULL then blit directly to the physical screen */
                        movem.l D0-D4/A0,-(A7)
                        move.w  #2,-(A7)                                /* XBIOS function $02: void *Physbase(void); Returns the physical start address of the video memory */
                        trap    #14
                        addq.l  #2,A7
                        movea.l D0,A1
                        movem.l (A7)+,D0-D4/A0
                T132_001:
                        movea.l P201_pc_Box(A6),A2
                        lea     V132_1_xxx_Masks(PC),A5
                        moveq   #0x0F,D5
                        and.w   D4,D5                                   /* D5 = index of first pixel to blit from first unit of source bitmap */
                        mulu.w  D2,D3                                   /* P203_i_Y * P204_i_SourceByteWidth */
                        adda.l  D3,A0
                        sub.w   D5,D4
                        lsr.w   #1,D4                                   /* Convert pixel count to byte count */
                        adda.w  D4,A0                                   /* Address in source bitmap of first unit to read from */
                        moveq   #0,D7
                        moveq   #0,D4
                        tst.w   G578_B_UseByteBoxCoordinates(A4)
                        beq.s   T132_002                                /* Branch if G578_B_UseByteBoxCoordinates = FALSE */
                        move.b  (A2)+,D4                                /* X1 */
                        move.b  (A2)+,D7                                /* X2 */
                        bra.s   T132_003
                T132_002:
                        move.w  (A2)+,D4                                /* X1 */
                        move.w  (A2)+,D7                                /* X2 */
                T132_003:
                        sub.w   D4,D7                                   /* X2 - X1 */
                        addq.w  #1,D7                                   /* X2 - X1 + 1 */
                        swap    D7                                      /* Most significant word of D7 contains X2 - X1 + 1 */
                        moveq   #0,D3
                        tst.w   G578_B_UseByteBoxCoordinates(A4)
                        beq.s   T132_004                                /* Branch if G578_B_UseByteBoxCoordinates = FALSE */
                        move.b  (A2)+,D3                                /* Y1 */
                        move.b  (A2),D7                                 /* Y2 */
                        bra.s   T132_005
                T132_004:
                        move.w  (A2)+,D3                                /* Y1 */
                        move.w  (A2),D7                                 /* Y2 */
                T132_005:
                        sub.w   D3,D7                                   /* Least significant word of D7 contains Y2 - Y1: number of lines of bitmap to blit (iteration count) */
                        swap    D7                                      /* Least significant word of D7 contains X2 - X1 + 1 */
                        moveq   #0x0F,D6
                        and.w   D4,D6                                   /* D6 = index of first pixel to blit to first unit of destination bitmap */
                        mulu.w  D1,D3                                   /* Y1 * P205_i_DestinationByteWidth */
                        adda.l  D3,A1                                   /* Address of line in destination bitmap where blit will start */
                        sub.w   D6,D4
                        lsr.w   #1,D4                                   /* Convert pixel count to byte count */
                        adda.w  D4,A1                                   /* Address in destination bitmap of first unit to write to */
                        moveq   #15,D3
                        add.w   D7,D3                                   /* D3 = (X2 - X1 + 1) + 15 */
                        add.w   D5,D3                                   /* D3 = (X2 - X1 + 1) + 15 + index of first pixel to blit from first unit of source bitmap */
                        andi.w  #0xFFF0,D3                              /* Multiple of 16 pixels */
                        lsr.w   #1,D3                                   /* D3 = byte count for a line */
                        move.w  D2,D4                                   /* P204_i_SourceByteWidth */
                        sub.w   D3,D4                                   /* P204_i_SourceByteWidth - byte count for a line */
                        movea.w D4,A3                                   /* Byte offset in source bitmap between 2 lines */
                        add.w   D6,D7                                   /* Index of first pixel to blit to first unit of destination bitmap + (X2 - X1 + 1)   Number of pixels to blit on a line including left padding */
                        move.w  D7,L0229_i_LinePixelCount(A6)
                        moveq   #15,D3
                        add.w   D7,D3                                   /* D3 = (X2 - X1 + 1) + 15 */
                        andi.w  #0xFFF0,D3                              /* Multiple of 16 pixels */
                        lsr.w   #1,D3                                   /* D3 = byte count */
                        sub.w   D3,D1                                   /* P205_i_DestinationByteWidth - D3 */
                        movea.w D1,A4                                   /* Byte offset in destination bitmap between 2 lines */
                        move.w  D5,D1                                   /* Index of first pixel to blit from first unit of source bitmap */
                        neg.w   D5
                        add.w   D6,D5
                        bpl.s   T132_006
                        addi.w  #16,D5                                  /* Required pixel shift inside units between source and destination */
                T132_006:
                        move.w  D6,D3
                        add.w   D3,D3
                        move.w  0(A5,D3.w),L0230_i_FirstUnitMask(A6)
                        move.w  D7,D3
                        add.w   D7,D3
                        cmpi.w  #32,D3
                        bpl.s   T132_007
                        move.w  0(A5,D3.w),D3
                        not.w   D3
                        or.w    D3,L0230_i_FirstUnitMask(A6)
                        cmp.w   D5,D6
                        bpl.s   T132_008
                        add.w   D7,D1
                        sub.w   D6,D1
                        cmpi.w  #17,D1
                        bpl.s   T132_008
                        subq.w  #8,A3
                        bra.s   T132_008
                T132_007:
                        andi.w  #0x001F,D3
                        move.w  0(A5,D3.w),D3
                        not.w   D3
                        move.w  D3,L0231_i_LastUnitMask(A6)
                T132_008:
                        move.w  D5,D3
                        add.w   D3,D3
                        movea.w 0(A5,D3.w),A5
                        swap    D5
                        tst.w   D0
                        bpl.s   T132_009                                /* If P206_i_TransparentColor >= 0 */
                        lea     T132_035_NoTransparency(PC),A2
                        bra.s   T132_011_BlitLine
                T132_009:
                        add.w   D0,D0
                        move.w  D0,D3
                        add.w   D0,D0
                        add.w   D3,D0                                   /* D0 = 6 * P206_i_TransparentColor */
                        jmp     2(PC,D0.w)                              /* Each entry in the jumptable below is 6 bytes large */
                T132_010:
                        lea     T132_019_TransparentColor00(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_020_TransparentColor01(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_021_TransparentColor02(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_022_TransparentColor03(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_023_TransparentColor04(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_024_TransparentColor05(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_025_TransparentColor06(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_026_TransparentColor07(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_027_TransparentColor08(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_028_TransparentColor09(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_029_TransparentColor10(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_030_TransparentColor11(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_031_TransparentColor12(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_032_TransparentColor13(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_033_TransparentColor14(PC),A2
                        bra.s   T132_011_BlitLine
                        lea     T132_034_TransparentColor15(PC),A2
                T132_011_BlitLine:
                        move.w  L0230_i_FirstUnitMask(A6),D5
                        swap    D5
                        tst.w   D5
                        beq.s   T132_013
                        move.w  A5,D4
                        cmp.w   D5,D6
                        bpl.s   T132_012
                        move.w  (A0)+,D1
                        ror.w   D5,D1
                        and.w   D4,D1
                        swap    D1
                        move.w  (A0)+,D0
                        ror.w   D5,D0
                        and.w   D4,D0
                        swap    D0
                        move.w  (A0)+,D3
                        ror.w   D5,D3
                        and.w   D4,D3
                        swap    D3
                        move.w  (A0)+,D2
                        ror.w   D5,D2
                        and.w   D4,D2
                        swap    D2
                T132_012:
                        swap    D6
                        move.w  (A0)+,D0
                        ror.w   D5,D0
                        move.w  D0,D6
                        swap    D1
                        and.w   D4,D1
                        not.w   D4
                        and.w   D4,D0
                        or.w    D1,D0
                        move.w  D6,D1
                        swap    D1
                        move.w  (A0)+,D1
                        ror.w   D5,D1
                        move.w  D1,D6
                        swap    D0
                        and.w   D4,D1
                        not.w   D4
                        and.w   D4,D0
                        or.w    D0,D1
                        move.w  D6,D0
                        swap    D0
                        move.w  (A0)+,D2
                        ror.w   D5,D2
                        move.w  D2,D6
                        swap    D3
                        and.w   D4,D3
                        not.w   D4
                        and.w   D4,D2
                        or.w    D3,D2
                        move.w  D6,D3
                        swap    D3
                        move.w  (A0)+,D3
                        ror.w   D5,D3
                        move.w  D3,D6
                        swap    D2
                        and.w   D4,D3
                        not.w   D4
                        and.w   D4,D2
                        or.w    D2,D3
                        move.w  D6,D2
                        swap    D2
                        swap    D6
                        swap    D5
                        jmp     (A2)
                T132_013:
                        movem.w (A0)+,D0-D3
                        swap    D5
                        jmp     (A2)
                T132_014:
                        not.w   D4
                        and.w   D4,D0
                        and.w   D4,D1
                        and.w   D4,D2
                        and.w   D4,D3
                        not.w   D4
                        and.w   D4,(A1)
                        or.w    D0,(A1)+
                        and.w   D4,(A1)
                        or.w    D1,(A1)+
                        and.w   D4,(A1)
                        or.w    D2,(A1)+
                        and.w   D4,(A1)
                        or.w    D3,(A1)+
                T132_015:
                        subi.w  #16,D7                                  /* 16 pixels less to blit on the line (D7 includes left padding pixels) */
                        ble.s   T132_018_ProceedToNextLine              /* Branch if D7 <= 0. If the line was fully blitted */
                        cmpi.w  #16,D7
                        bmi.s   T132_017                                /* Branch if D7 < 16. If there is less than a unit of 16 pixels left to blit */
                        clr.w   D5                                      /* Use a 0x0000 mask */
                        swap    D5
                T132_016:
                        tst.w   D5
                        beq.s   T132_013
                        move.w  A5,D4
                        bra     T132_012
                T132_017:
                        move.w  L0231_i_LastUnitMask(A6),D5
                        swap    D5
                        cmp.w   D7,D5
                        bmi.s   T132_016
                        swap    D0                                      /* Horizontal flip of bits in D0, D1, D2, D3 */
                        swap    D1
                        swap    D2
                        swap    D3
                        move.w  D0,D4
                        move.w  D1,D0
                        move.w  D4,D1
                        move.w  D2,D4
                        move.w  D3,D2
                        move.w  D4,D3                                   /* Horizontal flip of bits in D0, D1, D2, D3 */
                        swap    D5
                        jmp     (A2)
                T132_018_ProceedToNextLine:
                        swap    D7                                      /* Line count */
                        subq.w  #1,D7                                   /* One less line to copy */
                        bmi     T132_038_Return                         /* Branch if < 0, if there are no more lines of bitmap to blit */
                        swap    D7
                        move.w  L0229_i_LinePixelCount(A6),D7
                        adda.w  A3,A0                                   /* Proceed to next line of source bitmap */
                        adda.w  A4,A1                                   /* Proceed to next line of destination bitmap */
                        bra     T132_011_BlitLine
                T132_019_TransparentColor00:
                        move.w  D0,D4
                        or.w    D1,D4
                        or.w    D2,D4
                        or.w    D3,D4
                        not.w   D4
                        or.w    D5,D4
                        bne.s   T132_014
                        bra     T132_036
                T132_020_TransparentColor01:
                        move.w  D1,D4
                        or.w    D2,D4
                        or.w    D3,D4
                        not.w   D4
                        and.w   D0,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra     T132_036
                T132_021_TransparentColor02:
                        move.w  D0,D4
                        or.w    D2,D4
                        or.w    D3,D4
                        not.w   D4
                        and.w   D1,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra     T132_036
                T132_022_TransparentColor03:
                        move.w  D2,D4
                        or.w    D3,D4
                        not.w   D4
                        and.w   D0,D4
                        and.w   D1,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra     T132_036
                T132_023_TransparentColor04:
                        move.w  D0,D4
                        or.w    D1,D4
                        or.w    D3,D4
                        not.w   D4
                        and.w   D2,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra     T132_036
                T132_024_TransparentColor05:
                        move.w  D1,D4
                        or.w    D3,D4
                        not.w   D4
                        and.w   D0,D4
                        and.w   D2,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra     T132_036
                T132_025_TransparentColor06:
                        move.w  D0,D4
                        or.w    D3,D4
                        not.w   D4
                        and.w   D1,D4
                        and.w   D2,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra     T132_036
                T132_026_TransparentColor07:
                        move.w  D3,D4
                        not.w   D4
                        and.w   D0,D4
                        and.w   D1,D4
                        and.w   D2,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra     T132_036
                T132_027_TransparentColor08:
                        move.w  D0,D4
                        or.w    D1,D4
                        or.w    D2,D4
                        not.w   D4
                        and.w   D3,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra     T132_036
                T132_028_TransparentColor09:
                        move.w  D1,D4
                        or.w    D2,D4
                        not.w   D4
                        and.w   D0,D4
                        and.w   D3,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra.s   T132_036
                T132_029_TransparentColor10:
                        move.w  D0,D4
                        or.w    D2,D4
                        not.w   D4
                        and.w   D1,D4
                        and.w   D3,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra.s   T132_036
                T132_030_TransparentColor11:
                        move.w  D2,D4
                        not.w   D4
                        and.w   D0,D4
                        and.w   D1,D4
                        and.w   D3,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra.s   T132_036
                T132_031_TransparentColor12:
                        move.w  D0,D4
                        or.w    D1,D4
                        not.w   D4
                        and.w   D2,D4
                        and.w   D3,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra.s   T132_036
                T132_032_TransparentColor13:
                        move.w  D1,D4
                        not.w   D4
                        and.w   D0,D4
                        and.w   D2,D4
                        and.w   D3,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra.s   T132_036
                T132_033_TransparentColor14:
                        move.w  D0,D4
                        not.w   D4
                        and.w   D1,D4
                        and.w   D2,D4
                        and.w   D3,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra.s   T132_036
                T132_034_TransparentColor15:
                        move.w  D0,D4
                        and.w   D1,D4
                        and.w   D2,D4
                        and.w   D3,D4
                        or.w    D5,D4
                        bne     T132_014
                        bra.s   T132_036
                T132_035_NoTransparency:
                        move.w  D5,D4
                        bne     T132_014
                T132_036:
                        move.w  D0,(A1)+
                        move.w  D1,(A1)+
                        move.w  D2,(A1)+
                        move.w  D3,(A1)+
                        bra     T132_015
                V132_1_xxx_Masks:
                        dc.w    0x0000,0x8000,0xC000,0xE000
                        dc.w    0xF000,0xF800,0xFC00,0xFE00
                        dc.w    0xFF00,0xFF80,0xFFC0,0xFFE0
                        dc.w    0xFFF0,0xFFF8,0xFFFC,0xFFFE
                T132_038_Return:
                        movem.l (A7)+,D4-D7/A2-A5
        }
}

/* This function creates a bitmap in P210_puc_Bitmap_Temporary with the dimensions of P211_pc_Box and filled with units from P207_puc_Bitmap_Source starting from P213_i_FirstUnitIndex to P212_i_LastUnitIndex
The written units are masked with P209_puc_Bitmap_Mask and the pixels removed by the mask are replaced by the color P215_i_TransparentColor. The bitmap at coordinates P216_i_X and P217_i_Y in the resulting P210_puc_Bitmap_Temporary is blitted to P208_puc_Bitmap_Destination with transparent color P215_i_TransparentColor
The dimensions of P207_puc_Bitmap_Source are ignored as it is only used as a source for units. Consequently the source bitmap is never drawn as is and is always distorted */
VOID F133_xxxx_VIDEO_BlitBoxFilledWithMaskedBitmap(P207_puc_Bitmap_Source, P208_puc_Bitmap_Destination, P209_puc_Bitmap_Mask, P210_puc_Bitmap_Temporary, P211_pc_Box, P212_i_LastUnitIndex, P213_i_FirstUnitIndex, P214_i_DestinationByteWidth, P215_i_TransparentColor, P216_i_X, P217_i_Y)
unsigned char* P207_puc_Bitmap_Source;
unsigned char* P208_puc_Bitmap_Destination;
unsigned char* P209_puc_Bitmap_Mask;
unsigned char* P210_puc_Bitmap_Temporary;
char* P211_pc_Box;
int P212_i_LastUnitIndex; /* Index of the last source bitmap unit to write to the destination box. Must be greater than P213_i_FirstUnitIndex. After this unit is written to the destination box, the next unit to write will be set to the first unit in the source bitmap, and not reset to P213_i_FirstUnitIndex */
int P213_i_FirstUnitIndex; /* Index of the first source bitmap unit to write to the destination box. Must be lower than P212_i_LastUnitIndex */
int P214_i_DestinationByteWidth;
int P215_i_TransparentColor;
int P216_i_X;
int P217_i_Y;
{
        int L0232_i_BoxUnitWidth;


        asm {
                        movem.l D5-D7/A2-A4,-(A7)
                        move.w  P215_i_TransparentColor(A6),D0
                        cmp.b   #255,D0
                        beq.s   T133_001                                /* If mask should not be used */
                        tst.b   D0
                        bpl.s   T133_002                                /* If P215_i_TransparentColor >= 0. If mask should be used */
                        andi.w  #0x007F,P215_i_TransparentColor(A6)     /* Clear bit 7 for later call to F132_xzzz_VIDEO_Blit */
                T133_001:
                        lea     T133_026_TransparentColor00_NoMask(PC),A3
                        bra.s   T133_004
                T133_002:
                        lea     T133_010_UseMask(PC),A3
                        move.w  D0,D1
                        add.w   D0,D0
                        add.w   D1,D0
                        add.w   D0,D0                                   /* D0 = 6 * P215_i_TransparentColor (each entry in the jump table below is 6 bytes large) */
                        jmp     2(PC,D0.w)                              /* This jumptable is used to set in A1 the address of the routine to set the color of pixels excluded by the mask to the specified transparent color */
                T133_003:
                        lea     T133_026_TransparentColor00_NoMask(PC),A1
                        bra.s   T133_004
                        lea     T133_025_TransparentColor01(PC),A1
                        bra.s   T133_004
                        lea     T133_015_TransparentColor02(PC),A1
                        bra.s   T133_004
                        lea     T133_024_TransparentColor03(PC),A1
                        bra.s   T133_004
                        lea     T133_017_TransparentColor04(PC),A1
                        bra.s   T133_004
                        lea     T133_019_TransparentColor05(PC),A1
                        bra.s   T133_004
                        lea     T133_016_TransparentColor06(PC),A1
                        bra.s   T133_004
                        lea     T133_023_TransparentColor07(PC),A1
                        bra.s   T133_004
                        lea     T133_013_TransparentColor08(PC),A1
                        bra.s   T133_004
                        lea     T133_021_TransparentColor09(PC),A1
                        bra.s   T133_004
                        lea     T133_014_TransparentColor10(PC),A1
                        bra.s   T133_004
                        lea     T133_020_TransparentColor11(PC),A1
                        bra.s   T133_004
                        lea     T133_012_TransparentColor12(PC),A1
                        bra.s   T133_004
                        lea     T133_018_TransparentColor13(PC),A1
                        bra.s   T133_004
                        lea     T133_011_TransparentColor14(PC),A1
                        bra.s   T133_004
                        lea     T133_022_TransparentColor15(PC),A1
                T133_004:
                        movea.l P207_puc_Bitmap_Source(A6),A0
                        move.w  P212_i_LastUnitIndex(A6),D6
                        move.w  P213_i_FirstUnitIndex(A6),D7
                        move.w  D7,D0
                        lsl.w   #3,D0                                   /* P213_i_FirstUnitIndex * 8 = offset in bytes in P207_puc_Bitmap_Source */
                        adda.w  D0,A0
                        swap    D7                                      /* Most significant word of D7 contains P213_i_FirstUnitIndex */
                        movea.l P211_pc_Box(A6),A2
                        moveq   #0,D3                                   /* Prepare D3 for X1 */
                        moveq   #0,D0                                   /* Prepare D0 for X2 */
                        tst.w   G578_B_UseByteBoxCoordinates(A4)
                        beq.s   T133_005                                /* Branch if G578_B_UseByteBoxCoordinates = FALSE */
                        move.b  (A2)+,D3                                /* X1 */
                        move.b  (A2)+,D0                                /* X2 */
                        bra.s   T133_006
                T133_005:
                        move.w  (A2)+,D3                                /* X1 */
                        move.w  (A2)+,D0                                /* X2 */
                T133_006:
                        sub.w   D3,D0                                   /* X2 - X1 */
                        lsr.w   #4,D0                                   /* (X2 - X1) / 16 */
                        addq.w  #1,D0                                   /* ((X2 - X1) / 16) + 1 */
                        move.w  D0,L0232_i_BoxUnitWidth(A6)
                        moveq   #0,D3                                   /* Prepare D3 for Y1 */
                        moveq   #0,D5                                   /* Prepare D5 for Y2 */
                        tst.w   G578_B_UseByteBoxCoordinates(A4)
                        beq.s   T133_007                                /* Branch if G578_B_UseByteBoxCoordinates = FALSE */
                        move.b  (A2)+,D3                                /* Y1 */
                        move.b  (A2),D5                                 /* Y2 */
                        bra.s   T133_008
                T133_007:
                        move.w  (A2)+,D3                                /* Y1 */
                        move.w  (A2),D5                                 /* Y2 */
                T133_008:
                        sub.w   D3,D5                                   /* Y2 - Y1 */
                        addq.w  #1,D5                                   /* (Y2 - Y1) + 1 */
                        mulu.w  D0,D5                                   /* ((Y2 - Y1) + 1) * (((X2 - X1) / 16) + 1) */
                        subq.w  #1,D5                                   /* (((Y2 - Y1) + 1) * (((X2 - X1) / 16) + 1)) - 1 */
                        move.w  D5,D7                                   /* Least significant word of D7 contains box unit count: the number of bitmap units that must be written to the box from the source bitmap */
                        movea.l A1,A4
                        movea.l P209_puc_Bitmap_Mask(A6),A1
                        movea.l P210_puc_Bitmap_Temporary(A6),A2
                T133_009_Loop:
                        movem.w (A0)+,D0-D3                             /* Load unit (4 words) of bitmap data */
                        jmp     (A3)                                    /* A3 = T133_010_UseMask or T133_026_TransparentColor00_NoMask */
                T133_010_UseMask:
                        move.w  (A1),D5                                 /* Get one word from the mask */
                        addq.l  #8,A1                                   /* Proceed to next unit */
                        and.w   D5,D0                                   /* Clear bits in fourth word bitmap according to mask */
                        and.w   D5,D1                                   /* Clear bits in third word of bitmap according to mask */
                        and.w   D5,D2                                   /* Clear bits in second word of bitmap according to mask */
                        and.w   D5,D3                                   /* Clear bits in first word of bitmap according to mask */
                        not.w   D5
                        jmp     (A4)                                    /* A4 = One of T133_011_TransparentColor14 to T133_026_TransparentColor00_NoMask */
                T133_011_TransparentColor14:
                        or.w    D5,D1                                   /* Set bits 1 (2) in third word of bitmap according to mask */
                T133_012_TransparentColor12:
                        or.w    D5,D2                                   /* Set bits 2 (4) in second word of bitmap according to mask */
                T133_013_TransparentColor08:
                        or.w    D5,D3                                   /* Set bits 3 (8) in first word of bitmap according to mask */
                        bra.s   T133_026_TransparentColor00_NoMask
                T133_014_TransparentColor10:
                        or.w    D5,D3                                   /* Set bits 3 (8) in first word of bitmap according to mask */
                T133_015_TransparentColor02:
                        or.w    D5,D1                                   /* Set bits 1 (2) in third word of bitmap according to mask */
                        bra.s   T133_026_TransparentColor00_NoMask
                T133_016_TransparentColor06:
                        or.w    D5,D1                                   /* Set bits 1 (2) in third word of bitmap according to mask */
                T133_017_TransparentColor04:
                        or.w    D5,D2                                   /* Set bits 2 (4) in second word of bitmap according to mask */
                        bra.s   T133_026_TransparentColor00_NoMask
                T133_018_TransparentColor13:
                        or.w    D5,D3                                   /* Set bits 3 (8) in first word of bitmap according to mask */
                T133_019_TransparentColor05:
                        or.w    D5,D2                                   /* Set bits 2 (4) in second word of bitmap according to mask */
                        or.w    D5,D0                                   /* Set bits 0 (1) in fourth word of bitmap according to mask */
                        bra.s   T133_026_TransparentColor00_NoMask
                T133_020_TransparentColor11:
                        or.w    D5,D1                                   /* Set bits 1 (2) in third word of bitmap according to mask */
                T133_021_TransparentColor09:
                        or.w    D5,D3                                   /* Set bits 3 (8) in first word of bitmap according to mask */
                        or.w    D5,D0                                   /* Set bits 0 (1) in fourth word of bitmap according to mask */
                        bra.s   T133_026_TransparentColor00_NoMask
                T133_022_TransparentColor15:
                        or.w    D5,D3                                   /* Set bits 3 (8) in first word of bitmap according to mask */
                T133_023_TransparentColor07:
                        or.w    D5,D2                                   /* Set bits 2 (4) in second word of bitmap according to mask */
                T133_024_TransparentColor03:
                        or.w    D5,D1                                   /* Set bits 1 (2) in third word of bitmap according to mask */
                T133_025_TransparentColor01:
                        or.w    D5,D0                                   /* Set bits 0 (1) in fourth word of bitmap according to mask */
                T133_026_TransparentColor00_NoMask:
                        movem.w D0-D3,(A2)                              /* Write a unit (4 words) of bitmap to P210_puc_Bitmap_Temporary */
                        addq.l  #8,A2                                   /* Proceed to the next unit (4 words = 8 bytes) in P210_puc_Bitmap_Temporary */
                        swap    D7                                      /* Least significant word is P213_i_FirstUnitIndex, most significant word is count of units left to write */
                        addq.w  #1,D7                                   /* Increment P213_i_FirstUnitIndex */
                        cmp.w   D6,D7
                        beq.s   T133_028                                /* Branch if P213_i_FirstUnitIndex = P212_i_LastUnitIndex */
                T133_027:
                        swap    D7                                      /* Least significant word is Unit count */
                        dbf     D7,T133_009_Loop                        /* Decrement D7 (count of units left to write) and branch if D7 >= 0 */
                        bra.s   T133_029
                T133_028:
                        move.w  #0,D7                                   /* P213_i_FirstUnitIndex = 0 */
                        movea.l P207_puc_Bitmap_Source(A6),A0
                        bra.s   T133_027
                T133_029:
                        movem.l (A7)+,D5-D7/A2-A4
        }
        F132_xzzz_VIDEO_Blit(P210_puc_Bitmap_Temporary, P208_puc_Bitmap_Destination, P211_pc_Box, P216_i_X, P217_i_Y, L0232_i_BoxUnitWidth << 3, P214_i_DestinationByteWidth, P215_i_TransparentColor);
}

VOID F134_zzzz_VIDEO_FillBitmap(P218_puc_Bitmap, P219_i_Color, P220_i_UnitCount)
register unsigned char* P218_puc_Bitmap;
register int P219_i_Color;
register int P220_i_UnitCount; /* Number of units = 8 bytes = 16 pixels */
{
        asm {
                        moveq   #0,D0
                        moveq   #0,D1
                        lsr.w   #1,P219_i_Color                 /* Move Bit 0 to processor carry flag */
                        bcc.s   T134_001                        /* If Bit 0 of P219_i_Color is 0 */
                        not.w   D0                              /* Sets all bits in least significant word of D0 to 1 to match Bit 0 from P219_i_Color */
                        swap    D0
                T134_001:
                        lsr.w   #1,P219_i_Color                 /* Move Bit 1 to processor carry flag */
                        bcc.s   T134_002                        /* If Bit 1 of P219_i_Color is 0 */
                        not.w   D0                              /* Sets all bits in least significant word of D0 to 1 to match Bit 1 from P219_i_Color */
                T134_002:
                        lsr.w   #1,P219_i_Color                 /* Move Bit 2 to processor carry flag */
                        bcc.s   T134_003                        /* If Bit 2 of P219_i_Color is 0 */
                        not.w   D1                              /* Sets all bits in least significant word of D0 to 1 to match Bit 2 from P219_i_Color */
                        swap    D1
                T134_003:
                        lsr.w   #1,P219_i_Color                 /* Move Bit 3 to processor carry flag */
                        bcc.s   T134_004_Loop                   /* If Bit 3 of P219_i_Color is 0 */
                        not.w   D1                              /* Sets all bits in least significant word of D0 to 1 to match Bit 3 from P219_i_Color */
                T134_004_Loop:
                        move.l  D0,(P218_puc_Bitmap)+           /* Write 4 bytes and move to the next location */
                        move.l  D1,(P218_puc_Bitmap)+           /* Write 4 bytes and move to the next location */
                        subq.w  #1,P220_i_UnitCount
                        bne.s   T134_004_Loop
        }
}

VOID F135_xzzz_VIDEO_FillBox(P221_puc_Bitmap, P222_pc_Box, P223_i_Color, P224_i_ByteWidth)
unsigned char* P221_puc_Bitmap;
char* P222_pc_Box;
int P223_i_Color; /* If bit 15 is set then only every other pixel is overwritten */
int P224_i_ByteWidth;
{
        asm {
                        movem.l D4-D7,-(A7)
                        movea.l P222_pc_Box(A6),A0
                        tst.w   G578_B_UseByteBoxCoordinates(A4)
                        beq.s   T135_001                                /* If using words in box coordinates */
                        moveq   #0,D0
                        moveq   #0,D1
                        moveq   #0,D2
                        moveq   #0,D3
                        move.b  (A0)+,D0                                /* First byte of P222_pc_Box */
                        move.b  (A0)+,D1                                /* Second byte of P222_pc_Box */
                        move.b  (A0)+,D2                                /* Third byte of P222_pc_Box */
                        move.b  (A0),D3                                 /* Fourth byte of P222_pc_Box */
                        bra.s   T135_002
                T135_001:
                        move.w  (A0)+,D0                                /* First word of P222_pc_Box */
                        move.w  (A0)+,D1                                /* Second word of P222_pc_Box */
                        move.w  (A0)+,D2                                /* Third word of P222_pc_Box */
                        move.w  (A0),D3                                 /* Fourth word of P222_pc_Box */
                T135_002:
                        swap    D0
                        move.w  D2,D0
                        swap    D0
                        movea.l P221_puc_Bitmap(A6),A1
                        sub.w   D2,D3
                        swap    D3
                        mulu.w  P224_i_ByteWidth(A6),D2
                        adda.w  D2,A1
                        lea     V135_1_xxx(PC),A0
                        moveq   #15,D6
                        and.w   D0,D6
                        add.w   D6,D6
                        move.w  0(A0,D6.w),D6
                        lsr.w   #4,D0
                        moveq   #15,D4
                        and.w   D1,D4
                        addq.w  #1,D4
                        add.w   D4,D4
                        move.w  0(A0,D4.w),D4
                        not.w   D4
                        lsr.w   #4,D1
                        move.w  D0,D2
                        lsl.w   #3,D2
                        adda.w  D2,A1
                        sub.w   D0,D1
                        move.w  D1,D3
                        bne.s   T135_003
                        or.w    D4,D6
                T135_003:
                        subq.w  #1,D3
                        swap    D3
                        addq.w  #1,D1
                        lsl.w   #3,D1
                        move.w  P224_i_ByteWidth(A6),D7
                        sub.w   D1,D7
                        move.w  D4,D5
                        not.w   D5
                        move.w  D6,D1
                        not.w   D1
                        swap    D7
                        clr.w   D7
                        btst    #15,P223_i_Color(A6)
                        beq.s   T135_004                                /* Branch if Bit 15 of P223_i_Color = 0 */
                        swap    D0
                        move.w  #0x5555,D7
                        btst    #0,D0
                        bne.s   T135_004
                        add.w   D7,D7
                T135_004:
                        moveq   #0x0F,D0
                        and.w   P223_i_Color(A6),D0                     /* Color index extracted from P223_i_Color by removing bit 15 */
                        add.w   D0,D0
                        move.w  D0,D2
                        add.w   D0,D0
                        add.w   D2,D0
                        jmp     2(PC,D0.w)
                T135_005:
                        lea     T135_016(PC),A0
                        bra.s   T135_006
                        lea     T135_015(PC),A0
                        bra.s   T135_006
                        lea     T135_019(PC),A0
                        bra.s   T135_006
                        lea     T135_014(PC),A0
                        bra.s   T135_006
                        lea     T135_024(PC),A0
                        bra.s   T135_006
                        lea     T135_027(PC),A0
                        bra.s   T135_006
                        lea     T135_018(PC),A0
                        bra.s   T135_006
                        lea     T135_013(PC),A0
                        bra.s   T135_006
                        lea     T135_022(PC),A0
                        bra.s   T135_006
                        lea     T135_021(PC),A0
                        bra.s   T135_006
                        lea     T135_026(PC),A0
                        bra.s   T135_006
                        lea     T135_025(PC),A0
                        bra.s   T135_006
                        lea     T135_023(PC),A0
                        bra.s   T135_006
                        lea     T135_020(PC),A0
                        bra.s   T135_006
                        lea     T135_017(PC),A0
                        bra.s   T135_006
                        lea     T135_012(PC),A0
                T135_006:
                        swap    D3
                        move.w  D3,D2
                        swap    D3
                        move.w  D6,D0
                        or.w    D7,D0
                        and.w   D0,(A1)
                        and.w   D0,2(A1)
                        and.w   D0,4(A1)
                        and.w   D0,6(A1)
                        not.w   D7
                        move.w  D1,D0
                        and.w   D7,D0
                        not.w   D7
                        jsr     (A0)
                        addq.l  #8,A1
                        tst.w   D2
                        bmi.s   T135_010
                        dbf     D2,T135_007
                        bra.s   T135_009
                T135_007:
                        move.w  D7,D0
                        not.w   D0
                T135_008:
                        and.w   D7,(A1)
                        and.w   D7,2(A1)
                        and.w   D7,4(A1)
                        and.w   D7,6(A1)
                        jsr     (A0)
                        addq.l  #8,A1
                        dbf     D2,T135_008
                T135_009:
                        move.w  D4,D0
                        or.w    D7,D0
                        and.w   D0,(A1)
                        and.w   D0,2(A1)
                        and.w   D0,4(A1)
                        and.w   D0,6(A1)
                        not.w   D7
                        move.w  D5,D0
                        and.w   D7,D0
                        not.w   D7
                        jsr     (A0)
                        addq.l  #8,A1
                T135_010:
                        swap    D7
                        adda.w  D7,A1
                        swap    D7
                        tst.w   D7
                        beq.s   T135_011
                        not.w   D7
                T135_011:
                        dbf     D3,T135_006
                        movem.l (A7)+,D4-D7
                        bra.s   T135_029_Return
                T135_012:
                        or.w    D0,6(A1)
                T135_013:
                        or.w    D0,4(A1)
                T135_014:
                        or.w    D0,2(A1)
                T135_015:
                        or.w    D0,(A1)
                T135_016:
                        rts
                T135_017:
                        or.w    D0,6(A1)
                T135_018:
                        or.w    D0,4(A1)
                T135_019:
                        or.w    D0,2(A1)
                        rts
                T135_020:
                        or.w    D0,4(A1)
                T135_021:
                        or.w    D0,(A1)
                T135_022:
                        or.w    D0,6(A1)
                        rts
                T135_023:
                        or.w    D0,6(A1)
                T135_024:
                        or.w    D0,4(A1)
                        rts
                T135_025:
                        or.w    D0,(A1)
                T135_026:
                        or.w    D0,6(A1)
                        or.w    D0,2(A1)
                        rts
                T135_027:
                        or.w    D0,4(A1)
                        or.w    D0,(A1)
                        rts
                V135_1_xxx:
                        dc.w    0x0000,0x8000,0xC000,0xE000
                        dc.w    0xF000,0xF800,0xFC00,0xFE00
                        dc.w    0xFF00,0xFF80,0xFFC0,0xFFE0
                        dc.w    0xFFF0,0xFFF8,0xFFFC,0xFFFE
                        dc.w    0xFFFF
                T135_029_Return:
        }
}

VOID F136_nzzz_VIDEO_ShadeScreenBox(P225_pc_Box, P226_i_Color)
char* P225_pc_Box;
int P226_i_Color;
{
        F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, P225_pc_Box, P226_i_Color | MASK0x8000_SHADE, C160_BYTE_WIDTH_SCREEN); /* Shading will be used: only every other pixel will be written */
}
