/* This program displays the FTL logo animation and plays the associated sound effect. The animation is only a palette animation: there is actually only one image of the FTL logo stored in the file. This image is first loaded using a completely black palette so that nothing is visible on screen. The animation effect is then produced by changing colors in the palette so that each part of the image lights up in sequence. The sound effect is not digitized but rather produced using commands that make use of the noise generator of the Atari ST Programmable Sound Generator (PSG) chip */
asm {
                bra.s   LoadBitmap                      /* Unconditional branch to entry point */
        PlaySoundAndAnimatePalette:
                pea     SoundCommands(PC)
                move.w  #0x0020,-(A7)                   /* Function number for Dosound(). Produce a sound */
                trap    #14                             /* Call XBIOS. Dosound() uses interrupts so that the sound commands are processed while this program continues and performs the palette animation */
                lea     PaletteCommands(PC),A6
        ProcessPaletteCommand:
                move.w  (A6)+,D7                        /* Read next palette command */
                tst.w   D7
                beq.s   RunProgram                      /* Branch if D7 = 0 (if this is the last palette command) */
                cmpi.w  #8,D7
                bcs.s   ProcessDelay                    /* Branch if D7 < 8 (if the palette command is to wait) */
                move.w  D7,D6
                andi.w  #0x0777,D7                      /* Remove most significant nibble from the word which then only contains the color value */
                rol.w   #4,D6                           /* Rotate 4 bits to the left so that the most significant nibble becomes the least significant nibble */
                andi.w  #0x000F,D6                      /* Remove the 3 most significant nibbles from the word which then only contains the color index */
                move.w  D7,-(A7)                        /* Color value */
                move.w  D6,-(A7)                        /* Color index */
                move.w  #0x0007,-(A7)                   /* Function number for Setcolor(). Set a color in hardware palette */
                trap    #14                             /* Call XBIOS */
                bra.s   ProcessPaletteCommand
        ProcessDelay:
                bsr.s   Wait                            /* Branch to subroutine */
                bra.s   ProcessPaletteCommand
        Wait:
                move.w  #0x0025,-(A7)                   /* Function number for Vsync(). Pauses program execution until the next vertical blank interrupt */
                trap    #14                             /* Call XBIOS */
                addq.l  #2,A7                           /* Clean up stack after call */
                dbf     D7,Wait                         /* If D7 is false (not 0) then decrement D7 and branch */
                rts                                     /* Return from subroutine */
        RunProgram:
                pea     EnvironmentString(PC)           /* Pointer to environment string (0 for parent) */
                pea     CommandLineParameters(PC)       /* Command tail (command line parameters) */
                pea     ProgramName(PC)                 /* Pathname of program */
                move.w  #0,-(A7)                        /* Mode: Load and execute named program file and return exit code when child terminates */
                move.w  #0x004B,-(A7)                   /* Function number for Pexec(). Load or execute a process */
                trap    #1                              /* Call GEMDOS */
        InfiniteLoop:
                bra.s   InfiniteLoop
        ProgramName:
                dc.b    "START.PRG",0
        CommandLineParameters:
                dc.b    4,"AUTO",0                      /* 4 is the length of the command line parameter string */
        EnvironmentString:
                dc.b    0,0                             /* Empty environment */
        LoadBitmap:
                move.w  #0x0002,-(A7)                   /* Function number for Physbase(). Returns the address of the physical base of screen memory */
                trap    #14                             /* Call XBIOS */
                addq.l  #2,A7                           /* Clean up stack after call */
                movea.l D0,A1                           /* A1 = address of the physical base of screen memory. A1 is the address where decoded pixels are drawn */
                moveq   #0,D4
                moveq   #0,D5
                lea     BitmapCommands(PC),A0           /* A0 = Address of the bitmap commands for the FTL logo */
                move.w  #160,D7                         /* Bitmap width in bytes. 160 bytes = 320 pixels */
                move.w  #200,D6                         /* Bitmap height. 200 pixels */
                mulu.w  D7,D6                           /* D6 = Bitmap size in bytes */
                movea.l A1,A3                           /* A3 = A1 = screen base address */
                adda.l  D6,A3                           /* A3 = Address of the first byte after the screen memory */
                move.l  A3,D6                           /* D6 = Address of the first byte after the screen memory */
                clr.l   (A1)                            /* Clear the first bitmap unit to prepare the first draw operation */
                clr.l   4(A1)
                move.w  #15,D0                          /* Index of the first pixel left to draw in current bitmap unit */
                moveq   #0,D4

/* Build two tables of 16 long binary masks. One mask from each table may be combined with AND to form the mask of bits to manipulate in a bitmap unit */
                lea     UnitMasks(PC),A6                /* First address after the end of data where the tables will be written */
                movea.w A6,A4
                movea.w A6,A5
                adda.l  #64,A5                          /* A5 = A4 + 64 (size of the first table) */
                movem.l A4-A5,-(A7)                     /* Backup registers to the stack */
                move.w  #0xFFFF,D3
                moveq   #15,D2                          /* This will be used to loop 16 times */
        BuildTable:
                lsl.l   #1,D3                           /* Logical Shift Left register D3 by 1 bit */
                move.w  D3,(A5)+                        /* Write D3 to the address stored in A5 */
                move.w  D3,(A5)+
                swap    D3                              /* Swaps lower and higher 16 bits words in register D3 */
                move.w  D3,(A4)+
                move.w  D3,(A4)+
                swap    D3                              /* Swaps lower and higher 16 bits words in register D3 */
                dbf     D2,BuildTable                   /* Decrement and Branch if False (Loop until D2 = 0). Tables at the end of the loop:
                                                           (A4) 00010001 00030003 00070007 000F000F
                                                                001F001F 003F003F 007F007F 00FF00FF
                                                                01FF01FF 03FF03FF 07FF07FF 0FFF0FFF
                                                                1FFF1FFF 3FFF3FFF 7FFF7FFF FFFFFFFF
                                                           (A5) FFFEFFFE FFFCFFFC FFF8FFF8 FFF0FFF0
                                                                FFE0FFE0 FFC0FFC0 FF80FF80 FF00FF00
                                                                FE00FE00 FC00FC00 F800F800 F000F000
                                                                E000E000 C000C000 80008000 00000000 */
                movem.l (A7)+,A4-A5                     /* Restore registers from stack */
                lea     BitmapUnits(PC),A6              /* A6 = Address of BitmapUnits */

/* This code expands the FTL logo bitmap by interpreting a series of bitmap commands (each command is 1, 2 or 3 bytes large) that draw pixels on screen. Each command may draw multiple pixels that are either of the same color (specified in the command) or copied from the previous line of already expanded bitmap data. It does not implement bitmap commands 9, 10 and 14 which are not used in the FTL logo data */
        ProcessBitmapCommand:
                move.b  (A0)+,D3                        /* Read next byte of FTL Logo data into D3 (most significant nibble: command, least significant nibble: color index) */
                move.b  D3,D2                           /* Copy the byte in register D2 */
                bmi.s   MultiByteCommand                /* Branch if D2 < 0 (if command >= 8) */
                andi.w  #0x000F,D2                      /* D2 = color index */
                lsr.b   #4,D3                           /* D3 = command (0 to 7) */
                moveq   #1,D1
                add.b   D3,D1                           /* D1 = D1 + D3. D1 = number of pixels to draw = command + 1 */
        DrawSame:                                       /* Draw D1 pixels of color D2 */
                lsl.w   #3,D2                           /* D2 = D2 * 8. Each entry in BitmapUnits is 8 bytes large */
                movea.l A6,A2                           /* A2 = A6 = Address of BitmapUnits */
                adda.w  D2,A2                           /* A2 = Address of unit used as source for pixel data */
        LoopSame: /* Draw pixels of the same color */
                bsr.s   DrawPixelsInCurrentUnit         /* Branch to subroutine */
                tst.w   D1
                bne.s   LoopSame                        /* Branch if D1 <> 0 (if there are pixels left to draw for the current bitmap command) */
                bra.s   ProcessBitmapCommand
        MultiByteCommand:
                andi.w  #0x000F,D2                      /* D2 = color index */
                moveq   #0,D1
                move.b  (A0)+,D1                        /* D1 = number of pixels to draw */
                btst    #6,D3
                beq.s   TwoBytesCommand                 /* Branch if bit 6 of D3 = 0 (if command < 12) */
                asl.w   #8,D1                           /* Shift left to make room for one more byte (3 bytes large commands 12 and 15) */
                move.b  (A0)+,D1                        /* Read next byte of data in D1 */
        TwoBytesCommand:
                addq.w  #1,D1                           /* D1 = D1 + 1. Number of pixels to draw */
                btst    #4,D3
                beq.s   DrawSame                        /* Branch if bit 4 of D3 = 0 (if command = 8 or command = 12) */
                movea.l A1,A2                           /* A2 = A1 = Address where decoded pixels are drawn */
                suba.w  D7,A2                           /* Substract D7 = image width in bytes. A2 = Address of source pixel data = address of the previous line from which to copy pixels */
        LoopCopy: /* Draw pixels copied from previous line */
                bsr.s   DrawPixelsInCurrentUnit         /* Branch to subroutine */
                tst.l   D5
                beq.w   Continued                       /* Branch if D5 = 0. This test is always true because D5 always equals 0 */
                movea.l D5,A2                           /* This instruction is never executed */
        Continued:
                addq.l  #8,A2                           /* A2 = A2 + 8. Proceed to the next source bitmap unit of 16 pixels (8 bytes) */
                tst.w   D1
                bne.s   LoopCopy                        /* Branch if D1 <> 0 (if there are pixels left to draw for the current bitmap command) */
                bsr.s   DrawSinglePixel                 /* Branch to subroutine. Draw final pixel for commands 11 and 15 */
                bra.s   ProcessBitmapCommand

/* Subroutine to draw pixels in the current bitmap unit */
        DrawPixelsInCurrentUnit:
                move.b  D0,D4                           /* Index of the first pixel left to draw in current bitmap unit */
                lsl.w   #2,D4                           /* D4 = D4  * 4. 4 bytes per entry in the first table */
                move.l  0(A4,D4.w),D3                   /* Mask for two words of planar bitmap containing the correct number of bits set to 1 */
                cmp.w   D1,D0
                bmi.s   UnitFull                        /* Branch if D0 < D1 (if index of first pixel left to draw in current bitmap unit < number of pixels to draw, if there is not enough room in the current unit to draw all the pixels of the current bitmap command) */
                sub.w   D1,D0                           /* D0 = D0 - D1 */
                move.b  D0,D4                           /* Number of pixels to leave intact in current bitmap unit */
                lsl.w   #2,D4                           /* D4 = D4  * 4. 4 bytes per entry in the second table */
                and.l   0(A5,D4.w),D3                   /* Apply second mask to D3 so it contains the appropriate mask with the correct number of bits set to 1 at the correct positions in two words of planar bitmap */
                moveq   #0,D1                           /* D1 = 0. There are no more pixels to draw */
                bra.s   DrawMultiplePixels
        UnitFull:
                sub.w   D0,D1                           /* D1 = D1 - D0 */
                subq.w  #1,D1                           /* D1 = D1 - 1. The current command has D0 + 1 less pixels left to draw */
                move.w  #-1,D0                          /* No more pixels to draw in current bitmap unit */        
        DrawMultiplePixels:
                move.l  (A2),D5                         /* D5 = input pixel data for first two bits */
                and.l   D3,D5                           /* Apply mask in D3 */
                or.l    D5,(A1)                         /* Draw first two bits of each pixel from D5 */
                move.l  4(A2),D5                        /* D5 = input pixel data for last two bits */
                and.l   D3,D5                           /* AND mask with D3 */
                or.l    D5,4(A1)                        /* Draw last two bits of each pixel from D5 */
                moveq   #0,D5                           /* Zero value in D5 means the subroutine was called to draw multiple pixels */
        PostDraw:
                tst.w   D0
                bpl.s   ExitSub                         /* Branch if D0 > 0 (if there is at least one pixel left to draw in current bitmap unit) */
                addq.l  #8,A1                           /* Proceed to next bitmap unit (8 bytes) */
                cmpa.l  A1,A3
                bne.s   ClearUnit                       /* Branch if A3 <> A1 (if end of screen memory has not been reached) */
                cmp.l   A1,D6
                beq.w   PlaySoundAndAnimatePalette      /* Branch if D6 = A1 (if end of screen memory has been reached) */
                adda.w  D7,A3                           /* This instruction is never executed because A3 = D6 so the condition above cannot be false */
                swap    D7                              /* This instruction is never executed */
                adda.w  D7,A1                           /* This instruction is never executed */
                move.l  A2,D5                           /* This instruction is never executed */
                add.w   D7,D5                           /* BUG0_01 Coding error without consequence. The 16 bit value in D7 is added to D5 (which contains an address) without extending the value to 32 bit. The resulting address may be incorrect if there is a carry. No consequence as this instruction is never executed */
                swap    D7                              /* This instruction is never executed */
        ClearUnit:
                move.w  #15,D0                          /* Number of pixels left to draw in current bitmap unit */
                clr.l   (A1)                            /* Clear next bitmap unit to prepare next draw operation */
                clr.l   4(A1)
        ExitSub:
                rts                                     /* Return from subroutine */

/* Subroutine to draw one pixel whose 4 bit color index is stored in D2. The pixel index in the unit is stored in D0 */
        DrawSinglePixel:
                btst    #3,D0
                bne.s   Bit0FirstByte                   /* Branch if bit 3 of D0 < 8 (if the bits for the pixel are in the first byte of the words in video memory) */
                btst    #0,D2
                beq.s   Bit1SecondByte                  /* Branch if bit 0 of D2 = 0 */
                bset    D0,1(A1)                        /* Set bit in second byte of second word */
        Bit1SecondByte:
                btst    #1,D2
                beq.s   Bit2SecondByte                  /* Branch if bit 1 of D2 = 0 */
                bset    D0,3(A1)                        /* Set bit in second byte of fourth word */
        Bit2SecondByte:
                btst    #2,D2
                beq.s   Bit3SecondByte                  /* Branch if bit 2 of D2 = 0 */
                bset    D0,5(A1)                        /* Set bit in second byte of sixth word */
        Bit3SecondByte:
                btst    #3,D2
                beq.s   NextPixel                       /* Branch if bit 3 of D2 = 0 */
                bset    D0,7(A1)                        /* Set bit in second byte of eigth word */
                bra.s   NextPixel                       /* Branch to subroutine */
        Bit0FirstByte:
                btst    #0,D2
                beq.s   Bit1FirstByte                   /* Branch if bit 0 of D2 = 0 */
                bset    D0,(A1)                         /* Set bit in first byte of first word */
        Bit1FirstByte:
                btst    #1,D2
                beq.s   Bit2FirstByte                   /* Branch if bit 1 of D2 = 0 */
                bset    D0,2(A1)                        /* Set bit in first byte of third word */
        Bit2FirstByte:
                btst    #2,D2
                beq.s   Bit3FirstByte                   /* Branch if bit 2 of D2 = 0 */
                bset    D0,4(A1)                        /* Set bit in first byte of fifth word */
        Bit3FirstByte:
                btst    #3,D2
                beq.s   NextPixel                       /* Branch if bit 3 of D2 = 0 */
                bset    D0,6(A1)                        /* Set bit in first byte of seventh word */
        NextPixel:
                subq.w  #1,D0                           /* Proceed to next pixel */
                bra.w   PostDraw                        /* Inconditional Branch */

        BitmapUnits: /* For each color index 0 to 15, a bitmap unit (4 words, 8 bytes, 16 pixels) where all pixels have the corresponding colox index. These bitmap units are used as a source of pixel data when drawing multiple pixels of the same color */
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
        BitmapCommands: /* Bitmap encoded with IMG1 algorithm but without the 4 bytes header containing the width and height in pixels */
                dc.w    0xC040,0x7D08,0x801B,0x08C0,0x0110,0x0880,0x0E28,0x8019,0x1880,0x0E08,0x300E,0x80FA,0x2880,0x0C48,0x2008,0x7008
                dc.w    0x8009,0x3880,0x0C18,0x40B8,0xE180,0x1008,0x5048,0xB810,0x1028,0x3048,0x6048,0x2018,0x3058,0xB8E7,0x0880,0x0C38
                dc.w    0x3058,0x3018,0x4088,0x0D00,0x6840,0x880A,0x0078,0x50B8,0xE048,0x2008,0x4068,0x1078,0x0058,0x1088,0x1800,0x8815
                dc.w    0xB8D9,0xB811,0x0800,0x2800,0x8808,0x0088,0x47B0,0xD328,0xB810,0x8854,0x2E80,0xD348,0x4088,0x2D0D,0x8A18,0x0D78
                dc.w    0x0D5A,0xB0DD,0x8810,0x0D8A,0x1B0D,0x580A,0x891C,0x0A38,0x0D4A,0x290A,0xB808,0x1880,0xD208,0x1D3A,0x0D58,0x0A89
                dc.w    0x1F0A,0x280A,0x891E,0x0A28,0x4A49,0x0AB8,0x0A18,0x80C9,0x1D2A,0x8708,0x0A38,0x0A89,0x210A,0xBD24,0x3A59,0xB00C
                dc.w    0x80C3,0x1D2A,0x8710,0x0ABD,0x280A,0x891C,0x1A18,0x3A69,0x58B0,0x0480,0xBF1D,0x1A87,0x161A,0x281A,0x891F,0x1ABA
                dc.w    0x038A,0x0949,0x8A0E,0x080D,0xBA09,0xB008,0x80BC,0x1D1A,0x8714,0x7A0D,0x280D,0x8A0A,0x298A,0x1428,0x0D8A,0x0969
                dc.w    0x8A0B,0x0D18,0x3A69,0x584E,0x80B6,0x1D1A,0x8713,0x8A0D,0x0D48,0x0DB9,0x0C8A,0x120D,0x484D,0x3A79,0x0A8D,0x0828
                dc.w    0x0DBA,0x09BD,0xBC0D,0x1A87,0x118A,0x098D,0x0988,0x083D,0x3A59,0x0A8D,0x0F88,0x0A3A,0x8908,0x880C,0x3A69,0x68BD
                dc.w    0xB10D,0x1A87,0x108A,0x083D,0x800A,0x880D,0xB80A,0x8819,0x0DBA,0x0B88,0x0B0D,0xBA09,0x4810,0xBDAC,0x0D1A,0x8710
                dc.w    0x6A2D,0x800F,0x8810,0x3A59,0x0A88,0x1A3A,0x8908,0x880C,0x3A69,0x68BD,0xA90D,0x1A26,0x870B,0x5A2D,0x8013,0x8812
                dc.w    0x0DB8,0x0988,0x190D,0xBA0B,0x880B,0x0DBA,0x0978,0xBDA5,0x1A66,0x675A,0x2D80,0x1A88,0x103A,0x590A,0x881A,0x3A89
                dc.w    0x0888,0x0C3A,0x6988,0x08BD,0xA11A,0x860B,0x075A,0x1D80,0x2288,0x0D0D,0xB809,0x8819,0x0DBA,0x0B88,0x0B0D,0xBA09
                dc.w    0x188E,0x1080,0x940D,0x0A86,0x0C4A,0x1D80,0x2888,0x0C3A,0x598A,0x0E88,0x0C3A,0x8908,0x880C,0x3A7F,0x8E17,0x808C
                dc.w    0x0D0A,0x860A,0x5A1D,0x8029,0x1D3A,0x0D78,0x0D3A,0x8914,0x0A88,0x0A0D,0xBA0B,0x8808,0x2E8F,0x0B8E,0x1E80,0x830D
                dc.w    0x0A86,0x0A4A,0x1D80,0x251D,0x3A87,0x080A,0x683A,0x8916,0x0A88,0x093A,0x395F,0x8E0A,0x8F0C,0x8E24,0x807A,0x0D0A
                dc.w    0x8609,0x4A1D,0x8022,0x1D2A,0x8711,0x0A48,0x0DBD,0x243A,0x790A,0x8809,0xBE0D,0x8E1E,0x807D,0x0D0A,0x8609,0x3A1D
                dc.w    0x801F,0x1D2A,0x8717,0x1A48,0x3A89,0x161A,0x8808,0x3A89,0x0888,0x0C0D,0x2A29,0xB01E,0x8080,0x0D0A,0x8608,0x2A1D
                dc.w    0x801D,0x1D1A,0x8717,0x7A0D,0x380D,0xBA07,0x8A13,0x780D,0xBA0B,0x880C,0x3A69,0x488E,0x1080,0x830D,0x0A86,0x082A
                dc.w    0x1D80,0x1A1D,0x1A87,0x168A,0x0C1D,0x483A,0x598A,0x120D,0x783A,0x8908,0x880C,0x0D2A,0x690A,0x8808,0x204E,0x8086
                dc.w    0x0D0A,0x762A,0x1D80,0x171D,0x1A87,0x158A,0x088D,0x0A58,0x0D3A,0x690A,0x8D0F,0x8808,0x0DBA,0x0B88,0x0C3A,0x6978
                dc.w    0x2018,0x4E18,0x8082,0x0D0A,0x662A,0x1D80,0x151D,0x1A87,0x138A,0x082D,0x800E,0x583A,0x7988,0x193A,0x8908,0x880C
                dc.w    0x0D2A,0x690A,0x880C,0xB005,0x8080,0x0D0A,0x1546,0x1A1D,0x8013,0x1D1A,0x8711,0x7A2D,0x8014,0x680D,0xBA0A,0x8818
                dc.w    0x0DBA,0x0B88,0x0C3A,0x6988,0x0D4E,0x8080,0x0D0A,0x4506,0x2A0D,0x8012,0x0D1A,0x8711,0x6A2D,0x8018,0x8808,0x3A79
                dc.w    0x8819,0x3A89,0x0888,0x0C0D,0x2A69,0x0ABD,0x910A,0x551A,0x0D80,0x110D,0x1A36,0x870B,0x6A2D,0x801E,0x780D,0xBA0A
                dc.w    0x8810,0x0068,0x0DBA,0x0B88,0x0C3A,0x698A,0x0A0D,0xBD0B,0x3C80,0x730D,0x0A45,0x2A0D,0x800F,0x0D1A,0x7667,0x5A2D
                dc.w    0x8022,0x8809,0x3A79,0x880F,0x2068,0x3A89,0x0888,0x0C0D,0x2A89,0x140A,0x182E,0x200D,0x3C1B,0x1C80,0x700D,0x0A35
                dc.w    0x1A0D,0x800E,0x0D1A,0x860C,0x074A,0x2D80,0x2E28,0x0DBA,0x0A78,0x1038,0x3068,0x0DBA,0x0B88,0x0C3A,0x8915,0x0ABD
                dc.w    0x052C,0x5B0C,0x806D,0x0D0A,0x351A,0x0D80,0x0C0D,0x1A86,0x0D3A,0x1D80,0x2A1D,0x3A0D,0x1038,0x3A79,0x8809,0x7078
                dc.w    0x3A89,0x0888,0x0C0D,0xBC20,0x1C7B,0x0C80,0x6B0D,0x0A25,0x1A80,0x0C0D,0x0A86,0x0D3A,0x1D80,0x261D,0x3A87,0x080A
                dc.w    0x380D,0xBA0A,0x880A,0xBD0D,0xBA0B,0x8809,0x00BA,0x0689,0x131A,0xBD04,0x2C8B,0x080C,0x8069,0x0D0A,0x151A,0x800B
                dc.w    0x0D0A,0x860C,0x3A1D,0x8023,0x1D2A,0x8711,0x0AB8,0x0E88,0x0B40,0x780D,0x4A69,0x8809,0x10BA,0x078A,0x1318,0x2E08
                dc.w    0x00BB,0x0B0C,0x8068,0x0A05,0x1A80,0x0A0D,0x0A86,0x0B3A,0x1D80,0x201D,0x2A87,0x171A,0xBA07,0x490A,0x880A,0x800A
                dc.w    0x480D,0x4A49,0x0A68,0x3038,0x0D8A,0x170D,0xB805,0x0D2C,0x8B09,0x0C80,0x660D,0x1A80,0x090D,0x0A86,0x0A3A,0x1D80
                dc.w    0x1D1D,0x2A87,0x186A,0x0D38,0x0D5A,0x190A,0x7880,0x0D68,0x1D7A,0x8808,0x2048,0x8D16,0x382E,0x200D,0x2C8B,0x090C
                dc.w    0x8065,0x0A80,0x080D,0x0A86,0x093A,0x1D80,0x1B1D,0x1A87,0x178A,0x0C1D,0x1028,0x2D5A,0x880A,0x800A,0x8809,0x5D48
                dc.w    0x00B0,0x0888,0x1D2E,0x300D,0x2C8B,0x090C,0x8063,0x0A70,0x0D0A,0x8608,0x2A1D,0x8019,0x1D1A,0x8716,0x8A0B,0x7D40
                dc.w    0x384D,0x880E,0x7038,0x2088,0x0E00,0x5830,0x880F,0x1068,0x0048,0x0E50,0x0D2C,0x8B09,0x0C80,0x690D,0x0A76,0x2A1D
                dc.w    0x8016,0x1D1A,0x8716,0x8A08,0x3D80,0x1088,0x1A40,0x1850,0x880D,0x40B0,0x0B10,0x6840,0x4820,0xB009,0x0D2C,0x8B09
                dc.w    0x0C80,0x660D,0x0A66,0x2A1D,0x8014,0x1D1A,0x8715,0x6A3D,0x8017,0x880E,0x8019,0x4830,0x4870,0x08B0,0x0470,0x2880
                dc.w    0x0818,0x30B0,0x090D,0x2C8B,0x090C,0x8063,0x0D0A,0x1536,0x2A1D,0x8012,0x1D1A,0x1687,0x116A,0x3D80,0x1D48,0x3058
                dc.w    0x801A,0x1880,0x0908,0x800C,0x0880,0x0A08,0x800A,0x0850,0x0E80,0x080D,0x2C8B,0x090C,0x8060,0x0D0A,0x4506,0x1A1D
                dc.w    0x8011,0x1D0A,0x6687,0x0B5A,0x2D80,0x2418,0x800A,0x1880,0x4DBF,0x0680,0x090D,0x2C8B,0x090C,0x805D,0x0D0A,0x452A
                dc.w    0x0D80,0x101D,0x0A86,0x0A67,0x4A2D,0x8029,0x0880,0x140D,0x8A4D,0x0F8C,0x0E8B,0x090C,0x805A,0x0D0A,0x451A,0x0D80
                dc.w    0x100D,0x0A86,0x0F07,0x4A1D,0x8033,0x0D8A,0x1089,0x4E0F,0x8B19,0x0C80,0x581A,0x351A,0x0D80,0x0E1D,0x0A86,0x0E4A
                dc.w    0x1D80,0x2D1D,0x8A08,0x8960,0xBB1A,0x0C80,0x550D,0x0A35,0x1A0D,0x800D,0x0D0A,0x860D,0x4A1D,0x8028,0x1D7A,0x7789
                dc.w    0x63BD,0x710A,0x251A,0x0D80,0x0C0D,0x0A86,0x0C3A,0x1D80,0x241D,0x6A87,0x1189,0x638B,0x1C0C,0x8052,0x0D0A,0x151A
                dc.w    0x0D80,0x0B0D,0x0A86,0x0B3A,0x1D80,0x201D,0x5A87,0x1ABA,0xD415,0x0A0D,0x800A,0x0D0A,0x860B,0x2A1D,0x801D,0x1D4A
                dc.w    0x8723,0xBAD2,0x051A,0x8009,0x0D0A,0x860A,0x3A1D,0x801A,0x1D3A,0x872A,0xBC7E,0xBD51,0x1A80,0x090D,0x0A86,0x092A
                dc.w    0x1D80,0x181D,0x3A87,0x30BC,0x7C1C,0x8051,0x0A80,0x090D,0x0A86,0x082A,0x1D80,0x170D,0x2A87,0x3789,0x198A,0x478C
                dc.w    0x1B0D,0x8050,0x0A80,0x080D,0x0A76,0x2A1D,0x8015,0x1D2A,0x8738,0x8A64,0x8C19,0x1D80,0x590D,0x0A15,0x462A,0x1D80
                dc.w    0x131D,0x2A16,0x872D,0x8A2C,0x8D5F,0x8059,0x0D0A,0x4516,0x1A1D,0x8012,0x1D1A,0x6687,0x228A,0x198D,0x0F80,0xC50D
                dc.w    0x0A65,0x1A0D,0x8012,0x0D1A,0x860B,0x8717,0x8A15,0x8D09,0x80D7,0x0D0A,0x651A,0x0D80,0x101D,0x1A86,0x0E87,0x108A
                dc.w    0x126D,0x80E3,0x1A55,0x1A0D,0x800E,0x1D1A,0x8614,0x778A,0x115D,0x80EB,0x0A55,0x1A0D,0x800D,0x0D1A,0x8619,0x078A
                dc.w    0x0F5D,0x80F1,0x0D0A,0x451A,0x0D80,0x0C0D,0x1A86,0x188A,0x0E3D,0x80F8,0x0D0A,0x351A,0x0D80,0x0B0D,0x1A86,0x168A
                dc.w    0x0E2D,0x80FE,0x0A35,0x0A0D,0x800A,0x0D1A,0x8614,0x8A0E,0x2DC0,0x0102,0x0A25,0x0A0D,0x800A,0x0D1A,0x8612,0x8A0D
                dc.w    0x2DC0,0x0106,0x0DBA,0x020D,0x8008,0x0D1A,0x8611,0x8A0C,0x2DC0,0x010B,0x0A15,0x0A80,0x080D,0x1A86,0x0F8A,0x0C2D
                dc.w    0xC001,0x0FBA,0x0170,0x0D0A,0x0586,0x0E8A,0x0C1D,0xC001,0x131A,0x600D,0x0A25,0x860B,0x8A0C,0x1DC0,0x0115,0x1A60
                dc.w    0x0D0A,0x4576,0x8A0C,0x1DC0,0x0118,0x0A50,0x0D0A,0x7536,0x8A0C,0x1DC0,0x0121,0x0D0A,0x850A,0x8A0C,0x0DC0,0x0123
                dc.w    0x0D0A,0x8509,0x8A0C,0x0DC0,0x0125,0x0A85,0x088A,0x0C0D,0xC001,0x260D,0x758A,0x0A05,0x0A0D,0xC001,0x270D,0x0A55
                dc.w    0x8A09,0x150A,0x0DC0,0x0129,0x0A55,0x8A08,0x150A,0x0DC0,0x012A,0x0A55,0x7A15,0x0A0D,0xC001,0x2B0D,0xBA05,0x6A15
                dc.w    0x0A0D,0xC001,0x2C0A,0x457A,0x150A,0x0DC0,0x012D,0xBA04,0x6A15,0x0A0D,0xC001,0x2D0D,0xB50B,0x050A,0x0DC0,0x012E
                dc.w    0x0A35,0x6A25,0x0AC0,0x012F,0xBA0D,0x0DF5,0x013A,0x150D,0xC001,0x30FD,0x03BF,0x0ABA,0x0B0D,0xC001,0x300A,0x04B4
                dc.w    0x0814,0x0AC0,0x0130,0x0D0A,0x146A,0xBD03,0xC001,0x300A,0x245A,0x340A,0x0DC0,0x012F,0x0D0A,0x146A,0x340A,0x0DC0
                dc.w    0x012F,0x0D0A,0x145A,0x440A,0x0DC0,0x012F,0x0D0A,0x145A,0x540A,0x0DC0,0x012E,0x0D0A,0x145A,0x640A,0x0DC0,0x012D
                dc.w    0x0D0A,0x145A,0x740A,0x0DC0,0x012D,0x1A04,0x6A74,0x0A0D,0xC001,0x2C0D,0x8A08,0x8409,0x0A0D,0xC001,0x2A1D,0x8A08
                dc.w    0x840A,0x0A0D,0xC001,0x291D,0x8A08,0x840B,0x0A0D,0xC001,0x282D,0x7A84,0x0833,0x0A0D,0xC001,0x282D,0x7A44,0x730A
                dc.w    0x0DC0,0x0129,0x1D7A,0x830D,0x0A0D,0xC001,0x281D,0x7A83,0x0E0A,0x0DC0,0x0127,0x2D6A,0x830F,0x0A0D,0xC001,0x272D
                dc.w    0x6A83,0x0F0A,0x0DC0,0x0127,0x3D5A,0x8310,0x0A0D,0xC001,0x273D,0x5A83,0x0972,0x0A0D,0xC001,0x263D,0x5A23,0x820E
                dc.w    0x1A0D,0xC001,0x253D,0x5A82,0x141A,0x0DC0,0x0123,0x2D8A,0x0882,0x161A,0x1DC0,0x0120,0x2D8A,0x0882,0x0C81,0x0B2A
                dc.w    0x1DC0,0x011D,0x2D8A,0x0A81,0x1A3A,0x2DC0,0x011B,0x1D8A,0x0D81,0x183A,0x2DC0,0x011D,0x1D8A,0x0C81,0x210A,0x0DC0
                dc.w    0x2612
        SoundCommands: /* Sound commands encoded for XBIOS Dosound() function */
                dc.b    0x08,0x10       /* Write value 0x10 in register 0x08. Configures channel A to use the envelope setting in register 0D */
                dc.b    0x09,0x10       /* Write value 0x10 in register 0x09. Configures channel B to use the envelope setting in register 0D */
                dc.b    0x0C,0x0D       /* Write value 0x0D in register 0x0C. Sets the high byte of the frequency of the waveform specified in register 13 */
                dc.b    0x0D,0x0D       /* Write value 0x0D in register 0x0D. Configures the envelope wavefrom of the PSG */
                dc.b    0x06,0x1F       /* Write value 0x1F in register 0x06. The lower 5 bits of register 06 set the pitch of white noise. The lower the value, the higher the pitch */
                dc.b    0x07,0x27       /* Write value 0x27 in register 0x07. Enable tone on channels A, B, C and enable white noise on channel C */
                dc.b    0xFF,0x02       /* Wait for 2 vertical blank cycles */
                dc.b    0x06,0x1C       /* Write value 0x1C in register 0x06. The lower 5 bits of register 06 set the pitch of white noise. The lower the value, the higher the pitch */
                dc.b    0xFF,0x02       /* Wait for 2 vertical blank cycles */
                dc.b    0x06,0x19       /* Write value 0x19 in register 0x06. The lower 5 bits of register 06 set the pitch of white noise. The lower the value, the higher the pitch */
                dc.b    0xFF,0x02       /* Wait for 2 vertical blank cycles */
                dc.b    0x06,0x16       /* Write value 0x16 in register 0x06. The lower 5 bits of register 06 set the pitch of white noise. The lower the value, the higher the pitch */
                dc.b    0xFF,0x02       /* Wait for 2 vertical blank cycles */
                dc.b    0x06,0x13       /* Write value 0x13 in register 0x06. The lower 5 bits of register 06 set the pitch of white noise. The lower the value, the higher the pitch */
                dc.b    0xFF,0x02       /* Wait for 2 vertical blank cycles */
                dc.b    0x06,0x10       /* Write value 0x10 in register 0x06. The lower 5 bits of register 06 set the pitch of white noise. The lower the value, the higher the pitch */
                dc.b    0xFF,0x02       /* Wait for 2 vertical blank cycles */
                dc.b    0x06,0x0C       /* Write value 0x0C in register 0x06. The lower 5 bits of register 06 set the pitch of white noise. The lower the value, the higher the pitch */
                dc.b    0xFF,0x02       /* Wait for 2 vertical blank cycles */
                dc.b    0x06,0x08       /* Write value 0x08 in register 0x06. The lower 5 bits of register 06 set the pitch of white noise. The lower the value, the higher the pitch */
                dc.b    0xFF,0x02       /* Wait for 2 vertical blank cycles */
                dc.b    0x06,0x04       /* Write value 0x04 in register 0x06. The lower 5 bits of register 06 set the pitch of white noise. The lower the value, the higher the pitch */
                dc.b    0xFF,0x02       /* Wait for 2 vertical blank cycles */
                dc.b    0x06,0x00       /* Write value 0x00 in register 0x06. The lower 5 bits of register 06 set the pitch of white noise. The lower the value, the higher the pitch */
                dc.b    0xFF,0x02       /* Wait for 2 vertical blank cycles */
                dc.b    0x0C,0x0A       /* Write value 0x0A in register 0x0C. Sets the high byte of the frequency of the waveform specified in register 13 */
                dc.b    0x0D,0x09       /* Write value 0x09 in register 0x0D. Configures the envelope wavefrom of the PSG */
                dc.b    0xFF,0x00       /* End of sound data */
        PaletteCommands: /* Palette commands used by the palette animation routine */
                dc.w    0x1777          /* Set color #1 to white (RGB = 777) */
                dc.w    0x0001          /* Wait for 1 vertical blank cycle */
                dc.w    0x2777          /* Set color #2 to white (RGB = 777) */
                dc.w    0x0001          /* Wait for 1 vertical blank cycle */
                dc.w    0x3777          /* Set color #3 to white (RGB = 777) */
                dc.w    0x0002          /* Wait for 2 vertical blank cycles */
                dc.w    0x4777          /* Set color #4 to white (RGB = 777) */
                dc.w    0x0002          /* Wait for 2 vertical blank cycles */
                dc.w    0x5777          /* Set color #5 to white (RGB = 777) */
                dc.w    0x0003          /* Wait for 3 vertical blank cycles */
                dc.w    0x6777          /* Set color #6 to white (RGB = 777) */
                dc.w    0x0003          /* Wait for 3 vertical blank cycles */
                dc.w    0x7777          /* Set color #7 to white (RGB = 777) */
                dc.w    0x0003          /* Wait for 3 vertical blank cycles */
                dc.w    0x8777          /* Set color #8 to white (RGB = 777) */
                dc.w    0x9777          /* Set color #9 to white (RGB = 777) */
                dc.w    0xA555          /* Set color #10 to light grey (RGB = 555) */
                dc.w    0xF777          /* Set color #15 to white (RGB = 777) */
                dc.w    0x0003          /* Wait for 3 vertical blank cycles */
                dc.w    0x8000          /* Set color #8 to black (RGB = 000) */
                dc.w    0xB777          /* Set color #11 to white (RGB = 777) */
                dc.w    0xC555          /* Set color #12 to light grey (RGB = 555) */
                dc.w    0xD222          /* Set color #13 to dark grey (RGB = 222) */
                dc.w    0x0003          /* Wait for 3 vertical blank cycles */
                dc.w    0xF770          /* Set color #15 to yellow (RGB = 770) */
                dc.w    0xE770          /* Set color #14 to yellow (RGB = 770) */
                dc.w    0x0000          /* End of palette commands */
        UnitMasks: /* These masks are generated dynamically */
}
