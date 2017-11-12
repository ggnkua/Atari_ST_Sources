/* This routine checks the 489 bytes of sector 7 that contain a fuzzy bit. If there is not at least one fuzzy bit detected (a bit with a value different than the value it had in a previous sector reading) or if any of the normal bits does not have the expected value then the routine detects a copy instead of an original disk.
Before this routine is called, two parameters are pushed to the stack by R138_lzzz_COPYPROTECTIONEF_HiddenCodeLauncher. The return address is also pushed to the stack by the jsr instruction used to call this routine (there is an rts at the end of this routine). The first parameter is the address of a buffer containing a sector 7 reading to analyze. The second parameter is the address of an array of 3 (DM) or 4 (CSB) addresses to store the results. This routine is called either with:
G643_puc_FloppyDiskReadBuffer_COPYPROTECTIONDF and G083_apc_Graphic21Result_COPYPROTECTIONF containing pointers to:
     G081_ai_FuzzyBits_COPYPROTECTIONF
     G070_B_Sector7Analyzed_COPYPROTECTIONF
     G078_B_FuzzyBitFound_COPYPROTECTIONF
     G073_i_StopFreeingMemory_COPYPROTECTIONF (CSB only, there are only 3 pointers used in DM)
G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE and G429_apc_Graphic21Result_COPYPROTECTIONE containing pointers to:
     G293_ai_FuzzyBits_COPYPROTECTIONE
     G031_i_Graphic562_Sector7Analyzed_COPYPROTECTIONE
     G418_l_LastEvent22Time_COPYPROTECTIONE
     G068_i_CheckLastEvent22Time_COPYPROTECTIONE (CSB only, there are only 3 pointers used in DM) */
asm {
                movem.l D6-D7/A3,-(A7)          /* Backup registers to the stack */
                movea.l 16(A7),A0               /* First parameter: Address of the 512 bytes buffer containing a sector 7 reading (G643_puc_FloppyDiskReadBuffer_COPYPROTECTIONDF or G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE) */
                lea     20(A0),A0               /* Address of the first byte in the sector that contains a fuzzy bit at offset 20 in buffer */
                movea.l 20(A7),A3               /* Second routine parameter: Address of array of 4 pointers (G083_apc_Graphic21Result_COPYPROTECTIONF or G429_apc_Graphic21Result_COPYPROTECTIONE) */
                movea.l (A3)+,A1                /* Address of (G081_ai_FuzzyBits_COPYPROTECTIONF or G293_ai_FuzzyBits_COPYPROTECTIONE): a 64 bytes buffer containing the fuzzy bits extracted from a previous sector 7 reading */
                move.w  #489,D6                 /* Counter for InspectionLoop. 489 = number of bytes in sector 7 that contain a fuzzy bit */
                moveq   #16,D7                  /* Data will be read and analysed in blocks of 16 bytes (16 fuzzy bits, one from each byte, will form a word in D2) */
                moveq   #0,D0                   /* D0 will store the number of D2 words (fuzzy bits) that are different between two readings of sector 7. If D0 stays at 0 (no difference), then the disk is identified as a copy */
        InspectionLoop:
                moveq   #0,D1                   /* Index of a bit in D2 in the InspectionLoop. Incremented until it reaches value 16 */
                moveq   #0,D2                   /* D2 stores the values of 16 fuzzy bits (bit 7 extracted from 16 bytes) and is then compared with a previous value from the specified buffer */
        AnalysisLoop:
                move.b  (A0)+,D3                /* Get next byte to inspect from read buffer in D3 then increment A0 */
                bpl.s   FuzzyBitClear           /* Branch if bit 7 of D3 is 0 (in each byte, Bit 7 is the fuzzy bit) */
                bset    D1,D2                   /* Set in D2 the bit whose index is in D1 */
                andi.b  #0x7F,D3                /* Clear bit 7 (the fuzzy bit) in D3 */
        FuzzyBitClear:
                cmpi.b  #0x68,D3
                beq.s   ValidByte               /* Branch if D3 = 0x68 (if the normal bits in the byte have the expected value 0x68) */
                moveq   #0,D0                   /* D0 = 0 means that the sector is not original */
                bra.s   ExitInspectionLoop
        ValidByte:
                addq.w  #1,D1
                subq.w  #1,D6
                beq.s   ExitAnalysisLoop        /* Branch if D6 = 0 (if all bytes in the sector that contain a fuzzy bit have been analyzed) */
                cmp.w   D7,D1
                bne.s   AnalysisLoop            /* Branch if D1 <> 16 (if 16 fuzzy bits have not yet been extracted into D2) */
        ExitAnalysisLoop:
                cmp.w   (A1),D2                 /* Compare word of 16 fuzzy bits previously read with the one just collected */
                beq.s   NoDifferenceFound       /* Branch if no difference was found between the two readings */
                addq.w  #1,D0                   /* Increment the count of differences between readings of sector 7 */
        NoDifferenceFound:
                move.w  D2,(A1)+                /* Overwrite the previously read word of fuzzy bits with the newly collected one. A total of (489/8) = 62 bytes are written in the 64 bytes buffer */
                tst.w   D6
                bne.s   InspectionLoop          /* Branch if D6 <> 0 (if there are still bytes to inspect) */
        ExitInspectionLoop:
                movea.l (A3)+,A0                /* Address of (G070_B_Sector7Analyzed_COPYPROTECTIONF or G031_i_Graphic562_Sector7Analyzed_COPYPROTECTIONE): a variable used as a boolean to indicate if sector was analyzed */
                move.w  #136,(A0)               /* Set value to C00136_TRUE. This indicates that the fuzzy bits sector analysis has been completed */
                tst.w   D0
                bne.s   DiskIsOriginal          /* Branch if D0 <> 0 (if differences have been found between two sector readings which means the disk is original) */
                movea.l (A3),A0                 /* Address of (G078_B_FuzzyBitFound_COPYPROTECTIONF or G418_l_LastEvent22Time_COPYPROTECTIONE) */
                clr.l   (A0)                    /* If no differences were found with the previous reading, the value is set to 0 otherwise it is not modified */
                                                /* BUG0_01 Coding error without consequence. If graphic #21 is called with G643_puc_FloppyDiskReadBuffer_COPYPROTECTIONDF as second parameter and it does not detect any fuzzy bit then it writes 0 as a long (4 bytes) to G078_B_FuzzyBitFound_COPYPROTECTIONF but this variable is an int (2 bytes) which causes G077_B_DoNotDrawFluxcagesDuringEndgame (not related to the copy protection) to be overwritten too as a side effect as it is the next variable in memory. No consequence because the value of this variable is always 0 until the very end of the game */
        DiskIsOriginal:
                movea.l 4(A3),A3                /* CSB only. Address of (G073_i_StopFreeingMemory_COPYPROTECTIONF or G068_i_CheckLastEvent22Time_COPYPROTECTIONE) */
                move.w  #512,(A3)               /* CSB only. The value is set to C00512_FALSE */
                movem.l (A7)+,D6-D7/A3          /* Restore registers from the stack */
                rts                             /* Return from subroutine */
                dc.l    0x00000000              /* Unused padding */
}