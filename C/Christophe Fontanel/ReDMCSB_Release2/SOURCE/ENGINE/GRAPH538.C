/* This routine programs the FDC (Floppy Disk Controller) to read sector 7. It is very similar to S465_qzzz_COPYPROTECTIOND_ReadSector247
Before this routine is called, two parameters are pushed to the stack by R138_lzzz_COPYPROTECTIONEF_HiddenCodeLauncher. The return address is also pushed to the stack by the jsr instruction used to call this routine (there is an rts at the end of this routine). The first parameter is the address of a buffer to store the sector 7 reading: G643_puc_FloppyDiskReadBuffer_COPYPROTECTIONDF. The second parameter is the address of G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF (also used to access G624_B_FloppyDriveTurnedOn_COPYPROTECTIONDF that follows in memory) */
asm {
                move.l  A2,D3                   /* Backup A2 in D3 */
                clr.l   -(A7)                   /* Super() parameter value 0 to switch between user and supervisor modes */
                move.w  #0x0020,-(A7)           /* 0x20 is GEMDOS function Super() to switch to supervisor mode */
                trap    #1                      /* Call GEMDOS */
                move.l  D0,2(A7)                /* Save result in the stack. This is the old address of the supervisor stack, it will be restored when Super() is called again at the end */
                tst.w   0x043E
                bne.s   Exit                    /* Branch if system variable 'flock' <> 0 (This variable must be non zero during all disk activity to prevent the OS from using DMA during vertical blank */
                move.w  #1,0x043E               /* Set 'flock' system variable to 1 (non zero value) */
                movea.l 14(A7),A0               /* Address of G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF */
                move.w  #259,(A0)+              /* G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF = 259. This the maximum number of Vertical Blank cycles to wait before the read operation will time out */
                move.w  #1,(A0)                 /* G624_B_FloppyDriveTurnedOn_COPYPROTECTIONDF = 1. This flag is checked in vertical blank to turn off the floppy drive when reading is complete */
                movea.w #0x8800,A0              /* A0 = 0xFFFF8800. This is the address of the Programmable Sound Generator (PSG, YM2149 sound chip) Read data/Register select */
                moveq   #0xF8,D2                /* Used as a bit mask 11111000 */
                move    SR,D0                   /* Backup Status Register in D0 */
                ori     #0x0700,SR              /* Sets bits 8, 9 and 10 in SR which form a 3 bits Interrupt Mask. This disables all interrupts */
                move.b  #0x0E,(A0)              /* Write 0x0E to the PSG register select. This selects I/O port A */
                and.b   (A0),D2                 /* Read data from chip and apply binary mask in D2 to remove bits 0 to 2 and keep bits 3 to 7 */
                ori.b   #0x05,D2                /* Sets bits 0 and 2 in D2, in order to turn on drive 0 and its light (but not the motor), and select side 0 */
                move.b  D2,2(A0)                /* Write D2 to the write address of the PSG */
                movea.w #0x8606,A0              /* A0 = 0xFFFF8606. This is the address of the DMA mode/status register */
                move.w  #0x0084,(A0)            /* Write 0x84 to the DMA mode/status register (FIFO). Subsequent writes to -2(A0) = 0xFFFF8604 will now be directed to the SECTOR register of the FDC */
                moveq   #7,D1                   /* Sector number containing the fuzzy bits */
                bsr.s   SendD1ToFDCRegister     /* Call subroutine to set the sector to read in the FDC (7) */
                move.b  0x000D(A7),0xFFFF860D   /* Address of the DMA base and counter (Low byte) (Buffer address where the sector will be read) */
                move.b  0x000C(A7),0xFFFF860B   /* Address of the DMA base and counter (Mid byte) (Buffer address where the sector will be read) */
                move.b  0x000B(A7),0xFFFF8609   /* Address of the DMA base and counter (High byte) (Buffer address where the sector will be read) */
                move.w  #0x0090,(A0)            /* Set read mode */
                move.w  #0x0190,(A0)            /* Set write mode */
                move.w  #0x0090,(A0)            /* Set read mode. This sequence of operations clears the DMA FIFO buffer and prepares for a read operation */
                move.w  D0,-2(A0)               /* Write sector count to read to the DMA. This triggers the DMA transfer operation */
                                                /* BUG0_01 Coding error without consequence. This should write immediate value #1 instead of D0 = SR whose value is undetermined. No consequence because the DMA transfer is started no matter what is the actual value. The FDC will always stop the 'Read Sector' operation after reading a single sector (sector 7) because of the invalid CRC (caused by the fuzzy bits) */
                move.w  #0x0080,D1
                move.w  D1,(A0)                 /* Write D1 = 0x80 to the DMA mode/status register (FIFO). Subsequent writes to -2(A0) = 0xFFFF8604 will now be directed to the COMMAND register of the FDC */
                bsr.s   SendD1ToFDCRegister     /* Call subroutine to define the command to execute (0x80: instruct the FDC to spin-up the disk and read a single sector). The command is immediately executed by the FDC */
                move    D0,SR                   /* Restore SR from D0 */
        Exit:
                trap    #1                      /* Call GEMDOS function 0x20 Super(). This switches back to user mode */
                addq.l  #6,A7                   /* Clean up stack */
                movea.l D3,A2                   /* Restore A2 from D3 */
                rts
        SendD1ToFDCRegister:
                bsr.s   Delay                   /* Branch to subroutine Delay */
                move.w  D1,-2(A0)               /* D1 is written to the FDC access/sector count */
        Delay:
                moveq   #46,D2                  /* Loop will iterate 46 times */
        Loop:
                subq.w  #1,D2
                bne.s   Loop                    /* Branch if D2 <> 0 */
                rts                             /* Return from subroutine */
                dc.l    0x00000000              /* Unused */
}
