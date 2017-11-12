/* This boot sector contains the required information about the floppy disk (identification and physical layout) and code to set a fully black color palette and then load and run either a hard coded number of sectors (unused) or a file from the root directory (SWOOSH.IMG) */
asm {
                bra.s   LoaderCode                      /* Unconditional branch to the loader code at offset 0x3A (0x38 bytes forward) */
                dc.b    "Loader"
                dc.b    0x00,0x00,0x00                  /* Volume serial number */
                dc.w    0x0002                          /* 512 bytes per sector (little endian word) */
                dc.b    2                               /* 2 sectors per cluster */
                dc.w    0x0100                          /* 1 reserved sector (Little endian word) */
                dc.b    2                               /* 2 File Allocation Tables (FAT) */
                dc.w    0x1000                          /* 16 entries in the root directory (Little endian word). Each entry is 32 bytes so 16 entries occupy exactly a sector (512 bytes) */
                dc.w    0x2403                          /* 804 sectors on media. This number of sectors is incorrect and should be 800 (80 tracks of 10 sectors) */
                dc.b    0xF8                            /* Media descriptor */
                dc.w    0x0200                          /* 2 of sectors per FAT (Little endian word) */
                dc.w    0x0A00                          /* 10 sectors per track (Little endian word) */
                dc.w    0x0100                          /* 1 side on media (Little endian word) */
                dc.w    0x0000                          /* 0 hidden sectors (Little endian word) */
        _cmdload:
                dc.w    0x0000                          /* Word value that is copied to the system variable named '_cmdload' (Big endian word) */
        LoadMode:
                dc.w    0x0000                          /* Load mode (Big endian word). 0 instructs the loader to load a file by its name and using the filesystem. Other values instruct the loader to load a sequence of sectors without refering to the filesystem */
        FirstSector:
                dc.w    0x0000                          /* First sector to read (Big endian word). Only used when Load mode is not 0 */
        SectorCount:
                dc.w    0x0000                          /* Number of sectors to read (Big endian word). Only used when Load mode is not 0 */
        LoadAddress:
                dc.w    0x0004, 0x0000                  /* Load address (Big endian long). Memory address where the file or sectors will be loaded */
        FATAddress:
                dc.w    0x0000, 0x0000                  /* FAT address (Big endian long). Memory address where the FAT and root directory data will be loaded. The value 0x00000000 will automatically select an appropriate address */
        FileName:
                dc.b    "SWOOSH  IMG"                   /* File name and extension (8.3 name without the '.'). Only used when Load mode is 0 */
                dc.b    0x00                            /* Reserved */

        /* Change color #0 from 0x0777 (White) to 0x0000 (Black) over 8 vertical blank cycles */
        LoaderCode:
                moveq   #7,D0                           /* Vertical Blank counter */
                move.w  #0x0777,D1                      /* RGB components for color White */
        ScreenFadeToBlack:
                movem.l D0-D1,-(A7)                     /* Backup registers to the stack */
                move.w  #0x0025,-(A7)                   /* Function number for Vsync(). Pause program execution until the next vertical blank interrupt */
                trap    #14                             /* Call XBIOS */
                addq.l  #2,A7                           /* Clean up stack after call */
                movem.l (A7)+,D0-D1                     /* Restore registers from the stack */
                movea.l #0xFFFF8240,A0                  /* Address of palette register #0 */
                move.w  D1,(A0)                         /* Set color #0 to the value in D1 */
                subi.w  #0x0111,D1                      /* Substract 0x111 from D1 to get a darker gray color */
                dbf     D0,ScreenFadeToBlack            /* Decrement D0 and branch if it was not 0 */

        /* Set all colors to 0x0000 (Black) */
                movea.l #0xFFFF8240,A0                  /* Address of palette register #0 */
                moveq   #15,D0                          /* Color counter */
        AllBlackPalette:
                clr.w   (A0)+                           /* Set color to 0x0000 (Black) and proceed to the next palette register */
                dbf     D0,AllBlackPalette              /* Decrement D0 and branch if it was not 0 */

        /* Set system variable _cmdload */
                move.w  _cmdload(PC),0x00000482.L       /* Set system variable _cmdload = 0. When nonzero an attempt is made to load and execute COMMAND.PRG from the boot device. (Load a shell or an application in place of the desktop) */

        /* Get BIOS Parameter Block for the boot floppy disk */
                move.w  0x00000446.L,-(A7)              /* Put the value of the system variable _bootdev in the stack. This variable contains the device number the system was booted from */
                move.w  #0x0007,-(A7)                   /* Function number for Getbpb(). Returns the address of the current BPB (Bios Parameter Block) for a mounted device  */
                trap    #13                             /* Call BIOS */
                addq.w  #4,A7                           /* Clean up stack after call */
                tst.l   D0
                beq.w   InfiniteLoop                    /* Branch if D0 = 0 (if Getbpb() failed) */
                movea.l D0,A5                           /* Store the BPB address in A5 */

        /* Determine address where the FAT will be read */
                lea     FATAddress(PC),A0               /* Store the address of FATAddress in A0. FATAddress is the location where the FAT (File Allocation Table) and directory sectors will be stored in memory */
                tst.l   (A0)
                bne.s   ReadFAT                         /* Branch if FATAddress <> 0 */
                move.l  0x00000432.L,(A0)               /* If no value is specified for FATAddress then use the value of the system variable _membot which contains the bottom address of available memory */

        ReadFAT:
                move.w  8(A5),D0                        /* D0 = number of sectors per FAT (from BPB) */
                lsl.w   #8,D0
                add.l   D0,D0                           /* D0 = D0 * 512 */
                movea.w D0,A4                           /* A4 = size of the FAT in bytes */
                adda.l  FATAddress(PC),A4               /* A4 will point to the beginning of the root directory sector once read in memory */

        /* Load sectors or file */
                move.w  LoadMode(PC),D0                 /* Mode = 0: Load file. Mode <> 0: Load sectors */
                beq.s   LoadFile                        /* Branch if LoadMode = 0 */
                move.w  FirstSector(PC),D6              /* D6 = First sector to read */
                move.w  SectorCount(PC),D4              /* D4 = Number of sectors to read */
                movea.l LoadAddress(PC),A3              /* A3 = Address of buffer to store sectors */
                bra.w   LoadSectors                     /* Inconditional branch */
        LoadFile:
                move.w  10(A5),D6                       /* D6 = First sector to read = First sector of the second FAT (from BPB) */
                move.w  8(A5),D4                        /* D4 = Number of sectors to read = Number of sectors per FAT on the volume (from BPB) */
                add.w   6(A5),D4                        /* Add the number of sectors of the root directory (from BPB) */
                movea.l FATAddress(PC),A3               /* A3 = FATAddress. This is the location where the read sectors will be stored in memory */
                bsr     ReadSectors                     /* Read the sectors for the FAT and root directory */
                bne.w   InfiniteLoop                    /* Branch if an error occured during the read operation */

        /* Find file entry to load in root directory */
                movea.l A4,A0                           /* Address of the root directory */
                move.w  6(A5),D0                        /* Number of sectors of the root directory (from BPB) */
                lsl.w   #8,D0
                lsl.w   #1,D0                           /* D0 = D0 * 512 */
                lea     0(A0,D0.w),A0                   /* Address of the first byte following the root directory sector */
                lea     FileName(PC),A1                 /* Address of the file name being searched for in the root directory */
        SearchFileInDir:
                suba.w  #32,A0                          /* Move to previous file entry in the root directory (32 bytes per entry) */
                cmpa.l  A4,A0                           /* Compare A4 and A0 to check if we have reached the first file entry of the root directory */
                blt.w   InfiniteLoop                    /* Branch if A0 < A4 (if all files in the root directory have been tested) */
                moveq   #10,D0                          /* Counter to check the 8+3 = 11 characters of a file name */
        CompareFileNames:
                move.b  0(A0,D0.w),D1                   /* Character at index D0 in file entry at A0 */
                cmp.b   0(A1,D0.w),D1                   /* Compare character from file entry with character from the file name we are looking for (SWOOSH.IMG) */
                bne.s   SearchFileInDir                 /* Branch if characters are different (proceed to next file entry) */
                dbf     D0,CompareFileNames             /* Decrement D0 and branch if it was not 0 */
                moveq   #0,D7

        /* Parse FAT to load all the sectors corresponding to the clusters of the file to read */
                move.b  0x001B(A0),D7                   /* Most significant byte of the first cluster index */
                lsl.w   #8,D7                           /* Shift to make room for the other byte */
                move.b  0x001A(A0),D7                   /* Less significant byte of the first cluster index */
                movea.l FATAddress(PC),A6               /* A6 = FATAddress */
                movea.l LoadAddress(PC),A3              /* A3 = LoadAddress */
                clr.l   D4
        ProcessCluster:
                cmpi.w  #0x0FF0,D7
                bge.s   LoadSectors                     /* Branch if D7 >= 0xFF0 (last cluster of the file) */
                move.w  D7,D3
                subq.w  #2,D3
                mulu.w  2(A5),D3                        /* Multiply cluster index by the number of sectors per cluster (from BPB) */
                add.w   12(A5),D3                       /* Add the index of the first sector of data (from BPB) */
                cmpi.w  #0x0040,D4
                bge.s   LoadConsecutiveSectors          /* Branch if D4 >= 64 (do not read more than 64 consecutive sectors at once) */
                tst.w   D4
                beq.s   FirstConsecutiveSectors         /* Branch if D4 = 0 */
                cmp.w   D5,D3
                beq.s   NextConsecutiveSectors          /* Branch if D5 = D3 (if sector follows previous sector then increment the number of sectors to read in one operation) */
        LoadConsecutiveSectors:
                bsr.s   ReadSectors                     /* Read the sectors */
                bne.s   InfiniteLoop                    /* Branch if an error occured */
                lsl.l   #8,D4
                lsl.l   #1,D4                           /* D4 = D4 * 512 */
                adda.l  D4,A3                           /* Address where sectors are loaded */
        FirstConsecutiveSectors:
                move.w  D3,D6                           /* Index of first sector to load */
                move.w  D3,D5                           /* Index of last sector to load */
                clr.l   D4
        NextConsecutiveSectors:
                add.w   2(A5),D4                        /* One more cluster to read. Increment the number of sectors to read by the number of sectors per cluster (from BPB) */
                add.w   2(A5),D5                        /* Sectors per cluster (from BPB) */
        /* Get next cluster index */
                move.w  D7,D2
                lsr.w   #1,D2                           /* D2 = D2 / 2 */
                add.w   D7,D2                           /* FAT entry index */
                move.b  1(A6,D2.w),D1                   /* Most significant byte of the next cluster index */
                lsl.w   #8,D1                           /* Shift to make room for the other byte */
                move.b  0(A6,D2.w),D1                   /* Least significant byte of the next cluster index */
                btst    #0,D7
                beq.s   SetNextClusterIndex             /* Branch if bit 0 of D7 is clear (if cluster index is even) */
                lsr.w   #4,D1                           /* Shift to get the most significant nibble (each FAT entry is 12 bits large, occupying a byte and a half) */
        SetNextClusterIndex:
                andi.w  #0x0FFF,D1
                move.w  D1,D7                           /* D7 = Next cluster index */
                bra.s   ProcessCluster                  /* Inconditional branch */

        LoadSectors:
                tst.w   D4
                beq.s   LoadCompleted                   /* Branch if D4 = 0 (no more sectors to read) */
                bsr.s   ReadSectors                     /* Read the sectors */
                bne.s   InfiniteLoop                    /* Branch if D0 <> 0 (if an error occured) */
        LoadCompleted:
                move.l  LoadAddress(PC),-(A7)           /* Push LoadAddress to the stack */
                rts                                     /* Return. This will run the code loaded in memory at LoadAddress */
        InfiniteLoop:
                bra.s   InfiniteLoop
        ReadSectors:
                move.w  0x00000446.L,-(A7)              /* Select device (0 = A: 1 = B: etc.) using the _bootdev system variable (device number the system was booted from) */
                move.w  D6,-(A7)                        /* First sector to transfer */
                move.w  D4,-(A7)                        /* Number of sectors to transfer */
                move.l  A3,-(A7)                        /* Address of buffer to store sectors */
                clr.w   -(A7)                           /* Mode 0 (read) */
                move.w  #0x0004,-(A7)                   /* Function number for rwabs(). Read or write logical sectors on a device */
                trap    #13                             /* Call BIOS */
                adda.w  #0x000E,A7                      /* Clean up stack after call */
                tst.w   D0                              /* Check for error */
                rts                                     /* Return */
        /* Padding with 98 unused bytes of value 0x00 until the end of the sector */
                dc.b   0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
                dc.b   0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
                dc.b   0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
                dc.b   0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
                dc.b   0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
                dc.b   0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
                dc.b   0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        /* The last word is computed so that the 16 bit checksum of the whole boot sector is 0x1234. This is required for the sector to be identified as executable by the operating system */
                dc.w    0x247D
}
