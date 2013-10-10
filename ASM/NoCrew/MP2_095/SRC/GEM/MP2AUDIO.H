/* If tos.h defines the wrong names!! */
#define Vsetmode setmode
#define setmode setsndmode

/* #define STATIC_BUFFER */

#define STOP_BLOCK 1024
#define BLOCK_SIZE DEFAULT_BLOCK_SIZE*1024L


#define MUTE 1
#define MUTE_RESTORE 0

#define MPG_MD_STEREO           0#define MPG_MD_JOINT_STEREO     1#define MPG_MD_DUAL_CHANNEL     2#define MPG_MD_MONO             3
typedef struct { int x,y,w,h; } CORDS;

/* defines for toggle_object() */
#define SET_NORMAL -1
#define TOGGLE 0
#define SET_SELECTED 1
