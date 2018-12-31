#define T0OBJ 0
#define T1OBJ 22
#define T2OBJ 37
#define T3OBJ 49
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 84

BYTE *rs_strings[] = {
" TextDemo  ",
" Exit  ",
" Display  ",
"  About TEXTDEMO ",
"--------------------",
"1",
"2",
"3",
"4",
"5",
"6",
"  Quit       ",
"  Char Attributes ",
"  Display Line    ",
"  Erase Window    ",
"Line Attributes",
"",
"",
"Here is your text line.       ",
"Text: ______________________________",
"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
"010",
"Display at (X-coordinate): ___",
"999",
"010",
"Display at (Y-coordinate): ___",
"999",
"300",
"Line Width  (in pixels)  : ___",
"999",
"020",
"Line Height (in pixels)  : ___",
"999",
"B",
"Justification (None/Char/Word/Both): _",
"X",
"L",
"Horiz. Align. (Left/Center/Right)  : _",
"X",
"B",
"Vert (Floor/Desc/Base/Half/Asc/Top): _",
"X",
"0000",
"Baseline Rotation (degrees * 10): ____",
"9999",
"  OK  ",
" Cancel ",
"Character Attributes",
"",
"",
" 1",
"Font i.d. (always use 1 on ST) : __",
"99",
"10",
"Char. Height (Points or Pixels): __",
"99",
"N",
"Is \"Character Height\" in pixels?  _",
"X",
" 0",
"Special Effects Flags (Decimal): __",
"99",
" 1",
"Foreground (Text) Color        : __",
"99",
" 0",
"Background (Line) Color        : __",
"99",
"  OK  ",
" Cancel ",
"GEM Text Display Demo",
"",
"",
"by Corey Cole",
"",
"",
" OK ",
"copyright 1986 by ANTIC Publishing",
"",
"",
"    This utility is intended",
"to be used with the \"Displaying",
"Text With GEM\" article in the",
"premiere issue of STart."};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
15L, 16L, 17L, 3, 6, 2, 0x1000, 0x0, -1, 16,1,
18L, 19L, 20L, 3, 6, 2, 0x1180, 0x0, -2, 31,37,
21L, 22L, 23L, 3, 6, 0, 0x1180, 0x0, -1, 4,31,
24L, 25L, 26L, 3, 6, 0, 0x1180, 0x0, -1, 4,31,
27L, 28L, 29L, 3, 6, 0, 0x1180, 0x0, -1, 4,31,
30L, 31L, 32L, 3, 6, 0, 0x1180, 0x0, -1, 4,31,
33L, 34L, 35L, 3, 6, 0, 0x1180, 0x0, -1, 2,39,
36L, 37L, 38L, 3, 6, 0, 0x1180, 0x0, -1, 2,39,
39L, 40L, 41L, 3, 6, 0, 0x1180, 0x0, -1, 2,39,
42L, 43L, 44L, 3, 6, 0, 0x1180, 0x0, -1, 5,39,
47L, 48L, 49L, 3, 6, 2, 0x1000, 0x0, -1, 21,1,
50L, 51L, 52L, 3, 6, 0, 0x1180, 0x0, -1, 3,36,
53L, 54L, 55L, 3, 6, 0, 0x1180, 0x0, -1, 3,36,
56L, 57L, 58L, 3, 6, 0, 0x1180, 0x0, -1, 2,36,
59L, 60L, 61L, 3, 6, 0, 0x1180, 0x0, -1, 3,36,
62L, 63L, 64L, 3, 6, 0, 0x1180, 0x0, -1, 3,36,
65L, 66L, 67L, 3, 6, 0, 0x1180, 0x0, -1, 3,36,
70L, 71L, 72L, 3, 6, 2, 0x1000, 0x0, -1, 22,1,
73L, 74L, 75L, 3, 6, 2, 0x1000, 0x0, -1, 14,1,
77L, 78L, 79L, 3, 6, 2, 0x1180, 0x0, -1, 35,1};

OBJECT rs_object[] = {
-1, 1, 6, G_IBOX, NONE, NORMAL, 0x0L, 0,0, 80,25,
6, 2, 2, G_BOX, NONE, NORMAL, 0x1100L, 0,0, 80,513,
1, 3, 5, G_IBOX, NONE, NORMAL, 0x0L, 2,0, 28,769,
4, -1, -1, G_TITLE, NONE, NORMAL, 0x0L, 0,0, 11,769,
5, -1, -1, G_TITLE, NONE, NORMAL, 0x1L, 11,0, 7,769,
2, -1, -1, G_TITLE, NONE, NORMAL, 0x2L, 18,0, 10,769,
0, 7, 18, G_IBOX, NONE, NORMAL, 0x0L, 0,769, 80,19,
16, 8, 15, G_BOX, NONE, NORMAL, 0xFF1100L, 2,0, 20,8,
9, -1, -1, G_STRING, NONE, NORMAL, 0x3L, 0,0, 20,1,
10, -1, -1, G_STRING, NONE, DISABLED, 0x4L, 0,1, 20,1,
11, -1, -1, G_STRING, NONE, NORMAL, 0x5L, 0,2, 20,1,
12, -1, -1, G_STRING, NONE, NORMAL, 0x6L, 0,3, 20,1,
13, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 0,4, 20,1,
14, -1, -1, G_STRING, NONE, NORMAL, 0x8L, 0,5, 20,1,
15, -1, -1, G_STRING, NONE, NORMAL, 0x9L, 0,6, 20,1,
7, -1, -1, G_STRING, NONE, NORMAL, 0xAL, 0,7, 20,1,
18, 17, 17, G_BOX, NONE, NORMAL, 0xFF1100L, 13,0, 13,1,
16, -1, -1, G_STRING, NONE, NORMAL, 0xBL, 0,0, 13,1,
6, 19, 21, G_BOX, NONE, NORMAL, 0xFF1100L, 20,0, 18,3,
20, -1, -1, G_STRING, NONE, NORMAL, 0xCL, 0,0, 18,1,
21, -1, -1, G_STRING, NONE, NORMAL, 0xDL, 0,1, 18,1,
18, -1, -1, G_STRING, LASTOB, NORMAL, 0xEL, 0,2, 18,1,
-1, 1, 14, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 41,18,
3, 2, 2, G_BOX, NONE, NORMAL, 0xFF1171L, 1,1, 26,3,
1, -1, -1, G_TEXT, NONE, NORMAL, 0x0L, 0,0, 26,3,
4, -1, -1, G_FBOXTEXT, EDITABLE, NORMAL, 0x1L, 1,5, 38,2,
13, 5, 12, G_BOX, NONE, NORMAL, 0x1100L, 1,8, 39,9,
6, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x2L, 0,0, 39,1,
7, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x3L, 0,1, 39,1,
8, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x4L, 0,2, 39,1,
9, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x5L, 0,3, 39,1,
10, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x6L, 0,5, 39,1,
11, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x7L, 0,6, 39,1,
12, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x8L, 0,7, 39,1,
4, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x9L, 0,8, 39,1,
14, -1, -1, G_BUTTON, 0x7, NORMAL, 0x2DL, 31,1, 8,1,
0, -1, -1, G_BUTTON, 0x25, NORMAL, 0x2EL, 31,3, 8,1,
-1, 1, 11, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 39,13,
3, 2, 2, G_BOX, NONE, NORMAL, 0xFF1171L, 2,1, 24,3,
1, -1, -1, G_TEXT, NONE, NORMAL, 0xAL, 0,0, 24,3,
10, 4, 9, G_BOX, NONE, NORMAL, 0x1100L, 2,5, 36,7,
5, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0xBL, 0,0, 36,1,
6, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0xCL, 0,1, 36,1,
7, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0xDL, 0,2, 36,1,
8, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0xEL, 0,4, 36,1,
9, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0xFL, 0,5, 36,1,
3, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x10L, 0,6, 36,1,
11, -1, -1, G_BUTTON, 0x7, NORMAL, 0x44L, 29,1, 8,1,
0, -1, -1, G_BUTTON, 0x25, NORMAL, 0x45L, 29,3, 8,1,
-1, 1, 6, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 40,14,
4, 2, 3, G_BOX, NONE, NORMAL, 0xFD1171L, 3,1, 26,4,
3, -1, -1, G_TEXT, NONE, NORMAL, 0x11L, 0,0, 26,2,
1, -1, -1, G_TEXT, NONE, NORMAL, 0x12L, 0,2, 26,1,
5, -1, -1, G_BUTTON, 0x7, NORMAL, 0x4CL, 32,2, 6,1,
6, -1, -1, G_TEXT, NONE, NORMAL, 0x13L, 3,6, 34,1,
0, 7, 10, G_BOX, NONE, OUTLINED, 0xFF1100L, 3,8, 34,4,
8, -1, -1, G_STRING, NONE, NORMAL, 0x50L, 1,0, 28,1,
9, -1, -1, G_STRING, NONE, NORMAL, 0x51L, 1,1, 31,1,
10, -1, -1, G_STRING, NONE, NORMAL, 0x52L, 1,2, 29,1,
6, -1, -1, G_STRING, LASTOB, NORMAL, 0x53L, 1,3, 24,1};

LONG rs_trindex[] = {
0L,
22L,
37L,
49L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 84
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 20
#define NUM_OBS 60
#define NUM_TREE 4

BYTE pname[] = "TXDEMO.RSC";