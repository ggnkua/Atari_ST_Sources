#include <STRING.H>

/*_***************** Constants for conditional compilation *****************_*/
/* Possible values for the game version to compile */
#define C00_VERSION_ATARI_ST_DM10aEN  0
#define C01_VERSION_ATARI_ST_DM10bEN  1
#define C02_VERSION_ATARI_ST_DM11EN   2
#define C03_VERSION_ATARI_ST_DM12EN   3
#define C04_VERSION_ATARI_ST_DM12GE   4
#define C05_VERSION_ATARI_ST_DM13aFR  5
#define C06_VERSION_ATARI_ST_DM13bFR  6
#define C07_VERSION_ATARI_ST_CSB20EN  7
#define C08_VERSION_ATARI_ST_CSB21EN  8


/* If GAMEVERSION is not already defined (with parameter -D on the compiler command line, for example -DGAMEVERSION=0) then define a default version to compile */
#ifndef GAMEVERSION
#define GAMEVERSION C08_VERSION_ATARI_ST_CSB21EN
#endif

/* If NOCOPYPROTECTION is defined (with parameter -D on the compiler command line, for example -DNOCOPYPROTECTION=1) then the game compiles without all copy protection related variables and code */

#if GAMEVERSION == C00_VERSION_ATARI_ST_DM10aEN
        #define C00_COMPILE_DM10aEN                                                      1
        #define C01_COMPILE_DM10aEN_DM10bEN                                              1
        #define C02_COMPILE_DM10aEN_DM10bEN_DM11EN                                       1
        #define C03_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN                                1
        #define C04_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE                         1
        #define C05_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR                 1
        #define C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR         1
        #define C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN 1
        #define C08_COMPILE_DM10aEN_DM10bEN_DM11EN_CSB20EN_CSB21EN                       1
        #define C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN                1
        #define C10_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_CSB20EN_CSB21EN         1
        #define CHECKSUM_A 0xB9F1
        #define CHECKSUM_B 0xE582
        #define CHECKSUM_C 0x7C63
        #define CHECKSUM_D 0xB1EB
#endif

#if GAMEVERSION == C01_VERSION_ATARI_ST_DM10bEN
        #define C01_COMPILE_DM10aEN_DM10bEN                                              1
        #define C02_COMPILE_DM10aEN_DM10bEN_DM11EN                                       1
        #define C03_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN                                1
        #define C04_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE                         1
        #define C05_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR                 1
        #define C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR         1
        #define C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN 1
        #define C08_COMPILE_DM10aEN_DM10bEN_DM11EN_CSB20EN_CSB21EN                       1
        #define C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN                1
        #define C10_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_CSB20EN_CSB21EN         1
        #define C11_COMPILE_DM10bEN                                                      1
        #define C12_COMPILE_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN 1
        #define CHECKSUM_A 0x3C8F
        #define CHECKSUM_B 0x06AB
        #define CHECKSUM_C 0x5B3A
        #define CHECKSUM_D 0x1895
#endif

#if GAMEVERSION == C02_VERSION_ATARI_ST_DM11EN
        #define C02_COMPILE_DM10aEN_DM10bEN_DM11EN                                       1
        #define C03_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN                                1
        #define C04_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE                         1
        #define C05_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR                 1
        #define C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR         1
        #define C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN 1
        #define C08_COMPILE_DM10aEN_DM10bEN_DM11EN_CSB20EN_CSB21EN                       1
        #define C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN                1
        #define C10_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_CSB20EN_CSB21EN         1
        #define C12_COMPILE_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN 1
        #define C13_COMPILE_DM11EN                                                       1
        #define C14_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR                         1
        #define C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN         1
        #define CHECKSUM_A 0x2FF3
        #define CHECKSUM_B 0x9FCB
        #define CHECKSUM_C 0x5ABC
        #define CHECKSUM_D 0x1913
#endif

#if GAMEVERSION == C03_VERSION_ATARI_ST_DM12EN
        #define C03_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN                                1
        #define C04_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE                         1
        #define C05_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR                 1
        #define C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR         1
        #define C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN 1
        #define C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN                1
        #define C10_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_CSB20EN_CSB21EN         1
        #define C12_COMPILE_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN 1
        #define C14_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR                         1
        #define C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN         1
        #define C16_COMPILE_DM12EN                                                       1
        #define C17_COMPILE_DM12EN_DM12GE                                                1
        #define C18_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR                                1
        #define C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN                1
        #define C20_COMPILE_DM12EN_CSB20EN_CSB21EN                                       1
        #define CHECKSUM_A 0xD815
        #define CHECKSUM_B 0x0432
        #define CHECKSUM_C 0xF661
        #define CHECKSUM_D 0xE14D
#endif

#if GAMEVERSION == C04_VERSION_ATARI_ST_DM12GE
        #define C04_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE                         1
        #define C05_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR                 1
        #define C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR         1
        #define C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN 1
        #define C10_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_CSB20EN_CSB21EN         1
        #define C12_COMPILE_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN 1
        #define C14_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR                         1
        #define C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN         1
        #define C17_COMPILE_DM12EN_DM12GE                                                1
        #define C18_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR                                1
        #define C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN                1
        #define C21_COMPILE_DM12GE                                                       1
        #define C22_COMPILE_DM12GE_DM13aFR_DM13bFR                                       1
        #define CHECKSUM_A 0x2E51
        #define CHECKSUM_B 0xFCBF
        #define CHECKSUM_C 0xFE95
        #define CHECKSUM_D 0xD919
#endif

#if GAMEVERSION == C05_VERSION_ATARI_ST_DM13aFR
        #define C05_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR                 1
        #define C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR         1
        #define C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN 1
        #define C12_COMPILE_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN 1
        #define C14_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR                         1
        #define C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN         1
        #define C18_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR                                1
        #define C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN                1
        #define C22_COMPILE_DM12GE_DM13aFR_DM13bFR                                       1
        #define C23_COMPILE_DM13aFR_DM13bFR                                              1
        #define C24_COMPILE_DM13aFR_DM13bFR_CSB20EN_CSB21EN                              1
        #define CHECKSUM_A 0x35D5
        #define CHECKSUM_B 0xE630
        #define CHECKSUM_C 0x1526
        #define CHECKSUM_D 0xE9B7
#endif

#if GAMEVERSION == C06_VERSION_ATARI_ST_DM13bFR
        #define C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR         1
        #define C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN 1
        #define C12_COMPILE_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN 1
        #define C14_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR                         1
        #define C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN         1
        #define C18_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR                                1
        #define C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN                1
        #define C22_COMPILE_DM12GE_DM13aFR_DM13bFR                                       1
        #define C23_COMPILE_DM13aFR_DM13bFR                                              1
        #define C24_COMPILE_DM13aFR_DM13bFR_CSB20EN_CSB21EN                              1
        #define C25_COMPILE_DM13bFR_CSB20EN_CSB21EN                                      1
        #define CHECKSUM_A 0x35D5
        #define CHECKSUM_B 0xE630
        #define CHECKSUM_C 0x1526
        #define CHECKSUM_D 0xE9B7
#endif

#if GAMEVERSION == C07_VERSION_ATARI_ST_CSB20EN
        #define C07_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN 1
        #define C08_COMPILE_DM10aEN_DM10bEN_DM11EN_CSB20EN_CSB21EN                       1
        #define C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN                1
        #define C10_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_CSB20EN_CSB21EN         1
        #define C12_COMPILE_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN 1
        #define C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN         1
        #define C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN                1
        #define C20_COMPILE_DM12EN_CSB20EN_CSB21EN                                       1
        #define C24_COMPILE_DM13aFR_DM13bFR_CSB20EN_CSB21EN                              1
        #define C25_COMPILE_DM13bFR_CSB20EN_CSB21EN                                      1
        #define C26_COMPILE_CSB20EN                                                      1
        #define C27_COMPILE_CSB20EN_CSB21EN                                              1
        #define CHECKSUM_A 0x396C
        #define CHECKSUM_B 0x3177
        #define CHECKSUM_C 0x3648
        #define CHECKSUM_D 0xEF78
#endif

#if GAMEVERSION == C08_VERSION_ATARI_ST_CSB21EN
        #define C08_COMPILE_DM10aEN_DM10bEN_DM11EN_CSB20EN_CSB21EN                       1
        #define C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN                1
        #define C10_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_CSB20EN_CSB21EN         1
        #define C12_COMPILE_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN 1
        #define C15_COMPILE_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN         1
        #define C19_COMPILE_DM12EN_DM12GE_DM13aFR_DM13bFR_CSB20EN_CSB21EN                1
        #define C20_COMPILE_DM12EN_CSB20EN_CSB21EN                                       1
        #define C24_COMPILE_DM13aFR_DM13bFR_CSB20EN_CSB21EN                              1
        #define C25_COMPILE_DM13bFR_CSB20EN_CSB21EN                                      1
        #define C27_COMPILE_CSB20EN_CSB21EN                                              1
        #define C28_COMPILE_CSB21EN                                                      1
        #define CHECKSUM_A 0xC0F8
        #define CHECKSUM_B 0x02A3
        #define CHECKSUM_C 0x6628
        #define CHECKSUM_D 0xBF98
#endif


/*_********************** Types, Constants and macros **********************_*/
#define NULL 0L /* Null pointer */

typedef int VOID; /* There is no void type in Megamax C. It is not possible to declare a function with no return value */
                  /* This fake VOID type is used only to clearly indicate functions that do not return any value */

typedef VOID (*SUBROUTINE)(); /* SUBROUTINE is a pointer to a function returning VOID */

typedef int BOOLEAN; /* There is no boolean type in Megamax C. This fake BOOLEAN type is used for variables of type int whose values are only tested as being 0 (false) or non zero (true) */
#define FALSE 0
#define TRUE  1

#define M00_INDEX_TO_ORDINAL(value) ((value) + 1)
#define M01_ORDINAL_TO_INDEX(value) ((value) - 1)

#define M02_RANDOM(value) (F027_AA59_MAIN_Get16bitRandomNumber() % (value)) /* This macro can be used for any value */
#define M03_RANDOM(value) (F027_AA59_MAIN_Get16bitRandomNumber() & (value - 1)) /* This macro can only be used for values that are a power of 2 */
#define M04_RANDOM(value) F029_AA19_MAIN_Get2BitRandomNumber()
#define M05_RANDOM(value) F028_a000_MAIN_Get1BitRandomNumber()
#define M06_RANDOM(value) F027_AA59_MAIN_Get16bitRandomNumber()

#define M07_GET(value, mask)    ((value) & (mask))
#define M08_SET(value, mask)    ((value) |= (mask))
#define M09_CLEAR(value, mask)  ((value) &= ~(mask))
#define M10_TOGGLE(value, mask) ((value) ^= (mask))

/* Errors */
#define C40_ERROR_OUT_OF_MEMORY                                  40
#define C41_ERROR_UNABLE_TO_OPEN_GRAPHICS_DAT                    41
#define C42_ERROR_UNABLE_TO_LOAD_GRAPHICS_DAT_HEADER             42
#define C43_ERROR_NOT_ENOUGH_MEMORY_TO_ALLOCATE_BLOCK            43
#define C44_ERROR_NOT_ENOUGH_CACHE_MEMORY_AFTER_LOADING_GRAPHICS 44
#define C45_ERROR_TIMELINE_FULL                                  45
#define C50_ERROR_UNABLE_TO_OPEN_DUNGEON_OR_SAVED_GAME           50
#define C52_ERROR_UNABLE_TO_LOAD_SAVED_GAME                      52
#define C60_ERROR_EVENT_PROCESSING_STOPPED                       60

typedef struct {
        int GraphicIndex;
        unsigned char aUnreferenced; /* BUG0_00 Useless code */
        unsigned char Period;
        unsigned char Priority;
        unsigned char bUnreferenced; /* BUG0_00 Useless code */
        unsigned char LoudDistance;
        unsigned char SoftDistance;
} SOUND;

/* Sounds */
#define C00_SOUND_METALLIC_THUD       0 /* Played when a creature drops at least one weapon or during a impact with a weapon projectile */
#define C01_SOUND_SWITCH              1 /* Played for audible sensors and when clicking on a door button */
#define C02_SOUND_DOOR_RATTLE         2 /* Played when a door is opening or closing */
#define C04_SOUND_WOODEN_THUD         4 /* Played when a creature drops objects (without any weapon), when attacking a door, when a creature is hit by a closing door, or during a impact with a non weapon projectile */
#define C05_SOUND_STRONG_EXPLOSION    5 /* Played for Fireballs, Slimes, Lighning Bolts and for the first step of rebirth at a Vi altar */
#define C06_SOUND_SCREAM              6 /* Played when falling in a pit and when the game is over (all champions in the party are dead) */
#define C08_SOUND_SWALLOW             8 /* Played when a champion eats or drinks */
#define C09_SOUND_CHAMPION_0_DAMAGED  9 /* Sounds 9 to 12 are played when a champion is damaged (each champion has his own sound) */
#define C13_SOUND_SPELL              13 /* Played during a impact with a Poison Bolt explosion projectile and when creating explosions for Harm Non Material, Open Door, Poison Bolt, Poison Cloud, Fluxcage and for Rebirth steps 1 and 2 */
#define C16_SOUND_COMBAT             16 /* Played for all melee actions, shoot, throw and during Animated Armour / Deth Knight attacks */
#define C17_SOUND_BUZZ               17 /* Played for teleporters and group generators */
#define C18_SOUND_PARTY_DAMAGED      18 /* Played when the party runs into a wall or is hit by a closing door */
#define C20_SOUND_WEAK_EXPLOSION     20 /* Played for Fireballs, Slimes, Lighning Bolts */

#define CM1_MODE_DO_NOT_PLAY_SOUND   -1 /* Used when discarding a GROUP thing to drop the group objects on the floor silently */
#define C00_MODE_PLAY_IMMEDIATELY     0 /* Stops and replaces any currently playing sound. Used when the party movement is blocked, when a champion swallows, when a teleporter buzzes and when the party screams (death or fall through a pit) */
#define C01_MODE_PLAY_IF_PRIORITIZED  1 /* Set sound to be played in the next game loop if no other sound (louder or with higher priority) is already pending. Used for most sounds to make sure only one sound is played during each clock tick */
#define C02_MODE_PLAY_ONE_TICK_LATER  2 /* Used for the sound of objects falling on the floor after a creature dies during combat (but not during movement), for the sound of a door being destroyed and for the sound of a champion being damaged. This allows another sound (the attack sound) to be played right before */

#define MASK0xFF01_KEY_CLICK 0xFF01

typedef struct {
        unsigned char X1;
        unsigned char X2;
        unsigned char Y1;
        unsigned char Y2;
} BOX_BYTE;

typedef struct {
        int X1;
        int X2;
        int Y1;
        int Y2;
} BOX_WORD;

typedef struct {
        int Command;
        int Code; /* ASCII code or scan code */
} KEYBOARD_INPUT;

typedef struct {
        int Command;
        BOX_WORD Box;
        int Button;
} MOUSE_INPUT;

/* Mouse buttons */
#define MASK0x0002_MOUSE_LEFT_BUTTON  0x0002

typedef struct {
        int X;
        int Y;
        int Command;
} COMMAND;

/* Commands */
#define C000_COMMAND_NONE                                                     0
#define C001_COMMAND_TURN_LEFT                                                1
#define C002_COMMAND_TURN_RIGHT                                               2
#define C003_COMMAND_MOVE_FORWARD                                             3
#define C004_COMMAND_MOVE_RIGHT                                               4
#define C005_COMMAND_MOVE_BACKWARD                                            5
#define C006_COMMAND_MOVE_LEFT                                                6
#define C007_COMMAND_TOGGLE_INVENTORY_CHAMPION_0                              7
#define C008_COMMAND_TOGGLE_INVENTORY_CHAMPION_1                              8
#define C009_COMMAND_TOGGLE_INVENTORY_CHAMPION_2                              9
#define C010_COMMAND_TOGGLE_INVENTORY_CHAMPION_3                             10
#define C011_COMMAND_CLOSE_INVENTORY                                         11
#define C012_COMMAND_CLICK_IN_CHAMPION_0_STATUS_BOX                          12
#define C013_COMMAND_CLICK_IN_CHAMPION_1_STATUS_BOX                          13
#define C014_COMMAND_CLICK_IN_CHAMPION_2_STATUS_BOX                          14
#define C015_COMMAND_CLICK_IN_CHAMPION_3_STATUS_BOX                          15
#define C016_COMMAND_SET_LEADER_CHAMPION_0                                   16
#define C017_COMMAND_SET_LEADER_CHAMPION_1                                   17
#define C018_COMMAND_SET_LEADER_CHAMPION_2                                   18
#define C019_COMMAND_SET_LEADER_CHAMPION_3                                   19
#define C020_COMMAND_CLICK_ON_SLOT_BOX_00_CHAMPION_0_STATUS_BOX_READY_HAND   20
#define C021_COMMAND_CLICK_ON_SLOT_BOX_01_CHAMPION_0_STATUS_BOX_ACTION_HAND  21
#define C022_COMMAND_CLICK_ON_SLOT_BOX_02_CHAMPION_1_STATUS_BOX_READY_HAND   22
#define C023_COMMAND_CLICK_ON_SLOT_BOX_03_CHAMPION_1_STATUS_BOX_ACTION_HAND  23
#define C024_COMMAND_CLICK_ON_SLOT_BOX_04_CHAMPION_2_STATUS_BOX_READY_HAND   24
#define C025_COMMAND_CLICK_ON_SLOT_BOX_05_CHAMPION_2_STATUS_BOX_ACTION_HAND  25
#define C026_COMMAND_CLICK_ON_SLOT_BOX_06_CHAMPION_3_STATUS_BOX_READY_HAND   26
#define C027_COMMAND_CLICK_ON_SLOT_BOX_07_CHAMPION_3_STATUS_BOX_ACTION_HAND  27
#define C028_COMMAND_CLICK_ON_SLOT_BOX_08_INVENTORY_READY_HAND               28
#define C029_COMMAND_CLICK_ON_SLOT_BOX_09_INVENTORY_ACTION_HAND              29
#define C030_COMMAND_CLICK_ON_SLOT_BOX_10_INVENTORY_HEAD                     30
#define C031_COMMAND_CLICK_ON_SLOT_BOX_11_INVENTORY_TORSO                    31
#define C032_COMMAND_CLICK_ON_SLOT_BOX_12_INVENTORY_LEGS                     32
#define C033_COMMAND_CLICK_ON_SLOT_BOX_13_INVENTORY_FEET                     33
#define C034_COMMAND_CLICK_ON_SLOT_BOX_14_INVENTORY_POUCH_2                  34
#define C035_COMMAND_CLICK_ON_SLOT_BOX_15_INVENTORY_QUIVER_LINE2_1           35
#define C036_COMMAND_CLICK_ON_SLOT_BOX_16_INVENTORY_QUIVER_LINE1_2           36
#define C037_COMMAND_CLICK_ON_SLOT_BOX_17_INVENTORY_QUIVER_LINE2_2           37
#define C038_COMMAND_CLICK_ON_SLOT_BOX_18_INVENTORY_NECK                     38
#define C039_COMMAND_CLICK_ON_SLOT_BOX_19_INVENTORY_POUCH_1                  39
#define C040_COMMAND_CLICK_ON_SLOT_BOX_20_INVENTORY_QUIVER_LINE1_1           40
#define C041_COMMAND_CLICK_ON_SLOT_BOX_21_INVENTORY_BACKPACK_LINE1_1         41
#define C042_COMMAND_CLICK_ON_SLOT_BOX_22_INVENTORY_BACKPACK_LINE2_2         42
#define C043_COMMAND_CLICK_ON_SLOT_BOX_23_INVENTORY_BACKPACK_LINE2_3         43
#define C044_COMMAND_CLICK_ON_SLOT_BOX_24_INVENTORY_BACKPACK_LINE2_4         44
#define C045_COMMAND_CLICK_ON_SLOT_BOX_25_INVENTORY_BACKPACK_LINE2_5         45
#define C046_COMMAND_CLICK_ON_SLOT_BOX_26_INVENTORY_BACKPACK_LINE2_6         46
#define C047_COMMAND_CLICK_ON_SLOT_BOX_27_INVENTORY_BACKPACK_LINE2_7         47
#define C048_COMMAND_CLICK_ON_SLOT_BOX_28_INVENTORY_BACKPACK_LINE2_8         48
#define C049_COMMAND_CLICK_ON_SLOT_BOX_29_INVENTORY_BACKPACK_LINE2_9         49
#define C050_COMMAND_CLICK_ON_SLOT_BOX_30_INVENTORY_BACKPACK_LINE1_2         50
#define C051_COMMAND_CLICK_ON_SLOT_BOX_31_INVENTORY_BACKPACK_LINE1_3         51
#define C052_COMMAND_CLICK_ON_SLOT_BOX_32_INVENTORY_BACKPACK_LINE1_4         52
#define C053_COMMAND_CLICK_ON_SLOT_BOX_33_INVENTORY_BACKPACK_LINE1_5         53
#define C054_COMMAND_CLICK_ON_SLOT_BOX_34_INVENTORY_BACKPACK_LINE1_6         54
#define C055_COMMAND_CLICK_ON_SLOT_BOX_35_INVENTORY_BACKPACK_LINE1_7         55
#define C056_COMMAND_CLICK_ON_SLOT_BOX_36_INVENTORY_BACKPACK_LINE1_8         56
#define C057_COMMAND_CLICK_ON_SLOT_BOX_37_INVENTORY_BACKPACK_LINE1_9         57
#define C058_COMMAND_CLICK_ON_SLOT_BOX_38_CHEST_1                            58
#define C059_COMMAND_CLICK_ON_SLOT_BOX_39_CHEST_2                            59
#define C060_COMMAND_CLICK_ON_SLOT_BOX_40_CHEST_3                            60
#define C061_COMMAND_CLICK_ON_SLOT_BOX_41_CHEST_4                            61
#define C062_COMMAND_CLICK_ON_SLOT_BOX_42_CHEST_5                            62
#define C063_COMMAND_CLICK_ON_SLOT_BOX_43_CHEST_6                            63
#define C064_COMMAND_CLICK_ON_SLOT_BOX_44_CHEST_7                            64
#define C065_COMMAND_CLICK_ON_SLOT_BOX_45_CHEST_8                            65
#define C070_COMMAND_CLICK_ON_MOUTH                                          70
#define C071_COMMAND_CLICK_ON_EYE                                            71
#define C080_COMMAND_CLICK_IN_DUNGEON_VIEW                                   80
#define C081_COMMAND_CLICK_IN_PANEL                                          81
#define C083_COMMAND_TOGGLE_INVENTORY_LEADER                                 83
#define C100_COMMAND_CLICK_IN_SPELL_AREA                                    100
#define C101_COMMAND_CLICK_IN_SPELL_AREA_SYMBOL_1                           101
#define C102_COMMAND_CLICK_IN_SPELL_AREA_SYMBOL_2                           102
#define C103_COMMAND_CLICK_IN_SPELL_AREA_SYMBOL_3                           103
#define C104_COMMAND_CLICK_IN_SPELL_AREA_SYMBOL_4                           104
#define C105_COMMAND_CLICK_IN_SPELL_AREA_SYMBOL_5                           105
#define C106_COMMAND_CLICK_IN_SPELL_AREA_SYMBOL_6                           106
#define C107_COMMAND_CLICK_IN_SPELL_AREA_RECANT_SYMBOL                      107
#define C108_COMMAND_CLICK_IN_SPELL_AREA_CAST_SPELL                         108
#define C111_COMMAND_CLICK_IN_ACTION_AREA                                   111
#define C112_COMMAND_CLICK_IN_ACTION_AREA_PASS                              112
#define C113_COMMAND_CLICK_IN_ACTION_AREA_ACTION_0                          113
#define C114_COMMAND_CLICK_IN_ACTION_AREA_ACTION_1                          114
#define C115_COMMAND_CLICK_IN_ACTION_AREA_ACTION_2                          115
#define C116_COMMAND_CLICK_IN_ACTION_AREA_CHAMPION_0_ACTION                 116
#define C117_COMMAND_CLICK_IN_ACTION_AREA_CHAMPION_1_ACTION                 117
#define C118_COMMAND_CLICK_IN_ACTION_AREA_CHAMPION_2_ACTION                 118
#define C119_COMMAND_CLICK_IN_ACTION_AREA_CHAMPION_3_ACTION                 119
#define C125_COMMAND_CLICK_ON_CHAMPION_ICON_TOP_LEFT                        125
#define C126_COMMAND_CLICK_ON_CHAMPION_ICON_TOP_RIGHT                       126
#define C127_COMMAND_CLICK_ON_CHAMPION_ICON_LOWER_RIGHT                     127
#define C128_COMMAND_CLICK_ON_CHAMPION_ICON_LOWER_LEFT                      128
#define C140_COMMAND_SAVE_GAME                                              140
#define C145_COMMAND_SLEEP                                                  145
#define C146_COMMAND_WAKE_UP                                                146
#define C147_COMMAND_FREEZE_GAME                                            147
#define C148_COMMAND_UNFREEZE_GAME                                          148
#define C160_COMMAND_CLICK_IN_PANEL_RESURRECT                               160
#define C161_COMMAND_CLICK_IN_PANEL_REINCARNATE                             161
#define C162_COMMAND_CLICK_IN_PANEL_CANCEL                                  162
#define C200_COMMAND_ENTRANCE_ENTER_DUNGEON                                 200
#define C201_COMMAND_ENTRANCE_RESUME                                        201
#define C202_COMMAND_ENTRANCE_DRAW_CREDITS                                  202
#define C210_COMMAND_CLICK_ON_DIALOG_CHOICE_1                               210
#define C211_COMMAND_CLICK_ON_DIALOG_CHOICE_2                               211
#define C212_COMMAND_CLICK_ON_DIALOG_CHOICE_3                               212
#define C213_COMMAND_CLICK_ON_DIALOG_CHOICE_4                               213
#define C215_COMMAND_RESTART_GAME                                           215

typedef unsigned int THING; /* Bits 15-14: Cell, Bits 13-10: Type, Bits 9-0: Index */
#define MASK0xC000_THING_CELL 0xC000

#define M11_CELL(thing)                      ((thing) >> 14)
#define M12_TYPE(thing)                      (((thing) & 0x3C00) >> 10)
#define M13_INDEX(thing)                     ((thing) & 0x03FF)
#define M14_TYPE_AND_INDEX(thing)            ((thing) & 0x3FFF)
#define M15_THING_WITH_NEW_CELL(thing, cell) ((thing) & 0x3FFF) | ((cell) << 14)

/* Thing types (11 to 13 are not used) */
#define CM1_THING_TYPE_PARTY      -1 /* This special thing type represents the party for some functions */
#define C00_THING_TYPE_DOOR        0
#define C01_THING_TYPE_TELEPORTER  1
#define C02_THING_TYPE_TEXT        2
#define C03_THING_TYPE_SENSOR      3
#define C04_THING_TYPE_GROUP       4
#define C05_THING_TYPE_WEAPON      5
#define C06_THING_TYPE_ARMOUR      6
#define C07_THING_TYPE_SCROLL      7
#define C08_THING_TYPE_POTION      8
#define C09_THING_TYPE_CONTAINER   9
#define C10_THING_TYPE_JUNK       10
#define C14_THING_TYPE_PROJECTILE 14
#define C15_THING_TYPE_EXPLOSION  15

/* Special thing values */
#define C0xFF80_THING_FIRST_EXPLOSION             -128 /* These special EXPLOSION thing values are used in projectiles. Actual EXPLOSION things are only created after projectile impacts */
#define C0xFF80_THING_EXPLOSION_FIREBALL          -128
#define C0xFF81_THING_EXPLOSION_SLIME             -127
#define C0xFF82_THING_EXPLOSION_LIGHTNING_BOLT    -126
#define C0xFF83_THING_EXPLOSION_HARM_NON_MATERIAL -125
#define C0xFF84_THING_EXPLOSION_OPEN_DOOR         -124
#define C0xFF86_THING_EXPLOSION_POISON_BOLT       -122
#define C0xFF87_THING_EXPLOSION_POISON_CLOUD      -121
#define C0xFFA8_THING_EXPLOSION_SMOKE              -88
#define C0xFFB2_THING_EXPLOSION_FLUXCAGE           -78
#define C0xFFE4_THING_EXPLOSION_REBIRTH_STEP1      -28
#define C0xFFE5_THING_EXPLOSION_REBIRTH_STEP2      -27
#define C0xFFFE_THING_ENDOFLIST                     -2 /* In 'Next' member of thing data: means the thing data is used and is the last in its linked list */
#define C0xFFFF_THING_NONE                          -1 /* In 'Next' member of thing data: means the thing data is unused */
#define C0xFFFF_THING_PARTY                         -1 /* This thing value represents the party for some functions */

/* Cells and Directions */
#define CM1_CELL_ANY       -1
#define C00_CELL_NORTHWEST  0
#define C01_CELL_NORTHEAST  1
#define C02_CELL_SOUTHEAST  2
#define C03_CELL_SOUTHWEST  3

#define C0_DIRECTION_NORTH 0
#define C1_DIRECTION_EAST  1
#define C2_DIRECTION_SOUTH 2
#define C3_DIRECTION_WEST  3

#define M16_IS_ORIENTED_WEST_EAST(direction) ((direction) & 0x0001)

#define M17_NEXT(value)      (((value) + 1) & 0x0003)
#define M18_OPPOSITE(value)  (((value) + 2) & 0x0003)
#define M19_PREVIOUS(value)  (((value) + 3) & 0x0003)
#define M20_PREVIOUS(value)  (((value) - 1) & 0x0003)
#define M21_NORMALIZE(value) ((value) & 0x0003)

typedef struct {
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_29_IMPROVEMENT */
        unsigned int Noise[149]; /* Noise[10] is the key to decrypt the second part of the header */
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_29_IMPROVEMENT There is one more word before actual data in the save header. The key is now the 30th word instead of the 11th word */
        unsigned int Noise[150]; /* Noise[29] is the key to decrypt the second part of the header */
#endif
        unsigned char Useless; /* BUG0_00 Useless code. First byte of actual data in save header. Value is always 1 */
        unsigned char Format; /* Format used by the engine which created the saved game */
        long aUnreferenced; /* BUG0_00 Useless code */
        BOOLEAN SaveAndPlayChoice; /* 0 if 'Save and Quit' was used, 1 if 'Save and Play' was used */
        long GameID; /* Random value uniquely identifying a specific game. Only the same game can be reloaded after the party has died */
        unsigned int Keys[16]; /* 16 possible parts in a saved game file. Only 5 are actually used */
        unsigned int Checksums[16];
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_29_IMPROVEMENT */
        char bUnreferenced[138]; /* Not used in DM */
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_29_IMPROVEMENT The DungeonID is now written in the save header and the remaining 132 bytes of additional data are preserved when loading and saving */
        int Platform;
        unsigned int DungeonID;
        char AdditionalData[132]; /* Preserved when loading and saving the game but never actually used */
#endif
} SAVE_HEADER;

/* Format */
#define C1_FORMAT_DM_ATARI_ST                                   1
#define C2_FORMAT_DM_AMIGA_2X_PC98_X68000_FM_TOWNS_CSB_ATARI_ST 2
#define C3_FORMAT_DM_APPLE_IIGS                                 3
#define C5_FORMAT_DM_AMIGA_36_PC_CSB_AMIGA_PC98_X68000_FM_TOWNS 5

/* Platform */
#define C1_PLATFORM_ATARI_ST    1
#define C2_PLATFORM_APPLE_IIGS  2
#define C3_PLATFORM_AMIGA       3
#define C5_PLATFORM_PC98        5
#define C6_PLATFORM_X68000      6
#define C7_PLATFORM_FM_TOWNS_EN 7
#define C8_PLATFORM_FM_TOWNS_JP 8
#define C9_PLATFORM_PC          9

/* Dungeon IDs */
#define C00_DUNGEON_UNKNOWN     0
#define C10_DUNGEON_DM         10
#define C12_DUNGEON_CSB_PRISON 12
#define C13_DUNGEON_CSB_GAME   13 /* Value used in CSB MINI.DAT */
#define C50_DUNGEON_KID        50

typedef struct {
        char* Address;
        unsigned int ByteCount;
} SAVE_PART;

/* Saved game parts */
#define C0_SAVE_PART_GLOBAL_DATA  0
#define C1_SAVE_PART_ACTIVE_GROUP 1
#define C2_SAVE_PART_PARTY        2
#define C3_SAVE_PART_EVENTS       3
#define C4_SAVE_PART_TIMELINE     4

typedef struct {
        unsigned long GameTime;
        unsigned long LastRandomNumber;
        THING LeaderHandObject;
        unsigned int PartyChampionCount;
        int PartyMapX;
        int PartyMapY;
        int PartyDirection;
        int PartyMapIndex;
        int LeaderIndex;
        int MagicCasterChampionIndex;
        unsigned int EventCount;
        unsigned int FirstUnusedEventIndex;
        unsigned int EventMaximumCount;
        unsigned int CurrentActiveGroupCount;
        long LastCreatureAttackTime;
        long LastPartyMovementTime;
        int DisabledMovementTicks;
        int ProjectileDisabledMovementTicks;
        int LastProjectileDisabledMovementDirection;
        unsigned int MaximumActiveGroupCount;
        char Useless[80]; /* BUG0_00 Useless code */
} GLOBAL_DATA;

typedef struct {
        int GroupThingIndex;
        unsigned char Directions;
        unsigned char Cells;
        unsigned char LastMoveTime;
        unsigned char DelayFleeingFromTarget;
        unsigned char TargetMapX;
        unsigned char TargetMapY;
        unsigned char PriorMapX;
        unsigned char PriorMapY;
        unsigned char HomeMapX;
        unsigned char HomeMapY;
        unsigned char Aspect[4];
} ACTIVE_GROUP;

/* Active Group Creature Aspect */
#define M22_HORIZONTAL_OFFSET(aspect)             ((aspect) & 0x0007)
#define M23_VERTICAL_OFFSET(aspect)               (((aspect) >> 3) & 0x0007)
#define M24_SET_HORIZONTAL_OFFSET(aspect, offset) ((aspect) |= (offset))
#define M25_SET_VERTICAL_OFFSET(aspect, offset)   ((aspect) |= ((offset) << 3))
#define MASK0x0040_FLIP_BITMAP  0x0040
#define MASK0x0080_IS_ATTACKING 0x0080

typedef struct {
        int TemporaryExperience;
        long Experience;
} SKILL;

typedef struct {
        char Name[8];
        char Title[20];
        unsigned char Direction;
        unsigned char Cell;
        char Useless1; /* BUG0_00 Useless code. Always 1 in DM and CSB Atari ST, DM Apple IIGS, DM Amiga 2.x (versions where champion portrait is part of the CHAMPION structure). Always 0 in all other versions where champion portrait is not part of the CHAMPION structure */
        char Useless2; /* BUG0_00 Useless code. Always 2 in DM and CSB Atari ST, DM Apple IIGS, DM Amiga 2.x (versions where champion portrait is part of the CHAMPION structure). Always 0 in all other versions where champion portrait is not part of the CHAMPION structure */
        unsigned char ActionIndex;
        unsigned char SymbolStep; /* Values 0..3, determines which set of 6 available symbols is drawn in the spell area */
        char Symbols[5];
        char aUnreferenced;
        unsigned char DirectionMaximumDamageReceived;
        unsigned char MaximumDamageReceived;
        char PoisonEventCount;
        char bUnreferenced;
        int EnableActionEventIndex;
        int HideDamageReceivedEventIndex;
        int Attributes;
        int Wounds;
        int CurrentHealth;
        int MaximumHealth;
        int CurrentStamina;
        int MaximumStamina;
        int CurrentMana;
        int MaximumMana;
        int ActionDefense;
        int Food;
        int Water;
        unsigned char Statistics[7][3]; /* 1 byte of padding inserted by compiler (not inserted on x86 platforms thus champion data is 799 bytes large or 319 bytes large, instead of 800 or 320) */
        SKILL Skills[20];
        THING Slots[30];
        unsigned int Load;
        int ShieldDefense;
        char cUnreferenced[44]; /* BUG0_00 Useless code. Contains additional data in some versions:
        unsigned char* Portrait; Pointer to portrait data when it is not directly part of this structure. In Amiga 3.x and PC versions (and probably others)
        unsigned char MagicMapWizardSpellCount; Show active spells on magic map. In Chaos Strikes Back 3.x
        unsigned char MagicMapNinjaSpellCount; Show fake walls and hidden pits on magic map. In Chaos Strikes Back 3.x
        unsigned char MagicMapFighterSpellCount; Show creatures on magic map. In Chaos Strikes Back 3.x
        unsigned char MagicMapPriestSpellDirectionOrdinal; Anchor magic map to the casting point. In Chaos Strikes Back 3.x
        unsigned int MagicMapPriestSpellLocation; In Chaos Strikes Back 3.x */
        char dUnreferenced[16]; /* BUG0_00 Useless code. Not part of this structure on platforms where portraits are not part of the CHAMPION structure */
        unsigned char Portrait[464]; /* 32 x 29 pixels bitmap. Not part of this structure on some platforms */
} CHAMPION;

/* Champion indices */
#define CM1_CHAMPION_NONE            -1
#define C00_CHAMPION_FIRST            0
#define C04_CHAMPION_CLOSE_INVENTORY  4

#define M26_CHAMPION_ICON_INDEX(value, direction) ((value + 4 - direction) & 0x0003)

/* Champion attributes */
#define MASK0x0008_DISABLE_ACTION 0x0008
#define MASK0x0010_MALE           0x0010
#define MASK0x0080_NAME_TITLE     0x0080
#define MASK0x0100_STATISTICS     0x0100
#define MASK0x0200_LOAD           0x0200
#define MASK0x0400_ICON           0x0400
#define MASK0x0800_PANEL          0x0800
#define MASK0x1000_STATUS_BOX     0x1000
#define MASK0x2000_WOUNDS         0x2000
#define MASK0x4000_VIEWPORT       0x4000
#define MASK0x8000_ACTION_HAND    0x8000

/* Champion wounds */
#define MASK0x0000_NO_WOUND    0x0000
#define MASK0x0001_READY_HAND  0x0001
#define MASK0x0002_ACTION_HAND 0x0002
#define MASK0x0004_HEAD        0x0004
#define MASK0x0008_TORSO       0x0008
#define MASK0x0010_LEGS        0x0010
#define MASK0x0020_FEET        0x0020

/* Champion statistics */
#define C0_STATISTIC_LUCK      0
#define C1_STATISTIC_STRENGTH  1
#define C2_STATISTIC_DEXTERITY 2
#define C3_STATISTIC_WISDOM    3
#define C4_STATISTIC_VITALITY  4
#define C5_STATISTIC_ANTIMAGIC 5
#define C6_STATISTIC_ANTIFIRE  6
#define C8_STATISTIC_MANA      8 /* Used as a fake statistic index for objects granting a Mana bonus */
#define C0_MAXIMUM             0
#define C1_CURRENT             1
#define C2_MINIMUM             2

/* Champion skills */
#define C00_SKILL_FIGHTER    0
#define C01_SKILL_NINJA      1
#define C02_SKILL_PRIEST     2
#define C03_SKILL_WIZARD     3
#define C04_SKILL_SWING      4
#define C05_SKILL_THRUST     5
#define C06_SKILL_CLUB       6
#define C07_SKILL_PARRY      7
#define C08_SKILL_STEAL      8
#define C09_SKILL_FIGHT      9
#define C10_SKILL_THROW     10
#define C11_SKILL_SHOOT     11
#define C12_SKILL_IDENTIFY  12
#define C13_SKILL_HEAL      13
#define C14_SKILL_INFLUENCE 14
#define C15_SKILL_DEFEND    15
#define C16_SKILL_FIRE      16
#define C17_SKILL_AIR       17
#define C18_SKILL_EARTH     18
#define C19_SKILL_WATER     19

/* Slots */
#define CM1_SLOT_LEADER_HAND      -1
#define C00_SLOT_READY_HAND        0
#define C01_SLOT_ACTION_HAND       1
#define C02_SLOT_HEAD              2
#define C03_SLOT_TORSO             3
#define C04_SLOT_LEGS              4
#define C05_SLOT_FEET              5
#define C06_SLOT_POUCH_2           6
#define C07_SLOT_QUIVER_LINE2_1    7
#define C08_SLOT_QUIVER_LINE1_2    8
#define C09_SLOT_QUIVER_LINE2_2    9
#define C10_SLOT_NECK             10
#define C11_SLOT_POUCH_1          11
#define C12_SLOT_QUIVER_LINE1_1   12
#define C13_SLOT_BACKPACK_LINE1_1 13
#define C14_SLOT_BACKPACK_LINE2_2 14
#define C15_SLOT_BACKPACK_LINE2_3 15
#define C16_SLOT_BACKPACK_LINE2_4 16
#define C17_SLOT_BACKPACK_LINE2_5 17
#define C18_SLOT_BACKPACK_LINE2_6 18
#define C19_SLOT_BACKPACK_LINE2_7 19
#define C20_SLOT_BACKPACK_LINE2_8 20
#define C21_SLOT_BACKPACK_LINE2_9 21
#define C22_SLOT_BACKPACK_LINE1_2 22
#define C23_SLOT_BACKPACK_LINE1_3 23
#define C24_SLOT_BACKPACK_LINE1_4 24
#define C25_SLOT_BACKPACK_LINE1_5 25
#define C26_SLOT_BACKPACK_LINE1_6 26
#define C27_SLOT_BACKPACK_LINE1_7 27
#define C28_SLOT_BACKPACK_LINE1_8 28
#define C29_SLOT_BACKPACK_LINE1_9 29
#define C30_SLOT_CHEST_1          30
#define C31_SLOT_CHEST_2          31
#define C32_SLOT_CHEST_3          32
#define C33_SLOT_CHEST_4          33
#define C34_SLOT_CHEST_5          34
#define C35_SLOT_CHEST_6          35
#define C36_SLOT_CHEST_7          36
#define C37_SLOT_CHEST_8          37

/* Portrait coordinates in graphic #26 */
#define M27_PORTRAIT_X(index) (((index) & 0x0007) << 5)
#define M28_PORTRAIT_Y(index) (((index) >> 3) * 29)

typedef union {
        struct {
                unsigned int MapX     :5;
                unsigned int MapY     :5;
                unsigned int MapIndex :6;
        } Location;
        unsigned int Scent;
} SCENT;

typedef struct {
        CHAMPION Champions[4];
        int MagicalLightAmount;
        char Event73Count_ThievesEye;
        char Event79Count_Footprints;
        int ShieldDefense;
        int FireShieldDefense;
        int SpellShieldDefense;
        unsigned char ScentCount;
        unsigned char FreezeLifeTicks;
        unsigned char FirstScentIndex;
        unsigned char LastScentIndex;
        SCENT Scents[24];
        unsigned char ScentStrengths[24];
        char Event71Count_Invisibility;
        char aUnreferenced; /* BUG0_00 Useless code */
        char bUnreferenced[40]; /* BUG0_00 Useless code */
} PARTY;

typedef struct {
        long Map_Time;
        union {
                struct {
                        unsigned char Type;
                        unsigned char Priority;
                } A;
                unsigned int Type_Priority; /* If two events occur at the same time, the one with the highest value will be processed first */
        } A;
        union {
                struct {
                        unsigned char MapX;
                        unsigned char MapY;
                } Location;
                int MapXY;
                int Attack;
                int Defense;
                int LightPower;
                THING Slot;
                char SlotOrdinal;
        } B;
        union {
                struct {
                        unsigned char Cell;
                        unsigned char Effect;
                } A;
                struct {
                        unsigned int MapX       :5;
                        unsigned int MapY       :5;
                        unsigned int Direction  :2;
                        unsigned int StepEnergy :4;
                } Projectile;
                THING Slot;
                int SoundIndex;
                unsigned char Ticks;
        } C;
} EVENT;

#define M29_MAP(map_time)                         ((unsigned int)((map_time) >> 24))
#define M30_TIME(map_time)                        ((map_time) & 0x00FFFFFF)
#define M31_SET_MAP(map_time, map)                (map_time) = (((map_time) & 0x00FFFFFF) | (((long)(map)) << 24))
#define M32_SET_TIME(map_time, time)              (map_time) = (((map_time) & 0xFF000000) | (time))
#define M33_SET_MAP_AND_TIME(map_time, map, time) (map_time) = ((time) | (((long)(map)) << 24))

/* Event types */
#define CM3_EVENT_CREATE_REACTION_EVENT_29_DANGER_ON_SQUARE  -3 /* Used when a creature in a group was damaged or killed by a Poison Cloud or by a closing door or if Lord Chaos is surrounded by 3 Fluxcages */
#define CM2_EVENT_CREATE_REACTION_EVENT_30_HIT_BY_PROJECTILE -2 /* Used when a projectile impacts with a creature in a group */
#define CM1_EVENT_CREATE_REACTION_EVENT_31_PARTY_IS_ADJACENT -1 /* Used when the party bumps into a group or performs a melee attack */
#define C00_EVENT_NONE                                        0
#define C01_EVENT_DOOR_ANIMATION                              1
#define C02_EVENT_DOOR_DESTRUCTION                            2
#define C05_EVENT_CORRIDOR                                    5
#define C06_EVENT_WALL                                        6
#define C07_EVENT_FAKEWALL                                    7
#define C08_EVENT_TELEPORTER                                  8
#define C09_EVENT_PIT                                         9
#define C10_EVENT_DOOR                                       10
#define C11_EVENT_ENABLE_CHAMPION_ACTION                     11
#define C12_EVENT_HIDE_DAMAGE_RECEIVED                       12
#define C13_EVENT_VI_ALTAR_REBIRTH                           13
#define C20_EVENT_PLAY_SOUND                                 20
#define C22_EVENT_COPYPROTECTIONE                            22
#define C24_EVENT_REMOVE_FLUXCAGE                            24
#define C25_EVENT_EXPLOSION                                  25
#define C29_EVENT_GROUP_REACTION_DANGER_ON_SQUARE            29
#define C30_EVENT_GROUP_REACTION_HIT_BY_PROJECTILE           30
#define C31_EVENT_GROUP_REACTION_PARTY_IS_ADJACENT           31
#define C32_EVENT_UPDATE_ASPECT_GROUP                        32
#define C33_EVENT_UPDATE_ASPECT_CREATURE_0                   33 /* Events 33-36 and 38-41 are used for individual creatures only while the group is attacking the party */
#define C34_EVENT_UPDATE_ASPECT_CREATURE_1                   34
#define C35_EVENT_UPDATE_ASPECT_CREATURE_2                   35
#define C36_EVENT_UPDATE_ASPECT_CREATURE_3                   36
#define C37_EVENT_UPDATE_BEHAVIOR_GROUP                      37
#define C38_EVENT_UPDATE_BEHAVIOR_CREATURE_0                 38
#define C39_EVENT_UPDATE_BEHAVIOR_CREATURE_1                 39
#define C40_EVENT_UPDATE_BEHAVIOR_CREATURE_2                 40
#define C41_EVENT_UPDATE_BEHAVIOR_CREATURE_3                 41
#define C48_EVENT_MOVE_PROJECTILE_IGNORE_IMPACTS             48 /* Projectiles created by a champion (by casting a spell, shooting a weapon or throwing an object) or by a creature (by casting a spell) ignore impacts during their first movement otherwise an impact would always occur immediately as these projectiles are created on the champion or creature square */
#define C49_EVENT_MOVE_PROJECTILE                            49 /* Projectiles created by projectile launcher sensors never ignore impacts as well as all other projectiles after their first movement */
#define C53_EVENT_WATCHDOG                                   53
#define C60_EVENT_MOVE_GROUP_SILENT                          60
#define C61_EVENT_MOVE_GROUP_AUDIBLE                         61
#define C65_EVENT_ENABLE_GROUP_GENERATOR                     65
#define C70_EVENT_LIGHT                                      70
#define C71_EVENT_INVISIBILITY                               71
#define C72_EVENT_CHAMPION_SHIELD                            72
#define C73_EVENT_THIEVES_EYE                                73
#define C74_EVENT_PARTY_SHIELD                               74
#define C75_EVENT_POISON_CHAMPION                            75
#define C77_EVENT_SPELLSHIELD                                77
#define C78_EVENT_FIRESHIELD                                 78
#define C79_EVENT_FOOTPRINTS                                 79

typedef struct {
        unsigned int Signature;
        long DecompressedByteCount;
        unsigned int DungeonID;
} COMPRESSED_DUNGEON_HEADER;

#define C0x8104_SIGNATURE_COMPRESSED_DUNGEON 0x8104

typedef struct {
        unsigned int OrnamentRandomSeed;
        unsigned int RawMapDataByteCount;
        unsigned char MapCount; /* The compiler inserts a padding 0x00 byte after this variable to align the next int on an even memory address */
        unsigned int TextDataWordCount;
        unsigned int InitialPartyLocation; /* Bits 15-12 Unreferenced, Bits 11-10: Direction, Bits 9-5: Y, Bits 4-0: X */
        unsigned int SquareFirstThingCount;
        unsigned int ThingCount[16];
} DUNGEON_HEADER;

/* Squares */
#define M34_SQUARE_TYPE(square)   ((square) >> 5)
#define M35_SQUARE(element, mask) (((element) << 5) | mask)

/* Elements (Square types, projectile impact types, square aspect) */
#define CM2_ELEMENT_CHAMPION     -2 /* Values -2 and -1 are only used as projectile impact types */
#define CM1_ELEMENT_CREATURE     -1
#define C00_ELEMENT_WALL          0 /* Values 0-6 are used as square types and projectile impact types. Values 0-2 and 5-6 are also used for square aspect */
#define C01_ELEMENT_CORRIDOR      1
#define C02_ELEMENT_PIT           2
#define C03_ELEMENT_STAIRS        3
#define C04_ELEMENT_DOOR          4
#define C05_ELEMENT_TELEPORTER    5
#define C06_ELEMENT_FAKEWALL      6
#define C16_ELEMENT_DOOR_SIDE    16 /* Values 16-19 are only used for square aspect */
#define C17_ELEMENT_DOOR_FRONT   17
#define C18_ELEMENT_STAIRS_SIDE  18
#define C19_ELEMENT_STAIRS_FRONT 19

/* Square masks */
#define MASK0x0001_WALL_WEST_RANDOM_ORNAMENT_ALLOWED              0x0001
#define MASK0x0002_WALL_SOUTH_RANDOM_ORNAMENT_ALLOWED             0x0002
#define MASK0x0004_WALL_EAST_RANDOM_ORNAMENT_ALLOWED              0x0004
#define MASK0x0008_WALL_NORTH_RANDOM_ORNAMENT_ALLOWED             0x0008
#define MASK0x0008_CORRIDOR_RANDOM_ORNAMENT_ALLOWED               0x0008
#define MASK0x0001_PIT_IMAGINARY                                  0x0001
#define MASK0x0004_PIT_INVISIBLE                                  0x0004
#define MASK0x0008_PIT_OPEN                                       0x0008
#define MASK0x0004_STAIRS_UP                                      0x0004
#define MASK0x0008_STAIRS_NORTH_SOUTH_ORIENTATION                 0x0008
#define MASK0x0008_DOOR_NORTH_SOUTH_ORIENTATION                   0x0008
#define MASK0x0004_TELEPORTER_VISIBLE                             0x0004
#define MASK0x0008_TELEPORTER_OPEN                                0x0008
#define MASK0x0001_FAKEWALL_IMAGINARY                             0x0001
#define MASK0x0004_FAKEWALL_OPEN                                  0x0004
#define MASK0x0008_FAKEWALL_RANDOM_ORNAMENT_OR_FOOTPRINTS_ALLOWED 0x0008
#define MASK0x0010_THING_LIST_PRESENT                             0x0010

/* Door states */
#define C0_DOOR_STATE_OPEN                0
#define C1_DOOR_STATE_CLOSED_ONE_FOURTH   1
#define C2_DOOR_STATE_CLOSED_HALF         2
#define C3_DOOR_STATE_CLOSED_THREE_FOURTH 3
#define C4_DOOR_STATE_CLOSED              4
#define C5_DOOR_STATE_DESTROYED           5

#define M36_DOOR_STATE(square)            ((square) & 0x0007)
#define M37_SET_DOOR_STATE(square, state) (square) = ((((square) & 0x00FF) & ~0x0007) | state)

typedef struct {
        unsigned int RawMapDataByteOffset;
        unsigned int aUnreferenced; /* BUG0_00 Useless code */
        unsigned int bUnreferenced; /* BUG0_00 Useless code */
        unsigned char OffsetMapX;
        unsigned char OffsetMapY;
        struct {
                unsigned int Level                    :6;
                unsigned int Width                    :5;
                unsigned int Height                   :5;
        } A;
        struct {
                unsigned int WallOrnamentCount        :4; /* May be used in a Sensor on a Wall or closed Fake Wall square */
                unsigned int RandomWallOrnamentCount  :4; /* Used only on some Wall squares and some closed Fake Wall squares */
                unsigned int FloorOrnamentCount       :4; /* May be used in a Sensor on a Pit, open Fake Wall, Corridor or Teleporter square */
                unsigned int RandomFloorOrnamentCount :4; /* Used only on some Corridor squares and some open Fake Wall squares */
        } B;
        struct {
                unsigned int DoorOrnamentCount        :4;
                unsigned int CreatureTypeCount        :4;
                unsigned int Unreferenced             :4;
                unsigned int Difficulty               :4;
        } C;
        struct {
                unsigned int FloorSet                 :4;
                unsigned int WallSet                  :4;
                unsigned int DoorSet0                 :4;
                unsigned int DoorSet1                 :4;
        } D;
} MAP;

#define CM1_MAP_INDEX_NONE       -1
#define C255_MAP_INDEX_ENTRANCE 255

#define M38_DISTANCE(mapx1, mapy1, mapx2, mapy2) (F023_aarz_MAIN_GetAbsoluteValue((mapx1) - (int)(mapx2)) + F023_aarz_MAIN_GetAbsoluteValue((mapy1) - (int)(mapy2)))

typedef struct {
        THING Next;
} GENERIC;

typedef struct {
        THING Next;
        unsigned int Type              :1;
        unsigned int OrnamentOrdinal   :4;
        unsigned int Vertical          :1;
        unsigned int Button            :1;
        unsigned int MagicDestructible :1;
        unsigned int MeleeDestructible :1;
        unsigned int Unreferenced      :7;
} DOOR;

typedef struct {
        THING Next;
        struct {
                unsigned int TargetMapX       :5;
                unsigned int TargetMapY       :5;
                unsigned int Rotation         :2;
                unsigned int AbsoluteRotation :1;
                unsigned int Scope            :2; /* 0: Objects, 1: Groups, 2: Objects and Party, 3: Objects, Groups and Party */
                unsigned int Audible          :1;
        } A;
        struct {
                unsigned int Unreferenced     :8;
                unsigned int TargetMapIndex   :8;
        } B;
} TELEPORTER;

/* Teleporter Scopes */
#define MASK0x0001_SCOPE_CREATURES        0x0001
#define MASK0x0002_SCOPE_OBJECTS_OR_PARTY 0x0002

typedef struct {
        THING Next;
        unsigned int Visible            :1;
        unsigned int Unreferenced       :2;
        unsigned int TextDataWordOffset :13;
} TEXT;

/* Four kinds of sensors: Regular with local target, Regular with remote target, Group generator, Launcher */
typedef struct {
        THING Next;
        unsigned int Type_Data;
        struct {
                unsigned int Unreferenced         :2;
                unsigned int OnceOnly             :1;
                unsigned int Effect               :2; /* Not used for group generators */
                unsigned int RevertEffect         :1; /* Not used for group generators */
                unsigned int Audible              :1;
                unsigned int Value                :4; /* Ticks for all sensors except group generators (where Bit 10: 0 fixed number, 1 random number and Bits 9-7: count) and end game (where the value is a delay in seconds) */
                unsigned int LocalEffect          :1; /* Not used for group generators */
                unsigned int OrnamentOrdinal      :4;
        } A;
        union {
                struct { /* Regular with remote target */
                        unsigned int Unreferenced :4;
                        unsigned int TargetCell   :2; /* Ignored for squares other than walls */
                        unsigned int TargetMapX   :5;
                        unsigned int TargetMapY   :5;
                } A;
                struct { /* Regular with local target, Launcher, Group generators */
                        unsigned int Unreferenced :4;
                        unsigned int Multiple     :12;
                } B;
        } B;
} SENSOR;

/* Sensor types */
#define C000_SENSOR_DISABLED                                                          0 /* Never triggered, may be used for a floor or wall ornament */
#define C001_SENSOR_FLOOR_THERON_PARTY_CREATURE_OBJECT                                1 /* Triggered by party/thing F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval */
#define C002_SENSOR_FLOOR_THERON_PARTY_CREATURE                                       2 /* Triggered by party/thing F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval */
#define C003_SENSOR_FLOOR_PARTY                                                       3 /* Triggered by party/thing F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval */
#define C004_SENSOR_FLOOR_OBJECT                                                      4 /* Triggered by party/thing F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval */
#define C005_SENSOR_FLOOR_PARTY_ON_STAIRS                                             5 /* Triggered by party/thing F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval */
#define C006_SENSOR_FLOOR_GROUP_GENERATOR                                             6 /* Triggered by event F245_xxxx_TIMELINE_ProcessEvent5_Square_Corridor */
#define C007_SENSOR_FLOOR_CREATURE                                                    7 /* Triggered by party/thing F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval */
#define C008_SENSOR_FLOOR_PARTY_POSSESSION                                            8 /* Triggered by party/thing F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval */
#define C009_SENSOR_FLOOR_VERSION_CHECKER                                             9 /* Triggered by party/thing F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval */
#define C001_SENSOR_WALL_ORNAMENT_CLICK                                               1 /* Triggered by player click F275_aszz_SENSOR_IsTriggeredByClickOnWall */
#define C002_SENSOR_WALL_ORNAMENT_CLICK_WITH_ANY_OBJECT                               2 /* Triggered by player click F275_aszz_SENSOR_IsTriggeredByClickOnWall */
#define C003_SENSOR_WALL_ORNAMENT_CLICK_WITH_SPECIFIC_OBJECT                          3 /* Triggered by player click F275_aszz_SENSOR_IsTriggeredByClickOnWall */
#define C004_SENSOR_WALL_ORNAMENT_CLICK_WITH_SPECIFIC_OBJECT_REMOVED                  4 /* Triggered by player click F275_aszz_SENSOR_IsTriggeredByClickOnWall */
#define C005_SENSOR_WALL_AND_OR_GATE                                                  5 /* Triggered by event F248_xxxx_TIMELINE_ProcessEvent6_Square_Wall */
#define C006_SENSOR_WALL_COUNTDOWN                                                    6 /* Triggered by event F248_xxxx_TIMELINE_ProcessEvent6_Square_Wall */
#define C007_SENSOR_WALL_SINGLE_PROJECTILE_LAUNCHER_NEW_OBJECT                        7 /* Triggered by event F248_xxxx_TIMELINE_ProcessEvent6_Square_Wall */
#define C008_SENSOR_WALL_SINGLE_PROJECTILE_LAUNCHER_EXPLOSION                         8 /* Triggered by event F248_xxxx_TIMELINE_ProcessEvent6_Square_Wall */
#define C009_SENSOR_WALL_DOUBLE_PROJECTILE_LAUNCHER_NEW_OBJECT                        9 /* Triggered by event F248_xxxx_TIMELINE_ProcessEvent6_Square_Wall */
#define C010_SENSOR_WALL_DOUBLE_PROJECTILE_LAUNCHER_EXPLOSION                        10 /* Triggered by event F248_xxxx_TIMELINE_ProcessEvent6_Square_Wall */
#define C011_SENSOR_WALL_ORNAMENT_CLICK_WITH_SPECIFIC_OBJECT_REMOVED_ROTATE_SENSORS  11 /* Triggered by player click F275_aszz_SENSOR_IsTriggeredByClickOnWall */
#define C012_SENSOR_WALL_OBJECT_GENERATOR_ROTATE_SENSORS                             12 /* Triggered by player click F275_aszz_SENSOR_IsTriggeredByClickOnWall */
#define C013_SENSOR_WALL_SINGLE_OBJECT_STORAGE_ROTATE_SENSORS                        13 /* Triggered by player click F275_aszz_SENSOR_IsTriggeredByClickOnWall */
#define C014_SENSOR_WALL_SINGLE_PROJECTILE_LAUNCHER_SQUARE_OBJECT                    14 /* Triggered by event F248_xxxx_TIMELINE_ProcessEvent6_Square_Wall */
#define C015_SENSOR_WALL_DOUBLE_PROJECTILE_LAUNCHER_SQUARE_OBJECT                    15 /* Triggered by event F248_xxxx_TIMELINE_ProcessEvent6_Square_Wall */
#define C016_SENSOR_WALL_OBJECT_EXCHANGER                                            16 /* Triggered by player click F275_aszz_SENSOR_IsTriggeredByClickOnWall */
#define C017_SENSOR_WALL_ORNAMENT_CLICK_WITH_SPECIFIC_OBJECT_REMOVED_REMOVE_SENSOR   17 /* Triggered by player click F275_aszz_SENSOR_IsTriggeredByClickOnWall */
#define C018_SENSOR_WALL_END_GAME                                                    18 /* Triggered by event F248_xxxx_TIMELINE_ProcessEvent6_Square_Wall */
#define C127_SENSOR_WALL_CHAMPION_PORTRAIT                                          127 /* Triggered by player click F275_aszz_SENSOR_IsTriggeredByClickOnWall */

/* Sensor and event effects */
#define CM1_EFFECT_NONE           -1
#define C00_EFFECT_SET             0
#define C01_EFFECT_CLEAR           1
#define C02_EFFECT_TOGGLE          2
#define C03_EFFECT_HOLD            3
#define C10_EFFECT_ADD_EXPERIENCE 10

/* Sensor type and data */
#define M39_TYPE(sensor)              ((sensor)->Type_Data & 0x007F)
#define M40_DATA(sensor)              ((sensor)->Type_Data >> 7)
#define M41_SET_DATA(sensor, data)    (((sensor)->Type_Data) = (((sensor)->Type_Data) & 0x007F) | (data << 7))
#define M42_MASK1(data)               ((data) & 0x000F)
#define M43_MASK2(data)               (((data) & 0x00F0) >> 4)
#define M44_SET_TYPE_DISABLED(sensor) (((sensor)->Type_Data) &= 0xFF80)
#define M45_HEALTH_MULTIPLIER(sensor) ((sensor)->B.B.Multiple & 0x000F) /* Used for group generators */
#define M46_TICKS(sensor)             ((sensor)->B.B.Multiple >> 4)     /* Used for group generators */
#define M47_KINETIC_ENERGY(sensor)    ((sensor)->B.B.Multiple & 0x00FF) /* Used for launchers */
#define M48_STEP_ENERGY(sensor)       ((sensor)->B.B.Multiple >> 8)     /* Used for launchers */
#define M49_LOCAL_EFFECT(sensor)      ((sensor)->B.B.Multiple)          /* Used for regular with local target */

/* Group generator */
#define MASK0x0007_GENERATED_CREATURE_COUNT           0x0007
#define MASK0x0008_RANDOMIZE_GENERATED_CREATURE_COUNT 0x0008

typedef struct {
        THING Next;
        THING Slot;
        unsigned char Type;
        unsigned char Cells;
#define ActiveGroupIndex Cells /* Groups on the same map as the party have an associated ACTIVE_GROUP structure whose index is stored in place of the Cells, which are then stored in the ACTIVE_GROUP structure itself */
        unsigned int Health[4];
        unsigned int Behavior      :4;
        unsigned int aUnreferenced :1;
        unsigned int Count         :2;
        unsigned int bUnreferenced :1;
        unsigned int Direction     :2;
        unsigned int DoNotDiscard  :1;
        unsigned int cUnreferenced :5;
} GROUP;

/* Creature types */
#define C01_CREATURE_SWAMP_SLIME_SLIME_DEVIL      1
#define C02_CREATURE_GIGGLER                      2
#define C03_CREATURE_WIZARD_EYE_FLYING_EYE        3
#define C04_CREATURE_PAIN_RAT_HELLHOUND           4
#define C06_CREATURE_SCREAMER                     6
#define C07_CREATURE_ROCK_ROCKPILE                7
#define C09_CREATURE_STONE_GOLEM                  9
#define C11_CREATURE_BLACK_FLAME                 11
#define C12_CREATURE_SKELETON                    12
#define C14_CREATURE_VEXIRK                      14
#define C15_CREATURE_MAGENTA_WORM_WORM           15
#define C16_CREATURE_TROLIN_ANTMAN               16
#define C18_CREATURE_ANIMATED_ARMOUR_DETH_KNIGHT 18
#define C19_CREATURE_MATERIALIZER_ZYTAZ          19
#define C22_CREATURE_DEMON                       22
#define C23_CREATURE_LORD_CHAOS                  23
#define C24_CREATURE_RED_DRAGON                  24
#define C25_CREATURE_LORD_ORDER                  25
#define C26_CREATURE_GREY_LORD                   26

#define C255_SINGLE_CENTERED_CREATURE   255 /* Special value for Cells when the group contains a single creature on the center of the square */

#define M50_CREATURE_VALUE(groupvalue, creatureindex) (((groupvalue) >> ((creatureindex) << 1)) & 0x0003) /* Used to get the cell of a creature in a group (or to get a creature direction in a group on the same map as the party) */

/* Group behaviors */
#define C0_BEHAVIOR_WANDER   0 /* The group moves toward the party if it can smell it nearby or follows its scent if present. Otherwise it moves in random directions */
#define C2_BEHAVIOR_USELESS  2 /* This behavior is never used */
#define C3_BEHAVIOR_USELESS  3 /* This behavior is never used */
#define C4_BEHAVIOR_USELESS  4 /* This behavior is never used */
#define C5_BEHAVIOR_FLEE     5 /* The group is afraid and flees from its target (the square where the party or danger was last seen) */
#define C6_BEHAVIOR_ATTACK   6 /* The group attacks the party. The group will cast spells if it is in range and on the same row or column as the party. Otherwise it will move closer to the party for melee attacks */
#define C7_BEHAVIOR_APPROACH 7 /* The group is not close enough to attack and moves toward its target (the square where the party was last seen) */

typedef struct {
        THING Next;
        unsigned int Type         :7;
        unsigned int DoNotDiscard :1;
        unsigned int Cursed       :1;
        unsigned int Poisoned     :1;
        unsigned int ChargeCount  :4;
        unsigned int Broken       :1;
        unsigned int Lit          :1; /* Used only for Torches */
} WEAPON;

/* Weapon types */
#define C02_WEAPON_TORCH          2
#define C08_WEAPON_DAGGER         8
#define C27_WEAPON_ARROW         27
#define C28_WEAPON_SLAYER        28
#define C30_WEAPON_ROCK          30
#define C31_WEAPON_POISON_DART   31
#define C32_WEAPON_THROWING_STAR 32

typedef struct {
        THING Next;
        unsigned int Type         :7;
        unsigned int DoNotDiscard :1;
        unsigned int Cursed       :1;
        unsigned int ChargeCount  :4;
        unsigned int Broken       :1;
        unsigned int Unreferenced :2;
} ARMOUR;

typedef struct {
        THING Next;
        unsigned int TextThingIndex :10;
        unsigned int Closed         :6;
} SCROLL;

typedef struct {
        THING Next;
        unsigned int Power        :8;
        unsigned int Type         :7;
        unsigned int DoNotDiscard :1;
} POTION;

/* Potion types */
#define C03_POTION_VEN_POTION   3
#define C06_POTION_ROS_POTION   6
#define C07_POTION_KU_POTION    7
#define C08_POTION_DANE_POTION  8
#define C09_POTION_NETA_POTION  9
#define C10_POTION_ANTIVENIN   10
#define C11_POTION_MON_POTION  11
#define C12_POTION_YA_POTION   12
#define C13_POTION_EE_POTION   13
#define C14_POTION_VI_POTION   14
#define C15_POTION_WATER_FLASK 15
#define C19_POTION_FUL_BOMB    19
#define C20_POTION_EMPTY_FLASK 20

typedef struct {
        THING Next;
        THING Slot;
        unsigned int aUnreferenced :1;
        unsigned int Type          :2;
        unsigned int bUnreferenced :13;
        unsigned int cUnreferenced; /* BUG0_00 Useless code */
} CONTAINER;

typedef struct {
        THING Next;
        unsigned int Type         :7;
        unsigned int DoNotDiscard :1;
        unsigned int Cursed       :1;
        unsigned int Unreferenced :5;
        unsigned int ChargeCount  :2;
} JUNK;

/* Junk types */
#define C01_JUNK_WATERSKIN          1
#define C05_JUNK_BONES              5
#define C25_JUNK_BOULDER           25
#define C42_JUNK_MAGICAL_BOX_BLUE  42
#define C43_JUNK_MAGICAL_BOX_GREEN 43
#define C51_JUNK_ZOKATHRA          51

typedef struct {
        THING Next;
        THING Slot; /* The projectile associated thing may be an object or an explosion. When it is an explosion, special values are used for the 'Thing' value in the projectile slot and there is no corresponding explosion thing data. An actual explosion thing is only created after a projectile impact */
        unsigned char KineticEnergy;
        unsigned char Attack;
        int EventIndex;
} PROJECTILE;

typedef struct {
        THING Next;
        unsigned int Type     :7;
        unsigned int Centered :1;
        unsigned int Attack   :8;
} EXPLOSION;

/* Explosion types */
#define C000_EXPLOSION_FIREBALL            0
#define C001_EXPLOSION_SLIME               1
#define C002_EXPLOSION_LIGHTNING_BOLT      2
#define C003_EXPLOSION_HARM_NON_MATERIAL   3
#define C004_EXPLOSION_OPEN_DOOR           4
#define C006_EXPLOSION_POISON_BOLT         6
#define C007_EXPLOSION_POISON_CLOUD        7
#define C040_EXPLOSION_SMOKE              40
#define C050_EXPLOSION_FLUXCAGE           50
#define C100_EXPLOSION_REBIRTH_STEP1     100
#define C101_EXPLOSION_REBIRTH_STEP2     101

typedef struct {
        unsigned char Attributes;
        unsigned char Defense;
} DOOR_INFO;

/* Door Info attributes */
#define MASK0x0001_CREATURES_CAN_SEE_THROUGH    0x0001
#define MASK0x0002_PROJECTILES_CAN_PASS_THROUGH 0x0002
#define MASK0x0004_ANIMATED                     0x0004

typedef struct {
        unsigned char CreatureAspectIndex;
        unsigned char AttackSoundOrdinal;
        unsigned int Attributes; /* Bits 15-14 Unreferenced */
        unsigned int GraphicInfo; /* Bits 11 and 6 Unreferenced */
        unsigned char MovementTicks; /* Value 255 means the creature cannot move */
        unsigned char AttackTicks; /* Minimum ticks between attacks */
        unsigned char Defense;
        unsigned char BaseHealth;
        unsigned char Attack;
        unsigned char PoisonAttack;
        unsigned char Dexterity; /* 1 byte of padding inserted by compiler */
        unsigned int Ranges; /* Bits 7-4 Unreferenced */
        unsigned int Properties;
        unsigned int Resistances; /* Bits 15-12 and 3-0 Unreferenced */
        unsigned int AnimationTicks; /* Bits 15-12 Unreferenced */
        unsigned int WoundProbabilities; /* Contains 4 probabilities to wound a champion's Head (Bits 15-12), Legs (Bits 11-8), Torso (Bits 7-4) and Feet (Bits 3-0) */
        unsigned char AttackType; /* 1 byte of padding inserted by compiler */
} CREATURE_INFO;

/* Attributes */
#define MASK0x0003_SIZE                      0x0003
#define MASK0x0004_SIDE_ATTACK               0x0004
#define MASK0x0008_PREFER_BACK_ROW           0x0008
#define MASK0x0010_ATTACK_ANY_CHAMPION       0x0010
#define MASK0x0020_LEVITATION                0x0020
#define MASK0x0040_NON_MATERIAL              0x0040
#define MASK0x0200_DROP_FIXED_POSSESSIONS    0x0200
#define MASK0x0400_KEEP_THROWN_SHARP_WEAPONS 0x0400
#define MASK0x0800_SEE_INVISIBLE             0x0800
#define MASK0x1000_NIGHT_VISION              0x1000
#define MASK0x2000_ARCHENEMY                 0x2000
#define M51_HEIGHT(attributes) (((attributes) >> 7) & 0x0003)

/* Creature sizes */
#define C0_SIZE_QUARTER_SQUARE 0
#define C1_SIZE_HALF_SQUARE    1
#define C2_SIZE_FULL_SQUARE    2

/* Creature info GraphicInfo */
#define MASK0x0003_ADDITIONAL                        0x0003 /* Value 1 for creatures where next flag is set, Value 0 if next flag is clear. Used to reserve (value * 3) derived bitmap indices for flipped horizontal front bitmaps (D1, D3 and D2). However only the first set of 3 derived graphics is ever used when drawing a creature when a flipped bitmap is required. Hence values 2 and 3 are never used in the games */
#define MASK0x0004_FLIP_NON_ATTACK                   0x0004
#define MASK0x0008_SIDE                              0x0008
#define MASK0x0010_BACK                              0x0010
#define MASK0x0020_ATTACK                            0x0020
#define MASK0x0080_SPECIAL_D2_FRONT                  0x0080 /* Clear: use the front bitmap to draw the creature at D2 when viewed from the front.
                                                               Set: use the next flag to determine which bitmap to use to draw the creature at D2 when viewed from the front */
#define MASK0x0100_SPECIAL_D2_FRONT_IS_FLIPPED_FRONT 0x0100 /* Clear: use dedicated bitmap to draw the creature at D2. This is never used in the games and not fully implemented:
                                                                 In Dungeon Master (this was removed in Chaos Strikes Back), an additional native bitmap would be loaded in F096_qzzz_DUNGEONVIEW_LoadCurrentMapGraphics_COPYPROTECTIONDF
                                                                 but never used in F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF
                                                                 and it would even break the creature bitmap selection logic.
                                                               Set: use the flipped front image to draw the creature at D2 when viewed from the front */
#define MASK0x0200_FLIP_ATTACK                       0x0200
#define MASK0x0400_FLIP_DURING_ATTACK                0x0400
#define M52_MAXIMUM_HORIZONTAL_OFFSET(graphicinfo) (((graphicinfo) >> 12) & 0x0003)
#define M53_MAXIMUM_VERTICAL_OFFSET(graphicinfo)   (((graphicinfo) >> 14) & 0x0003)

/* Order of derived graphics for each creature (only the first two are mandatory, all other are optional):
Front D3
Front D2
Side D3
Side D2
Back D3
Back D2
Attacking D3
Attacking D2
(Additional Front D1
Additional Front D3
Additional Front D2) x n (0 to 3, value in MASK0x0003_ADDITIONAL) */

/* Creature info MovementTicks */
#define C255_IMMOBILE 255

/* Creature info Ranges */
#define M54_SIGHT_RANGE(ranges)  ((ranges) & 0x000F) /* Distance under which the creature can see the party */
#define M55_SMELL_RANGE(ranges)  (((ranges) >> 8) & 0x000F) /* Distance under which the creature can smell the party without seeing it */
#define M56_ATTACK_RANGE(ranges) ((ranges) >> 12) /* Distance under which the creature can attack the party (minimum 1 for melee attacks, more for spell casting) */

/* Creature info Properties */
#define M57_FEAR_RESISTANCE(properties) (((properties) >> 4) & 0x000F)
#define M58_EXPERIENCE(properties)      (((properties) >> 8) & 0x000F)
#define M59_WARINESS(properties)        ((properties) >> 12)
#define C15_IMMUNE_TO_FEAR 15

/* Creature info Resistances */
#define M60_FIRE_RESISTANCE(resistances)   (((resistances) >> 4) & 0x000F)
#define M61_POISON_RESISTANCE(resistances) (((resistances) >> 8) & 0x000F)
#define C15_IMMUNE_TO_FIRE   15
#define C15_IMMUNE_TO_POISON 15

/* Creature info AnimationTicks */
#define M62_NEXT_BEHAVIOR_UPDATE_AFTER_ATTACK_TICKS(animationticks) ((animationticks) & 0x000F)
#define M63_NEXT_NON_ATTACK_ASPECT_UPDATE_TICKS(animationticks)     (((animationticks) >> 4) & 0x000F)
#define M64_NEXT_ATTACK_ASPECT_UPDATE_TICKS(animationticks)         (((animationticks) >> 8) & 0x000F)

/* Creature info Attack types */
#define C0_ATTACK_NORMAL    0 /* Caused when a champion is poisoned, lacks stamina or stands in a Poison Cloud and by creatures (Giggler). This attack type cannot cause wounds */
#define C1_ATTACK_FIRE      1 /* Caused by Fireball explosions (or Lightning Bolt explosions if created right on the cell of a champion on the party square) and creatures (Black Flame) */
#define C2_ATTACK_SELF      2 /* Caused by the party walking into a wall, falling through a pit or standing in a closing door */
#define C3_ATTACK_BLUNT     3 /* Caused by all non explosion projectiles, Slime explosions and creatures (Demon, Mummy, Ruster, Stone Golem, Swamp Slime / Slime Devil, Trolin / Ant Man, Water Elemental) */
#define C4_ATTACK_SHARP     4 /* Caused by creatures (Animated Armour / Deth Knight, Couatl, Giant Scorpion / Scorpion, Giant Wasp / Muncher, Magenta Worm / Worm, Oitu, Pain Rat / Hellhound, Red Dragon / Dragon, Rockpile / Rock pile, Skeleton) */
#define C5_ATTACK_MAGIC     5 /* Caused by Poison Bolt explosions and creatures (Grey Lord, Lord Chaos, Lord Order, Materializer / Zytaz, Vexirk, Wizard Eye / Flying Eye) */
#define C6_ATTACK_PSYCHIC   6 /* Caused by creatures (Ghost / Rive, Screamer) */
#define C7_ATTACK_LIGHTNING 7 /* Caused by Lightning Bolt explosions */

typedef struct {
        int Type;
        unsigned char ObjectAspectIndex;
        unsigned char ActionSetIndex;
        int AllowedSlots;
} OBJECT_INFO;

/* Object info */
#define C000_OBJECT_INFO_INDEX_FIRST_SCROLL      0
#define C001_OBJECT_INFO_INDEX_FIRST_CONTAINER   1
#define C002_OBJECT_INFO_INDEX_FIRST_POTION      2
#define C023_OBJECT_INFO_INDEX_FIRST_WEAPON     23
#define C069_OBJECT_INFO_INDEX_FIRST_ARMOUR     69
#define C127_OBJECT_INFO_INDEX_FIRST_JUNK      127

/* Object allowed slots */
#define MASK0x0001_MOUTH                        0x0001
#define MASK0x0002_HEAD                         0x0002
#define MASK0x0004_NECK                         0x0004
#define MASK0x0008_TORSO                        0x0008
#define MASK0x0010_LEGS                         0x0010
#define MASK0x0020_FEET                         0x0020
#define MASK0x0040_QUIVER_LINE1                 0x0040
#define MASK0x0080_QUIVER_LINE2                 0x0080
#define MASK0x0100_POUCH_PASS_AND_THROUGH_DOORS 0x0100
#define MASK0x0200_HANDS                        0x0200
#define MASK0x0400_CONTAINER                    0x0400

typedef struct {
        unsigned char Weight;
        unsigned char Class;
        unsigned char Strength;
        unsigned char KineticEnergy;
        unsigned int Attributes; /* Bits 15-13 Unreferenced */
} WEAPON_INFO;

/* Weapon info class */
#define C000_CLASS_SWING_WEAPON         0 /* Class 0: SWING weapons */
#define C002_CLASS_DAGGER_AND_AXES      2 /* Class 1 to 15: THROW weapons */
#define C010_CLASS_BOW_AMMUNITION      10
#define C011_CLASS_SLING_AMMUNITION    11
#define C012_CLASS_POISON_DART         12
#define C016_CLASS_FIRST_BOW           16 /* Class 16 to 111: SHOOT weapons */
#define C031_CLASS_LAST_BOW            31
#define C032_CLASS_FIRST_SLING         32
#define C047_CLASS_LAST_SLING          47
#define C112_CLASS_FIRST_MAGIC_WEAPON 112 /* Class 112 to 255: Magic and special weapons */

/* Weapon attributes */
#define M65_SHOOT_ATTACK(attributes)              ((attributes) & 0x00FF)
#define M66_PROJECTILE_ASPECT_ORDINAL(attributes) (((attributes) >> 8) & 0x001F)

typedef struct {
        unsigned char Weight;
        unsigned char Defense;
        unsigned char Attributes; /* Bits 6-3 Unreferenced. 1 byte of padding inserted by compiler */
} ARMOUR_INFO;

/* Armour Info Attributes */
#define MASK0x0080_IS_A_SHIELD   0x0080
#define MASK0x0007_SHARP_DEFENSE 0x0007

typedef struct {
        long Symbols; /* Most significant byte: 0 (spell definition does not include power symbol) / not 0 (spell definition includes power symbol) */
        unsigned char BaseRequiredSkillLevel;
        unsigned char SkillIndex;
        unsigned int Attributes; /* Bits 15-10: Duration, Bits 9-4: Type, Bits 3-0: Kind */
} SPELL;

/* Spell attributes */
#define M67_SPELL_KIND(spell)     ((spell)->Attributes & 0x000F)
#define M68_SPELL_TYPE(spell)     (((spell)->Attributes >> 4) & 0x003F)
#define M69_SPELL_DURATION(spell) (((spell)->Attributes >> 10) & 0x003F)

/* Spell kinds */
#define C1_SPELL_KIND_POTION     1
#define C2_SPELL_KIND_PROJECTILE 2
#define C3_SPELL_KIND_OTHER      3

/* Spell types */
#define C4_SPELL_TYPE_PROJECTILE_OPEN_DOOR 4
#define C0_SPELL_TYPE_OTHER_LIGHT          0
#define C1_SPELL_TYPE_OTHER_DARKNESS       1
#define C2_SPELL_TYPE_OTHER_THIEVES_EYE    2
#define C3_SPELL_TYPE_OTHER_INVISIBILITY   3
#define C4_SPELL_TYPE_OTHER_PARTY_SHIELD   4
#define C5_SPELL_TYPE_OTHER_MAGIC_TORCH    5
#define C6_SPELL_TYPE_OTHER_FOOTPRINTS     6
#define C7_SPELL_TYPE_OTHER_ZOKATHRA       7
#define C8_SPELL_TYPE_OTHER_FIRESHIELD     8

/* Lines in spell area */
#define C1_SPELL_AREA_CHAMPION_NAME     1
#define C2_SPELL_AREA_AVAILABLE_SYMBOLS 2
#define C3_SPELL_AREA_CHAMPION_SYMBOLS  3

typedef struct {
        unsigned char ActionIndicesAndProperties[6]; /* Indices 0-2: Action indices, Indices 3-5: Action Properties (Bit 7: requires charge, Bit 6-0: minimum skill level) */
        unsigned char Useless; /* BUG0_00 Useless code. Probably a champion skill index, copied into G512_uc_Useless. 1 byte of padding inserted by compiler */
} ACTION_SET;

/* Action set properties */
#define MASK0x0080_ACTION_REQUIRES_CHARGE 0x0080

/* Actions */
#define C000_ACTION_N             0
#define C001_ACTION_BLOCK         1
#define C002_ACTION_CHOP          2
#define C003_ACTION_X             3
#define C004_ACTION_BLOW_HORN     4
#define C005_ACTION_FLIP          5
#define C006_ACTION_PUNCH         6
#define C007_ACTION_KICK          7
#define C008_ACTION_WAR_CRY       8
#define C009_ACTION_STAB          9
#define C010_ACTION_CLIMB_DOWN   10
#define C011_ACTION_FREEZE_LIFE  11
#define C012_ACTION_HIT          12
#define C013_ACTION_SWING        13
#define C014_ACTION_STAB         14
#define C015_ACTION_THRUST       15
#define C016_ACTION_JAB          16
#define C017_ACTION_PARRY        17
#define C018_ACTION_HACK         18
#define C019_ACTION_BERZERK      19
#define C020_ACTION_FIREBALL     20
#define C021_ACTION_DISPELL      21
#define C022_ACTION_CONFUSE      22
#define C023_ACTION_LIGHTNING    23
#define C024_ACTION_DISRUPT      24
#define C025_ACTION_MELEE        25
#define C026_ACTION_X            26
#define C027_ACTION_INVOKE       27
#define C028_ACTION_SLASH        28
#define C029_ACTION_CLEAVE       29
#define C030_ACTION_BASH         30
#define C031_ACTION_STUN         31
#define C032_ACTION_SHOOT        32
#define C033_ACTION_SPELLSHIELD  33
#define C034_ACTION_FIRESHIELD   34
#define C035_ACTION_FLUXCAGE     35
#define C036_ACTION_HEAL         36
#define C037_ACTION_CALM         37
#define C038_ACTION_LIGHT        38
#define C039_ACTION_WINDOW       39
#define C040_ACTION_SPIT         40
#define C041_ACTION_BRANDISH     41
#define C042_ACTION_THROW        42
#define C043_ACTION_FUSE         43
#define C255_ACTION_NONE        255

typedef struct {
        int X;
        int Y;
        int IconIndex;
} SLOT_BOX;

/* Slot boxes */
#define C08_SLOT_BOX_INVENTORY_FIRST_SLOT   8
#define C09_SLOT_BOX_INVENTORY_ACTION_HAND  9
#define C38_SLOT_BOX_CHEST_FIRST_SLOT      38

#define M70_HAND_SLOT_INDEX(slotboxindex) ((slotboxindex) & 0x0001)

/* Object icon indices */
#define CM1_ICON_NONE                                  -1
#define C000_ICON_JUNK_COMPASS_NORTH                    0
#define C003_ICON_JUNK_COMPASS_WEST                     3
#define C004_ICON_WEAPON_TORCH_UNLIT                    4
#define C007_ICON_WEAPON_TORCH_LIT                      7
#define C008_ICON_JUNK_WATER                            8
#define C009_ICON_JUNK_WATERSKIN                        9
#define C010_ICON_JUNK_JEWEL_SYMAL_UNEQUIPPED          10
#define C011_ICON_JUNK_JEWEL_SYMAL_EQUIPPED            11
#define C012_ICON_JUNK_ILLUMULET_UNEQUIPPED            12
#define C013_ICON_JUNK_ILLUMULET_EQUIPPED              13
#define C014_ICON_WEAPON_FLAMITT_EMPTY                 14
#define C016_ICON_WEAPON_EYE_OF_TIME_EMPTY             16
#define C018_ICON_WEAPON_STORMRING_EMPTY               18
#define C020_ICON_WEAPON_STAFF_OF_CLAWS_EMPTY          20
#define C022_ICON_WEAPON_STAFF_OF_CLAWS_FULL           22
#define C023_ICON_WEAPON_BOLT_BLADE_STORM_EMPTY        23
#define C025_ICON_WEAPON_FURY_RA_BLADE_EMPTY           25
#define C027_ICON_WEAPON_THE_FIRESTAFF                 27
#define C028_ICON_WEAPON_THE_FIRESTAFF_COMPLETE        28
#define C030_ICON_SCROLL_SCROLL_OPEN                   30
#define C031_ICON_SCROLL_SCROLL_CLOSED                 31
#define C032_ICON_WEAPON_DAGGER                        32
#define C038_ICON_WEAPON_DELTA_SIDE_SPLITTER           38
#define C039_ICON_WEAPON_DIAMOND_EDGE                  39
#define C040_ICON_WEAPON_VORPAL_BLADE                  40
#define C041_ICON_WEAPON_THE_INQUISITOR_DRAGON_FANG    41
#define C043_ICON_WEAPON_HARDCLEAVE_EXECUTIONER        43
#define C045_ICON_WEAPON_MACE_OF_ORDER                 45
#define C051_ICON_WEAPON_ARROW                         51
#define C052_ICON_WEAPON_SLAYER                        52
#define C054_ICON_WEAPON_ROCK                          54
#define C055_ICON_WEAPON_POISON_DART                   55
#define C056_ICON_WEAPON_THROWING_STAR                 56
#define C058_ICON_WEAPON_STAFF                         58
#define C059_ICON_WEAPON_WAND                          59
#define C060_ICON_WEAPON_TEOWAND                       60
#define C061_ICON_WEAPON_YEW_STAFF                     61
#define C062_ICON_WEAPON_STAFF_OF_MANAR_STAFF_OF_IRRA  62
#define C063_ICON_WEAPON_SNAKE_STAFF_CROSS_OF_NETA     63
#define C064_ICON_WEAPON_THE_CONDUIT_SERPENT_STAFF     64
#define C065_ICON_WEAPON_DRAGON_SPIT                   65
#define C066_ICON_WEAPON_SCEPTRE_OF_LYF                66
#define C081_ICON_ARMOUR_CLOAK_OF_NIGHT                81
#define C104_ICON_ARMOUR_CROWN_OF_NERRA               104
#define C119_ICON_ARMOUR_ELVEN_BOOTS                  119
#define C120_ICON_JUNK_GEM_OF_AGES                    120
#define C121_ICON_JUNK_EKKHARD_CROSS                  121
#define C122_ICON_JUNK_MOONSTONE                      122
#define C124_ICON_JUNK_PENDANT_FERAL                  124
#define C128_ICON_JUNK_BOULDER                        128
#define C137_ICON_JUNK_RABBITS_FOOT                   137
#define C140_ICON_ARMOUR_DEXHELM                      140
#define C141_ICON_ARMOUR_FLAMEBAIN                    141
#define C142_ICON_ARMOUR_POWERTOWERS                  142
#define C144_ICON_CONTAINER_CHEST_CLOSED              144
#define C145_ICON_CONTAINER_CHEST_OPEN                145
#define C147_ICON_JUNK_CHAMPION_BONES                 147
#define C148_ICON_POTION_MA_POTION_MON_POTION         148
#define C163_ICON_POTION_WATER_FLASK                  163
#define C168_ICON_JUNK_APPLE                          168
#define C176_ICON_JUNK_IRON_KEY                       176
#define C191_ICON_JUNK_MASTER_KEY                     191
#define C194_ICON_ARMOUR_BOOT_OF_SPEED                194
#define C195_ICON_POTION_EMPTY_FLASK                  195
#define C201_ICON_ACTION_ICON_EMPTY_HAND              201
#define C202_ICON_EYE_NOT_LOOKING                     202
#define C203_ICON_EYE_LOOKING                         203
#define C204_ICON_EMPTY_BOX                           204
#define C205_ICON_MOUTH_OPEN                          205
#define C208_ICON_NECK                                208
#define C212_ICON_READY_HAND                          212

typedef struct {
        unsigned char Box[4];    /* Part of bitmap to extract */
        unsigned char ByteWidth; /* Source bitmap width in bytes */
        unsigned char Height;    /* Source bitmap height in pixels */
        unsigned char X;         /* Destination X coordinate */
        unsigned char Y;         /* Destination Y coordinate */
} FRAME;

typedef struct {
        FRAME ClosedOrDestroyed;
        FRAME Vertical[3];
        FRAME LeftHorizontal[3];
        FRAME RightHorizontal[3];
} DOOR_FRAMES;

typedef struct {
        unsigned int RGBColor[6];
        unsigned char D2ReplacementColor;
        unsigned char D3ReplacementColor;
} CREATURE_REPLACEMENT_COLOR_SET;

typedef struct {
        unsigned char NativeBitmapRelativeIndex;
        unsigned char BaseStartUnitIndex; /* Index of the unit (16 pixels = 8 bytes) in bitmap where blit will start from. A random value of 0 or 1 is added to this base index */
        unsigned char TransparentColor; /* Bit 7: Do not use mask if set, Bits 6-0: Transparent color index. 0xFF = no transparency */
        unsigned char Mask; /* Bit 7: Flip, Bits 6-0: Mask index. 0xFF = no mask */
        unsigned char ByteWidth;
        unsigned char Height;
        unsigned char X;
        unsigned char Useless; /* BUG0_00 Useless code. Actual data is always 0x40 */
} FIELD_ASPECT;

/* Field Aspect Mask */
#define MASK0x0080_FLIP_MASK  0x0080
#define MASK0x007F_MASK_INDEX 0x007F
#define C255_NO_MASK             255

typedef struct {
        unsigned int FirstNativeBitmapRelativeIndex;
        unsigned int FirstDerivedBitmapIndex;
        unsigned char ByteWidthFront;
        unsigned char HeightFront;
        unsigned char ByteWidthSide;
        unsigned char HeightSide;
        unsigned char ByteWidthAttack;
        unsigned char HeightAttack;
        unsigned char CoordinateSet_TransparentColor;
        unsigned char ReplacementColorSetIndices;
} CREATURE_ASPECT;

#define M71_COORDINATE_SET(creatureaspect)                 (((creatureaspect)->CoordinateSet_TransparentColor >> 4) & 0x000F)
#define M72_TRANSPARENT_COLOR(creatureaspect)              ((creatureaspect)->CoordinateSet_TransparentColor & 0x000F)
#define M73_COLOR_09_REPLACEMENT_COLOR_SET(creatureaspect) ((creatureaspect)->ReplacementColorSetIndices & 0x000F)
#define M74_COLOR_10_REPLACEMENT_COLOR_SET(creatureaspect) (((creatureaspect)->ReplacementColorSetIndices >> 4) & 0x000F)

typedef struct {
        unsigned char FirstNativeBitmapRelativeIndex;
        unsigned char FirstDerivedBitmapRelativeIndex;
        unsigned char ByteWidth;
        unsigned char Height;
        unsigned char GraphicInfo; /* Bits 7-5 and 3-1 Unreferenced */
        unsigned char CoordinateSet;
} OBJECT_ASPECT;

/* Object aspect GraphicInfo */
#define MASK0x0001_FLIP_ON_RIGHT 0x0001
#define MASK0x0010_ALCOVE        0x0010

typedef struct {
        unsigned char FirstNativeBitmapRelativeIndex;
        unsigned char FirstDerivedBitmapRelativeIndex;
        unsigned char ByteWidth;
        unsigned char Height;
        unsigned int GraphicInfo; /* Bits 15-9, 7-5 and 3-2 Unreferenced */
} PROJECTIL_ASPECT;

/* Projectile aspect GraphicInfo */
#define MASK0x0010_SIDE                      0x0010
#define MASK0x0100_SCALE_WITH_KINETIC_ENERGY 0x0100
#define MASK0x0003_ASPECT_TYPE               0x0003

/* Projectile aspect type */
#define C0_PROJECTILE_ASPECT_TYPE_HAS_BACK_GRAPHIC_AND_ROTATION    0
#define C1_PROJECTILE_ASPECT_TYPE_HAS_BACK_GRAPHIC_AND_NO_ROTATION 1
#define C2_PROJECTILE_ASPECT_TYPE_NO_BACK_GRAPHIC_AND_ROTATION     2
#define C3_PROJECTILE_ASPECT_TYPE_NO_BACK_GRAPHIC_AND_NO_ROTATION  3

/* Projectile aspects */
#define C03_PROJECTILE_ASPECT_EXPLOSION_LIGHTNING_BOLT            3
#define C10_PROJECTILE_ASPECT_EXPLOSION_FIREBALL                 10
#define C11_PROJECTILE_ASPECT_EXPLOSION_DEFAULT                  11
#define C12_PROJECTILE_ASPECT_EXPLOSION_SLIME                    12
#define C13_PROJECTILE_ASPECT_EXPLOSION_POISON_BOLT_POISON_CLOUD 13

typedef struct {
        unsigned char ByteWidth;
        unsigned char Height;
} EXPLOSION_ASPECT;

/* Explosion aspects */
#define C0_EXPLOSION_ASPECT_FIRE   0
#define C1_EXPLOSION_ASPECT_SPELL  1
#define C2_EXPLOSION_ASPECT_POISON 2
#define C3_EXPLOSION_ASPECT_SMOKE  3

/* Colors */
#define CM1_COLOR_NO_TRANSPARENCY -1
#define C00_COLOR_BLACK            0
#define C01_COLOR_DARK_GRAY        1
#define C02_COLOR_LIGHT_GRAY       2
#define C03_COLOR_DARK_BROWN       3
#define C04_COLOR_CYAN             4
#define C05_COLOR_LIGHT_BROWN      5
#define C06_COLOR_DARK_GREEN       6
#define C07_COLOR_LIGHT_GREEN      7
#define C08_COLOR_RED              8
#define C09_COLOR_GOLD             9
#define C10_COLOR_FLESH           10
#define C11_COLOR_YELLOW          11
#define C12_COLOR_DARKEST_GRAY    12
#define C13_COLOR_LIGHTEST_GRAY   13
#define C14_COLOR_BLUE            14
#define C15_COLOR_WHITE           15

#define C0x0000_RGB_BLACK         0x0000
#define C0x0002_RGB_DARK_BLUE     0x0002
#define C0x0421_RGB_LIGHT_BROWN   0x0421
#define C0x0437_RGB_PINK          0x0437
#define C0x0531_RGB_LIGHTER_BROWN 0x0531
#define C0x0541_RGB_DARK_GOLD     0x0541
#define C0x0651_RGB_GOLD          0x0651
#define C0x0700_RGB_RED           0x0700
#define C0x0772_RGB_YELLOW        0x0772
#define C0x0777_RGB_WHITE         0x0777

#define MASK0x0700_RED_COMPONENT   0x0700
#define MASK0x0070_GREEN_COMPONENT 0x0070
#define MASK0x0007_BLUE_COMPONENT  0x0007

#define C69_CHAMPION_STATUS_BOX_SPACING 69

#define M75_BITMAP_BYTE_COUNT(width, height) ((width / 2) * height) /* Division of width must occur before multiplication by height otherwise the result is wrong for large bitmaps like 320 x 200 */
#define M76_BITMAP_UNIT_COUNT(width, height) (((width / 2) * height) / 8) /* A unit is 16 pixels = 8 bytes */
#define M77_NORMALIZED_BYTE_WIDTH(width)     (((width) + 7) & 0xFFF8) /* Ensure bitmap width is a multiple of 16 pixels = 8 bytes = 1 unit */

/* Graphic and native bitmap indices */
#define C000_GRAPHIC_DIALOG_BOX                         0
#define C001_GRAPHIC_TITLE                              1
#define C002_GRAPHIC_ENTRANCE_LEFT_DOOR                 2
#define C003_GRAPHIC_ENTRANCE_RIGHT_DOOR                3
#define C004_GRAPHIC_ENTRANCE                           4
#define C005_GRAPHIC_CREDITS                            5
#define C006_GRAPHIC_THE_END                            6
#define C007_GRAPHIC_STATUS_BOX                         7 /* This graphic is never used */
#define C008_GRAPHIC_STATUS_BOX_DEAD_CHAMPION           8
#define C009_GRAPHIC_MENU_SPELL_AREA_BACKGROUND         9 /* This graphic is drawn as the background of the spell area controls. The top line is always overwritten by the spell area controls. However the arrows in the top right corner can be seen very briefly when the spell area is drawn, for example when unfreezing the game: quickly press the 'Escape' key many times to try and see them. The full image can be seen on the screenshots on the back of the early box of Dungeon Master for Atari ST that show an early design of the game */
#define C010_GRAPHIC_MENU_ACTION_AREA                  10
#define C011_GRAPHIC_MENU_SPELL_AREA_LINES             11 /* The first line in this graphic is never drawn on screen. The second and third lines are used to draw symbols over the background in graphic #9 */
#define C012_GRAPHIC_FONT                              12 /* This graphic is never used */
#define C013_GRAPHIC_MOVEMENT_ARROWS                   13
#define C014_GRAPHIC_DAMAGE_TO_CREATURE                14
#define C015_GRAPHIC_DAMAGE_TO_CHAMPION_SMALL          15
#define C016_GRAPHIC_DAMAGE_TO_CHAMPION_BIG            16
#define C017_GRAPHIC_INVENTORY                         17
#define C018_GRAPHIC_ARROW_FOR_CHEST_CONTENT           18
#define C019_GRAPHIC_EYE_FOR_OBJECT_DESCRIPTION        19
#define C020_GRAPHIC_PANEL_EMPTY                       20
#define C021_GRAPHIC_CHECK_FUZZY_BITS_SECTOR_7         21
#define C022_GRAPHIC_EMPTY                             22 /* Empty graphic */
#define C023_GRAPHIC_PANEL_OPEN_SCROLL                 23
#define C024_GRAPHIC_EMPTY                             24 /* Empty graphic */
#define C025_GRAPHIC_PANEL_OPEN_CHEST                  25
#define C026_GRAPHIC_CHAMPION_PORTRAITS                26
#define C027_GRAPHIC_PANEL_RENAME_CHAMPION             27
#define C028_GRAPHIC_CHAMPION_ICONS                    28
#define C029_GRAPHIC_OBJECT_DESCRIPTION_CIRCLE         29
#define C030_GRAPHIC_FOOD_LABEL                        30
#define C031_GRAPHIC_WATER_LABEL                       31
#define C032_GRAPHIC_POISONED_LABEL                    32
#define C033_GRAPHIC_SLOT_BOX_NORMAL                   33
#define C034_GRAPHIC_SLOT_BOX_WOUNDED                  34
#define C035_GRAPHIC_SLOT_BOX_ACTING_HAND              35
#define C036_GRAPHIC_SLOT_BOX_UNKNOWN                  36 /* This graphic is never used */
#define C037_GRAPHIC_BORDER_PARTY_SHIELD               37
#define C038_GRAPHIC_BORDER_PARTY_FIRESHIELD           38
#define C039_GRAPHIC_BORDER_PARTY_SPELLSHIELD          39
#define C040_GRAPHIC_PANEL_RESURRECT_REINCARNATE       40
#define C041_GRAPHIC_HOLE_IN_WALL                      41
#define C042_GRAPHIC_OBJECT_ICONS_000_TO_031           42
#define C043_GRAPHIC_OBJECT_ICONS_032_TO_063           43
#define C044_GRAPHIC_OBJECT_ICONS_064_TO_095           44
#define C045_GRAPHIC_OBJECT_ICONS_096_TO_127           45
#define C046_GRAPHIC_OBJECT_ICONS_128_TO_159           46
#define C047_GRAPHIC_OBJECT_ICONS_160_TO_191           47
#define C048_GRAPHIC_OBJECT_ICONS_192_TO_223           48
#define C049_GRAPHIC_FLOOR_PIT_D3L                     49
#define C050_GRAPHIC_FLOOR_PIT_D3C                     50
#define C051_GRAPHIC_FLOOR_PIT_D2L                     51
#define C052_GRAPHIC_FLOOR_PIT_D2C                     52
#define C053_GRAPHIC_FLOOR_PIT_D1L                     53
#define C054_GRAPHIC_FLOOR_PIT_D1C                     54
#define C055_GRAPHIC_FLOOR_PIT_D0L                     55
#define C056_GRAPHIC_FLOOR_PIT_D0C                     56
#define C057_GRAPHIC_FLOOR_PIT_INVISIBLE_D2L           57
#define C058_GRAPHIC_FLOOR_PIT_INVISIBLE_D2C           58
#define C059_GRAPHIC_FLOOR_PIT_INVISIBLE_D1L           59
#define C060_GRAPHIC_FLOOR_PIT_INVISIBLE_D1C           60
#define C061_GRAPHIC_FLOOR_PIT_INVISIBLE_D0L           61
#define C062_GRAPHIC_FLOOR_PIT_INVISIBLE_D0C           62
#define C063_GRAPHIC_CEILING_PIT_D2L                   63
#define C064_GRAPHIC_CEILING_PIT_D2C                   64
#define C065_GRAPHIC_CEILING_PIT_D1L                   65
#define C066_GRAPHIC_CEILING_PIT_D1C                   66
#define C067_GRAPHIC_CEILING_PIT_D0L                   67
#define C068_GRAPHIC_CEILING_PIT_D0C                   68
#define C069_GRAPHIC_FIRST_FIELD_MASK                  69
#define C073_GRAPHIC_FIRST_FIELD                       73
#define C075_GRAPHIC_FIRST_FLOOR_SET                   75
#define C077_GRAPHIC_FIRST_WALL_SET                    77
#define C090_GRAPHIC_FIRST_STAIRS                      90
#define C108_GRAPHIC_FIRST_DOOR_SET                   108
#define C120_GRAPHIC_INSCRIPTION_FONT                 120
#define C121_GRAPHIC_FIRST_WALL_ORNAMENT              121
#define C208_GRAPHIC_WALL_ORNAMENT_43_CHAMPION_MIRROR 208
#define C241_GRAPHIC_FLOOR_ORNAMENT_15_FOOTPRINTS     241
#define C247_GRAPHIC_FIRST_FLOOR_ORNAMENT             247
#define C301_GRAPHIC_FIRST_DOOR_MASK                  301
#define C303_GRAPHIC_FIRST_DOOR_ORNAMENT              303
#define C315_GRAPHIC_FIRST_DOOR_BUTTON                315
#define C316_GRAPHIC_FIRST_PROJECTILE                 316
#define C348_GRAPHIC_FIRST_EXPLOSION                  348
#define C351_GRAPHIC_FIRST_EXPLOSION_PATTERN          351
#define C360_GRAPHIC_FIRST_OBJECT                     360
#define C446_GRAPHIC_FIRST_CREATURE                   446
#define C533_GRAPHIC_FIRST_SOUND                      533
#define C534_GRAPHIC_SOUND_DOOR_RATTLE                534
#define C535_GRAPHIC_SOUND_SWITCH                     535
#define C538_GRAPHIC_READ_SECTOR_7                    538
#define C549_GRAPHIC_FIRST_CREATURE_ATTACK_SOUND      549
#define C556_GRAPHIC_OBJECT_NAMES                     556
#define C557_GRAPHIC_FONT                             557
#define C558_GRAPHIC_GLOBAL_VARIABLES                 558
#define C559_GRAPHIC_GLOBAL_VARIABLES                 559
#define C560_GRAPHIC_GLOBAL_VARIABLES                 560
#define C561_GRAPHIC_GLOBAL_VARIABLES                 561
#define C562_GRAPHIC_GLOBAL_VARIABLES                 562

/* Derived bitmap indices */
#define C000_DERIVED_BITMAP_VIEWPORT                    0 /* Used while drawing fields (graphics #73 to #74) and explosion patterns  (graphics #351 to #359) over the viewport (224x136 pixels) */
#define C001_DERIVED_BITMAP_THIEVES_EYE_VISIBLE_AREA    1 /* Used to store the visible area behind hole in wall or door (96x95 pixels) */
#define C002_DERIVED_BITMAP_DAMAGE_TO_CREATURE_MEDIUM   2 /* Used for scaled down graphic #14 to 64x37 pixels */
#define C003_DERIVED_BITMAP_DAMAGE_TO_CREATURE_SMALL    3 /* Used for scaled down graphic #14 to 42x37 pixels */
#define C004_DERIVED_BITMAP_FIRST_WALL_ORNAMENT         4 /* 64 bitmaps: 4 bitmaps (two bitmaps per wall ornament, scaled 16/32 for D3 and 20/32 for D2) for each of the 16 possible wall ornaments per map (including inscription) in G101_aai_CurrentMapWallOrnamentsInfo. */
#define C068_DERIVED_BITMAP_FIRST_DOOR_ORNAMENT_D3     68 /* 34 bitmaps: 2 bitmaps (scaled 16/32 for D3 and 20/32 for D2) for each of the 17 possible door ornaments per map (including masks for destroyed / thieves eye) in G103_aai_CurrentMapDoorOrnamentsInfo */
#define C069_DERIVED_BITMAP_FIRST_DOOR_ORNAMENT_D2     69
#define C102_DERIVED_BITMAP_FIRST_DOOR_BUTTON         102 /* 2 bitmaps (scaled 16/32 for D3 and 20/32 for D2) for the door button */
#define C104_DERIVED_BITMAP_FIRST_OBJECT              104 /* 178 bitmaps: 2 bitmaps (scaled 16/32 for D3 and 20/32 for D2) for each object bitmap, including alcove bitmaps (for the chest) and mirrored bitmaps (for the chest and the green and blue magical boxes) */
#define C282_DERIVED_BITMAP_FIRST_PROJECTILE          282 /* 156 bitmaps: 6 bitmaps (one for each scale in G215_auc_Graphic558_ProjectileScales) for each projectile bitmap except for magic projectiles which are scaled according to their actual power (graphics #316 to 324 and #327 to 343) */
#define C438_DERIVED_BITMAP_FIRST_EXPLOSION           438 /* 3 x 14 bitmaps for Fire, Spell and Poison explosions at scales 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30 plus 1 x 15 bitmaps for Smoke explosion at same scale values + 32 */
#define C495_DERIVED_BITMAP_FIRST_CREATURE            495 /* 217 bitmaps. 711 is the last derived bitmap index of the last creature. Derived bitmaps 712-729 are unused */

/* Counts */
#define C002_FLOOR_SET_GRAPHIC_COUNT        2
#define C013_WALL_SET_GRAPHIC_COUNT        13
#define C018_STAIRS_GRAPHIC_COUNT          18
#define C003_DOOR_SET_GRAPHIC_COUNT         3
#define C001_DOOR_BUTTON_COUNT              1
#define C001_FOUNTAIN_ORNAMENT_COUNT        1
#define C003_ALCOVE_ORNAMENT_COUNT          3
#define C027_CREATURE_TYPE_COUNT           27
#define C070_MANDATORY_GRAPHIC_COUNT       70
#define C550_LOADABLE_GRAPHIC_COUNT_DM    550
#define C563_GRAPHIC_COUNT                563
#define C712_DERIVED_BITMAP_ACTUAL_COUNT  712
#define C730_DERIVED_BITMAP_MAXIMUM_COUNT 730
#define C004_EXPLOSION_ASPECT_COUNT         4
#define C014_PROJECTILE_ASPECT_COUNT       14
#define C085_OBJECT_ASPECT_COUNT           85

/* For G088_apuc_Bitmap_WallSet */
#define C00_WALL_BITMAP_DOOR_FRAME_RIGHT_D1C  0
#define C01_WALL_BITMAP_DOOR_FRAME_FRONT      1
#define C02_WALL_BITMAP_DOOR_FRAME_LEFT_D1C   2
#define C03_WALL_BITMAP_DOOR_FRAME_LEFT_D2C   3
#define C04_WALL_BITMAP_DOOR_FRAME_LEFT_D3C   4
#define C05_WALL_BITMAP_DOOR_FRAME_LEFT_D3L   5
#define C06_WALL_BITMAP_DOOR_FRAME_TOP_D1LCR  6
#define C07_WALL_BITMAP_DOOR_FRAME_TOP_D2LCR  7
#define C08_WALL_BITMAP_WALL_D0R              8
#define C09_WALL_BITMAP_WALL_D0L              9
#define C10_WALL_BITMAP_WALL_D1LCR           10
#define C11_WALL_BITMAP_WALL_D2LCR           11
#define C12_WALL_BITMAP_WALL_D3LCR           12
#define C13_WALL_BITMAP_WALL_D3L2            13
#define C14_WALL_BITMAP_WALL_D3R2            14

/* For G079_ai_StairsNativeBitmapIndices */
#define C00_STAIRS_BITMAP_SIDE_D0L             0
#define C01_STAIRS_BITMAP_DOWN_SIDE_D1L        1
#define C02_STAIRS_BITMAP_UP_SIDE_D1L          2
#define C03_STAIRS_BITMAP_SIDE_D2L             3
#define C04_STAIRS_BITMAP_DOWN_FRONT_D0C_LEFT  4
#define C05_STAIRS_BITMAP_DOWN_FRONT_D1C       5
#define C06_STAIRS_BITMAP_DOWN_FRONT_D1L       6
#define C07_STAIRS_BITMAP_DOWN_FRONT_D2C       7
#define C08_STAIRS_BITMAP_DOWN_FRONT_D2L       8
#define C09_STAIRS_BITMAP_DOWN_FRONT_D3C       9
#define C10_STAIRS_BITMAP_DOWN_FRONT_D3L      10
#define C11_STAIRS_BITMAP_UP_FRONT_D0C_LEFT   11
#define C12_STAIRS_BITMAP_UP_FRONT_D1C        12
#define C13_STAIRS_BITMAP_UP_FRONT_D1L        13
#define C14_STAIRS_BITMAP_UP_FRONT_D2C        14
#define C15_STAIRS_BITMAP_UP_FRONT_D2L        15
#define C16_STAIRS_BITMAP_UP_FRONT_D3C        16
#define C17_STAIRS_BITMAP_UP_FRONT_D3L        17

/* For G080_aai_DoorNativeBitmapIndices */
#define C0_DOOR_BITMAP_FRONT_D1LCR 0
#define C1_DOOR_BITMAP_FRONT_D2LCR 1
#define C2_DOOR_BITMAP_FRONT_D3LCR 2

/* Graphic relative indices */
#define C0_FLOOR_SET_STONE                  0
#define C0_WALL_SET_STONE                   0
#define C0_DOOR_BUTTON                      0
#define C0_WALL_ORNAMENT_INSCRIPTION        0
#define C15_FLOOR_ORNAMENT_FOOTPRINTS      15
#define C15_DOOR_ORNAMENT_DESTROYED_MASK   15
#define C16_DOOR_ORNAMENT_THIEVES_EYE_MASK 16

/* Width in bytes */
#define C008_BYTE_WIDTH            8
#define C016_BYTE_WIDTH           16
#define C024_BYTE_WIDTH           24
#define C032_BYTE_WIDTH           32
#define C040_BYTE_WIDTH           40
#define C048_BYTE_WIDTH           48
#define C064_BYTE_WIDTH           64
#define C072_BYTE_WIDTH           72
#define C112_BYTE_WIDTH_VIEWPORT 112
#define C128_BYTE_WIDTH          128
#define C144_BYTE_WIDTH          144
#define C160_BYTE_WIDTH_SCREEN   160

/* Scales */
#define C16_SCALE_D3 16
#define C20_SCALE_D2 20
#define M78_SCALED_DIMENSION(dimension, scale) (((dimension * scale) + (scale >> 1)) >> 5)

/* Array indices */
#define C0_X             0
#define C1_Y             1
#define C2_SCALE         2
#define C0_X1            0
#define C1_X2            1
#define C2_Y1            2
#define C3_Y2            3
#define C4_BYTE_WIDTH    4
#define C4_SCALE         4
#define C5_HEIGHT        5
#define C0_X_SHIFT_INDEX 0
#define C1_Y_SHIFT_INDEX 1

/* Square aspect */
#define C0_ELEMENT                     0
#define C1_FIRST_GROUP_OR_OBJECT       1
#define C2_RIGHT_WALL_ORNAMENT_ORDINAL 2
#define C3_FRONT_WALL_ORNAMENT_ORDINAL 3
#define C4_LEFT_WALL_ORNAMENT_ORDINAL  4
#define C2_PIT_INVISIBLE               2
#define C2_TELEPORTER_VISIBLE          2
#define C2_STAIRS_UP                   2
#define C2_DOOR_STATE                  2
#define C3_DOOR_THING_INDEX            3
#define C4_FLOOR_ORNAMENT_ORDINAL      4
#define MASK0x8000_FOOTPRINTS          0x8000

/* Viewport */
#define C0_VIEWPORT_NOT_DUNGEON_VIEW               0
#define C1_VIEWPORT_DUNGEON_VIEW                   1
#define C2_VIEWPORT_AS_BEFORE_SLEEP_OR_FREEZE_GAME 2

/* View lanes */
#define C0_VIEW_LANE_CENTER 0
#define C1_VIEW_LANE_LEFT   1
#define C2_VIEW_LANE_RIGHT  2

/* View squares */
#define CM3_VIEW_SQUARE_D4C           -3
#define CM2_VIEW_SQUARE_D4L           -2
#define CM1_VIEW_SQUARE_D4R           -1
#define C00_VIEW_SQUARE_D3C            0
#define C01_VIEW_SQUARE_D3L            1
#define C02_VIEW_SQUARE_D3R            2
#define C03_VIEW_SQUARE_D2C            3
#define C04_VIEW_SQUARE_D2L            4
#define C05_VIEW_SQUARE_D2R            5
#define C06_VIEW_SQUARE_D1C            6
#define C07_VIEW_SQUARE_D1L            7
#define C08_VIEW_SQUARE_D1R            8
#define C09_VIEW_SQUARE_D0C            9
#define C10_VIEW_SQUARE_D0L           10
#define C11_VIEW_SQUARE_D0R           11
#define C12_VIEW_SQUARE_D3R2          12
#define C13_VIEW_SQUARE_D3L2          13
#define C03_VIEW_SQUARE_D3C_EXPLOSION  3
#define C04_VIEW_SQUARE_D3L_EXPLOSION  4
#define C09_VIEW_SQUARE_D1C_EXPLOSION  9
#define C12_VIEW_SQUARE_D0C_EXPLOSION 12
/* Visible square names and values (the party stands at D0C)
        +-------+-------+-------+
        |  D4L  |  D4C  |  D4R  |
        |       |       |       |
        |  -2   |  -3   |  -1   |
+-------+-------+-------+-------+-------+
|  D3L2 |  D3L  |  D3C  |  D3R  | D3L2  |
|       |       |       |       |       |
|   13  |   1   |   0   |   2   |  12   |
+-------+-------+-------+-------+-------+
        |  D2L  |  D2C  |  D2R  |
        |       |       |       |
        |   4   |   3   |   5   |
        +-------+-------+-------+
        |  D1L  |  D1C  |  D1R  |
        |       |       |       |
        |   7   |   6   |   8   |
        +-------+-------+-------+
        |  D0L  |  D0C  |  D0R  |
        |       |       |       |
        |   10  |   9   |  11   |
        +-------+-------+-------+
*/

/* View cells */
#define C00_VIEW_CELL_FRONT_LEFT                   0
#define C01_VIEW_CELL_FRONT_RIGHT                  1
#define C02_VIEW_CELL_BACK_RIGHT                   2
#define C03_VIEW_CELL_BACK_LEFT                    3
#define C04_VIEW_CELL_ALCOVE                       4
#define C05_VIEW_CELL_DOOR_BUTTON_OR_WALL_ORNAMENT 5

/* View cells for half square sized creatures */
#define C00_VIEW_CELL_LEFT_COLUMN   0
#define C01_VIEW_CELL_RIGHT_COLUMN  1
#define C02_VIEW_CELL_BACK_ROW      2
#define C03_VIEW_CELL_CENTER_COLUMN 3
#define C04_VIEW_CELL_FRONT_ROW     4

/* View cell orders */
#define MASK0x0008_DOOR_FRONT                                    0x0008
#define C0000_CELL_ORDER_ALCOVE                                  0x0000
#define C0001_CELL_ORDER_BACKLEFT                                0x0001
#define C0002_CELL_ORDER_BACKRIGHT                               0x0002
#define C0018_CELL_ORDER_DOORPASS1_BACKLEFT                      0x0018
#define C0021_CELL_ORDER_BACKLEFT_BACKRIGHT                      0x0021
#define C0028_CELL_ORDER_DOORPASS1_BACKRIGHT                     0x0028
#define C0032_CELL_ORDER_BACKRIGHT_FRONTRIGHT                    0x0032
#define C0039_CELL_ORDER_DOORPASS2_FRONTRIGHT                    0x0039
#define C0041_CELL_ORDER_BACKLEFT_FRONTLEFT                      0x0041
#define C0049_CELL_ORDER_DOORPASS2_FRONTLEFT                     0x0049
#define C0128_CELL_ORDER_DOORPASS1_BACKRIGHT_BACKLEFT            0x0128
#define C0218_CELL_ORDER_DOORPASS1_BACKLEFT_BACKRIGHT            0x0218
#define C0321_CELL_ORDER_BACKLEFT_BACKRIGHT_FRONTRIGHT           0x0321
#define C0342_CELL_ORDER_BACKRIGHT_FRONTLEFT_FRONTRIGHT          0x0342
#define C0349_CELL_ORDER_DOORPASS2_FRONTLEFT_FRONTRIGHT          0x0349
#define C0412_CELL_ORDER_BACKRIGHT_BACKLEFT_FRONTLEFT            0x0412
#define C0431_CELL_ORDER_BACKLEFT_FRONTRIGHT_FRONTLEFT           0x0431
#define C0439_CELL_ORDER_DOORPASS2_FRONTRIGHT_FRONTLEFT          0x0439
#define C3421_CELL_ORDER_BACKLEFT_BACKRIGHT_FRONTLEFT_FRONTRIGHT 0x3421
#define C4312_CELL_ORDER_BACKRIGHT_BACKLEFT_FRONTRIGHT_FRONTLEFT 0x4312

/* View walls */
#define C00_VIEW_WALL_D3L_RIGHT  0
#define C01_VIEW_WALL_D3R_LEFT   1
#define C02_VIEW_WALL_D3L_FRONT  2
#define C03_VIEW_WALL_D3C_FRONT  3
#define C04_VIEW_WALL_D3R_FRONT  4
#define C05_VIEW_WALL_D2L_RIGHT  5
#define C06_VIEW_WALL_D2R_LEFT   6
#define C07_VIEW_WALL_D2L_FRONT  7
#define C08_VIEW_WALL_D2C_FRONT  8
#define C09_VIEW_WALL_D2R_FRONT  9
#define C10_VIEW_WALL_D1L_RIGHT 10
#define C11_VIEW_WALL_D1R_LEFT  11
#define C12_VIEW_WALL_D1C_FRONT 12
/* Walls where ornaments are visible (the party stands at D0C)
        +-------+-------+-------+         
        |       |       |       |         
        |       |       |       |         
        |       |       |       |         
+-------+-------+-------+-------+-------+ 
|       |  D3L  |  D3C  |  D3R  |       | 
|       |     0 |       | 1     |       |  
|       |   2   |   3   |   4   |       |  
+-------+-------+-------+-------+-------+ 
        |  D2L  |  D2C  |  D2R  |         
        |     5 |       | 6     |          
        |   7   |   8   |   9   |          
        +-------+-------+-------+         
        |  D1L  |  D1C  |  D1R  |         
        |    10 |       | 11    |          
        |       |  12   |       |          
        +-------+-------+-------+         
        |       |  D0C  |       |         
        |       |       |       |         
        |       |       |       |         
        +-------+-------+-------+         
*/

/* View floors */
#define C0_VIEW_FLOOR_D3L 0
#define C1_VIEW_FLOOR_D3C 1
#define C2_VIEW_FLOOR_D3R 2
#define C3_VIEW_FLOOR_D2L 3
#define C4_VIEW_FLOOR_D2C 4
#define C5_VIEW_FLOOR_D2R 5
#define C6_VIEW_FLOOR_D1L 6
#define C7_VIEW_FLOOR_D1C 7
#define C8_VIEW_FLOOR_D1R 8
/* Floors where ornaments are visible (the party stands at D0C)
        +-------+-------+-------+
        |       |       |       |
        |       |       |       |
        |       |       |       |
+-------+-------+-------+-------+-------+
|       |  D3L  |  D3C  |  D3R  |       |
|       |       |       |       |       |
|       |   0   |   1   |   2   |       |
+-------+-------+-------+-------+-------+
        |  D2L  |  D2C  |  D2R  |
        |       |       |       |
        |   3   |   4   |   5   |
        +-------+-------+-------+
        |  D1L  |  D1C  |  D1R  |
        |       |       |       |
        |   6   |   7   |   8   |
        +-------+-------+-------+
        |       |  D0C  |       |
        |       |       |       |
        |       |       |       |
        +-------+-------+-------+
*/

/* View door ornaments */
#define C0_VIEW_DOOR_ORNAMENT_D3LCR 0
#define C1_VIEW_DOOR_ORNAMENT_D2LCR 1
#define C2_VIEW_DOOR_ORNAMENT_D1LCR 2

/* View door buttons */
#define C0_VIEW_DOOR_BUTTON_D3R 0
#define C1_VIEW_DOOR_BUTTON_D3C 1
#define C2_VIEW_DOOR_BUTTON_D2C 2
#define C3_VIEW_DOOR_BUTTON_D1C 3

/* Shift sets */
#define C0_SHIFT_SET_D0_BACK_OR_D1_FRONT 0
#define C1_SHIFT_SET_D1_BACK_OR_D2_FRONT 1
#define C2_SHIFT_SET_D2_BACK_OR_D3_FRONT 2

/* For G103_aai_CurrentMapDoorOrnamentsInfo */
#define C0_NATIVE_BITMAP_INDEX 0
#define C1_COORDINATE_SET      1

/* Memory allocation */
#define C0_ALLOCATION_TEMPORARY_ON_TOP_OF_HEAP    0
#define C1_ALLOCATION_PERMANENT                   1
#define C2_ALLOCATION_TEMPORARY_ON_BOTTOM_OF_HEAP 2

/* Blocks for bitmaps */
#define M79_PREVIOUS_BLOCK_SIZE(block)           (*((long*)((block) - 4)))
#define M80_BLOCK_SIZE(block)                    (*((long*)(block)))
#define M81_USED_BLOCK_USAGE_COUNT(block)        (*((int*)((block) + 4)))
#define M82_USED_BLOCK_PREVIOUS_INDEX(block)     (*((int*)((block) + 6)))
#define M83_USED_BLOCK_NEXT_INDEX(block)         (*((int*)((block) + 8)))
#define M84_USED_BLOCK_BITMAP_INDEX(block)       (*((int*)((block) + 10)))
#define M85_USED_BLOCK_BITMAP(block)             ((block) + 12)
#define M86_UNUSED_BLOCK_PREVIOUS_ADDRESS(block) (*((unsigned char**)((block) + 4)))
#define M87_UNUSED_BLOCK_NEXT_ADDRESS(block)     (*((unsigned char**)((block) + 8)))

/* Graphic buffers */
#define M88_GRAPHIC_BYTE_WIDTH(graphic)          (*((int*)(graphic)) >> 1)
#define M89_GRAPHIC_HEIGHT(graphic)              (*((int*)((graphic) + 2)))
#define M90_GRAPHIC_INDEX_OR_SIZE(graphic)       (*((int*)(graphic)))

/* Text types */
#define C0_TEXT_TYPE_INSCRIPTION 0 /* Used for text on walls */
#define C1_TEXT_TYPE_MESSAGE     1 /* Used for messages displayed when the party walks on a square */
#define C2_TEXT_TYPE_SCROLL      2 /* Used for text on scrolls and champion information */
#define MASK0x8000_DECODE_EVEN_IF_INVISIBLE 0x8000

/* Outcomes */
#define C0_OUTCOME_KILLED_NO_CREATURES_IN_GROUP   0
#define C1_OUTCOME_KILLED_SOME_CREATURES_IN_GROUP 1
#define C2_OUTCOME_KILLED_ALL_CREATURES_IN_GROUP  2

/* Dialogs */
#define C0_DIALOG_SET_VIEWPORT 0
#define C1_DIALOG_SET_SCREEN   1
#define C1_ONE_CHOICE          1
#define C2_TWO_CHOICES         2
#define C4_FOUR_CHOICES        4

/* For F031_aAA2_OBJECT_LoadNames and G352_apc_ObjectNames */
#define C007_CHAMPION_NAME_MAXIMUM_LENGTH   7
#define C012_ACTION_NAME_MAXIMUM_LENGTH    12
#define C014_OBJECT_NAME_MAXIMUM_LENGTH    14
#define C199_OBJECT_NAME_COUNT            199

/* For F067_aaat_MOUSE_SetPointerToNormal */
#define C0_POINTER_ARROW 0
#define C1_POINTER_HAND  1

/* For F106_rzzz_DUNGEONVIEW_TestResetToStep1_COPYPROTECTIONF and F408_xxxx_MENUS_GetClickOnSpellCastResult and F424_xxxx_DIALOG_GetChoice */
#define C0_USELESS 0
#define C1_USELESS 1
#define C2_USELESS 2

/* For F133_xxxx_VIDEO_BlitBoxFilledWithMaskedBitmap */
#define MASK0x0080_DO_NOT_USE_MASK 0x0080

/* For F136_nzzz_VIDEO_ShadeScreenBox */
#define MASK0x8000_SHADE 0x8000

/* For F163_amzz_DUNGEON_LinkThingToList and F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE */
#define CM1_MAPX_NOT_ON_A_SQUARE              -1
#define CM2_MAPX_PROJECTILE_ASSOCIATED_OBJECT -2

/* For F166_szzz_DUNGEON_GetUnusedThing */
#define MASK0x8000_CHAMPION_BONES 0x8000
#define MASK0x7FFF_THING_TYPE     0x7FFF

/* For F179_xxxx_GROUP_GetCreatureAspectUpdateTime and F200_xxxx_GROUP_GetDistanceToVisibleParty */
#define CM1_WHOLE_CREATURE_GROUP -1

/* For F186_xxxx_GROUP_DropCreatureFixedPossessions */
#define MASK0x8000_RANDOM_DROP 0x8000

/* For F231_izzz_GROUP_GetMeleeActionDamage */
#define MASK0x8000_HIT_NON_MATERIAL_CREATURES 0x8000

/* For F281_xxxx_CHAMPION_Rename */
#define C1_RENAME_CHAMPION_NAME  1
#define C2_RENAME_CHAMPION_TITLE 2

/* For F303_AA09_CHAMPION_GetSkillLevel */
#define MASK0x4000_IGNORE_OBJECT_MODIFIERS     0x4000
#define MASK0x8000_IGNORE_TEMPORARY_EXPERIENCE 0x8000

/* For F313_xxxx_CHAMPION_GetWoundDefense */
#define MASK0x0000_DO_NOT_USE_SHARP_DEFENSE 0x0000
#define MASK0x8000_USE_SHARP_DEFENSE        0x8000

/* For F317_adzz_CHAMPION_AddScentStrength */
#define MASK0x8000_MERGE_CYCLES 0x8000

/* For F328_nzzz_CHAMPION_IsObjectThrown and F329_hzzz_CHAMPION_IsLeaderHandObjectThrown */
#define C0_SIDE_LEFT  0
#define C1_SIDE_RIGHT 1

/* For F342_xxxx_INVENTORY_DrawPanel_Object (Object description masks) */
#define MASK0x0001_DESCRIPTION_CONSUMABLE 0x0001
#define MASK0x0002_DESCRIPTION_POISONED   0x0002
#define MASK0x0004_DESCRIPTION_BROKEN     0x0004
#define MASK0x0008_DESCRIPTION_CURSED     0x0008

/* For F385_xxxx_MENUS_DrawActionDamage */
#define CM1_DAMAGE_CANT_REACH    -1
#define CM2_DAMAGE_NO_AMMUNITION -2

/* For F410_xxxx_MENUS_PrintSpellFailureMessage */
#define C00_FAILURE_NEEDS_MORE_PRACTICE  0
#define C01_FAILURE_MEANINGLESS_SPELL    1
#define C10_FAILURE_NEEDS_FLASK_IN_HAND 10

/* For F412_xxxx_MENUS_GetChampionSpellCastResult */
#define C0_SPELL_CAST_FAILURE             0
#define C1_SPELL_CAST_SUCCESS             1
#define C3_SPELL_CAST_FAILURE_NEEDS_FLASK 3

/* For F414_xxxx_SAVEUTIL_ReplaceTildeByDriveLetterInString */
#define C0_DRIVE_TYPE_NONE      0
#define C1_DRIVE_TYPE_GAME_DISK 1
#define C2_DRIVE_TYPE_SAVE_DISK 2

/* For F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn */
#define C0_DO_NOT_FORCE_DIALOG_DM_CSB 0
#define C1_FORCE_DIALOG_DM            1
#define C1_DO_NOT_FORCE_DIALOG_CSB    1
#define C2_FORCE_DIALOG_CSB           2

/* For F435_xxxx_STARTEND_LoadGame_COPYPROTECTIONF */
#define CM1_LOAD_GAME_FAILURE -1
#define C01_LOAD_GAME_SUCCESS  1

/* For F449_xxxx_FLOPPY_IsDiskWriteProtected */
#define C0_FLOPPY_DRIVE_A 0
#define C1_FLOPPY_DRIVE_B 1

/* For F452_xxxx_FLOPPY_GetDiskTypeInDrive_COPYPROTECTIONB */
#define C0_DISK_TYPE_GAME_DISK                 0
#define C1_DISK_TYPE_SAVE_DISK_WRITE_ENABLED   1
#define C2_DISK_TYPE_SAVE_DISK_WRITE_PROTECTED 2
#define C3_DISK_TYPE_UNFORMATTED_DISK          3
#define C4_DISK_TYPE_NO_DISK                   4

/* For F454_xxxx_FLOPPY_IsSaveDiskTypeInSaveDiskDrive */
#define C0_SAVE_DISK_WRITE_ENABLED_FOR_SAVING  0
#define C1_SAVE_DISK_WRITE_ENABLED_FOR_LOADING 1
#define C2_SAVE_DISK_UNFORMATTED_DISK          2

/* For F480_AA07_CACHE_ReleaseBlock and F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic */
#define MASK0x8000_DERIVED_BITMAP 0x8000
#define MASK0x7FFF_GRAPHIC_INDEX  0x7FFF
#define MASK0x8000_NOT_EXPANDED   0x8000

/* For G298_B_NewGame */
#define C000_MODE_LOAD_SAVED_GAME         0
#define C001_MODE_LOAD_DUNGEON            1
#define C099_MODE_WAITING_ON_ENTRANCE    99
#define C202_MODE_ENTRANCE_DRAW_CREDITS 202

/* For G424_i_PanelContent */
#define C0_PANEL_FOOD_WATER_POISONED   0
#define C2_PANEL_SCROLL                2
#define C4_PANEL_CHEST                 4
#define C5_PANEL_RESURRECT_REINCARNATE 5

/* For F497_pzzz_LZW_Decompress */
#define C5004_LZW_TEMPORARY_BUFFER_BYTE_COUNT 5004L /* The maximum size of LZW codes is 12 bits. 2^12 = 4096 is the required size for the LZW buffer. The LZW compression algorithm (not included in the game) has to search for strings in the LZW dictionary. In order to improve performance searches rely on a hashing function and require a buffer size that is a prime number. 5003 is a prime number larger than the required buffer size of 4096 bytes. The actual buffer is 5004 bytes so that it is word aligned */

typedef struct {
        char Routine[42];
        VOID (*PatchedFunction)();
        unsigned char* (*GetGraphicAddressFunction)();
        int GraphicIndex;
        char* SectorBuffer;
        char* HiddenCodeParameters;
        BOOLEAN Used;
        unsigned int FirstWords[3];
} CODE_PATCH;

/* Copy protection */
#define MASK0x0001_SECTOR7   0x0001
#define MASK0x0004_SECTOR247 0x0004

#define MASK0x0000_BUFFER_CONTAINS_GRAPHIC_DATA 0x0000
#define MASK0x0001_BUFFER_CONTAINS_SECTOR7      0x0001
#define MASK0x0002_BUFFER_CONTAINS_SECTOR247    0x0002

#define C00136_TRUE    136
#define C00555_TRUE    555
#define C01113_TRUE   1113
#define C65152_TRUE  65152
#define C00255_FALSE   255
#define C00512_FALSE   512
#define C00555_FALSE   555
#define C03217_FALSE  3217
#define C12777_FALSE 12777


/*_************** Global variables and static local variables **************_*/
extern unsigned char* _base; /* Process base page. This variable is declared in the C loader init.c */
extern BOX_WORD G000_s_Graphic562_Box_SpellArea;
extern BOX_WORD G001_s_Graphic562_Box_ActionArea;
extern BOX_WORD G002_s_Graphic562_Box_MovementArrows;
extern BOX_WORD G003_s_Graphic562_Box_Title_StrikesBack_Destination;
extern BOX_WORD G004_s_Graphic562_Box_Title_StrikesBack_Source;
extern BOX_WORD G005_s_Graphic562_Box_Title_Presents;
extern BOX_WORD G006_s_Graphic562_Box_Entrance_DungeonView;
extern BOX_WORD G007_s_Graphic562_Box_Entrance_OpeningDoorLeft;
extern BOX_WORD G008_s_Graphic562_Box_Entrance_OpeningDoorRight;
extern BOX_WORD G009_s_Graphic562_Box_Entrance_Doors;
extern BOX_WORD G010_s_Graphic562_Box_Entrance_ClosedDoorLeft;
extern BOX_WORD G011_s_Graphic562_Box_Entrance_ClosedDoorRight;
extern BOX_WORD G012_s_Graphic562_Box_Endgame_TheEnd;
extern BOX_WORD G013_s_Graphic562_Box_Endgame_Restart_Outer;
extern BOX_WORD G014_s_Graphic562_Box_Endgame_Restart_Inner;
extern BOX_WORD G015_s_Graphic562_Box_Endgame_ChampionMirror;
extern BOX_WORD G016_s_Graphic562_Box_Endgame_ChampionPortrait;
extern unsigned char G017_auc_Graphic562_PaletteChanges_NoChanges[16];
extern int G018_ai_Graphic562_MandatoryGraphicIndices[C070_MANDATORY_GRAPHIC_COUNT];
extern unsigned int G019_aui_Graphic562_Palette_Credits[16];
extern unsigned int G020_aui_Graphic562_Palette_Entrance[16];
extern unsigned int G021_aaui_Graphic562_Palette_DungeonView[6][16];
extern int G022_i_Graphic562_IndirectStopExpiringEvent_COPYPROTECTIONE;
extern char G023_aac_Graphic562_OrderedCellsToAttack[8][4];
extern char G024_ac_Graphic562_WoundProbabilityIndexToWoundMask[4];
extern char G025_ac_Graphic562_Unreferenced[8];
extern int G026_ai_Graphic562_IconGraphicFirstIconIndex[7];
extern char G027_ac_Graphic562_Unreferenced[4];
extern BOX_WORD G028_s_Graphic562_Box_LeaderHandObjectName;
extern unsigned char G029_auc_Graphic562_ChargeCountToTorchType[16];
extern SLOT_BOX G030_as_Graphic562_SlotBoxes[46];
extern int G031_i_Graphic562_Sector7Analyzed_COPYPROTECTIONE;
extern BOX_WORD G032_s_Graphic562_Box_Panel;
extern BOX_WORD G033_s_Graphic562_Box_ArrowOrEye;
extern BOX_WORD G034_s_Graphic562_Box_ObjectDescriptionCircle;
extern BOX_WORD G035_s_Graphic562_Box_Food;
extern BOX_WORD G036_s_Graphic562_Box_Water;
extern BOX_WORD G037_s_Graphic562_Box_Poisoned;
extern int G038_ai_Graphic562_SlotMasks[38];
extern int G039_ai_Graphic562_LightPowerToLightAmount[16];
extern int G040_ai_Graphic562_PaletteIndexToLightAmount[6];
extern BOX_WORD G041_s_Graphic562_Box_ViewportFloppyZzzCross;
extern unsigned char G042_auc_Graphic562_Bitmap_ArrowPointer[M75_BITMAP_BYTE_COUNT(16, 16)];
extern unsigned char G043_auc_Graphic562_Bitmap_HandPointer[M75_BITMAP_BYTE_COUNT(16, 16)];
extern unsigned char G044_auc_Graphic562_PaletteChanges_MousePointerIcon[16];
extern unsigned char G045_auc_Graphic562_PaletteChanges_MousePointerIconShadow[16];
extern unsigned char G046_auc_Graphic562_ChampionColor[4];
extern BOX_BYTE G047_s_Graphic562_Box_ChampionPortrait;
extern BOX_WORD G048_s_Graphic562_Box_Mouth;
extern BOX_WORD G049_s_Graphic562_Box_Eye;
extern unsigned char G050_auc_Graphic562_WoundDefenseFactor[6];
extern char G051_ac_Graphic562_UnderscoreCharacterString[2];
extern char G052_ac_Graphic562_RenameChampionInputCharacterString[2];
extern char G053_ac_Graphic562_ReincarnateSpecialCharacters[6];
extern int G054_ai_Graphic562_Box_ChampionIcons[16];
extern unsigned int G055_aaaui_Graphic562_BarGraphMasks[4][3][2];
extern unsigned int G056_aaui_Graphic562_BarGraphByteOffsets[4][3];
extern int G057_ai_Graphic562_SlotDropOrder[30];
extern int G058_i_Graphic562_Useless_COPYPROTECTIOND;
extern unsigned char G059_auc_Graphic562_SquareTypeToEventType[7];
extern SOUND G060_as_Graphic562_Sounds[22];
extern BOX_WORD G061_s_Graphic562_Box_ScreenTop;
extern BOX_WORD G062_s_Graphic562_Box_ScreenRight;
extern BOX_WORD G063_s_Graphic562_Box_ScreenBottom;
extern long G064_al_Graphic562_PrintTextMasks2[4];
extern long G065_al_Graphic562_PrintTextMasks1[4];
extern char G066_ac_Graphic562_LineFeedCharacterString[2];
extern int G067_i_Graphic562Anchor;
extern int G068_i_CheckLastEvent22Time_COPYPROTECTIONE;
extern unsigned int G069_ui_State_COPYPROTECTIONF;
extern BOOLEAN G070_B_Sector7Analyzed_COPYPROTECTIONF;
extern BOOLEAN G071_B_Sector7ReadingInitiated_COPYPROTECTIONF;
extern unsigned int G072_ui_GraceReadRetryCount_COPYPROTECTIONF;
extern int G073_i_StopFreeingMemory_COPYPROTECTIONF;
extern unsigned char* G074_puc_Bitmap_Temporary;
extern unsigned char* G075_apuc_PaletteChanges_Projectile[4];
extern BOOLEAN G076_B_UseFlippedWallAndFootprintsBitmaps;
extern BOOLEAN G077_B_DoNotDrawFluxcagesDuringEndgame;
extern BOOLEAN G078_B_FuzzyBitFound_COPYPROTECTIONF;
extern int G079_ai_StairsNativeBitmapIndices[C018_STAIRS_GRAPHIC_COUNT];
extern int G080_aai_DoorNativeBitmapIndices[C003_DOOR_SET_GRAPHIC_COUNT][2];
extern int G081_ai_FuzzyBits_COPYPROTECTIONF[32];
extern char G082_ac_CodePatch0_COPYPROTECTIONF[68];
extern char* G083_apc_Graphic21Result_COPYPROTECTIONF[4];
extern unsigned char* G084_puc_Bitmap_Floor;
extern unsigned char* G085_puc_Bitmap_Ceiling;
extern unsigned char* G086_puc_Bitmap_ViewportBlackArea;
extern unsigned char* G087_puc_Bitmap_ViewportFloorArea;
extern unsigned char* G088_apuc_Bitmap_WallSet[C013_WALL_SET_GRAPHIC_COUNT + 2];
extern char G089_ac_CodePatch1_COPYPROTECTIONF[68];
extern unsigned char* G090_puc_Bitmap_WallD3LCR_Flipped;
extern unsigned char* G091_puc_Bitmap_WallD2LCR_Flipped;
extern unsigned char* G092_puc_Bitmap_WallD1LCR_Flipped;
extern unsigned char* G093_puc_Bitmap_WallD0L_Flipped;
extern unsigned char* G094_puc_Bitmap_WallD0R_Flipped;
extern unsigned char* G095_puc_Bitmap_WallD3LCR_Native;
extern unsigned char* G096_puc_Bitmap_WallD2LCR_Native;
extern unsigned char* G097_puc_Bitmap_WallD1LCR_Native;
extern unsigned char* G098_puc_Bitmap_WallD0L_Native;
extern unsigned char* G099_puc_Bitmap_WallD0R_Native;
extern char G100_ac_CodePatch2_COPYPROTECTIONF[68];
extern int G101_aai_CurrentMapWallOrnamentsInfo[16][2];
extern int G102_aai_CurrentMapFloorOrnamentsInfo[16][2];
extern int G103_aai_CurrentMapDoorOrnamentsInfo[17][2];
extern char* G104_apc_CodePatches_COPYPROTECTIONF[3];
extern BOX_BYTE G105_s_Graphic558_Box_ExplosionPattern_D0C;
extern BOX_BYTE G106_s_Graphic558_Box_ThievesEye_ViewportVisibleArea;
extern BOX_BYTE G107_s_Graphic558_Box_ThievesEye_VisibleArea;
extern BOX_BYTE G108_s_Graphic558_Box_ThievesEye_HoleInDoorFrame;
extern BOX_BYTE G109_s_Graphic558_Box_ChampionPortraitOnWall;
extern FRAME G110_s_Graphic558_Frame_StairsUpFront_D3L;
extern FRAME G111_s_Graphic558_Frame_StairsUpFront_D3C;
extern FRAME G112_s_Graphic558_Frame_StairsUpFront_D3R;
extern FRAME G113_s_Graphic558_Frame_StairsUpFront_D2L;
extern FRAME G114_s_Graphic558_Frame_StairsUpFront_D2C;
extern FRAME G115_s_Graphic558_Frame_StairsUpFront_D2R;
extern FRAME G116_s_Graphic558_Frame_StairsUpFront_D1L;
extern FRAME G117_s_Graphic558_Frame_StairsUpFront_D1C;
extern FRAME G118_s_Graphic558_Frame_StairsUpFront_D1R;
extern FRAME G119_s_Graphic558_Frame_StairsUpFront_D0L;
extern FRAME G120_s_Graphic558_Frame_StairsUpFront_D0R;
extern FRAME G121_s_Graphic558_Frame_StairsDownFront_D3L;
extern FRAME G122_s_Graphic558_Frame_StairsDownFront_D3C;
extern FRAME G123_s_Graphic558_Frame_StairsDownFront_D3R;
extern FRAME G124_s_Graphic558_Frame_StairsDownFront_D2L;
extern FRAME G125_s_Graphic558_Frame_StairsDownFront_D2C;
extern FRAME G126_s_Graphic558_Frame_StairsDownFront_D2R;
extern FRAME G127_s_Graphic558_Frame_StairsDownFront_D1L;
extern FRAME G128_s_Graphic558_Frame_StairsDownFront_D1C;
extern FRAME G129_s_Graphic558_Frame_StairsDownFront_D1R;
extern FRAME G130_s_Graphic558_Frame_StairsDownFront_D0L;
extern FRAME G131_s_Graphic558_Frame_StairsDownFront_D0R;
extern FRAME G132_s_Graphic558_Frame_StairsSide_D2L;
extern FRAME G133_s_Graphic558_Frame_StairsSide_D2R;
extern FRAME G134_s_Graphic558_Frame_StairsUpSide_D1L;
extern FRAME G135_s_Graphic558_Frame_StairsUpSide_D1R;
extern FRAME G136_s_Graphic558_Frame_StairsDownSide_D1L;
extern FRAME G137_s_Graphic558_Frame_StairsDownSide_D1R;
extern FRAME G138_s_Graphic558_Frame_StairsSide_D0L;
extern FRAME G139_s_Graphic558_Frame_StairsSide_D0R;
extern FRAME G140_s_Graphic558_Frame_FloorPit_D3L;
extern FRAME G141_s_Graphic558_Frame_FloorPit_D3C;
extern FRAME G142_s_Graphic558_Frame_FloorPit_D3R;
extern FRAME G143_s_Graphic558_Frame_FloorPit_D2L;
extern FRAME G144_s_Graphic558_Frame_FloorPit_D2C;
extern FRAME G145_s_Graphic558_Frame_FloorPit_D2R;
extern FRAME G146_s_Graphic558_Frame_FloorPit_D1L;
extern FRAME G147_s_Graphic558_Frame_FloorPit_D1C;
extern FRAME G148_s_Graphic558_Frame_FloorPit_D1R;
extern FRAME G149_s_Graphic558_Frame_FloorPit_D0L;
extern FRAME G150_s_Graphic558_Frame_FloorPit_D0C;
extern FRAME G151_s_Graphic558_Frame_FloorPit_D0R;
extern FRAME G152_s_Graphic558_Frame_CeilingPit_D2L;
extern FRAME G153_s_Graphic558_Frame_CeilingPit_D2C;
extern FRAME G154_s_Graphic558_Frame_CeilingPit_D2R;
extern FRAME G155_s_Graphic558_Frame_CeilingPit_D1L;
extern FRAME G156_s_Graphic558_Frame_CeilingPit_D1C;
extern FRAME G157_s_Graphic558_Frame_CeilingPit_D1R;
extern FRAME G158_s_Graphic558_Frame_CeilingPit_D0L;
extern FRAME G159_s_Graphic558_Frame_CeilingPit_D0C;
extern FRAME G160_s_Graphic558_Frame_CeilingPit_D0R;
extern BOX_BYTE G161_s_Graphic558_Box_WallBitmap_D3LCR;
extern BOX_BYTE G162_s_Graphic558_Box_WallBitmap_D2LCR;
extern FRAME G163_as_Graphic558_Frame_Walls[14];
extern FRAME G164_s_Graphic558_Frame_DoorFrameLeft_D3L;
extern FRAME G165_s_Graphic558_Frame_DoorFrameRight_D3R;
extern FRAME G166_s_Graphic558_Frame_DoorFrameLeft_D3C;
extern FRAME G167_s_Graphic558_Frame_DoorFrameRight_D3C;
extern FRAME G168_s_Graphic558_Frame_DoorFrameLeft_D2C;
extern FRAME G169_s_Graphic558_Frame_DoorFrameRight_D2C;
extern FRAME G170_s_Graphic558_Frame_DoorFrameLeft_D1C;
extern FRAME G171_s_Graphic558_Frame_DoorFrameRight_D1C;
extern FRAME G172_s_Graphic558_Frame_DoorFrame_D0C;
extern FRAME G173_s_Graphic558_Frame_DoorFrameTop_D2L;
extern FRAME G174_s_Graphic558_Frame_DoorFrameTop_D2C;
extern FRAME G175_s_Graphic558_Frame_DoorFrameTop_D2R;
extern FRAME G176_s_Graphic558_Frame_DoorFrameTop_D1L;
extern FRAME G177_s_Graphic558_Frame_DoorFrameTop_D1C;
extern FRAME G178_s_Graphic558_Frame_DoorFrameTop_D1R;
extern DOOR_FRAMES G179_s_Graphic558_Frames_Door_D3L;
extern DOOR_FRAMES G180_s_Graphic558_Frames_Door_D3C;
extern DOOR_FRAMES G181_s_Graphic558_Frames_Door_D3R;
extern DOOR_FRAMES G182_s_Graphic558_Frames_Door_D2L;
extern DOOR_FRAMES G183_s_Graphic558_Frames_Door_D2C;
extern DOOR_FRAMES G184_s_Graphic558_Frames_Door_D2R;
extern DOOR_FRAMES G185_s_Graphic558_Frames_Door_D1L;
extern DOOR_FRAMES G186_s_Graphic558_Frames_Door_D1C;
extern DOOR_FRAMES G187_s_Graphic558_Frames_Door_D1R;
extern FIELD_ASPECT G188_as_Graphic558_FieldAspects[12];
extern int G189_i_Graphic558_StopAddingEvents_COPYPROTECTIONE;
extern unsigned char G190_auc_Graphic558_WallOrnamentDerivedBitmapIndexIncrement[12];
extern unsigned char G191_auc_Graphic558_FloorOrnamentNativeBitmapIndexIncrements[9];
extern unsigned char G192_auc_Graphic558_AlcoveOrnamentIndices[C003_ALCOVE_ORNAMENT_COUNT];
extern int G193_ai_Graphic558_FountainOrnamentIndices[C001_FOUNTAIN_ORNAMENT_COUNT];
extern unsigned char G194_auc_Graphic558_WallOrnamentCoordinateSetIndices[60];
extern unsigned char G195_auc_Graphic558_FloorOrnamentCoordinateSetIndices[9];
extern unsigned char G196_auc_Graphic558_DoorOrnamentCoordinateSetIndices[12];
extern unsigned char G197_auc_Graphic558_DoorButtonCoordinateSet[1];
extern unsigned char G198_auc_Graphic558_PaletteChanges_DoorButtonAndWallOrnament_D3[16];
extern unsigned char G199_auc_Graphic558_PaletteChanges_DoorButtonAndWallOrnament_D2[16];
extern unsigned char G200_auc_Graphic558_PaletteChanges_DoorOrnament_D3[16];
extern unsigned char G201_auc_Graphic558_PaletteChanges_DoorOrnament_D2[16];
extern BOX_BYTE G202_ac_Graphic558_Box_WallPatchBehindInscription;
extern char G203_ac_Graphic558_InscriptionLineY[4];
extern char G204_ac_Graphic558_UnreadableInscriptionBoxY2[15];
extern unsigned char G205_aaauc_Graphic558_WallOrnamentCoordinateSets[8][13][6];
extern unsigned char G206_aaauc_Graphic558_FloorOrnamentCoordinateSets[3][9][6];
extern unsigned char G207_aaauc_Graphic558_DoorOrnamentCoordinateSets[4][3][6];
extern unsigned char G208_aaauc_Graphic558_DoorButtonCoordinateSets[1][4][6];
extern OBJECT_ASPECT G209_as_Graphic558_ObjectAspects[C085_OBJECT_ASPECT_COUNT];
extern PROJECTIL_ASPECT G210_as_Graphic558_ProjectileAspects[C014_PROJECTILE_ASPECT_COUNT];
extern EXPLOSION_ASPECT G211_as_Graphic558_ExplosionAspects[C004_EXPLOSION_ASPECT_COUNT];
extern unsigned char G212_auc_Graphic558_PaletteChanges_Smoke[16];
extern unsigned char G213_auc_Graphic558_PaletteChanges_FloorOrnament_D3[16];
extern unsigned char G214_auc_Graphic558_PaletteChanges_FloorOrnament_D2[16];
extern unsigned char G215_auc_Graphic558_ProjectileScales[7];
extern unsigned char G216_auc_Graphic558_ExplosionBaseScales[5];
extern unsigned char G217_aauc_Graphic558_ObjectPileShiftSetIndices[16][2];
extern unsigned char G218_aaaauc_Graphic558_ObjectCoordinateSets[3][10][5][2];
extern CREATURE_ASPECT G219_as_Graphic558_CreatureAspects[C027_CREATURE_TYPE_COUNT];
extern CREATURE_REPLACEMENT_COLOR_SET G220_as_Graphic558_CreatureReplacementColorSets[13];
extern unsigned char G221_auc_Graphic558_PaletteChanges_Creature_D3[16];
extern unsigned char G222_auc_Graphic558_PaletteChanges_Creature_D2[16];
extern char G223_aac_Graphic558_ShiftSets[3][8];
extern unsigned char G224_aaaauc_Graphic558_CreatureCoordinateSets[3][11][5][2];
extern int G225_aai_Graphic558_CenteredExplosionCoordinates[15][2];
extern int G226_aaai_Graphic558_ExplosionCoordinates[15][2][2];
extern int G227_aai_Graphic558_RebirthStep2ExplosionCoordinates[7][3];
extern int G228_aai_Graphic558_RebirthStep1ExplosionCoordinates[7][3];
extern int G229_i_Graphic558Anchor;
extern int G230_i_CurrentFloorSet;
extern int G231_i_CurrentWallSet;
extern BOOLEAN G232_B_FirstFunctionCall;
extern int G233_ai_Graphic559_DirectionToStepEastCount[4];
extern int G234_ai_Graphic559_DirectionToStepNorthCount[4];
extern unsigned char G235_auc_Graphic559_ThingDataByteCount[16];
extern unsigned char G236_auc_Graphic559_AdditionalThingCounts[16];
extern OBJECT_INFO G237_as_Graphic559_ObjectInfo[180];
extern WEAPON_INFO G238_as_Graphic559_WeaponInfo[46];
extern ARMOUR_INFO G239_as_Graphic559_ArmourInfo[58];
extern int G240_i_Graphic559_State_COPYPROTECTIOND;
extern char G241_ac_Graphic559_JunkInfo[53];
extern int G242_ai_Graphic559_FoodAmounts[8];
extern CREATURE_INFO G243_as_Graphic559_CreatureInfo[C027_CREATURE_TYPE_COUNT];
extern unsigned char G244_auc_Graphic559_CreatureAttackSounds[8];
extern unsigned int G245_aui_Graphic559_FixedPossessionsCreature12Skeleton[3];
extern unsigned int G246_aui_Graphic559_FixedPossessionsCreature09StoneGolem[2];
extern unsigned int G247_aui_Graphic559_FixedPossessionsCreature16Trolin_Antman[2];
extern unsigned int G248_aui_Graphic559_FixedPossessionsCreature18AnimatedArmour_DethKnight[7];
extern unsigned int G249_aui_Graphic559_FixedPossessionsCreature07Rock_RockPile[5];
extern unsigned int G250_aui_Graphic559_FixedPossessionsCreature04PainRat_Hellhound[3];
extern unsigned int G251_aui_Graphic559_FixedPossessionsCreature06Screamer[3];
extern unsigned int G252_aui_Graphic559_FixedPossessionsCreature15MagentaWorm_Worm[4];
extern unsigned int G253_aui_Graphic559_FixedPossessionsCreature24RedDragon[11];
extern DOOR_INFO G254_as_Graphic559_DoorInfo[4];
extern char G255_aac_Graphic559_MessageAndScrollEscapeReplacementStrings[32][8];
extern char G256_aac_Graphic559_EscapeReplacementCharacters[32][2];
extern char G257_aac_Graphic559_InscriptionEscapeReplacementStrings[32][8];
extern unsigned char G258_auc_Graphic559_GroupDirections[4];
extern int G259_i_Graphic559Anchor;
extern unsigned int* G260_pui_DungeonTextData;
extern unsigned char G261_auc_CurrentMapWallOrnamentIndices[15];
extern unsigned char G262_auc_CurrentMapFloorOrnamentIndices[15];
extern unsigned char G263_auc_CurrentMapDoorOrnamentIndices[17];
extern unsigned char* G264_puc_CurrentMapAllowedCreatureTypes;
extern int G265_i_CurrentMapInscriptionWallOrnamentIndex;
extern int G266_i_CurrentMapViAltarWallOrnamentIndex;
extern int G267_ai_CurrentMapAlcoveOrnamentIndices[3];
extern int G268_ai_CurrentMapFountainOrnamentIndices[1];
extern MAP* G269_ps_CurrentMap;
extern unsigned int* G270_pui_CurrentMapColumnsCumulativeSquareFirstThingCount;
extern unsigned char** G271_ppuc_CurrentMapData;
extern int G272_i_CurrentMapIndex;
extern int G273_i_CurrentMapWidth;
extern int G274_i_CurrentMapHeight;
extern DOOR_INFO G275_as_CurrentMapDoorInfo[2];
extern unsigned char* G276_puc_DungeonRawMapData;
extern MAP* G277_ps_DungeonMaps;
extern DUNGEON_HEADER* G278_ps_DungeonHeader;
extern unsigned char*** G279_pppuc_DungeonMapData;
extern unsigned int* G280_pui_DungeonColumnsCumulativeSquareThingCount;
extern int* G281_pi_DungeonMapsFirstColumnIndex;
extern unsigned int G282_ui_DungeonColumnCount;
extern THING* G283_pT_SquareFirstThings;
extern unsigned char* G284_apuc_ThingData[16];
extern int G285_i_SquareAheadElement;
extern BOOLEAN G286_B_FacingAlcove;
extern BOOLEAN G287_B_FacingViAltar;
extern BOOLEAN G288_B_FacingFountain;
extern int G289_i_DungeonView_ChampionPortraitOrdinal;
extern THING G290_T_DungeonView_InscriptionThing;
extern unsigned char G291_aauc_DungeonViewClickableBoxes[6][4];
extern THING G292_aT_PileTopObject[5];
extern int G293_ai_FuzzyBits_COPYPROTECTIONE[32];
extern unsigned char G294_auc_LastDiscardedThingMapIndex[16];
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_00_OPTIMIZATION */
extern char G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE[512];
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_00_OPTIMIZATION */
extern char G295_ac_Sector7ReadingBuffer_COPYPROTECTIONE[1024];
#endif
extern unsigned char* G296_puc_Bitmap_Viewport;
extern BOOLEAN G297_B_DrawFloorAndCeilingRequested;
extern BOOLEAN G298_B_NewGame;
extern unsigned int G299_ui_CandidateChampionOrdinal;
extern BOOLEAN G300_B_PartyIsSleeping;
extern BOOLEAN G301_B_GameTimeTicking;
extern BOOLEAN G302_B_GameWon;
extern BOOLEAN G303_B_PartyDead;
extern int G304_i_DungeonViewPaletteIndex;
extern unsigned int G305_ui_PartyChampionCount;
extern int G306_i_PartyMapX;
extern int G307_i_PartyMapY;
extern int G308_i_PartyDirection;
extern int G309_i_PartyMapIndex;
extern int G310_i_DisabledMovementTicks;
extern int G311_i_ProjectileDisabledMovementTicks;
extern int G312_i_LastProjectileDisabledMovementDirection;
extern unsigned long G313_ul_GameTime;
extern int G314_i_SectorsReadRequested_COPYPROTECTIONDF;
extern int G315_i_SectorsReadFailure_COPYPROTECTIONDF;
extern int G316_i_SectorsReadPreviousFailure_COPYPROTECTIONDF;
extern int G317_i_WaitForInputVerticalBlankCount;
extern int G318_i_WaitForInputMaximumVerticalBlankCount;
extern unsigned long G319_ul_LoadGameTime_COPYPROTECTIONF;
extern int G320_i_Unreferenced;
extern BOOLEAN G321_B_StopWaitingForPlayerInput;
extern BOOLEAN G322_B_PaletteSwitchingEnabled;
extern BOOLEAN G323_B_EnablePaletteSwitchingRequested;
extern BOOLEAN G324_B_DrawViewportRequested;
extern BOOLEAN G325_B_SetMousePointerToObjectInMainLoop;
extern BOOLEAN G326_B_RefreshMousePointerInMainLoop;
extern int G327_i_NewPartyMapIndex;
extern int G328_i_TimeBombToKillParty_COPYPROTECTIONF;
extern int G329_i_Useless_COPYPROTECTIOND;
extern int G330_i_StopExpiringEvents_COPYPROTECTIONE;
extern BOOLEAN G331_B_PressingEye;
extern BOOLEAN G332_B_StopPressingEye;
extern BOOLEAN G333_B_PressingMouth;
extern BOOLEAN G334_B_StopPressingMouth;
extern int G335_i_SelectedDialogChoice;
extern int G336_i_HighlightBoxX1;
extern int G337_i_HighlightBoxX2;
extern int G338_i_HighlightBoxY1;
extern int G339_i_HighlightBoxY2;
extern BOOLEAN G340_B_HighlightBoxInversionRequested;
extern BOOLEAN G341_B_HighlightBoxEnabled;
extern BOOLEAN G342_B_RefreshDungeonViewPaletteRequested;
extern unsigned char* G343_puc_Graphic_DialogBox;
extern char G344_ac_CodePatch1_COPYPROTECTIONE[68];
extern unsigned int G345_aui_BlankBuffer[32];
extern unsigned int G346_aui_Palette_MiddleScreen[16];
extern unsigned int G347_aui_Palette_TopAndBottomScreen[16];
extern long* G348_pl_Bitmap_LogicalScreenBase;
extern unsigned long G349_ul_LastRandomNumber;
extern BOOLEAN G350_B_SwitchToTopBottomPalette;
extern int G351_i_ConcurrentVerticalBlankExceptionCount;
extern char* G352_apc_ObjectNames[C199_OBJECT_NAME_COUNT];
extern char G353_ac_StringBuildBuffer[128];
extern int G354_i_MessageAreaScrollingLineCount;
extern BOOLEAN G355_B_ScrollMessageArea;
extern unsigned char* G356_puc_Bitmap_MessageAreaNewRow;
extern unsigned char* G357_puc_InterfaceAndScrollsFont;
extern int G358_i_MessageAreaCursorRow;
extern int G359_i_MessageAreaCursorColumn;
extern long G360_al_MessageAreaRowExpirationTime[4];
extern long G361_l_LastCreatureAttackTime;
extern long G362_l_LastPartyMovementTime;
extern int G363_i_SecondaryDirectionToOrFromParty;
extern int G364_i_CreatureDamageOutcome;
extern BOOLEAN G365_B_CreateLauncherProjectile;
extern int G366_i_ProjectilePoisonAttack;
extern int G367_i_ProjectileAttackType;
extern char* G368_apc_CodePatches_COPYPROTECTIONE[6];
extern unsigned int G369_ui_EventMaximumCount;
extern EVENT* G370_ps_Events;
extern int* G371_pi_Timeline;
extern unsigned int G372_ui_EventCount;
extern unsigned int G373_ui_FirstUnusedEventIndex;
extern long G374_l_WatchdogTime;
extern ACTIVE_GROUP* G375_ps_ActiveGroups;
extern unsigned int G376_ui_MaximumActiveGroupCount;
extern unsigned int G377_ui_CurrentActiveGroupCount;
extern int G378_i_CurrentGroupMapX;
extern int G379_i_CurrentGroupMapY;
extern THING G380_T_CurrentGroupThing;
extern unsigned int G381_ui_CurrentGroupDistanceToParty;
extern int G382_i_CurrentGroupPrimaryDirectionToParty;
extern int G383_i_CurrentGroupSecondaryDirectionToParty;
extern char G384_ac_GroupMovementTestedDirections[4];
extern char G385_ac_FluxCages[4];
extern unsigned int G386_ui_FluxCageCount;
extern BOOLEAN G387_B_GroupMovementBlockedByWallStairsPitFakeWallFluxcageTeleporter;
extern THING G388_T_GroupMovementBlockedByGroupThing;
extern BOOLEAN G389_B_GroupMovementBlockedByDoor;
extern BOOLEAN G390_B_GroupMovementBlockedByParty;
extern int G391_i_DropMovingCreatureFixedPossessionsCellCount;
extern unsigned char G392_auc_DropMovingCreatureFixedPossessionsCells[4];
extern char G393_ac_CodePatch4_COPYPROTECTIONE[68];
extern unsigned char G394_auc_StealFromSlotIndices[8];
extern long G395_l_LastGroupDirectionSetTime;
extern ACTIVE_GROUP* G396_ps_TwoHalfSquareSizedCreaturesGroupLastDirectionSetActiveGroup;
extern int G397_i_MoveResultMapX;
extern int G398_i_MoveResultMapY;
extern unsigned int G399_ui_MoveResultMapIndex;
extern int G400_i_MoveResultDirection;
extern unsigned int G401_ui_MoveResultCell;
extern BOOLEAN G402_B_UseRopeToClimbDownPit;
extern int G403_i_SensorRotationEffect;
extern int G404_i_SensorRotationEffectMapX;
extern int G405_i_SensorRotationEffectMapY;
extern int G406_i_SensorRotationEffectCell;
extern PARTY G407_s_Party;
extern char G408_ac_CodePatch3_COPYPROTECTIONE[68];
extern int G409_ai_ChampionPendingDamage[4];
extern int G410_ai_ChampionPendingWounds[4];
extern int G411_i_LeaderIndex;
extern unsigned char* G412_puc_Bitmap_ObjectIconForMousePointer;
extern int G413_i_LeaderHandObjectIconIndex;
extern THING G414_T_LeaderHandObject;
extern BOOLEAN G415_B_LeaderEmptyHanded;
extern int G416_i_Useless;
extern char* G417_apc_BaseSkillNames[4];
extern long G418_l_LastEvent22Time_COPYPROTECTIONE;
extern char G419_ac_IntegerToStringConversionBuffer[5];
extern BOOLEAN G420_B_MousePointerHiddenToDrawChangedObjectIconOnScreen;
extern int G421_i_ObjectDescriptionTextX;
extern int G422_i_ObjectDescriptionTextY;
extern int G423_i_InventoryChampionOrdinal;
extern int G424_i_PanelContent;
extern THING G425_aT_ChestSlots[8];
extern THING G426_T_OpenChest;
extern char G427_ac_CodePatch5_COPYPROTECTIONE[68];
extern char* G428_apc_SkillLevelNames[15];
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_04_IMPROVEMENT */
extern char* G429_apc_Graphic21Result_COPYPROTECTIONE[3];
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_04_IMPROVEMENT */
extern char* G429_apc_Graphic21Result_COPYPROTECTIONE[4];
#endif
extern char* G430_apc_DirectionNames[4];
extern char* G431_apc_StatisticNames[7];
extern COMMAND G432_as_CommandQueue[5];
extern int G433_i_CommandQueueFirstIndex;
extern int G434_i_CommandQueueLastIndex;
extern BOOLEAN G435_B_CommandQueueLocked;
extern BOOLEAN G436_B_PendingClickPresent;
extern int G437_i_PendingClickX;
extern int G438_i_PendingClickY;
extern int G439_i_PendingClickButtonsStatus;
extern BOOLEAN G440_B_Consequence_StopSearchingMouseInput_COPYPROTECTIONC;
extern MOUSE_INPUT* G441_ps_PrimaryMouseInput;
extern MOUSE_INPUT* G442_ps_SecondaryMouseInput;
extern KEYBOARD_INPUT* G443_ps_PrimaryKeyboardInput;
extern KEYBOARD_INPUT* G444_ps_SecondaryKeyboardInput;
extern MOUSE_INPUT G445_as_Graphic561_PrimaryMouseInput_Entrance[4];
extern MOUSE_INPUT G446_as_Graphic561_PrimaryMouseInput_RestartGame[2];
#ifdef C06_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_DM12GE_DM13aFR_DM13bFR /* CHANGE7_28_IMPROVEMENT */
extern MOUSE_INPUT G447_as_Graphic561_PrimaryMouseInput_Interface[16];
#endif
#ifdef C27_COMPILE_CSB20EN_CSB21EN /* CHANGE7_28_IMPROVEMENT */
extern MOUSE_INPUT G447_as_Graphic561_PrimaryMouseInput_Interface[20];
#endif
extern MOUSE_INPUT G448_as_Graphic561_SecondaryMouseInput_Movement[9];
extern MOUSE_INPUT G449_as_Graphic561_SecondaryMouseInput_ChampionInventory[38];
extern MOUSE_INPUT G450_as_Graphic561_PrimaryMouseInput_PartySleeping[3];
extern MOUSE_INPUT G451_as_Graphic561_PrimaryMouseInput_FrozenGame[3];
extern MOUSE_INPUT G452_as_Graphic561_MouseInput_ActionAreaNames[5];
extern MOUSE_INPUT G453_as_Graphic561_MouseInput_ActionAreaIcons[5];
extern MOUSE_INPUT G454_as_Graphic561_MouseInput_SpellArea[9];
extern MOUSE_INPUT G455_as_Graphic561_MouseInput_ChampionNamesHands[13];
extern MOUSE_INPUT G456_as_Graphic561_MouseInput_PanelChest[9];
extern MOUSE_INPUT G457_as_Graphic561_MouseInput_PanelResurrectReincarnateCancel[4];
extern KEYBOARD_INPUT G458_as_Graphic561_PrimaryKeyboardInput_Interface[7];
extern KEYBOARD_INPUT G459_as_Graphic561_SecondaryKeyboardInput_Movement[7];
extern KEYBOARD_INPUT G460_as_Graphic561_PrimaryKeyboardInput_PartySleeping[3];
extern KEYBOARD_INPUT G461_as_Graphic561_PrimaryKeyboardInput_FrozenGame[2];
extern BOX_BYTE G462_as_Graphic561_Box_ObjectPiles[4];
extern BOX_WORD G463_as_Graphic561_Box_MovementArrows[4];
extern BOX_WORD G464_as_Graphic561_Box_SpellSymbolsAndDelete[7];
extern int G465_ai_Graphic561_MovementArrowToStepForwardCount[4];
extern int G466_ai_Graphic561_MovementArrowToStepRightCount[4];
extern BOX_WORD G467_s_Graphic561_Box_Dialog1ChoicePatchA;
extern BOX_WORD G468_s_Graphic561_Box_Dialog1ChoicePatchB;
extern BOX_WORD G469_s_Graphic561_Box_Dialog2ChoicesPatch;
extern BOX_WORD G470_s_Graphic561_Box_Dialog4ChoicesPatch;
extern MOUSE_INPUT G471_as_Graphic561_PrimaryMouseInput_ViewportDialog1Choice[2];
extern MOUSE_INPUT G472_as_Graphic561_PrimaryMouseInput_ViewportDialog2Choices[3];
extern MOUSE_INPUT G473_as_Graphic561_PrimaryMouseInput_ViewportDialog3Choices[4];
extern MOUSE_INPUT G474_as_Graphic561_PrimaryMouseInput_ViewportDialog4Choices[5];
extern MOUSE_INPUT G475_as_Graphic561_PrimaryMouseInput_ScreenDialog1Choice[2];
extern MOUSE_INPUT G476_as_Graphic561_PrimaryMouseInput_ScreenDialog2Choices[3];
extern MOUSE_INPUT G477_as_Graphic561_PrimaryMouseInput_ScreenDialog3Choices[4];
extern MOUSE_INPUT G478_as_Graphic561_PrimaryMouseInput_ScreenDialog4Choices[5];
extern int G479_i_Graphic561Anchor;
extern MOUSE_INPUT* G480_aaps_PrimaryMouseInput_DialogSets[2][4];
extern KEYBOARD_INPUT* G481_ps_PrimaryKeyboardInputBackup;
extern KEYBOARD_INPUT* G482_ps_SecondaryKeyboardInputBackup;
extern MOUSE_INPUT* G483_ps_PrimaryMouseInputBackup;
extern MOUSE_INPUT* G484_ps_SecondaryMouseInputBackup;
extern unsigned char G485_aauc_Graphic560_SymbolBaseManaCost[4][6];
extern unsigned char G486_auc_Graphic560_SymbolManaCostMultiplier[6];
extern SPELL G487_as_Graphic560_Spells[25];
extern int G488_i_Graphic560_RequestCheckFuzzyBitCount_COPYPROTECTIONE;
extern ACTION_SET G489_as_Graphic560_ActionSets[44];
#ifdef C09_COMPILE_DM10aEN_DM10bEN_DM11EN_DM12EN_CSB20EN_CSB21EN /* CHANGE4_00_LOCALIZATION Translation to German language */
extern char G490_ac_Graphic560_ActionNames[300];
#endif
#ifdef C22_COMPILE_DM12GE_DM13aFR_DM13bFR /* CHANGE4_00_LOCALIZATION Translation to German language */
extern char G490_ac_Graphic560_ActionNames[400];
#endif
extern unsigned char G491_auc_Graphic560_ActionDisabledTicks[44];
extern unsigned char G492_auc_Graphic560_ActionDamageFactor[44];
extern unsigned char G493_auc_Graphic560_ActionHitProbability[44];
extern unsigned char G494_auc_Graphic560_ActionStamina[44];
extern char G495_ac_Graphic560_ActionDefense[44];
extern unsigned char G496_auc_Graphic560_ActionSkillIndex[44];
extern unsigned char G497_auc_Graphic560_ActionExperienceGain[44];
extern unsigned char G498_auc_Graphic560_PaletteChanges_ActionAreaObjectIcon[16];
extern BOX_WORD G499_s_Graphic560_Box_ActionArea3ActionsMenu;
extern BOX_WORD G500_s_Graphic560_Box_ActionArea2ActionsMenu;
extern BOX_WORD G501_s_Graphic560_Box_ActionArea1ActionMenu;
extern BOX_WORD G502_s_Graphic560_Box_ActionAreaMediumDamage;
extern BOX_WORD G503_s_Graphic560_Box_ActionAreaSmallDamage;
extern BOX_WORD G504_s_Graphic560_Box_SpellAreaControls;
extern int G505_i_Graphic560Anchor;
extern int G506_i_ActingChampionOrdinal;
extern unsigned int G507_ui_ActionCount;
extern BOOLEAN G508_B_RefreshActionArea;
extern BOOLEAN G509_B_ActionAreaContainsIcons;
extern char G510_ac_ActionListMinimumSkillLevel[3];
extern unsigned char G511_auc_ActionList[3];
extern unsigned char G512_uc_Useless;
extern int G513_i_ActionDamage;
extern int G514_i_MagicCasterChampionIndex;
extern unsigned int G515_aui_Bitmap_SpellAreaLine[M75_BITMAP_BYTE_COUNT(96, 12) / 2];
extern unsigned int G516_aaui_Bitmap_SpellAreaLines[3][M75_BITMAP_BYTE_COUNT(96, 12) / 2];
extern THING G517_T_ActionTargetGroupThing;
extern char* G518_pc_SystemCallReturnAddress;
extern int G521_i_GameFileHandle;
extern long G522_l_Unreferenced;
extern BOOLEAN G523_B_RestartGameRequested;
extern BOOLEAN G524_B_RestartGameAllowed;
extern long G525_l_GameID;
extern unsigned int G526_ui_DungeonID;
extern int G527_i_Platform;
extern int G528_i_Format;
extern char* G519_pc_D081_ADMGAMEDAT;
extern char* G520_pc_D082_ADMGAMEBAK;
extern int G529_i_Useless;
extern BOOLEAN G530_B_LoadingCompressedDungeon;
extern unsigned char* G531_puc_DecompressedDungeonCurrentPosition;
extern long G532_l_DecompressedDungeonRemainingByteCount;
extern char G533_ac_CodePatch2_COPYPROTECTIONE[68];
extern char G534_ac_SaveHeaderAdditionalData[132];
extern unsigned char G535_auc_BitIndexToMaskConversionTable[8];
extern char* G536_pc_D084_GAMELOADEDREADYTOPLAY;
extern char* G537_pc_D085_CANTMODIFYGAMEDISK;
extern char* G538_pc_D086_THATSNOTTHEMASTERDISK;
extern char* G539_pc_D087_CANTFINDSAVEDGAME;
extern char* G540_pc_D088_UNABLETOSAVEGAME;
extern char* G541_pc_D089_UNABLETOFORMATDISK;
extern char* G542_pc_D090_THATSTHEGAMEDISK;
extern char* G543_pc_D091_THATSAGAMESAVEDISK;
extern char* G544_pc_D092_THATDISKISWRITEPROTECTED;
extern char* G545_pc_D093_THATDISKISUNREADABLE;
extern char* G546_pc_D094_THATSNOTTHESAMEGAME;
extern char* G547_pc_D095_SAVEDGAMEDAMAGED;
extern char* G548_pc_D096_PUTTHEGAMESAVEDISKIN;
extern char* G549_pc_D097_PUTTHEGAMEDISKIN;
extern char* G550_pc_D098_PUTABLANKDISKIN;
extern char* G551_pc_D099_SAVINGGAME;
extern char* G552_pc_D100_LOADINGGAME;
extern char* G553_pc_D101_FORMATTINGDISK;
extern char* G554_pc_D102_FORMATDISKANYWAY;
extern char* G555_pc_D103_THEREISNODISKIN;
extern char* G556_pc_D104_LOADSAVEDGAME;
extern char* G557_pc_D105_SAVEANDPLAY;
extern char* G558_pc_D106_SAVEANDQUIT;
extern char* G559_pc_D107_FORMATFLOPPY;
extern char* G560_pc_D108_OK;
extern char* G561_pc_D109_CANCEL;
extern unsigned char* G562_apuc_Bitmap_EntranceDoorAnimationSteps[10];
extern unsigned char* G563_puc_Graphic4_InterfaceEntranceScreen;
extern unsigned char* G564_puc_Graphic5_InterfaceCredits;
extern unsigned char* G565_puc_Graphic535_Sound02DoorRattle;
extern unsigned char* G566_puc_Graphic534_Sound01Switch;
extern BOOLEAN G567_B_SingleFloppyDrive;
extern int G568_i_DiskType;
extern char* G569_pc_SavedGameFileName;
extern char* G570_pc_SavedGameBackupFileName;
extern char* G571_pc_D116_DRIVEA;
extern char* G572_pc_D117_DRIVEB;
extern int G573_i_GameDiskFloppyDriveIndex;
extern int G574_i_SaveDiskFloppyDriveIndex;
extern char G575_ac_SavedGameFileName[15];
extern char G576_ac_SavedGameBackupFileName[15];
extern char G577_ac_TestFileName[5];
extern BOOLEAN G578_B_UseByteBoxCoordinates;
extern int G579_i_Unreferenced;
extern unsigned int G580_ui_PSGModeRegisterBackup;
extern char* G581_pc_contermSystemVariable;
extern char G582_c_contermSystemVariableBackup;
extern int G583_i_PendingSoundIndex;
extern unsigned int G584_ui_PendingSoundLoud;
extern char G585_ac_CodePatch0_COPYPROTECTIONE[68];
extern int G586_i_ImmediateSoundCount_COPYPROTECTIOND;
extern int G587_i_HideMousePointerRequestCount;
extern int G588_i_MouseButtonsStatus;
extern int G589_i_MousePointerHotspotX;
extern int G590_i_MousePointerHotspotY;
extern long G591_l_MousePointerYX;
extern BOOLEAN G592_B_BuildMousePointerScreenAreaRequested;
extern BOOLEAN G593_B_BuildMousePointerScreenAreaCompleted;
extern BOOLEAN G594_B_BuildMousePointerScreenAreaRequestedInMouseException;
extern BOOLEAN G595_B_MousePointerVisible;
extern BOOLEAN G596_B_NoDrawInVerticalBlankWhileHidingMousePointer;
extern BOOLEAN G597_B_IgnoreMouseMovements;
extern BOOLEAN G598_B_MousePointerBitmapUpdated;
extern unsigned int G599_ui_UseChampionIconOrdinalAsMousePointerBitmap;
extern BOOLEAN G600_B_UseObjectAsMousePointerBitmap;
extern BOOLEAN G601_B_UseHandAsMousePointerBitmap;
extern BOOLEAN G602_B_CurrentMousePointerIsObject;
extern int G603_i_MousePointerScreenAreaCurrentX;
extern int G604_i_MousePointerScreenAreaCurrentY;
extern int G605_i_MousePointerBitmapHotspotX;
extern int G606_i_MousePointerBitmapHotspotY;
extern int G607_i_MousePointerScreenAreaNextX;
extern int G608_i_MousePointerScreenAreaNextY;
extern int G609_i_MousePointerAreaLastLineIndex;
extern unsigned int G610_ui_MousePointerAreaUnitWidth;
extern unsigned char* G611_puc_Bitmap_MousePointerArea;
extern unsigned char* G612_puc_Bitmap_MousePointerAreaCustom;
extern unsigned char* G613_puc_Bitmap_MousePointerOriginalColorsChampionIcon;
extern unsigned char* G614_puc_Bitmap_MousePointerModifiedColorsChampionIcon;
extern unsigned char* G615_puc_Bitmap_MousePointerOriginalColorsObject;
extern unsigned char* G616_puc_Bitmap_MousePointerModifiedColorsObject;
extern unsigned char* G617_puc_Bitmap_MousePointerScreenArea;
extern unsigned char* G618_puc_Bitmap_MousePointerHiddenScreenArea;
extern BOX_BYTE G619_s_Box_MousePointer_ObjectShadow;
extern BOX_BYTE G620_s_Box_MousePointer_Object;
extern BOX_WORD G621_s_Box_MousePointer_ChampionIconShadow;
extern BOX_WORD G622_s_Box_MousePointer_ChampionIcon;
extern BOOLEAN G623_B_Mouse_OnButtonsStatusChangeSemaphore;
extern BOOLEAN G624_B_FloppyDriveTurnedOn_COPYPROTECTIONDF;
extern int G625_i_FloppyDriveDMATimeout_COPYPROTECTIONDF;
extern SUBROUTINE G626_pfV_S080_aaat_COPYPROTECTIONDF_CheckDMATransferCompletion;
extern SUBROUTINE G627_pfV_S081_aaao_COPYPROTECTIONDF_TurnOffFloppyDrive;
extern int G628_i_LastFuzzyBitCount_COPYPROTECTIONE;
extern int G629_i_ConsecutiveIdenticalFuzzyBitCounts_COPYPROTECTIONE;
extern int G630_i_GraphicsDatFileHandle;
extern int G631_i_GraphicsDatFileReferenceCount;
extern unsigned int G632_ui_GraphicCount;
extern long G633_l_GraphicsDatFileSize;
extern unsigned int* G634_pui_GraphicCompressedByteCount;
extern unsigned int* G635_pui_GraphicDecompressedByteCount;
extern unsigned char** G636_ppuc_Graphics;
extern int* G637_pi_NativeBitmapBlockIndices;
extern int* G638_pi_DerivedBitmapBlockIndices;
extern int* G639_pi_DerivedBitmapByteCount;
extern int G640_i_FloppyDiskReadBufferGraphicsDatChunkIndex;
extern unsigned char* G641_puc_CacheMemoryBottom;
extern unsigned char* G642_puc_GraphicMemoryBottom;
extern unsigned char* G643_puc_FloppyDiskReadBuffer_COPYPROTECTIONDF;
extern int G644_i_FloppyDiskReadBufferContentType_COPYPROTECTIONDF;
extern unsigned char* G645_puc_HeapMemoryTop;
extern unsigned char* G646_puc_AvailableHeapMemoryTop;
extern long G647_l_Unreferenced;
extern long G648_l_AvailableHeapMemoryByteCount;
extern unsigned char* G649_puc_GraphicMemoryTop;
extern unsigned char* G650_puc_GraphicMemoryBottomTemp;
extern unsigned char* G651_puc_CacheMemoryTop;
extern unsigned char* G652_puc_AvailableGEMMemoryBottom;
extern long G653_l_AvailableGEMMemoryByteCount;
extern BOOLEAN G654_B_GraphicMemoryInitialized;
extern unsigned char** G655_ppuc_Blocks;
extern long G656_l_AvailableCacheMemoryByteCount;
extern unsigned char* G657_puc_FirstUnusedBlock;
extern unsigned char* G658_puc_FirstUsedBlock;
extern unsigned char* G659_puc_LastUsedBlock;
extern unsigned char* G660_puc_FirstReferencedUsedBlock;
extern BOOLEAN G661_B_LargeHeapMemory;
extern long G662_l_LastResetCacheUsageCountsTime;
extern BOOLEAN G663_B_LZW_RepetitionEnabled;
extern int G664_i_LZW_CodeBitCount;
extern int G665_i_LZW_CurrentMaximumCode;
extern int G666_i_LZW_AbsoluteMaximumCode;
extern char G667_ac_LZW_InputBuffer[12];
extern int G668_i_LZW_DictionaryNextAvailableCode;
extern BOOLEAN G669_B_LZW_DictionaryFlushed;
extern unsigned char G670_auc_LZW_Unreferenced[9];
extern unsigned char G671_auc_LZW_LeastSignificantBitMasks[9];
extern int G672_i_LZW_InputBufferBitIndex;
extern int G673_i_LZW_InputBufferBitCount;
extern int G674_i_LZW_CharacterToRepeat;


/*_******************************* Functions *******************************_*/
/* Labels defined in asm{} blocks are declared as C functions so that they can
be accessed from outside the asm{} blocks where they are defined.
Exxx_: Exceptions declared in asm{} blocks (return with 'rte' instruction)
Fxxx_: Regular C functions
Rxxx_: Routines declared in asm{} blocks (return with 'jmp' instruction)
Sxxx_: Subroutines declared in asm{} blocks (return with 'rts' instruction)
Vxxx_: Variables declared in asm{} blocks

J000: Jump table generated by the linker for function calls between segments
R001: C loader added by the linker (source code in init.c) */
extern VOID F002_xxxx_MAIN_GameLoop_COPYPROTECTIONDF();
extern VOID F003_aaaS_MAIN_ProcessNewPartyMap_COPYPROTECTIONE();
/* F004: main()
F005: function to initialize argc and argv (empty in this program) */
extern VOID F006_aamz_MAIN_HighlightScreenBox();
extern VOID F007_aAA7_MAIN_CopyBytes();
extern VOID F008_aA19_MAIN_ClearBytes();
extern VOID F009_aA49_MAIN_WriteSpacedBytes();
extern VOID F010_aAA7_MAIN_WriteSpacedWords();
extern int V011_1_xxx_RegisterA4Backup();
extern int V012_1_xxx_RegisterA5Backup();
extern int E013_xxxx_MAIN_Exception69Handler_TimerC_DoNothing();
extern int E014_xxxx_MAIN_Exception70Handler_KeyboardMIDI();
extern int V014_1_xxx_JMPTargetAddress();
extern int E015_xxxx_MAIN_Exception72Handler_TimerB_PaletteSwitcher();
extern int S016_xxxx_MAIN_DrawMousePointerHiddenScreenAreaIfNecessary_COPYPROTECTIONDF();
extern int E017_xxxx_MAIN_Exception28Handler_VerticalBlank_COPYPROTECTIONDF();
extern int V017_1_xxx_JMPTargetAddress();
extern VOID F018_aaat_MAIN_SetExceptionVectors();
extern VOID F019_aarz_MAIN_DisplayErrorAndStop();
extern VOID F020_aAA5_MAIN_BlitToViewport();
extern VOID F021_a002_MAIN_BlitToScreen();
extern VOID F022_aaaU_MAIN_Delay();
extern int F023_aarz_MAIN_GetAbsoluteValue();
extern int F024_aatz_MAIN_GetMinimumValue();
extern int F025_aatz_MAIN_GetMaximumValue();
extern int F026_a003_MAIN_GetBoundedValue();
extern unsigned int F027_AA59_MAIN_Get16bitRandomNumber();
extern unsigned int F028_a000_MAIN_Get1BitRandomNumber();
extern unsigned int F029_AA19_MAIN_Get2BitRandomNumber();
extern unsigned int F030_aaaW_MAIN_GetScaledProduct();
extern VOID F031_aAA2_OBJECT_LoadNames();
extern int F032_aaaY_OBJECT_GetType();
extern int F033_aaaz_OBJECT_GetIconIndex();
extern VOID F034_aaau_OBJECT_DrawLeaderHandObjectName();
extern VOID F035_aaaw_OBJECT_ClearLeaderHandObjectName();
extern VOID F036_aA19_OBJECT_ExtractIconFromBitmap();
extern VOID F037_aA29_OBJECT_DrawIconToScreen();
extern VOID F038_AA07_OBJECT_DrawIconInSlotBox();
extern int F039_aaaL_OBJECT_GetIconIndexInSlotBox();
extern VOID F040_aacZ_TEXT_Print();
extern VOID F041_aadZ_TEXT_PrintWithTrailingSpaces();
extern VOID F042_xxxx_TEXT_MESSAGEAREA_MoveCursor();
extern VOID F043_aahz_TEXT_MESSAGEAREA_ClearAllRows();
extern VOID F044_xxxx_TEXT_MESSAGEAREA_ClearExpiredRows();
extern VOID F045_xxxx_TEXT_MESSAGEAREA_CreateNewRow();
extern VOID F046_xxxx_TEXT_MESSAGEAREA_PrintString();
extern VOID F047_xzzz_TEXT_MESSAGEAREA_PrintMessage();
extern VOID F048_xxxx_TEXT_MESSAGEAREA_PrintCharacter_Unreferenced();
extern VOID F049_xxxx_TEXT_MESSAGEAREA_PrintInteger_Unreferenced();
extern VOID F050_xxxx_TEXT_MESSAGEAREA_PrintSpace_Unreferenced();
extern VOID F051_AA19_TEXT_MESSAGEAREA_PrintLineFeed();
extern VOID F052_aaoz_TEXT_PrintToViewport();
extern VOID F053_aajz_TEXT_PrintToLogicalScreen();
extern VOID F054_aAA1_TEXT_Initialize();
extern long R055_xxxx_OS_CallBIOS();
extern long R056_aaal_OS_CallXBIOS();
extern long R057_rzzz_OS_CallGEMDOS();
extern int S058_xxxx_OS_Exception257Handler_CriticalError();
extern int S059_aaac_OS_SetException257Vector_CriticalError();
extern VOID F060_AA29_SOUND_Play();
extern VOID F061_xxxx_SOUND_SetChannelAmplitudes();
extern int E061_aAA6_SOUND_Exception77Handler_TimerA_SoundPlayer();
extern int V061_1_HHH_i_RemainingSoundSampleCount();
extern int V061_2_A79_i_SoundSampleRepeatCount();
extern int V061_3_aav_l_NextSoundSample();
extern int V061_4_GFF_l_CurrentChannelsAmplitudeTable();
extern int V061_5_xxx_al_ChannelsAmplitudeTableLoud();
extern int V061_6_dzz_al_ChannelsAmplitudeTableSoft();
extern VOID F062_aalz_SOUND_Initialize();
extern VOID F063_aA05_SOUND_KeyClickOff();
extern VOID F064_aadz_SOUND_RequestPlay_COPYPROTECTIOND();
extern VOID F065_aanz_SOUND_PlayPendingSound_COPYPROTECTIOND();
extern VOID F066_aalz_MOUSE_Initialize();
extern VOID F067_aaat_MOUSE_SetPointerToNormal();
extern VOID F068_aagz_MOUSE_SetPointerToObject();
extern VOID F069_aaaL_MOUSE_SetPointer();
extern VOID F070_aajz_MOUSE_ProcessCommands125To128_ClickOnChampionIcon();
extern VOID F071_xxxx_MOUSE_DropChampionIcon();
extern int S072_xxxx_MOUSE_DrawPointerHiddenScreenArea();
extern VOID F073_xxxx_MOUSE_BuildPointerScreenArea();
extern VOID F074_xxxx_MOUSE_DrawPointerScreenArea();
extern int S074_xxxx_MOUSE_DrawPointerScreenArea();
extern VOID F075_xxxx_MOUSE_Exception70Handler_IKBD_MIDI_MouseStatus();
extern int S075_aaak_MOUSE_Exception70Handler_IKBD_MIDI_MouseStatus();
extern VOID F076_xxxx_MOUSE_OnMouseButtonsStatusChange();
extern int S076_aaal_MOUSE_OnMouseButtonsStatusChange();
extern VOID F077_aA39_MOUSE_HidePointer_COPYPROTECTIONE();
extern VOID F078_xzzz_MOUSE_ShowPointer();
extern int F079_a002_COPYPROTECTIONC_GetChecksumAdd();
extern int S080_aaat_COPYPROTECTIONDF_CheckDMATransferCompletion();
extern int S081_aaao_COPYPROTECTIONDF_TurnOffFloppyDrive();
/* F082: _ldiv(). Megamax C System Library. Helper function to divide long integers */
extern int _lmul(); /* F083: Megamax C System Library. Helper function to multiply long integers. Used in random functions */
/* F084: _blockmv(). Megamax C System Library. Helper function to copy structures
F085: _blockcmp. Megamax C System Library. Helper function to compare structures
F086: strcat(). Megamax C System Library. Standard C Library function to concatenate strings
F087: strcmp(). Megamax C System Library. Standard C Library function to compare strings
F088: strcpy(). Megamax C System Library. Standard C Library function to copy a string
F089: strncpy(). Megamax C System Library. Standard C Library function to copy n characters from a string
F090: strlen(). Megamax C System Library. Standard C Library function to get length of a string
F091: index(). Megamax C System Library. Standard C Library function to find a character in a string
S092: _init(). Subroutine to initialize BSS segment (global variables and static local variables) generated by compiler and linker */
extern VOID F093_xxxx_DUNGEONVIEW_ApplyCreatureReplacementColors();
extern VOID F094_mzzz_DUNGEONVIEW_LoadFloorSet();
extern VOID F095_izzz_DUNGEONVIEW_LoadWallSet();
extern VOID F096_qzzz_DUNGEONVIEW_LoadCurrentMapGraphics_COPYPROTECTIONDF();
extern VOID F097_lzzz_DUNGEONVIEW_DrawViewport();
extern VOID F098_rzzz_DUNGEONVIEW_DrawFloorAndCeiling();
extern VOID F099_xxxx_DUNGEONVIEW_CopyBitmapAndFlipHorizontal();
extern VOID F100_xxxx_DUNGEONVIEW_DrawWallSetBitmap();
extern VOID F101_xxxx_DUNGEONVIEW_DrawWallSetBitmapWithoutTransparency();
extern VOID F102_xxxx_DUNGEONVIEW_DrawDoorBitmap();
extern VOID F103_xxxx_DUNGEONVIEW_DrawDoorFrameBitmapFlippedHorizontally();
extern VOID F104_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmap();
extern VOID F105_xxxx_DUNGEONVIEW_DrawFloorPitOrStairsBitmapFlippedHorizontally();
extern VOID F106_rzzz_DUNGEONVIEW_TestResetToStep1_COPYPROTECTIONF();
extern BOOLEAN F107_xxxx_DUNGEONVIEW_IsDrawnWallOrnamentAnAlcove_COPYPROTECTIONF();
extern VOID F108_xxxx_DUNGEONVIEW_DrawFloorOrnament();
extern VOID F109_xxxx_DUNGEONVIEW_DrawDoorOrnament();
extern VOID F110_xxxx_DUNGEONVIEW_DrawDoorButton();
extern VOID F111_xxxx_DUNGEONVIEW_DrawDoor();
extern VOID F112_xxxx_DUNGEONVIEW_DrawCeilingPit();
extern VOID F113_xxxx_DUNGEONVIEW_DrawField();
extern unsigned char* F114_xxxx_DUNGEONVIEW_GetExplosionBitmap();
extern VOID F115_xxxx_DUNGEONVIEW_DrawObjectsCreaturesProjectilesExplosions_COPYPROTECTIONEF();
extern VOID F116_xxxx_DUNGEONVIEW_DrawSquareD3L();
extern VOID F117_xxxx_DUNGEONVIEW_DrawSquareD3R();
extern VOID F118_xxxx_DUNGEONVIEW_DrawSquareD3C_COPYPROTECTIONF();
extern VOID F119_xxxx_DUNGEONVIEW_DrawSquareD2L();
extern VOID F120_xxxx_DUNGEONVIEW_DrawSquareD2R_COPYPROTECTIONF();
extern VOID F121_xxxx_DUNGEONVIEW_DrawSquareD2C();
extern VOID F122_xxxx_DUNGEONVIEW_DrawSquareD1L();
extern VOID F123_xxxx_DUNGEONVIEW_DrawSquareD1R();
extern VOID F124_xxxx_DUNGEONVIEW_DrawSquareD1C();
extern VOID F125_xxxx_DUNGEONVIEW_DrawSquareD0L();
extern VOID F126_xxxx_DUNGEONVIEW_DrawSquareD0R();
extern VOID F127_xxxx_DUNGEONVIEW_DrawSquareD0C();
extern VOID F128_rzzz_DUNGEONVIEW_Draw_COPYPROTECTIONF();
extern VOID F129_szzz_VIDEO_BlitShrinkWithPaletteChanges();
extern VOID F130_xxxx_VIDEO_FlipHorizontal();
extern VOID F131_xxxx_VIDEO_FlipVertical();
extern VOID F132_xzzz_VIDEO_Blit();
extern VOID F133_xxxx_VIDEO_BlitBoxFilledWithMaskedBitmap();
extern VOID F134_zzzz_VIDEO_FillBitmap();
extern VOID F135_xzzz_VIDEO_FillBox();
extern VOID F136_nzzz_VIDEO_ShadeScreenBox();
extern VOID F137_pzzz_COPYPROTECTIONEF_PatchFunctionWithHiddenCodeLauncher();
extern int R138_lzzz_COPYPROTECTIONEF_HiddenCodeLauncher();
extern BOOLEAN F139_aqzz_DUNGEON_IsCreatureAllowedOnMap();
extern unsigned int F140_yzzz_DUNGEON_GetObjectWeight();
extern int F141_anzz_DUNGEON_GetObjectInfoIndex();
extern int F142_aqzz_DUNGEON_GetProjectileAspect();
extern unsigned int F143_mzzz_DUNGEON_GetArmourDefense();
extern unsigned int F144_amzz_DUNGEON_GetCreatureAttributes();
extern unsigned int F145_rzzz_DUNGEON_GetGroupCells();
extern VOID F146_aczz_DUNGEON_SetGroupCells();
extern unsigned int F147_aawz_DUNGEON_GetGroupDirections();
extern VOID F148_aayz_DUNGEON_SetGroupDirections();
extern BOOLEAN F149_aawz_DUNGEON_IsWallOrnamentAnAlcove();
extern VOID F150_wzzz_DUNGEON_UpdateMapCoordinatesAfterRelativeMovement();
extern unsigned char F151_rzzz_DUNGEON_GetSquare();
extern unsigned char F152_xxxx_DUNGEON_GetRelativeSquare();
extern int F153_yzzz_DUNGEON_GetRelativeSquareType();
extern int F154_afzz_DUNGEON_GetLocationAfterLevelChange();
extern int F155_ahzz_DUNGEON_GetStairsExitDirection();
extern unsigned char* F156_afzz_DUNGEON_GetThingData();
extern unsigned char* F157_rzzz_DUNGEON_GetSquareFirstThingData();
extern WEAPON_INFO* F158_ayzz_DUNGEON_GetWeaponInfo();
extern THING F159_rzzz_DUNGEON_GetNextThing();
extern int F160_xxxx_DUNGEON_GetSquareFirstThingIndex();
extern THING F161_szzz_DUNGEON_GetSquareFirstThing();
extern THING F162_afzz_DUNGEON_GetSquareFirstObject();
extern VOID F163_amzz_DUNGEON_LinkThingToList();
extern VOID F164_dzzz_DUNGEON_UnlinkThingFromList();
extern THING F165_xxxx_DUNGEON_GetDiscardedThing();
extern THING F166_szzz_DUNGEON_GetUnusedThing();
extern THING F167_aozz_DUNGEON_GetObjectForProjectileLauncherOrObjectGenerator();
extern VOID F168_ajzz_DUNGEON_DecodeText();
extern int F169_xxxx_DUNGEON_GetRandomOrnamentIndex();
extern int F170_xxxx_DUNGEON_GetRandomOrnamentOrdinal();
extern VOID F171_xxxx_DUNGEON_SetSquareAspectRandomWallOrnamentOrdinals();
extern VOID F172_awzz_DUNGEON_SetSquareAspect();
extern VOID F173_gzzz_DUNGEON_SetCurrentMap();
extern VOID F174_aozz_DUNGEON_SetCurrentMapAndPartyMap();
extern THING F175_gzzz_GROUP_GetThing();
extern int F176_avzz_GROUP_GetCreatureOrdinalInCell();
extern int F177_aszz_GROUP_GetMeleeTargetCreatureOrdinal();
extern unsigned int F178_aazz_GROUP_GetGroupValueUpdatedWithCreatureValue();
extern long F179_xxxx_GROUP_GetCreatureAspectUpdateTime();
extern VOID F180_hzzz_GROUP_StartWandering();
extern VOID F181_czzz_GROUP_DeleteEvents();
extern VOID F182_aqzz_GROUP_StopAttacking();
extern VOID F183_kzzz_GROUP_AddActiveGroup();
extern VOID F184_ahzz_GROUP_RemoveActiveGroup();
extern THING F185_auzz_GROUP_GetGenerated();
extern VOID F186_xxxx_GROUP_DropCreatureFixedPossessions();
extern VOID F187_czzz_GROUP_DropMovingCreatureFixedPossessions();
extern VOID F188_aozz_GROUP_DropGroupPossessions();
extern VOID F189_awzz_GROUP_Delete();
extern int F190_zzzz_GROUP_GetDamageCreatureOutcome();
extern int F191_aayz_GROUP_GetDamageAllCreaturesOutcome();
extern int F192_ayzz_GROUP_GetResistanceAdjustedPoisonAttack();
extern VOID F193_xxxx_GROUP_StealFromChampion();
extern VOID F194_hzzz_GROUP_RemoveAllActiveGroups();
extern VOID F195_akzz_GROUP_AddAllActiveGroups();
extern VOID F196_aozz_GROUP_InitializeActiveGroups();
extern BOOLEAN F197_xxxx_GROUP_IsViewPartyBlocked();
extern BOOLEAN F198_xxxx_GROUP_IsSmellPartyBlocked();
extern int F199_xxxx_GROUP_GetDistanceBetweenUnblockedSquares();
extern int F200_xxxx_GROUP_GetDistanceToVisibleParty();
extern int F201_xxxx_GROUP_GetSmelledPartyPrimaryDirectionOrdinal();
extern BOOLEAN F202_xxxx_GROUP_IsMovementPossible();
extern int F203_xxxx_GROUP_GetFirstPossibleMovementDirectionOrdinal();
extern BOOLEAN F204_xxxx_GROUP_IsArchenemyDoubleMovementPossible();
extern VOID F205_xxxx_GROUP_SetDirection();
extern VOID F206_xxxx_GROUP_SetDirectionGroup();
extern BOOLEAN F207_xxxx_GROUP_IsCreatureAttacking();
extern VOID F208_xxxx_GROUP_AddEvent();
extern VOID F209_xzzz_GROUP_ProcessEvents29to41();
extern BOOLEAN F210_uzzz_COPYPROTECTIONE_ProcessEvent22_IsSector7Valid_NormalBytes();
extern SUBROUTINE F211_vzzz_COPYPROTECTIONDF_GetSubroutineAbsoluteAddress();
extern VOID F212_mzzz_PROJECTILE_Create();
extern VOID F213_hzzz_EXPLOSION_Create();
extern VOID F214_pzzz_PROJECTILE_DeleteEvent();
extern VOID F215_lzzz_PROJECTILE_Delete();
extern unsigned int F216_xxxx_PROJECTILE_GetImpactAttack();
extern BOOLEAN F217_xxxx_PROJECTILE_HasImpactOccured();
extern int F218_ezzz_PROJECTILE_GetImpactCount();
extern VOID F219_xxxx_PROJECTILE_ProcessEvents48To49_Projectile();
extern VOID F220_xxxx_EXPLOSION_ProcessEvent25_Explosion();
extern BOOLEAN F221_xxxx_GROUP_IsFluxcageOnSquare();
extern unsigned int F222_xxxx_GROUP_IsLordChaosOnSquare();
extern BOOLEAN F223_xxxx_GROUP_IsSquareACorridorTeleporterPitOrDoor();
extern VOID F224_zzzz_GROUP_FluxCageAction();
extern VOID F225_dzzz_GROUP_FuseAction();
extern int F226_ozzz_GROUP_GetDistanceBetweenSquares();
extern BOOLEAN F227_qzzz_GROUP_IsDestinationVisibleFromSource();
extern int F228_uzzz_GROUP_GetDirectionsWhereDestinationIsVisibleFromSource();
extern VOID F229_hzzz_GROUP_SetOrderedCellsToAttack();
extern int F230_ezzz_GROUP_GetChampionDamage();
extern int F231_izzz_GROUP_GetMeleeActionDamage();
extern BOOLEAN F232_dzzz_GROUP_IsDoorDestroyedByAttack();
extern VOID F233_wzzz_TIMELINE_Initialize();
extern BOOLEAN F234_xxxx_TIMELINE_IsEventABeforeEventB();
extern int F235_bzzz_TIMELINE_GetIndex();
extern VOID F236_pzzz_TIMELINE_FixChronology();
extern VOID F237_rzzz_TIMELINE_DeleteEvent();
extern int F238_pzzz_TIMELINE_AddEvent_GetEventIndex_COPYPROTECTIONE();
extern VOID F239_xxxx_TIMELINE_ExtractFirstEvent();
extern BOOLEAN F240_xxxx_TIMELINE_IsFirstEventExpired_COPYPROTECTIONE();
extern VOID F241_xxxx_TIMELINE_ProcessEvent1_DoorAnimation();
extern VOID F242_xxxx_TIMELINE_ProcessEvent7_Square_FakeWall();
extern VOID F243_xxxx_TIMELINE_ProcessEvent2_DoorDestruction();
extern VOID F244_xxxx_TIMELINE_ProcessEvent10_Square_Door();
extern VOID F245_xxxx_TIMELINE_ProcessEvent5_Square_Corridor();
extern VOID F246_xxxx_TIMELINE_ProcessEvent65_EnableGroupGenerator();
extern VOID F247_xxxx_TIMELINE_TriggerProjectileLauncher();
extern VOID F248_xxxx_TIMELINE_ProcessEvent6_Square_Wall();
extern VOID F249_xxxx_TIMELINE_MoveTeleporterOrPitSquareThings();
extern VOID F250_xxxx_TIMELINE_ProcessEvent8_Square_Teleporter();
extern VOID F251_xxxx_TIMELINE_ProcessEvent9_Square_Pit();
extern VOID F252_xxxx_TIMELINE_ProcessEvents60to61_MoveGroup();
extern VOID F253_xxxx_TIMELINE_ProcessEvent11Part1_EnableChampionAction();
extern VOID F254_xxxx_TIMELINE_ProcessEvent12_HideDamageReceived();
extern VOID F255_xxxx_TIMELINE_ProcessEvent13_ViAltarRebirth();
extern VOID F256_xxxx_TIMELINE_ProcessEvent53_Watchdog();
extern VOID F257_xxxx_TIMELINE_ProcessEvent70_Light();
extern BOOLEAN F258_xxxx_TIMELINE_HasWeaponMovedToSlot();
extern VOID F259_xxxx_TIMELINE_ProcessEvent11Part2_MoveWeaponFromQuiverToSlot();
extern VOID F260_pzzz_TIMELINE_RefreshAllChampionStatusBoxes();
extern VOID F261_hzzz_TIMELINE_Process_COPYPROTECTIONEF();
extern int F262_xxxx_MOVE_GetTeleporterRotatedGroupResult();
extern THING F263_xxxx_MOVE_GetTeleporterRotatedProjectileThing();
extern BOOLEAN F264_avzz_MOVE_IsLevitating();
extern VOID F265_xxxx_MOVE_CreateEvent60To61_MoveGroup();
extern BOOLEAN F266_xxxx_MOVE_IsKilledByProjectileImpact();
extern BOOLEAN F267_dzzz_MOVE_GetMoveResult_COPYPROTECTIONCE();
extern VOID F268_fzzz_SENSOR_AddEvent();
extern VOID F269_xxxx_SENSOR_AddSkillExperience();
extern VOID F270_xxxx_SENSOR_TriggerLocalEffect();
extern VOID F271_xxxx_SENSOR_ProcessRotationEffect();
extern VOID F272_xxxx_SENSOR_TriggerEffect();
extern THING F273_xxxx_SENSOR_GetObjectOfTypeInCell();
extern BOOLEAN F274_xxxx_SENSOR_IsObjectInPartyPossession();
extern BOOLEAN F275_aszz_SENSOR_IsTriggeredByClickOnWall();
extern VOID F276_qzzz_SENSOR_ProcessThingAdditionOrRemoval();
extern BOOLEAN F277_jzzz_COPYPROTECTIONE_IsSector7Valid_FuzzyBits();
extern VOID F278_apzz_CHAMPION_ResetDataToStartGame();
extern int F279_xxxx_CHAMPION_GetDecodedValue();
extern VOID F280_agzz_CHAMPION_AddCandidateChampionToParty();
extern VOID F281_xxxx_CHAMPION_Rename();
extern VOID F282_xzzz_CHAMPION_ProcessCommands160To162_ClickInResurrectReincarnatePanel();
extern VOID F283_azzz_CHAMPION_ViAltarRebirth();
extern VOID F284_czzz_CHAMPION_SetPartyDirection();
extern int F285_szzz_CHAMPION_GetIndexInCell();
extern int F286_hzzz_CHAMPION_GetTargetChampionIndex();
extern VOID F287_xxxx_CHAMPION_DrawBarGraphs();
extern int S287_xxxx_CHAMPION_DrawChampionBarGraphs_Subroutine();
extern char* F288_xxxx_CHAMPION_GetStringFromInteger();
extern VOID F289_xxxx_CHAMPION_DrawHealthOrStaminaOrManaValue();
extern VOID F290_xxxx_CHAMPION_DrawHealthStaminaManaValues();
extern VOID F291_xxxx_CHAMPION_DrawSlot();
extern VOID F292_arzz_CHAMPION_DrawState();
extern VOID F293_ahzz_CHAMPION_DrawAllChampionStates();
extern BOOLEAN F294_aozz_CHAMPION_IsAmmunitionCompatibleWithWeapon();
extern BOOLEAN F295_xxxx_CHAMPION_HasObjectIconInSlotBoxChanged();
extern VOID F296_aizz_CHAMPION_DrawChangedObjectIcons();
extern VOID F297_atzz_CHAMPION_PutObjectInLeaderHand();
extern THING F298_aqzz_CHAMPION_GetObjectRemovedFromLeaderHand();
extern VOID F299_xxxx_CHAMPION_ApplyObjectModifiersToStatistics();
extern THING F300_aozz_CHAMPION_GetObjectRemovedFromSlot();
extern VOID F301_apzz_CHAMPION_AddObjectInSlot();
extern VOID F302_mzzz_CHAMPION_ProcessCommands28To65_ClickOnSlotBox();
extern unsigned int F303_AA09_CHAMPION_GetSkillLevel();
extern VOID F304_apzz_CHAMPION_AddSkillExperience();
extern int F305_xxxx_CHAMPION_GetThrowingStaminaCost();
extern int F306_xxxx_CHAMPION_GetStaminaAdjustedValue();
extern unsigned int F307_fzzz_CHAMPION_GetStatisticAdjustedAttack();
extern BOOLEAN F308_vzzz_CHAMPION_IsLucky();
extern unsigned int F309_awzz_CHAMPION_GetMaximumLoad();
extern int F310_AA08_CHAMPION_GetMovementTicks();
extern int F311_wzzz_CHAMPION_GetDexterity();
extern unsigned int F312_xzzz_CHAMPION_GetStrength();
extern int F313_xxxx_CHAMPION_GetWoundDefense();
extern VOID F314_gzzz_CHAMPION_WakeUp();
extern int F315_arzz_CHAMPION_GetScentOrdinal();
extern VOID F316_aizz_CHAMPION_DeleteScent();
extern VOID F317_adzz_CHAMPION_AddScentStrength();
extern VOID F318_xxxx_CHAMPION_DropAllObjects();
extern VOID F319_xxxx_CHAMPION_Kill();
extern VOID F320_akzz_CHAMPION_ApplyAndDrawPendingDamageAndWounds();
extern int F321_AA29_CHAMPION_AddPendingDamageAndWounds_GetDamage();
extern VOID F322_lzzz_CHAMPION_Poison();
extern VOID F323_xxxx_CHAMPION_Unpoison();
extern int F324_aezz_CHAMPION_DamageAll_GetDamagedChampionCount();
extern VOID F325_bzzz_CHAMPION_DecrementStamina();
extern VOID F326_ozzz_CHAMPION_ShootProjectile();
extern BOOLEAN F327_kzzz_CHAMPION_IsProjectileSpellCast();
extern BOOLEAN F328_nzzz_CHAMPION_IsObjectThrown();
extern BOOLEAN F329_hzzz_CHAMPION_IsLeaderHandObjectThrown();
extern VOID F330_szzz_CHAMPION_DisableAction();
extern VOID F331_auzz_CHAMPION_ApplyTimeEffects_COPYPROTECTIONF();
extern VOID F332_xxxx_INVENTORY_DrawIconToViewport();
extern VOID F333_xxxx_INVENTORY_OpenAndDrawChest();
extern VOID F334_akzz_INVENTORY_CloseChest();
extern VOID F335_xxxx_INVENTORY_DrawPanel_ObjectDescriptionString();
extern VOID F336_xxxx_INVENTORY_DrawPanel_BuildObjectAttributesString();
extern VOID F337_akzz_INVENTORY_SetDungeonViewPalette();
extern VOID F338_atzz_INVENTORY_DecreaseTorchesLightPower_COPYPROTECTIONE();
extern VOID F339_xxxx_INVENTORY_DrawPanel_ArrowOrEye();
extern VOID F340_xxxx_INVENTORY_DrawPanel_ScrollTextLine();
extern VOID F341_xxxx_INVENTORY_DrawPanel_Scroll();
extern VOID F342_xxxx_INVENTORY_DrawPanel_Object();
extern VOID F343_xxxx_INVENTORY_DrawPanel_HorizontalBar();
extern VOID F344_xxxx_INVENTORY_DrawPanel_FoodOrWaterBar();
extern VOID F345_xxxx_INVENTORY_DrawPanel_FoodWaterPoisoned();
extern VOID F346_xxxx_INVENTORY_DrawPanel_ResurrectReincarnate();
extern VOID F347_xxxx_INVENTORY_DrawPanel();
extern VOID F348_xxxx_INVENTORY_AdjustStatisticCurrentValue();
extern VOID F349_dzzz_INVENTORY_ProcessCommand70_ClickOnMouth();
extern VOID F350_aqzz_INVENTORY_DrawStopPressingMouth();
extern VOID F351_xxxx_INVENTORY_DrawChampionSkillsAndStatistics();
extern VOID F352_aszz_INVENTORY_ProcessCommand71_ClickOnEye();
extern VOID F353_auzz_INVENTORY_DrawStopPressingEye();
extern VOID F354_szzz_INVENTORY_DrawStatusBoxPortrait();
extern VOID F355_hzzz_INVENTORY_Toggle_COPYPROTECTIONE();
extern BOOLEAN F356_ozzz_COPYPROTECTIONE_IsSector7Valid_ByteValuesAndFuzzyBitCount();
extern VOID F357_qzzz_COMMAND_DiscardAllInput();
extern int F358_xxxx_COMMAND_GetCommandFromMouseInput_COPYPROTECTIONC();
extern VOID F359_hzzz_COMMAND_ProcessClick_COPYPROTECTIONC();
extern VOID F360_xxxx_COMMAND_ProcessPendingClick();
extern VOID F361_nzzz_COMMAND_ProcessKeyPress();
extern VOID F362_xxxx_COMMAND_HighlightBoxEnable();
extern VOID F363_pzzz_COMMAND_HighlightBoxDisable();
extern VOID F364_xxxx_COMMAND_TakeStairs();
extern VOID F365_xxxx_COMMAND_ProcessTypes1To2_TurnParty();
extern VOID F366_xxxx_COMMAND_ProcessTypes3To6_MoveParty();
extern VOID F367_xxxx_COMMAND_ProcessTypes12To27_ClickInChampionStatusBox();
extern VOID F368_fzzz_COMMAND_SetLeader();
extern VOID F369_xxxx_COMMAND_ProcessTypes101To108_ClickInSpellSymbolsArea_COPYPROTECTIONE();
extern VOID F370_xxxx_COMMAND_ProcessType100_ClickInSpellArea();
extern VOID F371_xxxx_COMMAND_ProcessType111To115_ClickInActionArea_COPYPROTECTIONE();
extern VOID F372_xxxx_COMMAND_ProcessType80_ClickInDungeonView_TouchFrontWall();
extern VOID F373_xxxx_COMMAND_ProcessType80_ClickInDungeonView_GrabLeaderHandObject();
extern VOID F374_xxxx_COMMAND_ProcessType80_ClickInDungeonView_DropLeaderHandObject();
extern BOOLEAN F375_xxxx_COMMAND_ProcessType80_ClickInDungeonView_IsLeaderHandObjectThrown();
extern BOOLEAN F376_xxxx_COMMAND_IsPointInBox();
extern VOID F377_xxxx_COMMAND_ProcessType80_ClickInDungeonView();
extern VOID F378_xxxx_COMMAND_ProcessType81_ClickInPanel();
extern VOID F379_jzzz_COMMAND_DrawSleepScreen();
extern VOID F380_xzzz_COMMAND_ProcessQueue_COPYPROTECTIONC();
extern VOID F381_xxxx_MENUS_PrintMessageAfterReplacements();
extern int F382_xxxx_MENUS_GetActionObjectChargeCount();
extern VOID F383_xxxx_MENUS_SetActionList();
extern char* F384_xxxx_MENUS_GetActionName();
extern VOID F385_xxxx_MENUS_DrawActionDamage();
extern VOID F386_ezzz_MENUS_DrawActionIcon();
extern VOID F387_hzzz_MENUS_DrawActionArea();
extern VOID F388_rzzz_MENUS_ClearActingChampion();
extern VOID F389_xxxx_MENUS_ProcessCommands116To119_SetActingChampion();
extern VOID F390_rzzz_MENUS_RefreshActionAreaAndSetChampionDirectionMaximumDamageReceived();
extern BOOLEAN F391_xxxx_MENUS_DidClickTriggerAction();
extern VOID F392_xxxx_MENUS_BuildSpellAreaLine();
extern VOID F393_lzzz_MENUS_DrawSpellAreaControls();
extern VOID F394_ozzz_MENUS_SetMagicCasterAndDrawSpellArea();
extern VOID F395_pzzz_MENUS_DrawMovementArrows();
extern VOID F396_pzzz_MENUS_LoadSpellAreaLinesBitmap();
extern VOID F397_xxxx_MENUS_DrawAvailableSymbols();
extern VOID F398_xxxx_MENUS_DrawChampionSymbols();
extern VOID F399_xxxx_MENUS_AddChampionSymbol();
extern VOID F400_xxxx_MENUS_DeleteChampionSymbol();
extern BOOLEAN F401_xxxx_MENUS_IsGroupFrightenedByAction();
extern BOOLEAN F402_xxxx_MENUS_IsMeleeActionPerformed();
extern BOOLEAN F403_xxxx_MENUS_IsPartySpellOrFireShieldSuccessful();
extern VOID F404_xxxx_MENUS_CreateEvent70_Light();
extern VOID F405_xxxx_MENUS_DecrementCharges();
extern VOID F406_xxxx_MENUS_SetChampionDirectionToPartyDirection();
extern BOOLEAN F407_xxxx_MENUS_IsActionPerformed();
extern int F408_xxxx_MENUS_GetClickOnSpellCastResult();
extern SPELL* F409_xxxx_MENUS_GetSpellFromSymbols();
extern VOID F410_xxxx_MENUS_PrintSpellFailureMessage();
extern POTION* F411_xxxx_MENUS_GetEmptyFlaskInHand();
extern int F412_xxxx_MENUS_GetChampionSpellCastResult();
extern int F413_AA08_COPYPROTECTIONC_GetChecksumEor();
extern VOID F414_xxxx_SAVEUTIL_ReplaceTildeByDriveLetterInString();
extern BOOLEAN F415_xxxx_SAVEUTIL_IsReadBytesSuccessful();
extern BOOLEAN F416_xxxx_SAVEUTIL_IsWriteBytesSuccessful();
extern unsigned int F417_xxxx_SAVEUTIL_GetChecksumAndObfuscate();
extern unsigned int F418_xxxx_SAVEUTIL_GetChecksum();
extern BOOLEAN F419_xxxx_SAVEUTIL_IsReadObfuscatedBytesAndValidateChecksumSuccessful();
extern BOOLEAN F420_xxxx_SAVEUTIL_IsWriteObfuscatedSavePartSuccessful();
extern BOOLEAN F421_xxxx_SAVEUTIL_IsReadBytesWithChecksumSuccessful();
extern BOOLEAN F422_xxxx_SAVEUTIL_IsWriteBytesWithChecksumSuccessful();
extern VOID F423_xxxx_SAVEUTIL_FixClonedThings();
extern int F424_xxxx_DIALOG_GetChoice();
extern VOID F425_xxxx_DIALOG_PrintCenteredChoice();
extern BOOLEAN F426_xxxx_DIALOG_IsMessageOnTwoLines();
extern VOID F427_xxxx_DIALOG_Draw();
extern BOOLEAN F428_AA39_DIALOG_RequireGameDiskInDrive_NoDialogDrawn();
extern BOOLEAN F429_xxxx_STARTEND_IsReadSaveHeaderSuccessful();
extern BOOLEAN F430_xxxx_STARTEND_IsWriteObfuscatedSaveHeaderSuccessful();
extern unsigned int F431_xxxx_STARTEND_GetDarkenedColor();
extern BOOLEAN F432_xxxx_STARTEND_FormatDiskMenu(); /* In CSB20EN and CSB21EN, this function returns VOID (no return value) */
extern VOID F433_AA39_STARTEND_ProcessCommand140_SaveGame_COPYPROTECTIONCDF();
extern BOOLEAN F434_xxxx_STARTEND_IsLoadDungeonSuccessful_COPYPROTECTIONC();
extern int F435_xxxx_STARTEND_LoadGame_COPYPROTECTIONF();
extern VOID F436_xxxx_STARTEND_FadeToPalette();
extern VOID F437_xxxx_STARTEND_DrawTitle();
extern VOID F438_xxxx_STARTEND_OpenEntranceDoors();
extern VOID F439_xxxx_STARTEND_DrawEntrance();
extern long F440_xxxx_STARTEND_GetTemporarilyLoadedGraphicByteCount();
extern VOID F441_xxxx_STARTEND_ProcessEntrance();
extern VOID F442_AA08_STARTEND_ProcessCommand202_EntranceDrawCredits();
extern VOID F443_xxxx_STARTEND_EndgamePrintString();
extern VOID F444_AA29_STARTEND_Endgame();
extern VOID F445_xxxx_STARTEND_FuseSequenceUpdate();
extern VOID F446_zzzz_STARTEND_FuseSequence();
extern VOID F447_xxxx_STARTEND_HangIfFalse_COPYPROTECTIONA();
extern VOID F448_xxxx_MEMINIT_InitializeMemoryManager_COPYPROTECTIONADEF();
extern BOOLEAN F449_xxxx_FLOPPY_IsDiskWriteProtected();
extern VOID F450_xxxx_FLOPPY_ForceMediaChangeDetection();
extern VOID F451_xxxx_FLOPPY_Initialize();
extern int F452_xxxx_FLOPPY_GetDiskTypeInDrive_COPYPROTECTIONB();
extern BOOLEAN F453_xxxx_FLOPPY_IsFormatDiskSuccessful();
extern BOOLEAN F454_xxxx_FLOPPY_IsSaveDiskTypeInSaveDiskDrive();
extern VOID F455_xxxx_FLOPPY_DecompressDungeon();
extern VOID F456_vzzz_START_DrawDisabledMenus();
extern VOID F457_AA08_START_DrawEnabledMenus_COPYPROTECTIONF();
extern int F458_xxxx_START_GetCommandLineParameters_COPYPROTECTIONA();
extern int F459_xxxx_START_GetScaledBitmapByteCount();
extern VOID F460_xxxx_START_InitializeGraphicData();
extern VOID F461_AA08_START_AllocateFlippedWallBitmaps();
extern VOID F462_xxxx_START_StartGame_COPYPROTECTIONF();
extern VOID F463_wzzz_START_InitializeGame_COPYPROTECTIONADEF();
extern int F464_AA07_COPYPROTECTIONC_GetChecksumSub();
extern int S465_qzzz_COPYPROTECTIOND_ReadSector247();
extern VOID F466_rzzz_EXPAND_GraphicToBitmap();
extern long F467_xxxx_MEMORY_GetGraphicOffset();
extern unsigned char* F468_ozzz_MEMORY_Allocate();
extern VOID F469_rzzz_MEMORY_FreeAtHeapTop();
extern VOID F470_xzzz_MEMORY_FreeAtHeapBottom();
extern VOID F471_xxxx_CACHE_RemoveUnusedBlock();
extern VOID F472_xxxx_CACHE_AddUnusedBlock();
extern VOID F473_xxxx_MEMORY_SortValues();
extern VOID F474_xxxx_MEMORY_LoadGraphic_COPYPROTECTIONDF();
extern VOID F475_ozzz_MEMORY_Initialize();
extern VOID F476_mzzz_MEMORY_InitializeGraphicMemory();
extern VOID F477_izzz_MEMORY_OpenGraphicsDat_COPYPROTECTIONDF();
extern VOID F478_gzzz_MEMORY_CloseGraphicsDat_COPYPROTECTIONDF();
extern VOID F479_izzz_MEMORY_ReadGraphicsDatHeader();
extern VOID F480_AA07_CACHE_ReleaseBlock();
extern VOID F481_xxxx_CACHE_FreeMemory();
extern VOID F482_xxxx_CACHE_Defragment();
extern unsigned char* F483_xxxx_CACHE_GetNewBlock();
extern VOID F484_gzzz_MEMORY_LoadGraphics_COPYPROTECTIONDEF();
extern VOID F485_xxxx_CACHE_ResetUsageCounts();
extern VOID F486_xxxx_MEMORY_AddBlockToUsedList();
extern unsigned char* F487_xxxx_CACHE_GetBlockAndIncrementUsageCount();
extern VOID F488_bzzz_MEMORY_ExpandGraphicToBitmap();
extern unsigned char* F489_ayzz_MEMORY_GetNativeBitmapOrGraphic();
extern VOID F490_lzzz_MEMORY_LoadDecompressAndExpandGraphic();
extern BOOLEAN F491_xzzz_CACHE_IsDerivedBitmapInCache();
extern unsigned char* F492_mzzz_CACHE_GetDerivedBitmap();
extern VOID F493_hzzz_CACHE_AddDerivedBitmap();
extern unsigned int F494_ozzz_MEMORY_GetGraphicDecompressedByteCount();
extern int F495_xxxx_LZW_GetNextInputCode();
extern VOID F496_xxxx_LZW_OutputCharacter();
extern long F497_pzzz_LZW_Decompress();


/*_**************************** Memory addresses ***************************_*/
#define C0x0070_ADDRESS_INTERRUPT_AUTOVECTOR_4_VERTICAL_BLANK       0x0070 /* Interrupt Autovector Level 4 (Vertical Blank) */
#define C0x0090_ADDRESS_INTERRUPT_VECTOR_TRAP_4                     0x0090 /* TRAP #4 */
#define C0x0114_ADDRESS_INTERRUPT_VECTOR_5_MFP_TIMER_C              0x0114 /* Interrupt Vector 5 MFP Timer C (200hz Clock) */
#define C0x0118_ADDRESS_INTERRUPT_VECTOR_6_KEYBOARD_MIDI            0x0118 /* Interrupt Vector 6 Keyboard/MIDI (ACIA) */
#define C0x0120_ADDRESS_INTERRUPT_VECTOR_8_TIMER_B_HORIZONTAL_BLANK 0x0120 /* Interrupt Vector 8 Timer B (Horizontal Blank) */
#define C0x0404_ADDRESS_SYSTEM_VARIABLE_etv_critic                  0x0404 /* GEM Critical error handler */
#define C0x043E_ADDRESS_SYSTEM_VARIABLE_flock                       0x043E /* Floppy lock */
#define C0x0472_ADDRESS_SYSTEM_VARIABLE_hdv_bpb                     0x0472 /* Vector for getbpb for hard disk */
#define C0x0476_ADDRESS_SYSTEM_VARIABLE_hdv_rw                      0x0476 /* Vector for read/write routine for hard disk */
#define C0x047E_ADDRESS_SYSTEM_VARIABLE_hdv_mediach                 0x047E /* Vector for hard disk media change */
#define C0x0484_ADDRESS_SYSTEM_VARIABLE_conterm                     0x0484 /* Attribute vector for console output */
#define C0x04A6_ADDRESS_SYSTEM_VARIABLE__nflops                     0x04A6 /* Number of connected floppy drives */
#define C0x04F2_ADDRESS_SYSTEM_VARIABLE__sysbase                    0x04F2 /* Pointer to start of OS */

/*_************* Structure, macros and constants for OS calls **************_*/
typedef struct {
        VOID (*midivec)();  /* MIDI Input */
        VOID (*vkbderr)();  /* IKBD Error */
        VOID (*vmiderr)();  /* MIDI Error */
        VOID (*statvec)();  /* IKBD Status */
        VOID (*mousevec)(); /* IKBD Mouse */
        VOID (*clockvec)(); /* IKBD Clock */
        VOID (*joyvec)();   /* IKBD Joystick */
        VOID (*midisys)();  /* Main MIDI Vector */
        VOID (*ikbdsys)();  /* Main IKBD Vector */
        char ikbdstate;
} KBDVECS;

#define Rwabs(a, b, c, d, e)               (long)R055_xxxx_OS_CallBIOS(0x04, a, b, c, d, e)
#define Logbase()                          (char*)R056_aaal_OS_CallXBIOS(0x03)
#define Setscreen(a, b, c)                 (VOID)R056_aaal_OS_CallXBIOS(0x05, a, b, c)
#define Setpalette(a)                      (VOID)R056_aaal_OS_CallXBIOS(0x06, a)
#define Floprd(a, b, c, d, e, f, g)        (int)R056_aaal_OS_CallXBIOS(0x08, a, b, c, d, e, f, g)
#define Flopwr(a, b, c, d, e, f, g)        (long)R056_aaal_OS_CallXBIOS(0x09, a, b, c, d, e, f, g)
#define Flopfmt(a, b, c, d, e, f, g, h, i) (long)R056_aaal_OS_CallXBIOS(0x0A, a, b, c, d, e, f, g, h, i)
#define Random()                           (unsigned long)R056_aaal_OS_CallXBIOS(0x11)
#define Protobt(a, b, c, d)                (VOID)R056_aaal_OS_CallXBIOS(0x12, a, b, c, d)
#define Jdisint(a)                         (VOID)R056_aaal_OS_CallXBIOS(0x1A, a)
#define Jenabint(a)                        (VOID)R056_aaal_OS_CallXBIOS(0x1B, a)
#define Giaccess(a, b)                     (char)R056_aaal_OS_CallXBIOS(0x1C, a, b)
#define Xbtimer(a, b, c, d)                (VOID)R056_aaal_OS_CallXBIOS(0x1F, a, b, c, d)
#define Kbdvbase()                         (KBDVECS*)R056_aaal_OS_CallXBIOS(0x22)
#define Vsync()                            (VOID)R056_aaal_OS_CallXBIOS(0x25)
#define Supexec(a)                         (long)R056_aaal_OS_CallXBIOS(0x26, a)
#define Cconout(a)                         (VOID)R057_rzzz_OS_CallGEMDOS(0x02, a)
#define Crawcin()                          (long)R057_rzzz_OS_CallGEMDOS(0x07)
#define Cconws(a)                          (VOID)R057_rzzz_OS_CallGEMDOS(0x09, a)
#define Cconis()                           (int)R057_rzzz_OS_CallGEMDOS(0x0B)
#define Super(a)                           (long)R057_rzzz_OS_CallGEMDOS(0x20, a)
#define Fcreate(a, b)                      (long)R057_rzzz_OS_CallGEMDOS(0x3C, a, b)
#define Fopen(a, b)                        (long)R057_rzzz_OS_CallGEMDOS(0x3D, a, b)
#define Fclose(a)                          (long)R057_rzzz_OS_CallGEMDOS(0x3E, a)
#define Fread(a, b, c)                     (long)R057_rzzz_OS_CallGEMDOS(0x3F, a, b, c)
#define Fwrite(a, b, c)                    (long)R057_rzzz_OS_CallGEMDOS(0x40, a, b, c)
#define Fdelete(a)                         (long)R057_rzzz_OS_CallGEMDOS(0x41, a)
#define Fseek(a, b, c)                     (long)R057_rzzz_OS_CallGEMDOS(0x42, a, b, c)
#define Malloc(a)                          (long)R057_rzzz_OS_CallGEMDOS(0x48, a)
#define Fsfirst(a, b)                      (long)R057_rzzz_OS_CallGEMDOS(0x4E, a, b)
#define Frename(a, b, c)                   (long)R057_rzzz_OS_CallGEMDOS(0x56, a, b, c)

#define C0_RESERVED                                                      0
#define CM13_ERROR_EWRPRO_MEDIUM_WRITE_PROTECTED                       -13
#define C0L_FILLER                                                      0L
#define C001_SECTOR_1                                                    1
#define C007_SECTOR_7                                                    7
#define C010_SECTOR_10                                                  10
#define C247_SECTOR_247                                                247
#define C0_TRACK_0                                                       0
#define C0_SIDE_0                                                        0
#define C1_ONE_SECTOR                                                    1
#define C2_TWO_SECTORS                                                   2
#define C9_SECTORS_PER_TRACK                                             9
#define C1_INTERLEAVE                                                    1
#define C0x87654321_MAGIC                                       0x87654321
#define C0_READ_WITH_MEDIA_CHANGE                                        0
#define C0_LOGICAL_SECTOR_0                                              0
#define C0_FILE_ATTRIBUTES                                               0
#define C0_READ_ONLY                                                     0
#define C0_SEEK_FROM_BEGINNING_OF_FILE                                   0
#define C2_SEEK_FROM_END_OF_FILE                                         2
#define C0_TIMER_A                                                       0
#define C1_DELAY_MODE_4_PRESCALE                                         1
#define C05_INTERRUPT_TIMER_C                                            5
#define C13_INTERRUPT_TIMER_A                                           13
#define CM1L_NO_CHANGE                                                  -1L
#define CM1_NO_RESOLUTION_CHANGE                                        -1
#define C0x01000001_SERIAL_RANDOM                               0x01000001
#define C2_80_TRACKS_SINGLE_SIDED                                        2
#define C0_DISK_NOT_EXECUTABLE                                           0
#define MASK0x0000_READ_PSG_REGISTER                                0x0000
#define MASK0x0080_WRITE_PSG_REGISTER                               0x0080
#define C07_REGISTER_PSG_MODE                                            7
#define C11_REGISTER_PSG_WAVEFORM_FREQUENCY_LOW_BYTE                    11
#define C12_REGISTER_PSG_WAVEFORM_FREQUENCY_HIGH_BYTE                   12
#define C0x003F_MODE_ENABLE_TONE_AND_WHITE_NOISE_CHANNELS_A_B_C     0x003F
