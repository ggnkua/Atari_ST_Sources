#define T0OBJ 0
#define T1OBJ 17
#define T2OBJ 18
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 11

BYTE *rs_strings[] = {
" Desk ",
" File ",
"  Craigs Menu",
"--------------------",
"  Desk Accessory 1  ",
"  Desk Accessory 2  ",
"  Desk Accessory 3  ",
"  Desk Accessory 4  ",
"  Desk Accessory 5  ",
"  Desk Accessory 6  ",
"  Quit       "};

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
-1, 1, 5, G_IBOX, NONE, NORMAL, 0x0L, 0,0, 80,25,
5, 2, 2, G_BOX, NONE, NORMAL, 0x1100L, 0,0, 80,513,
1, 3, 4, G_IBOX, NONE, NORMAL, 0x0L, 2,0, 12,769,
4, -1, -1, G_TITLE, NONE, NORMAL, 0x0L, 0,0, 6,769,
2, -1, -1, G_TITLE, NONE, NORMAL, 0x1L, 6,0, 6,769,
0, 6, 15, G_IBOX, NONE, NORMAL, 0x0L, 0,769, 80,19,
15, 7, 14, G_BOX, NONE, NORMAL, 0xFF1100L, 2,0, 20,8,
8, -1, -1, G_STRING, NONE, NORMAL, 0x2L, 0,0, 20,1,
9, -1, -1, G_STRING, NONE, DISABLED, 0x3L, 0,1, 20,1,
10, -1, -1, G_STRING, NONE, NORMAL, 0x4L, 0,2, 20,1,
11, -1, -1, G_STRING, NONE, NORMAL, 0x5L, 0,3, 20,1,
12, -1, -1, G_STRING, NONE, NORMAL, 0x6L, 0,4, 20,1,
13, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 0,5, 20,1,
14, -1, -1, G_STRING, NONE, NORMAL, 0x8L, 0,6, 20,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x9L, 0,7, 20,1,
5, 16, 16, G_BOX, NONE, NORMAL, 0xFF1100L, 8,0, 13,1,
15, -1, -1, G_STRING, LASTOB, NORMAL, 0xAL, 0,0, 13,1,
-1, -1, -1, G_BOX, LASTOB, OUTLINED, 0x21100L, 0,0, 70,15,
-1, -1, -1, G_BOX, LASTOB, OUTLINED, 0x21100L, 0,0, 70,15};

LONG rs_trindex[] = {
0L,
17L,
18L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 11
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 0
#define NUM_OBS 19
#define NUM_TREE 3

BYTE pname[] = "CRAIG.RSC";