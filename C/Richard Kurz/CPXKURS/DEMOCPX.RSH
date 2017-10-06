#define T0OBJ 0
#define FREEBB 1
#define FREEIMG 1
#define FREESTR 17

BYTE *rs_strings[] = {
"  Demo CPX",
"",
"",
"PopUp",
"Aus",
"V",
"e",
"r",
"t",
".",
"123",
"Noch ein MenÅ",
"123",
"OK",
"Abbruch",
"Sichern",
"Horizontal"};

WORD IMAG0[] = {
0x0, 0x0, 0x0, 0x0, 
0x0, 0x0, 0x0, 0x0, 
0x7, 0xE000, 0xF, 0xF000, 
0xF, 0xF000, 0xF, 0xF000, 
0xF, 0xF000, 0xF, 0xF000, 
0xF, 0xF000, 0xF, 0xF000, 
0x7, 0xE000, 0x7, 0xE000, 
0x7, 0xE000, 0x3, 0xC000, 
0x3, 0xC000, 0x0, 0x0, 
0x0, 0x0, 0x3, 0xC000, 
0x7, 0xE000, 0x7, 0xE000, 
0x3, 0xC000, 0x0, 0x0};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0L, 4, 24, 0, 0, 1};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
0L, 1L, 2L, 3, 6, 0, 0x1180, 0x0, 2, 11,1};

OBJECT rs_object[] = {
-1, 1, 28, G_BOX, NONE, NORMAL, 0xFF1141L, 0,0, 32,11,
3, 2, 2, G_BOXTEXT, NONE, OUTLINED, 0x0L, 1,2048, 15,2,
1, -1, -1, G_IMAGE, NONE, NORMAL, 0x0L, 522,768, 4,2049,
4, -1, -1, G_BUTTON, SELECTABLE, NORMAL, 0x3L, 20,2048, 11,1,
6, 5, 5, G_BOX, NONE, NORMAL, 0xFF1141L, 20,2049, 11,2049,
4, -1, -1, G_BUTTON, TOUCHEXIT, SHADOWED, 0x4L, 2,512, 7,1,
12, 7, 11, G_BOX, NONE, NORMAL, 0xFF1101L, 20,3, 3,2053,
8, -1, -1, G_STRING, NONE, NORMAL, 0x5L, 1,2048, 1,1,
9, -1, -1, G_STRING, NONE, NORMAL, 0x6L, 1,2049, 1,1,
10, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 1,2050, 1,1,
11, -1, -1, G_STRING, NONE, NORMAL, 0x8L, 1,2051, 1,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x9L, 1,2052, 1,1,
17, 13, 16, G_BOX, NONE, NORMAL, 0xFF1141L, 23,3, 8,2053,
15, 14, 14, G_BOX, TOUCHEXIT, NORMAL, 0xFF1111L, 2,2049, 4,2050,
13, -1, -1, G_BUTTON, TOUCHEXIT, NORMAL, 0xAL, 0,2048, 4,1,
16, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2FF1100L, 2,4, 4,1,
12, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1FF1100L, 2,2048, 4,1,
18, -1, -1, G_BUTTON, TOUCHEXIT, SHADOWED, 0xBL, 1,2051, 15,1,
23, 19, 22, G_BOX, NONE, NORMAL, 0xFF1141L, 1,2054, 15,2,
21, 20, 20, G_BOX, TOUCHEXIT, NORMAL, 0xFF1111L, 3,2048, 9,1,
19, -1, -1, G_BUTTON, TOUCHEXIT, NORMAL, 0xCL, 2,0, 4,1,
22, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x4FF1100L, 1,2048, 2,1,
18, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x3FF1100L, 12,2048, 2,1,
28, 24, 26, G_BOX, NONE, NORMAL, 0xFF1100L, 0,9, 32,2,
25, -1, -1, G_BUTTON, 0x7, NORMAL, 0xDL, 1036,2048, 8,1,
26, -1, -1, G_BUTTON, 0x5, NORMAL, 0xEL, 22,2048, 9,1,
23, 27, 27, G_BOX, NONE, NORMAL, 0xFF1100L, 0,0, 11,2,
26, -1, -1, G_BUTTON, 0x5, NORMAL, 0xFL, 1,2048, 9,1,
0, -1, -1, G_BUTTON, LASTOB, NORMAL, 0x10L, 1,2053, 15,1};

LONG rs_trindex[] = {
0L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0, &IMAG0[0]};

#define NUM_STRINGS 17
#define NUM_FRSTR 0
#define NUM_IMAGES 1
#define NUM_BB 1
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 1
#define NUM_OBS 29
#define NUM_TREE 1

BYTE pname[] = "DEMOCPX.RSC";