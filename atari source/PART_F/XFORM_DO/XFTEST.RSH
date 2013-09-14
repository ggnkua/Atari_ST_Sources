#define T0OBJ 0
#define T1OBJ 13
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 25

BYTE *rs_strings[] = {
"Test dialog with editable text",
"______",
"EDIT:______",
"XXXXXX",
"______",
"EDIT:______",
"XXXXXX",
"______",
"EDIT:______",
"XXXXXX",
"Swell",
"Foo",
"Radio Buttons!",
" Desk ",
" File ",
"  This is XFTEST  ",
"--------------------",
"1",
"2",
"3",
"4",
"5",
"6",
"  Test   ",
"  Quit   "};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
1L, 2L, 3L, 3, 6, 0, 0x1180, 0x0, -1, 7,12,
4L, 5L, 6L, 3, 6, 0, 0x1180, 0x0, -1, 7,12,
7L, 8L, 9L, 3, 6, 0, 0x1180, 0x0, -1, 7,12};

OBJECT rs_object[] = {
-1, 1, 7, G_BOX, NONE, NORMAL, 0x1100L, 12,1538, 64,28,
2, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 2,1, 30,1,
3, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x0L, 3,3, 11,1,
4, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x1L, 47,5, 11,1,
5, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x2L, 3,7, 11,1,
6, -1, -1, G_BUTTON, 0x7, NORMAL, 0xAL, 26,8, 8,1,
7, -1, -1, G_BUTTON, 0x5, NORMAL, 0xBL, 26,10, 8,1,
0, 8, 12, G_BOX, NONE, NORMAL, 0xFF1100L, 2,9, 22,3,
9, -1, -1, G_BOXCHAR, 0x11, NORMAL, 0x31FF1100L, 0,2, 4,1,
10, -1, -1, G_BOXCHAR, 0x11, NORMAL, 0x32FF1100L, 6,2, 4,1,
11, -1, -1, G_BOXCHAR, 0x11, NORMAL, 0x33FF1100L, 12,2, 4,1,
12, -1, -1, G_BOXCHAR, 0x11, NORMAL, 0x34FF1100L, 18,2, 4,1,
7, -1, -1, G_STRING, LASTOB, NORMAL, 0xCL, 4,0, 14,1,
-1, 1, 5, G_IBOX, NONE, NORMAL, 0x0L, 0,0, 90,25,
5, 2, 2, G_BOX, NONE, NORMAL, 0x1100L, 0,0, 90,513,
1, 3, 4, G_IBOX, NONE, NORMAL, 0x0L, 2,0, 12,769,
4, -1, -1, G_TITLE, NONE, NORMAL, 0xDL, 0,0, 6,769,
2, -1, -1, G_TITLE, NONE, NORMAL, 0xEL, 6,0, 6,769,
0, 6, 15, G_IBOX, NONE, NORMAL, 0x0L, 0,769, 80,19,
15, 7, 14, G_BOX, NONE, NORMAL, 0xFF1100L, 2,0, 20,8,
8, -1, -1, G_STRING, NONE, DISABLED, 0xFL, 0,0, 20,1,
9, -1, -1, G_STRING, NONE, DISABLED, 0x10L, 0,1, 20,1,
10, -1, -1, G_STRING, NONE, NORMAL, 0x11L, 0,2, 20,1,
11, -1, -1, G_STRING, NONE, NORMAL, 0x12L, 0,3, 20,1,
12, -1, -1, G_STRING, NONE, NORMAL, 0x13L, 0,4, 20,1,
13, -1, -1, G_STRING, NONE, NORMAL, 0x14L, 0,5, 20,1,
14, -1, -1, G_STRING, NONE, NORMAL, 0x15L, 0,6, 20,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0x16L, 0,7, 20,1,
5, 16, 17, G_BOX, NONE, NORMAL, 0xFF1100L, 8,0, 11,2,
17, -1, -1, G_STRING, NONE, NORMAL, 0x17L, 0,0, 11,1,
15, -1, -1, G_STRING, LASTOB, NORMAL, 0x18L, 0,1, 11,1};

LONG rs_trindex[] = {
0L,
13L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 25
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 3
#define NUM_OBS 31
#define NUM_TREE 2

BYTE pname[] = "XFTEST.RSC";