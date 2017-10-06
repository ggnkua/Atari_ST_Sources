#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 40

BYTE *rs_strings[] = {
"V",
"",
"",
"E",
"",
"",
"R",
"",
"",
"T",
"",
"",
"C",
"",
"",
"A",
"",
"",
"L",
"",
"",
"I",
"",
"",
"00",
"",
"",
"SAMPLE POPUP",
"",
"",
"AAAA",
"",
"",
"Horizontal",
"",
"",
"00",
"",
"",
"Exit"};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
0L, 1L, 2L, 3, 6, 0, 0x1180, 0x0, -1, 2,1,
3L, 4L, 5L, 3, 6, 0, 0x1180, 0x0, -1, 2,1,
6L, 7L, 8L, 3, 6, 0, 0x1180, 0x0, -1, 2,1,
9L, 10L, 11L, 3, 6, 0, 0x1180, 0x0, -1, 2,1,
12L, 13L, 14L, 3, 6, 0, 0x1180, 0x0, -1, 2,1,
15L, 16L, 17L, 3, 6, 0, 0x1180, 0x0, -1, 2,1,
18L, 19L, 20L, 3, 6, 0, 0x1180, 0x0, -1, 2,1,
21L, 22L, 23L, 3, 6, 0, 0x1180, 0x0, -1, 2,1,
24L, 25L, 26L, 3, 6, 2, 0x1180, 0x0, -1, 3,1,
27L, 28L, 29L, 3, 6, 2, 0x1180, 0x0, -1, 13,1,
30L, 31L, 32L, 3, 6, 2, 0x1180, 0x0, -1, 5,1,
33L, 34L, 35L, 3, 6, 2, 0x1180, 0x0, -1, 11,1,
36L, 37L, 38L, 3, 6, 2, 0x1180, 0x0, -1, 3,1};

OBJECT rs_object[] = {
-1, 1, 24, G_BOX, TOUCHEXIT, NORMAL, 0x1141L, 12,1538, 32,11,
16, 2, 11, G_BOX, NONE, NORMAL, 0xFF1100L, 279,0, 1800,2568,
11, 3, 10, G_IBOX, NONE, NORMAL, 0x1100L, 1,1280, 3,8,
4, -1, -1, G_TEXT, NONE, NORMAL, 0x0L, 0,0, 1794,769,
5, -1, -1, G_TEXT, NONE, NORMAL, 0x1L, 0,1, 3,1,
6, -1, -1, G_TEXT, NONE, NORMAL, 0x2L, 0,2, 3,1,
7, -1, -1, G_TEXT, NONE, NORMAL, 0x3L, 0,3, 3,257,
8, -1, -1, G_TEXT, NONE, NORMAL, 0x4L, 0,5, 3,1,
9, -1, -1, G_TEXT, NONE, NORMAL, 0x5L, 0,6, 3,1,
10, -1, -1, G_TEXT, NONE, NORMAL, 0x6L, 0,7, 2,1,
2, -1, -1, G_TEXT, NONE, NORMAL, 0x7L, 0,4, 3,257,
1, 12, 15, G_BOX, NONE, NORMAL, 0xFF1141L, 1794,0, 6,2568,
14, 13, 13, G_BOX, TOUCHEXIT, NORMAL, 0xFF1111L, 1025,1538, 1794,3587,
12, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, 0x8L, 0,1, 1794,1025,
15, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x2FF1100L, 1025,1286, 1794,1,
11, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x1FF1100L, 1025,1281, 1794,1,
17, -1, -1, G_BOXTEXT, NONE, NORMAL, 0x9L, 0,0, 23,1281,
18, -1, -1, G_BOXTEXT, TOUCHEXIT, SHADOWED, 0xAL, 265,1282, 520,769,
24, 19, 23, G_BOX, NONE, NORMAL, 0xFF1141L, 0,1029, 23,1539,
20, -1, -1, G_BOXTEXT, NONE, NORMAL, 0xBL, 0,0, 23,513,
22, 21, 21, G_BOX, TOUCHEXIT, NORMAL, 0xFF1111L, 7,2561, 9,1025,
20, -1, -1, G_BOXTEXT, TOUCHEXIT, NORMAL, 0xCL, 1794,0, 259,1025,
23, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x3FF1100L, 272,2561, 1538,1025,
18, -1, -1, G_BOXCHAR, TOUCHEXIT, NORMAL, 0x4FF1100L, 260,2561, 1538,1025,
0, 25, 25, G_BOX, NONE, NORMAL, 0xFF1100L, 0,2824, 32,1282,
24, -1, -1, G_BUTTON, 0x27, NORMAL, 0x27L, 1290,2304, 1290,513};

LONG rs_trindex[] = {
0L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 40
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 13
#define NUM_OBS 26
#define NUM_TREE 1

BYTE pname[] = "SAMPLE.RSC";
