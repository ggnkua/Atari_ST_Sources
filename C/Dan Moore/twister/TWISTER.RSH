#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 12

BYTE *rs_strings[] = {
"Format",
"Exit",
"Single",
"Double",
"A",
"B",
"Mega-Twister",
"drive",
"David Small and Dan Moore",
"sides",
"by",
"version 2.0"};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
0};

OBJECT rs_object[] = {
-1, 1, 14, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 32,17,
2, -1, -1, G_BUTTON, 0x5, NORMAL, 0x0L, 19,14, 8,1,
3, -1, -1, G_BUTTON, 0x7, NORMAL, 0x1L, 4,14, 8,1,
6, 4, 5, G_BOX, NONE, NORMAL, 0x100L, 19,9, 8,3,
5, -1, -1, G_BUTTON, 0x11, NORMAL, 0x2L, 0,0, 8,1,
3, -1, -1, G_BUTTON, 0x11, NORMAL, 0x3L, 0,1, 8,1,
9, 7, 8, G_BOX, NONE, NORMAL, 0x100L, 4,9, 8,3,
8, -1, -1, G_BUTTON, 0x11, NORMAL, 0x4L, 0,0, 8,1,
6, -1, -1, G_BUTTON, 0x11, NORMAL, 0x5L, 0,1, 8,1,
10, -1, -1, G_STRING, NONE, NORMAL, 0x6L, 10,2, 12,1,
11, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 5,8, 5,1,
12, -1, -1, G_STRING, NONE, NORMAL, 0x8L, 4,5, 25,1,
13, -1, -1, G_STRING, NONE, NORMAL, 0x9L, 20,8, 5,1,
14, -1, -1, G_STRING, NONE, NORMAL, 0xAL, 15,4, 2,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, 0xBL, 11,3, 11,1};

LONG rs_trindex[] = {
0L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 12
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 0
#define NUM_OBS 15
#define NUM_TREE 1

BYTE pname[] = "TWISTER.RSC";