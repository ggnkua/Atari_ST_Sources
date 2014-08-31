#define T0OBJ 0
#define T1OBJ 2
#define T2OBJ 22
#define FREEBB 0
#define FREEIMG 2
#define FREESTR 28

BYTE *rs_strings[] = {
"Sample",
" Sample Server ",
"",
"",
" (w) 1996  by  Peter Rottengatter ",
"",
"",
"Beverage :",
"",
"Coca Cola",
"",
"Fanta",
"",
"Sprite",
"___",
"Use Port No. ___",
"999",
"Continent :",
"  Antarctica  ",
"Save",
"Accept",
"Cancel",
"  America",
"  Africa",
"  Antarctica",
"  Asia",
"  Australia",
"  Europe"};

WORD IMAG0[] = {
0x0, 0x0, 0x7, 0xE000, 
0x1F, 0xF800, 0x7F, 0xFE00, 
0x1FF, 0xFF80, 0x7FF, 0xFFE0, 
0x1FFF, 0xFFF8, 0x7FFF, 0xFFFE, 
0xFFFF, 0xFFFF, 0x7FFF, 0xFFFE, 
0x3FFF, 0xFFFC, 0x1FFF, 0xFFF8, 
0xFFF, 0xFFF0, 0x7FF, 0xFFE0, 
0x3FF, 0xFFC0, 0x1FF, 0xFF80, 
0xFF, 0xFF00, 0x7F, 0xFE00, 
0x3F, 0xFC00, 0x1F, 0xF800, 
0xF, 0xF000, 0x7, 0xE000, 
0x3, 0xC000, 0x0, 0x0};

WORD IMAG1[] = {
0x0, 0x0, 0x7, 0xE000, 
0x19, 0x9800, 0x62, 0x4600, 
0x184, 0x2180, 0x608, 0x1060, 
0x1810, 0x818, 0x6020, 0x406, 
0xFFFF, 0xFFFF, 0x4040, 0x202, 
0x2020, 0x404, 0x1020, 0x408, 
0x810, 0x810, 0x410, 0x820, 
0x208, 0x1040, 0x108, 0x1080, 
0x84, 0x2100, 0x44, 0x2200, 
0x22, 0x4400, 0x12, 0x4800, 
0x9, 0x9000, 0x5, 0xA000, 
0x3, 0xC000, 0x0, 0x0};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0L, 1L, 0L, 4096,13,9, 2,0,32,24, 0,26,36,8};

TEDINFO rs_tedinfo[] = {
1L, 2L, 3L, 3, 6, 2, 0x1180, 0x0, -1, 16,1,
4L, 5L, 6L, 5, 6, 0, 0x1180, 0x0, -1, 35,1,
14L, 15L, 16L, 3, 6, 0, 0x1180, 0x0, -1, 4,17};

OBJECT rs_object[] = {
-1, 1, 1, G_BOX, NONE, NORMAL, 0x11100L, 0,0, 529,5,
0, -1, -1, G_ICON, 0x21, NORMAL, 0x0L, 262,769, 1028,514,
-1, 1, 17, G_BOX, NONE, NORMAL, 0x1100L, 0,0, 37,3597,
4, 2, 3, G_BOX, NONE, NORMAL, 0xFF1100L, 0,0, 37,2307,
3, -1, -1, G_TEXT, NONE, NORMAL, 0x0L, 11,2560, 15,1,
1, -1, -1, G_TEXT, NONE, NORMAL, 0x1L, 6,2, 26,1,
12, 5, 11, G_IBOX, NONE, NORMAL, 0x1100L, 22,1028, 13,5,
6, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 0,3072, 10,1,
7, -1, -1, 0x11A, 0x11, 0x6, 0x6DL, 1,2, 2,1,
8, -1, -1, G_STRING, NONE, NORMAL, 0x9L, 4,2, 9,1,
9, -1, -1, 0x11A, 0x11, 0x6, 0x78L, 1,3, 2,1,
10, -1, -1, G_STRING, NONE, NORMAL, 0xBL, 4,3, 5,1,
11, -1, -1, 0x11A, 0x11, 0x6, 0x7FL, 1,4, 2,1,
4, -1, -1, G_STRING, NONE, NORMAL, 0xDL, 4,4, 6,1,
13, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x2L, 2,5, 16,1,
14, -1, -1, G_STRING, NONE, NORMAL, 0x11L, 2,3590, 11,1,
15, -1, -1, G_BUTTON, TOUCHEXIT, SHADOWED, 0x12L, 5,1544, 14,1,
17, 16, 16, G_BOX, NONE, NORMAL, 0xFF1100L, 0,11, 12,3586,
15, -1, -1, G_BUTTON, 0x5, NORMAL, 0x13L, 3,3840, 6,1,
0, 18, 19, G_BOX, NONE, NORMAL, 0xFF1100L, 12,11, 25,3586,
19, -1, -1, G_BUTTON, 0x5, NORMAL, 0x14L, 3,3840, 8,1,
17, -1, -1, G_BUTTON, 0x25, NORMAL, 0x15L, 14,3840, 8,1,
-1, 1, 6, G_BOX, NONE, SHADOWED, 0xFF1100L, 0,0, 14,6,
2, -1, -1, G_STRING, NONE, NORMAL, 0x16L, 0,0, 14,1,
3, -1, -1, G_STRING, NONE, CHECKED, 0x17L, 0,1, 14,1,
4, -1, -1, G_STRING, NONE, NORMAL, 0x18L, 0,2, 14,1,
5, -1, -1, G_STRING, NONE, NORMAL, 0x19L, 0,3, 14,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x1AL, 0,4, 14,1,
0, -1, -1, G_STRING, LASTOB, NORMAL, 0x1BL, 0,5, 14,1};

LONG rs_trindex[] = {
0L,
2L,
22L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0, &IMAG0[0],
0, &IMAG1[0]};

#define NUM_STRINGS 28
#define NUM_FRSTR 0
#define NUM_IMAGES 2
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 1
#define NUM_TI 3
#define NUM_OBS 29
#define NUM_TREE 3

BYTE pname[] = "SAMPLE.RSC";