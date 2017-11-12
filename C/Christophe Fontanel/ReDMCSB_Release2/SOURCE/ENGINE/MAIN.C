#include "DEFS.H"

/*_Global variables_*/
int G285_i_SquareAheadElement;
BOOLEAN G286_B_FacingAlcove;
BOOLEAN G287_B_FacingViAltar;
BOOLEAN G288_B_FacingFountain;
int G289_i_DungeonView_ChampionPortraitOrdinal;
THING G290_T_DungeonView_InscriptionThing;
unsigned char G291_aauc_DungeonViewClickableBoxes[6][4]; /* Four boxes for objects on top of piles on the floor, one box for object on top of pile in alcove and one box for a door button or a wall ornament */
THING G292_aT_PileTopObject[5];
#ifndef NOCOPYPROTECTION
int G293_ai_FuzzyBits_COPYPROTECTIONE[32];
#endif
unsigned char G294_auc_LastDiscardedThingMapIndex[16];
#ifndef NOCOPYPROTECTION
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_00_OPTIMIZATION */
char G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE[512];
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_00_OPTIMIZATION Increased sector 7 read buffer size to 1024 bytes instead of 512 bytes but only the first 512 bytes are used */
char G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE[1024];
#endif
#endif
unsigned char* G296_puc_Bitmap_Viewport;
BOOLEAN G297_B_DrawFloorAndCeilingRequested = TRUE;
BOOLEAN G298_B_NewGame;
unsigned int G299_ui_CandidateChampionOrdinal;
BOOLEAN G300_B_PartyIsSleeping;
BOOLEAN G301_B_GameTimeTicking;
BOOLEAN G302_B_GameWon;
BOOLEAN G303_B_PartyDead;
int G304_i_DungeonViewPaletteIndex;
unsigned int G305_ui_PartyChampionCount;
int G306_i_PartyMapX;
int G307_i_PartyMapY;
int G308_i_PartyDirection;
int G309_i_PartyMapIndex;
int G310_i_DisabledMovementTicks;
int G311_i_ProjectileDisabledMovementTicks;
int G312_i_LastProjectileDisabledMovementDirection;
unsigned long G313_ul_GameTime;
#ifndef NOCOPYPROTECTION
int G314_i_SectorsReadRequested_COPYPROTECTIONDF;
int G315_i_SectorsReadFailure_COPYPROTECTIONDF;
int G316_i_SectorsReadPreviousFailure_COPYPROTECTIONDF;
#endif
int G317_i_WaitForInputVerticalBlankCount;
int G318_i_WaitForInputMaximumVerticalBlankCount;
#ifndef NOCOPYPROTECTION
unsigned long G319_ul_LoadGameTime_COPYPROTECTIONF;
#endif
int G320_i_Unreferenced; /* BUG0_00 Useless code */
BOOLEAN G321_B_StopWaitingForPlayerInput = TRUE;
BOOLEAN G322_B_PaletteSwitchingEnabled;
BOOLEAN G323_B_EnablePaletteSwitchingRequested;
BOOLEAN G324_B_DrawViewportRequested;
BOOLEAN G325_B_SetMousePointerToObjectInMainLoop;
BOOLEAN G326_B_RefreshMousePointerInMainLoop;
int G327_i_NewPartyMapIndex = CM1_MAP_INDEX_NONE;
#ifndef NOCOPYPROTECTION
int G328_i_TimeBombToKillParty_COPYPROTECTIONF;
int G329_i_Useless_COPYPROTECTIOND; /* BUG0_00 Useless code */
int G330_i_StopExpiringEvents_COPYPROTECTIONE;
#endif
BOOLEAN G331_B_PressingEye;
BOOLEAN G332_B_StopPressingEye;
BOOLEAN G333_B_PressingMouth;
BOOLEAN G334_B_StopPressingMouth;
int G335_i_SelectedDialogChoice;
int G336_i_HighlightBoxX1;
int G337_i_HighlightBoxX2;
int G338_i_HighlightBoxY1;
int G339_i_HighlightBoxY2;
BOOLEAN G340_B_HighlightBoxInversionRequested;
BOOLEAN G341_B_HighlightBoxEnabled;
BOOLEAN G342_B_RefreshDungeonViewPaletteRequested;
unsigned char* G343_puc_Graphic_DialogBox;
#ifndef NOCOPYPROTECTION
char G344_ac_CodePatch1_COPYPROTECTIONE[68];
#endif
unsigned int G345_aui_BlankBuffer[32];
unsigned int G346_aui_Palette_MiddleScreen[16];
unsigned int G347_aui_Palette_TopAndBottomScreen[16];
long* G348_pl_Bitmap_LogicalScreenBase = Logbase();
unsigned long G349_ul_LastRandomNumber = Random();
BOOLEAN G350_B_SwitchToTopBottomPalette;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_01_FIX */
int G351_i_ConcurrentVerticalBlankExceptionCount;
#endif


overlay "main"

VOID F002_xxxx_MAIN_GameLoop_COPYPROTECTIONDF()
{
        G318_i_WaitForInputMaximumVerticalBlankCount = 10;
        do {
                G317_i_WaitForInputVerticalBlankCount = 0;
                if (G327_i_NewPartyMapIndex != CM1_MAP_INDEX_NONE) {
                        T002_002:
                        F003_aaaS_MAIN_ProcessNewPartyMap_COPYPROTECTIONE(G327_i_NewPartyMapIndex);
                        F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(C0xFFFF_THING_PARTY, CM1_MAPX_NOT_ON_A_SQUARE, 0, G306_i_PartyMapX, G307_i_PartyMapY);
                        G327_i_NewPartyMapIndex = CM1_MAP_INDEX_NONE;
                        F357_qzzz_COMMAND_DiscardAllInput();
                }
                F261_hzzz_TIMELINE_Process_COPYPROTECTIONEF();
                if (G327_i_NewPartyMapIndex != CM1_MAP_INDEX_NONE) {
                        goto T002_002;
                }
                if (!G423_i_InventoryChampionOrdinal && !G300_B_PartyIsSleeping) {
                        F128_rzzz_DUNGEONVIEW_Draw_COPYPROTECTIONF(G308_i_PartyDirection, G306_i_PartyMapX, G307_i_PartyMapY);
                        if (G325_B_SetMousePointerToObjectInMainLoop) {
                                G325_B_SetMousePointerToObjectInMainLoop = FALSE;
                                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                                F068_aagz_MOUSE_SetPointerToObject(G412_puc_Bitmap_ObjectIconForMousePointer);
                                F078_xzzz_MOUSE_ShowPointer();
                        }
                        if (G326_B_RefreshMousePointerInMainLoop) {
                                G326_B_RefreshMousePointerInMainLoop = FALSE;
                                G598_B_MousePointerBitmapUpdated = TRUE;
                                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                                F078_xzzz_MOUSE_ShowPointer();
                        }
                }
                F363_pzzz_COMMAND_HighlightBoxDisable();
                F065_aanz_SOUND_PlayPendingSound_COPYPROTECTIOND();
                F320_akzz_CHAMPION_ApplyAndDrawPendingDamageAndWounds();
                if (G303_B_PartyDead) {
                        return;
                }
                G313_ul_GameTime++; /* BUG0_02 After playing a single game for hundreds of hours (in one row or across multiple save/load cycles) the game starts to behave strangely and then hangs. Even though the game time is stored in a 32 bit value, event times in the timeline are stored on 24 bits so the maximum possible time value is 2^24 - 1 = 16777215 (around 850 to 1000 hours of actual play time). Issues occur because new events scheduled to occur in the future are actually scheduled in the past and then expire immediately. For example, if you use the 'Light' action of the Yew Staff or Sceptre Of Lyf when G313_ul_GameTime = 16776500 then in F407_xxxx_MENUS_IsActionPerformed an event to remove the light will be scheduled at (16775000 + 2500) Mod 2^24 = 284 and will thus expire immediately so that the light will only be visible for a very short moment. When G313_ul_GameTime reaches 16777200 (the largest multiple of 300 that is smaller than the maximum value of 16777216), in F256_xxxx_TIMELINE_ProcessEvent53_Watchdog the time of the next C53_EVENT_WATCHDOG is set to (16777200 + 300) Mod 2^24 = 284 and thus expires immediately. F261_hzzz_TIMELINE_Process_COPYPROTECTIONEF then enters an infinite loop where it constantly processes the same event C53_EVENT_WATCHDOG, causing the game to hang. Fixing this bug could be done by substracting a fixed amount (like 15000000) from all time values stored in the game (all events and some global variables) when the time reaches a maximum value, like 16000000 */
                if (!((int)G313_ul_GameTime & 511)) {
                        F338_atzz_INVENTORY_DecreaseTorchesLightPower_COPYPROTECTIONE();
                }
                if (G407_s_Party.FreezeLifeTicks) {
                        G407_s_Party.FreezeLifeTicks--;
                }
                F390_rzzz_MENUS_RefreshActionAreaAndSetChampionDirectionMaximumDamageReceived();
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_00_IMPROVEMENT Faster regeneration */
                if (!((int)G313_ul_GameTime & 63)) {
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_00_IMPROVEMENT Faster regeneration while sleeping */
                if (!((int)G313_ul_GameTime & (G300_B_PartyIsSleeping ? 15 : 63))) {
#endif
                        F331_auzz_CHAMPION_ApplyTimeEffects_COPYPROTECTIONF();
                }
                if (G310_i_DisabledMovementTicks) {
                        G310_i_DisabledMovementTicks--;
                }
                if (G311_i_ProjectileDisabledMovementTicks) {
                        G311_i_ProjectileDisabledMovementTicks--;
                }
                F044_xxxx_TEXT_MESSAGEAREA_ClearExpiredRows();
                if (G374_l_WatchdogTime < G313_ul_GameTime) {
                        F019_aarz_MAIN_DisplayErrorAndStop(C60_ERROR_EVENT_PROCESSING_STOPPED);
                }
                G321_B_StopWaitingForPlayerInput = FALSE;
                do {
                        while (Cconis()) {
                                F361_nzzz_COMMAND_ProcessKeyPress(Crawcin());
                        }
                        if (G332_B_StopPressingEye) {
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_02_FIX G331_B_PressingEye is set to FALSE here instead of immediately when the mouse button is released in mouse exception handler S076_aaal_MOUSE_OnMouseButtonsStatusChange. This ensures that G331_B_PressingEye cannot be TRUE when F380_xzzz_COMMAND_ProcessQueue_COPYPROTECTIONC is called below and FALSE when reaching the test added on G331_B_PressingEye in F380_xzzz_COMMAND_ProcessQueue_COPYPROTECTIONC in the case where the mouse button is released in between */
                                G331_B_PressingEye = FALSE;
#endif
                                G332_B_StopPressingEye = FALSE;
                                F353_auzz_INVENTORY_DrawStopPressingEye();
                        } else {
                                if (G334_B_StopPressingMouth) {
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_02_FIX G333_B_PressingMouth is set to FALSE here instead of immediately when the mouse button is released in mouse exception handler S076_aaal_MOUSE_OnMouseButtonsStatusChange. This ensures that G333_B_PressingMouth cannot be TRUE when F380_xzzz_COMMAND_ProcessQueue_COPYPROTECTIONC is called below and FALSE when reaching the test added on G333_B_PressingMouth in F380_xzzz_COMMAND_ProcessQueue_COPYPROTECTIONC in the case where the mouse button is released in between */
                                        G333_B_PressingMouth = FALSE;
#endif
                                        G334_B_StopPressingMouth = FALSE;
                                        F350_aqzz_INVENTORY_DrawStopPressingMouth();
                                }
                        }
                        F380_xzzz_COMMAND_ProcessQueue_COPYPROTECTIONC();
                        if (!G321_B_StopWaitingForPlayerInput) {
                                F363_pzzz_COMMAND_HighlightBoxDisable();
                        }
                } while (!G321_B_StopWaitingForPlayerInput || !G301_B_GameTimeTicking);
#ifndef NOCOPYPROTECTION
                /* If there is a copy protection sector read failure and the previous read succeeded */
                if (!((int)G313_ul_GameTime & 63) && (G315_i_SectorsReadFailure_COPYPROTECTIONDF & ~G316_i_SectorsReadPreviousFailure_COPYPROTECTIONDF)) {
                        F456_vzzz_START_DrawDisabledMenus();
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_03_IMPROVEMENT */
                        F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(C1_FORCE_DIALOG_DM, FALSE);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives */
                        F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(C2_FORCE_DIALOG_CSB, FALSE);
#endif
                        F457_AA08_START_DrawEnabledMenus_COPYPROTECTIONF();
                        G316_i_SectorsReadPreviousFailure_COPYPROTECTIONDF = G315_i_SectorsReadFailure_COPYPROTECTIONDF;
                }
#endif
        } while ();
}

VOID F003_aaaS_MAIN_ProcessNewPartyMap_COPYPROTECTIONE(P000_i_MapIndex)
int P000_i_MapIndex;
{
        EVENT L0000_s_Event;


        F194_hzzz_GROUP_RemoveAllActiveGroups(); /* BUG0_63 The behavior of groups and the directions of individual creatures in groups are not restored when a saved game is loaded. Each group on the same map as the party has additional data that other groups do not have. This additional data is stored as part of saved games and loaded when the game is restarted. However, after loading a saved game the function to initialize this data is called. This overwrites the data and thus the state of groups when the game was saved is ignored */
        F174_aozz_DUNGEON_SetCurrentMapAndPartyMap(P000_i_MapIndex);
        F096_qzzz_DUNGEONVIEW_LoadCurrentMapGraphics_COPYPROTECTIONDF();
#ifndef NOCOPYPROTECTION
        if ((G313_ul_GameTime - G418_l_LastEvent22Time_COPYPROTECTIONE) > 500) {
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_04_IMPROVEMENT */
                G418_l_LastEvent22Time_COPYPROTECTIONE = G313_ul_GameTime + 1;
#endif
                L0000_s_Event.A.A.Type = C22_EVENT_COPYPROTECTIONE;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_04_IMPROVEMENT Event 22 expires 2 ticks in the future */
                M33_SET_MAP_AND_TIME(L0000_s_Event.Map_Time, P000_i_MapIndex, (G418_l_LastEvent22Time_COPYPROTECTIONE = G313_ul_GameTime) + 2);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_04_IMPROVEMENT Event 22 expires 3 ticks in the future */
                M33_SET_MAP_AND_TIME(L0000_s_Event.Map_Time, P000_i_MapIndex, G418_l_LastEvent22Time_COPYPROTECTIONE + 2);
#endif
                F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0000_s_Event);
                F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(C0_DO_NOT_FORCE_DIALOG_DM_CSB, FALSE);
                Floprd(G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE, C0L_FILLER, C0_FLOPPY_DRIVE_A, C007_SECTOR_7, C0_TRACK_0, C0_SIDE_0, C1_ONE_SECTOR);
                G488_i_Graphic560_RequestCheckFuzzyBitCount_COPYPROTECTIONE = C01113_TRUE;
                G031_i_Graphic562_Sector7Analyzed_COPYPROTECTIONE = C00255_FALSE;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_04_IMPROVEMENT */
                G068_i_CheckLastEvent22Time_COPYPROTECTIONE = C00555_TRUE;
#endif
        }
#endif
        F195_akzz_GROUP_AddAllActiveGroups(); /* BUG0_63 */
        F337_akzz_INVENTORY_SetDungeonViewPalette();
}

int main()
{
        asm { /* Backup A4 and A5 registers so these addresses can be accessed when running exception handlers */
                lea     V011_1_xxx_RegisterA4Backup(PC),A0
                move.l  A4,(A0)                                 /* Backup copy of A4 register. Megamax C stores the address of the DATA segment (positive offsets) and BSS segment (negative offsets) in A4 */
                lea     V012_1_xxx_RegisterA5Backup(PC),A0
                move.l  A5,(A0)                                 /* Backup copy of A5 register. Megamax C stores the address of the JUMPTABLE in A5 */
        }
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_05_OPTIMIZATION */
        F448_xxxx_MEMINIT_InitializeMemoryManager_COPYPROTECTIONADEF();
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_05_OPTIMIZATION */
        F463_wzzz_START_InitializeGame_COPYPROTECTIONADEF();
#endif
        for(;;) { /*_Infinite loop_*/
                F002_xxxx_MAIN_GameLoop_COPYPROTECTIONDF();
                F444_AA29_STARTEND_Endgame(G303_B_PartyDead);
        }
}

VOID F006_aamz_MAIN_HighlightScreenBox(P001_i_X1, P002_i_X2, P003_i_Y1, P004_i_Y2)
int P001_i_X1;
int P002_i_X2;
int P003_i_Y1;
int P004_i_Y2;
{
        asm {
                        movem.l D4-D7,-(A7)
                        movea.l G348_pl_Bitmap_LogicalScreenBase(A4),A0
                        move.w  P003_i_Y1(A6),D5
                        move.w  P004_i_Y2(A6),D0
                        sub.w   D5,D0
                        mulu.w  #160,D5
                        adda.w  D5,A0
                        move.w  P001_i_X1(A6),D5
                        move.w  D5,D6
                        lsr.w   #1,D5
                        andi.w  #0x00F8,D5
                        move.w  D5,D7
                        adda.w  D5,A0
                        addq.l  #4,A0
                        andi.w  #0x000F,D6
                        move.w  #-0x0001,D3
                        move.w  D3,D4
                        lsr.w   D6,D3
                        move.w  P002_i_X2(A6),D5
                        move.w  D5,D6
                        lsr.w   #1,D6
                        andi.w  #0x00F8,D6
                        andi.w  #0x000F,D5
                        neg.w   D5
                        addi.w  #0x000F,D5
                        lsl.w   D5,D4
                        cmp.w   D6,D7
                        beq.s   T006_004
                        move.w  D6,D1
                        sub.w   D7,D1
                        subq.w  #8,D1
                        lsr.w   #3,D1
                T006_001:
                        lea     160(A0),A1
                        move.w  (A0),D5
                        move.w  D5,D6
                        not.w   D5
                        and.w   D3,D5
                        move.w  D3,D7
                        not.w   D7
                        and.w   D7,D6
                        or.w    D5,D6
                        move.w  D6,(A0)
                        addq.l  #8,A0
                        move.w  D1,D2
                        bra.s   T006_003
                T006_002:
                        not.w   (A0)
                        addq.l  #8,A0
                T006_003:
                        dbf     D2,T006_002
                        move.w  (A0),D5
                        move.w  D5,D6
                        not.w   D5
                        and.w   D4,D5
                        move.w  D4,D7
                        not.w   D7
                        and.w   D7,D6
                        or.w    D5,D6
                        move.w  D6,(A0)
                        movea.l A1,A0
                        dbf     D0,T006_001
                        bra.s   T006_006_Return
                T006_004:
                        and.w   D4,D3
                T006_005:
                        move.w  (A0),D5
                        move.w  D5,D6
                        not.w   D5
                        and.w   D3,D5
                        move.w  D3,D7
                        not.w   D7
                        and.w   D7,D6
                        or.w    D5,D6
                        move.w  D6,(A0)
                        lea     160(A0),A0
                        dbf     D0,T006_005
                T006_006_Return:
                        movem.l (A7)+,D4-D7
        }
}

VOID F007_aAA7_MAIN_CopyBytes(P005_pc_Source, P006_pc_Destination, P007_i_ByteCount)
char* P005_pc_Source;
char* P006_pc_Destination;
int P007_i_ByteCount;
{
        asm {
                        movem.l D4-D7/A2-A6,-(A7)
                        move.w  P007_i_ByteCount(A6),D7
                        movea.l P005_pc_Source(A6),A3
                        movea.l P006_pc_Destination(A6),A2
                        move.l  A3,D0
                        move.l  A2,D1
                        andi.w  #0x0001,D0
                        beq.s   T007_001                        /* Branch if P005_pc_Source is even */
                        andi.w  #0x0001,D1
                        bne.s   T007_004                        /* Branch if P006_pc_Destination is even */
                        bra.s   T007_003_LoopExpression
                T007_001:
                        andi.w  #0x0001,D1
                        beq.s   T007_005                        /* Branch if P006_pc_Destination is even */
                        bra.s   T007_003_LoopExpression
                T007_002_Loop:
                        move.b  (A3)+,(A2)+                     /* Copy one byte from source to destination and increment A2 and A3 */
                        move.b  (A3)+,(A2)+
                        move.b  (A3)+,(A2)+
                        move.b  (A3)+,(A2)+
                        move.b  (A3)+,(A2)+
                        move.b  (A3)+,(A2)+
                        move.b  (A3)+,(A2)+
                        move.b  (A3)+,(A2)+
                T007_003_LoopExpression:
                        subq.w  #8,D7                           /* There are 8 bytes less to copy */
                        bpl.s   T007_002_Loop                   /* Branch if D7 >= 0 */
                        addq.w  #8,D7                           /* Restore D7 to its previous value (there are less than 8 bytes left to copy) */
                        bra.s   T007_013
                T007_004:
                        subq.w  #1,D7
                        bmi.s   T007_014_Return
                        move.b  (A3)+,(A2)+                     /* Copy one byte from source to destination and increment A2 and A3 */
                T007_005:
                        cmpa.l  A2,A3
                        bpl.s   T007_011_LoopExpression
                        adda.w  D7,A3                           /* Bytes will be read from the end */
                        adda.w  D7,A2                           /* Bytes will be written from the end */
                        moveq   #1,D6
                        and.w   D7,D6
                        beq.s   T007_007_LoopExpression
                        subq.w  #1,D7
                        bmi.s   T007_014_Return
                        move.b  -(A3),-(A2)                     /* Copy one byte from source to destination and decrement A2 and A3 */
                        bra.s   T007_007_LoopExpression
                T007_006_Loop:
                        lea     -48(A3),A3                      /* A3 = A3 - 48 */
                        movem.l (A3),D0-D6/A0-A1/A4-A6          /* Copy 48 bytes from source to 12 registers */
                        movem.l D0-D6/A0-A1/A4-A6,-(A2)         /* Copy 48 bytes from 12 registers to destination and decrement A2 */
                T007_007_LoopExpression:
                        subi.w  #48,D7                          /* There are 48 byte less to copy */
                        bpl.s   T007_006_Loop                   /* Branch if D7 >= 0 */
                        addi.w  #48,D7                          /* Restore D7 to its previous value (there are less than 48 bytes left to copy) */
                        bra.s   T007_009
                T007_008:
                        move.b  -(A3),-(A2)                     /* Copy one byte from source to destination and decrement A2 and A3 */
                T007_009:
                        dbf     D7,T007_008                     /* Decrement D7 and branch if D7 >= 0 */
                        bra.s   T007_014_Return
                T007_010_Loop:
                        movem.l (A3)+,D0-D6/A0-A1/A4-A6         /* Copy 48 bytes from source to 12 registers */
                        movem.l D0-D6/A0-A1/A4-A6,(A2)          /* Copy 48 bytes from 12 registers to destination */
                        lea     48(A2),A2                       /* A2 = A2 + 48 */
                T007_011_LoopExpression:
                        subi.w  #48,D7                          /* There are 48 byte less to copy */
                        bpl.s   T007_010_Loop                   /* Branch if D7 >= 0 */
                        addi.w  #48,D7                          /* Restore D7 to its previous value (there are less than 48 bytes left to copy) */
                        bra.s   T007_013
                T007_012:
                        move.b  (A3)+,(A2)+                     /* Copy one byte from source to destination and increment A2 and A3 */
                T007_013:
                        dbf     D7,T007_012                     /* Decrement D7 and branch if D7 >= 0 */
                T007_014_Return:
                        movem.l (A7)+,D4-D7/A2-A6
        }
}

VOID F008_aA19_MAIN_ClearBytes(P008_pc_Buffer, P009_i_ByteCount)
char* P008_pc_Buffer;
int P009_i_ByteCount;
{
        asm {
                        movem.l D4-D7/A2-A6,-(A7)
                        move.w P009_i_ByteCount(A6),D0
                        movea.l P008_pc_Buffer(A6),A0
                        adda.w D0,A0                                    /* Address of the last byte to clear (start clearing from the end) */
                        subi.w #52,D0                                   /* 52 bytes is the total size of all 13 registers used in the operation */
                        bmi.s T008_002                                  /* Branch if there are less than 52 bytes left to clear */
                        movem.l G345_aui_BlankBuffer(A4),D1-D7/A1-A6    /* Initialize all registers to 0 except A0 and D0 (the function parameters) and A7 (stack pointer) */
                T008_001:
                        movem.l D1-D7/A1-A6,-(A0)                       /* Decrement A0 and save all registers at A0, effectively clearing 52 bytes of data at A0 in one instruction */
                        subi.w #52,D0                                   /* The number of bytes left to clear */
                        bpl.s T008_001
                T008_002:
                        addi.w #52,D0                                   /* The number of bytes left to clear (now less than 52) */
                        bra.s T008_004
                T008_003:
                        clr.b -(A0)                                     /* Decrement address in A0 and clear byte at A0 */
                T008_004:
                        dbf D0,T008_003
                        movem.l (A7)+,D4-D7/A2-A6
        }
}

VOID F009_aA49_MAIN_WriteSpacedBytes(P010_pc_Buffer, P011_i_ByteCount, P012_c_ByteValue, P013_i_Spacing)
register char* P010_pc_Buffer;
register int P011_i_ByteCount;
register char P012_c_ByteValue;
register int P013_i_Spacing;
{
        if (P013_i_Spacing != 1) {
                do {
                        *P010_pc_Buffer = P012_c_ByteValue;
                        asm {
                                adda.w P013_i_Spacing,P010_pc_Buffer
                        }
                } while (--P011_i_ByteCount);
        } else {
                do {
                        *P010_pc_Buffer++ = P012_c_ByteValue;
                } while (--P011_i_ByteCount);
        }
}

VOID F010_aAA7_MAIN_WriteSpacedWords(P014_pi_Buffer, P015_i_WordCount, P016_i_WordValue, P017_i_Spacing)
register int* P014_pi_Buffer;
register int P015_i_WordCount;
register int P016_i_WordValue;
register int P017_i_Spacing;
{
        if (P017_i_Spacing != 2) {
                do {
                        *P014_pi_Buffer = P016_i_WordValue;
                        asm {
                                adda.w P017_i_Spacing,P014_pi_Buffer
                        }
                } while (--P015_i_WordCount);
        } else {
                do {
                        *P014_pi_Buffer++ = P016_i_WordValue;
                } while (--P015_i_WordCount);
        }
}

asm {
        V011_1_xxx_RegisterA4Backup:
                dc.l 0L                                                         /* Backup copy of A4 register (pointing to DATA/BSS). This is used in exception handlers */
        V012_1_xxx_RegisterA5Backup:
                dc.l 0L                                                         /* Backup copy of A5 register (pointing to JUMPTABLE). This is used in exception handlers */
        E013_xxxx_MAIN_Exception69Handler_TimerC_DoNothing:
                rte                                                             /* Return from exception (Status Register is restored). This exception handler corresponds to processor interrupt #6 (ST-MFP interrupt #5). The processor sets the 'interrupt priority mask' in sr to 6 before executing this exception handler */
        E014_xxxx_MAIN_Exception70Handler_KeyboardMIDI:                         /* This exception handler corresponds to processor interrupt #6 (ST-MFP interrupt #6). The processor sets the 'interrupt priority mask' in sr to 6 before executing this exception handler */
                move.w  D0,-(A7)
                move    SR,D0                                                   /* Status Register */
                andi.w  #0xF8FF,D0
                ori.w   #0x0500,D0
                move    D0,SR                                                   /* Set interrupt priority mask = 5 in Status Register. All interrupts below or equal to 5 will now be ignored. This means Horizontal Blank interrupts (level 2) and Vertical Blank interrupts (level 4) are ignored and MFP interrupts (level 6) are processed. This reduces the interrupt level of IKBD and now allows other interrupts 6 to be processed */
                move.w  (A7)+,D0
                dc.w    0x4EF9                                                  /* jmp instruction. The target address will be replaced by the default Exception Vector 70 Handler */
        V014_1_xxx_JMPTargetAddress:
                dc.l    0x00000000
        E015_xxxx_MAIN_Exception72Handler_TimerB_PaletteSwitcher:               /* This exception handler corresponds to processor interrupt #6 (ST-MFP interrupt #8). The processor sets the 'interrupt priority mask' in sr to 6 before executing this exception handler */
                movem.l A0/A4,-(A7)
                movea.l V011_1_xxx_RegisterA4Backup(PC),A4                      /* Restore A4 */
                movea.w #0xFA00,A0                                              /* Base address of the MFP is 0xFFFFFA00 (movea sign extends the word address to a long address) */
                tst.w   G350_B_SwitchToTopBottomPalette(A4)
                bne.s   T015_001                                                /* If the palette for top and bottom should be configured */
                clr.b   27(A0)                                                  /* Clear LSB of Timer B control register on the MFP. This stops Timer B (it does not count anymore) */
                move.b  #139,33(A0)                                             /* Write 139 in LSB of Timer B data register. This is the initial counter value. The timer will decrement this value at each Horizontal Blank until it reaches 1, then it produces an interrupt. The middle screen area has 139 lines */
                move.b  #8,27(A0)                                               /* Write 8 in LSB of Timer B control register on the MFP. This sets Timer B in event count mode */
                movem.l D0-D7,-(A7)
                movem.l G346_aui_Palette_MiddleScreen(A4),D0-D7                 /* Load all data registers with the color palette for the middle of the screen. 8 registers * 4 bytes/register = 32 bytes */
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_06_OPTIMIZATION */
                movem.l D0-D7,0x00FF8240                                        /* Write all data registers (the full palette) to the video palette registers */
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_06_OPTIMIZATION The correct register address is 0xFFFF8240 instead of 0x00FF8240, even if both addresses always work fine. Earlier models of Atari ST computers used a 68000 processor that has a 24 bit address bus and thus they completely ignore the most significant byte of addresses. Later models like Atari TT and Falcon used a 68030 processor that has a 32 bit address bus. However this has no consequence either because on these models the built-in MMU (Memory Management Unit) is programmed to redirect register accesses that use 24 bit addresses to the appropriate 32 bit addresses */
                movem.l D0-D7,0xFFFF8240                                        /* Write all data registers (the full palette) to the video palette registers */
#endif
                addq.w  #TRUE,G350_B_SwitchToTopBottomPalette(A4)               /* Set flag so that during the next execution of this exception, the palette will be switched to the top/bottom palette */
                bra.s   T015_002
        T015_001:
                movem.l D0-D7,-(A7)
                movem.l G347_aui_Palette_TopAndBottomScreen(A4),D0-D7           /* Load all data registers with the color palette for the top and bottom of the screen. 8 registers * 4 bytes/register = 32 bytes */
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_06_OPTIMIZATION */
                movem.l D0-D7,0x00FF8240                                        /* Write all data registers (the full palette) to the video palette registers */
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_06_OPTIMIZATION */
                movem.l D0-D7,0xFFFF8240                                        /* Write all data registers (the full palette) to the video palette registers */
#endif
                andi.b  #0xFE,19(A0)                                            /* Clear bit 0 of LSB of Interrupt Mask Register A on the MFP. This masks interrupts for Timer B */
                andi.b  #0xFE,7(A0)                                             /* Clear bit 0 of LSB of Interrupt Enable Register A on the MFP. This disables interrupts for Timer B */
        T015_002:
                bclr    #0,15(A0)                                               /* Clear bit 0 of word of Interrupt In-Service Register A on the MFP. This marks the end of the processing of interrupt */
                movem.l (A7)+,D0-D7/A0/A4
                rte
        S016_xxxx_MAIN_DrawMousePointerHiddenScreenAreaIfNecessary_COPYPROTECTIONDF:
#ifndef NOCOPYPROTECTION
                tst.w   G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF(A4)
                bpl.s   T016_001                                                /* If DMA transfer is still ongoing (> 0) or if it succeeded (= 0) */
                move.w  G314_i_SectorsReadRequested_COPYPROTECTIONDF(A4),D1
                or.w    D1,G315_i_SectorsReadFailure_COPYPROTECTIONDF(A4)       /* Copy bits for requested sectors */
                clr.w   G314_i_SectorsReadRequested_COPYPROTECTIONDF(A4)        /* Clear flags */
                clr.w   G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF(A4)       /* Clear DMA error (negative value) */
        T016_001:
#endif
                tst.w   G595_B_MousePointerVisible(A4)
                bne.s   T016_002                                                /* If mouse pointer is currently displayed */
                rts
        T016_002:
                tst.w   D0
                bne.s   T016_008_DrawMousePointerHiddenScreenArea               /* Branch if D0 != 0. If removing the mouse pointer was requested (D0 is set by E017_xxxx_MAIN_Exception28Handler_VerticalBlank_COPYPROTECTIONDF) */
                tst.w   G354_i_MessageAreaScrollingLineCount(A4)
                blt.s   T016_003                                                /* If there is no ongoing scrolling of the message area */
                cmpi.w  #151,D5
                bcc.s   T016_008_DrawMousePointerHiddenScreenArea               /* If mouse pointer Y >= 151. If mouse pointer is over text area */
        T016_003:
                tst.w   G324_B_DrawViewportRequested(A4)
                beq.s   T016_006                                                /* If the viewport was not updated */
                cmpi.w  #169,D5
                bge.s   T016_006                                                /* If mouse pointer Y >= 169. If mouse pointer is not over the viewport */
                cmpi.w  #224,D4
                bge.s   T016_005                                                /* If mouse pointer X >= 224. If mouse pointer is not over the viewport */
                tst.w   G600_B_UseObjectAsMousePointerBitmap(A4)
                beq.s   T016_004                                                /* If the mouse pointer bitmap is not an object */
                tst.w   G602_B_CurrentMousePointerIsObject(A4)
                beq.s   T016_004                                                /* If the mouse pointer is not an object */
                cmpi.w  #23,D5
                ble.s   T016_006                                                /* If mouse pointer Y <= 23. Hotspot of an object mouse pointer is at coordinates 8,8 */
                bra.s   T016_008_DrawMousePointerHiddenScreenArea
        T016_004:
                cmpi.w  #16,D5
                blt.s   T016_006                                                /* If mouse pointer Y < 16 */
                bra.s   T016_008_DrawMousePointerHiddenScreenArea
        T016_005:
                tst.w   G600_B_UseObjectAsMousePointerBitmap(A4)
                beq.s   T016_006
                cmpi.w  #28,D5
                bgt.s   T016_006                                                /* If mouse pointer Y > 28 */
                cmpi.w  #23,D5
                ble.s   T016_006                                                /* If mouse pointer Y <= 23 */
                cmpi.w  #232,D4
                blt.s   T016_008_DrawMousePointerHiddenScreenArea               /* If mouse pointer X <= 232 */
        T016_006:
                tst.w   G340_B_HighlightBoxInversionRequested(A4)
                beq.s   T016_007                                                /* If no box is inversed */
                cmpi.w  #192,D4
                bge.s   T016_008_DrawMousePointerHiddenScreenArea               /* If mouse pointer X > 192 */
        T016_007:
                rts
        T016_008_DrawMousePointerHiddenScreenArea:
                moveq   #TRUE,D0                                                /* Mouse pointer is no more on screen and must be drawn later in E017_xxxx_MAIN_Exception28Handler_VerticalBlank_COPYPROTECTIONDF */
                jsr     S072_xxxx_MOUSE_DrawPointerHiddenScreenArea(PC)
                rts
        E017_xxxx_MAIN_Exception28Handler_VerticalBlank_COPYPROTECTIONDF:       /* This exception handler corresponds to processor interrupt 4 (vertical blank). The processor sets the 'interrupt priority mask' in sr to 4 before executing this exception handler. This means Horizontal Blank interrupts (level 2) and other Vertical Blank interrupts (level 4) are ignored and MFP interrupts (level 6) are processed */
                movem.l D0-D5/A0/A4-A5,-(A7)
                movea.l V011_1_xxx_RegisterA4Backup(PC),A4                      /* Restore A4 */
                movea.l V012_1_xxx_RegisterA5Backup(PC),A5                      /* Restore A5 */
                tst.w   G324_B_DrawViewportRequested(A4)
                beq.s   T017_001
                move.w  G323_B_EnablePaletteSwitchingRequested(A4),G322_B_PaletteSwitchingEnabled(A4)
        T017_001:                                                               /* BUG0_03 Graphical glitch. If a vertical blank interrupt occurs while processing of the previous vertical blank exception has not completed then the interrupt is ignored because of the interrupt mask automatically set by the processor when running the exception. Consequently, the palette switching code below is not executed and the dungeon view may be drawn on screen with the wrong color palette. This is only visible for a very short amount of time and disappears on the next vertical scan. The issue can occur when the processor is under heavy load because many other interrupts occur with a higher priority level than the vertical blank interrupt, such as sound processing (another interrupt that occurs thousands of times per second to play the sound) and mouse processing (another interrupt each time the mouse moves or button status changes). North American systems are more affected because the vertical blank interrupt occurs at 60 Hz rather than 50 Hz in European systems */
                tst.w   G322_B_PaletteSwitchingEnabled(A4)
                beq.s   T017_002                                                /* If palette switching is disabled */
                clr.w   G350_B_SwitchToTopBottomPalette(A4)
                movea.w #0xFA00,A0                                              /* This is the base address of the MFP */
                clr.b   27(A0)                                                  /* Clear LSB of Timer B control register on the MFP. This stops Timer B (it does not count anymore) */
                move.b  #31,33(A0)                                              /* Write 31 in LSB of Timer B data register. This is the initial counter value. The timer will decrement this value at each Horizontal Blank until it reaches 1, then it produces an interrupt. This is the line number where color palette will be switched (below champion status boxes and above the dungeon view) */
                move.b  #8,27(A0)                                               /* Write 8 in LSB of Timer B control register on the MFP. This sets Timer B in event count mode */
                ori.b   #1,19(A0)                                               /* Set bit 0 of LSB of Interrupt Mask Register A on the MFP. Interrupts for Timer B are not masked anymore */
                ori.b   #1,7(A0)                                                /* Set bit 0 of LSB of Interrupt Enable Register A on the MFP. This enables interrupts for Timer B */
        T017_002:
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_01_FIX The exception handler now changes the interrupt mask to 3 so that other vertical blank interrupts are not ignored anymore. When concurrent exceptions occur, the handler will only run the palette switching code and return after incrementing a counter for concurrent exceptions. At the end of the exception handler, if there are concurrent exceptions that were not fully processed, then they are processed in a loop. With this mechanism, vertical blank interrupts are never ignored so that the palette switching code always starts on time and the graphical glitches are avoided */
                tst.w   G351_i_ConcurrentVerticalBlankExceptionCount(A4)
                beq.s   T017_003                                                /* If no vertical blank exception is being processed */
                addq.w  #1,G351_i_ConcurrentVerticalBlankExceptionCount(A4)     /* If a vertical blank exception is already being processed then increment the counter and return */
                movem.l (A7)+,D0-D5/A0/A4-A5
                rte
        T017_003:
                addq.w  #1,G351_i_ConcurrentVerticalBlankExceptionCount(A4)     /* If no vertical blank exception is being processed then increment the counter */
        T017_004_Loop:
                move    SR,D0
                andi.w  #0xF8FF,D0
                ori.w   #0x0300,D0
                move    D0,SR                                                   /* Set interrupt priority mask = 3 in Status Register. All interrupts below or equal to 3 will now be ignored. This means Horizontal Blank interrupts (level 2) are ignored, Vertical Blank interrupts (level 4) and MFP interrupts (level 6) are processed. Other Vertical Blank interrupts are not ignored anymore and G351_i_ConcurrentVerticalBlankExceptionCount counts the number of such interrupts that occur concurrently */
#endif
                tst.w   G596_B_NoDrawInVerticalBlankWhileHidingMousePointer(A4)
                bne     T017_019
                moveq   #0,D0
                move.l  G590_i_MousePointerHotspotY(A4),D3                      /* The long contains both words for Y & X coordinates */
                move.l  D3,G591_l_MousePointerYX(A4)
                move.l  D3,D2
                swap    D2
                move.w  G603_i_MousePointerScreenAreaCurrentX(A4),D4
                move.w  G604_i_MousePointerScreenAreaCurrentY(A4),D5
                tst.w   G599_ui_UseChampionIconOrdinalAsMousePointerBitmap(A4)
                beq.s   T017_006                                                /* If no champion icon is being dragged */
                cmpi.w  #274,D3
                blt.s   T017_005                                                /* If mouse pointer X < 274. If the mouse pointer was dragged too far to the left */
                cmpi.w  #28,D2
                ble.s   T017_006                                                /* If mouse pointer Y <= 28. If the mouse pointer is still in the champion icons area */
        T017_005:
                movem.l D0-D3/A0-A1,-(A7)
                jsr     F071_xxxx_MOUSE_DropChampionIcon(PC)
                movem.l (A7)+,D0-D3/A0-A1
        T017_006:
                move.w  G593_B_BuildMousePointerScreenAreaCompleted(A4),D0      /* D0 is a boolean used by S016_xxxx_MAIN_DrawMousePointerHiddenScreenAreaIfNecessary_COPYPROTECTIONDF for 'Remove mouse pointer from screen, perform updates on screen then draw the mouse pointer back on screen' */
                clr.w   G593_B_BuildMousePointerScreenAreaCompleted(A4)         /* Reset request to force mouse pointer removal */
                tst.w   G592_B_BuildMousePointerScreenAreaRequested(A4)
                beq.s   T017_007
                tst.w   G598_B_MousePointerBitmapUpdated(A4)
                bne.s   T017_007                                                /* If the mouse pointer has changed */
                cmp.w   D3,D4                                                   /* If mouse pointer has moved */
                bne.s   T017_007
                cmp.w   D2,D5                                                   /* If mouse pointer has moved */
                bne.s   T017_007
                moveq   #TRUE,D0                                                /* Force mouse pointer removal and later mouse pointer draw */
                clr.w   G592_B_BuildMousePointerScreenAreaRequested(A4)
        T017_007:
                jsr     S016_xxxx_MAIN_DrawMousePointerHiddenScreenAreaIfNecessary_COPYPROTECTIONDF(PC)
#ifndef NOCOPYPROTECTION
                move.l  A0,-(A7)
                lea     G078_B_FuzzyBitFound_COPYPROTECTIONF+20(A4),A0
                tst.w   -20(A0)                                                 /* Refers to G078_B_FuzzyBitFound_COPYPROTECTIONF */
                bne.s   T017_008                                                /* If at least a fuzzy bit was found */
                tst.w   G328_i_TimeBombToKillParty_COPYPROTECTIONF(A4)
                bne.s   T017_008                                                /* If the time bomb to kill the party is already triggered */
                movem.l D0-D3/A0-A1,-(A7)
                jsr     F106_rzzz_DUNGEONVIEW_TestResetToStep1_COPYPROTECTIONF(PC)
                movem.l (A7)+,D0-D3/A0-A1
                addq.w  #5,G328_i_TimeBombToKillParty_COPYPROTECTIONF(A4)       /* Trigger the time bomb to kill the party */
        T017_008:
                movea.l (A7)+,A0
#endif
                tst.w   D0
                beq.s   T017_009                                                /* If the mouse pointer should not be drawn on screen */
                cmpi.w  #15,D2
                bhi.s   T017_009                                                /* If Mouse Y > 15 */
                jsr     S074_xxxx_MOUSE_DrawPointerScreenArea(PC)
                moveq   #FALSE,D0
        T017_009:
                tst.w   G354_i_MessageAreaScrollingLineCount(A4)
                blt.s   T017_010
                movem.l D0-D3/A0-A1,-(A7)
                move.w  #27,D1                                                  /* Number of pixel lines in the message area */
                sub.w   G354_i_MessageAreaScrollingLineCount(A4),D1
                mulu.w  #160,D1                                                 /* Each line is 320 pixels = 160 bytes */
                move.w  D1,-(A7)
                move.l  G348_pl_Bitmap_LogicalScreenBase(A4),D1
                addi.l  #27520,D1                                               /* Start of line 172 of the screen */
                move.l  D1,-(A7)
                addi.l  #160,D1                                                 /* Scroll 1 line */
                move.l  D1,-(A7)
                jsr     F007_aAA7_MAIN_CopyBytes(PC)
                adda.w  #10,A7
                movem.l (A7)+,D0-D3/A0-A1
                bra.s   T017_011
        T017_010:
                tst.w   G355_B_ScrollMessageArea(A4)
                beq.s   T017_013                                                /* If there is no new text line to inject at bottom of the screen */
                clr.w   G355_B_ScrollMessageArea(A4)
        T017_011:
                moveq   #7,D1                                                   /* Height in pixels of the text line */
                tst.w   G354_i_MessageAreaScrollingLineCount(A4)
                blt.s   T017_012                                                /* If there is no ongoing vertical scrolling of the message area */
                addq.w  #1,G354_i_MessageAreaScrollingLineCount(A4)             /* Add one more line of scrolling until the whole new line will be displayed on screen */
                move.w  G354_i_MessageAreaScrollingLineCount(A4),D1
                cmpi.w  #7,D1
                bne.s   T017_012
                move.w  #-1,G354_i_MessageAreaScrollingLineCount(A4)
        T017_012:
                movem.l D0-D3/A0-A1,-(A7)
                move.w  D1,D2
                mulu.w  #160,D1                                                 /* Number of bytes to move */
                move.w  D1,-(A7)
                neg.w   D2
                addi.w  #200,D2
                mulu.w  #160,D2
                add.l   G348_pl_Bitmap_LogicalScreenBase(A4),D2
                move.l  D2,-(A7)
                move.l  G356_puc_Bitmap_MessageAreaNewRow(A4),-(A7)
                jsr     F007_aAA7_MAIN_CopyBytes(PC)
                adda.w  #10,A7
                movem.l (A7)+,D0-D3/A0-A1
        T017_013:
                tst.w   G324_B_DrawViewportRequested(A4)
                beq.s   T017_016                                                /* If viewport was not updated */
                clr.w   G324_B_DrawViewportRequested(A4)
                movem.l D0-D7/A0-A4,-(A7)
                tst.w   G342_B_RefreshDungeonViewPaletteRequested(A4)
                beq.s   T017_014                                                /* If the color palette for the dungeon view has not changed */
                clr.w   G342_B_RefreshDungeonViewPaletteRequested(A4)
                lea     G021_aaui_Graphic562_Palette_DungeonView(A4),A0               /* Address of an array of 6 color palettes for dungeon view, depending on light in the dungeon */
                move.w  G304_i_DungeonViewPaletteIndex(A4),D0
                lsl.w   #5,D0                                                   /* Each palette in the table is 32 bytes large */
                adda.w  D0,A0                                                   /* Address of the selected palette in the array */
                movem.l (A0),D0-D7                                              /* The eight data registers are loaded with the palette data (8 registers of 4 bytes each = 32 bytes) */
                movem.l D0-D7,G346_aui_Palette_MiddleScreen(A4)                 /* The eight data registers are copied to G346_aui_Palette_MiddleScreen, which updates the color palette used by the palette switching routine */
        T017_014:
                movea.l G296_puc_Bitmap_Viewport(A4),A0
                movea.l G348_pl_Bitmap_LogicalScreenBase(A4),A1
                adda.w  #5280,A1                                                /* This is the starting address of the viewport area in the video memory */
                move.w  #135,D0                                                 /* The viewport has 136 lines (0 to 135) */
        T017_015:
                movem.l (A0)+,D1-D7/A2-A4                                       /* Copy 40 bytes of viewport data (80 pixels) in registers */
                movem.l D1-D7/A2-A4,(A1)                                        /* Copy 40 bytes from registers to the screen */
                movem.l (A0)+,D1-D7/A2-A4                                       /* Copy 40 bytes of viewport data (80 pixels) in registers */
                movem.l D1-D7/A2-A4,40(A1)                                      /* Copy 40 bytes from registers to the screen */
                movem.l (A0)+,D1-D7/A2                                          /* Copy 32 bytes of viewport data (64 pixels) in registers */
                movem.l D1-D7/A2,80(A1)                                         /* Copy 32 bytes from registers to the screen. 40 + 40 + 32 = 112 bytes = 224 pixels which is the viewport width */
                lea     160(A1),A1                                              /* This is the offset where the next viewport line starts (160 bytes = 320 pixels = 1 line on screen) */
                dbf     D0,T017_015
                movem.l (A7)+,D0-D7/A0-A4
        T017_016:
                tst.w   G340_B_HighlightBoxInversionRequested(A4)
                beq.s   T017_017                                                /* If there is no highlight box inversion request */
                clr.w   G340_B_HighlightBoxInversionRequested(A4)               /* Disable the highlight box inversion request */
                not.w   G341_B_HighlightBoxEnabled(A4)                          /* Value is inverted between $0000 (box is not inverted on screen) and $FFFF (box is inverted on screen) */
                movem.l D0-D3/A0-A1,-(A7)
                move.w  G339_i_HighlightBoxY2(A4),-(A7)
                move.w  G338_i_HighlightBoxY1(A4),-(A7)
                move.w  G337_i_HighlightBoxX2(A4),-(A7)
                move.w  G336_i_HighlightBoxX1(A4),-(A7)
                jsr     F006_aamz_MAIN_HighlightScreenBox(PC)
                addq.l  #8,A7
                movem.l (A7)+,D0-D3/A0-A1
        T017_017:
                tst.w   D0
                beq.s   T017_018                                                /* If the mouse pointer should not be drawn on screen */
                jsr     S074_xxxx_MOUSE_DrawPointerScreenArea(PC)
        T017_018:
                tst.w   G592_B_BuildMousePointerScreenAreaRequested(A4)
                beq.s   T017_019
                clr.w   G592_B_BuildMousePointerScreenAreaRequested(A4)
                move.w  #TRUE,G593_B_BuildMousePointerScreenAreaCompleted(A4)
                clr.w   G598_B_MousePointerBitmapUpdated(A4)
                movem.l D0-D3/A0-A1,-(A7)
                jsr     F073_xxxx_MOUSE_BuildPointerScreenArea(PC)
                movem.l (A7)+,D0-D3/A0-A1
        T017_019:
#ifndef NOCOPYPROTECTION
                tst.w   G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF(A4)
                ble.s   T017_020                                                /* If floppy disk transfer is complete (succeeded if = 0 or failed if < 0) */
                movea.l G626_pfV_S080_aaat_COPYPROTECTIONDF_CheckDMATransferCompletion(A4),A0
                move.l  A1,-(A7)
                jsr     (A0)
                movea.l (A7)+,A1
                bra.s   T017_021
        T017_020:
                tst.w   G624_B_FloppyDriveTurnedOn_COPYPROTECTIONDF(A4)
                beq.s   T017_021                                                /* If the floppy drive is turned off */
                movea.l G627_pfV_S081_aaao_COPYPROTECTIONDF_TurnOffFloppyDrive(A4),A0
                jsr     (A0)
        T017_021:
#endif
                addq.w  #1,G317_i_WaitForInputVerticalBlankCount(A4)
                move.w  G317_i_WaitForInputVerticalBlankCount(A4),D0
                cmp.w   G318_i_WaitForInputMaximumVerticalBlankCount(A4),D0
                bls.s   T017_022                                                /* Branch if G317_i_WaitForInputVerticalBlankCount <= G318_i_WaitForInputMaximumVerticalBlankCount */
                move.w  #TRUE,G321_B_StopWaitingForPlayerInput(A4)              /* This flag instructs the main loop to to increment the game time. This occurs every 11 vertical blank cycles */
        T017_022:
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_01_FIX */
                movem.l (A7)+,D0-D5/A0/A4-A5
                dc.w    0x4EF9                                                  /* Call the original exception handler with a jmp instruction */
        V017_1_xxx_JMPTargetAddress:
                dc.l    0x00000000
}
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_01_FIX */
                trap    #4                                                      /* Call the original exception handler for vertical blank. A trap instruction is used instead of the jmp in previous versions so that execution continues with the next instruction when the original exception handler returns with an rte instruction */
                move    SR,D0
                andi.w  #0xF8FF,D0
                ori.w   #0x0400,D0
                move    D0,SR                                                   /* Set interrupt priority mask = 4 in Status register. All interrupts below or equal to 4 will now be ignored. This means Horizontal Blank interrupts (level 2) and Vertical Blank interrupts (level 4) are ignored and MFP interrupts (level 6) are processed. This resets the interrupt priority mask to its regular value (set by the processor before running the exception handler). The rte instruction will restore the previous value of the SR register where the interrupt priority mask is usually 3 during execution of normal code (while not in an exception handler), which will enable again Vertical Blank interrupts */
                subq.w  #1,G351_i_ConcurrentVerticalBlankExceptionCount(A4)
                bne     T017_004_Loop
                movem.l (A7)+,D0-D5/A0/A4-A5
                rte
}
#endif

VOID F018_aaat_MAIN_SetExceptionVectors()
{
        asm {
                lea     E013_xxxx_MAIN_Exception69Handler_TimerC_DoNothing(PC),A0
                move.l  A0,C0x0114_ADDRESS_INTERRUPT_VECTOR_5_MFP_TIMER_C                     /* Replace Exception Vector 69 (MFP timer C (200Hz) System Clock, ST-MFP interrupt #5. Points to the system clock interrupt). This effectively disables the default handler (the new one is a simple RTE) */
                lea     V014_1_xxx_JMPTargetAddress(PC),A0                                    /* Address of the target address of the JMP instruction at the end of the exception 70 Handler prefix */
                move.l  C0x0118_ADDRESS_INTERRUPT_VECTOR_6_KEYBOARD_MIDI,(A0)                 /* Copy the address of the current exception 70 handler at the end of the custom handler prefix */
                lea     E014_xxxx_MAIN_Exception70Handler_KeyboardMIDI(PC),A0
                move.l  A0,C0x0118_ADDRESS_INTERRUPT_VECTOR_6_KEYBOARD_MIDI                   /* Replace Exception Vector 70 (IKBD/MIDI, ST-MFP interrupt #6. Points to the handler for IKBD and MIDI interrupts) */
                lea     E015_xxxx_MAIN_Exception72Handler_TimerB_PaletteSwitcher(PC),A0
                move.l  A0,C0x0120_ADDRESS_INTERRUPT_VECTOR_8_TIMER_B_HORIZONTAL_BLANK        /* Replace Exception Vector 72 (MFP timer B (HBL counter), ST-MFP interrupt #8) */
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_01_FIX */
                lea     V017_1_xxx_JMPTargetAddress(PC),A0
                move.l  C0x0070_ADDRESS_INTERRUPT_AUTOVECTOR_4_VERTICAL_BLANK,(A0)            /* Copy current Exception Vector 28 (vertical blank) in the jmp target address. The custom vertical blank handler calls the original handler via this jmp */
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_01_FIX The original vertical blank handler is now called via a TRAP #4 instruction instead of a jmp */
                move.l  C0x0070_ADDRESS_INTERRUPT_AUTOVECTOR_4_VERTICAL_BLANK,C0x0090_ADDRESS_INTERRUPT_VECTOR_TRAP_4 /* Copy current Exception Vector 28 (vertical blank) to Exception Vector 36 (TRAP #4). The custom vertical blank handler calls the original handler via TRAP #4 */
#endif
                lea     E017_xxxx_MAIN_Exception28Handler_VerticalBlank_COPYPROTECTIONDF(PC),A0
                move.l  A0,C0x0070_ADDRESS_INTERRUPT_AUTOVECTOR_4_VERTICAL_BLANK              /* Replace Exception Vector 28 */
        }
}

VOID F019_aarz_MAIN_DisplayErrorAndStop(P018_i_ErrorNumber)
int P018_i_ErrorNumber;
{
        Cconws("\33HSYSTEM ERROR "); /* \33H is the VT-52 command to move the mouse pointer to the top left corner. 33 (octal) = 1B (hexadecimal) = 27 (decimal) = ESC (Megamax C does not support hexadecimal character constants) */
        Cconout((P018_i_ErrorNumber / 10) + '0');
        Cconout((P018_i_ErrorNumber % 10) + '0');
        for(;;); /*_Infinite loop_*/
}

VOID F020_aAA5_MAIN_BlitToViewport(P019_puc_Bitmap, P020_pi_Box, P021_i_BitmapByteWidth, P022_i_TransparentColor)
unsigned char* P019_puc_Bitmap;
int* P020_pi_Box;
int P021_i_BitmapByteWidth;
int P022_i_TransparentColor;
{
        G578_B_UseByteBoxCoordinates = FALSE, F132_xzzz_VIDEO_Blit(P019_puc_Bitmap, G296_puc_Bitmap_Viewport, P020_pi_Box, 0, 0, P021_i_BitmapByteWidth, C112_BYTE_WIDTH_VIEWPORT, P022_i_TransparentColor);
}

VOID F021_a002_MAIN_BlitToScreen(P023_puc_Bitmap, P024_pi_Box, P025_i_BitmapByteWidth, P026_i_TransparentColor)
unsigned char* P023_puc_Bitmap;
int* P024_pi_Box;
int P025_i_BitmapByteWidth;
int P026_i_TransparentColor;
{
        G578_B_UseByteBoxCoordinates = FALSE, F132_xzzz_VIDEO_Blit(P023_puc_Bitmap, G348_pl_Bitmap_LogicalScreenBase, P024_pi_Box, 0, 0, P025_i_BitmapByteWidth, C160_BYTE_WIDTH_SCREEN, P026_i_TransparentColor);
}

VOID F022_aaaU_MAIN_Delay(P027_ui_VerticalBlankCount)
unsigned int P027_ui_VerticalBlankCount;
{
        while (P027_ui_VerticalBlankCount--) {
                Vsync();
        }
}

#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_01_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
int F023_aarz_MAIN_GetAbsoluteValue(P028_i_Value)
register int P028_i_Value;
{
        if (P028_i_Value < 0) {
                return -P028_i_Value;
        }
        return P028_i_Value;
}

int F024_aatz_MAIN_GetMinimumValue(P029_i_Value1, P030_i_Value2)
int P029_i_Value1;
int P030_i_Value2;
{
        if (P029_i_Value1 < P030_i_Value2) {
                return P029_i_Value1;
        }
        return P030_i_Value2;
}

int F025_aatz_MAIN_GetMaximumValue(P031_i_Value1, P032_i_Value2)
int P031_i_Value1;
int P032_i_Value2;
{
        if (P031_i_Value1 > P032_i_Value2) {
                return P031_i_Value1;
        }
        return P032_i_Value2;
}

int F026_a003_MAIN_GetBoundedValue(P033_i_MinimumAllowedValue, P034_i_Value, P035_i_MaximumAllowedValue)
int P033_i_MinimumAllowedValue;
int P034_i_Value;
int P035_i_MaximumAllowedValue;
{
        if (P034_i_Value < P033_i_MinimumAllowedValue) {
                return P033_i_MinimumAllowedValue;
        }
        if (P034_i_Value > P035_i_MaximumAllowedValue) {
                return P035_i_MaximumAllowedValue;
        }
        return P034_i_Value;
}

unsigned int F027_AA59_MAIN_Get16bitRandomNumber()
{
        return (unsigned int)((G349_ul_LastRandomNumber = G349_ul_LastRandomNumber * 3141592621 + 11) >> 8); /* Pseudorandom number generator */
}

unsigned int F028_a000_MAIN_Get1BitRandomNumber()
{
        return (unsigned int)((G349_ul_LastRandomNumber = G349_ul_LastRandomNumber * 3141592621 + 11) >> 8) & 0x0001; /* Pseudorandom number generator */
}

unsigned int F029_AA19_MAIN_Get2BitRandomNumber()
{
        return (unsigned int)((G349_ul_LastRandomNumber = G349_ul_LastRandomNumber * 3141592621 + 11) >> 8) & 0x0003; /* Pseudorandom number generator */
}

unsigned int F030_aaaW_MAIN_GetScaledProduct(P036_ui_Value1, P037_ui_Scale, P038_ui_Value2)
unsigned int P036_ui_Value1;
unsigned int P037_ui_Scale;
unsigned int P038_ui_Value2;
{
        return ((long)P036_ui_Value1 * P038_ui_Value2) >> P037_ui_Scale;
}
#endif

#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_01_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
int F023_aarz_MAIN_GetAbsoluteValue(P028_i_Value)
int P028_i_Value;
{
        asm {
                        move.w  P028_i_Value(A6),D0
                        bpl.s   T023_002_Return         /* Branch if D0 >= 0 */
                        neg.w   D0
                T023_002_Return:
        }
}

int F024_aatz_MAIN_GetMinimumValue(P029_i_Value1, P030_i_Value2)
int P029_i_Value1;
int P030_i_Value2;
{
        asm {
                        move.w  P029_i_Value1(A6),D0
                        cmp.w   P030_i_Value2(A6),D0
                        blt.s   T024_002_Return         /* Branch if D0 < P030_i_Value2 (signed comparison) */
                        move.w  P030_i_Value2(A6),D0
                T024_002_Return:
        }
}

int F025_aatz_MAIN_GetMaximumValue(P031_i_Value1, P032_i_Value2)
int P031_i_Value1;
int P032_i_Value2;
{
        asm {
                        move.w  P031_i_Value1(A6),D0
                        cmp.w   P032_i_Value2(A6),D0
                        bgt.s   T025_002_Return         /* Branch if D0 > P032_i_Value2 (signed comparison) */
                        move.w  P032_i_Value2(A6),D0
                T025_002_Return:
        }
}

int F026_a003_MAIN_GetBoundedValue(P033_i_MinimumAllowedValue, P034_i_Value, P035_i_MaximumAllowedValue)
int P033_i_MinimumAllowedValue;
int P034_i_Value;
int P035_i_MaximumAllowedValue;
{
        asm {
                        move.w  P034_i_Value(A6),D0
                        cmp.w   P033_i_MinimumAllowedValue(A6),D0
                        bgt.s   T026_001                                /* Branch if D0 > P033_i_MinimumAllowedValue (signed comparison) */
                        move.w  P033_i_MinimumAllowedValue(A6),D0
                        bra.s   T026_003_Return
                T026_001:
                        cmp.w   P035_i_MaximumAllowedValue(A6),D0
                        ble.s   T026_003_Return                         /* Branch if D0 <= P035_i_MaximumAllowedValue (signed comparison) */
                        move.w  P035_i_MaximumAllowedValue(A6),D0
                T026_003_Return:
        }
}

unsigned int F027_AA59_MAIN_Get16bitRandomNumber()
{
        asm {
                move.l  G349_ul_LastRandomNumber(A4),-(A7)
                move.l  #3141592621,-(A7)                       /* A classic value for pseudo random number generators (looks like first decimals of Pi, except the last two digits which are replaced by 21) */
                jsr     _lmul(PC)                               /* Multiply long values */
                moveq   #11,D0
                add.l   (A7)+,D0                                /* D0 = 11 + result of multiplication (from stack), then clean up stack */
                move.l  D0,G349_ul_LastRandomNumber(A4)
                lsr.l   #8,D0                                   /* Return value is between 0 and 65535 */
        }
}

unsigned int F028_a000_MAIN_Get1BitRandomNumber()
{
        asm {
                move.l  G349_ul_LastRandomNumber(A4),-(A7)
                move.l  #3141592621,-(A7)                       /* A classic value for pseudo random number generators (looks like first decimals of Pi, except the last two digits which are replaced by 21) */
                jsr     _lmul(PC)                               /* Multiply long values */
                moveq   #11,D0
                add.l   (A7)+,D0                                /* D0 = 11 + result of multiplication (from stack), then clean up stack */
                move.l  D0,G349_ul_LastRandomNumber(A4)
                lsr.l   #8,D0
                and.w   #0x0001,D0                              /* Return value is 0 or 1 */
        }
}

unsigned int F029_AA19_MAIN_Get2BitRandomNumber()
{
        asm {
                move.l  G349_ul_LastRandomNumber(A4),-(A7)
                move.l  #3141592621,-(A7)                       /* A classic value for pseudo random number generators (looks like first decimals of Pi, except the last two digits which are replaced by 21) */
                jsr     _lmul(PC)                               /* Multiply long values */
                moveq   #11,D0
                add.l   (A7)+,D0                                /* D0 = 11 + result of multiplication (from stack), then clean up stack */
                move.l  D0,G349_ul_LastRandomNumber(A4)
                lsr.l   #8,D0
                and.w   #0x0003,D0                              /* Return value is 0, 1, 2 or 3 */
        }
}

unsigned int F030_aaaW_MAIN_GetScaledProduct(P036_ui_Value1, P037_ui_Scale, P038_ui_Value2)
unsigned int P036_ui_Value1;
unsigned int P037_ui_Scale;
unsigned int P038_ui_Value2;
{
        asm {
                move.w  P036_ui_Value1(A6),D0
                mulu.w  P038_ui_Value2(A6),D0
                move.w  P037_ui_Scale(A6),D1
                asr.l   D1,D0                   /* Arithmetic Shift Right bits in D0 by D1 cells. D0 = D0 / 2^D1 */
        }
}
#endif
