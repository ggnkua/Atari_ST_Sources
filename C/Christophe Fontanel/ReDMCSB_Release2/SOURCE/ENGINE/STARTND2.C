#include "DEFS.H"

/*_Global variables_*/
unsigned char* G562_apuc_Bitmap_EntranceDoorAnimationSteps[10];
unsigned char* G563_puc_Graphic4_InterfaceEntranceScreen;
unsigned char* G564_puc_Graphic5_InterfaceCredits;
unsigned char* G565_puc_Graphic535_Sound02DoorRattle;
unsigned char* G566_puc_Graphic534_Sound01Switch;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives */
BOOLEAN G567_B_SingleFloppyDrive;
int G568_i_DiskType;
char* G569_pc_SavedGameFileName;
char* G570_pc_SavedGameBackupFileName;
char* G571_pc_D116_DRIVEA;
char* G572_pc_D117_DRIVEB;
int G573_i_GameDiskFloppyDriveIndex;
int G574_i_SaveDiskFloppyDriveIndex;
char G575_ac_SavedGameFileName[15] = "A:\\CSBGAME.DAT";
char G576_ac_SavedGameBackupFileName[15] = "A:\\CSBGAME.BAK";
#endif


overlay "start"

#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_03_IMPROVEMENT CHANGE7_31_IMPROVEMENT */
BOOLEAN F432_xxxx_STARTEND_FormatDiskMenu()
{
        register int L1328_i_Choice;
        register int L1329_i_DiskType;
        register BOOLEAN L1330_B_ReadyToFormat;
        register int L1331_i_Track;
        register char* L1332_pc_Message;
        register unsigned char* L1333_puc_Buffer;
        long L1336_l_ByteCount;


        L1330_B_ReadyToFormat = FALSE;
        L1332_pc_Message = NULL;
        do {
                F427_xxxx_DIALOG_Draw(L1332_pc_Message, G550_pc_D098_PUTABLANKDISKIN, G559_pc_D107_FORMATFLOPPY, G561_pc_D109_CANCEL, NULL, NULL, FALSE, FALSE, FALSE);
                F078_xzzz_MOUSE_ShowPointer();
                L1328_i_Choice = F424_xxxx_DIALOG_GetChoice(C2_TWO_CHOICES, C0_DIALOG_SET_VIEWPORT);
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                if (L1328_i_Choice == 2) { /* Choice 'CANCEL' */
                        return FALSE;
                }
                if ((L1329_i_DiskType = F452_xxxx_FLOPPY_GetDiskTypeInDrive_COPYPROTECTIONB()) == C0_DISK_TYPE_GAME_DISK) {
                        L1332_pc_Message = G537_pc_D085_CANTMODIFYGAMEDISK;
                } else {
                        if (L1329_i_DiskType == C2_DISK_TYPE_SAVE_DISK_WRITE_PROTECTED) {
                                L1332_pc_Message = G544_pc_D092_THATDISKISWRITEPROTECTED;
                        } else {
                                L1330_B_ReadyToFormat = TRUE;
                        }
                }
        } while (!L1330_B_ReadyToFormat);
        L1336_l_ByteCount = G648_l_AvailableHeapMemoryByteCount;
        L1333_puc_Buffer = F468_ozzz_MEMORY_Allocate(L1336_l_ByteCount, C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        for(L1331_i_Track = 0; L1331_i_Track < 80; L1331_i_Track++) {
                Flopfmt(L1333_puc_Buffer, C0L_FILLER, C0_FLOPPY_DRIVE_A, C9_SECTORS_PER_TRACK, L1331_i_Track, C0_SIDE_0, C1_INTERLEAVE, C0x87654321_MAGIC, (L1331_i_Track <= 1) ? 0 : 0xE5E5);
        }
        Protobt(L1333_puc_Buffer, C0x01000001_SERIAL_RANDOM, C2_80_TRACKS_SINGLE_SIDED, C0_DISK_NOT_EXECUTABLE);
        Flopwr(L1333_puc_Buffer, C0L_FILLER, C0_FLOPPY_DRIVE_A, C001_SECTOR_1, C0_TRACK_0, C0_SIDE_0, C1_ONE_SECTOR);
        F469_rzzz_MEMORY_FreeAtHeapTop(L1336_l_ByteCount);
        return TRUE;
}
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives CHANGE7_31_IMPROVEMENT Refactored floppy disk format function with these new features: New dialog message if there is no floppy disk in the drive. New dialog message while formatting and if formatting failed, asks for confirmation if trying to format an existing save disk. Code to format floppy disk moved to a separate function CHANGE7_34_OPTIMIZATION */
VOID F432_xxxx_STARTEND_FormatDiskMenu()
{
        int L1328_i_Choice;
        BOOLEAN L1330_B_ReadyToFormat;
        register char* L1332_pc_Message;
        char L1334_ac_PutBlankDiskIn[50];
        char L1335_ac_ThereIsNoDiskIn[50];


        L1330_B_ReadyToFormat = FALSE;
        F414_xxxx_SAVEUTIL_ReplaceTildeByDriveLetterInString(L1334_ac_PutBlankDiskIn, G550_pc_D098_PUTABLANKDISKIN, C2_DRIVE_TYPE_SAVE_DISK);
        F414_xxxx_SAVEUTIL_ReplaceTildeByDriveLetterInString(L1335_ac_ThereIsNoDiskIn, G555_pc_D103_THEREISNODISKIN, C2_DRIVE_TYPE_SAVE_DISK);
        L1332_pc_Message = NULL;
        do {
                if (L1332_pc_Message == NULL); /* BUG0_00 Useless code */
                F427_xxxx_DIALOG_Draw(L1332_pc_Message, L1334_ac_PutBlankDiskIn, G559_pc_D107_FORMATFLOPPY, G561_pc_D109_CANCEL, NULL, NULL, FALSE, FALSE, FALSE);
                L1328_i_Choice = F424_xxxx_DIALOG_GetChoice(C2_TWO_CHOICES, C0_DIALOG_SET_VIEWPORT, C2_USELESS, C1_USELESS);
                if (L1328_i_Choice == 2) { /* Choice 'CANCEL' */
                        return;
                }
                if (F454_xxxx_FLOPPY_IsSaveDiskTypeInSaveDiskDrive(C2_SAVE_DISK_UNFORMATTED_DISK) == TRUE) {
                        L1330_B_ReadyToFormat = TRUE;
                        continue;
                }
                L1330_B_ReadyToFormat = FALSE;
                switch (G568_i_DiskType) {
                        case C0_DISK_TYPE_GAME_DISK:
                                L1332_pc_Message = G537_pc_D085_CANTMODIFYGAMEDISK;
                                continue;
                        case C2_DISK_TYPE_SAVE_DISK_WRITE_PROTECTED:
                                L1332_pc_Message = G544_pc_D092_THATDISKISWRITEPROTECTED;
                                continue;
                        case C4_DISK_TYPE_NO_DISK:
                                L1332_pc_Message = &L1335_ac_ThereIsNoDiskIn;
                                continue;
                        case C1_DISK_TYPE_SAVE_DISK_WRITE_ENABLED:
                                F427_xxxx_DIALOG_Draw(G543_pc_D091_THATSAGAMESAVEDISK, G554_pc_D102_FORMATDISKANYWAY, G560_pc_D108_OK, G561_pc_D109_CANCEL, NULL, NULL, FALSE, FALSE, FALSE);
                                L1328_i_Choice = F424_xxxx_DIALOG_GetChoice(C2_TWO_CHOICES, C0_DIALOG_SET_VIEWPORT, C0_USELESS, C0_USELESS);
                                if (L1328_i_Choice == 1) { /* Choice 'OK' */
                                        switch (F452_xxxx_FLOPPY_GetDiskTypeInDrive_COPYPROTECTIONB(C2_DRIVE_TYPE_SAVE_DISK)) {
                                                case C0_DISK_TYPE_GAME_DISK:
                                                        L1332_pc_Message = G537_pc_D085_CANTMODIFYGAMEDISK;
                                                        break;
                                                case C2_DISK_TYPE_SAVE_DISK_WRITE_PROTECTED:
                                                        L1332_pc_Message = G544_pc_D092_THATDISKISWRITEPROTECTED;
                                                        break;
                                                case C4_DISK_TYPE_NO_DISK:
                                                        L1332_pc_Message = &L1335_ac_ThereIsNoDiskIn;
                                                        break;
                                                case C1_DISK_TYPE_SAVE_DISK_WRITE_ENABLED:
                                                case C3_DISK_TYPE_UNFORMATTED_DISK:
                                                        L1330_B_ReadyToFormat = TRUE;
                                        }
                                        continue;
                                }
                                L1332_pc_Message = NULL;
                }
        } while (!L1330_B_ReadyToFormat);
        F427_xxxx_DIALOG_Draw(NULL, G553_pc_D101_FORMATTINGDISK, NULL, NULL, NULL, NULL, FALSE, FALSE, FALSE);
        if (!F453_xxxx_FLOPPY_IsFormatDiskSuccessful()) {
                F427_xxxx_DIALOG_Draw(G541_pc_D089_UNABLETOFORMATDISK, NULL, G560_pc_D108_OK, NULL, NULL, NULL, FALSE, FALSE, FALSE);
                F424_xxxx_DIALOG_GetChoice(C1_ONE_CHOICE, C0_DIALOG_SET_VIEWPORT, C0_USELESS, C0_USELESS);
        }
}
#endif

VOID F433_AA39_STARTEND_ProcessCommand140_SaveGame_COPYPROTECTIONCDF()
{
        register int L1337_i_Multiple;
#define A1337_B_DiskTypeIsSaveDiskWriteEnabled L1337_i_Multiple
#define A1337_i_DifferingWordCount             L1337_i_Multiple
        register BOOLEAN L1338_B_SaveAndPlayChoice;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_09_OPTIMIZATION Variables reordered */
        register int L1340_i_Multiple;
#endif
        register int L1339_i_Multiple;
#define A1339_i_ForceDialog   L1339_i_Multiple
#define A1339_i_Choice        L1339_i_Multiple
#define A1339_i_SavePartIndex L1339_i_Multiple
#define A1339_i_ThingType     L1339_i_Multiple
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_09_OPTIMIZATION Variables reordered */
        register int L1340_i_Multiple;
#endif
#define A1340_i_DiskType    L1340_i_Multiple
#define A1340_i_MaxBitCount L1340_i_Multiple
        register char* L1341_pc_Multiple;
#define A1341_pc_Message         L1341_pc_Multiple
#define A1341_pc_DungeonChecksum L1341_pc_Multiple
        register SAVE_HEADER* L1342_ps_SaveHeader;
        int L1343_i_Checksum;
#ifdef C12_COMPILE_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE1_02_FIX */
        int L1344_ui_Weight;
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_15_IMPROVEMENT */
        int L1345_i_DungeonChecksum;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives */
        char L1346_ac_PutTheGameSaveDiskIn[50];
        char L1347_ac_ThereIsNoDiskIn[50];
#endif
        GLOBAL_DATA L1348_s_GlobalData;
        SAVE_PART L1349_as_SaveParts[16];
#ifndef NOCOPYPROTECTION
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_09_OPTIMIZATION Variables reordered */
        unsigned char* L1351_puc_Sector7Buffer; /* 512 bytes */
#endif
        unsigned char* L1350_puc_FuzzyBitsBuffer; /* 64 bytes */
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_09_OPTIMIZATION Variables reordered */
        unsigned char* L1351_puc_Sector7Buffer; /* 512 bytes */
#endif
#endif


        A1337_i_DifferingWordCount = 0;
        F456_vzzz_START_DrawDisabledMenus();
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_33_IMPROVEMENT */
#ifndef NOCOPYPROTECTION
        A1339_i_ForceDialog = C0_DO_NOT_FORCE_DIALOG_DM_CSB;
        while (G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF);
        do {
                F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(A1339_i_ForceDialog, FALSE);
                A1339_i_ForceDialog = C1_FORCE_DIALOG_DM;
                L1351_puc_Sector7Buffer = F468_ozzz_MEMORY_Allocate((long)(512 + 64), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
                L1350_puc_FuzzyBitsBuffer = L1351_puc_Sector7Buffer + 512;
                asm {
                                move.l  A2,-(A7)
                                jsr     T433_003_CallXBIOSToReadSector7(PC)
                                jsr     T433_004_CheckFuzzyBitValues(PC)
                                jsr     T433_003_CallXBIOSToReadSector7(PC)
                                jsr     T433_004_CheckFuzzyBitValues(PC)
                                bra     T433_021
                        T433_003_CallXBIOSToReadSector7:
                                move.w  #1,-(A7)                                /* C1_ONE_SECTOR */
                                clr.w   -(A7)                                   /* C0_SIDE_0 */
                                move.l  #0x00070000,-(A7)                       /* C007_SECTOR_7, C0_TRACK_0 */
                                clr.w   -(A7)                                   /* C0_FLOPPY_DRIVE_A */
                                clr.l   -(A7)                                   /* C0L_FILLER */
                                move.l  L1351_puc_Sector7Buffer(A6),-(A7)
                                move.w  #0x0008,-(A7)                           /* Floprd */
                                trap    #14                                     /* Call XBIOS */
                                lea     20(A7),A7                               /* Clean up stack */
                                rts
                        T433_004_CheckFuzzyBitValues: /* Algorithm identical to the one in graphic #21 */
                                movea.l L1351_puc_Sector7Buffer(A6),A0
                                lea     20(A0),A0
                                movea.l L1350_puc_FuzzyBitsBuffer(A6),A1
                                move.w  #489,D0
                                moveq   #16,A1340_i_MaxBitCount
                                moveq   #0,A1337_i_DifferingWordCount
                        T433_005:
                                moveq   #0,D1
                                moveq   #0,D2
                        T433_006_Loop:
                                move.b  (A0)+,D3
                                bpl.s   T433_007
                                bset    D1,D2
                                andi.b  #0x7F,D3
                        T433_007:
                                cmpi.b  #0x68,D3
                                beq.s   T433_008
                                moveq   #0,A1337_i_DifferingWordCount
                                rts
                        T433_008:
                                addq.w  #1,D1
                                subq.w  #1,D0
                                beq.s   T433_009
                                cmp.w   A1340_i_MaxBitCount,D1
                                bne.s   T433_006_Loop
                        T433_009:
                                cmp.w   (A1),D2
                                beq.s   T433_010
                                addq.w  #1,A1337_i_DifferingWordCount
                        T433_010:
                                move.w  D2,(A1)+
                                tst.w   D0
                                bne.s   T433_005
                                rts
                        T433_021:
                                movea.l (A7)+,A2
                }
                F469_rzzz_MEMORY_FreeAtHeapTop((long)(512 + 64));
        } while (!A1337_i_DifferingWordCount);
#endif
        A1337_B_DiskTypeIsSaveDiskWriteEnabled = FALSE;
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        A1341_pc_Message = NULL;
        L1342_ps_SaveHeader = (SAVE_HEADER*)F468_ozzz_MEMORY_Allocate((long)sizeof(SAVE_HEADER), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        do {
                F427_xxxx_DIALOG_Draw(A1341_pc_Message, G548_pc_D096_PUTTHEGAMESAVEDISKIN, G557_pc_D105_SAVEANDPLAY, G558_pc_D106_SAVEANDQUIT, G559_pc_D107_FORMATFLOPPY, G561_pc_D109_CANCEL, FALSE, FALSE, FALSE);
                F078_xzzz_MOUSE_ShowPointer();
                A1339_i_Choice = F424_xxxx_DIALOG_GetChoice(C4_FOUR_CHOICES, C0_DIALOG_SET_VIEWPORT);
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                if (A1339_i_Choice == 3) { /* Choice 'FORMAT FLOPPY' */
                        if (!F432_xxxx_STARTEND_FormatDiskMenu()) {
                                goto T433_060;
                        }
                        continue;
                }
                if (A1339_i_Choice == 4) { /* Choice 'CANCEL' */
                        goto T433_060;
                }
                L1338_B_SaveAndPlayChoice = (A1339_i_Choice == 1);
                if ((A1340_i_DiskType = F452_xxxx_FLOPPY_GetDiskTypeInDrive_COPYPROTECTIONB()) == C0_DISK_TYPE_GAME_DISK) {
                        A1341_pc_Message = G537_pc_D085_CANTMODIFYGAMEDISK;
                        continue;
                }
                if (A1340_i_DiskType == C2_DISK_TYPE_SAVE_DISK_WRITE_PROTECTED) {
                        A1341_pc_Message = G544_pc_D092_THATDISKISWRITEPROTECTED;
                        continue;
                }
                if (A1340_i_DiskType == C3_DISK_TYPE_UNFORMATTED_DISK) {
                        A1341_pc_Message = G545_pc_D093_THATDISKISUNREADABLE;
                        continue;
                }
                A1337_B_DiskTypeIsSaveDiskWriteEnabled = TRUE;
        } while (!A1337_B_DiskTypeIsSaveDiskWriteEnabled);
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_05_IMPROVEMENT A dialog box with the message "Saving game..." is displayed while saving the game */
        F427_xxxx_DIALOG_Draw(NULL, G551_pc_D099_SAVINGGAME, NULL, NULL, NULL, NULL, FALSE, FALSE, FALSE);
#endif
        Fdelete(G520_pc_D082_ADMGAMEBAK);
        Frename(C0_RESERVED, G519_pc_D081_ADMGAMEDAT, G520_pc_D082_ADMGAMEBAK);
        if ((G521_i_GameFileHandle = Fcreate(G519_pc_D081_ADMGAMEDAT, C0_FILE_ATTRIBUTES)) < 0) {
                goto T433_059;
        }
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives CHANGE7_33_IMPROVEMENT Refactored save game function with these new features: New dialog message if there is no floppy disk in the drive. If you choose 'FORMAT FLOPPY' and then choose 'CANCEL' then you come back to the save dialog instead of closing the save dialog and coming back to the inventory. The assembly code for the copy protection uses custom routines to read sector 7 instead of calling XBIOS function Floprd() CHANGE7_34_OPTIMIZATION */
#ifndef NOCOPYPROTECTION
        L1351_puc_Sector7Buffer = F468_ozzz_MEMORY_Allocate((long)(512 + 64), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        L1350_puc_FuzzyBitsBuffer = L1351_puc_Sector7Buffer + 512;
        A1339_i_ForceDialog = C0_DO_NOT_FORCE_DIALOG_DM_CSB;
        while (G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF);
        do {
                F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(A1339_i_ForceDialog, FALSE);
                A1339_i_ForceDialog = C2_FORCE_DIALOG_CSB;
                asm {
                                move.l  A2,-(A7)
                                move.w  #1,-(A7)                                        /* C1_ONE_SECTOR */
                                clr.l   -(A7)                                           /* C0_SIDE_0, C0_TRACK_0 */
                                move.w  #6,-(A7)                                        /* SECTOR_6 */
                                clr.w   -(A7)                                           /* C0_FLOPPY_DRIVE_A */
                                clr.l   -(A7)                                           /* C0L_FILLER */
                                move.l  L1351_puc_Sector7Buffer(A6),-(A7)
                                move.w  #0x0008,-(A7)                                   /* Floprd() */
                                trap    #14                                             /* Call XBIOS */
                                lea     20(A7),A7                                       /* Clean up stack */
                                clr.l   -(A7)
                                move.w  #0x0020,-(A7)                                   /* Super() */
                                trap    #1                                              /* Call GEMDOS */
                                move.l  D0,2(A7)                                        /* Store result in stack (overwrite parameter from call above). No stack cleanup as another identical call will be made later */
                                tst.w   C0x043E_ADDRESS_SYSTEM_VARIABLE_flock           /* Check if floppy disk is being accessed */
                                bne     T433_021                                        /* If the floppy disk is being accessed */
                                move.w  #1,C0x043E_ADDRESS_SYSTEM_VARIABLE_flock        /* Mark floppy disk as being accessed */
                                bsr.s   T433_011_ReadSector7
                                bsr     T433_018_WaitDMATransferCompletion
                                bsr.s   T433_004_CheckFuzzyBitValues
                                bsr.s   T433_011_ReadSector7
                                bsr     T433_018_WaitDMATransferCompletion
                                bsr.s   T433_004_CheckFuzzyBitValues
                                bra     T433_021
                        T433_004_CheckFuzzyBitValues:                                   /* Subroutine very similar to graphic #21. Check normal bits, store and compare fuzzy bits with previous reading */
                                movea.l L1351_puc_Sector7Buffer(A6),A0
                                lea     20(A0),A0
                                movea.l L1350_puc_FuzzyBitsBuffer(A6),A1
                                move.w  #489,D0                                         /* Number of bytes containing fuzzy bits in the sector */
                                moveq   #16,A1340_i_MaxBitCount
                                moveq   #0,A1337_i_DifferingWordCount
                        T433_005:
                                moveq   #0,D1
                                moveq   #0,D2
                        T433_006_Loop:
                                move.b  (A0)+,D3
                                bpl.s   T433_007
                                bset    D1,D2
                                andi.b  #0x7F,D3
                        T433_007:
                                cmpi.b  #0x68,D3                                        /* This is the value of bytes containing fuzzy bits */
                                beq.s   T433_008
                                moveq   #0,A1337_i_DifferingWordCount                   /* Return value. The sector is not original */
                                rts
                        T433_008:
                                addq.w  #1,D1
                                subq.w  #1,D0
                                beq.s   T433_009
                                cmp.w   A1340_i_MaxBitCount,D1
                                bne.s   T433_006_Loop
                        T433_009:
                                cmp.w   (A1),D2
                                beq.s   T433_010
                                addq.w  #1,A1337_i_DifferingWordCount                   /* There is one more word (made of fuzzy bits) that differs from previous reading */
                        T433_010:
                                move.w  D2,(A1)+
                                tst.w   D0
                                bne.s   T433_005
                                rts
                        T433_011_ReadSector7:                                           /* Subroutine very similar to graphic #538 */
                                movea.w #0x8800,A1                                      /* This is the address of the Programmable Sound Generator (PSG, YM2149 sound chip) Read data/Register select */
                                moveq   #0xF8,D2                                        /* This is used as bit mask 11111000 */
                                move    SR,D0                                           /* Backup Status Register in D0 */
                                ori     #0x0700,SR                                      /* Set interrupt priority mask = 7. All interrupts <= 7 will now be ignored. This includes Horizontal Blank interrupts (level 2), Vertical Blank interrupts (level 4) and MFP interrupts (level 6) */
                                move.b  #14,(A1)                                        /* Write 14 to the PSG register select. This selects I/O port A */
                                and.b   (A1),D2                                         /* Read data from PSG and apply mask in D2 */
                                ori.b   #0x05,D2                                        /* Enable bits 0 and 2 in D2 in order to turn on drive 0 and its light (but not the motor), and select side 0 */
                                move.b  D2,2(A1)                                        /* Write D2 to the write address of the PSG */
                                move    D0,SR                                           /* Restore Status Register from D0 */
                                move.w  G317_i_WaitForInputVerticalBlankCount(A4),D3
                                add.w   #259,D3                                         /* This represents the delay after which the DMA access will time out */
                                movea.w #0x8606,A1                                      /* Address of the DMA mode/status register */
                                move.w  #0x0080,(A1)                                    /* Write mode $80 to the DMA mode/status register. Subsequent read/write from/to -2(A1) = 0xFFFF8604 will be directed to the FDC STATUS/CONTROL register */
                                moveq   #7,D1                                           /* Write command 7 to the FDC CONTROL register. This command is Restore = Seek track 0. This will turn on the motor and move the drive head to track 0 */
                                bsr.s   T433_015_SendD1ToFDCRegister
                        T433_012_Loop:
                                move.w  #0x0080,(A1)                                    /* Write mode $80 to the DMA mode/status register. Subsequent read/write from/to -2(A1) = 0xFFFF8604 will be directed to the FDC STATUS/CONTROL register */
                                bsr.s   T433_016_Delay
                                moveq   #0x02,D1
                                and.w   -2(A1),D1                                       /* Read the STATUS register of the FDC and apply the mask in D1. This keeps only bit 1. This bit is set if the disk is at the index pulse */
                                bsr.s   T433_016_Delay
                                tst.w   D1
                                beq.s   T433_012_Loop                                   /* If bit 1 = 0 (Disk is not at index pulse) then continue waiting */
                                move.w  #0x0080,(A1)                                    /* Write mode $80 to the DMA mode/status register. Subsequent read/write from/to -2(A1) = 0xFFFF8604 will be directed to the FDC STATUS/CONTROL register */
                                moveq   #0,D1                                           /* Write command 0 to the FDC CONTROL register. This command is Restore = Seek track 0. This will turn on the motor and move the drive head to track 0 */
                                bsr.s   T433_015_SendD1ToFDCRegister
                                move.w  #0x0080,(A1)                                    /* Write mode $80 to the DMA mode/status register. Subsequent read/write from/to -2(A1) = 0xFFFF8604 will be directed to the FDC STATUS/CONTROL register */
                        T433_013_Delay:
                                moveq   #44,D0
                        T433_014:
                                subq.w  #1,D0
                                bne.s   T433_014
                                moveq   #1,D0
                                and.w   -2(A1),D0                                       /* Read the STATUS register of the FDC and apply the mask in D0. This keeps only bit 0. This bit is 1 if the FDC is busy executing a command otherwise it is 0 */
                                bne.s   T433_013_Delay                                  /* Branch if the FDC is busy */
                                move.w  #0x0084,(A1)                                    /* Write mode $84 to the DMA mode/status register. Subsequent read/write from/to -2(A1) = $FFFF8604 will be directed to the FDC SECTOR register */
                                moveq   #C007_SECTOR_7,D1                               /* This is the sector number containing the fuzzy bits */
                                bsr.s   T433_015_SendD1ToFDCRegister                    /* Call subroutine to set the sector to read in the FDC */
                                move.b  L1351_puc_Sector7Buffer+3(A6),0x860D            /* Address of the DMA base and counter (Low byte)  (Buffer address where the sector will be read) */
                                move.b  L1351_puc_Sector7Buffer+2(A6),0x860B            /* Address of the DMA base and counter (Mid byte)  (Buffer address where the sector will be read) */
                                move.b  L1351_puc_Sector7Buffer+1(A6),0x8609            /* Address of the DMA base and counter (High byte) (Buffer address where the sector will be read) */
                                move.w  #0x0090,(A1)                                    /* Write mode $90 to the DMA mode/status register. Set read mode (from DMA to memory) from the FDC. Subsequent write to -2(A1) = 0xFFFF8604 will be directed to the DMA internal sector count register */
                                move.w  #0x0190,(A1)                                    /* Write mode $190 to the DMA mode/status register. Set write mode (from memory to DMA) from the FDC. Subsequent write to -2(A1) = 0xFFFF8604 will be directed to the DMA internal sector count register */
                                move.w  #0x0090,(A1)                                    /* Write mode $90 to the DMA mode/status register. Set read mode (from DMA to memory) from the FDC. Subsequent write to -2(A1) = 0xFFFF8604 will be directed to the DMA internal sector count register. This sequence of operations (toggling the DMA mode) clears the DMA FIFO buffers and prepares for a read operation */
                                move.w  #1,-2(A1)                                       /* Write sector count = 1 to the DMA to read one sector. This triggers the DMA transfer operation */
                                move.w  #0x0080,D1                                      /* This value is written both to the DMA mode/status register on the next line and to the FDC CONTROL register 4 lines below. In this last case, this represents command 0x80 sent to the FDC CONTROL register which triggers the 'Read Sector' command */
                                move.w  D1,(A1)                                         /* Write mode $80 to the DMA mode/status register. Subsequent read/write from/to -2(A1) = 0xFFFF8604 will be directed to the FDC STATUS/CONTROL register */
                        T433_015_SendD1ToFDCRegister:                                   /* Includes delay before and after writing D1 to the FDC */
                                bsr.s   T433_016_Delay
                                move.w  D1,-2(A1)                                       /* Write D1 to the currently selected FDC register */
                        T433_016_Delay:
                                moveq   #46,D2
                        T433_017:
                                subq.w  #1,D2
                                bne.s   T433_017
                                rts
                        T433_018_WaitDMATransferCompletion:                             /* Subroutine similar to S080_aaat_COPYPROTECTIONDF_CheckDMATransferCompletion */
                                cmp.w   G317_i_WaitForInputVerticalBlankCount(A4),D3    /* This value is incremented during each Vertical Blank */
                                bmi.s   T433_020                                        /* If DMA transfer has timed out */
                                move.w  G317_i_WaitForInputVerticalBlankCount(A4),D2
                                btst    #5,0xFA01                                       /* Test bit 5 of the MFP GPIP (the chip managing DMA transfers) */
                                bne.s   T433_018_WaitDMATransferCompletion              /* If this bit is 1, a DMA transfer from the floppy disk controller is still ongoing. If this bit is 0, then the DMA transfer is complete */
                                move.w  #0x0090,(A1)                                    /* Write mode $90 to the DMA mode/status register. Set read mode (from DMA to memory) from the FDC. Subsequent write to -2(A1) = 0xFFFF8604 will be directed to the DMA internal sector count register */
                                moveq   #1,D0
                                and.w   (A1),D0                                         /* If bit 0 = 1 then there is at least 1 sector left to transfer else all sectors have been transferred */
                                beq.s   T433_020                                        /* Branch if bit 0 = 0 (all sectors were transferred) */
                                move.w  #0x0080,(A1)                                    /* Write mode $80 to the DMA mode/status register. Subsequent read/write from/to -2(A1) = 0xFFFF8604 will be directed to the FDC STATUS/CONTROL register */
                                moveq   #44,D0
                        T433_019_Delay:
                                subq.w  #1,D0
                                bne.s   T433_019_Delay                                  /* This loop introduces the necessary delay for programming the FDC */
                                moveq   #0x10,D0                                        /* This is a mask with only bit 4 set */
                                and.w   -2(A1),D0                                       /* Read the STATUS register of the FDC and apply the mask in D0. This keeps only bit 4 */
                                bne.s   T433_020                                        /* Branch if bit 4 = 0. The FDC sets this bit to indicate 'RECORD NOT FOUND (RNF)' (track, sector or side not found) */
                                rts
                        T433_020:
                                addq.l  #4,A7                                           /* Clean up the stack to remove the return address */
                        T433_021:
                                clr.w   C0x043E_ADDRESS_SYSTEM_VARIABLE_flock           /* Mark floppy disk as not being used anymore */
                                trap    #1                                              /* This calls function Super() again to go back to user mode */
                                addq.l  #6,A7                                           /* Clean up stack */
                                movea.l (A7)+,A2
                }
        } while (!A1337_i_DifferingWordCount);
        F469_rzzz_MEMORY_FreeAtHeapTop((long)(512 + 64));
#endif
        A1337_B_DiskTypeIsSaveDiskWriteEnabled = FALSE;
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        A1341_pc_Message = NULL;
        L1342_ps_SaveHeader = (SAVE_HEADER*)F468_ozzz_MEMORY_Allocate((long)sizeof(SAVE_HEADER), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        F414_xxxx_SAVEUTIL_ReplaceTildeByDriveLetterInString(L1346_ac_PutTheGameSaveDiskIn, G548_pc_D096_PUTTHEGAMESAVEDISKIN, C2_DRIVE_TYPE_SAVE_DISK);
        F414_xxxx_SAVEUTIL_ReplaceTildeByDriveLetterInString(L1347_ac_ThereIsNoDiskIn, G555_pc_D103_THEREISNODISKIN, C2_DRIVE_TYPE_SAVE_DISK);
        do {
                if (A1341_pc_Message == NULL); /* BUG0_00 Useless code */
                F427_xxxx_DIALOG_Draw(A1341_pc_Message, L1346_ac_PutTheGameSaveDiskIn, G557_pc_D105_SAVEANDPLAY, G558_pc_D106_SAVEANDQUIT, G559_pc_D107_FORMATFLOPPY, G561_pc_D109_CANCEL, FALSE, FALSE, FALSE);
                A1339_i_Choice = F424_xxxx_DIALOG_GetChoice(C4_FOUR_CHOICES, C0_DIALOG_SET_VIEWPORT, C0_USELESS, C0_USELESS);
                if (A1339_i_Choice == 3) { /* Choice 'FORMAT FLOPPY' */
                        F432_xxxx_STARTEND_FormatDiskMenu();
                        A1341_pc_Message = NULL;
                        continue;
                }
                if (A1339_i_Choice == 4) { /* Choice 'CANCEL' */
                        goto T433_060;
                }
                L1338_B_SaveAndPlayChoice = (A1339_i_Choice == 1);
                if (F454_xxxx_FLOPPY_IsSaveDiskTypeInSaveDiskDrive(C0_SAVE_DISK_WRITE_ENABLED_FOR_SAVING) == TRUE) {
                        A1337_B_DiskTypeIsSaveDiskWriteEnabled = TRUE;
                        continue;
                }
                A1337_B_DiskTypeIsSaveDiskWriteEnabled = FALSE;
                switch (G568_i_DiskType) {
                        case C0_DISK_TYPE_GAME_DISK:
                                A1341_pc_Message = G537_pc_D085_CANTMODIFYGAMEDISK;
                                break;
                        case C2_DISK_TYPE_SAVE_DISK_WRITE_PROTECTED:
                                A1341_pc_Message = G544_pc_D092_THATDISKISWRITEPROTECTED;
                                break;
                        case C4_DISK_TYPE_NO_DISK:
                                A1341_pc_Message = &L1347_ac_ThereIsNoDiskIn;
                                break;
                        case C3_DISK_TYPE_UNFORMATTED_DISK:
                                A1341_pc_Message = G545_pc_D093_THATDISKISUNREADABLE;
                }
        } while (A1337_B_DiskTypeIsSaveDiskWriteEnabled == FALSE);
        F427_xxxx_DIALOG_Draw(NULL, G551_pc_D099_SAVINGGAME, NULL, NULL, NULL, NULL, FALSE, FALSE, FALSE);
        Fdelete(G570_pc_SavedGameBackupFileName);
        Frename(C0_RESERVED, G569_pc_SavedGameFileName, G570_pc_SavedGameBackupFileName);
        if ((G521_i_GameFileHandle = Fcreate(G569_pc_SavedGameFileName, C0_FILE_ATTRIBUTES)) < 0) {
                goto T433_059;
        }
#endif
#ifdef C12_COMPILE_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE1_02_FIX Substract leader hand object weight before saving */
        if (!G415_B_LeaderEmptyHanded) {
                G407_s_Party.Champions[G411_i_LeaderIndex].Load -= (L1344_ui_Weight = F140_yzzz_DUNGEON_GetObjectWeight(G414_T_LeaderHandObject));
        }
#endif
        L1348_s_GlobalData.GameTime = G313_ul_GameTime;
        L1348_s_GlobalData.LastRandomNumber = G349_ul_LastRandomNumber;
        L1348_s_GlobalData.PartyChampionCount = G305_ui_PartyChampionCount;
        L1348_s_GlobalData.PartyMapX = G306_i_PartyMapX;
        L1348_s_GlobalData.PartyMapY = G307_i_PartyMapY;
        L1348_s_GlobalData.PartyDirection = G308_i_PartyDirection;
        L1348_s_GlobalData.PartyMapIndex = G309_i_PartyMapIndex;
        L1348_s_GlobalData.LeaderIndex = G411_i_LeaderIndex;
        L1348_s_GlobalData.MagicCasterChampionIndex = G514_i_MagicCasterChampionIndex;
        L1348_s_GlobalData.EventCount = G372_ui_EventCount;
        L1348_s_GlobalData.FirstUnusedEventIndex = G373_ui_FirstUnusedEventIndex;
        L1348_s_GlobalData.EventMaximumCount = G369_ui_EventMaximumCount;
        L1348_s_GlobalData.CurrentActiveGroupCount = G377_ui_CurrentActiveGroupCount;
        L1348_s_GlobalData.LastCreatureAttackTime = G361_l_LastCreatureAttackTime;
        L1348_s_GlobalData.LastPartyMovementTime = G362_l_LastPartyMovementTime;
        L1348_s_GlobalData.DisabledMovementTicks = G310_i_DisabledMovementTicks;
        L1348_s_GlobalData.ProjectileDisabledMovementTicks = G311_i_ProjectileDisabledMovementTicks;
        L1348_s_GlobalData.LastProjectileDisabledMovementDirection = G312_i_LastProjectileDisabledMovementDirection;
#ifdef C12_COMPILE_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE1_02_FIX The object is not removed from the leader hand while saving */
        L1348_s_GlobalData.LeaderHandObject = G414_T_LeaderHandObject;
#endif
        L1348_s_GlobalData.MaximumActiveGroupCount = G376_ui_MaximumActiveGroupCount;
#ifdef C00_COMPILE_DM10aEN /* CHANGE1_02_FIX The object is removed from the leader hand while saving with F298_aqzz_CHAMPION_GetObjectRemovedFromLeaderHand which also hides the object name on screen while saving */
        if (!G415_B_LeaderEmptyHanded) {
                L1348_s_GlobalData.LeaderHandObject = F298_aqzz_CHAMPION_GetObjectRemovedFromLeaderHand();
        } else {
                L1348_s_GlobalData.LeaderHandObject = C0xFFFF_THING_NONE;
        }
#endif
        F008_aA19_MAIN_ClearBytes(L1348_s_GlobalData.Useless, sizeof(L1348_s_GlobalData.Useless)); /* BUG0_00 Useless code */
        F008_aA19_MAIN_ClearBytes(L1349_as_SaveParts, sizeof(L1349_as_SaveParts));
        L1349_as_SaveParts[C0_SAVE_PART_GLOBAL_DATA].Address = (char*)&L1348_s_GlobalData;
        L1349_as_SaveParts[C0_SAVE_PART_GLOBAL_DATA].ByteCount = sizeof(L1348_s_GlobalData);
        L1349_as_SaveParts[C1_SAVE_PART_ACTIVE_GROUP].Address = (char*)G375_ps_ActiveGroups;
        L1349_as_SaveParts[C1_SAVE_PART_ACTIVE_GROUP].ByteCount = G376_ui_MaximumActiveGroupCount * sizeof(ACTIVE_GROUP);
        L1349_as_SaveParts[C2_SAVE_PART_PARTY].Address = (char*)&G407_s_Party;
        L1349_as_SaveParts[C2_SAVE_PART_PARTY].ByteCount = sizeof(G407_s_Party);
        L1349_as_SaveParts[C3_SAVE_PART_EVENTS].Address = (char*)G370_ps_Events;
        L1349_as_SaveParts[C3_SAVE_PART_EVENTS].ByteCount = G369_ui_EventMaximumCount * sizeof(EVENT);
        L1349_as_SaveParts[C4_SAVE_PART_TIMELINE].Address = (char*)G371_pi_Timeline;
        L1349_as_SaveParts[C4_SAVE_PART_TIMELINE].ByteCount = G369_ui_EventMaximumCount * sizeof(int);
        L1342_ps_SaveHeader->SaveAndPlayChoice = L1338_B_SaveAndPlayChoice;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_29_IMPROVEMENT */
        F007_aAA7_MAIN_CopyBytes(G534_ac_SaveHeaderAdditionalData, L1342_ps_SaveHeader->AdditionalData, sizeof(G534_ac_SaveHeaderAdditionalData));
#endif
        L1342_ps_SaveHeader->GameID = G525_l_GameID;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_29_IMPROVEMENT */
        L1342_ps_SaveHeader->Format = C1_FORMAT_DM_ATARI_ST;
        L1342_ps_SaveHeader->Useless = C1_USELESS; /* BUG0_00 Useless code */
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_29_IMPROVEMENT */
        L1342_ps_SaveHeader->Format = G528_i_Format;
        L1342_ps_SaveHeader->Useless = G529_i_Useless; /* BUG0_00 Useless code */
        L1342_ps_SaveHeader->Platform = G527_i_Platform;
        L1342_ps_SaveHeader->DungeonID = G526_ui_DungeonID;
#endif
        A1339_i_SavePartIndex = 0;
        while (A1339_i_SavePartIndex < 16) {
                L1342_ps_SaveHeader->Keys[A1339_i_SavePartIndex++] = M06_RANDOM(65536);
        }
        for(A1339_i_SavePartIndex = 0; A1339_i_SavePartIndex < 5; A1339_i_SavePartIndex++) {
                L1342_ps_SaveHeader->Checksums[A1339_i_SavePartIndex] = F418_xxxx_SAVEUTIL_GetChecksum(L1349_as_SaveParts[A1339_i_SavePartIndex].Address, L1342_ps_SaveHeader->Keys[A1339_i_SavePartIndex], L1349_as_SaveParts[A1339_i_SavePartIndex].ByteCount >> 1);
        }
        if (!F430_xxxx_STARTEND_IsWriteObfuscatedSaveHeaderSuccessful(L1342_ps_SaveHeader)) {
                goto T433_059;
        }
        for(A1339_i_SavePartIndex = 0; A1339_i_SavePartIndex < 5; A1339_i_SavePartIndex++) {
                if (!F420_xxxx_SAVEUTIL_IsWriteObfuscatedSavePartSuccessful(L1349_as_SaveParts[A1339_i_SavePartIndex].Address, L1349_as_SaveParts[A1339_i_SavePartIndex].ByteCount, L1342_ps_SaveHeader->Keys[A1339_i_SavePartIndex], &L1343_i_Checksum)) {
                        goto T433_059;
                }
        }
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_15_IMPROVEMENT */
        if (!F416_xxxx_SAVEUTIL_IsWriteBytesSuccessful(G278_ps_DungeonHeader, sizeof(DUNGEON_HEADER))) {
                goto T433_059;
        }
        if (!F416_xxxx_SAVEUTIL_IsWriteBytesSuccessful(G277_ps_DungeonMaps, G278_ps_DungeonHeader->MapCount * sizeof(MAP))) {
                goto T433_059;
        }
        if (!F416_xxxx_SAVEUTIL_IsWriteBytesSuccessful(G280_pui_DungeonColumnsCumulativeSquareThingCount, G282_ui_DungeonColumnCount * sizeof(int))) {
                goto T433_059;
        }
        if (!F416_xxxx_SAVEUTIL_IsWriteBytesSuccessful(G283_pT_SquareFirstThings, G278_ps_DungeonHeader->SquareFirstThingCount * sizeof(int))) {
                goto T433_059;
        }
        if (!F416_xxxx_SAVEUTIL_IsWriteBytesSuccessful(G260_pui_DungeonTextData, G278_ps_DungeonHeader->TextDataWordCount * sizeof(int))) {
                goto T433_059;
        }
        for(A1339_i_ThingType = C00_THING_TYPE_DOOR; A1339_i_ThingType < C15_THING_TYPE_EXPLOSION + 1; A1339_i_ThingType++) {
                if (!F416_xxxx_SAVEUTIL_IsWriteBytesSuccessful(G284_apuc_ThingData[A1339_i_ThingType], G235_auc_Graphic559_ThingDataByteCount[A1339_i_ThingType] * G278_ps_DungeonHeader->ThingCount[A1339_i_ThingType])) {
                        goto T433_059;
                }
        }
        if (!F416_xxxx_SAVEUTIL_IsWriteBytesSuccessful(G276_puc_DungeonRawMapData, G278_ps_DungeonHeader->RawMapDataByteCount)) {
                goto T433_059;
        }
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_15_IMPROVEMENT A checksum is appended to dungeon data (in both dungeon files and saved game files) to improve reliability */
        A1341_pc_DungeonChecksum = (char*)&L1345_i_DungeonChecksum;
        L1345_i_DungeonChecksum = 0;
        if (!F422_xxxx_SAVEUTIL_IsWriteBytesWithChecksumSuccessful(G278_ps_DungeonHeader, (int*)A1341_pc_DungeonChecksum, sizeof(DUNGEON_HEADER))) {
                goto T433_059;
        }
        if (!F422_xxxx_SAVEUTIL_IsWriteBytesWithChecksumSuccessful(G277_ps_DungeonMaps, (int*)A1341_pc_DungeonChecksum, G278_ps_DungeonHeader->MapCount * sizeof(MAP))) {
                goto T433_059;
        }
        if (!F422_xxxx_SAVEUTIL_IsWriteBytesWithChecksumSuccessful(G280_pui_DungeonColumnsCumulativeSquareThingCount, (int*)A1341_pc_DungeonChecksum, G282_ui_DungeonColumnCount * sizeof(int))) {
                goto T433_059;
        }
        if (!F422_xxxx_SAVEUTIL_IsWriteBytesWithChecksumSuccessful(G283_pT_SquareFirstThings, (int*)A1341_pc_DungeonChecksum, G278_ps_DungeonHeader->SquareFirstThingCount * sizeof(int))) {
                goto T433_059;
        }
        if (!F422_xxxx_SAVEUTIL_IsWriteBytesWithChecksumSuccessful(G260_pui_DungeonTextData, (int*)A1341_pc_DungeonChecksum, G278_ps_DungeonHeader->TextDataWordCount * sizeof(int))) {
                goto T433_059;
        }
        for(A1339_i_ThingType = C00_THING_TYPE_DOOR; A1339_i_ThingType < C15_THING_TYPE_EXPLOSION + 1; A1339_i_ThingType++) {
                if (!F422_xxxx_SAVEUTIL_IsWriteBytesWithChecksumSuccessful(G284_apuc_ThingData[A1339_i_ThingType], (int*)A1341_pc_DungeonChecksum, G235_auc_Graphic559_ThingDataByteCount[A1339_i_ThingType] * G278_ps_DungeonHeader->ThingCount[A1339_i_ThingType])) {
                        goto T433_059;
                }
        }
        if (!F422_xxxx_SAVEUTIL_IsWriteBytesWithChecksumSuccessful(G276_puc_DungeonRawMapData, (int*)A1341_pc_DungeonChecksum, G278_ps_DungeonHeader->RawMapDataByteCount)) {
                goto T433_059;
        }
        if (!F416_xxxx_SAVEUTIL_IsWriteBytesSuccessful((int*)A1341_pc_DungeonChecksum, sizeof(int))) {
                goto T433_059;
        }
#endif
        Fclose(G521_i_GameFileHandle);
        if (!L1338_B_SaveAndPlayChoice) {
                F078_xzzz_MOUSE_ShowPointer();
                F444_AA29_STARTEND_Endgame(FALSE);
        }
        /* BUG0_57 The object in the leader hand disappears after saving the game. The object is removed from the leader hand before saving the champion data so that its weight is not permanently added to the load of the leader. Also the object name is not visible while saving. However the object is not put back in the leader hand when saving is complete, which creates an orphan. If the game is loaded, then the object is restored in the leader hand. If the game is saved a second time, the object cannot be recovered */
#ifdef C12_COMPILE_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE1_02_FIX Add leader hand object weight after saving */
        if (!G415_B_LeaderEmptyHanded) {
                G407_s_Party.Champions[G411_i_LeaderIndex].Load += L1344_ui_Weight;
        }
#endif
        G524_B_RestartGameAllowed = TRUE;
        goto T433_060;
        T433_059:
        Fclose(G521_i_GameFileHandle);
        F427_xxxx_DIALOG_Draw(G540_pc_D088_UNABLETOSAVEGAME, NULL, G560_pc_D108_OK, NULL, NULL, NULL, FALSE, FALSE, FALSE);
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_34_OPTIMIZATION */
        F078_xzzz_MOUSE_ShowPointer();
        F424_xxxx_DIALOG_GetChoice(C1_ONE_CHOICE, C0_DIALOG_SET_VIEWPORT);
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_34_OPTIMIZATION */
        F424_xxxx_DIALOG_GetChoice(C1_ONE_CHOICE, C0_DIALOG_SET_VIEWPORT, C0_USELESS, C0_USELESS);
#endif
        T433_060:
        F469_rzzz_MEMORY_FreeAtHeapTop((long)sizeof(SAVE_HEADER));
        F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(C0_DO_NOT_FORCE_DIALOG_DM_CSB, FALSE);
        F457_AA08_START_DrawEnabledMenus_COPYPROTECTIONF();
        F078_xzzz_MOUSE_ShowPointer();
}

BOOLEAN F434_xxxx_STARTEND_IsLoadDungeonSuccessful_COPYPROTECTIONC()
{
        register int L1352_i_MapCount;
        register int L1353_i_Multiple;
#define A1353_i_InitialPartyLocation L1353_i_Multiple
#define A1353_i_ThingType            L1353_i_Multiple
#define A1353_i_Counter              L1353_i_Multiple
        register int L1354_i_Counter;
        register unsigned int L1355_ui_Multiple;
#define A1355_ui_ColumnCount        L1355_ui_Multiple
#define A1355_ui_Counter            L1355_ui_Multiple
#define A1355_ui_ThingDataByteCount L1355_ui_Multiple
        register GENERIC* L1356_ps_Generic;
        register unsigned char** L1357_ppuc_ColumnFirstSquares;
        unsigned char* L1358_puc_Square;
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_15_IMPROVEMENT */
        int L1359_i_ExpectedChecksum;
        int L1360_i_RunningChecksum;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_30_IMPROVEMENT */
        unsigned long L1361_ul_FileSize;
        COMPRESSED_DUNGEON_HEADER L1362_s_CompressedDungeonHeader;
#endif


#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_15_IMPROVEMENT */
        L1360_i_RunningChecksum = 0;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_30_IMPROVEMENT */
        G530_B_LoadingCompressedDungeon = FALSE;
        if (G298_B_NewGame) {
                if (Fread(G521_i_GameFileHandle, (long)sizeof(COMPRESSED_DUNGEON_HEADER), &L1362_s_CompressedDungeonHeader) != sizeof(COMPRESSED_DUNGEON_HEADER)) {
                        goto T434_043;
                }
                if (L1362_s_CompressedDungeonHeader.Signature != C0x8104_SIGNATURE_COMPRESSED_DUNGEON) { /* If the dungeon is not compressed */
                        Fseek(0L, G521_i_GameFileHandle, C0_SEEK_FROM_BEGINNING_OF_FILE) >= 0; /* Result of fseek is ignored */
                } else {
                        G526_ui_DungeonID = L1362_s_CompressedDungeonHeader.DungeonID;
                        G530_B_LoadingCompressedDungeon = TRUE;
                        G531_puc_DecompressedDungeonCurrentPosition = F468_ozzz_MEMORY_Allocate(G532_l_DecompressedDungeonRemainingByteCount = L1362_s_CompressedDungeonHeader.DecompressedByteCount, C2_ALLOCATION_TEMPORARY_ON_BOTTOM_OF_HEAP);
                        L1356_ps_Generic = (GENERIC*)F468_ozzz_MEMORY_Allocate(L1361_ul_FileSize = Fseek(0L, G521_i_GameFileHandle, C2_SEEK_FROM_END_OF_FILE) - 8, C2_ALLOCATION_TEMPORARY_ON_BOTTOM_OF_HEAP);
                        Fseek(8L, G521_i_GameFileHandle, C0_SEEK_FROM_BEGINNING_OF_FILE) >= 0; /* Result of fseek is ignored */
                        if (Fread(G521_i_GameFileHandle, (long)L1361_ul_FileSize, L1356_ps_Generic) != L1361_ul_FileSize) {
                                goto T434_043;
                        }
                        F455_xxxx_FLOPPY_DecompressDungeon(L1356_ps_Generic, G531_puc_DecompressedDungeonCurrentPosition, L1362_s_CompressedDungeonHeader.DecompressedByteCount);
                        F470_xzzz_MEMORY_FreeAtHeapBottom(L1361_ul_FileSize);
                }
        }
#endif
        if (!G523_B_RestartGameRequested) {
                G278_ps_DungeonHeader = (DUNGEON_HEADER*)F468_ozzz_MEMORY_Allocate((long)sizeof(DUNGEON_HEADER), C1_ALLOCATION_PERMANENT);
        }
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_15_IMPROVEMENT */
        if (!F415_xxxx_SAVEUTIL_IsReadBytesSuccessful(G278_ps_DungeonHeader, sizeof(DUNGEON_HEADER))) {
                return FALSE;
        }
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_15_IMPROVEMENT */
        if (!F421_xxxx_SAVEUTIL_IsReadBytesWithChecksumSuccessful(G278_ps_DungeonHeader, &L1360_i_RunningChecksum, sizeof(DUNGEON_HEADER))) {
                goto T434_043;
        }
#endif
        if (G298_B_NewGame) {
                G306_i_PartyMapX = (A1353_i_InitialPartyLocation = G278_ps_DungeonHeader->InitialPartyLocation) & 0x001F;
                G307_i_PartyMapY = (A1353_i_InitialPartyLocation >>= 5) & 0x001F;
                G308_i_PartyDirection = (A1353_i_InitialPartyLocation >> 5) & 0x0003;
                G309_i_PartyMapIndex = 0;
        }
        L1352_i_MapCount = G278_ps_DungeonHeader->MapCount;
        if (!G523_B_RestartGameRequested) {
                G277_ps_DungeonMaps = (MAP*)F468_ozzz_MEMORY_Allocate((long)(sizeof(MAP) * L1352_i_MapCount), C1_ALLOCATION_PERMANENT);
        }
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_15_IMPROVEMENT */
        if (!F415_xxxx_SAVEUTIL_IsReadBytesSuccessful(G277_ps_DungeonMaps, L1352_i_MapCount * sizeof(MAP))) {
                return FALSE;
        }
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_15_IMPROVEMENT */
        if (!F421_xxxx_SAVEUTIL_IsReadBytesWithChecksumSuccessful(G277_ps_DungeonMaps, &L1360_i_RunningChecksum, L1352_i_MapCount * sizeof(MAP))) {
                goto T434_043;
        }
#endif
        if (!G523_B_RestartGameRequested) {
                G281_pi_DungeonMapsFirstColumnIndex = (int*)F468_ozzz_MEMORY_Allocate((long)(L1352_i_MapCount << 1), C1_ALLOCATION_PERMANENT);
        }
        A1355_ui_ColumnCount = L1354_i_Counter = 0;
        while (L1354_i_Counter < L1352_i_MapCount) {
                G281_pi_DungeonMapsFirstColumnIndex[L1354_i_Counter] = A1355_ui_ColumnCount;
                A1355_ui_ColumnCount += G277_ps_DungeonMaps[L1354_i_Counter].A.Width + 1;
                L1354_i_Counter++;
        }
        G282_ui_DungeonColumnCount = A1355_ui_ColumnCount;
        L1354_i_Counter = G278_ps_DungeonHeader->SquareFirstThingCount;
        if (G298_B_NewGame) {
                G278_ps_DungeonHeader->SquareFirstThingCount += 300;
        }
        if (!G523_B_RestartGameRequested) {
                G280_pui_DungeonColumnsCumulativeSquareThingCount = (unsigned int*)F468_ozzz_MEMORY_Allocate((long)(A1355_ui_ColumnCount << 1), C1_ALLOCATION_PERMANENT);
                G283_pT_SquareFirstThings = (THING*)F468_ozzz_MEMORY_Allocate((long)(G278_ps_DungeonHeader->SquareFirstThingCount << 1), C1_ALLOCATION_PERMANENT);
                G260_pui_DungeonTextData = (unsigned int*)F468_ozzz_MEMORY_Allocate((long)(G278_ps_DungeonHeader->TextDataWordCount) << 1, C1_ALLOCATION_PERMANENT);
        }
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_15_IMPROVEMENT */
        if (!F415_xxxx_SAVEUTIL_IsReadBytesSuccessful(G280_pui_DungeonColumnsCumulativeSquareThingCount, A1355_ui_ColumnCount * sizeof(int))) {
                return FALSE;
        }
        if (!F415_xxxx_SAVEUTIL_IsReadBytesSuccessful(G283_pT_SquareFirstThings, L1354_i_Counter * sizeof(int))) {
                return FALSE;
        }
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_15_IMPROVEMENT */
        if (!F421_xxxx_SAVEUTIL_IsReadBytesWithChecksumSuccessful(G280_pui_DungeonColumnsCumulativeSquareThingCount, &L1360_i_RunningChecksum, A1355_ui_ColumnCount * sizeof(int))) {
                goto T434_043;
        }
        if (!F421_xxxx_SAVEUTIL_IsReadBytesWithChecksumSuccessful(G283_pT_SquareFirstThings, &L1360_i_RunningChecksum, L1354_i_Counter * sizeof(int))) {
                goto T434_043;
        }
#endif
        if (G298_B_NewGame) {
                for(A1355_ui_Counter = 0; A1355_ui_Counter < 300; A1355_ui_Counter++) {
                        G283_pT_SquareFirstThings[L1354_i_Counter++] = C0xFFFF_THING_NONE;
                }
        }
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_15_IMPROVEMENT */
        if (!F415_xxxx_SAVEUTIL_IsReadBytesSuccessful(G260_pui_DungeonTextData, G278_ps_DungeonHeader->TextDataWordCount * sizeof(int))) {
                return FALSE;
        }
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_15_IMPROVEMENT */
        if (!F421_xxxx_SAVEUTIL_IsReadBytesWithChecksumSuccessful(G260_pui_DungeonTextData, &L1360_i_RunningChecksum, G278_ps_DungeonHeader->TextDataWordCount * sizeof(int))) {
                goto T434_043;
        }
#endif
        if (G298_B_NewGame) {
                G369_ui_EventMaximumCount = 100;
        }
        for(A1353_i_ThingType = C00_THING_TYPE_DOOR; A1353_i_ThingType < C15_THING_TYPE_EXPLOSION + 1; A1353_i_ThingType++) {
                L1354_i_Counter = G278_ps_DungeonHeader->ThingCount[A1353_i_ThingType];
                if (G298_B_NewGame) {
                        G278_ps_DungeonHeader->ThingCount[A1353_i_ThingType] = F024_aatz_MAIN_GetMinimumValue((A1353_i_ThingType == C15_THING_TYPE_EXPLOSION) ? 768 : 1024, L1354_i_Counter + G236_auc_Graphic559_AdditionalThingCounts[A1353_i_ThingType]);
                }
                A1355_ui_ThingDataByteCount = G235_auc_Graphic559_ThingDataByteCount[A1353_i_ThingType];
                if (!G523_B_RestartGameRequested) {
                        G284_apuc_ThingData[A1353_i_ThingType] = F468_ozzz_MEMORY_Allocate((long)(G278_ps_DungeonHeader->ThingCount[A1353_i_ThingType] * A1355_ui_ThingDataByteCount), C1_ALLOCATION_PERMANENT);
                }
                L1356_ps_Generic = (GENERIC*)G284_apuc_ThingData[A1353_i_ThingType];
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_15_IMPROVEMENT */
                if (!F415_xxxx_SAVEUTIL_IsReadBytesSuccessful(G284_apuc_ThingData[A1353_i_ThingType], A1355_ui_ThingDataByteCount * L1354_i_Counter)) {
                        return FALSE;
                }
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_15_IMPROVEMENT */
                if (!F421_xxxx_SAVEUTIL_IsReadBytesWithChecksumSuccessful(G284_apuc_ThingData[A1353_i_ThingType], &L1360_i_RunningChecksum, A1355_ui_ThingDataByteCount * L1354_i_Counter)) {
                        goto T434_043;
                }
#endif
                if (G298_B_NewGame) {
                        if ((A1353_i_ThingType == C04_THING_TYPE_GROUP) || (A1353_i_ThingType >= C14_THING_TYPE_PROJECTILE)) {
                                G369_ui_EventMaximumCount += G278_ps_DungeonHeader->ThingCount[A1353_i_ThingType];
                        }
                        for(L1356_ps_Generic += L1354_i_Counter * (A1355_ui_ThingDataByteCount >>= 1), L1354_i_Counter = G236_auc_Graphic559_AdditionalThingCounts[A1353_i_ThingType]; L1354_i_Counter; L1354_i_Counter--, L1356_ps_Generic += A1355_ui_ThingDataByteCount) {
                                L1356_ps_Generic->Next = C0xFFFF_THING_NONE;
                        }
                }
        }
        if (!G523_B_RestartGameRequested) {
                G276_puc_DungeonRawMapData = F468_ozzz_MEMORY_Allocate((long)G278_ps_DungeonHeader->RawMapDataByteCount, C1_ALLOCATION_PERMANENT);
        }
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_15_IMPROVEMENT */
        if (!F415_xxxx_SAVEUTIL_IsReadBytesSuccessful(G276_puc_DungeonRawMapData, G278_ps_DungeonHeader->RawMapDataByteCount)) {
                return FALSE;
        }
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_15_IMPROVEMENT A checksum is appended to dungeon data (in both dungeon files and saved game files) to improve reliability */
        if (!F421_xxxx_SAVEUTIL_IsReadBytesWithChecksumSuccessful(G276_puc_DungeonRawMapData, &L1360_i_RunningChecksum, G278_ps_DungeonHeader->RawMapDataByteCount)) {
                goto T434_043;
        }
        if (F415_xxxx_SAVEUTIL_IsReadBytesSuccessful(&L1359_i_ExpectedChecksum, 2) && (L1359_i_ExpectedChecksum != L1360_i_RunningChecksum)) {
                goto T434_043;
        }
#endif
        if ((!G523_B_RestartGameRequested)
#ifndef NOCOPYPROTECTION
        && (F079_a002_COPYPROTECTIONC_GetChecksumAdd(&F433_AA39_STARTEND_ProcessCommand140_SaveGame_COPYPROTECTIONCDF) == CHECKSUM_D)
#endif
        ) {
                G279_pppuc_DungeonMapData = (unsigned char***)F468_ozzz_MEMORY_Allocate((long)((G282_ui_DungeonColumnCount + L1352_i_MapCount) * sizeof(char*)), C1_ALLOCATION_PERMANENT);
                L1357_ppuc_ColumnFirstSquares = (unsigned char**)(G279_pppuc_DungeonMapData + L1352_i_MapCount);
                for(L1354_i_Counter = 0; L1354_i_Counter < L1352_i_MapCount; L1354_i_Counter++) {
                        G279_pppuc_DungeonMapData[L1354_i_Counter] = L1357_ppuc_ColumnFirstSquares;
                        *L1357_ppuc_ColumnFirstSquares++ = (L1358_puc_Square = G276_puc_DungeonRawMapData + G277_ps_DungeonMaps[L1354_i_Counter].RawMapDataByteOffset);
                        for(A1353_i_Counter = 1; A1353_i_Counter <= G277_ps_DungeonMaps[L1354_i_Counter].A.Width; A1353_i_Counter++) {
                                *L1357_ppuc_ColumnFirstSquares++ = (L1358_puc_Square += (G277_ps_DungeonMaps[L1354_i_Counter].A.Height + 1));
                        }
                }
        }
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_30_IMPROVEMENT */
        if (G530_B_LoadingCompressedDungeon) {
                G530_B_LoadingCompressedDungeon = FALSE;
                F470_xzzz_MEMORY_FreeAtHeapBottom(L1362_s_CompressedDungeonHeader.DecompressedByteCount);
        }
#endif
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_12_FIX */
        F423_xxxx_SAVEUTIL_FixClonedThings();
#endif
        return TRUE;
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_15_IMPROVEMENT */
        T434_043:
        return FALSE;
#endif
}

int F435_xxxx_STARTEND_LoadGame_COPYPROTECTIONF()
{
        register int L1363_i_Multiple;
#define A1363_i_Choice             L1363_i_Multiple
#define A1363_i_MapCount           L1363_i_Multiple
#define A1363_i_VerticalBlankCount L1363_i_Multiple
        register BOOLEAN L1364_B_LoadBackupGame;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_03_IMPROVEMENT Replaced by G568_i_DiskType in Chaos Strikes Back */
        register int L1365_i_DiskType;
#endif
        register BOOLEAN L1366_B_FadePalette;
        register char* L1367_pc_Message;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_14_FIX Useless code removed */
        int L1368_i_Unreferenced; /* BUG0_00 Useless code */
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives */
        char L1369_ac_PutTheGameSaveDiskIn[50];
        char L1370_ac_ThereIsNoDiskIn[50];
#endif
        GLOBAL_DATA L1371_s_GlobalData;
        SAVE_HEADER L1372_s_SaveHeader;
#ifdef C04_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE /* CHANGE5_06_OPTIMIZATION */
        unsigned int L1373_aui_Palette_Blank[16];
#endif


        L1366_B_FadePalette = FALSE;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_29_IMPROVEMENT */
        G528_i_Format = C2_FORMAT_DM_AMIGA_2X_PC98_X68000_FM_TOWNS_CSB_ATARI_ST;
        G529_i_Useless = C1_USELESS; /* BUG0_00 Useless code */
        G527_i_Platform = C1_PLATFORM_ATARI_ST;
        G526_ui_DungeonID = C10_DUNGEON_DM;
#endif
        L1367_pc_Message = NULL;
        if (G298_B_NewGame) {
                L1366_B_FadePalette = !F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(C0_DO_NOT_FORCE_DIALOG_DM_CSB, TRUE);
                G521_i_GameFileHandle = Fopen("\\DUNGEON.DAT", C0_READ_ONLY);
                if (G521_i_GameFileHandle < 0) {
                        F019_aarz_MAIN_DisplayErrorAndStop(C50_ERROR_UNABLE_TO_OPEN_DUNGEON_OR_SAVED_GAME);
                        for(;;); /*_Infinite loop_*/
                }
                T435_002:
                G524_B_RestartGameAllowed = FALSE;
                G305_ui_PartyChampionCount = 0;
                G414_T_LeaderHandObject = C0xFFFF_THING_NONE;
                G525_l_GameID = (long)M06_RANDOM(65536) * M06_RANDOM(65536);
        } else {
                L1367_pc_Message = NULL;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_03_IMPROVEMENT CHANGE7_32_IMPROVEMENT */
                T435_004:
                do {
                        F427_xxxx_DIALOG_Draw(L1367_pc_Message, G548_pc_D096_PUTTHEGAMESAVEDISKIN, G556_pc_D104_LOADSAVEDGAME, G561_pc_D109_CANCEL, NULL, NULL, TRUE, TRUE, TRUE);
                        F078_xzzz_MOUSE_ShowPointer();
                        A1363_i_Choice = F424_xxxx_DIALOG_GetChoice(C2_TWO_CHOICES, C1_DIALOG_SET_SCREEN);
                        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                        if (A1363_i_Choice == 2) { /* Choice 'CANCEL' */
                                T435_008: /* BUG0_58 The game stops with message 'SYSTEM ERROR 41' when you click Resume on the entrance screen and then click Cancel. If the game disk is not in the floppy disk drive when clicking Cancel then the game fails to open the graphics.dat file */
#ifdef C14_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE2_19_FIX The game disk is required when clicking Cancel. */
                                F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(C0_DO_NOT_FORCE_DIALOG_DM_CSB, TRUE);
#endif
                                return CM1_LOAD_GAME_FAILURE;
                        }
                        T435_009:
                        if ((L1365_i_DiskType = F452_xxxx_FLOPPY_GetDiskTypeInDrive_COPYPROTECTIONB()) == C1_DISK_TYPE_SAVE_DISK_WRITE_ENABLED) {
                                L1364_B_LoadBackupGame = FALSE;
                                if ((G521_i_GameFileHandle = Fopen(G519_pc_D081_ADMGAMEDAT, C0_READ_ONLY)) < 0) {
                                        if ((G521_i_GameFileHandle = Fopen(G520_pc_D082_ADMGAMEBAK, C0_READ_ONLY)) >= 0) {
                                                L1364_B_LoadBackupGame = TRUE;
                                        } else {
                                                if (!G523_B_RestartGameRequested && ((G521_i_GameFileHandle = Fopen("A:\\DUNGEON.FTL", C0_READ_ONLY)) >= 0)) {
                                                        L1366_B_FadePalette = TRUE;
                                                        G298_B_NewGame = C001_MODE_LOAD_DUNGEON;
                                                        goto T435_002;
                                                }
                                                L1367_pc_Message = G539_pc_D087_CANTFINDSAVEDGAME;
                                                L1365_i_DiskType = C3_DISK_TYPE_UNFORMATTED_DISK;
                                        }
                                }
                        } else {
                                if (L1365_i_DiskType == C0_DISK_TYPE_GAME_DISK) {
                                        L1367_pc_Message = G542_pc_D090_THATSTHEGAMEDISK;
                                } else {
                                        if (L1365_i_DiskType == C3_DISK_TYPE_UNFORMATTED_DISK) {
                                                L1367_pc_Message = G545_pc_D093_THATDISKISUNREADABLE;
                                        } else {
                                                if (L1365_i_DiskType == C2_DISK_TYPE_SAVE_DISK_WRITE_PROTECTED) {
                                                        L1367_pc_Message = G544_pc_D092_THATDISKISWRITEPROTECTED;
                                                }
                                        }
                                }
                        }
                } while (L1365_i_DiskType != C1_DISK_TYPE_SAVE_DISK_WRITE_ENABLED);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives CHANGE7_32_IMPROVEMENT Refactored load game function: New dialog message if there is no floppy disk in the drive CHANGE7_34_OPTIMIZATION */
                F414_xxxx_SAVEUTIL_ReplaceTildeByDriveLetterInString(L1369_ac_PutTheGameSaveDiskIn, G548_pc_D096_PUTTHEGAMESAVEDISKIN, C2_DRIVE_TYPE_SAVE_DISK);
                F414_xxxx_SAVEUTIL_ReplaceTildeByDriveLetterInString(L1370_ac_ThereIsNoDiskIn, G555_pc_D103_THEREISNODISKIN, C2_DRIVE_TYPE_SAVE_DISK);
                T435_004:
                if (G567_B_SingleFloppyDrive == TRUE) {
                        if (F452_xxxx_FLOPPY_GetDiskTypeInDrive_COPYPROTECTIONB(C2_DRIVE_TYPE_SAVE_DISK) == C1_DISK_TYPE_SAVE_DISK_WRITE_ENABLED) {
                                goto T435_009;
                        }
                } else {
                        if (L1367_pc_Message == NULL) {
                                goto T435_009;
                        }
                }
                do {
                        if (L1367_pc_Message == NULL); /* BUG0_00 Useless code */
                        F427_xxxx_DIALOG_Draw(L1367_pc_Message, L1369_ac_PutTheGameSaveDiskIn, G556_pc_D104_LOADSAVEDGAME, G561_pc_D109_CANCEL, NULL, NULL, TRUE, TRUE, TRUE);
                        A1363_i_Choice = F424_xxxx_DIALOG_GetChoice(C2_TWO_CHOICES, C1_DIALOG_SET_SCREEN, C2_USELESS, C1_USELESS);
                        if (A1363_i_Choice == 2) { /* Choice 'CANCEL' */
                                T435_008:
                                F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(C0_DO_NOT_FORCE_DIALOG_DM_CSB, TRUE);
                                return CM1_LOAD_GAME_FAILURE;
                        }
                        T435_009:
                        if (F454_xxxx_FLOPPY_IsSaveDiskTypeInSaveDiskDrive(C1_SAVE_DISK_WRITE_ENABLED_FOR_LOADING) == TRUE) {
                                L1364_B_LoadBackupGame = FALSE;
                                if ((G521_i_GameFileHandle = Fopen(G569_pc_SavedGameFileName, C0_READ_ONLY)) < 0) {
                                        if ((G521_i_GameFileHandle = Fopen(G570_pc_SavedGameBackupFileName, C0_READ_ONLY)) >= 0) {
                                                L1364_B_LoadBackupGame = TRUE;
                                        } else {
                                                if (!G523_B_RestartGameRequested && ((G521_i_GameFileHandle = Fopen("A:\\DUNGEON.FTL", C0_READ_ONLY)) >= 0)) {
                                                        L1366_B_FadePalette = TRUE;
                                                        G298_B_NewGame = C001_MODE_LOAD_DUNGEON;
                                                        goto T435_002;
                                                }
                                                L1367_pc_Message = G539_pc_D087_CANTFINDSAVEDGAME;
                                                G568_i_DiskType = C3_DISK_TYPE_UNFORMATTED_DISK;
                                        }
                                }
                        } else {
                                if (G568_i_DiskType == C0_DISK_TYPE_GAME_DISK) {
                                        L1367_pc_Message = G542_pc_D090_THATSTHEGAMEDISK;
                                } else {
                                        if (G568_i_DiskType == C3_DISK_TYPE_UNFORMATTED_DISK) {
                                                L1367_pc_Message = G545_pc_D093_THATDISKISUNREADABLE;
                                        } else {
                                                if (G568_i_DiskType == C2_DISK_TYPE_SAVE_DISK_WRITE_PROTECTED) {
                                                        L1367_pc_Message = G544_pc_D092_THATDISKISWRITEPROTECTED;
                                                } else {
                                                        if (G568_i_DiskType == C4_DISK_TYPE_NO_DISK) {
                                                                L1367_pc_Message = &L1370_ac_ThereIsNoDiskIn;
                                                        }
                                                }
                                        }
                                }
                        }
                } while (G568_i_DiskType != C1_DISK_TYPE_SAVE_DISK_WRITE_ENABLED);
#endif
                if (!F429_xxxx_STARTEND_IsReadSaveHeaderSuccessful(&L1372_s_SaveHeader)) {
                        goto T435_037;
                }
                if (G523_B_RestartGameRequested && (L1372_s_SaveHeader.GameID != G525_l_GameID)) {
                        L1367_pc_Message = G546_pc_D094_THATSNOTTHESAMEGAME;
                        goto T435_004;
                }
                G525_l_GameID = L1372_s_SaveHeader.GameID;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_29_IMPROVEMENT */
                F007_aAA7_MAIN_CopyBytes(L1372_s_SaveHeader.AdditionalData, G534_ac_SaveHeaderAdditionalData, sizeof(G534_ac_SaveHeaderAdditionalData));
                if ((L1372_s_SaveHeader.Format != C1_FORMAT_DM_ATARI_ST) && (L1372_s_SaveHeader.Platform != C1_PLATFORM_ATARI_ST)) {
                        goto T435_037;
                }
#endif
                if (!F419_xxxx_SAVEUTIL_IsReadObfuscatedBytesAndValidateChecksumSuccessful(&L1371_s_GlobalData, sizeof(GLOBAL_DATA), L1372_s_SaveHeader.Keys[C0_SAVE_PART_GLOBAL_DATA], L1372_s_SaveHeader.Checksums[C0_SAVE_PART_GLOBAL_DATA])) {
                        goto T435_037;
                }
#ifndef NOCOPYPROTECTION
                G319_ul_LoadGameTime_COPYPROTECTIONF = 
#endif
                G313_ul_GameTime = L1371_s_GlobalData.GameTime;
                G349_ul_LastRandomNumber = L1371_s_GlobalData.LastRandomNumber;
                G305_ui_PartyChampionCount = L1371_s_GlobalData.PartyChampionCount;
                G306_i_PartyMapX = L1371_s_GlobalData.PartyMapX;
                G307_i_PartyMapY = L1371_s_GlobalData.PartyMapY;
                G308_i_PartyDirection = L1371_s_GlobalData.PartyDirection;
                G309_i_PartyMapIndex = L1371_s_GlobalData.PartyMapIndex;
                G411_i_LeaderIndex = L1371_s_GlobalData.LeaderIndex;
                G514_i_MagicCasterChampionIndex = L1371_s_GlobalData.MagicCasterChampionIndex;
                G372_ui_EventCount = L1371_s_GlobalData.EventCount;
                G373_ui_FirstUnusedEventIndex = L1371_s_GlobalData.FirstUnusedEventIndex;
                G369_ui_EventMaximumCount = L1371_s_GlobalData.EventMaximumCount;
                G377_ui_CurrentActiveGroupCount = L1371_s_GlobalData.CurrentActiveGroupCount;
                G361_l_LastCreatureAttackTime = L1371_s_GlobalData.LastCreatureAttackTime;
                G362_l_LastPartyMovementTime = L1371_s_GlobalData.LastPartyMovementTime;
                G310_i_DisabledMovementTicks = L1371_s_GlobalData.DisabledMovementTicks;
                G311_i_ProjectileDisabledMovementTicks = L1371_s_GlobalData.ProjectileDisabledMovementTicks;
                G312_i_LastProjectileDisabledMovementDirection = L1371_s_GlobalData.LastProjectileDisabledMovementDirection;
                G414_T_LeaderHandObject = L1371_s_GlobalData.LeaderHandObject;
                G376_ui_MaximumActiveGroupCount = L1371_s_GlobalData.MaximumActiveGroupCount;
                if (!G523_B_RestartGameRequested) {
                        F233_wzzz_TIMELINE_Initialize();
                        F196_aozz_GROUP_InitializeActiveGroups();
                }
                if (!F419_xxxx_SAVEUTIL_IsReadObfuscatedBytesAndValidateChecksumSuccessful(G375_ps_ActiveGroups, sizeof(ACTIVE_GROUP) * G376_ui_MaximumActiveGroupCount, L1372_s_SaveHeader.Keys[C1_SAVE_PART_ACTIVE_GROUP], L1372_s_SaveHeader.Checksums[C1_SAVE_PART_ACTIVE_GROUP])) {
                        goto T435_037;
                }
                if (!F419_xxxx_SAVEUTIL_IsReadObfuscatedBytesAndValidateChecksumSuccessful(&G407_s_Party, sizeof(PARTY), L1372_s_SaveHeader.Keys[C2_SAVE_PART_PARTY], L1372_s_SaveHeader.Checksums[C2_SAVE_PART_PARTY])) {
                        goto T435_037;
                }
                if (!F419_xxxx_SAVEUTIL_IsReadObfuscatedBytesAndValidateChecksumSuccessful(G370_ps_Events, sizeof(EVENT) * G369_ui_EventMaximumCount, L1372_s_SaveHeader.Keys[C3_SAVE_PART_EVENTS], L1372_s_SaveHeader.Checksums[C3_SAVE_PART_EVENTS])) {
                        goto T435_037;
                }
                if (!F419_xxxx_SAVEUTIL_IsReadObfuscatedBytesAndValidateChecksumSuccessful(G371_pi_Timeline, sizeof(int) * G369_ui_EventMaximumCount, L1372_s_SaveHeader.Keys[C4_SAVE_PART_TIMELINE], L1372_s_SaveHeader.Checksums[C4_SAVE_PART_TIMELINE])) {
                        goto T435_037;
                }
        }
        if (!F434_xxxx_STARTEND_IsLoadDungeonSuccessful_COPYPROTECTIONC()) {
                goto T435_037;
        }
        Fclose(G521_i_GameFileHandle);
        if (G298_B_NewGame) {
                F233_wzzz_TIMELINE_Initialize();
                F196_aozz_GROUP_InitializeActiveGroups();
                if (L1366_B_FadePalette) {
#ifdef C04_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE /* CHANGE5_06_OPTIMIZATION */
                        F008_aA19_MAIN_ClearBytes(L1373_aui_Palette_Blank, sizeof(L1373_aui_Palette_Blank));
                        F436_xxxx_STARTEND_FadeToPalette(L1373_aui_Palette_Blank);
#endif
#ifdef C24_COMPILE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE5_06_OPTIMIZATION Use an existing blank global variable as a blank color palette instead of a dedicated local variable */
                        F436_xxxx_STARTEND_FadeToPalette(G345_aui_BlankBuffer);
#endif
                        Vsync();
                        F008_aA19_MAIN_ClearBytes(G348_pl_Bitmap_LogicalScreenBase, M75_BITMAP_BYTE_COUNT(320, 200));
                        F436_xxxx_STARTEND_FadeToPalette(G347_aui_Palette_TopAndBottomScreen);
                }
                F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(C0_DO_NOT_FORCE_DIALOG_DM_CSB, TRUE);
        } else {
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_29_IMPROVEMENT Read additional save header data */
                G529_i_Useless = L1372_s_SaveHeader.Useless; /* BUG0_00 Useless code */
                if (L1372_s_SaveHeader.Format == C1_FORMAT_DM_ATARI_ST) { /* BUG0_00 Useless code. This code is never run because in CSB the format is C2_FORMAT_DM_AMIGA_2X_PC98_X68000_FM_TOWNS_CSB_ATARI_ST and the save header structure was changed making it impossible to load saved games made with earlier versions of the engine. DM Atari ST did not store the dungeon ID in the saved game file. This code tries to detect the dungeon based on the values of map count and ornament random seed */
                        A1363_i_MapCount = G278_ps_DungeonHeader->MapCount;
                        if ((A1363_i_MapCount == 14) && (G278_ps_DungeonHeader->OrnamentRandomSeed == 99)) { /* Original dungeon of Dungeon Master */
                                G526_ui_DungeonID = C10_DUNGEON_DM;
                        } else {
                                if ((A1363_i_MapCount == 10) && (G278_ps_DungeonHeader->OrnamentRandomSeed == 76)) { /* Broken detection of the original dungeon of Chaos Strikes Back because the actual CSB dungeon has 11 maps and its seed is 13. This was possibly implemented to detect an early version of the CSB dungeon when it was still developed as a DM expansion pack and not yet a standalone game. This would have allowed loading a saved game made with the DM engine with the new CSB engine */
                                        G526_ui_DungeonID = C13_DUNGEON_CSB_GAME;
                                } else {
                                        G526_ui_DungeonID = C00_DUNGEON_UNKNOWN;
                                }
                        }
                } else {
                        G528_i_Format = L1372_s_SaveHeader.Format;
                        G527_i_Platform = L1372_s_SaveHeader.Platform;
                        G526_ui_DungeonID = L1372_s_SaveHeader.DungeonID;
                }
#endif
                G524_B_RestartGameAllowed = TRUE;
                if (L1364_B_LoadBackupGame) {
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_03_IMPROVEMENT */
                        Frename(C0_RESERVED, G520_pc_D082_ADMGAMEBAK, G519_pc_D081_ADMGAMEDAT);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives */
                        Frename(C0_RESERVED, G570_pc_SavedGameBackupFileName, G569_pc_SavedGameFileName);
#endif
                }
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_14_FIX Useless code removed. Screen is also erased and palette is also set by F427_xxxx_DIALOG_Draw called by F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn below */
                F008_aA19_MAIN_ClearBytes(G348_pl_Bitmap_LogicalScreenBase, M75_BITMAP_BYTE_COUNT(320, 200)); /* BUG0_00 Useless code */
                F436_xxxx_STARTEND_FadeToPalette(G347_aui_Palette_TopAndBottomScreen);
#endif
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_03_IMPROVEMENT */
                F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(C1_FORCE_DIALOG_DM, TRUE);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives */
                F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(C1_DO_NOT_FORCE_DIALOG_CSB, TRUE);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_32_IMPROVEMENT Refactored load game function: New dialog message while the game is loading */
                F427_xxxx_DIALOG_Draw(NULL, G552_pc_D100_LOADINGGAME, NULL, NULL, NULL, NULL, TRUE, TRUE, TRUE);
#endif
        }
        G303_B_PartyDead = FALSE;
        return C01_LOAD_GAME_SUCCESS;
        T435_037:
        F436_xxxx_STARTEND_FadeToPalette(G347_aui_Palette_TopAndBottomScreen);
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_17_IMPROVEMENT */
        F019_aarz_MAIN_DisplayErrorAndStop(C52_ERROR_UNABLE_TO_LOAD_SAVED_GAME);
#endif
        if (G523_B_RestartGameRequested) {
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_19_FIX Useless code removed. Cannot be executed because previous call to F019_aarz_MAIN_DisplayErrorAndStop contains an infinite loop */
                A1363_i_VerticalBlankCount = 600; /* BUG0_00 Useless code */
                while (--A1363_i_VerticalBlankCount) {
                        Vsync();
                }
                return CM1_LOAD_GAME_FAILURE;
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_17_IMPROVEMENT The game does not stop anymore and a dialog box with the message 'SAVED GAME DAMAGED!' is drawn if loading a saved game fails while restarting a game */
                F427_xxxx_DIALOG_Draw(G547_pc_D095_SAVEDGAMEDAMAGED, G549_pc_D097_PUTTHEGAMEDISKIN, G560_pc_D108_OK, NULL, NULL, NULL, TRUE, TRUE, TRUE);
#ifdef C18_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_34_OPTIMIZATION */
                F078_xzzz_MOUSE_ShowPointer();
                F424_xxxx_DIALOG_GetChoice(C1_ONE_CHOICE, C1_DIALOG_SET_SCREEN);
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_34_OPTIMIZATION */
                F424_xxxx_DIALOG_GetChoice(C1_ONE_CHOICE, C1_DIALOG_SET_SCREEN, C0_USELESS, C0_USELESS);
#endif
                goto T435_008;
#endif
        }
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_17_IMPROVEMENT The game still stops if the initial loading of a saved game fails */
        Cconws(G547_pc_D095_SAVEDGAMEDAMAGED);
#endif
        for(;;); /*_Infinite loop_*/
}

VOID F436_xxxx_STARTEND_FadeToPalette(P849_pui_Palette)
unsigned int* P849_pui_Palette;
{
        register unsigned int L1374_ui_CurrentRGBColor;
        register unsigned int L1375_ui_TargetRGBColor;
        register int L1376_i_Color;
        register int L1377_i_Counter;
        register unsigned int* L1378_pui_PaletteRegister;
        long L1379_l_SupervisorStack;


        L1378_pui_PaletteRegister = (unsigned int*)0xFFFF8240;
        L1379_l_SupervisorStack = Super(0L);
        for(L1377_i_Counter = 0; L1377_i_Counter < 8; L1377_i_Counter++) {
                Vsync();
                for(L1376_i_Color = 0; L1376_i_Color < 16; L1376_i_Color++) {
                        L1374_ui_CurrentRGBColor = L1378_pui_PaletteRegister[L1376_i_Color];
                        L1375_ui_TargetRGBColor = P849_pui_Palette[L1376_i_Color];
                        if (M07_GET(L1374_ui_CurrentRGBColor, MASK0x0007_BLUE_COMPONENT) > M07_GET(L1375_ui_TargetRGBColor, MASK0x0007_BLUE_COMPONENT)) {
                                L1374_ui_CurrentRGBColor--;
                        }
                        if (M07_GET(L1374_ui_CurrentRGBColor, MASK0x0007_BLUE_COMPONENT) < M07_GET(L1375_ui_TargetRGBColor, MASK0x0007_BLUE_COMPONENT)) {
                                L1374_ui_CurrentRGBColor++;
                        }
                        if (M07_GET(L1374_ui_CurrentRGBColor, MASK0x0070_GREEN_COMPONENT) > M07_GET(L1375_ui_TargetRGBColor, MASK0x0070_GREEN_COMPONENT)) {
                                L1374_ui_CurrentRGBColor -= 16;
                        }
                        if (M07_GET(L1374_ui_CurrentRGBColor, MASK0x0070_GREEN_COMPONENT) < M07_GET(L1375_ui_TargetRGBColor, MASK0x0070_GREEN_COMPONENT)) {
                                L1374_ui_CurrentRGBColor += 16;
                        }
                        if (M07_GET(L1374_ui_CurrentRGBColor, MASK0x0700_RED_COMPONENT) > M07_GET(L1375_ui_TargetRGBColor, MASK0x0700_RED_COMPONENT)) {
                                L1374_ui_CurrentRGBColor -= 256;
                        }
                        if (M07_GET(L1374_ui_CurrentRGBColor, MASK0x0700_RED_COMPONENT) < M07_GET(L1375_ui_TargetRGBColor, MASK0x0700_RED_COMPONENT)) {
                                L1374_ui_CurrentRGBColor += 256;
                        }
                        L1378_pui_PaletteRegister[L1376_i_Color] = L1374_ui_CurrentRGBColor;
                }
        }
        Super(L1379_l_SupervisorStack);
}

VOID F437_xxxx_STARTEND_DrawTitle()
{
        register int L1380_i_Counter;
        register unsigned int L1381_ui_DestinationHeight;
        register int L1382_i_DestinationPixelWidth;
        register long L1383_l_Bitmap_TitleSteps;
        register unsigned char* L1384_puc_Bitmap_Title;
        register unsigned char* L1385_puc_Bitmap_LogicalScreenBase;
        unsigned char* L1386_apuc_Bitmap_Screens[2]; /* Two buffers in order to use the 'double buffering' technique (display a buffer on screen while preparing the next image in the other buffer) */
        unsigned char* L1387_apuc_Bitmap_ShrinkedTitle[20]; /* Only the first 18 entries are actually used */
        unsigned char* L1388_puc_Bitmap_Temporary;
        unsigned char* L1389_puc_Bitmap_StrikesBack;
        int L1390_i_Unreferenced; /* BUG0_00 Useless code */
        int L1391_aai_Coordinates[21][5]; /* Only the first 18 entries are actually used */
        unsigned int L1392_aui_Palette[16];


        G578_B_UseByteBoxCoordinates = FALSE;
        if (G648_l_AvailableHeapMemoryByteCount < C5004_LZW_TEMPORARY_BUFFER_BYTE_COUNT + 133056) {
                return;
        }
        L1383_l_Bitmap_TitleSteps = (long)F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(320, 200) + /* Title bitmap */
                                                                          M75_BITMAP_BYTE_COUNT(320, 57) +  /* 'master' or 'strikes back' part of title bitmap */
                                                                          M75_BITMAP_BYTE_COUNT(48, 12) +   /* Zoom step 0 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(64, 16) +   /* Zoom step 1 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(80, 20) +   /* Zoom step 2 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(96, 24) +   /* Zoom step 3 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(112, 28) +  /* Zoom step 4 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(128, 32) +  /* Zoom step 5 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(144, 36) +  /* Zoom step 6 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(160, 40) +  /* Zoom step 7 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(176, 44) +  /* Zoom step 8 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(192, 48) +  /* Zoom step 9 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(208, 52) +  /* Zoom step 10 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(224, 56) +  /* Zoom step 11 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(240, 60) +  /* Zoom step 12 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(256, 64) +  /* Zoom step 13 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(272, 68) +  /* Zoom step 14 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(288, 72) +  /* Zoom step 15 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(304, 76) +  /* Zoom step 16 of 'Dungeon' or 'Chaos' */
                                                                          M75_BITMAP_BYTE_COUNT(320, 80) +  /* Zoom step 17 of 'Dungeon' or 'Chaos' */
                                                                          256,                             /* Padding to allow memory alignment on a 256 bytes boundary. Required for the screen memory address on Atari ST */
                                                                    C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP); /* Total memory size allocated = 133056 bytes */
        L1383_l_Bitmap_TitleSteps += 256;
        L1383_l_Bitmap_TitleSteps &= 0xFFFFFF00; /* Make sure the screen memory buffer is aligned on a 256 bytes boundary */
        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(C001_GRAPHIC_TITLE, L1384_puc_Bitmap_Title = (unsigned char*)L1383_l_Bitmap_TitleSteps, 0, 0);
        L1383_l_Bitmap_TitleSteps += M75_BITMAP_BYTE_COUNT(320, 200);
        L1385_puc_Bitmap_LogicalScreenBase = L1386_apuc_Bitmap_Screens[1] = (unsigned char*)G348_pl_Bitmap_LogicalScreenBase;
        L1388_puc_Bitmap_Temporary = L1386_apuc_Bitmap_Screens[0] = L1384_puc_Bitmap_Title;
        F010_aAA7_MAIN_WriteSpacedWords(L1392_aui_Palette, 16, C0x0002_RGB_DARK_BLUE, sizeof(int));
        F436_xxxx_STARTEND_FadeToPalette(L1392_aui_Palette);
        F008_aA19_MAIN_ClearBytes(L1385_puc_Bitmap_LogicalScreenBase, M75_BITMAP_BYTE_COUNT(320, 200));
        F132_xzzz_VIDEO_Blit(L1384_puc_Bitmap_Title, G348_pl_Bitmap_LogicalScreenBase, &G005_s_Graphic562_Box_Title_Presents, 0, 137, C160_BYTE_WIDTH_SCREEN, C160_BYTE_WIDTH_SCREEN, CM1_COLOR_NO_TRANSPARENCY);
        L1392_aui_Palette[15] = C0x0777_RGB_WHITE;
        F436_xxxx_STARTEND_FadeToPalette(L1392_aui_Palette);
        F132_xzzz_VIDEO_Blit(L1384_puc_Bitmap_Title, L1389_puc_Bitmap_StrikesBack = (unsigned char*)L1383_l_Bitmap_TitleSteps, &G004_s_Graphic562_Box_Title_StrikesBack_Source, 0, 80, C160_BYTE_WIDTH_SCREEN, C160_BYTE_WIDTH_SCREEN, CM1_COLOR_NO_TRANSPARENCY);
        L1383_l_Bitmap_TitleSteps += M75_BITMAP_BYTE_COUNT(320, 57);
        L1381_ui_DestinationHeight = 12;
        L1382_i_DestinationPixelWidth = 48;
        for(L1380_i_Counter = 0; L1380_i_Counter < 18; L1380_i_Counter++) {
                L1387_apuc_Bitmap_ShrinkedTitle[L1380_i_Counter] = (unsigned char*)L1383_l_Bitmap_TitleSteps;
                F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(L1384_puc_Bitmap_Title, L1383_l_Bitmap_TitleSteps, 320, 80, L1382_i_DestinationPixelWidth, L1381_ui_DestinationHeight, G017_auc_Graphic562_PaletteChanges_NoChanges);
                L1391_aai_Coordinates[L1380_i_Counter][C1_X2] = (L1391_aai_Coordinates[L1380_i_Counter][C0_X1] = (320 - L1382_i_DestinationPixelWidth) / 2) + L1382_i_DestinationPixelWidth - 1;
                L1391_aai_Coordinates[L1380_i_Counter][C3_Y2] = (L1391_aai_Coordinates[L1380_i_Counter][C2_Y1] = ((int)(160 - L1381_ui_DestinationHeight)) / 2) + L1381_ui_DestinationHeight - 1;
                L1383_l_Bitmap_TitleSteps += (L1391_aai_Coordinates[L1380_i_Counter][C4_SCALE] = ((L1382_i_DestinationPixelWidth + 15) / 16) * 8) * L1381_ui_DestinationHeight;
                L1381_ui_DestinationHeight += 4;
                L1382_i_DestinationPixelWidth += 16;
        }
        L1392_aui_Palette[15] = C0x0002_RGB_DARK_BLUE;
        F436_xxxx_STARTEND_FadeToPalette(L1392_aui_Palette);
        F008_aA19_MAIN_ClearBytes(L1388_puc_Bitmap_Temporary, M75_BITMAP_BYTE_COUNT(320, 200));
        Setscreen(CM1L_NO_CHANGE, L1388_puc_Bitmap_Temporary, CM1_NO_RESOLUTION_CHANGE); /* Do not change logical screen address, change physical screen address, do not change screen mode */
        F008_aA19_MAIN_ClearBytes(L1385_puc_Bitmap_LogicalScreenBase, M75_BITMAP_BYTE_COUNT(320, 200));
        Setscreen(CM1L_NO_CHANGE, L1385_puc_Bitmap_LogicalScreenBase, CM1_NO_RESOLUTION_CHANGE); /* Do not change logical screen address, change physical screen address, do not change screen mode */
        L1392_aui_Palette[3] = C0x0541_RGB_DARK_GOLD;
        L1392_aui_Palette[4] = C0x0421_RGB_LIGHT_BROWN;
        L1392_aui_Palette[5] = C0x0651_RGB_GOLD;
        L1392_aui_Palette[6] = C0x0531_RGB_LIGHTER_BROWN;
        L1392_aui_Palette[8] = C0x0772_RGB_YELLOW;
        L1392_aui_Palette[15] = C0x0700_RGB_RED;
        L1392_aui_Palette[10] = C0x0002_RGB_DARK_BLUE;
        L1392_aui_Palette[12] = C0x0002_RGB_DARK_BLUE;
        F436_xxxx_STARTEND_FadeToPalette(L1392_aui_Palette);
        for(L1380_i_Counter = 0; L1380_i_Counter < 18; L1380_i_Counter++) {
                Vsync();
                F132_xzzz_VIDEO_Blit(L1387_apuc_Bitmap_ShrinkedTitle[L1380_i_Counter], L1386_apuc_Bitmap_Screens[L1380_i_Counter & 0x0001], L1391_aai_Coordinates[L1380_i_Counter], 0, 0, L1391_aai_Coordinates[L1380_i_Counter][C4_BYTE_WIDTH], C160_BYTE_WIDTH_SCREEN, CM1_COLOR_NO_TRANSPARENCY);
                Setscreen(CM1L_NO_CHANGE, L1386_apuc_Bitmap_Screens[L1380_i_Counter & 0x0001], CM1_NO_RESOLUTION_CHANGE); /* Do not change logical screen address, change physical screen address, do not change screen mode */
        }
        Vsync();
        Vsync();
        F132_xzzz_VIDEO_Blit(L1389_puc_Bitmap_StrikesBack, G348_pl_Bitmap_LogicalScreenBase, &G003_s_Graphic562_Box_Title_StrikesBack_Destination, 0, 0, C160_BYTE_WIDTH_SCREEN, C160_BYTE_WIDTH_SCREEN, C00_COLOR_BLACK);
        L1392_aui_Palette[10] = C0x0000_RGB_BLACK;
        L1392_aui_Palette[12] = C0x0700_RGB_RED;
        F436_xxxx_STARTEND_FadeToPalette(L1392_aui_Palette);
        Vsync(); /* BUG0_71 Some timings are too short on fast computers. After the zoom effect, the title screen is quickly replaced by the entrance screen on a fast computer because the execution speed is not limited */
        F469_rzzz_MEMORY_FreeAtHeapTop(133056L);
}

VOID F438_xxxx_STARTEND_OpenEntranceDoors()
{
        register unsigned int L1393_ui_AnimationStep;
        register unsigned char** L1394_ppuc_Bitmap_EntranceDoorAnimationSteps;
        long* L1395_pl_Bitmap_EntranceDoor;
        unsigned char* L1396_pc_Bitmap_DungeonView;


        L1394_ppuc_Bitmap_EntranceDoorAnimationSteps = G562_apuc_Bitmap_EntranceDoorAnimationSteps;
        L1395_pl_Bitmap_EntranceDoor = G348_pl_Bitmap_LogicalScreenBase + (M75_BITMAP_BYTE_COUNT(320, 30) / sizeof(long)); /* This adds 4800 bytes = 9600 pixels = 30 lines of 320 pixels */
        L1396_pc_Bitmap_DungeonView = (unsigned char*)L1394_ppuc_Bitmap_EntranceDoorAnimationSteps[9];
        L1393_ui_AnimationStep = 1;
        do {
                if ((L1393_ui_AnimationStep % 3) == 1) {
                        F060_AA29_SOUND_Play(G565_puc_Graphic535_Sound02DoorRattle, 145, TRUE);
                }
                F007_aAA7_MAIN_CopyBytes(L1394_ppuc_Bitmap_EntranceDoorAnimationSteps[8], L1394_ppuc_Bitmap_EntranceDoorAnimationSteps[9], M75_BITMAP_BYTE_COUNT(128, 161) * 2);
                F132_xzzz_VIDEO_Blit(G296_puc_Bitmap_Viewport, L1394_ppuc_Bitmap_EntranceDoorAnimationSteps[9], &G006_s_Graphic562_Box_Entrance_DungeonView, 0, 0, C112_BYTE_WIDTH_VIEWPORT, C128_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
                if ((int)G007_s_Graphic562_Box_Entrance_OpeningDoorLeft.X2 >= 0) {
                        F132_xzzz_VIDEO_Blit(L1394_ppuc_Bitmap_EntranceDoorAnimationSteps[L1393_ui_AnimationStep & 0x0003], L1394_ppuc_Bitmap_EntranceDoorAnimationSteps[9], &G007_s_Graphic562_Box_Entrance_OpeningDoorLeft, (L1393_ui_AnimationStep & 0x00FC) << 2, 0, C064_BYTE_WIDTH, C128_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
                        G007_s_Graphic562_Box_Entrance_OpeningDoorLeft.X2 -= 4;
                }
                F132_xzzz_VIDEO_Blit(L1394_ppuc_Bitmap_EntranceDoorAnimationSteps[4 + (L1393_ui_AnimationStep & 0x0003)], L1394_ppuc_Bitmap_EntranceDoorAnimationSteps[9], &G008_s_Graphic562_Box_Entrance_OpeningDoorRight, (L1393_ui_AnimationStep & 0x0003) << 2, 0, C064_BYTE_WIDTH, C128_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
                G008_s_Graphic562_Box_Entrance_OpeningDoorRight.X1 += 4;
                Vsync(); /* BUG0_71 Some timings are too short on fast computers. When the player clicks on 'Enter' on the entrance screen, the doors open to quickly on a fast computer because the execution speed is not limited */
                asm {
                                movem.l D4-D7/A2-A6,-(A7)               /* Backup registers D4-D7/A2-A6 to the stack */
                                movea.l L1395_pl_Bitmap_EntranceDoor(A6),A0
                                movea.l L1396_pc_Bitmap_DungeonView(A6),A1
                                move.w  #160,D0                         /* Number of columns of pixels to copy between the two doors */
                        T438_004:
                                movem.l (A1)+,D1-D7/A2-A6               /* Load 48 bytes from (A1) into registers */
                                movem.l D1-D7/A2-A6,(A0)                /* Copy 48 bytes from registers to (A0) */
                                movem.l (A1)+,D1-D7/A2-A6               /* Load 48 bytes from (A1) into registers */
                                movem.l D1-D7/A2-A6,48(A0)              /* Copy 48 bytes from registers to 48(A0) */
                                movem.l (A1)+,D1-D4                     /* Load 16 bytes from (A1) into registers */
                                movem.l D1-D4,96(A0)                    /* Copy 16 bytes from registers to 96(A0). 48 + 48 + 16 = 112 bytes = 224 pixels (width of dungeon view) */
                                move.b  (A1),112(A0)
                                move.b  2(A1),114(A0)
                                move.b  4(A1),116(A0)
                                move.b  6(A1),118(A0)
                                lea     160(A0),A0
                                lea     16(A1),A1
                                dbf     D0,T438_004
                                movem.l (A7)+,D4-D7/A2-A6               /* Restore registers D4-D7/A2-A6 from the stack */
                }
        } while (++L1393_ui_AnimationStep != 32);
}

VOID F439_xxxx_STARTEND_DrawEntrance()
{
        register unsigned int L1397_ui_ColumnIndex;
        unsigned char* L1398_apuc_MicroDungeonCurrentMapData[32]; /* A micro dungeon (5x5 squares) is built in memory to draw the dungeon view behind the opening entrance doors (the actual dungeon is not loaded at this point) */
        unsigned char L1399_auc_MicroDungeonSquares[25];
        MAP L1400_s_MicroDungeonMap;


        G309_i_PartyMapIndex = C255_MAP_INDEX_ENTRANCE;
        G297_B_DrawFloorAndCeilingRequested = TRUE;
        G273_i_CurrentMapWidth = 5;
        G274_i_CurrentMapHeight = 5;
        G271_ppuc_CurrentMapData = &L1398_apuc_MicroDungeonCurrentMapData;
        G269_ps_CurrentMap = &L1400_s_MicroDungeonMap; /* BUG0_00 Useless code. Use of uninitialized variable L1400_s_MicroDungeonMap. No consequence as G269_ps_CurrentMap is not used while drawing the dungeon view except when checking whether random ornaments are allowed but no square in the micro dungeon allow random ornament */
        F009_aA49_MAIN_WriteSpacedBytes(L1399_auc_MicroDungeonSquares, 25, M35_SQUARE(C00_ELEMENT_WALL, 0), sizeof(char));
        for(L1397_ui_ColumnIndex = 0; L1397_ui_ColumnIndex < 5; L1397_ui_ColumnIndex++) {
                L1398_apuc_MicroDungeonCurrentMapData[L1397_ui_ColumnIndex] = &L1399_auc_MicroDungeonSquares[L1397_ui_ColumnIndex * 5];
                L1399_auc_MicroDungeonSquares[L1397_ui_ColumnIndex + 10] = M35_SQUARE(C01_ELEMENT_CORRIDOR, 0);
        }
        L1399_auc_MicroDungeonSquares[7] = M35_SQUARE(C01_ELEMENT_CORRIDOR, 0);
        F436_xxxx_STARTEND_FadeToPalette(G345_aui_BlankBuffer);
        F466_rzzz_EXPAND_GraphicToBitmap(G563_puc_Graphic4_InterfaceEntranceScreen, G348_pl_Bitmap_LogicalScreenBase, 0, 0);
        F128_rzzz_DUNGEONVIEW_Draw_COPYPROTECTIONF(C2_DIRECTION_SOUTH, 2, 0);
        G324_B_DrawViewportRequested = FALSE;
        G578_B_UseByteBoxCoordinates = FALSE, F132_xzzz_VIDEO_Blit(G348_pl_Bitmap_LogicalScreenBase, G562_apuc_Bitmap_EntranceDoorAnimationSteps[8], &G009_s_Graphic562_Box_Entrance_Doors, 0, 30, C160_BYTE_WIDTH_SCREEN, C128_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
        F021_a002_MAIN_BlitToScreen(G562_apuc_Bitmap_EntranceDoorAnimationSteps[0], &G010_s_Graphic562_Box_Entrance_ClosedDoorLeft, C064_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
        F021_a002_MAIN_BlitToScreen(G562_apuc_Bitmap_EntranceDoorAnimationSteps[4], &G011_s_Graphic562_Box_Entrance_ClosedDoorRight, C064_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
        F436_xxxx_STARTEND_FadeToPalette(G020_aui_Graphic562_Palette_Entrance);
}

long F440_xxxx_STARTEND_GetTemporarilyLoadedGraphicByteCount(P850_i_GraphicIndex, P851_ppuc_Graphic)
int P850_i_GraphicIndex;
unsigned char** P851_ppuc_Graphic;
{
        long L1401_l_GraphicDecompressedByteCount;


        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(P850_i_GraphicIndex | MASK0x8000_NOT_EXPANDED, *P851_ppuc_Graphic = F468_ozzz_MEMORY_Allocate(L1401_l_GraphicDecompressedByteCount = (long)F494_ozzz_MEMORY_GetGraphicDecompressedByteCount(P850_i_GraphicIndex), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP), 0, 0);
        return L1401_l_GraphicDecompressedByteCount;
}

VOID F441_xxxx_STARTEND_ProcessEntrance()
{
        register unsigned int L1402_ui_AnimationStep;
        register long L1403_l_ByteCount;
        register int L1404_i_Unreferenced; /* BUG0_00 Useless code */
        BOX_WORD L1405_s_Box;


        G441_ps_PrimaryMouseInput = G445_as_Graphic561_PrimaryMouseInput_Entrance;
        G442_ps_SecondaryMouseInput = NULL;
        G443_ps_PrimaryKeyboardInput = NULL;
        G444_ps_SecondaryKeyboardInput = NULL;
        for(L1402_ui_AnimationStep = 0; L1402_ui_AnimationStep < 8; L1402_ui_AnimationStep++) {
                G562_apuc_Bitmap_EntranceDoorAnimationSteps[L1402_ui_AnimationStep] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(128, 161), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        }
        G562_apuc_Bitmap_EntranceDoorAnimationSteps[8] = F468_ozzz_MEMORY_Allocate((long)(M75_BITMAP_BYTE_COUNT(128, 161) * 2), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        G562_apuc_Bitmap_EntranceDoorAnimationSteps[9] = F468_ozzz_MEMORY_Allocate((long)(M75_BITMAP_BYTE_COUNT(128, 161) * 2), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(C003_GRAPHIC_ENTRANCE_RIGHT_DOOR, G562_apuc_Bitmap_EntranceDoorAnimationSteps[4], 0, 0);
        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(C002_GRAPHIC_ENTRANCE_LEFT_DOOR, G562_apuc_Bitmap_EntranceDoorAnimationSteps[0], 0, 0);
        L1403_l_ByteCount = F440_xxxx_STARTEND_GetTemporarilyLoadedGraphicByteCount(C004_GRAPHIC_ENTRANCE, &G563_puc_Graphic4_InterfaceEntranceScreen);
        L1403_l_ByteCount += F440_xxxx_STARTEND_GetTemporarilyLoadedGraphicByteCount(C005_GRAPHIC_CREDITS, &G564_puc_Graphic5_InterfaceCredits);
        L1403_l_ByteCount += F440_xxxx_STARTEND_GetTemporarilyLoadedGraphicByteCount(C535_GRAPHIC_SOUND_SWITCH, &G565_puc_Graphic535_Sound02DoorRattle);
        L1403_l_ByteCount += F440_xxxx_STARTEND_GetTemporarilyLoadedGraphicByteCount(C534_GRAPHIC_SOUND_DOOR_RATTLE, &G566_puc_Graphic534_Sound01Switch);
        F478_gzzz_MEMORY_CloseGraphicsDat_COPYPROTECTIONDF();
        G578_B_UseByteBoxCoordinates = FALSE;
        L1405_s_Box.X1 = 0;
        L1405_s_Box.X2 = 100;
        L1405_s_Box.Y1 = 0;
        L1405_s_Box.Y2 = 160;
        for(L1402_ui_AnimationStep = 1; L1402_ui_AnimationStep < 4; L1402_ui_AnimationStep++) {
                F132_xzzz_VIDEO_Blit(G562_apuc_Bitmap_EntranceDoorAnimationSteps[0], G562_apuc_Bitmap_EntranceDoorAnimationSteps[L1402_ui_AnimationStep], &L1405_s_Box, L1402_ui_AnimationStep << 2, 0, C064_BYTE_WIDTH, C064_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
                L1405_s_Box.X2 -= 4;
        }
        L1405_s_Box.X2 = 127;
        for(L1402_ui_AnimationStep = 5; L1402_ui_AnimationStep < 8; L1402_ui_AnimationStep++) {
                L1405_s_Box.X1 += 4;
                F132_xzzz_VIDEO_Blit(G562_apuc_Bitmap_EntranceDoorAnimationSteps[4], G562_apuc_Bitmap_EntranceDoorAnimationSteps[L1402_ui_AnimationStep], &L1405_s_Box, 0, 0, C064_BYTE_WIDTH, C064_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
        }
        do {
                F439_xxxx_STARTEND_DrawEntrance();
                F078_xzzz_MOUSE_ShowPointer();
                F357_qzzz_COMMAND_DiscardAllInput();
                G298_B_NewGame = C099_MODE_WAITING_ON_ENTRANCE;
                do {
                        Vsync();
                        F380_xzzz_COMMAND_ProcessQueue_COPYPROTECTIONC();
                } while (G298_B_NewGame == C099_MODE_WAITING_ON_ENTRANCE);
        } while (G298_B_NewGame == C202_MODE_ENTRANCE_DRAW_CREDITS);
        F060_AA29_SOUND_Play(G566_puc_Graphic534_Sound01Switch, 112, TRUE);
        F022_aaaU_MAIN_Delay(20);
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        if (G298_B_NewGame) {
                F438_xxxx_STARTEND_OpenEntranceDoors();
        }
        F469_rzzz_MEMORY_FreeAtHeapTop(L1403_l_ByteCount + (8 * M75_BITMAP_BYTE_COUNT(128, 161)) + ((M75_BITMAP_BYTE_COUNT(128, 161) * 2) + (M75_BITMAP_BYTE_COUNT(128, 161) * 2)));
}

VOID F442_AA08_STARTEND_ProcessCommand202_EntranceDrawCredits()
{
        int L1406_i_VerticalBlankCount;


        L1406_i_VerticalBlankCount = 1800;
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        F436_xxxx_STARTEND_FadeToPalette(G345_aui_BlankBuffer);
        F466_rzzz_EXPAND_GraphicToBitmap(G564_puc_Graphic5_InterfaceCredits, G348_pl_Bitmap_LogicalScreenBase, 0, 0);
        F436_xxxx_STARTEND_FadeToPalette(G019_aui_Graphic562_Palette_Credits);
        do {
                Vsync();
        } while (--L1406_i_VerticalBlankCount && !G588_i_MouseButtonsStatus && !Cconis());
        G298_B_NewGame = C202_MODE_ENTRANCE_DRAW_CREDITS;
}

VOID F443_xxxx_STARTEND_EndgamePrintString(P852_i_X, P853_i_Y, P854_i_TextColor, P855_pc_String)
int P852_i_X;
int P853_i_Y;
int P854_i_TextColor;
register char* P855_pc_String;
{
        register char* L1407_pc_Character;
        char L1408_ac_ModifiedString[50];


        for(L1407_pc_Character = L1408_ac_ModifiedString; *L1407_pc_Character = *P855_pc_String++; L1407_pc_Character++) {
                if ((*L1407_pc_Character >= 'A') && (*L1407_pc_Character <= 'Z')) {
                        *L1407_pc_Character -= 64; /* Use the same font as the one used for scrolls */
                }
        }
        F053_aajz_TEXT_PrintToLogicalScreen(P852_i_X , P853_i_Y, P854_i_TextColor, C12_COLOR_DARKEST_GRAY, L1408_ac_ModifiedString);
}

VOID F444_AA29_STARTEND_Endgame(P856_B_DoNotDrawCreditsOnly)
BOOLEAN P856_B_DoNotDrawCreditsOnly;
{
        register int L1409_i_Multiple;
#define A1409_i_Color              L1409_i_Multiple
#define A1409_i_ChampionIndex      L1409_i_Multiple
#define A1409_i_VerticalBlankCount L1409_i_Multiple
        register int L1410_i_Multiple;
#define A1410_i_Counter L1410_i_Multiple
#define A1410_i_Y       L1410_i_Multiple
        register int L1411_i_Multiple;
#define A1411_i_X          L1411_i_Multiple
#define A1411_i_SkillIndex L1411_i_Multiple
        register int L1412_i_SkillLevel;
        register unsigned char* L1413_puc_TemporaryBuffer;
        register unsigned char* L1414_puc_Bitmap_TheEnd;
        char L1415_c_ChampionTitleFirstCharacter;
        CHAMPION* L1416_ps_Champion;
        unsigned char* L1417_puc_Graphic_Credits;
        unsigned char* L1418_puc_Bitmap_ChampionMirror;
        unsigned int L1419_aui_Palette[16];
        unsigned int L1420_aui_Palette_TopAndBottomScreen[16];
        unsigned int L1421_aui_Palette_DarkBlue[16];
        char L1422_ac_String[20];
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_37_IMPROVEMENT */
        BOOLEAN L1423_B_WaitBeforeDrawingRestart; /* BUG0_00 Useless code */


        L1423_B_WaitBeforeDrawingRestart = TRUE; /* BUG0_00 Useless code */
#endif
        F067_aaat_MOUSE_SetPointerToNormal(C0_POINTER_ARROW);
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        G441_ps_PrimaryMouseInput = NULL;
        G442_ps_SecondaryMouseInput = NULL;
        G443_ps_PrimaryKeyboardInput = NULL;
        G444_ps_SecondaryKeyboardInput = NULL;
        if (P856_B_DoNotDrawCreditsOnly && !G302_B_GameWon) {
                F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C06_SOUND_SCREAM, G306_i_PartyMapX, G307_i_PartyMapY, C00_MODE_PLAY_IMMEDIATELY);
                F022_aaaU_MAIN_Delay(240);
        }
        F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(C0_DO_NOT_FORCE_DIALOG_DM_CSB, FALSE);
        F477_izzz_MEMORY_OpenGraphicsDat_COPYPROTECTIONDF();
        L1413_puc_TemporaryBuffer = G088_apuc_Bitmap_WallSet[C10_WALL_BITMAP_WALL_D1LCR];
        if (P856_B_DoNotDrawCreditsOnly) {
                L1414_puc_Bitmap_TheEnd = L1413_puc_TemporaryBuffer;
                L1413_puc_TemporaryBuffer += M75_BITMAP_BYTE_COUNT(80, 14);
                F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(C006_GRAPHIC_THE_END, L1414_puc_Bitmap_TheEnd, 0, 0);
                if (G302_B_GameWon) {
                        L1418_puc_Bitmap_ChampionMirror = L1413_puc_TemporaryBuffer;
                        L1413_puc_TemporaryBuffer += M75_BITMAP_BYTE_COUNT(64, 43);
                        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(C208_GRAPHIC_WALL_ORNAMENT_43_CHAMPION_MIRROR, L1418_puc_Bitmap_ChampionMirror, 0, 0);
                }
        }
        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(MASK0x8000_NOT_EXPANDED | C005_GRAPHIC_CREDITS, L1417_puc_Graphic_Credits = L1413_puc_TemporaryBuffer, 0, 0);
        F478_gzzz_MEMORY_CloseGraphicsDat_COPYPROTECTIONDF();
        if (G322_B_PaletteSwitchingEnabled) {
                F007_aAA7_MAIN_CopyBytes(G347_aui_Palette_TopAndBottomScreen, L1420_aui_Palette_TopAndBottomScreen, sizeof(G347_aui_Palette_TopAndBottomScreen));
                for(A1410_i_Counter = 0; A1410_i_Counter <= 7; A1410_i_Counter++) {
                        Vsync();
                        for(A1409_i_Color = 0; A1409_i_Color < 16; A1409_i_Color++) {
                                G346_aui_Palette_MiddleScreen[A1409_i_Color] = F431_xxxx_STARTEND_GetDarkenedColor(G346_aui_Palette_MiddleScreen[A1409_i_Color]);
                                G347_aui_Palette_TopAndBottomScreen[A1409_i_Color] = F431_xxxx_STARTEND_GetDarkenedColor(G347_aui_Palette_TopAndBottomScreen[A1409_i_Color]);
                        }
                }
                G322_B_PaletteSwitchingEnabled = FALSE;
                Vsync();
                F007_aAA7_MAIN_CopyBytes(L1420_aui_Palette_TopAndBottomScreen, G347_aui_Palette_TopAndBottomScreen, sizeof(L1420_aui_Palette_TopAndBottomScreen));
        } else {
                F436_xxxx_STARTEND_FadeToPalette(G345_aui_BlankBuffer);
        }
        if (P856_B_DoNotDrawCreditsOnly) {
                if (G302_B_GameWon) {
                        F134_zzzz_VIDEO_FillBitmap(G348_pl_Bitmap_LogicalScreenBase, C12_COLOR_DARKEST_GRAY, M76_BITMAP_UNIT_COUNT(320, 200));
                        for(A1409_i_ChampionIndex = C00_CHAMPION_FIRST; A1409_i_ChampionIndex < G305_ui_PartyChampionCount; A1409_i_ChampionIndex++) {
                                A1410_i_Y = A1409_i_ChampionIndex * 48;
                                L1416_ps_Champion = &G407_s_Party.Champions[A1409_i_ChampionIndex];
                                F021_a002_MAIN_BlitToScreen(L1418_puc_Bitmap_ChampionMirror, &G015_s_Graphic562_Box_Endgame_ChampionMirror, C032_BYTE_WIDTH, C10_COLOR_FLESH);
                                F021_a002_MAIN_BlitToScreen(L1416_ps_Champion->Portrait, &G016_s_Graphic562_Box_Endgame_ChampionPortrait, C016_BYTE_WIDTH, C01_COLOR_DARK_GRAY);
                                F443_xxxx_STARTEND_EndgamePrintString(87, A1410_i_Y += 14, C09_COLOR_GOLD, L1416_ps_Champion->Name);
                                A1411_i_X = (6 * strlen(L1416_ps_Champion->Name)) + 87;
                                L1415_c_ChampionTitleFirstCharacter = L1416_ps_Champion->Title[0];
                                if ((L1415_c_ChampionTitleFirstCharacter != ',') && (L1415_c_ChampionTitleFirstCharacter != ';') && (L1415_c_ChampionTitleFirstCharacter != '-')) {
                                        A1411_i_X += 6;
                                }
                                F443_xxxx_STARTEND_EndgamePrintString(A1411_i_X, A1410_i_Y++, C09_COLOR_GOLD, L1416_ps_Champion->Title);
                                for(A1411_i_SkillIndex = C00_SKILL_FIGHTER; A1411_i_SkillIndex <= C03_SKILL_WIZARD; A1411_i_SkillIndex++) {
                                        L1412_i_SkillLevel = F024_aatz_MAIN_GetMinimumValue(16, F303_AA09_CHAMPION_GetSkillLevel(A1409_i_ChampionIndex, A1411_i_SkillIndex | (MASK0x4000_IGNORE_OBJECT_MODIFIERS | MASK0x8000_IGNORE_TEMPORARY_EXPERIENCE)));
                                        if (L1412_i_SkillLevel == 1) {
                                                continue;
                                        }
                                        strcpy(L1422_ac_String, G428_apc_SkillLevelNames[L1412_i_SkillLevel - 2]);
                                        strcat(L1422_ac_String, " ");
                                        strcat(L1422_ac_String, G417_apc_BaseSkillNames[A1411_i_SkillIndex]);
                                        F443_xxxx_STARTEND_EndgamePrintString(105, A1410_i_Y = A1410_i_Y + 8, C13_COLOR_LIGHTEST_GRAY, L1422_ac_String);
                                }
                                G015_s_Graphic562_Box_Endgame_ChampionMirror.Y1 += 48;
                                G015_s_Graphic562_Box_Endgame_ChampionMirror.Y2 += 48;
                                G016_s_Graphic562_Box_Endgame_ChampionPortrait.Y1 += 48;
                                G016_s_Graphic562_Box_Endgame_ChampionPortrait.Y2 += 48;
                        }
                        F436_xxxx_STARTEND_FadeToPalette(L1420_aui_Palette_TopAndBottomScreen);
                        for(;;); /*_Infinite loop_*/
                }
                T444_017:
                F008_aA19_MAIN_ClearBytes(G348_pl_Bitmap_LogicalScreenBase, M75_BITMAP_BYTE_COUNT(320, 200));
                F021_a002_MAIN_BlitToScreen(L1414_puc_Bitmap_TheEnd, &G012_s_Graphic562_Box_Endgame_TheEnd, C040_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
                F010_aAA7_MAIN_WriteSpacedWords(L1421_aui_Palette_DarkBlue, 16, C0x0002_RGB_DARK_BLUE, sizeof(int));
                F007_aAA7_MAIN_CopyBytes(L1421_aui_Palette_DarkBlue, L1419_aui_Palette, sizeof(L1421_aui_Palette_DarkBlue));
                L1419_aui_Palette[15] = C0x0777_RGB_WHITE;
                F436_xxxx_STARTEND_FadeToPalette(L1419_aui_Palette);
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_37_IMPROVEMENT */
                if (L1423_B_WaitBeforeDrawingRestart) { /* BUG0_00 Useless code */
#endif
                        F022_aaaU_MAIN_Delay(300);
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_37_IMPROVEMENT */
                } /* BUG0_00 Useless code */
#endif
                if (G524_B_RestartGameAllowed) {
                        G578_B_UseByteBoxCoordinates = FALSE;
                        F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G013_s_Graphic562_Box_Endgame_Restart_Outer, C01_COLOR_DARK_GRAY, C160_BYTE_WIDTH_SCREEN);
                        F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G014_s_Graphic562_Box_Endgame_Restart_Inner, C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                        F053_aajz_TEXT_PrintToLogicalScreen(110, 154, C04_COLOR_CYAN, C00_COLOR_BLACK, "RESTART THIS GAME");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                        F053_aajz_TEXT_PrintToLogicalScreen(89, 154, C04_COLOR_CYAN, C00_COLOR_BLACK, "DIESES SPIEL NEU STARTEN");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                        F053_aajz_TEXT_PrintToLogicalScreen(107, 154, C04_COLOR_CYAN, C00_COLOR_BLACK, "RECOMMENCER CE JEU");
#endif
                        L1419_aui_Palette[1] = C0x0437_RGB_PINK;
                        L1419_aui_Palette[4] = C0x0777_RGB_WHITE;
                        G441_ps_PrimaryMouseInput = &G446_as_Graphic561_PrimaryMouseInput_RestartGame;
                        F357_qzzz_COMMAND_DiscardAllInput();
                        F078_xzzz_MOUSE_ShowPointer();
                        F436_xxxx_STARTEND_FadeToPalette(L1419_aui_Palette);
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_37_IMPROVEMENT */
                        A1409_i_VerticalBlankCount = 600;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_37_IMPROVEMENT Restart experience improved: the game waits a longer time for the player to click on the 'Restart this game' button before drawing the credits */
                        A1409_i_VerticalBlankCount = 900;
#endif
                        while (--A1409_i_VerticalBlankCount && !G523_B_RestartGameRequested) {
                                F380_xzzz_COMMAND_ProcessQueue_COPYPROTECTIONC();
                                Vsync();
                        }
                        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                        if (G523_B_RestartGameRequested) {
                                F436_xxxx_STARTEND_FadeToPalette(L1421_aui_Palette_DarkBlue);
                                F008_aA19_MAIN_ClearBytes(G348_pl_Bitmap_LogicalScreenBase, M75_BITMAP_BYTE_COUNT(320, 200));
                                F436_xxxx_STARTEND_FadeToPalette(G021_aaui_Graphic562_Palette_DungeonView[0]);
                                F007_aAA7_MAIN_CopyBytes(G021_aaui_Graphic562_Palette_DungeonView[0], G346_aui_Palette_MiddleScreen, sizeof(G346_aui_Palette_MiddleScreen));
                                G298_B_NewGame = C000_MODE_LOAD_SAVED_GAME;
                                if (F435_xxxx_STARTEND_LoadGame_COPYPROTECTIONF() != CM1_LOAD_GAME_FAILURE) {
                                        F462_xxxx_START_StartGame_COPYPROTECTIONF();
                                        G523_B_RestartGameRequested = FALSE;
                                        F078_xzzz_MOUSE_ShowPointer();
                                        F357_qzzz_COMMAND_DiscardAllInput();
                                        return;
                                }
                        }
                }
                F436_xxxx_STARTEND_FadeToPalette(L1421_aui_Palette_DarkBlue);
        }
        F466_rzzz_EXPAND_GraphicToBitmap(L1417_puc_Graphic_Credits, G348_pl_Bitmap_LogicalScreenBase, 0, 0);
        F436_xxxx_STARTEND_FadeToPalette(G019_aui_Graphic562_Palette_Credits);
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_37_IMPROVEMENT Restart experience improved: restart is now possible even after the credits have been drawn by pressing a key or clicking a mouse button */
        while (!G588_i_MouseButtonsStatus && !Cconis());
        if (G524_B_RestartGameAllowed && P856_B_DoNotDrawCreditsOnly) {
                L1423_B_WaitBeforeDrawingRestart = FALSE;
                F436_xxxx_STARTEND_FadeToPalette(L1421_aui_Palette_DarkBlue);
                goto T444_017;
        }
#endif
        for(;;); /*_Infinite loop_*/
}

VOID F445_xxxx_STARTEND_FuseSequenceUpdate()
{
        F261_hzzz_TIMELINE_Process_COPYPROTECTIONEF();
        F128_rzzz_DUNGEONVIEW_Draw_COPYPROTECTIONF(G308_i_PartyDirection, G306_i_PartyMapX, G307_i_PartyMapY);
        F065_aanz_SOUND_PlayPendingSound_COPYPROTECTIOND();
        G313_ul_GameTime++; /* BUG0_71 Some timings are too short on fast computers. The ending animation when Lord Chaos is fused plays too quickly because the execution speed is not limited */
}

VOID F446_zzzz_STARTEND_FuseSequence()
{
        register int L1424_i_Multiple;
#define A1424_B_RemoveFluxcagesFromLoadChaosSquare L1424_i_Multiple
#define A1424_i_Attack                             L1424_i_Multiple
#define A1424_i_CreatureTypeSwitchCount            L1424_i_Multiple
#define A1424_i_MapX                               L1424_i_Multiple
#define A1424_i_TextThingCount                     L1424_i_Multiple
        register int L1425_i_Multiple;
#define A1425_i_FluxcageMapX   L1425_i_Multiple
#define A1425_i_MapY           L1425_i_Multiple
#define A1425_i_CycleCount     L1425_i_Multiple
#define A1425_i_TextThingIndex L1425_i_Multiple
        register int L1426_i_Multiple;
#define A1426_i_FluxcageMapY            L1426_i_Multiple
#define A1426_i_FuseSequenceUpdateCount L1426_i_Multiple
#define A1426_i_TextThingCount          L1426_i_Multiple
        register THING L1427_T_Thing;
        register GROUP* L1428_ps_Group;
        register EXPLOSION* L1429_ps_Explosion;
        THING L1430_T_NextThing;
        int L1431_i_LordChaosMapX;
        int L1432_i_LordChaosMapY;
        THING L1433_T_LordChaosThing;
        char L1434_c_TextFirstCharacter;
        THING L1435_aT_TextThings[8];
        char L1436_ac_String[200];


        G302_B_GameWon = TRUE;
        if (G423_i_InventoryChampionOrdinal) {
                F355_hzzz_INVENTORY_Toggle_COPYPROTECTIONE(C04_CHAMPION_CLOSE_INVENTORY);
        }
        F363_pzzz_COMMAND_HighlightBoxDisable();
        G407_s_Party.MagicalLightAmount = 200;
        F337_akzz_INVENTORY_SetDungeonViewPalette();
        G407_s_Party.FireShieldDefense = G407_s_Party.SpellShieldDefense = G407_s_Party.ShieldDefense = 100;
        F260_pzzz_TIMELINE_RefreshAllChampionStatusBoxes();
        F445_xxxx_STARTEND_FuseSequenceUpdate();
        L1431_i_LordChaosMapX = G306_i_PartyMapX;
        L1432_i_LordChaosMapY = G307_i_PartyMapY;
        L1431_i_LordChaosMapX += G233_ai_Graphic559_DirectionToStepEastCount[G308_i_PartyDirection], L1432_i_LordChaosMapY += G234_ai_Graphic559_DirectionToStepNorthCount[G308_i_PartyDirection];
        L1428_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(L1433_T_LordChaosThing = F175_gzzz_GROUP_GetThing(L1431_i_LordChaosMapX, L1432_i_LordChaosMapY));
        L1428_ps_Group->Health[0] = 10000;
        F146_aczz_DUNGEON_SetGroupCells(L1428_ps_Group, C255_SINGLE_CENTERED_CREATURE, G309_i_PartyMapIndex);
        F148_aayz_DUNGEON_SetGroupDirections(L1428_ps_Group, M18_OPPOSITE(G308_i_PartyDirection), G309_i_PartyMapIndex);
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_20_FIX This code removes Fluxcages from the party square but fails to remove them from the Lord Chaos square */
        L1427_T_Thing = F162_afzz_DUNGEON_GetSquareFirstObject(G306_i_PartyMapX, G307_i_PartyMapY);
        A1424_B_RemoveFluxcagesFromLoadChaosSquare = TRUE;
        T446_002:
        while (L1427_T_Thing != C0xFFFE_THING_ENDOFLIST) {
                L1430_T_NextThing = F159_rzzz_DUNGEON_GetNextThing(L1427_T_Thing);
                if (M12_TYPE(L1427_T_Thing) == C15_THING_TYPE_EXPLOSION) {
                        L1429_ps_Explosion = (EXPLOSION*)F156_afzz_DUNGEON_GetThingData(L1427_T_Thing);
                        if (L1429_ps_Explosion->Type == C050_EXPLOSION_FLUXCAGE) {
                                F164_dzzz_DUNGEON_UnlinkThingFromList(L1427_T_Thing, 0, G306_i_PartyMapX, G307_i_PartyMapY); /* BUG0_59 The game hangs when using the Fuse action on Lord Chaos. If there is a Fluxcage on the square where Lord Chaos stands then it is not removed as it should and this hangs the game while processing the end sequence. In the second pass, this call still removes explosion things from the party square instead of the Lord Chaos square. Here is the process leading to the game hanging: The game finds a Fluxcage explosion on the square where Lord Chaos is standing but it tries to remove it from the party square with this call to F164_dzzz_DUNGEON_UnlinkThingFromList, which fails. The explosion is then marked as unused, but it is still part of the linked list of things on Lord Chaos' square. The first call to F213_hzzz_EXPLOSION_Create below calls F166_szzz_DUNGEON_GetUnusedThing to get an unused explosion thing, which initializes and returns the same thing that is still part of the linked list. F213_hzzz_EXPLOSION_Create then calls F163_amzz_DUNGEON_LinkThingToList to add the explosion at the end of the list. The last thing in the list being the same as the thing being added, this results in an explosion thing linked to itself. This causes an infinite loop the next time that all things on the square are processed in a loop */
                                L1429_ps_Explosion->Next = C0xFFFF_THING_NONE;
                        }
                }
                L1427_T_Thing = L1430_T_NextThing;
        }
        if (A1424_B_RemoveFluxcagesFromLoadChaosSquare) {
                A1424_B_RemoveFluxcagesFromLoadChaosSquare = FALSE;
                L1427_T_Thing = F162_afzz_DUNGEON_GetSquareFirstObject(L1431_i_LordChaosMapX, L1432_i_LordChaosMapY);
                goto T446_002;
        }
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_20_FIX Fluxcages are removed correctly from both the party square and the Lord Chaos square */
        A1424_B_RemoveFluxcagesFromLoadChaosSquare = TRUE;
        A1425_i_FluxcageMapX = G306_i_PartyMapX;
        A1426_i_FluxcageMapY = G307_i_PartyMapY;
        T446_002:
        for(L1427_T_Thing = F162_afzz_DUNGEON_GetSquareFirstObject(A1425_i_FluxcageMapX, A1426_i_FluxcageMapY); L1427_T_Thing != C0xFFFE_THING_ENDOFLIST; L1427_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L1427_T_Thing)) {
                if (M12_TYPE(L1427_T_Thing) == C15_THING_TYPE_EXPLOSION) {
                        L1429_ps_Explosion = (EXPLOSION*)F156_afzz_DUNGEON_GetThingData(L1427_T_Thing);
                        if (L1429_ps_Explosion->Type == C050_EXPLOSION_FLUXCAGE) {
                                F164_dzzz_DUNGEON_UnlinkThingFromList(L1427_T_Thing, 0, A1425_i_FluxcageMapX, A1426_i_FluxcageMapY);
                                L1429_ps_Explosion->Next = C0xFFFF_THING_NONE;
                                goto T446_002;
                        }
                }
        }
        if (A1424_B_RemoveFluxcagesFromLoadChaosSquare) {
                A1424_B_RemoveFluxcagesFromLoadChaosSquare = FALSE;
                A1425_i_FluxcageMapX = L1431_i_LordChaosMapX;
                A1426_i_FluxcageMapY = L1432_i_LordChaosMapY;
                goto T446_002;
        }
#endif
        F445_xxxx_STARTEND_FuseSequenceUpdate();
        for(A1424_i_Attack = 55; A1424_i_Attack <= 255; A1424_i_Attack += 40) {
                F213_hzzz_EXPLOSION_Create(C0xFF80_THING_EXPLOSION_FIREBALL, A1424_i_Attack, L1431_i_LordChaosMapX, L1432_i_LordChaosMapY, C255_SINGLE_CENTERED_CREATURE);
                F445_xxxx_STARTEND_FuseSequenceUpdate();
        }
        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C17_SOUND_BUZZ, L1431_i_LordChaosMapX, L1432_i_LordChaosMapY, C01_MODE_PLAY_IF_PRIORITIZED);
        L1428_ps_Group->Type = C25_CREATURE_LORD_ORDER;
        F445_xxxx_STARTEND_FuseSequenceUpdate();
        for(A1424_i_Attack = 55; A1424_i_Attack <= 255; A1424_i_Attack += 40) {
                F213_hzzz_EXPLOSION_Create(C0xFF83_THING_EXPLOSION_HARM_NON_MATERIAL, A1424_i_Attack, L1431_i_LordChaosMapX, L1432_i_LordChaosMapY, C255_SINGLE_CENTERED_CREATURE);
                F445_xxxx_STARTEND_FuseSequenceUpdate();
        }
        A1425_i_CycleCount = 4;
        while (--A1425_i_CycleCount) {
                A1424_i_CreatureTypeSwitchCount = 5;
                while (--A1424_i_CreatureTypeSwitchCount) {
                        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C17_SOUND_BUZZ, L1431_i_LordChaosMapX, L1432_i_LordChaosMapY, C01_MODE_PLAY_IF_PRIORITIZED);
                        L1428_ps_Group->Type = (A1424_i_CreatureTypeSwitchCount & 0x0001) ? C25_CREATURE_LORD_ORDER : C23_CREATURE_LORD_CHAOS;
                        A1426_i_FuseSequenceUpdateCount = A1425_i_CycleCount;
                        while (A1426_i_FuseSequenceUpdateCount--) {
                                F445_xxxx_STARTEND_FuseSequenceUpdate();
                        }
                }
        }
        F213_hzzz_EXPLOSION_Create(C0xFF80_THING_EXPLOSION_FIREBALL, 255, L1431_i_LordChaosMapX, L1432_i_LordChaosMapY, C255_SINGLE_CENTERED_CREATURE);
        F213_hzzz_EXPLOSION_Create(C0xFF83_THING_EXPLOSION_HARM_NON_MATERIAL, 255, L1431_i_LordChaosMapX, L1432_i_LordChaosMapY, C255_SINGLE_CENTERED_CREATURE);
        F445_xxxx_STARTEND_FuseSequenceUpdate();
        L1428_ps_Group->Type = C26_CREATURE_GREY_LORD;
        F445_xxxx_STARTEND_FuseSequenceUpdate();
        G077_B_DoNotDrawFluxcagesDuringEndgame = TRUE;
        F445_xxxx_STARTEND_FuseSequenceUpdate();
        for(A1424_i_MapX = 0; A1424_i_MapX < G273_i_CurrentMapWidth; A1424_i_MapX++) {
                for(A1425_i_MapY = 0; A1425_i_MapY < G274_i_CurrentMapHeight; A1425_i_MapY++) {
                        if (((L1427_T_Thing = F175_gzzz_GROUP_GetThing(A1424_i_MapX, A1425_i_MapY)) != C0xFFFE_THING_ENDOFLIST) && ((A1424_i_MapX != L1431_i_LordChaosMapX) || (A1425_i_MapY != L1432_i_LordChaosMapY))) {
                                F189_awzz_GROUP_Delete(A1424_i_MapX, A1425_i_MapY);
                        }
                }
        }
        F445_xxxx_STARTEND_FuseSequenceUpdate();
        /* Count and get list of text things located at 0, 0 in the current map. Their text is then printed as messages in the order specified by their first letter (which is not printed) */
        L1427_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(0, 0);
        A1424_i_TextThingCount = 0;
        while (L1427_T_Thing != C0xFFFE_THING_ENDOFLIST) {
                if (M12_TYPE(L1427_T_Thing) == C02_THING_TYPE_TEXT) {
                        L1435_aT_TextThings[A1424_i_TextThingCount++] = L1427_T_Thing;
                }
                L1427_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L1427_T_Thing);
        }
        L1434_c_TextFirstCharacter = 'A';
        A1426_i_TextThingCount = A1424_i_TextThingCount;
        while (A1424_i_TextThingCount--) {
                for(A1425_i_TextThingIndex = 0; A1425_i_TextThingIndex < A1426_i_TextThingCount; A1425_i_TextThingIndex++) {
                        F168_ajzz_DUNGEON_DecodeText(L1436_ac_String, L1435_aT_TextThings[A1425_i_TextThingIndex], C1_TEXT_TYPE_MESSAGE | MASK0x8000_DECODE_EVEN_IF_INVISIBLE);
                        if (L1436_ac_String[1] == L1434_c_TextFirstCharacter) {
                                F043_aahz_TEXT_MESSAGEAREA_ClearAllRows();
                                L1436_ac_String[1] = '\n'; /* New line */
                                F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C15_COLOR_WHITE, &L1436_ac_String[1]);
                                F445_xxxx_STARTEND_FuseSequenceUpdate();
                                F022_aaaU_MAIN_Delay(780);
                                L1434_c_TextFirstCharacter++;
                                break;
                        }
                }
        }
        F022_aaaU_MAIN_Delay(600);
        G524_B_RestartGameAllowed = FALSE;
        F444_AA29_STARTEND_Endgame(TRUE);
}

#ifndef NOCOPYPROTECTION
VOID F447_xxxx_STARTEND_HangIfFalse_COPYPROTECTIONA(P857_B_CommandLineParameterIsAUTO)
BOOLEAN P857_B_CommandLineParameterIsAUTO;
{
        if (!P857_B_CommandLineParameterIsAUTO) {
                for(;;); /*_Infinite loop_*/
        }
}
#endif
