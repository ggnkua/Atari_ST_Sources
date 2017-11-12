#include "DEFS.H"

overlay "start"

VOID F456_vzzz_START_DrawDisabledMenus()
{
        if (!G300_B_PartyIsSleeping) {
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
                F363_pzzz_COMMAND_HighlightBoxDisable();
                G578_B_UseByteBoxCoordinates = FALSE;
                if (G423_i_InventoryChampionOrdinal) {
#ifdef C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN /* CHANGE8_09_FIX Make sure the chest is always closed */
                        if (G424_i_PanelContent == C4_PANEL_CHEST) {
#endif
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_38_OPTIMIZATION */
                                F347_xxxx_INVENTORY_DrawPanel();
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_38_OPTIMIZATION Function call replaced by an equivalent call. The previous call to F347_xxxx_INVENTORY_DrawPanel() caused the chest to be closed and opened again but only closing is really necessary. Each time F456_vzzz_START_DrawDisabledMenus is called, the panel is overwritten anyway (by the save game dialog, the Sleep screen or the Freeze Game screen) so drawing the chest contents is not necessary */
                                F334_akzz_INVENTORY_CloseChest();
#endif
#ifdef C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN /* CHANGE8_09_FIX */
                        }
#endif
                } else {
                        F136_nzzz_VIDEO_ShadeScreenBox(&G002_s_Graphic562_Box_MovementArrows, C00_COLOR_BLACK);
                }
                F136_nzzz_VIDEO_ShadeScreenBox(&G000_s_Graphic562_Box_SpellArea, C00_COLOR_BLACK);
                F136_nzzz_VIDEO_ShadeScreenBox(&G001_s_Graphic562_Box_ActionArea, C00_COLOR_BLACK);
                F067_aaat_MOUSE_SetPointerToNormal(C0_POINTER_ARROW); /* BUG0_60 On the Reincarnate/Resurrect screen, the 'Arrow' mouse pointer is replaced by the 'Hand' pointer after you grab an object and put it back. After an object is placed in the inventory, the mouse pointer is always set to the 'Hand' without checking if the Reincarnate/Resurrect buttons are on screen. When called by F280_agzz_CHAMPION_AddCandidateChampionToParty this replaces the Hand pointer by the Arrow pointer */
                F078_xzzz_MOUSE_ShowPointer();
        }
}

VOID F457_AA08_START_DrawEnabledMenus_COPYPROTECTIONF()
{
        register int L1462_i_Multiple;
#define A1462_i_MagicCasterChampionIndex L1462_i_Multiple
#define A1462_i_InventoryChampionOrdinal L1462_i_Multiple

        if (G300_B_PartyIsSleeping) {
                F379_jzzz_COMMAND_DrawSleepScreen();
                F097_lzzz_DUNGEONVIEW_DrawViewport(C0_VIEWPORT_NOT_DUNGEON_VIEW);
        } else {
                A1462_i_MagicCasterChampionIndex = G514_i_MagicCasterChampionIndex;
                G514_i_MagicCasterChampionIndex = CM1_CHAMPION_NONE; /* Force next function to draw the spell area */
                F394_ozzz_MENUS_SetMagicCasterAndDrawSpellArea(A1462_i_MagicCasterChampionIndex);
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_10_FIX The variable defining what to draw in the action area is set in the appropriate function */
                if (!G506_i_ActingChampionOrdinal) {
                        G509_B_ActionAreaContainsIcons = TRUE;
                }
#endif
                F387_hzzz_MENUS_DrawActionArea();
                if (A1462_i_InventoryChampionOrdinal = G423_i_InventoryChampionOrdinal) {
                        G423_i_InventoryChampionOrdinal = M00_INDEX_TO_ORDINAL(CM1_CHAMPION_NONE);
                        F355_hzzz_INVENTORY_Toggle_COPYPROTECTIONE(M01_ORDINAL_TO_INDEX(A1462_i_InventoryChampionOrdinal));
                } else {
                        F098_rzzz_DUNGEONVIEW_DrawFloorAndCeiling();
                        F395_pzzz_MENUS_DrawMovementArrows();
                }
                F069_aaaL_MOUSE_SetPointer();
        }
#ifndef NOCOPYPROTECTION
        G328_i_TimeBombToKillParty_COPYPROTECTIONF = 0;
#endif
}

#ifndef NOCOPYPROTECTION
int F458_xxxx_START_GetCommandLineParameters_COPYPROTECTIONA(P866_pc_CommandLineParameters)
char* P866_pc_CommandLineParameters;
{
        register int L1463_i_CommandLineLength;
        register int L1464_i_Character;
        register unsigned char* L1465_puc_CommandLineParameters;


        L1465_puc_CommandLineParameters = _base + 128; /* Address of command line parameters in the process base page */
        L1463_i_CommandLineLength = *L1465_puc_CommandLineParameters++;
        for(L1464_i_Character = 0; L1464_i_Character < L1463_i_CommandLineLength; L1464_i_Character++) {
                P866_pc_CommandLineParameters[L1464_i_Character] = (char)L1465_puc_CommandLineParameters[L1464_i_Character];
        }
        P866_pc_CommandLineParameters[++L1464_i_Character] = '\0';
        return L1463_i_CommandLineLength;
}
#endif

/* Returns the amount of memory required to store a scaled bitmap */
int F459_xxxx_START_GetScaledBitmapByteCount(P867_i_ByteWidth, P868_i_Height, P869_i_Scale)
int P867_i_ByteWidth;
int P868_i_Height;
int P869_i_Scale;
{
        return M77_NORMALIZED_BYTE_WIDTH(M78_SCALED_DIMENSION(P867_i_ByteWidth, P869_i_Scale)) * M78_SCALED_DIMENSION(P868_i_Height, P869_i_Scale);
}

VOID F460_xxxx_START_InitializeGraphicData()
{
        register int L1466_i_Multiple;
#define A1466_i_DoorOrnamentIndex     L1466_i_Multiple
#define A1466_i_ObjectAspectIndex     L1466_i_Multiple
#define A1466_i_ProjectileAspectIndex L1466_i_Multiple
#define A1466_i_ExplosionAspectIndex  L1466_i_Multiple
#define A1466_i_CreatureGraphicInfo   L1466_i_Multiple
        register int L1467_i_Multiple;
#define A1467_i_ProjectileScaleIndex L1467_i_Multiple
#define A1467_i_Scale                L1467_i_Multiple
#define A1467_i_CreatureIndex        L1467_i_Multiple
        register int L1468_i_DerivedBitmapIndex;
        register int L1469_i_BitmapByteCount;
        register OBJECT_ASPECT* L1470_ps_ObjectAspect;
        register CREATURE_ASPECT* L1471_ps_CreatureAspect;
        PROJECTIL_ASPECT* L1472_ps_ProjectileAspect;
        EXPLOSION_ASPECT* L1473_ps_ExplosionAspect;
        int L1474_i_CreatureFrontBitmapD2ByteCount;
        int L1475_i_Multiple;
#define A1475_i_CreatureFrontBitmapD3ByteCount L1475_i_Multiple
#define A1475_i_AdditionalFrontGraphicCount    L1475_i_Multiple


        G085_puc_Bitmap_Ceiling = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(224, 29), C1_ALLOCATION_PERMANENT);
        G084_puc_Bitmap_Floor = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(224, 70), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C13_WALL_BITMAP_WALL_D3L2] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(16, 49), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C14_WALL_BITMAP_WALL_D3R2] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(16, 49), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C12_WALL_BITMAP_WALL_D3LCR] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(128, 51), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C11_WALL_BITMAP_WALL_D2LCR] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(144, 71), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C10_WALL_BITMAP_WALL_D1LCR] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(256, 111), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C09_WALL_BITMAP_WALL_D0L] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(32, 136), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C08_WALL_BITMAP_WALL_D0R] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(32, 136), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C07_WALL_BITMAP_DOOR_FRAME_TOP_D2LCR] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(96, 3), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C06_WALL_BITMAP_DOOR_FRAME_TOP_D1LCR] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(128, 4), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C05_WALL_BITMAP_DOOR_FRAME_LEFT_D3L] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(32, 43), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C04_WALL_BITMAP_DOOR_FRAME_LEFT_D3C] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(32, 44), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C03_WALL_BITMAP_DOOR_FRAME_LEFT_D2C] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(48, 65), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C02_WALL_BITMAP_DOOR_FRAME_LEFT_D1C] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(32, 94), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C00_WALL_BITMAP_DOOR_FRAME_RIGHT_D1C] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(32, 94), C1_ALLOCATION_PERMANENT);
        G088_apuc_Bitmap_WallSet[C01_WALL_BITMAP_DOOR_FRAME_FRONT] = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(32, 123), C1_ALLOCATION_PERMANENT);
        G296_puc_Bitmap_Viewport = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(224, 136), C1_ALLOCATION_PERMANENT);
        G086_puc_Bitmap_ViewportBlackArea = G296_puc_Bitmap_Viewport + M75_BITMAP_BYTE_COUNT(224, 29);
        G087_puc_Bitmap_ViewportFloorArea = G086_puc_Bitmap_ViewportBlackArea + M75_BITMAP_BYTE_COUNT(224, 37);
        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(MASK0x8000_NOT_EXPANDED | C558_GRAPHIC_GLOBAL_VARIABLES, &G229_i_Graphic558Anchor + 1, 0, 0); /* +1 adds two bytes as &G229_i_Graphic558Anchor is pointer to an int */
        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(MASK0x8000_NOT_EXPANDED | C561_GRAPHIC_GLOBAL_VARIABLES, &G479_i_Graphic561Anchor + 1, 0, 0);
        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(MASK0x8000_NOT_EXPANDED | C560_GRAPHIC_GLOBAL_VARIABLES, &G505_i_Graphic560Anchor + 1, 0, 0);
        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(MASK0x8000_NOT_EXPANDED | C559_GRAPHIC_GLOBAL_VARIABLES, &G259_i_Graphic559Anchor + 1, 0, 0);
        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(MASK0x8000_NOT_EXPANDED | C562_GRAPHIC_GLOBAL_VARIABLES, &G067_i_Graphic562Anchor + 1, 0, 0);
        G639_pi_DerivedBitmapByteCount[C000_DERIVED_BITMAP_VIEWPORT] = M75_BITMAP_BYTE_COUNT(224, 136);
        G639_pi_DerivedBitmapByteCount[C001_DERIVED_BITMAP_THIEVES_EYE_VISIBLE_AREA] = M75_BITMAP_BYTE_COUNT(96, 95);
        G639_pi_DerivedBitmapByteCount[C002_DERIVED_BITMAP_DAMAGE_TO_CREATURE_MEDIUM] = M75_BITMAP_BYTE_COUNT(64, 37);
        G639_pi_DerivedBitmapByteCount[C003_DERIVED_BITMAP_DAMAGE_TO_CREATURE_SMALL] = M75_BITMAP_BYTE_COUNT(48, 37);
        /* Prepare two special door ornaments for the two door masks */
        for(A1466_i_DoorOrnamentIndex = C15_DOOR_ORNAMENT_DESTROYED_MASK; A1466_i_DoorOrnamentIndex <= C16_DOOR_ORNAMENT_THIEVES_EYE_MASK; A1466_i_DoorOrnamentIndex++) {
                G103_aai_CurrentMapDoorOrnamentsInfo[A1466_i_DoorOrnamentIndex][C0_NATIVE_BITMAP_INDEX] = A1466_i_DoorOrnamentIndex + (C301_GRAPHIC_FIRST_DOOR_MASK - C15_DOOR_ORNAMENT_DESTROYED_MASK);
                G103_aai_CurrentMapDoorOrnamentsInfo[A1466_i_DoorOrnamentIndex][C1_COORDINATE_SET] = 1;
                G639_pi_DerivedBitmapByteCount[A1466_i_DoorOrnamentIndex * 2 + C068_DERIVED_BITMAP_FIRST_DOOR_ORNAMENT_D3] = M75_BITMAP_BYTE_COUNT(48, 41);
                G639_pi_DerivedBitmapByteCount[A1466_i_DoorOrnamentIndex * 2 + C069_DERIVED_BITMAP_FIRST_DOOR_ORNAMENT_D2] = M75_BITMAP_BYTE_COUNT(64, 61);
        }
        /* Prepare one special floor ornament for the footprints */
        G102_aai_CurrentMapFloorOrnamentsInfo[C15_FLOOR_ORNAMENT_FOOTPRINTS][C0_NATIVE_BITMAP_INDEX] = C241_GRAPHIC_FLOOR_ORNAMENT_15_FOOTPRINTS;
        G102_aai_CurrentMapFloorOrnamentsInfo[C15_FLOOR_ORNAMENT_FOOTPRINTS][C1_COORDINATE_SET] = 1;
        for(A1466_i_ObjectAspectIndex = 0, L1470_ps_ObjectAspect = G209_as_Graphic558_ObjectAspects; A1466_i_ObjectAspectIndex < C085_OBJECT_ASPECT_COUNT; A1466_i_ObjectAspectIndex++, L1470_ps_ObjectAspect++) {
                L1468_i_DerivedBitmapIndex = C104_DERIVED_BITMAP_FIRST_OBJECT + L1470_ps_ObjectAspect->FirstDerivedBitmapRelativeIndex;
                G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = F459_xxxx_START_GetScaledBitmapByteCount(L1470_ps_ObjectAspect->ByteWidth, L1470_ps_ObjectAspect->Height, C16_SCALE_D3);
                G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = F459_xxxx_START_GetScaledBitmapByteCount(L1470_ps_ObjectAspect->ByteWidth, L1470_ps_ObjectAspect->Height, C20_SCALE_D2);
                if (M07_GET(L1470_ps_ObjectAspect->GraphicInfo, MASK0x0001_FLIP_ON_RIGHT)) {
                        G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex] = G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex - 2];
                        L1468_i_DerivedBitmapIndex++;
                        G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex] = G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex - 2];
                        L1468_i_DerivedBitmapIndex++;
                }
                if (M07_GET(L1470_ps_ObjectAspect->GraphicInfo, MASK0x0010_ALCOVE)) {
                        G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex] = G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex - 2];
                        L1468_i_DerivedBitmapIndex++;
                        G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex] = G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex - 2];
                }
        }
        for(A1466_i_ProjectileAspectIndex = 0, L1472_ps_ProjectileAspect = G210_as_Graphic558_ProjectileAspects; A1466_i_ProjectileAspectIndex < C014_PROJECTILE_ASPECT_COUNT; A1466_i_ProjectileAspectIndex++, L1472_ps_ProjectileAspect++) {
                if (!M07_GET(L1472_ps_ProjectileAspect->GraphicInfo, MASK0x0100_SCALE_WITH_KINETIC_ENERGY)) {
                        L1468_i_DerivedBitmapIndex = C282_DERIVED_BITMAP_FIRST_PROJECTILE + L1472_ps_ProjectileAspect->FirstDerivedBitmapRelativeIndex;
                        for(A1467_i_ProjectileScaleIndex = 0; A1467_i_ProjectileScaleIndex < 6; A1467_i_ProjectileScaleIndex++, L1468_i_DerivedBitmapIndex++) {
                                G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex] = (L1469_i_BitmapByteCount = F459_xxxx_START_GetScaledBitmapByteCount(L1472_ps_ProjectileAspect->ByteWidth, L1472_ps_ProjectileAspect->Height, G215_auc_Graphic558_ProjectileScales[A1467_i_ProjectileScaleIndex]));
                                if (M07_GET(L1472_ps_ProjectileAspect->GraphicInfo, MASK0x0003_ASPECT_TYPE) != C3_PROJECTILE_ASPECT_TYPE_NO_BACK_GRAPHIC_AND_NO_ROTATION) {
                                        G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex + 6] = L1469_i_BitmapByteCount;
                                        if (M07_GET(L1472_ps_ProjectileAspect->GraphicInfo, MASK0x0003_ASPECT_TYPE) != C2_PROJECTILE_ASPECT_TYPE_NO_BACK_GRAPHIC_AND_ROTATION) {
                                                G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex + 12] = L1469_i_BitmapByteCount;
                                        }
                                }
                        }
                }
        }
        G075_apuc_PaletteChanges_Projectile[0] = G213_auc_Graphic558_PaletteChanges_FloorOrnament_D3;
        G075_apuc_PaletteChanges_Projectile[1] = G214_auc_Graphic558_PaletteChanges_FloorOrnament_D2;
        G075_apuc_PaletteChanges_Projectile[2] = G075_apuc_PaletteChanges_Projectile[3] = G017_auc_Graphic562_PaletteChanges_NoChanges;
        L1468_i_DerivedBitmapIndex = C438_DERIVED_BITMAP_FIRST_EXPLOSION;
        for(A1466_i_ExplosionAspectIndex = 0, L1473_ps_ExplosionAspect = G211_as_Graphic558_ExplosionAspects; A1466_i_ExplosionAspectIndex < C004_EXPLOSION_ASPECT_COUNT; A1466_i_ExplosionAspectIndex++, L1473_ps_ExplosionAspect++) {
                for(A1467_i_Scale = 4; A1467_i_Scale < 32; A1467_i_Scale += 2) {
                        G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = F459_xxxx_START_GetScaledBitmapByteCount(L1473_ps_ExplosionAspect->ByteWidth, L1473_ps_ExplosionAspect->Height, A1467_i_Scale);
                }
                if (A1466_i_ExplosionAspectIndex == C3_EXPLOSION_ASPECT_SMOKE) {
                        G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = L1473_ps_ExplosionAspect->ByteWidth * L1473_ps_ExplosionAspect->Height;
                }
        }
        L1468_i_DerivedBitmapIndex = C495_DERIVED_BITMAP_FIRST_CREATURE;
        for(A1467_i_CreatureIndex = 0; A1467_i_CreatureIndex < C027_CREATURE_TYPE_COUNT; A1467_i_CreatureIndex++) {
                L1471_ps_CreatureAspect = &G219_as_Graphic558_CreatureAspects[A1467_i_CreatureIndex];
                A1466_i_CreatureGraphicInfo = G243_as_Graphic559_CreatureInfo[A1467_i_CreatureIndex].GraphicInfo;
                L1471_ps_CreatureAspect->FirstDerivedBitmapIndex = L1468_i_DerivedBitmapIndex;
                G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = A1475_i_CreatureFrontBitmapD3ByteCount = F459_xxxx_START_GetScaledBitmapByteCount(L1471_ps_CreatureAspect->ByteWidthFront, L1471_ps_CreatureAspect->HeightFront, C16_SCALE_D3);
                G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = L1474_i_CreatureFrontBitmapD2ByteCount = F459_xxxx_START_GetScaledBitmapByteCount(L1471_ps_CreatureAspect->ByteWidthFront, L1471_ps_CreatureAspect->HeightFront, C20_SCALE_D2);
                if (M07_GET(A1466_i_CreatureGraphicInfo, MASK0x0008_SIDE)) {
                        G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = F459_xxxx_START_GetScaledBitmapByteCount(L1471_ps_CreatureAspect->ByteWidthSide, L1471_ps_CreatureAspect->HeightSide, C16_SCALE_D3);
                        G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = F459_xxxx_START_GetScaledBitmapByteCount(L1471_ps_CreatureAspect->ByteWidthSide, L1471_ps_CreatureAspect->HeightSide, C20_SCALE_D2);
                }
                if (M07_GET(A1466_i_CreatureGraphicInfo, MASK0x0010_BACK)) {
                        G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = A1475_i_CreatureFrontBitmapD3ByteCount;
                        G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = L1474_i_CreatureFrontBitmapD2ByteCount;
                }
                if (M07_GET(A1466_i_CreatureGraphicInfo, MASK0x0020_ATTACK)) {
                        G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = F459_xxxx_START_GetScaledBitmapByteCount(L1471_ps_CreatureAspect->ByteWidthAttack, L1471_ps_CreatureAspect->HeightAttack, C16_SCALE_D3);
                        G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = F459_xxxx_START_GetScaledBitmapByteCount(L1471_ps_CreatureAspect->ByteWidthAttack, L1471_ps_CreatureAspect->HeightAttack, C20_SCALE_D2);
                }
                if (A1475_i_AdditionalFrontGraphicCount = M07_GET(A1466_i_CreatureGraphicInfo, MASK0x0003_ADDITIONAL)) {
                        do {
                                G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = L1471_ps_CreatureAspect->ByteWidthFront * L1471_ps_CreatureAspect->HeightFront;
                                G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = F459_xxxx_START_GetScaledBitmapByteCount(L1471_ps_CreatureAspect->ByteWidthFront, L1471_ps_CreatureAspect->HeightFront, C16_SCALE_D3);
                                G639_pi_DerivedBitmapByteCount[L1468_i_DerivedBitmapIndex++] = F459_xxxx_START_GetScaledBitmapByteCount(L1471_ps_CreatureAspect->ByteWidthFront, L1471_ps_CreatureAspect->HeightFront, C20_SCALE_D2);
                        } while (--A1475_i_AdditionalFrontGraphicCount);
                }
        }
}

VOID F461_AA08_START_AllocateFlippedWallBitmaps()
{
        G090_puc_Bitmap_WallD3LCR_Flipped = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(128, 51), C1_ALLOCATION_PERMANENT);
        G091_puc_Bitmap_WallD2LCR_Flipped = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(144, 71), C1_ALLOCATION_PERMANENT);
        G092_puc_Bitmap_WallD1LCR_Flipped = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(256, 111), C1_ALLOCATION_PERMANENT);
        G093_puc_Bitmap_WallD0L_Flipped = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(32, 136), C1_ALLOCATION_PERMANENT);
        G094_puc_Bitmap_WallD0R_Flipped = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(32, 136), C1_ALLOCATION_PERMANENT);
}

VOID F462_xxxx_START_StartGame_COPYPROTECTIONF()
{
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_39_FIX */
        int L1476_i_GraphicsDatFileReferenceCountBackup;
#endif


        G331_B_PressingEye = FALSE;
        G332_B_StopPressingEye = FALSE;
        G333_B_PressingMouth = FALSE;
        G334_B_StopPressingMouth = FALSE;
        G340_B_HighlightBoxInversionRequested = FALSE;
        G341_B_HighlightBoxEnabled = FALSE;
        G300_B_PartyIsSleeping = FALSE;
#ifndef NOCOPYPROTECTION
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_00_IMPROVEMENT Status variables for COPYPROTECTIONF are now reset each time a game is restarted */
        G069_ui_State_COPYPROTECTIONF = 15;
        G070_B_Sector7Analyzed_COPYPROTECTIONF = FALSE;
        G071_B_Sector7ReadingInitiated_COPYPROTECTIONF = FALSE;
#endif
#endif
        G506_i_ActingChampionOrdinal = M00_INDEX_TO_ORDINAL(CM1_CHAMPION_NONE);
        G509_B_ActionAreaContainsIcons = TRUE;
        G599_ui_UseChampionIconOrdinalAsMousePointerBitmap = M00_INDEX_TO_ORDINAL(CM1_CHAMPION_NONE);
        /* BUG0_61 The game stops with message 'SYSTEM ERROR 60' right after restarting from a saved game. The game manages a watchdog event to detect issues with the timeline processing. Each time the watchdog event expires, a new watchdog event is scheduled to occur 300 ticks later. If at any point the watchdog event time G374_l_WatchdogTime is in the past compared to the current game time G313_ul_GameTime then the game is stopped (in F002_xxxx_MAIN_GameLoop_COPYPROTECTIONDF) with the error message. The issue is that the watchdog event time is not reset when restarting from a saved game so if you restore a game where the current time is in the future compared to the watchdog time then the game stops. How to reproduce:
        - Start a new game and save the game on floppy A. In this saved game, time is for example 250 ticks.
        - Wait for at least 600 ticks (around 2 minutes) and save the game again on floppy B. In this saved game, time is for example 850 ticks.
        - Boot the game and resume the game from floppy A. Game time is restored to 250. Wait a moment then at time = 300, G374_l_WatchdogTime is set to 600.
        - Kill your party (bump in walls or cast Fireballs while facing a wall).
        - On the end screen, click on 'Restart this game' and resume from floppy B. Game time is restored to 850. Because watchdog is still at 600 (not reinitialized to 16777215), as soon as the game loop starts the 'SYSTEM ERROR 60' message is drawn and the game hangs */
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_05_FIX The watchdog event time is reset after the game is restarted */
        G374_l_WatchdogTime = 0x00FFFFFF;
#endif
        G441_ps_PrimaryMouseInput = G447_as_Graphic561_PrimaryMouseInput_Interface;
        G442_ps_SecondaryMouseInput = G448_as_Graphic561_SecondaryMouseInput_Movement;
        G443_ps_PrimaryKeyboardInput = G458_as_Graphic561_PrimaryKeyboardInput_Interface;
        G444_ps_SecondaryKeyboardInput = G459_as_Graphic561_SecondaryKeyboardInput_Movement;
        F003_aaaS_MAIN_ProcessNewPartyMap_COPYPROTECTIONE(G309_i_PartyMapIndex);
        if (!G298_B_NewGame) {
                F008_aA19_MAIN_ClearBytes(G348_pl_Bitmap_LogicalScreenBase, M75_BITMAP_BYTE_COUNT(320, 200));
                F436_xxxx_STARTEND_FadeToPalette(G347_aui_Palette_TopAndBottomScreen);
                F427_xxxx_DIALOG_Draw(NULL, G536_pc_D084_GAMELOADEDREADYTOPLAY, G560_pc_D108_OK, NULL, NULL, NULL, TRUE, TRUE, TRUE);
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_34_OPTIMIZATION */
                F078_xzzz_MOUSE_ShowPointer();
                F424_xxxx_DIALOG_GetChoice(C1_ONE_CHOICE, C1_DIALOG_SET_SCREEN);
                F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_34_OPTIMIZATION */
                F424_xxxx_DIALOG_GetChoice(C1_ONE_CHOICE, C1_DIALOG_SET_SCREEN, C0_USELESS, C0_USELESS);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_39_FIX Close graphics.dat if it is open before calling F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn */
                if (L1476_i_GraphicsDatFileReferenceCountBackup = G631_i_GraphicsDatFileReferenceCount) {
                        G631_i_GraphicsDatFileReferenceCount = 1;
                        F478_gzzz_MEMORY_CloseGraphicsDat_COPYPROTECTIONDF();
                }
#endif
                F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(C0_DO_NOT_FORCE_DIALOG_DM_CSB, TRUE); /* BUG0_62 The game stops with message 'SYSTEM ERROR 41' if the game disk is removed from the floppy disk drive after resuming from a saved game on the entrance screen and before clicking OK in the 'Game loaded, ready to play.' dialog. This occurs because the graphics.dat file is still open at this point and F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn calls F452_xxxx_FLOPPY_GetDiskTypeInDrive_COPYPROTECTIONB which then closes the file and tries to open it again. This does not occur when restarting the game after the party has died because in that case the graphics.dat file is closed at this point so F452_xxxx_FLOPPY_GetDiskTypeInDrive_COPYPROTECTIONB does not have to close it and open it again */
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_39_FIX Reopen graphics.dat if it was open before calling F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn */
                if (L1476_i_GraphicsDatFileReferenceCountBackup) {
                        F477_izzz_MEMORY_OpenGraphicsDat_COPYPROTECTIONDF();
                        G631_i_GraphicsDatFileReferenceCount = L1476_i_GraphicsDatFileReferenceCountBackup;
                }
#endif
                Vsync();
                F008_aA19_MAIN_ClearBytes(G348_pl_Bitmap_LogicalScreenBase, M75_BITMAP_BYTE_COUNT(320, 200));
        } else {
                G578_B_UseByteBoxCoordinates = FALSE;
                Vsync();
                /* Erase everything on screen except the viewport */
                F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G061_s_Graphic562_Box_ScreenTop, C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
                F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G062_s_Graphic562_Box_ScreenRight, C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
                F135_xzzz_VIDEO_FillBox(G348_pl_Bitmap_LogicalScreenBase, &G063_s_Graphic562_Box_ScreenBottom, C00_COLOR_BLACK, C160_BYTE_WIDTH_SCREEN);
        }
        Setpalette(G021_aaui_Graphic562_Palette_DungeonView[0]);
        F395_pzzz_MENUS_DrawMovementArrows();
        F278_apzz_CHAMPION_ResetDataToStartGame();
        G301_B_GameTimeTicking = TRUE;
}

#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_03_IMPROVEMENT Support for two floppy disk drives (Added call to F451_xxxx_FLOPPY_Initialize) CHANGE7_05_OPTIMIZATION Refactored game initialization function. This function and the new version of F448_xxxx_MEMINIT_InitializeMemoryManager_COPYPROTECTIONADEF is equivalent to the older version of F448_xxxx_MEMINIT_InitializeMemoryManager_COPYPROTECTIONADEF. */
VOID F463_wzzz_START_InitializeGame_COPYPROTECTIONADEF()
{
#ifndef NOCOPYPROTECTION
        register BOOLEAN L1477_B_CommandLineParameterIsAUTO_COPYPROTECTIONA;
        char L1478_ac_CommandLineParameters_COPYPROTECTIONA[130];
#endif


        Supexec(&S059_aaac_OS_SetException257Vector_CriticalError);
#ifndef NOCOPYPROTECTION
        F458_xxxx_START_GetCommandLineParameters_COPYPROTECTIONA(L1478_ac_CommandLineParameters_COPYPROTECTIONA);
#endif
        F451_xxxx_FLOPPY_Initialize();
        F448_xxxx_MEMINIT_InitializeMemoryManager_COPYPROTECTIONADEF();
#ifndef NOCOPYPROTECTION
        L1477_B_CommandLineParameterIsAUTO_COPYPROTECTIONA = (L1478_ac_CommandLineParameters_COPYPROTECTIONA[0] == 'A') && (L1478_ac_CommandLineParameters_COPYPROTECTIONA[1] == 'U') && (L1478_ac_CommandLineParameters_COPYPROTECTIONA[2] == 'T') && (L1478_ac_CommandLineParameters_COPYPROTECTIONA[3] == 'O');
#endif
        F479_izzz_MEMORY_ReadGraphicsDatHeader();
        F460_xxxx_START_InitializeGraphicData();
#ifndef NOCOPYPROTECTION
        F447_xxxx_STARTEND_HangIfFalse_COPYPROTECTIONA(L1477_B_CommandLineParameterIsAUTO_COPYPROTECTIONA);
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
}
#endif
