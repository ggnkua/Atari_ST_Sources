#include "DEFS.H"

overlay "start"

VOID F448_xxxx_MEMINIT_InitializeMemoryManager_COPYPROTECTIONADEF()
{
        register long L1437_l_AvailableHeapMemoryByteCount;
        register long L1438_l_AvailableGEMMemoryBottom;
        register long L1439_l_AvailableGEMMemoryByteCount;
#ifndef NOCOPYPROTECTION
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_05_OPTIMIZATION */
        register BOOLEAN L1441_B_CommandLineParameterIsAUTO_COPYPROTECTIONA;
#endif
#endif
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_14_FIX Useless code removed */
        register char* L1442_pc_HeapMemoryBottom_Useless; /* BUG0_00 Useless code */
#endif
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_08_OPTIMIZATION Variable definition changed */
        register char* L1443_pc_SupervisorStack;
#endif
#ifndef NOCOPYPROTECTION
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_05_OPTIMIZATION */
        char L1444_ac_CommandLineParameters_COPYPROTECTIONA[130];
#endif
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_08_OPTIMIZATION Variable definition changed */
        register long L1440_l_SupervisorStack;
#endif


        Cconws("\33f"); /* VT-52 command to hide the cursor. 33 (octal) = 1B (hexadecimal) = 27 (decimal) = ESC (Megamax C does not support hexadecimal character constants) */
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_05_OPTIMIZATION */
        Supexec(&S059_aaac_OS_SetException257Vector_CriticalError);
#ifndef NOCOPYPROTECTION
        F458_xxxx_START_GetCommandLineParameters_COPYPROTECTIONA(L1444_ac_CommandLineParameters_COPYPROTECTIONA);
#endif
#endif
        L1437_l_AvailableHeapMemoryByteCount = Malloc(-1L) - 20;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_08_OPTIMIZATION */
        L1443_pc_SupervisorStack = (char*)Super(0L);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_08_OPTIMIZATION */
        L1440_l_SupervisorStack = Super(0L);
#endif
        asm {
                movea.l C0x04F2_ADDRESS_SYSTEM_VARIABLE__sysbase,A1     /* Address of the OSHEADER BIOS structure */
                move.l  12(A1),L1438_l_AvailableGEMMemoryBottom         /* os_end. Address of the first byte not used by the OS (BIOS/GEMDOS/VDI) */
                movea.l 20(A1),A0                                       /* os_magic. Address of the GEM_MUPB structure (GEM memory-usage parameter block) */
                move.l  4(A0),L1439_l_AvailableGEMMemoryByteCount       /* gm_end. Address of the end of the memory required by GEM (from the GEM_MUPB) */
        }
        L1439_l_AvailableGEMMemoryByteCount -= L1438_l_AvailableGEMMemoryBottom;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_08_OPTIMIZATION */
        Super(L1443_pc_SupervisorStack);
#endif
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_14_FIX Useless code removed */
        F475_ozzz_MEMORY_Initialize(L1442_pc_HeapMemoryBottom_Useless = (char*)Malloc(L1437_l_AvailableHeapMemoryByteCount), L1437_l_AvailableHeapMemoryByteCount, L1438_l_AvailableGEMMemoryBottom, L1439_l_AvailableGEMMemoryByteCount); /* BUG0_00 Useless code */
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_08_OPTIMIZATION */
        Super(L1440_l_SupervisorStack);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_14_FIX Useless code removed */
        F475_ozzz_MEMORY_Initialize(Malloc(L1437_l_AvailableHeapMemoryByteCount), L1437_l_AvailableHeapMemoryByteCount, L1438_l_AvailableGEMMemoryBottom, L1439_l_AvailableGEMMemoryByteCount);
#endif
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_05_OPTIMIZATION */
#ifndef NOCOPYPROTECTION
        L1441_B_CommandLineParameterIsAUTO_COPYPROTECTIONA = (L1444_ac_CommandLineParameters_COPYPROTECTIONA[0] == 'A') && (L1444_ac_CommandLineParameters_COPYPROTECTIONA[1] == 'U') && (L1444_ac_CommandLineParameters_COPYPROTECTIONA[2] == 'T') && (L1444_ac_CommandLineParameters_COPYPROTECTIONA[3] == 'O');
#endif
        F479_izzz_MEMORY_ReadGraphicsDatHeader();
        F460_xxxx_START_InitializeGraphicData();
#ifndef NOCOPYPROTECTION
        F447_xxxx_STARTEND_HangIfFalse_COPYPROTECTIONA(L1441_B_CommandLineParameterIsAUTO_COPYPROTECTIONA);
#endif
        F437_xxxx_STARTEND_DrawTitle();
        F094_mzzz_DUNGEONVIEW_LoadFloorSet(C0_FLOOR_SET_STONE);
        F095_izzz_DUNGEONVIEW_LoadWallSet(C0_WALL_SET_STONE);
#ifndef NOCOPYPROTECTION
        Floprd(G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE, C0L_FILLER, C0_FLOPPY_DRIVE_A, C007_SECTOR_7, C0_TRACK_0, C0_SIDE_0, C1_ONE_SECTOR);
#endif
        F054_aAA1_TEXT_Initialize();
        F031_aAA2_OBJECT_LoadNames();
        F007_aAA7_MAIN_CopyBytes(G021_aaui_Graphic562_Palette_DungeonView[0], G346_aui_Palette_MiddleScreen, sizeof(G346_aui_Palette_MiddleScreen));
        F007_aAA7_MAIN_CopyBytes(G021_aaui_Graphic562_Palette_DungeonView[0], G347_aui_Palette_TopAndBottomScreen, sizeof(G347_aui_Palette_TopAndBottomScreen));
#ifndef NOCOPYPROTECTION
        G626_pfV_S080_aaat_COPYPROTECTIONDF_CheckDMATransferCompletion = F211_vzzz_COPYPROTECTIONDF_GetSubroutineAbsoluteAddress(&S080_aaat_COPYPROTECTIONDF_CheckDMATransferCompletion);
        G627_pfV_S081_aaao_COPYPROTECTIONDF_TurnOffFloppyDrive = F211_vzzz_COPYPROTECTIONDF_GetSubroutineAbsoluteAddress(&S081_aaao_COPYPROTECTIONDF_TurnOffFloppyDrive);
#endif
        F066_aalz_MOUSE_Initialize();
        Supexec(&F018_aaat_MAIN_SetExceptionVectors);
        Jdisint(C05_INTERRUPT_TIMER_C);
        F062_aalz_SOUND_Initialize();
        Vsync();
        F441_xxxx_STARTEND_ProcessEntrance();
        while (F435_xxxx_STARTEND_LoadGame_COPYPROTECTIONF() != C01_LOAD_GAME_SUCCESS) {
                F477_izzz_MEMORY_OpenGraphicsDat_COPYPROTECTIONDF();
                F441_xxxx_STARTEND_ProcessEntrance();
        }
        F477_izzz_MEMORY_OpenGraphicsDat_COPYPROTECTIONDF();
        F396_pzzz_MENUS_LoadSpellAreaLinesBitmap();
        F476_mzzz_MEMORY_InitializeGraphicMemory();
        F462_xxxx_START_StartGame_COPYPROTECTIONF();
        F478_gzzz_MEMORY_CloseGraphicsDat_COPYPROTECTIONDF();
        if (G298_B_NewGame) {
                F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(C0xFFFF_THING_PARTY, CM1_MAPX_NOT_ON_A_SQUARE, 0, G306_i_PartyMapX, G307_i_PartyMapY);
        }
        F078_xzzz_MOUSE_ShowPointer();
        F357_qzzz_COMMAND_DiscardAllInput();
#endif
}
