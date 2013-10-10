#define T0OBJ 0
#define T1OBJ 10
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 13

BYTE *rs_strings[] = {
"FORMAT DISK",
"drive:",
"A:",
"___________",
"disk label: ________.___",
"FFFFFFFFFFF",
"format:",
"cancel",
"format",
"single sided",
"double sided",
"FORMAT DISK",
"working ..."};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
3L, 4L, 5L, 3, 6, 0, 0x1180, 0x0, -1, 12,25};

OBJECT rs_object[] = {
-1, 1, 9, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 40,12,
2, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 2,1, 11,1,
3, -1, -1, G_STRING, NONE, NORMAL, 0x1L, 6,4, 16,1,
4, -1, -1, G_STRING, NONE, NORMAL, 0x2L, 23,4, 2,1,
5, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x0L, 6,6, 28,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x6L, 6,8, 7,1,
7, -1, -1, G_BUTTON, 0x5, NORMAL, 0x7L, 30,2, 9,1,
8, -1, -1, G_BUTTON, 0x5, NORMAL, 0x8L, 30,4, 9,1,
9, -1, -1, G_BUTTON, 0x11, NORMAL, 0x9L, 7,10, 14,1,
0, -1, -1, G_BUTTON, 0x31, NORMAL, 0xAL, 23,10, 14,1,
-1, 1, 4, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 40,12,
2, -1, -1, G_STRING, NONE, NORMAL, 0xBL, 2,1, 11,1,
4, 3, 3, G_BOX, NONE, NORMAL, 0xFF1100L, 3,10, 29,1,
2, -1, -1, G_BOX, NONE, NORMAL, 0x11111L, 0,0, 6,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, 0xCL, 2,3, 13,1};

LONG rs_trindex[] = {
0L,
10L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 13
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 1
#define NUM_OBS 15
#define NUM_TREE 2

BYTE pname[] = "FORMAT.RSC";