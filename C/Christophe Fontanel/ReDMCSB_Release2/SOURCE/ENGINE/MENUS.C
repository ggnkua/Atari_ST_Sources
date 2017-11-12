#include "DEFS.H"

/*_Global variables_*/
unsigned char G485_aauc_Graphic560_SymbolBaseManaCost[4][6];
unsigned char G486_auc_Graphic560_SymbolManaCostMultiplier[6];
SPELL G487_as_Graphic560_Spells[25];
int G488_i_Graphic560_RequestCheckFuzzyBitCount_COPYPROTECTIONE; /* This variable is necessary even if NOCOPYPROTECTION is defined because a value is loaded for it from graphic #560 */
ACTION_SET G489_as_Graphic560_ActionSets[44];
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
char G490_ac_Graphic560_ActionNames[300];
#endif
#ifdef C22_COMPILE_DM12GE_DM13aFR_DM13bFR /* CHANGE4_00_LOCALIZATION Translation to German language */
char G490_ac_Graphic560_ActionNames[400];
#endif
unsigned char G491_auc_Graphic560_ActionDisabledTicks[44];
unsigned char G492_auc_Graphic560_ActionDamageFactor[44];
unsigned char G493_auc_Graphic560_ActionHitProbability[44];
unsigned char G494_auc_Graphic560_ActionStamina[44];
char G495_ac_Graphic560_ActionDefense[44];
unsigned char G496_auc_Graphic560_ActionSkillIndex[44];
unsigned char G497_auc_Graphic560_ActionExperienceGain[44];
unsigned char G498_auc_Graphic560_PaletteChanges_ActionAreaObjectIcon[16];
BOX_WORD G499_s_Graphic560_Box_ActionArea3ActionsMenu;
BOX_WORD G500_s_Graphic560_Box_ActionArea2ActionsMenu;
BOX_WORD G501_s_Graphic560_Box_ActionArea1ActionMenu;
BOX_WORD G502_s_Graphic560_Box_ActionAreaMediumDamage;
BOX_WORD G503_s_Graphic560_Box_ActionAreaSmallDamage;
BOX_WORD G504_s_Graphic560_Box_SpellAreaControls;
int G505_i_Graphic560Anchor;
int G506_i_ActingChampionOrdinal;
unsigned int G507_ui_ActionCount;
BOOLEAN G508_B_RefreshActionArea;
BOOLEAN G509_B_ActionAreaContainsIcons;
char G510_ac_ActionListMinimumSkillLevel[3];
unsigned char G511_auc_ActionList[3];
unsigned char G512_uc_Useless; /* BUG0_00 Useless code */
int G513_i_ActionDamage;
int G514_i_MagicCasterChampionIndex = CM1_CHAMPION_NONE;
unsigned int G515_aui_Bitmap_SpellAreaLine[M75_BITMAP_BYTE_COUNT(96, 12) / 2];
unsigned int G516_aaui_Bitmap_SpellAreaLines[3][M75_BITMAP_BYTE_COUNT(96, 12) / 2]; /* A single bitmap containing 3 lines of 96 * 12 pixels. The first line is never used */
THING G517_T_ActionTargetGroupThing;


overlay "user"

VOID F381_xxxx_MENUS_PrintMessageAfterReplacements(P756_pc_String)
register char* P756_pc_String;
{
        register char* L1164_pc_Character;
        char* L1165_pc_ReplacementString;
        char L1166_ac_OutputString[128];


        L1164_pc_Character = L1166_ac_OutputString;
        *L1164_pc_Character++ = '\n'; /* New line */
        do {
                if (*P756_pc_String == '@') {
                        P756_pc_String++;
                        if (*(L1164_pc_Character - 1) != '\n') { /* New line */
                                *L1164_pc_Character++ = ' ';
                        }
                        if (*P756_pc_String != 'p') { /* '@p' in the source string is replaced by the champion name followed by a space */
                        } else {
                                L1165_pc_ReplacementString = G407_s_Party.Champions[M01_ORDINAL_TO_INDEX(G506_i_ActingChampionOrdinal)].Name;
                        }
                        *L1164_pc_Character = '\0';
                        strcat(L1166_ac_OutputString, L1165_pc_ReplacementString);
                        L1164_pc_Character += strlen(L1165_pc_ReplacementString);
                        *L1164_pc_Character++ = ' ';
                } else {
                        *L1164_pc_Character++ = *P756_pc_String;
                }
        } while (*P756_pc_String++);
        *L1164_pc_Character = '\0';
        if (L1166_ac_OutputString[1]) { /* If the string is not empty (the first character is a new line \n) */
                F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C04_COLOR_CYAN, L1166_ac_OutputString);
        }
}

int F382_xxxx_MENUS_GetActionObjectChargeCount()
{
        register THING L1167_T_Thing;
        register JUNK* L1168_ps_Junk;


        L1168_ps_Junk = (JUNK*)F156_afzz_DUNGEON_GetThingData(L1167_T_Thing = G407_s_Party.Champions[M01_ORDINAL_TO_INDEX(G506_i_ActingChampionOrdinal)].Slots[C01_SLOT_ACTION_HAND]);
        switch (M12_TYPE(L1167_T_Thing)) {
                case C05_THING_TYPE_WEAPON:
                        return ((WEAPON*)L1168_ps_Junk)->ChargeCount;
                case C06_THING_TYPE_ARMOUR:
                        return ((ARMOUR*)L1168_ps_Junk)->ChargeCount;
                case C10_THING_TYPE_JUNK:
                        return L1168_ps_Junk->ChargeCount;
                default:
                        return 1;
        }
}

VOID F383_xxxx_MENUS_SetActionList(P757_ps_ActionSet)
register ACTION_SET* P757_ps_ActionSet;
{
        register unsigned int L1169_ui_ActionListIndex;
        register unsigned int L1170_ui_NextAvailableActionListIndex;
        register unsigned int L1171_ui_ActionIndex;
        register unsigned int L1172_ui_MinimumSkillLevel;


        G511_auc_ActionList[0] = P757_ps_ActionSet->ActionIndicesAndProperties[0];
        G510_ac_ActionListMinimumSkillLevel[0] = 1;
        L1170_ui_NextAvailableActionListIndex = 1;
        for(L1169_ui_ActionListIndex = 1; L1169_ui_ActionListIndex < 3; L1169_ui_ActionListIndex++) {
                if ((L1171_ui_ActionIndex = P757_ps_ActionSet->ActionIndicesAndProperties[L1169_ui_ActionListIndex]) == C255_ACTION_NONE) {
                        continue;
                }
                if (M07_GET(L1172_ui_MinimumSkillLevel = P757_ps_ActionSet->ActionIndicesAndProperties[L1169_ui_ActionListIndex + 3], MASK0x0080_ACTION_REQUIRES_CHARGE) && !F382_xxxx_MENUS_GetActionObjectChargeCount()) {
                        continue;
                }
                M09_CLEAR(L1172_ui_MinimumSkillLevel, MASK0x0080_ACTION_REQUIRES_CHARGE);
                if (F303_AA09_CHAMPION_GetSkillLevel(M01_ORDINAL_TO_INDEX(G506_i_ActingChampionOrdinal), G496_auc_Graphic560_ActionSkillIndex[L1171_ui_ActionIndex]) >= L1172_ui_MinimumSkillLevel) {
                        G511_auc_ActionList[L1170_ui_NextAvailableActionListIndex] = L1171_ui_ActionIndex;
                        G510_ac_ActionListMinimumSkillLevel[L1170_ui_NextAvailableActionListIndex] = L1172_ui_MinimumSkillLevel;
                        L1170_ui_NextAvailableActionListIndex++;
                }
        }
        G507_ui_ActionCount = L1170_ui_NextAvailableActionListIndex;
        for(L1169_ui_ActionListIndex = L1170_ui_NextAvailableActionListIndex; L1169_ui_ActionListIndex < 3; L1169_ui_ActionListIndex++) {
                G511_auc_ActionList[L1169_ui_ActionListIndex] = C255_ACTION_NONE;
        }
}

char* F384_xxxx_MENUS_GetActionName(P758_uc_ActionIndex)
register unsigned char P758_uc_ActionIndex;
{
        register char* L1173_pc_Character;


        if (P758_uc_ActionIndex == C255_ACTION_NONE) {
                return "";
        }
        L1173_pc_Character = G490_ac_Graphic560_ActionNames;
        while (P758_uc_ActionIndex--) {
                while (*L1173_pc_Character++);
        }
        return L1173_pc_Character;
}

VOID F385_xxxx_MENUS_DrawActionDamage(P759_i_Damage)
int P759_i_Damage;
{
        register unsigned int L1174_ui_Multiple;
#define A1174_ui_DerivedBitmapIndex L1174_ui_Multiple
#define A1174_ui_CharacterIndex     L1174_ui_Multiple
        register int L1175_i_ByteWidth;
        register int L1176_i_Multiple;
#define A1176_i_X          L1176_i_Multiple
#define A1176_i_PixelWidth L1176_i_Multiple
        register unsigned char* L1177_puc_Bitmap;
        register unsigned char* L1178_puc_Multiple;
#define A1178_puc_String L1178_puc_Multiple
#define A1178_puc_Bitmap L1178_puc_Multiple
        char L1179_ac_String[6];
        BOX_WORD* L1180_ps_Box;


        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        G578_B_UseByteBoxCoordinates = FALSE;
        F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G001_s_Graphic562_Box_ActionArea, C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
        if (P759_i_Damage < 0) {
                if (P759_i_Damage == CM1_DAMAGE_CANT_REACH) {
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                        A1176_i_X = 242;
                        A1178_puc_String = (unsigned char*)"CAN'T REACH";
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                        A1176_i_X = 242;
                        A1178_puc_String = (unsigned char*)"ZU WEIT WEG";
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                        A1176_i_X = 248;
                        A1178_puc_String = (unsigned char*)"TROP LOIN";
#endif
                } else {
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                        A1176_i_X = 248;
                        A1178_puc_String = (unsigned char*)"NEED AMMO";
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                        A1176_i_X = 236;
                        A1178_puc_String = (unsigned char*)"MEHR MUNITION";
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                        A1176_i_X = 236;
                        A1178_puc_String = (unsigned char*)"SANS MUNITION";
#endif
                }
                F053_aajz_TEXT_PrintToLogicalScreen(A1176_i_X, 100, C04_COLOR_CYAN, C00_COLOR_BLACK, A1178_puc_String);
        } else {
                if (P759_i_Damage > 40) {
                        L1180_ps_Box = &G499_s_Graphic560_Box_ActionArea3ActionsMenu;
                        L1177_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C014_GRAPHIC_DAMAGE_TO_CREATURE);
                        L1175_i_ByteWidth = C048_BYTE_WIDTH;
                } else {
                        if (P759_i_Damage > 15) {
                                A1174_ui_DerivedBitmapIndex = C002_DERIVED_BITMAP_DAMAGE_TO_CREATURE_MEDIUM;
                                A1176_i_PixelWidth = 64;
                                L1175_i_ByteWidth = C032_BYTE_WIDTH;
                                L1180_ps_Box = &G502_s_Graphic560_Box_ActionAreaMediumDamage;
                        } else {
                                A1174_ui_DerivedBitmapIndex = C003_DERIVED_BITMAP_DAMAGE_TO_CREATURE_SMALL;
                                A1176_i_PixelWidth = 42;
                                L1175_i_ByteWidth = C024_BYTE_WIDTH;
                                L1180_ps_Box = &G503_s_Graphic560_Box_ActionAreaSmallDamage;
                        }
                        if (!F491_xzzz_CACHE_IsDerivedBitmapInCache(A1174_ui_DerivedBitmapIndex)) {
                                A1178_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C014_GRAPHIC_DAMAGE_TO_CREATURE);
                                F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(A1178_puc_Bitmap, L1177_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(A1174_ui_DerivedBitmapIndex), 96, 45, A1176_i_PixelWidth, 37, G017_auc_Graphic562_PaletteChanges_NoChanges);
                                F493_hzzz_CACHE_AddDerivedBitmap(A1174_ui_DerivedBitmapIndex);
                        } else {
                                L1177_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(A1174_ui_DerivedBitmapIndex);
                        }
                }
                F021_a002_MAIN_BlitToScreen(L1177_puc_Bitmap, L1180_ps_Box, L1175_i_ByteWidth, CM1_COLOR_NO_TRANSPARENCY);
                /* Convert damage value to string */
                A1174_ui_CharacterIndex = 5;
                A1176_i_X = 274;
                L1179_ac_String[5] = '\0';
                do {
                        L1179_ac_String[--A1174_ui_CharacterIndex] = '0' + (P759_i_Damage % 10);
                        A1176_i_X -= 3;
                } while (P759_i_Damage /= 10);
                F053_aajz_TEXT_PrintToLogicalScreen(A1176_i_X, 100, C04_COLOR_CYAN, C00_COLOR_BLACK, &L1179_ac_String[A1174_ui_CharacterIndex]);
        }
        F078_xzzz_MOUSE_ShowPointer();
}

VOID F386_ezzz_MENUS_DrawActionIcon(P760_ui_ChampionIndex)
unsigned int P760_ui_ChampionIndex;
{
        register THING L1181_ui_Multiple;
#define A1181_T_Thing      L1181_ui_Multiple
#define A1181_ui_IconIndex L1181_ui_Multiple
        register unsigned char* L1182_puc_Bitmap_Icon;
        register CHAMPION* L1183_ps_Champion;
        BOX_WORD L1184_s_Box;
        BOX_WORD L1185_s_Box;


        if (!G509_B_ActionAreaContainsIcons) {
                return;
        }
        L1184_s_Box.X2 = (L1184_s_Box.X1 = (P760_ui_ChampionIndex * 22) + 233) + 19;
        L1184_s_Box.Y1 = 86;
        L1184_s_Box.Y2 = 120;
        G578_B_UseByteBoxCoordinates = FALSE;
        L1183_ps_Champion = &G407_s_Party.Champions[P760_ui_ChampionIndex];
        if (!L1183_ps_Champion->CurrentHealth) {
                F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &L1184_s_Box, C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
                return;
        }
        L1182_puc_Bitmap_Icon = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(16, 16), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        if ((A1181_T_Thing = L1183_ps_Champion->Slots[C01_SLOT_ACTION_HAND]) == C0xFFFF_THING_NONE) {
                A1181_ui_IconIndex = C201_ICON_ACTION_ICON_EMPTY_HAND;
        } else {
                if (G237_as_Graphic559_ObjectInfo[F141_anzz_DUNGEON_GetObjectInfoIndex(A1181_T_Thing)].ActionSetIndex) {
                        A1181_ui_IconIndex = F033_aaaz_OBJECT_GetIconIndex(A1181_T_Thing);
                } else {
                        F134_zzzz_VIDEO_FillBitmap(L1182_puc_Bitmap_Icon, C04_COLOR_CYAN, M76_BITMAP_UNIT_COUNT(16, 16));
                        goto T386_006;
                }
        }
        F036_aA19_OBJECT_ExtractIconFromBitmap(A1181_ui_IconIndex, L1182_puc_Bitmap_Icon);
        F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(L1182_puc_Bitmap_Icon, L1182_puc_Bitmap_Icon, 16, 16, 16, 16, G498_auc_Graphic560_PaletteChanges_ActionAreaObjectIcon);
        T386_006:
        F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &L1184_s_Box, C04_COLOR_CYAN, C160_BYTE_WIDTH_SCREEN);
        L1185_s_Box.X1 = L1184_s_Box.X1 + 2;
        L1185_s_Box.X2 = L1184_s_Box.X2 - 2;
        L1185_s_Box.Y1 = 95;
        L1185_s_Box.Y2 = 110;
        F021_a002_MAIN_BlitToScreen(L1182_puc_Bitmap_Icon, &L1185_s_Box, C008_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
        if (M07_GET(L1183_ps_Champion->Attributes, MASK0x0008_DISABLE_ACTION) || G299_ui_CandidateChampionOrdinal || G300_B_PartyIsSleeping) {
                F136_nzzz_VIDEO_ShadeScreenBox(&L1184_s_Box, C00_COLOR_BLACK);
        }
        F469_rzzz_MEMORY_FreeAtHeapTop((long)M75_BITMAP_BYTE_COUNT(16, 16));
}

VOID F387_hzzz_MENUS_DrawActionArea()
{
        register unsigned int L1186_ui_Multiple;
#define A1186_ui_ChampionIndex   L1186_ui_Multiple
#define A1186_ui_ActionListIndex L1186_ui_Multiple
        register BOX_WORD* L1187_ps_Box;


        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        G578_B_UseByteBoxCoordinates = FALSE;
        F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G001_s_Graphic562_Box_ActionArea, C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
        if (G509_B_ActionAreaContainsIcons) {
                A1186_ui_ChampionIndex = C00_CHAMPION_FIRST;
                while (A1186_ui_ChampionIndex < G305_ui_PartyChampionCount) {
                        F386_ezzz_MENUS_DrawActionIcon(A1186_ui_ChampionIndex++);
                }
        } else {
                if (G506_i_ActingChampionOrdinal) {
                        L1187_ps_Box = &G499_s_Graphic560_Box_ActionArea3ActionsMenu;
                        if (G511_auc_ActionList[2] == C255_ACTION_NONE) {
                                L1187_ps_Box = &G500_s_Graphic560_Box_ActionArea2ActionsMenu;
                        }
                        if (G511_auc_ActionList[1] == C255_ACTION_NONE) {
                                L1187_ps_Box = &G501_s_Graphic560_Box_ActionArea1ActionMenu;
                        }
                        F021_a002_MAIN_BlitToScreen(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C010_GRAPHIC_MENU_ACTION_AREA), L1187_ps_Box, C048_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
                        F041_aadZ_TEXT_PrintWithTrailingSpaces(G348_pl_Bitmap_LogicalScreenBase, C160_BYTE_WIDTH_SCREEN, 235, 83, C00_COLOR_BLACK, C04_COLOR_CYAN, G407_s_Party.Champions[M01_ORDINAL_TO_INDEX(G506_i_ActingChampionOrdinal)].Name, C007_CHAMPION_NAME_MAXIMUM_LENGTH);
                        for(A1186_ui_ActionListIndex = 0; A1186_ui_ActionListIndex < 3; A1186_ui_ActionListIndex++) {
                                F041_aadZ_TEXT_PrintWithTrailingSpaces(G348_pl_Bitmap_LogicalScreenBase, C160_BYTE_WIDTH_SCREEN, 241, 93 + (A1186_ui_ActionListIndex * 12), C04_COLOR_CYAN, C00_COLOR_BLACK, F384_xxxx_MENUS_GetActionName(G511_auc_ActionList[A1186_ui_ActionListIndex]), C012_ACTION_NAME_MAXIMUM_LENGTH);
                        }
                }
        }
        F078_xzzz_MOUSE_ShowPointer();
        G508_B_RefreshActionArea = FALSE;
}

VOID F388_rzzz_MENUS_ClearActingChampion()
{
        if (G506_i_ActingChampionOrdinal) {
                G506_i_ActingChampionOrdinal--;
                M08_SET(G407_s_Party.Champions[G506_i_ActingChampionOrdinal].Attributes, MASK0x8000_ACTION_HAND);
                F292_arzz_CHAMPION_DrawState(G506_i_ActingChampionOrdinal);
                G506_i_ActingChampionOrdinal = M00_INDEX_TO_ORDINAL(CM1_CHAMPION_NONE);
                G508_B_RefreshActionArea = TRUE;
        }
}

VOID F389_xxxx_MENUS_ProcessCommands116To119_SetActingChampion(P761_ui_ChampionIndex)
unsigned int P761_ui_ChampionIndex;
{
        register int L1188_i_ActionSetIndex;
        register THING L1189_T_Thing;
        register CHAMPION* L1190_ps_Champion;
        register ACTION_SET* L1191_ps_ActionSet;


        L1190_ps_Champion = &G407_s_Party.Champions[P761_ui_ChampionIndex];
        if (M07_GET(L1190_ps_Champion->Attributes, MASK0x0008_DISABLE_ACTION) || !L1190_ps_Champion->CurrentHealth) {
                return;
        }
        if ((L1189_T_Thing = L1190_ps_Champion->Slots[C01_SLOT_ACTION_HAND]) == C0xFFFF_THING_NONE) {
                L1188_i_ActionSetIndex = 2; /* Actions Punck, Kick and War Cry */
        } else {
                if ((L1188_i_ActionSetIndex = G237_as_Graphic559_ObjectInfo[F141_anzz_DUNGEON_GetObjectInfoIndex(L1189_T_Thing)].ActionSetIndex) == 0) {
                        return;
                }
        }
        L1191_ps_ActionSet = &G489_as_Graphic560_ActionSets[L1188_i_ActionSetIndex];
        G506_i_ActingChampionOrdinal = M00_INDEX_TO_ORDINAL(P761_ui_ChampionIndex);
        G512_uc_Useless = L1191_ps_ActionSet->Useless; /* BUG0_00 Useless code */
        F383_xxxx_MENUS_SetActionList(L1191_ps_ActionSet);
        G509_B_ActionAreaContainsIcons = FALSE;
        M08_SET(L1190_ps_Champion->Attributes, MASK0x8000_ACTION_HAND);
        F292_arzz_CHAMPION_DrawState(P761_ui_ChampionIndex);
        F387_hzzz_MENUS_DrawActionArea();
}

VOID F390_rzzz_MENUS_RefreshActionAreaAndSetChampionDirectionMaximumDamageReceived()
{
        register int L1192_i_ChampionIndex;
        register int L1193_i_Unreferenced; /* BUG0_00 Useless code */
        register int L1194_i_Unreferenced; /* BUG0_00 Useless code */
        register CHAMPION* L1195_ps_Champion;


        if (!G305_ui_PartyChampionCount) {
                return;
        }
        if (G300_B_PartyIsSleeping || G299_ui_CandidateChampionOrdinal) {
                if (G506_i_ActingChampionOrdinal) {
                        F388_rzzz_MENUS_ClearActingChampion();
                        return;
                }
                if (!G299_ui_CandidateChampionOrdinal) {
                        return;
                }
        } else {
                L1195_ps_Champion = G407_s_Party.Champions;
                L1192_i_ChampionIndex = C00_CHAMPION_FIRST;
                do {
                        if ((L1192_i_ChampionIndex != G411_i_LeaderIndex) && (M00_INDEX_TO_ORDINAL(L1192_i_ChampionIndex) != G506_i_ActingChampionOrdinal) && L1195_ps_Champion->MaximumDamageReceived && (L1195_ps_Champion->Direction != L1195_ps_Champion->DirectionMaximumDamageReceived)) {
                                L1195_ps_Champion->Direction = L1195_ps_Champion->DirectionMaximumDamageReceived;
                                M08_SET(L1195_ps_Champion->Attributes, MASK0x0400_ICON);
                                F292_arzz_CHAMPION_DrawState(L1192_i_ChampionIndex);
                        }
                        L1195_ps_Champion->MaximumDamageReceived = 0;
                        L1195_ps_Champion++;
                        L1192_i_ChampionIndex++;
                } while (L1192_i_ChampionIndex < G305_ui_PartyChampionCount);
        }
        if (G508_B_RefreshActionArea) {
                if (!G506_i_ActingChampionOrdinal) {
                        if (G513_i_ActionDamage) {
                                F385_xxxx_MENUS_DrawActionDamage(G513_i_ActionDamage);
                                G513_i_ActionDamage = 0;
                        } else {
                                G509_B_ActionAreaContainsIcons = TRUE;
                                F387_hzzz_MENUS_DrawActionArea();
                        }
                } else {
                        G509_B_ActionAreaContainsIcons = FALSE;
                        M08_SET(L1195_ps_Champion->Attributes, MASK0x8000_ACTION_HAND);
                        F292_arzz_CHAMPION_DrawState(M01_ORDINAL_TO_INDEX(G506_i_ActingChampionOrdinal));
                        F387_hzzz_MENUS_DrawActionArea();
                }
        }
}

BOOLEAN F391_xxxx_MENUS_DidClickTriggerAction(P762_i_ActionListIndex)
int P762_i_ActionListIndex;
{
        register int L1196_i_ChampionIndex;
        register unsigned int L1197_ui_ActionIndex;
        register BOOLEAN L1198_B_ClickTriggeredAction;
        register CHAMPION* L1199_ps_Champion;


        if (!G506_i_ActingChampionOrdinal || (G511_auc_ActionList[P762_i_ActionListIndex] == C255_ACTION_NONE)) { /* BUG0_01 Coding error without consequence. Out of bounds array index when called with P762_i_ActionListIndex = -1. No consequence because this accesses G512_uc_Useless which cannot have value 255 */
                return FALSE;
        }
        L1199_ps_Champion = &G407_s_Party.Champions[L1196_i_ChampionIndex = M01_ORDINAL_TO_INDEX(G506_i_ActingChampionOrdinal)];
        if (P762_i_ActionListIndex == -1) {
                L1198_B_ClickTriggeredAction = -1;
        } else {
                L1197_ui_ActionIndex = G511_auc_ActionList[P762_i_ActionListIndex];
                L1199_ps_Champion->ActionDefense += G495_ac_Graphic560_ActionDefense[L1197_ui_ActionIndex]; /* BUG0_54 The defense modifier of an action is permanent. 
                Each action has an associated defense modifier value and a number of ticks while the champion cannot perform another action because the action icon is grayed out. If an action has a non zero defense modifier and a zero value for the number of ticks then the defense modifier is applied but it is never removed. This causes no issue in the original games because there are no actions in this case but it may occur in a version where data is customized. This statement should only be executed if the value for the action in G491_auc_Graphic560_ActionDisabledTicks is not 0 otherwise the action is not disabled at the end of F407_xxxx_MENUS_IsActionPerformed and thus not enabled later in F253_xxxx_TIMELINE_ProcessEvent11Part1_EnableChampionAction where the defense modifier is also removed */
                M08_SET(L1199_ps_Champion->Attributes, MASK0x0100_STATISTICS);
                L1198_B_ClickTriggeredAction = F407_xxxx_MENUS_IsActionPerformed(L1196_i_ChampionIndex, L1197_ui_ActionIndex);
                L1199_ps_Champion->ActionIndex = L1197_ui_ActionIndex;
        }
        F388_rzzz_MENUS_ClearActingChampion();
        return L1198_B_ClickTriggeredAction;
}

VOID F392_xxxx_MENUS_BuildSpellAreaLine(P763_i_SpellAreaBitmapLine)
int P763_i_SpellAreaBitmapLine;
{
        register unsigned int L1200_ui_SymbolIndex;
        register int L1201_i_X;
        register char L1202_c_Character;
        register CHAMPION* L1203_ps_Champion;
        char L1204_ac_SpellSymbolString[2];


        L1203_ps_Champion = &G407_s_Party.Champions[G514_i_MagicCasterChampionIndex];
        if (P763_i_SpellAreaBitmapLine == C2_SPELL_AREA_AVAILABLE_SYMBOLS) {
                F007_aAA7_MAIN_CopyBytes(G516_aaui_Bitmap_SpellAreaLines[1], G515_aui_Bitmap_SpellAreaLine, sizeof(G515_aui_Bitmap_SpellAreaLine));
                L1201_i_X = 1;
                L1202_c_Character = 96 + (6 * L1203_ps_Champion->SymbolStep);
                L1204_ac_SpellSymbolString[1] = '\0';
                for(L1200_ui_SymbolIndex = 0; L1200_ui_SymbolIndex < 6; L1200_ui_SymbolIndex++) {
                        L1204_ac_SpellSymbolString[0] = L1202_c_Character++;
                        F040_aacZ_TEXT_Print(G515_aui_Bitmap_SpellAreaLine, 48, L1201_i_X += 14, 8, C04_COLOR_CYAN, C00_COLOR_BLACK, L1204_ac_SpellSymbolString);
                }
        } else {
                if (P763_i_SpellAreaBitmapLine == C3_SPELL_AREA_CHAMPION_SYMBOLS) {
                        F007_aAA7_MAIN_CopyBytes(G516_aaui_Bitmap_SpellAreaLines[2], G515_aui_Bitmap_SpellAreaLine, sizeof(G515_aui_Bitmap_SpellAreaLine));
                        L1204_ac_SpellSymbolString[1] = '\0';
                        L1201_i_X = 8;
                        for(L1200_ui_SymbolIndex = 0; L1200_ui_SymbolIndex < 4; L1200_ui_SymbolIndex++) {
                                if ((L1204_ac_SpellSymbolString[0] = L1203_ps_Champion->Symbols[L1200_ui_SymbolIndex]) == '\0') {
                                        return;
                                }
                                F040_aacZ_TEXT_Print(G515_aui_Bitmap_SpellAreaLine, 48, L1201_i_X += 9, 8, C04_COLOR_CYAN, C00_COLOR_BLACK, L1204_ac_SpellSymbolString);
                        }

                }
        }
}

VOID F393_lzzz_MENUS_DrawSpellAreaControls(P764_i_ChampionIndex)
int P764_i_ChampionIndex;
{
        register CHAMPION* L1205_ps_Champion;
        int L1206_i_Champion0CurrentHealth;
        int L1207_i_Champion1CurrentHealth;
        int L1208_i_Champion2CurrentHealth;
        int L1209_i_Champion3CurrentHealth;


        L1205_ps_Champion = &G407_s_Party.Champions[P764_i_ChampionIndex];
        G578_B_UseByteBoxCoordinates = FALSE;
        L1206_i_Champion0CurrentHealth = G407_s_Party.Champions[0].CurrentHealth;
        L1207_i_Champion1CurrentHealth = G407_s_Party.Champions[1].CurrentHealth;
        L1208_i_Champion2CurrentHealth = G407_s_Party.Champions[2].CurrentHealth;
        L1209_i_Champion3CurrentHealth = G407_s_Party.Champions[3].CurrentHealth;
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G504_s_Graphic560_Box_SpellAreaControls, C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
        switch (P764_i_ChampionIndex) {
                case 0:
                        F006_aamz_MAIN_HighlightScreenBox(233, 277, 42, 49);
                        F053_aajz_TEXT_PrintToLogicalScreen(235, 48, C00_COLOR_BLACK, C04_COLOR_CYAN, L1205_ps_Champion);
                        if (G305_ui_PartyChampionCount > 1) {
                                if (L1207_i_Champion1CurrentHealth) {
                                        F006_aamz_MAIN_HighlightScreenBox(280, 291, 42, 48);
                                }
                                T393_002:
                                if (G305_ui_PartyChampionCount > 2) {
                                        if (L1208_i_Champion2CurrentHealth) {
                                                F006_aamz_MAIN_HighlightScreenBox(294, 305, 42, 48);
                                        }
                                        T393_003:
                                        if (G305_ui_PartyChampionCount > 3) {
                                                if (L1209_i_Champion3CurrentHealth) {
                                                        F006_aamz_MAIN_HighlightScreenBox(308, 319, 42, 48);
                                                }
                                        }
                                }
                        }
                        break;
                case 1:
                        if (L1206_i_Champion0CurrentHealth) {
                                F006_aamz_MAIN_HighlightScreenBox(233, 244, 42, 48);
                        }
                        F006_aamz_MAIN_HighlightScreenBox(247, 291, 42, 49);
                        F053_aajz_TEXT_PrintToLogicalScreen(249, 48, C00_COLOR_BLACK, C04_COLOR_CYAN, L1205_ps_Champion);
                        goto T393_002;
                case 2:
                        if (L1206_i_Champion0CurrentHealth) {
                                F006_aamz_MAIN_HighlightScreenBox(233, 244, 42, 48);
                        }
                        if (L1207_i_Champion1CurrentHealth) {
                                F006_aamz_MAIN_HighlightScreenBox(247, 258, 42, 48);
                        }
                        F006_aamz_MAIN_HighlightScreenBox(261, 305, 42, 49);
                        F053_aajz_TEXT_PrintToLogicalScreen(263, 48, C00_COLOR_BLACK, C04_COLOR_CYAN, L1205_ps_Champion);
                        goto T393_003;
                case 3:
                        if (L1206_i_Champion0CurrentHealth) {
                                F006_aamz_MAIN_HighlightScreenBox(233, 244, 42, 48);
                        }
                        if (L1207_i_Champion1CurrentHealth) {
                                F006_aamz_MAIN_HighlightScreenBox(247, 258, 42, 48);
                        }
                        if (L1208_i_Champion2CurrentHealth) {
                                F006_aamz_MAIN_HighlightScreenBox(261, 272, 42, 48);
                        }
                        F006_aamz_MAIN_HighlightScreenBox(275, 319, 42, 49);
                        F053_aajz_TEXT_PrintToLogicalScreen(277, 48, C00_COLOR_BLACK, C04_COLOR_CYAN, L1205_ps_Champion);
        }
        F078_xzzz_MOUSE_ShowPointer();
}

VOID F394_ozzz_MENUS_SetMagicCasterAndDrawSpellArea(P765_i_ChampionIndex)
register int P765_i_ChampionIndex;
{
        register unsigned int L1210_ui_Y;
        register int L1211_i_Counter;
        register long L1212_l_Bitmap;
        register CHAMPION* L1213_ps_Champion;


        if ((P765_i_ChampionIndex == G514_i_MagicCasterChampionIndex) || ((P765_i_ChampionIndex != CM1_CHAMPION_NONE) && !G407_s_Party.Champions[P765_i_ChampionIndex].CurrentHealth)) {
                return;
        }
        if (G514_i_MagicCasterChampionIndex == CM1_CHAMPION_NONE) {
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                F021_a002_MAIN_BlitToScreen(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C009_GRAPHIC_MENU_SPELL_AREA_BACKGROUND), &G000_s_Graphic562_Box_SpellArea, C048_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY); /* The top line is always overwritten by the spell area controls but it can be seen very briefly when the spell area is drawn, for example when unfreezing the game: quickly press the 'Escape' key many times to try and see the arrows in the top right corner of the spell area */
                F078_xzzz_MOUSE_ShowPointer();
        }
        if (P765_i_ChampionIndex == CM1_CHAMPION_NONE) {
                G514_i_MagicCasterChampionIndex = CM1_CHAMPION_NONE;
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                G578_B_UseByteBoxCoordinates = FALSE;
                F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G000_s_Graphic562_Box_SpellArea, C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
                F078_xzzz_MOUSE_ShowPointer();
        } else {
                L1213_ps_Champion = &G407_s_Party.Champions[G514_i_MagicCasterChampionIndex = P765_i_ChampionIndex];
                F392_xxxx_MENUS_BuildSpellAreaLine(C2_SPELL_AREA_AVAILABLE_SYMBOLS);
                L1211_i_Counter = 0;
                L1212_l_Bitmap = (long)G348_pl_Bitmap_LogicalScreenBase + 8112; /* First pixel of spell area line 2 at screen coordinates 224, 50 */
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                F393_lzzz_MENUS_DrawSpellAreaControls(P765_i_ChampionIndex);
                for(L1210_ui_Y = 1; L1210_ui_Y < 12; L1210_ui_Y++) { /* Do not draw the first and last lines */
                        F007_aAA7_MAIN_CopyBytes(&G515_aui_Bitmap_SpellAreaLine[L1211_i_Counter += 24], L1212_l_Bitmap += C160_BYTE_WIDTH_SCREEN, 48); /* Copy 48 bytes = 96 pixels = one line of pixels in the spell area line bitmap */
                }
                F392_xxxx_MENUS_BuildSpellAreaLine(C3_SPELL_AREA_CHAMPION_SYMBOLS);
                L1211_i_Counter = 0;
                L1212_l_Bitmap = (long)G348_pl_Bitmap_LogicalScreenBase + 10032; /* First pixel of spell area line 3 at screen coordinates 224, 62 */
                for(L1210_ui_Y = 1; L1210_ui_Y < 12; L1210_ui_Y++) { /* Do not draw the first and last lines */
                        F007_aAA7_MAIN_CopyBytes(&G515_aui_Bitmap_SpellAreaLine[L1211_i_Counter += 24], L1212_l_Bitmap += C160_BYTE_WIDTH_SCREEN, 48); /* Copy 48 bytes = 96 pixels = one line of pixels in the spell area line bitmap */
                }
                F078_xzzz_MOUSE_ShowPointer();
        }
}

VOID F395_pzzz_MENUS_DrawMovementArrows()
{
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        F021_a002_MAIN_BlitToScreen(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C013_GRAPHIC_MOVEMENT_ARROWS), &G002_s_Graphic562_Box_MovementArrows, C048_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
        F078_xzzz_MOUSE_ShowPointer();
}

VOID F396_pzzz_MENUS_LoadSpellAreaLinesBitmap()
{
        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(C011_GRAPHIC_MENU_SPELL_AREA_LINES, G516_aaui_Bitmap_SpellAreaLines, 0, 0);
}

VOID F397_xxxx_MENUS_DrawAvailableSymbols(P766_ui_SymbolStep)
unsigned int P766_ui_SymbolStep;
{
        register unsigned int L1214_ui_Counter;
        register int L1215_i_X;
        register char L1216_c_Character;
        char L1217_ac_String[2];


        L1217_ac_String[1] = '\0';
        L1216_c_Character = 96 + 6 * P766_ui_SymbolStep;
        L1215_i_X = 225;
        for(L1214_ui_Counter = 0; L1214_ui_Counter < 6; L1214_ui_Counter++) {
                L1217_ac_String[0] = L1216_c_Character++;
                F053_aajz_TEXT_PrintToLogicalScreen(L1215_i_X += 14, 58, C04_COLOR_CYAN, C00_COLOR_BLACK, L1217_ac_String);
        }
}

VOID F398_xxxx_MENUS_DrawChampionSymbols(P767_ps_Champion)
register CHAMPION* P767_ps_Champion;
{
        register unsigned int L1218_ui_SymbolIndex;
        register int L1219_i_X;
        register unsigned int L1220_ui_SymbolCount;
        char L1221_ac_String[2];


        L1220_ui_SymbolCount = strlen(P767_ps_Champion->Symbols);
        L1219_i_X = 232;
        L1221_ac_String[1] = '\0';
        for(L1218_ui_SymbolIndex = 0; L1218_ui_SymbolIndex < 4; L1218_ui_SymbolIndex++) {
                if (L1218_ui_SymbolIndex >= L1220_ui_SymbolCount) {
                        L1221_ac_String[0] = ' ';
                } else {
                        L1221_ac_String[0] = P767_ps_Champion->Symbols[L1218_ui_SymbolIndex];
                }
                F053_aajz_TEXT_PrintToLogicalScreen(L1219_i_X += 9, 70, C04_COLOR_CYAN, C00_COLOR_BLACK, L1221_ac_String);
        }
}

VOID F399_xxxx_MENUS_AddChampionSymbol(P768_i_SymbolIndex)
int P768_i_SymbolIndex;
{
        register unsigned int L1222_ui_SymbolStep;
        register unsigned int L1223_ui_ManaCost;
        register int L1224_i_SymbolIndex;
        register CHAMPION* L1225_ps_Champion;


        L1225_ps_Champion = &G407_s_Party.Champions[G514_i_MagicCasterChampionIndex];
        L1222_ui_SymbolStep = L1225_ps_Champion->SymbolStep;
        L1223_ui_ManaCost = G485_aauc_Graphic560_SymbolBaseManaCost[L1222_ui_SymbolStep][P768_i_SymbolIndex];
        if (L1222_ui_SymbolStep) {
                L1223_ui_ManaCost = (L1223_ui_ManaCost * G486_auc_Graphic560_SymbolManaCostMultiplier[L1224_i_SymbolIndex = L1225_ps_Champion->Symbols[0] - 96]) >> 3;
        }
        if (L1223_ui_ManaCost <= L1225_ps_Champion->CurrentMana) {
                L1225_ps_Champion->CurrentMana -= L1223_ui_ManaCost;
                M08_SET(L1225_ps_Champion->Attributes, MASK0x0100_STATISTICS);
                L1225_ps_Champion->Symbols[L1222_ui_SymbolStep] = 96 + (L1222_ui_SymbolStep * 6) + P768_i_SymbolIndex;
                L1225_ps_Champion->Symbols[L1222_ui_SymbolStep + 1] = '\0';
                L1225_ps_Champion->SymbolStep = L1222_ui_SymbolStep = M17_NEXT(L1222_ui_SymbolStep);
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                F397_xxxx_MENUS_DrawAvailableSymbols(L1222_ui_SymbolStep);
                F398_xxxx_MENUS_DrawChampionSymbols(L1225_ps_Champion);
                F292_arzz_CHAMPION_DrawState(G514_i_MagicCasterChampionIndex);
                F078_xzzz_MOUSE_ShowPointer();
        }
}

VOID F400_xxxx_MENUS_DeleteChampionSymbol()
{
        register unsigned int L1226_ui_SymbolStep;
        register int L1227_i_Unreferenced; /* BUG0_00 Useless code */
        register CHAMPION* L1228_ps_Champion;


        L1228_ps_Champion = &G407_s_Party.Champions[G514_i_MagicCasterChampionIndex];
        if (!strlen(L1228_ps_Champion->Symbols)) {
                return;
        }
        L1228_ps_Champion->SymbolStep = L1226_ui_SymbolStep = M19_PREVIOUS(L1228_ps_Champion->SymbolStep);
        L1228_ps_Champion->Symbols[L1226_ui_SymbolStep] = '\0';
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        F397_xxxx_MENUS_DrawAvailableSymbols(L1226_ui_SymbolStep);
        F398_xxxx_MENUS_DrawChampionSymbols(L1228_ps_Champion);
        F078_xzzz_MOUSE_ShowPointer();
}

BOOLEAN F401_xxxx_MENUS_IsGroupFrightenedByAction(P769_i_ChampionIndex, P770_i_ActionIndex, P771_i_MapX, P772_i_MapY)
int P769_i_ChampionIndex;
int P770_i_ActionIndex;
int P771_i_MapX;
int P772_i_MapY;
{
        register int L1229_i_FrightAmount;
        register unsigned int L1230_ui_FearResistance;
        register unsigned int L1231_ui_Experience;
        register BOOLEAN L1232_B_IsGroupFrightenedByAction;
        register GROUP* L1233_ps_Group;
        register CREATURE_INFO* L1234_ps_CreatureInfo;
        ACTIVE_GROUP* L1235_ps_ActiveGroup;


        L1232_B_IsGroupFrightenedByAction = FALSE;
        if (G517_T_ActionTargetGroupThing == C0xFFFE_THING_ENDOFLIST) {
        } else {
                switch (P770_i_ActionIndex) {
                        case C008_ACTION_WAR_CRY:
                                L1229_i_FrightAmount = 3;
                                L1231_ui_Experience = 12; /* War Cry gives experience in priest skill C14_SKILL_INFLUENCE below. The War Cry action also has an experience gain of 7 defined in G497_auc_Graphic560_ActionExperienceGain in the same skill (versions 1.1 and below) or in the fighter skill C07_SKILL_PARRY (versions 1.2 and above). In versions 1.2 and above, this is the only action that gives experience in two skills */
                                break;
                        case C037_ACTION_CALM:
                                L1229_i_FrightAmount = 7;
                                L1231_ui_Experience = 35;
                                break;
                        case C041_ACTION_BRANDISH:
                                L1229_i_FrightAmount = 6;
                                L1231_ui_Experience = 30;
                                break;
                        case C004_ACTION_BLOW_HORN:
                                L1229_i_FrightAmount = 6;
                                L1231_ui_Experience = 20;
                                break;
                        case C022_ACTION_CONFUSE:
                                L1229_i_FrightAmount = 12;
                                L1231_ui_Experience = 45;
                }
                L1229_i_FrightAmount += F303_AA09_CHAMPION_GetSkillLevel(P769_i_ChampionIndex, C14_SKILL_INFLUENCE);
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L1233_ps_Group = &(((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(G517_T_ActionTargetGroupThing)]);
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                L1233_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(G517_T_ActionTargetGroupThing);
#endif
                L1234_ps_CreatureInfo = &G243_as_Graphic559_CreatureInfo[L1233_ps_Group->Type];
                if (((L1230_ui_FearResistance = M57_FEAR_RESISTANCE(L1234_ps_CreatureInfo->Properties)) > M02_RANDOM(L1229_i_FrightAmount)) || (L1230_ui_FearResistance == C15_IMMUNE_TO_FEAR)) {
                        L1231_ui_Experience >>= 1;
                } else {
                        L1235_ps_ActiveGroup = &G375_ps_ActiveGroups[L1233_ps_Group->ActiveGroupIndex];
                        if (L1233_ps_Group->Behavior == C6_BEHAVIOR_ATTACK) {
                                F182_aqzz_GROUP_StopAttacking(L1235_ps_ActiveGroup, P771_i_MapX, P772_i_MapY);
                                F180_hzzz_GROUP_StartWandering(P771_i_MapX, P772_i_MapY);
                        }
                        L1233_ps_Group->Behavior = C5_BEHAVIOR_FLEE;
                        L1235_ps_ActiveGroup->DelayFleeingFromTarget = ((16 - L1230_ui_FearResistance) << 2) / L1234_ps_CreatureInfo->MovementTicks;
                        L1232_B_IsGroupFrightenedByAction = TRUE;
                }
                F304_apzz_CHAMPION_AddSkillExperience(P769_i_ChampionIndex, C14_SKILL_INFLUENCE, L1231_ui_Experience);
        }
        return L1232_B_IsGroupFrightenedByAction;
}

BOOLEAN F402_xxxx_MENUS_IsMeleeActionPerformed(P773_i_ChampionIndex, P774_ps_Champion, P775_i_ActionIndex, P776_i_TargetMapX, P777_i_TargetMapY, P778_i_SkillIndex)
int P773_i_ChampionIndex;
register CHAMPION* P774_ps_Champion;
int P775_i_ActionIndex;
int P776_i_TargetMapX;
int P777_i_TargetMapY;
int P778_i_SkillIndex;
{
        register unsigned int L1236_ui_Multiple;
#define A1236_ui_ChampionCell       L1236_ui_Multiple
#define A1236_ui_ActionDamageFactor L1236_ui_Multiple
        register int L1237_i_Multiple;
#define A1237_i_Direction            L1237_i_Multiple
#define A1237_i_CellDelta            L1237_i_Multiple
#define A1237_i_ActionHitProbability L1237_i_Multiple
        register int L1238_i_CreatureOrdinal;


        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C16_SOUND_COMBAT, G306_i_PartyMapX, G307_i_PartyMapY, C01_MODE_PLAY_IF_PRIORITIZED);
        if (G517_T_ActionTargetGroupThing == C0xFFFE_THING_ENDOFLIST) {
                goto T402_010;
        }
        if (L1238_i_CreatureOrdinal = F177_aszz_GROUP_GetMeleeTargetCreatureOrdinal(P776_i_TargetMapX, P777_i_TargetMapY, G306_i_PartyMapX, G307_i_PartyMapY, A1236_ui_ChampionCell = P774_ps_Champion->Cell)) {
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_14_FIX The code to detect if a champion has another champion in front of him is wrong */
                if (((A1237_i_Direction = P774_ps_Champion->Direction) != A1236_ui_ChampionCell) &&
                    (M21_NORMALIZE(++A1237_i_Direction) != A1236_ui_ChampionCell) &&
                    ((M21_NORMALIZE(++A1237_i_Direction) != A1236_ui_ChampionCell) || (F285_szzz_CHAMPION_GetIndexInCell(M19_PREVIOUS(A1236_ui_ChampionCell)) != CM1_CHAMPION_NONE))) {
                        if (F285_szzz_CHAMPION_GetIndexInCell(M17_NEXT(A1236_ui_ChampionCell)) != CM1_CHAMPION_NONE) { /* BUG0_55 A champion in the back row may perform a melee attack even if there is another champion between him and the target creature. If there is a delta of 2 between the cell and the direction of a champion then the presence of another champion in front of him is ignored. For example, a champion in direction 0 (facing North) and cell 2 (back right) can attack a creature if there is another champion in front of him at cell 1 */
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_14_FIX The code to detect if a champion has another champion in front of him is fixed */
                switch (M21_NORMALIZE(A1236_ui_ChampionCell + 4 - P774_ps_Champion->Direction)) {
                        case C02_VIEW_CELL_BACK_RIGHT: /* Champion is on the back right of the square and tries to attack a creature in the front right of its square */
                                A1237_i_CellDelta = 3;
                                goto T402_005;
                        case C03_VIEW_CELL_BACK_LEFT: /* Champion is on the back left of the square and tries to attack a creature in the front left of its square */
                                A1237_i_CellDelta = 1;
                                T402_005: /* Check if there is another champion in front */
                                if (F285_szzz_CHAMPION_GetIndexInCell(M21_NORMALIZE(A1236_ui_ChampionCell + A1237_i_CellDelta)) != CM1_CHAMPION_NONE) {
#endif
                                        G513_i_ActionDamage = CM1_DAMAGE_CANT_REACH;
                                        goto T402_010;
                                }
                }
                if ((P775_i_ActionIndex == C024_ACTION_DISRUPT) && !M07_GET(F144_amzz_DUNGEON_GetCreatureAttributes(G517_T_ActionTargetGroupThing), MASK0x0040_NON_MATERIAL)) {
                } else {
                        A1237_i_ActionHitProbability = G493_auc_Graphic560_ActionHitProbability[P775_i_ActionIndex];
                        A1236_ui_ActionDamageFactor = G492_auc_Graphic560_ActionDamageFactor[P775_i_ActionIndex];
                        if ((F033_aaaz_OBJECT_GetIconIndex(P774_ps_Champion->Slots[C01_SLOT_ACTION_HAND]) == C040_ICON_WEAPON_VORPAL_BLADE) || (P775_i_ActionIndex == C024_ACTION_DISRUPT)) {
                                M08_SET(A1237_i_ActionHitProbability, MASK0x8000_HIT_NON_MATERIAL_CREATURES);
                        }
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        G513_i_ActionDamage = F231_izzz_GROUP_GetMeleeActionDamage(P774_ps_Champion, P773_i_ChampionIndex, &((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(G517_T_ActionTargetGroupThing)], M01_ORDINAL_TO_INDEX(L1238_i_CreatureOrdinal), P776_i_TargetMapX, P777_i_TargetMapY, A1237_i_ActionHitProbability, A1236_ui_ActionDamageFactor, P778_i_SkillIndex);
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        G513_i_ActionDamage = F231_izzz_GROUP_GetMeleeActionDamage(P774_ps_Champion, P773_i_ChampionIndex, (GROUP*)F156_afzz_DUNGEON_GetThingData(G517_T_ActionTargetGroupThing), M01_ORDINAL_TO_INDEX(L1238_i_CreatureOrdinal), P776_i_TargetMapX, P777_i_TargetMapY, A1237_i_ActionHitProbability, A1236_ui_ActionDamageFactor, P778_i_SkillIndex);
#endif
                        return TRUE;
                }
        }
        T402_010:
        return FALSE;
}

BOOLEAN F403_xxxx_MENUS_IsPartySpellOrFireShieldSuccessful(P779_ps_Champion, P780_B_SpellShield, P781_ui_Ticks, P782_B_UseMana)
CHAMPION* P779_ps_Champion;
BOOLEAN P780_B_SpellShield;
register unsigned int P781_ui_Ticks;
BOOLEAN P782_B_UseMana;
{
        register BOOLEAN L1239_B_IsPartySpellOrFireShieldSuccessful;
        EVENT L1240_s_Event;


        L1239_B_IsPartySpellOrFireShieldSuccessful = TRUE;
        if (P782_B_UseMana) {
                if (P779_ps_Champion->CurrentMana == 0) {
                        return FALSE;
                }
                if (P779_ps_Champion->CurrentMana < 4) {
                        P781_ui_Ticks >>= 1;
                        P779_ps_Champion->CurrentMana = 0;
                        L1239_B_IsPartySpellOrFireShieldSuccessful = FALSE;
                } else {
                        P779_ps_Champion->CurrentMana -= 4;
                }
        }
        L1240_s_Event.B.Defense = P781_ui_Ticks >> 5;
        if (P780_B_SpellShield) {
                L1240_s_Event.A.A.Type = C77_EVENT_SPELLSHIELD;
                if (G407_s_Party.SpellShieldDefense > 50) {
                        L1240_s_Event.B.Defense >>= 2;
                }
                G407_s_Party.SpellShieldDefense += L1240_s_Event.B.Defense;
        } else {
                L1240_s_Event.A.A.Type = C78_EVENT_FIRESHIELD;
                if (G407_s_Party.FireShieldDefense > 50) {
                        L1240_s_Event.B.Defense >>= 2;
                }
                G407_s_Party.FireShieldDefense += L1240_s_Event.B.Defense;
        }
        L1240_s_Event.A.A.Priority = 0;
        M33_SET_MAP_AND_TIME(L1240_s_Event.Map_Time, G309_i_PartyMapIndex, G313_ul_GameTime + P781_ui_Ticks);
        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L1240_s_Event);
        F260_pzzz_TIMELINE_RefreshAllChampionStatusBoxes();
        return L1239_B_IsPartySpellOrFireShieldSuccessful;
}

VOID F404_xxxx_MENUS_CreateEvent70_Light(P783_i_LightPower, P784_i_Ticks)
int P783_i_LightPower;
int P784_i_Ticks;
{
        EVENT L1241_s_Event;


        L1241_s_Event.A.A.Type = C70_EVENT_LIGHT;
        L1241_s_Event.B.LightPower = P783_i_LightPower;
        M33_SET_MAP_AND_TIME(L1241_s_Event.Map_Time, G309_i_PartyMapIndex, G313_ul_GameTime + P784_i_Ticks);
        L1241_s_Event.A.A.Priority = 0;
        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L1241_s_Event);
        F337_akzz_INVENTORY_SetDungeonViewPalette();
}

VOID F405_xxxx_MENUS_DecrementCharges(P785_ps_Champion)
CHAMPION* P785_ps_Champion;
{
        register THING L1242_T_Thing;
        register JUNK* L1243_ps_Junk;


        L1243_ps_Junk = (JUNK*)F156_afzz_DUNGEON_GetThingData(L1242_T_Thing = P785_ps_Champion->Slots[C01_SLOT_ACTION_HAND]);
        switch (M12_TYPE(L1242_T_Thing)) {
                case C05_THING_TYPE_WEAPON:
                        if (((WEAPON*)L1243_ps_Junk)->ChargeCount) {
                                ((WEAPON*)L1243_ps_Junk)->ChargeCount--;
                        }
                        break;
                case C06_THING_TYPE_ARMOUR:
                        if (((ARMOUR*)L1243_ps_Junk)->ChargeCount) {
                                ((ARMOUR*)L1243_ps_Junk)->ChargeCount--;
                        }
                        break;
                case C10_THING_TYPE_JUNK:
                        if (L1243_ps_Junk->ChargeCount) {
                                L1243_ps_Junk->ChargeCount--;
                        }
        }
        F296_aizz_CHAMPION_DrawChangedObjectIcons();
}

VOID F406_xxxx_MENUS_SetChampionDirectionToPartyDirection(P786_ps_Champion)
register CHAMPION* P786_ps_Champion;
{
        if (P786_ps_Champion->Direction != G308_i_PartyDirection) {
                P786_ps_Champion->Direction = G308_i_PartyDirection;
                M08_SET(P786_ps_Champion->Attributes, MASK0x0400_ICON);
        }
}

BOOLEAN F407_xxxx_MENUS_IsActionPerformed(P787_i_ChampionIndex, P788_i_ActionIndex)
register int P787_i_ChampionIndex;
int P788_i_ActionIndex;
{
        register unsigned int L1244_ui_Multiple;
#define A1244_ui_TargetSquare  L1244_ui_Multiple
#define A1244_ui_HealingAmount L1244_ui_Multiple
#define A1244_ui_ManaCost      L1244_ui_Multiple
        register int L1245_i_Multiple;
#define A1245_T_ExplosionThing  L1245_i_Multiple
#define A1245_B_ActionPerformed L1245_i_Multiple
        register int L1246_i_Multiple;
#define A1246_i_RequiredManaAmount    L1246_i_Multiple
#define A1246_i_ActionHandWeaponClass L1246_i_Multiple
#define A1246_i_StepEnergy            L1246_i_Multiple
#define A1246_i_HealingCapability     L1246_i_Multiple
#define A1246_i_Ticks                 L1246_i_Multiple
        register CHAMPION* L1247_ps_Champion;
        register WEAPON* L1248_ps_Weapon;
        unsigned int L1249_ui_ActionDisabledTicks;
        int L1250_i_Multiple;
#define A1250_i_KineticEnergy        L1250_i_Multiple
#define A1250_i_ReadyHandWeaponClass L1250_i_Multiple
#define A1250_T_Object               L1250_i_Multiple
#define A1250_i_MissingHealth        L1250_i_Multiple
#define A1250_i_HealingAmount        L1250_i_Multiple
        int L1251_i_MapX;
        int L1252_i_MapY;
        int L1253_i_ActionStamina;
        int L1254_i_ActionSkillIndex;
        int L1255_i_ActionExperienceGain;
        WEAPON_INFO* L1256_ps_WeaponInfoActionHand;
        WEAPON_INFO* L1257_ps_WeaponInfoReadyHand;
        EVENT L1258_s_Event;


        if (P787_i_ChampionIndex >= G305_ui_PartyChampionCount) {
                return FALSE;
        }
        L1247_ps_Champion = &G407_s_Party.Champions[P787_i_ChampionIndex];
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
        L1248_ps_Weapon = (WEAPON*)F156_afzz_DUNGEON_GetThingData(L1247_ps_Champion->Slots[C01_SLOT_ACTION_HAND]);
#endif
        if (!L1247_ps_Champion->CurrentHealth) {
                return FALSE;
        }
        L1251_i_MapX = G306_i_PartyMapX;
        L1252_i_MapY = G307_i_PartyMapY;
        L1251_i_MapX += G233_ai_Graphic559_DirectionToStepEastCount[L1247_ps_Champion->Direction], L1252_i_MapY += G234_ai_Graphic559_DirectionToStepNorthCount[L1247_ps_Champion->Direction];
        G517_T_ActionTargetGroupThing = F175_gzzz_GROUP_GetThing(L1251_i_MapX, L1252_i_MapY);
        L1249_ui_ActionDisabledTicks = G491_auc_Graphic560_ActionDisabledTicks[P788_i_ActionIndex];
        L1254_i_ActionSkillIndex = G496_auc_Graphic560_ActionSkillIndex[P788_i_ActionIndex];
        L1253_i_ActionStamina = G494_auc_Graphic560_ActionStamina[P788_i_ActionIndex] + M05_RANDOM(2);
        L1255_i_ActionExperienceGain = G497_auc_Graphic560_ActionExperienceGain[P788_i_ActionIndex];
        A1244_ui_TargetSquare = F151_rzzz_DUNGEON_GetSquare(L1251_i_MapX, L1252_i_MapY);
        A1245_B_ActionPerformed = TRUE;
        if (((L1254_i_ActionSkillIndex >= C16_SKILL_FIRE) && (L1254_i_ActionSkillIndex <= C19_SKILL_WATER)) || (L1254_i_ActionSkillIndex == C03_SKILL_WIZARD)) {
                A1246_i_RequiredManaAmount = 7 - F024_aatz_MAIN_GetMinimumValue(6, F303_AA09_CHAMPION_GetSkillLevel(P787_i_ChampionIndex, L1254_i_ActionSkillIndex));
        }
        switch (P788_i_ActionIndex) {
                case C023_ACTION_LIGHTNING:
                        A1250_i_KineticEnergy = 180;
                        A1245_T_ExplosionThing = C0xFF82_THING_EXPLOSION_LIGHTNING_BOLT;
                        goto T407_014;
                case C021_ACTION_DISPELL:
                        A1250_i_KineticEnergy = 150;
                        A1245_T_ExplosionThing = C0xFF83_THING_EXPLOSION_HARM_NON_MATERIAL;
                        goto T407_014;
                case C020_ACTION_FIREBALL:
                        A1250_i_KineticEnergy = 150;
                        goto T407_013;
                case C040_ACTION_SPIT:
                        A1250_i_KineticEnergy = 250;
                        T407_013:
                        A1245_T_ExplosionThing = C0xFF80_THING_EXPLOSION_FIREBALL;
                        T407_014:
                        F406_xxxx_MENUS_SetChampionDirectionToPartyDirection(L1247_ps_Champion);
                        if (L1247_ps_Champion->CurrentMana < A1246_i_RequiredManaAmount) {
                                A1250_i_KineticEnergy = F025_aatz_MAIN_GetMaximumValue(2, L1247_ps_Champion->CurrentMana * A1250_i_KineticEnergy / A1246_i_RequiredManaAmount);
                                A1246_i_RequiredManaAmount = L1247_ps_Champion->CurrentMana;
                        }
                        if (!(A1245_B_ActionPerformed = F327_kzzz_CHAMPION_IsProjectileSpellCast(P787_i_ChampionIndex, A1245_T_ExplosionThing, A1250_i_KineticEnergy, A1246_i_RequiredManaAmount))) {
                                L1255_i_ActionExperienceGain >>= 1;
                        }
                        F405_xxxx_MENUS_DecrementCharges(L1247_ps_Champion);
                        break;
                case C030_ACTION_BASH:
                case C018_ACTION_HACK:
                case C019_ACTION_BERZERK:
                case C007_ACTION_KICK:
                case C013_ACTION_SWING:
                case C002_ACTION_CHOP:
                        if ((M34_SQUARE_TYPE(A1244_ui_TargetSquare) == C04_ELEMENT_DOOR) && (M36_DOOR_STATE(A1244_ui_TargetSquare) == C4_DOOR_STATE_CLOSED)) {
                                F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C16_SOUND_COMBAT, G306_i_PartyMapX, G307_i_PartyMapY, C01_MODE_PLAY_IF_PRIORITIZED);
                                L1249_ui_ActionDisabledTicks = 6;
                                F232_dzzz_GROUP_IsDoorDestroyedByAttack(L1251_i_MapX, L1252_i_MapY, F312_xzzz_CHAMPION_GetStrength(P787_i_ChampionIndex, C01_SLOT_ACTION_HAND), FALSE, 2);
                                F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C04_SOUND_WOODEN_THUD, G306_i_PartyMapX, G307_i_PartyMapY, C02_MODE_PLAY_ONE_TICK_LATER);
                                break;
                        }
                case C024_ACTION_DISRUPT:
                case C016_ACTION_JAB:
                case C017_ACTION_PARRY:
                case C014_ACTION_STAB:
                case C009_ACTION_STAB:
                case C031_ACTION_STUN:
                case C015_ACTION_THRUST:
                case C025_ACTION_MELEE:
                case C028_ACTION_SLASH:
                case C029_ACTION_CLEAVE:
                case C006_ACTION_PUNCH:
                        if (!(A1245_B_ActionPerformed = F402_xxxx_MENUS_IsMeleeActionPerformed(P787_i_ChampionIndex, L1247_ps_Champion, P788_i_ActionIndex, L1251_i_MapX, L1252_i_MapY, L1254_i_ActionSkillIndex))) {
                                L1255_i_ActionExperienceGain >>= 1;
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_16_IMPROVEMENT The delay before another action can be performed after a melee action fails is halved */
                                L1249_ui_ActionDisabledTicks >>= 1;
#endif
                        }
                        break;
                case C022_ACTION_CONFUSE:
                        F405_xxxx_MENUS_DecrementCharges(L1247_ps_Champion);
                case C008_ACTION_WAR_CRY:
                case C037_ACTION_CALM:
                case C041_ACTION_BRANDISH:
                case C004_ACTION_BLOW_HORN:
                        A1245_B_ActionPerformed = F401_xxxx_MENUS_IsGroupFrightenedByAction(P787_i_ChampionIndex, P788_i_ActionIndex, L1251_i_MapX, L1252_i_MapY);
                        break;
                case C032_ACTION_SHOOT:
                        if (M12_TYPE(L1247_ps_Champion->Slots[C00_SLOT_READY_HAND]) != C05_THING_TYPE_WEAPON) {
                                goto T407_032;
                        }
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        L1256_ps_WeaponInfoActionHand = &G238_as_Graphic559_WeaponInfo[((WEAPON*)G284_apuc_ThingData[C05_THING_TYPE_WEAPON])[M13_INDEX(L1247_ps_Champion->Slots[C01_SLOT_ACTION_HAND])].Type];
                        L1257_ps_WeaponInfoReadyHand = &G238_as_Graphic559_WeaponInfo[((WEAPON*)G284_apuc_ThingData[C05_THING_TYPE_WEAPON])[M13_INDEX(L1247_ps_Champion->Slots[C00_SLOT_READY_HAND])].Type];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        L1256_ps_WeaponInfoActionHand = &G238_as_Graphic559_WeaponInfo[L1248_ps_Weapon->Type];
                        L1257_ps_WeaponInfoReadyHand = F158_ayzz_DUNGEON_GetWeaponInfo(L1247_ps_Champion->Slots[C00_SLOT_READY_HAND]);
#endif
                        A1246_i_ActionHandWeaponClass = L1256_ps_WeaponInfoActionHand->Class;
                        A1250_i_ReadyHandWeaponClass = L1257_ps_WeaponInfoReadyHand->Class;
                        if ((A1246_i_ActionHandWeaponClass >= C016_CLASS_FIRST_BOW) && (A1246_i_ActionHandWeaponClass <= C031_CLASS_LAST_BOW)) {
                                if (A1250_i_ReadyHandWeaponClass != C010_CLASS_BOW_AMMUNITION) {
                                        goto T407_032;
                                }
                                A1246_i_StepEnergy -= C016_CLASS_FIRST_BOW;
                        } else {
                                if ((A1246_i_ActionHandWeaponClass >= C032_CLASS_FIRST_SLING) && (A1246_i_ActionHandWeaponClass <= C047_CLASS_LAST_SLING)) {
                                        if (A1250_i_ReadyHandWeaponClass != C011_CLASS_SLING_AMMUNITION) {
                                                T407_032:
                                                G513_i_ActionDamage = CM2_DAMAGE_NO_AMMUNITION;
                                                L1255_i_ActionExperienceGain = 0;
                                                A1245_B_ActionPerformed = FALSE;
                                                break;
                                        }
                                        A1246_i_StepEnergy -= C032_CLASS_FIRST_SLING;
                                }
                        }
                        F406_xxxx_MENUS_SetChampionDirectionToPartyDirection(L1247_ps_Champion);
                        A1250_T_Object = F300_aozz_CHAMPION_GetObjectRemovedFromSlot(P787_i_ChampionIndex, C00_SLOT_READY_HAND);
                        F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND(C16_SOUND_COMBAT, G306_i_PartyMapX, G307_i_PartyMapY, C01_MODE_PLAY_IF_PRIORITIZED);
                        F326_ozzz_CHAMPION_ShootProjectile(L1247_ps_Champion, A1250_T_Object, L1256_ps_WeaponInfoActionHand->KineticEnergy + L1257_ps_WeaponInfoReadyHand->KineticEnergy, (M65_SHOOT_ATTACK(L1256_ps_WeaponInfoActionHand->Attributes) + F303_AA09_CHAMPION_GetSkillLevel(P787_i_ChampionIndex, C11_SKILL_SHOOT)) << 1, A1246_i_StepEnergy);
                        break;
                case C005_ACTION_FLIP:
                        if (M05_RANDOM(2)) {
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                                F381_xxxx_MENUS_PrintMessageAfterReplacements("IT COMES UP HEADS.");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                                F381_xxxx_MENUS_PrintMessageAfterReplacements("DIE KOPFSEITE IST OBEN.");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                                F381_xxxx_MENUS_PrintMessageAfterReplacements("C'EST FACE.");
#endif
                        } else {
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                                F381_xxxx_MENUS_PrintMessageAfterReplacements("IT COMES UP TAILS.");
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                                F381_xxxx_MENUS_PrintMessageAfterReplacements("DIE ZAHL IST OBEN.");
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                                F381_xxxx_MENUS_PrintMessageAfterReplacements("C'EST PILE.");
#endif
                        }
                        break;
                case C033_ACTION_SPELLSHIELD:
                case C034_ACTION_FIRESHIELD:
                        if (!F403_xxxx_MENUS_IsPartySpellOrFireShieldSuccessful(L1247_ps_Champion, P788_i_ActionIndex == C033_ACTION_SPELLSHIELD, 280, TRUE)) {
                                L1255_i_ActionExperienceGain >>= 2;
                                L1249_ui_ActionDisabledTicks >>= 1;
                        } else {
                                F405_xxxx_MENUS_DecrementCharges(L1247_ps_Champion);
                        }
                        break;
                case C027_ACTION_INVOKE:
                        A1250_i_KineticEnergy = M03_RANDOM(128) + 100;
                        switch (M02_RANDOM(6)) {
                                case 0:
                                        A1245_T_ExplosionThing = C0xFF86_THING_EXPLOSION_POISON_BOLT;
                                        goto T407_014;
                                case 1:
                                        A1245_T_ExplosionThing = C0xFF87_THING_EXPLOSION_POISON_CLOUD;
                                        goto T407_014;
                                case 2:
                                        A1245_T_ExplosionThing = C0xFF83_THING_EXPLOSION_HARM_NON_MATERIAL;
                                        goto T407_014;
                                default:
                                        goto T407_013;
                        }
                case C035_ACTION_FLUXCAGE:
                        F406_xxxx_MENUS_SetChampionDirectionToPartyDirection(L1247_ps_Champion);
                        F224_zzzz_GROUP_FluxCageAction(L1251_i_MapX, L1252_i_MapY);
                        break;
                case C043_ACTION_FUSE:
                        F406_xxxx_MENUS_SetChampionDirectionToPartyDirection(L1247_ps_Champion);
                        L1251_i_MapX = G306_i_PartyMapX;
                        L1252_i_MapY = G307_i_PartyMapY;
                        L1251_i_MapX += G233_ai_Graphic559_DirectionToStepEastCount[G308_i_PartyDirection], L1252_i_MapY += G234_ai_Graphic559_DirectionToStepNorthCount[G308_i_PartyDirection];
                        F225_dzzz_GROUP_FuseAction(L1251_i_MapX, L1252_i_MapY);
                        break;
                case C036_ACTION_HEAL:
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_17_IMPROVEMENT
Healing amount is Min(Abs(Maximum health - Current health), Random(Min(10, Heal skill level) + 5)). Maximum healing amount is 15 which is very small in later stages of the game.
Mana cost is ((16 - Min(10, Heal skill level)) * HealingAmount) / 4
Experience gained is 2 if healing does not occurs or 20 if it occurs */
                        A1246_i_HealingCapability = F024_aatz_MAIN_GetMinimumValue(10, F303_AA09_CHAMPION_GetSkillLevel(P787_i_ChampionIndex, C13_SKILL_HEAL));
                        A1250_i_HealingAmount = F024_aatz_MAIN_GetMinimumValue(F023_aarz_MAIN_GetAbsoluteValue(L1247_ps_Champion->MaximumHealth - L1247_ps_Champion->CurrentHealth), M02_RANDOM(A1246_i_HealingCapability + 5));
                        L1255_i_ActionExperienceGain = 2;
                        while (A1250_i_HealingAmount && ((A1244_ui_ManaCost = (((16 - A1246_i_HealingCapability) * A1250_i_HealingAmount) >> 2)) > L1247_ps_Champion->CurrentMana)) {
                                A1250_i_HealingAmount--; /* Decrease healing amount until the champion has enough mana for the healing */
                        }
                        if (A1250_i_HealingAmount) {
                                L1247_ps_Champion->CurrentHealth += A1250_i_HealingAmount; /* Heal an amount between 5 and 15 */
                                L1247_ps_Champion->CurrentMana -= A1244_ui_ManaCost;
                                M08_SET(L1247_ps_Champion->Attributes, MASK0x0100_STATISTICS);
                                A1245_B_ActionPerformed = TRUE;
                                L1255_i_ActionExperienceGain = 20;
                        }
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_17_IMPROVEMENT Heal action is much more effective
Heal cycles occur as long as the champion has missing health and enough mana. Cycle count = Min(Current Mana / 2, Missing health / Min(10, Heal skill level))
Healing amount is Min(Missing health, Min(10, Heal skill level)) * heal cycle count
Mana cost is 2 * heal cycle count
Experience gain is 2 + 2 * heal cycle count */
                        if (((A1250_i_MissingHealth = L1247_ps_Champion->MaximumHealth - L1247_ps_Champion->CurrentHealth) > 0) && L1247_ps_Champion->CurrentMana) {
                                A1246_i_HealingCapability = F024_aatz_MAIN_GetMinimumValue(10, F303_AA09_CHAMPION_GetSkillLevel(P787_i_ChampionIndex, C13_SKILL_HEAL));
                                L1255_i_ActionExperienceGain = 2;
                                do {
                                        A1244_ui_HealingAmount = F024_aatz_MAIN_GetMinimumValue(A1250_i_MissingHealth, A1246_i_HealingCapability);
                                        L1247_ps_Champion->CurrentHealth += A1244_ui_HealingAmount;
                                        L1255_i_ActionExperienceGain += 2;
                                } while (((L1247_ps_Champion->CurrentMana = L1247_ps_Champion->CurrentMana - 2) > 0) && (A1250_i_MissingHealth = A1250_i_MissingHealth - A1244_ui_HealingAmount));
                                if (L1247_ps_Champion->CurrentMana < 0) {
                                        L1247_ps_Champion->CurrentMana = 0;
                                }
                                M08_SET(L1247_ps_Champion->Attributes, MASK0x0100_STATISTICS);
                                A1245_B_ActionPerformed = TRUE;
                        }
#endif
                        break;
                case C039_ACTION_WINDOW:
                        A1246_i_Ticks = M02_RANDOM(F303_AA09_CHAMPION_GetSkillLevel(P787_i_ChampionIndex, L1254_i_ActionSkillIndex) + 8) + 5;
                        L1258_s_Event.A.A.Priority = 0;
                        L1258_s_Event.A.A.Type = C73_EVENT_THIEVES_EYE;
                        M33_SET_MAP_AND_TIME(L1258_s_Event.Map_Time, G309_i_PartyMapIndex, G313_ul_GameTime + A1246_i_Ticks);
                        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L1258_s_Event);
                        G407_s_Party.Event73Count_ThievesEye++;
                        goto T407_076;
                case C010_ACTION_CLIMB_DOWN:
                        L1251_i_MapX = G306_i_PartyMapX;
                        L1252_i_MapY = G307_i_PartyMapY;
                        L1251_i_MapX += G233_ai_Graphic559_DirectionToStepEastCount[G308_i_PartyDirection], L1252_i_MapY += G234_ai_Graphic559_DirectionToStepNorthCount[G308_i_PartyDirection];
#ifdef C05_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR /* CHANGE6_00_FIX */
                        if (M34_SQUARE_TYPE(F151_rzzz_DUNGEON_GetSquare(L1251_i_MapX, L1252_i_MapY)) == C02_ELEMENT_PIT) { /* BUG0_56 You can climb down a pit with the rope even if there is a group levitating over it */
#endif
#ifdef C25_COMPILE_DM13bFR_CSB20EN_CSB21EN /* CHANGE6_00_FIX The presence of a group over the pit is checked so that you cannot climb down a pit with the rope if there is a group levitating over it */
                        if ((M34_SQUARE_TYPE(F151_rzzz_DUNGEON_GetSquare(L1251_i_MapX, L1252_i_MapY)) == C02_ELEMENT_PIT) && (F175_gzzz_GROUP_GetThing(L1251_i_MapX, L1252_i_MapY) == C0xFFFE_THING_ENDOFLIST)) {
#endif
                                G402_B_UseRopeToClimbDownPit = TRUE;
                                F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(C0xFFFF_THING_PARTY, G306_i_PartyMapX, G307_i_PartyMapY, L1251_i_MapX, L1252_i_MapY);
                                G402_B_UseRopeToClimbDownPit = FALSE;
                        } else {
                                L1249_ui_ActionDisabledTicks = 0;
                        }
                        break;
                case C011_ACTION_FREEZE_LIFE:
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        L1248_ps_Weapon = (WEAPON*)F156_afzz_DUNGEON_GetThingData(L1247_ps_Champion->Slots[C01_SLOT_ACTION_HAND]);
#endif
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_06_FIX Useless code removed */
                        if (((WEAPON*)L1248_ps_Weapon)->Type == C42_JUNK_MAGICAL_BOX_BLUE) {
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_06_FIX Useless code removed */
                        if (L1248_ps_Weapon->Type == C42_JUNK_MAGICAL_BOX_BLUE) {
#endif
                                A1246_i_Ticks = 30;
                                goto T407_071;
                        }
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_06_FIX Useless code removed */
                        if (((WEAPON*)L1248_ps_Weapon)->Type == C43_JUNK_MAGICAL_BOX_GREEN) {
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_06_FIX Useless code removed */
                        if (L1248_ps_Weapon->Type == C43_JUNK_MAGICAL_BOX_GREEN) {
#endif
                                A1246_i_Ticks = 125;
                                T407_071:
                                F300_aozz_CHAMPION_GetObjectRemovedFromSlot(P787_i_ChampionIndex, C01_SLOT_ACTION_HAND);
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_06_FIX Useless code removed */
                                ((WEAPON*)L1248_ps_Weapon)->Next = C0xFFFF_THING_NONE;
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_06_FIX Useless code removed */
                                L1248_ps_Weapon->Next = C0xFFFF_THING_NONE;
#endif
                        } else {
                                A1246_i_Ticks = 70;
                                F405_xxxx_MENUS_DecrementCharges(L1247_ps_Champion);
                        }
                        G407_s_Party.FreezeLifeTicks = F024_aatz_MAIN_GetMinimumValue(200, G407_s_Party.FreezeLifeTicks + A1246_i_Ticks);
                        break;
                case C038_ACTION_LIGHT:
                        G407_s_Party.MagicalLightAmount += G039_ai_Graphic562_LightPowerToLightAmount[2];
                        F404_xxxx_MENUS_CreateEvent70_Light(-2, 2500);
                        T407_076:
                        F405_xxxx_MENUS_DecrementCharges(L1247_ps_Champion);
                        break;
                case C042_ACTION_THROW:
                        F406_xxxx_MENUS_SetChampionDirectionToPartyDirection(L1247_ps_Champion);
                        if (A1245_B_ActionPerformed = F328_nzzz_CHAMPION_IsObjectThrown(P787_i_ChampionIndex, C01_SLOT_ACTION_HAND, (L1247_ps_Champion->Cell == M17_NEXT(G308_i_PartyDirection)) || (L1247_ps_Champion->Cell == M18_OPPOSITE(G308_i_PartyDirection)))) {
                                G370_ps_Events[L1247_ps_Champion->EnableActionEventIndex].B.SlotOrdinal = M00_INDEX_TO_ORDINAL(C01_SLOT_ACTION_HAND);
                        }
        }
        if (L1249_ui_ActionDisabledTicks) {
                F330_szzz_CHAMPION_DisableAction(P787_i_ChampionIndex, L1249_ui_ActionDisabledTicks);
        }
        if (L1253_i_ActionStamina) {
                F325_bzzz_CHAMPION_DecrementStamina(P787_i_ChampionIndex, L1253_i_ActionStamina);
        }
        if (L1255_i_ActionExperienceGain) {
                F304_apzz_CHAMPION_AddSkillExperience(P787_i_ChampionIndex, L1254_i_ActionSkillIndex, L1255_i_ActionExperienceGain);
        }
        F292_arzz_CHAMPION_DrawState(P787_i_ChampionIndex);
        return A1245_B_ActionPerformed;
}

int F408_xxxx_MENUS_GetClickOnSpellCastResult()
{
        register int L1259_i_SpellCastResult;
        register CHAMPION* L1260_ps_Champion;


        L1260_ps_Champion = &G407_s_Party.Champions[G514_i_MagicCasterChampionIndex];
        F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
        F363_pzzz_COMMAND_HighlightBoxDisable();
        if ((L1259_i_SpellCastResult = F412_xxxx_MENUS_GetChampionSpellCastResult(G514_i_MagicCasterChampionIndex)) != C3_SPELL_CAST_FAILURE_NEEDS_FLASK) {
                L1260_ps_Champion->Symbols[0] = '\0';
                F397_xxxx_MENUS_DrawAvailableSymbols(L1260_ps_Champion->SymbolStep = 0);
                F398_xxxx_MENUS_DrawChampionSymbols(L1260_ps_Champion);
        } else {
                L1259_i_SpellCastResult = C0_SPELL_CAST_FAILURE;
        }
        F078_xzzz_MOUSE_ShowPointer();
        return L1259_i_SpellCastResult;
}

SPELL* F409_xxxx_MENUS_GetSpellFromSymbols(P789_puc_Symbols)
register unsigned char* P789_puc_Symbols;
{
        register long L1261_l_Symbols;
        register int L1262_i_Multiple;
#define A1262_i_BitShiftCount L1262_i_Multiple
#define A1262_i_SpellIndex    L1262_i_Multiple
        register SPELL* L1263_ps_Spell;


#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_26_OPTIMIZATION Code deduplication */
        if (!(*(P789_puc_Symbols + 1))) {
                return NULL;
        }
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_26_OPTIMIZATION */
        if (*(P789_puc_Symbols + 1)) {
#endif
                A1262_i_BitShiftCount = 24;
                L1261_l_Symbols = 0;
                do {
                        L1261_l_Symbols |= (long)*P789_puc_Symbols++ << A1262_i_BitShiftCount;
                } while (*P789_puc_Symbols && ((A1262_i_BitShiftCount -= 8) >= 0));
                L1263_ps_Spell = G487_as_Graphic560_Spells;
                A1262_i_SpellIndex = 25;
                while (A1262_i_SpellIndex--) {
                        if (L1263_ps_Spell->Symbols & 0xFF000000) { /* If byte 1 of spell is not 0 then the spell includes the power symbol */
                                if (L1261_l_Symbols == L1263_ps_Spell->Symbols) { /* Compare champion symbols, including power symbol, with spell (never used with actual spells) */
                                        return L1263_ps_Spell;
                                }
                        } else {
                                if ((L1261_l_Symbols & 0x00FFFFFF) == L1263_ps_Spell->Symbols) { /* Compare champion symbols, except power symbol, with spell */
                                        return L1263_ps_Spell;
                                }
                        }
                        L1263_ps_Spell++;
                }
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_26_OPTIMIZATION */
        }
#endif
        return NULL;
}

VOID F410_xxxx_MENUS_PrintSpellFailureMessage(P790_ps_Champion, P791_i_FailureType, P792_ui_SkillIndex)
CHAMPION* P790_ps_Champion;
int P791_i_FailureType;
unsigned int P792_ui_SkillIndex;
{
        register char* L1264_pc_Message;


        if (P792_ui_SkillIndex > C03_SKILL_WIZARD) {
                 P792_ui_SkillIndex = (P792_ui_SkillIndex - 4) / 4;
        }
        F051_AA19_TEXT_MESSAGEAREA_PrintLineFeed();
        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C04_COLOR_CYAN, P790_ps_Champion->Name);
        switch (P791_i_FailureType) {
                case C00_FAILURE_NEEDS_MORE_PRACTICE:
#ifdef C03_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                        L1264_pc_Message = " NEEDS MORE PRACTICE WITH THIS ";
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C04_COLOR_CYAN, L1264_pc_Message);
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C04_COLOR_CYAN, G417_apc_BaseSkillNames[P792_ui_SkillIndex]);
                        L1264_pc_Message = " SPELL.";
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                        L1264_pc_Message = " BRAUCHT MEHR UEBUNG MIT DIESEM ";
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C04_COLOR_CYAN, L1264_pc_Message);
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C04_COLOR_CYAN, G417_apc_BaseSkillNames[P792_ui_SkillIndex]);
                        L1264_pc_Message = " ZAUBERSPRUCH.";
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                        L1264_pc_Message = " DOIT PRATIQUER DAVANTAGE SON ";
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C04_COLOR_CYAN, " DOIT PRATIQUER DAVANTAGE SON "); /* BUG0_01 Coding error without consequence. String litteral used instead of variable L1264_pc_Message. No consequence because the strings are identical */
                        if (P792_ui_SkillIndex == C03_SKILL_WIZARD) { /* French version does not use the same word for Wizard and Priest spells */
                                L1264_pc_Message = "ENVOUTEMENT.";
                        } else {
                                L1264_pc_Message = "EXORCISME.";
                        }
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_07_LOCALIZATION Translation to English language (differences with original Dungeon Master) */
                        L1264_pc_Message = " NEEDS MORE PRACTICE WITH THIS ";
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C04_COLOR_CYAN, " NEEDS MORE PRACTICE WITH THIS "); /* BUG0_01 Coding error without consequence. String litteral used instead of variable L1264_pc_Message. No consequence because the strings are identical */
                        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C04_COLOR_CYAN, G417_apc_BaseSkillNames[P792_ui_SkillIndex]);
                        L1264_pc_Message = " SPELL.";
#endif
                        break;
                case C01_FAILURE_MEANINGLESS_SPELL:
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                        L1264_pc_Message = " MUMBLES A MEANINGLESS SPELL.";
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                        L1264_pc_Message = " MURMELT EINEN SINNLOSEN ZAUBERSPRUCH.";
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                        L1264_pc_Message = " MARMONNE UNE CONJURATION IMCOMPREHENSIBLE.";
#endif
                        break;
                case C10_FAILURE_NEEDS_FLASK_IN_HAND:
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
                        L1264_pc_Message = " NEEDS AN EMPTY FLASK IN HAND FOR POTION.";
#endif
#ifdef C21_COMPILE_DM12GE /* CHANGE4_00_LOCALIZATION Translation to German language */
                        L1264_pc_Message = " MUSS FUER DEN TRANK EINE LEERE FLASCHE BEREITHALTEN.";
#endif
#ifdef C23_COMPILE_DM13aFR_DM13bFR /* CHANGE5_00_LOCALIZATION Translation to French language */
                        L1264_pc_Message = " DOIT AVOIR UN FLACON VIDE EN MAIN POUR LA POTION.";
#endif
        }
        F047_xzzz_TEXT_MESSAGEAREA_PrintMessage(C04_COLOR_CYAN, L1264_pc_Message);
}

POTION* F411_xxxx_MENUS_GetEmptyFlaskInHand(P793_ps_Champion, P794_pT_PotionThing)
register CHAMPION* P793_ps_Champion;
register THING* P794_pT_PotionThing;
{
        register THING L1265_T_Thing;


#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION */
        if (((L1265_T_Thing = P793_ps_Champion->Slots[C01_SLOT_ACTION_HAND]) != C0xFFFF_THING_NONE) && (F033_aaaz_OBJECT_GetIconIndex(L1265_T_Thing) == C195_ICON_POTION_EMPTY_FLASK)) {
                *P794_pT_PotionThing = L1265_T_Thing;
                return &((POTION*)G284_apuc_ThingData[C08_THING_TYPE_POTION])[M13_INDEX(L1265_T_Thing)];
        }
        if (((L1265_T_Thing = P793_ps_Champion->Slots[C00_SLOT_READY_HAND]) != C0xFFFF_THING_NONE) && (F033_aaaz_OBJECT_GetIconIndex(L1265_T_Thing) == C195_ICON_POTION_EMPTY_FLASK)) {
                *P794_pT_PotionThing = L1265_T_Thing;
                return &((POTION*)G284_apuc_ThingData[C08_THING_TYPE_POTION])[M13_INDEX(L1265_T_Thing)];
        }
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls CHANGE2_09_OPTIMIZATION Code deduplication */
        register int L1266_i_SlotIndex;


        L1266_i_SlotIndex = C02_SLOT_HEAD;
        while (--L1266_i_SlotIndex >= C00_SLOT_READY_HAND) {
                if (((L1265_T_Thing = P793_ps_Champion->Slots[L1266_i_SlotIndex]) != C0xFFFF_THING_NONE) && (F033_aaaz_OBJECT_GetIconIndex(L1265_T_Thing) == C195_ICON_POTION_EMPTY_FLASK)) {
                        *P794_pT_PotionThing = L1265_T_Thing;
                        return (POTION*)F156_afzz_DUNGEON_GetThingData(L1265_T_Thing);
                }
        }
#endif
        return NULL;
}

int F412_xxxx_MENUS_GetChampionSpellCastResult(P795_i_ChampionIndex)
register int P795_i_ChampionIndex;
{
        register unsigned int L1267_ui_Multiple;
#define A1267_ui_SkillLevel L1267_ui_Multiple
#define A1267_ui_LightPower L1267_ui_Multiple
#define A1267_ui_SpellPower L1267_ui_Multiple
#define A1267_ui_Ticks      L1267_ui_Multiple
#define A1267_ui_SlotIndex  L1267_ui_Multiple
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_09_OPTIMIZATION Variables reordered. D4 and D5 swapped in DM compared to CSB */
        register unsigned int L1269_ui_Multiple;
#endif
        register int L1268_i_PowerSymbolOrdinal;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_09_OPTIMIZATION Variables reordered. D4 and D5 swapped in DM compared to CSB */
        register unsigned int L1269_ui_Multiple;
#endif
#define A1269_ui_RequiredSkillLevel L1269_ui_Multiple
#define A1269_ui_EmptyFlaskWeight   L1269_ui_Multiple
#define A1269_ui_Ticks              L1269_ui_Multiple
        register CHAMPION* L1270_ps_Champion;
        register SPELL* L1271_ps_Spell;
        THING L1272_T_Object;
        unsigned int L1273_ui_Experience;
        int L1274_i_MissingSkillLevelCount;
        POTION* L1275_ps_Potion;
        EVENT L1276_s_Event;
        JUNK* L1277_ps_Junk;


        if (P795_i_ChampionIndex >= G305_ui_PartyChampionCount) {
                return C0_SPELL_CAST_FAILURE;
        }
        L1270_ps_Champion = &G407_s_Party.Champions[P795_i_ChampionIndex];
        if (!(L1270_ps_Champion->CurrentHealth)) {
                return C0_SPELL_CAST_FAILURE;
        }
        if ((L1271_ps_Spell = F409_xxxx_MENUS_GetSpellFromSymbols(L1270_ps_Champion->Symbols)) == NULL) {
                F410_xxxx_MENUS_PrintSpellFailureMessage(L1270_ps_Champion, C01_FAILURE_MEANINGLESS_SPELL, 0);
                return C0_SPELL_CAST_FAILURE;
        }
        L1268_i_PowerSymbolOrdinal = L1270_ps_Champion->Symbols[0] - '_'; /* Values 1 to 6 */
        L1273_ui_Experience = M03_RANDOM(8) + ((A1269_ui_RequiredSkillLevel = L1271_ps_Spell->BaseRequiredSkillLevel + L1268_i_PowerSymbolOrdinal) << 4) + ((M01_ORDINAL_TO_INDEX(L1268_i_PowerSymbolOrdinal) * L1271_ps_Spell->BaseRequiredSkillLevel) << 3) + (A1269_ui_RequiredSkillLevel * A1269_ui_RequiredSkillLevel);
        A1267_ui_SkillLevel = F303_AA09_CHAMPION_GetSkillLevel(P795_i_ChampionIndex, L1271_ps_Spell->SkillIndex);
        if (A1267_ui_SkillLevel < A1269_ui_RequiredSkillLevel) {
                L1274_i_MissingSkillLevelCount = A1269_ui_RequiredSkillLevel - A1267_ui_SkillLevel;
                while (L1274_i_MissingSkillLevelCount--) {
                        if (M03_RANDOM(128) > F024_aatz_MAIN_GetMinimumValue(L1270_ps_Champion->Statistics[C3_STATISTIC_WISDOM][C1_CURRENT] + 15, 115)) {
                                F304_apzz_CHAMPION_AddSkillExperience(P795_i_ChampionIndex, L1271_ps_Spell->SkillIndex, L1273_ui_Experience >> (A1269_ui_RequiredSkillLevel - A1267_ui_SkillLevel));
                                F410_xxxx_MENUS_PrintSpellFailureMessage(L1270_ps_Champion, C00_FAILURE_NEEDS_MORE_PRACTICE, L1271_ps_Spell->SkillIndex);
                                return C0_SPELL_CAST_FAILURE;
                        }
                }
        }
        switch (M67_SPELL_KIND(L1271_ps_Spell)) {
                case C1_SPELL_KIND_POTION:
                        if ((L1275_ps_Potion = F411_xxxx_MENUS_GetEmptyFlaskInHand(L1270_ps_Champion, &L1272_T_Object)) == NULL) {
                                F410_xxxx_MENUS_PrintSpellFailureMessage(L1270_ps_Champion, C10_FAILURE_NEEDS_FLASK_IN_HAND, 0);
                                return C3_SPELL_CAST_FAILURE_NEEDS_FLASK;
                        }
                        A1269_ui_EmptyFlaskWeight = F140_yzzz_DUNGEON_GetObjectWeight(L1272_T_Object);
                        L1275_ps_Potion->Type = M68_SPELL_TYPE(L1271_ps_Spell);
                        L1275_ps_Potion->Power = M03_RANDOM(16) + (L1268_i_PowerSymbolOrdinal * 40);
                        L1270_ps_Champion->Load += F140_yzzz_DUNGEON_GetObjectWeight(L1272_T_Object) - A1269_ui_EmptyFlaskWeight;
                        F296_aizz_CHAMPION_DrawChangedObjectIcons();
                        if (G423_i_InventoryChampionOrdinal == M00_INDEX_TO_ORDINAL(P795_i_ChampionIndex)) {
                                M08_SET(L1270_ps_Champion->Attributes, MASK0x0200_LOAD);
                                F292_arzz_CHAMPION_DrawState(P795_i_ChampionIndex);
                        }
                        break;
                case C2_SPELL_KIND_PROJECTILE:
                        if (L1270_ps_Champion->Direction != G308_i_PartyDirection) {
                                L1270_ps_Champion->Direction = G308_i_PartyDirection;
                                M08_SET(L1270_ps_Champion->Attributes, MASK0x0400_ICON);
                                F292_arzz_CHAMPION_DrawState(P795_i_ChampionIndex);
                        }
                        if (M68_SPELL_TYPE(L1271_ps_Spell) == C4_SPELL_TYPE_PROJECTILE_OPEN_DOOR) {
                                A1267_ui_SkillLevel <<= 1;
                        }
                        F327_kzzz_CHAMPION_IsProjectileSpellCast(P795_i_ChampionIndex, M68_SPELL_TYPE(L1271_ps_Spell) + C0xFF80_THING_FIRST_EXPLOSION, F026_a003_MAIN_GetBoundedValue(21, (L1268_i_PowerSymbolOrdinal + 2) * (4 + (A1267_ui_SkillLevel << 1)), 255), 0);
                        break;
                case C3_SPELL_KIND_OTHER:
                        L1276_s_Event.A.A.Priority = 0;
                        A1267_ui_SpellPower = (L1268_i_PowerSymbolOrdinal + 1) << 2;
                        switch (M68_SPELL_TYPE(L1271_ps_Spell)) {
                                case C0_SPELL_TYPE_OTHER_LIGHT:
                                        A1269_ui_Ticks = 10000 + ((A1267_ui_SpellPower - 8) << 9);
                                        A1267_ui_LightPower = (A1267_ui_SpellPower >> 1);
                                        A1267_ui_LightPower--;
                                        goto T412_019;
                                case C5_SPELL_TYPE_OTHER_MAGIC_TORCH:
                                        A1269_ui_Ticks = 2000 + ((A1267_ui_SpellPower - 3) << 7);
                                        A1267_ui_LightPower = (A1267_ui_SpellPower >> 2);
                                        A1267_ui_LightPower++;
                                        T412_019:
                                        G407_s_Party.MagicalLightAmount += G039_ai_Graphic562_LightPowerToLightAmount[A1267_ui_LightPower];
                                        F404_xxxx_MENUS_CreateEvent70_Light(-A1267_ui_LightPower, A1269_ui_Ticks);
                                        break;
                                case C1_SPELL_TYPE_OTHER_DARKNESS:
                                        A1267_ui_LightPower = (A1267_ui_SpellPower >> 2);
                                        G407_s_Party.MagicalLightAmount -= G039_ai_Graphic562_LightPowerToLightAmount[A1267_ui_LightPower];
                                        F404_xxxx_MENUS_CreateEvent70_Light(A1267_ui_LightPower, 98);
                                        break;
                                case C2_SPELL_TYPE_OTHER_THIEVES_EYE:
                                        L1276_s_Event.A.A.Type = C73_EVENT_THIEVES_EYE;
                                        G407_s_Party.Event73Count_ThievesEye++;
                                        A1267_ui_SpellPower = (A1267_ui_SpellPower >> 1);
                                        goto T412_032;
                                case C3_SPELL_TYPE_OTHER_INVISIBILITY:
                                        L1276_s_Event.A.A.Type = C71_EVENT_INVISIBILITY;
                                        G407_s_Party.Event71Count_Invisibility++;
                                        goto T412_033;
                                case C4_SPELL_TYPE_OTHER_PARTY_SHIELD:
                                        L1276_s_Event.A.A.Type = C74_EVENT_PARTY_SHIELD;
                                        L1276_s_Event.B.Defense = A1267_ui_SpellPower;
                                        if (G407_s_Party.ShieldDefense > 50) {
                                                L1276_s_Event.B.Defense >>= 2;
                                        }
                                        G407_s_Party.ShieldDefense += L1276_s_Event.B.Defense;
                                        F260_pzzz_TIMELINE_RefreshAllChampionStatusBoxes();
                                        goto T412_032;
                                case C6_SPELL_TYPE_OTHER_FOOTPRINTS:
                                        L1276_s_Event.A.A.Type = C79_EVENT_FOOTPRINTS;
                                        G407_s_Party.Event79Count_Footprints++;
                                        G407_s_Party.FirstScentIndex = G407_s_Party.ScentCount;
                                        if (L1268_i_PowerSymbolOrdinal < 3) {
                                                G407_s_Party.LastScentIndex = G407_s_Party.FirstScentIndex;
                                        } else {
                                                G407_s_Party.LastScentIndex = 0;
                                        }
                                        T412_032:
                                        A1267_ui_Ticks = A1267_ui_SpellPower * A1267_ui_SpellPower;
                                        T412_033:
                                        M33_SET_MAP_AND_TIME(L1276_s_Event.Map_Time, G309_i_PartyMapIndex, G313_ul_GameTime + A1267_ui_Ticks);
                                        F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE(&L1276_s_Event);
                                        break;
                                case C7_SPELL_TYPE_OTHER_ZOKATHRA:
                                        if ((L1272_T_Object = F166_szzz_DUNGEON_GetUnusedThing(C10_THING_TYPE_JUNK)) == C0xFFFF_THING_NONE) {
                                                break;
                                        }
                                        L1277_ps_Junk = (JUNK*)F156_afzz_DUNGEON_GetThingData(L1272_T_Object);
                                        L1277_ps_Junk->Type = C51_JUNK_ZOKATHRA;
                                        if (L1270_ps_Champion->Slots[C00_SLOT_READY_HAND] == C0xFFFF_THING_NONE) {
                                                A1267_ui_SlotIndex = C00_SLOT_READY_HAND;
                                        } else {
                                                if (L1270_ps_Champion->Slots[C01_SLOT_ACTION_HAND] == C0xFFFF_THING_NONE) {
                                                        A1267_ui_SlotIndex = C01_SLOT_ACTION_HAND;
                                                } else {
                                                        A1267_ui_SlotIndex = -1;
                                                }
                                        }
                                        if ((A1267_ui_SlotIndex == C00_SLOT_READY_HAND) || (A1267_ui_SlotIndex == C01_SLOT_ACTION_HAND)) {
                                                F301_apzz_CHAMPION_AddObjectInSlot(P795_i_ChampionIndex, L1272_T_Object, A1267_ui_SlotIndex);
                                                F292_arzz_CHAMPION_DrawState(P795_i_ChampionIndex);
                                        } else {
                                                F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE(L1272_T_Object, CM1_MAPX_NOT_ON_A_SQUARE, 0, G306_i_PartyMapX, G307_i_PartyMapY);
                                        }
                                        break;
                                case C8_SPELL_TYPE_OTHER_FIRESHIELD:
                                        F403_xxxx_MENUS_IsPartySpellOrFireShieldSuccessful(L1270_ps_Champion, FALSE, (A1267_ui_SpellPower * A1267_ui_SpellPower) + 100, FALSE);
                        }
        }
        F304_apzz_CHAMPION_AddSkillExperience(P795_i_ChampionIndex, L1271_ps_Spell->SkillIndex, L1273_ui_Experience);
        F330_szzz_CHAMPION_DisableAction(P795_i_ChampionIndex, M69_SPELL_DURATION(L1271_ps_Spell));
        return C1_SPELL_CAST_SUCCESS;
}
