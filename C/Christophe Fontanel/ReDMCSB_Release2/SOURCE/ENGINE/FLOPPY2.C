#include "DEFS.H"

overlay "start"

#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives */
VOID F451_xxxx_FLOPPY_Initialize()
{
        register int L1451_i_FloppyDriveCount;
        register long L1452_l_SupervisorStack;


        L1452_l_SupervisorStack = Super(0L);
        asm {
                move.w  C0x04A6_ADDRESS_SYSTEM_VARIABLE__nflops,L1451_i_FloppyDriveCount
        }
        Super(L1452_l_SupervisorStack);
        if (L1451_i_FloppyDriveCount == 2) {
                G574_i_SaveDiskFloppyDriveIndex = C1_FLOPPY_DRIVE_B;
        } else {
                G567_B_SingleFloppyDrive = TRUE;
        }
        G571_pc_D116_DRIVEA = "DRIVE A:";
        G572_pc_D117_DRIVEB = "DRIVE B:";
}
#endif

#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_03_IMPROVEMENT */
int F452_xxxx_FLOPPY_GetDiskTypeInDrive_COPYPROTECTIONB()
{
        register int L1453_i_DiskType;
        register int L1455_i_GraphicsDatFileReferenceCountBackup;
        register unsigned char* L1456_puc_Buffer_COPYPROTECTIONB;


        if (L1455_i_GraphicsDatFileReferenceCountBackup = G631_i_GraphicsDatFileReferenceCount) {
                G631_i_GraphicsDatFileReferenceCount = 1;
                F478_gzzz_MEMORY_CloseGraphicsDat_COPYPROTECTIONDF();
        }
        L1456_puc_Buffer_COPYPROTECTIONB = F468_ozzz_MEMORY_Allocate(1024L, C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        F450_xxxx_FLOPPY_ForceMediaChangeDetection();
        if (Floprd(L1456_puc_Buffer_COPYPROTECTIONB, C0L_FILLER, C0_FLOPPY_DRIVE_A, C001_SECTOR_1, C0_TRACK_0, C0_SIDE_0, C2_TWO_SECTORS)) {
                L1453_i_DiskType = C3_DISK_TYPE_UNFORMATTED_DISK;
        } else {
                if (!Floprd(L1456_puc_Buffer_COPYPROTECTIONB, C0L_FILLER, C0_FLOPPY_DRIVE_A, C010_SECTOR_10, C0_TRACK_0, C0_SIDE_0, C1_ONE_SECTOR)
#ifndef NOCOPYPROTECTION
                && !Floprd(L1456_puc_Buffer_COPYPROTECTIONB, C0L_FILLER, C0_FLOPPY_DRIVE_A, C247_SECTOR_247, C0_TRACK_0, C0_SIDE_0, C1_ONE_SECTOR) && !strcmp(L1456_puc_Buffer_COPYPROTECTIONB, "Copyright (c) 1987, Software Heaven, Inc.") && !strcmp(&L1456_puc_Buffer_COPYPROTECTIONB[128], "DungeonMaster")
#endif
                ) {
                        L1453_i_DiskType = C0_DISK_TYPE_GAME_DISK;
                } else {
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_20_OPTIMIZATION */
                        if (F449_xxxx_FLOPPY_IsDiskWriteProtected(C0_FLOPPY_DRIVE_A, L1456_puc_Buffer_COPYPROTECTIONB)) {
#endif
#ifdef C18_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE3_20_OPTIMIZATION */
                        if (F449_xxxx_FLOPPY_IsDiskWriteProtected(L1456_puc_Buffer_COPYPROTECTIONB)) {
#endif
                                L1453_i_DiskType = C2_DISK_TYPE_SAVE_DISK_WRITE_PROTECTED;
                        } else {
                                L1453_i_DiskType = C1_DISK_TYPE_SAVE_DISK_WRITE_ENABLED;
                        }
                }
        }
        F469_rzzz_MEMORY_FreeAtHeapTop(1024L);
        if (L1455_i_GraphicsDatFileReferenceCountBackup) {
                F477_izzz_MEMORY_OpenGraphicsDat_COPYPROTECTIONDF();
                G631_i_GraphicsDatFileReferenceCount = L1455_i_GraphicsDatFileReferenceCountBackup;
        }
        return L1453_i_DiskType;
}
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives. Disk type is returned in G568_i_DiskType */
int F452_xxxx_FLOPPY_GetDiskTypeInDrive_COPYPROTECTIONB(P861_i_DriveType)
int P861_i_DriveType;
{
        register int L1453_i_DiskType;
        register int L1454_i_FloppyDriveIndex;
        register int L1455_i_GraphicsDatFileReferenceCountBackup;
        register unsigned char* L1456_puc_Buffer_COPYPROTECTIONB;


        if (P861_i_DriveType == C0_DRIVE_TYPE_NONE) {
                return C4_DISK_TYPE_NO_DISK;
        }
        if (L1455_i_GraphicsDatFileReferenceCountBackup = G631_i_GraphicsDatFileReferenceCount) {
                G631_i_GraphicsDatFileReferenceCount = 1;
                F478_gzzz_MEMORY_CloseGraphicsDat_COPYPROTECTIONDF();
        }
        L1456_puc_Buffer_COPYPROTECTIONB = F468_ozzz_MEMORY_Allocate(1024L, C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        if (P861_i_DriveType == C1_DRIVE_TYPE_GAME_DISK) {
                L1454_i_FloppyDriveIndex = G573_i_GameDiskFloppyDriveIndex;
        } else {
                L1454_i_FloppyDriveIndex = G574_i_SaveDiskFloppyDriveIndex;
        }
        F450_xxxx_FLOPPY_ForceMediaChangeDetection(P861_i_DriveType);
        if (Floprd(L1456_puc_Buffer_COPYPROTECTIONB, C0L_FILLER, L1454_i_FloppyDriveIndex, C001_SECTOR_1, C0_TRACK_0, C0_SIDE_0, C2_TWO_SECTORS)) {
                L1453_i_DiskType = C3_DISK_TYPE_UNFORMATTED_DISK;
        } else {
                if (!Floprd(L1456_puc_Buffer_COPYPROTECTIONB, C0L_FILLER, L1454_i_FloppyDriveIndex, C010_SECTOR_10, C0_TRACK_0, C0_SIDE_0, C1_ONE_SECTOR)
#ifndef NOCOPYPROTECTION
                && !Floprd(L1456_puc_Buffer_COPYPROTECTIONB, C0L_FILLER, L1454_i_FloppyDriveIndex, C247_SECTOR_247, C0_TRACK_0, C0_SIDE_0, C1_ONE_SECTOR) && !strcmp(L1456_puc_Buffer_COPYPROTECTIONB, "Copyright (c) 1987, Software Heaven, Inc.") && !strcmp(&L1456_puc_Buffer_COPYPROTECTIONB[128], "DungeonMaster")
#endif
                ) {
                        L1453_i_DiskType = C0_DISK_TYPE_GAME_DISK;
                } else {
                        if (F449_xxxx_FLOPPY_IsDiskWriteProtected(L1454_i_FloppyDriveIndex, L1456_puc_Buffer_COPYPROTECTIONB)) {
                                L1453_i_DiskType = C2_DISK_TYPE_SAVE_DISK_WRITE_PROTECTED;
                        } else {
                                L1453_i_DiskType = C1_DISK_TYPE_SAVE_DISK_WRITE_ENABLED;
                        }
                }
        }
        F469_rzzz_MEMORY_FreeAtHeapTop(1024L);
        if (L1455_i_GraphicsDatFileReferenceCountBackup) {
                F477_izzz_MEMORY_OpenGraphicsDat_COPYPROTECTIONDF();
                G631_i_GraphicsDatFileReferenceCount = L1455_i_GraphicsDatFileReferenceCountBackup;
        }
        return (G568_i_DiskType = L1453_i_DiskType);
}
#endif

#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_31_IMPROVEMENT */
BOOLEAN F453_xxxx_FLOPPY_IsFormatDiskSuccessful()
{
        register unsigned int L1457_ui_TrackIndex;
        register BOOLEAN L1458_B_IsFormatDiskSuccessful;
        register long L1459_l_ByteCount;
        register unsigned char* L1460_puc_Buffer;


        L1458_B_IsFormatDiskSuccessful = TRUE;
        L1459_l_ByteCount = G648_l_AvailableHeapMemoryByteCount;
        L1460_puc_Buffer = F468_ozzz_MEMORY_Allocate(L1459_l_ByteCount, C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        for(L1457_ui_TrackIndex = 0; L1457_ui_TrackIndex < 80; L1457_ui_TrackIndex++) {
                if (Flopfmt(L1460_puc_Buffer, C0L_FILLER, G574_i_SaveDiskFloppyDriveIndex, C9_SECTORS_PER_TRACK, L1457_ui_TrackIndex, C0_SIDE_0, C1_INTERLEAVE, C0x87654321_MAGIC, (L1457_ui_TrackIndex <= 1) ? 0 : 0xE5E5)) {
                        goto T453_006;
                }
        }
        Protobt(L1460_puc_Buffer, C0x01000001_SERIAL_RANDOM, C2_80_TRACKS_SINGLE_SIDED, C0_DISK_NOT_EXECUTABLE);
        if (Flopwr(L1460_puc_Buffer, C0L_FILLER, G574_i_SaveDiskFloppyDriveIndex, C001_SECTOR_1, C0_TRACK_0, C0_SIDE_0, C1_ONE_SECTOR)) {
                T453_006:
                L1458_B_IsFormatDiskSuccessful = FALSE;
        }
        F469_rzzz_MEMORY_FreeAtHeapTop(L1459_l_ByteCount);
        return L1458_B_IsFormatDiskSuccessful;
}
#endif

#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives */
BOOLEAN F454_xxxx_FLOPPY_IsSaveDiskTypeInSaveDiskDrive(P862_i_SaveDiskType)
int P862_i_SaveDiskType;
{
        register int L1461_i_Multiple;
#define A1461_i_DiskType    L1461_i_Multiple
#define A1461_i_DriveLetter L1461_i_Multiple


        if (P862_i_SaveDiskType == C2_SAVE_DISK_UNFORMATTED_DISK) {
                A1461_i_DiskType = C3_DISK_TYPE_UNFORMATTED_DISK;
        } else {
                G569_pc_SavedGameFileName = &G575_ac_SavedGameFileName;
                G570_pc_SavedGameBackupFileName = &G576_ac_SavedGameBackupFileName;
                if (G567_B_SingleFloppyDrive) {
                        A1461_i_DriveLetter = 'A';
                } else {
                        A1461_i_DriveLetter = 'B';
                }
                G575_ac_SavedGameFileName[0] = A1461_i_DriveLetter;
                G576_ac_SavedGameBackupFileName[0] = A1461_i_DriveLetter;
                A1461_i_DiskType = C1_DISK_TYPE_SAVE_DISK_WRITE_ENABLED;
        }
        if (F452_xxxx_FLOPPY_GetDiskTypeInDrive_COPYPROTECTIONB(C2_DRIVE_TYPE_SAVE_DISK) == A1461_i_DiskType) {
                return TRUE;
        }
        return FALSE;
}
#endif

#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_30_IMPROVEMENT */
VOID F455_xxxx_FLOPPY_DecompressDungeon(P863_puc_CompressedDungeonBuffer, P864_puc_DecompressedDungeonBuffer, P865_l_DecompressedByteCount)
register unsigned char* P863_puc_CompressedDungeonBuffer;
register unsigned char* P864_puc_DecompressedDungeonBuffer;
register long P865_l_DecompressedByteCount;
{
        asm {
                        movea.l P863_puc_CompressedDungeonBuffer,A0                                     /* Address of 2 tables containing: 4 most common bytes / 16 less common bytes */
                        lea     20(P863_puc_CompressedDungeonBuffer),P863_puc_CompressedDungeonBuffer
                        moveq   #0,D1
                T455_001:
                        move.w  (P863_puc_CompressedDungeonBuffer)+,D1                                  /* Get first word of compressed data */
                        moveq   #16,D0                                                                  /* Number of compressed data bits left to process in D1 */
                T455_002_Loop:
                        btst    #15,D1
                        beq.s   T455_004                                                                /* Branch if bit 15 is 0 */
                        moveq   #2,D2                                                                   /* Request 2 bits from compressed data. Can be either 10 or 11 */
                        bsr.s   T455_006_Subroutine
                        subq.w  #2,D1                                                                   /* 2 less bits in D1 */
                        bne.s   T455_003
                        swap    D1
                        moveq   #4,D2                                                                   /* Request 4 bits from compressed data */
                        bsr.s   T455_006_Subroutine
                        move.b  4(A0,D1.w),(P864_puc_DecompressedDungeonBuffer)+                        /* Output 1 byte from the table of 16 less common bytes */
                        bra.s   T455_005
                T455_003:
                        swap    D1
                        moveq   #8,D2                                                                   /* Request 8 bits from compressed data (a byte to output directly) */
                        bsr.s   T455_006_Subroutine
                        move.b  D1,(P864_puc_DecompressedDungeonBuffer)+                                /* Output 1 byte directly from compressed data */
                        bra.s   T455_005
                T455_004:
                        moveq   #3,D2                                                                   /* Request 3 bits from compressed data (first bit is 0, last two bits are an index in table of most common bytes) */
                        bsr.s   T455_006_Subroutine
                        move.b  0(A0,D1.w),(P864_puc_DecompressedDungeonBuffer)+                        /* Output 1 byte from the table of 4 most common bytes */
                T455_005:
                        subq.l  #1,P865_l_DecompressedByteCount                                         /* One less byte of decompressed data to output */
                        beq.s   T455_008_Return                                                         /* Branch if there is no more data to output */
                        clr.w   D1
                        swap    D1
                        tst.w   D0
                        bne.s   T455_002_Loop
                        bra.s   T455_001
                T455_006_Subroutine:
                        cmp.w   D2,D0
                        bpl.s   T455_007                                                                /* Branch if D0 (Number of compressed data bits left to process in D1) >= D2 (Requested bit count) */
                        sub.w   D0,D2
                        lsl.l   D0,D1                                                                   /* Make room in D1 */
                        move.w  (P863_puc_CompressedDungeonBuffer)+,D1                                  /* Get next word of compressed data */
                        moveq   #16,D0                                                                  /* Number of compressed data bits left to process in D1 */
                T455_007:
                        sub.w   D2,D0                                                                   /* Decrease the number of bits left to process */
                        lsl.l   D2,D1                                                                   /* Remove bits left to process from D1 */
                        swap    D1
                        rts
                T455_008_Return:
        }
}
#endif
