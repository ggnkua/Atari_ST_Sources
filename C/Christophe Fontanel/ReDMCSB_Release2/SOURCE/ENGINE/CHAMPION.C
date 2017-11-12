#include "DEFS.H"

/*_Global variables_*/
PARTY G407_s_Party;
#ifndef NOCOPYPROTECTION
char G408_ac_CodePatch3_COPYPROTECTIONE[68];
#endif
int G409_ai_ChampionPendingDamage[4];
int G410_ai_ChampionPendingWounds[4];
int G411_i_LeaderIndex = CM1_CHAMPION_NONE;
unsigned char* G412_puc_Bitmap_ObjectIconForMousePointer;
int G413_i_LeaderHandObjectIconIndex;
THING G414_T_LeaderHandObject;
BOOLEAN G415_B_LeaderEmptyHanded;
int G416_i_Useless; /* BUG0_00 Useless code */
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
char* G417_apc_BaseSkillNames[4] = { "FIGHTER", "NINJA", "PRIEST", "WIZARD" };
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
char* G417_apc_BaseSkillNames[4] = { "KAMPFER", "NINJA", "PRIESTER", "MAGIER" };
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
char* G417_apc_BaseSkillNames[4] = { "GUERRIER", "NINJA", "PRETRE", "SORCIER" };
#endif
#ifndef NOCOPYPROTECTION
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_04_IMPROVEMENT */
long G418_l_LastEvent22Time_COPYPROTECTIONE;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_04_IMPROVEMENT */
long G418_l_LastEvent22Time_COPYPROTECTIONE = -505; /* This value ensures that the first time F003_aaaS_MAIN_ProcessNewPartyMap_COPYPROTECTIONE is run it will trigger COPYPROTECTIONE and allows adding events in F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE */
#endif
#endif


overlay "player"

VOID F278_apzz_CHAMPION_ResetDataToStartGame()
{
        register int L0785_i_ChampionIndex;
        register int L0786_i_Unreferenced; /* BUG0_00 Useless code */
        register THING L0787_T_Thing;
        register CHAMPION* L0788_ps_Champion;
        register char* L0789_pc_Unreferenced; /* BUG0_00 Useless code */
        char L0790_ac_Unreferenced[8]; /* BUG0_00 Useless code */


        if (!G298_B_NewGame) {
                if ((L0787_T_Thing = G414_T_LeaderHandObject) == C0xFFFF_THING_NONE) {
                        G415_B_LeaderEmptyHanded = TRUE;
                        G413_i_LeaderHandObjectIconIndex = CM1_ICON_NONE;
                        F069_aaaL_MOUSE_SetPointer();
                } else {
                        F297_atzz_CHAMPION_PutObjectInLeaderHand(L0787_T_Thing, TRUE); /* This call will add the weight of the leader hand object to the Load of the leader a first time */
                }
                L0788_ps_Champion = G407_s_Party.Champions;
                for(L0785_i_ChampionIndex = C00_CHAMPION_FIRST; L0785_i_ChampionIndex < G305_ui_PartyChampionCount; L0785_i_ChampionIndex++, L0788_ps_Champion++) {
                        M09_CLEAR(L0788_ps_Champion->Attributes, MASK0x0080_NAME_TITLE | MASK0x0100_STATISTICS | MASK0x0200_LOAD | MASK0x0400_ICON | MASK0x0800_PANEL | MASK0x1000_STATUS_BOX | MASK0x2000_WOUNDS | MASK0x4000_VIEWPORT | MASK0x8000_ACTION_HAND);
                        M08_SET(L0788_ps_Champion->Attributes, MASK0x8000_ACTION_HAND | MASK0x1000_STATUS_BOX | MASK0x0400_ICON);
                }
                F293_ahzz_CHAMPION_DrawAllChampionStates();
                if ((L0785_i_ChampionIndex = G411_i_LeaderIndex) != CM1_CHAMPION_NONE) {
                        G411_i_LeaderIndex = CM1_CHAMPION_NONE;
                        F368_fzzz_COMMAND_SetLeader(L0785_i_ChampionIndex); /* BUG0_32 The load of a champion with no objects in his inventory is not 0. If you save the game with an object in the leader hand then when you resume or restart the game the weight of the object in the leader hand is permanently added to the load of the leader. When the game is saved, the weight of the leader hand object is substracted from the load of the leader. But when the game is loaded, the weight of the leader hand object is added twice to the load of the leader: a first time by the call to F297_atzz_CHAMPION_PutObjectInLeaderHand above and a second time by this call to F368_fzzz_COMMAND_SetLeader */
                }
                if ((L0785_i_ChampionIndex = G514_i_MagicCasterChampionIndex) != CM1_CHAMPION_NONE) {
                        G514_i_MagicCasterChampionIndex = CM1_CHAMPION_NONE;
                        F394_ozzz_MENUS_SetMagicCasterAndDrawSpellArea(L0785_i_ChampionIndex);
                }
        } else {
                G414_T_LeaderHandObject = C0xFFFF_THING_NONE;
                G413_i_LeaderHandObjectIconIndex = CM1_ICON_NONE;
                G415_B_LeaderEmptyHanded = TRUE;
        }
}

#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_16_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
int F279_xxxx_CHAMPION_GetDecodedValue(P594_pc_String, P595_ui_CharacterCount)
register char* P594_pc_String;
register unsigned int P595_ui_CharacterCount;
{
        register int L0791_i_CharacterIndex;
        register int L0792_i_Value;


        L0792_i_Value = 0;
        for(L0791_i_CharacterIndex = 0; L0791_i_CharacterIndex < P595_ui_CharacterCount; L0791_i_CharacterIndex++) {
                L0792_i_Value = (L0792_i_Value << 4) + (*P594_pc_String++ - 'A');
        }
        return L0792_i_Value;
}
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_16_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
int F279_xxxx_CHAMPION_GetDecodedValue(P594_pc_String, P595_ui_CharacterCount)
char* P594_pc_String;
unsigned int P595_ui_CharacterCount;
{
        asm {
                        movea.l P594_pc_String(A6),A0
                        moveq   #0,D0
                T279_001_Loop:
                        asl.w   #4,D0                           /* Make place for the next nibble */
                        moveq   #-'A',D1
                        add.b   (A0)+,D1                        /* This converts one ASCII character to a nibble value 0..15 (only characters 'A' to 'P' are permitted in the strings) */
                        add.b   D1,D0
                        subq.w  #1,P595_ui_CharacterCount(A6)
                        bne.s   T279_001_Loop
        }
}
#endif

VOID F280_agzz_CHAMPION_AddCandidateChampionToParty(P596_ui_ChampionPortraitIndex)
unsigned int P596_ui_ChampionPortraitIndex;
{
        register THING L0793_T_Thing;
        register unsigned int L0794_ui_Multiple;
#define A0794_ui_ViewCell       L0794_ui_Multiple
#define A0794_ui_SlotIndex      L0794_ui_Multiple
#define A0794_ui_CharacterIndex L0794_ui_Multiple
#define A0794_ui_StatisticIndex L0794_ui_Multiple
#define A0794_ui_SkillIndex     L0794_ui_Multiple
        register int L0795_i_HiddenSkillIndex;
        register unsigned int L0796_ui_Multiple;
#define A0796_ui_Character  L0796_ui_Multiple
#define A0796_ui_SkillValue L0796_ui_Multiple
#define A0796_ui_ThingType  L0796_ui_Multiple
        register CHAMPION* L0797_ps_Champion;
        register char* L0798_pc_Character;
        int L0799_i_PreviousPartyChampionCount;
        unsigned int L0800_ui_Multiple;
#define A0800_B_ChampionTitleCopied L0800_ui_Multiple
#define A0800_ui_HiddenSkillCounter L0800_ui_Multiple
        unsigned int L0801_ui_SlotIndex;
        int L0802_i_MapX;
        int L0803_i_MapY;
        unsigned int L0804_ui_ChampionObjectsCell;
        int L0805_i_ObjectAllowedSlots;
        long L0806_l_BaseSkillExperience;
        char L0807_ac_DecodedChampionText[78];


        if (!G415_B_LeaderEmptyHanded) {
                return;
        }
        if (G305_ui_PartyChampionCount == 4) {
                return;
        }
        L0797_ps_Champion = &G407_s_Party.Champions[L0799_i_PreviousPartyChampionCount = G305_ui_PartyChampionCount];
        F008_aA19_MAIN_ClearBytes(L0797_ps_Champion, sizeof(CHAMPION));
        G578_B_UseByteBoxCoordinates = TRUE, F132_xzzz_VIDEO_Blit(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C026_GRAPHIC_CHAMPION_PORTRAITS), L0797_ps_Champion->Portrait, &G047_s_Graphic562_Box_ChampionPortrait, M27_PORTRAIT_X(P596_ui_ChampionPortraitIndex), M28_PORTRAIT_Y(P596_ui_ChampionPortraitIndex), C128_BYTE_WIDTH, C016_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
        L0797_ps_Champion->Useless1 = 1; /* BUG0_00 Useless code */
        L0797_ps_Champion->Useless2 = 2; /* BUG0_00 Useless code */
        L0797_ps_Champion->ActionIndex = C255_ACTION_NONE;
        L0797_ps_Champion->EnableActionEventIndex = -1;
        L0797_ps_Champion->HideDamageReceivedEventIndex = -1;
        L0797_ps_Champion->Direction = G308_i_PartyDirection;
        for(A0794_ui_ViewCell = C00_VIEW_CELL_FRONT_LEFT; F285_szzz_CHAMPION_GetIndexInCell(M21_NORMALIZE(A0794_ui_ViewCell + G308_i_PartyDirection)) != CM1_CHAMPION_NONE; A0794_ui_ViewCell++);
        L0797_ps_Champion->Cell = M21_NORMALIZE(A0794_ui_ViewCell + G308_i_PartyDirection);
        L0797_ps_Champion->Attributes = MASK0x0400_ICON;
        L0797_ps_Champion->DirectionMaximumDamageReceived = G308_i_PartyDirection;
        L0797_ps_Champion->Food = 1500 + M03_RANDOM(256);
        L0797_ps_Champion->Water = 1500 + M03_RANDOM(256);
        for(A0794_ui_SlotIndex = C00_SLOT_READY_HAND; A0794_ui_SlotIndex < C30_SLOT_CHEST_1; A0794_ui_SlotIndex++) {
                L0797_ps_Champion->Slots[A0794_ui_SlotIndex] = C0xFFFF_THING_NONE;
        }
        for(L0793_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(G306_i_PartyMapX, G307_i_PartyMapY); M12_TYPE(L0793_T_Thing) != C02_THING_TYPE_TEXT; L0793_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0793_T_Thing));
        F168_ajzz_DUNGEON_DecodeText(L0798_pc_Character = &L0807_ac_DecodedChampionText, L0793_T_Thing, C2_TEXT_TYPE_SCROLL | MASK0x8000_DECODE_EVEN_IF_INVISIBLE);
        A0794_ui_CharacterIndex = 0;
        while ((A0796_ui_Character = *L0798_pc_Character++) != '\n') { /* New line */
                L0797_ps_Champion->Name[A0794_ui_CharacterIndex++] = A0796_ui_Character;
        }
        L0797_ps_Champion->Name[A0794_ui_CharacterIndex] = '\0';
        A0794_ui_CharacterIndex = 0;
        A0800_B_ChampionTitleCopied = FALSE;
        do {
                A0796_ui_Character = *L0798_pc_Character++;
                if (A0796_ui_Character == '\n') { /* New line */
                        if (A0800_B_ChampionTitleCopied) {
                                break;
                        }
                        A0800_B_ChampionTitleCopied = TRUE;
                } else {
                        L0797_ps_Champion->Title[A0794_ui_CharacterIndex++] = A0796_ui_Character;
                }
        } while ();
        L0797_ps_Champion->Title[A0794_ui_CharacterIndex] = '\0';
        if (*L0798_pc_Character++ == 'M') {
                M08_SET(L0797_ps_Champion->Attributes, MASK0x0010_MALE);
        }
        L0798_pc_Character++;
        L0797_ps_Champion->CurrentHealth = L0797_ps_Champion->MaximumHealth = F279_xxxx_CHAMPION_GetDecodedValue(L0798_pc_Character, 4);
        L0798_pc_Character += 4;
        L0797_ps_Champion->CurrentStamina = L0797_ps_Champion->MaximumStamina = F279_xxxx_CHAMPION_GetDecodedValue(L0798_pc_Character, 4);
        L0798_pc_Character += 4;
        L0797_ps_Champion->CurrentMana = L0797_ps_Champion->MaximumMana = F279_xxxx_CHAMPION_GetDecodedValue(L0798_pc_Character, 4);
        L0798_pc_Character += 4;
        L0798_pc_Character++;
        for(A0794_ui_StatisticIndex = C0_STATISTIC_LUCK; A0794_ui_StatisticIndex <= C6_STATISTIC_ANTIFIRE; A0794_ui_StatisticIndex++) {
                L0797_ps_Champion->Statistics[A0794_ui_StatisticIndex][C2_MINIMUM] = 30;
                L0797_ps_Champion->Statistics[A0794_ui_StatisticIndex][C1_CURRENT] = L0797_ps_Champion->Statistics[A0794_ui_StatisticIndex][C0_MAXIMUM] = F279_xxxx_CHAMPION_GetDecodedValue(L0798_pc_Character, 2);
                L0798_pc_Character += 2;
        }
        L0797_ps_Champion->Statistics[C0_STATISTIC_LUCK][C2_MINIMUM] = 10;
        L0798_pc_Character++;
        for(A0794_ui_SkillIndex = C04_SKILL_SWING; A0794_ui_SkillIndex <= C19_SKILL_WATER; A0794_ui_SkillIndex++) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_06_FIX Useless code removed. All bytes are already cleared before this loop */
                L0797_ps_Champion->Skills[A0794_ui_SkillIndex].TemporaryExperience = 0;
                if ((A0796_ui_SkillValue = *L0798_pc_Character++ - 'A') == 0) {
                        L0797_ps_Champion->Skills[A0794_ui_SkillIndex].Experience = 0;
                } else {
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_06_FIX Useless code removed */
                if ((A0796_ui_SkillValue = *L0798_pc_Character++ - 'A') > 0 ) {
#endif
                        L0797_ps_Champion->Skills[A0794_ui_SkillIndex].Experience = 125L << A0796_ui_SkillValue;
                }
        }
        for(A0794_ui_SkillIndex = C00_SKILL_FIGHTER; A0794_ui_SkillIndex <= C03_SKILL_WIZARD; A0794_ui_SkillIndex++) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_06_FIX Useless code removed. All bytes are already cleared before this loop */
                L0797_ps_Champion->Skills[A0794_ui_SkillIndex].TemporaryExperience = 0;
#endif
                L0806_l_BaseSkillExperience = 0;
                L0795_i_HiddenSkillIndex = (A0794_ui_SkillIndex + 1) << 2;
                for(A0800_ui_HiddenSkillCounter = 0; A0800_ui_HiddenSkillCounter < 4; A0800_ui_HiddenSkillCounter++) {
                        L0806_l_BaseSkillExperience += L0797_ps_Champion->Skills[L0795_i_HiddenSkillIndex + A0800_ui_HiddenSkillCounter].Experience;
                }
                L0797_ps_Champion->Skills[A0794_ui_SkillIndex].Experience = L0806_l_BaseSkillExperience;
        }
        G299_ui_CandidateChampionOrdinal = L0799_i_PreviousPartyChampionCount + 1;
        if (++G305_ui_PartyChampionCount == 1) {
                F368_fzzz_COMMAND_SetLeader(C00_CHAMPION_FIRST);
                G508_B_RefreshActionArea = TRUE;
        } else { /* BUG0_33 The highlighted box around the acting champion's action hand is not cleared when clicking on a champion mirror. There is no code to clear the acting champion before opening the inventory of a candidate champion in a mirror */
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_08_FIX Clear the acting champion before drawing the action icon of the candidate champion */
                F388_rzzz_MENUS_ClearActingChampion();
#endif
                F386_ezzz_MENUS_DrawActionIcon(G305_ui_PartyChampionCount - 1); /* BUG0_34 Graphical glitch when you quickly move the mouse into the action area after clicking on a portrait. If you quickly move the mouse pointer over the action area where the action icon for the candidate champion will be drawn after clicking on a portrait and before the inventory is drawn on screen then there may be a graphical glitch where the mouse pointer erases a part of the action icon with a black rectangle in the action area 'behind' the mouse pointer. This is because the mouse pointer is not hidden while drawing the action icon (with F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE and F078_xzzz_MOUSE_ShowPointer). When the mouse pointer is moved over the action area, it captures the black pixels behind the pointer. The action icon is drawn and when the inventory is open, the mouse cursor is hidden which causes the captured black pixels to replace part of the action icon */
        }
        L0802_i_MapX = G306_i_PartyMapX;
        L0803_i_MapY = G307_i_PartyMapY;
        L0804_ui_ChampionObjectsCell = M18_OPPOSITE(G308_i_PartyDirection);
        L0802_i_MapX += G233_ai_Graphic559_DirectionToStepEastCount[G308_i_PartyDirection], L0803_i_MapY += G234_ai_Graphic559_DirectionToStepNorthCount[G308_i_PartyDirection];
        L0793_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(L0802_i_MapX, L0803_i_MapY);
        A0794_ui_SlotIndex = C13_SLOT_BACKPACK_LINE1_1;
        while (L0793_T_Thing != C0xFFFE_THING_ENDOFLIST) {
                if (((A0796_ui_ThingType = M12_TYPE(L0793_T_Thing)) > C03_THING_TYPE_SENSOR) && (M11_CELL(L0793_T_Thing) == L0804_ui_ChampionObjectsCell)) {
                        L0805_i_ObjectAllowedSlots = G237_as_Graphic559_ObjectInfo[F141_anzz_DUNGEON_GetObjectInfoIndex(L0793_T_Thing)].AllowedSlots;
                        switch (A0796_ui_ThingType) {
                                case C06_THING_TYPE_ARMOUR:
                                        for(L0801_ui_SlotIndex = C02_SLOT_HEAD; L0801_ui_SlotIndex <= C05_SLOT_FEET; L0801_ui_SlotIndex++) {
                                                if (L0805_i_ObjectAllowedSlots & G038_ai_Graphic562_SlotMasks[L0801_ui_SlotIndex]) {
                                                        goto T280_048;
                                                }
                                        }
                                        if ((L0805_i_ObjectAllowedSlots & G038_ai_Graphic562_SlotMasks[C10_SLOT_NECK]) && (L0797_ps_Champion->Slots[C10_SLOT_NECK] == C0xFFFF_THING_NONE)) {
                                                L0801_ui_SlotIndex = C10_SLOT_NECK;
                                        } else {
                                                goto T280_046;
                                        }
                                        break;
                                case C05_THING_TYPE_WEAPON:
                                        if (L0797_ps_Champion->Slots[C01_SLOT_ACTION_HAND] == C0xFFFF_THING_NONE) {
                                                L0801_ui_SlotIndex = C01_SLOT_ACTION_HAND;
                                        } else {
                                                goto T280_046;
                                        }
                                        break;
                                case C07_THING_TYPE_SCROLL:
                                case C08_THING_TYPE_POTION:
                                        if (L0797_ps_Champion->Slots[C11_SLOT_POUCH_1] == C0xFFFF_THING_NONE) {
                                                L0801_ui_SlotIndex = C11_SLOT_POUCH_1;
                                        } else {
                                                if (L0797_ps_Champion->Slots[C06_SLOT_POUCH_2] == C0xFFFF_THING_NONE) {
                                                        L0801_ui_SlotIndex = C06_SLOT_POUCH_2;
                                                } else {
                                                        goto T280_046;
                                                }
                                        }
                                        break;
                                case C09_THING_TYPE_CONTAINER:
                                case C10_THING_TYPE_JUNK:
                                        T280_046:
                                        if ((L0805_i_ObjectAllowedSlots & G038_ai_Graphic562_SlotMasks[C10_SLOT_NECK]) && (L0797_ps_Champion->Slots[C10_SLOT_NECK] == C0xFFFF_THING_NONE)) {
                                                L0801_ui_SlotIndex = C10_SLOT_NECK;
                                        } else {
                                                L0801_ui_SlotIndex = A0794_ui_SlotIndex++;
                                        }
                        }
                        T280_048:
                        if (L0797_ps_Champion->Slots[L0801_ui_SlotIndex] != C0xFFFF_THING_NONE) {
                                goto T280_046;
                        }
                        F301_apzz_CHAMPION_AddObjectInSlot(L0799_i_PreviousPartyChampionCount, L0793_T_Thing, L0801_ui_SlotIndex);
                }
                L0793_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0793_T_Thing);
        }
        F355_hzzz_INVENTORY_Toggle_COPYPROTECTIONE(L0799_i_PreviousPartyChampionCount);
        F456_vzzz_START_DrawDisabledMenus();
}

VOID F281_xxxx_CHAMPION_Rename(P597_ps_Champion)
register CHAMPION* P597_ps_Champion;
{
        register unsigned int L0808_ui_Multiple;
#define A0808_ui_CharacterIndex L0808_ui_Multiple
#define A0808_ui_ChampionIndex  L0808_ui_Multiple
        register int L0809_i_RenamedChampionString;
        register int L0810_i_Character;
        register BOOLEAN L0811_B_ChampionTitleIsFull;
        register char* L0812_pc_RenamedChampionString;
        int L0813_i_X;
        int L0814_i_Y;
        BOX_WORD L0815_s_Box;
        unsigned int L0816_ui_MousePointerHotspotX;
        unsigned int L0817_ui_MousePointerHotspotY;
        int L0818_i_NewLeftMouseButtonStatus;
        int L0819_i_OldLeftMouseButtonStatus;
        int L0820_i_CharacterIndexBackup;
        char L0821_ac_ChampionNameBackupString[8];


        L0815_s_Box.Y1 = 3;
        L0815_s_Box.Y2 = 8;
        L0815_s_Box.X2 = (L0815_s_Box.X1 = 3) + 167;
        F135_xzzz_VIDEO_FillBox(G296_puc_Bitmap_Viewport, &L0815_s_Box, C12_COLOR_DARKEST_GRAY, C112_BYTE_WIDTH_VIEWPORT); /* Erase the champion name and title */
        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C027_GRAPHIC_PANEL_RENAME_CHAMPION), &G032_s_Graphic562_Box_Panel, C072_BYTE_WIDTH, C04_COLOR_CYAN);
        F052_aaoz_TEXT_PrintToViewport(177, 58, C13_COLOR_LIGHTEST_GRAY, "_______");
        F052_aaoz_TEXT_PrintToViewport(105, 76, C13_COLOR_LIGHTEST_GRAY, "___________________");
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        F097_lzzz_DUNGEONVIEW_DrawViewport(C0_VIEWPORT_NOT_DUNGEON_VIEW);
        F067_aaat_MOUSE_SetPointerToNormal(C0_POINTER_ARROW);
        F078_xzzz_MOUSE_ShowPointer();
        P597_ps_Champion->Name[A0808_ui_CharacterIndex = 0] = '\0';
        P597_ps_Champion->Title[0] = '\0';
        L0809_i_RenamedChampionString = C1_RENAME_CHAMPION_NAME;
        L0812_pc_RenamedChampionString = P597_ps_Champion->Name;
        L0813_i_X = 177;
        L0814_i_Y = 91;
        L0819_i_OldLeftMouseButtonStatus = M07_GET(G588_i_MouseButtonsStatus, MASK0x0002_MOUSE_LEFT_BUTTON);
        do {
                if (!(L0811_B_ChampionTitleIsFull = ((L0809_i_RenamedChampionString == C2_RENAME_CHAMPION_TITLE) && A0808_ui_CharacterIndex == 19))) {
                        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                        F040_aacZ_TEXT_Print(G348_pl_Bitmap_LogicalScreenBase, C160_BYTE_WIDTH_SCREEN, L0813_i_X, L0814_i_Y, C09_COLOR_GOLD, C12_COLOR_DARKEST_GRAY, G051_ac_Graphic562_UnderscoreCharacterString);
                        F078_xzzz_MOUSE_ShowPointer();
                }
                while (!Cconis()) {
                        L0818_i_NewLeftMouseButtonStatus = M07_GET(G588_i_MouseButtonsStatus, MASK0x0002_MOUSE_LEFT_BUTTON);
                        if (L0818_i_NewLeftMouseButtonStatus && !L0819_i_OldLeftMouseButtonStatus) { /* If left mouse button status has changed */
                                L0816_ui_MousePointerHotspotX = G589_i_MousePointerHotspotX;
                                L0817_ui_MousePointerHotspotY = G590_i_MousePointerHotspotY;
                                if ((L0809_i_RenamedChampionString == C2_RENAME_CHAMPION_TITLE || (A0808_ui_CharacterIndex > 0)) && (L0816_ui_MousePointerHotspotX >= 197) && (L0816_ui_MousePointerHotspotX <= 215) && (L0817_ui_MousePointerHotspotY >= 147) && (L0817_ui_MousePointerHotspotY <= 155)) { /* Coordinates of 'OK' button */
                                        L0820_i_CharacterIndexBackup = A0808_ui_CharacterIndex;
                                        strcpy(L0821_ac_ChampionNameBackupString, L0812_pc_RenamedChampionString = P597_ps_Champion->Name);
                                        A0808_ui_CharacterIndex = strlen(L0812_pc_RenamedChampionString);
                                        while (L0812_pc_RenamedChampionString[--A0808_ui_CharacterIndex] == ' ') { /* Replace space characters on the right of the champion name by '\0' characters */
                                                L0812_pc_RenamedChampionString[A0808_ui_CharacterIndex] = '\0';
                                        }
                                        for(A0808_ui_ChampionIndex = C00_CHAMPION_FIRST; A0808_ui_ChampionIndex < G305_ui_PartyChampionCount - 1; A0808_ui_ChampionIndex++) {
                                                if (!strcmp(G407_s_Party.Champions[A0808_ui_ChampionIndex].Name, L0812_pc_RenamedChampionString)) { /* If an existing champion already has the specified name for the new champion */
                                                        goto T281_011_ContinueRename;
                                                }
                                        }
                                        return;
                                        T281_011_ContinueRename:
                                        if (L0809_i_RenamedChampionString == C2_RENAME_CHAMPION_TITLE) {
                                                L0812_pc_RenamedChampionString = P597_ps_Champion->Title;
                                        }
                                        strcpy(L0812_pc_RenamedChampionString = P597_ps_Champion->Name, L0821_ac_ChampionNameBackupString);
                                        A0808_ui_CharacterIndex = L0820_i_CharacterIndexBackup;
                                } else {
                                        if ((L0816_ui_MousePointerHotspotX >= 107) && (L0816_ui_MousePointerHotspotX <= 175) && (L0817_ui_MousePointerHotspotY >= 147) && (L0817_ui_MousePointerHotspotY <= 155)) { /* Coordinates of 'BACKSPACE' button */
                                                L0810_i_Character = '\b';
                                                break;
                                        }
                                        if ((L0816_ui_MousePointerHotspotX < 107) || (L0816_ui_MousePointerHotspotX > 215) || (L0817_ui_MousePointerHotspotY < 116) || (L0817_ui_MousePointerHotspotY > 144)) {/* Coordinates of table of all other characters */
                                                goto T281_023;
                                        }
                                        if (!((L0816_ui_MousePointerHotspotX + 4) % 10) || (!((L0817_ui_MousePointerHotspotY + 5) % 10) && ((L0816_ui_MousePointerHotspotX < 207) || (L0817_ui_MousePointerHotspotY != 135)))) {
                                                goto T281_023;
                                        }
                                        L0810_i_Character = 'A' + (11 * ((L0817_ui_MousePointerHotspotY - 116) / 10)) + ((L0816_ui_MousePointerHotspotX - 107) / 10);
                                        if ((L0810_i_Character == 86) || (L0810_i_Character == 97)) { /* The 'Return' button occupies two cells in the table */
                                                L0810_i_Character = '\r'; /* Carriage return */
                                                break;
                                        }
                                        if (L0810_i_Character >= 87) { /* Compensate for the first cell occupied by 'Return' button */
                                                L0810_i_Character--;
                                        }
                                        if (L0810_i_Character > 'Z') {
                                                L0810_i_Character = G053_ac_Graphic562_ReincarnateSpecialCharacters[(L0810_i_Character - 'Z') - 1];
                                        }
                                        break;
                                }
                        }
                        T281_023:
                        L0819_i_OldLeftMouseButtonStatus = L0818_i_NewLeftMouseButtonStatus;
                        Vsync();
                }
                L0819_i_OldLeftMouseButtonStatus = L0818_i_NewLeftMouseButtonStatus;
                if (Cconis()) {
                        L0810_i_Character = Crawcin();
                }
                if ((L0810_i_Character >= 'a') && (L0810_i_Character <= 'z')) {
                        L0810_i_Character -= 32; /* Convert to uppercase */
                }
                if (((L0810_i_Character >= 'A') && (L0810_i_Character <= 'Z')) || (L0810_i_Character == '.') || (L0810_i_Character == ',') || (L0810_i_Character == ';') || (L0810_i_Character == ':') || (L0810_i_Character == ' ')) {
                        if ((L0810_i_Character == ' ') && A0808_ui_CharacterIndex == 0) {
                        } else {
                                if (!L0811_B_ChampionTitleIsFull) {
                                        G052_ac_Graphic562_RenameChampionInputCharacterString[0] = L0810_i_Character;
                                        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                                        F040_aacZ_TEXT_Print(G348_pl_Bitmap_LogicalScreenBase, C160_BYTE_WIDTH_SCREEN, L0813_i_X, L0814_i_Y, C13_COLOR_LIGHTEST_GRAY, C12_COLOR_DARKEST_GRAY, G052_ac_Graphic562_RenameChampionInputCharacterString);
                                        F078_xzzz_MOUSE_ShowPointer();
                                        L0812_pc_RenamedChampionString[A0808_ui_CharacterIndex++] = L0810_i_Character;
                                        L0812_pc_RenamedChampionString[A0808_ui_CharacterIndex] = '\0';
                                        L0813_i_X += 6;
                                        if ((L0809_i_RenamedChampionString == C1_RENAME_CHAMPION_NAME) && (A0808_ui_CharacterIndex == 7)) {
                                                goto T281_033_ProceedToTitle;
                                        }
                                }
                        }
                } else {
                        if (L0810_i_Character == '\r') { /* Carriage return */
                                if ((L0809_i_RenamedChampionString == C1_RENAME_CHAMPION_NAME) && (A0808_ui_CharacterIndex > 0)) {
                                        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                                        F040_aacZ_TEXT_Print(G348_pl_Bitmap_LogicalScreenBase, C160_BYTE_WIDTH_SCREEN, L0813_i_X, L0814_i_Y, C13_COLOR_LIGHTEST_GRAY, C12_COLOR_DARKEST_GRAY, G051_ac_Graphic562_UnderscoreCharacterString);
                                        F078_xzzz_MOUSE_ShowPointer();
                                        T281_033_ProceedToTitle:
                                        L0809_i_RenamedChampionString = C2_RENAME_CHAMPION_TITLE;
                                        L0812_pc_RenamedChampionString = P597_ps_Champion->Title;
                                        L0813_i_X = 105;
                                        L0814_i_Y = 109;
                                        A0808_ui_CharacterIndex = 0;
                                }
                        } else {
                                if (L0810_i_Character == '\b') { /* Backspace */
                                        if ((L0809_i_RenamedChampionString == C1_RENAME_CHAMPION_NAME) && (A0808_ui_CharacterIndex == 0)) {
                                                continue;
                                        }
                                        if (!L0811_B_ChampionTitleIsFull) {
                                                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                                                F040_aacZ_TEXT_Print(G348_pl_Bitmap_LogicalScreenBase, C160_BYTE_WIDTH_SCREEN, L0813_i_X, L0814_i_Y, C13_COLOR_LIGHTEST_GRAY, C12_COLOR_DARKEST_GRAY, G051_ac_Graphic562_UnderscoreCharacterString);
                                                F078_xzzz_MOUSE_ShowPointer();
                                        }
                                        if (A0808_ui_CharacterIndex == 0) {
                                                L0812_pc_RenamedChampionString = P597_ps_Champion->Name;
                                                A0808_ui_CharacterIndex = strlen(L0812_pc_RenamedChampionString) - 1;
                                                L0809_i_RenamedChampionString = C1_RENAME_CHAMPION_NAME;
                                                L0813_i_X = 177 + (A0808_ui_CharacterIndex * 6);
                                                L0814_i_Y = 91;
                                        } else {
                                                A0808_ui_CharacterIndex--;
                                                L0813_i_X -= 6;
                                        }
                                        L0812_pc_RenamedChampionString[A0808_ui_CharacterIndex] = '\0';
                                }
                        }
                }
        } while ();
}

VOID F282_xzzz_CHAMPION_ProcessCommands160To162_ClickInResurrectReincarnatePanel(P598_i_Command)
int P598_i_Command;
{
        register unsigned int L0822_ui_ChampionIndex;
        register unsigned int L0823_ui_Multiple;
#define A0823_ui_SlotIndex      L0823_ui_Multiple
#define A0823_ui_StatisticIndex L0823_ui_Multiple
#define A0823_ui_Counter        L0823_ui_Multiple
#define A0823_ui_ChampionColor  L0823_ui_Multiple
        register int L0824_i_Multiple;
#define A0824_i_OneEighthOfCurrentStatistic L0824_i_Multiple
#define A0824_i_StatisticIndex              L0824_i_Multiple
        register THING L0825_T_Thing;
        register CHAMPION* L0826_ps_Champion;
        register SENSOR* L0827_ps_Sensor;
        int L0828_i_MapX;
        int L0829_i_MapY;
        BOX_WORD L0830_s_Box;


        L0826_ps_Champion = &G407_s_Party.Champions[L0822_ui_ChampionIndex = G305_ui_PartyChampionCount - 1];
        if (P598_i_Command == C162_COMMAND_CLICK_IN_PANEL_CANCEL) {
                F355_hzzz_INVENTORY_Toggle_COPYPROTECTIONE(C04_CHAMPION_CLOSE_INVENTORY);
                G299_ui_CandidateChampionOrdinal = M00_INDEX_TO_ORDINAL(CM1_CHAMPION_NONE);
                if (G305_ui_PartyChampionCount == 1) {
                        F368_fzzz_COMMAND_SetLeader(CM1_CHAMPION_NONE);
                }
                G305_ui_PartyChampionCount--;
                L0830_s_Box.Y1 = 0;
                L0830_s_Box.Y2 = 28;
                L0830_s_Box.X2 = (L0830_s_Box.X1 = L0822_ui_ChampionIndex * C69_CHAMPION_STATUS_BOX_SPACING) + 66;
                G578_B_UseByteBoxCoordinates = FALSE;
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &L0830_s_Box, C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
                F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G054_ai_Graphic562_Box_ChampionIcons[M26_CHAMPION_ICON_INDEX(L0826_ps_Champion->Cell, G308_i_PartyDirection) << 2], C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
                F457_AA08_START_DrawEnabledMenus_COPYPROTECTIONF();
                F078_xzzz_MOUSE_ShowPointer();
        } else {
                G299_ui_CandidateChampionOrdinal = M00_INDEX_TO_ORDINAL(CM1_CHAMPION_NONE);
                L0828_i_MapX = G306_i_PartyMapX;
                L0829_i_MapY = G307_i_PartyMapY;
                L0828_i_MapX += G233_ai_Graphic559_DirectionToStepEastCount[G308_i_PartyDirection], L0829_i_MapY += G234_ai_Graphic559_DirectionToStepNorthCount[G308_i_PartyDirection];
                for(A0823_ui_SlotIndex = C00_SLOT_READY_HAND; A0823_ui_SlotIndex < C30_SLOT_CHEST_1; A0823_ui_SlotIndex++) {
                        if ((L0825_T_Thing = L0826_ps_Champion->Slots[A0823_ui_SlotIndex]) != C0xFFFF_THING_NONE) {
                                F164_dzzz_DUNGEON_UnlinkThingFromList(L0825_T_Thing, 0, L0828_i_MapX, L0829_i_MapY);
                        }
                }
                L0825_T_Thing = F161_szzz_DUNGEON_GetSquareFirstThing(L0828_i_MapX, L0829_i_MapY);
                do {
                        if (M12_TYPE(L0825_T_Thing) == C03_THING_TYPE_SENSOR) {
                                L0827_ps_Sensor = (SENSOR*)F156_afzz_DUNGEON_GetThingData(L0825_T_Thing);
                                M44_SET_TYPE_DISABLED(L0827_ps_Sensor);
                                break;
                        }
                        L0825_T_Thing = F159_rzzz_DUNGEON_GetNextThing(L0825_T_Thing);
                } while ();
                if (P598_i_Command == C161_COMMAND_CLICK_IN_PANEL_REINCARNATE) {
                        F281_xxxx_CHAMPION_Rename(L0826_ps_Champion);
                        F008_aA19_MAIN_ClearBytes(L0826_ps_Champion->Skills, sizeof(L0826_ps_Champion->Skills));
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_24_IMPROVEMENT New reincarnation rules: Health, Mana and Stamina values are halved. The current and maximum values of each statistic except Luck are decreased by 1/8th of their value without going below their minimum value */
                        for(A0823_ui_StatisticIndex = C1_STATISTIC_STRENGTH; A0823_ui_StatisticIndex <= C6_STATISTIC_ANTIFIRE; A0823_ui_StatisticIndex++) { /* This loop does not affect Luck. When the loop starts, the minimum value of each statistic C1_STATISTIC_STRENGTH to C6_STATISTIC_ANTIFIRE is 30 (as set by F280_agzz_CHAMPION_AddCandidateChampionToParty). Current and maximum values are equal to the value from the champion definition */
                                A0824_i_OneEighthOfCurrentStatistic = L0826_ps_Champion->Statistics[A0823_ui_StatisticIndex][C1_CURRENT] >> 3;
                                L0826_ps_Champion->Statistics[A0823_ui_StatisticIndex][C1_CURRENT] = L0826_ps_Champion->Statistics[A0823_ui_StatisticIndex][C0_MAXIMUM] = F025_aatz_MAIN_GetMaximumValue(L0826_ps_Champion->Statistics[A0823_ui_StatisticIndex][C2_MINIMUM], L0826_ps_Champion->Statistics[A0823_ui_StatisticIndex][C1_CURRENT] - A0824_i_OneEighthOfCurrentStatistic);
                        }
                        L0826_ps_Champion->CurrentHealth >>= 1;
                        L0826_ps_Champion->MaximumHealth >>= 1;
                        L0826_ps_Champion->CurrentStamina >>= 1;
                        L0826_ps_Champion->MaximumStamina >>= 1;
                        L0826_ps_Champion->CurrentMana >>= 1;
                        L0826_ps_Champion->MaximumMana >>= 1;
#endif
                        for(A0823_ui_Counter = 0; A0823_ui_Counter < 12; A0823_ui_Counter++) {
                                A0824_i_StatisticIndex = M02_RANDOM(7);
                                L0826_ps_Champion->Statistics[A0824_i_StatisticIndex][C1_CURRENT]++;
                                L0826_ps_Champion->Statistics[A0824_i_StatisticIndex][C0_MAXIMUM]++;
                        }
                }
                if (G305_ui_PartyChampionCount == 1) {
                        G362_l_LastPartyMovementTime = G313_ul_GameTime;
                        F368_fzzz_COMMAND_SetLeader(C00_CHAMPION_FIRST);
                        F394_ozzz_MENUS_SetMagicCasterAndDrawSpellArea(C00_CHAMPION_FIRST);
                } else {
                        F393_lzzz_MENUS_DrawSpellAreaControls(G514_i_MagicCasterChampionIndex);
                }
                F051_AA19_TEXT_MESSAGEAREA_PrintLineFeed();
                F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(A0823_ui_ChampionColor = G046_auc_Graphic562_ChampionColor[L0822_ui_ChampionIndex], L0826_ps_Champion->Name);
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(A0823_ui_ChampionColor, (P598_i_Command == C160_COMMAND_CLICK_IN_PANEL_RESURRECT) ? " RESURRECTED." : " REINCARNATED.");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(A0823_ui_ChampionColor, (P598_i_Command == C160_COMMAND_CLICK_IN_PANEL_RESURRECT) ? " ZUM LEBEN ERWECKT." : " REINKARNIERT.");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(A0823_ui_ChampionColor, (P598_i_Command == C160_COMMAND_CLICK_IN_PANEL_RESURRECT) ? " RESSUSCITE." : " REINCARNE.");
#endif
                F355_hzzz_INVENTORY_Toggle_COPYPROTECTIONE(C04_CHAMPION_CLOSE_INVENTORY);
                F457_AA08_START_DrawEnabledMenus_COPYPROTECTIONF();
                F067_aaat_MOUSE_SetPointerToNormal((G411_i_LeaderIndex == CM1_CHAMPION_NONE) ? C0_POINTER_ARROW : C1_POINTER_HAND);
        }
}

VOID F283_azzz_CHAMPION_ViAltarRebirth(P599_i_ChampionIndex)
int P599_i_ChampionIndex;
{
        register unsigned int L0831_ui_Multiple;
#define A0831_ui_Cell          L0831_ui_Multiple
#define A0831_ui_MaximumHealth L0831_ui_Multiple
        register CHAMPION* L0832_ps_Champion;


        L0832_ps_Champion = &G407_s_Party.Champions[P599_i_ChampionIndex];
        if (F285_szzz_CHAMPION_GetIndexInCell(L0832_ps_Champion->Cell) != CM1_CHAMPION_NONE) {
                for(A0831_ui_Cell = C00_CELL_NORTHWEST; F285_szzz_CHAMPION_GetIndexInCell(A0831_ui_Cell) != CM1_CHAMPION_NONE; A0831_ui_Cell++);
                L0832_ps_Champion->Cell = A0831_ui_Cell;
        }
        A0831_ui_MaximumHealth = L0832_ps_Champion->MaximumHealth;
        L0832_ps_Champion->CurrentHealth = (L0832_ps_Champion->MaximumHealth = F025_aatz_MAIN_GetMaximumValue(25, A0831_ui_MaximumHealth - (A0831_ui_MaximumHealth >> 6) - 1)) >> 1;
        F393_lzzz_MENUS_DrawSpellAreaControls(G514_i_MagicCasterChampionIndex);
        L0832_ps_Champion->Direction = G308_i_PartyDirection;
        M08_SET(L0832_ps_Champion->Attributes, MASK0x8000_ACTION_HAND | MASK0x1000_STATUS_BOX | MASK0x0400_ICON);
        F292_arzz_CHAMPION_DrawState(P599_i_ChampionIndex);
}

#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_16_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
VOID F284_czzz_CHAMPION_SetPartyDirection(P600_i_Direction)
register int P600_i_Direction;
{
        register int L0833_i_ChampionIndex;
        register int L0834_i_Delta;
        register CHAMPION* L0835_ps_Champion;


        if (P600_i_Direction == G308_i_PartyDirection) {
                return;
        }
        if ((L0834_i_Delta = P600_i_Direction - G308_i_PartyDirection) < 0) {
                L0834_i_Delta += 4;
        }
        L0835_ps_Champion = G407_s_Party.Champions;
        for(L0833_i_ChampionIndex = C00_CHAMPION_FIRST; L0833_i_ChampionIndex < G305_ui_PartyChampionCount; L0833_i_ChampionIndex++) {
                L0835_ps_Champion->Cell = M21_NORMALIZE(L0835_ps_Champion->Cell + L0834_i_Delta);
                L0835_ps_Champion->Direction = M21_NORMALIZE(L0835_ps_Champion->Direction + L0834_i_Delta);
                L0835_ps_Champion++;
        }
        G308_i_PartyDirection = P600_i_Direction;
        F296_aizz_CHAMPION_DrawChangedObjectIcons();
}
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_16_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
VOID F284_czzz_CHAMPION_SetPartyDirection(P600_i_Direction)
int P600_i_Direction;
{
        asm {
                        move.w  P600_i_Direction(A6),D3
                        move.w  G308_i_PartyDirection(A4),D2
                        move.w  D3,G308_i_PartyDirection(A4)
                        sub.w   D2,D3
                        beq.s   T284_005_Return
                        addq.w  #4,D3
                        lea     G407_s_Party.Champions(A4),A0
                        move.w  G305_ui_PartyChampionCount(A4),D0
                T284_001_Loop:
                        add.b   D3,0x001D(A0)                           /* Champion Cell */
                        andi.b  #0x03,0x001D(A0)                        /* Champion Cell */
                        add.b   D3,0x001C(A0)                           /* Champion Direction */
                        andi.b  #0x03,0x001C(A0)                        /* Champion Direction */
                        lea     800(A0),A0                              /* Proceed to next champion in party */
                        subq.w  #1,D0
                        bgt.s   T284_001_Loop
        }
        F296_aizz_CHAMPION_DrawChangedObjectIcons();
        T284_005_Return: ;
}
#endif

int F285_szzz_CHAMPION_GetIndexInCell(P601_ui_Cell)
register unsigned int P601_ui_Cell;
{
        register int L0836_i_ChampionIndex;
        register CHAMPION* L0837_ps_Champion;


        for(L0836_i_ChampionIndex = C00_CHAMPION_FIRST, L0837_ps_Champion = G407_s_Party.Champions; L0836_i_ChampionIndex < G305_ui_PartyChampionCount; L0836_i_ChampionIndex++, L0837_ps_Champion++) {
                if ((L0837_ps_Champion->Cell == P601_ui_Cell) && L0837_ps_Champion->CurrentHealth) {
                        return L0836_i_ChampionIndex;
                }
        }
        return CM1_CHAMPION_NONE;
}

int F286_hzzz_CHAMPION_GetTargetChampionIndex(P602_i_MapX, P603_i_MapY, P604_ui_Cell)
int P602_i_MapX;
int P603_i_MapY;
unsigned int P604_ui_Cell;
{
        register unsigned int L0838_ui_Counter;
        register int L0839_i_ChampionIndex;
        unsigned char L0840_auc_OrderedCellsToAttack[4];


        if (G305_ui_PartyChampionCount && (M38_DISTANCE(P602_i_MapX, P603_i_MapY, G306_i_PartyMapX, G307_i_PartyMapY) <= 1)) {
                F229_hzzz_GROUP_SetOrderedCellsToAttack(L0840_auc_OrderedCellsToAttack, G306_i_PartyMapX, G307_i_PartyMapY, P602_i_MapX, P603_i_MapY, P604_ui_Cell);
                for(L0838_ui_Counter = 0; L0838_ui_Counter < 4; L0838_ui_Counter++) {
                        if ((L0839_i_ChampionIndex = F285_szzz_CHAMPION_GetIndexInCell(L0840_auc_OrderedCellsToAttack[L0838_ui_Counter])) >= 0) {
                                return L0839_i_ChampionIndex;
                        }
                }
        }
        return CM1_CHAMPION_NONE;
}

VOID F287_xxxx_CHAMPION_DrawBarGraphs(P605_i_ChampionIndex)
int P605_i_ChampionIndex;
{
        register int L0841_i_ColorBits3And2;
        register int L0842_i_Multiple;
#define A0842_i_BarGraphIndex  L0842_i_Multiple
#define A0842_i_ColorBits1And0 L0842_i_Multiple
        register long L0843_l_Multiple;
#define A0843_l_BarGraphHeight        L0843_l_Multiple
#define A0843_l_BarGraphMaskInverted2 L0843_l_Multiple
        register int L0844_i_BarGraphMaskInverted1;
        register CHAMPION* L0845_ps_Multiple;
#define A0845_ps_Champion       L0845_ps_Multiple
#define A0845_pi_BarGraphHeight L0845_ps_Multiple
        register char* L0846_pc_VideoAddress;
        int L0847_ai_BarGraphHeights[3];
        int L0848_i_LastBarGraph;


        A0845_ps_Champion = &G407_s_Party.Champions[P605_i_ChampionIndex];
        A0842_i_BarGraphIndex = 0;
        if (A0845_ps_Champion->CurrentHealth > 0) {
                A0843_l_BarGraphHeight = (((long)A0845_ps_Champion->CurrentHealth << 10) * 25) / A0845_ps_Champion->MaximumHealth;
                if (A0843_l_BarGraphHeight & 0x000003FF) {
                        L0847_ai_BarGraphHeights[A0842_i_BarGraphIndex++] = (A0843_l_BarGraphHeight >> 10) + 1;
                } else {
                        L0847_ai_BarGraphHeights[A0842_i_BarGraphIndex++] = (A0843_l_BarGraphHeight >> 10);
                }
        } else {
                L0847_ai_BarGraphHeights[A0842_i_BarGraphIndex++] = 0;
        }
        if (A0845_ps_Champion->CurrentStamina > 0) {
                A0843_l_BarGraphHeight = (((long)A0845_ps_Champion->CurrentStamina << 10) * 25) / A0845_ps_Champion->MaximumStamina;
                if (A0843_l_BarGraphHeight & 0x000003FF) {
                        L0847_ai_BarGraphHeights[A0842_i_BarGraphIndex++] = (A0843_l_BarGraphHeight >> 10) + 1;
                } else {
                        L0847_ai_BarGraphHeights[A0842_i_BarGraphIndex++] = (A0843_l_BarGraphHeight >> 10);
                }
        } else {
                L0847_ai_BarGraphHeights[A0842_i_BarGraphIndex++] = 0;
        }
        if (A0845_ps_Champion->CurrentMana > 0) {
                if (A0845_ps_Champion->CurrentMana > A0845_ps_Champion->MaximumMana) {
                        L0847_ai_BarGraphHeights[A0842_i_BarGraphIndex] = 25;
                } else {
                        A0843_l_BarGraphHeight = (((long)A0845_ps_Champion->CurrentMana << 10) * 25) / A0845_ps_Champion->MaximumMana;
                        if (A0843_l_BarGraphHeight & 0x000003FF) {
                                L0847_ai_BarGraphHeights[A0842_i_BarGraphIndex] = (A0843_l_BarGraphHeight >> 10) + 1;
                        } else {
                                L0847_ai_BarGraphHeights[A0842_i_BarGraphIndex] = (A0843_l_BarGraphHeight >> 10);
                        }
                }
        } else {
                L0847_ai_BarGraphHeights[A0842_i_BarGraphIndex] = 0;
        }
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        asm {
                        movea.l G348_pl_Bitmap_LogicalScreenBase(A4),A0
                        lea     320(A0),A0                                              /* Address of the first pixel on the third line on screen (320 bytes = 640 pixels = 2 lines). Bar graphs are never drawn above this line */
                        move.w  P605_i_ChampionIndex(A6),D1
                        ext.l   D1
                        cmp.w   #3,D1
                        bcs.s   T287_014                                                /* If the specified champion index is 0, 1 or 2 */
                        move.l  #0x80000000,A0842_i_ColorBits1And0
                        move.l  A0842_i_ColorBits1And0,L0841_i_ColorBits3And2
                        addq.l  #1,L0841_i_ColorBits3And2
                        bra.s   T287_017                                                /* Champion #3, Color #14: L0841_i_ColorBits3And2 = 0x80000001 A0842_i_ColorBits1And0 = 0x80000000 */
                T287_014:                                                                                          
                        cmp.w   #2,D1                                                                              
                        bcs.s   T287_015                                                /* If the specified champion index is 0 or 1 */
                        moveq   #0,A0842_i_ColorBits1And0                                                                
                        move.l  #0x80000000,L0841_i_ColorBits3And2                                                       
                        bra.s   T287_017                                                /* Champion #2, Color #08: L0841_i_ColorBits3And2 = 0x80000000 A0842_i_ColorBits1And0 = 0x00000000 */
                T287_015:                                                                                          
                        cmp.w   #1,D1                                                                              
                        bcs.s   T287_016                                                /* If the specified champion index is 0 */
                        move.l  #0x80000001,A0842_i_ColorBits1And0                                                       
                        move.l  A0842_i_ColorBits1And0,L0841_i_ColorBits3And2                                                  
                        subq.l  #1,L0841_i_ColorBits3And2                                                                
                        bra.s   T287_017                                                /* Champion #1, Color #11: L0841_i_ColorBits3And2 = 0x80000000 A0842_i_ColorBits1And0 = 0x80000001 */
                T287_016:                                                                                          
                        move.l  #0x80000001,A0842_i_ColorBits1And0                                                       
                        moveq   #1,L0841_i_ColorBits3And2                               /* Champion #0, Color #07: L0841_i_ColorBits3And2 = 0x00000001 A0842_i_ColorBits1And0 = 0x80000001 */
                T287_017:
                        add.w   D1,D1
                        move.w  D1,D2
                        add.w   D1,D1
                        add.w   D2,D1
                        move.w  D1,L0848_i_LastBarGraph(A6)                             /* 6 * Champion index */
                        addq.w  #4,L0848_i_LastBarGraph(A6)
                        lea     L0847_ai_BarGraphHeights(A6),A0845_pi_BarGraphHeight
                T287_018_Loop:
                        movea.l A0,L0846_pc_VideoAddress
                        lea     G056_aaui_Graphic562_BarGraphByteOffsets(A4),A1
                        adda.w  0(A1,D1.w),L0846_pc_VideoAddress
                        lsl.w   #1,D1
                        lea     G055_aaaui_Graphic562_BarGraphMasks(A4),A1
/* G055_aaaui_Graphic562_BarGraphMasks contains the following 16 bits masks: 3 pairs of masks (for each bar graph) for each champion:
0000000000000011  1100000000000000        0000011110000000  0000000000000000        0000000000001111  0000000000000000
0001111000000000  0000000000000000        0000000000111100  0000000000000000        0111100000000000  0000000000000000
0000000011110000  0000000000000000        0000000000000001  1110000000000000        0000001111000000  0000000000000000
0000000000000111  1000000000000000        0000111100000000  0000000000000000        0000000000011110  0000000000000000 */
                        move.w  0(A1,D1.w),D2
                        move.w  2(A1,D1.w),D3
                        move.w  D2,L0844_i_BarGraphMaskInverted1
                        not.w   L0844_i_BarGraphMaskInverted1
                        move.w  D3,A0843_l_BarGraphMaskInverted2
                        not.w   D5
                        lsr.w   #1,D1
                        move.w  (A0845_pi_BarGraphHeight)+,D0                           /* Height of bar graph to draw */
                        jsr     S287_xxxx_CHAMPION_DrawChampionBarGraphs_Subroutine(PC)
                        cmp.w   L0848_i_LastBarGraph(A6),D1
                        beq     T287_030                                                /* Branch if there are no more bar graphs to draw */
                        addq.w  #2,D1                                                   /* Proceed to next bar graph */
                        bra.s   T287_018_Loop
                S287_xxxx_CHAMPION_DrawChampionBarGraphs_Subroutine:
                        move.w  D1,-(A7)
                        move.w  #24,D1                                                  /* Index of bar graph line to draw */
                T287_020_Loop:
                        cmp.w   D1,D0
                        bhi.s   T287_021                                                /* If height of bar graph to draw > line being drawn (if a bar graph line should be drawn) */
                        and.w   L0844_i_BarGraphMaskInverted1,(L0846_pc_VideoAddress)   /* Clear bit 0 of each pixel. Set bits for color #12 */
                        and.w   A0843_l_BarGraphMaskInverted2,8(L0846_pc_VideoAddress)  /* Clear bit 0 of each pixel */
                        and.w   L0844_i_BarGraphMaskInverted1,2(L0846_pc_VideoAddress)  /* Clear bit 1 of each pixel */
                        and.w   A0843_l_BarGraphMaskInverted2,10(L0846_pc_VideoAddress) /* Clear bit 1 of each pixel */
                        or.w    D2,4(L0846_pc_VideoAddress)                             /* Set bit 2 of each pixel */
                        or.w    D3,12(L0846_pc_VideoAddress)                            /* Set bit 2 of each pixel */
                        or.w    D2,6(L0846_pc_VideoAddress)                             /* Set bit 3 of each pixel */
                        or.w    D3,14(L0846_pc_VideoAddress)                            /* Set bit 3 of each pixel */
                        bra.s   T287_029
                T287_021:
                        tst.w   A0842_i_ColorBits1And0                                  /* Test bit 0 (Color bit 0) */
                        beq.s   T287_022
                        or.w    D2,(L0846_pc_VideoAddress)                              /* Set bit 0 of each pixel */
                        or.w    D3,8(L0846_pc_VideoAddress)                             /* Set bit 0 of each pixel */
                        bra.s   T287_023
                T287_022:
                        and.w   L0844_i_BarGraphMaskInverted1,(L0846_pc_VideoAddress)   /* Clear bit 0 of each pixel */
                        and.w   A0843_l_BarGraphMaskInverted2,8(L0846_pc_VideoAddress)  /* Clear bit 0 of each pixel */
                T287_023:
                        tst.l   A0842_i_ColorBits1And0                                  /* Test bit 15 (Color bit 1) */
                        bge.s   T287_024
                        or.w    D2,2(L0846_pc_VideoAddress)                             /* Set bit 1 of each pixel */
                        or.w    D3,10(L0846_pc_VideoAddress)                            /* Set bit 1 of each pixel */
                        bra.s   T287_025
                T287_024:
                        and.w   L0844_i_BarGraphMaskInverted1,2(L0846_pc_VideoAddress)  /* Clear bit 1 of each pixel */
                        and.w   A0843_l_BarGraphMaskInverted2,10(L0846_pc_VideoAddress) /* Clear bit 1 of each pixel */
                T287_025:
                        tst.w   L0841_i_ColorBits3And2                                  /* Test bit 0 (Color bit 2) */
                        beq.s   T287_026
                        or.w    D2,4(L0846_pc_VideoAddress)                             /* Set bit 2 of each pixel */
                        or.w    D3,12(L0846_pc_VideoAddress)                            /* Set bit 2 of each pixel */
                        bra.s   T287_027
                T287_026:
                        and.w   L0844_i_BarGraphMaskInverted1,4(L0846_pc_VideoAddress)  /* Clear bit 2 of each pixel */
                        and.w   A0843_l_BarGraphMaskInverted2,12(L0846_pc_VideoAddress) /* Clear bit 2 of each pixel */
                T287_027:
                        tst.l   L0841_i_ColorBits3And2                                  /* Test bit 15 (Color bit 3) */
                        bge.s   T287_028
                        or.w    D2,6(L0846_pc_VideoAddress)                             /* Set bit 3 of each pixel */
                        or.w    D3,14(L0846_pc_VideoAddress)                            /* Set bit 3 of each pixel */
                        bra.s   T287_029
                T287_028:
                        and.w   L0844_i_BarGraphMaskInverted1,6(L0846_pc_VideoAddress)  /* Clear bit 3 of each pixel */
                        and.w   A0843_l_BarGraphMaskInverted2,14(L0846_pc_VideoAddress) /* Clear bit 3 of each pixel */
                T287_029:
                        lea     160(L0846_pc_VideoAddress),L0846_pc_VideoAddress        /* Proceed to next line ($00A0 = 160 bytes per line) */
                        dbf     D1,T287_020_Loop
                        move.w  (A7)+,D1
                        rts
                T287_030:
        }
        F078_xzzz_MOUSE_ShowPointer();
}

#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_16_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
char* F288_xxxx_CHAMPION_GetStringFromInteger(P606_ui_Integer, P607_B_Padding, P608_i_PaddingCharacterCount)
register unsigned int P606_ui_Integer;
register BOOLEAN P607_B_Padding;
int P608_i_PaddingCharacterCount;
{
        register int L0849_i_Digit;
        register char* L0850_pc_Character;
        static char G419_ac_IntegerToStringConversionBuffer[5];


        if (P607_B_Padding) {
                F009_aA49_MAIN_WriteSpacedBytes(G419_ac_IntegerToStringConversionBuffer, 4, ' ', sizeof(char));
        }
        L0850_pc_Character = &G419_ac_IntegerToStringConversionBuffer[4];
        *L0850_pc_Character = '\0';
        if (!P606_ui_Integer) {
                *(--L0850_pc_Character) = '0';
        } else {
                while (L0849_i_Digit = P606_ui_Integer) {
                        *(--L0850_pc_Character) = '0' + L0849_i_Digit - ((P606_ui_Integer /= 10) * 10);
                }
        }
        if (P607_B_Padding) {
                return &G419_ac_IntegerToStringConversionBuffer[4 - P608_i_PaddingCharacterCount];
        }
        return L0850_pc_Character;
}
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_16_OPTIMIZATION Source code converted from C language to assembly language for better performance and smaller machine code size */
char* F288_xxxx_CHAMPION_GetStringFromInteger(P606_ui_Integer, P607_B_Padding, P608_i_PaddingCharacterCount)
unsigned int P606_ui_Integer;
BOOLEAN P607_B_Padding;
int P608_i_PaddingCharacterCount;
{
        static char G419_ac_IntegerToStringConversionBuffer[5];


        asm {
                        moveq   #4,D0
                        sub.w   P608_i_PaddingCharacterCount(A6),D0
                        lea     G419_ac_IntegerToStringConversionBuffer(A4),A1
                        add.l   A1,D0
                        move.l  #'    ',(A1)+                                   /* Write 4 'space' characters */
                        clr.b   (A1)                                            /* Write a 00h byte to mark the end of the string */
                        moveq   #0,D1
                        move.w  P606_ui_Integer(A6),D1
                T288_003_Loop:
                        divu    #10,D1
                        swap    D1                                              /* This places the remainder of the division (0..9) in the least significant word of D1 */
                        add.b   #'0',D1                                         /* This converts a number (0..9) to the corresponding ASCII character */
                        move.b  D1,-(A1)                                        /* Replace the last character in the string by the digit, and decrement A1 */
                        clr.w   D1                                              /* Clear the division remainder */
                        swap    D1                                              /* This places the last quotient of the division in the least significant word of D1 */
                        bne.s   T288_003_Loop                                   /* If there is still a non zero quotient to process */
                        tst.w   P607_B_Padding(A6)
                        bne.s   T288_007_Return                                 /* If padding (leading spaces) should be present in returned string */
                        move.l  A1,D0
                T288_007_Return:
        }
}
#endif

VOID F289_xxxx_CHAMPION_DrawHealthOrStaminaOrManaValue(P609_i_Y, P610_i_CurrentValue, P611_i_MaximumValue)
int P609_i_Y;
int P610_i_CurrentValue;
int P611_i_MaximumValue;
{
        F052_aaoz_TEXT_PrintToViewport(55, P609_i_Y, C13_COLOR_LIGHTEST_GRAY, F288_xxxx_CHAMPION_GetStringFromInteger(P610_i_CurrentValue, TRUE, 3));
        F052_aaoz_TEXT_PrintToViewport(73, P609_i_Y, C13_COLOR_LIGHTEST_GRAY, "/");
        F052_aaoz_TEXT_PrintToViewport(79, P609_i_Y, C13_COLOR_LIGHTEST_GRAY, F288_xxxx_CHAMPION_GetStringFromInteger(P611_i_MaximumValue, TRUE, 3));
}

VOID F290_xxxx_CHAMPION_DrawHealthStaminaManaValues(P612_ps_Champion)
register CHAMPION* P612_ps_Champion;
{
        F289_xxxx_CHAMPION_DrawHealthOrStaminaOrManaValue(116, P612_ps_Champion->CurrentHealth, P612_ps_Champion->MaximumHealth);
        F289_xxxx_CHAMPION_DrawHealthOrStaminaOrManaValue(124, P612_ps_Champion->CurrentStamina / 10, P612_ps_Champion->MaximumStamina / 10);
        F289_xxxx_CHAMPION_DrawHealthOrStaminaOrManaValue(132, P612_ps_Champion->CurrentMana, P612_ps_Champion->MaximumMana);
}

VOID F291_xxxx_CHAMPION_DrawSlot(P613_i_ChampionIndex, P614_ui_SlotIndex)
int P613_i_ChampionIndex;
register unsigned int P614_ui_SlotIndex;
{
        register THING L0851_T_Thing;
        register BOOLEAN L0852_B_IsInventoryChampion;
        register int L0853_i_IconIndex;
        register CHAMPION* L0854_ps_Champion;
        register SLOT_BOX* L0855_ps_SlotBox;
        int L0856_i_SlotBoxIndex;
        char L0857_ac_Unreferenced[8]; /* BUG0_00 Useless code */
        BOX_WORD L0858_s_Box;
        int L0859_i_NativeBitmapIndex;
        unsigned char* L0860_puc_Bitmap;
        int L0861_i_DestinationByteWidth;


        L0859_i_NativeBitmapIndex = -1;
        L0854_ps_Champion = &G407_s_Party.Champions[P613_i_ChampionIndex];
        L0852_B_IsInventoryChampion = (G423_i_InventoryChampionOrdinal == M00_INDEX_TO_ORDINAL(P613_i_ChampionIndex));
        if (!L0852_B_IsInventoryChampion) { /* If drawing a slot for a champion other than the champion whose inventory is open */
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_08_FIX */
                if ((P614_ui_SlotIndex > C01_SLOT_ACTION_HAND) || G299_ui_CandidateChampionOrdinal) {
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_08_FIX In F280_agzz_CHAMPION_AddCandidateChampionToParty the value of G299_ui_CandidateChampionOrdinal is set before F388_rzzz_MENUS_ClearActingChampion is called, which calls F292_arzz_CHAMPION_DrawState which in turn calls this function to draw the action hand slot. Without this updated condition the slot would not be drawn */
                if ((P614_ui_SlotIndex > C01_SLOT_ACTION_HAND) || (G299_ui_CandidateChampionOrdinal == M00_INDEX_TO_ORDINAL(P613_i_ChampionIndex))) {
#endif
                        return;
                }
                L0856_i_SlotBoxIndex = (P613_i_ChampionIndex << 1) + P614_ui_SlotIndex;
        } else {
                L0856_i_SlotBoxIndex = C08_SLOT_BOX_INVENTORY_FIRST_SLOT + P614_ui_SlotIndex;
        }
        if (P614_ui_SlotIndex >= C30_SLOT_CHEST_1) {
                L0851_T_Thing = G425_aT_ChestSlots[P614_ui_SlotIndex - C30_SLOT_CHEST_1];
        } else {
                L0851_T_Thing = L0854_ps_Champion->Slots[P614_ui_SlotIndex];
        }
        L0855_ps_SlotBox = &G030_as_Graphic562_SlotBoxes[L0856_i_SlotBoxIndex];
        L0858_s_Box.X2 = (L0858_s_Box.X1 = L0855_ps_SlotBox->X - 1) + 17;
        L0858_s_Box.Y2 = (L0858_s_Box.Y1 = L0855_ps_SlotBox->Y - 1) + 17;
        if (L0852_B_IsInventoryChampion) {
                L0860_puc_Bitmap = G296_puc_Bitmap_Viewport;
                L0861_i_DestinationByteWidth = C112_BYTE_WIDTH_VIEWPORT;
        } else {
                L0860_puc_Bitmap = (unsigned char*)G348_pl_Bitmap_LogicalScreenBase;
                L0861_i_DestinationByteWidth = C160_BYTE_WIDTH_SCREEN;
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        }
        if (L0851_T_Thing == C0xFFFF_THING_NONE) {
                if (P614_ui_SlotIndex <= C05_SLOT_FEET) {
                        L0853_i_IconIndex = C212_ICON_READY_HAND + (P614_ui_SlotIndex << 1);
                        if (M07_GET(L0854_ps_Champion->Wounds, 1 << P614_ui_SlotIndex)) {
                                L0853_i_IconIndex++;
                                L0859_i_NativeBitmapIndex = C034_GRAPHIC_SLOT_BOX_WOUNDED;
                        } else {
                                L0859_i_NativeBitmapIndex = C033_GRAPHIC_SLOT_BOX_NORMAL;
                        }
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_09_OPTIMIZATION */
                        if ((P614_ui_SlotIndex == C01_SLOT_ACTION_HAND) && (M00_INDEX_TO_ORDINAL(P613_i_ChampionIndex) == G506_i_ActingChampionOrdinal)) {
                                L0859_i_NativeBitmapIndex = C035_GRAPHIC_SLOT_BOX_ACTING_HAND;
                        }
#endif
                } else {
                        if ((P614_ui_SlotIndex >= C10_SLOT_NECK) && (P614_ui_SlotIndex <= C13_SLOT_BACKPACK_LINE1_1)) {
                                L0853_i_IconIndex = C208_ICON_NECK + (P614_ui_SlotIndex - C10_SLOT_NECK);
                        } else {
                                L0853_i_IconIndex = C204_ICON_EMPTY_BOX;
                        }
                }
        } else {
                L0853_i_IconIndex = F033_aaaz_OBJECT_GetIconIndex(L0851_T_Thing); /* BUG0_35 The closed chest icon is drawn when the chest is opened. If you open the inventory of a champion and place a chest in the action hand, the closed chest icon is drawn instead of the open chest icon. If you place a Chest in the action hand before opening the inventory (in the champion status box on top of the screen) then when you open the inventory the open chest icon is drawn correctly in the action hand (by F333_xxxx_INVENTORY_OpenAndDrawChest). Code is missing to change the icon when a chest is drawn in the action hand while in the inventory */
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_10_FIX Code added to change the icon of the Chest and Scroll when in the action hand and in the inventory. This fix causes BUG2_00 for scrolls */
                if (L0852_B_IsInventoryChampion && (P614_ui_SlotIndex == C01_SLOT_ACTION_HAND) && ((L0853_i_IconIndex == C144_ICON_CONTAINER_CHEST_CLOSED) || (L0853_i_IconIndex == C030_ICON_SCROLL_SCROLL_OPEN))) { /* BUG2_00 The closed scroll icon is drawn when the scroll is open. If you open the inventory of a champion and place a scroll in the action hand, the closed scroll icon is drawn instead of the open scroll icon. If you put another scroll in the action hand of another champion (in the status box on top of the screen) the icon is changed to the open scroll icon. If a champion in the party has a lit torch in hand then if you wait long enough without doing anything until the torch light decreases then the scroll icon changes automatically to the open scroll icon (caused by F338_atzz_INVENTORY_DecreaseTorchesLightPower_COPYPROTECTIONE which calls F296_aizz_CHAMPION_DrawChangedObjectIcons if the charge count of a torch has changed). The code added to fix BUG0_35 about chest icons also affects scrolls while it should not */
                        L0853_i_IconIndex++;
                }
#endif
                if (P614_ui_SlotIndex <= C05_SLOT_FEET) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_09_OPTIMIZATION */
                        if ((P614_ui_SlotIndex == C01_SLOT_ACTION_HAND) && (M00_INDEX_TO_ORDINAL(P613_i_ChampionIndex) == G506_i_ActingChampionOrdinal)) {
                                L0859_i_NativeBitmapIndex = C035_GRAPHIC_SLOT_BOX_ACTING_HAND;
                        } else {
#endif
                                if (M07_GET(L0854_ps_Champion->Wounds, 1 << P614_ui_SlotIndex)) {
                                        L0859_i_NativeBitmapIndex = C034_GRAPHIC_SLOT_BOX_WOUNDED;
                                } else {
                                        L0859_i_NativeBitmapIndex = C033_GRAPHIC_SLOT_BOX_NORMAL;
                                }
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_09_OPTIMIZATION */
                        }
#endif
                }
        }
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_09_OPTIMIZATION Code deduplication */
        if ((P614_ui_SlotIndex == C01_SLOT_ACTION_HAND) && (M00_INDEX_TO_ORDINAL(P613_i_ChampionIndex) == G506_i_ActingChampionOrdinal)) {
                L0859_i_NativeBitmapIndex = C035_GRAPHIC_SLOT_BOX_ACTING_HAND;
        }
#endif
        if (L0859_i_NativeBitmapIndex != -1) {
                G578_B_UseByteBoxCoordinates = FALSE, F132_xzzz_VIDEO_Blit(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(L0859_i_NativeBitmapIndex), L0860_puc_Bitmap, &L0858_s_Box, 0, 0, C016_BYTE_WIDTH, L0861_i_DestinationByteWidth, C12_COLOR_DARKEST_GRAY);
        }
        F038_AA07_OBJECT_DrawIconInSlotBox(L0856_i_SlotBoxIndex, L0853_i_IconIndex);
        if (!L0852_B_IsInventoryChampion) {
                F078_xzzz_MOUSE_ShowPointer();
        }
}

VOID F292_arzz_CHAMPION_DrawState(P615_ui_ChampionIndex)
register unsigned int P615_ui_ChampionIndex;
{
        register unsigned int L0862_ui_ChampionAttributes;
        register BOOLEAN L0863_B_IsInventoryChampion;
        register int L0864_i_Multiple;
#define A0864_i_BorderCount       L0864_i_Multiple
#define A0864_i_ColorIndex        L0864_i_Multiple
#define A0864_i_Load              L0864_i_Multiple
#define A0864_i_ChampionIconIndex L0864_i_Multiple
#define A0864_i_StatisticIndex    L0864_i_Multiple
#define A0864_i_SlotIndex         L0864_i_Multiple
        register CHAMPION* L0865_ps_Champion;
        register char* L0866_pc_ChampionName;
        char L0867_c_ChampionTitleFirstCharacter;
        int L0868_i_ChampionStatusBoxX;
        int L0869_i_ChampionTitleX;
        int L0870_i_Multiple;
#define A0870_i_NativeBitmapIndex L0870_i_Multiple
#define A0870_i_Color             L0870_i_Multiple
        BOX_WORD L0871_s_Box;
        int L0872_ai_NativeBitmapIndices[3];


        L0868_i_ChampionStatusBoxX = P615_ui_ChampionIndex * C69_CHAMPION_STATUS_BOX_SPACING;
        L0865_ps_Champion = &G407_s_Party.Champions[P615_ui_ChampionIndex];
        L0862_ui_ChampionAttributes = L0865_ps_Champion->Attributes;
        if (!M07_GET(L0862_ui_ChampionAttributes, MASK0x0080_NAME_TITLE | MASK0x0100_STATISTICS | MASK0x0200_LOAD | MASK0x0400_ICON | MASK0x0800_PANEL | MASK0x1000_STATUS_BOX | MASK0x2000_WOUNDS | MASK0x4000_VIEWPORT | MASK0x8000_ACTION_HAND)) {
                return;
        }
        L0863_B_IsInventoryChampion = (M00_INDEX_TO_ORDINAL(P615_ui_ChampionIndex) == G423_i_InventoryChampionOrdinal);
        G578_B_UseByteBoxCoordinates = FALSE;
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        if (M07_GET(L0862_ui_ChampionAttributes, MASK0x1000_STATUS_BOX)) {
                L0871_s_Box.Y1 = 0;
                L0871_s_Box.Y2 = 28;
                L0871_s_Box.X2 = (L0871_s_Box.X1 = L0868_i_ChampionStatusBoxX) + 66;
                if (L0865_ps_Champion->CurrentHealth) {
                        F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &L0871_s_Box, C12_COLOR_DARKEST_GRAY, C160_BYTE_WIDTH_SCREEN);
                        F008_aA19_MAIN_ClearBytes(L0872_ai_NativeBitmapIndices, sizeof(L0872_ai_NativeBitmapIndices));
                        A0864_i_BorderCount = 0;
                        if (G407_s_Party.FireShieldDefense > 0) {
                                L0872_ai_NativeBitmapIndices[A0864_i_BorderCount++] = C038_GRAPHIC_BORDER_PARTY_FIRESHIELD;
                        }
                        if (G407_s_Party.SpellShieldDefense > 0) {
                                L0872_ai_NativeBitmapIndices[A0864_i_BorderCount++] = C039_GRAPHIC_BORDER_PARTY_SPELLSHIELD;
                        }
                        if ((G407_s_Party.ShieldDefense > 0) || L0865_ps_Champion->ShieldDefense) {
                                L0872_ai_NativeBitmapIndices[A0864_i_BorderCount++] = C037_GRAPHIC_BORDER_PARTY_SHIELD;
                        }
                        while (A0864_i_BorderCount--) {
                                F021_a002_MAIN_BlitToScreen(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(L0872_ai_NativeBitmapIndices[A0864_i_BorderCount]), &L0871_s_Box, C040_BYTE_WIDTH, C10_COLOR_FLESH);
                        }
                        if (L0863_B_IsInventoryChampion) {
                                F354_szzz_INVENTORY_DrawStatusBoxPortrait(P615_ui_ChampionIndex);
                                M08_SET(L0862_ui_ChampionAttributes, MASK0x0100_STATISTICS);
                        } else {
                                M08_SET(L0862_ui_ChampionAttributes, MASK0x0080_NAME_TITLE | MASK0x0100_STATISTICS | MASK0x2000_WOUNDS | MASK0x8000_ACTION_HAND);
                        }
                } else {
                        F021_a002_MAIN_BlitToScreen(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C008_GRAPHIC_STATUS_BOX_DEAD_CHAMPION), &L0871_s_Box, C040_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_11_OPTIMIZATION */
                        F053_aajz_TEXT_PrintToLogicalScreen(1 + L0868_i_ChampionStatusBoxX, 5, C13_COLOR_LIGHTEST_GRAY, C01_COLOR_DARK_GRAY, L0865_ps_Champion->Name);
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_11_OPTIMIZATION Machine code size reduced. This code produces 2 bytes less of executable code */
                        F053_aajz_TEXT_PrintToLogicalScreen(L0868_i_ChampionStatusBoxX + 1, 5, C13_COLOR_LIGHTEST_GRAY, C01_COLOR_DARK_GRAY, L0865_ps_Champion->Name);
#endif
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_07_FIX Function call moved to F319_xxxx_CHAMPION_Kill so that champion icons are displayed correctly */
                        F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G054_ai_Graphic562_Box_ChampionIcons[M26_CHAMPION_ICON_INDEX(L0865_ps_Champion->Cell, G308_i_PartyDirection) << 2], C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN); /* BUG0_36 A champion icon may be missing in the upper right corner of the screen after loading a saved game where at least one champion is dead. When a dead champion is reborn at a Vi Altar, the champion cell is set to the first available cell where there is no champion alive. It is then possible that the cell of the reborn champion is the same as the cell of another dead champion in the party. If the index of the dead champion is higher than the index of the reborn champion and the game is saved then when restarting the game from the saved game the icon of the reborn champion will not appear on screen. This is only a graphic glitch and you only need to click on the black area where the missing icon should be to make it appear again. When the game is loaded, the state of each champion is drawn. For a dead champion, this erases the champion icon according to the cell of the dead champion, even if another champion is at the same cell */
#endif
                        F386_ezzz_MENUS_DrawActionIcon(P615_ui_ChampionIndex);
                        goto T292_042;
                }
        }
        if (!(L0865_ps_Champion->CurrentHealth)) {
                goto T292_042;
        }
        if (M07_GET(L0862_ui_ChampionAttributes, MASK0x0080_NAME_TITLE)) {
                A0864_i_ColorIndex = (P615_ui_ChampionIndex == G411_i_LeaderIndex) ? C09_COLOR_GOLD : C13_COLOR_LIGHTEST_GRAY;
                if (L0863_B_IsInventoryChampion) {
                        F052_aaoz_TEXT_PrintToViewport(3, 7, A0864_i_ColorIndex, L0866_pc_ChampionName = L0865_ps_Champion->Name);
                        L0869_i_ChampionTitleX = 6 * strlen(L0866_pc_ChampionName) + 3;
                        L0867_c_ChampionTitleFirstCharacter = L0865_ps_Champion->Title[0];
                        if ((L0867_c_ChampionTitleFirstCharacter != ',') && (L0867_c_ChampionTitleFirstCharacter != ';') && (L0867_c_ChampionTitleFirstCharacter != '-')) {
                                L0869_i_ChampionTitleX += 6;
                        }
                        F052_aaoz_TEXT_PrintToViewport(L0869_i_ChampionTitleX, 7, A0864_i_ColorIndex, L0865_ps_Champion->Title);
                        M08_SET(L0862_ui_ChampionAttributes, MASK0x4000_VIEWPORT);
                } else {
                        L0871_s_Box.Y1 = 0;
                        L0871_s_Box.Y2 = 6;
                        L0871_s_Box.X2 = (L0871_s_Box.X1 = L0868_i_ChampionStatusBoxX) + 42;
                        F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &L0871_s_Box, C01_COLOR_DARK_GRAY, C160_BYTE_WIDTH_SCREEN);
                        F053_aajz_TEXT_PrintToLogicalScreen(L0868_i_ChampionStatusBoxX + 1, 5, A0864_i_ColorIndex, C01_COLOR_DARK_GRAY, L0865_ps_Champion->Name);
                }
        }
        if (M07_GET(L0862_ui_ChampionAttributes, MASK0x0100_STATISTICS)) {
                F287_xxxx_CHAMPION_DrawBarGraphs(P615_ui_ChampionIndex);
                if (L0863_B_IsInventoryChampion) {
                        F290_xxxx_CHAMPION_DrawHealthStaminaManaValues(L0865_ps_Champion);
                        if ((L0865_ps_Champion->Food < 0) || (L0865_ps_Champion->Water < 0) || (L0865_ps_Champion->PoisonEventCount)) {
                                A0870_i_NativeBitmapIndex = C034_GRAPHIC_SLOT_BOX_WOUNDED;
                        } else {
                                A0870_i_NativeBitmapIndex = C033_GRAPHIC_SLOT_BOX_NORMAL;
                        }
                        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(A0870_i_NativeBitmapIndex), &G048_s_Graphic562_Box_Mouth, C016_BYTE_WIDTH, C12_COLOR_DARKEST_GRAY);
                        A0870_i_NativeBitmapIndex = C033_GRAPHIC_SLOT_BOX_NORMAL;
                        for(A0864_i_StatisticIndex = C1_STATISTIC_STRENGTH; A0864_i_StatisticIndex <= C6_STATISTIC_ANTIFIRE; A0864_i_StatisticIndex++) {
                                if ((L0865_ps_Champion->Statistics[A0864_i_StatisticIndex][C1_CURRENT] < L0865_ps_Champion->Statistics[A0864_i_StatisticIndex][C0_MAXIMUM])) {
                                        A0870_i_NativeBitmapIndex = C034_GRAPHIC_SLOT_BOX_WOUNDED;
                                        break;
                                }
                        }
                        F020_aAA5_MAIN_BlitToViewport(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(A0870_i_NativeBitmapIndex), &G049_s_Graphic562_Box_Eye, C016_BYTE_WIDTH, C12_COLOR_DARKEST_GRAY);
                        M08_SET(L0862_ui_ChampionAttributes, MASK0x4000_VIEWPORT);
                }
        }
        if (M07_GET(L0862_ui_ChampionAttributes, MASK0x2000_WOUNDS)) {
                for(A0864_i_SlotIndex = L0863_B_IsInventoryChampion ? C05_SLOT_FEET : C01_SLOT_ACTION_HAND; A0864_i_SlotIndex >= C00_SLOT_READY_HAND; A0864_i_SlotIndex--) {
                        F291_xxxx_CHAMPION_DrawSlot(P615_ui_ChampionIndex, A0864_i_SlotIndex);
                }
                if (L0863_B_IsInventoryChampion) {
                        M08_SET(L0862_ui_ChampionAttributes, MASK0x4000_VIEWPORT);
                }
        }
        if (M07_GET(L0862_ui_ChampionAttributes, MASK0x0200_LOAD) && L0863_B_IsInventoryChampion) {
                if (L0865_ps_Champion->Load > (A0864_i_Load = F309_awzz_CHAMPION_GetMaximumLoad(L0865_ps_Champion))) {
                        A0870_i_Color = C08_COLOR_RED;
                } else {
                        if (((long)L0865_ps_Champion->Load << 3) > ((long)A0864_i_Load * 5)) {
                                A0870_i_Color = C11_COLOR_YELLOW;
                        } else {
                                A0870_i_Color = C13_COLOR_LIGHTEST_GRAY;
                        }
                }
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_08_OPTIMIZATION */
                F052_aaoz_TEXT_PrintToViewport(104, 132, A0870_i_Color, "LOAD");
#endif
#ifdef C20_COMPILE_DM12EN_CSB20EN_CSB21EN /* CHANGE3_08_OPTIMIZATION Trailing space characters removed from strings */
                F052_aaoz_TEXT_PrintToViewport(104, 132, A0870_i_Color, "LOAD ");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                F052_aaoz_TEXT_PrintToViewport(104, 132, A0870_i_Color, "LAST ");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                F052_aaoz_TEXT_PrintToViewport(104, 132, A0870_i_Color, "CHARGE ");
#endif
                A0864_i_Load = L0865_ps_Champion->Load / 10;
                strcpy(G353_ac_StringBuildBuffer, F288_xxxx_CHAMPION_GetStringFromInteger(A0864_i_Load, TRUE, 3));
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                strcat(G353_ac_StringBuildBuffer, ".");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                strcat(G353_ac_StringBuildBuffer, ",");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                strcat(G353_ac_StringBuildBuffer, "KG,");
#endif
                A0864_i_Load = L0865_ps_Champion->Load - (A0864_i_Load * 10);
                strcat(G353_ac_StringBuildBuffer, F288_xxxx_CHAMPION_GetStringFromInteger(A0864_i_Load, FALSE, 1));
                strcat(G353_ac_StringBuildBuffer, "/");
                A0864_i_Load = (F309_awzz_CHAMPION_GetMaximumLoad(L0865_ps_Champion) + 5) / 10;
                strcat(G353_ac_StringBuildBuffer, F288_xxxx_CHAMPION_GetStringFromInteger(A0864_i_Load, TRUE, 3));
#ifdef C10_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_CSB20EN_CSB21EN /* CHANGE5_00_LOCALIZATION Translation to French language */
                strcat(G353_ac_StringBuildBuffer, " KG");
#endif
                F052_aaoz_TEXT_PrintToViewport(148, 132, A0870_i_Color, &G353_ac_StringBuildBuffer);
                M08_SET(L0862_ui_ChampionAttributes, MASK0x4000_VIEWPORT);
        }
        A0864_i_ChampionIconIndex = M26_CHAMPION_ICON_INDEX(L0865_ps_Champion->Cell, G308_i_PartyDirection);
        if (M07_GET(L0862_ui_ChampionAttributes, MASK0x0400_ICON) && (G599_ui_UseChampionIconOrdinalAsMousePointerBitmap != M00_INDEX_TO_ORDINAL(A0864_i_ChampionIconIndex))) {
                F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G054_ai_Graphic562_Box_ChampionIcons[A0864_i_ChampionIconIndex << 2], G046_auc_Graphic562_ChampionColor[P615_ui_ChampionIndex], C160_BYTE_WIDTH_SCREEN);
                F132_xzzz_VIDEO_Blit(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C028_GRAPHIC_CHAMPION_ICONS), G348_pl_Bitmap_LogicalScreenBase, &G054_ai_Graphic562_Box_ChampionIcons[A0864_i_ChampionIconIndex << 2], M26_CHAMPION_ICON_INDEX(L0865_ps_Champion->Direction, G308_i_PartyDirection) * 19, 0, C040_BYTE_WIDTH, C160_BYTE_WIDTH_SCREEN, C12_COLOR_DARKEST_GRAY);
        }
        if (M07_GET(L0862_ui_ChampionAttributes, MASK0x0800_PANEL) && L0863_B_IsInventoryChampion) {
                if (G333_B_PressingMouth) {
                        F345_xxxx_INVENTORY_DrawPanel_FoodWaterPoisoned();
                } else {
                        if (G331_B_PressingEye) {
                                if (G415_B_LeaderEmptyHanded) {
                                        F351_xxxx_INVENTORY_DrawChampionSkillsAndStatistics();
                                }
                        } else {
                                F347_xxxx_INVENTORY_DrawPanel();
                        }
                }
                M08_SET(L0862_ui_ChampionAttributes, MASK0x4000_VIEWPORT);
        }
        if (M07_GET(L0862_ui_ChampionAttributes, MASK0x8000_ACTION_HAND)) {
                F291_xxxx_CHAMPION_DrawSlot(P615_ui_ChampionIndex, C01_SLOT_ACTION_HAND);
                F386_ezzz_MENUS_DrawActionIcon(P615_ui_ChampionIndex);
                if (L0863_B_IsInventoryChampion) {
                        M08_SET(L0862_ui_ChampionAttributes, MASK0x4000_VIEWPORT);
                }
        }
        if (M07_GET(L0862_ui_ChampionAttributes, MASK0x4000_VIEWPORT)) {
                F097_lzzz_DUNGEONVIEW_DrawViewport(C0_VIEWPORT_NOT_DUNGEON_VIEW);
        }
        T292_042:
        M09_CLEAR(L0865_ps_Champion->Attributes, MASK0x0080_NAME_TITLE | MASK0x0100_STATISTICS | MASK0x0200_LOAD | MASK0x0400_ICON | MASK0x0800_PANEL | MASK0x1000_STATUS_BOX | MASK0x2000_WOUNDS | MASK0x4000_VIEWPORT | MASK0x8000_ACTION_HAND);
        F078_xzzz_MOUSE_ShowPointer();
}

VOID F293_ahzz_CHAMPION_DrawAllChampionStates()
{
        register int L0873_i_ChampionIndex;


        Vsync();
        for(L0873_i_ChampionIndex = C00_CHAMPION_FIRST; L0873_i_ChampionIndex < G305_ui_PartyChampionCount; L0873_i_ChampionIndex++) {
                F292_arzz_CHAMPION_DrawState(L0873_i_ChampionIndex);
        }
}

BOOLEAN F294_aozz_CHAMPION_IsAmmunitionCompatibleWithWeapon(P616_i_ChampionIndex, P617_i_WeaponSlotIndex, P618_i_AmmunitionSlotIndex)
int P616_i_ChampionIndex;
int P617_i_WeaponSlotIndex;
int P618_i_AmmunitionSlotIndex;
{
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_12_OPTIMIZATION Variable definition changed */
        CHAMPION* L0874_ps_Champion;
        register WEAPON_INFO* L0875_ps_WeaponInfo;
        register THING* L0876_pT_Thing;
#endif
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_06_FIX Useless code removed */
        long L0877_l_Unreferenced; /* BUG0_00 Useless code */
#endif
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_12_OPTIMIZATION Variable definition changed */
        int L0879_i_WeaponClass;
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_12_OPTIMIZATION Variable definition changed */
        register CHAMPION* L0874_ps_Champion;
        register WEAPON_INFO* L0875_ps_WeaponInfo;
        register THING L0878_T_Thing;
        register int L0879_i_WeaponClass;
#endif


        L0874_ps_Champion = &G407_s_Party.Champions[P616_i_ChampionIndex];
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_12_OPTIMIZATION Variable definition changed */
        L0876_pT_Thing = &L0874_ps_Champion->Slots[P617_i_WeaponSlotIndex];
        if (M12_TYPE(*L0876_pT_Thing) != C05_THING_TYPE_WEAPON) {
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_12_OPTIMIZATION Variable definition changed */
        L0878_T_Thing = L0874_ps_Champion->Slots[P617_i_WeaponSlotIndex];
        if (M12_TYPE(L0878_T_Thing) != C05_THING_TYPE_WEAPON) {
#endif
                return FALSE;
        }
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0875_ps_WeaponInfo = &G238_as_Graphic559_WeaponInfo[((WEAPON*)G284_apuc_ThingData[C05_THING_TYPE_WEAPON])[M13_INDEX(*L0876_pT_Thing)].Type];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0875_ps_WeaponInfo = F158_ayzz_DUNGEON_GetWeaponInfo(L0878_T_Thing);
#endif
        if ((L0875_ps_WeaponInfo->Class >= C016_CLASS_FIRST_BOW) && (L0875_ps_WeaponInfo->Class <= C031_CLASS_LAST_BOW)) {
                L0879_i_WeaponClass = C010_CLASS_BOW_AMMUNITION;
        } else {
                if ((L0875_ps_WeaponInfo->Class >= C032_CLASS_FIRST_SLING) && (L0875_ps_WeaponInfo->Class <= C047_CLASS_LAST_SLING)) {
                        L0879_i_WeaponClass = C011_CLASS_SLING_AMMUNITION;
                } else {
                        return FALSE;
                }
        }
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_12_OPTIMIZATION Variable definition changed */
        L0876_pT_Thing = &L0874_ps_Champion->Slots[P618_i_AmmunitionSlotIndex];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_12_OPTIMIZATION Variable definition changed */
        L0878_T_Thing = L0874_ps_Champion->Slots[P618_i_AmmunitionSlotIndex];
#endif
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        return ((M12_TYPE(*L0876_pT_Thing) == C05_THING_TYPE_WEAPON) && (G238_as_Graphic559_WeaponInfo[((WEAPON*)G284_apuc_ThingData[C05_THING_TYPE_WEAPON])[M13_INDEX(*L0876_pT_Thing)].Type].Class == L0879_i_WeaponClass));
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L0875_ps_WeaponInfo = F158_ayzz_DUNGEON_GetWeaponInfo(L0878_T_Thing);
        return ((M12_TYPE(L0878_T_Thing) == C05_THING_TYPE_WEAPON) && (L0875_ps_WeaponInfo->Class == L0879_i_WeaponClass));
#endif
}

BOOLEAN F295_xxxx_CHAMPION_HasObjectIconInSlotBoxChanged(P619_i_SlotBoxIndex, P620_T_Thing)
register int P619_i_SlotBoxIndex;
THING P620_T_Thing;
{
        register int L0880_i_CurrentIconIndex;
        register int L0881_i_NewIconIndex;


        L0880_i_CurrentIconIndex = F039_aaaL_OBJECT_GetIconIndexInSlotBox(P619_i_SlotBoxIndex);
        if (((L0880_i_CurrentIconIndex < C032_ICON_WEAPON_DAGGER) && (L0880_i_CurrentIconIndex >= C000_ICON_JUNK_COMPASS_NORTH)) ||
            ((L0880_i_CurrentIconIndex >= C148_ICON_POTION_MA_POTION_MON_POTION) && (L0880_i_CurrentIconIndex <= C163_ICON_POTION_WATER_FLASK)) ||
            (L0880_i_CurrentIconIndex == C195_ICON_POTION_EMPTY_FLASK)) {
                L0881_i_NewIconIndex = F033_aaaz_OBJECT_GetIconIndex(P620_T_Thing);
                if (L0881_i_NewIconIndex != L0880_i_CurrentIconIndex) {
                        if ((P619_i_SlotBoxIndex < C08_SLOT_BOX_INVENTORY_FIRST_SLOT) && !G420_B_MousePointerHiddenToDrawChangedObjectIconOnScreen) {
                                G420_B_MousePointerHiddenToDrawChangedObjectIconOnScreen = TRUE;
                                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                        }
                        F038_AA07_OBJECT_DrawIconInSlotBox(P619_i_SlotBoxIndex, L0881_i_NewIconIndex);
                        return TRUE;
                }
        }
        return FALSE;
}

/* This function draws visible object icons that have changed (in the leader hand, champion hands, champion inventory slots and open chest slots) */
VOID F296_aizz_CHAMPION_DrawChangedObjectIcons()
{
        register unsigned int L0882_ui_Counter;
#define A0882_ui_SlotBoxIndex L0882_ui_Counter
#define A0882_ui_SlotIndex    L0882_ui_Counter
        register int L0883_i_InventoryChampionOrdinal;
        register int L0884_i_Multiple;
#define A0884_i_LeaderHandObjectIconIndex L0884_i_Multiple
#define A0884_B_DrawViewport              L0884_i_Multiple
        register int L0885_i_ChampionIndex;
        register THING* L0886_pT_Thing;
        register CHAMPION* L0887_ps_Champion;
        int L0888_i_IconIndex;
        BOOLEAN L0889_B_ObjectIconChanged;


        L0883_i_InventoryChampionOrdinal = G423_i_InventoryChampionOrdinal;
        if (G299_ui_CandidateChampionOrdinal && !L0883_i_InventoryChampionOrdinal) {
                return;
        }
        G420_B_MousePointerHiddenToDrawChangedObjectIconOnScreen = FALSE;
        if ((((A0884_i_LeaderHandObjectIconIndex = G413_i_LeaderHandObjectIconIndex) < C032_ICON_WEAPON_DAGGER) && ((A0884_i_LeaderHandObjectIconIndex = G413_i_LeaderHandObjectIconIndex) >= C000_ICON_JUNK_COMPASS_NORTH)) || (((A0884_i_LeaderHandObjectIconIndex = G413_i_LeaderHandObjectIconIndex) >= C148_ICON_POTION_MA_POTION_MON_POTION) && ((A0884_i_LeaderHandObjectIconIndex = G413_i_LeaderHandObjectIconIndex) <= C163_ICON_POTION_WATER_FLASK)) || ((A0884_i_LeaderHandObjectIconIndex = G413_i_LeaderHandObjectIconIndex) == C195_ICON_POTION_EMPTY_FLASK)) {
                L0888_i_IconIndex = F033_aaaz_OBJECT_GetIconIndex(G414_T_LeaderHandObject);
                if (L0888_i_IconIndex != A0884_i_LeaderHandObjectIconIndex) {
                        G420_B_MousePointerHiddenToDrawChangedObjectIconOnScreen = TRUE;
                        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                        F036_aA19_OBJECT_ExtractIconFromBitmap(L0888_i_IconIndex, G412_puc_Bitmap_ObjectIconForMousePointer);
                        F068_aagz_MOUSE_SetPointerToObject(G412_puc_Bitmap_ObjectIconForMousePointer);
                        G413_i_LeaderHandObjectIconIndex = L0888_i_IconIndex;
                        F034_aaau_OBJECT_DrawLeaderHandObjectName(G414_T_LeaderHandObject);
                }
        }
        for(A0882_ui_SlotBoxIndex = 0; A0882_ui_SlotBoxIndex < (G305_ui_PartyChampionCount << 1); A0882_ui_SlotBoxIndex++) {
                L0885_i_ChampionIndex = A0882_ui_SlotBoxIndex >> 1;
                if (L0883_i_InventoryChampionOrdinal == M00_INDEX_TO_ORDINAL(L0885_i_ChampionIndex)) {
                        continue;
                }
                if ((F295_xxxx_CHAMPION_HasObjectIconInSlotBoxChanged(A0882_ui_SlotBoxIndex, G407_s_Party.Champions[L0885_i_ChampionIndex].Slots[M70_HAND_SLOT_INDEX(A0882_ui_SlotBoxIndex)])) && (M70_HAND_SLOT_INDEX(A0882_ui_SlotBoxIndex) == C01_SLOT_ACTION_HAND)) {
                        F386_ezzz_MENUS_DrawActionIcon(L0885_i_ChampionIndex);
                }
        }
        if (L0883_i_InventoryChampionOrdinal) {
                L0887_ps_Champion = &G407_s_Party.Champions[M01_ORDINAL_TO_INDEX(L0883_i_InventoryChampionOrdinal)];
                L0886_pT_Thing = &L0887_ps_Champion->Slots[A0882_ui_SlotIndex = C00_SLOT_READY_HAND];
                for(A0884_B_DrawViewport = FALSE; A0882_ui_SlotIndex < C30_SLOT_CHEST_1; A0882_ui_SlotIndex++, L0886_pT_Thing++) {
                        A0884_B_DrawViewport |= (L0889_B_ObjectIconChanged = F295_xxxx_CHAMPION_HasObjectIconInSlotBoxChanged(A0882_ui_SlotIndex + C08_SLOT_BOX_INVENTORY_FIRST_SLOT, *L0886_pT_Thing));
                        if (L0889_B_ObjectIconChanged && (A0882_ui_SlotIndex == C01_SLOT_ACTION_HAND)) {
                                F386_ezzz_MENUS_DrawActionIcon(M01_ORDINAL_TO_INDEX(L0883_i_InventoryChampionOrdinal));
                        }
                }
                if (G424_i_PanelContent == C4_PANEL_CHEST) {
                        L0886_pT_Thing = G425_aT_ChestSlots;
                        for(A0882_ui_SlotIndex = 0; A0882_ui_SlotIndex < 8; A0882_ui_SlotIndex++, L0886_pT_Thing++) {
                                A0884_B_DrawViewport |= F295_xxxx_CHAMPION_HasObjectIconInSlotBoxChanged(A0882_ui_SlotIndex + C38_SLOT_BOX_CHEST_FIRST_SLOT, *L0886_pT_Thing);
                        }
                }
                if (A0884_B_DrawViewport) {
                        M08_SET(L0887_ps_Champion->Attributes, MASK0x4000_VIEWPORT);
                        F292_arzz_CHAMPION_DrawState(M01_ORDINAL_TO_INDEX(L0883_i_InventoryChampionOrdinal));
                }
        }
        if (G420_B_MousePointerHiddenToDrawChangedObjectIconOnScreen) {
                F078_xzzz_MOUSE_ShowPointer();
        }
}

VOID F297_atzz_CHAMPION_PutObjectInLeaderHand(P621_T_Thing, P622_B_SetMousePointerToObjectInMainLoop)
THING P621_T_Thing;
BOOLEAN P622_B_SetMousePointerToObjectInMainLoop; /* If TRUE, the mouse pointer is refreshed on screen by F002_xxxx_MAIN_GameLoop_COPYPROTECTIONDF() but only if the viewport does not contain an inventory (G423_i_InventoryChampionOrdinal = 0). If FALSE, the mouse pointer is refreshed immediately. This is used when the viewport contains an inventory (G423_i_InventoryChampionOrdinal != 0) */
{
        if (P621_T_Thing == C0xFFFF_THING_NONE) {
                return;
        }
        G415_B_LeaderEmptyHanded = FALSE;
        F036_aA19_OBJECT_ExtractIconFromBitmap(G413_i_LeaderHandObjectIconIndex = F033_aaaz_OBJECT_GetIconIndex(G414_T_LeaderHandObject = P621_T_Thing), G412_puc_Bitmap_ObjectIconForMousePointer);
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        F034_aaau_OBJECT_DrawLeaderHandObjectName(P621_T_Thing);
        if (P622_B_SetMousePointerToObjectInMainLoop) {
                G325_B_SetMousePointerToObjectInMainLoop = TRUE;
        } else {
                F068_aagz_MOUSE_SetPointerToObject(G412_puc_Bitmap_ObjectIconForMousePointer);
        }
        F078_xzzz_MOUSE_ShowPointer();
        if (G411_i_LeaderIndex != CM1_CHAMPION_NONE) {
                G407_s_Party.Champions[G411_i_LeaderIndex].Load += F140_yzzz_DUNGEON_GetObjectWeight(P621_T_Thing);
                M08_SET(G407_s_Party.Champions[G411_i_LeaderIndex].Attributes, MASK0x0200_LOAD);
                F292_arzz_CHAMPION_DrawState(G411_i_LeaderIndex);
        }
}

THING F298_aqzz_CHAMPION_GetObjectRemovedFromLeaderHand()
{
        register THING L0890_T_LeaderHandObject;


        G415_B_LeaderEmptyHanded = TRUE;
        if ((L0890_T_LeaderHandObject = G414_T_LeaderHandObject) != C0xFFFF_THING_NONE) {
                G414_T_LeaderHandObject = C0xFFFF_THING_NONE;
                G413_i_LeaderHandObjectIconIndex = CM1_ICON_NONE;
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                F035_aaaw_OBJECT_ClearLeaderHandObjectName();
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_13_OPTIMIZATION */
                F067_aaat_MOUSE_SetPointerToNormal((G411_i_LeaderIndex == CM1_CHAMPION_NONE) ? C0_POINTER_ARROW : C1_POINTER_HAND);
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_13_OPTIMIZATION Function call replaced by an equivalent and smaller call. This function includes the function call and test used in previous versions */
                F069_aaaL_MOUSE_SetPointer();
#endif
                F078_xzzz_MOUSE_ShowPointer();
                if (G411_i_LeaderIndex != CM1_CHAMPION_NONE) {
                        G407_s_Party.Champions[G411_i_LeaderIndex].Load -= F140_yzzz_DUNGEON_GetObjectWeight(L0890_T_LeaderHandObject);
                        M08_SET(G407_s_Party.Champions[G411_i_LeaderIndex].Attributes, MASK0x0200_LOAD);
                        F292_arzz_CHAMPION_DrawState(G411_i_LeaderIndex);
                }
        }
        return L0890_T_LeaderHandObject;
}

VOID F299_xxxx_CHAMPION_ApplyObjectModifiersToStatistics(P623_ps_Champion, P624_ui_SlotIndex, P625_ui_IconIndex, P626_i_ModifierFactor, P627_T_Thing)
register CHAMPION* P623_ps_Champion;
register unsigned int P624_ui_SlotIndex;
#define AP624_ui_StatisticValueIndex P624_ui_SlotIndex
register unsigned int P625_ui_IconIndex;
int P626_i_ModifierFactor;
THING P627_T_Thing;
{
        WEAPON* L0893_ps_Weapon;
        register int L0891_i_Multiple;
#define A0891_i_StatisticIndex L0891_i_Multiple
#define A0891_i_ThingType      L0891_i_Multiple
        register int L0892_i_Modifier;


        L0892_i_Modifier = 0;
        if ((((A0891_i_ThingType = M12_TYPE(P627_T_Thing)) == C05_THING_TYPE_WEAPON) || (A0891_i_ThingType == C06_THING_TYPE_ARMOUR)) && (P624_ui_SlotIndex >= C00_SLOT_READY_HAND) && (P624_ui_SlotIndex <= C12_SLOT_QUIVER_LINE1_1)) {
                L0893_ps_Weapon = (WEAPON*)F156_afzz_DUNGEON_GetThingData(P627_T_Thing);
                if (((A0891_i_ThingType == C05_THING_TYPE_WEAPON) && L0893_ps_Weapon->Cursed) || ((A0891_i_ThingType == C06_THING_TYPE_ARMOUR) && ((ARMOUR*)L0893_ps_Weapon)->Cursed)) {
                        A0891_i_StatisticIndex = C0_STATISTIC_LUCK;
                        L0892_i_Modifier = -3;
                        goto T299_044_ApplyModifier;
                }
        }
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_25_FIX The Luck modifier of the Rabbit's Foot is applied when it is inside a chest */
        if (P625_ui_IconIndex == C137_ICON_JUNK_RABBITS_FOOT) { /* BUG0_37 The contents of a chest are refreshed when grabbing or putting a Rabbit's Foot anywhere in the inventory. An object in a chest may disappear when grabbing a Rabbit's Foot from a chest. A champion may have a permanent bonus or malus to the (hidden) Luck statistic. The Luck modifier of the Rabbit's Foot is applied when it is inside a chest while it should not. This causes the following issues:
- If a chest is open then each time you grab or put a Rabbit's Foot anywhere in the inventory the chest contents are drawn again in the panel. If there are empty slots in the chest then objects are reorganized so they occupy the first slots of the chest
- If there is an object in the leader hand when grabbing a Rabbit's Foot from a chest then the next object in the chest disappears and becomes an orphan. This occurs because when processing F302_mzzz_CHAMPION_ProcessCommands28To65_ClickOnSlotBox:
a) F300_aozz_CHAMPION_GetObjectRemovedFromSlot is called to remove the Rabbit's Foot from the slot which in turn calls F299_xxxx_CHAMPION_ApplyObjectModifiersToStatistics to remove the Rabbit's Foot modifier. This sets the MASK0x0800_PANEL flag for the champion.
b) F297_atzz_CHAMPION_PutObjectInLeaderHand is called to place the Rabbit's Foot in hand. This calls F292_arzz_CHAMPION_DrawState. Because MASK0x0800_PANEL is set, the chest is closed an opened again, shifting the object right after the slot where the Rabbit's Foot was to the previous slot.
c) F301_apzz_CHAMPION_AddObjectInSlot is called to place the object that was in the leader hand in the Chest, overwriting the object that was shifted there which has now become an orphan thing.
- When a champion puts a Rabbit's Foot in a chest, that champion's Luck is increased. When a champion removes a Rabbit's Foot from a chest, that champion's Luck is decreased. If you move a chest containing a Rabbit's Foot from one champion to another between these two operations, then the first champion keeps a permanent Luck bonus and the second champion has no bonus for possessing a Rabbit's Foot and will even get a malus when removing it from the chest */
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_25_FIX The Luck modifier of the Rabbit's Foot is not applied when it is inside a chest */
        if ((P625_ui_IconIndex == C137_ICON_JUNK_RABBITS_FOOT) && (P624_ui_SlotIndex < C30_SLOT_CHEST_1)) {
#endif
                A0891_i_StatisticIndex = C0_STATISTIC_LUCK;
                L0892_i_Modifier = 10;
        } else {
                if (P624_ui_SlotIndex == C01_SLOT_ACTION_HAND) {
                        if (P625_ui_IconIndex == C045_ICON_WEAPON_MACE_OF_ORDER) {
                                A0891_i_StatisticIndex = C1_STATISTIC_STRENGTH;
                                L0892_i_Modifier = 5;
                        } else {
                                A0891_i_StatisticIndex = C8_STATISTIC_MANA;
                                if ((P625_ui_IconIndex >= C020_ICON_WEAPON_STAFF_OF_CLAWS_EMPTY) && (P625_ui_IconIndex <= C022_ICON_WEAPON_STAFF_OF_CLAWS_FULL)) {
                                        L0892_i_Modifier = 4;
                                } else {
                                        if ((P625_ui_IconIndex >= C058_ICON_WEAPON_STAFF) && (P625_ui_IconIndex <= C066_ICON_WEAPON_SCEPTRE_OF_LYF)) {
                                                switch (P625_ui_IconIndex) {
                                                        case C058_ICON_WEAPON_STAFF:
                                                                L0892_i_Modifier = 2;
                                                                break;
                                                        case C059_ICON_WEAPON_WAND:
                                                                L0892_i_Modifier = 1;
                                                                break;
                                                        case C060_ICON_WEAPON_TEOWAND:
                                                                L0892_i_Modifier = 6;
                                                                break;
                                                        case C061_ICON_WEAPON_YEW_STAFF:
                                                                L0892_i_Modifier = 4;
                                                                break;
                                                        case C062_ICON_WEAPON_STAFF_OF_MANAR_STAFF_OF_IRRA:
                                                                L0892_i_Modifier = 10;
                                                                break;
                                                        case C063_ICON_WEAPON_SNAKE_STAFF_CROSS_OF_NETA:
                                                                L0892_i_Modifier = 8;
                                                                break;
                                                        case C064_ICON_WEAPON_THE_CONDUIT_SERPENT_STAFF:
                                                                L0892_i_Modifier = 16;
                                                                break;
                                                        case C065_ICON_WEAPON_DRAGON_SPIT:
                                                                L0892_i_Modifier = 7;
                                                                break;
                                                        case C066_ICON_WEAPON_SCEPTRE_OF_LYF:
                                                                L0892_i_Modifier = 5;
                                                }
                                        } else {
                                                switch (P625_ui_IconIndex) {
                                                        case C038_ICON_WEAPON_DELTA_SIDE_SPLITTER:
                                                                L0892_i_Modifier = 1;
                                                                break;
                                                        case C041_ICON_WEAPON_THE_INQUISITOR_DRAGON_FANG:
                                                                L0892_i_Modifier = 2;
                                                                break;
                                                        case C040_ICON_WEAPON_VORPAL_BLADE:
                                                                L0892_i_Modifier = 4;
                                                }
                                        }
                                }
                        }
                } else {
                        if (P624_ui_SlotIndex == C04_SLOT_LEGS) {
                                if (P625_ui_IconIndex == C142_ICON_ARMOUR_POWERTOWERS) {
                                        A0891_i_StatisticIndex = C1_STATISTIC_STRENGTH;
                                        L0892_i_Modifier = 10;
                                }
                        } else {
                                if (P624_ui_SlotIndex == C02_SLOT_HEAD) {
                                        if (P625_ui_IconIndex == C104_ICON_ARMOUR_CROWN_OF_NERRA) {
                                                A0891_i_StatisticIndex = C3_STATISTIC_WISDOM;
                                                L0892_i_Modifier = 10;
                                        } else {
                                                if (P625_ui_IconIndex == C140_ICON_ARMOUR_DEXHELM) {
                                                        A0891_i_StatisticIndex = C2_STATISTIC_DEXTERITY;
                                                        L0892_i_Modifier = 10;
                                                }
                                        }
                                } else {
                                        if (P624_ui_SlotIndex == C03_SLOT_TORSO) {
                                                if (P625_ui_IconIndex == C141_ICON_ARMOUR_FLAMEBAIN) {
                                                        A0891_i_StatisticIndex = C6_STATISTIC_ANTIFIRE;
                                                        L0892_i_Modifier = 12;
                                                } else {
                                                        if (P625_ui_IconIndex == C081_ICON_ARMOUR_CLOAK_OF_NIGHT) {
                                                                A0891_i_StatisticIndex = C2_STATISTIC_DEXTERITY;
                                                                L0892_i_Modifier = 8;
                                                        }
                                                }
                                        } else {
                                                if (P624_ui_SlotIndex == C10_SLOT_NECK) {
                                                        if ((P625_ui_IconIndex >= C010_ICON_JUNK_JEWEL_SYMAL_UNEQUIPPED) && (P625_ui_IconIndex <= C011_ICON_JUNK_JEWEL_SYMAL_EQUIPPED)) {
                                                                A0891_i_StatisticIndex = C5_STATISTIC_ANTIMAGIC;
                                                                L0892_i_Modifier = 15;
                                                        } else {
                                                                if (P625_ui_IconIndex == C081_ICON_ARMOUR_CLOAK_OF_NIGHT) {
                                                                        A0891_i_StatisticIndex = C2_STATISTIC_DEXTERITY;
                                                                        L0892_i_Modifier = 8;
                                                                } else {
                                                                        if (P625_ui_IconIndex == C122_ICON_JUNK_MOONSTONE) {
                                                                                A0891_i_StatisticIndex = C8_STATISTIC_MANA;
                                                                                L0892_i_Modifier = 3;
                                                                        }
                                                                }
                                                        }
                                                }
                                        }
                                }
                        }
                }
        }
        T299_044_ApplyModifier:
        if (L0892_i_Modifier) {
                L0892_i_Modifier *= P626_i_ModifierFactor;
                if (A0891_i_StatisticIndex == C8_STATISTIC_MANA) {
                        P623_ps_Champion->MaximumMana += L0892_i_Modifier;
                } else {
                        if (A0891_i_StatisticIndex < C6_STATISTIC_ANTIFIRE + 1) {
                                AP624_ui_StatisticValueIndex = C0_MAXIMUM;
                                while (AP624_ui_StatisticValueIndex <= C2_MINIMUM) {
                                        P623_ps_Champion->Statistics[A0891_i_StatisticIndex][AP624_ui_StatisticValueIndex++] += L0892_i_Modifier; /* BUG0_38 A champion is much luckier than expected during combat when equipped with at least 4 cursed objects. Champion statistic values are stored as one byte unsigned integers which can store values between 0 to 255. Each champion has a minimum, a maximum and a current value for each of the statistics. When an object modifier is applied to a statistic, all three values are modified but there is no check to make sure the new values stay in the bounds of 0 to 255. This is not an issue in most cases because nearly all modifiers are positive and with relatively small values so that any combination of champion statistic value with these modifiers will result in valid values. The only issue is with the hidden luck statistic and the modifier for cursed objects which is the only negative modifier in the game (-3). The minimum luck value for all champions is set to 10 at the beginning of the game and is only changed by object modifiers. If enough cursed objects are equipped (between 4 and 6) then the minimum value 'wraps around' and becomes a large value (254 with 4 cursed objects, 251 with 5 cursed objects and 248 with 6 cursed objects). The first time that the luck of the champion is tested after the cursed objects are equipped, the current luck value is set to its minimum value (248, 251 or 254) because the game detects that the current value is smaller than the minimum allowed. During the following luck tests, if the test succeeds, the current luck is decreased by 2 and then bounded between the minimum and maximum values. The current value is then smaller than the minimum value so the current luck value is set to its minimum value (248, 251 or 254). If the test fails, the current luck is increased by 2 and then bounded between the minimum and maximum values. The current value is then larger than the minimum value, however it is larger than the maximum value so the current value is set to its maximum value. During the next luck test, the current value will again be smaller than the minimum and be reset to the minimum value. As a consequence, while the cursed objects are equipped, the current luck value can only have two possible values: either its maximum value, or its minimum value (which is even larger at 248, 251 or 254) so the champion is always luckier than he should be */
                                }
                        }
                }
                M08_SET(P623_ps_Champion->Attributes, MASK0x0800_PANEL | MASK0x0100_STATISTICS);
        }
}

THING F300_aozz_CHAMPION_GetObjectRemovedFromSlot(P628_ui_ChampionIndex, P629_ui_SlotIndex)
unsigned int P628_ui_ChampionIndex;
register unsigned int P629_ui_SlotIndex;
{
        register THING L0894_T_Thing;
        register int L0895_i_IconIndex;
        register CHAMPION* L0896_ps_Champion;
        register WEAPON* L0897_ps_Weapon;
        BOOLEAN L0898_B_IsInventoryChampion;


        L0896_ps_Champion = &G407_s_Party.Champions[P628_ui_ChampionIndex];
        if (P629_ui_SlotIndex >= C30_SLOT_CHEST_1) {
                L0894_T_Thing = G425_aT_ChestSlots[P629_ui_SlotIndex - C30_SLOT_CHEST_1];
                G425_aT_ChestSlots[P629_ui_SlotIndex - C30_SLOT_CHEST_1] = C0xFFFF_THING_NONE;
        } else {
                L0894_T_Thing = L0896_ps_Champion->Slots[P629_ui_SlotIndex];
                L0896_ps_Champion->Slots[P629_ui_SlotIndex] = C0xFFFF_THING_NONE;
        }
        if (L0894_T_Thing == C0xFFFF_THING_NONE) {
                return C0xFFFF_THING_NONE;
        }
        L0898_B_IsInventoryChampion = (M00_INDEX_TO_ORDINAL(P628_ui_ChampionIndex) == G423_i_InventoryChampionOrdinal);
        L0895_i_IconIndex = F033_aaaz_OBJECT_GetIconIndex(L0894_T_Thing);
        F299_xxxx_CHAMPION_ApplyObjectModifiersToStatistics(L0896_ps_Champion, P629_ui_SlotIndex, L0895_i_IconIndex, -1, L0894_T_Thing); /* Remove objet modifiers */
        L0897_ps_Weapon = (WEAPON*)F156_afzz_DUNGEON_GetThingData(L0894_T_Thing);
        if (P629_ui_SlotIndex == C10_SLOT_NECK) {
                if ((L0895_i_IconIndex >= C012_ICON_JUNK_ILLUMULET_UNEQUIPPED) && (L0895_i_IconIndex <= C013_ICON_JUNK_ILLUMULET_EQUIPPED)) {
                        ((JUNK*)L0897_ps_Weapon)->ChargeCount = 0;
                        G407_s_Party.MagicalLightAmount -= G039_ai_Graphic562_LightPowerToLightAmount[2];
                        F337_akzz_INVENTORY_SetDungeonViewPalette();
                } else {
                        if ((L0895_i_IconIndex >= C010_ICON_JUNK_JEWEL_SYMAL_UNEQUIPPED) && (L0895_i_IconIndex <= C011_ICON_JUNK_JEWEL_SYMAL_EQUIPPED)) {
                                ((JUNK*)L0897_ps_Weapon)->ChargeCount = 0;
                        }
                }
        }
        F291_xxxx_CHAMPION_DrawSlot(P628_ui_ChampionIndex, P629_ui_SlotIndex);
        if (L0898_B_IsInventoryChampion) {
                M08_SET(L0896_ps_Champion->Attributes, MASK0x4000_VIEWPORT);
        }
        if (P629_ui_SlotIndex < C02_SLOT_HEAD) {
                if (P629_ui_SlotIndex == C01_SLOT_ACTION_HAND) {
                        M08_SET(L0896_ps_Champion->Attributes, MASK0x8000_ACTION_HAND);
                        if (G506_i_ActingChampionOrdinal == M00_INDEX_TO_ORDINAL(P628_ui_ChampionIndex)) {
                                F388_rzzz_MENUS_ClearActingChampion();
                        }
                        if ((L0895_i_IconIndex >= C030_ICON_SCROLL_SCROLL_OPEN) && (L0895_i_IconIndex <= C031_ICON_SCROLL_SCROLL_CLOSED)) {
                                ((SCROLL*)L0897_ps_Weapon)->Closed = TRUE;
                                F296_aizz_CHAMPION_DrawChangedObjectIcons();
                        }
                }
                if ((L0895_i_IconIndex >= C004_ICON_WEAPON_TORCH_UNLIT) && (L0895_i_IconIndex <= C007_ICON_WEAPON_TORCH_LIT)) {
                        L0897_ps_Weapon->Lit = FALSE;
                        F337_akzz_INVENTORY_SetDungeonViewPalette();
                        F296_aizz_CHAMPION_DrawChangedObjectIcons();
                }
                if (L0898_B_IsInventoryChampion && (P629_ui_SlotIndex == C01_SLOT_ACTION_HAND)) {
                        if (L0895_i_IconIndex == C144_ICON_CONTAINER_CHEST_CLOSED) {
                                F334_akzz_INVENTORY_CloseChest();
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_26_OPTIMIZATION */
                                M08_SET(L0896_ps_Champion->Attributes, MASK0x0800_PANEL);
                        } else {
                                if ((L0895_i_IconIndex >= C030_ICON_SCROLL_SCROLL_OPEN) && (L0895_i_IconIndex <= C031_ICON_SCROLL_SCROLL_CLOSED)) {
                                        M08_SET(L0896_ps_Champion->Attributes, MASK0x0800_PANEL);
                                }
                        }
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_26_OPTIMIZATION Code deduplication */
                                goto T300_011;
                        }
                        if ((L0895_i_IconIndex >= C030_ICON_SCROLL_SCROLL_OPEN) && (L0895_i_IconIndex <= C031_ICON_SCROLL_SCROLL_CLOSED)) {
                                T300_011:
                                M08_SET(L0896_ps_Champion->Attributes, MASK0x0800_PANEL);
                        }
#endif
                }
        }
        L0896_ps_Champion->Load -= F140_yzzz_DUNGEON_GetObjectWeight(L0894_T_Thing);
        M08_SET(L0896_ps_Champion->Attributes, MASK0x0200_LOAD);
        return L0894_T_Thing;
}

VOID F301_apzz_CHAMPION_AddObjectInSlot(P630_ui_ChampionIndex, P631_T_Thing, P632_ui_SlotIndex)
register unsigned int P630_ui_ChampionIndex;
register THING P631_T_Thing;
register unsigned int P632_ui_SlotIndex;
{
        register int L0899_i_IconIndex;
        register CHAMPION* L0900_ps_Champion;
        register WEAPON* L0901_ps_Weapon;
        BOOLEAN L0902_B_IsInventoryChampion;


        if (P631_T_Thing == C0xFFFF_THING_NONE) {
                return;
        }
        L0900_ps_Champion = &G407_s_Party.Champions[P630_ui_ChampionIndex];
        if (P632_ui_SlotIndex >= C30_SLOT_CHEST_1) {
                G425_aT_ChestSlots[P632_ui_SlotIndex - C30_SLOT_CHEST_1] = P631_T_Thing;
        } else {
                L0900_ps_Champion->Slots[P632_ui_SlotIndex] = P631_T_Thing;
        }
        L0900_ps_Champion->Load += F140_yzzz_DUNGEON_GetObjectWeight(P631_T_Thing);
        M08_SET(L0900_ps_Champion->Attributes, MASK0x0200_LOAD);
        L0899_i_IconIndex = F033_aaaz_OBJECT_GetIconIndex(P631_T_Thing);
        L0902_B_IsInventoryChampion = (M00_INDEX_TO_ORDINAL(P630_ui_ChampionIndex) == G423_i_InventoryChampionOrdinal);
        F299_xxxx_CHAMPION_ApplyObjectModifiersToStatistics(L0900_ps_Champion, P632_ui_SlotIndex, L0899_i_IconIndex, 1, P631_T_Thing); /* Add objet modifiers */
        L0901_ps_Weapon = (WEAPON*)F156_afzz_DUNGEON_GetThingData(P631_T_Thing);
        if (P632_ui_SlotIndex < C02_SLOT_HEAD) {
                if (P632_ui_SlotIndex == C01_SLOT_ACTION_HAND) {
                        M08_SET(L0900_ps_Champion->Attributes, MASK0x8000_ACTION_HAND);
                        if (G506_i_ActingChampionOrdinal == M00_INDEX_TO_ORDINAL(P630_ui_ChampionIndex)) {
                                F388_rzzz_MENUS_ClearActingChampion();
                        }
                        if ((L0899_i_IconIndex >= C030_ICON_SCROLL_SCROLL_OPEN) && (L0899_i_IconIndex <= C031_ICON_SCROLL_SCROLL_CLOSED)) {
                                ((SCROLL*)L0901_ps_Weapon)->Closed = FALSE;
                                F296_aizz_CHAMPION_DrawChangedObjectIcons();
                        }
                }
                if (L0899_i_IconIndex == C004_ICON_WEAPON_TORCH_UNLIT) {
                        L0901_ps_Weapon->Lit = TRUE;
                        F337_akzz_INVENTORY_SetDungeonViewPalette();
                        F296_aizz_CHAMPION_DrawChangedObjectIcons();
                } else {
                        if (L0902_B_IsInventoryChampion && (P632_ui_SlotIndex == C01_SLOT_ACTION_HAND) &&
                            ((L0899_i_IconIndex == C144_ICON_CONTAINER_CHEST_CLOSED) || ((L0899_i_IconIndex >= C030_ICON_SCROLL_SCROLL_OPEN) && (L0899_i_IconIndex <= C031_ICON_SCROLL_SCROLL_CLOSED)))) {
                                M08_SET(L0900_ps_Champion->Attributes, MASK0x0800_PANEL);
                        }
                }
        } else {
                if (P632_ui_SlotIndex == C10_SLOT_NECK) {
                        if ((L0899_i_IconIndex >= C012_ICON_JUNK_ILLUMULET_UNEQUIPPED) && (L0899_i_IconIndex <= C013_ICON_JUNK_ILLUMULET_EQUIPPED)) {
                                ((JUNK*)L0901_ps_Weapon)->ChargeCount = 1;
                                G407_s_Party.MagicalLightAmount += G039_ai_Graphic562_LightPowerToLightAmount[2];
                                F337_akzz_INVENTORY_SetDungeonViewPalette();
                                L0899_i_IconIndex++;
                        } else {
                                if ((L0899_i_IconIndex >= C010_ICON_JUNK_JEWEL_SYMAL_UNEQUIPPED) && (L0899_i_IconIndex <= C011_ICON_JUNK_JEWEL_SYMAL_EQUIPPED)) {
                                        ((JUNK*)L0901_ps_Weapon)->ChargeCount = 1;
                                        L0899_i_IconIndex++;
                                }
                        }
                }
        }
        F291_xxxx_CHAMPION_DrawSlot(P630_ui_ChampionIndex, P632_ui_SlotIndex);
        if (L0902_B_IsInventoryChampion) {
                M08_SET(L0900_ps_Champion->Attributes, MASK0x4000_VIEWPORT);
        }
}

VOID F302_mzzz_CHAMPION_ProcessCommands28To65_ClickOnSlotBox(P633_ui_SlotBoxIndex)
unsigned int P633_ui_SlotBoxIndex;
{
        register int L0903_i_ChampionIndex;
        register unsigned int L0904_ui_SlotIndex;
        register THING L0905_T_LeaderHandObject;
        register THING L0906_T_SlotThing;


        if (P633_ui_SlotBoxIndex < C08_SLOT_BOX_INVENTORY_FIRST_SLOT) {
                if (G299_ui_CandidateChampionOrdinal) {
                        return;
                }
                L0903_i_ChampionIndex = P633_ui_SlotBoxIndex >> 1;
                if ((L0903_i_ChampionIndex >= G305_ui_PartyChampionCount) || (M00_INDEX_TO_ORDINAL(L0903_i_ChampionIndex) == (int)G423_i_InventoryChampionOrdinal) || !G407_s_Party.Champions[L0903_i_ChampionIndex].CurrentHealth) {
                        return;
                }
                L0904_ui_SlotIndex = M70_HAND_SLOT_INDEX(P633_ui_SlotBoxIndex);
        } else {
                L0903_i_ChampionIndex = M01_ORDINAL_TO_INDEX(G423_i_InventoryChampionOrdinal);
                L0904_ui_SlotIndex = P633_ui_SlotBoxIndex - C08_SLOT_BOX_INVENTORY_FIRST_SLOT;
        }
        L0905_T_LeaderHandObject = G414_T_LeaderHandObject;
        if (L0904_ui_SlotIndex >= C30_SLOT_CHEST_1) {
                L0906_T_SlotThing = G425_aT_ChestSlots[L0904_ui_SlotIndex - C30_SLOT_CHEST_1];
        } else {
                L0906_T_SlotThing = G407_s_Party.Champions[L0903_i_ChampionIndex].Slots[L0904_ui_SlotIndex];
        }
        if ((L0906_T_SlotThing == C0xFFFF_THING_NONE) && (L0905_T_LeaderHandObject == C0xFFFF_THING_NONE)) {
                return;
        }
        if ((L0905_T_LeaderHandObject != C0xFFFF_THING_NONE) && (!(G237_as_Graphic559_ObjectInfo[F141_anzz_DUNGEON_GetObjectInfoIndex(L0905_T_LeaderHandObject)].AllowedSlots & G038_ai_Graphic562_SlotMasks[L0904_ui_SlotIndex]))) {
                return;
        }
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        if (L0905_T_LeaderHandObject != C0xFFFF_THING_NONE) {
                F298_aqzz_CHAMPION_GetObjectRemovedFromLeaderHand();
        }
        if (L0906_T_SlotThing != C0xFFFF_THING_NONE) {
                F300_aozz_CHAMPION_GetObjectRemovedFromSlot(L0903_i_ChampionIndex, L0904_ui_SlotIndex);
                F297_atzz_CHAMPION_PutObjectInLeaderHand(L0906_T_SlotThing, FALSE); /* BUG0_39 In the leader inventory, the Food/Water/Poisoned panel is briefly drawn when replacing a scroll or chest by another scroll or chest in the action hand. This does not occur for champions other than the leader. When swapping the objects between the action hand and the leader hand, the program first removes the object in the action hand with a call to F300_aozz_CHAMPION_GetObjectRemovedFromSlot. If the removed object is a chest or a scroll then this sets the MASK0x0800_PANEL flag in the champion data to refresh the panel. Then the object in the leader hand is removed with a call to F297_atzz_CHAMPION_PutObjectInLeaderHand. The weight of the object in the leader hand is part of the load of the leader, so this sets another flag MASK0x0200_LOAD in the champion data of the leader to refresh the Load value and then calls the function F292_arzz_CHAMPION_DrawState to draw the leader champion state. If the champion is not the leader, nothing is drawn. If the champion is the leader, the Food/Water/Poisoned panel is drawn because at this point the action hand is empty. Then the object that was removed from the leader hand is put in the action hand with a call to F301_apzz_CHAMPION_AddObjectInSlot and this draws the panel again, this time showing the chest contents or scroll text. The fix would be to swap the calls to F300_aozz_CHAMPION_GetObjectRemovedFromSlot and F297_atzz_CHAMPION_PutObjectInLeaderHand (note this would not fix the double refresh of the Load value after removing the first object and after putting the second object) */
        }
        if (L0905_T_LeaderHandObject != C0xFFFF_THING_NONE) {
                F301_apzz_CHAMPION_AddObjectInSlot(L0903_i_ChampionIndex, L0905_T_LeaderHandObject, L0904_ui_SlotIndex);
        }
        F292_arzz_CHAMPION_DrawState(L0903_i_ChampionIndex);
        F078_xzzz_MOUSE_ShowPointer();
}

unsigned int F303_AA09_CHAMPION_GetSkillLevel(P634_i_ChampionIndex, P635_ui_SkillIndex)
int P634_i_ChampionIndex;
unsigned int P635_ui_SkillIndex;
{
        register long L0907_l_Experience;
        register int L0908_i_SkillLevel;
        register int L0909_i_NeckIconIndex;
        register int L0910_i_ActionHandIconIndex;
        register SKILL* L0911_ps_Skill;
        register CHAMPION* L0912_ps_Champion;
        BOOLEAN L0913_B_IgnoreTemporaryExperience;
        BOOLEAN L0914_B_IgnoreObjectModifiers;


        if (G300_B_PartyIsSleeping) {
                return 1;
        }
        L0913_B_IgnoreTemporaryExperience = M07_GET(P635_ui_SkillIndex, MASK0x8000_IGNORE_TEMPORARY_EXPERIENCE);
        L0914_B_IgnoreObjectModifiers = M07_GET(P635_ui_SkillIndex, MASK0x4000_IGNORE_OBJECT_MODIFIERS);
        M09_CLEAR(P635_ui_SkillIndex, MASK0x8000_IGNORE_TEMPORARY_EXPERIENCE | MASK0x4000_IGNORE_OBJECT_MODIFIERS);
        L0912_ps_Champion = &G407_s_Party.Champions[P634_i_ChampionIndex];
        L0911_ps_Skill = &L0912_ps_Champion->Skills[P635_ui_SkillIndex];
        L0907_l_Experience = L0911_ps_Skill->Experience;
        if (!L0913_B_IgnoreTemporaryExperience) {
                L0907_l_Experience += L0911_ps_Skill->TemporaryExperience;
        }
        if (P635_ui_SkillIndex > C03_SKILL_WIZARD) { /* Hidden skill */
                L0911_ps_Skill = &L0912_ps_Champion->Skills[(P635_ui_SkillIndex - C04_SKILL_SWING) >> 2];
                L0907_l_Experience += L0911_ps_Skill->Experience; /* Add experience in the base skill */
                if (!L0913_B_IgnoreTemporaryExperience) {
                        L0907_l_Experience += L0911_ps_Skill->TemporaryExperience;
                }
                L0907_l_Experience >>= 1; /* Halve experience to get average of base skill + hidden skill experience */
        }
        L0908_i_SkillLevel = 1;
        while (L0907_l_Experience >= 500) {
                L0907_l_Experience >>= 1;
                L0908_i_SkillLevel++;
        }
        if (!L0914_B_IgnoreObjectModifiers) {
                if ((L0910_i_ActionHandIconIndex = F033_aaaz_OBJECT_GetIconIndex(L0912_ps_Champion->Slots[C01_SLOT_ACTION_HAND])) == C027_ICON_WEAPON_THE_FIRESTAFF) {
                        L0908_i_SkillLevel++;
                } else {
                        if (L0910_i_ActionHandIconIndex == C028_ICON_WEAPON_THE_FIRESTAFF_COMPLETE) {
                                L0908_i_SkillLevel += 2;
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_09_FIX The skill modifier of the Firestaff is not cumulative with other modifiers */
                        } else { /* BUG0_40 If a champion has The Firestaff in the action hand then skill modifiers from other objects (Pendant Feral, Ekkhard Cross, Gem of Ages and Moonstone) are ignored. Wrong code causes the skill modifier of the Firesatff not to be cumulative with other modifiers */
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_09_FIX The skill modifier of the Firesatff is cumulative with other modifiers */
                        }
                }
#endif
                                L0909_i_NeckIconIndex = F033_aaaz_OBJECT_GetIconIndex(L0912_ps_Champion->Slots[C10_SLOT_NECK]);
                                switch (P635_ui_SkillIndex) {
                                        case C03_SKILL_WIZARD:
                                                if (L0909_i_NeckIconIndex == C124_ICON_JUNK_PENDANT_FERAL) {
                                                        L0908_i_SkillLevel += 1;
                                                }
                                                break;
                                        case C15_SKILL_DEFEND:
                                                if (L0909_i_NeckIconIndex == C121_ICON_JUNK_EKKHARD_CROSS) {
                                                        L0908_i_SkillLevel += 1;
                                                }
                                                break;
                                        case C13_SKILL_HEAL:
                                                if ((L0909_i_NeckIconIndex == C120_ICON_JUNK_GEM_OF_AGES) || (L0910_i_ActionHandIconIndex == C066_ICON_WEAPON_SCEPTRE_OF_LYF)) { /* The skill modifiers of these two objects are not cumulative */
                                                        L0908_i_SkillLevel += 1;
                                                }
                                                break;
                                        case C14_SKILL_INFLUENCE:
                                                if (L0909_i_NeckIconIndex == C122_ICON_JUNK_MOONSTONE) {
                                                        L0908_i_SkillLevel += 1;
                                                }
                                }
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_09_FIX */
                        }
                }
#endif
        }
        return L0908_i_SkillLevel;
}

VOID F304_apzz_CHAMPION_AddSkillExperience(P636_ui_ChampionIndex, P637_ui_SkillIndex, P638_ui_Experience)
unsigned int P636_ui_ChampionIndex;
unsigned int P637_ui_SkillIndex;
register unsigned int P638_ui_Experience;
#define AP638_ui_SkillLevelAfter P638_ui_Experience
#define AP638_ui_ChampionColor   P638_ui_Experience
{
        register unsigned int L0915_ui_Multiple;
#define A0915_ui_MapDifficulty    L0915_ui_Multiple
#define A0915_ui_SkillLevelBefore L0915_ui_Multiple
#define A0915_ui_VitalityAmount   L0915_ui_Multiple
#define A0915_ui_StaminaAmount    L0915_ui_Multiple
        register int L0916_i_BaseSkillIndex;
        register long L0917_l_Experience_Useless; /* BUG0_00 Useless code */
        register SKILL* L0918_ps_Skill;
        register CHAMPION* L0919_ps_Champion;
        int L0920_i_MinorStatisticIncrease;
        int L0921_i_MajorStatisticIncrease;
        int L0922_i_BaseSkillLevel;


        if ((P637_ui_SkillIndex >= C04_SKILL_SWING) && (P637_ui_SkillIndex <= C11_SKILL_SHOOT) && (G361_l_LastCreatureAttackTime < (G313_ul_GameTime - 150))) {
                P638_ui_Experience >>= 1;
        }
        if (P638_ui_Experience) {
                if (A0915_ui_MapDifficulty = G269_ps_CurrentMap->C.Difficulty) {
                        P638_ui_Experience *= A0915_ui_MapDifficulty;
                }
                L0919_ps_Champion = &G407_s_Party.Champions[P636_ui_ChampionIndex];
                if (P637_ui_SkillIndex >= C04_SKILL_SWING) {
                        L0916_i_BaseSkillIndex = (P637_ui_SkillIndex - C04_SKILL_SWING) >> 2;
                } else {
                        L0916_i_BaseSkillIndex = P637_ui_SkillIndex;
                }
                L0917_l_Experience_Useless = L0918_ps_Skill->Experience; /* BUG0_00 Useless code. Use of uninitialized variable L0918_ps_Skill */
                A0915_ui_SkillLevelBefore = F303_AA09_CHAMPION_GetSkillLevel(P636_ui_ChampionIndex, L0916_i_BaseSkillIndex | (MASK0x4000_IGNORE_OBJECT_MODIFIERS | MASK0x8000_IGNORE_TEMPORARY_EXPERIENCE));
                if ((P637_ui_SkillIndex >= C04_SKILL_SWING) && (G361_l_LastCreatureAttackTime > (G313_ul_GameTime - 25))) {
                        P638_ui_Experience <<= 1;
                }
                L0918_ps_Skill = &L0919_ps_Champion->Skills[P637_ui_SkillIndex];
                L0918_ps_Skill->Experience += P638_ui_Experience;
                if (L0918_ps_Skill->TemporaryExperience < 32000) {
                        L0918_ps_Skill->TemporaryExperience += F026_a003_MAIN_GetBoundedValue(1, P638_ui_Experience >> 3, 100);
                }
                L0918_ps_Skill = &L0919_ps_Champion->Skills[L0916_i_BaseSkillIndex];
                if (P637_ui_SkillIndex >= C04_SKILL_SWING) {
                        L0918_ps_Skill->Experience += P638_ui_Experience;
                }
                AP638_ui_SkillLevelAfter = F303_AA09_CHAMPION_GetSkillLevel(P636_ui_ChampionIndex, L0916_i_BaseSkillIndex | (MASK0x4000_IGNORE_OBJECT_MODIFIERS | MASK0x8000_IGNORE_TEMPORARY_EXPERIENCE));
                if (AP638_ui_SkillLevelAfter > A0915_ui_SkillLevelBefore) {
                        L0922_i_BaseSkillLevel = AP638_ui_SkillLevelAfter;
                        L0920_i_MinorStatisticIncrease = M05_RANDOM(2);
                        L0921_i_MajorStatisticIncrease = 1 + M05_RANDOM(2);
                        A0915_ui_VitalityAmount = M05_RANDOM(2); /* For Priest skill, the amount is 0 or 1 for all skill levels */
                        if (L0916_i_BaseSkillIndex != C02_SKILL_PRIEST) {
                                A0915_ui_VitalityAmount &= AP638_ui_SkillLevelAfter; /* For non Priest skills the amount is 0 for even skill levels. The amount is 0 or 1 for odd skill levels */
                        }
                        L0919_ps_Champion->Statistics[C4_STATISTIC_VITALITY][C0_MAXIMUM] += A0915_ui_VitalityAmount;
                        A0915_ui_StaminaAmount = L0919_ps_Champion->MaximumStamina;
                        L0919_ps_Champion->Statistics[C6_STATISTIC_ANTIFIRE][C0_MAXIMUM] += M05_RANDOM(2) & ~AP638_ui_SkillLevelAfter; /* The amount is 0 for odd skill levels. The amount is 0 or 1 for even skill levels */
                        switch (L0916_i_BaseSkillIndex) {
                                case C00_SKILL_FIGHTER:
                                        A0915_ui_StaminaAmount >>= 4;
                                        AP638_ui_SkillLevelAfter *= 3;
                                        L0919_ps_Champion->Statistics[C1_STATISTIC_STRENGTH][C0_MAXIMUM] += L0921_i_MajorStatisticIncrease;
                                        L0919_ps_Champion->Statistics[C2_STATISTIC_DEXTERITY][C0_MAXIMUM] += L0920_i_MinorStatisticIncrease;
                                        break;
                                case C01_SKILL_NINJA:
                                        A0915_ui_StaminaAmount /= 21;
                                        AP638_ui_SkillLevelAfter <<= 1;
                                        L0919_ps_Champion->Statistics[C1_STATISTIC_STRENGTH][C0_MAXIMUM] += L0920_i_MinorStatisticIncrease;
                                        L0919_ps_Champion->Statistics[C2_STATISTIC_DEXTERITY][C0_MAXIMUM] += L0921_i_MajorStatisticIncrease;
                                        break;
                                case C03_SKILL_WIZARD:
                                        A0915_ui_StaminaAmount >>= 5;
                                        L0919_ps_Champion->MaximumMana += AP638_ui_SkillLevelAfter + (AP638_ui_SkillLevelAfter >> 1);
                                        L0919_ps_Champion->Statistics[C3_STATISTIC_WISDOM][C0_MAXIMUM] += L0921_i_MajorStatisticIncrease;
                                        goto T304_016;
                                case C02_SKILL_PRIEST:
                                        A0915_ui_StaminaAmount /= 25;
                                        L0919_ps_Champion->MaximumMana += AP638_ui_SkillLevelAfter;
                                        AP638_ui_SkillLevelAfter += (AP638_ui_SkillLevelAfter + 1) >> 1;
                                        L0919_ps_Champion->Statistics[C3_STATISTIC_WISDOM][C0_MAXIMUM] += L0920_i_MinorStatisticIncrease;
                                        T304_016:
                                        if ((L0919_ps_Champion->MaximumMana += F024_aatz_MAIN_GetMinimumValue(M04_RANDOM(4), L0922_i_BaseSkillLevel - 1)) > 900) {
                                                L0919_ps_Champion->MaximumMana = 900;
                                        }
                                        L0919_ps_Champion->Statistics[C5_STATISTIC_ANTIMAGIC][C0_MAXIMUM] += M02_RANDOM(3);
                        }
                        if ((L0919_ps_Champion->MaximumHealth += AP638_ui_SkillLevelAfter + M02_RANDOM((AP638_ui_SkillLevelAfter >> 1) + 1)) > 999) {
                                L0919_ps_Champion->MaximumHealth = 999;
                        }
                        if ((L0919_ps_Champion->MaximumStamina += A0915_ui_StaminaAmount + M02_RANDOM((A0915_ui_StaminaAmount >> 1) + 1)) > 9999) {
                                L0919_ps_Champion->MaximumStamina = 9999;
                        }
                        M08_SET(L0919_ps_Champion->Attributes, MASK0x0100_STATISTICS);
                        F292_arzz_CHAMPION_DrawState(P636_ui_ChampionIndex);
                        F051_AA19_TEXT_MESSAGEAREA_PrintLineFeed();
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(AP638_ui_ChampionColor = G046_auc_Graphic562_ChampionColor[P636_ui_ChampionIndex], L0919_ps_Champion->Name);
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(AP638_ui_ChampionColor, " JUST GAINED A ");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(AP638_ui_ChampionColor, " HAT SOEBEN ");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(AP638_ui_ChampionColor, " VIENT DE DEVENIR ");
#endif
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(AP638_ui_ChampionColor, G417_apc_BaseSkillNames[L0916_i_BaseSkillIndex]);
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(AP638_ui_ChampionColor, " LEVEL!");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(AP638_ui_ChampionColor, " STUFE ERREICHT!");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(AP638_ui_ChampionColor, "!");
#endif
                }
        }
}

int F305_xxxx_CHAMPION_GetThrowingStaminaCost(P639_T_Thing)
THING P639_T_Thing;
{
        register int L0923_i_Weight;
        register int L0924_i_StaminaCost;


        L0924_i_StaminaCost = F026_a003_MAIN_GetBoundedValue(1, L0923_i_Weight = F140_yzzz_DUNGEON_GetObjectWeight(P639_T_Thing) >> 1, 10);
        while ((L0923_i_Weight -= 10) > 0) {
                L0924_i_StaminaCost += L0923_i_Weight >> 1;
        }
        return L0924_i_StaminaCost;
}

int F306_xxxx_CHAMPION_GetStaminaAdjustedValue(P640_ps_Champion, P641_i_Value)
register CHAMPION* P640_ps_Champion;
int P641_i_Value;
{
        register int L0925_i_CurrentStamina;
        register int L0926_i_HalfMaximumStamina;


        if ((L0925_i_CurrentStamina = P640_ps_Champion->CurrentStamina) < (L0926_i_HalfMaximumStamina = P640_ps_Champion->MaximumStamina >> 1)) {
                return (P641_i_Value >>= 1) + (int)(((long)P641_i_Value * (long)L0925_i_CurrentStamina) / L0926_i_HalfMaximumStamina);
        }
        return P641_i_Value;
}

unsigned int F307_fzzz_CHAMPION_GetStatisticAdjustedAttack(P642_ps_Champion, P643_ui_StatisticIndex, P644_ui_Attack)
CHAMPION* P642_ps_Champion;
unsigned int P643_ui_StatisticIndex;
unsigned int P644_ui_Attack;
{
        register int L0927_i_Factor;


        if ((L0927_i_Factor = 170 - P642_ps_Champion->Statistics[P643_ui_StatisticIndex][C1_CURRENT]) < 16) { /* BUG0_41 The Antifire and Antimagic statistics are completely ignored. The Vitality statistic is ignored against poison and to determine the probability of being wounded. Vitality is still used normally to compute the defense against wounds and the speed of health regeneration. A bug in the Megamax C compiler produces wrong machine code for this statement. It always returns 0 for the current statistic value so that L0927_i_Factor = 170 in all cases */
                return P644_ui_Attack >> 3;
        }
        return F030_aaaW_MAIN_GetScaledProduct(P644_ui_Attack, 7, L0927_i_Factor);
}

BOOLEAN F308_vzzz_CHAMPION_IsLucky(P645_ps_Champion, P646_ui_Percentage)
CHAMPION* P645_ps_Champion;
register unsigned int P646_ui_Percentage;
#define AP646_ui_IsLucky P646_ui_Percentage
{
        register unsigned char* L0928_puc_Statistic;


        if (M05_RANDOM(2) && (M02_RANDOM(100) > P646_ui_Percentage)) {
                return TRUE;
        }
        L0928_puc_Statistic = P645_ps_Champion->Statistics[C0_STATISTIC_LUCK];
        AP646_ui_IsLucky = (M02_RANDOM(L0928_puc_Statistic[C1_CURRENT]) > P646_ui_Percentage);
        L0928_puc_Statistic[C1_CURRENT] = F026_a003_MAIN_GetBoundedValue(L0928_puc_Statistic[C2_MINIMUM], L0928_puc_Statistic[C1_CURRENT] + (AP646_ui_IsLucky ? -2 : 2), L0928_puc_Statistic[C0_MAXIMUM]);
        return AP646_ui_IsLucky;
}

unsigned int F309_awzz_CHAMPION_GetMaximumLoad(P647_ps_Champion)
register CHAMPION* P647_ps_Champion;
{
        register unsigned int L0929_ui_MaximumLoad;
        register int L0930_i_Wounds;


        L0929_ui_MaximumLoad = (P647_ps_Champion->Statistics[C1_STATISTIC_STRENGTH][C1_CURRENT] << 3) + 100;
        L0929_ui_MaximumLoad = F306_xxxx_CHAMPION_GetStaminaAdjustedValue(P647_ps_Champion, L0929_ui_MaximumLoad);
        if (L0930_i_Wounds = P647_ps_Champion->Wounds) {
                L0929_ui_MaximumLoad -= L0929_ui_MaximumLoad >> (M07_GET(L0930_i_Wounds, MASK0x0010_LEGS) ? 2 : 3);
        }
        if (F033_aaaz_OBJECT_GetIconIndex(P647_ps_Champion->Slots[C05_SLOT_FEET]) == C119_ICON_ARMOUR_ELVEN_BOOTS) {
                L0929_ui_MaximumLoad += L0929_ui_MaximumLoad >> 4;
        }
        L0929_ui_MaximumLoad += 9;
        L0929_ui_MaximumLoad -= L0929_ui_MaximumLoad % 10; /* Round the value to the next multiple of 10 */
        return L0929_ui_MaximumLoad;
}

int F310_AA08_CHAMPION_GetMovementTicks(P648_ps_Champion)
register CHAMPION* P648_ps_Champion;
{
        register unsigned int L0931_ui_Multiple;
#define A0931_ui_Load       L0931_ui_Multiple
#define A0931_ui_WoundTicks L0931_ui_Multiple
        register unsigned int L0932_ui_MaximumLoad;
        register int L0933_i_Ticks;


        if ((L0932_ui_MaximumLoad = F309_awzz_CHAMPION_GetMaximumLoad(P648_ps_Champion)) > (A0931_ui_Load = P648_ps_Champion->Load)) { /* BUG0_72 The party moves very slowly even though no champion 'Load' value is drawn in red. When the Load of a champion has exactly the maximum value he can carry then the Load is drawn in yellow but the speed is the same as when the champion is overloaded (when the Load is drawn in red). The comparison operator should be >= instead of > */
                L0933_i_Ticks = 2;
                if (((long)A0931_ui_Load << 3) > ((long)L0932_ui_MaximumLoad * 5)) {
                        L0933_i_Ticks++;
                }
                A0931_ui_WoundTicks = 1;
        } else {
                L0933_i_Ticks = 4 + (((A0931_ui_Load - L0932_ui_MaximumLoad) << 2) / L0932_ui_MaximumLoad);
                A0931_ui_WoundTicks = 2;
        }
        if (M07_GET(P648_ps_Champion->Wounds, MASK0x0020_FEET)) {
                L0933_i_Ticks += A0931_ui_WoundTicks;
        }
        if (F033_aaaz_OBJECT_GetIconIndex(P648_ps_Champion->Slots[C05_SLOT_FEET]) == C194_ICON_ARMOUR_BOOT_OF_SPEED) {
                L0933_i_Ticks--;
        }
        return L0933_i_Ticks;
}

int F311_wzzz_CHAMPION_GetDexterity(P649_ps_Champion)
register CHAMPION* P649_ps_Champion;
{
        register int L0934_i_Dexterity;


        L0934_i_Dexterity = M03_RANDOM(8) + P649_ps_Champion->Statistics[C2_STATISTIC_DEXTERITY][C1_CURRENT];
        L0934_i_Dexterity -= ((long)(L0934_i_Dexterity >> 1) * (long)P649_ps_Champion->Load) / F309_awzz_CHAMPION_GetMaximumLoad(P649_ps_Champion);
        if (G300_B_PartyIsSleeping) {
                L0934_i_Dexterity >>= 1;
        }
        return F026_a003_MAIN_GetBoundedValue(1 + M03_RANDOM(8), L0934_i_Dexterity >> 1, 100 - M03_RANDOM(8));
}

unsigned int F312_xzzz_CHAMPION_GetStrength(P650_i_ChampionIndex, P651_i_SlotIndex)
int P650_i_ChampionIndex;
int P651_i_SlotIndex;
{
        register int L0935_i_Strength;
        register unsigned int L0936_ui_Multiple;
#define A0936_ui_ObjectWeight L0936_ui_Multiple
#define A0936_ui_SkillLevel   L0936_ui_Multiple
        register unsigned int L0937_ui_Multiple;
#define A0937_ui_OneSixteenthMaximumLoad L0937_ui_Multiple
#define A0937_ui_Class                   L0937_ui_Multiple
        register THING L0938_T_Thing;
        register CHAMPION* L0939_ps_Champion;
        register WEAPON_INFO* L0940_ps_WeaponInfo;
        int L0941_i_LoadThreshold;


        L0939_ps_Champion = &G407_s_Party.Champions[P650_i_ChampionIndex];
        L0935_i_Strength = M03_RANDOM(16) + L0939_ps_Champion->Statistics[C1_STATISTIC_STRENGTH][C1_CURRENT];
        L0938_T_Thing = L0939_ps_Champion->Slots[P651_i_SlotIndex];
        if ((A0936_ui_ObjectWeight = F140_yzzz_DUNGEON_GetObjectWeight(L0938_T_Thing)) <= (A0937_ui_OneSixteenthMaximumLoad = F309_awzz_CHAMPION_GetMaximumLoad(L0939_ps_Champion) >> 4)) {
                L0935_i_Strength += A0936_ui_ObjectWeight - 12;
        } else {
                if (A0936_ui_ObjectWeight <= (L0941_i_LoadThreshold = A0937_ui_OneSixteenthMaximumLoad + ((A0937_ui_OneSixteenthMaximumLoad - 12) >> 1))) {
                        L0935_i_Strength += (A0936_ui_ObjectWeight - A0937_ui_OneSixteenthMaximumLoad) >> 1;
                } else {
                        L0935_i_Strength -= (A0936_ui_ObjectWeight - L0941_i_LoadThreshold) << 1;
                }
        }
        if (M12_TYPE(L0938_T_Thing) == C05_THING_TYPE_WEAPON) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L0940_ps_WeaponInfo = &G238_as_Graphic559_WeaponInfo[((WEAPON*)G284_apuc_ThingData[C05_THING_TYPE_WEAPON])[M13_INDEX(L0938_T_Thing)].Type];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L0940_ps_WeaponInfo = F158_ayzz_DUNGEON_GetWeaponInfo(L0938_T_Thing);
#endif
                L0935_i_Strength += L0940_ps_WeaponInfo->Strength;
                A0936_ui_SkillLevel = 0;
                A0937_ui_Class = L0940_ps_WeaponInfo->Class;
                if ((A0937_ui_Class == C000_CLASS_SWING_WEAPON) || (A0937_ui_Class == C002_CLASS_DAGGER_AND_AXES)) {
                        A0936_ui_SkillLevel = F303_AA09_CHAMPION_GetSkillLevel(P650_i_ChampionIndex, C04_SKILL_SWING);
                }
                if ((A0937_ui_Class != C000_CLASS_SWING_WEAPON) && (A0937_ui_Class < C016_CLASS_FIRST_BOW)) {
                        A0936_ui_SkillLevel += F303_AA09_CHAMPION_GetSkillLevel(P650_i_ChampionIndex, C10_SKILL_THROW);
                }
                if ((A0937_ui_Class >= C016_CLASS_FIRST_BOW) && (A0937_ui_Class < C112_CLASS_FIRST_MAGIC_WEAPON)) {
                        A0936_ui_SkillLevel += F303_AA09_CHAMPION_GetSkillLevel(P650_i_ChampionIndex, C11_SKILL_SHOOT);
                }
                L0935_i_Strength += A0936_ui_SkillLevel << 1;
        }
        L0935_i_Strength = F306_xxxx_CHAMPION_GetStaminaAdjustedValue(L0939_ps_Champion, L0935_i_Strength);
        if (M07_GET(L0939_ps_Champion->Wounds, (P651_i_SlotIndex == C00_SLOT_READY_HAND) ? MASK0x0001_READY_HAND : MASK0x0002_ACTION_HAND)) {
                L0935_i_Strength >>= 1;
        }
        return F026_a003_MAIN_GetBoundedValue(0, L0935_i_Strength >> 1, 100);
}

int F313_xxxx_CHAMPION_GetWoundDefense(P652_i_ChampionIndex, P653_ui_WoundIndex)
int P652_i_ChampionIndex;
unsigned int P653_ui_WoundIndex;
{
        register int L0942_i_Multiple;
#define A0942_i_SlotIndex    L0942_i_Multiple
#define A0942_i_WoundDefense L0942_i_Multiple
        register unsigned int L0943_ui_ArmourShieldDefense;
        register BOOLEAN L0944_B_UseSharpDefense;
        register THING L0945_T_Thing;
        register CHAMPION* L0946_ps_Champion;
        register ARMOUR_INFO* L0947_ps_ArmourInfo;


        L0946_ps_Champion = &G407_s_Party.Champions[P652_i_ChampionIndex];
        if (L0944_B_UseSharpDefense = M07_GET(P653_ui_WoundIndex, MASK0x8000_USE_SHARP_DEFENSE)) {
                M09_CLEAR(P653_ui_WoundIndex, MASK0x8000_USE_SHARP_DEFENSE);
        }
        for(L0943_ui_ArmourShieldDefense = 0, A0942_i_SlotIndex = C00_SLOT_READY_HAND; A0942_i_SlotIndex <= C01_SLOT_ACTION_HAND; A0942_i_SlotIndex++) {
                if (M12_TYPE(L0945_T_Thing = L0946_ps_Champion->Slots[A0942_i_SlotIndex]) == C06_THING_TYPE_ARMOUR) {
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                        L0947_ps_ArmourInfo = &G239_as_Graphic559_ArmourInfo[(((ARMOUR*)G284_apuc_ThingData[C06_THING_TYPE_ARMOUR])[M13_INDEX(L0945_T_Thing)]).Type];
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                        L0947_ps_ArmourInfo = (ARMOUR_INFO*)F156_afzz_DUNGEON_GetThingData(L0945_T_Thing);
                        L0947_ps_ArmourInfo = &G239_as_Graphic559_ArmourInfo[((ARMOUR*)L0947_ps_ArmourInfo)->Type];
#endif
                        if (M07_GET(L0947_ps_ArmourInfo->Attributes, MASK0x0080_IS_A_SHIELD)) {
                                L0943_ui_ArmourShieldDefense += ((F312_xzzz_CHAMPION_GetStrength(P652_i_ChampionIndex, A0942_i_SlotIndex) + F143_mzzz_DUNGEON_GetArmourDefense(L0947_ps_ArmourInfo, L0944_B_UseSharpDefense)) * G050_auc_Graphic562_WoundDefenseFactor[P653_ui_WoundIndex]) >> ((A0942_i_SlotIndex == P653_ui_WoundIndex) ? 4 : 5);
                        }
                }
        }
        A0942_i_WoundDefense = M02_RANDOM((L0946_ps_Champion->Statistics[C4_STATISTIC_VITALITY][C1_CURRENT] >> 3) + 1);
        if (L0944_B_UseSharpDefense) {
                A0942_i_WoundDefense >>= 1;
        }
        A0942_i_WoundDefense += L0946_ps_Champion->ActionDefense + L0946_ps_Champion->ShieldDefense + G407_s_Party.ShieldDefense + L0943_ui_ArmourShieldDefense;
        if ((P653_ui_WoundIndex > C01_SLOT_ACTION_HAND) && (M12_TYPE(L0945_T_Thing = L0946_ps_Champion->Slots[P653_ui_WoundIndex]) == C06_THING_TYPE_ARMOUR)) {
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                A0942_i_WoundDefense += F143_mzzz_DUNGEON_GetArmourDefense(&G239_as_Graphic559_ArmourInfo[(((ARMOUR*)G284_apuc_ThingData[C06_THING_TYPE_ARMOUR])[M13_INDEX(L0945_T_Thing)]).Type], L0944_B_UseSharpDefense);
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                L0947_ps_ArmourInfo = (ARMOUR_INFO*)F156_afzz_DUNGEON_GetThingData(L0945_T_Thing);
                A0942_i_WoundDefense += F143_mzzz_DUNGEON_GetArmourDefense(&G239_as_Graphic559_ArmourInfo[((ARMOUR*)L0947_ps_ArmourInfo)->Type], L0944_B_UseSharpDefense);
#endif
        }
        if (M07_GET(L0946_ps_Champion->Wounds, 1 << P653_ui_WoundIndex)) {
                A0942_i_WoundDefense -= 8 + M04_RANDOM(4);
        }
        if (G300_B_PartyIsSleeping) {
                A0942_i_WoundDefense >>= 1;
        }
        return F026_a003_MAIN_GetBoundedValue(0, A0942_i_WoundDefense >> 1, 100);
}

VOID F314_gzzz_CHAMPION_WakeUp()
{
        int L0948_i_Unreferenced; /* BUG0_00 Useless code */


        G321_B_StopWaitingForPlayerInput = TRUE;
        G300_B_PartyIsSleeping = FALSE;
        G318_i_WaitForInputMaximumVerticalBlankCount = 10;
        F098_rzzz_DUNGEONVIEW_DrawFloorAndCeiling();
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_10_FIX */
        if (!G509_B_ActionAreaContainsIcons && !G506_i_ActingChampionOrdinal) { /* BUG0_42 The action icons are not drawn in the action area after you unfreeze the game. The variable G509_B_ActionAreaContainsIcons defining what to draw in the action area is not set in the right function in the code. 
        If you press ESC to freeze the game right after clicking on an action name while damage to a creature is being displayed in the action area, then when you unfreeze the game the action icons are not drawn in the action area which remains empty. You can get the action icons back by sleeping and waking up. This was fixed by moving this code from F314_gzzz_CHAMPION_WakeUp (the condition is different but the result is perfectly equivalent) */
                G509_B_ActionAreaContainsIcons = TRUE;
        }
#endif
        G441_ps_PrimaryMouseInput = G447_as_Graphic561_PrimaryMouseInput_Interface;
        G442_ps_SecondaryMouseInput = G448_as_Graphic561_SecondaryMouseInput_Movement;
        G443_ps_PrimaryKeyboardInput = G458_as_Graphic561_PrimaryKeyboardInput_Interface;
        G444_ps_SecondaryKeyboardInput = G459_as_Graphic561_SecondaryKeyboardInput_Movement;
        F357_qzzz_COMMAND_DiscardAllInput();
        F457_AA08_START_DrawEnabledMenus_COPYPROTECTIONF();
}

int F315_arzz_CHAMPION_GetScentOrdinal(P654_i_MapX, P655_i_MapY)
int P654_i_MapX;
int P655_i_MapY;
{
        register unsigned int L0949_ui_SearchedScent;
        register int L0950_i_ScentIndex;
        register unsigned int* L0951_pui_Scent;
        SCENT L0952_s_SearchedScent;


        if (L0950_i_ScentIndex = G407_s_Party.ScentCount) {
                L0952_s_SearchedScent.Location.MapX = P654_i_MapX;
                L0952_s_SearchedScent.Location.MapY = P655_i_MapY;
                L0952_s_SearchedScent.Location.MapIndex = G272_i_CurrentMapIndex;
                L0949_ui_SearchedScent = L0952_s_SearchedScent.Scent;
                L0951_pui_Scent = (unsigned int*)&G407_s_Party.Scents[L0950_i_ScentIndex--];
                do {
                        if ((*(--L0951_pui_Scent)) == L0949_ui_SearchedScent) {
                                return M00_INDEX_TO_ORDINAL(L0950_i_ScentIndex);
                        }
                } while (L0950_i_ScentIndex--);
        }
        return 0;
}

VOID F316_aizz_CHAMPION_DeleteScent(P656_ui_ScentIndex)
register unsigned int P656_ui_ScentIndex;
{
        register unsigned int L0953_ui_Count;


        if (L0953_ui_Count = --G407_s_Party.ScentCount - P656_ui_ScentIndex) {
                F007_aAA7_MAIN_CopyBytes(&G407_s_Party.Scents[P656_ui_ScentIndex + 1], &G407_s_Party.Scents[P656_ui_ScentIndex], L0953_ui_Count * sizeof(SCENT));
                F007_aAA7_MAIN_CopyBytes(&G407_s_Party.ScentStrengths[P656_ui_ScentIndex + 1], &G407_s_Party.ScentStrengths[P656_ui_ScentIndex], L0953_ui_Count);
        }
        if (P656_ui_ScentIndex < G407_s_Party.FirstScentIndex) {
                G407_s_Party.FirstScentIndex--;
        }
        if (P656_ui_ScentIndex < G407_s_Party.LastScentIndex) {
                G407_s_Party.LastScentIndex--;
        }
}

VOID F317_adzz_CHAMPION_AddScentStrength(P657_i_MapX, P658_i_MapY, P659_i_CycleCount)
int P657_i_MapX;
int P658_i_MapY;
register int P659_i_CycleCount;
{
        register int L0954_i_ScentIndex;
        register BOOLEAN L0955_B_Merge;
        register BOOLEAN L0956_B_CycleCountDefined;
        register SCENT* L0957_ps_Scent; /* BUG0_00 Useless code */
        SCENT L0958_s_Scent; /* BUG0_00 Useless code */


        if (L0954_i_ScentIndex = G407_s_Party.ScentCount) {
                if (L0955_B_Merge = M07_GET(P659_i_CycleCount, MASK0x8000_MERGE_CYCLES)) {
                        M09_CLEAR(P659_i_CycleCount, MASK0x8000_MERGE_CYCLES);
                }
                L0958_s_Scent.Location.MapX = P657_i_MapX; /* BUG0_00 Useless code */
                L0958_s_Scent.Location.MapY = P658_i_MapY; /* BUG0_00 Useless code */
                L0958_s_Scent.Location.MapIndex = G272_i_CurrentMapIndex; /* BUG0_00 Useless code */
                L0957_ps_Scent = G407_s_Party.Scents; /* BUG0_00 Useless code */
                L0956_B_CycleCountDefined = FALSE;
                while (L0954_i_ScentIndex--) {
                        *L0957_ps_Scent++ == L0958_s_Scent; /* BUG0_00 Useless code. The result of the comparison is ignored */
                        if (!L0956_B_CycleCountDefined) {
                                L0956_B_CycleCountDefined = TRUE;
                                if (L0955_B_Merge) {
                                        P659_i_CycleCount = F025_aatz_MAIN_GetMaximumValue(G407_s_Party.ScentStrengths[L0954_i_ScentIndex], P659_i_CycleCount);
                                } else {
                                        P659_i_CycleCount = F024_aatz_MAIN_GetMinimumValue(80, G407_s_Party.ScentStrengths[L0954_i_ScentIndex] + P659_i_CycleCount);
                                }
                        }
                        G407_s_Party.ScentStrengths[L0954_i_ScentIndex] = P659_i_CycleCount;
                }
        }
}

VOID F318_xxxx_CHAMPION_DropAllObjects(P660_i_ChampionIndex)
register int P660_i_ChampionIndex;
{
        register unsigned int L0959_ui_Cell;
        register THING L0960_T_Thing;
        register unsigned int L0961_ui_SlotIndex;


        L0959_ui_Cell = G407_s_Party.Champions[P660_i_ChampionIndex].Cell;
        for(L0961_ui_SlotIndex = C00_SLOT_READY_HAND; L0961_ui_SlotIndex < C30_SLOT_CHEST_1; L0961_ui_SlotIndex++) {
                if ((L0960_T_Thing = F300_aozz_CHAMPION_GetObjectRemovedFromSlot(P660_i_ChampionIndex, G057_ai_Graphic562_SlotDropOrder[L0961_ui_SlotIndex])) != C0xFFFF_THING_NONE) {
                        F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(M15_THING_WITH_NEW_CELL(L0960_T_Thing, L0959_ui_Cell), CM1_MAPX_NOT_ON_A_SQUARE, 0, G306_i_PartyMapX, G307_i_PartyMapY);
                }
        }
}

VOID F319_xxxx_CHAMPION_Kill(P661_ui_ChampionIndex)
register unsigned int P661_ui_ChampionIndex;
{
        register unsigned int L0962_ui_Multiple;
#define A0962_ui_Cell              L0962_ui_Multiple
#define A0962_ui_ChampionIconIndex L0962_ui_Multiple
        register int L0963_i_AliveChampionIndex;
        register THING L0964_T_Thing;
        register CHAMPION* L0965_ps_Champion;
        register JUNK* L0966_ps_Junk;


        L0965_ps_Champion = &G407_s_Party.Champions[P661_ui_ChampionIndex];
        L0965_ps_Champion->CurrentHealth = 0;
        M08_SET(L0965_ps_Champion->Attributes, MASK0x1000_STATUS_BOX);
        if (M00_INDEX_TO_ORDINAL(P661_ui_ChampionIndex) == G423_i_InventoryChampionOrdinal) {
                if (G331_B_PressingEye) {
                        G331_B_PressingEye = FALSE;
                        G597_B_IgnoreMouseMovements = FALSE;
                        if (!G415_B_LeaderEmptyHanded) {
                                F034_aaau_OBJECT_DrawLeaderHandObjectName(G414_T_LeaderHandObject);
                        }
                        G587_i_HideMousePointerRequestCount = 1;
                        F078_xzzz_MOUSE_ShowPointer();
                } else {
                        if (G333_B_PressingMouth) {
                                G333_B_PressingMouth = FALSE;
                                G597_B_IgnoreMouseMovements = FALSE;
                                G587_i_HideMousePointerRequestCount = 1;
                                F078_xzzz_MOUSE_ShowPointer();
                        }
                }
                F355_hzzz_INVENTORY_Toggle_COPYPROTECTIONE(C04_CHAMPION_CLOSE_INVENTORY);
        }
        F318_xxxx_CHAMPION_DropAllObjects(P661_ui_ChampionIndex);
        L0964_T_Thing = F166_szzz_DUNGEON_GetUnusedThing(MASK0x8000_CHAMPION_BONES | C10_THING_TYPE_JUNK);
        if (L0964_T_Thing == C0xFFFF_THING_NONE) {
        } else {
                L0966_ps_Junk = (JUNK*)F156_afzz_DUNGEON_GetThingData(L0964_T_Thing);
                L0966_ps_Junk->Type = C05_JUNK_BONES;
                L0966_ps_Junk->DoNotDiscard = TRUE;
                L0966_ps_Junk->ChargeCount = P661_ui_ChampionIndex;
                A0962_ui_Cell = L0965_ps_Champion->Cell;
                F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(M15_THING_WITH_NEW_CELL(L0964_T_Thing, A0962_ui_Cell), CM1_MAPX_NOT_ON_A_SQUARE, 0, G306_i_PartyMapX, G307_i_PartyMapY);
        }
        L0965_ps_Champion->SymbolStep = 0;
        L0965_ps_Champion->Symbols[0] = '\0';
        L0965_ps_Champion->Direction = G308_i_PartyDirection;
        L0965_ps_Champion->MaximumDamageReceived = 0;
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_07_FIX */
        if (M00_INDEX_TO_ORDINAL(M26_CHAMPION_ICON_INDEX(A0962_ui_Cell, G308_i_PartyDirection)) == G599_ui_UseChampionIconOrdinalAsMousePointerBitmap) {
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_07_FIX */
        A0962_ui_ChampionIconIndex = M26_CHAMPION_ICON_INDEX(A0962_ui_Cell, G308_i_PartyDirection);
        if (M00_INDEX_TO_ORDINAL(A0962_ui_ChampionIconIndex) == G599_ui_UseChampionIconOrdinalAsMousePointerBitmap) {
#endif
                G598_B_MousePointerBitmapUpdated = TRUE;
                G599_ui_UseChampionIconOrdinalAsMousePointerBitmap = M00_INDEX_TO_ORDINAL(CM1_CHAMPION_NONE);
                G592_B_BuildMousePointerScreenAreaRequested = TRUE;
        }
        if (L0965_ps_Champion->PoisonEventCount) {
                F323_xxxx_CHAMPION_Unpoison(P661_ui_ChampionIndex);
        }
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_07_FIX The champion icon is erased when the champion is killed and simply not drawn anymore when drawing the state of a dead champion */
        G578_B_UseByteBoxCoordinates = FALSE;
        F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G054_ai_Graphic562_Box_ChampionIcons[A0962_ui_ChampionIconIndex << 2], C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
#endif
        F292_arzz_CHAMPION_DrawState(P661_ui_ChampionIndex);
        for(L0963_i_AliveChampionIndex = C00_CHAMPION_FIRST, L0965_ps_Champion = G407_s_Party.Champions; L0963_i_AliveChampionIndex < G305_ui_PartyChampionCount; L0963_i_AliveChampionIndex++, L0965_ps_Champion++) {
                if (L0965_ps_Champion->CurrentHealth) {
                        break;
                }
        }
        if (L0963_i_AliveChampionIndex == G305_ui_PartyChampionCount) { /* BUG0_43 The game does not end if the last living champion in the party is killed while looking at a candidate champion in a portrait. The condition to end the game when the whole party is killed is not true because the code considers the candidate champion as alive (in the loop above) */
                G303_B_PartyDead = TRUE;
                return;
        }
        if (P661_ui_ChampionIndex == G411_i_LeaderIndex) {
                F368_fzzz_COMMAND_SetLeader(L0963_i_AliveChampionIndex);
        }
        if (P661_ui_ChampionIndex == G514_i_MagicCasterChampionIndex) {
                F394_ozzz_MENUS_SetMagicCasterAndDrawSpellArea(L0963_i_AliveChampionIndex);
                return;
        }
        F393_lzzz_MENUS_DrawSpellAreaControls(G514_i_MagicCasterChampionIndex);
}

VOID F320_akzz_CHAMPION_ApplyAndDrawPendingDamageAndWounds()
{
        register unsigned int L0967_ui_ChampionIndex;
        register unsigned int L0968_ui_PendingDamage;
        register int L0969_i_Multiple;
#define A0969_i_Health     L0969_i_Multiple
#define A0969_i_X          L0969_i_Multiple
#define A0969_i_EventIndex L0969_i_Multiple
        register int L0970_i_PendingWounds;
        register CHAMPION* L0971_ps_Champion;
        register EVENT* L0972_ps_Event;
        int L0973_i_Y;
        EVENT L0974_s_Event;
        BOX_WORD L0975_s_Box;


        L0971_ps_Champion = G407_s_Party.Champions;
        for(L0967_ui_ChampionIndex = C00_CHAMPION_FIRST; L0967_ui_ChampionIndex < G305_ui_PartyChampionCount; L0967_ui_ChampionIndex++, L0971_ps_Champion++) {
                M08_SET(L0971_ps_Champion->Wounds, L0970_i_PendingWounds = G410_ai_ChampionPendingWounds[L0967_ui_ChampionIndex]);
                G410_ai_ChampionPendingWounds[L0967_ui_ChampionIndex] = 0;
                if (!(L0968_ui_PendingDamage = G409_ai_ChampionPendingDamage[L0967_ui_ChampionIndex])) {
                        continue;
                }
                G409_ai_ChampionPendingDamage[L0967_ui_ChampionIndex] = 0;
                if (!(A0969_i_Health = L0971_ps_Champion->CurrentHealth)) {
                        continue;
                }
                if ((A0969_i_Health = A0969_i_Health - L0968_ui_PendingDamage) <= 0) {
                        F319_xxxx_CHAMPION_Kill(L0967_ui_ChampionIndex);
                } else {
                        L0971_ps_Champion->CurrentHealth = A0969_i_Health;
                        M08_SET(L0971_ps_Champion->Attributes, MASK0x0100_STATISTICS);
                        if (L0970_i_PendingWounds) {
                                M08_SET(L0971_ps_Champion->Attributes, MASK0x2000_WOUNDS);
                        }
                        A0969_i_X = L0967_ui_ChampionIndex * C69_CHAMPION_STATUS_BOX_SPACING;
                        L0975_s_Box.Y1 = 0;
                        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                        if (M00_INDEX_TO_ORDINAL(L0967_ui_ChampionIndex) == G423_i_InventoryChampionOrdinal) {
                                L0975_s_Box.Y2 = 28;
                                L0975_s_Box.X2 = (L0975_s_Box.X1 = A0969_i_X + 7) + 31; /* Box is over the champion portrait in the status box */
                                F021_a002_MAIN_BlitToScreen(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C016_GRAPHIC_DAMAGE_TO_CHAMPION_BIG), &L0975_s_Box, C016_BYTE_WIDTH, C10_COLOR_FLESH);
                                if (L0968_ui_PendingDamage < 10) { /* 1 digit */
                                        A0969_i_X += 21;
                                } else {
                                        if (L0968_ui_PendingDamage < 100) { /* 2 digits */
                                                A0969_i_X += 18;
                                        } else { /* 3 digits */
                                                A0969_i_X += 15;
                                        }
                                }
                                L0973_i_Y = 16;
                        } else {
                                L0975_s_Box.Y2 = 6;
                                L0975_s_Box.X2 = (L0975_s_Box.X1 = A0969_i_X) + 47; /* Box is over the champion name in the status box */
                                F021_a002_MAIN_BlitToScreen(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C015_GRAPHIC_DAMAGE_TO_CHAMPION_SMALL), &L0975_s_Box, C024_BYTE_WIDTH, C10_COLOR_FLESH);
                                if (L0968_ui_PendingDamage < 10) { /* 1 digit */
                                        A0969_i_X += 19;
                                } else {
                                        if (L0968_ui_PendingDamage < 100) { /* 2 digits */
                                                A0969_i_X += 16;
                                        } else { /* 3 digits */
                                                A0969_i_X += 13;
                                        }
                                }
                                L0973_i_Y = 5;
                        }
                        F053_aajz_TEXT_PrintToLogicalScreen(A0969_i_X, L0973_i_Y, C15_COLOR_WHITE, C08_COLOR_RED, F288_xxxx_CHAMPION_GetStringFromInteger(L0968_ui_PendingDamage, FALSE, 3));
                        if ((A0969_i_EventIndex = L0971_ps_Champion->HideDamageReceivedEventIndex) == -1) {
                                L0974_s_Event.A.A.Type = C12_EVENT_HIDE_DAMAGE_RECEIVED;
                                M33_SET_MAP_AND_TIME(L0974_s_Event.Map_Time, G309_i_PartyMapIndex, G313_ul_GameTime + 5);
                                L0974_s_Event.A.A.Priority = L0967_ui_ChampionIndex;
                                L0971_ps_Champion->HideDamageReceivedEventIndex = F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0974_s_Event);
                        } else {
                                L0972_ps_Event = &G370_ps_Events[A0969_i_EventIndex];
                                M33_SET_MAP_AND_TIME(L0972_ps_Event->Map_Time, G309_i_PartyMapIndex, G313_ul_GameTime + 5);
                                F236_pzzz_TIMELINE_FixChronology(F235_bzzz_TIMELINE_GetIndex(A0969_i_EventIndex));
                        }
                        F292_arzz_CHAMPION_DrawState(L0967_ui_ChampionIndex);
                        F078_xzzz_MOUSE_ShowPointer();
                }
        }
}

int F321_AA29_CHAMPION_AddPendingDamageAndWounds_GetDamage(P662_i_ChampionIndex, P663_i_Attack, P664_i_AllowedWounds, P665_i_AttackType)
int P662_i_ChampionIndex;
register int P663_i_Attack;
int P664_i_AllowedWounds;
int P665_i_AttackType;
{
        register int L0976_i_Multiple;
#define A0976_i_WoundIndex     L0976_i_Multiple
#define A0976_i_WisdomFactor   L0976_i_Multiple
#define A0976_i_AdjustedAttack L0976_i_Multiple
        register unsigned int L0977_ui_Defense;
        register unsigned int L0978_ui_WoundCount;
        register CHAMPION* L0979_ps_Champion;


        if ((P662_i_ChampionIndex == CM1_CHAMPION_NONE) || (M00_INDEX_TO_ORDINAL(P662_i_ChampionIndex) == G299_ui_CandidateChampionOrdinal || G302_B_GameWon)) { /* BUG0_00 Useless code. This condition is never true */
                return; /* BUG0_01 Coding error without consequence. Undefined return value. No consequence because this code is never executed */
        }
        if (P663_i_Attack <= 0) {
                return 0;
        }
        L0979_ps_Champion = &G407_s_Party.Champions[P662_i_ChampionIndex];
        if (!L0979_ps_Champion->CurrentHealth) {
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_11_OPTIMIZATION */
                T321_004:
#endif
                return 0;
        }
        if (P665_i_AttackType != C0_ATTACK_NORMAL) {
                for(L0978_ui_WoundCount = 0, A0976_i_WoundIndex = C00_SLOT_READY_HAND, L0977_ui_Defense = 0; A0976_i_WoundIndex <= C05_SLOT_FEET; A0976_i_WoundIndex++) {
                        if (P664_i_AllowedWounds & (1 << A0976_i_WoundIndex)) {
                                L0978_ui_WoundCount++;
                                L0977_ui_Defense += F313_xxxx_CHAMPION_GetWoundDefense(P662_i_ChampionIndex, A0976_i_WoundIndex | ((P665_i_AttackType == C4_ATTACK_SHARP) ? MASK0x8000_USE_SHARP_DEFENSE : MASK0x0000_DO_NOT_USE_SHARP_DEFENSE));
                        }
                }
                if (L0978_ui_WoundCount) {
                        L0977_ui_Defense /= L0978_ui_WoundCount;
                }
                switch (P665_i_AttackType) {
                        case C6_ATTACK_PSYCHIC:
                                if ((A0976_i_WisdomFactor = 115 - L0979_ps_Champion->Statistics[C3_STATISTIC_WISDOM][C1_CURRENT]) <= 0) {
                                        P663_i_Attack = 0;
                                } else {
                                        P663_i_Attack = F030_aaaW_MAIN_GetScaledProduct(P663_i_Attack, 6, A0976_i_WisdomFactor);
                                }
                                goto T321_024;
                        case C5_ATTACK_MAGIC:
                                P663_i_Attack = F307_fzzz_CHAMPION_GetStatisticAdjustedAttack(L0979_ps_Champion, C5_STATISTIC_ANTIMAGIC, P663_i_Attack);
                                P663_i_Attack -= G407_s_Party.SpellShieldDefense;
                                goto T321_024;
                        case C1_ATTACK_FIRE:
                                P663_i_Attack = F307_fzzz_CHAMPION_GetStatisticAdjustedAttack(L0979_ps_Champion, C6_STATISTIC_ANTIFIRE, P663_i_Attack);
                                P663_i_Attack -= G407_s_Party.FireShieldDefense;
                                break;
                        case C2_ATTACK_SELF:
                                L0977_ui_Defense >>= 1;
                        case C3_ATTACK_BLUNT:
                        case C4_ATTACK_SHARP:
                        case C7_ATTACK_LIGHTNING:
                }
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_12_FIX The champion damage is 0 if the party fire shield value is higher than the fire attack value */
                if (P663_i_Attack <= 0) {
                        goto T321_004;
                }
#endif
                P663_i_Attack = F030_aaaW_MAIN_GetScaledProduct(P663_i_Attack, 6, 130 - L0977_ui_Defense); /* BUG0_44 A champion may take much more damage than expected after a Black Flame attack or an impact with a Fireball projectile. If the party has a fire shield defense value higher than the fire attack value then the resulting intermediary attack value is negative and damage should be 0. However, the negative value is still used for further computations and the result may be a very high positive attack value which may kill a champion. This can occur only for ATTACK_FIRE and if P663_i_Attack is negative before calling F030_aaaW_MAIN_GetScaledProduct */
                T321_024:
                if (P663_i_Attack <= 0) {
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_11_OPTIMIZATION */
                        return 0;
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_11_OPTIMIZATION Code deduplication */
                        goto T321_004;
#endif
                }
                if (P663_i_Attack > (A0976_i_AdjustedAttack = F307_fzzz_CHAMPION_GetStatisticAdjustedAttack(L0979_ps_Champion, C4_STATISTIC_VITALITY, M03_RANDOM(128) + 10))) { /* BUG0_45 This bug is not perceptible because of BUG0_41 that ignores Vitality while determining the probability of being wounded. However if it was fixed, the behavior would be the opposite of what it should: the higher the vitality of a champion, the lower the result of F307_fzzz_CHAMPION_GetStatisticAdjustedAttack and the more likely the champion could get wounded (because of more iterations in the loop below) */
                        do {
                                M08_SET(G410_ai_ChampionPendingWounds[P662_i_ChampionIndex], (1 << M03_RANDOM(8)) & P664_i_AllowedWounds);
                        } while ((P663_i_Attack > (A0976_i_AdjustedAttack <<= 1)) && A0976_i_AdjustedAttack);
                }
                if (G300_B_PartyIsSleeping) {
                        F314_gzzz_CHAMPION_WakeUp();
                }
        }
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_12_FIX This condition cannot be true, if P663_i_Attack was negative then the function would have already returned in a previous check */
        if (P663_i_Attack <= 0) { /* BUG0_00 Useless code */
                P663_i_Attack = 0;
        }
#endif
        G409_ai_ChampionPendingDamage[P662_i_ChampionIndex] += P663_i_Attack;
        return P663_i_Attack;
}

VOID F322_lzzz_CHAMPION_Poison(P666_i_ChampionIndex, P667_ui_Attack)
int P666_i_ChampionIndex;
unsigned int P667_ui_Attack;
{
        EVENT L0980_s_Event;
        CHAMPION* L0981_ps_Champion;


        if ((P666_i_ChampionIndex == CM1_CHAMPION_NONE) || (M00_INDEX_TO_ORDINAL(P666_i_ChampionIndex) == G299_ui_CandidateChampionOrdinal)) {
                return;
        }
        L0981_ps_Champion = &G407_s_Party.Champions[P666_i_ChampionIndex];
        F321_AA29_CHAMPION_AddPendingDamageAndWounds_GetDamage(P666_i_ChampionIndex, F025_aatz_MAIN_GetMaximumValue(1, P667_ui_Attack >> 6), MASK0x0000_NO_WOUND, C0_ATTACK_NORMAL);
        M08_SET(L0981_ps_Champion->Attributes, MASK0x0100_STATISTICS);
        if ((M00_INDEX_TO_ORDINAL(P666_i_ChampionIndex) == G423_i_InventoryChampionOrdinal) && (G424_i_PanelContent == C0_PANEL_FOOD_WATER_POISONED)) {
                M08_SET(L0981_ps_Champion->Attributes, MASK0x0800_PANEL);
        }
        if (--P667_ui_Attack) {
                L0981_ps_Champion->PoisonEventCount++;
                L0980_s_Event.A.A.Type = C75_EVENT_POISON_CHAMPION;
                L0980_s_Event.A.A.Priority = P666_i_ChampionIndex;
                M33_SET_MAP_AND_TIME(L0980_s_Event.Map_Time, G309_i_PartyMapIndex, G313_ul_GameTime + 36);
                L0980_s_Event.B.Attack = P667_ui_Attack;
                F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L0980_s_Event);
        }
        F292_arzz_CHAMPION_DrawState(P666_i_ChampionIndex);
}

VOID F323_xxxx_CHAMPION_Unpoison(P668_i_ChampionIndex)
int P668_i_ChampionIndex;
{
        register int L0982_i_EventIndex;
        register EVENT* L0983_ps_Event;


        if (P668_i_ChampionIndex == CM1_CHAMPION_NONE) {
                return;
        }
        for(L0982_i_EventIndex = 0, L0983_ps_Event = G370_ps_Events; L0982_i_EventIndex < G369_ui_EventMaximumCount; L0983_ps_Event++, L0982_i_EventIndex++) {
                if ((L0983_ps_Event->A.A.Type == C75_EVENT_POISON_CHAMPION) && (L0983_ps_Event->A.A.Priority == P668_i_ChampionIndex)) {
                        F237_rzzz_TIMELINE_DeleteEvent(L0982_i_EventIndex);
                }
        }
        G407_s_Party.Champions[P668_i_ChampionIndex].PoisonEventCount = 0;
}

int F324_aezz_CHAMPION_DamageAll_GetDamagedChampionCount(P669_ui_Attack, P670_i_Wounds, P671_i_AttackType)
register unsigned int P669_ui_Attack;
int P670_i_Wounds;
int P671_i_AttackType;
{
        register int L0984_i_ChampionIndex;
        register int L0985_i_RandomAttack;
        register int L0986_i_DamagedChampionCount;
        register char* L0987_pc_Unreferenced; /* BUG0_00 Useless code */


        if (!P669_ui_Attack) {
                return; /* BUG0_01 Coding error without consequence. Undefined return value. No consequence because this code is never executed */
        }
        P669_ui_Attack -= (L0985_i_RandomAttack = (P669_ui_Attack >> 3) + 1);
        L0985_i_RandomAttack <<= 1;
        for(L0986_i_DamagedChampionCount = 0, L0984_i_ChampionIndex = C00_CHAMPION_FIRST; L0984_i_ChampionIndex < G305_ui_PartyChampionCount; L0984_i_ChampionIndex++) {
                if (F321_AA29_CHAMPION_AddPendingDamageAndWounds_GetDamage(L0984_i_ChampionIndex, F025_aatz_MAIN_GetMaximumValue(1, P669_ui_Attack + M02_RANDOM(L0985_i_RandomAttack)), P670_i_Wounds, P671_i_AttackType)) { /* Actual attack is P669_ui_Attack +/- (P669_ui_Attack / 8) */
                        L0986_i_DamagedChampionCount++;
                }
        }
        return L0986_i_DamagedChampionCount;
}

VOID F325_bzzz_CHAMPION_DecrementStamina(P672_i_ChampionIndex, P673_i_Decrement)
int P672_i_ChampionIndex;
int P673_i_Decrement;
{
        register int L0988_i_Stamina;
        register CHAMPION* L0989_ps_Champion;


        if (P672_i_ChampionIndex == CM1_CHAMPION_NONE) {
                return;
        }
        L0989_ps_Champion = &G407_s_Party.Champions[P672_i_ChampionIndex];
        if ((L0988_i_Stamina = (L0989_ps_Champion->CurrentStamina -= P673_i_Decrement)) <= 0) {
                L0989_ps_Champion->CurrentStamina = 0;
                F321_AA29_CHAMPION_AddPendingDamageAndWounds_GetDamage(P672_i_ChampionIndex, (-L0988_i_Stamina) >> 1, MASK0x0000_NO_WOUND, C0_ATTACK_NORMAL);
        } else {
                if (L0988_i_Stamina > L0989_ps_Champion->MaximumStamina) {
                        L0989_ps_Champion->CurrentStamina = L0989_ps_Champion->MaximumStamina;
                }
        }
        M08_SET(L0989_ps_Champion->Attributes, MASK0x0200_LOAD | MASK0x0100_STATISTICS);
}

VOID F326_ozzz_CHAMPION_ShootProjectile(P674_ps_Champion, P675_T_Thing, P676_i_KineticEnergy, P677_i_Attack, P678_i_StepEnergy)
register CHAMPION* P674_ps_Champion;
THING P675_T_Thing;
int P676_i_KineticEnergy;
int P677_i_Attack;
int P678_i_StepEnergy;
{
        register unsigned int L0990_ui_Direction;


        L0990_ui_Direction = P674_ps_Champion->Direction;
        F212_mzzz_PROJECTILE_Create(P675_T_Thing, G306_i_PartyMapX, G307_i_PartyMapY, M21_NORMALIZE((((P674_ps_Champion->Cell - L0990_ui_Direction + 1) & 0x0002) >> 1) + L0990_ui_Direction), L0990_ui_Direction, P676_i_KineticEnergy, P677_i_Attack, P678_i_StepEnergy);
        /* BUG0_46 You can run into a projectile shot by a champion. When a champion throws an object, movement is disabled for a short time in the direction in which the object was thrown to prevent the party from running into the projectile. However, when a champion shoots an object or casts a spell, movement is not disabled and the party can run into the projectile. This applies to the actions 'Shoot' (Bow/Claw Bow, Crossbow, Speedbow, Sling), 'Lightning' (Stormring, Bolt Blade/Storm , The Conduit/Serpent Staff), 'Dispell' (Yew Staff, Staff Of Manar/Staff Of Irra), 'Fireball' (Flamitt, Fury/Ra Blade), 'Spit' (none), 'Invoke' (The Firestaff) and to all projectile spells (Fireball, Lightning Bolt, Harm Non Material, Open Door, Poison Bolt, Poison Cloud) */
#ifdef C28_COMPILE_CSB21EN /* CHANGE8_07_FIX Movement is disabled for a short time after shooting projectiles */
        G311_i_ProjectileDisabledMovementTicks = 4;
        G312_i_LastProjectileDisabledMovementDirection = L0990_ui_Direction;
#endif
}

BOOLEAN F327_kzzz_CHAMPION_IsProjectileSpellCast(P679_i_ChampionIndex, P680_T_Thing, P681_i_KineticEnergy, P682_ui_RequiredManaAmount)
int P679_i_ChampionIndex;
THING P680_T_Thing;
register int P681_i_KineticEnergy;
unsigned int P682_ui_RequiredManaAmount;
{
        register int L0991_i_StepEnergy;
        register CHAMPION* L0992_ps_Champion;


        L0992_ps_Champion = &G407_s_Party.Champions[P679_i_ChampionIndex];
        if (L0992_ps_Champion->CurrentMana < P682_ui_RequiredManaAmount) {
                return FALSE;
        }
        L0992_ps_Champion->CurrentMana -= P682_ui_RequiredManaAmount;
        M08_SET(L0992_ps_Champion->Attributes, MASK0x0100_STATISTICS);
        L0991_i_StepEnergy = 10 - F024_aatz_MAIN_GetMinimumValue(8, L0992_ps_Champion->MaximumMana >> 3);
        if (P681_i_KineticEnergy < (L0991_i_StepEnergy << 2)) {
                P681_i_KineticEnergy += 3;
                L0991_i_StepEnergy--;
        }
        F326_ozzz_CHAMPION_ShootProjectile(L0992_ps_Champion, P680_T_Thing, P681_i_KineticEnergy, 90, L0991_i_StepEnergy);
        /* BUG0_01 Coding error without consequence. Undefined return value. A 'return TRUE;' statement is missing. No consequence because the actual value returned cannot be 0: it is the value of register D0 at the end of execution of F326_ozzz_CHAMPION_ShootProjectile, which is the return value of F212_mzzz_PROJECTILE_Create, which in turn is the return value of F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE, which is the index of the event added for the projectile. This index cannot be 0 because event 0 is always event 53 */
}

BOOLEAN F328_nzzz_CHAMPION_IsObjectThrown(P683_i_ChampionIndex, P684_i_SlotIndex, P685_i_Side)
int P683_i_ChampionIndex;
int P684_i_SlotIndex;
int P685_i_Side;
{
        register int L0993_i_KineticEnergy;
        register int L0994_i_Multiple;
#define A0994_i_Experience L0994_i_Multiple
#define A0994_i_Attack     L0994_i_Multiple
        register int L0995_i_Multiple;
#define A0995_i_WeaponKineticEnergy L0995_i_Multiple
#define A0995_i_SkillLevel          L0995_i_Multiple
#define A0995_i_StepEnergy          L0995_i_Multiple
        register THING L0996_T_Thing;
        register CHAMPION* L0997_ps_Champion;
        register WEAPON_INFO* L0998_ps_WeaponInfo;
        THING L0999_T_ActionHandThing;
        BOOLEAN L1000_B_ThrowingLeaderHandObject;


        L1000_B_ThrowingLeaderHandObject = FALSE;
        if (P684_i_SlotIndex < 0) { /* Throw object in leader hand, which is temporarily placed in action hand */
                if (G415_B_LeaderEmptyHanded) {
                        return FALSE;
                }
                L0996_T_Thing = F298_aqzz_CHAMPION_GetObjectRemovedFromLeaderHand();
                L0997_ps_Champion = &G407_s_Party.Champions[P683_i_ChampionIndex];
                L0999_T_ActionHandThing = L0997_ps_Champion->Slots[C01_SLOT_ACTION_HAND];
                L0997_ps_Champion->Slots[C01_SLOT_ACTION_HAND] = L0996_T_Thing;
                P684_i_SlotIndex = C01_SLOT_ACTION_HAND;
                L1000_B_ThrowingLeaderHandObject = TRUE;
        }
        L0993_i_KineticEnergy = F312_xzzz_CHAMPION_GetStrength(P683_i_ChampionIndex, P684_i_SlotIndex);
        if (L1000_B_ThrowingLeaderHandObject) {
                L0997_ps_Champion->Slots[P684_i_SlotIndex] = L0999_T_ActionHandThing;
        } else {
                if ((L0996_T_Thing = F300_aozz_CHAMPION_GetObjectRemovedFromSlot(P683_i_ChampionIndex, P684_i_SlotIndex)) == C0xFFFF_THING_NONE) {
                        return FALSE;
                }
        }
        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C16_SOUND_COMBAT, G306_i_PartyMapX, G307_i_PartyMapY, C01_MODE_PLAY_IF_PRIORITIZED);
        F325_bzzz_CHAMPION_DecrementStamina(P683_i_ChampionIndex, F305_xxxx_CHAMPION_GetThrowingStaminaCost(L0996_T_Thing));
        F330_szzz_CHAMPION_DisableAction(P683_i_ChampionIndex, 4);
        A0994_i_Experience = 8;
        A0995_i_WeaponKineticEnergy = 1;
        if (M12_TYPE(L0996_T_Thing) == C05_THING_TYPE_WEAPON) {
                A0994_i_Experience += 4;
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L0998_ps_WeaponInfo = &G238_as_Graphic559_WeaponInfo[((WEAPON*)G284_apuc_ThingData[C05_THING_TYPE_WEAPON])[M13_INDEX(L0996_T_Thing)].Type];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L0998_ps_WeaponInfo = F158_ayzz_DUNGEON_GetWeaponInfo(L0996_T_Thing);
#endif
                if (L0998_ps_WeaponInfo->Class <= C012_CLASS_POISON_DART) {
                        A0994_i_Experience += (A0995_i_WeaponKineticEnergy = L0998_ps_WeaponInfo->KineticEnergy) >> 2;
                }
        }
        F304_apzz_CHAMPION_AddSkillExperience(P683_i_ChampionIndex, C10_SKILL_THROW, A0994_i_Experience);
        L0993_i_KineticEnergy += A0995_i_WeaponKineticEnergy;
        A0995_i_SkillLevel = F303_AA09_CHAMPION_GetSkillLevel(P683_i_ChampionIndex, C10_SKILL_THROW);
        L0993_i_KineticEnergy += M03_RANDOM(16) + (L0993_i_KineticEnergy >> 1) + A0995_i_SkillLevel;
        A0994_i_Attack = F026_a003_MAIN_GetBoundedValue(40, (A0995_i_SkillLevel << 3) + M03_RANDOM(32), 200);
        A0995_i_StepEnergy = F025_aatz_MAIN_GetMaximumValue(5, 11 - A0995_i_SkillLevel);
        F212_mzzz_PROJECTILE_Create(L0996_T_Thing, G306_i_PartyMapX, G307_i_PartyMapY, M21_NORMALIZE(G308_i_PartyDirection + P685_i_Side), G308_i_PartyDirection, L0993_i_KineticEnergy, A0994_i_Attack, A0995_i_StepEnergy);
        G311_i_ProjectileDisabledMovementTicks = 4;
        G312_i_LastProjectileDisabledMovementDirection = G308_i_PartyDirection;
        F292_arzz_CHAMPION_DrawState(P683_i_ChampionIndex);
        return TRUE;
}

BOOLEAN F329_hzzz_CHAMPION_IsLeaderHandObjectThrown(P686_i_Side)
int P686_i_Side;
{
        if (G411_i_LeaderIndex == CM1_CHAMPION_NONE) {
                return FALSE;
        }
        return F328_nzzz_CHAMPION_IsObjectThrown(G411_i_LeaderIndex, CM1_SLOT_LEADER_HAND, P686_i_Side);
}

VOID F330_szzz_CHAMPION_DisableAction(P687_i_ChampionIndex, P688_ui_Ticks)
int P687_i_ChampionIndex;
unsigned int P688_ui_Ticks;
{
        register long L1001_l_UpdatedEnableActionEventTime;
        register long L1002_l_CurrentEnableActionEventTime;
        register int L1003_i_EventIndex;
        register CHAMPION* L1004_ps_Champion;
        EVENT L1005_s_Event;


        L1004_ps_Champion = &G407_s_Party.Champions[P687_i_ChampionIndex];
        L1001_l_UpdatedEnableActionEventTime = G313_ul_GameTime + P688_ui_Ticks;
        L1005_s_Event.A.A.Type = C11_EVENT_ENABLE_CHAMPION_ACTION;
        L1005_s_Event.A.A.Priority = P687_i_ChampionIndex;
        L1005_s_Event.B.SlotOrdinal = 0;
        if ((L1003_i_EventIndex = L1004_ps_Champion->EnableActionEventIndex) >= 0) {
                L1002_l_CurrentEnableActionEventTime = M30_TIME(G370_ps_Events[L1003_i_EventIndex].Map_Time);
                if (L1001_l_UpdatedEnableActionEventTime >= L1002_l_CurrentEnableActionEventTime) {
                        L1001_l_UpdatedEnableActionEventTime += (L1002_l_CurrentEnableActionEventTime - G313_ul_GameTime) >> 1;
                } else {
                        L1001_l_UpdatedEnableActionEventTime = L1002_l_CurrentEnableActionEventTime + (P688_ui_Ticks >> 1);
                }
                F237_rzzz_TIMELINE_DeleteEvent(L1003_i_EventIndex);
        } else {
                M08_SET(L1004_ps_Champion->Attributes, MASK0x8000_ACTION_HAND | MASK0x0008_DISABLE_ACTION);
                F292_arzz_CHAMPION_DrawState(P687_i_ChampionIndex);
        }
        M33_SET_MAP_AND_TIME(L1005_s_Event.Map_Time, G309_i_PartyMapIndex, L1001_l_UpdatedEnableActionEventTime);
        L1004_ps_Champion->EnableActionEventIndex = F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L1005_s_Event);
}

VOID F331_auzz_CHAMPION_ApplyTimeEffects_COPYPROTECTIONF()
{
        register unsigned int L1006_ui_Multiple;
#define A1006_ui_GameTime      L1006_ui_Multiple
#define A1006_ui_ChampionIndex L1006_ui_Multiple
        register unsigned int L1007_ui_Multiple;
#define A1007_ui_ScentIndex            L1007_ui_Multiple
#define A1007_ui_ManaGain              L1007_ui_Multiple
#define A1007_ui_StaminaGainCycleCount L1007_ui_Multiple
#define A1007_ui_StatisticIndex        L1007_ui_Multiple
        register unsigned int L1008_ui_Multiple;
#define A1008_ui_WizardSkillLevel L1008_ui_Multiple
#define A1008_ui_Delay            L1008_ui_Multiple
#define A1008_ui_StaminaAboveHalf L1008_ui_Multiple
#define A1008_ui_StatisticMaximum L1008_ui_Multiple
        register int L1009_i_Multiple;
#define A1009_i_SkillIndex       L1009_i_Multiple
#define A1009_i_StaminaMagnitude L1009_i_Multiple
#define A1009_i_StaminaLoss      L1009_i_Multiple
        register CHAMPION* L1010_ps_Champion;
        register unsigned char* L1011_puc_Statistic;
        unsigned int L1012_ui_TimeCriteria;
        int L1013_i_Multiple;
#define A1013_i_StaminaAmount L1013_i_Multiple
#define A1013_i_HealthGain    L1013_i_Multiple
        SCENT L1014_s_Scent;


        if (!G305_ui_PartyChampionCount) {
                return;
        }
        L1014_s_Scent.Location.MapX = G306_i_PartyMapX;
        L1014_s_Scent.Location.MapY = G307_i_PartyMapY;
        L1014_s_Scent.Location.MapIndex = G309_i_PartyMapIndex;
        A1007_ui_ScentIndex = 0;
        while ((int)A1007_ui_ScentIndex < G407_s_Party.ScentCount - 1) {
                G407_s_Party.Scents[A1007_ui_ScentIndex] == L1014_s_Scent; /* BUG0_00 Useless code. The result of the comparison is ignored */
                if (!(G407_s_Party.ScentStrengths[A1007_ui_ScentIndex] = F025_aatz_MAIN_GetMaximumValue(0, G407_s_Party.ScentStrengths[A1007_ui_ScentIndex] - 1)) && !A1007_ui_ScentIndex) {
                        F316_aizz_CHAMPION_DeleteScent(0);
                        continue;
                }
                A1007_ui_ScentIndex++;
        }
        A1006_ui_GameTime = G313_ul_GameTime;
        L1012_ui_TimeCriteria = (((A1006_ui_GameTime & 0x0080) + ((A1006_ui_GameTime & 0x0100) >> 2)) + ((A1006_ui_GameTime & 0x0040) << 2)) >> 2;
        for(A1006_ui_ChampionIndex = C00_CHAMPION_FIRST, L1010_ps_Champion = G407_s_Party.Champions; A1006_ui_ChampionIndex < G305_ui_PartyChampionCount; A1006_ui_ChampionIndex++, L1010_ps_Champion++) {
                if (L1010_ps_Champion->CurrentHealth && (M00_INDEX_TO_ORDINAL(A1006_ui_ChampionIndex) != G299_ui_CandidateChampionOrdinal)) {
                        if ((L1010_ps_Champion->CurrentMana < L1010_ps_Champion->MaximumMana) && (L1012_ui_TimeCriteria < (L1010_ps_Champion->Statistics[C3_STATISTIC_WISDOM][C1_CURRENT] + (A1008_ui_WizardSkillLevel = F303_AA09_CHAMPION_GetSkillLevel(A1006_ui_ChampionIndex, C03_SKILL_WIZARD) + F303_AA09_CHAMPION_GetSkillLevel(A1006_ui_ChampionIndex, C02_SKILL_PRIEST))))) {
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_00_IMPROVEMENT Faster regeneration. Mana gain is ((MaximumMana / 64) + 1) and Stamina cost is Max(7, 16 - WizardLevel) */
                                F325_bzzz_CHAMPION_DecrementStamina(A1006_ui_ChampionIndex, F025_aatz_MAIN_GetMaximumValue(7, 16 - A1008_ui_WizardSkillLevel));
                                L1010_ps_Champion->CurrentMana += (L1010_ps_Champion->MaximumMana >> 6) + 1;
                                if (L1010_ps_Champion->CurrentMana > L1010_ps_Champion->MaximumMana) {
                                        L1010_ps_Champion->CurrentMana = L1010_ps_Champion->MaximumMana;
                                }
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_00_IMPROVEMENT Faster regeneration. Mana gain is ((MaximumMana / 40) + 1) if not sleeping and (((MaximumMana / 40) * 2) + 1) if sleeping. Stamina cost is ManaGain * Max(7, 16 - WizardLevel). Higher mana gain for higher stamina cost */
                                A1007_ui_ManaGain = L1010_ps_Champion->MaximumMana / 40;
                                if (G300_B_PartyIsSleeping) {
                                        A1007_ui_ManaGain = A1007_ui_ManaGain << 1;
                                }
                                A1007_ui_ManaGain++;
                                F325_bzzz_CHAMPION_DecrementStamina(A1006_ui_ChampionIndex, A1007_ui_ManaGain * F025_aatz_MAIN_GetMaximumValue(7, 16 - A1008_ui_WizardSkillLevel));
                                L1010_ps_Champion->CurrentMana += F024_aatz_MAIN_GetMinimumValue(A1007_ui_ManaGain, L1010_ps_Champion->MaximumMana - L1010_ps_Champion->CurrentMana);
#endif
                        } else {
                                if (L1010_ps_Champion->CurrentMana > L1010_ps_Champion->MaximumMana) {
                                        L1010_ps_Champion->CurrentMana--;
                                }
                        }
                        for(A1009_i_SkillIndex = C19_SKILL_WATER; A1009_i_SkillIndex >= C00_SKILL_FIGHTER; A1009_i_SkillIndex--) {
                                if (L1010_ps_Champion->Skills[A1009_i_SkillIndex].TemporaryExperience > 0) {
                                        L1010_ps_Champion->Skills[A1009_i_SkillIndex].TemporaryExperience--;
                                }
                        }
                        A1007_ui_StaminaGainCycleCount = 4;
                        A1009_i_StaminaMagnitude = L1010_ps_Champion->MaximumStamina;
                        while (L1010_ps_Champion->CurrentStamina < (A1009_i_StaminaMagnitude >>= 1)) {
                                A1007_ui_StaminaGainCycleCount += 2;
                        }
                        A1009_i_StaminaLoss = 0;
                        A1013_i_StaminaAmount = F026_a003_MAIN_GetBoundedValue(1, (L1010_ps_Champion->MaximumStamina >> 8) - 1, 6);
                        if (G300_B_PartyIsSleeping) {
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_00_IMPROVEMENT Faster regeneration */
                                A1013_i_StaminaAmount += F025_aatz_MAIN_GetMaximumValue(1, A1013_i_StaminaAmount >> 1);
                        }
                        if ((A1008_ui_Delay = (G313_ul_GameTime - G362_l_LastPartyMovementTime)) > 100) {
                                A1013_i_StaminaAmount++;
                                if (A1008_ui_Delay > 500) {
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_00_IMPROVEMENT Faster regeneration */
                                A1013_i_StaminaAmount <<= 1;
                        }
                        if ((A1008_ui_Delay = (G313_ul_GameTime - G362_l_LastPartyMovementTime)) > 80) {
                                A1013_i_StaminaAmount++;
                                if (A1008_ui_Delay > 250) {
#endif
                                        A1013_i_StaminaAmount++;
                                }
                        }
                        do {
                                A1008_ui_StaminaAboveHalf = (A1007_ui_StaminaGainCycleCount <= 4);
                                if (L1010_ps_Champion->Food < -512) {
                                        if (A1008_ui_StaminaAboveHalf) {
                                               A1009_i_StaminaLoss += A1013_i_StaminaAmount;
                                               L1010_ps_Champion->Food -= 2;
                                        }
                                } else {
                                        if (L1010_ps_Champion->Food >= 0) {
                                                A1009_i_StaminaLoss -= A1013_i_StaminaAmount;
                                        }
                                        L1010_ps_Champion->Food -= A1008_ui_StaminaAboveHalf ? 2 : A1007_ui_StaminaGainCycleCount >> 1;
                                }
                                if (L1010_ps_Champion->Water < -512) {
                                        if (A1008_ui_StaminaAboveHalf) {
                                               A1009_i_StaminaLoss += A1013_i_StaminaAmount;
                                               L1010_ps_Champion->Water -= 1;
                                        }
                                } else {
                                        if (L1010_ps_Champion->Water >= 0) {
                                                A1009_i_StaminaLoss -= A1013_i_StaminaAmount;
                                        }
                                        L1010_ps_Champion->Water -= A1008_ui_StaminaAboveHalf ? 1 : A1007_ui_StaminaGainCycleCount >> 2;
                                }
                                A1007_ui_StaminaGainCycleCount--;
                        } while (A1007_ui_StaminaGainCycleCount && ((L1010_ps_Champion->CurrentStamina - A1009_i_StaminaLoss) < L1010_ps_Champion->MaximumStamina));
                        F325_bzzz_CHAMPION_DecrementStamina(A1006_ui_ChampionIndex, A1009_i_StaminaLoss);
                        if (L1010_ps_Champion->Food < -1024) {
                                L1010_ps_Champion->Food = -1024;
                        }
                        if (L1010_ps_Champion->Water < -1024) {
                                L1010_ps_Champion->Water = -1024;
                        }
                        if ((L1010_ps_Champion->CurrentHealth < L1010_ps_Champion->MaximumHealth) && (L1010_ps_Champion->CurrentStamina >= (L1010_ps_Champion->MaximumStamina >> 2)) && (L1012_ui_TimeCriteria < (L1010_ps_Champion->Statistics[C4_STATISTIC_VITALITY][C1_CURRENT] + 12))) {
                                A1013_i_HealthGain = (L1010_ps_Champion->MaximumHealth >> 7) + 1;
                                if (G300_B_PartyIsSleeping) {
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_00_IMPROVEMENT Faster regeneration */
                                        A1013_i_HealthGain += F025_aatz_MAIN_GetMaximumValue(1, A1013_i_HealthGain >> 1);
                                }
                                if (F033_aaaz_OBJECT_GetIconIndex(L1010_ps_Champion->Slots[C10_SLOT_NECK]) == C121_ICON_JUNK_EKKHARD_CROSS) {
                                        A1013_i_HealthGain += 1;
                                }
                                if ((L1010_ps_Champion->CurrentHealth += A1013_i_HealthGain) > L1010_ps_Champion->MaximumHealth) {
                                        L1010_ps_Champion->CurrentHealth = L1010_ps_Champion->MaximumHealth;
                                }
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_00_IMPROVEMENT Faster regeneration */
                                        A1013_i_HealthGain <<= 1;
                                }
                                if (F033_aaaz_OBJECT_GetIconIndex(L1010_ps_Champion->Slots[C10_SLOT_NECK]) == C121_ICON_JUNK_EKKHARD_CROSS) {
                                        A1013_i_HealthGain += (A1013_i_HealthGain >> 1) + 1;
                                }
                                L1010_ps_Champion->CurrentHealth += F024_aatz_MAIN_GetMinimumValue(A1013_i_HealthGain, L1010_ps_Champion->MaximumHealth - L1010_ps_Champion->CurrentHealth);
#endif
                        }
#ifndef NOCOPYPROTECTION
                        if (G328_i_TimeBombToKillParty_COPYPROTECTIONF && !(--G328_i_TimeBombToKillParty_COPYPROTECTIONF)) {
                                G524_B_RestartGameAllowed = FALSE;
                                F324_aezz_CHAMPION_DamageAll_GetDamagedChampionCount(4096, MASK0x0000_NO_WOUND, C0_ATTACK_NORMAL);
                        }
#endif
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_00_IMPROVEMENT Faster regeneration */
                        if (!((int)G313_ul_GameTime & 255)) {
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_00_IMPROVEMENT Faster regeneration */
                        if (!((int)G313_ul_GameTime & (G300_B_PartyIsSleeping ? 63 : 255))) {
#endif
                                A1007_ui_StatisticIndex = C0_STATISTIC_LUCK;
                                while (A1007_ui_StatisticIndex <= C6_STATISTIC_ANTIFIRE) {
                                        L1011_puc_Statistic = L1010_ps_Champion->Statistics[A1007_ui_StatisticIndex];
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_00_IMPROVEMENT Faster regeneration */
                                        if (L1011_puc_Statistic[C1_CURRENT] < L1011_puc_Statistic[C0_MAXIMUM]) {
                                                L1011_puc_Statistic[C1_CURRENT]++;
                                        } else {
                                                if (L1011_puc_Statistic[C1_CURRENT] > L1011_puc_Statistic[C0_MAXIMUM]) {
                                                        L1011_puc_Statistic[C1_CURRENT]--;
                                                }
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_00_IMPROVEMENT Faster regeneration. If the current statistic is higher than the maximum, it is decreased by current/maximum instead of by 1 */
                                        A1008_ui_StatisticMaximum = L1011_puc_Statistic[C0_MAXIMUM];
                                        if (L1011_puc_Statistic[C1_CURRENT] < A1008_ui_StatisticMaximum) {
                                                L1011_puc_Statistic[C1_CURRENT]++;
                                        } else {
                                                if (L1011_puc_Statistic[C1_CURRENT] > A1008_ui_StatisticMaximum) {
                                                        L1011_puc_Statistic[C1_CURRENT] -= L1011_puc_Statistic[C1_CURRENT] / A1008_ui_StatisticMaximum;
                                                }
#endif
                                        }
                                        A1007_ui_StatisticIndex++;
                                }
                        }
                        if (!G300_B_PartyIsSleeping && (L1010_ps_Champion->Direction != G308_i_PartyDirection) && (G361_l_LastCreatureAttackTime < (G313_ul_GameTime - 60))) {
                                L1010_ps_Champion->Direction = G308_i_PartyDirection;
                                L1010_ps_Champion->MaximumDamageReceived = 0;
                                M08_SET(L1010_ps_Champion->Attributes, MASK0x0400_ICON);
                        }
                        M08_SET(L1010_ps_Champion->Attributes, MASK0x0100_STATISTICS);
                        if (M00_INDEX_TO_ORDINAL(A1006_ui_ChampionIndex) == G423_i_InventoryChampionOrdinal) {
                                if (G333_B_PressingMouth || G331_B_PressingEye || (G424_i_PanelContent == C0_PANEL_FOOD_WATER_POISONED)) {
                                        M08_SET(L1010_ps_Champion->Attributes, MASK0x0800_PANEL);
                                }
                        }
                }
        }
        F293_ahzz_CHAMPION_DrawAllChampionStates();
}
