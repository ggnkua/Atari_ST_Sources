#include "DEFS.H"

/*_Global variables_*/
BOX_WORD G000_s_Graphic562_Box_SpellArea;
BOX_WORD G001_s_Graphic562_Box_ActionArea;
BOX_WORD G002_s_Graphic562_Box_MovementArrows;
BOX_WORD G003_s_Graphic562_Box_Title_StrikesBack_Destination;
BOX_WORD G004_s_Graphic562_Box_Title_StrikesBack_Source;
BOX_WORD G005_s_Graphic562_Box_Title_Presents;
BOX_WORD G006_s_Graphic562_Box_Entrance_DungeonView;
BOX_WORD G007_s_Graphic562_Box_Entrance_OpeningDoorLeft;
BOX_WORD G008_s_Graphic562_Box_Entrance_OpeningDoorRight;
BOX_WORD G009_s_Graphic562_Box_Entrance_Doors;
BOX_WORD G010_s_Graphic562_Box_Entrance_ClosedDoorLeft;
BOX_WORD G011_s_Graphic562_Box_Entrance_ClosedDoorRight;
BOX_WORD G012_s_Graphic562_Box_Endgame_TheEnd;
BOX_WORD G013_s_Graphic562_Box_Endgame_Restart_Outer;
BOX_WORD G014_s_Graphic562_Box_Endgame_Restart_Inner;
BOX_WORD G015_s_Graphic562_Box_Endgame_ChampionMirror;
BOX_WORD G016_s_Graphic562_Box_Endgame_ChampionPortrait;
unsigned char G017_auc_Graphic562_PaletteChanges_NoChanges[16];
int G018_ai_Graphic562_MandatoryGraphicIndices[C070_MANDATORY_GRAPHIC_COUNT]; /* Indices of graphics that must always be loaded */
unsigned int G019_aui_Graphic562_Palette_Credits[16];
unsigned int G020_aui_Graphic562_Palette_Entrance[16];
unsigned int G021_aaui_Graphic562_Palette_DungeonView[6][16];
int G022_i_Graphic562_IndirectStopExpiringEvent_COPYPROTECTIONE; /* This variable is necessary even if NOCOPYPROTECTION is defined because a value is loaded for it from graphic #562 */
char G023_aac_Graphic562_OrderedCellsToAttack[8][4];
char G024_ac_Graphic562_WoundProbabilityIndexToWoundMask[4];
char G025_ac_Graphic562_Unreferenced[8]; /* BUG0_00 Useless code. Values 10 11 13 12 10 13 6 13. Maybe slot indices to steal from that was later replaced by G394_auc_StealFromSlotIndices in F193_xxxx_GROUP_StealFromChampion */
int G026_ai_Graphic562_IconGraphicFirstIconIndex[7];
char G027_ac_Graphic562_Unreferenced[4]; /* BUG0_00 Useless code. Values 0 15 0 15. Probably a BOX_BYTE for icon */
BOX_WORD G028_s_Graphic562_Box_LeaderHandObjectName;
unsigned char G029_auc_Graphic562_ChargeCountToTorchType[16];
SLOT_BOX G030_as_Graphic562_SlotBoxes[46]; /* 8 for champion hands in status boxes, 30 for champion inventory, 8 for chest */
int G031_i_Graphic562_Sector7Analyzed_COPYPROTECTIONE; /* This variable is necessary even if NOCOPYPROTECTION is defined because a value is loaded for it from graphic #562 */
BOX_WORD G032_s_Graphic562_Box_Panel;
BOX_WORD G033_s_Graphic562_Box_ArrowOrEye;
BOX_WORD G034_s_Graphic562_Box_ObjectDescriptionCircle;
BOX_WORD G035_s_Graphic562_Box_Food;
BOX_WORD G036_s_Graphic562_Box_Water;
BOX_WORD G037_s_Graphic562_Box_Poisoned;
int G038_ai_Graphic562_SlotMasks[38]; /* 30 for champion inventory, 8 for chest */
int G039_ai_Graphic562_LightPowerToLightAmount[16];
int G040_ai_Graphic562_PaletteIndexToLightAmount[6];
BOX_WORD G041_s_Graphic562_Box_ViewportFloppyZzzCross;
unsigned char G042_auc_Graphic562_Bitmap_ArrowPointer[M75_BITMAP_BYTE_COUNT(16, 16)];
unsigned char G043_auc_Graphic562_Bitmap_HandPointer[M75_BITMAP_BYTE_COUNT(16, 16)];
unsigned char G044_auc_Graphic562_PaletteChanges_MousePointerIcon[16];
unsigned char G045_auc_Graphic562_PaletteChanges_MousePointerIconShadow[16];
unsigned char G046_auc_Graphic562_ChampionColor[4];
BOX_BYTE G047_s_Graphic562_Box_ChampionPortrait;
BOX_WORD G048_s_Graphic562_Box_Mouth;
BOX_WORD G049_s_Graphic562_Box_Eye;
unsigned char G050_auc_Graphic562_WoundDefenseFactor[6];
char G051_ac_Graphic562_UnderscoreCharacterString[2];
char G052_ac_Graphic562_RenameChampionInputCharacterString[2];
char G053_ac_Graphic562_ReincarnateSpecialCharacters[6];
int G054_ai_Graphic562_Box_ChampionIcons[16]; /* Array of 4 boxes */
unsigned int G055_aaaui_Graphic562_BarGraphMasks[4][3][2];
unsigned int G056_aaui_Graphic562_BarGraphByteOffsets[4][3];
int G057_ai_Graphic562_SlotDropOrder[30];
int G058_i_Graphic562_Useless_COPYPROTECTIOND; /* BUG0_00 Useless code. This variable is necessary even if NOCOPYPROTECTION is defined because a value is loaded for it from graphic #562 */
unsigned char G059_auc_Graphic562_SquareTypeToEventType[7]; /* 1 byte of padding inserted by compiler */
SOUND G060_as_Graphic562_Sounds[22];
BOX_WORD G061_s_Graphic562_Box_ScreenTop;
BOX_WORD G062_s_Graphic562_Box_ScreenRight;
BOX_WORD G063_s_Graphic562_Box_ScreenBottom;
long G064_al_Graphic562_PrintTextMasks2[4];
long G065_al_Graphic562_PrintTextMasks1[4];
char G066_ac_Graphic562_LineFeedCharacterString[2];
int G067_i_Graphic562Anchor;
#ifndef NOCOPYPROTECTION
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_04_IMPROVEMENT Additional copy protection to check if fuzzy bits detection has been disabled in COPYPROTECTIONE. This new variable is used for an additional check to detect if code to check COPYPROTECTIONE sector 7 reading has been disabled. It makes sure that the sector 7 reading in COPYPROTECTIONE is checked by either F277_jzzz_COPYPROTECTIONE_IsSector7Valid_FuzzyBits or by hidden code in graphic #21 in the 500 ticks following the last event 22 */
int G068_i_CheckLastEvent22Time_COPYPROTECTIONE = C00512_FALSE;
#endif
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_00_IMPROVEMENT */
unsigned int G069_ui_State_COPYPROTECTIONF = 15;
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_00_IMPROVEMENT Status variables for COPYPROTECTIONF are now reset each time a game is restarted in F462_xxxx_START_StartGame_COPYPROTECTIONF */
unsigned int G069_ui_State_COPYPROTECTIONF;
#endif
BOOLEAN G070_B_Sector7Analyzed_COPYPROTECTIONF;
BOOLEAN G071_B_Sector7ReadingInitiated_COPYPROTECTIONF;
unsigned int G072_ui_GraceReadRetryCount_COPYPROTECTIONF;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_10_IMPROVEMENT Additional copy protection to check if fuzzy bits detection has been disabled in COPYPROTECTIONF. This new variable is used for an additional check to ensure that graphic #21 is executed correctly in COPYPROTECTIONF. If not, memory is not freed while drawing the dungeon view and the game will run out of memory */
int G073_i_StopFreeingMemory_COPYPROTECTIONF = C00512_FALSE;
#endif
#endif
unsigned char* G074_puc_Bitmap_Temporary;
unsigned char* G075_apuc_PaletteChanges_Projectile[4];
BOOLEAN G076_B_UseFlippedWallAndFootprintsBitmaps;
BOOLEAN G077_B_DoNotDrawFluxcagesDuringEndgame;
#ifndef NOCOPYPROTECTION
BOOLEAN G078_B_FuzzyBitFound_COPYPROTECTIONF = TRUE;
#endif
int G079_ai_StairsNativeBitmapIndices[C018_STAIRS_GRAPHIC_COUNT];
int G080_aai_DoorNativeBitmapIndices[C003_DOOR_SET_GRAPHIC_COUNT][2];
#ifndef NOCOPYPROTECTION
int G081_ai_FuzzyBits_COPYPROTECTIONF[32];
char G082_ac_CodePatch0_COPYPROTECTIONF[68];
char* G083_apc_Graphic21Result_COPYPROTECTIONF[4] = { &G081_ai_FuzzyBits_COPYPROTECTIONF,
                                                 &G070_B_Sector7Analyzed_COPYPROTECTIONF,
                                                 &G078_B_FuzzyBitFound_COPYPROTECTIONF,
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_10_IMPROVEMENT This value is never used as graphic #21 in DM only refers to the first 3 pointers in the array */
                                                 &G071_B_Sector7ReadingInitiated_COPYPROTECTIONF };
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_10_IMPROVEMENT */
                                                 &G073_i_StopFreeingMemory_COPYPROTECTIONF };
#endif
#endif
unsigned char* G084_puc_Bitmap_Floor;
unsigned char* G085_puc_Bitmap_Ceiling;
unsigned char* G086_puc_Bitmap_ViewportBlackArea;
unsigned char* G087_puc_Bitmap_ViewportFloorArea;
unsigned char* G088_apuc_Bitmap_WallSet[C013_WALL_SET_GRAPHIC_COUNT + 2]; /* 13 bitmaps from graphics.dat and 2 additional flipped bitmaps */
#ifndef NOCOPYPROTECTION
char G089_ac_CodePatch1_COPYPROTECTIONF[68];
#endif
unsigned char* G090_puc_Bitmap_WallD3LCR_Flipped;
unsigned char* G091_puc_Bitmap_WallD2LCR_Flipped;
unsigned char* G092_puc_Bitmap_WallD1LCR_Flipped;
unsigned char* G093_puc_Bitmap_WallD0L_Flipped;
unsigned char* G094_puc_Bitmap_WallD0R_Flipped;
unsigned char* G095_puc_Bitmap_WallD3LCR_Native;
unsigned char* G096_puc_Bitmap_WallD2LCR_Native;
unsigned char* G097_puc_Bitmap_WallD1LCR_Native;
unsigned char* G098_puc_Bitmap_WallD0L_Native;
unsigned char* G099_puc_Bitmap_WallD0R_Native;
#ifndef NOCOPYPROTECTION
char G100_ac_CodePatch2_COPYPROTECTIONF[68];
#endif
int G101_aai_CurrentMapWallOrnamentsInfo[16][2];
int G102_aai_CurrentMapFloorOrnamentsInfo[16][2]; /* For each possible ornament (+ footprints): Graphic # and Coordinate set) */
int G103_aai_CurrentMapDoorOrnamentsInfo[17][2]; /* For each possible ornament (+ masks for broken door and hole in door): Graphic # and Coordinate set) */
#ifndef NOCOPYPROTECTION
char* G104_apc_CodePatches_COPYPROTECTIONF[3] = { &G082_ac_CodePatch0_COPYPROTECTIONF,
                                                  &G089_ac_CodePatch1_COPYPROTECTIONF,
                                                  &G100_ac_CodePatch2_COPYPROTECTIONF };
#endif
BOX_BYTE G105_s_Graphic558_Box_ExplosionPattern_D0C; /* This is the full dungeon view */
BOX_BYTE G106_s_Graphic558_Box_ThievesEye_ViewportVisibleArea;
BOX_BYTE G107_s_Graphic558_Box_ThievesEye_VisibleArea;
BOX_BYTE G108_s_Graphic558_Box_ThievesEye_HoleInDoorFrame;
BOX_BYTE G109_s_Graphic558_Box_ChampionPortraitOnWall;
FRAME G110_s_Graphic558_Frame_StairsUpFront_D3L;
FRAME G111_s_Graphic558_Frame_StairsUpFront_D3C;
FRAME G112_s_Graphic558_Frame_StairsUpFront_D3R;
FRAME G113_s_Graphic558_Frame_StairsUpFront_D2L;
FRAME G114_s_Graphic558_Frame_StairsUpFront_D2C;
FRAME G115_s_Graphic558_Frame_StairsUpFront_D2R;
FRAME G116_s_Graphic558_Frame_StairsUpFront_D1L;
FRAME G117_s_Graphic558_Frame_StairsUpFront_D1C;
FRAME G118_s_Graphic558_Frame_StairsUpFront_D1R;
FRAME G119_s_Graphic558_Frame_StairsUpFront_D0L;
FRAME G120_s_Graphic558_Frame_StairsUpFront_D0R;
FRAME G121_s_Graphic558_Frame_StairsDownFront_D3L;
FRAME G122_s_Graphic558_Frame_StairsDownFront_D3C;
FRAME G123_s_Graphic558_Frame_StairsDownFront_D3R;
FRAME G124_s_Graphic558_Frame_StairsDownFront_D2L;
FRAME G125_s_Graphic558_Frame_StairsDownFront_D2C;
FRAME G126_s_Graphic558_Frame_StairsDownFront_D2R;
FRAME G127_s_Graphic558_Frame_StairsDownFront_D1L;
FRAME G128_s_Graphic558_Frame_StairsDownFront_D1C;
FRAME G129_s_Graphic558_Frame_StairsDownFront_D1R;
FRAME G130_s_Graphic558_Frame_StairsDownFront_D0L;
FRAME G131_s_Graphic558_Frame_StairsDownFront_D0R;
FRAME G132_s_Graphic558_Frame_StairsSide_D2L;
FRAME G133_s_Graphic558_Frame_StairsSide_D2R;
FRAME G134_s_Graphic558_Frame_StairsUpSide_D1L;
FRAME G135_s_Graphic558_Frame_StairsUpSide_D1R;
FRAME G136_s_Graphic558_Frame_StairsDownSide_D1L;
FRAME G137_s_Graphic558_Frame_StairsDownSide_D1R;
FRAME G138_s_Graphic558_Frame_StairsSide_D0L;
FRAME G139_s_Graphic558_Frame_StairsSide_D0R;
FRAME G140_s_Graphic558_Frame_FloorPit_D3L;
FRAME G141_s_Graphic558_Frame_FloorPit_D3C;
FRAME G142_s_Graphic558_Frame_FloorPit_D3R;
FRAME G143_s_Graphic558_Frame_FloorPit_D2L;
FRAME G144_s_Graphic558_Frame_FloorPit_D2C;
FRAME G145_s_Graphic558_Frame_FloorPit_D2R;
FRAME G146_s_Graphic558_Frame_FloorPit_D1L;
FRAME G147_s_Graphic558_Frame_FloorPit_D1C;
FRAME G148_s_Graphic558_Frame_FloorPit_D1R;
FRAME G149_s_Graphic558_Frame_FloorPit_D0L;
FRAME G150_s_Graphic558_Frame_FloorPit_D0C;
FRAME G151_s_Graphic558_Frame_FloorPit_D0R;
FRAME G152_s_Graphic558_Frame_CeilingPit_D2L;
FRAME G153_s_Graphic558_Frame_CeilingPit_D2C;
FRAME G154_s_Graphic558_Frame_CeilingPit_D2R;
FRAME G155_s_Graphic558_Frame_CeilingPit_D1L;
FRAME G156_s_Graphic558_Frame_CeilingPit_D1C;
FRAME G157_s_Graphic558_Frame_CeilingPit_D1R;
FRAME G158_s_Graphic558_Frame_CeilingPit_D0L;
FRAME G159_s_Graphic558_Frame_CeilingPit_D0C;
FRAME G160_s_Graphic558_Frame_CeilingPit_D0R;
BOX_BYTE G161_s_Graphic558_Box_WallBitmap_D3LCR;
BOX_BYTE G162_s_Graphic558_Box_WallBitmap_D2LCR;
FRAME G163_as_Graphic558_Frame_Walls[14];
FRAME G164_s_Graphic558_Frame_DoorFrameLeft_D3L;
FRAME G165_s_Graphic558_Frame_DoorFrameRight_D3R;
FRAME G166_s_Graphic558_Frame_DoorFrameLeft_D3C;
FRAME G167_s_Graphic558_Frame_DoorFrameRight_D3C;
FRAME G168_s_Graphic558_Frame_DoorFrameLeft_D2C;
FRAME G169_s_Graphic558_Frame_DoorFrameRight_D2C;
FRAME G170_s_Graphic558_Frame_DoorFrameLeft_D1C;
FRAME G171_s_Graphic558_Frame_DoorFrameRight_D1C;
FRAME G172_s_Graphic558_Frame_DoorFrame_D0C;
FRAME G173_s_Graphic558_Frame_DoorFrameTop_D2L;
FRAME G174_s_Graphic558_Frame_DoorFrameTop_D2C;
FRAME G175_s_Graphic558_Frame_DoorFrameTop_D2R;
FRAME G176_s_Graphic558_Frame_DoorFrameTop_D1L;
FRAME G177_s_Graphic558_Frame_DoorFrameTop_D1C;
FRAME G178_s_Graphic558_Frame_DoorFrameTop_D1R;
DOOR_FRAMES G179_s_Graphic558_Frames_Door_D3L;
DOOR_FRAMES G180_s_Graphic558_Frames_Door_D3C;
DOOR_FRAMES G181_s_Graphic558_Frames_Door_D3R;
DOOR_FRAMES G182_s_Graphic558_Frames_Door_D2L;
DOOR_FRAMES G183_s_Graphic558_Frames_Door_D2C;
DOOR_FRAMES G184_s_Graphic558_Frames_Door_D2R;
DOOR_FRAMES G185_s_Graphic558_Frames_Door_D1L;
DOOR_FRAMES G186_s_Graphic558_Frames_Door_D1C;
DOOR_FRAMES G187_s_Graphic558_Frames_Door_D1R;
FIELD_ASPECT G188_as_Graphic558_FieldAspects[12];
int G189_i_Graphic558_StopAddingEvents_COPYPROTECTIONE; /* This variable is necessary even if NOCOPYPROTECTION is defined because a value is loaded for it from graphic #558 */
unsigned char G190_auc_Graphic558_WallOrnamentDerivedBitmapIndexIncrement[12];
unsigned char G191_auc_Graphic558_FloorOrnamentNativeBitmapIndexIncrements[9];
unsigned char G192_auc_Graphic558_AlcoveOrnamentIndices[C003_ALCOVE_ORNAMENT_COUNT];
int G193_ai_Graphic558_FountainOrnamentIndices[C001_FOUNTAIN_ORNAMENT_COUNT];
unsigned char G194_auc_Graphic558_WallOrnamentCoordinateSetIndices[60];
unsigned char G195_auc_Graphic558_FloorOrnamentCoordinateSetIndices[9];
unsigned char G196_auc_Graphic558_DoorOrnamentCoordinateSetIndices[12];
unsigned char G197_auc_Graphic558_DoorButtonCoordinateSet[1];
unsigned char G198_auc_Graphic558_PaletteChanges_DoorButtonAndWallOrnament_D3[16];
unsigned char G199_auc_Graphic558_PaletteChanges_DoorButtonAndWallOrnament_D2[16];
unsigned char G200_auc_Graphic558_PaletteChanges_DoorOrnament_D3[16];
unsigned char G201_auc_Graphic558_PaletteChanges_DoorOrnament_D2[16];
BOX_BYTE G202_ac_Graphic558_Box_WallPatchBehindInscription;
char G203_ac_Graphic558_InscriptionLineY[4];
char G204_ac_Graphic558_UnreadableInscriptionBoxY2[15];
unsigned char G205_aaauc_Graphic558_WallOrnamentCoordinateSets[8][13][6];
unsigned char G206_aaauc_Graphic558_FloorOrnamentCoordinateSets[3][9][6];
unsigned char G207_aaauc_Graphic558_DoorOrnamentCoordinateSets[4][3][6];
unsigned char G208_aaauc_Graphic558_DoorButtonCoordinateSets[1][4][6];
OBJECT_ASPECT G209_as_Graphic558_ObjectAspects[C085_OBJECT_ASPECT_COUNT];
PROJECTIL_ASPECT G210_as_Graphic558_ProjectileAspects[C014_PROJECTILE_ASPECT_COUNT];
EXPLOSION_ASPECT G211_as_Graphic558_ExplosionAspects[C004_EXPLOSION_ASPECT_COUNT];
unsigned char G212_auc_Graphic558_PaletteChanges_Smoke[16];
unsigned char G213_auc_Graphic558_PaletteChanges_FloorOrnament_D3[16];
unsigned char G214_auc_Graphic558_PaletteChanges_FloorOrnament_D2[16];
unsigned char G215_auc_Graphic558_ProjectileScales[7];
unsigned char G216_auc_Graphic558_ExplosionBaseScales[5];
unsigned char G217_aauc_Graphic558_ObjectPileShiftSetIndices[16][2]; /* 16 pairs of X and Y shift values */
unsigned char G218_aaaauc_Graphic558_ObjectCoordinateSets[3][10][5][2];
CREATURE_ASPECT G219_as_Graphic558_CreatureAspects[C027_CREATURE_TYPE_COUNT];
CREATURE_REPLACEMENT_COLOR_SET G220_as_Graphic558_CreatureReplacementColorSets[13];
/* BUG0_04 Some creatures may be drawn with unexpected colors in Dungeon Master
In the color palettes used to draw the dungeon view, two colors (9 and 10) are only used by creature graphics and each creature type can specify replacement colors to use instead of the default colors. Creature types that do not use these colors can specify that no replacement is needed. Each map in the dungeon has an associated list of allowed creature types. If multiple creatures with conflicting color replacements are allowed on the same map then each replacement color is defined by the creature type that appears the last in the list of allowed creature types. There are no such conflicts in Dungeon Master.
However, the side bitmap of 'Giant Wasp' uses color 10 but no replacement is specified. In the game, the actual color used is not the same on all maps where they are present: on map 3 the color is the one defined by 'Magenta Worm', on map 5 it is the color defined by 'Wizard Eye' and on map 10 it is the color defined by 'Water Elemental'.
All bitmaps for 'Swamp Slime' use both colors 9 and 10 but replacement is only specified for color 10. On the map where this creature is used, there are no other creatures defining color 9 so the default color is used which is appropriate. However, this color should be explicitly specified.
The front, side and attack bitmaps for 'Lord Chaos' use color 9 but no replacement is specified. On the map where this creature is used, the colors defined by the Demon are used, which are also appropriate for Lord Chaos. However, these colors should be explicitly specified. Note a unique case for Lord Chaos bitmaps in DM: the palette changes applied when drawing bitmaps at D2 change color 9 to color 10 so this color is also affected by other creatures on the map */
/* BUG7_01 Some creatures may be drawn with unexpected colors in Chaos Strikes Back
In the color palettes used to draw the dungeon view, two colors (9 and 10) are only used by creature graphics and each creature type can specify replacement colors to use instead of the default colors. Creature types that do not use these colors can specify that no replacement is needed. Each map in the dungeon has an associated list of allowed creature types. If multiple creatures with conflicting color replacements are allowed on the same map then each replacement color is defined by the creature type that appears the last in the list of allowed creature types. There are such conflicts in Chaos Strikes Back for 'Worm' which are never drawn with their 'true' colors.
All bitmaps for 'Slime Devil' use both colors 9 and 10 but replacement is only specified for color 10. On the map where this creature is used, there are no other creatures defining color 9 so the default color is used which is appropriate. However, this color should be explicitly specified.
The front, side and attack bitmaps for 'Lord Chaos' use both colors 9 and 10 but no replacements are specified. On the map where this creature is used, the colors defined by the Demon are used, which are also appropriate for Lord Chaos. However, these colors should be explicitly specified.
All bitmaps for 'Hellhound' do not use colors 9 and 10 but it specifies replacements for both, inherited from 'Pain Rat' (DM). On the map where this creature is used, none of the creatures use colors 9 and 10 so this has no consequence. However, these colors should not be specified.
All bitmaps for 'Worm' use both colors 9 and 10 and specify replacements for both colors 9 and 10 but these replacements are still for 'Magenta Worm' (DM). In the game, the actual colors used are not the same on all maps where they are present: on map 0 the colors are defined by 'Demon', on map 9 the colors are defined by 'Dragon' (same colors as 'Demon') and on map 4 color 9 is defined by 'Giant Scorpion' and color 10 is defined by 'Flying Eye'.
The front, side and attack bitmaps for 'Zytaz' use both colors 9 and 10 and specify replacements for both colors 9 and 10 but the replacements are still for the 'Materializer' (DM). They appear with other (and correct) colors in the game only because they were defined by 'Demon'. However, these colors should be explicitly specified */
unsigned char G221_auc_Graphic558_PaletteChanges_Creature_D3[16];
unsigned char G222_auc_Graphic558_PaletteChanges_Creature_D2[16];
char G223_aac_Graphic558_ShiftSets[3][8];
unsigned char G224_aaaauc_Graphic558_CreatureCoordinateSets[3][11][5][2];
int G225_aai_Graphic558_CenteredExplosionCoordinates[15][2];
int G226_aaai_Graphic558_ExplosionCoordinates[15][2][2];
int G227_aai_Graphic558_RebirthStep2ExplosionCoordinates[7][3];
int G228_aai_Graphic558_RebirthStep1ExplosionCoordinates[7][3];
int G229_i_Graphic558Anchor;
int G230_i_CurrentFloorSet = -1;
int G231_i_CurrentWallSet = -1;


overlay "show"

VOID F093_xxxx_DUNGEONVIEW_ApplyCreatureReplacementColors(P096_i_ReplacedColor, P097_i_ReplacementColorSetIndex)
register int P096_i_ReplacedColor;
register int P097_i_ReplacementColorSetIndex;
{
        register int L0069_i_PaletteIndex;


        for(L0069_i_PaletteIndex = 0; L0069_i_PaletteIndex < 6; L0069_i_PaletteIndex++) {
                G021_aaui_Graphic562_Palette_DungeonView[L0069_i_PaletteIndex][P096_i_ReplacedColor] = G220_as_Graphic558_CreatureReplacementColorSets[P097_i_ReplacementColorSetIndex].RGBColor[L0069_i_PaletteIndex];
        }
        G222_auc_Graphic558_PaletteChanges_Creature_D2[P096_i_ReplacedColor] = G220_as_Graphic558_CreatureReplacementColorSets[P097_i_ReplacementColorSetIndex].D2ReplacementColor;
        G221_auc_Graphic558_PaletteChanges_Creature_D3[P096_i_ReplacedColor] = G220_as_Graphic558_CreatureReplacementColorSets[P097_i_ReplacementColorSetIndex].D3ReplacementColor;
}

VOID F094_mzzz_DUNGEONVIEW_LoadFloorSet(P098_i_FloorSet)
register int P098_i_FloorSet;
#define AP098_i_GraphicIndex P098_i_FloorSet
{
        if (G230_i_CurrentFloorSet != P098_i_FloorSet) {
                G230_i_CurrentFloorSet = P098_i_FloorSet;
                AP098_i_GraphicIndex = (P098_i_FloorSet * C002_FLOOR_SET_GRAPHIC_COUNT) + C075_GRAPHIC_FIRST_FLOOR_SET;
                F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(AP098_i_GraphicIndex, G084_puc_Bitmap_Floor, 0, 0);
                F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(AP098_i_GraphicIndex + 1, G085_puc_Bitmap_Ceiling, 0, 0);
        }
}

VOID F095_izzz_DUNGEONVIEW_LoadWallSet(P099_i_WallSet)
register int P099_i_WallSet;
#define AP099_i_GraphicIndex P099_i_WallSet
{
        register int L0070_i_WallSetLastGraphicIndex;
        register unsigned char** L0071_ppuc_Bitmaps;


        if ((G231_i_CurrentWallSet != P099_i_WallSet) || G523_B_RestartGameRequested) {
                G231_i_CurrentWallSet = P099_i_WallSet;
                AP099_i_GraphicIndex = (P099_i_WallSet * C013_WALL_SET_GRAPHIC_COUNT) + C077_GRAPHIC_FIRST_WALL_SET;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_11_OPTIMIZATION Comma removed */
                L0071_ppuc_Bitmaps = &G088_apuc_Bitmap_WallSet[C01_WALL_BITMAP_DOOR_FRAME_FRONT], L0070_i_WallSetLastGraphicIndex = AP099_i_GraphicIndex + C013_WALL_SET_GRAPHIC_COUNT;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_11_OPTIMIZATION Comma removed */
                L0071_ppuc_Bitmaps = &G088_apuc_Bitmap_WallSet[C01_WALL_BITMAP_DOOR_FRAME_FRONT];
                L0070_i_WallSetLastGraphicIndex = AP099_i_GraphicIndex + C013_WALL_SET_GRAPHIC_COUNT;
#endif
                while (AP099_i_GraphicIndex < L0070_i_WallSetLastGraphicIndex) {
                        F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic(AP099_i_GraphicIndex++, *L0071_ppuc_Bitmaps++, 0, 0);
                }
                F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(G088_apuc_Bitmap_WallSet[C02_WALL_BITMAP_DOOR_FRAME_LEFT_D1C], G088_apuc_Bitmap_WallSet[C00_WALL_BITMAP_DOOR_FRAME_RIGHT_D1C], G171_s_Graphic558_Frame_DoorFrameRight_D1C.ByteWidth, G171_s_Graphic558_Frame_DoorFrameRight_D1C.Height);
                F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(G088_apuc_Bitmap_WallSet[C13_WALL_BITMAP_WALL_D3L2], G088_apuc_Bitmap_WallSet[C14_WALL_BITMAP_WALL_D3R2], G163_as_Graphic558_Frame_Walls[C12_VIEW_SQUARE_D3R2].ByteWidth, G163_as_Graphic558_Frame_Walls[C12_VIEW_SQUARE_D3R2].Height);
        }
}

VOID F096_qzzz_DUNGEONVIEW_LoadCurrentMapGraphics_COPYPROTECTIONDF()
{
        register int L0072_i_Multiple;
#define A0072_i_GraphicIndex         L0072_i_Multiple
#define A0072_i_ProjectileAspectType L0072_i_Multiple
#define A0072_i_OrnamentIndex        L0072_i_Multiple
#define A0072_i_CreatureType         L0072_i_Multiple
        register int L0073_i_Multiple;
#define A0073_i_WallSet L0073_i_Multiple
#define A0073_i_Counter L0073_i_Multiple
        register unsigned int L0074_ui_Multiple;
#define A0074_ui_FloorSet                   L0074_ui_Multiple
#define A0074_ui_GraphicIndex               L0074_ui_Multiple
#define A0074_ui_DoorSet                    L0074_ui_Multiple
#define A0074_ui_OrnamentIndex              L0074_ui_Multiple
#define A0074_ui_ReplacementColorSetOrdinal L0074_ui_Multiple
#define A0074_ui_AttackSoundOrdinal         L0074_ui_Multiple
#define A0074_ui_CreatureGraphicInfo        L0074_ui_Multiple
        register unsigned int L0075_ui_Multiple;
#define A0075_ui_WallSet      L0075_ui_Multiple
#define A0075_ui_GraphicCount L0075_ui_Multiple
        register unsigned char* L0076_puc_Multiple;
#define A0076_puc_CoordinateSet L0076_puc_Multiple
#define A0076_puc_CreatureAspect  L0076_puc_Multiple
        register int* L0077_pi_GraphicIndices;
        int* L0078_pi_GraphicIndex;
        unsigned char L0079_auc_DoorSets[2];
        int L0080_i_CreatureTypeIndex;
        BOOLEAN L0081_B_FirstFunctionCallOrSmallHeapMemory;
        int L0082_i_Unreferenced; /* BUG0_00 Useless code */
        int L0083_i_CreatureAdditionalGraphicCount;
        int L0084_i_OrnamentCounter;
        int L0085_i_MapAlcoveGraphicCount;
        int L0086_i_MapFountainGraphicCount;
        BOOLEAN L0087_B_OpenGraphicsDatRequired;
        static BOOLEAN G232_B_FirstFunctionCall = TRUE;


        L0081_B_FirstFunctionCallOrSmallHeapMemory = G232_B_FirstFunctionCall || !G661_B_LargeHeapMemory;
        A0074_ui_FloorSet = G269_ps_CurrentMap->D.FloorSet;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_12_OPTIMIZATION */
        A0075_ui_WallSet = G269_ps_CurrentMap->D.WallSet;
        if (L0087_B_OpenGraphicsDatRequired = (L0081_B_FirstFunctionCallOrSmallHeapMemory || (A0074_ui_FloorSet != G230_i_CurrentFloorSet) || (A0075_ui_WallSet != G231_i_CurrentWallSet))) {
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_12_OPTIMIZATION Use of another variable */
        A0073_i_WallSet = G269_ps_CurrentMap->D.WallSet;
        if (L0087_B_OpenGraphicsDatRequired = (L0081_B_FirstFunctionCallOrSmallHeapMemory || (A0074_ui_FloorSet != G230_i_CurrentFloorSet) || (A0073_i_WallSet != G231_i_CurrentWallSet))) {
#endif
                F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn(C0_DO_NOT_FORCE_DIALOG_DM_CSB, FALSE);
                F477_izzz_MEMORY_OpenGraphicsDat_COPYPROTECTIONDF();
        }
#ifndef NOCOPYPROTECTION
        else {
                while (G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF);
        }
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_13_OPTIMIZATION Code moved and maximum number of loadable graphics updated */
        L0077_pi_GraphicIndices = (int*)F468_ozzz_MEMORY_Allocate((long)(C563_GRAPHIC_COUNT * sizeof(int)), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        F007_aAA7_MAIN_CopyBytes(G018_ai_Graphic562_MandatoryGraphicIndices, L0077_pi_GraphicIndices, sizeof(G018_ai_Graphic562_MandatoryGraphicIndices));
        A0075_ui_GraphicCount = C070_MANDATORY_GRAPHIC_COUNT;
#endif
        F094_mzzz_DUNGEONVIEW_LoadFloorSet(A0074_ui_FloorSet);
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_12_OPTIMIZATION */
        F095_izzz_DUNGEONVIEW_LoadWallSet(A0075_ui_WallSet);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_12_OPTIMIZATION Use of another variable */
        F095_izzz_DUNGEONVIEW_LoadWallSet(A0073_i_WallSet);
#endif
        if (G661_B_LargeHeapMemory) {
                G074_puc_Bitmap_Temporary = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(144, 71), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
                G578_B_UseByteBoxCoordinates = TRUE;
                F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(G095_puc_Bitmap_WallD3LCR_Native = G088_apuc_Bitmap_WallSet[C12_WALL_BITMAP_WALL_D3LCR], G074_puc_Bitmap_Temporary, G163_as_Graphic558_Frame_Walls[C00_VIEW_SQUARE_D3C].ByteWidth, G163_as_Graphic558_Frame_Walls[C00_VIEW_SQUARE_D3C].Height);
                F134_zzzz_VIDEO_FillBitmap(G090_puc_Bitmap_WallD3LCR_Flipped, C10_COLOR_FLESH, M76_BITMAP_UNIT_COUNT(128, 51));
                F132_xzzz_VIDEO_Blit(G074_puc_Bitmap_Temporary, G090_puc_Bitmap_WallD3LCR_Flipped, &G161_s_Graphic558_Box_WallBitmap_D3LCR, 11, 0, C064_BYTE_WIDTH, C064_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
                F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(G096_puc_Bitmap_WallD2LCR_Native = G088_apuc_Bitmap_WallSet[C11_WALL_BITMAP_WALL_D2LCR], G074_puc_Bitmap_Temporary, G163_as_Graphic558_Frame_Walls[C03_VIEW_SQUARE_D2C].ByteWidth, G163_as_Graphic558_Frame_Walls[C03_VIEW_SQUARE_D2C].Height);
                F134_zzzz_VIDEO_FillBitmap(G091_puc_Bitmap_WallD2LCR_Flipped, C10_COLOR_FLESH, M76_BITMAP_UNIT_COUNT(144, 71));
                F132_xzzz_VIDEO_Blit(G074_puc_Bitmap_Temporary, G091_puc_Bitmap_WallD2LCR_Flipped, &G162_s_Graphic558_Box_WallBitmap_D2LCR, 8, 0, C072_BYTE_WIDTH, C072_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
                F469_rzzz_MEMORY_FreeAtHeapTop((long)M75_BITMAP_BYTE_COUNT(144, 71));
                F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(G097_puc_Bitmap_WallD1LCR_Native = G088_apuc_Bitmap_WallSet[C10_WALL_BITMAP_WALL_D1LCR], G092_puc_Bitmap_WallD1LCR_Flipped, G163_as_Graphic558_Frame_Walls[C06_VIEW_SQUARE_D1C].ByteWidth, G163_as_Graphic558_Frame_Walls[C06_VIEW_SQUARE_D1C].Height);
                F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(G098_puc_Bitmap_WallD0L_Native = G088_apuc_Bitmap_WallSet[C09_WALL_BITMAP_WALL_D0L], G094_puc_Bitmap_WallD0R_Flipped, G163_as_Graphic558_Frame_Walls[C10_VIEW_SQUARE_D0L].ByteWidth, G163_as_Graphic558_Frame_Walls[C10_VIEW_SQUARE_D0L].Height);
                F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(G099_puc_Bitmap_WallD0R_Native = G088_apuc_Bitmap_WallSet[C08_WALL_BITMAP_WALL_D0R], G093_puc_Bitmap_WallD0L_Flipped, G163_as_Graphic558_Frame_Walls[C10_VIEW_SQUARE_D0L].ByteWidth, G163_as_Graphic558_Frame_Walls[C10_VIEW_SQUARE_D0L].Height);
        }
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_13_OPTIMIZATION */
        L0077_pi_GraphicIndices = (int*)F468_ozzz_MEMORY_Allocate((long)(C550_LOADABLE_GRAPHIC_COUNT_DM * sizeof(int)), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP);
        F007_aAA7_MAIN_CopyBytes(G018_ai_Graphic562_MandatoryGraphicIndices, L0077_pi_GraphicIndices, sizeof(G018_ai_Graphic562_MandatoryGraphicIndices));
        A0075_ui_GraphicCount = C070_MANDATORY_GRAPHIC_COUNT;
#endif
        if (!G269_ps_CurrentMap->C.CreatureTypeCount || G661_B_LargeHeapMemory) { /* Graphics loaded only if there are no creatures on the map (for the Hall of Champions) or if there is no memory limitation to store all graphics */
                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = C040_GRAPHIC_PANEL_RESURRECT_REINCARNATE;
                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = C026_GRAPHIC_CHAMPION_PORTRAITS;
                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = C027_GRAPHIC_PANEL_RENAME_CHAMPION;
        }
        L0078_pi_GraphicIndex = &G079_ai_StairsNativeBitmapIndices[C17_STAIRS_BITMAP_UP_FRONT_D3L];
        A0073_i_Counter = (G269_ps_CurrentMap->D.WallSet * C018_STAIRS_GRAPHIC_COUNT) + C090_GRAPHIC_FIRST_STAIRS;
        A0072_i_GraphicIndex = A0073_i_Counter + C018_STAIRS_GRAPHIC_COUNT;
        while (A0073_i_Counter < A0072_i_GraphicIndex) {
                if (!G661_B_LargeHeapMemory) { /* If heap memory is small (if large, then all these graphics are added later) */
                        L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0073_i_Counter;
                }
                *(L0078_pi_GraphicIndex--) = A0073_i_Counter++;
        }
        A0072_i_GraphicIndex = C556_GRAPHIC_OBJECT_NAMES;
        if (!G661_B_LargeHeapMemory) {
                A0072_i_GraphicIndex -= 6; /* Do not load the last 6 sounds (creature attack sounds) when available memory is low */
        }
        A0073_i_Counter = C533_GRAPHIC_FIRST_SOUND;
        while (A0073_i_Counter < A0072_i_GraphicIndex) {
                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0073_i_Counter++;
        }
        for(A0073_i_Counter = 0; A0073_i_Counter < C085_OBJECT_ASPECT_COUNT; A0073_i_Counter++) {
                A0074_ui_GraphicIndex = C360_GRAPHIC_FIRST_OBJECT + G209_as_Graphic558_ObjectAspects[A0073_i_Counter].FirstNativeBitmapRelativeIndex;
                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0074_ui_GraphicIndex;
                if (M07_GET(G209_as_Graphic558_ObjectAspects[A0073_i_Counter].GraphicInfo, MASK0x0010_ALCOVE)) {
                        L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0074_ui_GraphicIndex + 1;
                }
        }
        for(A0073_i_Counter = 0; A0073_i_Counter < C014_PROJECTILE_ASPECT_COUNT; A0073_i_Counter++) {
                A0074_ui_GraphicIndex = C316_GRAPHIC_FIRST_PROJECTILE + G210_as_Graphic558_ProjectileAspects[A0073_i_Counter].FirstNativeBitmapRelativeIndex;
                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0074_ui_GraphicIndex;
                if ((A0072_i_ProjectileAspectType = M07_GET(G210_as_Graphic558_ProjectileAspects[A0073_i_Counter].GraphicInfo, MASK0x0003_ASPECT_TYPE)) != C3_PROJECTILE_ASPECT_TYPE_NO_BACK_GRAPHIC_AND_NO_ROTATION) {
                        L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0074_ui_GraphicIndex + 1;
                        if (A0072_i_ProjectileAspectType != C2_PROJECTILE_ASPECT_TYPE_NO_BACK_GRAPHIC_AND_ROTATION) {
                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0074_ui_GraphicIndex + 2;
                        }
                }
        }
        A0073_i_Counter = C348_GRAPHIC_FIRST_EXPLOSION;
        while (A0073_i_Counter < C360_GRAPHIC_FIRST_OBJECT) {
                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0073_i_Counter++;
        }
        L0079_auc_DoorSets[0] = G269_ps_CurrentMap->D.DoorSet0;
        L0079_auc_DoorSets[1] = G269_ps_CurrentMap->D.DoorSet1;
        for(A0074_ui_DoorSet = 0; A0074_ui_DoorSet <= 1; A0074_ui_DoorSet++) {
                L0078_pi_GraphicIndex = &G080_aai_DoorNativeBitmapIndices[C2_DOOR_BITMAP_FRONT_D3LCR][A0074_ui_DoorSet];
                A0073_i_Counter = C108_GRAPHIC_FIRST_DOOR_SET + (L0079_auc_DoorSets[A0074_ui_DoorSet] * C003_DOOR_SET_GRAPHIC_COUNT);
                A0072_i_GraphicIndex = A0073_i_Counter + C003_DOOR_SET_GRAPHIC_COUNT;
                while (A0073_i_Counter < A0072_i_GraphicIndex) {
                        if (!G661_B_LargeHeapMemory) { /* If heap memory is small (if large, then all these graphics are added later) */
                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0073_i_Counter;
                        }
                        *L0078_pi_GraphicIndex = A0073_i_Counter++;
                        L0078_pi_GraphicIndex -= 2;
                }
        }
        F010_aAA7_MAIN_WriteSpacedWords(G267_ai_CurrentMapAlcoveOrnamentIndices, C003_ALCOVE_ORNAMENT_COUNT, -1, sizeof(int));
        F010_aAA7_MAIN_WriteSpacedWords(G268_ai_CurrentMapFountainOrnamentIndices, C001_FOUNTAIN_ORNAMENT_COUNT, -1, sizeof(int));
        L0085_i_MapAlcoveGraphicCount = 0;
        L0086_i_MapFountainGraphicCount = 0;
        G266_i_CurrentMapViAltarWallOrnamentIndex = -1;
        for(A0074_ui_OrnamentIndex = 0; A0074_ui_OrnamentIndex <= G269_ps_CurrentMap->B.WallOrnamentCount; A0074_ui_OrnamentIndex++) {
                A0073_i_Counter = C121_GRAPHIC_FIRST_WALL_ORNAMENT + ((A0072_i_OrnamentIndex = G261_auc_CurrentMapWallOrnamentIndices[A0074_ui_OrnamentIndex]) * 2); /* Each wall ornament has 2 graphics */
                G101_aai_CurrentMapWallOrnamentsInfo[A0074_ui_OrnamentIndex][C0_NATIVE_BITMAP_INDEX] = A0073_i_Counter;
                for(L0084_i_OrnamentCounter = 0; L0084_i_OrnamentCounter < C003_ALCOVE_ORNAMENT_COUNT; L0084_i_OrnamentCounter++) {
                        if (A0072_i_OrnamentIndex == G192_auc_Graphic558_AlcoveOrnamentIndices[L0084_i_OrnamentCounter]) {
                                G267_ai_CurrentMapAlcoveOrnamentIndices[L0085_i_MapAlcoveGraphicCount++] = A0074_ui_OrnamentIndex;
                                if (A0072_i_OrnamentIndex == 2) { /* Wall ornament #2 is the Vi Altar */
                                        G266_i_CurrentMapViAltarWallOrnamentIndex = A0074_ui_OrnamentIndex;
                                }
                        }
                }
                for(L0084_i_OrnamentCounter = 0; L0084_i_OrnamentCounter < C001_FOUNTAIN_ORNAMENT_COUNT; L0084_i_OrnamentCounter++) {
                        if (A0072_i_OrnamentIndex == G193_ai_Graphic558_FountainOrnamentIndices[L0084_i_OrnamentCounter]) {
                                G268_ai_CurrentMapFountainOrnamentIndices[L0086_i_MapFountainGraphicCount++] = A0074_ui_OrnamentIndex;
                        }
                }
                A0076_puc_CoordinateSet = G205_aaauc_Graphic558_WallOrnamentCoordinateSets[G101_aai_CurrentMapWallOrnamentsInfo[A0074_ui_OrnamentIndex][C1_COORDINATE_SET] = G194_auc_Graphic558_WallOrnamentCoordinateSetIndices[A0072_i_OrnamentIndex]][0];
                if (!G661_B_LargeHeapMemory) { /* If heap memory is small (if large, then all these graphics are added later) */
                        L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0073_i_Counter++;
                        L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0073_i_Counter++;
                }
                A0072_i_GraphicIndex = C004_DERIVED_BITMAP_FIRST_WALL_ORNAMENT + (A0074_ui_OrnamentIndex * 4);
                A0073_i_Counter = A0072_i_GraphicIndex;
                A0072_i_GraphicIndex += 4;
                while (A0073_i_Counter < A0072_i_GraphicIndex) {
                        F480_AA07_CACHE_ReleaseBlock(A0073_i_Counter | MASK0x8000_DERIVED_BITMAP);
                        G639_pi_DerivedBitmapByteCount[A0073_i_Counter++] = A0076_puc_CoordinateSet[C4_BYTE_WIDTH] * A0076_puc_CoordinateSet[C5_HEIGHT];
                        A0076_puc_CoordinateSet += ((A0072_i_GraphicIndex - A0073_i_Counter) == 2) ? 18 : 12;
                }
        }
        for(A0074_ui_OrnamentIndex = 0; A0074_ui_OrnamentIndex < G269_ps_CurrentMap->B.FloorOrnamentCount; A0074_ui_OrnamentIndex++) {
                A0073_i_Counter = C247_GRAPHIC_FIRST_FLOOR_ORNAMENT + ((A0072_i_OrnamentIndex = G262_auc_CurrentMapFloorOrnamentIndices[A0074_ui_OrnamentIndex]) * 6);
                G102_aai_CurrentMapFloorOrnamentsInfo[A0074_ui_OrnamentIndex][C0_NATIVE_BITMAP_INDEX] = A0073_i_Counter;
                G102_aai_CurrentMapFloorOrnamentsInfo[A0074_ui_OrnamentIndex][C1_COORDINATE_SET] = G195_auc_Graphic558_FloorOrnamentCoordinateSetIndices[A0072_i_OrnamentIndex];
                if (!G661_B_LargeHeapMemory) { /* If heap memory is small (if large, then all these graphics are added later) */
                        A0072_i_GraphicIndex = A0073_i_Counter + 6;
                        while (A0073_i_Counter < A0072_i_GraphicIndex) {
                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0073_i_Counter++;
                        }
                }
        }
        for(A0074_ui_OrnamentIndex = 0; A0074_ui_OrnamentIndex < G269_ps_CurrentMap->C.DoorOrnamentCount; A0074_ui_OrnamentIndex++) {
                A0073_i_Counter = C303_GRAPHIC_FIRST_DOOR_ORNAMENT + (A0072_i_OrnamentIndex = G263_auc_CurrentMapDoorOrnamentIndices[A0074_ui_OrnamentIndex]);
                G103_aai_CurrentMapDoorOrnamentsInfo[A0074_ui_OrnamentIndex][C0_NATIVE_BITMAP_INDEX] = A0073_i_Counter;
                if (!G661_B_LargeHeapMemory) { /* If heap memory is small (if large, then all these graphics are added later) */
                        L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0073_i_Counter;
                }
                A0076_puc_CoordinateSet = G207_aaauc_Graphic558_DoorOrnamentCoordinateSets[G103_aai_CurrentMapDoorOrnamentsInfo[A0074_ui_OrnamentIndex][C1_COORDINATE_SET] = G196_auc_Graphic558_DoorOrnamentCoordinateSetIndices[A0072_i_OrnamentIndex]][0];
                A0072_i_GraphicIndex = C068_DERIVED_BITMAP_FIRST_DOOR_ORNAMENT_D3 + A0074_ui_OrnamentIndex * 2;
                A0073_i_Counter = A0072_i_GraphicIndex;
                A0072_i_GraphicIndex += 2;
                while (A0073_i_Counter < A0072_i_GraphicIndex) {
                        F480_AA07_CACHE_ReleaseBlock(A0073_i_Counter | MASK0x8000_DERIVED_BITMAP);
                        G639_pi_DerivedBitmapByteCount[A0073_i_Counter++] = A0076_puc_CoordinateSet[C4_BYTE_WIDTH] * A0076_puc_CoordinateSet[C5_HEIGHT];
                        A0076_puc_CoordinateSet += 6;
                }
        }
        for(A0072_i_GraphicIndex = C102_DERIVED_BITMAP_FIRST_DOOR_BUTTON, A0073_i_Counter = 0; A0073_i_Counter < C001_DOOR_BUTTON_COUNT; A0073_i_Counter++) {
                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0073_i_Counter + C315_GRAPHIC_FIRST_DOOR_BUTTON;
                A0076_puc_CoordinateSet = G208_aaauc_Graphic558_DoorButtonCoordinateSets[G197_auc_Graphic558_DoorButtonCoordinateSet[A0073_i_Counter]][1];
                G639_pi_DerivedBitmapByteCount[A0072_i_GraphicIndex++] = A0076_puc_CoordinateSet[C4_BYTE_WIDTH] * A0076_puc_CoordinateSet[C5_HEIGHT];
                A0076_puc_CoordinateSet += 6;
                G639_pi_DerivedBitmapByteCount[A0072_i_GraphicIndex++] = A0076_puc_CoordinateSet[C4_BYTE_WIDTH] * A0076_puc_CoordinateSet[C5_HEIGHT];
        }
        F093_xxxx_DUNGEONVIEW_ApplyCreatureReplacementColors(9, 8); /* Restore the default color #9 */
        F093_xxxx_DUNGEONVIEW_ApplyCreatureReplacementColors(10, 12); /* Restore the default color #10 */
        for(L0080_i_CreatureTypeIndex = 0; L0080_i_CreatureTypeIndex < G269_ps_CurrentMap->C.CreatureTypeCount; L0080_i_CreatureTypeIndex++) {
                A0076_puc_CreatureAspect = (unsigned char*)&G219_as_Graphic558_CreatureAspects[A0072_i_CreatureType = G264_puc_CurrentMapAllowedCreatureTypes[L0080_i_CreatureTypeIndex]];
                if (A0074_ui_ReplacementColorSetOrdinal = M73_COLOR_09_REPLACEMENT_COLOR_SET((CREATURE_ASPECT*)A0076_puc_CreatureAspect)) {
                        F093_xxxx_DUNGEONVIEW_ApplyCreatureReplacementColors(9, M01_ORDINAL_TO_INDEX(A0074_ui_ReplacementColorSetOrdinal));
                }
                if (A0074_ui_ReplacementColorSetOrdinal = M74_COLOR_10_REPLACEMENT_COLOR_SET((CREATURE_ASPECT*)A0076_puc_CreatureAspect)) {
                        F093_xxxx_DUNGEONVIEW_ApplyCreatureReplacementColors(10, M01_ORDINAL_TO_INDEX(A0074_ui_ReplacementColorSetOrdinal));
                }
                if (!G661_B_LargeHeapMemory) { /* If heap memory is small (if large, then all these graphics are added later) */
                        if ((A0074_ui_AttackSoundOrdinal = G243_as_Graphic559_CreatureInfo[A0072_i_CreatureType].AttackSoundOrdinal) && (A0074_ui_AttackSoundOrdinal <= 6)) {
                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0074_ui_AttackSoundOrdinal + C549_GRAPHIC_FIRST_CREATURE_ATTACK_SOUND;
                        }
                        A0073_i_Counter = C446_GRAPHIC_FIRST_CREATURE + ((CREATURE_ASPECT*)A0076_puc_CreatureAspect)->FirstNativeBitmapRelativeIndex;
                        L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0073_i_Counter;
                        A0074_ui_CreatureGraphicInfo = G243_as_Graphic559_CreatureInfo[A0072_i_CreatureType].GraphicInfo;
                        if (M07_GET(A0074_ui_CreatureGraphicInfo, MASK0x0008_SIDE)) {
                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = ++A0073_i_Counter;
                        }
                        if (M07_GET(A0074_ui_CreatureGraphicInfo, MASK0x0010_BACK)) {
                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = ++A0073_i_Counter;
                        }
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_14_FIX Useless code removed */
                        if (M07_GET(A0074_ui_CreatureGraphicInfo, MASK0x0080_SPECIAL_D2_FRONT) && !M07_GET(A0074_ui_CreatureGraphicInfo, MASK0x0100_SPECIAL_D2_FRONT_IS_FLIPPED_FRONT)) { /* BUG0_00 Useless code */
                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = ++A0073_i_Counter;
                        }
#endif
                        if (M07_GET(A0074_ui_CreatureGraphicInfo, MASK0x0020_ATTACK)) {
                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = ++A0073_i_Counter;
                        }
                        if (L0083_i_CreatureAdditionalGraphicCount = M07_GET(A0074_ui_CreatureGraphicInfo, MASK0x0003_ADDITIONAL)) {
                                do {
                                        if (!M07_GET(A0074_ui_CreatureGraphicInfo, MASK0x0004_FLIP_NON_ATTACK)) {
                                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = ++A0073_i_Counter;
                                        }
                                } while (--L0083_i_CreatureAdditionalGraphicCount);
                        }
                }
        }
        if (L0081_B_FirstFunctionCallOrSmallHeapMemory) { /* If this is not the first call to the function and G661_B_LargeHeapMemory = TRUE then all graphics have already been loaded during the first call */
                if (G661_B_LargeHeapMemory) { /* If heap memory is large enough then load all graphics that are not listed in G018_ai_Graphic562_MandatoryGraphicIndices or loaded in all cases */
                        A0074_ui_GraphicIndex = C090_GRAPHIC_FIRST_STAIRS;
                        while (A0074_ui_GraphicIndex < C108_GRAPHIC_FIRST_DOOR_SET) {
                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0074_ui_GraphicIndex++;
                        }
                        A0074_ui_GraphicIndex = C108_GRAPHIC_FIRST_DOOR_SET;
                        while (A0074_ui_GraphicIndex < C120_GRAPHIC_INSCRIPTION_FONT) {
                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0074_ui_GraphicIndex++;
                        }
                        A0074_ui_GraphicIndex = C121_GRAPHIC_FIRST_WALL_ORNAMENT;
                        while (A0074_ui_GraphicIndex < C247_GRAPHIC_FIRST_FLOOR_ORNAMENT) {
                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0074_ui_GraphicIndex++;
                        }
                        A0074_ui_GraphicIndex = C247_GRAPHIC_FIRST_FLOOR_ORNAMENT;
                        while (A0074_ui_GraphicIndex < C301_GRAPHIC_FIRST_DOOR_MASK) {
                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0074_ui_GraphicIndex++;
                        }
                        A0074_ui_GraphicIndex = C303_GRAPHIC_FIRST_DOOR_ORNAMENT;
                        while (A0074_ui_GraphicIndex < C316_GRAPHIC_FIRST_PROJECTILE) {
                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0074_ui_GraphicIndex++;
                        }
                        A0074_ui_GraphicIndex = C446_GRAPHIC_FIRST_CREATURE;
                        while (A0074_ui_GraphicIndex < C533_GRAPHIC_FIRST_SOUND) {
                                L0077_pi_GraphicIndices[A0075_ui_GraphicCount++] = A0074_ui_GraphicIndex++;
                        }
                }
                F484_gzzz_MEMORY_LoadGraphics_COPYPROTECTIONDEF(L0077_pi_GraphicIndices, A0075_ui_GraphicCount);
        }
        if (L0087_B_OpenGraphicsDatRequired) {
                F478_gzzz_MEMORY_CloseGraphicsDat_COPYPROTECTIONDF();
        }
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_13_OPTIMIZATION */
        F469_rzzz_MEMORY_FreeAtHeapTop((long)(C550_LOADABLE_GRAPHIC_COUNT_DM * sizeof(int)));
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_13_OPTIMIZATION */
        F469_rzzz_MEMORY_FreeAtHeapTop((long)(C563_GRAPHIC_COUNT * sizeof(int)));
#endif
        G297_B_DrawFloorAndCeilingRequested = TRUE;
        G342_B_RefreshDungeonViewPaletteRequested = TRUE;
        G232_B_FirstFunctionCall = FALSE;
}

VOID F097_lzzz_DUNGEONVIEW_DrawViewport(P100_i_PaletteSwitchingRequestedState)
int P100_i_PaletteSwitchingRequestedState;
{
        if (P100_i_PaletteSwitchingRequestedState == C2_VIEWPORT_AS_BEFORE_SLEEP_OR_FREEZE_GAME) {
                G323_B_EnablePaletteSwitchingRequested = G322_B_PaletteSwitchingEnabled;
        } else {
                G323_B_EnablePaletteSwitchingRequested = P100_i_PaletteSwitchingRequestedState;
        }
        G324_B_DrawViewportRequested = TRUE; /* This will cause the viewport bitmap in G296_puc_Bitmap_Viewport to be drawn to the screen in E017_xxxx_MAIN_Exception28Handler_VerticalBlank_COPYPROTECTIONDF */
        Vsync(); /* Waits for the next vertical blank exception to make sure the viewport is on screen when the function returns */
}

VOID F098_rzzz_DUNGEONVIEW_DrawFloorAndCeiling()
{
        F008_aA19_MAIN_ClearBytes(G086_puc_Bitmap_ViewportBlackArea, M75_BITMAP_BYTE_COUNT(224, 37));
        F007_aAA7_MAIN_CopyBytes(G085_puc_Bitmap_Ceiling, G296_puc_Bitmap_Viewport, M75_BITMAP_BYTE_COUNT(224, 29));
        F007_aAA7_MAIN_CopyBytes(G084_puc_Bitmap_Floor, G087_puc_Bitmap_ViewportFloorArea, M75_BITMAP_BYTE_COUNT(224, 70));
        G297_B_DrawFloorAndCeilingRequested = FALSE;
}

VOID F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(P101_puc_Bitmap_Source, P102_puc_Bitmap_Destination, P103_ui_ByteWidth, P104_ui_Height)
unsigned char* P101_puc_Bitmap_Source;
unsigned char* P102_puc_Bitmap_Destination;
unsigned int P103_ui_ByteWidth;
unsigned int P104_ui_Height;
{
        F007_aAA7_MAIN_CopyBytes(P101_puc_Bitmap_Source, P102_puc_Bitmap_Destination, P103_ui_ByteWidth * P104_ui_Height);
        F130_xxxx_VIDEO_FlipHorizontal(P102_puc_Bitmap_Destination, P103_ui_ByteWidth, P104_ui_Height);
}

VOID F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(P105_puc_Bitmap, P106_ps_Frame)
unsigned char* P105_puc_Bitmap;
register FRAME* P106_ps_Frame;
{
        if (P106_ps_Frame->ByteWidth) {
                F132_xzzz_VIDEO_Blit(P105_puc_Bitmap, G296_puc_Bitmap_Viewport, P106_ps_Frame, P106_ps_Frame->X, P106_ps_Frame->Y, P106_ps_Frame->ByteWidth, C112_BYTE_WIDTH_VIEWPORT, C10_COLOR_FLESH);
        }
}

#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_15_OPTIMIZATION New function to draw walls in the center of the dungeon view without unnecessary transparency support for better performance */
VOID F101_xxxx_DUNGEONVIEW_DrawWallSetBitmapWithoutTransparency(P107_puc_Bitmap, P108_ps_Frame)
unsigned char* P107_puc_Bitmap;
register FRAME* P108_ps_Frame;
{
        if (P108_ps_Frame->ByteWidth) {
                F132_xzzz_VIDEO_Blit(P107_puc_Bitmap, G296_puc_Bitmap_Viewport, P108_ps_Frame, P108_ps_Frame->X, P108_ps_Frame->Y, P108_ps_Frame->ByteWidth, C112_BYTE_WIDTH_VIEWPORT, CM1_COLOR_NO_TRANSPARENCY);
        }
}
#endif

VOID F102_xxxx_DUNGEONVIEW_DrawDoorBitmap(P109_ps_Frame)
register FRAME* P109_ps_Frame;
{
        if (P109_ps_Frame->ByteWidth) {
                F132_xzzz_VIDEO_Blit(G074_puc_Bitmap_Temporary, G296_puc_Bitmap_Viewport, P109_ps_Frame, P109_ps_Frame->X, P109_ps_Frame->Y, P109_ps_Frame->ByteWidth, C112_BYTE_WIDTH_VIEWPORT, C10_COLOR_FLESH);
        }
}

VOID F103_xxxx_DUNGEONVIEW_DrawDoorFrameBitmapFlippedHorizontally(P110_puc_Bitmap, P111_ps_Frame)
unsigned char* P110_puc_Bitmap;
register FRAME* P111_ps_Frame;
{
        if (P111_ps_Frame->ByteWidth) {
                F130_xxxx_VIDEO_FlipHorizontal(P110_puc_Bitmap, P111_ps_Frame->ByteWidth, P111_ps_Frame->Height);
                F132_xzzz_VIDEO_Blit(P110_puc_Bitmap, G296_puc_Bitmap_Viewport, P111_ps_Frame, P111_ps_Frame->X, P111_ps_Frame->Y, P111_ps_Frame->ByteWidth, C112_BYTE_WIDTH_VIEWPORT, C10_COLOR_FLESH);
        }
}

VOID F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(P112_i_NativeBitmapIndex, P113_ps_Frame)
int P112_i_NativeBitmapIndex;
register FRAME* P113_ps_Frame;
{
        if (P113_ps_Frame->ByteWidth) {
                F132_xzzz_VIDEO_Blit(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(P112_i_NativeBitmapIndex), G296_puc_Bitmap_Viewport, P113_ps_Frame, P113_ps_Frame->X, P113_ps_Frame->Y, P113_ps_Frame->ByteWidth, C112_BYTE_WIDTH_VIEWPORT, C10_COLOR_FLESH);
        }
}

VOID F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(P114_i_NativeBitmapIndex, P115_ps_Frame)
int P114_i_NativeBitmapIndex;
register FRAME* P115_ps_Frame;
{
        if (P115_ps_Frame->ByteWidth) {
                F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(P114_i_NativeBitmapIndex), G074_puc_Bitmap_Temporary, P115_ps_Frame->ByteWidth, P115_ps_Frame->Height);
                F132_xzzz_VIDEO_Blit(G074_puc_Bitmap_Temporary, G296_puc_Bitmap_Viewport, P115_ps_Frame, P115_ps_Frame->X, P115_ps_Frame->Y, P115_ps_Frame->ByteWidth, C112_BYTE_WIDTH_VIEWPORT, C10_COLOR_FLESH);
        }
}

#ifndef NOCOPYPROTECTION
VOID F106_rzzz_DUNGEONVIEW_TestResetToStep1_COPYPROTECTIONF()
{
        if ((G072_ui_GraceReadRetryCount_COPYPROTECTIONF < 5) && !G078_B_FuzzyBitFound_COPYPROTECTIONF) { /* If copy protected sector 7 was read and analyzed and no fuzzy bit was found */
                if (!G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF && !M07_GET(G315_i_SectorsReadFailure_COPYPROTECTIONDF, MASK0x0001_SECTOR7)) { /* If no copy protected sector is being read and sector 7 was read without failure */
                        M08_SET(G315_i_SectorsReadFailure_COPYPROTECTIONDF, MASK0x0001_SECTOR7); /* Set failure flag because no fuzzy bit was found */
                        G072_ui_GraceReadRetryCount_COPYPROTECTIONF++;
                }
                M09_CLEAR(G316_i_SectorsReadPreviousFailure_COPYPROTECTIONDF, MASK0x0001_SECTOR7);
                G069_ui_State_COPYPROTECTIONF = 15; /* Reset COPYPROTECTIONF to state 1 */
                G078_B_FuzzyBitFound_COPYPROTECTIONF = TRUE;
        }
}
#endif

BOOLEAN F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF(P116_i_WallOrnamentOrdinal, P117_i_ViewWallIndex)
register int P116_i_WallOrnamentOrdinal;
#define AP116_i_CharacterCount    P116_i_WallOrnamentOrdinal
#define AP116_i_WallOrnamentIndex P116_i_WallOrnamentOrdinal
register int P117_i_ViewWallIndex;
{
        register int L0088_i_Multiple;
#define A0088_i_NativeBitmapIndex       L0088_i_Multiple
#define A0088_i_UnreadableTextLineCount L0088_i_Multiple
        register int L0089_i_Multiple;
#define A0089_i_WallOrnamentCoordinateSetIndex L0089_i_Multiple
#define A0089_i_FountainOrnamentIndex          L0089_i_Multiple
#define A0089_i_PixelWidth                     L0089_i_Multiple
#define A0089_i_X                              L0089_i_Multiple
        register unsigned char* L0090_puc_Multiple;
#define A0090_puc_String        L0090_puc_Multiple
#define A0090_puc_CoordinateSet L0090_puc_Multiple
        register unsigned char* L0091_puc_Multiple;
#define A0091_puc_Character     L0091_puc_Multiple
#define A0091_puc_Bitmap        L0091_puc_Multiple
#define A0091_puc_CoordinateSet L0091_puc_Multiple
        unsigned char* L0092_puc_Bitmap;
        int L0093_i_CoordinateSetOffset;
        BOOLEAN L0094_B_FlipHorizontal;
        BOOLEAN L0095_B_IsInscription;
        BOOLEAN L0096_B_IsAlcove;
        int L0097_i_TextLineIndex;
        FRAME L0098_s_Frame;
        unsigned char L0099_auc_InscriptionString[70];


        if (P116_i_WallOrnamentOrdinal) {
                P116_i_WallOrnamentOrdinal--;
                A0088_i_NativeBitmapIndex = G101_aai_CurrentMapWallOrnamentsInfo[AP116_i_WallOrnamentIndex][C0_NATIVE_BITMAP_INDEX];
                A0090_puc_CoordinateSet = G205_aaauc_Graphic558_WallOrnamentCoordinateSets[A0089_i_WallOrnamentCoordinateSetIndex = G101_aai_CurrentMapWallOrnamentsInfo[AP116_i_WallOrnamentIndex][C1_COORDINATE_SET]][P117_i_ViewWallIndex];
                L0096_B_IsAlcove = F149_aawz_DUNGEON_IsWallOrnamentAnAlcove(AP116_i_WallOrnamentIndex);
                if (L0095_B_IsInscription = (AP116_i_WallOrnamentIndex == G265_i_CurrentMapInscriptionWallOrnamentIndex)) {
                        F168_ajzz_DUNGEON_DecodeText(L0099_auc_InscriptionString, G290_T_DungeonView_InscriptionThing, C0_TEXT_TYPE_INSCRIPTION);
                }
#ifndef NOCOPYPROTECTION
                F106_rzzz_DUNGEONVIEW_TestResetToStep1_COPYPROTECTIONF(C0_USELESS); /* BUG0_01 Coding error without consequence. Function call with wrong number of parameters. It should be called with 0 parameters. No consequence because additional parameters are ignored */
#endif
                if (P117_i_ViewWallIndex >= C10_VIEW_WALL_D1L_RIGHT) {
                        if (P117_i_ViewWallIndex == C12_VIEW_WALL_D1C_FRONT) {
                                if (L0095_B_IsInscription) {
                                        F132_xzzz_VIDEO_Blit(G088_apuc_Bitmap_WallSet[C10_WALL_BITMAP_WALL_D1LCR], G296_puc_Bitmap_Viewport, &G202_ac_Graphic558_Box_WallPatchBehindInscription, 94, 28, G163_as_Graphic558_Frame_Walls[C06_VIEW_SQUARE_D1C].ByteWidth, C112_BYTE_WIDTH_VIEWPORT, CM1_COLOR_NO_TRANSPARENCY);
                                        A0090_puc_String = L0099_auc_InscriptionString;
                                        L0092_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C120_GRAPHIC_INSCRIPTION_FONT);
                                        L0097_i_TextLineIndex = 0;
                                        do {
                                                AP116_i_CharacterCount = 0;
                                                A0091_puc_Character = A0090_puc_String;
                                                while (*A0091_puc_Character++ < 128) { /* Hexadecimal: 0x80 (Megamax C does not support hexadecimal character constants) */
                                                        AP116_i_CharacterCount++;
                                                }
                                                L0098_s_Frame.Box[C1_X2] = (L0098_s_Frame.Box[C0_X1] = 112 - (AP116_i_CharacterCount << 2)) + 7;
                                                L0098_s_Frame.Box[C2_Y1] = (L0098_s_Frame.Box[C3_Y2] = (unsigned int)(G203_ac_Graphic558_InscriptionLineY[L0097_i_TextLineIndex++])) - 7;
                                                while (AP116_i_CharacterCount--) {
                                                        F132_xzzz_VIDEO_Blit(L0092_puc_Bitmap, G296_puc_Bitmap_Viewport, &L0098_s_Frame, *A0090_puc_String++ << 3, 0, C144_BYTE_WIDTH, C112_BYTE_WIDTH_VIEWPORT, C10_COLOR_FLESH);
                                                        L0098_s_Frame.Box[C0_X1] += 8;
                                                        L0098_s_Frame.Box[C1_X2] += 8;
                                                }
                                        } while (*A0090_puc_String++ != 129); /* Hexadecimal: 0x81 (Megamax C does not support hexadecimal character constants) */
                                        goto T107_031;
                                }
                                A0088_i_NativeBitmapIndex++;
                                F007_aAA7_MAIN_CopyBytes(A0090_puc_CoordinateSet, G291_aauc_DungeonViewClickableBoxes[C05_VIEW_CELL_DOOR_BUTTON_OR_WALL_ORNAMENT], sizeof(G291_aauc_DungeonViewClickableBoxes[C05_VIEW_CELL_DOOR_BUTTON_OR_WALL_ORNAMENT]));
                                G286_B_FacingAlcove = L0096_B_IsAlcove;
                                G287_B_FacingViAltar = 
#ifndef NOCOPYPROTECTION
                                G078_B_FuzzyBitFound_COPYPROTECTIONF &&
#endif
                                (AP116_i_WallOrnamentIndex == G266_i_CurrentMapViAltarWallOrnamentIndex);
                                G288_B_FacingFountain = FALSE;
                                for(A0089_i_FountainOrnamentIndex = 0; A0089_i_FountainOrnamentIndex < C001_FOUNTAIN_ORNAMENT_COUNT; A0089_i_FountainOrnamentIndex++) {
                                        if (G268_ai_CurrentMapFountainOrnamentIndices[A0089_i_FountainOrnamentIndex] == AP116_i_WallOrnamentIndex) {
                                                G288_B_FacingFountain = TRUE;
                                                break;
                                        }
                                }
                        }
                        A0091_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(A0088_i_NativeBitmapIndex);
                        if (P117_i_ViewWallIndex == C11_VIEW_WALL_D1R_LEFT) {
                                F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(A0091_puc_Bitmap, G074_puc_Bitmap_Temporary, A0090_puc_CoordinateSet[C4_BYTE_WIDTH], A0090_puc_CoordinateSet[C5_HEIGHT]);
                                A0091_puc_Bitmap = G074_puc_Bitmap_Temporary;
                        }
                        A0089_i_X = 0;
                } else {
                        L0093_i_CoordinateSetOffset = 0;
                        if (L0094_B_FlipHorizontal = (P117_i_ViewWallIndex == C06_VIEW_WALL_D2R_LEFT) || (P117_i_ViewWallIndex == C01_VIEW_WALL_D3R_LEFT)) {
                                A0091_puc_CoordinateSet = G205_aaauc_Graphic558_WallOrnamentCoordinateSets[A0089_i_WallOrnamentCoordinateSetIndex][C11_VIEW_WALL_D1R_LEFT];
                        } else {
                                if ((P117_i_ViewWallIndex == C05_VIEW_WALL_D2L_RIGHT) || (P117_i_ViewWallIndex == C00_VIEW_WALL_D3L_RIGHT)) {
                                        A0091_puc_CoordinateSet = G205_aaauc_Graphic558_WallOrnamentCoordinateSets[A0089_i_WallOrnamentCoordinateSetIndex][C10_VIEW_WALL_D1L_RIGHT];
                                } else {
                                        A0088_i_NativeBitmapIndex++;
                                        A0091_puc_CoordinateSet = G205_aaauc_Graphic558_WallOrnamentCoordinateSets[A0089_i_WallOrnamentCoordinateSetIndex][C12_VIEW_WALL_D1C_FRONT];
                                        if (P117_i_ViewWallIndex == C07_VIEW_WALL_D2L_FRONT) {
                                                L0093_i_CoordinateSetOffset = 6;
                                        } else {
                                                if (P117_i_ViewWallIndex == C09_VIEW_WALL_D2R_FRONT) {
                                                        L0093_i_CoordinateSetOffset = -6;
                                                }
                                        }
                                }
                        }
                        A0089_i_PixelWidth = (A0090_puc_CoordinateSet + L0093_i_CoordinateSetOffset)[C1_X2] - (A0090_puc_CoordinateSet + L0093_i_CoordinateSetOffset)[C0_X1];
                        if (!F491_xzzz_CACHE_IsDerivedBitmapInCache(AP116_i_WallOrnamentIndex = C004_DERIVED_BITMAP_FIRST_WALL_ORNAMENT + (AP116_i_WallOrnamentIndex << 2) + G190_auc_Graphic558_WallOrnamentDerivedBitmapIndexIncrement[P117_i_ViewWallIndex])) {
                                L0092_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(A0088_i_NativeBitmapIndex);
                                F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(L0092_puc_Bitmap, F492_mzzz_CACHE_GetDerivedBitmap(AP116_i_WallOrnamentIndex), A0091_puc_CoordinateSet[C4_BYTE_WIDTH] << 1, A0091_puc_CoordinateSet[C5_HEIGHT], A0089_i_PixelWidth + 1, A0090_puc_CoordinateSet[C5_HEIGHT], (P117_i_ViewWallIndex <= C04_VIEW_WALL_D3R_FRONT) ? G198_auc_Graphic558_PaletteChanges_DoorButtonAndWallOrnament_D3 : G199_auc_Graphic558_PaletteChanges_DoorButtonAndWallOrnament_D2);
                                F493_hzzz_CACHE_AddDerivedBitmap(AP116_i_WallOrnamentIndex);
                        }
                        A0091_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(AP116_i_WallOrnamentIndex);
                        if (L0094_B_FlipHorizontal) {
                                F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(A0091_puc_Bitmap, G074_puc_Bitmap_Temporary, A0090_puc_CoordinateSet[C4_BYTE_WIDTH], A0090_puc_CoordinateSet[C5_HEIGHT]);
                                A0091_puc_Bitmap = G074_puc_Bitmap_Temporary;
                                A0089_i_X = 15 - (A0089_i_X & 0x000F);
                        } else {
                                if (P117_i_ViewWallIndex == C07_VIEW_WALL_D2L_FRONT) {
                                        A0089_i_X -= A0090_puc_CoordinateSet[C1_X2] - A0090_puc_CoordinateSet[C0_X1];
                                } else {
                                        A0089_i_X = 0;
                                }
                        }
                }
                if (L0095_B_IsInscription) {
                        L0092_puc_Bitmap = A0090_puc_CoordinateSet;
                        A0090_puc_String = L0099_auc_InscriptionString;
                        A0088_i_UnreadableTextLineCount = 0;
                        do {
                                while (*A0090_puc_String < 128) { /* Hexadecimal: 0x80 (Megamax C does not support hexadecimal character constants) */
                                        A0090_puc_String++;
                                }
                                A0088_i_UnreadableTextLineCount++;
                        } while (*A0090_puc_String++ != 129); /* Hexadecimal: 0x81 (Megamax C does not support hexadecimal character constants) */
                        A0090_puc_CoordinateSet = L0092_puc_Bitmap;
                        if (A0088_i_UnreadableTextLineCount < 4) {
                                F007_aAA7_MAIN_CopyBytes(A0090_puc_CoordinateSet, &L0098_s_Frame, sizeof(L0098_s_Frame));
                                A0090_puc_CoordinateSet = &L0098_s_Frame.Box;
                                A0090_puc_CoordinateSet[C3_Y2] = G204_ac_Graphic558_UnreadableInscriptionBoxY2[G190_auc_Graphic558_WallOrnamentDerivedBitmapIndexIncrement[P117_i_ViewWallIndex] * 3 + A0088_i_UnreadableTextLineCount - 1];
                        }
                }
                F132_xzzz_VIDEO_Blit(A0091_puc_Bitmap, G296_puc_Bitmap_Viewport, A0090_puc_CoordinateSet, A0089_i_X, 0, A0090_puc_CoordinateSet[C4_BYTE_WIDTH], C112_BYTE_WIDTH_VIEWPORT, C10_COLOR_FLESH);
                if ((P117_i_ViewWallIndex == C12_VIEW_WALL_D1C_FRONT) && G289_i_DungeonView_ChampionPortraitOrdinal--) { /* BUG0_05 A champion portrait sensor on a wall square is visible on all sides of the wall. If there is another sensor with a wall ornament on one side of the wall then the champion portrait is drawn over that wall ornament */
                        F132_xzzz_VIDEO_Blit(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C026_GRAPHIC_CHAMPION_PORTRAITS), G296_puc_Bitmap_Viewport, &G109_s_Graphic558_Box_ChampionPortraitOnWall, (G289_i_DungeonView_ChampionPortraitOrdinal & 0x0007) << 5, (G289_i_DungeonView_ChampionPortraitOrdinal >> 3) * 29, C128_BYTE_WIDTH, C112_BYTE_WIDTH_VIEWPORT, C01_COLOR_DARK_GRAY); /* A portrait is 32x29 pixels */
                }
                T107_031:
                return L0096_B_IsAlcove;
        }
        return FALSE;
}

VOID F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(P118_i_FloorOrnamentOrdinal, P119_ui_ViewFloorIndex)
register int P118_i_FloorOrnamentOrdinal;
#define AP118_i_FloorOrnamentIndex P118_i_FloorOrnamentOrdinal
register unsigned int P119_ui_ViewFloorIndex;
{
        register int L0100_i_NativeBitmapIndex;
        register BOOLEAN L0101_B_DrawFootprints;
        register unsigned char* L0102_puc_Bitmap;
        register unsigned char* L0103_puc_CoordinateSet;


        if (P118_i_FloorOrnamentOrdinal) {
                if (L0101_B_DrawFootprints = M07_GET(P118_i_FloorOrnamentOrdinal, MASK0x8000_FOOTPRINTS)) {
                        if (!M09_CLEAR(P118_i_FloorOrnamentOrdinal, MASK0x8000_FOOTPRINTS)) {
                                goto T108_005;
                        }
                }
                P118_i_FloorOrnamentOrdinal--;
                L0100_i_NativeBitmapIndex = G102_aai_CurrentMapFloorOrnamentsInfo[AP118_i_FloorOrnamentIndex][C0_NATIVE_BITMAP_INDEX] + G191_auc_Graphic558_FloorOrnamentNativeBitmapIndexIncrements[P119_ui_ViewFloorIndex];
                L0103_puc_CoordinateSet = G206_aaauc_Graphic558_FloorOrnamentCoordinateSets[G102_aai_CurrentMapFloorOrnamentsInfo[AP118_i_FloorOrnamentIndex][C1_COORDINATE_SET]][P119_ui_ViewFloorIndex];
                if ((P119_ui_ViewFloorIndex == C8_VIEW_FLOOR_D1R) || (P119_ui_ViewFloorIndex == C5_VIEW_FLOOR_D2R) || (P119_ui_ViewFloorIndex == C2_VIEW_FLOOR_D3R) || ((AP118_i_FloorOrnamentIndex == C15_FLOOR_ORNAMENT_FOOTPRINTS) && G076_B_UseFlippedWallAndFootprintsBitmaps && ((P119_ui_ViewFloorIndex == C7_VIEW_FLOOR_D1C) || (P119_ui_ViewFloorIndex == C4_VIEW_FLOOR_D2C) || (P119_ui_ViewFloorIndex == C1_VIEW_FLOOR_D3C)))) {
                        F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(L0100_i_NativeBitmapIndex), L0102_puc_Bitmap = G074_puc_Bitmap_Temporary, L0103_puc_CoordinateSet[C4_BYTE_WIDTH], L0103_puc_CoordinateSet[C5_HEIGHT]);
                } else {
                        L0102_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(L0100_i_NativeBitmapIndex);
                }
                F132_xzzz_VIDEO_Blit(L0102_puc_Bitmap, G296_puc_Bitmap_Viewport, L0103_puc_CoordinateSet, 0, 0, L0103_puc_CoordinateSet[C4_BYTE_WIDTH], C112_BYTE_WIDTH_VIEWPORT, C10_COLOR_FLESH);
                T108_005:
                if (L0101_B_DrawFootprints) {
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(M00_INDEX_TO_ORDINAL(C15_FLOOR_ORNAMENT_FOOTPRINTS), P119_ui_ViewFloorIndex);
                }
        }
}

VOID F109_xxxx_DUNGEONVIEW_DrawDoorOrnament(P120_i_DoorOrnamentOrdinal, P121_i_ViewDoorOrnamentIndex)
register int P120_i_DoorOrnamentOrdinal;
register int P121_i_ViewDoorOrnamentIndex;
#define AP121_i_ByteWidth P121_i_ViewDoorOrnamentIndex
{
        register int L0104_i_NativeBitmapIndex;
        register int L0105_i_CoordinateSet;
        register unsigned char* L0106_puc_CoordinateSet;
        register unsigned char* L0107_puc_Multiple;
#define A0107_puc_Bitmap        L0107_puc_Multiple
#define A0107_puc_CoordinateSet L0107_puc_Multiple
        unsigned char* L0108_puc_Bitmap_Native;


        if (P120_i_DoorOrnamentOrdinal) {
                P120_i_DoorOrnamentOrdinal--;
                L0104_i_NativeBitmapIndex = G103_aai_CurrentMapDoorOrnamentsInfo[P120_i_DoorOrnamentOrdinal][C0_NATIVE_BITMAP_INDEX];
                L0106_puc_CoordinateSet = G207_aaauc_Graphic558_DoorOrnamentCoordinateSets[L0105_i_CoordinateSet = G103_aai_CurrentMapDoorOrnamentsInfo[P120_i_DoorOrnamentOrdinal][C1_COORDINATE_SET]][P121_i_ViewDoorOrnamentIndex];
                if (P121_i_ViewDoorOrnamentIndex == C2_VIEW_DOOR_ORNAMENT_D1LCR) {
                        A0107_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(L0104_i_NativeBitmapIndex);
                        AP121_i_ByteWidth = C048_BYTE_WIDTH;
                } else {
                        if (!F491_xzzz_CACHE_IsDerivedBitmapInCache(P120_i_DoorOrnamentOrdinal = C068_DERIVED_BITMAP_FIRST_DOOR_ORNAMENT_D3 + (P120_i_DoorOrnamentOrdinal * 2) + P121_i_ViewDoorOrnamentIndex)) {
                                A0107_puc_CoordinateSet = G207_aaauc_Graphic558_DoorOrnamentCoordinateSets[L0105_i_CoordinateSet][C2_VIEW_DOOR_ORNAMENT_D1LCR];
                                L0108_puc_Bitmap_Native = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(L0104_i_NativeBitmapIndex);
                                F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(L0108_puc_Bitmap_Native, F492_mzzz_CACHE_GetDerivedBitmap(P120_i_DoorOrnamentOrdinal), A0107_puc_CoordinateSet[C4_BYTE_WIDTH] << 1, A0107_puc_CoordinateSet[C5_HEIGHT], L0106_puc_CoordinateSet[C1_X2] - L0106_puc_CoordinateSet[C0_X1] + 1, L0106_puc_CoordinateSet[C5_HEIGHT], (P121_i_ViewDoorOrnamentIndex == C0_VIEW_DOOR_ORNAMENT_D3LCR) ? G200_auc_Graphic558_PaletteChanges_DoorOrnament_D3 : G201_auc_Graphic558_PaletteChanges_DoorOrnament_D2);
                                F493_hzzz_CACHE_AddDerivedBitmap(P120_i_DoorOrnamentOrdinal);
                        }
                        A0107_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(P120_i_DoorOrnamentOrdinal);
                        if (P121_i_ViewDoorOrnamentIndex == C0_VIEW_DOOR_ORNAMENT_D3LCR) {
                                AP121_i_ByteWidth = C024_BYTE_WIDTH;
                        } else {
                                AP121_i_ByteWidth = C032_BYTE_WIDTH;
                        }
                }
                F132_xzzz_VIDEO_Blit(A0107_puc_Bitmap, G074_puc_Bitmap_Temporary, L0106_puc_CoordinateSet, 0, 0, L0106_puc_CoordinateSet[C4_BYTE_WIDTH], AP121_i_ByteWidth, C09_COLOR_GOLD);
        }
}

VOID F110_xxxx_DUNGEONVIEW_DrawDoorButton(P122_i_DoorButtonOrdinal, P123_i_ViewDoorButtonIndex)
register int P122_i_DoorButtonOrdinal;
register int P123_i_ViewDoorButtonIndex;
{
        register int L0109_i_NativeBitmapIndex;
        register int L0110_i_CoordinateSet;
        register unsigned char* L0111_puc_CoordinateSet;
        register unsigned char* L0112_puc_Multiple;
#define A0112_puc_Bitmap        L0112_puc_Multiple
#define A0112_puc_CoordinateSet L0112_puc_Multiple
        unsigned char* L0113_puc_Bitmap_Native;


        if (P122_i_DoorButtonOrdinal) {
                P122_i_DoorButtonOrdinal--;
                L0109_i_NativeBitmapIndex = P122_i_DoorButtonOrdinal + C315_GRAPHIC_FIRST_DOOR_BUTTON;
                L0111_puc_CoordinateSet = G208_aaauc_Graphic558_DoorButtonCoordinateSets[L0110_i_CoordinateSet = G197_auc_Graphic558_DoorButtonCoordinateSet[P122_i_DoorButtonOrdinal]][P123_i_ViewDoorButtonIndex];
                if (P123_i_ViewDoorButtonIndex == C3_VIEW_DOOR_BUTTON_D1C) {
                        A0112_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(L0109_i_NativeBitmapIndex);
                        F007_aAA7_MAIN_CopyBytes(L0111_puc_CoordinateSet, G291_aauc_DungeonViewClickableBoxes[C05_VIEW_CELL_DOOR_BUTTON_OR_WALL_ORNAMENT], sizeof(G291_aauc_DungeonViewClickableBoxes[C05_VIEW_CELL_DOOR_BUTTON_OR_WALL_ORNAMENT]));
                } else {
                        if (!F491_xzzz_CACHE_IsDerivedBitmapInCache(P122_i_DoorButtonOrdinal = C102_DERIVED_BITMAP_FIRST_DOOR_BUTTON + (P122_i_DoorButtonOrdinal * 2) + ((!P123_i_ViewDoorButtonIndex) ? 0 : P123_i_ViewDoorButtonIndex - 1))) {
                                A0112_puc_CoordinateSet = G208_aaauc_Graphic558_DoorButtonCoordinateSets[L0110_i_CoordinateSet][C3_VIEW_DOOR_BUTTON_D1C];
                                L0113_puc_Bitmap_Native = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(L0109_i_NativeBitmapIndex);
                                F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(L0113_puc_Bitmap_Native, F492_mzzz_CACHE_GetDerivedBitmap(P122_i_DoorButtonOrdinal), A0112_puc_CoordinateSet[C4_BYTE_WIDTH] << 1, A0112_puc_CoordinateSet[C5_HEIGHT], L0111_puc_CoordinateSet[C1_X2] - L0111_puc_CoordinateSet[C0_X1] + 1, L0111_puc_CoordinateSet[C5_HEIGHT], (P123_i_ViewDoorButtonIndex == C2_VIEW_DOOR_BUTTON_D2C) ? G199_auc_Graphic558_PaletteChanges_DoorButtonAndWallOrnament_D2 : G198_auc_Graphic558_PaletteChanges_DoorButtonAndWallOrnament_D3);
                                F493_hzzz_CACHE_AddDerivedBitmap(P122_i_DoorButtonOrdinal);
                        }
                        A0112_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(P122_i_DoorButtonOrdinal);
                }
                F132_xzzz_VIDEO_Blit(A0112_puc_Bitmap, G296_puc_Bitmap_Viewport, L0111_puc_CoordinateSet, 0, 0, L0111_puc_CoordinateSet[C4_BYTE_WIDTH], C112_BYTE_WIDTH_VIEWPORT, C10_COLOR_FLESH);
        }
}

VOID F111_xxxx_DUNGEONVIEW_DrawDoor(P124_ui_DoorThingIndex, P125_i_DoorState, P126_pi_DoorNativeBitmapIndices, P127_i_ByteCount, P128_i_ViewDoorOrnamentIndex, P129_ps_DoorFrames)
unsigned int P124_ui_DoorThingIndex;
register int P125_i_DoorState;
int* P126_pi_DoorNativeBitmapIndices;
int P127_i_ByteCount;
int P128_i_ViewDoorOrnamentIndex;
DOOR_FRAMES* P129_ps_DoorFrames;
{
        register int L0114_i_DoorType;
        register DOOR_FRAMES* L0115_ps_DoorFrames;
        register DOOR* L0116_ps_Door;


        L0115_ps_DoorFrames = P129_ps_DoorFrames;
        if (P125_i_DoorState != C0_DOOR_STATE_OPEN) {
                L0116_ps_Door = (DOOR*)(G284_apuc_ThingData[C00_THING_TYPE_DOOR]) + P124_ui_DoorThingIndex;
                F007_aAA7_MAIN_CopyBytes(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(P126_pi_DoorNativeBitmapIndices[L0114_i_DoorType = L0116_ps_Door->Type]), G074_puc_Bitmap_Temporary, P127_i_ByteCount);
                F109_xxxx_DUNGEONVIEW_DrawDoorOrnament(L0116_ps_Door->OrnamentOrdinal, P128_i_ViewDoorOrnamentIndex);
                if (M07_GET(G275_as_CurrentMapDoorInfo[L0114_i_DoorType].Attributes, MASK0x0004_ANIMATED)) {
                        if (M05_RANDOM(2)) {
                                F130_xxxx_VIDEO_FlipHorizontal(G074_puc_Bitmap_Temporary, L0115_ps_DoorFrames->ClosedOrDestroyed.ByteWidth, L0115_ps_DoorFrames->ClosedOrDestroyed.Height);
                        }
                        if (M05_RANDOM(2)) {
                                F131_xxxx_VIDEO_FlipVertical(G074_puc_Bitmap_Temporary, L0115_ps_DoorFrames->ClosedOrDestroyed.ByteWidth, L0115_ps_DoorFrames->ClosedOrDestroyed.Height);
                        }
                }
                if ((L0115_ps_DoorFrames == &G186_s_Graphic558_Frames_Door_D1C) && G407_s_Party.Event73Count_ThievesEye) {
                        F109_xxxx_DUNGEONVIEW_DrawDoorOrnament(M00_INDEX_TO_ORDINAL(C16_DOOR_ORNAMENT_THIEVES_EYE_MASK), C2_VIEW_DOOR_ORNAMENT_D1LCR);
                }
                if (P125_i_DoorState == C4_DOOR_STATE_CLOSED) {
                        F102_xxxx_DUNGEONVIEW_DrawDoorBitmap(&L0115_ps_DoorFrames->ClosedOrDestroyed);
                        return;
                }
                if (P125_i_DoorState == C5_DOOR_STATE_DESTROYED) {
                        F109_xxxx_DUNGEONVIEW_DrawDoorOrnament(M00_INDEX_TO_ORDINAL(C15_DOOR_ORNAMENT_DESTROYED_MASK), P128_i_ViewDoorOrnamentIndex);
                        F102_xxxx_DUNGEONVIEW_DrawDoorBitmap(&L0115_ps_DoorFrames->ClosedOrDestroyed);
                        return;
                }
                P125_i_DoorState--;
                if (L0116_ps_Door->Vertical) {
                        F102_xxxx_DUNGEONVIEW_DrawDoorBitmap(&L0115_ps_DoorFrames->Vertical[P125_i_DoorState]);
                } else {
                        F102_xxxx_DUNGEONVIEW_DrawDoorBitmap(&L0115_ps_DoorFrames->LeftHorizontal[P125_i_DoorState]);
                        F102_xxxx_DUNGEONVIEW_DrawDoorBitmap(&L0115_ps_DoorFrames->RightHorizontal[P125_i_DoorState]);
                }
        }
}

VOID F112_xxxx_DUNGEONVIEW_DrawCeilingPit(P130_i_NativeBitmapIndex, P131_ps_Frame, P132_i_MapX, P133_i_MapY, P134_B_FlipHorizontal)
int P130_i_NativeBitmapIndex;
FRAME* P131_ps_Frame;
int P132_i_MapX;
int P133_i_MapY;
BOOLEAN P134_B_FlipHorizontal;
{
        register int L0117_i_Multiple;
#define A0117_i_MapIndex L0117_i_Multiple
#define A0117_i_Square   L0117_i_Multiple


        if (((A0117_i_MapIndex = F154_afzz_DUNGEON_GetLocationAfterLevelChange(G272_i_CurrentMapIndex, -1, &P132_i_MapX, &P133_i_MapY)) >= 0) &&
            (M34_SQUARE_TYPE(A0117_i_Square = G279_pppuc_DungeonMapData[A0117_i_MapIndex][P132_i_MapX][P133_i_MapY]) == C02_ELEMENT_PIT) &&
            M07_GET(A0117_i_Square, MASK0x0008_PIT_OPEN)) {
                if (P134_B_FlipHorizontal) {
                        F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(P130_i_NativeBitmapIndex, P131_ps_Frame);
                } else {
                        F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(P130_i_NativeBitmapIndex, P131_ps_Frame);
                }
        }
}

VOID F113_xxxx_DUNGEONVIEW_DrawField(P135_ps_FieldAspect, P136_puc_Box)
register FIELD_ASPECT* P135_ps_FieldAspect;
unsigned char* P136_puc_Box;
{
        register unsigned char* L0118_puc_Bitmap_Mask;
        unsigned char* L0119_puc_Bitmap;


        if (P135_ps_FieldAspect->Mask == C255_NO_MASK) {
                L0118_puc_Bitmap_Mask = NULL;
        } else {
                F007_aAA7_MAIN_CopyBytes(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C069_GRAPHIC_FIRST_FIELD_MASK + M07_GET(P135_ps_FieldAspect->Mask, MASK0x007F_MASK_INDEX)), L0118_puc_Bitmap_Mask = G074_puc_Bitmap_Temporary, P135_ps_FieldAspect->ByteWidth * P135_ps_FieldAspect->Height);
                if (M07_GET(P135_ps_FieldAspect->Mask, MASK0x0080_FLIP_MASK)) {
                        F130_xxxx_VIDEO_FlipHorizontal(L0118_puc_Bitmap_Mask, P135_ps_FieldAspect->ByteWidth, P135_ps_FieldAspect->Height);
                }
        }
        F491_xzzz_CACHE_IsDerivedBitmapInCache(C000_DERIVED_BITMAP_VIEWPORT);
        L0119_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C073_GRAPHIC_FIRST_FIELD + P135_ps_FieldAspect->NativeBitmapRelativeIndex);
        F133_xxxx_VIDEO_BlitBoxFilledWithMaskedBitmap(L0119_puc_Bitmap, G296_puc_Bitmap_Viewport, L0118_puc_Bitmap_Mask, F492_mzzz_CACHE_GetDerivedBitmap(C000_DERIVED_BITMAP_VIEWPORT), P136_puc_Box, M05_RANDOM(2) + P135_ps_FieldAspect->BaseStartUnitIndex, M03_RANDOM(32), C112_BYTE_WIDTH_VIEWPORT, P135_ps_FieldAspect->TransparentColor, P135_ps_FieldAspect->X, 0);
        F493_hzzz_CACHE_AddDerivedBitmap(C000_DERIVED_BITMAP_VIEWPORT);
        F480_AA07_CACHE_ReleaseBlock(C000_DERIVED_BITMAP_VIEWPORT | MASK0x8000_DERIVED_BITMAP);
}

unsigned char* F114_xxxx_DUNGEONVIEW_GetExplosionBitmap(P137_ui_ExplosionAspectIndex, P138_ui_Scale, P139_pi_ByteWidth, P140_pi_Height)
register unsigned int P137_ui_ExplosionAspectIndex;
unsigned int P138_ui_Scale;
int* P139_pi_ByteWidth;
int* P140_pi_Height;
{
        register int L0120_i_ByteWidth;
        register int L0121_i_Height;
        register int L0122_i_DerivedBitmapIndex;
        register unsigned char* L0123_puc_Bitmap;
        register EXPLOSION_ASPECT* L0124_ps_ExplosionAspect;
        unsigned char* L0125_puc_Bitmap_Native;


        L0124_ps_ExplosionAspect = &G211_as_Graphic558_ExplosionAspects[P137_ui_ExplosionAspectIndex];
        if (P138_ui_Scale > 32) {
                P138_ui_Scale = 32;
        }
        L0120_i_ByteWidth = M78_SCALED_DIMENSION(L0124_ps_ExplosionAspect->ByteWidth, P138_ui_Scale);
        L0121_i_Height = M78_SCALED_DIMENSION(L0124_ps_ExplosionAspect->Height, P138_ui_Scale);
        if ((P138_ui_Scale == 32) && (P137_ui_ExplosionAspectIndex != C3_EXPLOSION_ASPECT_SMOKE)) {
                L0123_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(P137_ui_ExplosionAspectIndex + C348_GRAPHIC_FIRST_EXPLOSION);
        } else {
                if (F491_xzzz_CACHE_IsDerivedBitmapInCache(L0122_i_DerivedBitmapIndex = (P137_ui_ExplosionAspectIndex * 14) + (P138_ui_Scale >> 1) + (C438_DERIVED_BITMAP_FIRST_EXPLOSION - 2))) { /* Minimum scale is 4 */
                        L0123_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(L0122_i_DerivedBitmapIndex);
                } else {
                        L0125_puc_Bitmap_Native = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(F024_aatz_MAIN_GetMinimumValue(P137_ui_ExplosionAspectIndex, C2_EXPLOSION_ASPECT_POISON) + C348_GRAPHIC_FIRST_EXPLOSION);
                        F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(L0125_puc_Bitmap_Native, L0123_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(L0122_i_DerivedBitmapIndex), L0124_ps_ExplosionAspect->ByteWidth << 1, L0124_ps_ExplosionAspect->Height, L0120_i_ByteWidth << 1, L0121_i_Height, (P137_ui_ExplosionAspectIndex == C3_EXPLOSION_ASPECT_SMOKE) ? G212_auc_Graphic558_PaletteChanges_Smoke : G017_auc_Graphic562_PaletteChanges_NoChanges);
                        F493_hzzz_CACHE_AddDerivedBitmap(L0122_i_DerivedBitmapIndex);
                }
        }
        *P139_pi_ByteWidth = L0120_i_ByteWidth;
        *P140_pi_Height = L0121_i_Height;
        return L0123_puc_Bitmap;
}

VOID F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(P141_T_Thing, P142_i_Direction, P143_i_MapX, P144_i_MapY, P145_i_ViewSquareIndex, P146_ui_OrderedViewCellOrdinals)
register THING P141_T_Thing;
#define AP141_ui_CreatureIndex       P141_T_Thing
#define AP141_ui_CreatureGraphicInfo P141_T_Thing
#define AP141_ui_CreatureX           P141_T_Thing
int P142_i_Direction;
int P143_i_MapX;
int P144_i_MapY;
register int P145_i_ViewSquareIndex;
#define AP145_i_ViewSquareExplosionIndex P145_i_ViewSquareIndex
unsigned int P146_ui_OrderedViewCellOrdinals;
/* Contains 4 nibbles processed from the least significant to the most significant nibble
If the first nibble is 0, then the function call is to draw objects in an alcove on a wall square.
If bit 3 of the first nibble is set, then the function call is to draw a door square viewed from the front. In this case, there are two calls to this function to draw objects behind the door frame (pass 1) and then in front of the door frame (pass 2). The value of bits 2-0 indicate which pass to perform (1 or 2)
The remaining nibbles contain ordinals of square view cells to draw (values 1, 2, 3 or 4). Objects are drawn on the specified view cells and in the order specified. Ordinals are processed until the next nibble value is 0.
Here is the general structure of this huge function:

do {
  do {
    if there is a projectile, explosion or creature, take note of it, but do not draw them yet
    draw each object found
  } while there are things on square at processed cell

  Draw one creature at the cell being processed (or maybe 2 if half square sized)

  do { (Start over from the first thing on the square)
        Draw only projectiles at specified cell. For projectiles drawn as objects, a goto is made to the corresponding routine and then back from there.
  } while there are things on square at processed cell
} while there are cells left to process
do { (Start over from the first thing on the square)
        Draw only explosions at specified cell, except for Fluxcages (take note if a Fluxcage is present)
} while there are things on square at processed cell
If a Fluxcage is present, draw the fluxcage */
{
        register int L0126_i_Multiple;
#define A0126_i_ViewCell      L0126_i_Multiple
#define A0126_i_Cell          L0126_i_Multiple
#define A0126_i_ExplosionSize L0126_i_Multiple
        register int L0127_i_Multiple;
#define A0127_i_ThingType            L0127_i_Multiple
#define A0127_i_NativeBitmapIndex    L0127_i_Multiple
#define A0127_i_X                    L0127_i_Multiple
#define A0127_i_GroupCells           L0127_i_Multiple
#define A0127_i_NormalizedByteWidth  L0127_i_Multiple
#define A0127_i_Y                    L0127_i_Multiple
#define A0127_i_ProjectileAspect     L0127_i_Multiple
#define A0127_i_ExplosionType        L0127_i_Multiple
#define A0127_i_ExplosionAspectIndex L0127_i_Multiple
        register unsigned char* L0128_puc_Multiple;
#define A0128_puc_Bitmap L0128_puc_Multiple
#define A0128_puc_Box    L0128_puc_Multiple
        register OBJECT_ASPECT* L0129_ps_ObjectAspect;
        unsigned long L0130_ul_RemainingViewCellOrdinalsToProcess;
        unsigned char* L0131_puc_PaletteChanges;
        unsigned char* L0132_puc_Bitmap;
        unsigned char* L0133_puc_CoordinateSet;
        int L0134_i_DerivedBitmapIndex;
        BOOLEAN L0135_B_DrawAlcoveObjects;
        int L0136_i_ByteWidth;
        int L0137_i_Height;
        int L0138_i_ViewLane; /* The lane (center/left/right) that the specified square is part of */
        int L0139_i_Cell;
        int L0140_i_PaddingPixelCount;
        int L0141_i_Height;
        BOOLEAN L0142_B_UseAlcoveObjectImage; /* TRUE for objects that have a special graphic when drawn in an alcove, like the Chest */
        BOOLEAN L0143_B_FlipHorizontal;
        BOOLEAN L0144_B_DrawingGrabbableObject;
        BOX_BYTE L0145_s_Box;
        THING L0146_T_FirstThingToDraw; /* Initialized to P141_T_Thing and never changed afterwards. Used as a backup of the specified first object to draw */
        unsigned int L0147_ui_Multiple;
#define A0147_ui_ViewSquareIndexBackup L0147_ui_Multiple
#define A0147_ui_ExplosionScaleIndex   L0147_ui_Multiple
        int L0148_i_CellCounter;
        unsigned int L0149_ui_ObjectShiftIndex;
        unsigned int L0150_ui_Multiple;
#define A0150_ui_ShiftSetIndex        L0150_ui_Multiple
#define A0150_ui_ProjectileScaleIndex L0150_ui_Multiple
        THING L0151_T_GroupThing;
        GROUP* L0152_ps_Group;
        ACTIVE_GROUP* L0153_ps_ActiveGroup;
        CREATURE_INFO* L0154_ps_CreatureInfo;
        CREATURE_ASPECT* L0155_ps_CreatureAspect;
        int L0156_i_CreatureSize;
        int L0157_i_CreatureDirectionDelta;
        int L0158_i_CreatureGraphicInfo;
        int L0159_i_CreatureAspect;
        int L0160_i_Unreferenced1; /* BUG0_00 Useless code */
        int L0161_i_CreatureIndex;
        int L0162_i_TransparentColor;
        int L0163_i_SourceByteWidth;
        int L0164_i_SourceHeight;
        int L0165_i_CreaturePaddingPixelCount;
        int L0166_i_Unreferenced2; /* BUG0_00 Useless code */
        BOOLEAN L0167_B_TwoHalfSquareCreaturesFrontView;
        BOOLEAN L0168_B_DrawingLastBackRowCell;
        BOOLEAN L0169_B_UseCreatureSideBitmap;
        BOOLEAN L0170_B_UseCreatureBackBitmap;
        BOOLEAN L0171_B_UseCreatureSpecialD2FrontBitmap;
        BOOLEAN L0172_B_UseCreatureAttackBitmap;
        BOOLEAN L0173_B_UseFlippedHorizontallyCreatureFrontImage;
        BOOLEAN L0174_B_DrawCreaturesCompleted; /* Set to TRUE when the last creature that the function should draw is being drawn. This is used to avoid processing the code to draw creatures for the remaining square cells */
        int L0175_i_DoorFrontViewDrawingPass; /* Value 0, 1 or 2 */
        int L0176_i_Scale;
        BOOLEAN L0177_B_DerivedBitmapInCache;
        PROJECTILE* L0178_ps_Projectile;
        unsigned char L0179_auc_ProjectileCoordinates[2];
        int L0180_i_ProjectileX;
        int L0181_i_ProjectileDirection;
        int L0182_i_ProjectileAspectType;
        int L0183_i_ProjectileBitmapIndexDelta;
        BOOLEAN L0184_B_DoNotScaleWithKineticEnergy;
        BOOLEAN L0185_B_DrawProjectileAsObject; /* When true, the code section to draw an object is called (with a goto) to draw the projectile, then the code section goes back to projectile processing with another goto */
        BOOLEAN L0186_B_SquareHasProjectile;
        unsigned int L0187_ui_CurrentViewCellToDraw;
        BOOLEAN L0188_B_ProjectileFlipVertical;
        BOOLEAN L0189_B_ProjectileAspectTypeHasBackGraphicAndRotation;
        BOOLEAN L0190_B_FlipVertical;
        EXPLOSION* L0191_ps_Explosion;
        EXPLOSION* L0192_ps_FluxcageExplosion;
        int* L0193_pi_ExplosionCoordinates;
        int L0194_i_ExplosionScale;
        BOOLEAN L0195_B_SquareHasExplosion;
        BOOLEAN L0196_B_RebirthExplosion;
        BOOLEAN L0197_B_Smoke;
        FIELD_ASPECT L0198_s_FieldAspect;
#ifndef NOCOPYPROTECTION
        BOOLEAN L0199_B_ProceedToNextState_COPYPROTECTIONF;
#endif


        if (P141_T_Thing == C0xFFFE_THING_ENDOFLIST) {
                return;
        }
        L0152_ps_Group = NULL;
        L0151_T_GroupThing = C0xFFFF_THING_NONE;
        L0174_B_DrawCreaturesCompleted = L0186_B_SquareHasProjectile = L0195_B_SquareHasExplosion = FALSE;
        L0148_i_CellCounter = 0;
        L0146_T_FirstThingToDraw = P141_T_Thing;
        if (M07_GET(P146_ui_OrderedViewCellOrdinals, MASK0x0008_DOOR_FRONT)) { /* If the function call is to draw objects on a door square viewed from the front */
                L0175_i_DoorFrontViewDrawingPass = (P146_ui_OrderedViewCellOrdinals & 0x0001) + 1; /* Two function calls are made in that case to draw objects on both sides of the door frame. The door and its frame are drawn between the two calls. This value indicates the drawing pass so that creatures are drawn in the right order and so that Fluxcages are not drawn twice */
                P146_ui_OrderedViewCellOrdinals >>= 4; /* Remove the first nibble that was used for the door front view pass */
        } else {
                L0175_i_DoorFrontViewDrawingPass = 0; /* The function call is not to draw objects on a door square viewed from the front */
        }
        L0135_B_DrawAlcoveObjects = !(L0130_ul_RemainingViewCellOrdinalsToProcess = P146_ui_OrderedViewCellOrdinals);
        A0147_ui_ViewSquareIndexBackup = P145_i_ViewSquareIndex;
        L0138_i_ViewLane = (P145_i_ViewSquareIndex + 3) % 3;
#ifndef NOCOPYPROTECTION
        L0199_B_ProceedToNextState_COPYPROTECTIONF = ((G069_ui_State_COPYPROTECTIONF & 0x00FE) == 10) && G070_B_Sector7Analyzed_COPYPROTECTIONF;
#endif
        do {
/* Draw objects */
                if (L0135_B_DrawAlcoveObjects) {
                        A0126_i_ViewCell = C04_VIEW_CELL_ALCOVE; /* Index of coordinates to draw objects in alcoves */
                        L0139_i_Cell = M18_OPPOSITE(P142_i_Direction); /* Alcove is on the opposite direction of the viewing direction */
                        L0149_ui_ObjectShiftIndex = 2;
                } else {
                        A0126_i_ViewCell = M01_ORDINAL_TO_INDEX((int)L0130_ul_RemainingViewCellOrdinalsToProcess & 0x000F); /* View cell is the index of coordinates to draw object */
                        L0187_ui_CurrentViewCellToDraw = A0126_i_ViewCell;
                        L0130_ul_RemainingViewCellOrdinalsToProcess >>= 4; /* Proceed to the next cell ordinal */
                        L0148_i_CellCounter++;
                        L0139_i_Cell = M21_NORMALIZE(A0126_i_ViewCell + P142_i_Direction); /* Convert view cell to absolute cell */
                        P141_T_Thing = L0146_T_FirstThingToDraw;
                        P145_i_ViewSquareIndex = A0147_ui_ViewSquareIndexBackup; /* Restore value as it may have been modified while drawing a creature */
                        L0149_ui_ObjectShiftIndex = 0;
                }
                L0149_ui_ObjectShiftIndex += (L0139_i_Cell & 0x0001) << 3;
                L0185_B_DrawProjectileAsObject = FALSE;
                do {
                        if ((A0127_i_ThingType = M12_TYPE(P141_T_Thing)) == C04_THING_TYPE_GROUP) {
                                L0151_T_GroupThing = P141_T_Thing;
                                continue;
                        }
                        if (A0127_i_ThingType == C14_THING_TYPE_PROJECTILE) {
                                L0186_B_SquareHasProjectile = TRUE;
                                continue;
                        }
                        if (A0127_i_ThingType == C15_THING_TYPE_EXPLOSION) {
                                L0195_B_SquareHasExplosion = TRUE;
                                continue;
                        }
                        if ((P145_i_ViewSquareIndex >= C00_VIEW_SQUARE_D3C) && (P145_i_ViewSquareIndex <= C09_VIEW_SQUARE_D0C) && (M11_CELL(P141_T_Thing) == L0139_i_Cell)) { /* Square where objects are visible and object is located on cell being processed */
                                L0129_ps_ObjectAspect = &(G209_as_Graphic558_ObjectAspects[G237_as_Graphic559_ObjectInfo[F141_anzz_DUNGEON_GetObjectInfoIndex(P141_T_Thing)].ObjectAspectIndex]);
                                A0127_i_NativeBitmapIndex = C360_GRAPHIC_FIRST_OBJECT + L0129_ps_ObjectAspect->FirstNativeBitmapRelativeIndex;
                                if (L0142_B_UseAlcoveObjectImage = (L0135_B_DrawAlcoveObjects && M07_GET(L0129_ps_ObjectAspect->GraphicInfo, MASK0x0010_ALCOVE) && !L0138_i_ViewLane)) {
                                        A0127_i_NativeBitmapIndex++;
                                }
                                L0133_puc_CoordinateSet = G218_aaaauc_Graphic558_ObjectCoordinateSets[L0129_ps_ObjectAspect->CoordinateSet][P145_i_ViewSquareIndex][A0126_i_ViewCell];
                                if (!L0133_puc_CoordinateSet[C1_Y]) { /* If object is not visible */
                                        continue;
                                }
                                T115_015_DrawProjectileAsObject:
                                L0143_B_FlipHorizontal = M07_GET(L0129_ps_ObjectAspect->GraphicInfo, MASK0x0001_FLIP_ON_RIGHT) &&
                                                         !L0142_B_UseAlcoveObjectImage &&
                                                         ((L0138_i_ViewLane == C2_VIEW_LANE_RIGHT) || (!L0138_i_ViewLane && ((A0126_i_ViewCell == C01_VIEW_CELL_FRONT_RIGHT) || (A0126_i_ViewCell == C02_VIEW_CELL_BACK_RIGHT))));
                                                         /* Flip horizontally if object graphic requires it and is not being drawn in an alcove and the object is either on the right lane or on the right column of the center lane */
                                L0140_i_PaddingPixelCount = 0;
                                if ((P145_i_ViewSquareIndex == C09_VIEW_SQUARE_D0C) || ((P145_i_ViewSquareIndex >= C06_VIEW_SQUARE_D1C) && (A0126_i_ViewCell >= C02_VIEW_CELL_BACK_RIGHT))) {
                                        L0144_B_DrawingGrabbableObject = (!L0138_i_ViewLane && !L0185_B_DrawProjectileAsObject); /* If object is in the center lane (only D0C or D1C with condition above) and is not a projectile */
                                        A0150_ui_ShiftSetIndex = C0_SHIFT_SET_D0_BACK_OR_D1_FRONT;
                                        A0128_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(A0127_i_NativeBitmapIndex); /* Use base graphic, no resizing */
                                        L0136_i_ByteWidth = L0129_ps_ObjectAspect->ByteWidth;
                                        L0137_i_Height = L0129_ps_ObjectAspect->Height;
                                        if (L0143_B_FlipHorizontal) {
                                                F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(A0128_puc_Bitmap, G074_puc_Bitmap_Temporary, L0136_i_ByteWidth, L0137_i_Height);
                                                A0128_puc_Bitmap = G074_puc_Bitmap_Temporary;
                                        }
                                } else {
                                        L0144_B_DrawingGrabbableObject = FALSE;
                                        L0134_i_DerivedBitmapIndex = C104_DERIVED_BITMAP_FIRST_OBJECT + L0129_ps_ObjectAspect->FirstDerivedBitmapRelativeIndex;
                                        if ((P145_i_ViewSquareIndex >= C06_VIEW_SQUARE_D1C) || ((P145_i_ViewSquareIndex >= C03_VIEW_SQUARE_D2C) && (A0126_i_ViewCell >= C02_VIEW_CELL_BACK_RIGHT))) {
                                                L0134_i_DerivedBitmapIndex++;
                                                A0150_ui_ShiftSetIndex = C1_SHIFT_SET_D1_BACK_OR_D2_FRONT;
                                                L0136_i_ByteWidth = M78_SCALED_DIMENSION(L0129_ps_ObjectAspect->ByteWidth, C20_SCALE_D2);
                                                L0137_i_Height = M78_SCALED_DIMENSION(L0129_ps_ObjectAspect->Height, C20_SCALE_D2);
                                                L0131_puc_PaletteChanges = &G214_auc_Graphic558_PaletteChanges_FloorOrnament_D2;
                                        } else {
                                                A0150_ui_ShiftSetIndex = C2_SHIFT_SET_D2_BACK_OR_D3_FRONT;
                                                L0136_i_ByteWidth = M78_SCALED_DIMENSION(L0129_ps_ObjectAspect->ByteWidth, C16_SCALE_D3);
                                                L0137_i_Height = M78_SCALED_DIMENSION(L0129_ps_ObjectAspect->Height, C16_SCALE_D3);
                                                L0131_puc_PaletteChanges = &G213_auc_Graphic558_PaletteChanges_FloorOrnament_D3;
                                        }
                                        if (L0143_B_FlipHorizontal) {
                                                L0134_i_DerivedBitmapIndex += 2;
                                                L0140_i_PaddingPixelCount = (7 - ((L0136_i_ByteWidth - 1) & 0x0007)) << 1;
                                        } else {
                                                if (L0142_B_UseAlcoveObjectImage) {
                                                        L0134_i_DerivedBitmapIndex += 4;
                                                }
                                        }
                                        if (F491_xzzz_CACHE_IsDerivedBitmapInCache(L0134_i_DerivedBitmapIndex)) {
                                                A0128_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(L0134_i_DerivedBitmapIndex);
                                        } else {
                                                L0132_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(A0127_i_NativeBitmapIndex);
                                                F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(L0132_puc_Bitmap, A0128_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(L0134_i_DerivedBitmapIndex), L0129_ps_ObjectAspect->ByteWidth << 1, L0129_ps_ObjectAspect->Height, L0136_i_ByteWidth << 1, L0137_i_Height, L0131_puc_PaletteChanges);
                                                if (L0143_B_FlipHorizontal) {
                                                        F130_xxxx_VIDEO_FlipHorizontal(A0128_puc_Bitmap, M77_NORMALIZED_BYTE_WIDTH(L0136_i_ByteWidth), L0137_i_Height);
                                                }
                                                F493_hzzz_CACHE_AddDerivedBitmap(L0134_i_DerivedBitmapIndex);
                                        }
                                }
                                A0127_i_X = L0133_puc_CoordinateSet[C0_X];
                                L0145_s_Box.Y2 = L0133_puc_CoordinateSet[C1_Y];
                                if (!L0185_B_DrawProjectileAsObject) { /* If drawing an object that is not a projectile */
                                        A0127_i_X += G223_aac_Graphic558_ShiftSets[A0150_ui_ShiftSetIndex][G217_aauc_Graphic558_ObjectPileShiftSetIndices[L0149_ui_ObjectShiftIndex][C0_X_SHIFT_INDEX]];
                                        L0145_s_Box.Y2 += G223_aac_Graphic558_ShiftSets[A0150_ui_ShiftSetIndex][G217_aauc_Graphic558_ObjectPileShiftSetIndices[L0149_ui_ObjectShiftIndex][C1_Y_SHIFT_INDEX]];
                                        L0149_ui_ObjectShiftIndex++; /* The next object drawn will use the next shift values */
                                        if (L0135_B_DrawAlcoveObjects) {
                                                if (L0149_ui_ObjectShiftIndex >= 14) {
                                                        L0149_ui_ObjectShiftIndex = 2;
                                                }
                                        } else {
                                                L0149_ui_ObjectShiftIndex &= 0x000F;
                                        }
                                }
                                L0145_s_Box.Y1 = L0145_s_Box.Y2 - (L0137_i_Height - 1);
                                if (L0145_s_Box.Y2 > 135) {
                                        L0145_s_Box.Y2 = 135;
                                }
                                L0145_s_Box.X2 = F024_aatz_MAIN_GetMinimumValue(223, A0127_i_X + L0136_i_ByteWidth);
                                if (L0145_s_Box.X1 = F025_aatz_MAIN_GetMaximumValue(0, A0127_i_X - L0136_i_ByteWidth + 1)) {
                                        if (L0143_B_FlipHorizontal) {
                                                A0127_i_X = L0140_i_PaddingPixelCount;
                                        } else {
                                                A0127_i_X = 0;
                                        }
                                } else {
                                        A0127_i_X = L0136_i_ByteWidth - A0127_i_X - 1;
                                }
                                if (L0144_B_DrawingGrabbableObject) {
                                        L0132_puc_Bitmap = A0128_puc_Bitmap;
                                        A0128_puc_Box = G291_aauc_DungeonViewClickableBoxes[A0126_i_ViewCell];
                                        if (A0128_puc_Box[C0_X1] == 255) { /* If the grabbable object is the first */
                                                F007_aAA7_MAIN_CopyBytes(&L0145_s_Box, A0128_puc_Box, sizeof(L0145_s_Box));
                                                if ((L0141_i_Height = A0128_puc_Box[C3_Y2] - A0128_puc_Box[C2_Y1]) < 14) { /* If the box is too small then enlarge it a little */
                                                        L0141_i_Height = L0141_i_Height >> 1;
                                                        A0128_puc_Box[C2_Y1] += L0141_i_Height - 7;
                                                        if (L0141_i_Height < 4) {
                                                                A0128_puc_Box[C3_Y2] -= L0141_i_Height - 3;
                                                        }
                                                }
                                        } else { /* If there are several grabbable objects then enlarge the box so it includes all objects */
                                                A0128_puc_Box[C0_X1] = F024_aatz_MAIN_GetMinimumValue(A0128_puc_Box[C0_X1], L0145_s_Box.X1);
                                                A0128_puc_Box[C1_X2] = F025_aatz_MAIN_GetMaximumValue(A0128_puc_Box[C1_X2], L0145_s_Box.X2);
                                                A0128_puc_Box[C2_Y1] = F024_aatz_MAIN_GetMinimumValue(A0128_puc_Box[C2_Y1], L0145_s_Box.Y1);
                                                A0128_puc_Box[C3_Y2] = F025_aatz_MAIN_GetMaximumValue(A0128_puc_Box[C3_Y2], L0145_s_Box.Y2);
                                        }
                                        A0128_puc_Bitmap = L0132_puc_Bitmap;
                                        G292_aT_PileTopObject[A0126_i_ViewCell] = P141_T_Thing; /* The object is at the top of the pile */
                                }
                                F132_xzzz_VIDEO_Blit(A0128_puc_Bitmap, G296_puc_Bitmap_Viewport, &L0145_s_Box, A0127_i_X, 0, M77_NORMALIZED_BYTE_WIDTH(L0136_i_ByteWidth), C112_BYTE_WIDTH_VIEWPORT, C10_COLOR_FLESH);
                                if (L0185_B_DrawProjectileAsObject) {
                                        goto T115_171_BackFromT115_015_DrawProjectileAsObject;
                                }
                        }
                } while ((P141_T_Thing = F159_rzzz_DUNGEON_GetNextThing(P141_T_Thing)) != C0xFFFE_THING_ENDOFLIST);
                if (A0126_i_ViewCell == C04_VIEW_CELL_ALCOVE) {
                        break; /* End of processing when drawing objects in an alcove */
                }
                if (P145_i_ViewSquareIndex < C00_VIEW_SQUARE_D3C) {
                        break; /* End of processing if square is too far away at D4 */
                }
/* Draw creatures */
                L0168_B_DrawingLastBackRowCell = ((A0126_i_ViewCell <= C01_VIEW_CELL_FRONT_RIGHT) || (L0148_i_CellCounter == 1)) && (!L0130_ul_RemainingViewCellOrdinalsToProcess || ((L0130_ul_RemainingViewCellOrdinalsToProcess & 0x0000000F) >= 3)); /* If (draw cell on the back row or second cell being processed) and (no more cells to draw or next cell to draw is a cell on the front row) */
                if ((L0151_T_GroupThing == C0xFFFF_THING_NONE) || L0174_B_DrawCreaturesCompleted) {
                        goto T115_129_DrawProjectiles; /* Skip code to draw creatures */
                }
                if (L0152_ps_Group == NULL) { /* If all creature data and info has not already been gathered */
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        L0152_ps_Group = &((GROUP*)G284_apuc_ThingData[C04_THING_TYPE_GROUP])[M13_INDEX(L0151_T_GroupThing)];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                        L0152_ps_Group = (GROUP*)F156_afzz_DUNGEON_GetThingData(L0151_T_GroupThing);
#endif
                        L0153_ps_ActiveGroup = &G375_ps_ActiveGroups[L0152_ps_Group->ActiveGroupIndex];
                        L0154_ps_CreatureInfo = &G243_as_Graphic559_CreatureInfo[L0152_ps_Group->Type];
                        L0155_ps_CreatureAspect = &G219_as_Graphic558_CreatureAspects[L0154_ps_CreatureInfo->CreatureAspectIndex];
                        L0156_i_CreatureSize = M07_GET(L0154_ps_CreatureInfo->Attributes, MASK0x0003_SIZE);
                        L0158_i_CreatureGraphicInfo = L0154_ps_CreatureInfo->GraphicInfo;
                }
                L0129_ps_ObjectAspect = (OBJECT_ASPECT*)L0155_ps_CreatureAspect;
                if (AP141_ui_CreatureIndex = F176_avzz_GROUP_GetCreatureOrdinalInCell(L0152_ps_Group, L0139_i_Cell)) { /* If there is a creature on the cell being processed */
                        AP141_ui_CreatureIndex--; /* Convert ordinal to index */
                        L0161_i_CreatureIndex = (int)AP141_ui_CreatureIndex;
                } else {
                        if (L0156_i_CreatureSize == C1_SIZE_HALF_SQUARE) {
                                AP141_ui_CreatureIndex = 0;
                                L0161_i_CreatureIndex = -1;
                        } else {
                                goto T115_129_DrawProjectiles; /* No creature to draw at cell, skip to projectiles */
                        }
                }
                L0157_i_CreatureDirectionDelta = M21_NORMALIZE(P142_i_Direction - M50_CREATURE_VALUE(L0153_ps_ActiveGroup->Directions, AP141_ui_CreatureIndex));
                L0167_B_TwoHalfSquareCreaturesFrontView = FALSE;
                if ((A0127_i_GroupCells = L0153_ps_ActiveGroup->Cells) == C255_SINGLE_CENTERED_CREATURE) { /* If there is a single centered creature in the group */
                        if (L0130_ul_RemainingViewCellOrdinalsToProcess || (L0175_i_DoorFrontViewDrawingPass == 1)) {
                                goto T115_129_DrawProjectiles; /* Do not draw a single centered creature now, wait until second pass (for a front view door) or until all cells have been drawn so the creature is drawn over all the objects on the floor */
                        }
                        L0174_B_DrawCreaturesCompleted = TRUE;
                        if ((L0156_i_CreatureSize == C1_SIZE_HALF_SQUARE) && (L0157_i_CreatureDirectionDelta & 0x0001)) { /* Side view of half square creature */
                                A0126_i_ViewCell = C03_VIEW_CELL_CENTER_COLUMN;
                        } else {
                                A0126_i_ViewCell = C04_VIEW_CELL_FRONT_ROW;
                        }
                } else {
                        if ((L0156_i_CreatureSize == C1_SIZE_HALF_SQUARE) && (L0168_B_DrawingLastBackRowCell || !L0130_ul_RemainingViewCellOrdinalsToProcess || (L0161_i_CreatureIndex < 0))) {
                                if (L0168_B_DrawingLastBackRowCell && (L0175_i_DoorFrontViewDrawingPass != 2)) {
                                        if ((L0161_i_CreatureIndex >= 0) && (L0157_i_CreatureDirectionDelta & 0x0001)) {
                                                A0126_i_ViewCell = C02_VIEW_CELL_BACK_ROW; /* Side view of a half square creature on the back row. Drawn during pass 1 for a door square */
                                        } else {
                                                goto T115_129_DrawProjectiles;
                                        }
                                } else {
                                        if ((L0175_i_DoorFrontViewDrawingPass != 1) && !L0130_ul_RemainingViewCellOrdinalsToProcess) {
                                                if (L0157_i_CreatureDirectionDelta & 0x0001) {
                                                        if (L0161_i_CreatureIndex >= 0) {
                                                                A0126_i_ViewCell = C04_VIEW_CELL_FRONT_ROW; /* Side view of a half square creature on the front row. Drawn during pass 2 for a door square */
                                                        } else {
                                                                goto T115_129_DrawProjectiles;
                                                        }
                                                } else {
                                                        L0174_B_DrawCreaturesCompleted = TRUE;
                                                        if (L0161_i_CreatureIndex < 0) {
                                                                L0161_i_CreatureIndex = 0;
                                                        }
                                                        L0167_B_TwoHalfSquareCreaturesFrontView = L0152_ps_Group->Count;
                                                        if (((A0127_i_GroupCells = M50_CREATURE_VALUE(A0127_i_GroupCells, AP141_ui_CreatureIndex)) == P142_i_Direction) || (A0127_i_GroupCells == M20_PREVIOUS(P142_i_Direction))) {
                                                                A0126_i_ViewCell = C00_VIEW_CELL_LEFT_COLUMN;
                                                        } else {
                                                                A0126_i_ViewCell = C01_VIEW_CELL_RIGHT_COLUMN;
                                                        }
                                                }
                                        } else {
                                                goto T115_129_DrawProjectiles;
                                        }
                                }
                        } else {
                                if (L0156_i_CreatureSize != C0_SIZE_QUARTER_SQUARE) {
                                        goto T115_129_DrawProjectiles;
                                }
                        }
                }
                L0159_i_CreatureAspect = L0153_ps_ActiveGroup->Aspect[L0161_i_CreatureIndex];
                if (P145_i_ViewSquareIndex > C09_VIEW_SQUARE_D0C) {
                        P145_i_ViewSquareIndex--;
                }
                T115_077_DrawSecondHalfSquareCreature:
                L0133_puc_CoordinateSet = G224_aaaauc_Graphic558_CreatureCoordinateSets[M71_COORDINATE_SET((CREATURE_ASPECT*)L0129_ps_ObjectAspect)][P145_i_ViewSquareIndex][A0126_i_ViewCell];
                if (!L0133_puc_CoordinateSet[C1_Y]) {
                        goto T115_126_CreatureNotVisible;
                }
                AP141_ui_CreatureGraphicInfo = L0158_i_CreatureGraphicInfo;
                A0127_i_NativeBitmapIndex = C446_GRAPHIC_FIRST_CREATURE + ((CREATURE_ASPECT*)L0129_ps_ObjectAspect)->FirstNativeBitmapRelativeIndex; /* By default, assume using the front image */
                L0134_i_DerivedBitmapIndex = ((CREATURE_ASPECT*)L0129_ps_ObjectAspect)->FirstDerivedBitmapIndex;
                if (L0169_B_UseCreatureSideBitmap = M07_GET(AP141_ui_CreatureGraphicInfo, MASK0x0008_SIDE) && (L0157_i_CreatureDirectionDelta & 0x0001)) {
                        L0172_B_UseCreatureAttackBitmap = L0173_B_UseFlippedHorizontallyCreatureFrontImage = L0170_B_UseCreatureBackBitmap = FALSE;
                        A0127_i_NativeBitmapIndex++; /* Skip the front image. Side image is right after the front image */
                        L0134_i_DerivedBitmapIndex += 2;
                        L0163_i_SourceByteWidth = L0136_i_ByteWidth = ((CREATURE_ASPECT*)L0129_ps_ObjectAspect)->ByteWidthSide;
                        L0164_i_SourceHeight = L0137_i_Height = ((CREATURE_ASPECT*)L0129_ps_ObjectAspect)->HeightSide;
                } else {
                        L0170_B_UseCreatureBackBitmap = M07_GET(AP141_ui_CreatureGraphicInfo, MASK0x0010_BACK) && (L0157_i_CreatureDirectionDelta == 0);
                        if (L0172_B_UseCreatureAttackBitmap = !L0170_B_UseCreatureBackBitmap && M07_GET(L0159_i_CreatureAspect, MASK0x0080_IS_ATTACKING) && M07_GET(AP141_ui_CreatureGraphicInfo, MASK0x0020_ATTACK)) {
                                L0173_B_UseFlippedHorizontallyCreatureFrontImage = FALSE;
                                L0163_i_SourceByteWidth = L0136_i_ByteWidth = ((CREATURE_ASPECT*)L0129_ps_ObjectAspect)->ByteWidthAttack;
                                L0164_i_SourceHeight = L0137_i_Height = ((CREATURE_ASPECT*)L0129_ps_ObjectAspect)->HeightAttack;
                                A0127_i_NativeBitmapIndex++; /* Skip the front image */
                                L0134_i_DerivedBitmapIndex += 2;
                                if (M07_GET(AP141_ui_CreatureGraphicInfo, MASK0x0008_SIDE)) {
                                        A0127_i_NativeBitmapIndex++; /* If the creature has a side image, it preceeds the attack image */
                                        L0134_i_DerivedBitmapIndex += 2;
                                }
                                if (M07_GET(AP141_ui_CreatureGraphicInfo, MASK0x0010_BACK)) {
                                        A0127_i_NativeBitmapIndex++; /* If the creature has a back image, it preceeds the attack image */
                                        L0134_i_DerivedBitmapIndex += 2;
                                }
                        } else {
                                L0163_i_SourceByteWidth = L0136_i_ByteWidth = ((CREATURE_ASPECT*)L0129_ps_ObjectAspect)->ByteWidthFront;
                                L0164_i_SourceHeight = L0137_i_Height = ((CREATURE_ASPECT*)L0129_ps_ObjectAspect)->HeightFront;
                                if (L0170_B_UseCreatureBackBitmap) {
                                        L0173_B_UseFlippedHorizontallyCreatureFrontImage = FALSE;
                                        if (M07_GET(AP141_ui_CreatureGraphicInfo, MASK0x0008_SIDE)) {
                                                A0127_i_NativeBitmapIndex += 2; /* If the creature has a side image, it preceeds the back image */
                                                L0134_i_DerivedBitmapIndex += 4;
                                        } else {
                                                A0127_i_NativeBitmapIndex++; /* If the creature does not have a side image, the back image follows the front image */
                                                L0134_i_DerivedBitmapIndex += 2;
                                        }
                                } else {
                                        if (L0173_B_UseFlippedHorizontallyCreatureFrontImage = M07_GET(AP141_ui_CreatureGraphicInfo, MASK0x0004_FLIP_NON_ATTACK) && M07_GET(L0159_i_CreatureAspect, MASK0x0040_FLIP_BITMAP)) {
                                                L0134_i_DerivedBitmapIndex += 2;
                                                if (M07_GET(AP141_ui_CreatureGraphicInfo, MASK0x0008_SIDE)) {
                                                        L0134_i_DerivedBitmapIndex += 2;
                                                }
                                                if (M07_GET(AP141_ui_CreatureGraphicInfo, MASK0x0010_BACK)) {
                                                        L0134_i_DerivedBitmapIndex += 2;
                                                }
                                                if (M07_GET(AP141_ui_CreatureGraphicInfo, MASK0x0020_ATTACK)) {
                                                        L0134_i_DerivedBitmapIndex += 2;
                                                }
                                        }
                                }
                        }
                }
                if (P145_i_ViewSquareIndex >= C06_VIEW_SQUARE_D1C) { /* Creature is on D1 */
                        L0165_i_CreaturePaddingPixelCount = 0;
                        A0150_ui_ShiftSetIndex = C0_SHIFT_SET_D0_BACK_OR_D1_FRONT;
                        L0162_i_TransparentColor = M72_TRANSPARENT_COLOR((CREATURE_ASPECT*)L0129_ps_ObjectAspect);
                        if (L0169_B_UseCreatureSideBitmap) {
                                A0128_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(A0127_i_NativeBitmapIndex);
                                if (L0157_i_CreatureDirectionDelta == 1) {
                                        F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(A0128_puc_Bitmap, G074_puc_Bitmap_Temporary, L0136_i_ByteWidth, L0137_i_Height);
                                        A0128_puc_Bitmap = G074_puc_Bitmap_Temporary;
                                }
                        } else {
                                if (L0170_B_UseCreatureBackBitmap || !L0173_B_UseFlippedHorizontallyCreatureFrontImage) {
                                        A0128_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(A0127_i_NativeBitmapIndex);
                                        if (L0172_B_UseCreatureAttackBitmap && M07_GET(L0159_i_CreatureAspect, MASK0x0040_FLIP_BITMAP)) {
                                                F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(A0128_puc_Bitmap, G074_puc_Bitmap_Temporary, L0136_i_ByteWidth, L0137_i_Height);
                                                A0128_puc_Bitmap = G074_puc_Bitmap_Temporary;
                                        }
                                } else { /* Use first additional derived graphic: front D1 */
                                        if (F491_xzzz_CACHE_IsDerivedBitmapInCache(L0134_i_DerivedBitmapIndex)) { /* If derived graphic is already in memory */
                                                A0128_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(L0134_i_DerivedBitmapIndex);
                                        } else {
                                                L0132_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(A0127_i_NativeBitmapIndex);
                                                if (M07_GET(AP141_ui_CreatureGraphicInfo, MASK0x0004_FLIP_NON_ATTACK)) {
                                                        F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal(L0132_puc_Bitmap, A0128_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(L0134_i_DerivedBitmapIndex), L0136_i_ByteWidth, L0137_i_Height);
                                                }
                                                F493_hzzz_CACHE_AddDerivedBitmap(L0134_i_DerivedBitmapIndex);
                                        }
                                }
                        }
                } else { /* Creature is on D2 or D3 */
                        if (L0173_B_UseFlippedHorizontallyCreatureFrontImage) {
                                L0134_i_DerivedBitmapIndex++; /* Skip front D1 image in additional graphics */
                        }
                        if (P145_i_ViewSquareIndex >= C03_VIEW_SQUARE_D2C) { /* Creature is on D2 */
                                L0134_i_DerivedBitmapIndex++; /* Skip front D3 image in additional graphics */
                                A0150_ui_ShiftSetIndex = C1_SHIFT_SET_D1_BACK_OR_D2_FRONT;
                                L0171_B_UseCreatureSpecialD2FrontBitmap = M07_GET(AP141_ui_CreatureGraphicInfo, MASK0x0080_SPECIAL_D2_FRONT) && !L0169_B_UseCreatureSideBitmap && !L0170_B_UseCreatureBackBitmap && !L0172_B_UseCreatureAttackBitmap;
                                L0131_puc_PaletteChanges = &G222_auc_Graphic558_PaletteChanges_Creature_D2;
                                L0176_i_Scale = C20_SCALE_D2;
                        } else { /* Creature is on D3 */
                                A0150_ui_ShiftSetIndex = C2_SHIFT_SET_D2_BACK_OR_D3_FRONT;
                                L0171_B_UseCreatureSpecialD2FrontBitmap = FALSE;
                                L0131_puc_PaletteChanges = &G221_auc_Graphic558_PaletteChanges_Creature_D3;
                                L0176_i_Scale = C16_SCALE_D3;
                        }
                        L0136_i_ByteWidth = M78_SCALED_DIMENSION(L0163_i_SourceByteWidth, L0176_i_Scale);
                        L0137_i_Height = M78_SCALED_DIMENSION(L0164_i_SourceHeight, L0176_i_Scale);
                        L0162_i_TransparentColor = L0131_puc_PaletteChanges[M72_TRANSPARENT_COLOR((CREATURE_ASPECT*)L0129_ps_ObjectAspect)] / 10;
                        if (L0177_B_DerivedBitmapInCache = F491_xzzz_CACHE_IsDerivedBitmapInCache(L0134_i_DerivedBitmapIndex)) {
                                A0128_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(L0134_i_DerivedBitmapIndex);
                        } else {
                                L0132_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(A0127_i_NativeBitmapIndex);
                                F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(L0132_puc_Bitmap, A0128_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(L0134_i_DerivedBitmapIndex), L0163_i_SourceByteWidth << 1, L0164_i_SourceHeight, L0136_i_ByteWidth << 1, L0137_i_Height, L0131_puc_PaletteChanges);
                                F493_hzzz_CACHE_AddDerivedBitmap(L0134_i_DerivedBitmapIndex);
                        }
                        if ((L0169_B_UseCreatureSideBitmap && (L0157_i_CreatureDirectionDelta == 1)) || /* If creature is viewed from the right, the side view must be flipped */
                            (L0172_B_UseCreatureAttackBitmap && M07_GET(L0159_i_CreatureAspect, MASK0x0040_FLIP_BITMAP)) ||
                            (L0171_B_UseCreatureSpecialD2FrontBitmap && M07_GET(AP141_ui_CreatureGraphicInfo, MASK0x0100_SPECIAL_D2_FRONT_IS_FLIPPED_FRONT)) ||
                            (L0173_B_UseFlippedHorizontallyCreatureFrontImage && M07_GET(AP141_ui_CreatureGraphicInfo, MASK0x0004_FLIP_NON_ATTACK))) { /* If the graphic should be flipped */
                                if (!L0173_B_UseFlippedHorizontallyCreatureFrontImage || !L0177_B_DerivedBitmapInCache) {
                                        A0127_i_NormalizedByteWidth = M77_NORMALIZED_BYTE_WIDTH(L0136_i_ByteWidth);
                                        if (!L0173_B_UseFlippedHorizontallyCreatureFrontImage) {
                                                F007_aAA7_MAIN_CopyBytes(A0128_puc_Bitmap, G074_puc_Bitmap_Temporary, A0127_i_NormalizedByteWidth * L0137_i_Height);
                                                A0128_puc_Bitmap = G074_puc_Bitmap_Temporary;
                                        }
                                        F130_xxxx_VIDEO_FlipHorizontal(A0128_puc_Bitmap, A0127_i_NormalizedByteWidth, L0137_i_Height);
                                }
                                L0165_i_CreaturePaddingPixelCount = (7 - ((L0136_i_ByteWidth - 1) & 0x0007)) << 1;
                        } else {
                                L0165_i_CreaturePaddingPixelCount = 0;
                        }
                }
                A0127_i_Y = L0133_puc_CoordinateSet[C1_Y];
                A0127_i_Y += G223_aac_Graphic558_ShiftSets[A0150_ui_ShiftSetIndex][M23_VERTICAL_OFFSET(L0159_i_CreatureAspect)];
                L0145_s_Box.Y2 = F024_aatz_MAIN_GetMinimumValue(A0127_i_Y, 135);
                L0145_s_Box.Y1 = F025_aatz_MAIN_GetMaximumValue(0, A0127_i_Y - (L0137_i_Height - 1));
                A0127_i_X = L0133_puc_CoordinateSet[C0_X];
                A0127_i_X += G223_aac_Graphic558_ShiftSets[A0150_ui_ShiftSetIndex][M22_HORIZONTAL_OFFSET(L0159_i_CreatureAspect)];
                if (L0138_i_ViewLane == C1_VIEW_LANE_LEFT) {
                        A0127_i_X -= 100;
                } else {
                        if (L0138_i_ViewLane) { /* Lane right */
                                A0127_i_X += 100;
                        }
                }
                if (!(L0145_s_Box.X2 = F026_a003_MAIN_GetBoundedValue(0, A0127_i_X + L0136_i_ByteWidth, 223))) {
                        goto T115_126_CreatureNotVisible;
                }
                if (L0145_s_Box.X1 = F026_a003_MAIN_GetBoundedValue(0, A0127_i_X - L0136_i_ByteWidth + 1, 223)) {
                        if (L0145_s_Box.X1 == 223) {
                                goto T115_126_CreatureNotVisible;
                        }
                        AP141_ui_CreatureX = L0165_i_CreaturePaddingPixelCount;
                } else {
                        AP141_ui_CreatureX = L0165_i_CreaturePaddingPixelCount + (L0136_i_ByteWidth - A0127_i_X - 1);
                }
                F132_xzzz_VIDEO_Blit(A0128_puc_Bitmap, G296_puc_Bitmap_Viewport, &L0145_s_Box, AP141_ui_CreatureX, 0, M77_NORMALIZED_BYTE_WIDTH(L0136_i_ByteWidth), C112_BYTE_WIDTH_VIEWPORT, L0162_i_TransparentColor);
                T115_126_CreatureNotVisible:
                if (L0167_B_TwoHalfSquareCreaturesFrontView) {
                        L0167_B_TwoHalfSquareCreaturesFrontView = FALSE;
                        L0159_i_CreatureAspect = L0153_ps_ActiveGroup->Aspect[!L0161_i_CreatureIndex]; /* Aspect of the other creature in the pair */
                        if (A0126_i_ViewCell == C01_VIEW_CELL_RIGHT_COLUMN) {
                                A0126_i_ViewCell = C00_VIEW_CELL_LEFT_COLUMN;
                        } else {
                                A0126_i_ViewCell = C01_VIEW_CELL_RIGHT_COLUMN;
                        }
                        goto T115_077_DrawSecondHalfSquareCreature;
                }
/* Draw projectiles */
                T115_129_DrawProjectiles:
                if (!L0186_B_SquareHasProjectile || ((P145_i_ViewSquareIndex = A0147_ui_ViewSquareIndexBackup) > C09_VIEW_SQUARE_D0C) || (!(L0180_i_ProjectileX = G218_aaaauc_Graphic558_ObjectCoordinateSets[0][P145_i_ViewSquareIndex][A0126_i_ViewCell = L0187_ui_CurrentViewCellToDraw][C0_X]))) { /* If there is no projectile to draw or if projectiles are not visible on the specified square or on the cell being drawn */
                        continue;
                }
                P141_T_Thing = L0146_T_FirstThingToDraw; /* Restart processing list of objects from the beginning. The next loop draws only projectile objects among the list */
                do {
                        if ((M12_TYPE(P141_T_Thing) == C14_THING_TYPE_PROJECTILE) && (M11_CELL(P141_T_Thing) == L0139_i_Cell)) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                L0178_ps_Projectile = &((PROJECTILE*)G284_apuc_ThingData[C14_THING_TYPE_PROJECTILE])[M13_INDEX(P141_T_Thing)];
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_01_OPTIMIZATION Inline code replaced by function calls */
                                L0178_ps_Projectile = (PROJECTILE*)F156_afzz_DUNGEON_GetThingData(P141_T_Thing);
#endif
                                if ((A0127_i_ProjectileAspect = F142_aqzz_DUNGEON_GetProjectileAspect(L0178_ps_Projectile->Slot)) < 0) { /* Negative value: projectile aspect is the ordinal of a PROJECTIL_ASPECT */
                                        L0129_ps_ObjectAspect = (OBJECT_ASPECT*)&G210_as_Graphic558_ProjectileAspects[M01_ORDINAL_TO_INDEX(-A0127_i_ProjectileAspect)];
                                        A0127_i_NativeBitmapIndex = ((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->FirstNativeBitmapRelativeIndex + C316_GRAPHIC_FIRST_PROJECTILE;
                                        L0182_i_ProjectileAspectType = M07_GET(((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->GraphicInfo, MASK0x0003_ASPECT_TYPE);
                                        if (((L0184_B_DoNotScaleWithKineticEnergy = !M07_GET(((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->GraphicInfo, MASK0x0100_SCALE_WITH_KINETIC_ENERGY)) || (L0178_ps_Projectile->KineticEnergy == 255)) && (P145_i_ViewSquareIndex == C09_VIEW_SQUARE_D0C)) {
                                                L0176_i_Scale = 0; /* Use native bitmap without resizing */
                                                L0136_i_ByteWidth = ((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->ByteWidth;
                                                L0137_i_Height = ((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->Height;
                                        } else {
                                                A0150_ui_ProjectileScaleIndex = ((P145_i_ViewSquareIndex / 3) << 1) + (A0126_i_ViewCell >> 1);
                                                L0176_i_Scale = G215_auc_Graphic558_ProjectileScales[A0150_ui_ProjectileScaleIndex];
                                                if (!L0184_B_DoNotScaleWithKineticEnergy) {
                                                        L0176_i_Scale = (L0176_i_Scale * F025_aatz_MAIN_GetMaximumValue(96, L0178_ps_Projectile->KineticEnergy + 1)) >> 8;
                                                }
                                                L0136_i_ByteWidth = M78_SCALED_DIMENSION(((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->ByteWidth, L0176_i_Scale);
                                                L0137_i_Height = M78_SCALED_DIMENSION(((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->Height, L0176_i_Scale);
                                        }
                                        if (L0189_B_ProjectileAspectTypeHasBackGraphicAndRotation = (L0182_i_ProjectileAspectType == C0_PROJECTILE_ASPECT_TYPE_HAS_BACK_GRAPHIC_AND_ROTATION)) {
                                                L0188_B_ProjectileFlipVertical = ((P143_i_MapX + P144_i_MapY) & 0x0001);
                                        }
                                        if (L0182_i_ProjectileAspectType == C3_PROJECTILE_ASPECT_TYPE_NO_BACK_GRAPHIC_AND_NO_ROTATION) {
                                                L0183_i_ProjectileBitmapIndexDelta = 0;
                                                L0190_B_FlipVertical = L0143_B_FlipHorizontal = FALSE;
                                        } else {
                                                if (M16_IS_ORIENTED_WEST_EAST(L0181_i_ProjectileDirection = G370_ps_Events[L0178_ps_Projectile->EventIndex].C.Projectile.Direction) != M16_IS_ORIENTED_WEST_EAST(P142_i_Direction)) {
                                                        if (L0182_i_ProjectileAspectType == C2_PROJECTILE_ASPECT_TYPE_NO_BACK_GRAPHIC_AND_ROTATION) {
                                                                L0183_i_ProjectileBitmapIndexDelta = 1;
                                                        } else {
                                                                L0183_i_ProjectileBitmapIndexDelta = 2;
                                                        }
                                                        if (L0189_B_ProjectileAspectTypeHasBackGraphicAndRotation) {
                                                                L0143_B_FlipHorizontal = !A0126_i_ViewCell || (A0126_i_ViewCell == C03_VIEW_CELL_BACK_LEFT);
                                                                if (!(L0190_B_FlipVertical = L0188_B_ProjectileFlipVertical)) {
                                                                        L0143_B_FlipHorizontal = !L0143_B_FlipHorizontal;
                                                                }
                                                        } else {
                                                                L0190_B_FlipVertical = FALSE;
                                                                L0143_B_FlipHorizontal = (M17_NEXT(P142_i_Direction) == L0181_i_ProjectileDirection);
                                                        }
                                                } else {
                                                        if ((L0182_i_ProjectileAspectType >= C2_PROJECTILE_ASPECT_TYPE_NO_BACK_GRAPHIC_AND_ROTATION) || ((L0182_i_ProjectileAspectType == C1_PROJECTILE_ASPECT_TYPE_HAS_BACK_GRAPHIC_AND_NO_ROTATION) && (L0181_i_ProjectileDirection != P142_i_Direction)) || (L0189_B_ProjectileAspectTypeHasBackGraphicAndRotation && L0188_B_ProjectileFlipVertical)) { /* If the projectile does not have a back graphic or has one but is not seen from the back or if it has a back graphic and rotation and should be flipped vertically */
                                                                L0183_i_ProjectileBitmapIndexDelta = 0;
                                                        } else {
                                                                L0183_i_ProjectileBitmapIndexDelta = 1;
                                                        }
                                                        L0190_B_FlipVertical = L0189_B_ProjectileAspectTypeHasBackGraphicAndRotation && (A0126_i_ViewCell < C02_VIEW_CELL_BACK_RIGHT);
                                                        L0143_B_FlipHorizontal = M07_GET(((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->GraphicInfo, MASK0x0010_SIDE) && !((L0138_i_ViewLane == C2_VIEW_LANE_RIGHT) || (!L0138_i_ViewLane && ((A0126_i_ViewCell == C01_VIEW_CELL_FRONT_RIGHT) || (A0126_i_ViewCell == C02_VIEW_CELL_BACK_RIGHT))));
                                                }
                                        }
                                        A0127_i_NativeBitmapIndex += L0183_i_ProjectileBitmapIndexDelta;
                                        L0140_i_PaddingPixelCount = 0;
                                        if (!L0176_i_Scale) {
                                                A0128_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(A0127_i_NativeBitmapIndex);
                                        } else {
                                                if (L0143_B_FlipHorizontal) {
                                                        L0140_i_PaddingPixelCount = (7 - ((L0136_i_ByteWidth - 1) & 0x0007)) << 1;
                                                }
                                                if (L0184_B_DoNotScaleWithKineticEnergy && F491_xzzz_CACHE_IsDerivedBitmapInCache(L0134_i_DerivedBitmapIndex = C282_DERIVED_BITMAP_FIRST_PROJECTILE + ((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->FirstDerivedBitmapRelativeIndex + (L0183_i_ProjectileBitmapIndexDelta * 6) + A0150_ui_ProjectileScaleIndex)) {
                                                        A0128_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(L0134_i_DerivedBitmapIndex);
                                                } else {
                                                        L0132_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(A0127_i_NativeBitmapIndex);
                                                        if (L0184_B_DoNotScaleWithKineticEnergy) {
                                                                A0128_puc_Bitmap = F492_mzzz_CACHE_GetDerivedBitmap(L0134_i_DerivedBitmapIndex);
                                                        } else {
                                                                A0128_puc_Bitmap = G074_puc_Bitmap_Temporary;
                                                        }
                                                        F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(L0132_puc_Bitmap, A0128_puc_Bitmap, ((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->ByteWidth << 1, ((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->Height, L0136_i_ByteWidth << 1, L0137_i_Height, G075_apuc_PaletteChanges_Projectile[A0150_ui_ProjectileScaleIndex >> 1]);
                                                        if (L0184_B_DoNotScaleWithKineticEnergy) {
                                                                F493_hzzz_CACHE_AddDerivedBitmap(L0134_i_DerivedBitmapIndex);
                                                        }
                                                }
                                        }
                                        if (L0143_B_FlipHorizontal || L0190_B_FlipVertical) {
                                                A0127_i_NormalizedByteWidth = M77_NORMALIZED_BYTE_WIDTH(L0136_i_ByteWidth);
                                                if (A0128_puc_Bitmap != G074_puc_Bitmap_Temporary) {
                                                        F007_aAA7_MAIN_CopyBytes(A0128_puc_Bitmap, G074_puc_Bitmap_Temporary, A0127_i_NormalizedByteWidth * L0137_i_Height);
                                                        A0128_puc_Bitmap = G074_puc_Bitmap_Temporary;
                                                }
                                                if (L0190_B_FlipVertical) {
                                                        F131_xxxx_VIDEO_FlipVertical(A0128_puc_Bitmap, A0127_i_NormalizedByteWidth, L0137_i_Height);
                                                }
                                                if (L0143_B_FlipHorizontal) {
                                                        F130_xxxx_VIDEO_FlipHorizontal(A0128_puc_Bitmap, A0127_i_NormalizedByteWidth, L0137_i_Height);
                                                }
                                        }
                                        L0145_s_Box.Y2 = (L0137_i_Height >> 1) + 47;
                                        L0145_s_Box.Y1 = 47 - (L0137_i_Height >> 1) + !(L0137_i_Height & 0x0001);
                                        L0145_s_Box.X2 = F024_aatz_MAIN_GetMinimumValue(223, L0180_i_ProjectileX + L0136_i_ByteWidth);
                                        if (L0145_s_Box.X1 = F025_aatz_MAIN_GetMaximumValue(0, L0180_i_ProjectileX - L0136_i_ByteWidth + 1)) {
                                                if (L0143_B_FlipHorizontal) {
                                                        A0127_i_X = L0140_i_PaddingPixelCount;
                                                } else {
                                                        A0127_i_X = 0;
                                                }
                                        } else {
                                                A0127_i_X = F025_aatz_MAIN_GetMaximumValue(L0140_i_PaddingPixelCount, L0136_i_ByteWidth - L0180_i_ProjectileX - 1); /* BUG0_06 Graphical glitch when drawing projectiles or explosions. If a projectile or explosion bitmap is cropped because it is only partly visible on the left side of the viewport (L0145_s_Box.X1 = 0) and the bitmap is flipped horizontally (L0143_B_FlipHorizontal = TRUE) then a wrong part of the bitmap is drawn on screen. To fix this bug, "+ L0140_i_PaddingPixelCount" must be added to the second parameter of this function call */

                                        }
                                        F132_xzzz_VIDEO_Blit(A0128_puc_Bitmap, G296_puc_Bitmap_Viewport, &L0145_s_Box, A0127_i_X, 0, M77_NORMALIZED_BYTE_WIDTH(L0136_i_ByteWidth), C112_BYTE_WIDTH_VIEWPORT, C10_COLOR_FLESH);
                                } else { /* Positive value: projectile aspect is the index of a OBJECT_ASPECT */
                                        L0142_B_UseAlcoveObjectImage = FALSE;
                                        L0179_auc_ProjectileCoordinates[C0_X] = L0180_i_ProjectileX;
                                        L0179_auc_ProjectileCoordinates[C1_Y] = 47;
                                        L0133_puc_CoordinateSet = L0179_auc_ProjectileCoordinates;
                                        L0129_ps_ObjectAspect = &G209_as_Graphic558_ObjectAspects[A0127_i_ProjectileAspect];
                                        A0127_i_NativeBitmapIndex = L0129_ps_ObjectAspect->FirstNativeBitmapRelativeIndex + C360_GRAPHIC_FIRST_OBJECT;
                                        L0185_B_DrawProjectileAsObject = TRUE;
                                        goto T115_015_DrawProjectileAsObject; /* Go to code section to draw an object. Once completed, it jumps back to T115_171_BackFromT115_015_DrawProjectileAsObject below */
                                }
                        }
                        T115_171_BackFromT115_015_DrawProjectileAsObject: ;
                } while ((P141_T_Thing = F159_rzzz_DUNGEON_GetNextThing(P141_T_Thing)) != C0xFFFE_THING_ENDOFLIST);
#ifndef NOCOPYPROTECTION
                if (L0199_B_ProceedToNextState_COPYPROTECTIONF) { /* If G069_ui_State_COPYPROTECTIONF = 10 or 11 */
                        L0199_B_ProceedToNextState_COPYPROTECTIONF = FALSE;
                        if ((G069_ui_State_COPYPROTECTIONF = G069_ui_State_COPYPROTECTIONF + 6) > 16) {
                                G069_ui_State_COPYPROTECTIONF -= 3;
                        }
                } /* If G069_ui_State_COPYPROTECTIONF was 10 it is now 16, if it was 11 it is now 13 */
#endif
        } while (L0130_ul_RemainingViewCellOrdinalsToProcess);
/* Draw explosions */
        if (!L0195_B_SquareHasExplosion) {
                return;
        }
        L0192_ps_FluxcageExplosion = NULL;
        AP145_i_ViewSquareExplosionIndex = A0147_ui_ViewSquareIndexBackup + 3; /* Convert square index to square index for explosions */
        A0147_ui_ExplosionScaleIndex = AP145_i_ViewSquareExplosionIndex / 3;
        P141_T_Thing = L0146_T_FirstThingToDraw; /* Restart processing list of things from the beginning. The next loop draws only explosion things among the list */
        do {
                if (M12_TYPE(P141_T_Thing) == C15_THING_TYPE_EXPLOSION) {
                        A0126_i_Cell = M11_CELL(P141_T_Thing);
#ifdef C02_COMPILE_DM10aEN_DM10bEN_DM11EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                        L0191_ps_Explosion = &((EXPLOSION*)G284_apuc_ThingData[C15_THING_TYPE_EXPLOSION])[M13_INDEX(P141_T_Thing)];
#endif
#ifdef C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE3_02_OPTIMIZATION Inline code replaced by function calls */
                        L0191_ps_Explosion = (EXPLOSION*)F156_afzz_DUNGEON_GetThingData(P141_T_Thing);
#endif
                        if ((L0196_B_RebirthExplosion = ((A0127_i_ExplosionType = L0191_ps_Explosion->Type) >= C100_EXPLOSION_REBIRTH_STEP1)) && ((AP145_i_ViewSquareExplosionIndex < C03_VIEW_SQUARE_D3C_EXPLOSION) || (AP145_i_ViewSquareExplosionIndex > C09_VIEW_SQUARE_D1C_EXPLOSION) || (A0126_i_Cell != L0139_i_Cell))) { /* If explosion is rebirth and is not visible */
                                continue;
                        }
                        L0197_B_Smoke = FALSE;
                        if ((A0127_i_ExplosionType == C000_EXPLOSION_FIREBALL) || (A0127_i_ExplosionType == C002_EXPLOSION_LIGHTNING_BOLT) || (A0127_i_ExplosionType == C101_EXPLOSION_REBIRTH_STEP2)) {
                                A0127_i_ExplosionAspectIndex = C0_EXPLOSION_ASPECT_FIRE;
                        } else {
                                if ((A0127_i_ExplosionType == C006_EXPLOSION_POISON_BOLT) || (A0127_i_ExplosionType == C007_EXPLOSION_POISON_CLOUD)) {
                                        A0127_i_ExplosionAspectIndex = C2_EXPLOSION_ASPECT_POISON;
                                } else {
                                        if (A0127_i_ExplosionType == C040_EXPLOSION_SMOKE) {
                                                L0197_B_Smoke = TRUE;
                                                A0127_i_ExplosionAspectIndex = C3_EXPLOSION_ASPECT_SMOKE;
                                        } else {
                                                if (A0127_i_ExplosionType == C100_EXPLOSION_REBIRTH_STEP1) {
                                                        L0129_ps_ObjectAspect = (OBJECT_ASPECT*)&G210_as_Graphic558_ProjectileAspects[M01_ORDINAL_TO_INDEX(-F142_aqzz_DUNGEON_GetProjectileAspect(C0xFF82_THING_EXPLOSION_LIGHTNING_BOLT))];
                                                        A0128_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->FirstNativeBitmapRelativeIndex + (C316_GRAPHIC_FIRST_PROJECTILE + 1));
                                                        L0193_pi_ExplosionCoordinates = G228_aai_Graphic558_RebirthStep1ExplosionCoordinates[AP145_i_ViewSquareExplosionIndex - 3];
                                                        L0136_i_ByteWidth = M78_SCALED_DIMENSION((((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->ByteWidth), L0193_pi_ExplosionCoordinates[C2_SCALE]);
                                                        L0137_i_Height = M78_SCALED_DIMENSION((((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->Height), L0193_pi_ExplosionCoordinates[C2_SCALE]);
                                                        if (AP145_i_ViewSquareExplosionIndex != C09_VIEW_SQUARE_D1C_EXPLOSION) {
                                                                F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(A0128_puc_Bitmap, G074_puc_Bitmap_Temporary, ((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->ByteWidth << 1, ((PROJECTIL_ASPECT*)L0129_ps_ObjectAspect)->Height, L0136_i_ByteWidth << 1, L0137_i_Height, G017_auc_Graphic562_PaletteChanges_NoChanges);
                                                                A0128_puc_Bitmap = G074_puc_Bitmap_Temporary;
                                                        }
                                                        goto T115_200_DrawExplosion;
                                                }
                                                if (A0127_i_ExplosionType == C050_EXPLOSION_FLUXCAGE) {
                                                        if (AP145_i_ViewSquareExplosionIndex >= C04_VIEW_SQUARE_D3L_EXPLOSION) {
                                                                L0192_ps_FluxcageExplosion = L0191_ps_Explosion;
                                                        }
                                                        continue;
                                                }
                                                A0127_i_ExplosionAspectIndex = C1_EXPLOSION_ASPECT_SPELL;
                                        }
                                }
                        }
                        if (AP145_i_ViewSquareExplosionIndex == C12_VIEW_SQUARE_D0C_EXPLOSION) {
                                if (L0197_B_Smoke) {
                                        A0127_i_ExplosionAspectIndex--; /* Smoke uses the same graphics as Poison Cloud, but with palette changes */
                                }
                                A0127_i_ExplosionAspectIndex = A0127_i_ExplosionAspectIndex * 3; /* 3 graphics per explosion pattern */
                                if (A0126_i_ExplosionSize = (L0191_ps_Explosion->Attack >> 5)) {
                                        A0127_i_ExplosionAspectIndex++; /* Use second graphic in the pattern for medium explosion attack */
                                        if (A0126_i_ExplosionSize > 3) {
                                                A0127_i_ExplosionAspectIndex++; /* Use third graphic in the pattern for large explosion attack */
                                        }
                                }
                                F491_xzzz_CACHE_IsDerivedBitmapInCache(C000_DERIVED_BITMAP_VIEWPORT);
                                A0128_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(A0127_i_ExplosionAspectIndex + C351_GRAPHIC_FIRST_EXPLOSION_PATTERN);
                                if (L0197_B_Smoke) {
                                        F129_szzz_VIDEO_BlitShrinkWithPaletteChanges(A0128_puc_Bitmap, G074_puc_Bitmap_Temporary, 48, 32, 48, 32, G212_auc_Graphic558_PaletteChanges_Smoke);
                                        A0128_puc_Bitmap = G074_puc_Bitmap_Temporary;
                                }
                                F133_xxxx_VIDEO_BlitBoxFilledWithMaskedBitmap(A0128_puc_Bitmap, G296_puc_Bitmap_Viewport, NULL, F492_mzzz_CACHE_GetDerivedBitmap(C000_DERIVED_BITMAP_VIEWPORT), &G105_s_Graphic558_Box_ExplosionPattern_D0C, M04_RANDOM(4) + 87, M03_RANDOM(64), C112_BYTE_WIDTH_VIEWPORT, MASK0x0080_DO_NOT_USE_MASK | C10_COLOR_FLESH, 0, 0);
                                F493_hzzz_CACHE_AddDerivedBitmap(C000_DERIVED_BITMAP_VIEWPORT);
                                F480_AA07_CACHE_ReleaseBlock(C000_DERIVED_BITMAP_VIEWPORT | MASK0x8000_DERIVED_BITMAP);
#ifndef NOCOPYPROTECTION
                                if ((G031_i_Graphic562_Sector7Analyzed_COPYPROTECTIONE != C00136_TRUE) && (!F277_jzzz_COPYPROTECTIONE_IsSector7Valid_FuzzyBits(G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE))) {
                                        G189_i_Graphic558_StopAddingEvents_COPYPROTECTIONE = C00136_TRUE;
                                }
#endif
                        } else {
                                if (L0196_B_RebirthExplosion) {
                                        L0193_pi_ExplosionCoordinates = G227_aai_Graphic558_RebirthStep2ExplosionCoordinates[AP145_i_ViewSquareExplosionIndex - 3];
                                        L0194_i_ExplosionScale = L0193_pi_ExplosionCoordinates[C2_SCALE];
                                } else {
                                        if (L0191_ps_Explosion->Centered) {
                                                L0193_pi_ExplosionCoordinates = G225_aai_Graphic558_CenteredExplosionCoordinates[AP145_i_ViewSquareExplosionIndex];
                                        } else {
                                                if ((A0126_i_Cell == P142_i_Direction) || (A0126_i_Cell == M20_PREVIOUS(P142_i_Direction))) {
                                                        A0126_i_ViewCell = C00_VIEW_CELL_FRONT_LEFT;
                                                } else {
                                                        A0126_i_ViewCell = C01_VIEW_CELL_FRONT_RIGHT;
                                                }
                                                L0193_pi_ExplosionCoordinates = G226_aaai_Graphic558_ExplosionCoordinates[AP145_i_ViewSquareExplosionIndex][A0126_i_ViewCell];
                                        }
                                        L0194_i_ExplosionScale = F025_aatz_MAIN_GetMaximumValue(4, (F025_aatz_MAIN_GetMaximumValue(48, L0191_ps_Explosion->Attack + 1) * G216_auc_Graphic558_ExplosionBaseScales[A0147_ui_ExplosionScaleIndex]) >> 8) & 0xFFFE;
                                }
                                A0128_puc_Bitmap = F114_xxxx_DUNGEONVIEW_GetExplosionBitmap(A0127_i_ExplosionAspectIndex, L0194_i_ExplosionScale, &L0136_i_ByteWidth, &L0137_i_Height);
                                T115_200_DrawExplosion:
                                L0190_B_FlipVertical = M05_RANDOM(2);
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_02_FIX The variable is always set so that explosions are drawn correctly */
                                L0140_i_PaddingPixelCount = 0;
#endif
                                if (L0143_B_FlipHorizontal = M05_RANDOM(2)) {
                                        L0140_i_PaddingPixelCount = (7 - ((L0136_i_ByteWidth - 1) & 0x0007)) << 1; /* Number of unused pixels in the units on the right of the bitmap */
                                }
                                L0145_s_Box.Y2 = F024_aatz_MAIN_GetMinimumValue(135, L0193_pi_ExplosionCoordinates[C1_Y] + (L0137_i_Height >> 1));
                                A0127_i_Y = F025_aatz_MAIN_GetMaximumValue(0, L0193_pi_ExplosionCoordinates[C1_Y] - (L0137_i_Height >> 1) + !(L0137_i_Height & 0x0001));
                                if (A0127_i_Y >= 136) {
                                        continue;
                                }
                                L0145_s_Box.Y1 = A0127_i_Y;
                                if ((A0127_i_X = F024_aatz_MAIN_GetMinimumValue(223, L0193_pi_ExplosionCoordinates[C0_X] + L0136_i_ByteWidth)) < 0) {
                                        continue;
                                }
                                L0145_s_Box.X2 = A0127_i_X;
                                A0127_i_X = L0193_pi_ExplosionCoordinates[C0_X];
                                if (L0145_s_Box.X1 = F026_a003_MAIN_GetBoundedValue(0, A0127_i_X - L0136_i_ByteWidth + 1, 223)) {
#ifdef C01_COMPILE_DM10aEN_DM10bEN /* CHANGE2_02_FIX */
                                        if (L0143_B_FlipHorizontal) {
                                                A0127_i_X = L0140_i_PaddingPixelCount;
                                        } else {
                                                A0127_i_X = 0;
                                        }
#endif
#ifdef C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN /* CHANGE2_02_FIX */
                                        A0127_i_X = L0140_i_PaddingPixelCount;
#endif
                                } else {
                                        A0127_i_X = F025_aatz_MAIN_GetMaximumValue(L0140_i_PaddingPixelCount, L0136_i_ByteWidth - A0127_i_X - 1); /* BUG0_07 Graphical glitch when drawing explosions. If an explosion bitmap is cropped because it is only partly visible on the left side of the viewport (L0145_s_Box.X1 = 0) and the bitmap is not flipped horizontally (L0143_B_FlipHorizontal = FALSE) then the variable L0140_i_PaddingPixelCount is not set before being used here. Its previous value (defined while drawing something else) is used and may cause an incorrect bitmap to be drawn */

                                        /* BUG0_06 Graphical glitch when drawing projectiles or explosions. If a projectile or explosion bitmap is cropped because it is only partly visible on the left side of the viewport (L0145_s_Box.X1 = 0) and the bitmap is flipped horizontally (L0143_B_FlipHorizontal = TRUE) then a wrong part of the bitmap is drawn on screen. To fix this bug, "+ L0140_i_PaddingPixelCount" must be added to the second parameter of this function call */
                                }
                                if (L0145_s_Box.X2 <= L0145_s_Box.X1) {
                                        continue;
                                }
                                L0136_i_ByteWidth = M77_NORMALIZED_BYTE_WIDTH(L0136_i_ByteWidth);
                                if (L0143_B_FlipHorizontal || L0190_B_FlipVertical) {
                                        F007_aAA7_MAIN_CopyBytes(A0128_puc_Bitmap, G074_puc_Bitmap_Temporary, L0136_i_ByteWidth * L0137_i_Height);
                                        A0128_puc_Bitmap = G074_puc_Bitmap_Temporary;
                                }
                                if (L0143_B_FlipHorizontal) {
                                        F130_xxxx_VIDEO_FlipHorizontal(A0128_puc_Bitmap, L0136_i_ByteWidth, L0137_i_Height);
                                }
                                if (L0190_B_FlipVertical) {
                                        F131_xxxx_VIDEO_FlipVertical(A0128_puc_Bitmap, L0136_i_ByteWidth, L0137_i_Height);
                                }
                                F132_xzzz_VIDEO_Blit(A0128_puc_Bitmap, G296_puc_Bitmap_Viewport, &L0145_s_Box, A0127_i_X, 0, L0136_i_ByteWidth, C112_BYTE_WIDTH_VIEWPORT, C10_COLOR_FLESH);
                        }
                }
        } while ((P141_T_Thing = F159_rzzz_DUNGEON_GetNextThing(P141_T_Thing)) != C0xFFFE_THING_ENDOFLIST);
        if ((L0192_ps_FluxcageExplosion != NULL) && (L0175_i_DoorFrontViewDrawingPass != 1) && !G077_B_DoNotDrawFluxcagesDuringEndgame) { /* Fluxcage is an explosion displayed as a field (like teleporters), above all other graphics */
                AP145_i_ViewSquareExplosionIndex -= 3; /* Convert square index for explosions back to square index */
                F007_aAA7_MAIN_CopyBytes(&G188_as_Graphic558_FieldAspects[P145_i_ViewSquareIndex], &L0198_s_FieldAspect, sizeof(FIELD_ASPECT));
                (L0198_s_FieldAspect.NativeBitmapRelativeIndex)++; /* NativeBitmapRelativeIndex is now the index of the Fluxcage field graphic */
                F113_xxxx_DUNGEONVIEW_DrawField(&L0198_s_FieldAspect, &G163_as_Graphic558_Frame_Walls[P145_i_ViewSquareIndex]);
        }
}

VOID F116_xxxx_DUNGEONVIEW_DrawSquareD3L(P147_i_Direction, P148_i_MapX, P149_i_MapY)
register int P147_i_Direction;
register int P148_i_MapX;
register int P149_i_MapY;
{
        register int L0200_i_Order;
        int L0201_ai_SquareAspect[5];


        F172_awzz_DUNGEON_SetSquareAspect(L0201_ai_SquareAspect, P147_i_Direction, P148_i_MapX, P149_i_MapY);
        switch (L0201_ai_SquareAspect[C0_ELEMENT]) {
                case C19_ELEMENT_STAIRS_FRONT:
                        if (L0201_ai_SquareAspect[C2_STAIRS_UP]) {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C17_STAIRS_BITMAP_UP_FRONT_D3L], &G110_s_Graphic558_Frame_StairsUpFront_D3L);
                        } else {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C10_STAIRS_BITMAP_DOWN_FRONT_D3L], &G121_s_Graphic558_Frame_StairsDownFront_D3L);
                        }
                        goto T116_015;
                case C00_ELEMENT_WALL:
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C12_WALL_BITMAP_WALL_D3LCR], &G163_as_Graphic558_Frame_Walls[C01_VIEW_SQUARE_D3L]);
                        F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF(L0201_ai_SquareAspect[C2_RIGHT_WALL_ORNAMENT_ORDINAL], C00_VIEW_WALL_D3L_RIGHT);
                        if (F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF(L0201_ai_SquareAspect[C3_FRONT_WALL_ORNAMENT_ORDINAL], C02_VIEW_WALL_D3L_FRONT)) {
                                L0200_i_Order = C0000_CELL_ORDER_ALCOVE;
                                goto T116_017;
                        }
                        return;
                case C16_ELEMENT_DOOR_SIDE:
                case C18_ELEMENT_STAIRS_SIDE:
                        L0200_i_Order = C0321_CELL_ORDER_BACKLEFT_BACKRIGHT_FRONTRIGHT;
                        goto T116_016;
                case C17_ELEMENT_DOOR_FRONT:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0201_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C0_VIEW_FLOOR_D3L);
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0201_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P147_i_Direction, P148_i_MapX, P149_i_MapY, C01_VIEW_SQUARE_D3L, C0218_CELL_ORDER_DOORPASS1_BACKLEFT_BACKRIGHT);
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C05_WALL_BITMAP_DOOR_FRAME_LEFT_D3L], &G164_s_Graphic558_Frame_DoorFrameLeft_D3L);
                        F111_xxxx_DUNGEONVIEW_DrawDoor(L0201_ai_SquareAspect[C3_DOOR_THING_INDEX], L0201_ai_SquareAspect[C2_DOOR_STATE], G080_aai_DoorNativeBitmapIndices[C2_DOOR_BITMAP_FRONT_D3LCR], M75_BITMAP_BYTE_COUNT(48, 41), C0_VIEW_DOOR_ORNAMENT_D3LCR, &G179_s_Graphic558_Frames_Door_D3L);
                        L0200_i_Order = C0349_CELL_ORDER_DOORPASS2_FRONTLEFT_FRONTRIGHT;
                        goto T116_017;
                case C02_ELEMENT_PIT:
                        if (!L0201_ai_SquareAspect[C2_PIT_INVISIBLE]) {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(C049_GRAPHIC_FLOOR_PIT_D3L, &G140_s_Graphic558_Frame_FloorPit_D3L);
                        }
                case C05_ELEMENT_TELEPORTER:
                case C01_ELEMENT_CORRIDOR:
                        T116_015:
                        L0200_i_Order = C3421_CELL_ORDER_BACKLEFT_BACKRIGHT_FRONTLEFT_FRONTRIGHT;
                        T116_016:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0201_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C0_VIEW_FLOOR_D3L); /* BUG0_64 Floor ornaments are drawn over open pits. There is no check to prevent drawing floor ornaments over open pits */
                        T116_017:
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0201_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P147_i_Direction, P148_i_MapX, P149_i_MapY, C01_VIEW_SQUARE_D3L, L0200_i_Order);
        }
        if ((L0201_ai_SquareAspect[C0_ELEMENT] == C05_ELEMENT_TELEPORTER) && L0201_ai_SquareAspect[C2_TELEPORTER_VISIBLE]) {
                F113_xxxx_DUNGEONVIEW_DrawField(&G188_as_Graphic558_FieldAspects[C01_VIEW_SQUARE_D3L], G163_as_Graphic558_Frame_Walls[C01_VIEW_SQUARE_D3L].Box);
        }
}

VOID F117_xxxx_DUNGEONVIEW_DrawSquareD3R(P150_i_Direction, P151_i_MapX, P152_i_MapY)
register int P150_i_Direction;
register int P151_i_MapX;
register int P152_i_MapY;
{
        register int L0202_i_Order;
        int L0203_ai_SquareAspect[5];


        F172_awzz_DUNGEON_SetSquareAspect(L0203_ai_SquareAspect, P150_i_Direction, P151_i_MapX, P152_i_MapY);
        switch (L0203_ai_SquareAspect[C0_ELEMENT]) {
                case C19_ELEMENT_STAIRS_FRONT:
                        if (L0203_ai_SquareAspect[C2_STAIRS_UP]) {
                                F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(G079_ai_StairsNativeBitmapIndices[C17_STAIRS_BITMAP_UP_FRONT_D3L], &G112_s_Graphic558_Frame_StairsUpFront_D3R);
                        } else {
                                F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(G079_ai_StairsNativeBitmapIndices[C10_STAIRS_BITMAP_DOWN_FRONT_D3L], &G123_s_Graphic558_Frame_StairsDownFront_D3R);
                        }
                        goto T117_016;
                case C00_ELEMENT_WALL:
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C12_WALL_BITMAP_WALL_D3LCR], &G163_as_Graphic558_Frame_Walls[C02_VIEW_SQUARE_D3R]);
                        F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF(L0203_ai_SquareAspect[C4_LEFT_WALL_ORNAMENT_ORDINAL], C01_VIEW_WALL_D3R_LEFT);
                        if (F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF(L0203_ai_SquareAspect[C3_FRONT_WALL_ORNAMENT_ORDINAL], C04_VIEW_WALL_D3R_FRONT)) {
                                L0202_i_Order = C0000_CELL_ORDER_ALCOVE;
                                goto T117_018;
                        }
                        return;
                case C16_ELEMENT_DOOR_SIDE:
                case C18_ELEMENT_STAIRS_SIDE:
                        L0202_i_Order = C0412_CELL_ORDER_BACKRIGHT_BACKLEFT_FRONTLEFT;
                        goto T117_017;
                case C17_ELEMENT_DOOR_FRONT:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0203_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C2_VIEW_FLOOR_D3R);
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0203_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P150_i_Direction, P151_i_MapX, P152_i_MapY, C02_VIEW_SQUARE_D3R, C0128_CELL_ORDER_DOORPASS1_BACKRIGHT_BACKLEFT);
                        F007_aAA7_MAIN_CopyBytes(G088_apuc_Bitmap_WallSet[C05_WALL_BITMAP_DOOR_FRAME_LEFT_D3L], G074_puc_Bitmap_Temporary, M75_BITMAP_BYTE_COUNT(32, 44));
                        F103_xxxx_DUNGEONVIEW_DrawDoorFrameBitmapFlippedHorizontally(G074_puc_Bitmap_Temporary, &G165_s_Graphic558_Frame_DoorFrameRight_D3R);
                        if (((DOOR*)G284_apuc_ThingData[C00_THING_TYPE_DOOR])[L0203_ai_SquareAspect[C3_DOOR_THING_INDEX]].Button) {
                                F110_xxxx_DUNGEONVIEW_DrawDoorButton(M00_INDEX_TO_ORDINAL(C0_DOOR_BUTTON), C0_VIEW_DOOR_BUTTON_D3R);
                        }
                        F111_xxxx_DUNGEONVIEW_DrawDoor(L0203_ai_SquareAspect[C3_DOOR_THING_INDEX], L0203_ai_SquareAspect[C2_DOOR_STATE], G080_aai_DoorNativeBitmapIndices[C2_DOOR_BITMAP_FRONT_D3LCR], M75_BITMAP_BYTE_COUNT(48, 41), C0_VIEW_DOOR_ORNAMENT_D3LCR, &G181_s_Graphic558_Frames_Door_D3R);
                        L0202_i_Order = C0439_CELL_ORDER_DOORPASS2_FRONTRIGHT_FRONTLEFT;
                        goto T117_018;
                case C02_ELEMENT_PIT:
                        if (!L0203_ai_SquareAspect[C2_PIT_INVISIBLE]) {
                                F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(C049_GRAPHIC_FLOOR_PIT_D3L, &G142_s_Graphic558_Frame_FloorPit_D3R);
                        }
                case C05_ELEMENT_TELEPORTER:
                case C01_ELEMENT_CORRIDOR:
                        T117_016:
                        L0202_i_Order = C4312_CELL_ORDER_BACKRIGHT_BACKLEFT_FRONTRIGHT_FRONTLEFT;
                        T117_017:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0203_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C2_VIEW_FLOOR_D3R); /* BUG0_64 Floor ornaments are drawn over open pits. There is no check to prevent drawing floor ornaments over open pits */
                        T117_018:
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0203_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P150_i_Direction, P151_i_MapX, P152_i_MapY, C02_VIEW_SQUARE_D3R, L0202_i_Order);
        }
        if ((L0203_ai_SquareAspect[C0_ELEMENT] == C05_ELEMENT_TELEPORTER) && L0203_ai_SquareAspect[C2_TELEPORTER_VISIBLE]) {
                F113_xxxx_DUNGEONVIEW_DrawField(&G188_as_Graphic558_FieldAspects[C02_VIEW_SQUARE_D3R], G163_as_Graphic558_Frame_Walls[C02_VIEW_SQUARE_D3R].Box);
        }
}

VOID F118_xxxx_DUNGEONVIEW_DrawSquareD3C_COPYPROTECTIONF(P153_i_Direction, P154_i_MapX, P155_i_MapY)
register int P153_i_Direction;
register int P154_i_MapX;
register int P155_i_MapY;
{
        register int L0204_i_Order;
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_08_OPTIMIZATION Variable definition changed */
        register VOID (*L0205_pfV_Function)();
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_08_OPTIMIZATION Variable definition changed */
        register char* L0205_pfV_Function;
#endif
        int L0206_ai_SquareAspect[5];


        F172_awzz_DUNGEON_SetSquareAspect(L0206_ai_SquareAspect, P153_i_Direction, P154_i_MapX, P155_i_MapY);
        switch (L0206_ai_SquareAspect[C0_ELEMENT]) {
                case C19_ELEMENT_STAIRS_FRONT:
                        if (L0206_ai_SquareAspect[C2_STAIRS_UP]) {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C16_STAIRS_BITMAP_UP_FRONT_D3C], &G111_s_Graphic558_Frame_StairsUpFront_D3C);
                        } else {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C09_STAIRS_BITMAP_DOWN_FRONT_D3C], &G122_s_Graphic558_Frame_StairsDownFront_D3C);
                        }
                        goto T118_027;
                case C00_ELEMENT_WALL:
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_15_OPTIMIZATION */
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C12_WALL_BITMAP_WALL_D3LCR], &G163_as_Graphic558_Frame_Walls[C00_VIEW_SQUARE_D3C]);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_15_OPTIMIZATION */
                        F101_xxxx_DUNGEONVIEW_DrawWallSetBitmapWithoutTransparency(G088_apuc_Bitmap_WallSet[C12_WALL_BITMAP_WALL_D3LCR], &G163_as_Graphic558_Frame_Walls[C00_VIEW_SQUARE_D3C]);
#endif
                        if (F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF(L0206_ai_SquareAspect[C3_FRONT_WALL_ORNAMENT_ORDINAL], C03_VIEW_WALL_D3C_FRONT)) {
                                L0204_i_Order = C0000_CELL_ORDER_ALCOVE;
                                goto T118_028;
                        }
                        return;
                case C17_ELEMENT_DOOR_FRONT:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0206_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C1_VIEW_FLOOR_D3C);
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0206_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P153_i_Direction, P154_i_MapX, P155_i_MapY, C00_VIEW_SQUARE_D3C, C0218_CELL_ORDER_DOORPASS1_BACKLEFT_BACKRIGHT);
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C04_WALL_BITMAP_DOOR_FRAME_LEFT_D3C], &G166_s_Graphic558_Frame_DoorFrameLeft_D3C);
                        F007_aAA7_MAIN_CopyBytes(G088_apuc_Bitmap_WallSet[C04_WALL_BITMAP_DOOR_FRAME_LEFT_D3C], G074_puc_Bitmap_Temporary, M75_BITMAP_BYTE_COUNT(32, 44));
                        F103_xxxx_DUNGEONVIEW_DrawDoorFrameBitmapFlippedHorizontally(G074_puc_Bitmap_Temporary, &G167_s_Graphic558_Frame_DoorFrameRight_D3C);
                        if (((DOOR*)G284_apuc_ThingData[C00_THING_TYPE_DOOR])[L0206_ai_SquareAspect[C3_DOOR_THING_INDEX]].Button) {
                                F110_xxxx_DUNGEONVIEW_DrawDoorButton(M00_INDEX_TO_ORDINAL(C0_DOOR_BUTTON), C1_VIEW_DOOR_BUTTON_D3C);
                        }
                        F111_xxxx_DUNGEONVIEW_DrawDoor(L0206_ai_SquareAspect[C3_DOOR_THING_INDEX], L0206_ai_SquareAspect[C2_DOOR_STATE], G080_aai_DoorNativeBitmapIndices[C2_DOOR_BITMAP_FRONT_D3LCR], M75_BITMAP_BYTE_COUNT(48, 41), C0_VIEW_DOOR_ORNAMENT_D3LCR, &G180_s_Graphic558_Frames_Door_D3C);
                        L0204_i_Order = C0349_CELL_ORDER_DOORPASS2_FRONTLEFT_FRONTRIGHT;
                        goto T118_028;
                case C02_ELEMENT_PIT:
                        if (!L0206_ai_SquareAspect[C2_PIT_INVISIBLE]) {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(C050_GRAPHIC_FLOOR_PIT_D3C, &G141_s_Graphic558_Frame_FloorPit_D3C);
                        }
#ifndef NOCOPYPROTECTION
                case C05_ELEMENT_TELEPORTER:
                        /* If square D3C is a visible teleporter and criteria is met and there is no ongoing disk activity and the player either (loaded the current game before 66531 ticks of total play time and more than 65530 ticks of total play time have now passed) or (played for at least 8192 ticks since the game was loaded) */
                        if ((G069_ui_State_COPYPROTECTIONF >= 15) &&
                            !G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF &&
                            (((G319_ul_LoadGameTime_COPYPROTECTIONF < 66531L) && (G313_ul_GameTime > 65530L)) || (G313_ul_GameTime > G319_ul_LoadGameTime_COPYPROTECTIONF + 8192))) {
                                switch (M04_RANDOM(4)) {
                                        case 0:
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_08_OPTIMIZATION */
                                                L0205_pfV_Function = &F123_xxxx_DUNGEONVIEW_DrawSquareD1R;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_08_OPTIMIZATION */
                                                L0205_pfV_Function = (char*)&F123_xxxx_DUNGEONVIEW_DrawSquareD1R;
#endif
                                                break;
                                        case 1:
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_08_OPTIMIZATION */
                                                L0205_pfV_Function = &F124_xxxx_DUNGEONVIEW_DrawSquareD1C;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_08_OPTIMIZATION */
                                                L0205_pfV_Function = (char*)&F124_xxxx_DUNGEONVIEW_DrawSquareD1C;
#endif
                                                break;
                                        case 2:
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_08_OPTIMIZATION */
                                                L0205_pfV_Function = &F122_xxxx_DUNGEONVIEW_DrawSquareD1L;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_08_OPTIMIZATION */
                                                L0205_pfV_Function = (char*)&F122_xxxx_DUNGEONVIEW_DrawSquareD1L;
#endif
                                                break;
                                        case 3:
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_08_OPTIMIZATION */
                                                L0205_pfV_Function = &F126_xxxx_DUNGEONVIEW_DrawSquareD0R;
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_08_OPTIMIZATION */
                                                L0205_pfV_Function = (char*)&F126_xxxx_DUNGEONVIEW_DrawSquareD0R;
#endif
                                }
                                F137_pzzz_COPYPROTECTIONEF_PatchFunctionWithHiddenCodeLauncher(L0205_pfV_Function, &F489_ayzz_MEMORY_GetNativeBitmapOrGraphic, C538_GRAPHIC_READ_SECTOR_7, G643_puc_FloppyDiskReadBuffer_COPYPROTECTIONDF, &G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF, G104_apc_CodePatches_COPYPROTECTIONF, 3); /* &G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF is also used by graphic #538 to access G624_B_FloppyDriveTurnedOn_COPYPROTECTIONDF */
                                M08_SET(G644_i_FloppyDiskReadBufferContentType_COPYPROTECTIONDF, MASK0x0001_BUFFER_CONTAINS_SECTOR7);
                                M08_SET(G314_i_SectorsReadRequested_COPYPROTECTIONDF, MASK0x0001_SECTOR7);
                                G069_ui_State_COPYPROTECTIONF -= 10;
                                G071_B_Sector7ReadingInitiated_COPYPROTECTIONF = FALSE;
                        }
#endif
                case C01_ELEMENT_CORRIDOR:
                        T118_027:
                        L0204_i_Order = C3421_CELL_ORDER_BACKLEFT_BACKRIGHT_FRONTLEFT_FRONTRIGHT;
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0206_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C1_VIEW_FLOOR_D3C); /* BUG0_64 Floor ornaments are drawn over open pits. There is no check to prevent drawing floor ornaments over open pits */
                        T118_028:
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0206_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P153_i_Direction, P154_i_MapX, P155_i_MapY, C00_VIEW_SQUARE_D3C, L0204_i_Order);
        }
        if ((L0206_ai_SquareAspect[C0_ELEMENT] == C05_ELEMENT_TELEPORTER) && L0206_ai_SquareAspect[C2_TELEPORTER_VISIBLE]) {
                F113_xxxx_DUNGEONVIEW_DrawField(&G188_as_Graphic558_FieldAspects[C00_VIEW_SQUARE_D3C], G163_as_Graphic558_Frame_Walls[C00_VIEW_SQUARE_D3C].Box);
        }
}

VOID F119_xxxx_DUNGEONVIEW_DrawSquareD2L(P156_i_Direction, P157_i_MapX, P158_i_MapY)
register int P156_i_Direction;
register int P157_i_MapX;
register int P158_i_MapY;
{
        register int L0207_i_Order;
        int L0208_ai_SquareAspect[5];


        F172_awzz_DUNGEON_SetSquareAspect(L0208_ai_SquareAspect, P156_i_Direction, P157_i_MapX, P158_i_MapY);
        switch (L0208_ai_SquareAspect[C0_ELEMENT]) {
                case C19_ELEMENT_STAIRS_FRONT:
                        if (L0208_ai_SquareAspect[C2_STAIRS_UP]) {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C15_STAIRS_BITMAP_UP_FRONT_D2L], &G113_s_Graphic558_Frame_StairsUpFront_D2L);
                        } else {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C08_STAIRS_BITMAP_DOWN_FRONT_D2L], &G124_s_Graphic558_Frame_StairsDownFront_D2L);
                        }
                        goto T119_018;
                case C00_ELEMENT_WALL:
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C11_WALL_BITMAP_WALL_D2LCR], &G163_as_Graphic558_Frame_Walls[C04_VIEW_SQUARE_D2L]);
                        F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF(L0208_ai_SquareAspect[C2_RIGHT_WALL_ORNAMENT_ORDINAL], C05_VIEW_WALL_D2L_RIGHT);
                        if (F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF(L0208_ai_SquareAspect[C3_FRONT_WALL_ORNAMENT_ORDINAL], C07_VIEW_WALL_D2L_FRONT)) {
                                L0207_i_Order = C0000_CELL_ORDER_ALCOVE;
                                goto T119_020;
                        }
                        return;
                case C18_ELEMENT_STAIRS_SIDE:
                        F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C03_STAIRS_BITMAP_SIDE_D2L], &G132_s_Graphic558_Frame_StairsSide_D2L);
                case C16_ELEMENT_DOOR_SIDE:
                        L0207_i_Order = C0342_CELL_ORDER_BACKRIGHT_FRONTLEFT_FRONTRIGHT;
                        goto T119_019;
                case C17_ELEMENT_DOOR_FRONT:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0208_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C3_VIEW_FLOOR_D2L);
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0208_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P156_i_Direction, P157_i_MapX, P158_i_MapY, C04_VIEW_SQUARE_D2L, C0218_CELL_ORDER_DOORPASS1_BACKLEFT_BACKRIGHT);
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C07_WALL_BITMAP_DOOR_FRAME_TOP_D2LCR], &G173_s_Graphic558_Frame_DoorFrameTop_D2L);
                        F111_xxxx_DUNGEONVIEW_DrawDoor(L0208_ai_SquareAspect[C3_DOOR_THING_INDEX], L0208_ai_SquareAspect[C2_DOOR_STATE], G080_aai_DoorNativeBitmapIndices[C1_DOOR_BITMAP_FRONT_D2LCR], M75_BITMAP_BYTE_COUNT(64, 61), C1_VIEW_DOOR_ORNAMENT_D2LCR, &G182_s_Graphic558_Frames_Door_D2L);
                        L0207_i_Order = C0349_CELL_ORDER_DOORPASS2_FRONTLEFT_FRONTRIGHT;
                        goto T119_020;
                case C02_ELEMENT_PIT:
                        F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(L0208_ai_SquareAspect[C2_PIT_INVISIBLE] ? C057_GRAPHIC_FLOOR_PIT_INVISIBLE_D2L : C051_GRAPHIC_FLOOR_PIT_D2L, &G143_s_Graphic558_Frame_FloorPit_D2L);
                case C05_ELEMENT_TELEPORTER:
                case C01_ELEMENT_CORRIDOR:
                        T119_018:
                        L0207_i_Order = C3421_CELL_ORDER_BACKLEFT_BACKRIGHT_FRONTLEFT_FRONTRIGHT;
                        T119_019:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0208_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C3_VIEW_FLOOR_D2L); /* BUG0_64 Floor ornaments are drawn over open pits. There is no check to prevent drawing floor ornaments over open pits */
                        T119_020:
                        F112_xxxx_DUNGEONVIEW_DrawCeilingPit(C063_GRAPHIC_CEILING_PIT_D2L, &G152_s_Graphic558_Frame_CeilingPit_D2L, P157_i_MapX, P158_i_MapY, FALSE);
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0208_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P156_i_Direction, P157_i_MapX, P158_i_MapY, C04_VIEW_SQUARE_D2L, L0207_i_Order);
        }
        if ((L0208_ai_SquareAspect[C0_ELEMENT] == C05_ELEMENT_TELEPORTER) && L0208_ai_SquareAspect[C2_TELEPORTER_VISIBLE]) {
                F113_xxxx_DUNGEONVIEW_DrawField(&G188_as_Graphic558_FieldAspects[C04_VIEW_SQUARE_D2L], G163_as_Graphic558_Frame_Walls[C04_VIEW_SQUARE_D2L].Box);
        }
}

VOID F120_xxxx_DUNGEONVIEW_DrawSquareD2R_COPYPROTECTIONF(P159_i_Direction, P160_i_MapX, P161_i_MapY)
register int P159_i_Direction;
register int P160_i_MapX;
register int P161_i_MapY;
{
        register int L0209_i_Order;
        int L0210_ai_SquareAspect[5];


        F172_awzz_DUNGEON_SetSquareAspect(L0210_ai_SquareAspect, P159_i_Direction, P160_i_MapX, P161_i_MapY);
        switch (L0210_ai_SquareAspect[C0_ELEMENT]) {
                case C19_ELEMENT_STAIRS_FRONT:
                        if (L0210_ai_SquareAspect[C2_STAIRS_UP]) {
                                F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(G079_ai_StairsNativeBitmapIndices[C15_STAIRS_BITMAP_UP_FRONT_D2L], &G115_s_Graphic558_Frame_StairsUpFront_D2R);
                        } else {
                                F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(G079_ai_StairsNativeBitmapIndices[C08_STAIRS_BITMAP_DOWN_FRONT_D2L], &G126_s_Graphic558_Frame_StairsDownFront_D2R);
                        }
                        goto T120_027;
                case C00_ELEMENT_WALL:
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C11_WALL_BITMAP_WALL_D2LCR], &G163_as_Graphic558_Frame_Walls[C05_VIEW_SQUARE_D2R]);
                        F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF(L0210_ai_SquareAspect[C4_LEFT_WALL_ORNAMENT_ORDINAL], C06_VIEW_WALL_D2R_LEFT);
                        if (F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF(L0210_ai_SquareAspect[C3_FRONT_WALL_ORNAMENT_ORDINAL], C09_VIEW_WALL_D2R_FRONT)) {
                                L0209_i_Order = C0000_CELL_ORDER_ALCOVE;
                                goto T120_029;
                        }
#ifndef NOCOPYPROTECTION
                        if ((G069_ui_State_COPYPROTECTIONF <= 6) && G071_B_Sector7ReadingInitiated_COPYPROTECTIONF && !G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF) {
                        /* If sector 7 reading operation was initiated and has completed */
                                if (M07_GET(G315_i_SectorsReadFailure_COPYPROTECTIONDF, MASK0x0001_SECTOR7) || !M07_GET(G644_i_FloppyDiskReadBufferContentType_COPYPROTECTIONDF, MASK0x0001_BUFFER_CONTAINS_SECTOR7)) {
                                /* If sector 7 reading failed */
                                        if (M07_GET(G316_i_SectorsReadPreviousFailure_COPYPROTECTIONDF, MASK0x0001_SECTOR7)) {
                                                if (M07_GET(G315_i_SectorsReadFailure_COPYPROTECTIONDF, MASK0x0001_SECTOR7)) {
                                                        G072_ui_GraceReadRetryCount_COPYPROTECTIONF++;
                                                        M09_CLEAR(G315_i_SectorsReadFailure_COPYPROTECTIONDF, MASK0x0001_SECTOR7);
                                                }
                                                M09_CLEAR(G316_i_SectorsReadPreviousFailure_COPYPROTECTIONDF, MASK0x0001_SECTOR7);
                                        } else {
                                                goto T120_011;
                                        }
                                        G069_ui_State_COPYPROTECTIONF += 10; /* Go back to previous step */
                                        T120_011: ;
                                } else {
                                        G070_B_Sector7Analyzed_COPYPROTECTIONF = FALSE;
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_10_IMPROVEMENT */
                                        G073_i_StopFreeingMemory_COPYPROTECTIONF = C00555_TRUE; /* This variable will be reset to C00512_FALSE by graphic #21 by the time its value is checked in F128_rzzz_DUNGEONVIEW_Draw_COPYPROTECTIONF if the next call and patched function executes normally */
#endif
                                        F137_pzzz_COPYPROTECTIONEF_PatchFunctionWithHiddenCodeLauncher(M05_RANDOM(2) ? (char*)&F124_xxxx_DUNGEONVIEW_DrawSquareD1C : (char*)&F125_xxxx_DUNGEONVIEW_DrawSquareD0L, &F489_ayzz_MEMORY_GetNativeBitmapOrGraphic, C021_GRAPHIC_CHECK_FUZZY_BITS_SECTOR_7, G643_puc_FloppyDiskReadBuffer_COPYPROTECTIONDF, &G083_apc_Graphic21Result_COPYPROTECTIONF, G104_apc_CodePatches_COPYPROTECTIONF, 3);
                                        G069_ui_State_COPYPROTECTIONF += 5;
                                }
                        }
#endif
                        return;
                case C18_ELEMENT_STAIRS_SIDE:
                        F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(G079_ai_StairsNativeBitmapIndices[C03_STAIRS_BITMAP_SIDE_D2L], &G133_s_Graphic558_Frame_StairsSide_D2R);
                case C16_ELEMENT_DOOR_SIDE:
                        L0209_i_Order = C0431_CELL_ORDER_BACKLEFT_FRONTRIGHT_FRONTLEFT;
                        goto T120_028;
                case C17_ELEMENT_DOOR_FRONT:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0210_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C5_VIEW_FLOOR_D2R);
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0210_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P159_i_Direction, P160_i_MapX, P161_i_MapY, C05_VIEW_SQUARE_D2R, C0128_CELL_ORDER_DOORPASS1_BACKRIGHT_BACKLEFT);
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C07_WALL_BITMAP_DOOR_FRAME_TOP_D2LCR], &G175_s_Graphic558_Frame_DoorFrameTop_D2R);
                        F111_xxxx_DUNGEONVIEW_DrawDoor(L0210_ai_SquareAspect[C3_DOOR_THING_INDEX], L0210_ai_SquareAspect[C2_DOOR_STATE], G080_aai_DoorNativeBitmapIndices[C1_DOOR_BITMAP_FRONT_D2LCR], M75_BITMAP_BYTE_COUNT(64, 61), C1_VIEW_DOOR_ORNAMENT_D2LCR, &G184_s_Graphic558_Frames_Door_D2R);
                        L0209_i_Order = C0439_CELL_ORDER_DOORPASS2_FRONTRIGHT_FRONTLEFT;
                        goto T120_029;
                case C02_ELEMENT_PIT:
                        F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(L0210_ai_SquareAspect[C2_PIT_INVISIBLE] ? C057_GRAPHIC_FLOOR_PIT_INVISIBLE_D2L : C051_GRAPHIC_FLOOR_PIT_D2L, &G145_s_Graphic558_Frame_FloorPit_D2R);
                case C05_ELEMENT_TELEPORTER:
                case C01_ELEMENT_CORRIDOR:
                        T120_027:
                        L0209_i_Order = C4312_CELL_ORDER_BACKRIGHT_BACKLEFT_FRONTRIGHT_FRONTLEFT;
                        T120_028:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0210_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C5_VIEW_FLOOR_D2R); /* BUG0_64 Floor ornaments are drawn over open pits. There is no check to prevent drawing floor ornaments over open pits */
                        F112_xxxx_DUNGEONVIEW_DrawCeilingPit(C063_GRAPHIC_CEILING_PIT_D2L, &G154_s_Graphic558_Frame_CeilingPit_D2R, P160_i_MapX, P161_i_MapY, TRUE);
                        T120_029:
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0210_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P159_i_Direction, P160_i_MapX, P161_i_MapY, C05_VIEW_SQUARE_D2R, L0209_i_Order);
        }
        if ((L0210_ai_SquareAspect[C0_ELEMENT] == C05_ELEMENT_TELEPORTER) && L0210_ai_SquareAspect[C2_TELEPORTER_VISIBLE]) {
                F113_xxxx_DUNGEONVIEW_DrawField(&G188_as_Graphic558_FieldAspects[C05_VIEW_SQUARE_D2R], G163_as_Graphic558_Frame_Walls[C05_VIEW_SQUARE_D2R].Box);
        }
}

VOID F121_xxxx_DUNGEONVIEW_DrawSquareD2C(P162_i_Direction, P163_i_MapX, P164_i_MapY)
register int P162_i_Direction;
register int P163_i_MapX;
register int P164_i_MapY;
{
        register int L0211_i_Order;
        int L0212_ai_SquareAspect[5];


        F172_awzz_DUNGEON_SetSquareAspect(L0212_ai_SquareAspect, P162_i_Direction, P163_i_MapX, P164_i_MapY);
        switch (L0212_ai_SquareAspect[C0_ELEMENT]) {
                case C19_ELEMENT_STAIRS_FRONT:
                        if (L0212_ai_SquareAspect[C2_STAIRS_UP]) {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C14_STAIRS_BITMAP_UP_FRONT_D2C], &G114_s_Graphic558_Frame_StairsUpFront_D2C);
                        } else {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C07_STAIRS_BITMAP_DOWN_FRONT_D2C], &G125_s_Graphic558_Frame_StairsDownFront_D2C);
                        }
                        goto T121_015;
                case C00_ELEMENT_WALL:
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_15_OPTIMIZATION */
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C11_WALL_BITMAP_WALL_D2LCR], &G163_as_Graphic558_Frame_Walls[C03_VIEW_SQUARE_D2C]);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_15_OPTIMIZATION */
                        F101_xxxx_DUNGEONVIEW_DrawWallSetBitmapWithoutTransparency(G088_apuc_Bitmap_WallSet[C11_WALL_BITMAP_WALL_D2LCR], &G163_as_Graphic558_Frame_Walls[C03_VIEW_SQUARE_D2C]);
#endif
                        if (F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF(L0212_ai_SquareAspect[C3_FRONT_WALL_ORNAMENT_ORDINAL], C08_VIEW_WALL_D2C_FRONT)) {
                                L0211_i_Order = C0000_CELL_ORDER_ALCOVE;
                                goto T121_016;
                        }
                        return;
                case C17_ELEMENT_DOOR_FRONT:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0212_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C4_VIEW_FLOOR_D2C);
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0212_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P162_i_Direction, P163_i_MapX, P164_i_MapY, C03_VIEW_SQUARE_D2C, C0218_CELL_ORDER_DOORPASS1_BACKLEFT_BACKRIGHT);
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C07_WALL_BITMAP_DOOR_FRAME_TOP_D2LCR], &G174_s_Graphic558_Frame_DoorFrameTop_D2C);
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C03_WALL_BITMAP_DOOR_FRAME_LEFT_D2C], &G168_s_Graphic558_Frame_DoorFrameLeft_D2C);
                        F007_aAA7_MAIN_CopyBytes(G088_apuc_Bitmap_WallSet[C03_WALL_BITMAP_DOOR_FRAME_LEFT_D2C], G074_puc_Bitmap_Temporary, M75_BITMAP_BYTE_COUNT(48, 65));
                        F103_xxxx_DUNGEONVIEW_DrawDoorFrameBitmapFlippedHorizontally(G074_puc_Bitmap_Temporary, &G169_s_Graphic558_Frame_DoorFrameRight_D2C);
                        if (((DOOR*)G284_apuc_ThingData[C00_THING_TYPE_DOOR])[L0212_ai_SquareAspect[C3_DOOR_THING_INDEX]].Button) {
                                F110_xxxx_DUNGEONVIEW_DrawDoorButton(M00_INDEX_TO_ORDINAL(C0_DOOR_BUTTON), C2_VIEW_DOOR_BUTTON_D2C);
                        }
                        F111_xxxx_DUNGEONVIEW_DrawDoor(L0212_ai_SquareAspect[C3_DOOR_THING_INDEX], L0212_ai_SquareAspect[C2_DOOR_STATE], G080_aai_DoorNativeBitmapIndices[C1_DOOR_BITMAP_FRONT_D2LCR], M75_BITMAP_BYTE_COUNT(64, 61), C1_VIEW_DOOR_ORNAMENT_D2LCR, &G183_s_Graphic558_Frames_Door_D2C);
                        L0211_i_Order = C0349_CELL_ORDER_DOORPASS2_FRONTLEFT_FRONTRIGHT;
                        goto T121_016;
                case C02_ELEMENT_PIT:
                        F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(L0212_ai_SquareAspect[C2_PIT_INVISIBLE] ? C058_GRAPHIC_FLOOR_PIT_INVISIBLE_D2C : C052_GRAPHIC_FLOOR_PIT_D2C, &G144_s_Graphic558_Frame_FloorPit_D2C);
                case C05_ELEMENT_TELEPORTER:
                case C01_ELEMENT_CORRIDOR:
                        T121_015:
                        L0211_i_Order = C3421_CELL_ORDER_BACKLEFT_BACKRIGHT_FRONTLEFT_FRONTRIGHT;
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0212_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C4_VIEW_FLOOR_D2C); /* BUG0_64 Floor ornaments are drawn over open pits. There is no check to prevent drawing floor ornaments over open pits */
                        F112_xxxx_DUNGEONVIEW_DrawCeilingPit(C064_GRAPHIC_CEILING_PIT_D2C, &G153_s_Graphic558_Frame_CeilingPit_D2C, P163_i_MapX, P164_i_MapY, FALSE);
                        T121_016:
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0212_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P162_i_Direction, P163_i_MapX, P164_i_MapY, C03_VIEW_SQUARE_D2C, L0211_i_Order);
        }
        if ((L0212_ai_SquareAspect[C0_ELEMENT] == C05_ELEMENT_TELEPORTER) && L0212_ai_SquareAspect[C2_TELEPORTER_VISIBLE]) {
                F113_xxxx_DUNGEONVIEW_DrawField(&G188_as_Graphic558_FieldAspects[C03_VIEW_SQUARE_D2C], G163_as_Graphic558_Frame_Walls[C03_VIEW_SQUARE_D2C].Box, &L0212_ai_SquareAspect); /* BUG0_01 Coding error without consequence. Function call with wrong number of parameters. It should be called with 2 parameters. No consequence because additional parameters are ignored */
        }
}

VOID F122_xxxx_DUNGEONVIEW_DrawSquareD1L(P165_i_Direction, P166_i_MapX, P167_i_MapY)
register int P165_i_Direction;
register int P166_i_MapX;
register int P167_i_MapY;
{
        register int L0213_i_Order;
        int L0214_ai_SquareAspect[5];


        F172_awzz_DUNGEON_SetSquareAspect(L0214_ai_SquareAspect, P165_i_Direction, P166_i_MapX, P167_i_MapY);
        switch (L0214_ai_SquareAspect[C0_ELEMENT]) {
                case C19_ELEMENT_STAIRS_FRONT:
                        if (L0214_ai_SquareAspect[C2_STAIRS_UP]) {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C13_STAIRS_BITMAP_UP_FRONT_D1L], &G116_s_Graphic558_Frame_StairsUpFront_D1L);
                        } else {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C06_STAIRS_BITMAP_DOWN_FRONT_D1L], &G127_s_Graphic558_Frame_StairsDownFront_D1L);
                        }
                        goto T122_019;
                case C00_ELEMENT_WALL:
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C10_WALL_BITMAP_WALL_D1LCR], &G163_as_Graphic558_Frame_Walls[C07_VIEW_SQUARE_D1L]);
                        F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF(L0214_ai_SquareAspect[C2_RIGHT_WALL_ORNAMENT_ORDINAL], C10_VIEW_WALL_D1L_RIGHT);
                        return;
                case C18_ELEMENT_STAIRS_SIDE:
                        if (L0214_ai_SquareAspect[C2_STAIRS_UP]) {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C02_STAIRS_BITMAP_UP_SIDE_D1L], &G134_s_Graphic558_Frame_StairsUpSide_D1L);
                        } else {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C01_STAIRS_BITMAP_DOWN_SIDE_D1L], &G136_s_Graphic558_Frame_StairsDownSide_D1L);
                        }
                case C16_ELEMENT_DOOR_SIDE:
                        L0213_i_Order = C0032_CELL_ORDER_BACKRIGHT_FRONTRIGHT;
                        goto T122_020;
                case C17_ELEMENT_DOOR_FRONT:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0214_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C6_VIEW_FLOOR_D1L);
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0214_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P165_i_Direction, P166_i_MapX, P167_i_MapY, C07_VIEW_SQUARE_D1L, C0028_CELL_ORDER_DOORPASS1_BACKRIGHT);
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C06_WALL_BITMAP_DOOR_FRAME_TOP_D1LCR], &G176_s_Graphic558_Frame_DoorFrameTop_D1L);
                        F111_xxxx_DUNGEONVIEW_DrawDoor(L0214_ai_SquareAspect[C3_DOOR_THING_INDEX], L0214_ai_SquareAspect[C2_DOOR_STATE], G080_aai_DoorNativeBitmapIndices[C0_DOOR_BITMAP_FRONT_D1LCR], M75_BITMAP_BYTE_COUNT(96, 88), C2_VIEW_DOOR_ORNAMENT_D1LCR, &G185_s_Graphic558_Frames_Door_D1L);
                        L0213_i_Order = C0039_CELL_ORDER_DOORPASS2_FRONTRIGHT;
                        goto T122_021;
                case C02_ELEMENT_PIT:
                        F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(L0214_ai_SquareAspect[C2_PIT_INVISIBLE] ? C059_GRAPHIC_FLOOR_PIT_INVISIBLE_D1L : C053_GRAPHIC_FLOOR_PIT_D1L, &G146_s_Graphic558_Frame_FloorPit_D1L);
                case C05_ELEMENT_TELEPORTER:
                case C01_ELEMENT_CORRIDOR:
                        T122_019:
                        L0213_i_Order = C0032_CELL_ORDER_BACKRIGHT_FRONTRIGHT;
                        T122_020:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0214_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C6_VIEW_FLOOR_D1L); /* BUG0_64 Floor ornaments are drawn over open pits. There is no check to prevent drawing floor ornaments over open pits */
                        F112_xxxx_DUNGEONVIEW_DrawCeilingPit(C065_GRAPHIC_CEILING_PIT_D1L, &G155_s_Graphic558_Frame_CeilingPit_D1L, P166_i_MapX, P167_i_MapY, FALSE);
                        T122_021:
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0214_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P165_i_Direction, P166_i_MapX, P167_i_MapY, C07_VIEW_SQUARE_D1L, L0213_i_Order);
        }
        if ((L0214_ai_SquareAspect[C0_ELEMENT] == C05_ELEMENT_TELEPORTER) && L0214_ai_SquareAspect[C2_TELEPORTER_VISIBLE]) {
                F113_xxxx_DUNGEONVIEW_DrawField(&G188_as_Graphic558_FieldAspects[C07_VIEW_SQUARE_D1L], G163_as_Graphic558_Frame_Walls[C07_VIEW_SQUARE_D1L].Box, &L0214_ai_SquareAspect); /* BUG0_01 Coding error without consequence. Function call with wrong number of parameters. It should be called with 2 parameters. No consequence because additional parameters are ignored */
        }
}

VOID F123_xxxx_DUNGEONVIEW_DrawSquareD1R(P168_i_Direction, P169_i_MapX, P170_i_MapY)
register int P168_i_Direction;
register int P169_i_MapX;
register int P170_i_MapY;
{
        register int L0215_i_Order;
        int L0216_ai_SquareAspect[5];


        F172_awzz_DUNGEON_SetSquareAspect(L0216_ai_SquareAspect, P168_i_Direction, P169_i_MapX, P170_i_MapY);
        switch (L0216_ai_SquareAspect[C0_ELEMENT]) {
                case C19_ELEMENT_STAIRS_FRONT:
                        if (L0216_ai_SquareAspect[C2_STAIRS_UP]) {
                                F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(G079_ai_StairsNativeBitmapIndices[C13_STAIRS_BITMAP_UP_FRONT_D1L], &G118_s_Graphic558_Frame_StairsUpFront_D1R);
                        } else {
                                F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(G079_ai_StairsNativeBitmapIndices[C06_STAIRS_BITMAP_DOWN_FRONT_D1L], &G129_s_Graphic558_Frame_StairsDownFront_D1R);
                        }
                        goto T123_019;
                case C00_ELEMENT_WALL:
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C10_WALL_BITMAP_WALL_D1LCR], &G163_as_Graphic558_Frame_Walls[C08_VIEW_SQUARE_D1R]);
                        F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF(L0216_ai_SquareAspect[C4_LEFT_WALL_ORNAMENT_ORDINAL], C11_VIEW_WALL_D1R_LEFT);
                        return;
                case C18_ELEMENT_STAIRS_SIDE:
                        if (L0216_ai_SquareAspect[C2_STAIRS_UP]) {
                                F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(G079_ai_StairsNativeBitmapIndices[C02_STAIRS_BITMAP_UP_SIDE_D1L], &G135_s_Graphic558_Frame_StairsUpSide_D1R);
                        } else {
                                F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(G079_ai_StairsNativeBitmapIndices[C01_STAIRS_BITMAP_DOWN_SIDE_D1L], &G137_s_Graphic558_Frame_StairsDownSide_D1R);
                        }
                case C16_ELEMENT_DOOR_SIDE:
                        L0215_i_Order = C0041_CELL_ORDER_BACKLEFT_FRONTLEFT;
                        goto T123_020;
                case C17_ELEMENT_DOOR_FRONT:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0216_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C8_VIEW_FLOOR_D1R);
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0216_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P168_i_Direction, P169_i_MapX, P170_i_MapY, C08_VIEW_SQUARE_D1R, C0018_CELL_ORDER_DOORPASS1_BACKLEFT);
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C06_WALL_BITMAP_DOOR_FRAME_TOP_D1LCR], &G178_s_Graphic558_Frame_DoorFrameTop_D1R);
                        F111_xxxx_DUNGEONVIEW_DrawDoor(L0216_ai_SquareAspect[C3_DOOR_THING_INDEX], L0216_ai_SquareAspect[C2_DOOR_STATE], G080_aai_DoorNativeBitmapIndices[C0_DOOR_BITMAP_FRONT_D1LCR], M75_BITMAP_BYTE_COUNT(96, 88), C2_VIEW_DOOR_ORNAMENT_D1LCR, &G187_s_Graphic558_Frames_Door_D1R);
                        L0215_i_Order = C0049_CELL_ORDER_DOORPASS2_FRONTLEFT;
                        goto T123_021;
                case C02_ELEMENT_PIT:
                        F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(L0216_ai_SquareAspect[C2_PIT_INVISIBLE] ? C059_GRAPHIC_FLOOR_PIT_INVISIBLE_D1L : C053_GRAPHIC_FLOOR_PIT_D1L, &G148_s_Graphic558_Frame_FloorPit_D1R);
                case C05_ELEMENT_TELEPORTER:
                case C01_ELEMENT_CORRIDOR:
                        T123_019:
                        L0215_i_Order = C0041_CELL_ORDER_BACKLEFT_FRONTLEFT;
                        T123_020:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0216_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C8_VIEW_FLOOR_D1R); /* BUG0_64 Floor ornaments are drawn over open pits. There is no check to prevent drawing floor ornaments over open pits */
                        F112_xxxx_DUNGEONVIEW_DrawCeilingPit(C065_GRAPHIC_CEILING_PIT_D1L, &G157_s_Graphic558_Frame_CeilingPit_D1R, P169_i_MapX, P170_i_MapY, TRUE);
                        T123_021:
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0216_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P168_i_Direction, P169_i_MapX, P170_i_MapY, C08_VIEW_SQUARE_D1R, L0215_i_Order);
        }
        if ((L0216_ai_SquareAspect[C0_ELEMENT] == C05_ELEMENT_TELEPORTER) && L0216_ai_SquareAspect[C2_TELEPORTER_VISIBLE]) {
                F113_xxxx_DUNGEONVIEW_DrawField(&G188_as_Graphic558_FieldAspects[C08_VIEW_SQUARE_D1R], G163_as_Graphic558_Frame_Walls[C08_VIEW_SQUARE_D1R].Box, &L0216_ai_SquareAspect); /* BUG0_01 Coding error without consequence. Function call with wrong number of parameters. It should be called with 2 parameters. No consequence because additional parameters are ignored */
        }
}

VOID F124_xxxx_DUNGEONVIEW_DrawSquareD1C(P171_i_Direction, P172_i_MapX, P173_i_MapY)
register int P171_i_Direction;
register int P172_i_MapX;
register int P173_i_MapY;
{
        register int L0217_i_Order;
        int L0218_ai_SquareAspect[5];
        unsigned char* L0219_puc_Bitmap;


        F172_awzz_DUNGEON_SetSquareAspect(L0218_ai_SquareAspect, P171_i_Direction, P172_i_MapX, P173_i_MapY);
        switch (G285_i_SquareAheadElement = L0218_ai_SquareAspect[C0_ELEMENT]) {
                case C19_ELEMENT_STAIRS_FRONT:
                        if (L0218_ai_SquareAspect[C2_STAIRS_UP]) {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C12_STAIRS_BITMAP_UP_FRONT_D1C], &G117_s_Graphic558_Frame_StairsUpFront_D1C);
                        } else {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C05_STAIRS_BITMAP_DOWN_FRONT_D1C], &G128_s_Graphic558_Frame_StairsDownFront_D1C);
                        }
                        goto T124_017;
                case C00_ELEMENT_WALL:
                        G286_B_FacingAlcove = FALSE;
                        G287_B_FacingViAltar = FALSE;
                        G288_B_FacingFountain = FALSE;
                        if (G407_s_Party.Event73Count_ThievesEye) {
                                F491_xzzz_CACHE_IsDerivedBitmapInCache(C001_DERIVED_BITMAP_THIEVES_EYE_VISIBLE_AREA);
                                F132_xzzz_VIDEO_Blit(G296_puc_Bitmap_Viewport, F492_mzzz_CACHE_GetDerivedBitmap(C001_DERIVED_BITMAP_THIEVES_EYE_VISIBLE_AREA), &G107_s_Graphic558_Box_ThievesEye_VisibleArea, G106_s_Graphic558_Box_ThievesEye_ViewportVisibleArea.X1, G106_s_Graphic558_Box_ThievesEye_ViewportVisibleArea.Y1, C112_BYTE_WIDTH_VIEWPORT, C048_BYTE_WIDTH, CM1_COLOR_NO_TRANSPARENCY);
                                L0219_puc_Bitmap = F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C041_GRAPHIC_HOLE_IN_WALL);
                                F132_xzzz_VIDEO_Blit(L0219_puc_Bitmap, F492_mzzz_CACHE_GetDerivedBitmap(C001_DERIVED_BITMAP_THIEVES_EYE_VISIBLE_AREA), &G107_s_Graphic558_Box_ThievesEye_VisibleArea, 0, 0, C048_BYTE_WIDTH, C048_BYTE_WIDTH, C10_COLOR_FLESH); /* BUG0_74 Creatures are drawn with wrong colors when viewed through a wall with the 'Thieve's Eye' spell. The 'hole in wall' graphic is applied to the visible area with transparency on color 10. However the visible area may contain creature graphics that use color 9. When the bitmap is drawn below with transparency on color 9 then the creature graphic is alterated: pixels using color 9 are transparent and the background wall is visible through the creature graphic (grey/white pixels). To fix this bug, the 'hole in wall' graphic should be applied to the wall graphic first (in a temporary buffer) and then the wall with the hole should be drawn over the visible area */
                        }
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_15_OPTIMIZATION */
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C10_WALL_BITMAP_WALL_D1LCR], &G163_as_Graphic558_Frame_Walls[C06_VIEW_SQUARE_D1C]);
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_15_OPTIMIZATION */
                        F101_xxxx_DUNGEONVIEW_DrawWallSetBitmapWithoutTransparency(G088_apuc_Bitmap_WallSet[C10_WALL_BITMAP_WALL_D1LCR], &G163_as_Graphic558_Frame_Walls[C06_VIEW_SQUARE_D1C]);
#endif
                        if (F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF(L0218_ai_SquareAspect[C3_FRONT_WALL_ORNAMENT_ORDINAL], C12_VIEW_WALL_D1C_FRONT)) {
                                F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0218_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P171_i_Direction, P172_i_MapX, P173_i_MapY, C06_VIEW_SQUARE_D1C, C0000_CELL_ORDER_ALCOVE);
                        }
                        if (G407_s_Party.Event73Count_ThievesEye) {
                                F132_xzzz_VIDEO_Blit(F492_mzzz_CACHE_GetDerivedBitmap(C001_DERIVED_BITMAP_THIEVES_EYE_VISIBLE_AREA), G296_puc_Bitmap_Viewport, &G106_s_Graphic558_Box_ThievesEye_ViewportVisibleArea, 0, 0, C048_BYTE_WIDTH, C112_BYTE_WIDTH_VIEWPORT, C09_COLOR_GOLD); /* BUG0_74 */
                                F493_hzzz_CACHE_AddDerivedBitmap(C001_DERIVED_BITMAP_THIEVES_EYE_VISIBLE_AREA);
                                F480_AA07_CACHE_ReleaseBlock(C001_DERIVED_BITMAP_THIEVES_EYE_VISIBLE_AREA | MASK0x8000_DERIVED_BITMAP);
                        }
                        return;
                case C17_ELEMENT_DOOR_FRONT:
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0218_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C7_VIEW_FLOOR_D1C);
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0218_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P171_i_Direction, P172_i_MapX, P173_i_MapY, C06_VIEW_SQUARE_D1C, C0218_CELL_ORDER_DOORPASS1_BACKLEFT_BACKRIGHT);
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C06_WALL_BITMAP_DOOR_FRAME_TOP_D1LCR], &G177_s_Graphic558_Frame_DoorFrameTop_D1C);
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C02_WALL_BITMAP_DOOR_FRAME_LEFT_D1C], &G170_s_Graphic558_Frame_DoorFrameLeft_D1C);
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C00_WALL_BITMAP_DOOR_FRAME_RIGHT_D1C], &G171_s_Graphic558_Frame_DoorFrameRight_D1C);
                        if (((DOOR*)G284_apuc_ThingData[C00_THING_TYPE_DOOR])[L0218_ai_SquareAspect[C3_DOOR_THING_INDEX]].Button) {
                                F110_xxxx_DUNGEONVIEW_DrawDoorButton(M00_INDEX_TO_ORDINAL(C0_DOOR_BUTTON), C3_VIEW_DOOR_BUTTON_D1C);
                        }
                        F111_xxxx_DUNGEONVIEW_DrawDoor(L0218_ai_SquareAspect[C3_DOOR_THING_INDEX], L0218_ai_SquareAspect[C2_DOOR_STATE], G080_aai_DoorNativeBitmapIndices[C0_DOOR_BITMAP_FRONT_D1LCR], M75_BITMAP_BYTE_COUNT(96, 88), C2_VIEW_DOOR_ORNAMENT_D1LCR, &G186_s_Graphic558_Frames_Door_D1C);
                        L0217_i_Order = C0349_CELL_ORDER_DOORPASS2_FRONTLEFT_FRONTRIGHT;
                        goto T124_018;
                case C02_ELEMENT_PIT:
                        F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(L0218_ai_SquareAspect[C2_PIT_INVISIBLE] ? C060_GRAPHIC_FLOOR_PIT_INVISIBLE_D1C : C054_GRAPHIC_FLOOR_PIT_D1C, &G147_s_Graphic558_Frame_FloorPit_D1C);
                case C05_ELEMENT_TELEPORTER:
                case C01_ELEMENT_CORRIDOR:
                        T124_017:
                        L0217_i_Order = C3421_CELL_ORDER_BACKLEFT_BACKRIGHT_FRONTLEFT_FRONTRIGHT;
                        F108_xxxx_DUNGEONVIEW_DrawFloorOrnament(L0218_ai_SquareAspect[C4_FLOOR_ORNAMENT_ORDINAL], C7_VIEW_FLOOR_D1C); /* BUG0_64 Floor ornaments are drawn over open pits. There is no check to prevent drawing floor ornaments over open pits */
                        F112_xxxx_DUNGEONVIEW_DrawCeilingPit(C066_GRAPHIC_CEILING_PIT_D1C, &G156_s_Graphic558_Frame_CeilingPit_D1C, P172_i_MapX, P173_i_MapY, FALSE);
                        T124_018:
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0218_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P171_i_Direction, P172_i_MapX, P173_i_MapY, C06_VIEW_SQUARE_D1C, L0217_i_Order);
        }
        if ((L0218_ai_SquareAspect[C0_ELEMENT] == C05_ELEMENT_TELEPORTER) && L0218_ai_SquareAspect[C2_TELEPORTER_VISIBLE]) {
                F113_xxxx_DUNGEONVIEW_DrawField(&G188_as_Graphic558_FieldAspects[C06_VIEW_SQUARE_D1C], G163_as_Graphic558_Frame_Walls[C06_VIEW_SQUARE_D1C].Box, &L0218_ai_SquareAspect); /* BUG0_01 Coding error without consequence. Function call with wrong number of parameters. It should be called with 2 parameters. No consequence because additional parameters are ignored */
        }
}

VOID F125_xxxx_DUNGEONVIEW_DrawSquareD0L(P174_i_Direction, P175_i_MapX, P176_i_MapY)
register int P174_i_Direction;
register int P175_i_MapX;
register int P176_i_MapY;
{
        int L0220_ai_SquareAspect[5];


        F172_awzz_DUNGEON_SetSquareAspect(L0220_ai_SquareAspect, P174_i_Direction, P175_i_MapX, P176_i_MapY);
        switch (L0220_ai_SquareAspect[C0_ELEMENT]) {
                case C18_ELEMENT_STAIRS_SIDE:
                        F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C00_STAIRS_BITMAP_SIDE_D0L], &G138_s_Graphic558_Frame_StairsSide_D0L);
                        return;
                case C02_ELEMENT_PIT:
                        F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(L0220_ai_SquareAspect[C2_PIT_INVISIBLE] ? C061_GRAPHIC_FLOOR_PIT_INVISIBLE_D0L : C055_GRAPHIC_FLOOR_PIT_D0L, &G149_s_Graphic558_Frame_FloorPit_D0L);
                case C01_ELEMENT_CORRIDOR:
                case C16_ELEMENT_DOOR_SIDE:
                case C05_ELEMENT_TELEPORTER:
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0220_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P174_i_Direction, P175_i_MapX, P176_i_MapY, C10_VIEW_SQUARE_D0L, C0002_CELL_ORDER_BACKRIGHT);
                        break;
                case C00_ELEMENT_WALL:
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C09_WALL_BITMAP_WALL_D0L], &G163_as_Graphic558_Frame_Walls[C10_VIEW_SQUARE_D0L]);
                        return;
        }
        F112_xxxx_DUNGEONVIEW_DrawCeilingPit(C067_GRAPHIC_CEILING_PIT_D0L, &G158_s_Graphic558_Frame_CeilingPit_D0L, P175_i_MapX, P176_i_MapY, FALSE);
        if ((L0220_ai_SquareAspect[C0_ELEMENT] == C05_ELEMENT_TELEPORTER) && L0220_ai_SquareAspect[C2_TELEPORTER_VISIBLE]) {
                F113_xxxx_DUNGEONVIEW_DrawField(&G188_as_Graphic558_FieldAspects[C10_VIEW_SQUARE_D0L], G163_as_Graphic558_Frame_Walls[C10_VIEW_SQUARE_D0L].Box);
        }
}

VOID F126_xxxx_DUNGEONVIEW_DrawSquareD0R(P177_i_Direction, P178_i_MapX, P179_i_MapY)
register int P177_i_Direction;
register int P178_i_MapX;
register int P179_i_MapY;
{
        int L0221_ai_SquareAspect[5];


        F172_awzz_DUNGEON_SetSquareAspect(L0221_ai_SquareAspect, P177_i_Direction, P178_i_MapX, P179_i_MapY);
        switch (L0221_ai_SquareAspect[C0_ELEMENT]) {
                case C18_ELEMENT_STAIRS_SIDE:
                        F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(G079_ai_StairsNativeBitmapIndices[C00_STAIRS_BITMAP_SIDE_D0L], &G139_s_Graphic558_Frame_StairsSide_D0R);
                        return;
                case C02_ELEMENT_PIT:
                        F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(L0221_ai_SquareAspect[C2_PIT_INVISIBLE] ? C061_GRAPHIC_FLOOR_PIT_INVISIBLE_D0L : C055_GRAPHIC_FLOOR_PIT_D0L, &G151_s_Graphic558_Frame_FloorPit_D0R);
                case C01_ELEMENT_CORRIDOR:
                case C16_ELEMENT_DOOR_SIDE:
                case C05_ELEMENT_TELEPORTER:
                        F112_xxxx_DUNGEONVIEW_DrawCeilingPit(C067_GRAPHIC_CEILING_PIT_D0L, &G160_s_Graphic558_Frame_CeilingPit_D0R, P178_i_MapX, P179_i_MapY, TRUE);
                        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0221_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P177_i_Direction, P178_i_MapX, P179_i_MapY, C11_VIEW_SQUARE_D0R, C0001_CELL_ORDER_BACKLEFT);
                        break;
                case C00_ELEMENT_WALL:
                        F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C08_WALL_BITMAP_WALL_D0R], &G163_as_Graphic558_Frame_Walls[C11_VIEW_SQUARE_D0R]);
                        return;
        }
        if ((L0221_ai_SquareAspect[C0_ELEMENT] == C05_ELEMENT_TELEPORTER) && L0221_ai_SquareAspect[C2_TELEPORTER_VISIBLE]) {
                F113_xxxx_DUNGEONVIEW_DrawField(&G188_as_Graphic558_FieldAspects[C11_VIEW_SQUARE_D0R], G163_as_Graphic558_Frame_Walls[C11_VIEW_SQUARE_D0R].Box);
        }
}

VOID F127_xxxx_DUNGEONVIEW_DrawSquareD0C(P180_i_Direction, P181_i_MapX, P182_i_MapY)
register int P180_i_Direction;
register int P181_i_MapX;
register int P182_i_MapY;
{
        int L0222_ai_SquareAspect[5];


        F172_awzz_DUNGEON_SetSquareAspect(L0222_ai_SquareAspect, P180_i_Direction, P181_i_MapX, P182_i_MapY);
        switch (L0222_ai_SquareAspect[C0_ELEMENT]) {
                case C16_ELEMENT_DOOR_SIDE:
                        if (G407_s_Party.Event73Count_ThievesEye) {
                                F007_aAA7_MAIN_CopyBytes(G088_apuc_Bitmap_WallSet[C01_WALL_BITMAP_DOOR_FRAME_FRONT], G074_puc_Bitmap_Temporary, M75_BITMAP_BYTE_COUNT(32, 123));
                                F132_xzzz_VIDEO_Blit(F489_ayzz_MEMORY_GetNativeBitmapOrGraphic(C041_GRAPHIC_HOLE_IN_WALL), G074_puc_Bitmap_Temporary, &G108_s_Graphic558_Box_ThievesEye_HoleInDoorFrame, G172_s_Graphic558_Frame_DoorFrame_D0C.Box[C0_X1] - G106_s_Graphic558_Box_ThievesEye_ViewportVisibleArea.X1, 0, C048_BYTE_WIDTH, C016_BYTE_WIDTH, C09_COLOR_GOLD);
                                F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G074_puc_Bitmap_Temporary, &G172_s_Graphic558_Frame_DoorFrame_D0C);
                        } else {
                                F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C01_WALL_BITMAP_DOOR_FRAME_FRONT], &G172_s_Graphic558_Frame_DoorFrame_D0C);
                        }
                        break;
                case C19_ELEMENT_STAIRS_FRONT:
                        if (L0222_ai_SquareAspect[C2_STAIRS_UP]) {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C11_STAIRS_BITMAP_UP_FRONT_D0C_LEFT], &G119_s_Graphic558_Frame_StairsUpFront_D0L);
                                F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(G079_ai_StairsNativeBitmapIndices[C11_STAIRS_BITMAP_UP_FRONT_D0C_LEFT], &G120_s_Graphic558_Frame_StairsUpFront_D0R);
                        } else {
                                F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(G079_ai_StairsNativeBitmapIndices[C04_STAIRS_BITMAP_DOWN_FRONT_D0C_LEFT], &G130_s_Graphic558_Frame_StairsDownFront_D0L);
                                F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally(G079_ai_StairsNativeBitmapIndices[C04_STAIRS_BITMAP_DOWN_FRONT_D0C_LEFT], &G131_s_Graphic558_Frame_StairsDownFront_D0R);
                        }
                        break;
                case C02_ELEMENT_PIT:
                        F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap(L0222_ai_SquareAspect[C2_PIT_INVISIBLE] ? C062_GRAPHIC_FLOOR_PIT_INVISIBLE_D0C : C056_GRAPHIC_FLOOR_PIT_D0C, &G150_s_Graphic558_Frame_FloorPit_D0C);
        }
        F112_xxxx_DUNGEONVIEW_DrawCeilingPit(C068_GRAPHIC_CEILING_PIT_D0C, &G159_s_Graphic558_Frame_CeilingPit_D0C, P181_i_MapX, P182_i_MapY, FALSE);
        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(L0222_ai_SquareAspect[C1_FIRST_GROUP_OR_OBJECT], P180_i_Direction, P181_i_MapX, P182_i_MapY, C09_VIEW_SQUARE_D0C, C0021_CELL_ORDER_BACKLEFT_BACKRIGHT);
        if ((L0222_ai_SquareAspect[C0_ELEMENT] == C05_ELEMENT_TELEPORTER) && L0222_ai_SquareAspect[C2_TELEPORTER_VISIBLE]) {
                F113_xxxx_DUNGEONVIEW_DrawField(&G188_as_Graphic558_FieldAspects[C09_VIEW_SQUARE_D0C], G163_as_Graphic558_Frame_Walls[C09_VIEW_SQUARE_D0C].Box);
        }
}

VOID F128_rzzz_DUNGEONVIEW_Draw_COPYPROTECTIONF(P183_i_Direction, P184_i_MapX, P185_i_MapY)
register int P183_i_Direction;
register int P184_i_MapX;
register int P185_i_MapY;
{
        register BOOLEAN L0223_B_FlipWalls;
        int L0224_i_MapX;
        int L0225_i_MapY;


        L0223_B_FlipWalls = FALSE;
        if (G297_B_DrawFloorAndCeilingRequested) {
                F098_rzzz_DUNGEONVIEW_DrawFloorAndCeiling();
        }
        G578_B_UseByteBoxCoordinates = TRUE;
        F008_aA19_MAIN_ClearBytes(G291_aauc_DungeonViewClickableBoxes, sizeof(G291_aauc_DungeonViewClickableBoxes));
        F009_aA49_MAIN_WriteSpacedBytes(G291_aauc_DungeonViewClickableBoxes, 6, 255, 4);
        G074_puc_Bitmap_Temporary = F468_ozzz_MEMORY_Allocate((long)M75_BITMAP_BYTE_COUNT(160, 111), C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP); /* Dimensions of an explosion bitmap which is the largest bitmap to store */
        if (G076_B_UseFlippedWallAndFootprintsBitmaps = (P184_i_MapX + P185_i_MapY + P183_i_Direction) & 0x0001) {
                F130_xxxx_VIDEO_FlipHorizontal(G087_puc_Bitmap_ViewportFloorArea, C112_BYTE_WIDTH_VIEWPORT, 70); /* Height of floor bitmap is 70 lines */
                if (L0223_B_FlipWalls = G661_B_LargeHeapMemory) {
                        G088_apuc_Bitmap_WallSet[C12_WALL_BITMAP_WALL_D3LCR] = G090_puc_Bitmap_WallD3LCR_Flipped;
                        G088_apuc_Bitmap_WallSet[C11_WALL_BITMAP_WALL_D2LCR] = G091_puc_Bitmap_WallD2LCR_Flipped;
                        G088_apuc_Bitmap_WallSet[C10_WALL_BITMAP_WALL_D1LCR] = G092_puc_Bitmap_WallD1LCR_Flipped;
                        G088_apuc_Bitmap_WallSet[C09_WALL_BITMAP_WALL_D0L] = G093_puc_Bitmap_WallD0L_Flipped;
                        G088_apuc_Bitmap_WallSet[C08_WALL_BITMAP_WALL_D0R] = G094_puc_Bitmap_WallD0R_Flipped;
                }
        } else {
                F130_xxxx_VIDEO_FlipHorizontal(G296_puc_Bitmap_Viewport, C112_BYTE_WIDTH_VIEWPORT, 29); /* Height of ceiling bitmap is 29 lines */
        }
        if (F153_yzzz_DUNGEON_GetRelativeSquareType(P183_i_Direction, 3, -2, P184_i_MapX, P185_i_MapY) == C00_ELEMENT_WALL) {
                F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C13_WALL_BITMAP_WALL_D3L2], &G163_as_Graphic558_Frame_Walls[C13_VIEW_SQUARE_D3L2]);
        }
        if (F153_yzzz_DUNGEON_GetRelativeSquareType(P183_i_Direction, 3, 2, P184_i_MapX, P185_i_MapY) == C00_ELEMENT_WALL) {
                F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap(G088_apuc_Bitmap_WallSet[C14_WALL_BITMAP_WALL_D3R2], &G163_as_Graphic558_Frame_Walls[C12_VIEW_SQUARE_D3R2]);
        }
        L0224_i_MapX = P184_i_MapX;
        L0225_i_MapY = P185_i_MapY;
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P183_i_Direction, 4, -1, &L0224_i_MapX, &L0225_i_MapY);
        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(F162_afzz_DUNGEON_GetSquareFirstObject(L0224_i_MapX, L0225_i_MapY), P183_i_Direction, L0224_i_MapX, L0225_i_MapY, CM2_VIEW_SQUARE_D4L, C0001_CELL_ORDER_BACKLEFT);
        L0224_i_MapX = P184_i_MapX;
        L0225_i_MapY = P185_i_MapY;
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P183_i_Direction, 4, 1, &L0224_i_MapX, &L0225_i_MapY);
        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(F162_afzz_DUNGEON_GetSquareFirstObject(L0224_i_MapX, L0225_i_MapY), P183_i_Direction, L0224_i_MapX, L0225_i_MapY, CM1_VIEW_SQUARE_D4R, C0001_CELL_ORDER_BACKLEFT);
        L0224_i_MapX = P184_i_MapX;
        L0225_i_MapY = P185_i_MapY;
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P183_i_Direction, 4, 0, &L0224_i_MapX, &L0225_i_MapY);
        F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF(F162_afzz_DUNGEON_GetSquareFirstObject(L0224_i_MapX, L0225_i_MapY), P183_i_Direction, L0224_i_MapX, L0225_i_MapY, CM3_VIEW_SQUARE_D4C, C0001_CELL_ORDER_BACKLEFT);
        L0224_i_MapX = P184_i_MapX;
        L0225_i_MapY = P185_i_MapY;
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P183_i_Direction, 3, -1, &L0224_i_MapX, &L0225_i_MapY);
        F116_xxxx_DUNGEONVIEW_DrawSquareD3L(P183_i_Direction, L0224_i_MapX, L0225_i_MapY);
        L0224_i_MapX = P184_i_MapX;
        L0225_i_MapY = P185_i_MapY;
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P183_i_Direction, 3, 1, &L0224_i_MapX, &L0225_i_MapY);
        F117_xxxx_DUNGEONVIEW_DrawSquareD3R(P183_i_Direction, L0224_i_MapX, L0225_i_MapY);
        L0224_i_MapX = P184_i_MapX;
        L0225_i_MapY = P185_i_MapY;
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P183_i_Direction, 3, 0, &L0224_i_MapX, &L0225_i_MapY);
        F118_xxxx_DUNGEONVIEW_DrawSquareD3C_COPYPROTECTIONF(P183_i_Direction, L0224_i_MapX, L0225_i_MapY);
        L0224_i_MapX = P184_i_MapX;
        L0225_i_MapY = P185_i_MapY;
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P183_i_Direction, 2, -1, &L0224_i_MapX, &L0225_i_MapY);
        F119_xxxx_DUNGEONVIEW_DrawSquareD2L(P183_i_Direction, L0224_i_MapX, L0225_i_MapY);
        L0224_i_MapX = P184_i_MapX;
        L0225_i_MapY = P185_i_MapY;
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P183_i_Direction, 2, 1, &L0224_i_MapX, &L0225_i_MapY);
        F120_xxxx_DUNGEONVIEW_DrawSquareD2R_COPYPROTECTIONF(P183_i_Direction, L0224_i_MapX, L0225_i_MapY);
        L0224_i_MapX = P184_i_MapX;
        L0225_i_MapY = P185_i_MapY;
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P183_i_Direction, 2, 0, &L0224_i_MapX, &L0225_i_MapY);
        F121_xxxx_DUNGEONVIEW_DrawSquareD2C(P183_i_Direction, L0224_i_MapX, L0225_i_MapY);
        L0224_i_MapX = P184_i_MapX;
        L0225_i_MapY = P185_i_MapY;
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P183_i_Direction, 1, -1, &L0224_i_MapX, &L0225_i_MapY);
        F122_xxxx_DUNGEONVIEW_DrawSquareD1L(P183_i_Direction, L0224_i_MapX, L0225_i_MapY);
        L0224_i_MapX = P184_i_MapX;
        L0225_i_MapY = P185_i_MapY;
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P183_i_Direction, 1, 1, &L0224_i_MapX, &L0225_i_MapY);
        F123_xxxx_DUNGEONVIEW_DrawSquareD1R(P183_i_Direction, L0224_i_MapX, L0225_i_MapY);
        L0224_i_MapX = P184_i_MapX;
        L0225_i_MapY = P185_i_MapY;
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P183_i_Direction, 1, 0, &L0224_i_MapX, &L0225_i_MapY);
        F124_xxxx_DUNGEONVIEW_DrawSquareD1C(P183_i_Direction, L0224_i_MapX, L0225_i_MapY);
        L0224_i_MapX = P184_i_MapX;
        L0225_i_MapY = P185_i_MapY;
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P183_i_Direction, 0, -1, &L0224_i_MapX, &L0225_i_MapY);
        F125_xxxx_DUNGEONVIEW_DrawSquareD0L(P183_i_Direction, L0224_i_MapX, L0225_i_MapY);
        L0224_i_MapX = P184_i_MapX;
        L0225_i_MapY = P185_i_MapY;
        F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement(P183_i_Direction, 0, 1, &L0224_i_MapX, &L0225_i_MapY);
        F126_xxxx_DUNGEONVIEW_DrawSquareD0R(P183_i_Direction, L0224_i_MapX, L0225_i_MapY);
        F127_xxxx_DUNGEONVIEW_DrawSquareD0C(P183_i_Direction, P184_i_MapX, P185_i_MapY);
        if (L0223_B_FlipWalls) {
                        G088_apuc_Bitmap_WallSet[C12_WALL_BITMAP_WALL_D3LCR] = G095_puc_Bitmap_WallD3LCR_Native;
                        G088_apuc_Bitmap_WallSet[C11_WALL_BITMAP_WALL_D2LCR] = G096_puc_Bitmap_WallD2LCR_Native;
                        G088_apuc_Bitmap_WallSet[C10_WALL_BITMAP_WALL_D1LCR] = G097_puc_Bitmap_WallD1LCR_Native;
                        G088_apuc_Bitmap_WallSet[C09_WALL_BITMAP_WALL_D0L] = G098_puc_Bitmap_WallD0L_Native;
                        G088_apuc_Bitmap_WallSet[C08_WALL_BITMAP_WALL_D0R] = G099_puc_Bitmap_WallD0R_Native;
        }
#ifndef NOCOPYPROTECTION
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_10_IMPROVEMENT */
        if (!G071_B_Sector7ReadingInitiated_COPYPROTECTIONF && (G073_i_StopFreeingMemory_COPYPROTECTIONF != C00512_FALSE)) { /* Memory is not freed and the game will eventually run out of memory and stop */
        } else {
#endif
                G071_B_Sector7ReadingInitiated_COPYPROTECTIONF = TRUE; /* At this step the function patched with graphic #21 has necessarily been executed */
#endif
                F469_rzzz_MEMORY_FreeAtHeapTop((long)M75_BITMAP_BYTE_COUNT(160, 111));
#ifndef NOCOPYPROTECTION
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_10_IMPROVEMENT */
        }
#endif
#endif
        F097_lzzz_DUNGEONVIEW_DrawViewport(G309_i_PartyMapIndex != C255_MAP_INDEX_ENTRANCE);
        if (G309_i_PartyMapIndex != C255_MAP_INDEX_ENTRANCE) { /* If not in entrance then anticipate the next call to draw the dungeon view by drawing the floor and ceiling in the viewport */
                F098_rzzz_DUNGEONVIEW_DrawFloorAndCeiling();
        }
}
