#define T0OBJ 0
#define FREEBB 0
#define FREEIMG 0
#define FREESTR 19

BYTE *rs_strings[] = {
"System Statistics",
"0000",
"__.__",
"9999",
"00000000",
"__/__/____",
"99999999",
"ST Free RAM:",
"00000000",
"TT Free RAM:",
"00000000",
"Total Free RAM:",
"00000000",
"TOS Version:",
"TOS Date:",
"Exit",
"00000000",
"____/__/__",
"99999999"};

LONG rs_frstr[] = {
0};

BITBLK rs_bitblk[] = {
0};

LONG rs_frimg[] = {
0};

ICONBLK rs_iconblk[] = {
0};

TEDINFO rs_tedinfo[] = {
1L, 2L, 3L, 3, 6, 0, 0x1180, 0x0, -1, 5,6,
4L, 5L, 6L, 3, 6, 0, 0x1180, 0x0, -1, 9,11,
16L, 17L, 18L, 3, 6, 0, 0x1180, 0x0, -1, 9,11};

OBJECT rs_object[] = {
-1, 1, 1, G_BOX, NONE, NORMAL, 0xFF1141L, 0,0, 32,11,
0, 2, 3, G_BOX, NONE, OUTLINED, 0x11100L, 2,769, 1819,2568,
3, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 773,0, 17,1,
1, 4, 16, G_BOX, NONE, NORMAL, 0xFF1100L, 256,513, 1307,1799,
5, -1, -1, G_FTEXT, NONE, NORMAL, 0x0L, 1556,0, 773,769,
6, -1, -1, G_FTEXT, NONE, NORMAL, 0x1L, 1551,769, 10,1,
13, 7, 12, G_BOX, NONE, NORMAL, 0xFF1100L, 1792,1794, 1817,3,
8, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 1,0, 12,1,
9, -1, -1, G_STRING, NONE, NORMAL, 0x8L, 17,0, 8,1,
10, -1, -1, G_STRING, NONE, NORMAL, 0x9L, 1,1, 12,1,
11, -1, -1, G_STRING, NONE, NORMAL, 0xAL, 17,1, 8,1,
12, -1, -1, G_STRING, NONE, NORMAL, 0xBL, 1,2, 15,1,
6, -1, -1, G_STRING, NONE, NORMAL, 0xCL, 17,2, 8,1,
14, -1, -1, G_STRING, NONE, NORMAL, 0xDL, 1281,512, 14,1,
15, -1, -1, G_STRING, NONE, NORMAL, 0xEL, 1281,769, 9,1,
16, -1, -1, G_BUTTON, 0x7, NORMAL, 0xFL, 1545,6, 8,1,
3, -1, -1, G_FTEXT, 0xA0, NORMAL, 0x2L, 1035,769, 10,1};

LONG rs_trindex[] = {
0L};

struct foobar {
	WORD	dummy;
	WORD	*image;
	} rs_imdope[] = {
0};

#define NUM_STRINGS 19
#define NUM_FRSTR 0
#define NUM_IMAGES 0
#define NUM_BB 0
#define NUM_FRIMG 0
#define NUM_IB 0
#define NUM_TI 3
#define NUM_OBS 17
#define NUM_TREE 1

BYTE pname[] = "PARTZ.RSC";