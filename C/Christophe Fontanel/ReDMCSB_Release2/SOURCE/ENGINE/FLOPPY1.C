#include "DEFS.H"

overlay "start"

#ifdef C08_COMPILE_DM10aEN_DM10bEN_DM11EN_CSB20EN_CSB21EN /* CHANGE3_20_OPTIMIZATION CHANGE7_03_IMPROVEMENT Support for two floppy disk drives */
BOOLEAN F449_xxxx_FLOPPY_IsDiskWriteProtected(P858_i_FloppyDriveIndex, P859_pc_Buffer)
int P858_i_FloppyDriveIndex;
char* P859_pc_Buffer;
{
        Floprd(P859_pc_Buffer, C0L_FILLER, P858_i_FloppyDriveIndex, C001_SECTOR_1, C0_TRACK_0, C0_SIDE_0, C1_ONE_SECTOR);
        return (Flopwr(P859_pc_Buffer, C0L_FILLER, P858_i_FloppyDriveIndex, C001_SECTOR_1, C0_TRACK_0, C0_SIDE_0, C1_ONE_SECTOR) == CM13_ERROR_EWRPRO_MEDIUM_WRITE_PROTECTED);
}
#endif
#ifdef C18_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE3_20_OPTIMIZATION Removed support for two floppy disk drives in the function to detect if a floppy disk is write protected. This support is reintroduced in CSB for Atari ST 2.0 */
BOOLEAN F449_xxxx_FLOPPY_IsDiskWriteProtected(P859_pc_Buffer)
char* P859_pc_Buffer;
{
        Floprd(P859_pc_Buffer, C0L_FILLER, C0_FLOPPY_DRIVE_A, C001_SECTOR_1, C0_TRACK_0, C0_SIDE_0, C1_ONE_SECTOR);
        return (Flopwr(P859_pc_Buffer, C0L_FILLER, C0_FLOPPY_DRIVE_A, C001_SECTOR_1, C0_TRACK_0, C0_SIDE_0, C1_ONE_SECTOR) == CM13_ERROR_EWRPRO_MEDIUM_WRITE_PROTECTED);
}
#endif

#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_03_IMPROVEMENT */
VOID F450_xxxx_FLOPPY_ForceMediaChangeDetection()
{
        Rwabs(C0_READ_WITH_MEDIA_CHANGE, NULL, C2_TWO_SECTORS, C0_LOGICAL_SECTOR_0, C0_FLOPPY_DRIVE_A);
        Fsfirst("F", C0_FILE_ATTRIBUTES); /* Searches for a file named "F" in the current folder of the default drive */
}
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives. The code of this function is directly inspired by a routine described in the official Atari "Rainbow TOS Release Notes" (First edition Aug 7, 1989 or second edition Mar 5, 1991) in a section named "Forcing 'Media Change'". It will force a "Media Change" even if the floppy disk in the drive has not changed (causing GEMDOS to flush any cached information about the file system) */
VOID F450_xxxx_FLOPPY_ForceMediaChangeDetection(P860_i_DriveType)
int P860_i_DriveType;
{
        register long L1445_l_SupervisorStack;
        register long L1446_l_ReplacementBPBVector;
        int L1447_i_FloppyDriveIndex;
        char* L1448_pc_DefaultBPBVector;
        char* L1449_pc_DefaultMediaChangeVector;
        char* L1450_pc_DefaultRWBlocksVector;
        static char G577_ac_TestFileName[5] = "A:\\F";



        if (P860_i_DriveType != C0_DRIVE_TYPE_NONE) {
                if (P860_i_DriveType == C1_DRIVE_TYPE_GAME_DISK) {;
                        L1447_i_FloppyDriveIndex = G573_i_GameDiskFloppyDriveIndex;
                } else {
                        L1447_i_FloppyDriveIndex = G574_i_SaveDiskFloppyDriveIndex;
                }
                G577_ac_TestFileName[0] = 'A' + L1447_i_FloppyDriveIndex;
                L1445_l_SupervisorStack = Super(0L);
                asm {
                                lea     V450_1_xxx_RegisterA6Backup(PC),A0
                                move.l  A6,(A0)
                                move.l  C0x0472_ADDRESS_SYSTEM_VARIABLE_hdv_bpb,L1448_pc_DefaultBPBVector(A6)                 /* Exception vector to routine that establishes the BPB of a BIOS drive. The drive index is passed on the stack at 4(A7) */
                                move.l  C0x047E_ADDRESS_SYSTEM_VARIABLE_hdv_mediach,L1449_pc_DefaultMediaChangeVector(A6)     /* Vector to routine for establishing the media-change status of a BIOS drive. The drive index is passed on the stack at 4(A7) */
                                move.l  C0x0476_ADDRESS_SYSTEM_VARIABLE_hdv_rw,L1450_pc_DefaultRWBlocksVector(A6)             /* Exception vector to the routine for reading and writing of blocks to BIOS drives. The same parameters are passed on the stack as for Rwabs (starting with 4(A7); rwflag) */
                                lea     T450_003_ReplacementRoutineBPBVector(PC),A0
                                move.l  A0,C0x0472_ADDRESS_SYSTEM_VARIABLE_hdv_bpb                                            /* Replace original vector */
                                move.l  A0,L1446_l_ReplacementBPBVector
                                lea     T450_005_ReplacementRoutineMediaChangeVector(PC),A0
                                move.l  A0,C0x047E_ADDRESS_SYSTEM_VARIABLE_hdv_mediach                                        /* Replace original vector */
                                lea     T450_007_ReplacementRoutineRWBlocks(PC),A0
                                move.l  A0,C0x0476_ADDRESS_SYSTEM_VARIABLE_hdv_rw                                             /* Replace original vector */
                }
                Fopen(G577_ac_TestFileName, C0_READ_ONLY);
                asm {
                        cmp.l   C0x0472_ADDRESS_SYSTEM_VARIABLE_hdv_bpb,L1446_l_ReplacementBPBVector
                        bne.s   T450_010                                                                                /* If the current vector current vector is not the replacement routine */
                        move.l  L1448_pc_DefaultBPBVector(A6),C0x0472_ADDRESS_SYSTEM_VARIABLE_hdv_bpb                   /* Restore original vector */
                        move.l  L1449_pc_DefaultMediaChangeVector(A6),C0x047E_ADDRESS_SYSTEM_VARIABLE_hdv_mediach       /* Restore original vector */
                        move.l  L1450_pc_DefaultRWBlocksVector(A6),C0x0476_ADDRESS_SYSTEM_VARIABLE_hdv_rw               /* Restore original vector */
                        bra.s   T450_010
                        T450_003_ReplacementRoutineBPBVector:
                                movea.l V450_1_xxx_RegisterA6Backup(PC),A0
                                move.w  -2(A0),D0                                                                       /* L1447_i_FloppyDriveIndex */
                                cmp.w   4(A7),D0                                                                        /* Drive index */
                                bne.s   T450_004                                                                        /* Branch if D0 != drive index */
                                move.l  -6(A0),C0x0472_ADDRESS_SYSTEM_VARIABLE_hdv_bpb                                  /* Restore original vector L1448_pc_DefaultBPBVector */
                                move.l  -10(A0),C0x047E_ADDRESS_SYSTEM_VARIABLE_hdv_mediach                             /* Restore original vector L1449_pc_DefaultMediaChangeVector */
                                move.l  -14(A0),C0x0476_ADDRESS_SYSTEM_VARIABLE_hdv_rw                                  /* Restore original vector L1450_pc_DefaultRWBlocksVector */
                        T450_004:
                                movea.l -6(A0),A0                                                                       /* L1448_pc_DefaultBPBVector */
                                jmp     (A0)                                                                            /* Call L1448_pc_DefaultBPBVector */
                        T450_005_ReplacementRoutineMediaChangeVector:
                                movea.l V450_1_xxx_RegisterA6Backup(PC),A0
                                move.w  -2(A0),D0                                                                       /* L1447_i_FloppyDriveIndex */
                                cmp.w   4(A7),D0                                                                        /* Drive index */
                                bne.s   T450_006                                                                        /* Branch if D0 != drive index */
                                moveq   #2,D0                                                                           /* Return value. 2 is the BIOS value MED_CHANGED: Media has changed (see Mediach() BIOS function) */
                                rts
                        T450_006:
                                movea.l -10(A0),A0                                                                      /* L1449_pc_DefaultMediaChangeVector */
                                jmp     (A0)                                                                            /* Call L1449_pc_DefaultMediaChangeVector */
                        T450_007_ReplacementRoutineRWBlocks:
                                movea.l V450_1_xxx_RegisterA6Backup(PC),A0
                                move.w  -2(A0),D0                                                                       /* L1447_i_FloppyDriveIndex */
                                cmp.w   14(A7),D0                                                                       /* Drive index as in Rwabs parameters, starting at 4(a7) */
                                bne.s   T450_008                                                                        /* Branch if D0 != drive index */
                                moveq   #-14,D0                                                                         /* Return value. -14 is the BIOS error E_CHNG: Media change detected */
                                rts
                        T450_008:
                                movea.l -14(A0),A0                                                                      /* L1450_pc_DefaultRWBlocksVector */
                                jmp     (A0)                                                                            /* Call L1450_pc_DefaultRWBlocksVector */
                        V450_1_xxx_RegisterA6Backup:
                                dc.l    0x00000000
                        T450_010:
                }
                Super(L1445_l_SupervisorStack);
        }
}
#endif
