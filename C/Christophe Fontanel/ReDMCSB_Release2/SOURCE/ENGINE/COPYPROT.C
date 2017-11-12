#include "DEFS.H"

#ifndef NOCOPYPROTECTION
/*_Global variables_*/
BOOLEAN G624_B_FloppyDriveTurnedOn_COPYPROTECTIONDF = FALSE;
int G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF = 0;
SUBROUTINE G626_pfV_S080_aaat_COPYPROTECTIONDF_CheckDMATransferCompletion;
SUBROUTINE G627_pfV_S081_aaao_COPYPROTECTIONDF_TurnOffFloppyDrive;


overlay "main"

int F079_a002_COPYPROTECTIONC_GetChecksumAdd(P095_pfV_Function)
VOID (*P095_pfV_Function)();
{
        asm {
                        movea.l P095_pfV_Function(A6),A0
                        cmpi.w  #0x4EF9,(A0)
                        bne.s   T079_001                        /* If A0 is not the address of a jmp instruction ($4EF9) from the jumptable */
                        movea.l 2(A0),A0                        /* Replace A0 by the target address of the jmp */
                T079_001:
                        moveq   #100,D0
                        move.l  #0x4E5E4E75,D1                  /* These are the bytes for instructions unlk A6 / rts which mark the end of the function */
                T079_002_Loop:
                        add.w   (A0)+,D0                        /* Add word values from start of the function */
                        cmp.l   (A0),D1
                        bne.s   T079_002_Loop                   /* Continue adding words until the end of the function is reached */
        }
}

asm {
        S080_aaat_COPYPROTECTIONDF_CheckDMATransferCompletion:
                lea     G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF(A4),A1
                cmpi.w  #259,(A1)
                beq.s   T080_001
                btst    #5,0xFA01                                               /* Test bit 5 of the MFP GPIP (the chip managing DMA transfers) */
                beq.s   T080_002                                                /* If this bit is 1, a DMA transfer from the floppy disk controller is still ongoing. If this bit is 0, then the DMA transfer is complete */
                moveq   #-2,D0                                                  /* Return value -2 means 'DMA transfer is not complete yet' */
        T080_001:
                subq.w  #1,(A1)                                                 /* Decrement timeout value */
                beq.s   T080_005                                                /* If 0 then this means the DMA transfer has timed out */
                rts
        T080_002:
                movea.w #0x8606,A0                                              /* Address of the DMA mode/status register */
                move.w  #0x0090,(A0)                                            /* Write mode $90 to the DMA mode/status register. Set read mode (from DMA to memory) from the FDC. Subsequent write to -2(A0) = 0xFFFF8604 will be directed to the DMA internal sector count register */
                moveq   #1,D0
                and.w   (A0),D0                                                 /* If bit 0 of register 0xFFFF8606 is 0 then there is a DMA error otherwise there is no DMA error */
                beq.s   T080_004                                                /* Branch if bit 0 = 0 (DMA error) */
                move.w  #0x0080,(A0)                                            /* Write mode $80 to the DMA mode/status register. Subsequent read/write from/to -2(A0) = 0xFFFF8604 will be directed to the FDC STATUS/CONTROL register */
                moveq   #44,D0                                                  /* Delay */
        T080_003_Loop:
                subq.w  #1,D0
                bne.s   T080_003_Loop                                           /* This loop introduces the necessary delay for programming the FDC */
                moveq   #0x10,D0                                                /* This is a mask with only bit 4 set */
                and.w   -2(A0),D0                                               /* Read the STATUS register of the FDC and apply the mask in D0 to keep only bit 4 */
                beq.s   T080_005                                                /* Branch if bit 4 = 0. The FDC sets this bit to indicate 'RECORD NOT FOUND (RNF)' (track, sector or side not found) */
                moveq   #-7,D0
        T080_004:
                subq.w  #1,D0
        T080_005:
                move.w  D0,(A1)                                                 /* Floppy Drive DMA Timeout = D0:
                                                                                        -8 if the FDC returned error 'Record not found'
                                                                                        -2 if the read operation timed out
                                                                                        -1 if the DMA reported a transfer error
                                                                                         0 if the read operation succeeded */
                bne.s   T080_006                                                /* If an error occured during the transfer */
                clr.w   G314_i_SectorsReadRequested_COPYPROTECTIONDF(A4)
        T080_006:
                clr.w   C0x043E_ADDRESS_SYSTEM_VARIABLE_flock                   /* Clear flock to indicate that DMA is not busy anymore */
                rts
        S081_aaao_COPYPROTECTIONDF_TurnOffFloppyDrive:
                tst.w   C0x043E_ADDRESS_SYSTEM_VARIABLE_flock                   /* Test flock. This value is not 0 if the floppy disk is being accessed. This is a system semaphore to avoid DMA conflicts */
                bne.s   T081_001                                                /* Branch if flock != 0 */
                move.w  0x8604,D0                                               /* Address of DMA data register */
                btst    #7,D0                                                   /* Status byte from the DMA data register (MOTOR ON). This bit is 0 if the floppy drive motor is on, 1 if it is off */
                bne.s   T081_001                                                /* Branch if bit7 != 0 (if motor is already stopped) */
                movea.w #0x8800,A0                                              /* This is the address of the Programmable Sound Generator (PSG, YM2149 sound chip) Read data/Register select */
                moveq   #7,D0                                                   /* This is used as a bit mask 00000111 */
                move    SR,D1                                                   /* Backup Status Register in D1 */
                ori     #0x0700,SR                                              /* Set interrupt priority mask = 7. All interrupts <= 7 are now ignored. This includes Horizontal Blank interrupts (level 2), Vertical Blank interrupts (level 4) and MFP interrupts (level 6) */
                move.b  #14,(A0)                                                /* Write $0E to the PSG register select. This selects I/O port A */
                or.b    (A0),D0                                                 /* Read data from chip and apply binary mask in D0 to set bits 0 to 2 and not change bits 3 to 7, in order to turn off floppy drive 0 and its light (this will also stop the motor) */
                move.b  D0,2(A0)                                                /* Write D0 to the write address of the PSG */
                move    D1,SR                                                   /* Restore Status Register from D1 */
                clr.w   G624_B_FloppyDriveTurnedOn_COPYPROTECTIONDF(A4)
        T081_001:
                rts
}


overlay "show"

VOID F137_pzzz_COPYPROTECTIONEF_PatchFunctionWithHiddenCodeLauncher(P227_pfV_FunctionToPatch, P228_pfpuc_GetGraphicAddressFunction, P229_i_GraphicIndex, P230_pc_SectorBuffer, P231_pc_HiddenCodeParameters, P232_pps_CodePatches, P233_i_CodePatchCount)
register VOID (*P227_pfV_FunctionToPatch)();
unsigned char* (*P228_pfpuc_GetGraphicAddressFunction)();
int P229_i_GraphicIndex;
char* P230_pc_SectorBuffer;
char* P231_pc_HiddenCodeParameters;
CODE_PATCH** P232_pps_CodePatches;
int P233_i_CodePatchCount;
{
        register CODE_PATCH* L0233_ps_CodePatch;


        do {
                L0233_ps_CodePatch = P232_pps_CodePatches[M02_RANDOM(P233_i_CodePatchCount)];
                if (L0233_ps_CodePatch->Used); /* BUG0_00 Useless code */
        } while (L0233_ps_CodePatch->Used);
        L0233_ps_CodePatch->Used = TRUE;
        F007_aAA7_MAIN_CopyBytes(&R138_lzzz_COPYPROTECTIONEF_HiddenCodeLauncher, L0233_ps_CodePatch, 42);
        asm {
                T137_002:
                        cmpi.w  #0x4EF9,(P227_pfV_FunctionToPatch)
                        bne.s   T137_003                                                /* If the first instruction of the function to patch is not a jmp ($4EF9). A jmp instruction would mean we are in the jumptable and not directly on the function */
                        movea.l 2(P227_pfV_FunctionToPatch),P227_pfV_FunctionToPatch    /* Use the address following the jmp instruction (this is the real address of the function) */
                        bra.s   T137_002
                T137_003:
        }
        F007_aAA7_MAIN_CopyBytes(P227_pfV_FunctionToPatch, L0233_ps_CodePatch->FirstWords, sizeof(L0233_ps_CodePatch->FirstWords));
        L0233_ps_CodePatch->PatchedFunction = P227_pfV_FunctionToPatch;
        L0233_ps_CodePatch->GetGraphicAddressFunction = P228_pfpuc_GetGraphicAddressFunction;
        L0233_ps_CodePatch->GraphicIndex = P229_i_GraphicIndex;
        L0233_ps_CodePatch->SectorBuffer = P230_pc_SectorBuffer;
        L0233_ps_CodePatch->HiddenCodeParameters = P231_pc_HiddenCodeParameters;
        asm {
                move.w  #0x4EF9,(P227_pfV_FunctionToPatch)+             /* Write bytes for jmp instruction */
                move.l  L0233_ps_CodePatch,(P227_pfV_FunctionToPatch)   /* Replace the following long with the buffer address containing the routine */
        }
}

asm {
        R138_lzzz_COPYPROTECTIONEF_HiddenCodeLauncher:
                lea     V138_6_xxx_BufferIsUsed_FirstWords(PC),A0
                clr.w   (A0)+                                                   /* Clear first word so that the buffer is now marked as free */
                movea.l V138_1_xxx_JMPTargetAddress_PatchedFunction(PC),A1      /* Address of patched function */
                move.l  (A0)+,(A1)+                                             /* Restore the first two words (a long) */
                move.w  (A0),(A1)                                               /* Restore the third word */
                movea.l V138_2_xxx_GetGraphicAddressFunction(PC),A0
                move.w  V138_3_xxx_GraphicIndex(PC),-(A7)
                jsr     (A0)
                movea.l D0,A0                                                   /* Address of graphic (hidden code) in memory */
                move.l  V138_5_xxx_HiddenCodeParameters(PC),-(A7)               /* Address of result structure */
                move.l  V138_4_xxx_SectorBuffer(PC),-(A7)                       /* Address of buffer storing copy protection sector */
                jsr     (A0)                                                    /* Run hidden code */
                lea     0x000A(A7),A7
                dc.w    0x4EF9                                                  /* Jump to original patched function. Note: the execution result of graphic #21 or #538 is stored in the result structure by the routine itself, return value in D0 is ignored */
        V138_1_xxx_JMPTargetAddress_PatchedFunction:
                dc.l    0x00000000
        V138_2_xxx_GetGraphicAddressFunction:
                dc.l    0x00000000
        V138_3_xxx_GraphicIndex:
                dc.w    0x0000
        V138_4_xxx_SectorBuffer:
                dc.l    0x00000000
        V138_5_xxx_HiddenCodeParameters:
                dc.l    0x00000000
        V138_6_xxx_BufferIsUsed_FirstWords:
                dc.w    0x0000                                                  /* First word is 0 if buffer is not used, set to 1 if used */
                dc.w    0x0000,0x0000,0x0000                                    /* Copy of the first three words of the patched function (they were replaced with a jump to this routine) */
}


overlay "dunman"

BOOLEAN F210_uzzz_COPYPROTECTIONE_ProcessEvent22_IsSector7Valid_NormalBytes(P431_puc_SectorBuffer)
register unsigned char* P431_puc_SectorBuffer;
{
        if ((*P431_puc_SectorBuffer++ != 0x07) || (*P431_puc_SectorBuffer++ != 'P') || (*P431_puc_SectorBuffer++ != 'A') || (*P431_puc_SectorBuffer++ != 'C') || (*P431_puc_SectorBuffer++ != 'E') || (*P431_puc_SectorBuffer++ != '/') || (*P431_puc_SectorBuffer++ != 'F') || (*P431_puc_SectorBuffer != 'B') || (P431_puc_SectorBuffer[503] != 'F') || (P431_puc_SectorBuffer[504] != 'B')) {
                return FALSE;
        }
        G240_i_Graphic559_State_COPYPROTECTIOND += 4; /* The effect of this variable is based on whether the value is odd or even. Adding 4 has no actual effect: an odd value remains odd, an even value remains even */
        return 4;
}

SUBROUTINE F211_vzzz_COPYPROTECTIONDF_GetSubroutineAbsoluteAddress(P432_pfV_Function)
VOID (*P432_pfV_Function)();
{
        asm {
                        movea.l P432_pfV_Function(A6),A0
                        cmpi.w  #0x4EF9,(A0)
                        bne.s   T211_001                        /* If A0 is not the address of a jmp instruction ($4EF9) from the jumptable */
                        movea.l 2(A0),A0                        /* Replace A0 by the target address of the jmp */
                T211_001:
                        move.l  A0,D0
        }
}


overlay "timeline"

BOOLEAN F277_jzzz_COPYPROTECTIONE_IsSector7Valid_FuzzyBits(P593_puc_SectorBuffer)
register unsigned char* P593_puc_SectorBuffer;
{
        register int L0780_i_ByteIndex;
        register int L0781_i_Counter;
        register int L0782_i_FuzzyBitCount;
        register int L0783_i_FuzzyBits;
        int L0784_i_DifferingWordCount;


        L0782_i_FuzzyBitCount = 0;
        L0784_i_DifferingWordCount = 0;
        L0781_i_Counter = 0;
        L0783_i_FuzzyBits = 0;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_04_IMPROVEMENT */
        G068_i_CheckLastEvent22Time_COPYPROTECTIONE = C00512_FALSE;
#endif
        for(L0780_i_ByteIndex = 20; L0780_i_ByteIndex < 509; L0780_i_ByteIndex++) {
                L0783_i_FuzzyBits = (L0783_i_FuzzyBits << 1) | ((P593_puc_SectorBuffer[L0780_i_ByteIndex] >> 7) & 0x0001);
                if (((L0782_i_FuzzyBitCount++) == 16) || (L0780_i_ByteIndex == 508)) {
                        L0782_i_FuzzyBitCount = 0;
                        if (L0783_i_FuzzyBits != G293_ai_FuzzyBits_COPYPROTECTIONE[L0781_i_Counter]) {
                                L0784_i_DifferingWordCount++;
                        }
                        G293_ai_FuzzyBits_COPYPROTECTIONE[L0781_i_Counter++] = L0783_i_FuzzyBits;
                        L0783_i_FuzzyBits = 0;
                }
        }
        if (!L0784_i_DifferingWordCount) {
                G418_l_LastEvent22Time_COPYPROTECTIONE = 0;
        }
        G031_i_Graphic562_Sector7Analyzed_COPYPROTECTIONE = C00136_TRUE;
        return L0784_i_DifferingWordCount;
}


overlay "player"

BOOLEAN F356_ozzz_COPYPROTECTIONE_IsSector7Valid_ByteValuesAndFuzzyBitCount(P720_pc_SectorBuffer)
register char* P720_pc_SectorBuffer;
{
        register int L1104_i_ByteIndex;
        register unsigned int L1105_ui_Byte;
        register int L1106_i_FuzzyBitCount;
        static int G628_i_LastFuzzyBitCount_COPYPROTECTIONE;
        static int G629_i_ConsecutiveIdenticalFuzzyBitCounts_COPYPROTECTIONE;


        L1106_i_FuzzyBitCount = 0;
        L1104_i_ByteIndex = 20;
        P720_pc_SectorBuffer += L1104_i_ByteIndex;
        while (L1104_i_ByteIndex++ < 509) {
                if (((L1105_ui_Byte = *P720_pc_SectorBuffer++) & 0x007F) != 0x0068) {
                        T356_002:
                        G189_i_Graphic558_StopAddingEvents_COPYPROTECTIONE = C65152_TRUE;
                        return FALSE;
                }
                if (L1105_ui_Byte == 0x00E8) {
                        L1106_i_FuzzyBitCount++;
                }
        }
        if (L1106_i_FuzzyBitCount == G628_i_LastFuzzyBitCount_COPYPROTECTIONE) {
                if (++G629_i_ConsecutiveIdenticalFuzzyBitCounts_COPYPROTECTIONE > 3) {
                        goto T356_002;
                }
        }
        G629_i_ConsecutiveIdenticalFuzzyBitCounts_COPYPROTECTIONE = 0;
        G628_i_LastFuzzyBitCount_COPYPROTECTIONE = L1106_i_FuzzyBitCount;
        G488_i_Graphic560_RequestCheckFuzzyBitCount_COPYPROTECTIONE = C12777_FALSE;
        return TRUE;
}


overlay "user"

int F413_AA08_COPYPROTECTIONC_GetChecksumEor(P796_pfV_Function)
VOID (*P796_pfV_Function)();
{
        asm {
                        moveq   #10,D1
                        movea.l P796_pfV_Function(A6),A0
                        move.l  #0x4E5E4E75,D2                  /* These are the bytes for instructions unlk A6 / rts which mark the end of the function */
                        cmpi.w  #0x4EF9,(A0)
                        bne.s   T413_001                        /* If A0 is not the address of a jmp instruction ($4EF9) from the jumptable */
                        movea.l 2(A0),A0                        /* Replace A0 by the target address of the jmp */
                T413_001:
                        moveq   #0,D0
                T413_002_Loop:
                        add.w   (A0)+,D1                        /* Add words from start of the function */
                        eor.w   D1,D0
                        cmp.l   (A0),D2
                        bne.s   T413_002_Loop
        }
}


overlay "start"

int F464_AA07_COPYPROTECTIONC_GetChecksumSub(P870_pfV_Function)
VOID (*P870_pfV_Function)();
{
        asm {
                        moveq   #27,D0
                        movea.l P870_pfV_Function(A6),A1
                        move.l  #0x4E5E4E75,D2                  /* These are the bytes for instructions unlk A6 / rts which mark the end of the function */
                        moveq   #0,D1
                        cmpi.w  #0x4EF9,(A1)
                        bne.s   T464_001_Loop                   /* If A1 is not the address of a jmp instruction ($4EF9) from the jumptable */
                        movea.l 2(A1),A1                        /* Replace A1 by the target address of the jmp */
                T464_001_Loop:
                        sub.w   (A1)+,D0                        /* Substract words from start of the function */
                        addq.w  #1,D1
                        add.w   D1,D0
                        cmp.l   (A1),D2
                        bne.s   T464_001_Loop
        }
}

asm {
        S465_qzzz_COPYPROTECTIOND_ReadSector247:
        S465Loop:
                tst.w   G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF(A4)
                bne.s   S465Loop
                moveq   #MASK0x0004_SECTOR247,D0
                or.w    D0,G314_i_SectorsReadRequested_COPYPROTECTIONDF(A4)
                move.l  A2,D3                                                   /* Backup A2 in D3 */
                clr.l   -(A7)
                move.w  #0x0020,-(A7)
                trap    #1                                                      /* Call GEMDOS function Super() */
                move.l  D0,2(A7)                                                /* Store result in the stack, in place of the long. The stack is not cleaned up as another identical call will be made later */
                tst.w   C0x043E_ADDRESS_SYSTEM_VARIABLE_flock                   /* Check if system variable flock is equal to 0. This variable must be non zero while using the DMA to prevent the OS from using DMA during vertical blank. This is required during all disk activity */
                bne.s   T465_001
                move.w  #1,C0x043E_ADDRESS_SYSTEM_VARIABLE_flock                /* Set flock system variable to 1 (non zero value) */
                move.w  #259,G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF(A4)  /* This is the maximum number of Vertical Blanks to wait before the read operation will time out */
                move.w  #TRUE,G624_B_FloppyDriveTurnedOn_COPYPROTECTIONDF(A4)   /* This flag is checked in vertical blank to turn off the floppy drive when reading is complete */
                movea.w #0x8800,A1                                              /* This is the address of the Programmable Sound Generator (PSG, YM2149 sound chip) Read data/Register select */
                moveq   #0xF8,D2                                                /* This is used as bit mask 11111000 */
                move    SR,D0                                                   /* Backup Status Register in D0 */
                ori     #0x0700,SR                                              /* Set interrupt priority mask = 7. All interrupts <= 7 will now be ignored. This includes Horizontal Blank interrupts (level 2), Vertical Blank interrupts (level 4) and MFP interrupts (level 6) */
                move.b  #0x0E,(A1)                                              /* Write $0E to the PSG register select. This selects I/O port A */
                and.b   (A1),D2                                                 /* Read data from chip and apply binary mask in D2 to only keep bits 3 to 7 and clear bits 0 to 2 */
                ori.b   #0x05,D2                                                /* Enable bits 0 and 2 in D2 in order to turn on drive 0 and its light (but not the motor), and select side 0 */
                move.b  D2,2(A1)                                                /* Write D2 to the write address of the PSG */
                movea.w #0x8606,A1                                              /* Address of the DMA mode/status register */
                move.w  #0x0084,(A1)                                            /* Write mode $84 to the DMA mode/status register. Subsequent read/write from/to -2(A1) = $FFFF8604 will be directed to the FDC SECTOR register */
                moveq   #C247_SECTOR_247,D1                                     /* Sector count to read */
                bsr.s   T465_002_SendD1ToFDCRegister
                move.b  0x000D(A7),0xFFFF860D                                   /* Address of the DMA base and counter (Low byte)  (Buffer address where the sector will be read) */
                move.b  0x000C(A7),0xFFFF860B                                   /* Address of the DMA base and counter (Mid byte)  (Buffer address where the sector will be read) */
                move.b  0x000B(A7),0xFFFF8609                                   /* Address of the DMA base and counter (High byte) (Buffer address where the sector will be read) */
                move.w  #0x0090,(A1)                                            /* Write mode $90 to the DMA mode/status register. Set read mode (from DMA to memory) from the FDC. Subsequent write to -2(A1) = 0xFFFF8604 will be directed to the DMA internal sector count register */
                move.w  #0x0190,(A1)                                            /* Write mode $190 to the DMA mode/status register. Set write mode (from memory to DMA) from the FDC. Subsequent write to -2(A1) = 0xFFFF8604 will be directed to the DMA internal sector count register */
                move.w  #0x0090,(A1)                                            /* Write mode $90 to the DMA mode/status register. Set read mode (from DMA to memory) from the FDC. Subsequent write to -2(A1) = 0xFFFF8604 will be directed to the DMA internal sector count register. This sequence of operations (toggling the DMA mode) clears the DMA FIFO buffers and prepares for a read operation */
                move.w  #1,-2(A1)                                               /* Write sector count = 1 to the DMA to read one sector. This triggers the DMA transfer operation */
                move.w  #0x0080,D1                                              /* This value is written both to the DMA mode/status register on the next line and to the FDC CONTROL register below. In this last case, this represents command 0x80 sent to the FDC CONTROL register which triggers the 'Read Sector' command */
                move.w  D1,(A1)                                                 /* Write mode $80 to the DMA mode/status register. Subsequent read/write from/to -2(A1) = 0xFFFF8604 will be directed to the FDC STATUS/CONTROL register */
                bsr.s   T465_002_SendD1ToFDCRegister
                move    D0,SR                                                   /* Restore SR from D0. SR is the Status Register of the processor */
        T465_001:
                trap    #1                                                      /* Call GEMDOS function Super() again to go back to user mode */
                addq.l  #6,A7                                                   /* Cleanup stack */
                movea.l D3,A2                                                   /* Restore A2 from D3 */
                rts
        T465_002_SendD1ToFDCRegister:
                bsr.s   T465_003_Delay
                move.w  D1,-2(A1)                                               /* Write D1 to the currently selected FDC register */
        T465_003_Delay:
                moveq   #46,D2                                                  /* This loop is used to cause a delay during disk accesses */
        T465_004_Loop:
                subq.w  #1,D2
                bne.s   T465_004_Loop
                rts
}
#endif